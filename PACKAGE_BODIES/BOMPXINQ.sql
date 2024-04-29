--------------------------------------------------------
--  DDL for Package Body BOMPXINQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPXINQ" as
/* $Header: BOMXINQB.pls 120.0.12010000.4 2010/02/24 12:35:15 agoginen ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMXINQB.sql                                               |
| DESCRIPTION  : This file is a packaged procedure for the exploders.
| 		 This package contains 3 different exploders for the
|  		 modules it can be called from.  The procedure exploders
|		 calls the correct exploder based on the module option.
|		 Each of the 3 exploders can be called on directly too.
| Parameters:	org_id		organization_id
|		order_by	1 - Op seq, item seq
|				2 - Item seq, op seq
|		grp_id		unique value to identify current explosion
|				use value from sequence bom_small_expl_temp_s
|		session_id	unique value to identify current session
|			 	use value from bom_small_expl_temp_session_s
|		levels_to_explode
|		bom_or_eng	1 - BOM
|				2 - ENG
|		impl_flag	1 - implemented only
|				2 - both impl and unimpl
|		explode_option	1 - All
|				2 - Current
|				3 - Current and future
|		module		1 - Costing
|				2 - Bom
|				3 - Order entry
|		cst_type_id	cost type id for costed explosion
|		std_comp_flag	1 - explode only standard components
|				2 - all components
|		expl_qty	explosion quantity
|		item_id		item id of asembly to explode
|		list_id		unique id for lists in bom_lists for range
|		report_option	1 - cost rollup with report
|				2 - cost rollup no report
|				3 - temp cost rollup with report
|		cst_rlp_id	rollup_id
|		req_id		request id
|		prgm_appl_id	program application id
|		prg_id		program id
|		user_id		user id
|		lock_flag	1 - do not lock the table
|				2 - lock the table
|		alt_rtg_desg	alternate routing designator
|		rollup_option	1 - single level rollup
|				2 - full rollup
|		plan_factor_flag1 - Yes
|				2 - No
|		alt_desg	alternate bom designator
|		rev_date	explosion date
|		comp_code	concatenated component code lpad 16
|               show_rev        1 - obtain current revision of component
|				2 - don't obtain current revision
|		material_ctrl   1 - obtain subinventory locator
|				2 - don't obtain subinventory locator
|		lead_time	1 - calculate offset percent
|				2 - don't calculate offset percent
|		err_msg		error message out buffer
|		error_code	error code out.  returns sql error code
|				if sql error, 9999 if loop detected.
| Revision
  		Shreyas Shah	creation
  02/10/94	Shreyas Shah	added multi-org capability from bom_lists
				max_bom_levels of all orgs for multi-org
| 08/03/95	Rob Yee		added parameters for 10SG
| 01/12/02	Rahul Chitko	Exporting of an indented BOM into multiple
|                               pl/sql tables enabled. These pl/sql tables
|                               match the parameters used by the pl/sql BO and
|                               can be used for a direct import.
| 01/23/03	Rahul Chitko	Added validation to make sure that the organization
|				hierarchy is optional and that the user can still
|			        export data for the current organization.
|                                                                           |
+==========================================================================*/
  TYPE Header_Record_Id_Type IS RECORD
       (bill_sequence_id   NUMBER := FND_API.G_MISS_NUM,
        assembly_item_id   NUMBER := FND_API.G_MISS_NUM);

  TYPE Header_Record_Id_Tbl_Type IS TABLE OF Header_Record_Id_Type
    INDEX BY BINARY_INTEGER;
  G_Header_Record_id_Tbl    Header_Record_Id_Tbl_Type;
  G_bom_header_tbl          BOM_BO_PUB.BOM_HEADER_TBL_TYPE;
  G_bom_revisions_tbl       BOM_BO_PUB.BOM_REVISION_TBL_TYPE;
  G_bom_components_tbl      BOM_BO_PUB.BOM_COMPS_TBL_TYPE;
  G_bom_ref_designators_tbl BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE;
  G_bom_sub_components_tbl  BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE;
  G_bom_comp_ops_tbl        BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE;
  no_profile EXCEPTION;
  invalid_org EXCEPTION;
  invalid_assembly_item_name EXCEPTION;
  invalid_comp_seq_id EXCEPTION;
  invalid_bill_seq_id EXCEPTION;
  invalid_locator_id EXCEPTION;
  missing_parameters EXCEPTION;

procedure exploders(
	verify_flag		IN  NUMBER DEFAULT 0,
	online_flag		IN  NUMBER DEFAULT 0,
	org_id 			IN  NUMBER,
	order_by 		IN  NUMBER DEFAULT 1,
	grp_id			IN  NUMBER,
	session_id		IN  NUMBER DEFAULT 0,
	l_levels_to_explode 	IN  NUMBER DEFAULT 1,
	bom_or_eng		IN  NUMBER DEFAULT 1,
	impl_flag		IN  NUMBER DEFAULT 1,
	plan_factor_flag	IN  NUMBER DEFAULT 2,
	l_explode_option 	IN  NUMBER DEFAULT 2,
	module			IN  NUMBER DEFAULT 2,
	cst_type_id		IN  NUMBER DEFAULT 0,
	std_comp_flag		IN  NUMBER DEFAULT 0,
	unit_number_from	IN  VARCHAR2 DEFAULT '',
	unit_number_to		IN  VARCHAR2 DEFAULT '',
	rev_date		IN  DATE DEFAULT sysdate,
        show_rev        	IN NUMBER DEFAULT 2,
	material_ctrl   	IN NUMBER DEFAULT 2,
	lead_time		IN NUMBER DEFAULT 2,
	err_msg			OUT NOCOPY VARCHAR2,
	error_code		OUT NOCOPY NUMBER) AS

    max_level			NUMBER;
    levels_to_explode		NUMBER;
    explode_option		NUMBER;
    cost_org_id			NUMBER;
    max_levels			NUMBER;
    incl_oc_flag		NUMBER;
    counter			NUMBER;
    l_std_comp_flag		NUMBER;
    l_error_code		NUMBER;
    l_err_msg			VARCHAR2(2000);
    loop_detected		EXCEPTION;

BEGIN

    levels_to_explode	:= l_levels_to_explode;
    explode_option	:= l_explode_option;

/*
** fetch the max permissible levels for explosion
** doing a max since if no row exist to prevent no_Data_found exception
** from being raised
*/

    SELECT max(MAXIMUM_BOM_LEVEL)
	INTO max_level
	FROM BOM_PARAMETERS
	WHERE (org_id = -1
		or
		(org_id <> -1 and ORGANIZATION_ID = org_id)
	      );

-- since sort width is increased to 4 and column width is only 240,
-- maximum level must be at most 59 (levels 0 through 59).

    IF nvl(max_level, 60) > 59 THEN
	max_level := 59;
    END IF;

/*
** if levels to explode > max levels or < 0, set it to max_levels
*/
    IF (levels_to_explode < 0) OR (levels_to_explode > max_level) THEN
      	levels_to_explode := max_level;
    END IF;

/*
** if levels_to_explode > 1, then explode_option = CURRENT is the
** only valid option
** 05/20/93 removed this condition to make it generic.  Also the verify
** needs current+future indented explosion.

    IF levels_to_explode > 1 THEN
	explode_option	:= 2;
    END IF;
*/

    IF (module = 1 or module = 2) THEN 	/* cst or bom explosion */
	l_std_comp_flag	:= 2; 	/* ALL */
    ELSE
	l_std_comp_flag := std_comp_flag;
    END IF;

    IF (module = 1) THEN		/* CST */
	incl_oc_flag := 2;
    ELSE
	incl_oc_flag := 1;
    END IF;

    -- dbms_output.put_line('calling bompbxin.bom_Exploder . . .');

    BOMPBXIN.bom_exploder(
	verify_flag => verify_flag,
	online_flag => online_flag,
	org_id => org_id,
	order_by => order_by,
	grp_id => grp_id,
	levels_to_explode => levels_to_explode,
	bom_or_eng => bom_or_eng,
	impl_flag => impl_flag,
	std_comp_flag => l_std_comp_flag,
	plan_factor_flag => plan_factor_flag,
	explode_option => explode_option,
	incl_oc_flag => incl_oc_flag,
	unit_number_from => unit_number_from,
	unit_number_to => unit_number_to,
	max_level => max_level,
	rev_date => rev_date,
        show_rev => show_rev,
	material_ctrl => material_ctrl,
	lead_time => lead_time,
	err_msg => l_err_msg,
	error_code => l_error_code
    );

    error_code 	:= l_error_code;
    err_msg	:= l_err_msg;

EXCEPTION
    WHEN OTHERS THEN
	error_code	:= l_error_code;
	err_msg		:= l_err_msg;
END exploders;

PROCEDURE loopstr2msg(
	grp_id		IN NUMBER,
	verify_msg	OUT NOCOPY VARCHAR2
) IS
	top_alt		VARCHAR2(10);
	org_id		NUMBER;
        cur_msgstr      VARCHAR2(240);
        cur_item_id     NUMBER;
        cur_substr      VARCHAR2(16);
        position        NUMBER;
        tmp_msg         VARCHAR2(2000);
 	err_msg		VARCHAR2(80);

	CURSOR get_loop_rows(c_group_id NUMBER) IS
		SELECT
			COMPONENT_CODE,
			LOOP_FLAG,
			PLAN_LEVEL
		FROM BOM_SMALL_EXPL_TEMP
		WHERE GROUP_ID = c_group_id
		AND LOOP_FLAG = 1;
BEGIN

  SELECT NVL( TOP_ALTERNATE_DESIGNATOR, 'none' ), ORGANIZATION_ID
	INTO top_alt, org_id
	FROM BOM_SMALL_EXPL_TEMP
	WHERE GROUP_ID = grp_id
	AND ROWNUM = 1
	AND PLAN_LEVEL = 0;

  FOR loop_rec IN get_loop_rows( grp_id ) LOOP

	tmp_msg := '';

	FOR i IN 0..loop_rec.plan_level LOOP
		position := (i * 16) + 1;
		cur_substr := SUBSTR( loop_rec.component_code, position, 16 );
		cur_item_id := TO_NUMBER( cur_substr );

  	SELECT
  	substrb(MIF.ITEM_NUMBER || ' ' || BBM.ALTERNATE_BOM_DESIGNATOR,1,16)
  	INTO cur_msgstr
  	FROM MTL_ITEM_FLEXFIELDS MIF, BOM_BILL_OF_MATERIALS BBM
  	WHERE MIF.ORGANIZATION_ID = BBM.ORGANIZATION_ID
  	AND MIF.ITEM_ID = BBM.ASSEMBLY_ITEM_ID
  	AND BBM.ASSEMBLY_ITEM_ID = cur_item_id
  	AND BBM.ORGANIZATION_ID = org_id
  	AND (
		((top_alt = 'none') AND BBM.ALTERNATE_BOM_DESIGNATOR IS NULL)
		OR
		((top_alt <> 'none')
	  	AND (
		      ( EXISTS ( SELECT NULL FROM BOM_BILL_OF_MATERIALS BBM1
		        WHERE BBM1.ORGANIZATION_ID = org_id
		        AND BBM1.ASSEMBLY_ITEM_ID = cur_item_id
		        AND BBM1.ALTERNATE_BOM_DESIGNATOR = top_alt)
		        AND BBM.ALTERNATE_BOM_DESIGNATOR = top_alt
                      )
		      OR
		      ( NOT EXISTS (SELECT NULL FROM BOM_BILL_OF_MATERIALS BBM2
                        WHERE BBM2.ORGANIZATION_ID = org_id
                        AND BBM2.ASSEMBLY_ITEM_ID = cur_item_id
                        AND BBM2.ALTERNATE_BOM_DESIGNATOR = top_alt)
		        AND BBM.ALTERNATE_BOM_DESIGNATOR IS NULL
                      )
	            )
	  	)
  	   );

	  IF i = 0 THEN
		tmp_msg := cur_msgstr;
	  ELSE
	  	tmp_msg := tmp_msg || ' -> ' || cur_msgstr;
	  END IF;

	END LOOP; /* loop through component_code */

	verify_msg := tmp_msg;


  END LOOP; /* for loop_rec cursor loop */


EXCEPTION
    when others then
	err_msg := substrb(SQLERRM, 1, 70);

END loopstr2msg;

procedure exploder_userexit (
	verify_flag		IN  NUMBER DEFAULT 0,
	org_id			IN  NUMBER,
	order_by 		IN  NUMBER DEFAULT 1,
	grp_id			IN  NUMBER,
	session_id		IN  NUMBER DEFAULT 0,
	levels_to_explode 	IN  NUMBER DEFAULT 1,
	bom_or_eng		IN  NUMBER DEFAULT 1,
	impl_flag		IN  NUMBER DEFAULT 1,
	plan_factor_flag	IN  NUMBER DEFAULT 2,
	explode_option 		IN  NUMBER DEFAULT 2,
	module			IN  NUMBER DEFAULT 2,
	cst_type_id		IN  NUMBER DEFAULT 0,
	std_comp_flag		IN  NUMBER DEFAULT 0,
	expl_qty		IN  NUMBER DEFAULT 1,
	item_id			IN  NUMBER,
	unit_number_from	IN  VARCHAR2,
	unit_number_to		IN  VARCHAR2,
	alt_desg		IN  VARCHAR2 DEFAULT '',
	comp_code               IN  VARCHAR2 DEFAULT '',
	rev_date		IN  DATE DEFAULT sysdate,
        show_rev        	IN NUMBER DEFAULT 2,
	material_ctrl   	IN NUMBER DEFAULT 2,
	lead_time		IN NUMBER DEFAULT 2,
	err_msg			OUT NOCOPY VARCHAR2,
	error_code		OUT NOCOPY NUMBER) AS
    cbsi NUMBER;
    out_code			NUMBER;
    cost_org_id			NUMBER;
    stmt_num			NUMBER := 1;
    out_message			VARCHAR2(240);
    parameter_error		EXCEPTION;
    exploder_error		EXCEPTION;
   -- inv_uom_conv_exe            EXCEPTION;
    X_SortWidth		        number; -- Maximum of 9999 components per level
    cnt  NUMBER :=0;          -- bug 2951874
-- Bug 2088686
    is_cost_organization VARCHAR2(1);

    /* Bug: 9355186 - PL/SQL Tables for bulk collect */
    TYPE numTabType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE charTabType IS TABLE OF varchar2(3) INDEX BY BINARY_INTEGER;
    t_conversion_rate numTabType;
    curBSI numTabType;
    curCSI numTabType;
    curCII numTabType;
    curCBSI numTabType;
    t_master_org_id numTabType;
    t_child_uom charTabType;
    t_master_uom charTabtype;
    bulk_limit NUMBER := 10000;
   -- t_comp_qty NUMBER;
   -- t_comp_extd_qty NUMBER;
   -- t_item_cost NUMBER;
    Cursor cur is
       Select BET.bill_sequence_id curBSI,
              BET.component_sequence_id curCSI,
              BET.component_item_id curCII,
              BET.common_bill_sequence_id curCBSI,
              msi1.organization_id t_master_org_id,
              msi1.primary_uom_code t_master_uom,
              msi2.primary_uom_code t_child_uom
       from   BOM_SMALL_EXPL_TEMP BET, bom_bill_of_materials bbm,  mtl_system_items msi1, mtl_system_items msi2
       where  BET.bill_sequence_id <> BET.common_bill_sequence_id
       and    bbm.bill_sequence_id =  BET.common_bill_sequence_id
       and    msi1.inventory_item_id = BET.component_item_id
       and    msi1.organization_id =  bbm.organization_id
       and    msi2.inventory_item_id = BET.component_item_id
       and    msi2.organization_id = BET.organization_id
       and    BET.group_id = grp_id;
--Bug 2088686

   cursor conv (t_master_uom varchar2,
                t_child_uom  varchar2,
                t_inv_id     number,
                t_master_org_id number) is
    select conversion_rate
    from   mtl_uom_conversions_view
    where primary_uom_code = t_master_uom and
                uom_code = t_child_uom and
                inventory_item_id = t_inv_id and
                organization_id = t_master_org_id;

BEGIN
    -- Added savepoint for bug 3863319
    SAVEPOINT  exploder_userexit_pvt;

    X_SortWidth := BOMPBXIN.G_SortWidth;

    IF (verify_flag = 1) AND (module <> 2) THEN
	raise parameter_error;
    END IF;

    if (grp_id is null or item_id is null) then
	raise parameter_error;
    end if;

    stmt_num := 2;
    insert into bom_small_expl_temp
      (
	group_id,
	bill_sequence_id,
	component_sequence_id,
	organization_id,
	top_item_id,
	component_item_id,
	plan_level,
	extended_quantity,
        basis_type,
	component_quantity,
	sort_order,
	program_update_date,
	top_bill_sequence_id,
	component_code,
	loop_flag,
	top_alternate_designator,
	bom_item_type,
	parent_bom_item_type
       )
	select
	grp_id,
	bom.bill_sequence_id,
	NULL,
	org_id,
	item_id,
	item_id,
	0,
	expl_qty,
	1,
	1,
	lpad('1', X_SortWidth, '0'),
	sysdate,
	bom.bill_sequence_id,
	nvl(comp_code, lpad(item_id, 16, '0')),
	2,
	alt_desg,
	msi.bom_item_type,
	msi.bom_item_type
	from bom_bill_of_materials bom, mtl_system_items msi
	where bom.assembly_item_id = item_id
	and   bom.organization_id = org_id
	and   nvl(alternate_bom_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
	and   msi.organization_id = org_id
	and   inventory_item_id = item_id;

    if (SQL%NOTFOUND) then
	raise no_data_found;
    end if;

    -- dbms_output.put_line('level 0 inserted . . . ');
    Exploders(
	verify_flag => verify_flag,
	online_flag => 1,
	org_id => org_id,
	order_by => order_by,
	grp_id => grp_id,
	session_id => session_id,
	l_levels_to_explode => levels_to_explode,
	bom_or_eng => bom_or_eng,
	impl_flag => impl_flag,
	plan_factor_flag => plan_factor_flag,
	l_explode_option => explode_option,
	module => module,
	unit_number_from => unit_number_from,
	unit_number_to => unit_number_to,
	cst_type_id => cst_type_id,
	std_comp_flag => std_comp_flag,
	rev_date => rev_date,
        show_rev => show_rev,
	material_ctrl => material_ctrl,
	lead_time => lead_time,
	err_msg => out_message,
	error_code => out_code
    	);

    if (verify_flag <> 1 and (out_code = 9999 or out_code = 9998
		or out_code < 0)) then
  	raise exploder_error;
    elsif (verify_flag = 1 and (out_code = 9998 or out_code < 0)) then
	raise exploder_error;
    end if;

    if (module = 1) then
	BOMPCEXP.cst_exploder(
		grp_id => grp_id,
		org_id => org_id,
		cst_type_id => cst_type_id,
		inq_flag => 1,
		err_msg => out_message,
   		error_code => out_code);
    end if;

    if (verify_flag = 1) then
       Loopstr2msg( grp_id, out_message );
    end if;
-- Bug 2157325 Begin
-- If the master organization is referenced as the costing organization then
-- is_cost_organzation flag is set to 'N' else if the child organization itself
-- referenced as the costing organization then the is_cost_organization flag is
-- set to 'Y'.
--bug 2951874 corrected the following sql.

   select count(*) into  cnt
   from   mtl_parameters
   where  organization_id = cost_organization_id
          and organization_id = org_id;

   if (cnt >0) then
     is_cost_organization := 'Y';
   else
     is_cost_organization := 'N';
   end if;
-- Bug 2157325 End

  /* Bug 9355186 : Changed to bulk collect to improve performance */
  OPEN cur;
  LOOP
  FETCH cur
   bulk collect
   into curBSI, curCSI, curCII, curCBSI, t_master_org_id, t_master_uom, t_child_uom
   LIMIT bulk_limit;
  EXIT WHEN curBSI.count = 0;

  FOR i IN 1..curCSI.COUNT LOOP

/* Bug 9355186 - This information in queried in cursor cur
    select msi.primary_uom_code, msi.organization_id into
           t_master_uom, t_master_org_id
    from   mtl_system_items msi, bom_bill_of_materials bbm
    where  cr.curCBSI = bbm.bill_sequence_id and
           bbm.organization_id = msi.organization_id and
           msi.inventory_item_id = cr.curCII;

    select msi.primary_uom_code into t_child_uom
    from   mtl_system_items msi
    where  msi.inventory_item_id = cr.curCII and
           msi.organization_id = cr.curOI;
*/

/* Bug 2663515
    select conversion_rate into t_conversion_rate
    from   mtl_uom_conversions_view
    where primary_uom_code = t_master_uom and
          uom_code = t_child_uom and
          inventory_item_id = cr.curCII and
          organization_id = t_master_org_id;
*/

-- Bug 2088686 Begin
-- If the Intended Bill is referenced some other bill of different organization
-- then the conversion rate, uom of the component in the child organization
-- should be calculated.
  OPEN conv(t_master_uom(i), t_child_uom(i), curCII(i), t_master_org_id(i));
  Fetch conv into t_conversion_rate(i);
  if conv%NOTFOUND then
     close conv;  -- added for Bug #2994556
     /* Bug 9355186 : Error is thrown right away instead of raising exception */
         FND_MESSAGE.SET_NAME('BOM','BOM_UOMCV_INVUOMTYPE_ERR');
         fnd_message.Set_Token('FROMUOM',t_master_uom(i));
         fnd_message.Set_Token('TOUOM',t_child_uom(i));
         fnd_message.raise_error;
  End if;
 close conv;  -- added for Bug #2994556
  END LOOP; -- curCSI.count loop

/* Bug 9355186 : Individual updates converted into bulk update
    if is_cost_organization <> 'Y' then
       UPDATE BOM_SMALL_EXPL_TEMP
       SET    item_cost = item_cost*t_conversion_rate
       WHERE  group_id = cr.curGI and
              component_sequence_id = cr.curCSI and
              bill_sequence_id = cr.curBSI and
              common_bill_sequence_id = cr.curCBSI;
    end if;
--Bug 2157325 End

    UPDATE BOM_SMALL_EXPL_TEMP
    SET    component_quantity = trunc(component_quantity/t_conversion_rate, 22), --Bug 9173185 fix
           extended_quantity = extended_quantity/t_conversion_rate,
--           item_cost = item_cost*t_conversion_rate,
           primary_uom_code = cr.curPUC
    WHERE  group_id = cr.curGI and
           component_sequence_id = cr.curCSI and
           bill_sequence_id = cr.curBSI and
           common_bill_sequence_id = cr.curCBSI;
*/

  FORALL i IN 1..curCSI.COUNT
   /* Bug 9355186: Proving hint to improve performance */
   UPDATE /*+ index(BOM_SMALL_EXPL_TEMP BOM_SMALL_EXPL_TEMP_n1) */ BOM_SMALL_EXPL_TEMP
   SET
   -- Bug 2157325 Begin
   -- If cost_organization is Master organization then the item cost should be
   -- calculated by multiplying the conversion_rate.
   item_cost = decode(is_cost_organization,'Y',item_cost,item_cost*t_conversion_rate(i)),
   component_quantity = trunc(component_quantity/t_conversion_rate(i), 22), --Bug 8977128 fix
   extended_quantity = extended_quantity/t_conversion_rate(i)
   WHERE  group_id = grp_id and
     component_sequence_id = curCSI(i) and
     bill_sequence_id = curBSI(i) and
     common_bill_sequence_id = curCBSI(i);

  END LOOP; -- bulk collect loop
  close cur;

-- Bug 2088686 End
  error_code	:= out_code;
    err_msg	:= out_message;

EXCEPTION
    when exploder_error then
      error_code := out_code;
      err_msg	 := out_message;
    WHEN parameter_error THEN
	error_code	:= -1;
        Fnd_Msg_Pub.Build_Exc_Msg(
          p_pkg_name => 'BOMPXINQ',
          p_procedure_name => 'exploder_userexit',
          p_error_text => 'verify parameters');
        err_msg := Fnd_Message.Get_Encoded;
/* Commented for bug 9355186 WHEN  inv_uom_conv_exe THEN
         FND_MESSAGE.SET_NAME('BOM','BOM_UOMCV_INVUOMTYPE_ERR');
         fnd_message.Set_Token('FROMUOM',t_master_uom);
         fnd_message.Set_Token('TOUOM',t_child_uom);
         fnd_message.raise_error;*/

    WHEN OTHERS THEN
        error_code      := SQLCODE;
        Fnd_Msg_Pub.Build_Exc_Msg(
          p_pkg_name => 'BOMPXINQ',
          p_procedure_name => 'exploder_userexit',
          p_error_text => SQLERRM);
        err_msg := Fnd_Message.Get_Encoded;
        ROLLBACK TO exploder_userexit_pvt; -- Added for bug: 3863319
END exploder_userexit;

--========================================================================
-- PROCEDURE  :   Export_BOM
-- PARAMETERS :   Profile_id         IN   NUMBER       Security Profile Id
--		  Org_hierarchy_name IN   VARCHAR2     Organization Hierarchy
--                                                     Name
--                Assembly_item_id   IN   NUMBER       Assembly item id
--                Organization_id    IN   NUMBER       Organization id
--                Alternate_bm_designator IN VARCHAR2  Alternate bom designator
--                Costs              IN   NUMBER       Cost flag
--                Cost_type_id       IN   NUMBER       Cost type id
--                bom_export_tab     OUT  bomexporttabtype export table
--                Err_Msg            OUT  VARCHAR2     Error Message
--                Error_Code         OUT  NUMBER       Error Megssage
--
-- COMMENT    :   API Accepts the security profile id,name of an hierarchy,
--                Assembly item id, Organization id, Alternate bom designator,
--                Costs, Cost type id and returns bom_export_tab PL/SQL table
--                consists  of exploded BOM for all the organizations under
--                the hierarchy name. Error Code and corresponding Error
--                mesages are returned in case of an error
--
--========================================================================
PROCEDURE EXPORT_BOM  ( Profile_id                 IN      NUMBER,
                        Org_hierarchy_name         IN      VARCHAR2,
                        Assembly_item_id           IN      NUMBER,
                        Organization_id            IN      NUMBER,
                        Alternate_bm_designator    IN      VARCHAR2 DEFAULT '',
                        Costs                      IN      NUMBER DEFAULT 2,
                        Cost_type_id               IN      NUMBER DEFAULT 0,
                        bom_export_tab             OUT NOCOPY    bomexporttabtype,
                        Err_Msg                    OUT NOCOPY    VARCHAR2,
                        Error_Code                 OUT NOCOPY    NUMBER )
                        IS
t_org_code_list INV_OrgHierarchy_PVT.OrgID_tbl_type;
l_Org_hierarchy_name  VARCHAR2(30);
l_assembly_item_id    NUMBER;
l_organization_id     NUMBER;
l_cst_type_id         NUMBER;

max_level           NUMBER;
l_group_id          NUMBER;
l_org_name          VARCHAR2(60);
c_Cost_type_id      NUMBER;
c_assembly_item_id  NUMBER;
i_count             NUMBER :=1;
l_assembly_found    BOOLEAN :=TRUE;
l_org_count         NUMBER;

no_organization     EXCEPTION;
explode_error       EXCEPTION;
no_hierarchy        EXCEPTION;
cost_type           EXCEPTION;
no_level_access     EXCEPTION;
no_assy             EXCEPTION;
no_list             EXCEPTION;

-- cursor to obtain exploded bom from bom_small_expl_temp table
CURSOR export_tab (l_organization_id NUMBER, l_group_id NUMBER) IS
     SELECT
     TOP_BILL_SEQUENCE_ID      ,
     BILL_SEQUENCE_ID          ,
     COMMON_BILL_SEQUENCE_ID   ,
     ORGANIZATION_ID           ,
     COMPONENT_SEQUENCE_ID     ,
     COMPONENT_ITEM_ID         ,
     BASIS_TYPE		       ,
     COMPONENT_QUANTITY        ,
     PLAN_LEVEL                ,
     EXTENDED_QUANTITY         ,
     SORT_ORDER                ,
     GROUP_ID                  ,
     TOP_ALTERNATE_DESIGNATOR  ,
     COMPONENT_YIELD_FACTOR    ,
     TOP_ITEM_ID               ,
     COMPONENT_CODE            ,
     INCLUDE_IN_ROLLUP_FLAG    ,
     LOOP_FLAG                 ,
     PLANNING_FACTOR           ,
     OPERATION_SEQ_NUM         ,
     BOM_ITEM_TYPE             ,
     PARENT_BOM_ITEM_TYPE      ,
     ASSEMBLY_ITEM_ID          ,
     WIP_SUPPLY_TYPE           ,
     ITEM_NUM                  ,
     EFFECTIVITY_DATE          ,
     DISABLE_DATE              ,
     IMPLEMENTATION_DATE       ,
     OPTIONAL                  ,
     SUPPLY_SUBINVENTORY       ,
     SUPPLY_LOCATOR_ID         ,
     COMPONENT_REMARKS         ,
     CHANGE_NOTICE             ,
     OPERATION_LEAD_TIME_PERCENT,
     MUTUALLY_EXCLUSIVE_OPTIONS ,
     CHECK_ATP                  ,
     REQUIRED_TO_SHIP           ,
     REQUIRED_FOR_REVENUE       ,
     INCLUDE_ON_SHIP_DOCS       ,
     LOW_QUANTITY               ,
     HIGH_QUANTITY              ,
     SO_BASIS                   ,
     OPERATION_OFFSET           ,
     CURRENT_REVISION           ,
     LOCATOR                    ,
     CONTEXT                    ,
     ATTRIBUTE1                 ,
     ATTRIBUTE2                 ,
     ATTRIBUTE3                 ,
     ATTRIBUTE4                 ,
     ATTRIBUTE5                 ,
     ATTRIBUTE6                 ,
     ATTRIBUTE7                 ,
     ATTRIBUTE8                 ,
     ATTRIBUTE9                 ,
     ATTRIBUTE10                ,
     ATTRIBUTE11                ,
     ATTRIBUTE12                ,
     ATTRIBUTE13                ,
     ATTRIBUTE14                ,
     ATTRIBUTE15                ,
     ITEM_COST                  ,
     EXTEND_COST_FLAG
     FROM  bom_small_expl_temp
     WHERE
     Organization_id = l_organization_id
     AND GROUP_ID    =  l_group_id;

BEGIN
	l_assembly_item_id := Assembly_item_id;
	l_organization_id := Organization_id;
	c_Cost_type_id := Cost_type_id;

	--Set the Security Profile value as passed by the user
	FND_PROFILE.put('PER_SECURITY_PROFILE_ID',profile_id);

	--dbms_output.put_line('within export_Bom . . . ');

       -- Validate the Organization Hierarchy name and check,if the access allowed
	if (Org_hierarchy_name is not null)
	then
	   SELECT count (*) into l_org_count from
     	       per_organization_structures
	   WHERE  INV_ORGHIERARCHY_PVT.ORG_HIERARCHY_ACCESS(Org_hierarchy_name)='Y'
	   AND    name = Org_hierarchy_name;

          if (l_org_count <1 ) then
	          RAISE no_hierarchy;
          end if;
	--dbms_output.put_line('org count in heirarchy is more than 0 . . . ');

	end if;

/*	BEGIN
       --  Get the corresponding Organization name
         SELECT organization_name into l_org_name
         FROM   org_organization_definitions
         WHERE  organization_id = l_organization_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
	        RAISE no_organization;
	END;
*/

	if (Org_hierarchy_name is null OR Org_hierarchy_name = '')
	THEN
		--dbms_output.put_line('Org Hierarachy is null ' );
		t_org_code_list(1) := l_organization_id;
	ELSE
	   if (INV_ORGHIERARCHY_PVT.ORG_HIERARCHY_LEVEL_ACCESS(Org_hierarchy_name,
           l_organization_id)= 'Y') THEN
		INV_ORGHIERARCHY_PVT.ORG_HIERARCHY_LIST (Org_hierarchy_name,
                l_organization_id ,t_org_code_list);
	   else
		RAISE no_level_access;
	   end if;
	END IF;

    -- For each Organization, if the assembly exists then call the bom exploder
	FOR I in t_org_code_list.FIRST..t_org_code_list.LAST LOOP
	BEGIN
--dbms_output.put_line('organization: ' || t_org_code_list(I));

		SELECT assembly_item_id INTO c_assembly_item_id
		FROM   bom_bill_of_materials
		WHERE  assembly_item_id = l_assembly_item_id
		AND    organization_id = t_org_code_list(I)
		AND    nvl(ALTERNATE_BOM_DESIGNATOR,'NONE')=
		       nvl(Alternate_bm_designator,'NONE') ;
	EXCEPTION
          WHEN NO_DATA_FOUND THEN
		l_assembly_found :=FALSE;
	END;

       if l_assembly_found then
	BEGIN
	if ( costs = 1) then
		SELECT COST_TYPE_ID into l_cst_type_id
		FROM  cst_item_cost_type_v
		WHERE inventory_item_id = Assembly_item_id
		AND   cost_type_id = c_Cost_type_id
		AND   organization_id = t_org_code_list(I);
	end if;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		l_organization_id := t_org_code_list(I);
		RAISE  cost_type;
	END;
	--Get the maximum level for explosion is allowed for the Organization
	SELECT MAXIMUM_BOM_LEVEL INTO max_level
	FROM BOM_PARAMETERS
	WHERE ORGANIZATION_ID = t_org_code_list(I);

	SELECT bom_explosion_temp_s.nextval
	INTO  l_group_id from dual;

	DELETE from bom_small_expl_temp where group_id =l_group_id;

	--dbms_output.put_line('calling explosion . . . ');

	exploder_userexit (
	verify_flag          => 0 ,
        org_id               => t_org_code_list(I) ,
        order_by             => 2 ,
        grp_id               => l_group_id ,
        session_id           => 0 ,
        levels_to_explode    => max_level,
        bom_or_eng           => 1,
        impl_flag            => 1,
        plan_factor_flag     => 2,
        explode_option       => 3,
        module               => costs ,
        unit_number_from     => NULL,
        unit_number_to       => NULL,
        cst_type_id          => cost_type_id ,
        std_comp_flag        => 2 ,
        expl_qty             => 1,
        item_id              => Assembly_item_id ,
        alt_desg             => alternate_bm_designator ,
        comp_code            => null ,
        rev_date             => sysdate ,
        show_rev             => 1 ,
        material_ctrl        => 1,
        lead_time            => 1,
        err_msg              => err_msg ,
        error_code           => Error_Code  );
	if error_code = 9998 then
		l_organization_id := t_org_code_list(I);
		RAISE explode_error;
	end if ;
	if (error_code = 0 or error_code is NULL) then
	-- Copy the data into the PL/SQL table
  	  FOR loop_tab IN  export_tab ( t_org_code_list(I),l_group_id)
	   LOOP
		bom_export_tab(i_count).TOP_BILL_SEQUENCE_ID :=
		loop_tab.TOP_BILL_SEQUENCE_ID;
		bom_export_tab(i_count).BILL_SEQUENCE_ID :=
		loop_tab.BILL_SEQUENCE_ID;
		bom_export_tab(i_count).COMMON_BILL_SEQUENCE_ID :=
		loop_tab.COMMON_BILL_SEQUENCE_ID;
		bom_export_tab(i_count).ORGANIZATION_ID :=
		loop_tab.ORGANIZATION_ID ;
		bom_export_tab(i_count).COMPONENT_SEQUENCE_ID :=
		loop_tab.COMPONENT_SEQUENCE_ID  ;
		bom_export_tab(i_count).COMPONENT_ITEM_ID  :=
		loop_tab.COMPONENT_ITEM_ID  ;
		bom_export_tab(i_count).BASIS_TYPE:= loop_tab.BASIS_TYPE;
		bom_export_tab(i_count).COMPONENT_QUANTITY :=
		loop_tab.COMPONENT_QUANTITY ;
		bom_export_tab(i_count).PLAN_LEVEL := loop_tab.PLAN_LEVEL;
		bom_export_tab(i_count).EXTENDED_QUANTITY :=
		loop_tab.EXTENDED_QUANTITY ;
		bom_export_tab(i_count).SORT_ORDER :=
		loop_tab.SORT_ORDER ;
		bom_export_tab(i_count).GROUP_ID  :=
		loop_tab.GROUP_ID ;
		bom_export_tab(i_count).TOP_ALTERNATE_DESIGNATOR :=
		loop_tab.TOP_ALTERNATE_DESIGNATOR;
		bom_export_tab(i_count).COMPONENT_YIELD_FACTOR  :=
		loop_tab.COMPONENT_YIELD_FACTOR ;
		bom_export_tab(i_count).TOP_ITEM_ID  :=
		loop_tab.TOP_ITEM_ID  ;
		bom_export_tab(i_count).COMPONENT_CODE  :=
		loop_tab.COMPONENT_CODE  ;
		bom_export_tab(i_count).INCLUDE_IN_ROLLUP_FLAG  :=
		loop_tab.INCLUDE_IN_ROLLUP_FLAG ;
		bom_export_tab(i_count).LOOP_FLAG  := loop_tab.LOOP_FLAG ;
		bom_export_tab(i_count).PLANNING_FACTOR  :=
		loop_tab. PLANNING_FACTOR ;
		bom_export_tab(i_count).OPERATION_SEQ_NUM  :=
		loop_tab.OPERATION_SEQ_NUM ;
		bom_export_tab(i_count).BOM_ITEM_TYPE := loop_tab.BOM_ITEM_TYPE;
		bom_export_tab(i_count).PARENT_BOM_ITEM_TYPE :=
		loop_tab.PARENT_BOM_ITEM_TYPE   ;
		bom_export_tab(i_count).ASSEMBLY_ITEM_ID :=
		loop_tab.ASSEMBLY_ITEM_ID;
		bom_export_tab(i_count).WIP_SUPPLY_TYPE :=
		loop_tab.WIP_SUPPLY_TYPE ;
		bom_export_tab(i_count).ITEM_NUM  := loop_tab.ITEM_NUM ;
		bom_export_tab(i_count).EFFECTIVITY_DATE  :=
		loop_tab.EFFECTIVITY_DATE;
		bom_export_tab(i_count).DISABLE_DATE  :=
		loop_tab.DISABLE_DATE    ;
		bom_export_tab(i_count).IMPLEMENTATION_DATE :=
		loop_tab.IMPLEMENTATION_DATE  ;
		bom_export_tab(i_count).OPTIONAL := loop_tab.OPTIONAL ;
		bom_export_tab(i_count).SUPPLY_SUBINVENTORY :=
		loop_tab.SUPPLY_SUBINVENTORY ;
		bom_export_tab(i_count).SUPPLY_LOCATOR_ID  :=
		loop_tab.SUPPLY_LOCATOR_ID ;
		bom_export_tab(i_count).COMPONENT_REMARKS :=
		loop_tab.COMPONENT_REMARKS      ;
		bom_export_tab(i_count).CHANGE_NOTICE :=
		loop_tab.CHANGE_NOTICE   ;
		bom_export_tab(i_count).OPERATION_LEAD_TIME_PERCENT :=
		loop_tab.OPERATION_LEAD_TIME_PERCENT;
		bom_export_tab(i_count).MUTUALLY_EXCLUSIVE_OPTIONS :=
		loop_tab.MUTUALLY_EXCLUSIVE_OPTIONS;
		bom_export_tab(i_count).CHECK_ATP  := loop_tab.CHECK_ATP ;
		bom_export_tab(i_count).REQUIRED_TO_SHIP :=
		loop_tab.REQUIRED_TO_SHIP ;
		bom_export_tab(i_count).REQUIRED_FOR_REVENUE :=
		loop_tab.REQUIRED_FOR_REVENUE    ;
		bom_export_tab(i_count).INCLUDE_ON_SHIP_DOCS :=
		loop_tab.INCLUDE_ON_SHIP_DOCS    ;
		bom_export_tab(i_count).LOW_QUANTITY := loop_tab.LOW_QUANTITY;
		bom_export_tab(i_count).HIGH_QUANTITY := loop_tab.HIGH_QUANTITY;
		bom_export_tab(i_count).SO_BASIS := loop_tab.SO_BASIS ;
		bom_export_tab(i_count).OPERATION_OFFSET :=
		loop_tab.OPERATION_OFFSET ;
		bom_export_tab(i_count).CURRENT_REVISION :=
		loop_tab.CURRENT_REVISION ;
		bom_export_tab(i_count).LOCATOR  := loop_tab.LOCATOR ;
		bom_export_tab(i_count).CONTEXT  := loop_tab.CONTEXT ;
		bom_export_tab(i_count).ATTRIBUTE1 := loop_tab.ATTRIBUTE1 ;
		bom_export_tab(i_count).ATTRIBUTE2 := loop_tab.ATTRIBUTE2 ;
		bom_export_tab(i_count).ATTRIBUTE3  := loop_tab.ATTRIBUTE3 ;
		bom_export_tab(i_count).ATTRIBUTE4  := loop_tab.ATTRIBUTE4 ;
		bom_export_tab(i_count).ATTRIBUTE5  := loop_tab.ATTRIBUTE5 ;
		bom_export_tab(i_count).ATTRIBUTE6  := loop_tab.ATTRIBUTE6 ;
		bom_export_tab(i_count).ATTRIBUTE7  := loop_tab.ATTRIBUTE7 ;
		bom_export_tab(i_count).ATTRIBUTE8  := loop_tab.ATTRIBUTE8 ;
		bom_export_tab(i_count).ATTRIBUTE9  := loop_tab.ATTRIBUTE9 ;
		bom_export_tab(i_count).ATTRIBUTE10 := loop_tab.ATTRIBUTE10;
		bom_export_tab(i_count).ATTRIBUTE11 := loop_tab.ATTRIBUTE11;
		bom_export_tab(i_count).ATTRIBUTE12 := loop_tab.ATTRIBUTE12;
		bom_export_tab(i_count).ATTRIBUTE13 := loop_tab.ATTRIBUTE13;
		bom_export_tab(i_count).ATTRIBUTE14 := loop_tab.ATTRIBUTE14;
		bom_export_tab(i_count).ATTRIBUTE15 := loop_tab.ATTRIBUTE15;
		bom_export_tab(i_count).ITEM_COST   := loop_tab.ITEM_COST  ;
		bom_export_tab(i_count).EXTEND_COST_FLAG :=
		loop_tab.EXTEND_COST_FLAG  ;
 	    i_count := i_count  +1;
	   end loop ;
	   DELETE from bom_small_expl_temp where group_id =l_group_id;
	 end if;
	end if;
	l_assembly_found := TRUE;
	END LOOP;
	error_code := 0;
	Err_Msg    := NULL ;

 EXCEPTION
	WHEN  no_level_access THEN
		rollback ;
		bom_export_tab.delete;
		error_code := -122;
		Fnd_Message.Set_Name('BOM','BOM_NO_ORG_LEVEL_ACCESS');
		Fnd_Message.Set_Token('l_org_name',l_org_name);
		Fnd_Message.Set_Token('Org_hierarchy_name',Org_hierarchy_name);
		Err_Msg  := Fnd_Message.Get;
	WHEN no_organization THEN
		rollback ;
		bom_export_tab.delete;
		error_code := -121;
		Fnd_Message.Set_Name('BOM','BOM_INVALID_ORGANIZATION');
		Fnd_Message.Set_Token('l_organization_id',l_organization_id);
		Err_Msg := Fnd_Message.Get;
	WHEN explode_error   THEN
		rollback;
		bom_export_tab.delete;
		error_code := -120;
		Fnd_Message.Set_Name('BOM','BOM_ORG_LEVELS_EXCEEDED');
		Fnd_Message.Set_Token('Assembly',Assembly_item_id);
		Fnd_Message.Set_Token('Orgid',l_organization_id);
		Err_Msg:= Fnd_Message.Get;
	WHEN no_hierarchy THEN
		rollback ;
		bom_export_tab.delete;
		error_code := -119;
		Fnd_Message.Set_Name('BOM','BOM_INVALID_HIER_OR_ACCESS');
		Fnd_Message.Set_Token('Org_hierarchy_name',Org_hierarchy_name);
		Err_Msg := Fnd_Message.Get;
		--dbms_output.put_line('Error: no_hierarchy ' || Err_Msg);
	WHEN cost_type THEN
		rollback ;
		bom_export_tab.delete;
		error_code := -118;
		Fnd_Message.Set_Name('BOM','BOM_COST_TYPE_INVALID');
		Fnd_Message.Set_Token('Cost_type',c_Cost_type_id);
		Fnd_Message.Set_Token('Orgid',l_organization_id);
		Err_Msg := Fnd_Message.Get;
	WHEN OTHERS THEN
		rollback ;
		bom_export_tab.delete ;
		error_code := SQLCODE;
		Err_Msg := SQLERRM;
	END;

FUNCTION Get_Item_Name(P_item_id IN NUMBER,
                       P_organization_id IN NUMBER)
  RETURN VARCHAR2 IS
  l_item_name MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE;
BEGIN
  SELECT concatenated_segments
  INTO   l_item_name
  FROM   mtl_system_items_kfv
  WHERE  inventory_item_id = P_item_id
  AND    organization_id   = P_organization_id;
  RETURN l_item_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE invalid_assembly_item_name;
END Get_Item_Name;


FUNCTION Get_Org_Code(P_organization_id IN NUMBER)
  RETURN VARCHAR2 IS
  l_org_code VARCHAR2(3);
BEGIN
  SELECT organization_code
  INTO   l_org_code
  FROM   mtl_parameters
  WHERE  organization_id = P_organization_id;
  RETURN l_org_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE Invalid_Org;
END;

FUNCTION Header_Id_Exists(P_assembly_item_id IN NUMBER,
                          P_bill_sequence_id IN NUMBER)
  RETURN BOOLEAN IS
BEGIN
  IF (G_Header_Record_Id_Tbl.COUNT <= 0) THEN
    RETURN FALSE;
  END IF;
  FOR i IN G_Header_Record_Id_Tbl.FIRST..G_Header_Record_Id_Tbl.LAST LOOP
    IF (G_Header_Record_Id_Tbl(i).assembly_item_id = P_assembly_item_id AND
        G_Header_Record_Id_Tbl(i).bill_sequence_id = P_bill_sequence_id) THEN
      RETURN TRUE;
    END IF;
  END LOOP;
  RETURN FALSE;
END Header_Id_Exists;

FUNCTION Get_Locator_Name(P_locator_id IN NUMBER,
                          P_organization_id IN NUMBER)
  RETURN VARCHAR2 IS
  CURSOR locator_name_CUR IS
    SELECT concatenated_segments
    FROM   mtl_item_locations_kfv
    WHERE  inventory_location_id = P_locator_id
    AND    organization_id       = P_organization_id;
  l_locator_name MTL_ITEM_LOCATIONS_KFV.Concatenated_Segments%TYPE;
BEGIN
  OPEN locator_name_CUR;
  FETCH locator_name_CUR INTO l_locator_name;
  IF (locator_name_CUR%NOTFOUND) THEN
    RAISE invalid_locator_id;
  END IF;
  RETURN l_locator_name;
END Get_Locator_Name;

PROCEDURE Populate_Header(P_assembly_item_id IN NUMBER,
                          P_bill_sequence_id IN NUMBER,
                          P_organization_id  IN NUMBER,
                          P_alternate_bm_designator IN VARCHAR2) IS
  CURSOR Bill_Details_CUR IS
    SELECT specific_assembly_comment,
           assembly_type,
           common_assembly_item_id,
           common_organization_id,
           original_system_reference,
           alternate_bom_designator,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
    FROM   bom_bill_of_materials
    WHERE  bill_sequence_id = p_bill_sequence_id;
    --AND    NVL(alternate_bom_designator, '##$$##') = NVL(P_alternate_bm_designator, '##$$##');

    CURSOR Revision_Details_CUR IS
      SELECT revision,
             description,
             effectivity_date,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15
      FROM   mtl_item_revisions
      WHERE  inventory_item_id = P_assembly_item_id
      AND    organization_id   = P_organization_id;

  l_bill_details              Bill_Details_CUR%ROWTYPE;
  l_common_assembly_item_name MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE;
  l_common_org_code           VARCHAR2(3);
  l_item_name                 MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE;
  l_org_code                  VARCHAR2(3);
  l_cnt                       NUMBER;
  l_counter                   NUMBER;
  l_count                     NUMBER;
BEGIN

  l_count := G_Header_Record_Id_Tbl.LAST + 1;
  IF (l_count IS NULL) THEN
    l_count := 1;
  END IF;
  G_Header_Record_Id_Tbl(l_count).bill_sequence_id := P_bill_sequence_id;
  G_Header_Record_Id_Tbl(l_count).assembly_item_id := P_assembly_item_id;


  l_item_name := Get_Item_Name(P_assembly_item_id, P_organization_id);
  l_org_code  := Get_Org_Code(P_organization_id);

  OPEN Bill_Details_CUR;
  FETCH Bill_Details_CUR INTO l_bill_details;
  IF (Bill_Details_CUR%NOTFOUND) THEN
    RAISE invalid_bill_seq_id;
  END IF;
  CLOSE Bill_Details_CUR;

  IF l_bill_details.common_assembly_item_id IS NOT NULL THEN
    l_common_assembly_item_name := Get_Item_Name(l_bill_details.common_assembly_item_id,
                                                l_bill_details.common_organization_id);
    l_common_org_code           := Get_Org_Code(l_bill_details.common_organization_id);
  END IF;

  l_cnt := G_Bom_Header_Tbl.LAST + 1;
  IF (l_cnt IS NULL) THEN
    l_cnt := 1;
  END IF;

  G_Bom_Header_Tbl(l_cnt).assembly_item_name        := l_item_name;
  G_Bom_Header_Tbl(l_cnt).organization_code         := l_org_code;
  G_Bom_Header_Tbl(l_cnt).alternate_bom_code        := l_bill_details.alternate_bom_designator;
  G_Bom_Header_Tbl(l_cnt).common_assembly_item_name := l_common_assembly_item_name;
  G_Bom_Header_Tbl(l_cnt).common_organization_code  := l_common_org_code;
  G_Bom_Header_Tbl(l_cnt).assembly_comment          := l_bill_details.specific_assembly_comment;
  G_Bom_Header_Tbl(l_cnt).assembly_type             := l_bill_details.assembly_type;
  G_Bom_Header_Tbl(l_cnt).attribute_category        := l_bill_details.attribute_category;
  G_Bom_Header_Tbl(l_cnt).attribute1                := l_bill_details.attribute1;
  G_Bom_Header_Tbl(l_cnt).attribute2                := l_bill_details.attribute2;
  G_Bom_Header_Tbl(l_cnt).attribute3                := l_bill_details.attribute3;
  G_Bom_Header_Tbl(l_cnt).attribute4                := l_bill_details.attribute4;
  G_Bom_Header_Tbl(l_cnt).attribute5                := l_bill_details.attribute5;
  G_Bom_Header_Tbl(l_cnt).attribute6                := l_bill_details.attribute6;
  G_Bom_Header_Tbl(l_cnt).attribute7                := l_bill_details.attribute7;
  G_Bom_Header_Tbl(l_cnt).attribute8                := l_bill_details.attribute8;
  G_Bom_Header_Tbl(l_cnt).attribute9                := l_bill_details.attribute9;
  G_Bom_Header_Tbl(l_cnt).attribute10               := l_bill_details.attribute10;
  G_Bom_Header_Tbl(l_cnt).attribute11               := l_bill_details.attribute11;
  G_Bom_Header_Tbl(l_cnt).attribute12               := l_bill_details.attribute12;
  G_Bom_Header_Tbl(l_cnt).attribute13               := l_bill_details.attribute13;
  G_Bom_Header_Tbl(l_cnt).attribute14               := l_bill_details.attribute14;
  G_Bom_Header_Tbl(l_cnt).attribute15               := l_bill_details.attribute15;
  G_Bom_Header_Tbl(l_cnt).original_system_reference := l_bill_details.original_system_reference;

  l_counter := G_Bom_Revisions_Tbl.LAST + 1;
  IF (l_counter IS NULL) THEN
    l_counter := 1;
  END IF;
  FOR l_revision_details IN Revision_Details_CUR LOOP
    G_Bom_Revisions_Tbl(l_counter).assembly_item_name   := l_item_name;
    G_Bom_Revisions_Tbl(l_counter).organization_code    := l_org_code;
    G_Bom_Revisions_Tbl(l_counter).revision             := l_revision_details.revision;
    G_Bom_Revisions_Tbl(l_counter).alternate_bom_code   := l_bill_details.alternate_bom_designator;
    G_Bom_Revisions_Tbl(l_counter).description          := l_revision_details.description;
    G_Bom_Revisions_Tbl(l_counter).start_effective_date := l_revision_details.effectivity_date;
    G_Bom_Revisions_Tbl(l_counter).attribute1           := l_revision_details.attribute1;
    G_Bom_Revisions_Tbl(l_counter).attribute2           := l_revision_details.attribute2;
    G_Bom_Revisions_Tbl(l_counter).attribute3           := l_revision_details.attribute3;
    G_Bom_Revisions_Tbl(l_counter).attribute4           := l_revision_details.attribute4;
    G_Bom_Revisions_Tbl(l_counter).attribute5           := l_revision_details.attribute5;
    G_Bom_Revisions_Tbl(l_counter).attribute6           := l_revision_details.attribute6;
    G_Bom_Revisions_Tbl(l_counter).attribute7           := l_revision_details.attribute7;
    G_Bom_Revisions_Tbl(l_counter).attribute8           := l_revision_details.attribute8;
    G_Bom_Revisions_Tbl(l_counter).attribute9           := l_revision_details.attribute9;
    G_Bom_Revisions_Tbl(l_counter).attribute10          := l_revision_details.attribute10;
    G_Bom_Revisions_Tbl(l_counter).attribute11          := l_revision_details.attribute11;
    G_Bom_Revisions_Tbl(l_counter).attribute12          := l_revision_details.attribute12;
    G_Bom_Revisions_Tbl(l_counter).attribute13          := l_revision_details.attribute13;
    G_Bom_Revisions_Tbl(l_counter).attribute14          := l_revision_details.attribute14;
    G_Bom_Revisions_Tbl(l_counter).attribute15          := l_revision_details.attribute15;
    l_counter := l_counter + 1;
  END LOOP;

  EXCEPTION
    WHEN invalid_bill_seq_id THEN
      FND_MESSAGE.Set_Name('BOM', 'BOM_INVALID_BILL_SEQ_ID');
      FND_MESSAGE.Set_Token('BILL_SEQUENCE_ID', P_bill_sequence_id);
      FND_MESSAGE.Set_Token('ASSEMBLY_ITEM_NAME', l_item_name);
      FND_MESSAGE.Set_Token('ORGANIZATION_CODE', l_org_code);
      RAISE invalid_bill_seq_id;
END Populate_Header;

PROCEDURE Populate_Details(P_component_item_id IN NUMBER,
                           P_bill_sequence_id  IN NUMBER,
                           P_component_sequence_id IN NUMBER,
                           P_organization_id IN NUMBER) IS
  CURSOR Component_Details_CUR IS
    SELECT effectivity_date,
           disable_date,
           operation_seq_num,
           acd_type,
           item_num,
           basis_type,
           component_quantity,
           planning_factor,
           component_yield_factor,
           include_in_cost_rollup,
           wip_supply_type,
           so_basis,
           optional,
           mutually_exclusive_options,
           check_atp,
           shipping_allowed,
           required_to_ship,
           required_for_revenue,
           include_on_ship_docs,
           quantity_related,
           supply_subinventory,
           low_quantity,
           high_quantity,
           component_remarks,
           from_end_item_unit_number,
           to_end_item_unit_number,
           enforce_int_requirements,
           supply_locator_id,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
    FROM   bom_inventory_components
    WHERE  bill_sequence_id      = P_bill_sequence_id
    AND    component_sequence_id = P_component_sequence_id
    AND    component_item_id     = P_component_item_id;

  CURSOR Sub_Component_Details_CUR IS
    SELECT implementation_date,
           substitute_component_id,
           substitute_item_quantity,
           enforce_int_requirements,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
    FROM   bom_substitute_components_v
    WHERE  component_sequence_id = P_component_sequence_id;

  CURSOR Ref_Desig_Details_CUR IS
    SELECT component_reference_designator,
           implementation_date,
           ref_designator_comment,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
    FROM   bom_reference_designators_v
    WHERE  component_sequence_id = P_component_sequence_id;

  CURSOR Comp_Oper_Details_CUR IS
    SELECT operation_seq_num,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
    FROM   bom_component_operations
    WHERE  component_sequence_id = P_component_sequence_id;
  l_comp_details Component_Details_CUR%ROWTYPE;
  l_cnt NUMBER;
  j     NUMBER;
  k     NUMBER;
  l     NUMBER;
  l_component_item_name MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
  l_locator_name        MTL_ITEM_LOCATIONS_KFV.CONCATENATED_SEGMENTS%TYPE;
BEGIN
  l_component_item_name := Get_Item_Name(P_component_item_id, P_organization_id);

  OPEN Component_Details_CUR;
  FETCH Component_Details_CUR INTO l_comp_details;
  IF (Component_Details_CUR%NOTFOUND) THEN
    RAISE invalid_comp_seq_id;
  END IF;
  CLOSE Component_Details_CUR;

  IF (l_comp_details.supply_locator_id IS NOT NULL) THEN
    l_locator_name := Get_Locator_Name(l_comp_details.supply_locator_id,
                                       P_organization_id);
  END IF;

  l_cnt := G_Bom_Components_Tbl.LAST + 1;
  IF (l_cnt IS NULL) THEN
    l_cnt := 1;
  END IF;

  j := G_Bom_Sub_Components_Tbl.LAST + 1;
  IF (j IS NULL) THEN
    j := 1;
  END IF;

  k := G_Bom_Ref_Designators_Tbl.LAST + 1;
  IF (k IS NULL) THEN
    k := 1;
  END IF;

  l := G_Bom_Comp_Ops_Tbl.LAST + 1;
  IF (l IS NULL) THEN
    l := 1;
  END IF;

  FOR i IN G_Header_Record_Id_Tbl.FIRST..G_Header_Record_Id_Tbl.LAST LOOP
    IF (G_Header_Record_Id_Tbl(i).bill_sequence_id = P_bill_sequence_id) THEN
      G_Bom_Components_Tbl(l_cnt).organization_code         := G_Bom_Header_Tbl(i).organization_code;
      G_Bom_Components_Tbl(l_cnt).assembly_item_name        := G_Bom_Header_Tbl(i).assembly_item_name;
      G_Bom_Components_Tbl(l_cnt).start_effective_date      := l_comp_details.effectivity_date;
      G_Bom_Components_Tbl(l_cnt).disable_date              := l_comp_details.disable_date;
      G_Bom_Components_Tbl(l_cnt).operation_sequence_number := l_comp_details.operation_seq_num;
      G_Bom_Components_Tbl(l_cnt).component_item_name       := l_component_item_name;
      G_Bom_Components_Tbl(l_cnt).alternate_bom_code        := G_Bom_Header_Tbl(i).alternate_bom_code;
      G_Bom_Components_Tbl(l_cnt).item_sequence_number      := l_comp_details.item_num;
      G_Bom_Components_Tbl(l_cnt).basis_type		    := l_comp_details.basis_type;
      G_Bom_Components_Tbl(l_cnt).quantity_per_assembly     := l_comp_details.component_quantity;
      G_Bom_Components_Tbl(l_cnt).planning_percent          := l_comp_details.planning_factor;
      G_Bom_Components_Tbl(l_cnt).projected_yield           := l_comp_details.component_yield_factor;
      G_Bom_Components_Tbl(l_cnt).include_in_cost_rollup    := l_comp_details.include_in_cost_rollup;
      G_Bom_Components_Tbl(l_cnt).wip_supply_type           := l_comp_details.wip_supply_type;
      G_Bom_Components_Tbl(l_cnt).so_basis                  := l_comp_details.so_basis;
      G_Bom_Components_Tbl(l_cnt).optional                  := l_comp_details.optional;
      G_Bom_Components_Tbl(l_cnt).mutually_exclusive        := l_comp_details.mutually_exclusive_options;
      G_Bom_Components_Tbl(l_cnt).check_atp                 := l_comp_details.check_atp;
      G_Bom_Components_Tbl(l_cnt).shipping_allowed          := l_comp_details.shipping_allowed;
      G_Bom_Components_Tbl(l_cnt).required_to_ship          := l_comp_details.required_to_ship;
      G_Bom_Components_Tbl(l_cnt).required_for_revenue      := l_comp_details.required_for_revenue;
      G_Bom_Components_Tbl(l_cnt).include_on_ship_docs      := l_comp_details.include_on_ship_docs;
      G_Bom_Components_Tbl(l_cnt).quantity_related          := l_comp_details.quantity_related;
      G_Bom_Components_Tbl(l_cnt).supply_subinventory       := l_comp_details.supply_subinventory;
      G_Bom_Components_Tbl(l_cnt).location_name             := l_locator_name;
      G_Bom_Components_Tbl(l_cnt).minimum_allowed_quantity  := l_comp_details.low_quantity;
      G_Bom_Components_Tbl(l_cnt).maximum_allowed_quantity  := l_comp_details.high_quantity;
      G_Bom_Components_Tbl(l_cnt).comments                  := l_comp_details.component_remarks;
      G_Bom_Components_Tbl(l_cnt).from_end_item_unit_number := l_comp_details.from_end_item_unit_number;
      G_Bom_Components_Tbl(l_cnt).to_end_item_unit_number   := l_comp_details.to_end_item_unit_number;
      G_Bom_Components_Tbl(l_cnt).enforce_int_requirements  := l_comp_details.enforce_int_requirements;
      G_Bom_Components_Tbl(l_cnt).attribute_category        := l_comp_details.attribute_category;
      G_Bom_Components_Tbl(l_cnt).attribute1                := l_comp_details.attribute1;
      G_Bom_Components_Tbl(l_cnt).attribute2                := l_comp_details.attribute2;
      G_Bom_Components_Tbl(l_cnt).attribute3                := l_comp_details.attribute3;
      G_Bom_Components_Tbl(l_cnt).attribute4                := l_comp_details.attribute4;
      G_Bom_Components_Tbl(l_cnt).attribute5                := l_comp_details.attribute5;
      G_Bom_Components_Tbl(l_cnt).attribute6                := l_comp_details.attribute6;
      G_Bom_Components_Tbl(l_cnt).attribute7                := l_comp_details.attribute7;
      G_Bom_Components_Tbl(l_cnt).attribute8                := l_comp_details.attribute8;
      G_Bom_Components_Tbl(l_cnt).attribute9                := l_comp_details.attribute9;
      G_Bom_Components_Tbl(l_cnt).attribute10               := l_comp_details.attribute10;
      G_Bom_Components_Tbl(l_cnt).attribute11               := l_comp_details.attribute11;
      G_Bom_Components_Tbl(l_cnt).attribute12               := l_comp_details.attribute12;
      G_Bom_Components_Tbl(l_cnt).attribute13               := l_comp_details.attribute13;
      G_Bom_Components_Tbl(l_cnt).attribute14               := l_comp_details.attribute14;
      G_Bom_Components_Tbl(l_cnt).attribute15               := l_comp_details.attribute15;

      FOR Sub_Comp_Rec IN Sub_Component_Details_CUR LOOP
        G_Bom_Sub_Components_Tbl(j).organization_code         := G_Bom_Header_Tbl(i).organization_code;
        G_Bom_Sub_Components_Tbl(j).assembly_item_name        := G_Bom_Header_Tbl(i).assembly_item_name;
        G_Bom_Sub_Components_Tbl(j).start_effective_date      := Sub_Comp_Rec.implementation_date;
        G_Bom_Sub_Components_Tbl(j).operation_sequence_number := l_comp_details.operation_seq_num;
        G_Bom_Sub_Components_Tbl(j).component_item_name       := l_component_item_name;
        G_Bom_Sub_Components_Tbl(j).alternate_bom_code        := G_Bom_Header_Tbl(i).alternate_bom_code;
        G_Bom_Sub_Components_Tbl(j).substitute_component_name := Get_Item_Name(Sub_Comp_Rec.substitute_component_id,
                                                                               P_organization_id);
        G_Bom_Sub_Components_Tbl(j).substitute_item_quantity  := Sub_Comp_Rec.substitute_item_quantity;
        G_Bom_Sub_Components_Tbl(j).from_end_item_unit_number := l_comp_details.from_end_item_unit_number;
        G_Bom_Sub_Components_Tbl(j).enforce_int_requirements  := Sub_Comp_Rec.enforce_int_requirements;
        G_Bom_Sub_Components_Tbl(j).attribute_category        := Sub_Comp_Rec.attribute_category;
        G_Bom_Sub_Components_Tbl(j).attribute1                := Sub_Comp_Rec.attribute1;
        G_Bom_Sub_Components_Tbl(j).attribute2                := Sub_Comp_Rec.attribute2;
        G_Bom_Sub_Components_Tbl(j).attribute3                := Sub_Comp_Rec.attribute3;
        G_Bom_Sub_Components_Tbl(j).attribute4                := Sub_Comp_Rec.attribute4;
        G_Bom_Sub_Components_Tbl(j).attribute5                := Sub_Comp_Rec.attribute5;
        G_Bom_Sub_Components_Tbl(j).attribute6                := Sub_Comp_Rec.attribute6;
        G_Bom_Sub_Components_Tbl(j).attribute7                := Sub_Comp_Rec.attribute7;
        G_Bom_Sub_Components_Tbl(j).attribute8                := Sub_Comp_Rec.attribute8;
        G_Bom_Sub_Components_Tbl(j).attribute9                := Sub_Comp_Rec.attribute9;
        G_Bom_Sub_Components_Tbl(j).attribute10               := Sub_Comp_Rec.attribute10;
        G_Bom_Sub_Components_Tbl(j).attribute11               := Sub_Comp_Rec.attribute11;
        G_Bom_Sub_Components_Tbl(j).attribute12               := Sub_Comp_Rec.attribute12;
        G_Bom_Sub_Components_Tbl(j).attribute13               := Sub_Comp_Rec.attribute13;
        G_Bom_Sub_Components_Tbl(j).attribute14               := Sub_Comp_Rec.attribute14;
        G_Bom_Sub_Components_Tbl(j).attribute15               := Sub_Comp_Rec.attribute15;
        j := j + 1;
      END LOOP;

      FOR Ref_Desg_Rec IN Ref_Desig_Details_CUR LOOP
        G_Bom_Ref_Designators_Tbl(k).organization_code         := G_Bom_Header_Tbl(i).organization_code;
        G_Bom_Ref_Designators_Tbl(k).assembly_item_name        := G_Bom_Header_Tbl(i).assembly_item_name;
        G_Bom_Ref_Designators_Tbl(k).start_effective_date      := Ref_Desg_Rec.implementation_date;
        G_Bom_Ref_Designators_Tbl(k).operation_sequence_number := l_comp_details.operation_seq_num;
        G_Bom_Ref_Designators_Tbl(k).component_item_name       := l_component_item_name;
        G_Bom_Ref_Designators_Tbl(k).alternate_bom_code        := G_Bom_Header_Tbl(i).alternate_bom_code;
        G_Bom_Ref_Designators_Tbl(k).reference_designator_name := Ref_Desg_Rec.component_reference_designator;
        G_Bom_Ref_Designators_Tbl(k).ref_designator_comment    := Ref_Desg_Rec.ref_designator_comment;
        G_Bom_Ref_Designators_Tbl(k).from_end_item_unit_number := l_comp_details.from_end_item_unit_number;
        G_Bom_Ref_Designators_Tbl(k).attribute_category        := Ref_Desg_Rec.attribute_category;
        G_Bom_Ref_Designators_Tbl(k).attribute1                := Ref_Desg_Rec.attribute1;
        G_Bom_Ref_Designators_Tbl(k).attribute2                := Ref_Desg_Rec.attribute2;
        G_Bom_Ref_Designators_Tbl(k).attribute3                := Ref_Desg_Rec.attribute3;
        G_Bom_Ref_Designators_Tbl(k).attribute4                := Ref_Desg_Rec.attribute4;
        G_Bom_Ref_Designators_Tbl(k).attribute5                := Ref_Desg_Rec.attribute5;
        G_Bom_Ref_Designators_Tbl(k).attribute6                := Ref_Desg_Rec.attribute6;
        G_Bom_Ref_Designators_Tbl(k).attribute7                := Ref_Desg_Rec.attribute7;
        G_Bom_Ref_Designators_Tbl(k).attribute8                := Ref_Desg_Rec.attribute8;
        G_Bom_Ref_Designators_Tbl(k).attribute9                := Ref_Desg_Rec.attribute9;
        G_Bom_Ref_Designators_Tbl(k).attribute10               := Ref_Desg_Rec.attribute10;
        G_Bom_Ref_Designators_Tbl(k).attribute11               := Ref_Desg_Rec.attribute11;
        G_Bom_Ref_Designators_Tbl(k).attribute12               := Ref_Desg_Rec.attribute12;
        G_Bom_Ref_Designators_Tbl(k).attribute13               := Ref_Desg_Rec.attribute13;
        G_Bom_Ref_Designators_Tbl(k).attribute14               := Ref_Desg_Rec.attribute14;
        G_Bom_Ref_Designators_Tbl(k).attribute15               := Ref_Desg_Rec.attribute15;
        k := k + 1;
      END LOOP;

      FOR Comp_Oper_Rec IN Comp_Oper_Details_CUR LOOP
        G_Bom_Comp_Ops_Tbl(l).organization_code                := G_Bom_Header_Tbl(i).organization_code;
        G_Bom_Comp_Ops_Tbl(l).assembly_item_name               := G_Bom_Header_Tbl(i).assembly_item_name;
        G_Bom_Comp_Ops_Tbl(l).start_effective_date             := l_comp_details.effectivity_date;
        G_Bom_Comp_Ops_Tbl(l).from_end_item_unit_number        := l_comp_details.from_end_item_unit_number;
        G_Bom_Comp_Ops_Tbl(l).to_end_item_unit_number          := l_comp_details.to_end_item_unit_number;
        G_Bom_Comp_Ops_Tbl(l).operation_sequence_number        := Comp_Oper_Rec.operation_seq_num;
        G_Bom_Comp_Ops_Tbl(l).component_item_name              := l_component_item_name;
        G_Bom_Comp_Ops_Tbl(l).alternate_bom_code               := G_Bom_Header_Tbl(i).alternate_bom_code;
        G_Bom_Comp_Ops_Tbl(l).attribute_category               := Comp_Oper_Rec.attribute_category;
        G_Bom_Comp_Ops_Tbl(l).attribute1                       := Comp_Oper_Rec.attribute1;
        G_Bom_Comp_Ops_Tbl(l).attribute2                       := Comp_Oper_Rec.attribute2;
        G_Bom_Comp_Ops_Tbl(l).attribute3                       := Comp_Oper_Rec.attribute3;
        G_Bom_Comp_Ops_Tbl(l).attribute4                       := Comp_Oper_Rec.attribute4;
        G_Bom_Comp_Ops_Tbl(l).attribute5                       := Comp_Oper_Rec.attribute5;
        G_Bom_Comp_Ops_Tbl(l).attribute6                       := Comp_Oper_Rec.attribute6;
        G_Bom_Comp_Ops_Tbl(l).attribute7                       := Comp_Oper_Rec.attribute7;
        G_Bom_Comp_Ops_Tbl(l).attribute8                       := Comp_Oper_Rec.attribute8;
        G_Bom_Comp_Ops_Tbl(l).attribute9                       := Comp_Oper_Rec.attribute9;
        G_Bom_Comp_Ops_Tbl(l).attribute10                      := Comp_Oper_Rec.attribute10;
        G_Bom_Comp_Ops_Tbl(l).attribute11                      := Comp_Oper_Rec.attribute11;
        G_Bom_Comp_Ops_Tbl(l).attribute12                      := Comp_Oper_Rec.attribute12;
        G_Bom_Comp_Ops_Tbl(l).attribute13                      := Comp_Oper_Rec.attribute13;
        G_Bom_Comp_Ops_Tbl(l).attribute14                      := Comp_Oper_Rec.attribute14;
        G_Bom_Comp_Ops_Tbl(l).attribute15                      := Comp_Oper_Rec.attribute15;
        l := l + 1;
      END LOOP;
      exit;
    END IF;
  END LOOP;

  EXCEPTION
    WHEN invalid_comp_seq_id THEN
      FND_MESSAGE.Set_Name('BOM', 'BOM_INVALID_COMP_SEQ_ID');
      FND_MESSAGE.Set_Token('COMPONENT_ITEM_NAME', l_component_item_name);
      FND_MESSAGE.Set_Token('COMPONENT_SEQ_ID', P_component_sequence_id);
      RAISE invalid_comp_seq_id;
    WHEN invalid_locator_id THEN
      FND_MESSAGE.Set_Name('BOM', 'BOM_INVALID_LOCATOR_ID');
      FND_MESSAGE.Set_Token('LOCATOR_ID', l_comp_details.supply_locator_id);
      FND_MESSAGE.Set_Token('ORGANIZATION_ID', P_organization_id);
      FND_MESSAGE.Set_Token('COMPONENT_ITEM_NAME', l_component_item_name);
      RAISE invalid_locator_id;
END Populate_Details;

--========================================================================
-- PROCEDURE  :   Export_BOM
-- PARAMETERS :   Org_hierarchy_name        IN   VARCHAR2     Organization Hierarchy
--                                                            Name
--                Assembly_item_name        IN   VARCHAR2     Assembly item name
--                Organization_code         IN   VARCHAR2     Organization code
--                Alternate_bm_designator   IN   VARCHAR2     Alternate bom designator
--                Costs                     IN   NUMBER       Cost flag
--                Cost_type_id              IN   NUMBER       Cost type id
--                X_bom_header_tbl          OUT
--                X_bom_revisions_tbl       OUT
--                X_bom_components_tbl      OUT
--                X_bom_ref_designators_tbl OUT
--                X_bom_sub_components_tbl  OUT
--                X_bom_comp_ops_tbl        OUT
--                Err_Msg                   OUT  VARCHAR2     Error Message
--                Error_Code                OUT  NUMBER       Error Megssage
--
-- COMMENT    :   API Accepts the name of an hierarchy, Assembly item name,
--                Organization code, Alternate bom designator, Costs,
--                Cost type id. It returns the following six pl/sql tables:
--                1. P_bom_header_tbl ,
--                2. p_bom_revisions_tbl,
--                3. p_bom_components_tbl,
--                4. p_bom_ref_designators_tbl,
--                5. p_bom_sub_components_tbl,
--                6. p_bom_comp_ops_tbl
--                p_bom_header_tbl consists of all bom header records. p_bom_revisions_tbl
--                consists of all revisions for an assembly item withina bom.
--                p_bom_components_tbl consists of all components of a bom.
--                p_bom_ref_designators_tbl consists of the reference designators for each
--                of the components within a bom. p_bom_sub_components_tbl consits of
--                substitute components for each of the components within a bom.
--                p_bom_comp_ops_tbl consists of component operations for each of the
--                components within a bom. Error Code and corresponding Error
--                mesages are returned in case of an error
--
--
--========================================================================
PROCEDURE EXPORT_BOM  ( P_org_hierarchy_name      IN   VARCHAR2 DEFAULT NULL,
                        P_assembly_item_name      IN   VARCHAR2,
                        P_organization_code       IN   VARCHAR2,
                        P_alternate_bm_designator IN   VARCHAR2 DEFAULT NULL,
                        P_costs                   IN   NUMBER DEFAULT 2,
                        P_cost_type_id            IN   NUMBER DEFAULT 0,
                        X_bom_header_tbl          OUT  NOCOPY BOM_BO_PUB.BOM_HEADER_TBL_TYPE,
                        X_bom_revisions_tbl       OUT  NOCOPY BOM_BO_PUB.BOM_REVISION_TBL_TYPE,
                        X_bom_components_tbl      OUT  NOCOPY BOM_BO_PUB.BOM_COMPS_TBL_TYPE,
                        X_bom_ref_designators_tbl OUT  NOCOPY BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE,
                        X_bom_sub_components_tbl  OUT  NOCOPY BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE,
                        X_bom_comp_ops_tbl        OUT  NOCOPY BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE,
                        X_Err_Msg                 OUT  NOCOPY VARCHAR2,
                        X_Error_Code              OUT  NOCOPY NUMBER
                        ) IS
  l_organization_id  NUMBER;
  l_assembly_item_id NUMBER;
  l_profile_id       NUMBER := FND_PROFILE.value('PER_SECURITY_PROFILE_ID');

  l_bom_export_tab          BOMPXINQ.BOMEXPORTTABTYPE;

  CURSOR organization_code_CUR IS
    SELECT organization_id
    FROM   mtl_parameters
    WHERE  organization_code = P_organization_code;

  CURSOR assembly_item_name_CUR IS
    SELECT inventory_item_id
    FROM   mtl_system_items
    WHERE  segment1        = P_assembly_item_name
    AND    organization_id = l_organization_id;
  l_err_text VARCHAR2(2000);
  l_err_msg varchar2(2000);
  l_err_Code number;

BEGIN
  G_Header_Record_id_Tbl.DELETE;
  G_bom_header_tbl.DELETE;
  G_bom_revisions_tbl.DELETE;
  G_bom_components_tbl.DELETE;
  G_bom_ref_designators_tbl.DELETE;
  G_bom_sub_components_tbl.DELETE;
  G_bom_comp_ops_tbl.DELETE;

  IF (l_profile_id = null) THEN
  --dbms_output.put_line('No profile PER_SECURITY_PROFILE_ID . . . ');
    RAISE no_profile;
  END IF;


  --dbms_output.put_line('profile PER_SECURITY_PROFILE_ID . . . ' || l_profile_id);

  IF ((P_assembly_item_name IS NULL OR
       P_assembly_item_name = FND_API.G_MISS_CHAR) OR
       (
         (P_organization_code IS NULL OR
          P_organization_code = FND_API.G_MISS_CHAR
	 ) AND
	 (P_org_hierarchy_name IS NULL OR
	  P_org_hierarchy_name = FND_API.G_MISS_CHAR
	  )
	)
      )
  THEN
       RAISE missing_parameters;
  END IF;

  if (P_organization_code is not null)
  then
	l_organization_id := BOM_Val_To_Id.Organization(p_organization => P_organization_code,
                                                  x_err_text     => l_err_text);
  end if;

  IF (l_organization_id IS NULL OR
      l_organization_id = FND_API.G_MISS_NUM)
     AND P_organization_code is not null
  THEN
    --dbms_output.put_line('Invalid Organization . . . ');
    RAISE invalid_org;
  END IF;

  --dbms_output.put_line('Organization . . . ' || l_organization_id);
/*
  OPEN organization_code_CUR;

  FETCH organization_code_CUR INTO l_organization_id;
  IF (organization_code_CUR%NOTFOUND) THEN
    RAISE invalid_org;
  END IF;

  CLOSE organization_code_CUR;
*/

  OPEN assembly_item_name_CUR;

  FETCH assembly_item_name_CUR INTO l_assembly_item_id;
  IF (assembly_item_name_CUR%NOTFOUND) THEN
    RAISE invalid_assembly_item_name;
  END IF;
  CLOSE assembly_item_name_CUR;

  --dbms_output.put_line('Assembly item id: ' || l_assembly_item_id);


/* Call the existing Export_BOM that returns a single pl/sql table containing information about
   all the entities of a BOM
*/
  EXPORT_BOM(Profile_Id              => l_profile_id,
             Org_Hierarchy_Name      => P_org_hierarchy_name,
             Assembly_Item_Id        => l_assembly_item_id,
             Organization_Id         => l_organization_id,
             Alternate_Bm_Designator => P_alternate_bm_designator,
             Costs                   => P_costs,
             Cost_Type_Id            => P_cost_type_id,
             Bom_Export_Tab          => l_bom_export_tab,
             Err_Msg                 => l_Err_Msg,
             Error_Code              => l_Err_Code);

             x_err_msg := l_err_msg;
	     x_error_code := l_err_code;

  --dbms_output.put_line('exported in a single table . . . ' || l_bom_export_tab.COUNT);
  --dbms_output.put_line('error msg. . . ' || l_Err_Msg);
  --dbms_output.put_line('error code. . . ' || l_err_code);

  IF (X_Error_Code = 0 AND l_bom_export_tab.COUNT <> 0) THEN
    FOR i IN l_bom_export_tab.FIRST..l_bom_export_tab.LAST LOOP
      IF NOT Header_Id_Exists(P_assembly_item_id => l_bom_export_tab(i).assembly_item_id,
                              P_bill_sequence_id => l_bom_export_tab(i).bill_sequence_id) THEN
        IF (l_bom_export_tab(i).assembly_item_id IS NOT NULL) THEN
          Populate_Header(l_bom_export_tab(i).assembly_item_id,
                          l_bom_export_tab(i).bill_sequence_id,
                          l_bom_export_tab(i).organization_id,
                          p_Alternate_Bm_Designator);
        ELSE
          Populate_Header(l_bom_export_tab(i).component_item_id,
                          l_bom_export_tab(i).bill_sequence_id,
                          l_bom_export_tab(i).organization_id,
                          p_Alternate_Bm_Designator);
        END IF;
      END IF;
      IF (l_bom_export_tab(i).assembly_item_id IS NOT NULL) THEN
        Populate_Details(l_bom_export_tab(i).component_item_id,
                         l_bom_export_tab(i).bill_sequence_id,
                         l_bom_export_tab(i).component_sequence_id,
                         l_bom_export_tab(i).organization_id);
      END IF;

    END LOOP;
    X_Bom_Header_Tbl          := G_Bom_Header_Tbl;
    X_Bom_Revisions_Tbl       := G_Bom_Revisions_Tbl;
    X_Bom_Components_Tbl      := G_Bom_Components_Tbl;
    X_Bom_Ref_Designators_Tbl := G_Bom_Ref_Designators_Tbl;
    X_Bom_Sub_Components_Tbl  := G_Bom_Sub_Components_Tbl;
    X_Bom_Comp_Ops_Tbl        := G_Bom_Comp_Ops_Tbl;
  END IF;  -- Error_Code = 0

  EXCEPTION
       WHEN no_profile THEN
         rollback;
         X_error_code := -117;
         FND_MESSAGE.Set_Name('BOM', 'BOM_NO_PROFILE');
         X_Err_Msg := FND_MESSAGE.Get;

       WHEN missing_parameters THEN
         X_error_code := -112;
         FND_MESSAGE.Set_Name('BOM', 'BOM_ASSY_OR_ORG_MISSING');
         X_err_Msg := FND_MESSAGE.Get;

       WHEN invalid_org THEN
         rollback;
         X_error_code := -121;
         FND_MESSAGE.Set_Name('BOM', 'BOM_INVALID_ORGANIZATION');
         FND_MESSAGE.Set_Token('L_ORGANIZATION_ID', P_organization_code);
         X_Err_Msg := FND_MESSAGE.Get;

       WHEN invalid_assembly_item_name THEN
         rollback;
         X_error_code := -116;
         FND_MESSAGE.Set_Name('BOM', 'BOM_INVALID_ASSEMBLY_ITEM');
         FND_MESSAGE.Set_Token('ASSEMBLY_ITEM', P_assembly_item_name);
         X_Err_Msg := FND_MESSAGE.Get;

       WHEN invalid_comp_seq_id THEN
         rollback;
         X_bom_header_tbl.DELETE;
         X_bom_revisions_tbl.DELETE;
         X_bom_components_tbl.DELETE;
         X_bom_ref_designators_tbl.DELETE;
         X_bom_sub_components_tbl.DELETE;
         X_bom_comp_ops_tbl.DELETE;
         X_error_code := -115;
         X_Err_Msg := FND_MESSAGE.Get;

       WHEN invalid_locator_id THEN
         rollback;
         X_bom_header_tbl.DELETE;
         X_bom_revisions_tbl.DELETE;
         X_bom_components_tbl.DELETE;
         X_bom_ref_designators_tbl.DELETE;
         X_bom_sub_components_tbl.DELETE;
         X_bom_comp_ops_tbl.DELETE;
         X_error_code := -114;
         X_Err_Msg := FND_MESSAGE.Get;

       WHEN invalid_bill_seq_id THEN
         rollback;
         X_bom_header_tbl.DELETE;
         X_bom_revisions_tbl.DELETE;
         X_bom_components_tbl.DELETE;
         X_bom_ref_designators_tbl.DELETE;
         X_bom_sub_components_tbl.DELETE;
         X_bom_comp_ops_tbl.DELETE;
         X_error_code := -113;
         X_Err_Msg := FND_MESSAGE.Get;
END EXPORT_BOM;

END BOMPXINQ;

/
