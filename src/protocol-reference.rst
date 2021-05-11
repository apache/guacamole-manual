Guacamole protocol reference
============================

Drawing instructions
--------------------

.. _arc-instruction:

arc
~~~

The arc instruction adds the specified arc subpath to the existing path,
creating a new path if no path exists. The path created can be modified
further by other path-type instructions, and finally stroked, filled,
and/or closed.

``layer``
   The layer which should have the specified arc subpath added.

``x``
   The X coordinate of the center of the circle containing the arc to be
   drawn.

``y``
   The Y coordinate of the center of the circle containing the arc to be
   drawn.

``radius``
   The radius of the circle containing the arc to be drawn, in pixels.

``start``
   The starting angle of the arc to be drawn, in radians.

``end``
   The ending angle of the arc to be drawn, in radians.

``negative``
   Non-zero if the arc should be drawn from START to END in order of
   decreasing angle, zero otherwise.

.. _cfill-instruction:

cfill
~~~~~

Fills the current path with the specified color. This instruction
completes the current path. Future path instructions will begin a new
path.

``mask``
   The channel mask to apply when filling the current path in the
   specified layer.

``layer``
   The layer whose path should be filled.

``r``
   The red component of the color to use to fill the current path in the
   specified layer.

``g``
   The green component of the color to use to fill the current path in
   the specified layer.

``b``
   The blue component of the color to use to fill the current path in
   the specified layer.

``a``
   The alpha component of the color to use to fill the current path in
   the specified layer.

.. _clip-instruction:

clip
~~~~

Applies the current path as the clipping path. Future operations will
only draw within the current path. Note that future clip instructions
will also be limited by this path. To set a completely new clipping
path, you must first reset the layer with a reset instruction. If you
wish to only reset the clipping path, but preserve the current transform
matrix, push the layer state before setting the clipping path, and pop
the layer state to reset.

``layer``
   The layer whose clipping path should be set.

.. _close-instruction:

close
~~~~~

Closes the current path by connecting the start and end points with a
straight line.

``layer``
   The layer whose path should be closed.

.. _copy-instruction:

copy
~~~~

Copies image data from the specified rectangle of the specified layer or
buffer to a different location of another specified layer or buffer.

``srclayer``
   The index of the layer to copy image data from.

``srcx``
   The X coordinate of the upper-left corner of the source rectangle
   within the source layer.

``srcy``
   The Y coordinate of the upper-left corner of the source rectangle
   within the source layer.

``srcwidth``
   The width of the source rectangle within the source layer.

``srcheight``
   The height of the source rectangle within the source layer.

``mask``
   The channel mask to apply when drawing the image data on the
   destination layer.

``dstlayer``
   The index of the layer to draw the image data to.

``dstx``
   The X coordinate of the upper-left corner of the destination within
   the destination layer.

``dsty``
   The Y coordinate of the upper-left corner of the destination within
   the destination layer.

.. _cstroke-instruction:

cstroke
~~~~~~~

Strokes the current path with the specified color. This instruction
completes the current path. Future path instructions will begin a new
path.

``mask``
   The channel mask to apply when stroking the current path in the
   specified layer.

``layer``
   The layer whose path should be stroked.

``cap``
   The index of the line cap style to use. This can be either butt (0),
   round (1), or square (2).

``join``
   The index of the line join style to use. This can be either bevel
   (0), miter (1), or round (2).

``thickness``
   The thickness of the stroke to draw, in pixels.

``r``
   The red component of the color to use to stroke the current path in
   the specified layer.

``g``
   The green component of the color to use to stroke the current path in
   the specified layer.

``b``
   The blue component of the color to use to stroke the current path in
   the specified layer.

``a``
   The alpha component of the color to use to stroke the current path in
   the specified layer.

.. _cursor-instruction:

cursor
~~~~~~

Sets the client's cursor to the image data from the specified rectangle
of a layer, with the specified hotspot.

``x``
   The X coordinate of the cursor's hotspot.

``y``
   The Y coordinate of the cursor's hotspot.

``srclayer``
   The index of the layer to copy image data from.

``srcx``
   The X coordinate of the upper-left corner of the source rectangle
   within the source layer.

``srcy``
   The Y coordinate of the upper-left corner of the source rectangle
   within the source layer.

``srcwidth``
   The width of the source rectangle within the source layer.

``srcheight``
   The height of the source rectangle within the source layer.

.. _curve-instruction:

curve
~~~~~

Adds the specified cubic bezier curve subpath.

``layer``
   The layer which should have the specified curve subpath added.

``cp1x``
   The X coordinate of the first control point of the curve.

``cp1y``
   The Y coordinate of the first control point of the curve.

``cp2x``
   The X coordinate of the second control point of the curve.

``cp2y``
   The Y coordinate of the second control point of the curve.

``x``
   The X coordinate of the endpoint of the curve.

``y``
   The Y coordinate of the endpoint of the curve.

.. _dispose-instruction:

dispose
~~~~~~~

Removes the specified layer. The specified layer will be recreated as a
new layer if it is referenced again.

``layer``
   The layer to remove.

.. _distort-instruction:

distort
~~~~~~~

Sets the given affine transformation matrix to the layer. Unlike
transform, this operation is independent of any previously sent
transformation matrix. This operation can be undone by setting the
layer's transformation matrix to the identity matrix using distort

``layer``
   The layer to distort.

``a``
   The matrix value in row 1, column 1.

``b``
   The matrix value in row 2, column 1.

``c``
   The matrix value in row 1, column 2.

``d``
   The matrix value in row 2, column 2.

``e``
   The matrix value in row 1, column 3.

``f``
   The matrix value in row 2, column 3.

.. _identity-instruction:

identity
~~~~~~~~

Resets the transform matrix of the specified layer to the identity
matrix.

``layer``
   The layer whose transform matrix should be reset.

.. _lfill-instruction:

lfill
~~~~~

Fills the current path with a tiled pattern of the image data from the
specified layer. This instruction completes the current path. Future
path instructions will begin a new path.

``mask``
   The channel mask to apply when filling the current path in the
   specified layer.

``layer``
   The layer whose path should be filled.

``srclayer``
   The layer to use as the pattern.

.. _line-instruction:

line
~~~~

Adds the specified line subpath.

``layer``
   The layer which should have the specified line subpath added.

``x``
   The X coordinate of the endpoint of the line.

``y``
   The Y coordinate of the endpoint of the line.

.. _lstroke-instruction:

lstroke
~~~~~~~

Strokes the current path with a tiled pattern of the image data from the
specified layer. This instruction completes the current path. Future
path instructions will begin a new path.

``mask``
   The channel mask to apply when filling the current path in the
   specified layer.

``layer``
   The layer whose path should be filled.

``cap``
   The index of the line cap style to use. This can be either butt (0),
   round (1), or square (2).

``join``
   The index of the line join style to use. This can be either bevel
   (0), miter (1), or round (2).

``thickness``
   The thickness of the stroke to draw, in pixels.

``srclayer``
   The layer to use as the pattern.

.. _move-instruction:

move
~~~~

Moves the given layer to the given location within the specified parent
layer. This operation is applicable only to layers, and cannot be
applied to buffers (layers with negative indices). Applying this
operation to the default layer (layer 0) also has no effect.

``layer``
   The layer to move.

``parent``
   The layer that should be the parent of the given layer.

``x``
   The X coordinate to move the layer to.

``y``
   The Y coordinate to move the layer to.

``z``
   The relative Z-ordering of this layer. Layers with larger values will
   appear above layers with smaller values.

.. _pop-instruction:

pop
~~~

Restores the previous state of the specified layer from the stack. The
state restored includes the transformation matrix and clipping path.

``layer``
   The layer whose state should be restored.

.. _push-instruction:

push
~~~~

Saves the current state of the specified layer to the stack. The state
saved includes the current transformation matrix and clipping path.

``layer``
   The layer whose state should be saved.

.. _rect-instruction:

rect
~~~~

Adds a rectangular path to the specified layer.

``mask``
   The channel mask to apply when drawing the image data.

``layer``
   The destination layer.

``x``
   The X coordinate of the upper-left corner of the rectangle to draw.

``y``
   The Y coordinate of the upper-left corner of the rectangle to draw.

``width``
   The width of the rectangle to draw.

``height``
   The width of the rectangle to draw.

.. _reset-instruction:

reset
~~~~~

Resets the transformation and clip state of the layer.

``layer``
   The layer whose state should be reset.

.. _set-instruction:

set
~~~

Sets the given client-side property to the specified value. Currently
there is only one property: miter-limit, the maximum distance between
the inner and outer points of a miter joint, proportional to stroke
width (if miter-limit is set to 10.0, the default, then the maximum
distance between the points of the joint is 10 times the stroke width).

``layer``
   The layer whose property should be set.

``property``
   The name of the property to set.

``value``
   The value to set the given property to.

.. _shade-instruction:

shade
~~~~~

Sets the opacity of the given layer.

``layer``
   The layer whose opacity should be set.

``opacity``
   The opacity of the layer, where 0 is completely transparent, and 255
   is completely opaque.

.. _size-instruction:

size
~~~~

Sets the size of the specified layer.

``layer``
   The layer to resize.

``width``
   The new width of the layer

``height``
   The new height of the layer

.. _start-instruction:

start
~~~~~

Starts a new subpath at the specified point.

``layer``
   The layer which should start a new subpath.

``x``
   The X coordinate of the first point of the new subpath.

``y``
   The Y coordinate of the first point of the new subpath.

.. _transfer-instruction:

transfer
~~~~~~~~

Transfers image data from the specified rectangle of the specified layer
or buffer to a different location of another specified layer or buffer,
using the specified transfer function.

For a list of available functions, see the definition of
``guac_transfer_function`` within the
```guacamole/protocol-types.h`` <https://github.com/apache/guacamole-server/blob/master/src/libguac/guacamole/protocol-types.h>`__
header included with libguac.

``srclayer``
   The index of the layer to transfer image data from.

``srcx``
   The X coordinate of the upper-left corner of the source rectangle
   within the source layer.

``srcy``
   The Y coordinate of the upper-left corner of the source rectangle
   within the source layer.

``srcwidth``
   The width of the source rectangle within the source layer.

``srcheight``
   The height of the source rectangle within the source layer.

``function``
   The index of the transfer function to use.

   For a list of available functions, see the definition of
   ``guac_transfer_function`` within the
   ```guacamole/protocol-types.h`` <https://github.com/apache/guacamole-server/blob/master/src/libguac/guacamole/protocol-types.h>`__
   header included with libguac.

``dstlayer``
   The index of the layer to draw the image data to.

``dstx``
   The X coordinate of the upper-left corner of the destination within
   the destination layer.

``dsty``
   The Y coordinate of the upper-left corner of the destination within
   the destination layer.

.. _transform-instruction:

transform
~~~~~~~~~

Applies the specified transformation matrix to future operations. Unlike
distort, this operation is dependent on any previously sent
transformation matrices, and only affects future operations. This
operation can be undone by setting the layer's transformation matrix to
the identity matrix using identity, but image data already drawn will
not be affected.

``layer``
   The layer to apply the given transformation matrix to.

``a``
   The matrix value in row 1, column 1.

``b``
   The matrix value in row 2, column 1.

``c``
   The matrix value in row 1, column 2.

``d``
   The matrix value in row 2, column 2.

``e``
   The matrix value in row 1, column 3.

``f``
   The matrix value in row 2, column 3.

Streaming instructions
----------------------

.. _ack-instruction:

ack
~~~

The ack instruction acknowledges a received data blob, providing a
status code and message indicating whether the operation associated with
the blob succeeded or failed. A status code other than ``SUCCESS``
implicitly ends the stream.

``stream``
   The index of the stream the corresponding blob was received on.

``message``
   A human-readable error message. This typically is not exposed within
   any user interface, and mainly helps with debugging.

``status``
   The Guacamole status code denoting success or failure.

Status codes
^^^^^^^^^^^^

Several Guacamole instructions, and various other internals of the
Guacamole core, use a common set of numeric status codes. These codes
denote success or failure of operations, and can be rendered by user
interfaces in a human-readable way.

+-----+----------------+-----------------------------------------------+
| C   | Name           | Description                                   |
| ode |                |                                               |
+=====+================+===============================================+
| 0   | ``SUCCESS``    | The operation succeeded. No error.            |
+-----+----------------+-----------------------------------------------+
| 256 | `              | The requested operation is unsupported.       |
|     | `UNSUPPORTED`` |                                               |
+-----+----------------+-----------------------------------------------+
| 512 | ``             | An internal error occurred, and the operation |
|     | SERVER_ERROR`` | could not be performed.                       |
+-----+----------------+-----------------------------------------------+
| 513 | `              | The operation could not be performed because  |
|     | `SERVER_BUSY`` | the server is busy.                           |
+-----+----------------+-----------------------------------------------+
| 514 | ``UPST         | The upstream server is not responding. In     |
|     | REAM_TIMEOUT`` | most cases, the upstream server is the remote |
|     |                | desktop server.                               |
+-----+----------------+-----------------------------------------------+
| 515 | ``UP           | The upstream server encountered an error. In  |
|     | STREAM_ERROR`` | most cases, the upstream server is the remote |
|     |                | desktop server.                               |
+-----+----------------+-----------------------------------------------+
| 516 | ``RESOUR       | An associated resource, such as a file or     |
|     | CE_NOT_FOUND`` | stream, could not be found, and thus the      |
|     |                | operation failed.                             |
+-----+----------------+-----------------------------------------------+
| 517 | ``RESOU        | A resource is already in use or locked,       |
|     | RCE_CONFLICT`` | preventing the requested operation.           |
+-----+----------------+-----------------------------------------------+
| 518 | ``RES          | The requested operation cannot continue       |
|     | OURCE_CLOSED`` | because the associated resource has been      |
|     |                | closed.                                       |
+-----+----------------+-----------------------------------------------+
| 519 | ``UPSTRE       | The upstream server does not appear to exist, |
|     | AM_NOT_FOUND`` | or cannot be reached over the network. In     |
|     |                | most cases, the upstream server is the remote |
|     |                | desktop server.                               |
+-----+----------------+-----------------------------------------------+
| 520 | ``UPSTREAM     | The upstream server is refusing to service    |
|     | _UNAVAILABLE`` | connections. In most cases, the upstream      |
|     |                | server is the remote desktop server.          |
+-----+----------------+-----------------------------------------------+
| 521 | ``SESS         | The session within the upstream server has    |
|     | ION_CONFLICT`` | ended because it conflicts with another       |
|     |                | session. In most cases, the upstream server   |
|     |                | is the remote desktop server.                 |
+-----+----------------+-----------------------------------------------+
| 522 | ``SES          | The session within the upstream server has    |
|     | SION_TIMEOUT`` | ended because it appeared to be inactive. In  |
|     |                | most cases, the upstream server is the remote |
|     |                | desktop server.                               |
+-----+----------------+-----------------------------------------------+
| 523 | ``SE           | The session within the upstream server has    |
|     | SSION_CLOSED`` | been forcibly closed. In most cases, the      |
|     |                | upstream server is the remote desktop server. |
+-----+----------------+-----------------------------------------------+
| 768 | ``CLIENT       | The parameters of the request are illegal or  |
|     | _BAD_REQUEST`` | otherwise invalid.                            |
+-----+----------------+-----------------------------------------------+
| 769 | ``CLIENT_      | Permission was denied, because the user is    |
|     | UNAUTHORIZED`` | not logged in. Note that the user may be      |
|     |                | logged into Guacamole, but still not logged   |
|     |                | in with respect to the remote desktop server. |
+-----+----------------+-----------------------------------------------+
| 771 | ``CLIE         | Permission was denied, and logging in will    |
|     | NT_FORBIDDEN`` | not solve the problem.                        |
+-----+----------------+-----------------------------------------------+
| 776 | ``CL           | The client (usually the user of Guacamole or  |
|     | IENT_TIMEOUT`` | their browser) is taking too long to respond. |
+-----+----------------+-----------------------------------------------+
| 781 | ``CL           | The client has sent more data than the        |
|     | IENT_OVERRUN`` | protocol allows.                              |
+-----+----------------+-----------------------------------------------+
| 783 | ``CLI          | The client has sent data of an unexpected or  |
|     | ENT_BAD_TYPE`` | illegal type.                                 |
+-----+----------------+-----------------------------------------------+
| 797 | ``CLI          | The client is already using too many          |
|     | ENT_TOO_MANY`` | resources. Existing resources must be freed   |
|     |                | before further requests are allowed.          |
+-----+----------------+-----------------------------------------------+

.. _argv-instruction:

argv
~~~~

Allocates a new stream, associating it with the given argument
(connection parameter) metadata. The relevant connection parameter data
will later be sent along the stream with blob instructions. If sent by
the client, this data will be the desired new value of the connection
parameter being changed, and will be applied if the server supports
changing that connection parameter while the connection is active. If
sent by the server, this data will be the current value of a connection
parameter being exposed to the client.

``stream``
   The index of the stream to allocate.

``mimetype``
   The mimetype of the connection parameter being sent. In most cases,
   this will be "text/plain".

``name``
   The name of the connection parameter whose value is being sent.

.. _audio-stream-instruction:

audio
~~~~~

Allocates a new stream, associating it with the given audio metadata.
Audio data will later be sent along the stream with blob instructions.
The mimetype given must be a mimetype previously specified by the client
during the handshake procedure. Playback will begin immediately and will
continue as long as blobs are received along the stream.

``stream``
   The index of the stream to allocate.

``mimetype``
   The mimetype of the audio data being sent.

.. _blob-instruction:

blob
~~~~

Sends a blob of data along the given stream. This blob of data is
arbitrary, base64-encoded data, and only has meaning to the Guacamole
client or server through the metadata assigned to the stream when the
stream was allocated.

``stream``
   The index of the stream along which the given data should be sent.

``data``
   The base64-encoded data to send.

.. _clipboard-instruction:

clipboard
~~~~~~~~~

Allocates a new stream, associating it with the given clipboard
metadata. The clipboard data will later be sent along the stream with
blob instructions. If sent by the client, this data will be the contents
of the client-side clipboard. If sent by the server, this data will be
the contents of the clipboard within the remote desktop.

``stream``
   The index of the stream to allocate.

``mimetype``
   The mimetype of the clipboard data being sent. In most cases, this
   will be "text/plain".

.. _end-instruction:

end
~~~

The end instruction terminates an open stream, freeing any client-side
or server-side resources. Data sent to a terminated stream will be
ignored. Terminating a stream with the end instruction only denotes the
end of the stream and does not imply an error.

``stream``
   The index of the stream the corresponding blob was received on.

.. _file-stream-instruction:

file
~~~~

Allocates a new stream, associating it with the given arbitrary file
metadata. The contents of the file will later be sent along the stream
with blob instructions. The full size of the file need not be known
ahead of time.

``stream``
   The index of the stream to allocate.

``mimetype``
   The mimetype of the file being sent.

``filename``
   The name of the file, as it would be saved on a filesystem.

.. _img-instruction:

img
~~~

Allocates a new stream, associating it with the metadata of an image
update, including the image type, the destination layer, and destination
coordinates. The contents of the image will later be sent along the
stream with blob instructions. The full size of the image need not be
known ahead of time.

``stream``
   The index of the stream to allocate.

``mimetype``
   The mimetype of the image being sent.

``mask``
   The channel mask to apply when drawing the image data.

``layer``
   The destination layer.

``x``
   The X coordinate of the upper-left corner of the destination within
   the destination layer.

``y``
   The Y coordinate of the upper-left corner of the destination within
   the destination layer.

.. _nest-stream-instruction:

nest
~~~~

.. important::

   *The ``nest`` instruction has been deprecated.*

   The ``nest`` instruction is no longer necessary, having been replaced
   by other streaming instructions (such as
   ```blob`` <#blob-instruction>`__, ```ack`` <#ack-instruction>`__, and
   ```end`` <#end-instruction>`__). Code using the ``nest`` instruction
   should instead write instructions directly without wrapping those
   instructions within ``nest``.

Encodes part of one or more instructions within a single instruction,
associating that packet of data with a stream index. Future nest
instructions with the same stream index will append their data to the
same logical stream on the client side. Once nested data is received on
the client side, the client immediately executes any completed
instructions within the associated stream, in order.

``index``
   The index of the stream this data should be appended to. This index
   is completely arbitrary, and denotes only how nested data should be
   reassembled.

``data``
   The protocol data, containing part of one or more instructions.

.. _pipe-instruction:

pipe
~~~~

Allocates a new stream, associating it with the given arbitrary named
pipe metadata. The contents of the pipe will later be sent along the
stream with blob instructions. Pipes in the Guacamole protocol are
unidirectional, named pipes, very similar to a UNIX FIFO or pipe. It is
up to client-side code to handle pipe data appropriately, likely based
upon the name of the pipe, which is arbitrary. Pipes may be opened by
either the client or the server.

``stream``
   The index of the stream to allocate.

``mimetype``
   The mimetype of the data being sent along the pipe.

``name``
   The arbitrary name of the pipe, which may have special meaning to
   client-side code.

.. _video-stream-instruction:

video
~~~~~

Allocates a new stream, associating it with the given video metadata.
Video data will later be sent along the stream with blob instructions.
The mimetype given must be a mimetype previously specified by the client
during the handshake procedure. Playback will begin immediately and will
continue as long as blobs are received along the stream.

``stream``
   The index of the stream to allocate.

``layer``
   The index of the layer to stream the video data into. The effect of
   other drawing operations on this layer during playback is undefined,
   as the client codec implementation may leverage any rendering
   mechanism it sees fit, including hardware decoding.

``mimetype``
   The mimetype of the video data being sent.

Object instructions
-------------------

.. _body-object-instruction:

body
~~~~

Allocates a new stream, associating it with the name of a stream
previously requested by a get instruction. The contents of the stream
will be sent later with blob instructions. The full size of the stream
need not be known ahead of time.

``object``
   The index of the object associated with this stream.

``stream``
   The index of the stream to allocate.

``mimetype``
   The mimetype of the data being sent.

``name``
   The name of the stream associated with the object.

.. _filesystem-object-instruction:

filesystem
~~~~~~~~~~

Allocates a new object, associating it with the given arbitrary
filesystem metadata. The contents of files and directories within the
filesystem will later be sent along streams requested with get
instructions or created with put instructions.

``object``
   The index of the object to allocate.

``name``
   The name of the filesystem.

.. _get-object-instruction:

get
~~~

Requests that a new stream be created, providing read access to the
object stream having the given name. The requested stream will be
created, in response, with a body instruction.

Stream names are arbitrary and dictated by the object from which they
are requested, with the exception of the root stream of the object
itself, which has the reserved name "``/``". The root stream of the
object has the mimetype
"``application/vnd.glyptodon.guacamole.stream-index+json``", and
provides a simple JSON map of available stream names to their
corresponding mimetypes. If the object contains a hierarchy of streams,
some of these streams may also be
"``application/vnd.glyptodon.guacamole.stream-index+json``".

For example, the ultimate content of the body stream provided in
response to a get request for the root stream of an object containing
two text streams, "A" and "B", would be the following:

.. container:: informalexample

   ::

      {
          "A" : "text/plain",
          "B" : "text/plain"
      }

``object``
   The index of the object to request a stream from.

``name``
   The name of the stream being requested from the given object.

.. _put-object-instruction:

put
~~~

Allocates a new stream, associating it with the given arbitrary object
and stream name. The contents of the stream will later be sent with blob
instructions.

``object``
   The index of the object associated with this stream.

``stream``
   The index of the stream to allocate.

``mimetype``
   The mimetype of the data being sent.

``name``
   The name of the stream within the given object to which data is being
   sent.

.. _undefine-object-instruction:

undefine
~~~~~~~~

Undefines an existing object, allowing its index to be reused by another
future object. The resource associated with the original object may or
may not continue to exist - it simply no longer has an associated
object.

``object``
   The index of the object to undefine.

Client handshake instructions
-----------------------------

.. _audio-handshake-instruction:

audio
~~~~~

Specifies which audio mimetypes are supported by the client. Each
parameter must be a single mimetype, listed in order of client
preference, with the optimal mimetype being the first parameter.

.. _connect-instruction:

connect
~~~~~~~

Begins the connection using the previously specified protocol with the
given arguments. This is the last instruction sent during the handshake
phase.

The parameters of this instruction correspond exactly to the parameters
of the received args instruction. If the received args instruction has,
for example, three parameters, the responding connect instruction must
also have three parameters.

.. _image-handshake-instruction:

image
~~~~~

Specifies which image mimetypes are supported by the client. Each
parameter must be a single mimetype, listed in order of client
preference, with the optimal mimetype being the first parameter.

It is expected that the supported mimetypes will include at least
"image/png" and "image/jpeg", and the server *may* safely assume that
these mimetypes are supported, even if they are absent from the
handshake.

.. _select-instruction:

select
~~~~~~

Requests that the connection be made using the specified protocol, or to
the specified existing connection. Whether a new connection is
established or an existing connection is joined depends on whether the
ID of an active connection is provided. The Guacamole protocol dictates
that the IDs generated for active connections (provided during the
handshake of those connections via the `ready
instruction <#ready-instruction>`__) must not collide with any supported
protocols.

This is the first instruction sent during the handshake phase.

``ID``
   The name of the protocol to use, such as "vnc" or "rdp", or the ID of
   the active connection to be joined, as returned via the `ready
   instruction <#ready-instruction>`__.

.. _size-handshake-instruction:

size
~~~~

Specifies the client's optimal screen size and resolution.

``width``
   The optimal screen width.

``height``
   The optimal screen height.

``dpi``
   The optimal screen resolution, in approximate DPI.

.. _timezone-handshake-instruction:

timezone
~~~~~~~~

Specifies the timezone of the client system, in IANA zone key format.
This is a single-value parameter, and may be used by protocols to set
the timezone on the remote computer, if the remote system allows the
timezone to be configured. This instruction is optional.

``timezone``

.. _video-handshake-instruction:

video
~~~~~

Specifies which video mimetypes are supported by the client. Each
parameter must be a single mimetype, listed in order of client
preference, with the optimal mimetype being the first parameter.

Server handshake instructions
-----------------------------

.. _args-instruction:

args
~~~~

Reports the expected format of the argument list for the protocol
requested by the client. This message can be sent by the server during
the handshake phase only.

The first parameter of this instruction will be the protocol version
supported by the server. This is used to negotiate protocol
compatibility between the client and the server, with the highest
supported protocol by both sides being chosen. Versions of Guacamole
prior to 1.1.0 do not support protocol version negotiation, and will
silently ignore this instruction.

The remaining parameters of the args instruction are the names of all
connection parameters accepted by the server for the protocol selected
by the client, in order. The client's responding connect instruction
must contain the values of each of these parameters in the same order.

Client control instructions
---------------------------

.. _client-disconnect-instruction:

disconnect
~~~~~~~~~~

Notifies the server that the connection is about to be closed by the
client. This message can be sent by the client during any phase, and
takes no parameters.

.. _client-nop-instruction:

nop
~~~

The client "nop" instruction does absolutely nothing, has no parameters,
and is universally ignored by the Guacamole server. Its main use is as a
keep-alive signal, and may be sent by Guacamole clients when there is no
activity to ensure the socket is not closed due to timeout.

.. _client-sync-instruction:

sync
~~~~

Reports that all operations as of the given server-relative timestamp
have been completed. If a sync is received from the server, the client
must respond with a corresponding sync once all previous operations have
been completed, or the server may stop sending updates until the client
catches up. For the client, sending a sync with a timestamp newer than
any timestamp received from the server is an error.

Both client and server are expected to occasionally send sync to report
on current operation execution state.

``timestamp``
   A valid server-relative timestamp.

Server control instructions
---------------------------

.. _server-disconnect-instruction:

disconnect
~~~~~~~~~~

Notifies the client that the connection is about to be closed by the
server. This message can be sent by the server during any phase, and
takes no parameters.

.. _error-instruction:

error
~~~~~

Notifies the client that the connection is about to be closed due to the
specified error. This message can be sent by the server during any
phase.

``text``
   An arbitrary message describing the error

``status``
   The Guacamole status code describing the error. For a list of status
   codes, see the table in `Status codes <#status-codes>`__.

.. _log-instruction:

log
~~~

The log instruction sends an arbitrary string for debugging purposes.
This instruction will be ignored by Guacamole clients, but can be seen
in protocol dumps if such dumps become necessary. Sending a log
instruction can help add context when searching for the cause of a fault
in protocol support.

``message``
   An arbitrary, human-readable message.

.. _server-mouse-instruction:

mouse
~~~~~

Reports that a user on the current connection has moved the mouse to the
given coordinates.

``x``
   The current X coordinate of the mouse pointer.

``y``
   The current Y coordinate of the mouse pointer.

.. _server-nop-instruction:

nop
~~~

The server "nop" instruction does absolutely nothing, has no parameters,
and is universally ignored by Guacamole clients. Its main use is as a
keep-alive signal, and may be sent by guacd or client plugins when there
is no activity to ensure the socket is not closed due to timeout.

.. _ready-instruction:

ready
~~~~~

The ready instruction sends the ID of a new connection and marks the
beginning of the interactive phase of a new, successful connection. The
ID sent is a completely arbitrary string, and has no standard format. It
must be unique from all existing and future connections and may not
match the name of any installed protocol support.

``ID``
   An arbitrary, unique identifier for the current connection. This
   identifier must be unique from all existing and future connections,
   and may not match the name of any installed protocol support (such as
   "vnc" or "rdp").

.. _server-sync-instruction:

sync
~~~~

Indicates that the given timestamp is the current timestamp as of all
previous operations. The client must respond to every sync instruction
received.

Both client and server are expected to occasionally send sync to report
on current operation execution state.

``timestamp``
   A valid server-relative timestamp.

Client events
-------------

.. _key-instruction:

key
~~~

Sends the specified key press or release event.

``keysym``
   The `X11 keysym <http://www.x.org/wiki/KeySyms>`__ of the key being
   pressed or released.

``pressed``
   0 if the key is not pressed, 1 if the key is pressed.

.. _client-mouse-instruction:

mouse
~~~~~

Sends the specified mouse movement or button press or release event (or
combination thereof).

``x``
   The current X coordinate of the mouse pointer.

``y``
   The current Y coordinate of the mouse pointer.

``mask``
   The button mask, representing the pressed or released status of each
   mouse button.

.. _size-event-instruction:

size
~~~~

Specifies that the client's optimal screen size has changed from what
was specified during the handshake, or from previously-sent "size"
instructions.

``width``
   The new, optimal screen width.

``height``
   The new, optimal screen height.

