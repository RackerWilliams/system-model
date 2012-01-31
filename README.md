## System Model Proposal

### Major Points

#### System Model != Power Proxy Config

While the system model contains configuration data, the system model
is not a configuration item for any one perticular component.  It is
simply a declaritive document that controls a repose deployment.

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

#### The system model contains...

...an indication of how Repose is deployed, what filters are used
where, and what the connections are between varius componets.  What
are the allowed communications paths?  The latter is of particular
importance especially as we develop the concept of security zones in
repose.

#### The system model is an interface

As with any interface it provides a level of abstraction.  It must
shield the operator from implementation details.  For example, the
fact that servlet-context-router filter is needed to dispatch within a
local context is an implementation detail that *may* change.

The more we treat the model like a general interface, the less likely
it has to change as the product matures.

#### We are not optimizing for ease parsing

When we have a choice we want to reduce the number of changes that
will come to the model over time...and we want the model to be
readable. Easy for a human to read is a better goal than easy for a
computer to pase....end of the day the complexity in parsing the
config can be coded once an is neglageble compared to how often humans
will interact with the file.

#### Transformation is not a bad thing

The power-proxy needs some info from the system model, the versioning
component may need a collection of possible destinations, etc. Being
able to translate the model to extract relevent data by each component
is not a bad stradegy.

#### Should generate an image

It should be possible to generate an overview image of a particular
deployment from all of the data in the model.  There's a
transformation from the proposed model to dot format to illustrate
this point here...

````
xsl/sys2dot.xsl
````

### Other Notes

Take the entity names in the model witha grain of salt...I'm not
entirely marrid to them.  It's important that the concepts make it to
the final file.

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
