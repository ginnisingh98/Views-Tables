--------------------------------------------------------
--  DDL for Package Body OE_COPY_UTIL_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_COPY_UTIL_EXT" AS
/* $Header: OEXCEXTB.pls 115.1 2004/02/03 23:36:57 mchavan noship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'OE_COPY_UTIL_EXT';

PROCEDURE Copy_Line_DFF
 ( p_copy_rec       IN  oe_order_copy_util.copy_rec_type
 , p_operation      IN  VARCHAR2
 , p_ref_line_rec   IN  OE_Order_PUB.Line_Rec_Type
 , p_copy_line_rec  IN  OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
 )
IS
BEGIN

-- This is an extension API to allow users to write their own logic on copying
-- line level descriptive flexfields. By default, we do not allow users to copy
-- the DFF if they are doing a ORDER to RMA copy.
-- With this extension API, they will get a chance to copy the DFF for
-- Order to RMA copy. Users can even write a selective logic so that only some
-- valid attributes are copied over.
-- ON copy form if user selects to include the DFF on Lines Tab then
-- p_copy_line_rec will have all DFF flex attributes from source line. Otherwise
-- they all will get set to FND_API.G_MISS_CHAR.
--
-- The check-box to include DFF, which is currently not available for Order to
-- RMA copy, will be enabled if this extension API is implemented by users (by
-- setting the system parameter : COPY_LINE_DFF_EXT_API).
--
-- These DFF attributes will still be Validated during COPY and if it fails in
-- validation then appropriate message will be displayed. Also we will set the
-- values to NULL and will indicate to users to enter these values manually
-- after copy.
--
-- Here is a list of attributes on p_copy_rec that can be usefull
-- copy_order ->
--    VARCHAR2(1) : FND_API.G_TRUE -  If New Order/Quote is to be
--                                    created
--
-- append_to_header_id ->
--     NUMBER : Header_id of order, you are adding lines to
--
-- hdr_type ->
--      NUMBER : order_type_id of the destination order.
--
-- new_phase ->
--      VARCHAR2(1) : F if creating a Sales Order. 'N' if creating a Quote.
--
-- line_type ->
--      NUMBER : line_type_id  selected on COPY form.
--
-- line_descflex ->
--    VARCHAR2(1) : FND_API.G_TRUE -  If user selects to copy line level DFF on
--                                    copy form.
--
-- Other parameters are:
--
-- p_operation : VARCHAR2(30) Possible values are
-- 'ORDER_TO_RETURN', 'RETURN_TO_ORDER', 'RETURN_TO_RETURN' and 'ORDER_TO_ORDER'
-- This indicates how the line category is changing on the specific line record.
--
-- p_ref_line_rec : It will be populated with the COPY source line record.
--
NULL;

END Copy_Line_DFF;

END OE_COPY_UTIL_EXT;

/
