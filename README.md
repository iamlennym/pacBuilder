# pacBuilder
Small utility to help construct pac files from freeform input

## Steps Required ##

* Clone the repository onto your Mac / Linux machine (e.g. `git clone https://github.com/iamlennym/pacBuilder.git`).
* Build the `pacbuilder` docker image:
    - Execute the following commands:
        - `./build.sh` (builds a local docker image for `pacbuilder`)
        - `docker images` (Lists local images. Be sure that `pacbuilder` is in the list)

            Example output:
            ```
            REPOSITORY          TAG               IMAGE ID       CREATED         SIZE
            pacbuilder          latest            eae9adabc5d8   7 minutes ago      116MB
            ```
* Add the `pacBuilder.sh` script to your PATH.
  * Although you can execute the script from the build directory directly, it is convenient to also add the path to the script to your environment's PATH.


## Example Usage ##

* The `pacBuilder` usage screen is displayed when no parameters are specified:

```
            Usage:

                /pacBuilder/src/pacbuilder.pl <Input file>

```


* The scaffolded pac file will be printed to STDOUT. 
* Create a pac file from the `sample.txt` input file:
  ```
  ./pacBuilder.sh sample.txt
  ```

* Re-direct STDOUT to a file to store the pac file to disk.
  ```
  ./pacBuilder.sh sample.txt > sample.pac
  ```


## PAC file Template ##

* pacBuilder uses the `custom_template.pac` file to construct the new pac files.
* You are welcome to chop and change this file according to your needs.
* The following lines should always be present (pacBuilder will replace these with the values derived from the input file):

```
    // IP Range exclusions
	// XXX_IP_RANGE_EXCLUSIONS_XXX

	// Individual IP exclusions
	// XXX_INDIVIDUAL_IP_EXCLUSIONS_XXX

    
	//  Specific destinations can be bypassed here.
	//	Also bypass plain host names (without domain).
	//	Also possible to match direct host and domain like this : (host == "host.example.com") ||
	// XXX_DOMAIN_HOST_EXCLUSIONS_XXX
```