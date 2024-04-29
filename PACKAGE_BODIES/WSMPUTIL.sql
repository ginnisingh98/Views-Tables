--------------------------------------------------------
--  DDL for Package Body WSMPUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPUTIL" AS
/* $Header: WSMUTILB.pls 120.6.12010000.7 2010/03/03 15:45:59 sisankar ship $ */

/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name     : wsmutilb.pls                                              |
| Description   : Contains the following procedures :
|       FUNCTION    CHECK_WSM_ORG
|       PROCEDURE   find_routing_start              - overridden
|       PROCEDURE   find_routing_end                - overridden
|       FUNCTION    GET_SCHEDULED_DATE              - overridden
|       FUNCTION    GET_DEF_ACCT_CLASS_CODE
|       PROCEDURE   GET_DEF_COMPLETION_SUB_DTLS     - overridden
|       FUNCTION    primary_loop_test
|       PROCEDURE   GET_DEFAULT_SUB_LOC
|       PROCEDURE   UPDATE_SUB_LOC
|       FUNCTION    CHECK_IF_ORG_IS_VALID
|       PROCEDURE   WRITE_TO_WIE
|       PROCEDURE   find_common_routing
|       FUNCTION    get_routing_start
|       FUNCTION    get_routing_end
|       FUNCTION    CHECK_COPROD_RELATION
|       FUNCTION    CHECK_COPROD_COMP_RELATION
|       FUNCTION    CHECK_COPROD_RELATION
|       FUNCTION    CHECK_100_PERCENT
|       PROCEDURE   AUTONOMOUS_TXN
|       PROCEDURE   OPERATION_IS_STANDARD_REPEATS   - overridden
|       PROCEDURE   validate_non_std_references
|       FUNCTION    WSM_ESA_ENABLED
|       FUNCTION    WSM_CHANGE_ESA_FLAG
|       FUNCTION    network_with_disabled_op
|       FUNCTION    primary_path_is_effective_till
|       FUNCTION    effective_next_op_exists
|       FUNCTION    effective_next_op_exits
|       FUNCTION    wlt_if_costed
|       PROCEDURE   check_charges_exist
|       FUNCTION    replacement_op_seq_id
|       FUNCTION    check_po_move
|       PROCEDURE   validate_lbj_before_close
|       PROCEDURE   get_Kanban_rec_grp_info
|       PROCEDURE   get_max_kanban_asmbly_qty
|       PROCEDURE   return_att_quantity
|       FUNCTION    check_osp_operation
|       FUNCTION    CHECK_WLMTI                     - overridden and commented
|       FUNCTION    CHECK_WMTI                      - overridden and commented
|       FUNCTION    CHECK_WSMT                      - overridden and commented
|       FUNCTION    CHECK_WMT                       - commented
|       FUNCTION    CHECK_WSMTI                     - commented
|       FUNCTION    JOBS_WITH_QTY_AT_FROM_OP        - overridden
|       FUNCTION    CREATE_LBJ_COPY_RTG_PROFILE     - overridden
|       FUNCTION    GET_INV_ACCT_PERIOD
|       PROCEDURE   AUTONOMOUS_WRITE_TO_WIE
|       FUNCTION    GET_JOB_BOM_SEQ_ID
|       FUNCTION    replacement_copy_op_seq_id
|       FUNCTION    get_internal_copy_type
|   PROCEDURE   lock_wdj
|                                                                           |
| Revision                                                                  |
|  04/24/00   Anirban Dey       Initial Creation                            |
+==========================================================================*/



/***************************************************************************************/

FUNCTION CHECK_WSM_ORG (
                p_organization_id   IN  NUMBER,
                x_err_code          OUT NOCOPY NUMBER,
                x_err_msg           OUT NOCOPY VARCHAR2
                )
RETURN INTEGER
IS
    l_stmt_num  NUMBER := 0;
    l_rowcount  NUMBER := 0;
BEGIN

    x_err_code := 0;
    x_err_msg := '';
    l_stmt_num := 10;
    /*
    ** commented out by Bala Balakumar, June 01, 2000.
    SELECT  count(*)
    INTO    l_rowcount
    FROM    MTL_PARAMETERS MP
    WHERE   MP.ORGANIZATION_ID = p_organization_id
    AND     UPPER(WSM_ENABLED_FLAG)='Y';
    */

    /* Check_wsm_org should also include a check to
    ** see if a record exists in wsm_parameters table
    */

    SELECT  count(*)
        INTO    l_rowcount
        FROM    MTL_PARAMETERS MP, WSM_PARAMETERS WSM
        WHERE   WSM.ORGANIZATION_ID = p_organization_id
    AND MP.ORGANIZATION_ID = WSM.ORGANIZATION_ID
        AND     UPPER(MP.WSM_ENABLED_FLAG)='Y';

    x_err_code := 0;
    x_err_msg := 'WSMPUTIL.CHECK_WSM_ORG: Success';
    return(l_rowcount);

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPUTIL.CHECK_WSM_ORG: (stmt_num='||l_stmt_num||'): '||SUBSTR(SQLERRM,1,60);
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
        return(0);

END CHECK_WSM_ORG;


/***************************************************************************************/

-- CZH.I_OED-2, currently, the primary key of BON is (FROM_OP_SEQ_ID, TO_OP_SEQ_ID)
-- if the operation of START_OP_SEQ_ID is not effective as of P_ROUTING_REV_DATE,
-- find_routing_start() will call replacement_op_seq_id() to see if it has a replacement
-- or not. IF it has a replacement, find_routing_start() will return x_err_code = 0,
-- NOT -3, however, the START_OP_SEQ_ID returned will STILL be the one defined in BON


PROCEDURE find_routing_start(
             p_routing_sequence_id NUMBER,
         start_op_seq_id       OUT NOCOPY NUMBER,
         x_err_code            OUT NOCOPY NUMBER,
         x_err_msg             OUT NOCOPY VARCHAR2) IS
l_rtg_rev_date  DATE := SYSDATE;
BEGIN
    find_routing_start(
             p_routing_sequence_id,
             l_rtg_rev_date,
             start_op_seq_id,
             x_err_code,
             x_err_msg);
END;

-- CZH.I_OED-1, override function
PROCEDURE find_routing_start(
             p_routing_sequence_id NUMBER,
             p_routing_rev_date    DATE,
         start_op_seq_id       OUT NOCOPY NUMBER,
         x_err_code            OUT NOCOPY NUMBER,
         x_err_msg             OUT NOCOPY VARCHAR2) IS

l_eff_date      DATE;   -- ADD: CZH.I_OED-1
l_dis_date      DATE;   -- ADD: CZH.I_OED-1
l_rtg_rev_date  DATE;   -- ADD: CZH I_OED-1
l_count         number; -- ADD: CZH.I_OED-1.BUG2558058

-- CZH I_OED-1: 07/03/02
-- this cursor finds a bon.from_op_seq_id, which is in BOS and effective
-- and is not in BON.to_op_seq_id
--
-- bon.disable/effectivity_date is never used before I project. They will
-- be used in the stage 2 of this project.
--
-- For stage 1, we will find the start of the routing without
-- considering the effective/disable date of the operations in BOS

-- BC: CZH I_OED-1
CURSOR get_start IS
  SELECT UNIQUE bon.from_op_seq_id
  FROM   bom_operation_networks bon
  WHERE  bon.from_op_seq_id IN (
           SELECT operation_sequence_id
           FROM   bom_operation_sequences
           WHERE  routing_sequence_id = p_routing_sequence_id
         )
  AND    NOT EXISTS (  --bon.from_op_seq_id NOT IN
           SELECT 'X'  --unique bon1.to_op_seq_id
           FROM   bom_operation_networks bon1
           WHERE  bon1.to_op_seq_id = bon.from_op_seq_id
           AND EXISTS (  --bon1.to_op_seq_id IN
             SELECT 'X'  --operation_sequence_id
             FROM   bom_operation_sequences
             WHERE  bon1.to_op_seq_id   = operation_sequence_id
             AND    routing_sequence_id = p_routing_sequence_id
           )
         );
-- EC: CZH I_OED-1:

BEGIN

    x_err_code := 0;
    l_rtg_rev_date := NVL(p_routing_rev_date, SYSDATE);  -- CZH I_OED-1

-- BC: CZH I_OED-1

    -- BA: CZH.I_OED-1.BUG2558058, no network defined
    --     error_code -1 is reserved for WSM_NO_NETWORK_EXISTS
    SELECT count(*)
    INTO   l_count
    FROM   bom_operation_networks bon
    WHERE  bon.from_op_seq_id IN (
           SELECT operation_sequence_id
           FROM   bom_operation_sequences
           WHERE  routing_sequence_id = p_routing_sequence_id
           );
    IF(l_count = 0) THEN
        x_err_code := -1;
        FND_MESSAGE.SET_NAME('WSM','WSM_NO_NETWORK_EXISTS');
        x_err_msg  := FND_MESSAGE.GET;
        RETURN;
    END IF;
    -- EA: CZH.I_OED-1.BUG2558058

    OPEN get_start;

    FETCH get_start INTO start_op_seq_id;

    IF get_start%NOTFOUND THEN
        x_err_code := -2;          -- CZH I_OED-1, BUG2558058 changed to -2
        FND_MESSAGE.SET_NAME('WSM','WSM_NET_START_NOT_FOUND');
        x_err_msg:= FND_MESSAGE.GET;
        RETURN;
    END IF;

    LOOP
        IF get_start%ROWCOUNT >1 THEN
            x_err_code := -2;         -- CZH I_OED-1
            FND_MESSAGE.SET_NAME('WSM','WSM_NET_MULTIPLE_STARTS');
            x_err_msg:= FND_MESSAGE.GET;
            RETURN;
        END IF;

        FETCH get_start INTO start_op_seq_id;
        EXIT WHEN get_start%NOTFOUND;
    END LOOP;

    CLOSE get_start;

    -- CZH.I_OED-1, check if the start_op is effective or not
    -- BC: CZH.I_OED-2, if it has a replacement, do not error out with x_err_code -3
    --     We will not return the replacement op_seq_id either, because in BON,
    --     start_op_seq_id is the 'START', and some cursors rely on this
    SELECT effectivity_date,
           nvl(disable_date, l_rtg_rev_date+2)
    INTO   l_eff_date,
           l_dis_date
    FROM   bom_operation_sequences
    WHERE  routing_sequence_id = p_routing_sequence_id
    AND    operation_sequence_id = start_op_seq_id;

    --IF (l_eff_date > l_rtg_rev_date OR l_dis_date <= l_rtg_rev_date) THEN
    IF (l_rtg_rev_date NOT Between l_eff_date  and l_dis_date ) THEN  -- HH24MISS Add
        IF(NVL(WSMPUTIL.replacement_op_seq_id(
                         start_op_seq_id,
                         l_rtg_rev_date), -1) = -1) THEN  -- ADD: CZH.I_OED-2
            x_err_code := -3;
            FND_MESSAGE.SET_NAME('WSM','WSM_NET_START_NOT_EFFECTIVE');
            x_err_msg:= FND_MESSAGE.GET;
            RETURN;
        END IF;                                           -- ADD: CZH.I_OED-2
    END IF;

-- EC: CZH I_OED-1
/*
-- OSP Begin Changes

    If check_po_move (
             p_sequence_id      => p_routing_sequence_id,
             p_sequence_id_type => 'R' ,
         p_routing_rev_date => l_rtg_rev_date,
         x_err_code         => x_err_code ,
         x_err_msg          => x_err_msg ) then

    x_err_code := -4;
        FND_MESSAGE.SET_NAME('WSM','WSM_FIRST_OP_PO_MOVE');
        x_err_msg:= FND_MESSAGE.GET;
        RETURN;
    end if;

-- OSP End Changes
*/
EXCEPTION
    WHEN OTHERS THEN
    x_err_code := SQLCODE;
    x_err_msg  := 'WSMPUTIL.FIND_ROUTING_START '|| SUBSTR(SQLERRM,1,60);
    -- FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
    RETURN;

END find_routing_start;


/*****************************************************************************/

-- CZH.I_OED-2, currently, the primary key of BON is (FROM_OP_SEQ_ID, TO_OP_SEQ_ID)
-- if the operation of END_OP_SEQ_ID is not effective as of P_ROUTING_REV_DATE,
-- find_routing_end() will call replacement_op_seq_id() to see if it has a replacement
-- or not. IF it has a replacement, find_routing_start() will return x_err_code = 0,
-- NOT -3, however, the END_OP_SEQ_ID returned will STILL be the one defined in BON

PROCEDURE find_routing_end(
             p_routing_sequence_id NUMBER,
             end_op_seq_id         OUT NOCOPY NUMBER,
             x_err_code            OUT NOCOPY NUMBER,
             x_err_msg             OUT NOCOPY VARCHAR2) IS
l_rtg_rev_date  DATE := SYSDATE;
BEGIN
        find_routing_end(
             p_routing_sequence_id,
             l_rtg_rev_date,
             end_op_seq_id,
             x_err_code,
             x_err_msg);
END;


-- CZH.I_OED-1, override function
PROCEDURE find_routing_end (
              p_routing_sequence_id     NUMBER,
              p_routing_rev_date        DATE,
              end_op_seq_id         OUT NOCOPY NUMBER,
          x_err_code            OUT NOCOPY NUMBER,
          x_err_msg             OUT NOCOPY VARCHAR2 ) IS

l_eff_date      DATE;   -- ADD: CZH.I_OED-1
l_dis_date      DATE;   -- ADD: CZH.I_OED-1
l_rtg_rev_date  DATE;   -- ADD: CZH I_OED-1
l_count         number; -- ADD: CZH.I_OED-1.BUG2558058


-- CZH.I_OED-1: 07/03/02
-- For stage 1, we will find the end of the routing without
-- considering the effective/disable date of the operations in BOS

-- BC: CZH I_OED-1
CURSOR get_end IS
  SELECT UNIQUE bon.to_op_seq_id
  FROM   bom_operation_networks bon
  WHERE  bon.to_op_seq_id IN (
           SELECT operation_sequence_id
           FROM   bom_operation_sequences
           WHERE  routing_sequence_id = p_routing_sequence_id
         )
  AND    NOT EXISTS (  --bon.from_op_seq_id NOT IN
           SELECT 'X'  --unique bon1.to_op_seq_id
           FROM   bom_operation_networks bon1
           WHERE  bon1.from_op_seq_id = bon.to_op_seq_id
           AND EXISTS (        --bon1.to_op_seq_id IN
             SELECT 'X'  --operation_sequence_id
             FROM   bom_operation_sequences
             WHERE  bon1.from_op_seq_id = operation_sequence_id
             AND    routing_sequence_id = p_routing_sequence_id
           )
         );
-- EC: CZH I_OED-1

BEGIN

    x_err_code := 0;
    l_rtg_rev_date := NVL(p_routing_rev_date, SYSDATE);  -- CZH I_OED-1


-- BC: CZH I_OED-1

    -- BA: CZH.I_OED-1.BUG2558058, no network defined
    --     error_code -1 is reserved for WSM_NO_NETWORK_EXISTS
    SELECT count(*)
    INTO   l_count
    FROM   bom_operation_networks bon
    WHERE  bon.from_op_seq_id IN (
           SELECT operation_sequence_id
           FROM   bom_operation_sequences
           WHERE  routing_sequence_id = p_routing_sequence_id
           );
    IF(l_count = 0) THEN
        x_err_code := -1;
        FND_MESSAGE.SET_NAME('WSM','WSM_NO_NETWORK_EXISTS');
        x_err_msg  := FND_MESSAGE.GET;
        RETURN;
    END IF;
    -- EA: CZH.I_OED-1.BUG2558058

    OPEN get_end;
    FETCH get_end INTO end_op_seq_id;

    IF get_end%NOTFOUND THEN
        x_err_code := -2;          -- CZH I_OED-1, BUG2558058 changed to -2
        FND_MESSAGE.SET_NAME('WSM','WSM_NET_END_NOT_FOUND');
        x_err_msg:= FND_MESSAGE.GET;
        RETURN;
    END IF;

    LOOP
        IF get_end%ROWCOUNT >1 THEN
            x_err_code := -2;          -- CZH I_OED-1
            FND_MESSAGE.SET_NAME('WSM','WSM_NET_MULTIPLE_ENDS');
            x_err_msg:= FND_MESSAGE.GET;
            RETURN;
        END IF;
        FETCH get_end INTO end_op_seq_id;
        EXIT WHEN get_end%NOTFOUND;
    END LOOP;

    CLOSE get_end;

    -- CZH.I_OED-1: check if the end_op is effective or not
    -- BC: CZH.I_OED-2, if it has a replacement, do not error out with x_err_code -3.
    --     We will not return the replacement op_seq_id either, because in BON,
    --     end_op_seq_id is the 'END', and some cursors rely on this
    SELECT effectivity_date,
           nvl(disable_date, l_rtg_rev_date+2)
    INTO   l_eff_date,
           l_dis_date
    FROM   bom_operation_sequences
    WHERE  routing_sequence_id = p_routing_sequence_id
    AND    operation_sequence_id = end_op_seq_id;

    --IF (l_eff_date > l_rtg_rev_date OR l_dis_date <= l_rtg_rev_date) THEN
    IF (l_rtg_rev_date NOT Between l_eff_date  and l_dis_date ) THEN  -- HH24MISS Add
        IF(NVL(WSMPUTIL.replacement_op_seq_id(
                         end_op_seq_id,
                         l_rtg_rev_date), -1) = -1) THEN -- ADD: CZH.I_OED-2
            x_err_code := -3;
            FND_MESSAGE.SET_NAME('WSM','WSM_NET_END_NOT_EFFECTIVE');
            x_err_msg:= FND_MESSAGE.GET;
            RETURN;
        END IF;                                          -- ADD: CZH.I_OED-2
    END IF;

-- EC: CZH I_OED-1

EXCEPTION
    WHEN OTHERS THEN
    x_err_code := SQLCODE;
    x_err_msg := 'WSMPUTIL.FIND_ROUTING_END '|| SUBSTR(SQLERRM,1,60);
    -- BD: 1964044 -- FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg); -- ED: 1964044
    RETURN;

END find_routing_end;



/*****************************************************************************/

   --
   -- This is an over-loaded function which calls the same function
   -- with p_quantity parameter.
   --
   -- This is created to circumvent the dependency issues with forms and other objects
   --

   FUNCTION GET_SCHEDULED_DATE
                (
        p_organization_id       IN      NUMBER,
        p_primary_item_id    IN  NUMBER,
        p_schedule_method       IN      VARCHAR2,
        p_input_date            IN      DATE,
                x_err_code              OUT NOCOPY     NUMBER,
                x_err_msg               OUT NOCOPY     VARCHAR2
                )
   RETURN DATE IS

   x_output_date    DATE;

   BEGIN
            x_output_date := Get_Scheduled_Date
                (
        p_organization_id   => p_organization_id,
        p_primary_item_id   => p_primary_item_id,
        p_schedule_method   => p_schedule_method,
        p_input_date        => p_input_date,
                x_err_code      => x_err_code,
                x_err_msg       => x_err_msg,
        p_quantity      => 0
                );

        return x_output_date;

   END GET_SCHEDULED_DATE;


/*****************************************************************************/

 --
 -- Since this is an overloaded function, we shouldn't have
 -- DEFAULT clause on p_quantity. Else, you'll get the following error
 -- while calling this function.
 -- PLS-00307: too many declarations of 'GET_SCHEDULED_DATE'
 --            match this call
 --

FUNCTION GET_SCHEDULED_DATE (
    p_organization_id       IN  NUMBER,
    p_primary_item_id       IN  NUMBER,
    p_schedule_method       IN  VARCHAR2,
    p_input_date            IN  DATE,
    x_err_code              OUT NOCOPY     NUMBER,
    x_err_msg               OUT NOCOPY     VARCHAR2,
    p_quantity              IN  NUMBER
            )
RETURN DATE
IS
   x_output_date    DATE;
   l_lead_time      NUMBER;
   l_cum_mfg_lead_time  NUMBER;
   l_stmt_num       NUMBER;
   l_fixed_lead_time    NUMBER;
   l_variable_lead_time NUMBER;


   CURSOR forward_cur(p_lead_time NUMBER) IS
    SELECT  BCD1.CALENDAR_DATE
    FROM    BOM_CALENDAR_DATES BCD1,
        BOM_CALENDAR_DATES BCD2,
        MTL_PARAMETERS MP
    WHERE   MP.ORGANIZATION_ID = p_organization_id
    AND BCD1.CALENDAR_CODE = MP.CALENDAR_CODE
    AND BCD2.CALENDAR_CODE = MP.CALENDAR_CODE
    AND BCD1.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
    AND     BCD2.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
    AND BCD2.CALENDAR_DATE = TRUNC(p_input_date)
    AND BCD1.SEQ_NUM = NVL(BCD2.SEQ_NUM, BCD2.NEXT_SEQ_NUM) +
                CEIL(p_lead_time);

   CURSOR backward_cur(p_lead_time NUMBER) IS
        SELECT  BCD1.CALENDAR_DATE
        FROM    BOM_CALENDAR_DATES BCD1,
                BOM_CALENDAR_DATES BCD2,
                MTL_PARAMETERS MP
        WHERE   MP.ORGANIZATION_ID = p_organization_id
        AND     BCD1.CALENDAR_CODE = MP.CALENDAR_CODE
        AND     BCD2.CALENDAR_CODE = MP.CALENDAR_CODE
        AND     BCD1.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
        AND     BCD2.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
        AND     BCD2.CALENDAR_DATE = TRUNC(p_input_date)
        AND     BCD1.SEQ_NUM = NVL(BCD2.SEQ_NUM, BCD2.PRIOR_SEQ_NUM) +
                               DECODE(p_lead_time, 0, 0, 1-CEIL(p_lead_time));
                                /* Bugfix:     1383041
                   PrevStmt:   1 - CEIL(p_lead_time); */


BEGIN

    l_stmt_num := 10;

--  SELECT  NVL(MSI.CUM_MANUFACTURING_LEAD_TIME, 0)
--  SELECT  NVL(MSI.full_lead_time, 0)
--  INTO    l_cum_mfg_lead_time
--  FROM    MTL_SYSTEM_ITEMS MSI
--  WHERE   MSI.organization_id = p_organization_id
--  AND MSI.inventory_item_id = p_primary_item_id;

    SELECT  nvl(fixed_lead_time,0), nvl(variable_lead_time,0)
      INTO  l_fixed_lead_time, l_variable_lead_time
      FROM  MTL_SYSTEM_ITEMS
      WHERE organization_id = p_organization_id
      AND   inventory_item_id = p_primary_item_id;

    IF (SQL%NOTFOUND) THEN
        l_cum_mfg_lead_time := 0;
    END IF;

    l_cum_mfg_lead_time := l_fixed_lead_time + l_variable_lead_time * p_quantity;

    IF (UPPER(p_schedule_method) = 'F') THEN
            l_stmt_num := 20;

        OPEN forward_cur(l_cum_mfg_lead_time);
        FETCH forward_cur INTO x_output_date;
        IF (forward_cur%NOTFOUND) THEN
            x_output_date := SYSDATE;
        END IF;
        CLOSE forward_cur;
        x_err_code := 0;
--      RETURN x_output_date+( p_input_date - TRUNC(p_input_date));
     ELSIF (UPPER(p_schedule_method) = 'B') THEN
            l_stmt_num := 30;

                OPEN backward_cur(l_cum_mfg_lead_time);
                FETCH backward_cur INTO x_output_date;
                IF (backward_cur%NOTFOUND) THEN
                        x_output_date := SYSDATE;
                END IF;
                CLOSE backward_cur;
                x_err_code := 0;
--              RETURN x_output_date + ( p_input_date - TRUNC(p_input_date));
    ELSE
            l_stmt_num := 40;

        x_output_date := SYSDATE;
        x_err_code := 0;
--              RETURN x_output_date + ( p_input_date - TRUNC(p_input_date));
    END IF;

    RETURN x_output_date + ( p_input_date - TRUNC(p_input_date));

    l_stmt_num := 50;


EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPUTIL.GET_SCHEDULED_DATE('||l_stmt_num||
                '): '|| SUBSTR(SQLERRM,1,60);
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
        return SYSDATE;

END GET_SCHEDULED_DATE;


/*****************************************************************************/


FUNCTION GET_DEF_ACCT_CLASS_CODE (
            p_organization_id       IN      NUMBER,
            p_inventory_item_id     IN      NUMBER,
    p_subinventory_name IN  VARCHAR2,
            x_err_code              OUT NOCOPY     NUMBER,
            x_err_msg               OUT NOCOPY     VARCHAR2
            )
RETURN VARCHAR2
IS
l_stmt_num   NUMBER;
x_accounting_class_code  VARCHAR2(10);

BEGIN
    x_err_code := 0;
    x_err_msg := NULL;
    l_stmt_num := 10;

    BEGIN
        SELECT  WSE.DEFAULT_ACCT_CLASS_CODE
        INTO    x_accounting_class_code
        FROM    WSM_SECTOR_EXTENSIONS WSE,
                WSM_ITEM_EXTENSIONS WIE
        WHERE   WIE.organization_id = p_organization_id
        AND     WIE.inventory_item_id = p_inventory_item_id
        AND     WIE.sector_extension_id = WSE.sector_extension_id
        AND     WSE.organization_id = WIE.organization_id;

        IF x_accounting_class_code IS NOT NULL THEN
            RETURN x_accounting_class_code;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        x_accounting_class_code := NULL;
    END;

    BEGIN
        IF x_accounting_class_code IS NULL THEN
            SELECT  WSE.DEFAULT_ACCT_CLASS_CODE
            INTO    x_accounting_class_code
            FROM    WSM_SECTOR_EXTENSIONS WSE,
                    WSM_SUBINVENTORY_EXTENSIONS WSUE
            WHERE   WSUE.organization_id = p_organization_id
            AND     WSUE.secondary_inventory_name = p_subinventory_name
            AND     WSUE.sector_extension_id = WSE.sector_extension_id
            AND     WSUE.organization_id = WSE.organization_id;
        END IF;

        IF x_accounting_class_code IS NOT NULL THEN
            RETURN x_accounting_class_code;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        x_accounting_class_code := NULL;
    END ;

    BEGIN
        IF x_accounting_class_code IS NULL THEN
            SELECT default_acct_class_code
            INTO    x_accounting_class_code
            from  wsm_parameters
            WHERE organization_id = p_organization_id;
        END IF;

        IF x_accounting_class_code IS NOT NULL THEN
                RETURN x_accounting_class_code;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        x_accounting_class_code := NULL;
    END;

    IF x_accounting_class_code IS  NULL THEN
        RETURN NULL;
    END IF;

EXCEPTION
       WHEN OTHERS THEN
           x_err_code := SQLCODE;
           x_err_msg := 'WSMPTUIL.GET_DEF_ACCT_CLASS_CODE('||l_stmt_num||'): '||SUBSTR(SQLERRM,1,60);
       FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
           return NULL;
END GET_DEF_ACCT_CLASS_CODE;


/*****************************************************************************/

PROCEDURE GET_DEF_COMPLETION_SUB_DTLS (
                p_organization_id       IN      NUMBER,
                p_routing_sequence_id   IN      NUMBER,
                x_subinventory_code     OUT NOCOPY     VARCHAR2,
                x_locator_id            OUT NOCOPY     NUMBER,
                x_err_code              OUT NOCOPY     NUMBER,
                x_err_msg               OUT NOCOPY     VARCHAR2
                ) IS
BEGIN
        GET_DEF_COMPLETION_SUB_DTLS (
                p_organization_id,
                p_routing_sequence_id,
                SYSDATE,
                x_subinventory_code,
                x_locator_id,
                x_err_code,
                x_err_msg
        );
END;


-- CZH: overloading function

PROCEDURE GET_DEF_COMPLETION_SUB_DTLS (
        p_organization_id   IN  NUMBER,
                p_routing_sequence_id   IN      NUMBER,
                p_routing_revision_date IN      DATE,
                x_subinventory_code     OUT NOCOPY     VARCHAR2,
                x_locator_id            OUT NOCOPY     NUMBER,
                x_err_code              OUT NOCOPY     NUMBER,
                x_err_msg               OUT NOCOPY     VARCHAR2
              ) IS
l_stmt_num      NUMBER;
l_operation_seq_id  NUMBER;

-- BA NSO-WLT
x_standard_operation_id NUMBER;
not_std_op EXCEPTION;
-- EA NSO-WLT

BEGIN
    x_subinventory_code := NULL;
    x_err_code := 0;
    x_err_msg := NULL;
    x_locator_id := NULL;

    l_stmt_num := 10;


    FIND_ROUTING_END(
              p_routing_sequence_id,
              p_routing_revision_date, --ADD: CZH
              l_operation_seq_id,
              x_err_code,
              x_err_msg);

    IF (x_err_code <> 0 ) THEN
    x_subinventory_code := NULL;
    x_locator_id := NULL;
    return;
    END IF;

    --BA:  CZH.I_OED-2, consider replacement
    l_operation_seq_id := WSMPUTIL.replacement_op_seq_id(
                                   l_operation_seq_id,
                                   p_routing_revision_date);
    --EA:  CZH.I_OED-2

    IF (l_operation_seq_id IS NOT NULL) THEN
      -- BA NSO-WLT
        x_standard_operation_id := 0;
        l_stmt_num := 15;

        SELECT nvl(standard_operation_id, -999)
        INTO   x_standard_operation_id
        FROM   bom_operation_sequences
        WHERE  operation_sequence_id = l_operation_seq_id;

        IF x_standard_operation_id <> -999 then
        -- EA NSO-WLT

        l_stmt_num := 20;
--MES replacing WSM_OPERATION_DETAILS with BOM_STANDARD_OPERATIONS
/*
            -- BA NSO-WLT
        SELECT  WOD.SECONDARY_INVENTORY_NAME,
                    WOD.INVENTORY_LOCATION_ID
        INTO    x_subinventory_code,
            x_locator_id
        FROM    WSM_OPERATION_DETAILS WOD,
                BOM_OPERATION_SEQUENCES BOS
        WHERE   BOS.operation_sequence_id  = l_operation_seq_id
        AND     BOS.routing_sequence_id = p_routing_sequence_id
        AND     nvl(WOD.standard_operation_id, -999) = nvl(BOS.standard_operation_id, -999)
        AND     WOD.organization_id = p_organization_id;
        -- EA NSO-WLT
*/
        -- BA NSO-WLT
        SELECT  BSO.DEFAULT_SUBINVENTORY,
                BSO.DEFAULT_LOCATOR_ID
        INTO    x_subinventory_code,
                x_locator_id
        FROM    BOM_STANDARD_OPERATIONS BSO,
                BOM_OPERATION_SEQUENCES BOS
        WHERE   BOS.operation_sequence_id  = l_operation_seq_id
        AND     BOS.routing_sequence_id = p_routing_sequence_id
        AND     nvl(BSO.standard_operation_id, -999) = nvl(BOS.standard_operation_id, -999)
        AND     BSO.organization_id = p_organization_id;
        -- EA NSO-WLT

        IF (SQL%NOTFOUND) THEN
        l_stmt_num := 30;
        x_subinventory_code := NULL;
        x_locator_id := NULL;
        return;
        END IF;

        -- BA NSO-WLT
        ELSE
            l_stmt_num := 35;
            raise NOT_STD_OP;
        END IF;
        -- EA NSO-WLT

    END IF;

    l_stmt_num := 40;

    RETURN;


EXCEPTION

    -- BA NSO-WLT
    WHEN NOT_STD_OP THEN
        x_subinventory_code := NULL;
        x_locator_id := NULL;
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPTUIL.GET_DEF_COMPLETION_SUB_DTLS('||l_stmt_num||
                        '): '|| SUBSTR(SQLERRM,1,60);
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
        return ;
   -- EA NSO-WLT

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPTUIL.GET_DEF_COMPLETION_SUB_DTLS('||l_stmt_num||
                        '): '|| SUBSTR(SQLERRM,1,60);
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
        return ;

END GET_DEF_COMPLETION_SUB_DTLS;


/*********************************************************************/


FUNCTION  primary_loop_test     (
                  p_routing_sequence_id NUMBER,
                  start_id NUMBER,
                  end_id NUMBER,
                  x_err_code OUT NOCOPY NUMBER,
                  x_err_msg OUT NOCOPY VARCHAR2 )
RETURN NUMBER IS


x_from_id   NUMBER;
x_meet_num  NUMBER;
x_temp      NUMBER;
dumnum      NUMBER;
p_count     NUMBER;
l_st_num    NUMBER;

BEGIN


l_st_num := 5;

    -- BA: bug 3170719
    -- if two records in BON has the same op_seq_num but different op_seq_id
    -- we will error out
    declare
        cursor get_ops is
            select  bos.operation_seq_num           op_seq_num,
                    bos.operation_sequence_id       op_seq_id
            from    bom_operation_networks      bon,
                    bom_operation_sequences     bos
            where   bos.routing_sequence_id = p_routing_sequence_id
            and     bon.from_op_seq_id = bos.operation_sequence_id
            union
            select  bos.operation_seq_num           op_seq_num,
                    bos.operation_sequence_id       op_seq_id
            from    bom_operation_networks      bon,
                    bom_operation_sequences     bos
            where   bos.routing_sequence_id = p_routing_sequence_id
            and     bon.to_op_seq_id = bos.operation_sequence_id;

        type t_number   is table of number       index by binary_integer;
        op_seq_ids      t_number;
    begin
        op_seq_ids.delete;
        for op_rec in get_ops loop
            if op_seq_ids.exists(op_rec.op_seq_num) then
                FND_MESSAGE.SET_NAME('WSM','WSM_NET_DUP_OP_SEQ_NUM');
                x_err_msg:= FND_MESSAGE.GET;
                RETURN 1;
            else
                op_seq_ids(op_rec.op_seq_num) := op_rec.op_seq_id;
            end if;
        end loop;
    end;
    -- EA: bug 3170719


l_st_num := 10;

    BEGIN

        SELECT 1
        INTO   dumnum
        FROM   bom_operation_networks
        WHERE  from_op_seq_id = start_id
        AND    transition_type = 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

            FND_MESSAGE.SET_NAME('WSM','WSM_START_SHOULD_BE_PRIMARY');
            x_err_msg:= FND_MESSAGE.GET;
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN 1;

        WHEN TOO_MANY_ROWS THEN

            FND_MESSAGE.SET_NAME('WSM','WSM_MULT_PRIMARY_STARTS');
            x_err_msg:= FND_MESSAGE.GET;
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN 1;
    END;

l_st_num := 20;

    BEGIN

        SELECT 1
        INTO   dumnum
        FROM   bom_operation_networks
        WHERE  to_op_seq_id = end_id
        AND    transition_type =1 ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

            FND_MESSAGE.SET_NAME('WSM','WSM_END_SHOULD_BE_PRIMARY');
            x_err_msg := FND_MESSAGE.GET;
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN 1;

        WHEN TOO_MANY_ROWS THEN
            FND_MESSAGE.SET_NAME('WSM','WSM_MULT_PRIMARY_ENDS');
            x_err_msg:= FND_MESSAGE.GET;
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN 1;

    END;

-- OSFMAPSP2 Integration -- Add -- Start - BBK.

l_st_num := 25;

    Declare

    l_from_opseq_num NUMBER;
    l_to_opseq_num NUMBER;

    Begin

        select bos1.operation_seq_num
               , bos2.operation_seq_num
        into   l_from_opseq_num, l_to_opseq_num
        from   bom_operation_networks bon
               , bom_operation_sequences bos1
               , bom_operation_sequences bos2
        where  bos1.routing_sequence_id = p_routing_sequence_id
        and    bos2.routing_sequence_id = bos1.routing_sequence_id
        and    bon.from_op_seq_id = bos1.operation_sequence_id
        and    bos2.operation_sequence_id = bon.to_op_seq_id
        group by bos1.routing_sequence_id
               , bos1.operation_seq_num
               , bos2.operation_seq_num
        having count(bon.from_op_seq_id) > 1;

    If sql%rowcount <> 0 Then
            FND_MESSAGE.SET_NAME('WSM','WSM_DUPLICATE_LINK');
            fnd_message.set_token('FROM_OPSEQ_NUM', l_from_opseq_num);
            fnd_message.set_token('TO_OPSEQ_NUM', l_to_opseq_num);
            x_err_msg:= FND_MESSAGE.GET;
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN 1;
    End If;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        Null; -- NO duplicates found.

        WHEN TOO_MANY_ROWS THEN
            FND_MESSAGE.SET_NAME('WSM','WSM_DUPLICATE_LINKS_EXIST');
            x_err_msg:= FND_MESSAGE.GET;
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN 1;

    END;


-- OSFMAPSP2 Integration -- Add -- End  - BBK.

l_st_num := 30;

    BEGIN

        SELECT  count(*)
        INTO    p_count
        FROM    BOM_OPERATION_NETWORKS_V
        WHERE   routing_sequence_id = p_routing_sequence_id
        AND     transition_type = 1
        AND     from_op_seq_id NOT IN
            (SELECT to_op_seq_id
             FROM   BOM_OPERATION_NETWORKS_V
             WHERE  routing_sequence_id = p_routing_sequence_id
             AND    transition_type = 1 );

        IF p_count > 1 THEN
            FND_MESSAGE.SET_NAME('WSM','WSM_MULT_PRIMARY_PATHS');
            x_err_msg:= FND_MESSAGE.GET;
        END IF;

    END ;

l_st_num := 40;

    x_from_id := start_id;

    WHILE  x_from_id <> end_id LOOP

        BEGIN
            SELECT to_op_seq_id, to_seq_num
            INTO   x_temp,x_meet_num
            FROM   bom_operation_networks_v
            WHERE  from_op_seq_id = x_from_id
            AND    transition_type = 1;

        EXCEPTION
            WHEN TOO_MANY_ROWS  then
                FND_MESSAGE.SET_NAME('WSM','WSM_MULTIPLE_PRIMARY_PATHS_START');
                FND_MESSAGE.SET_TOKEN('WSM_SEQ_NUM',x_meet_num);
                x_err_msg:= FND_MESSAGE.GET;
                FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
                RETURN 1;

            WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('WSM','WSM_PRIMARY_PATH_END_IMPROPER');
                FND_MESSAGE.SET_TOKEN('WSM_SEQ_NUM',x_meet_num);
                x_err_msg:= FND_MESSAGE.GET;
                FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
                RETURN 1;
        END;

l_st_num := 40;

        BEGIN
            SELECT count(*)
            INTO   p_count
            FROM   BOM_OPERATION_NETWORKS
            WHERE  to_op_seq_id = x_from_id
            AND    transition_type = 1;

            IF p_count > 1 THEN
                SELECT from_seq_num
                INTO   x_meet_num
                FROM   BOM_OPERATION_NETWORKS_V
                WHERE  from_op_seq_id = x_from_id;

                FND_MESSAGE.SET_NAME('WSM','WSM_MULT_PRIMARY_PATHS_MEET');
                FND_MESSAGE.SET_TOKEN('WSM_SEQ_NUM',x_meet_num);
                x_err_msg:= FND_MESSAGE.GET;
            END IF;

        END;

        x_from_id := x_temp;

    END LOOP ;

    RETURN 0;

l_st_num := 50;

EXCEPTION

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPTUIL.PRIMARY_LOOP_TEST.('||l_st_num||
                                    '): '|| SUBSTR(SQLERRM,1,60);
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
    RETURN 1;

END primary_loop_test;

/*************************************************************************/

PROCEDURE GET_DEFAULT_SUB_LOC ( p_org_id IN NUMBER ,
                p_routing_sequence_id IN NUMBER,
                p_end_id IN NUMBER,
                x_completion_subinventory OUT NOCOPY VARCHAR2,
                x_inventory_location_id OUT NOCOPY NUMBER,
                x_err_code OUT NOCOPY NUMBER,
                x_err_msg OUT NOCOPY VARCHAR2 ) IS


x_standard_operation_id NUMBER;
no_sub EXCEPTION;

-- BA NSO-WLT: Non-Standard Operations Project code change by Sadiq.
not_std_op EXCEPTION;
-- EA NSO-WLT

BEGIN

    x_completion_subinventory := NULL;
    x_inventory_location_id := 0;

    -- BA NSO-WLT
    SELECT nvl(standard_operation_id, '-999')
    INTO   x_standard_operation_id
    FROM   bom_operation_sequences
    WHERE  operation_sequence_id = p_end_id;

    IF x_standard_operation_id <> -999 then
    -- EA NSO-WLT
--MES replacing WSM_OPERATION_DETAILS with BOM_STANDARD_OPERATIONS
/*
        SELECT secondary_inventory_name, inventory_location_id
        INTO  x_completion_subinventory,x_inventory_location_id
        FROM wsm_operation_details
        WHERE standard_operation_id = x_standard_operation_id
        AND organization_id = p_org_id;
*/
        SELECT DEFAULT_SUBINVENTORY, DEFAULT_LOCATOR_ID
        INTO  x_completion_subinventory,x_inventory_location_id
        FROM BOM_STANDARD_OPERATIONS
        WHERE standard_operation_id = x_standard_operation_id
        AND organization_id = p_org_id;

        IF x_completion_subinventory IS NULL THEN
            RAISE NO_SUB;
        END IF;

    -- BA NSO-WLT
    ELSE
        raise not_std_op;
    END IF;
    -- EA NSO-WLT

EXCEPTION

    WHEN NO_SUB THEN
        x_err_code := -1;
        FND_MESSAGE.SET_NAME('WSM','WSM_END_OPERATION_STK_PT');
        x_err_msg:= FND_MESSAGE.GET||' '||x_completion_subinventory;
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);

    -- BA NSO-WLT
    WHEN NOT_STD_OP THEN
        x_err_code := -1;
        FND_MESSAGE.SET_NAME('WSM','WSM_END_OPERATION_STK_PT');
        x_err_msg:= FND_MESSAGE.GET||' '||x_completion_subinventory;
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
    -- EA NSO-WLT

    WHEN NO_DATA_FOUND THEN
        x_err_code := -1;
        FND_MESSAGE.SET_NAME('WSM','WSM_END_OPERATION_STK_PT');
        x_err_msg:= FND_MESSAGE.GET||' '||x_completion_subinventory;
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPTUIL.DEFAULT_SUB_LOC:' || SUBSTR(SQLERRM,1,60);
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);

END GET_DEFAULT_SUB_LOC;

/************************************************************************/


PROCEDURE UPDATE_SUB_LOC (  p_routing_sequence_id IN NUMBER,
                p_completion_subinventory IN VARCHAR2,
                p_inventory_location_id IN  NUMBER,
                x_err_code OUT NOCOPY NUMBER,
                x_err_msg OUT NOCOPY VARCHAR2 ) IS

BEGIN
    UPDATE bom_operational_routings
    SET completion_subinventory =  p_completion_subinventory
    WHERE routing_sequence_id = p_routing_sequence_id;

    UPDATE bom_operational_routings
    SET completion_locator_id = p_inventory_location_id
    WHERE routing_sequence_id = p_routing_sequence_id;

EXCEPTION

    WHEN OTHERS THEN
            x_err_code := SQLCODE;
            x_err_msg := 'WSMPTUIL.UPDATE_SUB_LOC:' || SUBSTR(SQLERRM,1,60);
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);

END UPDATE_SUB_LOC;




/**************************************************************************/


/*
** Function CHECK_IF_ORG_IS_VALID to check for the validity
** of an organization for use in WSM.
** The following checks are made;
** 1. Org should be a Standard Costing Method Org.
** 2. Org should have inventory item lot number set to NON-UNIQUE.
** 3. Org should have WIP Parameter lot number default type to JOBNAME.
** 4. Org should NOT be WPS enabled in WIP Parameter table.
** BA#1490834
** 5. Org should NOT be WMS enabled in Inventory Parameters.
** EA#1490834
*/

FUNCTION CHECK_IF_ORG_IS_VALID
        ( p_organization_id   IN NUMBER,
          x_err_code          OUT NOCOPY NUMBER,
          x_err_msg           OUT NOCOPY VARCHAR2
        )
RETURN INTEGER
IS

        l_stmt_num  NUMBER := 0;
        l_rowcount  NUMBER := 0;

        l_lotNumberUniqueNess number default 0;
                -- 1:UniqueForItem, 2:NoUniqueness

        l_primaryCostMethod number default 0;
                -- 1:Standard, 2: Average.

        l_lotNumberDefaultType number default 0;
                -- 1:JobName, 2:InvRules.

        l_wpsEnabledFlag number default 0;
                -- 1:Yes, 2:No.

/*BA#1490834*/

        l_wmsEnabledFlag varchar2(1) default 'N';
                -- 1:Yes, 2:No.

        e_wmsEnabled EXCEPTION;
/*EA#1490834*/

        e_lotNumberUniqueness EXCEPTION;
        e_primaryCostMethod EXCEPTION;
        e_lotNumberDefaultType EXCEPTION;
        e_wpsEnabled EXCEPTION;

        -- Bug#2131807 PJM enabled check.
        e_pjmEnabled EXCEPTION;
        l_pjm_Enabled boolean default FALSE;


Begin

        l_stmt_num := l_stmt_num + 10;

        Select  MTL.LOT_NUMBER_UNIQUENESS,
                MTL.PRIMARY_COST_METHOD,
                WIP.LOT_NUMBER_DEFAULT_TYPE,
                WIP.USE_FINITE_SCHEDULER
                /*BA#1490834*/
                , MTL.WMS_ENABLED_FLAG
                /*EA#1490834*/
        into
                l_lotNumberUniqueNess,
                l_primaryCostMethod,
                l_lotNumberDefaultType,
                l_wpsEnabledFlag
                /*BA#1490834*/
                , l_wmsEnabledFlag
                /*EA#1490834*/
        From    MTL_PARAMETERS MTL, WIP_PARAMETERS WIP
        Where   MTL.organization_id = p_organization_id
        And     MTL.organization_id = WIP.organization_id (+);

        If      l_primaryCostMethod <> 1 Then
                 -- NON_STANDARD costing method
                fnd_message.set_name('WSM', 'WSM_ORG_NOT_STD_COST');
                raise e_primaryCostMethod;

        ElsIf   l_lotNumberUniqueness <> 2 Then
                -- LotNumber is NOT Non-UNIQUE
                fnd_message.set_name('WSM', 'WSM_ORG_LOT_NONUNIQUE');
                raise e_lotNumberUniqueness;

        ElsIf   l_lotNumberDefaultType <> 1 Then
                 -- Default Type is NOT JOBNAME
                fnd_message.set_name('WSM', 'WSM_ORG_LOT_DEFAULT_TYPE');
                raise e_lotNumberDefaultType;

-- Start comments to fix bug #2006687
-- Commented out the following check and moved this code to WSMFPARM.fmb
-- This is done to enable Agilent to have a WPS enabled OSFM org.
--                ElsIf   NVL(l_wpsEnabledFlag, 2) = 1 Then
--                         -- Org is WPS Enabled. Raise exception.
--
--                        fnd_message.set_name('WSM', 'WSM_ORG_WPS_ENABLED');
--                        raise e_wpsEnabled;
-- End comments to fix bug #2006687

    /*BA#1490834*/
-- OSFM and WMS can coexist, so this check
-- is being removed

-- ElsIf   NVL(l_wmsEnabledFlag, 'N') = 'Y' Then
--     -- Org is WMS Enabled. Raise exception.
--
--     fnd_message.set_name('WSM', 'WSM_ORG_WM$
--     raise e_wmsEnabled;
    /*EA#1490834*/
        Else

                -- Bug#2131807 PJM enabled check.

                l_stmt_num := 20;

                l_pjm_enabled := PJM_INSTALL.check_implementation_status(
                                p_organization_id => p_organization_id);

                If l_pjm_enabled = TRUE Then
                        fnd_message.set_name('WSM', 'WSM_ORG_PJM_ENABLED');
                        raise e_pjmEnabled;
                End If;

                -- Bug#2131807 PJM enabled check.

                return 0;

        End If;

EXCEPTION
        When e_primaryCostMethod Then
                x_err_code := 1;
                x_err_msg := fnd_message.get;
                FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
                return(x_err_code);

        When e_lotNumberUniqueness Then
                x_err_code := 2;
                x_err_msg := fnd_message.get;
                FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
                return(x_err_code);

        When e_lotNumberDefaultType Then
                x_err_code := 3;
                x_err_msg := fnd_message.get;
                FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
                return(x_err_code);

        When e_wpsEnabled Then
                x_err_code := 4;
                x_err_msg := fnd_message.get;
                FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
                return(x_err_code);

        /*BA#1490834*/
        When e_wmsEnabled Then
                x_err_code := 5;
                x_err_msg := fnd_message.get;
                return(x_err_code);
        /*EA#1490834*/

        -- Bug#2131807 PJM enabled check.
        When e_pjmEnabled Then -- Bug#2131807 check PJM enabled
                x_err_code := 6;
                x_err_msg := fnd_message.get;
                FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
                return(x_err_code);

        WHEN OTHERS Then
                x_err_code := SQLCODE;
                x_err_msg :=
                 'WSMPUTIL.CHECK_IF_ORG_IS_VALID: (stmt_num='||
                 l_stmt_num||'): '||
                 SUBSTR(SQLERRM,1,60);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
                return(x_err_code);


End CHECK_IF_ORG_IS_VALID;

/**************************************************************************/
-- written by abedajna, 09/07/00

PROCEDURE WRITE_TO_WIE (    p_header_id IN NUMBER,
                p_message IN VARCHAR2,
                p_request_id  IN  NUMBER,
                p_program_id  IN NUMBER,
                p_program_application_id IN NUMBER,
                p_message_type IN NUMBER,
                x_err_code  OUT NOCOPY NUMBER,
                        x_err_msg   OUT NOCOPY VARCHAR2) IS


    x_user NUMBER := FND_GLOBAL.user_id;
    x_login NUMBER := FND_GLOBAL.login_id;


BEGIN

    INSERT INTO WSM_INTERFACE_ERRORS (
                     HEADER_ID,
                         MESSAGE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             REQUEST_ID,
             PROGRAM_ID,
             PROGRAM_APPLICATION_ID,
             MESSAGE_TYPE    )
    values (
            p_header_id,
            p_message,
            SYSDATE,
            x_user,
            SYSDATE,
            x_user,
            x_login,
            p_request_id,
            p_program_id,
            p_program_application_id,
            p_message_type );


EXCEPTION

    WHEN OTHERS THEN
            x_err_code := SQLCODE;
                x_err_msg := 'WSMPTUIL.WRITE_TO_WIE:' || SUBSTR(SQLERRM,1,60);
                FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);

END WRITE_TO_WIE;

/*BA#1577747*/

/* Procedure to get the common routing sequence id for a given
** Routing sequence id.  If the given routing is not a common
** routing, then the routing sequence id and the common routing sequence
** id will be the same. -- bbk
*/


/*****************************************************************************/

PROCEDURE find_common_routing ( p_routing_sequence_id IN NUMBER,
                                p_common_routing_sequence_id OUT NOCOPY NUMBER,
                                x_err_code OUT NOCOPY NUMBER,
                                x_err_msg OUT NOCOPY VARCHAR2 ) IS

    l_routing_sequence_id NUMBER;
    l_common_routing_sequence_id NUMBER default -999;
    prev_common_rout_seq_id NUMBER;

Begin

        l_routing_sequence_id := p_routing_sequence_id;

        WHILE NVL(l_routing_sequence_id,-999) <>
                NVL(l_common_routing_sequence_id, -999) Loop

                -- l_counter := l_counter+1;
                --dbms_output.put_line('Counter is '||l_counter);

                Select  routing_sequence_id
                        , common_routing_sequence_id
                Into
                        l_routing_sequence_id
                        , l_common_routing_sequence_id

                From BOM_OPERATIONAL_ROUTINGS

                Where routing_sequence_id = l_routing_sequence_id;


                If  l_routing_sequence_id <>
                        l_common_routing_sequence_id Then

                        prev_common_rout_seq_id := l_common_routing_sequence_id;
                        l_common_routing_sequence_id := -999;
                        l_routing_sequence_id := prev_common_rout_seq_id;

        Else

            p_common_routing_sequence_id := l_common_routing_sequence_id;

                End If;


    End Loop;

EXCEPTION

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPTUIL.FIND_COMMON_ROUTING:' || SUBSTR(SQLERRM,1,60);
        -- FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);

End find_common_routing;

/*EA#1577747*/

-- BA OSFM-APS integration.
-- Function submitted by Raghav Raghavacharya for OSFM-APS integration.
-- Added to this file by Sadiq

/*****************************************************************************/

FUNCTION get_routing_start( p_routing_sequence_id       IN  NUMBER)
RETURN NUMBER
IS
    v_op_seq_num number;
    v_operation_sequence_id number;
    x_err_msg varchar2(2000); -- modified by bbk
    x_err_code  number; -- modified by bbk
    /*BA#1577747*/
    e_user_exception EXCEPTION;
    p_common_routing_sequence_id NUMBER;
    /*EA#1577747*/
BEGIN
    /*BA#1577747*/

    WSMPUTIL.find_common_routing(
        p_routing_sequence_id => p_routing_sequence_id,
                p_common_routing_sequence_id => p_common_routing_sequence_id,
                x_err_code => x_err_code,
                x_err_msg => x_err_msg
        );

    If x_err_code <> 0 Then
        raise e_user_exception;
    End If;

    /*EA#1577747*/

    WSMPUTIL.find_routing_start(
                        -- p_routing_sequence_id, -- bbk
                        p_common_routing_sequence_id, -- use this to find start.
                        SYSDATE, --CZH: call with sysdate
                        v_operation_sequence_id ,
                        x_err_code,
                        x_err_msg);
        -- BA: CZH I_OED-1
        IF (x_err_code <> 0 and x_err_code <> -3) THEN  -- BUGFIX 3056524, ignore -3 also
                raise e_user_exception;
        END IF;
        -- EA: CZH I_OED-1

    select operation_seq_num
    into v_op_seq_num
    from bom_operation_sequences
    where operation_sequence_id = v_operation_sequence_id;

    return v_op_seq_num;

EXCEPTION
    WHEN E_USER_EXCEPTION THEN
        -- FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
        return 0;

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPTUIL.GET_ROUTING_START' || SUBSTR(SQLERRM,1,60);
        -- FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
        return 0;

End get_routing_start;


/*****************************************************************************/

FUNCTION get_routing_end( p_routing_sequence_id       IN  NUMBER)
RETURN NUMBER
IS

    v_operation_sequence_id number;
    v_op_seq_num number;

    x_err_msg varchar2(2000); -- modified by bbk
    x_err_code  number; -- modified by bbk
    /*BA#1577747*/
    e_user_exception EXCEPTION;
    p_common_routing_sequence_id NUMBER;
    /*EA#1577747*/

 BEGIN
    /*BA#1577747*/

    WSMPUTIL.find_common_routing(
        p_routing_sequence_id => p_routing_sequence_id,
                p_common_routing_sequence_id => p_common_routing_sequence_id,
                x_err_code => x_err_code,
                x_err_msg => x_err_msg
        );

    If x_err_code <> 0 Then
        raise e_user_exception;
    End If;


    /*EA#1577747*/

    WSMPUTIL.find_routing_end(
                        p_common_routing_sequence_id ,
                        SYSDATE, -- CZH, call with SYSDATE
                        v_operation_sequence_id ,
                        x_err_code,
                        x_err_msg);
        -- BA: CZH I_OED-1
        IF (x_err_code <> 0 and x_err_code <> -3) THEN -- BUGFIX 3056524, ignore -3 also
                raise e_user_exception;
        END IF;
        -- EA: CZH I_OED-1

    select operation_seq_num
    into   v_op_seq_num
    from   bom_operation_sequences
    where  operation_sequence_id = v_operation_sequence_id;

    return v_op_seq_num;

EXCEPTION
    WHEN E_USER_EXCEPTION THEN
        -- BD: 1964044 -- FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);   -- ED: 1964044
        return 0;

    WHEN OTHERS THEN
            x_err_code := SQLCODE;
                x_err_msg := 'WSMPTUIL.GET_ROUTING_END' || SUBSTR(SQLERRM,1,60);
        -- BD: 1964044 -- FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg); -- ED: 1964044
        return 0;

End get_routing_end;

-- EA OSFM-APS integration.


/*
    Added on 12.29.2000 to fix Bug # 1418785.
    This function checks if a co-product relationship
    exists for a given bill sequence.
*/

/*****************************************************************************/

FUNCTION CHECK_COPROD_RELATION
(
        p_bom_bill_seq_id       IN NUMBER,
        x_err_code              OUT NOCOPY NUMBER,
        x_err_msg               OUT NOCOPY VARCHAR2
)
RETURN BOOLEAN IS

        x_relation_exists       BOOLEAN := TRUE;
    temp_bill_seq_id    NUMBER := 0;
        l_stmt_num              NUMBER  := 0;

BEGIN

    x_err_code := 0;
    x_err_msg := '';

    SELECT bill_sequence_id
    INTO   temp_bill_seq_id
    FROM   wsm_co_products coprod
    WHERE  p_bom_bill_seq_id = coprod.bill_sequence_id;

    -- IF Clause added by Bala on Feb 8th, 2000.
    -- Bug# 1418785 not returning any values.

    If SQL%ROWCOUNT > 0 Then
        return TRUE;
    End If;

EXCEPTION

    WHEN OTHERS THEN
      x_err_code := SQLCODE;
      x_err_msg := substr(('WSMPUTIL.check_coprod_relation'||SUBSTR(SQLERRM,1,1000)), 1, 1000);
      x_relation_exists := FALSE;
      RETURN x_relation_exists;

END CHECK_COPROD_RELATION;

--BA 2731019
FUNCTION CHECK_COPROD_COMP_RELATION
(
        p_bom_bill_seq_id       IN NUMBER,
        p_component_seq_id       IN NUMBER
)
RETURN NUMBER IS
        temp_bill_seq_id        NUMBER := 0;
BEGIN

    SELECT bill_sequence_id
    INTO   temp_bill_seq_id
    FROM   wsm_co_products coprod
    WHERE  p_bom_bill_seq_id = coprod.bill_sequence_id
    AND    p_component_seq_id = coprod.COMPONENT_SEQUENCE_ID;

    If SQL%ROWCOUNT > 0 Then
        return 1;
    ELSE
    return 0;
    End If;

EXCEPTION

    WHEN OTHERS THEN
      RETURN 0;

END CHECK_COPROD_COMP_RELATION;
--EA 2731019

/*****************************************************************************/
-- This is an overloaded function created for BOM USE alone..BBK
FUNCTION CHECK_COPROD_RELATION (
        p_bom_bill_seq_id       IN NUMBER
)
RETURN NUMBER IS

        l_relation_exists       NUMBER := 0;
    l_relation_exist_boolean BOOLEAN := FALSE;
        l_err_code              NUMBER := 0;
        l_err_msg               VARCHAR2(1000) := NULL;

BEGIN

    l_relation_exist_boolean := WSMPUTIL.check_coprod_relation (
                    p_bom_bill_seq_id => p_bom_bill_seq_id
                    , x_err_code => l_err_code
                    , x_err_msg => l_err_msg);

    If  l_err_code <> 0
        or l_err_msg <> NULL
        or l_relation_exist_boolean = FALSE Then

        l_relation_exists := 0;
    Else
        l_relation_exists := 1;

    End If;

    return l_relation_exists;

EXCEPTION

    WHEN OTHERS THEN
        l_relation_exists := 0;
    RETURN l_relation_exists;

END CHECK_COPROD_RELATION;

/*****************************************************************************/
/*
**
**  This procedure is added to validate
**  that the sum of planning percentages
**  of all links emanating from each node
**  exactly adds up to 100. This enhancement
**  is done along with the APS-WSM integration
**
*/

/*****************************************************************************/

FUNCTION CHECK_100_PERCENT (    p_routing_sequence_id   IN NUMBER,
                                x_err_code              OUT NOCOPY NUMBER,
                                x_err_msg               OUT NOCOPY VARCHAR2)
RETURN NUMBER  IS

    var_total_planning_pct NUMBER;
    p_from_seq_num NUMBER;

    CURSOR check_percentage_sum IS
    SELECT distinct (from_seq_num)
    FROM bom_operation_networks_v
    WHERE routing_sequence_id = p_routing_sequence_id
    ORDER BY from_seq_num ;

BEGIN

    OPEN check_percentage_sum;

    LOOP
        FETCH check_percentage_sum INTO p_from_seq_num ;
        EXIT WHEN check_percentage_sum%NOTFOUND;

    SELECT SUM(planning_pct)
    INTO   var_total_planning_pct
    FROM   bom_operation_networks_v
    WHERE  from_seq_num =  p_from_seq_num
    AND    transition_type IN (1, 2)
        AND    routing_sequence_id = p_routing_sequence_id ;

    IF( var_total_planning_pct <> 100) THEN

       FND_MESSAGE.SET_NAME('WSM','WSM_%_SUM_NOT_100');
       FND_MESSAGE.SET_TOKEN('WSM_SEQ_NUM',p_from_seq_num);
       x_err_msg:= FND_MESSAGE.GET;
       x_err_code := -1  ;
           RETURN 0;
           EXIT;

        END IF ;

    END LOOP ;

    IF check_percentage_sum%ISOPEN THEN
       CLOSE check_percentage_sum;
    END IF;

    RETURN 1;

EXCEPTION WHEN OTHERS THEN

      x_err_code := SQLCODE;
      x_err_msg := 'WSMPUTIL.check_100_percent : '||SUBSTR(SQLERRM,1,1000);
      RETURN 0;
      IF check_percentage_sum%ISOPEN THEN
      CLOSE check_percentage_sum;
      END IF;
END CHECK_100_PERCENT;


/*****************************************************************************/

/*BA#1641781*/
PROCEDURE AUTONOMOUS_TXN(p_user IN NUMBER,
            p_login IN NUMBER,
            p_header_id IN NUMBER,
                        p_message IN VARCHAR2,
                        p_request_id IN NUMBER,
                        p_program_id IN NUMBER,
                        p_program_application_id IN NUMBER,
                        p_message_type IN NUMBER,
                        p_txn_id IN NUMBER,
                        x_err_code OUT NOCOPY NUMBER,
                        x_err_msg OUT NOCOPY VARCHAR2)

IS
   PRAGMA autonomous_transaction;
BEGIN
    INSERT INTO WSM_INTERFACE_ERRORS (
            HEADER_ID,
            TRANSACTION_ID,
                MESSAGE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            MESSAGE_TYPE    )
        values (
            p_header_id,
            p_txn_id,
            p_message,
            SYSDATE,
            p_user,
            SYSDATE,
            p_user,
            p_login,
            p_request_id,
            p_program_id,
            p_program_application_id,
            p_message_type );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := substrb(sqlerrm,1,2000);
        rollback;

END AUTONOMOUS_TXN;
/*EA#1641781*/


/***********************************************************************************/

 --
 -- This is an over-loaded function which calls the same function
 -- with p_routing_revision_date as parameter.
 --
 -- This is created to circumvent the dependency issues with forms and other objects
 --

 PROCEDURE OPERATION_IS_STANDARD_REPEATS (
        p_routing_sequence_id   IN NUMBER,
        p_standard_operation_id IN NUMBER,
        p_operation_code        IN VARCHAR2,
        p_organization_id       IN NUMBER, --BBK
        p_op_is_std_op          OUT NOCOPY NUMBER,
        p_op_repeated_times     OUT NOCOPY NUMBER,
        x_err_code              OUT NOCOPY NUMBER,
                x_err_msg               OUT NOCOPY VARCHAR2)
 IS
 BEGIN
          Operation_Is_Standard_Repeats(
            p_routing_sequence_id   => p_routing_sequence_id,
            p_routing_revision_date => SYSDATE,
            p_standard_operation_id => p_standard_operation_id,
            p_operation_code        => p_operation_code,
            p_organization_id       => p_organization_id,
            p_op_is_std_op          => p_op_is_std_op,
            p_op_repeated_times     => p_op_repeated_times,
            x_err_code              => x_err_code,
                        x_err_msg               => x_err_msg );

 END OPERATION_IS_STANDARD_REPEATS;

/* **********************************************************************************
-- BA: NSO-WLT

Function description:
    Given a routing (routing sequence id) and an operation (operation code or
    standard operation id), this procedure finds out if:
    1. This operation is a standard operation (p_op_is_std_op=1)
       Then, if it is a standard operation, is it unique in the primary path of the
            network routing (if so p_op_is_unique=1, otherwise 0)
       Then if not unique, how many times this repeats in the primary path of the
            network routing (p_op_repeated_times=1 if more than once, otherwise, 2).
    2. This operation is a non-standard op (p_op_is_std_op= 0),
       Then, if it is a non-standard op, is it unique in the primary path of the
            network routing (if so p_op_is_unique=1, otherwise 0)
       If not unique, how many times this repeats in the primary path of the
            network routing (p_op_repeated_times=1 if more than once, otherwise, 2).

 --
 -- Since this is an overloaded function, we shouldn't have
 -- DEFAULT clause on p_quantity. Else, you'll get the following error
 -- while calling this function.
 -- PLS-00307: too many declarations of 'GET_SCHEDULED_DATE'
 --            match this call
 --
********************************************************************************** */

PROCEDURE OPERATION_IS_STANDARD_REPEATS(
            p_routing_sequence_id   IN  NUMBER,
            p_routing_revision_date IN  DATE,   -- CZH.I_OED-1
            p_standard_operation_id IN  NUMBER,
            p_operation_code        IN  VARCHAR2,
            p_organization_id       IN  NUMBER, --BBK
            p_op_is_std_op          OUT NOCOPY NUMBER,
            p_op_repeated_times     OUT NOCOPY NUMBER,
            x_err_code              OUT NOCOPY NUMBER,
                        x_err_msg               OUT NOCOPY VARCHAR2)

IS

    l_stmt_num     NUMBER;
    l_std_op_id    NUMBER ; --BBK
    l_op_seq_num   NUMBER;
    l_rtg_rev_date DATE;

BEGIN

    l_rtg_rev_date      := NVL(p_routing_revision_date, SYSDATE);
    p_op_is_std_op      := 0;
    p_op_repeated_times := 0;
    x_err_code          := 0;
    x_err_msg           := NULL;

    l_stmt_num := 10;

    IF (p_routing_sequence_id is null) then
    x_err_code := 1;
    x_err_msg := 'WSMPUTIL.operation_is_standard_repeats: Invalid operation and/or routing ('
            ||l_stmt_num || ') ';
    p_op_is_std_op := 3;         -- CZH: why?
    p_op_repeated_times := 3;    -- CZH: why?
        return;
    END IF;


    l_stmt_num := 20;

    IF (p_operation_code is null and p_standard_operation_id is null) then
    -- Job is at an NSO operation.
        p_op_is_std_op := 0;
    p_op_repeated_times := 0;
    return;

    ELSIF p_standard_operation_id is not null then

    l_std_op_id := p_standard_operation_id;
    p_op_is_std_op := 1;

    ELSIF (p_operation_code is not null) then

    l_stmt_num := 30;

    Begin

        select nvl(standard_operation_id, -999)
        into   l_std_op_id
        from   bom_standard_operations
        where  organization_id = p_organization_id -- BBK
        and    operation_type  = 1                 -- Standard Operation Type BBK
        and    line_id is NULL                     -- Not for a WIP Line BBK
        and    operation_code = p_operation_code;

    Exception

        WHEN NO_DATA_FOUND THEN
        x_err_code := 2;
            x_err_msg := 'WSMPUTIL.operation_is_standard_repeats ('
                 ||l_stmt_num  || '): Standard_op_id not found for this opcode.. '
                 ||substrb(sqlerrm,1,1000);

        WHEN OTHERS THEN
        x_err_code := 3;
            x_err_msg := 'WSMPUTIL.operation_is_standard_repeats ('
                                 ||l_stmt_num ||'): '||substrb(sqlerrm,1,1000);

    End;

    IF (l_std_op_id = -999) then
        p_op_is_std_op := 0;
    ELSE
        p_op_is_std_op := 1;
    END IF;


    END IF;

    -- Let us get How many times that this is repeated
    -- Previous logic was wrong. Rewrote this. BBK

    l_stmt_num := 50;

    Declare

        l_rtg_end_opseqid NUMBER default 0;
        l_err_msg         varchar2(2000);
        l_err_code        NUMBER := 0;
        l_counter         NUMBER := 0;

    Begin

       /*Bug 3659838 Cursor c is replaced by a select with count*/
      /***************************
        DECLARE
            cursor c is
            -- BC: CZH.I_OED-2, consider replacement
            select distinct bon.from_op_seq_id,
                   bos.standard_operation_id
            from   bom_operation_networks  bon,
                   bom_operation_sequences bos
            Where  bos.routing_sequence_id   = p_routing_sequence_id
            and    bos.operation_sequence_id = bon.from_op_seq_id
            and    bos.standard_operation_id = l_std_op_id      --p_standard_operation_id --Fix for 2265237
            and    nvl(bos.disable_date, l_rtg_rev_date+1) >= l_rtg_rev_date  -- CZH.I_OED-1
            and    bos.effectivity_date                    <= l_rtg_rev_date  -- CZH.I_OED-1
            UNION
            select distinct bon.to_op_seq_id,
                   bos.standard_operation_id
            from   bom_operation_networks  bon,
                   bom_operation_sequences bos
            Where  bos.routing_sequence_id   = p_routing_sequence_id
            and    bos.operation_sequence_id = bon.to_op_seq_id
            and    bos.standard_operation_id = l_std_op_id      --p_standard_operation_id --Fix for 2265237
            and    nvl(bos.disable_date, l_rtg_rev_date+1) >= l_rtg_rev_date  --CZH.I_OED-1
            and    bos.effectivity_date                    <= l_rtg_rev_date; --CZH.I_OED-1
            select distinct
                   bos.operation_sequence_id,
                   bos.standard_operation_id
            from   bom_operation_networks  bon,
                   bom_operation_sequences bos
            Where  bos.routing_sequence_id   = p_routing_sequence_id
            and    bos.standard_operation_id = l_std_op_id
            and    (bos.operation_sequence_id = WSMPUTIL.replacement_op_seq_id(
                                                            bon.from_op_seq_id,
                                                            l_rtg_rev_date)
                    or
                    bos.operation_sequence_id = WSMPUTIL.replacement_op_seq_id(
                                                            bon.to_op_seq_id,
                                                            l_rtg_rev_date)
                   );
            -- EC: CZH.I_OED-2

            c_opseq_id NUMBER;
            c_stdop_id NUMBER;
            *****************/
         /*End of changes for Bug 3659838*/

        BEGIN
            /*Bug 3659838
            OPEN c;
            LOOP

                FETCH c INTO c_opseq_id, c_stdop_id;
                EXIT WHEN c%NOTFOUND;
                l_counter := l_counter+1;

            END LOOP;
            CLOSE c;
            Bug 3659838*/
            /*Bug 3659838 Following SQL is added for this bug*/
            select count(*)
            into  l_counter
            from  bom_operation_sequences bos,
                   bom_operation_sequences bos2
            Where  bos.routing_sequence_id  = p_routing_sequence_id
            and    bos.operation_sequence_id IN
                   (select from_op_seq_id opseqid
                   from  bom_operation_networks  bon_A,
                           bom_operation_sequences bos_A
                   where  bos_A.routing_sequence_id  = p_routing_sequence_id
                   and    bon_A.from_op_seq_id = bos_A.operation_sequence_id
                   UNION ALL
                   select to_op_seq_id opseqid
                   from  bom_operation_networks  bon_B,
                           bom_operation_sequences bos_B
                   where  bos_B.routing_sequence_id  = p_routing_sequence_id
                   and    bon_B.from_op_seq_id = bos_B.operation_sequence_id)
            and    bos2.routing_sequence_id  = p_routing_sequence_id
            and    bos.operation_seq_num = bos2.operation_seq_num
            and    bos2.standard_operation_id = l_std_op_id
            and    nvl(bos2.disable_date, l_rtg_rev_date+1) >= l_rtg_rev_date
            and    bos2.effectivity_date <= l_rtg_rev_date;

        END;

    p_op_repeated_times := l_counter;

    End;
EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := substr('WSMPUTIL.OPERATION_IS_STANDARD_REPEATS' ||sqlerrm,1,2000);
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
        return;

END OPERATION_IS_STANDARD_REPEATS;
-- BA: NSO-WLT

-- added by abedajna for patchset H non standard jobs project

procedure validate_non_std_references(p_assembly_item_id        IN NUMBER,
                                      p_routing_reference_id    IN NUMBER,
                                      p_bom_reference_id        IN NUMBER,
                                      p_alt_routing_designator  IN VARCHAR2,
                                      p_alt_bom_designator      IN VARCHAR2,
                                      p_organization_id         IN NUMBER,
                                      p_start_date              IN DATE,
                                      p_end_date                IN DATE,
                                      p_start_quantity          IN NUMBER,
                                      p_mrp_net_quantity        IN OUT NOCOPY  NUMBER,
                                      p_class_code              IN VARCHAR2,
                                      p_completion_subinventory IN VARCHAR2,
                                      p_completion_locator_id   IN NUMBER,
                                      p_firm_planned_flag       IN OUT NOCOPY NUMBER,
                      p_bom_revision        IN OUT NOCOPY VARCHAR2,
                      p_bom_revision_date   IN OUT NOCOPY DATE,
                      p_routing_revision    IN OUT NOCOPY VARCHAR2,
                      p_routing_revision_date   IN OUT NOCOPY DATE,
                                      x_routing_seq_id          OUT NOCOPY NUMBER,
                                      x_bom_seq_id              OUT NOCOPY NUMBER,
                      validation_level          NUMBER,
                                      x_error_code              OUT NOCOPY NUMBER,
                                      x_err_msg                 OUT NOCOPY VARCHAR2) IS

-- validation_level = 0 => validations performed during job creation
-- validation_level = 1 => validations performed for bom_reference
-- validation_level = 2 => validations performed for routing_reference

-- *** Error Code and Message Guide ***
-- 1: Routing Reference Cannot be Null
-- 2: Invalid Assembly Item Id
-- 3: Invalid Routing Reference Id
-- 4: Invalid Bom Reference Id
-- 5: Invalid Alternate Routing Designator
-- 0: Invalid Alternate Bom Designator -- WARNING
-- 7: Start Date cannot be greater than End Date
-- 8: Both Start and End Dates must be Entered
-- 9: Invalid Start Quantity
-- 10: Invalid Net Quantity
-- 11: Invalid Class Code
-- 12: Invalid Completion Locator Id
-- 13: Invalid Completion Subinventory
-- 14: Invalid Firm Planned Flag


l_no_of_records NUMBER := 0;
l_dummy     NUMBER := 0;
l_stmt_num  NUMBER;
def_completion_subinventory VARCHAR2(10) := '';
def_completion_locator_id   NUMBER := '';
l_mtl_locator_type  NUMBER;
l_sub_loc_control   NUMBER;
l_org_loc_control   NUMBER;
l_restrict_locators_code    NUMBER;
l_item_loc_control  NUMBER;
l_segs                  VARCHAR2(10000);
l_loc_success           BOOLEAN;
l_locator_id        NUMBER;
l_rev_date      DATE;

-- ST : Serial Support Project -----------------------------
l_serial_control_code   NUMBER;
-- ST : Serial Support Project -----------------------------

begin

x_error_code := 0;
x_err_msg := '';

l_stmt_num := 10;

-- routing reference cannot be null
if validation_level = 0 then

    if p_routing_reference_id is null then
          fnd_message.set_name('WSM','WSM_NS_RTNG_REF_NULL');
          x_err_msg := fnd_message.get;
          x_error_code := 1;
          return;
    end if;

end if;


-- assembly cannot be null
if validation_level = 0 then

        if p_assembly_item_id is null then
              fnd_message.set_name('WSM','WSM_NS_ASS_NULL');
              x_err_msg := fnd_message.get;
              x_error_code := 1;
              return;
        end if;

end if;

-- check that the item exists and it is lot controlled
if validation_level = 0 then

l_stmt_num := 20;

    BEGIN
        select  1
        into    l_no_of_records
        from    mtl_system_items_kfv msi
        where   msi.inventory_item_id = p_assembly_item_id
        and     msi.organization_id = p_organization_id
        and     msi.lot_control_code = 2;
    EXCEPTION
        when too_many_rows then l_no_of_records := 1;
        when no_data_found then
        x_error_code := 2;
        fnd_message.set_name('WSM','WSM_ASSEMBLY_NO_LOT');
        x_err_msg := fnd_message.get;
        return;
    END;

l_stmt_num := 30;
    if l_no_of_records <> 0 then
        BEGIN
            l_no_of_records := 0;
            select  1,
                -- ST : Serial Support Project -----------------------------
                serial_number_control_code
        into    l_no_of_records,
                -- ST : Serial Support Project -----------------------------
                l_serial_control_code
            from    mtl_system_items_kfv msi
            where   msi.inventory_item_id = p_assembly_item_id
            and     msi.organization_id = p_organization_id
        -- ST : Serial Support Project --------------
            and     msi.serial_number_control_code IN (1,2);
        -- ST : Serial Support Project --------------
        EXCEPTION
            when too_many_rows then l_no_of_records := 1;
            when no_data_found then
                x_error_code := 2;
                fnd_message.set_name('WSM','WSM_ASSEMBLY_NOT_SERIAL');
                x_err_msg := fnd_message.get;
        return;
        END;
    end if;

end if;

-- check for the existance of the item used for routing reference
if validation_level in (0,2) then

l_stmt_num := 40;
    BEGIN
        select  1
        into    l_dummy
        from    mtl_system_items_kfv msi
        where   msi.inventory_item_id = p_routing_reference_id
        and     msi.organization_id = p_organization_id;
    EXCEPTION
        when too_many_rows then null;
        when no_data_found then
              fnd_message.set_name('WSM','WSM_INVALID_FIELD');
              fnd_message.set_token('FLD_NAME', 'ROUTING_REFERENCE_ID');
              x_err_msg := fnd_message.get;
              x_error_code := 3;
              return;
    END;
end if;

-- check for the existance of the item used for bom reference
if validation_level in (0,1) then

l_stmt_num := 50;
if p_bom_reference_id is not null then
    BEGIN
        select  1
        into    l_dummy
        from    mtl_system_items_kfv msi
        where   msi.inventory_item_id = p_bom_reference_id
        and     msi.organization_id = p_organization_id;
    EXCEPTION
        when too_many_rows then null;
        when no_data_found then
              fnd_message.set_name('WSM','WSM_INVALID_FIELD');
              fnd_message.set_token('FLD_NAME', 'BOM_REFERENCE_ID');
              x_err_msg := fnd_message.get;
              x_error_code := 4;
          return;
    END;
end if;


if p_bom_reference_id is null and p_alt_bom_designator is not null then
    x_err_msg := 'Warning! Alternate Bom Designator has a not null value that has been ignored.';
end if;

end if;

-- check for the existance of routing
if validation_level in (0,2) then

BEGIN
l_stmt_num := 60;
select bor.routing_sequence_id,
       bor.completion_subinventory,
       bor.completion_locator_id
into   x_routing_seq_id,
       def_completion_subinventory,
       def_completion_locator_id
from   bom_routing_alternates_v bor
where  bor.organization_id = p_organization_id
and    bor.assembly_item_id = p_routing_reference_id
and    NVL(bor.alternate_routing_designator, '&*') = NVL(p_alt_routing_designator, '&*')
and    bor.routing_type = 1
and    bor.cfm_routing_flag = 3;
EXCEPTION
        when no_data_found then
              fnd_message.set_name('WSM','WSM_INVALID_FIELD');
              fnd_message.set_token('FLD_NAME', 'ROUTING_REFERENCE_ID/ALTERNATE_ROUTING_DESIGNATOR');
              x_err_msg := fnd_message.get;
              x_error_code := 5;
              return;
END;

end if;


-- check for existance of bom
if validation_level in (0,1) then

l_stmt_num := 70;
if p_bom_reference_id is not null then
    BEGIN
            SELECT  bom.common_bill_sequence_id
            INTO  x_bom_seq_id
            FROM  bom_bill_of_materials bom
            WHERE  NVL(bom.alternate_bom_designator, '&*') = NVL(p_alt_bom_designator, '&*')
            AND  BOM.assembly_item_id = p_bom_reference_id
            AND  bom.organization_id = p_organization_id;
    EXCEPTION
            when no_data_found then
            fnd_message.set_name('WIP','WIP_BILL_DOES_NOT_EXIST');
                x_err_msg := fnd_message.get;
--SpUA bugfix 3154345  Not really a SpUA bugfix!!
--Now we will enable wrong alt_bom_desig to error out
                x_error_code := 6;
--End SpUA bugfix
    END;
end if;

end if; -- validation level

/***************
-- date validations

l_stmt_num := 80;
if p_start_date is null or p_end_date is null then
         fnd_message.set_name('WSM','WSM_NS_NULL_DATE');
         x_err_msg := fnd_message.get;
         x_error_code := 8;
         return;
end if;

if p_start_date > p_end_date then
         fnd_message.set_name('WSM','WSM_FUSD_GT_LUCD');
         x_err_msg := fnd_message.get;
         x_error_code := 7;
         return;
end if;

***************/


-- start quantity validations
if validation_level = 0 then

l_stmt_num := 90;
    if p_start_quantity is null or (p_start_quantity is not null and p_start_quantity <= 0) then
         fnd_message.set_name('WSM','WSM_INVALID_FIELD');
     fnd_message.set_token('FLD_NAME', 'START_QUANTITY');
         x_err_msg := fnd_message.get;
         x_error_code := 9;
         return;
    end if;

    -- ST : Serial Support Project -----------------------------
    IF l_serial_control_code = 2 THEN
        IF floor(p_start_quantity) <> p_start_quantity THEN
        -- ST : Serial Support Project -----------------------------
        fnd_message.set_name('WSM','WSM_INVALID_JOB_TXN_QTY');
        x_err_msg := fnd_message.get;
        x_error_code := 9;
        return;
    END IF;
   END IF;
   -- ST : Serial Support Project -----------------------------
end if;

-- net quantity validations
if validation_level = 0 then

l_stmt_num := 100;
    if p_mrp_net_quantity is null then
    p_mrp_net_quantity := 0;
    else
        if p_mrp_net_quantity < 0 or p_mrp_net_quantity > p_start_quantity then
         fnd_message.set_name('WSM','WSM_INVALID_FIELD');
         fnd_message.set_token('FLD_NAME', 'MRP_NET_QUANTITY');
         x_err_msg := fnd_message.get;
         x_error_code := 9;
         return;
        end if;

        -- ST : Serial Support Project -----------------------------
        IF l_serial_control_code = 2 THEN
        IF floor(p_mrp_net_quantity) <> p_mrp_net_quantity THEN
            -- ST : Serial Support Project -----------------------------
            fnd_message.set_name('WSM','WSM_INVALID_JOB_TXN_QTY');
            x_err_msg := fnd_message.get;
            x_error_code := 9;
            return;
        END IF;
       END IF;
       -- ST : Serial Support Project -----------------------------
    end if;

end if;

-- class code validation
if validation_level = 0 then

l_stmt_num := 110;
       BEGIN
        select  1
        into    l_dummy
        from    wip_accounting_classes
        where   class_code = nvl(p_class_code, '***')
        and     organization_id = p_organization_id
    and     nvl(disable_date, sysdate + 1) > sysdate
    and class_type = 7;
        EXCEPTION
        when too_many_rows then null;
        when no_data_found then
              fnd_message.set_name('WSM','WSM_INVALID_FIELD');
              fnd_message.set_token('FLD_NAME', 'CLASS_CODE');
              x_err_msg := fnd_message.get;
              x_error_code := 11;
              return;
        END;

end if;


 -- completion subinv and locator validation
if validation_level = 0 then

l_stmt_num := 120;

    if p_completion_subinventory is not null then
        /* ST bug fix 3722383 if WSM: Complete Job Sector lot extension level  is set at Item level,
    then sector extension for the subinventory is not mandatory */
        if ( nvl(FND_PROFILE.value('WSM_COMPLETE_SEC_LOT_EXTN_LEVEL'), '1') = 2 ) then


        BEGIN
        select  1
        into    l_dummy
        from    wsm_subinventory_extensions
        where   secondary_inventory_name = p_completion_subinventory
        and     organization_id = p_organization_id;
        EXCEPTION
        when too_many_rows then null;
        when no_data_found then
              fnd_message.set_name('WSM','WSM_INVALID_FIELD');
              fnd_message.set_token('FLD_NAME', 'COMPLETION_SUBINVENTORY');
              x_err_msg := fnd_message.get;
              x_error_code := 13;
              return;
        END;
    end if;
    /* ST bug fix 3722383 end */

        select locator_type
        into l_mtl_locator_type
        from mtl_secondary_inventories
        where secondary_inventory_name = p_completion_subinventory
        and organization_id = p_organization_id;

/* ST bugfix3336844(2793501) call wip_locator.validate is enough for validate lcator: null or not. remove checks of
--locator validation null. comment out checks of l_mtl_locator_type, it does not works if org level is locator
--control but sub is not. */
/***
        select locator_type
        into l_mtl_locator_type
        from mtl_secondary_inventories
        where secondary_inventory_name = p_completion_subinventory
        and organization_id = p_organization_id;

    if p_completion_locator_id is not null then
***/
        SELECT  nvl(msub.locator_type, 1) sub_loc_control,
        MP.stock_locator_control_code org_loc_control,
        MS.restrict_locators_code,
        MS.location_control_code item_loc_control
        into l_sub_loc_control, l_org_loc_control,
         l_restrict_locators_code, l_item_loc_control
    FROM    mtl_system_items MS,
        mtl_secondary_inventories MSUB,
        mtl_parameters MP
    WHERE   MP.organization_id = p_organization_id
    AND     MS.organization_id = p_organization_id
    AND     MS.inventory_item_id = p_assembly_item_id
    AND     MSUB.secondary_inventory_name = p_completion_subinventory
    AND     MSUB.organization_id = p_organization_id;


        l_locator_id := p_completion_locator_id;

    /* STbugfix 3336844 added exception handler, since the WIP API does not have */
        begin
       WIP_LOCATOR.validate(   p_organization_id,
                                    p_assembly_item_id,
                                    p_completion_subinventory,
                                    l_org_loc_control,
                                    l_sub_loc_control,
                                    l_item_loc_control,
                                    l_restrict_locators_code,
                                    NULL, NULL, NULL, NULL,
                                    l_locator_id,
                                    l_segs,
                                    l_loc_success);
    exception
       when NO_DATA_FOUND then
           l_stmt_num := 123;
           l_loc_success := FALSE;
        end;

        IF not l_loc_success THEN
                      fnd_message.set_name('WSM','WSM_INVALID_FIELD');
                      fnd_message.set_token('FLD_NAME', 'COMPLETION_LOCATOR_ID');
                      x_err_msg := fnd_message.get;
                      x_error_code := 12;
                      return;
        end if;
/*** ST bugfix 3336844
    elsif p_completion_locator_id is null then
        if l_mtl_locator_type = 2 then
                  fnd_message.set_name('WSM','WSM_INVALID_FIELD');
                  fnd_message.set_token('FLD_NAME', 'COMPLETION_LOCATOR_ID');
                  x_err_msg := fnd_message.get;
                  x_error_code := 12;
                  return;
        end if;
    end if;
end fix 3336844 ***/
    elsif p_completion_subinventory is null and p_completion_locator_id is null then
    null;
    elsif p_completion_subinventory is null and p_completion_locator_id is not null then
        fnd_message.set_name('WSM','WSM_INVALID_FIELD');
        fnd_message.set_token('FLD_NAME', 'COMPLETION_LOCATOR_ID');
        x_err_msg := fnd_message.get;
        x_error_code := 12;
        return;
    end if;

end if;


-- validate firm planned flag
if validation_level = 0 then

l_stmt_num:= 130;

    if p_firm_planned_flag is not null and p_firm_planned_flag <> 2 then
        fnd_message.set_name('WSM','WSM_INVALID_FIELD');
        fnd_message.set_token('FLD_NAME', 'FIRM_PLANNED_FLAG');
        x_err_msg := fnd_message.get;
        x_error_code := 14;
        return;
    end if;
    if p_firm_planned_flag is null then
    p_firm_planned_flag := 2;
    end if;

end if;

-- get revisions

l_stmt_num:= 140;
if validation_level in (0,1,2) then

    if p_start_date > SYSDATE then
        l_rev_date := p_start_date;
    else
        l_rev_date := SYSDATE;
    end if;

    if validation_level in (0,1) then
        wip_revisions.bom_revision (p_organization_id,
                                    p_bom_reference_id,
                                    p_bom_revision,
                                    p_bom_revision_date,
                                    l_rev_date);
    end if;

    if validation_level in (0,2) then
        wip_revisions.routing_revision (p_organization_id,
                                        p_routing_reference_id,
                                        p_routing_revision,
                                        p_routing_revision_date,
                                        l_rev_date);
    end if;

end if;


exception
    when others then
            x_error_code := SQLCODE;
            x_err_msg := 'WSMPUTIL.validate_non_std_references (stmt_num='||l_stmt_num||'): '||SUBSTR(SQLERRM,1,1000);
        return;

end validate_non_std_references;



-- abb H, added by abedajna for optional scrap accounting project
-- this function checks whether the org for the wip_entity_id that is passed has scrap accounting
-- enabled or not.
-- returns 1 if scrap accounting should be reckoned enabled for the job,
-- 2 if it should be reckoned disabled for the job, zero => error


FUNCTION WSM_ESA_ENABLED(p_wip_entity_id IN NUMBER DEFAULT NULL,
                         err_code OUT NOCOPY NUMBER,
                         err_msg  OUT NOCOPY VARCHAR2,
                         p_org_id IN NUMBER DEFAULT NULL,
                         p_job_type IN NUMBER DEFAULT NULL) RETURN INTEGER IS

l_organization_id       NUMBER;
l_job_type      NUMBER;
l_stmt_no       NUMBER;
l_est_scrap_accounting  NUMBER;

begin

err_code := 0;
err_msg := '';

if p_job_type = 3 then
        return 2;  --disabled
end if;

l_stmt_no := 5;
if p_org_id is not null then
        select nvl(ESTIMATED_SCRAP_ACCOUNTING, 1)
        into l_est_scrap_accounting
        from wsm_parameters
        where organization_id = p_org_id;

        return l_est_scrap_accounting;
end if;

if p_wip_entity_id is not null then

    l_stmt_no := 10;
    select wdj.organization_id, wdj.job_type
    into l_organization_id, l_job_type
    from wip_discrete_jobs wdj, wip_entities we
    where wdj.wip_entity_id = p_wip_entity_id
    and wdj.wip_entity_id = we.wip_entity_id
    and we.entity_type = 5;

    if l_job_type = 3 then
            return 2;  --disabled
    else
    l_stmt_no:= 20;
            select nvl(ESTIMATED_SCRAP_ACCOUNTING, 1)
            into l_est_scrap_accounting
            from wsm_parameters
            where organization_id = l_organization_id;

            return l_est_scrap_accounting;
    end if;

end if;

exception
when others then
        err_code := SQLCODE;
        err_msg := 'WSMPUTIL.WSM_ESA_ENABLED (stmt_num='||l_stmt_no||'): '||SUBSTR(SQLERRM,1,1000);
        return 0;
end;


-- abb H, added by abedajna for optional scrap accounting project
-- This API checks if all jobs in an org have one of the following status types or not:
-- Unreleased, Closed On-Hold with date_released null and Cancelled. If all jobs in the
-- org are in one of the statuses mentioned the API returns 0, else it returns 1. When the
-- user creates a new org and wishes to setup wsm parameters in the org, this procedure is
-- called by the Parameters form. In this case no row exists in wsm_parameters for the
-- job as yet. In that case the proc has been designed to return 2.

FUNCTION WSM_CHANGE_ESA_FLAG(p_org_id IN NUMBER,
                             err_code OUT NOCOPY NUMBER,
                             err_msg  OUT NOCOPY VARCHAR2) RETURN INTEGER IS

ret_val1 NUMBER := 0;
l_dummy  NUMBER;

begin

err_code := 0;
err_msg := '';

    BEGIN
-- added by abb to take care of the case when the form is opened the first time
-- in an org, Then there's no row in the wsm_parameters and change of flag
-- should be allowed.
    begin
        select 1
        into l_dummy
        from wsm_parameters
        where organization_id = p_org_id;
    exception
        when no_data_found then return 2;
    end;

        begin
            select  1
            into    ret_val1
            from    wip_discrete_jobs wdj, wip_entities we
            where   wdj.organization_id = p_org_id
            and     wdj.wip_entity_id = we.wip_entity_id
            and     we.entity_type = 5
            and     wdj.status_type = 6
            and     wdj.date_released is not null;
        exception
                when too_many_rows then ret_val1 := 1;
                when no_data_found then ret_val1 := 0;
        end;

    if ret_val1 = 1 then
        return ret_val1;
    else
            begin
            -- Bug#2872306 - TOPSQL Fix -- BBK
            -- Pushed it under dual exists condition check.
            -- The purpose of this sql is to find if there are OPEN Lotbased Jobs.
                    select  1
                    into    ret_val1
                from dual
                where exists (select 1
                        from    wip_discrete_jobs wdj, wip_entities we
                        where   wdj.organization_id = p_org_id
                        and     wdj.wip_entity_id = we.wip_entity_id
                        and     we.entity_type = 5
                        and     wdj.status_type not in (1,7,12,6)
                );
            exception
                    when too_many_rows then ret_val1 := 1;
                    when no_data_found then ret_val1 := 0;
            end;
                return ret_val1;
    end if;

    END;

    EXCEPTION
    when others then
        err_code := SQLCODE;
        err_msg := 'WSMPUTIL.WSM_CHANGE_ESA_FLAG: '||SUBSTR(SQLERRM,1,1000);
        return 0;
end;


/***************************************************************************************/

-- CZH.I_OED-1
--      return 0 if no disabled op is found in the routing
--      return 1 if disabled op's are found in the routing
--      return -1 if any unexpected error is encountered.

FUNCTION network_with_disabled_op (
                p_routing_sequence_id IN  NUMBER,
                p_routing_rev_date    IN  DATE,
                x_err_code            OUT NOCOPY NUMBER,
                x_err_msg             OUT NOCOPY VARCHAR2
                ) RETURN INTEGER IS
x_return       NUMBER;
l_rtg_rev_date DATE;
BEGIN
    x_return       := 0;
    x_err_code     := 0;
    x_err_msg      := NULL;
    l_rtg_rev_date := NVL(p_routing_rev_date, SYSDATE);

    --
    -- bugfix 2721157: Performance Problem - Replaced WHERE EXISTS with WHERE IN clause
    -- since the sub-query has a better selectivity.
    -- Also, broke the query into 2 parts.
    --

    begin
      select 1
      into   x_return
      from   bom_operation_networks bon
      where  bon.from_op_seq_id in (select bos.operation_sequence_id
                  from   bom_operation_sequences bos
                  where  bos.routing_sequence_id = p_routing_sequence_id
                          --BC: CZH.I_OED-2, should consider replacement op
                  -- and    NOT(bos.effectivity_date <= l_rtg_rev_date
                  --       and nvl(bos.disable_date, l_rtg_rev_date+1) > l_rtg_rev_date)
                          and    nvl(WSMPUTIL.replacement_op_seq_id( bos.operation_sequence_id,
                                                         l_rtg_rev_date), -1) = -1 )
                          --EC: CZH.I_OED-2
      and    rownum = 1;  -- Added ROWNUM to limit the number of rows accessed
    exception

      when NO_DATA_FOUND then

          select 1
          into   x_return
          from   bom_operation_networks bon
          where  bon.to_op_seq_id in (  select bos.operation_sequence_id
                  from   bom_operation_sequences bos
                  where  bos.routing_sequence_id = p_routing_sequence_id
                          --BC: CZH.I_OED-2, should consider replacement op
                  -- and    NOT(bos.effectivity_date <= l_rtg_rev_date
                  --       and nvl(bos.disable_date, l_rtg_rev_date+1) > l_rtg_rev_date)
                          and    nvl(WSMPUTIL.replacement_op_seq_id( bos.operation_sequence_id,
                                                         l_rtg_rev_date), -1) = -1 )
                          --EC: CZH.I_OED-2
          and    rownum = 1;  -- Added ROWNUM to limit the number of rows accessed

    end;

    RETURN x_return;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return := 0;
        RETURN x_return;

    WHEN TOO_MANY_ROWS THEN
        x_return := 1;
        RETURN x_return;

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPUTIL.NETWORK_WITH_DISABLED_OP: '||SUBSTR(SQLERRM,1,1000);
        RETURN -1;      -- bugfix2721157: return -1 instead of 0 to distinguish between expected and unexpected errors.
END network_with_disabled_op;

/***************************************************************************************/

-- CZH.I_OED-1
--      return 0 if network dose not have effective primary path up to p_op_seq_num
--      return 1 if network has effective primary path up to p_op_seq_num

FUNCTION primary_path_is_effective_till (
                p_routing_sequence_id IN    NUMBER,
                p_routing_rev_date    IN        DATE,
                p_start_op_seq_id     IN OUT NOCOPY    NUMBER,
                p_op_seq_num          IN    NUMBER,
                x_err_code            OUT NOCOPY    NUMBER,
                x_err_msg             OUT NOCOPY    VARCHAR2
                ) RETURN INTEGER IS
l_op_seq_id     NUMBER;
l_op_seq_num    NUMBER;
e_bad_path      EXCEPTION;
l_rtg_rev_date  DATE;

CURSOR  primary_cur IS (
    SELECT      to_op_seq_id
    FROM        bom_operation_networks
    WHERE       transition_type = 1
    START WITH  from_op_seq_id = l_op_seq_id
    AND         transition_type = 1
    CONNECT BY  from_op_seq_id = PRIOR to_op_seq_id
    AND         transition_type = 1
);

BEGIN
    x_err_code     := 0;
    x_err_msg      := NULL;
    l_rtg_rev_date := NVL(p_routing_rev_date, SYSDATE);

    -- Call find_routing_start if p_start_op_seq_id is not specified.
    -- If p_start_op_seq_id is specified, it should be effective,
    -- however, even if it is not effective it will be caught later on
    IF(p_start_op_seq_id IS NULL) THEN
        WSMPUTIL.FIND_ROUTING_START(
                    p_routing_sequence_id,
                    SYSDATE, -- CZH: call with SYSDATE
                    p_start_op_seq_id,
                    x_err_code,
                    x_err_msg);
        IF (x_err_code <> 0 ) THEN
            raise e_bad_path;
        END IF;
    END IF;

    l_op_seq_id := p_start_op_seq_id;

    OPEN primary_cur;
    LOOP
        -- get bos.operation_seq_num and compare with p_op_seq_num
        begin
            SELECT operation_seq_num
            INTO   l_op_seq_num
            FROM   bom_operation_sequences
            WHERE  operation_sequence_id = l_op_seq_id
            AND    routing_sequence_id = p_routing_sequence_id;
            -- BD: CZH.I_OED-2, should consider replacement
            --AND  effectivity_date <= l_rtg_rev_date
            --AND  nvl(disable_date, l_rtg_rev_date+2) > l_rtg_rev_date;
            -- ED: CZH.I_OED-2

        exception
            WHEN others THEN
                raise e_bad_path;
        end;

        IF l_op_seq_num = p_op_seq_num THEN
            return 1;
        END IF;

        FETCH primary_cur INTO  l_op_seq_id;
        EXIT when primary_cur%NOTFOUND;

        --BA: CZH.I_OED-2, test if it has a effective replacement
        IF( NVL(WSMPUTIL.replacement_op_seq_id(
                             l_op_seq_id,
                             l_rtg_rev_date), -1) = -1) THEN
            raise e_bad_path;
        END IF;
        --EA: CZH.I_OED-2
    END LOOP;
    CLOSE primary_cur;

    x_err_code := 1;
    x_err_msg := 'operation ' || p_op_seq_num || ' is not on primary path';
    return 0;

EXCEPTION
        WHEN e_bad_path THEN
            return 0;
        WHEN others THEN
            x_err_code := SQLCODE;
            x_err_msg := substr(SQLERRM,1,200);
            return 0;
END;

/***************************************************************************************/
-- CZH.I_OED-1
--      return 0 if current operation does not have effective next operation
--      return 1 if current operation has effective next operation
--      return 2 if current operation is the last operation
--      return 3 if current operation is at outside routing
FUNCTION effective_next_op_exists (
                p_organization_id     IN     NUMBER,
                p_wip_entity_id       IN     NUMBER,
                p_wo_op_seq_num       IN     NUMBER,
                p_end_op_seq_id       IN     NUMBER,   -- CZH.I_9999
                x_err_code            OUT NOCOPY    NUMBER,
                x_err_msg             OUT NOCOPY    VARCHAR2
                ) RETURN INTEGER IS
l_count             NUMBER;
l_return            NUMBER:= 0;
l_wo_op_seq_id      NUMBER;
--l_last_op_seq_num NUMBER;          -- DEL: CZH.I_9999
l_rtg_seq_id        NUMBER := NULL;  -- ADD: CZH.I_9999
l_rtg_rev_date      DATE := NULL;    -- ADD: CZH.I_9999
l_end_op_seq_id     NUMBER;          -- ADD: CZH.I_9999

BEGIN
        x_err_code := 0;
        x_err_msg  := NULL;

        -- BD: CZH.I_9999, 9999 is no longer the last operation
        /****************
        -- At the last operation
        SELECT  nvl(LAST_OPERATION_SEQ_NUM,9999)
        INTO    l_last_op_seq_num
        FROM    WSM_PARAMETERS
        WHERE   ORGANIZATION_ID = p_organization_id;
        if(p_wo_op_seq_num = l_last_op_seq_num) then
            return 2;  -- at last operation
        end if;
        ****************/
        -- ED: CZH.I_9999

        SELECT  OPERATION_SEQUENCE_ID
        INTO    l_wo_op_seq_id
        FROM    WIP_OPERATIONS
        WHERE   ORGANIZATION_ID = p_organization_id
        AND     wip_entity_id = p_wip_entity_id
        AND     OPERATION_SEQ_NUM = p_wo_op_seq_num;

        IF(NVL(l_wo_op_seq_id, -1) = -1) THEN
            return 3; -- at outside rtg

        -- BA: CZH.I_9999, check if at the last operation
        ELSE
            IF ( p_end_op_seq_id IS NOT NULL ) THEN -- do not call find_routing_end again

                l_end_op_seq_id := p_end_op_seq_id;

            ELSE  -- call find_routing_end if p_end_op_seq_id is NULL

                select common_routing_sequence_id,
                       routing_revision_date
                into   l_rtg_seq_id,
                       l_rtg_rev_date
                from   wip_discrete_jobs
                where  wip_entity_id = p_wip_entity_id;

                WSMPUTIL.find_routing_end (
                      p_routing_sequence_id => l_rtg_seq_id,
                      p_routing_rev_date    => l_rtg_rev_date,
                      end_op_seq_id         => l_end_op_seq_id,
                      x_err_code            => x_err_code,
                      x_err_msg             => x_err_msg);
                IF (x_err_code <> 0) THEN
                    return 0; -- no valid next operation, no end op in routing
                END IF;

                -- BA: CZH.I_OED-2, should use the replacement
                l_end_op_seq_id := WSMPUTIL.replacement_op_seq_id(
                                             l_end_op_seq_id,
                                             l_rtg_rev_date);
                -- EA: CZH.I_OED-2

            END IF;

            IF (l_wo_op_seq_id = l_end_op_seq_id) THEN
                return 2;  -- at last operation
            end if;

        -- EA: CZH.I_9999
        END IF;

        IF( l_rtg_seq_id IS NULL) THEN  -- do not call this again if called before
            select common_routing_sequence_id,
                   routing_revision_date
            into   l_rtg_seq_id,
                   l_rtg_rev_date
            from   wip_discrete_jobs
            where  wip_entity_id = p_wip_entity_id;
        END IF;

        SELECT 1
        INTO   l_count
        FROM   sys.dual
        WHERE  exists(
                   select 1
                   from   bom_operation_networks   bon
                   --where  NVL(WSMPUTIL.replacement_op_seq_id(
                   --                  bon.from_op_seq_id,
                   --                  l_rtg_rev_date), -1) = l_wo_op_seq_id
                   where bon.from_op_seq_id IN (
               select bos.operation_sequence_id
               from   bom_operation_sequences bos,
                              bom_operation_sequences bos2
                   where  bos.operation_seq_num      = bos2.operation_seq_num
                       AND    bos.routing_sequence_id    = bos2.routing_sequence_id
                       AND    bos2.operation_sequence_id = l_wo_op_seq_id
                   )
                   and    NVL(WSMPUTIL.replacement_op_seq_id(
                                       bon.to_op_seq_id,
                                       l_rtg_rev_date), -1) <> -1
               );

        IF (l_count = 1) THEN
            return 1; -- having valid next operation(s)
        ELSE
            return 0; -- no valid next operation
        END IF;

EXCEPTION
        WHEN others THEN
            x_err_code := SQLCODE;
            x_err_msg := substr(SQLERRM,1,200);
            return 0;
END effective_next_op_exists;


/***************************************************************************************/
--this is to make the UTIL compatible with 1158 + OED-1
--this function is called from Move Txn form/interface on OSFM 1158+OED-1 codeline
FUNCTION effective_next_op_exits (
                p_organization_id     IN     NUMBER,
                p_wip_entity_id       IN     NUMBER,
                p_wo_op_seq_num       IN     NUMBER,
                x_err_code            OUT NOCOPY   NUMBER,
                x_err_msg             OUT NOCOPY   VARCHAR2
                ) RETURN INTEGER IS
l_count           NUMBER;
l_return          NUMBER := 0;
l_last_op_seq_num NUMBER;
l_op_seq_id       NUMBER;
l_rtg_rev_date    DATE :=NULL;
BEGIN
        x_err_code := 0;
        x_err_msg  := NULL;

        -- At the last operation
        SELECT  nvl(LAST_OPERATION_SEQ_NUM,9999)
        INTO    l_last_op_seq_num
        FROM    WSM_PARAMETERS
        WHERE   ORGANIZATION_ID = p_organization_id;
        if(p_wo_op_seq_num = l_last_op_seq_num) then
            return 2;  -- at last operation
        end if;

        -- At outside routing operation
        SELECT  OPERATION_SEQUENCE_ID
        INTO    l_op_seq_id
        FROM    WIP_OPERATIONS
        WHERE   ORGANIZATION_ID = p_organization_id
        AND     wip_entity_id = p_wip_entity_id
        AND     OPERATION_SEQ_NUM = p_wo_op_seq_num;
        IF(NVL(l_op_seq_id, -1) = -1) THEN
            return 3; -- at outside rtg
        END IF;

    -- to be compatible with base release, query from bom tables directly.

/**        -- Check WSM_NEXT_OPERATION_V
        select  count(*)
        into    l_count
        from    wsm_next_operations_v
        where   wip_entity_id = p_wip_entity_id
        and     to_wo_operation_seq_num >= p_wo_op_seq_num
        and     fm_operation_seq_num    =  p_wo_op_seq_num;
**/
    --begin fix
    select  nvl(routing_revision_date, sysdate)
      into  l_rtg_rev_date
      from  wip_discrete_jobs
      where wip_entity_id = p_wip_entity_id;

    select count(*)
    into   l_count
    from   bom_operation_networks bon
    where  bon.from_op_seq_id = l_op_seq_id
    and    exists (select bos.operation_sequence_id
               from   bom_operation_sequences bos
               where  bos.operation_sequence_id = bon.to_op_seq_id
               and    bos.effectivity_date <= l_rtg_rev_date
               and    NVL(bos.disable_date, l_rtg_rev_date) >= l_rtg_rev_date
               );
        --end fix

    IF (l_count <> 0) THEN
            return 1; -- having valid next operation(s)
        ELSE
            return 0; -- no valid next operation
        END IF;

EXCEPTION
        WHEN others THEN
            x_err_code := SQLCODE;
            x_err_msg := substr(SQLERRM,1,200);
            return 0;
END;

/***************************************************************************************/
--this is to make the UTIL compatible with 1158 and 1157
FUNCTION wlt_if_costed (
        p_wip_entity_id in number )
 RETURN NUMBER IS

   l_dummy  number;

 BEGIN
   select 1
   into   l_dummy
   from   wsm_split_merge_transactions wsmt,
          wsm_sm_resulting_jobs wrj,
      wip_entities we
   where  wrj.wip_entity_id = p_wip_entity_id
   and    wrj.transaction_id = wsmt.transaction_id
   and    wsmt.transaction_type_id in (1,2,6)
   and    we.wip_entity_id = wrj.wip_entity_id
   and    we.entity_type = 5
   and    nvl(wsmt.costed,1) <> 4;

   return 2;


 EXCEPTION
   when NO_DATA_FOUND then
        return 1;

   when TOO_MANY_ROWS then
        return 2;

   when OTHERS then
        return 2;

END;

/***************************************************************************************/
 -- Moved this procedure from WSMPLTOP to here

PROCEDURE check_charges_exist ( p_wip_entity_id           IN         NUMBER,
                                p_organization_id         IN         NUMBER,
                                p_op_seq_num              IN         NUMBER,
                                p_op_seq_id               IN         NUMBER,
                                p_charges_exist           OUT NOCOPY NUMBER,
                                p_manually_added_comp     OUT NOCOPY NUMBER,
                                p_issued_material         OUT NOCOPY NUMBER,
                                p_manually_added_resource OUT NOCOPY NUMBER,
                                p_issued_resource         OUT NOCOPY NUMBER,
                                x_error_code              OUT NOCOPY NUMBER,
                                x_error_msg               OUT NOCOPY VARCHAR2)
IS

    l_stmt_num              NUMBER;
    l_dummy_number          NUMBER;
    e_proc_exception        EXCEPTION;

    l_rtg_op_seq_num        NUMBER default 0;
    l_qty_at_tomove         NUMBER default 0;
    --l_last_op_seq_num NUMBER := 9999;  Removed for 999 project

    --Start additions to fix bug #2404640--
    l_consider_op_seq1      NUMBER;
    l_rtg_seq_id            NUMBER;
    l_rtg_rev_dt            DATE;
    l_start_op_seq_id       NUMBER;
    l_job_start_op_seq_id   NUMBER;
    --End additions to fix bug #2404640--
    l_first_op_seq_num NUMBER := 10;       --bugfix 3546334


BEGIN
        l_stmt_num := 10;

        IF (l_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'WSMPUTIL.check_charges_exist parameters are :'||
                                'p_wip_entity_id='||p_wip_entity_id||
                                ', p_organization_id='||p_organization_id||
                                ', p_op_seq_num='||p_op_seq_num||
                                ', p_op_seq_id='||p_op_seq_id);
        END IF;

        p_charges_exist             := 0;
        p_manually_added_comp       := 0;
        p_issued_material           := 0;
        p_manually_added_resource   := 0;
        p_issued_resource           := 0;

        x_error_code := 0;
        x_error_msg := NULL;

        --Start deletions for 9999 project
        --Start additions  to fix bug #2458260
        --SELECT nvl(last_operation_seq_num, 9999)
        --INTO   l_last_op_seq_num
        --FROM   wsm_parameters
        --WHERE  organization_id = p_organization_id;
        --End additions  to fix bug #2458260
        --End deletions for 9999 project

        --BA: 3546334 get first op_seq_num. when populate WRO, op_seq_num 1 in bic will
        --be copied into WRO as comp req at first operation. in this case seq_num in WRO
        --and BIC not match, thus it was incorrectly be treated as manually added comp.
        l_stmt_num := 15;
        select min(operation_seq_num)
        into   l_first_op_seq_num
        from   wip_operations
        where  wip_entity_id = p_wip_entity_id;
        --EA: 3546334


        -- Note the JOB OPERATION SEQUENCE NUMBER need not have to be the
        -- same as the ONE in ROUTING. Hence, First get the corresponding
        -- operation sequence number in Routing and use this whenever
        -- a join is made with BIC or BOS --BBK

        l_stmt_num := 20;

        Begin

            Select  bos.operation_seq_num, wo.quantity_waiting_to_move
            into    l_rtg_op_seq_num, l_qty_at_tomove
            From    BOM_OPERATION_SEQUENCES bos, wip_operations wo
            Where   bos.operation_sequence_id = NVL(wo.operation_sequence_id, -999)
            and     wo.wip_entity_id = p_wip_entity_id
            and     wo.operation_seq_num = p_op_seq_num
            and     wo.organization_id = p_organization_id
            and     wo.repetitive_schedule_id is NULL;

            IF (l_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'At '||l_stmt_num||' l_rtg_op_seq_num='||l_rtg_op_seq_num);
                fnd_file.put_line(fnd_file.log, 'At '||l_stmt_num||' l_qty_at_tomove='||l_qty_at_tomove);
            END IF;

        Exception
            WHEN NO_DATA_FOUND Then -- Job is not at this opseqnum or is at a Jump Operation.
                p_charges_exist := 0;
                return;
        End;

        l_stmt_num := 30;

        --VJ: Start Additions to fix bug #2378859--
        -- Check for possible explosion of phantom components.
        BEGIN

        Select  2 into p_manually_added_comp
        from    wip_requirement_operations wro
        where   wro.wip_entity_id = p_wip_entity_id
        and     wro.organization_id = p_organization_id
        and     wro.operation_seq_num = 0-p_op_seq_num      -- -ve op seq num for exploded components.
        and     wro.wip_supply_type = 6                     -- Phantom components exploded
        and     wro.required_quantity <> 0
        and NOT EXISTS (select 1
                        from    bom_inventory_components bic, wip_discrete_jobs wdj
                        where   bic.bill_sequence_id = NVL(wdj.common_bom_sequence_id, -999)
                        and     bic.component_item_id = wro.inventory_item_id
                        and     (bic.operation_seq_num = l_rtg_op_seq_num -- NOTE:use of BOS opseq Num
                                 or
                                 bic.operation_seq_num = 1 and p_op_seq_num = l_first_op_seq_num)  --bugfix 3546334
                        and     wdj.wip_entity_id = wro.wip_entity_id
                        and     wdj.organization_id = wro.organization_id);

        IF (l_debug = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'At '||l_stmt_num||' p_manually_added_comp='||p_manually_added_comp);
        END IF;

        EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        p_manually_added_comp := 0;
                        x_error_code := 0;
                        x_error_msg  := 'WSMPUTIL.check_charges_exist (' || l_stmt_num
                                || ') : No components have been added to this job manually or phnatom exploded. Job id= '
                                || p_wip_entity_id;

                WHEN TOO_MANY_ROWS THEN
                        p_manually_added_comp := 2;
                        x_error_code := 0;
                        x_error_msg  := 'WSMPUTIL.check_charges_exist ('
                                || l_stmt_num
                                || ') : Phantom Components have been exploded in this operation for this job. Job id ='
                                || p_wip_entity_id;

                WHEN OTHERS THEN
                        x_error_code := SQLCODE;
                        x_error_msg  := 'WSMPUTIL.check_charges_exist (' || l_stmt_num
                                || ') : Exception: Job id = ' || p_wip_entity_id;
                        raise e_proc_exception;

        END; --check for possible phantom explosions
        --VJ: End Additions to fix bug #2378859--

        -- This sql checks if there are any components that the user "intends to" issue
        --  manually. This pl/sql block looks for components in WRO that are not
        --  present in bom_inventory_components. It does not matter whether or not the user
        --  has already issued this material to job currently, what matters is recording the
        --  user's "intention" to issue these matls manually.

        -- added by BBK.
        -- Check Manual Material Requirement at this operation.

l_stmt_num := 40;

    IF (p_manually_added_comp = 0) THEN         --VJ: Added condition to fix bug #2378859--

        --Start changes to fix bug #2404640--
l_stmt_num := 50;

        --1. Get the opseqid of the start operation of the routing
        SELECT common_routing_sequence_id,
               routing_revision_date
        INTO   l_rtg_seq_id,
               l_rtg_rev_dt
        FROM   wip_discrete_jobs
        WHERE  wip_entity_id = p_wip_entity_id
        AND    organization_id = p_organization_id;

l_stmt_num := 60;

        find_routing_start(p_routing_sequence_id => l_rtg_seq_id,
                           p_routing_rev_date    => l_rtg_rev_dt,
                           start_op_seq_id       => l_start_op_seq_id,
                           x_err_code            => x_error_code,
                           x_err_msg             => x_error_msg);

l_stmt_num := 70;

        --2. Get the opseqid of the current operation of the job
        SELECT operation_sequence_id
        INTO   l_job_start_op_seq_id
        FROM   wip_operations
        WHERE  wip_entity_id = p_wip_entity_id
        AND    organization_id = p_organization_id
        AND    operation_seq_num = p_op_seq_num;

        l_consider_op_seq1 := 0;

        --3. If the job is currently at the first operation of the routing
        IF (l_start_op_seq_id = l_job_start_op_seq_id) THEN

l_stmt_num := 80;

            --4. Check if there is an operation with sequence 1 in the routing of the job
            BEGIN
                SELECT  0
                INTO    l_consider_op_seq1
                FROM    bom_operation_sequences
                WHERE   routing_sequence_id = l_rtg_seq_id
                AND     operation_seq_num = 1;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_consider_op_seq1 := 1;
                WHEN OTHERS THEN
                    x_error_code := SQLCODE;
                    x_error_msg  := 'WSMPUTIL.check_charges_exist (' || l_stmt_num
                            || ') : Exception: Job id = ' || p_wip_entity_id;
                    raise e_proc_exception;
            END;
        END IF;

    --5. If l_consider_op_seq1 = 1, consider opseq 1 from bom while checking for components in the current op
        BEGIN
            IF (l_consider_op_seq1 = 1) THEN
                l_stmt_num := 90;

                SELECT  1
                INTO    p_manually_added_comp
                FROM    wip_requirement_operations wro
                WHERE   wro.wip_entity_id = p_wip_entity_id
                AND     wro.organization_id = p_organization_id
                AND     wro.operation_seq_num = p_op_seq_num
                AND     wro.required_quantity <> 0
                AND     NOT EXISTS (
                        select 1
                        from    bom_inventory_components bic, wip_discrete_jobs wdj
                        where   bic.bill_sequence_id = NVL(wdj.common_bom_sequence_id, -999)
                        and     bic.component_item_id = wro.inventory_item_id
                        --and     bic.operation_seq_num in (1, l_rtg_op_seq_num) -- NOTE:use of BOS opseq Num
                        and     (bic.operation_seq_num = l_rtg_op_seq_num -- NOTE:use of BOS opseq Num
                                 or
                                 bic.operation_seq_num = 1 and p_op_seq_num = l_first_op_seq_num)  --bugfix 3546334
                        and     wdj.wip_entity_id = wro.wip_entity_id
                        and     wdj.organization_id = wro.organization_id);
            ELSE
    --End changes to fix bug #2404640--
            l_stmt_num := 100;

                SELECT  1
                INTO    p_manually_added_comp
                FROM    wip_requirement_operations wro
                WHERE   wro.wip_entity_id = p_wip_entity_id
                AND     wro.organization_id = p_organization_id
                AND     wro.operation_seq_num = p_op_seq_num
                AND     wro.required_quantity <> 0
                AND     NOT EXISTS (
                        select  1
                        from    bom_inventory_components bic, wip_discrete_jobs wdj
                        where   bic.bill_sequence_id = NVL(wdj.common_bom_sequence_id, -999)
                        and     bic.component_item_id = wro.inventory_item_id
                        and     bic.operation_seq_num = l_rtg_op_seq_num -- NOTE:use of BOS opseq Num
                        and     wdj.wip_entity_id = wro.wip_entity_id
                        and     wdj.organization_id = wro.organization_id);

            END IF;

            IF SQL%ROWCOUNT <> 0 Then
                p_manually_added_comp := 1;
            End If;


            IF (l_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'At '||l_stmt_num||' p_manually_added_comp='||p_manually_added_comp);
            END IF;

        EXCEPTION

                WHEN NO_DATA_FOUND THEN
                    p_manually_added_comp := 0;
                    x_error_code := 0;
                    x_error_msg  := 'WSMPUTIL.check_charges_exist (' || l_stmt_num
                                    || ') : No components have been added to this job manually. Job id = '
                                    || p_wip_entity_id;

                WHEN TOO_MANY_ROWS THEN
                    p_manually_added_comp := 1;
                    x_error_code := 0;
                    x_error_msg  := 'WSMPUTIL.check_charges_exist ('
                                    || l_stmt_num
                                    || ') : Components have been added to this job manually. Job id = '
                                    || p_wip_entity_id;

                WHEN OTHERS THEN
                    x_error_code := SQLCODE;
                    x_error_msg  := 'WSMPUTIL.check_charges_exist (' || l_stmt_num
                                    || ') : Exception: Job id = ' || p_wip_entity_id;
                    raise e_proc_exception;

        END; --check Manually Material Requirements
    END IF;  --p_manually_added_comp = 0     --VJ: Added condition to fix bug #2378859--

        -- Check if charges exist for this job. Looking at records in WRO will not give the correct
        --  picture if the cost processor has not been run between the time this job moved to the latest
        --  op in the n/w rtg to the time this code is run. So, one needs to look in MMT to see if
        --  any material has been *already issued* (since this job is at intraop step Q) from the
        --  inventory to the job. This is the purpose of the following pl/sql block.

l_stmt_num := 110;

    If l_qty_at_tomove = 0 Then -- BBK

        BEGIN
            --This SQL is commented out.New SQL is added that includes
            --mtl_material_transactions_temp also.
            /*
                    select sum(primary_quantity)
                    into l_dummy_number
                    from mtl_material_transactions
                    where organization_id = p_organization_id
                    and transaction_source_id = p_wip_entity_id
                    and operation_seq_num = p_op_seq_num
                    --and transaction_source_type_id = 5 -- Job or Schedule
                    -- VJ: Start changes to fix bug #2663468--
                    and ((transaction_source_type_id = 5 -- Job or Schedule
                          and transaction_action_id not in (40, 41, 42, 43)
                         )
                        or transaction_type_id not in (55, 56, 57, 58)
                        )
                    -- VJ: End changes to fix bug #2663468--
                    group by inventory_item_id
                    having sum(primary_quantity) <> 0;
            */

            /*Start of Changes for Bug 3229281*/
            select sum(primary_quantity)
            into l_dummy_number
            from (
                select  inventory_item_id,primary_quantity
                from    mtl_material_transactions
                where   organization_id = p_organization_id
                and     transaction_source_id = p_wip_entity_id
                and     operation_seq_num = p_op_seq_num
                and     ((transaction_source_type_id = 5
                          and transaction_action_id not in (40, 41, 42, 43)
                         )
                         or transaction_type_id not in (55, 56, 57, 58)
                        )
                union all
                select  inventory_item_id,primary_quantity
                from    mtl_material_transactions_temp
                where   organization_id = p_organization_id
                and     transaction_source_id = p_wip_entity_id
                and     operation_seq_num = p_op_seq_num
                and     ((transaction_source_type_id = 5
                         and transaction_action_id not in (40, 41, 42, 43)
                         )
                        or transaction_type_id not in (55, 56, 57, 58)
                        )
                )
            group by inventory_item_id
            having sum(primary_quantity) <> 0;
            /*End of Changes for Bug 3229281*/

            IF SQL%ROWCOUNT <> 0 Then
                    p_issued_material := 1;
            End If;

            IF (l_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'At '||l_stmt_num||' l_dummy_number='||l_dummy_number);
                fnd_file.put_line(fnd_file.log, 'At '||l_stmt_num||' p_issued_material='||p_issued_material);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_issued_material := 0;
                x_error_code := 0;
                x_error_msg  := 'WSMPUTIL.check_charges_exist ('
                                || l_stmt_num
                                || ') : No matl has been issued to this job. Job id = '
                                || p_wip_entity_id;

            WHEN TOO_MANY_ROWS THEN
                p_issued_material := 1;
                x_error_code := 0;
                x_error_msg  := 'WSMPUTIL.check_charges_exist ('
                                || l_stmt_num
                                || ') Materials have been issued to this job. Job id = '
                                || p_wip_entity_id;

            WHEN OTHERS THEN
                x_error_code := SQLCODE;
                x_error_msg  := substr(
                                ('WSMPUTIL.check_charges_exist ('
                                || l_stmt_num
                                || ') Job id = '
                                || p_wip_entity_id || ' : Exception =  '||SQLERRM), 1, 1000);
                raise e_proc_exception;
        END;

        l_stmt_num := 120;

        -- Check if charges exist for this job. Looking at records in WRO will not give the correct
        -- picture if the cost processor has not been run between the time this job moved to the latest
        -- op in the n/w rtg to the time this code is run. So, one needs to look in WT to see if
        -- any resources have been *already issued* (since this job is at intraop step Q) from the
        -- inventory to the job. This is the purpose of the following pl/sql block.

        BEGIN
            --Bug 3229281
            --The following sql is commented out because it does not include
            --resource txns in wip_cost_txn_interface table.
            /*      select wip_entity_id
                    into l_dummy_number
                    from wip_transactions
                    where organization_id = p_organization_id
                    and wip_entity_id = p_wip_entity_id
                    and operation_seq_num = p_op_seq_num; */

            /*Start of Changes for Bug 3229281*/
            /*The following SQL checks if the net quantity of
              each resource is 0 or not.
            */
            select sum(primary_quantity)
            into   l_dummy_number
            from
            (
                    select  resource_id,PRIMARY_QUANTITY
                    from    wip_transactions
                    where   organization_id = p_organization_id
                    and     wip_entity_id = p_wip_entity_id
                    and     operation_seq_num = p_op_seq_num
                    and     transaction_type in (1,3)
                    UNION ALL
                    select  resource_id,PRIMARY_QUANTITY
                    from    wip_cost_txn_interface
                    where   organization_id = p_organization_id
                    and     wip_entity_id = p_wip_entity_id
                    and     operation_seq_num = p_op_seq_num
                    and transaction_type in (1,3)
            )
            group by resource_id
            having sum(primary_quantity) <> 0;

            /*End of Changes for Bug 3229281*/

            IF SQL%ROWCOUNT <> 0 Then
                    p_issued_resource := 1;
            End If;

            IF (l_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'At '||l_stmt_num||' l_dummy_number='||l_dummy_number);
                fnd_file.put_line(fnd_file.log, 'At '||l_stmt_num||' p_issued_resource='||p_issued_resource);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_issued_resource := 0;
                x_error_code := 0;
                x_error_msg  := 'WSMPUTIL.check_charges_exist ('
                        || l_stmt_num
                        || ') : No resource have been issued to this job. Job id = '
                        || p_wip_entity_id;

            WHEN TOO_MANY_ROWS THEN
                p_issued_resource := 1;
                x_error_code := 0;
                x_error_msg  := 'WSMPUTIL.check_charges_exist ('
                                || l_stmt_num
                                || ') Resources have been issued to this job. Job id = '
                                || p_wip_entity_id;

            WHEN OTHERS THEN
                x_error_code := SQLCODE;
                x_error_msg  := substr(
                                ('WSMPUTIL.check_charges_exist ('
                                || l_stmt_num
                                || ') Job id = '
                                || p_wip_entity_id || ' : Exception =  '||SQLERRM), 1, 1000);
                raise e_proc_exception;
        END;

    Else -- Qty is at TOMOVE
                    p_issued_material := 0;
                    p_issued_resource := 0;
                    x_error_code := 0;
                    x_error_msg  := 'WSMPUTIL.check_charges_exist ('
                                    || l_stmt_num
                                    || ') : Qty is at TOMOVE. Job id = '
                                    || p_wip_entity_id;
    End If; -- end of qty_at_tomove for materials and Resources

l_stmt_num := 130;

    -- This sql checks if there are any resources that the user intends to issue
    --  manually. This pl/sql block looks for resources in WOR that are not
    --  present in bom_operation_resources. It does not matter whether or not the user
    --  has already issued these resources to job yet, what matters is recording the
    --  user's intention to issue these resources manually.

    BEGIN
            -- added by BBK.

        select  1 into p_manually_added_resource
        From    wip_operation_resources wor
        Where   wor.wip_entity_id = p_wip_entity_id
        and     wor.operation_seq_num = p_op_seq_num
        and     wor.repetitive_schedule_id is NULL
        and     wor.applied_resource_units <> 0
        and NOT EXISTS (select  1
                        From    bom_operation_resources bor, wip_operations wo
                        Where   bor.operation_sequence_id = wo.operation_sequence_id
                        and     bor.resource_seq_num = wor.resource_seq_num
                        and     wo.wip_entity_id = wor.wip_entity_id
                        and     wo.operation_seq_num = wor.operation_seq_num);

        IF SQL%ROWCOUNT <> 0 Then
                p_manually_added_resource := 1;
        End If;

        IF (l_debug = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'At '||l_stmt_num||' p_manually_added_resource='||p_manually_added_resource);
        END IF;


    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            x_error_code := 0;
            p_manually_added_resource := 0;
            x_error_msg  := 'WSMPUTIL.check_charges_exist ('
                            || l_stmt_num
                            || ') : Resources have not been issued manually to this job. Job id = '
                            || p_wip_entity_id;

        WHEN TOO_MANY_ROWS THEN
            p_manually_added_resource := 1;
            x_error_code := 0;
            x_error_msg  := 'WSMPUTIL.check_charges_exist ('
                            || l_stmt_num
                            || ') Resources have been manually issued to this job. Job id = '
                            || p_wip_entity_id;

        WHEN OTHERS THEN
            x_error_code := SQLCODE;
            x_error_msg  := substr(
                            ('WSMPUTIL.check_charges_exist ('
                            || l_stmt_num
                            || ') Job id = '
                            || p_wip_entity_id || ' : Exception =  '||SQLERRM), 1, 1000);
            raise e_proc_exception;
    END;

        -- Now, check if charges exist.
l_stmt_num := 140;

    if ( (p_issued_resource <> 0) or (p_manually_added_resource <> 0)  or
            (p_issued_material <> 0) or (p_manually_added_comp  <> 0)
       ) then
            p_charges_exist := 1;
    end if;

    IF (l_debug = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'At '||l_stmt_num||' p_charges_exist='||p_charges_exist);
    END IF;

EXCEPTION

    WHEN e_proc_exception THEN
            x_error_code := -99;

    WHEN OTHERS THEN
            x_error_code := sqlcode;
            x_error_msg  := substr(
                                ('WSMPUTIL.check_charges_exist ('
                                || l_stmt_num
                                || ') Job id = '
                                || p_wip_entity_id || ' : Exception =  '||SQLERRM), 1, 1000);

END check_charges_exist;



/***************************************************************************************/
-- CZH.I_OED-2
--      return NULL if no effective replacement is found
Function replacement_op_seq_id (
                p_op_seq_id          NUMBER,
                p_routing_rev_date   DATE
                ) RETURN INTEGER
IS
        replacement_op_seq_id NUMBER := NULL;
        eff_date              DATE   := NULL;
        dis_date              DATE   := NULL;
        l_rtg_rev_date        DATE;
BEGIN

        l_rtg_rev_date :=  NVL(p_routing_rev_date, SYSDATE);

        SELECT operation_sequence_id,
               effectivity_date,
               disable_date
        INTO   replacement_op_seq_id,
               eff_date,
               dis_date
        FROM   bom_operation_sequences
        WHERE  operation_sequence_id = p_op_seq_id;

        --IF NOT( l_rtg_rev_date >= eff_date  AND l_rtg_rev_date <  nvl(dis_date, l_rtg_rev_date+1) ) THEN
        IF NOT( l_rtg_rev_date between eff_date  and NVL(dis_date, l_rtg_rev_date+1) ) THEN

            SELECT bos.operation_sequence_id
            INTO   replacement_op_seq_id
            FROM   bom_operation_sequences bos,
                   bom_operation_sequences bos2
            WHERE  l_rtg_rev_date between bos.effectivity_date and  nvl(bos.disable_date, l_rtg_rev_date+1) --HH24MISS
            AND    bos.operation_seq_num      = bos2.operation_seq_num
            AND    bos.routing_sequence_id    = bos2.routing_sequence_id
            AND    bos2.operation_sequence_id = p_op_seq_id;

        END IF;

        return replacement_op_seq_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        return NULL;

    WHEN OTHERS THEN
        return NULL;
END replacement_op_seq_id;

-- OSP : This procedure determines if the routing (R), operation (O) in a routing
--       or a standard operation (S) has PO Move charge type resources attached
--       to them.


FUNCTION check_po_move (
             p_sequence_id      NUMBER,
             p_sequence_id_type     VARCHAR2,
         p_routing_rev_date     DATE,
         x_err_code             OUT NOCOPY NUMBER,
         x_err_msg              OUT NOCOPY VARCHAR2

) RETURN BOOLEAN IS

x_rowcount INTEGER ;

BEGIN
    -- when the id passed is routing_sequence_id

    if p_sequence_id_type = 'R' then

             SELECT count(*)
             INTO   x_rowcount
             FROM   bom_operational_routings bor,
            bom_operation_resources bres,
            bom_operation_sequences bos
             WHERE  bor.routing_sequence_id = p_sequence_id
         AND    bor.common_routing_sequence_id = bos.routing_sequence_id
         AND    bos.operation_sequence_id = bres.operation_sequence_id
        /* BD HH24MISS*/ /*
         AND    nvl(p_routing_rev_date, SYSDATE)
            >= bos.effectivity_date
             AND    nvl(p_routing_rev_date, SYSDATE)
            <  nvl(bos.disable_date, nvl(p_routing_rev_date, SYSDATE)+1)
         */ /* ED HH24MISS*/
        /*BA HH24MISS */
         AND    nvl(p_routing_rev_date, SYSDATE) BETWEEN
            bos.effectivity_date AND nvl(bos.disable_date, nvl(p_routing_rev_date, SYSDATE)+1)
        /*EA HH24MISS */
         AND    bres.autocharge_type = WIP_CONSTANTS.PO_MOVE ;

    -- when the id passed is operation_sequence_id

    elsif p_sequence_id_type = 'O' then

             SELECT count(*)
             INTO   x_rowcount
             FROM   bom_operation_resources bres,
            bom_operation_sequences bos
             WHERE  bos.operation_sequence_id =  p_sequence_id
         AND    bos.operation_sequence_id = bres.operation_sequence_id
        /*BD HH24MISS */ /*
         AND    nvl(p_routing_rev_date, SYSDATE)
            >= bos.effectivity_date
             AND    nvl(p_routing_rev_date, SYSDATE)
            <  nvl(bos.disable_date, nvl(p_routing_rev_date, SYSDATE)+1)
        */ /*ED HH24MISS */
        /*BA HH24MISS */
         AND    nvl(p_routing_rev_date, SYSDATE) BETWEEN
            bos.effectivity_date AND nvl(bos.disable_date, nvl(p_routing_rev_date, SYSDATE)+1)
        /*EA HH24MISS */
         AND    bres.autocharge_type = WIP_CONSTANTS.PO_MOVE ;

    -- when the id passed is standard_operation_id

    elsif p_sequence_id_type = 'S' then

         SELECT count(*)
             INTO   x_rowcount
             FROM   bom_std_op_resources  bsor
             WHERE  bsor.standard_operation_id = p_sequence_id
         AND    bsor.autocharge_type = WIP_CONSTANTS.PO_MOVE;

    end if;

    if x_rowcount <> 0 then
        return TRUE;
    else
        return FALSE;
    end if;

EXCEPTION

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPUTIL.CHECK_PO_MOVE' ||substrb(sqlerrm, 1,1000);
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
        return FALSE;

END check_po_move ;


 --
 -- Bugfix 2617330
 --
 -- This new procedure will be used by WIP to determine if the lot based jobs
 -- can be closed or not. The API will accept 2 parameters: group_id and orgn_id
 -- Using these parameters, the API would identify all the lot based jobs in
 -- the table WIP_DJ_CLOSE_TEMP and validate these records.
 -- All jobs that fail in validation process would be printed and the value of
 -- column STATUS_TYPE  in wip_dj_close_temp would be updated to 99.
 -- In the end, the status of these jobs in wip_discrete_jobs will be updated to 15 (Failed Close)
 -- and records in wip_dj_close_temp with status 99 will be deleted.
 --
 -- x_err_code will be set to 0 if there are any unprocessed/uncosted txn.
 -- Otherwise, x_err_code will have a value of 1.
 --

 PROCEDURE validate_lbj_before_close (
            p_group_id          in number,
            p_organization_id   in number,
            x_err_code   out nocopy number,
            x_err_msg    out nocopy varchar2,
            x_return_status  out nocopy varchar2 ) is


 BEGIN


    -- Initialize Variables

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_err_code := 1;


    -- bugfix 2678167 : Modified the logic to improve performance. We will directly update the status
    --                  instead of looping thru one-by-one.

    -- Update the temp table status_type to 99 if there are any pending txns for that LBJ record.

    -- bugfix 3080643. added check for WLT interface in WSJI and WRJI, and Move Txn interface in WLMTI
    -- replace previous union query with check exists

    update wip_dj_close_temp wt
    set    status_type = 99
    where  wt.group_id = p_group_id
    and    wt.organization_id = p_organization_id
    and    wt.status_type <> 99
    and    exists (
            select '1' from wip_entities we
            where we.wip_entity_id = wt.wip_entity_id
            and   we.organization_id = wt.organization_id
            and   we.entity_type = 5)       -- check only LBJs
    and    (exists (
                select 1
                from   wsm_sm_starting_jobs sj,
                       wsm_split_merge_transactions wmt
               --Bug 4744794: join based on wip_entity_id is replaced with
               -- join based on wip_entity_name so that index is used.
                --where  sj.wip_entity_id = wt.wip_entity_id
                -- Modified SQL back to wip_entity_id for bug 9433681. We cannot use job name since it's updated during completion.
                where  sj.wip_entity_id = wt.wip_entity_id
                and    sj.organization_id = wt.organization_id
                and    sj.transaction_id = wmt.transaction_id
                and    (wmt.status <> 4 or nvl(wmt.costed,1) <> 4))
            or exists (
                select 1
                from   wsm_sm_resulting_jobs rj,
                       wsm_split_merge_transactions wmt
               --Bug 4744794: join based on wip_entity_id is replaced with
               -- join based on wip_entity_name so that index is used.
                --where  rj.wip_entity_id = wt.wip_entity_id
                -- Modified SQL back to wip_entity_id for bug 9433681. We cannot use job name since it's updated during completion.
                where  rj.wip_entity_id = wt.wip_entity_id
                and    rj.organization_id = wt.organization_id
                and    rj.transaction_id = wmt.transaction_id
                and    (wmt.status <> 4 or nvl(wmt.costed,1) <> 4))
            or exists (
                select 1
                from   wsm_starting_jobs_interface wsji,
                       wsm_split_merge_txn_interface wsmti
                where  wsji.wip_entity_id = wt.wip_entity_id
                and    wsmti.header_id = wsji.header_id
                and    wsmti.process_status in (WIP_CONSTANTS.PENDING, WIP_CONSTANTS.RUNNING))
            or exists (
                select 1
                from   wsm_resulting_jobs_interface wrji,
                       wsm_split_merge_txn_interface wsmti
                where  wrji.wip_entity_name = wt.wip_entity_name
                and    wsmti.header_id = wrji.header_id
                and    wsmti.process_status in (WIP_CONSTANTS.PENDING, WIP_CONSTANTS.RUNNING))
              --Bug 4744794: Separate SQLs are used to select the records for the cases
              -- wip_entity_id is Null and wip_entity_id is NOT NULL
            or exists (
                select 1
                from   wsm_lot_move_txn_interface wlmti
                --where  (nvl(wlmti.wip_entity_id, -9999) = wt.wip_entity_id or
                --       nvl(wlmti.wip_entity_name, '@#$*') = wt.wip_entity_name)
                where   wlmti.wip_entity_id = wt.wip_entity_id
                and    wlmti.status in (WIP_CONSTANTS.PENDING, WIP_CONSTANTS.RUNNING))
            or exists (
                select 1
                from   wsm_lot_move_txn_interface wlmti
                where  wlmti.wip_entity_name = wt.wip_entity_name
                and    wlmti.organization_id = wt.organization_id
                and    wlmti.status in (WIP_CONSTANTS.PENDING, WIP_CONSTANTS.RUNNING)));

    if sql%rowcount > 0 then
    x_err_code := 0;    -- this is needed by WIP to figure out whether to end the request in warning or success.
    end if;
    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'WSMPUTIL.validate_lbj_before_close: Updated LBJ records to ERROR.');
    end if;


    -- Update the WDJ status type to 15
    update wip_discrete_jobs
    set    status_type = 15     -- Failed Close.
    where  wip_entity_id in
                  (select wt.wip_entity_id
                   from   wip_dj_close_temp wt, wip_entities we
                   where  wt.group_id = p_group_id
                   and    wt.organization_id = p_organization_id
                   and    wt.status_type = 99
                   and    wt.wip_entity_id = we.wip_entity_id
                   and    we.entity_type = 5);      -- we will touch only the LBJs.

    if (sql%rowcount > 0) then
        fnd_file.put_line(fnd_file.log, 'Following jobs failed the close process because of unprocessed/uncosted WIP lot transactions or Move transactions:');

       -- Print the entities which FAILED CLOSE
        for rec in (select tm.wip_entity_id, we.wip_entity_name
                   from   wip_dj_close_temp tm, wip_entities we
                   where  tm.wip_entity_id = we.wip_entity_id
                   and    tm.organization_id = we.organization_id
                   and    tm.group_id = p_group_id
                   and    tm.organization_id = p_organization_id
                   and    tm.status_type = 99
                   and    we.entity_type = 5)
        loop
            fnd_file.put_line(fnd_file.log, rec.wip_entity_name);
        end loop;

    end if;

    -- Clean up the temp table.
    delete from wip_dj_close_temp
    where  group_id = p_group_id
    and    organization_id = p_organization_id
    and    status_type = 99;

    if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log, 'WSMPUTIL.validate_lbj_before_close: Successfully cleaned up temp table by deleting '||sql%rowcount|| ' records.');
    end if;

 EXCEPTION
    when others then
         fnd_file.put_line(fnd_file.log, 'WSMPUTIL.validate_lbj_before_close: Unexpected Error: '||sqlerrm);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

 END validate_lbj_before_close;




-- The following procedure supplies parameters to the inventory to be used
-- for the record group for the lov that displays lists all lots containing
-- all the components required at the first operation in the bom of the
-- chosen assembly that is being replenished.

PROCEDURE get_Kanban_rec_grp_info (p_organization_id    IN  number,
                p_kanban_assembly_id    IN  number,
                p_rtg_rev_date          IN  date,
                p_bom_seq_id            OUT NOCOPY number,
                p_start_seq_num         OUT NOCOPY number,
                p_error_code            OUT NOCOPY number,
                p_error_msg             OUT NOCOPY varchar2) IS

l_stmt_num                      number;
l_routing_seq_id                number;
l_common_routing_sequence_id    number;
l_start_op_seq_id               number;
l_error_code                    number := 0;
l_err_msg                       varchar2(2000) := '';

begin

l_stmt_num := 10;

begin
SELECT  bom.common_bill_sequence_id
INTO    p_bom_seq_id
FROM    bom_bill_of_materials bom
WHERE   bom.alternate_bom_designator is null
AND     bom.assembly_item_id = p_kanban_assembly_id
AND     bom.organization_id = p_organization_id;
exception
when no_data_found then
    p_bom_seq_id := null;
end;

l_stmt_num := 20;

select bor.routing_sequence_id
into   l_routing_seq_id
from   bom_routing_alternates_v bor
where  bor.organization_id = p_organization_id
and    bor.assembly_item_id = p_kanban_assembly_id
and    bor.alternate_routing_designator is null
and    bor.routing_type = 1
and    bor.cfm_routing_flag = 3;


l_stmt_num := 30;

WSMPUTIL.find_common_routing(
                p_routing_sequence_id => l_routing_seq_id,
                p_common_routing_sequence_id => l_common_routing_sequence_id,
                x_err_code => l_error_code,
                x_err_msg => l_err_msg);

if l_error_code <> 0 then
    p_error_code := l_error_code;
    p_error_msg := l_err_msg;
    return;
end if;


l_stmt_num := 40;

WSMPUTIL.find_routing_start (   l_common_routing_sequence_id,
                    p_rtg_rev_date,
                                l_start_op_seq_id,
                                l_error_code,
                                l_err_msg );

if l_error_code <> 0 then
        p_error_code := l_error_code;
        p_error_msg := l_err_msg;
        return;
end if;


l_stmt_num := 50;

select  bos.operation_seq_num
into    p_start_seq_num
from    bom_operation_sequences bos
where   bos.operation_sequence_id = l_start_op_seq_id;

exception

    when others then
        p_error_code := SQLCODE;
        p_error_msg := substr('wsmputil.get_Kanban_rec_grp_info: stmt no: '||l_stmt_num||' '||SQLERRM,1, 2000);


end get_Kanban_rec_grp_info;




-- the following procedure finds the maximum number of assemblies that can be created
-- out of a given component of a given bill

PROCEDURE get_max_kanban_asmbly_qty (p_bill_seq_id      IN      number,
                                p_component_item_id     IN      number,
                                p_bom_revision_date     IN      date,
                                p_start_seq_num             IN      number,
                p_available_qty         IN      number,
                p_max_asmbly_qty     OUT NOCOPY number,
                                p_error_code             OUT NOCOPY     number,
                                p_error_msg              OUT NOCOPY     varchar2) IS

l_component_quantity    number;
l_component_yield_factor number;

begin

select  component_quantity, component_yield_factor
into    l_component_quantity, l_component_yield_factor
from    bom_inventory_components
where   bill_sequence_id = p_bill_seq_id
and     component_item_id = p_component_item_id
and     (operation_seq_num = p_start_seq_num or operation_seq_num = 1)
and     p_bom_revision_date between effectivity_date and nvl(disable_date, p_bom_revision_date + 1);

p_max_asmbly_qty := round(((p_available_qty * l_component_yield_factor)/l_component_quantity), 6);

exception

        when others then
                p_error_code := SQLCODE;
                p_error_msg := substr('wsmputil.get_max_kanban_asmbly_qty: '||' '||SQLERRM,1, 2000);

end get_max_kanban_asmbly_qty;

   /* bug fix:7387499
   ***************************************************************************
   created this function for bug fix 5529692 to call this in
   BOM_OPERATION_NETWORKS_V to fetch standard operation id of
   operation that is relatively effective at a particular operation
   sequence number and inturn fetch its op code
   **************************************************************************/

   FUNCTION get_eff_stdop_id(p_stdop_id NUMBER,
                            p_opseq_id  NUMBER)
   return NUMBER
   is
   l_opseq_num number;
   l_eff_date date;
   l_routseq_id number;
   l_eff_stdop_id number;
   l_operation_type number;
   begin

     select operation_seq_num,routing_sequence_id,operation_type
     into   l_opseq_num,l_routseq_id,l_operation_type
     from   bom_operation_sequences
     where  standard_operation_id = p_stdop_id
     and    operation_sequence_id = p_opseq_id;

   l_eff_date := WSMPUTIL.EFFECTIVE_DATE(l_opseq_num,l_routseq_id,l_operation_type);

     select standard_operation_id into  l_eff_stdop_id
     from   bom_operation_sequences
     where  effectivity_date =  l_eff_date
     and    operation_seq_num = l_opseq_num
     and    routing_sequence_id = l_routseq_id
     and    operation_type = l_operation_type;

   return l_eff_stdop_id;

   end get_eff_stdop_id;

   /****************************************************************************************************
   Created this function for bug fix 5529692 to call this in
   BOM_OPERATION_NETWORKS_V to fetch standard department id of
   operation that is relatively effective at a particular operation
   sequence number and inturn fetch its department code
   ****************************************************************************************************/

   FUNCTION get_eff_dept_id(p_dept_id number,
                           p_opseq_id number)
   return number
   is
   l_opseq_num number;
   l_eff_date date;
   l_routseq_id number;
   l_eff_dept_id number;
   l_operation_type number;
   begin

     select operation_seq_num,routing_sequence_id,operation_type
     into   l_opseq_num,l_routseq_id,l_operation_type
     from   bom_operation_sequences
     where  department_id  = p_dept_id
     and    operation_SEQUENCE_id = p_opseq_id;

   l_eff_date := WSMPUTIL.EFFECTIVE_DATE(l_opseq_num,l_routseq_id,l_operation_type);

     select department_id into  l_eff_dept_id
     from   bom_operation_sequences
     where  effectivity_date = l_eff_date
     and    operation_seq_num = l_opseq_num
     and    routing_sequence_id = l_routseq_id
     and    operation_type =l_operation_type;

   return l_eff_dept_id;

   end get_eff_dept_id;


   /************************************************************************************************************************
   created this function to pick up the effectivity_date of operation that is
   relatively effective at particular operation sequence number of the routing,
   so that it can be shown in the lov attached to From
   and To fields in Network Routings form.
   ******************************************************************************************************************/

   FUNCTION EFFECTIVE_DATE(p_oper_seq_num number,
                         p_routing_seq_id number,
                         p_operation_type number)
   RETURN DATE
   IS
   l_eff_date date;
   l_count  number := 0;
   l_efe_sysdate number := 1;
   l_max_date date := NULL;
   l_min_date date := NULL;
   begin
           select   count(*) into l_count
           from     bom_operation_sequences s
           where    s.routing_sequence_id = p_routing_seq_id
           and      s.operation_seq_num   = p_oper_seq_num
           and      s.operation_type = p_operation_type
           group by s.operation_seq_num;

           if (l_count = 1) then

           select   s.effectivity_date into l_eff_date
           from     bom_operation_sequences s
           where    s.routing_sequence_id = p_routing_seq_id
           and      s.operation_seq_num   = p_oper_seq_num
           and      s.operation_type = p_operation_type;


           return l_eff_date;

           else

              begin
              select max(s.effectivity_date) into l_eff_date from bom_operation_sequences s
              where    s.routing_sequence_id = p_routing_seq_id
              and      s.operation_seq_num   = p_oper_seq_num
              and    sysdate <= nvl(s.disable_date, sysdate+1)
              and    s.effectivity_date <= sysdate
              and      s.operation_type = p_operation_type
              group by s.operation_seq_num ;


              exception
              WHEN NO_DATA_FOUND THEN
              l_efe_sysdate  := 0;
              end;

               if l_efe_sysdate = 1 then

                  return l_eff_date;

               else
                   begin
                   select max(s.effectivity_date) into l_max_date
                   from     bom_operation_sequences s
                   where    s.routing_sequence_id = p_routing_seq_id
                   and      s.operation_seq_num   = p_oper_seq_num
                   and    s.effectivity_date < sysdate
                   and      s.operation_type = p_operation_type
                   group by s.operation_seq_num ;

                    exception
                    WHEN NO_DATA_FOUND THEN
                    null;
                    end;

                    if (l_max_date IS NOT NULL) then
                    return l_max_date;

                    else

                      select   min(s.effectivity_date) into l_min_date
                      from     bom_operation_sequences s
                      where    s.routing_sequence_id = p_routing_seq_id
                      and      s.operation_seq_num   = p_oper_seq_num
                      and    s.effectivity_date > sysdate
                      and      s.operation_type = p_operation_type
                      group by s.operation_seq_num;


                       return l_min_date;

                     end if; --l_max_date not null

                 end if; --l_efe_sysdate = 0

             end if; -- l_count= 1

   END EFFECTIVE_DATE;

   --********************************************************************************************
   --bug fix:7387499
   --*******************************************************************************************


--***********************************************************************************************
-- ==============================================================================================
-- PROCEDURE return_att_quantity
-- ==============================================================================================
--***********************************************************************************************

PROCEDURE return_att_quantity(p_org_id          IN      number,
                             p_item_id          IN      number,
                             p_rev              IN      varchar2,
                             p_lot_no           IN      varchar2,
                             p_subinv           IN      varchar2,
                             p_locator_id       IN      number,
                             p_qoh              OUT NOCOPY     number,
                             p_atr              OUT NOCOPY     number,
                             p_att              OUT NOCOPY     number,
                             p_err_code         OUT NOCOPY     number,
                             p_err_msg          OUT NOCOPY     varchar2 ) IS

 lv_return_status varchar2(20);
 lv_msg_count     number := 0;
 lv_msg_data      varchar2(4000);
 lv_tree_id       number;
 lv_qoh           number;
 lv_rqoh          number;
 lv_qr            number;
 lv_qs            number;
 lv_att           number;
 lv_atr           number;

BEGIN
   --Bug 4567588:Tree mode is changed from reservation mode (3) to transaction
   --mode (2)
    inv_quantity_tree_pvt.create_tree(
          P_API_VERSION_NUMBER           => 1.0
        , P_INIT_MSG_LST                 => 'T'
        , X_RETURN_STATUS                => lv_return_status
        , X_MSG_COUNT                    => lv_msg_count
        , X_MSG_DATA                     => lv_msg_data
        , P_ORGANIZATION_ID              => p_org_id
        , P_INVENTORY_ITEM_ID            => p_item_id
        , P_TREE_MODE                    => 2 --3
        , P_IS_REVISION_CONTROL          => (p_rev is not null)
        , P_IS_LOT_CONTROL               => TRUE
        , P_IS_SERIAL_CONTROL            => FALSE
        , P_ASSET_SUB_ONLY               => FALSE
        , P_INCLUDE_SUGGESTION           => FALSE
        , P_DEMAND_SOURCE_TYPE_ID        => 13
        , P_DEMAND_SOURCE_HEADER_ID      => -9999
        , P_DEMAND_SOURCE_LINE_ID        => NULL
        , P_DEMAND_SOURCE_NAME           => NULL
        , P_LOT_EXPIRATION_DATE          => null
        , X_TREE_ID                      => lv_tree_id);

    if( lv_return_status <> 'S' ) then
        fnd_message.set_name('INV', 'INV_ERR_CREATETREE');
        p_err_msg := fnd_message.get;
        p_err_code := -1;
        return;
    end if;

    inv_quantity_tree_pvt.QUERY_TREE(
          P_API_VERSION_NUMBER           => 1.0
        , P_INIT_MSG_LST                 => 'T'
        , X_RETURN_STATUS                => lv_return_status
        , X_MSG_COUNT                    => lv_msg_count
        , X_MSG_DATA                     => lv_msg_data
        , P_TREE_ID                      => lv_tree_id
        , P_REVISION                     => p_rev
        , P_LOT_NUMBER                   => p_lot_no
        , P_SUBINVENTORY_CODE            => p_subinv
        , P_LOCATOR_ID                   => p_locator_id
        , X_QOH                          => lv_qoh
        , X_RQOH                         => lv_rqoh
        , X_QR                           => lv_qr
        , X_QS                           => lv_qs
        , X_ATT                          => lv_att
        , X_ATR                          => lv_atr
        );


    if( lv_return_status <> 'S' ) then
        fnd_message.set_name('INV', 'INV-CANNOT QUERY TREE');
        p_err_msg := fnd_message.get;
        p_err_code := -1;
        return;
    end if;

    p_qoh := lv_qoh;
    p_att := lv_att;
    --Bug 4567588
    p_atr := lv_att; --lv_atr;

    inv_quantity_tree_pvt.free_all(
             p_api_version_number => 1.0
           , p_init_msg_lst      => 'T'
           , x_return_status    => lv_return_status
           , x_msg_count       => lv_msg_count
           , x_msg_data       => lv_msg_data
    );

    IF(p_qoh = 0) THEN
        FND_MESSAGE.set_name('WSM','WSM_ZERO_ON_HAND');
        p_err_msg := fnd_message.get;
        p_err_code := -1;
        return;
    END IF;

    IF p_atr = 0 THEN
        FND_MESSAGE.set_name('WSM','WSM_LOT_FULL_RESERVED');
        p_err_msg := fnd_message.get;
        p_err_code := -1;
        return;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        p_err_code := SQLCODE;
        p_err_msg := substr('WSMPUTIL.return_att_quantity :' ||sqlerrm, 1,2000);
        FND_FILE.PUT_LINE(FND_FILE.LOG, p_err_msg);
        return;
END return_att_quantity;




-- OSP FP I addition begin
-- this function checks to see if the operation has an OSP resource
-- attached to it

function  check_osp_operation ( p_wip_entity_id     IN NUMBER,
                    p_operation_seq_num IN OUT NOCOPY NUMBER,
                    p_organization_id   IN NUMBER )


return boolean is

 l_op_seq_num  number;

begin

 l_op_seq_num := -1 ;

    select unique wor.operation_seq_num
    into l_op_seq_num
    from  wip_operation_resources wor
    where wor.organization_id = p_organization_id
    and  wor.wip_entity_id = p_wip_entity_id
    and  wor.operation_seq_num = nvl(p_operation_seq_num,wor.operation_seq_num)
    and  wor.autocharge_type IN (WIP_CONSTANTS.PO_RECEIPT,
                                 WIP_CONSTANTS.PO_MOVE);
    p_operation_seq_num := l_op_seq_num ;
    return true;

exception

 when no_data_found then

  return false;

  when too_many_rows then

  return true;

 -- when others then has been deliberately not written so that
 -- exception is thrown in the calling program. this means that
 -- x_error_code and x_error_msg out variables need not be
 -- defined here and passed back.

end check_osp_operation ;


 ------------------------------------------------------------
 -- FUNCTIONS THAT CHECK TXN and TXN INTERFACE TABLES
 ------------------------------------------------------------

/***************************************************************************************/

FUNCTION CHECK_WLMTI (
                   p_wip_entity_id      IN  NUMBER,
                   p_wip_entity_name    IN  VARCHAR2,
                   p_header_id          IN  NUMBER,
                   p_transaction_date   IN  DATE,
                   x_err_code           OUT NOCOPY NUMBER,
                   x_err_msg            OUT NOCOPY VARCHAR2,
           p_organization_id    IN  NUMBER
                   )
RETURN NUMBER
IS
    l_rowcount  NUMBER := 0;
    l_stmt_num  NUMBER := 0;

BEGIN
    x_err_code := 0;
    x_err_msg := '';
    l_stmt_num := 10;

/***************************************************************
-- Fixed bug #3453139: Stubbed out this procedure, since txns should not depend on interface records.

    l_rowcount := 0;

    IF (p_wip_entity_id IS NOT NULL) THEN

        l_stmt_num := 20;

        SELECT  1
        INTO    l_rowcount
    From    dual
    where exists (select 'Unprocessed WLMTI Record exists'
            FROM    WSM_LOT_MOVE_TXN_INTERFACE WLMTI
            WHERE   WLMTI.entity_type = 5
            AND     WLMTI.wip_entity_id = p_wip_entity_id
            AND     WLMTI.status IN (WIP_CONSTANTS.PENDING,
                                 WIP_CONSTANTS.RUNNING,
                                 WIP_CONSTANTS.ERROR)
            AND     WLMTI.transaction_date <= p_transaction_date
            AND     WLMTI.header_id <> p_header_id);
    -- Use of header_id here in WLMTI is useful to support BULK MOVE Txns
    -- Otherwise, I don't see any use for this. -- BBK.

        IF (l_rowcount > 0 ) THEN
                RETURN l_rowcount;
        END IF;


    ELSIF (p_wip_entity_name IS NOT NULL) THEN

        l_stmt_num := 30;

        SELECT  1
        INTO    l_rowcount
    From    dual
    where exists (select 'Unprocessed WLMTI Record exists'
            FROM    WSM_LOT_MOVE_TXN_INTERFACE WLMTI
            WHERE   WLMTI.entity_type = 5
            AND     WLMTI.wip_entity_name = p_wip_entity_name
        AND WLMTI.organization_id = decode(p_organization_id, 0, WLMTI.organization_id, p_organization_id)
            AND     WLMTI.status IN (WIP_CONSTANTS. PENDING,
                                 WIP_CONSTANTS.RUNNING,
                                 WIP_CONSTANTS.ERROR)
            AND     WLMTI.transaction_date <= p_transaction_date
            AND     WLMTI.header_id <> p_header_id );


        IF (l_rowcount > 0 ) THEN
        NULL;
                RETURN l_rowcount;
        END IF;

    END IF;
***************************************************************/

    x_err_code := 0;
    x_err_msg := 'WSMPUTIL.CHECK_WLMTI:Success';

    If (l_debug = 'Y') Then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'WSMPUTIL.check_wlmti: Returned Success');
    End If;

    RETURN l_rowcount;

EXCEPTION
    WHEN NO_DATA_FOUND THEN -- NO UNPROCESSED TXNS EXIST
    l_rowcount := 0;
    RETURN l_rowcount;

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPUTIL.check_wlmti(stmt_num='||l_stmt_num||' :'||SUBSTR(SQLERRM,1,1000);
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);

END CHECK_WLMTI;

--
-- Overloaded function, org_id missing
--
FUNCTION CHECK_WLMTI (
                   p_wip_entity_id      IN  NUMBER,
                   p_wip_entity_name    IN  VARCHAR2,
                   p_header_id          IN  NUMBER,
                   p_transaction_date   IN  DATE,
                   x_err_code           OUT NOCOPY NUMBER,
                   x_err_msg            OUT NOCOPY VARCHAR2
                   )
RETURN NUMBER AS

    l_organization_id NUMBER := 0;
    l_return_value NUMBER := 0;

BEGIN

    x_err_code := 0;
    x_err_msg := '';

/***************************************************************
-- Fixed bug #3453139: Stubbed out this procedure, since txns should not depend on interface records.

    l_return_value := check_wlmti( p_wip_entity_id => p_wip_entity_id
                , p_wip_entity_name => p_wip_entity_name
                , p_header_id => p_header_id
                , p_transaction_date => p_transaction_date
                , x_err_code => x_err_code
                , x_err_msg => x_err_msg
                , p_organization_id => l_organization_id
                );
***************************************************************/

    return l_return_value;

END CHECK_WLMTI;


/***************************************************************************************/

 -- Moved this procedure from WSMPLOAD to here
FUNCTION CHECK_WMTI
                   (
                   p_wip_entity_id      IN  NUMBER,
                   p_wip_entity_name    IN  VARCHAR2,
                   p_transaction_date   IN  DATE,
                   x_err_code           OUT NOCOPY NUMBER,
                   x_err_msg            OUT NOCOPY VARCHAR2,
           p_organization_id    IN  NUMBER
                   )
RETURN NUMBER
IS
    l_stmt_num  NUMBER := 0;
    l_rowcount  NUMBER := 0;

BEGIN
    x_err_code := 0;
    x_err_msg := '';
    l_stmt_num := 10;

/***************************************************************
-- Fixed bug #3453139: Stubbed out this procedure, since only online moves are now supported

    l_rowcount := 0;

    IF (p_wip_entity_id IS NOT NULL) THEN

        l_stmt_num := 20;

        SELECT  1
        INTO    l_rowcount
    From    dual
    where exists (select 'Unprocessed WMTI Record exists'
            FROM    WIP_MOVE_TXN_INTERFACE WMTI
            WHERE   WMTI.entity_type = 5
            AND     WMTI.wip_entity_id = p_wip_entity_id
            AND     WMTI.process_status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
            AND     WMTI.transaction_date < nvl(p_transaction_date, SYSDATE)
            ); -- So that it doesn't pick up itself


        IF (l_rowcount > 0 ) THEN
            x_err_msg := 'WSMPUTIL.check_wmti('||l_stmt_num||') : Returning error';
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN l_rowcount;
        END IF;

    ELSIF (p_wip_entity_name IS NOT NULL) THEN

        l_stmt_num := 60;

        SELECT  1
        INTO    l_rowcount
    From    dual
    where exists (select 'Unprocessed WMTI Record exists'
            FROM    WIP_MOVE_TXN_INTERFACE WMTI
            WHERE   WMTI.entity_type = 5
            AND     WMTI.wip_entity_name = p_wip_entity_name
        AND WMTI.organization_id = decode(p_organization_id, 0, WMTI.organization_id, p_organization_id)
            AND     WMTI.process_status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
            AND     WMTI.transaction_date < nvl(p_transaction_date, SYSDATE)
            );


        IF (l_rowcount > 0 ) THEN
            x_err_msg := 'WSMPUTIL.check_wmti('||l_stmt_num||') : Returning error';
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN l_rowcount;
        END IF;

    END IF;

***************************************************************/

    x_err_code := 0;
    x_err_msg := 'WSMPUTIL.CHECK_WMTI:Returned Success';
    IF (l_debug = 'Y') THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
    END IF;
    RETURN 0;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_rowcount := 0;
        return l_rowcount;

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPUTIL.check_wmti('||l_stmt_num||') :'||SUBSTR(SQLERRM,1,1000);
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
        return 1; -- return a nonzero value.

END CHECK_WMTI;

--
-- Overloaded function, org_id missing
--
FUNCTION CHECK_WMTI
                   (
                   p_wip_entity_id      IN  NUMBER,
                   p_wip_entity_name    IN  VARCHAR2,
                   p_transaction_date   IN  DATE,
                   x_err_code           OUT NOCOPY NUMBER,
                   x_err_msg            OUT NOCOPY VARCHAR2
                   )
RETURN NUMBER
AS

    l_organization_id NUMBER := 0;
    l_return_value NUMBER := 0;

BEGIN

    x_err_code := 0;
    x_err_msg := NULL;

/***************************************************************
-- Fixed bug #3453139: Stubbed out this procedure, since only online moves are now supported

    l_return_value := check_wmti(p_wip_entity_id => p_wip_entity_id
                    , p_wip_entity_name => p_wip_entity_name
                    , p_transaction_date => p_transaction_date
                    , x_err_code => x_err_code
                    , x_err_msg => x_err_msg
                    , p_organization_id => l_organization_id
                    );
***************************************************************/

    return l_return_value;


END CHECK_WMTI;


/***************************************************************************************/

-- Moved this procedure from WSMPLOAD to here
FUNCTION CHECK_WSMT
                   (
                   p_wip_entity_id      IN  NUMBER,
                   p_wip_entity_name    IN  VARCHAR2,
                   p_transaction_id     IN  NUMBER,
                   p_transaction_date   IN  DATE,
                   x_err_code           OUT NOCOPY NUMBER,
                   x_err_msg            OUT NOCOPY VARCHAR2,
           p_organization_id    IN  NUMBER
                   )
RETURN NUMBER
IS

    l_sj_rowcount   NUMBER := 0;
    l_rj_rowcount   NUMBER := 0;
    l_stmt_num      NUMBER := 0;

BEGIN

    x_err_code := 0;
    x_err_msg := '';
    l_stmt_num := 10;

/***************************************************************
-- Fixed bug #3453139: Stubbed out this procedure, since it should not be called from anywhere.

    if l_debug = 'Y' then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_wip_entity_id        ='||p_wip_entity_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_transaction_id       ='||p_transaction_id);
    end if;


    l_sj_rowcount := 0;
    l_rj_rowcount := 0;

    IF (p_wip_entity_id IS NOT NULL) THEN

        l_stmt_num := 20;

        IF(p_transaction_id IS NULL) THEN
            l_stmt_num := 30;

        Begin

            SELECT  1
            INTO    l_sj_rowcount
        FROM    dual
        WHERE exists (select 'Unprocessed WSMT Record exists'
                    FROM    WSM_SM_STARTING_JOBS WSSJ,
                        WSM_SPLIT_MERGE_TRANSACTIONS WSMT
                    WHERE
                        WSSJ.wip_entity_id = p_wip_entity_id
                    AND     WSMT.transaction_id = WSSJ.transaction_id
                    AND     WSMT.status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
                    AND     WSMT.transaction_date <= nvl(p_transaction_date,SYSDATE)
                );

        EXCEPTION
            WHEN NO_DATA_FOUND THEN -- No UNPROCESSED Txns exist
                NULL;
        End;

        ELSE

            l_stmt_num := 50;

        Begin

            SELECT  1
            INTO    l_sj_rowcount
        FROM    dual
        WHERE exists (select 'Unprocessed WSSJ/WSMT Record exists'
                    FROM    WSM_SM_STARTING_JOBS WSSJ,
                        WSM_SPLIT_MERGE_TRANSACTIONS WSMT
                    WHERE
                        WSSJ.wip_entity_id = p_wip_entity_id
                    AND     WSMT.transaction_id = WSSJ.transaction_id
                    AND     WSMT.status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
                    AND     WSMT.transaction_date <= nvl(p_transaction_date,SYSDATE)
                    AND     WSMT.transaction_id <> p_transaction_id
                );

        EXCEPTION
            WHEN NO_DATA_FOUND THEN -- No UNPROCESSED Txns exist
                NULL;
        End;

        END IF;


        IF (l_sj_rowcount > 0 ) THEN
            x_err_msg := 'WSMPUTIL.check_wsmt('||l_stmt_num||') : Returning error';
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN l_sj_rowcount;
        END IF;

        l_stmt_num := 90;

        IF (p_transaction_id IS NULL) THEN
            l_stmt_num := 100;

        Begin

            SELECT  1
            INTO    l_rj_rowcount
        FROM    dual
        WHERE exists (select 'Unprocessed WSRJ/WSMT Record exists'
                    FROM    WSM_SM_RESULTING_JOBS WSRJ,
                            WSM_SPLIT_MERGE_TRANSACTIONS WSMT
                    WHERE
                            WSRJ.wip_entity_id = p_wip_entity_id
                    AND     WSMT.transaction_id = WSRJ.transaction_id
                    AND     WSMT.status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
                    AND     WSMT.transaction_date <= nvl(p_transaction_date,SYSDATE)
                );

        EXCEPTION
            WHEN NO_DATA_FOUND THEN -- No UNPROCESSED Txns exist
                NULL;
        End;
        ELSE

            l_stmt_num := 120;

        Begin

            SELECT  1
            INTO    l_rj_rowcount
        FROM    dual
        WHERE exists (select 'Unprocessed WSRJ/WSMT Record exists'
                    FROM    WSM_SM_RESULTING_JOBS WSRJ,
                            WSM_SPLIT_MERGE_TRANSACTIONS WSMT
                    WHERE
                            WSRJ.wip_entity_id = p_wip_entity_id
                    AND     WSMT.transaction_id = WSRJ.transaction_id
                    AND     WSMT.status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
                    AND     WSMT.transaction_date <= nvl(p_transaction_date,SYSDATE)
                    AND     WSMT.transaction_id <> p_transaction_id
                );
        EXCEPTION
            WHEN NO_DATA_FOUND THEN -- No UNPROCESSED Txns exist
                NULL;
        End;

        END IF;

        IF (l_rj_rowcount > 0 ) THEN
            x_err_msg := 'WSMPUTIL.check_wsmt('||l_stmt_num||') : Returning error';
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN l_rj_rowcount;
        END IF;

        l_stmt_num := 160;

    ELSIF (p_wip_entity_name IS NOT NULL) THEN

        l_sj_rowcount := 0;
        l_rj_rowcount := 0;

        l_stmt_num := 180;

        IF(p_transaction_id IS NULL) THEN
            l_stmt_num := 190;

        Begin

            SELECT  1
            INTO    l_rj_rowcount
        FROM    dual
        WHERE exists (select 'Unprocessed WSRJ/WSMT Record exists'
                    FROM    WSM_SM_RESULTING_JOBS WSRJ,
                            WSM_SPLIT_MERGE_TRANSACTIONS WSMT
                    WHERE
                            WSRJ.wip_entity_name = p_wip_entity_name
                AND WSMT.organization_id = decode(p_organization_id,
                                                              0, WSMT.organization_id, p_organization_id)
                    AND     WSMT.transaction_id = WSRJ.transaction_id
                    AND     WSMT.status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
                    AND     WSMT.transaction_date <= nvl(p_transaction_date, SYSDATE)
            );

        EXCEPTION
            WHEN NO_DATA_FOUND THEN -- No UNPROCESSED Txns exist
                NULL;
        End;

        ELSE

            l_stmt_num := 210;

        Begin

            SELECT  1
            INTO    l_rj_rowcount
        FROM    dual
        WHERE exists (select 'Unprocessed WSRJ/WSMT Record exists'
                    FROM    WSM_SM_RESULTING_JOBS WSRJ,
                            WSM_SPLIT_MERGE_TRANSACTIONS WSMT
                    WHERE
                            WSRJ.wip_entity_name = p_wip_entity_name
                AND WSMT.organization_id = decode(p_organization_id,
                                                       0, WSMT.organization_id, p_organization_id)
                    AND     WSMT.transaction_id = WSRJ.transaction_id
                    AND     WSMT.status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
                    AND     WSMT.transaction_date <= nvl(p_transaction_date, SYSDATE)
                    AND     WSMT.transaction_id <> p_transaction_id
            );
        EXCEPTION
            WHEN NO_DATA_FOUND THEN -- No UNPROCESSED Txns exist
                NULL;
        End;

        END IF;

        IF (l_rj_rowcount > 0 ) THEN
            x_err_msg := 'WSMPUTIL.check_wsmt('||l_stmt_num||') : Returning error';
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN l_rj_rowcount;
        END IF;

    END IF;

    x_err_code := 0;
    x_err_msg := 'WSMPUTIL.CHECK_WSMT:Returned Success';
    IF (l_debug = 'Y') THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
    END IF;

***************************************************************/

    RETURN 0;

EXCEPTION

        WHEN OTHERS THEN
            x_err_code := SQLCODE;
            x_err_msg := 'WSMPUTIL.CHECK_WSMT' ||'(stmt_num='||l_stmt_num||') : '||substrb(sqlerrm, 1,1000);
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            return 1; -- return a nonzerovalue.

END CHECK_WSMT;


--
-- Overloaded function, org_id missing
--
FUNCTION CHECK_WSMT
                   (
                   p_wip_entity_id      IN  NUMBER,
                   p_wip_entity_name    IN  VARCHAR2,
                   p_transaction_id     IN  NUMBER,
                   p_transaction_date   IN  DATE,
                   x_err_code           OUT NOCOPY NUMBER,
                   x_err_msg            OUT NOCOPY VARCHAR2
                   )
RETURN NUMBER
IS

    l_organization_id NUMBER := 0;
    l_return_value NUMBER := 0;

BEGIN

    x_err_code := 0;
    x_err_msg := NULL;

/***************************************************************
-- Fixed bug #3453139: Stubbed out this procedure, since it should not be called from anywhere.

    l_return_value := check_wsmt(p_wip_entity_id => p_wip_entity_id
                    , p_wip_entity_name => p_wip_entity_name
                    , p_transaction_id => p_transaction_id
                    , p_transaction_date => p_transaction_date
                    , x_err_code => x_err_code
                    , x_err_msg => x_err_msg
                    , p_organization_id => l_organization_id
                    );

***************************************************************/

    return l_return_value;

END CHECK_WSMT;

/***************************************************************************************/

-- Check WIP MOVE TXN for a LATER Txn already registered for a job.
FUNCTION CHECK_WMT (
                   x_err_code           OUT NOCOPY NUMBER
                   , x_err_msg          OUT NOCOPY VARCHAR2
                   , p_wip_entity_id    IN  NUMBER
                   , p_wip_entity_name  IN  VARCHAR2
               , p_organization_id  IN  NUMBER
                   , p_transaction_date IN  DATE
                   )
RETURN NUMBER
IS
    l_stmt_num  NUMBER := 0;
    l_rowcount  NUMBER := 0;

BEGIN
    x_err_code := 0;
    x_err_msg := '';
    l_stmt_num := 10;

/***************************************************************
-- Fixed bug #3453139: Stubbed out this procedure, since it is not called from anywhere.

    l_rowcount := 0;

    IF (p_wip_entity_id IS NOT NULL) THEN

        l_stmt_num := 20;

    -- Processed WMT Record exists with a Later Txn Date
        SELECT  1
        INTO    l_rowcount
        FROM    WIP_MOVE_TRANSACTIONS WMT
        WHERE   WMT.wip_entity_id = p_wip_entity_id
        AND     WMT.transaction_date > nvl(p_transaction_date, SYSDATE)
        AND     rownum = 1;


        IF (l_rowcount > 0 ) THEN
            x_err_msg := 'WSMPUTIL.check_wmt('||l_stmt_num||') : error: Move Txn with a later txn date found.';
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN l_rowcount;
        END IF;

    ELSIF (p_wip_entity_name IS NOT NULL) THEN

        l_stmt_num := 60;

    -- Processed WMT Record exists with a Later Txn Date
        SELECT  1
        INTO    l_rowcount
        FROM    WIP_MOVE_TRANSACTIONS WMT, WIP_ENTITIES WE
        WHERE   WMT.wip_entity_id = we.wip_entity_id
    AND we.wip_entity_name = p_wip_entity_name
    AND we.organization_id = p_organization_id
        AND     WMT.transaction_date > nvl(p_transaction_date, SYSDATE)
    AND     rownum = 1;


        IF (l_rowcount > 0 ) THEN
            x_err_msg := 'WSMPUTIL.check_wmt('||l_stmt_num||') : error: Move Txn with a later txn date found.';
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN l_rowcount;
        END IF;

    END IF;


    x_err_code := 0;
***************************************************************/
    RETURN 0;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_rowcount := 0;
            x_err_msg := 'WSMPUTIL.CHECK_WMT:Returned Success';
            IF (l_debug = 'Y') THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            END IF;
        return l_rowcount;

        WHEN OTHERS THEN
            x_err_code := SQLCODE;
            x_err_msg := 'WSMPUTIL.check_wmt('||l_stmt_num||') :'||SUBSTR(SQLERRM,1,1000);
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            return 1; -- return a nonzero value.

END CHECK_WMT;


/***************************************************************************************/

FUNCTION CHECK_WSMTI
                   (
                   x_err_code           OUT NOCOPY NUMBER,
                   x_err_msg            OUT NOCOPY VARCHAR2,
                   p_wip_entity_id      IN  NUMBER,
                   p_wip_entity_name    IN  VARCHAR2,
                   p_organization_id    IN  NUMBER,
                   p_transaction_date   IN  DATE
                   )
RETURN NUMBER
IS

    l_sj_rowcount   NUMBER := 0;
    l_rj_rowcount   NUMBER := 0;
    l_stmt_num      NUMBER := 0;

    l_organization_id NUMBER := 0;
    l_wip_entity_name WIP_ENTITIES.WIP_ENTITY_NAME%TYPE;

BEGIN

    x_err_code := 0;
    x_err_msg := '';
    l_stmt_num := 10;

/***************************************************************
-- Fixed bug #3453139: Stubbed out this procedure, since it is not called from anywhere.

    if l_debug = 'Y' then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'WSMPUTIL.check_wsmti('||l_stmt_num||') Input parameters are ...');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_wip_entity_id    ='||p_wip_entity_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_wip_entity_name  ='||p_wip_entity_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_organization_id  ='||p_organization_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_transaction_date ='||to_char(p_transaction_date, 'DD-MON-YYYY HH24:MI:SS'));
    end if;

    l_sj_rowcount := 0;
    l_rj_rowcount := 0;

    IF (p_wip_entity_id IS NOT NULL) THEN

        l_stmt_num := 20;

        Begin

            SELECT  1
            INTO    l_sj_rowcount
        FROM    dual
        WHERE exists (select 'Unprocessed WSJI/WSMTI Record exists'
                    FROM    WSM_STARTING_JOBS_INTERFACE WSJI,
                            WSM_SPLIT_MERGE_TXN_INTERFACE WSMTI
                    WHERE   WSJI.wip_entity_id = p_wip_entity_id
                    AND     WSMTI.header_id = WSJI.header_id
                    AND     WSMTI.process_status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
                    AND     WSMTI.transaction_date <= nvl(p_transaction_date,SYSDATE)
                );

        EXCEPTION
            WHEN NO_DATA_FOUND THEN -- No UNPROCESSED Txns exist
                NULL;
        End;

        IF (l_sj_rowcount > 0 ) THEN
            x_err_msg := 'WSMPUTIL.check_wsmti('||l_stmt_num||') : Returning error - Unprocessed earlier WSJI Txn';
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN l_sj_rowcount;

        END IF;

        l_stmt_num := 30;

        select wip_entity_name, organization_id
        into l_wip_entity_name, l_organization_id
        from wip_entities
        Where wip_entity_id = p_wip_entity_id;

        l_stmt_num := 40;

        Begin

            SELECT  1
            INTO    l_rj_rowcount
        FROM    dual
        WHERE exists (select 'Unprocessed WRJI/WSMTI Record exists'
                    FROM    WSM_RESULTING_JOBS_INTERFACE WRJI,
                            WSM_SPLIT_MERGE_TXN_INTERFACE WSMTI
                    WHERE   WRJI.wip_entity_name = l_wip_entity_name
                AND WSMTI.organization_id = l_organization_id
                    AND     WSMTI.header_id = WRJI.header_id
                    AND     WSMTI.process_status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
                    AND     WSMTI.transaction_date <= nvl(p_transaction_date,SYSDATE)
                );

        EXCEPTION
            WHEN NO_DATA_FOUND THEN -- No UNPROCESSED Txns exist
                NULL;
        End;

        IF (l_rj_rowcount > 0 ) THEN
            x_err_msg := 'WSMPUTIL.check_wsmti('||l_stmt_num||') : Returning error - Unprocessed earlier WRJI Txn';
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN l_rj_rowcount;
        END IF;

    ELSIF (p_wip_entity_name IS NOT NULL) THEN

        l_sj_rowcount := 0;
        l_rj_rowcount := 0;

        l_stmt_num := 50;


        Begin

            SELECT  1
            INTO    l_sj_rowcount
        FROM    dual
        WHERE exists (select 'Unprocessed WSJI/WSMTI Record exists'
                    FROM    WSM_STARTING_JOBS_INTERFACE WSJI,
                            WSM_SPLIT_MERGE_TXN_INTERFACE WSMTI
                    WHERE   WSJI.wip_entity_name = p_wip_entity_name
                AND WSMTI.organization_id = p_organization_id
                    AND     WSMTI.header_id = WSJI.header_id
                    AND     WSMTI.process_status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
                    AND     WSMTI.transaction_date <= nvl(p_transaction_date,SYSDATE)
                );

        EXCEPTION
            WHEN NO_DATA_FOUND THEN -- No UNPROCESSED Txns exist
                NULL;
        End;

        IF (l_sj_rowcount > 0 ) THEN
            x_err_msg := 'WSMPUTIL.check_wsmti('||l_stmt_num||') : Returning error - Unprocessed earlier WSJI Txn';
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN l_sj_rowcount;

        END IF;

        l_stmt_num := 60;

        Begin

            SELECT  1
            INTO    l_rj_rowcount
        FROM    dual
        WHERE exists (select 'Unprocessed WRJI/WSMTI Record exists'
                    FROM    WSM_RESULTING_JOBS_INTERFACE WRJI,
                            WSM_SPLIT_MERGE_TXN_INTERFACE WSMTI
                    WHERE   WRJI.wip_entity_name = p_wip_entity_name
                AND WSMTI.organization_id = p_organization_id
                    AND     WSMTI.header_id = WRJI.header_id
                    AND     WSMTI.process_status IN (WIP_CONSTANTS.PENDING,
                                        WIP_CONSTANTS.RUNNING,
                                        WIP_CONSTANTS.ERROR)
                    AND     WSMTI.transaction_date <= nvl(p_transaction_date,SYSDATE)
                );

        EXCEPTION
            WHEN NO_DATA_FOUND THEN -- No UNPROCESSED Txns exist
                NULL;
        End;

        IF (l_rj_rowcount > 0 ) THEN
            x_err_msg := 'WSMPUTIL.check_wsmti('||l_stmt_num||') : Returning error - Unprocessed earlier WRJI Txn';
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            RETURN l_rj_rowcount;
        END IF;

    END IF;

    x_err_code := 0;
    x_err_msg := 'WSMPUTIL.CHECK_WSMTI:Returned Success - No Unprocessed WSMTI Txns for this lot';
    IF (l_debug = 'Y') THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
    END IF;

***************************************************************/

    RETURN 0;

EXCEPTION

        WHEN OTHERS THEN
            x_err_code := SQLCODE;
            x_err_msg := 'WSMPUTIL.CHECK_WSMTI' ||'(stmt_num='||l_stmt_num||') : '||substrb(sqlerrm, 1,1000);
            FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
            return 1; -- return a nonzerovalue.

END CHECK_WSMTI;

/***************************************************************************************/

--------------------------------------------------------------------
-- New Procedures/Functions added for DMF_PF.J or 11.5.10 ----------
--------------------------------------------------------------------
-- Import Network Routing Support through BOM Interface   ----------
--------------------------------------------------------------------
-- Bug#/Project: FP.J Import Network Rtg - 3088690
-- New/Overloaded: New
-- Release : 11.5.10.
-- Backward Compatible: YES
-- Modified by: Bala Balakumar.
--------------------------------------------------------------------
FUNCTION JOBS_WITH_QTY_AT_FROM_OP(
        x_err_code OUT NOCOPY NUMBER
        , x_err_msg     OUT NOCOPY varchar2
        , p_operation_sequence_id IN NUMBER
                )
RETURN BOOLEAN IS

    l_stmt_num NUMBER := 0;
    l_count NUMBER := 0;

Begin

    If fnd_profile.value('WSM_CREATE_LBJ_COPY_ROUTING') = WIP_CONSTANTS.YES Then

        Return FALSE;

    End If;


    l_stmt_num := 10;

    Select 1 into l_count
    From dual
    Where Exists ( Select 'Jobs with Qty At this Operation Exists'
        from    wip_discrete_jobs wdj
            , wip_operations wo
        Where   wdj.wip_entity_id = wo.wip_entity_id
        and NVL(wo.operation_sequence_id, -99999) =
            WSMPUTIL.replacement_op_seq_id (p_operation_sequence_id
                    , wdj.routing_revision_date)
        and wdj.status_type = WIP_CONSTANTS.RELEASED
        and     (
            wo.quantity_in_queue <> 0
            OR wo.quantity_running <> 0
            OR wo.quantity_waiting_to_move <> 0
            ));

    If l_count <> 0 Then
        RETURN TRUE;
    Else
        RETURN FALSE;
    End If;

EXCEPTION
        WHEN NO_DATA_FOUND Then
            return FALSE;

        -- WHEN OTHERS Exception should not be here.
        -- This should be handled by the calling program.

END JOBS_WITH_QTY_AT_FROM_OP;


--------------------------------------------------------------------
-- Bug#/Project: FP.J Import Network Rtg - 3088690
-- New/Overloaded: New and Overloaded
-- Release : 11.5.10.
-- Backward Compatible: YES
-- Modified by: Bala Balakumar.
--------------------------------------------------------------------
FUNCTION JOBS_WITH_QTY_AT_FROM_OP(
                x_err_code OUT NOCOPY NUMBER
                , x_err_msg     OUT NOCOPY varchar2
                , p_routing_sequence_id IN NUMBER
                , p_operation_seq_num IN NUMBER
                )
RETURN BOOLEAN IS

    l_stmt_num NUMBER := 0;
    l_count NUMBER := 0;

Begin

    If fnd_profile.value('WSM_CREATE_LBJ_COPY_ROUTING') = WIP_CONSTANTS.YES Then

        Return FALSE;

    End If;

    l_stmt_num := 10;

    Select 1 into l_count
    From dual
    Where Exists (
        Select 'Jobs with Qty At this Operation Exists'
        from    bom_operation_sequences bos
                , wip_discrete_jobs wdj
                , wip_operations wo
        Where   wdj.common_routing_sequence_id = p_routing_sequence_id
        and     wdj.status_type = WIP_CONSTANTS.RELEASED
        and     bos.routing_sequence_id = wdj.common_routing_sequence_id
        and     bos.operation_seq_num = p_operation_seq_num
        and     wdj.routing_revision_date between
                bos.effectivity_date and
                NVL(bos.disable_date, (wdj.routing_revision_date+1))
        and     wo.wip_entity_id = wdj.wip_entity_id
        and     wo.operation_sequence_id = bos.operation_sequence_id
        and     (wo.quantity_in_queue <> 0
                 OR wo.quantity_running <> 0
                 OR wo.quantity_waiting_to_move <> 0
                ));

    If l_count <> 0 Then
        RETURN TRUE;
    Else
        RETURN FALSE;
    End If;

    EXCEPTION
        WHEN NO_DATA_FOUND Then
            return FALSE;

        -- WHEN OTHERS Exception should not be here.
        -- This should be handled by the calling program.


END JOBS_WITH_QTY_AT_FROM_OP;

--------------------------------------------------------------------
-- Bug#/Project: FP.J OSFM/APS P2 Integration
-- New/Overloaded: New
-- Release : 11.5.10.
-- Backward Compatible: YES
-- Modified by: Bala Balakumar.
--------------------------------------------------------------------
FUNCTION CREATE_LBJ_COPY_RTG_PROFILE
RETURN NUMBER IS

    l_mfg_org_id varchar2(20);
    l_return_value NUMBER := WIP_CONSTANTS.NO;

BEGIN

    /****************** I M P O R T A N T ********************************/
    -- YOU SHOULD UNCOMMENT THE NEXT LINE AFTER FP.J UT/ST ---------------
     return to_number(fnd_profile.value('WSM_CREATE_LBJ_COPY_ROUTING'));
    ----------------------------------------------------------------------

    /****************** I M P O R T A N T ********************************/
    /***** Following code should be commented out after UT/ST for FP.J ***
    ----------------------------------------------------------------------

    l_mfg_org_id := fnd_profile.value_specific(
                    NAME => 'MFG_ORGANIZATION_ID'
                    , USER_ID => FND_GLOBAL.user_id);


    FND_FILE.PUT_LINE(FND_FILE.LOG,
            ('User value is  '|| to_char(FND_GLOBAL.user_id)
                        ||', Org Id is '|| l_mfg_org_id)
                        );

    Select  to_number(plan_code) into l_return_value
    from    wsm_parameters
    where   organization_id = to_number(l_mfg_org_id);

    If l_return_value IN (WIP_CONSTANTS.YES, WIP_CONSTANTS.NO) Then
        return l_return_value;
    Else
        return WIP_CONSTANTS.NO;
    End If;

    Exception
        When Others Then
            return WIP_CONSTANTS.NO;

    ----------------------------------------------------------------------
    ************** UPTO HERE, THE CODE SHOULD BE COMMENTED OUT **********/
    ----------------------------------------------------------------------

END CREATE_LBJ_COPY_RTG_PROFILE;


--------------------------------------------------------------------
-- Bug#/Project: FP.J OSFM/APS P2 Integration
-- New/Overloaded: New and OVERLOADED
-- Release : 11.5.10.
-- Backward Compatible: YES
-- Modified by: Bala Balakumar.
--------------------------------------------------------------------
FUNCTION CREATE_LBJ_COPY_RTG_PROFILE
    (p_organization_id IN NUMBER)
RETURN NUMBER IS

    l_return_value NUMBER := WIP_CONSTANTS.NO;
    l_plan_code VARCHAR2(30);

BEGIN

    -- Following is the strategy to be implemented in UT/ST/Cert/later for FP-J
    IF (WSMPUTIL.REFER_SITE_LEVEL_PROFILE = 'Y') THEN
        l_return_value := CREATE_LBJ_COPY_RTG_PROFILE;
    ELSE -- Refer to the org level setting
        select plan_code
        into   l_plan_code
        from   wsm_parameters
        where  organization_id = p_organization_id;

        IF (l_plan_code IS NULL) THEN -- retain the site level setting
            l_return_value := CREATE_LBJ_COPY_RTG_PROFILE;
      ELSE -- get the org-level setting
        l_return_value := to_number(l_plan_code);
      END IF;
    END IF;
    return l_return_value;

EXCEPTION
        WHEN OTHERS THEN
            return WIP_CONSTANTS.NO;

    /****************** I M P O R T A N T ********************************/
    -- YOU SHOULD UNCOMMENT THE NEXT LINE AFTER FP.J UT/ST ---------------
    -- return to_number(fnd_profile.value('WSM_CREATE_LBJ_COPY_ROUTING'));
    ----------------------------------------------------------------------

    /****************** I M P O R T A N T ********************************/
    /***** Following code should be commented out after UT/ST for FP.J ***
    ----------------------------------------------------------------------

    Select to_number(plan_code) into l_return_value
    from wsm_parameters
    where organization_id = p_organization_id;

    If l_return_value IN (WIP_CONSTANTS.YES, WIP_CONSTANTS.NO) Then
        return l_return_value;
    Else
        return WIP_CONSTANTS.NO;
    End If;

    Exception
        When Others Then
            return WIP_CONSTANTS.NO;

    ----------------------------------------------------------------------
    ************** UPTO HERE, THE CODE SHOULD BE COMMENTED OUT ************/
    ----------------------------------------------------------------------

END CREATE_LBJ_COPY_RTG_PROFILE;


--------------------------------------------------------------------
-- Bug#/Project: FP.J - Accounting Period consistent API
-- New or Overloaded: New
-- Release : 11.5.10.
-- Backward Compatible: YES
-- Modified by: Bala Balakumar.
-- RETURN value of 0 indicates the date is in a non-open period.
-- Exceptions should be handled by the calling programs.
--------------------------------------------------------------------
FUNCTION GET_INV_ACCT_PERIOD(
        x_err_code          OUT NOCOPY NUMBER,
        x_err_msg           OUT NOCOPY varchar2,
        p_organization_id   IN NUMBER,
        p_date              IN DATE) RETURN NUMBER IS

l_acct_period_id NUMBER := 0;
l_open_past_period BOOLEAN := FALSE;

BEGIN

    x_err_code := 0;

    /* ST : Bug 3205363 Commented the following for LE Timezone change.*/

    /*SELECT acct_period_id
    INTO   l_acct_period_id
    FROM   org_acct_periods
    WHERE  organization_id = p_organization_id
    AND    trunc(nvl(p_date, sysdate))
                between PERIOD_START_DATE and SCHEDULE_CLOSE_DATE
    AND    period_close_date is NULL
    AND    OPEN_FLAG = 'Y';*/

    /* ST : Bug 3205363 LE Timezone change Start */

    /* Henceforth call to be made to the tdacheck API to get the accounting period id */

    INVTTMTX.tdatechk(org_id           => p_organization_id,
                      transaction_date => p_date,
                      period_id        => l_acct_period_id,
                      open_past_period => l_open_past_period);

    /* open_past_period : FALSE because the check is only for the transaction date to be in an open period.
       and not to check if it is in the current ( most recent ) open period */

    if(l_acct_period_id = 0) or (l_acct_period_id = -1) then
        /*-------------------------------------------------------------+
        | 0  : No data found.                                          |
        | -1 : some  exception occured in the called API    ...........|
        +-------------------------------------------------------------*/
        fnd_message.set_name('WSM', 'WSM_ACCT_PERIOD_NOT_OPEN');
        x_err_code := -1;
        x_err_msg := FND_MESSAGE.GET;
        IF (l_debug = 'Y') THEN -- bug 3373637
            fnd_file.put_line(fnd_file.log, 'WSMPUTIL.GET_INV_ACCT_PERIOD: '||x_err_msg
                    || ' (organization_id = ' || p_organization_id || ')');
        END IF;
        l_acct_period_id := 0;
    end if;

    /* ST : Bug 3205363 LE Timezone change End */

    Return l_acct_period_id;

EXCEPTION

   /* ST : Bug 3205363 Commented the following for LE Time zone change */
   /*WHEN NO_DATA_FOUND then
        x_err_code := -1;
        fnd_message.set_name('WSM', 'WSM_ACCT_PERIOD_NOT_OPEN');
        x_err_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, 'WSMPUTIL.GET_INV_ACCT_PERIOD: '||x_err_msg);
        l_acct_period_id := 0; -- Date passed is in a NON-OPEN Period.
        Return l_acct_period_id;*/

    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPUTIL.GET_INV_ACCT_PERIOD: ' || substrb(sqlerrm, 1,1000);
        FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
        l_acct_period_id := 0; -- Date passed is in a NON-OPEN Period.
        Return l_acct_period_id;
END GET_INV_ACCT_PERIOD;

--------------------------------------------------------------------

PROCEDURE AUTONOMOUS_WRITE_TO_WIE (
                p_header_id                 IN  NUMBER,
                p_message                   IN  VARCHAR2,
                p_request_id                IN  NUMBER,
                p_program_id                IN  NUMBER,
                p_program_application_id    IN  NUMBER,
                p_message_type              IN  NUMBER,
                x_err_code                  OUT NOCOPY NUMBER,
                x_err_msg                   OUT NOCOPY VARCHAR2)
IS
    PRAGMA autonomous_transaction;

    x_user NUMBER := FND_GLOBAL.user_id;
    x_login NUMBER := FND_GLOBAL.login_id;


BEGIN

    INSERT INTO WSM_INTERFACE_ERRORS (
             HEADER_ID,
             MESSAGE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             REQUEST_ID,
             PROGRAM_ID,
             PROGRAM_APPLICATION_ID,
             MESSAGE_TYPE    )
    values (
            p_header_id,
            p_message,
            SYSDATE,
            x_user,
            SYSDATE,
            x_user,
            x_login,
            p_request_id,
            p_program_id,
            p_program_application_id,
            p_message_type );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := substrb(sqlerrm,1,2000);
        rollback;

END AUTONOMOUS_WRITE_TO_WIE;


-- get bom_sequence_id for a given wip_entity_id
FUNCTION GET_JOB_BOM_SEQ_ID(
        p_wip_entity_id     in number
) RETURN NUMBER IS

l_common_bom_seq_id NUMBER := 0;
l_bom_seq_id        NUMBER := 0;
l_bom_item_id       NUMBER;
l_alt_bom           VARCHAR2(10);
l_org_id            NUMBER;

BEGIN
    SELECT  wdj.common_bom_sequence_id,
            decode(wdj.job_type, 1, wdj.primary_item_id, wdj.bom_reference_id),
            wdj.alternate_bom_designator,
            wdj.organization_id
    INTO    l_common_bom_seq_id,
            l_bom_item_id,
            l_alt_bom,
            l_org_id
    FROM    wip_discrete_jobs wdj
    WHERE   wdj.wip_entity_id = p_wip_entity_id;

    --if(l_common_bom_seq_id IS NULL) then                              -- bug 3453830
    if(l_common_bom_seq_id IS NULL or l_common_bom_seq_id = 0) then     -- bug 3453830
        return null;
    else
        SELECT  bbom.bill_sequence_id
        INTO    l_bom_seq_id
        FROM    bom_bill_of_materials bbom
        WHERE   bbom.common_bill_sequence_id = l_common_bom_seq_id
        AND     bbom.organization_id = l_org_id
        AND     bbom.assembly_item_id = l_bom_item_id
        AND     nvl(bbom.alternate_bom_designator, '-@#$%') = nvl(l_alt_bom, '-@#$%');
    end if;

    return l_bom_seq_id;

EXCEPTION

    WHEN OTHERS THEN
        return -1;

END GET_JOB_BOM_SEQ_ID;


-- Start : Added to fix bug 3452913 --
FUNCTION replacement_copy_op_seq_id (
                p_job_op_seq_id   NUMBER,
                p_wip_entity_id   NUMBER
                ) RETURN INTEGER
IS
    l_copy_op_seq_id NUMBER := NULL;
BEGIN

    SELECT  distinct(wco.operation_sequence_id) -- Added distinct to fix bug #3507878
    INTO    l_copy_op_seq_id
    FROM    wsm_copy_operations wco,
            wip_operations wo
    WHERE   wo.operation_sequence_id = p_job_op_seq_id
    AND     wo.wip_entity_id = p_wip_entity_id
    AND     wo.wip_entity_id = wco.wip_entity_id
    AND     wo.wsm_op_seq_num = wco.operation_seq_num;

    return l_copy_op_seq_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        return NULL;

    WHEN OTHERS THEN
        return NULL;
END replacement_copy_op_seq_id;
-- End : Added to fix bug 3452913 --


-- BA bug 3512105
-- will return WLBJ.internal_copy_type, return -3 if not available
FUNCTION get_internal_copy_type (
         p_wip_entity_id   NUMBER
) RETURN INTEGER
IS
l_int_copy_type NUMBER;
BEGIN

    SELECT INTERNAL_COPY_TYPE
    INTO   l_int_copy_type
    FROM   wsm_lot_based_jobs
    WHERE  wip_entity_id = p_wip_entity_id;
    return l_int_copy_type;

EXCEPTION
    when others then
        return 3;
END;

-- EA bug 3512105

--bug 3754881 procedure for locking wdj to be called from the Move and WLT Forms
PROCEDURE lock_wdj(
      x_err_code                OUT NOCOPY NUMBER
    , x_err_msg                 OUT NOCOPY VARCHAR2
    , p_wip_entity_id           IN NUMBER
    , p_rollback_flag           IN NUMBER)
IS
    row_locked          EXCEPTION;
    PRAGMA EXCEPTION_INIT(row_locked, -54);
    l_dummy             NUMBER;
BEGIN
    IF p_rollback_flag = 1 THEN
        ROLLBACK TO LOCK_WDJ;
    END IF;

    SAVEPOINT LOCK_WDJ;

    SELECT  1
    INTO    l_dummy
    FROM    wip_discrete_jobs
    WHERE   wip_entity_id = p_wip_entity_id
    FOR UPDATE NOWAIT;

    -- bug 4932475 (base bug 4759095): Create a savepoint after locking wdj. We will rollback to this savepoint
    -- in rollback_before_add_operation so that the lock on the job is retained.
    SAVEPOINT AFTER_LOCK_WDJ;

    x_err_code := 0;

EXCEPTION
    WHEN row_locked THEN
         x_err_code := 1;

    WHEN others THEN
        x_err_code  := SQLCODE;
        x_err_msg   := substr('WSMPUTIL.LOCK_WDJ: ' || SQLERRM, 1, 4000);
END lock_wdj;
--end bug 3754881
--Bug 5182520:Added the following procedure to handle material status checks.
Function is_status_applicable(p_wms_installed           IN VARCHAR2,
                           p_trx_status_enabled         IN NUMBER,
                           p_trx_type_id                IN NUMBER,
                           p_lot_status_enabled         IN VARCHAR2,
                           p_serial_status_enabled      IN VARCHAR2,
                           p_organization_id            IN NUMBER,
                           p_inventory_item_id          IN NUMBER,
                           p_sub_code                   IN VARCHAR2,
                           p_locator_id                 IN NUMBER,
                           p_lot_number                 IN VARCHAR2,
                           p_serial_number              IN VARCHAR2,
			   x_error_msg                  OUT NOCOPY VARCHAR2
                           )
return varchar2 is
  l_status_applicable VARCHAR2(1) := 'Y';
  l_item              MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
  l_locator           MTL_ITEM_LOCATIONS_KFV.CONCATENATED_SEGMENTS%TYPE;
BEGIN
  IF (p_inventory_item_id IS NOT NULL and p_sub_code IS NOT NULL) THEN
      l_status_applicable := INV_MATERIAL_STATUS_GRP.is_status_applicable(p_wms_installed         => p_wms_installed,
                                                   p_trx_status_enabled    => p_trx_status_enabled   ,
                                                   p_trx_type_id           => p_trx_type_id          ,
                                                   p_lot_status_enabled    => p_lot_status_enabled   ,
                                                   p_serial_status_enabled => p_serial_status_enabled,
                                                   p_organization_id       => p_organization_id      ,
                                                   p_inventory_item_id     => p_inventory_item_id    ,
                                                   p_sub_code              => p_sub_code             ,
                                                   p_locator_id            => p_locator_id           ,
                                                   p_lot_number            => p_lot_number           ,
                                                   p_serial_number         => p_serial_number        ,
						   p_object_type           =>'Z');

   END IF; --End of p_inventory_item_id IS NOT NULL and p_sub_code IS NOT NULL

   IF l_status_applicable = 'N' THEN
      FND_MESSAGE.SET_NAME('WSM','WSM_TRX_SUBINV_NA_DUE_MS');
      FND_MESSAGE.SET_TOKEN('TOKEN1', p_sub_code);
      x_error_msg := fnd_message.get;

      return l_status_applicable;
   END IF;

   IF (p_locator_id IS NOT NULL) THEN
      l_status_applicable := INV_MATERIAL_STATUS_GRP.is_status_applicable(p_wms_installed         => p_wms_installed,
                                                   p_trx_status_enabled    => p_trx_status_enabled   ,
                                                   p_trx_type_id           => p_trx_type_id          ,
                                                   p_lot_status_enabled    => p_lot_status_enabled   ,
                                                   p_serial_status_enabled => p_serial_status_enabled,
                                                   p_organization_id       => p_organization_id      ,
                                                   p_inventory_item_id     => p_inventory_item_id    ,
                                                   p_sub_code              => p_sub_code             ,
                                                   p_locator_id            => p_locator_id           ,
                                                   p_lot_number            => p_lot_number           ,
                                                   p_serial_number         => p_serial_number        ,
						   p_object_type           =>'L');
   END IF; --End of  p_locator_id IS NOT NULL

   IF l_status_applicable = 'N' THEN
      select concatenated_segments
      into   l_locator
      from   mtl_item_locations_kfv
      where  inventory_location_id = p_locator_id
      and    organization_id = p_organization_id;

      FND_MESSAGE.SET_NAME('INV','INV_TRX_LOCATOR_NA_DUE_MS');
      FND_MESSAGE.SET_TOKEN('TOKEN1', l_locator);
      x_error_msg := fnd_message.get;
      return l_status_applicable;
   END IF;

   IF (p_lot_number IS NOT NULL) THEN
      l_status_applicable := INV_MATERIAL_STATUS_GRP.is_status_applicable(p_wms_installed         => p_wms_installed,
                                                   p_trx_status_enabled    => p_trx_status_enabled   ,
                                                   p_trx_type_id           => p_trx_type_id          ,
                                                   p_lot_status_enabled    => p_lot_status_enabled   ,
                                                   p_serial_status_enabled => p_serial_status_enabled,
                                                   p_organization_id       => p_organization_id      ,
                                                   p_inventory_item_id     => p_inventory_item_id    ,
                                                   p_sub_code              => p_sub_code             ,
                                                   p_locator_id            => p_locator_id           ,
                                                   p_lot_number            => p_lot_number           ,
                                                   p_serial_number         => p_serial_number        ,
						   p_object_type           =>'O');
   END IF; --End of  p_lot_number IS NOT NULL

   IF l_status_applicable = 'N' THEN
      select concatenated_segments
      into   l_item
      from   mtl_system_items_kfv
      where  inventory_item_id = p_inventory_item_id
      and    organization_id = p_organization_id;

      FND_MESSAGE.SET_NAME('INV','INV_TRX_LOT_NA_DUE_MS');
      FND_MESSAGE.SET_TOKEN('TOKEN1', p_lot_number);
      FND_MESSAGE.SET_TOKEN('TOKEN2', l_item);
      x_error_msg := fnd_message.get;
      return l_status_applicable;
   END IF;

   IF (p_serial_number IS NOT NULL) THEN
      l_status_applicable := INV_MATERIAL_STATUS_GRP.is_status_applicable(p_wms_installed         => p_wms_installed,
                                                   p_trx_status_enabled    => p_trx_status_enabled   ,
                                                   p_trx_type_id           => p_trx_type_id          ,
                                                   p_lot_status_enabled    => p_lot_status_enabled   ,
                                                   p_serial_status_enabled => p_serial_status_enabled,
                                                   p_organization_id       => p_organization_id      ,
                                                   p_inventory_item_id     => p_inventory_item_id    ,
                                                   p_sub_code              => p_sub_code             ,
                                                   p_locator_id            => p_locator_id           ,
                                                   p_lot_number            => p_lot_number           ,
                                                   p_serial_number         => p_serial_number        ,
						   p_object_type           =>'S');
   END IF; --End of  p_lot_number IS NOT NULL

   IF l_status_applicable = 'N' THEN
      select concatenated_segments
      into   l_item
      from   mtl_system_items_kfv
      where  inventory_item_id = p_inventory_item_id
      and    organization_id = p_organization_id;

      FND_MESSAGE.SET_NAME('INV','INV_TRX_SER_NA_DUE_MS');
      FND_MESSAGE.SET_TOKEN('TOKEN1', p_serial_number);
      FND_MESSAGE.SET_TOKEN('TOKEN2', l_item);
      x_error_msg := fnd_message.get;
   END IF;

   return l_status_applicable;

END is_status_applicable;

-- This Function is added to support Add operations/links in LBJ Interface.
   FUNCTION validate_job_network(
            p_wip_entity_id NUMBER,
            x_err_code OUT NOCOPY NUMBER,
            x_err_msg OUT NOCOPY VARCHAR2)
   RETURN NUMBER IS

       type network_links IS record (
               operation         wsm_copy_op_networks.from_op_seq_num%type,
               prev_op           wsm_copy_op_networks.from_op_seq_num%type,
               prev_op_rec_flag  wsm_copy_op_networks.recommended%type,
               next_op           wsm_copy_op_networks.to_op_seq_num%type,
               next_op_rec_flag  wsm_copy_op_networks.recommended%type);

       type t_network_links is table of network_links index by binary_integer;
       v_network_links t_network_links;

       type t_primary_path is table of number index by binary_integer;
       v_primary_path  t_primary_path;

       cursor c_job_network is
       SELECT CASE
       WHEN a.op_seq IS NULL THEN
         b.op_seq
       ELSE
         a.op_seq
       END operation,
         b.prev_seq prev_op,
         b.prev_op_reco,
         a.next_op next_op,
         a.next_op_reco
       FROM
         (SELECT from_op_seq_num op_seq,
            to_op_seq_num next_op,
            recommended next_op_reco
          FROM wsm_copy_op_networks
          WHERE wip_entity_id = p_wip_entity_id) a
         FULL OUTER JOIN
         (SELECT to_op_seq_num op_seq,
            from_op_seq_num prev_seq,
            recommended prev_op_reco
          FROM wsm_copy_op_networks
          WHERE wip_entity_id = p_wip_entity_id) b
         ON a.op_seq = b.op_seq
       ORDER BY 1,4;

       l_counter number;
       l_start_op number;
       l_end_op number;
       l_nw_start number;
       l_nw_end number;
       l_prev_op number;
       l_next_op_link number;
       l_next_link_op number;
       l_reco_count number :=0;
       l_link_count number :=1;
       l_stmt_num   number;

       e_multiple_start_op     exception;
       e_multiple_end_op       exception;
       e_multiple_primary_path exception;
       e_network_loop          exception;
       e_no_continuous_path    exception;

   BEGIN

   l_stmt_num := 10;
       begin
           select operation_seq_num
           into l_nw_start
           from wsm_copy_operations
           where wip_entity_id = p_wip_entity_id
           and network_start_end = 'S';
       exception
           when others then
               raise e_multiple_start_op;
       end;
   l_stmt_num := 20;
       begin
           select operation_seq_num
           into l_nw_end
           from wsm_copy_operations
           where wip_entity_id = p_wip_entity_id
           and network_start_end = 'E';
       exception
           when others then
               raise e_multiple_end_op;
       end;
   l_stmt_num := 30;
       open c_job_network;
       fetch c_job_network bulk collect into v_network_links;
       close c_job_network;
   l_stmt_num := 40;
       l_counter := v_network_links.first;
       while l_counter is not null loop

           -- Validate if the network has unique start operation.
           if v_network_links(l_counter).prev_op is null then
               if v_network_links(l_counter).operation <> nvl(l_start_op,v_network_links(l_counter).operation) then
                   raise e_multiple_start_op;
               end if;
               l_start_op := v_network_links(l_counter).operation;
           end if;
   l_stmt_num := 50;
           -- Validate if the network has unique end operation.
           if v_network_links(l_counter).next_op is null then
               if v_network_links(l_counter).operation <> nvl(l_end_op,v_network_links(l_counter).operation) then
                   raise e_multiple_end_op;
               end if;
               l_end_op := v_network_links(l_counter).operation;
           end if;
   l_stmt_num := 60;
           -- Validate if the network has unique primary path.
           if v_network_links(l_counter).operation = l_prev_op then
               if (v_network_links(l_counter).next_op_rec_flag='Y' and l_reco_count=1) then
                   if l_next_op_link <> v_network_links(l_counter).next_op then
                       raise e_multiple_primary_path;
                   end if;
               elsif v_network_links(l_counter).next_op_rec_flag='Y' then
                   l_reco_count :=1;
                   l_next_op_link := v_network_links(l_counter).next_op;
               end if;
           else
               l_prev_op := v_network_links(l_counter).operation;
               l_reco_count :=0;
               if v_network_links(l_counter).next_op_rec_flag='Y' then
                   l_reco_count :=1;
                   l_next_op_link := v_network_links(l_counter).next_op;
               end if;
           end if;
   l_stmt_num := 70;
           -- Validate if start operation has any previous operations.
           if v_network_links(l_counter).operation = l_nw_start and
              v_network_links(l_counter).prev_op is not null then
               raise e_network_loop;
           end if;
   l_stmt_num := 80;
           -- Validate if end operation has any next operations.
           if v_network_links(l_counter).operation = l_nw_end and
              v_network_links(l_counter).next_op is not null then
               raise e_network_loop;
           end if;
   l_stmt_num := 90;
           -- Validate for loop in primary path as well as build the primary path.
           if (not v_primary_path.exists(v_network_links(l_counter).operation)) then
               if nvl(v_network_links(l_counter).next_op_rec_flag,'Y')='Y' then
                   v_primary_path(v_network_links(l_counter).operation) := v_network_links(l_counter).next_op;
                   l_next_link_op := v_network_links(l_counter).next_op;
               end if;
           else
               if v_network_links(l_counter).next_op_rec_flag='Y' then
                   if nvl(l_next_link_op,v_network_links(l_counter).next_op) <> v_network_links(l_counter).next_op then
                       raise e_network_loop;
                   end if;
               end if;
           end if;
           l_counter := v_network_links.next(l_counter);
       end loop;
   l_stmt_num := 100;
       if l_start_op <> l_nw_start then
           raise e_multiple_start_op;
       end if;

       if l_end_op <> l_nw_end then
           raise e_multiple_end_op;
       end if;
   l_stmt_num := 110;
       --Validate if primary path is continuous.
       l_counter := l_start_op;
       loop
           l_link_count := l_link_count+1;
           if (not v_primary_path.exists(l_counter)) then
               raise e_no_continuous_path;
           else
               l_counter := v_primary_path(l_counter);
               if v_primary_path(l_counter) is null then
                   if l_link_count <> v_primary_path.count  then
                       raise e_no_continuous_path;
                   end if;
                   exit;
               end if;
           end if;
       end loop;
   l_stmt_num := 120;
       x_err_code :=0;
       x_err_msg := null;
       return 0;

   EXCEPTION

       when e_multiple_start_op then
           x_err_code := -1;
           fnd_message.set_name('WSM','WSM_MULT_PRIMARY_STARTS');
           x_err_msg := 'Error: validate_job_network: (#'||l_stmt_num||') ' ||fnd_message.get;
           return 1;

       when e_multiple_end_op then
           x_err_code := -1;
           fnd_message.set_name('WSM','WSM_MULT_PRIMARY_ENDS');
           x_err_msg := 'Error: validate_job_network: (#'||l_stmt_num||') ' ||fnd_message.get;
           return 1;

       when e_multiple_primary_path then
           x_err_code := -1;
           fnd_message.set_name('WSM','WSM_MULT_PRIMARY_PATHS');
           x_err_msg := 'Error: validate_job_network: (#'||l_stmt_num||') ' ||fnd_message.get;
           return 1;

      when e_network_loop then
          x_err_code := -1;
          fnd_message.set_name('WSM','WSM_NTWK_LOOP_EXISTS');
          x_err_msg := 'Error: validate_job_network: (#'||l_stmt_num||') ' ||fnd_message.get;
          return 1;

      when e_no_continuous_path then
          x_err_code := -1;
          fnd_message.set_name('WSM','WSM_PRIMARY_PATH_END_IMPROPER');
          fnd_message.set_token('WSM_SEQ_NUM',l_counter);
          x_err_msg := 'Error: validate_job_network: (#'||l_stmt_num||') ' ||fnd_message.get;
          return 1;

      when others then
          x_err_code := -1;
          x_err_msg := 'Error: validate_job_network: (#'||l_stmt_num||') ' ||sqlerrm(sqlcode);
          return 1;

   END validate_job_network;



END WSMPUTIL;

/
