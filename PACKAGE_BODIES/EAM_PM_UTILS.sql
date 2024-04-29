--------------------------------------------------------
--  DDL for Package Body EAM_PM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PM_UTILS" AS
/* $Header: EAMPMUTB.pls 120.8 2006/04/20 04:10:26 yjhabak ship $ */

  /**
   * This is a private procedure to be called to move one particular pm
   * suggestion to the wip mass load interface table.
   */
  procedure move_pm_to_wdj(p_group_id  in number,
                           p_pm_id     in number,
                           p_assoc_id  in number);

  /**
   * this is a private procedure to be called to update all the pms
   * under the root of the given pm.
   */
  procedure update_all_pm_uncomplete(p_wip_entity_id in number, p_activity_association_id in number);


  /**
   * This is a private function.
   * This function returns false if no pm related data should be updated. It returns true
   * otherwise. When it returns true, it populates the return parameters with the right
   * information.
   */
  function check_applicable_pm(p_org_id        in number,
                               p_wip_entity_id in number,
                               p_pm_schedule_id out NOCOPY number,
                               p_resched_point out NOCOPY number) return boolean;



  /**
   * This procedure should be called when completing the work order. It will update
   * the related PM rule data if applicable.
   **** This procedure is now obsolete and is no longer called,
   **** thus the body is null.
   */
  procedure update_pm_when_complete(p_org_id        in number,
                                    p_wip_entity_id in number,
                                    p_completion_date in date) is
    x_pm_id number := null;
    x_resched_point number;
    x_applicable boolean;
    x_new_base_date date;
  begin
	null;
  end update_pm_when_complete;

  /**
   * This procedure should be called when uncompleting the work order. It will update
   * the related PM rule data if applicable.
   */

  procedure update_pm_when_uncomplete(p_org_id        in number,
                                    p_wip_entity_id in number)
  is
	l_is_last_wo boolean;
	l_activity_association_id number;
	l_service_reading number;
	l_meter_reading_id number;
	l_last_service_end_date DATE;

            /* Bug # 5154927 : Corrected the query for both correctness and performance */
	    CURSOR METER_READING_IDS(P_WIP_ENTITY_ID NUMBER) IS
		select ccr.counter_value_id meter_reading_id
		  from csi_counter_readings ccr,  csi_transactions cct,
		       csi_counter_associations cca, wip_discrete_jobs wdj
		 where ccr.transaction_id = cct.transaction_id
		   and cct.transaction_type_id = 92
		   and cct.source_header_ref_id = wdj.wip_entity_id
		   and wdj.wip_entity_id = p_wip_entity_id
		   and wdj.maintenance_object_type = 3
		   and wdj.maintenance_object_id = cca.source_object_id
		   and cca.source_object_code = 'CP'
		   and cca.counter_id = ccr.counter_id;

	    L_MSG_DATA VARCHAR2(10000);
	    L_MSG_COUNT NUMBER;
	    L_RETURN_STATUS VARCHAR2(1);

  begin

	l_is_last_wo := check_is_last_wo(p_org_id, p_wip_entity_id,l_last_service_end_date);
	if (l_is_last_wo=false) then
		return;
	end if;

        -- Code added to take care of BUG # 4653925 , 5154927
         OPEN meter_reading_ids(p_wip_entity_id);
         LOOP
            fetch meter_reading_ids into l_meter_reading_id;
            Exit when meter_reading_ids%NOTFOUND;
                    EAM_MeterReading_PUB.disable_meter_reading(
                                p_api_version => 1.0,
                           		p_init_msg_list => null,
                			    p_commit => FND_API.G_FALSE,
                        		x_return_status => l_return_status,
                    	       	x_msg_count => l_msg_count,
                		          x_msg_data => l_msg_data,
                                  p_meter_reading_id => l_meter_reading_id,
                                  p_meter_id => null,
                                  p_meter_reading_date => null);

         END LOOP;

	-- reverse the last service reading in eam_pm_last_service table.
        	update eam_pm_last_service
	        set
				last_service_reading=prev_service_reading,
				wip_entity_id=null,
				last_update_date=sysdate,
				last_updated_by=fnd_global.user_id
	        where
				wip_entity_id=p_wip_entity_id
				and prev_service_reading is not null;


	-- Get the activity_association_id for this work order

	select meaa.activity_association_id into l_activity_association_id
 	from wip_discrete_jobs wdj, mtl_eam_asset_activities meaa
 	where
        wdj.wip_entity_id=p_wip_entity_id and
        wdj.maintenance_object_id=meaa.maintenance_object_id and
        wdj.maintenance_object_type=meaa.maintenance_object_type and
        wdj.primary_item_id=meaa.asset_activity_id;

	-- recursively reverse the last service date for all activities
	-- in the suppression tree with l_activity_association_id as
	-- root.
	update_all_pm_uncomplete(p_wip_entity_id, l_activity_association_id);
  exception
	when no_data_found then
		return;
  end;

/*
* Following function, given an organization id and wip_entity_number,
* determines whether this is the latest completed work order for
* its asset/activity association.
*/
  function check_is_last_wo(p_org_id number,
			    p_wip_entity_id number,
			    p_last_service_end_date OUT NOCOPY DATE )
  return boolean
  is
  	l_last_actual_end_date date;
	l_last_wip_entity_id number;
	l_transaction_type number;
  begin
	-- Find the latest date of any wo transaction for this asset / act assoc.

	select max(ejct.actual_end_date)
	into l_last_actual_end_date
	from
	eam_job_completion_txns ejct
	where
	transaction_type=1
	and transaction_id in
	(select max(ejct.transaction_id) from
	eam_job_completion_txns ejct,
	wip_discrete_jobs wdj1,
	wip_discrete_jobs wdj2
	where wdj1.wip_entity_id=p_wip_entity_id
	and wdj1.maintenance_object_type = wdj2.maintenance_object_type
	and wdj1.maintenance_object_id = wdj2.maintenance_object_id
        and nvl(wdj1.primary_item_id, -99) = nvl(wdj2.primary_item_id, -99)
        and wdj1.organization_id = wdj2.organization_id
	and ejct.wip_entity_id = wdj2.wip_entity_id
	group by ejct.wip_entity_id);

	--Retruning actual end date to get the counter reading id.
	p_last_service_end_date := l_last_actual_end_date;

	-- Find the wo transaction on this l_last_actual_end_date
	-- for this asset / act assoc and see if it matches
	-- p_wip_entity_id and if it is a "completion" transaction.

	select wip_entity_id, transaction_type
	into l_last_wip_entity_id, l_transaction_type
	from eam_job_completion_txns
	where actual_end_date=l_last_actual_end_date
	and transaction_id=
	(select max(transaction_id)
 	from eam_job_completion_txns
 	where wip_entity_id=p_wip_entity_id
	and transaction_type = 1);

	if (p_wip_entity_id <> l_last_wip_entity_id)
	then
		return false;
	else
		return true;
	end if;

  exception
	when no_data_found then
		return false;
  end;


  procedure update_all_pm_uncomplete(p_wip_entity_id in number, p_activity_association_id in number) is
  cursor C is
      select sup.child_association_id
        from eam_suppression_relations sup
       where
         sup.parent_association_id = p_activity_association_id;

l_prev_service_start_date date;
l_prev_service_end_date date;
l_prev_scheduled_start_date date;
l_prev_scheduled_end_date date;
l_prev_pm_suggested_start_date   date;
l_prev_pm_suggested_end_date   date;

    x_child_aa number;
  begin


     -- First, update the last service date in meaa table
     select prev_service_start_date, prev_service_end_date,
            prev_scheduled_start_date, prev_scheduled_end_date,
            prev_pm_suggested_start_date, prev_pm_suggested_end_date
	into l_prev_service_start_date, l_prev_service_end_date,
	     l_prev_scheduled_start_date, l_prev_scheduled_end_date,
	     l_prev_pm_suggested_start_date,l_prev_pm_suggested_end_date
	from mtl_eam_asset_activities
	where activity_association_id=p_activity_association_id;

  if (l_prev_service_start_date is not null and l_prev_service_end_date is not null and
      l_prev_scheduled_start_date is not null and l_prev_scheduled_end_date is not null) then
     update mtl_eam_asset_activities
        set last_service_start_date = l_prev_service_start_date,
            last_service_end_date = l_prev_service_end_date,
	    last_scheduled_start_date = l_prev_scheduled_start_date,
	    last_scheduled_end_date = l_prev_scheduled_end_date,
            last_pm_suggested_start_date = l_prev_pm_suggested_start_date,
	    last_pm_suggested_end_date = l_prev_pm_suggested_end_date
      where activity_association_id=p_activity_association_id;

     update mtl_eam_asset_activities
	set prev_service_start_date = null,
	    prev_service_end_date = null,
	    prev_scheduled_start_date = null,
	    prev_scheduled_end_date = null,
	    prev_pm_suggested_start_date = null,
	    prev_pm_suggested_end_date = null,
	    wip_entity_id = p_wip_entity_id
      where activity_association_id=p_activity_association_id;

  end if;

     open C;
     LOOP
       fetch C into x_child_aa;
       EXIT WHEN ( C%NOTFOUND );
       update_all_pm_uncomplete(p_wip_entity_id, x_child_aa);
     END LOOP;
     close C;

  end update_all_pm_uncomplete;


  /**
   * This function returns false if no pm related data should be updated. It returns true
   * otherwise. When it returns true, it populates the return parameters with the right
   * information.
   */
  function check_applicable_pm(p_org_id        in number,
                               p_wip_entity_id in number,
                               p_pm_schedule_id out NOCOPY number,
                               p_resched_point out NOCOPY number) return boolean
  is
    cursor C(p_asset_group_id number,
             p_asset_number varchar2,
             p_asset_activity_id number) is
      select pms.pm_schedule_id
        from eam_pm_schedulings pms,
             mtl_eam_asset_activities eaa
       where pms.activity_association_id = eaa.activity_association_id
         and eaa.organization_id = p_org_id
         and eaa.inventory_item_id = p_asset_group_id
         and eaa.serial_number = p_asset_number
         and eaa.asset_activity_id = p_asset_activity_id
         and nvl(eaa.start_date_active, sysdate-1) < sysdate
         and nvl(eaa.end_date_active, sysdate+1) > sysdate
         and nvl(pms.from_effective_date, sysdate-1) < sysdate
         and nvl(pms.to_effective_date, sysdate+1) > sysdate;

    x_pm_id number := null;
    x_asset_group_id number := null;
    x_asset_number varchar2(30) := null;
    x_asset_activity_id number := null;
    x_rebuild_id number := null;
    x_generated_by_pm boolean := false;
    x_resched_point number;
  begin
    select pm_schedule_id,
           asset_group_id,
           asset_number,
           primary_item_id,
           rebuild_item_id
      into x_pm_id,
           x_asset_group_id,
           x_asset_number,
           x_asset_activity_id,
           x_rebuild_id
      from wip_discrete_jobs
     where wip_entity_id = p_wip_entity_id;

    -- do nothing for rebuildable work order
    if ( x_rebuild_id is not null ) then
      return false;
    end if;

    -- find the corresponding valid pm schedule id if there is one
    if ( x_pm_id is null ) then
      open C(x_asset_group_id, x_asset_number, x_asset_activity_id);
      fetch C into x_pm_id;
      if ( C%NOTFOUND ) then
        close C;
        return false;
      end if;
      close C;
    else
      x_generated_by_pm := true;
    end if;

    select rescheduling_point into x_resched_point
      from eam_pm_schedulings
     where pm_schedule_id = x_pm_id;

    -- if the rescheduling point is start date, then we ignore the manually created
    -- work orders.
    if ( x_resched_point = 1 AND  x_generated_by_pm = false ) then
      return false;
    end if;

    p_pm_schedule_id := x_pm_id;
    p_resched_point := x_resched_point;
    return true;
  end check_applicable_pm;


  /**
   * This procedure is called to move the forecasted work order suggestions from
   * forecast table to wip_job_schedule_interface to be uploaded. It removes the
   * records from forecast table then.
   */
  procedure transfer_to_wdj(p_group_id number) is
    cursor pms is
      select distinct pm_schedule_id, activity_association_id
        from eam_forecasted_work_orders
       where group_id = p_group_id
         and process_flag = 'Y';

    l_pm_id number;
    l_assoc_id number;
  begin
    open pms;
    fetch pms into l_pm_id, l_assoc_id;
    if ( pms%NOTFOUND ) then
      close pms;
      return;
    end if;

    LOOP
      move_pm_to_wdj(p_group_id, l_pm_id, l_assoc_id);
      fetch pms into l_pm_id, l_assoc_id;
      EXIT WHEN ( pms%NOTFOUND );
    END LOOP;
    close pms;

    -- delete the records that has been moved to the mass load interface table
    delete from eam_forecasted_work_orders
    where group_id = p_group_id
    and process_flag = 'Y';
  end transfer_to_wdj;


 procedure move_pm_to_wdj(p_group_id  in number,
                           p_pm_id     in number,
                           p_assoc_id  in number) is
    cursor pmwo is
      select scheduled_start_date,
             scheduled_completion_date,
             wip_entity_id,
             action_type,
             created_by,
             creation_date,
             last_update_login,
             last_update_date,
             last_updated_by,
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
             attribute15
        from eam_forecasted_work_orders
       where pm_schedule_id = p_pm_id
         and group_id = p_group_id
         and process_flag = 'Y';

    recinfo pmwo%ROWTYPE;
    l_org_id            number;
    l_inventory_item_id   number;
    l_serial_number      varchar2(30);
    l_asset_activity_id number;
    l_owning_department number;
    l_description       varchar2(240);
 --   l_routing_reference_id number;
 --   l_bom_reference_id  number;
    l_priority_code     varchar2(30);
    l_activity_cause    varchar2(30);
    l_activity_type     varchar2(30);
    l_activity_source   varchar2(30);
    l_tagging_required_flag  varchar2(1);
    l_shutdown_type_code varchar2(30);
    l_class_code        varchar2(10);
    l_eam_item_type	number;
    l_maintenance_object_id number;
  begin
    select organization_id,
           inventory_item_id,
           serial_number,
           asset_activity_id,
           owning_department_id,
           activity_cause_code,
           activity_type_code,
           activity_source_code,
           tagging_required_flag,
           shutdown_type_code,
           priority_code
      into l_org_id,
           l_inventory_item_id,
           l_serial_number,
           l_asset_activity_id,
           l_owning_department,
           l_activity_cause,
           l_activity_type,
           l_activity_source,
           l_tagging_required_flag,
           l_shutdown_type_code,
           l_priority_code
      from mtl_eam_asset_activities
     where activity_association_id = p_assoc_id;

     if (l_serial_number is not null) then
      select wip_accounting_class_code, gen_object_id
       into l_class_code, l_maintenance_object_id
       from mtl_serial_numbers
      where current_organization_id = l_org_id
        and inventory_item_id = l_inventory_item_id
        and serial_number = l_serial_number;
     end if;

     select eam_item_type
	 into l_eam_item_type
       from mtl_system_items
     where organization_id = l_org_id
	 and inventory_item_id = l_inventory_item_id;

     select description
       into l_description
       /* from mtl_system_items_b Commented for bug#4878157 */
       from mtl_system_items_vl /* Added for bug#4878157 */
      where inventory_item_id = l_asset_activity_id
        and organization_id = l_org_id;

     open pmwo;
     fetch pmwo into recinfo;
     if ( pmwo%NOTFOUND ) then
       close pmwo;
       return;
     end if;

     LOOP
       if ( recinfo.action_type = 1 ) then
       -- Create
	if ( l_eam_item_type = 1 ) then
        -- for Asset Group and number
         insert into wip_job_schedule_interface(
           group_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           organization_id,
           load_type,
           first_unit_start_date,
           last_unit_completion_date,
           asset_group_id,
           description,
           routing_reference_id,
           bom_reference_id,
           asset_number,
           primary_item_id,
           pm_schedule_id,
           process_phase,
           process_status,
           owning_department,
           activity_type,
           activity_cause,
           activity_source,
           tagout_required,
           shutdown_type,
           priority,
           plan_maintenance,
           class_code,
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
           maintenance_object_id,
           maintenance_object_type,
           maintenance_object_source
         )values(
           p_group_id,
           sysdate,
           recinfo.last_updated_by,
           sysdate,
           recinfo.created_by,
           recinfo.last_update_login,
           l_org_id,
           7,
           recinfo.scheduled_start_date,
           recinfo.scheduled_completion_date,
           l_inventory_item_id,
           l_description,
           l_asset_activity_id,
           l_asset_activity_id,
           l_serial_number,
           l_asset_activity_id,
           p_pm_id,
           2,
           1,
           l_owning_department,
           l_activity_type,
           l_activity_cause,
           l_activity_source,
           l_tagging_required_flag,
           l_shutdown_type_code,
           to_number(l_priority_code),
           'Y',
           l_class_code,
           recinfo.attribute_category,
           recinfo.attribute1,
           recinfo.attribute2,
           recinfo.attribute3,
           recinfo.attribute4,
           recinfo.attribute5,
           recinfo.attribute6,
           recinfo.attribute7,
           recinfo.attribute8,
           recinfo.attribute9,
           recinfo.attribute10,
           recinfo.attribute11,
           recinfo.attribute12,
           recinfo.attribute13,
           recinfo.attribute14,
           recinfo.attribute15,
           l_maintenance_object_id,
           1,
           1
         );
        elsif (l_eam_item_type = 3) then
         -- for rebuildables
         insert into wip_job_schedule_interface(
           group_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           organization_id,
           load_type,
           first_unit_start_date,
           last_unit_completion_date,
           rebuild_item_id,
           description,
           routing_reference_id,
           bom_reference_id,
           rebuild_serial_number,
           primary_item_id,
           pm_schedule_id,
           process_phase,
           process_status,
           owning_department,
           activity_type,
           activity_cause,
           activity_source,
           tagout_required,
           shutdown_type,
           priority,
           plan_maintenance,
           class_code,
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
           manual_rebuild_flag,
           maintenance_object_id,
           maintenance_object_type,
           maintenance_object_source
         )values(
           p_group_id,
           sysdate,
           recinfo.last_updated_by,
           sysdate,
           recinfo.created_by,
           recinfo.last_update_login,
           l_org_id,
           7,
           recinfo.scheduled_start_date,
           recinfo.scheduled_completion_date,
           l_inventory_item_id,
           l_description,
           l_asset_activity_id,
           l_asset_activity_id,
           l_serial_number,
           l_asset_activity_id,
           p_pm_id,
           2,
           1,
           l_owning_department,
           l_activity_type,
           l_activity_cause,
           l_activity_source,
           l_tagging_required_flag,
           l_shutdown_type_code,
           to_number(l_priority_code),
           'Y',
           l_class_code,
           recinfo.attribute_category,
           recinfo.attribute1,
           recinfo.attribute2,
           recinfo.attribute3,
           recinfo.attribute4,
           recinfo.attribute5,
           recinfo.attribute6,
           recinfo.attribute7,
           recinfo.attribute8,
           recinfo.attribute9,
           recinfo.attribute10,
           recinfo.attribute11,
           recinfo.attribute12,
           recinfo.attribute13,
           recinfo.attribute14,
           recinfo.attribute15,
           'Y',
           nvl(l_maintenance_object_id, l_inventory_item_id),
           decode(l_maintenance_object_id, null, 2, 1),
           1
         );
  	end if;

       elsif ( recinfo.action_type = 2 ) then
       -- Reschdule
         insert into wip_job_schedule_interface(
           group_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           organization_id,
           load_type,
           wip_entity_id,
           first_unit_start_date,
           last_unit_completion_date,
           process_phase,
           process_status,
           maintenance_object_id,
           maintenance_object_type,
           maintenance_object_source
         )values(
           p_group_id,
           sysdate,
           recinfo.last_updated_by,
           sysdate,
           recinfo.created_by,
           recinfo.last_update_login,
           l_org_id,
           8,
           recinfo.wip_entity_id,
           recinfo.scheduled_start_date,
           recinfo.scheduled_completion_date,
           2,
           1,
           nvl(l_maintenance_object_id, l_inventory_item_id),
           decode(l_maintenance_object_id, null, 2, 1),
           1
         );
       elsif ( recinfo.action_type = 3 ) then
       -- Cancel
         insert into wip_job_schedule_interface(
           group_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           organization_id,
           load_type,
           wip_entity_id,
           status_type,
           process_phase,
           process_status,
           maintenance_object_id,
           maintenance_object_type,
           maintenance_object_source
         )values(
           p_group_id,
           sysdate,
           recinfo.last_updated_by,
           sysdate,
           recinfo.created_by,
           recinfo.last_update_login,
           l_org_id,
           8,
           recinfo.wip_entity_id,
           7,
           2,
           1,
           nvl(l_maintenance_object_id, l_inventory_item_id),
           decode(l_maintenance_object_id, null, 2, 1),
           1
         );
       end if;

       fetch pmwo into recinfo;
       EXIT WHEN ( pmwo%NOTFOUND );
     END LOOP;
     close pmwo;
  end move_pm_to_wdj;

END eam_pm_utils;

/
