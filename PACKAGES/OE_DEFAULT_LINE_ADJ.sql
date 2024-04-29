--------------------------------------------------------
--  DDL for Package OE_DEFAULT_LINE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_LINE_ADJ" AUTHID CURRENT_USER AS
/* $Header: OEXDLADS.pls 120.0 2005/06/01 00:33:56 appldev noship $ */

PROCEDURE Attributes
(   p_x_Line_Adj_rec                IN out  nocopy OE_Order_PUB.Line_Adj_Rec_Type
,   p_old_Line_Adj_rec              IN  OE_Order_PUB.Line_Adj_Rec_Type
,   p_iteration                     IN  NUMBER := 1
) ;

END OE_Default_Line_Adj  ;

 

/
