package main

import (
	"bufio"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"gopkg.in/yaml.v3"
)

const (
	sourceDir   = "/home/luuk/Obsidian/Vault"
	destDir     = "/home/luuk/quartz/content"
	imagesDir   = "Images"
	imageFolder = "Images"
)

var safeFiles = map[string]struct{}{
	"_index.md":  {},
	"sidebar.md": {},
	"README.md":  {},
}

// FrontMatter struct for parsing YAML frontmatter
type FrontMatter struct {
	Published bool `yaml:"published"`
}

func main() {
	publishedNotes := []string{}
	imageSet := map[string]struct{}{}

	// Walk the sourceDir recursively
	err := filepath.WalkDir(sourceDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if d.IsDir() {
			return nil
		}

		if filepath.Ext(path) == ".md" {
			published, err := isPublished(path)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Error reading frontmatter in %s: %v\n", path, err)
				return nil // skip this file but continue
			}

			if published {
				rel, err := filepath.Rel(sourceDir, path)
				if err != nil {
					return err
				}

				destPath := filepath.Join(destDir, rel)
				if err := copyFile(path, destPath); err != nil {
					fmt.Fprintf(os.Stderr, "Error copying %s: %v\n", path, err)
				} else {
					fmt.Printf("Copied note: %s\n", rel)
					publishedNotes = append(publishedNotes, path)
				}
			}
		}

		return nil
	})

	if err != nil {
		fmt.Fprintf(os.Stderr, "Error walking source dir: %v\n", err)
		os.Exit(1)
	}

	// Extract images referenced in published notes
	imageLinkRe := regexp.MustCompile(`!\[\[([^\]]+\.(png|jpg|jpeg|gif|svg))\]\]`)

	for _, note := range publishedNotes {
		content, err := os.ReadFile(note)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error reading %s: %v\n", note, err)
			continue
		}

		matches := imageLinkRe.FindAllSubmatch(content, -1)
		for _, m := range matches {
			imgName := string(m[1])
			imgPath := filepath.Join(sourceDir, imagesDir, imgName)
			if _, err := os.Stat(imgPath); err == nil {
				imageSet[imgPath] = struct{}{}
			} else {
				fmt.Fprintf(os.Stderr, "Warning: image not found: %s\n", imgPath)
			}
		}
	}

	// Step 3: Remove notes in content/ that are no longer published
	fmt.Println("Checking for obsolete notes to delete...")

	err = filepath.WalkDir(destDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if d.IsDir() || filepath.Ext(path) != ".md" {
			return nil
		}

		// Get the relative path from content/
		relPath, err := filepath.Rel(destDir, path)
		if err != nil {
			return err
		}

		// Check if it’s still published
		isStillPublished := false
		for _, publishedNote := range publishedNotes {
			if sameFile(relPath, publishedNote, sourceDir) {
				isStillPublished = true
				break
			}
		}

		if !isStillPublished {
			if _, protected := safeFiles[relPath]; protected {
				fmt.Printf("Skipping protected file: %s\n", relPath)
				return nil
			}
			err := os.Remove(path)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Error deleting %s: %v\n", path, err)
			} else {
				fmt.Printf("Deleted obsolete note: %s\n", relPath)
			}
		}

		return nil
	})

	// Copy images
	for imgPath := range imageSet {
		rel, err := filepath.Rel(sourceDir, imgPath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error getting relative path for %s: %v\n", imgPath, err)
			continue
		}

		destPath := filepath.Join(destDir, rel)
		if err := copyFile(imgPath, destPath); err != nil {
			fmt.Fprintf(os.Stderr, "Error copying image %s: %v\n", imgPath, err)
		} else {
			fmt.Printf("Copied image: %s\n", rel)
		}
	}
}

func sameFile(relPath string, fullPath string, sourceBase string) bool {
	expected := filepath.Join(sourceBase, relPath)
	absExpected, _ := filepath.Abs(expected)
	absActual, _ := filepath.Abs(fullPath)
	return absExpected == absActual
}

// isPublished reads YAML frontmatter of the file to check if published: true
func isPublished(path string) (bool, error) {
	f, err := os.Open(path)
	if err != nil {
		return false, err
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	inFrontMatter := false
	var frontMatterLines []string

	for scanner.Scan() {
		line := scanner.Text()
		if strings.TrimSpace(line) == "---" {
			if !inFrontMatter {
				inFrontMatter = true
			} else {
				// End of frontmatter
				break
			}
			continue
		}
		if inFrontMatter {
			frontMatterLines = append(frontMatterLines, line)
		} else if len(frontMatterLines) == 0 {
			// No frontmatter, exit early
			break
		}
	}

	if len(frontMatterLines) == 0 {
		// No frontmatter found
		return false, nil
	}

	frontMatterContent := strings.Join(frontMatterLines, "\n")
	var fm FrontMatter
	err = yaml.Unmarshal([]byte(frontMatterContent), &fm)
	if err != nil {
		return false, fmt.Errorf("yaml parse error: %w", err)
	}

	return fm.Published, nil
}

// copyFile copies file src to dst creating parent directories as needed
func copyFile(src, dst string) error {
	input, err := os.ReadFile(src)
	if err != nil {
		return err
	}

	err = os.MkdirAll(filepath.Dir(dst), 0755)
	if err != nil {
		return err
	}

	return os.WriteFile(dst, input, 0644)
}
