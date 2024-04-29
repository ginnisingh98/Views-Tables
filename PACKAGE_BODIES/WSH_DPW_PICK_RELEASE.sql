--------------------------------------------------------
--  DDL for Package Body WSH_DPW_PICK_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DPW_PICK_RELEASE" AS
/* $Header: WSHDPPRB.pls 115.0 99/07/16 08:18:54 porting ship $ */


  --
  -- Name
  --   FUNCTION Launch_Pick_Release
  --
  -- Purpose
  --   This function launches Pick Release program from Departure
  --   Planning Workbench Form
  --   - It gets the default shipping parameters for Pick Release
  --   - Creates a Pickinmg Batch
  --   - Launches the Pick Release Concurrent Program
  --   - Places error messages in FND message stack
  --
  -- Arguments
  --   p_departure_id       - departure to release
  --   p_delivery           - delivery to release
  --   p_warehouse	    - warehouse to release from
  --   p_request_id
  --
  -- Return Values
  --   Request ID of concurrent program
  --
  --
  -- Notes
  --

  FUNCTION Launch_Pick_Release( p_departure_id IN  NUMBER,
				p_delivery_id  IN  NUMBER,
				p_warehouse_id IN  NUMBER) RETURN NUMBER IS

    v_rowid		VARCHAR2(100);
    v_batch_id		NUMBER;
    v_batch_name	VARCHAR2(30);
    v_document_set	NUMBER;
    v_rsr_id		NUMBER;
    v_psr_id		NUMBER;
    org_id_char1	VARCHAR2(30);
    org_found_flag	BOOLEAN;
    v_org_id		NUMBER;
    v_request_id	NUMBER;

  BEGIN

    -- Get shipping parameter for Release Sequence Rule, Pick Slip Grouping Rule
    -- and Default Document Set
    WSH_PARAMETERS_PVT.get_param_value_num(
			p_warehouse_id,
			'RELEASE_SEQ_RULE_ID',
			v_rsr_id);

    WSH_PARAMETERS_PVT.get_param_value_num(
			p_warehouse_id,
			'PICK_SLIP_RULE_ID',
			v_psr_id);

    WSH_PARAMETERS_PVT.get_param_value_num(
			p_warehouse_id,
			'PICK_RELEASE_REPORT_SET_ID',
			v_document_set);

    IF v_rsr_id = -1 THEN
      -- error no default release seq rule
      FND_MESSAGE.SET_NAME('OE','WSH_PARAM_RELEASE_SEQ_RULE');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF v_psr_id = -1 THEN
      -- error no default pic slip rule
      FND_MESSAGE.SET_NAME('OE','WSH_PARAM_PICK_SLIP_RULE');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF v_document_set = -1 THEN
      -- error no default document set
      FND_MESSAGE.SET_NAME('OE','WSH_PARAM_PICK_DOCUMENT_SET');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    -- Get operating unit for batch
    -- Fetch the current Operating Org . If no operating org was returned by
    -- the function below indicated by org_found_flag = FALSE, then we set the
    -- operating org to NULL , otherwise to its fetched value

    FND_PROFILE.GET_SPECIFIC( 'ORG_ID' , NULL , NULL , NULL , org_id_char1 , org_found_flag );
    IF org_found_flag = TRUE THEN
      v_org_id := to_number(org_id_char1);
    ELSE
      v_org_id := NULL;
    END IF;

    SHP_PICKING_BATCHES_PKG.Insert_Row(
			X_Rowid				=>	v_rowid,
			X_Batch_Id			=>	v_batch_id,
			X_Creation_Date			=>	NULL,
			X_Created_By			=>	NULL,
			X_Last_Update_Date		=>	NULL,
			X_Last_Updated_By		=>	NULL,
			X_Last_Update_Login		=>	NULL,
			X_Name				=>	v_batch_name,
			X_Backorders_Only_Flag		=> 	'I',
			X_Print_flag			=>	to_char(v_document_set),
			X_Existing_Rsvs_Only_Flag	=> 	'N',
			X_Shipment_Priority_Code	=>	NULL,
			X_Ship_Method_Code		=>	NULL,
			X_Customer_Id			=>	NULL,
			X_Group_Id			=>	NULL,
			X_Header_Count			=>	NULL,
			X_Header_Id			=>	NULL,
			X_Ship_Set_Number		=>	NULL,
			X_Inventory_Item_Id		=>	NULL,
			X_Order_Type_Id			=>	NULL,
			X_Date_Requested_From		=>	NULL,
			X_Date_Requested_To		=>	NULL,
			X_Scheduled_Shipment_Date_From	=>	NULL,
			X_Scheduled_Shipment_Date_To	=>	NULL,
			X_Site_Use_Id			=>	NULL,
			X_Warehouse_Id			=>	p_warehouse_id,
			X_Subinventory			=>	NULL,
			X_Date_Completed		=>	NULL,
			X_Date_Confirmed		=>	NULL,
			X_Date_Last_Printed		=>	NULL,
			X_Date_Released			=>	NULL,
			X_Date_Unreleased		=>	NULL,
			X_Departure_Id			=>	p_departure_id,
			X_Delivery_Id			=>	p_delivery_id,
			X_Include_Planned_Lines		=>	'N',
			X_Partial_Allowed_Flag		=>	'Y',
			X_Pick_Slip_Rule_Id		=>	v_psr_id,
			X_Release_Seq_Rule_Id		=>	v_rsr_id,
			X_Autocreate_Delivery_Flag	=>	'N',
			X_Context			=>	NULL,
			X_Attribute1			=>	NULL,
			X_Attribute2			=>	NULL,
			X_Attribute3			=>	NULL,
			X_Attribute4			=>	NULL,
			X_Attribute5			=>	NULL,
			X_Attribute6			=>	NULL,
			X_Attribute7			=>	NULL,
			X_Attribute8			=>	NULL,
			X_Attribute9			=>	NULL,
			X_Attribute10			=>	NULL,
			X_Attribute11			=>	NULL,
			X_Attribute12			=>	NULL,
			X_Attribute13			=>	NULL,
			X_Attribute14			=>	NULL,
			X_Attribute15			=>	NULL,
			X_Error_Report_Flag		=>	NULL,
			X_Org_Id			=>	v_org_id);



    v_request_id := SHP_PICKING_BATCHES_PKG.Submit_Release_Request(v_batch_id);

    RETURN v_request_id;

  END Launch_Pick_Release;

END WSH_DPW_PICK_RELEASE;

/
