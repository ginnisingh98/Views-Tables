--------------------------------------------------------
--  DDL for Package Body PA_BILLING_SCHEDULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_SCHEDULE_PUB" AS
/* $Header: PABLINPB.pls 120.3 2005/08/19 16:16:18 mwasowic noship $ */

   G_PKG_NAME       VARCHAR2(30) := 'PA_BILLING_SCHEDULE_PUB';

-- API name                      : Update_Project_Task_Bill_Info
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	       	 IN	 NUMBER     REQUIRED   DEFAULT=1.0
-- p_init_msg_list	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_commit	         	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_lbr_schedule_type	 	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_non_lbr_schedule_type	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_emp_bill_rate_sch_name	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_emp_bill_rate_sch_id 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_job_bill_rate_sch_name	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_job_bill_rate_sch_id   	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_lbr_sch_fxd_date	 	 IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_lbr_sch_discount	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_rev_schedule	         IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_rev_schedule_id	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_inv_schedule	       	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_inv_schedule_id	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_rev_ind_sch_fxd_date	 IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_inv_ind_sch_fxd_date 	 IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_nlbr_bill_rate_org	 	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_nlbr_bill_rate_org_id	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_nlbr_std_bill_rate_sch	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_nlbr_sch_fxd_date	         IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_nlbr_sch_discount	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	         OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	                 OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	                 OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Update_Project_Task_Bill_Info(
   p_api_version	       	 IN	 NUMBER     DEFAULT 1.0,
   p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
   p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
   p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
   p_validation_level	         IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
   p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
   p_debug_mode	                 IN	 VARCHAR2   DEFAULT 'N',
   p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
   p_project_id	                 IN	 NUMBER    ,
   p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
   p_lbr_schedule_type	       IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
   p_non_lbr_schedule_type     IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
   p_emp_bill_rate_sch_name    IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR  ,
   p_emp_bill_rate_sch_id      IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
   p_job_bill_rate_sch_name    IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR   ,
   p_job_bill_rate_sch_id      IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
   p_lbr_sch_fxd_date	       IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
   p_lbr_sch_discount	       IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
   p_rev_schedule	       IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR  ,
   p_rev_schedule_id	       IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
   p_inv_schedule	         IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR  ,
   p_inv_schedule_id	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
   p_rev_ind_sch_fxd_date	 IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
   p_inv_ind_sch_fxd_date 	 IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
   p_nlbr_bill_rate_org	 	 IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR  ,
   p_nlbr_bill_rate_org_id	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
   p_nlbr_std_bill_rate_sch	 IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR  ,
   p_nlbr_sch_fxd_date	         IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
   p_nlbr_sch_discount	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
   p_record_version_number	 IN	 NUMBER     DEFAULT 1,
   x_return_status	         OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
   x_msg_count	                 OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
   x_msg_data	                 OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )  IS

            --Derive bill_job_group_id from pa_projects_prm_v using project-task id.
  CURSOR cur_job_group IS
         SELECT bill_job_group_id
           FROM pa_projects_prm_v
          WHERE project_id = p_project_id;
          --AND task_id = decode( p_task_id, FND_API.G_MISS_NUM, p_task_id );

  l_api_name                CONSTANT VARCHAR(30) := 'Update_Project_Task_Bill_Info';
  l_api_version             CONSTANT NUMBER      := 1.0;

  l_return_status                    VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_msg_data                   VARCHAR2(250);
  l_dummy_char                       VARCHAR2(1);
  l_msg_count                        NUMBER;
  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;

  l_job_group_id                     NUMBER;

  l_emp_bill_rate_sch_id             NUMBER;
  l_job_bill_rate_sch_id             NUMBER;
  l_lbr_sch_fxd_date	             DATE;
  l_lbr_sch_discount	             NUMBER;
  l_rev_schedule_id	             NUMBER;
  l_inv_schedule_id                  NUMBER;
  l_rev_ind_sch_fxd_date             DATE;
  l_inv_ind_sch_fxd_date 	       DATE;
  l_nlbr_bill_rate_org_id	       NUMBER;
  l_nlbr_std_bill_rate_sch	       VARCHAR2(30);
  l_nlbr_sch_fxd_date	             DATE;
  l_nlbr_sch_discount	             NUMBER;

BEGIN
   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('Update Bill Info PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT prm_create_project;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update Bill Info PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SCHEDULE_PUB.Update_Project_Task_Bill_Info');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := 'S';

   IF p_validate_only = FND_API.G_TRUE AND p_validation_level > 0
   THEN
      IF p_lbr_schedule_type = 'B' AND p_non_lbr_schedule_type= 'B'
      THEN

         l_rev_schedule_id := null;
         l_inv_schedule_id := null;
         l_rev_ind_sch_fxd_date := null;
         l_inv_ind_sch_fxd_date := null;

         l_nlbr_bill_rate_org_id := p_nlbr_bill_rate_org_id;
         l_nlbr_std_bill_rate_sch := p_nlbr_std_bill_rate_sch;
         l_nlbr_sch_fxd_date := p_nlbr_sch_fxd_date;
         l_nlbr_sch_discount := p_nlbr_sch_discount;

         l_emp_bill_rate_sch_id := p_emp_bill_rate_sch_id;
         l_lbr_sch_fxd_date := p_lbr_sch_fxd_date;
         l_lbr_sch_discount := p_lbr_sch_discount;
         l_job_bill_rate_sch_id := p_job_bill_rate_sch_id;

         --validating organization
         IF ( p_nlbr_bill_rate_org_id IS NOT NULL AND p_nlbr_bill_rate_org_id <> FND_API.G_MISS_NUM ) OR
            ( p_nlbr_bill_rate_org IS NOT NULL AND p_nlbr_bill_rate_org <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Carrying out organization');
            end if;
            PA_BILLING_SCHEDULE_UTILS.NL_org_sch_Name_To_Id
               ( p_org_id                  => p_nlbr_bill_rate_org_id
                ,p_org_name                => p_nlbr_bill_rate_org
                ,p_check_id_flag           => 'A'
                ,x_org_id                  => l_nlbr_bill_rate_org_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;

         --Validating emp-bill rate schedule id
         IF ( p_emp_bill_rate_sch_id IS NOT NULL AND p_emp_bill_rate_sch_id <> FND_API.G_MISS_NUM ) OR
            ( p_emp_bill_rate_sch_name IS NOT NULL AND p_emp_bill_rate_sch_name <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Emp bill rate schedule id');
            end if;
            PA_BILLING_SCHEDULE_UTILS.Emp_bill_rate_sch_name_To_Id
               ( p_emp_bill_rate_id        => p_emp_bill_rate_sch_id
                ,p_emp_bill_rate_name      => p_emp_bill_rate_sch_name
                ,p_check_id_flag           => 'A'
                ,x_emp_bill_rate_id        => l_emp_bill_rate_sch_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;


         --Validating job-bill rate schedule id
         IF ( p_job_bill_rate_sch_id IS NOT NULL AND p_job_bill_rate_sch_id <> FND_API.G_MISS_NUM ) OR
            ( p_job_bill_rate_sch_name IS NOT NULL AND p_job_bill_rate_sch_name <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Job bill rate schedule id');
            end if;

/*            --Derive bill_job_group_id from pa_projects_prm_v using project-task id.
            SELECT bill_job_group_id
                            INTO l_job_group_id
              FROM pa_projects_prm_v
             WHERE project_id = p_project_id;
               --AND task_id = decode( p_task_id, FND_API.G_MISS_NUM, p_task_id );*/

             l_job_group_id := PA_BILLING_SCHEDULE_UTILS.Get_Job_Group_Id(
                                              p_project_id,
                                              l_return_status );

            PA_BILLING_SCHEDULE_UTILS.Job_bill_rate_sch_name_To_Id
               ( p_job_bill_rate_id        => p_job_bill_rate_sch_id
                ,p_job_bill_rate_name      => p_job_bill_rate_sch_name
                ,p_job_group_id            => l_job_group_id
                ,p_check_id_flag           => 'A'
                ,x_job_bill_rate_id        => l_job_bill_rate_sch_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;

         --Validating Schedule
         IF ( p_nlbr_std_bill_rate_sch IS NOT NULL AND p_nlbr_std_bill_rate_sch <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking  schedule ');
            end if;
            PA_BILLING_SCHEDULE_UTILS.Nlbr_schedule_name_To_Id
               ( p_sch_name                => p_nlbr_std_bill_rate_sch
                ,p_nlbr_org_id             => l_nlbr_bill_rate_org_id
                ,p_check_id_flag           => 'A'
                ,x_sch_name                => l_nlbr_std_bill_rate_sch
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;
      ELSIF p_lbr_schedule_type = 'B' AND p_non_lbr_schedule_type= 'I'
      THEN
         l_nlbr_bill_rate_org_id := null;
         l_nlbr_std_bill_rate_sch := null;
         l_nlbr_sch_fxd_date := null;
         l_nlbr_sch_discount := null;

         l_rev_schedule_id := p_rev_schedule_id;
         l_inv_schedule_id := p_inv_schedule_id;
         l_rev_ind_sch_fxd_date := p_rev_ind_sch_fxd_date;
         l_inv_ind_sch_fxd_date := p_inv_ind_sch_fxd_date;


         l_emp_bill_rate_sch_id := p_emp_bill_rate_sch_id;
         l_lbr_sch_fxd_date := p_lbr_sch_fxd_date;
         l_lbr_sch_discount := p_lbr_sch_discount;
         l_job_bill_rate_sch_id := p_job_bill_rate_sch_id;


         --Validating emp-bill rate schedule id
         IF ( p_emp_bill_rate_sch_id IS NOT NULL AND p_emp_bill_rate_sch_id <> FND_API.G_MISS_NUM ) OR
            ( p_emp_bill_rate_sch_name IS NOT NULL AND p_emp_bill_rate_sch_name <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Emp bill rate schedule id');
            end if;
            PA_BILLING_SCHEDULE_UTILS.Emp_bill_rate_sch_name_To_Id
               ( p_emp_bill_rate_id        => p_emp_bill_rate_sch_id
                ,p_emp_bill_rate_name      => p_emp_bill_rate_sch_name
                ,p_check_id_flag           => 'A'
                ,x_emp_bill_rate_id        => l_emp_bill_rate_sch_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;


         --Validating job-bill rate schedule id
         IF ( p_job_bill_rate_sch_id IS NOT NULL AND p_job_bill_rate_sch_id <> FND_API.G_MISS_NUM ) OR
            ( p_job_bill_rate_sch_name IS NOT NULL AND p_job_bill_rate_sch_name <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Job bill rate schedule id');
            end if;

             l_job_group_id := PA_BILLING_SCHEDULE_UTILS.Get_Job_Group_Id(
                                              p_project_id,
                                              l_return_status );

            PA_BILLING_SCHEDULE_UTILS.Job_bill_rate_sch_name_To_Id
               ( p_job_bill_rate_id        => p_job_bill_rate_sch_id
                ,p_job_bill_rate_name      => p_job_bill_rate_sch_name
                ,p_job_group_id            => l_job_group_id
                ,p_check_id_flag           => 'A'
                ,x_job_bill_rate_id        => l_job_bill_rate_sch_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;


         --Validating rev schedule id
         IF ( p_rev_schedule_id IS NOT NULL AND p_rev_schedule_id <> FND_API.G_MISS_NUM ) OR
            ( p_rev_schedule IS NOT NULL AND p_rev_schedule <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Revenue schedule');
            end if;
            PA_BILLING_SCHEDULE_UTILS.Rev_Sch_Name_To_Id
               ( p_rev_sch_id              => p_rev_schedule_id
                ,p_rev_sch_name            => p_rev_schedule
                ,p_check_id_flag           => 'A'
                ,x_rev_sch_id              => l_rev_schedule_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;

         --Validating Inv schedule id
         IF ( p_inv_schedule_id IS NOT NULL AND p_inv_schedule_id <> FND_API.G_MISS_NUM ) OR
            ( p_inv_schedule IS NOT NULL AND p_inv_schedule <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Invoice schedule');
            end if;
            PA_BILLING_SCHEDULE_UTILS.Inv_Sch_Name_To_Id
               ( p_inv_sch_id              => p_inv_schedule_id
                ,p_inv_sch_name            => p_inv_schedule
                ,p_check_id_flag           => 'A'
                ,x_inv_sch_id              => l_inv_schedule_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;
      ELSIF p_lbr_schedule_type = 'I' AND p_non_lbr_schedule_type= 'B'
      THEN
         l_nlbr_bill_rate_org_id := p_nlbr_bill_rate_org_id;
         l_nlbr_std_bill_rate_sch := p_nlbr_std_bill_rate_sch;
         l_nlbr_sch_fxd_date := p_nlbr_sch_fxd_date;
         l_nlbr_sch_discount := p_nlbr_sch_discount;

         l_rev_schedule_id := p_rev_schedule_id;
         l_inv_schedule_id := p_inv_schedule_id;
         l_rev_ind_sch_fxd_date := p_rev_ind_sch_fxd_date;
         l_inv_ind_sch_fxd_date := p_inv_ind_sch_fxd_date;


         l_emp_bill_rate_sch_id := null;
         l_lbr_sch_fxd_date := null;
         l_lbr_sch_discount := null;
         l_job_bill_rate_sch_id := null;

         --Validating rev schedule id
         IF ( p_rev_schedule_id IS NOT NULL AND p_rev_schedule_id <> FND_API.G_MISS_NUM ) OR
            ( p_rev_schedule IS NOT NULL AND p_rev_schedule <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Revenue schedule');
            end if;
            PA_BILLING_SCHEDULE_UTILS.Rev_Sch_Name_To_Id
               ( p_rev_sch_id              => p_rev_schedule_id
                ,p_rev_sch_name            => p_rev_schedule
                ,p_check_id_flag           => 'A'
                ,x_rev_sch_id              => l_rev_schedule_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;

         --Validating Inv schedule id
         IF ( p_inv_schedule_id IS NOT NULL AND p_inv_schedule_id <> FND_API.G_MISS_NUM ) OR
            ( p_inv_schedule IS NOT NULL AND p_inv_schedule <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Invoice schedule');
            end if;
            PA_BILLING_SCHEDULE_UTILS.Inv_Sch_Name_To_Id
               ( p_inv_sch_id              => p_inv_schedule_id
                ,p_inv_sch_name            => p_inv_schedule
                ,p_check_id_flag           => 'A'
                ,x_inv_sch_id              => l_inv_schedule_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;

         --validating organization
         IF ( p_nlbr_bill_rate_org_id IS NOT NULL AND p_nlbr_bill_rate_org_id <> FND_API.G_MISS_NUM ) OR
            ( p_nlbr_bill_rate_org IS NOT NULL AND p_nlbr_bill_rate_org <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Carrying out organization');
            end if;
            PA_BILLING_SCHEDULE_UTILS.NL_org_sch_Name_To_Id
               ( p_org_id                  => p_nlbr_bill_rate_org_id
                ,p_org_name                => p_nlbr_bill_rate_org
                ,p_check_id_flag           => 'A'
                ,x_org_id                  => l_nlbr_bill_rate_org_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;

         --Validating Schedule
         IF ( p_nlbr_std_bill_rate_sch IS NOT NULL AND p_nlbr_std_bill_rate_sch <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking  schedule ');
            end if;
            PA_BILLING_SCHEDULE_UTILS.Nlbr_schedule_name_To_Id
               ( p_sch_name                => p_nlbr_std_bill_rate_sch
                ,p_nlbr_org_id             => l_nlbr_bill_rate_org_id
                ,p_check_id_flag           => 'A'
                ,x_sch_name                => l_nlbr_std_bill_rate_sch
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;
      ELSE
          l_nlbr_bill_rate_org_id := null;
          l_nlbr_std_bill_rate_sch := null;
          l_nlbr_sch_fxd_date := null;
          l_nlbr_sch_discount := null;
          l_emp_bill_rate_sch_id := null;
          l_lbr_sch_fxd_date := null;
          l_lbr_sch_discount := null;
          l_job_bill_rate_sch_id := null;

          l_rev_schedule_id := p_rev_schedule_id;
          l_inv_schedule_id := p_inv_schedule_id;
          l_rev_ind_sch_fxd_date := p_rev_ind_sch_fxd_date;
          l_inv_ind_sch_fxd_date := p_inv_ind_sch_fxd_date;


         --Validating rev schedule id
         IF ( p_rev_schedule_id IS NOT NULL AND p_rev_schedule_id <> FND_API.G_MISS_NUM ) OR
            ( p_rev_schedule IS NOT NULL AND p_rev_schedule <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Revenue schedule');
            end if;
            PA_BILLING_SCHEDULE_UTILS.Rev_Sch_Name_To_Id
               ( p_rev_sch_id              => p_rev_schedule_id
                ,p_rev_sch_name            => p_rev_schedule
                ,p_check_id_flag           => 'A'
                ,x_rev_sch_id              => l_rev_schedule_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;

         --Validating Inv schedule id
         IF ( p_inv_schedule_id IS NOT NULL AND p_inv_schedule_id <> FND_API.G_MISS_NUM ) OR
            ( p_inv_schedule IS NOT NULL AND p_inv_schedule <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('Update Billing Info PUB : Checking Invoice schedule');
            end if;
            PA_BILLING_SCHEDULE_UTILS.Inv_Sch_Name_To_Id
               ( p_inv_sch_id              => p_inv_schedule_id
                ,p_inv_sch_name            => p_inv_schedule
                ,p_check_id_flag           => 'A'
                ,x_inv_sch_id              => l_inv_schedule_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
            END IF;
         END IF;
      END IF;

         if (p_debug_mode = 'Y') then
            pa_debug.debug('Update Bill Info PUB : checking message count');
         end if;

         l_msg_count := FND_MSG_PUB.count_msg;
         If l_msg_count > 0 THEN
             x_msg_count := l_msg_count;
             If l_msg_count = 1 THEN
                pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE ,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count ,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out );
                    x_msg_data := l_data;
            End if;
            RAISE  FND_API.G_EXC_ERROR;
         End if;

         if (p_debug_mode = 'Y') then
            pa_debug.debug('Update Bill Info PUB : Calling private api Update Bill Info');
         end if;

         PA_BILLING_SCHEDULE_PVT.Update_Project_Task_Bill_Info(
                p_commit                           => FND_API.G_FALSE,
                p_validate_only                    => p_validate_only,
                p_validation_level	               => p_validation_level,
                p_calling_module	               => p_calling_module,
                p_debug_mode	                     => p_debug_mode,
                p_max_msg_count                    => p_max_msg_count,
                p_project_id                       => p_project_id,
                p_task_id                          => p_task_id,
                p_lbr_schedule_type	 	         => p_lbr_schedule_type,
                p_non_lbr_schedule_type 	         => p_non_lbr_schedule_type,
                p_emp_bill_rate_sch_id             => l_emp_bill_rate_sch_id,
                p_job_bill_rate_sch_id             => l_job_bill_rate_sch_id,
                p_lbr_sch_fxd_date	               => l_lbr_sch_fxd_date,
                p_lbr_sch_discount	               => l_lbr_sch_discount,
                p_rev_schedule_id	               => l_rev_schedule_id,
                p_inv_schedule_id                  => l_inv_schedule_id,
                p_rev_ind_sch_fxd_date             => l_rev_ind_sch_fxd_date,
                p_inv_ind_sch_fxd_date 	         => l_inv_ind_sch_fxd_date,
                p_nlbr_bill_rate_org_id	         => l_nlbr_bill_rate_org_id,
                p_nlbr_std_bill_rate_sch	         => l_nlbr_std_bill_rate_sch,
                p_nlbr_sch_fxd_date	               => l_nlbr_sch_fxd_date,
                p_nlbr_sch_discount	               => l_nlbr_sch_discount,
                p_record_version_number	         => p_record_version_number,
                x_return_status	               => l_return_status,
                x_msg_count	                     => l_msg_count,
                x_msg_data	                     => l_msg_data
            );

         if (p_debug_mode = 'Y') then
            pa_debug.debug('Update Bill Info PUB : checking message count');
         end if;

         l_msg_count := FND_MSG_PUB.count_msg;
         If l_msg_count > 0 THEN
             x_msg_count := l_msg_count;
             If l_msg_count = 1 THEN
                pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE ,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count ,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out );
                    x_msg_data := l_data;
            End if;
            RAISE  FND_API.G_EXC_ERROR;
         End if;
   END IF;
   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;
 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Update_Bill_Info;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PUB',
                               p_procedure_name => 'Update_Project_Task_Bill_Info',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Update_Bill_Info;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Update_Bill_Info;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PUB',
                               p_procedure_name => 'Update_Project_Task_Bill_Info',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));

       RAISE;
END Update_Project_Task_Bill_Info;


-- API name                      : update_billing_schedule_type
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	       	 IN	 NUMBER     REQUIRED   DEFAULT=1.0
-- p_init_msg_list	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_commit	         	       IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_lbr_schedule_type   IN    VARCHAR2       REQUIRED,
-- p_non_lbr_schedule_type   IN    VARCHAR2   REQUIRED,
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	         OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	                 OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	                 OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--
 PROCEDURE  update_billing_schedule_type(
 p_api_version	                 IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER     ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_lbr_schedule_type   IN    VARCHAR2,
 p_non_lbr_schedule_type   IN    VARCHAR2,
 p_record_version_number         IN	 NUMBER     DEFAULT 1,
 x_return_status	         OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	                 OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_data	                 OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
)IS

  l_api_name                CONSTANT VARCHAR(30) := 'update_billing_schedule_type';
  l_api_version             CONSTANT NUMBER      := 1.0;

  l_return_status                    VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_msg_data                   VARCHAR2(250);
  l_dummy_char                       VARCHAR2(1);
  l_msg_count                        NUMBER;

  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;
  l_task_id                          NUMBER;
  l_effective_to_date                DATE;
BEGIN
   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('update_billing_schedule_type PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT bill_sch_type;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('update_billing_schedule_type PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SCHEDULE_PUB.UPDATE_LABOR_MULTIPLIER');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := 'S';

    IF p_validate_only = FND_API.G_TRUE AND
       p_validation_level > 0
    THEN
        IF p_task_id = FND_API.G_MISS_NUM
        THEN
           l_task_id := null;
        ELSE
           l_task_id := p_task_id;
        END IF;

        PA_BILLING_SCHEDULE_PVT.update_billing_schedule_type(
                                        p_commit	        => FND_API.G_FALSE,
                                        p_validate_only       => p_validate_only,
                                        p_validation_level	  => p_validation_level,
                                        p_calling_module	  => p_calling_module,
                                        p_debug_mode	        => p_debug_mode,
                                        p_max_msg_count	  => p_max_msg_count,
                                        p_project_id	        => p_project_id,
                                        p_task_id	        => l_task_id,
                                        p_lbr_schedule_type => p_lbr_schedule_type,
                                        p_non_lbr_schedule_type   => p_non_lbr_schedule_type,
                                        p_record_version_number   => p_record_version_number,
                                        x_return_status	  => l_return_status,
                                        x_msg_count	        => l_msg_count,
                                        x_msg_data	        => l_msg_data
                                  );
    END IF;

    if (p_debug_mode = 'Y') then
        pa_debug.debug('update_billing_schedule_type PUB : checking message count');
    end if;
    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       If l_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE ,
               p_msg_index      => 1,
               p_msg_count      => l_msg_count ,
               p_msg_data       => l_msg_data,
               p_data           => l_data,
               p_msg_index_out  => l_msg_index_out );
               x_msg_data := l_data;
       End if;
       RAISE  FND_API.G_EXC_ERROR;
    End if;

   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO bill_sch_type;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PUB',
                               p_procedure_name => 'update_billing_schedule_type',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO bill_sch_type;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO bill_sch_type;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PUB',
                               p_procedure_name => 'update_billing_schedule_type',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END update_billing_schedule_type;



-- API name                      : create_labor_multiplier
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	       	 IN	 NUMBER     REQUIRED   DEFAULT=1.0
-- p_init_msg_list	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_commit	         	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	         IN	 NUMBER	OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier	         IN	 NUMBER	REQUIRED
-- p_effective_from_date	 IN	 DATE	      REQUIRED
-- p_effective_to_date	         IN	 DATE	      OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- x_labor_multiplier_id         OUT   NUMBER   REQUIRED
-- x_return_status	         OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	                 OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	                 OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--
 PROCEDURE  Create_Labor_Multiplier(
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER     ,
 p_task_id	         	 IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier	 IN	 NUMBER	,
 p_effective_from_date	 IN	 DATE	      ,
 p_effective_to_date	 IN	 DATE	      DEFAULT FND_API.G_MISS_DATE,
 x_labor_multiplier_id   OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status	       OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	       OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_data	             OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
) IS

  l_api_name                CONSTANT VARCHAR(30) := 'Update_Project_Task_Bill_Info';
  l_api_version             CONSTANT NUMBER      := 1.0;

  l_return_status                    VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_msg_data                   VARCHAR2(250);
  l_dummy_char                       VARCHAR2(1);
  l_msg_count                        NUMBER;

  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;

  l_task_id                          NUMBER;
  l_effective_to_date                DATE;

BEGIN
   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('Update Bill Info PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT prm_create_project;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update Bill Info PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SCHEDULE_PUB.CREATE_LABOR_MULTIPLIER');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := 'S';

    IF p_validate_only = FND_API.G_TRUE AND
       p_validation_level > 0
    THEN
        IF p_task_id = FND_API.G_MISS_NUM
        THEN
           l_task_id := null;
        ELSE
           l_task_id := p_task_id;
        END IF;

        IF p_effective_to_date = FND_API.G_MISS_DATE
        THEN
           l_effective_to_date := null;
        ELSE
           l_effective_to_date := p_effective_to_date;
        END IF;

        PA_BILLING_SCHEDULE_PVT.Create_Labor_Multiplier(
                                        p_commit	        => FND_API.G_FALSE,
                                        p_validate_only       => p_validate_only,
                                        p_validation_level	  => p_validation_level,
                                        p_calling_module	  => p_calling_module,
                                        p_debug_mode	        => p_debug_mode,
                                        p_max_msg_count	  => p_max_msg_count,
                                        p_project_id	        => p_project_id,
                                        p_task_id	        => l_task_id,
                                        p_labor_multiplier	  => p_labor_multiplier,
                                        p_effective_from_date => p_effective_from_date,
                                        p_effective_to_date	  => l_effective_to_date,
                                        x_labor_multiplier_id => x_labor_multiplier_id,
                                        x_return_status	  => l_return_status,
                                        x_msg_count	        => l_msg_count,
                                        x_msg_data	        => l_msg_data
                                  );
    END IF;

    if (p_debug_mode = 'Y') then
        pa_debug.debug('Update Bill Info PUB : checking message count');
    end if;
    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       If l_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE ,
               p_msg_index      => 1,
               p_msg_count      => l_msg_count ,
               p_msg_data       => l_msg_data,
               p_data           => l_data,
               p_msg_index_out  => l_msg_index_out );
               x_msg_data := l_data;
       End if;
       RAISE  FND_API.G_EXC_ERROR;
    End if;
    IF FND_API.TO_BOOLEAN(P_COMMIT)
    THEN
       COMMIT WORK;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_labor_multiplier_id := NULL; -- NOCOPY
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PUB',
                               p_procedure_name => 'create_labor_multiplier',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       x_labor_multiplier_id := NULL; -- NOCOPY
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       x_labor_multiplier_id := NULL; -- NOCOPY
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PUB',
                               p_procedure_name => 'create_labor_multiplier',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END Create_Labor_Multiplier;

-- API name                      : update_labor_multiplier
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	       	 IN	 NUMBER     REQUIRED   DEFAULT=1.0
-- p_init_msg_list	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_commit	         	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier_id       IN    NUMBER     REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier	         IN	 NUMBER
-- p_effective_from_date	 IN	 DATE	      REQUIRED
-- p_effective_to_date	         IN	 DATE	      OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	         OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	                 OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	                 OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--
 PROCEDURE  Update_Labor_Multiplier(
 p_api_version	                 IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	         IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	                 IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier_id       IN    NUMBER,
 p_project_id	                 IN	 NUMBER     ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier	         IN	 NUMBER	,
 p_effective_from_date	         IN	 DATE	      ,
 p_effective_to_date	         IN	 DATE	      DEFAULT FND_API.G_MISS_DATE,
 p_record_version_number         IN	 NUMBER     DEFAULT 1,
 x_return_status	         OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	                 OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_data	                 OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
)IS

  l_api_name                CONSTANT VARCHAR(30) := 'Update_Project_Task_Bill_Info';
  l_api_version             CONSTANT NUMBER      := 1.0;

  l_return_status                    VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_msg_data                   VARCHAR2(250);
  l_dummy_char                       VARCHAR2(1);
  l_msg_count                        NUMBER;

  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;
  l_task_id                          NUMBER;
  l_effective_to_date                DATE;
BEGIN
   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('Update Bill Info PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT prm_create_project;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update Bill Info PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SCHEDULE_PUB.UPDATE_LABOR_MULTIPLIER');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := 'S';

    IF p_validate_only = FND_API.G_TRUE AND
       p_validation_level > 0
    THEN
        IF p_task_id = FND_API.G_MISS_NUM
        THEN
           l_task_id := null;
        ELSE
           l_task_id := p_task_id;
        END IF;

        IF p_effective_to_date = FND_API.G_MISS_DATE
        THEN
           l_effective_to_date := null;
        ELSE
           l_effective_to_date := p_effective_to_date;
        END IF;

        PA_BILLING_SCHEDULE_PVT.Update_Labor_Multiplier(
                                        p_commit	        => FND_API.G_FALSE,
                                        p_validate_only       => p_validate_only,
                                        p_validation_level	  => p_validation_level,
                                        p_calling_module	  => p_calling_module,
                                        p_debug_mode	        => p_debug_mode,
                                        p_max_msg_count	  => p_max_msg_count,
                                        p_labor_multiplier_id => p_labor_multiplier_id,
                                        p_project_id	        => p_project_id,
                                        p_task_id	        => l_task_id,
                                        p_labor_multiplier	  => p_labor_multiplier,
                                        p_effective_from_date => p_effective_from_date,
                                        p_effective_to_date	  => l_effective_to_date,
                                        p_record_version_number   => p_record_version_number,
                                        x_return_status	  => l_return_status,
                                        x_msg_count	        => l_msg_count,
                                        x_msg_data	        => l_msg_data
                                  );
    END IF;

    if (p_debug_mode = 'Y') then
        pa_debug.debug('Update Bill Info PUB : checking message count');
    end if;
    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       If l_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE ,
               p_msg_index      => 1,
               p_msg_count      => l_msg_count ,
               p_msg_data       => l_msg_data,
               p_data           => l_data,
               p_msg_index_out  => l_msg_index_out );
               x_msg_data := l_data;
       End if;
       RAISE  FND_API.G_EXC_ERROR;
    End if;

   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PUB',
                               p_procedure_name => 'update_labor_multiplier',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PUB',
                               p_procedure_name => 'update_labor_multiplier',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END Update_Labor_Multiplier;

-- API name                      : delete_labor_multiplier
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version	       	 IN	 NUMBER     REQUIRED   DEFAULT=1.0
-- p_init_msg_list	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_commit	         	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier_id       IN    NUMBER     REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier	         IN	 NUMBER
-- p_effective_from_date	 IN	 DATE	      REQUIRED
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	         OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	                 OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	                 OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--
 PROCEDURE  delete_Labor_Multiplier(
 p_api_version	                 IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	         IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	                 IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier_id       IN    NUMBER,
 p_project_id	                 IN	 NUMBER     ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier	         IN	 NUMBER	,
 p_effective_from_date	         IN	 DATE	      ,
 p_record_version_number         IN	 NUMBER     DEFAULT 1,
 x_return_status	         OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	                 OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_data	                 OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
)IS

  l_api_name                CONSTANT VARCHAR(30) := 'delete_labor_multiplier';
  l_api_version             CONSTANT NUMBER      := 1.0;

  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;
  l_return_status                    VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_msg_data                   VARCHAR2(250);
  l_dummy_char                       VARCHAR2(1);
  l_msg_count                        NUMBER;
  l_task_id                          NUMBER;
BEGIN
   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('Update Bill Info PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT prm_create_project;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update Bill Info PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SCHEDULE_PUB.DELETE_LABOR_MULTIPLIER');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := 'S';

    IF p_validate_only = FND_API.G_TRUE AND
       p_validation_level > 0
    THEN
        IF p_task_id = FND_API.G_MISS_NUM
        THEN
           l_task_id := null;
        ELSE
           l_task_id := p_task_id;
        END IF;

        PA_BILLING_SCHEDULE_PVT.Delete_Labor_Multiplier(
                                        p_commit	        => FND_API.G_FALSE,
                                        p_validate_only       => p_validate_only,
                                        p_validation_level	  => p_validation_level,
                                        p_calling_module	  => p_calling_module,
                                        P_labor_multiplier       => p_labor_multiplier,
                                        p_debug_mode	        => p_debug_mode,
                                        p_max_msg_count	  => p_max_msg_count,
                                        p_labor_multiplier_id => p_labor_multiplier_id,
                                        p_project_id	        => p_project_id,
                                        p_task_id	        => l_task_id,
                                        p_effective_from_date => p_effective_from_date,
                                        p_record_version_number => p_record_version_number,
                                        x_return_status	  => l_return_status,
                                        x_msg_count	        => l_msg_count,
                                        x_msg_data	        => l_msg_data
                                  );
    END IF;

    if (p_debug_mode = 'Y') then
        pa_debug.debug('Update Bill Info PUB : checking message count');
    end if;
    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       If l_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE ,
               p_msg_index      => 1,
               p_msg_count      => l_msg_count ,
               p_msg_data       => l_msg_data,
               p_data           => l_data,
               p_msg_index_out  => l_msg_index_out );
               x_msg_data := l_data;
       End if;
       RAISE  FND_API.G_EXC_ERROR;
    End if;

    IF FND_API.TO_BOOLEAN(P_COMMIT)
    THEN
       COMMIT WORK;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PUB',
                               p_procedure_name => 'Delete_labor_multiplier',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PUB',
                               p_procedure_name => 'delete_labor_multiplier',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END Delete_Labor_Multiplier;


END PA_BILLING_SCHEDULE_PUB;

/
