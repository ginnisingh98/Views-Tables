--------------------------------------------------------
--  DDL for Package OE_ORDER_IMPORT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_IMPORT_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVIMUS.pls 120.1 2005/08/05 15:29:24 sphatarp noship $ */

--  Start of Comments
--  API name    Order Import Utilities
--  Type        Private
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_ORDER_IMPORT_UTIL_PVT';

PROCEDURE Delete_Order(
   p_request_id			IN  NUMBER
  ,p_order_source_id     	IN  NUMBER
  ,p_orig_sys_document_ref     	IN  VARCHAR2
  ,p_sold_to_org_id             IN  NUMBER   := NULL
  ,p_sold_to_org                IN  VARCHAR2 := NULL
  ,p_change_sequence		IN  VARCHAR2 := NULL
  ,p_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Delete_Messages(
   p_request_id     		IN  NUMBER
  ,p_order_source_id     	IN  NUMBER
  ,p_orig_sys_document_ref 	IN  VARCHAR2
  ,p_sold_to_org_id             IN  NUMBER   := NULL
  ,p_sold_to_org             IN  VARCHAR2   := NULL
  ,p_change_sequence 		IN  VARCHAR2 := NULL
  ,p_org_id                     IN  VARCHAR2 := Null
  ,p_return_status OUT NOCOPY VARCHAR2

);

FUNCTION Get_Line_Index(
   p_line_tbl			IN OE_Order_Pub.Line_Tbl_Type
  ,p_orig_sys_line_ref 		IN VARCHAR2
  ,p_orig_sys_shipment_ref	IN VARCHAR2
)
RETURN NUMBER;


END OE_ORDER_IMPORT_UTIL_PVT;

 

/
