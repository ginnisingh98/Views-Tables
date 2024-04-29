--------------------------------------------------------
--  DDL for Package Body WIP_EAM_RESOURCE_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EAM_RESOURCE_TRANSACTION" as
/* $Header: wiprstxb.pls 120.14.12010000.6 2009/11/18 09:21:35 vboddapa ship $ */

 g_pkg_name    CONSTANT VARCHAR2(30):= 'WIP_EAM_RESOURCE_TRANSACTION';

      PROCEDURE resource_validate (
          p_api_version        IN       NUMBER
         ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
         ,p_commit             IN       VARCHAR2 := fnd_api.g_false
         ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
         ,p_wip_entity_id      IN       NUMBER
         ,p_operation_seq_num  IN       NUMBER
         ,p_organization_id    IN       NUMBER
         ,p_resource_seq_num   IN       NUMBER
         ,p_resource_code      IN       VARCHAR2
         ,p_uom_code           IN       VARCHAR2
         ,p_employee_name      IN       VARCHAR2
         ,p_equipment_name     IN       VARCHAR2
         ,p_reason             IN       VARCHAR2
         ,p_charge_dept        IN       VARCHAR2
         ,p_start_time         IN       DATE DEFAULT TRUNC(SYSDATE) --for bug 8532793
         ,x_resource_seq_num   OUT NOCOPY      NUMBER
         ,x_actual_resource_rate OUT NOCOPY    NUMBER
         ,x_status             OUT NOCOPY      NUMBER
         ,x_res_status         OUT NOCOPY      NUMBER
         ,x_uom_status         OUT NOCOPY      NUMBER
         ,x_employee_status    OUT NOCOPY      NUMBER
         ,x_employee_id        OUT NOCOPY      NUMBER
         ,x_employee_number    OUT NOCOPY      VARCHAR2
         ,x_equipment_status   OUT NOCOPY      NUMBER
         ,x_reason_status      OUT NOCOPY      NUMBER
         ,x_charge_dept_status OUT NOCOPY      NUMBER
         ,x_machine_status     OUT NOCOPY      NUMBER
         ,x_person_status      OUT NOCOPY      NUMBER
	 ,x_work_order_status  OUT NOCOPY      NUMBER
         ,x_instance_id        OUT NOCOPY      NUMBER
         ,x_charge_dept_id     OUT NOCOPY      NUMBER
         ,x_return_status      OUT NOCOPY      VARCHAR2
         ,x_msg_count          OUT NOCOPY      NUMBER
         ,x_msg_data           OUT NOCOPY      VARCHAR2)

       IS
          l_api_name       CONSTANT VARCHAR2(30) := 'resource_validate';
          l_api_version    CONSTANT NUMBER       := 1.0;
          l_wip_entity_id         NUMBER := 0;
          l_operation_seq_num     NUMBER := 0;
          l_stmt_num              NUMBER := 0;
          l_resource_id           NUMBER := 0;
          l_resource_id1          NUMBER := 0;
          l_resource_seq_num      NUMBER := 0;
          l_invalid_combo_status  NUMBER := 0;
          l_temp_resource_id      NUMBER := 0;
          l_res_exists_status     NUMBER := 0;
          res_exists              NUMBER := 0;
          l_res_seq_num           NUMBER := 0;
          l_res_code              VARCHAR2(80) ;
          l_res_id                NUMBER := 0;
          l_temp_res_id           NUMBER := 0;
          l_invalid_res_combo     NUMBER := 0;
          l_temp_resource_code    VARCHAR2(80) ;
          l_temp_resource_type    NUMBER;
          l_resource_type         NUMBER;
          l_resource_code1        VARCHAR2(80) ;
          resource_exists         NUMBER := 0;
          l_uom_code              VARCHAR2(30) ;
          uom_exists              NUMBER := 0;
          uom_status              NUMBER := 0;
          employee_exists         NUMBER := 0;
          employee_status         NUMBER := 0;
          l_empl_full_name        VARCHAR2(240) ;
          equipment_exists        NUMBER := 0;
          equipment_status        NUMBER := 0;
          l_equip_serial_no       VARCHAR2(80) ;
          reason_exists           NUMBER := 0;
          reason_status           NUMBER := 0;
          l_reason                VARCHAR2(240) ;
          charge_dept_exists      NUMBER := 0;
          charge_dept_status      NUMBER := 0;
          l_charge_dept           VARCHAR2(240) ;
          l_person_status         NUMBER := 0;
          l_machine_status        NUMBER := 0;
          l_person_id             NUMBER := 0;
          l_employee_number       VARCHAR2(30) ;
          l_actual_employee_id    NUMBER := 0;
          l_actual_employee_number VARCHAR2(30) ;
          l_charge_dept_id        NUMBER := 0;
          l_actual_charge_dept_id  NUMBER := 0;
          l_owning_department_id   NUMBER := 0;
          l_instance_id            NUMBER := 0;


            l_status_type            NUMBER ;
            l_we_entity_type         NUMBER ;


          v_resource_code         BOM_RESOURCES.RESOURCE_CODE%TYPE;

        --added the cursor in the declare section instead of putting inline cursors
           CURSOR c_res_in_bom_cur IS --rhshriva
	          Select resource_id,resource_code
	          from bom_resources
                  where organization_id =p_organization_id;

            CURSOR c_res_cur IS   --rhshriva
	      select br.resource_id,br.resource_code,br.resource_type
	      from
	      cst_activities ca,
	      bom_department_resources bdr,
	      bom_resources br
	      where br.organization_id = p_organization_id
	      and bdr.department_id = (select department_id
	                                             from wip_operations
	                                             where organization_id = p_organization_id
	                                             and wip_entity_id =p_wip_entity_id
	                                             and operation_seq_num =  p_operation_seq_num )
	      and br.resource_id = bdr.resource_id
	      and br.default_activity_id = ca.activity_id (+)
	      and nvl(ca.disable_date(+),sysdate+1) > sysdate
	      and nvl(br.disable_date,sysdate+1) > sysdate
	      and (ca.organization_id is null or ca.organization_id =p_organization_id );

            CURSOR c_res_seq_num IS    --rhshriva
	             select wor.resource_seq_num,
	                     br.resource_code,
	                     br.resource_id
	               from cst_activities ca,
	                    bom_resources br,
	                    wip_operation_resources wor
	              where wor.repetitive_schedule_id is null
	              and  br.organization_id = wor.organization_id
	              and  wor.resource_id = br.resource_id
	              and wor.activity_id = ca.activity_id (+)
	              and nvl(ca.disable_date(+),sysdate+1)> sysdate
	              and wor.organization_id =  p_organization_id
	              and wor.wip_entity_id =p_wip_entity_id
               and    wor.operation_seq_num = p_operation_seq_num ;



              CURSOR c_uom_cur(l_temp_res_id1  NUMBER)  IS   --rhshriva
	              select distinct muc.uom_code
	                  from mtl_uom_conversions muc,mtl_units_of_measure muom
	                  where muom.uom_code = muc.uom_code
	                    and muc.inventory_item_id = 0
	                    and nvl(muc.disable_date,sysdate+1) >sysdate
	                    and muc.uom_class in (select muc2.uom_class
	                                         from mtl_uom_conversions muc2,bom_resources br
                                                 where muc2.inventory_item_id = 0
                                                 and muc2.uom_code = br.unit_of_measure
                                                 and br.resource_id = l_temp_res_id1);


               CURSOR c_empl_cur(l_temp_res_id2  NUMBER) IS    --rhshriva
                select distinct full_name,person_id,employee_number
                 from per_people_f
                 where
		  p_start_time BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE --for bug 8532793
		       and person_id in (select person_id
                                       from bom_resource_employees
                                       where organization_id =p_organization_id
                                and resource_id = l_temp_res_id2 );

             CURSOR c_equip_cur(l_temp_res_id3 NUMBER) IS --for     rhshriva
	            select distinct serial_number
	             from bom_dept_res_instances
	             where instance_id in (select instance_id
	                                     from bom_resource_equipments
	                                     where organization_id =p_organization_id
                                   and resource_id =l_temp_res_id3 );

 /* Changed query for cursor to take care of the shared resources too - Bug 3873717 */
/* Bug  5262052 .Changed query to validate the resource code , irresepective of whether employee is entered or not.
	Resources can be charged w/o an employee.Proper employee are fetched in Employees LOV in JSP */

             CURSOR c_charge_dept_cur(l_temp_res_id4  NUMBER) IS
                              select distinct bd.department_code, bd.department_id
                      from bom_department_resources bdr, bom_departments bd
                      where bdr.department_id = bd.department_id
                      and bdr.resource_id = l_temp_res_id4 ;


         CURSOR c_reason_cur IS -- rhshriva
         select reason_name
         from mtl_transaction_reasons
         where  nvl(disable_date, sysdate + 1) > sysdate;

         -- Cursor to fetch if resource seq num corresponding to resource_id.
         CURSOR c_resource_seq_num IS
	           select resource_seq_num
	             from wip_operation_resources
	            where wip_entity_id = p_wip_entity_id
		    and   operation_seq_num = p_operation_seq_num
		    and   organization_id = p_organization_id
		    and   resource_id = l_resource_id;

         -- Cursor to fetch maximum resource sequence number attached to operation.
         CURSOR c_cur_resource_seq_num IS
	           select resource_seq_num
	             from wip_operation_resources
	            where wip_entity_id = p_wip_entity_id
		    and   operation_seq_num = p_operation_seq_num
		    and   organization_id = p_organization_id
		    order by resource_seq_num desc;

       BEGIN
          -- Standard Start of API savepoint
          l_stmt_num    := 10;
          SAVEPOINT get_resource_validate_pvt;

          l_stmt_num    := 20;
          -- Standard call to check for call compatibility.
          IF NOT fnd_api.compatible_api_call(
                l_api_version
               ,p_api_version
               ,l_api_name
               ,g_pkg_name) THEN
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          l_stmt_num    := 30;
          -- Initialize message list if p_init_msg_list is set to TRUE.
          IF fnd_api.to_boolean(p_init_msg_list) THEN
             fnd_msg_pub.initialize;
          END IF;

          l_stmt_num    := 40;
          --  Initialize API return status to success
          x_return_status := fnd_api.g_ret_sts_success;

          l_stmt_num    := 50;
          -- API body

          l_wip_entity_id := p_wip_entity_id;
          l_operation_seq_num := p_operation_seq_num;
	  l_resource_seq_num := p_resource_seq_num;

          v_resource_code := p_resource_code ;

          l_stmt_num := 60;



          open c_res_in_bom_cur ;--for  --rhshriva

         LOOP
         fetch c_res_in_bom_cur into l_resource_id1, l_resource_code1;
         exit when c_res_in_bom_cur%NOTFOUND;

         if (l_resource_code1 = v_resource_code) then
            resource_exists := 1;

        l_stmt_num := 70;

        -- Check whether the resource code entered is valid and matches with a resource in BOM_RESOURCES
        open c_res_cur ;

            l_stmt_num := 75;

            LOOP

            fetch c_res_cur into l_temp_resource_id,l_temp_resource_code,l_temp_resource_type ;
            Exit when c_res_cur%NOTFOUND;

            l_stmt_num := 80;

            if (l_temp_resource_code = l_resource_code1) then
               res_exists := 1;
               l_temp_res_id := l_temp_resource_id;  -- actual checking of the resource
               l_resource_type := l_temp_resource_type;
            end if;
            end loop;
           close c_res_cur;
           end if;
          end loop;
         close c_res_in_bom_cur;

           l_stmt_num := 90;

           --Set the status to show that the resource exists.. resource_exists = 0 means it does not exist else it exists

           if(resource_exists = 0) then
            l_res_exists_status := 1;
           end if;

           if (res_exists = 0) then
            l_res_exists_status := 1;
           end if;

           l_stmt_num := 100;

           if (p_employee_name is not null) then

               if (l_resource_type <> 2) then
                 l_person_status := 1;

               end if;
           end if;

           if (p_equipment_name is not null) then

              if (l_resource_type <> 1) then
                 l_machine_status := 1;
              end if;
           end if;

           x_machine_status := l_machine_status;
           x_person_status := l_person_status;

           -- Check the resource code - resource sequence combination, in order to verify any illegal entry throgh the JSP

           if (p_resource_code is not null) then
             select resource_id into l_resource_id from bom_resources where resource_code = p_resource_code and organization_id = p_organization_id ;
           end if;

	   if(l_resource_id <> 0 and l_resource_seq_num is null) then

	      open c_resource_seq_num;
	      fetch c_resource_seq_num into l_resource_seq_num;
	      if (c_resource_seq_num%NOTFOUND) then
		     open c_cur_resource_seq_num;
		     fetch c_cur_resource_seq_num into l_resource_seq_num;
		     if (c_cur_resource_seq_num%NOTFOUND) then
			  l_resource_seq_num := 10;
		     else
			  l_resource_seq_num := l_resource_seq_num + 1;
		     end if;
		     close c_cur_resource_seq_num;
	       end if;
	   end if;
           x_resource_seq_num := l_resource_seq_num;


           if (l_temp_res_id <> 0) then
           open c_res_seq_num;

           l_stmt_num := 110;

           loop

           fetch c_res_seq_num into l_res_seq_num, l_res_code, l_res_id ;
           exit when c_res_seq_num % NOTFOUND;

           l_stmt_num := 120;

           -- Check for resource_code and resource_sequence combination

           if (l_res_seq_num = l_resource_seq_num ) and  (l_res_id <> l_resource_id) then
                    l_invalid_res_combo := 1;
           end if;
            end loop;
            close c_res_seq_num;

            end if;


         if (l_invalid_res_combo = 1) then
           l_invalid_combo_status := 1;
         end if;

          x_status := l_invalid_combo_status;
          x_res_status := l_res_exists_status;

          -- Check for UOM entered through the JSP

          open c_uom_cur(l_temp_res_id1=> l_temp_res_id);
         loop
         fetch c_uom_cur into l_uom_code;
         EXIT WHEN c_uom_cur%NOTFOUND;

         -- Actual check for UOM value entered with the valid values of UOM

           if (upper(l_uom_code) = upper(p_uom_code)) then
              uom_exists := 1;
           end if;
         end loop;
         close c_uom_cur;

         if (uom_exists = 0) then
            uom_status := 1;
         end if;

         x_uom_status := uom_status;

         -- Check for employee name entered through the JSP

         if (p_employee_name is not null) then

         open c_empl_cur(l_temp_res_id2=>l_temp_res_id);
          loop
          fetch c_empl_cur into l_empl_full_name,l_person_id,l_employee_number;
          EXIT WHEN c_empl_cur%NOTFOUND;

          -- Check for the employee name within the valid values of employee name
          if (l_empl_full_name = p_employee_name) then
             employee_exists := 1;
             l_actual_employee_id := l_person_id;
             l_actual_employee_number := l_employee_number;
             x_employee_id := l_actual_employee_id;
             x_employee_number := l_actual_employee_number;
             select instance_id into l_instance_id from bom_resource_employees where resource_id = l_temp_res_id and person_id = l_actual_employee_id;
          end if;
          end loop;
          close c_empl_cur;

          if (employee_exists = 0) then
             employee_status := 1;
          end if;

          --Bug 2182515: populate actual labor rate if employee instance given
          if (employee_exists = 1) then
		  BEGIN
		    SELECT	 hourly_labor_rate
		    INTO	 x_actual_resource_rate
		    FROM	 wip_employee_labor_rates
		    WHERE	 employee_id = l_actual_employee_id
		    AND	organization_id = p_organization_id
		    AND	effective_date = (
				SELECT	MAX(effective_date)
				FROM	wip_employee_labor_rates
				WHERE	employee_id = l_actual_employee_id
				AND		organization_id = p_organization_id
				AND		effective_date <= sysdate
							);
		  EXCEPTION
			  WHEN NO_DATA_FOUND THEN
		 --OK: will happen if no labor rate is defined .
			   x_actual_resource_rate := null;
		  END;
          end if; -- employee_exists = 1

          end if;  -- p_employee_name is not null

          x_employee_status := employee_status;

          -- Check for equipment name entered through JSP

          if (p_equipment_name is not null) then

          open c_equip_cur(l_temp_res_id3=>l_temp_res_id) ;
          loop
          fetch c_equip_cur into l_equip_serial_no;
          EXIT WHEN c_equip_cur%NOTFOUND;

          -- Check for equipment name to find out that the value entered does indeed exist in the valid list of values

          if (l_equip_serial_no = p_equipment_name ) then
           equipment_exists := 1;
           select instance_id into l_instance_id from bom_dept_res_instances where resource_id = l_temp_res_id and serial_number = l_equip_serial_no ;
          end if;
          end loop;
          close c_equip_cur;

          if (equipment_exists = 0) then
           equipment_status := 1;
          end if;

          end if;

          x_equipment_status := equipment_status;

          -- Check for reason entered through the JSP

          if (p_reason is not null) then
          open c_reason_cur ;
          loop
          fetch c_reason_cur into l_reason;
          EXIT WHEN c_reason_cur%NOTFOUND;

          -- Check to see that the value entered does indeed match with any valid value from the table

          if (l_reason = p_reason ) then
           reason_exists := 1;
          end if;
          end loop;
          close c_reason_cur;

          if (reason_exists = 0) then
           reason_status := 1;
          end if;

          end if;

          x_reason_status := reason_status;

          if (p_wip_entity_id is not null) then
          select owning_department into l_owning_department_id from wip_discrete_jobs where wip_entity_id = p_wip_entity_id;
          end if;


          -- Check for Charge Department entered through the JSP

          if (p_charge_dept is not null) then

          open c_charge_dept_cur(l_temp_res_id4=>l_temp_res_id);
          loop
          fetch c_charge_dept_cur into l_charge_dept, l_charge_dept_id;
          EXIT WHEN c_charge_dept_cur%NOTFOUND;

          -- Check to see that the value entered does indeed match with the valid List Of Values

          if (l_charge_dept = p_charge_dept) then
             charge_dept_exists := 1;
             l_actual_charge_dept_id := l_charge_dept_id;
          end if;
          end loop;
          close c_charge_dept_cur;

          if (charge_dept_exists = 0) then
            charge_dept_status := 1;
          end if;




          end if;

        --start of fix for 3949853

             select wdj.status_type, we.entity_type
             into l_status_type, l_we_entity_type
             from wip_discrete_jobs wdj, wip_entities we
             where wdj.wip_entity_id = we.wip_entity_id
             and wdj.wip_entity_id = l_wip_entity_id;

             if ( ((l_status_type = 3) or (l_status_type = 4)) and l_we_entity_type = 6) then
                     x_work_order_status := 0;
             else
                     x_work_order_status := 1;
             end if;
         --end of fix for 3949853

          x_charge_dept_status := charge_dept_status;
          x_charge_dept_id := l_actual_charge_dept_id;
          x_instance_id := l_instance_id;

          -- End of API body.
          -- Standard check of p_commit.
          IF fnd_api.to_boolean(p_commit) THEN
             COMMIT WORK;
          END IF;

          l_stmt_num    := 999;
          -- Standard call to get message count and if count is 1, get message info.
          fnd_msg_pub.count_and_get(
             p_count => x_msg_count
            ,p_data => x_msg_data);
       EXCEPTION
          WHEN fnd_api.g_exc_error THEN
             ROLLBACK TO get_resource_validate_pvt
             ;
             x_return_status := fnd_api.g_ret_sts_error;
             fnd_msg_pub.count_and_get(
    --            p_encoded => FND_API.g_false
                p_count => x_msg_count
               ,p_data => x_msg_data);
          WHEN fnd_api.g_exc_unexpected_error THEN
             ROLLBACK TO get_resource_validate_pvt;
             x_return_status := fnd_api.g_ret_sts_unexp_error;

             fnd_msg_pub.count_and_get(
                p_count => x_msg_count
               ,p_data => x_msg_data);
          WHEN OTHERS THEN
             ROLLBACK TO get_resource_validate_pvt;
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             IF fnd_msg_pub.check_msg_level(
                   fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
             END IF;

             fnd_msg_pub.count_and_get(
                p_count => x_msg_count
               ,p_data => x_msg_data);

       END resource_validate;





        PROCEDURE insert_into_wcti(
                 p_api_version        IN       NUMBER
                ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
                ,p_wip_entity_id      IN       NUMBER
                ,p_operation_seq_num  IN       NUMBER
                ,p_organization_id    IN       NUMBER
                ,p_transaction_qty    IN       NUMBER
                ,p_transaction_date   IN       DATE
                ,p_resource_seq_num   IN       NUMBER
                ,p_uom                IN       VARCHAR2
                ,p_resource_code      IN       VARCHAR2
                ,p_reason_name        IN       VARCHAR2
                ,p_reference          IN       VARCHAR2
                ,p_instance_id        IN       NUMBER
                ,p_serial_number      IN      	VARCHAR2
                ,p_charge_dept_id     IN       NUMBER
                ,p_actual_resource_rate IN    NUMBER
                ,p_employee_id        IN      NUMBER
                ,p_employee_number    IN      VARCHAR2
                ,x_return_status      OUT NOCOPY      VARCHAR2
                ,x_msg_count          OUT NOCOPY      NUMBER
                ,x_msg_data           OUT NOCOPY      VARCHAR2)

              IS
                 l_api_name       CONSTANT VARCHAR2(30) := 'insert_into_wcti';
                 l_api_version    CONSTANT NUMBER       := 1.0;
                 l_wip_entity_id         NUMBER := 0;
                 l_operation_seq_num     NUMBER := 0;
                 l_organization_id       NUMBER := 0;
                 l_stmt_num              NUMBER := 0;
                 l_groupid               NUMBER := 0;
                 l_source_code           VARCHAR2(30) ;
                 l_organization_code     VARCHAR2(30) ;
                 l_wip_entity_name       VARCHAR2(240) ;
                 l_entity_type           NUMBER := 0;
                 l_primary_item_id       NUMBER := 0;
                 l_project_id            NUMBER := 0;
                 l_task_id               NUMBER := 0;
                 l_resource_code         VARCHAR2(10) ;
                 l_resource_id           NUMBER := 0;
                 l_resource_type         NUMBER := 0;
                 l_uom		          VARCHAR2(10) ;
                 l_txn_uom               VARCHAR2(10) ;
                 l_usage_rate_or_amount  NUMBER := 0;
                 l_basis_type            NUMBER := 0;
                 l_activity_id           NUMBER := 0;
                 l_activity_name         VARCHAR2(10) ;
                 l_standard_rate_flag    NUMBER := 0;
                 l_acct_period_id        NUMBER := 0;
                 l_department_id         NUMBER := 0;
                 l_department_code       VARCHAR2(10) ;
                 l_reason_id             NUMBER := 0;
                 l_conversion_rate       NUMBER := 0;
                 l_primary_qty           NUMBER := 0;
                 l_res_seq_num_temp      NUMBER := 0;
                 old_res_status          NUMBER := 0;
                 l_start_date            DATE;
                 l_completion_date       DATE;
                 l_return_status         VARCHAR2(80) ;
                 l_msg_count             NUMBER := 0;
                 l_msg_data              varchar2(80) ;
                 l_transaction_date      DATE := p_transaction_date;
                 l_open                  BOOLEAN := false;

                 CURSOR c_cur_wor(l_wip_entity_id1 NUMBER,l_organization_id1 NUMBER,
                 l_operation_seq_num1  NUMBER ) IS --for     --rhshriva
		 select resource_seq_num
		 from wip_operation_resources
		 where wip_entity_id =l_wip_entity_id1 and
		 organization_id = l_organization_id1 and
                 operation_seq_num =  l_operation_seq_num1 ;


              BEGIN
                 -- Standard Start of API savepoint
                 l_stmt_num    := 10;
                 SAVEPOINT get_insert_into_wcti_pvt;

                 l_stmt_num    := 20;
                 -- Standard call to check for call compatibility.
                 IF NOT fnd_api.compatible_api_call(
                       l_api_version
                      ,p_api_version
                      ,l_api_name
                      ,g_pkg_name) THEN
                    RAISE fnd_api.g_exc_unexpected_error;
                 END IF;

                 l_stmt_num    := 30;
                 -- Initialize message list if p_init_msg_list is set to TRUE.
                 IF fnd_api.to_boolean(p_init_msg_list) THEN
                    fnd_msg_pub.initialize;
                 END IF;

                 l_stmt_num    := 40;
                 --  Initialize API return status to success
                 x_return_status := fnd_api.g_ret_sts_success;

                 l_stmt_num    := 50;
                 -- API body
                 l_wip_entity_id     := p_wip_entity_id;
                 l_operation_seq_num := p_operation_seq_num;
                 l_organization_id := p_organization_id;

                 l_stmt_num    := 60;

                 -- Get the Group Id

                 select wip_transactions_s.nextval into l_groupid from dual;

                 l_stmt_num := 70;

                l_stmt_num := 80;



                  l_stmt_num := 90;

                  -- Get Organization_Code

                  select organization_code into l_organization_code from mtl_parameters where organization_id = l_organization_id;

                  l_stmt_num := 100;

                  -- Get Wip_Enttity_Name and Primary Item Id

                  select wip_entity_name,entity_type,primary_item_id
                  into l_wip_entity_name, l_entity_type , l_primary_item_id
                  from wip_entities where organization_id = l_organization_id and wip_entity_id = l_wip_entity_id;

                  l_stmt_num := 110;

                  -- Get Project Id and Task Id

                  select project_id,task_id into l_project_id, l_task_id from wip_discrete_jobs
                  where organization_id = l_organization_id and wip_entity_id = l_wip_entity_id;

                  l_stmt_num := 120;


		   -- check transaction_date, if null, default to sysdate
                   if (l_transaction_date is null) then
                     l_transaction_date := sysdate;
                   end if;


                  -- Get Account Period Id corresponding to sysdate

                  INVTTMTX.tdatechk(org_id  => l_organization_id,
                     transaction_date  => sysdate,
                     period_id       => l_acct_period_id,
                     open_past_period   => l_open);

                  select min(acct_period_id) into l_acct_period_id from org_acct_periods
                  where  trunc(l_transaction_date) >= trunc(period_start_date)
		    and  trunc(l_transaction_date) <= trunc(schedule_close_date)
		    and  organization_id = l_organization_id
		    and  period_close_date is null;

                  l_stmt_num := 130;

                  -- Get Department Id and Department Code

                  select bd.department_id,bd.department_code
                  into l_department_id, l_department_code
                  from wip_operations wo, bom_departments bd
                  where wo.wip_entity_id = l_wip_entity_id and wo.organization_id = l_organization_id
                  and wo.operation_seq_num = l_operation_seq_num and wo.department_id = bd.department_id(+);

                  l_stmt_num := 140;

                  -- Get Reason Id

                  if (p_reason_name is not null) then
                   select reason_id into l_reason_id from mtl_transaction_reasons where reason_name = p_reason_name;
                  end if;

                  -- Get resource_id, resource_code, resource_type, uom, basis_type, activity_id, activity and standard_rate_flag

                  if (p_resource_code is not null) then
                  l_stmt_num := 150;
                  select br.resource_id,
                         br.resource_code,
                         br.resource_type,
                         br.unit_of_measure uom_code,
                         br.default_basis_type basis_type,
                         ca.activity_id,
                         ca.activity,
                         br.standard_rate_flag
                         into
                         l_resource_id,
                         l_resource_code,
                         l_resource_type,
                         l_uom,
                         l_basis_type,
                         l_activity_id,
                         l_activity_name,
                         l_standard_rate_flag
                         from
                         cst_activities ca,
                         bom_department_resources bdr,
                         bom_resources br
                         where br.organization_id = l_organization_id
                         and bdr.department_id = (select department_id
                                                  from wip_operations
                                                  where organization_id = l_organization_id
                                                  and wip_entity_id = l_wip_entity_id
                                                  and operation_seq_num = l_operation_seq_num)
                         and br.resource_id = bdr.resource_id
                         and br.default_activity_id = ca.activity_id (+)
                         and nvl(ca.disable_date(+),sysdate+1) > sysdate
                         and nvl(br.disable_date,sysdate+1) > sysdate
                         and (ca.organization_id is null or ca.organization_id = l_organization_id)
                         and resource_code = p_resource_code;

                   end if;

                   l_stmt_num := 160;

                   if p_uom is not null then
                    l_txn_uom := p_uom;
                   end if;

                   l_stmt_num := 170;

                   -- Get the conversion_rate corresponding to primary uom of resource and transaction uom

                   l_conversion_rate :=
           	          inv_convert.inv_um_convert(
           	            item_id       => 0,
           	            precision     => 38,
           	            from_quantity => 1,
           	            from_unit     => l_uom,
           	            to_unit       => l_txn_uom,
           	            from_name     => NULL,
                           to_name       => NULL);

                   l_stmt_num := 180;

                   --Get the primary quantity based on the conversion rate

                   l_primary_qty := round((p_transaction_qty / l_conversion_rate),6) ;

                   l_stmt_num := 190;

                   -- If the resource_sequence number entry does not exist in WIP_OPERATION_RESOURCES, then place a new entry

                   open c_cur_wor(l_wip_entity_id1 =>l_wip_entity_id,
                   l_organization_id1=>l_organization_id,
                   l_operation_seq_num1=>l_operation_seq_num) ;

                   LOOP
                   fetch c_cur_wor into l_res_seq_num_temp;
                   EXIT WHEN c_cur_wor%NOTFOUND;

                   -- Check whether the entry for resource_sequnece_num exists in WIP_OPERATION_RESOURCES

                   if (l_res_seq_num_temp = p_resource_seq_num) then
                    old_res_status := 1;

                    BEGIN
                    select nvl(usage_rate_or_amount,0)
		    into l_usage_rate_or_amount
		    from wip_operation_resources
		    where wip_entity_id = l_wip_entity_id
		    and operation_seq_num = l_operation_seq_num
		    and resource_seq_num = l_res_seq_num_temp
                    and organization_id = l_organization_id;
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    raise fnd_api.g_exc_unexpected_error;
                    END;

                   end if;
                   end loop;
                   close c_cur_wor ;

                   l_stmt_num := 200;

                   select scheduled_start_date, scheduled_completion_date
                   into l_start_date, l_completion_date
                   from wip_discrete_jobs where wip_entity_id = l_wip_entity_id;

                   l_stmt_num := 210;

                   if (old_res_status = 0) then

                   -- If entry does not exists in WIP_OPERATION_RESOURCES then place a new entry into WIP_OPERATION_RESOURCES

                      insert into wip_operation_resources(
                         WIP_ENTITY_ID
                        ,OPERATION_SEQ_NUM
                        ,RESOURCE_SEQ_NUM
                        ,ORGANIZATION_ID
                        ,REPETITIVE_SCHEDULE_ID
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATED_BY
                        ,CREATION_DATE
                        ,CREATED_BY
                        ,LAST_UPDATE_LOGIN
                        ,REQUEST_ID
                        ,PROGRAM_APPLICATION_ID
                        ,PROGRAM_ID
                        ,PROGRAM_UPDATE_DATE
                        ,RESOURCE_ID
                        ,UOM_CODE
                        ,BASIS_TYPE
                        ,USAGE_RATE_OR_AMOUNT
                        ,ACTIVITY_ID
                        ,SCHEDULED_FLAG
                        ,ASSIGNED_UNITS
                        ,AUTOCHARGE_TYPE
                        ,STANDARD_RATE_FLAG
                        ,APPLIED_RESOURCE_UNITS
                        ,APPLIED_RESOURCE_VALUE
                        ,START_DATE
                        ,COMPLETION_DATE
                        ,ATTRIBUTE_CATEGORY
                        ,ATTRIBUTE1
                        ,ATTRIBUTE2
                        ,ATTRIBUTE3
                        ,ATTRIBUTE4
                        ,ATTRIBUTE5
                        ,ATTRIBUTE6
                        ,ATTRIBUTE7
                        ,ATTRIBUTE8
                        ,ATTRIBUTE9
                        ,ATTRIBUTE10
                        ,ATTRIBUTE11
                        ,ATTRIBUTE12
                        ,ATTRIBUTE13
                        ,ATTRIBUTE14
                        ,ATTRIBUTE15
                        ,RELIEVED_RES_COMPLETION_UNITS
                        ,RELIEVED_RES_SCRAP_UNITS
                        ,RELIEVED_RES_COMPLETION_VALUE
                        ,RELIEVED_RES_SCRAP_VALUE
                        ,RELIEVED_VARIANCE_VALUE
                        ,TEMP_RELIEVED_VALUE
                        ,RELIEVED_RES_FINAL_COMP_UNITS
                        ,DEPARTMENT_ID
                        ,PHANTOM_FLAG
                        ,PHANTOM_OP_SEQ_NUM
                        ,PHANTOM_ITEM_ID
                        ,SCHEDULE_SEQ_NUM
                        ,SUBSTITUTE_GROUP_NUM
                        ,REPLACEMENT_GROUP_NUM
                        ,PRINCIPLE_FLAG
                        ,SETUP_ID
                        ,PARENT_RESOURCE_SEQ )

                        values(
                         l_wip_entity_id
                        ,l_operation_seq_num
                        ,p_resource_seq_num
                        ,l_organization_id
                        ,null
                        ,sysdate
                        ,FND_GLOBAL.user_id
                        ,sysdate
                        ,FND_GLOBAL.user_id
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,l_resource_id
                        ,l_uom
                        ,l_basis_type
                        ,0   -- usage rate or amount
                        ,null -- activity id
                        ,2  -- scheduled flag
                        ,1  -- assigned units
                        ,2  --autocharge type
                        ,2  -- standard rate flag
                        ,0  -- applied resource units
                        ,0  -- applied resource value
                        ,l_start_date
                        ,l_completion_date
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,l_department_id --populate operations dept. id
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        ,null
                        );
                    end if;

                  l_stmt_num := 220;

                  --Insert into WIP_COST_TXN_INTERFACE

                   insert into wip_cost_txn_interface(
                        transaction_id,
                        last_update_date,
                        last_updated_by,
                        last_updated_by_name,
                        creation_date,
                        created_by,
                        created_by_name,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        group_id,
                        source_code,
                        source_line_id,
                        process_phase,
                        process_status,
                        transaction_type,
                        organization_id,
                        organization_code,
                        wip_entity_id,
                        wip_entity_name,
                        entity_type,
                        line_id,
                        line_code,
                        primary_item_id,
                        repetitive_schedule_id,
                        transaction_date,
                        acct_period_id,
                        operation_seq_num,
                        resource_seq_num,
                        department_id,
                        department_code,
                        employee_id,
                        employee_num,
                        resource_id,
                        resource_code,
                        resource_type,
                        usage_rate_or_amount,
                        basis_type,
                        autocharge_type,
                        standard_rate_flag,
                        transaction_quantity,
                        transaction_uom,
                        primary_quantity,
                        primary_uom,
                        primary_uom_class,
                        actual_resource_rate,
                        currency_code,
                        currency_conversion_date,
                        currency_conversion_type,
                        currency_conversion_rate,
                        currency_actual_resource_rate,
                        activity_id,
                        activity_name,
                        reason_id,
                        reason_name,
                        reference,
                        move_transaction_id,
                        rcv_transaction_id,
                        po_header_id,
                        po_line_id,
                        receiving_account_id,
                        project_id,
                        task_id,
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
                        completion_transaction_id,
                        phantom_flag,
                        xml_document_id,
                        charge_department_id,
                        instance_id
                      ) values (
                        NULL, -- transaction_id
                        SYSDATE, -- last_update_date
                        FND_GLOBAL.user_id, -- last_updated_by
                        FND_GLOBAL.user_name, -- last_updated_by_name
                        SYSDATE, -- creation_date
                        FND_GLOBAL.user_id, -- created_by
                        FND_GLOBAL.user_name, -- created_by_name
                        NULL, -- last_update_login
                        NULL, -- request_id
                        NULL, -- program_application_id
                        NULL, -- program_id
                        NULL, -- program_update_date
                        NULL, -- groupid
                        null,  --source_code
                        NULL, -- source_line_id
                        2, -- process_phase
                        1, -- process_status
                        1, -- transaction_type
                        l_organization_id,
                        l_organization_code,
                        l_wip_entity_id,
                        l_wip_entity_name,
                        l_entity_type,
                        null,
                        null,
                        l_primary_item_id,
                        null, --x_first_schedule_id
                        l_transaction_date,
                        l_acct_period_id,
                        l_operation_seq_num,
                        p_resource_seq_num,
                        l_department_id,
                        l_department_code,
			decode(p_employee_id,0,null,p_employee_id),
                        p_employee_number,  -- employee number
                        l_resource_id,
                        l_resource_code,
                        l_resource_type,
                        decode(l_usage_rate_or_amount,0,null,l_usage_rate_or_amount), --usage_rate_or_amount
                        l_basis_type,
                        2, -- autocharge_type
                        l_standard_rate_flag,
                        p_transaction_qty,
                        l_txn_uom,
                        l_primary_qty,
                        l_uom,
                        NULL, -- primary_uom_class
                        p_actual_resource_rate,
                        null, -- currency_code
                        null, -- currency_conversion_date
                        null, -- currency_conversion_type
                        null, -- currency_conversion_rate
                        null, -- currency_actual_resource_rate
                        l_activity_id,
                        l_activity_name,
                        decode(l_reason_id,0,null,l_reason_id),
                        p_reason_name,
                        p_reference,
                        null, -- move_transaction_id
                        null, -- rcv_transaction_id
                        null, -- po_header_id
                        null, -- po_line_id
                        null, -- receiving_account_id
                        l_project_id,
                        l_task_id,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        decode(p_charge_dept_id,0,null,p_charge_dept_id),
                        decode(p_instance_id,0,null,p_instance_id)
                        );

                 l_stmt_num    := 230;

                 if (p_instance_id is not null and p_instance_id <> 0) then

                   WIP_EAM_RESOURCE_TRANSACTION.insert_into_wori (
                    p_api_version        =>  1.0
       	         ,p_init_msg_list      => fnd_api.g_false
       	         ,p_commit             => fnd_api.g_false
       	         ,p_validation_level   => fnd_api.g_valid_level_full
       	         ,p_wip_entity_id      => l_wip_entity_id
       	         ,p_operation_seq_num  => l_operation_seq_num
       	         ,p_organization_id    => l_organization_id
       	         ,p_resource_seq_num   => p_resource_seq_num
       	         ,p_instance_id        => p_instance_id
       	         ,p_serial_number      => p_serial_number
       	         ,p_start_date         => l_start_date
       	         ,p_completion_date    => l_completion_date
       	         ,x_return_status      => l_return_status
       	         ,x_msg_count          => l_msg_count
                    ,x_msg_data           => l_msg_data );

                  end if;




                 -- End of API body.
                 -- Standard check of p_commit.
                 IF fnd_api.to_boolean(p_commit) THEN
                    COMMIT WORK;
                 END IF;

                 l_stmt_num    := 999;
                 -- Standard call to get message count and if count is 1, get message info.
                 fnd_msg_pub.count_and_get(
                    p_count => x_msg_count
                   ,p_data => x_msg_data);
              EXCEPTION
                 WHEN fnd_api.g_exc_error THEN
                    ROLLBACK TO get_insert_into_wcti_pvt;
                    x_return_status := fnd_api.g_ret_sts_error;
                    fnd_msg_pub.count_and_get(
           --            p_encoded => FND_API.g_false
                       p_count => x_msg_count
                      ,p_data => x_msg_data);
                 WHEN fnd_api.g_exc_unexpected_error THEN
                    ROLLBACK TO get_insert_into_wcti_pvt;
                    x_return_status := fnd_api.g_ret_sts_unexp_error;

                    fnd_msg_pub.count_and_get(
                       p_count => x_msg_count
                      ,p_data => x_msg_data);
                 WHEN OTHERS THEN
                    ROLLBACK TO get_insert_into_wcti_pvt;
                    x_return_status := fnd_api.g_ret_sts_unexp_error;
                    IF fnd_msg_pub.check_msg_level(
                          fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
                    END IF;

                    fnd_msg_pub.count_and_get(
                       p_count => x_msg_count
                      ,p_data => x_msg_data);
          END insert_into_wcti;



          -- Procedure for inserting the instances into WIP_OP_RESOURCE_INSTANCES

          PROCEDURE insert_into_wori(
                     p_api_version        IN       NUMBER
                    ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                    ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                    ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                    ,p_wip_entity_id      IN       NUMBER
                    ,p_operation_seq_num  IN       NUMBER
                    ,p_organization_id    IN       NUMBER
                    ,p_resource_seq_num   IN       NUMBER
                    ,p_instance_id        IN       NUMBER
                    ,p_serial_number      IN       VARCHAR2
                    ,p_start_date         IN       DATE
                    ,p_completion_date    IN       DATE
                    ,x_return_status      OUT NOCOPY      VARCHAR2
                    ,x_msg_count          OUT NOCOPY      NUMBER
                    ,x_msg_data           OUT NOCOPY      VARCHAR2)

               IS
                     l_api_name       CONSTANT VARCHAR2(30) := 'insert_into_wori';
          	          l_api_version    CONSTANT NUMBER       := 1.0;
                     l_instance_id    NUMBER := 0;
                     row_exists       NUMBER := 0;
                     l_stmt_num       NUMBER := 0;

                   CURSOR c_cur_wori IS  --rhshriva
                   select instance_id
                   from wip_op_resource_instances
                   where wip_entity_id = p_wip_entity_id  and
          	   organization_id = p_organization_id  and
          	   operation_seq_num = p_operation_seq_num  and
                   resource_seq_num = p_resource_seq_num and
                   instance_id = p_instance_id ;


               BEGIN
          	            -- Standard Start of API savepoint
          	            l_stmt_num    := 10;
          	            SAVEPOINT get_insert_into_wori_pvt;

          	            l_stmt_num    := 20;
          	            -- Standard call to check for call compatibility.
          	            IF NOT fnd_api.compatible_api_call(
          	                  l_api_version
          	                 ,p_api_version
          	                 ,l_api_name
          	                 ,g_pkg_name) THEN
          	               RAISE fnd_api.g_exc_unexpected_error;
          	            END IF;

          	            l_stmt_num    := 30;
          	            -- Initialize message list if p_init_msg_list is set to TRUE.
          	            IF fnd_api.to_boolean(p_init_msg_list) THEN
          	               fnd_msg_pub.initialize;
          	            END IF;

          	            l_stmt_num    := 40;
          	            --  Initialize API return status to success
          	            x_return_status := fnd_api.g_ret_sts_success;

          	            l_stmt_num    := 50;
                    -- API body

                    -- Cursor to check whether the entry for the particular instance
                    -- already exists in the table WIP_OP_RESOURCE_INSTANCES

                    open c_cur_wori;

          	              LOOP
          	              fetch c_cur_wori into l_instance_id;
          	              EXIT WHEN c_cur_wori%NOTFOUND;

          	              l_stmt_num := 60;

          	              -- Check whether the entry for instance_id exists in WIP_OP_RESOURCE_INSTANCES

          	              if (l_instance_id = p_instance_id) then
          	               row_exists := 1;
          	              end if;
          	              end loop;
                      close c_cur_wori ;


                      l_stmt_num := 70;

                      -- If the entry does not exist in the WIP_OP_RESOURCE_INSTANCES
                      -- Insert into the table



                      if (row_exists = 0) then


           	   insert into wip_op_resource_instances (
           		wip_entity_id,
           		operation_seq_num,
           		resource_seq_num,
           		organization_id,
           		last_update_date,
           		last_updated_by,
           		creation_date,
           		created_by,
           		last_update_login,
           		instance_id,
           		serial_number,
           		start_date,
           		completion_date,
           		batch_id  )

           		values

           		(p_wip_entity_id,
           		 p_operation_seq_num,
           		 p_resource_seq_num,
           		 p_organization_id,
           		 sysdate,
           		 FND_GLOBAL.user_id,
           		 sysdate,
           		 FND_GLOBAL.user_id,
           		 null,
           		 p_instance_id,
           		 p_serial_number,
           		 p_start_date,
           		 p_completion_date,
           		 null);


           		 l_stmt_num := 80;

           	     end if;

           	     l_stmt_num := 800;

           	     -- End of API body.
          	               -- Standard check of p_commit.
          	               IF fnd_api.to_boolean(p_commit) THEN
          	                  COMMIT WORK;
          	               END IF;

          	               l_stmt_num    := 999;
          	               -- Standard call to get message count and if count is 1, get message info.
          	               fnd_msg_pub.count_and_get(
          	                  p_count => x_msg_count
          	                 ,p_data => x_msg_data);
          	            EXCEPTION
          	               WHEN fnd_api.g_exc_error THEN
          	                  ROLLBACK TO get_insert_into_wori_pvt;
          	                  x_return_status := fnd_api.g_ret_sts_error;
          	                  fnd_msg_pub.count_and_get(
          	         --            p_encoded => FND_API.g_false
          	                     p_count => x_msg_count
          	                    ,p_data => x_msg_data);
          	               WHEN fnd_api.g_exc_unexpected_error THEN
          	                  ROLLBACK TO get_insert_into_wori_pvt;
          	                  x_return_status := fnd_api.g_ret_sts_unexp_error;

          	                  fnd_msg_pub.count_and_get(
          	                     p_count => x_msg_count
          	                    ,p_data => x_msg_data);
          	               WHEN OTHERS THEN
          	                  ROLLBACK TO get_insert_into_wori_pvt;
          	                  x_return_status := fnd_api.g_ret_sts_unexp_error;
          	                  IF fnd_msg_pub.check_msg_level(
          	                        fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          	                     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
          	                  END IF;

          	                  fnd_msg_pub.count_and_get(
          	                     p_count => x_msg_count
          	                    ,p_data => x_msg_data);
   END insert_into_wori;

   -- API called by Costing to insert into WED and WRO during receiving
   -- Anju Gupta: Modifed for PO Service Line Types Enhancement

   procedure WIP_EAMRCVDIRECTITEM_HOOK
   ( p_api_version        IN      NUMBER
     ,p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false
     ,p_commit            IN      VARCHAR2 := fnd_api.g_false
     ,p_rcv_txn_id        IN      NUMBER
     ,p_primary_qty    IN      NUMBER
     ,p_primary_uom    IN      VARCHAR2
     ,p_unit_price    IN      NUMBER
     ,x_return_status               OUT NOCOPY   VARCHAR2
     ,x_msg_count                   OUT NOCOPY   NUMBER
     ,x_msg_data                    OUT NOCOPY   VARCHAR2 )
     IS

            l_api_name       CONSTANT VARCHAR2(30) := 'create_requisition';
            l_api_version    CONSTANT NUMBER       := 1.0;
            l_organization_id  NUMBER;
            l_wip_entity_id    NUMBER;
            l_operation_seq_num NUMBER;
            l_resource_seq_num  NUMBER;
            l_department_id    NUMBER;
            l_primary_quantity  NUMBER;
            l_primary_uom    VARCHAR2(3);
            l_po_header_id   NUMBER;
            l_po_line_id  NUMBER;
            l_vendor_id   NUMBER;
            l_vendor_site_id  NUMBER;
            l_item_id  NUMBER;
            l_category_id  NUMBER;
            l_item_description VARCHAR2(240);
            l_unit_price  NUMBER;
            l_quantity  NUMBER;
            l_need_by_date DATE;
            l_stmt_num  NUMBER;
            l_status NUMBER;
            l_required_quantity NUMBER;
            l_quantity_received NUMBER;
            l_direct_item_id  NUMBER;
            l_uom  VARCHAR2(3);
            l_conversion_rate       NUMBER := 0;
            l_order_type_lookup_code po_lines_all.order_type_lookup_code%TYPE;


      BEGIN

         -- Standard Start of API savepoint
              l_stmt_num    := 10;
              SAVEPOINT wip_eamrcvdirectitem_pvt;

              l_stmt_num    := 20;
              -- Standard call to check for call compatibility.
              IF NOT fnd_api.compatible_api_call(
                    l_api_version
                   ,p_api_version
                   ,l_api_name
                   ,g_pkg_name) THEN
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              l_stmt_num    := 30;
              -- Initialize message list if p_init_msg_list is set to TRUE.
              IF fnd_api.to_boolean(p_init_msg_list) THEN
                 fnd_msg_pub.initialize;
              END IF;

              l_stmt_num    := 40;
              --  Initialize API return status to success
              x_return_status := fnd_api.g_ret_sts_success;

              l_stmt_num    := 50;

              -- API body

       -- Get values from WCTI

     if p_rcv_txn_id is not null then

     begin

         select     rct.organization_id,
                     rct.wip_entity_id,
                     rct.wip_operation_seq_num,
                     rct.wip_resource_seq_num,
                     wo.department_id,
                     rct.po_header_id,
                     rct.po_line_id,
                     rct.vendor_id,
                     rct.vendor_site_id,
                     pla.item_id,
                     pla.category_id,
                     pla.item_description,
                     nvl(plla.need_by_date,wo.first_unit_start_date),
                     pla.order_type_lookup_code



       into    l_organization_id,
               l_wip_entity_id,
               l_operation_seq_num,
               l_resource_seq_num,
               l_department_id,
               l_po_header_id,
               l_po_line_id,
               l_vendor_id,
               l_vendor_site_id,
               l_item_id,
               l_category_id,
               l_item_description,
               l_need_by_date,
               l_order_type_lookup_code

          from rcv_transactions rct, po_lines_all pla, po_line_types plt,
	         po_line_locations_all plla, wip_operations wo
	         where pla.po_header_id (+) = rct.po_header_id
	         and pla.po_line_id (+) = rct.po_line_id
	         and rct.po_line_location_id  = plla.line_location_id (+)
	         and pla.line_type_id  = plt.line_type_id (+)
	         and plt.outside_operation_flag  = 'N'
	         and rct.wip_entity_id  = wo.wip_entity_id (+)
	         and rct.organization_id = wo.organization_id (+)
	         and rct.wip_operation_seq_num  = wo.operation_seq_num (+)
                 and rct.transaction_id = p_rcv_txn_id;

                 l_primary_quantity := p_primary_qty;
                 l_primary_uom := p_primary_uom;
                 l_unit_price := p_unit_price;

          begin

		select sum( nvl(pd.quantity_delivered, 0) )
		into l_quantity_received
		from
		po_lines_all pol,
		po_distributions_all pd,
		po_line_types plt
		where
		pol.po_line_id = pd.po_line_id
		AND pol.line_type_id = plt.line_type_id
		AND upper(nvl(plt.outside_operation_flag, 'N')) = 'N'
		AND pd.destination_type_code = 'SHOP FLOOR'
		AND upper(nvl(pol.cancel_flag, 'N')) <> 'Y'
		AND pd.wip_entity_id = l_wip_entity_id
		AND pd.wip_operation_seq_num = l_operation_seq_num
		AND pd.destination_organization_id = l_organization_id
		AND pol.item_description = l_item_description;


          exception

           WHEN NO_DATA_FOUND  then

           RAISE fnd_api.g_exc_unexpected_error;

          end;



   if ((l_wip_entity_id is not null) and (l_operation_seq_num is not null) and (l_organization_id is not null)) then


      if (l_item_id is not null) then

       begin

        select 1, nvl(required_quantity,0)
        into l_status, l_required_quantity
        from wip_requirement_operations
        where wip_entity_id = l_wip_entity_id
        and organization_id = l_organization_id
        and operation_seq_num = l_operation_seq_num
        and inventory_item_id = l_item_id;

        if (l_quantity_received > l_required_quantity ) then

        update wip_requirement_operations
        set required_quantity = nvl(l_quantity_received,0)
        where wip_entity_id = l_wip_entity_id
        and organization_id = l_organization_id
        and operation_seq_num = l_operation_seq_num
        and inventory_item_id = l_item_id;

        end if;

        if (l_order_type_lookup_code = 'AMOUNT') THEN

	    update wip_requirement_operations
        set required_quantity = nvl(l_quantity_received,0)
        where wip_entity_id = l_wip_entity_id
        and organization_id = l_organization_id
        and operation_seq_num = l_operation_seq_num
        and inventory_item_id = l_item_id;

        end if;

      exception

       WHEN NO_DATA_FOUND  then

       insert into WIP_REQUIREMENT_OPERATIONS
    (INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    WIP_ENTITY_ID,
    OPERATION_SEQ_NUM,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    DEPARTMENT_ID,
    WIP_SUPPLY_TYPE,
    DATE_REQUIRED,
    REQUIRED_QUANTITY,
    QUANTITY_ISSUED,
    QUANTITY_PER_ASSEMBLY,
    MRP_NET_FLAG,
    AUTO_REQUEST_MATERIAL,
    VENDOR_ID,
    UNIT_PRICE)
    values
    (  l_item_id,
       l_organization_id,
       l_wip_entity_id,
       nvl(l_operation_seq_num,1),
       sysdate,
       FND_GLOBAL.USER_ID,
       sysdate,
       FND_GLOBAL.USER_ID,
       l_department_id,
       1,
       l_need_by_date,
       nvl(l_primary_quantity,0),
       0,
       nvl(l_primary_quantity,0),
       1,
       'Y',
       l_vendor_id,
       l_unit_price
    );

     END ;


    else

       if (l_resource_seq_num is null) then

   begin

   select 1, max (direct_item_sequence_id), sum(nvl(required_quantity,0))
   into l_status , l_direct_item_id, l_required_quantity
   from wip_eam_direct_items
   where wip_entity_id = l_wip_entity_id
   and organization_id = l_organization_id
   and operation_seq_num = l_operation_seq_num
   and description = l_item_description;

      select uom
      into l_uom
      from wip_eam_direct_items
      where wip_entity_id = l_wip_entity_id
      and organization_id = l_organization_id
      and operation_seq_num = l_operation_seq_num
      and description = l_item_description
      and direct_item_sequence_id = l_direct_item_id;


      begin

	  /* Bug # 4890934 : Replace view by base tables */

	select sum(round(inv_convert.inv_um_convert(0,38,quantity_received,
	       uom_code,l_uom, NULL,NULL),3))
	  into l_quantity_received
	  from (SELECT uom.uom_code, sum(pda.quantity_delivered) quantity_received
	  FROM po_line_types plt, mtl_units_of_measure uom, po_lines_all pla, po_distributions_all pda
	 WHERE pda.destination_type_code = 'SHOP FLOOR' AND pla.line_type_id = plt.line_type_id
	   AND upper(nvl(plt.outside_operation_flag, 'N')) = 'N' AND pla.po_line_id = pda.po_line_id
	   AND pla.unit_meas_lookup_code = uom.unit_of_measure (+)
	   AND upper(nvl(pla.cancel_flag, 'N')) <> 'Y' AND pla.item_description = l_item_description
	   AND pda.wip_entity_id = l_wip_entity_id AND pda.wip_operation_seq_num = l_operation_seq_num
	   AND pda.destination_organization_id = l_organization_id
	 GROUP BY uom.uom_code);

      exception

           WHEN NO_DATA_FOUND  then

           RAISE fnd_api.g_exc_unexpected_error;

     end;


           if (l_quantity_received > l_required_quantity ) then

           update wip_eam_direct_items
           set required_quantity = l_quantity_received
           where wip_entity_id = l_wip_entity_id
           and organization_id = l_organization_id
           and operation_seq_num = l_operation_seq_num
           and direct_item_sequence_id = l_direct_item_id;

           end if;

           if ( l_order_type_lookup_code = 'AMOUNT') then
           		update wip_eam_direct_items
           set required_quantity = nvl(l_quantity_received,0),
           amount = amount + p_unit_price
           where wip_entity_id = l_wip_entity_id
           and organization_id = l_organization_id
           and operation_seq_num = l_operation_seq_num
           and direct_item_sequence_id = l_direct_item_id;

           end if;

   exception

   WHEN NO_DATA_FOUND  then



      insert into WIP_EAM_DIRECT_ITEMS
       (DESCRIPTION,
        PURCHASING_CATEGORY_ID,
        DIRECT_ITEM_SEQUENCE_ID,
        OPERATION_SEQ_NUM,
        DEPARTMENT_ID,
        WIP_ENTITY_ID,
        ORGANIZATION_ID,
        SUGGESTED_VENDOR_ID,
        SUGGESTED_VENDOR_SITE_ID,
        SUGGESTED_VENDOR_CONTACT_ID,
        UNIT_PRICE,
        AUTO_REQUEST_MATERIAL,
        REQUIRED_QUANTITY,
        UOM,
        NEED_BY_DATE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        order_type_lookup_code,
        amount
       )
    values
       ( l_item_description,
         l_category_id,
         wip_eam_di_seq_id_s.nextval,
         nvl(l_operation_seq_num,1),
         l_department_id,
         l_wip_entity_id,
         l_organization_id,
         l_vendor_id,
         l_vendor_site_id,
         null,
         decode(l_order_type_lookup_code, 'AMOUNT', 0, l_unit_price),
         'Y',
         l_primary_quantity,
         l_primary_uom,
         l_need_by_date,
         FND_GLOBAL.USER_ID,
         sysdate,
         sysdate,
         FND_GLOBAL.USER_ID,
         l_order_type_lookup_code,
		 l_unit_price );

     end; -- end of insertion into WIP_EAM_DIRECT_ITEMS table

       end if;  -- end of l_resource_seq_num

     end if; -- end of l_item_id, l_operation_seq_num, l_organization_id not null

    end if; -- end of l_wip_entity_id,

   exception

   when NO_DATA_FOUND then

    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'OSP item received');

   end;

   end if;  -- end of p_rcv_txn_id not null


          -- End of API body.
              -- Standard check of p_commit.
              IF fnd_api.to_boolean(p_commit) THEN
                 COMMIT WORK;
              END IF;

              l_stmt_num    := 999;
              -- Standard call to get message count and if count is 1, get message info.
              fnd_msg_pub.count_and_get(
                 p_encoded => fnd_api.g_false
                ,p_count => x_msg_count
                ,p_data => x_msg_data);

    EXCEPTION
              WHEN fnd_api.g_exc_error THEN
                 ROLLBACK TO wip_eamrcvdirectitem_pvt;
                 x_return_status := fnd_api.g_ret_sts_error;
                 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
                 fnd_msg_pub.count_and_get(
                    p_encoded => fnd_api.g_false
                   ,p_count => x_msg_count
                   ,p_data => x_msg_data);
              WHEN fnd_api.g_exc_unexpected_error THEN
                 ROLLBACK TO wip_eamrcvdirectitem_pvt;
                 x_return_status := fnd_api.g_ret_sts_unexp_error;
                 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
                 fnd_msg_pub.count_and_get(
                    p_encoded => fnd_api.g_false
                   ,p_count => x_msg_count
                   ,p_data => x_msg_data);
              WHEN OTHERS THEN
                 ROLLBACK TO wip_eamrcvdirectitem_pvt;
                 x_return_status := fnd_api.g_ret_sts_unexp_error;
                 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
                 IF fnd_msg_pub.check_msg_level(
                       fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
                 END IF;

                 fnd_msg_pub.count_and_get(
                    p_encoded   => fnd_api.g_false
                   ,p_count => x_msg_count
                   ,p_data => x_msg_data);

 END WIP_EAMRCVDIRECTITEM_HOOK;


END WIP_EAM_RESOURCE_TRANSACTION;

/
