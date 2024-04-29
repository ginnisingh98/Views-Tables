--------------------------------------------------------
--  DDL for Package Body MSC_ATP_EXCEPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_EXCEPTIONS" AS
/* $Header: MSCATPXB.pls 120.1 2007/12/12 10:22:59 sbnaik ship $  */

G_PKG_NAME 		CONSTANT     VARCHAR2(30) := 'MSC_ATP_EXCEPTIONS';
PG_DEBUG                             VARCHAR2(1) := Order_Sch_Wb.mr_debug;

-- Function to get the plan type for a given plan_id.
-- Returns 1 if the plan is optimized or constrained.
-- Returns 0 otherwise
-- Should be replaced by checks in Get_Plan_Info
PROCEDURE Get_Plan_Constraints  (
        p_plan_id         in            number,
        x_plan_type       out NOCOPY    number
) IS

    l_optimized_plan    number;
    l_constrain_plan    number;
BEGIN

    x_plan_type := 0;
    SELECT DECODE(plans.plan_type, 4, 2,
             DECODE(daily_material_constraints, 1, 1,
               DECODE(daily_resource_constraints, 1, 1,
                 DECODE(weekly_material_constraints, 1, 1,
                   DECODE(weekly_resource_constraints, 1, 1,
                     DECODE(period_material_constraints, 1, 1,
                       DECODE(period_resource_constraints, 1, 1, 2)
                           )
                         )
                       )
                     )
                   )
                 ),
           DECODE(NVL(fnd_profile.value('MSO_BATCHABLE_FLAG'),'N'), 'Y', DECODE(plans.plan_type, 4, 0,2,0,
             DECODE(daily_material_constraints, 1, 1,
               DECODE(daily_resource_constraints, 1, 1,
                 DECODE(weekly_material_constraints, 1, 1,
                   DECODE(weekly_resource_constraints, 1, 1,
                     DECODE(period_material_constraints, 1, 1,
                       DECODE(period_resource_constraints, 1, 1, 2)
                           )
                         )
                       )
                     )
                   )
                 ), 0)

    INTO   l_optimized_plan,l_constrain_plan
    FROM   msc_designators desig,
           msc_plans plans
    WHERE  plans.plan_id = p_plan_id
    AND    desig.designator = plans.compile_designator
    AND    desig.sr_instance_id = plans.sr_instance_id
    AND    desig.organization_id = plans.organization_id;

    if (l_optimized_plan = 1) or (l_constrain_plan = 1) then
        x_plan_type := 1;
    end if;

EXCEPTION
    WHEN OTHERS THEN
        x_plan_type := 0;
        if (PG_DEBUG in ('Y','C')) then
        msc_sch_wb.atp_debug ('Get_Plan_Constraints: Exception encountered');
        end if;
END Get_Plan_Constraints;

-- Add a new ATP Exception

PROCEDURE Add_ATP_Exception (
        p_session_id            IN              NUMBER,
        p_exception_rec         IN OUT NOCOPY   MSC_ATP_EXCEPTIONS.ATP_Exception_Rec_Typ,
        x_return_status         OUT NOCOPY      VARCHAR2
) IS

l_insert_item_exception         NUMBER := 0;
-- l_plan_type                  NUMBER := 0; -- bug 2795053-reopen (ssurendr): plan_type variable removed
l_tmp_var                       NUMBER := 0;

BEGIN

    -- Debug Output
    if (PG_DEBUG in ('Y', 'C')) then
    msc_sch_wb.atp_debug ('********** Begin Add_ATP_Exception **********');
    msc_sch_wb.atp_debug ('Input Record Dump: ');
    msc_sch_wb.atp_debug ('   Exception_Type  ' || p_exception_rec.exception_type);
    msc_sch_wb.atp_debug ('   Exception_Grp   ' || p_exception_rec.exception_group);
    msc_sch_wb.atp_debug ('   Plan ID         ' || p_exception_rec.plan_id);
    msc_sch_wb.atp_debug ('   Organization ID ' || p_exception_rec.organization_id);
    msc_sch_wb.atp_debug ('   Inventory Item ID    ' || p_exception_rec.inventory_item_id); --4235545
    msc_sch_wb.atp_debug ('   Sr Instance ID  ' || p_exception_rec.sr_instance_ID);
    msc_sch_wb.atp_debug ('   Demand ID       ' || p_exception_rec.demand_id);
    msc_sch_wb.atp_debug ('   Quantity        ' || p_exception_rec.quantity);
    msc_sch_wb.atp_debug ('   Qty. Satisfied  ' || p_exception_rec.quantity_satisfied);
    msc_sch_wb.atp_debug ('   Dmd Satisfy Dt  ' || p_exception_rec.demand_satisfy_date);
    msc_sch_wb.atp_debug ('   Order Number    ' || p_exception_rec.order_number);
    msc_sch_wb.atp_debug ('   Customer ID     ' || p_exception_rec.customer_id);
    msc_sch_wb.atp_debug ('   Cusustomer Site ID    ' || p_exception_rec.customer_site_id); --4235545
    msc_sch_wb.atp_debug ('----------------------------------------------- ');
    end if;

    -- Initialize variables
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Error Checking
    if (p_exception_rec.exception_group <> 5) OR -- Late Sales order
       -- bug 2795053-reopen (ssurendr): Exception type check changed.
       (p_exception_rec.exception_type <> 68 ) THEN  -- Overcommitment of Sales Order
            if (PG_DEBUG in ('Y', 'C')) then
            msc_sch_wb.atp_debug ('AEX: Only supported exceptions are :');
            msc_sch_wb.atp_debug ('AEX:     Group = 5');
            msc_sch_wb.atp_debug ('AEX:     Type = 68');
            end if;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
    end if;

    /*
    bug 2795053-reopen (ssurendr): Plan type check removed.
    -- Set Exception group and type based on plan type.
    GET_PLAN_CONSTRAINTS (p_exception_rec.plan_id, l_plan_type);

    if (l_plan_type = 1) then
        p_exception_rec.exception_type := 24; -- Constrained plan , use late repln.
    else
        p_exception_rec.exception_type := 15; -- Unconstrained, use late supply
    end if;
    if (PG_DEBUG in ('Y', 'C')) then
        msc_sch_wb.atp_debug ('Plan type as determined is : '|| l_plan_type);
        msc_sch_wb.atp_debug ('Exception type after check is : '|| p_exception_rec.exception_type);
    end if;
    */

    -- First Insert Data into Exception Details
    BEGIN
        insert into msc_exception_details (
            exception_detail_id,
            exception_type,
            quantity,
            date1,-- Demand Satisfaction Date
            number1,  -- Demand ID
            number3,  -- Demand date quantity
            plan_id,
            organization_id,
            inventory_item_id,
            resource_id,
            department_id,
            sr_instance_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            number4  -- Origination
        )
        values (
            msc_exception_details_s.nextval,
            p_exception_rec.exception_type,
            p_exception_rec.quantity,
            p_exception_rec.demand_satisfy_date, -- This is a misnomer. This actually contains demand date.
            p_exception_rec.demand_id,
            p_exception_rec.quantity_satisfied,
            p_exception_rec.plan_id,
            p_exception_rec.organization_id,
            p_exception_rec.inventory_item_id,
            -1,
            -1,
            p_exception_rec.sr_instance_id,
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            MSC_ATP_EXCEPTIONS.G_ATP_EXCEPTION_ORIGIN_CODE
        );
    EXCEPTION
        WHEN OTHERS THEN
            if (PG_DEBUG in ('Y','C')) then
            msc_sch_wb.atp_debug ('AEX: Unable to add exception details record');
            msc_sch_wb.atp_debug ('Error is: ' || sqlerrm);
            msc_sch_wb.atp_debug ('Code : ' || sqlcode);
            end if;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    if (PG_DEBUG in ('Y','C')) then
    msc_sch_wb.atp_debug ('AEX: Inserted details record. Now updating item record');
    end if;

    -- Next try an dupdate the exception count
    BEGIN
         select 1
           into l_tmp_var
           from msc_item_exceptions
          where plan_id = p_exception_rec.plan_id
            and organization_id = p_exception_rec.organization_id
            and sr_instance_id = p_exception_rec.sr_instance_id
            and inventory_item_id = p_exception_rec.inventory_item_id
            and exception_type = p_exception_rec.exception_type;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            if (PG_DEBUG in ('Y','C')) then
                msc_sch_wb.atp_debug ('AEX: No record found in item exception table');
            end if;
            l_insert_item_exception := 1;
        WHEN TOO_MANY_ROWS THEN
            if (PG_DEBUG in ('Y','C')) then
                msc_sch_wb.atp_debug ('AEX: Multiple records found in item exception table');
            end if;
            l_insert_item_exception := 0;
        WHEN OTHERS THEN
            if (PG_DEBUG in ('Y','C')) then
            msc_sch_wb.atp_debug ('AEX: Unable to add item exception record');
            msc_sch_wb.atp_debug ('Code : ' || sqlcode);
            msc_sch_wb.atp_debug ('Error is: ' || sqlerrm);
            end if;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    if (l_insert_item_exception = 1 ) THEN
        BEGIN
            -- insert into msc_item_exceptions
            insert into msc_item_exceptions (
                plan_id,
                organization_id,
                sr_instance_id,
                inventory_item_id,
                exception_type,
                exception_group,
                -- exception_count, bug 2795053-reopen (ssurendr): Count removed
                last_update_date,
                last_updated_by,
                creation_date,
                created_by
            )
            values (
                p_exception_rec.plan_id,
                p_exception_rec.organization_id,
                p_exception_rec.sr_instance_id,
                p_exception_rec.inventory_item_id,
                p_exception_rec.exception_type,
                p_exception_rec.exception_group,
                -- 1, bug 2795053-reopen (ssurendr): Count removed.
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID
            );
            if (PG_DEBUG in ('Y','C')) then
            msc_sch_wb.atp_debug ('AEX: Inserted item exception record');
            end if;
        EXCEPTION
            WHEN OTHERS THEN
                if (PG_DEBUG in ('Y','C')) then
                msc_sch_wb.atp_debug('Add_Exception: Error while inserting new exception type');
                msc_sch_wb.atp_debug('Error is: ' || sqlerrm);
                msc_sch_wb.atp_debug ('Code : ' || sqlcode);
                end if;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
    end if;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        if (PG_DEBUG in ('Y','C')) then
        msc_sch_wb.atp_debug ('Add_Exception: G_EXC_ERROR');
        msc_sch_wb.atp_debug ('Code : ' || sqlcode);
        msc_sch_wb.atp_debug ('Error is: ' || sqlerrm);
        end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        if (PG_DEBUG in ('Y','C')) then
        msc_sch_wb.atp_debug ('Add_Exception: G_EXC_UNEXPECTED_ERROR');
        msc_sch_wb.atp_debug ('Code : ' || sqlcode);
        msc_sch_wb.atp_debug ('Error is: ' || sqlerrm);
        end if;

    WHEN OTHERS THEN
        if (PG_DEBUG in ('Y','C')) then
        msc_sch_wb.atp_debug ('Add_Exception: OTHERS');
        msc_sch_wb.atp_debug ('Code : ' || sqlcode);
        msc_sch_wb.atp_debug ('Error is: ' || sqlerrm);
        end if;

END Add_ATP_Exception;

END MSC_ATP_EXCEPTIONS;

/
