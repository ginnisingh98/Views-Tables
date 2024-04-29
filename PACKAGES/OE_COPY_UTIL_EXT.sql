--------------------------------------------------------
--  DDL for Package OE_COPY_UTIL_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_COPY_UTIL_EXT" AUTHID CURRENT_USER AS
/* $Header: OEXCEXTS.pls 115.1 2004/02/03 23:36:41 mchavan noship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'OE_COPY_UTIL_EXT';

-- This global variable is added for backward compatibility. Please do not set
-- this variable.
G_CALL_API          VARCHAR2(1) := 'N';

PROCEDURE Copy_Line_DFF
 ( p_copy_rec       IN  oe_order_copy_util.copy_rec_type
 , p_operation      IN  VARCHAR2
 , p_ref_line_rec   IN  OE_Order_PUB.Line_Rec_Type
 , p_copy_line_rec  IN  OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
 );

END OE_COPY_UTIL_EXT;

 

/
