--------------------------------------------------------
--  DDL for Package OE_ORDER_IMPORT_CONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_IMPORT_CONFIG_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVIMCS.pls 120.0 2005/06/01 03:08:24 appldev noship $ */

--  Start of Comments
--  API name    OE_ORDER_IMPORT_CONFIG_PVT
--  Type        Private
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_ORDER_IMPORT_CONFIG_PVT';

PROCEDURE Pre_Process(
  p_header_rec                  IN     OE_Order_Pub.Header_Rec_Type
 ,p_x_line_tbl                    IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
,p_return_status OUT NOCOPY VARCHAR2

);


END OE_ORDER_IMPORT_CONFIG_PVT;

 

/
