--------------------------------------------------------
--  DDL for Package OE_DEFAULT_LINE_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_LINE_SCREDIT" AUTHID CURRENT_USER AS
/* $Header: OEXDLSCS.pls 120.0 2005/06/01 02:27:12 appldev noship $ */

PROCEDURE Attributes
(   p_x_Line_Scredit_rec            IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type
,   p_iteration                     IN  NUMBER := 1
) ;

END OE_Default_Line_Scredit  ;

 

/
