--------------------------------------------------------
--  DDL for Package Body EAM_OTL_TIMECARD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OTL_TIMECARD_PUB" as
/* $Header: EAMOTLTB.pls 120.5.12010000.6 2009/09/02 03:52:48 jgootyag ship $ */

g_pkg_name    CONSTANT VARCHAR2(30):= 'OTL_EAM_TIMECARD_PUB';
g_msg                  VARCHAR2(2000):= null;
g_status varchar2(30) :='SUCCESS';      -- if we find any problem we will set this to 'ERRORS'
g_exception_description         VARCHAR2(2000) :='Resource Transaction Failed';  -- and we will set the exception desc
g_debug_sqlerrm VARCHAR2(250);


-- procedure to get attributes for a given building block
-- for EAM we need to get all the attributes that are necessary for Resource Transaction
-- 1- Work Order;
-- 2- Operation
-- 3- Resource Code
-- 4- Charge Department
-- 5- Asset Group Id
-- 6- Owning Department Id
-- 7- Asset Number


PROCEDURE get_attribute_id (p_att_table  IN  HXC_USER_TYPE_DEFINITION_GRP.t_time_attribute,
                           p_bb_id      IN number,
                           p_last_att_index IN OUT NOCOPY BINARY_INTEGER,
                           x_workorder OUT NOCOPY NUMBER,
                           x_operation OUT NOCOPY NUMBER,
                           x_resource OUT NOCOPY NUMBER,
                           x_charge_department OUT NOCOPY NUMBER,
                           x_asset_group_id OUT NOCOPY NUMBER,
                           x_owning_department OUT NOCOPY NUMBER,
                           x_asset_number OUT NOCOPY VARCHAR2)
IS

bld_block_mismatch           EXCEPTION;
no_attributes_found          EXCEPTION;

no_workorder_found EXCEPTION;
no_operation_found  EXCEPTION;
no_resource_found  EXCEPTION;

l_att_index     BINARY_INTEGER;
l_bld_blk_id    hxc_time_building_blocks.time_building_block_id%TYPE;
l_attribute_id   number;

-- Strings
l_work_order VARCHAR2(30) := 'EAMWORKORDER';
l_operation  VARCHAR2(30) := 'EAMOPERATION';
l_resource_code VARCHAR2(30) := 'EAMRESOURCE';
l_charge_department VARCHAR2(30) := 'EAMCHARGEDEPT';
l_asset_group VARCHAR2(30) := 'EAMASSETGROUP';
l_owning_department VARCHAR2(30) := 'EAMDEPARTMENTID';
l_asset_number VARCHAR2(30) := 'EAMASSETNUMBER';

-- Ids
l_work_order_id NUMBER;
l_operation_id  NUMBER;
l_resource_id NUMBER;
l_charge_department_id NUMBER;
l_asset_group_id NUMBER;
l_owning_department_id NUMBER;
l_asset_number_id VARCHAR2(30);

-- Boolean
l_found_workorder boolean := FALSE;
l_found_operation boolean := FALSE;
l_found_resource boolean := FALSE;
l_found_charge_department boolean := FALSE;
l_found_asset_group_id boolean := FALSE;
l_found_owning_department boolean := FALSE;
l_found_asset_number boolean := FALSE;

l_attribute VARCHAR2(30);


BEGIN

-- Get the attributes of the detail record - element name, input values

g_msg := 'Inside Method get_attribute_id' ;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

l_att_index := NVL( p_last_att_index, p_att_table.FIRST);
l_bld_blk_id := p_att_table(l_att_index).bb_id;

g_msg := 'Building Block Id : ' || l_bld_blk_id || ' Attribute Index : ' || l_att_index ;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- sanity check to make sure we are in sync

IF ( l_bld_blk_id <> p_bb_id )
THEN

-- dbms_output.put_line('in sanity check!!!!');

    g_status := 'ERRORS';

    -- define our error mechanism

raise bld_block_mismatch;

END IF;

IF p_att_table.COUNT <> 0 THEN
   --
   FOR att IN l_att_index .. p_att_table.LAST
   LOOP

       -- dbms_output.put_line('AT'||p_att_table(att).field_name||' '||p_att_table(att).value);

        IF ( l_bld_blk_id <> p_att_table(att).bb_id ) THEN
                p_last_att_index := att;

                g_msg := 'Last Attribute of Building Block Id :' || l_bld_blk_id || ' is ' || p_last_att_index ;
                fnd_file.put_line(FND_FILE.LOG, g_msg);
                -- dbms_output.put_line(g_msg);
                EXIT;
        END IF;

          -- Check for Workorder

          if( upper(p_att_table(att).field_name) = l_work_order ) then
            l_found_workorder :=TRUE;
            l_work_order_id:= to_number (p_att_table(att).value);

            g_msg := 'Work Order is : ' || l_work_order_id;
	    fnd_file.put_line(FND_FILE.LOG, g_msg);
	    -- dbms_output.put_line(g_msg);

          -- Check for Operation

          elsif ( upper(p_att_table(att).field_name) = l_operation ) then
            l_found_operation :=TRUE;
            l_operation_id:= to_number (p_att_table(att).value);

            g_msg := 'Operation is : ' || l_operation_id;
	    fnd_file.put_line(FND_FILE.LOG, g_msg);
	    -- dbms_output.put_line(g_msg);

          -- Check for Resource

          elsif ( upper(p_att_table(att).field_name) = l_resource_code ) then
	    l_found_resource :=TRUE;
            l_resource_id:= to_number (p_att_table(att).value);

             g_msg := 'Resource is : ' || l_resource_id;
	     fnd_file.put_line(FND_FILE.LOG, g_msg);
	     -- dbms_output.put_line(g_msg);


          -- Check for Charge Department

          elsif ( upper(p_att_table(att).field_name) = l_charge_department ) then
	    l_found_charge_department :=TRUE;
            l_charge_department_id:= to_number (p_att_table(att).value);

            g_msg := 'Charge Department is : ' || l_charge_department_id;
	    fnd_file.put_line(FND_FILE.LOG, g_msg);
	    -- dbms_output.put_line(g_msg);

          -- Check for Asset Group Id

          elsif ( upper(p_att_table(att).field_name) = l_asset_group ) then
	    l_found_asset_group_id :=TRUE;
            l_asset_group_id:= to_number (p_att_table(att).value);

            g_msg := 'Asset Group Id is : ' || l_asset_group_id;
	    fnd_file.put_line(FND_FILE.LOG, g_msg);
	    -- dbms_output.put_line(g_msg);

          -- Check for Owning Department Id

       elsif ( upper(p_att_table(att).field_name) = l_owning_department ) then
	    l_found_owning_department :=TRUE;
	    l_owning_department_id:= to_number (p_att_table(att).value);

	    g_msg := 'Owning Department Id is : ' || l_owning_department_id;
	    fnd_file.put_line(FND_FILE.LOG, g_msg);
            -- dbms_output.put_line(g_msg);

	  -- Check for Asset Number

	  elsif ( upper(p_att_table(att).field_name) = l_asset_number ) then
	    l_found_asset_number :=TRUE;
	    l_asset_number_id:= p_att_table(att).value;

	    g_msg := 'Asset Number is : ' || l_asset_number_id;
	    fnd_file.put_line(FND_FILE.LOG, g_msg);
	    -- dbms_output.put_line(g_msg);

      end if;

    END LOOP;
   --
ELSE
   --
   g_status := 'ERRORS';
   g_msg := 'No Attributes Found ';
   fnd_file.put_line(FND_FILE.LOG, g_msg);
   -- dbms_output.put_line(g_msg);
   g_exception_description := g_msg;
   raise no_attributes_found;

   --
END IF;

x_workorder := l_work_order_id;
x_operation := l_operation_id;
x_resource := l_resource_id;
x_charge_department := l_charge_department_id;
x_asset_group_id := l_asset_group_id;
x_owning_department := l_owning_department_id;
x_asset_number := l_asset_number_id;


if(l_found_workorder = FALSE) then
   g_status := 'ERRORS';
   raise no_workorder_found;

elsif (l_found_operation = FALSE) then
   g_status := 'ERRORS';
   raise no_operation_found;

elsif (l_found_resource = FALSE) then
   g_status := 'ERRORS';
   raise no_resource_found;
end if;

--
EXCEPTION

WHEN no_workorder_found then

  g_msg := 'Work Order not found';
  fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);
  g_exception_description := g_msg;

WHEN no_operation_found then

  g_msg := 'Operation not found';
  fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);
  g_exception_description := g_msg;

WHEN no_resource_found then

  g_msg := 'Resource not found';
  fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);
  g_exception_description := g_msg;

WHEN bld_block_mismatch then

  g_msg := 'Mismatch of Building Block Id' ;
  fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);

WHEN others then

  g_msg := 'UNEXPECTED ERROR: ' || SQLERRM;
  fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);


END get_attribute_id;

-- End of fetching all attributes




-- Procedure for performing Resource Transaction
-- This procedure will insert data into WIP_COST_TXN_INTERFACE table for Cost Manager to process
-- Besides the process will also insert or delete data from WIP_OPERATION_RESOURCES and
-- WIP_OPERATION_RES_INSTANCES, in case we are trying to reverse certain transactions

PROCEDURE perform_res_txn (p_wip_entity_id IN NUMBER,
			   p_operation_seq_num IN NUMBER,
			   p_resource_id  IN NUMBER,
                           p_instance_id IN NUMBER,
			   p_charge_department_id IN NUMBER,
			   p_bb_id IN NUMBER,
			   p_transaction_qty IN NUMBER,
			   p_start_time IN DATE) IS

invalid_resource   EXCEPTION;
invalid_uom        EXCEPTION;
invalid_employee   EXCEPTION;
invalid_equipment  EXCEPTION;
invalid_charge_department EXCEPTION;
invalid_machine   EXCEPTION;
invalid_person    EXCEPTION;
operation_res_combination   EXCEPTION;
invalid_wo        EXCEPTION;



l_st   number;
l_rs_st   number;
l_u_st   number;
l_em_st  number;
l_eq_st   number;
l_re_st  number;
l_d_st  number;
l_m_st  number;
l_p_st   number;
l_rt_st  varchar2(10);
l_emp_id number;
l_emp_no varchar2(30);
l_wo_st number;

l_actual_resource   number;
l_instance_id   number;
l_charge_dept_id   number;

l_msg_count  number;
l_msg_data  varchar2(100);
l_workorder number;
l_operation number;
l_resource number;
l_charge_department number;

l_asset_group number;
l_owning_department number;
l_asset_number varchar2(30);
l_resource_seq_num number;
l_person_id   number;
l_employee_name varchar2(80);
l_organization_id number;
l_resource_code varchar2(80);
l_uom varchar2(3);
l_charge_department_code  varchar2(80);
l_bb_id  number;

l_return_status1  varchar2(10);
l_msg_count1  number;
l_msg_data1  varchar2(100);
l_measure                       NUMBER;
l_start_time                    DATE;



begin

l_workorder := p_wip_entity_id;
l_operation := p_operation_seq_num;
l_resource  := p_resource_id;
l_charge_department := p_charge_department_id;
l_bb_id := p_bb_id ;
l_measure := p_transaction_qty;
l_start_time := p_start_time;

g_msg := 'Start of perform_res_txn' ;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

g_msg := 'Work Order is : ' || l_workorder || ' and Operation is : ' || l_operation || ' and Resource is : ' || l_resource || ' and Employee is :' || p_instance_id;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);


-- Get Resource Sequence Number

begin

if (l_workorder is not null AND l_operation is not null) then

select nvl((max(resource_seq_num) + 10),10)
into l_resource_seq_num
from wip_operation_resources
where wip_entity_id = l_workorder
and operation_seq_num = l_operation;

end if;

exception

when others then

l_resource_seq_num := 10;

end;

g_msg := 'Resource Sequence Number is : ' || l_resource_seq_num;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);



-- Get Employee Name

begin

if (p_instance_id is not null) then

--fix for 3823899.use table per_all_people_f and check effectivity dates
--Fix for 6808173. Modified check for effectivity dates. It was causing errors for name changes made in HR.

select distinct full_name
   into l_employee_name
   from PER_ALL_PEOPLE_F
   where person_id = p_instance_id
   and l_start_time BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;
   --and NVL(current_employee_flag,'N')='Y';

end if;

exception

when others then

null;

end;

g_msg := 'Employee Name is : ' || l_employee_name;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- Get Organization Id

begin

if (l_workorder is not null) then

select organization_id
into l_organization_id
from wip_entities
where wip_entity_id = l_workorder;

end if;

exception

when others then

null;

end;

g_msg := 'Organization Id is : ' || l_organization_id;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- Get Resource Code

begin

if (l_resource is not null) then

select resource_code , unit_of_measure
into l_resource_code , l_uom
from bom_resources
where resource_id = l_resource
and organization_id = l_organization_id ;

end if;

exception

when others then

null;

end;

g_msg := 'Resource Code is : ' || l_resource_code;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);


-- Get Charge Department

begin

if (l_charge_department is not null) then

select distinct department_code
into l_charge_department_code
from bom_departments
where organization_id = l_organization_id
and department_id = l_charge_department;

end if;

exception

when others then

null;

end;

g_msg := 'Charge Department is : ' || l_charge_department_code;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

g_msg := 'Start of Resource Validation in WIP_EAM_RESOURCE_TRANSACTION.resource_validate';
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

if (l_workorder is not null) then



WIP_EAM_RESOURCE_TRANSACTION.resource_validate (
          p_api_version        => 1.0
         ,p_init_msg_list      => fnd_api.g_false
         ,p_commit             => fnd_api.g_false
         ,p_validation_level   => fnd_api.g_valid_level_full
         ,p_wip_entity_id      => l_workorder
         ,p_operation_seq_num  => l_operation
         ,p_organization_id    => l_organization_id
         ,p_resource_seq_num   => l_resource_seq_num
	 ,p_resource_code      => l_resource_code
         ,p_uom_code           => l_uom
         ,p_employee_name      => l_employee_name
         ,p_equipment_name     => null
         ,p_reason             => null
         ,p_charge_dept        => l_charge_department_code
         ,p_start_time         => l_start_time --for bug 6808173
         ,x_actual_resource_rate => l_actual_resource
         ,x_status             => l_st
         ,x_res_status         => l_rs_st
         ,x_uom_status         => l_u_st
         ,x_employee_status    => l_em_st
         ,x_employee_id        => l_emp_id
         ,x_employee_number    => l_emp_no
         ,x_equipment_status   => l_eq_st
         ,x_reason_status      => l_re_st
         ,x_charge_dept_status => l_d_st
         ,x_machine_status     => l_m_st
         ,x_person_status      => l_p_st
	 ,x_work_order_status  => l_wo_st
         ,x_instance_id        => l_instance_id
         ,x_charge_dept_id     => l_charge_dept_id
	 ,x_resource_seq_num  => l_resource_seq_num
         ,x_return_status      => l_rt_st
         ,x_msg_count          => l_msg_count
         ,x_msg_data           => l_msg_data);


                        if (l_rs_st = 1) then

	                      g_status := 'ERRORS';
                          raise invalid_resource;
                        end if;

	                   if (l_u_st = 1) then

	                      g_status := 'ERRORS';
                          raise invalid_uom;
                       end if;

	                   if (l_em_st = 1) then

	                      g_status := 'ERRORS';
                          raise invalid_employee;

                       end if;

	                   if (l_eq_st = 1) then

	                      g_status := 'ERRORS';
                          raise invalid_equipment;
                       end if;


	                   if (l_d_st = 1) then

	                      g_status := 'ERRORS';
                          raise invalid_charge_department;
                       end if;


	                   if (l_m_st = 1) then

	                      g_status := 'ERRORS';
                          raise invalid_machine;
                       end if;


	                   if (l_p_st = 1) then

	                      g_status := 'ERRORS';
                          raise invalid_person;
                       end if;


                       if (l_st = 1) then

			              g_status := 'ERRORS';
                        raise operation_res_combination;
                       end if;

			 if (l_wo_st = 1) then
                                   g_status := 'ERRORS';
                                   raise invalid_wo;
                          end if;



-- dbms_output.put_line ('Resource Seq Num is :' || l_resource_seq_num);
-- Added check (l_wo_st =0) in if condition
if ((l_rs_st = 0) and (l_st = 0) and (l_u_st = 0) and (l_em_st = 0)and (l_eq_st = 0)) then
  if ((l_re_st = 0) and (l_d_st = 0) and (l_m_st = 0) and (l_p_st = 0) and (l_rt_st = 'S') and (l_wo_st =0))  then

 -- dbms_output.put_line ('Inside the loop');
  WIP_EAM_RESOURCE_TRANSACTION.insert_into_wcti(
                 p_api_version        =>  1.0
                ,p_init_msg_list      => fnd_api.g_false
                ,p_commit             => fnd_api.g_false
                ,p_validation_level   => fnd_api.g_valid_level_full
                ,p_wip_entity_id      => l_workorder
                ,p_operation_seq_num  => l_operation
                ,p_organization_id    => l_organization_id
                ,p_transaction_qty    => l_measure
                ,p_transaction_date   => l_start_time
                ,p_resource_seq_num   => l_resource_seq_num
                ,p_uom                => l_uom
                ,p_resource_code      => l_resource_code
                ,p_reason_name        => null
                ,p_reference          => null
                ,p_instance_id        => l_instance_id
                ,p_serial_number      => null
                ,p_charge_dept_id     => l_charge_dept_id
                ,p_actual_resource_rate => l_actual_resource
                ,p_employee_id        => l_emp_id
                ,p_employee_number    => l_emp_no
                ,x_return_status      => l_return_status1
                ,x_msg_count          => l_msg_count1
                ,x_msg_data           => l_msg_data1);
       --  dbms_output.put_line ('After insert into wcti');
     end if;

end if;
-- dbms_output.put_line ('End of insert into wcti');

if (l_return_status1 = 'S') then

-- set the transaction status for the block we have processed

g_msg := 'Insert into WCTI - SUCCESS';
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(l_bb_id) := 'SUCCESS';
HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(l_bb_id) := 'Resource Transaction Processed Successfully';

else

g_msg := 'Insert into WCTI failed';
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(l_bb_id) := 'ERRORS';
HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(l_bb_id) := 'Resource Transaction Failed';

end if;

else

 	 g_msg := 'Work order details no found - skip resource insertion';
 	 fnd_file.put_line(FND_FILE.LOG, g_msg);

end if;

EXCEPTION

WHEN invalid_resource THEN

fnd_message.set_name('EAM', 'EAM_WO_INVALID_RES_SELECTED');
g_exception_description := SUBSTR(fnd_message.get,1,2000);
g_msg := g_exception_description;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);


WHEN invalid_uom THEN

fnd_message.set_name('EAM', 'EAM_WO_INVALID_UOM_ENTRY');
g_exception_description := SUBSTR(fnd_message.get,1,2000);
g_msg := g_exception_description;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

WHEN invalid_employee THEN

fnd_message.set_name('EAM', 'EAM_WO_INVALID_EMPLOYEE_ENTRY');
g_exception_description := SUBSTR(fnd_message.get,1,2000);
g_msg := g_exception_description;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

WHEN invalid_equipment THEN

fnd_message.set_name('EAM', 'EAM_WO_INVALID_EQUIPMENT_ENTRY');
g_exception_description := SUBSTR(fnd_message.get,1,2000);
g_msg := g_exception_description;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

WHEN invalid_charge_department THEN

fnd_message.set_name('EAM', 'EAM_WO_INVALID_CHARGE_DEPT_ENT');
g_exception_description := SUBSTR(fnd_message.get,1,2000);
g_msg := g_exception_description;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

WHEN invalid_machine THEN

fnd_message.set_name('EAM', 'EAM_WO_RES_NOT_A_MACHINE');
g_exception_description := SUBSTR(fnd_message.get,1,2000);
g_msg := g_exception_description;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

WHEN invalid_person THEN

fnd_message.set_name('EAM', 'EAM_WO_RES_NOT_AN_EMPLOYEE');
g_exception_description := SUBSTR(fnd_message.get,1,2000);
g_msg := g_exception_description;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

WHEN operation_res_combination THEN

fnd_message.set_name('EAM', 'EAM_WO_INVALID_RES_SEQ_COMB');
g_exception_description := SUBSTR(fnd_message.get,1,2000);
g_msg := g_exception_description;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

WHEN invalid_wo THEN
   fnd_message.set_name('EAM', 'EAM_NO_CHARGES_ALLOWED');
   g_exception_description := SUBSTR(fnd_message.get,1,2000);
   g_msg := g_exception_description;
   fnd_file.put_line(FND_FILE.LOG, g_msg);

WHEN others then

  g_msg := 'UNEXPECTED ERROR: ' || SQLERRM;
  fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);

end;


-- Function for forming the where clause

FUNCTION where_clause (p_asset_group_id IN NUMBER,
		       p_asset_number IN VARCHAR2,
		       p_owning_department IN NUMBER,
		       p_charge_department IN NUMBER,
		       p_resource_id IN NUMBER,
		       p_wip_entity_id IN NUMBER,
		       p_operation_seq_num IN NUMBER,
		       p_organization_id IN NUMBER,
		       p_person_id  IN NUMBER,
		       --p_project_id IN NUMBER,
		       --p_task_id IN NUMBER,
		       p_where_clause IN OUT NOCOPY VARCHAR2) RETURN VARCHAR2

IS

l_where_clause VARCHAR2(25000);
l_count NUMBER;

BEGIN

l_count := 0;
g_msg := 'Inside Method where_clause';
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

g_msg := 'Input Parameters are : Asset Group Id : ' || p_asset_group_id || ' Asset Number : ' || p_asset_number || ' Owning Department : ' || p_owning_department || ' Charge Department : ' || p_charge_department ;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

g_msg := 'Resource Id : ' || p_resource_id || ' Wip Entity Id : ' || p_wip_entity_id || ' Operation Seq Num: ' || p_operation_seq_num || ' Organization Id : ' || p_organization_id || ' Person Id :' || p_person_id ;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

l_where_clause := p_where_clause ;

-- Append Inventory Item Id if it is NOT NULL

if (p_asset_group_id is not null) then

   l_count := l_count + 1;

  l_where_clause := l_where_clause || '[EAMASSETGROUP] {= '''|| to_char(p_asset_group_id) || '''}';

end if;

g_msg := 'where_clause after Inventory Item Id ' || l_where_clause ;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- Append Asset Number if it is NOT NULL

if (p_asset_number is not null) then

 l_count := l_count + 1;

 if (l_count > 1) then

 l_where_clause := l_where_clause || ' AND ' || '[EAMASSETNUMBER] {= '''|| p_asset_number || '''}';

 else

 l_where_clause := l_where_clause || '[EAMASSETNUMBER] {= '''|| p_asset_number || '''}';

 end if;

end if;

g_msg := 'where_clause after Asset Number ' || l_where_clause;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- Append Owning Department if it is NOT NULL

if (p_owning_department is not null) then

 l_count := l_count + 1;

 if (l_count > 1) then

 l_where_clause := l_where_clause || ' AND ' || '[EAMDEPARTMENTID] {= '''|| to_char(p_owning_department) || '''}';

 else

 l_where_clause := l_where_clause || '[EAMDEPARTMENTID] {= '''|| to_char(p_owning_department) || '''}';

 end if;

end if;

g_msg := 'where_clause after Owning Department ' || l_where_clause;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- Append Resource Id if it is NOT NULL

if (p_resource_id is not null) then

 l_count := l_count + 1;

 if (l_count > 1) then

 l_where_clause := l_where_clause || ' AND ' || '[EAMRESOURCE] {= '''|| to_char(p_resource_id) || '''}';

 else

 l_where_clause := l_where_clause || '[EAMRESOURCE] {= '''|| to_char(p_resource_id) || '''}';

 end if;

end if;

g_msg := 'where_clause after Resource Id ' || l_where_clause;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- Append Wip Entity Id if it is NOT NULL

if (p_wip_entity_id is not null) then

 l_count := l_count + 1;

 if (l_count > 1) then

 l_where_clause := l_where_clause || ' AND ' || '[EAMWORKORDER] {= '''|| to_char(p_wip_entity_id) || '''}';

 else

 l_where_clause := l_where_clause || '[EAMWORKORDER] {= '''|| to_char(p_wip_entity_id) || '''}';

 end if;

end if;

g_msg := 'where_clause after Wip Entity Id ' || l_where_clause;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- Append Operation if it is NOT NULL

if (p_operation_seq_num is not null) then

 l_count := l_count + 1;

 if (l_count > 1) then

 l_where_clause := l_where_clause || ' AND ' || '[EAMOPERATION] {= '''|| to_char(p_operation_seq_num) || '''}';

 else

 l_where_clause := l_where_clause || '[EAMOPERATION] {= '''|| to_char(p_operation_seq_num) || '''}';

 end if;

end if;

g_msg := 'where_clause after Operation ' || l_where_clause;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- Append Organization Id if it is NOT NULL

if (p_organization_id is not null) then

 l_count := l_count + 1;

 if (l_count > 1) then

 l_where_clause := l_where_clause || ' AND ' || '[EAMORGANIZATIONID] {= '''|| to_char(p_organization_id) || '''}';

 else

 l_where_clause := l_where_clause || '[EAMORGANIZATIONID] {= '''|| to_char(p_organization_id) || '''}';

 end if;

end if;

g_msg := 'where_clause after Organization Id ' || l_where_clause;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- Append Charge Department if it is NOT NULL

if (p_charge_department is not null) then

 l_count := l_count + 1;

 if (l_count > 1) then

 l_where_clause := l_where_clause || ' AND ' || '[EAMCHARGEDEPT] {= '''|| to_char(p_charge_department) || '''}';

 else

 l_where_clause := l_where_clause || '[EAMCHARGEDEPT] {= '''|| to_char(p_charge_department) || '''}';

 end if;

end if;

g_msg := 'where_clause after Charge Department ' || l_where_clause;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- Append Project Id if it is NOT NULL

/*if (p_project_id is not null) then

 l_count := l_count + 1;

 if (l_count > 1) then

 l_where_clause := l_where_clause || ' AND ' || '[Project_Id] {= '''|| to_char(p_project_id) || '''}';

 else

 l_where_clause := l_where_clause || '[Project_Id] {= '''|| to_char(p_project_id) || '''}';

 end if;

end if;

g_msg := 'where_clause after Project Id ' || l_where_clause; */
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- Append Task Id if it is NOT NULL

/*if (p_task_id is not null) then

 l_count := l_count + 1;

 if (l_count > 1) then

 l_where_clause := l_where_clause || ' AND ' || '[Task_Id] {= '''|| to_char(p_task_id) || '''}';

 else

 l_where_clause := l_where_clause || '[Task_Id] {= '''|| to_char(p_task_id) || '''}';

 end if;

end if;*/

g_msg := 'where_clause after Task Id ' || l_where_clause;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);


-- Append Person Id if it is NOT NULL

if (p_person_id is not null) then

 l_count := l_count + 1;

 if (l_count > 1) then

 l_where_clause := l_where_clause || ' AND ' || '[TIMECARD_BLOCK.RESOURCE_ID] {= '''|| to_char(p_person_id) || '''}';

 else

 l_where_clause := l_where_clause || '[TIMECARD_BLOCK.RESOURCE_ID] {= '''|| to_char(p_person_id) || '''}';

 end if;

end if;

g_msg := 'Final where_clause  ' || l_where_clause;
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

return l_where_clause;
END;

-- End of Function for forming the where clause



-- Main Retrieval Procedure



PROCEDURE retrieve_process (
      errbuf  out    nocopy  varchar2,
      retcode    out  nocopy   varchar2,
      p_start_date IN varchar2,
      p_end_date IN varchar2,
      p_organization_id IN NUMBER,
      p_asset_group_id IN NUMBER,
      p_asset_number IN VARCHAR2,
      --p_project_id  IN  NUMBER,
      --p_task_id   IN  NUMBER,
      p_resource_id IN NUMBER,
      p_person_id  IN NUMBER,
      p_owning_department IN NUMBER,
      p_wip_entity_id IN NUMBER,
      p_operation_seq_num IN NUMBER,
      p_charge_department IN NUMBER,
      p_transaction_code IN VARCHAR2
    ) IS

l_last_att_index number;
l_bb_id                         NUMBER(15);
l_bb_index                      BINARY_INTEGER;
l_type                          VARCHAR2(30);
l_measure                       NUMBER;
l_start_time                    DATE;
l_stop_time                     DATE;
l_parent_bb_id                  NUMBER(15);
l_scope                         VARCHAR2(30);
l_resource_id                   NUMBER(15);
l_resource_type                 VARCHAR2(30);
l_comment_text                  VARCHAR2(2000);
l_changed                       VARCHAR2(1);
l_deleted                       VARCHAR2(1);
l_index                         NUMBER;

l_old_measure                       NUMBER;
l_old_start_time                    DATE;
l_old_count                         NUMBER;


-- Specific Variables
l_workorder number;
l_operation number;
l_resource number;
l_charge_department number;
l_asset_group number;
l_owning_department number;
l_asset_number varchar2(30);
l_resource_seq_num number := 10;
l_person_id   number;
l_employee_name varchar2(80);
l_organization_id number;
l_resource_code varchar2(80);
l_charge_department_code  varchar2(80);

l_actual_resource   number;
l_status   number;
l_res_status   number;
l_uom_status   number;
l_employee_status  number;
l_equipment_status   number;
l_reason_status  number;
l_charge_dept_status  number;
l_machine_status  number;
l_person_status   number;
l_instance_id   number;
l_charge_dept_id   number;
l_return_status  varchar2(10);
l_msg_count  number;
l_msg_data  varchar2(100);
l_return_status1  varchar2(10);
l_msg_count1  number;
l_msg_data1  varchar2(100);

-- Old Details
l_old_workorder  number;
l_old_operation   number;
l_old_resource   number;
l_old_charge_department  number;
l_old_asset_group  number;
l_old_owning_department  number;
l_old_asset_number  varchar2(30);

t_temp_attr_index number;

l_stmt_num NUMBER;
l_where_clause VARCHAR2(25000) := '';

l_conc_status             BOOLEAN;
l_error_message           VARCHAR2(2000);
l_error_code              NUMBER;




begin

g_msg := 'Entering retrieve_process method';
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

l_stmt_num    := 10;
SAVEPOINT retrieve_process_pub;

-- Initialize message list
fnd_msg_pub.initialize;

-- Initialize API return status to success
  --l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', l_error_message);

  l_stmt_num    := 20;

  -- API starts

  l_error_code := 9999;
  l_error_message := 'Unknown Exception';

  g_msg := '';
  fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);

  fnd_file.put_line(FND_FILE.LOG, 'Start Retrieval Process. Time now is ' || to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));

  fnd_file.put_line(FND_FILE.LOG, g_msg);

  fnd_file.new_line(FND_FILE.LOG,1);

  g_msg := 'Before Building Where Clause in Retrieve Process';
  fnd_file.put_line(FND_FILE.LOG, g_msg);
   -- dbms_output.put_line(g_msg);

l_where_clause := where_clause (p_asset_group_id,p_asset_number,p_owning_department,p_charge_department,
		       p_resource_id,p_wip_entity_id,p_operation_seq_num,p_organization_id,p_person_id,l_where_clause);

g_msg := 'After Building Where Clause in Retrieve Process, Where Clause is : ' || l_where_clause;
fnd_file.put_line(FND_FILE.LOG, g_msg);

-- call generic retrieval



HXC_INTEGRATION_LAYER_V1_GRP.execute_retrieval_process (
        p_process          => 'Maintenance Retrieval Process'
,       p_transaction_code => p_transaction_code
,       p_start_date       => to_date(p_start_date,'DD-MM-YYYY')
,       p_end_date         => to_date(p_end_date,'DD-MM-YYYY')
,       p_incremental      => 'Y'
,       p_rerun_flag       => 'N'
,       p_where_clause     => l_where_clause
,       p_scope            => 'DAY'
,       p_clusive          => 'EX'
);


-- process results of generic retrieval

g_msg := 'After HXC_INTEGRATION_LAYER_V1_GRP.execute_retrieval_process ';
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

g_msg := 'Start Processing of Building Blocks start now ';
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

-- dbms_output.put_line(HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks.COUNT);



IF HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks.COUNT <> 0 THEN

l_old_count := HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks.first;

FOR l_cnt in HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks.first ..
             HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks.last

   LOOP

   g_msg := 'Processing Building Blocks : ' || l_cnt;
   fnd_file.put_line(FND_FILE.LOG, g_msg);
   -- dbms_output.put_line(g_msg);

  g_status := 'SUCCESS';

   BEGIN
   l_bb_id := HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_cnt).bb_id;
   l_bb_index := l_cnt;
   l_type := HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_cnt).type;
   l_measure := HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_cnt).measure;
   l_start_time := HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_cnt).start_time;
   l_stop_time := HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_cnt).stop_time;
   l_scope := HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_cnt).scope;
   l_resource_id := HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_cnt).resource_id;
   l_resource_type := HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_cnt).resource_type;
   l_changed := HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_cnt).changed;
   l_deleted := HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_cnt).deleted;


   g_msg := 'Building Block Id : ' || l_bb_id || 'Measure : ' || l_measure || ' Resource Id : '|| l_resource_id || ' Start Time : ' || l_start_time;
   fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);

   g_msg := 'Building Block Status :  Changed ' || l_changed || ' Deleted : ' || l_deleted;
   fnd_file.put_line(FND_FILE.LOG, g_msg);
   -- dbms_output.put_line(g_msg);


-- only need to process detail building blocks for performing resource transactions

  IF l_scope = 'DETAIL' THEN



  -- Get the attributes for this building block

  /*******************************************************************************/

  -- Record is new and has not been deleted.So we need to perform the transaction

  /*******************************************************************************/


 if( l_deleted = 'N') and (l_changed = 'N') then

  g_msg := 'Before get_attribute_id - NEW (N,N)-> (Delete,Change)';
  fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);


  get_attribute_id (p_att_table  =>  HXC_USER_TYPE_DEFINITION_GRP.t_detail_attributes,
                    p_bb_id      =>  l_bb_id,
                    p_last_att_index => l_last_att_index,
                    x_workorder => l_workorder,
                    x_operation => l_operation,
                    x_resource => l_resource,
                    x_charge_department => l_charge_department,
                    x_asset_group_id => l_asset_group,
                    x_owning_department => l_owning_department,
                    x_asset_number => l_asset_number);

  g_msg := 'After get_attribute_id - NEW (N,N)-> (Delete,Change)';
  fnd_file.put_line(FND_FILE.LOG, g_msg);
 -- dbms_output.put_line(g_msg);

 g_msg := 'l_workorder:' || l_workorder;
  fnd_file.put_line(FND_FILE.LOG, g_msg);

  perform_res_txn (p_wip_entity_id  => l_workorder,
  	           p_operation_seq_num => l_operation,
  	           p_resource_id  => l_resource,
               p_instance_id => l_resource_id,
  		   p_charge_department_id => l_charge_department,
  		   p_bb_id => l_bb_id,
  		   p_transaction_qty  => l_measure,
		   p_start_time  => l_start_time);

  g_msg := 'After Resource Txn - (N,N)-> (Delete,Change)';
  fnd_file.put_line(FND_FILE.LOG, g_msg);
 -- dbms_output.put_line(g_msg);

  end if;


  /*******************************************************************************/

    -- Record has been changed and has been deleted.So we need to reverse
    -- the previous transaction. Do not need to take care of the changes

  /*******************************************************************************/

  /********************************************************************************/
    -- Bug 3427426
    -- For now, Once an OTL time card has been approved, no deletes will be allowed
    -- Bug 3753728 -- Corrections allowed for EAM timecard
  /********************************************************************************/

  if( l_deleted = 'Y') and (l_changed = 'Y') then

  -- t_temp_attr_index := l_last_att_index;

  g_msg := 'Before get_attribute_id - NEW (Y,Y)-> (Delete,Change)';
  fnd_file.put_line(FND_FILE.LOG, g_msg);

  g_msg := 'Update OTL Timecard. Resource Transaction reversed.';
  fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);

  get_attribute_id (p_att_table  =>  HXC_USER_TYPE_DEFINITION_GRP.t_detail_attributes,
                      p_bb_id      =>  l_bb_id,
                      p_last_att_index => l_last_att_index,
                      x_workorder => l_workorder,
                      x_operation => l_operation,
                      x_resource => l_resource,
                      x_charge_department => l_charge_department,
                      x_asset_group_id => l_asset_group,
                      x_owning_department => l_owning_department,
                      x_asset_number => l_asset_number);

  g_msg := 'After get_attribute_id - NEW (Y,Y)-> (Delete,Change)';
  fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);

  g_msg := 'Before get_attribute_id - OLD (Y,Y)-> (Delete,Change)';
  fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);


  get_attribute_id (p_att_table  =>  HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_attributes,
                        p_bb_id      =>  l_bb_id,
                        p_last_att_index => t_temp_attr_index,
                        x_workorder => l_old_workorder,
                        x_operation => l_old_operation,
                        x_resource => l_old_resource,
                        x_charge_department => l_old_charge_department,
                        x_asset_group_id => l_old_asset_group,
                        x_owning_department => l_old_owning_department,
                        x_asset_number => l_old_asset_number);

 g_msg := 'After get_attribute_id - OLD (Y,Y)-> (Delete,Change)';
 fnd_file.put_line(FND_FILE.LOG, g_msg);
 -- dbms_output.put_line(g_msg);


 -- t_temp_attr_index := l_last_att_index;
 l_old_measure := HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_old_count).measure;
 l_old_start_time := HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_old_count).start_time;
 l_old_count := l_old_count + 1;

 perform_res_txn (p_wip_entity_id  => l_old_workorder,
   	           p_operation_seq_num => l_old_operation,
   	           p_resource_id  => l_old_resource,
               p_instance_id => l_resource_id,
   		   p_charge_department_id => l_old_charge_department,
   		   p_bb_id => l_bb_id,
   		   p_transaction_qty  => -(l_old_measure),
		   p_start_time  => l_old_start_time);

g_msg := 'After Reversing Resource Txn - (Y,Y)-> (Delete,Change)';
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);



end if;


/*******************************************************************************/

 -- Record is new but has been deleted.So do not need to perform any transaction
 -- only need to set the index for the new attributes table

/*******************************************************************************/


if( l_deleted = 'Y') and (l_changed = 'N') then

g_msg := 'Before get_attribute_id - NEW (Y,N)-> (Delete,Change)';
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

get_attribute_id (p_att_table  =>  HXC_USER_TYPE_DEFINITION_GRP.t_detail_attributes,
                      p_bb_id      =>  l_bb_id,
                      p_last_att_index => l_last_att_index,
                      x_workorder => l_workorder,
                      x_operation => l_operation,
                      x_resource => l_resource,
                      x_charge_department => l_charge_department,
                      x_asset_group_id => l_asset_group,
                      x_owning_department => l_owning_department,
                      x_asset_number => l_asset_number);

g_msg := 'After get_attribute_id - NEW (Y,N) -> (Delete,Change)';
fnd_file.put_line(FND_FILE.LOG, g_msg);
-- dbms_output.put_line(g_msg);

end if;


/*******************************************************************************/

 -- Record has been changed but has not been deleted.So we need to reverse the
 -- old resource transaction and create the new resource transaction

 -- Bug 3427426
 -- Updates to OTL Time cards are not being supported at this time
 -- Bug 3753728 -- Corrections allowed for EAM timecard

/*******************************************************************************/

if( l_deleted = 'N') and (l_changed = 'Y') then

-- t_temp_attr_index := l_last_att_index;

   g_msg := 'Before get_attribute_id - NEW (N,Y)-> (Delete,Change)';
   fnd_file.put_line(FND_FILE.LOG, g_msg);
  -- dbms_output.put_line(g_msg);

   g_msg := 'Updating OTL Timecard';
   fnd_file.put_line(FND_FILE.LOG, g_msg);

    get_attribute_id (p_att_table  =>  HXC_USER_TYPE_DEFINITION_GRP.t_detail_attributes,
                      p_bb_id      =>  l_bb_id,
                      p_last_att_index => l_last_att_index,
                      x_workorder => l_workorder,
                      x_operation => l_operation,
                      x_resource => l_resource,
                      x_charge_department => l_charge_department,
                      x_asset_group_id => l_asset_group,
                      x_owning_department => l_owning_department,
                      x_asset_number => l_asset_number);

      g_msg := 'After get_attribute_id - NEW (N,Y) -> (Delete,Change)';
      fnd_file.put_line(FND_FILE.LOG, g_msg);
      -- dbms_output.put_line(g_msg);

     g_msg := 'Before get_attribute_id - OLD (N,Y)-> (Delete,Change)';
      fnd_file.put_line(FND_FILE.LOG, g_msg);
      -- dbms_output.put_line(g_msg);



      get_attribute_id (p_att_table  =>  HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_attributes,
                        p_bb_id      =>  l_bb_id,
                        p_last_att_index => t_temp_attr_index,
                        x_workorder => l_old_workorder,
                        x_operation => l_old_operation,
                        x_resource => l_old_resource,
                        x_charge_department => l_old_charge_department,
                        x_asset_group_id => l_old_asset_group,
                        x_owning_department => l_old_owning_department,
                        x_asset_number => l_old_asset_number);

       g_msg := 'After get_attribute_id - OLD (N,Y)-> (Delete,Change)';
       fnd_file.put_line(FND_FILE.LOG, g_msg);
       -- dbms_output.put_line(g_msg);

      -- t_temp_attr_index := l_last_att_index;

       l_old_measure := HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_old_count).measure;
       l_old_start_time := HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_old_count).start_time;
       l_old_count := l_old_count + 1;

        perform_res_txn (p_wip_entity_id  => l_old_workorder,
          	           p_operation_seq_num => l_old_operation,
          	           p_resource_id  => l_old_resource,
                       p_instance_id => l_resource_id,
          		   p_charge_department_id => l_old_charge_department,
          		   p_bb_id => l_bb_id,
          		   p_transaction_qty  => -(l_old_measure),
		           p_start_time  => l_old_start_time);

      g_msg := 'After Reversing Resource Txn - (N,Y)-> (Delete,Change)';
      fnd_file.put_line(FND_FILE.LOG, g_msg);
      -- dbms_output.put_line(g_msg);

      perform_res_txn (p_wip_entity_id  => l_workorder,
        	           p_operation_seq_num => l_operation,
        	           p_resource_id  => l_resource,
                       p_instance_id => l_resource_id,
        		   p_charge_department_id => l_charge_department,
        		   p_bb_id => l_bb_id,
        		   p_transaction_qty  => l_measure,
		           p_start_time  => l_start_time);

   g_msg := 'After Resource Txn - (N,Y)-> (Delete,Change)';
   fnd_file.put_line(FND_FILE.LOG, g_msg);
   -- dbms_output.put_line(g_msg);

end if;


end if;

end;

-- set the transaction status for the block we have processed

/**changed for bug#3949853
HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(l_cnt) := 'SUCCESS';
HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(l_cnt) := 'Building Block Processed Successfully';

g_msg := 'SUCCESS -- Building Block Processed Successfully';
fnd_file.put_line(FND_FILE.LOG, g_msg);
**/

   if g_status <> 'ERRORS' then
           HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(l_cnt) := 'SUCCESS';
           HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(l_cnt) := 'Building Block Processed Successfully';
           g_msg := 'SUCCESS -- Building Block Processed Successfully';
           fnd_file.put_line(FND_FILE.LOG, g_msg);
		   COMMIT WORK;
   else
           HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(l_cnt) := g_status;
           HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(l_cnt) := g_exception_description;
           g_msg := 'FAILURE -- Building Block Processing Failed';
		   fnd_file.put_line(FND_FILE.LOG, g_msg);
   end if;


end loop;

end if;

-- set overall transaction status

HXC_INTEGRATION_LAYER_V1_GRP.set_parent_statuses;

-- tell the generic retrieval to update the transactions statuses

HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status
    (p_process               => 'Maintenance Retrieval Process'
    ,p_status                => 'SUCCESS'
    ,p_exception_description => 'Building Block Processed Successfully'
    ,p_rollback              => FALSE);

g_msg := 'SUCCESS -- Resource Transaction Completed Successfully';
fnd_file.put_line(FND_FILE.LOG, g_msg);



exception
-- if there was any problem in the recipient application processing then set the overall transaction
-- status to be a failure. If we know what went wrong in more detail then this will be noted in the
-- exception description for the transation

-- utility that propergates the status of processed blocks up the timecard hierarchy. Useful since
-- we only processed the detail blocks

when others then


HXC_INTEGRATION_LAYER_V1_GRP.set_parent_statuses;

-- tell the generic retrieval to update the transactions statuses

HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status
    (p_process               => 'Maintenance Retrieval Process'
    ,p_status                => 'ERRORS'
    ,p_exception_description => SUBSTR(SQLERRM,1,200)
    ,p_rollback              => FALSE);

g_msg := 'FAILURE -- Resource Transaction encountered errors; Please look into hxc_transactions table for details';
fnd_file.put_line(FND_FILE.LOG, g_msg);
/*Added for Bug 7559044*/
l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', g_msg); -- Bug 7559044


END retrieve_process;

FUNCTION get_person_id RETURN VARCHAR2 IS

l_user_id NUMBER := FND_GLOBAL.USER_ID;
l_person_id  VARCHAR2(30) := '';

BEGIN
l_user_id := FND_GLOBAL.USER_ID;
 begin
 select to_char(employee_id)
 into l_person_id
 from fnd_user
 where user_id = l_user_id;

 exception
 when others then
  null;

 end;

 return l_person_id;
END;

FUNCTION get_retrieval_function RETURN VARCHAR2 IS

l_function_name VARCHAR2(50);
BEGIN

l_function_name := 'Maintenance Retrieval Process';


return l_function_name;
END;


procedure validate_work_day
(p_date  IN DATE,
 p_organization_id IN NUMBER,
 x_status OUT NOCOPY NUMBER)  IS

l_calendar_code  VARCHAR2(40);
l_day_block      NUMBER;
l_start_date     DATE;
l_end_date       DATE;
l_exception_type NUMBER;
rem_days         NUMBER;
block_no         NUMBER;
l_days_off       NUMBER;
l_days_on        NUMBER;
l_total_days     NUMBER;
l_total          NUMBER;
l_stmt_num       NUMBER;

CURSOR seq_num_calendar IS
    select days_off,days_on, (days_off+days_on) as total_days
     from bom_workday_patterns
     where calendar_code = l_calendar_code
     and shift_num is null
     and seq_num is not null
     order by seq_num;


BEGIN

select calendar_code
into l_calendar_code
from mtl_parameters
where organization_id = p_organization_id;


select SUM(days_off + days_on)
into l_day_block
from bom_workday_patterns
where calendar_code = l_calendar_code
and shift_num is null
and seq_num is not null
group by calendar_code;


select calendar_start_date,
calendar_end_date
into l_start_date,
l_end_date
from bom_calendars
where calendar_code = l_calendar_code;

begin

select nvl(exception_type,2)
into l_exception_type
from bom_calendar_exceptions
where calendar_code = l_calendar_code
and exception_date = p_date;

if (l_exception_type = 1) then
 x_status := 0;
else
 x_status := 1;
end if;

exception

when others then
if (p_date <= l_end_date) then

  rem_days := MOD((p_date - l_start_date),l_day_block);

end if;

l_total := 0;

OPEN seq_num_calendar;
  LOOP
    fetch seq_num_calendar into l_days_off, l_days_on, l_total_days;
    exit when seq_num_calendar%notfound;

    if ((l_total + l_total_days) >= rem_days) then

       if ((l_total + l_days_on) >= rem_days) then
          x_status := 0;
       else
          x_status := 1;
       end if;

     end if;

     l_total := l_total + l_total_days;


END LOOP;
CLOSE seq_num_calendar;

end;


END validate_work_day;





procedure validate_process(p_operation IN varchar2) IS

  l_blocks HXC_USER_TYPE_DEFINITION_GRP.timecard_info;
  l_attributes HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info;
  l_messages HXC_USER_TYPE_DEFINITION_GRP.message_table;

begin

  ---- get time information
  HXC_INTEGRATION_LAYER_V1_GRP.get_app_hook_params(
                     p_building_blocks => l_blocks,
                     p_app_attributes  => l_attributes,
                     p_messages        => l_messages);

  ---   EAM will have its own application specific validation
  eam_validate_timecard (p_operation => p_operation
                    ,p_time_building_blocks => l_blocks
                    ,p_time_attributes => l_attributes
                    ,p_messages => l_messages );

  ---  set time information
  HXC_INTEGRATION_LAYER_V1_GRP.set_app_hook_params(
                     p_building_blocks => l_blocks,
                     p_app_attributes => l_attributes,
                     p_messages => l_messages);

END validate_process;



procedure eam_validate_timecard(	p_operation IN varchar2,
							p_time_building_blocks IN  HXC_USER_TYPE_DEFINITION_GRP.timecard_info,
							p_time_attributes IN  HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info,
							p_messages IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table)
IS

	-- Define the variables that form part of the Deposit Mapping
	l_asset_number          VARCHAR2(30);
	l_asset_group           NUMBER;
	l_charge_dept           NUMBER;
	l_dept_id               NUMBER;
	l_operation_number      NUMBER;
	l_org_id                wip_discrete_jobs.organization_id%type;
	l_resource_id           NUMBER;
	l_wip_entity_id         NUMBER;
	-- End of deposit mapping variable declarations

	-- Other variables
	l_job_type              NUMBER := 3;
	l_count                 NUMBER :=-1;
	l_attrib_count          NUMBER :=-1;
	l_bb_count              NUMBER :=-1;
	l_counter               NUMBER :=1;
	l_time_bb_id            NUMBER :=-1;
	l_wip_entity_name       VARCHAR2(300);
	l_asset_group_name      VARCHAR2(300);
	l_dept_name             VARCHAR2(100);
	l_charge_dept_name      VARCHAR2(100);
	l_resource_name         VARCHAR2(100);
	msg_tkn                 VARCHAR2(2000) := '';
	l_min_acct_period_date  DATE := SYSDATE;
	l_max_acct_period_date  DATE := SYSDATE;
	l_wo_released_date      DATE := SYSDATE;
    l_stop_time             DATE := SYSDATE - 100000;
	l_start_time            DATE := SYSDATE - 100000;
    l_exact_start_time      DATE := SYSDATE - 100000;
	l_current_week_tc       HXC_USER_TYPE_DEFINITION_GRP.timecard_info;
	l_parent_bb_id          NUMBER := -1;
	l_return_status         NUMBER := 1;

	l_eam_card              NUMBER :=0;
	i                       NUMBER;
	j                       NUMBER;
	k                       NUMBER;
	d			    NUMBER;

	/* OTL has introduced an integrated time card structure, that lets users enter
	time for EAM, Projects and Payroll applications on a single layout. This brings about a need to change the validation from EAM side such that it does not fail
	when data for Projects/Payroll is also included in the building blocks submitted */

	begin

	-- Define the current week temporary PL/SQL timecard table and clear it
	-- of any previously filled values
	if l_current_week_tc.COUNT <> 0 then
		l_current_week_tc.DELETE;
	end if;

	l_counter := 1;

	-- Loop through the list of blocks and perform block level
	-- validations on each of them

	--OTL ELP bug

	if (p_time_building_blocks.count <> 0) then

		i := p_time_building_blocks.FIRST;

		while i is not null loop

			l_eam_card := 0;

			if p_time_building_blocks(i).date_to > SYSDATE then

				l_bb_count := i;
				l_time_bb_id := p_time_building_blocks(i).time_building_block_id;

				-- loop through the attributes table and find out the attribute records for
				-- the current building block.
				-- ELP OTL Bug
				if (p_time_attributes.count <> 0) then
					j := p_time_attributes.first;

					LOOP
					EXIT when not p_time_attributes.exists(j);

						If p_time_attributes(j).Building_Block_Id = P_time_building_Blocks(i).Time_Building_Block_Id  Then

							-- find out the attribute name and assign the value to the correct variable
							if upper(p_time_attributes(j).attribute_name) = 'EAMASSETGROUP' then
								l_asset_group := nvl(p_time_attributes(j).attribute_value,-9999);
								l_eam_card := 1;
							end if;

							if upper(p_time_attributes(j).attribute_name) = 'EAMASSETNUMBER' then
								l_asset_number := nvl(p_time_attributes(j).attribute_value,' ');
								l_eam_card := 1;

								if l_asset_number = 'null' then
									l_asset_number := ' ';
								end if;
							end if;

							if upper(p_time_attributes(j).attribute_name) = 'EAMCHARGEDEPT' then
								l_charge_dept := nvl(p_time_attributes(j).attribute_value,-9999);
								l_eam_card := 1;
							end if;

							if upper(p_time_attributes(j).attribute_name) = 'EAMDEPARTMENTID' then
								l_dept_id := nvl(p_time_attributes(j).attribute_value,-9999);
								l_eam_card := 1;
							end if;

							if upper(p_time_attributes(j).attribute_name) = 'EAMOPERATION' then
								l_operation_number := nvl(p_time_attributes(j).attribute_value,-9999);
								l_eam_card := 1;
							end if;

							if upper(p_time_attributes(j).attribute_name) = 'EAMORGANIZATIONID' then
								l_org_id := nvl(p_time_attributes(j).attribute_value,-9999);
							end if;

							if upper(p_time_attributes(j).attribute_name) = 'EAMRESOURCE' then
								l_resource_id := nvl(p_time_attributes(j).attribute_value,-9999);
								l_eam_card := 1;
							end if;

							if upper(p_time_attributes(j).attribute_name) = 'EAMWORKORDER' then
								l_eam_card := 1;
								l_wip_entity_id := nvl(p_time_attributes(j).attribute_value,-9999);
							end if;

							l_attrib_count := j;

						end if; -- end of check p_time_attributes(j).Building_Block_Id

						j := p_time_attributes.next(j);

					end loop;

				end if; -- end of check p_time_attributes.count <> 0

				-- Get some commonly used variables for later use.

				-- If it is a DAY scope BB and is 'near' the SYSDATE, then store it's BB Id,
				-- Start and stop times in l_current_week_tc for later use in Validation 10

				if p_time_building_blocks(i).scope = 'DAY'  and ( p_time_building_blocks(i).start_time > SYSDATE - 10 OR
													p_time_building_blocks(i).stop_time  < SYSDATE + 10) then
					l_current_week_tc(l_counter).time_building_block_id := p_time_building_blocks(i).time_building_block_id;
					l_current_week_tc(l_counter).start_time := p_time_building_blocks(i).start_time;
					l_current_week_tc(l_counter).stop_time := p_time_building_blocks(i).stop_time;
				end if;

				l_counter := l_counter + 1;

				-- Derive start and end time outside detail block; Change for timekeeper


				if p_time_building_blocks(i).scope = 'TIMECARD' then
					l_start_time := p_time_building_blocks(i).start_time;
					l_stop_time  := p_time_building_blocks(i).stop_time;
				end if;

				if upper(p_time_building_blocks(i).scope) = 'DETAIL' then

				-- Deriving attributes only for detail scope building blocks.Code change for timekeeper
				-- Added checks for null value

					if (l_eam_card = 1) then

						if l_wip_entity_id <> -9999 and l_org_id <> -9999 and l_wip_entity_id is not null and l_org_id is not null then
							select wip_entity_name into l_wip_entity_name
							from wip_entities
							where wip_entity_id = l_wip_entity_id
							and organization_id = l_org_id;
						end if;

						if l_org_id <> -9999 and l_asset_group <> -9999 and l_asset_group is not null and l_org_id is not null then
							select distinct msik.concatenated_segments into l_asset_group_name
							from mtl_system_items_b_kfv msik, mtl_parameters mp
							where msik.inventory_item_id = l_asset_group
							and mp.maint_organization_id = l_org_id
                                                        and mp.organization_id = msik.organization_id;
						end if;

						if l_dept_id <> -9999 and l_org_id <> -9999 and l_dept_id is not null and l_org_id is not null then
							select department_code into l_dept_name from
							bom_departments where
							department_id = l_dept_id
							and organization_id = l_org_id;
						end if;


						if l_charge_dept <> -9999 and l_org_id <> -9999 and l_charge_dept is not null and l_org_id is not null then
							select department_code into l_charge_dept_name from
							bom_departments where
							department_id = l_charge_dept
							and organization_id = l_org_id;
						end if;



						if l_resource_id <> -9999 and l_org_id <> -9999 and l_resource_id is not null and l_org_id is not null then
							select resource_code into l_resource_name from
							bom_resources where
							resource_id = l_resource_id and
							organization_id = l_org_id;
						end if;

					end if; -- end of check for l_eam_card = 1



					-- Perform the block attribute validations one by one

					-- 1. Check whether the work order is a maintenance work order or not.

					if l_wip_entity_id <> -9999 and l_org_id <> -9999 then
						select job_type into l_job_type from wip_discrete_jobs where
						wip_entity_id = l_wip_entity_id
						and organization_id = l_org_id;
						if l_job_type <> 3 then -- not a maintenance work order
							-- Add the corresponding error message to the message table
							msg_tkn := 'WO_NAME&'||l_wip_entity_name;
							Add_Error_To_Table( p_message_table => p_messages ,
							p_message_name            => 'EAM_OTL_NOT_MNT_WO',
							p_message_token           => msg_tkn,
							P_Message_Level           => 'ERROR',
							P_Message_Field           => NULL,
							p_application_short_name  => 'EAM',
							P_Timecard_bb_Id          =>
							P_time_Building_Blocks(i).Time_Building_Block_Id,
							P_Time_Attribute_Id       => l_attrib_count);
							msg_tkn := '';
						end if;
					end if;

					-- 2. Asset group - work order association is correct.
					if l_wip_entity_id <> -9999 and l_org_id <> -9999 and l_asset_group <> -9999 then
						-- bug  4146481. added NVL in query
						select count(*) into l_count from wip_discrete_jobs where
						wip_entity_id = l_wip_entity_id and
						organization_id = l_org_id and
						nvl(asset_group_id,rebuild_item_id) = l_asset_group;
						if l_count = 0 then
							-- Add the corresponding error message to the message table
							msg_tkn := 'WO_NAME&'||l_wip_entity_name||'&' || 'AG_NAME&'||l_asset_group_name;
							Add_Error_To_Table( p_message_table => p_messages ,
							p_message_name            => 'EAM_OTL_AG_WO_INCORRECT',
							p_message_token           => msg_tkn,
							P_Message_Level           => 'ERROR',
							P_Message_Field           => NULL,
							p_application_short_name  => 'EAM',
							P_Timecard_bb_Id          =>
							P_time_Building_Blocks(i).Time_Building_Block_Id,
							P_Time_Attribute_Id       => l_attrib_count);
							msg_tkn := '';
						end if;
					end if;

					-- 3. Asset number belongs to the correct asset group.
					if l_asset_number <> ' ' and l_asset_group <> -9999 then
					-- Changed as part of CAR impact
						select count(*) into l_count from csi_item_instances where
						serial_number = l_asset_number and
						inventory_item_id = l_asset_group;
						if l_count = 0 then
							-- Add the corresponding error message to the message table
							msg_tkn := 'AN_NAME&'||l_asset_number||'&' || 'AG_NAME&'||l_asset_group_name;
							Add_Error_To_Table( p_message_table => p_messages ,
							p_message_name            => 'EAM_OTL_AG_AN_INCORRECT',
							p_message_token           => msg_tkn,
							P_Message_Level           => 'ERROR',
							P_Message_Field           => NULL,
							p_application_short_name  => 'EAM',
							P_Timecard_bb_Id          =>
							P_time_Building_Blocks(i).Time_Building_Block_Id,
							P_Time_Attribute_Id       => l_attrib_count);
							msg_tkn := '';
						end if;
					end if;

					-- 4. asset number and work order association is correct.
					if l_asset_number <> ' ' and l_org_id <> -9999 and l_wip_entity_id <> -9999 then
						-- bug  4146481. added NVL in query
						select count(*) into l_count from wip_discrete_jobs where
						nvl(asset_number,rebuild_serial_number) = l_asset_number and
						wip_entity_id = l_wip_entity_id and
						organization_id = l_org_id;
						if l_count = 0 then
							-- Add the corresponding error message to the message table
							msg_tkn := 'WO_NAME&'||l_wip_entity_name||'&' ||'AN_NAME&'||l_asset_number;
							Add_Error_To_Table( p_message_table => p_messages ,
							p_message_name            => 'EAM_OTL_AN_WO_INCORRECT',
							p_message_token           => msg_tkn,
							P_Message_Level           => 'ERROR',
							P_Message_Field           => NULL,
							p_application_short_name  => 'EAM',
							P_Timecard_bb_Id          =>
							P_time_Building_Blocks(i).Time_Building_Block_Id,
							P_Time_Attribute_Id       => l_attrib_count);
							msg_tkn := '';
						end if;
					end if;

					-- 5. operations do belong to the work order
					if l_wip_entity_id <> -9999 and l_org_id <> -9999 and l_operation_number <> -9999 then
						select count(*) into l_count from wip_operations where
						wip_entity_id = l_wip_entity_id and
						organization_id = l_org_id and
						operation_seq_num = l_operation_number;
						if l_count = 0 then
							-- Add the corresponding error message to the message table
							msg_tkn := 'OP_NAME&'||l_operation_number||'&' ||'WO_NAME&'||l_wip_entity_name;
							Add_Error_To_Table( p_message_table => p_messages ,
							p_message_name            => 'EAM_OTL_OP_WO_INCORRECT',
							p_message_token           => msg_tkn,
							P_Message_Level           => 'ERROR',
							P_Message_Field           => NULL,
							p_application_short_name  => 'EAM',
							P_Timecard_bb_Id          =>
							P_time_Building_Blocks(i).Time_Building_Block_Id,
							P_Time_Attribute_Id       => l_attrib_count);
							msg_tkn := '';
						end if;
					end if;

					-- 6. Check whether department and operation association is correct.
					if l_wip_entity_id <> -9999 and l_org_id <> -9999 and l_operation_number <> -9999
					and l_dept_id <> -9999 then
						select count(*) into l_count from wip_operations where
						wip_entity_id = l_wip_entity_id and
						operation_seq_num = l_operation_number and
						organization_id = l_org_id and
						department_id = l_dept_id;
						if l_count = 0 then
							-- Add the corresponding error message to the message table
							msg_tkn := 'OP_NAME&'||l_operation_number||'&' ||'DP_NAME&'||l_dept_name;
							Add_Error_To_Table( p_message_table => p_messages ,
							p_message_name            => 'EAM_OTL_OP_DEPT_INCORRECT',
							p_message_token           => msg_tkn,
							P_Message_Level           => 'ERROR',
							P_Message_Field           => NULL,
							p_application_short_name  => 'EAM',
							P_Timecard_bb_Id          =>
							P_time_Building_Blocks(i).Time_Building_Block_Id,
							P_Time_Attribute_Id       => l_attrib_count);
							msg_tkn := '';
						end if;
					end if;

					-- 7. Check whether the resources belong to the correct department and
					--   are either assigned or shared resources for the department
					if l_resource_id <> -9999 and l_dept_id <> -9999 then
						select count(*) into l_count from (select  br.resource_code,
                                                br.description,
                                                br.resource_type,
                                                br.functional_currency_flag,
                                                2 autocharge_type,
                                                br.unit_of_measure uom_code,
                                                br.unit_of_measure uom,
                                                br.default_basis_type basis_type, ca.activity_id,
                                                ca.activity,
                                                br.standard_rate_flag,
                                                br.organization_id,
                                                to_char(bdr.department_id) as department_id,
                                                (select meaning from mfg_lookups m1 where m1.lookup_type like 'BOM_RESOURCE_TYPE' and  m1.lookup_code =  2) meaning,
                                                to_char(br.resource_id) as res_id
                                                from cst_activities ca,
                                                bom_department_resources bdr,
                                                bom_resources br
                                                where br.resource_id = bdr.resource_id and
                                                br.default_activity_id = ca.activity_id (+) and
                                                nvl(ca.disable_date(+),sysdate+1) > sysdate and
                                                nvl(br.disable_date,sysdate+1) > sysdate and   (ca.organization_id is
                                                null or ca.organization_id = br.organization_id)
                                                order by br.resource_code
						)
						where res_id = l_resource_id
						and department_id = l_dept_id;
						if l_count = 0 then
							-- Add the corresponding error message to the message table
							msg_tkn := 'RS_NAME&'||l_resource_name||'&' ||'DP_NAME&'||l_dept_name;
							Add_Error_To_Table( p_message_table => p_messages ,
							p_message_name            => 'EAM_OTL_RES_DEPT_INCORRECT',
							p_message_token           => msg_tkn,
							P_Message_Level           => 'ERROR',
							P_Message_Field           => NULL,
							p_application_short_name  => 'EAM',
							P_Timecard_bb_Id          =>
							P_time_Building_Blocks(i).Time_Building_Block_Id,
							P_Time_Attribute_Id       => l_attrib_count);
							msg_tkn := '';
						end if;
					end if;

					-- 8. Charge department is correct for the resource, where in the charge
					--     department is the one where the resource is either owned or shared.
					-- Added union clause to take care of the shared resources too - Bug 3873717
					if l_charge_dept <> -9999 and l_resource_id <> -9999 then
						select count(*) into l_count from (select distinct bd.department_code,
						bd.organization_id,
						bd.description,
						to_char(bdri.department_id) as department_id,
						to_char(ppf.person_id) as person_id,
						bdri.resource_id as resource_id
						from bom_dept_res_instances bdri,
						bom_departments bd,
						bom_resource_employees bre,
						per_people_f ppf
						where bdri.instance_id = bre.instance_id
						and ppf.person_id = bre.person_id
						and bd.department_id = bdri.department_id
						and sysdate >= ppf.effective_start_date
						and sysdate <= ppf.effective_end_date
						union
						select distinct bd.department_code,
						bd.organization_id,
						bd.description,
						to_char(bdr.department_id) as department_id,
						to_char(ppf.person_id) as person_id,
						bdri.resource_id as resource_id
						from bom_dept_res_instances bdri,
						bom_departments bd,
						bom_resource_employees bre,
						bom_department_resources bdr,
						per_people_f ppf
						where bdri.instance_id = bre.instance_id
						and ppf.person_id = bre.person_id
						and sysdate >= ppf.effective_start_date and sysdate <= ppf.effective_end_date
						and bd.department_id = bdr.department_id
						and bdr.share_from_dept_id = bdri.department_id
						and bdr.resource_id = bdri.resource_id
						)

						where department_id = l_charge_dept
						and resource_id = l_resource_id;
						if l_count = 0 then
							-- Add the corresponding error message to the message table
							msg_tkn := 'CH_DEPT&'||l_charge_dept_name||'&' ||'RS_NAME&'||l_resource_name;
							Add_Error_To_Table( p_message_table => p_messages ,
							p_message_name            => 'EAM_OTL_CHRG_DEPT_INCORRECT',
							p_message_token           => msg_tkn,
							P_Message_Level           => 'ERROR',
							P_Message_Field           => NULL,
							p_application_short_name  => 'EAM',
							P_Timecard_bb_Id          =>
							P_time_Building_Blocks(i).Time_Building_Block_Id,
							P_Time_Attribute_Id       => l_attrib_count);
							msg_tkn := '';
						end if;
					end if;

					if p_time_building_blocks(i).scope = 'TIMECARD' then
						l_start_time := p_time_building_blocks(i).start_time;
						l_stop_time  := p_time_building_blocks(i).stop_time;
					end if;


					-- 9. Check whether the start and end dates are within the accounting
					--    periods or not
					if l_start_time <> SYSDATE - 100000 and
					l_stop_time <> SYSDATE - 100000 and
					l_org_id <> -9999 and
					p_time_building_blocks(i).scope = 'TIMECARD' then
						select nvl(min(period_start_date), (sysdate - 200000)),
						nvl(max(schedule_close_date),(sysdate + 200000))
						into l_min_acct_period_date,l_max_acct_period_date
						from org_acct_periods
						where organization_id = l_org_id
						and upper(open_flag) = 'Y';
						if l_start_time <= l_min_acct_period_date OR
						l_stop_time  >=  l_max_acct_period_date then
							-- Add the corresponding error message to the message table
							msg_tkn := 'ST_TIME&'||l_start_time||'&' || 'EN_TIME&'||l_stop_time;
							Add_Error_To_Table( p_message_table => p_messages ,
							p_message_name            => 'EAM_OTL_NOT_IN_ACCT_PER',
							p_message_token           => msg_tkn,
							P_Message_Level           => 'ERROR',
							P_Message_Field           => NULL,
							p_application_short_name  => 'EAM',
							P_Timecard_bb_Id          =>
							P_time_Building_Blocks(i).Time_Building_Block_Id,
							P_Time_Attribute_Id       => l_attrib_count);
							msg_tkn := '';
						end if;
					end if;

					-- Code changes for supporting Timekeeper functionality;
					-- Robust check on dates

					-- 10. Check whether the start date and end date are less than the
					--     sysdate for a day scope building block. Also checking if the
                    --     start time is less than released date of the workorder
					if upper(p_time_building_blocks(i).scope) = 'DETAIL' and
							p_time_building_blocks(i).parent_building_block_id is not null then

						l_parent_bb_id := p_time_building_blocks(i).parent_building_block_id;
						-- Loop through the l_current_week_tc to find the parent BB and
						-- subsequently the parent's start time and stop times

						d := 0;

						k:= l_current_week_tc.FIRST;

						LOOP
						EXIT when not l_current_week_tc.exists(k);


							if l_current_week_tc(k).time_building_block_id = l_parent_bb_id then

								d := 1;
                                l_exact_start_time := p_time_building_blocks(i).start_time;
                                if(l_exact_start_time is null) then
                                  l_exact_start_time := l_current_week_tc(k).start_time;
                                end if;


								if l_current_week_tc(k).start_time >= SYSDATE then

									msg_tkn := 'ST_TIME&'||l_current_week_tc(k).start_time;
									Add_Error_To_Table( p_message_table => p_messages ,
									p_message_name            => 'EAM_OTL_FUTURE_DATE_ERR',
									p_message_token           => msg_tkn,
									P_Message_Level           => 'ERROR',
									P_Message_Field           => NULL,
									p_application_short_name  => 'EAM',
									P_Timecard_bb_Id          =>
									P_time_Building_Blocks(i).Time_Building_Block_Id,
									P_Time_Attribute_Id       => l_attrib_count);
									msg_tkn := '';

								end if;
                                select date_released into l_wo_released_date
                                from wip_discrete_jobs
                                where wip_entity_id = l_wip_entity_id
                                and organization_id = l_org_id;


                                if l_exact_start_time < l_wo_released_date then

                                  msg_tkn := 'ST_TIME&'||l_exact_start_time;
                                  Add_Error_To_Table( p_message_table => p_messages ,
                                  p_message_name            => 'EAM_OTL_DATE_LT_REL_ERR',
                                  p_message_token           => msg_tkn,
                                  P_Message_Level           => 'ERROR',
                                  P_Message_Field           => NULL,
    	                          p_application_short_name  => 'EAM',
                                  P_Timecard_bb_Id          =>
                                  P_time_Building_Blocks(i).Time_Building_Block_Id,
                                  P_Time_Attribute_Id       => l_attrib_count);
                                  msg_tkn := '';

                                 end if;


							end if; -- end of check for time building block id


							EXIT when d =1;
							k := l_current_week_tc.next(k);

						END LOOP;

					end if;

					-- 11. Check whether the user has entered atleast a workorder, resource
					--     or operation
					if upper(p_time_building_blocks(i).scope) = 'DETAIL' and
							l_wip_entity_id    = -9999 and l_resource_id      = -9999 and
							l_operation_number = -9999	then
						Add_Error_To_Table( p_message_table => p_messages ,
						p_message_name            => 'EAM_OTL_INSUFFICIENT_INFO',
						p_message_token           => msg_tkn,
						P_Message_Level           => 'ERROR',
						P_Message_Field           => NULL,
						p_application_short_name  => 'EAM',
						P_Timecard_bb_Id          =>
						P_time_Building_Blocks(i).Time_Building_Block_Id,
						P_Time_Attribute_Id       => l_attrib_count);
					end if;

					/* As per decision of upper management, it was decided not to
					check for the dates being in MFG holiday. Hence commenting
					out this validation.
					-- 12. Check whether the day is in a MFG calendar work day or not

					if upper(p_time_building_blocks(i).scope) = 'DETAIL' and
					p_time_building_blocks(i).parent_building_block_id is not null then

						l_parent_bb_id := p_time_building_blocks(i).parent_building_block_id;
						-- Loop through the l_current_week_tc to find the parent BB and
						-- subsequently the parent's start time and stop times
						for k in l_current_week_tc.FIRST .. l_current_week_tc.last loop
							if l_current_week_tc(k).time_building_block_id = l_parent_bb_id then
								validate_work_day(p_date  => l_current_week_tc(k).start_time,
								p_organization_id     => l_org_id,
								x_status              => l_return_status);
								if l_return_status = 1 then
									msg_tkn := 'ST_TIME&'||l_current_week_tc(k).start_time;
									Add_Error_To_Table( p_message_table => p_messages ,
									p_message_name            => 'EAM_OTL_MFG_HOLIDAY_ERR',
									p_message_token           => msg_tkn,
									P_Message_Level           => 'ERROR',
									P_Message_Field           => NULL,
									p_application_short_name  => 'EAM',
									P_Timecard_bb_Id          =>
									P_time_Building_Blocks(i).Time_Building_Block_Id,
									P_Time_Attribute_Id       => l_attrib_count);
									msg_tkn := '';
								end if;
							end if;
						end loop;
					end if;
					*/ --End of comment for validation 12.

				end if; -- End of check attributes for detail time building blocks

			end if ;

			i:= p_time_building_blocks.next(i);

		end loop; -- end of check for : i is not null loop

	end if; -- end of check for p_time_building_blocks.count <> 0

	-- end of time bldg blk processing loop

	EXCEPTION
	WHEN OTHERS THEN
	Add_Error_To_Table( p_message_table => p_messages ,
	p_message_name            => 'EAM_OTL_GEN_ERR',
	p_message_token           => msg_tkn,
	P_Message_Level           => 'ERROR',
	P_Message_Field           => NULL,
	p_application_short_name  => 'EAM',
	P_Timecard_bb_Id          => l_time_bb_id,
	P_Time_Attribute_Id       => l_attrib_count);

END eam_validate_timecard;




-- public procedure
--   add_error_to_table
--
-- description
--   adds error to the TCO message stack
PROCEDURE add_error_to_table (
		p_message_table	IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.MESSAGE_TABLE
	   ,p_message_name  IN     FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
	   ,p_message_token IN     VARCHAR2
	   ,p_message_level IN     VARCHAR2
           ,p_message_field IN     VARCHAR2
	   ,p_application_short_name IN VARCHAR2 -- default 'EAM'
	   ,p_timecard_bb_id     IN     NUMBER
	   ,p_time_attribute_id  IN     NUMBER) is

  l_last_index BINARY_INTEGER;

BEGIN

  l_last_index := NVL(p_message_table.last,0);

  p_message_table(l_last_index+1).message_name := p_message_name;
  p_message_table(l_last_index+1).message_level := p_message_level;
  p_message_table(l_last_index+1).message_field := p_message_field;
  p_message_table(l_last_index+1).message_tokens:= p_message_token;
  p_message_table(l_last_index+1).application_short_name := p_application_short_name;
  p_message_table(l_last_index+1).time_building_block_id := p_timecard_bb_id;
  p_message_table(l_last_index+1).time_attribute_id := p_time_attribute_id;

END add_error_to_table;



END EAM_OTL_TIMECARD_PUB; -- package body

/
