# mts-trial-deployment-config

This repository holds MTS resources definitions (shared and per trial) and CONTROLS the actual cloud deployment.

## Using this repository

### Creating a new trial
Copy the sample_trial directory into a new directory with a meaningful name. (e.g. trial987drugX) (Name cannot be longer than 19 characters).
Modify the definition file (.json), this will control the actual trial and initial settings. Make sure to provide correct values, such as the right docker image and correct first practitioner.
Note: you must choose a UNIQUE id for this trial, so it won't conflict with another trial

commit the changes, push and create a PR. Once approved the new trial will be created.

Multiple trials can be added together.

### Updating an existing trial

Go to the directory of the wanted trial and change any paramater except the id.

commit the changes, push and create a PR. Once approved the trial will be updated.

### Deleting a trial

Go to the directory of the wanted trial.

Copy paste the following json snippet into the definition file.
Update with the correct name and id.

```json
{
    "name": "sampletrial",
    "id": "sample1",
    "delete": true
}
```

commit the changes, push and create a PR. Once approved the trial will be deleted.
// TODO: this is not implemented yet.

Once the resource group (trial) was deleted go ahead and remove the actual definition file from the repository (if you wish to).
