--------------------------------------------------------
--  DDL for Package INV_MWB_QUERY_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_QUERY_MANAGER" AUTHID CURRENT_USER AS
/* $Header: INVMWQMS.pls 120.16 2008/01/10 23:57:24 musinha ship $ */
   TYPE SelectColumnRecType IS RECORD ( column_name VARCHAR2(100), column_value VARCHAR2(100) );

   TYPE SelectColumnTabType  IS TABLE OF SelectColumnRecType INDEX BY BINARY_INTEGER;

   -- Bug 6060233: Changed the size to 500
   TYPE SQLClauseTabType    IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;			-- Bug 6429880


   g_onhand_select SelectColumnTabType;
   g_onhand_from   SQLClauseTabType;
   g_onhand_where  SQLClauseTabType;
   g_onhand_group  SQLClauseTabType;

   g_onhand_1_select SelectColumnTabType;
   g_onhand_1_from   SQLClauseTabType;
   g_onhand_1_where  SQLClauseTabType;
   g_onhand_1_group  SQLClauseTabType;

   g_inbound_select SelectColumnTabType;
   g_inbound_from   SQLClauseTabType;
   g_inbound_where  SQLClauseTabType;
   g_inbound_group  SQLClauseTabType;

   g_inbound_1_select SelectColumnTabType;
   g_inbound_1_from   SQLClauseTabType;
   g_inbound_1_where  SQLClauseTabType;
   g_inbound_1_group  SQLClauseTabType;

   g_receiving_select SelectColumnTabType;
   g_receiving_from   SQLClauseTabType;
   g_receiving_where  SQLClauseTabType;
   g_receiving_group  SQLClauseTabType;

   g_receiving_1_select SelectColumnTabType;
   g_receiving_1_from   SQLClauseTabType;
   g_receiving_1_where  SQLClauseTabType;
   g_receiving_1_group  SQLClauseTabType;

   g_union_select SelectColumnTabType;
   g_union_from   SQLClauseTabType;
   g_union_where  SQLClauseTabType;
   g_union_group  SQLClauseTabType;

   g_null_select  SelectColumnTabType;
   g_null_clause  SQLClauseTabType;


   PROCEDURE add_from_clause(p_from_clause IN VARCHAR2, p_target IN VARCHAR2);
   PROCEDURE add_where_clause(p_where_clause IN VARCHAR2, p_target IN VARCHAR2);
   PROCEDURE add_group_clause(p_group_clause IN VARCHAR2, p_target IN VARCHAR2);
   PROCEDURE add_bind_variable(p_bind_name IN VARCHAR2, p_bind_value IN VARCHAR2);
   PROCEDURE add_bind_variable(p_bind_name IN VARCHAR2, p_bind_value IN DATE);
   PROCEDURE add_bind_variable(p_bind_name IN VARCHAR2, p_bind_value IN NUMBER);
   PROCEDURE add_qf_where_onhand(p_flag VARCHAR2);
   PROCEDURE add_qf_where_receiving(p_flag VARCHAR2);
   PROCEDURE add_qf_where_inbound(p_flag VARCHAR2);
   PROCEDURE add_qf_where_lpn_node(p_mat_loc VARCHAR2);
   PROCEDURE execute_query;
   PROCEDURE make_nested_lpn_onhand_query;
   PROCEDURE make_nested_lpn_rcv_query;
   PROCEDURE make_nested_lpn_inbound_query;

   PROCEDURE initialize_onhand_query;
   PROCEDURE initialize_inbound_query;
   PROCEDURE initialize_receiving_query;

   PROCEDURE initialize_onhand_1_query;
   PROCEDURE initialize_inbound_1_query;
   PROCEDURE initialize_receiving_1_query;

   PROCEDURE initialize_union_query;

   PO_RELEASE_ID               CONSTANT NUMBER := 1;
   RELEASE_LINE_NUMBER         CONSTANT NUMBER := 2;
   SHIPMENT_NUMBER             CONSTANT NUMBER := 3;
   SHIPMENT_HEADER_ID_INTERORG CONSTANT NUMBER := 4;
   ASN                         CONSTANT NUMBER := 5;
   SHIPMENT_HEADER_ID_ASN      CONSTANT NUMBER := 6;
   TRADING_PARTNER             CONSTANT NUMBER := 7;
   VENDOR_ID                   CONSTANT NUMBER := 8;
   TRADING_PARTNER_SITE        CONSTANT NUMBER := 9;
   VENDOR_SITE_ID              CONSTANT NUMBER := 10;
   FROM_ORG                    CONSTANT NUMBER := 11;
   FROM_ORG_ID                 CONSTANT NUMBER := 12;
   TO_ORG                      CONSTANT NUMBER := 13;
   TO_ORG_ID                   CONSTANT NUMBER := 14;
   EXPECTED_RECEIPT_DATE       CONSTANT NUMBER := 15;
   SHIPPED_DATE                CONSTANT NUMBER := 16;
   OWNING_ORG                  CONSTANT NUMBER := 17;
   OWNING_ORG_ID               CONSTANT NUMBER := 18;
   REQ_HEADER_ID               CONSTANT NUMBER := 19;
   OE_HEADER_ID                CONSTANT NUMBER := 20;
   PO_HEADER_ID                CONSTANT NUMBER := 21;
   MATURITY_DATE               CONSTANT NUMBER := 22;
   HOLD_DATE                   CONSTANT NUMBER := 23;
   SUPPLIER_LOT                CONSTANT NUMBER := 24;
   PARENT_LOT                  CONSTANT NUMBER := 25;
   DOCUMENT_TYPE               CONSTANT NUMBER := 26;
   DOCUMENT_TYPE_ID            CONSTANT NUMBER := 27;
   DOCUMENT_NUMBER             CONSTANT NUMBER := 28;
   DOCUMENT_LINE_NUMBER        CONSTANT NUMBER := 29;
   RELEASE_NUMBER              CONSTANT NUMBER := 30;
   ORIGINATION_TYPE            CONSTANT NUMBER := 31;
   ORIGINATION_DATE            CONSTANT NUMBER := 32;
   ACTION_CODE                 CONSTANT NUMBER := 33;
   ACTION_DATE                 CONSTANT NUMBER := 34;
   RETEST_DATE                 CONSTANT NUMBER := 35;
   SECONDARY_UNPACKED          CONSTANT NUMBER := 36;
   SECONDARY_PACKED            CONSTANT NUMBER := 37;
   SUBINVENTORY_CODE           CONSTANT NUMBER := 38;
   LOCATOR                     CONSTANT NUMBER := 39;
   LOCATOR_ID                  CONSTANT NUMBER := 40;
   LPN                         CONSTANT NUMBER := 41;
   LPN_ID                      CONSTANT NUMBER := 42;
   COST_GROUP                  CONSTANT NUMBER := 43;
   CG_ID                       CONSTANT NUMBER := 44;
   LOADED                      CONSTANT NUMBER := 45;
   PLANNING_PARTY              CONSTANT NUMBER := 46;
   PLANNING_PARTY_ID           CONSTANT NUMBER := 47;
   OWNING_PARTY                CONSTANT NUMBER := 48;
   OWNING_PARTY_ID             CONSTANT NUMBER := 49;
   LOT                         CONSTANT NUMBER := 50;
   SERIAL                      CONSTANT NUMBER := 51;
   UNIT_NUMBER                 CONSTANT NUMBER := 52;
   LOT_EXPIRY_DATE             CONSTANT NUMBER := 53;
   ORGANIZATION_CODE           CONSTANT NUMBER := 54;
   ORG_ID                      CONSTANT NUMBER := 55;
   ITEM                        CONSTANT NUMBER := 56;
   ITEM_DESCRIPTION            CONSTANT NUMBER := 57;
   ITEM_ID                     CONSTANT NUMBER := 58;
   REVISION                    CONSTANT NUMBER := 59;
   PRIMARY_UOM_CODE            CONSTANT NUMBER := 60;
   ONHAND                      CONSTANT NUMBER := 61;
   RECEIVING                   CONSTANT NUMBER := 62;
   INBOUND                     CONSTANT NUMBER := 63;
   UNPACKED                    CONSTANT NUMBER := 64;
   PACKED                      CONSTANT NUMBER := 65;
   SECONDARY_UOM_CODE          CONSTANT NUMBER := 66;
   SECONDARY_ONHAND            CONSTANT NUMBER := 67;
   SECONDARY_RECEIVING         CONSTANT NUMBER := 68;
   SECONDARY_INBOUND           CONSTANT NUMBER := 69;
   GRADE_CODE                  CONSTANT NUMBER := 70;
   OWNING_ORGANIZATION_ID      CONSTANT NUMBER := 71;
   PLANNING_ORGANIZATION_ID    CONSTANT NUMBER := 72;
   OWNING_TP_TYPE              CONSTANT NUMBER := 73;
   PLANNING_TP_TYPE            CONSTANT NUMBER := 74;

   -- Onhand Material Status support
   STATUS                      CONSTANT NUMBER := 75;
   STATUS_ID                   CONSTANT NUMBER := 76;

END INV_MWB_QUERY_MANAGER;

/
