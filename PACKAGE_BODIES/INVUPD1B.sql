--------------------------------------------------------
--  DDL for Package Body INVUPD1B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVUPD1B" AS -- {
/* $Header: INVUPD1B.pls 120.23.12010000.11 2010/04/21 11:05:22 ccsingh ship $ */
-- Values used in IOI to indicate an attribute update to NULL.
--
g_Upd_Null_CHAR     VARCHAR2(1)  :=  '!';
g_Upd_Null_NUM      NUMBER       :=  -999999;
g_Upd_Null_DATE     DATE         :=  NULL;

-- FND null value sets
g_FND_Upd_Null_NUM      NUMBER       :=  9.99E125;
g_FND_Upd_Null_Char     VARCHAR2(1)  :=  chr(0);

--2808277 Start supporting Item Revision Update
FUNCTION assign_item_rev_data_update(
	org_id		NUMBER,
	all_org		NUMBER		:= 2,
	prog_appid	NUMBER		:= -1,
	prog_id		NUMBER		:= -1,
	request_id	NUMBER		:= -1,
	user_id		NUMBER		:= -1,
	login_id	   NUMBER		:= -1,
	err_text IN OUT NOCOPY VARCHAR2,
	xset_id  IN	NUMBER		DEFAULT -999)
RETURN  NUMBER;
--2808277 End supporting Item Revision Update

FUNCTION mtl_pr_assign_item_data_update(
	org_id		NUMBER,
	all_org		NUMBER		:= 2,
	prog_appid	NUMBER		:= -1,
	prog_id		NUMBER		:= -1,
	request_id	NUMBER		:= -1,
	user_id		NUMBER		:= -1,
	login_id	   NUMBER		:= -1,
	err_text IN OUT NOCOPY VARCHAR2,
	xset_id  IN	NUMBER		DEFAULT -999) RETURN  INTEGER IS

   CURSOR C_msii_records IS
	   SELECT	ROWID, intf.*
	   FROM  mtl_system_items_interface intf
	   WHERE intf.process_flag   = 1
	   AND   intf.set_process_id = xset_id
	   AND ((intf.organization_id = org_id) or (all_org = 1));

	CURSOR C_status_controlled_attr(cp_item_status_code VARCHAR2) IS
	   SELECT status.attribute_name
            ,status.attribute_value
	   FROM   mtl_status_attribute_values status
            ,mtl_item_attributes ctrl
	   WHERE  status.attribute_name = ctrl.attribute_name
      AND    status.inventory_item_status_code = cp_item_status_code
      AND    ctrl.status_control_code = 1;

   --Added for Bug 4366615
 	CURSOR	C_puom_records IS
 	   SELECT Primary_Unit_Of_Measure, ROWID
      FROM	 Mtl_System_Items_Interface
 	   WHERE	 Process_Flag = 1
 	   AND	 Set_Process_Id = xset_id
 	   AND	((organization_id = org_id) or (all_org = 1))
 	   FOR	UPDATE OF Primary_Uom_Code;
   -- End of Bug 4366615

   ret_code             NUMBER  := 0;
   rtn_status           NUMBER  := 0;
	error_text		      VARCHAR2(250);
	dumm_status		      NUMBER;
	status_code		      NUMBER;
	t_trans_id		      NUMBER;
	t_organization_id	   NUMBER;
	t_inventory_item_id	NUMBER;
	t_template_id		   VARCHAR2(30)	 DEFAULT null;
   msi_primary_uom      VARCHAR2(26)    DEFAULT null;
	msi_eng_item_flag	   VARCHAR2(1)	    DEFAULT null;
   msi_inventory_item_status_code    VARCHAR2(20) DEFAULT NULL;

	ASS_ITEM_ERR		   EXCEPTION;
	attr_err_mesg_name	VARCHAR2(30)    DEFAULT null;
	upd_status		      NUMBER		    DEFAULT 1;

   --Added for Bug 4366615
   temp_uom_code		   VARCHAR2(3);
	msi_primary_uom_code	VARCHAR2(3);
   --End of Bug 4366615

   msi_tracking_quantity_ind   mtl_system_items.tracking_quantity_ind%TYPE;
   msi_secondary_uom_code      mtl_system_items.secondary_uom_code%TYPE;
   msi_secondary_default_ind   mtl_system_items.secondary_default_ind%TYPE;
   msi_ont_pricing_qty_source  mtl_system_items.ont_pricing_qty_source%TYPE;
   msi_dual_uom_deviation_high mtl_system_items.dual_uom_deviation_high%TYPE;
   msi_dual_uom_deviation_low  mtl_system_items.dual_uom_deviation_low%TYPE;

	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452


BEGIN -- {

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD1B.mtl_pr_assign_item_data_update: begin org_id=' || TO_CHAR(org_id));
   END IF;

   -- Added for Bug 4366615
	FOR puom IN C_puom_records LOOP
	   BEGIN
		   IF puom.Primary_Unit_of_Measure IS NOT NULL THEN
			   SELECT Uom_Code
			   INTO   temp_uom_code
	         FROM   Mtl_Units_Of_Measure
		      WHERE  Unit_Of_Measure = puom.Primary_Unit_Of_Measure --Bug 5192495
			   AND    SYSDATE < nvl(Disable_Date, SYSDATE+1);

			   UPDATE Mtl_System_Items_Interface
			   SET	  Primary_Uom_Code = temp_uom_code
			   WHERE  Rowid = puom.Rowid;
		   END IF;
      EXCEPTION
		   WHEN NO_DATA_FOUND THEN
            dumm_status := INVPUOPI.mtl_log_interface_err(
                       t_organization_id,
                       user_id,
                       login_id,
                       prog_appid,
                       prog_id,
                       request_id,
                       t_trans_id,
                       error_text,
                       'PRIMARY_UNIT_OF_MEASURE',
                       'MTL_SYSTEM_ITEMS_INTERFACE',
                       'INV_IOI_PRIMARY_UOM',
                       err_text);
		      dumm_status := INVUPD2B.set_process_flag3(puom.ROWID,user_id,login_id,prog_appid,prog_id,request_id);
		 END;
	 END LOOP;
    --End of Bug 4366615

	FOR rec IN C_msii_records LOOP -- {
	   t_organization_id   := rec.organization_id;
		t_inventory_item_id := rec.inventory_item_id;
		t_trans_id          := rec.transaction_id;

      -- Start 2913856
      --Jalaj Srivastava Bug 5017588
      --update of uom fields not allowed.

      BEGIN
         SELECT msi.primary_unit_of_measure,
		msi.eng_item_flag,
                msi.primary_uom_code,	--* Added for Bug 4366615
                msi.inventory_item_status_code,
                msi.tracking_quantity_ind,
                msi.secondary_uom_code,
                msi.secondary_default_ind,
                msi.ont_pricing_qty_source,
                msi.dual_uom_deviation_high,
                msi.dual_uom_deviation_low
         INTO   msi_primary_uom,
		msi_eng_item_flag,
                msi_primary_uom_code,	--* Added for Bug 4366615
                msi_inventory_item_status_code,
                msi_tracking_quantity_ind,
                msi_secondary_uom_code,
                msi_secondary_default_ind,
                msi_ont_pricing_qty_source,
                msi_dual_uom_deviation_high,
                msi_dual_uom_deviation_low
         FROM   mtl_system_items_B msi
         WHERE  msi.inventory_item_id = t_inventory_item_id
         AND    msi.organization_id   = t_organization_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
		      NULL;
      END;
		-- End 291385

        /* Added to convert '!' to NULL before validations as by this point it will not get converter and never go in to IF condition
        Even if we psas NULL that too converted to '!' during insert_into_MSII*/
       -- bug 9548336

      SELECT Decode (rec.ENG_ITEM_FLAG,g_Upd_Null_CHAR,NULL,rec.ENG_ITEM_FLAG),
             Decode (rec.PRIMARY_UOM_CODE,g_Upd_Null_CHAR,NULL,rec.PRIMARY_UOM_CODE),
             Decode (rec.tracking_quantity_ind,g_Upd_Null_CHAR,NULL,rec.tracking_quantity_ind),
             Decode (rec.secondary_uom_code,g_Upd_Null_CHAR,NULL,rec.secondary_uom_code),
             Decode (rec.secondary_default_ind,g_Upd_Null_CHAR,NULL,rec.secondary_default_ind),
             Decode (rec.ont_pricing_qty_source,g_Upd_Null_CHAR,NULL,rec.ont_pricing_qty_source),
             Decode (rec.dual_uom_deviation_high,g_Upd_Null_CHAR,NULL,rec.dual_uom_deviation_high),
             Decode (rec.dual_uom_deviation_low,g_Upd_Null_CHAR,NULL,rec.dual_uom_deviation_low)
      INTO  rec.ENG_ITEM_FLAG,rec.PRIMARY_UOM_CODE,rec.tracking_quantity_ind, rec.secondary_uom_code,rec.secondary_default_ind,
            rec.ont_pricing_qty_source, rec.dual_uom_deviation_high, rec.dual_uom_deviation_low
      FROM dual;

		-- if any of the non-updateable fields are being updated [ENG_ITEM_FLAG and PRIMARY_UOM]
	   IF (rec.MATERIAL_COST               IS NULL
          AND rec.MATERIAL_SUB_ELEM       IS NULL
          AND rec.MATERIAL_OH_RATE        IS NULL
          AND rec.MATERIAL_OH_SUB_ELEM    IS NULL
          AND rec.MATERIAL_SUB_ELEM_ID    IS NULL
          AND rec.MATERIAL_OH_SUB_ELEM_ID IS NULL)
      THEN

		   IF (rec.ENG_ITEM_FLAG IS NULL OR rec.ENG_ITEM_FLAG = msi_eng_item_flag)
            AND (rec.PRIMARY_UOM_CODE IS NULL OR rec.primary_uom_code  = msi_primary_uom_code)
            --Jalaj Srivastava Bug 5017588
            --all uom fields are non updateable
            AND (rec.tracking_quantity_ind   IS NULL OR rec.tracking_quantity_ind   = msi_tracking_quantity_ind   )
            AND (rec.secondary_uom_code      IS NULL OR rec.secondary_uom_code      = msi_secondary_uom_code      )
            AND (rec.secondary_default_ind   IS NULL OR rec.secondary_default_ind   = msi_secondary_default_ind   )
            AND (rec.ont_pricing_qty_source  IS NULL OR rec.ont_pricing_qty_source  = msi_ont_pricing_qty_source  )
            AND (rec.dual_uom_deviation_high IS NULL OR rec.dual_uom_deviation_high = msi_dual_uom_deviation_high )
            AND (rec.dual_uom_deviation_low  IS NULL OR rec.dual_uom_deviation_low  = msi_dual_uom_deviation_low  )
         THEN

	      status_code := 1;
      	      /* Bug 4751471  Status Controlled attrs are relevantly updated when status is applied. Eliminating this chk
		      BEGIN -- {

			      -- if status controlled attributes are not being modified
			      IF NOT (rec.STOCK_ENABLED_FLAG                 IS NULL
                       AND rec.MTL_TRANSACTIONS_ENABLED_FLAG  IS NULL
                       AND	rec.PURCHASING_ENABLED_FLAG        IS NULL
                       AND	rec.BUILD_IN_WIP_FLAG              IS NULL
                       AND	rec.CUSTOMER_ORDER_ENABLED_FLAG    IS NULL
                       AND	rec.INTERNAL_ORDER_ENABLED_FLAG    IS NULL
                       AND	rec.BOM_ENABLED_FLAG               IS NULL
                       AND	rec.INVOICE_ENABLED_FLAG           IS NULL
                       AND	rec.RECIPE_ENABLED_FLAG            IS NULL
                       AND	rec.PROCESS_EXECUTION_ENABLED_FLAG IS NULL)
               THEN -- {

                  -- Start 2913856 Changed is not null to <>
                  --4751471 : Status attributes under sets control
                  --Values passed in the interface table should be compared against status setup not against msb db value.
				      FOR srec IN C_status_controlled_attr(nvl(rec.inventory_item_status_code,msi_inventory_item_status_code)) LOOP -- {
					      IF((srec.attribute_name = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG'
                            AND NVL(rec.STOCK_ENABLED_FLAG,srec.attribute_value)              <> srec.attribute_value)
					         OR (srec.attribute_name = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG'
                            AND NVL(rec.MTL_TRANSACTIONS_ENABLED_FLAG,srec.attribute_value)   <>  srec.attribute_value)
					         OR (srec.attribute_name = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG'
					               AND NVL(rec.PURCHASING_ENABLED_FLAG,srec.attribute_value)       <> srec.attribute_value)
					         OR (srec.attribute_name = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG'
					               AND NVL(rec.BUILD_IN_WIP_FLAG,srec.attribute_value)             <> srec.attribute_value)
					         OR (srec.attribute_name = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG'
					               AND NVL(rec.CUSTOMER_ORDER_ENABLED_FLAG,srec.attribute_value)   <> srec.attribute_value)
					         OR (srec.attribute_name = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG'
					               AND NVL(rec.INTERNAL_ORDER_ENABLED_FLAG,srec.attribute_value)   <> srec.attribute_value)
					         OR (srec.attribute_name = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG'
					               AND NVL(rec.BOM_ENABLED_FLAG,srec.attribute_value)              <> srec.attribute_value)
					         OR (srec.attribute_name = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG'
					               AND NVL(rec.INVOICE_ENABLED_FLAG,srec.attribute_value)          <> srec.attribute_value)
	                     OR (srec.attribute_name = 'MTL_SYSTEM_ITEMS.RECIPE_ENABLED_FLAG'
					               AND NVL(rec.RECIPE_ENABLED_FLAG,srec.attribute_value)           <> srec.attribute_value)
					         OR (srec.attribute_name = 'MTL_SYSTEM_ITEMS.PROCESS_EXECUTION_ENABLED_FLAG'
					              AND NVL(rec.PROCESS_EXECUTION_ENABLED_FLAG,srec.attribute_value) <> srec.attribute_value))
				         THEN -- {
					         status_code := 0;
					      END IF; -- }
					      -- exit when first status controlled attribute is found not to be null
					      EXIT WHEN status_code = 0;
				      END LOOP; -- }
				      --End 2913856
			      END IF; -- }
		      EXCEPTION
		         WHEN NO_DATA_FOUND THEN
		            NULL;  -- no status controlled attributes
      		END; -- }

			   IF (status_code = 1) THEN -- { */
				   -- check if an attribute that should not be updated if onhand qties exist is being updated
				   IF NOT (rec.LOCATION_CONTROL_CODE          IS NULL
                       AND	rec.LOT_CONTROL_CODE           IS NULL
                       AND	rec.REVISION_QTY_CONTROL_CODE  IS NULL
                       AND	rec.SERIAL_NUMBER_CONTROL_CODE IS NULL
                       AND	rec.SHELF_LIFE_CODE            IS NULL
                       AND	rec.COSTING_ENABLED_FLAG       IS NULL
                       AND	rec.INVENTORY_ASSET_FLAG       IS NULL )
               THEN -- {
					   -- if onhand quantities exist or transactions pending then
					   IF (INVUPD1B.exists_onhand_quantities(t_organization_id, t_inventory_item_id)     <> 1
					      AND INVUPD1B.exists_onhand_child_qties(t_organization_id, t_inventory_item_id) <> 1 )
                  THEN -- {
						   -- copy msi data to msii record for ``missing'' attributes, also set process_	flag = 2
						   dumm_status := INVUPD1B.copy_msi_to_msii(rec.rowid,t_organization_id, t_inventory_item_id);
                     rtn_status  := INVPULI4.assign_status_attributes(rec.inventory_item_id,rec.organization_id,err_text,xset_id,rec.rowid);
        					IF rtn_status = 0 THEN
               		   status_code := 1;
              			ELSE
             				status_code := 0;
             			END IF;

 					   ELSE -- } {
					      -- Check for dependencies of attributes being updated
					      upd_status := INVUPD1B.mtl_validate_attr_upd(
            			                       		rec.organization_id,
            		                        		rec.inventory_item_id,
								                        rec.rowid,
								                        attr_err_mesg_name);

			            IF upd_status <> 0 THEN --{
			               -- At least one attribute failed the dependency check.
                			-- Flag error that on-hand qties exist and related
               			-- non-updateable attribute is being updated.
			               upd_status  := INVPUOPI.mtl_log_interface_err(
								                     t_organization_id,
                                          	user_id,
                                          	login_id,
                                          	prog_appid,
                                          	prog_id,
                                          	request_id,
                                          	t_trans_id,
                                          	error_text,
                                          	null,
                                          	'MTL_SYSTEM_ITEMS_INTERFACE',
                                          	attr_err_mesg_name,
                                          	err_text);

						      upd_status := INVUPD2B.set_process_flag3(rec.ROWID,user_id,login_id,prog_appid,prog_id,request_id);
					      ELSE
						      dumm_status := INVUPD1B.copy_msi_to_msii(rec.rowid,t_organization_id,t_inventory_item_id);
            		      rtn_status  := INVPULI4.assign_status_attributes(rec.inventory_item_id,rec.organization_id,err_text,xset_id,rec.rowid);
            			   IF rtn_status = 0 THEN
               				status_code := 1;
              				ELSE
             				    status_code := 0;
             				END IF;
					      END IF; --}
				      END IF; -- }
				   ELSE	-- no onhand qties exist and no transactions pending  -- } {
					   -- copy msi data to msii record for ``missing'' attributes, also set process_flag = 2
					   dumm_status := INVUPD1B.copy_msi_to_msii(rec.rowid, t_organization_id, t_inventory_item_id);
                  rtn_status  := INVPULI4.assign_status_attributes(rec.inventory_item_id,rec.organization_id,err_text,xset_id,rec.rowid);
        			   IF rtn_status = 0 THEN
           				status_code := 1;
        				ELSE
       				    status_code := 0;
        				END IF;
             END IF; -- }
    /*    Bug 4751471 - Status Controlled attrs are relevantly updated when status is applied. Eliminating chk
			  ELSE -- } {
			     -- flag error that status controlled attribute is being modified  and move to next record
				  dumm_status  := INVPUOPI.mtl_log_interface_err(
                                       	t_organization_id,
                                       	user_id,
                                       	login_id,
                                       	prog_appid,
                                       	prog_id,
                                       	request_id,
                                       	t_trans_id,
                                       	error_text,
                                       	null,
                                       	'MTL_SYSTEM_ITEMS_INTERFACE',
                                       	'INV_STATUS_CNTRL_ATTRIB_ERROR',
                                       	err_text);
				  dumm_status := INVUPD2B.set_process_flag3(rec.ROWID,user_id,login_id,prog_appid,prog_id,request_id);
			  END IF; -- } */
		  ELSE -- } {
		     -- flag error that non-updateable fields are being updated and move to next record
			  dumm_status  := INVPUOPI.mtl_log_interface_err(
                                    	t_organization_id,
                                    	user_id,
                                    	login_id,
                                    	prog_appid,
                                    	prog_id,
                                    	request_id,
                                    	t_trans_id,
                                    	error_text,
                                    	null,
                                    	'MTL_SYSTEM_ITEMS_INTERFACE',
                                    	'INV_NON_UPDATE_ATTRIBUTE_ERROR',
                                    	err_text);
			  dumm_status := INVUPD2B.set_process_flag3(rec.ROWID,user_id,login_id,prog_appid,prog_id,request_id);
		  END IF; -- }
     ELSE -- } {
	     -- flag error that costing related fields are being updated and move to next record
		  dumm_status  := INVPUOPI.mtl_log_interface_err(
                                 	t_organization_id,
                                 	user_id,
                                 	login_id,
                                 	prog_appid,
                                 	prog_id,
                                 	request_id,
                                 	t_trans_id,
                                 	error_text,
                                 	null,
                                 	'MTL_SYSTEM_ITEMS_INTERFACE',
                                 	'INV_NON_UPDATE_ATTR_ERROR2',
                                 	err_text);
		  dumm_status := INVUPD2B.set_process_flag3(rec.ROWID,user_id,login_id,prog_appid,prog_id,request_id);
	  END IF; -- }
  END LOOP;	-- MSII LOOP  -- }

  --2808277 Start supporting Item Revision Update
  rtn_status := assign_item_rev_data_update(
				 org_id	    => org_id
				,all_org    => all_org
				,prog_appid => prog_appid
				,prog_id    => prog_id
				,request_id => request_id
				,user_id    => user_id
				,login_id   => login_id
				,err_text   => err_text
				,xset_id    => xset_id);

	IF (rtn_status <> 0) THEN
           dumm_status := INVPUOPI.mtl_log_interface_err (
                                -1,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                -1,
                                '*** BAD RETURN CODE e ***' || err_text,
                                null,
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_ERR',
                                err_text);
	  ret_code := rtn_status;

	END IF;
   --2808277 End supporting Item Revision Update

	return (ret_code);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
		dumm_status  := INVPUOPI.mtl_log_interface_err(
				t_organization_id,
				user_id,
				login_id,
				prog_appid,
				prog_id,
				request_id,
				t_trans_id,
				error_text,
				null,
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_RECORD_NOT_FOUND_ERROR',
				err_text);
      RETURN (1);
   WHEN OTHERS THEN
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD1B.mtl_pr_assign_item_data_update: when OTHERS exception');
      END IF;
      RETURN (1);
      -- any other error other than no data found ?
END mtl_pr_assign_item_data_update; -- }

--
-- Function to check for attribute dependencies impacted by on-hand quantites.
--

FUNCTION mtl_validate_attr_upd
(
   org_id		IN  NUMBER
,  item_id              IN  NUMBER
,  row_id		IN  ROWID
,  attr_err_mesg_name   OUT NOCOPY VARCHAR2
)
RETURN  INTEGER
IS


cursor msii_attr is
select  LOCATION_CONTROL_CODE,
	LOT_CONTROL_CODE,
	REVISION_QTY_CONTROL_CODE,
	SERIAL_NUMBER_CONTROL_CODE,
	SHELF_LIFE_CODE,
	COSTING_ENABLED_FLAG,
	INVENTORY_ASSET_FLAG,
	RESTRICT_LOCATORS_CODE,
	AUTO_SERIAL_ALPHA_PREFIX,
	START_AUTO_SERIAL_NUMBER,
	/* Start Bug 3713912 */
	SECONDARY_UOM_CODE ,
	TRACKING_QUANTITY_IND,
	SECONDARY_DEFAULT_IND,
	DUAL_UOM_DEVIATION_HIGH,
        DUAL_UOM_DEVIATION_LOW
	/* End Bug 3713912 */
  from  MTL_SYSTEM_ITEMS_INTERFACE
where  rowid = row_id;

cursor msi_attr is
select  LOCATION_CONTROL_CODE,
	LOT_CONTROL_CODE,
	REVISION_QTY_CONTROL_CODE,
	SERIAL_NUMBER_CONTROL_CODE,
	SHELF_LIFE_CODE,
	COSTING_ENABLED_FLAG,
	INVENTORY_ASSET_FLAG,
	RESTRICT_LOCATORS_CODE,
	AUTO_SERIAL_ALPHA_PREFIX,  -- Bug #1402402
	START_AUTO_SERIAL_NUMBER,   -- Bug #1402402
	/* Start Bug 3713912 */
	SECONDARY_UOM_CODE ,
	TRACKING_QUANTITY_IND,
	SECONDARY_DEFAULT_IND,
	DUAL_UOM_DEVIATION_HIGH,
        DUAL_UOM_DEVIATION_LOW
	/* End Bug 3713912 */
  from  MTL_SYSTEM_ITEMS
where  inventory_item_id = item_id
  and  organization_id = org_id;

msii_rec msii_attr%rowtype;
msi_rec  msi_attr%rowtype;
attrib_error	exception;
attr_noerr_flg number;

	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

BEGIN --{

	attr_noerr_flg := 0;
	open msii_attr;
	fetch msii_attr into msii_rec;
	open msi_attr;
	fetch msi_attr into msi_rec;

-- Location Control Code

if msii_rec.location_control_code is not null then --{

	if msi_rec.location_control_code = 1 then
		if msii_rec.location_control_code = 1 then
 			attr_noerr_flg := 0;
		elsif msii_rec.location_control_code in (2,3) then
			attr_err_mesg_name := 'INV_IOI_LOC_CTRL_CODE_UPD_QOH';
			raise attrib_error;
		end if;
	elsif msi_rec.location_control_code = 2 then
		if msii_rec.location_control_code = 1 then
			attr_err_mesg_name := 'INV_IOI_LOC_CTRL_CODE_UPD_QOH';
 			raise attrib_error;
		elsif msii_rec.location_control_code = 2 then
 			attr_noerr_flg := 0;
		elsif msii_rec.location_control_code = 3 then
			if msi_rec.restrict_locators_code = 1 then
				attr_err_mesg_name := 'INV_IOI_LOC_CTRL_CODE_UPD_QOH';
				raise attrib_error;
			elsif msi_rec.restrict_locators_code = 2 then
				attr_noerr_flg := 0;
 			end if;
		end if;
	elsif msi_rec.location_control_code = 3 then
		if msii_rec.location_control_code = 1 then
			attr_err_mesg_name := 'INV_IOI_LOC_CTRL_CODE_UPD_QOH';
 			raise attrib_error;
		elsif msii_rec.location_control_code = 2 then
 			attr_noerr_flg := 0;
		elsif msii_rec.location_control_code = 3 then
			attr_noerr_flg := 0;
		end if;
	end if;

end if; --}

-- end Location Control Code

-- Lot Control Code
if msii_rec.lot_control_code is not null then --{
           if msi_rec.lot_control_code = msii_rec.lot_control_code then
                 	attr_noerr_flg := 0;
           else
  		attr_err_mesg_name := 'INV_IOI_LOT_CTRL_CODE_UPD_QOH';
  		raise attrib_error;
           end if;
end if; --}
-- End Lot Control Code

-- Revision Qty Control Code
if msii_rec.revision_qty_control_code is not null then --{
         if msi_rec.Revision_qty_control_code = msii_rec.Revision_qty_control_code then
               attr_noerr_flg := 0;
         else
               attr_err_mesg_name := 'INV_IOI_REV_QTY_CTRL_UPD_QOH';
               raise attrib_error;
         end if;
end if; --}
-- End Revision qty control code

-- Serial Number Control Code
if msii_rec.serial_number_control_code is not null then --{
	if msi_rec.serial_number_control_code = 1 then
		if msii_rec.serial_number_control_code  in (1,6) then  -- Bug 1402402
			attr_noerr_flg := 0;
		else
               		attr_err_mesg_name := 'INV_IOI_SRL_NUM_CTRL_UPD_QOH';
			raise attrib_error;
                end if;
/*	elsif msii_rec.serial_number_control_code = 6 then
			if (msii_rec.auto_serial_alpha_prefix is null and
			   msii_rec.start_auto_serial_number is null) then
				attr_err_mesg_name := 'INV_AUTO_SERIAL_PREFIX';
				raise attrib_error;
			else
				attr_noerr_flg := 0;
			end if;
		else
               		attr_err_mesg_name := 'INV_IOI_SRL_NUM_CTRL_UPD_QOH';
			raise attrib_error;
                end if;
*/  -- Commented for Bug 1402402
	elsif msi_rec.serial_number_control_code = 2 then
		if msii_rec.serial_number_control_code in (2,5) then
			attr_noerr_flg := 0;
		else
                 	attr_err_mesg_name := 'INV_IOI_SRL_NUM_CTRL_UPD_QOH';
			raise attrib_error;
                end if;
	elsif msi_rec.serial_number_control_code = 5 then
		if msii_rec.serial_number_control_code = 5 then    -- Bug 1402402
			attr_noerr_flg := 0;
                elsif msii_rec.serial_number_control_code = 2  then   -- Added for Bug 1402402
			if (msii_rec.auto_serial_alpha_prefix is null or
			   msii_rec.start_auto_serial_number is null) then
				attr_err_mesg_name := 'INV_AUTO_SERIAL_PREFIX';
				raise attrib_error;
			else
				attr_noerr_flg := 0;
			end if;
		else
                 	attr_err_mesg_name := 'INV_IOI_SRL_NUM_CTRL_UPD_QOH';
			raise attrib_error;
                end if;
	elsif msi_rec.serial_number_control_code = 6 then
		if msii_rec.serial_number_control_code in (1,6) then
			attr_noerr_flg := 0;
		else
                 	attr_err_mesg_name := 'INV_IOI_SRL_NUM_CTRL_UPD_QOH';
			raise attrib_error;
                end if;
	end if;
end if; --}
-- End Serial Number Control Code

-- Shelf Life Code
if msii_rec.shelf_life_code is not null then --{
	if msi_rec.shelf_life_code = 1 then
		if msii_rec.shelf_life_code = 1 then
			attr_noerr_flg := 0;
                else
                 	attr_err_mesg_name := 'INV_IOI_SHLF_LIF_CODE_UPD_QOH';
			raise attrib_error;
		end if;
	elsif msi_rec.shelf_life_code in (2,4) then
		if msii_rec.shelf_life_code = 1 then
                 	attr_err_mesg_name := 'INV_IOI_SHLF_LIF_CODE_UPD_QOH';
			raise attrib_error;
		elsif msii_rec.shelf_life_code in ( 2,4) then
			attr_noerr_flg := 0;
		end if;
	end if;
end if; --}
-- end shelf life code

-- Inventory Asset Flag
if msii_rec.inventory_asset_flag is not null then --{
         if msi_rec.inventory_asset_flag = msii_rec.inventory_asset_flag then
               attr_noerr_flg := 0;
         else
               attr_err_mesg_name := 'INV_IOI_INV_ASST_FLG_UPD_QOH';
               raise attrib_error;
         end if;
end if; --}
-- End Inventory Asset Flag

-- Costing Enabled Flag
if msii_rec.costing_enabled_flag is not null then --{
         if msi_rec.costing_enabled_flag = msii_rec.costing_enabled_flag then
               attr_noerr_flg := 0;
         else
               attr_err_mesg_name := 'INV_IOI_COST_ENBL_FLG_UPD_QOH';
               raise attrib_error;
         end if;
end if; --}
-- End Costing Enabled Flag

/* Start Bug 3713912 */
-- Tracking Quantity Indicator
if msii_rec.TRACKING_QUANTITY_IND is not null then --{
         if msi_rec.TRACKING_QUANTITY_IND = msii_rec.TRACKING_QUANTITY_IND then
               attr_noerr_flg := 0;
         else
               attr_err_mesg_name := 'INV_IOI_TRCK_QTY_IND_UPD_QOH';
               raise attrib_error;
         end if;
end if; --}
-- Tracking Quantity Indicator

-- Secondary Default Indicator
if msii_rec.SECONDARY_DEFAULT_IND is not null then --{
         if msi_rec.SECONDARY_DEFAULT_IND = msii_rec.SECONDARY_DEFAULT_IND then
               attr_noerr_flg := 0;
         else
               attr_err_mesg_name := 'INV_IOI_SEC_DFLT_IND_UPD_QOH';
               raise attrib_error;
         end if;
end if; --}
-- Secondary Default Indicator

-- Secondary UOM Code
if msii_rec.SECONDARY_UOM_CODE is not null then --{
         if msi_rec.SECONDARY_UOM_CODE = msii_rec.SECONDARY_UOM_CODE then
               attr_noerr_flg := 0;
         else
               attr_err_mesg_name := 'INV_IOI_SEC_UOM_CODE_UPD_QOH';
               raise attrib_error;
         end if;
end if; --}
-- Secondary UOM Code

-- Dual UOM Deviation High
if msii_rec.DUAL_UOM_DEVIATION_HIGH is not null then --{
         if msi_rec.DUAL_UOM_DEVIATION_HIGH = msii_rec.DUAL_UOM_DEVIATION_HIGH then
               attr_noerr_flg := 0;
         else
               attr_err_mesg_name := 'INV_IOI_DUAL_HI_DEV_UPD_QOH';
               raise attrib_error;
         end if;
end if; --}
-- Dual UOM Deviation High

-- Dual UOM Deviation Low
if msii_rec.DUAL_UOM_DEVIATION_LOW is not null then --{
         if msi_rec.DUAL_UOM_DEVIATION_LOW = msii_rec.DUAL_UOM_DEVIATION_LOW then
               attr_noerr_flg := 0;
         else
               attr_err_mesg_name := 'INV_IOI_DUAL_LOW_DEV_UPD_QOH';
               raise attrib_error;
         end if;
end if; --}
-- Dual UOM Deviation Low
/* End Bug 3713912 */
  return attr_noerr_flg;
	close msi_attr;
	close msii_attr;

exception

	when attrib_error then
	close msi_attr;
	close msii_attr;
	  return 1;
	when OTHERS then
	IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('when OTHERS exception raised in mtl_validate_attr_upd');
	END IF;
 	close msi_attr;
	close msii_attr;
	  return 1;

END mtl_validate_attr_upd; --}


FUNCTION chk_exist_copy_template_attr
(
	org_id		NUMBER,
	all_org		NUMBER		:= 2,
	prog_appid	NUMBER		:= -1,
	prog_id		NUMBER		:= -1,
	request_id	NUMBER		:= -1,
	user_id		NUMBER		:= -1,
	login_id	NUMBER		:= -1,
	err_text IN OUT NOCOPY VARCHAR2,
	xset_id  IN	NUMBER		DEFAULT -999
)
RETURN INTEGER
IS
	CURSOR C_msii_records is
	select
	ROWID,
	INVENTORY_ITEM_ID,
	ORGANIZATION_ID,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
	SUMMARY_FLAG,
	ENABLED_FLAG,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE,
	DESCRIPTION,
	BUYER_ID,
	ACCOUNTING_RULE_ID,
	INVOICING_RULE_ID,
	SEGMENT1,
	SEGMENT2,
	SEGMENT3,
	SEGMENT4,
	SEGMENT5,
	SEGMENT6,
	SEGMENT7,
	SEGMENT8,
	SEGMENT9,
	SEGMENT10,
	SEGMENT11,
	SEGMENT12,
	SEGMENT13,
	SEGMENT14,
	SEGMENT15,
	SEGMENT16,
	SEGMENT17,
	SEGMENT18,
	SEGMENT19,
	SEGMENT20,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
        GLOBAL_ATTRIBUTE_CATEGORY,
        GLOBAL_ATTRIBUTE1,
        GLOBAL_ATTRIBUTE2,
        GLOBAL_ATTRIBUTE3,
        GLOBAL_ATTRIBUTE4,
        GLOBAL_ATTRIBUTE5,
        GLOBAL_ATTRIBUTE6,
        GLOBAL_ATTRIBUTE7,
        GLOBAL_ATTRIBUTE8,
        GLOBAL_ATTRIBUTE9,
        GLOBAL_ATTRIBUTE10,
        GLOBAL_ATTRIBUTE11,
        GLOBAL_ATTRIBUTE12,
        GLOBAL_ATTRIBUTE13,
        GLOBAL_ATTRIBUTE14,
        GLOBAL_ATTRIBUTE15,
        GLOBAL_ATTRIBUTE16,
        GLOBAL_ATTRIBUTE17,
        GLOBAL_ATTRIBUTE18,
        GLOBAL_ATTRIBUTE19,
        GLOBAL_ATTRIBUTE20,
	PURCHASING_ITEM_FLAG,
	SHIPPABLE_ITEM_FLAG,
	CUSTOMER_ORDER_FLAG,
	INTERNAL_ORDER_FLAG,
      -- SERVICE_ITEM_FLAG,
	INVENTORY_ITEM_FLAG,
	ENG_ITEM_FLAG,
	INVENTORY_ASSET_FLAG,
	PURCHASING_ENABLED_FLAG,
	CUSTOMER_ORDER_ENABLED_FLAG,
	INTERNAL_ORDER_ENABLED_FLAG,
	SO_TRANSACTIONS_FLAG,
	MTL_TRANSACTIONS_ENABLED_FLAG,
	STOCK_ENABLED_FLAG,
	BOM_ENABLED_FLAG,
	BUILD_IN_WIP_FLAG,
	REVISION_QTY_CONTROL_CODE,
	ITEM_CATALOG_GROUP_ID,
	CATALOG_STATUS_FLAG,
	RETURNABLE_FLAG,
	DEFAULT_SHIPPING_ORG,
	COLLATERAL_FLAG,
	TAXABLE_FLAG,
	PURCHASING_TAX_CODE,
	QTY_RCV_EXCEPTION_CODE,
	ALLOW_ITEM_DESC_UPDATE_FLAG,
	INSPECTION_REQUIRED_FLAG,
	RECEIPT_REQUIRED_FLAG,
	MARKET_PRICE,
	HAZARD_CLASS_ID,
	RFQ_REQUIRED_FLAG,
	QTY_RCV_TOLERANCE,
	LIST_PRICE_PER_UNIT,
	UN_NUMBER_ID,
	PRICE_TOLERANCE_PERCENT,
	ASSET_CATEGORY_ID,
	ROUNDING_FACTOR,
	UNIT_OF_ISSUE,
	ENFORCE_SHIP_TO_LOCATION_CODE,
	ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
	ALLOW_UNORDERED_RECEIPTS_FLAG,
	ALLOW_EXPRESS_DELIVERY_FLAG,
	DAYS_EARLY_RECEIPT_ALLOWED,
	DAYS_LATE_RECEIPT_ALLOWED,
	RECEIPT_DAYS_EXCEPTION_CODE,
	RECEIVING_ROUTING_ID,
	INVOICE_CLOSE_TOLERANCE,
	RECEIVE_CLOSE_TOLERANCE,
	AUTO_LOT_ALPHA_PREFIX,
	START_AUTO_LOT_NUMBER,
	LOT_CONTROL_CODE,
	SHELF_LIFE_CODE,
	SHELF_LIFE_DAYS,
	SERIAL_NUMBER_CONTROL_CODE,
	START_AUTO_SERIAL_NUMBER,
	AUTO_SERIAL_ALPHA_PREFIX,
	SOURCE_TYPE,
	SOURCE_ORGANIZATION_ID,
	SOURCE_SUBINVENTORY,
	EXPENSE_ACCOUNT,
	ENCUMBRANCE_ACCOUNT,
	RESTRICT_SUBINVENTORIES_CODE,
	UNIT_WEIGHT,
	WEIGHT_UOM_CODE,
	VOLUME_UOM_CODE,
	UNIT_VOLUME,
	RESTRICT_LOCATORS_CODE,
	LOCATION_CONTROL_CODE,
	SHRINKAGE_RATE,
	ACCEPTABLE_EARLY_DAYS,
	PLANNING_TIME_FENCE_CODE,
	DEMAND_TIME_FENCE_CODE,
	LEAD_TIME_LOT_SIZE,
	STD_LOT_SIZE,
	CUM_MANUFACTURING_LEAD_TIME,
	OVERRUN_PERCENTAGE,
	MRP_CALCULATE_ATP_FLAG,
	ACCEPTABLE_RATE_INCREASE,
	ACCEPTABLE_RATE_DECREASE,
	CUMULATIVE_TOTAL_LEAD_TIME,
	PLANNING_TIME_FENCE_DAYS,
	DEMAND_TIME_FENCE_DAYS,
	END_ASSEMBLY_PEGGING_FLAG,
	REPETITIVE_PLANNING_FLAG,
	PLANNING_EXCEPTION_SET,
	BOM_ITEM_TYPE,
	PICK_COMPONENTS_FLAG,
	REPLENISH_TO_ORDER_FLAG,
	BASE_ITEM_ID,
	ATP_COMPONENTS_FLAG,
	ATP_FLAG,
	FIXED_LEAD_TIME,
	VARIABLE_LEAD_TIME,
	WIP_SUPPLY_LOCATOR_ID,
	WIP_SUPPLY_TYPE,
	WIP_SUPPLY_SUBINVENTORY,
	PRIMARY_UOM_CODE,
	PRIMARY_UNIT_OF_MEASURE,
	ALLOWED_UNITS_LOOKUP_CODE,
	COST_OF_SALES_ACCOUNT,
	SALES_ACCOUNT,
	DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
	INVENTORY_ITEM_STATUS_CODE,
	INVENTORY_PLANNING_CODE,
	PLANNER_CODE,
	PLANNING_MAKE_BUY_CODE,
	FIXED_LOT_MULTIPLIER,
	ROUNDING_CONTROL_TYPE,
	CARRYING_COST,
	POSTPROCESSING_LEAD_TIME,
	PREPROCESSING_LEAD_TIME,
	FULL_LEAD_TIME,
	ORDER_COST,
	MRP_SAFETY_STOCK_PERCENT,
	MRP_SAFETY_STOCK_CODE,
	MIN_MINMAX_QUANTITY,
	MAX_MINMAX_QUANTITY,
	MINIMUM_ORDER_QUANTITY,
	FIXED_ORDER_QUANTITY,
	FIXED_DAYS_SUPPLY,
	MAXIMUM_ORDER_QUANTITY,
	ATP_RULE_ID,
	PICKING_RULE_ID,
	RESERVABLE_TYPE,
	POSITIVE_MEASUREMENT_ERROR,
	NEGATIVE_MEASUREMENT_ERROR,
	ENGINEERING_ECN_CODE,
	ENGINEERING_ITEM_ID,
	ENGINEERING_DATE,
	SERVICE_STARTING_DELAY,
      -- VENDOR_WARRANTY_FLAG,
	SERVICEABLE_COMPONENT_FLAG,
	SERVICEABLE_PRODUCT_FLAG,
	BASE_WARRANTY_SERVICE_ID,
	PAYMENT_TERMS_ID,
	PREVENTIVE_MAINTENANCE_FLAG,
	PRIMARY_SPECIALIST_ID,
	SECONDARY_SPECIALIST_ID,
	SERVICEABLE_ITEM_CLASS_ID,
	TIME_BILLABLE_FLAG,
	MATERIAL_BILLABLE_FLAG,
	EXPENSE_BILLABLE_FLAG,
	PRORATE_SERVICE_FLAG,
	COVERAGE_SCHEDULE_ID,
	SERVICE_DURATION_PERIOD_CODE,
	SERVICE_DURATION,
	WARRANTY_VENDOR_ID,
	MAX_WARRANTY_AMOUNT,
	RESPONSE_TIME_PERIOD_CODE,
	RESPONSE_TIME_VALUE,
	NEW_REVISION_CODE,
	INVOICEABLE_ITEM_FLAG,
	TAX_CODE,
	INVOICE_ENABLED_FLAG,
	MUST_USE_APPROVED_VENDOR_FLAG,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	OUTSIDE_OPERATION_FLAG,
	OUTSIDE_OPERATION_UOM_TYPE,
	SAFETY_STOCK_BUCKET_DAYS,
	AUTO_REDUCE_MPS,
	COSTING_ENABLED_FLAG,
	CYCLE_COUNT_ENABLED_FLAG,
	DEMAND_SOURCE_LINE,
	COPY_ITEM_ID,
	SET_ID,
	REVISION,
	AUTO_CREATED_CONFIG_FLAG,
	ITEM_TYPE,
	MODEL_CONFIG_CLAUSE_NAME,
	SHIP_MODEL_COMPLETE_FLAG,
	MRP_PLANNING_CODE,
	RETURN_INSPECTION_REQUIREMENT,
	DEMAND_SOURCE_TYPE,
	DEMAND_SOURCE_HEADER_ID,
	TRANSACTION_ID,
	PROCESS_FLAG,
	ORGANIZATION_CODE,
	ITEM_NUMBER,
	COPY_ITEM_NUMBER,
	TEMPLATE_ID,
	TEMPLATE_NAME,
	COPY_ORGANIZATION_ID,
	COPY_ORGANIZATION_CODE,
	ATO_FORECAST_CONTROL,
	TRANSACTION_TYPE,
	MATERIAL_COST,
	MATERIAL_SUB_ELEM,
	MATERIAL_OH_RATE,
	MATERIAL_OH_SUB_ELEM,
	MATERIAL_SUB_ELEM_ID,
	MATERIAL_OH_SUB_ELEM_ID,
	RELEASE_TIME_FENCE_CODE,
	RELEASE_TIME_FENCE_DAYS,
	CONTAINER_ITEM_FLAG,
	VEHICLE_ITEM_FLAG,
	MAXIMUM_LOAD_WEIGHT,
	MINIMUM_FILL_PERCENT,
	CONTAINER_TYPE_CODE,
	INTERNAL_VOLUME,
	SET_PROCESS_ID
	from MTL_SYSTEM_ITEMS_INTERFACE
	where process_flag = 1
	and set_process_id = xset_id
	and ((organization_id = org_id) or (all_org = 1));

	ret_code		NUMBER		:= 1;
	error_text		VARCHAR2(250);
	dumm_status		NUMBER;
	status_code		NUMBER;
	t_organization_id	NUMBER;
	t_inventory_item_id	NUMBER;
	t_trans_id		NUMBER;
        INVALID_TEMPLATE_ERR    EXCEPTION;
	ASS_ITEM_ERR		EXCEPTION;
	ORG_TEMPLATE_ERR        EXCEPTION;
	PARSE_ITEM_ERR		EXCEPTION;
	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

BEGIN -- {

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD1B: Inside chk_exist_copy_template_attr'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;

   status_code := INVUPD1B.check_inv_item_id(
			org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			err_text,
			xset_id);

   for rec in C_msii_records loop -- {
      BEGIN -- {
         t_organization_id := rec.organization_id;
         t_inventory_item_id := rec.inventory_item_id;
         t_trans_id := rec.transaction_id;

         if (rec.item_number is not NULL) then -- {
            error_text := NULL;
            ret_code := INVPUOPI.mtl_pr_parse_item_number(
					rec.item_number,
					rec.inventory_item_id,
					rec.transaction_id,
					rec.organization_id,
					error_text,
					rec.rowid);
            if (ret_code < 0) then -- {
               raise PARSE_ITEM_ERR;
            end if; -- }
         end if; -- }

         if ( INVUPD1B.exists_in_msi(
			rec.ROWID,
			t_organization_id,
			t_inventory_item_id,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
			t_trans_id,
			err_text,
			xset_id) = 1 )
         then
  	    rec.inventory_item_id := t_inventory_item_id;
	 else
            -- flag error that record does not exist in msi
	    --Bug: 4937990
	    -- Changed the error message
            dumm_status  := INVPUOPI.mtl_log_interface_err(
					t_organization_id,
					user_id,
					login_id,
					prog_appid,
					prog_id,
					request_id,
					t_trans_id,
					error_text,
					null,
					'MTL_SYSTEM_ITEMS_INTERFACE',
					'INV_ORGITEM_ID_NOT_FOUND',
					err_text);
            dumm_status := INVUPD2B.set_process_flag3(rec.ROWID,user_id,login_id,prog_appid,prog_id,request_id);
	 end if;
      EXCEPTION
         -- if an oracle error occurred
         when ASS_ITEM_ERR then
            dumm_status  := INVPUOPI.mtl_log_interface_err(
					t_organization_id,
					user_id,
					login_id,
					prog_appid,
					prog_id,
					request_id,
					t_trans_id,
					error_text,
					null,
					'MTL_SYSTEM_ITEMS_INTERFACE',
					'INV_TEMPLATE_ERROR',
					err_text);
            dumm_status := INVUPD2B.set_process_flag3(rec.ROWID,user_id,login_id,prog_appid,prog_id,request_id);
            status_code := 1;

         when PARSE_ITEM_ERR then
            dumm_status  := INVPUOPI.mtl_log_interface_err(
					t_organization_id,
					user_id,
					login_id,
					prog_appid,
					prog_id,
					request_id,
					t_trans_id,
					error_text,
					'ITEM_NUMBER',
					'MTL_SYSTEM_ITEMS_INTERFACE',
					'INV_PARSE_ITEM_ERROR',
					err_text);
            dumm_status := INVUPD2B.set_process_flag3(rec.ROWID,user_id,login_id,prog_appid,prog_id,request_id);
         END;
      end loop;  -- msii loop

      -- IOI Perf improvements..apply mass template.
      IF (INSTR(INV_EGO_REVISION_VALIDATE.Get_Process_Control,'PLM_UI:Y') = 0) THEN
         status_code := INVPULI2.copy_template_attributes(
                           org_id
                          ,all_org
                          ,prog_appid
                          ,prog_id
                          ,request_id
                          ,user_id
                          ,login_id
                          ,xset_id
                          ,err_text);
      END IF;

      return (status_code);

EXCEPTION

   when OTHERS then
	IF l_inv_debug_level IN(101, 102) THEN
	   INVPUTLI.info('when OTHERS exception raised in chk_exist_copy_template_attr');
	END IF;
        return (1);

END chk_exist_copy_template_attr; -- }


FUNCTION check_inv_item_id
(
	org_id		NUMBER,
	all_org		NUMBER		:= 2,
	prog_appid	NUMBER		:= -1,
	prog_id		NUMBER		:= -1,
	request_id	NUMBER		:= -1,
	user_id		NUMBER		:= -1,
	login_id	NUMBER		:= -1,
	err_text IN OUT NOCOPY VARCHAR2,
	xset_id  IN	NUMBER		DEFAULT -999
)
return INTEGER
IS
	CURSOR C_inv_item_id_records is
	select process_flag, organization_id, transaction_id
	from MTL_SYSTEM_ITEMS_INTERFACE MSII
	where MSII.inventory_item_id is not NULL
	and MSII.set_process_id = xset_id
	and MSII.process_flag = 1
	and not exists
		(select inventory_item_id
		 from MTL_SYSTEM_ITEMS_B MSI
		 where MSII.inventory_item_id = MSI.inventory_item_id
		 and MSII.organization_id = MSI.organization_id)
	for update;

	error_text		VARCHAR2(250);
	l_process_flag_3	NUMBER		:= 3;
	dumm_status		NUMBER;
	ret_code		NUMBER		:= 0;
	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

BEGIN -- {

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD1B: Inside check_inv_item_id'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;

	for rec in C_inv_item_id_records loop -- {

		dumm_status  := INVPUOPI.mtl_log_interface_err(
				rec.organization_id,
				user_id,
				login_id,
				prog_appid,
				prog_id,
				request_id,
				rec.transaction_id,
				error_text,
				'INVENTORY_ITEM_ID',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_INV_ITEM_ID_NOEXIST_ERROR',
				err_text);

		update MTL_SYSTEM_ITEMS_INTERFACE
		set process_flag = l_process_flag_3
		where current of C_inv_item_id_records;
		ret_code := 1;

	end loop; -- }

        /* commit for debugging ONLY */
	-- commit;

   return (ret_code);

EXCEPTION

   when OTHERS then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('when OTHERS exception raised in check_inv_item_id');
      END IF;
      return (1);

END check_inv_item_id; -- }


FUNCTION exists_in_msi
(
	row_id			ROWID,
	org_id          	NUMBER,
	inv_item_id IN OUT NOCOPY NUMBER,
	prog_appid		NUMBER		:= -1,
	prog_id			NUMBER		:= -1,
	request_id		NUMBER		:= -1,
	user_id			NUMBER		:= -1,
	login_id		NUMBER		:= -1,
	trans_id		NUMBER,
	err_text IN OUT	NOCOPY	VARCHAR2,
	xset_id  IN		NUMBER		DEFAULT NULL
)
return INTEGER
IS
	tmp_orgid	NUMBER;
	error_text	VARCHAR2(250);
	dumm_status	NUMBER;

	-- Dynamic SQL vars
	DSQL_inventory_item_id	NUMBER;
	DSQL_statement		VARCHAR2(3000);
	DSQL_c			INTEGER; -- pointer to dynamic SQL cursor
	DSQL_rows_processed	INTEGER;
	statement_temp		VARCHAR2(2000);
	err_temp		VARCHAR2(1000);
	transaction_id_bind	INTEGER;
	dummy_ret_code		NUMBER;

	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

BEGIN -- {

  IF l_inv_debug_level IN(101, 102) THEN
     INVPUTLI.info('INVUPD1B: Inside exists_in_msi'|| '***orgid: ' || TO_CHAR(org_id));
  END IF;

	if inv_item_id is null then -- {

		dummy_ret_code := INVPUTLI.get_dynamic_sql_str(1, statement_temp, err_temp);
		DSQL_statement := 'select msi.inventory_item_id
					from mtl_system_items_B msi,
					mtl_system_items_interface msii
		                        where msii.rowid = :row_id_bind
		                        AND msi.organization_id = msii.organization_id
					and ' || statement_temp;
		DSQL_c := dbms_sql.open_cursor;
		dbms_sql.parse(DSQL_c, DSQL_statement, dbms_sql.native);
		dbms_sql.define_column(DSQL_c,1,DSQL_inventory_item_id);
		dbms_sql.bind_variable(DSQL_c, 'row_id_bind', row_id);
		DSQL_rows_processed := dbms_sql.execute(DSQL_c);
--
		if dbms_sql.fetch_rows(DSQL_c) > 0 then -- {
			dbms_sql.column_value(DSQL_c,1,DSQL_inventory_item_id);
--
			update MTL_SYSTEM_ITEMS_INTERFACE
			set inventory_item_id = DSQL_inventory_item_id
			where rowid  = row_id;
--
			inv_item_id := DSQL_inventory_item_id;
			dbms_sql.close_cursor(DSQL_c);
		else -- } {
			dbms_sql.close_cursor(DSQL_c);
--
			return (0);
		end if; -- }

	end if; -- }

	select organization_id
	into tmp_orgid
	from MTL_SYSTEM_ITEMS_B
	where organization_id = org_id
	and inventory_item_id = inv_item_id;

   return (1);

EXCEPTION

   when NO_DATA_FOUND then
      -- orgid inv_item_id combination does not exist in msi
      return 0;

   when OTHERS then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('when OTHERS exception raised in exists_in_msi');
      END IF;

      if dbms_sql.is_open(DSQL_c) then -- {
         dbms_sql.close_cursor(DSQL_c);
      end if; -- }

      dumm_status := INVPUOPI.mtl_log_interface_err(
				org_id,
				user_id,
				login_id,
				prog_appid,
				prog_id,
				request_id,
				trans_id,
				error_text,
				null,
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_DYN_SQL_ERROR',
				err_text);

      dumm_status := INVUPD2B.set_process_flag3 (row_id,user_id,login_id,prog_appid,prog_id,request_id);

      return (0);

END exists_in_msi; -- }


FUNCTION exists_onhand_quantities
(
	org_id          NUMBER,
	inv_item_id     NUMBER
)
return INTEGER
IS
	tmp_org_id	NUMBER;
	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
BEGIN -- {

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD1B: Inside exists_onhand_quantities'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;



	select organization_id
	into tmp_org_id
	from MTL_ONHAND_QUANTITIES_DETAIL MOQ -- Bug:2687570
	where MOQ.ORGANIZATION_ID = org_id
	AND MOQ.INVENTORY_ITEM_ID = inv_item_id;

   return (1);

EXCEPTION

   when NO_DATA_FOUND then
      return (0);

   when TOO_MANY_ROWS then
      return (1);

   when OTHERS then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('when OTHERS exception raised in exists_onhand_quantities');
      END IF;
      return (0);

END exists_onhand_quantities; -- }


FUNCTION exists_onhand_child_qties
(
	org_id          NUMBER,
	inv_item_id     NUMBER
)
return INTEGER
IS
	-- child records in msi of master org_id
	CURSOR C_child_msi_records IS
	select
	MSI.INVENTORY_ITEM_ID,
	MSI.ORGANIZATION_ID
	from MTL_SYSTEM_ITEMS_B MSI, MTL_PARAMETERS MP
	where MP.master_organization_id = org_id
        and MP.organization_id = MSI.organization_id
	and MSI.inventory_item_id = inv_item_id
	and MSI.organization_id <> MP.master_organization_id;

	tmp_org_id	NUMBER;
	status		NUMBER		:= 0;

	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

BEGIN -- {

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD1B: Inside exists_onhand_child_qties'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;
	-- if record is a master record
	select organization_id
	into tmp_org_id
	from MTL_PARAMETERS MP
	where MP.organization_id = org_id
	AND MP.master_organization_id = org_id;

	for rec in C_child_msi_records loop -- {

		status := INVUPD1B.exists_onhand_quantities(rec.INVENTORY_ITEM_ID, rec.ORGANIZATION_ID);
		exit when status = 1;

	end loop; -- }

   return status;

	--	if exists_onhand_quantities
	--		return (1)
	--	else
	--		return (0) [default]

EXCEPTION

   when NO_DATA_FOUND then -- record is not a master record
	return (0);

   when OTHERS then
        IF l_inv_debug_level IN(101, 102) THEN
	   INVPUTLI.info('when OTHERS exception raised in exists_onhand_child_qties');
        END IF;
	return (0);

END exists_onhand_child_qties; -- }


FUNCTION copy_msi_to_msii(
	row_id		ROWID,
	org_id          NUMBER,
	inv_item_id     NUMBER) return INTEGER  IS

CURSOR c_trade_item_default
 IS
   SELECT default_value FROM FND_DESCR_FLEX_COLUMN_USAGES
    WHERE application_id = 431
      AND DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_MASTER_ITEMS'
      AND DESCRIPTIVE_FLEX_CONTEXT_CODE = 'Main'
      AND END_USER_COLUMN_NAME = 'Trade_Item_Descriptor';

   msi_record_temp	MTL_SYSTEM_ITEMS_VL%ROWTYPE;
   msii_temp_data       MTL_SYSTEM_ITEMS_INTERFACE%ROWTYPE;
   l_process_flag_2	NUMBER	:= 2;
   l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

BEGIN -- {

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD1B: Inside copy_msi_to_msii'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;

   SELECT *  INTO msi_record_temp
   FROM   MTL_SYSTEM_ITEMS_VL MSI
   WHERE  MSI.organization_id   = org_id
   AND    MSI.inventory_item_id = inv_item_id;

   SELECT * INTO msii_temp_data
   FROM  MTL_SYSTEM_ITEMS_INTERFACE msii
   WHERE MSII.ROWID   = ROW_ID;

   -- Start 5565453 : Perf issue reducing the shared memory
   IF msii_temp_data.DAYS_MAX_INV_WINDOW IS NULL THEN
      msii_temp_data.DAYS_MAX_INV_WINDOW := msi_record_temp.DAYS_MAX_INV_WINDOW;
   ELSIF msii_temp_data.DAYS_MAX_INV_WINDOW    = g_Upd_Null_NUM THEN
      msii_temp_data.DAYS_MAX_INV_WINDOW := NULL;
   ELSIF msii_temp_data.DAYS_MAX_INV_WINDOW    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DAYS_MAX_INV_WINDOW := NULL;
   END IF;
   IF msii_temp_data.DRP_PLANNED_FLAG IS NULL THEN
      msii_temp_data.DRP_PLANNED_FLAG := msi_record_temp.DRP_PLANNED_FLAG;
   ELSIF msii_temp_data.DRP_PLANNED_FLAG    = g_Upd_Null_NUM THEN
      msii_temp_data.DRP_PLANNED_FLAG := NULL;
   ELSIF msii_temp_data.DRP_PLANNED_FLAG    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DRP_PLANNED_FLAG := NULL;
   END IF;
   IF msii_temp_data.CRITICAL_COMPONENT_FLAG IS NULL THEN
      msii_temp_data.CRITICAL_COMPONENT_FLAG := msi_record_temp.CRITICAL_COMPONENT_FLAG;
   ELSIF msii_temp_data.CRITICAL_COMPONENT_FLAG    = g_Upd_Null_NUM THEN
      msii_temp_data.CRITICAL_COMPONENT_FLAG := NULL;
   ELSIF msii_temp_data.CRITICAL_COMPONENT_FLAG    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.CRITICAL_COMPONENT_FLAG := NULL;
   END IF;
   IF msii_temp_data.CONTINOUS_TRANSFER IS NULL THEN
      msii_temp_data.CONTINOUS_TRANSFER := msi_record_temp.CONTINOUS_TRANSFER;
   ELSIF msii_temp_data.CONTINOUS_TRANSFER    = g_Upd_Null_NUM THEN
      msii_temp_data.CONTINOUS_TRANSFER := NULL;
   ELSIF msii_temp_data.CONTINOUS_TRANSFER    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.CONTINOUS_TRANSFER := NULL;
   END IF;
   IF msii_temp_data.CONVERGENCE IS NULL THEN
      msii_temp_data.CONVERGENCE := msi_record_temp.CONVERGENCE;
   ELSIF msii_temp_data.CONVERGENCE    = g_Upd_Null_NUM THEN
      msii_temp_data.CONVERGENCE := NULL;
   ELSIF msii_temp_data.CONVERGENCE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.CONVERGENCE := NULL;
   END IF;
   IF msii_temp_data.DIVERGENCE IS NULL THEN
      msii_temp_data.DIVERGENCE := msi_record_temp.DIVERGENCE;
   ELSIF msii_temp_data.DIVERGENCE    = g_Upd_Null_NUM THEN
      msii_temp_data.DIVERGENCE := NULL;
   ELSIF msii_temp_data.DIVERGENCE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DIVERGENCE := NULL;
   END IF;
   IF msii_temp_data.LOT_DIVISIBLE_FLAG is null then
      msii_temp_data.LOT_DIVISIBLE_FLAG := msi_record_temp.LOT_DIVISIBLE_FLAG;
   END IF;
   IF msii_temp_data.GRADE_CONTROL_FLAG is null then
      msii_temp_data.GRADE_CONTROL_FLAG := msi_record_temp.GRADE_CONTROL_FLAG;
   END IF;
   IF msii_temp_data.CHILD_LOT_FLAG is null then
      msii_temp_data.CHILD_LOT_FLAG := msi_record_temp.CHILD_LOT_FLAG;
   END IF;
   /* Bug 8453724. Added ELSIF statements to set PARENT_CHILD_GENERATION_FLAG to NULL, if it has '!' character, which is used
      to null out a value in IOI */
   IF msii_temp_data.PARENT_CHILD_GENERATION_FLAG is null then
      msii_temp_data.PARENT_CHILD_GENERATION_FLAG := msi_record_temp.PARENT_CHILD_GENERATION_FLAG;
   ELSIF msii_temp_data.PARENT_CHILD_GENERATION_FLAG = g_Upd_Null_CHAR THEN
      msii_temp_data.PARENT_CHILD_GENERATION_FLAG := NULL;
   ELSIF msii_temp_data.PARENT_CHILD_GENERATION_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.PARENT_CHILD_GENERATION_FLAG := NULL;
   END IF;
   IF msii_temp_data.CHILD_LOT_STARTING_NUMBER IS NULL THEN
      msii_temp_data.CHILD_LOT_STARTING_NUMBER := msi_record_temp.CHILD_LOT_STARTING_NUMBER;
   ELSIF msii_temp_data.CHILD_LOT_STARTING_NUMBER    = '!' THEN
      msii_temp_data.CHILD_LOT_STARTING_NUMBER := NULL;
   ELSIF msii_temp_data.CHILD_LOT_STARTING_NUMBER    = g_FND_Upd_Null_Char THEN
      msii_temp_data.CHILD_LOT_STARTING_NUMBER := NULL;
   END IF;
   IF msii_temp_data.CHILD_LOT_VALIDATION_FLAG is null then
      msii_temp_data.CHILD_LOT_VALIDATION_FLAG := msi_record_temp.CHILD_LOT_VALIDATION_FLAG;
   END IF;
   IF msii_temp_data.PROCESS_QUALITY_ENABLED_FLAG is null then
      msii_temp_data.PROCESS_QUALITY_ENABLED_FLAG := msi_record_temp.PROCESS_QUALITY_ENABLED_FLAG;
   END IF;
   IF msii_temp_data.PROCESS_SUPPLY_SUBINVENTORY IS NULL THEN
      msii_temp_data.PROCESS_SUPPLY_SUBINVENTORY := msi_record_temp.PROCESS_SUPPLY_SUBINVENTORY;
   ELSIF msii_temp_data.PROCESS_SUPPLY_SUBINVENTORY    = '!' THEN
      msii_temp_data.PROCESS_SUPPLY_SUBINVENTORY := NULL;
   ELSIF msii_temp_data.PROCESS_SUPPLY_SUBINVENTORY    = g_FND_Upd_Null_Char THEN
      msii_temp_data.PROCESS_SUPPLY_SUBINVENTORY := NULL;
   END IF;
   IF msii_temp_data.PROCESS_YIELD_SUBINVENTORY IS NULL THEN
      msii_temp_data.PROCESS_YIELD_SUBINVENTORY := msi_record_temp.PROCESS_YIELD_SUBINVENTORY;
   ELSIF msii_temp_data.PROCESS_YIELD_SUBINVENTORY    = '!' THEN
      msii_temp_data.PROCESS_YIELD_SUBINVENTORY := NULL;
   ELSIF msii_temp_data.PROCESS_YIELD_SUBINVENTORY    = g_FND_Upd_Null_Char THEN
      msii_temp_data.PROCESS_YIELD_SUBINVENTORY := NULL;
   END IF;
   IF msii_temp_data.HAZARDOUS_MATERIAL_FLAG is null then
      msii_temp_data.HAZARDOUS_MATERIAL_FLAG := msi_record_temp.HAZARDOUS_MATERIAL_FLAG;
   END IF;
   IF msii_temp_data.CAS_NUMBER IS NULL THEN
      msii_temp_data.CAS_NUMBER := msi_record_temp.CAS_NUMBER;
   ELSIF msii_temp_data.CAS_NUMBER    = '!' THEN
      msii_temp_data.CAS_NUMBER := NULL;
   ELSIF msii_temp_data.CAS_NUMBER    = g_FND_Upd_Null_Char THEN
      msii_temp_data.CAS_NUMBER := NULL;
   END IF;
   IF msii_temp_data.EXPIRATION_ACTION_INTERVAL IS NULL THEN
      msii_temp_data.EXPIRATION_ACTION_INTERVAL := msi_record_temp.EXPIRATION_ACTION_INTERVAL;
   ELSIF msii_temp_data.EXPIRATION_ACTION_INTERVAL    = -999999 THEN
      msii_temp_data.EXPIRATION_ACTION_INTERVAL := NULL;
   ELSIF msii_temp_data.EXPIRATION_ACTION_INTERVAL    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.EXPIRATION_ACTION_INTERVAL := NULL;
   END IF;
   IF msii_temp_data.EXPIRATION_ACTION_CODE is null then
      msii_temp_data.EXPIRATION_ACTION_CODE := msi_record_temp.EXPIRATION_ACTION_CODE;
    ELSIF msii_temp_data.EXPIRATION_ACTION_CODE    = '!' THEN
      msii_temp_data.EXPIRATION_ACTION_CODE := NULL;
   END IF;
   IF msii_temp_data.HOLD_DAYS IS NULL THEN
      msii_temp_data.HOLD_DAYS := msi_record_temp.HOLD_DAYS;
   ELSIF msii_temp_data.HOLD_DAYS    = -999999 THEN
      msii_temp_data.HOLD_DAYS := NULL;
   ELSIF msii_temp_data.HOLD_DAYS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.HOLD_DAYS := NULL;
   END IF;
   IF msii_temp_data.REPAIR_LEADTIME IS NULL THEN
      msii_temp_data.REPAIR_LEADTIME := msi_record_temp.REPAIR_LEADTIME;
   ELSIF msii_temp_data.REPAIR_LEADTIME    = -999999 THEN
      msii_temp_data.REPAIR_LEADTIME := NULL;
   ELSIF msii_temp_data.REPAIR_LEADTIME    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.REPAIR_LEADTIME := NULL;
   END IF;
   IF msii_temp_data.REPAIR_YIELD IS NULL THEN
      msii_temp_data.REPAIR_YIELD := msi_record_temp.REPAIR_YIELD;
   ELSIF msii_temp_data.REPAIR_YIELD    = -999999 THEN
      msii_temp_data.REPAIR_YIELD := NULL;
   ELSIF msii_temp_data.REPAIR_YIELD    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.REPAIR_YIELD := NULL;
   END IF;
   IF msii_temp_data.REPAIR_PROGRAM IS NULL THEN
      msii_temp_data.REPAIR_PROGRAM := msi_record_temp.REPAIR_PROGRAM;
   ELSIF msii_temp_data.REPAIR_PROGRAM    = -999999 THEN
      msii_temp_data.REPAIR_PROGRAM := NULL;
   ELSIF msii_temp_data.REPAIR_PROGRAM    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.REPAIR_PROGRAM := NULL;
   END IF;
   IF msii_temp_data.OUTSOURCED_ASSEMBLY IS NULL THEN
      msii_temp_data.OUTSOURCED_ASSEMBLY := msi_record_temp.OUTSOURCED_ASSEMBLY;
   ELSIF msii_temp_data.OUTSOURCED_ASSEMBLY    = -999999 THEN
      msii_temp_data.OUTSOURCED_ASSEMBLY := NULL;
   ELSIF msii_temp_data.OUTSOURCED_ASSEMBLY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.OUTSOURCED_ASSEMBLY := NULL;
   END IF;
   IF trim(msii_temp_data.RFQ_REQUIRED_FLAG) is null then
      msii_temp_data.RFQ_REQUIRED_FLAG := msi_record_temp.RFQ_REQUIRED_FLAG;
   ELSE
      msii_temp_data.RFQ_REQUIRED_FLAG := trim(msii_temp_data.RFQ_REQUIRED_FLAG);
   END IF;
   IF msii_temp_data.MIN_MINMAX_QUANTITY IS NULL THEN
      msii_temp_data.MIN_MINMAX_QUANTITY := msi_record_temp.MIN_MINMAX_QUANTITY;
   ELSIF msii_temp_data.MIN_MINMAX_QUANTITY    = -999999 THEN
      msii_temp_data.MIN_MINMAX_QUANTITY := NULL;
   ELSIF msii_temp_data.MIN_MINMAX_QUANTITY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.MIN_MINMAX_QUANTITY := NULL;
   END IF;
   IF msii_temp_data.PROGRAM_APPLICATION_ID is null then
      msii_temp_data.PROGRAM_APPLICATION_ID := msi_record_temp.PROGRAM_APPLICATION_ID;
   END IF;
   IF msii_temp_data.DEFAULT_SERIAL_STATUS_ID IS NULL THEN
      msii_temp_data.DEFAULT_SERIAL_STATUS_ID := msi_record_temp.DEFAULT_SERIAL_STATUS_ID;
   ELSIF msii_temp_data.DEFAULT_SERIAL_STATUS_ID    = g_Upd_Null_NUM THEN
      msii_temp_data.DEFAULT_SERIAL_STATUS_ID := NULL;
   ELSIF msii_temp_data.DEFAULT_SERIAL_STATUS_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DEFAULT_SERIAL_STATUS_ID := NULL;
   END IF;
   IF msii_temp_data.ASN_AUTOEXPIRE_FLAG IS NULL THEN
      msii_temp_data.ASN_AUTOEXPIRE_FLAG := msi_record_temp.ASN_AUTOEXPIRE_FLAG;
   ELSIF msii_temp_data.ASN_AUTOEXPIRE_FLAG    = g_Upd_Null_NUM THEN
      msii_temp_data.ASN_AUTOEXPIRE_FLAG := NULL;
   ELSIF msii_temp_data.ASN_AUTOEXPIRE_FLAG    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ASN_AUTOEXPIRE_FLAG := NULL;
   END IF;
   IF msii_temp_data.DEFAULT_GRADE IS NULL THEN
      msii_temp_data.DEFAULT_GRADE := msi_record_temp.DEFAULT_GRADE;
   ELSIF msii_temp_data.DEFAULT_GRADE    = '!' THEN
      msii_temp_data.DEFAULT_GRADE := NULL;
   ELSIF msii_temp_data.DEFAULT_GRADE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.DEFAULT_GRADE := NULL;
   END IF;
   IF msii_temp_data.CHILD_LOT_PREFIX IS NULL THEN
      msii_temp_data.CHILD_LOT_PREFIX := msi_record_temp.CHILD_LOT_PREFIX;
   ELSIF msii_temp_data.CHILD_LOT_PREFIX    = '!' THEN
      msii_temp_data.CHILD_LOT_PREFIX := NULL;
   ELSIF msii_temp_data.CHILD_LOT_PREFIX    = g_FND_Upd_Null_Char THEN
      msii_temp_data.CHILD_LOT_PREFIX := NULL;
   END IF;
   IF msii_temp_data.COPY_LOT_ATTRIBUTE_FLAG is null then
      msii_temp_data.COPY_LOT_ATTRIBUTE_FLAG := msi_record_temp.COPY_LOT_ATTRIBUTE_FLAG;
   END IF;
   IF msii_temp_data.PROCESS_COSTING_ENABLED_FLAG is null then
      msii_temp_data.PROCESS_COSTING_ENABLED_FLAG := msi_record_temp.PROCESS_COSTING_ENABLED_FLAG;
   END IF;
   IF msii_temp_data.PROCESS_SUPPLY_LOCATOR_ID IS NULL THEN
      msii_temp_data.PROCESS_SUPPLY_LOCATOR_ID := msi_record_temp.PROCESS_SUPPLY_LOCATOR_ID;
   ELSIF msii_temp_data.PROCESS_SUPPLY_LOCATOR_ID    = -999999 THEN
      msii_temp_data.PROCESS_SUPPLY_LOCATOR_ID := NULL;
   ELSIF msii_temp_data.PROCESS_SUPPLY_LOCATOR_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.PROCESS_SUPPLY_LOCATOR_ID := NULL;
   END IF;
   IF msii_temp_data.PROCESS_YIELD_LOCATOR_ID IS NULL THEN
      msii_temp_data.PROCESS_YIELD_LOCATOR_ID := msi_record_temp.PROCESS_YIELD_LOCATOR_ID;
   ELSIF msii_temp_data.PROCESS_YIELD_LOCATOR_ID    = -999999 THEN
      msii_temp_data.PROCESS_YIELD_LOCATOR_ID := NULL;
   ELSIF msii_temp_data.PROCESS_YIELD_LOCATOR_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.PROCESS_YIELD_LOCATOR_ID := NULL;
   END IF;
   IF msii_temp_data.RETEST_INTERVAL IS NULL THEN
      msii_temp_data.RETEST_INTERVAL := msi_record_temp.RETEST_INTERVAL;
   ELSIF msii_temp_data.RETEST_INTERVAL    = -999999 THEN
      msii_temp_data.RETEST_INTERVAL := NULL;
   ELSIF msii_temp_data.RETEST_INTERVAL    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.RETEST_INTERVAL := NULL;
   END IF;
   IF msii_temp_data.MATURITY_DAYS IS NULL THEN
      msii_temp_data.MATURITY_DAYS := msi_record_temp.MATURITY_DAYS;
   ELSIF msii_temp_data.MATURITY_DAYS    = -999999 THEN
      msii_temp_data.MATURITY_DAYS := NULL;
   ELSIF msii_temp_data.MATURITY_DAYS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.MATURITY_DAYS := NULL;
   END IF;
   IF msii_temp_data.CHARGE_PERIODICITY_CODE IS NULL THEN
      msii_temp_data.CHARGE_PERIODICITY_CODE := msi_record_temp.CHARGE_PERIODICITY_CODE;
   ELSIF msii_temp_data.CHARGE_PERIODICITY_CODE    = '!' THEN
      msii_temp_data.CHARGE_PERIODICITY_CODE := NULL;
   ELSIF msii_temp_data.CHARGE_PERIODICITY_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.CHARGE_PERIODICITY_CODE := NULL;
   END IF;
   IF msii_temp_data.PREPOSITION_POINT IS NULL THEN
      msii_temp_data.PREPOSITION_POINT := msi_record_temp.PREPOSITION_POINT;
   ELSIF msii_temp_data.PREPOSITION_POINT    = '!' THEN
      msii_temp_data.PREPOSITION_POINT := NULL;
   ELSIF msii_temp_data.PREPOSITION_POINT    = g_FND_Upd_Null_Char THEN
      msii_temp_data.PREPOSITION_POINT := NULL;
   END IF;
   IF msii_temp_data.SUBCONTRACTING_COMPONENT IS NULL THEN
      msii_temp_data.SUBCONTRACTING_COMPONENT := msi_record_temp.SUBCONTRACTING_COMPONENT;
   ELSIF msii_temp_data.SUBCONTRACTING_COMPONENT    = -999999 THEN
      msii_temp_data.SUBCONTRACTING_COMPONENT := NULL;
   ELSIF msii_temp_data.SUBCONTRACTING_COMPONENT    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SUBCONTRACTING_COMPONENT := NULL;
   END IF;
   IF msii_temp_data.DEMAND_TIME_FENCE_CODE IS NULL THEN
      msii_temp_data.DEMAND_TIME_FENCE_CODE := msi_record_temp.DEMAND_TIME_FENCE_CODE;
   ELSIF msii_temp_data.DEMAND_TIME_FENCE_CODE    = -999999 THEN
      msii_temp_data.DEMAND_TIME_FENCE_CODE := NULL;
   ELSIF msii_temp_data.DEMAND_TIME_FENCE_CODE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DEMAND_TIME_FENCE_CODE := NULL;
   END IF;
   IF msii_temp_data.SAFETY_STOCK_BUCKET_DAYS IS NULL THEN
      msii_temp_data.SAFETY_STOCK_BUCKET_DAYS := msi_record_temp.SAFETY_STOCK_BUCKET_DAYS;
   ELSIF msii_temp_data.SAFETY_STOCK_BUCKET_DAYS    = -999999 THEN
      msii_temp_data.SAFETY_STOCK_BUCKET_DAYS := NULL;
   ELSIF msii_temp_data.SAFETY_STOCK_BUCKET_DAYS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SAFETY_STOCK_BUCKET_DAYS := NULL;
   END IF;
   -- added following ELSIF condition to fix bug 8827755
   IF trim(msii_temp_data.DESCRIPTION) is null then
      msii_temp_data.DESCRIPTION := msi_record_temp.DESCRIPTION;
   ELSIF  msii_temp_data.DESCRIPTION    = '!' THEN
      msii_temp_data.DESCRIPTION := NULL;
   ELSE
      msii_temp_data.DESCRIPTION := trim(msii_temp_data.DESCRIPTION);
   END IF;
   IF msii_temp_data.LONG_DESCRIPTION IS NULL THEN
      msii_temp_data.LONG_DESCRIPTION := msi_record_temp.LONG_DESCRIPTION;
   ELSIF msii_temp_data.LONG_DESCRIPTION    = '!' THEN
      msii_temp_data.LONG_DESCRIPTION := NULL;
   ELSIF msii_temp_data.LONG_DESCRIPTION    = g_FND_Upd_Null_Char THEN
      msii_temp_data.LONG_DESCRIPTION := NULL;
   ELSE
      msii_temp_data.LONG_DESCRIPTION := trim(msii_temp_data.LONG_DESCRIPTION);
   END IF;
   IF msii_temp_data.BUYER_ID IS NULL THEN
      msii_temp_data.BUYER_ID := msi_record_temp.BUYER_ID;
   ELSIF msii_temp_data.BUYER_ID    = -999999 THEN
      msii_temp_data.BUYER_ID := NULL;
   ELSIF msii_temp_data.BUYER_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.BUYER_ID := NULL;
   END IF;
   IF msii_temp_data.INVOICING_RULE_ID IS NULL THEN
      msii_temp_data.INVOICING_RULE_ID := msi_record_temp.INVOICING_RULE_ID;
   ELSIF msii_temp_data.INVOICING_RULE_ID    = -999999 THEN
      msii_temp_data.INVOICING_RULE_ID := NULL;
   ELSIF msii_temp_data.INVOICING_RULE_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.INVOICING_RULE_ID := NULL;
   END IF;
   IF trim(msii_temp_data.SEGMENT6) is null then
      msii_temp_data.SEGMENT6 := msi_record_temp.SEGMENT6;
   ELSE
      msii_temp_data.SEGMENT6 := trim(msii_temp_data.SEGMENT6);
   END IF;
   IF trim(msii_temp_data.SEGMENT8) is null then
      msii_temp_data.SEGMENT8 := msi_record_temp.SEGMENT8;
   ELSE
      msii_temp_data.SEGMENT8 := trim(msii_temp_data.SEGMENT8);
   END IF;
   IF trim(msii_temp_data.SEGMENT11) is null then
      msii_temp_data.SEGMENT11 := msi_record_temp.SEGMENT11;
   ELSE
      msii_temp_data.SEGMENT11 := trim(msii_temp_data.SEGMENT11);
   END IF;
   IF trim(msii_temp_data.SEGMENT14) is null then
      msii_temp_data.SEGMENT14 := msi_record_temp.SEGMENT14;
   ELSE
      msii_temp_data.SEGMENT14 := trim(msii_temp_data.SEGMENT14);
   END IF;
   IF trim(msii_temp_data.SEGMENT19) is null then
      msii_temp_data.SEGMENT19 := msi_record_temp.SEGMENT19;
   ELSE
      msii_temp_data.SEGMENT19 := trim(msii_temp_data.SEGMENT19);
   END IF;
   IF msii_temp_data.ATTRIBUTE_CATEGORY IS NULL THEN
      msii_temp_data.ATTRIBUTE_CATEGORY := msi_record_temp.ATTRIBUTE_CATEGORY;
   ELSIF msii_temp_data.ATTRIBUTE_CATEGORY    = '!' THEN
      msii_temp_data.ATTRIBUTE_CATEGORY := NULL;
   ELSIF msii_temp_data.ATTRIBUTE_CATEGORY    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE_CATEGORY := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE_CATEGORY := trim(msii_temp_data.ATTRIBUTE_CATEGORY);
   END IF;
   IF msii_temp_data.ATTRIBUTE3 IS NULL THEN
      msii_temp_data.ATTRIBUTE3 := msi_record_temp.ATTRIBUTE3;
   ELSIF msii_temp_data.ATTRIBUTE3    = '!' THEN
      msii_temp_data.ATTRIBUTE3 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE3    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE3 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE3 := trim(msii_temp_data.ATTRIBUTE3);
   END IF;
   IF msii_temp_data.ATTRIBUTE5 IS NULL THEN
      msii_temp_data.ATTRIBUTE5 := msi_record_temp.ATTRIBUTE5;
   ELSIF msii_temp_data.ATTRIBUTE5    = '!' THEN
      msii_temp_data.ATTRIBUTE5 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE5    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE5 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE5 := trim(msii_temp_data.ATTRIBUTE5);
   END IF;
   IF msii_temp_data.ATTRIBUTE7 IS NULL THEN
      msii_temp_data.ATTRIBUTE7 := msi_record_temp.ATTRIBUTE7;
   ELSIF msii_temp_data.ATTRIBUTE7    = '!' THEN
      msii_temp_data.ATTRIBUTE7 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE7    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE7 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE7 := trim(msii_temp_data.ATTRIBUTE7);
   END IF;
   IF msii_temp_data.ATTRIBUTE10 IS NULL THEN
      msii_temp_data.ATTRIBUTE10 := msi_record_temp.ATTRIBUTE10;
   ELSIF msii_temp_data.ATTRIBUTE10    = '!' THEN
      msii_temp_data.ATTRIBUTE10 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE10    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE10 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE10 := trim(msii_temp_data.ATTRIBUTE10);
   END IF;
   IF msii_temp_data.ATTRIBUTE12 IS NULL THEN
      msii_temp_data.ATTRIBUTE12 := msi_record_temp.ATTRIBUTE12;
   ELSIF msii_temp_data.ATTRIBUTE12    = '!' THEN
      msii_temp_data.ATTRIBUTE12 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE12    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE12 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE12 := trim(msii_temp_data.ATTRIBUTE12);
   END IF;
   IF msii_temp_data.ATTRIBUTE14 IS NULL THEN
      msii_temp_data.ATTRIBUTE14 := msi_record_temp.ATTRIBUTE14;
   ELSIF msii_temp_data.ATTRIBUTE14    = '!' THEN
      msii_temp_data.ATTRIBUTE14 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE14    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE14 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE14 := trim(msii_temp_data.ATTRIBUTE14);
   END IF;
   IF msii_temp_data.ATTRIBUTE17 IS NULL THEN
      msii_temp_data.ATTRIBUTE17 := msi_record_temp.ATTRIBUTE17;
   ELSIF msii_temp_data.ATTRIBUTE17    = '!' THEN
      msii_temp_data.ATTRIBUTE17 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE17    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE17 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE17 := trim(msii_temp_data.ATTRIBUTE17);
   END IF;
   IF msii_temp_data.ATTRIBUTE19 IS NULL THEN
      msii_temp_data.ATTRIBUTE19 := msi_record_temp.ATTRIBUTE19;
   ELSIF msii_temp_data.ATTRIBUTE19    = '!' THEN
      msii_temp_data.ATTRIBUTE19 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE19    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE19 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE19 := trim(msii_temp_data.ATTRIBUTE19);
   END IF;
   IF msii_temp_data.ATTRIBUTE21 IS NULL THEN
      msii_temp_data.ATTRIBUTE21 := msi_record_temp.ATTRIBUTE21;
   ELSIF msii_temp_data.ATTRIBUTE21    = '!' THEN
      msii_temp_data.ATTRIBUTE21 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE21    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE21 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE21 := trim(msii_temp_data.ATTRIBUTE21);
   END IF;
   IF msii_temp_data.ATTRIBUTE24 IS NULL THEN
      msii_temp_data.ATTRIBUTE24 := msi_record_temp.ATTRIBUTE24;
   ELSIF msii_temp_data.ATTRIBUTE24    = '!' THEN
      msii_temp_data.ATTRIBUTE24 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE24    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE24 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE24 := trim(msii_temp_data.ATTRIBUTE24);
   END IF;
   IF msii_temp_data.ATTRIBUTE26 IS NULL THEN
      msii_temp_data.ATTRIBUTE26 := msi_record_temp.ATTRIBUTE26;
   ELSIF msii_temp_data.ATTRIBUTE26    = '!' THEN
      msii_temp_data.ATTRIBUTE26 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE26    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE26 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE26 := trim(msii_temp_data.ATTRIBUTE26);
   END IF;
   IF msii_temp_data.ATTRIBUTE28 IS NULL THEN
      msii_temp_data.ATTRIBUTE28 := msi_record_temp.ATTRIBUTE28;
   ELSIF msii_temp_data.ATTRIBUTE28    = '!' THEN
      msii_temp_data.ATTRIBUTE28 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE28    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE28 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE28 := trim(msii_temp_data.ATTRIBUTE28);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE_CATEGORY IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE_CATEGORY := msi_record_temp.GLOBAL_ATTRIBUTE_CATEGORY;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE_CATEGORY    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE_CATEGORY := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE_CATEGORY    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE_CATEGORY := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE_CATEGORY := trim(msii_temp_data.GLOBAL_ATTRIBUTE_CATEGORY);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE2 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE2 := msi_record_temp.GLOBAL_ATTRIBUTE2;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE2    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE2 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE2    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE2 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE2 := trim(msii_temp_data.GLOBAL_ATTRIBUTE2);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE5 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE5 := msi_record_temp.GLOBAL_ATTRIBUTE5;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE5    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE5 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE5    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE5 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE5 := trim(msii_temp_data.GLOBAL_ATTRIBUTE5);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE7 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE7 := msi_record_temp.GLOBAL_ATTRIBUTE7;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE7    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE7 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE7    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE7 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE7 := trim(msii_temp_data.GLOBAL_ATTRIBUTE7);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE9 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE9 := msi_record_temp.GLOBAL_ATTRIBUTE9;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE9    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE9 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE9    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE9 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE9 := trim(msii_temp_data.GLOBAL_ATTRIBUTE9);
   END IF;
   IF trim(msii_temp_data.CUSTOMER_ORDER_FLAG) is null then
      msii_temp_data.CUSTOMER_ORDER_FLAG := msi_record_temp.CUSTOMER_ORDER_FLAG;
   ELSE
      msii_temp_data.CUSTOMER_ORDER_FLAG := trim(msii_temp_data.CUSTOMER_ORDER_FLAG);
   END IF;
   IF trim(msii_temp_data.ENG_ITEM_FLAG) is null then
      msii_temp_data.ENG_ITEM_FLAG := msi_record_temp.ENG_ITEM_FLAG;
   ELSE
      msii_temp_data.ENG_ITEM_FLAG := trim(msii_temp_data.ENG_ITEM_FLAG);
   END IF;
   IF trim(msii_temp_data.PURCHASING_ENABLED_FLAG) is null then
      IF msii_temp_data.inventory_item_status_code IS NULL THEN
         msii_temp_data.PURCHASING_ENABLED_FLAG := msi_record_temp.PURCHASING_ENABLED_FLAG;
      END IF;
   ELSE
      msii_temp_data.PURCHASING_ENABLED_FLAG := trim(msii_temp_data.PURCHASING_ENABLED_FLAG);
   END IF;
   IF trim(msii_temp_data.INTERNAL_ORDER_ENABLED_FLAG) is null then
      IF msii_temp_data.inventory_item_status_code IS NULL THEN
         msii_temp_data.INTERNAL_ORDER_ENABLED_FLAG := msi_record_temp.INTERNAL_ORDER_ENABLED_FLAG;
      END IF;
   ELSE
      msii_temp_data.INTERNAL_ORDER_ENABLED_FLAG := trim(msii_temp_data.INTERNAL_ORDER_ENABLED_FLAG);
   END IF;
   IF trim(msii_temp_data.BOM_ENABLED_FLAG) is null then
      IF  msii_temp_data.inventory_item_status_code IS NULL THEN
         msii_temp_data.BOM_ENABLED_FLAG := msi_record_temp.BOM_ENABLED_FLAG;
      END IF;
   ELSE
      msii_temp_data.BOM_ENABLED_FLAG := trim(msii_temp_data.BOM_ENABLED_FLAG);
   END IF;

   IF msii_temp_data.RESTRICT_LOCATORS_CODE is null then
      msii_temp_data.RESTRICT_LOCATORS_CODE := msi_record_temp.RESTRICT_LOCATORS_CODE;
   END IF;
   IF msii_temp_data.SHRINKAGE_RATE IS NULL THEN
      msii_temp_data.SHRINKAGE_RATE := msi_record_temp.SHRINKAGE_RATE;
   ELSIF msii_temp_data.SHRINKAGE_RATE    = -999999 THEN
      msii_temp_data.SHRINKAGE_RATE := NULL;
   ELSIF msii_temp_data.SHRINKAGE_RATE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SHRINKAGE_RATE := NULL;
   END IF;

   IF msii_temp_data.LEAD_TIME_LOT_SIZE IS NULL THEN
      msii_temp_data.LEAD_TIME_LOT_SIZE := msi_record_temp.LEAD_TIME_LOT_SIZE;
   ELSIF msii_temp_data.LEAD_TIME_LOT_SIZE = -999999 THEN
      IF msii_temp_data.STD_LOT_SIZE IS NULL THEN
         IF msi_record_temp.STD_LOT_SIZE IS NULL THEN
       msii_temp_data.LEAD_TIME_LOT_SIZE := 1;
         ELSE
       msii_temp_data.LEAD_TIME_LOT_SIZE := msi_record_temp.STD_LOT_SIZE;
         END IF;
      ELSIF msii_temp_data.STD_LOT_SIZE = -999999 THEN
         msii_temp_data.LEAD_TIME_LOT_SIZE := 1;
      ELSIF msii_temp_data.STD_LOT_SIZE = g_FND_Upd_Null_NUM THEN
         msii_temp_data.LEAD_TIME_LOT_SIZE := 1;
      ELSE
         msii_temp_data.LEAD_TIME_LOT_SIZE := msii_temp_data.STD_LOT_SIZE;
      END IF;
   ELSIF msii_temp_data.LEAD_TIME_LOT_SIZE = g_FND_Upd_Null_NUM THEN
      IF msii_temp_data.STD_LOT_SIZE IS NULL THEN
         IF msi_record_temp.STD_LOT_SIZE IS NULL THEN
       msii_temp_data.LEAD_TIME_LOT_SIZE := 1;
         ELSE
       msii_temp_data.LEAD_TIME_LOT_SIZE := msi_record_temp.STD_LOT_SIZE;
         END IF;
      ELSIF msii_temp_data.STD_LOT_SIZE = -999999 THEN
         msii_temp_data.LEAD_TIME_LOT_SIZE := 1;
      ELSIF msii_temp_data.STD_LOT_SIZE = g_FND_Upd_Null_NUM THEN
         msii_temp_data.LEAD_TIME_LOT_SIZE := 1;
      ELSE
         msii_temp_data.LEAD_TIME_LOT_SIZE := msii_temp_data.STD_LOT_SIZE;
      END IF;
   END IF;

   --STD_LOT_SIZE should be updated only after lead_time_lot_size
   IF msii_temp_data.STD_LOT_SIZE IS NULL THEN
      msii_temp_data.STD_LOT_SIZE := msi_record_temp.STD_LOT_SIZE;
   ELSIF msii_temp_data.STD_LOT_SIZE    = -999999 THEN
      msii_temp_data.STD_LOT_SIZE := NULL;
   ELSIF msii_temp_data.STD_LOT_SIZE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.STD_LOT_SIZE := NULL;
   END IF;

   IF msii_temp_data.CUM_MANUFACTURING_LEAD_TIME IS NULL THEN
      msii_temp_data.CUM_MANUFACTURING_LEAD_TIME := msi_record_temp.CUM_MANUFACTURING_LEAD_TIME;
   ELSIF msii_temp_data.CUM_MANUFACTURING_LEAD_TIME = -999999 THEN
      msii_temp_data.CUM_MANUFACTURING_LEAD_TIME := NULL;
   ELSIF msii_temp_data.CUM_MANUFACTURING_LEAD_TIME = g_FND_Upd_Null_NUM THEN
      msii_temp_data.CUM_MANUFACTURING_LEAD_TIME := NULL;
   END IF;
   IF msii_temp_data.DEMAND_TIME_FENCE_DAYS IS NULL THEN
      msii_temp_data.DEMAND_TIME_FENCE_DAYS := msi_record_temp.DEMAND_TIME_FENCE_DAYS;
   ELSIF msii_temp_data.DEMAND_TIME_FENCE_DAYS    = -999999 THEN
      msii_temp_data.DEMAND_TIME_FENCE_DAYS := NULL;
   ELSIF msii_temp_data.DEMAND_TIME_FENCE_DAYS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DEMAND_TIME_FENCE_DAYS := NULL;
   END IF;
   IF msii_temp_data.RELEASE_TIME_FENCE_DAYS       IS NULL THEN
      msii_temp_data.RELEASE_TIME_FENCE_DAYS := msi_record_temp.RELEASE_TIME_FENCE_DAYS;
   ELSIF msii_temp_data.RELEASE_TIME_FENCE_DAYS    = -999999 THEN
      msii_temp_data.RELEASE_TIME_FENCE_DAYS := NULL;
   ELSIF msii_temp_data.RELEASE_TIME_FENCE_DAYS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.RELEASE_TIME_FENCE_DAYS := NULL;
   END IF;
   IF msii_temp_data.PLANNING_EXCEPTION_SET IS NULL THEN
      msii_temp_data.PLANNING_EXCEPTION_SET := msi_record_temp.PLANNING_EXCEPTION_SET;
   ELSIF msii_temp_data.PLANNING_EXCEPTION_SET    = '!' THEN
      msii_temp_data.PLANNING_EXCEPTION_SET := NULL;
   ELSIF msii_temp_data.PLANNING_EXCEPTION_SET    = g_FND_Upd_Null_Char THEN
      msii_temp_data.PLANNING_EXCEPTION_SET := NULL;
   ELSE
      msii_temp_data.PLANNING_EXCEPTION_SET := trim(msii_temp_data.PLANNING_EXCEPTION_SET);
   END IF;
   IF msii_temp_data.BASE_ITEM_ID IS NULL THEN
      msii_temp_data.BASE_ITEM_ID := msi_record_temp.BASE_ITEM_ID;
   ELSIF msii_temp_data.BASE_ITEM_ID    = -999999 THEN
      msii_temp_data.BASE_ITEM_ID := NULL;
   ELSIF msii_temp_data.BASE_ITEM_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.BASE_ITEM_ID := NULL;
   END IF;
   IF msii_temp_data.FIXED_LEAD_TIME IS NULL THEN
      msii_temp_data.FIXED_LEAD_TIME := msi_record_temp.FIXED_LEAD_TIME;
   ELSIF msii_temp_data.FIXED_LEAD_TIME    = -999999 THEN
      msii_temp_data.FIXED_LEAD_TIME := NULL;
   ELSIF msii_temp_data.FIXED_LEAD_TIME    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.FIXED_LEAD_TIME := NULL;
   END IF;
   IF msii_temp_data.WIP_SUPPLY_TYPE is null then
      msii_temp_data.WIP_SUPPLY_TYPE := msi_record_temp.WIP_SUPPLY_TYPE;
   END IF;
   IF msii_temp_data.WIP_SUPPLY_SUBINVENTORY IS NULL THEN
      msii_temp_data.WIP_SUPPLY_SUBINVENTORY := msi_record_temp.WIP_SUPPLY_SUBINVENTORY;
   ELSIF msii_temp_data.WIP_SUPPLY_SUBINVENTORY    = '!' THEN
      msii_temp_data.WIP_SUPPLY_SUBINVENTORY := NULL;
   ELSIF msii_temp_data.WIP_SUPPLY_SUBINVENTORY    = g_FND_Upd_Null_Char THEN
      msii_temp_data.WIP_SUPPLY_SUBINVENTORY := NULL;
   ELSE
      msii_temp_data.WIP_SUPPLY_SUBINVENTORY := trim(msii_temp_data.WIP_SUPPLY_SUBINVENTORY);
   END IF;
   IF trim(msii_temp_data.DEFAULT_INCLUDE_IN_ROLLUP_FLAG) is null then
      msii_temp_data.DEFAULT_INCLUDE_IN_ROLLUP_FLAG := msi_record_temp.DEFAULT_INCLUDE_IN_ROLLUP_FLAG;
   ELSE
      msii_temp_data.DEFAULT_INCLUDE_IN_ROLLUP_FLAG := trim(msii_temp_data.DEFAULT_INCLUDE_IN_ROLLUP_FLAG);
   END IF;
   IF msii_temp_data.PLANNER_CODE IS NULL THEN
      msii_temp_data.PLANNER_CODE := msi_record_temp.PLANNER_CODE;
   ELSIF msii_temp_data.PLANNER_CODE    = '!' THEN
      msii_temp_data.PLANNER_CODE := NULL;
   ELSIF msii_temp_data.PLANNER_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.PLANNER_CODE := NULL;
   ELSE
      msii_temp_data.PLANNER_CODE := trim(msii_temp_data.PLANNER_CODE);
   END IF;
   IF msii_temp_data.ROUNDING_CONTROL_TYPE is null then
      msii_temp_data.ROUNDING_CONTROL_TYPE := msi_record_temp.ROUNDING_CONTROL_TYPE;
   END IF;
   IF msii_temp_data.POSTPROCESSING_LEAD_TIME IS NULL THEN
      msii_temp_data.POSTPROCESSING_LEAD_TIME := msi_record_temp.POSTPROCESSING_LEAD_TIME;
   ELSIF msii_temp_data.POSTPROCESSING_LEAD_TIME    = -999999 THEN
      msii_temp_data.POSTPROCESSING_LEAD_TIME := NULL;
   ELSIF msii_temp_data.POSTPROCESSING_LEAD_TIME    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.POSTPROCESSING_LEAD_TIME := NULL;
   END IF;
   IF msii_temp_data.FULL_LEAD_TIME IS NULL THEN
      msii_temp_data.FULL_LEAD_TIME := msi_record_temp.FULL_LEAD_TIME;
   ELSIF msii_temp_data.FULL_LEAD_TIME    = -999999 THEN
      msii_temp_data.FULL_LEAD_TIME := NULL;
   ELSIF msii_temp_data.FULL_LEAD_TIME    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.FULL_LEAD_TIME := NULL;
   END IF;
   IF msii_temp_data.MRP_SAFETY_STOCK_PERCENT IS NULL THEN
      msii_temp_data.MRP_SAFETY_STOCK_PERCENT := msi_record_temp.MRP_SAFETY_STOCK_PERCENT;
   ELSIF msii_temp_data.MRP_SAFETY_STOCK_PERCENT    = -999999 THEN
      msii_temp_data.MRP_SAFETY_STOCK_PERCENT := NULL;
   ELSIF msii_temp_data.MRP_SAFETY_STOCK_PERCENT    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.MRP_SAFETY_STOCK_PERCENT := NULL;
   END IF;
   IF msii_temp_data.MAX_MINMAX_QUANTITY IS NULL THEN
      msii_temp_data.MAX_MINMAX_QUANTITY := msi_record_temp.MAX_MINMAX_QUANTITY;
   ELSIF msii_temp_data.MAX_MINMAX_QUANTITY    = -999999 THEN
      msii_temp_data.MAX_MINMAX_QUANTITY := NULL;
   ELSIF msii_temp_data.MAX_MINMAX_QUANTITY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.MAX_MINMAX_QUANTITY := NULL;
   END IF;
   IF msii_temp_data.FIXED_ORDER_QUANTITY IS NULL THEN
      msii_temp_data.FIXED_ORDER_QUANTITY := msi_record_temp.FIXED_ORDER_QUANTITY;
   ELSIF msii_temp_data.FIXED_ORDER_QUANTITY    = -999999 THEN
      msii_temp_data.FIXED_ORDER_QUANTITY := NULL;
   ELSIF msii_temp_data.FIXED_ORDER_QUANTITY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.FIXED_ORDER_QUANTITY := NULL;
   END IF;
   IF msii_temp_data.ATP_RULE_ID IS NULL THEN
      msii_temp_data.ATP_RULE_ID := msi_record_temp.ATP_RULE_ID;
   ELSIF msii_temp_data.ATP_RULE_ID    = -999999 THEN
      msii_temp_data.ATP_RULE_ID := NULL;
   ELSIF msii_temp_data.ATP_RULE_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ATP_RULE_ID := NULL;
   END IF;
   IF msii_temp_data.POSITIVE_MEASUREMENT_ERROR IS NULL THEN
      msii_temp_data.POSITIVE_MEASUREMENT_ERROR := msi_record_temp.POSITIVE_MEASUREMENT_ERROR;
   ELSIF msii_temp_data.POSITIVE_MEASUREMENT_ERROR    = -999999 THEN
      msii_temp_data.POSITIVE_MEASUREMENT_ERROR := NULL;
   ELSIF msii_temp_data.POSITIVE_MEASUREMENT_ERROR    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.POSITIVE_MEASUREMENT_ERROR := NULL;
   END IF;
   IF msii_temp_data.ENGINEERING_ITEM_ID is null then
      msii_temp_data.ENGINEERING_ITEM_ID := msi_record_temp.ENGINEERING_ITEM_ID;
   END IF;
   IF msii_temp_data.SERVICE_STARTING_DELAY IS NULL THEN
      msii_temp_data.SERVICE_STARTING_DELAY := msi_record_temp.SERVICE_STARTING_DELAY;
   ELSIF msii_temp_data.SERVICE_STARTING_DELAY    = -999999 THEN
      msii_temp_data.SERVICE_STARTING_DELAY := NULL;
   ELSIF msii_temp_data.SERVICE_STARTING_DELAY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SERVICE_STARTING_DELAY := NULL;
   END IF;
   IF msii_temp_data.PAYMENT_TERMS_ID IS NULL THEN
      msii_temp_data.PAYMENT_TERMS_ID := msi_record_temp.PAYMENT_TERMS_ID;
   ELSIF msii_temp_data.PAYMENT_TERMS_ID    = -999999 THEN
      msii_temp_data.PAYMENT_TERMS_ID := NULL;
   ELSIF msii_temp_data.PAYMENT_TERMS_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.PAYMENT_TERMS_ID := NULL;
   END IF;
   IF msii_temp_data.SECONDARY_SPECIALIST_ID is null then
      msii_temp_data.SECONDARY_SPECIALIST_ID := msi_record_temp.SECONDARY_SPECIALIST_ID;
   END IF;
   IF msii_temp_data.MATERIAL_BILLABLE_FLAG IS NULL THEN
      msii_temp_data.MATERIAL_BILLABLE_FLAG := msi_record_temp.MATERIAL_BILLABLE_FLAG;
   ELSIF msii_temp_data.MATERIAL_BILLABLE_FLAG    = '!' THEN
      msii_temp_data.MATERIAL_BILLABLE_FLAG := NULL;
   ELSIF msii_temp_data.MATERIAL_BILLABLE_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.MATERIAL_BILLABLE_FLAG := NULL;
   ELSE
      msii_temp_data.MATERIAL_BILLABLE_FLAG := trim(msii_temp_data.MATERIAL_BILLABLE_FLAG);
   END IF;
   IF msii_temp_data.COVERAGE_SCHEDULE_ID IS NULL THEN
      msii_temp_data.COVERAGE_SCHEDULE_ID := msi_record_temp.COVERAGE_SCHEDULE_ID;
   ELSIF msii_temp_data.COVERAGE_SCHEDULE_ID    = -999999 THEN
      msii_temp_data.COVERAGE_SCHEDULE_ID := NULL;
   ELSIF msii_temp_data.COVERAGE_SCHEDULE_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.COVERAGE_SCHEDULE_ID := NULL;
   END IF;
   IF msii_temp_data.WARRANTY_VENDOR_ID is null then
      msii_temp_data.WARRANTY_VENDOR_ID := msi_record_temp.WARRANTY_VENDOR_ID;
   END IF;
   IF trim(msii_temp_data.RESPONSE_TIME_PERIOD_CODE) is null then
      msii_temp_data.RESPONSE_TIME_PERIOD_CODE := msi_record_temp.RESPONSE_TIME_PERIOD_CODE;
   ELSE
      msii_temp_data.RESPONSE_TIME_PERIOD_CODE := trim(msii_temp_data.RESPONSE_TIME_PERIOD_CODE);
   END IF;
   IF msii_temp_data.TAX_CODE IS NULL THEN
      msii_temp_data.TAX_CODE := msi_record_temp.TAX_CODE;
   ELSIF msii_temp_data.TAX_CODE    = '!' THEN
      msii_temp_data.TAX_CODE := NULL;
   ELSIF msii_temp_data.TAX_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.TAX_CODE := NULL;
   ELSE
      msii_temp_data.TAX_CODE := trim(msii_temp_data.TAX_CODE);
   END IF;
   IF trim(msii_temp_data.MUST_USE_APPROVED_VENDOR_FLAG) is null then
      msii_temp_data.MUST_USE_APPROVED_VENDOR_FLAG := msi_record_temp.MUST_USE_APPROVED_VENDOR_FLAG;
   ELSE
      msii_temp_data.MUST_USE_APPROVED_VENDOR_FLAG := trim(msii_temp_data.MUST_USE_APPROVED_VENDOR_FLAG);
   END IF;
   IF trim(msii_temp_data.OUTSIDE_OPERATION_FLAG) is null then
      msii_temp_data.OUTSIDE_OPERATION_FLAG := msi_record_temp.OUTSIDE_OPERATION_FLAG;
   ELSE
      msii_temp_data.OUTSIDE_OPERATION_FLAG := trim(msii_temp_data.OUTSIDE_OPERATION_FLAG);
   END IF;
   IF msii_temp_data.AUTO_REDUCE_MPS IS NULL THEN
      msii_temp_data.AUTO_REDUCE_MPS := msi_record_temp.AUTO_REDUCE_MPS;
   ELSIF msii_temp_data.AUTO_REDUCE_MPS    = -999999 THEN
      msii_temp_data.AUTO_REDUCE_MPS := NULL;
   ELSIF msii_temp_data.AUTO_REDUCE_MPS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.AUTO_REDUCE_MPS := NULL;
   ELSE
      msii_temp_data.AUTO_REDUCE_MPS := trim(msii_temp_data.AUTO_REDUCE_MPS);
   END IF;
   IF trim(msii_temp_data.AUTO_CREATED_CONFIG_FLAG) is null then
      msii_temp_data.AUTO_CREATED_CONFIG_FLAG := msi_record_temp.AUTO_CREATED_CONFIG_FLAG;
   ELSE
      msii_temp_data.AUTO_CREATED_CONFIG_FLAG := trim(msii_temp_data.AUTO_CREATED_CONFIG_FLAG);
   END IF;
   IF trim(msii_temp_data.SHIP_MODEL_COMPLETE_FLAG) is null then
      msii_temp_data.SHIP_MODEL_COMPLETE_FLAG := msi_record_temp.SHIP_MODEL_COMPLETE_FLAG;
   ELSE
      msii_temp_data.SHIP_MODEL_COMPLETE_FLAG := trim(msii_temp_data.SHIP_MODEL_COMPLETE_FLAG);
   END IF;
   IF msii_temp_data.ATO_FORECAST_CONTROL IS NULL THEN
      msii_temp_data.ATO_FORECAST_CONTROL := msi_record_temp.ATO_FORECAST_CONTROL;
   ELSIF msii_temp_data.ATO_FORECAST_CONTROL    = -999999 THEN
      msii_temp_data.ATO_FORECAST_CONTROL := NULL;
   ELSIF msii_temp_data.ATO_FORECAST_CONTROL    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ATO_FORECAST_CONTROL := NULL;
   END IF;
   IF msii_temp_data.MAXIMUM_LOAD_WEIGHT IS NULL THEN
      msii_temp_data.MAXIMUM_LOAD_WEIGHT := msi_record_temp.MAXIMUM_LOAD_WEIGHT;
   ELSIF msii_temp_data.MAXIMUM_LOAD_WEIGHT    = -999999 THEN
      msii_temp_data.MAXIMUM_LOAD_WEIGHT := NULL;
   ELSIF msii_temp_data.MAXIMUM_LOAD_WEIGHT    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.MAXIMUM_LOAD_WEIGHT := NULL;
   END IF;
   IF msii_temp_data.INTERNAL_VOLUME IS NULL THEN
      msii_temp_data.INTERNAL_VOLUME := msi_record_temp.INTERNAL_VOLUME;
   ELSIF msii_temp_data.INTERNAL_VOLUME    = -999999 THEN
      msii_temp_data.INTERNAL_VOLUME := NULL;
   ELSIF msii_temp_data.INTERNAL_VOLUME    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.INTERNAL_VOLUME := NULL;
   END IF;
   IF msii_temp_data.OVERCOMPLETION_TOLERANCE_TYPE IS NULL THEN
      msii_temp_data.OVERCOMPLETION_TOLERANCE_TYPE := msi_record_temp.OVERCOMPLETION_TOLERANCE_TYPE;
   ELSIF msii_temp_data.OVERCOMPLETION_TOLERANCE_TYPE    = g_Upd_Null_NUM THEN
      msii_temp_data.OVERCOMPLETION_TOLERANCE_TYPE := NULL;
   ELSIF msii_temp_data.OVERCOMPLETION_TOLERANCE_TYPE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.OVERCOMPLETION_TOLERANCE_TYPE := NULL;
   END IF;
   IF trim(msii_temp_data.RECIPE_ENABLED_FLAG) is null then
       IF msii_temp_data.INVENTORY_ITEM_STATUS_CODE IS NULL THEN
          msii_temp_data.RECIPE_ENABLED_FLAG := msi_record_temp.RECIPE_ENABLED_FLAG;
       END IF;
   ELSE
      msii_temp_data.RECIPE_ENABLED_FLAG := trim(msii_temp_data.RECIPE_ENABLED_FLAG);
   END IF;
   IF msii_temp_data.REVISION_QTY_CONTROL_CODE is null then
      msii_temp_data.REVISION_QTY_CONTROL_CODE := msi_record_temp.REVISION_QTY_CONTROL_CODE;
   END IF;
   IF msii_temp_data.CATALOG_STATUS_FLAG IS NULL THEN
      msii_temp_data.CATALOG_STATUS_FLAG := msi_record_temp.CATALOG_STATUS_FLAG;
   ELSIF msii_temp_data.CATALOG_STATUS_FLAG    = '!' THEN
      msii_temp_data.CATALOG_STATUS_FLAG := NULL;
   ELSIF msii_temp_data.CATALOG_STATUS_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.CATALOG_STATUS_FLAG := NULL;
   ELSE
      msii_temp_data.CATALOG_STATUS_FLAG := trim(msii_temp_data.CATALOG_STATUS_FLAG);
   END IF;
   IF trim(msii_temp_data.COLLATERAL_FLAG) is null then
      msii_temp_data.COLLATERAL_FLAG := msi_record_temp.COLLATERAL_FLAG;
   ELSE
      msii_temp_data.COLLATERAL_FLAG := trim(msii_temp_data.COLLATERAL_FLAG);
   END IF;
   IF msii_temp_data.PURCHASING_TAX_CODE IS NULL THEN
      msii_temp_data.PURCHASING_TAX_CODE := msi_record_temp.PURCHASING_TAX_CODE;
   ELSIF msii_temp_data.PURCHASING_TAX_CODE    = '!' THEN
      msii_temp_data.PURCHASING_TAX_CODE := NULL;
   ELSIF msii_temp_data.PURCHASING_TAX_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.PURCHASING_TAX_CODE := NULL;
   ELSE
      msii_temp_data.PURCHASING_TAX_CODE := trim(msii_temp_data.PURCHASING_TAX_CODE);
   END IF;
   IF msii_temp_data.INSPECTION_REQUIRED_FLAG IS NULL THEN
      msii_temp_data.INSPECTION_REQUIRED_FLAG := msi_record_temp.INSPECTION_REQUIRED_FLAG;
   ELSIF msii_temp_data.INSPECTION_REQUIRED_FLAG    = '!' THEN
      msii_temp_data.INSPECTION_REQUIRED_FLAG := NULL;
   ELSIF msii_temp_data.INSPECTION_REQUIRED_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.INSPECTION_REQUIRED_FLAG := NULL;
   ELSE
      msii_temp_data.INSPECTION_REQUIRED_FLAG := trim(msii_temp_data.INSPECTION_REQUIRED_FLAG);
   END IF;
   IF msii_temp_data.MARKET_PRICE IS NULL THEN
      msii_temp_data.MARKET_PRICE := msi_record_temp.MARKET_PRICE;
   ELSIF msii_temp_data.MARKET_PRICE    = -999999 THEN
      msii_temp_data.MARKET_PRICE := NULL;
   ELSIF msii_temp_data.MARKET_PRICE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.MARKET_PRICE := NULL;
   END IF;
   IF msii_temp_data.LIST_PRICE_PER_UNIT IS NULL THEN
      msii_temp_data.LIST_PRICE_PER_UNIT := msi_record_temp.LIST_PRICE_PER_UNIT;
   ELSIF msii_temp_data.LIST_PRICE_PER_UNIT    = -999999 THEN
      msii_temp_data.LIST_PRICE_PER_UNIT := NULL;
   ELSIF msii_temp_data.LIST_PRICE_PER_UNIT    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.LIST_PRICE_PER_UNIT := NULL;
   END IF;
   IF msii_temp_data.PRICE_TOLERANCE_PERCENT IS NULL THEN
      msii_temp_data.PRICE_TOLERANCE_PERCENT := msi_record_temp.PRICE_TOLERANCE_PERCENT;
   ELSIF msii_temp_data.PRICE_TOLERANCE_PERCENT    = -999999 THEN
      msii_temp_data.PRICE_TOLERANCE_PERCENT := NULL;
   ELSIF msii_temp_data.PRICE_TOLERANCE_PERCENT    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.PRICE_TOLERANCE_PERCENT := NULL;
   END IF;
   IF msii_temp_data.UNIT_OF_ISSUE IS NULL THEN
      msii_temp_data.UNIT_OF_ISSUE := msi_record_temp.UNIT_OF_ISSUE;
   ELSIF msii_temp_data.UNIT_OF_ISSUE    = '!' THEN
      msii_temp_data.UNIT_OF_ISSUE := NULL;
   ELSIF msii_temp_data.UNIT_OF_ISSUE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.UNIT_OF_ISSUE := NULL;
   ELSE
      msii_temp_data.UNIT_OF_ISSUE := trim(msii_temp_data.UNIT_OF_ISSUE);
   END IF;
   IF msii_temp_data.ALLOW_SUBSTITUTE_RECEIPTS_FLAG IS NULL THEN
      msii_temp_data.ALLOW_SUBSTITUTE_RECEIPTS_FLAG := msi_record_temp.ALLOW_SUBSTITUTE_RECEIPTS_FLAG;
   ELSIF msii_temp_data.ALLOW_SUBSTITUTE_RECEIPTS_FLAG    = '!' THEN
      msii_temp_data.ALLOW_SUBSTITUTE_RECEIPTS_FLAG := NULL;
   ELSIF msii_temp_data.ALLOW_SUBSTITUTE_RECEIPTS_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ALLOW_SUBSTITUTE_RECEIPTS_FLAG := NULL;
   ELSE
      msii_temp_data.ALLOW_SUBSTITUTE_RECEIPTS_FLAG := trim(msii_temp_data.ALLOW_SUBSTITUTE_RECEIPTS_FLAG);
   END IF;
   IF msii_temp_data.ALLOW_EXPRESS_DELIVERY_FLAG IS NULL THEN
      msii_temp_data.ALLOW_EXPRESS_DELIVERY_FLAG := msi_record_temp.ALLOW_EXPRESS_DELIVERY_FLAG;
   ELSIF msii_temp_data.ALLOW_EXPRESS_DELIVERY_FLAG    = '!' THEN
      msii_temp_data.ALLOW_EXPRESS_DELIVERY_FLAG := NULL;
   ELSIF msii_temp_data.ALLOW_EXPRESS_DELIVERY_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ALLOW_EXPRESS_DELIVERY_FLAG := NULL;
   ELSE
      msii_temp_data.ALLOW_EXPRESS_DELIVERY_FLAG := trim(msii_temp_data.ALLOW_EXPRESS_DELIVERY_FLAG);
   END IF;
   IF msii_temp_data.RECEIPT_DAYS_EXCEPTION_CODE IS NULL THEN
      msii_temp_data.RECEIPT_DAYS_EXCEPTION_CODE := msi_record_temp.RECEIPT_DAYS_EXCEPTION_CODE;
   ELSIF msii_temp_data.RECEIPT_DAYS_EXCEPTION_CODE    = '!' THEN
      msii_temp_data.RECEIPT_DAYS_EXCEPTION_CODE := NULL;
   ELSIF msii_temp_data.RECEIPT_DAYS_EXCEPTION_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.RECEIPT_DAYS_EXCEPTION_CODE := NULL;
   ELSE
      msii_temp_data.RECEIPT_DAYS_EXCEPTION_CODE := trim(msii_temp_data.RECEIPT_DAYS_EXCEPTION_CODE);
   END IF;
   IF msii_temp_data.RECEIVE_CLOSE_TOLERANCE IS NULL THEN
      msii_temp_data.RECEIVE_CLOSE_TOLERANCE := msi_record_temp.RECEIVE_CLOSE_TOLERANCE;
   ELSIF msii_temp_data.RECEIVE_CLOSE_TOLERANCE    = -999999 THEN
      msii_temp_data.RECEIVE_CLOSE_TOLERANCE := NULL;
   ELSIF msii_temp_data.RECEIVE_CLOSE_TOLERANCE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.RECEIVE_CLOSE_TOLERANCE := NULL;
   END IF;
   IF msii_temp_data.START_AUTO_LOT_NUMBER IS NULL THEN
      msii_temp_data.START_AUTO_LOT_NUMBER := msi_record_temp.START_AUTO_LOT_NUMBER;
   ELSIF msii_temp_data.START_AUTO_LOT_NUMBER    = '!' THEN
      msii_temp_data.START_AUTO_LOT_NUMBER := NULL;
   ELSIF msii_temp_data.START_AUTO_LOT_NUMBER    = g_FND_Upd_Null_Char THEN
      msii_temp_data.START_AUTO_LOT_NUMBER := NULL;
   ELSE
      msii_temp_data.START_AUTO_LOT_NUMBER := trim(msii_temp_data.START_AUTO_LOT_NUMBER);
   END IF;
   IF msii_temp_data.SERIAL_NUMBER_CONTROL_CODE is null then
      msii_temp_data.SERIAL_NUMBER_CONTROL_CODE := msi_record_temp.SERIAL_NUMBER_CONTROL_CODE;
   END IF;
   IF msii_temp_data.AUTO_SERIAL_ALPHA_PREFIX IS NULL THEN
      msii_temp_data.AUTO_SERIAL_ALPHA_PREFIX := msi_record_temp.AUTO_SERIAL_ALPHA_PREFIX;
   ELSIF msii_temp_data.AUTO_SERIAL_ALPHA_PREFIX    = '!' THEN
      msii_temp_data.AUTO_SERIAL_ALPHA_PREFIX := NULL;
   ELSIF msii_temp_data.AUTO_SERIAL_ALPHA_PREFIX    = g_FND_Upd_Null_Char THEN
      msii_temp_data.AUTO_SERIAL_ALPHA_PREFIX := NULL;
   ELSE
      msii_temp_data.AUTO_SERIAL_ALPHA_PREFIX := trim(msii_temp_data.AUTO_SERIAL_ALPHA_PREFIX);
   END IF;
   IF msii_temp_data.SOURCE_ORGANIZATION_ID IS NULL THEN
      msii_temp_data.SOURCE_ORGANIZATION_ID := msi_record_temp.SOURCE_ORGANIZATION_ID;
   ELSIF msii_temp_data.SOURCE_ORGANIZATION_ID    = -999999 THEN
      msii_temp_data.SOURCE_ORGANIZATION_ID := NULL;
   ELSIF msii_temp_data.SOURCE_ORGANIZATION_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SOURCE_ORGANIZATION_ID := NULL;
   END IF;
   IF msii_temp_data.ENCUMBRANCE_ACCOUNT IS NULL THEN
      msii_temp_data.ENCUMBRANCE_ACCOUNT := msi_record_temp.ENCUMBRANCE_ACCOUNT;
   ELSIF msii_temp_data.ENCUMBRANCE_ACCOUNT    = -999999 THEN
      msii_temp_data.ENCUMBRANCE_ACCOUNT := NULL;
   ELSIF msii_temp_data.ENCUMBRANCE_ACCOUNT    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ENCUMBRANCE_ACCOUNT := NULL;
   END IF;
   IF msii_temp_data.WEIGHT_UOM_CODE IS NULL THEN
      msii_temp_data.WEIGHT_UOM_CODE := msi_record_temp.WEIGHT_UOM_CODE;
   ELSIF msii_temp_data.WEIGHT_UOM_CODE    = '!' THEN
      msii_temp_data.WEIGHT_UOM_CODE := NULL;
   ELSIF msii_temp_data.WEIGHT_UOM_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.WEIGHT_UOM_CODE := NULL;
   ELSE
      msii_temp_data.WEIGHT_UOM_CODE := trim(msii_temp_data.WEIGHT_UOM_CODE);
   END IF;
   IF trim(msii_temp_data.SEGMENT16) is null then
      msii_temp_data.SEGMENT16 := msi_record_temp.SEGMENT16;
   ELSE
      msii_temp_data.SEGMENT16 := trim(msii_temp_data.SEGMENT16);
   END IF;
   IF trim(msii_temp_data.SEGMENT17) is null then
      msii_temp_data.SEGMENT17 := msi_record_temp.SEGMENT17;
   ELSE
      msii_temp_data.SEGMENT17 := trim(msii_temp_data.SEGMENT17);
   END IF;
   msii_temp_data.PROCESS_FLAG := l_process_flag_2;
   IF trim(msii_temp_data.SUMMARY_FLAG) is null then
      msii_temp_data.SUMMARY_FLAG := msi_record_temp.SUMMARY_FLAG;
   ELSE
      msii_temp_data.SUMMARY_FLAG := trim(msii_temp_data.SUMMARY_FLAG);
   END IF;
   IF trim(msii_temp_data.ENABLED_FLAG) is null then
      msii_temp_data.ENABLED_FLAG := msi_record_temp.ENABLED_FLAG;
   ELSE
      msii_temp_data.ENABLED_FLAG := trim(msii_temp_data.ENABLED_FLAG);
   END IF;
   IF msii_temp_data.START_DATE_ACTIVE is null then
      msii_temp_data.START_DATE_ACTIVE := msi_record_temp.START_DATE_ACTIVE;
   END IF;
   IF msii_temp_data.END_DATE_ACTIVE is null then
      msii_temp_data.END_DATE_ACTIVE := msi_record_temp.END_DATE_ACTIVE;
   END IF;
   IF msii_temp_data.ACCOUNTING_RULE_ID IS NULL THEN
      msii_temp_data.ACCOUNTING_RULE_ID := msi_record_temp.ACCOUNTING_RULE_ID;
   ELSIF msii_temp_data.ACCOUNTING_RULE_ID    = -999999 THEN
      msii_temp_data.ACCOUNTING_RULE_ID := NULL;
   ELSIF msii_temp_data.ACCOUNTING_RULE_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ACCOUNTING_RULE_ID := NULL;
   END IF;
   IF trim(msii_temp_data.SEGMENT1) is null then
      msii_temp_data.SEGMENT1 := msi_record_temp.SEGMENT1;
   ELSE
      msii_temp_data.SEGMENT1 := trim(msii_temp_data.SEGMENT1);
   END IF;
   IF trim(msii_temp_data.SEGMENT2) is null then
      msii_temp_data.SEGMENT2 := msi_record_temp.SEGMENT2;
   ELSE
      msii_temp_data.SEGMENT2 := trim(msii_temp_data.SEGMENT2);
   END IF;
   IF trim(msii_temp_data.SEGMENT3) is null then
      msii_temp_data.SEGMENT3 := msi_record_temp.SEGMENT3;
   ELSE
      msii_temp_data.SEGMENT3 := trim(msii_temp_data.SEGMENT3);
   END IF;
   IF trim(msii_temp_data.SEGMENT4) is null then
      msii_temp_data.SEGMENT4 := msi_record_temp.SEGMENT4;
   ELSE
      msii_temp_data.SEGMENT4 := trim(msii_temp_data.SEGMENT4);
   END IF;
   IF trim(msii_temp_data.SEGMENT5) is null then
      msii_temp_data.SEGMENT5 := msi_record_temp.SEGMENT5;
   ELSE
      msii_temp_data.SEGMENT5 := trim(msii_temp_data.SEGMENT5);
   END IF;
   IF trim(msii_temp_data.SEGMENT7) is null then
      msii_temp_data.SEGMENT7 := msi_record_temp.SEGMENT7;
   ELSE
      msii_temp_data.SEGMENT7 := trim(msii_temp_data.SEGMENT7);
   END IF;
   IF trim(msii_temp_data.SEGMENT9) is null then
      msii_temp_data.SEGMENT9 := msi_record_temp.SEGMENT9;
   ELSE
      msii_temp_data.SEGMENT9 := trim(msii_temp_data.SEGMENT9);
   END IF;
   IF trim(msii_temp_data.SEGMENT10) is null then
      msii_temp_data.SEGMENT10 := msi_record_temp.SEGMENT10;
   ELSE
      msii_temp_data.SEGMENT10 := trim(msii_temp_data.SEGMENT10);
   END IF;
   IF trim(msii_temp_data.SEGMENT12) is null then
      msii_temp_data.SEGMENT12 := msi_record_temp.SEGMENT12;
   ELSE
      msii_temp_data.SEGMENT12 := trim(msii_temp_data.SEGMENT12);
   END IF;
   IF trim(msii_temp_data.SEGMENT13) is null then
      msii_temp_data.SEGMENT13 := msi_record_temp.SEGMENT13;
   ELSE
      msii_temp_data.SEGMENT13 := trim(msii_temp_data.SEGMENT13);
   END IF;
   IF trim(msii_temp_data.SEGMENT15) is null then
      msii_temp_data.SEGMENT15 := msi_record_temp.SEGMENT15;
   ELSE
      msii_temp_data.SEGMENT15 := trim(msii_temp_data.SEGMENT15);
   END IF;
   IF trim(msii_temp_data.SEGMENT18) is null then
      msii_temp_data.SEGMENT18 := msi_record_temp.SEGMENT18;
   ELSE
      msii_temp_data.SEGMENT18 := trim(msii_temp_data.SEGMENT18);
   END IF;
   IF trim(msii_temp_data.SEGMENT20) is null then
      msii_temp_data.SEGMENT20 := msi_record_temp.SEGMENT20;
   ELSE
      msii_temp_data.SEGMENT20 := trim(msii_temp_data.SEGMENT20);
   END IF;
   IF msii_temp_data.ATTRIBUTE1 IS NULL THEN
      msii_temp_data.ATTRIBUTE1 := msi_record_temp.ATTRIBUTE1;
   ELSIF msii_temp_data.ATTRIBUTE1    = '!' THEN
      msii_temp_data.ATTRIBUTE1 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE1    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE1 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE1 := trim(msii_temp_data.ATTRIBUTE1);
   END IF;
   IF msii_temp_data.ATTRIBUTE2 IS NULL THEN
      msii_temp_data.ATTRIBUTE2 := msi_record_temp.ATTRIBUTE2;
   ELSIF msii_temp_data.ATTRIBUTE2    = '!' THEN
      msii_temp_data.ATTRIBUTE2 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE2    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE2 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE2 := trim(msii_temp_data.ATTRIBUTE2);
   END IF;
   IF msii_temp_data.ATTRIBUTE4 IS NULL THEN
      msii_temp_data.ATTRIBUTE4 := msi_record_temp.ATTRIBUTE4;
   ELSIF msii_temp_data.ATTRIBUTE4    = '!' THEN
      msii_temp_data.ATTRIBUTE4 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE4    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE4 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE4 := trim(msii_temp_data.ATTRIBUTE4);
   END IF;
   IF msii_temp_data.ATTRIBUTE6 IS NULL THEN
      msii_temp_data.ATTRIBUTE6 := msi_record_temp.ATTRIBUTE6;
   ELSIF msii_temp_data.ATTRIBUTE6    = '!' THEN
      msii_temp_data.ATTRIBUTE6 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE6    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE6 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE6 := trim(msii_temp_data.ATTRIBUTE6);
   END IF;
   IF msii_temp_data.ATTRIBUTE8 IS NULL THEN
      msii_temp_data.ATTRIBUTE8 := msi_record_temp.ATTRIBUTE8;
   ELSIF msii_temp_data.ATTRIBUTE8    = '!' THEN
      msii_temp_data.ATTRIBUTE8 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE8    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE8 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE8 := trim(msii_temp_data.ATTRIBUTE8);
   END IF;
   IF msii_temp_data.ATTRIBUTE9 IS NULL THEN
      msii_temp_data.ATTRIBUTE9 := msi_record_temp.ATTRIBUTE9;
   ELSIF msii_temp_data.ATTRIBUTE9    = '!' THEN
      msii_temp_data.ATTRIBUTE9 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE9    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE9 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE9 := trim(msii_temp_data.ATTRIBUTE9);
   END IF;
   IF msii_temp_data.ATTRIBUTE11 IS NULL THEN
      msii_temp_data.ATTRIBUTE11 := msi_record_temp.ATTRIBUTE11;
   ELSIF msii_temp_data.ATTRIBUTE11    = '!' THEN
      msii_temp_data.ATTRIBUTE11 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE11    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE11 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE11 := trim(msii_temp_data.ATTRIBUTE11);
   END IF;
   IF msii_temp_data.ATTRIBUTE13 IS NULL THEN
      msii_temp_data.ATTRIBUTE13 := msi_record_temp.ATTRIBUTE13;
   ELSIF msii_temp_data.ATTRIBUTE13    = '!' THEN
      msii_temp_data.ATTRIBUTE13 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE13    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE13 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE13 := trim(msii_temp_data.ATTRIBUTE13);
   END IF;
   IF msii_temp_data.ATTRIBUTE15 IS NULL THEN
      msii_temp_data.ATTRIBUTE15 := msi_record_temp.ATTRIBUTE15;
   ELSIF msii_temp_data.ATTRIBUTE15    = '!' THEN
      msii_temp_data.ATTRIBUTE15 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE15    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE15 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE15 := trim(msii_temp_data.ATTRIBUTE15);
   END IF;
   IF msii_temp_data.ATTRIBUTE16 IS NULL THEN
      msii_temp_data.ATTRIBUTE16 := msi_record_temp.ATTRIBUTE16;
   ELSIF msii_temp_data.ATTRIBUTE16    = '!' THEN
      msii_temp_data.ATTRIBUTE16 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE16    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE16 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE16 := trim(msii_temp_data.ATTRIBUTE16);
   END IF;
   IF msii_temp_data.ATTRIBUTE18 IS NULL THEN
      msii_temp_data.ATTRIBUTE18 := msi_record_temp.ATTRIBUTE18;
   ELSIF msii_temp_data.ATTRIBUTE18    = '!' THEN
      msii_temp_data.ATTRIBUTE18 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE18    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE18 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE18 := trim(msii_temp_data.ATTRIBUTE18);
   END IF;
   IF msii_temp_data.ATTRIBUTE20 IS NULL THEN
      msii_temp_data.ATTRIBUTE20 := msi_record_temp.ATTRIBUTE20;
   ELSIF msii_temp_data.ATTRIBUTE20    = '!' THEN
      msii_temp_data.ATTRIBUTE20 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE20    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE20 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE20 := trim(msii_temp_data.ATTRIBUTE20);
   END IF;
   IF msii_temp_data.ATTRIBUTE22 IS NULL THEN
      msii_temp_data.ATTRIBUTE22 := msi_record_temp.ATTRIBUTE22;
   ELSIF msii_temp_data.ATTRIBUTE22    = '!' THEN
      msii_temp_data.ATTRIBUTE22 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE22    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE22 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE22 := trim(msii_temp_data.ATTRIBUTE22);
   END IF;
   IF msii_temp_data.ATTRIBUTE23 IS NULL THEN
      msii_temp_data.ATTRIBUTE23 := msi_record_temp.ATTRIBUTE23;
   ELSIF msii_temp_data.ATTRIBUTE23    = '!' THEN
      msii_temp_data.ATTRIBUTE23 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE23    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE23 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE23 := trim(msii_temp_data.ATTRIBUTE23);
   END IF;
   IF msii_temp_data.ATTRIBUTE25 IS NULL THEN
      msii_temp_data.ATTRIBUTE25 := msi_record_temp.ATTRIBUTE25;
   ELSIF msii_temp_data.ATTRIBUTE25    = '!' THEN
      msii_temp_data.ATTRIBUTE25 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE25    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE25 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE25 := trim(msii_temp_data.ATTRIBUTE25);
   END IF;
   IF msii_temp_data.ATTRIBUTE27 IS NULL THEN
      msii_temp_data.ATTRIBUTE27 := msi_record_temp.ATTRIBUTE27;
   ELSIF msii_temp_data.ATTRIBUTE27    = '!' THEN
      msii_temp_data.ATTRIBUTE27 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE27    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE27 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE27 := trim(msii_temp_data.ATTRIBUTE27);
   END IF;
   IF msii_temp_data.ATTRIBUTE29 IS NULL THEN
      msii_temp_data.ATTRIBUTE29 := msi_record_temp.ATTRIBUTE29;
   ELSIF msii_temp_data.ATTRIBUTE29    = '!' THEN
      msii_temp_data.ATTRIBUTE29 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE29    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE29 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE29 := trim(msii_temp_data.ATTRIBUTE29);
   END IF;
   IF msii_temp_data.ATTRIBUTE30 IS NULL THEN
      msii_temp_data.ATTRIBUTE30 := msi_record_temp.ATTRIBUTE30;
   ELSIF msii_temp_data.ATTRIBUTE30    = '!' THEN
      msii_temp_data.ATTRIBUTE30 := NULL;
   ELSIF msii_temp_data.ATTRIBUTE30    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ATTRIBUTE30 := NULL;
   ELSE
      msii_temp_data.ATTRIBUTE30 := trim(msii_temp_data.ATTRIBUTE30);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE1 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE1 := msi_record_temp.GLOBAL_ATTRIBUTE1;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE1    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE1 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE1    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE1 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE1 := trim(msii_temp_data.GLOBAL_ATTRIBUTE1);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE3 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE3 := msi_record_temp.GLOBAL_ATTRIBUTE3;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE3    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE3 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE3    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE3 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE3 := trim(msii_temp_data.GLOBAL_ATTRIBUTE3);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE4 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE4 := msi_record_temp.GLOBAL_ATTRIBUTE4;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE4    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE4 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE4    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE4 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE4 := trim(msii_temp_data.GLOBAL_ATTRIBUTE4);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE6 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE6 := msi_record_temp.GLOBAL_ATTRIBUTE6;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE6    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE6 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE6    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE6 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE6 := trim(msii_temp_data.GLOBAL_ATTRIBUTE6);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE8 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE8 := msi_record_temp.GLOBAL_ATTRIBUTE8;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE8    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE8 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE8    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE8 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE8 := trim(msii_temp_data.GLOBAL_ATTRIBUTE8);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE10 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE10 := msi_record_temp.GLOBAL_ATTRIBUTE10;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE10    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE10 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE10    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE10 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE10 := trim(msii_temp_data.GLOBAL_ATTRIBUTE10);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE11 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE11 := msi_record_temp.GLOBAL_ATTRIBUTE11;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE11    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE11 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE11    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE11 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE11 := trim(msii_temp_data.GLOBAL_ATTRIBUTE11);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE12 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE12 := msi_record_temp.GLOBAL_ATTRIBUTE12;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE12  = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE12 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE12  = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE12 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE12 := trim(msii_temp_data.GLOBAL_ATTRIBUTE12);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE13 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE13 := msi_record_temp.GLOBAL_ATTRIBUTE13;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE13    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE13 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE13    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE13 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE13 := trim(msii_temp_data.GLOBAL_ATTRIBUTE13);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE14 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE14 := msi_record_temp.GLOBAL_ATTRIBUTE14;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE14    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE14 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE14    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE14 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE14 := trim(msii_temp_data.GLOBAL_ATTRIBUTE14);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE15 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE15 := msi_record_temp.GLOBAL_ATTRIBUTE15;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE15    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE15 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE15    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE15 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE15 := trim(msii_temp_data.GLOBAL_ATTRIBUTE15);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE16 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE16 := msi_record_temp.GLOBAL_ATTRIBUTE16;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE16    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE16 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE16    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE16 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE16 := trim(msii_temp_data.GLOBAL_ATTRIBUTE16);
   END IF;

  IF msii_temp_data.GLOBAL_ATTRIBUTE17 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE17 := msi_record_temp.GLOBAL_ATTRIBUTE17;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE17    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE17 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE17    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE17 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE17 := trim(msii_temp_data.GLOBAL_ATTRIBUTE17);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE18 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE18 := msi_record_temp.GLOBAL_ATTRIBUTE18;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE18    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE18 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE18    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE18 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE18 := trim(msii_temp_data.GLOBAL_ATTRIBUTE18);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE19 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE19 := msi_record_temp.GLOBAL_ATTRIBUTE19;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE19    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE19 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE19    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE19 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE19 := trim(msii_temp_data.GLOBAL_ATTRIBUTE19);
   END IF;
   IF msii_temp_data.GLOBAL_ATTRIBUTE20 IS NULL THEN
      msii_temp_data.GLOBAL_ATTRIBUTE20 := msi_record_temp.GLOBAL_ATTRIBUTE20;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE20    = '!' THEN
      msii_temp_data.GLOBAL_ATTRIBUTE20 := NULL;
   ELSIF msii_temp_data.GLOBAL_ATTRIBUTE20    = g_FND_Upd_Null_Char THEN
      msii_temp_data.GLOBAL_ATTRIBUTE20 := NULL;
   ELSE
      msii_temp_data.GLOBAL_ATTRIBUTE20 := trim(msii_temp_data.GLOBAL_ATTRIBUTE20);
   END IF;

   IF trim(msii_temp_data.PURCHASING_ITEM_FLAG) is null then
      msii_temp_data.PURCHASING_ITEM_FLAG := msi_record_temp.PURCHASING_ITEM_FLAG;
   ELSE
      msii_temp_data.PURCHASING_ITEM_FLAG := trim(msii_temp_data.PURCHASING_ITEM_FLAG);
   END IF;
   IF trim(msii_temp_data.SHIPPABLE_ITEM_FLAG) is null then
      msii_temp_data.SHIPPABLE_ITEM_FLAG := msi_record_temp.SHIPPABLE_ITEM_FLAG;
   ELSE
      msii_temp_data.SHIPPABLE_ITEM_FLAG := trim(msii_temp_data.SHIPPABLE_ITEM_FLAG);
   END IF;
   IF trim(msii_temp_data.INTERNAL_ORDER_FLAG) is null then
      msii_temp_data.INTERNAL_ORDER_FLAG := msi_record_temp.INTERNAL_ORDER_FLAG;
   ELSE
      msii_temp_data.INTERNAL_ORDER_FLAG := trim(msii_temp_data.INTERNAL_ORDER_FLAG);
   END IF;
   IF trim(msii_temp_data.INVENTORY_ITEM_FLAG) is null then
      msii_temp_data.INVENTORY_ITEM_FLAG := msi_record_temp.INVENTORY_ITEM_FLAG;
   ELSE
      msii_temp_data.INVENTORY_ITEM_FLAG := trim(msii_temp_data.INVENTORY_ITEM_FLAG);
   END IF;
   IF trim(msii_temp_data.INVENTORY_ASSET_FLAG) is null then
      msii_temp_data.INVENTORY_ASSET_FLAG := msi_record_temp.INVENTORY_ASSET_FLAG;
   ELSE
      msii_temp_data.INVENTORY_ASSET_FLAG := trim(msii_temp_data.INVENTORY_ASSET_FLAG);
   END IF;
   IF Trim(msii_temp_data.CUSTOMER_ORDER_ENABLED_FLAG) IS NULL THEN
       IF msii_temp_data.INVENTORY_ITEM_STATUS_CODE IS NULL THEN
          msii_temp_data.CUSTOMER_ORDER_ENABLED_FLAG := msi_record_temp.CUSTOMER_ORDER_ENABLED_FLAG;
       END IF;
   ELSE
      msii_temp_data.CUSTOMER_ORDER_ENABLED_FLAG := trim(msii_temp_data.CUSTOMER_ORDER_ENABLED_FLAG);
   END IF;
   IF trim(msii_temp_data.MTL_TRANSACTIONS_ENABLED_FLAG) is null then
      IF msii_temp_data.inventory_item_status_code IS NULL THEN
         msii_temp_data.MTL_TRANSACTIONS_ENABLED_FLAG := msi_record_temp.MTL_TRANSACTIONS_ENABLED_FLAG;
      END IF;
   ELSE
      msii_temp_data.MTL_TRANSACTIONS_ENABLED_FLAG := trim(msii_temp_data.MTL_TRANSACTIONS_ENABLED_FLAG);
   END IF;
   IF trim(msii_temp_data.STOCK_ENABLED_FLAG) is null then
      if msii_temp_data.inventory_item_status_code IS NULL THEN
         msii_temp_data.STOCK_ENABLED_FLAG := msi_record_temp.STOCK_ENABLED_FLAG;
      END IF;
   ELSE
      msii_temp_data.STOCK_ENABLED_FLAG := trim(msii_temp_data.STOCK_ENABLED_FLAG);
   END IF;
   IF trim(msii_temp_data.BUILD_IN_WIP_FLAG) is null then
      IF msii_temp_data.inventory_item_status_code is null then
         msii_temp_data.BUILD_IN_WIP_FLAG := msi_record_temp.BUILD_IN_WIP_FLAG;
      END IF;
   ELSE
      msii_temp_data.BUILD_IN_WIP_FLAG := trim(msii_temp_data.BUILD_IN_WIP_FLAG);
   END IF;
   IF trim(msii_temp_data.SO_TRANSACTIONS_FLAG) is null then
      msii_temp_data.SO_TRANSACTIONS_FLAG := msi_record_temp.SO_TRANSACTIONS_FLAG;
   ELSE
      msii_temp_data.SO_TRANSACTIONS_FLAG := trim(msii_temp_data.SO_TRANSACTIONS_FLAG);
   END IF;
   IF trim(msii_temp_data.PROCESS_EXECUTION_ENABLED_FLAG) is null then
      IF msii_temp_data.inventory_item_status_code is null then
         msii_temp_data.PROCESS_EXECUTION_ENABLED_FLAG := msi_record_temp.PROCESS_EXECUTION_ENABLED_FLAG;
      END IF;
   ELSE
      msii_temp_data.PROCESS_EXECUTION_ENABLED_FLAG := trim(msii_temp_data.PROCESS_EXECUTION_ENABLED_FLAG);
   END IF;
   IF msii_temp_data.ITEM_CATALOG_GROUP_ID IS NULL THEN
      msii_temp_data.ITEM_CATALOG_GROUP_ID := msi_record_temp.ITEM_CATALOG_GROUP_ID;
   ELSIF msii_temp_data.ITEM_CATALOG_GROUP_ID    = -999999 THEN
      msii_temp_data.ITEM_CATALOG_GROUP_ID := NULL;
   ELSIF msii_temp_data.ITEM_CATALOG_GROUP_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ITEM_CATALOG_GROUP_ID := NULL;
   END IF;
   IF trim(msii_temp_data.RETURNABLE_FLAG) is null then
      msii_temp_data.RETURNABLE_FLAG := msi_record_temp.RETURNABLE_FLAG;
   ELSE
      msii_temp_data.RETURNABLE_FLAG := trim(msii_temp_data.RETURNABLE_FLAG);
   END IF;
   IF msii_temp_data.DEFAULT_SHIPPING_ORG IS NULL THEN
      msii_temp_data.DEFAULT_SHIPPING_ORG := msi_record_temp.DEFAULT_SHIPPING_ORG;
   ELSIF msii_temp_data.DEFAULT_SHIPPING_ORG    = -999999 THEN
      msii_temp_data.DEFAULT_SHIPPING_ORG := NULL;
   ELSIF msii_temp_data.DEFAULT_SHIPPING_ORG    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DEFAULT_SHIPPING_ORG := NULL;
   END IF;
   IF msii_temp_data.TAXABLE_FLAG IS NULL THEN
      msii_temp_data.TAXABLE_FLAG := msi_record_temp.TAXABLE_FLAG;
   ELSIF msii_temp_data.TAXABLE_FLAG    = '!' THEN
      msii_temp_data.TAXABLE_FLAG := NULL;
   ELSIF msii_temp_data.TAXABLE_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.TAXABLE_FLAG := NULL;
   ELSE
      msii_temp_data.TAXABLE_FLAG := trim(msii_temp_data.TAXABLE_FLAG);
   END IF;
   IF msii_temp_data.QTY_RCV_EXCEPTION_CODE IS NULL THEN
      msii_temp_data.QTY_RCV_EXCEPTION_CODE := msi_record_temp.QTY_RCV_EXCEPTION_CODE;
   ELSIF msii_temp_data.QTY_RCV_EXCEPTION_CODE    = '!' THEN
      msii_temp_data.QTY_RCV_EXCEPTION_CODE := NULL;
   ELSIF msii_temp_data.QTY_RCV_EXCEPTION_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.QTY_RCV_EXCEPTION_CODE := NULL;
   ELSE
      msii_temp_data.QTY_RCV_EXCEPTION_CODE := trim(msii_temp_data.QTY_RCV_EXCEPTION_CODE);
   END IF;
   IF trim(msii_temp_data.ALLOW_ITEM_DESC_UPDATE_FLAG) is null then
      msii_temp_data.ALLOW_ITEM_DESC_UPDATE_FLAG := msi_record_temp.ALLOW_ITEM_DESC_UPDATE_FLAG;
   ELSE
      msii_temp_data.ALLOW_ITEM_DESC_UPDATE_FLAG := trim(msii_temp_data.ALLOW_ITEM_DESC_UPDATE_FLAG);
   END IF;
   IF msii_temp_data.RECEIPT_REQUIRED_FLAG IS NULL THEN
      msii_temp_data.RECEIPT_REQUIRED_FLAG := msi_record_temp.RECEIPT_REQUIRED_FLAG;
   ELSIF msii_temp_data.RECEIPT_REQUIRED_FLAG    = '!' THEN
      msii_temp_data.RECEIPT_REQUIRED_FLAG := NULL;
   ELSIF msii_temp_data.RECEIPT_REQUIRED_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.RECEIPT_REQUIRED_FLAG := NULL;
   ELSE
      msii_temp_data.RECEIPT_REQUIRED_FLAG := trim(msii_temp_data.RECEIPT_REQUIRED_FLAG);
   END IF;
   IF msii_temp_data.HAZARD_CLASS_ID IS NULL THEN
      msii_temp_data.HAZARD_CLASS_ID := msi_record_temp.HAZARD_CLASS_ID;
   ELSIF msii_temp_data.HAZARD_CLASS_ID    = -999999 THEN
      msii_temp_data.HAZARD_CLASS_ID := NULL;
   ELSIF msii_temp_data.HAZARD_CLASS_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.HAZARD_CLASS_ID := NULL;
   END IF;
   IF msii_temp_data.QTY_RCV_TOLERANCE IS NULL THEN
      msii_temp_data.QTY_RCV_TOLERANCE := msi_record_temp.QTY_RCV_TOLERANCE;
   ELSIF msii_temp_data.QTY_RCV_TOLERANCE    = -999999 THEN
      msii_temp_data.QTY_RCV_TOLERANCE := NULL;
   ELSIF msii_temp_data.QTY_RCV_TOLERANCE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.QTY_RCV_TOLERANCE := NULL;
   END IF;
   IF msii_temp_data.UN_NUMBER_ID IS NULL THEN
      msii_temp_data.UN_NUMBER_ID := msi_record_temp.UN_NUMBER_ID;
   ELSIF msii_temp_data.UN_NUMBER_ID    = -999999 THEN
      msii_temp_data.UN_NUMBER_ID := NULL;
   ELSIF msii_temp_data.UN_NUMBER_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.UN_NUMBER_ID := NULL;
   END IF;
   IF msii_temp_data.ASSET_CATEGORY_ID IS NULL THEN
      msii_temp_data.ASSET_CATEGORY_ID := msi_record_temp.ASSET_CATEGORY_ID;
   ELSIF msii_temp_data.ASSET_CATEGORY_ID    = -999999 THEN
      msii_temp_data.ASSET_CATEGORY_ID := NULL;
   ELSIF msii_temp_data.ASSET_CATEGORY_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ASSET_CATEGORY_ID := NULL;
   END IF;
   IF msii_temp_data.ROUNDING_FACTOR IS NULL THEN
      msii_temp_data.ROUNDING_FACTOR := msi_record_temp.ROUNDING_FACTOR;
   ELSIF msii_temp_data.ROUNDING_FACTOR    = -999999 THEN
      msii_temp_data.ROUNDING_FACTOR := NULL;
   ELSIF msii_temp_data.ROUNDING_FACTOR    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ROUNDING_FACTOR := NULL;
   END IF;
   IF msii_temp_data.ENFORCE_SHIP_TO_LOCATION_CODE IS NULL THEN
      msii_temp_data.ENFORCE_SHIP_TO_LOCATION_CODE := msi_record_temp.ENFORCE_SHIP_TO_LOCATION_CODE;
   ELSIF msii_temp_data.ENFORCE_SHIP_TO_LOCATION_CODE    = '!' THEN
      msii_temp_data.ENFORCE_SHIP_TO_LOCATION_CODE := NULL;
   ELSIF msii_temp_data.ENFORCE_SHIP_TO_LOCATION_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ENFORCE_SHIP_TO_LOCATION_CODE := NULL;
   ELSE
      msii_temp_data.ENFORCE_SHIP_TO_LOCATION_CODE := trim(msii_temp_data.ENFORCE_SHIP_TO_LOCATION_CODE);
   END IF;
   IF msii_temp_data.ALLOW_UNORDERED_RECEIPTS_FLAG IS NULL THEN
      msii_temp_data.ALLOW_UNORDERED_RECEIPTS_FLAG := msi_record_temp.ALLOW_UNORDERED_RECEIPTS_FLAG;
   ELSIF msii_temp_data.ALLOW_UNORDERED_RECEIPTS_FLAG    = '!' THEN
      msii_temp_data.ALLOW_UNORDERED_RECEIPTS_FLAG := NULL;
   ELSIF msii_temp_data.ALLOW_UNORDERED_RECEIPTS_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ALLOW_UNORDERED_RECEIPTS_FLAG := NULL;
   ELSE
      msii_temp_data.ALLOW_UNORDERED_RECEIPTS_FLAG := trim(msii_temp_data.ALLOW_UNORDERED_RECEIPTS_FLAG);
   END IF;
   IF msii_temp_data.DAYS_EARLY_RECEIPT_ALLOWED IS NULL THEN
      msii_temp_data.DAYS_EARLY_RECEIPT_ALLOWED := msi_record_temp.DAYS_EARLY_RECEIPT_ALLOWED;
   ELSIF msii_temp_data.DAYS_EARLY_RECEIPT_ALLOWED    = -999999 THEN
      msii_temp_data.DAYS_EARLY_RECEIPT_ALLOWED := NULL;
   ELSIF msii_temp_data.DAYS_EARLY_RECEIPT_ALLOWED    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DAYS_EARLY_RECEIPT_ALLOWED := NULL;
   END IF;
   IF msii_temp_data.DAYS_LATE_RECEIPT_ALLOWED IS NULL THEN
      msii_temp_data.DAYS_LATE_RECEIPT_ALLOWED := msi_record_temp.DAYS_LATE_RECEIPT_ALLOWED;
   ELSIF msii_temp_data.DAYS_LATE_RECEIPT_ALLOWED    = -999999 THEN
      msii_temp_data.DAYS_LATE_RECEIPT_ALLOWED := NULL;
   ELSIF msii_temp_data.DAYS_LATE_RECEIPT_ALLOWED    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DAYS_LATE_RECEIPT_ALLOWED := NULL;
   END IF;
   IF msii_temp_data.RECEIVING_ROUTING_ID IS NULL THEN
      msii_temp_data.RECEIVING_ROUTING_ID := msi_record_temp.RECEIVING_ROUTING_ID;
   ELSIF msii_temp_data.RECEIVING_ROUTING_ID    = -999999 THEN
      msii_temp_data.RECEIVING_ROUTING_ID := NULL;
   ELSIF msii_temp_data.RECEIVING_ROUTING_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.RECEIVING_ROUTING_ID := NULL;
   END IF;
   IF msii_temp_data.INVOICE_CLOSE_TOLERANCE IS NULL THEN
      msii_temp_data.INVOICE_CLOSE_TOLERANCE := msi_record_temp.INVOICE_CLOSE_TOLERANCE;
   ELSIF msii_temp_data.INVOICE_CLOSE_TOLERANCE    = -999999 THEN
      msii_temp_data.INVOICE_CLOSE_TOLERANCE := NULL;
   ELSIF msii_temp_data.INVOICE_CLOSE_TOLERANCE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.INVOICE_CLOSE_TOLERANCE := NULL;
   END IF;
   IF msii_temp_data.AUTO_LOT_ALPHA_PREFIX IS NULL THEN
      msii_temp_data.AUTO_LOT_ALPHA_PREFIX := msi_record_temp.AUTO_LOT_ALPHA_PREFIX;
   ELSIF msii_temp_data.AUTO_LOT_ALPHA_PREFIX    = '!' THEN
      msii_temp_data.AUTO_LOT_ALPHA_PREFIX := NULL;
   ELSIF msii_temp_data.AUTO_LOT_ALPHA_PREFIX    = g_FND_Upd_Null_Char THEN
      msii_temp_data.AUTO_LOT_ALPHA_PREFIX := NULL;
   ELSE
      msii_temp_data.AUTO_LOT_ALPHA_PREFIX := trim(msii_temp_data.AUTO_LOT_ALPHA_PREFIX);
   END IF;
   IF msii_temp_data.LOT_CONTROL_CODE is null then
      msii_temp_data.LOT_CONTROL_CODE := msi_record_temp.LOT_CONTROL_CODE;
   END IF;
   IF msii_temp_data.SHELF_LIFE_CODE is null then
      msii_temp_data.SHELF_LIFE_CODE := msi_record_temp.SHELF_LIFE_CODE;
   END IF;
   IF msii_temp_data.SHELF_LIFE_DAYS IS NULL THEN
      msii_temp_data.SHELF_LIFE_DAYS := msi_record_temp.SHELF_LIFE_DAYS;
   ELSIF msii_temp_data.SHELF_LIFE_DAYS    = -999999 THEN
      msii_temp_data.SHELF_LIFE_DAYS := NULL;
   ELSIF msii_temp_data.SHELF_LIFE_DAYS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SHELF_LIFE_DAYS := NULL;
   END IF;
   IF msii_temp_data.START_AUTO_SERIAL_NUMBER IS NULL THEN
      msii_temp_data.START_AUTO_SERIAL_NUMBER := msi_record_temp.START_AUTO_SERIAL_NUMBER;
   ELSIF msii_temp_data.START_AUTO_SERIAL_NUMBER    = '!' THEN
      msii_temp_data.START_AUTO_SERIAL_NUMBER := NULL;
   ELSIF msii_temp_data.START_AUTO_SERIAL_NUMBER    = g_FND_Upd_Null_Char THEN
      msii_temp_data.START_AUTO_SERIAL_NUMBER := NULL;
   ELSE
      msii_temp_data.START_AUTO_SERIAL_NUMBER := trim(msii_temp_data.START_AUTO_SERIAL_NUMBER);
   END IF;
   IF msii_temp_data.SOURCE_TYPE IS NULL THEN
      msii_temp_data.SOURCE_TYPE := msi_record_temp.SOURCE_TYPE;
   ELSIF msii_temp_data.SOURCE_TYPE    = -999999 THEN
      msii_temp_data.SOURCE_TYPE := NULL;
   ELSIF msii_temp_data.SOURCE_TYPE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SOURCE_TYPE := NULL;
   END IF;
   IF msii_temp_data.SOURCE_SUBINVENTORY IS NULL THEN
      msii_temp_data.SOURCE_SUBINVENTORY := msi_record_temp.SOURCE_SUBINVENTORY;
   ELSIF msii_temp_data.SOURCE_SUBINVENTORY    = '!' THEN
      msii_temp_data.SOURCE_SUBINVENTORY := NULL;
   ELSIF msii_temp_data.SOURCE_SUBINVENTORY    = g_FND_Upd_Null_Char THEN
      msii_temp_data.SOURCE_SUBINVENTORY := NULL;
   ELSE
      msii_temp_data.SOURCE_SUBINVENTORY := trim(msii_temp_data.SOURCE_SUBINVENTORY);
   END IF;
   IF msii_temp_data.EXPENSE_ACCOUNT IS NULL THEN
      msii_temp_data.EXPENSE_ACCOUNT := msi_record_temp.EXPENSE_ACCOUNT;
   ELSIF msii_temp_data.EXPENSE_ACCOUNT    = -999999 THEN
      msii_temp_data.EXPENSE_ACCOUNT := NULL;
   ELSIF msii_temp_data.EXPENSE_ACCOUNT    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.EXPENSE_ACCOUNT := NULL;
   END IF;
   IF msii_temp_data.RESTRICT_SUBINVENTORIES_CODE is null then
      msii_temp_data.RESTRICT_SUBINVENTORIES_CODE := msi_record_temp.RESTRICT_SUBINVENTORIES_CODE;
   END IF;
   IF msii_temp_data.UNIT_WEIGHT IS NULL THEN
      msii_temp_data.UNIT_WEIGHT := msi_record_temp.UNIT_WEIGHT;
   ELSIF msii_temp_data.UNIT_WEIGHT    = -999999 THEN
      msii_temp_data.UNIT_WEIGHT := NULL;
   ELSIF msii_temp_data.UNIT_WEIGHT    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.UNIT_WEIGHT := NULL;
   END IF;
   IF msii_temp_data.VOLUME_UOM_CODE IS NULL THEN
      msii_temp_data.VOLUME_UOM_CODE := msi_record_temp.VOLUME_UOM_CODE;
   ELSIF msii_temp_data.VOLUME_UOM_CODE    = '!' THEN
      msii_temp_data.VOLUME_UOM_CODE := NULL;
   ELSIF msii_temp_data.VOLUME_UOM_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.VOLUME_UOM_CODE := NULL;
   ELSE
      msii_temp_data.VOLUME_UOM_CODE := trim(msii_temp_data.VOLUME_UOM_CODE);
   END IF;
   IF msii_temp_data.UNIT_VOLUME IS NULL THEN
      msii_temp_data.UNIT_VOLUME := msi_record_temp.UNIT_VOLUME;
   ELSIF msii_temp_data.UNIT_VOLUME    = -999999 THEN
      msii_temp_data.UNIT_VOLUME := NULL;
   ELSIF msii_temp_data.UNIT_VOLUME    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.UNIT_VOLUME := NULL;
   END IF;
   IF msii_temp_data.LOCATION_CONTROL_CODE is null then
      msii_temp_data.LOCATION_CONTROL_CODE := msi_record_temp.LOCATION_CONTROL_CODE;
   END IF;
   IF msii_temp_data.ACCEPTABLE_EARLY_DAYS IS NULL THEN
      msii_temp_data.ACCEPTABLE_EARLY_DAYS := msi_record_temp.ACCEPTABLE_EARLY_DAYS;
   ELSIF msii_temp_data.ACCEPTABLE_EARLY_DAYS    = -999999 THEN
      msii_temp_data.ACCEPTABLE_EARLY_DAYS := NULL;
   ELSIF msii_temp_data.ACCEPTABLE_EARLY_DAYS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ACCEPTABLE_EARLY_DAYS := NULL;
   END IF;
   IF msii_temp_data.PLANNING_TIME_FENCE_CODE is null then
      msii_temp_data.PLANNING_TIME_FENCE_CODE := msi_record_temp.PLANNING_TIME_FENCE_CODE;
   END IF;
   IF msii_temp_data.OVERRUN_PERCENTAGE IS NULL THEN
      msii_temp_data.OVERRUN_PERCENTAGE := msi_record_temp.OVERRUN_PERCENTAGE;
   ELSIF msii_temp_data.OVERRUN_PERCENTAGE    = -999999 THEN
      msii_temp_data.OVERRUN_PERCENTAGE := NULL;
   ELSIF msii_temp_data.OVERRUN_PERCENTAGE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.OVERRUN_PERCENTAGE := NULL;
   END IF;
   IF msii_temp_data.MRP_CALCULATE_ATP_FLAG is null then
      msii_temp_data.MRP_CALCULATE_ATP_FLAG := msi_record_temp.MRP_CALCULATE_ATP_FLAG;
   END IF;
   IF msii_temp_data.ACCEPTABLE_RATE_INCREASE IS NULL THEN
      msii_temp_data.ACCEPTABLE_RATE_INCREASE := msi_record_temp.ACCEPTABLE_RATE_INCREASE;
   ELSIF msii_temp_data.ACCEPTABLE_RATE_INCREASE    = -999999 THEN
      msii_temp_data.ACCEPTABLE_RATE_INCREASE := NULL;
   ELSIF msii_temp_data.ACCEPTABLE_RATE_INCREASE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ACCEPTABLE_RATE_INCREASE := NULL;
   END IF;
   IF msii_temp_data.ACCEPTABLE_RATE_DECREASE IS NULL THEN
      msii_temp_data.ACCEPTABLE_RATE_DECREASE := msi_record_temp.ACCEPTABLE_RATE_DECREASE;
   ELSIF msii_temp_data.ACCEPTABLE_RATE_DECREASE    = -999999 THEN
      msii_temp_data.ACCEPTABLE_RATE_DECREASE := NULL;
   ELSIF msii_temp_data.ACCEPTABLE_RATE_DECREASE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ACCEPTABLE_RATE_DECREASE := NULL;
   END IF;
   IF msii_temp_data.CUMULATIVE_TOTAL_LEAD_TIME IS NULL THEN
      msii_temp_data.CUMULATIVE_TOTAL_LEAD_TIME := msi_record_temp.CUMULATIVE_TOTAL_LEAD_TIME;
   ELSIF msii_temp_data.CUMULATIVE_TOTAL_LEAD_TIME    = -999999 THEN
      msii_temp_data.CUMULATIVE_TOTAL_LEAD_TIME := NULL;
   ELSIF msii_temp_data.CUMULATIVE_TOTAL_LEAD_TIME    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.CUMULATIVE_TOTAL_LEAD_TIME := NULL;
   END IF;
   IF msii_temp_data.PLANNING_TIME_FENCE_DAYS IS NULL THEN
      msii_temp_data.PLANNING_TIME_FENCE_DAYS := msi_record_temp.PLANNING_TIME_FENCE_DAYS;
   ELSIF msii_temp_data.PLANNING_TIME_FENCE_DAYS    = -999999 THEN
      msii_temp_data.PLANNING_TIME_FENCE_DAYS := NULL;
   ELSIF msii_temp_data.PLANNING_TIME_FENCE_DAYS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.PLANNING_TIME_FENCE_DAYS := NULL;
   END IF;
   IF msii_temp_data.RELEASE_TIME_FENCE_CODE IS NULL THEN
      msii_temp_data.RELEASE_TIME_FENCE_CODE := msi_record_temp.RELEASE_TIME_FENCE_CODE;
   ELSIF msii_temp_data.RELEASE_TIME_FENCE_CODE    = -999999 THEN
      msii_temp_data.RELEASE_TIME_FENCE_CODE := NULL;
   ELSIF msii_temp_data.RELEASE_TIME_FENCE_CODE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.RELEASE_TIME_FENCE_CODE := NULL;
   END IF;
   IF msii_temp_data.END_ASSEMBLY_PEGGING_FLAG IS NULL THEN
      msii_temp_data.END_ASSEMBLY_PEGGING_FLAG := msi_record_temp.END_ASSEMBLY_PEGGING_FLAG;
   ELSIF msii_temp_data.END_ASSEMBLY_PEGGING_FLAG    = '!' THEN
      msii_temp_data.END_ASSEMBLY_PEGGING_FLAG := NULL;
   ELSIF msii_temp_data.END_ASSEMBLY_PEGGING_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.END_ASSEMBLY_PEGGING_FLAG := NULL;
   ELSE
      msii_temp_data.END_ASSEMBLY_PEGGING_FLAG := trim(msii_temp_data.END_ASSEMBLY_PEGGING_FLAG);
   END IF;
   IF trim(msii_temp_data.REPETITIVE_PLANNING_FLAG) is null then
      msii_temp_data.REPETITIVE_PLANNING_FLAG := msi_record_temp.REPETITIVE_PLANNING_FLAG;
   ELSE
      msii_temp_data.REPETITIVE_PLANNING_FLAG := trim(msii_temp_data.REPETITIVE_PLANNING_FLAG);
   END IF;
   IF msii_temp_data.BOM_ITEM_TYPE is null then
      msii_temp_data.BOM_ITEM_TYPE := msi_record_temp.BOM_ITEM_TYPE;
   END IF;
   IF trim(msii_temp_data.PICK_COMPONENTS_FLAG) is null then
      msii_temp_data.PICK_COMPONENTS_FLAG := msi_record_temp.PICK_COMPONENTS_FLAG;
   ELSE
      msii_temp_data.PICK_COMPONENTS_FLAG := trim(msii_temp_data.PICK_COMPONENTS_FLAG);
   END IF;
   IF trim(msii_temp_data.REPLENISH_TO_ORDER_FLAG) is null then
      msii_temp_data.REPLENISH_TO_ORDER_FLAG := msi_record_temp.REPLENISH_TO_ORDER_FLAG;
   ELSE
      msii_temp_data.REPLENISH_TO_ORDER_FLAG := trim(msii_temp_data.REPLENISH_TO_ORDER_FLAG);
   END IF;
   IF trim(msii_temp_data.ATP_COMPONENTS_FLAG) is null then
      msii_temp_data.ATP_COMPONENTS_FLAG := msi_record_temp.ATP_COMPONENTS_FLAG;
   END IF;
   IF trim(msii_temp_data.ATP_FLAG) is null then
      msii_temp_data.ATP_FLAG := msi_record_temp.ATP_FLAG;
   ELSE
      msii_temp_data.ATP_FLAG := trim(msii_temp_data.ATP_FLAG);
   END IF;
   IF msii_temp_data.VARIABLE_LEAD_TIME IS NULL THEN
      msii_temp_data.VARIABLE_LEAD_TIME := msi_record_temp.VARIABLE_LEAD_TIME;
   ELSIF msii_temp_data.VARIABLE_LEAD_TIME    = -999999 THEN
      msii_temp_data.VARIABLE_LEAD_TIME := NULL;
   ELSIF msii_temp_data.VARIABLE_LEAD_TIME    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.VARIABLE_LEAD_TIME := NULL;
   END IF;
   IF msii_temp_data.WIP_SUPPLY_LOCATOR_ID IS NULL THEN
      msii_temp_data.WIP_SUPPLY_LOCATOR_ID := msi_record_temp.WIP_SUPPLY_LOCATOR_ID;
   ELSIF msii_temp_data.WIP_SUPPLY_LOCATOR_ID    = -999999 THEN
      msii_temp_data.WIP_SUPPLY_LOCATOR_ID := NULL;
   ELSIF msii_temp_data.WIP_SUPPLY_LOCATOR_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.WIP_SUPPLY_LOCATOR_ID := NULL;
   END IF;
   msii_temp_data.PRIMARY_UOM_CODE        := msi_record_temp.PRIMARY_UOM_CODE;
   msii_temp_data.PRIMARY_UNIT_OF_MEASURE := trim(msi_record_temp.PRIMARY_UNIT_OF_MEASURE);
   IF msii_temp_data.ALLOWED_UNITS_LOOKUP_CODE is null then
      msii_temp_data.ALLOWED_UNITS_LOOKUP_CODE := msi_record_temp.ALLOWED_UNITS_LOOKUP_CODE;
   END IF;
   IF msii_temp_data.COST_OF_SALES_ACCOUNT is null then
      msii_temp_data.COST_OF_SALES_ACCOUNT := msi_record_temp.COST_OF_SALES_ACCOUNT;
   END IF;
   IF msii_temp_data.SALES_ACCOUNT is null then
      msii_temp_data.SALES_ACCOUNT := msi_record_temp.SALES_ACCOUNT;
   END IF;
   IF msii_temp_data.INVENTORY_PLANNING_CODE is null then
      msii_temp_data.INVENTORY_PLANNING_CODE := msi_record_temp.INVENTORY_PLANNING_CODE;
   END IF;
   IF msii_temp_data.PLANNING_MAKE_BUY_CODE is null then
      msii_temp_data.PLANNING_MAKE_BUY_CODE := msi_record_temp.PLANNING_MAKE_BUY_CODE;
   END IF;
   IF msii_temp_data.FIXED_LOT_MULTIPLIER IS NULL THEN
      msii_temp_data.FIXED_LOT_MULTIPLIER := msi_record_temp.FIXED_LOT_MULTIPLIER;
   ELSIF msii_temp_data.FIXED_LOT_MULTIPLIER    = -999999 THEN
      msii_temp_data.FIXED_LOT_MULTIPLIER := NULL;
   ELSIF msii_temp_data.FIXED_LOT_MULTIPLIER    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.FIXED_LOT_MULTIPLIER := NULL;
   END IF;
   IF msii_temp_data.CARRYING_COST IS NULL THEN
      msii_temp_data.CARRYING_COST := msi_record_temp.CARRYING_COST;
   ELSIF msii_temp_data.CARRYING_COST    = -999999 THEN
      msii_temp_data.CARRYING_COST := NULL;
   ELSIF msii_temp_data.CARRYING_COST    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.CARRYING_COST := NULL;
   END IF;
   IF msii_temp_data.PREPROCESSING_LEAD_TIME IS NULL THEN
      msii_temp_data.PREPROCESSING_LEAD_TIME := msi_record_temp.PREPROCESSING_LEAD_TIME;
   ELSIF msii_temp_data.PREPROCESSING_LEAD_TIME    = -999999 THEN
      msii_temp_data.PREPROCESSING_LEAD_TIME := NULL;
   ELSIF msii_temp_data.PREPROCESSING_LEAD_TIME    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.PREPROCESSING_LEAD_TIME := NULL;
   END IF;
   IF msii_temp_data.ORDER_COST IS NULL THEN
      msii_temp_data.ORDER_COST := msi_record_temp.ORDER_COST;
   ELSIF msii_temp_data.ORDER_COST    = -999999 THEN
      msii_temp_data.ORDER_COST := NULL;
   ELSIF msii_temp_data.ORDER_COST    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.ORDER_COST := NULL;
   END IF;
   IF msii_temp_data.MRP_SAFETY_STOCK_CODE is null then
      msii_temp_data.MRP_SAFETY_STOCK_CODE := msi_record_temp.MRP_SAFETY_STOCK_CODE;
   END IF;
   IF msii_temp_data.MINIMUM_ORDER_QUANTITY IS NULL THEN
      msii_temp_data.MINIMUM_ORDER_QUANTITY := msi_record_temp.MINIMUM_ORDER_QUANTITY;
   ELSIF msii_temp_data.MINIMUM_ORDER_QUANTITY    = -999999 THEN
      msii_temp_data.MINIMUM_ORDER_QUANTITY := NULL;
   ELSIF msii_temp_data.MINIMUM_ORDER_QUANTITY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.MINIMUM_ORDER_QUANTITY := NULL;

   END IF;
   IF msii_temp_data.FIXED_DAYS_SUPPLY IS NULL THEN
      msii_temp_data.FIXED_DAYS_SUPPLY := msi_record_temp.FIXED_DAYS_SUPPLY;
   ELSIF msii_temp_data.FIXED_DAYS_SUPPLY    = -999999 THEN
      msii_temp_data.FIXED_DAYS_SUPPLY := NULL;
   ELSIF msii_temp_data.FIXED_DAYS_SUPPLY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.FIXED_DAYS_SUPPLY := NULL;
   END IF;
   IF msii_temp_data.MAXIMUM_ORDER_QUANTITY IS NULL THEN
      msii_temp_data.MAXIMUM_ORDER_QUANTITY := msi_record_temp.MAXIMUM_ORDER_QUANTITY;
   ELSIF msii_temp_data.MAXIMUM_ORDER_QUANTITY    = -999999 THEN
      msii_temp_data.MAXIMUM_ORDER_QUANTITY := NULL;
   ELSIF msii_temp_data.MAXIMUM_ORDER_QUANTITY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.MAXIMUM_ORDER_QUANTITY := NULL;
   END IF;
   IF msii_temp_data.PICKING_RULE_ID IS NULL THEN
      msii_temp_data.PICKING_RULE_ID := msi_record_temp.PICKING_RULE_ID;
   ELSIF msii_temp_data.PICKING_RULE_ID    = -999999 THEN
      msii_temp_data.PICKING_RULE_ID := NULL;
   ELSIF msii_temp_data.PICKING_RULE_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.PICKING_RULE_ID := NULL;
   END IF;
   IF msii_temp_data.RESERVABLE_TYPE is null then
      msii_temp_data.RESERVABLE_TYPE := msi_record_temp.RESERVABLE_TYPE;
   END IF;
   IF msii_temp_data.NEGATIVE_MEASUREMENT_ERROR IS NULL THEN
      msii_temp_data.NEGATIVE_MEASUREMENT_ERROR := msi_record_temp.NEGATIVE_MEASUREMENT_ERROR;
   ELSIF msii_temp_data.NEGATIVE_MEASUREMENT_ERROR    = -999999 THEN
      msii_temp_data.NEGATIVE_MEASUREMENT_ERROR := NULL;
   ELSIF msii_temp_data.NEGATIVE_MEASUREMENT_ERROR    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.NEGATIVE_MEASUREMENT_ERROR := NULL;
   END IF;
   IF trim(msii_temp_data.ENGINEERING_ECN_CODE) is null then
      msii_temp_data.ENGINEERING_ECN_CODE := msi_record_temp.ENGINEERING_ECN_CODE;
   ELSE
      msii_temp_data.ENGINEERING_ECN_CODE := trim(msii_temp_data.ENGINEERING_ECN_CODE);
   END IF;
   IF msii_temp_data.ENGINEERING_DATE is null then
      msii_temp_data.ENGINEERING_DATE := msi_record_temp.ENGINEERING_DATE;
   END IF;
   IF trim(msii_temp_data.SERVICEABLE_COMPONENT_FLAG) is null then
      msii_temp_data.SERVICEABLE_COMPONENT_FLAG := msi_record_temp.SERVICEABLE_COMPONENT_FLAG;
   ELSE
      msii_temp_data.SERVICEABLE_COMPONENT_FLAG := trim(msii_temp_data.SERVICEABLE_COMPONENT_FLAG);
   END IF;
   IF trim(msii_temp_data.SERVICEABLE_PRODUCT_FLAG) is null then
      msii_temp_data.SERVICEABLE_PRODUCT_FLAG := msi_record_temp.SERVICEABLE_PRODUCT_FLAG;
   ELSE
      msii_temp_data.SERVICEABLE_PRODUCT_FLAG := trim(msii_temp_data.SERVICEABLE_PRODUCT_FLAG);
   END IF;
   IF msii_temp_data.BASE_WARRANTY_SERVICE_ID is null then
      msii_temp_data.BASE_WARRANTY_SERVICE_ID := msi_record_temp.BASE_WARRANTY_SERVICE_ID;
   END IF;
   IF trim(msii_temp_data.PREVENTIVE_MAINTENANCE_FLAG) is null then
      msii_temp_data.PREVENTIVE_MAINTENANCE_FLAG := msi_record_temp.PREVENTIVE_MAINTENANCE_FLAG;
   ELSE
      msii_temp_data.PREVENTIVE_MAINTENANCE_FLAG := trim(msii_temp_data.PREVENTIVE_MAINTENANCE_FLAG);
   END IF;
   IF msii_temp_data.PRIMARY_SPECIALIST_ID is null then
      msii_temp_data.PRIMARY_SPECIALIST_ID := msi_record_temp.PRIMARY_SPECIALIST_ID;
   END IF;
   IF msii_temp_data.SERVICEABLE_ITEM_CLASS_ID is null then
      msii_temp_data.SERVICEABLE_ITEM_CLASS_ID := msi_record_temp.SERVICEABLE_ITEM_CLASS_ID;
   END IF;
   IF trim(msii_temp_data.TIME_BILLABLE_FLAG) is null then
      msii_temp_data.TIME_BILLABLE_FLAG := msi_record_temp.TIME_BILLABLE_FLAG;
   ELSE
      msii_temp_data.TIME_BILLABLE_FLAG := trim(msii_temp_data.TIME_BILLABLE_FLAG);
   END IF;
   IF trim(msii_temp_data.EXPENSE_BILLABLE_FLAG) is null then
      msii_temp_data.EXPENSE_BILLABLE_FLAG := msi_record_temp.EXPENSE_BILLABLE_FLAG;
   ELSE
      msii_temp_data.EXPENSE_BILLABLE_FLAG := trim(msii_temp_data.EXPENSE_BILLABLE_FLAG);
   END IF;
   IF trim(msii_temp_data.PRORATE_SERVICE_FLAG) is null then
      msii_temp_data.PRORATE_SERVICE_FLAG := msi_record_temp.PRORATE_SERVICE_FLAG;
   ELSE
      msii_temp_data.PRORATE_SERVICE_FLAG := trim(msii_temp_data.PRORATE_SERVICE_FLAG);
   END IF;
   IF msii_temp_data.SERVICE_DURATION_PERIOD_CODE IS NULL THEN
      msii_temp_data.SERVICE_DURATION_PERIOD_CODE := msi_record_temp.SERVICE_DURATION_PERIOD_CODE;
   ELSIF msii_temp_data.SERVICE_DURATION_PERIOD_CODE    = '!' THEN
      msii_temp_data.SERVICE_DURATION_PERIOD_CODE := NULL;
   ELSIF msii_temp_data.SERVICE_DURATION_PERIOD_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.SERVICE_DURATION_PERIOD_CODE := NULL;
   ELSE
      msii_temp_data.SERVICE_DURATION_PERIOD_CODE := trim(msii_temp_data.SERVICE_DURATION_PERIOD_CODE);
   END IF;
   IF msii_temp_data.SERVICE_DURATION IS NULL THEN
      msii_temp_data.SERVICE_DURATION := msi_record_temp.SERVICE_DURATION;
   ELSIF msii_temp_data.SERVICE_DURATION    = -999999 THEN
      msii_temp_data.SERVICE_DURATION := NULL;
   ELSIF msii_temp_data.SERVICE_DURATION    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SERVICE_DURATION := NULL;
   END IF;
   IF msii_temp_data.MAX_WARRANTY_AMOUNT is null then
      msii_temp_data.MAX_WARRANTY_AMOUNT := msi_record_temp.MAX_WARRANTY_AMOUNT;
   END IF;
   IF msii_temp_data.RESPONSE_TIME_VALUE is null then
      msii_temp_data.RESPONSE_TIME_VALUE := msi_record_temp.RESPONSE_TIME_VALUE;
   END IF;
   IF trim(msii_temp_data.NEW_REVISION_CODE) is null then
      msii_temp_data.NEW_REVISION_CODE := msi_record_temp.NEW_REVISION_CODE;
   ELSE
      msii_temp_data.NEW_REVISION_CODE := trim(msii_temp_data.NEW_REVISION_CODE);
   END IF;
   IF trim(msii_temp_data.INVOICEABLE_ITEM_FLAG) is null then
      msii_temp_data.INVOICEABLE_ITEM_FLAG := msi_record_temp.INVOICEABLE_ITEM_FLAG;
   ELSE
      msii_temp_data.INVOICEABLE_ITEM_FLAG := trim(msii_temp_data.INVOICEABLE_ITEM_FLAG);
   END IF;
   IF trim(msii_temp_data.INVOICE_ENABLED_FLAG) is null then
      IF msii_temp_data.inventory_item_status_code is null then
         msii_temp_data.INVOICE_ENABLED_FLAG := msi_record_temp.INVOICE_ENABLED_FLAG;
      END IF;
   ELSE
      msii_temp_data.INVOICE_ENABLED_FLAG := trim(msii_temp_data.INVOICE_ENABLED_FLAG);
   END IF;
   IF msii_temp_data.REQUEST_ID is null then
      msii_temp_data.REQUEST_ID := msi_record_temp.REQUEST_ID;
   END IF;
   IF msii_temp_data.PROGRAM_ID is null then
      msii_temp_data.PROGRAM_ID := msi_record_temp.PROGRAM_ID;
   END IF;
   IF msii_temp_data.PROGRAM_UPDATE_DATE is null then
      msii_temp_data.PROGRAM_UPDATE_DATE := msi_record_temp.PROGRAM_UPDATE_DATE;
   END IF;
   IF msii_temp_data.OUTSIDE_OPERATION_UOM_TYPE IS NULL THEN
      msii_temp_data.OUTSIDE_OPERATION_UOM_TYPE := msi_record_temp.OUTSIDE_OPERATION_UOM_TYPE;
   ELSIF msii_temp_data.OUTSIDE_OPERATION_UOM_TYPE    = '!' THEN
      msii_temp_data.OUTSIDE_OPERATION_UOM_TYPE := NULL;
   ELSIF msii_temp_data.OUTSIDE_OPERATION_UOM_TYPE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.OUTSIDE_OPERATION_UOM_TYPE := NULL;
   ELSE
      msii_temp_data.OUTSIDE_OPERATION_UOM_TYPE := trim(msii_temp_data.OUTSIDE_OPERATION_UOM_TYPE);
   END IF;
   IF trim(msii_temp_data.COSTING_ENABLED_FLAG) is null then
      msii_temp_data.COSTING_ENABLED_FLAG := msi_record_temp.COSTING_ENABLED_FLAG;
   ELSE
      msii_temp_data.COSTING_ENABLED_FLAG := trim(msii_temp_data.COSTING_ENABLED_FLAG);
   END IF;
   IF trim(msii_temp_data.CYCLE_COUNT_ENABLED_FLAG) is null then
      msii_temp_data.CYCLE_COUNT_ENABLED_FLAG := msi_record_temp.CYCLE_COUNT_ENABLED_FLAG;
   ELSE
      msii_temp_data.CYCLE_COUNT_ENABLED_FLAG := trim(msii_temp_data.CYCLE_COUNT_ENABLED_FLAG);
   END IF;
   IF msii_temp_data.ITEM_TYPE IS NULL THEN
      msii_temp_data.ITEM_TYPE := msi_record_temp.ITEM_TYPE;
   ELSIF msii_temp_data.ITEM_TYPE    = '!' THEN
      msii_temp_data.ITEM_TYPE := NULL;
   ELSIF msii_temp_data.ITEM_TYPE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ITEM_TYPE := NULL;
   ELSE
      msii_temp_data.ITEM_TYPE := trim(msii_temp_data.ITEM_TYPE);
   END IF;
   IF trim(msii_temp_data.MODEL_CONFIG_CLAUSE_NAME) is null then
      msii_temp_data.MODEL_CONFIG_CLAUSE_NAME := msi_record_temp.MODEL_CONFIG_CLAUSE_NAME;
   ELSE
      msii_temp_data.MODEL_CONFIG_CLAUSE_NAME := trim(msii_temp_data.MODEL_CONFIG_CLAUSE_NAME);
   END IF;
   IF msii_temp_data.MRP_PLANNING_CODE is null then
      msii_temp_data.MRP_PLANNING_CODE := msi_record_temp.MRP_PLANNING_CODE;
   END IF;
   IF msii_temp_data.RETURN_INSPECTION_REQUIREMENT is null then
      msii_temp_data.RETURN_INSPECTION_REQUIREMENT := msi_record_temp.RETURN_INSPECTION_REQUIREMENT;
   END IF;
   IF trim(msii_temp_data.CONTAINER_ITEM_FLAG) is null then
      msii_temp_data.CONTAINER_ITEM_FLAG := msi_record_temp.CONTAINER_ITEM_FLAG;
   ELSE
      msii_temp_data.CONTAINER_ITEM_FLAG := trim(msii_temp_data.CONTAINER_ITEM_FLAG);
   END IF;
   IF trim(msii_temp_data.VEHICLE_ITEM_FLAG) is null then
      msii_temp_data.VEHICLE_ITEM_FLAG := msi_record_temp.VEHICLE_ITEM_FLAG;
   ELSE
      msii_temp_data.VEHICLE_ITEM_FLAG := trim(msii_temp_data.VEHICLE_ITEM_FLAG);
   END IF;
   IF msii_temp_data.MINIMUM_FILL_PERCENT IS NULL THEN
      msii_temp_data.MINIMUM_FILL_PERCENT := msi_record_temp.MINIMUM_FILL_PERCENT;
   ELSIF msii_temp_data.MINIMUM_FILL_PERCENT    = -999999 THEN
      msii_temp_data.MINIMUM_FILL_PERCENT := NULL;
   ELSIF msii_temp_data.MINIMUM_FILL_PERCENT    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.MINIMUM_FILL_PERCENT := NULL;
   END IF;
   IF msii_temp_data.CONTAINER_TYPE_CODE IS NULL THEN
      msii_temp_data.CONTAINER_TYPE_CODE := msi_record_temp.CONTAINER_TYPE_CODE;
   ELSIF msii_temp_data.CONTAINER_TYPE_CODE    = '!' THEN
      msii_temp_data.CONTAINER_TYPE_CODE := NULL;
   ELSIF msii_temp_data.CONTAINER_TYPE_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.CONTAINER_TYPE_CODE := NULL;
   ELSE
      msii_temp_data.CONTAINER_TYPE_CODE := trim(msii_temp_data.CONTAINER_TYPE_CODE);
   END IF;
   IF trim(msii_temp_data.CHECK_SHORTAGES_FLAG) is null then
      msii_temp_data.CHECK_SHORTAGES_FLAG := msi_record_temp.CHECK_SHORTAGES_FLAG;
   END IF;
   IF msii_temp_data. EFFECTIVITY_CONTROL is null then
      msii_temp_data.EFFECTIVITY_CONTROL := msi_record_temp.EFFECTIVITY_CONTROL;
   END IF;
   IF msii_temp_data.OVERCOMPLETION_TOLERANCE_VALUE IS NULL THEN
      msii_temp_data.OVERCOMPLETION_TOLERANCE_VALUE := msi_record_temp.OVERCOMPLETION_TOLERANCE_VALUE;
   ELSIF msii_temp_data.OVERCOMPLETION_TOLERANCE_VALUE    = g_Upd_Null_NUM THEN
      msii_temp_data.OVERCOMPLETION_TOLERANCE_VALUE := NULL;
   ELSIF msii_temp_data.OVERCOMPLETION_TOLERANCE_VALUE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.OVERCOMPLETION_TOLERANCE_VALUE := NULL;
   END IF;
   IF msii_temp_data.UNDER_SHIPMENT_TOLERANCE IS NULL THEN
      msii_temp_data.UNDER_SHIPMENT_TOLERANCE := msi_record_temp.UNDER_SHIPMENT_TOLERANCE;
   ELSIF msii_temp_data.UNDER_SHIPMENT_TOLERANCE    = g_Upd_Null_NUM THEN
      msii_temp_data.UNDER_SHIPMENT_TOLERANCE := NULL;
   ELSIF msii_temp_data.UNDER_SHIPMENT_TOLERANCE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.UNDER_SHIPMENT_TOLERANCE := NULL;
   END IF;
   IF msii_temp_data.OVER_RETURN_TOLERANCE IS NULL THEN
      msii_temp_data.OVER_RETURN_TOLERANCE := msi_record_temp.OVER_RETURN_TOLERANCE;
   ELSIF msii_temp_data.OVER_RETURN_TOLERANCE    = g_Upd_Null_NUM THEN
      msii_temp_data.OVER_RETURN_TOLERANCE := NULL;
   ELSIF msii_temp_data.OVER_RETURN_TOLERANCE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.OVER_RETURN_TOLERANCE := NULL;
   END IF;
   IF msii_temp_data. EQUIPMENT_TYPE is null then
      msii_temp_data.EQUIPMENT_TYPE := msi_record_temp.EQUIPMENT_TYPE;
   END IF;
   IF msii_temp_data.RECOVERED_PART_DISP_CODE IS NULL THEN
      msii_temp_data.RECOVERED_PART_DISP_CODE := msi_record_temp.RECOVERED_PART_DISP_CODE;
   ELSIF msii_temp_data.RECOVERED_PART_DISP_CODE    = '!' THEN
      msii_temp_data.RECOVERED_PART_DISP_CODE := NULL;
   ELSIF msii_temp_data.RECOVERED_PART_DISP_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.RECOVERED_PART_DISP_CODE := NULL;
   ELSE
      msii_temp_data.RECOVERED_PART_DISP_CODE := trim(msii_temp_data.RECOVERED_PART_DISP_CODE);
   END IF;
   IF trim(msii_temp_data.EVENT_FLAG) is null then
      msii_temp_data.EVENT_FLAG := msi_record_temp.EVENT_FLAG;
   END IF;
   IF trim(msii_temp_data.ELECTRONIC_FLAG) is null then
      msii_temp_data.ELECTRONIC_FLAG := msi_record_temp.ELECTRONIC_FLAG;
   END IF;
   IF trim(msii_temp_data.VOL_DISCOUNT_EXEMPT_FLAG) is null then
      msii_temp_data.VOL_DISCOUNT_EXEMPT_FLAG := msi_record_temp.VOL_DISCOUNT_EXEMPT_FLAG;
   END IF;
   IF trim(msii_temp_data.COUPON_EXEMPT_FLAG) is null then
      msii_temp_data.COUPON_EXEMPT_FLAG := msi_record_temp.COUPON_EXEMPT_FLAG;
   END IF;
   IF msii_temp_data.ASSET_CREATION_CODE IS NULL THEN
      msii_temp_data.ASSET_CREATION_CODE := msi_record_temp.ASSET_CREATION_CODE;
   ELSIF msii_temp_data.ASSET_CREATION_CODE    = '!' THEN
      msii_temp_data.ASSET_CREATION_CODE := NULL;
   ELSIF msii_temp_data.ASSET_CREATION_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.ASSET_CREATION_CODE := NULL;
   ELSE
      msii_temp_data.ASSET_CREATION_CODE := trim(msii_temp_data.ASSET_CREATION_CODE);
   END IF;
   IF trim(msii_temp_data.ORDERABLE_ON_WEB_FLAG) is null then
      msii_temp_data.ORDERABLE_ON_WEB_FLAG := msi_record_temp.ORDERABLE_ON_WEB_FLAG;
   END IF;
   IF trim(msii_temp_data.BACK_ORDERABLE_FLAG) is null then
      msii_temp_data.BACK_ORDERABLE_FLAG := msi_record_temp.BACK_ORDERABLE_FLAG;
   END IF;
   IF trim(msii_temp_data.INDIVISIBLE_FLAG) is null then
      msii_temp_data.INDIVISIBLE_FLAG := msi_record_temp.INDIVISIBLE_FLAG;
   END IF;
   IF msii_temp_data.UNIT_LENGTH IS NULL THEN
      msii_temp_data.UNIT_LENGTH := msi_record_temp.UNIT_LENGTH;
   ELSIF msii_temp_data.UNIT_LENGTH    = g_Upd_Null_NUM THEN
      msii_temp_data.UNIT_LENGTH := NULL;
   ELSIF msii_temp_data.UNIT_LENGTH    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.UNIT_LENGTH := NULL;
   END IF;
   IF msii_temp_data.UNIT_WIDTH IS NULL THEN
      msii_temp_data.UNIT_WIDTH := msi_record_temp.UNIT_WIDTH;
   ELSIF msii_temp_data.UNIT_WIDTH    = g_Upd_Null_NUM THEN
      msii_temp_data.UNIT_WIDTH := NULL;
   ELSIF msii_temp_data.UNIT_WIDTH    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.UNIT_WIDTH := NULL;
   END IF;
   IF trim(msii_temp_data.BULK_PICKED_FLAG) is null then
      msii_temp_data.BULK_PICKED_FLAG := msi_record_temp.BULK_PICKED_FLAG;
   END IF;
   IF trim(msii_temp_data.LOT_STATUS_ENABLED) is null then
      msii_temp_data.LOT_STATUS_ENABLED := msi_record_temp.LOT_STATUS_ENABLED;
   END IF;
   IF trim(msii_temp_data.SERIAL_STATUS_ENABLED) is null then
      msii_temp_data.SERIAL_STATUS_ENABLED := msi_record_temp.SERIAL_STATUS_ENABLED;
   END IF;
   IF trim(msii_temp_data.LOT_SPLIT_ENABLED) is null then
      msii_temp_data.LOT_SPLIT_ENABLED := msi_record_temp.LOT_SPLIT_ENABLED;
   END IF;
   IF trim(msii_temp_data.LOT_MERGE_ENABLED) is null then
      msii_temp_data.LOT_MERGE_ENABLED := msi_record_temp.LOT_MERGE_ENABLED;
   END IF;
   IF msii_temp_data.OPERATION_SLACK_PENALTY IS NULL THEN
      msii_temp_data.OPERATION_SLACK_PENALTY := msi_record_temp.OPERATION_SLACK_PENALTY;
   ELSIF msii_temp_data.OPERATION_SLACK_PENALTY    = g_Upd_Null_NUM THEN
      msii_temp_data.OPERATION_SLACK_PENALTY := NULL;
   ELSIF msii_temp_data.OPERATION_SLACK_PENALTY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.OPERATION_SLACK_PENALTY := NULL;
   END IF;
   IF trim(msii_temp_data.FINANCING_ALLOWED_FLAG) is null then
      msii_temp_data.FINANCING_ALLOWED_FLAG := msi_record_temp.FINANCING_ALLOWED_FLAG;
   END IF;
   IF msii_temp_data.EAM_ACTIVITY_TYPE_CODE IS NULL THEN
      msii_temp_data.EAM_ACTIVITY_TYPE_CODE := msi_record_temp.EAM_ACTIVITY_TYPE_CODE;
   ELSIF msii_temp_data.EAM_ACTIVITY_TYPE_CODE    = g_Upd_Null_CHAR THEN
      msii_temp_data.EAM_ACTIVITY_TYPE_CODE := NULL;
   ELSIF msii_temp_data.EAM_ACTIVITY_TYPE_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.EAM_ACTIVITY_TYPE_CODE := NULL;
   ELSE
      msii_temp_data.EAM_ACTIVITY_TYPE_CODE := trim(msii_temp_data.EAM_ACTIVITY_TYPE_CODE);
   END IF;
   IF msii_temp_data.EAM_ACT_NOTIFICATION_FLAG IS NULL THEN
      msii_temp_data.EAM_ACT_NOTIFICATION_FLAG := msi_record_temp.EAM_ACT_NOTIFICATION_FLAG ;
   ELSIF msii_temp_data.EAM_ACT_NOTIFICATION_FLAG    = g_Upd_Null_CHAR THEN
      msii_temp_data.EAM_ACT_NOTIFICATION_FLAG := NULL;
   ELSIF msii_temp_data.EAM_ACT_NOTIFICATION_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.EAM_ACT_NOTIFICATION_FLAG := NULL;
   ELSE
      msii_temp_data.EAM_ACT_NOTIFICATION_FLAG := trim(msii_temp_data.EAM_ACT_NOTIFICATION_FLAG);
   END IF;
   IF msii_temp_data.DUAL_UOM_CONTROL is null then
      msii_temp_data.DUAL_UOM_CONTROL := msi_record_temp.DUAL_UOM_CONTROL;
   END IF;

   msii_temp_data.SECONDARY_UOM_CODE      :=  trim(msi_record_temp.SECONDARY_UOM_CODE);
   msii_temp_data.DUAL_UOM_DEVIATION_HIGH := msi_record_temp.DUAL_UOM_DEVIATION_HIGH;
   msii_temp_data.DUAL_UOM_DEVIATION_LOW  := msi_record_temp.DUAL_UOM_DEVIATION_LOW;

   IF msii_temp_data.SUBSCRIPTION_DEPEND_FLAG IS NULL THEN
      msii_temp_data.SUBSCRIPTION_DEPEND_FLAG := msi_record_temp.SUBSCRIPTION_DEPEND_FLAG;
   ELSIF msii_temp_data.SUBSCRIPTION_DEPEND_FLAG    = g_Upd_Null_CHAR THEN
      msii_temp_data.SUBSCRIPTION_DEPEND_FLAG := NULL;
   ELSIF msii_temp_data.SUBSCRIPTION_DEPEND_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.SUBSCRIPTION_DEPEND_FLAG := NULL;
   ELSE
      msii_temp_data.SUBSCRIPTION_DEPEND_FLAG := trim(msii_temp_data.SUBSCRIPTION_DEPEND_FLAG);
   END IF;
   IF msii_temp_data.SERV_BILLING_ENABLED_FLAG IS NULL THEN
      msii_temp_data.SERV_BILLING_ENABLED_FLAG := msi_record_temp.SERV_BILLING_ENABLED_FLAG;
   ELSIF msii_temp_data.SERV_BILLING_ENABLED_FLAG    = g_Upd_Null_CHAR THEN
      msii_temp_data.SERV_BILLING_ENABLED_FLAG := NULL;
   ELSIF msii_temp_data.SERV_BILLING_ENABLED_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.SERV_BILLING_ENABLED_FLAG := NULL;
   ELSE
      msii_temp_data.SERV_BILLING_ENABLED_FLAG := trim(msii_temp_data.SERV_BILLING_ENABLED_FLAG);
   END IF;
   IF msii_temp_data.SERV_IMPORTANCE_LEVEL IS NULL THEN
      msii_temp_data.SERV_IMPORTANCE_LEVEL := msi_record_temp.SERV_IMPORTANCE_LEVEL;
   ELSIF msii_temp_data.SERV_IMPORTANCE_LEVEL    = g_Upd_Null_NUM THEN
      msii_temp_data.SERV_IMPORTANCE_LEVEL := NULL;
   ELSIF msii_temp_data.SERV_IMPORTANCE_LEVEL    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SERV_IMPORTANCE_LEVEL := NULL;
   END IF;
   IF msii_temp_data.LOT_TRANSLATE_ENABLED IS NULL THEN
      msii_temp_data.LOT_TRANSLATE_ENABLED := msi_record_temp.LOT_TRANSLATE_ENABLED;
   ELSIF msii_temp_data.LOT_TRANSLATE_ENABLED    = g_Upd_Null_CHAR THEN
      msii_temp_data.LOT_TRANSLATE_ENABLED := NULL;
   ELSIF msii_temp_data.LOT_TRANSLATE_ENABLED    = g_FND_Upd_Null_Char THEN
      msii_temp_data.LOT_TRANSLATE_ENABLED := NULL;
   ELSE
      msii_temp_data.LOT_TRANSLATE_ENABLED := trim(msii_temp_data.LOT_TRANSLATE_ENABLED);
   END IF;
   IF msii_temp_data.CREATE_SUPPLY_FLAG IS NULL THEN
      msii_temp_data.CREATE_SUPPLY_FLAG := msi_record_temp.CREATE_SUPPLY_FLAG;
   ELSIF msii_temp_data.CREATE_SUPPLY_FLAG    = g_Upd_Null_CHAR THEN
      msii_temp_data.CREATE_SUPPLY_FLAG := NULL;
   ELSIF msii_temp_data.CREATE_SUPPLY_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.CREATE_SUPPLY_FLAG := NULL;
   ELSE
      msii_temp_data.CREATE_SUPPLY_FLAG := trim(msii_temp_data.CREATE_SUPPLY_FLAG);
   END IF;
   IF msii_temp_data.SUBSTITUTION_WINDOW_DAYS IS NULL THEN
      msii_temp_data.SUBSTITUTION_WINDOW_DAYS := msi_record_temp.SUBSTITUTION_WINDOW_DAYS;
   ELSIF msii_temp_data.SUBSTITUTION_WINDOW_DAYS    = g_Upd_Null_NUM THEN
      msii_temp_data.SUBSTITUTION_WINDOW_DAYS := NULL;
   ELSIF msii_temp_data.SUBSTITUTION_WINDOW_DAYS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SUBSTITUTION_WINDOW_DAYS := NULL;
   END IF;
   IF msii_temp_data.LOT_SUBSTITUTION_ENABLED IS NULL THEN
      msii_temp_data.LOT_SUBSTITUTION_ENABLED := msi_record_temp.LOT_SUBSTITUTION_ENABLED;
   ELSIF msii_temp_data.LOT_SUBSTITUTION_ENABLED    = g_Upd_Null_CHAR THEN
      msii_temp_data.LOT_SUBSTITUTION_ENABLED := NULL;
   ELSIF msii_temp_data.LOT_SUBSTITUTION_ENABLED    = g_FND_Upd_Null_Char THEN
      msii_temp_data.LOT_SUBSTITUTION_ENABLED := NULL;
   ELSE
      msii_temp_data.LOT_SUBSTITUTION_ENABLED := trim(msii_temp_data.LOT_SUBSTITUTION_ENABLED);
   END IF;
   IF msii_temp_data.EAM_ACTIVITY_SOURCE_CODE IS NULL THEN
      msii_temp_data.EAM_ACTIVITY_SOURCE_CODE := msi_record_temp.EAM_ACTIVITY_SOURCE_CODE;
   ELSIF msii_temp_data.EAM_ACTIVITY_SOURCE_CODE    = g_Upd_Null_CHAR THEN
      msii_temp_data.EAM_ACTIVITY_SOURCE_CODE := NULL;
   ELSIF msii_temp_data.EAM_ACTIVITY_SOURCE_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.EAM_ACTIVITY_SOURCE_CODE := NULL;
   ELSE
      msii_temp_data.EAM_ACTIVITY_SOURCE_CODE := trim(msii_temp_data.EAM_ACTIVITY_SOURCE_CODE);
   END IF;
   IF msii_temp_data.CONFIG_MODEL_TYPE IS NULL THEN
      msii_temp_data.CONFIG_MODEL_TYPE := msi_record_temp.CONFIG_MODEL_TYPE;
   ELSIF msii_temp_data.CONFIG_MODEL_TYPE    = g_Upd_Null_CHAR THEN
      msii_temp_data.CONFIG_MODEL_TYPE := NULL;
   ELSIF msii_temp_data.CONFIG_MODEL_TYPE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.CONFIG_MODEL_TYPE := NULL;
   ELSE
      msii_temp_data.CONFIG_MODEL_TYPE := trim(msii_temp_data.CONFIG_MODEL_TYPE);
   END IF;
   msii_temp_data.TRACKING_QUANTITY_IND  := trim(msi_record_temp.TRACKING_QUANTITY_IND);
   msii_temp_data.ONT_PRICING_QTY_SOURCE := trim(msi_record_temp.ONT_PRICING_QTY_SOURCE);
   msii_temp_data.SECONDARY_DEFAULT_IND  := trim(msi_record_temp.SECONDARY_DEFAULT_IND);
   IF msii_temp_data.CONFIG_MATCH IS NULL THEN
      msii_temp_data.CONFIG_MATCH := msi_record_temp.CONFIG_MATCH;
   ELSIF msii_temp_data.CONFIG_MATCH    = g_Upd_Null_CHAR THEN
      msii_temp_data.CONFIG_MATCH := NULL;
   ELSIF msii_temp_data.CONFIG_MATCH    = g_FND_Upd_Null_Char THEN
      msii_temp_data.CONFIG_MATCH := NULL;
   ELSE
      msii_temp_data.CONFIG_MATCH := trim(msii_temp_data.CONFIG_MATCH);
   END IF;
   IF msii_temp_data.CURRENT_PHASE_ID IS NULL THEN
      msii_temp_data.CURRENT_PHASE_ID := msi_record_temp.CURRENT_PHASE_ID;
   ELSIF msii_temp_data.CURRENT_PHASE_ID    = -999999 THEN
      msii_temp_data.CURRENT_PHASE_ID := NULL;
   ELSIF msii_temp_data.CURRENT_PHASE_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.CURRENT_PHASE_ID := NULL;
   END IF;
   IF msii_temp_data.VMI_MINIMUM_DAYS IS NULL THEN
      msii_temp_data.VMI_MINIMUM_DAYS := msi_record_temp.VMI_MINIMUM_DAYS;
   ELSIF msii_temp_data.VMI_MINIMUM_DAYS    = g_Upd_Null_NUM THEN
      msii_temp_data.VMI_MINIMUM_DAYS := NULL;
   ELSIF msii_temp_data.VMI_MINIMUM_DAYS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.VMI_MINIMUM_DAYS := NULL;
   END IF;
   IF msii_temp_data.VMI_MAXIMUM_DAYS IS NULL THEN
      msii_temp_data.VMI_MAXIMUM_DAYS := msi_record_temp.VMI_MAXIMUM_DAYS;
   ELSIF msii_temp_data.VMI_MAXIMUM_DAYS    = g_Upd_Null_NUM THEN
      msii_temp_data.VMI_MAXIMUM_DAYS := NULL;
   ELSIF msii_temp_data.VMI_MAXIMUM_DAYS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.VMI_MAXIMUM_DAYS := NULL;
   END IF;
   IF msii_temp_data.SO_AUTHORIZATION_FLAG IS NULL THEN
      msii_temp_data.SO_AUTHORIZATION_FLAG := msi_record_temp.SO_AUTHORIZATION_FLAG;
   ELSIF msii_temp_data.SO_AUTHORIZATION_FLAG    = g_Upd_Null_NUM THEN
      msii_temp_data.SO_AUTHORIZATION_FLAG := NULL;
   ELSIF msii_temp_data.SO_AUTHORIZATION_FLAG    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SO_AUTHORIZATION_FLAG := NULL;
   END IF;
   IF msii_temp_data.CONSIGNED_FLAG IS NULL THEN
      msii_temp_data.CONSIGNED_FLAG := msi_record_temp.CONSIGNED_FLAG;
   ELSIF msii_temp_data.CONSIGNED_FLAG    = g_Upd_Null_NUM THEN
      msii_temp_data.CONSIGNED_FLAG := NULL;
   ELSIF msii_temp_data.CONSIGNED_FLAG    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.CONSIGNED_FLAG := NULL;
   END IF;
   IF msii_temp_data.FORECAST_HORIZON IS NULL THEN
      msii_temp_data.FORECAST_HORIZON := msi_record_temp.FORECAST_HORIZON;
   ELSIF msii_temp_data.FORECAST_HORIZON    = g_Upd_Null_NUM THEN
      msii_temp_data.FORECAST_HORIZON := NULL;
   ELSIF msii_temp_data.FORECAST_HORIZON    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.FORECAST_HORIZON := NULL;
   END IF;
   IF msii_temp_data.DAYS_TGT_INV_SUPPLY IS NULL THEN
      msii_temp_data.DAYS_TGT_INV_SUPPLY := msi_record_temp.DAYS_TGT_INV_SUPPLY;
   ELSIF msii_temp_data.DAYS_TGT_INV_SUPPLY    = g_Upd_Null_NUM THEN
      msii_temp_data.DAYS_TGT_INV_SUPPLY := NULL;
   ELSIF msii_temp_data.DAYS_TGT_INV_SUPPLY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DAYS_TGT_INV_SUPPLY := NULL;
   END IF;
   IF msii_temp_data.DAYS_TGT_INV_WINDOW IS NULL THEN
      msii_temp_data.DAYS_TGT_INV_WINDOW := msi_record_temp.DAYS_TGT_INV_WINDOW;
   ELSIF msii_temp_data.DAYS_TGT_INV_WINDOW    = g_Upd_Null_NUM THEN
      msii_temp_data.DAYS_TGT_INV_WINDOW := NULL;
   ELSIF msii_temp_data.DAYS_TGT_INV_WINDOW    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DAYS_TGT_INV_WINDOW := NULL;
   END IF;
   IF msii_temp_data.OVER_SHIPMENT_TOLERANCE IS NULL THEN
      msii_temp_data.OVER_SHIPMENT_TOLERANCE := msi_record_temp.OVER_SHIPMENT_TOLERANCE;
   ELSIF msii_temp_data.OVER_SHIPMENT_TOLERANCE    = g_Upd_Null_NUM THEN
      msii_temp_data.OVER_SHIPMENT_TOLERANCE := NULL;
   ELSIF msii_temp_data.OVER_SHIPMENT_TOLERANCE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.OVER_SHIPMENT_TOLERANCE := NULL;
   END IF;
   IF msii_temp_data.UNDER_RETURN_TOLERANCE IS NULL THEN
      msii_temp_data.UNDER_RETURN_TOLERANCE := msi_record_temp.UNDER_RETURN_TOLERANCE;
   ELSIF msii_temp_data.UNDER_RETURN_TOLERANCE    = g_Upd_Null_NUM THEN
      msii_temp_data.UNDER_RETURN_TOLERANCE := NULL;
   ELSIF msii_temp_data.UNDER_RETURN_TOLERANCE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.UNDER_RETURN_TOLERANCE := NULL;
   END IF;
   IF trim(msii_temp_data.DEFECT_TRACKING_ON_FLAG) is null then
      msii_temp_data.DEFECT_TRACKING_ON_FLAG := msi_record_temp.DEFECT_TRACKING_ON_FLAG;
   END IF;
   IF trim(msii_temp_data.DOWNLOADABLE_FLAG) is null then
      msii_temp_data.DOWNLOADABLE_FLAG := msi_record_temp.DOWNLOADABLE_FLAG;
   END IF;
   IF trim(msii_temp_data.COMMS_NL_TRACKABLE_FLAG) is null then
      msii_temp_data.COMMS_NL_TRACKABLE_FLAG := msi_record_temp.COMMS_NL_TRACKABLE_FLAG;
   END IF;
   IF trim(msii_temp_data.COMMS_ACTIVATION_REQD_FLAG) is null then
      msii_temp_data.COMMS_ACTIVATION_REQD_FLAG := msi_record_temp.COMMS_ACTIVATION_REQD_FLAG;
   END IF;
   IF trim(msii_temp_data.WEB_STATUS) is null then
      msii_temp_data.WEB_STATUS := msi_record_temp.WEB_STATUS;
   ELSE
      msii_temp_data.WEB_STATUS := trim(msii_temp_data.WEB_STATUS);
   END IF;
   IF msii_temp_data.DIMENSION_UOM_CODE IS NULL THEN
      msii_temp_data.DIMENSION_UOM_CODE := msi_record_temp.DIMENSION_UOM_CODE;
   ELSIF msii_temp_data.DIMENSION_UOM_CODE    = '!' THEN
      msii_temp_data.DIMENSION_UOM_CODE := NULL;
   ELSIF msii_temp_data.DIMENSION_UOM_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.DIMENSION_UOM_CODE := NULL;
   ELSE
      msii_temp_data.DIMENSION_UOM_CODE := trim(msii_temp_data.DIMENSION_UOM_CODE);
   END IF;
   IF msii_temp_data.UNIT_HEIGHT IS NULL THEN
      msii_temp_data.UNIT_HEIGHT := msi_record_temp.UNIT_HEIGHT;
   ELSIF msii_temp_data.UNIT_HEIGHT    = g_Upd_Null_NUM THEN
      msii_temp_data.UNIT_HEIGHT := NULL;
   ELSIF msii_temp_data.UNIT_HEIGHT    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.UNIT_HEIGHT := NULL;
   END IF;
   IF msii_temp_data.DEFAULT_LOT_STATUS_ID IS NULL THEN
      msii_temp_data.DEFAULT_LOT_STATUS_ID := msi_record_temp.DEFAULT_LOT_STATUS_ID;
   ELSIF msii_temp_data.DEFAULT_LOT_STATUS_ID    = g_Upd_Null_NUM THEN
      msii_temp_data.DEFAULT_LOT_STATUS_ID := NULL;
   ELSIF msii_temp_data.DEFAULT_LOT_STATUS_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DEFAULT_LOT_STATUS_ID := NULL;
   END IF;
   IF msii_temp_data.INVENTORY_CARRY_PENALTY IS NULL THEN
      msii_temp_data.INVENTORY_CARRY_PENALTY := msi_record_temp.INVENTORY_CARRY_PENALTY;
   ELSIF msii_temp_data.INVENTORY_CARRY_PENALTY    = g_Upd_Null_NUM THEN
      msii_temp_data.INVENTORY_CARRY_PENALTY := NULL;
   ELSIF msii_temp_data.INVENTORY_CARRY_PENALTY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.INVENTORY_CARRY_PENALTY := NULL;
   END IF;
   IF msii_temp_data.EAM_ITEM_TYPE IS NULL THEN
      msii_temp_data.EAM_ITEM_TYPE := msi_record_temp.EAM_ITEM_TYPE;
   ELSIF msii_temp_data.EAM_ITEM_TYPE    = g_Upd_Null_NUM THEN
      msii_temp_data.EAM_ITEM_TYPE := NULL;
   ELSIF msii_temp_data.EAM_ITEM_TYPE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.EAM_ITEM_TYPE := NULL;
   END IF;
   IF msii_temp_data.EAM_ACTIVITY_CAUSE_CODE IS NULL THEN
      msii_temp_data.EAM_ACTIVITY_CAUSE_CODE := msi_record_temp.EAM_ACTIVITY_CAUSE_CODE;
   ELSIF msii_temp_data.EAM_ACTIVITY_CAUSE_CODE    = g_Upd_Null_CHAR THEN
      msii_temp_data.EAM_ACTIVITY_CAUSE_CODE := NULL;
   ELSIF msii_temp_data.EAM_ACTIVITY_CAUSE_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.EAM_ACTIVITY_CAUSE_CODE := NULL;
   ELSE
      msii_temp_data.EAM_ACTIVITY_CAUSE_CODE := trim(msii_temp_data.EAM_ACTIVITY_CAUSE_CODE);
   END IF;
   IF msii_temp_data.EAM_ACT_SHUTDOWN_STATUS IS NULL THEN
      msii_temp_data.EAM_ACT_SHUTDOWN_STATUS := msi_record_temp.EAM_ACT_SHUTDOWN_STATUS;
   ELSIF msii_temp_data.EAM_ACT_SHUTDOWN_STATUS    = g_Upd_Null_CHAR THEN
      msii_temp_data.EAM_ACT_SHUTDOWN_STATUS := NULL;
   ELSIF msii_temp_data.EAM_ACT_SHUTDOWN_STATUS    = g_FND_Upd_Null_Char THEN
      msii_temp_data.EAM_ACT_SHUTDOWN_STATUS := NULL;
   ELSE
      msii_temp_data.EAM_ACT_SHUTDOWN_STATUS := trim(msii_temp_data.EAM_ACT_SHUTDOWN_STATUS);
   END IF;
   IF msii_temp_data.CONTRACT_ITEM_TYPE_CODE IS NULL THEN
      msii_temp_data.CONTRACT_ITEM_TYPE_CODE := msi_record_temp.CONTRACT_ITEM_TYPE_CODE;
   ELSIF msii_temp_data.CONTRACT_ITEM_TYPE_CODE    = g_Upd_Null_CHAR THEN
      msii_temp_data.CONTRACT_ITEM_TYPE_CODE := NULL;
   ELSIF msii_temp_data.CONTRACT_ITEM_TYPE_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.CONTRACT_ITEM_TYPE_CODE := NULL;
   ELSE
      msii_temp_data.CONTRACT_ITEM_TYPE_CODE := trim(msii_temp_data.CONTRACT_ITEM_TYPE_CODE);
   END IF;
   IF msii_temp_data.SERV_REQ_ENABLED_CODE IS NULL THEN
      msii_temp_data.SERV_REQ_ENABLED_CODE := msi_record_temp.SERV_REQ_ENABLED_CODE;
   ELSIF msii_temp_data.SERV_REQ_ENABLED_CODE    = g_Upd_Null_CHAR THEN
      msii_temp_data.SERV_REQ_ENABLED_CODE := NULL;
   ELSIF msii_temp_data.SERV_REQ_ENABLED_CODE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.SERV_REQ_ENABLED_CODE := NULL;
   ELSE
      msii_temp_data.SERV_REQ_ENABLED_CODE := trim(msii_temp_data.SERV_REQ_ENABLED_CODE);
   END IF;
   IF msii_temp_data.PLANNED_INV_POINT_FLAG IS NULL THEN
      msii_temp_data.PLANNED_INV_POINT_FLAG := msi_record_temp.PLANNED_INV_POINT_FLAG;
   ELSIF msii_temp_data.PLANNED_INV_POINT_FLAG    = g_Upd_Null_CHAR THEN
      msii_temp_data.PLANNED_INV_POINT_FLAG := NULL;
   ELSIF msii_temp_data.PLANNED_INV_POINT_FLAG    = g_FND_Upd_Null_Char THEN
      msii_temp_data.PLANNED_INV_POINT_FLAG := NULL;
   ELSE
      msii_temp_data.PLANNED_INV_POINT_FLAG := trim(msii_temp_data.PLANNED_INV_POINT_FLAG);
   END IF;
   IF msii_temp_data.DEFAULT_SO_SOURCE_TYPE IS NULL THEN
      msii_temp_data.DEFAULT_SO_SOURCE_TYPE := msi_record_temp.DEFAULT_SO_SOURCE_TYPE;
   ELSIF msii_temp_data.DEFAULT_SO_SOURCE_TYPE    = g_Upd_Null_CHAR THEN
      msii_temp_data.DEFAULT_SO_SOURCE_TYPE := NULL;
   ELSIF msii_temp_data.DEFAULT_SO_SOURCE_TYPE    = g_FND_Upd_Null_Char THEN
      msii_temp_data.DEFAULT_SO_SOURCE_TYPE := NULL;
   ELSE
      msii_temp_data.DEFAULT_SO_SOURCE_TYPE := trim(msii_temp_data.DEFAULT_SO_SOURCE_TYPE);
   END IF;
   IF msii_temp_data.SUBSTITUTION_WINDOW_CODE IS NULL THEN
      msii_temp_data.SUBSTITUTION_WINDOW_CODE := msi_record_temp.SUBSTITUTION_WINDOW_CODE;
   ELSIF msii_temp_data.SUBSTITUTION_WINDOW_CODE    = g_Upd_Null_NUM THEN
      msii_temp_data.SUBSTITUTION_WINDOW_CODE := NULL;
   ELSIF msii_temp_data.SUBSTITUTION_WINDOW_CODE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.SUBSTITUTION_WINDOW_CODE := NULL;
   END IF;
   IF msii_temp_data.MINIMUM_LICENSE_QUANTITY IS NULL THEN
      msii_temp_data.MINIMUM_LICENSE_QUANTITY := msi_record_temp.MINIMUM_LICENSE_QUANTITY;
   ELSIF msii_temp_data.MINIMUM_LICENSE_QUANTITY    = -999999 THEN
      msii_temp_data.MINIMUM_LICENSE_QUANTITY := NULL;
   ELSIF msii_temp_data.MINIMUM_LICENSE_QUANTITY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.MINIMUM_LICENSE_QUANTITY := NULL;
   END IF;
   IF msii_temp_data.IB_ITEM_INSTANCE_CLASS IS NULL THEN
      msii_temp_data.IB_ITEM_INSTANCE_CLASS := msi_record_temp.IB_ITEM_INSTANCE_CLASS;
   ELSIF msii_temp_data.IB_ITEM_INSTANCE_CLASS    = g_Upd_Null_CHAR THEN
      msii_temp_data.IB_ITEM_INSTANCE_CLASS := NULL;
   ELSIF msii_temp_data.IB_ITEM_INSTANCE_CLASS    = g_FND_Upd_Null_Char THEN
      msii_temp_data.IB_ITEM_INSTANCE_CLASS := NULL;
   ELSE
      msii_temp_data.IB_ITEM_INSTANCE_CLASS := trim(msii_temp_data.IB_ITEM_INSTANCE_CLASS);
   END IF;
   IF msii_temp_data.CONFIG_ORGS IS NULL THEN
      msii_temp_data.CONFIG_ORGS := msi_record_temp.CONFIG_ORGS;
   ELSIF msii_temp_data.CONFIG_ORGS    = g_Upd_Null_CHAR THEN
      msii_temp_data.CONFIG_ORGS := NULL;
   ELSIF msii_temp_data.CONFIG_ORGS    = g_FND_Upd_Null_Char THEN
      msii_temp_data.CONFIG_ORGS := NULL;
   ELSE
      msii_temp_data.CONFIG_ORGS := trim(msii_temp_data.CONFIG_ORGS);
   END IF;
   IF msii_temp_data.LIFECYCLE_ID IS NULL THEN
      msii_temp_data.LIFECYCLE_ID := msi_record_temp.LIFECYCLE_ID;
   ELSIF msii_temp_data.LIFECYCLE_ID    = -999999 THEN
      msii_temp_data.LIFECYCLE_ID := NULL;
   ELSIF msii_temp_data.LIFECYCLE_ID    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.LIFECYCLE_ID := NULL;
   END IF;
   IF msii_temp_data.VMI_MINIMUM_UNITS IS NULL THEN
      msii_temp_data.VMI_MINIMUM_UNITS := msi_record_temp.VMI_MINIMUM_UNITS;
   ELSIF msii_temp_data.VMI_MINIMUM_UNITS    = g_Upd_Null_NUM THEN
      msii_temp_data.VMI_MINIMUM_UNITS := NULL;
   ELSIF msii_temp_data.VMI_MINIMUM_UNITS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.VMI_MINIMUM_UNITS := NULL;
   END IF;
   IF msii_temp_data.VMI_MAXIMUM_UNITS IS NULL THEN
      msii_temp_data.VMI_MAXIMUM_UNITS := msi_record_temp.VMI_MAXIMUM_UNITS;
   ELSIF msii_temp_data.VMI_MAXIMUM_UNITS    = g_Upd_Null_NUM THEN
      msii_temp_data.VMI_MAXIMUM_UNITS := NULL;
   ELSIF msii_temp_data.VMI_MAXIMUM_UNITS    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.VMI_MAXIMUM_UNITS := NULL;
   END IF;
   IF msii_temp_data.VMI_FIXED_ORDER_QUANTITY IS NULL THEN
      msii_temp_data.VMI_FIXED_ORDER_QUANTITY := msi_record_temp.VMI_FIXED_ORDER_QUANTITY;
   ELSIF msii_temp_data.VMI_FIXED_ORDER_QUANTITY    = g_Upd_Null_NUM THEN
      msii_temp_data.VMI_FIXED_ORDER_QUANTITY := NULL;
   ELSIF msii_temp_data.VMI_FIXED_ORDER_QUANTITY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.VMI_FIXED_ORDER_QUANTITY := NULL;
   END IF;
   IF msii_temp_data.VMI_FORECAST_TYPE IS NULL THEN
      msii_temp_data.VMI_FORECAST_TYPE := msi_record_temp.VMI_FORECAST_TYPE;
   ELSIF msii_temp_data.VMI_FORECAST_TYPE    = g_Upd_Null_NUM THEN
      msii_temp_data.VMI_FORECAST_TYPE := NULL;
   ELSIF msii_temp_data.VMI_FORECAST_TYPE    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.VMI_FORECAST_TYPE := NULL;
   END IF;
   IF msii_temp_data.EXCLUDE_FROM_BUDGET_FLAG IS NULL THEN
      msii_temp_data.EXCLUDE_FROM_BUDGET_FLAG := msi_record_temp.EXCLUDE_FROM_BUDGET_FLAG;
   ELSIF msii_temp_data.EXCLUDE_FROM_BUDGET_FLAG    = g_Upd_Null_NUM THEN
      msii_temp_data.EXCLUDE_FROM_BUDGET_FLAG := NULL;
   ELSIF msii_temp_data.EXCLUDE_FROM_BUDGET_FLAG    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.EXCLUDE_FROM_BUDGET_FLAG := NULL;
   END IF;
   IF msii_temp_data.DAYS_MAX_INV_SUPPLY IS NULL THEN
      msii_temp_data.DAYS_MAX_INV_SUPPLY := msi_record_temp.DAYS_MAX_INV_SUPPLY;
   ELSIF msii_temp_data.DAYS_MAX_INV_SUPPLY    = g_Upd_Null_NUM THEN
      msii_temp_data.DAYS_MAX_INV_SUPPLY := NULL;
   ELSIF msii_temp_data.DAYS_MAX_INV_SUPPLY    = g_FND_Upd_Null_NUM THEN
      msii_temp_data.DAYS_MAX_INV_SUPPLY := NULL;
   END IF;
   IF trim(msii_temp_data.INVENTORY_ITEM_STATUS_CODE) is null then
      msii_temp_data.INVENTORY_ITEM_STATUS_CODE := msi_record_temp.INVENTORY_ITEM_STATUS_CODE;
   ELSE
      msii_temp_data.INVENTORY_ITEM_STATUS_CODE := trim(msii_temp_data.INVENTORY_ITEM_STATUS_CODE);
   END IF;
   /* R12 FPC Attributes */
   IF msii_temp_data.STYLE_ITEM_ID IS NULL THEN
      msii_temp_data.STYLE_ITEM_ID :=  msi_record_temp.STYLE_ITEM_ID;
   ELSIF msii_temp_data.STYLE_ITEM_ID = g_Upd_Null_NUM THEN
      msii_temp_data.STYLE_ITEM_ID :=  NULL;
   ELSIF msii_temp_data.STYLE_ITEM_ID = g_FND_Upd_Null_NUM THEN
      msii_temp_data.STYLE_ITEM_ID :=  NULL;
   END IF;

   IF trim(msii_temp_data.STYLE_ITEM_FLAG) IS NULL THEN
      msii_temp_data.STYLE_ITEM_FLAG :=  msi_record_temp.STYLE_ITEM_FLAG;
   ELSIF msii_temp_data.STYLE_ITEM_FLAG = g_Upd_Null_CHAR THEN
      msii_temp_data.STYLE_ITEM_FLAG :=  NULL;
   ELSIF msii_temp_data.STYLE_ITEM_FLAG = g_FND_Upd_Null_CHAR THEN
      msii_temp_data.STYLE_ITEM_FLAG :=  NULL;
   ELSE
      msii_temp_data.STYLE_ITEM_FLAG := trim(msii_temp_data.STYLE_ITEM_FLAG);
   END IF;

   IF trim(msii_temp_data.GDSN_OUTBOUND_ENABLED_FLAG) IS NULL THEN
      msii_temp_data.GDSN_OUTBOUND_ENABLED_FLAG := msi_record_temp.GDSN_OUTBOUND_ENABLED_FLAG;
   ELSIF msii_temp_data.GDSN_OUTBOUND_ENABLED_FLAG = g_Upd_Null_CHAR THEN
      msii_temp_data.GDSN_OUTBOUND_ENABLED_FLAG :=  NULL;
   ELSIF msii_temp_data.GDSN_OUTBOUND_ENABLED_FLAG = g_FND_Upd_Null_CHAR THEN
      msii_temp_data.GDSN_OUTBOUND_ENABLED_FLAG :=  NULL;
   ELSE
      msii_temp_data.GDSN_OUTBOUND_ENABLED_FLAG := trim(msii_temp_data.GDSN_OUTBOUND_ENABLED_FLAG);
   END IF;

   IF trim(msii_temp_data.TRADE_ITEM_DESCRIPTOR) IS NULL THEN
      IF ( msi_record_temp.TRADE_ITEM_DESCRIPTOR IS NULL AND msii_temp_data.GDSN_OUTBOUND_ENABLED_FLAG = 'Y' ) THEN --BUG 6455261
         --Retrieve default value for Trade Item Descriptor
         OPEN  c_trade_item_default;
         FETCH c_trade_item_default INTO msii_temp_data.TRADE_ITEM_DESCRIPTOR;
         CLOSE c_trade_item_default;
      ELSE
         msii_temp_data.TRADE_ITEM_DESCRIPTOR := msi_record_temp.TRADE_ITEM_DESCRIPTOR;
      END IF;
   ELSIF msii_temp_data.TRADE_ITEM_DESCRIPTOR = g_Upd_Null_CHAR THEN
      msii_temp_data.TRADE_ITEM_DESCRIPTOR :=  NULL;
   ELSIF msii_temp_data.TRADE_ITEM_DESCRIPTOR = g_FND_Upd_Null_CHAR THEN
      msii_temp_data.TRADE_ITEM_DESCRIPTOR :=  NULL;
   ELSE
      msii_temp_data.TRADE_ITEM_DESCRIPTOR := trim(msii_temp_data.TRADE_ITEM_DESCRIPTOR);
   END IF;


   UPDATE MTL_SYSTEM_ITEMS_INTERFACE SET ROW = msii_temp_data WHERE ROWID = row_id;

   -- End 5565453 : Perf issue reducing the shared memory

   RETURN (0);

EXCEPTION

   WHEN OTHERS THEN
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('when OTHERS exception raised in copy_msi_to_msii');
      END IF;
      RETURN(1);

END copy_msi_to_msii; -- }


FUNCTION mtl_pr_validate_item_update
(
	org_id          NUMBER,
	all_org         NUMBER          := 2,
	prog_appid      NUMBER          := -1,
	prog_id         NUMBER          := -1,
	request_id      NUMBER          := -1,
	user_id         NUMBER          := -1,
	login_id        NUMBER          := -1,
	err_text IN OUT NOCOPY VARCHAR2,
	xset_id  IN     NUMBER          DEFAULT NULL
)
return INTEGER
IS
	ret_code_create		NUMBER		:= 1;
	ret_code_master		NUMBER		:= 1;
	ret_code_child		NUMBER		:= 1;

	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

BEGIN -- {

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD1B: Inside mtl_pr_validate_item_update'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;

	ret_code_create := INVPVALI.mtl_pr_validate_item(
				org_id => org_id,
				all_org => all_org,
				prog_appid => prog_appid,
				prog_id => prog_id,
				request_id => request_id,
				user_id => user_id,
				login_id => login_id,
				err_text => err_text,
				xset_id => xset_id);

	if (ret_code_create <> 0) then
		return (ret_code_create);
	end if;

	ret_code_master := INVUPD2B.validate_item_update_master(
				org_id,
				all_org,
				prog_appid,
				prog_id,
				request_id,
				user_id,
				login_id,
				err_text,
				xset_id);

	ret_code_child := INVUPD2B.validate_item_update_child(
				org_id,
				all_org,
				prog_appid,
				prog_id,
				request_id,
				user_id,
				login_id,
				err_text,
				xset_id);

	if (ret_code_master = 0 AND ret_code_child = 0) then
		return (0);
	else
		if (ret_code_master <> 0) then
			return (ret_code_master);
		end if;
		if (ret_code_child <> 0) then
			return (ret_code_child);
		end if;
	end if;

EXCEPTION

   when OTHERS then
	IF l_inv_debug_level IN(101, 102) THEN
		INVPUTLI.info('when OTHERS exception raised in mtl_pr_validate_item_update' || SQLERRM);
	END IF;

	return (1);

END mtl_pr_validate_item_update; -- }

--Start Bug: 2808277 Supporting Item Revision Update
FUNCTION assign_item_rev_data_update(
	org_id		NUMBER,
	all_org		NUMBER		:= 2,
	prog_appid	NUMBER		:= -1,
	prog_id		NUMBER		:= -1,
	request_id	NUMBER		:= -1,
	user_id		NUMBER		:= -1,
	login_id	NUMBER		:= -1,
	err_text IN OUT NOCOPY VARCHAR2,
	xset_id  IN	NUMBER		DEFAULT -999)
RETURN  NUMBER IS

   --Fill Item Id for Item Number
   CURSOR c_fill_Item_Id IS
     SELECT DISTINCT item_number,
	    organization_id
     FROM   mtl_item_revisions_interface
     WHERE  inventory_item_id IS     NULL
     AND    item_number       IS NOT NULL
     AND    organization_id   IS NOT NULL
     AND    set_process_id    = xset_id
     AND    process_flag      = 1;

   --Assigning Transaction Id
   CURSOR c_fill_transaction_id IS
      SELECT distinct inventory_item_id,
	     organization_id,
	     transaction_type
      FROM   mtl_item_revisions_interface
      WHERE  process_flag = 1
      AND    set_process_id  = xset_id
      AND    transaction_id IS NULL --Bug: 3019435 Added condition
      AND   (organization_id = org_id or all_org = 1);

   --Fill Revision id, default values
   CURSOR c_fill_revision_details IS
     SELECT   rowid
             ,revision
	     ,revision_id
	     ,description
             ,inventory_item_id
	     ,organization_id
             ,change_notice
	     ,ecn_initiation_date
	     ,implementation_date
	     ,implemented_serial_number
	     ,effectivity_date
	     ,attribute_category
	     ,attribute1
	     ,attribute2
	     ,attribute3
	     ,attribute4
	     ,attribute5
	     ,attribute6
	     ,attribute7
	     ,attribute8
	     ,attribute9
	     ,attribute10
	     ,attribute11
	     ,attribute12
	     ,attribute13
	     ,attribute14
	     ,attribute15
	     ,revision_label
	     ,revision_reason
	     ,transaction_id
     FROM   mtl_item_revisions_interface
     WHERE  process_flag = 1
     AND   set_process_id  = xset_id
     AND   (organization_id = org_id or all_org = 1);

   CURSOR c_get_rev_defaults(cp_org_id   NUMBER,
		             cp_item_id  NUMBER,
			     cp_revision VARCHAR2) IS
     SELECT   revision_id
	     ,description
             ,change_notice
	     ,ecn_initiation_date
	     ,implementation_date
	     --,implemented_serial_number
	     ,effectivity_date
	     ,attribute_category
	     ,attribute1
	     ,attribute2
	     ,attribute3
	     ,attribute4
	     ,attribute5
	     ,attribute6
	     ,attribute7
	     ,attribute8
	     ,attribute9
	     ,attribute10
	     ,attribute11
	     ,attribute12
	     ,attribute13
	     ,attribute14
	     ,attribute15
	     ,revision_label
	     ,revision_reason
	     ,revised_item_sequence_id
	     ,lifecycle_id
	     ,current_phase_id
     FROM   mtl_item_revisions
     WHERE  organization_id   = cp_org_id
     AND    inventory_item_id = cp_item_id
     AND    revision          = cp_revision;

   l_process_flag_1    CONSTANT  NUMBER :=  1;
   l_process_flag_2    CONSTANT  NUMBER :=  2;
   l_process_flag_3    CONSTANT  NUMBER :=  3;
   flex_id		         NUMBER;
   l_rev_rec		         c_get_rev_defaults%ROWTYPE;
   status                        NUMBER := 0;
   dumm_status                   NUMBER := 0;
   tran_id                       NUMBER := 0;
   ASSIGN_ERROR                  EXCEPTION;
   LOGGING_ERROR                 EXCEPTION;
   l_sysdate                     DATE := SYSDATE;
   l_all_org           CONSTANT  NUMBER :=  1;
   l_default_revision  VARCHAR2(3);

BEGIN

   --Assign Orgnization Id for missing ones
   UPDATE mtl_item_revisions_interface i
   SET    i.organization_id = (SELECT o.organization_id
			       FROM   mtl_parameters o
			       WHERE  o.organization_code = i.organization_code)
   WHERE i.organization_id is NULL
   AND   set_process_id  = xset_id
   AND   i.process_flag = l_process_flag_1;

   --Assign Item Id
   FOR cr IN c_fill_Item_Id loop

      status := INVPUOPI.mtl_pr_parse_flex_name (
                        cr.organization_id, 'MSTK',
                        cr.item_number,   flex_id,
                        0, err_text);
      IF status <> 0 THEN
----Bug: 3019435 Changed the code with in IF st.
	 UPDATE mtl_item_revisions_interface
	 SET    process_flag     = l_process_flag_3,
	        transaction_id   = NVL(transaction_id,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval)
	 WHERE  item_number      = cr.item_number
	 AND    inventory_item_id IS NULL
	 AND    process_flag     = l_process_flag_1
         AND    set_process_id   = xset_id
	 AND    organization_id  = cr.organization_id
	 RETURNING transaction_id INTO tran_id;
/*
         SELECT MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
	 INTO  tran_id
	 FROM dual;
*/
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                err_text,
				'item_number',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERROR ;
         END IF;

/*	 UPDATE mtl_item_revisions_interface
	 SET    process_flag     = l_process_flag_3,
	        transaction_id   = tran_id
	 WHERE  item_number      = cr.item_number
	 AND    inventory_item_id IS NULL
	 AND    process_flag     = l_process_flag_1
         AND    set_process_id   = xset_id
	 AND    organization_id  = cr.organization_id;
*/
	 IF status < 0 THEN
	    raise ASSIGN_ERROR;
	 END IF;

      ELSIF status = 0 THEN

         UPDATE mtl_item_revisions_interface
         SET   inventory_item_id = flex_id
         WHERE item_number = cr.item_number
         AND   set_process_id   = xset_id
	 AND   organization_id  = cr.organization_id;

      END IF;

   END LOOP; -- Fill Item Id LOOP.

   --Assign Transaction Id
   FOR cr IN c_fill_transaction_id LOOP

      SELECT MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
      INTO   tran_id FROM dual;

      UPDATE  mtl_item_revisions_interface
      SET     transaction_id     = tran_id
      WHERE   inventory_item_id  = cr.inventory_item_id
      AND     organization_id    = cr.organization_id
      AND     transaction_type   = cr.transaction_type
      -- AND     set_process_id + 0 = xset_id --fix for bug#8757041,removed + 0
      AND     set_process_id = xset_id
      AND     process_flag       = l_process_flag_1;

   END LOOP;


   --Fill Revision id, default values
   FOR cr IN c_fill_Revision_details LOOP

      OPEN  c_get_rev_defaults(cp_org_id   => cr.organization_id,
			       cp_item_id  => cr.inventory_item_id,
			       cp_revision => cr.revision);
      FETCH c_get_rev_defaults INTO l_rev_rec;
      CLOSE c_get_rev_defaults;

      IF l_rev_rec.revision_id IS NOT NULL THEN

         SELECT  starting_revision
	 INTO    l_default_revision
	 FROM    mtl_parameters
	 WHERE   organization_id = cr.organization_id;

	 IF l_default_revision = cr.revision THEN

	    UPDATE  mtl_item_revisions_interface
	    SET     effectivity_date = l_rev_rec.effectivity_date
	    WHERE   rowid = cr.rowid;

	 END IF;


         UPDATE  mtl_item_revisions_interface
         SET      revision_id               = l_rev_rec.revision_id
	         ,description               = decode(description,NULL,l_rev_rec.description,'!',NULL,g_FND_Upd_Null_Char,NULL,description)
		 ,change_notice             = l_rev_rec.change_notice
	         ,ecn_initiation_date       = l_rev_rec.ecn_initiation_date
		 ,implementation_date       = NVL(implementation_date,l_rev_rec.implementation_date)
	 	 --,implemented_serial_number = NVL(implemented_serial_number,l_rev_rec.implemented_serial_number)
	         ,effectivity_date          = NVL(effectivity_date,l_rev_rec.effectivity_date)
		 ,attribute_category        = decode(attribute_category,NULL,l_rev_rec.attribute_category,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute_category)
		 ,attribute1                = decode(attribute1,NULL,l_rev_rec.attribute1,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute1)
		 ,attribute2                = decode(attribute2,NULL,l_rev_rec.attribute2,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute2)
		 ,attribute3                = decode(attribute3,NULL,l_rev_rec.attribute3,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute3)
		 ,attribute4                = decode(attribute4,NULL,l_rev_rec.attribute4,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute4)
		 ,attribute5                = decode(attribute5,NULL,l_rev_rec.attribute5,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute5)
		 ,attribute6                = decode(attribute6,NULL,l_rev_rec.attribute6,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute6)
		 ,attribute7                = decode(attribute7,NULL,l_rev_rec.attribute7,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute7)
		 ,attribute8                = decode(attribute8,NULL,l_rev_rec.attribute8,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute8)
		 ,attribute9                = decode(attribute9,NULL,l_rev_rec.attribute9,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute9)
		 ,attribute10               = decode(attribute10,NULL,l_rev_rec.attribute10,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute10)
		 ,attribute11               = decode(attribute11,NULL,l_rev_rec.attribute11,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute11)
		 ,attribute12               = decode(attribute12,NULL,l_rev_rec.attribute12,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute12)
		 ,attribute13               = decode(attribute13,NULL,l_rev_rec.attribute13,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute13)
		 ,attribute14               = decode(attribute14,NULL,l_rev_rec.attribute14,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute14)
		 ,attribute15               = decode(attribute15,NULL,l_rev_rec.attribute15,'!',NULL, g_FND_Upd_Null_Char, NULL, attribute15)
		 ,revision_label            = decode(revision_label,NULL,l_rev_rec.revision_label,'!',NULL, g_FND_Upd_Null_Char, NULL, revision_label)
		 ,revision_reason           = decode(revision_reason,NULL,l_rev_rec.revision_reason,'!',NULL, g_FND_Upd_Null_Char, NULL, revision_reason)
		 ,revised_item_sequence_id  = decode(revised_item_sequence_id,NULL,l_rev_rec.revised_item_sequence_id,g_Upd_Null_NUM,NULL, g_FND_Upd_Null_NUM, NULL, revised_item_sequence_id)
		 ,lifecycle_id              = decode(lifecycle_id,NULL,l_rev_rec.lifecycle_id,g_Upd_Null_NUM,NULL, g_FND_Upd_Null_NUM, NULL, lifecycle_id)
		 ,current_phase_id          = decode(current_phase_id,NULL,l_rev_rec.current_phase_id,g_Upd_Null_NUM,NULL, g_FND_Upd_Null_NUM, NULL, current_phase_id)
	 WHERE  rowid = cr.rowid;

      ELSE

         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.transaction_id,
                                err_text,
				'REVISION',
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_INVALID_REVISION',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERROR ;
         END IF;

         UPDATE mtl_item_revisions_interface
	 SET    process_flag     = l_process_flag_3
	 WHERE  rowid            = cr.rowid;

      END IF;

   END LOOP; --Revision defaults fill LOOP

   --Update process flag , at last
   UPDATE mtl_item_revisions_interface
   SET    process_flag        = l_process_flag_2 ,
	  last_update_date    = l_sysdate,
          last_updated_by     =  decode(last_updated_by,NULL,user_id,last_updated_by),
	  creation_date       = l_sysdate,
	  created_by          = decode(created_by, NULL, user_id,created_by)
	  --3070781 :Revision defaults fill LOOP is enough to fill below columns
	  --This routine gets called only during revision update.
          --implementation_date = nvl(effectivity_date, l_sysdate),
	  --effectivity_date    = nvl(effectivity_date, l_sysdate)
   WHERE  inventory_item_id is not null
   AND    process_flag        = l_process_flag_1
   AND    set_process_id      = xset_id
   AND    (organization_id    = org_id or all_org = l_all_org);

   --Set process flag for the records with errors
   UPDATE mtl_item_revisions_interface i
   SET    i.process_flag     = l_process_flag_3,
          i.last_update_date = sysdate,
          i.last_updated_by  = decode(i.last_updated_by, NULL, user_id,i.last_updated_by),
          i.creation_date    = l_sysdate,
          i.created_by       = decode(i.created_by, NULL, user_id,i.created_by)
   WHERE (i.inventory_item_id is NULL or  i.organization_id is NULL)
   AND   i.set_process_id    = xset_id
   AND   i.process_flag      = l_process_flag_1
   AND  (i.organization_id   = org_id or  all_org = l_all_org );

   RETURN (0);

EXCEPTION
   WHEN OTHERS THEN
      RETURN (1);
END assign_item_rev_data_update;
--End Bug: 2808277 Supporting Item Revision Update


end INVUPD1B; -- }

/
