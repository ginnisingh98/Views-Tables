--------------------------------------------------------
--  DDL for Package Body PA_BILLING_SCHEDULE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_SCHEDULE_UTILS" AS
/* $Header: PABLINUB.pls 120.3 2005/08/19 16:16:26 mwasowic noship $ */

-- API name                      : Emp_bill_rate_sch_name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_emp_bill_rate_id	    	IN	NUMBER	OPTIONAL   DEFAULT FND_API.G_MISS_NUM
-- p_emp_bill_rate_name		IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_check_id_flag		IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- x_ emp_bill_rate_id		OUT 	NUMBER	REQUIRED
-- x_return_status		OUT	VARCHAR2	REQUIRED
-- x_error_msg_code		OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Emp_bill_rate_sch_name_To_Id(
   p_emp_bill_rate_id	    	IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_emp_bill_rate_name		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_check_id_flag		IN	VARCHAR2	DEFAULT 'A',
   x_emp_bill_rate_id		OUT 	NOCOPY NUMBER	, --File.Sql.39 bug 4440895
   x_return_status		OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code		OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 ) IS

   l_current_id       NUMBER     := NULL;
   l_num_ids          NUMBER     := 0;
   l_id_found_flag    VARCHAR(1) := 'N';

   CURSOR c_ids
   IS
     SELECT brs.bill_rate_sch_id
       FROM pa_std_bill_rate_schedules brs, pa_lookups l
      WHERE brs.schedule_type = 'EMPLOYEE'
        AND brs.std_bill_rate_schedule = p_emp_bill_rate_name
        AND l.lookup_type = 'SCHEDULE TYPE'
        AND l.lookup_code (+) = brs.schedule_type;

BEGIN

    IF p_emp_bill_rate_id IS NOT NULL
    THEN
       IF p_check_id_flag = 'Y'
       THEN
          SELECT brs.bill_rate_sch_id
            INTO x_emp_bill_rate_id
            FROM pa_std_bill_rate_schedules brs, pa_lookups l
           WHERE brs.schedule_type = 'EMPLOYEE'
             AND brs.bill_rate_sch_id = p_emp_bill_rate_id
             AND l.lookup_type = 'SCHEDULE TYPE'
             AND l.lookup_code (+) = brs.schedule_type;
       ELSIF p_check_id_flag = 'N'
       THEN
           x_emp_bill_rate_id := p_emp_bill_rate_id;
       ELSIF p_check_id_flag = 'A'
       THEN
           IF (p_emp_bill_rate_name IS NULL) THEN
              -- Return a null ID since the name is null.
              x_emp_bill_rate_id := NULL;
           ELSE
              -- Find the ID which matches the Name passed
              OPEN c_ids;
              LOOP
                  FETCH c_ids INTO l_current_id;
                  EXIT WHEN c_ids%NOTFOUND;
                  IF (l_current_id = p_emp_bill_rate_id) THEN
                      l_id_found_flag := 'Y';
                      x_emp_bill_rate_id := p_emp_bill_rate_id;
                  END IF;
              END LOOP;
              l_num_ids := c_ids%ROWCOUNT;
              CLOSE c_ids;
              IF (l_num_ids = 0) THEN
                  -- No IDs for name
                  RAISE NO_DATA_FOUND;
              ELSIF (l_num_ids = 1) THEN
                  -- Since there is only one ID for the name use it.
                  x_emp_bill_rate_id := l_current_id;
              ELSIF (l_id_found_flag = 'N') THEN
                  -- More than one ID for the name and none of the IDs matched
                  -- the ID passed in.
                  RAISE TOO_MANY_ROWS;
              END IF;
           END IF;
       END IF;
    ELSE
        IF p_emp_bill_rate_name IS NOT NULL
        THEN
            SELECT brs.bill_rate_sch_id
              INTO x_emp_bill_rate_id
              FROM pa_std_bill_rate_schedules brs, pa_lookups l
             WHERE brs.schedule_type = 'EMPLOYEE'
               AND brs.std_bill_rate_schedule = p_emp_bill_rate_name
               AND l.lookup_type = 'SCHEDULE TYPE'
               AND l.lookup_code (+) = brs.schedule_type;
        ELSE
            x_emp_bill_rate_id := null;
        END IF;
    END IF;
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_emp_bill_rate_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_INV_EMP_BR_SCH_ID';
       WHEN too_many_rows THEN
         x_emp_bill_rate_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_TOO_MANY_EMP_BR';
       WHEN OTHERS THEN
         x_emp_bill_rate_id := null;
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Emp_bill_rate_sch_name_To_Id;

-- API name                      : Job_bill_rate_sch_name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_job_bill_rate_id	    	IN	NUMBER	OPTIONAL   DEFAULT FND_API.G_MISS_NUM
-- p_job_bill_rate_name		IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_check_id_flag		IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- p_job_group_id	        IN	NUMBER	REQUIRED
-- x_job_bill_rate_id		OUT 	NUMBER	REQUIRED
-- x_return_status		OUT	VARCHAR2	REQUIRED
-- x_error_msg_code		OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  job_bill_rate_sch_name_To_Id(
   p_job_bill_rate_id	    	IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_job_bill_rate_name		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_check_id_flag		IN	VARCHAR2	DEFAULT 'A',
   p_job_group_id             IN    NUMBER ,
   x_job_bill_rate_id		OUT 	NOCOPY NUMBER,	 --File.Sql.39 bug 4440895
   x_return_status		OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code		OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 ) IS

   l_current_id       NUMBER     := NULL;
   l_num_ids          NUMBER     := 0;
   l_id_found_flag    VARCHAR(1) := 'N';

   CURSOR c_ids
   IS
     SELECT brs.bill_rate_sch_id
       FROM pa_std_bill_rate_schedules brs, pa_lookups l
      WHERE brs.schedule_type = 'JOB'
        AND brs.std_bill_rate_schedule = p_job_bill_rate_name
        AND brs.job_group_id = p_job_group_id
        AND l.lookup_type = 'SCHEDULE TYPE'
        AND l.lookup_code (+) = brs.schedule_type;

BEGIN

    IF p_job_bill_rate_id IS NOT NULL
    THEN
       IF p_check_id_flag = 'Y'
       THEN
          SELECT brs.bill_rate_sch_id
            INTO x_job_bill_rate_id
            FROM pa_std_bill_rate_schedules brs, pa_lookups l
           WHERE brs.schedule_type = 'JOB'
             AND brs.bill_rate_sch_id = p_job_bill_rate_id
             AND brs.job_group_id = p_job_group_id
             AND l.lookup_type = 'SCHEDULE TYPE'
             AND l.lookup_code (+) = brs.schedule_type;
       ELSIF p_check_id_flag = 'N'
       THEN
           x_job_bill_rate_id := p_job_bill_rate_id;
       ELSIF p_check_id_flag = 'A'
       THEN
           IF (p_job_bill_rate_name IS NULL) THEN
              -- Return a null ID since the name is null.
              x_job_bill_rate_id := NULL;
           ELSE
              -- Find the ID which matches the Name passed
              OPEN c_ids;
              LOOP
                  FETCH c_ids INTO l_current_id;
                  EXIT WHEN c_ids%NOTFOUND;
                  IF (l_current_id = p_job_bill_rate_id) THEN
                      l_id_found_flag := 'Y';
                      x_job_bill_rate_id := p_job_bill_rate_id;
                  END IF;
              END LOOP;
              l_num_ids := c_ids%ROWCOUNT;
              CLOSE c_ids;
              IF (l_num_ids = 0) THEN
                  -- No IDs for name
                  RAISE NO_DATA_FOUND;
              ELSIF (l_num_ids = 1) THEN
                  -- Since there is only one ID for the name use it.
                  x_job_bill_rate_id := l_current_id;
              ELSIF (l_id_found_flag = 'N') THEN
                  -- More than one ID for the name and none of the IDs matched
                  -- the ID passed in.
                  RAISE TOO_MANY_ROWS;
              END IF;
           END IF;
       END IF;
    ELSE
        IF p_job_bill_rate_name IS NOT NULL
        THEN
          SELECT brs.bill_rate_sch_id
            INTO x_job_bill_rate_id
            FROM pa_std_bill_rate_schedules brs, pa_lookups l
           WHERE brs.schedule_type = 'JOB'
             AND brs.std_bill_rate_schedule = p_job_bill_rate_name
             AND brs.job_group_id = p_job_group_id
             AND l.lookup_type = 'SCHEDULE TYPE'
             AND l.lookup_code (+) = brs.schedule_type;
        ELSE
           x_job_bill_rate_id  := null;
        END IF;
    END IF;
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_job_bill_rate_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_INV_JOB_BR_SCH_ID';
       WHEN too_many_rows THEN
         x_job_bill_rate_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_TOO_MANY_JOB_BR';
       WHEN OTHERS THEN
         x_job_bill_rate_id := null;
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Job_bill_rate_sch_name_To_Id;


-- API name                      : Rev_Sch_Name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_rev_sch_id	    	      IN	NUMBER	OPTIONAL   DEFAULT FND_API.G_MISS_NUM
-- p_rev_sch_name	      IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_check_id_flag	      IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- x_rev_sch_id		      OUT 	NUMBER	REQUIRED
-- x_return_status	      OUT	VARCHAR2	REQUIRED
-- x_error_msg_code	      OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Rev_Sch_Name_To_Id(
   p_rev_sch_id	    	      IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_rev_sch_name	            IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_check_id_flag	      IN	VARCHAR2	DEFAULT 'A',
   x_rev_sch_id		      OUT 	NOCOPY NUMBER	, --File.Sql.39 bug 4440895
   x_return_status	      OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code	      OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 ) IS

   l_current_id       NUMBER     := NULL;
   l_num_ids          NUMBER     := 0;
   l_id_found_flag    VARCHAR(1) := 'N';

   CURSOR c_ids
   IS
           SELECT irs.ind_rate_sch_id
             FROM pa_lookups l, pa_ind_rate_schedules irs
            WHERE l.lookup_type = 'IND RATE SCHEDULE TYPE'
              AND l.lookup_code = irs.ind_rate_schedule_type
              AND irs.project_id IS NULL
              AND trunc(sysdate) BETWEEN irs.start_date_active
                                 AND nvl(irs.end_date_active,trunc(sysdate+1))
              AND irs.ind_rate_sch_name = p_rev_sch_name ;

BEGIN
    IF p_rev_sch_id IS NOT NULL
    THEN
       IF p_check_id_flag = 'Y'
       THEN
           SELECT irs.ind_rate_sch_id
             INTO x_rev_sch_id
             FROM pa_lookups l, pa_ind_rate_schedules irs
            WHERE l.lookup_type = 'IND RATE SCHEDULE TYPE'
              AND l.lookup_code = irs.ind_rate_schedule_type
              AND irs.project_id IS NULL
              AND trunc(sysdate) BETWEEN irs.start_date_active
                                 AND nvl(irs.end_date_active,trunc(sysdate+1))
              AND irs.ind_rate_sch_id = p_rev_sch_id;

       ELSIF p_check_id_flag = 'N'
       THEN
           x_rev_sch_id := p_rev_sch_id;
       ELSIF p_check_id_flag = 'A'
       THEN
           IF (p_rev_sch_name IS NULL) THEN
              -- Return a null ID since the name is null.
              x_rev_sch_id := NULL;
           ELSE
              -- Find the ID which matches the Name passed
              OPEN c_ids;
              LOOP
                  FETCH c_ids INTO l_current_id;
                  EXIT WHEN c_ids%NOTFOUND;
                  IF (l_current_id = p_rev_sch_id) THEN
                      l_id_found_flag := 'Y';
                      x_rev_sch_id := p_rev_sch_id;
                  END IF;
              END LOOP;
              l_num_ids := c_ids%ROWCOUNT;
              CLOSE c_ids;
              IF (l_num_ids = 0) THEN
                  -- No IDs for name
                  RAISE NO_DATA_FOUND;
              ELSIF (l_num_ids = 1) THEN
                  -- Since there is only one ID for the name use it.
                  x_rev_sch_id := l_current_id;
              ELSIF (l_id_found_flag = 'N') THEN
                  -- More than one ID for the name and none of the IDs matched
                  -- the ID passed in.
                  RAISE TOO_MANY_ROWS;
              END IF;
           END IF;
       END IF;
    ELSE
        IF p_rev_sch_name IS NOT NULL
        THEN
           SELECT irs.ind_rate_sch_id
             INTO x_rev_sch_id
             FROM pa_lookups l, pa_ind_rate_schedules irs
            WHERE l.lookup_type = 'IND RATE SCHEDULE TYPE'
              AND l.lookup_code = irs.ind_rate_schedule_type
              AND irs.project_id IS NULL
              AND trunc(sysdate) BETWEEN irs.start_date_active
                                 AND nvl(irs.end_date_active,trunc(sysdate+1))
              AND irs.ind_rate_sch_name = p_rev_sch_name ;
        ELSE
           x_rev_sch_id  := null;
        END IF;
    END IF;
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_rev_sch_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_REV_SCHEDULE_ID';
       WHEN too_many_rows THEN
         x_rev_sch_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_TOO_MANY_REV_SCH';
       WHEN OTHERS THEN
         x_rev_sch_id := null;
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Rev_Sch_Name_To_Id;


-- API name                      : Inv_Sch_Name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_inv_sch_id	    	      IN	NUMBER	OPTIONAL   DEFAULT FND_API.G_MISS_NUM
-- p_inv_sch_name	      IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_check_id_flag            IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- x_inv_sch_id		      OUT 	NUMBER	REQUIRED
-- x_return_status	      OUT	VARCHAR2	REQUIRED
-- x_error_msg_code	      OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Inv_Sch_Name_To_Id(
   p_Inv_sch_id	    	      IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_Inv_sch_name	            IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_check_id_flag	      IN	VARCHAR2	DEFAULT 'A',
   x_Inv_sch_id		      OUT 	NOCOPY NUMBER	, --File.Sql.39 bug 4440895
   x_return_status	      OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code	      OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 ) IS

   l_current_id       NUMBER     := NULL;
   l_num_ids          NUMBER     := 0;
   l_id_found_flag    VARCHAR(1) := 'N';

   CURSOR c_ids
   IS
           SELECT irs.ind_rate_sch_id
             FROM pa_lookups l, pa_ind_rate_schedules irs
            WHERE l.lookup_type = 'IND RATE SCHEDULE TYPE'
              AND l.lookup_code = irs.ind_rate_schedule_type
              AND irs.project_id IS NULL
              AND trunc(sysdate) BETWEEN irs.start_date_active
                                 AND nvl(irs.end_date_active,trunc(sysdate+1))
              AND irs.ind_rate_sch_name = p_inv_sch_name ;

BEGIN
    IF p_inv_sch_id IS NOT NULL
    THEN
       IF p_check_id_flag = 'Y'
       THEN
           SELECT irs.ind_rate_sch_id
             INTO x_inv_sch_id
             FROM pa_lookups l, pa_ind_rate_schedules irs
            WHERE l.lookup_type = 'IND RATE SCHEDULE TYPE'
              AND l.lookup_code = irs.ind_rate_schedule_type
              AND irs.project_id IS NULL
              AND trunc(sysdate) BETWEEN irs.start_date_active
                                 AND nvl(irs.end_date_active,trunc(sysdate+1))
              AND irs.ind_rate_sch_id = p_inv_sch_id;

       ELSIF p_check_id_flag = 'N'
       THEN
           x_inv_sch_id := p_inv_sch_id;
       ELSIF p_check_id_flag = 'A'
       THEN
           IF (p_inv_sch_name IS NULL) THEN
              -- Return a null ID since the name is null.
              x_inv_sch_id := NULL;
           ELSE
              -- Find the ID which matches the Name passed
              OPEN c_ids;
              LOOP
                  FETCH c_ids INTO l_current_id;
                  EXIT WHEN c_ids%NOTFOUND;
                  IF (l_current_id = p_inv_sch_id) THEN
                      l_id_found_flag := 'Y';
                      x_inv_sch_id := p_inv_sch_id;
                  END IF;
              END LOOP;
              l_num_ids := c_ids%ROWCOUNT;
              CLOSE c_ids;
              IF (l_num_ids = 0) THEN
                  -- No IDs for name
                  RAISE NO_DATA_FOUND;
              ELSIF (l_num_ids = 1) THEN
                  -- Since there is only one ID for the name use it.
                  x_inv_sch_id := l_current_id;
              ELSIF (l_id_found_flag = 'N') THEN
                  -- More than one ID for the name and none of the IDs matched
                  -- the ID passed in.
                  RAISE TOO_MANY_ROWS;
              END IF;
           END IF;
       END IF;
    ELSE
        IF p_inv_sch_name IS NOT NULL
        THEN
           SELECT irs.ind_rate_sch_id
             INTO x_inv_sch_id
             FROM pa_lookups l, pa_ind_rate_schedules irs
            WHERE l.lookup_type = 'IND RATE SCHEDULE TYPE'
              AND l.lookup_code = irs.ind_rate_schedule_type
              AND irs.project_id IS NULL
              AND trunc(sysdate) BETWEEN irs.start_date_active
                                 AND nvl(irs.end_date_active,trunc(sysdate+1))
              AND irs.ind_rate_sch_name = p_inv_sch_name ;
        ELSE
           x_inv_sch_id  := null;
        END IF;
    END IF;
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_inv_sch_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_INV_SCHEDULE_ID';
       WHEN too_many_rows THEN
         x_inv_sch_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_TOO_MANY_INV_SCH';
       WHEN OTHERS THEN
         x_inv_sch_id := null;
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Inv_Sch_Name_To_Id;


-- API name                      : Nlbr_schedule_name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_sch_id	    	IN	NUMBER	OPTIONAL   DEFAULT FND_API.G_MISS_NUM
-- p_sch_name		IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_nlbr_org_id        IN    NUMBER      REQUIRED
-- p_check_id_flag	IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- x_sch_id		OUT 	NUMBER	REQUIRED
-- x_return_status	OUT	VARCHAR2	REQUIRED
-- x_error_msg_code	OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Nlbr_schedule_name_To_Id(
   p_sch_name		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_nlbr_org_id        IN    NUMBER,
   p_check_id_flag	IN	VARCHAR2	DEFAULT 'A',
   x_sch_name	      OUT 	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_return_status	OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code	OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 ) IS
BEGIN
    IF p_sch_name IS NOT NULL
    THEN
       IF p_check_id_flag = 'Y'
       THEN
          SELECT brs.std_bill_rate_schedule
            INTO x_sch_name
            FROM pa_std_bill_rate_schedules brs, pa_lookups l
           WHERE organization_id = p_nlbr_org_id
             AND brs.schedule_type = 'NON-LABOR'
             AND l.lookup_type = 'SCHEDULE TYPE'
             AND l.lookup_code (+) = brs.schedule_type
             AND brs.std_bill_rate_schedule = p_sch_name;
       ELSE
           x_sch_name := p_sch_name;
       END IF;
    END IF;
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_sch_name := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_NL_SCHEDULE_ID';
       WHEN too_many_rows THEN
         x_sch_name := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_TOO_MANY_NL_SCH';
       WHEN OTHERS THEN
         x_sch_name := NULL;
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Nlbr_schedule_name_To_Id;


-- API name                      : NL_org_sch_Name_To_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_org_id	    	IN	NUMBER	OPTIONAL   DEFAULT FND_API.G_MISS_NUM
-- p_org_name		IN	VARCHAR2	OPTIONAL   DEFAULT FND_API.G_MISS_CHAR
-- p_nlbr_org_id        IN    NUMBER      REQUIRED
-- p_check_id_flag	IN	VARCHAR2	REQUIRED   DEFAULT 'A'
-- x_org_id		OUT 	NUMBER	REQUIRED
-- x_return_status	OUT	VARCHAR2	REQUIRED
-- x_error_msg_code	OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  NL_org_sch_Name_To_Id(
   p_org_id	    	      IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_org_name		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
   p_check_id_flag	IN	VARCHAR2	DEFAULT 'A',
   x_org_id		      OUT 	NOCOPY NUMBER	, --File.Sql.39 bug 4440895
   x_return_status	OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code	OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 ) IS

   l_current_id       NUMBER     := NULL;
   l_num_ids          NUMBER     := 0;
   l_id_found_flag    VARCHAR(1) := 'N';

   CURSOR c_ids
   IS
           SELECT o.organization_id
             FROM pa_organizations_sbrs_v o
            WHERE o.schedule_type = 'NON-LABOR'
              AND o.name = p_org_name;

BEGIN
    IF p_org_id IS NOT NULL
    THEN
       IF p_check_id_flag = 'Y'
       THEN
           SELECT o.organization_id
             INTO x_org_id
             FROM pa_organizations_sbrs_v o
            WHERE o.schedule_type = 'NON-LABOR'
              AND o.organization_id = p_org_id;
       ELSIF p_check_id_flag = 'N'
       THEN
           x_org_id := p_org_id;
       ELSIF p_check_id_flag = 'A'
       THEN
           IF (p_org_name IS NULL) THEN
              -- Return a null ID since the name is null.
              x_org_id := NULL;
           ELSE
              -- Find the ID which matches the Name passed
              OPEN c_ids;
              LOOP
                  FETCH c_ids INTO l_current_id;
                  EXIT WHEN c_ids%NOTFOUND;
                  IF (l_current_id = p_org_id) THEN
                      l_id_found_flag := 'Y';
                      x_org_id := p_org_id;
                  END IF;
              END LOOP;
              l_num_ids := c_ids%ROWCOUNT;
              CLOSE c_ids;
              IF (l_num_ids = 0) THEN
                  -- No IDs for name
                  RAISE NO_DATA_FOUND;
              ELSIF (l_num_ids = 1) THEN
                  -- Since there is only one ID for the name use it.
                  x_org_id := l_current_id;
              ELSIF (l_id_found_flag = 'N') THEN
                  -- More than one ID for the name and none of the IDs matched
                  -- the ID passed in.
                  RAISE TOO_MANY_ROWS;
              END IF;
           END IF;
       END IF;
    ELSE
        IF p_org_name IS NOT NULL
        THEN
           SELECT o.organization_id
             INTO x_org_id
             FROM pa_organizations_sbrs_v o
            WHERE o.schedule_type = 'NON-LABOR'
              AND o.name = p_org_name;
        ELSE
           x_org_id := null;
        END IF;
    END IF;
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_org_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_INVALID_ORG';
       WHEN too_many_rows THEN
         x_org_id := null;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PRJ_TOO_MANY_ORG';
       WHEN OTHERS THEN
         x_org_id := null;
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END NL_org_sch_Name_To_Id;


-- API name                      : Duplicate_labor_Multiplier
-- Type                          : Public Function
-- Pre-reqs                      : None
-- Return Value                  : BOLLEAN
-- Prameters
-- p_project_id	          IN	NUMBER	REQUIRED
-- p_task_id	          IN	NUMBER	OPTIONAL      DEFAULT FND_API.MISS_NUM
-- p_effective_from_date  IN	DATE	      REQUIRED
-- p_effective_to_date      IN      DATE
-- p_labor_multiplier_id    IN      NUMBER
-- x_return_status	  OUT 	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION  Duplicate_labor_Multiplier(
   p_project_id	          IN	NUMBER  ,
   p_task_id	          IN	NUMBER  DEFAULT FND_API.G_MISS_NUM,
   p_effective_from_date    IN	DATE	  ,
   p_effective_to_date      IN      DATE    ,
   p_labor_multiplier_id    IN      NUMBER ,
   x_return_status	    OUT 	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 ) RETURN BOOLEAN IS

   CURSOR cur_lbr_mult
   IS
     SELECT 'x'
       FROM pa_labor_multipliers
      WHERE project_id  = p_project_id
        AND NVL( TASK_ID, -1 ) = DECODE( p_task_id, NULL, -1, p_task_id )
        AND (p_effective_from_date BETWEEN START_DATE_ACTIVE AND NVL(END_DATE_ACTIVE, p_effective_from_date + 1)
             OR  p_effective_to_date BETWEEN START_DATE_ACTIVE AND NVL(END_DATE_ACTIVE, p_effective_to_date + 1)
             OR  START_DATE_ACTIVE BETWEEN p_effective_from_date AND NVL(p_effective_to_date, START_DATE_ACTIVE + 1))
        AND ( p_labor_multiplier_id IS NULL OR labor_multiplier_id <> p_labor_multiplier_id );
   l_dummy_char         VARCHAR2(1);
 BEGIN
      OPEN cur_lbr_mult;
      FETCH cur_lbr_mult INTO l_dummy_char;
      IF cur_lbr_mult%FOUND
      THEN
          CLOSE cur_lbr_mult;
          RETURN TRUE;
      ELSE
         CLOSE cur_lbr_mult;
         RETURN FALSE;
      END IF;
      x_return_status:= FND_API.G_RET_STS_SUCCESS;
 EXCEPTION
       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
 END Duplicate_labor_Multiplier;

-- API name                      : Emp_job_mandatory_validation
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_emp_bill_rate_sch_id	IN	NUMBER	OPTIONAL DEFAULT FND_API.G_MISS_NUM
-- p_job_bill_rate_sch_id	IN	VARCHAR2	OPTIONAL DEFAULT FND_API.G_MISS_NUM
-- x_return_status	        OUT	VARCHAR2	REQUIRED
-- x_error_msg_code	        OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  Emp_job_mandatory_validation(
   p_emp_bill_rate_sch_id	  IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
   p_job_bill_rate_sch_id	  IN	VARCHAR2	DEFAULT FND_API.G_MISS_NUM,
   x_return_status	        OUT	NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
   x_error_msg_code	        OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
 ) IS
 BEGIN
      IF pa_install.is_prm_licensed = 'Y' THEN
         IF p_job_bill_rate_sch_id IS NULL OR p_job_bill_rate_sch_id = FND_API.G_MISS_NUM
         THEN
            x_return_status:= FND_API.G_RET_STS_ERROR;
            x_error_msg_code:= 'PA_JOB_BILL_RT_SCH_NOT_NULL';
         END IF;
      ELSE
         IF ( p_emp_bill_rate_sch_id IS NULL OR p_emp_bill_rate_sch_id = FND_API.G_MISS_NUM ) AND
            ( p_job_bill_rate_sch_id IS NULL OR p_job_bill_rate_sch_id = FND_API.G_MISS_NUM )
         THEN
            x_return_status:= FND_API.G_RET_STS_ERROR;
            x_error_msg_code:= 'PA_EJ_BILL_RT_SCH_NOT_NULL';
         END IF;
      END IF;
 EXCEPTION
       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
 END Emp_job_mandatory_validation;

-- API name                      : Get_Job_Group_Id
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                 IN      NUMBER          REQUIRED
-- x_return_status	        OUT	VARCHAR2	REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION Get_Job_Group_Id(
   p_project_id NUMBER ,
   x_return_status OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
 ) RETURN NUMBER AS

  --Derive bill_job_group_id from pa_projects_prm_v using project-task id.
  CURSOR cur_job_group IS
         SELECT bill_job_group_id
           FROM pa_projects_prm_v
          WHERE project_id = p_project_id;
  l_job_group_id NUMBER;

 BEGIN
      OPEN cur_job_group;
      FETCH cur_job_group INTO l_job_group_id;
      CLOSE cur_job_group;
      x_return_status:= FND_API.G_RET_STS_SUCCESS;
      RETURN l_job_group_id;
 EXCEPTION
       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
 END Get_Job_Group_Id;


-- API name                      : Get_Project_Type_Class
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : VARCHAR2
-- Prameters
-- p_project_id                 IN      NUMBER          REQUIRED
-- x_return_status              OUT     VARCHAR2        REQUIRED
--
--  History
--
--  21-MAY-01   Majid Ansari             -Created
--
--

 FUNCTION Get_Project_Type_Class(
   p_project_id NUMBER ,
   x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) RETURN VARCHAR2 AS

  CURSOR cur_projects_all
  IS
    SELECT ppt.project_type_class_code
      FROM pa_projects_all ppa, pa_project_types ppt
     WHERE ppa.project_id = p_project_id
       AND ppa.project_type = ppt.project_type;

  l_project_type_class_code  VARCHAR2(30);
BEGIN
   OPEN cur_projects_all;
   FETCH cur_projects_all INTO l_project_type_class_code;
   CLOSE cur_projects_all;
   RETURN l_project_type_class_code;
   x_return_status:= FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Project_Type_Class;

-- API name                      : CHECK_BILL_INFO_REQ
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_type_class_code   IN    VARCHAR2    REQUIRED
-- p_lbr_schedule_type         IN    VARCHAR2    REQUIRED
-- p_non_lbr_schedule_type     IN    VARCHAR2    REQUIRED
-- p_emp_bill_rate_sch_id      IN    NUMBER      REQUIRED
-- p_job_bill_rate_sch_id      IN    NUMBER      REQUIRED
-- p_rev_schedule_id           IN    NUMBER      REQUIRED
-- p_inv_schedule_id           IN    NUMBER      REQUIRED
-- p_nlbr_bill_rate_org_id     IN    NUMBER      REQUIRED
-- p_nlbr_std_bill_rate_sch    IN    VARCHAR2    REQUIRED
-- x_error_msg_code            OUT   VARCHAR2    REQUIRED
-- x_return_status             OUT   VARCHAR2    REQUIRED
--
--  History
--
--  06-JUN-01   Majid Ansari             -Created
--
--

PROCEDURE CHECK_BILL_INFO_REQ(
   p_project_type_class_code       IN VARCHAR2,
   p_lbr_schedule_type             IN VARCHAR2,
   p_non_lbr_schedule_type         IN VARCHAR2,
   p_emp_bill_rate_sch_id          IN NUMBER,
   p_job_bill_rate_sch_id          IN NUMBER,
   p_rev_schedule_id               IN NUMBER,
   p_inv_schedule_id               IN NUMBER,
   p_nlbr_bill_rate_org_id         IN NUMBER,
   p_nlbr_std_bill_rate_sch        IN VARCHAR2,
   x_error_msg_code               OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_return_status                OUT  NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
 ) AS

  l_error_msg_code   VARCHAR2(250);
  l_return_status    VARCHAR2(1);
BEGIN
   x_return_status := 'S';
   IF p_project_type_class_code = 'CONTRACT'
   THEN
      IF p_lbr_schedule_type = 'B'
      THEN
        PA_BILLING_SCHEDULE_UTILS.Emp_job_mandatory_validation(
                                p_emp_bill_rate_sch_id,
                                p_job_bill_rate_sch_id,
                                l_return_status,
                                l_error_msg_code );
        IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            x_error_msg_code := l_error_msg_code;
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
      ELSIF p_lbr_schedule_type = 'I'
      THEN
         --If any of the revenue or inv schedule is null then raise a message.
         IF p_rev_schedule_id IS NULL OR p_rev_schedule_id = FND_API.G_MISS_NUM
         THEN
            x_error_msg_code := 'PA_PRJ_REV_SCH_REQ';
            x_return_status:= FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
         END IF;

         IF p_inv_schedule_id IS NULL OR p_inv_schedule_id = FND_API.G_MISS_NUM
         THEN
            x_error_msg_code := 'PA_PRJ_INV_SCH_REQ';
            x_return_status:= FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      IF p_non_lbr_schedule_type = 'B'
      THEN
         IF p_nlbr_bill_rate_org_id IS NULL OR p_nlbr_bill_rate_org_id = FND_API.G_MISS_NUM
         THEN
            x_error_msg_code := 'PA_PRJ_ORG_ID_REQ';
            x_return_status:= FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
         END IF;

         IF p_nlbr_std_bill_rate_sch IS NULL  OR p_nlbr_std_bill_rate_sch = FND_API.G_MISS_CHAR
         THEN
            x_error_msg_code := 'PA_PRJ_NL_SCH_REQ';
            x_return_status:= FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
         END IF;

      ELSIF p_non_lbr_schedule_type = 'I'
      THEN

         IF p_rev_schedule_id IS NULL OR p_rev_schedule_id = FND_API.G_MISS_NUM
         THEN
            x_error_msg_code := 'PA_PRJ_REV_SCH_REQ';
            x_return_status:= FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
         END IF;

         IF p_inv_schedule_id IS NULL OR p_inv_schedule_id = FND_API.G_MISS_NUM
         THEN
            x_error_msg_code := 'PA_PRJ_INV_SCH_REQ';
            x_return_status:= FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
         END IF;
      END IF;

   END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
END CHECK_BILL_INFO_REQ;

-- API name                      : CHECK_LABOR_MULTIPLIER_REQ
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_labor_multiplier              IN NUMBER,
-- p_effective_from_date           IN VARCHAR2,
-- x_error_msg_code                OUT   VARCHAR2    REQUIRED
-- x_return_status                 OUT   VARCHAR2    REQUIRED
--
--  History
--
--  06-JUN-01   Majid Ansari             -Created
--
--

PROCEDURE CHECK_LABOR_MULTIPLIER_REQ(
   p_labor_multiplier              IN NUMBER,
   p_effective_from_date           IN DATE,
   x_error_msg_code                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_return_status                 OUT NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
 ) AS
BEGIN
     x_return_status:= FND_API.G_RET_STS_SUCCESS;
     IF p_labor_multiplier IS NULL OR p_labor_multiplier = FND_API.G_MISS_NUM
     THEN
        x_error_msg_code := 'PA_PRJ_LB_MULT_REQ';
        x_return_status:= FND_API.G_RET_STS_ERROR;
        RAISE  FND_API.G_EXC_ERROR;
     END IF;

     IF p_effective_from_date IS NULL OR p_effective_from_date = FND_API.G_MISS_DATE
     THEN
        x_error_msg_code := 'PA_PRJ_ST_DT_REQ';
        x_return_status:= FND_API.G_RET_STS_ERROR;
        RAISE  FND_API.G_EXC_ERROR;
     END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
END CHECK_LABOR_MULTIPLIER_REQ;

-- API name                      : CHECK_START_END_DATE
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_effective_from_date           IN  DATE        REQUIRED
-- p_effective_to_date             IN  DATE        REQUIRED
-- x_msg_count                     OUT NUMBER      REQUIRED
-- x_msg_data                      OUT VARCHAR2    REQUIRED
-- x_return_status                 OUT VARCHAR2    REQUIRED
--
--  History
--
--  06-JUN-01   Majid Ansari             -Created
--
--

PROCEDURE CHECK_START_END_DATE(
   p_effective_from_date           IN DATE,
   p_effective_to_date             IN DATE,
   x_return_status                 OUT NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
   x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) AS
BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF p_effective_from_date IS NOT NULL AND p_effective_to_date IS NOT NULL
     THEN
        IF p_effective_from_date > p_effective_to_date
        THEN
           x_error_msg_code := 'PA_PRJ_ST_DT_LESS_ED_DT';
           x_return_status:= FND_API.G_RET_STS_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;
     END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
END CHECK_START_END_DATE;

END PA_BILLING_SCHEDULE_UTILS;

/
