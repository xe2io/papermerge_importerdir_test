# Papermerge Importer Dir Test
This repo sets up the environment to test the [Papermerge][1] [Importer Directory][2] functionality.
It is prompted by a [discussion][3] on papermerge project.

  [1]: https://github.com/ciur/papermerge
  [2]: https://papermerge.readthedocs.io/en/v1.4.0/consumption.html#the-importer-directory
  [3]: https://github.com/ciur/papermerge/discussions/464

## Test Environment
The scenario in the original discussion is running in a Synology NAS environment, which is not replicated here.
The startup script creates the `config`, `data`, and `watchdir` directories if they do not exist and changes user/group ownership (1000 by default) for volume mounts.
  
After running the container to set up the sqlite database and initial config, the container needs to be stopped so the `IMPORT_DIR` value can be set in `config/papermerge.conf.py`[^1]:
```
IMPORTER_DIR = "/consume"
```
  
If this is configured properly, the logs should not have the following complaint about `IMPORTER_DIR` not being defined (before the imap/mail consumer):
```
[2022-08-04 04:52:41,865: WARNING/MainProcess] Importer from local folder task not started.Reason:
1. IMPORTER_DIR not configured
2. importer dir does not exist

[2022-08-04 04:52:41,865: WARNING/MainProcess] Importer from imap account not started.Reason:
PAPERMERGE_IMPORT_MAIL_USER not defined
PAPERMERGE_IMPORT_MAIL_HOST not defined
```

The logs should also show a `import_from_local_folder` job being dispatched to a worker:
```
[2022-08-04 04:58:46,644: INFO/Beat] Scheduler: Sending due task import_from_local_folder (papermerge.core.management.commands.worker.import_from_local_folder)
[2022-08-04 04:58:46,647: INFO/MainProcess] Task papermerge.core.management.commands.worker.import_from_local_folder[740da318-b1dc-4892-8efb-02e75602403a] received
[2022-08-04 04:58:46,648: DEBUG/ForkPoolWorker-2] Celery beat: import_from_local_folder
[2022-08-04 04:58:46,649: INFO/ForkPoolWorker-2] Task papermerge.core.management.commands.worker.import_from_local_folder[740da318-b1dc-4892-8efb-02e75602403a] succeeded in 0.0012208240004838444s: None
```

## Notes
A sample receipt pdf may used to test the import: https://eforms.com/download/2019/01/Receipt-Template.pdf  
The container logs should show the file being processed, as well as OCR start/stop messages in the admin logs.  

If uid/gid mapping is being used (e.g. for podman or rootless Docker), the papermerge worker process may not have permissions to move the file.
If this is the case, the file will remain in the watch directory and a copy imported each time the worker runs[^2].
Note that the imported documents will [only appear in the superuser's (first user) inbox](https://papermerge.readthedocs.io/en/v2.0.1/consumption.html#the-importer-directory).  

---
[^1]: The linuxserver/papermerge and the official papermerge images [both](https://github.com/linuxserver/docker-papermerge/blob/master/root/etc/cont-init.d/50-config#L19-L21) [copy](https://github.com/ciur/papermerge/blob/master/docker/app.startup.sh#L7-L9) the default papermerge.conf.py file to the app config folder if they do not already exist.  I think this is bypassing the Configula and other mechanisms of configuration during initial setup.  Will open an issue/PR when I have the time.

[^2]: At least it will be _really_ obvious that the importer is working :P
