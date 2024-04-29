--------------------------------------------------------
--  DDL for Package OE_INLINE_CUSTOMER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INLINE_CUSTOMER_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPINLS.pls 120.1.12010000.1 2008/07/25 07:53:07 appldev ship $ */
--  Start of Comments
--  API name    OE_INLINE_CUSTOMER_PUB
--  Type        Public
--  Purpose     Order Import customer creation
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--  End of Comments

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'OE_INLINE_CUSTOMER_PUB';
G_SOLD_TO_CUST              NUMBER;

PROCEDURE Create_Customer_Info(
          p_customer_info_ref       IN     Varchar2,
          p_customer_info_type_code IN     Varchar2,
          p_usage                   IN     Varchar2,
          p_orig_sys_document_ref   IN     Varchar2 Default null,
          p_orig_sys_line_ref       IN     Varchar2 Default null,
          p_order_source_id         IN     Number   Default null,
          p_org_id                  IN     Number   Default null,
          x_customer_info_id        OUT NOCOPY /* file.sql.39 change */    Number,
          x_customer_info_number    OUT NOCOPY /* file.sql.39 change */    Varchar2,
          x_return_status           OUT NOCOPY /* file.sql.39 change */    Varchar2
          );

Procedure Delete_Customer_Info(
           p_header_customer_rec  In  OE_ORDER_IMPORT_SPECIFIC_PVT.Customer_Rec_Type,
           p_line_customer_tbl    In OE_ORDER_IMPORT_SPECIFIC_PVT.Customer_Tbl_Type);

End OE_INLINE_CUSTOMER_PUB;

/
