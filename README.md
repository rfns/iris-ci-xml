## IRIS CI for XML generation

This is an add-on repository that includes classes required to generate a XML.

## Dependencies

* [IRIS-CI](https://github.com/rfns/iris-ci) it's required for runtime.
* [Port](https://github.com/rfns/port) (automatically downloaded by the installer provided on this repo). It's used for importing all the sources
from `/opt/ci/app`

## Usage

Same usage as of [IRIS-CI](https://github.com/rfns/iris-ci) but there's a few envs that can be used to control how Port should behave.
Clone this repo and overwrite the volumes that point to:

* `/opt/ci/App/Installer.cls`
* `/opt/ci/Runner.cls`

To modify the charset used for I/O:

* `PORT_CONFIGURATION_INPUT_CHARSET` to provide which encoding to use when importing the routine/file.
* `PORT_CONFIGURATION_OUTPUT_CHARSET` to provide which encoding to use when exporting the routine/file.

Syntax: 

`extensionA:encodingA;extensionB:encodingB` where `;` is used to separate each extension. Encoding refers to `RAW` or `UTF8`.

To modify the log verbosity:

* `PORT_CONFIGURATION_LOGLEVEL` to increase the level. From 1 to 2. Defaults to 1.

To modify the project name:

* `PORT_CONFIGURATION_PROJECTNAME` this will modify the name used by the xml and the project itself.
