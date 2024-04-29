--------------------------------------------------------
--  DDL for Package WSMPLCVA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPLCVA" AUTHID CURRENT_USER AS
/* $Header: WSMLCVAS.pls 115.13 2002/10/04 21:39:37 abedajna ship $ */

-- global datatype declarations
-- ==============================================================================================
-- creating an index by table that'll store the valid org values as the index for easy validation
-- ==============================================================================================

--abb H optional scrap accounting, added ESTIMATED_SCRAP_ACCOUNTING
type rec_wsm_param IS record
        (ORGANIZATION_ID 		wsm_parameters.ORGANIZATION_ID%type,
        COPRODUCTS_SUPPLY_DEFAULT 	wsm_parameters.COPRODUCTS_SUPPLY_DEFAULT%type,
        DEFAULT_ACCT_CLASS_CODE  	wsm_parameters.DEFAULT_ACCT_CLASS_CODE%type,
        OP_SEQ_NUM_INCREMENT  		wsm_parameters.OP_SEQ_NUM_INCREMENT%type,
        LAST_OPERATION_SEQ_NUM  	wsm_parameters.LAST_OPERATION_SEQ_NUM%type,
	ESTIMATED_SCRAP_ACCOUNTING	wsm_parameters.ESTIMATED_SCRAP_ACCOUNTING%type,
	MAX_ORG_ACC_PERIODS  		org_acct_periods.ACCT_PERIOD_ID%type,
	MAX_STK_LOC_CNTRL   		mtl_parameters.STOCK_LOCATOR_CONTROL_CODE%type,
	PO_CREATION_TIME		wip_parameters.PO_CREATION_TIME%type);

v_rec_wsm_param rec_wsm_param;

type t_org    IS   table of rec_wsm_param index by binary_integer;
v_org t_org;

-- ================================================================================================
-- creating an index by table that'll store the valid hash(subinv+org) as index for easy validation
-- ================================================================================================

type t_subinv    IS   table of  wsm_subinventory_extensions.secondary_inventory_name%type
						index by binary_integer;
v_subinv t_subinv;


-- ===============================================================================================
-- creating an index by table that'll store the valid item values as the index for easy validation
-- ===============================================================================================

type t_item      IS table of wsm_lot_job_interface.primary_item_id%type
                                                 index by binary_integer;
v_item t_item;

-- ===============================================================================================
-- creating an index by table that'll store hash (assembly + component) item values as the index
-- ===============================================================================================

type rec_item IS record(INVENTORY_ITEM_ID wsm_starting_lots_interface.INVENTORY_ITEM_ID%type,
			PRIMARY_ITEM_ID   wsm_lot_job_interface.PRIMARY_ITEM_ID%type);

type t_mode2_item  IS table of rec_item index by binary_integer;

v_mode2_item t_mode2_item;

-- ===============================================================================================
-- creating an index by table that'll store the valid class codes as the index for easy validation
-- ===============================================================================================

type t_class_code      IS table of wsm_lot_job_interface.class_code%type
                                                 index by binary_integer;
v_class_code  t_class_code;

-- ===============================================================================================
-- creating an index by table that'll store the valid user id's as the index for easy validation
-- ===============================================================================================

type t_user  IS table of wsm_lot_job_interface.last_updated_by%type
                                                 index by binary_integer;
v_user t_user;


--  PROCEDURE DECLARATIONS  --

--**********************************************************************************************
PROCEDURE load_org_table;
--**********************************************************************************************
PROCEDURE load_subinventory;
--**********************************************************************************************
PROCEDURE load_class_code;
--**********************************************************************************************

END;

 

/
