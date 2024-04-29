--------------------------------------------------------
--  DDL for Package Body PA_BILLING_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_SETUP_PVT" AS
/* $Header: PABLSTVB.pls 120.3 2005/08/19 16:17:01 mwasowic noship $ */


-- API name                      : update_revenue_and_billing
-- Type                          : Private procedure
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
-- p_distribution_rule         IN    VARCHAR2   REQUIRED
-- p_billing_cycle_id          IN    NUMBER   REQUIRED
-- p_first_bill_offset         IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_next_billing_date         IN    DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_output_tax_code           IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_billing_job_group_id         IN    NUMBER   REQUIRED
-- p_invoice_comment           IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_labor_id                    IN    NUMBER   REQUIRED
-- p_non_labor_id                 IN    NUMBER   OPTIONAL
-- p_retention_inv_format_id   IN    VARCHAR2   OPTIONAL
-- p_retention_percent         IN    NUMBER     OPTIONAL
-- p_retention_output_tax_code IN    VARCHAR2   OPTIONAL
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  update_revenue_and_billing(
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER    ,
 p_distribution_rule         IN    VARCHAR2   ,
 p_billing_cycle_id          IN    NUMBER   ,
 p_first_bill_offset         IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_next_billing_date         OUT    NOCOPY DATE       , --File.Sql.39 bug 4440895
 p_output_tax_code           IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_billing_job_group_id         IN    NUMBER   ,
 p_invoice_comment           IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_labor_id                     IN    NUMBER   ,
 p_non_labor_id                 IN    NUMBER   ,
 p_retention_inv_format_id   IN    VARCHAR2   ,
 p_retention_percent         IN    NUMBER     ,
 p_retention_output_tax_code IN    VARCHAR2   ,
 p_record_version_number	 IN	 NUMBER     DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

  l_return_status                    VARCHAR2(1);
  l_msg_data                         VARCHAR2(250);
  l_msg_count                        NUMBER;

  l_dummy_char                       VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;

  l_task_id                         NUMBER;
  l_first_bill_offset               NUMBER;
  l_next_billing_date               DATE;
  l_output_tax_code                 VARCHAR2(50);
  l_invoice_comment                 VARCHAR2(240);
  l_retention_inv_format_id         NUMBER(15);
  l_retention_percent               PA_PROJECTS_ALL.RETENTION_PERCENTAGE%TYPE;
  l_retention_output_tax_code       VARCHAR2(50);
  l_project_type_class_code         PA_PROJECT_TYPES.PROJECT_TYPE_CLASS_CODE%TYPE;


BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT revenue_and_billing;
    END IF;

    x_return_status := 'S';

   IF p_validate_only = FND_API.G_TRUE AND p_validation_level > 0
   THEN
      --Assign null to the variables that are passed as G_MISS....

      IF  p_first_bill_offset  = FND_API.G_MISS_NUM
      THEN
          l_first_bill_offset := null;
      ELSE
          l_first_bill_offset := p_first_bill_offset;
      END IF;

      IF p_next_billing_date = FND_API.G_MISS_DATE
      THEN
         l_next_billing_date := null;
      ELSE
         l_next_billing_date := p_next_billing_date;
      END IF;

      IF p_output_tax_code = FND_API.G_MISS_CHAR
      THEN
         l_output_tax_code := null;
      ELSE
         l_output_tax_code := p_output_tax_code;
      END IF;

      IF p_invoice_comment = FND_API.G_MISS_CHAR
      THEN
         l_invoice_comment := null;
      ELSE
         l_invoice_comment := p_invoice_comment;
      END IF;

      IF p_retention_percent = FND_API.G_MISS_NUM
      THEN
         l_retention_percent := null;
      ELSE
         l_retention_percent := p_retention_percent;
      END IF;

      IF p_retention_output_tax_code = FND_API.G_MISS_CHAR
      THEN
         l_retention_output_tax_code := null;
      ELSE
         l_retention_output_tax_code := p_retention_output_tax_code;
      END IF;

  END IF;

--  Mandatory parameters check

    --Get the project type class code and pass to procedure to validate mandaory columns
    l_project_type_class_code := PA_BILLING_SCHEDULE_UTILS.Get_Project_Type_Class(
                                       p_project_id,
                                       l_return_status );

    PA_BILLING_SETUP_UTILS.REV_BILL_INF_REQ_CHECK(
                   p_project_type_class_code   => l_project_type_class_code,
                   p_distribution_rule         => p_distribution_rule,
                   p_billing_cycle_id          => p_billing_cycle_id,
                   p_first_bill_offset         => p_first_bill_offset,
                   p_billing_job_group_id      => p_billing_job_group_id,
                   p_labor_id                  => p_labor_id,
                   p_non_labor_id              => p_non_labor_id,
                   x_return_status	           => l_return_status,
                   x_error_msg_code            => l_error_msg_code );

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
      pa_debug.debug('Update_reve_and_billing PVT: Checking Lock on record');
  END IF;

      /* Lock pa_projects table and update */
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
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;


      UPDATE pa_projects
         SET  DISTRIBUTION_RULE                   = p_distribution_rule,
              BILLING_CYCLE_ID                    = p_billing_cycle_id,
              BILLING_OFFSET                      = l_first_bill_offset,
              OUTPUT_TAX_CODE                     = l_output_tax_code,
              BILL_JOB_GROUP_ID                   = p_billing_job_group_id ,
              INVOICE_COMMENT                     = l_invoice_comment,
              LABOR_INVOICE_FORMAT_ID             = p_labor_id,
              NON_LABOR_INVOICE_FORMAT_ID         = p_non_labor_id,
              RETENTION_INVOICE_FORMAT_ID         = p_retention_inv_format_id,
              RETENTION_PERCENTAGE                = l_retention_percent,
              RETENTION_TAX_CODE                  = l_retention_output_tax_code,
              LAST_UPDATE_DATE        = SYSDATE        ,
              LAST_UPDATED_BY         = FND_GLOBAL.USER_ID ,
              LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID,

      /* If job group bill id is changed then update
         the JOB_BILL_RATE_SCHEDULE_ID to null */

              JOB_BILL_RATE_SCHEDULE_ID = DECODE( p_billing_job_group_id, BILL_JOB_GROUP_ID, JOB_BILL_RATE_SCHEDULE_ID ),
              RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
        WHERE project_id = p_project_id
          AND record_version_number = p_record_version_number;


EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO revenue_and_billing;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'update_rev_and_billing',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO revenue_and_billing;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO revenue_and_billing;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'update_rev_and_billing',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END update_revenue_and_billing;

-- API name                      : create_credit_receivers
-- Type                          : Private procedure
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
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_percentage         IN    NUMBER   REQUIRED
-- p_transfer_to_AR            IN    VARCHAR2   REQUIRED
-- p_effective_from_date       IN    DATE       REQUIRED
-- p_effective_to_date         IN    DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- x_credit_receiver_id        OUT   NUMBER   REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  create_credit_receivers(
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_type               IN    VARCHAR2   ,
 p_person_id                 IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_percentage         IN    NUMBER   ,
 p_transfer_to_AR            IN    VARCHAR2   ,
 p_effective_from_date         IN    DATE       ,
 p_effective_to_date           IN    DATE        DEFAULT FND_API.G_MISS_DATE,
 x_credit_receiver_id        OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

    l_return_status            VARCHAR2(1);
    l_error_msg_code           VARCHAR2(250);
    l_dummy_char               VARCHAR2(1);
    l_msg_count                NUMBER;


    l_task_id	             NUMBER;
    l_credit_percentage        NUMBER;
    l_effective_to_date        DATE;
    l_person_id                NUMBER;
    l_credit_receiver_id       NUMBER;
BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT credit_receivers;
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

       IF p_credit_percentage = FND_API.G_MISS_NUM
       THEN
          l_credit_percentage := null;
       ELSE
          l_credit_percentage := p_credit_percentage;
       END IF;

       IF p_effective_to_date = FND_API.G_MISS_DATE
       THEN
          l_effective_to_date := null;
       ELSE
          l_effective_to_date := p_effective_to_date;
       END IF;

       --Mandatory check for parmeters
       PA_BILLING_SETUP_UTILS.CREDIT_REC_REQ_CHECK(
                             p_credit_type   => p_credit_type,
                             p_person_id     => p_person_id,
                             p_transfer_to_AR => p_transfer_to_AR,
                             p_effective_from_date => p_effective_from_date,
                             x_return_status  => l_return_status,
                             x_error_msg_code            => l_error_msg_code );

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


       IF NOT PA_BILLING_SETUP_UTILS.Duplicate_credit_receivers(
                                   p_project_id	         	 => p_project_id,
                                   p_task_id	         	 => l_task_id,
                                   p_credit_type             => p_credit_type,
                                   p_person_id               => p_person_id,
                                   p_effective_from_date     => p_effective_from_date,
                                   p_effective_to_date     => l_effective_to_date,
                                   p_credit_receiver_id    => l_credit_receiver_id,
                                   x_return_status	       => l_return_status
                                  )
       THEN
          SELECT pa_credit_receivers_s.NEXTVAL INTO l_credit_receiver_id
            FROM dual;
          x_credit_receiver_id := l_credit_receiver_id;
          INSERT INTO pa_credit_receivers(
                                          credit_receiver_id,
                                          PERSON_ID,
                                          CREDIT_TYPE_CODE              ,
                                          PROJECT_ID           ,
                                          LAST_UPDATE_DATE    ,
                                          LAST_UPDATED_BY     ,
                                          CREATION_DATE       ,
                                          CREATED_BY,
                                          LAST_UPDATE_LOGIN   ,
                                          START_DATE_ACTIVE   ,
                                          CREDIT_PERCENTAGE   ,
                                          TASK_ID             ,
                                          END_DATE_ACTIVE      ,
                                          TRANSFER_TO_AR_FLAG   ,
                                          SALESREP_ID            ,
                                          BUDGET_TYPE_CODE        ,
                                          RECORD_VERSION_NUMBER
                                         )
                                 VALUES (
                                          l_credit_receiver_id,
                                          p_person_id,
                                          p_credit_type,
                                          p_project_id,
                                          sysdate,
                                          FND_GLOBAL.USER_ID,
                                          sysdate,
                                          FND_GLOBAL.USER_ID,
                                          FND_GLOBAL.LOGIN_ID,
                                          p_effective_from_date,
                                          p_credit_percentage,
                                          l_task_id,
                                          p_effective_to_date,
                                          p_transfer_to_AR,
                                          null,
                                          null,
                                          1
                                        );

       ELSE
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_PRJ_CR_REC_EXISTS' );
          x_msg_data := 'PA_PRJ_CR_REC_EXISTS';
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'CREATE_CREDIT_RECEIVERS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       x_credit_receiver_id := null;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := 'E';

       x_credit_receiver_id := null;

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'CREATE_CREDIT_RECEIVERS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));

       x_credit_receiver_id := null;

       RAISE;

END create_credit_receivers;

-- API name                      : update_credit_receivers
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit	         	       IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_receiver_id        IN   NUMBER   REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_percentage         IN    NUMBER   REQUIRED
-- p_transfer_to_AR            IN    VARCHAR2   REQUIRED
-- p_effective_from_date       IN    DATE       REQUIRED
-- p_effective_to_date         IN    DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  update_credit_receivers(
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_receiver_id        IN   NUMBER   ,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_type               IN    VARCHAR2   ,
 p_person_id                 IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_percentage         IN    NUMBER   DEFAULT FND_API.G_MISS_NUM,
 p_transfer_to_AR            IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_effective_from_date         IN    DATE       ,
 p_effective_to_date           IN    DATE        DEFAULT FND_API.G_MISS_DATE,
 p_record_version_number	 IN	 NUMBER     DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

    l_return_status            VARCHAR2(1);
    l_error_msg_code           VARCHAR2(250);
    l_dummy_char               VARCHAR2(1);
    l_msg_count                NUMBER;

    l_effective_to_date        DATE;

    l_task_id	             NUMBER;
    l_credit_percentage        NUMBER;
    l_person_id                NUMBER;
BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT credit_receivers;
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

       IF p_credit_percentage = FND_API.G_MISS_NUM
       THEN
          l_credit_percentage := null;
       ELSE
          l_credit_percentage := p_credit_percentage;
       END IF;

       IF l_effective_to_date = FND_API.G_MISS_DATE
       THEN
          l_effective_to_date := null;
       ELSE
          l_effective_to_date := p_effective_to_date;
       END IF;

       --Mandatory check for parmeters
       PA_BILLING_SETUP_UTILS.CREDIT_REC_REQ_CHECK(
                             p_credit_type   => p_credit_type,
                             p_person_id     => p_person_id,
                             p_transfer_to_AR => p_transfer_to_AR,
                             p_effective_from_date => p_effective_from_date,
                             x_return_status  => l_return_status,
                             x_error_msg_code            => l_error_msg_code );


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
         pa_debug.debug('Update_Credit_Receivers PVT: Checking Lock on record');
    END IF;

    IF p_validate_only <> FND_API.G_TRUE
    THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
             FROM pa_credit_receivers
            WHERE credit_receiver_id = p_credit_receiver_id
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
             FROM pa_credit_receivers
            WHERE credit_receiver_id = p_credit_receiver_id
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

       IF NOT PA_BILLING_SETUP_UTILS.Duplicate_credit_receivers(
                                   p_project_id	         	 => p_project_id,
                                   p_task_id	         	 => l_task_id,
                                   p_credit_type             => p_credit_type,
                                   p_person_id               => p_person_id,
                                   p_effective_from_date     => p_effective_from_date,
                                   p_effective_to_date       => l_effective_to_date,
                                   p_credit_receiver_id      => p_credit_receiver_id,
                                   x_return_status	       => l_return_status
                                  )
       THEN

           UPDATE pa_credit_receivers
              SET CREDIT_PERCENTAGE   = l_credit_percentage,
                  start_date_active   = p_effective_from_date,
                  TRANSFER_TO_AR_FLAG = p_TRANSFER_TO_AR,
                  end_date_active     = l_effective_to_date,
                  credit_type_code = p_credit_type,
                  person_id   = p_person_id,
                  LAST_UPDATE_DATE    = SYSDATE        ,
                  LAST_UPDATED_BY     = FND_GLOBAL.USER_ID ,
                  LAST_UPDATE_LOGIN   = FND_GLOBAL.LOGIN_ID,
                  RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
            WHERE credit_receiver_id = p_credit_receiver_id
              AND RECORD_VERSION_NUMBER = p_RECORD_VERSION_NUMBER;
       ELSE
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_PRJ_CR_REC_EXISTS' );
          x_msg_data := 'PA_PRJ_CR_REC_EXISTS';
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
       END IF;

    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'UPDATE_CREDIT_RECEIVERS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'UPDATE_CREDIT_RECEIVERS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END update_credit_receivers;



-- API name                      : delete_credit_receivers
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit	         	       IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only	 	 IN	 VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module	 	 IN 	 VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode	         	 IN	 VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count	 	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_receiver_id        IN   NUMBER   REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_effective_from_date       IN    DATE       REQUIRED
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  delete_credit_receivers(
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_receiver_id        IN   NUMBER   ,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_type               IN    VARCHAR2   ,
 p_person_id                 IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_effective_from_date         IN    DATE       ,
 p_record_version_number	 IN	 NUMBER     DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

    l_return_status            VARCHAR2(1);
    l_error_msg_code           VARCHAR2(250);
    l_dummy_char               VARCHAR2(1);
    l_msg_count                NUMBER;

    l_effective_to_date        DATE;

    l_task_id	             NUMBER;
    l_credit_percentage        NUMBER;
    l_person_id                NUMBER;
BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT credit_receivers;
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
         pa_debug.debug('Delete_Credit_Receivers PVT: Checking Lock on record');
    END IF;

    IF p_validate_only <> FND_API.G_TRUE
    THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
             FROM pa_credit_receivers
            WHERE credit_receiver_id = p_credit_receiver_id
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
             FROM pa_credit_receivers
            WHERE credit_receiver_id = p_credit_receiver_id
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

       DELETE FROM pa_credit_receivers
        WHERE credit_receiver_id = p_credit_receiver_id
          AND RECORD_VERSION_NUMBER = p_RECORD_VERSION_NUMBER;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'delete_CREDIT_RECEIVERS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'delete_CREDIT_RECEIVERS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END delete_credit_receivers;


-- API name                      : create_billing_assignments
-- Type                          : Private procedure
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
-- p_billing_extension_id    IN    NUMBER   REQUIRED
-- p_amount                    IN    NUMBER     OPTIONAL DEFAULT=FND_API.G_MISS_NUM
-- p_percent                   IN    NUMBER     OPTIONAl DEFAULT=FND_API.G_MISS_NUM
-- p_active                    IN    VARCHAR2   REQUIRED
-- x_billing_assignment_id    OUT  NUMBER   REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  create_billing_assignments(
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_billing_extension_id    IN    NUMBER   ,
 p_amount                    IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_percent                   IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_active                    IN    VARCHAR2    ,
 x_billing_assignment_id    OUT  NOCOPY NUMBER   , --File.Sql.39 bug 4440895
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  CURSOR cur_proj_all
  IS
    SELECT org_id, distribution_rule, project_type
      FROM pa_projects_all
     WHERE project_id = p_project_id;

    l_return_status            VARCHAR2(1);
    l_error_msg_code           VARCHAR2(250);
    l_dummy_char               VARCHAR2(1);
    l_msg_count                NUMBER;

    l_effective_to_date        DATE;

    l_task_id	             NUMBER;
    l_amount             NUMBER;
    l_percent            NUMBER;

    l_rec_proj_all       cur_proj_all%ROWTYPE;

    l_billing_assignment_id   NUMBER;

BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT billing_assignments;
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

       IF p_amount = FND_API.G_MISS_NUM
       THEN
          l_amount := null;
       ELSE
          l_amount := p_amount;
       END IF;

       IF p_percent = FND_API.G_MISS_NUM
       THEN
          l_percent := null;
       ELSE
          l_percent := p_percent;
       END IF;

       --Mandatory parameters check
       PA_BILLING_SETUP_UTILS.BILL_XTENSION_REQ_CHECK(
                              p_billing_extension_id   => p_billing_extension_id,
                              x_return_status	       => l_return_status,
                              x_error_msg_code         => l_error_msg_code );

        IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_error_msg_code);

            x_msg_data := l_error_msg_code;
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
        END IF;


       IF NOT PA_BILLING_SETUP_UTILS.Duplicate_billing_assignments(
                                   p_project_id	         	 => p_project_id,
                                   p_task_id	         	 => l_task_id,
                                   p_billing_extension_id    => p_billing_extension_id,
                                   p_billing_assignment_id    => l_billing_assignment_id,
                                   p_active_flag              => p_active,
                                   x_return_status	       => l_return_status
                                  )
       THEN

          OPEN cur_proj_all;
          FETCH cur_proj_all INTO l_rec_proj_all;
          CLOSE cur_proj_all;


          SELECT PA_BILLING_ASSIGNMENTS_S.NEXTVAL INTO l_billing_assignment_id
            FROM dual;

          x_billing_assignment_id := l_billing_assignment_id;
          INSERT INTO pa_billing_assignments_all(
                           BILLING_ASSIGNMENT_ID           ,
                           BILLING_EXTENSION_ID            ,
                           PROJECT_TYPE                    ,
                           PROJECT_ID                      ,
                           TOP_TASK_ID                     ,
                           AMOUNT                          ,
                           PERCENTAGE                      ,
                           ACTIVE_FLAG                     ,
                           CREATION_DATE                   ,
                           CREATED_BY                      ,
                           LAST_UPDATE_DATE                ,
                           LAST_UPDATED_BY                 ,
                           LAST_UPDATE_LOGIN               ,
                           ATTRIBUTE_CATEGORY              ,
                           DISTRIBUTION_RULE               ,
                           ORG_ID                          ,
                           RECORD_VERSION_NUMBER  )
                 VALUES (  l_billing_assignment_id,
                           p_billing_extension_id          ,
                           l_rec_proj_all.project_type                  ,
                           p_project_id                    ,
                           l_task_id                       ,
                           l_amount                        ,
                           l_percent                       ,
                           p_active                        ,
                           sysdate                         ,
                           FND_GLOBAL.USER_ID                 ,
                           sysdate                         ,
                           FND_GLOBAL.USER_ID                 ,
                           FND_GLOBAL.LOGIN_ID                ,
                           null                            ,
                           l_rec_proj_all.distribution_rule             ,
                           l_rec_proj_all.org_id                        ,
                           1
                        );


       ELSE
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_PRJ_BILL_ASSGN_EXISTS' );
          x_msg_data := 'PA_PRJ_BILL_ASSGN_EXISTS';
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'CREATE_BILLING_ASSIGNMENTS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       x_billing_assignment_id := null;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := 'E';

       x_billing_assignment_id := null;

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'CREATE_BILLING_ASSIGNMENTS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));

       x_billing_assignment_id := null;

       RAISE;

END create_billing_assignments;



-- API name                      : update_billing_assignments
-- Type                          : Private procedure
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
-- p_billing_extension_id    IN    number   REQUIRED
-- p_amount                    IN    NUMBER     REQUIRED
-- p_percent                   IN    NUMBER     REQUIRED
-- p_active                    IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  update_billing_assignments(
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_billing_extension_id    IN    NUMBER   ,
 p_billing_assignment_id    IN    NUMBER   ,
 p_amount                    IN    NUMBER     ,
 p_percent                   IN    NUMBER     ,
 p_active                    IN    VARCHAR2    DEFAULT FND_API.G_MISS_CHAR,
 p_record_version_number	 IN	 NUMBER    DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

    l_return_status            VARCHAR2(1);
    l_error_msg_code           VARCHAR2(250);
    l_dummy_char               VARCHAR2(1);
    l_msg_count                NUMBER;

    l_effective_to_date        DATE;

    l_task_id	             NUMBER;
    l_amount             NUMBER;
    l_percent            NUMBER;

BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT billing_assignments;
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

       IF p_amount = FND_API.G_MISS_NUM
       THEN
          l_amount := null;
       ELSE
          l_amount := p_amount;
       END IF;

       IF p_percent = FND_API.G_MISS_NUM
       THEN
          l_percent := null;
       ELSE
          l_percent := p_percent;
       END IF;

       --Mandatory parameters check
       PA_BILLING_SETUP_UTILS.BILL_XTENSION_REQ_CHECK(
                              p_billing_extension_id   => p_billing_extension_id,
                              x_return_status	       => l_return_status,
                              x_error_msg_code         => l_error_msg_code );

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
         pa_debug.debug('Update Billing Assignments PVT: Checking Lock on record');
    END IF;

    IF p_validate_only <> FND_API.G_TRUE
    THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
             FROM pa_billing_assignments_all
            WHERE billing_assignment_id   = p_billing_assignment_id
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
             FROM pa_billing_assignments_all
            WHERE billing_assignment_id   = p_billing_assignment_id
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

      IF NOT PA_BILLING_SETUP_UTILS.Duplicate_billing_assignments(
                                   p_project_id	         	 => p_project_id,
                                   p_task_id	         	 => l_task_id,
                                   p_billing_extension_id    => p_billing_extension_id,
                                   p_billing_assignment_id   => p_billing_assignment_id,
                                   p_active_flag              => p_active,
                                   x_return_status	       => l_return_status
                                  )
      THEN
         UPDATE  pa_billing_assignments_all
            SET
                 billing_extension_id    = p_billing_extension_id,
                 AMOUNT                  = l_amount       ,
                 PERCENTAGE              = l_percent      ,
                 ACTIVE_FLAG             = p_active       ,
                 LAST_UPDATE_DATE        = SYSDATE        ,
                 LAST_UPDATED_BY         = FND_GLOBAL.USER_ID ,
                 LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID,
                 RECORD_VERSION_NUMBER   = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
           WHERE billing_assignment_id = p_billing_assignment_id
             AND  RECORD_VERSION_NUMBER = p_record_version_number;
       ELSE
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_PRJ_BILL_ASSGN_EXISTS' );
          x_msg_data := 'PA_PRJ_BILL_ASSGN_EXISTS';
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
       END IF;

    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'UPDATE_BILLING_ASSIGNMENTS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'UPDATE_BILLING_ASSIGNMENTS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END update_billing_assignments;


-- API name                      : delete_billing_assignments
-- Type                          : Private procedure
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
-- p_billing_extension_id    IN    NUMBER   REQUIRED
-- p_billing_assignment_id    IN    NUMBER   ,
-- p_record_version_number	 IN	 NUMBER     REQUIRED   DEFAULT=1
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_msg_count	             OUT 	 VARCHAR2   REQUIRED
-- x_msg_data	             OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  delete_billing_assignments(
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_billing_extension_id    IN    NUMBER   ,
 p_billing_assignment_id    IN    NUMBER   ,
 p_record_version_number	 IN	 NUMBER    DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

    l_return_status            VARCHAR2(1);
    l_error_msg_code           VARCHAR2(250);
    l_dummy_char               VARCHAR2(1);
    l_msg_count                NUMBER;

    l_effective_to_date        DATE;

    l_task_id	             NUMBER;
    l_amount             NUMBER;
    l_percent            NUMBER;

BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT billing_assignments;
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

    IF (p_debug_mode = 'Y')
    THEN
         pa_debug.debug('Delete Billing Assignments PVT: Checking Lock on record');
    END IF;

    IF p_validate_only <> FND_API.G_TRUE
    THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
             FROM pa_billing_assignments_all
            WHERE billing_extension_id   = p_billing_extension_id
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
             FROM pa_billing_assignments_all
            WHERE billing_extension_id   = p_billing_extension_id
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


       DELETE FROM pa_billing_assignments_all
        WHERE billing_extension_id   = p_billing_extension_id
          AND  RECORD_VERSION_NUMBER = p_record_version_number;

    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'DELETE_BILLING_ASSIGNMENTS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PVT',
                               p_procedure_name => 'DELETE_BILLING_ASSIGNMENTS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END delete_billing_assignments;

END PA_BILLING_SETUP_PVT;

/
