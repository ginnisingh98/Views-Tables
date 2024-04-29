--------------------------------------------------------
--  DDL for Package Body WIP_UPDATE_SETUP_RESOURCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_UPDATE_SETUP_RESOURCES" AS
/* $Header: wpusetrb.pls 115.9 2002/12/03 11:28:12 simishra ship $ */

g_scheduled_jobs Number_Tbl_Type;


PROCEDURE DELETE_SETUP_RESOURCES(p_wip_entity_id     NUMBER,
				 p_organization_id   NUMBER,
				 p_operation_seq_num NUMBER,
				 p_resource_seq_num  NUMBER) IS

BEGIN

  -- delete old setup resource instances
  delete from wip_op_resource_instances
  where wip_entity_id = p_wip_entity_id
    and organization_id = p_organization_id
    and operation_seq_num = p_operation_seq_num
    and resource_seq_num in (
		             select resource_seq_num
		               from wip_operation_resources wor
		              where wor.wip_entity_id = p_wip_entity_id
	                        and wor.organization_id = p_organization_id
	                        and wor.operation_seq_num = p_operation_seq_num
	                        and wor.parent_resource_seq = p_resource_seq_num);

   -- delete old setup resources
   delete from wip_operation_resources
    where wip_entity_id = p_wip_entity_id
      and organization_id = p_organization_id
      and operation_seq_num = p_operation_seq_num
      and parent_resource_seq = p_resource_seq_num;

END DELETE_SETUP_RESOURCES;


PROCEDURE UPDATE_SETUP_RESOURCES_PVT(p_wip_entity_id         IN NUMBER,
				     p_organization_id       IN NUMBER,
				     p_operation_seq         IN NUMBER,
				     p_resource_seq          IN NUMBER,
				     x_status                OUT NOCOPY VARCHAR2,
				     x_msg_count             OUT NOCOPY NUMBER,
				     x_msg_data              OUT NOCOPY VARCHAR2)
IS
   l_setup_id      NUMBER;
   l_resource_id   NUMBER;
   l_dept_id       NUMBER;

   l_next_wip_entity_id      NUMBER;
   l_next_operation_seq_num  NUMBER;
   l_next_resource_seq_num   NUMBER;
   l_next_instance_id        NUMBER;
   l_next_serial_number      VARCHAR2(30);
   l_next_setup_id           NUMBER;
   l_next_processed_qty      NUMBER;
   l_next_start_date         DATE;

   l_update_resources        BOOLEAN := TRUE;

   l_transition_time         NUMBER;
   l_uom_code                VARCHAR2(3);
   l_std_op_id               NUMBER;
   l_setup_op_res_seq        NUMBER;
   l_num_of_instances        NUMBER;

   l_instance_id             NUMBER;
   l_serial_number           VARCHAR2(30);
   l_res_completion_date     DATE;
   l_ri_completion_date      DATE;


   cursor op_res_instances(p_wip_entity_id NUMBER,
			   p_operation_seq_num NUMBER,
			   p_resource_seq_num NUMBER) is
     select wori.instance_id,
            wori.serial_number,
            wori.completion_date
       from wip_op_resource_instances wori
      where wori.wip_entity_id = p_wip_entity_id
        and wori.organization_id = p_organization_id
        and wori.operation_seq_num = p_operation_seq_num
        and wori.resource_seq_num = p_resource_seq_num;


   cursor next_op_res(p_completion_date DATE,
		      p_resource_id     NUMBER) IS
     select wip_entity_id,
            operation_seq_num,
            resource_seq_num,
            setup_id,
            processed_qty,
            start_date
       from (select wor.wip_entity_id wip_entity_id,
	            wor.operation_seq_num operation_seq_num,
	            wor.resource_seq_num resource_seq_num,
	            wor.setup_id,
	            nvl(wo.quantity_running,0)+nvl(wo.quantity_completed,0) processed_qty,
	            wor.start_date start_date
	       from wip_operation_resources wor,
	            wip_operations wo
	      where wor.start_date >= p_completion_date
	        and wor.resource_id = p_resource_id
	        and wor.parent_resource_seq is null
	        and wo.wip_entity_id = wor.wip_entity_id
	        and wo.organization_id = wor.organization_id
	        and wo.operation_seq_num = wor.operation_seq_num
	      order by wor.start_date)
	 where rownum = 1;




   cursor next_op_res_inst(p_completion_date DATE,
			   p_resource_id     NUMBER,
			   p_instance_id     NUMBER,
			   p_serial_number   VARCHAR2) IS
     select wip_entity_id,
            operation_seq_num,
            resource_seq_num,
            instance_id,
            serial_number,
	    setup_id,
	    processed_qty,
	    start_date
         from (select wori1.wip_entity_id wip_entity_id,
	              wori1.operation_seq_num operation_seq_num,
	              wori1.resource_seq_num resource_seq_num,
	              wori1.instance_id instance_id,
	              wori1.serial_number serial_number,
	              wor1.setup_id,
	              nvl(wo.quantity_running,0)+nvl(wo.quantity_completed,0) processed_qty,
	              wor1.start_date start_date
	         from wip_op_resource_instances wori1,
	              wip_operation_resources wor1,
	              wip_operations wo
	        where wor1.wip_entity_id =  wori1.wip_entity_id
	          and wor1.operation_seq_num = wori1.operation_seq_num
	          and wor1.resource_seq_num = wori1.resource_seq_num
	          and wori1.start_date >= p_completion_date
	          and wor1.resource_id = p_resource_id
	          and wor1.parent_resource_seq is null
	          and wori1.instance_id = p_instance_id
	          and nvl(wori1.serial_number,-1) = nvl(p_serial_number,-1)
	          and wo.wip_entity_id = wor1.wip_entity_id
	          and wo.organization_id = wor1.organization_id
	          and wo.operation_seq_num = wor1.operation_seq_num
	        order by wori1.start_date)
	 where rownum = 1;

   cursor get_transition(p_resource_id NUMBER,
			 l_from_setup_id NUMBER,
			 l_to_setup_id NUMBER) IS
     select transition_time, operation_id
       from (select inv_convert.inv_um_convert
	                     (-1,2,transition_time,
	                      transition_uom, 'MIN', NULL, NULL) transition_time,
	     operation_id
	     from bom_setup_transitions
	     where resource_id = l_resource_id
	     and organization_id = p_organization_id
	     and from_setup_id = l_setup_id
	     and to_setup_id = l_next_setup_id
               union
               select inv_convert.inv_um_convert
	                (-1,2,transition_time,
			 transition_uom, 'MIN', NULL, NULL) transition_time,
	              operation_id
	         from bom_setup_transitions
                where resource_id = l_resource_id
                  and organization_id = p_organization_id
                  and from_setup_id is null
	          and to_setup_id = l_next_setup_id)
	   where rownum = 1;

   cursor setup_resource_cursor(p_std_op_id NUMBER) IS
      select bsor.resource_id,
	     bsor.resource_seq_num,
	     bsor.assigned_units,
	     bsor.schedule_flag,
	     bso.department_id
	FROM bom_std_op_resources bsor,
	     bom_standard_operations bso
       WHERE bsor.standard_operation_id = p_std_op_id
	 and bso.standard_operation_id = bsor.standard_operation_id;

   cursor instance_cursor(p_resource_id NUMBER,
			  p_dept_id NUMBER) IS
      select instance_id,
	     serial_number
	from bom_dept_res_instances
       where resource_id = p_resource_id
	 and department_id = p_dept_id;



BEGIN

   -- get the current resource and setup
   select wor.setup_id,
          wor.resource_id,
          nvl(wor.department_id, wo.department_id),
          wor.completion_date
     into l_setup_id,
          l_resource_id,
          l_dept_id,
          l_res_completion_date
     from wip_operation_resources wor,
          wip_operations wo
    where wor.wip_entity_id = p_wip_entity_id
      and wor.organization_id = p_organization_id
      and wor.operation_seq_num = p_operation_seq
      and wor.resource_seq_num = p_resource_seq
      and wo.wip_entity_id = wor.wip_entity_id
      and wo.organization_id = wor.organization_id
      and wo.operation_seq_num = wor.operation_seq_num;


   SAVEPOINT start_point;


   -- for each resource instance, find the necessary setup resources for the
   -- NEXT activity using the same instance

   OPEN op_res_instances(p_wip_entity_id,p_operation_seq, p_resource_seq);
   LOOP
      FETCH op_res_instances INTO l_instance_id, l_serial_number, l_ri_completion_date;

     IF op_res_instances%ROWCOUNT = 0 THEN
	OPEN next_op_res(l_res_completion_date, l_resource_id);
        FETCH next_op_res INTO l_next_wip_entity_id, l_next_operation_seq_num,
	                       l_next_resource_seq_num, l_next_setup_id,
	                       l_next_processed_qty, l_next_start_date;
        CLOSE next_op_res;

     ELSE
        OPEN next_op_res_inst(l_ri_completion_date, l_resource_id, l_instance_id, l_serial_number);
        FETCH next_op_res_inst INTO l_next_wip_entity_id, l_next_operation_seq_num,
	                         l_next_resource_seq_num, l_next_instance_id,
	                         l_next_serial_number, l_next_setup_id,
	                         l_next_processed_qty, l_next_start_date;
        CLOSE next_op_res_inst;

     end if;

    -- check if the job found is in the excluded list
    FOR i IN 1..g_scheduled_jobs.count loop
	if g_scheduled_jobs(i) = l_next_wip_entity_id THEN
	  l_update_resources := FALSE;
	  exit;
	end if;
    END LOOP;


    -- if the job is in the excluded list or if the next job already has activity,
    -- then do NOT update setup resources and exit
    if l_update_resources = FALSE or l_next_processed_qty > 0 then
       exit;
    end if;

    -- get the appropriate transition for the opep resource instance
    OPEN get_transition(l_resource_id, l_setup_id, l_next_setup_id);
    FETCH  get_transition INTO l_transition_time, l_std_op_id;
    IF get_transition%NOTFOUND THEN
       l_update_resources := FALSE;
       exit;
    END IF;
    CLOSE get_transition;

    DELETE_SETUP_RESOURCES(l_next_wip_entity_id,
			   p_organization_id,
			   l_next_operation_seq_num,
			   l_next_resource_seq_num);

     -- get the max resource sequence for the operation
    select max(res)
      into l_setup_op_res_seq
      from (select max(resource_seq_num) res
              from wip_operation_resources
             where wip_entity_id = l_next_wip_entity_id
               and operation_seq_num = l_next_operation_seq_num
            union
            select max(resource_seq_num) res
              from wip_sub_operation_resources
             where wip_Entity_id = l_next_wip_entity_id
	       and operation_seq_num = l_next_operation_seq_num);

     l_setup_op_res_seq := l_setup_op_res_seq+10;

     -- insert setup resource for the resource that is being setup
     INSERT INTO WIP_OPERATION_RESOURCES
       (last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	organization_id,
	wip_entity_id,
	repetitive_schedule_id,
	operation_seq_num,
	resource_seq_num,
	resource_id,
	uom_code,
	basis_type,
	activity_id,
	standard_rate_flag,
	usage_rate_or_amount,
	scheduled_flag,
	assigned_units,
	autocharge_type,
	applied_resource_units,
	applied_resource_value,
	start_date,
	completion_date,
	parent_resource_seq,
	substitute_group_num,
	replacement_group_num,
	schedule_seq_num
	)
       select
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.LOGIN_ID,
        p_organization_id,
        l_next_wip_entity_id,
        NULL,
        l_next_operation_seq_num,
        l_setup_op_res_seq,
        l_resource_id,
        'MIN',
        2,                    -- basis type: PER_LOT
        wor.activity_id,
        wor.standard_rate_flag,
        l_transition_time,      -- usage_rate_or_amount
        1,                      -- scheduled_flag: YES
        wor.assigned_units,
        wor.autocharge_type,
        0,                    -- applied_resource_units
        0,                    -- applied_resource_value
        l_next_start_date - (l_transition_time/1440),
        l_next_start_date,
        l_next_resource_seq_num,
        wor.substitute_group_num,
        wor.replacement_group_num,
        wor.schedule_seq_num
       FROM
        wip_operation_resources wor
       WHERE wor.wip_entity_id = l_next_wip_entity_id
         and wor.organization_id = p_organization_id
         and wor.operation_seq_num = l_next_operation_seq_num
         and wor.resource_seq_num = l_next_resource_seq_num;

	    insert into wip_op_resource_instances
	      (ORGANIZATION_ID,
	       WIP_ENTITY_ID,
	       OPERATION_SEQ_NUM,
	       RESOURCE_SEQ_NUM,
	       INSTANCE_ID,
	       SERIAL_NUMBER,
	       START_DATE,
	       COMPLETION_DATE,
	       LAST_UPDATE_DATE,
	       LAST_UPDATED_BY,
	       CREATION_DATE,
	       CREATED_BY,
	       LAST_UPDATE_LOGIN)
	      select
	       ORGANIZATION_ID,
	       WIP_ENTITY_ID,
	       OPERATION_SEQ_NUM,
	       l_setup_op_res_seq,
	       l_instance_id,
	       l_serial_number,
	       START_DATE,
	       COMPLETION_DATE,
	       SYSDATE,
	       FND_GLOBAL.USER_ID,
	       SYSDATE,
	       FND_GLOBAL.USER_ID,
	       LAST_UPDATE_LOGIN
	      from wip_operation_resources
	     where wip_entity_id = l_next_wip_entity_id
	       and organization_id = p_organization_id
	       and operation_seq_num = l_next_operation_seq_num
	       and resource_seq_num = l_setup_op_res_seq;

	 FOR setup_res_rec in setup_resource_cursor(l_std_op_id) LOOP

	    l_setup_op_res_seq := l_setup_op_res_seq+10;

            INSERT INTO WIP_OPERATION_RESOURCES
	      (last_update_date,
	       last_updated_by,
	       creation_date,
	       created_by,
	       last_update_login,
	       organization_id,
	       wip_entity_id,
	       repetitive_schedule_id,
	       operation_seq_num,
	       resource_seq_num,
	       resource_id,
	       uom_code,
	       basis_type,
	       activity_id,
	       standard_rate_flag,
	       usage_rate_or_amount,
	       scheduled_flag,
	       assigned_units,
	       autocharge_type,
	       applied_resource_units,
	       applied_resource_value,
	       start_date,
	       completion_date,
	       parent_resource_seq,
	       substitute_group_num,
	       replacement_group_num,
	       schedule_seq_num
	       )
	      select
	      SYSDATE,
	      FND_GLOBAL.USER_ID,
	      SYSDATE,
	      FND_GLOBAL.USER_ID,
	      FND_GLOBAL.LOGIN_ID,
	      p_organization_id,
	      l_next_wip_entity_id,
	      NULL,
	      l_next_operation_seq_num,
	      l_setup_op_res_seq,
	      setup_res_rec.resource_id,
	      'MIN',
	      2,                             -- basis type: PER_LOT
	      wor.activity_id,
	      wor.standard_rate_flag,
	      l_transition_time,             -- usage_rate_or_amount
	      setup_res_rec.schedule_flag,   -- scheduled_flag: YES
	      setup_res_rec.assigned_units,
	      wor.autocharge_type,
	      0,                             -- applied_resource_units
	      0,                             -- applied_resource_value
	      decode(setup_res_rec.schedule_flag,
		     1,l_next_start_date - (l_transition_time/1440),
		     l_next_start_date),
	      l_next_start_date,
	      l_next_resource_seq_num,
	      wor.substitute_group_num,
	      wor.replacement_group_num,
	      wor.schedule_seq_num
	      FROM
	      wip_operation_resources wor
	      where wor.wip_entity_id = l_next_wip_entity_id
	      and wor.organization_id = p_organization_id
	      and wor.operation_seq_num = l_next_operation_seq_num
	      and wor.resource_seq_num = l_next_resource_seq_num;

	    l_num_of_instances:= 0;

	    FOR instance_rec in instance_cursor(setup_res_rec.resource_id, setup_res_rec.department_id) LOOP

	       -- inserting a setup op resource instance for a given op resource
	       if (l_num_of_instances < setup_res_rec.assigned_units) then

		  l_num_of_instances := l_num_of_instances + 1;

		  insert into wip_op_resource_instances
		    (ORGANIZATION_ID,
		     WIP_ENTITY_ID,
		     OPERATION_SEQ_NUM,
		     RESOURCE_SEQ_NUM,
		     INSTANCE_ID,
		     SERIAL_NUMBER,
		     START_DATE,
		     COMPLETION_DATE,
		     LAST_UPDATE_DATE,
		     LAST_UPDATED_BY,
		     CREATION_DATE,
		     CREATED_BY,
		     LAST_UPDATE_LOGIN)
		    select
		      ORGANIZATION_ID,
		      WIP_ENTITY_ID,
		      OPERATION_SEQ_NUM,
		      l_setup_op_res_seq,
		      instance_rec.instance_id,
		      instance_rec.serial_number,
		      START_DATE,
		      COMPLETION_DATE,
		      SYSDATE,
		      FND_GLOBAL.USER_ID,
		      SYSDATE,
		      FND_GLOBAL.USER_ID,
		      LAST_UPDATE_LOGIN
		      from wip_operation_resources
		      where wip_entity_id = l_next_wip_entity_id
		      and organization_id = p_organization_id
		      and operation_seq_num = l_next_operation_seq_num
		      and resource_seq_num = l_setup_op_res_seq
		      and parent_resource_seq is not null;
		ELSE
		  exit;
	       END IF;
	    END LOOP;

   END LOOP;
   exit when op_res_instances%NOTFOUND;
   END LOOP;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
     return;
   WHEN OTHERS THEN
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
			      p_count   => x_msg_count,
			      p_data    => x_msg_data);
    x_status := fnd_api.g_ret_sts_error;
    ROLLBACK to start_point;
   RETURN ;



END UPDATE_SETUP_RESOURCES_PVT;



  --
  --
  -- Public Functions
  --

PROCEDURE UPDATE_SETUP_RESOURCES_PUB(p_wip_entity_id         IN NUMBER,
				     p_organization_id       IN NUMBER,
				     x_status                OUT NOCOPY VARCHAR2,
				     x_msg_count             OUT NOCOPY NUMBER,
				     x_msg_data              OUT NOCOPY VARCHAR2)
IS
   CURSOR OPERATION_RESOURCES_CURS(p_wip_entity_id NUMBER) IS
     select wor.operation_seq_num,
            wor.resource_seq_num
       from wip_operation_resources wor
      where wor.wip_entity_id = p_wip_entity_id;


BEGIN

   FOR op_res_rec in OPERATION_RESOURCES_CURS(p_wip_entity_id) LOOP
      UPDATE_SETUP_RESOURCES_PVT(p_wip_entity_id,
				 p_organization_id,
				 op_res_rec.operation_seq_num,
				 op_res_rec.resource_seq_num,
				 x_status,
				 x_msg_count,
				 x_msg_data);
   END LOOP;

END UPDATE_SETUP_RESOURCES_PUB;


PROCEDURE UPDATE_SETUP_RESOURCES_PUB(p_wip_entity_id         IN NUMBER,
                                     p_organization_id       IN NUMBER,
                                     p_list_weid             IN Number_Tbl_Type,
                                     x_status                OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2) IS

BEGIN
  ADD_SCHEDULED_JOBS(p_list_weid);

  UPDATE_SETUP_RESOURCES_PUB(p_wip_entity_id,
			     p_organization_id,
			     x_status,
			     x_msg_count,
			     x_msg_data);

END UPDATE_SETUP_RESOURCES_PUB;


PROCEDURE DELETE_SETUP_RESOURCES_PUB(p_wip_entity_id     IN NUMBER,
				     p_organization_id   IN NUMBER) IS
BEGIN

  -- delete old setup resource instances
  delete from wip_op_resource_instances wori
  where wori.wip_entity_id = p_wip_entity_id
    and wori.organization_id = p_organization_id
    and wori.resource_seq_num in (
				  select resource_seq_num
				  from wip_operation_resources wor
				  where wor.wip_entity_id = p_wip_entity_id
				    and wor.organization_id = p_organization_id
				    and wor.parent_resource_seq is not null);

   -- delete old setup resources
   delete from wip_operation_resources
    where wip_entity_id = p_wip_entity_id
      and organization_id = p_organization_id
      and parent_resource_seq is not null;

END DELETE_SETUP_RESOURCES_PUB;

PROCEDURE ADD_SCHEDULED_JOBS(p_list_weid IN  Number_Tbl_Type) IS
  orig_num_of_records NUMBER;
BEGIN
   orig_num_of_records := g_scheduled_jobs.count;

   FOR i IN 1..p_list_weid.count loop
      if p_list_weid(i) = -1 THEN
	 EXIT;
      end if;
      g_scheduled_jobs(orig_num_of_records + i) := p_list_weid(i);
   END LOOP;

END ADD_SCHEDULED_JOBS;

PROCEDURE DELETE_SCHEDULED_JOBS_TBL IS
BEGIN
   g_scheduled_jobs.delete;

END DELETE_SCHEDULED_JOBS_TBL;


END WIP_UPDATE_SETUP_RESOURCES;

/
