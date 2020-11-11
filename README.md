# moodledev-plugins
Plugins for Moodle dev

## Plugins List

```bash
mkdir moodle
cd moodle
```

- https://moodle.org/plugins/local_codechecker
- https://github.com/moodlehq/moodle-local_codechecker
```bash
git submodule add -b master https://github.com/moodlehq/moodle-local_codechecker.git local/codechecker
```


## Remove
```bash
git submodule deinit <path_to_submodule>
git rm <path_to_submodule>
git commit -m "Removed submodule "
rm -rf .git/modules/<path_to_submodule>
```
