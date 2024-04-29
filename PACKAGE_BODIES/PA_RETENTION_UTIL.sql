--------------------------------------------------------
--  DDL for Package Body PA_RETENTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RETENTION_UTIL" as
/* $Header: PAXIRUTB.pls 120.2 2005/08/19 17:14:48 mwasowic noship $ */

   /*----------------------------------------------------------------------------------------+
   |   Function   :   IsBillingCycleQualified                                                |
   |   Purpose    :                                                                                            |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id                     IN      Project Id                                 |
   |     p_task_id                        IN      Task ID                                    |
   |     p_bill_thru_date                 IN      Bill thru Date                             |
   |     p_billing_cycle_id               IN      Billing cycle ID                           |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


   g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

FUNCTION IsBillingCycleQualified(p_project_id	IN NUMBER,
  				    p_task_id	IN NUMBER,
			            P_bill_thru_date IN DATE,
			            p_billing_cycle_id IN NUMBER) RETURN VARCHAR2 IS


           QualifiedFlag	 VARCHAR2(1) := 'N';
           Last_Bill_thru_date	 Date ;
           TmpBillingDate        Date;

   BEGIN


       -- Finding the last bill thru date
	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Entering IsBillingCycleQualified Function ');
		pa_retention_util.write_log('IsBillingCycleQualified: ' || 'Billing Cycle Id  : ' || p_billing_cycle_id );
		pa_retention_util.write_log('IsBillingCycleQualified: ' || 'Bill Thru Date    : ' || to_char(p_bill_thru_date));
	END IF;

       BEGIN

		-- Find the maximum bill through date from invoices table for retention invoices

		IF NVL(p_task_id,0) = 0 THEN

				SELECT MAX(bill_through_date)
		  		INTO last_bill_thru_date
		  		FROM pa_draft_invoices
	 	 		WHERE project_id = p_project_id
		   		AND retention_invoice_flag = 'Y';

			 IF g1_debug_mode  = 'Y' THEN
			 	pa_retention_util.write_log('IsBillingCycleQualified: ' || 'Project Level Last Bill Thru Date    : '
				||  to_char(last_bill_thru_date));
			 END IF;
		ELSE
				SELECT MAX(di.bill_through_date)
		  		INTO last_bill_thru_date
		  		FROM pa_draft_invoices di
	 	 		WHERE di.project_id = p_project_id
		   		AND di.retention_invoice_flag = 'Y'
				AND EXISTS(
					SELECT null FROM pa_draft_invoice_items dii
					WHERE dii.draft_invoice_num = di.draft_invoice_num
					  AND dii.project_id = di.project_id
					  AND dii.task_id    = p_task_id);
			 IF g1_debug_mode  = 'Y' THEN
			 	pa_retention_util.write_log('IsBillingCycleQualified: ' || 'Task Level Last Bill Thru Date    : '
				||  to_char(last_bill_thru_date));
			 END IF;
		END IF;

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			last_bill_thru_date := NULL;

       END;

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('IsBillingCycleQualified: ' || 'Last Bill Thru Date    : ' ||  to_char(last_bill_thru_date));
	END IF;

       IF last_bill_thru_date IS NULL THEN

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('IsBillingCycleQualified: ' || 'Last Bill Thru Date  IS NULL  ');
	END IF;

	   BEGIN

		IF NVL(p_task_id,0) = 0 THEN

			SELECT MIN(di.bill_through_date)
		  	INTO last_bill_thru_date
		  	FROM pa_draft_invoices di
		 	WHERE EXISTS (
			SELECT null FROM pa_draft_invoice_items dii
			 WHERE dii.draft_invoice_num = di.draft_invoice_num
			   AND dii.project_id = di.project_id
                           AND di.project_id = p_project_id
			   AND dii.invoice_line_type = 'RETENTION');

			 IF g1_debug_mode  = 'Y' THEN
			 	pa_retention_util.write_log('IsBillingCycleQualified: ' || 'II Project Level Last Bill Thru Date    : '
				||  to_char(last_bill_thru_date));
			 END IF;

		ELSE
			SELECT MIN(di.bill_through_date)
		  	INTO last_bill_thru_date
		  	FROM pa_draft_invoices di
		 	WHERE EXISTS (
			SELECT null FROM pa_draft_invoice_items dii
			 WHERE dii.draft_invoice_num = di.draft_invoice_num
			   AND dii.project_id = di.project_id
			   AND dii.task_id    = p_task_id
			   AND dii.invoice_line_type = 'RETENTION');

			 IF g1_debug_mode  = 'Y' THEN
			 	pa_retention_util.write_log('IsBillingCycleQualified: ' || 'II Task Level Last Bill Thru Date    : '
				||  to_char(last_bill_thru_date));
			 END IF;
		END IF;

		EXCEPTION
		WHEN NO_DATA_FOUND THEN

			 IF g1_debug_mode  = 'Y' THEN
			 	pa_retention_util.write_log('IsBillingCycleQualified: ' || 'No Data Found  ');
			 END IF;
			QualifiedFlag := 'N';

	    END;

       END IF;

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('IsBillingCycleQualified: ' || 'Calling PA_Billing_Cycles_Pkg.Get_Billing_Date');
	END IF;

       TmpBillingDate := PA_Billing_Cycles_Pkg.Get_Billing_Date (
                				X_Project_ID		=>p_project_id,
                				X_Project_Start_Date	=>last_bill_thru_date,
                				X_Billing_Cycle_ID 	=>p_billing_cycle_id,
                				X_Bill_Thru_Date        =>P_Bill_thru_date,
                				X_Last_Bill_Thru_Date   =>last_bill_thru_date);

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('IsBillingCycleQualified: ' || 'TmpBillDate   : ' || to_char(tmpBillingDate));
	END IF;

       IF TmpBillingDate <= P_Bill_thru_date THEN
	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('IsBillingCycleQualified: ' || 'Qualified    ');
	END IF;
	  QualifiedFlag := 'Y';
       ELSE
	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('IsBillingCycleQualified: ' || ' not Qualified    ');
	END IF;
	  QualifiedFlag := 'N';

       END IF;

       Return (QualifiedFlag);

   END IsBillingCycleQualified;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   write_log_message                                                      |
   |   Purpose    :   To write log message as supplied by other processe                     |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_log_message                    IN      Message to be logged                       |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


   PROCEDURE Write_log(p_message IN VARCHAR2) IS

   BEGIN
	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('Write_log: ' || p_message);
	END IF;
   END Write_Log;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   copy_retention setup                                                   |
   |   Purpose    :   To copy retention setup from project to another project                |
   |                  (called from forms) OR                                                 |
   |                  one project customer to other customers of the same project            |
   |                  (called from OA)                                                       |
   |   NOTE : When called from OA the setup of one project-customer is to be copied to       |
   |          the same project - different customer                                          |
   |          When called from FORMS, the setup of one project is to be copied to another    |
   |          project.                                                                       |
   |          In this case - if the customers are existing in both projects, then            |
   |                               a customer-customer copy is made.                         |
   |                         if not, then the setup of primary customer of source project    |
   |                               is copied to destination project                          |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_fr_project_id                  IN      Source Project Id                          |
   |     p_to_project_id                  IN      Destination Project ID                     |
   |     p_fr_customer_id                 IN      Source Customer ID                         |
   |     p_to_customer_id                 IN      Destination Customer ID                    |
   |     p_fr_date                        IN      Effective Start Date                       |
   |     p_to_date                        IN      Effective End Date                         |
   |     p_call_mode                      IN      Call Mode ('PROJECT', 'CUSTOMER')          |
   |     x_return_status                  OUT     Return Status                              |
   |     x_msg_count                      OUT     Message Count                              |
   |     x_msg_data                       OUT     Message Data                               |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE copy_retention_setup (
            p_fr_project_id                  IN      NUMBER DEFAULT NULL,
            p_to_project_id                  IN      NUMBER DEFAULT NULL,
            p_fr_customer_id                 IN      NUMBER DEFAULT NULL,
            p_to_customer_id                 IN      NUMBER DEFAULT NULL,
            p_fr_date                        IN      DATE DEFAULT NULL,
            p_to_date                        IN      DATE DEFAULT NULL,
            p_call_mode                      IN      VARCHAR2 DEFAULT 'PROJECT',
            x_return_status                  OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                      OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                       OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


       /* This cursor selects retention_level_code (source project)  of customers existing in both the
          source and destination project */

       cursor pc_cur (l_fr_project_id number, l_to_project_id number) IS
              select pc.customer_id, pc.retention_level_code
                        from pa_project_customers pc
                        where pc.project_id = l_fr_project_id
                        and pc.customer_id in (select customer_id from pa_project_customers
                                            where project_id = l_to_project_id);

       /* This cursor selects those customer records of destination project which do not have
          the same customers in the source project
          These records will not have their retention_level_code updated by the previous cursor */

       cursor no_cust_cur (l_fr_project_id number, l_to_project_id number) IS
              select pc.customer_id, pc.retention_level_code
                        from pa_project_customers pc
                        where pc.project_id = l_to_project_id
                        and pc.customer_id not in (select customer_id from pa_project_customers
                                            where project_id = l_fr_project_id);

       l_to_project_id               NUMBER;
       l_primary_cust_id             NUMBER;
       l_not_update                   NUMBER;
       l_retention_level_code        VARCHAR2(30);
       l_insufficient_parameters     EXCEPTION;

       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(30) := NULL;

       l_delta                       NUMBER;


   BEGIN

         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

       /* Check for proper set of parameters
          Source project_id (p_fr_project_id) is mandatory
          Either destination project_id (p_to_project_id) (when called from FORMS)
          OR both source and destination customer_id's (when called from OA) are required  */

        --dbms_output.put_line ('in copy retention setup 1');
        --dbms_output.put_line ('calling calculate date factor ');

        calculate_date_factor(p_fr_project_id => p_fr_project_id,
                             p_to_project_id => p_to_project_id,
                             x_delta         => l_delta,
                             x_return_status => l_return_status ,
                             x_msg_count     => l_msg_count ,
                             x_msg_data      => l_msg_data );

        --dbms_output.put_line ('after calculate date factor ' || l_delta);

        if p_call_mode = 'CUSTOMER' THEN

           --dbms_output.put_line ('in OA');
           --l_to_project_id := p_fr_project_id;

           update pa_project_customers
           set retention_level_code = (select retention_level_code
                                       from pa_project_customers
                                       where project_id = p_fr_project_id
                                       and   customer_id = p_fr_customer_id)
           where project_id = p_to_project_id
           and   customer_id = p_to_customer_id;

           --dbms_output.put_line ('calling delete retention rules OA');

           /* If the setup already exists for the customer it has to be deleted
              The validation (retained_amount / billed amount is zero is done at UI*/

           delete_retn_rules_customer (
                      p_project_id    => p_to_project_id ,
                      p_customer_id   => p_to_customer_id ,
                      x_return_status    => l_return_status ,
                      x_msg_count        => l_msg_count ,
                      x_msg_data         => l_msg_data );

           --dbms_output.put_line ('calling insert retention rules OA');

           /* Insert into retention rules table */

           insert_retention_rules (
                      p_fr_project_id    => p_fr_project_id ,
                      p_fr_customer_id   => p_fr_customer_id ,
                      p_to_project_id    => p_to_project_id ,
                      p_to_customer_id   => p_to_customer_id ,
                      p_fr_date          => p_fr_date ,
                      p_to_date          => p_to_date ,
                      p_delta            => l_delta ,
                      x_return_status    => l_return_status ,
                      x_msg_count        => l_msg_count ,
                      x_msg_data         => l_msg_data );

        else

            --dbms_output.put_line ('in forms');

            --dbms_output.put_line ('delete retention rules');

           /* If the setup already exists for the project it has to be deleted */

            delete_retention_rules (
                      p_project_id    => p_to_project_id ,
                      p_task_id       => NULL ,
                      x_return_status    => l_return_status ,
                      x_msg_count        => l_msg_count ,
                      x_msg_data         => l_msg_data );

            for pc_rec in pc_cur (p_fr_project_id, p_to_project_id) loop

                update pa_project_customers
                set retention_level_code = pc_rec.retention_level_code
                where project_id = p_to_project_id
                and   customer_id = pc_rec.customer_id;

                --dbms_output.put_line ('calling insert retention rules Forms');

                insert_retention_rules (
                      p_fr_project_id    => p_fr_project_id ,
                      p_fr_customer_id   => pc_rec.customer_id ,
                      p_to_project_id    => p_to_project_id ,
                      p_to_customer_id   => pc_rec.customer_id ,
                      p_fr_date          => p_fr_date ,
                      p_to_date          => p_to_date ,
                      p_delta            => l_delta ,
                      x_return_status    => l_return_status ,
                      x_msg_count        => l_msg_count ,
                      x_msg_data         => l_msg_data );

            END LOOP;


            /* If there are customers in the destination project not existing in source project
               the source project's primary customer setup is copied to the destination project */

            SELECT count(*) into l_not_update
            from pa_project_customers pc
            where pc.project_id = p_to_project_id
            and pc.customer_id not in (select customer_id from pa_project_customers
                                            where project_id = p_fr_project_id);

            if l_not_update <> 0 then

               --dbms_output.put_line ('same customer not in source getting primary cust');

               l_primary_cust_id := PA_PROJECTS_MAINT_UTILS.get_primary_customer(
                                           p_project_id => p_fr_project_id);

               if (nvl(l_primary_cust_id,0) <> 0) then

                  select pc.retention_level_code
                  into l_retention_level_code
                  from pa_project_customers pc
                  where pc.project_id = p_fr_project_id
                  and pc.customer_id = l_primary_cust_id;

                  for pc_no_rec in no_cust_cur (p_fr_project_id, p_to_project_id ) loop

                      update pa_project_customers
                      set retention_level_code = l_retention_level_code
                      where project_id = p_to_project_id
                      and customer_id = pc_no_rec.customer_id;

                   --dbms_output.put_line ('calling insert_retetniton rules for primary cust');

                      insert_retention_rules (
                          p_fr_project_id    => p_fr_project_id ,
                          p_fr_customer_id   => l_primary_cust_id ,
                          p_to_project_id    => p_to_project_id ,
                          p_to_customer_id   => pc_no_rec.customer_id ,
                          p_fr_date          => p_fr_date ,
                          p_to_date          => p_to_date ,
                          p_delta            => l_delta ,
                          x_return_status    => l_return_status ,
                          x_msg_count        => l_msg_count ,
                          x_msg_data         => l_msg_data );

                  END LOOP;

               end if;

            end if;

        end if;

        if l_return_status = 'E' then
           x_return_status := l_return_status;
           x_msg_count     := l_msg_count   ;
           x_msg_data      := l_msg_data   ;
        end if;


   EXCEPTION

        WHEN others THEN
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_RETENTION_UTIL',
                    p_procedure_name   => 'copy_retention_setup');

             RAISE ;

   END copy_retention_setup;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   copy_retention setup                                                   |
   |   Purpose    :   This is an overloaded procedure. When called from OA there could be    |
   |                  multiple destination customers. This procedure loops through and calls |
   |                  the copy for single customer                                           |
   |                  This will be called from OA                                            |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_fr_project_id                  IN      Source Project Id                          |
   |     p_to_project_id                  IN      Destination Project ID                     |
   |     p_fr_customer_id                 IN      Source Customer ID                         |
   |     p_to_customer_id_tab             IN      Array of Destination Customer ID           |
   |     p_fr_date                        IN      Effective Start Date                       |
   |     p_to_date                        IN      Effective End Date                         |
   |     p_call_mode                      IN      Call Mode ('PROJECT', 'CUSTOMER')          |
   |     x_return_status                  OUT     Return Status                              |
   |     x_msg_count                      OUT     Message Count                              |
   |     x_msg_data                       OUT     Message Data                               |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


   PROCEDURE copy_retention_setup (
            p_fr_project_id                  IN      NUMBER ,
            p_to_project_id                  IN      NUMBER DEFAULT NULL,
            p_fr_customer_id                 IN      NUMBER DEFAULT NULL,
            p_to_customer_id_tab             IN      PA_NUM_1000_NUM,
            p_rec_version_tab                IN      PA_NUM_1000_NUM,
            p_fr_date                        IN      DATE DEFAULT NULL,
            p_to_date                        IN      DATE DEFAULT NULL,
            p_call_mode                      IN      VARCHAR2 DEFAULT 'PROJECT',
            x_return_status                  OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                      OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                       OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


            l_tab_count NUMBER := 0;
            l_to_customer_id              NUMBER;
            l_to_project_id               NUMBER;

            l_return_status               VARCHAR2(30) := NULL;
            l_msg_count                   NUMBER       := NULL;
            l_msg_data                    VARCHAR2(30) := NULL;


   BEGIN

         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;
          --dbms_output.put_line ('in copy retention setup 2');
          l_tab_count := p_to_customer_id_tab.COUNT;

          IF l_tab_count = 0 then
             RETURN;

          END IF;

          if p_to_project_id is null then

             l_to_project_id := p_fr_project_id;

          else

             l_to_project_id := p_to_project_id;

          end if;

          FOR i in 1..l_tab_count LOOP

              --dbms_output.put_line ('calling copy retention setup 1');
             set_rec_version_num (  p_project_id        => l_to_project_id,
                                    p_customer_id       => p_to_customer_id_tab(i),
                                    p_version_num       => p_rec_version_tab(i),
                                    x_return_status     => l_return_status,
                                    x_msg_count         => l_msg_count,
                                    x_msg_data          => l_msg_data );

              if l_return_status = FND_API.G_RET_STS_ERROR then

                 rollback;
                 exit;

              end if;

              copy_retention_setup (
                    p_fr_project_id    => p_fr_project_id,
                    p_to_project_id    => l_to_project_id,
                    p_fr_customer_id   => p_fr_customer_id,
                    p_to_customer_id   => p_to_customer_id_tab(i),
                    p_fr_date          => p_fr_date,
                    p_to_date          => p_to_date,
                    p_call_mode        => p_call_mode,
                    x_return_status    => l_return_status,
                    x_msg_count        => l_msg_count,
                    x_msg_data         => l_msg_data);


          END LOOP;

           x_return_status := l_return_status;
           x_msg_count     := l_msg_count   ;
           x_msg_data      := l_msg_data   ;

   EXCEPTION

        WHEN others THEN
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_RETENTION_UTIL',
                    p_procedure_name   => 'copy_retention_setup');


   END copy_retention_setup;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   delete_retn_rules_customer                                             |
   |   Purpose    :   To delete from retention rules table for a project and customer        |
   |                  This will be called from OA                                            |
   |                                                                                         |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id                     IN      Destination project id                     |
   |     p_customer_id                    IN      Destination customer id                    |
   |     x_return_status                  OUT     Return status of this procedure            |
   |     x_msg_count                      OUT     Error message count                        |
   |     x_msg_data                       OUT     Error message                              |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE delete_retn_rules_customer (
            p_project_id                  IN      NUMBER,
            p_customer_id                 IN      NUMBER,
            x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                    OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(30) := NULL;


   BEGIN

         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;
            --dbms_output.put_line ('in delete retention rules');

            DELETE FROM pa_proj_retn_rules
            WHERE project_id = p_project_id
            AND  customer_id = p_customer_id;


            DELETE FROM pa_proj_retn_bill_rules
            WHERE project_id = p_project_id
            AND  customer_id = p_customer_id;


   EXCEPTION

        WHEN others THEN
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_RETENTION_UTIL',
                    p_procedure_name   => 'delete_retn_rules_customer');


   END delete_retn_rules_customer;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   delete_retention_rules                                                 |
   |   Purpose    :   To delete from retention rules table for a project                     |
   |                  This will be called from Forms                                         |
   |                                                                                         |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id                     IN      Destination project id                     |
   |     x_return_status                  OUT     Return status of this procedure            |
   |     x_msg_count                      OUT     Error message count                        |
   |     x_msg_data                       OUT     Error message                              |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE delete_retention_rules (
            p_project_id                  IN      NUMBER,
            p_task_id                     IN      NUMBER DEFAULT NULL,
            x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                    OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(30) := NULL;


   BEGIN

            --dbms_output.put_line ('in delete retention rules');

         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF NVL(p_task_id, 0) = 0 then

            DELETE FROM pa_proj_retn_rules
            WHERE project_id = p_project_id;

            DELETE FROM pa_proj_retn_bill_rules
            WHERE project_id = p_project_id;

         ELSE
            DELETE FROM pa_proj_retn_rules
            WHERE project_id = p_project_id
            AND  task_id = p_task_id;

            DELETE FROM pa_proj_retn_bill_rules
            WHERE project_id = p_project_id
            AND  task_id = p_task_id;

         END IF;



   EXCEPTION

        WHEN others THEN
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_RETENTION_UTIL',
                    p_procedure_name   => 'delete_retention_rules');

   END delete_retention_rules;



   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   insert_retention_rules                                                 |
   |   Purpose    :   To insert into retention rules table                                   |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_fr_project_id                  IN      Source project id                          |
   |     p_fr_customer_id                 IN      Source customer id                         |
   |     p_to_project_id                  IN      Destination project id                     |
   |     p_to_customer_id                 IN      Destination customer id                    |
   |     p_fr_date                        IN      From effective date                        |
   |     p_to_date                        IN      To effective date                          |
   |     x_return_status                  OUT     Return status of this procedure            |
   |     x_msg_count                      OUT     Error message count                        |
   |     x_msg_data                       OUT     Error message                              |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE insert_retention_rules (
            p_fr_project_id               IN      NUMBER,
            p_fr_customer_id              IN      NUMBER,
            p_to_project_id               IN      NUMBER,
            p_to_customer_id              IN      NUMBER,
            p_fr_date                     IN      DATE,
            p_to_date                     IN      DATE,
            p_delta                       IN      NUMBER,
            x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                    OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


       cursor retn_cur( l_fr_project_id number, l_fr_customer_id number) IS
               select retention_level_code, task_id, expenditure_category,
                      expenditure_type, non_labor_resource, event_type,
                      effective_start_date, effective_end_date,
                      retention_percentage, retention_amount, threshold_amount,
                      projfunc_total_retained, project_total_retained,
                      total_retained, revenue_category_code
               from pa_proj_retn_rules
               where project_id = l_fr_project_id
               and   customer_id = l_fr_customer_id;

       cursor bill_cur( l_fr_project_id number, l_fr_customer_id number) IS
               select  billing_method_code, task_id, completed_percentage,
                       total_retention_amount, retn_billing_cycle_id, client_extension_flag,
                       retn_billing_percentage, retn_billing_amount
               from pa_proj_retn_bill_rules
               where project_id = l_fr_project_id
               and   customer_id = l_fr_customer_id;

       l_to_task_id                     NUMBER;
       l_fr_start_date               DATE;
       l_to_start_date               DATE;

       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(30) := NULL;


   BEGIN

            --dbms_output.put_line ('in insert retention rules');

         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;


            for retn_rec in retn_cur ( p_fr_project_id, p_fr_customer_id) loop

                if nvl(retn_rec.task_id,0) <> 0 then

                        get_corresponding_task (
                                        p_fr_project_id    => p_fr_project_id,
                                        p_fr_task_id       => retn_rec.task_id,
                                        p_to_project_id    => p_to_project_id,
                                        x_task_id          => l_to_task_id,
                                        x_fr_start_date    => l_fr_start_date,
                                        x_to_start_date    => l_to_start_date,
                                        x_return_status    => l_return_status ,
                                        x_msg_count        => l_msg_count ,
                                        x_msg_data         => l_msg_data );


                        INSERT INTO pa_proj_retn_rules
                               (RETENTION_RULE_ID,
                                RETENTION_LEVEL_CODE,
                                PROJECT_ID,
                                CUSTOMER_ID,
                                TASK_ID ,
                                EXPENDITURE_CATEGORY,
                                EXPENDITURE_TYPE,
                                NON_LABOR_RESOURCE,
                                EVENT_TYPE,
                                EFFECTIVE_START_DATE,
                                EFFECTIVE_END_DATE,
                                RETENTION_PERCENTAGE,
                                RETENTION_AMOUNT,
                                THRESHOLD_AMOUNT,
                                CREATION_DATE,
                                CREATED_BY ,
                                LAST_UPDATE_DATE ,
                                LAST_UPDATED_BY,
                                REVENUE_CATEGORY_CODE)
                        VALUES
                                (pa_proj_retn_rules_s.nextval,
                                retn_rec.retention_level_code,
                                p_to_project_id,
                                p_to_customer_id,
                                l_to_task_id,
                                retn_rec.expenditure_category,
                                retn_rec.expenditure_type,
                                retn_rec.non_labor_resource,
                                retn_rec.event_type,
                                decode(l_to_start_date, NULL,
                                             retn_rec.effective_start_date + p_delta,
                                             retn_rec.effective_start_date + (l_to_start_date -
                                                                              l_fr_start_date)),
                                decode( retn_rec.effective_end_date, null, null,
                                        decode(l_to_start_date, NULL,
                                                  retn_rec.effective_end_date + p_delta,
                                                  retn_rec.effective_end_date +
                                                       (l_to_start_date - l_fr_start_date))),
                                retn_rec.retention_percentage,
                                retn_rec.retention_amount,
                                retn_rec.threshold_amount,
                                sysdate,
                                fnd_global.user_id,
                                sysdate,
                                fnd_global.user_id,
                                retn_rec.revenue_category_code);

                else
                   l_to_task_id := NULL;

                   INSERT INTO pa_proj_retn_rules
                          (RETENTION_RULE_ID,
                           RETENTION_LEVEL_CODE,
                           PROJECT_ID,
                           CUSTOMER_ID,
                           TASK_ID ,
                           EXPENDITURE_CATEGORY,
                           EXPENDITURE_TYPE,
                           NON_LABOR_RESOURCE,
                           EVENT_TYPE,
                           EFFECTIVE_START_DATE,
                           EFFECTIVE_END_DATE,
                           RETENTION_PERCENTAGE,
                           RETENTION_AMOUNT,
                           THRESHOLD_AMOUNT,
                           CREATION_DATE,
                           CREATED_BY ,
                           LAST_UPDATE_DATE ,
                           LAST_UPDATED_BY,
                           REVENUE_CATEGORY_CODE)
                   VALUES
                           (pa_proj_retn_rules_s.nextval,
                           retn_rec.retention_level_code,
                           p_to_project_id,
                           p_to_customer_id,
                           l_to_task_id,
                           retn_rec.expenditure_category,
                           retn_rec.expenditure_type,
                           retn_rec.non_labor_resource,
                           retn_rec.event_type,
                           retn_rec.effective_start_date + p_delta,
                           retn_rec.effective_end_date + p_delta,
                           retn_rec.retention_percentage,
                           retn_rec.retention_amount,
                           retn_rec.threshold_amount,
                           sysdate,
                           fnd_global.user_id,
                           sysdate,
                           fnd_global.user_id,
                           retn_rec.revenue_category_code);

                end if;

            END LOOP;

            for bill_rec in bill_cur ( p_fr_project_id, p_fr_customer_id) loop

                if nvl(bill_rec.task_id,0) <> 0 then


                   if (p_fr_project_id = p_to_project_id) then

                       l_to_task_id := bill_rec.task_id;

                   else

                        get_corresponding_task (
                                        p_fr_project_id    => p_fr_project_id,
                                        p_fr_task_id       => bill_rec.task_id,
                                        p_to_project_id    => p_to_project_id,
                                        x_task_id          => l_to_task_id,
                                        x_fr_start_date    => l_fr_start_date,
                                        x_to_start_date    => l_to_start_date,
                                        x_return_status    => l_return_status ,
                                        x_msg_count        => l_msg_count ,
                                        x_msg_data         => l_msg_data );

                   end if;

                else
                   l_to_task_id := NULL;
                end if;

                --dbms_output.put_line ('actual insertion');
                INSERT INTO pa_proj_retn_bill_rules
                 ( RETN_BILLING_RULE_ID,
                   BILLING_METHOD_CODE,
                   PROJECT_ID,
                   CUSTOMER_ID,
                   TASK_ID ,
                   COMPLETED_PERCENTAGE,
                   TOTAL_RETENTION_AMOUNT,
                   RETN_BILLING_CYCLE_ID,
                   CLIENT_EXTENSION_FLAG,
                   RETN_BILLING_PERCENTAGE,
                   RETN_BILLING_AMOUNT,
                   CREATION_DATE,
                   CREATED_BY ,
                   LAST_UPDATE_DATE ,
                   LAST_UPDATED_BY)
               VALUES
                  (pa_proj_retn_bill_rules_s.nextval,
                  bill_rec.billing_method_code,
                  p_to_project_id,
                  p_to_customer_id,
                  l_to_task_id,
                  bill_rec.completed_percentage,
                  bill_rec.total_retention_amount,
                  bill_rec.retn_billing_cycle_id,
                  bill_rec.client_extension_flag,
                  bill_rec.retn_billing_percentage,
                  bill_rec.retn_billing_amount,
                  sysdate,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id );

            END LOOP;


   EXCEPTION

        WHEN others THEN
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_RETENTION_UTIL',
                    p_procedure_name   => 'insert_retention_rules');

   END insert_retention_rules;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_currency_code                                                      |
   |   Purpose    :   This procedure returns the various currency code for the given project |
   |                  ID                                                                     |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id                     IN      Project_id                                 |
   |     x_invproc_currency_type          OUT     invproc currency type                      |
   |     x_project_currency_code          OUT     project currency code                      |
   |     x_projfunc_currency_code         OUT     project functional currency code           |
   |     x_funding_currency_code          OUT     funding currency code                      |
   |     x_invproc_currency_code          OUT     invoice processing currency code           |
   |     x_return_status                  OUT     Return status of this procedure            |
   |     x_msg_count                      OUT     Error message count                        |
   |     x_msg_data                       OUT     Error message                              |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE get_currency_code(
            p_project_id               IN      NUMBER,
            x_invproc_currency_type       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_project_currency_code       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_projfunc_currency_code      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_funding_currency_code       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_invproc_currency_code       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                    OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


            l_return_status               VARCHAR2(30) := NULL;
            l_msg_count                   NUMBER       := NULL;
            l_msg_data                    VARCHAR2(30) := NULL;

   BEGIN

         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;
        --dbms_output.put_line ('in get currency code');
        SELECT    invproc_currency_type,
                  project_currency_code,
                  projfunc_currency_code
        INTO      x_invproc_currency_type,
                  x_project_currency_code,
                  x_projfunc_currency_code
        FROM       pa_projects_all
        WHERE      project_id = p_project_id;


       x_funding_currency_code := NULL;

       IF x_invproc_currency_type = 'PROJECT_CURRENCY'  THEN

          x_invproc_currency_code := x_project_currency_code;

       ELSIF x_invproc_currency_type = 'PROJFUNC_CURRENCY'  THEN

          x_invproc_currency_code := x_projfunc_currency_code;

       ELSIF x_invproc_currency_type = 'FUNDING_CURRENCY'  THEN

          BEGIN

              SELECT funding_currency_code
              INTO   x_invproc_currency_code
              FROM   pa_summary_project_fundings
              WHERE  project_id = p_project_id
              AND    rownum = 1
              GROUP BY funding_currency_code
              HAVING    sum(nvl(total_baselined_amount,0)) > 0;

              x_funding_currency_code := x_invproc_currency_code;

          EXCEPTION

              WHEN NO_DATA_FOUND THEN

                  x_invproc_currency_code := null;

                  /*
                   x_msg_count     := 1;
                   x_msg_data      := 'PA_NO_FUNDING_EXISTS';
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   FND_MSG_PUB.add_Exc_msg(
                          p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                          p_procedure_name   => 'get_project_defaults');

                   RAISE ;
                 */

          END;


       END IF;


   EXCEPTION

        WHEN others THEN

             x_invproc_currency_type  := NULL; -- NOCOPY
             x_project_currency_code  := NULL; -- NOCOPY
             x_projfunc_currency_code := NULL; -- NOCOPY
             x_funding_currency_code  := NULL; -- NOCOPY
             x_invproc_currency_code  := NULL; -- NOCOPY
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_RETENTION_UTILS',
                    p_procedure_name   => 'get_currency_code');

             RAISE ;

   END get_currency_code;

   /*----------------------------------------------------------------------------------------+
   |   Procedure   :   get_corresponding_task                                                 |
   |   Purpose    :   This procedure returns task_id of the destination project corresponding|
   |                  to the source project's task_id.                                       |
   |                  NOTE : When setup is copied from source project to destination project |
   |                         both project's will have same task_number.                      |
   |                  If the retention setup of source project is defined at task_level the  |
   |                     corresponding task_id of destination project (based on tak_number)  |
   |                  will be returned by this function                                      |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_fr_project_id                  IN      Project ID (Source)                        |
   |     p_fr_task_id                     IN      Task    ID (Source)                        |
   |     p_to_project_id                  IN      Project ID (destination)                   |
   |     x_task_id                        OUT     task    ID (destination)                   |
   |     x_fr_start_date                  OUT     task start date (Source)                   |
   |     x_to_start_date                  OUT     task start date (Destination)              |
   |     x_return_status                  OUT     return status                              |
   |     x_msg_count                      OUT     message count                              |
   |     x_msg_data                       OUT     message data                               |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE get_corresponding_task ( p_fr_project_id   IN NUMBER,
                                      p_fr_task_id       IN NUMBER,
                                      p_to_project_id    IN NUMBER,
                                      x_task_id          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                      x_fr_start_date    OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                      x_to_start_date    OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                      x_return_status    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_msg_count        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                      x_msg_data         OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

        l_return_status               VARCHAR2(30) := NULL;
        l_msg_count                   NUMBER       := NULL;
        l_msg_data                    VARCHAR2(30) := NULL;

   BEGIN

       x_return_status    := FND_API.G_RET_STS_SUCCESS;
       x_msg_count        := 0;

       --dbms_output.put_line ('in get corresponding task');

       SELECT  new.task_id, new.start_date, old.start_date
       INTO    x_task_id, x_to_start_date, x_fr_start_date
       FROM    pa_tasks old, pa_tasks new
       WHERE   old.project_id = p_fr_project_id
       AND     old.task_id = p_fr_task_id
       AND     old.task_number = new.task_number
       AND     new.project_id = p_to_project_id;


   EXCEPTION

        WHEN others THEN

             x_task_id        := NULL; --NOCOPY
             x_fr_start_date  := NULL; --NOCOPY
             x_to_start_date  := NULL; --NOCOPY
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_RETENTION_UTIL',
                    p_procedure_name   => 'get_corresponding_task');

             RAISE ;

   END get_corresponding_task;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_project_info                                                       |
   |   Purpose    :   This procedure returns the project related information for the given   |
   |                  project ID                                                             |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id                     IN      Input Project id                           |
   |     x_project_name                   OUT     Project Name                               |
   |     x_project_number                 OUT     Project Number                             |
   |     x_invproc_currency_type          OUT     Invoice processing currency type           |
   |     x_invproc_currency_code          OUT     Invoice processing currency code           |
   |     x_projfunc_currency_code         OUT     Invoice processing currency code           |
   |     x_return_status                  OUT     Return status of this procedure            |
   |     x_msg_count                      OUT     Error message count                        |
   |     x_msg_data                       OUT     Error message                              |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


   PROCEDURE get_project_info (p_project_id              IN     NUMBER,
                               x_project_name            OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_project_number          OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_invproc_currency_type   OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_invproc_currency_code   OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_projfunc_currency_code  OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_return_status           OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_msg_count               OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               x_msg_data                OUT    NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


        l_project_currency_code   VARCHAR2(30);
        l_invproc_currency_type    VARCHAR2(30);


        l_return_status               VARCHAR2(30) := NULL;
        l_msg_count                   NUMBER       := NULL;
        l_msg_data                    VARCHAR2(30) := NULL;

   BEGIN

         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

        SELECT p.segment1, p.name, p.invproc_currency_type,
               p.project_currency_code, p.projfunc_currency_code, lk.meaning
        INTO x_project_number, x_project_name, l_invproc_currency_type,
             l_project_currency_code, x_projfunc_currency_code, x_invproc_currency_type
        FROM pa_projects_all p , pa_lookups lk
        WHERE project_id = p_project_id
        and   lk.lookup_type = 'INVPROCE_CURR_TYPE'
        and   lk.lookup_code = p.invproc_currency_type;


       IF l_invproc_currency_type = 'PROJECT_CURRENCY'  THEN

          x_invproc_currency_code := l_project_currency_code;

       ELSIF l_invproc_currency_type = 'PROJFUNC_CURRENCY'  THEN

          x_invproc_currency_code := x_projfunc_currency_code;

       ELSIF l_invproc_currency_type = 'FUNDING_CURRENCY'  THEN

          BEGIN

              SELECT funding_currency_code
              INTO   x_invproc_currency_code
              FROM   pa_summary_project_fundings
              WHERE  project_id = p_project_id
              AND    rownum = 1
              GROUP BY funding_currency_code
              HAVING    sum(nvl(total_baselined_amount,0)) > 0;


          EXCEPTION

              WHEN NO_DATA_FOUND THEN

                  x_invproc_currency_code := null;

                  /*
                   x_msg_count     := 1;
                   x_msg_data      := 'PA_NO_FUNDING_EXISTS';
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   FND_MSG_PUB.add_Exc_msg(
                          p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                          p_procedure_name   => 'get_project_defaults');

                   RAISE ;
                 */

          END;


       END IF;



   EXCEPTION

        WHEN others THEN

            x_project_name          := NULL; --NOCOPY
            x_project_number        := NULL; --NOCOPY
            x_invproc_currency_type := NULL; --NOCOPY
            x_invproc_currency_code := NULL; --NOCOPY
            x_projfunc_currency_code  := NULL; --NOCOPY
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_RETENTION_UTILS',
                    p_procedure_name   => 'get_project_info');

             RAISE ;


   END get_project_info;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   calculate_date_factor                                                  |
   |   Purpose    :   To calculate date factor based on the difference in dates between      |
   |                  source project and destination project                                 |
   |                                                                                         |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_fr_project_id                  IN      Source project id                          |
   |     p_to_project_id                  IN      Destination project id                     |
   |     x_delta                          OUT     date factor to be used for effective dates |
   |     x_return_status                  OUT     Return status of this procedure            |
   |     x_msg_count                      OUT     Error message count                        |
   |     x_msg_data                       OUT     Error message                              |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE calculate_date_factor (
            p_fr_project_id               IN      NUMBER,
            p_to_project_id               IN      NUMBER,
            x_delta                       OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                    OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(30) := NULL;

                 -- use min(start_date) as pseudo original project start

       CURSOR c2 is SELECT min(start_date) min_start
                    FROM pa_tasks
                    WHERE project_id = p_fr_project_id;

       c2_rec  c2%rowtype;


       l_fr_start_date    DATE;
       l_to_start_date    DATE;



   BEGIN

         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         --dbms_output.put_line ('in calculate date factor ');

       SELECT fr_proj.start_date, to_proj.start_date
       INTO l_fr_start_date, l_to_start_date
       FROM pa_projects_all fr_proj, pa_projects_all to_proj
       WHERE fr_proj.project_id = p_fr_project_id
       AND   to_proj.project_id = p_to_project_id;

      if (l_to_start_date is null) then
            x_delta := 0;
      elsif (l_fr_start_date is not null) then
            x_delta := l_to_start_date - l_fr_start_date;
      else
           open c2;
           fetch c2 into c2_rec;
           if c2%found then
              x_delta := l_to_start_date - c2_rec.min_start;
           end if;
           close c2;

      end if;



   EXCEPTION

        WHEN others THEN
             x_delta := NULL; --NOCOPY
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_RETENTION_UTIL',
                    p_procedure_name   => 'calculate_date_factor');


   END calculate_date_factor;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_rec_version_num                                                    |
   |   Purpose    :   This procedure returns the record version number of the given project  |
   |                  and customer id from pa_project_customers table                        |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id                     IN      Input Project id                           |
   |     p_customer_id                    IN      Input Customer id                          |
   |     x_version_num                    OUT     Record version number                      |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


   PROCEDURE get_rec_version_num ( p_project_id          IN NUMBER,
                                    p_customer_id         IN NUMBER,
                                    x_version_num         OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

   BEGIN

       SELECT record_version_number
       INTO  x_version_num
       FROM pa_project_customers
       WHERE project_id = p_project_id
       AND customer_id = p_customer_id;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
           x_version_num := NULL;

   END get_rec_version_num;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   check_rec_version_num                                                  |
   |   Purpose    :   This procedure checks the record version number with the record version|
   |                  number of the given project  and customer id in  pa_project_customers  |
   |                  table                                                                  |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id                     IN      Input Project id                           |
   |     p_customer_id                    IN      Input Customer id                          |
   |     p_version_num                    IN      Record version number                      |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


   FUNCTION check_rec_version_num ( p_project_id          IN NUMBER,
                                    p_customer_id         IN NUMBER,
                                    p_version_num         IN NUMBER)
        RETURN VARCHAR2 IS

        l_version_num   NUMBER;

   BEGIN

       BEGIN

           SELECT record_version_number
           INTO  l_version_num
           FROM pa_project_customers
           WHERE project_id = p_project_id
           AND customer_id = p_customer_id;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                l_version_num := NULL;
       END;

       IF NVL(l_version_num,0) = NVL(p_version_num,0) THEN

          RETURN 'T';

       ELSE

          RETURN 'F';

       END IF;

   END check_rec_version_num;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   set_rec_version_num                                                    |
   |   Purpose    :   This procedure sets the record version number of the given project     |
   |                  and customer id in pa_project_customers table                          |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id                     IN      Input Project id                           |
   |     p_customer_id                    IN      Input Customer id                          |
   |     p_version_num                    IN      old Record version number                  |
   |     x_version_num                    OUT     new Record version number                  |
   |     x_return_status                  OUT     Return Status                              |
   |     x_msg_count                      OUT     Message Count                              |
   |     x_msg_data                       OUT     Message Data                               |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


   PROCEDURE set_rec_version_num ( p_project_id          IN NUMBER,
                                    p_customer_id         IN NUMBER,
                                    p_version_num         IN NUMBER,
/*                                  x_version_num         OUT NUMBER, */
                                    x_return_status       OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                                    x_msg_count           OUT NOCOPY NUMBER,  --File.Sql.39 bug 4440895
                                    x_msg_data            OUT NOCOPY VARCHAR2) IS    --File.Sql.39 bug 4440895

        vers_valid                    VARCHAR2(1);
        l_return_status               VARCHAR2(30) := NULL;
        l_msg_count                   NUMBER       := NULL;
        l_msg_data                    VARCHAR2(30) := NULL;
        l_record_modified             EXCEPTION;

   BEGIN

       x_return_status    := FND_API.G_RET_STS_SUCCESS;
       x_msg_count        := 0;

       vers_valid := check_rec_version_num(p_project_id  => p_project_id,
                                           p_customer_id => p_customer_id,
                                           p_version_num => p_version_num);

       IF vers_valid = 'T' THEN

          update pa_project_customers
          set    record_version_number = p_version_num + 1
          where  project_id = p_project_id
          and    customer_id = p_customer_id
          and    record_version_number = p_version_num;

          /* x_version_num := p_version_num + 1; */

       ELSE

           RAISE l_record_modified;

       END IF;

    EXCEPTION

        WHEN l_record_modified THEN
             x_msg_count     := 1;
             x_msg_data      := 'PA_XC_RECORD_CHANGED';
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_RETENTION_UTIL',
                    p_procedure_name   => 'set_rec_version_num');

    END set_rec_version_num;


PROCEDURE retn_billing_method_single(
                          p_billing_mode                IN      VARCHAR2,
                          P_retention_level             IN      VARCHAR2,
                          p_project_id                  IN      VARCHAR2,
                          p_task_id                     IN      VARCHAR2,
                          p_customer_id                 IN      VARCHAR2,
                          p_retn_billing_cycle_id       IN      VARCHAR2,
                          p_billing_method_code         IN      VARCHAR2,
                          p_invproc_currency_code       IN      VARCHAR2,
                          p_completed_percentage        IN      VARCHAR2,
                          p_total_retention_amount      IN      VARCHAR2,
                          p_client_extension_flag       IN      VARCHAR2,
                          p_retn_billing_percentage     IN      VARCHAR2,
                          p_retn_billing_amount         IN      VARCHAR2,
                          p_version_num                 IN      NUMBER,
                          x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data                    OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS


  l_init_msg_list       VARCHAR2(20)        := FND_API.G_TRUE;

  l_count               NUMBER;
  l_row_count           NUMBER;

  l_tot_retn_amount             EXCEPTION;
  l_retn_billing_cycle          EXCEPTION;
  l_bill_per_either_amount      EXCEPTION;
  l_percentage_invalid          EXCEPTION;
  l_bill_per_either_amount_null EXCEPTION;
  l_neg_not_allowed             EXCEPTION;
  l_used_other_method           EXCEPTION;



  l_x_return_status               VARCHAR2(30)  := NULL;
  l_x_msg_count                   NUMBER        := NULL;
  l_x_msg_data                    VARCHAR2(200) := NULL;



BEGIN

  x_return_status    := FND_API.G_RET_STS_SUCCESS;
  x_msg_count        := 0;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


 /* -------------------------------------------------------------
     Validating the Input Data
     1) Total Retention Amount should not null, It can be Zero
     2) Cycle Id Should not be null
    ------------------------------------------------------------- */

   IF (p_billing_method_code = 'TOTAL_RETENTION_AMOUNT') THEN


      IF ((nvl(p_total_retention_amount, 0) < 0) OR (nvl(p_retn_billing_percentage,0) < 0)
           OR (nvl(p_retn_billing_amount,0) < 0)) THEN

         RAISE l_neg_not_allowed;

      END IF;


      IF  p_total_retention_amount IS NULL  THEN

          RAISE l_tot_retn_amount;

      END IF;


      IF  (p_retn_billing_percentage IS NULL) and (p_retn_billing_amount IS NULL) THEN

          RAISE l_bill_per_either_amount_null;

      END IF;

      IF  (p_retn_billing_percentage IS NOT NULL) and (p_retn_billing_amount IS NOT NULL) THEN

          RAISE l_bill_per_either_amount;

      END IF;


      IF (NVL(p_retn_billing_percentage, 0) > 100)  THEN

         RAISE l_percentage_invalid;

       END IF;



   ELSIF (p_billing_method_code = 'RETENTION_BILLING_CYCLE') THEN

      IF ((nvl(p_retn_billing_percentage,0) < 0)
           OR (nvl(p_retn_billing_amount,0) < 0)) THEN

         RAISE l_neg_not_allowed;

      END IF;


      IF  (p_retn_billing_cycle_id is NULL) THEN

         RAISE l_retn_billing_cycle;

      END IF;


      IF  (p_retn_billing_percentage IS NULL) and (p_retn_billing_amount IS NULL) THEN

          RAISE l_bill_per_either_amount_null;

      END IF;

      IF  (p_retn_billing_percentage IS NOT NULL) and (p_retn_billing_amount IS NOT NULL) THEN

          RAISE l_bill_per_either_amount;

      END IF;


      IF (NVL(p_retn_billing_percentage, 0) > 100)  THEN

         RAISE l_percentage_invalid;

       END IF;




   END IF;



      /*  Set the Record Version Number, This package will check for the database version number and
          What ever version number use in the program, If both are equal then return staus will be successful,
          If both are differnt then Other User is already updated the project Record so raising the error */


          pa_retention_util.set_rec_version_num ( p_project_id,
                                                  p_customer_id,
                                                  p_version_num,
                                                  l_x_return_status,
                                                  l_x_msg_count,
                                                  l_x_msg_data
                                                 );


          IF (l_x_return_status = 'E') THEN


             x_return_status := 'X';
             x_msg_count     := l_x_msg_count;
             x_msg_data      := l_x_msg_data;

             return;


          END IF;





/* ------------------------------------------------------------------
   Delete the Old method from Table and Insert a Row with New Method
   ------------------------------------------------------------------ */


   DELETE FROM pa_proj_retn_bill_rules
      WHERE project_id = p_project_id
        AND nvl(task_id, -99) = nvl(p_task_id, -99)
        AND customer_id = p_customer_id ;


   l_row_count := SQL%ROWCOUNT;


   IF (p_billing_mode = 'U')  AND  (l_row_count = 0) THEN


     RAISE l_used_other_method;    /* Other User is Changed this methdo */


   END IF;



/* ------------------------------------------------------------------
   Insert for the Following Billing Method.
    Total Retention Amount
    Retention Billing Cycle
    Client Extension
    'None' - No Insertion for or this method
   ------------------------------------------------------------------ */

 IF ((p_billing_method_code = 'TOTAL_RETENTION_AMOUNT') OR (p_billing_method_code = 'RETENTION_BILLING_CYCLE')
    OR (p_billing_method_code = 'CLIENT_EXTENSION')) THEN


   INSERT INTO pa_proj_retn_bill_rules
             ( PROJECT_ID   ,
               CUSTOMER_ID  ,
               TASK_ID,
               BILLING_METHOD_CODE,
               COMPLETED_PERCENTAGE,
               TOTAL_RETENTION_AMOUNT,
               RETN_BILLING_CYCLE_ID,
               CLIENT_EXTENSION_FLAG,
               RETN_BILLING_PERCENTAGE,
               RETN_BILLING_AMOUNT,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               RETN_BILLING_RULE_ID
            )
      VALUES(
               p_project_id,
               p_customer_id,
               p_task_id,
               p_billing_method_code,
               p_completed_percentage,
               p_total_retention_amount,
               p_retn_billing_cycle_id,
               p_client_extension_flag,
               p_retn_billing_percentage,
               p_retn_billing_amount,
               sysdate,
               -1,
               sysdate,
               -1,
               pa_proj_retn_bill_rules_s.nextval
             );

   END IF;



EXCEPTION
 WHEN l_retn_billing_cycle THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_BILL_CYCLE_NULL';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_single');
 WHEN l_tot_retn_amount THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_BILL_TOT_AMT_NULL';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_single');

 WHEN l_bill_per_either_amount THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_PERC_AMNT_EXIST';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_single');

 WHEN l_bill_per_either_amount_null THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_PERC_AMNT_NO_EXIST';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_single');
 WHEN l_neg_not_allowed THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_NEG_VAL';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_single');

 WHEN l_percentage_invalid THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_PERCENT_RANGE';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_single');

 WHEN l_used_other_method THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_RECORD_CHANGED';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_single');

 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SUBSTR(SQLERRM, 1, 240);
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_single');

END retn_billing_method_single;


PROCEDURE retn_billing_method_PerComp(
                          p_billing_mode                IN      VARCHAR2,
                          P_retention_level             IN      VARCHAR2,
                          p_project_id                  IN      VARCHAR2,
                          p_task_id                     IN      VARCHAR2,
                          p_customer_id                 IN      VARCHAR2,
                          p_retn_billing_cycle_id       IN      VARCHAR2,
                          p_billing_method_code         IN      VARCHAR2,
                          p_invproc_currency_code       IN      VARCHAR2,
                          p_completed_percentage        IN      PA_VC_1000_25,
                          p_total_retention_amount      IN      VARCHAR2,
                          p_client_extension_flag       IN      VARCHAR2,
                          p_retn_billing_percentage     IN      PA_VC_1000_25,
                          p_retn_billing_amount         IN      PA_VC_1000_25,
                          p_version_num                 IN      NUMBER,
                          x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data                    OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS

  l_init_msg_list       VARCHAR2(20)        := FND_API.G_TRUE;

  l_count               NUMBER;
  l_row_count           NUMBER;

  l_completed_percentage     PA_PLSQL_DATATYPES.Char30TabTyp;
  l_retn_billing_percentage  PA_PLSQL_DATATYPES.Char30TabTyp;
  l_retn_billing_amount      PA_PLSQL_DATATYPES.Char30TabTyp;


  l_comp_per                NUMBER;

  l_rec_count               NUMBER;

  l_retn_per_comp_dup           EXCEPTION;
  l_retn_per_comp_null          EXCEPTION;
  l_bill_per_either_amount      EXCEPTION;
  l_percentage_invalid          EXCEPTION;
  l_bill_per_either_amount_null EXCEPTION;
  l_neg_not_allowed             EXCEPTION;
  l_used_other_method           EXCEPTION;


  l_x_return_status               VARCHAR2(30)  := NULL;
  l_x_msg_count                   NUMBER        := NULL;
  l_x_msg_data                    VARCHAR2(200) := NULL;


BEGIN


  x_return_status    := FND_API.G_RET_STS_SUCCESS;
  x_msg_count        := 0;


  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;



    IF (p_completed_percentage.COUNT > 0) THEN


       FOR I in 1 .. p_completed_percentage.COUNT
       LOOP


          IF ( NVL(p_completed_percentage(i),0) = 0 ) THEN

              RAISE l_retn_per_comp_null;

          END IF;


         IF  (p_retn_billing_percentage(I) IS  NULL) and (p_retn_billing_amount(i) IS NULL) THEN

             RAISE l_bill_per_either_amount_null;

         END IF;


         IF  (p_retn_billing_percentage(I) IS  NOT NULL) and (p_retn_billing_amount(i) IS NOT NULL) THEN

             RAISE l_bill_per_either_amount;

        END IF;


         IF  (nvl(p_retn_billing_percentage(I),0) > 100)  OR ( NVL(p_completed_percentage(i),0) >100 ) THEN

             RAISE l_percentage_invalid;

         END IF;


         IF ((nvl(p_completed_percentage(i), 0) < 0) OR (nvl(p_retn_billing_percentage(i),0) < 0)
            OR (nvl(p_retn_billing_amount(i),0) < 0)) THEN

           RAISE l_neg_not_allowed;

         END IF;




          l_completed_percentage(i)     := p_completed_percentage(i);
          l_retn_billing_percentage(i)  := p_retn_billing_percentage(i);
          l_retn_billing_amount(i)      := p_retn_billing_amount(i);


       END LOOP;

    END IF;


  /* -------------------------------------------------------------
      Validating the Input
        -------------------------------------------------------------*/

   l_rec_count := l_completed_percentage.COUNT;


   IF (l_rec_count > 0) THEN


     FOR I in 1..l_rec_count
     LOOP


       FOR J in 1..l_rec_count
       LOOP


         IF ((i <> j) AND (l_completed_percentage(I) = l_completed_percentage(J))) THEN

            RAISE l_retn_per_comp_dup;

          END IF;


       END LOOP ;

     END LOOP ;

  END IF;



      /*  ---------------------------------------------------------------------------------------------------
          Set the Record Version Number, This package will check for the database version number and
          What ever version number use in the program, If both are equal then return staus will be successful,
          If both are differnt then Other User is already updated the project Record so raising the error
          --------------------------------------------------------------------------------------------------- */


          pa_retention_util.set_rec_version_num ( p_project_id,
                                                  p_customer_id,
                                                  p_version_num,
                                                  l_x_return_status,
                                                  l_x_msg_count,
                                                  l_x_msg_data
                                                 );


          IF (l_x_return_status = 'E') THEN


             x_return_status := 'X';
             x_msg_count     := l_x_msg_count;
             x_msg_data      := l_x_msg_data;


             return;


          END IF;





/* ---------------------------------------------------------------
   Delete the Old Method from Database
   --------------------------------------------------------------- */

   DELETE FROM pa_proj_retn_bill_rules
      WHERE project_id = p_project_id
        AND nvl(task_id, -99) = nvl(p_task_id, -99)
        AND customer_id = p_customer_id ;


   l_row_count := SQL%ROWCOUNT;


   IF (p_billing_mode = 'U')  AND  (l_row_count = 0) THEN


     RAISE l_used_other_method;    /* Other User is Changed this method */


   END IF;



 IF (l_completed_percentage.COUNT > 0) THEN


  FOR I IN 1 .. l_completed_percentage.COUNT
  LOOP

    INSERT INTO pa_proj_retn_bill_rules
             ( PROJECT_ID   ,
               CUSTOMER_ID  ,
               TASK_ID,
               BILLING_METHOD_CODE,
               COMPLETED_PERCENTAGE,
               TOTAL_RETENTION_AMOUNT,
               RETN_BILLING_CYCLE_ID,
               CLIENT_EXTENSION_FLAG,
               RETN_BILLING_PERCENTAGE,
               RETN_BILLING_AMOUNT,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               RETN_BILLING_RULE_ID
            )
      VALUES(
               p_project_id,
               p_customer_id,
               p_task_id,
               p_billing_method_code,
               l_completed_percentage(i),
               p_total_retention_amount,
               p_retn_billing_cycle_id,
               p_client_extension_flag,
               l_retn_billing_percentage(i),
               l_retn_billing_amount(i),
               sysdate,
               -1,
               sysdate,
               -1,
               pa_proj_retn_bill_rules_s.nextval
             );


    END LOOP;

 END IF;



EXCEPTION
 WHEN l_retn_per_comp_dup THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_BILL_PER_COMP_DUP';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_PerComp');

 WHEN l_retn_per_comp_null THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_BILL_PER_COMP_NULL';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_PerComp');

 WHEN l_bill_per_either_amount THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_PERC_AMNT_EXIST';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_PerComp');

 WHEN l_bill_per_either_amount_null THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_PERC_AMNT_NO_EXIST';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_PerComp');

 WHEN l_percentage_invalid THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_PERCENT_RANGE';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_PerComp');
 WHEN l_neg_not_allowed THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_NEG_VAL';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_PerComp');
 WHEN l_used_other_method THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_RECORD_CHANGED';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_PerComp');
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      -- dbms_output.put_line(SQLERRM);
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_method_PerComp');

END retn_billing_method_PerComp ;







PROCEDURE retn_billing_task_validate(
                          p_project_id                  IN      VARCHAR2,
                          P_task_name                   IN      VARCHAR2,
                          p_task_no                     IN      VARCHAR2,
                          p_customer_id                 IN      VARCHAR2,
                          p_retention_level             IN      VARCHAR2,
                          x_task_id                     OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data                    OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS


  l_init_msg_list          VARCHAR2(20)        := FND_API.G_TRUE;


  l_retn_task_name_null    EXCEPTION;
  l_retn_task_no_null      EXCEPTION;
  l_bill_rec_exists        EXCEPTION;

  l_message_code           VARCHAR2(30);


  l_name_task_id           NUMBER;
  l_no_task_id             NUMBER;
  l_bill_rec_count         NUMBER;




BEGIN



  x_return_status    := FND_API.G_RET_STS_SUCCESS;
  x_msg_count        := 0;


  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  l_message_code := NULL;


 /* If Retention Level is Task then validating the Task and also check this
     task already exists in pa_proj_retn_bill_rules table */

IF  (p_retention_level = 'T')  THEN


  IF ((p_task_name IS NOT NULL)  AND (p_task_no IS NULL)) THEN



    BEGIN

     SELECT top_task_id
       INTO x_task_id
       FROM pa_tasks
      WHERE project_id = p_project_id
        AND task_id = top_task_id
        AND task_name = p_task_name;


    EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_message_code := 'PA_TASK_NAME_INVALID';
     WHEN TOO_MANY_ROWS THEN
          l_message_code := 'PA_TASK_NAME_INVALID';

    END;


  END IF;



  IF ((p_task_name IS NULL)  AND (p_task_no IS NOT NULL)) THEN


   BEGIN


     SELECT top_task_id
       INTO x_task_id
       FROM pa_tasks
      WHERE project_id = p_project_id
        AND task_id = top_task_id
        AND task_number = p_task_no;


    EXCEPTION
         WHEN NO_DATA_FOUND THEN
         l_message_code := 'PA_TASK_NUMBER_INVALID';
         WHEN TOO_MANY_ROWS THEN
         l_message_code := 'PA_TASK_NUMBER_INVALID';


    END;

  END IF;



  IF ((p_task_name IS NOT NULL)  AND (p_task_no IS NOT NULL)) THEN



    BEGIN


     SELECT top_task_id
       INTO l_name_task_id
       FROM pa_tasks
      WHERE project_id = p_project_id
        AND task_id = top_task_id
        AND task_name = p_task_name;


    EXCEPTION
     WHEN NO_DATA_FOUND THEN
         l_name_task_id  := -99;
     WHEN TOO_MANY_ROWS THEN
         l_name_task_id := -99;

    END;


    BEGIN


     SELECT top_task_id
       INTO l_no_task_id
       FROM pa_tasks
      WHERE project_id = p_project_id
        AND task_id = top_task_id
        AND task_number = p_task_no;



    EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_name_task_id := -99;
     WHEN TOO_MANY_ROWS THEN
          l_name_task_id := -99;

    END;


     IF (l_name_task_id <> l_no_task_id) OR (l_name_task_id = -99) THEN


        l_message_code := 'PA_TASK_INVALID';

     ELSE


       x_task_id := l_name_task_id;

     END IF;


  END IF;


  IF ((p_task_name IS NULL)  AND (p_task_no IS NULL)) THEN

       l_message_code := 'PA_TASK_NULL';

  END IF;




    IF (l_message_code IS NOT NULL) THEN


       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count     := 1;
       x_msg_data      := l_message_code;

    END IF;



    IF (l_message_code IS NULL) THEN


        SELECT count(*)
          INTO l_bill_rec_count
          FROM  pa_proj_retn_bill_rules
         WHERE project_id = p_project_id
           AND task_id = x_task_id
           AND customer_id = p_customer_id;

          IF (l_bill_rec_count > 0) THEN

             RAISE l_bill_rec_exists;

          END IF;


     END IF;


ELSIF (p_retention_level = 'P') THEN


        SELECT count(*)
          INTO l_bill_rec_count
          FROM pa_proj_retn_bill_rules
         WHERE project_id = p_project_id
           AND customer_id = p_customer_id;


          IF (l_bill_rec_count > 0) THEN

             RAISE l_bill_rec_exists;

          END IF;


END IF;

EXCEPTION
 WHEN l_bill_rec_exists THEN
      x_task_id := NULL; --NOCOPY
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_RETN_BILL_REC_EXIST';
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_task_validate');

 WHEN OTHERS THEN
      x_task_id := NULL; --NOCOPY
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_RETENTION_UTIL',
                               p_procedure_name   => 'retn_billing_task_validate');



END retn_billing_task_validate;

---- Following APIs are added by Bhumesh K.

PROCEDURE Check_For_Overlap_Dates (
  P_RowID				VARCHAR2,
  P_Project_ID				NUMBER,
  P_Task_ID				NUMBER,
  P_Customer_ID				NUMBER,
  P_Retention_Level_Code		VARCHAR2,
  P_Expenditure_Category              	VARCHAR2,
  P_Expenditure_Type                  	VARCHAR2,
  P_Non_Labor_Resource                	VARCHAR2,
  P_Revenue_Category_Code             	VARCHAR2,
  P_Event_Type                        	VARCHAR2,
  P_Effective_Start_Date		DATE,
  P_Effective_End_Date			DATE,
  X_Return_Status_Code		IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_Error_Message_Code		IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
l_Exist_Flag  VARCHAR2(1) := 'N';
l_Max_Start_Date date;
l_Max_End_Date   date;

CURSOR Retention_Rules IS
  SELECT Effective_Start_Date, Effective_End_Date
  FROM   PA_PROJ_RETN_RULES
  WHERE  Project_ID 	= P_Project_ID
  AND    NVL(Task_ID, -1) = NVL(P_Task_ID, -1)
  AND    Customer_ID 	= P_Customer_ID
  AND    Retention_Level_Code = P_Retention_Level_Code
  AND    NVL(Expenditure_Category, 'X') = NVL(P_Expenditure_Category, 'X')
  AND    NVL(Expenditure_Type, 'X')     = NVL(P_Expenditure_Type, 'X')
  AND    NVL(Non_Labor_Resource, 'X')   = NVL(P_Non_Labor_Resource, 'X')
  AND    NVL(Revenue_Category_Code, 'X')= NVL(P_Revenue_Category_Code, 'X')
  AND    NVL(Event_Type, 'X')           = NVL(P_Event_Type, 'X')
  AND    decode(P_RowID, NULL, 'X', RowIDToChar(RowID))
	     <> decode(P_RowID, NULL, 'Y', P_RowID );

BEGIN

  -- dbms_output.put_line('Check for Start Date is Null');
  IF P_Effective_Start_Date IS NULL
  THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR; -- 'E';
      X_Error_Message_Code := 'PA_EFF_START_DATE_NULL';
      RETURN;
  END IF;

  -- dbms_output.put_line('Check for End Date is Null');
  IF P_Effective_End_Date IS NOT NULL
  THEN
    IF P_Effective_End_Date  < P_Effective_Start_Date
    THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR; -- 'E';
      X_Error_Message_Code := 'PA_INVALID_END_DATE';
      RETURN;
    END IF;
  END IF;

  FOR Rules_Rec IN Retention_Rules
  LOOP
    BEGIN
      IF ( Rules_Rec.Effective_End_Date IS NULL AND
	   P_Effective_Start_Date >= Rules_Rec.Effective_Start_Date ) OR
	 ( Rules_Rec.Effective_End_Date IS NULL AND
	   P_Effective_End_Date >= Rules_Rec.Effective_Start_Date )
      THEN
        X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
        X_Error_Message_Code := 'PA_SU_OVERLAP_RANGES';
	RETURN;
      END IF;

      IF ( P_Effective_Start_Date BETWEEN
	     Rules_Rec.Effective_Start_Date AND Rules_Rec.Effective_End_Date ) OR
	 ( P_Effective_End_Date BETWEEN
	     Rules_Rec.Effective_Start_Date AND Rules_Rec.Effective_End_Date )
      THEN
        X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
        X_Error_Message_Code := 'PA_SU_OVERLAP_RANGES';
	RETURN;
      END IF;

      IF ( Rules_Rec.Effective_End_Date IS NOT NULL AND
	 ( P_Effective_Start_Date <= Rules_Rec.Effective_Start_Date OR
	   P_Effective_Start_Date <= Rules_Rec.Effective_End_Date ) AND
	 P_Effective_End_Date   >= Rules_Rec.Effective_Start_Date )
      THEN
        X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
        X_Error_Message_Code := 'PA_SU_OVERLAP_RANGES';
	RETURN;
      END IF;

      IF Rules_Rec.Effective_End_Date IS NOT NULL AND
	 P_Effective_Start_Date <= Rules_Rec.Effective_Start_Date  AND
	 P_Effective_End_Date IS NULL
      THEN
        X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
        X_Error_Message_Code := 'PA_SU_OVERLAP_RANGES';
	RETURN;
      END IF;
    END;
  END LOOP;

END Check_For_Overlap_Dates;


PROCEDURE Validate_Expenditure_Category (
  P_Expenditure_Category	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_Expenditure_Type		IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_Non_Labor_Resource		IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_Return_Status_Code		IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_Error_Message_Code		IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

    l_expenditure_type varchar2(30) := p_expenditure_type;
    l_expenditure_category varchar2(30) := p_expenditure_category;
    l_non_labor_resource  varchar2(30) := p_non_labor_resource ;
BEGIN

  X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS;

  IF P_Expenditure_Category IS NULL
  THEN
    X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
    X_Error_Message_Code := 'PA_NO_EXPENDITURE_CATEGORY';
    RETURN;
  END IF;

  IF P_Expenditure_Category IS NOT NULL AND
     P_Non_Labor_Resource   IS NOT NULL AND
     P_Expenditure_Type     IS NULL
  THEN
    X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
    X_Error_Message_Code := 'PA_INVALID_EXPENDITURE_TYPE';
    RETURN;
  END IF;

  BEGIN
    SELECT
      Expenditure_Category
    INTO
      P_Expenditure_Category
    FROM
      PA_EXPENDITURE_CATEGORIES
    WHERE
      upper(Expenditure_Category) = upper(P_Expenditure_Category);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_expenditure_category := l_expenditure_category; -- NOCOPY
        X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
        X_Error_Message_Code := 'PA_NO_EXPENDITURE_CATEGORY';
	RETURN;
  END;

  IF  P_Expenditure_Type     IS NOT NULL AND
      P_Expenditure_Category IS NOT NULL AND
      X_Return_Status_Code <> FND_API.G_RET_STS_ERROR
  THEN
    BEGIN
      SELECT
	Expenditure_Type
      INTO
	P_Expenditure_Type
      FROM
	PA_EXPENDITURE_TYPES
      WHERE
	  upper(Expenditure_Category) = upper(P_Expenditure_Category)
      AND upper(Expenditure_Type)     = upper(P_Expenditure_Type);
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
          P_expenditure_category := l_expenditure_category; -- NOCOPY
          P_expenditure_type := l_expenditure_type; -- NOCOPY
          X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
          X_Error_Message_Code := 'PA_INVALID_EXPENDITURE_TYPE';
	  RETURN;
    END;
  END IF;

  IF  P_Non_Labor_Resource   IS NOT NULL  AND
      P_Expenditure_Type     IS NOT NULL  AND
      P_Expenditure_Category IS NOT NULL  AND
      X_Return_Status_Code <> FND_API.G_RET_STS_ERROR
  THEN
    BEGIN
      SELECT
	Non_Labor_Resource
      INTO
	P_Non_Labor_Resource
      FROM
	PA_NON_LABOR_RESOURCES
      WHERE
	  upper(Non_Labor_Resource) = upper(P_Non_Labor_Resource)
      AND upper(Expenditure_Type)   = upper(P_Expenditure_Type);
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
          P_expenditure_category := l_expenditure_category; -- NOCOPY
          P_expenditure_type := l_expenditure_type; -- NOCOPY
          P_non_labor_resource := l_non_labor_resource; -- NOCOPY
          X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
          X_Error_Message_Code := 'PA_NLR_INV_FOR_EXP_TYPE';
	  RETURN;
    END;
  END IF;

END Validate_Expenditure_Category;


PROCEDURE Validate_Revenue_Category (
  P_Revenue_Category_Code	   OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_Revenue_Category		IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_Event_Type			IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_Return_Status_Code		IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_Error_Message_Code		IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
l_Exist_Flag VARCHAR2(1) := '';
l_revenue_category varchar2(30) := p_revenue_category;
l_event_type varchar2(30) := p_event_type;
BEGIN

  X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS;

  IF P_Revenue_Category IS NULL
  THEN
    X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
    X_Error_Message_Code := 'PA_NO_REVENUE_CATEGORY';
    RETURN;
  END IF;

  BEGIN
    SELECT Lookup_Code, Meaning
    INTO   P_Revenue_Category_Code, P_Revenue_Category
    FROM   PA_LOOKUPS
    WHERE  Lookup_Type    = 'REVENUE CATEGORY'
    AND    upper(Meaning) = upper(P_Revenue_Category);
    EXCEPTION
      WHEN OTHERS THEN
        p_revenue_category := l_revenue_category; --NOCOPY
        X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
	X_Error_Message_Code := 'PA_NO_REVENUE_CATEGORY';
        RETURN;
  END;

  IF  P_Event_Type            IS NOT NULL AND
      P_Revenue_Category_Code IS NOT NULL
  THEN
    BEGIN
      SELECT Event_Type
      INTO   P_Event_Type
      FROM   PA_EVENT_TYPES
      WHERE  upper(Revenue_Category_Code) = upper(P_Revenue_Category_Code)
      AND    upper(Event_Type)            = upper(P_Event_Type);
      X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS;
      EXCEPTION
        WHEN OTHERS THEN
          p_revenue_category_code := null; --NOCOPY
          p_revenue_category := l_revenue_category; --NOCOPY
          p_event_type := l_event_type; --NOCOPY
          X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
          X_Error_Message_Code := 'PA_EVENT_INV_FOR_REV_CATEG';
	  RETURN;
    END;
  END IF;

END Validate_Revenue_Category;


PROCEDURE Delete_Retentions (
  P_Project_ID				NUMBER,
  P_Customer_ID				NUMBER,
  X_Return_Status_Code		IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_Error_Message_Code		IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
l_Exist_Flag VARCHAR2(1) := '';
BEGIN

  X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS; -- 'S';

  BEGIN
    DELETE FROM PA_PROJ_RETN_RULES
    WHERE  Project_ID  = P_Project_ID
    AND    Customer_ID = P_Customer_ID;

    DELETE FROM PA_PROJ_RETN_BILL_RULES
    WHERE  Project_ID  = P_Project_ID
    AND    Customer_ID = P_Customer_ID;

    UPDATE PA_PROJECT_CUSTOMERS
    SET    Retention_Level_Code = ''
    WHERE  Project_ID  = P_Project_ID
    AND    Customer_ID = P_Customer_ID;

    COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR; -- 'E';
      X_Error_Message_Code := 'PA_DATA_ERROR';
  END;
END Delete_Retentions;


PROCEDURE Check_Top_Task_Details (
    P_Project_ID                        NUMBER,
    P_Task_Number                       VARCHAR2,
    P_Task_Name                         VARCHAR2,
    X_Task_ID                   IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
    X_Return_Status_Code        IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code        IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

   l_task_id number := x_task_id;
  BEGIN

    BEGIN
      SELECT Task_ID
      INTO  X_Task_ID
      FROM  PA_TASKS
      WHERE Project_ID         = P_Project_ID
      AND   upper(Task_Number) = upper(P_Task_Number)
      AND   upper(Task_Name)   = upper(P_Task_Name) ;
      X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS;
      EXCEPTION WHEN OTHERS THEN
        X_Task_ID := l_task_id;
        X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
        X_Error_Message_Code := 'PA_TASK_INVALID';
    END;

  END  Check_Top_Task_Details;

  PROCEDURE Delete_Bill_Retentions (
	P_Bill_Rule_ID      		NUMBER,
	X_Return_Status_code	IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_Error_Message_Code	IN OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

  BEGIN

    X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS; -- 'S';

    DELETE FROM
      PA_PROJ_RETN_BILL_RULES
    WHERE
      RETN_BILLING_RULE_ID = P_Bill_Rule_ID ;
    COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR; -- 'E';
      X_Error_Message_Code := 'PA_DATA_ERROR';

  END Delete_Bill_Retentions ;

  PROCEDURE Check_Billing_Retentions (
    P_Project_ID                        NUMBER,
    P_Customer_ID                       NUMBER,
    X_Return_Status_code	IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code	IN OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS
  l_Exist_Flag NUMBER;
  BEGIN
    X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS; -- 'S';
    BEGIN
      SELECT
	  1
      INTO
	  l_Exist_Flag
      FROM
	  PA_PROJ_RETN_BILL_RULES
      WHERE
	  Project_ID = P_Project_ID
      AND Customer_ID = P_Customer_ID
      AND RowNum < 2;
      X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS; -- 'S';
      X_Error_Message_Code := '';
      EXCEPTION
	WHEN OTHERS THEN
	  X_Return_Status_Code := FND_API.G_RET_STS_ERROR; -- 'E';
          X_Error_Message_Code := '';
    END;

  END Check_Billing_Retentions ;


  PROCEDURE Validate_Retention_Data (
    P_RowID                         VARCHAR2,
    P_Project_ID                    NUMBER,
    P_Task_Number                   VARCHAR2,
    P_Task_Name                     VARCHAR2,
    P_Customer_ID                   NUMBER,
    P_Retention_Level_Code  IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Expenditure_Category  IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Expenditure_Type      IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Non_Labor_Resource    IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Revenue_Category      IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Event_Type            IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Retention_Percentage          NUMBER,
    P_Retention_Amount              NUMBER,
    P_Threshold_Amount              NUMBER,
    P_Effective_Start_Date          DATE,
    P_Effective_End_Date            DATE,
    P_Task_Flag			    VARCHAR2,
    X_Task_ID               IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
    X_Revenue_Category_Code IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Return_Status_code    IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code    IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

    l_retention_level_code varchar2(30) := P_Retention_Level_Code;
    l_Expenditure_Category varchar2(30) := P_Expenditure_Category;
    l_Expenditure_Type varchar2(30) := P_Expenditure_Type;
    l_Non_Labor_Resource varchar2(30) := P_Non_Labor_Resource;
    l_Revenue_Category varchar2(30) := P_Revenue_Category;
    l_Event_Type varchar2(30) := P_Event_Type;
    l_Task_ID varchar2(30) := X_Task_ID ;
    l_Revenue_Category_Code varchar2(30) := X_Revenue_Category_Code;



  BEGIN

    IF (P_Task_Number	       IS NULL AND
	P_Task_Name	       IS NULL AND
	P_Expenditure_Category IS NULL AND
	P_Expenditure_Type     IS NULL AND
	P_Non_Labor_Resource   IS NULL AND
	P_Revenue_Category     IS NULL AND
	P_Event_Type           IS NULL AND
        P_Retention_Percentage IS NULL AND
	P_Retention_Amount     IS NULL AND
	P_Threshold_Amount     IS NULL AND
	P_Effective_Start_Date IS NULL AND
	P_Effective_End_Date   IS NULL
       )
    THEN
      RETURN;
    END IF;

    IF P_Task_Flag = 'Y' AND P_Task_Number IS NULL
    THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
      X_Error_Message_Code := 'PA_TASK_NUMBER_INVALID'; -- 'PA_NO_TASK_NUMBER';
      RETURN;
    END IF;

    IF P_Task_Flag = 'Y' AND P_Task_Name IS NULL
    THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
      X_Error_Message_Code := 'PA_TASK_NAME_INVALID'; -- 'PA_NO_TASK_NAME';
      RETURN;
    END IF;

    IF P_Task_Number IS NOT NULL AND P_Task_Name IS NOT NULL
    THEN
      Check_Top_Task_Details (
        P_Project_ID          => P_Project_ID,
        P_Task_Number         => P_Task_Number,
        P_Task_Name           => P_Task_Name,
        X_Task_ID             => X_Task_ID,
        X_Return_Status_Code  => X_Return_Status_Code,
        X_Error_Message_Code  => X_Error_Message_Code );

      IF X_Return_Status_Code = FND_API.G_RET_STS_ERROR
      THEN
        RETURN;
      END IF;

    END IF;

    IF P_Retention_Percentage IS NULL AND P_Retention_Amount IS NULL
    THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
      X_Error_Message_Code := 'PA_RETN_PERC_OR_AMT_ENTER';
      RETURN;
    END IF;

    IF P_Retention_Percentage > 0 AND P_Retention_Amount > 0
    THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
      X_Error_Message_Code := 'PA_RETN_PERC_OR_AMT_ENTER';
      RETURN;
    END IF;

    IF P_Retention_Percentage NOT BETWEEN 0 AND 100
    THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
      X_Error_Message_Code := 'PA_RETN_PERCENT_RANGE';
      RETURN;
    END IF;

    IF P_Retention_Percentage < 0 OR
       P_Retention_Amount     < 0 OR
       P_Threshold_Amount     < 0
    THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
      X_Error_Message_Code := 'PA_RETN_NEG_VAL';
      RETURN;
    END IF;

    IF (P_Threshold_Amount < P_Retention_Amount) AND
       (P_Retention_Amount IS NOT NULL)
    THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
      X_Error_Message_Code := 'PA_RETN_INV_THRESHOLD_AMOUNT';
      RETURN;
    END IF;

    IF P_Retention_Level_Code IN ('EXPENDITURE_CATEGORY', 'EXPENDITURE_TYPE', 'NON_LABOR')
    THEN
      PA_Retention_Util.Validate_Expenditure_Category (
          P_Expenditure_Category   => P_Expenditure_Category,
          P_Expenditure_Type       => P_Expenditure_Type,
          P_NON_Labor_Resource     => P_Non_Labor_Resource,
          X_Return_Status_Code     => X_Return_Status_code,
          X_Error_Message_Code     => X_Error_Message_Code
      );
      IF X_Return_Status_Code = FND_API.G_RET_STS_SUCCESS
      THEN
        IF P_Expenditure_Category IS NOT NULL
        THEN
	  P_Retention_Level_Code := 'EXPENDITURE_CATEGORY';
        END IF;
        IF P_Expenditure_Type IS NOT NULL
        THEN
	  P_Retention_Level_Code := 'EXPENDITURE_TYPE';
        END IF;
        IF P_NON_Labor_Resource IS NOT NULL
        THEN
	  P_Retention_Level_Code := 'NON_LABOR';
        END IF;
      END IF;
    END IF;

    IF P_Retention_Level_Code IN ('REVENUE_CATEGORY', 'EVENT_TYPE')
    THEN
      PA_Retention_Util.Validate_Revenue_Category (
          P_Revenue_Category_Code => X_Revenue_Category_Code,
          P_Revenue_Category  	  => P_Revenue_Category,
          P_Event_Type      	  => P_Event_Type,
          X_Return_Status_Code    => X_Return_Status_code,
          X_Error_Message_Code    => X_Error_Message_Code
      );
      IF X_Return_Status_Code = FND_API.G_RET_STS_SUCCESS
      THEN
        IF P_Revenue_Category IS NOT NULL
        THEN
	  P_Retention_Level_Code := 'REVENUE_CATEGORY';
        END IF;
        IF P_Event_Type IS NOT NULL
	THEN
	  P_Retention_Level_Code := 'EVENT_TYPE';
	END IF;
      END IF;
    END IF;

    IF X_Return_Status_Code = FND_API.G_RET_STS_ERROR
    THEN
      RETURN;
    END IF;

    --- Performing Validations
    PA_Retention_Util.Check_For_Overlap_Dates (
	P_RowID			=> P_RowID,
        P_PROJECT_ID		=> P_Project_ID,
        P_Task_ID		=> X_Task_ID,
        P_CUSTOMER_ID	 	=> P_Customer_ID,
	P_Retention_Level_Code  => P_Retention_Level_Code,
        P_Expenditure_Category  => P_Expenditure_Category,
	P_Expenditure_Type 	=> P_Expenditure_Type,
	P_Non_Labor_Resource    => P_Non_Labor_Resource,
	P_Revenue_Category_Code => X_Revenue_Category_Code,
	P_Event_Type            => P_Event_Type,
        P_EFFECTIVE_START_DATE 	=> P_Effective_Start_Date,
        P_EFFECTIVE_END_DATE	=> P_Effective_End_Date,
        X_RETURN_STATUS_CODE	=> X_RETURN_STATUS_CODE,
        X_ERROR_MESSAGE_CODE	=> X_ERROR_MESSAGE_CODE
    );

    IF X_Return_Status_Code = FND_API.G_RET_STS_ERROR
    THEN
      RETURN;
    END IF;
  EXCEPTION
     when no_data_found then

         p_retention_level_code  := l_Retention_Level_Code;
         p_Expenditure_Category  := l_Expenditure_Category;
         p_Expenditure_Type  := l_Expenditure_Type;
         p_Non_Labor_Resource  := l_Non_Labor_Resource;
         p_Revenue_Category  := l_Revenue_Category;
         p_Event_Type  := l_Event_Type;
         x_Task_ID  := l_Task_ID ;
         x_Revenue_Category_Code  := l_Revenue_Category_Code;

  END Validate_Retention_Data;

  PROCEDURE Check_Retention_Rules (
    P_Project_ID                        NUMBER,
    P_Customer_ID                       NUMBER,
    X_Return_Value		IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
    X_Return_Status_code	IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code	IN OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

  l_Retained_Count 	NUMBER := 0;
  l_NonRetained_Count	NUMBER := 0;
  l_Billing_Rules_Count NUMBER := 0;

  BEGIN
    X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS; -- 'S';
    BEGIN
      SELECT
	NVL(sum( decode(nvl(total_retained,0),0,1,0)),0),
	NVL(sum( decode(nvl(total_retained,0),0,0,1)),0)
      INTO
	   l_NonRetained_Count,
	   l_Retained_Count
      FROM
	   PA_PROJ_RETN_RULES
      WHERE
	  Project_ID  = P_Project_ID
      AND Customer_ID = P_Customer_ID;
    END;

    BEGIN
      SELECT 1
      INTO   l_Billing_Rules_Count
      FROM
	  PA_PROJ_RETN_BILL_RULES
      WHERE
	  Project_ID  = P_Project_ID
      AND Customer_ID = P_Customer_ID
      AND RowNum < 2;
      EXCEPTION WHEN OTHERS THEN
	l_Billing_Rules_Count := 0;
    END;

    -- Dbms_Output.Put_Line('l_NonRetained_Count : '||l_NonRetained_Count);
    -- Dbms_Output.Put_Line('l_Retained_Count    : '||l_Retained_Count);
    -- Dbms_Output.Put_Line('l_Billing_Rules_Count : '||l_Billing_Rules_Count);

    -- Disable Both the buttons
    IF l_Retained_Count > 0
    THEN
      X_Return_Value := 0;
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    IF ( l_NonRetained_Count   = 0 AND
	 l_Retained_Count      = 0 AND
	 l_Billing_Rules_Count = 0 )
    THEN
      X_Return_Value := 2;
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    -- Enable Both the buttons
    IF l_NonRetained_Count > 0 OR l_Billing_Rules_Count > 0
    THEN
      X_Return_Value := 1;
      X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS;
      RETURN;
    END IF;

  END Check_Retention_Rules ;
   /*----------------------------------------------------------------------------------------+
   |   Function   :   IsRetentionExists                                                      |
   |   Purpose    :   To find the retention setup exists or not 			     |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id                     IN      Project Id                                 |
   |     p_retn_inv_fmt                   IN      Invoice Format ID                	     |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

FUNCTION CheckRetnInvFormat(p_project_id 	IN NUMBER,
                            p_retn_inv_fmt 	IN NUMBER) RETURN NUMBER IS
l_retn_invfmt_error  NUMBER:=0;
BEGIN
	BEGIN

		SELECT 1
	  	  INTO l_retn_invfmt_error
		  FROM dual
		 WHERE EXISTS(SELECT null
		       FROM pa_proj_retn_rules rtn
		      WHERE rtn.project_id = p_project_id);

		IF l_retn_invfmt_error = 1 THEN
			IF NVL(p_retn_inv_fmt,0)<>0  THEN
				l_retn_invfmt_error := 0;
			ELSE
				l_retn_invfmt_error := 1;
			END IF;
		END IF;

  	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		l_retn_invfmt_error := 0;
	END;

	RETURN(l_retn_invfmt_error);
END CheckRetnInvFormat;


END pa_retention_util;

/
