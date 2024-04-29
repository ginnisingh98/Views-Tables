--------------------------------------------------------
--  DDL for Package Body ENG_CANCEL_ECO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CANCEL_ECO" AS
/* $Header: ENGCNCLB.pls 120.4.12010000.4 2009/06/18 18:48:01 agoginen ship $ */


Procedure Cancel_Eco (
    org_id		 number ,
    change_order	 varchar2,
    user_id		 number,
    login		 number
--    comment		varchar2
) IS
    err_text		varchar2(2000);
    stmt_num		number;
    l_revised_item_sequence_id number;
    l_new_item_revision_id number;
    l_revised_item_id number;
    l_change_id number;
    l_return_status varchar2(4000);
    l_msg_data varchar2(4000);
    l_msg_count number;
    l_new_change_id number;
    l_cm_type_code varchar2(2000);

    cursor delete_attachments is
    select change_id,revised_item_id,new_item_revision_id,revised_item_sequence_id
    from eng_revised_items
    where organization_id = org_id
    and change_notice = change_order
    and status_type not in (5,6);

   CURSOR update_att_status is
   SELECT change_id, change_mgmt_type_code
   FROM eng_engineering_changes
   WHERE organization_id = org_id
   and change_notice = change_order;

   -- Changes for Bug 3668603
   -- Cursor to fetch the routing_sequence_id for cancelled revised items
   CURSOR c_cancelled_RI IS
   SELECT DISTINCT ri.routing_sequence_id
     FROM ENG_REVISED_ITEMS ri
    WHERE TRUNC(ri.last_update_date) = TRUNC(SYSDATE)
      AND ri.status_type = 5 -- Cancelled
      AND ri.organization_id = org_id
      AND ri.change_notice = change_order
    ORDER BY routing_sequence_id desc;

   -- Cursor to check if the routing header used in the revised item has any references
   Cursor c_check_rtg_header_del(p_routing_sequence_id NUMBER) is
     select routing_sequence_id
       from bom_operational_routings bor
      WHERE bor.pending_from_ecn IS NOT NULL
        And bor.routing_sequence_id = p_routing_sequence_id
        and not exists (select null
                          from BOM_OPERATION_SEQUENCES bos
                         where bos.routing_sequence_id = bor.routing_sequence_id
                           and (bos.change_notice is null
                                or
                                bos.change_notice <> change_order))
        and ((bor.alternate_routing_designator is null
              and not exists (select null
                                from BOM_OPERATIONAL_ROUTINGS bor2
                               where bor2.organization_id  = bor.organization_id
                                 and bor2.assembly_item_id = bor.assembly_item_id
                                 and bor2.alternate_routing_designator is not null)
              and not exists (select null
                                from MTL_RTG_ITEM_REVISIONS mriv
                               where mriv.organization_id  = bor.organization_id
                                 and mriv.inventory_item_id = bor.assembly_item_id
   		                 and mriv.implementation_date is not null
                                 and mriv.change_notice is null))
              or
             (bor.alternate_routing_designator is not null))
        and not exists (select null
                          from ENG_REVISED_ITEMS eri
                         where eri.organization_id = bor.organization_id
                           and eri.routing_sequence_id = bor.routing_sequence_id
                           and eri.change_notice <> change_order
                           and eri.status_type <> 5);

    Cursor is_editable_common_bom(  org_id number , change_order  varchar2) is
    select bill_sequence_id
    from BOM_BILL_OF_MATERIALS
    where common_bill_sequence_id <> source_bill_sequence_id
              and bill_sequence_id = common_bill_sequence_id
	      and pending_from_ECN  = change_order
	      and organization_id = org_id;

   l_del_rtg_header		NUMBER;
   l_routing_sequence_id	NUMBER;
   Common_bom           NUMBER;
   -- End changes for bug 3668603

   /*Bug 8221477: (FP of 7557368) Added following three variables.*/
   type rowid_tab_typ is table of rowid index by binary_integer;
   rowid_tab1 rowid_tab_typ;
   l_counter number;

Begin

--Bug : 3507992 Calling the following API on all cases, i.e. attachments made to new item revision,
--existing item revision or at the Item Level.

begin
open delete_attachments;
loop
  fetch delete_attachments into l_change_id,l_revised_item_id,l_new_item_revision_id,l_revised_item_sequence_id;
  exit when delete_attachments%NOTFOUND ;

    ENG_ATTACHMENT_IMPLEMENTATION.delete_attachments_for_curr_co
                                    (p_api_version => 1.0
                                    ,p_change_id => l_change_id
                                    ,p_rev_item_seq_id => l_revised_item_sequence_id
                                    ,x_return_status => l_return_status
                                    ,x_msg_data => l_msg_data
                                    ,x_msg_count => l_msg_count
                                    );
end loop;
close delete_attachments;
exception
when others then
  close delete_attachments;
end;

begin
OPEN update_att_status;
loop
  fetch update_att_status into l_new_change_id,l_cm_type_code;
  exit when update_att_status%NOTFOUND ;

IF l_cm_type_code = 'ATTACHMENT_APPROVAL' OR  l_cm_type_code = 'ATTACHMENT_REVIEW' then
	Change_Att_Status (l_new_change_id, user_id, login);
END if;
END loop;
close update_att_status;
exception
when others then
  close update_att_status;
end;

/*
** set cancel date and comments on ECO
    stmt_num := 5;
    UPDATE ENG_ENGINEERING_CHANGES
	SET CANCELLATION_DATE = SYSDATE,
	STATUS_TYPE = 5,
	CANCELLATION_COMMENTS = comment,
	LAST_UPDATED_BY = user_id,
	LAST_UPDATE_LOGIN = login
    WHERE ORGANIZATION_ID = org_id
    AND CHANGE_NOTICE = change_order;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows updated in eec');
*/

/*
** set cancellation date of all pending revised items on ECO
*/
    stmt_num := 10;
    UPDATE ENG_REVISED_ITEMS
   	SET CANCELLATION_DATE = SYSDATE,
       	STATUS_TYPE = 5,
	LAST_UPDATED_BY = user_id,
	LAST_UPDATE_LOGIN = login
    WHERE ORGANIZATION_ID = org_id
    AND CHANGE_NOTICE = change_order
    AND STATUS_TYPE NOT IN (5,6);
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows updated in eri');

/*
** delete substitute components of all pending revised items on ECO
*/
    stmt_num := 20;
    DELETE FROM BOM_SUBSTITUTE_COMPONENTS SC
    WHERE SC.COMPONENT_SEQUENCE_ID IN
   	(SELECT IC.COMPONENT_SEQUENCE_ID
       	FROM BOM_INVENTORY_COMPONENTS IC, ENG_REVISED_ITEMS RI
     	WHERE RI.ORGANIZATION_ID = org_id
       	AND RI.CHANGE_NOTICE = change_order
       	AND IC.REVISED_ITEM_SEQUENCE_ID = RI.REVISED_ITEM_SEQUENCE_ID
       	AND IC.IMPLEMENTATION_DATE IS NULL);
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted in bsc');

/*
** delete reference designators of all pending revised items on ECO
*/
    stmt_num := 30;
    DELETE FROM BOM_REFERENCE_DESIGNATORS RD
 	WHERE RD.COMPONENT_SEQUENCE_ID IN
        (SELECT IC.COMPONENT_SEQUENCE_ID
         FROM BOM_INVENTORY_COMPONENTS IC, ENG_REVISED_ITEMS RI
         WHERE RI.ORGANIZATION_ID = org_id
         AND RI.CHANGE_NOTICE = change_order
         AND IC.REVISED_ITEM_SEQUENCE_ID = RI.REVISED_ITEM_SEQUENCE_ID
         AND IC.IMPLEMENTATION_DATE IS NULL);
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted in brd');

/*
** insert the cancelled rev components into eng_revised_components
*/
    stmt_num := 40;
    INSERT INTO ENG_REVISED_COMPONENTS (
	COMPONENT_SEQUENCE_ID,
	COMPONENT_ITEM_ID,
 	OPERATION_SEQUENCE_NUM,
 	BILL_SEQUENCE_ID,
	CHANGE_NOTICE,
	EFFECTIVITY_DATE,
 	COMPONENT_QUANTITY,
	COMPONENT_YIELD_FACTOR,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
 	CREATED_BY,
	LAST_UPDATE_LOGIN,
 	CANCELLATION_DATE,
 	OLD_COMPONENT_SEQUENCE_ID,
	ITEM_NUM,
	WIP_SUPPLY_TYPE,
 	COMPONENT_REMARKS,
	SUPPLY_SUBINVENTORY,
	SUPPLY_LOCATOR_ID,
 	DISABLE_DATE,
	ACD_TYPE,
 	PLANNING_FACTOR,
	QUANTITY_RELATED,
	SO_BASIS,
 	OPTIONAL,
	MUTUALLY_EXCLUSIVE_OPTIONS,
	INCLUDE_IN_COST_ROLLUP,
 	CHECK_ATP,
	SHIPPING_ALLOWED,
 	REQUIRED_TO_SHIP,
	REQUIRED_FOR_REVENUE,
	INCLUDE_ON_SHIP_DOCS,
 	LOW_QUANTITY,
	HIGH_QUANTITY,
 	REVISED_ITEM_SEQUENCE_ID,
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
	BASIS_TYPE)
    SELECT
 	IC.COMPONENT_SEQUENCE_ID,
	IC.COMPONENT_ITEM_ID,
 	IC.OPERATION_SEQ_NUM,
 	IC.BILL_SEQUENCE_ID,
	IC.CHANGE_NOTICE,
	IC.EFFECTIVITY_DATE,
 	IC.COMPONENT_QUANTITY,
	IC. COMPONENT_YIELD_FACTOR,
	SYSDATE,
 	user_id,
	SYSDATE,
 	user_id,
 	login,
 	sysdate,
 	IC.OLD_COMPONENT_SEQUENCE_ID,
	IC.ITEM_NUM,
	IC.WIP_SUPPLY_TYPE,
 	IC.COMPONENT_REMARKS,
	IC.SUPPLY_SUBINVENTORY,
	IC.SUPPLY_LOCATOR_ID,
 	IC.DISABLE_DATE,
	IC.ACD_TYPE,
 	IC.PLANNING_FACTOR,
	IC.QUANTITY_RELATED,
	IC.SO_BASIS,
 	IC.OPTIONAL,
	IC.MUTUALLY_EXCLUSIVE_OPTIONS,
	IC.INCLUDE_IN_COST_ROLLUP,
 	IC.CHECK_ATP,
	IC.SHIPPING_ALLOWED,
 	IC.REQUIRED_TO_SHIP,
	IC.REQUIRED_FOR_REVENUE,
	IC.INCLUDE_ON_SHIP_DOCS,
 	IC.LOW_QUANTITY,
	IC.HIGH_QUANTITY,
 	IC.REVISED_ITEM_SEQUENCE_ID,
 	IC.ATTRIBUTE_CATEGORY,
 	IC.ATTRIBUTE1,
	IC.ATTRIBUTE2,
	IC.ATTRIBUTE3,
	IC.ATTRIBUTE4,
	IC.ATTRIBUTE5,
 	IC.ATTRIBUTE6,
	IC.ATTRIBUTE7,
	IC.ATTRIBUTE8,
	IC.ATTRIBUTE9,
	IC.ATTRIBUTE10,
 	IC.ATTRIBUTE11,
	IC.ATTRIBUTE12,
	IC.ATTRIBUTE13,
	IC.ATTRIBUTE14,
 	IC.ATTRIBUTE15,
	IC.BASIS_TYPE
    FROM BOM_INVENTORY_COMPONENTS IC, ENG_REVISED_ITEMS RI
    WHERE RI.ORGANIZATION_ID = org_id
    AND RI.CHANGE_NOTICE = change_order
    AND IC.CHANGE_NOTICE = RI.CHANGE_NOTICE
    AND IC.REVISED_ITEM_SEQUENCE_ID = RI.REVISED_ITEM_SEQUENCE_ID
    AND RI.BILL_SEQUENCE_ID = IC.BILL_SEQUENCE_ID
    AND IC.IMPLEMENTATION_DATE IS NULL;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows inserted in erc');

/*
** delete the rows from bom_inventory_components
*/
    stmt_num := 50;
    DELETE FROM BOM_INVENTORY_COMPONENTS IC
    WHERE CHANGE_NOTICE = change_order
    AND IMPLEMENTATION_DATE IS NULL
    AND REVISED_ITEM_SEQUENCE_ID IN (SELECT REVISED_ITEM_SEQUENCE_ID
         FROM ENG_REVISED_ITEMS ERI
         WHERE ERI.ORGANIZATION_ID = org_id
	 AND ERI.CHANGE_NOTICE = change_order
	 AND ERI.STATUS_TYPE = 5);
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from bic');
--------------------------------------------------------------------
/*Special handling for Editable common bom*/
for Common_bom in  is_editable_common_bom(org_id,change_order) loop

/*
** delete the rows from bom_inventory_components
*/
    DELETE FROM BOM_INVENTORY_COMPONENTS IC
    WHERE  IC.BILL_SEQUENCE_ID =Common_bom.bill_sequence_id   ;
END loop;


/* ADDED BY VHYMAVAT FOR THE BUG 2647795 TO HANDLE ROUTINGS*/
--------------------------------------------------------------------

    -- Delete substitute operation resources of all pending revised items on ECO
    DELETE FROM BOM_SUB_OPERATION_RESOURCES sor
    WHERE  EXISTS (SELECT NULL
                   FROM   BOM_OPERATION_SEQUENCES bos
                        , ENG_REVISED_ITEMS       ri
                   WHERE  sor.operation_sequence_id    = bos.operation_sequence_id
                   AND    bos.implementation_date      IS NULL
                   AND    bos.revised_item_sequence_id = ri.revised_item_sequence_id
                   AND    ri.status_type               = 5 -- Cancelled
                   AND    ri.organization_id           = org_id
                   AND    ri.change_notice             =change_order
                   ) ;
    /*Start - Bug 8221477 (FP of 7557368): Changed the delete logic for operation resources*/
    -- Delete operation resources of all pending revised items on ECO
    SELECT bor.ROWID BULK COLLECT INTO rowid_tab1
                   FROM   BOM_OPERATION_SEQUENCES bos
                        , ENG_REVISED_ITEMS       ri
                        , BOM_OPERATION_RESOURCES bor
                   WHERE  bor.operation_sequence_id    = bos.operation_sequence_id
                   AND    bos.implementation_date      IS NULL
                   AND    bos.change_notice             = ri.change_notice
                   AND    bos.revised_item_sequence_id = ri.revised_item_sequence_id
                   AND    ri.status_type               = 5 -- Cancelled
                   AND    ri.organization_id           = org_id
                   AND    ri.change_notice             = change_order;

    FORALL l_counter IN  1..rowid_tab1.count
                 DELETE FROM  BOM_OPERATION_RESOURCES
                  WHERE rowid =rowid_tab1(l_counter);
    /*End - Bug 8221477 (FP of 7557368): Changed the delete logic for operation resources */

    -- Insert the cancelled rev operations into eng_revised_operations
   INSERT INTO ENG_REVISED_OPERATIONS (
                   operation_sequence_id
                 , routing_sequence_id
                 , operation_seq_num
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , standard_operation_id
                 , department_id
                 , operation_lead_time_percent
                 , minimum_transfer_quantity
                 , count_point_type
                 , operation_description
                 , effectivity_date
                 , disable_date
                 , backflush_flag
                 , option_dependent_flag
                 , attribute_category
                 , attribute1
                 , attribute2
                 , attribute3
                 , attribute4
                 , attribute5
                 , attribute6
                 , attribute7
                 , attribute8
                 , attribute9
                 , attribute10
                 , attribute11
                 , attribute12
                 , attribute13
                 , attribute14
                 , attribute15
                 , request_id
                 , program_update_date
                 , operation_type
                 , reference_flag
                 , process_op_seq_id
                 , line_op_seq_id
                 , yield
                 , cumulative_yield
                 , reverse_cumulative_yield
                 , labor_time_calc
                 , machine_time_calc
                 , total_time_calc
                 , labor_time_user
                 , machine_time_user
                 , total_time_user
                 , net_planning_percent
                 , x_coordinate
                 , y_coordinate
                 , include_in_rollup
                 , operation_yield_enabled
                 , change_notice
                 , implementation_date
                 , old_operation_sequence_id
                 , acd_type
                 , revised_item_sequence_id
                 , cancellation_date)
          SELECT
                   bos.OPERATION_SEQUENCE_ID
                 , bos.ROUTING_SEQUENCE_ID
                 , bos.OPERATION_SEQ_NUM
                 , SYSDATE                  /* Last Update Date */
                 , user_id                /* Last Updated By */
                 , SYSDATE                  /* Creation Date */
                 , user_id                /* Created By */
                 , login              /* Last Update Login */
                 , bos.STANDARD_OPERATION_ID
                 , bos.DEPARTMENT_ID
                 , bos.OPERATION_LEAD_TIME_PERCENT
                 , bos.MINIMUM_TRANSFER_QUANTITY
                 , bos.COUNT_POINT_TYPE
                 , bos.OPERATION_DESCRIPTION
                 , bos.EFFECTIVITY_DATE
                 , bos.DISABLE_DATE
                 , bos.BACKFLUSH_FLAG
                 , bos.OPTION_DEPENDENT_FLAG
                 , bos.ATTRIBUTE_CATEGORY
                 , bos.ATTRIBUTE1
                 , bos.ATTRIBUTE2
                 , bos.ATTRIBUTE3
                 , bos.ATTRIBUTE4
                 , bos.ATTRIBUTE5
                 , bos.ATTRIBUTE6
                 , bos.ATTRIBUTE7
                 , bos.ATTRIBUTE8
                 , bos.ATTRIBUTE9
                 , bos.ATTRIBUTE10
                 , bos.ATTRIBUTE11
                 , bos.ATTRIBUTE12
                 , bos.ATTRIBUTE13
                 , bos.ATTRIBUTE14
                 , bos.ATTRIBUTE15
                 , NULL                       /* Request Id */
                 , SYSDATE                    /* program_update_date */
                 , bos.OPERATION_TYPE
                 , bos.REFERENCE_FLAG
                 , bos.PROCESS_OP_SEQ_ID
                 , bos.LINE_OP_SEQ_ID
                 , bos.YIELD
                 , bos.CUMULATIVE_YIELD
                 , bos.REVERSE_CUMULATIVE_YIELD
                 , bos.LABOR_TIME_CALC
                 , bos.MACHINE_TIME_CALC
                 , bos.TOTAL_TIME_CALC
                 , bos.LABOR_TIME_USER
                 , bos.MACHINE_TIME_USER
                 , bos.TOTAL_TIME_USER
                 , bos.NET_PLANNING_PERCENT
                 , bos.X_COORDINATE
                 , bos.Y_COORDINATE
                 , bos.INCLUDE_IN_ROLLUP
                 , bos.OPERATION_YIELD_ENABLED
                 , bos.CHANGE_NOTICE
                 , bos.IMPLEMENTATION_DATE
                 , bos.OLD_OPERATION_SEQUENCE_ID
                 , bos.ACD_TYPE
                 , bos.REVISED_ITEM_SEQUENCE_ID
                 , SYSDATE                    /* Cancellation Date */
         FROM    BOM_OPERATION_SEQUENCES bos
               , ENG_REVISED_ITEMS       ri
         WHERE  bos.implementation_date      IS NULL
         AND    bos.revised_item_sequence_id = ri.revised_item_sequence_id
         AND    bos.change_notice             = ri.change_notice   /*Added for bug 8221477 (FP of 7557368)*/
         AND    ri.status_type               = 5 -- Cancelled
         AND    ri.organization_id           = org_id
         AND    ri.change_notice             = change_order;
-- Delete the rows from bom_operation_sequences
    DELETE FROM BOM_OPERATION_SEQUENCES bos
    WHERE  EXISTS (SELECT NULL
                   FROM   ENG_REVISED_ITEMS       ri
                   WHERE  1=1 /*bos.implementation_date      IS NULL Commented for bug 8583280 (FP of 6908447)*/
                   AND    bos.revised_item_sequence_id = ri.revised_item_sequence_id
                   AND    ri.status_type               = 5 -- Cancelled
                   AND    ri.organization_id           = org_id
                   AND    ri.change_notice             = change_order
                   )
    AND bos.change_notice             = change_order   /*Added for bug 8221477 (FP of 7557368)*/
    AND bos.implementation_date IS NULL; /*Added for bug 8583280 (FP of 6908447)*/


    -- Delete routing revisions created by revised items on ECO
    DELETE FROM MTL_RTG_ITEM_REVISIONS rev
    WHERE  EXISTS (SELECT NULL
                   FROM   ENG_REVISED_ITEMS       ri
                   WHERE  1=1 /*rev.implementation_date      IS NULL Commented for bug 8583280*/
                   AND    rev.revised_item_sequence_id = ri.revised_item_sequence_id
                   AND    ri.status_type               = 5 -- Cancelled
                   AND    ri.organization_id           = org_id
                   AND    ri.change_notice             = change_order
                   )
    AND rev.implementation_date      IS NULL; /*Added for bug 8583280 (FP of 6908447)*/


    -- Delete the bom header if routing was created by this revised item and
    -- nothing else references this

    --
    -- Bug 3668603
    -- Before deleting the routing header, check if it is referenced,
    -- For each routing_sequence_id referenced in the cancelled revised items ,
    -- Check using cursor c_check_rtg_header_del, if it is referenced.
    -- If referenced, the header is not deleted and bom_operational_routings.pending_for_ecn is
    -- set to null for the routing header header if value is current eco change_notice.
    -- If not referenced, then delete the routing revisions if the header is a primary routing
    -- Delete the header and unset the routing_sequence_id on the revised items
    -- using the routing_sequence_id.
    --
    FOR cri IN c_cancelled_RI
    LOOP

        l_del_rtg_header := 0;
	l_routing_sequence_id := cri.routing_sequence_id;

        FOR crh IN c_check_rtg_header_del(cri.routing_sequence_id)
        LOOP
		l_del_rtg_header := 1;

        END LOOP;

        IF (l_del_rtg_header = 1)
        THEN
            DELETE FROM MTL_RTG_ITEM_REVISIONS rev
            WHERE EXISTS (SELECT 1
		            FROM BOM_OPERATIONAL_ROUTINGS bor
			   WHERE bor.routing_sequence_id = l_routing_sequence_id
			     AND bor.alternate_routing_designator IS NULL
			     AND bor.assembly_item_id = rev.INVENTORY_ITEM_ID
			     AND bor.organization_id = rev.organization_id);

            DELETE FROM BOM_OPERATIONAL_ROUTINGS
            WHERE routing_sequence_id = l_routing_sequence_id;

	    -- If routing was deleted, then unset the routing_sequence_id on the revised items
	    UPDATE ENG_REVISED_ITEMS  ri
               SET routing_sequence_id =  ''
                 , last_updated_by = user_id
                 , last_update_login = login
             WHERE ri.organization_id = org_id
               AND ri.change_notice = change_order
               AND ri.status_type = 5  -- Cancelled
	       AND ri.routing_sequence_id = l_routing_sequence_id
               AND NOT EXISTS (SELECT 'No Rtg Header'
                                 FROM BOM_OPERATIONAL_ROUTINGS bor
                                WHERE bor.routing_sequence_id = ri.routing_sequence_id
                            ) ;
        ELSE

            UPDATE BOM_OPERATIONAL_ROUTINGS
               SET last_update_date = SYSDATE
                 , last_updated_by = user_id
                 , last_update_login = login
                 , pending_from_ecn = null
             WHERE routing_sequence_id = l_routing_sequence_id
               AND pending_from_ecn = change_order;
        END IF;

    END LOOP;


    /*DELETE FROM BOM_OPERATIONAL_ROUTINGS bor
    WHERE  EXISTS ( SELECT NULL
                    FROM   ENG_REVISED_ITEMS       ri
                    WHERE
                        bor.routing_sequence_id      = ri.routing_sequence_id
                    AND    TRUNC(ri.last_update_date)      = TRUNC(SYSDATE)
                    AND    ri.status_type               = 5 -- Cancelled
                    AND    ri.organization_id           = org_id
                    AND    ri.change_notice             = change_order
                   )
    AND NOT EXISTS (SELECT NULL
                    FROM   BOM_OPERATION_SEQUENCES bos
                    WHERE  bos.routing_sequence_id = bor.routing_sequence_id
                    AND    (bos.change_notice IS NULL
                            OR   bos.change_notice <> change_notice)
                   )
    AND (( bor.alternate_routing_designator IS NULL
           AND NOT EXISTS( SELECT NULL
                           FROM   BOM_OPERATIONAL_ROUTINGS bor2
                           WHERE  bor2.organization_id  = bor.organization_id
                           AND    bor2.assembly_item_id = bor.assembly_item_id
                           AND    bor2.alternate_routing_designator IS NOT NULL )
         )
         OR
         ( bor.alternate_routing_designator IS NOT NULL
           AND NOT EXISTS( SELECT NULL
                           FROM   ENG_REVISED_ITEMS ri2
                           WHERE  ri2.organization_id     = bor.organization_id
                           AND    ri2.routing_sequence_id = bor.routing_sequence_id
                           AND    ri2.change_notice       <> change_order)
         )) ;
    -- If routing was deleted, then unset the routing_sequence_id on the revised items
    IF  SQL%FOUND THEN

        UPDATE ENG_REVISED_ITEMS  ri
        SET     routing_sequence_id       =  ''
             ,  last_updated_by           = user_id
             ,  last_update_login         =login
        WHERE  ri.organization_id         = org_id
        AND    ri.change_notice           = change_notice
        AND    ri.status_type             = 5  -- Cancelled
        AND    NOT EXISTS (SELECT 'No Rtg Header'
                           FROM   BOM_OPERATIONAL_ROUTINGS bor
                           WHERE  bor.routing_sequence_id  = ri.routing_sequence_id
                           ) ;
    END IF;*/

    -- End changes for bug 3668603


/*
** delete item revisions created by revised items on ECO
*/
    stmt_num := 60;

   delete from MTL_ITEM_REVISIONS_TL
   where revision_id IN (select revision_id
                         from MTL_ITEM_REVISIONS_B I
                         WHERE CHANGE_NOTICE = change_order
                         AND ORGANIZATION_ID = org_id
                         AND IMPLEMENTATION_DATE IS NULL
                         AND INVENTORY_ITEM_ID IN
			      (SELECT REVISED_ITEM_ID
     	                       FROM ENG_REVISED_ITEMS R
     	                       WHERE R.CHANGE_NOTICE = change_order
     	                       AND   R.ORGANIZATION_ID = org_id
	                       AND   R.REVISED_ITEM_SEQUENCE_ID = I.REVISED_ITEM_SEQUENCE_ID
     	                       AND   R.CANCELLATION_DATE IS NOT NULL));

    DELETE FROM MTL_ITEM_REVISIONS_B I
    WHERE CHANGE_NOTICE = change_order
    AND ORGANIZATION_ID = org_id
    AND IMPLEMENTATION_DATE IS NULL
    AND INVENTORY_ITEM_ID IN (SELECT REVISED_ITEM_ID
     	FROM ENG_REVISED_ITEMS R
     	WHERE R.CHANGE_NOTICE = change_order
     	AND   R.ORGANIZATION_ID = org_id
	AND   R.REVISED_ITEM_SEQUENCE_ID = I.REVISED_ITEM_SEQUENCE_ID
     	AND   R.CANCELLATION_DATE IS NOT NULL);

-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from mir');

/*
** Syalaman - Fix for bug 6469639.
** delete UDA data created by revised items of ECO
*/
  stmt_num := 70;

  DELETE FROM EGO_MTL_SY_ITEMS_EXT_TL A
  WHERE A.REVISION_ID IN (SELECT NEW_ITEM_REVISION_ID
                          FROM ENG_REVISED_ITEMS
                          WHERE NEW_ITEM_REVISION_ID IS NOT NULL
                                AND CHANGE_NOTICE = change_order
                                AND ORGANIZATION_ID = org_id);

-- Begin Bug 7381299 fixing
-- Fixed by Gabriel on 10/29/2008.

  /*  DELETE FROM EGO_MTL_SY_ITEMS_EXT_B A
    WHERE A.REVISION_ID IN (SELECT NEW_ITEM_REVISION_ID
                            FROM ENG_REVISED_ITEMS
                            WHERE NEW_ITEM_REVISION_ID IS NOT NULL
                                  AND CHANGE_NOTICE = change_order
                                  AND ORGANIZATION_ID = org_id); */

  ---- Changed as follows, added more columns: A.ORGANIZATION_ID,
  ---- A.INVENTORY_ITEM_ID that have indexes built on it to avoid
  ---- full table scan.

 DELETE
   FROM EGO_MTL_SY_ITEMS_EXT_B A
  WHERE (A.ORGANIZATION_ID, A.INVENTORY_ITEM_ID, A.REVISION_ID) IN
  (SELECT ORGANIZATION_ID,
    REVISED_ITEM_ID      ,
    NEW_ITEM_REVISION_ID
     FROM ENG_REVISED_ITEMS
    WHERE NEW_ITEM_REVISION_ID IS NOT NULL
  AND CHANGE_NOTICE             = change_order
  AND ORGANIZATION_ID           = org_id
  );

-- End Bug 7381299 fixing

-- Syalaman - End of fix for bug 6469639.

/*
** delete the bom header if bill was created by this revised item and
** nothing else references this
*/
/* This is to fix bug 1522704. Now cancellation of ECO won't delete
corresponding row from bom_bill_of_materials. Deletion will be done by
delete groups only. Here two line of code is added update BOM_BILL_OF_MATERIALS B
set pending_from_ecn = null*/
    stmt_num := 80;
    DELETE FROM BOM_BILL_OF_MATERIALS B
    WHERE B.BILL_SEQUENCE_ID in (SELECT BILL_SEQUENCE_ID
		FROM  ENG_REVISED_ITEMS ERI
		WHERE ORGANIZATION_ID = org_id
		AND   CHANGE_NOTICE = change_order
    		AND   STATUS_TYPE = 5
		AND   TRUNC(LAST_UPDATE_DATE) = trunc(sysdate))
    AND   B.PENDING_FROM_ECN = change_order
    AND   NOT EXISTS (SELECT NULL
                  FROM BOM_INVENTORY_COMPONENTS C
                  WHERE C.BILL_SEQUENCE_ID = B.BILL_SEQUENCE_ID
                  AND (C.CHANGE_NOTICE IS NULL
                      OR C.CHANGE_NOTICE <> change_order))
    AND  ((B.ALTERNATE_BOM_DESIGNATOR IS NULL
         AND NOT EXISTS (SELECT NULL
                       FROM BOM_BILL_OF_MATERIALS B2
                       WHERE B2.ORGANIZATION_ID = B.ORGANIZATION_ID
                       AND   B2.ASSEMBLY_ITEM_ID = B.ASSEMBLY_ITEM_ID
                       AND   B2.ALTERNATE_BOM_DESIGNATOR IS NOT NULL))
         OR
        (NOT EXISTS (SELECT NULL
                       FROM ENG_REVISED_ITEMS R
                       WHERE R.ORGANIZATION_ID = B.ORGANIZATION_ID
                       AND   R.BILL_SEQUENCE_ID = B.BILL_SEQUENCE_ID
                       AND   R.CHANGE_NOTICE <> change_order
		       AND    R.STATUS_TYPE <> 5)));

/*
** if bills was deleted, then unset the bill_sequence_id on the revise items
*/
    if (SQL%ROWCOUNT > 0) then
-- dbms_output.put_line('Deleted BOM headers');
    	stmt_num := 90;
	UPDATE ENG_REVISED_ITEMS  R
	SET    BILL_SEQUENCE_ID = ''
	WHERE  R.ORGANIZATION_ID = org_id
	AND    R.CHANGE_NOTICE = change_order
	AND    R.STATUS_TYPE = 5
	AND    NOT EXISTS (SELECT 'NO SUCH BILL'
		FROM BOM_BILL_OF_MATERIALS BOM
		WHERE BOM.BILL_SEQUENCE_ID = R.BILL_SEQUENCE_ID);
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows updated in eri for bsi');
    end if;

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        err_text :=  'Cancel_Eco' || '(' || stmt_num || ')' || SQLERRM;
    	FND_MESSAGE.SET_NAME('BOM', 'BOM_SQL_ERR');
    	FND_MESSAGE.SET_TOKEN('ENTITY', err_text);
    	APP_EXCEPTION.RAISE_EXCEPTION;
END Cancel_ECO;

Procedure Cancel_Revised_Item (
    rev_item_seq	number,
    bill_seq_id		number,
    user_id		number,
    login		number,
    change_order	varchar2
--    comment		varchar2
) IS
    err_text		varchar2(2000);
    stmt_num		number;
    l_revision_id	NUMBER;
    l_revised_item_sequence_id number;
    l_new_item_revision_id number;
    l_revised_item_id varchar2(4000);
    l_change_id number;
    l_return_status varchar2(4000);
    l_msg_data varchar2(4000);
    l_msg_count number;
    l_org_id number;
    common number;

    cursor delete_attachments is
    select change_id,revised_item_id,new_item_revision_id,revised_item_sequence_id,organization_id
    from eng_revised_items
    where revised_item_sequence_id = rev_item_seq;

    Cursor is_editable_common_bom1( rev_item_seq number ) is
    select bill_sequence_id
    from BOM_BILL_OF_MATERIALS
    where common_bill_sequence_id <> source_bill_sequence_id
              and bill_sequence_id = common_bill_sequence_id
	      and pending_from_ECN  =(select change_notice
	      from eng_revised_items
	      where revised_item_sequence_id = rev_item_seq);

Begin
--Bug : 3507992 Calling the following API on all cases, i.e. attachments made to new item revision,
--existing item revision or at the Item Level.

begin
open delete_attachments;
loop
  fetch delete_attachments into l_change_id,l_revised_item_id,l_new_item_revision_id,l_revised_item_sequence_id,l_org_id;
  exit when delete_attachments%NOTFOUND ;

    ENG_ATTACHMENT_IMPLEMENTATION.delete_attachments_for_curr_co
                                    (p_api_version => 1.0
                                    ,p_change_id => l_change_id
                                    ,p_rev_item_seq_id => l_revised_item_sequence_id
                                    ,x_return_status => l_return_status
                                    ,x_msg_data => l_msg_data
                                    ,x_msg_count => l_msg_count
                                    );
end loop;
close delete_attachments;
exception
when others then
  close delete_attachments;
end;
/*
** set cancellation date of all pending revised items on ECO
    stmt_num := 10;
    UPDATE ENG_REVISED_ITEMS
   	SET CANCELLATION_DATE = SYSDATE,
       	STATUS_TYPE = 5,
	CANCEL_COMMENTS = comment,
	LAST_UPDATED_BY = user_id,
	LAST_UPDATE_LOGIN = login
    WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows updated in eri');
*/

/*
** delete substitute components of all pending revised items on ECO
*/
    stmt_num := 20;
    DELETE FROM BOM_SUBSTITUTE_COMPONENTS SC
    WHERE SC.COMPONENT_SEQUENCE_ID IN
   	(SELECT IC.COMPONENT_SEQUENCE_ID
       	FROM BOM_INVENTORY_COMPONENTS IC
       	WHERE IC.REVISED_ITEM_SEQUENCE_ID = rev_item_seq);
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from bsc');

/*
** delete reference designators of all pending revised items on ECO
*/
    stmt_num := 30;
    DELETE FROM BOM_REFERENCE_DESIGNATORS RD
 	WHERE RD.COMPONENT_SEQUENCE_ID IN
        (SELECT IC.COMPONENT_SEQUENCE_ID
         FROM BOM_INVENTORY_COMPONENTS IC
         WHERE IC.REVISED_ITEM_SEQUENCE_ID = rev_item_seq);
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from brd');

/*
** insert the cancelled rev components into eng_revised_components
*/
    stmt_num := 40;
    INSERT INTO ENG_REVISED_COMPONENTS (
	COMPONENT_SEQUENCE_ID,
	COMPONENT_ITEM_ID,
 	OPERATION_SEQUENCE_NUM,
 	BILL_SEQUENCE_ID,
	CHANGE_NOTICE,
	EFFECTIVITY_DATE,
 	COMPONENT_QUANTITY,
	COMPONENT_YIELD_FACTOR,
	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
	CREATION_DATE,
 	CREATED_BY,
	LAST_UPDATE_LOGIN,
 	CANCELLATION_DATE,
 	OLD_COMPONENT_SEQUENCE_ID,
	ITEM_NUM,
	WIP_SUPPLY_TYPE,
 	COMPONENT_REMARKS,
	SUPPLY_SUBINVENTORY,
	SUPPLY_LOCATOR_ID,
 	DISABLE_DATE,
	ACD_TYPE,
 	PLANNING_FACTOR,
	QUANTITY_RELATED,
	SO_BASIS,
 	OPTIONAL,
	MUTUALLY_EXCLUSIVE_OPTIONS,
	INCLUDE_IN_COST_ROLLUP,
 	CHECK_ATP,
	SHIPPING_ALLOWED,
 	REQUIRED_TO_SHIP,
	REQUIRED_FOR_REVENUE,
	INCLUDE_ON_SHIP_DOCS,
 	LOW_QUANTITY,
	HIGH_QUANTITY,
 	REVISED_ITEM_SEQUENCE_ID,
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
	ATTRIBUTE15)
    SELECT
 	IC.COMPONENT_SEQUENCE_ID,
	IC.COMPONENT_ITEM_ID,
 	IC.OPERATION_SEQ_NUM,
 	IC.BILL_SEQUENCE_ID,
	IC.CHANGE_NOTICE,
	IC.EFFECTIVITY_DATE,
 	IC.COMPONENT_QUANTITY,
	IC. COMPONENT_YIELD_FACTOR,
	SYSDATE,
 	user_id,
	SYSDATE,
 	user_id,
 	login,
 	sysdate,
 	IC.OLD_COMPONENT_SEQUENCE_ID,
	IC.ITEM_NUM,
	IC.WIP_SUPPLY_TYPE,
 	IC.COMPONENT_REMARKS,
	IC.SUPPLY_SUBINVENTORY,
	IC.SUPPLY_LOCATOR_ID,
 	IC.DISABLE_DATE,
	IC.ACD_TYPE,
 	IC.PLANNING_FACTOR,
	IC.QUANTITY_RELATED,
	IC.SO_BASIS,
 	IC.OPTIONAL,
	IC.MUTUALLY_EXCLUSIVE_OPTIONS,
	IC.INCLUDE_IN_COST_ROLLUP,
 	IC.CHECK_ATP,
	IC.SHIPPING_ALLOWED,
 	IC.REQUIRED_TO_SHIP,
	IC.REQUIRED_FOR_REVENUE,
	IC.INCLUDE_ON_SHIP_DOCS,
 	IC.LOW_QUANTITY,
	IC.HIGH_QUANTITY,
 	IC.REVISED_ITEM_SEQUENCE_ID,
 	IC.ATTRIBUTE_CATEGORY,
 	IC.ATTRIBUTE1,
	IC.ATTRIBUTE2,
	IC.ATTRIBUTE3,
	IC.ATTRIBUTE4,
	IC.ATTRIBUTE5,
 	IC.ATTRIBUTE6,
	IC.ATTRIBUTE7,
	IC.ATTRIBUTE8,
	IC.ATTRIBUTE9,
	IC.ATTRIBUTE10,
 	IC.ATTRIBUTE11,
	IC.ATTRIBUTE12,
	IC.ATTRIBUTE13,
	IC.ATTRIBUTE14,
 	IC.ATTRIBUTE15
    FROM BOM_INVENTORY_COMPONENTS IC
    WHERE IC.REVISED_ITEM_SEQUENCE_ID = rev_item_seq;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows inserted into erc');

/*
** delete the rows from bom_inventory_components
*/
    stmt_num := 50;
    DELETE FROM BOM_INVENTORY_COMPONENTS IC
    WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from bic');

/*Special handling for Editable common bom*/
for common in is_editable_common_bom1(rev_item_seq) loop
/*
** delete the rows from bom_inventory_components
*/

    DELETE FROM BOM_INVENTORY_COMPONENTS IC
    WHERE  IC.BILL_SEQUENCE_ID = common.bill_sequence_id  ;
end loop;

/*
** delete item revisions created by revised items on ECO
*/
    stmt_num := 50;
   -- Modified where clause for performance bug 4251776
   delete from MTL_ITEM_REVISIONS_TL
   WHERE revision_id IN (select new_item_revision_id
                         from eng_revised_items I
                         WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq);

   /*where revision_id IN (select revision_id
                         from MTL_ITEM_REVISIONS_B I
                         WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq);*/
    -- Modified where clause for performance bug 4251776
    DELETE FROM MTL_ITEM_REVISIONS_B I --Fix for bug 3215586
    WHERE revision_id IN (select new_item_revision_id
                         from eng_revised_items I
                         WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq);

    /*WHERE REVISED_ITEM_SEQUENCE_ID = rev_item_seq;*/

-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from eri');

/*
** Syalaman - Fix for bug 6469639.
** delete UDA data created by revised items on ECO
*/
  stmt_num := 60;

  DELETE FROM EGO_MTL_SY_ITEMS_EXT_TL A
  WHERE A.REVISION_ID IN (SELECT NEW_ITEM_REVISION_ID
                          FROM ENG_REVISED_ITEMS
                          WHERE NEW_ITEM_REVISION_ID IS NOT NULL
                                AND REVISED_ITEM_SEQUENCE_ID = rev_item_seq);

  DELETE FROM EGO_MTL_SY_ITEMS_EXT_B A
  WHERE A.REVISION_ID IN (SELECT NEW_ITEM_REVISION_ID
                          FROM ENG_REVISED_ITEMS
                          WHERE NEW_ITEM_REVISION_ID IS NOT NULL
                                AND REVISED_ITEM_SEQUENCE_ID = rev_item_seq);
-- Syalaman - End of fix for bug 6469639.

/*
** delete the bom header if bill was created by this revised item and
** nothing else references this
*/
/* This is to fix bug 1522704. Now cancellation of ECO won't delete
corresponding row from bom_bill_of_materials. Deletion will be done by
delete groups only. Here two line of code is added update BOM_BILL_OF_MATERIALS B
set pending_from_ecn = null*/
    stmt_num := 70;
   DELETE FROM BOM_BILL_OF_MATERIALS B
   WHERE B.BILL_SEQUENCE_ID = bill_seq_id
    AND   B.PENDING_FROM_ECN = change_order
    AND   NOT EXISTS (SELECT NULL
                  FROM BOM_INVENTORY_COMPONENTS C
                  WHERE C.BILL_SEQUENCE_ID = B.BILL_SEQUENCE_ID
                  AND (C.REVISED_ITEM_SEQUENCE_ID IS NULL
                      OR C.REVISED_ITEM_SEQUENCE_ID <> rev_item_seq))
    AND  ((B.ALTERNATE_BOM_DESIGNATOR IS NULL
         AND NOT EXISTS (SELECT NULL
                       FROM BOM_BILL_OF_MATERIALS B2
                       WHERE B2.ORGANIZATION_ID = B.ORGANIZATION_ID
                       AND   B2.ASSEMBLY_ITEM_ID = B.ASSEMBLY_ITEM_ID
                       AND   B2.ALTERNATE_BOM_DESIGNATOR IS NOT NULL))
         OR
        (NOT EXISTS (SELECT NULL
                       FROM ENG_REVISED_ITEMS R
                       WHERE R.ORGANIZATION_ID = B.ORGANIZATION_ID
                       AND   R.BILL_SEQUENCE_ID = B.BILL_SEQUENCE_ID
		       AND   R.REVISED_ITEM_SEQUENCE_ID <> rev_item_seq
		       AND   R.STATUS_TYPE <> 5)));

/*
** if bill was deleted, then unset the bill_sequence_id on the revise item
*/
--  if (SQL%ROWCOUNT > 0) then
--dbms_output.put_line('Deleted BOM header');
    	stmt_num := 80;
	UPDATE ENG_REVISED_ITEMS  R
	SET    BILL_SEQUENCE_ID = ''
	         WHERE  R.REVISED_ITEM_SEQUENCE_ID = rev_item_seq;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows updated in eri for bsi');
--  end if;

/*
** if bill was deleted, then unset the bill_sequence_id on the revise item
*/
--  if (SQL%ROWCOUNT > 0) then
--dbms_output.put_line('Deleted BOM header');
    	stmt_num := 90;
	UPDATE ENG_REVISED_ITEMS  R
	SET   ALTERNATE_BOM_DESIGNATOR = ''
	         WHERE  R.REVISED_ITEM_SEQUENCE_ID = rev_item_seq
		 AND ROUTING_SEQUENCE_ID IS NULL;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows updated in eri for bsi');
--  end if;

EXCEPTION
    WHEN OTHERS THEN
	rollback;
        err_text := 'Cancel_Revised_Item' || '(' || stmt_num || ')' || SQLERRM;
    	FND_MESSAGE.SET_NAME('BOM', 'BOM_SQL_ERR');
    	FND_MESSAGE.SET_TOKEN('ENTITY', err_text);
    	APP_EXCEPTION.RAISE_EXCEPTION;
END Cancel_Revised_Item;

Procedure Cancel_Revised_Component (
    comp_seq_id		number,
    user_id		number,
    login		number,
    comment		varchar2
) IS
    err_text		varchar2(2000);
    stmt_num		number;
    -- R12 changes for common bom
    -- Cursor to fetch all the related components for the specified component being cancelled
    CURSOR c_related_components IS
    SELECT component_sequence_id
    FROM bom_components_b
    WHERE common_component_sequence_id = comp_seq_id;
Begin
/*
** insert the cancelled rev components into eng_revised_components
*/
    stmt_num := 10;
    INSERT INTO ENG_REVISED_COMPONENTS (
	COMPONENT_SEQUENCE_ID,
	COMPONENT_ITEM_ID,
 	OPERATION_SEQUENCE_NUM,
 	BILL_SEQUENCE_ID,
	CHANGE_NOTICE,
	EFFECTIVITY_DATE,
 	COMPONENT_QUANTITY,
	COMPONENT_YIELD_FACTOR,
	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
	CREATION_DATE,
 	CREATED_BY,
	LAST_UPDATE_LOGIN,
 	CANCELLATION_DATE,
        CANCEL_COMMENTS,
 	OLD_COMPONENT_SEQUENCE_ID,
	ITEM_NUM,
	WIP_SUPPLY_TYPE,
 	COMPONENT_REMARKS,
	SUPPLY_SUBINVENTORY,
	SUPPLY_LOCATOR_ID,
 	DISABLE_DATE,
	ACD_TYPE,
 	PLANNING_FACTOR,
	QUANTITY_RELATED,
	SO_BASIS,
 	OPTIONAL,
	MUTUALLY_EXCLUSIVE_OPTIONS,
	INCLUDE_IN_COST_ROLLUP,
 	CHECK_ATP,
	SHIPPING_ALLOWED,
 	REQUIRED_TO_SHIP,
	REQUIRED_FOR_REVENUE,
	INCLUDE_ON_SHIP_DOCS,
 	LOW_QUANTITY,
	HIGH_QUANTITY,
 	REVISED_ITEM_SEQUENCE_ID,
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
	ATTRIBUTE15)
    SELECT
 	IC.COMPONENT_SEQUENCE_ID,
	IC.COMPONENT_ITEM_ID,
 	IC.OPERATION_SEQ_NUM,
 	IC.BILL_SEQUENCE_ID,
	IC.CHANGE_NOTICE,
	IC.EFFECTIVITY_DATE,
 	IC.COMPONENT_QUANTITY,
	IC. COMPONENT_YIELD_FACTOR,
	SYSDATE,
 	user_id,
	SYSDATE,
 	user_id,
 	login,
 	sysdate,
        comment,
 	IC.OLD_COMPONENT_SEQUENCE_ID,
	IC.ITEM_NUM,
	IC.WIP_SUPPLY_TYPE,
 	IC.COMPONENT_REMARKS,
	IC.SUPPLY_SUBINVENTORY,
	IC.SUPPLY_LOCATOR_ID,
 	IC.DISABLE_DATE,
	IC.ACD_TYPE,
 	IC.PLANNING_FACTOR,
	IC.QUANTITY_RELATED,
	IC.SO_BASIS,
 	IC.OPTIONAL,
	IC.MUTUALLY_EXCLUSIVE_OPTIONS,
	IC.INCLUDE_IN_COST_ROLLUP,
 	IC.CHECK_ATP,
	IC.SHIPPING_ALLOWED,
 	IC.REQUIRED_TO_SHIP,
	IC.REQUIRED_FOR_REVENUE,
	IC.INCLUDE_ON_SHIP_DOCS,
 	IC.LOW_QUANTITY,
	IC.HIGH_QUANTITY,
 	IC.REVISED_ITEM_SEQUENCE_ID,
 	IC.ATTRIBUTE_CATEGORY,
 	IC.ATTRIBUTE1,
	IC.ATTRIBUTE2,
	IC.ATTRIBUTE3,
	IC.ATTRIBUTE4,
	IC.ATTRIBUTE5,
 	IC.ATTRIBUTE6,
	IC.ATTRIBUTE7,
	IC.ATTRIBUTE8,
	IC.ATTRIBUTE9,
	IC.ATTRIBUTE10,
 	IC.ATTRIBUTE11,
	IC.ATTRIBUTE12,
	IC.ATTRIBUTE13,
	IC.ATTRIBUTE14,
 	IC.ATTRIBUTE15
    FROM BOM_INVENTORY_COMPONENTS IC
    WHERE IC.COMPONENT_SEQUENCE_ID = comp_seq_id;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows inserted into erc');

/*
** delete from bom_inventory_comps
*/
    DELETE FROM BOM_INVENTORY_COMPONENTS
    WHERE  COMPONENT_SEQUENCE_ID = comp_seq_id;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows delete from bic');

  -- Fixed bug 618781.
  -- Cancelling of Revised component must also cancel the
  -- Subs. components and the reference designators.

/*
**	Delete the Substitute Components and also the Reference Designators
*/
    DELETE FROM BOM_SUBSTITUTE_COMPONENTS SC
    WHERE SC.COMPONENT_SEQUENCE_ID = comp_seq_id;

-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from bsc');

/*
** delete reference designators of all pending revised items on ECO
*/
    stmt_num := 30;
    DELETE FROM BOM_REFERENCE_DESIGNATORS RD
        WHERE RD.COMPONENT_SEQUENCE_ID = comp_seq_id;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from rfd');

    stmt_num := 40;

    FOR crc IN c_related_components
    LOOP
        stmt_num := stmt_num+1;
        /* delete from bom_inventory_comps */
        DELETE FROM bom_components_b
        WHERE  COMPONENT_SEQUENCE_ID = crc.COMPONENT_SEQUENCE_ID;
        stmt_num := stmt_num+1;
        /* delete the Substitute Components and also the Reference Designators */
        DELETE FROM BOM_SUBSTITUTE_COMPONENTS SC
        WHERE SC.COMPONENT_SEQUENCE_ID = crc.COMPONENT_SEQUENCE_ID;
        /* Delete reference designators of all pending revised items on ECO */
        stmt_num := stmt_num+1;
        DELETE FROM BOM_REFERENCE_DESIGNATORS RD
        WHERE RD.COMPONENT_SEQUENCE_ID = crc.COMPONENT_SEQUENCE_ID;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
	rollback;
        err_text :=  'Cancel_Revised_Component' || '(' || stmt_num || ')' ||
		SQLERRM;
    	FND_MESSAGE.SET_NAME('BOM', 'BOM_SQL_ERR');
    	FND_MESSAGE.SET_TOKEN('ENTITY', err_text);
    	APP_EXCEPTION.RAISE_EXCEPTION;
END Cancel_Revised_Component;

/*
Changing the attachment status to '' when the approval / review is being cancelled
*/
Procedure Change_Att_Status (
    p_change_id		number,
    user_id		number,
    login_id		number
)
IS
    err_text		varchar2(2000);
Begin
    SAVEPOINT before_status_update;
    update fnd_attached_documents
      set status = '',
          last_update_date = sysdate,
          last_updated_by = user_id,
          last_update_login = login_id
      where attached_document_id in
      (SELECT attachment_id FROM eng_attachment_changes WHERE change_id = p_change_id);
EXCEPTION
    WHEN OTHERS THEN
	rollback;
        err_text := 'Change_Attachment_Status' || '(' || ')' || SQLERRM;
    	FND_MESSAGE.SET_NAME('BOM', 'BOM_SQL_ERR');
    	FND_MESSAGE.SET_TOKEN('ENTITY', err_text);
    	APP_EXCEPTION.RAISE_EXCEPTION;
END Change_Att_Status;

END ENG_CANCEL_ECO;

/
