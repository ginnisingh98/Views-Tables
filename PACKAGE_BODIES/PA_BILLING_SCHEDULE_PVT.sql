--------------------------------------------------------
--  DDL for Package Body PA_BILLING_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_SCHEDULE_PVT" AS
/* $Header: PABLINVB.pls 120.3 2005/08/19 16:16:35 mwasowic noship $ */

   G_PKG_NAME       VARCHAR2(30) := 'PA_BILLING_SCHEDULE_PVT';

-- API name                      : Update_Project_Task_Bill_Info
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit	       	       IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_lbr_schedule_type	 	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_non_lbr_schedule_type	 IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_emp_bill_rate_sch_id 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_job_bill_rate_sch_id   	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_lbr_sch_fxd_date	 	 IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_lbr_sch_discount	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_rev_schedule_id	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_inv_schedule_id	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_rev_ind_sch_fxd_date	 IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_inv_ind_sch_fxd_date 	 IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_nlbr_bill_rate_org_id	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_nlbr_std_bill_rate_sch      IN	 VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_nlbr_sch_fxd_date	       IN	 DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_nlbr_sch_discount	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Update_Project_Task_Bill_Info(
 p_commit	         	         IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	         IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	         IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	         IN  VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	               IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	         IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	               IN	 NUMBER    ,
 p_task_id	         	         IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_lbr_schedule_type	 	   IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_non_lbr_schedule_type 	   IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_emp_bill_rate_sch_id          IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_job_bill_rate_sch_id          IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_lbr_sch_fxd_date	         IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
 p_lbr_sch_discount	         IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_rev_schedule_id	         IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_inv_schedule_id	 	   IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_rev_ind_sch_fxd_date	 	   IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
 p_inv_ind_sch_fxd_date 	   IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
 p_nlbr_bill_rate_org_id	   IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_nlbr_std_bill_rate_sch	   IN	 VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_nlbr_sch_fxd_date	         IN	 DATE       DEFAULT FND_API.G_MISS_DATE,
 p_nlbr_sch_discount	 	   IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_record_version_number	   IN	 NUMBER     DEFAULT 1,
 x_return_status	               OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	               OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                     OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

    l_return_status            VARCHAR2(1);
    l_error_msg_code           VARCHAR2(250);
    l_dummy_char               VARCHAR2(1);
    l_msg_count                NUMBER;


    l_task_id	         	   NUMBER;
    l_lbr_schedule_type	 	   VARCHAR2(1);
    l_non_lbr_schedule_type 	   VARCHAR2(1);
    l_emp_bill_rate_sch_id       NUMBER;
    l_job_bill_rate_sch_id       NUMBER;
    l_lbr_sch_fxd_date	         DATE;
    l_lbr_sch_discount	         NUMBER;
    l_rev_schedule_id	         NUMBER;
    l_inv_schedule_id	 	   NUMBER;
    l_rev_ind_sch_fxd_date	   DATE;
    l_inv_ind_sch_fxd_date 	   DATE;
    l_nlbr_bill_rate_org_id	   NUMBER;
    l_nlbr_std_bill_rate_sch       VARCHAR2(30);
    l_nlbr_sch_fxd_date	         DATE;
    l_nlbr_sch_discount	 	   NUMBER;
    l_project_type_class_code    PA_PROJECT_TYPES.PROJECT_TYPE_CLASS_CODE%TYPE;

 BEGIN

    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT Update_Bill_Info;
    END IF;

    x_return_status := 'S';

    IF p_validate_only = FND_API.G_TRUE AND
       p_validation_level > 0
    THEN

       IF (p_debug_mode = 'Y')
       THEN
           pa_debug.debug('Update_Project_Task_Bill_Info PVT: Checking PRM installation');
       END IF;

       --this functionality is moved to a utility procedure. PA_BILLING_SCHEDULES.CHECK_BILL_INFO_REQ
       /*PA_BILLING_SCHEDULE_UTILS.Emp_job_mandatory_validation(
                                  p_emp_bill_rate_sch_id,
                                  p_job_bill_rate_sch_id,
                                  l_return_status,
                                  l_error_msg_code );*/

        --Get the project type class code and pass to procedure to validate mandaory columns
        l_project_type_class_code := PA_BILLING_SCHEDULE_UTILS.Get_Project_Type_Class(
                                       p_project_id,
                                       l_return_status );

        PA_BILLING_SCHEDULE_UTILS.CHECK_BILL_INFO_REQ(
                   p_project_type_class_code       => l_project_type_class_code,
                   p_lbr_schedule_type             => p_lbr_schedule_type,
                   p_non_lbr_schedule_type         => p_non_lbr_schedule_type,
                   p_emp_bill_rate_sch_id          => p_emp_bill_rate_sch_id,
                   p_job_bill_rate_sch_id          => p_job_bill_rate_sch_id,
                   p_rev_schedule_id               => p_rev_schedule_id,
                   p_inv_schedule_id               => p_inv_schedule_id,
                   p_nlbr_bill_rate_org_id         => p_nlbr_bill_rate_org_id,
                   p_nlbr_std_bill_rate_sch        => p_nlbr_std_bill_rate_sch,
                   x_error_msg_code                => l_error_msg_code,
                   x_return_status                 => l_return_status  );

        IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_error_msg_code);

            x_msg_data := l_error_msg_code;
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    IF (p_debug_mode = 'Y')
    THEN
         pa_debug.debug('Update_Project_Task_Bill_Info PVT: Checking Lock on record');
    END IF;

    IF p_validate_only <> FND_API.G_TRUE
    THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_projects
           WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number
           FOR UPDATE OF record_version_number NOWAIT;
        EXCEPTION
           WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
               IF SQLCODE = -54 THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                  x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                  x_return_status := 'E' ;
               ELSE
                  raise;
               END IF;
        END;
      ELSE
         BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_projects
           WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              END IF;
          END;
      end if;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

    IF p_validate_only = FND_API.G_TRUE AND
       p_validation_level > 0
    THEN
        IF p_task_id = FND_API.G_MISS_NUM
        THEN
           l_task_id := null;
        ELSE
           l_task_id := p_task_id;
        END IF;

        IF p_lbr_schedule_type = FND_API.G_MISS_CHAR
        THEN
           l_lbr_schedule_type := null;
        ELSE
           l_lbr_schedule_type := p_lbr_schedule_type;
        END IF;

        IF  p_non_lbr_schedule_type = FND_API.G_MISS_CHAR
        THEN
            l_non_lbr_schedule_type := null;
        ELSE
            l_non_lbr_schedule_type := p_non_lbr_schedule_type;
        END IF;

        IF p_emp_bill_rate_sch_id = FND_API.G_MISS_NUM
        THEN
           l_emp_bill_rate_sch_id := null;
        ELSE
           l_emp_bill_rate_sch_id := p_emp_bill_rate_sch_id;
        END IF;

        IF p_job_bill_rate_sch_id = FND_API.G_MISS_NUM
        THEN
           l_job_bill_rate_sch_id := null;
        ELSE
           l_job_bill_rate_sch_id := p_job_bill_rate_sch_id;
        END IF;

        IF p_lbr_sch_fxd_date = FND_API.G_MISS_DATE
        THEN
           l_lbr_sch_fxd_date := null;
        ELSE
           l_lbr_sch_fxd_date := p_lbr_sch_fxd_date;
        END IF;

        IF p_lbr_sch_discount = FND_API.G_MISS_NUM
        THEN
           l_lbr_sch_discount := null;
        ELSE
           l_lbr_sch_discount := p_lbr_sch_discount;
        END IF;

        IF p_rev_schedule_id = FND_API.G_MISS_NUM
        THEN
           l_rev_schedule_id := null;
        ELSE
           l_rev_schedule_id := p_rev_schedule_id;
        END IF;

        IF p_inv_schedule_id = FND_API.G_MISS_NUM
        THEN
           l_inv_schedule_id := null;
        ELSE
           l_inv_schedule_id := p_inv_schedule_id;
        END IF;

        IF p_rev_ind_sch_fxd_date = FND_API.G_MISS_DATE
        THEN
           l_rev_ind_sch_fxd_date := null;
        ELSE
           l_rev_ind_sch_fxd_date := p_rev_ind_sch_fxd_date;
        END IF;

        IF p_inv_ind_sch_fxd_date = FND_API.G_MISS_DATE
        THEN
           l_inv_ind_sch_fxd_date := null;
        ELSE
           l_inv_ind_sch_fxd_date := p_inv_ind_sch_fxd_date;
        END IF;

        IF p_nlbr_bill_rate_org_id = FND_API.G_MISS_NUM
        THEN
           l_nlbr_bill_rate_org_id := null;
        ELSE
           l_nlbr_bill_rate_org_id := p_nlbr_bill_rate_org_id;
        END IF;

        IF p_nlbr_std_bill_rate_sch = FND_API.G_MISS_CHAR
        THEN
           l_nlbr_std_bill_rate_sch := null;
        ELSE
           l_nlbr_std_bill_rate_sch := p_nlbr_std_bill_rate_sch;
        END IF;

        IF p_nlbr_sch_fxd_date = FND_API.G_MISS_DATE
        THEN
           l_nlbr_sch_fxd_date := null;
        ELSE
           l_nlbr_sch_fxd_date := p_nlbr_sch_fxd_date;
        END IF;

        IF p_nlbr_sch_discount = FND_API.G_MISS_NUM
        THEN
           l_nlbr_sch_discount := null;
        ELSE
           l_nlbr_sch_discount := p_nlbr_sch_discount;
        END IF;

        IF p_task_id = FND_API.G_MISS_NUM OR l_task_id is NULL
        THEN
           UPDATE pa_projects
              SET  LABOR_SCH_TYPE                  = l_lbr_schedule_type,
                   NON_LABOR_SCH_TYPE              = l_non_lbr_schedule_type,
                   EMP_BILL_RATE_SCHEDULE_ID       = l_emp_bill_rate_sch_id ,
                   JOB_BILL_RATE_SCHEDULE_ID       = l_job_bill_rate_sch_id ,
                   LABOR_SCHEDULE_FIXED_DATE       = l_lbr_sch_fxd_date,
                   LABOR_SCHEDULE_DISCOUNT         = l_lbr_sch_discount,
                   REV_IND_RATE_SCH_ID             = l_rev_schedule_id,
                   INV_IND_RATE_SCH_ID             = l_inv_schedule_id,
                   REV_IND_SCH_FIXED_DATE          = l_rev_ind_sch_fxd_date,
                   INV_IND_SCH_FIXED_DATE          = l_inv_ind_sch_fxd_date,
                   NON_LABOR_BILL_RATE_ORG_ID      = l_nlbr_bill_rate_org_id,
                   NON_LABOR_STD_BILL_RATE_SCHDL   = l_nlbr_std_bill_rate_sch,
                   NON_LABOR_SCHEDULE_FIXED_DATE   = l_nlbr_sch_fxd_date,
                   NON_LABOR_SCHEDULE_DISCOUNT     = l_nlbr_sch_discount,
                   RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
            WHERE  project_id = p_project_id
              AND  RECORD_VERSION_NUMBER = p_record_version_number;

        ELSE

            --lock pa_tasks table
            IF p_validate_only <> FND_API.G_TRUE
            THEN
               BEGIN
                   SELECT 'x' INTO l_dummy_char
                     FROM  pa_tasks
                    WHERE task_id             = l_task_id
                      AND record_version_number  = p_record_version_number
                    FOR UPDATE OF record_version_number NOWAIT;
               EXCEPTION
                   WHEN TIMEOUT_ON_RESOURCE THEN
                       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                            p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                       x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                       x_return_status := 'E' ;
                   WHEN NO_DATA_FOUND THEN
                       if p_calling_module = 'FORM' then
                          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                               p_msg_name       => 'FORM_RECORD_CHANGED');
                          x_msg_data := 'FORM_RECORD_CHANGED';
                       else
                          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
                          x_msg_data := 'PA_XC_RECORD_CHANGED';
                      end if;
                      x_return_status := 'E' ;
                   WHEN OTHERS THEN
                      IF SQLCODE = -54 THEN
                         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                              p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                         x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                         x_return_status := 'E' ;
                      ELSE
                         raise;
                      END IF;
               END;
            ELSE
                BEGIN
                     SELECT 'x' INTO l_dummy_char
                       FROM  pa_tasks
                      WHERE task_id             = l_task_id
                        AND record_version_number  = p_record_version_number;
                EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                         if p_calling_module = 'FORM' then
                            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                                 p_msg_name       => 'FORM_RECORD_CHANGED');
                            x_msg_data := 'FORM_RECORD_CHANGED';
                        else
                            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
                            x_msg_data := 'PA_XC_RECORD_CHANGED';
                       end if;
                       x_return_status := 'E' ;
                     WHEN OTHERS THEN
                       IF SQLCODE = -54 THEN
                          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                               p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                          x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                          x_return_status := 'E' ;
                       END IF;
                END;
            END IF;
            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;
            UPDATE pa_tasks
               SET  LABOR_SCH_TYPE                  = l_lbr_schedule_type,
                    NON_LABOR_SCH_TYPE              = l_non_lbr_schedule_type,
                    EMP_BILL_RATE_SCHEDULE_ID       = l_emp_bill_rate_sch_id ,
                    JOB_BILL_RATE_SCHEDULE_ID       = l_job_bill_rate_sch_id ,
                    LABOR_SCHEDULE_FIXED_DATE       = l_lbr_sch_fxd_date,
                    LABOR_SCHEDULE_DISCOUNT         = l_lbr_sch_discount,
                    REV_IND_RATE_SCH_ID             = l_rev_schedule_id,
                    INV_IND_RATE_SCH_ID             = l_inv_schedule_id,
                    REV_IND_SCH_FIXED_DATE          = l_rev_ind_sch_fxd_date,
                    INV_IND_SCH_FIXED_DATE          = l_inv_ind_sch_fxd_date,
                    NON_LABOR_BILL_RATE_ORG_ID      = l_nlbr_bill_rate_org_id,
                    NON_LABOR_STD_BILL_RATE_SCHDL   = l_nlbr_std_bill_rate_sch,
                    NON_LABOR_SCHEDULE_FIXED_DATE   = l_nlbr_sch_fxd_date,
                    NON_LABOR_SCHEDULE_DISCOUNT     = l_nlbr_sch_discount,
                    RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
             WHERE  task_id = l_task_id
               AND  RECORD_VERSION_NUMBER = p_record_version_number;
        END IF;

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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PVT',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PVT',
                               p_procedure_name => 'Update_Project_Task_Bill_Info',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
 END Update_Project_Task_Bill_Info;

-- API name                      : update_billing_schedule_type
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit	         	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
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
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	         IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	                 IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	                 IN	 NUMBER     ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_lbr_schedule_type   IN    VARCHAR2       ,
 p_non_lbr_schedule_type   IN    VARCHAR2   ,
 p_record_version_number         IN	 NUMBER     DEFAULT 1,
 x_return_status	         OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	                 OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_data	                 OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
) IS

    l_return_status            VARCHAR2(1);
    l_error_msg_code           VARCHAR2(250);
    l_dummy_char               VARCHAR2(1);
    l_msg_count                NUMBER;

    l_task_id                  NUMBER;
    l_effective_to_date        DATE;
BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT bill_sch_type;
    END IF;

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

    END IF;

    IF (p_debug_mode = 'Y')
    THEN
         pa_debug.debug('update_billing_schedule_type PVT: Checking Lock on record');
    END IF;
    IF( p_task_id = FND_API.G_MISS_NUM OR l_task_id is NULL )
    THEN
      IF p_validate_only <> FND_API.G_TRUE
      THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
             FROM pa_projects
            WHERE project_id             = p_project_id
              AND record_version_number  = p_record_version_number
              FOR UPDATE OF record_version_number NOWAIT;
        EXCEPTION
           WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
               IF SQLCODE = -54 THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                  x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                  x_return_status := 'E' ;
               ELSE
                  raise;
               END IF;
        END;
      ELSE
         BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_projects
           WHERE project_id           = p_project_id
           AND record_version_number  = p_record_version_number;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              END IF;
          END;
      END IF;
    ELSE
      --lock pa_tasks
      IF p_validate_only <> FND_API.G_TRUE
      THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
             FROM pa_tasks
            WHERE task_id             = l_task_id
              AND record_version_number  = p_record_version_number
              FOR UPDATE OF record_version_number NOWAIT;
        EXCEPTION
           WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
               IF SQLCODE = -54 THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                  x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                  x_return_status := 'E' ;
               ELSE
                  raise;
               END IF;
        END;
      ELSE
         BEGIN
           SELECT 'x' INTO l_dummy_char
           FROM  pa_tasks
           WHERE task_id           = l_task_id
           AND record_version_number  = p_record_version_number;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              END IF;
          END;
      END IF;
    END IF;

      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

      IF p_lbr_schedule_type = 'B' and p_non_lbr_schedule_type = 'B'
      THEN
        IF( p_task_id = FND_API.G_MISS_NUM OR l_task_id is NULL )
        THEN
           UPDATE pa_projects
              SET  LABOR_SCH_TYPE                  = p_lbr_schedule_type,
                   NON_LABOR_SCH_TYPE              = p_non_lbr_schedule_type,
                   REV_IND_RATE_SCH_ID             = null,
                   INV_IND_RATE_SCH_ID             = null,
                   REV_IND_SCH_FIXED_DATE          = null,
                   INV_IND_SCH_FIXED_DATE          = null,
                   RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
            WHERE  project_id = p_project_id
              AND  RECORD_VERSION_NUMBER = p_record_version_number;
        ELSE
           UPDATE pa_tasks
              SET  LABOR_SCH_TYPE                  = p_lbr_schedule_type,
                   NON_LABOR_SCH_TYPE              = p_non_lbr_schedule_type,
                   REV_IND_RATE_SCH_ID             = null,
                   INV_IND_RATE_SCH_ID             = null,
                   REV_IND_SCH_FIXED_DATE          = null,
                   INV_IND_SCH_FIXED_DATE          = null,
                   RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
            WHERE  task_id = l_task_id
              AND  RECORD_VERSION_NUMBER = p_record_version_number;
        END IF;
      ELSIF p_lbr_schedule_type = 'B' and p_non_lbr_schedule_type = 'I'
      THEN
        IF( p_task_id = FND_API.G_MISS_NUM OR l_task_id is NULL )
        THEN
           UPDATE pa_projects
              SET  LABOR_SCH_TYPE                  = p_lbr_schedule_type,
                   NON_LABOR_SCH_TYPE              = p_non_lbr_schedule_type,
                   NON_LABOR_BILL_RATE_ORG_ID      = null,
                   NON_LABOR_STD_BILL_RATE_SCHDL   = null,
                   NON_LABOR_SCHEDULE_FIXED_DATE   = null,
                   NON_LABOR_SCHEDULE_DISCOUNT     = null,
                   RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
            WHERE  project_id = p_project_id
              AND  RECORD_VERSION_NUMBER = p_record_version_number;
        ELSE
           UPDATE pa_tasks
              SET  LABOR_SCH_TYPE                  = p_lbr_schedule_type,
                   NON_LABOR_SCH_TYPE              = p_non_lbr_schedule_type,
                   NON_LABOR_BILL_RATE_ORG_ID      = null,
                   NON_LABOR_STD_BILL_RATE_SCHDL   = null,
                   NON_LABOR_SCHEDULE_FIXED_DATE   = null,
                   NON_LABOR_SCHEDULE_DISCOUNT     = null,
                   RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
            WHERE  task_id = l_task_id
              AND  RECORD_VERSION_NUMBER = p_record_version_number;
        END IF;
      ELSIF p_lbr_schedule_type = 'I' and p_non_lbr_schedule_type = 'B'
      THEN
        IF( p_task_id = FND_API.G_MISS_NUM OR l_task_id is NULL )
        THEN
           UPDATE pa_projects
              SET  LABOR_SCH_TYPE                  = p_lbr_schedule_type,
                   NON_LABOR_SCH_TYPE              = p_non_lbr_schedule_type,
                   EMP_BILL_RATE_SCHEDULE_ID       = null,
                   JOB_BILL_RATE_SCHEDULE_ID       = null,
                   LABOR_SCHEDULE_FIXED_DATE       = null,
                   LABOR_SCHEDULE_DISCOUNT         = null,
                   RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
            WHERE  project_id = p_project_id
              AND  RECORD_VERSION_NUMBER = p_record_version_number;
        ELSE
           UPDATE pa_tasks
              SET  LABOR_SCH_TYPE                  = p_lbr_schedule_type,
                   NON_LABOR_SCH_TYPE              = p_non_lbr_schedule_type,
                   EMP_BILL_RATE_SCHEDULE_ID       = null,
                   JOB_BILL_RATE_SCHEDULE_ID       = null,
                   LABOR_SCHEDULE_FIXED_DATE       = null,
                   LABOR_SCHEDULE_DISCOUNT         = null,
                   RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
            WHERE  task_id = l_task_id
              AND  RECORD_VERSION_NUMBER = p_record_version_number;
        END IF;
      ELSIF p_lbr_schedule_type = 'I' and p_non_lbr_schedule_type = 'I'
      THEN
        IF( p_task_id = FND_API.G_MISS_NUM OR l_task_id is NULL )
        THEN
           UPDATE pa_projects
              SET  LABOR_SCH_TYPE                  = p_lbr_schedule_type,
                   NON_LABOR_SCH_TYPE              = p_non_lbr_schedule_type,
                   EMP_BILL_RATE_SCHEDULE_ID       = null,
                   JOB_BILL_RATE_SCHEDULE_ID       = null,
                   LABOR_SCHEDULE_FIXED_DATE       = null,
                   LABOR_SCHEDULE_DISCOUNT         = null,
                   NON_LABOR_BILL_RATE_ORG_ID      = null,
                   NON_LABOR_STD_BILL_RATE_SCHDL   = null,
                   NON_LABOR_SCHEDULE_FIXED_DATE   = null,
                   NON_LABOR_SCHEDULE_DISCOUNT     = null,
                   RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
            WHERE  project_id = p_project_id
              AND  RECORD_VERSION_NUMBER = p_record_version_number;
        ELSE
           UPDATE pa_tasks
              SET  LABOR_SCH_TYPE                  = p_lbr_schedule_type,
                   NON_LABOR_SCH_TYPE              = p_non_lbr_schedule_type,
                   EMP_BILL_RATE_SCHEDULE_ID       = null,
                   JOB_BILL_RATE_SCHEDULE_ID       = null,
                   LABOR_SCHEDULE_FIXED_DATE       = null,
                   LABOR_SCHEDULE_DISCOUNT         = null,
                   NON_LABOR_BILL_RATE_ORG_ID      = null,
                   NON_LABOR_STD_BILL_RATE_SCHDL   = null,
                   NON_LABOR_SCHEDULE_FIXED_DATE   = null,
                   NON_LABOR_SCHEDULE_DISCOUNT     = null,
                   RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
            WHERE  task_id = p_task_id
              AND  RECORD_VERSION_NUMBER = p_record_version_number;
        END IF;
      END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO bill_sch_type;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PVT',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PVT',
                               p_procedure_name => 'update_billing_schedule_type',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END update_billing_schedule_type;

-- API name                      : create_labor_multiplier
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit	         	       IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier	       IN	 NUMBER	    REQUIRED
-- p_effective_from_date	 IN	 DATE	    REQUIRED
-- p_effective_to_date	       IN	 DATE	    OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- x_labor_multiplier_id       OUT    NUMBER  REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--
 PROCEDURE  Create_Labor_Multiplier(
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER     ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier	 IN	 NUMBER	,
 p_effective_from_date	 IN	 DATE	      ,
 p_effective_to_date	 IN	 DATE	      DEFAULT FND_API.G_MISS_DATE,
 x_labor_multiplier_id       OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status	       OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	       OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_data	             OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
) IS

    l_return_status            VARCHAR2(1);
    l_error_msg_code           VARCHAR2(250);
    l_dummy_char               VARCHAR2(1);
    l_msg_count                NUMBER;

    l_task_id                  NUMBER;
    l_effective_to_date        DATE;
    l_labor_multiplier_id      NUMBER;
BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT Labor_Multiplier;
    END IF;

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
    END IF;

    IF p_labor_multiplier < 0
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_PRJ_LB_MULT_GR_ZR' );
       x_msg_count := FND_MSG_PUB.count_msg;
       x_msg_data := 'PA_PRJ_LB_MULT_GR_ZR';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;


    PA_BILLING_SCHEDULE_UTILS.CHECK_START_END_DATE(
                              p_effective_from_date => p_effective_from_date,
                              p_effective_to_date   => l_effective_to_date,
                              x_error_msg_code        => l_error_msg_code,
                              x_return_status         => l_return_status );

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_error_msg_code);
        x_msg_data := l_error_msg_code;
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    PA_BILLING_SCHEDULE_UTILS.CHECK_LABOR_MULTIPLIER_REQ(
                              p_labor_multiplier      => p_labor_multiplier,
                              p_effective_from_date   => p_effective_from_date,
                              x_error_msg_code        => l_error_msg_code,
                              x_return_status         => l_return_status );

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_error_msg_code);
        x_msg_data := l_error_msg_code;
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;


    IF NOT PA_BILLING_SCHEDULE_UTILS.DUPLICATE_LABOR_MULTIPLIER(
                            p_project_id	          ,
                            l_task_id	          ,
                            p_effective_from_date   ,
                            l_effective_to_date   ,
                            l_labor_multiplier_id,
                            l_return_status
                          )
    THEN
        SELECT pa_labor_multipliers_s.NEXTVAL INTO l_labor_multiplier_id
          FROM dual;
        x_labor_multiplier_id := l_labor_multiplier_id;
        INSERT INTO pa_labor_multipliers(
                                          labor_multiplier_id,
                                          PROJECT_ID,
                                          TASK_ID   ,
                                          LABOR_MULTIPLIER          ,
                                          START_DATE_ACTIVE          ,
                                          END_DATE_ACTIVE ,
                                          CREATED_BY      ,
                                          CREATION_DATE    ,
                                          LAST_UPDATED_BY   ,
                                          LAST_UPDATE_DATE   ,
                                          LAST_UPDATE_LOGIN   ,
                                          RECORD_VERSION_NUMBER )
                                  VALUES(
                                          l_labor_multiplier_id,
                                          p_project_id,
                                          l_task_id,
                                          p_labor_multiplier,
                                          p_effective_from_date,
                                          l_effective_to_date,
                                          FND_GLOBAL.USER_ID,
                                          SYSDATE,
                                          FND_GLOBAL.USER_ID,
                                          SYSDATE,
                                          FND_GLOBAl.LOGIN_ID,
                                          1
                                        );


    ELSE
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_PRJ_DATE_OVERLAP' );
        x_msg_data := 'PA_PRJ_DATE_OVERLAP';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       x_labor_multiplier_id := NULL; -- NOCOPY
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PVT',
                               p_procedure_name => 'create_labor_multiplier',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       x_labor_multiplier_id := NULL;  -- NOCOPY
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       x_labor_multiplier_id := NULL;  -- NOCOPY
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PVT',
                               p_procedure_name => 'create_labor_multiplier',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END Create_Labor_Multiplier;

-- API name                      : update_labor_multiplier
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit	         	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier_id       IN    NUMBER     REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier	         IN	 NUMBER	OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
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
) IS

    l_return_status            VARCHAR2(1);
    l_error_msg_code           VARCHAR2(250);
    l_dummy_char               VARCHAR2(1);
    l_msg_count                NUMBER;

    l_task_id                  NUMBER;
    l_effective_to_date        DATE;
BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT Labor_Multiplier;
    END IF;

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
    END IF;

    IF p_labor_multiplier < 0
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_PRJ_LB_MULT_GR_ZR' );
       x_msg_count := FND_MSG_PUB.count_msg;
       x_msg_data := 'PA_PRJ_LB_MULT_GR_ZR';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

--Mandatory params check

    PA_BILLING_SCHEDULE_UTILS.CHECK_LABOR_MULTIPLIER_REQ(
                              p_labor_multiplier      => p_labor_multiplier,
                              p_effective_from_date   => p_effective_from_date,
                              x_error_msg_code        => l_error_msg_code,
                              x_return_status         => l_return_status );

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_error_msg_code);
        x_msg_data := l_error_msg_code;
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

---Start end date check
    PA_BILLING_SCHEDULE_UTILS.CHECK_START_END_DATE(
                              p_effective_from_date => p_effective_from_date,
                              p_effective_to_date   => l_effective_to_date,
                              x_error_msg_code        => l_error_msg_code,
                              x_return_status         => l_return_status );

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_error_msg_code);
        x_msg_data := l_error_msg_code;
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;


    IF (p_debug_mode = 'Y')
    THEN
         pa_debug.debug('Update_Labor_Multiplier PVT: Checking Lock on record');
    END IF;

    IF p_validate_only <> FND_API.G_TRUE
    THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
             FROM pa_labor_multipliers
            WHERE labor_multiplier_id = p_labor_multiplier_id
              AND record_version_number  = p_record_version_number
              FOR UPDATE OF record_version_number NOWAIT;
        EXCEPTION
           WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
               IF SQLCODE = -54 THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                  x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                  x_return_status := 'E' ;
               ELSE
                  raise;
               END IF;
        END;
      ELSE
         BEGIN
           SELECT 'x' INTO l_dummy_char
             FROM  pa_labor_multipliers
            WHERE labor_multiplier_id = p_labor_multiplier_id
           AND record_version_number  = p_record_version_number;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              END IF;
          END;
      end if;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

      IF NOT PA_BILLING_SCHEDULE_UTILS.DUPLICATE_LABOR_MULTIPLIER(
                            p_project_id	          ,
                            l_task_id	          ,
                            p_effective_from_date   ,
                            l_effective_to_date   ,
                            p_labor_multiplier_id,
                            l_return_status
                          )
      THEN
        UPDATE pa_labor_multipliers
           SET LABOR_MULTIPLIER       = p_labor_multiplier,
               START_DATE_ACTIVE      = p_effective_from_date,
               END_DATE_ACTIVE        = l_effective_to_date,
               LAST_UPDATED_BY        = FND_GLOBAL.USER_ID,
               LAST_UPDATE_DATE       = SYSDATE,
               LAST_UPDATE_LOGIN      = FND_GLOBAL.LOGIN_ID,
               RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
         WHERE labor_multiplier_id = p_labor_multiplier_id
           AND RECORD_VERSION_NUMBER = p_RECORD_VERSION_NUMBER;
      ELSE
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_PRJ_DATE_OVERLAP' );
        x_msg_data := 'PA_PRJ_DATE_OVERLAP';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PVT',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PVT',
                               p_procedure_name => 'update_labor_multiplier',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END Update_Labor_Multiplier;


-- API name                      : delete_labor_multiplier
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit	         	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier_id       IN    NUMBER     REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_labor_multiplier	         IN	 NUMBER	OPTIONAL
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
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier_id   IN    NUMBER,
 p_project_id	       IN	 NUMBER     ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_labor_multiplier	 IN	 NUMBER	,
 p_effective_from_date	 IN	 DATE	      ,
 p_record_version_number IN	 NUMBER     DEFAULT 1,
 x_return_status	       OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	       OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_data	             OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
)IS

    l_return_status            VARCHAR2(1);
    l_error_msg_code           VARCHAR2(250);
    l_dummy_char               VARCHAR2(1);
    l_msg_count                NUMBER;

    l_task_id                  NUMBER;
    l_effective_to_date        DATE;
BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT Labor_Multiplier;
    END IF;

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

    END IF;

    IF (p_debug_mode = 'Y')
    THEN
         pa_debug.debug('Delete_Labor_Multiplier PVT: Checking Lock on record');
    END IF;

    IF p_validate_only <> FND_API.G_TRUE
    THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
             FROM pa_labor_multipliers
            WHERE labor_multiplier_id = p_labor_multiplier_id
              AND record_version_number  = p_record_version_number
              FOR UPDATE OF record_version_number NOWAIT;
        EXCEPTION
           WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
               IF SQLCODE = -54 THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                  x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                  x_return_status := 'E' ;
               ELSE
                  raise;
               END IF;
        END;
      ELSE
         BEGIN
           SELECT 'x' INTO l_dummy_char
             FROM  pa_labor_multipliers
            WHERE labor_multiplier_id = p_labor_multiplier_id
              AND record_version_number  = p_record_version_number;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              END IF;
          END;
      end if;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

      DELETE pa_labor_multipliers
       WHERE labor_multiplier_id = p_labor_multiplier_id
         AND RECORD_VERSION_NUMBER = p_RECORD_VERSION_NUMBER;
 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Labor_Multiplier;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PVT',
                               p_procedure_name => 'delete_labor_multiplier',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SCHEDULE_PVT',
                               p_procedure_name => 'delete_labor_multiplier',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END Delete_Labor_Multiplier;

END PA_BILLING_SCHEDULE_PVT;

/
