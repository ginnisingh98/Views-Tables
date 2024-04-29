--------------------------------------------------------
--  DDL for Package OE_DEFAULT_LOT_SERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_LOT_SERIAL" AUTHID CURRENT_USER AS
/* $Header: OEXDSRLS.pls 120.0 2005/06/01 00:02:10 appldev noship $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_x_Lot_Serial_rec              IN OUT NOCOPY  OE_Order_PUB.Lot_Serial_Rec_Type
,   p_iteration                     IN  NUMBER := 1
);

END OE_Default_Lot_Serial;

 

/
