--------------------------------------------------------
--  DDL for Package Body BOMPNORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPNORD" as
/* $Header: BOMEORDB.pls 120.2 2005/11/21 05:43:23 arudresh ship $ */

/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMEORDB.pls                                               |
| DESCRIPTION  : This file contains package body for the procedure used
|		 by the Enter Orders form
|		 to call the exploder.  The procedure first checks if
|		 a preexpldoed model already exists.  If it does, then
|		 it returns true or, if the copy_flag = 1, makes a copy of
| 		 the bill based on the rev_date and passes back the groupid
|		 of the copy.  If not or the preexploded model is marked for
|		 reexplosion, then it first calls the custom oe exploder to
|		 create a new master bill.
|
| Parameters:	org_id		organization_id
|		copy_flag	1 - create copy (used for the Configurator)
|				2 - don't create copy
|		expl_type	'OPTIONAL' or 'INCLUDED'
|		order_by	1 - Op seq, item seq
|				2 - Item seq, op seq
|		grp_id		unique value to identify current
|				  copy of the bill (only used by the
|				  configurator)
|		session_id	unique value to identify current session
|				 (only used by the configurator)
|		levels_to_explode
|		item_id		item id of asembly to explode
|		starting_rev_date
|		comp_code	concatenated component code (not used)
|		user_id
|		err_msg		error message out buffer
|		error_code	error code out.  returns sql error code
|				if sql error, 9999 if loop detected.
| Revision
| 02/20/94	Shreyas Shah	creation
| 12/27/94	Robert Yee	Modified to avoid duplicate models
| 12/28/94	Robert Yee	Remove updating of other session's flags
| 09/21/95      Raj Jain	modified for new BOM_OE_EXPLODER
| 09/26/95	Raj Jain	split BOMPNORD.sql into BOMEORDB.pls and
|					BOMEORDS.pls
| 04/28/97	Robert Yee	Redesign for partial explosions
| 01/05/03	Rahul Chitko	Added default for date so that explosion will
|                               happen successfully for sysdate even if it is
|                               called with a null rev_date.
|                                                                           |
+==========================================================================*/

Procedure Delete_Bom_Expl(top_bill_id  Number,
                          arg_expl_type        Varchar2)
IS
pragma  AUTONOMOUS_TRANSACTION;

BEGIN
        DELETE from bom_explosions
        WHERE top_bill_sequence_id = top_bill_id
        AND explosion_type = arg_expl_type;
        COMMIT;
END Delete_Bom_Expl;

PROCEDURE bmxporder_explode_for_order (
	org_id			IN  NUMBER,
	copy_flag		IN  NUMBER DEFAULT 2,
	expl_type		IN  VARCHAR2 DEFAULT 'OPTIONAL',
	order_by 		IN  NUMBER DEFAULT 1,
	grp_id		        IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	session_id		IN  NUMBER DEFAULT 0,
	levels_to_explode 	IN  NUMBER DEFAULT 60,
	item_id			IN  NUMBER,
	comp_code               IN  VARCHAR2 DEFAULT '',
	starting_rev_date	IN  DATE DEFAULT SYSDATE - 1000,
	rev_date		IN  VARCHAR2 DEFAULT NULL,
	user_id			IN  NUMBER DEFAULT 0,
        commit_flag             IN  VARCHAR2 DEFAULT 'N',
	err_msg		        IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code	        IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
   	alt_bom_designator      IN  VARCHAR2 DEFAULT NULL
) IS

    stmt_num 		NUMBER;
    X_ReExplode 	boolean := false; -- Re-Explode
    X_PreExploded 	boolean := false; -- Exploded before.
    X_EarlyRevs 	boolean := false; -- Explode earlier revisions
    X_Duplicate 	boolean := false; -- Duplicate explosions
    X_top_bill_id 	NUMBER := -1;
    X_sessn_id		NUMBER;

    X_revision_date		DATE;

    X_no_top_assy		EXCEPTION;
    X_INT_ERROR			EXCEPTION;

    X_exp_past_days		number := 1000;

    -- X_SortWidth	constant number := 7; -- maximum of 9999999 components per bill
    X_SortWidth	constant number := Bom_Common_Definitions.G_Bom_SortCode_Width;

CURSOR get_bill_id IS
SELECT 	bill_sequence_id
FROM 	bom_bill_of_materials
WHERE 	assembly_item_id = ITEM_ID
AND   	organization_id = ORG_ID
AND	alternate_bom_designator is null;

Cursor Convert_Date is
    SELECT 	to_date(nvl(REV_DATE, SYSDATE),'YYYY/MM/DD HH24:MI') rev_datetime
    FROM	sys.dual;

Cursor Check_Flag is
      Select 1
      FROM	bom_explosions be
      WHERE	be.top_bill_sequence_id = X_TOP_BILL_ID
      AND	be.explosion_type = EXPL_TYPE
      and be.rexplode_flag = 1
      and rownum = 1;

Cursor Get_Eff_Date is
	select to_date(to_char(effectivity_date,'YYYY/MM/DD HH24:MI'),'YYYY/MM/DD HH24:MI') effectivity_date
	from bom_explosions
        where top_bill_sequence_id = X_TOP_BILL_ID
        AND explosion_type = EXPL_TYPE
        and sort_order = lpad('1', X_SortWidth, '0');

CURSOR lock_bom IS
	SELECT 	1
	FROM	bom_bill_of_materials bbom
	WHERE 	organization_id = ORG_ID
	AND	assembly_item_id = ITEM_ID
	AND   	alternate_bom_designator is NULL
	FOR UPDATE OF assembly_item_id NOWAIT;

X_Row_Locked 		EXCEPTION;
Pragma exception_init(X_Row_locked, -54);

Cursor Get_New_Group is
	SELECT 	bom_config_explosions_s.nextval group_id
	FROM	sys.dual;

Begin

    error_code  := 0;
    x_sessn_id    := session_id;


    /* Get the date version of the rev_date parameter. */

    --  Bug 4252245
    --  Removed the convert_date cursor call and wrote seperate sql statements
    --  based on rev_date NULL or   NOT NULL values

    /*For X_Date in Convert_Date loop
      x_revision_date := X_Date.rev_datetime;
    End loop;*/

   If rev_date is NOT NULL then
        stmt_num := 10;
        SELECT      to_date(REV_DATE,'YYYY/MM/DD HH24:MI')
        into        x_revision_date
        FROM        sys.dual;
   else
        stmt_num := 20;
        SELECT      to_date(to_char(sysdate,'YYYY/MM/DD HH24:MI'),'YYYY/MM/DD HH24:MI')
        into        x_revision_date
        FROM        sys.dual;
   end if;

    -- Bug 4252245 ends

    -- Get the bill sequence id for the item/org passed in. If a primary
    -- bill does not exist, raise an exception.

    stmt_num := 25;

    For X_Bill in get_bill_id loop
      x_top_bill_id := X_Bill.bill_sequence_id;
    End loop;
    IF x_top_bill_id < 0 THEN
      raise x_no_top_assy;
    END IF;

   -- Check if any rexplode flag is set for the bill in bom_explosions.

   stmt_num := 30;
   For X_Explosion in Check_Flag loop
     X_ReExplode := true;
   End loop;


-- Check if any rows exist in bom_explosions where component is effective
-- before requested date.  If none then set re-explosion flag to ensure it
-- explodes again to cover earlier revisions
--
-- Also check for duplicate explosions.  If duplicate found, then re-explode.
--

   stmt_num := 40;
   For X_Root in Get_Eff_Date loop
     X_PreExploded := true; -- Exploded before.
     If Get_Eff_Date%rowcount > 1 then -- duplicate rows
       X_Duplicate := true; -- Duplicate explosions
       X_ReExplode := true;
       Exit;
     End if;
     If X_Root.effectivity_date > X_revision_date then
       X_EarlyRevs := true; -- Explode earlier revisions
       X_ReExplode := true;
     End if;
   End loop;

   If not X_PreExploded then -- new explosion
     X_ReExplode := true;
   End if;

   If X_ReExplode then
      Begin

      -- Lock the bill header so that two users don't try to create or
      -- re-explode the same bill at the same time. If we can't get a
      -- lock and the bill already exists then just pass all the re-explode
      -- logic (we'll use the existing bom).  If the bom doesn't exist yet,
      -- then raise the x_row_locked exception.

      stmt_num := 50;
      -- For X_Locked_Bill in lock_bom loop

	stmt_num := 60;
        If X_EarlyRevs or X_Duplicate then
	--Added call to Delete_Bom_Expl procedure to avoid deadlock issue and removed earlier delete st
              Delete_Bom_Expl(X_TOP_BILL_ID,EXPL_TYPE);
        End if; -- re-explode entire tree

	stmt_num := 70;

	FND_PROFILE.GET('BOM:OE_EXP_PAST_DAYS',x_exp_past_days);

	/* Call the oe bom exploder to create the non-date specific bom */


	stmt_num := 80;
	BOM_OE_EXPLODER_PKG.be_exploder
	(arg_org_id		=>	org_id,
	arg_starting_rev_date	=>	least(X_revision_date, sysdate -
					nvl(x_exp_past_days,1000)),
	arg_expl_type		=>	expl_type,
	arg_order_by		=>	order_by,
	arg_levels_to_explode 	=>	levels_to_explode,
	arg_item_id		=>	item_id,
	arg_comp_code           =>	comp_code,
	arg_user_id		=>	user_id,
	arg_err_msg		=>	err_msg,
	arg_error_code		=>	error_code,
 	arg_alt_bom_desig       =>      alt_bom_designator);

     --  End loop;

      If (error_code <> 0) then
	 raise X_INT_ERROR;
      end if;

      EXCEPTION
    	When X_Row_Locked then
          If not X_PreExploded then -- new explosion
	    Raise;
   	  End if;
      End; -- exploder nested block

    END IF; -- Re-Explode


    IF (COPY_FLAG = 1) THEN

	-- The procedure is being called from the configurator form, which
	-- needs it's own copy of the bill. Using the master bill, copy
	-- the bill as of the given rev_date into BOM_CONFIG_EXPLOSIONS.
	-- Pass back the group_id of this copy.

      stmt_num := 90;

      For X_Group in Get_New_Group loop


        stmt_num := 100;

	INSERT INTO bom_config_explosions (
 		TOP_BILL_SEQUENCE_ID,
 		BILL_SEQUENCE_ID,
 		ORGANIZATION_ID,
		EXPLOSION_TYPE,
 		COMPONENT_SEQUENCE_ID,
 		COMPONENT_ITEM_ID,
 		PLAN_LEVEL,
 		EXTENDED_QUANTITY,
 		SORT_ORDER,
 		GROUP_ID,
 		SESSION_ID,
 		TOP_ITEM_ID,
 		COMPONENT_QUANTITY,
 		SO_BASIS,
 		OPTIONAL,
 		MUTUALLY_EXCLUSIVE_OPTIONS,
 		CHECK_ATP,
 		SHIPPING_ALLOWED,
 		REQUIRED_TO_SHIP,
 		REQUIRED_FOR_REVENUE,
 		INCLUDE_ON_SHIP_DOCS,
 		INCLUDE_ON_BILL_DOCS,
 		LOW_QUANTITY,
 		HIGH_QUANTITY,
 		PICK_COMPONENTS,
 		PRIMARY_UOM_CODE,
 		PRIMARY_UNIT_OF_MEASURE,
 		BASE_ITEM_ID,
 		ATP_COMPONENTS_FLAG,
 		ATP_FLAG,
 		BOM_ITEM_TYPE,
 		PICK_COMPONENTS_FLAG,
 		REPLENISH_TO_ORDER_FLAG,
 		SHIPPABLE_ITEM_FLAG,
 		CUSTOMER_ORDER_FLAG,
 		INTERNAL_ORDER_FLAG,
 		CUSTOMER_ORDER_ENABLED_FLAG,
 		INTERNAL_ORDER_ENABLED_FLAG,
 		SO_TRANSACTIONS_FLAG,
 		DESCRIPTION,
 		ASSEMBLY_ITEM_ID,
 		CONFIGURATOR_FLAG,
  		COMPONENT_CODE,
 		LOOP_FLAG,
 		PARENT_BOM_ITEM_TYPE,
                OPERATION_SEQ_NUM,
                ITEM_NUM,
 		EFFECTIVITY_DATE,
 		DISABLE_DATE,
 		IMPLEMENTATION_DATE,
 		REXPLODE_FLAG,
 		COMMON_BILL_SEQUENCE_ID)
	SELECT
 		TOP_BILL_SEQUENCE_ID,
 		BILL_SEQUENCE_ID,
 		ORGANIZATION_ID,
 		expl_type,
		COMPONENT_SEQUENCE_ID,
 		COMPONENT_ITEM_ID,
 		PLAN_LEVEL,
 		EXTENDED_QUANTITY,
 		SORT_ORDER,
 		X_Group.group_id,
 		x_sessn_id,
 		TOP_ITEM_ID,
  		COMPONENT_QUANTITY,
 		SO_BASIS,
 		OPTIONAL,
 		MUTUALLY_EXCLUSIVE_OPTIONS,
 		CHECK_ATP,
 		SHIPPING_ALLOWED,
 		REQUIRED_TO_SHIP,
 		REQUIRED_FOR_REVENUE,
 		INCLUDE_ON_SHIP_DOCS,
 		INCLUDE_ON_BILL_DOCS,
 		LOW_QUANTITY,
 		HIGH_QUANTITY,
 		PICK_COMPONENTS,
 		PRIMARY_UOM_CODE,
 		PRIMARY_UNIT_OF_MEASURE,
 		BASE_ITEM_ID,
 		ATP_COMPONENTS_FLAG,
 		ATP_FLAG,
 		BOM_ITEM_TYPE,
 		PICK_COMPONENTS_FLAG,
 		REPLENISH_TO_ORDER_FLAG,
 		SHIPPABLE_ITEM_FLAG,
 		CUSTOMER_ORDER_FLAG,
 		INTERNAL_ORDER_FLAG,
 		CUSTOMER_ORDER_ENABLED_FLAG,
 		INTERNAL_ORDER_ENABLED_FLAG,
 		SO_TRANSACTIONS_FLAG,
 		DESCRIPTION,
 		ASSEMBLY_ITEM_ID,
 		'Y',
 		COMPONENT_CODE,
 		LOOP_FLAG,
 		PARENT_BOM_ITEM_TYPE,
                OPERATION_SEQ_NUM,
		ITEM_NUM,
 		EFFECTIVITY_DATE,
 		DISABLE_DATE,
 		IMPLEMENTATION_DATE,
 		REXPLODE_FLAG,
 		COMMON_BILL_SEQUENCE_ID
	FROM 	bom_explosions
	WHERE	top_bill_sequence_id = X_TOP_BILL_ID
	AND	explosion_type = EXPL_TYPE
	AND	plan_level > 0
	AND	effectivity_date <= X_REVISION_DATE
	AND	disable_date >  X_REVISION_DATE;

	grp_id := X_Group.group_id;

      End loop;

    ELSE

	grp_id := 0;

    END IF; -- (COPY_FLAG = 1)

    IF commit_flag = 'Y' then
       commit;
    END IF;

    error_code := 0;
    err_msg := '';

EXCEPTION
    When X_Row_Locked then
	FND_MESSAGE.set_name('BOM','BOM_CHANGES_IN_PROCESS');
        err_msg := fnd_message.get;
	error_code := -54;
    when X_INT_ERROR then
	NULL;
    WHEN x_no_top_assy THEN
	error_code 	:= 9998;
	FND_MESSAGE.Set_Name('BOM', 'BOM_BILL_DOES_NOT_EXIST');
        err_msg := FND_MESSAGE.GET;
    when others then
        err_msg := 'BOMPNORD(' || stmt_num || ')' || substrb(SQLERRM, 1, 60);
        error_code := SQLCODE;
END bmxporder_explode_for_order;

END bompnord;

/
