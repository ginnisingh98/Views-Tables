--------------------------------------------------------
--  DDL for Package OE_DEFAULT_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_HEADER" AUTHID CURRENT_USER AS
/* $Header: OEXDHDRS.pls 120.0 2005/05/31 23:11:24 appldev noship $ */

PROCEDURE Attributes
(   p_x_Header_rec                  IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
,   p_old_Header_rec                IN  OE_Order_PUB.Header_Rec_Type
,   p_iteration                     IN  NUMBER := 1
) ;

END OE_Default_Header  ;

 

/
