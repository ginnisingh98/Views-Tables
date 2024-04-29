--------------------------------------------------------
--  DDL for Package Body BOMPBEXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPBEXP" AS
/* $Header: BOMBEXPB.pls 120.1 2005/06/21 02:47:45 appldev ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMBEXPB.pls                                               |
| Description  : This is the bom exploder.                                  |
| Parameters:   org_id          organization_id                             |
|               order_by        1 - Op seq, item seq                        |
|                               2 - Item seq, op seq                        |
|               grp_id          unique value to identify current explosion  |
|                               use value from sequence bom_explosion_temp_s|
|               levels_to_explode                                           |
|               bom_or_eng      1 - BOM                                     |
|                               2 - ENG                                     |
|               impl_flag       1 - implemented only                        |
|                               2 - both impl and unimpl                    |
|               explode_option  1 - All                                     |
|                               2 - Current                                 |
|                               3 - Current and future                      |
|		incl_oc_flag	1 - include OC and M under standard item    |
|				2 - do not include                          |
|		incl_lt_flag	1 - include operation lead time %           |
|				2 - don't include operation lead time %     |
|               max_level       max bom levels permissible for org          |
|               rev_date        explosion date YYYY/MM/DD HH24:MI            |
|               err_msg         error message out buffer                    |
|               error_code      error code out.  returns sql error code     |
|                               if sql error, 9999 if loop detected.        |
| Revision                                                                  |
|		Shreyas Shah	Creation                                    |
| 02/10/94	Shreyas Shah	added common_bill_Seq_id to cursor          |
|             			added multi-org explosion                   |
| 10/19/95      Robert Yee      select operation lead time percent from     |
|                               routing                                     |
|                                                                           |
+==========================================================================*/

PROCEDURE bom_exploder(
	verify_flag		IN NUMBER DEFAULT 0,
	online_flag		IN NUMBER DEFAULT 1,
	org_id 			IN NUMBER,
	order_by 		IN NUMBER DEFAULT 1,
	grp_id			IN NUMBER,
	levels_to_explode 	IN NUMBER DEFAULT 1,
	bom_or_eng		IN NUMBER DEFAULT 1,
	impl_flag		IN NUMBER DEFAULT 1,
	plan_factor_flag	IN NUMBER DEFAULT 2,
	explode_option 		IN NUMBER DEFAULT 2,
	std_comp_flag		IN NUMBER DEFAULT 2,
	incl_oc_flag		IN NUMBER DEFAULT 1,
	incl_lt_flag		IN NUMBER DEFAULT 2,
	max_level		IN NUMBER,
	module			IN NUMBER DEFAULT 2,
	rev_date		IN VARCHAR2,
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER) AS

    prev_sort_order		VARCHAR2(4000);
    prev_top_bill_id		NUMBER;
    cum_count			NUMBER;
    cur_level			NUMBER;
    total_rows			NUMBER;
    cat_sort			VARCHAR2(7);
    rev_date_s			date;

    /* verify local vars */
    cur_component               VARCHAR2(16);
    cur_substr                  VARCHAR2(16);
    cur_loopstr                 VARCHAR2(1000);
    cur_loopflag                VARCHAR2(1);
    loop_found                  BOOLEAN := false;
    some_loop_was_found		BOOLEAN := false;
    max_level_exceeded		BOOLEAN := false;
    start_pos                   NUMBER;

    CURSOR exploder (
	c_level NUMBER,
	c_grp_id NUMBER,
	c_bom_or_eng NUMBER,
	c_rev_date date,
	c_impl_flag NUMBER,
	c_explode_option NUMBER,
	c_order_by NUMBER,
	c_verify_flag NUMBER,
	c_plan_factor_flag NUMBER,
	c_std_comp_flag NUMBER,
	c_incl_oc NUMBER
    ) IS
	SELECT
		BET.TOP_BILL_SEQUENCE_ID TBSI,
		BOM.BILL_SEQUENCE_ID BSI,
		BOM.COMMON_BILL_SEQUENCE_ID CBSI,
		BIC.COMPONENT_ITEM_ID CID,
		BIC.COMPONENT_SEQUENCE_ID CSI,
		BIC.COMPONENT_QUANTITY CQ,
		(BIC.COMPONENT_QUANTITY * BET.EXTENDED_QUANTITY *
		    decode(c_plan_factor_flag, 1, BIC.PLANNING_FACTOR/100, 1) /
			decode(BIC.COMPONENT_YIELD_FACTOR, 0, 1,
				BIC.COMPONENT_YIELD_FACTOR)) EQ,
		BET.SORT_ORDER SO,
		BET.TOP_ITEM_ID TID,
		BET.TOP_ALTERNATE_DESIGNATOR TAD,
		BOM.ALTERNATE_BOM_DESIGNATOR, -- for routing
		BIC.COMPONENT_YIELD_FACTOR CYF,
		BOM.ORGANIZATION_ID OI,
		decode(verify_flag, 1, BET.COMPONENT_CODE,
		    BET.COMPONENT_CODE || '-' || BIC.COMPONENT_ITEM_ID) CC,
		BIC.INCLUDE_IN_COST_ROLLUP IICR,
		BET.LOOP_FLAG LF,
		BIC.PLANNING_FACTOR PF, BIC.OPERATION_SEQ_NUM OSN,
		BIC.BOM_ITEM_TYPE BIT, BET.BOM_ITEM_TYPE PBIT,
		BET.COMPONENT_ITEM_ID PAID, BIC.WIP_SUPPLY_TYPE WST,
		BIC.ITEM_NUM ITN,
		BIC.EFFECTIVITY_DATE ED,
      		BIC.DISABLE_DATE DD,
      		BIC.IMPLEMENTATION_DATE ID,
      		BIC.OPTIONAL OPT,
      		BIC.SUPPLY_SUBINVENTORY SS,
      		BIC.SUPPLY_LOCATOR_ID SLI,
      		BIC.COMPONENT_REMARKS CR,
      		BIC.CHANGE_NOTICE CN,
      		BIC.OPERATION_LEAD_TIME_PERCENT OLTP,
      		BIC.MUTUALLY_EXCLUSIVE_OPTIONS MEO,
      		BIC.CHECK_ATP CATP,
      		BIC.REQUIRED_TO_SHIP RTS,
      		BIC.REQUIRED_FOR_REVENUE RFR,
      		BIC.INCLUDE_ON_SHIP_DOCS IOSD,
      		BIC.LOW_QUANTITY LQ,
      		BIC.HIGH_QUANTITY HQ,
		BIC.SO_BASIS SB
	FROM    BOM_EXPLOSION_TEMP BET,
		BOM_BILL_OF_MATERIALS BOM,
		BOM_INVENTORY_COMPONENTS BIC,
		MTL_SYSTEM_ITEMS MSI
	WHERE   BET.PLAN_LEVEL = c_level - 1
	AND	BET.GROUP_ID = c_grp_id
	AND     MSI.INVENTORY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
	AND     MSI.ORGANIZATION_ID = BOM.ORGANIZATION_ID
	AND     BOM.COMMON_BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
	AND     BET.COMPONENT_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
	AND	BOM.ORGANIZATION_ID = BET.ORGANIZATION_ID
	AND     NVL(BIC.ECO_FOR_PRODUCTION,2) = 2
	AND   ( (c_std_comp_flag = 1 /* only std components */
		  AND MSI.PICK_COMPONENTS_FLAG = 'Y'
		  AND BIC.BOM_ITEM_TYPE = 4 AND BIC.OPTIONAL = 2
		)
		OR
		(c_std_comp_flag = 2)
		OR
		(c_std_comp_flag = 3 AND nvl(BET.BOM_ITEM_TYPE, 1) IN (1,2)
		   AND (BIC.BOM_ITEM_TYPE IN (1,2)
		         OR
		        (BIC.BOM_ITEM_TYPE = 4 AND BIC.OPTIONAL = 1)
		       )
		)
	      )
	AND	( (c_bom_or_eng = 1 and BOM.ASSEMBLY_TYPE = 1)
		  OR
		  (c_bom_or_eng = 2)
	 	)
	AND	(
		  (BET.TOP_ALTERNATE_DESIGNATOR IS NULL
		    AND
		    BOM.ALTERNATE_BOM_DESIGNATOR IS NULL
		   )
		  OR
		   (BET.TOP_ALTERNATE_DESIGNATOR IS NOT NULL
		    AND
		    BOM.ALTERNATE_BOM_DESIGNATOR=BET.TOP_ALTERNATE_DESIGNATOR
		   )
		  OR
		  ( BET.TOP_ALTERNATE_DESIGNATOR IS NOT NULL
		    AND BOM.ALTERNATE_BOM_DESIGNATOR IS NULL
		    AND NOT EXISTS
			(SELECT 'X'
			 FROM BOM_BILL_OF_MATERIALS BOM2
			 WHERE BOM2.ORGANIZATION_ID = BET.ORGANIZATION_ID
			 AND   BOM2.ASSEMBLY_ITEM_ID = BET.COMPONENT_ITEM_ID
			 AND   BOM2.ALTERNATE_BOM_DESIGNATOR =
				BET.TOP_ALTERNATE_DESIGNATOR
			 AND   ((c_bom_or_eng = 1 and BOM2.ASSEMBLY_TYPE = 1)
				OR c_bom_or_eng = 2
			       )
			) /* subquery */
		   )
		) /* end of alt logic */
/* whether to include option classes and models under a standard item
** special logic added at CST request */
	AND ( (c_incl_oc = 1)
	      or
	      (c_incl_oc = 2 AND
		( BET.BOM_ITEM_TYPE = 4 AND BIC.BOM_ITEM_TYPE = 4)
		OR
		( BET.BOM_ITEM_TYPE <> 4)
	      )
	    )
/* do not explode if immediate parent is standard and current
component is option class or model - special logic for config items */
	AND NOT ( BET.PARENT_BOM_ITEM_TYPE = 4
		    AND
		  BET.BOM_ITEM_TYPE IN (1, 2)
	 	)
	AND 	( (c_explode_option = 1 /* ALL */ )
		  OR
		  (c_explode_option = 2 /* CURRENT */ AND
	 	  c_rev_date >=
		  BIC.EFFECTIVITY_DATE AND
                  c_rev_date <
		  nvl(BIC.DISABLE_DATE,
			c_rev_date+1)
		  ) /* CURRENT */
		  OR
		  (c_explode_option = 3 /* CURRENT AND FUTURE */ AND
		  nvl(BIC.DISABLE_DATE,
		  c_rev_date + 1) >
			c_rev_date
		  ) /* CURRENT AND FUTURE */
		)
	AND     ( (c_impl_flag = 2 AND
		   ( c_explode_option = 1
		    OR
		    (c_explode_option = 2 AND
		     BIC.EFFECTIVITY_DATE =
			(SELECT MAX(EFFECTIVITY_DATE)
			 FROM BOM_INVENTORY_COMPONENTS CIB
			 WHERE CIB.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
 			 AND CIB.COMPONENT_ITEM_ID = BIC.COMPONENT_ITEM_ID
			 AND NVL(CIB.ECO_FOR_PRODUCTION,2) = 2
			 AND ( decode(CIB.IMPLEMENTATION_DATE, NULL,
				CIB.OLD_COMPONENT_SEQUENCE_ID,
				CIB.COMPONENT_SEQUENCE_ID) =
			       decode(BIC.IMPLEMENTATION_DATE, NULL,
				BIC.OLD_COMPONENT_SEQUENCE_ID,
				BIC.COMPONENT_SEQUENCE_ID)
			      OR
			       CIB.OPERATION_SEQ_NUM = BIC.OPERATION_SEQ_NUM
			     ) /* decode */
			 AND CIB.EFFECTIVITY_DATE <=
			     c_rev_date
			) /* end of subquery */
		    ) /* CURRENT */
		    OR
		    (c_explode_option = 3 AND
		     BIC.EFFECTIVITY_DATE =
			(SELECT MAX(EFFECTIVITY_DATE)
			 FROM BOM_INVENTORY_COMPONENTS CIB
			 WHERE CIB.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
 			 AND CIB.COMPONENT_ITEM_ID = BIC.COMPONENT_ITEM_ID
			 AND NVL(CIB.ECO_FOR_PRODUCTION,2) = 2
			 AND ( decode(CIB.IMPLEMENTATION_DATE, NULL,
				CIB.OLD_COMPONENT_SEQUENCE_ID,
				CIB.COMPONENT_SEQUENCE_ID) =
			       decode(BIC.IMPLEMENTATION_DATE, NULL,
				BIC.OLD_COMPONENT_SEQUENCE_ID,
				BIC.COMPONENT_SEQUENCE_ID)
			      OR
			       CIB.OPERATION_SEQ_NUM = BIC.OPERATION_SEQ_NUM
			     ) /* decode */
			 AND CIB.EFFECTIVITY_DATE <=
			     c_rev_date
			    ) /* end of subquery */
		      OR BIC.EFFECTIVITY_DATE >
			c_rev_date
		    ) /* CURRENT AND FUTURE */
		  ) /* explode_option */
		) /* impl_flag = 2 */
		  OR
		(c_impl_flag = 1 AND BIC.IMPLEMENTATION_DATE IS NOT NULL)
	      ) /* explode option */
	AND ( ( c_verify_flag = 1 AND BET.LOOP_FLAG = 2 ) OR
	      c_verify_flag <> 1 )
        ORDER BY BET.TOP_BILL_SEQUENCE_ID, BET.SORT_ORDER,
		decode(c_order_by, 1, BIC.OPERATION_SEQ_NUM, BIC.ITEM_NUM),
		decode(c_order_by, 1, BIC.ITEM_NUM, BIC.OPERATION_SEQ_NUM);

        Cursor Get_OLTP (P_Assembly in number,
        P_Org_Id in number,
        P_Alternate in varchar2,
        P_Operation in number) is
          Select round(bos.operation_lead_time_percent, 2) oltp
          From Bom_Operation_Sequences bos,
               Bom_Operational_Routings bor
          Where bor.assembly_item_id = P_Assembly
          And   bor.organization_Id = P_Org_Id
          And  (bor.alternate_routing_designator = P_Alternate
                or
               (bor.alternate_routing_designator is null and not exists (
                  select null
                  from bom_operational_routings bor2
                  where bor2.assembly_item_id = P_Assembly
                  and   bor2.organization_id = P_Org_Id
                  and   bor2.alternate_routing_designator = P_Alternate)
               ))
          And   bor.common_routing_sequence_id = bos.routing_sequence_id
          And   bos.operation_seq_num = P_Operation
	  And   NVL(bos.eco_for_production,2) = 2
          And   trunc(bos.effectivity_date) <=
                trunc(rev_date_s)
          And   nvl(bos.disable_date,
                    rev_date_s+1) >=
                trunc(rev_date_s);


BEGIN

    rev_date_s	:= to_date(rev_date || ':59', 'YYYY/MM/DD HH24:MI:SS');

    for cur_level in 1..levels_to_explode loop

	total_rows	:= 0;
	cum_count	:= 0;

	for expl_row in exploder (
		cur_level,
		grp_id,
		bom_or_eng,
		rev_date_s,
		impl_flag,
		explode_option,
		order_by,
		verify_flag,
		plan_factor_flag,
		std_comp_flag,
		incl_oc_flag
	) loop

	    total_rows	:= total_rows + 1;
/*
** for very first iteration of the loop, set prevbillid = bill_id
*/
            if (cum_count = 0) then
		prev_top_bill_id := expl_row.TBSI;
		prev_sort_order := expl_row.SO;
	    end if;
/*
** whenever a diff assy at a particular level is being exploded, reset
** the cum_count so that the sort code always starts from 001 for each
** assembly
*/
            if ( prev_top_bill_id <> expl_row.TBSI or
		(prev_top_bill_id = expl_row.TBSI and
		   prev_sort_order <> expl_row.SO)) then
		cum_count	:= 0;
		prev_top_bill_id := expl_row.TBSI;
		prev_sort_order := expl_row.SO;
	    end if;

	    cum_count		:= cum_count + 1;
/*
** lpad cat_sort with 0s upto 7 characters
*/
	    cat_sort := lpad(to_char(cum_count), G_SortWidth, '0');

	    expl_row.SO	:= expl_row.SO || cat_sort;

            if (verify_flag = 1) then

                /* SQL has been modified to carry the loopstr and loopflag */
                loop_found := FALSE;
                cur_loopstr := expl_row.CC;
                cur_component := LPAD( TO_CHAR( expl_row.CID ), 16, '0' );

                /* search the current loop_string for current component */
                FOR i IN 1..max_level LOOP
                        start_pos := 1+( (i-1) * 16 );
                        cur_substr := SUBSTR( cur_loopstr, start_pos, 16 );

                        if (cur_component = cur_substr) then
                                loop_found := TRUE;
                                EXIT;
                        end if;
                END LOOP;

                /* deal with the search results */
                if loop_found then
                        expl_row.CC :=
                                expl_row.CC || cur_component;
                        expl_row.LF := 1;
			some_loop_was_found := TRUE;
                        loop_found := FALSE;
                else
                        expl_row.CC :=
                                expl_row.CC || cur_component;
                        expl_row.LF := 2;
                end if;

            end if;

            Expl_Row.OLTP := Null;
	    If incl_lt_flag = 1 then
              For X_Operation in Get_OLTP(
                P_Assembly => Expl_Row.PAID,
                P_Org_Id => Expl_Row.OI,
                P_Alternate => Expl_Row.alternate_bom_designator,
                P_Operation => Expl_Row.OSN) loop

                Expl_Row.OLTP := X_Operation.OLTP;

              End loop;
            End if;

	    INSERT INTO BOM_EXPLOSION_TEMP (
		TOP_BILL_SEQUENCE_ID,
		BILL_SEQUENCE_ID,
		COMMON_BILL_SEQUENCE_ID,
		ORGANIZATION_ID,
		COMPONENT_SEQUENCE_ID,
		COMPONENT_ITEM_ID,
		COMPONENT_QUANTITY,
		PLAN_LEVEL,
		EXTENDED_QUANTITY,
		SORT_ORDER,
		GROUP_ID,
		TOP_ALTERNATE_DESIGNATOR,
		COMPONENT_YIELD_FACTOR,
		TOP_ITEM_ID,
		COMPONENT_CODE,
		INCLUDE_IN_ROLLUP_FLAG,
		LOOP_FLAG,
		PLANNING_FACTOR,
		OPERATION_SEQ_NUM,
		BOM_ITEM_TYPE,
		PARENT_BOM_ITEM_TYPE,
		ASSEMBLY_ITEM_ID,
		WIP_SUPPLY_TYPE,
		ITEM_NUM,
		EFFECTIVITY_DATE,
      		DISABLE_DATE,
      		IMPLEMENTATION_DATE,
      		OPTIONAL,
      		SUPPLY_SUBINVENTORY,
      		SUPPLY_LOCATOR_ID,
      		COMPONENT_REMARKS,
      		CHANGE_NOTICE,
      		OPERATION_LEAD_TIME_PERCENT,
      		MUTUALLY_EXCLUSIVE_OPTIONS,
      		CHECK_ATP,
      		REQUIRED_TO_SHIP,
      		REQUIRED_FOR_REVENUE,
      		INCLUDE_ON_SHIP_DOCS,
      		LOW_QUANTITY,
      		HIGH_QUANTITY,
		SO_BASIS
	    ) VALUES (
		expl_row.TBSI,
		expl_row.BSI,
		expl_row.CBSI,
		expl_row.OI,
		expl_row.CSI,
		expl_row.CID,
		expl_row.CQ,
		cur_level,
		expl_row.EQ,
		expl_row.SO,
		grp_id,
		expl_row.TAD,
		expl_row.CYF,
		expl_row.TID,
		expl_row.CC,
		expl_row.IICR,
		expl_row.LF,
		expl_row.PF,
		expl_row.OSN,
		expl_row.BIT,
		expl_row.PBIT,
		expl_row.PAID,
		expl_row.WST,
		expl_row.ITN,
		expl_row.ED,
		expl_row.DD,
		expl_row.ID,
		expl_row.OPT,
		expl_row.SS,
		expl_row.SLI,
		expl_row.CR,
		expl_row.CN,
		expl_row.OLTP,
		expl_row.MEO,
		expl_row.CATP,
		expl_row.RTS,
		expl_row.RFR,
		expl_row.IOSD,
		expl_row.LQ,
		expl_row.HQ,
		expl_row.SB
	    );

	if( (verify_flag=1) and  some_loop_was_found and (online_flag = 1) )
	  then EXIT;
	end if;

        end loop;    /* cursor fetch loop */

/*
** if total rows fetched is 0, then break the loop here since nothing
** more to explode
*/

	if (module = 1) then 	/* intermittent commits for CST */
	    commit;
	end if;

	if (total_rows <> 0) then
          if cur_level = max_level then
	    max_level_exceeded := true;
          end if;
	else
	    Exit;
	end if;

        if( (verify_flag=1) and  some_loop_was_found and (online_flag = 1))
		then EXIT;
        end if;

    END LOOP; /* for each level */

-- done_exploding


    if some_loop_was_found then
	err_msg		:= 'BOM_LOOP_EXISTS';
        error_code 	:= 9999;
    elsif max_level_exceeded then
	err_msg		:= 'BOM_MAX_LEVELS';
        error_code 	:= 9998;
    else
        err_msg   	:= null;
        error_code 	:= 0;
    end if;

/*
** exception handlers
*/
EXCEPTION
    WHEN OTHERS THEN
	error_code	:= SQLCODE;
	err_msg		:= 'BOMPBEXP:' || substrb(SQLERRM,1,60);
	ROLLBACK;
END bom_exploder;

END BOMPBEXP;

/
