## System Model Proposal

### Major Points

#### System Model != Power Proxy Config

While the system model contains configuration data, the system model
is not a configuration item for any one perticular component.  It is
simply a declaritive document that states a repose deployment.

Thus

````xml
<system xmlns="http://docs.openrepose.org/repose/system-model/v1.1">
   ....
</system>
````

Instead of

````xml
<power-proxy xmlns="http://docs.openrepose.org/repose/system-model/v1.1">
   ....
</power-proxy>
````

Multiple components (like the power proxy and the versioning filter)
may extract data from the model in order to configure themselves.


### Repo Contents

Sample models are in:

````
samples/*.xml
````

PDFs are available so you can get an idea of how the connections
work.  The original samples supplied in the previous proposal are in

````
samples/power-proxy/orig/*.xml
````

For comparisons the sample models are translated to the previous format
in

````
samples/power-proxy/translated/*.xml
````

You can translate a model to the previous format with the supplied XSL

````
xsltproc xsl/sys2pp.xsl samples/complex.xml > out.xml
````

You can produce dot files to visualize what's going on with a different
XSL (the graphs are a little rough, though)

````
xsltproc xsl/sys2dot.xsl samples/complex.xml > out.dot
````

You can use graphviz to see the file.
