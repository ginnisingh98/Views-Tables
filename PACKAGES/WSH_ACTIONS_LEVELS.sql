--------------------------------------------------------
--  DDL for Package WSH_ACTIONS_LEVELS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ACTIONS_LEVELS" AUTHID CURRENT_USER as
/* $Header: WSHACLVS.pls 120.0.12010000.2 2009/12/04 05:52:41 mvudugul ship $ */

c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;

C_ACTION_ENABLED_LVL            CONSTANT NUMBER := 1;
C_LOCK_RECORDS_LVL              CONSTANT NUMBER := 2;
C_DLVY_ACTION_ENABLED_LVL       CONSTANT NUMBER := 3;
C_DECIMAL_QUANTITY_LVL          CONSTANT NUMBER := 4;
C_DLVY_DEFAULTS_LVL     	CONSTANT NUMBER := 5;
C_TRIP_NAME_LVL         	CONSTANT NUMBER := 6;
C_STOP_NAME_LVL         	CONSTANT NUMBER := 7;
C_SEQ_NUM_LVL           	CONSTANT NUMBER := 8;
C_CHECK_UNASSIGN_LVL    	CONSTANT NUMBER := 9;
C_DOCUMENT_SETS_LVL     	CONSTANT NUMBER := 10;
C_TRIP_STOP_VALIDATION_LVL      CONSTANT NUMBER := 11;
C_STOP_DEFAULTS_LVL             CONSTANT NUMBER := 12;
C_LOCATION_LVL                  CONSTANT NUMBER := 13;
C_TRIP_SMC_LVL                  CONSTANT NUMBER := 14;
C_BOL_NUM_LVL                   CONSTANT NUMBER := 15;
C_CHK_UPDATE_STATUS_LVL		CONSTANT NUMBER := 16;
C_FREIGHT_COST_TYPE_LVL         CONSTANT NUMBER := 17;
C_FREIGHT_UNIT_AMT_LVL          CONSTANT NUMBER := 18;
C_FREIGHT_CONV_RATE_LVL         CONSTANT NUMBER := 19;
C_FREIGHT_CURR_CODE_LVL         CONSTANT NUMBER := 20;
C_PARENT_ENTITY_LVL             CONSTANT NUMBER := 21;
C_CONTAINER_STATUS_LVL          CONSTANT NUMBER := 22;
C_CONTAINER_ORG_LVL             CONSTANT NUMBER := 23;
C_CONT_DLVY_LVL                 CONSTANT NUMBER := 24;
C_TRIP_STATUS_LVL		CONSTANT NUMBER := 25;
C_PLANNED_TRIP_LVL		CONSTANT NUMBER := 26;
C_WEIGHT_UOM_LVL                CONSTANT NUMBER := 27;
C_VOLUME_UOM_LVL                CONSTANT NUMBER := 28;
C_ARR_DEP_DATES_LVL             CONSTANT NUMBER := 29;
C_DISABLED_LIST_LVL		CONSTANT NUMBER := 30;
C_ARR_AFTER_TRIP_LVL		CONSTANT NUMBER := 31;
C_VEH_ORG_LVL			CONSTANT NUMBER := 32;
C_TRIP_MOT_LVL			CONSTANT NUMBER := 33;
C_SERVICE_LVL			CONSTANT NUMBER := 34;
C_CARRIER_LVL			CONSTANT NUMBER := 35;
C_VEH_ITEM_LVL			CONSTANT NUMBER := 36;
C_CONSOL_ALLW_LVL		CONSTANT NUMBER := 37;
--Following levels Added by KVENKATE for delivery details
C_GROSS_WEIGHT_LVL    	        CONSTANT NUMBER := 38;
C_NET_WEIGHT_LVL                CONSTANT NUMBER := 39;
C_VOLUME_LVL                    CONSTANT NUMBER := 40;
C_CUSTOMER_LVL                  CONSTANT NUMBER := 41;
C_SHIP_FROM_ORG_LVL             CONSTANT NUMBER := 42;
C_SHIP_TO_ORG_LVL               CONSTANT NUMBER := 43;
C_DELV_TO_ORG_LVL               CONSTANT NUMBER := 44;
C_INTMED_SHIP_ORG_LVL           CONSTANT NUMBER := 45;
C_TOL_ABOVE_LVL                 CONSTANT NUMBER := 46;
C_TOL_BELOW_LVL                 CONSTANT NUMBER := 47;
C_SHIP_QTY_LVL                  CONSTANT NUMBER := 48;
C_CC_QTY_LVL                    CONSTANT NUMBER := 49;
C_SERIAL_NUM_LVL                CONSTANT NUMBER := 50;
C_SMC_LVL                       CONSTANT NUMBER := 51;
C_FREIGHT_TERMS_LVL             CONSTANT NUMBER := 52;
C_FOB_LVL                       CONSTANT NUMBER := 53;
C_DEP_PLAN_LVL                  CONSTANT NUMBER := 54;
C_SHIP_MOD_COMP_LVL             CONSTANT NUMBER := 55;
C_REL_STATUS_LVL                CONSTANT NUMBER := 56;
C_SUB_INV_LVL                   CONSTANT NUMBER := 57;
C_REVISION_LVL                  CONSTANT NUMBER := 58;
C_LOCATOR_LVL                   CONSTANT NUMBER := 59;
C_LOT_NUMBER_LVL                CONSTANT NUMBER := 60;
C_SOLD_CONTACT_LVL              CONSTANT NUMBER := 61;
C_SHIP_CONTACT_LVL              CONSTANT NUMBER := 62;
C_DELIVER_CONTACT_LVL           CONSTANT NUMBER := 63;
C_INTMED_SHIP_CONTACT_LVL       CONSTANT NUMBER := 64;
C_CONT_ITEM_LVL                 CONSTANT NUMBER := 65;
C_MASTER_SER_NUM_LVL            CONSTANT NUMBER := 66;
-- I Harmonization: rvishnuv ******* Delivery
C_DELIVERY_NAME_LVL             CONSTANT NUMBER := 67;
C_ORGANIZATION_LVL              CONSTANT NUMBER := 68;
C_LOADING_ORDER_LVL             CONSTANT NUMBER := 69;
C_SHIP_FROM_LOC_LVL             CONSTANT NUMBER := 70;
C_SHIP_TO_LOC_LVL               CONSTANT NUMBER := 71;
C_INTMD_SHIPTO_LOC_LVL          CONSTANT NUMBER := 72;
C_POOLED_SHIPTO_LOC_LVL         CONSTANT NUMBER := 73;
C_DLVY_ORG_LVL                  CONSTANT NUMBER := 74;
C_FREIGHT_CARRIER_LVL           CONSTANT NUMBER := 75;
C_FOB_LOC_LVL                   CONSTANT NUMBER := 76;
C_ROUTE_EXPORT_TXN_LVL          CONSTANT NUMBER := 77;
C_CURRENCY_LVL                  CONSTANT NUMBER := 78;
C_NUMBER_OF_LPN_LVL             CONSTANT NUMBER := 79;
C_DERIVE_DELIVERY_UOM_LVL       CONSTANT NUMBER := 80;

-- HW Harmonization project for OPM. Added qty2
C_SHIP_QTY2_LVL                  CONSTANT NUMBER := 81;
C_CC_QTY2_LVL                    CONSTANT NUMBER := 82;
--I Harmonization KVENKATE
C_DET_INSPECT_FLAG_LVL           CONSTANT NUMBER := 83;
C_MASTER_LPN_ITEM_LVL            CONSTANT NUMBER := 84;
C_DETAIL_LPN_ITEM_LVL            CONSTANT NUMBER := 85;

-- I Harmonization: rvishnuv ******** Delivery
C_PRINT_LABEL_LVL                CONSTANT NUMBER := 86;
-- sperera ALCOA fix
C_TRIP_CONFIRM_DEFAULT_LVL       CONSTANT NUMBER :=87;
-- kvenkate
C_LOCK_RELATED_ENTITIES_LVL      CONSTANT NUMBER := 88;
--bms
C_VALIDATE_CONSTRAINTS_LVL       CONSTANT NUMBER := 89;
--bms
C_VALIDATE_FREIGHT_CLASS_LVL         CONSTANT NUMBER := 90;
C_VALIDATE_OM_QTY_WT_VOL_LVL         CONSTANT NUMBER := 91;
C_VALIDATE_OKE_NULL_FIELDS_LVL       CONSTANT NUMBER := 92;
C_VALIDATE_OM_MIS_LVL                CONSTANT NUMBER := 93;
C_VALIDATE_OKE_MIS_LVL               CONSTANT NUMBER := 94;
C_POPULATE_ORGANIZATION_ID           CONSTANT NUMBER := 95;
C_GET_SHIP_FROM_LOC_LVL              CONSTANT NUMBER := 96;
C_GET_SHIPTO_LOC_LVL                 CONSTANT NUMBER := 97;
C_GET_DELIVER_TO_LOC_LVL             CONSTANT NUMBER := 98;
C_GET_INTMED_SHIPTO_LOC_LVL          CONSTANT NUMBER := 99;
C_VALIDATE_SHIPTO_LOC_LVL            CONSTANT NUMBER := 100;
C_VALIDATE_SHIP_FROM_LOC_LVL         CONSTANT NUMBER := 101;
C_DEFAULT_FLEX_LVL                   CONSTANT NUMBER := 102;
C_DEFAULT_CONTAINEER_LVL             CONSTANT NUMBER := 103;
C_CREATE_MIXED_TRIP_LVL              CONSTANT NUMBER := 104;   -- J-IB-NPARIKH
C_CREATE_MIXED_STOP_LVL              CONSTANT NUMBER := 105;   -- J-IB-NPARIKH
-- J-IB-ANVISWAN
C_PO_CHECK_ORGID_LVL                 CONSTANT NUMBER := 106;
C_PO_DEFAULT_SHIPFROM_LVL            CONSTANT NUMBER := 107;
C_PO_VALIDATE_MAN_FIELDS_LVL         CONSTANT NUMBER := 108;
C_PO_DERIVE_DROPSHIP_LVL             CONSTANT NUMBER := 109;
C_PO_VALIDATE_SHPTO_LOC_LVL          CONSTANT NUMBER := 110;
C_PO_VALIDATE_FOB_LVL                CONSTANT NUMBER := 111;
C_PO_VALIDATE_FR_TERMS_LVL           CONSTANT NUMBER := 112;
C_PO_CALC_WT_VOL_LVL                 CONSTANT NUMBER := 113;
C_PO_GET_OPM_QTY_LVL                 CONSTANT NUMBER := 114;
C_PO_DEFAULT_FLEX_LVL                CONSTANT NUMBER := 115;
C_PLAN_ARR_DATE_LVL                  CONSTANT NUMBER := 116;  -- J-Stop Sequence Change-CSUN
C_WMS_CONTAINERS_LVL                 CONSTANT NUMBER := 117;  -- K-LPN Conv
C_CLIENT_LVL                         CONSTANT NUMBER := 118;  -- LSP PROJECT





g_validation_level_tab		wsh_util_core.id_tab_type;

PROCEDURE set_validation_level_on (
   p_entity			IN  VARCHAR2,
   x_return_status		OUT NOCOPY  VARCHAR2
 );

PROCEDURE set_validation_level_off (
   p_entity			IN  VARCHAR2,
   x_return_status		OUT NOCOPY  VARCHAR2
 );


PROCEDURE set_validation_level (
        p_entity		IN VARCHAR2,
        p_caller                IN VARCHAR2,
        p_phase                 IN NUMBER,
        p_action                IN VARCHAR2,
        x_return_status		OUT NOCOPY  VARCHAR2
    );

END WSH_ACTIONS_LEVELS;

/