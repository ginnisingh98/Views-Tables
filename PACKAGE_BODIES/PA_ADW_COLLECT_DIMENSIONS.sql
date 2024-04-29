--------------------------------------------------------
--  DDL for Package Body PA_ADW_COLLECT_DIMENSIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ADW_COLLECT_DIMENSIONS" AS
/* $Header: PAADWCDB.pls 115.2 99/07/16 13:21:36 porting shi $ */

   FUNCTION Initialize RETURN NUMBER IS
   BEGIN
        NULL;
   END Initialize;

   -- Procedure to get dimensions statuses

   PROCEDURE get_dim_status
                        ( x_dimension_code       IN     VARCHAR2,
                          x_dimension_status     IN OUT VARCHAR2,
                          x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack    VARCHAR2(1024);
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Dimension Status for Dimension Code ' || x_dimension_code;
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_status';

     pa_debug.debug(x_err_stage);

     SELECT
      status_code
     INTO
      x_dimension_status
     FROM
      pa_adw_dimension_status
     WHERE
      dimension_code = x_dimension_code;

     x_err_stack := x_old_err_stack;
     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
     WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_status;

   -- Procedure to collect lowest/top level tasks dimension
   -- We have one procedure for lowest level tasks and top level tasks
   -- because a task may be top level tasks as well as lowest level task


   PROCEDURE get_dim_tasks
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting lowest level tasks

     CURSOR sel_lowest_tasks IS
     SELECT
        TASK_ID,
        TOP_TASK_ID,
        TASK_NUMBER,
        TASK_NAME,
        DESCRIPTION,
        CARRYING_OUT_ORGANIZATION_ID,
        SERVICE_TYPE_CODE,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        USER_COL6,
        USER_COL7,
        USER_COL8,
        USER_COL9,
        USER_COL10,
        ADW_NOTIFY_FLAG
     FROM
        PA_ADW_LOWEST_TASKS_V
     WHERE
        ADW_NOTIFY_FLAG = 'Y';

     -- Define Cursor for selecting Top level tasks

     CURSOR sel_top_tasks IS
     SELECT
  	TOP_TASK_ID,
  	PROJECT_ID,
  	TASK_NUMBER,
  	TASK_NAME,
  	DESCRIPTION,
  	CARRYING_OUT_ORGANIZATION_ID,
  	SERVICE_TYPE_CODE,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10,
  	ADW_NOTIFY_FLAG
     FROM
        PA_ADW_TOP_TASKS_V
     WHERE
        ADW_NOTIFY_FLAG IN ('Y','S');

     -- define procedure variables

     lowest_tasks_r     sel_lowest_tasks%ROWTYPE;
     top_tasks_r	sel_top_tasks%ROWTYPE;
     x_old_err_stack	VARCHAR2(1024);

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Lowest Level Task Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_tasks';

     pa_debug.debug(x_err_stage);

     -- Check the profile option value for collecting lowest tasks
     IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y') THEN

      -- Process all lowest level tasks first

      FOR lowest_tasks_r IN sel_lowest_tasks LOOP

        -- First Try to Update the Row in the Interface Table
	UPDATE
	  PA_LOWEST_TASKS_IT
        SET
	  TOP_TASK_ID = LOWEST_TASKS_R.TOP_TASK_ID,
	  TASK_NUMBER = LOWEST_TASKS_R.TASK_NUMBER,
	  TASK_NAME = LOWEST_TASKS_R.TASK_NAME,
	  CARRYING_OUT_ORGANIZATION_ID = LOWEST_TASKS_R.CARRYING_OUT_ORGANIZATION_ID,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  SERVICE_TYPE_CODE = LOWEST_TASKS_R.SERVICE_TYPE_CODE,
	  DESCRIPTION = LOWEST_TASKS_R.DESCRIPTION,
	  USER_COL1 = LOWEST_TASKS_R.USER_COL1,
	  USER_COL2 = LOWEST_TASKS_R.USER_COL2,
	  USER_COL3 = LOWEST_TASKS_R.USER_COL3,
	  USER_COL4 = LOWEST_TASKS_R.USER_COL4,
	  USER_COL5 = LOWEST_TASKS_R.USER_COL5,
	  USER_COL6 = LOWEST_TASKS_R.USER_COL6,
	  USER_COL7 = LOWEST_TASKS_R.USER_COL7,
	  USER_COL8 = LOWEST_TASKS_R.USER_COL8,
	  USER_COL9 = LOWEST_TASKS_R.USER_COL9,
	  USER_COL10 = LOWEST_TASKS_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          TASK_ID = LOWEST_TASKS_R.TASK_ID;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_LOWEST_TASKS_IT
          (
	    TASK_ID,
	    TOP_TASK_ID,
	    TASK_NUMBER,
	    TASK_NAME,
	    CARRYING_OUT_ORGANIZATION_ID,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    SERVICE_TYPE_CODE,
	    DESCRIPTION,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    LOWEST_TASKS_R.TASK_ID,
	    LOWEST_TASKS_R.TOP_TASK_ID,
	    LOWEST_TASKS_R.TASK_NUMBER,
	    LOWEST_TASKS_R.TASK_NAME,
	    LOWEST_TASKS_R.CARRYING_OUT_ORGANIZATION_ID,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    LOWEST_TASKS_R.SERVICE_TYPE_CODE,
	    LOWEST_TASKS_R.DESCRIPTION,
	    LOWEST_TASKS_R.USER_COL1,
	    LOWEST_TASKS_R.USER_COL2,
	    LOWEST_TASKS_R.USER_COL3,
	    LOWEST_TASKS_R.USER_COL4,
	    LOWEST_TASKS_R.USER_COL5,
	    LOWEST_TASKS_R.USER_COL6,
	    LOWEST_TASKS_R.USER_COL7,
	    LOWEST_TASKS_R.USER_COL8,
	    LOWEST_TASKS_R.USER_COL9,
	    LOWEST_TASKS_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the Task as being transferred to the Interface table
	-- We are marking these tasks as 'S', since some of these tasks
	-- may be top level tasks too

	UPDATE
	  PA_TASKS
	SET
	  ADW_NOTIFY_FLAG = 'S'
	WHERE
	  TASK_ID = LOWEST_TASKS_R.TASK_ID;

      END LOOP; -- FOR lowest_tasks_r IN sel_lowest_tasks

     END IF; -- IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y')

     x_err_stage     := 'Collecting Top Level Task Dimension Table';

     pa_debug.debug(x_err_stage);

     -- Check the profile option value for collecting top tasks
     IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y') THEN

      -- Now process the top level tasks

      FOR top_tasks_r IN sel_top_tasks LOOP

        -- First Try to Update the Row in the Interface Table
	UPDATE
	  PA_TOP_TASKS_IT
        SET
	  PROJECT_ID = TOP_TASKS_R.PROJECT_ID,
	  TASK_NUMBER = TOP_TASKS_R.TASK_NUMBER,
	  TASK_NAME = TOP_TASKS_R.TASK_NAME,
	  CARRYING_OUT_ORGANIZATION_ID = TOP_TASKS_R.CARRYING_OUT_ORGANIZATION_ID,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  SERVICE_TYPE_CODE = TOP_TASKS_R.SERVICE_TYPE_CODE,
	  DESCRIPTION = TOP_TASKS_R.DESCRIPTION,
	  USER_COL1 = TOP_TASKS_R.USER_COL1,
	  USER_COL2 = TOP_TASKS_R.USER_COL2,
	  USER_COL3 = TOP_TASKS_R.USER_COL3,
	  USER_COL4 = TOP_TASKS_R.USER_COL4,
	  USER_COL5 = TOP_TASKS_R.USER_COL5,
	  USER_COL6 = TOP_TASKS_R.USER_COL6,
	  USER_COL7 = TOP_TASKS_R.USER_COL7,
	  USER_COL8 = TOP_TASKS_R.USER_COL8,
	  USER_COL9 = TOP_TASKS_R.USER_COL9,
	  USER_COL10 = TOP_TASKS_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          TOP_TASK_ID = TOP_TASKS_R.TOP_TASK_ID;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_TOP_TASKS_IT
          (
	    TOP_TASK_ID,
	    PROJECT_ID,
	    TASK_NUMBER,
	    TASK_NAME,
	    CARRYING_OUT_ORGANIZATION_ID,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    SERVICE_TYPE_CODE,
	    DESCRIPTION,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    TOP_TASKS_R.TOP_TASK_ID,
	    TOP_TASKS_R.PROJECT_ID,
	    TOP_TASKS_R.TASK_NUMBER,
	    TOP_TASKS_R.TASK_NAME,
	    TOP_TASKS_R.CARRYING_OUT_ORGANIZATION_ID,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    TOP_TASKS_R.SERVICE_TYPE_CODE,
	    TOP_TASKS_R.DESCRIPTION,
	    TOP_TASKS_R.USER_COL1,
	    TOP_TASKS_R.USER_COL2,
	    TOP_TASKS_R.USER_COL3,
	    TOP_TASKS_R.USER_COL4,
	    TOP_TASKS_R.USER_COL5,
	    TOP_TASKS_R.USER_COL6,
	    TOP_TASKS_R.USER_COL7,
	    TOP_TASKS_R.USER_COL8,
	    TOP_TASKS_R.USER_COL9,
	    TOP_TASKS_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the Task as transferred to Interface table

	UPDATE
	  PA_TASKS
	SET
	  ADW_NOTIFY_FLAG = 'N'
	WHERE
	  TOP_TASK_ID = TOP_TASKS_R.TOP_TASK_ID;

      END LOOP; -- FOR top_tasks_r IN sel_top_tasks

     END IF; -- IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y')

     -- Now update all remaining Low Level tasks as transferred to the
     -- interface table

     UPDATE
       PA_TASKS
     SET
       ADW_NOTIFY_FLAG = 'N'
     WHERE
       ADW_NOTIFY_FLAG = 'S';

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_tasks;

   -- Procedure to collect projects dimension

   PROCEDURE get_dim_projects
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting projects

     CURSOR sel_projects IS
     SELECT
	PROJECT_ID,
	PROJECT_TYPE,
	NAME,
	SEGMENT1,
	CARRYING_OUT_ORGANIZATION_ID,
	DESCRIPTION,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10,
  	ADW_NOTIFY_FLAG
     FROM
        PA_ADW_PROJECTS_V
     WHERE
        ADW_NOTIFY_FLAG = 'Y';

     -- define procedure variables

     projects_r    	sel_projects%ROWTYPE;

     x_old_err_stack	VARCHAR2(1024);

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Projects Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_projects';

     pa_debug.debug(x_err_stage);

     -- Process all projects

     FOR projects_r IN sel_projects LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_PROJECTS_IT
        SET
	  PROJECT_TYPE = PROJECTS_R.PROJECT_TYPE,
	  SEGMENT1 = PROJECTS_R.SEGMENT1,
	  NAME = PROJECTS_R.NAME,
	  CARRYING_OUT_ORGANIZATION_ID = PROJECTS_R.CARRYING_OUT_ORGANIZATION_ID,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  DESCRIPTION = PROJECTS_R.DESCRIPTION,
	  USER_COL1 = PROJECTS_R.USER_COL1,
	  USER_COL2 = PROJECTS_R.USER_COL2,
	  USER_COL3 = PROJECTS_R.USER_COL3,
	  USER_COL4 = PROJECTS_R.USER_COL4,
	  USER_COL5 = PROJECTS_R.USER_COL5,
	  USER_COL6 = PROJECTS_R.USER_COL6,
	  USER_COL7 = PROJECTS_R.USER_COL7,
	  USER_COL8 = PROJECTS_R.USER_COL8,
	  USER_COL9 = PROJECTS_R.USER_COL9,
	  USER_COL10 = PROJECTS_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          PROJECT_ID = PROJECTS_R.PROJECT_ID;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_PROJECTS_IT
          (
	    PROJECT_ID,
	    PROJECT_TYPE,
	    SEGMENT1,
	    NAME,
	    CARRYING_OUT_ORGANIZATION_ID,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    DESCRIPTION,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    PROJECTS_R.PROJECT_ID,
	    PROJECTS_R.PROJECT_TYPE,
	    PROJECTS_R.SEGMENT1,
	    PROJECTS_R.NAME,
	    PROJECTS_R.CARRYING_OUT_ORGANIZATION_ID,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    PROJECTS_R.DESCRIPTION,
	    PROJECTS_R.USER_COL1,
	    PROJECTS_R.USER_COL2,
	    PROJECTS_R.USER_COL3,
	    PROJECTS_R.USER_COL4,
	    PROJECTS_R.USER_COL5,
	    PROJECTS_R.USER_COL6,
	    PROJECTS_R.USER_COL7,
	    PROJECTS_R.USER_COL8,
	    PROJECTS_R.USER_COL9,
	    PROJECTS_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the Projects as transferred to Interface table

	UPDATE
	  PA_PROJECTS
	SET
	  ADW_NOTIFY_FLAG = 'N'
	WHERE
	  PROJECT_ID = PROJECTS_R.PROJECT_ID;

     END LOOP; -- FOR projects_r IN sel_projects

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_projects;

   -- Procedure to collect project types dimension

   PROCEDURE get_dim_project_types
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting project types

     CURSOR sel_project_types IS
     SELECT
	PROJECT_TYPE,
	DESCRIPTION,
	ALL_PROJECT_TYPES,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10,
  	ADW_NOTIFY_FLAG
     FROM
        PA_ADW_PRJ_TYPES_V
     WHERE
        ADW_NOTIFY_FLAG = 'Y';

     -- define procedure variables

     project_types_r    sel_project_types%ROWTYPE;

     x_old_err_stack	VARCHAR2(1024);
     x_count            number;

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Project Types Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_project_types';

     pa_debug.debug(x_err_stage);

     -- Process all project types

     FOR project_types_r IN sel_project_types LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_PRJ_TYPES_IT
        SET
	  ALL_PROJECT_TYPES = PROJECT_TYPES_R.ALL_PROJECT_TYPES,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  DESCRIPTION = PROJECT_TYPES_R.DESCRIPTION,
	  USER_COL1 = PROJECT_TYPES_R.USER_COL1,
	  USER_COL2 = PROJECT_TYPES_R.USER_COL2,
	  USER_COL3 = PROJECT_TYPES_R.USER_COL3,
	  USER_COL4 = PROJECT_TYPES_R.USER_COL4,
	  USER_COL5 = PROJECT_TYPES_R.USER_COL5,
	  USER_COL6 = PROJECT_TYPES_R.USER_COL6,
	  USER_COL7 = PROJECT_TYPES_R.USER_COL7,
	  USER_COL8 = PROJECT_TYPES_R.USER_COL8,
	  USER_COL9 = PROJECT_TYPES_R.USER_COL9,
	  USER_COL10 = PROJECT_TYPES_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          PROJECT_TYPE = PROJECT_TYPES_R.PROJECT_TYPE;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_PRJ_TYPES_IT
          (
	    PROJECT_TYPE,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    DESCRIPTION,
	    ALL_PROJECT_TYPES,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    PROJECT_TYPES_R.PROJECT_TYPE,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    PROJECT_TYPES_R.DESCRIPTION,
	    PROJECT_TYPES_R.ALL_PROJECT_TYPES,
	    PROJECT_TYPES_R.USER_COL1,
	    PROJECT_TYPES_R.USER_COL2,
	    PROJECT_TYPES_R.USER_COL3,
	    PROJECT_TYPES_R.USER_COL4,
	    PROJECT_TYPES_R.USER_COL5,
	    PROJECT_TYPES_R.USER_COL6,
	    PROJECT_TYPES_R.USER_COL7,
	    PROJECT_TYPES_R.USER_COL8,
	    PROJECT_TYPES_R.USER_COL9,
	    PROJECT_TYPES_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the project types as transferred to Interface table

	UPDATE
	  PA_PROJECT_TYPES
	SET
	  ADW_NOTIFY_FLAG = 'N'
	WHERE
	  PROJECT_TYPE = PROJECT_TYPES_R.PROJECT_TYPE;

     END LOOP; -- FOR project_types_r IN sel_project_types

     SELECT COUNT(*)
     INTO x_count
     FROM PA_ALL_PRJ_TYPES_IT;

     IF  x_count = 0
     THEN
         INSERT INTO PA_ALL_PRJ_TYPES_IT
	 (
           ALL_PROJECT_TYPES,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   STATUS_CODE
	 )
         SELECT DISTINCT
           ALL_PROJECT_TYPES,
           TRUNC(SYSDATE),
           X_LAST_UPDATED_BY,
           TRUNC(SYSDATE),
           X_CREATED_BY,
	   X_LAST_UPDATE_LOGIN,
	   X_REQUEST_ID,
	   X_PROGRAM_APPLICATION_ID,
	   X_PROGRAM_ID,
	   TRUNC(SYSDATE),
	   'P'
        FROM PA_ADW_PRJ_TYPES_V;

     END IF;

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_project_types;

   -- Procedure to collect expenditure types dimension

   PROCEDURE get_dim_expenditure_types
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting expenditure types

     CURSOR sel_expenditure_types IS
     SELECT
        EXPENDITURE_TYPE,
        ALL_EXPENDITURE_TYPES,
        EXPENDITURE_CATEGORY,
        REVENUE_CATEGORY_CODE,
        UNIT_OF_MEASURE,
        DESCRIPTION,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        USER_COL6,
        USER_COL7,
        USER_COL8,
        USER_COL9,
        USER_COL10,
        ADW_NOTIFY_FLAG
     FROM
        PA_ADW_EXP_TYPES_V
     WHERE
        ADW_NOTIFY_FLAG = 'Y';

     -- define procedure variables

     expenditure_types_r    sel_expenditure_types%ROWTYPE;

     x_old_err_stack	    VARCHAR2(1024);
     x_count                number;

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Expenditure Types Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_expenditure_types';

     pa_debug.debug(x_err_stage);

     -- Process all expenditure types

     FOR expenditure_types_r IN sel_expenditure_types LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_EXP_TYPES_IT
        SET
          ALL_EXPENDITURE_TYPES = EXPENDITURE_TYPES_R.ALL_EXPENDITURE_TYPES,
          EXPENDITURE_CATEGORY = EXPENDITURE_TYPES_R.EXPENDITURE_CATEGORY,
          REVENUE_CATEGORY_CODE = EXPENDITURE_TYPES_R.REVENUE_CATEGORY_CODE,
          UNIT_OF_MEASURE = EXPENDITURE_TYPES_R.UNIT_OF_MEASURE,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
          DESCRIPTION = EXPENDITURE_TYPES_R.DESCRIPTION,
	  USER_COL1 = EXPENDITURE_TYPES_R.USER_COL1,
	  USER_COL2 = EXPENDITURE_TYPES_R.USER_COL2,
	  USER_COL3 = EXPENDITURE_TYPES_R.USER_COL3,
	  USER_COL4 = EXPENDITURE_TYPES_R.USER_COL4,
	  USER_COL5 = EXPENDITURE_TYPES_R.USER_COL5,
	  USER_COL6 = EXPENDITURE_TYPES_R.USER_COL6,
	  USER_COL7 = EXPENDITURE_TYPES_R.USER_COL7,
	  USER_COL8 = EXPENDITURE_TYPES_R.USER_COL8,
	  USER_COL9 = EXPENDITURE_TYPES_R.USER_COL9,
	  USER_COL10 = EXPENDITURE_TYPES_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          EXPENDITURE_TYPE = EXPENDITURE_TYPES_R.EXPENDITURE_TYPE;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_EXP_TYPES_IT
          (
	    EXPENDITURE_TYPE,
            ALL_EXPENDITURE_TYPES,
            EXPENDITURE_CATEGORY,
            REVENUE_CATEGORY_CODE,
            UNIT_OF_MEASURE,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    DESCRIPTION,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    EXPENDITURE_TYPES_R.EXPENDITURE_TYPE,
            EXPENDITURE_TYPES_R.ALL_EXPENDITURE_TYPES,
            EXPENDITURE_TYPES_R.EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPES_R.REVENUE_CATEGORY_CODE,
            EXPENDITURE_TYPES_R.UNIT_OF_MEASURE,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    EXPENDITURE_TYPES_R.DESCRIPTION,
	    EXPENDITURE_TYPES_R.USER_COL1,
	    EXPENDITURE_TYPES_R.USER_COL2,
	    EXPENDITURE_TYPES_R.USER_COL3,
	    EXPENDITURE_TYPES_R.USER_COL4,
	    EXPENDITURE_TYPES_R.USER_COL5,
	    EXPENDITURE_TYPES_R.USER_COL6,
	    EXPENDITURE_TYPES_R.USER_COL7,
	    EXPENDITURE_TYPES_R.USER_COL8,
	    EXPENDITURE_TYPES_R.USER_COL9,
	    EXPENDITURE_TYPES_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the expenditure types as transferred to Interface table

	UPDATE
	  PA_EXPENDITURE_TYPES
	SET
	  ADW_NOTIFY_FLAG = 'N'
	WHERE
	  EXPENDITURE_TYPE = EXPENDITURE_TYPES_R.EXPENDITURE_TYPE;

     END LOOP; -- FOR expenditure_types_r IN sel_expenditure_types

     SELECT COUNT(*)
     INTO  x_count
     From  PA_ALL_EXP_TYPES_IT;

     IF x_count = 0
     Then
         INSERT INTO  PA_ALL_EXP_TYPES_IT
	 (
           ALL_EXPENDITURE_TYPES,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   STATUS_CODE
	 )
         SELECT DISTINCT
           ALL_EXPENDITURE_TYPES,
	   TRUNC(SYSDATE),
	   X_LAST_UPDATED_BY,
	   TRUNC(SYSDATE),
	   X_CREATED_BY,
	   X_LAST_UPDATE_LOGIN,
	   X_REQUEST_ID,
	   X_PROGRAM_APPLICATION_ID,
	   X_PROGRAM_ID,
	   TRUNC(SYSDATE),
	   'P'
        FROM PA_ADW_EXP_TYPES_V;
      END IF;

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_expenditure_types;

   -- Procedure to collect project classes

   PROCEDURE get_dim_project_classes
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting project classes

     CURSOR sel_project_classes IS
     SELECT
	PROJECT_ID,
	CLASS_CATEGORY,
	CLASS_CODE,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10,
  	ADW_NOTIFY_FLAG
     FROM
        PA_ADW_PRJ_CLASSES_V
     WHERE
        ADW_NOTIFY_FLAG = 'Y';

     -- define procedure variables

     project_classes_r  sel_project_classes%ROWTYPE;

     x_old_err_stack	VARCHAR2(1024);

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Projects Classes Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_project_classes';

     pa_debug.debug(x_err_stage);

     -- Process all project classes

     FOR project_classes_r IN sel_project_classes LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_PRJ_CLASSES_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  USER_COL1 = PROJECT_CLASSES_R.USER_COL1,
	  USER_COL2 = PROJECT_CLASSES_R.USER_COL2,
	  USER_COL3 = PROJECT_CLASSES_R.USER_COL3,
	  USER_COL4 = PROJECT_CLASSES_R.USER_COL4,
	  USER_COL5 = PROJECT_CLASSES_R.USER_COL5,
	  USER_COL6 = PROJECT_CLASSES_R.USER_COL6,
	  USER_COL7 = PROJECT_CLASSES_R.USER_COL7,
	  USER_COL8 = PROJECT_CLASSES_R.USER_COL8,
	  USER_COL9 = PROJECT_CLASSES_R.USER_COL9,
	  USER_COL10 = PROJECT_CLASSES_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          PROJECT_ID = PROJECT_CLASSES_R.PROJECT_ID
        AND CLASS_CATEGORY = PROJECT_CLASSES_R.CLASS_CATEGORY
        AND CLASS_CODE = PROJECT_CLASSES_R.CLASS_CODE;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_PRJ_CLASSES_IT
          (
	    PROJECT_ID,
	    CLASS_CATEGORY,
	    CLASS_CODE,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    PROJECT_CLASSES_R.PROJECT_ID,
	    PROJECT_CLASSES_R.CLASS_CATEGORY,
	    PROJECT_CLASSES_R.CLASS_CODE,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    PROJECT_CLASSES_R.USER_COL1,
	    PROJECT_CLASSES_R.USER_COL2,
	    PROJECT_CLASSES_R.USER_COL3,
	    PROJECT_CLASSES_R.USER_COL4,
	    PROJECT_CLASSES_R.USER_COL5,
	    PROJECT_CLASSES_R.USER_COL6,
	    PROJECT_CLASSES_R.USER_COL7,
	    PROJECT_CLASSES_R.USER_COL8,
	    PROJECT_CLASSES_R.USER_COL9,
	    PROJECT_CLASSES_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the project classes as transferred to Interface table

	UPDATE
	  PA_PROJECT_CLASSES
	SET
	  ADW_NOTIFY_FLAG = 'N'
	WHERE
          PROJECT_ID = PROJECT_CLASSES_R.PROJECT_ID
        AND CLASS_CATEGORY = PROJECT_CLASSES_R.CLASS_CATEGORY
        AND CLASS_CODE = PROJECT_CLASSES_R.CLASS_CODE;

     END LOOP; -- FOR project_classes_r IN sel_project_classes

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_project_classes;

   -- Procedure to collect class categories dimension

   PROCEDURE get_dim_class_categories
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting class categories

     CURSOR sel_class_categories IS
     SELECT
	CLASS_CATEGORY,
	DESCRIPTION,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10,
  	ADW_NOTIFY_FLAG
     FROM
        PA_ADW_CLASS_CATGS_V
     WHERE
        ADW_NOTIFY_FLAG = 'Y';

     -- define procedure variables

     class_categories_r sel_class_categories%ROWTYPE;

     x_old_err_stack	VARCHAR2(1024);

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Class Categories Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_class_categories';

     pa_debug.debug(x_err_stage);

     -- Process all class categories

     FOR class_categories_r IN sel_class_categories LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_CLASS_CATGS_IT
        SET
	  DESCRIPTION = CLASS_CATEGORIES_R.DESCRIPTION,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  USER_COL1 = CLASS_CATEGORIES_R.USER_COL1,
	  USER_COL2 = CLASS_CATEGORIES_R.USER_COL2,
	  USER_COL3 = CLASS_CATEGORIES_R.USER_COL3,
	  USER_COL4 = CLASS_CATEGORIES_R.USER_COL4,
	  USER_COL5 = CLASS_CATEGORIES_R.USER_COL5,
	  USER_COL6 = CLASS_CATEGORIES_R.USER_COL6,
	  USER_COL7 = CLASS_CATEGORIES_R.USER_COL7,
	  USER_COL8 = CLASS_CATEGORIES_R.USER_COL8,
	  USER_COL9 = CLASS_CATEGORIES_R.USER_COL9,
	  USER_COL10 = CLASS_CATEGORIES_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          CLASS_CATEGORY = CLASS_CATEGORIES_R.CLASS_CATEGORY;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_CLASS_CATGS_IT
          (
	    CLASS_CATEGORY,
	    DESCRIPTION,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    CLASS_CATEGORIES_R.CLASS_CATEGORY,
	    CLASS_CATEGORIES_R.DESCRIPTION,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    CLASS_CATEGORIES_R.USER_COL1,
	    CLASS_CATEGORIES_R.USER_COL2,
	    CLASS_CATEGORIES_R.USER_COL3,
	    CLASS_CATEGORIES_R.USER_COL4,
	    CLASS_CATEGORIES_R.USER_COL5,
	    CLASS_CATEGORIES_R.USER_COL6,
	    CLASS_CATEGORIES_R.USER_COL7,
	    CLASS_CATEGORIES_R.USER_COL8,
	    CLASS_CATEGORIES_R.USER_COL9,
	    CLASS_CATEGORIES_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the class categories as transferred to Interface table

	UPDATE
	  PA_CLASS_CATEGORIES
	SET
	  ADW_NOTIFY_FLAG = 'N'
	WHERE
          CLASS_CATEGORY = CLASS_CATEGORIES_R.CLASS_CATEGORY;

     END LOOP; -- FOR class_categories_r IN sel_class_categories

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_class_categories;

   -- Procedure to collect class codes dimension

   PROCEDURE get_dim_class_codes
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting class codes

     CURSOR sel_class_codes IS
     SELECT
	CLASS_CATEGORY,
	CLASS_CODE,
	DESCRIPTION,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10,
  	ADW_NOTIFY_FLAG
     FROM
        PA_ADW_CLASS_CODES_V
     WHERE
        ADW_NOTIFY_FLAG = 'Y';

     -- define procedure variables

     class_codes_r 	sel_class_codes%ROWTYPE;

     x_old_err_stack	VARCHAR2(1024);

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Class Codes Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_class_codes';

     pa_debug.debug(x_err_stage);

     -- Process all classes codes

     FOR class_codes_r IN sel_class_codes LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_CLASS_CODES_IT
        SET
	  DESCRIPTION = CLASS_CODES_R.DESCRIPTION,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  USER_COL1 = CLASS_CODES_R.USER_COL1,
	  USER_COL2 = CLASS_CODES_R.USER_COL2,
	  USER_COL3 = CLASS_CODES_R.USER_COL3,
	  USER_COL4 = CLASS_CODES_R.USER_COL4,
	  USER_COL5 = CLASS_CODES_R.USER_COL5,
	  USER_COL6 = CLASS_CODES_R.USER_COL6,
	  USER_COL7 = CLASS_CODES_R.USER_COL7,
	  USER_COL8 = CLASS_CODES_R.USER_COL8,
	  USER_COL9 = CLASS_CODES_R.USER_COL9,
	  USER_COL10 = CLASS_CODES_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          CLASS_CATEGORY = CLASS_CODES_R.CLASS_CATEGORY
        AND CLASS_CODE = CLASS_CODES_R.CLASS_CODE;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_CLASS_CODES_IT
          (
	    CLASS_CATEGORY,
	    CLASS_CODE,
	    DESCRIPTION,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    CLASS_CODES_R.CLASS_CATEGORY,
	    CLASS_CODES_R.CLASS_CODE,
	    CLASS_CODES_R.DESCRIPTION,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    CLASS_CODES_R.USER_COL1,
	    CLASS_CODES_R.USER_COL2,
	    CLASS_CODES_R.USER_COL3,
	    CLASS_CODES_R.USER_COL4,
	    CLASS_CODES_R.USER_COL5,
	    CLASS_CODES_R.USER_COL6,
	    CLASS_CODES_R.USER_COL7,
	    CLASS_CODES_R.USER_COL8,
	    CLASS_CODES_R.USER_COL9,
	    CLASS_CODES_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the class categories as transferred to Interface table

	UPDATE
	  PA_CLASS_CODES
	SET
	  ADW_NOTIFY_FLAG = 'N'
	WHERE
          CLASS_CATEGORY = CLASS_CODES_R.CLASS_CATEGORY
        AND CLASS_CODE = CLASS_CODES_R.CLASS_CODE;

     END LOOP; -- FOR class_codes_r IN sel_class_codes

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_class_codes;

   -- Procedure to collect lowest/top level resource dimension
   -- We have one procedure for lowest level resource and top level resource
   -- because a resource may be top level resource as well as lowest level resource

   PROCEDURE get_dim_resources
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting lowest level resources

     CURSOR sel_lowest_res_members IS
     SELECT
  	RESOURCE_LIST_MEMBER_ID,
  	PARENT_MEMBER_ID,
  	NAME,
  	ALIAS,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10,
  	ADW_NOTIFY_FLAG
     FROM
        PA_ADW_LOWEST_RLMEM_V
     WHERE
        ADW_NOTIFY_FLAG = 'Y';

     -- Define Cursor for selecting top level resources

     CURSOR sel_top_res_members IS
     SELECT
  	RESOURCE_LIST_MEMBER_ID,
  	RESOURCE_LIST_ID,
  	NAME,
  	ALIAS,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10,
  	ADW_NOTIFY_FLAG
     FROM
        PA_ADW_TOP_RLMEM_V
     WHERE
        ADW_NOTIFY_FLAG IN ('Y','S');

     -- define procedure variables

     lowest_res_members_r	sel_lowest_res_members%ROWTYPE;
     top_res_members_r		sel_top_res_members%ROWTYPE;

     x_old_err_stack	VARCHAR2(1024);

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Lowest Level Resource Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_resources';

     pa_debug.debug(x_err_stage);

     -- Process all lowest level resource first

     FOR lowest_res_members_r IN sel_lowest_res_members LOOP

        -- First Try to Update the Row in the Interface Table
	UPDATE
	  PA_LOWEST_RLMEM_IT
        SET
	  PARENT_MEMBER_ID = LOWEST_RES_MEMBERS_R.PARENT_MEMBER_ID,
	  NAME = LOWEST_RES_MEMBERS_R.NAME,
	  ALIAS = LOWEST_RES_MEMBERS_R.ALIAS,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  USER_COL1 = LOWEST_RES_MEMBERS_R.USER_COL1,
	  USER_COL2 = LOWEST_RES_MEMBERS_R.USER_COL2,
	  USER_COL3 = LOWEST_RES_MEMBERS_R.USER_COL3,
	  USER_COL4 = LOWEST_RES_MEMBERS_R.USER_COL4,
	  USER_COL5 = LOWEST_RES_MEMBERS_R.USER_COL5,
	  USER_COL6 = LOWEST_RES_MEMBERS_R.USER_COL6,
	  USER_COL7 = LOWEST_RES_MEMBERS_R.USER_COL7,
	  USER_COL8 = LOWEST_RES_MEMBERS_R.USER_COL8,
	  USER_COL9 = LOWEST_RES_MEMBERS_R.USER_COL9,
	  USER_COL10 = LOWEST_RES_MEMBERS_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          RESOURCE_LIST_MEMBER_ID = LOWEST_RES_MEMBERS_R.RESOURCE_LIST_MEMBER_ID;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_LOWEST_RLMEM_IT
          (
	    RESOURCE_LIST_MEMBER_ID,
	    PARENT_MEMBER_ID,
	    NAME,
	    ALIAS,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    LOWEST_RES_MEMBERS_R.RESOURCE_LIST_MEMBER_ID,
	    LOWEST_RES_MEMBERS_R.PARENT_MEMBER_ID,
	    LOWEST_RES_MEMBERS_R.NAME,
	    LOWEST_RES_MEMBERS_R.ALIAS,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    LOWEST_RES_MEMBERS_R.USER_COL1,
	    LOWEST_RES_MEMBERS_R.USER_COL2,
	    LOWEST_RES_MEMBERS_R.USER_COL3,
	    LOWEST_RES_MEMBERS_R.USER_COL4,
	    LOWEST_RES_MEMBERS_R.USER_COL5,
	    LOWEST_RES_MEMBERS_R.USER_COL6,
	    LOWEST_RES_MEMBERS_R.USER_COL7,
	    LOWEST_RES_MEMBERS_R.USER_COL8,
	    LOWEST_RES_MEMBERS_R.USER_COL9,
	    LOWEST_RES_MEMBERS_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the Resource as being transferred to the Interface table
	-- We are marking these Resource as 'S', since some of these Resource
	-- may be top level Resource too

        -- PLEASE NOTE THAT WE ARE UPDATING THE BASE TABLE SINCE THE
	-- PA_ADW_LOWEST_RLMEM_V IS DEFINED ON MULTIPLE TABLES

	UPDATE
	  PA_RESOURCE_LIST_MEMBERS
	SET
	  ADW_NOTIFY_FLAG = 'S'
	WHERE
	  RESOURCE_LIST_MEMBER_ID = LOWEST_RES_MEMBERS_R.RESOURCE_LIST_MEMBER_ID;

     END LOOP; -- FOR lowest_res_members_r IN sel_lowest_res_members

     x_err_stage     := 'Collecting Top Level Resource Dimension Table';

     -- Now process the top level Resource

     FOR top_res_members_r IN sel_top_res_members LOOP

        -- First Try to Update the Row in the Interface Table
	UPDATE
	  PA_TOP_RLMEM_IT
        SET
	  RESOURCE_LIST_ID = TOP_RES_MEMBERS_R.RESOURCE_LIST_ID,
	  NAME = TOP_RES_MEMBERS_R.NAME,
	  ALIAS = TOP_RES_MEMBERS_R.ALIAS,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  USER_COL1 = TOP_RES_MEMBERS_R.USER_COL1,
	  USER_COL2 = TOP_RES_MEMBERS_R.USER_COL2,
	  USER_COL3 = TOP_RES_MEMBERS_R.USER_COL3,
	  USER_COL4 = TOP_RES_MEMBERS_R.USER_COL4,
	  USER_COL5 = TOP_RES_MEMBERS_R.USER_COL5,
	  USER_COL6 = TOP_RES_MEMBERS_R.USER_COL6,
	  USER_COL7 = TOP_RES_MEMBERS_R.USER_COL7,
	  USER_COL8 = TOP_RES_MEMBERS_R.USER_COL8,
	  USER_COL9 = TOP_RES_MEMBERS_R.USER_COL9,
	  USER_COL10 = TOP_RES_MEMBERS_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          RESOURCE_LIST_MEMBER_ID = TOP_RES_MEMBERS_R.RESOURCE_LIST_MEMBER_ID;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_TOP_RLMEM_IT
          (
	    RESOURCE_LIST_MEMBER_ID,
	    RESOURCE_LIST_ID,
	    NAME,
	    ALIAS,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    TOP_RES_MEMBERS_R.RESOURCE_LIST_MEMBER_ID,
	    TOP_RES_MEMBERS_R.RESOURCE_LIST_ID,
	    TOP_RES_MEMBERS_R.NAME,
	    TOP_RES_MEMBERS_R.ALIAS,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    TOP_RES_MEMBERS_R.USER_COL1,
	    TOP_RES_MEMBERS_R.USER_COL2,
	    TOP_RES_MEMBERS_R.USER_COL3,
	    TOP_RES_MEMBERS_R.USER_COL4,
	    TOP_RES_MEMBERS_R.USER_COL5,
	    TOP_RES_MEMBERS_R.USER_COL6,
	    TOP_RES_MEMBERS_R.USER_COL7,
	    TOP_RES_MEMBERS_R.USER_COL8,
	    TOP_RES_MEMBERS_R.USER_COL9,
	    TOP_RES_MEMBERS_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the resources as transferred to Interface table

        -- PLEASE NOTE THAT WE ARE UPDATING THE BASE TABLE SINCE THE
	-- PA_ADW_TOP_RLMEM_V IS DEFINED ON MULTIPLE TABLES

	UPDATE
	  PA_RESOURCE_LIST_MEMBERS
	SET
	  ADW_NOTIFY_FLAG = 'N'
	WHERE
	  RESOURCE_LIST_MEMBER_ID = TOP_RES_MEMBERS_R.RESOURCE_LIST_MEMBER_ID;

     END LOOP; -- FOR top_res_members_r IN sel_top_res_members

     -- Now update all remaining Low Level resources as transferred to the
     -- interface table

     UPDATE
       PA_RESOURCE_LIST_MEMBERS
     SET
       ADW_NOTIFY_FLAG = 'N'
     WHERE
       ADW_NOTIFY_FLAG = 'S';

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_resources;

   -- Procedure to collect resource list dimension

   PROCEDURE get_dim_resource_lists
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting resource lists

     CURSOR sel_resource_lists IS
     SELECT
	RESOURCE_LIST_ID,
	NAME,
	DESCRIPTION,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10,
  	ADW_NOTIFY_FLAG
     FROM
        PA_ADW_RES_LISTS_V
     WHERE
        ADW_NOTIFY_FLAG = 'Y';

     -- define procedure variables

     resource_lists_r   sel_resource_lists%ROWTYPE;

     x_old_err_stack	VARCHAR2(1024);

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Resource List Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_resource_lists';

     pa_debug.debug(x_err_stage);

     -- Process all resource lists

     FOR resource_lists_r IN sel_resource_lists LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_RES_LISTS_IT
        SET
	  NAME = RESOURCE_LISTS_R.NAME,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  DESCRIPTION = RESOURCE_LISTS_R.DESCRIPTION,
	  USER_COL1 = RESOURCE_LISTS_R.USER_COL1,
	  USER_COL2 = RESOURCE_LISTS_R.USER_COL2,
	  USER_COL3 = RESOURCE_LISTS_R.USER_COL3,
	  USER_COL4 = RESOURCE_LISTS_R.USER_COL4,
	  USER_COL5 = RESOURCE_LISTS_R.USER_COL5,
	  USER_COL6 = RESOURCE_LISTS_R.USER_COL6,
	  USER_COL7 = RESOURCE_LISTS_R.USER_COL7,
	  USER_COL8 = RESOURCE_LISTS_R.USER_COL8,
	  USER_COL9 = RESOURCE_LISTS_R.USER_COL9,
	  USER_COL10 = RESOURCE_LISTS_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          RESOURCE_LIST_ID = RESOURCE_LISTS_R.RESOURCE_LIST_ID;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_RES_LISTS_IT
          (
	    RESOURCE_LIST_ID,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    NAME,
	    DESCRIPTION,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE,
            BUSINESS_GROUP_ID
          )
          VALUES
          (
	    RESOURCE_LISTS_R.RESOURCE_LIST_ID,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    RESOURCE_LISTS_R.NAME,
	    RESOURCE_LISTS_R.DESCRIPTION,
	    RESOURCE_LISTS_R.USER_COL1,
	    RESOURCE_LISTS_R.USER_COL2,
	    RESOURCE_LISTS_R.USER_COL3,
	    RESOURCE_LISTS_R.USER_COL4,
	    RESOURCE_LISTS_R.USER_COL5,
	    RESOURCE_LISTS_R.USER_COL6,
	    RESOURCE_LISTS_R.USER_COL7,
	    RESOURCE_LISTS_R.USER_COL8,
	    RESOURCE_LISTS_R.USER_COL9,
	    RESOURCE_LISTS_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P',
            PA_UTILS.BUSINESS_GROUP_ID
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the project types as transferred to Interface table

	UPDATE
	  PA_RESOURCE_LISTS
	SET
	  ADW_NOTIFY_FLAG = 'N'
	WHERE
	  RESOURCE_LIST_ID = RESOURCE_LISTS_R.RESOURCE_LIST_ID;

     END LOOP; -- FOR resource_lists_r IN sel_resource_lists

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_resource_lists;

   -- prcoedure to collect budget type dimension

   PROCEDURE get_dim_budget_types
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting budget types

     CURSOR sel_budget_types IS
     SELECT
	BUDGET_TYPE_CODE,
	BUDGET_TYPE,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10,
  	ADW_NOTIFY_FLAG
     FROM
        PA_ADW_BGT_TYPES_V
     WHERE
        ADW_NOTIFY_FLAG = 'Y';

     -- define procedure variables

     budget_types_r     sel_budget_types%ROWTYPE;

     x_old_err_stack	VARCHAR2(1024);

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Budget Types Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_budget_types';

     pa_debug.debug(x_err_stage);

     -- Process all budget types

     FOR budget_types_r IN sel_budget_types LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_BGT_TYPES_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  BUDGET_TYPE = BUDGET_TYPES_R.BUDGET_TYPE,
	  USER_COL1 = BUDGET_TYPES_R.USER_COL1,
	  USER_COL2 = BUDGET_TYPES_R.USER_COL2,
	  USER_COL3 = BUDGET_TYPES_R.USER_COL3,
	  USER_COL4 = BUDGET_TYPES_R.USER_COL4,
	  USER_COL5 = BUDGET_TYPES_R.USER_COL5,
	  USER_COL6 = BUDGET_TYPES_R.USER_COL6,
	  USER_COL7 = BUDGET_TYPES_R.USER_COL7,
	  USER_COL8 = BUDGET_TYPES_R.USER_COL8,
	  USER_COL9 = BUDGET_TYPES_R.USER_COL9,
	  USER_COL10 = BUDGET_TYPES_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          BUDGET_TYPE_CODE = BUDGET_TYPES_R.BUDGET_TYPE_CODE;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_BGT_TYPES_IT
          (
	    BUDGET_TYPE_CODE,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    BUDGET_TYPE,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    BUDGET_TYPES_R.BUDGET_TYPE_CODE,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    BUDGET_TYPES_R.BUDGET_TYPE,
	    BUDGET_TYPES_R.USER_COL1,
	    BUDGET_TYPES_R.USER_COL2,
	    BUDGET_TYPES_R.USER_COL3,
	    BUDGET_TYPES_R.USER_COL4,
	    BUDGET_TYPES_R.USER_COL5,
	    BUDGET_TYPES_R.USER_COL6,
	    BUDGET_TYPES_R.USER_COL7,
	    BUDGET_TYPES_R.USER_COL8,
	    BUDGET_TYPES_R.USER_COL9,
	    BUDGET_TYPES_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

	-- Mark the project types as transferred to Interface table

	UPDATE
	  PA_BUDGET_TYPES
	SET
	  ADW_NOTIFY_FLAG = 'N'
	WHERE
	  BUDGET_TYPE_CODE = BUDGET_TYPES_R.BUDGET_TYPE_CODE;

     END LOOP; -- FOR budget_types_r IN sel_budget_types

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_budget_types;

   -- Procedure to collect pa periods dimension

   PROCEDURE get_dim_periods
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting periods

     CURSOR sel_periods IS
     SELECT
        PA_PERIOD_KEY,
	PA_PERIOD,
        PA_PERIOD_START_DATE,
        PA_PERIOD_END_DATE,
        PA_PERIOD_END_DATE - PA_PERIOD_START_DATE  + 1   TIMESPAN,
	GL_PERIOD,
	FINANCIAL_QUARTER,
	FINANCIAL_YEAR,
	ALL_FINANCIAL_YEARS,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10
     FROM
        PA_ADW_PERIODS_V;

     -- Cursor for selecting GL Periods

     CURSOR gl_periods IS
     SELECT DISTINCT
        GL_PERIOD,
        GL_PERIOD_START_DATE,
        GL_PERIOD_END_DATE,
        GL_PERIOD_END_DATE - GL_PERIOD_START_DATE  + 1   TIMESPAN,
        FINANCIAL_QUARTER
     FROM
        PA_ADW_PERIODS_V;

     -- Cursor for selecting Financial Quarters

     CURSOR fin_qtr IS
     SELECT DISTINCT
         FINANCIAL_QUARTER,
         FINANCIAL_YEAR
     FROM
        PA_ADW_PERIODS_V;

     -- Cursor for selecting Financial Years

     CURSOR fin_year IS
     SELECT DISTINCT
         FINANCIAL_YEAR,
         ALL_FINANCIAL_YEARS
     FROM
        PA_ADW_PERIODS_V;

     -- define procedure variables

     periods_r    	sel_periods%ROWTYPE;
     periods_gl    	gl_periods%ROWTYPE;
     fin_qtr_r    	fin_qtr%ROWTYPE;
     fin_year_r    	fin_year%ROWTYPE;
     x_count            number;
     x_start_date       date;
     x_end_date         date;
     x_timespan         number;

     x_old_err_stack	VARCHAR2(1024);

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting PA period Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_periods';

     pa_debug.debug(x_err_stage);

     -- Process all PA periods

     FOR periods_r IN sel_periods LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_PERIODS_IT
        SET
	  PA_PERIOD = PERIODS_R.PA_PERIOD,
	  START_DATE = PERIODS_R.PA_PERIOD_START_DATE,
	  END_DATE = PERIODS_R.PA_PERIOD_END_DATE,
	  TIMESPAN = PERIODS_R.TIMESPAN,
	  GL_PERIOD = PERIODS_R.GL_PERIOD,
	  FINANCIAL_QUARTER = PERIODS_R.FINANCIAL_QUARTER,
	  FINANCIAL_YEAR = PERIODS_R.FINANCIAL_YEAR,
	  ALL_FINANCIAL_YEARS = PERIODS_R.ALL_FINANCIAL_YEARS,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  USER_COL1 = PERIODS_R.USER_COL1,
	  USER_COL2 = PERIODS_R.USER_COL2,
	  USER_COL3 = PERIODS_R.USER_COL3,
	  USER_COL4 = PERIODS_R.USER_COL4,
	  USER_COL5 = PERIODS_R.USER_COL5,
	  USER_COL6 = PERIODS_R.USER_COL6,
	  USER_COL7 = PERIODS_R.USER_COL7,
	  USER_COL8 = PERIODS_R.USER_COL8,
	  USER_COL9 = PERIODS_R.USER_COL9,
	  USER_COL10 = PERIODS_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          PA_PERIOD_KEY = PERIODS_R.PA_PERIOD_KEY;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_PERIODS_IT
          (
	    PA_PERIOD_KEY,
	    PA_PERIOD,
            START_DATE,
            END_DATE,
            TIMESPAN,
	    GL_PERIOD,
	    FINANCIAL_QUARTER,
	    FINANCIAL_YEAR,
	    ALL_FINANCIAL_YEARS,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    PERIODS_R.PA_PERIOD_KEY,
	    PERIODS_R.PA_PERIOD,
	    PERIODS_R.PA_PERIOD_START_DATE,
	    PERIODS_R.PA_PERIOD_END_DATE,
	    PERIODS_R.TIMESPAN,
	    PERIODS_R.GL_PERIOD,
	    PERIODS_R.FINANCIAL_QUARTER,
	    PERIODS_R.FINANCIAL_YEAR,
	    PERIODS_R.ALL_FINANCIAL_YEARS,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    PERIODS_R.USER_COL1,
	    PERIODS_R.USER_COL2,
	    PERIODS_R.USER_COL3,
	    PERIODS_R.USER_COL4,
	    PERIODS_R.USER_COL5,
	    PERIODS_R.USER_COL6,
	    PERIODS_R.USER_COL7,
	    PERIODS_R.USER_COL8,
	    PERIODS_R.USER_COL9,
	    PERIODS_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

     END LOOP; -- FOR periods_r IN sel_periods

     FOR periods_gl IN gl_periods LOOP
        UPDATE
          PA_GL_PERIODS_IT
        SET
	  START_DATE = PERIODS_GL.GL_PERIOD_START_DATE,
	  END_DATE = PERIODS_GL.GL_PERIOD_END_DATE,
	  TIMESPAN = PERIODS_GL.TIMESPAN,
	  FINANCIAL_QUARTER = PERIODS_GL.FINANCIAL_QUARTER,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
        WHERE
          GL_PERIOD = PERIODS_GL.GL_PERIOD;

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_GL_PERIODS_IT
          (
            GL_PERIOD,
            START_DATE,
            END_DATE,
            TIMESPAN,
	    FINANCIAL_QUARTER,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
            CREATED_BY,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
            PERIODS_GL.GL_PERIOD,
	    PERIODS_GL.GL_PERIOD_START_DATE,
	    PERIODS_GL.GL_PERIOD_END_DATE,
	    PERIODS_GL.TIMESPAN,
	    PERIODS_GL.FINANCIAL_QUARTER,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
           );
        END IF ;
     END LOOP;  -- For periods_gl  in gl_periods

     FOR fin_qtr_r IN fin_qtr LOOP

        SELECT
          MIN(GL_PERIOD_START_DATE),
          MAX(GL_PERIOD_END_DATE)
        INTO
          x_start_date,
          x_end_date
       FROM
         PA_ADW_PERIODS_V
       WHERE
         FINANCIAL_QUARTER = fin_qtr_r.FINANCIAL_QUARTER ;

       x_timespan := x_end_date - x_start_date + 1 ;

        UPDATE
          PA_FINANCIAL_QTRS_IT
        SET
	  START_DATE = x_start_date,
	  END_DATE = x_end_date ,
	  TIMESPAN = x_timespan,
	  FINANCIAL_YEAR = fin_qtr_r.FINANCIAL_YEAR,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
        WHERE
          FINANCIAL_QUARTER = fin_qtr_r.FINANCIAL_QUARTER;

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          Insert Into PA_FINANCIAL_QTRS_IT
          (
	    FINANCIAL_QUARTER,
            START_DATE,
            END_DATE,
            TIMESPAN,
	    FINANCIAL_YEAR,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
            CREATED_BY,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
	  )
          VALUES
	  (
	    fin_qtr_r.FINANCIAL_QUARTER,
            x_start_date,
            x_end_date,
            x_timespan,
	    fin_qtr_r.FINANCIAL_YEAR,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );
        END IF;
     End LOOP;  -- For fin_qtr_r  in fin_qtr

     FOR fin_year_r IN fin_year LOOP


        SELECT
          MIN(GL_PERIOD_START_DATE),
          MAX(GL_PERIOD_END_DATE)
        INTO
          x_start_date,
          x_end_date
       FROM
         PA_ADW_PERIODS_V
       WHERE
         FINANCIAL_YEAR = fin_year_r.FINANCIAL_YEAR ;

       x_timespan := x_end_date - x_start_date + 1 ;

        UPDATE
	  PA_FINANCIAL_YRS_IT
        SET
	  START_DATE = x_start_date,
	  END_DATE = x_end_date ,
	  TIMESPAN = x_timespan,
	  ALL_FINANCIAL_YEARS = fin_year_r.ALL_FINANCIAL_YEARS,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
        WHERE
          FINANCIAL_YEAR = fin_year_r.FINANCIAL_YEAR;

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          Insert Into PA_FINANCIAL_YRS_IT
	  (
	    FINANCIAL_YEAR,
            START_DATE,
            END_DATE,
            TIMESPAN,
	    ALL_FINANCIAL_YEARS,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
            CREATED_BY,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
	  )
          Values
	  (
	    fin_year_r.FINANCIAL_YEAR,
            x_start_date,
            x_end_date,
            x_timespan,
	    fin_year_r.ALL_FINANCIAL_YEARS,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );
        END IF;
     END LOOP;  -- For fin_year_r  in fin_year

     SELECT
       COUNT(*)
       INTO x_count
     FROM
       PA_ALL_FINANCIAL_YRS_IT;

     IF  x_count = 0
     THEN
         INSERT INTO PA_ALL_FINANCIAL_YRS_IT
         (
           ALL_FINANCIAL_YEARS,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   STATUS_CODE
	 )
         SELECT DISTINCT
           ALL_FINANCIAL_YEARS,
           TRUNC(SYSDATE),
           X_LAST_UPDATED_BY,
           TRUNC(SYSDATE),
	   X_CREATED_BY,
	   X_LAST_UPDATE_LOGIN,
	   X_REQUEST_ID,
	   X_PROGRAM_APPLICATION_ID,
	   X_PROGRAM_ID,
	   TRUNC(SYSDATE),
	   'P'
        FROM
           PA_ADW_PERIODS_V;
     END IF;

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_periods;

   -- Procedure to collect service types dimension
   -- We are not maintaining any flag on service types, so this dimension
   -- is always refreshed

   PROCEDURE get_dim_service_types
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting service types

     CURSOR sel_service_types IS
     SELECT
	SERVICE_TYPE_CODE,
	SERVICE_TYPE,
	ALL_SERVICE_TYPES,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10
     FROM
        PA_ADW_SRVC_TYPES_V;

     -- define procedure variables

     service_types_r    sel_service_types%ROWTYPE;

     x_old_err_stack	VARCHAR2(1024);
     x_count            number;

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Service Types Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_service_types';

     pa_debug.debug(x_err_stage);

     -- Process all service types

     FOR service_types_r IN sel_service_types LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_SRVC_TYPES_IT
        SET
	  ALL_SERVICE_TYPES = SERVICE_TYPES_R.ALL_SERVICE_TYPES,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  SERVICE_TYPE = SERVICE_TYPES_R.SERVICE_TYPE,
	  USER_COL1 = SERVICE_TYPES_R.USER_COL1,
	  USER_COL2 = SERVICE_TYPES_R.USER_COL2,
	  USER_COL3 = SERVICE_TYPES_R.USER_COL3,
	  USER_COL4 = SERVICE_TYPES_R.USER_COL4,
	  USER_COL5 = SERVICE_TYPES_R.USER_COL5,
	  USER_COL6 = SERVICE_TYPES_R.USER_COL6,
	  USER_COL7 = SERVICE_TYPES_R.USER_COL7,
	  USER_COL8 = SERVICE_TYPES_R.USER_COL8,
	  USER_COL9 = SERVICE_TYPES_R.USER_COL9,
	  USER_COL10 = SERVICE_TYPES_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          SERVICE_TYPE_CODE = SERVICE_TYPES_R.SERVICE_TYPE_CODE;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_SRVC_TYPES_IT
          (
	    SERVICE_TYPE_CODE,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    SERVICE_TYPE,
	    ALL_SERVICE_TYPES,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    SERVICE_TYPES_R.SERVICE_TYPE_CODE,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    SERVICE_TYPES_R.SERVICE_TYPE,
	    SERVICE_TYPES_R.ALL_SERVICE_TYPES,
	    SERVICE_TYPES_R.USER_COL1,
	    SERVICE_TYPES_R.USER_COL2,
	    SERVICE_TYPES_R.USER_COL3,
	    SERVICE_TYPES_R.USER_COL4,
	    SERVICE_TYPES_R.USER_COL5,
	    SERVICE_TYPES_R.USER_COL6,
	    SERVICE_TYPES_R.USER_COL7,
	    SERVICE_TYPES_R.USER_COL8,
	    SERVICE_TYPES_R.USER_COL9,
	    SERVICE_TYPES_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

     END LOOP; -- FOR service_types_r IN sel_service_types

     SELECT count(*)
       into x_count
      FROM PA_ALL_SRVC_TYPES_IT;

     IF  x_count = 0
     THEN
         INSERT INTO PA_ALL_SRVC_TYPES_IT
	 (
           ALL_SERVICE_TYPES,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   STATUS_CODE
	 )
         SELECT DISTINCT
           ALL_SERVICE_TYPES,
           TRUNC(SYSDATE),
           X_LAST_UPDATED_BY,
           TRUNC(SYSDATE),
           X_CREATED_BY,
	   X_LAST_UPDATE_LOGIN,
	   X_REQUEST_ID,
	   X_PROGRAM_APPLICATION_ID,
	   X_PROGRAM_ID,
	   TRUNC(SYSDATE),
	   'P'
         FROM PA_ADW_SRVC_TYPES_V;
     END IF;

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_service_types;

   -- Procedure to collect organization dimension
   -- We are not maintaining any flag on organizations, so this dimension
   -- is always refreshed

   PROCEDURE get_dim_organizations
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS

     -- Define Cursor for selecting organizations

     CURSOR sel_organizations IS
     SELECT
	ORGANIZATION_ID,
	ORGANIZATION,
	BUSINESS_GROUP,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10
     FROM
        PA_ADW_ORGS_V;

     CURSOR project_bsns_grp IS
     SELECT  distinct
	BUSINESS_GROUP
     FROM
        PA_ADW_ORGS_V;

     CURSOR exp_bsns_grp IS
     SELECT  distinct
	BUSINESS_GROUP
     FROM
        PA_ADW_ORGS_V;

     CURSOR project_org IS
     SELECT
	ORGANIZATION_ID,
	ORGANIZATION,
	BUSINESS_GROUP,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10
     FROM
        PA_ADW_ORGS_V;

     CURSOR exp_org IS
     SELECT
	ORGANIZATION_ID,
	ORGANIZATION,
	BUSINESS_GROUP,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10
     FROM
        PA_ADW_ORGS_V;

     CURSOR sel_operating_units IS
     SELECT
	ORGANIZATION_ID,
	ORGANIZATION,
	LEGAL_ENTITY,
	SET_OF_BOOK,
  	USER_COL1,
  	USER_COL2,
  	USER_COL3,
  	USER_COL4,
  	USER_COL5,
  	USER_COL6,
  	USER_COL7,
  	USER_COL8,
  	USER_COL9,
  	USER_COL10
     FROM
        PA_ADW_OPER_UNITS_V;

     CURSOR legal_entity IS
     SELECT distinct
	LEGAL_ENTITY,
	SET_OF_BOOK
     FROM
        PA_ADW_OPER_UNITS_V;

     CURSOR set_of_book IS
     SELECT distinct
	SET_OF_BOOK
     FROM
        PA_ADW_OPER_UNITS_V;

     -- define procedure variables

     organizations_r    sel_organizations%ROWTYPE;
     operating_units_r  sel_operating_units%ROWTYPE;
     set_of_book_r      set_of_book%ROWTYPE;
     legal_entity_r     legal_entity%ROWTYPE;
     project_org_r      project_org%ROWTYPE;
     exp_org_r      	exp_org%ROWTYPE;
     project_bsns_grp_r project_bsns_grp%ROWTYPE;
     exp_bsns_grp_r     exp_bsns_grp%ROWTYPE;

     x_old_err_stack	VARCHAR2(1024);

   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Organization/Operating Units Dimension Table';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_organizations';

     pa_debug.debug(x_err_stage);

     FOR project_org_r IN project_org LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_PRJ_ORGS_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  ORGANIZATION = project_org_r.ORGANIZATION,
	  BUSINESS_GROUP = project_org_r.BUSINESS_GROUP,
	  USER_COL1 = project_org_r.USER_COL1,
	  USER_COL2 = project_org_r.USER_COL2,
	  USER_COL3 = project_org_r.USER_COL3,
	  USER_COL4 = project_org_r.USER_COL4,
	  USER_COL5 = project_org_r.USER_COL5,
	  USER_COL6 = project_org_r.USER_COL6,
	  USER_COL7 = project_org_r.USER_COL7,
	  USER_COL8 = project_org_r.USER_COL8,
	  USER_COL9 = project_org_r.USER_COL9,
	  USER_COL10 = project_org_r.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          ORGANIZATION_ID = project_org_r.ORGANIZATION_ID;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_PRJ_ORGS_IT
          (
	    ORGANIZATION_ID,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    ORGANIZATION,
	    BUSINESS_GROUP,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    project_org_r.ORGANIZATION_ID,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    project_org_r.ORGANIZATION,
	    project_org_r.BUSINESS_GROUP,
	    project_org_r.USER_COL1,
	    project_org_r.USER_COL2,
	    project_org_r.USER_COL3,
	    project_org_r.USER_COL4,
	    project_org_r.USER_COL5,
	    project_org_r.USER_COL6,
	    project_org_r.USER_COL7,
	    project_org_r.USER_COL8,
	    project_org_r.USER_COL9,
	    project_org_r.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

     END LOOP; -- FOR project_org_r IN project_org

     FOR project_bsns_grp_r IN project_bsns_grp LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_PRJ_BUSINESS_GRPS_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
        WHERE
	  BUSINESS_GROUP = project_bsns_grp_r.BUSINESS_GROUP;

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_PRJ_BUSINESS_GRPS_IT
          (
             business_group,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
	     LAST_UPDATE_LOGIN,
	     REQUEST_ID,
	     PROGRAM_APPLICATION_ID,
	     PROGRAM_ID,
	     PROGRAM_UPDATE_DATE,
	     STATUS_CODE
	  )
          VALUES
	  (
             project_bsns_grp_r.business_group,
             TRUNC(SYSDATE),
	     X_LAST_UPDATED_BY,
	     TRUNC(SYSDATE),
	     X_CREATED_BY,
	     X_LAST_UPDATE_LOGIN,
	     X_REQUEST_ID,
	     X_PROGRAM_APPLICATION_ID,
	     X_PROGRAM_ID,
	     TRUNC(SYSDATE),
	     'P'
	  );
         END IF;
      END LOOP;

     -- Process all organizations

     FOR organizations_r IN sel_organizations LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_ORGS_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  ORGANIZATION = ORGANIZATIONS_R.ORGANIZATION,
	  BUSINESS_GROUP = ORGANIZATIONS_R.BUSINESS_GROUP,
	  USER_COL1 = ORGANIZATIONS_R.USER_COL1,
	  USER_COL2 = ORGANIZATIONS_R.USER_COL2,
	  USER_COL3 = ORGANIZATIONS_R.USER_COL3,
	  USER_COL4 = ORGANIZATIONS_R.USER_COL4,
	  USER_COL5 = ORGANIZATIONS_R.USER_COL5,
	  USER_COL6 = ORGANIZATIONS_R.USER_COL6,
	  USER_COL7 = ORGANIZATIONS_R.USER_COL7,
	  USER_COL8 = ORGANIZATIONS_R.USER_COL8,
	  USER_COL9 = ORGANIZATIONS_R.USER_COL9,
	  USER_COL10 = ORGANIZATIONS_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          ORGANIZATION_ID = ORGANIZATIONS_R.ORGANIZATION_ID;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_ORGS_IT
          (
	    ORGANIZATION_ID,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    ORGANIZATION,
	    BUSINESS_GROUP,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    ORGANIZATIONS_R.ORGANIZATION_ID,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    ORGANIZATIONS_R.ORGANIZATION,
	    ORGANIZATIONS_R.BUSINESS_GROUP,
	    ORGANIZATIONS_R.USER_COL1,
	    ORGANIZATIONS_R.USER_COL2,
	    ORGANIZATIONS_R.USER_COL3,
	    ORGANIZATIONS_R.USER_COL4,
	    ORGANIZATIONS_R.USER_COL5,
	    ORGANIZATIONS_R.USER_COL6,
	    ORGANIZATIONS_R.USER_COL7,
	    ORGANIZATIONS_R.USER_COL8,
	    ORGANIZATIONS_R.USER_COL9,
	    ORGANIZATIONS_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

     END LOOP; -- FOR organizations_r IN sel_organizations

     FOR exp_org_r IN exp_org LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_EXP_ORGS_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  ORGANIZATION = exp_org_r.ORGANIZATION,
	  BUSINESS_GROUP = exp_org_r.BUSINESS_GROUP,
	  USER_COL1 = exp_org_r.USER_COL1,
	  USER_COL2 = exp_org_r.USER_COL2,
	  USER_COL3 = exp_org_r.USER_COL3,
	  USER_COL4 = exp_org_r.USER_COL4,
	  USER_COL5 = exp_org_r.USER_COL5,
	  USER_COL6 = exp_org_r.USER_COL6,
	  USER_COL7 = exp_org_r.USER_COL7,
	  USER_COL8 = exp_org_r.USER_COL8,
	  USER_COL9 = exp_org_r.USER_COL9,
	  USER_COL10 = exp_org_r.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          ORGANIZATION_ID = exp_org_r.ORGANIZATION_ID;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_EXP_ORGS_IT
          (
	    ORGANIZATION_ID,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    ORGANIZATION,
	    BUSINESS_GROUP,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    exp_org_r.ORGANIZATION_ID,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    exp_org_r.ORGANIZATION,
	    exp_org_r.BUSINESS_GROUP,
	    exp_org_r.USER_COL1,
	    exp_org_r.USER_COL2,
	    exp_org_r.USER_COL3,
	    exp_org_r.USER_COL4,
	    exp_org_r.USER_COL5,
	    exp_org_r.USER_COL6,
	    exp_org_r.USER_COL7,
	    exp_org_r.USER_COL8,
	    exp_org_r.USER_COL9,
	    exp_org_r.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

     END LOOP; -- FOR exp_org_r IN exp_org

     FOR exp_bsns_grp_r IN exp_bsns_grp LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_EXP_BUSINESS_GRPS_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
        WHERE
	  BUSINESS_GROUP = exp_bsns_grp_r.BUSINESS_GROUP;

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_EXP_BUSINESS_GRPS_IT
          (
             BUSINESS_GROUP,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
	     LAST_UPDATE_LOGIN,
	     REQUEST_ID,
	     PROGRAM_APPLICATION_ID,
	     PROGRAM_ID,
	     PROGRAM_UPDATE_DATE,
	     STATUS_CODE
	  )
          VALUES
	  (
             exp_bsns_grp_r.business_group,
             TRUNC(SYSDATE),
	     X_LAST_UPDATED_BY,
	     TRUNC(SYSDATE),
	     X_CREATED_BY,
	     X_LAST_UPDATE_LOGIN,
	     X_REQUEST_ID,
	     X_PROGRAM_APPLICATION_ID,
	     X_PROGRAM_ID,
	     TRUNC(SYSDATE),
	     'P'
	  );
         END IF;
     END LOOP;

     -- Process all operating units

     FOR operating_units_r IN sel_operating_units LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_OPER_UNITS_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  ORGANIZATION = OPERATING_UNITS_R.ORGANIZATION,
	  LEGAL_ENTITY = OPERATING_UNITS_R.LEGAL_ENTITY,
	  SET_OF_BOOK = OPERATING_UNITS_R.SET_OF_BOOK,
	  USER_COL1 = OPERATING_UNITS_R.USER_COL1,
	  USER_COL2 = OPERATING_UNITS_R.USER_COL2,
	  USER_COL3 = OPERATING_UNITS_R.USER_COL3,
	  USER_COL4 = OPERATING_UNITS_R.USER_COL4,
	  USER_COL5 = OPERATING_UNITS_R.USER_COL5,
	  USER_COL6 = OPERATING_UNITS_R.USER_COL6,
	  USER_COL7 = OPERATING_UNITS_R.USER_COL7,
	  USER_COL8 = OPERATING_UNITS_R.USER_COL8,
	  USER_COL9 = OPERATING_UNITS_R.USER_COL9,
	  USER_COL10 = OPERATING_UNITS_R.USER_COL10,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
          ORGANIZATION_ID = OPERATING_UNITS_R.ORGANIZATION_ID;

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_OPER_UNITS_IT
          (
	    ORGANIZATION_ID,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    ORGANIZATION,
	    LEGAL_ENTITY,
	    SET_OF_BOOK,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    OPERATING_UNITS_R.ORGANIZATION_ID,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    OPERATING_UNITS_R.ORGANIZATION,
	    OPERATING_UNITS_R.LEGAL_ENTITY,
	    OPERATING_UNITS_R.SET_OF_BOOK,
	    OPERATING_UNITS_R.USER_COL1,
	    OPERATING_UNITS_R.USER_COL2,
	    OPERATING_UNITS_R.USER_COL3,
	    OPERATING_UNITS_R.USER_COL4,
	    OPERATING_UNITS_R.USER_COL5,
	    OPERATING_UNITS_R.USER_COL6,
	    OPERATING_UNITS_R.USER_COL7,
	    OPERATING_UNITS_R.USER_COL8,
	    OPERATING_UNITS_R.USER_COL9,
	    OPERATING_UNITS_R.USER_COL10,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

     END LOOP; -- FOR operating_units_r IN sel_operating_units

     FOR set_of_book_r IN set_of_book LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_SET_OF_BOOKS_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
        WHERE
          SET_OF_BOOK = set_of_book_r.SET_OF_BOOK ;


	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_SET_OF_BOOKS_IT
	  (
             SET_OF_BOOK,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
	     LAST_UPDATE_LOGIN,
	     REQUEST_ID,
	     PROGRAM_APPLICATION_ID,
	     PROGRAM_ID,
	     PROGRAM_UPDATE_DATE,
	     STATUS_CODE
	  )
          VALUES
	  (
             SET_OF_BOOK_R.SET_OF_BOOK,
	     TRUNC(SYSDATE),
	     X_LAST_UPDATED_BY,
	     TRUNC(SYSDATE),
	     X_CREATED_BY,
	     X_LAST_UPDATE_LOGIN,
	     X_REQUEST_ID,
	     X_PROGRAM_APPLICATION_ID,
	     X_PROGRAM_ID,
	     TRUNC(SYSDATE),
	     'P'
	   );
         END IF;
      END LOOP;

     FOR legal_entity_r IN legal_entity LOOP

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_LEGAL_ENTITY_IT
        SET
          SET_OF_BOOK = legal_entity_r.SET_OF_BOOK,
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
        WHERE
          LEGAL_ENTITY = legal_entity_r.LEGAL_ENTITY ;


	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_LEGAL_ENTITY_IT
	  (
            LEGAL_ENTITY,
            SET_OF_BOOK,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
	  )
          VALUES
	  (
            LEGAL_ENTITY_R.LEGAL_ENTITY,
            LEGAL_ENTITY_R.SET_OF_BOOK,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	   );
         END IF;
      END LOOP;

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dim_organizations;

END PA_ADW_COLLECT_DIMENSIONS;

/
