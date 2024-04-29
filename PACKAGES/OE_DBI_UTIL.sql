--------------------------------------------------------
--  DDL for Package OE_DBI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DBI_UTIL" AUTHID CURRENT_USER As
/* $Header: OEXUDBIS.pls 120.0.12010000.1 2008/07/25 07:55:29 appldev ship $ */

G_PKG_NAME                   CONSTANT VARCHAR2(30) := 'OE_DBI_UTIL';

Procedure Update_DBI_Log
( x_return_status OUT NOCOPY VARCHAR2

/*
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
*/
);

END OE_DBI_UTIL;


/
