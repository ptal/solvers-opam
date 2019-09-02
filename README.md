# solvers-opam

OPAM packages repository for combinatorial solvers (such as constraint programming and SAT solving) and associated tools (such as benchmarking and data sets).


To install packages from this repository, use the following command:

```
opam repo add solvers git@github.com:ptal/solvers-opam.git
```

## Update your project

Projects in this repository follow [semantic versioning](http://semver.org/) rules.
We provide a script to automatically update the version of your OPAM project, create the tag on git, add the new version in this repository, and push all the changes online.
It can be used as follows:

```sh
./package.sh major ../AbSolute .
```

Have a look to [package.sh](https://github.com/ptal/solvers-opam/blob/master/package.sh) for more documentation.

## License

(This section is taken from [opam-repository](https://github.com/ocaml/opam-repository))

All the metadata contained in this repository are licensed under the
[CC0 1.0 Universal](http://creativecommons.org/publicdomain/zero/1.0/)
license.

Moreover, as the collection of the metadata in this repository is
technically a "Database" -- which is subject to a "sui generis" right
in Europe -- we would like to stress that even the *collection* of
the metadata contained in solvers-opam is licensed under CC0 and
thus the simple act of cloning solvers-opam is perfectly legal.
