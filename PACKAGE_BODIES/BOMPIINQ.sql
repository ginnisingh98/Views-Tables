--------------------------------------------------------
--  DDL for Package Body BOMPIINQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPIINQ" as
/* $Header: BOMIINQB.pls 120.3.12010000.2 2009/03/26 06:12:51 ntungare ship $ */

/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPIINQ.sql                                               |
| DESCRIPTION  : This file is a packaged procedure for the imploders.
|                This package contains 2 different imploders for the
|                single level and multi level implosion. The package
|                imploders calls the correct imploder based on the
|		 # of levels to implode.
| Parameters:   org_id          organization_id
|               sequence_id     unique value to identify current implosion
|                               use value from sequence bom_small_impl_temp_s
|               levels_to_implode
|               eng_mfg_flag    1 - BOM
|                               2 - ENG
|               impl_flag       1 - implemented only
|                               2 - both impl and unimpl
|               display_option  1 - All
|                               2 - Current
|                               3 - Current and future
|               item_id         item id of asembly to explode
|               impl_date       explosion date dd-mon-rr hh24:mi
|               err_msg         error message out buffer
|               error_code      error code out.  returns sql error code
|                               if sql error, 9999 if loop detected.
|		organization_option
|				1 - Current Organization
|				2 - Organization Hierarchy
|				3 - All Organizations to which access is allowed
|		organization_hierarchy
|				Organization Hierarchy Name
+==========================================================================*/
PROCEDURE imploder_userexit(
	sequence_id		IN  NUMBER,
	eng_mfg_flag		IN  NUMBER,
	org_id			IN  NUMBER,
	impl_flag		IN  NUMBER,
	display_option		IN  NUMBER,
	levels_to_implode	IN  NUMBER,
	item_id			IN  NUMBER,
	impl_date		IN  VARCHAR2,
	unit_number_from    	IN  VARCHAR2,
	unit_number_to		IN  VARCHAR2,
	err_msg			IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	err_code 		IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
        organization_option     IN  NUMBER default 1,
        organization_hierarchy  IN  VARCHAR2 default NULL,
        serial_number_from      IN VARCHAR2 default NULL,
        serial_number_to        IN VARCHAR2 default NULL) AS

	a_err_msg		VARCHAR2(80);
	a_err_code		NUMBER;
	t_org_code_list INV_OrgHierarchy_PVT.OrgID_tbl_type;
	N                   NUMBER:=0;
	dummy               NUMBER;
	l_org_name	VARCHAR2(60);
	item_found		BOOLEAN:=TRUE;
	l_master_org_for_current_org	NUMBER;
	l_master_org		NUMBER;

	CURSOR  c_master_org(c_organization_id NUMBER) IS
	 SELECT MASTER_ORGANIZATION_ID L_MASTER_ORG
	 FROM MTL_PARAMETERS
	 WHERE ORGANIZATION_ID = c_organization_id;


BEGIN

	/* If the parameter :
	Organization_Option = 1 then
		Take the current Organization
	else If Organization_Option = 2 is passed then
		Call the Inventory API to get the list of Organizations
		under the current Organization Hierarchy
        else if Organization Option = 3 is passed then
		Find the list of all the Organizations to which
		access is allowed */

	if ( organization_option =2  ) then

     /*		SELECT organization_name into l_org_name
		FROM   org_organization_definitions
		WHERE  organization_id = org_id;
      */

	/* In case of an org hierarchy, make sure that for those orgs that
	  have a master org different from the master org of the current org
	  are not considered.*/

	    --get the master org id for the current org
             OPEN c_master_org(org_id);
	     FETCH c_master_org into l_master_org_for_current_org;
	     CLOSE c_master_org;

  	     INV_ORGHIERARCHY_PVT.ORG_HIERARCHY_LIST(organization_hierarchy ,
		org_id ,t_org_code_list );

	elsif ( organization_option = 3 ) then
/* Bug:4929268 Performance Fix */
		for C1 in (  SELECT orgs.ORGANIZATION_ID
                             FROM ORG_ACCESS_VIEW oav,  MTL_SYSTEM_ITEMS_B msi,
				  MTL_PARAMETERS orgs,  MTL_PARAMETERS child_org
			     WHERE orgs.ORGANIZATION_ID = oav.ORGANIZATION_ID
		             AND msi.ORGANIZATION_ID = orgs.ORGANIZATION_ID
		             AND orgs.MASTER_ORGANIZATION_ID =  child_org.MASTER_ORGANIZATION_ID
		             AND oav.RESPONSIBILITY_ID = FND_PROFILE.Value('RESP_ID')
		             AND oav.RESP_APPLICATION_ID =  FND_PROFILE.value('RESP_APPL_ID')
		             AND msi.INVENTORY_ITEM_ID = item_id
		             AND child_org.ORGANIZATION_ID = org_id
			)
		LOOP
			N:=N+1;
			t_org_code_list(N) := C1.organization_id;
		END LOOP;
	elsif
		( organization_option = 1 ) then
		t_org_code_list(1) := org_id;
	end if;

	FOR I in t_org_code_list.FIRST..t_org_code_list.LAST LOOP

	/*In case of org hierarchy check if the org at current index is a
	child of the master org of the current org. If it is, continue as
	normal otherwise skip to end of loop*/

	if ( organization_option = 2 ) THEN
	OPEN c_master_org(t_org_code_list(I));
	FETCH c_master_org into l_master_org;
	CLOSE c_master_org;
	end if;

	if ( (organization_option = 2  and l_master_org = l_master_org_for_current_org)
	     or organization_option = 3 ) THEN

	/*Check the existence of the Item in the curent Organization,
	if found then call the Imploder API for the Organization,otherwise
	check the existence of the Item in the next Organization of the
	Organization List*/

                        select count(*) into dummy from mtl_system_items where
                        organization_id = t_org_code_list(I) and
                        inventory_item_id = item_id;

	                if dummy <1 then
                                item_found := FALSE;
                        end if;
	/*setting item_found to false when organization_option = 2  and
	l_master_org  <> l_master_org_for_current_org: */
	elsif (organization_option <> 1) THEN
		item_found := FALSE;
	end if;


            if item_found then
		-- commented for Bug #4070863 and added below
		/*INSERT INTO BOM_SMALL_IMPL_TEMP
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
			CREATED_BY,
			implosion_date)
		VALUES (sequence_id,
			item_id,
			item_id,
			item_id,
			NULL,
			0,
		--	'0000001',
			 Bom_Common_Definitions.G_Bom_Init_SortCode,
			NULL,
			NULL,
			t_org_code_list(I),
			sysdate,
			-1,
			sysdate,
			-1,
			to_date(impl_date, 'YYYY/MM/DD HH24:MI')); */

		  INSERT INTO BOM_SMALL_IMPL_TEMP
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
			CREATED_BY,
			IMPLOSION_DATE)
		   (
		    SELECT
			sequence_id,
			item_id,
			item_id,
			item_id,
			NULL,
			0,
			--'0001',
			Bom_Common_Definitions.G_Bom_Init_SortCode,
			NULL,
			NULL,
			t_org_code_list(I),
			sysdate,
			-1,
			sysdate,
			-1,
			to_date(impl_date, 'YYYY/MM/DD HH24:MI')
		    FROM DUAL
		    WHERE NOT EXISTS
		      ( SELECT 'X'
			FROM   BOM_SMALL_IMPL_TEMP
			WHERE  SEQUENCE_ID	        = sequence_id
			AND LOWEST_ITEM_ID	        = item_id
			AND CURRENT_ITEM_ID	        = item_id
			AND PARENT_ITEM_ID	        = item_id
			AND ALTERNATE_DESIGNATOR	IS NULL
			AND CURRENT_LEVEL	        = 0
			AND SORT_CODE			= Bom_Common_Definitions.G_Bom_Init_SortCode
			AND CURRENT_ASSEMBLY_TYPE	IS NULL
			AND COMPONENT_SEQUENCE_ID	IS NULL
			AND ORGANIZATION_ID	        = t_org_code_list(I)
		     )
		);

		bompiinq.implosion(sequence_id,eng_mfg_flag,t_org_code_list(I),
                impl_flag, display_option, levels_to_implode, impl_date,
                unit_number_from, unit_number_to,
                a_err_msg, a_err_code, serial_number_from, serial_number_to);

		err_msg		:= a_err_msg;
		err_code	:= a_err_code;
	item_found      := TRUE;
	end if;
	end loop;

    if (a_err_code <> 0) then
	ROLLBACK;
    end if;

EXCEPTION
    WHEN OTHERS THEN
	err_msg		:= substrb(SQLERRM, 1, 80);
	err_code	:= SQLCODE;
	IF c_master_org%isopen THEN
	CLOSE c_master_org;
	END IF;
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
	unit_number_from	IN  VARCHAR2,
	unit_number_to		IN  VARCHAR2,
	err_msg			IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	err_code 		IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	serial_number_from	IN  VARCHAR2 default NULL,
	serial_number_to	IN  VARCHAR2 default NULL) AS

    implosion_date		VARCHAR2(25);
    error_msg			VARCHAR(80);
    error_code			NUMBER;

BEGIN
    implosion_date	:= substr(impl_date, 1, 16);

    if levels_to_implode = 1 then
     	sl_imploder(sequence_id, eng_mfg_flag, org_id, impl_flag,
		display_option, implosion_date,unit_number_from,
	        unit_number_to,	error_msg, error_code,
                serial_number_from, serial_number_to);
    else
     	ml_imploder(sequence_id, eng_mfg_flag, org_id, impl_flag,
		levels_to_implode, implosion_date, unit_number_from,
	        unit_number_to,	error_msg, error_code,
                serial_number_from, serial_number_to);
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
	unit_number_from	IN  VARCHAR2,
	unit_number_to		IN  VARCHAR2,
	err_msg			IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code 		IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
        serial_number_from      IN  VARCHAR2 default NULL,
        serial_number_to        IN  VARCHAR2 default NULL) AS

    total_rows			NUMBER;
    cat_sort			VARCHAR2(7);

    --
    -- bug 6957708
    -- Added a hint based on an Index XX_BOM_COMPONENTS_B_I1 on BOM_COMPONENTS_B
    -- which is not a seeded index.
    -- This index XX_BOM_COMPONENTS_B_I1 is to be based on the
    -- columns COMPONENT_ITEM_ID and PK1_VALUE (in the same order)
    -- This index is needed only in case the customer has a very high data volume
    -- for other customers this hint would play no role.
    -- Also added 2 where clauses based on PK1_value and PK2_Value to cut
    -- down the data from BIC
    -- ntungare
    --
    CURSOR imploder (c_sequence_id NUMBER,
		c_eng_mfg_flag NUMBER, c_org_id NUMBER,
		c_display_option NUMBER,
		c_implosion_date VARCHAR2,
		c_unit_number_from VARCHAR2,
		c_unit_number_to   VARCHAR2,
                c_serial_number_from VARCHAR2,
                c_serial_number_to  VARCHAR2,
	        c_implemented_only_option NUMBER
		) IS
        SELECT  /*+ first_rows index(BIC XX_BOM_COMPONENTS_B_I1)*/
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
		 BBM.ORGANIZATION_ID OI,
		 BIC.FROM_END_ITEM_UNIT_NUMBER FUN,
	         BIC.TO_END_ITEM_UNIT_NUMBER TUN
        FROM
		BOM_SMALL_IMPL_TEMP BITT,
                BOM_INVENTORY_COMPONENTS BIC,
                BOM_BILL_OF_MATERIALS BBM,
		MTL_SYSTEM_ITEMS MSI
	where bic.pk1_value = BITT.PARENT_ITEM_ID and
              bic.pk2_value = NVL(bbm.common_organization_id,bbm.organization_id) and
	      bitt.current_level = 0
        and   bitt.organization_id = c_org_id
	and   MSI.ORGANIZATION_ID = BBM.ORGANIZATION_ID
	and   MSI.INVENTORY_ITEM_ID = BBM.ASSEMBLY_ITEM_ID
	and   bitt.sequence_id = c_sequence_id
	and   bitt.parent_item_id = bic.component_item_id
	and   bic.bill_sequence_id = bbm.common_bill_sequence_id
	and   bbm.organization_id = c_org_id
	and   NVL(BIC.ECO_FOR_PRODUCTION,2) = 2
	and   (
       		( c_eng_mfg_flag = 1
        	      and bbm.assembly_type = 1
		) /* get only Mfg boms */
        	or
        	(c_eng_mfg_flag = 2
		) /*both Mfg-Eng BOMs in ENG mode*/
	      ) /* end of entire and predicate */
	and ( /* match par alt */
	      ((bbm.alternate_bom_designator is null and
		 	bitt.lowest_alternate_designator is null)
		or
	      (bbm.alternate_bom_designator =
			bitt.lowest_alternate_designator))
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
	and ( /* Effectivity_control */
	    ( msi.effectivity_control =1   -- Date Effectivity
             AND
            ( /* start of all display options */
     	      ( c_display_option = 2
      		and bic.effectivity_date
         		<= to_date (c_implosion_date, 'YYYY/MM/DD HH24:MI')
      		and  ( bic.disable_date is null
            	       or bic.disable_date >
                	  to_date (c_implosion_date, 'YYYY/MM/DD HH24:MI')
            	     )
     	      ) /* end of CURRENT */
     	      or
     	      c_display_option = 1
     	      or
     	      ( c_display_option = 3
      		and ( bic.disable_date is null
            	      or bic.disable_date >
                   	    to_date (c_implosion_date, 'YYYY/MM/DD HH24:MI')
            	    )
     	      ) /* end of CURRENT_AND_FUTURE */
    	    ) /* end of all display options */
	  ) /* msi.effectivity_control =1 */
           OR  (
		 msi.effectivity_control =2 -- Unit Number Effectivity
                 AND nvl(msi.eam_item_type,0) <> 1 -- do not include serial eff EAM items
	        AND
                 c_unit_number_from is NOT NULL -- Profile Model/Unit Eff=YES
	        AND
                 (c_display_option = 1
                  OR (c_display_option in (2,3) AND bic.disable_date is null))
                AND
		 BIC.FROM_END_ITEM_UNIT_NUMBER <= c_unit_number_to
                AND
		 NVL(BIC.TO_END_ITEM_UNIT_NUMBER,c_unit_number_from) >= c_unit_number_from
            	)
           OR  (
		 msi.effectivity_control =2 -- Unit Number Effectivity
                 AND nvl(msi.eam_item_type,0) = 1 -- include only serial eff EAM items
	        AND
                 c_serial_number_from is NOT NULL -- Serial Effectivity for EAM items
	        AND
                 (c_display_option = 1
                  OR (c_display_option in (2,3) AND bic.disable_date is null))
                AND
		 BIC.FROM_END_ITEM_UNIT_NUMBER <= c_serial_number_to
                AND
		 NVL(BIC.TO_END_ITEM_UNIT_NUMBER,c_serial_number_from) >= c_serial_number_from
            	)
	   ) /* end of effectivity control */
	and ( /* effectivity_control */
           ( msi.effectivity_control =1 -- Date Effectivity
             AND
            ( /* start of implemented yes/no logic */
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
			    and  NVL(BIC2.ECO_FOR_PRODUCTION,2) = 2
                 	    and   decode(bic.implementation_date, NULL,
                          	bic.old_component_sequence_id,
                          	bic.component_sequence_id) =
                        	decode(bic2.implementation_date, NULL,
                          	bic2.old_component_sequence_id,
                          	bic2.component_sequence_id)
                 	    and trunc(bic2.effectivity_date, 'MI') <=
					to_date(c_implosion_date,
                                                'YYYY/MM/DD HH24:MI')
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
						       'YYYY/MM/DD HH24:MI'))
                 	    and ( bic2.disable_date >
					to_date(c_implosion_date,
                                                'YYYY/MM/DD HH24:MI')
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
			    and  NVL(bic2.ECO_FOR_PRODUCTION,2) = 2
                 	    and   nvl(bic2.old_component_sequence_id,
                                bic2.component_sequence_id) =
                          	nvl(bic.old_component_sequence_id,
                                bic.component_sequence_id)
                 	    and bic2.effectivity_date <=
					to_date(c_implosion_date,
                                                'YYYY/MM/DD HH24:MI')
			    and NOT EXISTS (SELECT null
			                  FROM bom_inventory_components bic4
                                         WHERE bic4.bill_sequence_id =
					       bic.bill_sequence_id
					   AND bic4.old_component_sequence_id =
					       bic.component_sequence_id
			                   AND NVL(bic4.ECO_FOR_PRODUCTION,2)= 2
					   AND bic4.acd_type in (2,3)
					   AND bic4.disable_date <=
                                               to_date(c_implosion_date,
						       'YYYY/MM/DD HH24:MI'))
                	    and ( bic2.disable_date >
					to_date(c_implosion_date,
                                                'YYYY/MM/DD HH24:MI')
                        	  or bic2.disable_date is null )
                	) /* end of subquery */
              		or
			bic.effectivity_date > to_date(c_implosion_date,
                                                'YYYY/MM/DD HH24:MI')
                 ) /* end of current and future */
          	 or
            	 ( c_display_option = 1)
      	       ) /* end of all display */
     	     ) /* end of impl = no */
    	   ) /* end of impl = yes-no */
	  ) /* effectivity_control = 1 */
          OR  /* serial effectivity control */
	   ( MSI.effectivity_control=2  -- Unit Effectivity
             AND nvl(msi.eam_item_type,0) <> 1 -- do not include serial eff EAM items
             AND
		c_unit_number_from is NOT NULL
             AND
            ( /* start of implemented yes/no logic */
     	      ( c_implemented_only_option = 1
      		and bic.implementation_date is not null
     	       )
     	      or
     	      ( c_implemented_only_option = 2 )
	     )
	  ) /* effectivity_control = 2 */
          OR  /* serial effectivity control */
	   ( MSI.effectivity_control=2  -- Serial Effectivity for EAM items
             AND nvl(msi.eam_item_type,0) = 1 -- include only serial eff EAM items
             AND
		c_serial_number_from is NOT NULL
             AND
            ( /* start of implemented yes/no logic */
     	      ( c_implemented_only_option = 1
      		and bic.implementation_date is not null
     	       )
     	      or
     	      ( c_implemented_only_option = 2 )
	     )
	  ) /* effectivity_control = 2 */
	 ) /* effectivity_control*/
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

     TYPE number_tab_tp IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

     TYPE date_tab_tp IS TABLE OF DATE
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_30 IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_10 IS TABLE OF VARCHAR2(10)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_240 IS TABLE OF VARCHAR2(240)
       INDEX BY BINARY_INTEGER;

    l_lid       number_tab_tp;
    l_pid       number_tab_tp;
    l_aid       number_tab_tp;
    l_abd       varchar_tab_10;
    l_sc        varchar_tab_240;
    l_lad       varchar_tab_10;
    l_cat       number_tab_tp;
    l_csi       number_tab_tp;
    l_oi        number_tab_tp;
    l_osn       number_tab_tp;
    l_ed        date_tab_tp;
    l_dd        date_tab_tp;
    l_fun       varchar_tab_30;
    l_tun       varchar_tab_30;
    l_bt        number_tab_tp;
    l_cq        number_tab_tp;
    l_risd      number_tab_tp;
    l_cn        varchar_tab_10;
    l_impf      number_tab_tp;

    l_lid1       number_tab_tp;
    l_pid1       number_tab_tp;
    l_aid1       number_tab_tp;
    l_abd1       varchar_tab_10;
    l_sc1        varchar_tab_240;
    l_lad1       varchar_tab_10;
    l_cat1       number_tab_tp;
    l_csi1       number_tab_tp;
    l_oi1        number_tab_tp;
    l_osn1       number_tab_tp;
    l_ed1        date_tab_tp;
    l_dd1        date_tab_tp;
    l_fun1       varchar_tab_30;
    l_tun1       varchar_tab_30;
    l_bt1	 number_tab_tp;
    l_cq1        number_tab_tp;
    l_risd1      number_tab_tp;
    l_cn1        varchar_tab_10;
    l_impf1      number_tab_tp;

    Loop_Count_Val        Number := 0;
    l_bulk_count        Number := 0;

  Prune_Tree exception;

BEGIN

	total_rows	:= 0;
	l_bulk_count    := 0;
--      Delete pl/sql tables.
                l_lid1.delete;
                l_pid1.delete;
                l_aid1.delete;
                l_abd1.delete;
                l_sc1.delete;
                l_lad1.delete;
                l_cat1.delete;
                l_csi1.delete;
                l_oi1.delete;
                l_osn1.delete;
                l_ed1.delete;
                l_dd1.delete;
                l_fun1.delete;
                l_tun1.delete;
                l_bt1.delete;
                l_cq1.delete;
                l_risd1.delete;
                l_cn1.delete;
                l_impf1.delete;

                l_lid.delete;
                l_pid.delete;
                l_aid.delete;
                l_abd.delete;
                l_sc.delete;
                l_lad.delete;
                l_cat.delete;
                l_csi.delete;
                l_oi.delete;
                l_osn.delete;
                l_ed.delete;
                l_dd.delete;
                l_fun.delete;
                l_tun.delete;
                l_bt.delete;
                l_cq.delete;
                l_risd.delete;
                l_cn.delete;
                l_impf.delete;

        IF not imploder%isopen then
                open imploder(sequence_id,
                eng_mfg_flag, org_id,display_option,
                IMpl_date, unit_number_from, unit_number_to,
                serial_number_from, serial_number_to,
                impl_flag);
        end if;
           FETCH imploder bulk collect into
                l_lid,
                L_pid,
                l_aid,
                l_abd,
                l_sc,
                l_lad,
                l_cat,
                l_csi,
                l_osn,
                l_ed,
                l_dd,
                l_bt,
                l_cq,
                l_risd,
                l_cn,
                l_impf,
                l_oi,
                l_fun,
                l_tun;
           loop_Count_Val := imploder%rowcount;
        CLOSE imploder;

        For i in 1..loop_Count_Val
        Loop
          Begin
            For X_Item_Attributes in Check_Disabled_Parent(
              P_Parent_Item => l_aid(i)) loop
                l_lid.delete(i);
                l_pid.delete(i);
                l_aid.delete(i);
                l_abd.delete(i);
                l_sc.delete(i);
                l_lad.delete(i);
                l_cat.delete(i);
                l_csi.delete(i);
                l_oi.delete(i);
                l_osn.delete(i);
                l_ed.delete(i);
                l_dd.delete(i);
                l_fun.delete(i);
                l_tun.delete(i);
                l_bt.delete(i);
                l_cq.delete(i);
                l_risd.delete(i);
                l_cn.delete(i);
                l_impf.delete(i);
                Raise Prune_Tree;
           End loop; /* Cursor loop  for Check_Disabled_Parent*/

            l_lad(i)   := l_abd(i);

            total_rows := total_rows + 1;

            -- cat_sort   := lpad(total_rows, 7, '0');
	    cat_sort   := lpad(total_rows, Bom_Common_Definitions.G_Bom_SortCode_Width, '0');

            l_sc(i)    := l_sc(i) || cat_sort;
          Exception
                When Prune_Tree then
                  null;
          End;
        End loop;               /* For loop */

--Loop to check if the record exist. If It exist then copy the record into
--an other table and insert the other table.
--This has to be done to avoid "ELEMENT DOES NOT EXIST exception"

              For i in 1..loop_Count_Val Loop
                if (l_impf.EXISTS(i)) Then
                        l_bulk_count         := l_bulk_count + 1;
                        l_lid1(l_bulk_count) := l_lid(i);
                        l_pid1(l_bulk_count) := l_pid(i);
                        l_aid1(l_bulk_count) := l_aid(i);
                        l_abd1(l_bulk_count) := l_abd(i);
                        l_sc1(l_bulk_count)  := l_sc(i);
                        l_lad1(l_bulk_count) := l_lad(i);
                        l_cat1(l_bulk_count) := l_cat(i);
                        l_csi1(l_bulk_count) := l_csi(i);
                        l_oi1(l_bulk_count)  := l_oi(i);
                        l_osn1(l_bulk_count) := l_osn(i);
                        l_ed1(l_bulk_count)  := l_ed(i);
                        l_dd1(l_bulk_count)  := l_dd(i);
                        l_fun1(l_bulk_count) := l_fun(i);
                        l_tun1(l_bulk_count) := l_tun(i);
                        l_bt1(l_bulk_count)  := l_bt(i);
                        l_cq1(l_bulk_count)  := l_cq(i);
                        l_risd1(l_bulk_count):= l_risd(i);
                        l_impf1(l_bulk_count):= l_impf(i);
                        l_cn1(l_bulk_count)  := l_cn(i);
                End if;
                END LOOP;


        FORALL i IN 1..l_bulk_count
	-- commented for Bug #4070863 and added below
            /*INSERT INTO BOM_SMALL_IMPL_TEMP
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
                 FROM_END_ITEM_UNIT_NUMBER,
                 TO_END_ITEM_UNIT_NUMBER,
                 COMPONENT_QUANTITY,
                 REVISED_ITEM_SEQUENCE_ID,
                 CHANGE_NOTICE,
                 IMPLEMENTED_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 PARENT_SORT_CODE,
		 implosion_date) VALUES (
                l_lid1(i),
                l_pid1(i),
                l_aid1(i),
                l_abd1(i),
                1,
                l_sc1(i),
                l_lad1(i),
                l_cat1(i),
                sequence_id,
                l_csi1(i),
                l_oi1(i),
                l_osn1(i),
                l_ed1(i),
                l_dd1(i),
                l_fun1(i),
                l_tun1(i),
                l_cq1(i),
                l_risd1(i),
                l_cn1(i),
                l_impf1(i),
                sysdate,
                -1,
                sysdate,
                -1,
               decode(length(l_sc1(i)), 7,null,substrb(l_sc1(i),1,length(l_sc1(i))-7)),
	       to_date(impl_date, 'YYYY/MM/DD HH24:MI')); */

	       INSERT INTO BOM_SMALL_IMPL_TEMP
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
                 FROM_END_ITEM_UNIT_NUMBER,
                 TO_END_ITEM_UNIT_NUMBER,
                 BASIS_TYPE,
                 COMPONENT_QUANTITY,
                 REVISED_ITEM_SEQUENCE_ID,
                 CHANGE_NOTICE,
                 IMPLEMENTED_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 PARENT_SORT_CODE,
		 IMPLOSION_DATE)
	     (	SELECT
                l_lid1(i),
                l_pid1(i),
                l_aid1(i),
                l_abd1(i),
                1,
                l_sc1(i),
                l_lad1(i),
                l_cat1(i),
                sequence_id,
                l_csi1(i),
                l_oi1(i),
                l_osn1(i),
                l_ed1(i),
                l_dd1(i),
                l_fun1(i),
                l_tun1(i),
                l_bt1(i),
                l_cq1(i),
                l_risd1(i),
                l_cn1(i),
                l_impf1(i),
                sysdate,
                -1,
                sysdate,
                -1,
               decode(length(l_sc1(i)), 7,null,substrb(l_sc1(i),1,length(l_sc1(i))-7)),
	       to_date(impl_date, 'YYYY/MM/DD HH24:MI')
        FROM  DUAL
	WHERE NOT EXISTS
	       ( SELECT 'X'
		 FROM   BOM_SMALL_IMPL_TEMP
		 WHERE  LOWEST_ITEM_ID            = l_lid1(i)
                 AND CURRENT_ITEM_ID              = l_pid1(i)
                 AND PARENT_ITEM_ID               = l_aid1(i)
                 AND ALTERNATE_DESIGNATOR         = l_abd1(i)
                 AND CURRENT_LEVEL                = 1
                 AND SORT_CODE                    = l_sc1(i)
                 AND SEQUENCE_ID                  = sequence_id
                 AND COMPONENT_SEQUENCE_ID        = l_csi1(i)
                 AND ORGANIZATION_ID              = l_oi1(i)
                 AND PARENT_SORT_CODE             = decode(length(l_sc1(i)), 7,null,substrb(l_sc1(i),1,length(l_sc1(i))-7))
               )
    );
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
	unit_number_from        IN  VARCHAR2,
	unit_number_to  	IN  VARCHAR2,
	err_msg			IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code 		IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
        serial_number_from      IN  VARCHAR2,
        serial_number_to        IN  VARCHAR2) AS

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
    -- bug 6957708
    -- Added a hint based on an Index XX_BOM_COMPONENTS_B_I1 on BOM_COMPONENTS_B
    -- which is not a seeded index.
    -- This index XX_BOM_COMPONENTS_B_I1 is to be based on the
    -- columns COMPONENT_ITEM_ID and PK1_VALUE (in the same order)
    -- This index is needed only in case the customer has a very high data volume
    -- for other customers this hint would play no role.
    -- Also added 2 where clauses based on PK1_value and PK2_Value to cut
    -- down the data from BIC
    -- ntungare
    --
    CURSOR imploder (c_current_level NUMBER, c_sequence_id NUMBER,
		c_eng_mfg_flag NUMBER, c_org_id NUMBER,
		c_implosion_date VARCHAR2, c_unit_number_from VARCHAR2,
                c_unit_number_to VARCHAR2,c_serial_number_from VARCHAR2,
                c_serial_number_to VARCHAR2, c_implemented_only_option NUMBER
		) IS
       	SELECT /*+ first_rows index(BIC XX_BOM_COMPONENTS_B_I1)*/
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
	       BBM.ORGANIZATION_ID OI,
	       BIC.FROM_END_ITEM_UNIT_NUMBER FUN,
	       BIC.TO_END_ITEM_UNIT_NUMBER TUN
	FROM
		BOM_SMALL_IMPL_TEMP BITT,
                BOM_INVENTORY_COMPONENTS BIC,
                BOM_BILL_OF_MATERIALS BBM,
		MTL_SYSTEM_ITEMS MSI
	where bic.pk1_value = BITT.PARENT_ITEM_ID and
              bic.pk2_value = NVL(bbm.common_organization_id, bbm.organization_id) and
	      bitt.current_level = c_current_level
	and bitt.organization_id = c_org_id
	and msi.organization_id = BBM.organization_id
	and msi.inventory_item_id = BBM.assembly_item_id
	and bitt.sequence_id = c_sequence_id
	and bitt.parent_item_id = bic.component_item_id
	and bic.bill_sequence_id = bbm.common_bill_sequence_id
	and bbm.organization_id = c_org_id
	and NVL(BIC.ECO_FOR_PRODUCTION,2) = 2
	and ( c_eng_mfg_flag = 2 or c_eng_mfg_flag = 1 and
		( c_current_level = 0
		  and bbm.assembly_type = 1
              	  or c_current_level <> 0 and bitt.current_assembly_type = 1
                   and bbm.assembly_type = 1))
	and ( c_current_level = 0
	      or   /* start of all alternate logic */
	      bbm.alternate_bom_designator is null and
	      bitt.lowest_alternate_designator is null
	      or bbm.alternate_bom_designator = bitt.lowest_alternate_designator
              or ( bitt.lowest_alternate_designator is null
                and bbm.alternate_bom_designator is not null
                and not exists (select NULL     /*for current item */
                     	        from bom_bill_of_materials bbm2
                      		where bbm2.organization_id = c_org_id
                      		and   bbm2.assembly_item_id =
					bitt.parent_item_id
                      		and   bbm2.alternate_bom_designator =
                               		 bbm.alternate_bom_designator
                      		and ( bitt.current_assembly_type = 2
                            		or  bbm2.assembly_type = 1
                            		and bitt.current_assembly_type = 1)
                     	       )
                 )
              or /* Pickup prim par only if starting alt is not
			null and bill for .. */
              (bitt.lowest_alternate_designator is not null
               and bbm.alternate_bom_designator is null
      	       and not exists (select NULL
                      		from bom_bill_of_materials bbm2
                      		where bbm2.organization_id = c_org_id
                      		and   bbm2.assembly_item_id =
						bbm.assembly_item_id
                      		and   bbm2.alternate_bom_designator =
                               		 bitt.lowest_alternate_designator
                      		and ( bitt.current_assembly_type = 1
                            		and bbm2.assembly_type = 1
                           		or bitt.current_assembly_type = 2)
                     		)
              )
            )
        and (( msi.effectivity_control=1 -- Date Effectivity Control
	      and bic.effectivity_date <= to_date(c_implosion_date, 'YYYY/MM/DD HH24:MI')
	      and ( bic.disable_date is null or
                    bic.disable_date > to_date(c_implosion_date, 'YYYY/MM/DD HH24:MI'))
	      and ( c_implemented_only_option = 1
                   and bic.implementation_date is not null
                  or
                ( c_implemented_only_option = 2
      	 	  and bic.effectivity_date =
        	    (select max(effectivity_date)
           		from bom_inventory_components bic2
           		where bic.bill_sequence_id = bic2.bill_sequence_id
           		and   bic.component_item_id = bic2.component_item_id
	                and   NVL(BIC2.ECO_FOR_PRODUCTION,2) = 2
           		and   decode(bic.implementation_date, NULL,
				         decode(bic.old_component_sequence_id,null,
						bic.component_sequence_id,
						bic.old_component_sequence_id)
					 ,bic.component_sequence_id) =
			      decode(bic2.implementation_date,NULL,
					decode(bic2.old_component_sequence_id,null,
					     --  bic2.component_sequence_id,bic.old_component_sequence_id)
					     bic2.component_sequence_id,bic2.old_component_sequence_id)  -- For FP Bug 6134733 (Base Bug : 5405194 )
				        , bic2.component_sequence_id)
           		and   bic2.effectivity_date <=
			      to_date(c_implosion_date,'YYYY/MM/DD HH24:MI')
			and NOT EXISTS (SELECT null
			                  FROM bom_inventory_components bic3
                                         WHERE bic3.bill_sequence_id =
					       bic.bill_sequence_id
					   AND bic3.old_component_sequence_id =
					       bic.component_sequence_id
	                                   and NVL(BIC3.ECO_FOR_PRODUCTION,2)= 2
					   AND bic3.acd_type in (2,3)
					   AND bic3.disable_date <= to_date(c_implosion_date,'YYYY/MM/DD HH24:MI'))
           		and   (bic2.disable_date is null
                               or bic2.disable_date > to_date(c_implosion_date,
					      'YYYY/MM/DD HH24:MI')))
		)))
         OR
          ( msi.effectivity_control = 2
            AND
	      BIC.FROM_END_ITEM_UNIT_NUMBER <= NVL(BITT.TO_END_ITEM_UNIT_NUMBER,
                             BIC.FROM_END_ITEM_UNIT_NUMBER)
            AND
		 NVL(BIC.TO_END_ITEM_UNIT_NUMBER,
                        NVL(BITT.FROM_END_ITEM_UNIT_NUMBER,
                             BIC.FROM_END_ITEM_UNIT_NUMBER)) >=
		 NVL(BITT.FROM_END_ITEM_UNIT_NUMBER,
                             BIC.FROM_END_ITEM_UNIT_NUMBER)
	    AND(c_implemented_only_option=1 and bic.implementation_date is not null
                  or  c_implemented_only_option = 2)
            AND bic.from_end_item_unit_number <= decode(msi.eam_item_type,1,c_serial_number_to,c_unit_number_to)
            AND decode(msi.eam_item_type,1,c_serial_number_from,c_unit_number_from) is not null -- exclude serial eff EAM items
            AND bic.to_end_item_unit_number is null
            OR bic.to_end_item_unit_number >= decode(msi.eam_item_type,1,c_serial_number_from,c_unit_number_from)))
	order by bitt.parent_item_id, bbm.assembly_item_id,
		bic.operation_seq_num;

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

     TYPE number_tab_tp IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

     TYPE date_tab_tp IS TABLE OF DATE
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_30 IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_10 IS TABLE OF VARCHAR2(10)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_240 IS TABLE OF VARCHAR2(240)
       INDEX BY BINARY_INTEGER;


    l_lid       number_tab_tp;
    l_pid       number_tab_tp;
    l_aid       number_tab_tp;
    l_abd       varchar_tab_10;
    l_sc        varchar_tab_240;
    l_lad       varchar_tab_10;
    l_cat       number_tab_tp;
    l_csi       number_tab_tp;
    l_oi        number_tab_tp;
    l_osn       number_tab_tp;
    l_ed        date_tab_tp;
    l_dd        date_tab_tp;
    l_fun       varchar_tab_30;
    l_tun       varchar_tab_30;
    l_bt	number_tab_tp;
    l_cq        number_tab_tp;
    l_risd      number_tab_tp;
    l_cn        varchar_tab_10;
    l_impf      number_tab_tp;

    l_lid1       number_tab_tp;
    l_pid1       number_tab_tp;
    l_aid1       number_tab_tp;
    l_abd1       varchar_tab_10;
    l_sc1        varchar_tab_240;
    l_lad1       varchar_tab_10;
    l_cat1       number_tab_tp;
    l_csi1       number_tab_tp;
    l_oi1        number_tab_tp;
    l_osn1       number_tab_tp;
    l_ed1        date_tab_tp;
    l_dd1        date_tab_tp;
    l_fun1       varchar_tab_30;
    l_tun1       varchar_tab_30;
    l_bt1	 number_tab_tp;
    l_cq1        number_tab_tp;
    l_risd1      number_tab_tp;
    l_cn1        varchar_tab_10;
    l_impf1      number_tab_tp;

    Loop_Count_Val      Number := 0;
    l_bulk_count        Number := 0;

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
	Loop_Count_Val      := 0;
	total_rows	:= 0;
	cum_count	:= 0;
      l_bulk_count      := 0;

--      Delete pl/sql tables.
                l_lid1.delete;
                l_pid1.delete;
                l_aid1.delete;
                l_abd1.delete;
                l_sc1.delete;
                l_lad1.delete;
                l_cat1.delete;
                l_csi1.delete;
                l_oi1.delete;
                l_osn1.delete;
                l_ed1.delete;
                l_dd1.delete;
                l_fun1.delete;
                l_tun1.delete;
                l_bt1.delete;
                l_cq1.delete;
                l_risd1.delete;
                l_cn1.delete;
                l_impf1.delete;

                l_lid.delete;
                l_pid.delete;
                l_aid.delete;
                l_abd.delete;
                l_sc.delete;
                l_lad.delete;
                l_cat.delete;
                l_csi.delete;
                l_oi.delete;
                l_osn.delete;
                l_ed.delete;
                l_dd.delete;
                l_fun.delete;
                l_tun.delete;
                l_bt.delete;
                l_cq.delete;
                l_risd.delete;
                l_cn.delete;
                l_impf.delete;

--      Open the Cursor, Fetch and Close for each level

        IF not imploder%isopen then
                open imploder(cur_level,sequence_id,
                eng_mfg_flag, org_id, IMpl_date,
                unit_number_from, unit_number_to,
                serial_number_from, serial_number_to,impl_flag);
        end if;
                FETCH imploder bulk collect into
                l_lid,
                l_pid,
                l_aid,
                l_abd,
                l_sc,
                l_lad,
                l_cat,
                l_csi,
                l_osn,
                l_ed,
                l_dd,
                l_bt,
                l_cq,
                l_risd,
                l_cn,
                l_impf,
                l_oi,
                l_fun,
                l_tun;
           loop_Count_Val := imploder%rowcount ;
        CLOSE imploder;

--      Loop through the values and check for cursors Check_Configured_Parent
--      and Check_Disabled_Parent. If Record is found then delete that
--      row from the pl/sql table

              For i in 1..loop_Count_Val Loop -- Check Loop
                 Begin
                  if (cur_level >= 1) then
                  For X_Item_Attributes in Check_Configured_Parent(
                                    P_Parent_Item => l_aid(i),
                                    P_Comp_Item => l_pid(i)) loop
                                l_lid.delete(i);
                                l_pid.delete(i);
                                l_aid.delete(i);
                                l_abd.delete(i);
                                l_sc.delete(i);
                                l_lad.delete(i);
                                l_cat.delete(i);
                                l_csi.delete(i);
                                l_oi.delete(i);
                                l_osn.delete(i);
                                l_ed.delete(i);
                                l_dd.delete(i);
                                l_fun.delete(i);
                                l_tun.delete(i);
                                l_bt.delete(i);
                                l_cq.delete(i);
                                l_risd.delete(i);
                                l_cn.delete(i);
                                l_impf.delete(i);
                                Raise Prune_Tree;
                  End loop;
                  End if;
                  For X_Item_Attributes in Check_Disabled_Parent(
                        P_Parent_Item => l_aid(i)) loop
                                l_lid.delete(i);
                                l_pid.delete(i);
                                l_aid.delete(i);
                                l_abd.delete(i);
                                l_sc.delete(i);
                                l_lad.delete(i);
                                l_cat.delete(i);
                                l_csi.delete(i);
                                l_oi.delete(i);
                                l_osn.delete(i);
                                l_ed.delete(i);
                                l_dd.delete(i);
                                l_fun.delete(i);
                                l_tun.delete(i);
                                l_bt.delete(i);
                                l_cq.delete(i);
                                l_risd.delete(i);
                                l_cn.delete(i);
                                l_impf.delete(i);
                                Raise Prune_Tree;
                 End loop;
                        total_rows      := total_rows + 1;
                        IF (cur_level = 0) THEN
                                l_LAD(i) := l_ABD(i);
                        END IF;
                        IF (cum_count = 0) THEN
                                prev_parent_item_id     := l_PID(i);
                        END IF;

                        IF (prev_parent_item_id <> l_PID(i)) THEN
                                cum_count               := 0;
                                prev_parent_item_id     := l_PID(i);
                        END IF;

                        cum_count       := cum_count + 1;

                        -- cat_sort        := lpad(cum_count, 7, '0');
                        cat_sort        := lpad(cum_count, Bom_Common_Definitions.G_Bom_SortCode_Width , '0');

                        l_SC(i) := l_SC(i) || cat_sort;
                Exception
                    When Prune_tree then
                    	null;
                End;
              End Loop; -- End of Check Loop


--Loop to check if the record exist. If It exist then copy the record into
--an other table and insert the other table.
--This has to be done to avoid "ELEMENT DOES NOT EXIST exception"

              For i in 1..loop_Count_Val Loop
                if (l_impf.EXISTS(i)) Then
                        l_bulk_count         := l_bulk_count + 1;
                        l_lid1(l_bulk_count) := l_lid(i);
                        l_pid1(l_bulk_count) := l_pid(i);
                        l_aid1(l_bulk_count) := l_aid(i);
                        l_abd1(l_bulk_count) := l_abd(i);
                        l_sc1(l_bulk_count)  := l_sc(i);
                        l_lad1(l_bulk_count) := l_lad(i);
                        l_cat1(l_bulk_count) := l_cat(i);
                        l_csi1(l_bulk_count) := l_csi(i);
                        l_oi1(l_bulk_count)  := l_oi(i);
                        l_osn1(l_bulk_count) := l_osn(i);
                        l_ed1(l_bulk_count)  := l_ed(i);
                        l_dd1(l_bulk_count)  := l_dd(i);
                        l_fun1(l_bulk_count) := l_fun(i);
                        l_tun1(l_bulk_count) := l_tun(i);
                        l_bt1(l_bulk_count)  := l_bt(i);
                        l_cq1(l_bulk_count)  := l_cq(i);
                        l_risd1(l_bulk_count):= l_risd(i);
                        l_impf1(l_bulk_count):= l_impf(i);
                        l_cn1(l_bulk_count)  := l_cn(i);
                End if;
                END LOOP;

-- Insert the Second table values using FORALL.

            FORALL i IN 1..l_bulk_count
	    -- commented for Bug #4070863 and added below
	    /*INSERT INTO BOM_SMALL_IMPL_TEMP
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
		 FROM_END_ITEM_UNIT_NUMBER,
                 TO_END_ITEM_UNIT_NUMBER,
                 COMPONENT_QUANTITY,
                 IMPLEMENTED_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 PARENT_SORT_CODE,
		 implosion_date) VALUES (
                l_lid1(i),
                l_pid1(i),
                l_aid1(i),
                l_abd1(i),
                cur_level + 1,
                l_sc1(i),
                l_lad1(i),
                l_cat1(i),
                sequence_id,
                l_csi1(i),
                l_oi1(i),
                l_risd1(i),
                l_cn1(i),
                l_osn1(i),
                l_ed1(i),
                l_dd1(i),
                l_fun1(i),
                l_tun1(i),
                l_cq1(i),
                l_impf1(i),
                sysdate,
                -1,
                sysdate,
                -1,
               decode(length(l_sc1(i)), 7,null,substrb(l_sc1(i),1,length(l_sc1(i))-7)),
	       to_date(impl_date, 'YYYY/MM/DD HH24:MI')); */

	       INSERT INTO BOM_SMALL_IMPL_TEMP
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
		 FROM_END_ITEM_UNIT_NUMBER,
                 TO_END_ITEM_UNIT_NUMBER,
                 BASIS_TYPE,
                 COMPONENT_QUANTITY,
                 IMPLEMENTED_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 PARENT_SORT_CODE,
		 IMPLOSION_DATE )
	 ( SELECT
                l_lid1(i),
                l_pid1(i),
                l_aid1(i),
                l_abd1(i),
                (cur_level + 1),
                l_sc1(i),
                l_lad1(i),
                l_cat1(i),
                sequence_id,
                l_csi1(i),
                l_oi1(i),
		l_risd1(i),
		l_cn1(i),
                l_osn1(i),
                l_ed1(i),
                l_dd1(i),
                l_fun1(i),
                l_tun1(i),
                l_bt1(i),
                l_cq1(i),
                l_impf1(i),
                sysdate,
                -1,
                sysdate,
                -1,
		decode(length(l_sc1(i)), 7,null,substrb(l_sc1(i),1,length(l_sc1(i))-7)),
		to_date(impl_date, 'YYYY/MM/DD HH24:MI')
        FROM  DUAL
	WHERE NOT EXISTS
	       ( SELECT 'X'
		 FROM   BOM_SMALL_IMPL_TEMP
		 WHERE  LOWEST_ITEM_ID            = l_lid1(i)
                 AND CURRENT_ITEM_ID              = l_pid1(i)
                 AND PARENT_ITEM_ID               = l_aid1(i)
                 AND ALTERNATE_DESIGNATOR         = l_abd1(i)
                 AND CURRENT_LEVEL                = (cur_level + 1)
                 AND SORT_CODE                    = l_sc1(i)
                 AND SEQUENCE_ID                  = sequence_id
                 AND COMPONENT_SEQUENCE_ID        = l_csi1(i)
                 AND ORGANIZATION_ID              = l_oi1(i)
                 AND PARENT_SORT_CODE             = decode(length(l_sc1(i)), 7,null,substrb(l_sc1(i),1,length(l_sc1(i))-7))
               )
    );

           IF (total_rows <> 0) THEN
                cur_level       := cur_level + 1;
            ELSE
                goto done_imploding;
            END IF;

        END LOOP;               /* while levels */


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

END bompiinq;

/
