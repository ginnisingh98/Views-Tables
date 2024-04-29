--------------------------------------------------------
--  DDL for Package Body INV_PROJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PROJECT" AS
/* $Header: INVPRJIB.pls 120.10.12010000.4 2009/08/10 21:51:39 vissubra ship $ */

   G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_PROJECT';

   G_DISPLAYED_SEGMENTS       VARCHAR2(1000);
   G_CONCATENATED_SEGMENTS    VARCHAR2(1000);
   G_PHYSICAL_LOCATOR         VARCHAR2(1000);
   G_PROJECT_COLUMN           NUMBER;
   G_TASK_COLUMN              NUMBER;
   G_PROJECT_NUMBER         VARCHAR2(30);
   G_PROJECT_ID             NUMBER;
   G_TASK_ID                NUMBER;
   G_TASK_NUMBER            VARCHAR2(30);

   G_LOC_CONC_QRY          VARCHAR2(1000);
   G_CONCATENATED_LOCATOR  VARCHAR2(1000);
   G_LOC_QRY_BLT           VARCHAR2(1) := 'N';
     /*For performace enhancements*/
  g_delimiter             VARCHAR2(1);
  g_project_index         NUMBER;
  g_task_index            NUMBER;
  g_organization_id       NUMBER;


   PROCEDURE MYDEBUG(MSG IN VARCHAR2) IS

     L_MSG VARCHAR2(5100);
     l_len number;
     l_count number;
     l_start number;
     l_subs varchar2(200);
   BEGIN

      L_MSG := MSG;

     /* INV_MOBILE_HELPER_FUNCTIONS.TRACELOG(
                                           P_ERR_MSG => L_MSG,
                                           P_MODULE  => G_PKG_NAME,
                                           P_LEVEL   => 4
                                          );

      l_len := length(l_msg);
      l_count := floor(l_len/100) + 1;
      l_start := 1;
      for i in 1 .. l_count
	loop
	   l_subs := substr(l_msg, l_start, (l_start +99));
	   dbms_output.put_line(l_subs);
	   l_start := l_start + 100;
	end loop;*/
      INV_LOG_UTIL.TRACE(
			 P_MESSAGE => L_MSG,
			 P_MODULE  => G_PKG_NAME,
			 P_LEVEL   => 4
			);
   exception
      when others then
	 null;
   END;



Procedure resolve_project_references(
	source_project_id	IN	number,
	source_project_number	IN OUT	NOCOPY varchar2,
	source_task_id		IN	number,
	source_task_number	IN OUT	NOCOPY varchar2,
	p_project_id		IN	number,
	p_project_number	IN OUT	NOCOPY varchar2,
	t_task_id		IN	number,
	t_task_number		IN OUT	NOCOPY varchar2,
	to_project_id		IN	number,
	to_project_number	IN OUT	NOCOPY varchar2,
	to_task_id		IN	number,
	to_task_number		IN OUT	NOCOPY varchar2,
	pa_expenditure_org_id	IN	number,
	pa_expenditure_org	IN OUT	NOCOPY varchar2,
	success			IN OUT	NOCOPY boolean ) IS

	l_cur_mfg_org_id NUMBER;
BEGIN

  source_project_number := NULL;
  source_task_number    := NULL;
  p_project_number      := NULL;
  t_task_number         := NULL;
  to_project_number     := NULL;
  to_task_number        := NULL;
  pa_expenditure_org    := NULL;

  -- bug 4662395 set the profile mfg_organization_id so
  -- the call to PJM_PROJECTS_ALL_V will return data.
  l_cur_mfg_org_id := TO_NUMBER(FND_PROFILE.VALUE('MFG_ORGANIZATION_ID'));

  IF ( (pa_expenditure_org_id IS NOT NULL) AND
       ( (l_cur_mfg_org_id IS NULL) OR
         (l_cur_mfg_org_id IS NOT NULL AND l_cur_mfg_org_id <> FND_API.G_MISS_NUM)
       )
     ) THEN
    FND_PROFILE.put('MFG_ORGANIZATION_ID',pa_expenditure_org_id);
  END IF;


  if ( source_project_id IS NOT NULL ) then
  BEGIN
  -- Modified For bug 1301035
  /*  Bug 2490166 */
   /*  SELECT m.segment1
  INTO source_project_number
  FROM pa_projects_all m
  WHERE m.project_id = source_project_id ; */

 SELECT m.project_number
  INTO source_project_number
  FROM pjm_projects_all_v m
  WHERE m.project_id = source_project_id ;


  EXCEPTION
    WHEN NO_DATA_FOUND then
      source_project_number := NULL;
  END;
 end if;



  if ( p_project_id IS NOT NULL ) then
  BEGIN
  -- Modified For bug 1301035
   /*  Bug 2490166 */
   /* SELECT my.segment1
  INTO p_project_number
  FROM pa_projects_all  my
  WHERE my.project_id = p_project_id ; */

  SELECT my.project_number
  INTO p_project_number
  FROM pjm_projects_all_v my
  WHERE my.project_id = p_project_id ;

  success := TRUE ;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      p_project_number := NULL;
  END;

  end if;


  if ( to_project_id IS NOT NULL ) then
  BEGIN
  -- Modified For bug 1301035
   /*  Bug 2490166 */
  /*   SELECT m.segment1
  INTO to_project_number
  FROM pa_projects_all m
  WHERE m.project_id = to_project_id ; */

  SELECT m.project_number
  INTO to_project_number
  FROM pjm_projects_all_v m
  WHERE m.project_id = to_project_id ;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      to_project_number := NULL;

  END;
  end if;



  if ( source_task_id IS NOT NULL ) then
  BEGIN
  SELECT m.task_number
  INTO source_task_number
  FROM pjm_tasks_v m
  WHERE m.task_id = source_task_id
  AND   m.project_id = source_project_id;

  EXCEPTION
    WHEN NO_DATA_FOUND then
      source_task_number := NULL;

  END;
  end if;



  if ( t_task_id IS NOT NULL ) then
  BEGIN
  SELECT m.task_number
  INTO t_task_number
  FROM pjm_tasks_v m
  WHERE m.task_id = t_task_id
  AND   m.project_id = p_project_id;

  EXCEPTION
    WHEN NO_DATA_FOUND then
      t_task_number := NULL;

  END;
  end if;


  if ( to_task_id IS NOT NULL ) then
  BEGIN
  SELECT m.task_number
  INTO to_task_number
  FROM pjm_tasks_v m
  WHERE m.task_id = to_task_id
  AND   m.project_id = to_project_id;

  EXCEPTION
    WHEN NO_DATA_FOUND then
      to_task_number := NULL;

  END;
  end if;


  --Bug #5504073
  --Added a ROWNUM = 1 while fetching expenditure org name
  IF ( pa_expenditure_org_id IS NOT NULL ) then
    BEGIN
      SELECT m.name
      INTO pa_expenditure_org
      FROM pa_organizations_expend_v  m
      WHERE m.organization_id = pa_expenditure_org_id
      AND   active_flag='Y'
      AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND then
        pa_expenditure_org := NULL;
    END;
  END IF;

  success := TRUE;
EXCEPTION
  WHEN OTHERS then
    success := FALSE;

END resolve_project_references ;


Procedure org_project_parameters(
	org_id				IN	number,
	p_project_reference_enabled	OUT	NOCOPY number,
	p_pm_cost_collection_enabled	OUT	NOCOPY number,
	p_project_control_level		OUT	NOCOPY number,
	success				OUT	NOCOPY boolean) IS
BEGIN
  success := TRUE;
  p_project_reference_enabled := 2;
  p_pm_cost_collection_enabled := 2;
  p_project_control_level := 1 ;
  SELECT NVL(mp.project_reference_enabled, 2),
	 NVL(mp.pm_cost_collection_enabled,2),
	 NVL(mp.project_control_level,1)
  INTO   p_project_reference_enabled,
	 p_pm_cost_collection_enabled,
	 p_project_control_level
  FROM   mtl_parameters mp
  WHERE  organization_id = org_id ;

  EXCEPTION
    WHEN OTHERS then
      success := FALSE ;

END org_project_parameters ;



  Function onhand_qty(
	org_id 		number,
	sub_code	varchar2,
	loc_id		number)return number  IS

  found			number := -1;
  qty_found		number := 0 ;

  BEGIN
  SELECT NVL(SUM(primary_transaction_quantity),0)
  INTO qty_found
  FROM MTL_ONHAND_QUANTITIES_DETAIL
  WHERE organization_id = org_id
  AND subinventory_code = NVL(sub_code, subinventory_code)
  AND NVL(locator_id,-9999) = NVL(loc_id, NVL(locator_id,-9999)) ;

  return qty_found ;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      qty_found := 0 ;
      return qty_found ;
    WHEN OTHERS then
      qty_found := -1 ;
      return qty_found ;

  END onhand_qty ;

  Function pending_in_temp(
	org_id		number,
	sub_code	varchar2,
	loc_id		number) return number IS

  found			number := -1;
  trx_found		number := 0;

  BEGIN
  SELECT COUNT(transaction_temp_id)
  INTO trx_found
  FROM mtl_material_transactions_temp
  WHERE organization_id = org_id
  AND subinventory_code = NVL(sub_code, subinventory_code)
  AND NVL(locator_id,-9999) = NVL(loc_id, NVL(locator_id,-9999)) ;

  return trx_found ;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      trx_found := 0 ;
      return trx_found ;
    WHEN OTHERS then
      trx_found := -1 ;
      return trx_found ;
  trx_found := NVL(trx_found, 0);

  END pending_in_temp ;



  Function pending_in_interface(
	org_id		number,
	sub_code	varchar2,
	loc_id		number) return number IS

  found			number := -1;
  trx_found		number := 0;

  BEGIN
  SELECT COUNT(transaction_interface_id)
  INTO trx_found
  FROM mtl_transactions_interface
  WHERE organization_id = org_id
  AND subinventory_code = NVL(sub_code, subinventory_code)
  AND NVL(locator_id,-9999) = NVL(loc_id, NVL(locator_id,-9999)) ;

  return trx_found ;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      trx_found := 0 ;
      return trx_found ;
    WHEN OTHERS then
      trx_found := -1 ;
      return trx_found ;


  END pending_in_interface ;


Procedure onhand_pending_trx(
	org_id				IN	number,
	sub_code			IN	varchar2,
	locator_id			IN	number,
	onhand				OUT	NOCOPY boolean,
	pending_trx			OUT	NOCOPY boolean,
	success				OUT	NOCOPY boolean) IS

	qty_found		number := 0;
	pending_trx_found	number := 0;
	onhand_return	number;
	pending_in_temp_return  number;
	pending_in_interface_return  number ;



BEGIN
  success := TRUE;

   onhand_return := onhand_qty(org_id,sub_code,locator_id) ;
  if ( onhand_return = 0 ) then
    pending_in_temp_return := pending_in_temp(org_id,sub_code,locator_id) ;
    if ( pending_in_temp_return = 0 ) then
      pending_in_interface_return := pending_in_interface(org_id,sub_code,locator_id) ;
      if ( pending_in_interface_return = 0 ) then
        onhand := FALSE;
	pending_trx := FALSE;
      else
	onhand := TRUE ;
	pending_trx := TRUE ;
      end if;
    else
      onhand := TRUE ;
      pending_trx := TRUE ;
    end if;
  else
    onhand := TRUE ;
    pending_trx := TRUE ;
  end if;
  if ( (onhand_return < 0 ) OR (pending_in_temp_return < 0 ) OR
	( pending_in_interface_return < 0 ) ) then
    success := FALSE;
  end if;

END onhand_pending_trx;


Procedure populate_project_info(
	FM_ORG_ID	IN	NUMBER,
	TO_ORG_ID	IN	NUMBER,
	FM_SUB		IN	VARCHAR2,
	TO_SUB		IN	VARCHAR2,
	FM_LOCATOR	IN	NUMBER,
	TO_LOCATOR	IN	NUMBER,
	F_PROJECT_ID	IN OUT	NOCOPY NUMBER,
	F_TASK_ID	IN OUT	NOCOPY NUMBER,
	T_PROJECT_ID	IN OUT	NOCOPY NUMBER,
	T_TASK_ID	IN OUT 	NOCOPY NUMBER,
	ERROR_CODE	OUT	NOCOPY VARCHAR2,
	ERROR_EXPL	OUT	NOCOPY VARCHAR2,
	SRC_TYPE_ID	IN	NUMBER,
	ACTION_ID	IN	NUMBER ,
        SOURCE_ID       IN      NUMBER) IS
/*
   Added source_id parameter to get the project and task of the source.
   Currently the source_id field is used for passing the  req_line_id.
   This parameter could be used in future for other sources.  For internal
   order intransit shipment and internal req intransit receipt the source
   id is the req_line_id. The project and task is selected from po_requisition_lines
   table.
*/
	prj_ref_enabled number ;
	prj_cntrl_level number;
	to_org_prj_ref_enabled number;
	to_org_prj_cntrl_level number;
	translated_mesg	varchar2(2000) := null;
	v_buffer	varchar2(241) := null;
	x_return_status Varchar2(1);
BEGIN

  error_code := null;
  error_expl := null;
  if ( (fm_org_id IS NULL ) OR (src_type_id IS NULL)
	OR (action_id IS NULL ) ) then
    fnd_message.set_name('INV','INV_DATA_ERROR');
    fnd_message.set_token('ENTITY', 'populate_project_info');
    translated_mesg := fnd_message.get ;
    error_code := '';
    error_expl := substr(translated_mesg,1,240) ;
    return ;
  end if;

  SELECT NVL(project_reference_enabled,2), NVL(project_control_level,1)
  INTO prj_ref_enabled, prj_cntrl_level
  FROM mtl_parameters
  WHERE organization_id = fm_org_id ;
  /* We are going to get task ids no matter what the control level is
     But are keeping reference for control level in case later we decide to
     filter on this. So now, setting cntrl_level = 2 (task level)
  */
  prj_cntrl_level := 2 ;
  if ( prj_ref_enabled = 2 ) then
    if ( (action_id IN (3,21,12) )) then
      goto handle_interorg ;
    else
      return ;
    end if;
  end if;

  if ( f_project_id IS NULL and fm_locator is not NULL) then
    SELECT project_id
    INTO f_project_id
    FROM mtl_item_locations
    WHERE inventory_location_id = fm_locator
    AND organization_id = fm_org_id ;
  end if;

  if ( f_task_id IS NULL AND f_project_id IS NOT NULL) then
    if ( prj_cntrl_level = 2 AND prj_ref_enabled = 1 ) then
      if ( fm_locator IS NOT NULL ) then
        SELECT task_id
        INTO f_task_id
        FROM mtl_item_locations
        WHERE NVL(project_id,-999) = NVL(f_project_id, -111)
        AND inventory_location_id = fm_locator
        AND organization_id = fm_org_id ;

      end if;
    end if;
  end if;

if ( action_id in (2,28) ) then

  if ( t_project_id IS NULL ) then
    if ( to_locator IS NOT NULL ) then
      SELECT project_id
      INTO t_project_id
      FROM mtl_item_locations
      WHERE inventory_location_id = to_locator
      AND organization_id = fm_org_id ;
    end if;
  end if;

  if ( t_task_id IS NULL  AND t_project_id IS NOT NULL) then
    if ( to_locator IS NOT NULL ) then
      SELECT task_id
      INTO t_task_id
      FROM mtl_item_locations
      WHERE inventory_location_id = to_locator
      AND organization_id = fm_org_id ;
    end if;

  end if;

end if;

<<handle_interorg>>
if ( (action_id = 3) OR (action_id = 21) OR (action_id = 12) ) then
  if ( to_org_id IS NULL ) then
    return;
  end if;

  SELECT NVL(project_reference_enabled,2), NVL(project_control_level,1)
  INTO to_org_prj_ref_enabled, to_org_prj_cntrl_level
  FROM mtl_parameters
  WHERE organization_id = to_org_id ;

  /* We are going to get task ids no matter what the control level is
     But are keeping reference for control level in case later we decide to
     filter on this. So now, setting cntrl_level = 2 (task level)
  */

  to_org_prj_cntrl_level := 2 ;
  if ( to_org_prj_ref_enabled = 2 ) then
    return;
  end if;
  If (action_id in (12,21) and source_id is not null) Then
     If (src_type_id = 8 ) Then /* Intransit Shipment */
         Get_project_info_from_Req(
                      x_return_status,
                      t_project_id,
                      t_task_id,
                      Source_Id);
     Else 			/* for Intransit Receipt */
         Get_project_info_for_RcvTrx(
                      x_return_status,
                      t_project_id,
                      t_task_id,
                      Source_Id);

     End If;
     If X_return_status <> FND_API.G_RET_STS_SUCCESS
     Then
	translated_mesg := fnd_message.get ;
    	error_code := '';
    	error_expl := substr(translated_mesg,1,240) ;
     End If;
     Return;
  End If;

  if ( t_project_id IS NULL ) then
    if ( to_locator IS NOT NULL ) then

      /* For an inventory intransit shipment,any locator entered on the form as
         to_locator is not picked up by receiving as a default unless the transaction
         default is set for that locator.
         The same behaviour is true for project related locators and additionally
         one cannot receive into a project related locator as well.
         As MTL_SUPPLY does not support locators, the inventory moves from project
         cost group to common and after receiving from common to common.*/

      If (action_id = 21 and src_type_id = 13) Then
         null;
      Else
         SELECT project_id
         INTO t_project_id
         FROM mtl_item_locations
         WHERE inventory_location_id = to_locator
         AND organization_id = to_org_id ;
      End If;
    end if;
  end if;

  if ( t_task_id IS NULL  AND t_project_id IS NOT NULL) then
    if ( to_locator IS NOT NULL ) then
      SELECT task_id
      INTO t_task_id
      FROM mtl_item_locations
      WHERE inventory_location_id = to_locator
      AND organization_id = to_org_id ;
    end if;

  end if;

end if;

EXCEPTION
  WHEN OTHERS then

    fnd_message.set_name('INV','INV_UNHANDLED_ERR');
    fnd_message.set_token('ENTITY1', 'populate_project_info');
    v_buffer := to_char(SQLCODE) || ' '|| substr(SQLERRM,1,150);
    fnd_message.set_token('ENTITY2', v_buffer);
    translated_mesg := fnd_message.get ;
    translated_mesg := substr(translated_mesg,1,230) ;
    error_expl  := translated_mesg ;

END populate_project_info;


Procedure call_cust_val(
	 V_item_id			IN	number
	,V_revision			IN	varchar2
	,V_org_id			IN	number
	,V_sub_code			IN	varchar2
	,V_locator_id			IN	number
	,V_xfr_org_id			IN	number
	,V_xfr_sub_code			IN	varchar2
	,V_xfr_locator_id		IN	number
	,V_quantity			IN	number
	,V_txn_type_id			IN	number
	,V_txn_action_id		IN	number
	,V_txn_source_type_id		IN	number
	,V_txn_source_id		IN	number
	,V_txn_source_name		IN	varchar2
	,V_project_id			IN 	number
	,V_task_id			IN OUT	NOCOPY number
	,V_source_project_id		IN 	number
	,V_source_task_id		IN OUT	NOCOPY number
	,V_to_project_id		IN 	number
	,V_to_task_id			IN OUT	NOCOPY number
	,V_txn_date			IN	date
	,V_pa_expenditure_org_id 	IN	number
	,V_expenditure_type		IN	varchar2
	,V_calling_module		IN	varchar2
	,V_user_id			IN	number
	,V_error_mesg			OUT	NOCOPY varchar2
	,V_warning_mesg			OUT	NOCOPY varchar2
	,V_success_flag			OUT	NOCOPY number
	,V_attribute_category		IN	varchar2
	,V_attribute1			IN	varchar2
	,V_attribute2			IN	varchar2
	,V_attribute3			IN	varchar2
	,V_attribute4			IN	varchar2
	,V_attribute5			IN	varchar2
	,V_attribute6			IN	varchar2
	,V_attribute7			IN	varchar2
	,V_attribute8			IN	varchar2
	,V_attribute9			IN	varchar2
	,V_attribute10			IN	varchar2
	,V_attribute11			IN	varchar2
	,V_attribute12			IN	varchar2
	,V_attribute13			IN	varchar2
	,V_attribute14			IN	varchar2
	,V_attribute15			IN	varchar2
        )
IS
	x_fm_org_project_control_level	number ;
	x_to_org_project_control_level	number;
	original_task_id		number;
	original_source_task_id		number;
	original_to_task_id		number;
	translated_mesg			varchar2(2000) := null;
Begin

v_error_mesg := null;
v_warning_mesg := null;

original_task_id := v_task_id ;
original_source_task_id := v_source_task_id ;
original_to_task_id := v_to_task_id ;
if ( v_org_id IS NULL ) then
  fnd_message.set_name('INV','INV_DATA_ERROR');
  fnd_message.set_token('ENTITY', 'call_customer_validation');
  translated_mesg :=  fnd_message.get ;
  v_error_mesg := substr(translated_mesg,1,240) ;
  v_success_flag := -1 ;
  return ;
end if;
if ( (v_txn_action_id = 3) AND v_xfr_org_id IS NULL ) then
  fnd_message.set_name('INV','INV_DATA_ERROR');
  fnd_message.set_token('ENTITY', 'call_customer_validation');
  translated_mesg :=  fnd_message.get ;
  v_error_mesg := substr(translated_mesg,1,240) ;
  v_success_flag := -1 ;
  return ;
end if;

SELECT NVL(project_control_level,1)
INTO x_fm_org_project_control_level
FROM mtl_parameters
WHERE organization_id = v_org_id ;

if ( v_txn_action_id = 3 ) then
  SELECT NVL(project_control_level,1)
  INTO x_to_org_project_control_level
  FROM mtl_parameters
  WHERE organization_id = v_xfr_org_id ;
end if;

/*
 now call customers validation package
*/

inv_prj_cust_val.validate(
	 V_item_id
	,V_revision
	,V_org_id
	,V_sub_code
	,V_locator_id
	,V_xfr_org_id
	,V_xfr_sub_code
	,V_xfr_locator_id
	,V_quantity
	,V_txn_type_id
	,V_txn_action_id
	,V_txn_source_type_id
	,V_txn_source_id
	,V_txn_source_name
	,V_project_id
	,V_task_id
	,V_source_project_id
	,V_source_task_id
	,V_to_project_id
	,V_to_task_id
	,V_txn_date
	,V_pa_expenditure_org_id
	,V_expenditure_type
	,V_calling_module
	,V_user_id
	,V_error_mesg
	,V_warning_mesg
	,V_success_flag
	,V_attribute_category
	,V_attribute1
	,V_attribute2
	,V_attribute3
	,V_attribute4
	,V_attribute5
	,V_attribute6
	,V_attribute7
	,V_attribute8
	,V_attribute9
	,V_attribute10
	,V_attribute11
	,V_attribute12
	,V_attribute13
	,V_attribute14
	,V_attribute15 );

/*
 Overwrite returned task info if project control level was project,
 otherwise, use task id info sent back by customer
*/

if ( x_fm_org_project_control_level = 2 ) then
  v_source_task_id := original_source_task_id ;
  v_task_id := original_task_id ;
end if;

if ( x_to_org_project_control_level = 1 ) then
  v_to_task_id := original_to_task_id ;
end if;

end call_cust_val ;

Procedure update_project_task(v_org_id	       number,
                              v_in_project_id  number,
                              v_in_task_id     number,
                              v_out_project_id in out NOCOPY number,
                              v_out_task_id    in out NOCOPY number) is
  v_project_reference_enabled  number;
  v_pm_cost_collection_enabled number;
  v_project_control_level      number;
  v_success                    boolean;
begin
  INV_PROJECT.org_project_parameters(v_org_id,
                         v_project_reference_enabled,
                         v_pm_cost_collection_enabled,
                         v_project_control_level,
                         v_success);
  if v_success and v_project_reference_enabled = 1
  then
    if v_in_project_id is not null
    then
     v_out_project_id := v_in_project_id;
     if v_in_task_id is not null
     then
        v_out_task_id := v_in_task_id;
     end if;
    end if;
  end if;
end update_project_task;
Procedure update_project_task_number(v_org_id	       number,
                                     v_in_project_id   number,
                                     v_in_task_id      number,
                                     v_out_project_id  in out NOCOPY number,
                                     v_out_task_id     in out NOCOPY number,
                                     v_out_project     in out NOCOPY varchar2,
                                     v_out_task        in out NOCOPY varchar2) is
  v_project_reference_enabled  number;
  v_pm_cost_collection_enabled number;
  v_project_control_level      number;
  v_success                    boolean;
begin
  INV_PROJECT.org_project_parameters(v_org_id,
                         v_project_reference_enabled,
                         v_pm_cost_collection_enabled,
                         v_project_control_level,
                         v_success);
  if v_success and v_project_reference_enabled = 1
  then
    if v_in_project_id is not null
    then
     v_out_project_id := v_in_project_id;
     begin

         -- bug 4662395 set the profile mfg_organization_id so
         -- the call to MTL_PROJECT_V will return data.

         FND_PROFILE.put('MFG_ORGANIZATION_ID',v_org_id);

         select project_number
         into v_out_project
         from mtl_project_v
         where project_id = v_in_project_id;
     exception
     when others
     then null;
     end;
     if v_in_task_id is not null
     then
        v_out_task_id := v_in_task_id;
        begin
         select task_number
         into v_out_task
         from mtl_task_v
         where project_id = v_in_project_id
         and   task_id = v_in_task_id;
        exception
        when others
        then null;
        end;
     end if;
    end if;
  end if;
end update_project_task_number;

/*
The Get_project_info_from_Req procedure is called in procedures
  Get_project_loc_for_prj_Req and
  populate_project_info procedure.

This procedure provides the project and task from
po_req_distributions_all via po_requisition_lines_all table
for the requisition_line_id in the
mtl_material_transactions_temp or the
transaction interface table.
*/
Procedure Get_project_info_from_Req(
        x_Return_Status         Out NOCOPY Varchar2,
        x_Project_Id            Out NOCOPY Number,
        x_Task_Id               Out NOCOPY Number,
        P_Req_Line_Id   	In  Number) IS

l_req_project_id        Number;
l_req_task_id           Number;

Begin
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        SELECT project_id,task_id
        INTO   l_req_project_id,l_req_task_id
        FROM   po_req_distributions_all
        WHERE  requisition_line_id = p_req_line_id;

       x_project_id := l_req_project_id;
       x_task_id    := l_req_task_id;

Exception
When Others Then

        X_return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Build_Exc_Msg(
                p_pkg_name       =>'Inv_Project',
                p_procedure_name => 'Get_project_info_from_Req');

End Get_project_info_from_Req;

/*
The Get_project_info_for_RcvTrx procedure is called in procedures
  populate_project_info procedure.

This procedure gets the project and task from po_req_distributions_all
via rcv_transactions table for the rcv_transaction_id in the
mtl_material_transactions_temp.
*/
Procedure Get_project_info_for_RcvTrx(
        x_Return_Status         Out NOCOPY Varchar2,
        x_Project_Id            Out NOCOPY Number,
        x_Task_Id               Out NOCOPY Number,
        P_Rcv_Trx_Id   		In  Number) IS

l_req_project_id        Number;
l_req_task_id           Number;

Begin
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        SELECT prd.project_id, prd.task_id
        INTO   l_req_project_id,l_req_task_id
        FROM   po_req_distributions_all prd,
               rcv_transactions rcv
        WHERE  rcv.transaction_id = P_Rcv_Trx_Id
        And    prd.requisition_line_id = rcv.requisition_line_id;

       x_project_id := l_req_project_id;
       x_task_id    := l_req_task_id;

Exception
When Others Then

        X_return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Build_Exc_Msg(
                p_pkg_name       =>'Inv_Project',
                p_procedure_name => 'Get_project_info_for_RcvTrx');

End Get_project_info_for_RcvTrx;

/*
/*
  Procedure Get_project_loc_for_prj_Req appends the project and task to the
  locator that is provided as input. This procedure takes care of creating a new
  locator if all control levels are met. This procedure is called by inltev.ppc
*/
Procedure Get_project_loc_for_prj_Req(
        X_Return_Status         Out     NOCOPY Varchar2,
        X_locator_Id            In Out  NOCOPY Number,
        P_organization_id       In      Number,
        P_Req_Line_Id   	In      Number) IS

l_req_project_id        Number;
l_req_task_id           Number;
l_Project_locator_id    Number;
l_return_status         Varchar2(1);

Begin
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        If P_Req_Line_Id is null Then
                Return;
        Else
                Get_project_info_from_Req(
                        l_return_status,
                        l_req_project_id,
                        l_req_task_id,
                        P_Req_Line_Id);
                If l_return_status <> FND_API.G_RET_STS_SUCCESS
                Then
                        Return;
                End If;
                If l_req_project_id is null
                Then
                        return;
                Else
                        PJM_PROJECT_LOCATOR.Get_DefaultProjectLocator
                                (P_Organization_Id,
                                 X_locator_Id,
                                 l_req_project_id,
                                 l_req_task_id,
                                 l_project_locator_Id);
                        X_locator_Id := l_project_locator_Id;
                End If;
        End If;

Exception
When Others Then

        X_return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Build_Exc_Msg(
                p_pkg_name       =>'Inv_Project',
                p_procedure_name => 'Get_project_loc_for_prj_Req');

End Get_project_loc_for_prj_Req;

Procedure Set_Org_client_info(X_return_Status   Out NOCOPY Varchar2,
                              P_Organization_Id In Number) Is

l_Org_Id          Number;
l_conreq_id       number :=0;   --bugfix 4643461

Begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 l_conreq_id := fnd_global.conc_request_id;

  IF nvl(g_organization_id,-999) <> nvl(P_Organization_Id,-999) THEN

     -- bugfix 4643461 cache the org_id for pickrelease and TM only. which has concurrent req id not null.
     -- Bug 5304874 Added INV_CACHE.is_pickrelease so that caching happens for pick release online cases also
     if (l_conreq_id > 0 OR INV_CACHE.is_pickrelease) then

	g_organization_id := P_Organization_Id;

    end if;

    --Commenting the Check Install for PJM, bug 3812559.
    /*IF PJM_INSTALL.CHECK_INSTALL
     THEN*/
        SELECT operating_unit
        INTO   l_org_id
        FROM org_organization_definitions
        WHERE organization_id = P_Organization_Id;

        if l_org_id is not null
        then

              -- MOAC replace fnd_client_info.set_org_context
              -- with MO_GLOBAL.init
              MO_GLOBAL.init('INV');
              -- fnd_client_info.set_org_context(to_char(l_org_id));
        end if;

        -- bugfix 4643461 added debug message
        if ( nvl(fnd_profile.value('INV_DEBUG_TRACE'), 0) = 1 ) then
            inv_log_util.trace('set client context : '||l_org_id, 'INV_PROJECT', 9);
            inv_log_util.trace('g_organization_id : '||g_organization_id, 'INV_PROJECT', 9);
        end if;


     /*END IF;*/
  END IF;

EXCEPTION
WHEN OTHERS THEN

        X_return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Build_Exc_Msg(
                p_pkg_name       =>'Inv_Project',
                p_procedure_name => 'Set_Org_client_info');

END Set_Org_client_info;


PROCEDURE SET_SESSION_PARAMETERS(
                                 X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
                                 X_MSG_COUNT       OUT NOCOPY NUMBER,
                                 X_MSG_DATA        OUT NOCOPY VARCHAR2,
                                 P_ORGANIZATION_ID IN  NUMBER
                                ) IS

   L_OPERATING_UNIT VARCHAR2(30);

BEGIN

   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

   FND_PROFILE.PUT('MFG_ORGANIZATION_ID', TO_CHAR(P_ORGANIZATION_ID));

   FND_PROFILE.GET('ORG_ID', L_OPERATING_UNIT);

   -- MOAC replace fnd_client_info.set_org_context
   -- with MO_GLOBAL.init
   MO_GLOBAL.init('INV');
   -- FND_CLIENT_INFO.SET_ORG_CONTEXT(L_OPERATING_UNIT);

   FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN OTHERS THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'SET_SESSION_PARAMETERS');
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

END SET_SESSION_PARAMETERS;

Procedure get_proj_task_from_lpn(
        p_organization_Id       IN  NUMBER,
        p_lpn_id                IN  NUMBER,
        x_project_id            OUT NOCOPY NUMBER,
        x_task_id               OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2)
IS
  l_project_id NUMBER := NULL;
  l_task_id NUMBER    := NULL;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT mil.segment19, mil.segment20
  INTO   l_project_id, l_task_id
  FROM   mtl_item_locations mil, wms_license_plate_numbers wlpn
  WHERE  wlpn.lpn_id = p_lpn_id
  AND    wlpn.organization_id = p_organization_id
  AND    wlpn.organization_id = mil.organization_id
  AND    wlpn.locator_id     = mil.inventory_location_id;

  x_project_id := l_project_id;
  x_task_id    := l_task_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    BEGIN
         select DISTINCT project_id, task_id
         INTO   l_project_id, l_task_id
         FROM   mtl_txn_request_lines
         WHERE  organization_id = p_organization_id
         AND    lpn_id          = p_lpn_id;

         x_project_id := l_project_id;
         x_task_id    := l_task_id;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
              x_project_id := NULL;
              x_task_id    := NULL;
         WHEN TOO_MANY_ROWS THEN
              x_project_id := NULL;
              x_task_id    := NULL;
         WHEN OTHERS THEN
              x_project_id := NULL;
              x_task_id    := NULL;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
                 (p_encoded               =>      FND_API.G_FALSE,
                  p_count                 =>      x_msg_count,
                  p_data                  =>      x_msg_data);
    END;

  WHEN FND_API.G_EXC_ERROR THEN
         x_project_id := NULL;
         x_task_id    := NULL;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
            (p_encoded               =>      FND_API.G_FALSE,
             p_count                 =>      x_msg_count,
             p_data                  =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_project_id := NULL;
         x_task_id    := NULL;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get
            (p_encoded               =>      FND_API.G_FALSE,
             p_count                 =>      x_msg_count,
             p_data                  =>      x_msg_data);
  WHEN OTHERS THEN
         x_project_id := NULL;
         x_task_id    := NULL;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
            (p_encoded               =>      FND_API.G_FALSE,
             p_count                 =>      x_msg_count,
             p_data                  =>      x_msg_data);
END get_proj_task_from_lpn;



Function Is_Project_Enabled(
        p_org_id                IN  NUMBER
        ) return varchar2
IS

l_project_reference_enabled  number;
success                      varchar2(6);

BEGIN
success := 'TRUE';
  SELECT NVL(project_reference_enabled,2)
  INTO   l_project_reference_enabled
  FROM   mtl_parameters
  WHERE  organization_id = p_org_id ;

  IF l_project_reference_enabled <> 1 THEN
    success := 'FALSE';
  END IF;

  RETURN success;

  EXCEPTION
    WHEN OTHERS then
      success := 'FALSE' ;
      RETURN success;

END Is_Project_Enabled ;

-- Procedure to clear global variables for locator, project and task
PROCEDURE CLEAR_GLOBAL_VARS IS
BEGIN
  G_PHYSICAL_LOCATOR := NULL;
  G_PROJECT_NUMBER := NULL;
  G_PROJECT_ID := NULL;
  G_TASK_NUMBER := NULL;
  G_TASK_ID := NULL;
END CLEAR_GLOBAL_VARS;

/* Procedure to obtain the Locator Metadata.
 * Processing Logic: Get all the segments (except 19 and 20) and
 * their corresponding validation types. If the validation type
 * of all the esgments is 'N' then form a string comprising
 * concatenated segments with the delimiter
 * (eg. SEGMENT1||'.'||SEGMENT2||'.'||SEGMENT3
 * If any of the segments has a validation type other than N'
 * form the display string as ALL\index of SEGMENT19\index of SEGMENT20
 */
PROCEDURE GET_LOCATOR_METADATA(
                               X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                               X_MSG_COUNT      OUT NOCOPY NUMBER,
                               X_MSG_DATA       OUT NOCOPY VARCHAR2,
                               X_DISPLAY        OUT NOCOPY VARCHAR2,
                               X_CONCATENATED   OUT NOCOPY VARCHAR2,
                               X_PROJECT_COLUMN OUT NOCOPY NUMBER,
                               X_TASK_COLUMN    OUT NOCOPY NUMBER
                              )  IS

   CURSOR CUR_SEG IS
   SELECT APPLICATION_COLUMN_NAME,
          ffs.FLEX_VALUE_SET_ID,
          ffv.VALIDATION_TYPE
   FROM   FND_ID_FLEX_SEGMENTS ffs,
          FND_FLEX_VALUE_SETS ffv
   WHERE  APPLICATION_ID = 401 -- 'INV'
   AND    ID_FLEX_CODE = 'MTLL'
   AND    ID_FLEX_NUM  = 101 -- 'STOCK_LOCATORS'
   AND    ENABLED_FLAG = 'Y'
   AND    DISPLAY_FLAG = 'Y'
   AND    ffv.FLEX_VALUE_SET_ID(+) = ffs.FLEX_VALUE_SET_ID
   ORDER BY SEGMENT_NUM;

   L_RETURN  VARCHAR2(90);
   L_ROWNUM  NUMBER := 0;
   L_COLNAME VARCHAR2(15);
   L_VALUE_SET_ID NUMBER;
   L_VALIDATION_TYPE VARCHAR2(1);
   L_CONCAT VARCHAR2(1000);
   L_DELIM VARCHAR2(1);
   L_FIRST_TIME BOOLEAN := TRUE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   OPEN CUR_SEG;
   LOOP
      FETCH CUR_SEG INTO L_COLNAME, L_VALUE_SET_ID, L_VALIDATION_TYPE;
      EXIT WHEN CUR_SEG%NOTFOUND;
      L_ROWNUM := L_ROWNUM + 1;
      IF (L_COLNAME = 'SEGMENT19') OR (L_COLNAME = 'SEGMENT20') THEN
         L_RETURN := L_RETURN ||'\0'||TO_CHAR(L_ROWNUM);
         IF (L_COLNAME = 'SEGMENT19') THEN
            X_PROJECT_COLUMN := L_ROWNUM;
         ELSE
            X_TASK_COLUMN := L_ROWNUM;
         END IF;
      ELSE
        --Get the delimter if it is the first non-project and non-task segment
        IF (L_FIRST_TIME) THEN
          IF (L_VALIDATION_TYPE = 'N') OR (L_VALIDATION_TYPE IS NULL) THEN

            SELECT CONCATENATED_SEGMENT_DELIMITER
            INTO L_DELIM
            FROM FND_ID_FLEX_STRUCTURES
            WHERE ID_FLEX_CODE = 'MTLL' AND ROWNUM =1;

            L_CONCAT := L_COLNAME;
          ELSE
            L_CONCAT := NULL;
          END IF;
          L_FIRST_TIME := FALSE;
        --From the 2nd segement onwards, check if l_concat is not null and the validation
        --type for the current segment is 'N' or there is none. If so then append the
        --delimiter and segment name to the concatenated segments string
        ELSE
          IF (L_VALIDATION_TYPE = 'N' OR L_VALIDATION_TYPE IS NULL)
              AND (L_CONCAT IS NOT NULL) THEN
            L_CONCAT := L_CONCAT || '||' || '''' || L_DELIM || '''' || '||' || L_COLNAME;
          ELSE
            L_CONCAT := NULL;
          END IF;  --END IF l_validation_type IS N
        END IF;  --END IF L_FIRST_TIME
      END IF;  --END IF COL_NAME is SEGMENT19 or SEGMENT20
   END LOOP;
   CLOSE CUR_SEG;

   X_DISPLAY := 'ALL'||L_RETURN;
   X_CONCATENATED := L_CONCAT;

   FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );
   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN OTHERS THEN

      IF (l_debug = 1) THEN
         MYDEBUG('EXCEPTION RAISED IN GET_LOCATOR_METADATA '||SQLERRM);
      END IF;

      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'GET_LOCATOR_METADATA');
      END IF;
      FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

END GET_LOCATOR_METADATA;

/* Function to get the position of PROJECT column (SEGMENT19) */
FUNCTION GET_PROJECT_COLUMN RETURN VARCHAR2 IS
   X_RETURN_STATUS VARCHAR2(1);
   X_MSG_DATA      VARCHAR2(1000);
   X_MSG_COUNT     NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      MYDEBUG('GET_PROJECT_COLUMN: G_DISPLAYED_SEGMENTS: '||G_DISPLAYED_SEGMENTS);
   END IF;
   IF G_DISPLAYED_SEGMENTS IS NULL THEN
     GET_LOCATOR_METADATA( X_RETURN_STATUS  => X_RETURN_STATUS,
                           X_MSG_COUNT      => X_MSG_COUNT,
                           X_MSG_DATA       => X_MSG_DATA,
                           X_DISPLAY        => G_DISPLAYED_SEGMENTS,
                           X_CONCATENATED   => G_CONCATENATED_SEGMENTS,
                           X_PROJECT_COLUMN => G_PROJECT_COLUMN,
                           X_TASK_COLUMN    => G_TASK_COLUMN);

     IF (l_debug = 1) THEN
        MYDEBUG('GET_PROJECT_COLUMN: GET_LOCATOR_METADATA: '||X_RETURN_STATUS);
     END IF;
   END IF;
   IF (l_debug = 1) THEN
      MYDEBUG('GET_PROJECT_COLUMN: RETURNS: '||G_PROJECT_COLUMN);
   END IF;
   RETURN G_PROJECT_COLUMN;
END;

/* Function to get the position of TASK column (SEGMENT20) */
FUNCTION GET_TASK_COLUMN RETURN VARCHAR2 IS
   X_RETURN_STATUS VARCHAR2(1);
   X_MSG_DATA      VARCHAR2(1000);
   X_MSG_COUNT     NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      MYDEBUG('GET_TASK_COLUMN: G_DISPLAYED_SEGMENTS: '||G_DISPLAYED_SEGMENTS);
   END IF;
   IF G_DISPLAYED_SEGMENTS IS NULL THEN
     GET_LOCATOR_METADATA( X_RETURN_STATUS  => X_RETURN_STATUS,
                           X_MSG_COUNT      => X_MSG_COUNT,
                           X_MSG_DATA       => X_MSG_DATA,
                           X_DISPLAY        => G_DISPLAYED_SEGMENTS,
                           X_CONCATENATED   => G_CONCATENATED_SEGMENTS,
                           X_PROJECT_COLUMN => G_PROJECT_COLUMN,
                           X_TASK_COLUMN    => G_TASK_COLUMN);
     IF (l_debug = 1) THEN
        MYDEBUG('GET_TASK_COLUMN: GET_LOCATOR_METADATA: '||X_RETURN_STATUS);
     END IF;
   END IF;
   IF (l_debug = 1) THEN
      MYDEBUG('GET_TASK_COLUMN: RETURNS: '||G_TASK_COLUMN);
   END IF;
   RETURN G_TASK_COLUMN;
END;

/* Function to fetch Physical Locator segments, project and task given locator and org
 * Processing Logic: Check if G_CONCATENATED_SEGMENTS is populated.
 * If yes then
 *   Query MTL_ITEM_LOCATIONS to fetch concatenated physical locator segments, project Id
 *   and Task Id for the passed locator Id/Org Id. Call get_project_number and get_task_number
 *   to get Project Number and Task Number.
 * else
 *   Use FND_FLEX_KEYVAL to fetch the Concatenated segment values, Project Id, Task Id,
 *   Project Number and Task Number for the passed LocatorId/OrgId combination.
 *   FND_FLEX_KEYVAL.CONCATENATED_SEGMENTS -- Concatenated display values
 *   FND_FLEX_KEYVAL.SEGMENT_VALUES -- Table of Segment Values
 * The fetched values are stored in Package variables,
 */
PROCEDURE FETCH_COMBINATION(P_LOCATOR_ID IN NUMBER,
                            P_ORG_ID IN NUMBER) IS
  L_CC_ID_RET  BOOLEAN;
  TYPE CUR_LOC IS REF CURSOR;
  c_locator CUR_LOC;
  l_loc_str VARCHAR2(1000);
  l_physical_locator VARCHAR2(1000);
  l_project_id NUMBER;
  l_task_id NUMBER;
  X_RETURN_STATUS VARCHAR2(1);
  X_MSG_DATA      VARCHAR2(1000);
  X_MSG_COUNT     NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF (l_debug = 1) THEN
     MYDEBUG('FETCH_COMBINATION: P_LOCATOR_ID: P_ORG_ID: '||P_LOCATOR_ID||' : '||P_ORG_ID);
  END IF;

  IF G_DISPLAYED_SEGMENTS IS NULL THEN
     GET_LOCATOR_METADATA( X_RETURN_STATUS  => X_RETURN_STATUS,
                           X_MSG_COUNT      => X_MSG_COUNT,
                           X_MSG_DATA       => X_MSG_DATA,
                           X_DISPLAY        => G_DISPLAYED_SEGMENTS,
                           X_CONCATENATED   => G_CONCATENATED_SEGMENTS,
                           X_PROJECT_COLUMN => G_PROJECT_COLUMN,
                           X_TASK_COLUMN    => G_TASK_COLUMN);
     IF (l_debug = 1) THEN
        MYDEBUG('FETCH_COMBINATION: GET_LOCATOR_METADATA: '||X_RETURN_STATUS);
     END IF;
   END IF;

   IF G_CONCATENATED_SEGMENTS IS NOT NULL THEN

     IF (l_debug = 1) THEN
        MYDEBUG('Using MTL_ITEM_LOCATIONS to get locator, project and task info');
     END IF;
     --Build the string to fetch locator id, project Id and
     --task Id from MTL_ITEM_LOCATIONS
     l_loc_str := 'SELECT ' || G_CONCATENATED_SEGMENTS || ', ';
     l_loc_str := l_loc_str || 'PROJECT_ID, TASK_ID FROM MTL_ITEM_LOCATIONS ';
     l_loc_str := l_loc_str || 'WHERE INVENTORY_LOCATION_ID = :1 AND ORGANIZATION_ID = :2';

     IF (l_debug = 1) THEN
        MYDEBUG('l_loc_str:' || l_loc_str);
     END IF;

     --Open the cursor and store the results in session variables
     OPEN c_locator FOR l_loc_str USING P_LOCATOR_ID, P_ORG_ID;
     FETCH c_locator INTO l_physical_locator, l_project_id, l_task_id;

     IF l_physical_locator IS NOT NULL THEN
       G_PHYSICAL_LOCATOR := l_physical_locator;
     ELSE
       G_PHYSICAL_LOCATOR := NULL;
     END IF;

     IF l_project_id IS NOT NULL THEN
       G_PROJECT_NUMBER := GET_PROJECT_NUMBER(l_project_id);
       G_PROJECT_ID := l_project_id;
     ELSE
       G_PROJECT_NUMBER := NULL;
       G_PROJECT_ID := NULL;
     END IF;

     IF l_task_id IS NOT NULL THEN
       G_TASK_NUMBER := GET_TASK_NUMBER(l_task_id);
       G_TASK_ID := l_task_id;
     ELSE
       G_TASK_NUMBER := NULL;
       G_TASK_ID := NULL;
     END IF;
     CLOSE c_locator;

    --If any of the segments has a validation type other than 'N'
    ELSE
     IF (l_debug = 1) THEN
        MYDEBUG('Using FND APIs to get locator, project and task info');
     END IF;
     L_CC_ID_RET := FND_FLEX_KEYVAL.VALIDATE_CCID(
                               APPL_SHORT_NAME       => 'INV',
                               KEY_FLEX_CODE         => 'MTLL',
                               STRUCTURE_NUMBER      => 101,
                               COMBINATION_ID        => P_LOCATOR_ID,
                               DISPLAYABLE           => G_DISPLAYED_SEGMENTS,
                               DATA_SET              => P_ORG_ID,
                               VRULE                 => NULL,
                               SECURITY              => 'IGNORE',
                               GET_COLUMNS           => NULL,
                               RESP_APPL_ID          => 401,
                               RESP_ID               => NULL,
                               USER_ID               => NULL,
                               SELECT_COMB_FROM_VIEW => NULL
                                                 );
     IF NOT L_CC_ID_RET THEN
       IF (l_debug = 1) THEN
          MYDEBUG('FETCH_COMBINATION: VALIDATE_CCID: CALL FAILED');
          MYDEBUG('FETCH_COMBINATION: VALIDATE_CCID: '||FND_FLEX_KEYVAL.ERROR_MESSAGE);
       END IF;
	   CLEAR_GLOBAL_VARS;
     ELSE
       G_PHYSICAL_LOCATOR := FND_FLEX_KEYVAL.CONCATENATED_VALUES;
       G_PROJECT_NUMBER := FND_FLEX_KEYVAL.SEGMENT_VALUE(GET_PROJECT_COLUMN);
       G_PROJECT_ID := FND_FLEX_KEYVAL.SEGMENT_ID(GET_PROJECT_COLUMN);
       G_TASK_NUMBER := FND_FLEX_KEYVAL.SEGMENT_VALUE(GET_TASK_COLUMN);
       G_TASK_ID := FND_FLEX_KEYVAL.SEGMENT_ID(GET_TASK_COLUMN);
     END IF;

   END IF;  --END If g_concated_segments IS NOT NULL

   IF (l_debug = 1) THEN
      MYDEBUG('LOC SEGS: ' || G_PHYSICAL_LOCATOR);
      MYDEBUG('G_PROJECT_NUMBER: ' || G_PROJECT_NUMBER);
      MYDEBUG('G_PROJECT_ID: ' || G_PROJECT_ID);
      MYDEBUG('G_TASK_NUMBER: ' || G_TASK_NUMBER);
      MYDEBUG('G_TASK_ID: ' || G_TASK_ID);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         MYDEBUG('FETCH_COMBINATION: RAISED EXCEPTION: '||SQLERRM);
      END IF;
END FETCH_COMBINATION;

/* Function to get the concatenated Locator Segments (except project and task)
 * given Locator Id and Organization Id
 */
FUNCTION GET_LOCSEGS(P_LOCATOR_ID IN NUMBER,
                     P_ORG_ID IN NUMBER) RETURN VARCHAR2 IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1) THEN
     MYDEBUG('GET_LOCSEGS: P_LOCATOR_ID: P_ORG_ID: '||P_LOCATOR_ID||':'||P_ORG_ID);
  END IF;

  /* If locator Id passed is not null then fetch the locator, project and
   * and task values. Else clear the session variables
  */
  IF P_LOCATOR_ID IS NOT NULL THEN
    FETCH_COMBINATION(P_LOCATOR_ID => P_LOCATOR_ID,
                      P_ORG_ID     => P_ORG_ID);
  ELSE
IF (l_debug = 1) THEN
   mydebug('loc id is null');
END IF;
    CLEAR_GLOBAL_VARS;
  END IF;

   RETURN G_PHYSICAL_LOCATOR;
END GET_LOCSEGS;

/*
 * This function returns the Project Number of the Project Id passed
 * Does not use FND API's.
 */
FUNCTION GET_PROJECT_NUMBER(p_project_id IN NUMBER) RETURN VARCHAR2 IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    /* The below code is commented because it uses pjm_projects_mtll_v
      which requrires mfg_organization_id profile value needs to be set
      whereas inv_projectlocator_pu.get_project_number do not require */

    -- If this code is ever uncommneted then the profile mfg_organization_id
    -- needs to be set by the calling object otherwise PJM_PROJECTS_MTLL_V
    -- will not return a value. Bug 4662395

   /*SELECT PROJECT_NUMBER
   INTO   L_PROJECT_NUMBER
   FROM   PJM_PROJECTS_MTLL_V
   WHERE  PROJECT_ID = P_PROJECT_ID;

   IF (l_debug = 1) THEN
      MYDEBUG('GET_PROJECT_NUMBER: RETURNS '||L_PROJECT_NUMBER);
   END IF;
   RETURN L_PROJECT_NUMBER;*/
   return INV_ProjectLocator_PUB.GET_PROJECT_NUMBER(p_project_id);

END GET_PROJECT_NUMBER;

FUNCTION GET_TASK_NUMBER(P_TASK_ID IN NUMBER) RETURN VARCHAR2 IS
   L_TASK_NUMBER VARCHAR2(100);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  /* SELECT TASK_NUMBER
   INTO   L_TASK_NUMBER
   FROM   PJM_TASKS_MTLL_V
   WHERE  TASK_ID = P_TASK_ID;

   IF (l_debug = 1) THEN
      MYDEBUG('GET_TASK_NUMBER: RETURNS '||L_TASK_NUMBER);
   END IF;
   RETURN L_TASK_NUMBER;*/
   return INV_ProjectLocator_PUB.GET_TASK_NUMBER(P_TASK_ID);

EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         MYDEBUG('GET_TASK_NUMBER: EXCEPTION '||SQLERRM);
      END IF;
      L_TASK_NUMBER := NULL;
      RETURN L_TASK_NUMBER;
END GET_TASK_NUMBER;


/*
 * These function are used to get the Project/Task Number of the Last Accessed
 * combination. They are for use in select statements e.g.
 *        SELECT ..
 *               ..
 *               INV_PROJECT.GET_LOCSEGS(LOCATOR_ID,ORG_ID)
 *               INV_PROJECT.GET_PROJECT_ID,
 *               INV_PROJECT.GET_PROJECT_NUMBER,
 *               INV_PROJECT.GET_TASK_ID,
 *               INV_PROJECT.GET_TASK_NUMBER,
 *               ..
 *        FROM   WMS_LICENSE_PLATE_NUMBERS
 *
 */
FUNCTION GET_PROJECT_NUMBER RETURN VARCHAR2 IS
BEGIN
  RETURN G_PROJECT_NUMBER;
END GET_PROJECT_NUMBER;

FUNCTION GET_PROJECT_ID RETURN VARCHAR2 IS
BEGIN
  RETURN G_PROJECT_ID;
END GET_PROJECT_ID;

FUNCTION GET_TASK_NUMBER RETURN VARCHAR2 IS
BEGIN
  RETURN G_TASK_NUMBER;
END GET_TASK_NUMBER;

FUNCTION GET_TASK_ID RETURN VARCHAR2 IS
BEGIN
  RETURN G_TASK_ID;
END GET_TASK_ID;

/*
 * Procedure to obtain the Locator Metadata.
 * Processing Logic: Get all the segments and
 * their corresponding validation types. If the validation type
 * of all the esgments is 'N' then form a string comprising
 * concatenated segments with the delimiter
 * (eg. SEGMENT1||'.'||SEGMENT2||'.'||SEGMENT3
 */
PROCEDURE CONC_LOC_QRY(
                               X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                               X_MSG_COUNT      OUT NOCOPY NUMBER,
                               X_MSG_DATA       OUT NOCOPY VARCHAR2,
                               X_CONCATENATED   OUT NOCOPY VARCHAR2
                          )  IS

   CURSOR CUR_SEG IS
   SELECT APPLICATION_COLUMN_NAME,
          ffs.FLEX_VALUE_SET_ID,
          ffv.VALIDATION_TYPE
   FROM   FND_ID_FLEX_SEGMENTS ffs,
          FND_FLEX_VALUE_SETS ffv
   WHERE  APPLICATION_ID = 401 -- 'INV'
   AND    ID_FLEX_CODE = 'MTLL'
   AND    ID_FLEX_NUM  = 101 -- 'STOCK_LOCATORS'
   AND    ENABLED_FLAG = 'Y'
   AND    DISPLAY_FLAG = 'Y'
   AND    ffv.FLEX_VALUE_SET_ID(+) = ffs.FLEX_VALUE_SET_ID
   ORDER BY SEGMENT_NUM;

   L_RETURN  VARCHAR2(90);
   L_ROWNUM  NUMBER := 0;
   L_COLNAME VARCHAR2(15);
   L_VALUE_SET_ID NUMBER;
   L_VALIDATION_TYPE VARCHAR2(1);
   L_CONCAT VARCHAR2(1000);
   L_DELIM VARCHAR2(1);
   L_FIRST_TIME BOOLEAN := TRUE;
   L_BSLASH_DELIM VARCHAR2(2);    -- For Bug# 7623167

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN


     SELECT CONCATENATED_SEGMENT_DELIMITER
     INTO L_DELIM
     FROM FND_ID_FLEX_STRUCTURES
     WHERE ID_FLEX_CODE = 'MTLL' AND ROWNUM =1;

     L_BSLASH_DELIM := '\' || L_DELIM;  -- For Bug# 7623167

     OPEN CUR_SEG;
     LOOP
       FETCH CUR_SEG INTO L_COLNAME, L_VALUE_SET_ID, L_VALIDATION_TYPE;
       EXIT WHEN CUR_SEG%NOTFOUND;
       L_ROWNUM := L_ROWNUM + 1;
       IF (L_FIRST_TIME) THEN


       /* Bug# 7623167: Added the replace fucntion to individual segments for getting the correct concatenated segments
       as if a segment is having the occurrence of the seperator then it should be prefixed by a backslash */
            IF (L_COLNAME = 'SEGMENT19') THEN
               --Commented For Bug# 7623167 and replaced below: L_CONCAT := 'inv_project.GET_PROJECT_NUMBER('||L_COLNAME||')'; --Changed for bug 3073756
               L_CONCAT := 'REPLACE(inv_project.GET_PROJECT_NUMBER('||L_COLNAME|| '),''' || L_DELIM || ''',''' || L_BSLASH_DELIM || ''')';
	          ELSIF(L_COLNAME = 'SEGMENT20') THEN
	            --Commented For Bug# 7623167 and replaced below: L_CONCAT := 'inv_project.GET_TASK_NUMBER('||L_COLNAME||')'; --Changed for bug 3073756
              L_CONCAT := 'REPLACE(inv_project.GET_TASK_NUMBER('||L_COLNAME|| '),''' || L_DELIM || ''',''' || L_BSLASH_DELIM || ''')';
            ELSIF (L_VALIDATION_TYPE = 'N' OR L_VALIDATION_TYPE IS NULL) THEN
            --Commented For Bug# 7623167 and replaced below: L_CONCAT := L_COLNAME;
              L_CONCAT := 'REPLACE('||L_COLNAME||',''' || L_DELIM || ''',''' || L_BSLASH_DELIM || ''')';
            ELSE
              L_CONCAT := NULL;
	           END IF;



           L_FIRST_TIME := FALSE;
        --From the 2nd segement onwards, check if l_concat is not null and the validation
        --type for the current segment is 'N' or there is none. If so then append the
        --delimiter and segment name to the concatenated segments string
       ELSE
            IF (L_CONCAT IS NULL) THEN
               L_CONCAT := NULL;
            ELSIF (L_COLNAME = 'SEGMENT19') THEN
               --Commented For Bug# 7623167 and replaced below: L_CONCAT := L_CONCAT || '||' || '''' || L_DELIM || '''' || '||' || 'inv_project.GET_PROJECT_NUMBER('||L_COLNAME||')';
               L_CONCAT := L_CONCAT || '||' || '''' || L_DELIM || '''' || '||' || 'REPLACE(inv_project.GET_PROJECT_NUMBER('||L_COLNAME|| '),''' || L_DELIM || ''',''' || L_BSLASH_DELIM || ''')';
	          ELSIF(L_COLNAME = 'SEGMENT20') THEN
	            --Commented For Bug# 7623167 and replaced below: L_CONCAT := L_CONCAT || '||' || '''' || L_DELIM || '''' || '||' || 'inv_project.GET_TASK_NUMBER('||L_COLNAME||')';
              L_CONCAT := L_CONCAT || '||' || '''' || L_DELIM || '''' || '||' || 'REPLACE(inv_project.GET_TASK_NUMBER('||L_COLNAME|| '),''' || L_DELIM || ''',''' || L_BSLASH_DELIM || ''')';
            ELSIF (L_VALIDATION_TYPE = 'N' OR L_VALIDATION_TYPE IS NULL) AND L_CONCAT IS NOT NULL THEN
              --Commented For Bug# 7623167 and replaced below: L_CONCAT := L_CONCAT || '||' || '''' || L_DELIM || '''' || '||' || L_COLNAME;
              L_CONCAT := L_CONCAT || '||' || '''' || L_DELIM || '''' || '||' || 'REPLACE('||L_COLNAME||',''' || L_DELIM || ''',''' || L_BSLASH_DELIM || ''')';

            ELSE
              L_CONCAT := NULL;
	          END IF;
            IF (l_debug = 1) THEN
               MYDEBUG('L_concat'||L_concat);
            END IF;

        END IF;  --END IF L_FIRST_TIME

   END LOOP;
   CLOSE CUR_SEG;

   IF (l_debug = 1) THEN
      MYDEBUG('L_OCNAT ' || L_CONCAT);
   END IF;
   X_CONCATENATED := L_CONCAT;


   FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );
   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN OTHERS THEN

      IF (l_debug = 1) THEN
         MYDEBUG('EXCEPTION RAISED IN conc_loc_qry '||SQLERRM);
      END IF;
      X_CONCATENATED := null;

      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'conc_loc_qry');
      END IF;
      FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

END CONC_LOC_QRY;


/*
 * Get the concatenated and resolved locator
 * currently used by material workbench
 */


FUNCTION GET_LOCATOR(P_LOCATOR_ID IN NUMBER,
                            P_ORG_ID IN NUMBER) RETURN VARCHAR2 IS
  L_CC_ID_RET  BOOLEAN;
  TYPE CUR_LOC IS REF CURSOR;
  c_locator          CUR_LOC;
  l_loc_str          VARCHAR2(1000);
  X_RETURN_STATUS    VARCHAR2(1);
  X_MSG_DATA         VARCHAR2(1000);
  X_MSG_COUNT        NUMBER;
  L_CONCATED_LOCATOR VARCHAR2(400);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
     MYDEBUG('GET_LOCATOR: P_LOCATOR_ID: P_ORG_ID: '||P_LOCATOR_ID||' : '||P_ORG_ID);
  END IF;
  /* bug 8680793 */
  IF (NVL(P_LOCATOR_ID,0) <= 0)  THEN
     IF (l_debug = 1) THEN
	MYDEBUG('Returning NULL as its not locator controlled');
     END IF;
     RETURN NULL;
  END IF;

  IF (G_LOC_QRY_BLT <> 'Y')  THEN
        G_LOC_QRY_BLT := 'Y';
        CONC_LOC_QRY(
                          X_RETURN_STATUS  => X_RETURN_STATUS,
                          X_MSG_COUNT      => X_MSG_COUNT,
                          X_MSG_DATA       => X_MSG_DATA,
                          X_CONCATENATED   => G_LOC_CONC_QRY
                        );
        IF (l_debug = 1) THEN
           MYDEBUG('GET_LOCATOR: GET_LOCATOR_METADATA: '||X_RETURN_STATUS);
        END IF;
   END IF;

   IF G_LOC_CONC_QRY IS NOT NULL THEN

     IF (l_debug = 1) THEN
        MYDEBUG('Using MTL_ITEM_LOCATIONS to get locator, project and task info');
     END IF;
     --Build the string to fetch locator from MTL_ITEM_LOCATIONS
     l_loc_str := 'SELECT ' || G_LOC_CONC_QRY ;
     l_loc_str := l_loc_str || ' FROM MTL_ITEM_LOCATIONS ';
     l_loc_str := l_loc_str || ' WHERE INVENTORY_LOCATION_ID = :1 AND ORGANIZATION_ID = :2';

     IF (l_debug = 1) THEN
        MYDEBUG('l_loc_str:' || l_loc_str);
     END IF;

     --Open the cursor and store the results in session variables
     OPEN c_locator FOR l_loc_str USING P_LOCATOR_ID, P_ORG_ID;
     FETCH c_locator INTO l_concated_locator;
     CLOSE c_locator;
     G_CONCATENATED_LOCATOR := l_concated_locator;

    --If any of the segments has a validation type other than 'N'
    ELSE
     IF (l_debug = 1) THEN
        MYDEBUG('Using FND APIs to get locator, project and task info');
     END IF;
     L_CC_ID_RET := FND_FLEX_KEYVAL.VALIDATE_CCID(
                               APPL_SHORT_NAME       => 'INV',
                               KEY_FLEX_CODE         => 'MTLL',
                               STRUCTURE_NUMBER      => 101,
                               COMBINATION_ID        => P_LOCATOR_ID,
			       DISPLAYABLE           => 'ALL',
                               DATA_SET              => P_ORG_ID,
                               VRULE                 => NULL,
                               SECURITY              => 'IGNORE',
                               GET_COLUMNS           => NULL,
                               RESP_APPL_ID          => 401,
                               RESP_ID               => NULL,
                               USER_ID               => NULL,
                               SELECT_COMB_FROM_VIEW => NULL
                                                 );
     IF NOT L_CC_ID_RET THEN
       IF (l_debug = 1) THEN
          MYDEBUG('GET_LOCATOR: VALIDATE_CCID: CALL FAILED');
          MYDEBUG('GET_LOCATOR: VALIDATE_CCID: '||FND_FLEX_KEYVAL.ERROR_MESSAGE);
       END IF;
     ELSE
       G_CONCATENATED_LOCATOR := FND_FLEX_KEYVAL.CONCATENATED_VALUES;
     END IF;

   END IF;  --END If g_concated_segments IS NOT NULL
   IF (l_debug = 1) THEN
      MYDEBUG('LOCATOR: ' || G_CONCATENATED_LOCATOR);
   END IF;
   return G_CONCATENATED_LOCATOR;

EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         MYDEBUG('GET_LOCATOR: RAISED EXCEPTION: '||SQLERRM);
      END IF;
      RETURN NULL; --Added for bug 3073756
END GET_LOCATOR;

/*Added overloaded function for performance enhancements...*/
  FUNCTION GET_LOCSEGS(p_concatenated_segments IN VARCHAR2)
    RETURN VARCHAR2 IS
    CURSOR cur_seg IS
      SELECT application_column_name
       FROM fnd_id_flex_segments ffs
      WHERE application_id = 401 -- 'INV'
        AND id_flex_code = 'MTLL'
        AND id_flex_num = 101    -- 'STOCK_LOCATORS'
        AND enabled_flag = 'Y'
        AND display_flag = 'Y'
       ORDER BY segment_num;

    CURSOR c_delim IS
      SELECT concatenated_segment_delimiter
        FROM fnd_id_flex_structures
       WHERE id_flex_code = 'MTLL'
         AND ROWNUM = 1;

    l_row_num      NUMBER         := 1;
    l_buf          VARCHAR2(491);--BUG3306367
    l_new_segments VARCHAR2(491)   := '';--BUG3306367
    i              BINARY_INTEGER := 1;
    j              BINARY_INTEGER := 1;
    k              BINARY_INTEGER := 1;
    l_col_index    BINARY_INTEGER := 1;
  BEGIN
    IF g_delimiter IS NULL THEN
      g_project_index  := 0;
      g_task_index     := 0;
      OPEN c_delim;
      FETCH c_delim INTO g_delimiter;
      CLOSE c_delim;

      FOR rec1 IN cur_seg LOOP
        IF rec1.application_column_name = 'SEGMENT19' THEN
          g_project_index  := l_row_num;
        END IF;

        IF rec1.application_column_name = 'SEGMENT20' THEN
          g_task_index  := l_row_num;
        END IF;

        l_row_num  := l_row_num + 1;
      END LOOP;
    END IF;

    IF g_project_index = 0 THEN
      RETURN p_concatenated_segments;
    END IF;

    LOOP
      <<skip_segment>>
      j := INSTR(p_concatenated_segments, g_delimiter, 1, i);

      /*
       *  j is initialized to 1, j is 0 only when the last
       *  instance of the delimitor is already found.
       *  In such a case fetch the rest of the string rather than
       *  a substr..
       */
      IF j = 0 THEN
        l_buf  := SUBSTR(p_concatenated_segments, k);
      ELSE
        IF SUBSTR(p_concatenated_segments, j - 1, 1) = '\' THEN
          i  := i + 1;
          GOTO skip_segment;
        END IF;

        l_buf  := SUBSTR(p_concatenated_segments, k,(j - k));
      END IF;

      IF l_col_index = g_project_index OR l_col_index = g_task_index THEN
        NULL;
      ELSE
        IF l_new_segments IS NULL THEN
          l_new_segments  := l_buf;
          /*bug 3905395 */
          IF l_buf IS NULL THEN
            l_new_segments := fnd_api.g_miss_char;
          END IF;
        ELSE
          l_new_segments  := l_new_segments || g_delimiter || l_buf;
        END IF;
      END IF;

      k            := j + 1;
      i            := i + 1;
      l_col_index  := l_col_index + 1;
      EXIT WHEN j = 0;
    END LOOP;

    RETURN l_new_segments;
  END get_locsegs;

  FUNCTION GET_PJM_LOCSEGS(p_concatenated_segments IN VARCHAR2)
      RETURN VARCHAR2 IS
    CURSOR cur_seg IS
      SELECT application_column_name
       FROM fnd_id_flex_segments ffs
      WHERE application_id = 401 -- 'INV'
        AND id_flex_code = 'MTLL'
        AND id_flex_num = 101    -- 'STOCK_LOCATORS'
        AND enabled_flag = 'Y'
        AND display_flag = 'Y'
       ORDER BY segment_num;

    CURSOR c_delim IS
      SELECT concatenated_segment_delimiter
        FROM fnd_id_flex_structures
       WHERE id_flex_code = 'MTLL'
         AND ROWNUM = 1;

    l_row_num      NUMBER         := 1;
    l_buf          VARCHAR2(491);--BUG3306367
    l_new_segments VARCHAR2(1000)   := '';--BUG4700952
    i              BINARY_INTEGER := 1;
    j              BINARY_INTEGER := 1;
    k              BINARY_INTEGER := 1;
    l_col_index    BINARY_INTEGER := 1;
    l_project_id       NUMBER;
    l_task_id          NUMBER;
    l_pt_buf       VARCHAR2(30);
  BEGIN
    IF p_concatenated_segments is null THEN
        return(NULL);
    END IF;
    IF g_delimiter IS NULL THEN
      g_project_index  := 0;
      g_task_index     := 0;
      OPEN c_delim;
      FETCH c_delim INTO g_delimiter;
      CLOSE c_delim;

      FOR rec1 IN cur_seg LOOP
        IF rec1.application_column_name = 'SEGMENT19' THEN
          g_project_index  := l_row_num;
        END IF;

        IF rec1.application_column_name = 'SEGMENT20' THEN
          g_task_index  := l_row_num;
        END IF;

        l_row_num  := l_row_num + 1;
      END LOOP;
    END IF;

    IF g_project_index = 0 THEN
      RETURN p_concatenated_segments;
    END IF;

    LOOP
      <<skip_segment>>
      j := INSTR(p_concatenated_segments, g_delimiter, 1, i);

      /*
       *  j is initialized to 1, j is 0 only when the last
       *  instance of the delimitor is already found.
       *  In such a case fetch the rest of the string rather than
       *  a substr..
       */
      IF j = 0 THEN
        l_buf  := SUBSTR(p_concatenated_segments, k);
      ELSE
        IF SUBSTR(p_concatenated_segments, j - 1, 1) = '\' THEN
          i  := i + 1;
          GOTO skip_segment;
        END IF;

        l_buf  := SUBSTR(p_concatenated_segments, k,(j - k));
      END IF;

      IF l_col_index = g_project_index OR l_col_index = g_task_index THEN

        -- 4662395 For this function
        -- the calling object will be required
        -- to set the profile mfg_organization_id.
        -- If this profile remains unset then
        -- no value will return from PJM_PROJECTS_ALL_V

        if (l_col_index = g_project_index) then
            l_project_id := to_number(l_buf);
            BEGIN
            SELECT m.project_number
	      INTO l_pt_buf
	      FROM pjm_projects_all_v m
              WHERE m.project_id = l_project_id
              AND ROWNUM = 1;
            EXCEPTION
                WHEN OTHERS THEN l_pt_buf := '';
            END;
        else
            BEGIN
            l_task_id := to_number(l_buf);
            SELECT m.task_number
	    INTO l_pt_buf
	    FROM pjm_tasks_v m
	    WHERE m.task_id = l_task_id
	      AND   m.project_id = l_project_id
              AND ROWNUM = 1;
            EXCEPTION
                WHEN OTHERS THEN l_pt_buf := '';
            END;

        end if;

        l_new_segments  := l_new_segments || g_delimiter || l_pt_buf;
      ELSE
        IF l_new_segments IS NULL THEN
          l_new_segments  := l_buf;
          /*bug 3905395 */
          IF l_buf IS NULL THEN
            l_new_segments := fnd_api.g_miss_char;
          END IF;
        ELSE
          l_new_segments  := l_new_segments || g_delimiter || l_buf;
        END IF;
      END IF;

      k            := j + 1;
      i            := i + 1;
      l_col_index  := l_col_index + 1;
      EXIT WHEN j = 0;
    END LOOP;

    RETURN l_new_segments;
  END get_pjm_locsegs;



END inv_project;

/
