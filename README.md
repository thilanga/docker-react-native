# Disclaimer

This is a fork from [gilesp's react_native](https://github.com/gilesp/docker/tree/master/react_native).

# Usage

## Get image

Usual clone and image install:
```
> git clone https://github.com/thilanga/docker-react-native
> cd docker-react-native

> docker build -t react-native .
```

Next you will need to have the two scripts available in your path. For example you can edit your `.bashrc` and add:
```
export PATH="$HOME/docker-react-native:$PATH"
```

## Create a project

create the project.
```
> git clone https://github.com/thilanga/react-native-firebase MyAwesomeProject
```

Connect to container and install missing packages
```
> ./react-native-container.sh

dev> cd MyAwesomeProject
dev> cd node_modules/react-native/
dev> yarn
```

## Run project

Inside container:
```
dev> adb reverse tcp:8081 tcp:8081 # you'll need android > 5.1 for this
dev> react-native start > react-start.log 2>&1 &
dev> react-native run-android
```

### Hot reload

```
dev> watchman watch .
```


To enable it on your phone,
shake it, and select `Enable Hot Reloading`.
You will also need to access `Dev Settings > Debug server host & port for device`
and enter `localhost:8081`.

# Install udev rules

On your host system, you'll need to install the android udev rules if you want to connect your phone or tablet via USB and deploy the react native app directly to it. You can get the rules from http://source.android.com/source/51-android.rules and you can install them as follows:

```
wget -S -O - http://source.android.com/source/51-android.rules | sed "s/<username>/$USER/" | sudo tee >/dev/null /etc/udev/rules.d/51-android.rules
sudo udevadm control --reload-rules
```
