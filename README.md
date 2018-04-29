# NuvuCameras

[![Build Status](https://travis-ci.org/emmt/NuvuCameras.jl.svg?branch=master)](https://travis-ci.org/emmt/NuvuCameras.jl)

[![Coverage Status](https://coveralls.io/repos/emmt/NuvuCameras.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/emmt/NuvuCameras.jl?branch=master)

[![codecov.io](http://codecov.io/github/emmt/NuvuCameras.jl/coverage.svg?branch=master)](http://codecov.io/github/emmt/NuvuCameras.jl?branch=master)

This module implements Julia support for Nüvü Camēras.

Examples can be find in the [`examples`](examples/) directory.


## Low-level API

The low-level API provides methods defined to directly call the C functions
of the Nüvü Camēras SDK.  There are however some simplifications to make
them easy to use:

* As all C functions of the Nüvü Camēras SDK, this status is used to assert
  the success of the call.  In case of failure, a `NuvuCameraError`
  exception is thrown which contains the symbolic name of the SDK function
  called and the value of the returned code.

* The low level interface is in a `NC` module which exports nothing, so all
  references to methods, constants, *etc.* of this module have to be prefixed
  by `NC.`.  For this reason, the prefixes `nc` (for functions), `Nc` (for some
  types) or `NC_` (for some constants) used in the C API have been stripped.
  To preserve compacity and readability, low level methods use
  [*camelCase*](https://en.wikipedia.org/wiki/Camel_case) style (with a leading
  lower case letter for methods) even though it is not the style in vogue in
  Julia.

* Pointers to opaque structures have a distinct signature so as to dispatch the
  calls to the correct C functions of the Nüvü Camēras SDK without the needs to
  have a specific prefix.  Prefixes like `ncSomeType...` are therefore
  suppressed and the first letter is converted to a lower case.  For instance
  `NC.close(arg)` manage to call `ncCamClose`, `ncProcClose`, or ...  depending
  on the type of its argument.

* When the shortned method name and its signature may be ambiguous, the type of
  the returned value is requested as the (usually) first argument.  For
  instance, `ncCamOpen(unit,channel,nbufs,camptr)` becomes
  `NC.open(NC.Cam,unit,channel,nbufs)` because `NC.Cam` is the type of the
  opaque handle for a Nüvü camera.

* Thanks to the ability of Julia methods to return several values, C
  functions taking references of one or more returned values are wrapped so
  as to return these values.

For code conversion or finding the relevant documentation, the C functions
and corresponding Julia methods are listed [here](doc/conversion.md).


### Restrictions

Only non-deprecated and thread-safe functions of the SDK are interfaced.
