# Running local in Docker
This file contains instructions for running the labeltool within a Docker instance connected to a local MongoDB. We assume the [Hitachi Labeltool repo](https://github.com/Hitachi-Automotive-And-Industry-Lab/semantic-segmentation-editor) is cloned into `$LABELTOOL_DIR`:
``` bash
export LABELTOOL_DIR=semantic-segmentation-editor-test
git clone https://github.com/Hitachi-Automotive-And-Industry-Lab/semantic-segmentation-editor $LABELTOOL_DIR
```

## Add Docker files
Two files are needed to run the labeltool with Docker:
- `Dockerfile`: This file contains the script to create the Docker container with the labeltool. If you build and run this, the MongoDB will be running within the container and any data will be lost on rebuild if not saved!
- `docker-compose.yml`: This file contains the configuration of the Labeltool-Docker with an external MongoDB.

Copy the templates into the labeltool directory:
``` bash
cp Dockerfile docker-compose.yml $LABELTOOL_DIR
```

## Setup local MongoDB instance
**1) Edit configuration in mongod.conf**
Main parameters:
-  `storage.dbPath`: local MongoDB storage path
-  `systemLog.path`: local logging path to check if everything runs fine (e.g. use `tail -f mongod.log`)
-  `net.port`: port on which the MongoDB instance runs, useful if you have multiple instances running in parallel
-  `security.authorization`: set this to `enabled` for authentication with user/password

**2) Start MongoDB instance with local conf**
If the DB directory as defined in the `mongod.conf` does not exist, create it with e.g. `mkdir mongodb-local`!
``` bash
/usr/bin/mongod --config mongod.conf &
```

**3) add user to local db ([official manual](https://docs.mongodb.com/manual/tutorial/enable-authentication/#create-the-user-administrator))**
Choose credentials as you like, but alter the `MONGO_URL` entry in `$LABELTOOL_DIR/docker-compose.yml` accordingly.
``` bash
mongo
use admin;
db.createUser(
{
user: "user",
pwd: "password",
roles: [ { role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase" ]
}
);
exit;
```
**4) Restart MongoDB instance with local conf**
Kill and restart `mongod` (find process with `ps aux | grep /usr/bin/mongod`). Make sure, authenticaton is enabled in `mongod.conf`:
```
security:
  authorization: enabled
```
Restart with authentication:
``` bash
/usr/bin/mongod --config mongod.conf --auth &
```

## Add data folders
Prepare directories as defined in the `volumes` mapping of `$LABELTOOL_DIR/docker-compose.yml`:
``` bash
mkdir -p $LABELTOOL_DIR/docker_data/input_img $LABELTOOL_DIR/docker_data/output_img
```

## Add settings.json
Backup the old settings file and add the provided one (`settings.json`). It contains the relevant class set for the provided sample image (`sample.png`).
``` bash
mv $LABELTOOL_DIR/settings.json $LABELTOOL_DIR/settings.json.bak
cp settings.json $LABELTOOL_DIR
```

## Import sample data (optional)
Copy the sample file (`sample.png`) to the data folder:
``` bash
mkdir -p $LABELTOOL_DIR/docker_data/input_img/test && cp sample.png $LABELTOOL_DIR/docker_data/input_img/test
```
Import the sample data (`sample.json`) to the MongoDB either with a GUI Tool like [MongoDB Compass](https://www.mongodb.com/products/compass) or via the console:
``` bash
mongoimport -v --db labeltool-local --collection SseSamples --file sample.json -u user -p password --authenticationDatabase admin
```
Make sure the db name ist the same as defined in your `MONGO_URL` (in `$LABELTOOL_DIR/docker-compose.yml`) and the credentials match your user!

## Start labeltool
Run the command `docker-compose -f $LABELTOOL_DIR/docker-compose.yml up` to build and start the docker. If you need to change anything and changes do not reflect it might help to rebuild with `docker-compose -f $LABELTOOL_DIR/docker-compose.yml up --build --force-recreate`. Please be patient, builds take quite some time (around 5-10min on my PC).
