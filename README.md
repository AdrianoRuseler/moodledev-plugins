# moodledev-plugins
Plugins for Moodle dev

## Plugins List

```bash
mkdir moodle
cd moodle
```
- https://moodle.org/plugins/tool_pluginskel
- https://github.com/mudrd8mz/moodle-tool_pluginskel
```bash
git submodule add -b main https://github.com/mudrd8mz/moodle-tool_pluginskel.git admin/tool/pluginskel
```

- https://moodle.org/plugins/local_codechecker
- https://github.com/moodlehq/moodle-local_codechecker
```bash
git submodule add -b master https://github.com/moodlehq/moodle-local_codechecker.git local/codechecker
```

- https://moodle.org/plugins/local_moodlecheck
- https://github.com/moodlehq/moodle-local_moodlecheck

```bash
git submodule add -b master https://github.com/moodlehq/moodle-local_moodlecheck.git local/moodlecheck
```

- https://moodle.org/plugins/local_adminer
- https://github.com/grabs/moodle-local_adminer

```bash
git submodule add -b MOODLE_39_STABLE https://github.com/grabs/moodle-local_adminer.git local/adminer
```


## Remove
```bash
git submodule deinit <path_to_submodule>
git rm <path_to_submodule>
git commit -m "Removed submodule "
rm -rf .git/modules/<path_to_submodule>
```
