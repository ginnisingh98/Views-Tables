--------------------------------------------------------
--  DDL for Package Body WPS_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WPS_COMMON" AS
/* $Header: wpscommb.pls 120.1 2005/08/30 11:09:15 sjchen noship $ */

  --
  --
  -- Public Functions
  --

-- use this as a separator, need to change because
-- it might not work in language other than english
ESC_CHR VARCHAR(4) := FND_GLOBAL.Local_Chr(27);

FUNCTION Get_Install_Status RETURN VARCHAR2
IS
 l_retval                   BOOLEAN;
 l_status                   VARCHAR2(1);
 l_industry                 VARCHAR2(1);

BEGIN

   l_retval := fnd_installation.get(WPS_APPLICATION_ID,
				    WPS_APPLICATION_ID,
				    l_status,
				    l_industry);

   IF (l_status IN ('I', 'S', 'N')) THEN
      RETURN (l_status);
    ELSE
      RETURN ('N');
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      return('N');

END ;


PROCEDURE GetParameters(p_org_id               IN  NUMBER,
			x_use_finite_scheduler OUT NOCOPY NUMBER,
			x_material_constrained OUT NOCOPY NUMBER,
			x_horizon_length       OUT NOCOPY NUMBER)
 IS
BEGIN

   SELECT
     Nvl(USE_FINITE_SCHEDULER,2),
     Nvl(MATERIAL_CONSTRAINED,2),
     Nvl(HORIZON_LENGTH,1)
   INTO x_use_finite_scheduler,
     x_material_constrained,
     x_horizon_length
   FROM WIP_PARAMETERS
   WHERE ORGANIZATION_ID = p_org_id;


EXCEPTION
   WHEN OTHERS THEN
      x_use_finite_scheduler := 2;
      x_material_constrained := 2;
      x_horizon_length := 1;

END GetParameters;


/*
 *  Procedure that populates the resource availability into
 *  MRP_NET_RESOURCE_AVAIL if not already there.
 */
PROCEDURE Populate_Resource_Avails (p_simulation_set  IN  VARCHAR2,
                                    p_organization_id IN  NUMBER,
                                    p_start_date      IN  DATE,
                                    p_cutoff_date     IN  DATE,
                                    p_wip_entity_id   IN  NUMBER,
                                    p_errnum          OUT NOCOPY NUMBER,
                                    p_errmesg         OUT NOCOPY VARCHAR2,
                                    p_reload          IN  NUMBER)
IS
  x_date_from DATE := trunc(p_start_date);
  x_date_to DATE := trunc(p_cutoff_date);
BEGIN

  p_errnum := 0;
  p_errmesg := 'Success';

  if (p_reload = 0) then  -- check if we want to refresh the data
    -- Check to make sure that if the resource information is already inserted
    -- in MRP_NET_RESOURCE_AVAIL, then no need to call MRP again
    -- The p_start_date, p_cutoff_date can be modified by
    -- resource_info_found_in_mrp function if this function
    -- returns FALSE so that we can get a new from_date to
    -- call MRP_RHX_RESOURCE_AVAILABILITY
    if (resource_info_found_in_mrp(p_simulation_set,
                                   p_organization_id,
                                   x_date_from,
                                   x_date_to)) then
      RETURN;
    end if;
  end if;

  -- information not found in MRP, call MRP
  populate_mrp_avail_resources(
    p_simulation_set => p_simulation_set,
    p_organization_id => p_organization_id,
    p_start_date => x_date_from,
    p_cutoff_date => x_date_to,
    p_wip_entity_id => p_wip_entity_id);

  RETURN ;

EXCEPTION
  WHEN OTHERS THEN
    p_errnum := -1 ;
    p_errmesg := 'Populate_Resource_Avails Failed - ' ||
                 to_char(SQLCODE) || ': ' || SQLERRM;

    RETURN ;

END Populate_Resource_Avails ;

PROCEDURE Populate_Resource_Avails
                                   (p_simulation_set  IN  VARCHAR2,
                                    p_organization_id IN  NUMBER,
                                    p_start_date      IN  DATE,
                                    p_cutoff_date     IN  DATE,
                                    p_resource_table  IN  Number_Tbl_Type,
				    p_dept_table      IN  Number_Tbl_Type,
				    p_24hour_flag_table IN Number_Tbl_Type,
                                    p_errnum          OUT NOCOPY NUMBER,
                                    p_errmesg         OUT NOCOPY VARCHAR2,
                                    p_reload          IN  NUMBER,
				    p_tbl_size        IN  NUMBER,
				    p_delete_data     IN  NUMBER)
IS
     x_date_from DATE := trunc(p_start_date);
     x_date_to DATE := trunc(p_cutoff_date);
     x NUMBER := 1;
BEGIN

  p_errnum := 0;
  p_errmesg := 'Success';

  if (p_reload = 0) then  -- check if we want to refresh the data
    -- Check to make sure that if the resource information is already inserted
    -- in MRP_NET_RESOURCE_AVAIL, then no need to call MRP again
    -- The p_start_date, p_cutoff_date can be modified by
    -- resource_info_found_in_mrp function if this function
    -- returns FALSE so that we can get a new from_date to
    -- call MRP_RHX_RESOURCE_AVAILABILITY
    if (resource_info_found_in_mrp(p_simulation_set,
                                   p_organization_id,
                                   x_date_from,
                                   x_date_to)) then
      RETURN;
    end if;
  end if;

  -- information not found in MRP, call MRP
  if(p_delete_data = 1) then
    delete from mrp_net_resource_avail
    where organization_id = p_organization_id
    and simulation_set = p_simulation_set
    and trunc(shift_date) >= trunc(p_start_date)
    and trunc(shift_date) <= trunc(p_cutoff_date);
  end if;

  LOOP
     EXIT WHEN p_resource_table(x) = 0;

     MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail(p_organization_id,
						  p_dept_table(x),
						  p_resource_table(x),
						  p_simulation_set,
						  p_24hour_flag_table(x),
						  p_start_date,
						  p_cutoff_date);

     x := x+1;



  END LOOP

  RETURN ;

EXCEPTION
  WHEN OTHERS THEN
    p_errnum := -1 ;
    p_errmesg := 'Populate_Resource_Avails Failed - ' ||
                 to_char(SQLCODE) || ': ' || SQLERRM;

    RETURN ;

END Populate_Resource_Avails;


PROCEDURE Populate_Res_Instance_Avails
                                   (p_simulation_set  IN  VARCHAR2,
                                    p_organization_id IN  NUMBER,
                                    p_start_date      IN  DATE,
                                    p_cutoff_date     IN  DATE,
                                    p_wip_entity_id   IN  NUMBER,
                                    p_errnum          OUT NOCOPY NUMBER,
                                    p_errmesg         OUT NOCOPY VARCHAR2,
                                    p_reload          IN  NUMBER)
IS
  x_date_from DATE := trunc(p_start_date);
  x_date_to DATE := trunc(p_cutoff_date);
BEGIN

  p_errnum := 0;
  p_errmesg := 'Success';

  if (p_reload = 0) then  -- check if we want to refresh the data
    -- Check to make sure that if the resource information is already inserted
    -- in MRP_NET_RESOURCE_AVAIL, then no need to call MRP again
    -- The p_start_date, p_cutoff_date can be modified by
    -- resource_info_found_in_mrp function if this function
    -- returns FALSE so that we can get a new from_date to
    -- call MRP_RHX_RESOURCE_AVAILABILITY
    if (resource_info_found_in_mrp(p_simulation_set,
                                   p_organization_id,
                                   x_date_from,
                                   x_date_to)) then
      RETURN;
    end if;
  end if;

  -- information not found in MRP, call MRP
  populate_mrp_avail_res_inst(
    p_simulation_set => p_simulation_set,
    p_organization_id => p_organization_id,
    p_start_date => x_date_from,
    p_cutoff_date => x_date_to,
    p_wip_entity_id => p_wip_entity_id);

  RETURN ;

EXCEPTION
  WHEN OTHERS THEN
    p_errnum := -1 ;
    p_errmesg := 'Populate_Resource_Instance_Avails Failed - ' ||
                 to_char(SQLCODE) || ': ' || SQLERRM;

    RETURN ;

END Populate_Res_Instance_Avails;


PROCEDURE Populate_Res_Instance_Avails
                                   (p_simulation_set  IN  VARCHAR2,
                                    p_organization_id IN  NUMBER,
                                    p_start_date      IN  DATE,
                                    p_cutoff_date     IN  DATE,
				    p_resource_table  IN  Number_Tbl_Type,
				    p_dept_table      IN  Number_Tbl_Type,
				    p_24hour_flag_table IN Number_Tbl_Type,
				    p_instance_table  IN Number_Tbl_Type,
				    p_serial_num_table  IN Varchar30_Tbl_Type,
                                    p_errnum          OUT NOCOPY NUMBER,
                                    p_errmesg         OUT NOCOPY VARCHAR2,
                                    p_reload          IN  NUMBER,
				    p_tbl_size        IN  NUMBER,
				    p_delete_data     IN  NUMBER)
IS
     x_date_from DATE := trunc(p_start_date);
     x_date_to DATE := trunc(p_cutoff_date);
     x NUMBER := 1;

BEGIN
  p_errnum := 0;
  p_errmesg := 'Success';

  if (p_reload = 0) then  -- check if we want to refresh the data
    -- Check to make sure that if the resource information is already inserted
    -- in MRP_NET_RESOURCE_AVAIL, then no need to call MRP again
    -- The p_start_date, p_cutoff_date can be modified by
    -- resource_info_found_in_mrp function if this function
    -- returns FALSE so that we can get a new from_date to
    -- call MRP_RHX_RESOURCE_AVAILABILITY
    if (resource_info_found_in_mrp(p_simulation_set,
                                   p_organization_id,
                                   x_date_from,
                                   x_date_to)) then
      RETURN;
    end if;
  end if;

  -- information not found in MRP, call MRP
  if(p_delete_data = 1) then
    delete from mrp_net_resource_avail
    where organization_id = p_organization_id
    and simulation_set = p_simulation_set
    and trunc(shift_date) >= trunc(p_start_date)
    and trunc(shift_date) <= trunc(p_cutoff_date);
  end if;

  LOOP
     EXIT WHEN p_resource_table(x) = 0;

     wps_res_instance_availability.calc_ins_avail(p_organization_id,
						  p_dept_table(x),
						  p_resource_table(x),
						  p_simulation_set,
						  p_instance_table(x),
						  p_serial_num_table(x),
						  p_24hour_flag_table(x),
						  p_start_date,
						  p_cutoff_date);

     x := x+1;

  END LOOP

  RETURN ;
EXCEPTION
  WHEN OTHERS THEN
    p_errnum := -1 ;
    p_errmesg := 'Populate_Resource_Avails Failed - ' ||
                 to_char(SQLCODE) || ': ' || SQLERRM;

    RETURN ;
END Populate_Res_Instance_Avails;





/*
 *  Procedure that populates the resource availability into
 *  MRP_NET_RESOURCE_AVAIL.
 */
PROCEDURE Populate_Individual_Res_Avails (p_simulation_set  IN  VARCHAR2,
                                          p_organization_id IN  NUMBER,
				          p_resource_id     IN  NUMBER,
                                          p_start_date      IN  DATE,
                                          p_cutoff_date     IN  DATE,
                                          p_errnum          OUT NOCOPY NUMBER,
                                          p_errmesg         OUT NOCOPY VARCHAR2,
                                          p_reload          IN  NUMBER,
					  p_department_id   IN NUMBER)
IS
  x_date_from       DATE := trunc(p_start_date);
  x_date_to         DATE := trunc(p_cutoff_date);

BEGIN

  p_errnum := 0;
  p_errmesg := 'Success';

  IF (p_reload <> 0) then
    -- remove all entries for this resource and repopulate
    delete from mrp_net_resource_avail
     where organization_id = p_organization_id
       and simulation_set = p_simulation_set
       and resource_id = p_resource_id
       and decode(p_department_id,null,-1,department_id) = nvl(p_department_id,-1);
       --and trunc(shift_date) >= trunc(p_start_date)
       --and trunc(shift_date) <= trunc(p_cutoff_date);

  ELSE
    -- Check to make sure that if the resource information is already inserted
    -- in MRP_NET_RESOURCE_AVAIL, then no need to call MRP again
    -- The p_start_date, p_cutoff_date can be modified by
    -- individual_res_info_found_in_mrp function if this function
    -- returns FALSE so that we can get a new from_date and to_date to
    -- call MRP_RHX_RESOURCE_AVAILABILITY
    IF (single_res_info_found_in_mrp(p_simulation_set,
                                     p_organization_id,
	 	       		     p_resource_id,
                                     x_date_from,
                                     x_date_to,
				     p_department_id)) THEN
      RETURN;
    END IF;
  END IF;


  -- information not found in MRP, call MRP
  populate_single_mrp_avail_res(p_simulation_set,
				p_organization_id,
				p_resource_id,
    				x_date_from,
				x_date_to,
				p_department_id);

  RETURN ;

EXCEPTION
  WHEN OTHERS THEN
    p_errnum := -1 ;
    p_errmesg := 'Populate_Individual_Res_Avails Failed - ' ||
                 to_char(SQLCODE) || ': ' || SQLERRM;

    RETURN ;

END Populate_Individual_Res_Avails ;

/*
 *  Procedure that populates the resource availability into
 *  MRP_NET_RESOURCE_AVAIL.
 */
PROCEDURE Populate_Individual_Ins_Avails (p_simulation_set  IN  VARCHAR2,
                                          p_organization_id IN  NUMBER,
				          p_resource_id     IN  NUMBER,
					  p_instance_id     IN  NUMBER,
					  p_serial_number   IN  VARCHAR2,
                                          p_start_date      IN  DATE,
                                          p_cutoff_date     IN  DATE,
                                          p_errnum          OUT NOCOPY NUMBER,
                                          p_errmesg         OUT NOCOPY VARCHAR2,
                                          p_reload          IN  NUMBER,
					  p_department_id   IN NUMBER)
IS
  x_date_from       DATE := trunc(p_start_date);
  x_date_to         DATE := trunc(p_cutoff_date);

BEGIN

  p_errnum := 0;
  p_errmesg := 'Success';

  /*dbms_output.put_line('Populate_Individual_Ins_Avails '||
		       to_char(p_resource_id)|| ': '||
		       to_char(p_instance_id)||': '||
		       p_serial_number||': ' ||
		       to_char(p_start_date)|| '--'||
		       to_char(p_cutoff_date));
 */
  IF (p_reload <> 0) then
    -- remove all entries for this resource and repopulate
    delete from mrp_net_resource_avail
     where organization_id = p_organization_id
       and simulation_set = p_simulation_set
      and resource_id = p_resource_id
      and instance_id = p_instance_id
      and nvl(serial_number,-1) = nvl(p_serial_number,-1)
      and decode(p_department_id,null,-1,department_id) = nvl(p_department_id,-1);
       --and trunc(shift_date) >= trunc(p_start_date)
       --and trunc(shift_date) <= trunc(p_cutoff_date);

  ELSE
    -- Check to make sure that if the resource information is already inserted
    -- in MRP_NET_RESOURCE_AVAIL, then no need to call MRP again
    -- The p_start_date, p_cutoff_date can be modified by
    -- individual_res_info_found_in_mrp function if this function
    -- returns FALSE so that we can get a new from_date and to_date to
    -- call MRP_RHX_RESOURCE_AVAILABILITY
    IF (single_ins_info_found_in_mrp(p_simulation_set,
                                     p_organization_id,
	 	       		     p_resource_id,
				     p_instance_id,
				     p_serial_number,
                                     x_date_from,
                                     x_date_to,
				     p_department_id)) THEN
       -- dbms_output.put_line('record existed in mrp table.');
      RETURN;
    END IF;
  END IF;


  -- information not found in MRP, call MRP
  populate_single_mrp_avail_ins(p_simulation_set,
				p_organization_id,
				p_resource_id,
				p_instance_id,
				p_serial_number,
    				x_date_from,
				x_date_to,
				p_department_id);

  RETURN ;

EXCEPTION
  WHEN OTHERS THEN
    p_errnum := -1 ;
    p_errmesg := 'Populate_Individual_Res_Avails Failed - ' ||
                 to_char(SQLCODE) || ': ' || SQLERRM;

    RETURN ;

END Populate_Individual_Ins_Avails ;

/*
 *  Wrapper on top of MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail.
 *  Basically delete the MRP_NET_RESOURCE_AVAIL table only for the date
 *  range specified by p_start_date and p_cutoff_date and for the passed
 *  in simulation_set identifier.
 */
PROCEDURE populate_mrp_avail_resources(p_simulation_set  IN varchar2,
                                       p_organization_id IN number,
                                       p_start_date      IN date,
                                       p_cutoff_date     IN date,
                                       p_wip_entity_id   IN number)
IS
  x_department_id   NUMBER;
  x_resource_id     NUMBER;
  x_24hr_flag       NUMBER;

  cursor dept_res is
  select  dept_res.department_id,
          dept_res.resource_id,
          NVL(dept_res.available_24_hours_flag, 2)
  from    bom_department_resources dept_res,
          bom_departments dept
  where   dept_res.department_id = dept.department_id
  AND     dept_res.share_from_dept_id is null
  AND     dept.organization_id = p_organization_id;

  cursor wip_res is
  select  distinct nvl(dept_res.share_from_dept_id, dept_res.department_id),
          dept_res.resource_id,
          NVL(dept_res.available_24_hours_flag, 2)
  from    bom_department_resources dept_res,
          wip_operations wo,
          wip_operation_resources wor
  WHERE   wo.wip_entity_id = p_wip_entity_id
    AND   wo.organization_id = p_organization_id
    AND   wor.wip_entity_id = wo.wip_entity_id
    AND   wor.organization_id = wo.organization_id
    AND   wor.operation_seq_num = wo.operation_seq_num
    AND   dept_res.department_id = nvl(wor.department_id, wo.department_id)
    AND   dept_res.resource_id = wor.resource_id
  union
  select  distinct nvl(dept_res.share_from_dept_id, dept_res.department_id),
          dept_res.resource_id,
          NVL(dept_res.available_24_hours_flag, 2)
  from    bom_department_resources dept_res,
          wip_operations wo,
          wip_sub_operation_resources wsor
  WHERE   wo.wip_entity_id = p_wip_entity_id
    AND   wo.organization_id = p_organization_id
    AND   wsor.wip_entity_id = wo.wip_entity_id
    AND   wsor.organization_id = wo.organization_id
    AND   wsor.operation_seq_num = wo.operation_seq_num
    AND   dept_res.department_id = nvl(wsor.department_id, wo.department_id)
    AND   dept_res.resource_id = wsor.resource_id
  union
  select  distinct bdr.department_id department_id,
          bdr.resource_id,
          nvl(bdr.available_24_hours_flag, 2)
  from    bom_std_op_resources bsor,
          bom_standard_operations bso,
          bom_department_resources bdr,
          bom_setup_transitions bst,
          wip_operation_resources wor
  WHERE   wor.organization_id = p_organization_id
    AND   wor.wip_entity_id = p_wip_entity_id
    AND   wor.setup_id is not null
    AND   bst.resource_id = wor.resource_id
    AND   bst.to_setup_id = wor.setup_id
    AND   bso.standard_operation_id = bst.operation_id
    AND   bsor.standard_operation_id = bso.standard_operation_id
    AND   bdr.department_id = bso.department_id
    AND   bdr.resource_id = bsor.resource_id
 union
 select   distinct nvl(dept_res.share_from_dept_id, dept_res.department_id),
          dept_res.resource_id,
          NVL(dept_res.available_24_hours_flag, 2)
   from   bom_department_resources dept_res,
          wip_sub_operation_resources wsor,
          bom_setup_transitions bst,
          bom_standard_operations bso,
          bom_std_op_resources bsor
  where   wsor.wip_entity_id = p_wip_entity_id
    and   wsor.organization_id = p_organization_id
    and   wsor.setup_id is not null
    and   bst.resource_id = wsor.resource_id
    and   bst.to_setup_id = wsor.setup_id
    and   bso.standard_operation_id = bst.operation_id
    and   bsor.standard_operation_id = bso.standard_operation_id
    and   dept_res.department_id = bso.department_id
    and   dept_res.resource_id = bsor.resource_id;



BEGIN
  -- clean up the table for the date range first
  delete from mrp_net_resource_avail
   where organization_id = p_organization_id
     and simulation_set = p_simulation_set
     and trunc(shift_date) >= trunc(p_start_date)
     and trunc(shift_date) <= trunc(p_cutoff_date);

  -- open the cursor and loop through each department resource and call
  -- MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail to insert resource
  -- availability information into MRP_NET_RESOURCE_AVAIL
  IF (p_wip_entity_id IS NULL) THEN
    OPEN dept_res;
    LOOP
      FETCH dept_res into x_department_id,
                          x_resource_id,
                          x_24hr_flag;
      EXIT WHEN dept_res%NOTFOUND;
      MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail(p_organization_id,
                                                   x_department_id,
                                                   x_resource_id,
                                                   p_simulation_set,
                                                   x_24hr_flag,
                                                   p_start_date,
                                                   p_cutoff_date);
    END LOOP;
    CLOSE dept_res;
  ELSE
    OPEN wip_res;
    LOOP
      FETCH wip_res into x_department_id,
                         x_resource_id,
                         x_24hr_flag;
      EXIT WHEN wip_res%NOTFOUND;
      MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail(p_organization_id,
                                                   x_department_id,
                                                   x_resource_id,
                                                   p_simulation_set,
                                                   x_24hr_flag,
                                                   p_start_date,
                                                   p_cutoff_date);
    END LOOP;
    CLOSE wip_res;
  END IF;
END populate_mrp_avail_resources;


/*
 *  Wrapper on top of wps_res_instance_availability.calc_ins_avail.
 *  Basically delete the MRP_NET_RESOURCE_AVAIL table only for the date
 *  range specified by p_start_date and p_cutoff_date and for the passed
 *  in simulation_set identifier.
 */
PROCEDURE populate_mrp_avail_res_inst
                                      (p_simulation_set  IN varchar2,
                                       p_organization_id IN number,
                                       p_start_date      IN date,
                                       p_cutoff_date     IN date,
                                       p_wip_entity_id   IN number)
IS
  x_department_id   NUMBER;
  x_resource_id     NUMBER;
  x_instance_id     NUMBER;
  x_serial_number   VARCHAR2(30);
  x_24hr_flag       NUMBER;

  cursor dept_ins is
  select  dept_ins.department_id,
          NVL(dept_res.available_24_hours_flag, 2),
          dept_ins.resource_id,
          dept_ins.instance_id,
          dept_ins.serial_number
  from    bom_dept_res_instances dept_ins,
          bom_department_resources dept_res,
          bom_departments dept
  where   dept_res.department_id = dept.department_id
    AND   dept_res.share_from_dept_id is null
    AND   dept_ins.resource_id = dept_res.resource_id
    AND   dept_ins.department_id = dept_res.department_id
    AND   dept.organization_id = p_organization_id;


  cursor wip_res is
  select  distinct nvl(dept_res.share_from_dept_id, dept_res.department_id),
          NVL(dept_res.available_24_hours_flag, 2),
          dept_res.resource_id,
          dept_ins.instance_id,
          dept_ins.serial_number
  from    bom_department_resources dept_res,
          bom_dept_res_instances dept_ins,
          wip_operations wo,
          wip_operation_resources wor
  WHERE   wo.wip_entity_id = p_wip_entity_id
    AND   wo.organization_id = p_organization_id
    AND   wor.wip_entity_id = wo.wip_entity_id
    AND   wor.organization_id = wo.organization_id
    AND   wor.operation_seq_num = wo.operation_seq_num
    AND   dept_res.department_id = nvl(wor.department_id, wo.department_id)
    AND   dept_res.resource_id = wor.resource_id
    AND   dept_ins.department_id = dept_res.department_id
    AND   dept_ins.resource_id = dept_res.resource_id
  union
  select  distinct nvl(dept_res.share_from_dept_id, dept_res.department_id),
          NVL(dept_res.available_24_hours_flag, 2),
          dept_res.resource_id,
          ins_changes.instance_id,
          ins_changes.serial_number
  from    bom_department_resources dept_res,
          bom_res_instance_changes ins_changes,
          wip_operations wo,
          wip_operation_resources wor
  WHERE   wo.wip_entity_id = p_wip_entity_id
    AND   wo.organization_id = p_organization_id
    AND   wor.wip_entity_id = wo.wip_entity_id
    AND   wor.organization_id = wo.organization_id
    AND   wor.operation_seq_num = wo.operation_seq_num
    AND   dept_res.department_id = nvl(wor.department_id, wo.department_id)
    AND   dept_res.resource_id = wor.resource_id
    AND   ins_changes.department_id = dept_res.department_id
    AND   ins_changes.resource_id = dept_res.resource_id
    AND   not exists
    ( select 1
      from bom_dept_res_instances dept_ins
      where dept_ins.department_id = ins_changes.department_id
      and   dept_ins.resource_id = ins_changes.resource_id
      and   dept_ins.instance_id = ins_changes.instance_id
      and   nvl(dept_ins.serial_number, -1) = nvl(ins_changes.serial_number, -1))
  union
  select  distinct nvl(dept_res.share_from_dept_id, dept_res.department_id),
          NVL(dept_res.available_24_hours_flag, 2),
          dept_res.resource_id,
          dept_ins.instance_id,
          dept_ins.serial_number
  from    bom_department_resources dept_res,
          bom_dept_res_instances dept_ins,
          wip_operations wo,
          wip_sub_operation_resources wsor
  WHERE   wo.wip_entity_id = p_wip_entity_id
    AND   wo.organization_id = p_organization_id
    AND   wsor.wip_entity_id = wo.wip_entity_id
    AND   wsor.organization_id = wo.organization_id
    AND   wsor.operation_seq_num = wo.operation_seq_num
    AND   dept_res.department_id = nvl(wsor.department_id, wo.department_id)
    AND   dept_res.resource_id = wsor.resource_id
    AND   dept_ins.department_id = dept_res.department_id
    AND   dept_ins.resource_id = dept_res.resource_id
  union
 select   distinct nvl(dept_res.share_from_dept_id, dept_res.department_id),
          NVL(dept_res.available_24_hours_flag, 2),
          dept_res.resource_id,
          dept_ins.instance_id,
          dept_ins.serial_number
   from   bom_department_resources dept_res,
          bom_dept_res_instances dept_ins,
          wip_operation_resources wor,
          bom_setup_transitions bst,
          bom_standard_operations bso,
          bom_std_op_resources bsor
  where   wor.wip_entity_id = p_wip_entity_id
    and   wor.organization_id = p_organization_id
    and   wor.setup_id is not null
    and   bst.resource_id = wor.resource_id
    and   bst.to_setup_id = wor.setup_id
    and   bso.standard_operation_id = bst.operation_id
    and   bsor.standard_operation_id = bso.standard_operation_id
    and   dept_res.department_id = bso.department_id
    and   dept_res.resource_id = bsor.resource_id
    AND   dept_ins.department_id = dept_res.department_id
    AND   dept_ins.resource_id = dept_res.resource_id
 union
 select   distinct nvl(dept_res.share_from_dept_id, dept_res.department_id),
          NVL(dept_res.available_24_hours_flag, 2),
          dept_res.resource_id,
          dept_ins.instance_id,
          dept_ins.serial_number
   from   bom_department_resources dept_res,
          bom_dept_res_instances dept_ins,
          wip_sub_operation_resources wsor,
          bom_setup_transitions bst,
          bom_standard_operations bso,
          bom_std_op_resources bsor
  where   wsor.wip_entity_id = p_wip_entity_id
    and   wsor.organization_id = p_organization_id
    and   wsor.setup_id is not null
    and   bst.resource_id = wsor.resource_id
    and   bst.to_setup_id = wsor.setup_id
    and   bso.standard_operation_id = bst.operation_id
    and   bsor.standard_operation_id = bso.standard_operation_id
    and   dept_res.department_id = bso.department_id
    and   dept_res.resource_id = bsor.resource_id
    AND   dept_ins.department_id = dept_res.department_id
    AND   dept_ins.resource_id = dept_res.resource_id;



BEGIN
  -- clean up the table for the date range first
  delete from mrp_net_resource_avail
   where organization_id = p_organization_id
     and simulation_set = p_simulation_set
     and trunc(shift_date) >= trunc(p_start_date)
     and trunc(shift_date) <= trunc(p_cutoff_date);

  -- open the cursor and loop through each department resource and call
  -- MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail to insert resource
  -- availability information into MRP_NET_RESOURCE_AVAIL
  IF (p_wip_entity_id IS NULL) THEN
    OPEN dept_ins;
    LOOP
      FETCH dept_ins into x_department_id,
	                  x_24hr_flag,
                          x_resource_id,
	                  x_instance_id,
	                  x_serial_number;
      EXIT WHEN dept_ins%NOTFOUND;
      wps_res_instance_availability.calc_ins_avail(p_organization_id,
                                                   x_department_id,
                                                   x_resource_id,
		  				   p_simulation_set,
						   x_instance_id,
						   x_serial_number,
                                                   x_24hr_flag,
                                                   p_start_date,
                                                   p_cutoff_date);
    END LOOP;
    CLOSE dept_ins;
  ELSE
    OPEN wip_res;
    LOOP
       FETCH wip_res into x_department_id,
                  	  x_24hr_flag,
	                  x_resource_id,
	                  x_instance_id,
	                  x_serial_number;
       EXIT WHEN wip_res%NOTFOUND;

      wps_res_instance_availability.calc_ins_avail(p_organization_id,
                                                   x_department_id,
                                                   x_resource_id,
		  				   p_simulation_set,
						   x_instance_id,
						   x_serial_number,
                                                   x_24hr_flag,
                                                   p_start_date,
                                                   p_cutoff_date);
    END LOOP;
    CLOSE wip_res;
  END IF;
END populate_mrp_avail_res_inst;



/*
 *  Wrapper on top of MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail.
 *  Basically delete the MRP_NET_RESOURCE_AVAIL table only for the date
 *  range specified by p_start_date and p_cutoff_date and for the passed
 *  in simulation_set identifier.
 */
PROCEDURE populate_single_mrp_avail_res(p_simulation_set  IN varchar2,
                                        p_organization_id IN number,
					p_resource_id     IN number,
                                        p_start_date      IN date,
	                                p_cutoff_date     IN date,
					p_department_id   IN NUMBER)
IS
  x_department_id   NUMBER;
  x_resource_id     NUMBER;
  x_24hr_flag       NUMBER;

  cursor dept_res is
  select  dept_res.department_id,
          NVL(dept_res.available_24_hours_flag, 2)
  from    bom_department_resources dept_res,
          bom_departments dept
  where   dept_res.department_id = dept.department_id
  AND     dept_res.resource_id = p_resource_id
  AND     dept_res.share_from_dept_id is null
  AND     dept.organization_id = p_organization_id
  AND     decode(p_department_id,null,-1,dept.department_id) = nvl(p_department_id,-1);

BEGIN
  -- open the cursor and loop through each department resource and call
  -- MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail to insert resource
  -- availability information into MRP_NET_RESOURCE_AVAIL
  OPEN dept_res;
  LOOP
    FETCH dept_res into x_department_id,
                        x_24hr_flag;
    EXIT WHEN dept_res%NOTFOUND;
    MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail(p_organization_id,
                                                 x_department_id,
                                                 p_resource_id,
                                                 p_simulation_set,
                                                 x_24hr_flag,
                                                 p_start_date,
                                                 p_cutoff_date);
  END LOOP;
  CLOSE dept_res;

  RETURN;

END populate_single_mrp_avail_res;

/*
 *  Wrapper on top of MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail.
 *  Basically delete the MRP_NET_RESOURCE_AVAIL table only for the date
 *  range specified by p_start_date and p_cutoff_date and for the passed
 *  in simulation_set identifier.
 */
PROCEDURE populate_single_mrp_avail_ins(p_simulation_set  IN varchar2,
                                        p_organization_id IN number,
					p_resource_id     IN number,
					p_instance_id     IN number,
					p_serial_number   IN varchar2,
                                        p_start_date      IN date,
	                                p_cutoff_date     IN date,
					p_department_id   IN NUMBER)
IS
  x_department_id   NUMBER;
  x_resource_id     NUMBER;
  x_24hr_flag       NUMBER;

  cursor dept_ins is
  select  dept_ins.department_id,
          NVL(dept_res.available_24_hours_flag, 2)
  from    bom_dept_res_instances dept_ins,
          bom_department_resources dept_res,
          bom_departments dept
  where   dept_ins.department_id = dept.department_id
  AND     dept_res.department_id = dept_ins.department_id
  and     dept_res.resource_id = p_resource_id
  AND     dept_ins.resource_id = p_resource_id
  AND     dept_ins.instance_id = p_instance_id
  AND     dept.organization_id = p_organization_id
  AND     decode(p_department_id,null,-1,dept.department_id) = nvl(p_department_id,-1);

BEGIN
  -- open the cursor and loop through each department resource and call
  -- MRP_RHX_RESOURCE_AVAILABILITY.calc_res_avail to insert resource
   -- availability information into MRP_NET_RESOURCE_AVAIL
   -- dbms_output.put_line('In populate single mrp avail ins.......');

  OPEN dept_ins;
  LOOP
    FETCH dept_ins into x_department_id,
                        x_24hr_flag;
    EXIT WHEN dept_ins%NOTFOUND;
    wps_res_instance_availability.calc_ins_avail(p_organization_id,
                                                 x_department_id,
                                                 p_resource_id,
						 p_simulation_set,
						 p_instance_id,
						 p_serial_number,
                                                 x_24hr_flag,
                                                 p_start_date,
                                                 p_cutoff_date);
  END LOOP;
  CLOSE dept_ins;

  RETURN;

END populate_single_mrp_avail_ins;

/*
 *  Function that checks against the MRP_NET_RESOURCE_AVAIL to see
 *  if the resource availability for the organization is already populated.
 *  If not, returns the p_from_date to the latest date in the table so
 *  that the caller can use the p_date_from and p_date_to to call MRP to
 *  populate the missing data
 */
FUNCTION resource_info_found_in_mrp(p_simulation_set    IN      VARCHAR2,
                                    p_organization_id   IN      NUMBER,
                                    p_date_from         IN OUT NOCOPY DATE,
                                    p_date_to           IN OUT NOCOPY DATE)
RETURN BOOLEAN IS
  max_date_from DATE;
  max_date_to   DATE;
  status        BOOLEAN := TRUE;
BEGIN

  -- fetch the max shift_date and min shift_date from mrp_net_resource_avail
  -- for the specified org and simulation set
  select trunc(min(shift_date)), trunc(max(shift_date))
    into max_date_from, max_date_to
    from mrp_net_resource_avail
   where organization_id = p_organization_id
     and simulation_set = p_simulation_set;

  if (max_date_from is NULL) then
    return FALSE;
  end if;

  -- compare and see if the passed in start and from date are in the
  -- mrp_net_resource_avail or not, if not, set p_date_from and p_date_to
  -- to cover the date range that are not already in the mrp table
  if (p_date_from < max_date_from) then
    status := FALSE;
    if (p_date_to <= max_date_to) then
      p_date_to := max_date_from-1;
    end if;
  elsif (p_date_to > max_date_to) then
    status := FALSE;
    p_date_from := max_date_to+1;
  end if;

  RETURN status;

END resource_info_found_in_mrp;

/*
 *  Function that checks against the MRP_NET_RESOURCE_AVAIL to see
 *  if the resource availability for the organization is already populated.
 *  If not, returns the p_from_date to the latest date in the table so
 *  that the caller can use the p_date_from and p_date_to to call MRP to
 *  populate the missing data.
 *  Same as resource_info_found_in_mrp but for one resource.
 */
FUNCTION single_res_info_found_in_mrp(p_simulation_set    IN      VARCHAR2,
                                      p_organization_id   IN      NUMBER,
                	              p_resource_id	  IN      NUMBER,
                                      p_date_from         IN OUT NOCOPY  DATE,
                                      p_date_to           IN OUT NOCOPY  DATE,
				      p_department_id     IN NUMBER)
RETURN BOOLEAN IS
  max_date_from DATE;
  max_date_to   DATE;
  status        BOOLEAN := TRUE;
BEGIN

  -- fetch the max shift_date and min shift_date from mrp_net_resource_avail
  -- for the specified org and simulation set
  select trunc(min(shift_date)), trunc(max(shift_date))
    into max_date_from, max_date_to
    from mrp_net_resource_avail
   where organization_id = p_organization_id
    and simulation_set = p_simulation_set
    and resource_id = p_resource_id
    and instance_id is null
    and decode(p_department_id,null,-1,department_id) = nvl(p_department_id,-1);

  if (max_date_from is NULL) then
    return FALSE;
  end if;

  -- compare and see if the passed in start and from date are in the
  -- mrp_net_resource_avail or not, if not, set p_date_from and p_date_to
  -- to cover the date range that are not already in the mrp table
  if (p_date_from < max_date_from) then
    status := FALSE;
    if (p_date_to <= max_date_to) then
      p_date_to := max_date_from-1;
    end if;
  elsif (p_date_to > max_date_to) then
    status := FALSE;
    p_date_from := max_date_to+1;
  end if;

  RETURN status;

END single_res_info_found_in_mrp;

/*
 *  Function that checks against the MRP_NET_RESOURCE_AVAIL to see
 *  if the resource availability for the organization is already populated.
 *  If not, returns the p_from_date to the latest date in the table so
 *  that the caller can use the p_date_from and p_date_to to call MRP to
 *  populate the missing data.
 *  Same as resource_info_found_in_mrp but for one resource.
 */
FUNCTION single_ins_info_found_in_mrp(p_simulation_set    IN      VARCHAR2,
                                      p_organization_id   IN      NUMBER,
                	              p_resource_id	  IN      NUMBER,
				      p_instance_id       IN      NUMBER,
				      p_serial_number     IN      VARCHAR2,
                                      p_date_from         IN OUT NOCOPY  DATE,
                                      p_date_to           IN OUT NOCOPY  DATE,
				      p_department_id     IN NUMBER)
RETURN BOOLEAN IS
  max_date_from DATE;
  max_date_to   DATE;
  status        BOOLEAN := TRUE;
BEGIN

  -- fetch the max shift_date and min shift_date from mrp_net_resource_avail
  -- for the specified org and simulation set
  select trunc(min(shift_date)), trunc(max(shift_date))
    into max_date_from, max_date_to
    from mrp_net_resource_avail
   where organization_id = p_organization_id
     and simulation_set = p_simulation_set
    and resource_id = p_resource_id
    and instance_id = p_instance_id
    and nvl(serial_number, -1)= nvl(p_serial_number, -1)
    and decode(p_department_id,null,-1,department_id) = nvl(p_department_id,-1);

  if (max_date_from is NULL) then
    return FALSE;
  end if;

  -- compare and see if the passed in start and from date are in the
  -- mrp_net_resource_avail or not, if not, set p_date_from and p_date_to
  -- to cover the date range that are not already in the mrp table
  if (p_date_from < max_date_from) then
    status := FALSE;
    if (p_date_to <= max_date_to) then
      p_date_to := max_date_from-1;
    end if;
  elsif (p_date_to > max_date_to) then
    status := FALSE;
    p_date_from := max_date_to+1;
  end if;

  RETURN status;

END single_ins_info_found_in_mrp;

PROCEDURE INCREMENT_BATCH_SEQ(NUMBER_OF_NEW_BATCHES NUMBER) IS
   dummy NUMBER;
BEGIN
   for i in 1..NUMBER_OF_NEW_BATCHES loop
      SELECT WIP_PROCESSING_BATCH_S.NEXTVAL INTO dummy  FROM DUAL;
   end loop;

END increment_batch_seq;


function submit_shopfloor_sched_request
(
  p_org_id IN NUMBER,
  p_scheduling_mode IN NUMBER,
  p_direction IN NUMBER,
  p_use_substiture_resource IN NUMBER,
  p_entity_type IN NUMBER,
  p_firm_window_date IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
) return NUMBER
IS
   l_request_id NUMBER;

   PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  l_request_id :=
    submit_scheduling_request
    (
      p_org_id => p_org_id,
      p_scheduling_mode => p_scheduling_mode, -- 2 all jobs, 3 Pending
      p_wip_entity_id => -1, -- all jobs?
      p_direction => p_direction,  -- 1 backward, 2 forward
      p_midpt_operation => '-1',
      p_start_date => null,
      p_end_date => null,
      p_horizon_start => null,
      p_horizon_length => -1,
      p_resource_constraint => -1,
      p_material_constraint => -1,
      p_connect_to_comm => '0',
      p_ip_address => '',
      p_port_number => null,
      p_user_id => null,
      p_ident => null,
      p_use_substiture_resource => p_use_substiture_resource,
      p_chosen_operation => '-1',
      p_chosen_subset_group => '-1',
      p_entity_type => p_entity_type,
      p_midpt_op_res => '-1',
      p_instance_id => '-1',
      p_serial_number => '',
      p_firm_window_date => p_firm_window_date,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    );

    commit;
  return l_request_id;
END submit_shopfloor_sched_request;

function submit_scheduling_request
(
  p_org_id IN NUMBER,
  p_scheduling_mode IN NUMBER,
  p_wip_entity_id IN NUMBER,
  p_direction IN NUMBER,
  p_midpt_operation IN VARCHAR2,
  p_start_date IN DATE,
  p_end_date IN DATE,
  p_horizon_start IN DATE,
  p_horizon_length IN NUMBER,
  p_resource_constraint IN NUMBER,
  p_material_constraint IN NUMBER,
  p_connect_to_comm IN VARCHAR2,
  p_ip_address IN VARCHAR2,
  p_port_number IN NUMBER,
  p_user_id IN NUMBER,
  p_ident IN NUMBER,
  p_use_substiture_resource IN NUMBER,
  p_chosen_operation IN VARCHAR2,
  p_chosen_subset_group IN VARCHAR2,
  p_entity_type IN NUMBER,
  p_midpt_op_res IN VARCHAR2,
  p_instance_id IN VARCHAR2,
  p_serial_number IN VARCHAR2,
  p_firm_window_date IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
) return NUMBER
IS

g_app_short_name VARCHAR2(10) := 'WPS';
g_scheduer_program VARCHAR2(10) := 'WPCWFS';
g_req_description VARCHAR2(255) := 'Schedule Work Order';

l_request_id NUMBER;
BEGIN

null;
  l_request_id :=
    FND_REQUEST.SUBMIT_REQUEST
    (
      g_app_short_name,
      g_scheduer_program,
      g_req_description,
      '',
      false,
      to_char(p_org_id),               -- arg 1:
      to_char(p_scheduling_mode),
      to_char(p_wip_entity_id),
      to_char(p_direction),
      p_midpt_operation,
      Nvl(fnd_number.number_to_canonical(wip_datetimes.dt_to_float(p_start_date)), '-1'),
      Nvl(fnd_number.number_to_canonical(wip_datetimes.dt_to_float(p_end_date)), '-1'),
      to_char(Nvl(wip_datetimes.dt_to_float(p_horizon_start),-1)),
      to_char(p_horizon_length),
      to_char(p_resource_constraint),  -- arg 10
      to_char(p_material_constraint),
      p_connect_to_comm,
      p_ip_address,
      to_char(p_port_number),
      to_char(p_user_id),
      to_char(p_ident),
      to_char(p_use_substiture_resource),
      p_chosen_operation,
      p_chosen_subset_group,
      to_char(p_entity_type),          -- arg 20
      p_midpt_op_res,
      p_instance_id,
      p_serial_number,
      p_firm_window_date,
      chr(0),                          -- arg 25, end
      '','','','','',
      '','','','','','','','','','',
      '','','','','','','','','','',
      '','','','','','','','','','',
      '','','','','','','','','','',
      '','','','','','','','','','',
      '','','','','','','','','','',
      '','','','','','','','','','');
  return l_request_id;
EXCEPTION
  WHEN OTHERS THEN
  x_msg_data := sqlerrm;
  x_return_status := FND_API.g_Ret_Sts_Unexp_Error;
  x_msg_count := 1;
END submit_scheduling_request;

function submit_launch_sched_request
  (
   p_connect_to_comm IN VARCHAR2,
   p_ip_address IN VARCHAR2,
   p_port_number IN VARCHAR2,
   p_user_id IN VARCHAR2,
   p_ident IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data OUT NOCOPY VARCHAR2
   ) return NUMBER
IS

g_app_short_name VARCHAR2(10) := 'WPS';
g_scheduer_program VARCHAR2(10) := 'WPCCBS';
g_req_description VARCHAR2(255) := '';

l_request_id NUMBER;

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

   null;

  l_request_id := FND_REQUEST.SUBMIT_REQUEST
    (
      g_app_short_name,        -- application
      g_scheduer_program,      -- program
      g_req_description,       -- description
      '',                      -- start_time
      false,                   -- sub_request
      '',                      -- arg 1
      '',                      -- arg 2
      '',                      -- arg 3
      '',                      -- arg 4
      '',                      -- arg 5
      '',                      -- arg 6
      '',                      -- arg 7
      '',                      -- arg 8
      '',                      -- arg 9
      '',                      -- arg 10
      '',                      -- arg 11
      p_connect_to_comm,       -- arg 12
      p_ip_address,            -- arg 13
      p_port_number,           -- arg 14
      p_user_id,               -- arg 15
      p_ident,                 -- arg 16
      chr(0),                  -- arg 17
      '','','',                -- arg 18, 19, 20
      '','','','','','','','','','',  -- arg 21 to end
      '','','','','','','','','','',
      '','','','','','','','','','',
      '','','','','','','','','','',
      '','','','','','','','','','',
      '','','','','','','','','','',
      '','','','','','','','','','',
      '','','','','','','','','','');
  commit;
    return l_request_id;
EXCEPTION
  WHEN OTHERS THEN
  x_msg_data := sqlerrm;
  x_return_status := FND_API.g_Ret_Sts_Unexp_Error;
  x_msg_count := 1;
END submit_launch_sched_request;

function get_request_status
(
  p_request_id     IN NUMBER,
  p_app_name       IN VARCHAR2,
  p_program        IN VARCHAR2,
  x_request_id     OUT NOCOPY NUMBER,
  x_phase          OUT NOCOPY VARCHAR2,
  x_status         OUT NOCOPY VARCHAR2,
  x_dev_phase      OUT NOCOPY VARCHAR2,
  x_dev_status     OUT NOCOPY VARCHAR2,
  x_message        OUT NOCOPY VARCHAR2
)   RETURN VARCHAR2
IS
  result boolean;
  retVal VARCHAR2(2);
begin

  x_request_id := p_request_id;
  -- Call the function
  result := fnd_concurrent.get_request_status(
              request_id => x_request_id,
              appl_shortname => p_app_name,
              program => p_program,
              phase => x_phase,
              status => x_status,
              dev_phase => x_dev_phase,
              dev_status => x_dev_status,
              message => x_message);

  retVal := to_char(sys.diutil.bool_to_int(result));

  return retVal;
END get_request_status;


PROCEDURE get_scheduling_param_options
(
  x_forward OUT NOCOPY VARCHAR2,
  x_backward OUT NOCOPY VARCHAR2,
  x_yes OUT NOCOPY VARCHAR2,
  x_no OUT NOCOPY VARCHAR2
) IS

CURSOR c_dir IS
  SELECT MEANING
  FROM MFG_LOOKUPS
  WHERE LOOKUP_TYPE = 'WIP_SCHED_DIRECTION'
    AND ENABLED_FLAG = 'Y'
    AND sysdate BETWEEN
      NVL(START_DATE_ACTIVE, sysdate-1) AND NVL(END_DATE_ACTIVE, sysdate + 1)
    AND LOOKUP_CODE IN (1,4)
  ORDER BY LOOKUP_CODE;

CURSOR c_yesno IS
  SELECT MEANING
  FROM MFG_LOOKUPS
  WHERE LOOKUP_TYPE = 'SYS_YES_NO'
    AND ENABLED_FLAG = 'Y'
    AND sysdate BETWEEN
      NVL(START_DATE_ACTIVE, sysdate-1) AND NVL(END_DATE_ACTIVE, sysdate + 1)
  ORDER BY LOOKUP_CODE;

BEGIN

  open c_dir;
  fetch c_dir into x_forward;
  fetch c_dir into x_backward;
  close c_dir;

  open c_yesno;
  fetch c_yesno into x_yes;
  fetch c_yesno into x_no;
  close c_yesno;

EXCEPTION WHEN OTHERS THEN
  null;
END get_scheduling_param_options;


function job_has_customer(p_wip_entity_id IN NUMBER, p_cust_name IN VARCHAR2)
return VARCHAR2
IS

ret VARCHAR2(1);
BEGIN
  ret := 'F';

  if (p_cust_name is not null) then
    begin
      select 'T'
      into ret
      from dual
      where exists (
        select 1
        from hz_cust_accounts hca, hz_parties hp,
             mtl_reservations mr,  oe_order_lines_all ool
        where mr.demand_source_line_id = ool.line_id
          and mr.demand_source_type_id = 2
          and mr.supply_source_type_id = 5
          and hp.party_name like p_cust_name
          and hca.cust_account_id = ool.sold_to_org_id
          and hp.party_id = hca.party_id
          and mr.supply_source_header_id = p_wip_entity_id
       );
     exception when others then
       null;
     end;
  end if;
  return ret;

end job_has_customer;

function job_has_sales_order(p_wip_entity_id IN NUMBER, p_so_name IN VARCHAR2)
return VARCHAR2
IS

ret VARCHAR2(1);
BEGIN
  ret := 'F';

  if (p_so_name is not null) then
      select 'T'
      into ret
      from dual
      where exists (
        select 1
        from mtl_reservations mr , mtl_sales_orders mso
        where mso.sales_order_id = mr.demand_source_header_id
           and mr.demand_source_type_id = 2
           and mr.supply_source_type_id = 5
           and mso.segment1 like p_so_name
           and mr.supply_source_header_id = p_wip_entity_id
       );
  end if;
  return ret;

end job_has_sales_order;

function get_cust_so_info(p_wip_entity_id IN NUMBER)
return VARCHAR2
IS

cust_name VARCHAR2(1024);
so_name VARCHAR2(256);
cust_cnt  NUMBER;
so_cnt NUMBER;
so_id NUMBER;
cust_id NUMBER;

BEGIN
  cust_name := '';
  so_name := '';

  select count(distinct ool.sold_to_org_id), count(distinct mr.demand_source_header_id)
  into cust_cnt, so_cnt
  from mtl_reservations mr, oe_order_lines_all ool, wip_discrete_jobs wdj
  where mr.demand_source_line_id = ool.line_id
    and mr.demand_source_type_id = 2
    and mr.supply_source_type_id = 5
    and mr.supply_source_header_id = p_wip_entity_id
    and wdj.wip_entity_id = p_wip_entity_id
    and wdj.organization_id = mr.organization_id
    and mr.inventory_item_id = wdj.primary_item_id;

  if ( cust_cnt >0 ) then -- so_cnt should >0 too
    select mso.segment1, hp.party_name
    into so_name, cust_name
    from mtl_reservations mr, oe_order_lines_all ool,
         hz_cust_accounts hca, hz_parties hp,
         mtl_sales_orders mso
    where mr.demand_source_line_id = ool.line_id
      and mr.demand_source_type_id = 2
      and mr.supply_source_type_id = 5
      and hca.cust_account_id = ool.sold_to_org_id
      and hp.party_id = hca.party_id
      and mso.sales_order_id = mr.demand_source_header_id
      and mr.supply_source_header_id = p_wip_entity_id
      and rownum = 1;
  end if;

  return cust_cnt || ESC_CHR || so_cnt || ESC_CHR || cust_name || ESC_CHR || so_name;

end get_cust_so_info;

function cancel_request(request_id in NUMBER,
		        message out NOCOPY VARCHAR2)
return number IS
  success BOOLEAN;

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN
  success := fnd_concurrent.cancel_request(request_id, message);

  commit;

  if success then
     return 1;
  else
     return 0;
  end if;

end cancel_request;




procedure update_scheduling_request_id(p_request_id in NUMBER,
				       p_wip_entity_id IN NUMBER,
				       p_organization_id IN NUMBER)
  IS
     RESOURCE_BUSY EXCEPTION;
     PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -00054);

     cursor lock_curs  is
      select wip_entity_id
      from wip_discrete_jobs
      where wip_entity_id = p_wip_entity_id
	and organization_id = p_organization_id
      for update nowait;

   l_wid NUMBER;

begin

   select wip_entity_id
     into l_wid
     from wip_discrete_jobs
     where wip_entity_id = p_wip_entity_id
     and organization_id = p_organization_id
     for update nowait;

   --open lock_curs;

   --fetch lock_curs into l_wid;

   --close lock_curs;

   update wip_discrete_jobs
   set scheduling_request_id = p_request_id
   where wip_entity_id = p_wip_entity_id
     and organization_id = p_organization_id;



exception
   WHEN RESOURCE_BUSY THEN
      --dbms_output.put_line('resource busy wip_id = ' || p_wip_entity_id);
      NULL;
   when no_data_found then
      --dbms_output.put_line('no data found wip_id = ' || p_wip_entity_id);
      NULL;
END update_scheduling_request_id;



procedure update_scheduling_request_id(p_request_id in NUMBER,
				       p_wip_entity_id_table  IN  Number_Tbl_Type,
				       p_wip_entity_table_size IN NUMBER,
				       p_organization_id NUMBER)
  IS
   i number := 1;

BEGIN

   LOOP
      EXIT when i > p_wip_entity_table_size;
      update_scheduling_request_id(p_request_id,
				   p_wip_entity_id_table(i),
				   p_organization_id);
      i := i+1;
   END LOOP;

END update_scheduling_request_id;


function get_DiscreteJob_Progress(p_wip_entity_id in NUMBER) return NUMBER

IS
   progress number := 0;
   completed number := 0;
   total number := 1;
   l_wip_entity_id number := 0;

BEGIN

   SELECT SUM(((WO.QUANTITY_COMPLETED+wo.QUANTITY_SCRAPPED)/wo.SCHEDULED_QUANTITY)*(wo.LAST_UNIT_COMPLETION_DATE - wo.FIRST_UNIT_START_DATE)),
     SUM(wo.LAST_UNIT_COMPLETION_DATE - wo.FIRST_UNIT_START_DATE) into completed, total
     from wip_operations wo,
          wip_discrete_jobs wdj
     where wdj.wip_entity_id = p_wip_entity_id
       and wo.wip_entity_id = wdj.wip_entity_id
     and wo.organization_id = wdj.organization_id;

   if ( total = 0 ) then
     select ((QUANTITY_COMPLETED+ QUANTITY_SCRAPPED)/START_QUANTITY) INTO progress
     from wip_discrete_jobs
     where wip_entity_id = p_wip_entity_id;
    else
      progress := completed/total;
    end if;

   return progress;

END get_DiscreteJob_Progress;



END WPS_Common;

/
