--------------------------------------------------------
--  DDL for Package OE_DEFAULT_HEADER_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_HEADER_SCREDIT" AUTHID CURRENT_USER AS
/* $Header: OEXDHSCS.pls 120.0 2005/06/01 01:06:40 appldev noship $ */

PROCEDURE Attributes
(   p_x_Header_Scredit_rec          IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_old_Header_Scredit_rec        IN  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_iteration                     IN  NUMBER := 1
) ;

END OE_Default_Header_Scredit  ;

 

/
