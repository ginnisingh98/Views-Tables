--------------------------------------------------------
--  DDL for Package Body EAM_SKILL_INSTANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_SKILL_INSTANCE" AS
/* $Header: EAMSKILB.pls 115.9 2004/05/04 18:03:04 anjgupta ship $ */


  /**
   * This procedure is used to assign an instance to the resource
   * this is the main procedure called from resource instance and
   * skill search jsp's
   */
  procedure insert_instance(p_wip_entity_id     in number,
                            p_operation_seq_num in number,
                            p_resource_seq_num  in number,
                            p_organization_id   in number,
                            p_user_id           in number,
                            p_instance_id       in number,
                            p_start_date        in date,
                            p_completion_date   in date,
                            p_assigned_units_updated out NOCOPY number) is

  l_start_date      DATE;
  l_completion_date DATE;
  l_user_id         NUMBER;
  l_org_id          NUMBER;
  x_duplicate       BOOLEAN;
  x_error           VARCHAR2(240);
  l_assigned_changed NUMBER;

  begin

        p_assigned_units_updated := 0;


    if (p_start_date is null) or (p_completion_date is null) or (p_organization_id is null) then
      select distinct start_date, completion_date, organization_id into l_start_date, l_completion_date, l_org_id
      from   wip_operation_resources wor
      where  wor.wip_entity_id     = p_wip_entity_id
      and    wor.operation_seq_num = p_operation_seq_num
      and    wor.resource_seq_num  = p_resource_seq_num;
    end if;


    --get the start date for instance
    if (p_start_date is not null) then
       l_start_date := p_start_date;
    end if;


    if (p_completion_date is not null) then
       l_completion_date := p_completion_date;
    end if;



    if(p_user_id is not null) then
      l_user_id := p_user_id;
    else
      l_user_id := FND_GLOBAL.USER_ID;
    end if;

    if(p_organization_id is not null) then
      l_org_id := p_organization_id;
    end if;

    --call the insert statement only if this instance is not duplicate

    x_duplicate := is_duplicate_instance(p_wip_entity_id, p_operation_seq_num,
                      p_resource_seq_num, l_org_id, p_instance_id);

    if (NOT x_duplicate) then
      INSERT INTO WIP_OP_RESOURCE_INSTANCES
      (
        WIP_ENTITY_ID,
        OPERATION_SEQ_NUM,
        RESOURCE_SEQ_NUM,
        ORGANIZATION_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        INSTANCE_ID,
        START_DATE,
        COMPLETION_DATE)
      VALUES(
        p_wip_entity_id,
        p_operation_seq_num,
        p_resource_seq_num,
        l_org_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        p_instance_id,
        l_start_date,
        l_completion_date);

      -- Bug 3568576 - Forward port of bug 3545813
      -- Do not firm wo after resource instances are added
      --after assigning the instance, firm the job,
      --otherwise rescheduling will wipe out all the instances
      --firm_work_order(p_wip_entity_id ,p_organization_id);
	p_assigned_units_updated := p_assigned_units_updated + 1 ;
      commit;

    end if;

  end insert_instance;


  /**
   * This function is used to check the duplicate instance assignment
   * if we already filter the lov then this function should return false
   */
  function is_duplicate_instance(p_wip_entity_id      in number,
                                  p_operation_seq_num in number,
                                  p_resource_seq_num  in number,
                                  p_organization_id   in number,
                                  p_instance_id       in number) return boolean is
  l_num NUMBER;
  begin
    select count(*) into l_num
    from   WIP_OP_RESOURCE_INSTANCES
    where  wip_entity_id     = p_wip_entity_id and
           operation_seq_num = p_operation_seq_num and
           resource_seq_num  = p_resource_seq_num and
           instance_id       = p_instance_id;

    if( l_num <> 0 ) then
       return true;
    else
       return false;
    end if;

  end is_duplicate_instance;


  /**
   * This procedure is used to check whether the assigned units are in
   * sync with the number of resource instances, if its less then we
   * increase the assigned units and return
   */
  procedure check_assigned_units(p_wip_entity_id      in number,
                                  p_operation_seq_num in number,
                                  p_resource_seq_num  in number,
                                  p_organization_id   in number,
                                  p_assigned_changed  out NOCOPY number) is
  l_assigned_units_num NUMBER;
  l_instance_num       NUMBER;

  begin

    select count(*) into l_instance_num
    from   WIP_OP_RESOURCE_INSTANCES
    where  wip_entity_id     = p_wip_entity_id and
           operation_seq_num = p_operation_seq_num and
           resource_seq_num  = p_resource_seq_num;

    select nvl(assigned_units,0) into l_assigned_units_num
    from   WIP_OPERATION_RESOURCES
    where  wip_entity_id     = p_wip_entity_id and
           operation_seq_num = p_operation_seq_num and
           resource_seq_num  = p_resource_seq_num;

    --we would be adding 1 instance, so check l_instance+1
    --if assigned units are less then increment

    if( l_instance_num + 1 > l_assigned_units_num ) then
      p_assigned_changed := 1;
      update wip_operation_resources
      set assigned_units  = (l_instance_num + 1)
      where wip_entity_id = p_wip_entity_id and
            operation_seq_num = p_operation_seq_num and
            resource_seq_num  = p_resource_seq_num;
    else
      p_assigned_changed := 0;
    end if;

  end check_assigned_units;

  /**
   * This procedure is used to firm the workorder after the instance
   * is assigned to the resource
   */
  procedure firm_work_order(p_wip_entity_id     in number,
                            p_organization_id   in number) is
  begin

    update wip_discrete_jobs
    set    firm_planned_flag = 1
    where  wip_entity_id = p_wip_entity_id;

  end firm_work_order;


  /**
   * This procedure is used to remove an assigned instance from
   * the resource
   */
  procedure remove_instance(p_wip_entity_id     in number,
                            p_operation_seq_num in number,
                            p_resource_seq_num  in number,
                            p_instance_id       in number) is
  begin

    delete from wip_op_resource_instances
    where wip_entity_id     = p_wip_entity_id and
          operation_seq_num = p_operation_seq_num and
          resource_seq_num  = p_resource_seq_num and
          instance_id       = p_instance_id;
    commit;
  end remove_instance;







END EAM_SKILL_INSTANCE;

/
