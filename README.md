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

- https://github.com/valentineus/moodle-webhooks

```bash
git submodule add -b v3.0.0-stable https://github.com/valentineus/moodle-webhooks.git local/webhooks
```

## Remove

```bash
SUBMPATH="moodle/path/to/submodule"
git submodule deinit $SUBMPATH
git rm $SUBMPATH
git commit -m "Removed submodule $SUBMPATH"
rm -rf .git/modules/$SUBMPATH
git push
```

```bash
git submodule add -b branch https://urltoplugin.git path/to/submodule
git add .
git commit -m "Some update info here..."
git push
```
