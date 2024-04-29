--------------------------------------------------------
--  DDL for Package Body PA_MU_DETAILS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MU_DETAILS_V_PKG" as
-- $Header: PAXBAULB.pls 120.2 2006/02/13 14:59:53 dlanka noship $


  PROCEDURE Insert_Row(	X_Rowid                 IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Line_ID		IN OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Batch_ID		 	NUMBER,
			X_Creation_Date			DATE,
			X_Created_By			NUMBER,
			X_Last_Updated_By		NUMBER,
			X_Last_Update_Date		DATE,
			X_Last_Update_Login		NUMBER,
			X_Project_ID			NUMBER,
			X_Task_ID			NUMBER,
			X_Old_Attribute_Value		VARCHAR2,
			X_New_Attribute_Value		VARCHAR2,
			X_Update_Flag			VARCHAR2,
			X_Recalculate_Flag		VARCHAR2 )
  IS
    l_line_id	NUMBER;
  BEGIN

    SELECT PA_MASS_UPDATE_DETAILS_S.NextVal
      INTO l_line_id
      FROM dual;

    INSERT INTO PA_MASS_UPDATE_DETAILS
	( 	Batch_ID,
		Line_ID,
		Project_ID,
		Task_ID,
		Old_Attribute_Value,
		New_Attribute_Value,
		Update_Flag,
		Recalculate_Flag,
		Creation_Date,
		Created_By,
		Last_Update_Date,
		Last_Updated_By,
		Last_Update_Login )
    VALUES
	(	X_batch_id,
		l_line_id,
		X_Project_ID,
		X_Task_ID,
		X_Old_Attribute_Value,
		X_New_Attribute_Value,
		X_Update_Flag,
		X_Recalculate_Flag,
		X_Creation_Date,
		X_Created_By,
		X_Last_Update_Date,
		X_Last_Updated_By,
		X_Last_Update_Login
	);

    X_Line_ID := l_line_id;

    SELECT rowid INTO X_Rowid
      FROM PA_MASS_UPDATE_DETAILS
     WHERE batch_id = X_batch_id
       AND line_id = l_line_id;

  END Insert_Row;


  PROCEDURE Update_Row(	X_Rowid                         VARCHAR2,
			X_Last_Updated_By		NUMBER,
			X_Last_Update_Date		DATE,
			X_Last_Update_Login		NUMBER,
			X_Project_ID			NUMBER,
			X_Task_ID			NUMBER,
			X_Old_Attribute_Value		VARCHAR2,
			X_New_Attribute_Value		VARCHAR2,
			X_Update_Flag			VARCHAR2,
			X_Recalculate_Flag		VARCHAR2,
			X_Rejection_Reason		VARCHAR2 )
  IS

  BEGIN

    UPDATE pa_mass_update_details
    SET
	Project_ID		=	X_Project_ID,
	Task_ID			=	X_Task_ID,
	Old_Attribute_Value	=	X_Old_Attribute_Value,
	New_Attribute_Value	=	X_New_Attribute_Value,
	Update_Flag		=	X_Update_Flag,
	Recalculate_Flag	=	X_Recalculate_Flag,
	Rejection_Reason	=	X_Rejection_Reason,
	Last_Update_Date	=	X_Last_Update_Date,
	Last_Updated_By		=	X_Last_Updated_By,
	Last_Update_Login	=	X_Last_Update_Login
    WHERE
	rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;

  END Update_Row;



  PROCEDURE Lock_Row(	X_Rowid                         VARCHAR2,
			X_Project_ID			NUMBER,
			X_Task_ID			NUMBER,
			X_Old_Attribute_Value		VARCHAR2,
			X_New_Attribute_Value		VARCHAR2,
			X_Update_Flag			VARCHAR2,
			X_Recalculate_Flag		VARCHAR2,
			X_Rejection_Reason		VARCHAR2 )
  IS

    CURSOR l_line_csr IS
      SELECT Project_ID,
	     Task_ID,
	     Old_Attribute_Value,
	     New_Attribute_Value,
	     Update_Flag,
	     Recalculate_Flag,
	     Rejection_Reason
        FROM pa_mass_update_details
       WHERE rowid = X_rowid
         FOR UPDATE NOWAIT;

    l_line_rec l_line_csr%ROWTYPE;

  BEGIN

    OPEN l_line_csr;
    FETCH l_line_csr into l_line_rec;
    IF (l_line_csr%NOTFOUND) THEN
      CLOSE l_line_csr;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE l_line_csr;

    IF (
	    (l_line_rec.project_id = X_Project_ID)
	AND (    (l_line_rec.task_id = X_Task_ID)
	      OR (     l_line_rec.task_id IS NULL
		   AND X_Task_ID IS NULL ) )
	AND (    (l_line_rec.old_attribute_value = X_Old_Attribute_Value)
	      OR (     l_line_rec.old_attribute_value IS NULL
		   AND X_Old_Attribute_Value IS NULL ) )
	AND (    (l_line_rec.new_attribute_value = X_New_Attribute_Value)
	      OR (     l_line_rec.new_attribute_value IS NULL
		   AND X_New_Attribute_Value IS NULL ) )
	AND (    (l_line_rec.update_flag = X_Update_Flag)
	      OR (     l_line_rec.update_flag IS NULL
		   AND X_Update_Flag IS NULL ) )
	AND (    (l_line_rec.recalculate_flag = X_Recalculate_Flag)
	      OR (     l_line_rec.recalculate_flag IS NULL
		   AND X_Recalculate_Flag IS NULL ) ) ) THEN

      return;

    ELSE

      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;

    END IF;

  END Lock_Row;



  PROCEDURE Delete_Row(	X_Rowid VARCHAR2 )
  IS
  BEGIN

    DELETE FROM pa_mass_update_details
     WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;

  END Delete_Row;


-- ----------------------------------------------------------
-- Generate_Lines
--   This procedure is used to generate detail lines for the
--   given criteria.
-- ----------------------------------------------------------

  PROCEDURE Generate_Lines(
			X_Batch_ID			NUMBER,
			X_Project_Selection		VARCHAR2,
			X_Search_Project_ID		NUMBER    Default NULL,
			X_Search_Organization_ID	NUMBER    Default NULL,
			X_Task_Selection		VARCHAR2,
			X_New_Organization_ID		NUMBER    Default NULL,
			X_Recalculate_Flag		VARCHAR2  Default 'Y',
			X_Err_Code		 IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Err_Stage		 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Err_Stack		 IN OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
  IS

    l_old_stack	VARCHAR2(630);
    l_user_id 	NUMBER := FND_GLOBAL.User_ID;
    l_login_id 	NUMBER := FND_GLOBAL.Login_ID;
    l_rowid	VARCHAR2(18);
    l_line_id	NUMBER;
    l_date	DATE := sysdate;
    l_proj_organization_id	NUMBER;
    l_update_flag		VARCHAR2(1);
    l_allow_update		VARCHAR2(1);
    l_recalc_flag		VARCHAR2(1);

    --
    -- Cursor for selecting all the tasks for the given project
    --
    CURSOR l_ProjTasks_csr (p_project_id NUMBER) IS
      SELECT task_id, carrying_out_organization_id organization_id
	FROM pa_tasks
       WHERE project_id = p_project_id;

    --
    -- Cursor for selecting all the tasks that belongs to the organization
    -- of the given project
    --
    CURSOR l_OrgTasks_csr (x_project_id NUMBER) IS
      SELECT t.task_id, t.carrying_out_organization_id organization_id
	FROM pa_tasks t, pa_projects p
       WHERE t.carrying_out_organization_id = p.carrying_out_organization_id
         AND t.project_id = p.project_id
	 AND p.project_id = x_project_id;

    --
    -- Cursor for selecting all the projects that belongs to the organization
    -- specified by the X_Search_Organization_ID parameter
    --
    CURSOR l_proj_csr IS
      SELECT p.project_id, p.carrying_out_organization_id organization_id,
	     pa_security.allow_update(p.project_id) allow_update
        FROM pa_projects p
       WHERE
    --       p.project_status_code <> 'CLOSED'. **** Archive Purge changes  ****
             pa_project_stus_utils.is_project_status_closed(p.project_status_code) <> 'Y'
	 AND p.carrying_out_organization_id = X_Search_Organization_ID
	 AND pa_security.Allow_Query(p.project_id) = 'Y';

    --
    -- Line_Exists
    --   This is a local function that will return whether or not the given
    --   Project/Task combination exists in the given batch.
    --
    -- Commenting out the function as part of bug fix : 4629597
  /*
    FUNCTION Line_Exists(
		X_Batch_ID		NUMBER,
		X_Project_ID		NUMBER,
		X_Task_ID		NUMBER DEFAULT NULL )
    RETURN BOOLEAN IS

      l_dummy VARCHAR2(1);

      CURSOR l_line_csr IS
        SELECT 'x'
          FROM pa_mass_update_details
         WHERE batch_id = X_Batch_ID
	   AND project_id = X_Project_ID
 	   AND (    (    task_id   IS NULL
		     AND X_Task_ID IS NULL)
		 OR (task_id = X_Task_ID));

    BEGIN

      OPEN l_line_csr;
      FETCH l_line_csr INTO l_dummy;
      IF (l_line_csr%NOTFOUND) THEN
        CLOSE l_line_csr;
        return FALSE;
      END IF;
      CLOSE l_line_csr;
      return TRUE;

    END Line_Exists; */

  BEGIN
    --
    -- Initialize error information
    --
    X_Err_Code := 0;
    l_old_stack := X_Err_Stack;
    X_Err_Stage := 'generate detail lines <' || to_char(X_Batch_ID) || '><' ||
                   X_Project_Selection || '><' || to_char(X_Search_Project_ID) ||
		   to_char(X_Search_Organization_ID) || X_Task_Selection || '><' ||
		   to_char(X_New_Organization_ID);

   --Bug 4629597. Delete the cached Lines. Please see the bug for more details
    DELETE
    FROM   pa_mass_update_details
    WHERE  batch_id=X_Batch_ID;

    IF (X_Project_Selection = 'NAME') THEN
      --
      -- We are selecting the project by name (project_id)
      --

      -- Get the organization_id of the given project
      SELECT carrying_out_organization_id,
	     pa_security.allow_update(project_id)
        INTO l_proj_organization_id, l_allow_update
        FROM pa_projects
       WHERE project_id = X_Search_Project_ID;

      --Bug 4629597.
      --IF (NOT (line_exists(X_Batch_ID, X_Search_Project_ID, NULL))) THEN

        --
	-- If the old and the new organization are the same, we still
	-- create the line; however, the Update_Flag and the
	-- Recalculate_Flag will be set to 'N'
	--
	IF (l_allow_update = 'N') OR
	   (l_proj_organization_id = X_New_Organization_ID) THEN
	  l_update_flag := 'N';
 	  l_recalc_flag := 'N';
	ELSE
	  l_update_flag := 'Y';
	  l_recalc_flag := X_Recalculate_Flag;
	END IF;

	INSERT_ROW(
		X_Rowid			=>	l_rowid,
		X_Line_ID		=>	l_line_id,
		X_Batch_ID		=>	X_Batch_ID,
		X_Creation_Date		=>	l_date,
		X_Created_By		=>	l_user_id,
		X_Last_Updated_By	=>	l_user_id,
		X_Last_Update_Date	=>	l_date,
		X_Last_Update_Login	=>	l_login_id,
		X_Project_ID		=>	X_Search_Project_ID,
		X_Task_ID		=>	NULL,
		X_Old_Attribute_Value	=>	to_char(l_proj_organization_id),
		X_New_Attribute_Value	=>	to_char(X_New_Organization_ID),
		X_Update_Flag		=>	l_update_flag,
		X_Recalculate_Flag	=>	l_recalc_flag );

      -- END IF; -- Fix for bug : 4629597

      IF (X_Task_Selection = 'ALL') THEN
	--
	-- We need to generate a line for all the tasks of the
	-- given project
	--
 	FOR l_task_rec IN l_ProjTasks_csr(X_Search_Project_ID) LOOP
          -- Commenting out the function as part of bug fix : 4629597
	 /* IF (NOT (line_exists(X_Batch_ID,
			       X_Search_Project_ID,
			       l_task_rec.task_id))) THEN */

            --
	    -- If the old and the new organization are the same, we still
	    -- create the line; however, the Update_Flag and the
	    -- Recalculate_Flag will be set to 'N'
	    --
	    IF (l_allow_update = 'N') OR
	       (l_task_rec.organization_id = X_New_Organization_ID) THEN
	      l_update_flag := 'N';
	      l_recalc_flag := 'N';
	    ELSE
	      l_update_flag := 'Y';
	      l_recalc_flag := X_Recalculate_Flag;
	    END IF;

	    INSERT_ROW(
		X_Rowid			=>	l_rowid,
		X_Line_ID		=>	l_line_id,
		X_Batch_ID		=>	X_Batch_ID,
		X_Creation_Date		=>	l_date,
		X_Created_By		=>	l_user_id,
		X_Last_Updated_By	=>	l_user_id,
		X_Last_Update_Date	=>	l_date,
		X_Last_Update_Login	=>	l_login_id,
		X_Project_ID		=>	X_Search_Project_ID,
		X_Task_ID		=>	l_task_rec.task_id,
		X_Old_Attribute_Value	=>	to_char(l_task_rec.organization_id),
		X_New_Attribute_Value	=>	to_char(X_New_Organization_ID),
		X_Update_Flag		=>	l_update_flag,
		X_Recalculate_Flag	=>	l_recalc_flag );

	  -- END IF; -- Fix for bug : 4629597

	END LOOP;

      ELSIF (X_Task_Selection = 'ORG') THEN
	--
	-- We need to generate a line for all the tasks with the same
	-- organization as the given project
	--
 	FOR l_task_rec IN l_OrgTasks_csr(X_Search_Project_ID) LOOP

-- Commenting out the function as part of bug fix : 4629597
/*	  IF (NOT (line_exists(X_Batch_ID,
			       X_Search_Project_ID,
			       l_task_rec.task_id))) THEN */

            --
	    -- If the old and the new organization are the same, we still
	    -- create the line; however, the Update_Flag and the
	    -- Recalculate_Flag will be set to 'N'
	    --
	    IF (l_allow_update = 'N') OR
	       (l_task_rec.organization_id = X_New_Organization_ID) THEN
	      l_update_flag := 'N';
	      l_recalc_flag := 'N';
	    ELSE
	      l_update_flag := 'Y';
	      l_recalc_flag := X_Recalculate_Flag;
	    END IF;

	    INSERT_ROW(
		X_Rowid			=>	l_rowid,
		X_Line_ID		=>	l_line_id,
		X_Batch_ID		=>	X_Batch_ID,
		X_Creation_Date		=>	l_date,
		X_Created_By		=>	l_user_id,
		X_Last_Updated_By	=>	l_user_id,
		X_Last_Update_Date	=>	l_date,
		X_Last_Update_Login	=>	l_login_id,
		X_Project_ID		=>	X_Search_Project_ID,
		X_Task_ID		=>	l_task_rec.task_id,
		X_Old_Attribute_Value	=>	to_char(l_task_rec.organization_id),
		X_New_Attribute_Value	=>	to_char(X_New_Organization_ID),
		X_Update_Flag		=>	l_update_flag,
		X_Recalculate_Flag	=>	l_recalc_flag );

	 --  END IF; -- Fix for bug : 4629597

	END LOOP;

      END IF;

    ELSIF (X_Project_Selection = 'ORG') THEN
      --
      -- We are selecting the project by organization.  Use a cursor
      -- loop to go through all the projects with the given organization
      --
      FOR l_proj_rec IN l_proj_csr LOOP
     -- Commenting out the function as part of bug fix : 4629597
      /*  IF (NOT (line_exists(X_Batch_ID,
			     l_proj_rec.project_id,
			     NULL))) THEN */

          --
	  -- If the old and the new organization are the same, we still
	  -- create the line; however, the Update_Flag and the
	  -- Recalculate_Flag will be set to 'N'
	  --
	  IF (l_proj_rec.allow_update = 'N') OR
	     (X_Search_Organization_ID = X_New_Organization_ID) THEN
	    l_update_flag := 'N';
	    l_recalc_flag := 'N';
	  ELSE
	    l_update_flag := 'Y';
	    l_recalc_flag := X_Recalculate_Flag;
	  END IF;

          INSERT_ROW(
		X_Rowid			=>	l_rowid,
		X_Line_ID		=>	l_line_id,
		X_Batch_ID		=>	X_Batch_ID,
		X_Creation_Date		=>	l_date,
		X_Created_By		=>	l_user_id,
		X_Last_Updated_By	=>	l_user_id,
		X_Last_Update_Date	=>	l_date,
		X_Last_Update_Login	=>	l_login_id,
		X_Project_ID		=>	l_proj_rec.project_id,
		X_Task_ID		=>	NULL,
		X_Old_Attribute_Value	=>	to_char(X_Search_Organization_ID),
		X_New_Attribute_Value	=>	to_char(X_New_Organization_ID),
		X_Update_Flag		=>	l_update_flag,
		X_Recalculate_Flag	=>	l_recalc_flag );

      -- END IF; -- Fix for bug : 4629597

      IF (X_Task_Selection = 'ALL') THEN
	--
	-- We need to generate a line for all the tasks of the
	-- current project in the loop
	--
 	FOR l_task_rec IN l_ProjTasks_csr(l_proj_rec.project_id) LOOP
-- Commenting out the function as part of bug fix : 4629597
  	 /* IF (NOT (line_exists(X_Batch_ID,
			       l_proj_rec.project_id,
			       l_task_rec.task_id))) THEN */

            --
	    -- If the old and the new organization are the same, we still
	    -- create the line; however, the Update_Flag and the
	    -- Recalculate_Flag will be set to 'N'
	    --
	    IF (l_proj_rec.allow_update = 'N') OR
	       (l_task_rec.organization_id = X_New_Organization_ID) THEN
	      l_update_flag := 'N';
	      l_recalc_flag := 'N';
	    ELSE
	      l_update_flag := 'Y';
	      l_recalc_flag := X_Recalculate_Flag;
	    END IF;

	    INSERT_ROW(
		X_Rowid			=>	l_rowid,
		X_Line_ID		=>	l_line_id,
		X_Batch_ID		=>	X_Batch_ID,
		X_Creation_Date		=>	l_date,
		X_Created_By		=>	l_user_id,
		X_Last_Updated_By	=>	l_user_id,
		X_Last_Update_Date	=>	l_date,
		X_Last_Update_Login	=>	l_login_id,
		X_Project_ID		=>	l_proj_rec.project_id,
		X_Task_ID		=>	l_task_rec.task_id,
		X_Old_Attribute_Value	=>	to_char(l_task_rec.organization_id),
		X_New_Attribute_Value	=>	to_char(X_New_Organization_ID),
		X_Update_Flag		=>	l_update_flag,
		X_Recalculate_Flag	=>	l_recalc_flag );

	--  END IF; -- Fix for bug : 4629597

	END LOOP;

      ELSIF (X_Task_Selection = 'ORG') THEN
	--
	-- We need to generate a line for all the tasks with the same
	-- organization as the current project in the loop
	--
 	FOR l_task_rec IN l_OrgTasks_csr(l_proj_rec.project_id) LOOP

  	/*  IF (NOT (line_exists(X_Batch_ID,
			       l_proj_rec.project_id,
			       l_task_rec.task_id))) THEN */

            --
	    -- If the old and the new organization are the same, we still
	    -- create the line; however, the Update_Flag and the
	    -- Recalculate_Flag will be set to 'N'
	    --
	    IF (l_proj_rec.allow_update = 'N') OR
	       (l_task_rec.organization_id = X_New_Organization_ID) THEN
	      l_update_flag := 'N';
	      l_recalc_flag := 'N';
	    ELSE
	      l_update_flag := 'Y';
	      l_recalc_flag := X_Recalculate_Flag;
	    END IF;

	    INSERT_ROW(
		X_Rowid			=>	l_rowid,
		X_Line_ID		=>	l_line_id,
		X_Batch_ID		=>	X_Batch_ID,
		X_Creation_Date		=>	l_date,
		X_Created_By		=>	l_user_id,
		X_Last_Updated_By	=>	l_user_id,
		X_Last_Update_Date	=>	l_date,
		X_Last_Update_Login	=>	l_login_id,
		X_Project_ID		=>	l_proj_rec.project_id,
		X_Task_ID		=>	l_task_rec.task_id,
		X_Old_Attribute_Value	=>	to_char(l_task_rec.organization_id),
		X_New_Attribute_Value	=>	to_char(X_New_Organization_ID),
		X_Update_Flag		=>	l_update_flag,
		X_Recalculate_Flag	=>	l_recalc_flag );

	 -- END IF; -- Fix for bug : 4629597

	END LOOP;

      END IF;

     END LOOP;

   END IF;

   X_Err_Stack := l_old_stack;

  EXCEPTION
    WHEN OTHERS THEN
      X_Err_Code := SQLCODE;

  END Generate_Lines;


END PA_MU_DETAILS_V_PKG;

/
