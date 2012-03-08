## Repose System Model Proposal

## Major Benfits over Service Domain Model

1. All possible connections stored in a single XML document.  The service model method stores end points
   in the configuration of individual routing componets.  That means in order to get a complete view of
   how things are connected -- you have to parse multiple files.  With *this* model there's a single document
   where you can see/edit all connections.

2. Services are in *this* model are addressed via full URIs.  The alternative Service domain model only sees
   services as a host and a port.  This shuts down a lot of possibilites for repose.

3. There's an indication of what connection are exposed to outside and which should remain internal (via the start attribute)
   this is important when setting up security zones.
   
4. Node boundries are explicitly expressed -- that means you can tell when a repose service is not accessible
   from the outside. And you can explicitly tell how things scale horizontally.

5. Shields Repose specific implementation details -- you don't have to know that you have to use one dispatcher for
   a local call and aother for a remote one -- it turns out that the dispatcher may change from one version of the
   product to another.

### Other Important Points

#### System Model != Power Proxy Config

While the system model contains configuration data, the system model
is not a configuration item for any one particular component.  It is
simply a declarative document that controls a repose deployment.

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
where, and what the connections are between various components.  What
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
computer to parse....end of the day the complexity in parsing the
config can be coded once an is negligible compared to how often humans
will interact with the file.

#### Should generate an image

It should be possible to generate an overview image of a particular
deployment directly from the  model.  There's a
transformation from the proposed model to dot format to illustrate
this point here...

````
xsl/sys2dot.xsl
````

### Other Notes

Take the entity names in the model with a grain of salt...I'm not
entirely married to them.  It's important that the concepts make it to
the final file though.

### Repo Contents

Sample models are in:

````
samples/*.xml
````

PDFs are available so you can get an idea of how the connections
work.

Examples of the alternate model are in

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
