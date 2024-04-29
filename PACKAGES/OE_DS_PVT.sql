--------------------------------------------------------
--  DDL for Package OE_DS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DS_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVDSRS.pls 120.0.12010000.1 2008/07/25 07:59:39 appldev ship $ */

TYPE Profile_type IS RECORD
( oe_source_code VARCHAR2(240)
, user_id        NUMBER
, login_id       NUMBER
, request_id     NUMBER
, application_id NUMBER
, program_id     NUMBER);

profile_values  Profile_type;

FUNCTION DropShipReceive( p_rcv_transaction_id      IN  NUMBER,
                          p_application_short_name  IN  VARCHAR2,
                          p_mode                    IN  NUMBER DEFAULT 0)
RETURN BOOLEAN;

FUNCTION Get_mtl_sales_order_id(p_header_id IN NUMBER)
RETURN NUMBER;

Procedure Insert_OE_Drop_Ship_Source
( P_Old_Line_ID                 In Number,
  P_New_Line_ID                 In Number);

Procedure Check_PO_Approved
( p_application_id               IN   NUMBER
, p_entity_short_name            IN   VARCHAR2
, p_validation_entity_short_name IN   VARCHAR2
, p_validation_tmplt_short_name  IN   VARCHAR2
, p_record_set_tmplt_short_name  IN   VARCHAR2
, p_scope                        IN   VARCHAR2
, p_result                       OUT NOCOPY /* file.sql.39 change */  NUMBER
);

FUNCTION Check_Req_PO_Cancelled
( p_line_id        IN    NUMBER
, p_header_id      IN    NUMBER
) RETURN BOOLEAN;

Procedure OM_PO_Discrepancy_Exists
( p_application_id               IN   NUMBER
, p_entity_short_name            IN   VARCHAR2
, p_validation_entity_short_name IN   VARCHAR2
, p_validation_tmplt_short_name  IN   VARCHAR2
, p_record_set_tmplt_short_name  IN   VARCHAR2
, p_scope                        IN   VARCHAR2
, p_result                       OUT NOCOPY /* file.sql.39 change */  NUMBER
);

END OE_DS_PVT;

/
