The docs for the SDK imply that the customer should get their app to listen to a specific {{unidays-sdk}} URL scheme. This needs to be configurable, since multiple apps that employ the SDK may be installed on one device, and would therefore contend.

The scheme should be configured as part of initing the SDK, and the docs updated to reflect this. The Cordova app and web fallback will work with this provided the callback URLs sent in x-success and x-error have the custom scheme.
