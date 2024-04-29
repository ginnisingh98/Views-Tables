--------------------------------------------------------
--  DDL for Package Body EAM_WORKORDERTRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WORKORDERTRANSACTIONS_PUB" AS
/* $Header: EAMPWOTB.pls 120.4.12010000.3 2009/04/08 10:21:13 smrsharm ship $ */

     -- Version  Initial version    1.0    Alice Yang

-- Validate:
-- 1) transaction type is either TXN_TYPE_COMPLETE or TXT_TYPE_UNCOMPLETE
-- 2) transaction date <= sysdate

PROCEDURE Validate_Transaction(
	p_x_return_status	IN OUT NOCOPY VARCHAR2,
	p_transaction_type	IN NUMBER,
        p_transaction_date      IN DATE) IS
BEGIN
        IF p_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            IF (NOT p_transaction_type = G_TXN_TYPE_COMPLETE) AND (NOT p_transaction_type = G_TXN_TYPE_UNCOMPLETE) THEN
                -- validate transaction type
                FND_MESSAGE.set_name('EAM', 'EAM_INVALID_TXN_TYPE');
                p_x_return_status := FND_API.G_RET_STS_ERROR;
            ELSIF p_transaction_date > sysdate THEN
                -- validate transaction_date
                FND_MESSAGE.set_name('EAM', 'EAM_TXN_LATER_THAN_TODAY');
                p_x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
END Validate_Transaction;

-- Validate (and Calculate):
-- 1) At least 2 of the 3 date related inputs are not null, and derive
--    the 3rd from the existing 2.  If all 3 values are not null, then
--    duration is over written by end_date - start_date
-- 2) start_date <= end_date
-- 3) end_date <= sysdate
PROCEDURE Validate_Start_End_Dates(
        p_x_return_status       IN OUT NOCOPY VARCHAR2,
        p_x_actual_start_date   IN OUT NOCOPY DATE,
        p_x_actual_end_date     IN OUT NOCOPY DATE,
        p_x_actual_duration     IN OUT NOCOPY NUMBER) IS
BEGIN
        IF p_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            IF p_x_actual_start_date is not null THEN
                IF p_x_actual_end_date is not null THEN
                  -- Fix for the bug 7136230
                    p_x_actual_duration := round(24*(p_x_actual_end_date - p_x_actual_start_date),3);
                ELSIF p_x_actual_duration is not null THEN
                    p_x_actual_end_date := p_x_actual_start_date + p_x_actual_duration;
                ELSE
                    -- missing both end_date and duration
                    FND_MESSAGE.set_name('EAM', 'EAM_MISSING_DATE_INFO');
                    p_x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
            ELSIF p_x_actual_end_date is not null THEN
                IF p_x_actual_duration is not null THEN
                    p_x_actual_start_date := p_x_actual_end_date - p_x_actual_duration;
                ELSE
                    -- missing both start_date and duration
                    FND_MESSAGE.set_name('EAM', 'EAM_MISSING_DATE_INFO');
                    p_x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
            ELSE
                -- missing both start and end dates
                FND_MESSAGE.set_name('EAM', 'EAM_MISSING_DATE_INFO');
                p_x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
        IF p_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            IF p_x_actual_start_date > p_x_actual_end_date THEN
                FND_MESSAGE.set_name('EAM', 'EAM_END_BEFORE_START');
                p_x_return_status := FND_API.G_RET_STS_ERROR;
            ELSIF p_x_actual_end_date > sysdate THEN
                FND_MESSAGE.set_name('EAM', 'EAM_END_LATER_THAN_TODAY');
                p_x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
END Validate_Start_End_Dates;

-- Validate:
-- 1) All required params are not null
-- 2) wip_entity_id is valid id
PROCEDURE Validate_Required_Information(
        p_x_return_status       IN OUT NOCOPY VARCHAR2,
        p_wip_entity_id         IN NUMBER,
        p_transaction_type      IN NUMBER,
        p_transaction_date      IN DATE,
        x_organization_id       OUT NOCOPY NUMBER,
        x_parent_wip_entity_id  OUT NOCOPY NUMBER,
        x_asset_group_id        OUT NOCOPY NUMBER,
        x_asset_number          OUT NOCOPY VARCHAR2,
	x_rebuild_jobs          OUT NOCOPY VARCHAR2,
	x_manual_rebuild_flag   OUT NOCOPY VARCHAR2,
        x_shutdown_type		OUT NOCOPY NUMBER) IS
    l_rebuild_item_id NUMBER;
    l_entity_type NUMBER;
    l_status_type NUMBER;
BEGIN
        IF NOT p_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            return;
        END IF;
        IF (p_wip_entity_id is null or  p_transaction_type is null or p_transaction_date is null) THEN
            FND_MESSAGE.set_name('EAM', 'EAM_WORK_ORDER_MISSING_INFO');
            p_x_return_status := FND_API.G_RET_STS_ERROR;
            return;
        END IF;

        -- check wip_entity_id points to a valid eam workorder
	select entity_type into l_entity_type
	    from wip_entities
	    where wip_entity_id = p_wip_entity_id;
        if (NOT l_entity_type = 6) then
	-- not an open eam job
	    FND_MESSAGE.set_name('EAM', 'EAM_NOT_OPEN_EAM_JOB');
	    p_x_return_status := FND_API.G_RET_STS_ERROR;
	    return;
 	END IF;

        -- set out params by query wip_discrete_jobs table
        select parent_wip_entity_id,
               asset_group_id,
               asset_number,
               organization_id,
	       rebuild_item_id,
	       manual_rebuild_flag,
               status_type,
	       shutdown_type
          into x_parent_wip_entity_id,
               x_asset_group_id,
               x_asset_number,
               x_organization_id,
               l_rebuild_item_id,
	       x_manual_rebuild_flag,
	       l_status_type,
	       x_shutdown_type
        from wip_discrete_jobs
        where wip_entity_id = p_wip_entity_id;
        if l_rebuild_item_id is null then
	    x_rebuild_jobs := 'N';
        else
	    x_rebuild_jobs := 'Y';
	end if;

	if p_transaction_type = G_TXN_TYPE_COMPLETE and (NOT l_status_type = 3) then
	    FND_MESSAGE.set_name('EAM', 'EAM_NOT_RELEASED_STATUS');
	    p_x_return_status := FND_API.G_RET_STS_ERROR;
	elsif p_transaction_type = G_TXN_TYPE_UNCOMPLETE and (NOT l_status_type = 4) then
	    FND_MESSAGE.set_name('EAM', 'EAM_NOT_COMPLETED_STATUS');
	    p_x_return_status := FND_API.G_RET_STS_ERROR;
	end if;
END Validate_Required_Information;

-- Validate:
-- actual work order start date is no later than the earliest actual operation
-- start dates (for all operations under this work order), and vice versa
-- for the end dates
PROCEDURE Validate_Actl_Dates_vs_Optns(
        p_x_return_status       IN OUT NOCOPY VARCHAR2,
        p_wip_entity_id         IN NUMBER,
        p_actual_start_date     IN DATE,
        p_actual_end_date       IN DATE) IS

  l_max_op_end_date DATE;
  l_min_op_start_date DATE;

BEGIN
        IF NOT p_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            return;
        END IF;

        select max(actual_end_date) into l_max_op_end_date
        from eam_op_completion_txns
        where wip_entity_id = p_wip_entity_id and transaction_type = G_TXN_TYPE_COMPLETE;

        select min(actual_start_date) into l_min_op_start_date
        from eam_op_completion_txns
        where wip_entity_id = p_wip_entity_id and transaction_type = G_TXN_TYPE_COMPLETE;

        IF (l_max_op_end_date is not null AND
            p_actual_end_date is not null AND
            l_max_op_end_date > p_actual_end_date) then
              FND_MESSAGE.set_name('EAM', 'EAM_WO_ACTUAL_END_DATE');
              p_x_return_status := FND_API.G_RET_STS_ERROR;
              return;
        end IF;

        IF (l_min_op_start_date is not null AND
            p_actual_start_date is not null AND
            l_min_op_start_date < p_actual_start_date) then
              FND_MESSAGE.set_name('EAM', 'EAM_WO_ACTUAL_START_DATE');
              p_x_return_status := FND_API.G_RET_STS_ERROR;
        end IF;
END Validate_Actl_Dates_vs_Optns;

-- Validate:
-- actual start date must be no earlier than minimum start date of all open acct periods

/*bug5859455
PROCEDURE Validate_Date_vs_Acct_Periods(
        p_x_return_status       IN OUT NOCOPY VARCHAR2,
        p_actual_start_date     IN DATE,
        p_organization_id       IN NUMBER) IS

    l_min_open_period_start_date DATE;
BEGIN
        IF NOT p_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            return;
        END IF;
        select nvl(min(period_start_date),sysdate+2)
        into l_min_open_period_start_date
        from org_acct_periods
        where organization_id = p_organization_id
        and open_flag = 'Y';
        if (p_actual_start_date < l_min_open_period_start_date) then
            FND_MESSAGE.set_name('EAM', 'EAM_MIN_WO_ACTUAL_START_DATE');
            p_x_return_status := FND_API.G_RET_STS_ERROR;
        end if;
END Validate_Date_vs_Acct_Periods;*/


 PROCEDURE Validate_Date_vs_Acct_Periods(
           p_x_return_status       IN OUT NOCOPY VARCHAR2,
           p_transaction_date     IN DATE,
           p_organization_id       IN NUMBER) IS

       l_min_open_period_start_date DATE;
   BEGIN
           IF NOT p_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
               return;
           END IF;
           select nvl(min(period_start_date),sysdate+2)
           into l_min_open_period_start_date
           from org_acct_periods
           where organization_id = p_organization_id
           and open_flag = 'Y';
           if (p_transaction_date < l_min_open_period_start_date) then
                FND_MESSAGE.set_name('EAM', 'EAM_TRANSACTION_DATE_INVALID');
               p_x_return_status := FND_API.G_RET_STS_ERROR;
           end if;
   END Validate_Date_vs_Acct_Periods;



-- Calculate:
-- for uncomplete transaction types: set actual start and end date to the
-- the last start and end date for this work order
PROCEDURE Calculate_Actl_Dates(
        p_x_return_status       IN OUT NOCOPY VARCHAR2,
        p_wip_entity_id IN NUMBER,
        x_actual_start_date     OUT NOCOPY DATE,
        x_actual_end_date       OUT NOCOPY DATE) IS

    l_max_tran_date DATE;
BEGIN
        IF NOT p_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            return;
        END IF;
        select max(transaction_date) into l_max_tran_date
            from eam_job_completion_txns where transaction_type = 1
            and wip_entity_id = p_wip_entity_id;
        select actual_start_date, actual_end_date into
            x_actual_start_date, x_actual_end_date
            from eam_job_completion_txns
            where transaction_date = l_max_tran_date;
END Calculate_Actl_Dates;

-- Validate:
-- if subinventory is provided, check that it is an expense subinventory
PROCEDURE Validate_Expense_Inventory(
        p_x_return_status       IN OUT NOCOPY VARCHAR2,
	p_instance_id		IN VARCHAR2,
        p_inventory_item_info   IN Inventory_Item_Tbl_Type,
        p_organization_id       IN NUMBER) IS

    l_asset_inventory NUMBER;
BEGIN
--	dbms_output.put_line('p_instance_id is '||p_instance_id);
        IF NOT p_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            return;
        END IF;
        IF (p_inventory_item_info.COUNT = 0) THEN
	    FND_MESSAGE.set_name('EAM', 'EAM_INVENTORY_NULL');
            p_x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
        END IF;

        FOR i IN 1..p_inventory_item_info.COUNT LOOP
            IF p_inventory_item_info(i).subinventory IS NULL THEN
	        FND_MESSAGE.set_name('EAM', 'EAM_INVENTORY_NULL');
	        p_x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
            END IF;
        END LOOP;

        -- p_inventory_item_info can have multi-lines only if if this is service work order
        if (p_instance_id is null) then
            if (p_inventory_item_info.COUNT > 1) then
                FND_MESSAGE.set_name('EAM', 'EAM_MULTIPLE_INVENTORY');
                p_x_return_status := FND_API.G_RET_STS_ERROR;
                return;
            else
                -- check for expense inventory
                select asset_inventory into l_asset_inventory
                  from mtl_secondary_inventories
                  where secondary_inventory_name = p_inventory_item_info(1).subinventory
                  and organization_id = p_organization_id;
                IF (NOT l_asset_inventory = 2) THEN
                    FND_MESSAGE.set_name('EAM', 'EAM_EXPENSE_SUBINVENTORY');
                    p_x_return_status := FND_API.G_RET_STS_ERROR;
                    return;
                END IF;
             end if;
        end if;
END Validate_Expense_Inventory;

-- Validate:
-- 1) If item, subinventory, or org is locator control (i.e. either pre-specified
-- or dynamin locator control (2,3) then ensure that locator is provided
-- 2) locator is in the list of valid locators
PROCEDURE Validate_Locator_Control(
        p_x_return_status       IN OUT NOCOPY VARCHAR2,
        p_asset_group_id        IN NUMBER,
        p_organization_id       IN NUMBER,
        p_inventory_item_info   IN Inventory_Item_Tbl_Type) IS
    l_locator NUMBER;
    l_location_control_code NUMBER;
    l_locator_type NUMBER;
    l_stock_locator_control_code NUMBER;
    l_inventory_location_id NUMBER;
    l_count NUMBER;
    l_subinventory VARCHAR2(100);
BEGIN
    IF NOT p_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;
    if p_asset_group_id IS NOT NULL then
      select location_control_code into l_location_control_code
        from mtl_system_items
        where inventory_item_id = p_asset_group_id and
        organization_id = p_organization_id;
    end if;
    select stock_locator_control_code into l_stock_locator_control_code
        from mtl_parameters
        where organization_id = p_organization_id;
    for i in 1..p_inventory_item_info.COUNT loop
        l_locator := p_inventory_item_info(i).locator;
	l_subinventory := p_inventory_item_info(i).subinventory;
        select locator_type into l_locator_type
          from mtl_secondary_inventories
          where secondary_inventory_name = l_subinventory
          and organization_id = p_organization_id;

        if (l_location_control_code in (2,3) or l_locator_type in (2,3)
            or l_stock_locator_control_code in (2,3)) then
            if l_locator is null then
                FND_MESSAGE.set_name('EAM', 'EAM_LOCATOR_ID_IS_NULL');
                p_x_return_status := FND_API.G_RET_STS_ERROR;
                return;
            end if;
        end if;
        if l_locator is not null then
            select count(*) into l_count
                from mtl_item_locations
                where organization_id = p_organization_id and inventory_location_id = l_locator and subinventory_code = l_subinventory;
            if (l_count = 0) then
                FND_MESSAGE.set_name('EAM', 'EAM_NOT_VALID_LOCATOR_ID');
                p_x_return_status := FND_API.G_RET_STS_ERROR;
		return;
            end if;
        end if;
    end loop;

end Validate_Locator_Control;

PROCEDURE Complete_Work_Order(
          p_api_version          IN NUMBER,
          p_init_msg_list        IN VARCHAR2 := fnd_api.g_false,
          p_commit               IN VARCHAR2 := fnd_api.g_false,
          x_return_status        OUT NOCOPY VARCHAR2,
          x_msg_count            OUT NOCOPY NUMBER,
          x_msg_data             OUT NOCOPY VARCHAR2,
          p_wip_entity_id        IN NUMBER,
          p_transaction_type     IN NUMBER,
          p_transaction_date     IN DATE,
          p_instance_id          IN NUMBER   := null,
          p_user_id              IN NUMBER   := fnd_global.user_id,
          p_request_id           IN NUMBER   := null,
          p_application_id       IN NUMBER   := null,
          p_program_id           IN NUMBER   := null,
          p_reconciliation_code  IN VARCHAR2 := null,
          p_actual_start_date    IN DATE     := null,
          p_actual_end_date      IN DATE     := null,
          p_actual_duration      IN NUMBER   := null,
          p_shutdown_start_date  IN DATE     := null,
          p_shutdown_end_date    IN DATE     := null,
          p_shutdown_duration    IN NUMBER   := null,
          p_inventory_item_info  IN Inventory_Item_Tbl_Type,
          p_reference            IN VARCHAR2 := null,
          p_reason               IN VARCHAR2 := null,
          p_attributes_rec       IN Attributes_Rec_Type
) IS

    l_api_name                  CONSTANT VARCHAR2(30) := 'Complete_Work_Order';
    l_api_version               CONSTANT NUMBER := 1.0;

    l_organization_id           NUMBER;
    l_rebuild_jobs              VARCHAR2(1);
    l_parent_wip_entity_id      NUMBER;
    l_asset_group_id            NUMBER;
    l_asset_number              VARCHAR2(30);
    l_manual_rebuild_flag       VARCHAR2(1);
    l_shutdown_type             NUMBER;

    l_actual_start_date         DATE;
    l_actual_end_date           DATE;
    l_actual_duration           NUMBER;
    l_shutdown_start_date       DATE;
    l_shutdown_end_date         DATE;
    l_shutdown_duration         NUMBER;

    l_errCode                   NUMBER;
    l_errMsg                    VARCHAR2(100);
    l_inventory_item_rec EAM_WorkOrderTransactions_PUB.Inventory_Item_Rec_Type;
    l_inventory_item_tbl EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type;
    l_maintenance_source_id  NUMBER;
     l_rebuild_item_id         NUMBER; /* Added for bug#5841713 */
BEGIN

    -- Standard begin of API savepoint
    SAVEPOINT Complete_Work_Order_PVT;
    -- Check p_init_msg_list
    IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize local date variables
    l_actual_start_date := p_actual_start_date;
    l_actual_end_date := p_actual_end_date;
    l_actual_duration := p_actual_duration;
    l_shutdown_start_date := p_shutdown_start_date;
    l_shutdown_end_date := p_shutdown_end_date;
    l_shutdown_duration := p_shutdown_duration;

    Validate_Required_Information(
        x_return_status,
        p_wip_entity_id,
        p_transaction_type,
        p_transaction_date,
        l_organization_id,
        l_parent_wip_entity_id,
        l_asset_group_id,
        l_asset_number,
        l_rebuild_jobs,
        l_manual_rebuild_flag,
        l_shutdown_type);


    Validate_Transaction(
        x_return_status,
        p_transaction_type,
        p_transaction_date);

    -- if transaction type is complete work order
    IF p_transaction_type = G_TXN_TYPE_COMPLETE THEN


        Validate_Start_End_Dates(
            x_return_status,
            l_actual_start_date,
            l_actual_end_date,
            l_actual_duration);
        -- validate shutdown dates exist if necessary
        if l_shutdown_type = 2 then
            Validate_Start_End_Dates(
                x_return_status,
                l_shutdown_start_date,
                l_shutdown_end_date,
                l_shutdown_duration);
        end if;

        Validate_Actl_Dates_vs_Optns(
            x_return_status,
            p_wip_entity_id,
            l_actual_start_date,
            l_actual_end_date);


       /* bug 5859455 Validate_Date_vs_Acct_Periods(
            x_return_status,
            l_actual_start_date,
            l_organization_id);*/

	  Validate_Date_vs_Acct_Periods(
               x_return_status,
               p_transaction_date,
               l_organization_id);


        IF l_rebuild_jobs = 'Y' THEN
            IF l_manual_rebuild_flag = 'N' THEN
                -- need subinventory

                 Validate_Expense_Inventory(
                     x_return_status,
                     p_instance_id,
                     p_inventory_item_info,
                     l_organization_id);

                 Validate_Locator_Control(
                     x_return_status,
                     l_asset_group_id,
                     l_organization_id,
                     p_inventory_item_info);
            END IF;
        END IF;
    ELSIF p_transaction_type = G_TXN_TYPE_UNCOMPLETE THEN
        Calculate_Actl_Dates(
            x_return_status,
            p_wip_entity_id,
            l_actual_start_date,
            l_actual_end_date);
    END IF;

    if x_return_status = FND_API.G_RET_STS_SUCCESS then


-- Bug 3676937 . For CMRO work orders need not check completion subinventory
    select maintenance_object_source, rebuild_item_id
    into l_maintenance_source_id, l_rebuild_item_id
    from wip_discrete_jobs
    where wip_entity_id = p_wip_entity_id;


if l_maintenance_source_id = 2 then  -- for CMRO no inventory item info is required.


     l_inventory_item_rec.subinventory := NULL;
     l_inventory_item_rec.locator := NULL;
     l_inventory_item_rec.lot_number := NULL;
     l_inventory_item_rec.serial_number := NULL;
     l_inventory_item_rec.quantity := NULL;
     l_inventory_item_tbl(1) := l_inventory_item_rec;
  else
	IF l_rebuild_item_id IS NOT NULL THEN /* Added for bug#5841713 End */
	     l_inventory_item_rec.subinventory := p_inventory_item_info(1).subinventory;
	     l_inventory_item_rec.locator := p_inventory_item_info(1).locator;
	     l_inventory_item_rec.lot_number := p_inventory_item_info(1).lot_number;
	     l_inventory_item_rec.serial_number := p_inventory_item_info(1).serial_number;
	     l_inventory_item_rec.quantity := p_inventory_item_info(1).quantity;
	     l_inventory_item_tbl(1) := l_inventory_item_rec;
	END IF; /* Added for bug#5841713 End */

end if ;


        eam_completion.complete_work_order_generic(
                           x_wip_entity_id              =>  p_wip_entity_id,
                           x_rebuild_jobs               =>  l_rebuild_jobs,
                           x_transaction_type           =>  p_transaction_type,
                           x_transaction_date           =>  p_transaction_date,
                           x_user_id                    =>  p_user_id,
                           x_request_id                 =>  p_request_id,
                           x_application_id             =>  p_application_id,
                           x_program_id                 =>  p_program_id,
                           x_reconcil_code              =>  p_reconciliation_code,
                           x_actual_start_date          =>  l_actual_start_date,
                           x_actual_end_date            =>  l_actual_end_date,
                           x_actual_duration            =>  l_actual_duration,
                           x_inventory_item_info        =>  l_inventory_item_tbl,
                           x_shutdown_start_date        =>  l_shutdown_start_date,
                           x_shutdown_end_date          =>  l_shutdown_end_date,
                           x_commit                     =>  p_commit,
                           errCode                      =>  l_errCode,
                           errMsg                       =>  l_errMsg,
                           /* Added for addressing bug#5477819 Start */
                           x_attribute_category         =>  p_attributes_rec.p_attribute_category,
                           x_attribute1                 =>  p_attributes_rec.p_attribute1,
                           x_attribute2                 =>  p_attributes_rec.p_attribute2,
                           x_attribute3                 =>  p_attributes_rec.p_attribute3,
                           x_attribute4                 =>  p_attributes_rec.p_attribute4,
                           x_attribute5                 =>  p_attributes_rec.p_attribute5,
                           x_attribute6                 =>  p_attributes_rec.p_attribute6,
                           x_attribute7                 =>  p_attributes_rec.p_attribute7,
                           x_attribute8                 =>  p_attributes_rec.p_attribute8,
                           x_attribute9                 =>  p_attributes_rec.p_attribute9,
                           x_attribute10                =>  p_attributes_rec.p_attribute10,
                           x_attribute11                =>  p_attributes_rec.p_attribute11,
                           x_attribute12                =>  p_attributes_rec.p_attribute12,
                           x_attribute13                =>  p_attributes_rec.p_attribute13,
                           x_attribute14                =>  p_attributes_rec.p_attribute14,
                           x_attribute15                =>  p_attributes_rec.p_attribute15
                           /* Added for addressing bug#5477819 End */
                        );
        if l_errCode <> 0 then  -- there was an error

--            dbms_output.put_line('caught error in call to eam_completion.complete_work_order');
--	    dbms_output.put_line('errMsg: '||l_errMsg);
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.set_name('EAM', 'EAM_INTERNAL_ERROR');
        end if;
    end if;

    if (x_return_status = FND_API.G_RET_STS_ERROR) then
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(
            p_count     =>      x_msg_count,
            p_data      =>      x_msg_data);
    end if;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--        dbms_output.put_line('unexpected error :'||FND_MSG_PUB.Get);
--	dbms_output.put_line('unexpected error :'||FND_MESSAGE.get);
        ROLLBACK TO Complete_Work_Order_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_count     => x_msg_count,
            p_data      => x_msg_data);
    WHEN NO_DATA_FOUND THEN
--        dbms_output.put_line('unexpected error :'||FND_MSG_PUB.Get);
--	dbms_output.put_line('unexpected error :'||FND_MESSAGE.get);
--	dbms_output.put_line('no data found');
        ROLLBACK TO Complete_Work_Order_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_count     => x_msg_count,
            p_data      => x_msg_data);
    WHEN OTHERS THEN
--        dbms_output.put_line('unexpected error :'||FND_MSG_PUB.Get);
--	dbms_output.put_line('unexpected error :'||FND_MESSAGE.get);
        ROLLBACK TO Complete_Work_Order_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(
		G_PKG_NAME,
		l_api_name
	    );
        END IF;
	FND_MSG_PUB.Count_And_Get(
	    p_count 	=> x_msg_count,
	    p_data	=> x_msg_data);
END Complete_Work_Order;

 procedure complete_operation(
    p_api_version                  IN    NUMBER  :=1.0,
    p_init_msg_list                IN    VARCHAR2 := FND_API.G_FALSE,
    p_commit                       IN    VARCHAR2 := fnd_api.g_false,
    x_return_status                OUT NOCOPY   VARCHAR2,
    x_msg_count                    OUT NOCOPY   NUMBER,
    x_msg_data                     OUT NOCOPY   VARCHAR2,
    p_wip_entity_id                IN    NUMBER,
    p_operation_seq_num            IN    NUMBER,
    p_transaction_date             IN    DATE := SYSDATE,
    p_transaction_type             IN    NUMBER,
    p_actual_start_date            IN    DATE := null,
    p_actual_end_date              IN    DATE := null,
    p_actual_duration              IN    NUMBER := null,
    p_shutdown_start_date          IN    DATE := null,
    p_shutdown_end_date            IN    DATE := null,
    p_shutdown_duration            IN    NUMBER := null,
    p_reconciliation_code          IN    NUMBER := null,
    p_attribute_rec                IN    Attributes_Rec_Type
) IS

  l_api_name             CONSTANT VARCHAR(30) := 'complete_operation';
  l_api_version          CONSTANT NUMBER      := 1.0;
  l_return_status        VARCHAR2(250);
  l_error_msg_code       VARCHAR2(250);

  l_err_stage            VARCHAR2(250);
  l_err_stack            VARCHAR2(250);

  l_db_status            NUMBER;
  l_db_last_update_date  DATE;
  l_tran_type            NUMBER;
  l_open_acct_per_date   DATE;
  l_transaction_date	 DATE;
  l_actual_duration     NUMBER;
  l_actual_start_date   DATE;
  l_actual_end_date     DATE;
  l_shutdown_start_date         DATE ;
  l_shutdown_end_date             DATE ;
   l_shutdown_duration NUMBER;
  l_err_code	         NUMBER;
  l_err_msg	         VARCHAR2(1000);
  l_operation_completed  wip_operations.operation_completed%type;
  l_shutdown_type         wip_operations.shutdown_type%type;
  l_transaction_type    NUMBER;
  l_department_id       wip_operations.department_id%type;
  l_description         wip_operations.description%type;
  l_quantity_completed  wip_operations.quantity_completed%type;
  l_first_unit_start_date  wip_operations.first_unit_start_date%type;
  l_last_unit_completion_date  wip_operations.last_unit_completion_date%type;
  l_created_by            wip_operations.created_by%type;
  l_creation_date          wip_operations.creation_date%type;
  l_last_updated_by       wip_operations.last_updated_by%type;
  l_last_update_login     wip_operations.last_update_login%type;
  l_last_update_date       wip_operations.last_update_date%type;


  BEGIN
    SAVEPOINT Complete_Operation_PVT;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

----Begining of Transaction type and transaction date validation

if  (p_transaction_date is not null)  then

    if p_transaction_date > sysdate then

     FND_MESSAGE.set_name('EAM', 'EAM_TXN_LATER_THAN_TODAY');
     FND_MSG_PUB.Add;
     eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_TXN_LATER_THAN_TODAY');
     x_return_status := FND_API.G_RET_STS_ERROR;
     end if;
end if;
--   dbms_output.put_line ('past txn type ...');



      select
	  wo.department_id,
	  wo.operation_completed,
	  wo.shutdown_type,
	  wo.description,
	  wo.quantity_completed,
	  wo.first_unit_start_date,
	  wo.last_unit_completion_date,
	  wo.created_by,
	  wo.creation_date,
	  wo.last_updated_by,
	  wo.last_update_login,
	  wo.last_update_date
      into
      l_department_id,
      l_operation_completed,
      l_shutdown_type,
      l_description,
      l_quantity_completed,
	  l_first_unit_start_date,
	  l_last_unit_completion_date,
	  l_created_by,
	  l_creation_date,
	  l_last_updated_by,
	  l_last_update_login,
	  l_last_update_date
	from
	  wip_operations wo
	where
	  wip_entity_id = p_wip_entity_id and
	  operation_seq_num =p_operation_seq_num;


--Checking if the User wants to complete (transaction type =1) an already completed operation
-- or If the user wanted to uncomplete (transaction type =2) an already uncompleted Operation.
--Systen should return error.

if (p_operation_seq_num is not NULL)  THEN

    if (l_operation_completed='Y')  and (p_transaction_type =1)  then

        FND_MESSAGE.set_name('EAM', 'EAM_INVALID_TXN_TYPE');
        FND_MSG_PUB.Add;
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_INVALID_TXN_TYPE') ;
        x_return_status := FND_API.G_RET_STS_ERROR;

   elsif  ((l_operation_completed <> 'Y')  and (p_transaction_type =2))  then

        FND_MESSAGE.set_name('EAM', 'EAM_INVALID_TXN_TYPE');
        FND_MSG_PUB.Add;
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_INVALID_TXN_TYPE') ;
        x_return_status := FND_API.G_RET_STS_ERROR;

    end if;

end if;




    IF (p_operation_seq_num is  NULL) THEN
      l_transaction_type := null;
    ELSIF (l_operation_completed = 'Y') THEN
      -- uncomplete --
      l_transaction_type := 2;
   ELSE
      -- complete --
    l_transaction_type := 1;
    END IF;

----End of Transaction type and transaction date validation



---Begining of Actual start date, Actual End Date, Actual Duration Validation

             l_actual_start_date :=  p_actual_start_date;
             l_actual_end_date   :=  p_actual_end_date;
             l_actual_duration   :=  p_actual_duration;
--------------------------------------------------------------------------------
--------------------------------------------------------------------


--------------------------------------------------------------------------------
  if ((l_actual_start_date is not null) AND (l_actual_end_date is not null) )  then
    l_actual_duration:=round(24*(l_actual_end_date-l_actual_start_date),3);
       	--l_actual_duration := round(24 * (
      	 -- to_date(to_char(l_actual_end_date, 'DD-MON-YY HH24:MI:SS'),'DD-MON-YY HH24:MI:SS')
	-- - to_date(to_char(l_actual_start_date, 'DD-MON-YY HH24:MI:SS'),'DD-MON-YY HH24:MI:SS')), 3);
     if (p_actual_duration is not null) and (p_actual_duration <> l_actual_duration )  then
        FND_MESSAGE.set_name('EAM', 'EAM_INCORRECT_DURATION');
        FND_MSG_PUB.Add;
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_INCORRECT_DURATION') ;
        x_return_status := FND_API.G_RET_STS_ERROR;

     end if;
elsif  ((l_actual_duration is not null)  and (l_actual_start_date is not null))  then
       l_actual_end_date := ((p_actual_start_date) + (p_actual_duration / 24));


 elsif (( l_actual_duration is not null) and (l_actual_end_date is not null))   then
       l_actual_start_date := ( (l_actual_end_date) - (l_actual_duration / 24)  );

   end if;
---------------------------------------------------------------------------------

  if (l_actual_duration is not null) then
   if  l_actual_duration < 0 then
        FND_MESSAGE.set_name('EAM', 'EAM_NEGATIVE_DURATION');
        FND_MSG_PUB.Add;
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_NEGATIVE_DURATION') ;
        x_return_status := FND_API.G_RET_STS_ERROR;

       end if;
  end if;



    select nvl(min(period_start_date),sysdate+1)
         into l_open_acct_per_date
          from org_acct_periods
           where organization_id = (select organization_id from wip_entities where wip_entity_id=p_wip_entity_id)
            and open_flag = 'Y';

    if  (l_actual_start_date is not null) then

          if l_actual_end_date > sysdate then
         	 FND_MESSAGE.set_name('EAM', 'EAM_END_LATER_THAN_TODAY');
         	 FND_MSG_PUB.Add;
         	 eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_END_LATER_THAN_TODAY ') ;
         	 x_return_status := FND_API.G_RET_STS_ERROR;
          end if;

      	  if (p_transaction_date < l_open_acct_per_date) then
         	 FND_MESSAGE.set_name('EAM', 'EAM_MIN_OP_ACTUAL_START_DATE');
         	 FND_MSG_PUB.Add;
         	 eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_MIN_OP_ACTUAL_START_DATE') ;
         	 x_return_status := FND_API.G_RET_STS_ERROR;

    	  end if;

    end if;
-------------------------------------------------------------------------------
               l_shutdown_duration:=p_shutdown_duration;
               l_shutdown_start_date:= p_shutdown_start_date  ;
               l_shutdown_end_date:=p_shutdown_end_date  ;




--dbms_output.put_line ('shutdown point');
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
  if ((l_shutdown_start_date is not null) AND (l_shutdown_end_date is not null) )  then
l_shutdown_duration:=round(24*( l_shutdown_end_date-l_shutdown_start_date),3);
      --	l_shutdown_duration := round(24 * (
--	  to_date(to_char(l_actual_end_date, 'DD-MON-YY HH24:MI:SS'),'DD-MON-YY HH24:MI:SS')
--	- to_date(to_char(l_actual_start_date, 'DD-MON-YY HH24:MI:SS'),'DD-MON-YY HH24:MI:SS')), 3);
     if (p_shutdown_duration is not null) and (p_shutdown_duration <> l_shutdown_duration )  then
        FND_MESSAGE.set_name('EAM', 'EAM_INCORRECT_SHUT_DUR');
        FND_MSG_PUB.Add;
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_INCORRECT_SHUT_DUR') ;
        x_return_status := FND_API.G_RET_STS_ERROR;

     end if;
     elsif ((l_shutdown_duration is not null)  and (l_shutdown_start_date is not null))  then
       l_shutdown_end_date := ((p_shutdown_start_date) + (p_shutdown_duration / 24));

   elsif

    (( l_shutdown_duration is not null) and (l_shutdown_end_date is not null))   then
       l_shutdown_start_date := ( (l_shutdown_end_date) - (l_shutdown_duration / 24)  );

   end if;
---------------------------------------------------------------------------------

  if (l_shutdown_duration is not null) then
   	if  l_shutdown_duration < 0 then
       		FND_MESSAGE.set_name('EAM', 'EAM_SHUTDOWN_DUR_NEGATIVE');
        	FND_MSG_PUB.Add;
        	eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_SHUTDOWN_DUR_NEGATIVE') ;
        	x_return_status := FND_API.G_RET_STS_ERROR;

       end if;
  end if;

    if  (l_shutdown_end_date is not null) then

          if l_shutdown_end_date > sysdate then
         	 FND_MESSAGE.set_name('EAM', 'EAM_SHUT_GREATER_SYSDATE');
         	 FND_MSG_PUB.Add;
         	 eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_SHUT_GREATER_SYSDATE ') ;
         	 x_return_status := FND_API.G_RET_STS_ERROR;
          end if;


    end if;
-------------------------------------------------------------------------------



      --   dbms_output.put_line ('p_shutdown_end_date > sysdate line 266');


	if ((l_shutdown_start_date is not null) and (l_shutdown_end_date is not null)
        and (l_shutdown_end_date < l_shutdown_start_date)) then
         	 FND_MESSAGE.set_name('EAM', 'EAM_SHUT_END_BEFORE_START');
         	 FND_MSG_PUB.Add;
         	 eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_SHUT_END_BEFORE_START ') ;


         	 x_return_status := FND_API.G_RET_STS_ERROR;

 	end if;

/*

dbms_output.put_line ('Work Order = '||p_wip_entity_id);
dbms_output.put_line ('Operation Seq Num = '||p_operation_seq_num);
dbms_output.put_line ('Transaction_type = '||l_transaction_type);
dbms_output.put_line ('Transaction Date = '||p_transaction_date);
dbms_output.put_line ('Actual Start Date = '||l_actual_start_date);
dbms_output.put_line ('Actual End Date = '||l_actual_end_date);
dbms_output.put_line ('Duration   = '||	l_actual_duration);
dbms_output.put_line ('Shutdown start Date  = '||	l_shutdown_start_date);
dbms_output.put_line ('Shutdown End Date = '||l_shutdown_end_date);
dbms_output.put_line ('Reconcilation Code = '||p_reconciliation_code);

*/


if (x_return_status = FND_API.G_RET_STS_SUCCESS)  then
    eam_op_comp.op_comp(
	x_err_code		=>	l_err_code,
	x_err_msg		=>	l_err_msg,

	p_wip_entity_id 	=>	p_wip_entity_id,
	p_operation_seq_num 	=>	p_operation_seq_num,
	p_transaction_type 	=>	l_transaction_type,
	p_transaction_date	=>	p_transaction_date,
	p_actual_start_date	=>	l_actual_start_date,
	p_actual_end_date	=>	l_actual_end_date,
	p_actual_duration	=>	l_actual_duration,
	p_shutdown_start_date	=>	l_shutdown_start_date,
	p_shutdown_end_date	=>	l_shutdown_end_date,
	p_reconciliation_code	=>	p_reconciliation_code,
	p_attribute_category	=>   p_attribute_rec.p_attribute_category,
	p_attribute1		=>	p_attribute_rec.p_attribute1,
	p_attribute2		=>	p_attribute_rec.p_attribute2,
	p_attribute3		=>	p_attribute_rec.p_attribute3,
	p_attribute4		=>	p_attribute_rec.p_attribute4,
	p_attribute5		=>	p_attribute_rec.p_attribute5,
	p_attribute6		=>	p_attribute_rec.p_attribute6,
	p_attribute7		=>	p_attribute_rec.p_attribute7,
	p_attribute8		=>	p_attribute_rec.p_attribute8,
	p_attribute9		=>	p_attribute_rec.p_attribute9,
	p_attribute10		=>	p_attribute_rec.p_attribute10,
	p_attribute11		=>	p_attribute_rec.p_attribute11,
	p_attribute12		=>	p_attribute_rec.p_attribute12,
	p_attribute13		=>	p_attribute_rec.p_attribute13,
	p_attribute14		=>	p_attribute_rec.p_attribute14,
	p_attribute15		=>	p_attribute_rec.p_attribute15
    );

--  call eam_op_comp.op_comp to
-- insert into eam_op_completion_txns, update wip_operations

    if l_err_code = 1 then  -- there was an error
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Add;
        end if;
    end if;

   if (x_return_status = FND_API.G_RET_STS_ERROR) then
        FND_MSG_PUB.Count_And_Get(
            p_count     =>      x_msg_count,
            p_data      =>      x_msg_data);
    end if;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Complete_Operation_PVT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get(
	    p_count	=> x_msg_count,
	    p_data	=> x_msg_data);
    WHEN OTHERS THEN
	ROLLBACK TO Complete_Operation_PVT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg(
		G_PKG_NAME,
		l_api_name
	    );
        END IF;
	FND_MSG_PUB.Count_And_Get(
	    p_count 	=> x_msg_count,
	    p_data	=> x_msg_data);



  END complete_operation;


  procedure SET_MANUAL_REB_FLAG(p_wip_entity_id        IN  NUMBER,
                                p_organization_id      IN  NUMBER,
                                p_manual_rebuild_flag  IN  VARCHAR2,
                                x_return_status        OUT NOCOPY VARCHAR2)
  IS

    l_count NUMBER := 0;

  BEGIN

    -- Validate WIP Entity Id
    select count(*) into l_count from wip_discrete_jobs where
      wip_entity_id = p_wip_entity_id and
      organization_id = p_organization_id;
    if l_count <> 1 then
      x_return_status := 'E';
      return;
    end if;

    -- Set Manual Rebuild Flag
    IF p_manual_rebuild_flag is not null then
      update wip_discrete_jobs set manual_rebuild_flag = p_manual_rebuild_flag
        where wip_entity_id = p_wip_entity_id and
        organization_id = p_organization_id;
    END IF;

    x_return_status := 'S';

    return;

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := 'E';

  END SET_MANUAL_REB_FLAG;


  procedure SET_OWNING_DEPARTMENT(p_wip_entity_id      IN  NUMBER,
                                  p_organization_id    IN  NUMBER,
                                  p_owning_department  IN  NUMBER,
                                  x_return_status      OUT NOCOPY VARCHAR2)

  IS

    l_count NUMBER;

  BEGIN

    -- Validate WIP Entity Id
    select count(*) into l_count from wip_discrete_jobs where
      wip_entity_id = p_wip_entity_id and
      organization_id = p_organization_id;
    if l_count <> 1 then
      x_return_status := 'E';
      return;
    end if;

    -- Validate owning department
    select count(*) into l_count from bom_departments where
      department_id = p_owning_department
      and organization_id = p_organization_id;
    if l_count <> 1 then
      x_return_status := 'E';
      return;
    end if;

    -- Set Owning Department
    IF p_owning_department is not null then
      update wip_discrete_jobs set owning_department = p_owning_department
        where wip_entity_id = p_wip_entity_id and
        organization_id = p_organization_id;
    END IF;

    x_return_status := 'S';

    return;

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := 'E';

  END SET_OWNING_DEPARTMENT;


/*********************************************************************
  * Procedure     : Update_EWOD
  * Parameters IN : organization Id
  *                 group_id
  *                 user_defined_status_id
  * Parameters OUT NOCOPY:
  *   errbuf         error messages
  *   retcode        return status. 0 for success, 1 for warning and 2 for error.
  * Purpose       : Procedure will update the database with the user_defined_status_id passed.
  *                 This procedure was added for a WIP bug 6718091
***********************************************************************/

PROCEDURE Update_EWOD
        (p_group_id           IN  NUMBER,
	 p_organization_id    IN  NUMBER,
	 p_new_status            IN  NUMBER,
         ERRBUF               OUT NOCOPY VARCHAR2 ,
         RETCODE              OUT NOCOPY VARCHAR2
         )
        IS

        BEGIN
	update eam_work_order_details
	SET                      user_defined_status_id		=  p_new_status
                               , program_update_date		=  SYSDATE
                               , last_update_date   	        =  SYSDATE
                               , last_updated_by		=  FND_GLOBAL.user_id
                               , last_update_login		=  FND_GLOBAL.login_id
                          WHERE  organization_id		=  p_organization_id
                          AND WIP_ENTITY_ID IN (SELECT wdct.WIP_ENTITY_ID
                                                FROM WIP_DJ_CLOSE_TEMP wdct, wip_discrete_jobs wdj
                                                WHERE wdct.ORGANIZATION_ID = p_organization_id
                                                AND wdct.GROUP_ID = p_group_id
						and wdj.wip_entity_id = wdct.WIP_ENTITY_ID
						and wdj.status_type = WIP_CONSTANTS.PEND_CLOSE);


         EXCEPTION
          WHEN others THEN
             retcode := 2; -- error
             errbuf := SQLERRM;

END Update_EWOD;

/*********************************************************************
  * Procedure     : RAISE_WORKFLOW_STATUS_PEND_CLS
  * Parameters IN : group_id
  *                 user_defined_status_id
  * Parameters OUT NOCOPY:
  *   errbuf         error messages
  *   retcode        return status. 0 for success, 1 for warning and 2 for error.
  *  Purpose       : Procedure will update workflow status to pending close for all wip_entity_ids provided in the group_id.
  *                 This procedure was added for a WIP bug 6718091
***********************************************************************/
PROCEDURE RAISE_WORKFLOW_STATUS_PEND_CLS
(p_group_id              IN  NUMBER,
 p_new_status            IN  NUMBER,
 ERRBUF               OUT NOCOPY VARCHAR2 ,
 RETCODE              OUT NOCOPY VARCHAR2 )

        IS

              l_return_status                VARCHAR2(1);

              TYPE WORKORDER_REC IS RECORD
                   (wip_entity_id			NUMBER,
                     organization_id                    NUMBER,
                     wip_entity_name			VARCHAR2(240),
                     old_system_status			NUMBER,
                     old_wo_status                      NUMBER,
                     workflow_type                      NUMBER
                    );

                CURSOR workorders
                 IS
                 SELECT wdj.wip_entity_id, we.wip_entity_name,
                        wdj.status_type,   wdj.organization_id, ewod.user_defined_status_id, ewod.workflow_type
                 FROM wip_discrete_jobs wdj, wip_dj_close_temp wdct, eam_work_order_details ewod, wip_entities we
                 WHERE wdct.group_id	   = p_group_id
                 and wdct.wip_entity_id    = wdj.wip_entity_id
                 and wdct.organization_id  = wdj.organization_id
                 and wdj.wip_entity_id     = ewod.wip_entity_id
                 and wdj.organization_id   = ewod.organization_id
                 and wdj.wip_entity_id     = we.wip_entity_id
                 and wdj.organization_id   = we.organization_id
		 and we.entity_type	   = WIP_CONSTANTS.EAM;


        BEGIN

            FOR l_workorders_rec IN workorders LOOP

               EAM_JOBCLOSE_PRIV.RAISE_WORKFLOW_STATUS_CHANGED
                    (p_wip_entity_id	        =>   l_workorders_rec.wip_entity_id,
                      p_wip_entity_name		=>   l_workorders_rec.wip_entity_name,
                      p_organization_id		=>   l_workorders_rec.organization_id,
                      p_new_status		=>   p_new_status,
                      p_old_system_status	=>   l_workorders_rec.status_type,
                      p_old_wo_status		=>   l_workorders_rec.user_defined_status_id,
                      p_workflow_type           =>   l_workorders_rec.workflow_type,
                      x_return_status           =>   l_return_status
                      );

                    IF (NVL(l_return_status,'S') <> 'S') THEN
                        RETCODE := 2;
                        errbuf := SQLERRM;
                        RETURN;
                    END IF;

                EAM_TEXT_UTIL.PROCESS_WO_EVENT
                   (
                        p_event				=> 'UPDATE',
                        p_wip_entity_id			=>l_workorders_rec.wip_entity_id,
                        p_organization_id		=>l_workorders_rec.organization_id,
                        p_last_update_date		=> SYSDATE,
                        p_last_updated_by		=> FND_GLOBAL.user_id,
                        p_last_update_login		=>FND_GLOBAL.login_id
                   );


                END LOOP;

END   RAISE_WORKFLOW_STATUS_PEND_CLS;

END EAM_WorkOrderTransactions_PUB;

/
