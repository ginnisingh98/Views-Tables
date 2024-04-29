--------------------------------------------------------
--  DDL for Package Body PA_BILLING_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_SETUP_PUB" AS
/* $Header: PABLSTPB.pls 120.3 2005/08/19 16:16:42 mwasowic noship $ */

   G_PKG_NAME       VARCHAR2(30) := 'PA_BILLING_SETUP_PUB';

-- API name                      : update_revenue_and_billing
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
-- p_distribution_rule         IN    VARCHAR2   REQUIRED
-- p_billing_cycle_id          IN    NUMBER     REQUIRED
-- p_first_bill_offset         IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_next_billing_date         IN    DATE       OPTIONAL
-- p_output_tax_code           IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_billing_job_group_id         IN    NUMBER   REQUIRED
-- p_invoice_comment           IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- p_labor_id                     IN    NUMBER   REQUIRED
-- p_non_labor_id                 IN    NUMBER   OPTIONAL
-- p_retention_inv_format_id   IN    VARCHAR2   OPTIONAL
-- p_retention_inv_format_name IN    VARCHAR2   OPTIONAL
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
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
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
 p_retention_inv_format_name IN    VARCHAR2   ,
 p_retention_percent         IN    NUMBER     ,
 p_retention_output_tax_code IN    VARCHAR2   ,
 p_record_version_number	 IN	 NUMBER     DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

  CURSOR cur_projects_all
  IS
    SELECT start_date
      FROM pa_projects_all
     WHERE project_id = p_project_id;

  l_api_name                CONSTANT VARCHAR(30) := 'update_revenue_and_billing';
  l_api_version             CONSTANT NUMBER      := 1.0;

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
  l_start_date                      DATE;

BEGIN
   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('Update Revenue and Bill Info PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT revenue_and_billing;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update Revenue and Bill Info PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SETUP_PUB.update_revenue_and_billing');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

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

      IF NVl( p_first_bill_offset, 0 ) < 0
      THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_PRJ_BILL_OFFSET_GR_ZR' );
          x_msg_data := 'PA_PRJ_BILL_OFFSET_GR_ZR';
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
      END IF;

      IF NVL( p_retention_percent, 0 ) < 0
      THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_PRJ_RETN_PERCENT_GR_ZR' );
          x_msg_data := 'PA_PRJ_RETN_PERCENT_GR_ZR';
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
      END IF;

      --Validate and convert name to id for retention_inv_format.
      IF ( p_retention_inv_format_id IS NOT NULL AND p_retention_inv_format_id <> FND_API.G_MISS_NUM ) OR
         ( p_retention_inv_format_name IS NOT NULL AND p_retention_inv_format_name <> FND_API.G_MISS_CHAR )
      THEN
         if (p_debug_mode = 'Y') then
             pa_debug.debug('Update rev and Billing Info PUB : Checking retention invoice format id');
         end if;
         PA_BILLING_SETUP_UTILS.Validate_Retn_Inv_Format
            ( p_retention_inv_format_id     => p_retention_inv_format_id
             ,p_retention_inv_format_name   => p_retention_inv_format_name
             ,p_check_id_flag               => 'A'
             ,x_retention_inv_format_id     => l_retention_inv_format_id
             ,x_return_status               => l_return_status
             ,x_error_msg_code              => l_error_msg_code);

         IF l_return_status = FND_API.G_RET_STS_ERROR
         THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_error_msg_code);
            x_msg_data := l_error_msg_code;
            x_return_status := 'E';
         END IF;
      END IF;

      --Get the next billing cycle date
      IF p_billing_cycle_id IS NOT NULL
      THEN
         OPEN cur_projects_all;
         FETCH cur_projects_all INTO l_start_date;
         CLOSE cur_projects_all;
         l_next_billing_date := Pa_Billing_Cycles_pkg.Get_Next_billing_Date(
                                        p_project_id,
                                        l_start_date,
                                        p_billing_cycle_id,
                                        l_first_bill_offset,
                                        null,
                                        null );
      END IF;

      PA_BILLING_SETUP_PVT.update_revenue_and_billing(
                               p_commit                      =>  FND_API.G_FALSE,
                               p_validate_only               =>  p_validate_only,
                               p_validation_level            =>  p_validation_level,
                               p_calling_module              =>  p_calling_module,
                               p_debug_mode                  =>  p_debug_mode,
                               p_max_msg_count	 	       =>  p_max_msg_count,
                               p_project_id                  =>  p_project_id,
                               p_distribution_rule           =>  p_distribution_rule,
                               p_billing_cycle_id            =>  p_billing_cycle_id,
                               p_first_bill_offset           =>  l_first_bill_offset,
                               p_next_billing_date           =>  l_next_billing_date,
                               p_output_tax_code             =>  l_output_tax_code,
                               p_billing_job_group_id           =>  p_billing_job_group_id,
                               p_invoice_comment             =>  l_invoice_comment,
                               p_labor_id                       =>  p_labor_id,
                               p_non_labor_id                   =>  p_non_labor_id,
                               p_retention_inv_format_id     =>  l_retention_inv_format_id,
                               p_retention_percent           =>  l_retention_percent,
                               p_retention_output_tax_code   =>  l_retention_output_tax_code,
                               p_record_version_number	 =>  p_record_version_number,
                               x_return_status	             =>  l_return_status,
                               x_msg_count	             =>  l_msg_count,
                               x_msg_data	                   =>  l_msg_data
                            );

      --return the next billing date to the calling program;
      p_next_billing_date := l_next_billing_date;

   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update reve and Bill Info PUB : checking message count');
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
          ROLLBACK TO revenue_and_billing;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'update_revenue_and_Billing',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'update_revenue_and_Billing',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

END update_revenue_and_billing;


-- API name                      : create_credit_receivers
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
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_person_name               IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CAHR
-- p_emp_number                IN    VARCHAR2     OPTIONAL DEFAULT FND_API.G_MISS_CHAR,
-- p_credit_percentage         IN    NUMBER   REQUIRED
-- p_transfer_to_AR            IN    VARCHAR2   REQUIRED
-- p_effective_from_date       IN    DATE       REQUIRED
-- p_effective_to_date         IN    DATE       OPTIONAL   DEFAULT=FND_API.G_MISS_DATE
-- x_credit_receiver_id        OUT   NUMBER     REQUIRED
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
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
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
 p_person_name               IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_emp_number                IN    VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
 p_credit_percentage         IN    NUMBER   ,
 p_transfer_to_AR            IN    VARCHAR2   ,
 p_effective_from_date         IN    DATE       ,
 p_effective_to_date           IN    DATE        DEFAULT FND_API.G_MISS_DATE,
 x_credit_receiver_id          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS
  l_api_name                CONSTANT VARCHAR(30) := 'create_credit_receivers';
  l_api_version             CONSTANT NUMBER      := 1.0;

  l_return_status                    VARCHAR2(1);
  l_msg_data                         VARCHAR2(250);
  l_msg_count                        NUMBER;

  l_dummy_char                       VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;

  l_task_id	         	  NUMBER;
  l_credit_percentage     NUMBER;
  l_effective_to_date     DATE;
  l_person_id             NUMBER;

BEGIN

   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('Update Revenue and Bill Info PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT credit_receivers;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update Revenue and Bill Info PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SETUP_PUB.update_revenue_and_billing');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := 'S';

   IF p_validate_only = FND_API.G_TRUE AND p_validation_level > 0
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


         --Validating employee or person id
         IF ( p_person_id IS NOT NULL AND p_person_id <> FND_API.G_MISS_NUM ) OR
            ( p_person_name IS NOT NULL AND p_person_name <> FND_API.G_MISS_CHAR ) OR
            ( p_emp_number IS NOT NULL AND p_emp_number <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('CREATE CREDIT RECEIVERS : Validating person id');
            end if;
            /*PA_BILLING_SETUP_UTILS.Validate_person_id_name
               ( p_person_id               => p_person_id
                ,p_person_name             => p_person_name
                ,p_check_id_flag           => 'A'
                ,x_person_id               => l_person_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);*/

           PA_BILLING_SETUP_UTILS.VALIDATE_EMP_NO_NAME
               ( p_person_id               => p_person_id
                ,p_person_name             => p_person_name
                ,p_emp_number              => p_emp_number
                ,p_check_id                => 'A'
                ,x_person_id               => l_person_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;

         PA_BILLING_SETUP_PVT.create_credit_receivers(
                                  p_commit	         	 =>    FND_API.G_FALSE,
                                  p_validate_only	 	 =>    p_validate_only,
                                  p_validation_level	       =>    p_validation_level,
                                  p_calling_module	 	 =>    p_calling_module,
                                  p_debug_mode	             =>    p_debug_mode,
                                  p_max_msg_count	 	 =>    p_max_msg_count,
                                  p_project_id	             =>    p_project_id,
                                  p_task_id	         	 =>    l_task_id,
                                  p_credit_type              =>    p_credit_type,
                                  p_person_id                =>    l_person_id,
                                  p_credit_percentage        =>    l_credit_percentage,
                                  p_transfer_to_AR           =>    p_transfer_to_AR,
                                  p_effective_from_date      =>    p_effective_from_date,
                                  p_effective_to_date        =>    l_effective_to_date,
                                  x_credit_receiver_id       =>    x_credit_receiver_id,
                                  x_return_status	       =>    l_return_status,
                                  x_msg_count	             =>    l_msg_count,
                                  x_msg_data	             =>    l_msg_data
                                );
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('CREATE CREDIT RECEIVERS PUB : checking message count');
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
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'CREATE_CREDIT_RECEIVERS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));

       x_credit_receiver_id := null;
       RAISE;

END create_credit_receivers;

-- API name                      : update_credit_receivers
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
-- p_credit_receiver_id        IN    NUMBER     REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_person_name               IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CAHR
-- p_emp_number                IN    VARCHAR2     OPTIONAL DEFAULT FND_API.G_MISS_CHAR,
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
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_receiver_id        IN    NUMBER,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_type               IN    VARCHAR2   ,
 p_person_id                 IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_person_name               IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_emp_number                IN    VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
 p_credit_percentage         IN    NUMBER   DEFAULT FND_API.G_MISS_NUM,
 p_transfer_to_AR            IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_effective_from_date         IN    DATE       ,
 p_effective_to_date           IN    DATE        DEFAULT FND_API.G_MISS_DATE,
 p_record_version_number	 IN	 NUMBER     DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) AS
  l_api_name                CONSTANT VARCHAR(30) := 'update_credit_receivers';
  l_api_version             CONSTANT NUMBER      := 1.0;

  l_return_status                    VARCHAR2(1);
  l_msg_data                         VARCHAR2(250);
  l_msg_count                        NUMBER;

  l_dummy_char                       VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;

  l_task_id	         	  NUMBER;
  l_credit_percentage     NUMBER;
  l_effective_to_date     DATE;
  l_person_id             NUMBER;
BEGIN

   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('Update credit receivers PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT credit_receivers;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update credit receivers PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SETUP_PUB.update_credit receivers');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := 'S';

   IF p_validate_only = FND_API.G_TRUE AND p_validation_level > 0
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


         --Validating employee or person id
         IF ( p_person_id IS NOT NULL AND p_person_id <> FND_API.G_MISS_NUM ) OR
            ( p_person_name IS NOT NULL AND p_person_name <> FND_API.G_MISS_CHAR ) OR
            ( p_emp_number IS NOT NULL AND p_emp_number <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('UPDATE CREDIT RECEIVERS : Validating person id');
            end if;
            /*PA_BILLING_SETUP_UTILS.Validate_person_id_name
               ( p_person_id               => p_person_id
                ,p_person_name             => p_person_name
                ,p_check_id_flag           => 'A'
                ,x_person_id               => l_person_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);*/

           PA_BILLING_SETUP_UTILS.VALIDATE_EMP_NO_NAME
               ( p_person_id               => p_person_id
                ,p_person_name             => p_person_name
                ,p_emp_number              => p_emp_number
                ,p_check_id           => 'A'
                ,x_person_id               => l_person_id
                ,x_return_status           => l_return_status
                ,x_error_msg_code          => l_error_msg_code);

            IF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => l_error_msg_code);
               x_msg_data := l_error_msg_code;
               x_return_status := 'E';
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;

         PA_BILLING_SETUP_PVT.update_credit_receivers(
                                  p_commit	         	 =>    FND_API.G_FALSE,
                                  p_validate_only	 	 =>    p_validate_only,
                                  p_validation_level	       =>    p_validation_level,
                                  p_calling_module	 	 =>    p_calling_module,
                                  p_debug_mode	             =>    p_debug_mode,
                                  p_max_msg_count	 	 =>    p_max_msg_count,
                                  p_credit_receiver_id       =>    p_credit_receiver_id,
                                  p_project_id	             =>    p_project_id,
                                  p_task_id	         	 =>    l_task_id,
                                  p_credit_type              =>    p_credit_type,
                                  p_person_id                =>    l_person_id,
                                  p_credit_percentage        =>    l_credit_percentage,
                                  p_transfer_to_AR           =>    p_transfer_to_AR,
                                  p_effective_from_date      =>    p_effective_from_date,
                                  p_effective_to_date        =>    l_effective_to_date,
                                  p_record_version_number    =>    p_record_version_number,
                                  x_return_status	       =>    l_return_status,
                                  x_msg_count	             =>    l_msg_count,
                                  x_msg_data	             =>    l_msg_data
                                );
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('UPDATE CREDIT RECEIVERS PUB : checking message count');
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
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'UPDATE_CREDIT_RECEIVERS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;


END update_credit_receivers;


-- API name                      : delete_credit_receivers
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
-- p_credit_receiver_id        IN    NUMBER     REQUIRED
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_person_name               IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CAHR
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
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_receiver_id        IN    NUMBER,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_type           IN    VARCHAR2   ,
 p_person_id             IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_person_name           IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_effective_from_date   IN    DATE       ,
 p_record_version_number	 IN	 NUMBER     DEFAULT 1,
 x_return_status	             OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	             OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	                   OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

 ) AS
  l_api_name                CONSTANT VARCHAR(30) := 'delete_credit_receivers';
  l_api_version             CONSTANT NUMBER      := 1.0;

  l_return_status                    VARCHAR2(1);
  l_msg_data                         VARCHAR2(250);
  l_msg_count                        NUMBER;

  l_dummy_char                       VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;

  l_task_id	         	  NUMBER;
  l_person_id             NUMBER;
BEGIN

   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('Delete credit receivers PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT credit_receivers;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Delete credit receivers PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SETUP_PUB.Delete_credit receivers');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := 'S';

   IF p_validate_only = FND_API.G_TRUE AND p_validation_level > 0
   THEN
       IF p_task_id = FND_API.G_MISS_NUM
       THEN
          l_task_id := null;
       ELSE
          l_task_id := p_task_id;
       END IF;


         --Validating employee or person id
         IF ( p_person_id IS NOT NULL AND p_person_id <> FND_API.G_MISS_NUM ) OR
            ( p_person_name IS NOT NULL AND p_person_name <> FND_API.G_MISS_CHAR )
         THEN
            if (p_debug_mode = 'Y') then
                pa_debug.debug('UPDATE CREDIT RECEIVERS : Validating person id');
            end if;
            PA_BILLING_SETUP_UTILS.Validate_person_id_name
               ( p_person_id               => p_person_id
                ,p_person_name             => p_person_name
                ,p_check_id_flag           => 'A'
                ,x_person_id               => l_person_id
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

         PA_BILLING_SETUP_PVT.delete_credit_receivers(
                                  p_commit	         	 =>    FND_API.G_FALSE,
                                  p_validate_only	 	 =>    p_validate_only,
                                  p_validation_level	       =>    p_validation_level,
                                  p_calling_module	 	 =>    p_calling_module,
                                  p_debug_mode	             =>    p_debug_mode,
                                  p_max_msg_count	 	 =>    p_max_msg_count,
                                  p_credit_receiver_id       =>    p_credit_receiver_id,
                                  p_project_id	             =>    p_project_id,
                                  p_task_id	         	 =>    l_task_id,
                                  p_credit_type              =>    p_credit_type,
                                  p_person_id                =>    l_person_id,
                                  p_effective_from_date      =>    p_effective_from_date,
                                  p_record_version_number    =>    p_record_version_number,
                                  x_return_status	       =>    l_return_status,
                                  x_msg_count	             =>    l_msg_count,
                                  x_msg_data	             =>    l_msg_data
                                );
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('DELETE CREDIT RECEIVERS PUB : checking message count');
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
          ROLLBACK TO credit_receivers;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'DELETE_CREDIT_RECEIVERS',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'DELETE_CREDIT_RECEIVERS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
END delete_credit_receivers;

-- API name                      : create_billing_assignments
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
-- p_billing_extension_id    IN    NUMBER   REQUIRED
-- p_amount                    IN    NUMBER     REQUIRED
-- p_percent                   IN    NUMBER     REQUIRED
-- p_active                    IN    VARCHAR2   OPTIONAL   DEFAULT=FND_API.G_MISS_CHAR
-- x_billing_assignment_id     OUT   NUMBER     REQUIRED
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
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_commit	         	 IN	 VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_validate_only	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
 p_validation_level	 IN	 NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
 p_calling_module	 	 IN 	 VARCHAR2   DEFAULT 'SELF_SERVICE',
 p_debug_mode	       IN	 VARCHAR2   DEFAULT 'N',
 p_max_msg_count	 	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_project_id	       IN	 NUMBER    ,
 p_task_id	         	 IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_billing_extension_id  IN    NUMBER   ,
 p_amount                IN    NUMBER      DEFAULT FND_API.G_MISS_NUM,
 p_percent               IN    NUMBER      DEFAULT FND_API.G_MISS_NUM,
 p_active                IN    VARCHAR2    ,
 x_billing_assignment_id     OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status	       OUT 	 NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_msg_count	       OUT 	 NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
 x_msg_data	             OUT 	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS
  l_api_name                CONSTANT VARCHAR(30) := 'create_billing_assignments';
  l_api_version             CONSTANT NUMBER      := 1.0;

  l_return_status                    VARCHAR2(1);
  l_msg_data                         VARCHAR2(250);
  l_msg_count                        NUMBER;

  l_dummy_char                       VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;

  l_task_id	           NUMBER;
  l_amount             NUMBER;
  l_percent            NUMBER;

BEGIN

   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('create_billing_assignments PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT billing_assignments;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('create_billing_assignments PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SETUP_PUB.create_billing_assignments');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := 'S';

   IF p_validate_only = FND_API.G_TRUE AND p_validation_level > 0
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

       PA_BILLING_SETUP_PVT.create_billing_assignments(
                                  p_commit	         	 =>    FND_API.G_FALSE,
                                  p_validate_only	 	 =>    p_validate_only,
                                  p_validation_level	       =>    p_validation_level,
                                  p_calling_module	 	 =>    p_calling_module,
                                  p_debug_mode	             =>    p_debug_mode,
                                  p_max_msg_count	 	 =>    p_max_msg_count,
                                  p_project_id	             =>    p_project_id,
                                  p_task_id	         	 =>    l_task_id,
                                  p_billing_extension_id     =>    p_billing_extension_id,
                                  x_billing_assignment_id    =>    x_billing_assignment_id,
                                  p_amount                   =>    l_amount ,
                                  p_percent                  =>    l_percent,
                                  p_active                   =>    p_active,
                                  x_return_status	       =>    l_return_status,
                                  x_msg_count	             =>    l_msg_count,
                                  x_msg_data	             =>    l_msg_data
                                );
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('CREATEE BILLING ASSIGNMENTS PUB : checking message count');
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
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'create_billing_assignments',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'create_billing_assignments',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));

       x_billing_assignment_id := null;

       RAISE;

END create_billing_assignments;


-- API name                      : update_billing_assignments
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
-- p_billing_extension_id    IN    NUMBER   REQUIRED
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
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
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
  l_api_name                CONSTANT VARCHAR(30) := 'update_billing_assignments';
  l_api_version             CONSTANT NUMBER      := 1.0;

  l_return_status                    VARCHAR2(1);
  l_msg_data                         VARCHAR2(250);
  l_msg_count                        NUMBER;

  l_dummy_char                       VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;

  l_task_id	           NUMBER;
  l_amount             NUMBER;
  l_percent            NUMBER;

BEGIN

   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('update_billing_assignments PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT billing_assignments;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('update_billing_assignments PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SETUP_PUB.update_billing_assignments');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := 'S';

   IF p_validate_only = FND_API.G_TRUE AND p_validation_level > 0
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

       PA_BILLING_SETUP_PVT.update_billing_assignments(
                                  p_commit	         	 =>    FND_API.G_FALSE,
                                  p_validate_only	 	 =>    p_validate_only,
                                  p_validation_level	       =>    p_validation_level,
                                  p_calling_module	 	 =>    p_calling_module,
                                  p_debug_mode	             =>    p_debug_mode,
                                  p_max_msg_count	 	 =>    p_max_msg_count,
                                  p_project_id	             =>    p_project_id,
                                  p_task_id	         	 =>    l_task_id,
                                  p_billing_extension_id     =>    p_billing_extension_id,
                                  p_billing_assignment_id     =>   p_billing_assignment_id,
                                  p_record_version_number    =>    p_record_version_number,
                                  p_amount                   =>    l_amount ,
                                  p_percent                  =>    l_percent,
                                  p_active                   =>    p_active,
                                  x_return_status	       =>    l_return_status,
                                  x_msg_count	             =>    l_msg_count,
                                  x_msg_data	             =>    l_msg_data
                                );
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('UPDATE BILLING ASSIGNMENTS PUB : checking message count');
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
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'update_billing_assignments',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'update_billing_assignments',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
END update_billing_assignments;


-- API name                      : delete_billing_assignments
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
-- p_billing_extension_id    IN    NUMBER   REQUIRED
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
 p_api_version	       IN	 NUMBER     DEFAULT 1.0,
 p_init_msg_list	 	 IN	 VARCHAR2   DEFAULT FND_API.G_TRUE,
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
  l_api_name                CONSTANT VARCHAR(30) := 'delete_billing_assignments';
  l_api_version             CONSTANT NUMBER      := 1.0;

  l_return_status                    VARCHAR2(1);
  l_msg_data                         VARCHAR2(250);
  l_msg_count                        NUMBER;

  l_dummy_char                       VARCHAR2(1);
  l_error_msg_code                   VARCHAR2(250);
  l_data                             VARCHAR2(250);
  l_msg_index_out                    NUMBER;

  l_task_id	           NUMBER;
  l_amount             NUMBER;
  l_percent            NUMBER;

BEGIN

   -- Standard call to check for call compatibility

   IF (p_debug_mode = 'Y')
   THEN
       pa_debug.debug('delete_billing_assignments PUB : Checking the api version number.');
   END IF;

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT billing_assignments;
   END IF;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('delete_billing_assignments PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_BILLING_SETUP_PUB.delete_billing_assignments');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := 'S';

   IF p_validate_only = FND_API.G_TRUE AND p_validation_level > 0
   THEN
       IF p_task_id = FND_API.G_MISS_NUM
       THEN
          l_task_id := null;
       ELSE
          l_task_id := p_task_id;
       END IF;

       PA_BILLING_SETUP_PVT.delete_billing_assignments(
                                  p_commit	         	 =>    FND_API.G_FALSE,
                                  p_validate_only	 	 =>    p_validate_only,
                                  p_validation_level	       =>    p_validation_level,
                                  p_calling_module	 	 =>    p_calling_module,
                                  p_debug_mode	             =>    p_debug_mode,
                                  p_max_msg_count	 	 =>    p_max_msg_count,
                                  p_project_id	             =>    p_project_id,
                                  p_task_id	         	 =>    l_task_id,
                                  p_billing_extension_id     =>    p_billing_extension_id,
                                  p_billing_assignment_id     =>    p_billing_assignment_id,
                                  p_record_version_number    =>    p_record_version_number,
                                  x_return_status	       =>    l_return_status,
                                  x_msg_count	             =>    l_msg_count,
                                  x_msg_data	             =>    l_msg_data
                                );
   END IF;

   if (p_debug_mode = 'Y') then
       pa_debug.debug('DELETE BILLING ASSIGNMENTS PUB : checking message count');
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
          ROLLBACK TO billing_assignments;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'delete_billing_assignments',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_BILLING_SETUP_PUB',
                               p_procedure_name => 'delete_billing_assignments',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
END delete_billing_assignments;

END PA_BILLING_SETUP_PUB;

/
