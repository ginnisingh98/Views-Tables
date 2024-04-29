--------------------------------------------------------
--  DDL for Package Body CSD_HV_WIP_JOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_HV_WIP_JOB_PVT" as
/* $Header: csdvhvjb.pls 120.30.12010000.19 2010/06/07 23:46:25 swai ship $ */
-- Start of Comments
-- Package name     : CSD_HV_WIP_JOB_PVT
-- Purpose          : This package is used for High Volume Repair Execution flow
--
--
-- History          : 05/01/2005, Created by Shiv Ragunathan
-- History          :
-- History          :
-- NOTE             :
-- End of Comments


-- Define Global Variable --
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSD_HV_WIP_JOB_PVT';

-- swai: bug 6995498/7182047 wrapper function to get the default item revision
-- Depending on the transaction type, check the corresponding profile option
-- and return null if the profile is No.
-- Transaction types are 'MAT_ISSUE' and 'JOB_COMP'.  Passing null for
-- transaction type will always return a default from bom_revsions API.
FUNCTION get_default_item_revision
(
    p_org_id                                  IN         NUMBER,
    p_inventory_item_id                       IN         NUMBER,
    p_transaction_date                        IN         DATE,
    p_mat_transaction_type                    IN         VARCHAR2 := null
) RETURN VARCHAR2
IS
    -- variables --
    l_revision    VARCHAR2(3) := null;
    l_get_default VARCHAR2(1) := FND_API.G_TRUE;
BEGIN
    if (p_mat_transaction_type = 'MAT_ISSUE') then -- material issue
        --swai: bug 6654197 - allow user to specify revision based on profile option
        if (nvl(fnd_profile.value('CSD_DEF_CUR_REVISION_MTL_TXN'), 'Y') = 'N' )  then
            l_get_default := FND_API.G_FALSE;
        end if;
    elsif (p_mat_transaction_type = 'JOB_COMP') then  -- job completion
        -- swai: bug 6654197 - allow user to specify revision based on profile option
        if (nvl(fnd_profile.value('CSD_DEF_CUR_REVISION_JOB_COMP'), 'Y') = 'N' ) then
            l_get_default := FND_API.G_FALSE;
        end if;
    end if;
    if (l_get_default = FND_API.G_TRUE) then
        l_revision :=   bom_revisions.get_item_revision_fn
               ('EXCLUDE_OPEN_HOLD',        -- eco_status
                'ALL',                      -- examine_type
                p_org_id,                   -- org_id
                p_inventory_item_id,        -- item_id
                p_transaction_date          -- rev_date
               ) ;
    end if;
    return l_revision;
END get_default_item_revision;

FUNCTION get_pending_quantity( p_wip_entity_id NUMBER,
                               p_operation_seq_num NUMBER,
                               p_resource_seq_num NUMBER,
                               p_primary_uom VARCHAR2 )
                                RETURN NUMBER IS


Cursor get_pending_qty_uom is
 select wcti.transaction_quantity,
        wcti.transaction_uom from
           wip_cost_txn_interface wcti
                  where
                   wcti.wip_entity_id = p_wip_entity_id and
                   wcti.operation_seq_num = p_operation_seq_num and
                   wcti.resource_seq_num  = p_resource_seq_num and
                  process_phase = 1 and
                  process_status = 1;

l_sum_pending_qty NUMBER := 0;
l_conversion_rate NUMBER;
l_primary_qty NUMBER;
BEGIN

FOR pending_qty_rec in get_pending_qty_uom
LOOP



        l_conversion_rate :=
          inv_convert.inv_um_convert(
            item_id       => 0,
            precision     => 38,
            from_quantity => 1,
            from_unit     => p_primary_uom,
            to_unit       => pending_qty_rec.transaction_uom ,
            from_name     => NULL,
            to_name       => NULL);



        -- perform UOM conversion
        l_primary_qty := pending_qty_rec.transaction_quantity/l_conversion_rate;

l_sum_pending_qty := l_sum_pending_qty + l_primary_qty;

END LOOP;


RETURN l_sum_pending_qty;


END;


FUNCTION ml_error_exists( p_group_id NUMBER )
                                RETURN BOOLEAN IS

lc_error_process_status CONSTANT NUMBER  := 3;


Cursor check_ml_interface_errors IS
  select 'exists' from wip_job_schedule_interface where
  group_id = p_group_id
  and process_status = lc_error_process_status;

l_error_exists VARCHAR2(6);

BEGIN

    open  check_ml_interface_errors ;
    fetch check_ml_interface_errors  into l_error_exists;
    close check_ml_interface_errors ;

    If l_error_exists is null then
        RETURN FALSE;
    else
        RETURN TRUE;
    end if;

END;

FUNCTION txn_int_error_exists( p_transaction_header_id NUMBER )
                                RETURN BOOLEAN IS

lc_error_process_status CONSTANT NUMBER  := 3;


Cursor check_txn_int_interface_errors IS
  select 'exists' from mtl_transactions_interface where
  transaction_header_id = p_transaction_header_id
  and process_flag = lc_error_process_status;

l_error_exists VARCHAR2(6);

BEGIN

    open  check_txn_int_interface_errors ;
    fetch check_txn_int_interface_errors  into l_error_exists;
    close check_txn_int_interface_errors ;

    If l_error_exists is null then
        RETURN FALSE;
    else
        RETURN TRUE;
    end if;

END;


-- this procedure adds any errors from the wip_interface_errors table
-- to the fnd_message stack.
-- assumption: each group has one type of transaction (op, material, resource)
--
PROCEDURE add_wip_interface_errors(p_group_id NUMBER, p_txn_type NUMBER) IS
   -- CONSTANTS --
   lc_txn_type_operations CONSTANT NUMBER  := 1;
   lc_txn_type_materials  CONSTANT NUMBER  := 2;
   lc_txn_type_resources  CONSTANT NUMBER  := 3;

   -- LOCAL VARIABLES --
   l_resource_name VARCHAR2(10);
   l_item_name VARCHAR2(10);

   -- CURSORS --
   Cursor c_wip_interface_errors is
       select wie.error,
        wie.error_type,
        wie.error_type_meaning,
        wjsi.wip_entity_id,
        wjsi.organization_id,
        we.wip_entity_name,
        wjdi.operation_seq_num,
        wjdi.inventory_item_id_new,
        wjdi.resource_id_new
      from
        wip_interface_errors_v wie,
        wip_job_schedule_interface wjsi,
        wip_entities we,
        wip_job_dtls_interface wjdi
      where wie.interface_id = wjsi.interface_id
        and we.wip_entity_id = wjsi.wip_entity_id
        and wjsi.group_id = wjdi.group_id
        and wjsi.group_id = p_group_id;

   Cursor c_resource_name (p_resource_id_new number) is
      select bom.resource_code
      from   bom_resources bom
      where  bom.resource_id = p_resource_id_new;

   Cursor c_item_name (p_inventory_item_id_new number,
                       p_organization_id number) is
      select mtl.concatenated_segments
      from   mtl_system_items_kfv mtl
      where  mtl.inventory_item_id = p_inventory_item_id_new
        and  mtl.organization_id = p_organization_id;
BEGIN

   FOR wip_interface_rec in c_wip_interface_errors
   LOOP
      IF (p_txn_type = lc_txn_type_operations) THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_WIP_INTERFACE_OP_ERR');

      ELSIF (p_txn_type = lc_txn_type_materials) THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_WIP_INTERFACE_MTL_ERR');
         open c_item_name(wip_interface_rec.inventory_item_id_new,
                          wip_interface_rec.organization_id);
         fetch c_item_name into l_item_name;
         close c_item_name;
         FND_MESSAGE.SET_TOKEN('ITEM_NAME', l_item_name);

      ELSIF (p_txn_type = lc_txn_type_resources) THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_WIP_INTERFACE_RES_ERR');
         open c_resource_name(wip_interface_rec.resource_id_new);
         fetch c_resource_name into l_resource_name;
         close c_resource_name;
         FND_MESSAGE.SET_TOKEN('RES_NAME', l_resource_name);
      END IF;

      FND_MESSAGE.SET_TOKEN('JOB_NAME', wip_interface_rec.wip_entity_name);
      FND_MESSAGE.SET_TOKEN('OP_SEQ', wip_interface_rec.operation_seq_num);
      FND_MESSAGE.SET_TOKEN('ERROR_TYPE', wip_interface_rec.error_type_meaning);
      FND_MESSAGE.SET_TOKEN('ERROR_MSG', wip_interface_rec.error);
      FND_MSG_PUB.ADD;
   END LOOP;
END add_wip_interface_errors;

-- This procedure checks if the specified Job name exists in the
-- specified organization. It checks if it exists in
-- wip_entities or wip_job_schedule_interface table.
-- If it exists, then an Error status is returned.
-- If it does not exist in either of the tables, then
-- a Sucess status is returned.
-- This procedure is used whenever a job_name is generated, to confirm that
-- the newly generated job_name does not already exist and hence can be
-- used to submit it to WIP Mass Load.


PROCEDURE validate_job_name
(
   p_job_name        IN       VARCHAR2,
   p_organization_id       IN       NUMBER,
   x_return_status         OUT NOCOPY  VARCHAR2
)
IS

      -- Used to check the existence of the Job_name for the specified organizization,
      l_job_count                     NUMBER := 0;

BEGIN


      Select count(*) into l_job_count from wip_entities where wip_entity_name = p_job_name and
            organization_id = p_organization_id ;

      If l_job_count = 0 Then

      -- Job does not exist in WIP_entities, check if it is already inserted in the interface table by another
      -- process and so may be in the process of getting into WIP.
      -- If it exists, do not want to use this job name, so return Error

            Select count(*) into l_job_count from wip_job_schedule_interface where job_name = p_job_name and
                organization_id = p_organization_id ;

             IF l_job_count = 0 THEN

            -- Generated job name does exist either in the interface or wip_entities table,
            -- Success is returned

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         RETURN;

      ELSE

         -- Job exists in wip_job_schedule_interface table, hence return Error status

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;


      END IF;


   ELSE

      -- Job exists in wip_entities table, hence return Error status

      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;


   END IF;



END validate_job_name;


-- This procedure generates a job name by appending a sequence generated number
-- to the passed in Job_Prefix
-- It Validates that the generated job name is unique for the specified organization,
-- It keeps looping and appending the subsequent sequence generated number, till a
-- unique Job name is generated


PROCEDURE generate_job_name
(
      p_job_prefix            IN       VARCHAR2,
      p_organization_id             IN       NUMBER,
      x_job_name                    OUT NOCOPY  VARCHAR2
)
IS

   l_return_status VARCHAR2(1);

BEGIN

   Loop

      -- generate the Job Name by appending a sequence generated number to the passed in
      -- job_prefix

            Select p_job_prefix || TO_CHAR( CSD_JOB_NAME_S.NEXTVAL ) into
            x_job_name From Dual;


            -- Check if the job name generated is unique for the specified organization,
      -- if not loop around till a unique job name is generated

      Validate_job_name     ( p_job_name      => x_job_name,
                  p_organization_id  => p_organization_id,
                  x_return_status    => l_return_status ) ;

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

         -- Generated job name does not exist both in the interface and wip_entities table, so exit the loop

         exit;

         END IF;


   End Loop;

END generate_job_name;


-- This procedure accepts job header, bills and routing information and inserts it into
-- WIP_JOB_SCHEDULE_INTERFACE table.

PROCEDURE insert_job_header
(
      p_job_header_rec           IN          wip_job_schedule_interface%ROWTYPE,
      x_return_status               OUT   NOCOPY   VARCHAR2
)
IS

      -- Job Record to hold the Job header, bills and routing information being inserted
      -- into wip_job_schedule_interface

   l_job_header_rec                wip_job_schedule_interface%ROWTYPE := p_job_header_rec;


      -- variables used for FND_LOG debug messages

      l_debug_level                   NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      l_proc_level                    NUMBER  := FND_LOG.LEVEL_PROCEDURE;
      l_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_wip_job_pvt.insert_job_header.';


      -- Constants Used for Inserting into wip_job_schedule_interface,
      -- These are the values needed for WIP Mass Load to pick up the records

      -- Indicates that the process Phase is Validation
      lc_validation_phase        CONSTANT    NUMBER := 2;

      -- Indicates that the process_status is Pending
      lc_pending_status       CONSTANT NUMBER := 1;

      -- Source Code Value of 'Depot_Repair'
      lc_depot_repair_source_code   CONSTANT VARCHAR2(30) :=   'DEPOT_REPAIR';

      -- Depot repair Application Id passed as source_line_id
      lc_depot_app_source_line_id   CONSTANT NUMBER := 512;




BEGIN


      IF ( l_proc_level >= l_debug_level ) then
         FND_LOG.STRING(   l_proc_level,
                  l_mod_name||'begin',
                  'Entering procedure insert_job_header' );
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Populate the record l_job_header_rec


      -- Populate the constant values

      l_job_header_rec.process_phase := lc_validation_phase;
      l_job_header_rec.process_status := lc_pending_status;
      l_job_header_rec.source_code := lc_depot_repair_source_code;
      l_job_header_rec.source_line_id := lc_depot_app_source_line_id ;


      -- Populate the row who columns

      l_job_header_rec.creation_date := SYSDATE;
      l_job_header_rec.last_update_date := SYSDATE;
      l_job_header_rec.created_by := fnd_global.user_id;
      l_job_header_rec.last_updated_by := fnd_global.user_id;
      l_job_header_rec.last_update_login := fnd_global.login_id;


   --insert into table wip_job_schedule_interface
      BEGIN
         INSERT INTO wip_job_schedule_interface
         (
         wip_entity_id,
         interface_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         load_type,
         process_phase,
         process_status,
         group_id,
         header_id,
         source_code,
          source_line_id,
         job_name,
         organization_id,
         status_type,
         first_unit_start_date,
         last_unit_completion_date,
         completion_subinventory,
         completion_locator_id,
         start_quantity,
         net_quantity,
         class_code,
         primary_item_id,
         bom_reference_id,
         routing_reference_id,
         alternate_routing_designator,
         alternate_bom_designator
         )
         VALUES
         (
         l_job_header_rec.wip_entity_id,
             l_job_header_rec.interface_id,
         l_job_header_rec.last_update_date,
         l_job_header_rec.last_updated_by,
         l_job_header_rec.creation_date,
         l_job_header_rec.created_by,
         l_job_header_rec.last_update_login,
         l_job_header_rec.load_type,
         l_job_header_rec.process_phase,
         l_job_header_rec.process_status,
         l_job_header_rec.group_id,
         l_job_header_rec.header_id,
         l_job_header_rec.source_code,
      l_job_header_rec.source_line_id,
         l_job_header_rec.job_name,
         l_job_header_rec.organization_id,
         l_job_header_rec.status_type,
         l_job_header_rec.first_unit_start_date,
            l_job_header_rec.last_unit_completion_date,
         l_job_header_rec.completion_subinventory,
         l_job_header_rec.completion_locator_id,
         l_job_header_rec.start_quantity,
         l_job_header_rec.net_quantity,
         l_job_header_rec.class_code,
         l_job_header_rec.primary_item_id,
         l_job_header_rec.bom_reference_id,
         l_job_header_rec.routing_reference_id,
         l_job_header_rec.alternate_routing_designator,
         l_job_header_rec.alternate_bom_designator
         );
      EXCEPTION
         WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_JOB_HEADER_INSERT_ERR');
               FND_MESSAGE.SET_TOKEN('JOB_NAME', l_job_header_rec.job_name );
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;
      END;


      IF ( l_proc_level >= l_debug_level ) then
         FND_LOG.STRING(   l_proc_level,
                  l_mod_name||'end',
                  'Leaving procedure insert_job_header');
      END IF;


END insert_job_header;


-- This procedure accepts job details information and inserts it into
-- wip_job_dtls_interface table.

PROCEDURE insert_job_details
(
      p_job_details_rec          IN          wip_job_dtls_interface%ROWTYPE,
      x_return_status               OUT   NOCOPY   VARCHAR2
)
IS

      -- Job Record to hold the Job Details information being inserted
      -- into wip_job_dtls_interface

       l_job_details_rec                wip_job_dtls_interface%ROWTYPE := p_job_details_rec;


      -- variables used for FND_LOG debug messages

      l_debug_level                   NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      l_proc_level                    NUMBER  := FND_LOG.LEVEL_PROCEDURE;
      l_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_wip_job_pvt.insert_job_header.';


      -- Constants Used for Inserting into wip_job_schedule_interface,
      -- These are the values needed for WIP Mass Load to pick up the records

      -- Indicates that the process Phase is Validation
      lc_validation_phase        CONSTANT    NUMBER := 2;

      -- Indicates that the process_status is Pending
      lc_pending_status       CONSTANT NUMBER := 1;

    --   lc_change_type CONSTANT                  NUMBER := 3;





BEGIN

-- dbms_output.put_line('Resource Seq Num is ' || l_job_details_rec.resource_seq_num );

-- dbms_output.put_line('usage_rate_or_amount is ' || l_job_details_rec.usage_rate_or_amount );

      IF ( l_proc_level >= l_debug_level ) then
         FND_LOG.STRING(   l_proc_level,
                  l_mod_name||'begin',
                  'Entering procedure insert_job_header' );
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Populate the record l_job_header_rec


      -- Populate the constant values

      l_job_details_rec.process_phase := lc_validation_phase;
      l_job_details_rec.process_status := lc_pending_status;
    --   l_job_details_rec.substitution_type := lc_change_type;

      -- Populate the row who columns

      l_job_details_rec.creation_date := SYSDATE;
      l_job_details_rec.last_update_date := SYSDATE;
      l_job_details_rec.created_by := fnd_global.user_id;
      l_job_details_rec.last_updated_by := fnd_global.user_id;
      l_job_details_rec.last_update_login := fnd_global.login_id;


   BEGIN

    INSERT INTO wip_job_dtls_interface
       (last_updated_by,
        last_update_date,
        last_update_login,
        created_by,
        creation_date,
        date_required,
        start_date,
        group_id,
        parent_header_id,
        inventory_item_id_old,
        inventory_item_id_new,
        resource_id_old,
        resource_id_new,
        resource_seq_num,
        load_type,
        mrp_net_flag,
        operation_seq_num,
        organization_id,
        process_phase,
        process_status,
   --     quantity_issued,
        quantity_per_assembly,
        required_quantity,
        uom_code,
        usage_rate_or_amount,
        assigned_units,
        wip_entity_id,
        wip_supply_type,
        autocharge_type,
        basis_type,
        completion_date,
        scheduled_flag,
        standard_rate_flag,
        substitution_type,
        supply_subinventory,
        supply_locator_id, --bug8465719
        -- swai: add columns for operations
        backflush_flag,
        count_point_type,
        department_id,
        first_unit_completion_date,
        first_unit_start_date,
        last_unit_completion_date,
        last_unit_start_date,
        minimum_transfer_quantity,
        standard_operation_id,
        description
        )
        Values
        (
            l_job_details_rec.last_updated_by,
            l_job_details_rec.last_update_date,
            l_job_details_rec.last_update_login,
            l_job_details_rec.created_by,
            l_job_details_rec.creation_date, -- sysdate,
            l_job_details_rec.date_required,
            l_job_details_rec.start_date,
            l_job_details_rec.group_id,
            l_job_details_rec.parent_header_id,
            l_job_details_rec.inventory_item_id_old,
            l_job_details_rec.inventory_item_id_new, -- 'WIP Completion',
            l_job_details_rec.resource_id_old,
            l_job_details_rec.resource_id_new,
            l_job_details_rec.resource_seq_num,
            l_job_details_rec.load_type,
            l_job_details_rec.mrp_net_flag,
            l_job_details_rec.operation_seq_num,
            l_job_details_rec.organization_id,
            l_job_details_rec.process_phase,
            l_job_details_rec.process_status,
        --    l_job_details_rec.quantity_issued,
        --    null,
            l_job_details_rec.quantity_per_assembly,
            l_job_details_rec.required_quantity,
            l_job_details_rec.uom_code,
            l_job_details_rec.usage_rate_or_amount,
            l_job_details_rec.assigned_units,
            l_job_details_rec.wip_entity_id,
            l_job_details_rec.wip_supply_type,
            l_job_details_rec.autocharge_type,
            l_job_details_rec.basis_type,
            l_job_details_rec.completion_date,
            l_job_details_rec.scheduled_flag,
            l_job_details_rec.standard_rate_flag,
            l_job_details_rec.substitution_type,
            l_job_details_rec.supply_subinventory,
            l_job_details_rec.supply_locator_id, --bug#8465719
            -- swai: add columns for operations
            l_job_details_rec.backflush_flag,
            l_job_details_rec.count_point_type,
            l_job_details_rec.department_id,
            l_job_details_rec.first_unit_completion_date,
            l_job_details_rec.first_unit_start_date,
            l_job_details_rec.last_unit_completion_date,
            l_job_details_rec.last_unit_start_date,
            l_job_details_rec.minimum_transfer_quantity,
            l_job_details_rec.standard_operation_id,
            l_job_details_rec.description
            );


      EXCEPTION
         WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_JOB_DETAILS_INSERT_ERR');
               FND_MESSAGE.SET_TOKEN('JOB_NAME', l_job_details_rec.wip_entity_id);
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;
      END;


      IF ( l_proc_level >= l_debug_level ) then
         FND_LOG.STRING(   l_proc_level,
                  l_mod_name||'end',
                  'Leaving procedure insert_job_header');
      END IF;


END insert_job_details;


PROCEDURE insert_transactions_header
(
      p_transactions_interface_rec           IN          mtl_transactions_interface%ROWTYPE,
      x_return_status               OUT   NOCOPY   VARCHAR2
)
IS

      -- Job Record to hold the Job Details information being inserted
      -- into wip_job_dtls_interface

       l_transactions_interface_rec                mtl_transactions_interface%ROWTYPE := p_transactions_interface_rec;


      -- constant used for FND_LOG debug messages

      lc_mod_name    CONSTANT                 VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.insert_transactions_header.';


      -- Constants Used for Inserting into mtl_transactions_interface,

         lc_concurrent_mode           CONSTANT    NUMBER := 1;
         lc_yes_process_flag          CONSTANT    NUMBER := 1;




BEGIN


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering procedure insert_job_header' );
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;




      -- Populate the constant values


      l_transactions_interface_rec.transaction_mode    := lc_concurrent_mode;
      l_transactions_interface_rec.process_flag        := lc_yes_process_flag;

      -- Populate the row who columns

      l_transactions_interface_rec.creation_date := SYSDATE;
      l_transactions_interface_rec.last_update_date := SYSDATE;
      l_transactions_interface_rec.created_by := fnd_global.user_id;
      l_transactions_interface_rec.last_updated_by := fnd_global.user_id;
      l_transactions_interface_rec.last_update_login := fnd_global.login_id;


   --insert into table mtl_transactions_interface
   BEGIN

    INSERT INTO mtl_transactions_interface
       (last_updated_by,
        last_update_date,
        last_update_login,
        created_by,
        creation_date,
        transaction_header_id,
        source_code,
        completion_transaction_id,
        inventory_item_id,
        subinventory_code,
        locator_id,
        transaction_quantity,
        transaction_uom,
        primary_quantity,
        transaction_date,
        organization_id,
        transaction_source_id,
        transaction_source_type_id,
        transaction_type_id,
        wip_entity_type,
        operation_seq_num,
        revision,
        transaction_mode,
        process_flag,
        source_header_id,
        source_line_id,
        transaction_interface_id,
        reason_id, -- swai: bug 6841113
        final_completion_flag
        )
        Values
        (
            l_transactions_interface_rec.last_updated_by,
            l_transactions_interface_rec.last_update_date,
            l_transactions_interface_rec.last_update_login,
            l_transactions_interface_rec.created_by,
            l_transactions_interface_rec.creation_date, -- sysdate,
            l_transactions_interface_rec.transaction_header_id,
            l_transactions_interface_rec.source_code, -- 'WIP Issue',
            l_transactions_interface_rec.completion_transaction_id,
            l_transactions_interface_rec.inventory_item_id, --8229,
            l_transactions_interface_rec.subinventory_code,
            l_transactions_interface_rec.locator_id,
            l_transactions_interface_rec.transaction_quantity, -- 1,
            l_transactions_interface_rec.transaction_uom, --'Ea',
            l_transactions_interface_rec.primary_quantity, -- 1,
            l_transactions_interface_rec.transaction_date, -- sysdate,
            l_transactions_interface_rec.organization_id, --207,
            l_transactions_interface_rec.transaction_source_id, --124743,
            l_transactions_interface_rec.transaction_source_type_id, -- 5,
            l_transactions_interface_rec.transaction_type_id, -- 35,
            l_transactions_interface_rec.wip_entity_type, -- 3,
            l_transactions_interface_rec.operation_seq_num,
            l_transactions_interface_rec.revision, --null, -- ,
            l_transactions_interface_rec.transaction_mode,
            l_transactions_interface_rec.process_flag,
            l_transactions_interface_rec.source_header_id, -- 124743, -- ,
            l_transactions_interface_rec.source_line_id, -- -1, --10,
            l_transactions_interface_rec.transaction_interface_id, -- null, -- mtl_material_transactions_s.nextval, --l_transaction_interface_id,
            l_transactions_interface_rec.reason_id, -- swai: bug 6841113
            l_transactions_interface_rec.final_completion_flag ); -- 'N' ) ;



      EXCEPTION
         WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_TXNS_HEADER_INSERT_ERR');
               FND_MESSAGE.SET_TOKEN('JOB_NAME', l_transactions_interface_rec.transaction_source_id );
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;
      END;



      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'end',
                  'Leaving procedure insert_transactions_header');
      END IF;


END insert_transactions_header;


PROCEDURE update_transactions_header
(
      p_transactions_interface_rec  IN          mtl_transactions_interface%ROWTYPE,
      x_return_status               OUT   NOCOPY   VARCHAR2
)
IS



      -- constant used for FND_LOG debug messages

      lc_mod_name    CONSTANT                 VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.update_transactions_header.';




BEGIN


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering procedure update_transactions_header' );
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;



   --update table mtl_transactions_interface
   BEGIN

  /*  dbms_output.put_line( 'p_transactions_interface_rec.transaction_interface_id is ' ||
         p_transactions_interface_rec.transaction_interface_id ); */

    UPDATE mtl_transactions_interface
     SET
        subinventory_code = p_transactions_interface_rec.subinventory_code,
        locator_id = p_transactions_interface_rec.locator_id,
        revision = p_transactions_interface_rec.revision,
        reason_id = p_transactions_interface_rec.reason_id  -- swai: bug 6841113
     where
        transaction_interface_id = p_transactions_interface_rec.transaction_interface_id;



      EXCEPTION
         WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_TXNS_HEADER_UPDATE_ERR');
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;
      END;



      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'end',
                  'Leaving procedure update_transactions_header');
      END IF;


END update_transactions_header;


PROCEDURE insert_transaction_lots
(
      p_txn_lots_interface_rec            IN          mtl_transaction_lots_interface%ROWTYPE,
      x_return_status               OUT   NOCOPY   VARCHAR2
)
IS


      -- constant used for FND_LOG debug messages

      lc_mod_name    CONSTANT                 VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.insert_transaction_lots';


         l_creation_date DATE;
      l_last_update_date DATE;
      l_created_by NUMBER;
      l_last_updated_by NUMBER;
         l_last_updated_by_name VARCHAR2(100);
      l_last_update_login NUMBER;

BEGIN


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering procedure insert_transaction_lots' );
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Populate the row who columns

      l_creation_date := SYSDATE;
      l_last_update_date := SYSDATE;
      l_created_by := fnd_global.user_id;
      l_last_updated_by := fnd_global.user_id;
      l_last_update_login := fnd_global.login_id;


   --insert into table mtl_transactions_interface
   BEGIN

    INSERT INTO mtl_transaction_lots_interface
       (last_updated_by,
        last_update_date,
        last_update_login,
        created_by,
        creation_date,
        transaction_interface_id,
        lot_number,
        transaction_quantity,
        serial_transaction_temp_id
        )
        Values
        (
            l_last_updated_by,
            l_last_update_date,
            l_last_update_login,
            l_created_by,
            l_creation_date, -- sysdate,
            p_txn_lots_interface_rec.transaction_interface_id,
            p_txn_lots_interface_rec.lot_number,
            p_txn_lots_interface_rec.transaction_quantity,
            p_txn_lots_interface_rec.serial_transaction_temp_id
            ); -- 'N' ) ;


      EXCEPTION
         WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_TXN_LOTS_INSERT_ERR');
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;
      END;



      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'end',
                  'Leaving procedure insert_transaction_lots');
      END IF;


END insert_transaction_lots;


PROCEDURE insert_upd_serial_numbers
(
      p_srl_nmbrs_interface_rec           IN          mtl_serial_numbers_interface%ROWTYPE,
      x_return_status               OUT   NOCOPY   VARCHAR2
)
IS


      -- constant used for FND_LOG debug messages

      lc_mod_name    CONSTANT                 VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.insert_upd_serial_numbers.';


         l_creation_date DATE;
      l_last_update_date DATE;
      l_created_by NUMBER;
      l_last_updated_by NUMBER;
         l_last_updated_by_name VARCHAR2(100);
      l_last_update_login NUMBER;
      l_row_exists  NUMBER := 0;

BEGIN


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering procedure insert_upd_serial_numbers' );
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

        Select count(*) into l_row_exists from mtl_serial_numbers_interface
            where transaction_interface_id =
                p_srl_nmbrs_interface_rec.transaction_interface_id;

        IF l_row_exists = 1 THEN

            BEGIN

            UPDATE mtl_serial_numbers_interface
            SET
                fm_serial_number = p_srl_nmbrs_interface_rec.fm_serial_number
            where transaction_interface_id =
                p_srl_nmbrs_interface_rec.transaction_interface_id;

            EXCEPTION
            WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('CSD','CSD_SRL_NMBRS_UPDATE_ERR');
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;
          END;

        ELSE

         -- Populate the row who columns

         l_creation_date := SYSDATE;
         l_last_update_date := SYSDATE;
         l_created_by := fnd_global.user_id;
         l_last_updated_by := fnd_global.user_id;
         l_last_update_login := fnd_global.login_id;


            --insert into table mtl_transactions_interface
            BEGIN

                INSERT INTO mtl_serial_numbers_interface
                (   last_updated_by,
                    last_update_date,
                    last_update_login,
                    created_by,
                    creation_date,
                    transaction_interface_id,
                    fm_serial_number
                )
                Values
                (
                    l_last_updated_by,
                    l_last_update_date,
                    l_last_update_login,
                    l_created_by,
                    l_creation_date, -- sysdate,
                    p_srl_nmbrs_interface_rec.transaction_interface_id,
                    p_srl_nmbrs_interface_rec.fm_serial_number
                    ); -- 'N' ) ;


                EXCEPTION
                WHEN OTHERS THEN
                        FND_MESSAGE.SET_NAME('CSD','CSD_SRL_NMBRS_INSERT_ERR');
                       FND_MSG_PUB.ADD;
                       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                     RETURN;
              END;

        END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'end',
                  'Leaving procedure insert_upd_serial_numbers');
      END IF;


END insert_upd_serial_numbers;


PROCEDURE insert_wip_cost_txn
(
      p_wip_cost_txn_interface_rec           IN          wip_cost_txn_interface%ROWTYPE,
      x_return_status               OUT   NOCOPY   VARCHAR2
)
IS



      -- constant used for FND_LOG debug messages

      lc_mod_name    CONSTANT                 VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.insert_transactions_header.';


      -- Constants Used for Inserting into mtl_transactions_interface,

         lc_concurrent_mode           CONSTANT    NUMBER := 1;
         lc_yes_process_flag          CONSTANT    NUMBER := 1;

        lc_res_validation_phase         CONSTANT    NUMBER := 1;
      lc_res_pending_status      CONSTANT NUMBER := 1;
      lc_discrete_entity_type     CONSTANT     NUMBER := 1;


         l_creation_date DATE;
      l_last_update_date DATE;
      l_created_by_name VARCHAr2(100);
      l_last_updated_by NUMBER;
         l_last_updated_by_name VARCHAR2(100);
      l_last_update_login NUMBER;
      l_process_phase     NUMBER;
      l_process_status    NUMBER;
      l_entity_type       NUMBER;



BEGIN


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering procedure insert_job_header' );
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Populate the constant values


      l_process_phase := lc_res_validation_phase;
      l_process_status := lc_res_pending_status;
      l_entity_type    := lc_discrete_entity_type;

      -- Populate the row who columns

      l_creation_date := SYSDATE;
      l_last_update_date := SYSDATE;
      l_created_by_name := fnd_global.user_name;
      l_last_updated_by := fnd_global.user_id;
      l_last_updated_by_name := fnd_global.user_name;
      l_last_update_login := fnd_global.login_id;


   --insert into table wip_cost_txn_interface
   BEGIN

    INSERT INTO wip_cost_txn_interface
       (last_updated_by_name,
        last_updated_by,
        last_update_date,
        last_update_login,
        created_by_name,
        creation_date,
        operation_seq_num,
        organization_id,
        organization_code,
        process_phase,
        process_status,
        resource_seq_num,
        transaction_date,
        transaction_quantity,
        transaction_type,
        transaction_uom,
        wip_entity_name,
        wip_entity_id,
        employee_id,
        employee_num,
        entity_type
        )
        Values
        (
            l_last_updated_by_name,
            l_last_updated_by,
            l_last_update_date,
            l_last_update_login,
            l_created_by_name,
            l_creation_date, -- sysdate,
            p_wip_cost_txn_interface_rec.operation_seq_num,
            p_wip_cost_txn_interface_rec.organization_id,
            p_wip_cost_txn_interface_rec.organization_code,
            l_process_phase,
            l_process_status,
            p_wip_cost_txn_interface_rec.resource_seq_num,
            p_wip_cost_txn_interface_rec.transaction_date,
            p_wip_cost_txn_interface_rec.transaction_quantity,
            p_wip_cost_txn_interface_rec.transaction_type,
            p_wip_cost_txn_interface_rec.transaction_uom,
            p_wip_cost_txn_interface_rec.wip_entity_name,
            p_wip_cost_txn_interface_rec.wip_entity_id,
            p_wip_cost_txn_interface_rec.employee_id,
            p_wip_cost_txn_interface_rec.employee_num,
            l_entity_type
             ) ;


      EXCEPTION
         WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_WIP_COST_TXN_INSERT_ERR');
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;

      END;


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'end',
                  'Leaving procedure insert_transactions_header');
      END IF;


END insert_wip_cost_txn;


PROCEDURE insert_wip_move_txn
(
      p_wip_move_txn_interface_rec           IN          wip_move_txn_interface%ROWTYPE,
      x_return_status               OUT   NOCOPY   VARCHAR2
)
IS



      -- constant used for FND_LOG debug messages

      lc_mod_name    CONSTANT                 VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.insert_wip_move_txn';


      -- Indicates that the process Phase is Validation
        lc_validation_phase         CONSTANT    NUMBER := 1;


        -- Indicates that the process_status is Running
      lc_running_status       CONSTANT NUMBER := 2;


         l_creation_date DATE;
      l_last_update_date DATE;
      l_created_by NUMBER;
      l_last_updated_by NUMBER;
         l_last_updated_by_name VARCHAR2(100);
         l_created_by_name VARCHAR2(100);
      l_last_update_login NUMBER;
      l_process_phase     NUMBER;
      l_process_status    NUMBER;



BEGIN


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering procedure insert_wip_move_txn' );
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Populate the constant values


      l_process_phase := lc_validation_phase;
      l_process_status := lc_running_status;

      -- Populate the row who columns

      l_creation_date := SYSDATE;
      l_last_update_date := SYSDATE;
      l_created_by := fnd_global.user_id;
      l_created_by_name := fnd_global.user_name;
      l_last_updated_by := fnd_global.user_id;
      l_last_updated_by_name := fnd_global.user_name;
      l_last_update_login := fnd_global.login_id;



   --insert into table wip_move_txn_interface
   BEGIN
    insert into wip_move_txn_interface(
        transaction_id,
        last_update_date,
        last_updated_by,
        last_updated_by_name,
        creation_date,
        created_by,
        created_by_name,
        group_id,
        process_phase,
        process_status,
        organization_id,
        wip_entity_name,
        transaction_date,
        fm_operation_seq_num,
        fm_intraoperation_step_type,
        to_operation_seq_num,
        to_intraoperation_step_type,
        transaction_quantity,
        transaction_uom
    ) values (
        p_wip_move_txn_interface_rec.transaction_id,
        l_last_update_date,       /* last_update_date */
        l_last_updated_by,        /* last_updated_by */
        l_last_updated_by_name,   /* last_updated_by_name */
        l_creation_date,          /* creation_date */
        l_created_by,             /* created_by */
        l_created_by_name,        /* created_by_name */
        p_wip_move_txn_interface_rec.group_id,      /* group_id */
        l_process_phase,             /* process phase */
        l_process_status,          /* process status */
        p_wip_move_txn_interface_rec.organization_id,
        p_wip_move_txn_interface_rec.wip_entity_name,
        p_wip_move_txn_interface_rec.transaction_date,
        p_wip_move_txn_interface_rec.fm_operation_seq_num,
        p_wip_move_txn_interface_rec.fm_intraoperation_step_type,
        p_wip_move_txn_interface_rec.to_operation_seq_num,
        p_wip_move_txn_interface_rec.to_intraoperation_step_type,
        p_wip_move_txn_interface_rec.transaction_quantity,
        p_wip_move_txn_interface_rec.transaction_uom
        );


      EXCEPTION
         WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_WIP_MOVE_TXN_INSERT_ERR');
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;

      END;


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'end',
                  'Leaving procedure insert_wip_move_txn');
      END IF;


END insert_wip_move_txn;

-- private routine.
-- Inserts into costing interface table for average costing method.
-- Bug#9453092, subhat
PROCEDURE insert_cst_interface(p_wip_entity_id 		IN NUMBER,
					 		   p_op_seq_num	 		IN NUMBER,
					 		   p_qty_completed 		IN NUMBER,
					 		   p_interface_id		IN NUMBER,
					 		   p_primary_quantity 	IN NUMBER
					 		   )
IS
BEGIN
	INSERT INTO cst_comp_snap_interface
		( created_by,
		  creation_date,
		  last_update_date,
		  last_update_login,
		  last_updated_by,
		  OPERATION_SEQ_NUM,
		  quantity_completed,
		  transaction_interface_id,
		  wip_entity_id,
		  primary_quantity
		)
	VALUES
		( fnd_global.user_id,
		  SYSDATE,
		  SYSDATE,
		  fnd_global.login_id,
		  fnd_global.user_id,
		  p_op_seq_num,
		  p_qty_completed,
		  p_interface_id,
		  p_wip_entity_id,
		  p_primary_quantity
		 );
END insert_cst_interface;

--
-- Inserts the transaction line(s) for job completion and then
-- processes the transaction lines if there are no details needed
-- OUT param:
-- x_transaction_header_id: If details are needed, the transaction
--                          header ID will be populated.  Otherwise
--                          parameter is null.
--
PROCEDURE process_job_comp_txn
(
    p_api_version_number                  IN          NUMBER,
    p_init_msg_list                       IN          VARCHAR2 ,
    p_commit                              IN          VARCHAR2 ,
    p_validation_level                    IN          NUMBER,
    x_return_status                       OUT NOCOPY  VARCHAR2,
    x_msg_count                           OUT NOCOPY  NUMBER,
    x_msg_data                            OUT NOCOPY  VARCHAR2,
    p_comp_job_dtls_rec                   IN          JOB_DTLS_REC_TYPE,
    x_transaction_header_id               OUT NOCOPY  NUMBER
)
IS
     lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_JOB_COMP_TXN';
     lc_api_version_number      CONSTANT NUMBER := 1.0;

     -- constants used for FND_LOG debug messages
     lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_job_comp_txn';

     l_need_details_flag       VARCHAR2(1) := 'F';
     l_transaction_header_id   NUMBER;

BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
               lc_mod_name||'begin',
               'Entering private API process_job_comp_txn' );
   END IF;

   SAVEPOINT PROCESS_JOB_COMP_TXN_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(lc_api_version_number,
                                      p_api_version_number,
                                      lc_api_name,
                                      G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
               lc_mod_name||'beforecallinsertjobcomptxn',
               'Just before calling insert_job_comp_txn');
   END IF;
   insert_job_comp_txn (
       p_api_version_number       => lc_api_version_number,
       p_init_msg_list            => fnd_api.g_false ,
       p_commit                   => fnd_api.g_false,
       p_validation_level         => p_validation_level,
       x_return_status            => x_return_status,
       x_msg_count                => x_msg_count,
       x_msg_data                 => x_msg_data,
       p_comp_job_dtls_rec        => p_comp_job_dtls_rec,
       x_need_details_flag        => l_need_details_flag,
       x_transaction_header_id    => l_transaction_header_id
    );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS )  THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_JOB_COMP_TXN_FAILURE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- if no need for details, then we can process transactions and commit
   IF l_need_details_flag = 'F' THEN
      IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                 FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                  lc_mod_name||'beforecallprocesstxn',
                  'Just before calling process_mti_transactions');
      END IF;
      process_mti_transactions(
          p_api_version_number       => lc_api_version_number,
          p_init_msg_list            => fnd_api.g_false ,
          p_commit                   => fnd_api.g_false,
          p_validation_level         => p_validation_level,
          x_return_status            => x_return_status,
          x_msg_count                => x_msg_count,
          x_msg_data                 => x_msg_data,
          p_txn_header_id            => l_transaction_header_id
         --  p_txn_type                                IN         VARCHAR2
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS )  THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_JOB_COMP_TXN_FAILURE');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
      --if we need details, pass back the transaction header id
      x_transaction_header_id := l_transaction_header_id;
   END IF;

   -- Check before commit
   IF l_need_details_flag = 'F' and FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_JOB_COMP_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_JOB_COMP_TXN_PVT  ;
         x_return_status := FND_API.G_RET_STS_ERROR;

         FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_JOB_COMP_TXN_PVT  ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            -- Add Unexpected Error to Message List, here SQLERRM is used for
            -- getting the error
            FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                     lc_mod_name||'others_exception',
                     'OTHERS Exception');
         END IF;
END process_job_comp_txn;

--
-- Inserts the transaction line(s) for job completion
-- Does NOT process the transaction lines
-- OUT params:
-- x_need_details_flag: set to 'T' if details are neede, otherwise 'F'
-- x_transaction_header_id: Transaction header ID always passed back
--                          regardless of need details param
--
PROCEDURE insert_job_comp_txn
(
    p_api_version_number                  IN          NUMBER,
    p_init_msg_list                       IN          VARCHAR2 ,
    p_commit                              IN          VARCHAR2 ,
    p_validation_level                    IN          NUMBER,
    x_return_status                       OUT NOCOPY  VARCHAR2,
    x_msg_count                           OUT NOCOPY  NUMBER,
    x_msg_data                            OUT NOCOPY  VARCHAR2,
    p_comp_job_dtls_rec                   IN          JOB_DTLS_REC_TYPE,
    x_need_details_flag                   OUT NOCOPY  VARCHAR2,
    x_transaction_header_id               OUT NOCOPY  NUMBER
)
IS

     lc_api_name                CONSTANT VARCHAR2(30) := 'INSERT_JOB_COMP_TXN';
     lc_api_version_number      CONSTANT NUMBER := 1.0;

     -- constants used for FND_LOG debug messages
     lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.insert_job_comp_txn';

     lc_revision_controlled       CONSTANT    NUMBER  := 2;
     lc_full_lot_control          CONSTANT    NUMBER  := 2;
     lc_predefined_serial_control CONSTANT    NUMBER  := 2;
     lc_inven_rct_srl_control     CONSTANT    NUMBER  := 5;
     lc_predfn_loc_cntrl          CONSTANT    NUMBER  := 2;
     lc_dyn_loc_cntrl             CONSTANT    NUMBER  := 3;
     lc_subinv_lv_loc_cntrl       CONSTANT    NUMBER  := 4;
     lc_inv_lv_loc_cntrl          CONSTANT    NUMBER  := 5;

     -- Constants used for inserting into mtl_transactions_interface
     lc_completion_source_code    CONSTANT    VARCHAR2(30) := 'WIP Completion';
     lc_wip_txn_source_type_id    CONSTANT    NUMBER := 5;
     lc_comp_txn_type             CONSTANT    NUMBER := 44;
     lc_non_std_wip_ent_type      CONSTANT    NUMBER := 3;
     lc_dummy_source_line_id      CONSTANT    NUMBER := -2;
     lc_n_final_completion_flag   CONSTANT    VARCHAR2(1) := 'N' ;

     -- Records to hold the mtl_transactions_interface data
     l_transactions_interface_rec                mtl_transactions_interface%ROWTYPE;

     l_locator_controlled     VARCHAR2(1) := 'F';
     l_revision_qty_control_code  NUMBER;
     l_transaction_quantity       NUMBER;
     l_lot_control_code           NUMBER;
     l_SERIAL_NUMBER_CONTROL_CODE NUMBER;

     l_last_op_move_quantity NUMBER;
     l_last_move_allowed     VARCHAR2(1);
     l_location_control_code  NUMBER;

     -- bug#9453092, subhat.
     l_costing_method		NUMBER := -1;
     l_last_op_seq_num		NUMBER := -1;

     Cursor get_job_details IS
     SELECT wdj.organization_id, wdj.primary_item_id,
      (wdj.start_quantity - wdj.quantity_completed - wdj.quantity_scrapped)
      transaction_quantity,
      wdj.completion_subinventory, wdj.completion_locator_id,
      msi.primary_uom_code, msi.revision_qty_control_code,
      msi.SERIAL_NUMBER_CONTROL_CODE, msi.LOT_CONTROL_CODE
      from wip_discrete_jobs wdj, mtl_system_items_kfv msi
      where wdj.wip_entity_id = p_comp_job_dtls_rec.wip_entity_id and
            wdj.primary_item_id = msi.inventory_item_id and
            wdj.organization_id = msi.organization_id;

     CURSOR get_mtl_header_id IS
         SELECT mtl_material_transactions_s.nextval from dual;

     CURSOR get_last_operation_dtls(c_org_id NUMBER) IS
         SELECT
           wo.quantity_waiting_to_move,
           'Y' allow_moves
          FROM
                 wip_operations wo
          WHERE  wo.operation_seq_num =
                   (select max(operation_seq_num)
                    from   wip_operations wo1
                    where  wo1.organization_id = wo.organization_id
                    and    wo1.wip_entity_id = wo.wip_entity_id
                    and    wo1.repetitive_schedule_id is NULL)
          AND    wo.organization_id = c_org_id
          AND    wo.wip_entity_id = p_comp_job_dtls_rec.wip_entity_id
          AND    wo.repetitive_schedule_id is NULL
          AND    not exists
                (select 'No move status exists'
                 from   wip_shop_floor_statuses ws,
                        wip_shop_floor_status_codes wsc
                 where  wsc.organization_id = wo.organization_id
                 and    ws.organization_id = wo.organization_id
                 and    ws.wip_entity_id = wo.wip_entity_id
                 and    ws.line_id is NULL
                 and    ws.operation_seq_num = wo.operation_seq_num
                 and    ws.intraoperation_step_type = 3
                 and    ws.shop_floor_status_code = wsc.shop_floor_status_code
                 and    wsc.status_move_flag = 2
                 and    nvl(wsc.disable_date, SYSDATE + 1) > SYSDATE)
          UNION
         SELECT
              wo.quantity_waiting_to_move,
              'N' allow_moves
         FROM
              wip_operations wo
         WHERE  wo.operation_seq_num =
                (select max(operation_seq_num)
                 from   wip_operations wo1
                 where  wo1.organization_id = wo.organization_id
                 and    wo1.wip_entity_id = wo.wip_entity_id
                 and    wo1.repetitive_schedule_id is NULL)
         AND    wo.organization_id = c_org_id
         AND    wo.wip_entity_id = p_comp_job_dtls_rec.wip_entity_id
         AND    wo.repetitive_schedule_id is NULL
         AND    exists
             (select 'Move status exists'
              from   wip_shop_floor_statuses ws,
                     wip_shop_floor_status_codes wsc
              where  wsc.organization_id = wo.organization_id
              and    ws.organization_id = wo.organization_id
              and    ws.wip_entity_id = wo.wip_entity_id
              and    ws.line_id is NULL
              and    ws.operation_seq_num = wo.operation_seq_num
              and    ws.intraoperation_step_type = 3
              and    ws.shop_floor_status_code = wsc.shop_floor_status_code
              and    wsc.status_move_flag = 2
              and    nvl(wsc.disable_date, SYSDATE + 1) > SYSDATE);


     CURSOR get_org_locator_control_code(p_organization_id NUMBER) IS
         SELECT stock_locator_control_code
         from mtl_parameters
         where organization_id = p_organization_id;

     CURSOR get_si_locator_control_code ( p_organization_id NUMBER,
                                          p_secondary_inventory_name VARCHAR2 ) IS
        SELECT locator_type
        from mtl_secondary_inventories
        where
            organization_id = p_organization_id and
            secondary_inventory_name = p_secondary_inventory_name;

     CURSOR get_inv_location_control_code ( p_organization_id NUMBER,
                                            p_inventory_item_id NUMBER )  IS
        SELECT location_control_code
        from mtl_system_items_b
        where
           organization_id = p_organization_id and
           inventory_item_id = p_inventory_item_id;

BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
               lc_mod_name||'begin',
               'Entering private API insert_job_comp_txn' );
   END IF;

   SAVEPOINT INSERT_JOB_COMP_TXN_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(lc_api_version_number,
                                     p_api_version_number,
                                      lc_api_name,
                                      G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- initialize out params
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_need_details_flag := 'F';

   -- generate transaction_id
   open get_mtl_header_id;
   fetch get_mtl_header_id into l_transactions_interface_rec.transaction_header_id;
   close get_mtl_header_id;

   open get_job_details;
   fetch get_job_details into
      l_transactions_interface_rec.organization_id,
      l_transactions_interface_rec.inventory_item_id,
      l_transaction_quantity,
      l_transactions_interface_rec.subinventory_code,
      l_transactions_interface_rec.locator_id,
      l_transactions_interface_rec.transaction_uom,
      l_revision_qty_control_code,
      l_SERIAL_NUMBER_CONTROL_CODE,
      l_lot_control_code;
   close get_job_details;

   open get_last_operation_dtls(
   c_org_id            => l_transactions_interface_rec.organization_id);
   fetch get_last_operation_dtls into
      l_last_op_move_quantity,
      l_last_move_allowed;
   IF (get_last_operation_dtls%FOUND) THEN
      l_transaction_quantity := l_last_op_move_quantity;
      IF l_last_move_allowed = 'N' THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_JOB_COMP_MV_NOT_ALL');
         FND_MSG_PUB.ADD;
         close get_last_operation_dtls;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   close get_last_operation_dtls;

   IF l_transaction_quantity <= 0 THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_JOB_COMP_ZER_QTY');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_transactions_interface_rec.source_code :=  lc_completion_source_code;
   l_transactions_interface_rec.transaction_date  := sysdate;
   l_transactions_interface_rec.transaction_source_type_id := lc_wip_txn_source_type_id;
   l_transactions_interface_rec.transaction_type_id:= lc_comp_txn_type;
   l_transactions_interface_rec.wip_entity_type := lc_non_std_wip_ent_type;
   l_transactions_interface_rec.source_line_id := lc_dummy_source_line_id;
   l_transactions_interface_rec.final_completion_flag := lc_n_final_completion_flag;

   IF  l_revision_qty_control_code   =  lc_revision_controlled THEN
      -- swai: bug 6995498/7182047 - move revision code to common wraper function
      l_transactions_interface_rec.revision := get_default_item_revision
                   (
                    p_org_id=>l_transactions_interface_rec.organization_id,
                    p_inventory_item_id=> l_transactions_interface_rec.inventory_item_id,
                    p_transaction_date=> l_transactions_interface_rec.transaction_date,
                    p_mat_transaction_type=> 'JOB_COMP'
                   ) ;
      IF l_transactions_interface_rec.revision is null THEN
          x_need_details_flag := 'T';
      END IF;
   END IF;

   IF l_transactions_interface_rec.subinventory_code is null THEN

      IF fnd_profile.value('CSD_DEF_REP_INV_ORG') = l_transactions_interface_rec.organization_id and
             fnd_profile.value('CSD_DEF_HV_CMP_SUBINV') is not null  THEN
             l_transactions_interface_rec.subinventory_code := fnd_profile.value('CSD_DEF_HV_CMP_SUBINV');
      ELSE
             x_need_details_flag := 'T'; -- swai: bug 5262927
      END IF;
   END IF;

   -- Get Locator Control
   open get_org_locator_control_code ( l_transactions_interface_rec.organization_id ) ;
   fetch get_org_locator_control_code  into l_location_control_code ;
   close get_org_locator_control_code;

   IF l_location_control_code = lc_subinv_lv_loc_cntrl THEN
      IF l_transactions_interface_rec.subinventory_code is not null THEN
          open get_si_locator_control_code ( l_transactions_interface_rec.organization_id ,
                           l_transactions_interface_rec.subinventory_code ) ;
          fetch get_si_locator_control_code  into l_location_control_code ;
          close get_si_locator_control_code;

          IF l_location_control_code = lc_inv_lv_loc_cntrl THEN
              open get_inv_location_control_code ( l_transactions_interface_rec.organization_id ,
                           l_transactions_interface_rec.inventory_item_id ) ;
              fetch get_inv_location_control_code  into l_location_control_code ;
              close get_inv_location_control_code;
          END IF;
      END IF;
   END IF;


   IF l_location_control_code in (lc_predfn_loc_cntrl,
                                  lc_dyn_loc_cntrl ) THEN
      l_locator_controlled := 'T' ;
   END IF;

   IF l_locator_controlled = 'T' THEN
      IF l_transactions_interface_rec.locator_id is null THEN
         x_need_details_flag := 'T';
      END IF;
   END IF;

   -- Lot Contrrolled Check
   -- Later Need to handle it here as well - based on profile
   -- Value
   IF l_lot_control_code = lc_full_lot_control THEN
      x_need_details_flag := 'T' ;
   END IF;

   l_transactions_interface_rec.transaction_quantity  := l_transaction_quantity;
   l_transactions_interface_rec.primary_quantity  := l_transactions_interface_rec.transaction_quantity;
   l_transactions_interface_rec.transaction_source_id := p_comp_job_dtls_rec.wip_entity_id;
   l_transactions_interface_rec.source_header_id := p_comp_job_dtls_rec.wip_entity_id;

   -- generate transaction_interface_id
   open get_mtl_header_id;
   fetch get_mtl_header_id into l_transactions_interface_rec.transaction_interface_id;
   close get_mtl_header_id;

   IF l_serial_number_control_code in (lc_predefined_serial_control,
                                       lc_inven_rct_srl_control) THEN

      x_need_details_flag := 'T' ;

      -- -1 identifies rows which are queried up in the details UI
      l_transactions_interface_rec.source_line_id := -1;

      IF ( l_transaction_quantity > 1 ) THEN
         l_transactions_interface_rec.transaction_quantity  := 1;

         --insert into table mtl_transactions_interface
         FOR l_qty_ctr IN 1..l_transaction_quantity
         LOOP
            IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
               lc_mod_name||'beforecallinserttxnshdr',
               'Just before calling insert_transactions_header');
            END IF;

            insert_transactions_header(   p_transactions_interface_rec  =>    l_transactions_interface_rec,
                x_return_status  =>    x_return_status );

			-- Support job completion for average costing method bug#9453092, Subhat
			IF l_costing_method = -1 THEN
				SELECT primary_cost_method
				INTO l_costing_method
				FROM mtl_parameters
				WHERE organization_id = l_transactions_interface_rec.organization_id;
			END IF;

			IF l_costing_method = 2 THEN
				IF l_last_op_seq_num = -1 THEN
					SELECT MAX(operation_seq_num)
					INTO l_last_op_seq_num
					FROM   wip_operations wo
					WHERE  wo.organization_id = l_transactions_interface_rec.organization_id
					AND    wo.wip_entity_id = p_comp_job_dtls_rec.wip_entity_id
					AND    wo.repetitive_schedule_id IS NULL;
				END IF;
				insert_cst_interface(p_wip_entity_id => p_comp_job_dtls_rec.wip_entity_id,
									 p_op_seq_num	 => l_last_op_seq_num,
									 p_qty_completed => l_transactions_interface_rec.transaction_quantity,
									 p_interface_id	 => l_transactions_interface_rec.transaction_interface_id,
									 p_primary_quantity => l_transaction_quantity
									 );
			END IF;	-- end bug#9453092

            IF l_qty_ctr <> l_transaction_quantity THEN
               -- generate transaction_interface_id for the next record
               open get_mtl_header_id;
               fetch get_mtl_header_id into l_transactions_interface_rec.transaction_interface_id;
               close get_mtl_header_id;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP;
      ELSE  -- Quantity = 1
         --insert into table mtl_transactions_interface
         IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
            lc_mod_name||'beforecallinserttxnshdr',
            'Just before calling insert_transactions_header');
         END IF;

         insert_transactions_header(p_transactions_interface_rec  =>    l_transactions_interface_rec,
                                    x_return_status  =>    x_return_status );

		 -- Support job completion for average costing method bug#9453092, Subhat
		 IF l_costing_method = -1 THEN
		 	 SELECT primary_cost_method
			 INTO l_costing_method
			 FROM mtl_parameters
			 WHERE organization_id = l_transactions_interface_rec.organization_id;
		 END IF;

		 IF l_costing_method = 2 THEN
			 IF l_last_op_seq_num = -1 THEN
				 SELECT MAX(operation_seq_num)
				 INTO l_last_op_seq_num
				 FROM   wip_operations wo
				 WHERE  wo.organization_id = l_transactions_interface_rec.organization_id
				 AND    wo.wip_entity_id = p_comp_job_dtls_rec.wip_entity_id
				 AND    wo.repetitive_schedule_id IS NULL;
			 END IF;
			 insert_cst_interface(p_wip_entity_id => p_comp_job_dtls_rec.wip_entity_id,
			 					  p_op_seq_num	 => l_last_op_seq_num,
								  p_qty_completed => l_transactions_interface_rec.transaction_quantity,
								  p_interface_id	 => l_transactions_interface_rec.transaction_interface_id,
								  p_primary_quantity => l_transaction_quantity
 								  );
 		 END IF;	-- end bug#9453092

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

   ELSE -- l_serial_number_control_code check
      IF x_need_details_flag = 'T' THEN
         -- -1 identifies rows which are queried up in the details UI
         l_transactions_interface_rec.source_line_id := -1;
      END IF;

      --insert into table mtl_transactions_interface
      IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
            lc_mod_name||'beforecallinserttxnshdr',
            'Just before calling insert_transactions_header');
      END IF;

      insert_transactions_header(p_transactions_interface_rec  =>    l_transactions_interface_rec,
                                 x_return_status  =>    x_return_status );
	  -- Support job completion for average costing method bug#9453092, Subhat
	  IF l_costing_method = -1 THEN
		  SELECT primary_cost_method
		  INTO l_costing_method
		  FROM mtl_parameters
		  WHERE organization_id = l_transactions_interface_rec.organization_id;
	  END IF;

	  IF l_costing_method = 2 THEN
		  IF l_last_op_seq_num = -1 THEN
			  SELECT MAX(operation_seq_num)
			  INTO l_last_op_seq_num
			  FROM   wip_operations wo
			  WHERE  wo.organization_id = l_transactions_interface_rec.organization_id
			  AND    wo.wip_entity_id = p_comp_job_dtls_rec.wip_entity_id
			  AND    wo.repetitive_schedule_id IS NULL;
		  END IF;
		  insert_cst_interface(p_wip_entity_id => p_comp_job_dtls_rec.wip_entity_id,
							   p_op_seq_num	 => l_last_op_seq_num,
							   p_qty_completed => l_transactions_interface_rec.transaction_quantity,
							   p_interface_id	 => l_transactions_interface_rec.transaction_interface_id,
							   p_primary_quantity => l_transactions_interface_rec.transaction_quantity
							   );
	  END IF;  -- end bug#9453092
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF; -- l_serial_number_control_code check

   -- Regardless of whether or not details are needed, pass back
   -- the transaction header ID.
   x_transaction_header_id := l_transactions_interface_rec.transaction_header_id;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to INSERT_JOB_COMP_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to INSERT_JOB_COMP_TXN_PVT  ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to INSERT_JOB_COMP_TXN_PVT  ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;
END insert_job_comp_txn;

PROCEDURE process_mti_transactions
(
    p_api_version_number                      IN         NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                  IN         VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                           OUT NOCOPY VARCHAR2,
    x_msg_count                               OUT NOCOPY NUMBER,
    x_msg_data                                OUT NOCOPY VARCHAR2,
    p_txn_header_id                           IN         NUMBER
)
IS
     lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_MTI_TRANSACTIONS';
     lc_api_version_number      CONSTANT NUMBER := 1.0;

     -- constants used for FND_LOG debug messages
     lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_mti_transactions';

     lc_MTI_source_table          CONSTANT    NUMBER  := 1;

     l_table            NUMBER;
     l_trans_count      NUMBER;
     l_return_count     NUMBER;
BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
               lc_mod_name||'begin',
               'Entering private API process_mti_transactions' );
   END IF;

   SAVEPOINT PROCESS_MTI_TRANSACTIONS_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(lc_api_version_number,
                                      p_api_version_number,
                                      lc_api_name,
                                      G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Populate the constant values
   l_table               := lc_MTI_source_table;

   IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
               lc_mod_name||'beforecallprocesstxns',
               'Just before calling INV_TXN_MANAGER_PUB.process_Transactions');
   END IF;

   l_return_count := INV_TXN_MANAGER_PUB.process_Transactions(
       p_api_version         => lc_api_version_number, --1.0, --           ,
       p_init_msg_list       => fnd_api.g_false, --'T', -- fnd_api.g_false    ,
       p_commit              => fnd_api.g_false, --'T', -- fnd_api.g_false     ,
       p_validation_level    => p_validation_level  ,
       x_return_status       => x_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data,
       x_trans_count         => l_trans_count,
       p_table               => l_table,
       p_header_id           => p_txn_header_id );

   IF ( txn_int_error_exists( p_txn_header_id)  or
        x_return_status <> FND_API.G_RET_STS_SUCCESS )  THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_PROCESS_MTI_TXN_FAILURE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Standard check for p_commit
   IF  FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_MTI_TRANSACTIONS_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_MTI_TRANSACTIONS_PVT  ;
         x_return_status := FND_API.G_RET_STS_ERROR;

         FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_MTI_TRANSACTIONS_PVT  ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            -- Add Unexpected Error to Message List, here SQLERRM is used for
            -- getting the error
            FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;
END process_mti_transactions;

PROCEDURE process_oper_comp_txn
(
    p_api_version_number                        IN          NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                    IN          VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                             OUT   NOCOPY   VARCHAR2,
    x_msg_count                                  OUT  NOCOPY      NUMBER,
    x_msg_data                                OUT      NOCOPY     VARCHAR2,
    p_mv_txn_dtls_tbl                        IN       MV_TXN_DTLS_TBL_TYPE
)
IS
        lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_OPER_COMP_TXN';
        lc_api_version_number      CONSTANT NUMBER := 1.0;

      -- constants used for FND_LOG debug messages

      lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_oper_comp_txn';

      -- Indicates that the process Phase is Validation
      --  lc_validation_phase          CONSTANT    NUMBER := 1;



        -- Constants used for inserting into wip_move_txn_interface

      lc_queue                     CONSTANT    NUMBER := 1;
      lc_to_move                   CONSTANT    NUMBER := 3;
        lc_error_process_status      CONSTANT    NUMBER := 3;


          -- Record to hold wip_move_txn_interface

       l_wip_move_txn_interface_rec                wip_move_txn_interface%ROWTYPE;


        /*  l_process_phase NUMBER;
          l_material_transaction_id NUMBER;  */

        l_prev_wip_entity_id NUMBER := -1;
        l_prev_to_operation_seq_num NUMBER    := -1;
        l_prev_transaction_quantity NUMBER := 0;
        --l_error_exists            VARCHAR2(6);
        l_err_wip_entity_name         VARCHAR2(240);
        l_err_op_seq_num              NUMBER;

        -- swai: bug 5330060
        -- temporary storgae of it move and in queue quantities
        l_qty_to_move  NUMBER := 0;
        l_qty_in_queue NUMBER := 0;
        -- end swai: bug 5330060

        CURSOR get_transaction_id IS
            SELECT wip_transactions_s.nextval from dual;


        Cursor check_mv_interface_errors ( c_group_id NUMBER ) IS
            select wip.wip_entity_name, mv.fm_operation_seq_num
            from wip_move_txn_interface mv, wip_entities wip
            where mv.group_id = c_group_id
            and mv.process_status = lc_error_process_status
            and mv.wip_entity_id = wip.wip_entity_id;

        -- swai: bug 5330060
        -- Get the previous operation for this job that has qty > 1
        -- for either in queue or waiting to move
        Cursor get_valid_previous_op (c_wip_entity_id NUMBER, c_op_seq_num NUMBER) IS
        select *
        from
            (select operation_seq_num,
                    quantity_in_queue,
                    quantity_waiting_to_move
               from wip_operations
              where wip_entity_id = c_wip_entity_id
                and operation_seq_num < c_op_seq_num
                and quantity_in_queue + quantity_waiting_to_move > 0
             order by operation_seq_num desc)
        where rownum=1;
        -- end swai: bug 5330060

     /*   CURSOR get_material_transaction_id IS
            SELECT mtl_material_transactions_s.nextval from dual;  */


BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering private API process_oper_comp_txn' );
      END IF;

        SAVEPOINT PROCESS_OPER_COMP_TXN_PVT;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call
           (lc_api_version_number,
            p_api_version_number,
            lc_api_name,
            G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
        END IF;




      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Populate the constant values


     --  l_process_phase := lc_validation_phase;


        -- generate transaction_id
        open get_transaction_id;
     --   fetch get_transaction_id into l_wip_move_txn_interface_rec.transaction_id;
        fetch get_transaction_id into l_wip_move_txn_interface_rec.group_id;
        close get_transaction_id;

       -- l_wip_move_txn_interface_rec.group_id := l_wip_move_txn_interface_rec.transaction_id;
        l_wip_move_txn_interface_rec.transaction_date := sysdate;
        l_wip_move_txn_interface_rec.fm_intraoperation_step_type  := lc_queue;


        -- swai: bug 5330060
        -- updated logic within for loop
        FOR mv_ctr in p_mv_txn_dtls_tbl.FIRST.. p_mv_txn_dtls_tbl.LAST
        LOOP

           l_wip_move_txn_interface_rec.organization_id := p_mv_txn_dtls_tbl(mv_ctr).organization_id;
           l_wip_move_txn_interface_rec.wip_entity_name := p_mv_txn_dtls_tbl(mv_ctr).wip_entity_name;
           l_wip_move_txn_interface_rec.transaction_uom := p_mv_txn_dtls_tbl(mv_ctr).transaction_uom;
           l_wip_move_txn_interface_rec.to_operation_seq_num := nvl(p_mv_txn_dtls_tbl(mv_ctr).to_operation_seq_num,
                                                                    p_mv_txn_dtls_tbl(mv_ctr).fm_operation_seq_num ) ;
           -- if the to operation seq is 0, then it's the last operation,
           -- make sure the to step type is to_move, otherwise, it's in queue.
           if (p_mv_txn_dtls_tbl(mv_ctr).to_operation_seq_num is null) then
               l_wip_move_txn_interface_rec.to_intraoperation_step_type :=  lc_to_move;
           else
               l_wip_move_txn_interface_rec.to_intraoperation_step_type  := lc_queue;
           end if;

           -- if we are completing more than one operation for the same job, make
           -- the quantities are passed forward.  Currently, do not allow the user
           -- to skip operations for the same job. (eg, complete 10, skip 20, complete 30)
           IF l_prev_wip_entity_id = p_mv_txn_dtls_tbl(mv_ctr).wip_entity_id THEN
               IF  l_prev_to_operation_seq_num <> p_mv_txn_dtls_tbl(mv_ctr).fm_operation_seq_num THEN
                  FND_MESSAGE.SET_NAME('CSD','CSD_OP_COMP_SEQ_ERROR');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
               ELSE
                  l_wip_move_txn_interface_rec.transaction_quantity := p_mv_txn_dtls_tbl(mv_ctr).transaction_quantity +
                  l_prev_transaction_quantity;
               END IF;
           ELSE
               l_wip_move_txn_interface_rec.transaction_quantity := p_mv_txn_dtls_tbl(mv_ctr).transaction_quantity;
           END IF;

           -- use the values passed in if there are items to be transacted.  Otherwise,
           -- we will attempt to find the appropriate from operation with an item that
           -- can be moved
           IF (l_wip_move_txn_interface_rec.transaction_quantity > 0) then
               l_wip_move_txn_interface_rec.fm_operation_seq_num := p_mv_txn_dtls_tbl(mv_ctr).fm_operation_seq_num;
           ELSE
               -- find the operation with a qty to complete, set the from operation to this
               open get_valid_previous_op (p_mv_txn_dtls_tbl(mv_ctr).wip_entity_id,
                                           p_mv_txn_dtls_tbl(mv_ctr).fm_operation_seq_num);
               fetch get_valid_previous_op into
                   l_wip_move_txn_interface_rec.fm_operation_seq_num,
                   l_qty_in_queue,
                   l_qty_to_move;
               close get_valid_previous_op;

               -- depending on where the item is, set the qty and from step type accordingly.
               if l_qty_in_queue > 0 then
                   l_wip_move_txn_interface_rec.fm_intraoperation_step_type  := lc_queue;
                   l_wip_move_txn_interface_rec.transaction_quantity :=  l_qty_in_queue;
               elsif (l_qty_to_move > 0) then
                   l_wip_move_txn_interface_rec.fm_intraoperation_step_type  := lc_to_move;
                   l_wip_move_txn_interface_rec.transaction_quantity :=  l_qty_to_move;
               end if;
           END IF;

           -- set the variables to compare in the next loop iteration
           l_prev_wip_entity_id := p_mv_txn_dtls_tbl(mv_ctr).wip_entity_id;
           l_prev_to_operation_seq_num := l_wip_move_txn_interface_rec.to_operation_seq_num;
           l_prev_transaction_quantity := l_wip_move_txn_interface_rec.transaction_quantity;

           --insert into table wip_move_txn_interface
           IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
               lc_mod_name||'beforecallinsertwipmvtxn',
               'Just before calling insert_wip_move_txn');
           END IF;

           insert_wip_move_txn(     p_wip_move_txn_interface_rec  =>    l_wip_move_txn_interface_rec,
                                  x_return_status  =>    x_return_status );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

        END LOOP;
        -- end swai: bug 5330060


/*     open get_material_transaction_id;
        fetch get_material_transaction_id into l_material_transaction_id;
        close get_material_transaction_id;
*/

        IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallprocesstxns',
                        'Just before calling INV_TXN_MANAGER_PUB.process_Transactions');
        END IF;

/*
      wip_movProc_grp.processInterface(p_movTxnID      => l_wip_move_txn_interface_rec.transaction_id,
                           p_procPhase     => l_process_phase,
                           p_txnHdrID      => l_material_transaction_id,
                           p_mtlMode       => WIP_CONSTANTS.ONLINE,
                           p_cplTxnID      => NULL,
                           p_commit        => FND_API.G_FALSE,
                           x_returnStatus  => x_return_status,
                           x_errorMsg      => x_msg_data);

*/

        wip_movProc_grp.processInterface(p_groupID       => l_wip_move_txn_interface_rec.group_id,
                         p_commit        => FND_API.G_FALSE,
                         x_returnStatus  => x_return_status ) ;

        -- Need to get errors from error table and pass it back
         open  check_mv_interface_errors  ( l_wip_move_txn_interface_rec.group_id );
         fetch check_mv_interface_errors  into l_err_wip_entity_name, l_err_op_seq_num;

         If (( x_return_status <> FND_API.G_RET_STS_SUCCESS) or
              (l_err_op_seq_num is not null)) THEN

            IF (l_err_op_seq_num is null) THEN
                close check_mv_interface_errors ;
                FND_MESSAGE.SET_NAME('CSD','CSD_MOVE_TXN_FAILURE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;

            ELSE
                x_return_status := FND_API.G_RET_STS_ERROR;
                WHILE check_mv_interface_errors%FOUND LOOP
                    FND_MESSAGE.SET_NAME('CSD','CSD_MOVE_TXN_FAILURE_DET');
                    FND_MESSAGE.SET_TOKEN('WIP_ENTITY_NAME', l_err_wip_entity_name);
                    FND_MESSAGE.SET_TOKEN('OPERATION_SEQ_NUM', l_err_op_seq_num );
                    FND_MSG_PUB.ADD;
                    fetch check_mv_interface_errors into l_err_wip_entity_name, l_err_op_seq_num;
                END LOOP;
             END IF;
         end if;
         close check_mv_interface_errors ;


 /*       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                ROLLBACK to PROCESS_OPER_COMP_TXN_PVT ;


                FND_MESSAGE.SET_NAME('CSD','CSD_MOVE_TXN_FAILURE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;  */


        /*        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                              FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                                lc_mod_name||'exc_exception',
                            'G_EXC_ERROR Exception');
                END IF;

                RETURN;  */

     --   END IF;


-- Standard check for p_commit
        IF FND_API.to_Boolean( p_commit )
        THEN
            COMMIT WORK;
        END IF;

EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_OPER_COMP_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_OPER_COMP_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_OPER_COMP_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;

END process_oper_comp_txn;



PROCEDURE process_issue_mtl_txn
(
    p_api_version_number                        IN          NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                    IN          VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                             OUT   NOCOPY   VARCHAR2,
    x_msg_count                                  OUT  NOCOPY      NUMBER,
    x_msg_data                                OUT      NOCOPY     VARCHAR2,
    p_mtl_txn_dtls_tbl                       IN       MTL_TXN_DTLS_TBL_TYPE,
 --   p_ro_quantity                               IN      NUMBER,
    x_transaction_header_id                      OUT     NOCOPY      NUMBER
)
IS

        lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_ISSUE_MTL_TXN';
        lc_api_version_number      CONSTANT NUMBER := 1.0;

      -- constants used for FND_LOG debug messages

      lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_issue_mtl_txn';


        lc_revision_controlled       CONSTANT    NUMBER := 2;
        lc_full_lot_control          CONSTANT    NUMBER  := 2;
        lc_predefined_serial_control CONSTANT    NUMBER  := 2;
        lc_inven_rct_srl_control     CONSTANT    NUMBER  := 5;

        lc_predfn_loc_cntrl           CONSTANT   NUMBER   := 2;
        lc_dyn_loc_cntrl             CONSTANT    NUMBER   := 3;
        lc_subinv_lv_loc_cntrl            CONSTANT   NUMBER   := 4;
        lc_inv_lv_loc_cntrl           CONSTANT   NUMBER   := 5;
        lc_MTI_source_table          CONSTANT    NUMBER := 1;


      -- Constants Used for Inserting into wip_job_schedule_interface,
      -- and details interface tables

      lc_non_std_update_load_type      CONSTANT NUMBER := 3;
      --lc_non_std_update_load_type    CONSTANT NUMBER := 9;
      lc_load_mtl_type  CONSTANT        NUMBER := 2;
      lc_substitution_change_type CONSTANT                  NUMBER := 3;
    --   lc_mrp_net_flag   CONSTANT        NUMBER  := 1;
      -- 11/7/05
    --   lc_push_wip_supply_type CONSTANT  NUMBER  := 1;

        -- Constants used for inserting into mtl_transactions_interface

        lc_issue_source_code    CONSTANT    VARCHAR2(30) := 'WIP Issue';
        lc_wip_txn_source_type_id CONSTANT    NUMBER := 5;
         lc_issue_txn_type             CONSTANT    NUMBER := 35;
         lc_wip_comp_return_txn_type             CONSTANT    NUMBER := 43;
        lc_non_std_wip_ent_type      CONSTANT    NUMBER := 3;
        lc_n_final_completion_flag   CONSTANT    VARCHAR2(1) := 'N' ;


          -- Records to hold the Job header,details
          -- and mtl_transactions_interface data

       l_transactions_interface_rec                mtl_transactions_interface%ROWTYPE;
        l_srl_nmbrs_interface_rec                mtl_serial_numbers_interface%ROWTYPE;
        l_job_header_rec                wip_job_schedule_interface%ROWTYPE;
        l_job_details_rec           wip_job_dtls_interface%ROWTYPE;



        l_table            NUMBER;
        l_trans_count      NUMBER;
        l_return_count     NUMBER;

      l_last_update_date DATE;
      l_last_updated_by NUMBER;
      l_last_update_login NUMBER;

      l_locator_controlled     VARCHAR2(1) := 'F';

      l_wip_update_needed  VARCHAR2(1) := 'F';

      l_row_need_details_flag VARCHAR2(1) := 'F';
      l_need_details_flag VARCHAR2(1) := 'F';
      l_location_control_code NUMBER;
      l_primary_qty        NUMBER;



        CURSOR get_mtl_header_id IS
            SELECT mtl_material_transactions_s.nextval from dual;

        CURSOR get_org_locator_control_code(p_organization_id NUMBER) IS
            SELECT stock_locator_control_code from mtl_parameters
            where organization_id = p_organization_id;

        CURSOR get_si_locator_control_code ( p_organization_id NUMBER,
                p_secondary_inventory_name VARCHAR2 ) IS
           SELECT locator_type from mtl_secondary_inventories where
               organization_id = p_organization_id and
               secondary_inventory_name = p_secondary_inventory_name;

        CURSOR get_inv_location_control_code ( p_organization_id NUMBER,
            p_inventory_item_id NUMBER )  IS
        select location_control_code from mtl_system_items_b where
        organization_id = p_organization_id and
        inventory_item_id = p_inventory_item_id;




BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering private API process_issue_mtl_txn' );
      END IF;

        SAVEPOINT PROCESS_ISSUE_MTL_TXN_PVT;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call
           (lc_api_version_number,
            p_api_version_number,
            lc_api_name,
            G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
        END IF;




      x_return_status := FND_API.G_RET_STS_SUCCESS;

--       x_need_details_flag := 'F';



      -- Populate the constant values


      l_table               := lc_MTI_source_table;


      -- Populate the row who columns

      l_last_update_date := SYSDATE;
      l_last_updated_by := fnd_global.user_id;
      l_last_update_login := fnd_global.login_id;


        -- generate transaction_header_id
        open get_mtl_header_id;
        fetch get_mtl_header_id into l_transactions_interface_rec.transaction_header_id;
        close get_mtl_header_id;


        l_transactions_interface_rec.source_code :=  lc_issue_source_code;

        l_transactions_interface_rec.transaction_date  := sysdate;
        l_transactions_interface_rec.transaction_source_type_id := lc_wip_txn_source_type_id;
        --check/verify above again


        l_transactions_interface_rec.wip_entity_type := lc_non_std_wip_ent_type;
        l_transactions_interface_rec.final_completion_flag := lc_n_final_completion_flag;


      -- Populate the constant values

        l_job_header_rec.load_type := lc_non_std_update_load_type;

        l_job_details_rec.date_required    := sysdate;
        l_job_details_rec.load_type := lc_load_mtl_type;

        l_job_details_rec.substitution_type := lc_substitution_change_type;

      --  l_job_details_rec.mrp_net_flag := lc_mrp_net_flag;
     --   11/7/05
      --  l_job_details_rec.wip_supply_type := lc_push_wip_supply_type;
        l_job_details_rec.wip_supply_type := null;
         -- Get the Group_id to be used for WIP Mass Load,

       SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.group_id FROM dual;

   --     l_job_header_rec.group_id := l_job_header_rec.header_id;

        l_job_details_rec.group_id         := l_job_header_rec.group_id;
/*        l_job_details_rec.parent_header_id := l_job_header_rec.group_id;

*/
        --   l_completion_subinv := nvl( p_completion_subinv, fnd_profile.value('CSD_HV_COMP_SUBINV')) ;
        --   l_completion_loc_id : nvl( p_completion_loc_id, fnd_profile.value('CSD_HV_COMP_LOC_ID'));



        FOR mtl_ctr in p_mtl_txn_dtls_tbl.FIRST.. p_mtl_txn_dtls_tbl.LAST

        LOOP

                    l_transactions_interface_rec.transaction_quantity  :=  (-1) * p_mtl_txn_dtls_tbl(mtl_ctr).transaction_quantity;

                    If l_transactions_interface_rec.transaction_quantity = 0 then
                        FND_MESSAGE.SET_NAME('CSD','CSD_ISS_QTY_ZERO');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    end if;


                    l_transactions_interface_rec.transaction_uom   := p_mtl_txn_dtls_tbl(mtl_ctr).transaction_uom;
                    --     l_transactions_interface_rec.primary_quantity
                    -- Need to check later for above
                    l_transactions_interface_rec.organization_id   := p_mtl_txn_dtls_tbl(mtl_ctr).organization_id;
                    l_transactions_interface_rec.transaction_source_id := p_mtl_txn_dtls_tbl(mtl_ctr).wip_entity_id;
                    l_transactions_interface_rec.source_header_id := p_mtl_txn_dtls_tbl(mtl_ctr).wip_entity_id;
                    l_transactions_interface_rec.source_line_id := p_mtl_txn_dtls_tbl(mtl_ctr).operation_seq_num;
                    l_transactions_interface_rec.operation_seq_num := p_mtl_txn_dtls_tbl(mtl_ctr).operation_seq_num;

                    l_transactions_interface_rec.reason_id := p_mtl_txn_dtls_tbl(mtl_ctr).reason_id;  -- swai bug 6841113

                    -- generate transaction_interface_id
                    open get_mtl_header_id;
                    fetch get_mtl_header_id into l_transactions_interface_rec.transaction_interface_id;
                    close get_mtl_header_id;


                    If p_mtl_txn_dtls_tbl(mtl_ctr).transaction_quantity > 0 then

                        l_transactions_interface_rec.transaction_type_id:= lc_issue_txn_type;
                    else

                        l_transactions_interface_rec.transaction_type_id:= lc_wip_comp_return_txn_type;

                    end if;


                    -- above needs to be issue or return from job - based on quantity
                    -- entered . If negative quantity entered, then a negative issue
                    -- ,meaning Return Job needs to be done

                    -- Need to do validation in the client, such that
                    -- if the return quantity is > issued quantity, there
                    -- should be an error message


                    If  p_mtl_txn_dtls_tbl(mtl_ctr).revision_qty_control_code   =  lc_revision_controlled then
                        -- swai: bug 6995498/7182047 - revision is defaulted in the UI, so do not default
                        -- behind the user's back in the API.  Just get value from record.
                        l_transactions_interface_rec.revision := p_mtl_txn_dtls_tbl(mtl_ctr).revision;

             --       dbms_output.put_line( 'revision is ' || l_transactions_interface_rec.revision );
                        If l_transactions_interface_rec.revision is null then
                            l_row_need_details_flag := 'T';
                        end if;

                    end if;

                    l_transactions_interface_rec.inventory_item_id := p_mtl_txn_dtls_tbl(mtl_ctr).inventory_item_id;

                    If p_mtl_txn_dtls_tbl(mtl_ctr).supply_subinventory is not null THEN

                        l_transactions_interface_rec.subinventory_code := p_mtl_txn_dtls_tbl(mtl_ctr).supply_subinventory;

                    ELSE

                       IF fnd_profile.value('CSD_DEF_REP_INV_ORG') = p_mtl_txn_dtls_tbl(mtl_ctr).organization_id and
                         fnd_profile.value('CSD_DEF_HV_SUBINV') is not null  THEN
                            l_transactions_interface_rec.subinventory_code := fnd_profile.value('CSD_DEF_HV_SUBINV');
                       ELSE
                            l_row_need_details_flag := 'T';
                       END IF;
                    END IF;

                    -- l_locator_controlled := Call Inventory procedure to get this

                    -- Get Locator Control

                    open get_org_locator_control_code ( l_transactions_interface_rec.organization_id ) ;
                    fetch get_org_locator_control_code  into l_location_control_code ;
                    close get_org_locator_control_code;

                    If l_location_control_code = lc_subinv_lv_loc_cntrl THEN

                        If l_transactions_interface_rec.subinventory_code is not null THEN
                            open get_si_locator_control_code ( l_transactions_interface_rec.organization_id ,
                                 l_transactions_interface_rec.subinventory_code ) ;
                            fetch get_si_locator_control_code  into l_location_control_code ;
                            close get_si_locator_control_code;

                            If l_location_control_code = lc_inv_lv_loc_cntrl THEN


                                open get_inv_location_control_code ( l_transactions_interface_rec.organization_id ,
                                 l_transactions_interface_rec.inventory_item_id ) ;
                                fetch get_inv_location_control_code  into l_location_control_code ;
                                close get_inv_location_control_code;

                              end if;


                         end If;

                      end if;


                        If l_location_control_code in ( lc_predfn_loc_cntrl ,
                                     lc_dyn_loc_cntrl ) THEN

                                     l_locator_controlled := 'T' ;

                        end if;


                     --   dbms_output.put_line( 'l_locator_contrl is'
                      --    || l_locator_controlled );



                    If l_locator_controlled = 'T' THEN

                        IF p_mtl_txn_dtls_tbl(mtl_ctr).supply_locator_id is not null THEN

                        --    dbms_output.put_line( 'p_mtl_txn_dtls_tbl(mtl_ctr).supply_locator_id is'
                          --          || p_mtl_txn_dtls_tbl(mtl_ctr).supply_locator_id );

                            l_transactions_interface_rec.locator_id        := p_mtl_txn_dtls_tbl(mtl_ctr).supply_locator_id;

                        ELSE

      /*                      IF fnd_profile.value('CSD_DEF_REP_INV_ORG') = p_mtl_txn_dtls_tbl(mtl_ctr).organization_id and
                                fnd_profile.value('CSD_DEF_HV_LOC_ID') is not null THEN


                                l_transactions_interface_rec.locator_id        := fnd_profile.value('CSD_DEF_HV_LOC_ID');
                                         dbms_output.put_line( 'l_transactions_interface_rec.locator_id is'
                                    || l_transactions_interface_rec.locator_id );

                            ELSE  */

                                l_row_need_details_flag := 'T';
       --                     END IF;
                        END IF;
                    END IF;

                    -- Lot Contrrolled Check
                    -- Later Need to handle it here as well - based on profile
                    -- Value

                    IF p_mtl_txn_dtls_tbl(mtl_ctr).lot_control_code
                                                = lc_full_lot_control THEN

                        l_row_need_details_flag := 'T' ;

                    END IF;



                       IF p_mtl_txn_dtls_tbl(mtl_ctr).serial_number_control_code
                        in ( lc_predefined_serial_control, lc_inven_rct_srl_control) THEN

                            IF ( abs(p_mtl_txn_dtls_tbl(mtl_ctr).transaction_quantity) > 1 ) THEN


                                l_row_need_details_flag := 'T' ;


                                If p_mtl_txn_dtls_tbl(mtl_ctr).transaction_quantity > 0 then

                                        l_transactions_interface_rec.transaction_quantity  := -1;
                                else

                                        l_transactions_interface_rec.transaction_quantity  := 1;
                                end if;


                               FOR l_qty_ctr IN 1..abs(p_mtl_txn_dtls_tbl(mtl_ctr).transaction_quantity)
                                LOOP


                                    --insert into table mtl_transactions_interface

                                    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                                      FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                                    lc_mod_name||'beforecallinserttxnshdr',
                                    'Just before calling insert_transactions_header');
                                    END IF;

                                    l_transactions_interface_rec.source_line_id := -1;
                                    -- -1 identifies rows which are queried up in the details UI


                                    insert_transactions_header(   p_transactions_interface_rec  =>    l_transactions_interface_rec,
                                           x_return_status  =>    x_return_status );


                                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                    END IF;

                                    IF l_qty_ctr <> p_mtl_txn_dtls_tbl(mtl_ctr).transaction_quantity THEN
                                        -- generate transaction_interface_id for the next record
                                        open get_mtl_header_id;
                                        fetch get_mtl_header_id into l_transactions_interface_rec.transaction_interface_id;
                                        close get_mtl_header_id;
                                    END IF;


                                END LOOP;

                             ELSE  -- quantity =1, serial controlled

                                  IF p_mtl_txn_dtls_tbl(mtl_ctr).lot_control_code
                                                <> lc_full_lot_control THEN


                                    IF (  p_mtl_txn_dtls_tbl(mtl_ctr).serial_number is not null ) then


                                        l_srl_nmbrs_interface_rec.transaction_interface_id := l_transactions_interface_rec.transaction_interface_id;

                                        l_srl_nmbrs_interface_rec.fm_serial_number :=  p_mtl_txn_dtls_tbl(mtl_ctr).serial_number;

                                        IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                                          FND_LOG.STRING(   FND_LOG.LEVEL_EVENT,
                                        lc_mod_name||'beforecallinsertsrlnmbrs',
                                        'Just before calling insert_upd_serial_numbers');
                                        END IF;


                                        insert_upd_serial_numbers(   p_srl_nmbrs_interface_rec  =>    l_srl_nmbrs_interface_rec,
                                           x_return_status  =>    x_return_status );


                                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;

                                     ELSE

                                         l_row_need_details_flag := 'T';

                                     END IF;


                                    END IF;


                                    If l_row_need_details_flag = 'T' then

                                                l_transactions_interface_rec.source_line_id := -1;
                                                -- -1 identifies rows which are queried up in the details UI
                                    end if;

                                    --insert into table mtl_transactions_interface

                                    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                                      FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                                    lc_mod_name||'beforecallinserttxnshdr',
                                    'Just before calling insert_transactions_header');
                                    END IF;



                                    insert_transactions_header(   p_transactions_interface_rec  =>    l_transactions_interface_rec,
                                           x_return_status  =>    x_return_status );


                                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                    END IF;



                                END IF;


                        ELSE  -- not serial controlled


                                IF l_row_need_details_flag = 'T' THEN

                                        l_transactions_interface_rec.source_line_id := -1;
                                        -- -1 identifies rows which are queried up in the details UI
                                END IF;


                            --insert into table mtl_transactions_interface

                                IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                                  FND_LOG.STRING(  FND_LOG.LEVEL_EVENT,
                                lc_mod_name||'beforecallinserttxnshdr',
                                'Just before calling insert_transactions_header');
                                END IF;


                                insert_transactions_header(    p_transactions_interface_rec  =>    l_transactions_interface_rec,
                                           x_return_status  =>    x_return_status );


                                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;

                        END IF;

                    -- Here, check if required_quantity for the material is
                    -- equal to (issued_quantity + transaction_quantity) ,
                    -- Only if it is different, need to populate and call wip
                    -- update program

      l_primary_qty := INV_CONVERT.INV_UM_CONVERT
               ( item_id         => l_transactions_interface_rec.inventory_item_id
               , lot_number      => null
               , organization_id       => l_transactions_interface_rec.organization_id
               , precision       => 5
               , from_quantity   => p_mtl_txn_dtls_tbl(mtl_ctr).transaction_quantity
               , from_unit       => l_transactions_interface_rec.transaction_uom
               , to_unit         => p_mtl_txn_dtls_tbl(mtl_ctr).uom_code
               , from_name       => NULL
               , to_name         => NULL);

        --    dbms_output.put_line('primary qty is ' || l_primary_qty );

                    l_job_details_rec.required_quantity :=
                        nvl(p_mtl_txn_dtls_tbl(mtl_ctr).issued_quantity, 0)+
                        l_primary_qty;
                    --    p_mtl_txn_dtls_tbl(mtl_ctr).transaction_quantity;

                  --  l_job_details_rec.required_quantity := 60;

                    If l_job_details_rec.required_quantity <> p_mtl_txn_dtls_tbl(mtl_ctr).required_quantity THEN
                        l_wip_update_needed := 'T' ;


                    -- Get the Group_id to be used for WIP Mass Load,

                   SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.header_id FROM dual;

            --        l_job_header_rec.group_id := l_job_header_rec.header_id;

            --        l_job_details_rec.group_id         := l_job_header_rec.header_id;
                    l_job_details_rec.parent_header_id := l_job_header_rec.header_id;



                   --   SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.interface_id FROM dual;


                        --Commenting out as don't think this is needed
                        -- Need to remove ro_quantity as well, later on if not neede
                        l_job_details_rec.quantity_per_assembly := l_job_details_rec.required_quantity / p_mtl_txn_dtls_tbl(mtl_ctr).job_quantity;

                       -- l_job_details_rec.quantity_per_assembly := 3;

                        l_job_header_rec.wip_entity_id := p_mtl_txn_dtls_tbl(mtl_ctr).wip_entity_id;
                        l_job_header_rec.organization_id   := p_mtl_txn_dtls_tbl(mtl_ctr).organization_id;

                        l_job_details_rec.inventory_item_id_old := p_mtl_txn_dtls_tbl(mtl_ctr).inventory_item_id;
                        l_job_details_rec.operation_seq_num := p_mtl_txn_dtls_tbl(mtl_ctr).operation_seq_num;
                        l_job_details_rec.organization_id   := p_mtl_txn_dtls_tbl(mtl_ctr).organization_id;

                        l_job_details_rec.wip_entity_id     := p_mtl_txn_dtls_tbl(mtl_ctr).wip_entity_id;

                    -- Call procedures to insert job header and job details information
                    -- into wip interface tables

                    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                          FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsertjob',
                        'Just before calling insert_job_header');
                       END IF;


                        insert_job_header(   p_job_header_rec  =>    l_job_header_rec,
                               x_return_status  =>    x_return_status );


                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;


                    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                          FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsertjobdtls',
                        'Just before calling insert_job_details');
                          END IF;

              /*          dbms_output.put_line('ll_job_details_rec.required_quantity is '
                              || l_job_details_rec.required_quantity );

                        dbms_output.put_line('ll_job_details_rec.quantity_per_assembly is '
                              || l_job_details_rec.quantity_per_assembly ); */

                        insert_job_details(     p_job_details_rec    =>    l_job_details_rec,
                                  x_return_status  =>    x_return_status );

                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;


                    END IF;


                    ---- Update CSD_WIP_TRANSACTION_DETAILS rows to have null values

                    If p_mtl_txn_dtls_tbl(mtl_ctr).WIP_TRANSACTION_DETAIL_ID is not null then

                        IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                              FND_LOG.STRING(   FND_LOG.LEVEL_EVENT,
                            lc_mod_name||'beforecallupdaterow',
                            'Just before calling CSD_WIP_TRANSACTION_DTLS_PKG.Delete_Row');
                              END IF;



     /*               CSD_WIP_TRANSACTION_DTLS_PKG.Update_Row(
                        p_WIP_TRANSACTION_DETAIL_ID  => p_mtl_txn_dtls_tbl(mtl_ctr).WIP_TRANSACTION_DETAIL_ID
                        ,p_CREATED_BY                 => null
                        ,p_CREATION_DATE              => null
                        ,p_LAST_UPDATED_BY            => l_last_updated_by
                        ,p_LAST_UPDATE_DATE           => l_last_update_date
                        ,p_LAST_UPDATE_LOGIN          => l_last_update_login
                        ,p_INVENTORY_ITEM_ID          => null
                        ,p_WIP_ENTITY_ID              => null
                        ,p_OPERATION_SEQ_NUM          => null
                        ,p_RESOURCE_SEQ_NUM           => null
                        ,p_INSTANCE_ID                => null
                        ,p_TRANSACTION_QUANTITY       => FND_API.G_MISS_NUM
                        ,p_TRANSACTION_UOM            => FND_API.G_MISS_CHAR
                        ,p_SERIAL_NUMBER              => FND_API.G_MISS_CHAR
                        ,p_OBJECT_VERSION_NUMBER      => p_mtl_txn_dtls_tbl(mtl_ctr).object_version_number
                        );   */

                        CSD_WIP_TRANSACTION_DTLS_PKG.Delete_Row(
                        p_WIP_TRANSACTION_DETAIL_ID  => p_mtl_txn_dtls_tbl(mtl_ctr).WIP_TRANSACTION_DETAIL_ID );


                    end if;

            IF l_row_need_details_flag = 'T' THEN

                l_row_need_details_flag := 'F';
                l_need_details_flag := 'T' ;

            END IF;

        END LOOP;

        IF l_need_details_flag = 'T' THEN

            x_transaction_header_id := l_transactions_interface_rec.transaction_header_id;

        END IF;

        IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallprocesstxns',
                        'Just before calling INV_TXN_MANAGER_PUB.process_Transactions');
        END IF;

     --  dbms_output.put_line('Before call to INV_TXN_MANAGER_PUB.process_Transactions');

        -- If transaction_header_id is null, then details are not needed
        IF l_need_details_flag = 'F' THEN

         l_return_count := INV_TXN_MANAGER_PUB.process_Transactions(
                p_api_version         => lc_api_version_number, --1.0, --           ,
                p_init_msg_list       => fnd_api.g_false, --'T', -- fnd_api.g_false    ,
                p_commit              => fnd_api.g_false, --'T', -- fnd_api.g_false     ,
                p_validation_level    => p_validation_level  ,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                x_trans_count         => l_trans_count,
                p_table               => l_table,
                p_header_id           => l_transactions_interface_rec.transaction_header_id  );


               If ( txn_int_error_exists( l_transactions_interface_rec.transaction_header_id )  or
                   x_return_status <> FND_API.G_RET_STS_SUCCESS )  THEN
                --    x_msg_data := x_msg_data||' after pt ' ;
                --  ROLLBACK to PROCESS_ISSUE_MTL_TXN_PVT ;


--                  IF nvl( x_msg_count, 0 )  = 0 THEN

                      FND_MESSAGE.SET_NAME('CSD','CSD_MAT_TXN_FAILURE');
                         FND_MSG_PUB.ADD;

                         RAISE FND_API.G_EXC_ERROR;

    --               END IF;



          --          RETURN;

                END IF;

        END IF;



       -- Call WIP Mass Load API

       -- Comment out for now - till WIP API works - Uncomment later

        IF l_wip_update_needed = 'T' THEN

          --   dbms_output.put_line('before WIP Update Call');

          BEGIN

            WIP_MASSLOAD_PUB.massLoadJobs(p_groupID   => l_job_header_rec.group_id,
                         p_validationLevel       => p_validation_level,
                         p_commitFlag            => 1,-- needs to be changed to 0 later, once WIP works
                         x_returnStatus          => x_return_status,
                         x_errorMsg              => x_msg_data );


                    If ( ml_error_exists( l_job_header_rec.group_id )  or
                        x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN


                            FND_MESSAGE.SET_NAME('CSD','CSD_MTL_ISS_MASS_LD_FAILURE');
                              FND_MSG_PUB.ADD;
                           x_return_status := FND_API.G_RET_STS_ERROR;

                             FND_MSG_PUB.count_and_get(  p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

                              RETURN;
                              -- Need to rollback  Raise exception -
                            -- once commit is removed from above call

                    end if;

                EXCEPTION
                  WHEN OTHERS THEN

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

                      FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
                END IF;

                FND_MSG_PUB.count_and_get(   p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

                 END;


/*            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              -- ROLLBACK to PROCESS_ISSUE_MTL_TXN_PVT ;
            --   dbms_output.put_line('WIP Update Error');


                 FND_MESSAGE.SET_NAME('CSD','CSD_MAT_TXN_FAILURE');
                   FND_MSG_PUB.ADD;
                   RETURN;  */
                 --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


      /*          IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                              FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                                lc_mod_name||'exc_exception',
                            'G_EXC_ERROR Exception');
                END IF;

                RETURN;  */

          --  END IF;
         END IF;





-- Standard check for p_commit
        IF l_need_details_flag = 'F' and FND_API.to_Boolean( p_commit )
        THEN
            COMMIT WORK;
        END IF;

EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
        --    dbms_output.put_line( 'FND_API.G_EXC_UNEXPECTED_ERROR error'|| sqlerrm);
         ROLLBACK to PROCESS_ISSUE_MTL_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_ISSUE_MTL_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
        --  dbms_output.put_line( 'OTHERS error' || sqlerrm );
         ROLLBACK to PROCESS_ISSUE_MTL_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      --    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
       --   END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;



END process_issue_mtl_txn;

--
-- Updates the transaction lines with lot and serial numbers
-- and the processes the transaction lines
--
PROCEDURE process_issue_mtl_txns_lot_srl
(
    p_api_version_number                      IN         NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                  IN         VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                           OUT NOCOPY VARCHAR2,
    x_msg_count                               OUT NOCOPY NUMBER,
    x_msg_data                                OUT NOCOPY VARCHAR2,
    p_mtl_txn_dtls_tbl                        IN         MTL_TXN_DTLS_TBL_TYPE,
    p_transaction_header_id                   IN         NUMBER
)
IS
   lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_ISSUE_MTL_TXNS_LOT_SRL';
   lc_api_version_number      CONSTANT NUMBER := 1.0;

   -- constants used for FND_LOG debug messages
   lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_issue_mtl_txns_lot_srl';

BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     lc_mod_name||'begin',
                     'Entering private API process_issue_mtl_txns_lot_srl' );
   END IF;

   SAVEPOINT PROCESS_MTL_TXNS_LOT_SRL_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (lc_api_version_number,
      p_api_version_number,
      lc_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
               lc_mod_name||'beforecallinsertjobcomptxn',
               'Just before calling insert_job_comp_txn');
   END IF;
   update_mtl_txns_lot_srl (
       p_api_version_number       => lc_api_version_number,
       p_init_msg_list            => fnd_api.g_false ,
       p_commit                   => fnd_api.g_false,
       p_validation_level         => p_validation_level,
       x_return_status            => x_return_status,
       x_msg_count                => x_msg_count,
       x_msg_data                 => x_msg_data,
       p_mtl_txn_dtls_tbl         => p_mtl_txn_dtls_tbl,
       p_transaction_header_id    => p_transaction_header_id
   );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS )  THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_MAT_TXN_FAILURE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
               lc_mod_name||'beforecallprocesstxn',
               'Just before calling process_mti_transactions');
   END IF;
   process_mti_transactions(
       p_api_version_number       => lc_api_version_number,
       p_init_msg_list            => fnd_api.g_false ,
       p_commit                   => fnd_api.g_false,
       p_validation_level         => p_validation_level,
       x_return_status            => x_return_status,
       x_msg_count                => x_msg_count,
       x_msg_data                 => x_msg_data,
       p_txn_header_id            => p_transaction_header_id
      --  p_txn_type                                IN         VARCHAR2
   );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS )  THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_MAT_TXN_FAILURE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
      ROLLBACK to PROCESS_MTL_TXNS_LOT_SRL_PVT ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                 p_count  => x_msg_count,
                                 p_data   => x_msg_data);

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                     lc_mod_name||'unx_exception',
                     'G_EXC_UNEXPECTED_ERROR Exception');
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK to PROCESS_MTL_TXNS_LOT_SRL_PVT ;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                 p_count  => x_msg_count,
                                 p_data   => x_msg_data);

      IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                     lc_mod_name||'exc_exception',
                     'G_EXC_ERROR Exception');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK to PROCESS_MTL_TXNS_LOT_SRL_PVT ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error
         FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => lc_api_name );
      END IF;

      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                     lc_mod_name||'others_exception',
                     'OTHERS Exception');
      END IF;
END process_issue_mtl_txns_lot_srl;

--
-- Updates the material transaction lines with lot and serial numbers only
-- Does NOT process the transaction lines
--
PROCEDURE update_mtl_txns_lot_srl
(
    p_api_version_number                      IN         NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                  IN         VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                           OUT NOCOPY VARCHAR2,
    x_msg_count                               OUT NOCOPY NUMBER,
    x_msg_data                                OUT NOCOPY VARCHAR2,
    p_mtl_txn_dtls_tbl                        IN         MTL_TXN_DTLS_TBL_TYPE,
    p_transaction_header_id                   IN         NUMBER
)
IS
   lc_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_MTL_TXNS_LOT_SRL';
   lc_api_version_number      CONSTANT NUMBER := 1.0;

   -- constants used for FND_LOG debug messages
   lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.update_mtl_txns_lot_srl';

   lc_revision_controlled       CONSTANT    NUMBER  := 2;
   lc_full_lot_control          CONSTANT    NUMBER  := 2;
   lc_predefined_serial_control CONSTANT    NUMBER  := 2;
   lc_inven_rct_srl_control     CONSTANT    NUMBER  := 5;

   -- Records to hold mtl_transactions_interface data
   l_transactions_interface_rec          mtl_transactions_interface%ROWTYPE;
   l_txn_lots_interface_rec              mtl_transaction_lots_interface%ROWTYPE;
   l_srl_nmbrs_interface_rec             mtl_serial_numbers_interface%ROWTYPE;

   CURSOR get_mtl_header_id IS
      SELECT mtl_material_transactions_s.nextval from dual;

BEGIN

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     lc_mod_name||'begin',
                     'Entering private API update_mtl_txns_lot_srl' );
   END IF;

   SAVEPOINT UPDATE_MTL_TXNS_LOT_SRL_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (lc_api_version_number,
      p_api_version_number,
      lc_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR mtl_ctr in p_mtl_txn_dtls_tbl.FIRST.. p_mtl_txn_dtls_tbl.LAST
   LOOP
      l_transactions_interface_rec.subinventory_code := p_mtl_txn_dtls_tbl(mtl_ctr).supply_subinventory;
      l_transactions_interface_rec.locator_id        := p_mtl_txn_dtls_tbl(mtl_ctr).supply_locator_id;
      l_transactions_interface_rec.revision          := p_mtl_txn_dtls_tbl(mtl_ctr).revision;
      l_transactions_interface_rec.transaction_interface_id := p_mtl_txn_dtls_tbl(mtl_ctr).transaction_interface_id;
      l_transactions_interface_rec.source_line_id    := p_mtl_txn_dtls_tbl(mtl_ctr).operation_seq_num;
      l_transactions_interface_rec.reason_id    := p_mtl_txn_dtls_tbl(mtl_ctr).reason_id;  -- swai bug 6841113

      --Update table mtl_transactions_interface
      IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
         lc_mod_name||'beforecallupdtxnhdr',
         'Just before calling update_transactions_header');
      END IF;

      update_transactions_header(p_transactions_interface_rec  =>    l_transactions_interface_rec,
                                x_return_status  =>    x_return_status );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Check for Lot Control
      IF p_mtl_txn_dtls_tbl(mtl_ctr).lot_control_code = lc_full_lot_control THEN
         l_txn_lots_interface_rec.transaction_interface_id := l_transactions_interface_rec.transaction_interface_id;
         l_txn_lots_interface_rec.lot_number := p_mtl_txn_dtls_tbl(mtl_ctr).lot_number;
         l_txn_lots_interface_rec.transaction_quantity := p_mtl_txn_dtls_tbl(mtl_ctr).transaction_quantity;

         IF p_mtl_txn_dtls_tbl(mtl_ctr).SERIAL_NUMBER_CONTROL_CODE in ( lc_predefined_serial_control , lc_inven_rct_srl_control ) THEN
            -- generate transaction_id
            open get_mtl_header_id;
            fetch get_mtl_header_id into l_txn_lots_interface_rec.serial_transaction_temp_id;
            close get_mtl_header_id;

            l_srl_nmbrs_interface_rec.transaction_interface_id := l_txn_lots_interface_rec.serial_transaction_temp_id;
            l_srl_nmbrs_interface_rec.fm_serial_number :=  p_mtl_txn_dtls_tbl(mtl_ctr).serial_number;

            IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                              lc_mod_name||'beforecallinsertsrlnmbrs',
                              'Just before calling insert_upd_serial_numbers');
            END IF;

            insert_upd_serial_numbers(p_srl_nmbrs_interface_rec => l_srl_nmbrs_interface_rec,
                                      x_return_status           =>  x_return_status);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                           lc_mod_name||'beforecallinserttxnslots',
                           'Just before calling insert_transaction_lots');
         END IF;

         insert_transaction_lots(p_txn_lots_interface_rec  =>    l_txn_lots_interface_rec,
                                 x_return_status           =>    x_return_status );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSE   -- not lc_full_lot_control
         IF p_mtl_txn_dtls_tbl(mtl_ctr).SERIAL_NUMBER_CONTROL_CODE in ( lc_predefined_serial_control , lc_inven_rct_srl_control ) THEN
            l_srl_nmbrs_interface_rec.transaction_interface_id := l_transactions_interface_rec.transaction_interface_id;
            l_srl_nmbrs_interface_rec.fm_serial_number :=  p_mtl_txn_dtls_tbl(mtl_ctr).serial_number;

            IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                              lc_mod_name||'beforecallinsertsrlnbrs',
                              'Just before calling insert_upd_serial_numbers');
            END IF;

            insert_upd_serial_numbers(p_srl_nmbrs_interface_rec => l_srl_nmbrs_interface_rec,
                                      x_return_status           => x_return_status );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      END IF;  -- end lot control condition
   END LOOP;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
      ROLLBACK to UPDATE_MTL_TXNS_LOT_SRL_PVT ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                 p_count  => x_msg_count,
                                 p_data   => x_msg_data);

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                     lc_mod_name||'unx_exception',
                     'G_EXC_UNEXPECTED_ERROR Exception');
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK to UPDATE_MTL_TXNS_LOT_SRL_PVT ;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

      IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                     lc_mod_name||'exc_exception',
                     'G_EXC_ERROR Exception');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK to UPDATE_MTL_TXNS_LOT_SRL_PVT ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error
         FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => lc_api_name );
      END IF;

      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                     lc_mod_name||'others_exception',
                     'OTHERS Exception');
      END IF;
END update_mtl_txns_lot_srl;


PROCEDURE process_transact_res_txn
(
    p_api_version_number                        IN          NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_commit                                    IN          VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                             OUT   NOCOPY   VARCHAR2,
    x_msg_count                                  OUT  NOCOPY      NUMBER,
    x_msg_data                                OUT      NOCOPY     VARCHAR2,
    p_res_txn_dtls_tbl                       IN       RES_TXN_DTLS_TBL_TYPE
  --  p_ro_quantity                               IN      NUMBER
)
IS

        lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_TRANSACT_RES_TXN';
        lc_api_version_number      CONSTANT NUMBER := 1.0;

      -- constants used for FND_LOG debug messages

      lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_transact_res_txn';


      -- Constants Used for Inserting into wip_job_schedule_interface,
      -- and details interface tables

      lc_non_std_update_load_type      CONSTANT NUMBER := 3;
      lc_load_res_type  CONSTANT        NUMBER := 1;
      lc_substitution_change_type CONSTANT                  NUMBER := 3;


        -- Constants used for inserting into wip_cost_txn_interface

         lc_res_transaction_type  CONSTANT  NUMBER := 1;


          -- Records to hold the Job header,details
          -- and wip_cost_txn_interface data

       l_wip_cost_txn_interface_rec                wip_cost_txn_interface%ROWTYPE;
        l_job_header_rec                wip_job_schedule_interface%ROWTYPE;
        l_job_details_rec           wip_job_dtls_interface%ROWTYPE;


      l_last_update_date DATE;
      l_last_updated_by NUMBER;
      l_last_update_login NUMBER;

      l_required_quantity NUMBER;

      l_wip_update_needed  VARCHAR2(1) := 'F';

      conversion_rate  NUMBER;
      primary_qty      NUMBER;



BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering private API process_transact_res_txn' );
      END IF;

        SAVEPOINT PROCESS_TRANSACT_RES_TXN_PVT;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call
           (lc_api_version_number,
            p_api_version_number,
            lc_api_name,
            G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
        END IF;




      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Populate the row who columns

      l_last_update_date := SYSDATE;
      l_last_updated_by := fnd_global.user_id;
      l_last_update_login := fnd_global.login_id;


      -- Populate the constant values

        l_job_header_rec.load_type := lc_non_std_update_load_type;

        l_job_details_rec.completion_date   := sysdate;

        l_job_details_rec.load_type := lc_load_res_type;

        l_job_details_rec.substitution_type := lc_substitution_change_type;


     --   l_job_details_rec.autocharge_type := fnd_profile.value('CSD_HV_ATCHG_TYP');

        --  If autocharge_type is null, throw an error and return;
        -- Uncomment following later - once profiles are defined
   /*     IF l_job_details_rec.autocharge_type is NULL THEN

              FND_MESSAGE.SET_NAME('CSD','CSD_ATCHG_TYP_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
        end if;


        l_job_details_rec.basis_type      := fnd_profile.value('CSD_HV_BASIS_TYP');

        --  If basis_type is null, throw an error and return;

        IF l_job_details_rec.basis_type is NULL THEN

              FND_MESSAGE.SET_NAME('CSD','CSD_BASIS_TYP_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
        end if;

        l_job_details_rec.scheduled_flag  := fnd_profile.value('CSD_HV_SCD_FLG');

        --  If scheduled_flag is null, throw an error and return;

        IF l_job_details_rec.scheduled_flag is NULL THEN

              FND_MESSAGE.SET_NAME('CSD','CSD_SCD_FLG_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
        end if;

        l_job_details_rec.standard_rate_flag  := fnd_profile.value('CSD_HV_STD_FLG');

        --  If standard_rate_flag is null, throw an error and return;

        IF l_job_details_rec.standard_rate_flag is NULL THEN

              FND_MESSAGE.SET_NAME('CSD','CSD_STD_FLG_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
        end if;  */

        l_wip_cost_txn_interface_rec.transaction_date := sysdate;
        l_wip_cost_txn_interface_rec.transaction_type := lc_res_transaction_type;


        -- Get the Group_id to be used for WIP Mass Load,

       SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.group_id FROM dual;

   --     l_job_header_rec.group_id := l_job_header_rec.header_id;

        l_job_details_rec.group_id         := l_job_header_rec.group_id;
   --     l_job_details_rec.parent_header_id := l_job_header_rec.group_id;



        FOR res_ctr in p_res_txn_dtls_tbl.FIRST.. p_res_txn_dtls_tbl.LAST

        LOOP

                    l_wip_cost_txn_interface_rec.operation_seq_num := p_res_txn_dtls_tbl(res_ctr).operation_seq_num;
                    l_wip_cost_txn_interface_rec.organization_id := p_res_txn_dtls_tbl(res_ctr).organization_id;
                    l_wip_cost_txn_interface_rec.organization_code := p_res_txn_dtls_tbl(res_ctr).organization_code;
                    l_wip_cost_txn_interface_rec.resource_seq_num := p_res_txn_dtls_tbl(res_ctr).resource_seq_num;
                    l_wip_cost_txn_interface_rec.transaction_quantity := p_res_txn_dtls_tbl(res_ctr).transaction_quantity;

                    If l_wip_cost_txn_interface_rec.transaction_quantity = 0 then
                        FND_MESSAGE.SET_NAME('CSD','CSD_TRX_QTY_ZERO');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    end if;

                    l_wip_cost_txn_interface_rec.transaction_uom := p_res_txn_dtls_tbl(res_ctr).transaction_uom;
                    l_wip_cost_txn_interface_rec.wip_entity_name := p_res_txn_dtls_tbl(res_ctr).wip_entity_name;
                    l_wip_cost_txn_interface_rec.wip_entity_id := p_res_txn_dtls_tbl(res_ctr).wip_entity_id;

             --       l_wip_cost_txn_interface_rec.employee_id     := p_res_txn_dtls_tbl(res_ctr).employee_id;

                    l_wip_cost_txn_interface_rec.employee_id     := p_res_txn_dtls_tbl(res_ctr).employee_id;
                    l_wip_cost_txn_interface_rec.employee_num     := p_res_txn_dtls_tbl(res_ctr).employee_num;

                    --insert into table wip_cost_txn_interface

                    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsertwipcosttxn',
                        'Just before calling insert_wip_cost_txn');
                    END IF;

       -- get conversion rate based on UOM
        conversion_rate :=
          inv_convert.inv_um_convert(
            item_id       => 0,
            precision     => 38,
            from_quantity => 1,
            from_unit     => p_res_txn_dtls_tbl(res_ctr).uom_code,
            to_unit       => l_wip_cost_txn_interface_rec.transaction_uom ,
            from_name     => NULL,
            to_name       => NULL);



        -- perform UOM conversion
        primary_qty := p_res_txn_dtls_tbl(res_ctr).transaction_quantity / conversion_rate;
   --       to_number(name_in(RESOURCE_TRANSACTIONS.APP_TRANSACTION_QUANTITY)) /
   --       res_transactions_uom.conversion_rate;



                    insert_wip_cost_txn(     p_wip_cost_txn_interface_rec  =>    l_wip_cost_txn_interface_rec,
                                           x_return_status  =>    x_return_status );


                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;







                    -- Here, check if required_quantity for the material is
                    -- equal to (issued_quantity + transaction_quantity) ,
                    -- Only if it is different, need to populate and call wip
                    -- update program

                    l_required_quantity :=
                         nvl(p_res_txn_dtls_tbl(res_ctr).applied_quantity, 0)+
                   --    nvl(p_res_txn_dtls_tbl(res_ctr).required_quantity, 0)+
                        primary_qty;
                 --       p_res_txn_dtls_tbl(res_ctr).transaction_quantity +
                 --       nvl(p_res_txn_dtls_tbl(res_ctr).pending_quantity, 0);

                  --  l_job_details_rec.required_quantity := 60;

                    If l_required_quantity <> p_res_txn_dtls_tbl(res_ctr).required_quantity THEN
                        l_wip_update_needed := 'T' ;

                        --Commenting out as don't think this is needed
                        -- Need to remove ro_quantity as well, later on if not neede
                       -- l_job_details_rec.quantity_per_assembly := l_required_quantity / p_ro_quantity;

        -- Get the Group_id to be used for WIP Mass Load,

       SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.header_id FROM dual;

    --    l_job_header_rec.group_id := l_job_header_rec.header_id;

    --    l_job_details_rec.group_id         := l_job_header_rec.group_id;
        l_job_details_rec.parent_header_id := l_job_header_rec.header_id;

                    l_job_header_rec.wip_entity_id := p_res_txn_dtls_tbl(res_ctr).wip_entity_id;
                    l_job_header_rec.organization_id := p_res_txn_dtls_tbl(res_ctr).organization_id;

                    l_job_details_rec.resource_id_old := p_res_txn_dtls_tbl(res_ctr).resource_id;
                    l_job_details_rec.resource_id_new := p_res_txn_dtls_tbl(res_ctr).resource_id;

                    l_job_details_rec.resource_seq_num := p_res_txn_dtls_tbl(res_ctr).resource_seq_num;
                    l_job_details_rec.operation_seq_num := p_res_txn_dtls_tbl(res_ctr).operation_seq_num;
                    l_job_details_rec.organization_id   := p_res_txn_dtls_tbl(res_ctr).organization_id;
                 --   l_job_details_rec.uom_code          := p_res_txn_dtls_tbl(res_ctr).uom_code;
                    If p_res_txn_dtls_tbl(res_ctr).basis_type = 1 then
                        l_job_details_rec.usage_rate_or_amount := l_required_quantity / p_res_txn_dtls_tbl(res_ctr).op_scheduled_quantity ;
                    else
                        l_job_details_rec.usage_rate_or_amount := l_required_quantity;
                    END IF;
                --    l_job_details_rec.usage_rate_or_amount := l_required_quantity / p_res_txn_dtls_tbl(res_ctr).job_quantity;
                    l_job_details_rec.wip_entity_id     := p_res_txn_dtls_tbl(res_ctr).wip_entity_id;



                    -- Call procedures to insert job header and job details information
                    -- into wip interface tables

                 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsertjob',
                        'Just before calling insert_job_header');
                      END IF;


                    insert_job_header(    p_job_header_rec  =>    l_job_header_rec,
                               x_return_status  =>    x_return_status );


                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;


                 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsertjobdtls',
                        'Just before calling insert_job_details');
                      END IF;


                    insert_job_details(   p_job_details_rec    =>    l_job_details_rec,
                               x_return_status  =>    x_return_status );

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                END IF;


                    ---- Update CSD_WIP_TRANSACTION_DETAILS rows to have null values

                    If p_res_txn_dtls_tbl(res_ctr).WIP_TRANSACTION_DETAIL_ID is not null then

                        IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                              FND_LOG.STRING(   FND_LOG.LEVEL_EVENT,
                            lc_mod_name||'beforecallupdaterow',
                            'Just before calling CSD_WIP_TRANSACTION_DTLS_PKG.Delete_Row');
                              END IF;



            /*        CSD_WIP_TRANSACTION_DTLS_PKG.Update_Row(
                        p_WIP_TRANSACTION_DETAIL_ID  => p_res_txn_dtls_tbl(res_ctr).WIP_TRANSACTION_DETAIL_ID
                        ,p_CREATED_BY                 => null
                        ,p_CREATION_DATE              => null
                        ,p_LAST_UPDATED_BY            => l_last_updated_by
                        ,p_LAST_UPDATE_DATE           => l_last_update_date
                        ,p_LAST_UPDATE_LOGIN          => l_last_update_login
                        ,p_INVENTORY_ITEM_ID          => null
                        ,p_WIP_ENTITY_ID              => null
                        ,p_OPERATION_SEQ_NUM          => null
                        ,p_RESOURCE_SEQ_NUM           => null
                        ,p_INSTANCE_ID                => null
                        ,p_TRANSACTION_QUANTITY       => FND_API.G_MISS_NUM
                        ,p_TRANSACTION_UOM            => FND_API.G_MISS_CHAR
                        ,p_SERIAL_NUMBER              => FND_API.G_MISS_CHAR
                        ,p_OBJECT_VERSION_NUMBER      => p_res_txn_dtls_tbl(res_ctr).object_version_number
                        );   */


                        CSD_WIP_TRANSACTION_DTLS_PKG.Delete_Row(
                        p_WIP_TRANSACTION_DETAIL_ID  => p_res_txn_dtls_tbl(res_ctr).WIP_TRANSACTION_DETAIL_ID );

                    end if;


        END LOOP;


       -- Call WIP Mass Load API
     -- Uncomment Later

     IF l_wip_update_needed = 'T' THEN

     BEGIN

       WIP_MASSLOAD_PUB.massLoadJobs(p_groupID   => l_job_header_rec.group_id,
                         p_validationLevel       => p_validation_level,
                         p_commitFlag            => 1, -- make it 0 later, once WIP works
                         x_returnStatus          => x_return_status,
                         x_errorMsg              => x_msg_data );

                    If ( ml_error_exists( l_job_header_rec.group_id )  or
                        x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

                            FND_MESSAGE.SET_NAME('CSD','CSD_RES_TXN_MASS_LD_FAILURE');
                              FND_MSG_PUB.ADD;
                           x_return_status := FND_API.G_RET_STS_ERROR;

                             FND_MSG_PUB.count_and_get(  p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

                              RETURN;
                              -- Need to rollback Raise exception -
                            -- once commit is removed from above call

                    end if;

       EXCEPTION
        WHEN OTHERS THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

        END;


 /*       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              --  ROLLBACK to PROCESS_TRANSACT_RES_TXN_PVT ;

                 FND_MESSAGE.SET_NAME('CSD','CSD_RES_TXN_FAILURE');
                   FND_MSG_PUB.ADD;
                   RETURN; -- later - once wip works - can remove this
                   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           */


         /*       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                              FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                                lc_mod_name||'exc_exception',
                            'G_EXC_ERROR Exception');
                END IF;

                RETURN;  */

     --   END IF;

     END IF;


-- Standard check for p_commit
        IF FND_API.to_Boolean( p_commit )
        THEN
            COMMIT WORK;
        END IF;

EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_TRANSACT_RES_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_TRANSACT_RES_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_TRANSACT_RES_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;



END process_transact_res_txn;



PROCEDURE PROCESS_SAVE_MTL_TXN_DTLS
(
    p_api_version_number                      IN           NUMBER,
    p_init_msg_list                           IN           VARCHAR2 ,
    p_commit                                  IN           VARCHAR2 ,
    p_validation_level                        IN           NUMBER ,
    x_return_status                           OUT  NOCOPY  VARCHAR2,
    x_msg_count                               OUT  NOCOPY  NUMBER,
    x_msg_data                                OUT  NOCOPY  VARCHAR2,
    p_mtl_txn_dtls_tbl                        IN           MTL_TXN_DTLS_TBL_TYPE,
    x_op_created                              OUT  NOCOPY  VARCHAR
   -- p_ro_quantity                               IN           NUMBER
)
IS
      lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_SAVE_CSD_MTL_TXN_DTLS';
      lc_api_version_number      CONSTANT NUMBER := 1.0;

      -- constants used for FND_LOG debug messages
      lc_mod_name                 CONSTANT VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_save_mtl_txn_dtls';

      -- Constants Used for Inserting into wip_job_schedule_interface,
      -- These are the values needed for WIP Mass Load to pick up the records

      -- Non Standard Update Discrete Job Load Type
      lc_non_std_update_load_type      CONSTANT NUMBER := 3;


      lc_load_mtl_type  CONSTANT        NUMBER := 2;

      lc_substitution_add_type CONSTANT                  NUMBER := 2;
      -- 11/7/05
      --   lc_mrp_net_flag   CONSTANT        NUMBER  := 1;
      -- 11/7/05
      --   lc_push_wip_supply_type CONSTANT  NUMBER  := 1;


      -- Job Records to hold the Job header and details information
      l_job_header_rec                wip_job_schedule_interface%ROWTYPE;
      l_job_details_rec           wip_job_dtls_interface%ROWTYPE;


      l_creation_date DATE;
      l_last_update_date DATE;
      l_created_by NUMBER;
      l_created_by_name VARCHAr2(100);
      l_last_updated_by NUMBER;
      l_last_updated_by_name VARCHAR2(100);
      l_last_update_login NUMBER;


      l_mtl_load_type NUMBER;
      l_mrp_net_flag NUMBER;
      --   l_quantity_issued NUMBER;

      l_WIP_TRANSACTION_DETAIL_ID NUMBER;

      l_job_quantity NUMBER;

      l_op_seq_num   NUMBER;
      l_op_exists    VARCHAR2(10);
      l_op_dtls_tbl  OP_DTLS_TBL_TYPE;

      CURSOR get_job_quantity ( p_wip_entity_id NUMBER ) IS
         SELECT start_quantity from wip_discrete_jobs where
         wip_entity_id = p_wip_entity_id ;

      CURSOR get_operation_exists(p_wip_entity_id NUMBER ) IS
         SELECT 'exists'
         from wip_operations
         where wip_entity_id = p_wip_entity_id
           and rownum = 1;

      --bug#8465719 begin
      l_location_control_code     NUMBER;
      l_location_subinv_control_code     NUMBER;
      l_locator_controlled        VARCHAR2(1) := 'F';
      l_locator_subinv_controlled        VARCHAR2(1) := 'F';

      lc_none_loc_contrl          CONSTANT   NUMBER :=1;
      lc_predfn_loc_cntrl         CONSTANT   NUMBER   := 2;
      lc_dyn_loc_cntrl            CONSTANT    NUMBER   := 3;

      l_wip_supply_type           NUMBER;   --2 means assembly pull
                                          --3 means Operation Pull
      l_wip_supply_subinventory   VARCHAR2(10);
      l_wip_supply_locator_id     NUMBER;



      CURSOR get_inv_location_control_code ( p_organization_id NUMBER,
        p_inventory_item_id NUMBER )  IS
      select location_control_code from mtl_system_items_b where
      organization_id = p_organization_id and
      inventory_item_id = p_inventory_item_id;


      CURSOR get_si_locator_control_code ( p_organization_id NUMBER,
            p_secondary_inventory_name VARCHAR2 ) IS
      SELECT locator_type from mtl_secondary_inventories where
      organization_id = p_organization_id and
      secondary_inventory_name = p_secondary_inventory_name;


      CURSOR get_wip_supply_info ( p_organization_id NUMBER,
        p_inventory_item_id NUMBER )  IS
      select wip_supply_type, wip_supply_subinventory, wip_supply_locator_id
      from mtl_system_items_b where
      organization_id = p_organization_id and
      inventory_item_id = p_inventory_item_id;
      --bug#8465719 end



BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering private API process_save_mtl_txn_dtls' );
      END IF;

-- Standard Start of API savepoint
        SAVEPOINT PROCESS_SAVE_MTL_TXN_DTLS_PVT;
-- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call
           (lc_api_version_number,
            p_api_version_number,
            lc_api_name,
            G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
        END IF;


      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_op_created := FND_API.G_FALSE;

      -- Populate the constant values

      l_job_header_rec.load_type := lc_non_std_update_load_type;

        l_job_details_rec.date_required    := sysdate;
        l_job_details_rec.load_type := lc_load_mtl_type;

        l_job_details_rec.substitution_type := lc_substitution_add_type;

      --  11/7/05
      --  l_job_details_rec.mrp_net_flag := lc_mrp_net_flag;
        l_job_details_rec.mrp_net_flag := null;
      -- 11/7/05
       -- l_job_details_rec.wip_supply_type := lc_push_wip_supply_type;
        l_job_details_rec.wip_supply_type := null;


    --   l_quantity_issued := 0;


      -- Populate the row who columns

      l_creation_date := SYSDATE;
      l_last_update_date := SYSDATE;
      l_created_by := fnd_global.user_id;
      l_last_updated_by := fnd_global.user_id;
      l_last_update_login := fnd_global.login_id;




        FOR mtl_ctr in p_mtl_txn_dtls_tbl.FIRST.. p_mtl_txn_dtls_tbl.LAST

        LOOP
            -- use l_op_seq_num throughout this loop, since op seq num may
            -- change if value 1 was originally passed in.
            l_op_seq_num := p_mtl_txn_dtls_tbl(mtl_ctr).operation_seq_num;

            If p_mtl_txn_dtls_tbl(mtl_ctr).new_row = 'Y' then
              -- swai: check if there is an existing operation to add the material to.
              -- Otherwise, we will have to create an operation first.
              if (l_op_seq_num = 1) then
                  if (p_mtl_txn_dtls_tbl(mtl_ctr).wip_entity_id is not null) then
                     open get_operation_exists(l_job_details_rec.wip_entity_id);
                     fetch get_operation_exists into l_op_exists;
                     close get_operation_exists;
                  end if;
                  if (l_op_exists is null) then
                     -- create operation, but only if default department is specified
                     l_op_dtls_tbl(1).department_id := fnd_profile.value('CSD_DEF_HV_OP_DEPT');
                     if (l_op_dtls_tbl(1).department_id is null) then
                        -- No operations exist for the job and no default
                        -- department has been specified, so throw an error.
                        -- we cannot add the material to operation 1 since
                        -- it would force a wip_supply_type of pull, which
                        -- required backflush.
                        FND_MESSAGE.SET_NAME('CSD','CSD_DEF_OP_DEPT_NULL');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                     else
                        l_op_dtls_tbl(1).new_row           := 'Y';
                        l_op_dtls_tbl(1).wip_entity_id     := p_mtl_txn_dtls_tbl(mtl_ctr).wip_entity_id;
                        l_op_dtls_tbl(1).organization_id   := p_mtl_txn_dtls_tbl(mtl_ctr).organization_id;
                        l_op_dtls_tbl(1).operation_seq_num := 10; -- default operation seq 10
                        l_op_dtls_tbl(1).backflush_flag    := 2;  -- default backflush
                        l_op_dtls_tbl(1).count_point_type  := 1;  -- default count point
                        l_op_dtls_tbl(1).first_unit_completion_date := sysdate;
                        l_op_dtls_tbl(1).first_unit_start_date      := sysdate;
                        l_op_dtls_tbl(1).last_unit_completion_date  := sysdate;
                        l_op_dtls_tbl(1).last_unit_start_date       := sysdate;
                        l_op_dtls_tbl(1).minimum_transfer_quantity  := 0;

                        PROCESS_SAVE_OP_DTLS
                        (
                            p_api_version_number => 1.0,
                            p_init_msg_list      => fnd_api.g_false,
                            p_Commit             => fnd_api.g_false,
                            p_validation_level   => p_validation_level,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_op_dtls_tbl        => l_op_dtls_tbl
                        );
                        if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
                           l_op_seq_num := l_op_dtls_tbl(1).operation_seq_num;
                           x_op_created := FND_API.G_TRUE;
                        else
                           FND_MESSAGE.SET_NAME('CSD','CSD_OP_AUTO_CREATE_FAILURE');
                           FND_MSG_PUB.ADD;
                           RAISE FND_API.G_EXC_ERROR;
                        end if;
                     end if; -- department profile
                  end if;  -- operation does not exist
              end if;


              -- Get the Group_id to be used for WIP Mass Load,
              SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.group_id FROM dual;


              -- get job_quantity
              open get_job_quantity ( p_mtl_txn_dtls_tbl(mtl_ctr).wip_entity_id);
              fetch get_job_quantity into l_job_quantity;
              close get_job_quantity;


              l_job_header_rec.header_id := l_job_header_rec.group_id;
              l_job_header_rec.wip_entity_id := p_mtl_txn_dtls_tbl(mtl_ctr).wip_entity_id;
              l_job_header_rec.organization_id   := p_mtl_txn_dtls_tbl(mtl_ctr).organization_id;

              l_job_details_rec.group_id         := l_job_header_rec.group_id;
              l_job_details_rec.parent_header_id := l_job_header_rec.group_id;
              l_job_details_rec.inventory_item_id_new := p_mtl_txn_dtls_tbl(mtl_ctr).inventory_item_id;
              l_job_details_rec.operation_seq_num := l_op_seq_num; -- p_mtl_txn_dtls_tbl(mtl_ctr).operation_seq_num;
              l_job_details_rec.organization_id   := p_mtl_txn_dtls_tbl(mtl_ctr).organization_id;
              l_job_details_rec.quantity_per_assembly := p_mtl_txn_dtls_tbl(mtl_ctr).transaction_quantity / l_job_quantity;
              l_job_details_rec.required_quantity :=             p_mtl_txn_dtls_tbl(mtl_ctr).transaction_quantity;
              l_job_details_rec.wip_entity_id     := p_mtl_txn_dtls_tbl(mtl_ctr).wip_entity_id;
              l_job_details_rec.supply_subinventory     := p_mtl_txn_dtls_tbl(mtl_ctr).supply_subinventory;


	      --bug#8465719 begin
              l_job_details_rec.SUPPLY_LOCATOR_ID     := p_mtl_txn_dtls_tbl(mtl_ctr).supply_locator_id;

              --FND_LOG.STRING(FND_LOG.LEVEL_EVENT,lc_mod_name,'SUPPLY_LOCATOR_ID : '||p_mtl_txn_dtls_tbl(mtl_ctr).supply_locator_id);
              --FND_LOG.STRING(FND_LOG.LEVEL_EVENT,lc_mod_name,'supply_subinventory : '||p_mtl_txn_dtls_tbl(mtl_ctr).supply_subinventory);
              --FND_LOG.STRING(FND_LOG.LEVEL_EVENT,lc_mod_name,'CSD_DEF_HV_SUBINV : '||fnd_profile.value('CSD_DEF_HV_SUBINV'));


              if (p_mtl_txn_dtls_tbl(mtl_ctr).supply_locator_id is null) Then

                open get_inv_location_control_code ( p_mtl_txn_dtls_tbl(mtl_ctr).organization_id ,
                                                    p_mtl_txn_dtls_tbl(mtl_ctr).inventory_item_id ) ;
                fetch get_inv_location_control_code  into l_location_control_code ;
                close get_inv_location_control_code;


                --FND_LOG.STRING(FND_LOG.LEVEL_EVENT,lc_mod_name,'l_location_control_code : '||l_location_control_code);

                If l_location_control_code in ( lc_predfn_loc_cntrl ,
                                                lc_dyn_loc_cntrl ) THEN
                    l_locator_controlled := 'T' ;
                end if;

                open get_si_locator_control_code ( p_mtl_txn_dtls_tbl(mtl_ctr).organization_id  ,
                     p_mtl_txn_dtls_tbl(mtl_ctr).supply_subinventory ) ;
                fetch get_si_locator_control_code  into l_location_subinv_control_code ;
                close get_si_locator_control_code;

                if (l_location_subinv_control_code <> 1) then
                    l_locator_subinv_controlled := 'T';
                end if;


                open get_wip_supply_info ( p_mtl_txn_dtls_tbl(mtl_ctr).organization_id ,
                                                p_mtl_txn_dtls_tbl(mtl_ctr).inventory_item_id ) ;
                fetch get_wip_supply_info into l_wip_supply_type, l_wip_supply_subinventory, l_wip_supply_locator_id;
                close get_wip_supply_info;

                --FND_LOG.STRING(FND_LOG.LEVEL_EVENT,lc_mod_name,'l_wip_supply_subinventory : '||l_wip_supply_subinventory);
                --FND_LOG.STRING(FND_LOG.LEVEL_EVENT,lc_mod_name,'l_wip_supply_locator_id : '||l_wip_supply_locator_id);
                --FND_LOG.STRING(FND_LOG.LEVEL_EVENT,lc_mod_name,'l_locator_controlled : '||l_locator_controlled);
                --FND_LOG.STRING(FND_LOG.LEVEL_EVENT,lc_mod_name,'CSD_DEF_INV_LOCATOR : '||fnd_profile.value('CSD_DEF_INV_LOCATOR'));
                --wip_supply_type = 2 means assembly pull, 3 means operation pull

                If ((l_locator_controlled = 'T' or l_locator_subinv_controlled = 'T') and (l_wip_supply_type = 2 or l_wip_supply_type = 3))
 THEN
                    if (l_wip_supply_locator_id is not null) then
                        --defaulted the subinventory and locator from the Organization item -->Work in Process  --> Supply section
                        --if the value is not set there, get it from depot CSD_DEF_INV_LOCATOR profile value
                        l_job_details_rec.supply_subinventory   := l_wip_supply_subinventory;
                        l_job_details_rec.SUPPLY_LOCATOR_ID     := l_wip_supply_locator_id;
                    else
                        l_job_details_rec.SUPPLY_LOCATOR_ID     := fnd_profile.value('CSD_DEF_INV_LOCATOR');
                    --FND_LOG.STRING(FND_LOG.LEVEL_EVENT,lc_mod_name,'SUPPLY_LOCATOR_ID : '||l_job_details_rec.SUPPLY_LOCATOR_ID);
                    end if;
                end if;

              end if;
              --bug#8465719 end



              If  l_job_details_rec.supply_subinventory is null then
                  FND_MESSAGE.SET_NAME('CSD','CSD_DEF_SUB_INV_NULL');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
              end if;



                    -- Call procedures to insert job header and job details information
                    -- into wip interface tables

                 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsertjob',
                        'Just before calling insert_job_header');
                      END IF;


                    insert_job_header(    p_job_header_rec  =>    l_job_header_rec,
                               x_return_status  =>    x_return_status );


                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;


                 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsertjobdtls',
                        'Just before calling insert_job_details');
                      END IF;


                    insert_job_details(   p_job_details_rec    =>    l_job_details_rec,
                               x_return_status  =>    x_return_status );

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;



                    -- Call WIP Mass Load API

                 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallwipmassload',
                        'Just before calling WIP_MASSLOAD_PUB.massLoadJobs');
                      END IF;

                BEGIN
                    WIP_MASSLOAD_PUB.massLoadJobs(p_groupID   => l_job_header_rec.group_id,
                         p_validationLevel       => p_validation_level,
                         p_commitFlag            => 0,
                         x_returnStatus          => x_return_status,
                         x_errorMsg              => x_msg_data );

                    If ( ml_error_exists( l_job_header_rec.group_id )  or
                        x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

                           FND_MESSAGE.SET_NAME('CSD','CSD_MTL_ADD_MASS_LD_FAILURE');
                           FND_MSG_PUB.ADD;
                           x_return_status := FND_API.G_RET_STS_ERROR;

                           FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                                      p_count  => x_msg_count,
                                                      p_data   => x_msg_data);
                           -- Need to rollback  Raise exception -
                           -- once commit is removed from above call
                           -- raise FND_API.G_EXC_ERROR;
                           RETURN;
                    end if;

                EXCEPTION
                  WHEN OTHERS THEN
                     add_wip_interface_errors(l_job_header_rec.group_id,
                                              2 /* 2 = materials */);

                     -- when rollback for WIP works, remove x_return_status, count_and_get,
                     -- and return then reinstate raise exception above
                     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                     /*
                     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        -- Add Unexpected Error to Message List, here SQLERRM is used for
                        -- getting the error

                        FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                                p_procedure_name => lc_api_name );
                     END IF;
                     */
                     FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                                p_count  => x_msg_count,
                                                p_data   => x_msg_data);

                     END;
                end if;

                If p_mtl_txn_dtls_tbl(mtl_ctr).WIP_TRANSACTION_DETAIL_ID is null then
                    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsertrow',
                        'Just before calling CSD_WIP_TRANSACTION_DTLS_PKG.Insert_Row');
                    END IF;

                    l_WIP_TRANSACTION_DETAIL_ID := null;

                    CSD_WIP_TRANSACTION_DTLS_PKG.Insert_Row(
                        px_WIP_TRANSACTION_DETAIL_ID  => l_WIP_TRANSACTION_DETAIL_ID
                        ,p_CREATED_BY                 => l_created_by
                        ,p_CREATION_DATE              => l_creation_date
                        ,p_LAST_UPDATED_BY            => l_last_updated_by
                        ,p_LAST_UPDATE_DATE           => l_last_update_date
                        ,p_LAST_UPDATE_LOGIN          => l_last_update_login
                        ,p_INVENTORY_ITEM_ID          => p_mtl_txn_dtls_tbl(mtl_ctr).INVENTORY_ITEM_ID
                        ,p_WIP_ENTITY_ID              => p_mtl_txn_dtls_tbl(mtl_ctr).WIP_ENTITY_ID
                        ,p_OPERATION_SEQ_NUM          => l_op_seq_num -- p_mtl_txn_dtls_tbl(mtl_ctr).OPERATION_SEQ_NUM
                        ,p_RESOURCE_SEQ_NUM           => null
                        ,p_employee_id                => null
                        ,p_TRANSACTION_QUANTITY       => p_mtl_txn_dtls_tbl(mtl_ctr).TRANSACTION_QUANTITY
                        ,p_TRANSACTION_UOM            => p_mtl_txn_dtls_tbl(mtl_ctr).TRANSACTION_UOM
                        ,p_SERIAL_NUMBER              => p_mtl_txn_dtls_tbl(mtl_ctr).SERIAL_NUMBER
                        ,p_REVISION                   => p_mtl_txn_dtls_tbl(mtl_ctr).REVISION -- swai: bug 6995498/7182047
                        ,p_REASON_ID                  => p_mtl_txn_dtls_tbl(mtl_ctr).REASON_ID  -- swai bug 6841113
                        ,p_BACKFLUSH_FLAG             => null
                        ,p_COUNT_POINT_TYPE           => null
                        ,p_DEPARTMENT_ID              => null
                        ,p_DESCRIPTION                => null
                        ,p_FIRST_UNIT_COMPLETION_DATE => null
                        ,p_FIRST_UNIT_START_DATE      => null
                        ,p_LAST_UNIT_COMPLETION_DATE  => null
                        ,p_LAST_UNIT_START_DATE       => null
                        ,p_MINIMUM_TRANSFER_QUANTITY  => null
                        ,p_STANDARD_OPERATION_ID      => null
                        );

                else

                 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallupdaterow',
                        'Just before calling CSD_WIP_TRANSACTION_DTLS_PKG.Update_Row');
                      END IF;

                    CSD_WIP_TRANSACTION_DTLS_PKG.Update_Row(
                        p_WIP_TRANSACTION_DETAIL_ID  => p_mtl_txn_dtls_tbl(mtl_ctr).WIP_TRANSACTION_DETAIL_ID
                        ,p_CREATED_BY                 => null
                        ,p_CREATION_DATE              => null
                        ,p_LAST_UPDATED_BY            => l_last_updated_by
                        ,p_LAST_UPDATE_DATE           => l_last_update_date
                        ,p_LAST_UPDATE_LOGIN          => l_last_update_login
                        ,p_INVENTORY_ITEM_ID          => null
                        ,p_WIP_ENTITY_ID              => null
                        ,p_OPERATION_SEQ_NUM          => null
                        ,p_RESOURCE_SEQ_NUM           => null
                        ,p_employee_id              => null
                        ,p_TRANSACTION_QUANTITY       => p_mtl_txn_dtls_tbl(mtl_ctr).TRANSACTION_QUANTITY
                        ,p_TRANSACTION_UOM            => p_mtl_txn_dtls_tbl(mtl_ctr).TRANSACTION_UOM
                        ,p_SERIAL_NUMBER              => p_mtl_txn_dtls_tbl(mtl_ctr).SERIAL_NUMBER
                        ,p_REVISION                   => p_mtl_txn_dtls_tbl(mtl_ctr).REVISION -- swai: bug 6995498/7182047
                        ,p_REASON_ID                  => p_mtl_txn_dtls_tbl(mtl_ctr).REASON_ID  -- swai bug 6841113
                        ,p_BACKFLUSH_FLAG             => null
                        ,p_COUNT_POINT_TYPE           => null
                        ,p_DEPARTMENT_ID              => null
                        ,p_DESCRIPTION                => null
                        ,p_FIRST_UNIT_COMPLETION_DATE => null
                        ,p_FIRST_UNIT_START_DATE      => null
                        ,p_LAST_UNIT_COMPLETION_DATE  => null
                        ,p_LAST_UNIT_START_DATE       => null
                        ,p_MINIMUM_TRANSFER_QUANTITY  => null
                        ,p_STANDARD_OPERATION_ID      => null
                        ,p_OBJECT_VERSION_NUMBER      => p_mtl_txn_dtls_tbl(mtl_ctr).object_version_number
                        );

                end if;

        END LOOP;

        -- Standard check for p_commit
        IF FND_API.to_Boolean( p_commit )
        THEN
            COMMIT WORK;
        END IF;

EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_SAVE_MTL_TXN_DTLS_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_SAVE_MTL_TXN_DTLS_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_SAVE_MTL_TXN_DTLS_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;



END PROCESS_SAVE_MTL_TXN_DTLS;



PROCEDURE PROCESS_SAVE_RES_TXN_DTLS
(
    p_api_version_number                        IN          NUMBER,
    p_init_msg_list                           IN         VARCHAR2,
    p_Commit                                    IN          VARCHAR2,
    p_validation_level                        IN         NUMBER,
    x_return_status                             OUT   NOCOPY   VARCHAR2,
    x_msg_count                                  OUT  NOCOPY      NUMBER,
    x_msg_data                                OUT      NOCOPY     VARCHAR2,
    p_res_txn_dtls_tbl                       IN       res_TXN_DTLS_TBL_TYPE
 --   p_ro_quantity                               IN              NUMBER
)
IS
        lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_SAVE_RES_TXN_DTLS';
        lc_api_version_number      CONSTANT NUMBER := 1.0;

      -- constants used for FND_LOG debug messages

      lc_mod_name                 CONSTANT VARCHAR2(2000) := 'csd.plsql.csd_wip_job_pvt.insert_job_header.';


      -- Constants Used for Inserting into wip_job_schedule_interface,
      -- These are the values needed for WIP Mass Load to pick up the records

      -- Non Standard Update Discrete Job Load Type
      lc_non_std_update_load_type      CONSTANT NUMBER := 3;


      lc_load_res_type           CONSTANT        NUMBER := 1;
      lc_substitution_add_type CONSTANT                  NUMBER := 2;

    --    11/7/05
    --   lc_manual_autocharge_type  CONSTANT        NUMBER := 2;
    --   lc_item_basis_type         CONSTANT        NUMBER := 1;
    --   lc_no_scheduled_flag       CONSTANT        NUMBER := 2;
    --   lc_yes_standard_rate_flag  CONSTANT        NUMBER := 1;


          -- Job Records to hold the Job header and details information

        l_job_header_rec                wip_job_schedule_interface%ROWTYPE;
        l_job_details_rec           wip_job_dtls_interface%ROWTYPE;


         l_creation_date DATE;
      l_last_update_date DATE;
      l_created_by NUMBER;
      l_created_by_name VARCHAr2(100);
      l_last_updated_by NUMBER;
         l_last_updated_by_name VARCHAR2(100);
      l_last_update_login NUMBER;


      l_WIP_TRANSACTION_DETAIL_ID NUMBER;
    --   l_validation_level NUMBER;

      l_job_quantity NUMBER;

      l_resource_seq_num NUMBER;


        CURSOR get_job_quantity ( p_wip_entity_id NUMBER ) IS
            SELECT start_quantity from wip_discrete_jobs where
            wip_entity_id = p_wip_entity_id ;

        -- swai: bug 7017062 nvl the max(resource_seq_num)
	   cursor get_next_resource_seq_num ( p_wip_entity_id NUMBER,
                    p_operation_seq_num NUMBER ) IS
                select nvl(MAX(RESOURCE_SEQ_NUM),0)+ 10 from
                wip_operation_resources where wip_entity_id
                = p_wip_entity_id and operation_seq_num =
                p_operation_seq_num;




BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering private API process_save_res_txn_dtls' );
      END IF;

-- Standard Start of API savepoint
        SAVEPOINT PROCESS_SAVE_RES_TXN_DTLS_PVT;
-- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call
           (lc_api_version_number,
            p_api_version_number,
            lc_api_name,
            G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


         -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
        END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;



      -- Populate the constant values

      l_job_header_rec.load_type := lc_non_std_update_load_type;

       l_job_details_rec.start_date  := sysdate;
        l_job_details_rec.load_type := lc_load_res_type;

        l_job_details_rec.substitution_type := lc_substitution_add_type;

     --   l_job_details_rec.autocharge_type := lc_manual_autocharge_type;
     --   l_job_details_rec.basis_type      := lc_item_basis_type;
        l_job_details_rec.completion_date := sysdate;
     --   l_job_details_rec.scheduled_flag  := lc_no_scheduled_flag;
      --  l_job_details_rec.standard_rate_flag := lc_yes_standard_rate_flag;



      -- Populate the row who columns

      l_creation_date := SYSDATE;
      l_last_update_date := SYSDATE;
      l_created_by := fnd_global.user_id;
      l_last_updated_by := fnd_global.user_id;
      l_last_update_login := fnd_global.login_id;

        FOR res_ctr in p_res_txn_dtls_tbl.FIRST.. p_res_txn_dtls_tbl.LAST

        LOOP

            l_resource_seq_num := p_res_txn_dtls_tbl(res_ctr).resource_seq_num;


            If p_res_txn_dtls_tbl(res_ctr).new_row = 'Y' then

               -- Get the Group_id to be used for WIP Mass Load,

                  SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.group_id FROM dual;

                    -- get job_quantity
                    open get_job_quantity ( p_res_txn_dtls_tbl(res_ctr).wip_entity_id);
                    fetch get_job_quantity into l_job_quantity;
                    close get_job_quantity;




                   l_job_header_rec.header_id := l_job_header_rec.group_id;
                    l_job_header_rec.wip_entity_id := p_res_txn_dtls_tbl(res_ctr).wip_entity_id;
                 l_job_header_rec.organization_id   := p_res_txn_dtls_tbl(res_ctr).organization_id;

                    l_job_details_rec.group_id         := l_job_header_rec.group_id;
                    l_job_details_rec.parent_header_id := l_job_header_rec.group_id;
                 --   l_job_details_rec.resource_id_old  := p_res_txn_dtls_tbl(res_ctr).resource_id;

                    l_job_details_rec.resource_id_new  := p_res_txn_dtls_tbl(res_ctr).resource_id;
                    l_job_details_rec.operation_seq_num := p_res_txn_dtls_tbl(res_ctr).operation_seq_num;


                    open get_next_resource_seq_num ( p_res_txn_dtls_tbl(res_ctr).wip_entity_id,
                        p_res_txn_dtls_tbl(res_ctr).operation_seq_num );

                    fetch get_next_resource_seq_num into l_job_details_rec.resource_seq_num;

                    close get_next_resource_seq_num;

                    l_resource_seq_num := l_job_details_rec.resource_seq_num;




                    l_job_details_rec.organization_id   := p_res_txn_dtls_tbl(res_ctr).organization_id;
                    l_job_details_rec.uom_code          := p_res_txn_dtls_tbl(res_ctr).transaction_uom;
                      l_job_details_rec.usage_rate_or_amount :=  p_res_txn_dtls_tbl(res_ctr).transaction_quantity / l_job_quantity;
                    l_job_details_rec.assigned_units    := 1; --p_res_txn_dtls_tbl(res_ctr).transaction_quantity;
                    l_job_details_rec.wip_entity_id     := p_res_txn_dtls_tbl(res_ctr).wip_entity_id;


                    -- Call procedures to insert job header and job details information
                    -- into wip interface tables

                 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsertjob',
                        'Just before calling insert_job_header');
                      END IF;


                    insert_job_header(    p_job_header_rec  =>    l_job_header_rec,
                               x_return_status  =>    x_return_status );


                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;


                 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsertjobdtls',
                        'Just before calling insert_job_details');
                      END IF;


                    insert_job_details(   p_job_details_rec    =>    l_job_details_rec,
                               x_return_status  =>    x_return_status );

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;



                    -- Call WIP Mass Load API

                 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallwipmassload',
                        'Just before calling WIP_MASSLOAD_PUB.massLoadJobs');
                 END IF;

                 BEGIN
                    WIP_MASSLOAD_PUB.massLoadJobs(p_groupID   => l_job_header_rec.group_id,
                         p_validationLevel       => p_validation_level,
                         p_commitFlag            => 0,
                         x_returnStatus          => x_return_status,
                         x_errorMsg              => x_msg_data );

                    If ( ml_error_exists( l_job_header_rec.group_id )  or
                         x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

                        FND_MESSAGE.SET_NAME('CSD','CSD_RES_ADD_MASS_LD_FAILURE');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;

                        FND_MSG_PUB.count_and_get(p_encoded   => FND_API.G_FALSE,
                                                  p_count  => x_msg_count,
                                                  p_data   => x_msg_data);

                        -- Need to rollback Raise exception -
                        -- once commit is removed from above call
                        -- raise FND_API.G_EXC_ERROR;
                        RETURN;
                    end if;

                EXCEPTION
                  WHEN OTHERS THEN
                     add_wip_interface_errors(l_job_header_rec.group_id,
                                              3 /* 3 = resources */);
                     -- raise FND_API.G_EXC_UNEXPECTED_ERROR;

                     -- when rollback for WIP works, remove x_return_status, count_and_get,
                     -- and return then reinstate raise exception above
                     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                     /*
                     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        -- Add Unexpected Error to Message List, here SQLERRM is used for
                        -- getting the error
                        FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                                p_procedure_name => lc_api_name );
                     END IF;
                     */
                     FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                                p_count  => x_msg_count,
                                                p_data   => x_msg_data);
                     return;
                END;
            end if;

            If p_res_txn_dtls_tbl(res_ctr).WIP_TRANSACTION_DETAIL_ID is null then

                 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsertrow',
                        'Just before calling CSD_WIP_TRANSACTION_DTLS_PKG.Insert_Row');
                END IF;

                    l_WIP_TRANSACTION_DETAIL_ID := null;

                    CSD_WIP_TRANSACTION_DTLS_PKG.Insert_Row(
                        px_WIP_TRANSACTION_DETAIL_ID  => l_WIP_TRANSACTION_DETAIL_ID
                        ,p_CREATED_BY                 => l_created_by
                        ,p_CREATION_DATE              => l_creation_date
                        ,p_LAST_UPDATED_BY            => l_last_updated_by
                        ,p_LAST_UPDATE_DATE           => l_last_update_date
                        ,p_LAST_UPDATE_LOGIN          => l_last_update_login
                        ,p_INVENTORY_ITEM_ID          => null
                        ,p_WIP_ENTITY_ID              => p_res_txn_dtls_tbl(res_ctr).WIP_ENTITY_ID
                        ,p_OPERATION_SEQ_NUM          => p_res_txn_dtls_tbl(res_ctr).OPERATION_SEQ_NUM
                        ,p_RESOURCE_SEQ_NUM           => l_RESOURCE_SEQ_NUM
                        ,p_employee_id                => p_res_txn_dtls_tbl(res_ctr).employee_id
                        ,p_TRANSACTION_QUANTITY       => p_res_txn_dtls_tbl(res_ctr).TRANSACTION_QUANTITY
                        ,p_TRANSACTION_UOM            => p_res_txn_dtls_tbl(res_ctr).TRANSACTION_UOM
                        ,p_SERIAL_NUMBER              => NULL
                        ,p_REVISION                   => NULL -- swai: bug 6995498/7182047
                        ,p_REASON_ID                  => null  -- swai bug 6841113
                        ,p_BACKFLUSH_FLAG             => null
                        ,p_COUNT_POINT_TYPE           => null
                        ,p_DEPARTMENT_ID              => null
                        ,p_DESCRIPTION                => null
                        ,p_FIRST_UNIT_COMPLETION_DATE => null
                        ,p_FIRST_UNIT_START_DATE      => null
                        ,p_LAST_UNIT_COMPLETION_DATE  => null
                        ,p_LAST_UNIT_START_DATE       => null
                        ,p_MINIMUM_TRANSFER_QUANTITY  => null
                        ,p_STANDARD_OPERATION_ID      => null
                    );
            else

                 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallupdaterow',
                        'Just before calling CSD_WIP_TRANSACTION_DTLS_PKG.Update_Row');
                      END IF;


                    CSD_WIP_TRANSACTION_DTLS_PKG.Update_Row(
                        p_WIP_TRANSACTION_DETAIL_ID  => p_res_txn_dtls_tbl(res_ctr).WIP_TRANSACTION_DETAIL_ID
                        ,p_CREATED_BY                 => null
                        ,p_CREATION_DATE              => null
                        ,p_LAST_UPDATED_BY            => l_last_updated_by
                        ,p_LAST_UPDATE_DATE           => l_last_update_date
                        ,p_LAST_UPDATE_LOGIN          => l_last_update_login
                        ,p_INVENTORY_ITEM_ID          => null
                        ,p_WIP_ENTITY_ID              => null
                        ,p_OPERATION_SEQ_NUM          => null
                        ,p_RESOURCE_SEQ_NUM           => null
                        ,p_employee_id                => p_res_txn_dtls_tbl(res_ctr).employee_id
                        ,p_TRANSACTION_QUANTITY       => p_res_txn_dtls_tbl(res_ctr).TRANSACTION_QUANTITY
                        ,p_TRANSACTION_UOM            => p_res_txn_dtls_tbl(res_ctr).TRANSACTION_UOM
                        ,p_SERIAL_NUMBER              => null
                        ,p_REVISION                   => null  -- swai: bug 6995498/7182047
                        ,p_REASON_ID                  => null  -- swai bug 6841113
                        ,p_BACKFLUSH_FLAG             => null
                        ,p_COUNT_POINT_TYPE           => null
                        ,p_DEPARTMENT_ID              => null
                        ,p_DESCRIPTION                => null
                        ,p_FIRST_UNIT_COMPLETION_DATE => null
                        ,p_FIRST_UNIT_START_DATE      => null
                        ,p_LAST_UNIT_COMPLETION_DATE  => null
                        ,p_LAST_UNIT_START_DATE       => null
                        ,p_MINIMUM_TRANSFER_QUANTITY  => null
                        ,p_STANDARD_OPERATION_ID      => null
                        ,p_OBJECT_VERSION_NUMBER      => p_res_txn_dtls_tbl(res_ctr).object_version_number
                    );

            end if;

        END LOOP;

-- Standard check for p_commit
        IF FND_API.to_Boolean( p_commit )
        THEN
            COMMIT WORK;
        END IF;

EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_SAVE_RES_TXN_DTLS_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_SAVE_RES_TXN_DTLS_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_SAVE_RES_TXN_DTLS_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;


END PROCESS_SAVE_RES_TXN_DTLS;


PROCEDURE PROCESS_SAVE_OP_DTLS
(
    p_api_version_number                 IN         NUMBER,
    p_init_msg_list                      IN         VARCHAR2,
    p_Commit                             IN         VARCHAR2,
    p_validation_level                   IN         NUMBER,
    x_return_status                      OUT NOCOPY VARCHAR2,
    x_msg_count                          OUT NOCOPY NUMBER,
    x_msg_data                           OUT NOCOPY VARCHAR2,
    p_op_dtls_tbl                        IN         OP_DTLS_TBL_TYPE
)
IS
   lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_SAVE_OP_DTLS';
   lc_api_version_number      CONSTANT NUMBER := 1.0;

   -- constants used for FND_LOG debug messages
   lc_mod_name                 CONSTANT VARCHAR2(2000) := 'csd.plsql.csd_wip_job_pvt.process_save_op_dtls.';

   -- Constants Used for Inserting into wip_job_schedule_interface,
   -- These are the values needed for WIP Mass Load to pick up the records
   lc_non_std_update_load_type   CONSTANT NUMBER := 3;  -- load type for update non standard discrete job

   -- Constants Used for Inserting into wip_job_dtls_interface
   lc_load_op_type               CONSTANT NUMBER := 3;  -- load type for operations
   lc_substitution_add_type      CONSTANT NUMBER := 2;  -- indicates add record (vs. change=3 or delete=1)
   lc_substitution_change_type   CONSTANT NUMBER := 3;  -- indicates change record (vs. add=2 or delete=1)
   lc_process_validation_phase   CONSTANT NUMBER := 2;  -- must be 2 for WIP to pick up record
   lc_process_pending_status     CONSTANT NUMBER := 1;  -- must be 1 for WIP to pick up record

   -- Job Records to hold the Job header and details information
   l_job_header_rec            wip_job_schedule_interface%ROWTYPE;
   l_job_details_rec           wip_job_dtls_interface%ROWTYPE;

   -- variables for WHO columns
   l_creation_date     DATE;
   l_last_update_date  DATE;
   l_created_by        NUMBER;
   l_last_updated_by   NUMBER;
   l_last_update_login NUMBER;

   -- primary key for CSD_WIP_TRANSACTION_DETAILS table
   l_wip_transaction_detail_id NUMBER;

BEGIN

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
               lc_mod_name||'begin',
               'Entering private API process_save_op_dtls' );
   END IF;

   -- Standard Start of API savepoint
   SAVEPOINT PROCESS_SAVE_OP_DTLS_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (lc_api_version_number,
      p_api_version_number,
      lc_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Populate the constant values for job header
   l_job_header_rec.load_type          := lc_non_std_update_load_type;

   -- Populate the constant values for job details
   l_job_details_rec.start_date        := sysdate;
   l_job_details_rec.load_type         := lc_load_op_type;

   -- Get the data for the WHO columns
   l_creation_date      := SYSDATE;
   l_last_update_date   := SYSDATE;
   l_created_by         := fnd_global.user_id;
   l_last_updated_by    := fnd_global.user_id;
   l_last_update_login  := fnd_global.login_id;

   FOR op_ctr in p_op_dtls_tbl.FIRST.. p_op_dtls_tbl.LAST
   LOOP
      -- l_operation_seq_num := p_op_dtls_tbl(op_ctr).operation_seq_num;

      IF p_op_dtls_tbl(op_ctr).operation_seq_num is not null THEN
         -- Get the Group_id to be used for WIP Mass Load,

         SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.group_id FROM dual;

         -- set job header info
         l_job_header_rec.header_id       := l_job_header_rec.group_id;
         l_job_header_rec.wip_entity_id   := p_op_dtls_tbl(op_ctr).wip_entity_id;
         l_job_header_rec.organization_id := p_op_dtls_tbl(op_ctr).organization_id;

         -- set job details (operations) info - required columns in wip_job_dtls_interface table
         l_job_details_rec.group_id         := l_job_header_rec.group_id;
         l_job_details_rec.parent_header_id := l_job_header_rec.group_id;
         l_job_details_rec.operation_seq_num := p_op_dtls_tbl(op_ctr).operation_seq_num;
         l_job_details_rec.backflush_flag   := p_op_dtls_tbl(op_ctr).backflush_flag;
         l_job_details_rec.count_point_type := p_op_dtls_tbl(op_ctr).count_point_type;
         l_job_details_rec.first_unit_completion_date := p_op_dtls_tbl(op_ctr).first_unit_completion_date;
         l_job_details_rec.first_unit_start_date      := p_op_dtls_tbl(op_ctr).first_unit_start_date;
         l_job_details_rec.last_unit_completion_date  := p_op_dtls_tbl(op_ctr).last_unit_completion_date;
         l_job_details_rec.last_unit_start_date       := p_op_dtls_tbl(op_ctr).last_unit_start_date;
         l_job_details_rec.minimum_transfer_quantity  := p_op_dtls_tbl(op_ctr).minimum_transfer_quantity;
         l_job_details_rec.process_phase    := lc_process_validation_phase;
         l_job_details_rec.process_status   := lc_process_pending_status;

         -- set job details (operations) info - optional columns in wip_job_dtls_interface table
         l_job_details_rec.description            := p_op_dtls_tbl(op_ctr).description;

         -- set job details (operations) info - not set in columns in wip_job_dtls_interface table
         l_job_details_rec.organization_id   := p_op_dtls_tbl(op_ctr).organization_id;
         l_job_details_rec.wip_entity_id     := p_op_dtls_tbl(op_ctr).wip_entity_id;

         IF p_op_dtls_tbl(op_ctr).new_row = 'Y' THEN
            l_job_details_rec.substitution_type := lc_substitution_add_type;
            l_job_details_rec.department_id    := p_op_dtls_tbl(op_ctr).department_id;
            l_job_details_rec.standard_operation_id  := p_op_dtls_tbl(op_ctr).standard_operation_id;
         ELSE
            l_job_details_rec.substitution_type := lc_substitution_change_type;
         END IF;

         -- Call procedures to insert job header and job details information
         -- into wip interface tables
         IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
            lc_mod_name||'beforecallinsertjob',
            'Just before calling insert_job_header');
         END IF;

         insert_job_header( p_job_header_rec =>    l_job_header_rec,
                            x_return_status  =>    x_return_status );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
            lc_mod_name||'beforecallinsertjobdtls',
            'Just before calling insert_job_details');
         END IF;

         insert_job_details(  p_job_details_rec =>    l_job_details_rec,
                              x_return_status   =>    x_return_status );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- Call WIP Mass Load API
         IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
            lc_mod_name||'beforecallwipmassload',
            'Just before calling WIP_MASSLOAD_PUB.massLoadJobs');
         END IF;

         BEGIN
            WIP_MASSLOAD_PUB.massLoadJobs(p_groupID   => l_job_header_rec.group_id,
                p_validationLevel       => p_validation_level,
                p_commitFlag            => 0,
                x_returnStatus          => x_return_status,
                x_errorMsg              => x_msg_data );

            If ( ml_error_exists( l_job_header_rec.group_id )  or
                 x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

               FND_MESSAGE.SET_NAME('CSD','CSD_OP_ADD_MASS_LD_FAILURE');
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_ERROR;

               FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                          p_count  => x_msg_count,
                                          p_data   => x_msg_data);

               -- Need to rollback Raise exception -
               -- once commit is removed from above call
               -- raise FND_API.G_EXC_ERROR;
               RETURN;
            end if;
         EXCEPTION
         WHEN OTHERS THEN
            add_wip_interface_errors(l_job_header_rec.group_id,
                                     1 /* 1 = operations */);
            -- raise FND_API.G_EXC_UNEXPECTED_ERROR;

            -- when rollback for WIP works, remove x_return_status, count_and_get,
            -- and return then reinstate raise exception above
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            /*
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

               -- Add Unexpected Error to Message List, here SQLERRM is used for
               -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                       p_procedure_name => lc_api_name );
            END IF;
            */
            FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                       p_count  => x_msg_count,
                                       p_data   => x_msg_data);
            return;
         END;
      end if;

      If p_op_dtls_tbl(op_ctr).WIP_TRANSACTION_DETAIL_ID is null then
         IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
               lc_mod_name||'beforecallinsertrow',
               'Just before calling CSD_WIP_TRANSACTION_DTLS_PKG.Insert_Row');
         END IF;

         l_WIP_TRANSACTION_DETAIL_ID := null;

         CSD_WIP_TRANSACTION_DTLS_PKG.Insert_Row(
            px_WIP_TRANSACTION_DETAIL_ID  => l_WIP_TRANSACTION_DETAIL_ID
            ,p_CREATED_BY                 => l_created_by
            ,p_CREATION_DATE              => l_creation_date
            ,p_LAST_UPDATED_BY            => l_last_updated_by
            ,p_LAST_UPDATE_DATE           => l_last_update_date
            ,p_LAST_UPDATE_LOGIN          => l_last_update_login
            ,p_INVENTORY_ITEM_ID          => null
            ,p_WIP_ENTITY_ID              => p_op_dtls_tbl(op_ctr).WIP_ENTITY_ID
            ,p_OPERATION_SEQ_NUM          => p_op_dtls_tbl(op_ctr).OPERATION_SEQ_NUM
            ,p_RESOURCE_SEQ_NUM           => null
            ,p_employee_id                => null
            ,p_TRANSACTION_QUANTITY       => null
            ,p_TRANSACTION_UOM            => null
            ,p_SERIAL_NUMBER              => NULL
            ,p_REVISION                   => NULL -- swai: bug 6995498/7182047
            ,p_REASON_ID                  => null  -- swai bug 6841113
            ,p_BACKFLUSH_FLAG             => p_op_dtls_tbl(op_ctr).BACKFLUSH_FLAG
            ,p_COUNT_POINT_TYPE           => p_op_dtls_tbl(op_ctr).COUNT_POINT_TYPE
            ,p_DEPARTMENT_ID              => p_op_dtls_tbl(op_ctr).DEPARTMENT_ID
            ,p_DESCRIPTION                => p_op_dtls_tbl(op_ctr).DESCRIPTION
            ,p_FIRST_UNIT_COMPLETION_DATE => p_op_dtls_tbl(op_ctr).FIRST_UNIT_COMPLETION_DATE
            ,p_FIRST_UNIT_START_DATE      => p_op_dtls_tbl(op_ctr).FIRST_UNIT_START_DATE
            ,p_LAST_UNIT_COMPLETION_DATE  => p_op_dtls_tbl(op_ctr).LAST_UNIT_COMPLETION_DATE
            ,p_LAST_UNIT_START_DATE       => p_op_dtls_tbl(op_ctr).LAST_UNIT_START_DATE
            ,p_MINIMUM_TRANSFER_QUANTITY  => p_op_dtls_tbl(op_ctr).MINIMUM_TRANSFER_QUANTITY
            ,p_STANDARD_OPERATION_ID      => p_op_dtls_tbl(op_ctr).STANDARD_OPERATION_ID

         );

      else
         IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
            lc_mod_name||'beforecallupdaterow',
            'Just before calling CSD_WIP_TRANSACTION_DTLS_PKG.Update_Row');
         END IF;

         CSD_WIP_TRANSACTION_DTLS_PKG.Update_Row(
            p_WIP_TRANSACTION_DETAIL_ID  => p_op_dtls_tbl(op_ctr).WIP_TRANSACTION_DETAIL_ID
            ,p_CREATED_BY                 => null
            ,p_CREATION_DATE              => null
            ,p_LAST_UPDATED_BY            => l_last_updated_by
            ,p_LAST_UPDATE_DATE           => l_last_update_date
            ,p_LAST_UPDATE_LOGIN          => l_last_update_login
            ,p_INVENTORY_ITEM_ID          => null
            ,p_WIP_ENTITY_ID              => null
            ,p_OPERATION_SEQ_NUM          => null
            ,p_RESOURCE_SEQ_NUM           => null
            ,p_employee_id                => null
            ,p_TRANSACTION_QUANTITY       => null
            ,p_TRANSACTION_UOM            => null
            ,p_SERIAL_NUMBER              => null
            ,p_REVISION                   => null -- swai: bug 6995498/7182047
            ,p_REASON_ID                  => null  -- swai bug 6841113
            ,p_BACKFLUSH_FLAG             => p_op_dtls_tbl(op_ctr).BACKFLUSH_FLAG
            ,p_COUNT_POINT_TYPE           => p_op_dtls_tbl(op_ctr).COUNT_POINT_TYPE
            ,p_DEPARTMENT_ID              => p_op_dtls_tbl(op_ctr).DEPARTMENT_ID
            ,p_DESCRIPTION                => p_op_dtls_tbl(op_ctr).DESCRIPTION
            ,p_FIRST_UNIT_COMPLETION_DATE => p_op_dtls_tbl(op_ctr).FIRST_UNIT_COMPLETION_DATE
            ,p_FIRST_UNIT_START_DATE      => p_op_dtls_tbl(op_ctr).FIRST_UNIT_START_DATE
            ,p_LAST_UNIT_COMPLETION_DATE  => p_op_dtls_tbl(op_ctr).LAST_UNIT_COMPLETION_DATE
            ,p_LAST_UNIT_START_DATE       => p_op_dtls_tbl(op_ctr).LAST_UNIT_START_DATE
            ,p_MINIMUM_TRANSFER_QUANTITY  => p_op_dtls_tbl(op_ctr).MINIMUM_TRANSFER_QUANTITY
            ,p_STANDARD_OPERATION_ID      => p_op_dtls_tbl(op_ctr).STANDARD_OPERATION_ID
            ,p_OBJECT_VERSION_NUMBER      => p_op_dtls_tbl(op_ctr).object_version_number
         );

      end if;
   END LOOP;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_SAVE_OP_DTLS_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_SAVE_OP_DTLS_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_SAVE_OP_DTLS_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;
END PROCESS_SAVE_OP_DTLS;


PROCEDURE create_wip_job
(
    p_api_version_number                    IN           NUMBER,
    p_init_msg_list                       IN          VARCHAR2 ,
    p_commit                                IN          VARCHAR2 ,
    p_validation_level                    IN          NUMBER,
    x_return_status                         OUT    NOCOPY   VARCHAR2,
    x_msg_count                              OUT   NOCOPY      NUMBER,
    x_msg_data                            OUT       NOCOPY     VARCHAR2,
    x_job_name                              OUT     NOCOPY      VARCHAR2,
    p_repair_line_id                        IN        NUMBER,
    p_repair_quantity                    IN        NUMBER,
    p_inventory_item_Id                   IN       NUMBER
   )
IS

      -- Job Record to hold the Job header, bills and routing information being inserted
      -- into wip_job_schedule_interface

    l_job_header_rec                wip_job_schedule_interface%ROWTYPE;

     lc_api_name                CONSTANT VARCHAR2(30) := 'CREATE_WIP_JOB';
     lc_api_version_number      CONSTANT NUMBER := 1.0;

-- WIP Job Status Lookup Codes for Released and Unreleased status, --- The Lookup Type is WIP_JOB_STATUS

     lc_released_status_code     CONSTANT NUMBER :=  3;
    lc_unreleased_status_code CONSTANT NUMBER :=  1;

         -- Non Standard Discrete Job Load Type
    lc_non_standard_load_type    CONSTANT NUMBER := 4;


      -- COnstants used for FND_LOG debug messages

      lc_mod_name     CONSTANT      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.create_wip_job';



     l_user_id  NUMBER;
     l_repair_xref_id  NUMBER;
     l_rep_hist_id  NUMBER;

      l_job_prefix   VARCHAR2(80);
      l_wip_entity_id  NUMBER;


--*****Below are the code to Default Repair Item as Material on Job**********
    l_default_ro_item               VARCHAR2(1);
--    l_wip_entity_id                 NUMBER;
    l_mtl_txn_dtls_tbl              CSD_HV_WIP_JOB_PVT.MTL_TXN_DTLS_TBL_TYPE;
    l_op_created		            VARCHAR2(10);
    l_num_other_jobs                NUMBER :=0; -- swai: bug 7477845/7483291


    CURSOR c_repair_line_info(p_repair_line_id IN NUMBER) IS
    select inventory_item_id, unit_of_measure, quantity, serial_number, inventory_org_id
    from csd_repairs
    where repair_line_id = p_repair_line_id;

    CURSOR c_count_material(p_wip_entity_id NUMBER, l_inventory_item_id NUMBER) IS
    select 'X'
    from wip_requirement_operations_v
    where wip_entity_id = p_wip_entity_id
    and inventory_item_id = l_inventory_item_id
    and rownum = 1;


    -- Cursor to select the item attributes serial control code and
    --  lot control code.
    CURSOR cur_get_item_attribs (
     p_org_id                            NUMBER,
     p_item_id                           NUMBER
    )
    IS
     SELECT serial_number_control_code
       FROM mtl_system_items
      WHERE organization_id = p_org_id AND inventory_item_id = p_item_id;


    Cursor c_get_serial_info(p_item_id number, p_serial_number varchar2, p_org_id number) is
    select current_status, current_subinventory_code from mtl_serial_numbers
    where inventory_item_id = p_item_id and serial_number = p_serial_number and current_organization_id = p_org_id;


--    Cursor c_get_min_operation_seq(p_wip_entity_id number) is
--    select min(operation_seq_num) from wip_operations_v where wip_entity_id = p_wip_entity_id;

    l_inventory_item_id     NUMBER;
    l_unit_of_measure       VARCHAR2(3);
    l_quantity              NUMBER;
    l_serial_number         VARCHAR2(30);
    l_inventory_org_id      NUMBER;
    l_subinventory          VARCHAR2(30);
    l_dummy                 VARCHAR2(1) := null;
    l_serial_control_code   NUMBER;
    l_current_status        NUMBER;
    l_current_subinventory_code VARCHAR2(10);
    l_operation_seq_num     NUMBER;



BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering Private API create_wip_job');
      END IF;

-- Standard Start of API savepoint
     SAVEPOINT CREATE_WIP_JOB_PVT;
-- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call
           (lc_api_version_number,
            p_api_version_number,
            lc_api_name,
            G_PKG_NAME)
      THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status:=FND_API.G_RET_STS_SUCCESS;


         l_job_header_rec.organization_id :=
              fnd_profile.value('CSD_DEF_REP_INV_ORG');

       --  l_job_header_rec.organization_id := 207;

          IF l_job_header_rec.organization_id is NULL THEN

              FND_MESSAGE.SET_NAME('CSD','CSD_DEF_REP_INV_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
          end if;


       l_job_prefix := fnd_profile.value('CSD_DEFAULT_JOB_PREFIX');

        --  If l_job_prefix is null, throw an error and return;

     --   l_job_prefix := 'SR';

        IF l_job_prefix is NULL THEN

              FND_MESSAGE.SET_NAME('CSD','CSD_JOB_PREFIX_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
        end if;



         l_job_header_rec.class_code :=
              fnd_profile.value('CSD_DEF_WIP_ACCOUNTING_CLASS');

          --  l_job_header_rec.class_code := 'Rework';

          IF l_job_header_rec.class_code is NULL THEN

              FND_MESSAGE.SET_NAME('CSD','CSD_CLASS_CODE_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
          end if;



-- Assign the WIP Job Status lookup codes corresponding to Released -- and Unreleased Job status,
            -- to be passed for WIP Interface Table


        if fnd_profile.value('CSD_DEFAULT_JOB_STATUS')   = 'RELEASED'  then


                  l_job_header_rec.status_type := lc_released_status_code ;

        elsif nvl( fnd_profile.value('CSD_DEFAULT_JOB_STATUS'), 'UNRELEASED' )   = 'UNRELEASED'  then

                  l_job_header_rec.status_type := lc_unreleased_status_code;
        end if;


         l_job_header_rec.load_type := lc_non_standard_load_type;



      l_job_header_rec.first_unit_start_date := sysdate;
      l_job_header_rec.last_unit_completion_date := sysdate;


      l_job_header_rec.start_quantity := p_repair_quantity;

   -- If the profile CSD: Default WIP MRP Net Qty to Zero is set to
   -- null / 'N' then net_quantity = start_quantity else if the
   -- profile is set to 'Y' then net_quantity = 0
        IF ( nvl(fnd_profile.value('CSD_WIP_MRP_NET_QTY'),'N') = 'N' ) THEN
        l_job_header_rec.net_quantity := p_repair_quantity;
        ELSIF ( fnd_profile.value('CSD_WIP_MRP_NET_QTY') = 'Y' ) THEN
        l_job_header_rec.net_quantity := 0;
        END IF;


        l_job_header_rec.primary_item_id :=
            p_inventory_item_id ;


-- Get the Group_id to be used for WIP Create Job,

         SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.group_id FROM dual;

         -- nnadig bug 9263438
         -- interface id should use sequence number from wip_interface_s
         -- wip_job_schedule_interface_s is for wjsi.group_id, and wip_interface_s is for wjsi.interface_id.
         SELECT wip_interface_s.NEXTVAL INTO l_job_header_rec.interface_id FROM dual;
         --l_job_header_rec.interface_id := l_job_header_rec.group_id;

          generate_job_name  (      p_job_prefix       =>l_job_prefix,
                                        p_organization_id  => l_job_header_rec.organization_id,
                                        x_job_name         => l_job_header_rec.job_name );


          x_job_name := l_job_header_rec.job_name;


          IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsert',
                        'Just before calling insert_job_header');
          END IF;

-- Call procedure to insert job header and bills, routing
-- information
            -- into wip_job_schedule_interface table


            insert_job_header(   p_job_header_rec     =>
                                              l_job_header_rec,
                                    x_return_status      =>
                                             x_return_status );


              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;


      -- CALL WIP API to process records in wip interface table,
         --If API fails, Raise error, rollback and return

       -- Call WIP Mass Load API

               IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallcreateonejob',
                        'Just before calling WIP_MASSLOAD_PUB.createOneJob');
                    END IF;
              --     dbms_output.put_line('Before calling createonejob');

                 WIP_MASSLOAD_PUB.createOneJob( p_interfaceID => l_job_header_rec.interface_id, --bug  9263438
                         p_validationLevel => p_validation_level,
                         x_wipEntityID => l_wip_entity_id,
                         x_returnStatus => x_return_status,
                         x_errorMsg     => x_msg_data );

          --      dbms_output.put_line('After calling createonejob');



                    If ( ml_error_exists( l_job_header_rec.group_id )  or
                        x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

                    --     ROLLBACK to CREATE_WIP_JOB_PVT ;


                        FND_MESSAGE.SET_NAME('CSD','CSD_JOB_CREAT_FAILURE');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;

                              -- Need to rollback Raise exception -
                            -- once commit is removed from above call

                    end if;


                --*****Below are the code to Default Repair Item as Material on Job**********

                l_default_ro_item := nvl(FND_PROFILE.VALUE('CSD_DEFAULT_RO_ITEM_AS_MATERIAL_ON_JOB'), 'N');
                --taklam
                if (l_default_ro_item = 'Y') then
                    -- swai: bug 7477845/7483291
                    -- check if there another job existing for this RO.  If so, do not default
                    -- the RO item as a material. Must compare we.wip_entity_id since
                    -- crj.wip_entity_id may be null (until wip_update is done).
                    select count(*)
                      into l_num_other_jobs
                      from csd_repair_job_xref crj,
                           wip_entities we
                     where crj.job_name        = we.wip_entity_name
                       and crj.organization_id = we.organization_id
                       and crj.repair_line_id = p_repair_line_id
                       and we.wip_entity_id <> l_wip_entity_id;

                    if (l_num_other_jobs = 0) then
                        OPEN  c_repair_line_info(p_repair_line_id);
                        FETCH c_repair_line_info into
                              l_inventory_item_id,
                              l_unit_of_measure,
                              l_quantity,
                              l_serial_number,
                              l_inventory_org_id;
                        CLOSE c_repair_line_info;
                        l_subinventory := fnd_profile.value('CSD_DEF_HV_SUBINV');

                        --Get serial number control code and lot control code
                        OPEN cur_get_item_attribs (l_inventory_org_id,
                                             l_inventory_item_id);

                        FETCH cur_get_item_attribs
                            INTO l_serial_control_code;
                        CLOSE cur_get_item_attribs;


                        IF l_serial_control_code IN (2, 5) then
                            OPEN c_get_serial_info (l_inventory_item_id, l_serial_number, l_inventory_org_id);
                            FETCH c_get_serial_info
                                INTO l_current_status,l_current_subinventory_code;
                            CLOSE c_get_serial_info;
                            --current status = 3 is valid serial number
                            if (l_current_status = 3) then
                                l_subinventory := l_current_subinventory_code;
                            else
                                l_serial_number := null;
                            end if;
                        else
                            --don't pass the serial number, it is not valid serial number
                            l_serial_number := null;
                        end if;


                        l_dummy := null;
                        OPEN c_count_material(l_wip_entity_id, l_inventory_item_id);
                        FETCH c_count_material into l_dummy;
                        CLOSE c_count_material;


                        if (l_dummy is null) then
                            --Default Repair Item as Material on Job
                            l_mtl_txn_dtls_tbl.delete;

                            l_mtl_txn_dtls_tbl(0).INVENTORY_ITEM_ID          :=l_inventory_item_id;
                            l_mtl_txn_dtls_tbl(0).WIP_ENTITY_ID              :=l_wip_entity_id;
                            l_mtl_txn_dtls_tbl(0).ORGANIZATION_ID            :=l_inventory_org_id;
                            l_mtl_txn_dtls_tbl(0).OPERATION_SEQ_NUM          :=1;
                            l_mtl_txn_dtls_tbl(0).TRANSACTION_QUANTITY       :=l_quantity; --repair order qty
                            l_mtl_txn_dtls_tbl(0).TRANSACTION_UOM            :=l_unit_of_measure; --Repair order UOM
                            l_mtl_txn_dtls_tbl(0).SERIAL_NUMBER              :=l_serial_number;
                            l_mtl_txn_dtls_tbl(0).SUPPLY_SUBINVENTORY        :=l_subinventory;
                            l_mtl_txn_dtls_tbl(0).OBJECT_VERSION_NUMBER      := 1;
                            l_mtl_txn_dtls_tbl(0).NEW_ROW                    := 'Y';


                            -- call API to create Repair Actuals header
                            CSD_HV_WIP_JOB_PVT.PROCESS_SAVE_MTL_TXN_DTLS
                                    ( p_api_version_number      => 1.0,
                                      p_init_msg_list           => 'T',
                                      p_commit                  => 'F',
                                      p_validation_level        => 1,
                                      p_mtl_txn_dtls_tbl		=> l_mtl_txn_dtls_tbl,
                                      x_op_created				=> l_op_created,
                                      x_return_status           => x_return_status,
                                      x_msg_count               => x_msg_count,
                                      x_msg_data                => x_msg_data);
                            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                                FND_MESSAGE.SET_NAME('CSD','CSD_JOB_GEN_FAILURE');
                                FND_MSG_PUB.ADD;
                                RAISE FND_API.G_EXC_ERROR;
                            END IF;
                        end if;
                    end if;  -- swai: bug 7477845/7483291 num other jobs = 0
                end if;
                --*****End of the code to Default Repair Item as Material on Job**********



/*                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      ROLLBACK to CREATE_WIP_JOB_PVT ;


                      FND_MESSAGE.SET_NAME('CSD','CSD_JOB_CREAT_FAILURE');
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;  */


                 --    dbms_output.put_line('In Error');

          /*            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING( FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
                   END IF;

                   RETURN;  */

               --    END IF;


      -- call procedures to insert a row in csd_repair_job_xref
        --  and csd_repair_history tables for the job created.

               L_user_id := fnd_global.user_id;

               IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallxrefwrite',
                        'Just before calling csd_to_form_repair_job_xref.validate_and_write');
               END IF;



             csd_to_form_repair_job_xref.validate_and_write(
                    p_api_version_number => lc_api_version_number,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_commit => FND_API.G_FALSE,
                    p_validation_level => NULL,
                    p_action_code => 0,
                    px_repair_job_xref_id => l_repair_xref_id,
                    p_created_by =>  l_user_id,
                    p_creation_date => SYSDATE,
                    p_last_updated_by => l_user_id,
                    p_last_update_date => SYSDATE,
                    p_last_update_login => l_user_id,
                    p_repair_line_id => p_repair_line_id,
                    p_wip_entity_id => l_wip_entity_id,
                    p_group_id => l_job_header_rec.group_id,
                    p_organization_id => l_job_header_rec.organization_id,
                    p_quantity => p_repair_quantity,
                    p_INVENTORY_ITEM_ID => l_job_header_rec.primary_item_id,
                    p_ITEM_REVISION =>  null,
                    p_OBJECT_VERSION_NUMBER => NULL,
                    p_attribute_category => NULL,
                    p_attribute1 => NULL,
                    p_attribute2 => NULL,
                    p_attribute3 => NULL,
                    p_attribute4 => NULL,
                    p_attribute5 => NULL,
                    p_attribute6 => NULL,
                    p_attribute7 => NULL,
                    p_attribute8 => NULL,
                    p_attribute9 => NULL,
                    p_attribute10 => NULL,
                    p_attribute11 => NULL,
                    p_attribute12 => NULL,
                    p_attribute13 => NULL,
                    p_attribute14 => NULL,
                    p_attribute15 => NULL,
                    p_quantity_completed => NULL,
                    p_job_name  =>  l_job_header_rec.job_name,
                    p_source_type_code  =>  'MANUAL',  -- bug fix 5763350
                    p_source_id1  =>  NULL,
                    p_ro_service_code_id  =>  NULL,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);


            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     ROLLBACK to CREATE_WIP_JOB_PVT ;

                     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING( FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
                  END IF;

                 RETURN;

                END IF;


               IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallhistwrite',
                        'Just before calling csd_to_form_repair_history.validate_and_write');
               END IF;



                csd_to_form_repair_history.validate_and_write(
                    p_api_version_number => lc_api_version_number,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_commit => FND_API.G_FALSE,
                    p_validation_level => NULL,
                    p_action_code => 0,
                    px_repair_history_id => l_rep_hist_id,
                    p_OBJECT_VERSION_NUMBER => NULL,
                    p_request_id => NULL,
                    p_program_id => NULL,
                    p_program_application_id => NULL,
                    p_program_update_date => NULL,
                    p_created_by =>  l_user_id,
                    p_creation_date => SYSDATE,
                    p_last_updated_by => l_user_id,
                    p_last_update_date => SYSDATE,
                    p_repair_line_id => p_repair_line_id,
                    p_event_code => 'JS',
                    p_event_date => SYSDATE,
                    p_quantity => p_repair_quantity,
                    p_paramn1 => l_wip_entity_id,
                    p_paramn2 => l_job_header_rec.organization_id,
                    p_paramn3 => NULL,
                    p_paramn4 => NULL,
                    p_paramn5 => p_repair_quantity,
                    p_paramn6 => NULL,
                    p_paramn8 => NULL,
                    p_paramn9 => NULL,
                    p_paramn10 => NULL,
                    p_paramc1 => l_job_header_rec.job_name,
                    p_paramc2 => NULL,
                    p_paramc3 => NULL,
                    p_paramc4 => NULL,
                    p_paramc5 => NULL,
                    p_paramc6 => NULL,
                    p_paramc7 => NULL,
                    p_paramc8 => NULL,
                    p_paramc9 => NULL,
                    p_paramc10 => NULL,
                    p_paramd1 => NULL ,
                    p_paramd2 => NULL ,
                    p_paramd3 => NULL ,
                    p_paramd4 => NULL ,
                    p_paramd5 => SYSDATE,
                    p_paramd6 => NULL ,
                    p_paramd7 => NULL ,
                    p_paramd8 => NULL ,
                    p_paramd9 => NULL ,
                    p_paramd10 => NULL ,
                    p_attribute_category => NULL ,
                    p_attribute1 => NULL ,
                    p_attribute2 => NULL ,
                    p_attribute3 => NULL ,
                    p_attribute4 => NULL ,
                    p_attribute5 => NULL ,
                    p_attribute6 => NULL ,
                    p_attribute7 => NULL ,
                    p_attribute8 => NULL ,
                    p_attribute9 => NULL ,
                    p_attribute10 => NULL ,
                    p_attribute11 => NULL ,
                    p_attribute12 => NULL ,
                    p_attribute13 => NULL ,
                    p_attribute14 => NULL ,
                    p_attribute15 => NULL ,
                    p_last_update_login  => l_user_id,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     ROLLBACK to CREATE_WIP_JOB_PVT ;

                    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING( FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
                 END IF;

                 RETURN;

               END IF;

-- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;


EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to CREATE_WIP_JOB_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to CREATE_WIP_JOB_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to CREATE_WIP_JOB_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;


END create_wip_job;


PROCEDURE generate_wip_jobs_from_scs
(
    p_api_version_number                    IN           NUMBER,
    p_init_msg_list                       IN          VARCHAR2 ,
    p_commit                                IN          VARCHAR2 ,
    p_validation_level                    IN          NUMBER,
    x_return_status                         OUT    NOCOPY   VARCHAR2,
    x_msg_count                              OUT   NOCOPY      NUMBER,
    x_msg_data                            OUT       NOCOPY     VARCHAR2,
    p_repair_line_id                        IN        NUMBER,
    p_repair_quantity                    IN        NUMBER,
    p_service_code_tbl                   IN       service_code_tbl_type
   )
IS
     -- Job Record to hold the Job header, bills and routing information being inserted
     -- into wip_job_schedule_interface
     l_job_header_rec                wip_job_schedule_interface%ROWTYPE;

     lc_api_name                CONSTANT VARCHAR2(30) := 'GENERATE_WIP_JOBS_FROM_SCS';
     lc_api_version_number      CONSTANT NUMBER := 1.0;

     -- WIP Job Status Lookup Codes for Released and Unreleased status,
     -- The Lookup Type is WIP_JOB_STATUS
     lc_released_status_code     CONSTANT NUMBER :=  3;
     lc_unreleased_status_code   CONSTANT NUMBER :=  1;

     -- Non Standard Discrete Job Load Type
     lc_non_standard_load_type    CONSTANT NUMBER := 4;

     lc_service_code CONSTANT VARCHAR2(30) :=  'SERVICE_CODE';


     -- Constants used for FND_LOG debug messages
     lc_mod_name     CONSTANT      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.generate_wip_jobs_from_scs';

     l_object_version_number  NUMBER;
     l_user_id  NUMBER;
     l_repair_xref_id  NUMBER;
     l_rep_hist_id  NUMBER;
     l_error_msg VARCHAR2(2000);

     l_job_prefix   VARCHAR2(80);
     l_wip_entity_id  NUMBER;

     -- swai: bug 5239301
     l_bills_routes_count NUMBER := 0;
     l_show_messages_flag VARCHAR2(1) := 'F';
     l_service_code       VARCHAR2(30);
     -- end swai: bug 5239301

     l_ro_service_code_rec  CSD_RO_SERVICE_CODES_PVT.RO_SERVICE_CODE_REC_TYPE;

     -- Counter used for populating l_x_job_bill_routing_tbl table with
     -- Bills and Routing information
     -- Also tracks the number of jobs being submitted

      CURSOR c_get_bills_routes(c_p_service_code_id number, c_p_organization_id number )
        IS
         SELECT bom.assembly_item_id bom_reference_id,
             bom.alternate_bom_designator,
             bor.assembly_item_id routing_reference_id,
             bor.alternate_routing_designator,
             bor.completion_subinventory,
             bor. completion_locator_id
         FROM   csd_sc_work_entities cscwe,
             bom_bill_of_materials bom , bom_operational_routings bor
         WHERE  cscwe.service_code_id = c_p_service_code_id
               And    cscwe.work_entity_type_code = 'BOM'
               and    cscwe.work_entity_id3 = c_p_organization_id
               and    cscwe.work_entity_id1 = bom.bill_sequence_id (+)
               and    cscwe.work_entity_id2 = bor.routing_sequence_id (+);

     -- swai: bug 5239301
     -- Cursor to get the service code details
      CURSOR c_get_service_code_details (c_p_service_code_id number)
      IS
         SELECT service_code
         FROM csd_service_codes_b
         WHERE service_code_id = c_p_service_code_id;
     -- end swai: bug 5239301



--*****Below are the code to Default Repair Item as Material on Job**********
    l_default_ro_item               VARCHAR2(1);
--    l_wip_entity_id                 NUMBER;
    l_mtl_txn_dtls_tbl              CSD_HV_WIP_JOB_PVT.MTL_TXN_DTLS_TBL_TYPE;
    l_op_created		            VARCHAR2(10);
    l_num_other_jobs                NUMBER :=0; -- swai: bug 7477845/7483291


    CURSOR c_repair_line_info(p_repair_line_id IN NUMBER) IS
    select inventory_item_id, unit_of_measure, quantity, serial_number, inventory_org_id
    from csd_repairs
    where repair_line_id = p_repair_line_id;

    CURSOR c_count_material(p_wip_entity_id NUMBER, l_inventory_item_id NUMBER) IS
    select 'X'
    from wip_requirement_operations_v
    where wip_entity_id = p_wip_entity_id
    and inventory_item_id = l_inventory_item_id
    and rownum = 1;


    -- Cursor to select the item attributes serial control code and
    --  lot control code.
    CURSOR cur_get_item_attribs (
     p_org_id                            NUMBER,
     p_item_id                           NUMBER
    )
    IS
     SELECT serial_number_control_code
       FROM mtl_system_items
      WHERE organization_id = p_org_id AND inventory_item_id = p_item_id;


    Cursor c_get_serial_info(p_item_id number, p_serial_number varchar2, p_org_id number) is
    select current_status, current_subinventory_code from mtl_serial_numbers
    where inventory_item_id = p_item_id and serial_number = p_serial_number and current_organization_id = p_org_id;


    Cursor c_get_min_operation_seq(p_wip_entity_id number) is
    select min(operation_seq_num) from wip_operations_v where wip_entity_id = p_wip_entity_id;

    l_inventory_item_id     NUMBER;
    l_unit_of_measure       VARCHAR2(3);
    l_quantity              NUMBER;
    l_serial_number         VARCHAR2(30);
    l_inventory_org_id      NUMBER;
    l_subinventory          VARCHAR2(30);
    l_dummy                 VARCHAR2(1) := null;
    l_serial_control_code   NUMBER;
    l_current_status        NUMBER;
    l_current_subinventory_code VARCHAR2(10);
    l_operation_seq_num     NUMBER;


BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering Private API generate_wip_jobs_from_scs');
      END IF;

-- Standard Start of API savepoint
      SAVEPOINT GENERATE_WIP_JOBS_FROM_SCS_PVT;
-- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
           (lc_api_version_number,
            p_api_version_number,
            lc_api_name,
            G_PKG_NAME)
      THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status:=FND_API.G_RET_STS_SUCCESS;

      l_job_header_rec.organization_id :=
              fnd_profile.value('CSD_DEF_REP_INV_ORG');


      IF l_job_header_rec.organization_id is NULL THEN

              FND_MESSAGE.SET_NAME('CSD','CSD_DEF_REP_INV_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_job_prefix := fnd_profile.value('CSD_DEFAULT_JOB_PREFIX');

      --  If l_job_prefix is null, throw an error and return;
      IF l_job_prefix is NULL THEN
              FND_MESSAGE.SET_NAME('CSD','CSD_JOB_PREFIX_NULL');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_job_header_rec.class_code :=
           fnd_profile.value('CSD_DEF_WIP_ACCOUNTING_CLASS');

      IF l_job_header_rec.class_code is NULL THEN
           FND_MESSAGE.SET_NAME('CSD','CSD_CLASS_CODE_NULL');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Populate the Job Header Record

      -- Assign the WIP Job Status lookup codes corresponding to Released
      -- and Unreleased Job status,
      -- to be passed for WIP Interface Table


      if fnd_profile.value('CSD_DEFAULT_JOB_STATUS')   = 'RELEASED'  then
         l_job_header_rec.status_type := lc_released_status_code ;

      elsif nvl( fnd_profile.value('CSD_DEFAULT_JOB_STATUS'), 'UNRELEASED' ) = 'UNRELEASED'  then
         l_job_header_rec.status_type := lc_unreleased_status_code;
      end if;


      l_job_header_rec.load_type := lc_non_standard_load_type;
      l_job_header_rec.first_unit_start_date := sysdate;
      l_job_header_rec.last_unit_completion_date := sysdate;
      l_job_header_rec.start_quantity := p_repair_quantity;

      -- Fix for bug# 3109417
      -- If the profile CSD: Default WIP MRP Net Qty to Zero is set to
      -- null / 'N' then net_quantity = start_quantity else if the
      -- profile is set to 'Y' then net_quantity = 0
      IF ( nvl(fnd_profile.value('CSD_WIP_MRP_NET_QTY'),'N') = 'N' ) THEN
        l_job_header_rec.net_quantity := p_repair_quantity;
      ELSIF ( fnd_profile.value('CSD_WIP_MRP_NET_QTY') = 'Y' ) THEN
        l_job_header_rec.net_quantity := 0;
      END IF;

      -- dbms_output.put_line('Before Loop');
      FOR sc_ctr in p_service_code_tbl.FIRST..
            p_service_code_tbl.LAST

      LOOP

          -- dbms_output.put_line('Inside Loop');
          l_job_header_rec.primary_item_id :=
          p_service_code_tbl(sc_ctr).inventory_item_id ;

          l_bills_routes_count := 0;  -- swai: bug 5239301
          FOR bills_routes_rec in c_get_bills_routes(
              p_service_code_tbl(sc_ctr).service_code_id, l_job_header_rec.organization_id )
          LOOP
               --  dbms_output.put_line('Inside 2nd loop');

               l_bills_routes_count := l_bills_routes_count + 1; -- swai: bug 5239301

               -- Populate the Bill and Routing information
               -- table. This is passed to the insert_job_header
               -- procedure

               -- Get the Group_id to be used for WIP Create Job,
               SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.group_id FROM dual;

               -- nnadig: bug 9263438
               -- interface id should use sequence number from wip_interface_s
               -- wip_job_schedule_interface_s is for wjsi.group_id, wip_interface_s is for wjsi.interface_id.
               SELECT wip_interface_s.NEXTVAL INTO l_job_header_rec.interface_id FROM dual;


               --l_job_header_rec.interface_id := l_job_header_rec.group_id;

               l_job_header_rec.bom_reference_id := bills_routes_rec.bom_reference_id ;
               l_job_header_rec.routing_reference_id := bills_routes_rec.routing_reference_id ;
               l_job_header_rec. alternate_bom_designator:= bills_routes_rec. alternate_bom_designator;
               l_job_header_rec. alternate_routing_designator:= bills_routes_rec. alternate_routing_designator;
               l_job_header_rec.completion_subinventory := bills_routes_rec.completion_subinventory;
               l_job_header_rec.completion_locator_id := bills_routes_rec. completion_locator_id;
               generate_job_name  (      p_job_prefix       =>l_job_prefix,
                                        p_organization_id  => l_job_header_rec.organization_id,
                                        x_job_name         => l_job_header_rec.job_name );
               -- dbms_output.put_line('After generate job name');


               IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallinsert',
                        'Just before calling insert_job_header');
                    END IF;

               -- Call procedure to insert job header and bills, routing
               -- information into wip_job_schedule_interface table

               insert_job_header(   p_job_header_rec     => l_job_header_rec,
                                    x_return_status      => x_return_status );


               --   dbms_output.put_line('After insert_job_header');


               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

               -- CALL WIP API to process records in wip interface table,
               -- If API fails, Raise error, rollback and return

               -- Call WIP Mass Load API

               IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallcreateonejob',
                        'Just before calling WIP_MASSLOAD_PUB.createOneJob');
               END IF;

               WIP_MASSLOAD_PUB.createOneJob( p_interfaceID => l_job_header_rec.interface_id, --bug 9263438
                         p_validationLevel => p_validation_level,
                         x_wipEntityID => l_wip_entity_id,
                         x_returnStatus => x_return_status,
                         x_errorMsg     => x_msg_data );


               If ( ml_error_exists( l_job_header_rec.group_id )  or
                  x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

                  --  ROLLBACK to GENERATE_WIP_JOBS_FROM_SCS_PVT ;


                  FND_MESSAGE.SET_NAME('CSD','CSD_JOB_GEN_FAILURE');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;

                  -- Need to rollback  Raise exception -
                  -- once commit is removed from above call

               end if;


                --*****Below are the code to Default Repair Item as Material on Job**********

                l_default_ro_item := nvl(FND_PROFILE.VALUE('CSD_DEFAULT_RO_ITEM_AS_MATERIAL_ON_JOB'), 'N');
                --taklam
                if (l_default_ro_item = 'Y') then

                    -- swai: bug 7477845/7483291
                    -- check if there another job existing for this RO.  If so, do not default
                    -- the RO item as a material. Must compare we.wip_entity_id since
                    -- crj.wip_entity_id may be null (until wip_update is done).
                    select count(*)
                      into l_num_other_jobs
                      from csd_repair_job_xref crj,
                           wip_entities we
                     where crj.job_name        = we.wip_entity_name
                       and crj.organization_id = we.organization_id
                       and crj.repair_line_id = p_repair_line_id
                       and we.wip_entity_id <> l_wip_entity_id;

                    if (l_num_other_jobs = 0) then
                        OPEN  c_repair_line_info(p_repair_line_id);
                        FETCH c_repair_line_info into
                              l_inventory_item_id,
                              l_unit_of_measure,
                              l_quantity,
                              l_serial_number,
                              l_inventory_org_id;
                        CLOSE c_repair_line_info;
                        l_subinventory := fnd_profile.value('CSD_DEF_HV_SUBINV');

                        --Get serial number control code and lot control code
                        OPEN cur_get_item_attribs (l_inventory_org_id,
                                             l_inventory_item_id);

                        FETCH cur_get_item_attribs
                            INTO l_serial_control_code;
                        CLOSE cur_get_item_attribs;


                        IF l_serial_control_code IN (2, 5) then
                            OPEN c_get_serial_info (l_inventory_item_id, l_serial_number, l_inventory_org_id);
                            FETCH c_get_serial_info
                                INTO l_current_status,l_current_subinventory_code;
                            CLOSE c_get_serial_info;
                            --current status = 3 is valid serial number
                            if (l_current_status = 3) then
                                l_subinventory := l_current_subinventory_code;
                            else
                                l_serial_number := null;
                            end if;
                        else
                            --don't pass the serial number, it is not valid serial number
                            l_serial_number := null;
                        end if;


                        l_dummy := null;
                        OPEN c_count_material(l_wip_entity_id, l_inventory_item_id);
                        FETCH c_count_material into l_dummy;
                        CLOSE c_count_material;


                        if (l_dummy is null) then
                            --Default Repair Item as Material on Job
                            l_mtl_txn_dtls_tbl.delete;

                            OPEN  c_get_min_operation_seq(l_wip_entity_id);
                            FETCH c_get_min_operation_seq into l_operation_seq_num;
                            CLOSE c_get_min_operation_seq;

                            if (l_operation_seq_num is null) then
                                l_operation_seq_num := 1;
                            end if;

                            l_mtl_txn_dtls_tbl(0).INVENTORY_ITEM_ID          :=l_inventory_item_id;
                            l_mtl_txn_dtls_tbl(0).WIP_ENTITY_ID              :=l_wip_entity_id;
                            l_mtl_txn_dtls_tbl(0).ORGANIZATION_ID            :=l_inventory_org_id;
                            l_mtl_txn_dtls_tbl(0).OPERATION_SEQ_NUM          :=l_operation_seq_num;
                            l_mtl_txn_dtls_tbl(0).TRANSACTION_QUANTITY       :=l_quantity; --repair order qty
                            l_mtl_txn_dtls_tbl(0).TRANSACTION_UOM            :=l_unit_of_measure; --Repair order UOM
                            l_mtl_txn_dtls_tbl(0).SERIAL_NUMBER              :=l_serial_number;
                            l_mtl_txn_dtls_tbl(0).SUPPLY_SUBINVENTORY        :=l_subinventory;
                            l_mtl_txn_dtls_tbl(0).OBJECT_VERSION_NUMBER      := 1;
                            l_mtl_txn_dtls_tbl(0).NEW_ROW                    := 'Y';


                            -- call API to create Repair Actuals header
                            CSD_HV_WIP_JOB_PVT.PROCESS_SAVE_MTL_TXN_DTLS
                                    ( p_api_version_number      => 1.0,
                                      p_init_msg_list           => 'T',
                                      p_commit                  => 'F',
                                      p_validation_level        => 1,
                                      p_mtl_txn_dtls_tbl		=> l_mtl_txn_dtls_tbl,
                                      x_op_created				=> l_op_created,
                                      x_return_status           => x_return_status,
                                      x_msg_count               => x_msg_count,
                                      x_msg_data                => x_msg_data);
                            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                                FND_MESSAGE.SET_NAME('CSD','CSD_JOB_GEN_FAILURE');
                                FND_MSG_PUB.ADD;
                                RAISE FND_API.G_EXC_ERROR;
                            END IF;
                        end if;
                    end if; -- swai: bug 7477845/7483291 l_num_other_jobs = 0
                end if;

                --*****End of the code to Default Repair Item as Material on Job**********

               --     dbms_output.put_line('After createOneJob');

               -- call procedures to insert a row in csd_repair_job_xref
               --  and csd_repair_history tables for the job created.

               l_user_id := fnd_global.user_id;

               IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                        lc_mod_name||'beforecallxrefwrite',
                        'Just before calling csd_to_form_repair_job_xref.validate_and_write');
               END IF;

               csd_to_form_repair_job_xref.validate_and_write(
                    p_api_version_number => lc_api_version_number,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_commit => FND_API.G_FALSE,
                    p_validation_level => NULL,
                    p_action_code => 0,
                    px_repair_job_xref_id => l_repair_xref_id,
                    p_created_by =>  l_user_id,
                    p_creation_date => SYSDATE,
                    p_last_updated_by => l_user_id,
                    p_last_update_date => SYSDATE,
                    p_last_update_login => l_user_id,
                    p_repair_line_id => p_repair_line_id,
                    p_wip_entity_id => l_wip_entity_id,
                    p_group_id => l_job_header_rec.group_id,
                    p_organization_id => l_job_header_rec.organization_id,
                    p_quantity => p_repair_quantity,
                    p_INVENTORY_ITEM_ID => l_job_header_rec.primary_item_id,
                    p_ITEM_REVISION =>  null,
                    p_OBJECT_VERSION_NUMBER => NULL,
                    p_attribute_category => NULL,
                    p_attribute1 => NULL,
                    p_attribute2 => NULL,
                    p_attribute3 => NULL,
                    p_attribute4 => NULL,
                    p_attribute5 => NULL,
                    p_attribute6 => NULL,
                    p_attribute7 => NULL,
                    p_attribute8 => NULL,
                    p_attribute9 => NULL,
                    p_attribute10 => NULL,
                    p_attribute11 => NULL,
                    p_attribute12 => NULL,
                    p_attribute13 => NULL,
                    p_attribute14 => NULL,
                    p_attribute15 => NULL,
                    p_quantity_completed => NULL,
                    p_job_name  =>  l_job_header_rec.job_name,
                    p_source_type_code  =>  lc_service_code,
                    p_source_id1  =>  p_service_code_tbl(sc_ctr).service_code_id,
                    p_ro_service_code_id  =>  p_service_code_tbl(sc_ctr).ro_service_code_id,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);

               --       dbms_output.put_line('After call to   csd_to_form_repair_job_xref.validate_and_write');


               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  ROLLBACK to GENERATE_WIP_JOBS_FROM_SCS_PVT ;
                  IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                     FND_LOG.STRING( FND_LOG.LEVEL_ERROR,
                     lc_mod_name||'exc_exception',
                     'G_EXC_ERROR Exception');
                  END IF;
                  RETURN;
               END IF;

               IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                  FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                  lc_mod_name||'beforecallhistwrite',
                  'Just before calling csd_to_form_repair_history.validate_and_write');
               END IF;

               csd_to_form_repair_history.validate_and_write(
                    p_api_version_number => lc_api_version_number,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_commit => FND_API.G_FALSE,
                    p_validation_level => NULL,
                    p_action_code => 0,
                    px_repair_history_id => l_rep_hist_id,
                    p_OBJECT_VERSION_NUMBER => NULL,
                    p_request_id => NULL,
                    p_program_id => NULL,
                    p_program_application_id => NULL,
                    p_program_update_date => NULL,
                    p_created_by =>  l_user_id,
                    p_creation_date => SYSDATE,
                    p_last_updated_by => l_user_id,
                    p_last_update_date => SYSDATE,
                    p_repair_line_id => p_repair_line_id,
                    p_event_code => 'JS',
                    p_event_date => SYSDATE,
                    p_quantity => p_repair_quantity,
                    p_paramn1 => l_wip_entity_id,
                    p_paramn2 => l_job_header_rec.organization_id,
                    p_paramn3 => NULL,
                    p_paramn4 => NULL,
                    p_paramn5 => p_repair_quantity,
                    p_paramn6 => NULL,
                    p_paramn8 => NULL,
                    p_paramn9 => NULL,
                    p_paramn10 => NULL,
                    p_paramc1 => l_job_header_rec.job_name,
                    p_paramc2 => NULL,
                    p_paramc3 => NULL,
                    p_paramc4 => NULL,
                    p_paramc5 => NULL,
                    p_paramc6 => NULL,
                    p_paramc7 => NULL,
                    p_paramc8 => NULL,
                    p_paramc9 => NULL,
                    p_paramc10 => NULL,
                    p_paramd1 => NULL ,
                    p_paramd2 => NULL ,
                    p_paramd3 => NULL ,
                    p_paramd4 => NULL ,
                    p_paramd5 => SYSDATE,
                    p_paramd6 => NULL ,
                    p_paramd7 => NULL ,
                    p_paramd8 => NULL ,
                    p_paramd9 => NULL ,
                    p_paramd10 => NULL ,
                    p_attribute_category => NULL ,
                    p_attribute1 => NULL ,
                    p_attribute2 => NULL ,
                    p_attribute3 => NULL ,
                    p_attribute4 => NULL ,
                    p_attribute5 => NULL ,
                    p_attribute6 => NULL ,
                    p_attribute7 => NULL ,
                    p_attribute8 => NULL ,
                    p_attribute9 => NULL ,
                    p_attribute10 => NULL ,
                    p_attribute11 => NULL ,
                    p_attribute12 => NULL ,
                    p_attribute13 => NULL ,
                    p_attribute14 => NULL ,
                    p_attribute15 => NULL ,
                    p_last_update_login  => l_user_id,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);

               --     dbms_output.put_line('after call to csd_to_form_repair_history.validate_and_write');

               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  ROLLBACK to GENERATE_WIP_JOBS_FROM_SCS_PVT ;
                  IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING( FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
                  END IF;
                  RETURN;
               END IF;
          END LOOP; -- bills and routes

          -- swai: bug 5239301
          -- if there are no bills or routes for this service code, get the
          -- service code name and log a warning message
          if (l_bills_routes_count = 0) then
              l_show_messages_flag := 'T';
              open c_get_service_code_details(p_service_code_tbl(sc_ctr).service_code_id);
              fetch c_get_service_code_details into l_service_code;
              close c_get_service_code_details;
              FND_MESSAGE.SET_NAME('CSD', 'CSD_NO_BILLS_ROUTES_FOR_SC');
              FND_MESSAGE.set_token('SERVICE_CODE', l_service_code);
              FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_WARNING_MSG);
          end if;
          -- swai: end bug 5239301

          l_ro_service_code_rec.ro_service_code_id := p_service_code_tbl(sc_ctr).ro_service_code_id;
          l_ro_service_code_rec.applied_to_work_flag := 'Y' ;
          l_ro_service_code_rec.object_version_number := p_service_code_tbl(sc_ctr).object_version_number;


          --  l_object_version_number := p_service_code_tbl(sc_ctr).object_version_number;

          IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                    FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                     lc_mod_name||'beforecallupdatesc',
                     'Just before calling CSD_RO_SERVICE_CODES_PVT.Update_RO_Service_Code');
          END IF;



          CSD_RO_SERVICE_CODES_PVT.Update_RO_Service_Code(
              p_api_version      => lc_api_version_number,
              p_commit     => FND_API.G_FALSE,
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => 100,
              p_ro_service_code_rec => l_ro_service_code_rec,
              x_obj_ver_number   => l_object_version_number,
              x_return_status    => x_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data ) ;


          -- dbms_output.put_line('after call to CSD_RO_SERVICE_CODES_PVT.Update_RO_Service_Code');
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               -- dbms_output.put_line('inside return status CSD_RO_SERVICE_CODES_PVT.Update_RO_Service_Code');
               ROLLBACK to GENERATE_WIP_JOBS_FROM_SCS_PVT ;
               IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING( FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
               END IF;
               RETURN;
          END IF;

      END LOOP;  -- service codes

      -- swai: bug 5239301
      -- if there are messages to show, then set the return status in order
      -- to flag this, but do not rollback.
      if l_show_messages_flag = 'T' then
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                 p_count  => x_msg_count,
                                 p_data   => x_msg_data);
      end if;
      -- swai: end bug 5239301

-- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;


EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to GENERATE_WIP_JOBS_FROM_SCS_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to GENERATE_WIP_JOBS_FROM_SCS_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to GENERATE_WIP_JOBS_FROM_SCS_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;


END generate_wip_jobs_from_scs;

--
-- swai: 12.1.2 Time clock functionality
-- Auto-issues all material lines.
-- If WIP entity id and operaion are specified, then only materials for
-- that operation will be issued and repair line will be disregarded.
-- Future functionality:
-- If repair line id is specified without wip entity id and operation,
-- then all materials for all jobs on that repair order will be issued.
--
PROCEDURE process_auto_issue_mtl_txn
(
    p_api_version_number                        IN         NUMBER,
    p_init_msg_list                             IN         VARCHAR2,
    p_commit                                    IN         VARCHAR2,
    p_validation_level                          IN         NUMBER,
    x_return_status                             OUT NOCOPY VARCHAR2,
    x_msg_count                                 OUT NOCOPY NUMBER,
    x_msg_data                                  OUT NOCOPY VARCHAR2,
    p_wip_entity_id                             IN         NUMBER,
    p_operation_seq_num                         IN         NUMBER,
    p_repair_line_id                            IN         NUMBER,
    x_transaction_header_id                     OUT NOCOPY NUMBER
) IS
    -- constants used for FND_LOG debug messages
    lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_AUTO_ISSUE_MTL_TXN';
    lc_api_version_number      CONSTANT NUMBER := 1.0;
    lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_auto_issue_mtl_txn';

    CURSOR get_wip_operation_mtls (p_wip_entity_id number, p_operation_seq_num number) is
    SELECT * FROM
    ( SELECT
          CWTD.WIP_TRANSACTION_DETAIL_ID,                -- wip_transaction_detail_id
          WRO.REQUIRED_QUANTITY,                         -- required_quantity
          DECODE(WRO.QUANTITY_ISSUED, 0, to_number(NULL),
               WRO.QUANTITY_ISSUED )   QUANTITY_ISSUED,  -- issued_quantity
          wdj.start_quantity,                            -- job_quantity
          null OP_SCHEDULED_QUANTITY,                    -- op_scheduled_quantity
          WRO.INVENTORY_ITEM_ID,  -- inventory_item_id
          WRO.WIP_ENTITY_ID,      -- wip_entity_id
          WRO.ORGANIZATION_ID,    -- organization_id
          WRO.OPERATION_SEQ_NUM,  -- operation_seq_num

          nvl( CWTD.TRANSACTION_QUANTITY,
               (WRO.REQUIRED_QUANTITY  -  WRO.QUANTITY_ISSUED )
                )    TRANSACTION_QUANTITY,               -- transaction_quantity
          decode ( CWTD.TRANSACTION_QUANTITY, null, MSIK.PRIMARY_UOM_CODE,
               nvl ( CWTD.TRANSACTION_UOM ,  MSIK.PRIMARY_UOM_CODE) ) TRANSACTION_UOM, -- transaction_uom
          MSIK.PRIMARY_UOM_CODE ITEM_PRIMARY_UOM_CODE,   -- uom_code
          CWTD.SERIAL_NUMBER,              -- serial_number
          null,                            -- lot number
          CWTD.REVISION revision,          -- revision
          MSIK.REVISION_QTY_CONTROL_CODE,  -- revision_qty_control_code
          MSIK.SERIAL_NUMBER_CONTROL_CODE, -- serial_number_control_code
          MSIK.LOT_CONTROL_CODE,           -- lot_control_code
          nvl ( WRO.supply_subinventory,
             decode ( fnd_profile.value('CSD_DEF_REP_INV_ORG') ,  WRO.ORGANIZATION_ID ,
                    fnd_profile.value('CSD_DEF_HV_SUBINV') , null ) )
             subinventory_code,             -- supply_subinventory
          WRO.supply_locator_id locator_id, -- supply_locator_id
          null transaction_interface_id,    -- transaction_interface_id
          null object_version_number,       -- object_version_number
          'N' new_row,                      -- new_row
          CWTD.reason_id                    -- reason_id
        FROM
          CSD_REPAIR_JOB_XREF  CRJX,
          WIP_REQUIREMENT_OPERATIONS WRO,
          MTL_SYSTEM_ITEMS_KFV MSIK,
          WIP_ENTITIES  WE,
          CSD_WIP_TRANSACTION_DETAILS CWTD,
          WIP_DISCRETE_JOBS WDJ,
          WIP_OPERATIONS WO,
          MTL_SERIAL_NUMBERS MSN,
          MTL_TRANSACTION_REASONS MTR
        WHERE
          CRJX.wip_entity_id = p_wip_entity_id
          AND WO.operation_seq_num = p_operation_seq_num
          AND CRJX.wip_entity_id = WRO.wip_entity_id
          AND WRO.INVENTORY_ITEM_ID =  MSIK.INVENTORY_ITEM_ID
          AND WRO.ORGANIZATION_ID = MSIK.ORGANIZATION_ID
          AND WRO.WIP_ENTITY_ID  =  WE.WIP_ENTITY_ID
          AND WRO.WIP_ENTITY_ID  =  WDJ.WIP_ENTITY_ID
          AND WDJ.STATUS_TYPE <> 12
          AND CWTD.INVENTORY_ITEM_ID(+) = WRO.INVENTORY_ITEM_ID
          AND CWTD.WIP_ENTITY_ID(+) = WRO.WIP_ENTITY_ID
          AND CWTD.OPERATION_SEQ_NUM(+) = WRO.OPERATION_SEQ_NUM
          AND WRO.WIP_ENTITY_ID  = WO.WIP_ENTITY_ID
          AND WRO.ORGANIZATION_ID  = WO.ORGANIZATION_ID
          AND WRO.OPERATION_SEQ_NUM  = WO.OPERATION_SEQ_NUM
          AND CWTD.SERIAL_NUMBER = MSN.SERIAL_NUMBER (+)
          AND CWTD.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID (+)
          AND CWTD.REASON_ID = MTR.REASON_ID (+)
    )
    WHERE transaction_quantity <> 0;

    -- local variables --
    l_mtl_txn_dtls_tbl MTL_TXN_DTLS_TBL_TYPE;
BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
              lc_mod_name||'begin',
              'Entering private API process_issue_mtl_txn' );
    END IF;

    SAVEPOINT PROCESS_AUTO_ISSUE_MTL_TXN_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (lc_api_version_number,
                                        p_api_version_number,
                                        lc_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open get_wip_operation_mtls(p_wip_entity_id, p_operation_seq_num);
    fetch get_wip_operation_mtls bulk collect into l_mtl_txn_dtls_tbl;
    close get_wip_operation_mtls;
    if (l_mtl_txn_dtls_tbl.count > 0) then
        process_issue_mtl_txn(
            p_api_version_number    => p_api_version_number,
            p_init_msg_list         => p_init_msg_list,
            p_commit                => p_commit,
            p_validation_level      => p_validation_level,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_mtl_txn_dtls_tbl      => l_mtl_txn_dtls_tbl,
            x_transaction_header_id => x_transaction_header_id
        );
    end if;

-- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;


EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_AUTO_ISSUE_MTL_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_AUTO_ISSUE_MTL_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_AUTO_ISSUE_MTL_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;

END process_auto_issue_mtl_txn;

--
-- swai: 12.1.2 Time clock functionality
-- Auto-transacts all resource lines.
-- If WIP entity id and operaion are specified, then only resources for
-- that operation will be issued and repair line will be disregarded.
-- Future functionality:
-- If repair line id is specified without wip entity id and operation,
-- then all resources for all jobs on that repair order will be issued.
--
PROCEDURE process_auto_transact_res_txn
(
    p_api_version_number                  IN         NUMBER,
    p_init_msg_list                       IN         VARCHAR2,
    p_commit                              IN         VARCHAR2,
    p_validation_level                    IN         NUMBER,
    x_return_status                       OUT NOCOPY VARCHAR2,
    x_msg_count                           OUT NOCOPY NUMBER,
    x_msg_data                            OUT NOCOPY VARCHAR2,
    p_wip_entity_id                       IN         NUMBER,
    p_operation_seq_num                   IN         NUMBER,
    p_repair_line_id                      IN         NUMBER
) IS
    -- constants used for FND_LOG debug messages
    lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_AUTO_TRANSACT_RES_TXN';
    lc_api_version_number      CONSTANT NUMBER := 1.0;
    lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_auto_transact_res_txn';

    CURSOR get_wip_operation_res (p_wip_entity_id number, p_operation_seq_num number) is
    SELECT * FROM
    ( SELECT
        WTD.WIP_TRANSACTION_DETAIL_ID,
        ROUND(WOR.USAGE_RATE_OR_AMOUNT * DECODE(WOR.BASIS_TYPE,1, WO.SCHEDULED_QUANTITY,1), 6) required_quantity,
        decode (( WOR.APPLIED_RESOURCE_UNITS
                  + csd_hv_wip_job_pvt.get_pending_quantity ( wor.wip_entity_id, wor.operation_seq_num, wor.resource_seq_num, WOR.UOM_CODE )
                ) , 0 , to_number(null) ,
                ( WOR.APPLIED_RESOURCE_UNITS
                  +  csd_hv_wip_job_pvt.get_pending_quantity ( wor.wip_entity_id, wor.operation_seq_num, wor.resource_seq_num, WOR.UOM_CODE )
                ) ) QUANTITY_APPLIED,
        null pending_quantity,
        wdj.start_quantity,
        wo.scheduled_quantity op_scheduled_quantity,
        wor.basis_type basis_type,
        wor.resource_id,
        WOR.RESOURCE_SEQ_NUM,
        WOR.WIP_ENTITY_ID,
        WOR.ORGANIZATION_ID,
        mp.organization_code,
        WOR.OPERATION_SEQ_NUM,
        nvl( WTD.TRANSACTION_QUANTITY,
                       decode ( sign (( WOR.USAGE_RATE_OR_AMOUNT * DECODE(WOR.BASIS_TYPE,1, WO.SCHEDULED_QUANTITY,1) )
                                      - WOR.APPLIED_RESOURCE_UNITS
                                      - csd_hv_wip_job_pvt.get_pending_quantity ( wor.wip_entity_id, wor.operation_seq_num, wor.resource_seq_num, WOR.UOM_CODE )
                                     ) ,  1 ,
                                round ((( WOR.USAGE_RATE_OR_AMOUNT * DECODE(WOR.BASIS_TYPE,1, WO.SCHEDULED_QUANTITY,1) )
                                      -  WOR.APPLIED_RESOURCE_UNITS
                                      -  csd_hv_wip_job_pvt.get_pending_quantity ( wor.wip_entity_id, wor.operation_seq_num, wor.resource_seq_num, WOR.UOM_CODE )
                                       ), 6 ), 0 )
            ) TRANSACTION_QUANTITY,
        nvl ( WTD.TRANSACTION_UOM ,  WOR.UOM_CODE) transaction_uom,  -- transaction uom
        WOR.UOM_CODE,
        WE.WIP_ENTITY_NAME,
        wtd.employee_id,
        papf.employee_number employee_num,
        wtd.object_version_number,
        'N' new_row
    FROM CSD_REPAIR_JOB_XREF  CRJX,
         WIP_OPERATION_RESOURCES WOR,
         WIP_ENTITIES  WE,
         CSD_WIP_TRANSACTION_DETAILS  WTD,
         BOM_RESOURCES BR,
         wip_operations wo,
         WIP_DISCRETE_JOBS wdj,
         per_all_people_f papf,
          MTL_PARAMETERS MP
    WHERE   CRJX.wip_entity_id = p_wip_entity_id
        AND WO.operation_seq_num = p_operation_seq_num
        AND CRJX.wip_entity_id = WOR.wip_entity_id
        AND WOR.WIP_ENTITY_ID  =  WE.WIP_ENTITY_ID
        AND WOR.WIP_ENTITY_ID  =  WDJ.WIP_ENTITY_ID
        AND WOR.RESOURCE_ID = BR.RESOURCE_ID
        AND WOR. WIP_ENTITY_ID =  WTD. WIP_ENTITY_ID(+)
        AND WOR. OPERATION_SEQ_NUM = WTD. OPERATION_SEQ_NUM(+)
                        AND   WOR.RESOURCE_SEQ_NUM
                = WTD. RESOURCE_SEQ_NUM(+)
        AND wtd.employee_id = papf.person_id(+)
        AND trunc(sysdate) between nvl( papf.effective_start_date, sysdate-1)
                            and nvl(papf.effective_end_date, sysdate)
        AND wor.organization_id = MP.ORGANIZATION_ID
        AND wdj.status_type <> 12
        AND WOR.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
        AND WOR.OPERATION_SEQ_NUM = WO.OPERATION_SEQ_NUM
        AND WOR.ORGANIZATION_ID = WO.ORGANIZATION_ID
        AND NVL(WOR.REPETITIVE_SCHEDULE_ID,-1)=NVL(WO.REPETITIVE_SCHEDULE_ID,-1)
    )
    WHERE transaction_quantity <> 0;

    -- local variables --
    l_res_txn_dtls_tbl RES_TXN_DTLS_TBL_TYPE;

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
              lc_mod_name||'begin',
              'Entering private API process_auto_transact_res_txn' );
    END IF;

    SAVEPOINT PROCESS_AUTO_TRANS_RES_TXN_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (lc_api_version_number,
                                        p_api_version_number,
                                        lc_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open get_wip_operation_res(p_wip_entity_id, p_operation_seq_num);
    fetch get_wip_operation_res bulk collect into l_res_txn_dtls_tbl;
    close get_wip_operation_res;
    if (l_res_txn_dtls_tbl.count > 0) then
        process_transact_res_txn(
            p_api_version_number    => p_api_version_number,
            p_init_msg_list         => p_init_msg_list,
            p_commit                => p_commit,
            p_validation_level      => p_validation_level,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_res_txn_dtls_tbl      => l_res_txn_dtls_tbl
        );
    end if;

-- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;


EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_AUTO_TRANS_RES_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_AUTO_TRANS_RES_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_AUTO_TRANS_RES_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;

END process_auto_transact_res_txn;

--
-- swai: 12.1.2 Time clock functionality
-- Auto-completes an operations
-- If WIP entity id and operaion are specified, then only the spcified
-- operation will be completed.
-- Future functionality:
-- If repair line id is specified without wip entity id and operation,
-- then all operations on all jobs on that repair order will be completed.
--
PROCEDURE process_auto_oper_comp_txn
(
    p_api_version_number                  IN         NUMBER,
    p_init_msg_list                       IN         VARCHAR2,
    p_commit                              IN         VARCHAR2,
    p_validation_level                    IN         NUMBER,
    x_return_status                       OUT NOCOPY VARCHAR2,
    x_msg_count                           OUT NOCOPY NUMBER,
    x_msg_data                            OUT NOCOPY VARCHAR2,
    p_wip_entity_id                       IN         NUMBER,
    p_operation_seq_num                   IN         NUMBER,
    p_repair_line_id                      IN         NUMBER

) IS

    -- constants used for FND_LOG debug messages
    lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_AUTO_OPER_COMP_TXN';
    lc_api_version_number      CONSTANT NUMBER := 1.0;
    lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_auto_oper_comp_txn';

    CURSOR get_wip_operation (p_wip_entity_id number, p_operation_seq_num number) is
    SELECT
         we.wip_entity_name,
         crjx.organization_id,
         wo.operation_seq_num,
         wo.next_operation_seq_num,
         wo.quantity_in_queue,   -- transaction_quantity
         msik.primary_uom_code,  -- transaction_uom
         crjx.wip_entity_id
    FROM CSD_REPAIR_JOB_XREF  CRJX,
         WIP_OPERATIONS WO,
         BOM_DEPARTMENTS BD,
         wip_discrete_jobs wdj,
         wip_entities we,
         mfg_lookups ml,
         mtl_system_items_kfv msik,
         csd_service_codes_vl cscv,
         csd_wip_transaction_details WTD,
         bom_standard_operations bso
    WHERE
         CRJX.wip_entity_id = p_wip_entity_id AND
         WO.operation_seq_num = p_operation_seq_num AND
         CRJX.wip_entity_id = WO.wip_entity_id(+) AND
         crjx.wip_entity_id = we.wip_entity_id AND
         crjx.wip_entity_id = wdj.wip_entity_id AND
         wdj.status_type = ml.lookup_code AND
         ml.lookup_type = 'WIP_JOB_STATUS' AND
         crjx.inventory_item_id = msik.inventory_item_id AND
         crjx.organization_id = msik.organization_id AND
         crjx.source_id1 = cscv.service_code_id (+) AND
         WO.DEPARTMENT_ID = BD.DEPARTMENT_ID(+) AND
         wdj.status_type <> 12 AND
         WO.wip_entity_id = WTD.WIP_ENTITY_ID(+) AND
         WO.operation_seq_num = WTD.operation_seq_num(+) AND
         WO.department_id = wtd.department_id(+) AND
         wo.standard_operation_id = bso.standard_operation_id(+) AND
         wo.quantity_completed <> wo.scheduled_quantity; -- only uncompleted operationss

    -- local variables --
    l_mv_txn_dtls_tbl MV_TXN_DTLS_TBL_TYPE;

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
              lc_mod_name||'begin',
              'Entering private API process_auto_oper_comp_txn' );
    END IF;

    SAVEPOINT PROCESS_AUTO_OPER_COMP_TXN_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (lc_api_version_number,
                                        p_api_version_number,
                                        lc_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open get_wip_operation(p_wip_entity_id, p_operation_seq_num);
    fetch get_wip_operation bulk collect into l_mv_txn_dtls_tbl;
    close get_wip_operation;
    if (l_mv_txn_dtls_tbl.count > 0) then
        process_oper_comp_txn(
            p_api_version_number    => p_api_version_number,
            p_init_msg_list         => p_init_msg_list,
            p_commit                => p_commit,
            p_validation_level      => p_validation_level,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_mv_txn_dtls_tbl      => l_mv_txn_dtls_tbl
        );
    end if;

-- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;


EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_AUTO_OPER_COMP_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_AUTO_OPER_COMP_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_AUTO_OPER_COMP_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;
END process_auto_oper_comp_txn;

--
PROCEDURE process_time_clock_res_txn
(
    p_api_version_number                  IN         NUMBER,
    p_init_msg_list                       IN         VARCHAR2,
    p_commit                              IN         VARCHAR2,
    p_validation_level                    IN         NUMBER,
    x_return_status                       OUT NOCOPY VARCHAR2,
    x_msg_count                           OUT NOCOPY NUMBER,
    x_msg_data                            OUT NOCOPY VARCHAR2,
    p_time_clock_entry_id                 IN         NUMBER
) IS
    -- constants used for FND_LOG debug messages
    lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_TIME_CLOCK_RES_TXN';
    lc_api_version_number      CONSTANT NUMBER := 1.0;
    lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_time_clock_res_txn';

    l_wip_entity_id     NUMBER;
    l_operation_seq_num NUMBER;
    l_employee_id       NUMBER;
    l_resource_id       NUMBER;
    l_clock_in_time     DATE;
    l_clock_out_time    DATE;
    l_res_txn_dtls_tbl  RES_TXN_DTLS_TBL_TYPE;
    l_existing_res_txn  RES_TXN_DTLS_REC_TYPE;
    l_clocked_time      NUMBER;
    l_exists            VARCHAR2(10);

    cursor get_time_clock_entry is
        select wip_entity_id,
               operation_seq_num,
               employee_id,
               resource_id,
               clock_in_time,
               clock_out_time
        from   csd_time_clock_entries
        where  time_clock_entry_id = p_time_clock_entry_id;

    cursor get_employee_num (p_organization_id NUMBER, p_employee_id NUMBER) is
        select employee_num
        from   mtl_employees_current_view
        where  organization_id = p_organization_id
          and  employee_id = p_employee_id;

    -- swai: bug 8923513
    -- validates the resource belongs to the same department as the operation
    cursor validate_op_res_dept (p_wip_entity_id NUMBER,
                                 p_operation_seq_num NUMBER,
                                 p_resource_id NUMBER) is
        SELECT
          'exists'
        FROM
          cst_activities cst,
          mtl_uom_conversions muc,
          bom_resources res,
          bom_department_resources bdr,
          bom_departments bd,
          mfg_lookups lup ,
          wip_operations wo
        WHERE nvl(res.disable_date, sysdate + 2) > sysdate
          and res.resource_id = bdr.resource_id
          and res.default_activity_id = cst.activity_id (+)
          and nvl(cst.organization_id(+), res.organization_id) = res.organization_id
          and nvl(cst.disable_date (+), sysdate + 2) > sysdate
          and res.unit_of_measure = muc.uom_code
          and muc.inventory_item_id = 0
          and lookup_type = 'BOM_AUTOCHARGE_TYPE'
          and lookup_code=nvl(res.autocharge_type,1)
          and bdr.department_id = bd.department_id
          and wo.department_id = bdr.department_id
          and res.organization_id = wo.organization_id
          and wo.wip_entity_id = p_wip_entity_id
          and wo.operation_seq_num = p_operation_seq_num
          and res.resource_id = p_resource_id
          and rownum = 1;

    cursor get_resource_info (p_wip_entity_id NUMBER,
                                     p_operation_seq_num NUMBER,
                                     p_resource_id NUMBER) is
        SELECT
            WTD.WIP_TRANSACTION_DETAIL_ID,
            wor.resource_id,
            WOR.RESOURCE_SEQ_NUM,
            WOR.WIP_ENTITY_ID,
            WE.WIP_ENTITY_NAME,
            WOR.ORGANIZATION_ID,
            MP.ORGANIZATION_CODE,
            WOR.OPERATION_SEQ_NUM,
            WDJ.START_QUANTITY job_quantity,
            ROUND(WOR.USAGE_RATE_OR_AMOUNT * DECODE(WOR.BASIS_TYPE,1, WO.SCHEDULED_QUANTITY,1), 6) required_quantity,
            WO.SCHEDULED_QUANTITY op_scheduled_quantity,
            ROUND(   decode (
                          ( WOR.APPLIED_RESOURCE_UNITS
                   +  csd_hv_wip_job_pvt.get_pending_quantity ( wor.wip_entity_id,
                wor.operation_seq_num,
                wor.resource_seq_num,
                WOR.UOM_CODE ) ) , 0 ,
                                       to_number(null) ,
                                     ( WOR.APPLIED_RESOURCE_UNITS
                   +  csd_hv_wip_job_pvt.get_pending_quantity ( wor.wip_entity_id,
                wor.operation_seq_num,
                wor.resource_seq_num,
                WOR.UOM_CODE ) )
                                ), 2
            )    APPLIED_QUANTITY,    -- quantity applied
            NVL( WTD.TRANSACTION_QUANTITY,
                           decode ( sign (( WOR.USAGE_RATE_OR_AMOUNT * DECODE(WOR.BASIS_TYPE,1, WO.SCHEDULED_QUANTITY,1) )
                                          - WOR.APPLIED_RESOURCE_UNITS
                                          - csd_hv_wip_job_pvt.get_pending_quantity ( wor.wip_entity_id, wor.operation_seq_num, wor.resource_seq_num, WOR.UOM_CODE )
                                         ) ,  1 ,
                                    round ((( WOR.USAGE_RATE_OR_AMOUNT * DECODE(WOR.BASIS_TYPE,1, WO.SCHEDULED_QUANTITY,1) )
                                          -  WOR.APPLIED_RESOURCE_UNITS
                                          -  csd_hv_wip_job_pvt.get_pending_quantity ( wor.wip_entity_id, wor.operation_seq_num, wor.resource_seq_num, WOR.UOM_CODE )
                                           ), 6 ), 0 )
                ) TRANSACTION_QUANTITY,
            nvl ( WTD.TRANSACTION_UOM ,  WOR.UOM_CODE) transaction_uom,  -- transaction uom
            WOR.UOM_CODE,
            wtd.employee_id,
            papf.employee_number employee_num,
            wor.basis_type basis_type,
            wtd.object_version_number,
            'N' new_row
        FROM CSD_REPAIR_JOB_XREF  CRJX,
             WIP_OPERATION_RESOURCES WOR,
             WIP_ENTITIES  WE,
             CSD_WIP_TRANSACTION_DETAILS  WTD,
             BOM_RESOURCES BR,
             wip_operations wo,
             WIP_DISCRETE_JOBS wdj,
             per_all_people_f papf,
             MTL_PARAMETERS MP
        WHERE   CRJX.wip_entity_id = p_wip_entity_id
            AND WO.operation_seq_num = p_operation_seq_num
            AND WOR.RESOURCE_ID = p_resource_id
            AND CRJX.wip_entity_id = WOR.wip_entity_id
            AND WOR.WIP_ENTITY_ID  =  WE.WIP_ENTITY_ID
            AND WOR.WIP_ENTITY_ID  =  WDJ.WIP_ENTITY_ID
            AND WOR.RESOURCE_ID = BR.RESOURCE_ID
            AND WOR. WIP_ENTITY_ID =  WTD. WIP_ENTITY_ID(+)
            AND WOR. OPERATION_SEQ_NUM = WTD. OPERATION_SEQ_NUM(+)
                            AND   WOR.RESOURCE_SEQ_NUM
                    = WTD. RESOURCE_SEQ_NUM(+)
            AND wtd.employee_id = papf.person_id(+)
            AND trunc(sysdate) between nvl( papf.effective_start_date, sysdate-1)
                                and nvl(papf.effective_end_date, sysdate)
            AND wor.organization_id = MP.ORGANIZATION_ID
            AND wdj.status_type <> 12
            AND WOR.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
            AND WOR.OPERATION_SEQ_NUM = WO.OPERATION_SEQ_NUM
            AND WOR.ORGANIZATION_ID = WO.ORGANIZATION_ID
            AND NVL(WOR.REPETITIVE_SCHEDULE_ID,-1)=NVL(WO.REPETITIVE_SCHEDULE_ID,-1);

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
              lc_mod_name||'begin',
              'Entering private API process_time_clock_res_txn' );
    END IF;

    SAVEPOINT PROCESS_TIME_CLOCK_RES_TXN_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (lc_api_version_number,
                                        p_api_version_number,
                                        lc_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open get_time_clock_entry;
    fetch get_time_clock_entry
    into    l_wip_entity_id,
            l_operation_seq_num,
            l_employee_id,
            l_resource_id,
            l_clock_in_time,
            l_clock_out_time;
    close get_time_clock_entry;

    if (l_resource_id is null) then
        l_resource_id :=  fnd_profile.value('CSD_DEF_HV_BOM_RESOURCE');-- get resource from profile value.
        if (l_resource_id is null) then
              FND_MESSAGE.SET_NAME('CSD', 'CSD_NO_DEF_HV_BOM_RESOURCE');
              FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_WARNING_MSG);
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RETURN;
        else
            -- Bug 8923513: Validate the resource against the operation department
            -- if resource does not belong to department, throw error.
            open validate_op_res_dept (l_wip_entity_id, l_operation_seq_num, l_resource_id);
            fetch validate_op_res_dept into  l_exists;
            close validate_op_res_dept;

            if (l_exists is null) then
              FND_MESSAGE.SET_NAME('CSD', 'CSD_INVALID_DEF_HV_BOM_RES');
              FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_WARNING_MSG);
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RETURN;
            end if;
        end if;
    end if;

    -- query for existing resource transaction before transacting additional resources
    open get_resource_info (l_wip_entity_id, l_operation_seq_num, l_resource_id);
    fetch get_resource_info
    into    l_existing_res_txn.wip_transaction_detail_id,
            l_existing_res_txn.resource_id,
            l_existing_res_txn.resource_seq_num,
            l_existing_res_txn.wip_entity_id,
            l_existing_res_txn.wip_entity_name,
            l_existing_res_txn.organization_id,
            l_existing_res_txn.organization_code,
            l_existing_res_txn.operation_seq_num,
            l_existing_res_txn.job_quantity,
            l_existing_res_txn.required_quantity,
            l_existing_res_txn.op_scheduled_quantity,
            l_existing_res_txn.applied_quantity,
            l_existing_res_txn.transaction_quantity,
            l_existing_res_txn.transaction_uom,
            l_existing_res_txn.uom_code,
            l_existing_res_txn.employee_id,
            l_existing_res_txn.employee_num,
            l_existing_res_txn.basis_type,
            l_existing_res_txn.object_version_number,
            l_existing_res_txn.new_row;
    close get_resource_info;

    -- populate resource details table to create and/or transact
    l_clocked_time := l_clock_out_time - l_clock_in_time;
    l_res_txn_dtls_tbl(1).transaction_quantity  := l_clocked_time;
    l_res_txn_dtls_tbl(1).transaction_uom       := 'DAY';
    l_res_txn_dtls_tbl(1).wip_entity_id         := l_wip_entity_id;
    l_res_txn_dtls_tbl(1).operation_seq_num     := l_operation_seq_num;
    l_res_txn_dtls_tbl(1).employee_id           := l_employee_id;
    l_res_txn_dtls_tbl(1).resource_id           := l_resource_id;
    l_res_txn_dtls_tbl(1).organization_id       := nvl(l_existing_res_txn.organization_id, fnd_profile.value('CSD_DEF_REP_INV_ORG'));
    l_res_txn_dtls_tbl(1).object_version_number := nvl(l_existing_res_txn.object_version_number, 1);
    l_res_txn_dtls_tbl(1).new_row               := nvl(l_existing_res_txn.new_row, 'Y');

    -- save the new/updated resource
    if (l_res_txn_dtls_tbl(1).new_row  = 'Y') then
        PROCESS_SAVE_RES_TXN_DTLS
        (
            p_api_version_number => p_api_version_number,
            p_init_msg_list      => p_init_msg_list,
            p_commit             => p_commit,
            p_validation_level   => p_validation_level,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_res_txn_dtls_tbl   => l_res_txn_dtls_tbl
        );
        -- afer saving, requery to get latest info to transact,
        -- including wip_transaction_detail_id, object_version_number
        open get_resource_info (l_wip_entity_id, l_operation_seq_num, l_resource_id);
        fetch get_resource_info
        into    l_res_txn_dtls_tbl(1).wip_transaction_detail_id,
                l_res_txn_dtls_tbl(1).resource_id,
                l_res_txn_dtls_tbl(1).resource_seq_num,
                l_res_txn_dtls_tbl(1).wip_entity_id,
                l_res_txn_dtls_tbl(1).wip_entity_name,
                l_res_txn_dtls_tbl(1).organization_id,
                l_res_txn_dtls_tbl(1).organization_code,
                l_res_txn_dtls_tbl(1).operation_seq_num,
                l_res_txn_dtls_tbl(1).job_quantity,
                l_res_txn_dtls_tbl(1).required_quantity,
                l_res_txn_dtls_tbl(1).op_scheduled_quantity,
                l_res_txn_dtls_tbl(1).applied_quantity,
                l_res_txn_dtls_tbl(1).transaction_quantity,
                l_res_txn_dtls_tbl(1).transaction_uom,
                l_res_txn_dtls_tbl(1).uom_code,
                l_res_txn_dtls_tbl(1).employee_id,
                l_res_txn_dtls_tbl(1).employee_num,
                l_res_txn_dtls_tbl(1).basis_type,
                l_res_txn_dtls_tbl(1).object_version_number,
                l_res_txn_dtls_tbl(1).new_row;
        close get_resource_info;
    else
        -- if transacting an existing resource, populate additional fields
        -- pass null for wip_transaction_detail_id because we do not want to
        -- transact the existing record
        l_res_txn_dtls_tbl(1).wip_transaction_detail_id  := null;
        l_res_txn_dtls_tbl(1).resource_seq_num      := l_existing_res_txn.resource_seq_num;
        l_res_txn_dtls_tbl(1).uom_code              := nvl(l_existing_res_txn.transaction_uom,'DAY');
        l_res_txn_dtls_tbl(1).organization_code     := l_existing_res_txn.organization_code;
        l_res_txn_dtls_tbl(1).wip_entity_name       := l_existing_res_txn.wip_entity_name;
        l_res_txn_dtls_tbl(1).job_quantity          := l_existing_res_txn.job_quantity;
        l_res_txn_dtls_tbl(1).required_quantity     := l_existing_res_txn.required_quantity;
        l_res_txn_dtls_tbl(1).op_scheduled_quantity := l_existing_res_txn.op_scheduled_quantity;
        l_res_txn_dtls_tbl(1).applied_quantity      := l_existing_res_txn.applied_quantity;
        l_res_txn_dtls_tbl(1).basis_type            := l_existing_res_txn.basis_type;
        -- employee could be different from the one that was saved, so query it separately
        open get_employee_num (l_res_txn_dtls_tbl(1).organization_id, l_res_txn_dtls_tbl(1).employee_id);
        fetch get_employee_num
        into l_res_txn_dtls_tbl(1).employee_num;
        close get_employee_num;
    end if;

    -- now, transact the resource
    process_transact_res_txn
    (
        p_api_version_number => p_api_version_number,
        p_init_msg_list      => p_init_msg_list,
        p_commit             => p_commit,
        p_validation_level   => p_validation_level,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_res_txn_dtls_tbl   => l_res_txn_dtls_tbl
    );

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_TIME_CLOCK_RES_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_TIME_CLOCK_RES_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_TIME_CLOCK_RES_TXN_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;
END process_time_clock_res_txn;

PROCEDURE process_comp_work_ro_status
(
    p_api_version_number                  IN         NUMBER,
    p_init_msg_list                       IN         VARCHAR2,
    p_commit                              IN         VARCHAR2,
    p_validation_level                    IN         NUMBER,
    x_return_status                       OUT NOCOPY VARCHAR2,
    x_msg_count                           OUT NOCOPY NUMBER,
    x_msg_data                            OUT NOCOPY VARCHAR2,
    p_repair_line_id                      IN         NUMBER,
    x_new_flow_status_code                OUT NOCOPY VARCHAR2,
    x_new_ro_status_code                  OUT NOCOPY VARCHAR2
) IS
    -- constants used for FND_LOG debug messages
    lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_COMP_WORK_RO_STATUS';
    lc_api_version_number      CONSTANT NUMBER := 1.0;
    lc_mod_name                      VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_comp_work_ro_status';

    cursor c_get_repair_info is
    select repair_type_id, flow_status_id, object_version_number
    from csd_repairs
    where repair_line_id = p_repair_line_id;

    cursor c_get_to_flow_status_id is
    select flow_status_id
    from csd_flow_statuses_b
    where flow_status_code = fnd_profile.value('CSD_COMPLETE_WORK_RO_STATUS');

    cursor c_get_repair_status is
    select flb.flow_status_code, dra.status
    from csd_repairs dra, csd_flow_statuses_b flb
    where dra.repair_line_id = p_repair_line_id
    and dra.flow_status_id = flb.flow_status_id;

    --
    l_repair_type_id NUMBER;
    l_obj_ver_num NUMBER;
    lx_obj_ver_num NUMBER;
    l_fm_flow_status_id NUMBER;
    l_to_flow_status_id NUMBER;

BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
              lc_mod_name||'begin',
              'Entering private API process_comp_work_ro_status' );
    END IF;

    SAVEPOINT PROCESS_COMP_WORK_RO_STATUS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (lc_api_version_number,
                                        p_api_version_number,
                                        lc_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- get the repair order info in order to update flow status
    open c_get_repair_info;
    fetch c_get_repair_info
    into  l_repair_type_id, l_fm_flow_status_id, l_obj_ver_num;
    close c_get_repair_info;

    -- get the flow status id to change to, from profile option
    open c_get_to_flow_status_id;
    fetch c_get_to_flow_status_id
    into  l_to_flow_status_id;
    close c_get_to_flow_status_id;


    csd_repairs_pvt.update_flow_status
    (
        p_api_version           => p_api_version_number,
        p_commit                => p_commit,
        p_init_msg_list         => p_init_msg_list,
        p_validation_level      => p_validation_level,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_repair_line_id        => p_repair_line_id,
        p_repair_type_id        => l_repair_type_id,
        p_from_flow_status_id   => l_fm_flow_status_id,
        p_to_flow_status_id     => l_to_flow_status_id,
        p_reason_code           => null,
        p_comments              => null,
        p_check_access_flag     => 'Y',
        p_object_version_number => l_obj_ver_num,
        x_object_version_number => lx_obj_ver_num
    );

    -- requery for the new flow status
    open c_get_repair_status;
    fetch c_get_repair_status
    into  x_new_flow_status_code, x_new_ro_status_code;
    close c_get_repair_status;

-- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_COMP_WORK_RO_STATUS ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_COMP_WORK_RO_STATUS ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_COMP_WORK_RO_STATUS ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;
END process_comp_work_ro_status;

/**
 * swai: 12.1.3
 * Deletes a saved material requirement that has not been transacted yet.
 * The following fields in p_mtl_txn_dtls are expected to be filled out:
 *    wip_entity_id
 *    organization_id
 *    inventory_item_id
 *    operation_seq_num
 *    wip_transaction_detail_id (optional)
 */
PROCEDURE process_delete_mtl_txn_dtl
(
    p_api_version_number                      IN           NUMBER,
    p_init_msg_list                           IN           VARCHAR2 ,
    p_commit                                  IN           VARCHAR2 ,
    p_validation_level                        IN           NUMBER ,
    x_return_status                           OUT  NOCOPY  VARCHAR2,
    x_msg_count                               OUT  NOCOPY  NUMBER,
    x_msg_data                                OUT  NOCOPY  VARCHAR2,
    p_mtl_txn_dtls                            IN           MTL_TXN_DTLS_REC_TYPE
)
IS
      lc_api_name                CONSTANT VARCHAR2(30) := 'PROCESS_DELETE_MTL_TXN_DTL';
      lc_api_version_number      CONSTANT NUMBER := 1.0;

      -- constants used for FND_LOG debug messages
      lc_mod_name                 CONSTANT VARCHAR2(2000) := 'csd.plsql.csd_hv_wip_job_pvt.process_delete_mtl_txn_dtl';

      -- Constants Used for Inserting into wip_job_schedule_interface,
      -- These are the values needed for WIP Mass Load to pick up the records

      -- Constants for WIP_JOB_SCHEDULE_INTERFACE table
      lc_non_std_update_load_type      CONSTANT NUMBER := 3; -- update non-standard job

      -- Constants for WIP_JOB_DTLS_INTERFACE table
      lc_load_mtl_type  CONSTANT             NUMBER  := 2; -- material
      lc_substitution_del_type CONSTANT      NUMBER  := 1; -- delete


      -- Job Records to hold the Job header and details information
      l_job_header_rec            wip_job_schedule_interface%ROWTYPE;
      l_job_details_rec           wip_job_dtls_interface%ROWTYPE;

      -- wip
      l_wip_transaction_detail_id NUMBER := NULL;

      cursor c_get_wip_txn_detail_id is
          select wip_transaction_detail_id
          from csd_wip_transaction_details
          where wip_entity_id = p_mtl_txn_dtls.wip_entity_id
          and inventory_item_id = p_mtl_txn_dtls.inventory_item_id
          and operation_seq_num = p_mtl_txn_dtls.operation_seq_num;

BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering private API process_delete_mtl_txn_dtl' );
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT PROCESS_DELETE_MTL_TXN_DTL_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
           (lc_api_version_number,
            p_api_version_number,
            lc_api_name,
            G_PKG_NAME)
      THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;


      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- populate l_job_header_rec values
      --
      SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_job_header_rec.group_id FROM dual;
      l_job_header_rec.load_type := lc_non_std_update_load_type;
      l_job_header_rec.header_id := l_job_header_rec.group_id;
      l_job_header_rec.wip_entity_id := p_mtl_txn_dtls.wip_entity_id;
      l_job_header_rec.organization_id   := p_mtl_txn_dtls.organization_id;

      --
      -- populate l_job_details_rec values
      --
      l_job_details_rec.load_type := lc_load_mtl_type;
      l_job_details_rec.substitution_type := lc_substitution_del_type;
      l_job_details_rec.group_id         := l_job_header_rec.group_id;
      l_job_details_rec.parent_header_id := l_job_header_rec.group_id;

      l_job_details_rec.wip_entity_id     := p_mtl_txn_dtls.wip_entity_id;
      l_job_details_rec.inventory_item_id_old := p_mtl_txn_dtls.inventory_item_id;
      l_job_details_rec.operation_seq_num := p_mtl_txn_dtls.operation_seq_num;

      -- Call procedures to insert job header and job details information
      -- into wip interface tables
      IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
            lc_mod_name||'beforecallinsertjob',
            'Just before calling insert_job_header');
      END IF;


      insert_job_header( p_job_header_rec  =>    l_job_header_rec,
                         x_return_status   =>    x_return_status );


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
            lc_mod_name||'beforecallinsertjobdtls',
            'Just before calling insert_job_details');
      END IF;


      insert_job_details( p_job_details_rec  =>    l_job_details_rec,
                          x_return_status    =>    x_return_status );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



      -- Call WIP Mass Load API

      IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
            lc_mod_name||'beforecallwipmassload',
            'Just before calling WIP_MASSLOAD_PUB.massLoadJobs');
      END IF;

      BEGIN
        WIP_MASSLOAD_PUB.massLoadJobs(p_groupID   => l_job_header_rec.group_id,
             p_validationLevel       => p_validation_level,
             p_commitFlag            => 0, -- do not commit right away
             x_returnStatus          => x_return_status,
             x_errorMsg              => x_msg_data );

        If ( ml_error_exists( l_job_header_rec.group_id )  or
            x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

               FND_MESSAGE.SET_NAME('CSD','CSD_MTL_ADD_MASS_LD_FAILURE');
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_ERROR;

               FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                          p_count  => x_msg_count,
                                          p_data   => x_msg_data);
               -- Need to rollback  Raise exception -
               -- once commit is removed from above call
               -- raise FND_API.G_EXC_ERROR;
               RETURN;
        end if;

      EXCEPTION
          WHEN OTHERS THEN
             add_wip_interface_errors(l_job_header_rec.group_id,
                                      2 /* 2 = materials */);

             -- when rollback for WIP works, remove x_return_status, count_and_get,
             -- and return then reinstate raise exception above
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             /*
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                -- Add Unexpected Error to Message List, here SQLERRM is used for
                -- getting the error

                FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => lc_api_name );
             END IF;
             */
             FND_MSG_PUB.count_and_get( p_encoded   => FND_API.G_FALSE,
                                        p_count  => x_msg_count,
                                        p_data   => x_msg_data);

      END;
      If p_mtl_txn_dtls.WIP_TRANSACTION_DETAIL_ID is null then
        -- query for wip_transaction_detail_id based on other fields
        open c_get_wip_txn_detail_id;
        fetch c_get_wip_txn_detail_id
        into l_wip_transaction_detail_id;
        close c_get_wip_txn_detail_id;
      else
        l_wip_transaction_detail_id := p_mtl_txn_dtls.WIP_TRANSACTION_DETAIL_ID;
      end if;

      If l_wip_transaction_detail_id is not null then
            IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
                lc_mod_name||'beforecallinsertrow',
                'Just before calling CSD_WIP_TRANSACTION_DTLS_PKG.Insert_Row');
            END IF;

            CSD_WIP_TRANSACTION_DTLS_PKG.Delete_Row(
                p_WIP_TRANSACTION_DETAIL_ID  => l_WIP_TRANSACTION_DETAIL_ID);

      end if;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
            COMMIT WORK;
      END IF;

EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
         ROLLBACK to PROCESS_DELETE_MTL_TXN_DTL_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'unx_exception',
                        'G_EXC_UNEXPECTED_ERROR Exception');
         END IF;


      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK to PROCESS_DELETE_MTL_TXN_DTL_PVT ;
         x_return_status := FND_API.G_RET_STS_ERROR;


         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_ERROR,
                        lc_mod_name||'exc_exception',
                        'G_EXC_ERROR Exception');
         END IF;

      WHEN OTHERS THEN
         ROLLBACK to PROCESS_DELETE_MTL_TXN_DTL_PVT ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         -- Add Unexpected Error to Message List, here SQLERRM is used for
         -- getting the error

               FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                    p_procedure_name => lc_api_name );
         END IF;

         FND_MSG_PUB.count_and_get(    p_encoded   => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data);

         IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(   FND_LOG.LEVEL_EXCEPTION,
                        lc_mod_name||'others_exception',
                        'OTHERS Exception');
         END IF;

END PROCESS_DELETE_MTL_TXN_DTL;

END CSD_HV_WIP_JOB_PVT;

/
