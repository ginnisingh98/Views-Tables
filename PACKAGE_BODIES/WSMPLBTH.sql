--------------------------------------------------------
--  DDL for Package Body WSMPLBTH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPLBTH" AS
/* $Header: WSMLBTHB.pls 115.19 2003/10/08 18:29:51 zchen ship $ */

FUNCTION Insert_Starting_Lot (
    p_transaction_type IN NUMBER,
    p_organization_id IN NUMBER,
    p_wip_flag IN NUMBER,
    p_split_flag IN NUMBER,
    p_lot_number IN VARCHAR2,
    p_inventory_item_id IN NUMBER,
    p_quantity IN NUMBER,
    p_subinventory_code IN VARCHAR2,
    p_locator_id IN NUMBER,
    p_revision IN VARCHAR2,
    X_err_code OUT NOCOPY NUMBER,
    X_err_msg OUT NOCOPY VARCHAR2
)
RETURN NUMBER IS
x_transaction_id NUMBER;
x_date DATE := SYSDATE;

x_user NUMBER := FND_GLOBAL.user_id;
x_login NUMBER := FND_GLOBAL.login_id;

BEGIN

-- commented out by abedajna for perf. tuning
/*  select WSM_split_merge_transactions_s.nextval
**  into x_transaction_id
**  from dual;
*/

    insert into WSM_lot_split_merges
    (
    transaction_id,
    transaction_type_id,
    organization_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    wip_flag,
    split_flag,
    last_update_login
    )
    values
    (
--  x_transaction_id,
    WSM_split_merge_transactions_s.nextval,
    p_transaction_type,
    p_organization_id,
    x_date,
    x_user,
    x_date,
    x_user,
    p_wip_flag,
    p_split_flag,
    x_login
    )
    returning transaction_id into x_transaction_id
    ;

    insert into WSM_sm_starting_lots
    (
    transaction_id,
    lot_number,
    inventory_item_id,
    organization_id,
    quantity,
    subinventory_code,
    locator_id,
    revision,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
    )
    values
    (
    x_transaction_id,
    p_lot_number,
    p_inventory_item_id,
    p_organization_id,
    p_quantity,
    p_subinventory_code,
    p_locator_id,
    p_revision,
    x_date,
    x_user,
    x_date,
    x_user,
    x_login
    )
    ;

    return(x_transaction_id);

EXCEPTION WHEN OTHERS THEN

    x_err_code := SQLCODE;
    x_err_msg := 'WSMPLBTH:INSERT_STARTING_LOT '||SUBSTR(SQLERRM, 1,60);
    RETURN -1;


END Insert_Starting_Lot;

PROCEDURE Insert_Resulting_Lot (
p_transaction_id          IN NUMBER ,
p_lot_number              IN VARCHAR2 ,
p_inventory_item_id       IN NUMBER ,
p_organization_id         IN NUMBER ,
p_quantity                IN NUMBER ,
p_subinventory_code       IN VARCHAR2,
p_locator_id          IN NUMBER,
X_err_code   OUT NOCOPY NUMBER,
X_err_msg    OUT NOCOPY VARCHAR2
) IS
x_date DATE := SYSDATE;
x_user NUMBER := FND_GLOBAL.user_id;
x_login NUMBER := FND_GLOBAL.login_id;
BEGIN
    insert into WSM_sm_resulting_lots
    (
    transaction_id,
    lot_number,
    inventory_item_id,
    organization_id,
    quantity,
    subinventory_code,
    locator_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
    )
    values
    (
    p_transaction_id,
    p_lot_number,
    p_inventory_item_id,
    p_organization_id,
    p_quantity,
    p_subinventory_code,
    p_locator_id,
    x_date,
    x_user,
    x_date,
    x_user,
    x_login
    );

EXCEPTION WHEN OTHERS THEN

    x_err_code := SQLCODE;
    x_err_msg := 'WSMPLBTH:INSERT_RESULTING_LOT '||SUBSTR(SQLERRM, 1,60);

END Insert_Resulting_Lot;


/* This procedure returns org level information that is needed
   at startup of the Create Lots form */

PROCEDURE get_org_values (
    p_organization_id IN NUMBER,
    p_acct_period_id OUT NOCOPY NUMBER,
    p_org_locator_control OUT NOCOPY NUMBER,
    X_err_code OUT NOCOPY NUMBER,
    X_err_msg OUT NOCOPY VARCHAR2
) IS
x_acct_period_id NUMBER;
x_org_locator_control NUMBER;

BEGIN

    -- BEGIN: BUG3126650
    --SELECT max(acct_period_id)
    --INTO x_acct_period_id
    --FROM ORG_ACCT_PERIODS
    --WHERE organization_id = p_organization_id
    --AND period_start_date <= trunc(SYSDATE)
    --AND open_flag = 'Y';
    --IF x_acct_period_id IS NULL THEN
    --    FND_MESSAGE.set_name('WIP','WIP_NO_ACCT_PERIOD');
    --    APP_EXCEPTION.raise_exception;
    --END IF;

    x_acct_period_id := WSMPUTIL.GET_INV_ACCT_PERIOD(
            x_err_code         => X_err_code,
            x_err_msg          => X_err_msg,
            p_organization_id  => p_organization_id,
            p_date             => SYSDATE);
    IF (X_err_code <> 0) THEN
        FND_MESSAGE.set_name('WIP','WIP_NO_ACCT_PERIOD');
        APP_EXCEPTION.raise_exception;
    END IF;
    -- END: BUG3126650

    SELECT max(stock_locator_control_code)
    INTO x_org_locator_control
    FROM    mtl_parameters
    WHERE organization_id = p_organization_id;

    IF x_org_locator_control IS NULL THEN
        x_org_locator_control := 1;
    END IF;

    p_acct_period_id := x_acct_period_id;
    p_org_locator_control := x_org_locator_control;

EXCEPTION WHEN OTHERS THEN

    p_acct_period_id := '';
    p_org_locator_control := '';
    x_err_code := SQLCODE;
    x_err_msg := 'WSMPLBTH:INSERT_RESULTING_LOT '||SUBSTR(SQLERRM, 1,60);


END get_org_values;

--bugfix 2212387 added parameter routing_revision and bom_revision.

FUNCTION Create_New_Lot (
     p_source_line_id IN NUMBER,
     p_organization_id IN NUMBER,
     p_primary_item_id IN NUMBER,
     p_job_name IN VARCHAR2,
     p_start_quantity IN NUMBER,
     p_net_quantity IN NUMBER, /* APS-1-AM */
     p_wip_entity_id IN NUMBER,
     p_completion_subinventory IN VARCHAR2,
     p_completion_locator_id IN NUMBER,
     p_alternate_rtg IN VARCHAR2,
     p_alternate_bom IN VARCHAR2,
     p_description IN VARCHAR2,
     p_job_type IN NUMBER,
     p_bill_sequence_id IN NUMBER,
     p_routing_sequence_id IN NUMBER,
     p_bom_revision_date IN DATE,
     p_routing_revision_date IN DATE,
     p_bom_revision IN VARCHAR2,     --2212387
     p_routing_revision IN VARCHAR2, --2212387
     p_start_date   IN DATE,
     p_complete_date IN DATE,
     p_class_code   IN VARCHAR2,
     p_wjsi_group_id OUT NOCOPY NUMBER,
         p_coproducts_supply IN NUMBER, /* APS-1-AM */
     x_err_code OUT NOCOPY NUMBER,
     x_err_msg OUT NOCOPY VARCHAR2

) RETURN NUMBER

IS

x_user_id NUMBER := FND_GLOBAL.USER_ID;
x_login NUMBER := FND_GLOBAL.login_id;
x_group_id NUMBER;
x_success NUMBER := 2;
l_st_num NUMBER :=1;

BEGIN
null;
/*
l_st_num := 10;

    INSERT INTO WIP_JOB_SCHEDULE_INTERFACE (

        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        group_id,
        source_code,
        source_line_id,
        organization_id,
        load_type,
        status_type,
        primary_item_id,
        wip_supply_type,
        job_name,
        alternate_routing_designator,
        alternate_bom_designator,
        start_Quantity,
        net_quantity,
        wip_entity_id,
        process_phase,
        process_Status,
        first_unit_start_date,
        first_unit_completion_date,
        last_unit_start_date,
        last_unit_completion_date,
        scheduling_method,
        completion_subinventory,
        completion_locator_id,
        class_code,
        description,
        bom_reference_id,
        routing_reference_id,
        bom_revision_date,
        routing_revision_date,
        bom_revision,
        routing_revision,
        firm_planned_flag,
        allow_explosion,
        Lot_number,
                coproducts_supply
    )
    VALUES
    (
        SYSDATE,
        x_user_id,
        SYSDATE,
        x_user_id,
        x_login,
--      x_group_id,
        wip_job_schedule_interface_s.nextval,
        'WSMLOT',
        p_source_line_id,
        p_organization_id,
        5,
        3,
        p_primary_item_id,
        3,
        p_job_name,
        p_alternate_rtg,
        p_alternate_bom,
        p_start_quantity,
        p_net_quantity,
        p_wip_entity_id,
        2,
        1,
        p_start_date,
        p_complete_date,
        p_start_date,
        p_complete_date,
        3,
        p_completion_subinventory,
        p_completion_locator_id,
        p_class_code,
        p_description,
        null, --p_bill_sequence_id,
        null, --p_routing_sequence_id,
            p_bom_revision_date,
            p_routing_revision_date,
                p_bom_revision,
            p_routing_revision,
        2,
        'Y',
        p_job_name,
                p_coproducts_supply
        )
        returning group_id into x_group_id;

    p_wjsi_group_id := x_group_id;

l_st_num := 30;

        WSMPMSLD.wsm_mass_load (x_group_id,
              2,
             x_err_code,
                         x_err_msg);

    IF x_err_code <> 0 THEN

        BEGIN

            SELECT nvl(min(SUBSTR(error,1,100)),x_err_msg)
            INTO x_err_msg
            FROM WIP_INTERFACE_ERRORS
            WHERE interface_id  in
                (SELECT interface_id
                 FROM wip_job_schedule_interface
                 WHERE  group_id = x_group_id)
            AND error_type = 1;

        EXCEPTION
            WHEN OTHERS THEN
            NULL;
        END ;
        RETURN -1;
    END IF;

l_st_num := 40;


        BEGIN

      SELECT count(1)
      INTO   x_success
      FROM   WIP_DISCRETE_JOBS
      WHERE  wip_entity_id = p_wip_entity_id;

    EXCEPTION WHEN NO_DATA_FOUND THEN

        x_err_code := 99999;
        x_err_msg := 'ENTITY_ID_ABSENT_IN_WDJ';
        Return -1;

        END;

l_st_num := 50;

    BEGIN

      SELECT count(1)
      INTO   x_success
      FROM   WIP_OPERATIONS
      WHERE  wip_entity_id = p_wip_entity_id;

     EXCEPTION WHEN NO_DATA_FOUND THEN

        x_err_code := 99999;
        x_err_msg := 'ENTITY_ID_ABSENT_IN_WO';
        Return -1;

        END;

l_st_num := 60;

     BEGIN

      SELECT count(1)
      INTO   x_success
      FROM   WIP_REQUIREMENT_OPERATIONS
      WHERE  wip_entity_id = p_wip_entity_id;

     EXCEPTION WHEN NO_DATA_FOUND THEN

        x_err_code := 99999;
        x_err_msg := 'ENTITY_ID_ABSENT_IN_WRO';
        Return -1;

        END;

l_st_num := 70;

    BEGIN
        SELECT min(SUBSTR(error,1,100))
        INTO x_err_msg
        FROM WIP_INTERFACE_ERRORS
        WHERE interface_id  in
            (select interface_id
             from wip_job_schedule_interface
             where group_id = x_group_id)
        AND error_type = 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL ;
        WHEN OTHERS THEN
            x_err_code := SQLCODE;
            x_err_msg := 'WSMPLBTH:CREATE_NEW_LOT '||'(stmt_num='||l_st_num||')'||SUBSTR(SQLERRM, 1,60);
        RETURN -1;

        END;

l_st_num := 80;

return 1;

EXCEPTION WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_msg := 'WSMPLBTH:CREATE_NEW_LOT '||'(stmt_num='||l_st_num||')'||SUBSTR(SQLERRM, 1,60);
        RETURN -1;
*/

END CREATE_NEW_LOT;


PROCEDURE UPDATE_WRO( p_wip_entity_id NUMBER,
              p_operation_seq_num NUMBER,
              p_inventory_item_id NUMBER,
              x_err_code OUT NOCOPY NUMBER,
              x_err_msg OUT NOCOPY VARCHAR2 ) IS

    BEGIN
        UPDATE wip_requirement_operations
        SET wip_supply_type = 1
        WHERE wip_entity_id = p_wip_entity_id
        AND operation_seq_num = p_operation_seq_num
        AND inventory_item_id = p_inventory_item_id;

    EXCEPTION

        WHEN OTHERS THEN
            x_err_code := SQLCODE;
            x_err_msg := 'WSMPLBTH:UPDATE_WRO  '||SUBSTR(SQLERRM, 1,60);

    END;

/*BA#2326548*/
    PROCEDURE lot_creation_enter_genealogy(p_transaction_id IN NUMBER,
                                           p_organization_id IN NUMBER,
                                           p_starting_lot_number IN VARCHAR2,
                                           p_source_item_id IN NUMBER,
                                        p_resulting_lot_number IN VARCHAR2,
                                        p_err_code OUT NOCOPY NUMBER,
                        p_err_msg OUT NOCOPY VARCHAR2) IS


      l_return_status         VARCHAR2(200);
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2(200);
      l_err_msg               VARCHAR2(2000);

    BEGIN

                       inv_genealogy_pub.insert_genealogy
                        (       p_api_version           => 1.0,
                                p_object_type           => 1,
                                p_parent_object_type    => 1,
                                p_object_number         => p_starting_lot_number,
                                p_inventory_item_id     => p_source_item_id,
                                p_org_id                => p_organization_id,
                                p_parent_object_number  => p_resulting_lot_number,
                                p_parent_inventory_item_id => p_source_item_id,
                                p_parent_org_id         => p_organization_id,
                                p_genealogy_origin      => 3,
                                p_genealogy_type        => 4,
                                p_origin_txn_id         => p_transaction_id,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data ) ;


                        IF ( l_msg_count = 1)  THEN
              fnd_message.set_name('INV',l_msg_data);
              p_err_code := -1;
              p_err_msg := fnd_message.get;
             ELSIF ( l_msg_count > 0 ) THEN
                            l_msg_data := fnd_msg_pub.get;
                            p_err_code := -1;
                            p_err_msg := fnd_message.get;
            END If;

    END;
/*EA#2326548*/


END WSMPLBTH;

/
