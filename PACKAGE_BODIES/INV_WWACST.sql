--------------------------------------------------------
--  DDL for Package Body INV_WWACST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_WWACST" AS
/* $Header: INVWWACB.pls 120.0.12010000.2 2010/02/22 05:34:20 ptian ship $ */

Procedure get_cost_group_ids(
  p_TRX_ACTION_ID   IN    NUMBER,
  p_TRX_SOURCE_TYPE_ID  IN    NUMBER,
  p_TRX_TYPE_ID   IN    NUMBER,
  p_FM_ORG_COST_MTD   IN    NUMBER,
  p_TO_ORG_COST_MTD   IN    NUMBER,
  p_FM_ORG_ID     IN    NUMBER,
  p_TO_ORG_ID     IN    NUMBER,
  p_FM_PROJECT_ID     IN    NUMBER,
  p_TO_PROJECT_ID     IN    NUMBER,
  p_SOURCE_PROJECT_ID   IN    NUMBER,
  p_TRX_ID              IN   NUMBER,
  p_ITEM_ID             IN   NUMBER,
	p_TRX_SRC_ID          IN   NUMBER,
	p_FM_ORG_PRJ_ENABLED  IN   NUMBER,
	p_TO_ORG_PRJ_ENABLED  IN   NUMBER,
  x_COST_GROUP_ID     IN OUT    NOCOPY NUMBER,
  x_XFR_COST_GROUP_ID   IN OUT    NOCOPY NUMBER,
  x_PRJ_CST_COLLECTED  OUT   NOCOPY VARCHAR2,
  x_XPRJ_CST_COLLECTED  OUT   NOCOPY VARCHAR2,
  x_CATEGORY_ID OUT NOCOPY NUMBER,
  x_ERR_MESG      OUT   NOCOPY VARCHAR2) IS

	avg_cost_cond1		VARCHAR2(2):= 'N';
	avg_cost_cond2		VARCHAR2(2) := 'N';
	do_cst_grp_sql		boolean := FALSE;
	do_xfr_cst_grp_sql	boolean := FALSE ;
	v_type_class		number := 2;
	translated_mesg		varchar2(241);
	x_to_org_id		number := p_TO_ORG_ID;
	v_buffer		varchar2(241):= null;
	l_cost_group_id 	NUMBER := x_COST_GROUP_ID;
	l_xfr_cost_Group_id	NUMBER := x_XFR_COST_GROUP_ID;
	l_retstat varchar2(255);
	l_msgcnt number;
	l_stdcg_acc_flag NUMBER;
	l_local_msg VARCHAR2(255);
	l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
	l_def_cost_group_id NUMBER := 0;
	l_def_xfr_cost_group_id NUMBER := 0;
BEGIN
	x_CATEGORY_ID := null;
--inv_debug.message('ssia', 'in wwacb transfer cost group is ' || x_XFR_COST_GROUP_ID);
	x_err_mesg := null;
	x_PRJ_CST_COLLECTED := null;
	x_XPRJ_CST_COLLECTED := null;

	if ( (p_TRX_ACTION_ID IS NULL) OR ( p_TRX_SOURCE_TYPE_ID IS NULL) OR
     (p_FM_ORG_ID IS NULL) OR ( p_FM_ORG_COST_MTD IS NULL) ) then
		fnd_message.set_name('INV','INV_DATA_ERROR');
		fnd_message.set_token('ENTITY', 'get_cost_group_ids');
		translated_mesg := fnd_message.get ;
		x_err_mesg := substr(translated_mesg,1,240) ;
		return ;
	end if;

	if ( p_FM_ORG_COST_MTD IN (2,5,6) ) then
		avg_cost_cond1 := 'Y' ;
		-- Call Costing API to retrieve cost_category_id
		CST_UTILITY_PUB.getTxnCategoryId(
				p_api_version => 1.0,
				p_validation_level => fnd_api.G_VALID_LEVEL_NONE,
				p_txn_id => p_TRX_ID,
				p_txn_action_id => p_TRX_ACTION_ID,
				p_txn_source_type_id => p_TRX_SOURCE_TYPE_ID,
				p_txn_source_id  => p_TRX_SRC_ID,
				p_item_id   => p_ITEM_ID,
				p_organization_id => p_FM_ORG_ID,
				x_category_id  =>  x_CATEGORY_ID,
				x_return_status => l_retstat,
				x_msg_count => l_msgcnt,
				x_msg_data => l_local_msg );
		if (l_retstat <> fnd_api.g_ret_sts_success) then
			translated_mesg := fnd_message.get ;
			x_err_mesg := substr(translated_mesg,1,240) ;
			return ;
		end if;
	elsif (p_FM_ORG_COST_MTD = 1 ) then
		/* If Standard Costing, check if CostGroupAccounting enabled */
		CST_UTILITY_PUB.get_Std_CG_Acct_Flag(
				P_API_VERSION => 1.0,
				P_VALIDATION_LEVEL => fnd_api.G_VALID_LEVEL_NONE,
				P_ORGANIZATION_ID => p_FM_ORG_ID,
				X_CG_ACCT_FLAG => l_stdcg_acc_flag,
				X_RETURN_STATUS => l_retstat,
				X_MSG_COUNT => l_msgcnt,
				X_MSG_DATA => l_local_msg);
		if (l_retstat <> fnd_api.g_ret_sts_success) then
			translated_mesg := fnd_message.get ;
			x_err_mesg := substr(translated_mesg,1,240) ;
			return ;
		end if;
		if (l_stdcg_acc_flag = 1) then
			avg_cost_cond1 := 'Y';
		else
			avg_cost_cond1 := 'N';
		end if;
	else
		avg_cost_cond1 := 'N';
	end if;

	if ( NVL(p_TO_ORG_COST_MTD,1) IN (2,5,6) ) then
		avg_cost_cond2 := 'Y' ;
	elsif (p_TO_ORG_COST_MTD = 1 ) then
		/* If Standard Costing, check if CostGroupAccounting enabled */
		CST_UTILITY_PUB.get_Std_CG_Acct_Flag(
				P_API_VERSION => 1.0,
				P_VALIDATION_LEVEL => fnd_api.G_VALID_LEVEL_NONE,
				P_ORGANIZATION_ID => p_TO_ORG_ID,
				X_CG_ACCT_FLAG => l_stdcg_acc_flag,
				X_RETURN_STATUS => l_retstat,
				X_MSG_COUNT => l_msgcnt,
				X_MSG_DATA => l_local_msg );
		if (l_retstat <> fnd_api.g_ret_sts_success) then
			translated_mesg := fnd_message.get ;
			x_err_mesg := substr(translated_mesg,1,240) ;
			return ;
		end if;
		if (l_stdcg_acc_flag = 1) then
			avg_cost_cond2 := 'Y';
		else
			avg_cost_cond2 := 'N';
		end if;
	else
		avg_cost_cond2 := 'N';
	end if;

	if ( p_TRX_ACTION_ID in (2,28) ) then
		avg_cost_cond2 := avg_cost_cond1 ;
		x_to_org_id := p_FM_ORG_ID ;
	end if;
	--2700919 fix added 5 (Planning Xfr) and 6 (Ownership Xfr)
	if ( p_TRX_ACTION_ID IN (1,2,3,4,8,12,21,24,27,28,29,31,32,33,34,5,6)) then
		if ( avg_cost_cond1 = 'Y' ) then
			if ( p_FM_PROJECT_ID IS NOT NULL ) then
				do_cst_grp_sql := TRUE ;
			else
				l_cost_group_id := -1 ;
			end if ;
		end if;
	end if;

	--2700919 fix added 5 (Planning Xfr) and 6 (Ownership Xfr)
	if ( p_TRX_ACTION_ID IN ( 2,3,12,21,28,5,6 ) ) then
		if ( avg_cost_cond2 = 'Y' ) then
			if ( p_TO_PROJECT_ID IS NOT NULL ) then
				do_xfr_cst_grp_sql := TRUE ;
			else
				l_xfr_cost_group_id := -1 ;
			end if ;
		end if;
	end if;

/*
 +--------------------------------------------------------------------------+
 | For R11, issue from "common" location  to project location for WIP issues|
 | needs to have the cost group id of the source project. This will be      |
 | overloaded in the xfer_cost_group_id column. This will only be done if   |
 | we are under average costing scenario.                                   |
 +--------------------------------------------------------------------------+*/

--Bug#4108315:Added transaction_action_ids 34(-ve Component Return),27(Component Return) and 33(-ve Component Issue).

   if ((p_TRX_SOURCE_TYPE_ID = 5) AND (avg_cost_cond1 = 'Y') AND
       /* bug2120290  (NVL(l_cost_group_id,-99) = 1) AND */
       (p_TRX_ACTION_ID IN (1,27,33,34)) AND (p_SOURCE_PROJECT_ID IS NOT NULL)) then
       BEGIN
	  SELECT costing_group_id
	    INTO l_xfr_cost_group_id
	    FROM mrp_project_parameters
	    WHERE organization_id = p_FM_ORG_ID
	    AND project_id = p_SOURCE_PROJECT_ID ;

	  -- 3052368. Cost group ID was not returned if set to 1. Changed it to
	  -- return default cost group of the org. if the cost group is
	  -- null for the project.

	  IF (l_xfr_cost_group_id IS NULL) THEN
	     begin
		SELECT default_cost_group_id INTO l_xfr_cost_group_id from
		  mtl_parameters WHERE organization_id = p_fm_org_id;
	     EXCEPTION
		WHEN no_data_found THEN
		   l_xfr_cost_group_id := -1 ;
	     END ;
	  END IF;

       EXCEPTION
	  WHEN NO_DATA_FOUND then
	     l_xfr_cost_group_id := -1 ;
	     -- Have to return default cost group id
       END;
   end if;

   if ( do_cst_grp_sql ) then
      BEGIN
	 SELECT costing_group_id
	   INTO l_cost_group_id
	   FROM mrp_project_parameters
	   WHERE organization_id = p_FM_ORG_ID
	   AND project_id = p_FM_PROJECT_ID ;

	 -- If the cost group id is null then get the default
	 -- 3052368. Cost group ID was not returned if set to 1. Changed it to
	 -- return default cost group of the org. if the cost group is
	 -- null for the project.
	 IF (l_cost_group_id IS NULL) THEN
	    begin
	       SELECT default_cost_group_id INTO l_cost_group_id from
		 mtl_parameters WHERE organization_id = p_fm_org_id;
	    EXCEPTION
	       WHEN no_data_found THEN
		  l_cost_group_id := -1 ;
	    END ;

	 END IF;

      EXCEPTION
	 WHEN NO_DATA_FOUND then
	    l_cost_group_id := -1 ;
      END ;

   end if;

   if ( do_xfr_cst_grp_sql ) then
      BEGIN
	 SELECT costing_group_id
	   INTO l_xfr_cost_group_id
	   FROM mrp_project_parameters
	   WHERE organization_id = x_to_org_id
	   AND project_id = p_TO_PROJECT_ID ;

      EXCEPTION
	 WHEN NO_DATA_FOUND then
	    l_xfr_cost_group_id := -1 ;
      END ;

      -- If the cost group id is null then get the default
      -- 3052368. Cost group ID was not returned if set to 1. Changed it to
      -- return default cost group of the org. if the cost group is
      -- null for the project.
      IF (l_xfr_cost_group_id IS NULL) THEN

	 begin
	    SELECT default_cost_group_id INTO l_xfr_cost_group_id from
	      mtl_parameters WHERE organization_id =  x_to_org_id;
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_xfr_cost_group_id := -1 ;
	 END ;

      END IF;
   end if;

   /* Now take care of populating pm_cost_collected flag */
   if ( avg_cost_cond1 = 'Y' ) AND ( p_fm_org_prj_enabled = 1 ) then
      x_PRJ_CST_COLLECTED := 'N' ;
    elsif ((avg_cost_cond1 = 'N') OR
	   ((avg_cost_cond1 = 'Y') AND (p_fm_org_prj_enabled = 2))) then  --Fix for 1598196
      if ( (p_TRX_ACTION_ID IN (1,27)) and
	   ((p_TRX_SOURCE_TYPE_ID IN (3,4,6,13)) OR
	    (p_TRX_SOURCE_TYPE_ID > 100)) ) then
	 if ( p_TRX_TYPE_ID IS NOT NULL) then
	    SELECT NVL(type_class,2)
	      INTO v_type_class
	      FROM mtl_transaction_types
	      WHERE transaction_type_id = p_TRX_TYPE_ID ;
	 end if;
	 if ( v_type_class = 1 ) then
	    x_PRJ_CST_COLLECTED := 'N' ;
	  else
	    x_PRJ_CST_COLLECTED := null;
	 end if;
      end if;
   end if;

   if (( avg_cost_cond2 = 'Y' ) AND ( p_to_org_prj_enabled = 1)) then
      x_XPRJ_CST_COLLECTED := 'N' ;
   end if;

   IF (l_cost_group_id <> -1) then
      x_COST_GROUP_ID := l_cost_group_id;
   end if;

   IF (l_xfr_cost_group_id <> -1) then
      x_XFR_COST_GROUP_ID := l_xfr_cost_group_id;
   end if;

   IF (l_debug = 1) THEN
      inv_trx_util_pub.trace('PrjCG : CG='||x_COST_GROUP_ID||',XfrCG='||x_XFR_COST_GROUP_ID, 'PRJCG', 9);
   END IF;
EXCEPTION
   WHEN OTHERS then
      fnd_message.set_name('INV','INV_UNHANDLED_ERR');
      fnd_message.set_token('ENTITY1', 'get_cost_group_ids');
      v_buffer := to_char(SQLCODE) || ' '|| substr(SQLERRM,1,150);
      fnd_message.set_token('ENTITY2', v_buffer);
      translated_mesg := fnd_message.get ;
      translated_mesg := substr(translated_mesg,1,230) ;
      x_err_mesg  := translated_mesg ;
end get_cost_group_ids ;


Procedure populate_cost_details(
	V_TRANSACTION_ID		IN 	NUMBER,
	V_ORG_ID			IN	NUMBER,
	V_ITEM_ID			IN	NUMBER,
	V_TXN_COST			IN 	NUMBER,
	V_NEW_AVG_COST			IN	NUMBER,
	V_PER_CHANGE			IN	NUMBER,
	V_VAL_CHANGE			IN	NUMBER,
	V_MAT_ACCNT			IN	NUMBER,
	V_MAT_OVHD_ACCNT		IN	NUMBER,
	V_RES_ACCNT			IN	NUMBER,
	V_OSP_ACCNT			IN	NUMBER,
	V_OVHD_ACCNT			IN	NUMBER,
	V_USER_ID			IN	NUMBER,
	V_LOGIN_ID			IN	NUMBER,
	V_REQUEST_ID			IN	NUMBER,
	V_PROG_APPL_ID			IN	NUMBER,
	V_PROG_ID			IN	NUMBER,
	V_ERR_NUM			OUT	NOCOPY NUMBER,
	V_ERR_CODE			OUT	NOCOPY VARCHAR2,
	v_err_mesg			OUT	NOCOPY VARCHAR2,
	V_TXN_SRC_TYPE_ID		IN	NUMBER,
	V_TXN_ACTION_ID			IN	NUMBER,
	V_COST_GROUP_ID			IN	NUMBER) IS

	translated_mesg		varchar2(2000) := null ;
	v_buffer		varchar2(241):= null;
Begin

  /* if txn_cost is null then don't do anything, zero err_num, means
     things are ok
  */

v_err_code := null;
v_err_mesg := null;
if ( v_txn_cost IS NULL ) then
  v_err_num := 0 ;
  return ;
end if;

/* Check if all data has been passed properly, else error
*/

if ( v_txn_src_type_id IS NULL ) or ( v_txn_action_id IS NULL ) or
   ( v_org_id IS NULL ) or ( v_item_id IS NULL ) OR (V_user_id IS NULL) or
   ( v_login_id IS NULL )  then
  v_err_num := -1 ;
  fnd_message.set_name('INV','INV_DATA_ERROR');
  fnd_message.set_token('ENTITY', 'populate_cost_details');
  translated_mesg := fnd_message.get ;
  v_err_mesg := substr(translated_mesg,1,240) ;
  return ;
end if;

/* For misc. transctions call costing package CSTPACIT and procedure
   cost_det_new_insert
*/
if ( ((v_txn_src_type_id IN (3,6,13)) OR (v_txn_src_type_id > 100) ) AND
   (v_txn_action_id IN (1,27)) ) then

  CSTPACIT.cost_det_new_insert(
	V_TRANSACTION_ID,
	V_TXN_ACTION_ID,
	V_ORG_ID,
	V_ITEM_ID,
	V_COST_GROUP_ID,
	V_TXN_COST,
	V_NEW_AVG_COST,
	V_PER_CHANGE,
	V_VAL_CHANGE,
	V_MAT_ACCNT,
	V_MAT_OVHD_ACCNT,
	V_RES_ACCNT,
	V_OSP_ACCNT,
	V_OVHD_ACCNT,
	V_USER_ID,
	V_LOGIN_ID,
	V_REQUEST_ID,
	V_PROG_APPL_ID,
	V_PROG_ID,
	V_ERR_NUM,
	V_ERR_CODE,
	V_ERR_MESG);

else
  /* populate the row in mtl_cst_txn_cost_details ourself. Do
   * not insert a row if we are doing a intrasnsit receipt or
   * intransit shipment. Also not to insert if it is cost
   * update transaction. (Fix bug 842532)
  */
  /*Bug 8760375,If transaction is a subinv transfer transaction,should NOT insert a record into MCTCD.*/
  if ( v_txn_action_id NOT IN (12, 21, 24, 2)) then

      INSERT INTO MTL_CST_TXN_COST_DETAILS (
      TRANSACTION_ID,
      ORGANIZATION_ID,
      INVENTORY_ITEM_ID,
      COST_ELEMENT_ID,
      LEVEL_TYPE,
      TRANSACTION_COST,
      NEW_AVERAGE_COST,
      PERCENTAGE_CHANGE,
      VALUE_CHANGE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
      )
    values (
      v_transaction_id,
      v_org_id,
      v_item_id,
      1,			/* Hard coded to This level Material */
      1,
      v_txn_cost,
      v_new_avg_cost,
      v_per_change,
      v_val_change,
      sysdate,
      v_user_id,
      sysdate,
      v_user_id,
      v_login_id,
      v_request_id,
      v_prog_appl_id,
      v_prog_id,
      sysdate);
  end if;
end if;
EXCEPTION
  when OTHERS then
    fnd_message.set_name('INV','INV_UNHANDLED_ERR');
    fnd_message.set_token('ENTITY1', 'populate_cost_details');
    v_buffer := to_char(SQLCODE) || ' '|| substr(SQLERRM,1,150);
    fnd_message.set_token('ENTITY2', v_buffer);
    translated_mesg := fnd_message.get ;
    translated_mesg := substr(translated_mesg,1,230) ;
    v_err_mesg  := translated_mesg ;

end populate_cost_details ;

Procedure call_prj_loc_validation(
	V_LOCID				IN	NUMBER,
	V_ORGID				IN	NUMBER,
	V_MODE				IN	VARCHAR2,
	V_REQD_FLAG			IN	VARCHAR2,
	V_PROJECT_ID			IN	NUMBER,
	V_TASK_ID			IN	NUMBER,
	V_RESULT			OUT	NOCOPY NUMBER,
	V_ERROR_MESG			OUT	NOCOPY VARCHAR2) IS

	translated_mesg		varchar2(2000) := null ;
	v_buffer		varchar2(241):= null;
	v_success		boolean := TRUE ;
BEGIN
  v_error_mesg := null;

  v_success := inv_projectlocator_pub.check_project_references(
                                                            v_orgid,
                                                            v_locid,
                                                            v_mode,
                                                            v_reqd_flag,
                                                            v_project_id,
                                                            v_task_id);
  if ( NOT v_success ) then
    v_result := 0 ;
    translated_mesg := fnd_message.get ;
    v_error_mesg := substr(translated_mesg,1,240) ;
  else
    v_result := 1;
  end if;
end call_prj_loc_validation;
END inv_wwacst;

/
