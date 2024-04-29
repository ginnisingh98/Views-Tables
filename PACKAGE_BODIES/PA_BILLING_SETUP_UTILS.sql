--------------------------------------------------------
--  DDL for Package Body PA_BILLING_SETUP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_SETUP_UTILS" AS
/* $Header: PABLSTUB.pls 120.3 2005/08/19 16:16:52 mwasowic noship $ */


-- API name                      : Validate_Retn_Inv_Format
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_retention_inv_format_id   IN    NUMBER     OPTIONAL  DEFAULT FND_API.G_MISS_NUM
-- p_retention_inv_format_name IN    VARCHAR2   OPTIONAL  DEFAULT FND_API.G_MISS_CHAR
-- p_check_id                  IN    VARCHAR2   REQUIRED  DEFAULT 'A'
-- x_retention_inv_format_id   OUT   NUMBER     REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Validate_Retn_Inv_Format(
 p_retention_inv_format_id   IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_retention_inv_format_name IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_check_id_flag             IN    VARCHAR2   DEFAULT 'A',
 x_retention_inv_format_id   OUT   NOCOPY NUMBER     , --File.Sql.39 bug 4440895
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
) AS

   l_current_id       NUMBER     := NULL;
   l_num_ids          NUMBER     := 0;
   l_id_found_flag    VARCHAR(1) := 'N';

   CURSOR c_ids
   IS
         SELECT invoice_format_id
           FROM pa_invoice_formats
          WHERE name = p_retention_inv_format_name;

BEGIN
    IF p_retention_inv_format_id IS NOT NULL
    THEN
       IF p_check_id_flag = 'Y'
       THEN
          SELECT invoice_format_id
            INTO x_retention_inv_format_id
            FROM pa_invoice_formats
           WHERE invoice_format_id = p_retention_inv_format_id;
       ELSIF p_check_id_flag = 'N'
       THEN
           x_retention_inv_format_id := p_retention_inv_format_id;
       ELSIF p_check_id_flag = 'A'
       THEN
           IF (p_retention_inv_format_name IS NULL) THEN
              -- Return a null ID since the name is null.
              x_retention_inv_format_id := NULL;
           ELSE
              -- Find the ID which matches the Name passed
              OPEN c_ids;
              LOOP
                  FETCH c_ids INTO l_current_id;
                  EXIT WHEN c_ids%NOTFOUND;
                  IF (l_current_id = p_retention_inv_format_id) THEN
                      l_id_found_flag := 'Y';
                      x_retention_inv_format_id := p_retention_inv_format_id;
                  END IF;
              END LOOP;
              l_num_ids := c_ids%ROWCOUNT;
              CLOSE c_ids;
              IF (l_num_ids = 0) THEN
                  -- No IDs for name
                  RAISE NO_DATA_FOUND;
              ELSIF (l_num_ids = 1) THEN
                  -- Since there is only one ID for the name use it.
                  x_retention_inv_format_id := l_current_id;
              ELSIF (l_id_found_flag = 'N') THEN
                  -- More than one ID for the name and none of the IDs matched
                  -- the ID passed in.
                  RAISE TOO_MANY_ROWS;
              END IF;
           END IF;
       END IF;
    ELSE
       IF p_retention_inv_format_name IS NOT NULL
       THEN
         SELECT invoice_format_id
           INTO x_retention_inv_format_id
           FROM pa_invoice_formats
          WHERE name = p_retention_inv_format_name;
       ELSE
          x_retention_inv_format_id := null;
       END IF;
    END IF;
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_retention_inv_format_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_INV_INVOI_FORMAT_ID';

         /* ATG NOCOPY */
         x_retention_inv_format_id := null;

       WHEN too_many_rows THEN
         x_retention_inv_format_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_TOO_MANY_INV_FMT_ID';
         /* ATG NOCOPY */
         x_retention_inv_format_id := null;
       WHEN OTHERS THEN
         x_retention_inv_format_id := null;
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         /* ATG NOCOPY */
         x_retention_inv_format_id := null;
         RAISE;
END Validate_Retn_Inv_Format;

-- API name                      : Duplicate_credit_receivers
-- Type                          : Utility Function
-- Pre-reqs                      : None
-- Return Value                  : BOOLEAN
-- Prameters
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER   REQUIRED
-- p_effective_from_date       IN    DATE       REQUIRED
-- p_effective_to_date           IN    DATE     REQUIRED  ,
-- p_credit_receiver_id          IN    NUMBER   REQUIRED,
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION  Duplicate_credit_receivers(
 p_project_id	         	 IN	 NUMBER     ,
 p_task_id	         	       IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_credit_type                 IN    VARCHAR2 ,
 p_person_id                   IN    NUMBER   ,
 p_effective_from_date         IN    DATE       ,
 p_effective_to_date           IN    DATE       ,
 p_credit_receiver_id          IN    NUMBER,
 x_return_status	             OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
 ) RETURN BOOLEAN AS
   CURSOR cur_cr
   IS
     SELECT 'X'
       FROM pa_credit_receivers
      WHERE project_id = p_project_id
        AND credit_type_code  = p_credit_type
        AND person_id         = p_person_id
        AND NVL( TASK_ID, -1 ) = DECODE( p_task_id, NULL, -1, p_task_id )
        AND (p_effective_from_date BETWEEN START_DATE_ACTIVE AND NVL(END_DATE_ACTIVE, p_effective_from_date + 1)
             OR  p_effective_to_date BETWEEN START_DATE_ACTIVE AND NVL(END_DATE_ACTIVE, p_effective_to_date + 1)
             OR  START_DATE_ACTIVE BETWEEN p_effective_from_date AND NVL(p_effective_to_date, START_DATE_ACTIVE + 1))
        AND ( p_credit_receiver_id IS NULL OR credit_receiver_id <> p_credit_receiver_id );
   l_dummy_char     VARCHAR2(1);
BEGIN
   OPEN cur_cr;
   FETCH cur_cr INTO l_dummy_char;
   IF cur_cr%NOTFOUND
   THEN
      CLOSE cur_cr;
      RETURN FALSE;
   ELSE
      CLOSE cur_cr;
      RETURN TRUE;
   END IF;
   x_return_status:= FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN OTHERS THEN
        x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;
END Duplicate_credit_receivers;


-- API name                      : Duplicate_billing_assignments
-- Type                          : Utility Function
-- Pre-reqs                      : None
-- Return Value                  : BOOLEAN
-- Prameters
-- p_project_id	         	 IN	 NUMBER     REQUIRED
-- p_task_id	         	 IN	 NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_billing_extension_id      IN   VARCHAR2    REQUIRED
-- p_billing_assignment_id     IN    NUMBER     REQUIRED
-- p_active_flag               IN    VARCHAR2   REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION  Duplicate_billing_assignments(
 p_project_id	         	 IN	 NUMBER     ,
 p_task_id	         	       IN	 NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_billing_extension_id        IN    NUMBER,
 p_billing_assignment_id       IN    NUMBER,
 p_active_flag                 IN    VARCHAR2,
 x_return_status	             OUT 	 NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
 ) RETURN BOOLEAN AS
   CURSOR cur_ba
   IS
     SELECT 'X'
       FROM pa_billing_assignments_all
      WHERE project_id = p_project_id
        AND NVL( active_flag , 'N' )   = 'Y'
        AND NVL( p_active_flag, 'N' )  = 'Y'
        AND NVL( top_task_id, -1 ) = DECODE( p_task_id, NULL, -1, p_task_id )
        AND billing_extension_id  = p_billing_extension_id
        AND ( p_billing_assignment_id IS NULL OR billing_assignment_id <> p_billing_assignment_id );


   l_dummy_char     VARCHAR2(1);
BEGIN

   OPEN cur_ba;
   FETCH cur_ba INTO l_dummy_char;
   IF cur_ba%NOTFOUND
   THEN
      CLOSE cur_ba;
      RETURN FALSE;
   ELSE
      CLOSE cur_ba;
      RETURN TRUE;
   END IF;
   x_return_status:= FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN OTHERS THEN
        x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;
END Duplicate_billing_assignments;


-- API name                      : VALIDATE_PERSON_ID_NAME
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_person_id                 IN    NUMBER     OPTIONAL  DEFAULT FND_API.G_MISS_NUM
-- p_person_name               IN    VARCHAR2   OPTIONAL  DEFAULT FND_API.G_MISS_CHAR
-- p_check_id                  IN    VARCHAR2   REQUIRED  DEFAULT 'A'
-- x_person_id   OUT   NUMBER     REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  VALIDATE_PERSON_ID_NAME(
 p_person_id                 IN    NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_person_name               IN    VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 p_check_id_flag             IN    VARCHAR2   DEFAULT 'A',
 x_person_id                 OUT   NOCOPY NUMBER     , --File.Sql.39 bug 4440895
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
) AS

   l_current_id       NUMBER     := NULL;
   l_num_ids          NUMBER     := 0;
   l_id_found_flag    VARCHAR(1) := 'N';

   CURSOR c_ids
   IS
          SELECT person_id
            FROM pa_employees
           WHERE full_name = p_person_name;


BEGIN
    IF p_person_id IS NOT NULL
    THEN
       IF p_check_id_flag = 'Y'
       THEN
          SELECT person_id
            INTO x_person_id
            FROM pa_employees
           WHERE person_id = p_person_id;
       ELSIF p_check_id_flag = 'N'
       THEN
           x_person_id := p_person_id;
       ELSIF p_check_id_flag = 'A'
       THEN
           IF (p_person_name IS NULL) THEN
              -- Return a null ID since the name is null.
              x_person_id := NULL;
           ELSE
              -- Find the ID which matches the Name passed
              OPEN c_ids;
              LOOP
                  FETCH c_ids INTO l_current_id;
                  EXIT WHEN c_ids%NOTFOUND;
                  IF (l_current_id = p_person_id) THEN
                      l_id_found_flag := 'Y';
                      x_person_id := p_person_id;
                  END IF;
              END LOOP;
              l_num_ids := c_ids%ROWCOUNT;
              CLOSE c_ids;
              IF (l_num_ids = 0) THEN
                  -- No IDs for name
                  RAISE NO_DATA_FOUND;
              ELSIF (l_num_ids = 1) THEN
                  -- Since there is only one ID for the name use it.
                  x_person_id := l_current_id;
              ELSIF (l_id_found_flag = 'N') THEN
                  -- More than one ID for the name and none of the IDs matched
                  -- the ID passed in.
                  RAISE TOO_MANY_ROWS;
              END IF;
           END IF;
       END IF;
    ELSE
       IF p_person_name IS NOT NULL
       THEN
          SELECT person_id
            INTO x_person_id
            FROM pa_employees
           WHERE full_name = p_person_name;
       ELSE
          x_person_id := null;
       END IF;
    END IF;
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_person_id  := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_INVALID_PERSON_ID';
         /* ATG NOCOPY */
         x_person_id := null;
       WHEN too_many_rows THEN
         x_person_id  := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_TOO_MANY_PERSON_ID';
         /* ATG NOCOPY */
         x_person_id := null;
       WHEN OTHERS THEN
         x_person_id  := null;
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         /* ATG NOCOPY */
         x_person_id := null;
         RAISE;
END VALIDATE_PERSON_ID_NAME;


-- API name                      : Get_Next_Billing_Date
-- Type                          : Utility Function
-- Pre-reqs                      : None
-- Return Value                  : DATE
-- Prameters
-- p_project_id                IN    NUMBER
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION  Get_Next_Billing_Date(
 p_project_id                IN    NUMBER,
 x_return_status	           OUT 	 NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
) RETURN DATE AS

  CURSOR cur_projects_all
  IS
    SELECT start_date, billing_cycle_id, billing_offset
      FROM pa_projects_all
     WHERE project_id = p_project_id;

 l_start_date        DATE;
 l_billing_cycle_id  NUMBER;
 l_billing_offset    NUMBER;
 l_next_billing_date DATE;
BEGIN

     OPEN cur_projects_all;
     FETCH cur_projects_all INTO l_start_date, l_billing_cycle_id, l_billing_offset;
     CLOSE cur_projects_all;
     l_next_billing_date := Pa_Billing_Cycles_pkg.Get_Next_billing_Date(
                                        p_project_id,
                                        l_start_date,
                                        l_billing_cycle_id,
                                        l_billing_offset,
                                        null,
                                        null );
    RETURN l_next_billing_date;

    x_return_status:= FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Get_Next_Billing_Date;


-- API name                      : REV_BILL_INF_REQ_CHECK
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_type_class_code   IN    VARCHAR2   REQUIRED
-- p_distribution_rule         IN    VARCHAR2   REQUIRED
-- p_billing_cycle_id          IN    NUMBER     REQUIRED
-- p_first_bill_offset         IN    NUMBER     REQUIRED
-- p_billing_job_group_id         IN    NUMBER  REQUIRED
-- p_labor_id                    IN    NUMBER   REQUIRED
-- p_non_labor_id                 IN    NUMBER  REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  REV_BILL_INF_REQ_CHECK(
 p_project_type_class_code   IN    VARCHAR2   ,
 p_distribution_rule         IN    VARCHAR2   ,
 p_billing_cycle_id          IN    NUMBER     ,
 p_first_bill_offset         IN    NUMBER     ,
 p_billing_job_group_id      IN    NUMBER  ,
 p_labor_id                  IN    NUMBER   ,
 p_non_labor_id              IN    NUMBER  ,
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
) AS
BEGIN
     x_return_status:= FND_API.G_RET_STS_SUCCESS;
     IF p_project_type_class_code = 'CONTRACT'
     THEN
        IF p_distribution_rule IS NULL OR p_distribution_rule = FND_API.G_MISS_CHAR
        THEN
           x_error_msg_code := 'PA_PRJ_DIST_RULE_REQ';
           x_return_status:= FND_API.G_RET_STS_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF p_billing_cycle_id IS NULL OR p_billing_cycle_id = FND_API.G_MISS_NUM
        THEN
           x_error_msg_code := 'PA_PRJ_BILLING_CYCLE_REQ';
           x_return_status:= FND_API.G_RET_STS_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF p_first_bill_offset IS NULL OR p_first_bill_offset = FND_API.G_MISS_NUM
        THEN
           x_error_msg_code := 'PA_PRJ_BILL_OFFSET_REQ';
           x_return_status:= FND_API.G_RET_STS_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF p_billing_job_group_id IS NULL OR p_billing_job_group_id = FND_API.G_MISS_NUM
        THEN
           x_error_msg_code := 'PA_PRJ_BILL_JOB_GROUP_REQ';
           x_return_status:= FND_API.G_RET_STS_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF p_labor_id IS NULL OR p_labor_id = FND_API.G_MISS_NUM
        THEN
           x_error_msg_code := 'PA_PRJ_LBR_INV_FORMAT_REQ';
           x_return_status:= FND_API.G_RET_STS_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF p_non_labor_id IS NULL OR p_non_labor_id = FND_API.G_MISS_NUM
        THEN
           x_error_msg_code := 'PA_PRJ_NL_INV_FORMAT_REQ';
           x_return_status:= FND_API.G_RET_STS_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;

     END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
END REV_BILL_INF_REQ_CHECK;


-- API name                      : BILL_XTENSION_REQ_CHECK
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_billing_extension_id      IN    NUMBER     REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  BILL_XTENSION_REQ_CHECK(
 p_billing_extension_id      IN    NUMBER    ,
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
) IS
BEGIN
     x_return_status:= FND_API.G_RET_STS_SUCCESS;
     IF p_billing_extension_id IS NULL OR p_billing_extension_id = FND_API.G_MISS_NUM
     THEN
         x_error_msg_code := 'PA_PRJ_BILL_XTENSION_REQ';
         x_return_status:= FND_API.G_RET_STS_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
     END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
END BILL_XTENSION_REQ_CHECK;


-- API name                      : VALIDATE_EMP_NO_TO_ID
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_person_id                 IN   NUMBER     DEFAULT FND_API.G_MISS_NUM,
-- p_emp_number                IN    VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
-- p_check_id                  IN    VARCHAR2   REQUIRED  DEFAULT 'A'
-- x_person_id                 OUT   NUMBER     ,
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  VALIDATE_EMP_NO_TO_ID(
 p_person_id                 IN   NUMBER      DEFAULT FND_API.G_MISS_NUM,
 p_emp_number                IN    VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
 p_check_id_flag                  IN    VARCHAR2   DEFAULT 'A',
 x_person_id                 OUT   NOCOPY NUMBER     , --File.Sql.39 bug 4440895
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
) IS
   l_current_id       NUMBER     := NULL;
   l_num_ids          NUMBER     := 0;
   l_id_found_flag    VARCHAR(1) := 'N';

   CURSOR c_ids
   IS
          SELECT person_id
            FROM pa_employees
           WHERE employee_number = p_emp_number;

BEGIN
    IF p_person_id IS NOT NULL
    THEN
       IF p_check_id_flag = 'Y'
       THEN
          SELECT person_id
            INTO x_person_id
            FROM pa_employees
           WHERE person_id = p_person_id;
       ELSIF p_check_id_flag = 'N'
       THEN
           x_person_id := p_person_id;
       ELSIF p_check_id_flag = 'A'
       THEN
           IF (p_emp_number IS NULL) THEN
              -- Return a null ID since the name is null.
              x_person_id := NULL;
           ELSE
              -- Find the ID which matches the Name passed
              OPEN c_ids;
              LOOP
                  FETCH c_ids INTO l_current_id;
                  EXIT WHEN c_ids%NOTFOUND;
                  IF (l_current_id = p_person_id) THEN
                      l_id_found_flag := 'Y';
                      x_person_id := p_person_id;
                  END IF;
              END LOOP;
              l_num_ids := c_ids%ROWCOUNT;
              CLOSE c_ids;
              IF (l_num_ids = 0) THEN
                  -- No IDs for name
                  RAISE NO_DATA_FOUND;
              ELSIF (l_num_ids = 1) THEN
                  -- Since there is only one ID for the name use it.
                  x_person_id := l_current_id;
              ELSIF (l_id_found_flag = 'N') THEN
                  -- More than one ID for the name and none of the IDs matched
                  -- the ID passed in.
                  RAISE TOO_MANY_ROWS;
              END IF;
           END IF;
       END IF;
    ELSE
       IF p_emp_number IS NOT NULL
       THEN
          SELECT person_id
            INTO x_person_id
            FROM pa_employees
           WHERE employee_number = p_emp_number;
       ELSE
          x_person_id := null;
       END IF;
    END IF;
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_person_id  := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_INVALID_PERSON_ID';
         /* ATG NOCOPY */
          x_person_id := null;
       WHEN too_many_rows THEN
         x_person_id  := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_TOO_MANY_PERSON_ID';
         /* ATG NOCOPY */
          x_person_id := null;
       WHEN OTHERS THEN
         x_person_id  := null;
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         x_error_msg_code  := 'Error in VALIDATE_EMP_NO_TO_ID';
         /* ATG NOCOPY */
          x_person_id := null;
         RAISE;
END VALIDATE_EMP_NO_TO_ID;


-- API name                      : VALIDATE_EMP_NO_NAME
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_person_id                 IN   NUMBER     OPTIONAL DEFAULT FND_API.G_MISS_NUM,
-- p_person_name               IN   VARCHAR2   OPTIONAL DEFAULT FND_API.G_MISS_CHAR,
-- p_emp_number                IN    VARCHAR2    OPTIONAL DEFAULT FND_API.G_MISS_CHAR,
-- p_check_id                  IN    VARCHAR2  REQUIRED DEFAULT 'A'
-- x_person_id                 OUT   NUMBER
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  VALIDATE_EMP_NO_NAME(
 p_person_id                 IN   NUMBER     DEFAULT FND_API.G_MISS_NUM,
 p_person_name               IN   VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
 p_emp_number                IN    VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
 p_check_id                  IN    VARCHAR2   DEFAULT 'A',
 x_person_id                 OUT   NOCOPY NUMBER     , --File.Sql.39 bug 4440895
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
) IS
   l_person_id        NUMBER;
   l_error_msg_code   VARCHAR2(250);
   l_return_status    VARCHAR2(1);
   l_person_id2        NUMBER;


BEGIN
     x_return_status:= FND_API.G_RET_STS_SUCCESS;
     IF ( p_person_name IS NOT NULL AND p_person_name <> FND_API.G_MISS_CHAR ) AND
        ( p_emp_number IS NOT NULL AND p_emp_number <> FND_API.G_MISS_CHAR )
     THEN
        PA_BILLING_SETUP_UTILS.Validate_person_id_name
           ( p_person_id               => p_person_id
            ,p_person_name             => p_person_name
            ,p_check_id_flag           => 'A'
            ,x_person_id               => l_person_id
            ,x_return_status           => l_return_status
            ,x_error_msg_code          => l_error_msg_code);


        l_person_id2 := l_person_id;

        PA_BILLING_SETUP_UTILS.VALIDATE_EMP_NO_TO_ID
           ( p_person_id               => p_person_id
            ,p_emp_number              => p_emp_number
            ,p_check_id_flag           => 'A'
            ,x_person_id               => l_person_id
            ,x_return_status           => l_return_status
            ,x_error_msg_code          => l_error_msg_code);

        IF l_person_id2 <> l_person_id
        THEN
           x_error_msg_code := 'PA_PRJ_INV_EMP_NO_NAME';
           x_return_status:= FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

     ELSIF ( p_person_id IS NOT NULL AND p_person_id <> FND_API.G_MISS_NUM ) OR
           ( p_person_name IS NOT NULL AND p_person_name <> FND_API.G_MISS_CHAR )
     THEN
        PA_BILLING_SETUP_UTILS.Validate_person_id_name
           ( p_person_id               => p_person_id
            ,p_person_name             => p_person_name
            ,p_check_id_flag           => 'A'
            ,x_person_id               => l_person_id
            ,x_return_status           => l_return_status
            ,x_error_msg_code          => l_error_msg_code);
     ELSIF ( p_person_id IS NOT NULL AND p_person_id <> FND_API.G_MISS_NUM ) OR
           ( p_emp_number IS NOT NULL AND p_emp_number <> FND_API.G_MISS_CHAR )
     THEN
        PA_BILLING_SETUP_UTILS.VALIDATE_EMP_NO_TO_ID
           ( p_person_id               => p_person_id
            ,p_emp_number              => p_emp_number
            ,p_check_id_flag           => 'A'
            ,x_person_id               => l_person_id
            ,x_return_status           => l_return_status
            ,x_error_msg_code          => l_error_msg_code);

     END IF;
     x_person_id := l_person_id;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    x_error_msg_code  := 'Error in VALIDATE_EMP_NO_NAME';
         /* ATG NOCOPY */
          x_person_id := null;
    WHEN OTHERS THEN
    x_error_msg_code  := 'Error in VALIDATE_EMP_NO_NAME';
         /* ATG NOCOPY */
          x_person_id := null;
END VALIDATE_EMP_NO_NAME;


-- API name                      : CREDIT_REC_REQ_CHECK
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_credit_type               IN    VARCHAR2   REQUIRED
-- p_person_id                 IN    NUMBER     REQUIRED
-- p_transfer_to_AR            IN    VARCHAR2   REQUIRED
-- p_effective_from_date       IN    DATE       REQUIRED
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  CREDIT_REC_REQ_CHECK(
 p_credit_type               IN    VARCHAR2 ,
 p_person_id                 IN    NUMBER,
 p_transfer_to_AR            IN    VARCHAR2,
 p_effective_from_date       IN    DATE,
 x_return_status	           OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
) AS
BEGIN
     x_return_status:= FND_API.G_RET_STS_SUCCESS;
     IF p_credit_type IS NULL OR p_credit_type = FND_API.G_MISS_CHAR
     THEN
         x_error_msg_code := 'PA_PRJ_CREDIT_TYPE_REQ';
         x_return_status:= FND_API.G_RET_STS_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
     END IF;

     IF p_person_id IS NULL OR p_person_id = FND_API.G_MISS_NUM
     THEN
         x_error_msg_code := 'PA_PRJ_EMP_NO_NAME_REQ';
         x_return_status:= FND_API.G_RET_STS_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
     END IF;

     IF p_transfer_to_AR IS NULL OR p_transfer_to_AR = FND_API.G_MISS_CHAR
     THEN
         x_error_msg_code := 'PA_PRJ_XFER_TO_AR_FLG_REQ';
         x_return_status:= FND_API.G_RET_STS_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
     END IF;

     IF p_effective_from_date IS NULL OR p_effective_from_date = FND_API.G_MISS_DATE
     THEN
         x_error_msg_code := 'PRJ_PA_ST_DT_REQ';
         x_return_status:= FND_API.G_RET_STS_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
     END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
END CREDIT_REC_REQ_CHECK;

-- API name                      : GET_SALES_CREDIT_FLAG
-- Type                          : Utility Function
-- Pre-reqs                      : None
-- Return Value                  : VARCHAR2( 'Y', 'N' )
-- Prameters
-- x_return_status	       OUT 	 VARCHAR2   REQUIRED
--
--  History
--
--  21-JUN-01   Majid Ansari             -Created
--
--

 FUNCTION  GET_SALES_CREDIT_FLAG(
 x_return_status	           OUT 	 NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
) RETURN VARCHAR2 AS

    CURSOR sales_crdt_flag
    IS
    SELECT NVL(ALLOW_SALES_CREDIT_FLAG, 'N') ALLOW_SALES_CREDIT_FLAG
       FROM RA_BATCH_SOURCES R,
            PA_IMPLEMENTATIONS S
      WHERE R.BATCH_SOURCE_ID  = S.INVOICE_BATCH_SOURCE_ID ;

    l_ALLOW_SALES_CREDIT_FLAG VARCHAR2(1);
BEGIN
    x_return_status:= FND_API.G_RET_STS_SUCCESS;

    OPEN sales_crdt_flag;
    FETCH sales_crdt_flag INTO l_ALLOW_SALES_CREDIT_FLAG;
    CLOSE sales_crdt_flag;

    RETURN NVL( l_ALLOW_SALES_CREDIT_FLAG, 'N' );

EXCEPTION
    WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
END GET_SALES_CREDIT_FLAG;



END PA_BILLING_SETUP_UTILS;

/
