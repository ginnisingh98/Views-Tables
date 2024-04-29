--------------------------------------------------------
--  DDL for Package OE_DEFAULT_HEADER_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_HEADER_ADJ" AUTHID CURRENT_USER AS
/* $Header: OEXDHADS.pls 120.0 2005/06/01 02:42:55 appldev noship $ */

PROCEDURE Attributes
(   p_x_Header_Adj_rec              IN  out nocopy OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type
,   p_iteration                     IN  NUMBER := 1
) ;

END OE_Default_Header_Adj  ;

 

/
