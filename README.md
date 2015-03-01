# vBucket

## What is vBucket?
vBucket is an API for your files.

It's goal is to provide you with http access to a directory on your linux filesystem and any metadata you want to add.

You can GET, POST, PUT and DELETE with a simple curl command:
```
# POST a file
curl -i -F file=@funny_cat.gif http://vbucket.example.com/

# GET the file
curl http://vbucket.example.com/funny_cat.gif

# DELETE the file
curl -X DELETE http://vbucket.example.com/funny_cat.gif

#PUT a file
curl --upload-file another_cat.gif http://vbucket.example.com/another_cat.gif
```

## vBucket vs.
### object storage
Object storage stores data as objects with metadata, identified by a uuid. An API is employed to access the objects.

vBucket is a REST API for a block storage filesystem. It has all the power of an object storage API without
the need for the underlying object storage hardware.

### webdav
WebDAV(Web Distributed Authoring and Versioning) is a unique protocol with many features for reading and writing documents.

vBucket uses HTTP for all it's communication, providing maximum accessibility to any language or system. POST, PUT, GET, and DELETE are the only methods you need to know.

### nfs
NFS(Network File System) is a distributed, open filesystem protocol that you would mount and treat like a local disk.
It is extremely valuable if you need complete control over the files and their heirarchy.

vBucket runs over HTTP, so there is no mounting or special ports to open. It works through firewalls, proxies, and NAT.

### iscsi
iSCSI(Internet Small Computer System Interface) is an IP protocol for sending SCSI commands over the network. You can do everything from mount a disk to boot from iSCSI. It is an extremely powerful storage bus.

vBucket is very lightweight and easy to install. The only requirements to get started are Linux and Ruby.

## Security
vBucket does not come with an encryption or authentication mechanism. If you plan on running vBucket over the Internet, its very simple to host behind Apache or Nginx. These web servers can provide basic authentication, SSL, reverse proxy.

## Applications

### File Server
At it's core, vBucket is designed to serve up files. If you want to host files that are accessible via REST API, you can simply run vBucket as a service and point it at a directory on your linux system. You can upload and download files over HTTP with a multitude of languages, libraries and tools.

### YUM/APT Repo
vBucket can serve as a repo for linux packages. GET requests from `yum` or `apt-get` to the API are easy for vBucket.

You can also publish new packages to your repo by doing a POST or PUT. vBucket can be configured with a `post_upload` script to run repo indexing commands after an upload has completed.

### Gem Server
In addition to Linux repos, you can also serve gems from vBucket. Simply use the `post_upload` in the configuration to perform a `gem generate_index` on your vBucket directory.

### Container Repo
There is a lot of movement in this area right now and containers are all the rage. As container repos become more standardized, it should be possible to host containers much like RPMs in a yum server. Upload your container and any metadata, and rebuild the index with a `post_upload` script.

### Vagrant Box Repo
Hate storing your base Vagrant boxes in Dropbox? I do. vBucket is a great way to keep them organized and accessible.
