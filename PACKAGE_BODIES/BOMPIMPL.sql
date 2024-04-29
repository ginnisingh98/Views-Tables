--------------------------------------------------------
--  DDL for Package Body BOMPIMPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPIMPL" as
/* $Header: BOMIMPLB.pls 120.1.12010000.4 2010/01/29 13:26:04 rvalsan ship $ */
PROCEDURE imploder_userexit(
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	display_option		IN  NUMBER,
	levels_to_implode	IN  NUMBER,
	item_id			IN  NUMBER,
	impl_date		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	err_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER) AS

    a_err_msg		VARCHAR2(80);
    a_err_code		NUMBER;

BEGIN

    INSERT INTO BOM_IMPLOSION_TEMP
        ( SEQUENCE_ID,
          LOWEST_ITEM_ID,
          CURRENT_ITEM_ID,
          PARENT_ITEM_ID,
          ALTERNATE_DESIGNATOR,
          CURRENT_LEVEL,
          SORT_CODE,
          CURRENT_ASSEMBLY_TYPE,
          COMPONENT_SEQUENCE_ID,
          ORGANIZATION_ID,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  CREATED_BY)
    VALUES (sequence_id,
	   item_id,
	   item_id,
	   item_id,
	   NULL,
	   0,
--	   '0000001',
	   Bom_Common_Definitions.G_Bom_Init_SortCode,
	   NULL,
	   NULL,
	   org_id,
	   sysdate,
	   -1,
	   sysdate,
	   -1);

    bompimpl.implosion(sequence_id, eng_mfg_flag, org_id, impl_flag,
	display_option, levels_to_implode, impl_date, a_err_msg, a_err_code);

    err_msg		:= a_err_msg;
    err_code		:= a_err_code;

    if (a_err_code <> 0) then
	ROLLBACK;
    end if;

EXCEPTION
    WHEN OTHERS THEN
	err_msg		:= substrb(SQLERRM, 1, 80);
	err_code	:= SQLCODE;
	ROLLBACK;
END imploder_userexit;

PROCEDURE implosion(
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	display_option		IN  NUMBER,
	levels_to_implode	IN  NUMBER,
	impl_date		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	err_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER) AS

    implosion_date		VARCHAR2(25);
    error_msg			VARCHAR(80);
    error_code			NUMBER;

BEGIN
--    implosion_date	:= substr(impl_date, 1, 16);
    implosion_date	:= impl_date;

    if levels_to_implode = 1 then
     	sl_imploder(sequence_id, eng_mfg_flag, org_id, impl_flag,
		display_option, implosion_date, error_msg, error_code);
    else
     	ml_imploder(sequence_id, eng_mfg_flag, org_id, impl_flag,
		levels_to_implode, implosion_date, error_msg, error_code);
    end if;

    err_msg	:= error_msg;
    err_code	:= error_code;

    if (error_code <> 0) then
	ROLLBACK;
    end if;

EXCEPTION
    WHEN OTHERS THEN
	err_msg		:= error_msg;
	err_code	:= error_code;
	ROLLBACK;
END implosion;

PROCEDURE sl_imploder (
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	display_option		IN  NUMBER,
	impl_date		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER) AS

    total_rows			NUMBER;
    cat_sort			VARCHAR2(7);

    --
    -- bug 8470695
    -- Modified the hint and added extra where clause
    -- to make the query selective
    --
    CURSOR imploder (c_sequence_id NUMBER,
		c_eng_mfg_flag NUMBER, c_org_id NUMBER,
		c_display_option NUMBER,
		c_implosion_date VARCHAR2, c_implemented_only_option NUMBER
		) IS
        SELECT   /*bug fix 9139520 removed the hint created for bug 8470695*/
		 BITT.LOWEST_ITEM_ID LID,
                 BITT.PARENT_ITEM_ID PID,
                 BBM.ASSEMBLY_ITEM_ID AID,
                 BBM.ALTERNATE_BOM_DESIGNATOR ABD,
                 BITT.SORT_CODE SC,
                 BITT.LOWEST_ALTERNATE_DESIGNATOR LAD,
		 BBM.ASSEMBLY_TYPE CAT,
		 BIC.COMPONENT_SEQUENCE_ID CSI,
      		 BIC.OPERATION_SEQ_NUM OSN,
      		 BIC.EFFECTIVITY_DATE ED,
      		 BIC.DISABLE_DATE DD,
      		 BIC.BASIS_TYPE BT,
      		 BIC.COMPONENT_QUANTITY CQ,
		 BIC.REVISED_ITEM_SEQUENCE_ID RISD,
		 BIC.CHANGE_NOTICE CN,
		 DECODE(BIC.IMPLEMENTATION_DATE, NULL, 2, 1) IMPF,
		 BBM.ORGANIZATION_ID OI
        FROM
		BOM_IMPLOSION_TEMP BITT,
                BOM_INVENTORY_COMPONENTS BIC,
                BOM_BILL_OF_MATERIALS BBM
	where bic.pk1_value = BITT.PARENT_ITEM_ID                                   -- 8470695
	and   bic.pk2_value = NVL(bbm.common_organization_id, bbm.organization_id)  -- 8470695
	and   bitt.current_level = 0
	and   bitt.organization_id = c_org_id
	and   bitt.sequence_id = c_sequence_id
	and   bitt.parent_item_id = bic.component_item_id
	and   bic.bill_sequence_id = bbm.common_bill_sequence_id
	and   bbm.organization_id = c_org_id
	and   NVL(bic.ECO_FOR_PRODUCTION,2) = 2
	and   (
       		( c_eng_mfg_flag = 1
        	      and bbm.assembly_type = 1
		) /* get only Mfg boms */
        	or
        	(c_eng_mfg_flag = 2
		) /*both Mfg-Eng BOMs in ENG mode*/
	      ) /* end of entire and predicate */
	and (
	      (nvl(bbm.alternate_bom_designator,'none') = /*Pickup match par*/
          		nvl(bitt.lowest_alternate_designator,'none')
     	      )
     	      or /* Pickup par with spec alt only, if start alt is null,*/
	      ( bitt.lowest_alternate_designator is null /*and bill with spec*/
      		and bbm.alternate_bom_designator is not null
						/* alt doesnt exist */
      		and not exists (select NULL     /*for current item */
                      from bom_bill_of_materials bbm2
                      where bbm2.organization_id = c_org_id
                      and   bbm2.assembly_item_id = bitt.parent_item_id
                      and   bbm2.alternate_bom_designator =
                                bbm.alternate_bom_designator
                      and (
                           (bitt.current_assembly_type = 1
                            and bbm2.assembly_type = 1)
                           or
                           (bitt.current_assembly_type = 2)
                          )
                     ) /* end of subquery */
     	      ) /* end of parent with specific alt */
 	      or /* Pickup prim par only if start alt is not null and bill 4*/
 	      ( bitt.lowest_alternate_designator is not null
						/* same par doesnt */
      		and bbm.alternate_bom_designator is null
						/* exist with this alt */
      		and not exists (select NULL
                      from bom_bill_of_materials bbm2
                      where bbm2.organization_id = c_org_id
                      and   bbm2.assembly_item_id = bbm.assembly_item_id
                      and   bbm2.alternate_bom_designator =
                                bitt.lowest_alternate_designator
                      and (
                           (bitt.current_assembly_type = 1
                            and bbm2.assembly_type = 1)
                           or
                           (bitt.current_assembly_type = 2)
                          )
                     ) /* end of subquery */
     	      ) /* end of parent with null alt */
     	    )/* end of all alternate logic */
	and ( /* start of all display options */
     	      ( c_display_option = 2
      		and bic.effectivity_date
         		<= to_date (c_implosion_date, 'YYYY/MM/DD HH24:MI:SS')
      		and  ( bic.disable_date is null
            	       or bic.disable_date >
                	  to_date (c_implosion_date, 'YYYY/MM/DD HH24:MI:SS')
            	     )
     	      ) /* end of CURRENT */
     	      or
     	      c_display_option = 1
     	      or
     	      ( c_display_option = 3
      		and ( bic.disable_date is null
            	      or bic.disable_date >
                   	    to_date (c_implosion_date, 'YYYY/MM/DD HH24:MI:SS')
            	    )
     	      ) /* end of CURRENT_AND_FUTURE */
    	    ) /* end of all display options */
	and ( /* start of implemented yes/no logic */
     	      ( c_implemented_only_option = 1
      		and bic.implementation_date is not null
     	      )
     	      or
     	      ( c_implemented_only_option = 2
      		and ( /* start of all display */
            	( c_display_option = 2
              	  and
              	  bic.effectivity_date =
                	(select max(effectivity_date)
                 	    from bom_inventory_components bic2
                 	    where bic2.bill_sequence_id = bic.bill_sequence_id
                 	    and  bic2.component_item_id = bic.component_item_id
			    and   NVL(bic2.ECO_FOR_PRODUCTION,2) = 2
                 	    and   decode(bic.implementation_date, NULL,
                          	bic.old_component_sequence_id,
                          	bic.component_sequence_id) =
                        	decode(bic2.implementation_date, NULL,
                          	bic2.old_component_sequence_id,
                          	bic2.component_sequence_id)
                 	    and bic2.effectivity_date <=
					to_date(c_implosion_date,
                                                'YYYY/MM/DD HH24:MI:SS')
			   --* AND Clause added for Bug 3085543
			    and NOT EXISTS (SELECT null
			                  FROM bom_inventory_components bic3
                                         WHERE bic3.bill_sequence_id =
					       bic.bill_sequence_id
					   AND bic3.old_component_sequence_id =
					       bic.component_sequence_id
			                   AND NVL(BIC3.ECO_FOR_PRODUCTION,2)= 2
					   AND bic3.acd_type in (2,3)
					   AND bic3.disable_date <=
                                               to_date(c_implosion_date,
						       'YYYY/MM/DD HH24:MI:SS'))
			   --* End of Bug 3085543
                 	    and ( bic2.disable_date >
					to_date(c_implosion_date,
                                                'YYYY/MM/DD HH24:MI:SS')
				  or bic2.disable_date is null )
                	) /* end of subquery */
                ) /* end of CURRENT */
          	or
            	( c_display_option = 3
             	  and bic.effectivity_date =
                	(select max(effectivity_date)
                 	    from bom_inventory_components bic2
                 	    where bic2.bill_sequence_id = bic.bill_sequence_id
                 	    and  bic2.component_item_id = bic.component_item_id
			    and   NVL(bic2.ECO_FOR_PRODUCTION,2) = 2
                 	    and   nvl(bic2.old_component_sequence_id,
                                bic2.component_sequence_id) =
                          	nvl(bic.old_component_sequence_id,
                                bic.component_sequence_id)
                 	    and bic2.effectivity_date <=
					to_date(c_implosion_date,
                                                'YYYY/MM/DD HH24:MI:SS')
			    --* AND Clause added for Bug - 3155946
			    AND NOT EXISTS ( SELECT Null
			    		     FROM   Bom_Inventory_Components bic4
					     WHERE  bic4.bill_sequence_id =
					     	    bic.bill_sequence_id
					     AND    bic4.old_component_sequence_id =
					     	    bic.component_sequence_id
					     AND    Nvl(bic4.eco_for_production,2) = 2
					     AND    bic4.acd_type in (2,3)
					     AND    bic4.disable_date <=
					            to_date(c_implosion_date,
						    'YYYY/MM/DD HH24:MI:SS') )
			    --* End of Bug - 3155946
                	    and ( bic2.disable_date >
					to_date(c_implosion_date,
                                                'YYYY/MM/DD HH24:MI:SS')
                        	  or bic2.disable_date is null )
                	) /* end of subquery */
              		or
			bic.effectivity_date > to_date(c_implosion_date,
                                                'YYYY/MM/DD HH24:MI:SS')
                 ) /* end of current and future */
          	 or
            	 ( c_display_option = 1)
      	       ) /* end of all display */
     	     ) /* end of impl = no */
    	   ) /* end of impl = yes-no */
	   order by bitt.parent_item_id,
		    bbm.assembly_item_id, bic.operation_seq_num;
  Cursor Check_Configured_Parent(
    P_Parent_Item in number,
    P_Comp_Item in number) is
      Select 1 dummy
      From mtl_system_items msi1,
           mtl_system_items msi2
      Where msi1.inventory_item_id = P_Parent_Item
      And   msi1.organization_id = org_id
      And   msi2.inventory_item_id = P_Comp_Item
      And   msi2.organization_id = org_id
      And   msi1.bom_item_type = 4 -- Standard
      And   msi1.replenish_to_order_flag = 'Y'
      And   msi1.base_item_id is not null -- configured item
      And   msi2.bom_item_type in (1, 2); -- model or option class
  Cursor Check_Disabled_Parent(
    P_Parent_Item in number) is
      Select 1 dummy
      From mtl_system_items msi
      Where msi.inventory_item_id = P_Parent_Item
      And   msi.organization_id = org_id
      And   msi.bom_enabled_flag = 'N';
  Prune_Tree exception;

BEGIN

	total_rows	:= 0;

	FOR impl_row in imploder(sequence_id,
		eng_mfg_flag, org_id, display_option,
		impl_date, impl_flag) LOOP
	Begin
	    IF imploder%NOTFOUND THEN
		goto done_imploding;
   	    END IF;

	    /*
            For X_Item_Attributes in Check_Configured_Parent(
              P_Parent_Item => impl_row.aid,
              P_Comp_Item => impl_row.pid) loop
                Raise Prune_Tree;
            End loop;
	    */

            For X_Item_Attributes in Check_Disabled_Parent(
              P_Parent_Item => impl_row.aid) loop
                Raise Prune_Tree;
            End loop;

	    impl_row.LAD	:= impl_row.ABD;

	    total_rows	:= total_rows + 1;

	    -- cat_sort	:= lpad(total_rows, 7, '0');
	    cat_sort	:= lpad(total_rows, Bom_Common_Definitions.G_Bom_SortCode_Width, '0');

	    impl_row.SC	:= impl_row.SC || cat_sort;

	    INSERT INTO BOM_IMPLOSION_TEMP
		(LOWEST_ITEM_ID,
		 CURRENT_ITEM_ID,
		 PARENT_ITEM_ID,
		 ALTERNATE_DESIGNATOR,
		 CURRENT_LEVEL,
		 SORT_CODE,
		 LOWEST_ALTERNATE_DESIGNATOR,
		 CURRENT_ASSEMBLY_TYPE,
		 SEQUENCE_ID,
		 COMPONENT_SEQUENCE_ID,
		 ORGANIZATION_ID,
       		 OPERATION_SEQ_NUM,
      		 EFFECTIVITY_DATE,
      		 DISABLE_DATE,
      		 BASIS_TYPE,
      		 COMPONENT_QUANTITY,
		 REVISED_ITEM_SEQUENCE_ID,
		 CHANGE_NOTICE,
		 IMPLEMENTED_FLAG,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY) VALUES (
		impl_row.LID,
		impl_row.PID,
		impl_row.AID,
		impl_row.ABD,
		1,
		impl_row.SC,
		impl_row.LAD,
		impl_row.CAT,
		sequence_id,
		impl_row.CSI,
		impl_row.OI,
		impl_row.OSN,
		impl_row.ED,
		impl_row.DD,
		impl_row.BT,
		impl_row.CQ,
		impl_row.RISD,
		impl_row.CN,
	        impl_row.IMPF,
		sysdate,
		-1,
		sysdate,
		-1);
              Exception
                When Prune_Tree then
                  null;
              End; -- row
	    end loop;		/* cursor fetch loop */

<<done_imploding>>
    error_code	:= 0;
/*
** exception handlers
*/
EXCEPTION
    WHEN OTHERS THEN
        error_code      := SQLCODE;
        err_msg         := substrb(SQLERRM, 1, 80);
END sl_imploder;

PROCEDURE ml_imploder(
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	a_levels_to_implode	IN  NUMBER,
	impl_date		IN  VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code 	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER) AS

    prev_parent_item_id		NUMBER;
    cum_count			NUMBER;
    cur_level			NUMBER;
    total_rows			NUMBER;
    levels_to_implode		NUMBER;
    max_level			NUMBER;
    cat_sort			VARCHAR2(7);
    max_extents			EXCEPTION;

/*
** max extents exceeded exception
*/
    PRAGMA EXCEPTION_INIT(max_extents, -1631);

    --
    -- bug 8470695
    -- Modified the hint and added extra where clause
    -- to make the query selective
    --
    CURSOR imploder (c_current_level NUMBER, c_sequence_id NUMBER,
		c_eng_mfg_flag NUMBER, c_org_id NUMBER,
		c_implosion_date VARCHAR2, c_implemented_only_option NUMBER
		) IS
       	SELECT /*Bug fix 9139520 removed the index created for bug 8470695*/
	       BITT.LOWEST_ITEM_ID LID,
               BITT.PARENT_ITEM_ID PID,
               BBM.ASSEMBLY_ITEM_ID AID,
               BBM.ALTERNATE_BOM_DESIGNATOR ABD,
               BITT.SORT_CODE SC,
               BITT.LOWEST_ALTERNATE_DESIGNATOR LAD,
	       BBM.ASSEMBLY_TYPE CAT,
	       BIC.COMPONENT_SEQUENCE_ID CSI,
      	       BIC.OPERATION_SEQ_NUM OSN,
      	       BIC.EFFECTIVITY_DATE ED,
               BIC.DISABLE_DATE DD,
      	       BIC.BASIS_TYPE BT,
      	       BIC.COMPONENT_QUANTITY CQ,
	       BIC.REVISED_ITEM_SEQUENCE_ID RISD,
	       BIC.CHANGE_NOTICE CN,
	       DECODE(BIC.IMPLEMENTATION_DATE, NULL, 2, 1) IMPF,
	       BBM.ORGANIZATION_ID OI
	FROM
		BOM_IMPLOSION_TEMP BITT,
                BOM_INVENTORY_COMPONENTS BIC,
                BOM_BILL_OF_MATERIALS BBM
	where bic.pk1_value = BITT.PARENT_ITEM_ID
        and bic.pk2_value   = NVL(bbm.common_organization_id, bbm.organization_id)
	and bitt.current_level = c_current_level
	and bitt.organization_id = c_org_id
	and bitt.sequence_id = c_sequence_id
	and bitt.parent_item_id = bic.component_item_id
	and bic.bill_sequence_id = bbm.common_bill_sequence_id
	and bbm.organization_id = c_org_id
	and NVL(BIC.ECO_FOR_PRODUCTION,2) = 2
	and (
	      ( c_current_level = 0
                and
                ( (c_eng_mfg_flag = 1
                    and bbm.assembly_type = 1
		  ) /* get only Mfg boms */
                  or
                  (c_eng_mfg_flag = 2
		  ) /*both Mfg-Eng BOMs in ENG mode*/
                ) /* eng or mfg */
              ) /* end of current_level = 0 */
              or
              ( c_current_level <> 0
                and
                ( (bitt.current_assembly_type = 1
                   and bbm.assembly_type = 1
				   and c_eng_mfg_flag = 1
	          )
                  or
                  (c_eng_mfg_flag = 2
		  )
                ) /* eng or mfg */
              ) /* end of current level <> 0 */
            ) /* end of entire and predicate */
	and ( c_current_level = 0
	      or   /* start of all alternate logic */
              ( nvl(bbm.alternate_bom_designator,'none') =
          		nvl(bitt.lowest_alternate_designator,'none')
              )
              or /* Pickup par with spec alt only, if start alt is null,*/
              ( bitt.lowest_alternate_designator is null
                and bbm.alternate_bom_designator is not null
						/* alt doesnt exist */
                and not exists (select NULL     /*for current item */
                      from bom_bill_of_materials bbm2
                      where bbm2.organization_id = c_org_id
                      and   bbm2.assembly_item_id = bitt.parent_item_id
                      and   bbm2.alternate_bom_designator =
                                bbm.alternate_bom_designator
                      and (
                           (bitt.current_assembly_type = 1
                            and bbm2.assembly_type = 1
							and c_eng_mfg_flag = 1)
                           or
                           (c_eng_mfg_flag = 2)
                          )
                     ) /* end of subquery */
              ) /* end of parent with specific alt */
              or /* Pickup prim par only if starting alt is not
			null and bill for .. */
              (bitt.lowest_alternate_designator is not null
				/* .. same par doesnt */
               and bbm.alternate_bom_designator is null
				/* .. exist with this alt */
      	       and not exists (select NULL
                      from bom_bill_of_materials bbm2
                      where bbm2.organization_id = c_org_id
                      and   bbm2.assembly_item_id = bbm.assembly_item_id
                      and   bbm2.alternate_bom_designator =
                                bitt.lowest_alternate_designator
                      and (
                           (bitt.current_assembly_type = 1
                            and bbm2.assembly_type = 1
							and c_eng_mfg_flag = 1)
                           or
                           (c_eng_mfg_flag = 2)
                          )
                     ) /* end of subquery */
              ) /* end of parent with null alt */
            )/* end of all alternate logic */
	and bic.effectivity_date <= to_date(c_implosion_date,
			'YYYY/MM/DD HH24:MI:SS')
	and ( bic.disable_date is null
              or
              bic.disable_date > to_date(c_implosion_date, 'YYYY/MM/DD HH24:MI:SS')
            )
	and ( /* start of implemented yes-no logic */
              ( c_implemented_only_option = 1
                and bic.implementation_date is not null
              )
              or
              ( c_implemented_only_option = 2
      	 	and bic.effectivity_date =
        	  (select max(effectivity_date)
           		from bom_inventory_components bic2
           		where bic.bill_sequence_id = bic2.bill_sequence_id
           		and   bic.component_item_id = bic2.component_item_id
			and   NVL(bic2.ECO_FOR_PRODUCTION,2) = 2
           		and   decode(bic.implementation_date, NULL,
                        	bic.old_component_sequence_id,
                        	bic.component_sequence_id) =
                    	      decode(bic2.implementation_date, NULL,
                          	bic2.old_component_sequence_id,
                          	bic2.component_sequence_id)
           		and   bic2.effectivity_date <= to_date(c_implosion_date,
                                                'YYYY/MM/DD HH24:MI:SS')
			--* AND Clause added for Bug 3085543
			and NOT EXISTS (SELECT null
			                  FROM bom_inventory_components bic3
                                         WHERE bic3.bill_sequence_id =
					       bic.bill_sequence_id
					   AND bic3.old_component_sequence_id =
					       bic.component_sequence_id
	                                   and NVL(BIC3.ECO_FOR_PRODUCTION,2)= 2
					   AND bic3.acd_type in (2,3)
					   AND bic3.disable_date <= to_date(c_implosion_date,'YYYY/MM/DD HH24:MI:SS'))
			--* End of Bug 3085543
           		and   ( bic2.disable_date is null
                                or
                  		( bic2.disable_date is not null
                   		  and bic2.disable_date >
					to_date(c_implosion_date,
                                                 'YYYY/MM/DD HH24:MI:SS')
                        	)
                       	      )
                  ) /* end of select (max) */
              ) /* end of impl_only = no */
   	    ) /* end of implemented yes-no logic */
	order by bitt.parent_item_id,
		bbm.assembly_item_id, bic.operation_seq_num;
  Cursor Check_Configured_Parent(
    P_Parent_Item in number,
    P_Comp_Item in number) is
      Select 1 dummy
      From mtl_system_items msi1,
           mtl_system_items msi2
      Where msi1.inventory_item_id = P_Parent_Item
      And   msi1.organization_id = org_id
      And   msi2.inventory_item_id = P_Comp_Item
      And   msi2.organization_id = org_id
      And   msi1.bom_item_type = 4 -- Standard
      And   msi1.replenish_to_order_flag = 'Y'
      And   msi1.base_item_id is not null -- configured item
      And   msi2.bom_item_type in (1, 2); -- model or option class
  Cursor Check_Disabled_Parent(
    P_Parent_Item in number) is
      Select 1 dummy
      From mtl_system_items msi
      Where msi.inventory_item_id = P_Parent_Item
      And   msi.organization_id = org_id
      And   msi.bom_enabled_flag = 'N';
  Prune_Tree exception;
BEGIN

    SELECT max(MAXIMUM_BOM_LEVEL)
	INTO max_level
	FROM BOM_PARAMETERS
	WHERE ORGANIZATION_ID = org_id;

    IF SQL%NOTFOUND or max_level is null THEN
	max_level 	:= 60;
    END IF;

    levels_to_implode	:= a_levels_to_implode;

    IF (levels_to_implode < 0 OR levels_to_implode > max_level) THEN
	levels_to_implode 	:= max_level;
    END IF;

    cur_level	:= 0;		/* initialize level */

    WHILE (cur_level < levels_to_implode) LOOP

	total_rows	:= 0;
	cum_count	:= 0;

	FOR impl_row in imploder (cur_level, sequence_id,
		eng_mfg_flag, org_id, impl_date, impl_flag) LOOP
        Begin

	    IF imploder%NOTFOUND THEN
		goto no_more_rows;
   	    END IF;

	    if (cur_level >=1)
	    then
               For X_Item_Attributes in Check_Configured_Parent(
                                         P_Parent_Item => impl_row.aid,
                                         P_Comp_Item => impl_row.pid) loop
                    Raise Prune_Tree;
                End loop;
	    end if;

            For X_Item_Attributes in Check_Disabled_Parent(
              P_Parent_Item => impl_row.aid) loop
                Raise Prune_Tree;
            End loop;

	    IF cur_level = 0 THEN
		impl_row.LAD	:= impl_row.ABD;
 	    END IF;

	    total_rows	:= total_rows + 1;

	    IF (cum_count = 0) THEN
		prev_parent_item_id	:= impl_row.PID;
	    END IF;

	    IF (prev_parent_item_id <> impl_row.PID) THEN
		cum_count		:= 0;
		prev_parent_item_id	:= impl_row.PID;
	    END IF;

	    cum_count	:= cum_count + 1;

	    -- cat_sort	:= lpad(cum_count, 7, '0');
	    cat_sort	:= lpad(cum_count, Bom_Common_Definitions.G_Bom_SortCode_Width, '0');

	    impl_row.SC	:= impl_row.SC || cat_sort;

	    INSERT INTO BOM_IMPLOSION_TEMP
		(LOWEST_ITEM_ID,
		 CURRENT_ITEM_ID,
		 PARENT_ITEM_ID,
		 ALTERNATE_DESIGNATOR,
		 CURRENT_LEVEL,
		 SORT_CODE,
		 LOWEST_ALTERNATE_DESIGNATOR,
		 CURRENT_ASSEMBLY_TYPE,
		 SEQUENCE_ID,
		 COMPONENT_SEQUENCE_ID,
		 ORGANIZATION_ID,
		 REVISED_ITEM_SEQUENCE_ID,
		 CHANGE_NOTICE,
       		 OPERATION_SEQ_NUM,
      		 EFFECTIVITY_DATE,
      		 DISABLE_DATE,
      		 BASIS_TYPE,
      		 COMPONENT_QUANTITY,
		 IMPLEMENTED_FLAG,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY) VALUES (
		impl_row.LID,
		impl_row.PID,
		impl_row.AID,
		impl_row.ABD,
		cur_level + 1,
		impl_row.SC,
		impl_row.LAD,
		impl_row.CAT,
		sequence_id,
		impl_row.CSI,
		impl_row.OI,
		impl_row.RISD,
		impl_row.CN,
		impl_row.OSN,
		impl_row.ED,
		impl_row.DD,
		impl_row.BT,
		impl_row.CQ,
		impl_row.IMPF,
		sysdate,
		-1,
		sysdate,
		-1);
              Exception
                When Prune_tree then
                  null;
              End; -- row
	    end loop;		/* cursor fetch loop */

<<no_more_rows>>
	    IF (total_rows <> 0) THEN
		cur_level	:= cur_level + 1;
	    ELSE
		goto done_imploding;
	    END IF;

	END LOOP;		/* while levels */

<<done_imploding>>
    error_code	:= 0;
/*
** exception handlers
*/
EXCEPTION
    WHEN max_extents THEN
	error_code	:= SQLCODE;
	err_msg		:= substrb(SQLERRM, 1, 80);
    WHEN OTHERS THEN
        error_code      := SQLCODE;
        err_msg         := substrb(SQLERRM, 1, 80);
END ml_imploder;

END bompimpl;

/
