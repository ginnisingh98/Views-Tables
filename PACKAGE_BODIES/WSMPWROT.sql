--------------------------------------------------------
--  DDL for Package Body WSMPWROT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPWROT" as
/* $Header: WSMWROTB.pls 120.4.12010000.2 2008/11/27 12:32:34 lmente ship $ */


/* ===========================================================================

  PROCEDURE NAME:       populate_wro

=========================================================================== */
PROCEDURE POPULATE_WRO (
                p_first_flag IN NUMBER,
                p_wip_entity_id IN NUMBER,
                p_organization_id IN NUMBER,
                p_assembly_item_id IN NUMBER,
                p_bom_revision_date IN DATE,
                p_alt_bom IN VARCHAR2,
                p_quantity IN NUMBER,
                p_operation_sequence_id IN NUMBER,      -- BA: NSO-WLT
                p_charges_exist IN NUMBER DEFAULT NULL, -- DEF ENH 0,-- EA: NSO-WLT
                x_err_code OUT NOCOPY NUMBER,
                x_err_msg  OUT NOCOPY VARCHAR2,
                p_routing_revision_date IN DATE DEFAULT NULL, -- DEF ENH SYSDATE,
                p_wip_supply_type IN NUMBER DEFAULT NULL ) -- DEF ENH 7)
IS
BEGIN
        POPULATE_WRO (
                p_first_flag,
                p_wip_entity_id,
                p_organization_id,
                p_assembly_item_id,
                p_bom_revision_date,
                p_alt_bom,
                p_quantity,
                p_operation_sequence_id,        -- BA: NSO-WLT
                p_charges_exist,        -- EA: NSO-WLT
                x_err_code,
                x_err_msg,
                p_routing_revision_date,
                p_wip_supply_type,
                NULL);

-- DEF ENH added exception block

EXCEPTION

        WHEN OTHERS THEN
                x_err_code := SQLCODE;
                x_err_msg := substr('WSMPWROT ('||'Overloaded Procedure'||')' || SQLERRM,1,2000);

END;

PROCEDURE POPULATE_WRO (
                p_first_flag IN NUMBER,
                p_wip_entity_id IN NUMBER,
                p_organization_id IN NUMBER,
                p_assembly_item_id IN NUMBER,
                p_bom_revision_date IN DATE,
                p_alt_bom IN VARCHAR2,
                p_quantity IN NUMBER,
                p_operation_sequence_id IN NUMBER,      -- BA: NSO-WLT
                p_charges_exist IN NUMBER DEFAULT NULL, -- DEF ENH 0,-- EA: NSO-WLT
                x_err_code OUT NOCOPY NUMBER,
                x_err_msg  OUT NOCOPY VARCHAR2,
                p_routing_revision_date IN DATE DEFAULT NULL, -- DEF ENH SYSDATE,
                p_wip_supply_type IN NUMBER DEFAULT NULL, -- DEF ENH 7,
                p_routing_sequence_id IN NUMBER )
IS
        x_routing_revision_date DATE ;  -- DEF ENH := p_routing_revision_date;

        x_default_sub           VARCHAR2(10);
        x_default_loc           NUMBER;
        x_bill_sequence_id      NUMBER;
        x_wdj_supply_type       NUMBER;
        x_org_id                NUMBER;
        x_user_id               NUMBER := FND_GLOBAL.USER_ID;
        x_login_id              NUMBER := FND_GLOBAL.login_id;
        x_operation_seq_num     NUMBER;
        x_max_resc_seq_num      NUMBER;

        l_error_msg             VARCHAR2(2000);
        l_error_code            NUMBER := 0;
        l                       NUMBER := 0;
        m                       NUMBER := 0;
        x_last_update_date      DATE;
        x_last_updated_by       NUMBER;
        x_creation_date         DATE;
        x_created_by            NUMBER;
        x_last_update_login     NUMBER;
        x_request_id            NUMBER;
        x_program_application_id NUMBER;
        x_program_id            NUMBER;
        x_program_update_date   DATE;

        l_stmt_num              NUMBER := 0;    -- BA: NSO-WLT
        l_op_seq_num_incr       NUMBER;         -- EA: NSO-WLT

        be_exploder_exception   EXCEPTION;
        my_exception            EXCEPTION;
        loop_in_bom_exception   EXCEPTION;
        x_max_bill_levels       NUMBER := 60;
        x_start_date            DATE;
        x_completion_date       DATE;
        x_uom_code              VARCHAR2(3);
        x_applied_resource_units NUMBER := 0;
        x_applied_resource_value NUMBER := 0;
        x_no_of_first_level_comp NUMBER := 0;
        x_comp_code             VARCHAR2(2000):= to_char(p_assembly_item_id);
        x_phan_qty              NUMBER := 1;
        NO_OF_COMP NUMBER := 0;
        i                       NUMBER:=0;
        x_explode_phantoms      BOOLEAN:=FALSE;
        x_routing_sequence_id   NUMBER;
        x_use_phantom_routings  NUMBER := 0;
        x_department_id         NUMBER;
        x_job_wip_supply_type   NUMBER ; -- DEF ENH := p_wip_supply_type;
        x_first_flag            NUMBER := p_first_flag;
        l_dummy                 NUMBER;
        DATETIME_FMT   CONSTANT VARCHAR2(22) := 'YYYY/MM/DD HH24:MI:SS';
	l_ato_phantom           VARCHAR2(1) := 'N'; -- bug 7598223

        cursor reqs is
        SELECT
                A.COMPONENT_SEQUENCE_ID,
                A.COMPONENT_ITEM_ID,
                O.OPERATION_SEQ_NUM,

                 decode (p_organization_id,     -- Supply locator id begin
                          x_org_id,

                        decode (A.SUPPLY_SUBINVENTORY, NULL,
                                decode ( C.WIP_SUPPLY_SUBINVENTORY, NULL,
                                        decode(nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),2,
                                                        nvl(x_default_loc,-1),3, nvl(x_default_loc,-1), NULL),
                                        C.WIP_SUPPLY_LOCATOR_ID),
                                A.SUPPLY_LOCATOR_ID ),

                        decode ( C.WIP_SUPPLY_SUBINVENTORY, NULL,
                                        decode(nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),2,
                                                        nvl(x_default_loc,-1),3, nvl(x_default_loc,-1), NULL),
                                        C.WIP_SUPPLY_LOCATOR_ID)

                       ) supply_locator_id,     -- Supply locator id end

                decode(x_job_wip_supply_type, 7, nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),
                       x_job_wip_supply_type) wip_supply_type,
                A.basis_type,   --LBM enh

                --R12-Component Shrinkage changes
                A.COMPONENT_QUANTITY QPA,
                A.COMPONENT_YIELD_FACTOR,
                --R12-Component Shrinkage changes

                decode (p_organization_id,
                          x_org_id,
                          nvl(A.SUPPLY_SUBINVENTORY, nvl(C.WIP_SUPPLY_SUBINVENTORY,
                                decode(nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),2,x_default_sub,
                                3,x_default_sub, NULL))),
                          nvl(C.WIP_SUPPLY_SUBINVENTORY,
                                decode(nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),2,x_default_sub,
                                3,x_default_sub, NULL)) ) supply_subinventory,

                a.component_remarks comments,
                a.attribute_category,
                a.attribute1,
                a.attribute2,
                a.attribute3,
                a.attribute4,
                a.attribute5,
                a.attribute6,
                a.attribute7,
                a.attribute8,
                a.attribute9,
                a.attribute10,
                a.attribute11,
                a.attribute12,
                a.attribute13,
                a.attribute14,
                a.attribute15,
                c.segment1,
                c.segment2,
                c.segment3,
                c.segment4,
                c.segment5,
                c.segment6,
                c.segment7,
                c.segment8,
                c.segment9,
                c.segment10,
                c.segment11,
                c.segment12,
                c.segment13,
                c.segment14,
                c.segment15,
                c.segment16,
                c.segment17,
                c.segment18,
                c.segment19,
                c.segment20,
                o.first_unit_start_date,
                o.department_id
        FROM
                WIP_OPERATIONS O,
                BOM_INVENTORY_COMPONENTS A,
                MTL_SYSTEM_ITEMS C,
                BOM_EXPLOSION_TEMP BE
        WHERE
                    BE.GROUP_ID=WSMPWROT.EXPLOSION_GROUP_ID
                AND BE.TOP_BILL_SEQUENCE_ID=x_bill_sequence_id
                AND A.COMPONENT_SEQUENCE_ID=BE.COMPONENT_SEQUENCE_ID
                AND BE.COMPONENT_ITEM_ID = C.INVENTORY_ITEM_ID
                AND O.wip_entity_id = p_wip_entity_id
                AND O.organization_id = p_organization_id
                AND O.operation_sequence_id = p_operation_sequence_id
                        -- bugfix 1661987: Replaced the earlier operation_seq_num condition with the following
                        -- so that records are inserted in WRO for the last operation also.
                AND O.operation_seq_num IN
                    (
                     SELECT max (o1.operation_seq_num)
                     from wip_operations o1
                     where
                        o1.wip_entity_id = p_wip_entity_id
                        and o1.operation_sequence_id = o.operation_sequence_id
                        and not exists (
                                        select 'x' from wip_requirement_operations r
                                        where
                                                r.wip_entity_id = p_wip_entity_id
                                                and r.organization_id = p_organization_id
                                                and ((r.OPERATION_SEQ_NUM = o1.operation_seq_num) or
                                                     (r.OPERATION_SEQ_NUM = -o1.operation_seq_num))
                                       )
                    )
                AND C.ORGANIZATION_ID = p_organization_id
                AND ((A.operation_seq_num  =
                         (SELECT BOS.operation_seq_num
                          FROM  BOM_OPERATION_SEQUENCES BOS
                          WHERE operation_sequence_id = p_operation_sequence_id))
                                OR (x_first_flag = 1 AND  A.OPERATION_SEQ_NUM =  1))
                AND A.EFFECTIVITY_DATE <=p_bom_revision_date
                AND nvl(A.DISABLE_DATE, p_bom_revision_date + 1) >= p_bom_revision_date  -- CHG: BUG2380517 from > to >=
                AND A.EFFECTIVITY_DATE =
                     (
                      SELECT MAX(EFFECTIVITY_DATE)
                      FROM   BOM_INVENTORY_COMPONENTS BIC,
                             ENG_REVISED_ITEMS ERI
                      WHERE  BIC.BILL_SEQUENCE_ID = A.BILL_SEQUENCE_ID
                             AND BIC.COMPONENT_ITEM_ID = A.COMPONENT_ITEM_ID
                             AND (decode(BIC.IMPLEMENTATION_DATE, NULL,
                                         BIC.OLD_COMPONENT_SEQUENCE_ID,
                                         BIC.COMPONENT_SEQUENCE_ID) =
                                  decode(A.IMPLEMENTATION_DATE, NULL,
                                          A.OLD_COMPONENT_SEQUENCE_ID,
                                          A.COMPONENT_SEQUENCE_ID)
                                  OR
                                  BIC.OPERATION_SEQ_NUM = A.OPERATION_SEQ_NUM)
                             AND  BIC.EFFECTIVITY_DATE <= p_bom_revision_date
                             AND  BIC.REVISED_ITEM_SEQUENCE_ID =
                                                ERI.REVISED_ITEM_SEQUENCE_ID(+)
                             AND  (nvl(ERI.STATUS_TYPE,6) IN (4,6,7))
                             AND  NOT EXISTS
                                        (SELECT  'X'
                                         FROM   BOM_INVENTORY_COMPONENTS BICN, ENG_REVISED_ITEMS ERI1
                                         WHERE      BICN.BILL_SEQUENCE_ID = A.BILL_SEQUENCE_ID
                                                AND BICN.OLD_COMPONENT_SEQUENCE_ID =
                                                                        A.COMPONENT_SEQUENCE_ID
                                                AND BICN.ACD_TYPE in (2,3)
                                                AND BICN.DISABLE_DATE <= p_bom_revision_date
                                                AND ERI1.REVISED_ITEM_SEQUENCE_ID = BICN.REVISED_ITEM_SEQUENCE_ID
                                                AND ( nvl(ERI1.STATUS_TYPE,6) IN (4,6,7) )
                                        )
                     )
                ORDER BY A.COMPONENT_ITEM_ID,
                         nvl(A.WIP_SUPPLY_TYPE, C.WIP_SUPPLY_TYPE),
                         TO_NUMBER(TO_CHAR(A.EFFECTIVITY_DATE,'SSSS'));

        TYPE table_comp_details is TABLE OF reqs%ROWTYPE
                INDEX by BINARY_INTEGER;
        t_comp_details table_comp_details;

BEGIN

l_stmt_num := 5;

    if (WSMPWROT.USE_PHANTOM_ROUTINGS IS NULL) then
        begin
                SELECT nvl(use_phantom_routings, 0)
                INTO WSMPWROT.USE_PHANTOM_ROUTINGS
                FROM BOM_PARAMETERS
                WHERE ORGANIZATION_ID = p_organization_id;
        exception
        when no_data_found then
                null;
        end;
    end if;

    x_use_phantom_routings := WSMPWROT.USE_PHANTOM_ROUTINGS;

l_stmt_num := 6;
    begin
            SELECT nvl(maximum_bom_level, 60)
            INTO x_max_bill_levels
            FROM BOM_PARAMETERS
            WHERE ORGANIZATION_ID = p_organization_id;
    exception
    when no_data_found then
            null;
    end;

    if ((p_routing_revision_date is NULL) and (p_wip_supply_type is null)) then
        SELECT  nvl(routing_revision_date, SYSDATE), nvl(wip_supply_type, 7)
        INTO    x_routing_revision_date, x_job_wip_supply_type
        FROM    wip_discrete_jobs
        WHERE   wip_entity_id=p_wip_entity_id;
    elsif (p_routing_revision_date is NULL) then
        SELECT  nvl(routing_revision_date, SYSDATE)
        INTO    x_routing_revision_date
        FROM    wip_discrete_jobs
        WHERE   wip_entity_id=p_wip_entity_id;

        x_job_wip_supply_type := p_wip_supply_type ;
    elsif (p_wip_supply_type is null) then
        SELECT  nvl(wip_supply_type, 7)
        INTO    x_job_wip_supply_type
        FROM    wip_discrete_jobs
        WHERE   wip_entity_id=p_wip_entity_id;

        x_routing_revision_date := p_routing_revision_date;
    else
        x_job_wip_supply_type := p_wip_supply_type ;
        x_routing_revision_date := p_routing_revision_date;
    end if;

l_stmt_num := 10;

    SELECT max(operation_seq_num)
    INTO x_operation_seq_num
    FROM WIP_OPERATIONS
    WHERE operation_sequence_id=p_operation_sequence_id
    and wip_entity_id = p_wip_entity_id;

l_stmt_num := 15;

    SELECT first_unit_start_date, last_unit_completion_date, department_id
    INTO x_start_date, x_completion_date, x_department_id
    FROM WIP_OPERATIONS
    WHERE wip_entity_id = p_wip_entity_id
    AND organization_id = p_organization_id
    AND operation_seq_num = x_operation_seq_num;

l_stmt_num := 20;

    SELECT default_pull_supply_subinv,
            default_pull_supply_locator_id
    INTO   x_default_sub,
       x_default_loc
    FROM   wip_parameters
    WHERE  organization_id = p_organization_id;

l_stmt_num := 30;

    if (p_charges_exist is NULL or p_charges_exist = 0   ) then
        l_op_seq_num_incr := 0;
    else
        SELECT nvl(op_seq_num_increment, 10)
        INTO   l_op_seq_num_incr
        FROM   wsm_parameters
        WHERE  organization_id = p_organization_id;
    end if;

    BEGIN
l_stmt_num := 40;

        SELECT B.BILL_SEQUENCE_ID, B.ORGANIZATION_ID
        INTO x_bill_sequence_id, x_org_id
        FROM BOM_BILL_OF_MATERIALS B
        WHERE B.ASSEMBLY_ITEM_ID = p_assembly_item_id
        AND   B.ORGANIZATION_ID  = p_organization_id
        AND   (
                (
                  (
                    nvl(B.ALTERNATE_BOM_DESIGNATOR, 'NONE') = nvl(p_alt_bom, 'NONE')
                    OR
                    (
                       B.ALTERNATE_BOM_DESIGNATOR IS NULL AND
                       NOT EXISTS
                       (
                         SELECT 'X' FROM BOM_BILL_OF_MATERIALS C
                         WHERE C.ASSEMBLY_ITEM_ID = p_assembly_item_id
                         AND   C.ORGANIZATION_ID = p_organization_id
                         AND   C.ALTERNATE_BOM_DESIGNATOR = p_alt_bom
                       )
                     )
                   )
                 )
               );

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               return;
     END;

l_stmt_num := 45;

    if (WSMPWROT.explosion_group_id is null) then
        x_explode_phantoms := TRUE;

        l_stmt_num := 46;

        SELECT BOM_EXPLOSION_TEMP_S.nextval INTO WSMPWROT.EXPLOSION_GROUP_ID
        FROM DUAL;
    end if;

    x_explode_phantoms:=TRUE;

    if (x_explode_phantoms=TRUE) then

l_stmt_num := 48;

/*      bompexpl.exploder_userexit(0, -- verify_flag
                           p_organization_id,
                           1, --order_by
                           WSMPWROT.EXPLOSION_GROUP_ID, -- grp_id
                           0, -- session_id
                           1, -- levels_to_explode
                           1, -- bom_or_eng
                           1, -- impl_flag
                           1, -- plan_factor_flag
                           2, --changed by skaradib for bug 2362939     -- explode_option
                           5, -- module
                           0, -- cst_type_id
                           0, -- std_comp_flag
                           1, -- expl_qty
                           p_assembly_item_id,
                           p_alt_bom,
                           '', -- comp_code
                           to_char(p_bom_revision_date, datetime_fmt), --datetime_fmt for bug 2393005 by skaradib
                           l_error_msg,
                           l_error_code);  */
-- Bug fix: 5377818 Used named convention for arguments

          bompexpl.exploder_userexit(
		            verify_flag      =>0,   -- verify_flag
					org_id           =>p_organization_id,
					order_by         =>1,        --order_by
					grp_id           =>WSMPWROT.EXPLOSION_GROUP_ID, -- grp_id
					session_id       =>0,        -- session_id
					levels_to_explode=>1,        -- levels_to_explode
					bom_or_eng       =>1,        -- bom_or_eng
					impl_flag        =>1,        -- impl_flag
					plan_factor_flag =>1,        -- plan_factor_flag
					explode_option   =>2,        --changed by skaradib for bug 2362939 -- explode_option
					module           =>5,        -- module
					cst_type_id      =>0,        -- cst_type_id
					std_comp_flag    =>0,        -- std_comp_flag
					expl_qty         =>1,        -- expl_qty
					item_id          =>p_assembly_item_id,
					alt_desg         =>p_alt_bom,
					comp_code        =>'',       -- comp_code
					rev_date         =>to_char(p_bom_revision_date, datetime_fmt), --datetime_fmt for bug 2393005 by skaradib
					err_msg          =>l_error_msg,
					error_code       =>l_error_code);



        if (l_error_code <> 0) then
                raise be_exploder_exception;
        end if;
    end if;

l_stmt_num := 49;

    if (x_first_flag=1) then
        begin
            select 0 into x_first_flag
            from BOM_OPERATION_NETWORKS_V BONV
            where BONV.routing_sequence_id=p_routing_sequence_id
            and    ((BONV.from_seq_num = 1) or (BONV.to_seq_num=1));
        exception
            when no_data_found then
                    null;
            when too_many_rows then
                    x_first_flag := 0;
        end;
    end if;

    begin
        OPEN reqs;

        LOOP

            FETCH reqs INTO t_comp_details(NO_OF_COMP);

            EXIT WHEN reqs%NOTFOUND;
            NO_OF_COMP := NO_OF_COMP+1;
        END LOOP;
        CLOSE reqs;
    end;

    x_no_of_first_level_comp:=NO_OF_COMP;
    i:=0;

    LOOP
        x_explode_phantoms := TRUE;
        if (t_comp_details.exists(i)) then
            if (t_comp_details(i).wip_supply_type=6) then
                BEGIN

l_stmt_num := 50;
                    t_comp_details(i).operation_seq_num :=-x_operation_seq_num;
                    x_phan_qty := t_comp_details(i).qpa;

                    SELECT B.BILL_SEQUENCE_ID, B.ORGANIZATION_ID
                    INTO x_bill_sequence_id, x_org_id
                    FROM BOM_BILL_OF_MATERIALS B
                    WHERE B.ASSEMBLY_ITEM_ID = t_comp_details(i).component_item_id
                    AND   B.ORGANIZATION_ID  = p_organization_id
                    AND   B.ALTERNATE_BOM_DESIGNATOR IS NULL;

                 EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                            x_bill_sequence_id := NULL;
                 END;
	                  -- bug 7598223: begin
 	                  l_stmt_num := 50.5;
 	                     begin
 	                         select  'Y'
 	                         into    l_ato_phantom
 	                         from    mtl_system_items msi
 	                         where   msi.inventory_item_id = t_comp_details(i).component_item_id
 	                         and     msi.organization_id   = p_organization_id
 	                         and     msi.replenish_to_order_flag = 'Y'
 	                         and     msi.bom_item_type in (1,2);
 	                     exception
 	                         when no_data_found then
 	                              l_ato_phantom := 'N';
 	                     end;
 	                  -- bug 7598223: end
l_stmt_num := 51;

                 BEGIN
                     SELECT common_routing_sequence_id into x_routing_sequence_id
                     FROM BOM_OPERATIONAL_ROUTINGS
                     WHERE assembly_item_id = t_comp_details(i).component_item_id
                     AND   organization_id = p_organization_id
                     AND   alternate_routing_designator is null
                     AND cfm_routing_flag = 3;
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        null;
                 END;
		 -- bug 7598223: added the condition on l_ato_phantom
                if ((x_explode_phantoms=TRUE) and (x_bill_sequence_id is not null) and l_ato_phantom = 'N') then

l_stmt_num := 60;

 /*                 bompexpl.exploder_userexit(0, -- verify_flag
                           p_organization_id,
                           1, --order_by
                           WSMPWROT.EXPLOSION_GROUP_ID, -- grp_id
                           0, -- session_id
                           x_max_bill_levels-1, -- levels_to_explode
                           1, -- bom_or_eng
                           1, -- impl_flag
                           1, -- plan_factor_flag
                           2, --changed by skaradib for bug 2362939 1, -- explode_option
                           5, -- module
                           0, -- cst_type_id
                           0, -- std_comp_flag
                           1, -- expl_qty
                           t_comp_details(i).component_item_id,
                           NULL,
                           x_comp_code, -- comp_code
                           to_char(p_bom_revision_date, datetime_fmt), --datetime_fmt for bug 2393005 by skaradib
                           l_error_msg,
                           l_error_code); */

-- Bug fix: 5377818 Used named convention for arguments

          bompexpl.exploder_userexit(
		            verify_flag      =>0,   -- verify_flag
					org_id           =>p_organization_id,
					order_by         =>1,        --order_by
					grp_id           =>WSMPWROT.EXPLOSION_GROUP_ID, -- grp_id
					session_id       =>0,        -- session_id
					levels_to_explode=>x_max_bill_levels-1,        -- levels_to_explode
					bom_or_eng       =>1,        -- bom_or_eng
					impl_flag        =>1,        -- impl_flag
					plan_factor_flag =>1,        -- plan_factor_flag
					explode_option   =>2,        --changed by skaradib for bug 2362939 -- explode_option
					module           =>5,        -- module
					cst_type_id      =>0,        -- cst_type_id
					std_comp_flag    =>0,        -- std_comp_flag
					expl_qty         =>1,        -- expl_qty
					item_id          =>t_comp_details(i).component_item_id,
					alt_desg         =>NULL,
					comp_code        =>x_comp_code,       -- comp_code
					rev_date         =>to_char(p_bom_revision_date, datetime_fmt), --datetime_fmt for bug 2393005 by skaradib
					err_msg          =>l_error_msg,
					error_code       =>l_error_code);


                            if (l_error_code <> 0) then
                                    raise be_exploder_exception;
                            end if;
                end if;

                if ((x_routing_sequence_id is not null) and (x_use_phantom_routings=1) and (x_bill_sequence_id is not null)) then
                    DECLARE
                        no_of_levels NUMBER:=0;
                        l_level NUMBER := 1;
                    BEGIN

l_stmt_num := 70;
                        select max(plan_level) into no_of_levels from bom_explosion_temp
                        where top_bill_sequence_id=x_bill_sequence_id;

                        FOR l_level in 1..no_of_levels LOOP
l_stmt_num := 80;
                            update bom_explosion_temp be set be.primary_path_flag=1
                            where
                            be.top_bill_sequence_id=x_bill_sequence_id
                            and be.group_id=WSMPWROT.EXPLOSION_GROUP_ID
                            and ((be.operation_seq_num=1)
                                 or (be.operation_seq_num in (
                                    select bonv.from_seq_num
                                    from   bom_operational_routings bor,
                                           bom_operation_networks_v bonv,
                                           bom_operation_sequences bos
                                    where  bor.assembly_item_id=be.assembly_item_id
                                    and    bor.alternate_routing_designator is null
                                    and    bonv.routing_sequence_id=bor.common_routing_sequence_id
                                    and    be.operation_seq_num=bos.operation_seq_num
                                    and    bos.routing_sequence_id=bor.common_routing_sequence_id
                                    AND    bos.effectivity_date <= x_routing_revision_date
                                    AND    nvl(bos.disable_date, x_routing_revision_date+2) >= x_routing_revision_date
                                                                            -- CHG: BUG2380517 from > to >=
                                    and    NVL(BOS.operation_type, 1) = 1
                                    and    bonv.transition_type=1))
                                 or (be.operation_seq_num in (
                                    select bonv.to_seq_num
                                    from   bom_operational_routings bor,
                                           bom_operation_networks_v bonv,
                                           bom_operation_sequences bos
                                    where  bor.assembly_item_id=be.assembly_item_id
                                    and    bor.alternate_routing_designator is null
                                    and    bonv.routing_sequence_id=bor.common_routing_sequence_id
                                    and    be.operation_seq_num=bos.operation_seq_num
                                    and    bos.routing_sequence_id=bor.common_routing_sequence_id
                                    AND    bos.effectivity_date <= x_routing_revision_date
                                    AND    nvl(bos.disable_date, x_routing_revision_date+2) > x_routing_revision_date
                                                                            -- CHG: BUG2380517 from > to >=
                                    and    NVL(BOS.operation_type, 1) = 1
                                    and    bonv.transition_type=1)))
                           and plan_level=l_level
                           and ((plan_level=1)
                                 OR (exists (
                                    select 'x'
                                    from bom_explosion_temp be1
                                    where be1.top_bill_sequence_id=x_bill_sequence_id
                                    and be1.group_id=WSMPWROT.EXPLOSION_GROUP_ID
                                    and be1.component_item_id=be.assembly_item_id
                                    and be1.sort_order=SUBSTR(BE.SORT_ORDER, 1, l_level*(WSMPWROT.X_SortWidth))
                                    and be1.primary_path_flag=1)));
                        END LOOP;
                    END;
                else    --if ((x_routing_sequence_id is not null) and (x_use_phantom_routings=1) and (x_bill_sequence_id is not null)) then

l_stmt_num := 90;
                    update bom_explosion_temp be set be.primary_path_flag=1
                    where be.top_bill_sequence_id=x_bill_sequence_id;

                    t_comp_details.delete(i);
                end if; --if ((x_routing_sequence_id is not null) and (x_use_phantom_routings=1) and (x_bill_sequence_id is not null)) then


                DECLARE
                cursor phan_comp is
                    SELECT
                        BE.COMPONENT_SEQUENCE_ID,
                        BE.COMPONENT_ITEM_ID,
                        BE.OPERATION_SEQ_NUM,

                        decode (p_organization_id,      -- Supply locator id begin
                                x_org_id,

                                decode (A.SUPPLY_SUBINVENTORY, NULL,
                                        decode (C.WIP_SUPPLY_SUBINVENTORY, NULL,
                                                decode(nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),2,
                                                                nvl(x_default_loc,-1),3, nvl(x_default_loc,-1), NULL),
                                                C.WIP_SUPPLY_LOCATOR_ID),
                                        A.SUPPLY_LOCATOR_ID ),

                                decode (C.WIP_SUPPLY_SUBINVENTORY, NULL,
                                        decode (nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),2,
                                                nvl(x_default_loc,-1),3, nvl(x_default_loc,-1), NULL),
                                                C.WIP_SUPPLY_LOCATOR_ID)

                               ) supply_locator_id,     -- Supply locator id end

                        decode(x_job_wip_supply_type, 7, nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),
                               x_job_wip_supply_type) wip_supply_type,
                        A.basis_type,

                        BE.extended_quantity*x_phan_qty qpa,
                        A.component_yield_factor,

                        decode (p_organization_id,
                                  x_org_id,
                                  nvl(A.SUPPLY_SUBINVENTORY, nvl(C.WIP_SUPPLY_SUBINVENTORY,
                                        decode(nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),2,x_default_sub,
                                        3,x_default_sub, NULL))),
                                  nvl(C.WIP_SUPPLY_SUBINVENTORY,
                                        decode(nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),2,x_default_sub,
                                        3,x_default_sub, NULL)) ) supply_subinventory,

                        a.component_remarks comments,
                        a.attribute_category,
                        a.attribute1,
                        a.attribute2,
                        a.attribute3,
                        a.attribute4,
                        a.attribute5,
                        a.attribute6,
                        a.attribute7,
                        a.attribute8,
                        a.attribute9,
                        a.attribute10,
                        a.attribute11,
                        a.attribute12,
                        a.attribute13,
                        a.attribute14,
                        a.attribute15,
                        c.segment1,
                        c.segment2,
                        c.segment3,
                        c.segment4,
                        c.segment5,
                        c.segment6,
                        c.segment7,
                        c.segment8,
                        c.segment9,
                        c.segment10,
                        c.segment11,
                        c.segment12,
                        c.segment13,
                        c.segment14,
                        c.segment15,
                        c.segment16,
                        c.segment17,
                        c.segment18,
                        c.segment19,
                        c.segment20,
                        x_start_date first_unit_start_date,
                        x_department_id department_id
                    FROM
                            BOM_INVENTORY_COMPONENTS A,
                            MTL_SYSTEM_ITEMS C,
                            BOM_EXPLOSION_TEMP BE
                    WHERE   BE.GROUP_ID = WSMPWROT.EXPLOSION_GROUP_ID
                            AND A.COMPONENT_SEQUENCE_ID = BE.COMPONENT_SEQUENCE_ID
                            AND C.INVENTORY_ITEM_ID = BE.COMPONENT_ITEM_ID
                            AND C.ORGANIZATION_ID = P_ORGANIZATION_ID
                            AND BE.TOP_BILL_SEQUENCE_ID=x_bill_sequence_id
                            AND BE.PRIMARY_PATH_FLAG = 1
                            AND A.EFFECTIVITY_DATE <=p_bom_revision_date
                            AND nvl(A.DISABLE_DATE, p_bom_revision_date + 1) >= p_bom_revision_date -- CHG: BUG2380517 from > to >=
                            AND A.EFFECTIVITY_DATE =
                                 (
                                  SELECT MAX(EFFECTIVITY_DATE)
                                  FROM   BOM_INVENTORY_COMPONENTS BIC,
                                         ENG_REVISED_ITEMS ERI
                                  WHERE  BIC.BILL_SEQUENCE_ID = A.BILL_SEQUENCE_ID
                                         AND BIC.COMPONENT_ITEM_ID = A.COMPONENT_ITEM_ID
                                         AND (
                                               decode(BIC.IMPLEMENTATION_DATE, NULL,
                                                     BIC.OLD_COMPONENT_SEQUENCE_ID,
                                                     BIC.COMPONENT_SEQUENCE_ID) =
                                               decode(A.IMPLEMENTATION_DATE, NULL,
                                                      A.OLD_COMPONENT_SEQUENCE_ID,
                                                      A.COMPONENT_SEQUENCE_ID)
                                             OR
                                              BIC.OPERATION_SEQ_NUM = A.OPERATION_SEQ_NUM)
                                         AND   BIC.EFFECTIVITY_DATE <= p_bom_revision_date
                                         AND   BIC.REVISED_ITEM_SEQUENCE_ID =
                                                            ERI.REVISED_ITEM_SEQUENCE_ID(+)
                                         AND   ( nvl(ERI.STATUS_TYPE,6) IN (4,6,7))
                                         AND  NOT EXISTS
                                                    (SELECT  'X'
                                                     FROM   BOM_INVENTORY_COMPONENTS BICN, ENG_REVISED_ITEMS ERI1
                                                     WHERE  BICN.BILL_SEQUENCE_ID = A.BILL_SEQUENCE_ID
                                                            AND BICN.OLD_COMPONENT_SEQUENCE_ID =
                                                                                    A.COMPONENT_SEQUENCE_ID
                                                            AND BICN.ACD_TYPE in (2,3)
                                                            AND BICN.DISABLE_DATE <= p_bom_revision_date
                                                            AND ERI1.REVISED_ITEM_SEQUENCE_ID = BICN.REVISED_ITEM_SEQUENCE_ID
                                                            AND ( nvl(ERI1.STATUS_TYPE,6) IN (4,6,7) )
                                                    ))

                            ORDER BY A.COMPONENT_ITEM_ID,
                                     nvl(A.WIP_SUPPLY_TYPE, C.WIP_SUPPLY_TYPE),
                                     TO_NUMBER(TO_CHAR(A.EFFECTIVITY_DATE,'SSSS'));

                BEGIN
l_stmt_num := 100;
                    OPEN phan_comp;
                    LOOP
                            l_stmt_num := 110;

                            FETCH phan_comp into t_comp_details(NO_OF_COMP);
                            EXIT WHEN phan_comp%NOTFOUND;

                            if ((t_comp_details(NO_OF_COMP).component_item_id=p_assembly_item_id) and (t_comp_details(NO_OF_COMP).wip_supply_type=6)) then
                                    raise loop_in_bom_exception;
                            end if;
                            IF (t_comp_details(NO_OF_COMP).wip_supply_type=6) THEN
                                    t_comp_details(NO_OF_COMP).operation_seq_num :=-x_operation_seq_num;
                            ELSE
                                    t_comp_details(NO_OF_COMP).operation_seq_num :=x_operation_seq_num;
                            END IF;
                            NO_OF_COMP:=NO_OF_COMP+1;
                    END LOOP;
                    CLOSE phan_comp;
                END;
            END IF; --if (t_comp_details(i).wip_supply_type=6) then

            IF (i=(x_no_of_first_level_comp - 1)) THEN
                    EXIT;
            ELSE
                    i := i+1;
            END IF;
        ELSE    --if (t_comp_details.exists(i)) then
                exit;
        END IF;

    END LOOP;   --LOOP


    WHILE (l<(t_comp_details.last+1)) LOOP
                m := l+1;
                if (t_comp_details.exists(l)) then
                WHILE (m<(t_comp_details.last+1)) LOOP
                if (t_comp_details.exists(m)) then
                        if (t_comp_details(l).component_item_id= t_comp_details(m).component_item_id) then
                                 t_comp_details(l).qpa := t_comp_details(l).qpa + t_comp_details(m).qpa;
                                 if (t_comp_details(l).wip_supply_type > t_comp_details(m).wip_supply_type) then
                                        t_comp_details(l).wip_supply_type := t_comp_details(m).wip_supply_type;
                                        t_comp_details(l).supply_subinventory := t_comp_details(m).supply_subinventory;
                                        t_comp_details(l).supply_locator_id := t_comp_details(m).supply_locator_id;
                                end if;
                                t_comp_details.delete(m);
                        end if;
                end if;
                m:=m+1;
                END LOOP;

                    l_stmt_num := 120;

                INSERT INTO WIP_REQUIREMENT_OPERATIONS
                (
                        inventory_item_id,
                        organization_id,
                        wip_entity_id,
                        operation_seq_num,
                        repetitive_schedule_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        component_sequence_id,
                        wip_supply_type,
                        basis_type,                 --LBM enh
                        date_required,
                        required_quantity,
                        quantity_issued,
                        quantity_per_assembly,
                        component_yield_factor, --R12-COMPONENT SHRINKAGE
                        supply_subinventory,
                        supply_locator_id,
                        mrp_net_flag,
                        comments,
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
                        attribute15,
                        segment1,
                        segment2,
                        segment3,
                        segment4,
                        segment5,
                        segment6,
                        segment7,
                        segment8,
                        segment9,
                        segment10,
                        segment11,
                        segment12,
                        segment13,
                        segment14,
                        segment15,
                        segment16,
                        segment17,
                        segment18,
                        segment19,
                        segment20,
                        department_id,
                        costed_quantity_issued,
                        costed_quantity_relieved
                )
                values
                (
                        t_comp_details(l).component_item_id,
                        p_organization_id,
                        p_wip_entity_id,
                        t_comp_details(l).operation_seq_num  + l_op_seq_num_incr,
                        NULL,
                        SYSDATE,
                        x_user_id,
                        SYSDATE,
                        x_user_id,
                        x_login_id,
                        t_comp_details(l).component_sequence_id,
                        t_comp_details(l).wip_supply_type,
                        t_comp_details(l).basis_type,                        --LBM enh
                        t_comp_details(l).first_unit_start_date,
                        ROUND(t_comp_details(l).qpa / t_comp_details(l).component_yield_factor
                                * decode(nvl(t_comp_details(l).basis_type, 1), 2, 1, p_quantity),6),  --LBM enh
                        0,
                        t_comp_details(l).qpa,
                        t_comp_details(l).component_yield_factor, --R12-Component Shrinkage
                        t_comp_details(l).supply_subinventory,
                        decode(t_comp_details(l).supply_locator_id, -1, NULL,t_comp_details(l).supply_locator_id),
                        decode(t_comp_details(l).wip_supply_type, 5, 2,
                        decode(sign(t_comp_details(l).qpa), -1, 2, 1)),
                        t_comp_details(l).comments,
                        t_comp_details(l).attribute_category,
                        t_comp_details(l).attribute1,
                        t_comp_details(l).attribute2,
                        t_comp_details(l).attribute3,
                        t_comp_details(l).attribute4,
                        t_comp_details(l).attribute5,
                        t_comp_details(l).attribute6,
                        t_comp_details(l).attribute7,
                        t_comp_details(l).attribute8,
                        t_comp_details(l).attribute9,
                        t_comp_details(l).attribute10,
                        t_comp_details(l).attribute11,
                        t_comp_details(l).attribute12,
                        t_comp_details(l).attribute13,
                        t_comp_details(l).attribute14,
                        t_comp_details(l).attribute15,
                        t_comp_details(l).segment1,
                        t_comp_details(l).segment2,
                        t_comp_details(l).segment3,
                        t_comp_details(l).segment4,
                        t_comp_details(l).segment5,
                        t_comp_details(l).segment6,
                        t_comp_details(l).segment7,
                        t_comp_details(l).segment8,
                        t_comp_details(l).segment9,
                        t_comp_details(l).segment10,
                        t_comp_details(l).segment11,
                        t_comp_details(l).segment12,
                        t_comp_details(l).segment13,
                        t_comp_details(l).segment14,
                        t_comp_details(l).segment15,
                        t_comp_details(l).segment16,
                        t_comp_details(l).segment17,
                        t_comp_details(l).segment18,
                        t_comp_details(l).segment19,
                        t_comp_details(l).segment20,
                        t_comp_details(l).department_id,
                        0,
                        0
                        );

                end if;
                l:=l+1;
        END LOOP;

if (x_use_phantom_routings = 1) then

        DECLARE
                    CURSOR phan_resc_cursor IS
                        SELECT BOR.resource_id ,
                                BOR.activity_id ,
                                BOR.standard_rate_flag ,
                                BOR.assigned_units ,
                                decode(nvl(BOR.basis_type, 1), wip_constants.PER_LOT , BOR.usage_rate_or_amount,
                                BOR.usage_rate_or_amount * nvl(WRO.QUANTITY_PER_ASSEMBLY, 1) ) usage_rate_or_amount,
                                BOR.basis_type ,
                                BOR.autocharge_type ,
                                BOS.department_id,
                                -(WRO.OPERATION_SEQ_NUM) phantom_op_seq_num,
                                WRO.INVENTORY_ITEM_ID phantom_item_id,
                                BOR.SCHEDULE_SEQ_NUM,           --bugfix 2493065
                                BOR.SUBSTITUTE_GROUP_NUM, BOR.PRINCIPLE_FLAG, BOR.SETUP_ID

                     FROM
                           MTL_UOM_CONVERSIONS CON,
                           BOM_RESOURCES BR,
                           BOM_OPERATION_RESOURCES BOR,
                           BOM_DEPARTMENT_RESOURCES BDR1,
                           BOM_OPERATION_SEQUENCES BOS,
                           BOM_OPERATIONAL_ROUTINGS BRTG,
                           WIP_REQUIREMENT_OPERATIONS WRO,
			   MTL_SYSTEM_ITEMS MSI                 --BUG 7598223
                    WHERE
                           BRTG.organization_id = p_organization_id
                      and  BRTG.assembly_item_id = wro.inventory_item_id
                      and  MSI.inventory_item_id = wro.inventory_item_id      --BUG 7598223
 	              and  MSI.organization_id = p_organization_id                     --BUG 7598223
 	              and  (MSI.bom_item_type not in (1, 2) or MSI.replenish_to_order_flag <> 'Y')   --BUG 7598223
                      and  NVL(BRTG.cfm_routing_flag, 3) = 3      /* not a flow routing */
                      and  BRTG.alternate_routing_designator IS NULL    /* primary routing */
                      and  BOS.department_id = BDR1.department_id
                      and  BOR.resource_id = BDR1.resource_id
                      and  BOR.operation_sequence_id = BOS.operation_sequence_id
                      AND  BOR.resource_id = BR.resource_id
                      AND  CON.UOM_CODE (+) = BR.UNIT_OF_MEASURE
                      AND  CON.INVENTORY_ITEM_ID (+) = 0
                      AND WRO.Operation_seq_num = -x_operation_seq_num
                      AND WRO.wip_entity_id=p_wip_entity_id
              and wro.organization_id=p_organization_id
              and BRTG.common_routing_sequence_id = BOS.routing_sequence_id
              and BOS.effectivity_date  <= x_routing_revision_date
              and NVL(BOS.operation_type, 1) = 1
              and NVL(BOS.disable_date, x_routing_revision_date+ 2) >= x_routing_revision_date
              and (bos.operation_sequence_id in ((select bon.from_op_seq_id from bom_operation_sequences bos1, BOM_OPERATION_NETWORKS_V BON
              where bon.transition_type=1
              and bon.routing_sequence_id=BRTG.common_routing_sequence_id )
              UNION ALL
              (select bon.to_op_seq_id from BOM_OPERATION_NETWORKS_V BON
              where bon.transition_type=1
              and bon.routing_sequence_id=BRTG.common_routing_sequence_id )))
                    ORDER  BY BOS.operation_seq_num;

        BEGIN

            l_stmt_num := 130;

                    SELECT max(resource_seq_num)
                    INTO x_max_resc_seq_num
                    FROM WIP_OPERATION_RESOURCES
                    WHERE wip_entity_id = p_wip_entity_id
                    and organization_id = p_organization_id
                    and operation_seq_num = x_operation_seq_num;

                    if x_max_resc_seq_num is null then
                       x_max_resc_seq_num := 0;
                    end if;

                    begin

                        l_stmt_num := 140;

                    SELECT last_update_date, last_updated_by, creation_date,
                           created_by, last_update_login, request_id,
                           program_application_id, program_id, program_update_date
                    INTO x_last_update_date, x_last_updated_by, x_creation_date,
                           x_created_by, x_last_update_login, x_request_id,
                           x_program_application_id, x_program_id, x_program_update_date
                    FROM WIP_OPERATION_RESOURCES
                    WHERE wip_entity_id = p_wip_entity_id
                       and organization_id = p_organization_id
                       and resource_seq_num = x_max_resc_seq_num
                       and operation_seq_num = x_operation_seq_num;

                    exception
                    when no_data_found then
                     x_last_update_date := SYSDATE;
                     x_last_updated_by  := FND_GLOBAL.USER_ID ;
                     x_creation_date    := SYSDATE;
                     x_created_by       := FND_GLOBAL.USER_ID;
                     x_last_update_login := FND_GLOBAL.LOGIN_ID;
                     x_request_id       := FND_GLOBAL.CONC_REQUEST_ID;
                     x_program_application_id := FND_GLOBAL.PROG_APPL_ID;
                     x_program_id       := FND_GLOBAL.CONC_PROGRAM_ID;
                     x_program_update_date := SYSDATE;

                  end;

    /* --------------------------------------------------------- *
     * GO through the cursor. Populate phantom resources         *
     * information to WIP_OPERATION_RESOURCES                    *
     * ----------------------------------------------------------*/
l_stmt_num := 160;
    FOR cur_resc IN phan_resc_cursor LOOP
        /* set resource_seq_num to be unique */
        x_max_resc_seq_num := x_max_resc_seq_num + 10;

        /* get UOM_code */

            l_stmt_num := 170;

        select unit_of_measure
          into x_uom_code
          from BOM_RESOURCES
         where resource_id = cur_resc.resource_id;

            l_stmt_num := 180;

        /* insert phantom resources */
        INSERT INTO WIP_OPERATION_RESOURCES(
                wip_entity_id,
                operation_seq_num,
                resource_seq_num,
                organization_id,
                repetitive_schedule_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                resource_id,
                uom_code,
                basis_type,
                usage_rate_or_amount,
                activity_id,
                scheduled_flag,
                assigned_units,
                autocharge_type,
                standard_rate_flag,
                applied_resource_units,
                applied_resource_value,
                start_date,
                completion_date,
                department_id,
                phantom_flag,
                phantom_op_seq_num,
                phantom_item_id,
                schedule_seq_num,             --bugfix 2493065
                substitute_group_num,
                principle_flag,
                setup_id )
        VALUES(
                p_wip_entity_id,
                x_operation_seq_num,
                x_max_resc_seq_num,
                p_organization_id,
                NULL, --DECODE(p_sched_id, 0, null, p_sched_id),
                x_last_update_date,
                x_last_updated_by,
                x_creation_date,
                x_created_by,
                x_last_update_login,
                x_request_id,
                x_program_application_id,
                x_program_id,
                x_program_update_date,
                cur_resc.resource_id,
                x_uom_code,
                cur_resc.basis_type,
                cur_resc.usage_rate_or_amount,
                cur_resc.activity_id,
                2,              /* non-scheduled */
                cur_resc.assigned_units,
                cur_resc.autocharge_type,
                cur_resc.standard_rate_flag,
                x_applied_resource_units,
                x_applied_resource_value,
                x_start_date,
                x_completion_date,
                cur_resc.department_id,
                1,              /* phantom_flag = YES */
                cur_resc.phantom_op_seq_num,
                cur_resc.phantom_item_id,
                cur_resc.schedule_seq_num,         --bugfix 2493065
                cur_resc.substitute_group_num,
                cur_resc.principle_flag,
                cur_resc.setup_id);

     END LOOP;
  END;
END IF;


--Start NL BugFix 2786476

WSMPWROT.EXPLOSION_GROUP_ID := NULL;

--End NL BugFix 2786476

--delete from wip_requirement_operations where wip_entity_id=p_wip_entity_id and operation_seq_num<0;

EXCEPTION

WHEN be_exploder_exception THEN
        x_err_code := l_error_code;
        x_err_msg := substr('WSMPWROT ('||to_char(l_stmt_num)||')' || l_error_msg,1,2000);
        x_err_msg := 'WSMWROT stop';


WHEN MY_EXCEPTION THEN
        x_err_code := -199;
        x_err_msg := 'WSMPWROT ('||to_char(l_stmt_num)||') '||x_operation_seq_num; /*NO_OF_COMP||' '
        ||t_comp_details(0).segment1||' '
        ||t_comp_details(1).segment1||' '||t_comp_details(2).segment1||' '||t_comp_details(3).segment1||' '
        ||t_comp_details(4).segment1||' '||t_comp_details(5).segment1||' '||t_comp_details(6).segment1||' '
        ||t_comp_details(7).segment1; */

WHEN loop_in_bom_exception THEN
        x_err_code := -1;
        FND_MESSAGE.SET_NAME('BOM', 'BOM_LOOP_EXISTS');
        x_err_msg := FND_MESSAGE.GET;

WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := substr('WSMPWROT ('||to_char(l_stmt_num)||')' || SQLERRM,1,2000);


END populate_wro;

FUNCTION GET_EXPLOSION_GROUP_ID
RETURN NUMBER IS
BEGIN
  return WSMPWROT.EXPLOSION_GROUP_ID;
END;

PROCEDURE SET_EXPLOSION_GROUP_ID_NULL
IS
BEGIN
        WSMPWROT.EXPLOSION_GROUP_ID := NULL;
        WSMPWROT.USE_PHANTOM_ROUTINGS := NULL;
END;

END  WSMPWROT;

/
