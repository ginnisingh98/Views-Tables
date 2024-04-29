--------------------------------------------------------
--  DDL for Package Body WIP_EAM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EAM_UTILS" as
/* $Header: wipeamub.pls 120.2 2005/09/06 16:35:44 anjgupta ship $ */

--------------------------------------------------------------------------
-- HISTORY:                                                             --
-- 04/25/05   Anju Gupta  : IB Convergence   Transactable Asset Changes --
--                          Refer to TDD for Detailed Design            --
--------------------------------------------------------------------------

  -- Procedure to find the default wip accounting class for a work order
  -- based on pre-defined criteria
  PROCEDURE DEFAULT_ACC_CLASS(
    p_org_id          IN  NUMBER,   -- Organization Id
    p_job_type        IN  NUMBER,   -- Standard/Rebuild
    p_serial_number   IN  VARCHAR2, -- Asset Number
    p_asset_group     IN  VARCHAR2, -- Asset Group
    p_parent_wo_name  IN  VARCHAR2, -- Parent Wip Entity Id
    p_asset_activity  IN  VARCHAR2, -- Asset Activity
    p_project_number  IN  VARCHAR2, -- Project Number
    p_task_number     IN  VARCHAR2, -- Task Number
    x_class_code      OUT NOCOPY VARCHAR2, -- WAC (return value)
    x_return_status   OUT NOCOPY VARCHAR2, -- Return Status
    x_msg_data        OUT NOCOPY VARCHAR2  -- Error messages
  )
  IS
    --Declare variables
    l_inv_item_id        NUMBER       := NULL;
    l_parent_weid        NUMBER       := NULL;
    l_project_id         NUMBER       := NULL;
    l_task_id            NUMBER       := NULL;
    l_asset_activity_id  NUMBER       := NULL;
    l_count              NUMBER       := 0;
    l_prj_class_code     VARCHAR2(10) := '';
    l_instance_id        NUMBER       := NULL;
    l_maintenance_object_type NUMBER :=0;

  BEGIN

    SAVEPOINT DEFAULT_WAC_START;

    x_return_status := 'S';

    -- Cases
    -- 1. Maintenance Work Order with Project/Task
    -- 2. Maintenance Work Order with no Project/Task
    --   2.1 Default from asset activity association
    --   2.2 Default from asset definition
    --   2.3 Default from EAM Parameters
    -- 3. Rebuild WO with a parent.
    -- 4. Rebuild WO without a parent but with Project/Task
    -- 5. Rebuild WO without a parent with no Project/Task
    --   5.1 Default from Rebuild Activity combination
    --   5.2 Default from EAM Parameters



    -- Get some of the commonly used variables for later use.
    -- Essentially involves getting the id from the names
    -- 1. Asset Group Id

    if p_asset_group is not null then
    /* IB Convergence changes */
      select inventory_item_id into l_inv_item_id
       from mtl_system_items_b_kfv msi, mtl_parameters mp
        where msi.concatenated_segments = p_asset_group
        and msi.organization_id = mp.organization_id
        and mp.maint_organization_id = p_org_id
        and rownum = 1;

            --1.1 Derive Instance_id
            if p_serial_number is not null then
            select cii.instance_id
            into l_instance_id
            from csi_item_instances cii
            where cii.inventory_item_id = l_inv_item_id
            and cii.serial_number = p_serial_number;

            l_maintenance_object_type := 3;

            else
            l_maintenance_object_type := 2;
            l_instance_id := l_inv_item_id;

            end if;

             --1.2

	end if;



    -- 2. Parent Wip Entity Id
    if p_parent_wo_name is not null then
      select wip_entity_id into l_parent_weid from wip_entities
        where wip_entity_name = p_parent_wo_name
        and organization_id = p_org_id;
    end if;
    -- 3. Asset Activity Id
    -- Activity should always be assigned to the work order organization
    if p_asset_activity is not null then
      select inventory_item_id into l_asset_activity_id from
        mtl_system_items_b_kfv where
        concatenated_segments = p_asset_activity
        and organization_id = p_org_id;
    end if;

    -- 4. Project Id
    if p_project_number is not null then
      select ppv.project_id into l_project_id
        from pjm_projects_v ppv,
        pjm_project_parameters ppp
        where ppv.project_id = ppp.project_id
        and ppp.organization_id = p_org_id
        and ppv.project_number = p_project_number;
    end if;
    -- 5. Task Id
    if p_project_number is not null and p_task_number is not null then
      select ppv.project_id, mtv.task_id into
        l_project_id, l_task_id
        from  pjm_projects_v ppv,
        pjm_project_parameters ppp,
        mtl_task_v mtv
        where  ppv.project_id = ppp.project_id
        and mtv.project_id(+) = ppp.project_id
        and ppp.organization_id = p_org_id
        and ppv.project_number = p_project_number
        and task_number = p_task_number;
    end if;

    -- If WO is a maintenance work order.
    if p_job_type = 1 then

       -- Case 1. Maintenance Work Order with Project/Task
      if p_project_number is not null then

        -- Call the Projects Team's API to return the WAC for the project/task given
        l_prj_class_code := PJM_UTILS.DEFAULT_WIP_ACCT_CLASS(
                              X_INVENTORY_ORG_ID  => p_org_id,
                              X_PROJECT_ID        => l_project_id,
                              X_TASK_ID           => l_task_id,
                              X_CLASS_TYPE        => 6);

        if l_prj_class_code is not null then
          x_class_code := l_prj_class_code;
          return;
        end if;
      end if;

      -- 2. Maintenance Work Order with no Project/Task; Or if the Project didn't
      --    have an associated WAC

      --   Case 2.1 From asset activity association
      if p_asset_activity is not null then

          select count(*)
          into l_count from mtl_eam_asset_activities meaa, eam_org_maint_defaults eomd
          where meaa.asset_activity_id = l_asset_activity_id
          and meaa.maintenance_object_type = 3
          and meaa.maintenance_object_id = l_instance_id
          and eomd.organization_id = p_org_id
          and meaa.activity_association_id = eomd.object_id
          and eomd.object_type = 60
          and eomd.accounting_class_code is not null
          and nvl(meaa.tmpl_flag, 'N') = 'N';

        if l_count = 1 then
          select accounting_class_code into x_class_code from mtl_eam_asset_activities meaa, eam_org_maint_defaults eomd
           where meaa.asset_activity_id = l_asset_activity_id
          and meaa.maintenance_object_type = 3
          and meaa.maintenance_object_id = l_instance_id
          and eomd.organization_id = p_org_id
          and meaa.activity_association_id = eomd.object_id
          and eomd.object_type = 60
          and nvl(meaa.tmpl_flag, 'N') = 'N';
          return;
        end if;
      end if;

      --   2.2 From asset definition

        select count(*)
        into l_count
        from eam_org_maint_defaults eomd
        where eomd.organization_id = p_org_id
        and eomd.object_type = 50
        and eomd.object_id = l_instance_id
        and eomd.accounting_class_code is not null;
      if l_count = 1 then
        select accounting_class_code into x_class_code from eam_org_maint_defaults eomd
        where eomd.organization_id = p_org_id
        and eomd.object_type = 50
        and eomd.object_id = l_instance_id;
        return;
      end if;

      --   2.3 From EAM Parameters
      select default_eam_class into x_class_code
        from wip_eam_parameters where
        organization_id = p_org_id;
      return;

    -- Rebuild Work Orders
    elsif p_job_type = 2 then

      -- Case 3. Rebuild WO with a parent.
      if l_parent_weid is not null then
        select  class_code into x_class_code from
          wip_discrete_jobs where
          wip_entity_id = l_parent_weid
          and organization_id = p_org_id;
        return;

      -- 4. Rebuild WO without a parent but with Project/Task
      elsif (l_parent_weid is null and p_project_number is not null )then

        -- Call the Projects Team's API to return the WAC for the project/task given
        l_prj_class_code := PJM_UTILS.DEFAULT_WIP_ACCT_CLASS(
                              X_INVENTORY_ORG_ID  => p_org_id,
                              X_PROJECT_ID        => l_project_id,
                              X_TASK_ID           => l_task_id,
                              X_CLASS_TYPE        => 6);
        if l_prj_class_code is not null then
          x_class_code := l_prj_class_code;
          return;
        end if;

      end if;

      -- 5. Rebuild WO without a parent and with no Project/Task; Or if the
      --    project did not have an associated WAC

      if p_asset_activity is not null then
        --   5.1 Default from Rebuild Activity combination


          select count(*)
          into l_count from mtl_eam_asset_activities meaa, eam_org_maint_defaults eomd
          where meaa.asset_activity_id = l_asset_activity_id
          and meaa.maintenance_object_type = l_maintenance_object_type
          and meaa.maintenance_object_id = l_instance_id
          and eomd.organization_id = p_org_id
          and meaa.activity_association_id = eomd.object_id
          and eomd.object_type = decode(l_maintenance_object_type, 3, 60, 2, 40 )
          and nvl(meaa.tmpl_flag, 'N') = 'N'
          and eomd.accounting_class_code is not null;

          if l_count = 1 then
           select accounting_class_code into x_class_code
		   from mtl_eam_asset_activities meaa, eam_org_maint_defaults eomd
          where meaa.asset_activity_id = l_asset_activity_id
          and meaa.maintenance_object_type = l_maintenance_object_type
          and meaa.maintenance_object_id = l_instance_id
          and eomd.organization_id = p_org_id
          and nvl(meaa.tmpl_flag, 'N') = 'N'
          and meaa.activity_association_id = eomd.object_id
          and eomd.object_type = decode(l_maintenance_object_type, 3, 60, 2, 40
);
            return;
          end if;

      -- Get it from the rebuild item definition
      else
        --   Serial controlled rebuild
        if p_serial_number is not null then

        select count(*)
        into l_count
        from eam_org_maint_defaults eomd
        where eomd.organization_id = p_org_id
        and eomd.object_type = 50
        and eomd.object_id = l_instance_id
        and eomd.accounting_class_code is not null;

          if l_count = 1 then
                select accounting_class_code into x_class_code from eam_org_maint_defaults eomd
                where eomd.organization_id = p_org_id
                and eomd.object_type = 50
                and eomd.object_id = l_instance_id;
            return;
          end if;
        --  Non serial controlled
        else

        -- Default it from Eam Parameters
        select default_eam_class into x_class_code
          from wip_eam_parameters where
          organization_id = p_org_id;
        return;

        end if;

      end if;

	  end if;

    -- In case no other case has returned a WAC, then default it from
    -- the eam parameters.
    select default_eam_class into x_class_code
      from wip_eam_parameters where
      organization_id = p_org_id;
    return;

  EXCEPTION

    when others then
      rollback to DEFAULT_WAC_START;
      x_msg_data := SQLERRM;
      x_return_status := 'E';
      -- Default it from eam parameters.
      select default_eam_class into x_class_code
        from wip_eam_parameters where
        organization_id = p_org_id;

  END DEFAULT_ACC_CLASS;




  -- This is a copy of the previous DEFAULT_ACC_CLASS procedure. The only
  -- difference is that this procedure takes 'id's as input instead of names.
  -- Procedure to find the default wip accounting class for a work order
  -- based on pre-defined criteria
  PROCEDURE DEFAULT_ACC_CLASS(
    p_org_id          IN  NUMBER,   -- Organization Id
    p_job_type        IN  NUMBER,   -- Standard/Rebuild
    p_serial_number   IN  VARCHAR2, -- Asset Number
    p_asset_group_id  IN  NUMBER, -- Asset Group
    p_parent_wo_id    IN  NUMBER, -- Parent Wip Entity Id
    p_asset_activity_id IN  NUMBER, -- Asset Activity
    p_project_id      IN  NUMBER, -- Project Number
    p_task_id         IN  NUMBER, -- Task Number
    x_class_code      OUT NOCOPY VARCHAR2, -- WAC (return value)
    x_return_status   OUT NOCOPY VARCHAR2, -- Return Status
    x_msg_data        OUT NOCOPY VARCHAR2  -- Error messages
  )
  IS
    --Declare variables
    l_inv_item_id        NUMBER       := p_asset_group_id;--NULL;
    l_parent_weid        NUMBER       := p_parent_wo_id;--NULL;
    l_project_id         NUMBER       := p_project_id;--NULL;
    l_task_id            NUMBER       := p_task_id;--NULL;
    l_asset_activity_id  NUMBER       := p_asset_activity_id;--NULL;
    l_count              NUMBER       := 0;
    l_instance_id        NUMBER       := NULL;
    l_prj_class_code     VARCHAR2(10) := '';

    l_maintenance_object_type NUMBER :=0;
  BEGIN

    SAVEPOINT DEFAULT_WAC_START;

    x_return_status := 'S';

    -- Cases
    -- 1. Maintenance Work Order with Project/Task
    -- 2. Maintenance Work Order with no Project/Task
    --   2.1 Default from asset activity association
    --   2.2 Default from asset definition
    --   2.3 Default from EAM Parameters
    -- 3. Rebuild WO with a parent.
    -- 4. Rebuild WO without a parent but with Project/Task
    -- 5. Rebuild WO without a parent with no Project/Task
    --   5.1 Default from Rebuild Activity combination
    --   5.2 Default from EAM Parameters


        --1 Derive Instance_id
            if p_serial_number is not null then
            select cii.instance_id
            into l_instance_id
            from csi_item_instances cii
            where cii.inventory_item_id = p_asset_group_id
            and cii.serial_number = p_serial_number;

             l_maintenance_object_type := 3;

            else
            l_maintenance_object_type := 2;
            l_instance_id := p_asset_group_id;
            end if;

    -- If WO is a maintenance work order.
    if p_job_type = 1 then

       -- Case 1. Maintenance Work Order with Project/Task
      if p_project_id is not null then

        -- Call the Projects Team's API to return the WAC for the project/task given
        l_prj_class_code := PJM_UTILS.DEFAULT_WIP_ACCT_CLASS(
                              X_INVENTORY_ORG_ID  => p_org_id,
                              X_PROJECT_ID        => l_project_id,
                              X_TASK_ID           => l_task_id,
                              X_CLASS_TYPE        => 6);

        if l_prj_class_code is not null then
          x_class_code := l_prj_class_code;
          return;
        end if;
      end if;

      -- 2. Maintenance Work Order with no Project/Task; Or if the Project didn't
      --    have an associated WAC

      --   Case 2.1 From asset activity association
      if p_asset_activity_id is not null then


          select count(*)
          into l_count from mtl_eam_asset_activities meaa, eam_org_maint_defaults eomd
          where meaa.asset_activity_id = l_asset_activity_id
          and meaa.maintenance_object_type = 3
          and meaa.maintenance_object_id = l_instance_id
          and nvl(meaa.tmpl_flag, 'N') = 'N'
          and eomd.organization_id = p_org_id
          and meaa.activity_association_id = eomd.object_id
          and eomd.object_type = 60
          and eomd.accounting_class_code is not null ;

        if l_count = 1 then
           select accounting_class_code into x_class_code
		   from mtl_eam_asset_activities meaa, eam_org_maint_defaults eomd
           where meaa.asset_activity_id = l_asset_activity_id
           and meaa.maintenance_object_type = 3
           and meaa.maintenance_object_id = l_instance_id
           and nvl(meaa.tmpl_flag, 'N') = 'N'
           and eomd.organization_id = p_org_id
           and meaa.activity_association_id = eomd.object_id
           and eomd.object_type = 60;
          return;
        end if;
      end if;

      --   2.2 From asset definition

        select count(*)
        into l_count
        from eam_org_maint_defaults eomd
        where eomd.organization_id = p_org_id
        and eomd.object_type = 50
        and eomd.object_id = l_instance_id
        and eomd.accounting_class_code is not null;

      if l_count = 1 then
        select accounting_class_code into x_class_code from eam_org_maint_defaults eomd
                where eomd.organization_id = p_org_id
                and eomd.object_type = 50
                and eomd.object_id = l_instance_id;
        return;
      end if;

      --   2.3 From EAM Parameters
      select default_eam_class into x_class_code
        from wip_eam_parameters where
        organization_id = p_org_id;
      return;

    -- Rebuild Work Orders
    elsif p_job_type = 2 then

      -- Case 3. Rebuild WO with a parent.
      if l_parent_weid is not null then
        select  class_code into x_class_code from
          wip_discrete_jobs where
          wip_entity_id = l_parent_weid
          and organization_id = p_org_id;
        return;

      -- 4. Rebuild WO without a parent but with Project/Task
      elsif l_parent_weid is null and p_project_id is not null then

        -- Call the Projects Team's API to return the WAC for the project/task given
        l_prj_class_code := PJM_UTILS.DEFAULT_WIP_ACCT_CLASS(
                              X_INVENTORY_ORG_ID  => p_org_id,
                              X_PROJECT_ID        => l_project_id,
                              X_TASK_ID           => l_task_id,
                              X_CLASS_TYPE        => 6);
        if l_prj_class_code is not null then
          x_class_code := l_prj_class_code;
          return;
        end if;

      end if;

      -- 5. Rebuild WO without a parent and with no Project/Task; Or if the
      --    project did not have an associated WAC

      if p_asset_activity_id is not null then
        --   5.1 Default from Rebuild Activity combination



         select count(*)
          into l_count from mtl_eam_asset_activities meaa, eam_org_maint_defaults eomd
          where meaa.asset_activity_id = l_asset_activity_id
          and meaa.maintenance_object_type = l_maintenance_object_type
          and meaa.maintenance_object_id = l_instance_id
          and eomd.organization_id = p_org_id
          and meaa.activity_association_id = eomd.object_id
          and eomd.object_type in (40, 60)
          and nvl(meaa.tmpl_flag, 'N') = 'N'
          and eomd.accounting_class_code is not null ;

         if l_count = 1 then
            select accounting_class_code into x_class_code from mtl_eam_asset_activities meaa, eam_org_maint_defaults eomd
          where meaa.asset_activity_id = l_asset_activity_id
          and meaa.maintenance_object_type = l_maintenance_object_type
          and meaa.maintenance_object_id = l_instance_id
          and nvl(meaa.tmpl_flag, 'N') = 'N'
          and eomd.organization_id = p_org_id
          and meaa.activity_association_id = eomd.object_id
          and eomd.object_type in (40, 60);
            return;
          end if;

      -- Get it from the rebuild item definition
      else
        --   Serial controlled rebuild
        if p_serial_number is not null then

        select count(*)
        into l_count
        from eam_org_maint_defaults eomd
        where eomd.organization_id = p_org_id
        and eomd.object_type = 50
        and eomd.object_id = l_instance_id
        and eomd.accounting_class_code is not null;
         if l_count = 1 then
                select accounting_class_code into x_class_code from eam_org_maint_defaults eomd
                where eomd.organization_id = p_org_id
                and eomd.object_type = 50
                and eomd.object_id = l_instance_id;
            return;
          end if;
        --  Non serial controlled
        else

        -- Default it from Eam Parameters
        select default_eam_class into x_class_code
          from wip_eam_parameters where
          organization_id = p_org_id;
        return;

        end if;

      end if;

    end if;

    -- In case no other case has returned a WAC, then default it from
    -- the eam parameters.
    select default_eam_class into x_class_code
      from wip_eam_parameters where
      organization_id = p_org_id;
    return;

  EXCEPTION

    when others then
      rollback to DEFAULT_WAC_START;
      x_msg_data := SQLERRM;
      x_return_status := 'E';
      -- Default it from eam parameters.
      select default_eam_class into x_class_code
        from wip_eam_parameters where
        organization_id = p_org_id;

  END DEFAULT_ACC_CLASS;


  -- This procedure copies over the asset attachments,
  -- asset activity attachments, activity bom attachments
  -- and activity routing attachments to the work order
  -- created by the WIP Mass Load.
  PROCEDURE copy_attachments(
    copy_asset_attachments         IN VARCHAR2, -- Copy Asset Attachments (Y/N).
    copy_activity_attachments      IN VARCHAR2, -- Copy Activity Attachments (Y/N).
    copy_activity_bom_attachments  IN VARCHAR2, -- Copy Activity BOM Attachments (Y/N).
    copy_activity_rtng_attachments IN VARCHAR2, -- Copy Activity Routing Attachments (Y/N).
    p_organization_id              IN NUMBER,   -- Org Id of the Work Order
    p_wip_entity_id                IN NUMBER,   -- Wip Ent Id of WO (created thru WML).
    p_primary_item_id              IN NUMBER,   -- Asset Activity Id of the activity.
    p_common_bom_sequence_id       IN NUMBER,   -- BOM Sequence Id for the activity
    p_common_routing_sequence_id   IN NUMBER    -- Routing Sequence Id for the Activity
  ) IS

    l_operation_sequence_id       NUMBER;
    l_operation_sequence_number   NUMBER;
    l_asset_number                VARCHAR2(30);
    l_inv_item_id                 NUMBER;

   -- baroy - instead of the ref cursor, use collections for bulk binding.
   -- TYPE CUR_TYP is ref cursor;
   -- c_op_cur                      CUR_TYP;
   TYPE op_rec_type is record (operation_sequence_id bom_operation_sequences.operation_sequence_id%type,
     operation_seq_num bom_operation_sequences.operation_seq_num%type);

   op_rec op_rec_type;
   cursor op_table is select operation_sequence_id, operation_seq_num
     from bom_operation_sequences
     where routing_sequence_id = p_common_routing_sequence_id ;

  begin

    -- Standard Start of API savepoint
    -- l_stmt_num    := 10;
    SAVEPOINT copy_attachments_pvt;

    -- Copy Asset Attachments

    if (copy_asset_attachments = 'Y') then

    begin

      select nvl(asset_number,rebuild_serial_number), nvl(asset_group_id,rebuild_item_id)
             into l_asset_number, l_inv_item_id
             from wip_discrete_jobs
             where wip_entity_id = p_wip_entity_id
             and organization_id = p_organization_id;



      if (p_wip_entity_id is not null  and l_asset_number is not
                  null and l_inv_item_id is not null ) then

            fnd_attached_documents2_pkg.copy_attachments(
                X_from_entity_name      =>  'MTL_SERIAL_NUMBERS',
                X_from_pk1_value        =>  to_char(p_organization_id),
                X_from_pk2_value        =>  to_char(l_inv_item_id),
                X_from_pk3_value        =>  l_asset_number,
                X_from_pk4_value        =>  '',
                X_from_pk5_value        =>  '',
                X_to_entity_name        =>  'EAM_WORK_ORDERS',
                X_to_pk1_value          =>  to_char(p_organization_id),
                X_to_pk2_value          =>  to_char(p_wip_entity_id),
                X_to_pk3_value          =>  '',
                X_to_pk4_value          =>  '',
                X_to_pk5_value          =>  '',
                X_created_by            =>  fnd_global.user_id,
                X_last_update_login     =>  fnd_global.login_id
                -- X_program_application_id=>  '',
                -- X_program_id            =>  '',
                -- X_request_id            =>  ''
             );

      end if;  -- end of check for p_wip_entity_id and l_asset_number

    end;

    end if ; -- End of Copy Asset Attachments

    -- Copy Activity Attachments
    if (copy_activity_attachments = 'Y') then

      if p_primary_item_id is not null then

              fnd_attached_documents2_pkg.copy_attachments(
                X_from_entity_name      =>  'MTL_SYSTEM_ITEMS',
                X_from_pk1_value        =>  to_char(p_organization_id),
                X_from_pk2_value        =>  to_char(p_primary_item_id),
                X_from_pk3_value        =>  '',
                X_from_pk4_value        =>  '',
                X_from_pk5_value        =>  '',
                X_to_entity_name        =>  'EAM_WORK_ORDERS',
                X_to_pk1_value          =>  to_char(p_organization_id),
                X_to_pk2_value          =>  to_char(p_wip_entity_id),
                X_to_pk3_value          =>  '',
                X_to_pk4_value          =>  '',
                X_to_pk5_value          =>  '',
                X_created_by            =>  fnd_global.user_id,
                X_last_update_login     =>  fnd_global.login_id
                -- X_program_application_id=>  '',
                -- X_program_id            =>  '',
                -- X_request_id            =>  ''
                 );

      end if;

    end if; -- End of Copy Activity Attachments

    -- Copy Attachments from Activity BOM

    if (copy_activity_bom_attachments = 'Y') then

            if p_common_bom_sequence_id is not null then

               fnd_attached_documents2_pkg.copy_attachments(
                X_from_entity_name      =>  'BOM_BILL_OF_MATERIALS',
                X_from_pk1_value        =>  to_char(p_common_bom_sequence_id),
                X_from_pk2_value        =>  '',
                X_from_pk3_value        =>  '',
                X_from_pk4_value        =>  '',
                X_from_pk5_value        =>  '',
                X_to_entity_name        =>  'EAM_WORK_ORDERS',
                X_to_pk1_value          =>  to_char(p_organization_id),
                X_to_pk2_value          =>  to_char(p_wip_entity_id),
                X_to_pk3_value          =>  '',
                X_to_pk4_value          =>  '',
                X_to_pk5_value          =>  '',
                X_created_by            =>  fnd_global.user_id,
                X_last_update_login     =>  fnd_global.login_id
                -- X_program_application_id=>  '',
                -- X_program_id            =>  '',
                -- X_request_id            =>  ''
                 );

           end if;  -- End of function

    end if;  -- end of copy bom attachments

    if (copy_activity_rtng_attachments = 'Y') then

      if (p_common_routing_sequence_id is not null) then

         fnd_attached_documents2_pkg.copy_attachments(
                X_from_entity_name      =>  'BOM_OPERATIONAL_ROUTINGS',
                X_from_pk1_value        =>  to_char(p_common_routing_sequence_id),
                X_from_pk2_value        =>  '',
                X_from_pk3_value        =>  '',
                X_from_pk4_value        =>  '',
                X_from_pk5_value        =>  '',
                X_to_entity_name        =>  'EAM_WORK_ORDERS',
                X_to_pk1_value          =>  to_char(p_organization_id),
                X_to_pk2_value          =>  to_char(p_wip_entity_id),
                X_to_pk3_value          =>  '',
                X_to_pk4_value          =>  '',
                X_to_pk5_value          =>  '',
                X_created_by            =>  fnd_global.user_id,
                X_last_update_login     =>  fnd_global.login_id
                -- X_program_application_id=>  '',
                -- X_program_id            =>  '',
                -- X_request_id            =>  ''
                 );

        -- Copy Attachments from Activity Routing
        -- open c_op_cur for 'select operation_sequence_id, operation_seq_num from bom_operation_sequences where routing_sequence_id = ' || p_common_routing_sequence_id ;

         -- l_stmt_num := 75;

        LOOP FETCH op_table into op_rec;

            l_operation_sequence_id     := op_rec.operation_sequence_id;
            l_operation_sequence_number := op_rec.operation_seq_num;

            --  l_stmt_num := 80;

            if l_operation_sequence_id is not null then

               fnd_attached_documents2_pkg.copy_attachments(
                X_from_entity_name      =>  'BOM_OPERATION_SEQUENCES',
                X_from_pk1_value        =>  to_char(l_operation_sequence_id),
                X_from_pk2_value        =>  '',
                X_from_pk3_value        =>  '',
                X_from_pk4_value        =>  '',
                X_from_pk5_value        =>  '',
                X_to_entity_name        =>  'EAM_DISCRETE_OPERATIONS',
                X_to_pk1_value          =>  to_char(p_wip_entity_id),
                X_to_pk2_value          =>  to_char(l_operation_sequence_number),
                X_to_pk3_value          =>  to_char(p_organization_id),
                X_to_pk4_value          =>  '',
                X_to_pk5_value          =>  '',
                X_created_by            =>  fnd_global.user_id,
                X_last_update_login     =>  fnd_global.login_id
                -- X_program_application_id=>  '',
                -- X_program_id            =>  '',
                -- X_request_id            =>  ''
                 );

            end if;

          exit when op_table%NOTFOUND;

        end loop; -- for the op_table loop.

        close op_table;

      end if ;  -- End of check for p_common_routing_sequence_id

    end if;  -- End of Copy Routing Attachments


   EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK TO copy_attachments_pvt;

  END copy_attachments;




  procedure create_default_operation
  (  p_organization_id             IN    NUMBER
    ,p_wip_entity_id               IN    NUMBER
  ) IS

  l_wip_entity_id            NUMBER;
  l_operation_exist          NUMBER := 0;
  l_description              VARCHAR2(720);
  l_organization_id          NUMBER;
  l_owning_department_id     NUMBER;
  l_start_date               DATE;
  l_completion_date          DATE;
  l_count number;
  l_min_op_seq_num number;
  l_department_id number;



 BEGIN

    fnd_message.set_name('EAM', 'EAM_WO_DEFAULT_OP');

    l_description := SUBSTRB(fnd_message.get, 1, 240);
    l_wip_entity_id := p_wip_entity_id;
    l_organization_id := p_organization_id;


   begin
    SELECT  nvl(COUNT(*),0)
    into    l_operation_exist
    FROM    WIP_OPERATIONS WO
    WHERE   WO.WIP_ENTITY_ID = l_wip_entity_id;

    IF ((l_operation_exist=0)) then


    select scheduled_start_date,
           scheduled_completion_date,
           owning_department
    into   l_start_date,
           l_completion_date,
           l_owning_department_id
    from wip_discrete_jobs
    where wip_entity_id = l_wip_entity_id
    and organization_id = l_organization_id;

    if (l_owning_department_id is null) then
    /* Changes for IB convergence */
/*    select distinct msn.owning_department_id
    into l_owning_department_id
    from wip_discrete_jobs wdj,mtl_serial_numbers msn
    where wdj.asset_group_id  = msn.inventory_item_id (+)
    and wdj.organization_id = msn.current_organization_id (+)
    and wdj.asset_number  = msn.serial_number (+)
    and wdj.wip_entity_id = l_wip_entity_id
    and wdj.organization_id = l_organization_id;*/

    select eomd.owning_department_id
    into l_owning_department_id
    from eam_org_maint_defaults eomd, wip_discrete_jobs wdj
    where wdj.maintenance_object_type = 3
    and wdj.organization_id = eomd.organization_id (+)
    and eomd.object_type (+) = 50
    and eomd.object_id (+) = wdj.maintenance_object_id
    and wdj.wip_entity_id = l_wip_entity_id
    and wdj.organization_id = l_organization_id;

    end if;


    -- insert
    insert into wip_operations
    (
       wip_entity_id
      ,operation_seq_num
      ,organization_id
      ,repetitive_schedule_id
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,operation_sequence_id
      ,standard_operation_id
      ,department_id
      ,description
      ,scheduled_quantity
      ,quantity_in_queue
      ,quantity_running
      ,quantity_waiting_to_move
      ,quantity_rejected
      ,quantity_scrapped
      ,quantity_completed
      ,first_unit_start_date
      ,first_unit_completion_date
      ,last_unit_start_date
      ,last_unit_completion_date
      ,previous_operation_seq_num
      ,next_operation_seq_num
      ,count_point_type
      ,backflush_flag
      ,minimum_transfer_quantity
      ,date_last_moved
      ,wf_itemtype
      ,wf_itemkey
      ,operation_yield
      ,operation_yield_enabled
      ,pre_split_quantity
      ,operation_completed
      ,shutdown_type
      ,x_pos
      ,y_pos
    )
    values
    (
       l_wip_entity_id
      ,10
      ,l_organization_id
      ,null  -- repetitive schedule id
      ,sysdate  -- last_update_date
      ,FND_GLOBAL.USER_ID
      ,sysdate  -- creation_date
      ,FND_GLOBAL.USER_ID
      ,FND_GLOBAL.LOGIN_ID
      ,null  -- operation_sequence_id
      ,null  -- standard_operation_id
      ,l_owning_department_id
      ,l_description
      ,1  -- scheduled_quantity
      ,1  -- quantity_in_queue
      ,1  -- quantity_running
      ,1  -- quantity_waiting_to_move
      ,0  -- quantity_rejected
      ,1  -- quantity_scrapped
      ,1  -- quantity_completed
      ,l_start_date
      ,l_completion_date
      ,l_start_date
      ,l_completion_date
      ,null -- previous_operation_seq_num
      ,null -- next_operation_seq_num
      ,1  -- count_point_type
      ,1  -- backflush_flag
      ,1  -- minimum_transfer_quantity
      ,null -- date_last_moved
      ,null  -- wf_itemtype
      ,null  -- wf_itemkey
      ,null  -- operation_yield
      ,null  -- operation_yield_enabled
      ,null  -- pre_split_quantity
      ,null  -- operation_completed
      ,null  -- shutdown_type
      ,null  -- x_pos
      ,null  -- y_pos
    );

   else  -- else for operation_exist check
    null;

   end if;

   /* Code added for updating material operation */


   begin
     select count(*)
     into l_count
     from wip_requirement_operations_v
     where organization_id = p_organization_id
     and  wip_entity_id = p_wip_entity_id
     and  operation_seq_num = 1;

     if l_count <> 0 then
       select min(operation_seq_num)
       into l_min_op_seq_num
      from wip_operations
     where    organization_id = p_organization_id and
              wip_entity_id = p_wip_entity_id;

      if (l_min_op_seq_num is not null) then
        select department_id into l_department_id
      from wip_operations
     where    organization_id = p_organization_id and
              wip_entity_id = p_wip_entity_id
          and   operation_seq_num = l_min_op_seq_num;
     end if;

       update wip_requirement_operations
              set operation_seq_num = l_min_op_seq_num,
                 department_id = l_department_id
          where operation_seq_num = 1 and
              organization_id = p_organization_id and
              wip_entity_id = p_wip_entity_id;

     end if;


     select count(*)
     into l_count
     from wip_eam_direct_items
     where organization_id = p_organization_id
     and  wip_entity_id = p_wip_entity_id
     and  operation_seq_num = 1;

     if l_count <> 0 then
       select min(operation_seq_num)
       into l_min_op_seq_num
      from wip_operations
     where    organization_id = p_organization_id and
              wip_entity_id = p_wip_entity_id;

      if (l_min_op_seq_num is not null) then
        select department_id into l_department_id
      from wip_operations
     where    organization_id = p_organization_id and
              wip_entity_id = p_wip_entity_id
          and   operation_seq_num = l_min_op_seq_num;
     end if;

       update wip_eam_direct_items
              set operation_seq_num = l_min_op_seq_num,
                 department_id = l_department_id
          where operation_seq_num = 1 and
              organization_id = p_organization_id and
              wip_entity_id = p_wip_entity_id;

     end if;

   end;


/* End of Check for Materials Operation */

   end ;  -- end for operation existence check

  END create_default_operation;  -- dml





END WIP_EAM_UTILS;

/
