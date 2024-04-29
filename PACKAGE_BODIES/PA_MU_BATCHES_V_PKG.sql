--------------------------------------------------------
--  DDL for Package Body PA_MU_BATCHES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MU_BATCHES_V_PKG" as
-- $Header: PAXBAUPB.pls 120.3 2007/02/06 12:11:32 rshaik ship $

-- -------------------------------------------------------------
-- Insert_Row
--   INSERT table handler
-- -------------------------------------------------------------

  PROCEDURE Insert_Row(	X_Rowid                 IN OUT NOCOPY   VARCHAR2, -- 4537865
			X_Batch_ID		IN OUT NOCOPY 	NUMBER, -- 4537865
			X_Org_Id                IN NUMBER DEFAULT NULL, --R12 MOAC Changes: Bug 4363093
			X_Creation_Date			DATE,
			X_Created_By			NUMBER,
			X_Last_Updated_By		NUMBER,
			X_Last_Update_Date		DATE,
			X_Last_Update_Login		NUMBER,
			X_Batch_Name			VARCHAR2,
			X_Batch_status_Code		VARCHAR2,
			X_Description			VARCHAR2,
			X_Project_Attribute		VARCHAR2,
			X_Effective_Date		DATE,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2 )
  IS
    l_batch_id	NUMBER;
    l_org_Id     NUMBER := nvl(X_Org_Id, pa_moac_utils.get_current_org_id); -- R12 MOAC changes
  BEGIN

    SELECT PA_MASS_UPDATE_BATCHES_S.NextVal
      INTO l_batch_id
      FROM dual;

    INSERT INTO PA_MASS_UPDATE_BATCHES
	( 	Batch_ID,
		Batch_Name,
		Description,
		Batch_Status_Code,
		Project_Attribute,
		Effective_Date,
		org_id, --R12 MOAC Changes: Bug 4363093
		Attribute_Category,
		Attribute1,
		Attribute2,
		Attribute3,
		Attribute4,
		Attribute5,
		Attribute6,
		Attribute7,
		Attribute8,
		Attribute9,
		Attribute10,
		Attribute11,
		Attribute12,
		Attribute13,
		Attribute14,
		Attribute15,
		Creation_Date,
		Created_By,
		Last_Update_Date,
		Last_Updated_By,
		Last_Update_Login )
    VALUES
	(	l_batch_id,
		X_Batch_Name,
		X_Description,
		X_Batch_Status_Code,
		X_Project_Attribute,
		trunc(X_Effective_Date),
		l_org_Id, --R12 MOAC Changes: Bug 4363093
		X_Attribute_Category,
		X_Attribute1,
		X_Attribute2,
		X_Attribute3,
		X_Attribute4,
		X_Attribute5,
		X_Attribute6,
		X_Attribute7,
		X_Attribute8,
		X_Attribute9,
		X_Attribute10,
		X_Attribute11,
		X_Attribute12,
		X_Attribute13,
		X_Attribute14,
		X_Attribute15,
		X_Creation_Date,
		X_Created_By,
		X_Last_Update_Date,
		X_Last_Updated_By,
		X_Last_Update_Login
	);

    X_Batch_ID := l_batch_id;

    SELECT rowid INTO X_Rowid
      FROM PA_MASS_UPDATE_BATCHES
     WHERE batch_id = l_batch_id;

  EXCEPTION -- 4537865
  WHEN OTHERS THEN

	X_Rowid := NULL;
	X_Batch_ID := NULL;
	fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_MU_BATCHES_V_PKG'
				,p_procedure_name => 'Insert_Row'
				,p_error_text     => SUBSTRB(SQLERRM,1,240));
	RAISE;
  END Insert_Row;


-- -------------------------------------------------------------
-- Update_Row
--   UPDATE table handler
-- -------------------------------------------------------------

  PROCEDURE Update_Row(	X_Rowid                         VARCHAR2,
			X_Last_Updated_By		NUMBER,
			X_Last_Update_Date		DATE,
			X_Last_Update_Login		NUMBER,
			X_Batch_Name			VARCHAR2,
			X_Batch_status_Code		VARCHAR2,
			X_Rejection_Code		VARCHAR2,
			X_Description			VARCHAR2,
			X_Project_Attribute		VARCHAR2,
                        X_Effective_Date		DATE,
			X_Process_Run_By		NUMBER,
			X_Process_Run_Date		DATE,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2 )
  IS

  BEGIN

    UPDATE pa_mass_update_batches
    SET
	Batch_Name		=	X_Batch_Name,
	Description		=	X_Description,
	Batch_Status_Code	=	X_Batch_Status_Code,
        Rejection_Code          = 	X_Rejection_Code,
	Project_Attribute	=	X_Project_Attribute,
	Process_Run_Date	=	X_Process_Run_Date,
	Process_Run_By		=	X_Process_Run_By,
        Effective_Date		=	trunc(X_Effective_Date),
	Attribute_Category	=	X_Attribute_Category,
	Attribute1		=	X_Attribute1,
	Attribute2		=	X_Attribute2,
	Attribute3		=	X_Attribute3,
	Attribute4		=	X_Attribute4,
	Attribute5		=	X_Attribute5,
	Attribute6		=	X_Attribute6,
	Attribute7		=	X_Attribute7,
	Attribute8		=	X_Attribute8,
	Attribute9		=	X_Attribute9,
	Attribute10		=	X_Attribute10,
	Attribute11		=	X_Attribute11,
	Attribute12		=	X_Attribute12,
	Attribute13		=	X_Attribute13,
	Attribute14		=	X_Attribute14,
	Attribute15		=	X_Attribute15,
	Last_Update_Date	=	X_Last_Update_Date,
	Last_Updated_By		=	X_Last_Updated_By,
	Last_Update_Login	=	X_Last_Update_Login
    WHERE
	rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;

  END Update_Row;


-- -------------------------------------------------------------
-- Lock_Row
--   LOCK table handler
-- -------------------------------------------------------------

  PROCEDURE Lock_Row(	X_Rowid                         VARCHAR2,
			X_Batch_Name			VARCHAR2,
			X_Batch_status_Code		VARCHAR2,
			X_Description			VARCHAR2,
			X_Project_Attribute		VARCHAR2,
			X_Process_Run_By		NUMBER,
			X_Process_Run_Date		DATE,
			X_Effective_Date		DATE,
			X_Rejection_Code		VARCHAR2,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2 )
  IS

    CURSOR l_batch_csr IS
      SELECT Batch_Name,
	     Description,
	     Batch_Status_Code,
	     Process_Run_Date,
	     Process_Run_By,
	     Project_Attribute,
             Effective_Date,
	     Rejection_Code,
	     Attribute_Category,
	     Attribute1,
	     Attribute2,
	     Attribute3,
	     Attribute4,
	     Attribute5,
	     Attribute6,
	     Attribute7,
	     Attribute8,
	     Attribute9,
	     Attribute10,
	     Attribute11,
	     Attribute12,
	     Attribute13,
	     Attribute14,
	     Attribute15
        FROM pa_mass_update_batches
       WHERE rowid = X_rowid
         FOR UPDATE NOWAIT;

    l_batch_rec l_batch_csr%ROWTYPE;

  BEGIN

    OPEN l_batch_csr;
    FETCH l_batch_csr into l_batch_rec;
    IF (l_batch_csr%NOTFOUND) THEN
      CLOSE l_batch_csr;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE l_batch_csr;

    IF (
	    (l_batch_rec.batch_name = X_Batch_Name)
	AND (l_batch_rec.batch_status_code = X_Batch_Status_Code)
	AND (l_batch_rec.project_attribute = X_Project_Attribute)
	AND (    (l_batch_rec.description = X_Description)
	      OR (     l_batch_rec.description IS NULL
		   AND X_Description IS NULL ) )
	AND (    (l_batch_rec.process_run_date = X_Process_Run_Date)
	      OR (     l_batch_rec.process_run_date IS NULL
		   AND X_Process_Run_Date IS NULL) )
	AND   (    (l_batch_rec.process_run_by = X_Process_Run_by)
	      OR (     l_batch_rec.process_run_by IS NULL
		   AND X_Process_Run_By IS NULL) )
	AND  (    (l_batch_rec.effective_date = X_Effective_Date)
	      OR (     l_batch_rec.effective_date IS NULL
		   AND X_Effective_Date IS NULL) )
	AND  (    (l_batch_rec.rejection_code = X_Rejection_Code)
	      OR (     l_batch_rec.rejection_code IS NULL
		   AND X_Rejection_Code IS NULL) )
	AND  (    (l_batch_rec.attribute_category = X_Attribute_Category)
	      OR (     l_batch_rec.attribute_category IS NULL
		   AND X_Attribute_Category IS NULL) )
	AND (    (l_batch_rec.attribute1 = X_Attribute1)
	      OR (     l_batch_rec.attribute1 IS NULL
		   AND X_Attribute1 IS NULL) )
	AND (    (l_batch_rec.attribute2 = X_Attribute2)
	      OR (     l_batch_rec.attribute2 IS NULL
		   AND X_Attribute2 IS NULL) )
	AND (    (l_batch_rec.attribute3 = X_Attribute3)
	      OR (     l_batch_rec.attribute3 IS NULL
		   AND X_Attribute3 IS NULL) )
	AND (    (l_batch_rec.attribute4 = X_Attribute4)
	      OR (     l_batch_rec.attribute4 IS NULL
		   AND X_Attribute4 IS NULL) )
	AND (    (l_batch_rec.attribute5 = X_Attribute5)
	      OR (     l_batch_rec.attribute5 IS NULL
		   AND X_Attribute5 IS NULL) )
	AND (    (l_batch_rec.attribute6 = X_Attribute6)
	      OR (     l_batch_rec.attribute6 IS NULL
		   AND X_Attribute6 IS NULL) )
	AND (    (l_batch_rec.attribute7 = X_Attribute7)
	      OR (     l_batch_rec.attribute7 IS NULL
		   AND X_Attribute7 IS NULL) )
	AND (    (l_batch_rec.attribute8 = X_Attribute8)
	      OR (     l_batch_rec.attribute8 IS NULL
		   AND X_Attribute8 IS NULL) )
	AND (    (l_batch_rec.attribute9 = X_Attribute9)
	      OR (     l_batch_rec.attribute9 IS NULL
		   AND X_Attribute9 IS NULL) )
	AND (    (l_batch_rec.attribute10 = X_Attribute10)
	      OR (     l_batch_rec.attribute10 IS NULL
		   AND X_Attribute10 IS NULL) )
	AND (    (l_batch_rec.attribute11 = X_Attribute11)
	      OR (     l_batch_rec.attribute11 IS NULL
		   AND X_Attribute11 IS NULL) )
	AND (    (l_batch_rec.attribute12 = X_Attribute12)
	      OR (     l_batch_rec.attribute12 IS NULL
		   AND X_Attribute12 IS NULL) )
	AND (    (l_batch_rec.attribute13 = X_Attribute13)
	      OR (     l_batch_rec.attribute13 IS NULL
		   AND X_Attribute13 IS NULL) )
	AND (    (l_batch_rec.attribute14 = X_Attribute14)
	      OR (     l_batch_rec.attribute14 IS NULL
		   AND X_Attribute14 IS NULL) )
	AND (    (l_batch_rec.attribute15 = X_Attribute15)
	      OR (     l_batch_rec.attribute15 IS NULL
		   AND X_Attribute15 IS NULL) ) ) THEN
      return;

    ELSE

      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;

    END IF;

  END Lock_Row;


-- -------------------------------------------------------------
-- Delete_Row
--   DELETE table handler
-- -------------------------------------------------------------

  PROCEDURE Delete_Row(	X_Rowid VARCHAR2 )
  IS

    l_batch_id NUMBER;

  BEGIN

    SELECT batch_id INTO l_batch_id
      FROM pa_mass_update_batches
     WHERE rowid = X_Rowid;

    --
    -- First, delete all the lines for this batch
    --
    BEGIN

      DELETE FROM pa_mass_update_details
       WHERE batch_id = l_batch_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	-- This is okay
        null;
    END;

    DELETE FROM pa_mass_update_batches
     WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;

  END Delete_Row;


-- -------------------------------------------------------------
-- Process_Conc
--    Called by the concurrent program to process batches.  This
--    procedure serves as a wrapper to the Process procedure.
-- -------------------------------------------------------------

  PROCEDURE Proc_Conc(  ERRBUF		OUT NOCOPY	VARCHAR2, -- 4537865
		        RETCODE		OUT	NOCOPY VARCHAR2,  -- 4537865
		        X_Batch_ID 	 IN	NUMBER   DEFAULT NULL,
			X_Request_ID    OUT     NOCOPY NUMBER )    --4537865
IS
    l_errbuf	VARCHAR2(2000);
    l_retcode	VARCHAR2(1);
    l_NO_EMP_RECORD	EXCEPTION;

    CURSOR l_batch_csr IS
      SELECT batch_id
        FROM pa_mass_update_batches
       WHERE batch_status_code = 'S'
         AND trunc(sysdate) >= trunc(nvl(effective_date, sysdate));

  BEGIN
    RETCODE := '0';
    X_Request_ID := FND_GLOBAL.Conc_Request_ID;

    IF (PA_UTILS.GetEmpIdFromUser(FND_GLOBAL.user_id) IS NULL) THEN
      raise l_NO_EMP_RECORD;
    END IF;

    IF (X_Batch_ID IS NOT NULL) THEN

      Process( ERRBUF		=> l_errbuf,
	       RETCODE		=> l_retcode,
	       X_Batch_ID	=> X_Batch_ID,
	       X_Concurrent	=> 'Y',
	       X_All_Batches	=> 'N' );
    ELSE

      FOR l_batch_rec IN l_batch_csr LOOP

        Process( ERRBUF		=> l_errbuf,
	         RETCODE	=> l_retcode,
	         X_Batch_ID	=> l_batch_rec.batch_id,
	         X_Concurrent	=> 'Y',
	         X_All_Batches	=> 'Y' );

      END LOOP;

    END IF;

  EXCEPTION
    WHEN l_NO_EMP_RECORD THEN
      RETCODE := '2';
      fnd_message.set_name('PA', 'PA_ALL_WARN_NO_EMPL_REC');
      ERRBUF := fnd_message.get;

    WHEN OTHERS THEN
      RETCODE := '2';
      ERRBUF := SQLERRM;

  END Proc_Conc;


-- -------------------------------------------------------------
-- Process
--   This procedure can be called online using the Mass Update
--   Batches form or as a concurrent program.  The parameter
--   X_Concurrent indicates how this procedure is being called.
-- -------------------------------------------------------------

  PROCEDURE Process(  ERRBUF		OUT NOCOPY	VARCHAR2, -- 4537865
		      RETCODE		OUT	 NOCOPY VARCHAR2, -- 4537865
		      X_Batch_ID 	 IN	NUMBER,
		      X_Concurrent	 IN	VARCHAR2 DEFAULT 'Y',
		      X_All_Batches	 IN 	VARCHAR2 DEFAULT 'N' )

  IS

    l_batch_status_code	VARCHAR2(1);
    l_project_attribute VARCHAR2(30);
    l_mass_adj_outcome  VARCHAR2(30) := NULL;
    l_dummy1		NUMBER;
    l_dummy2		NUMBER;
    l_proc_status	VARCHAR2(1) := 'C';
    l_effective_date	DATE;
    l_err_code		VARCHAR2(30);
    l_err_stage		VARCHAR2(30);
    l_err_stack		VARCHAR2(2000);
    l_org_func_security VARCHAR2(1);
    l_INVALID_STATUS	EXCEPTION;
    l_VALIDATION_ERROR	EXCEPTION;
    l_INVALID_DATE	EXCEPTION;
    l_PROJECT_CLOSED	EXCEPTION;
    l_UPDATE_NOT_ALLOWED EXCEPTION;
    --
    -- We create a new record type to store the error information
    -- for each batch line that fails to validate.  A PL/SQL table
    -- will be used to store all the failed lines.  We need to do
    -- this because we want to process all the lines even if an
    -- error has occured in one of the lines
    --
    TYPE ErrorRecTyp IS RECORD(
	line_id			NUMBER,
	rejection_reason	VARCHAR2(150) );

    TYPE ErrorTabTyp IS TABLE OF ErrorRecTyp
	INDEX BY BINARY_INTEGER;

    l_Error_Tab		ErrorTabTyp;  -- error table
    l_error_tab_index	NUMBER := 0;  -- table index counter

    -- -----------------------
    -- Cursor declarations
    -- -----------------------
    CURSOR l_batch_csr IS
      SELECT batch_status_code, project_attribute, effective_date
	FROM pa_mass_update_batches b
       WHERE b.batch_id = X_Batch_ID
	 FOR UPDATE;

    CURSOR l_BatchLines_csr IS
      SELECT line_id,
	     project_id,
	     task_id,
	     old_attribute_value,
	     new_attribute_value,
	     update_flag,
	     recalculate_flag,
	     pa_security.allow_update(project_id) allow_update
        FROM pa_mass_update_details
       WHERE batch_id = X_Batch_ID
	 FOR UPDATE;

    --
    -- This cursor is used to retrieve the necessary project/
    -- task information for attribute change validation.
    -- Note that in the case where the task ID is NULL, all
    -- the tasks for the project will be selected by the cursor.
    -- However, we'll only fetch the first record and decode all
    -- the task fields to NULL
    --
    CURSOR l_ProjTask_csr (x_project_id NUMBER,
			   x_task_id	NUMBER ) IS
      SELECT x_project_id	PROJECT_ID,
	     x_task_id		TASK_ID,
	     decode(x_task_id,
		    NULL, p.carrying_out_organization_id,
		    t.carrying_out_organization_id) OLD_VALUE,
	     p.project_type	PROJECT_TYPE,
	     p.start_date	PROJECT_START_DATE,
	     p.completion_date	PROJECT_END_DATE,
             pa_project_stus_utils.is_project_status_closed(
				p.project_status_code) PROJECT_CLOSED,
	     p.public_sector_flag,
	     decode(x_task_id,
		    NULL, NULL,
	     	    t.task_manager_person_id) TASK_MANAGER_PERSON_ID,
	     decode(x_task_id,
		    NULL, NULL,
	     	    t.service_type_code) SERVICE_TYPE_CODE,
	     decode(x_task_id,
		    NULL, NULL,
	     	    t.start_date) TASK_START_DATE,
	     decode(x_task_id,
		    NULL, NULL,
	     	    t.completion_date) TASK_END_DATE,
	     decode(x_task_id,
		    NULL, p.attribute_category,
		    t.attribute_category) ATTRIBUTE_CATEGORY,
	     decode(x_task_id,
		    NULL, p.attribute1,
		    t.attribute1) ATTRIBUTE1,
	     decode(x_task_id,
		    NULL, p.attribute2,
		    t.attribute2) ATTRIBUTE2,
	     decode(x_task_id,
		    NULL, p.attribute3,
		    t.attribute3) ATTRIBUTE3,
	     decode(x_task_id,
		    NULL, p.attribute4,
		    t.attribute4) ATTRIBUTE4,
	     decode(x_task_id,
		    NULL, p.attribute5,
		    t.attribute5) ATTRIBUTE5,
	     decode(x_task_id,
		    NULL, p.attribute6,
		    t.attribute6) ATTRIBUTE6,
	     decode(x_task_id,
		    NULL, p.attribute7,
		    t.attribute7) ATTRIBUTE7,
	     decode(x_task_id,
		    NULL, p.attribute8,
		    t.attribute8) ATTRIBUTE8,
	     decode(x_task_id,
		    NULL, p.attribute9,
		    t.attribute9) ATTRIBUTE9,
	     decode(x_task_id,
		    NULL, p.attribute10,
		    t.attribute10) ATTRIBUTE10,
	     decode(x_task_id,
		    NULL, p.pm_product_code,
		    t.pm_product_code) PM_PRODUCT_CODE,
	     p.pm_project_reference,
	     decode(x_task_id,
		    NULL, NULL,
	     	    t.pm_task_reference) PM_TASK_REFERENCE
	FROM pa_projects_all p,
	     pa_tasks	     t
       WHERE p.project_id = x_project_id
	 AND t.project_id = p.project_id
	 AND (   x_task_id IS NULL
	      OR t.task_id = x_task_id );

    l_ProjTask_rec l_ProjTask_csr%ROWTYPE;
      l_warnings_only_flag VARCHAR2(1) := 'N'; --bug3134205
    -- ---------------------------------------------------
    -- Set_Error
    --   This local procedure takes in an error code and
    --   tries to retrieve the error message.  The error
    --   information is then stored in the error table.
    -- ---------------------------------------------------
    PROCEDURE Set_Error(p_err_code VARCHAR2,
			p_line_id  NUMBER) IS
      l_error_msg    VARCHAR2(150):= NULL;
      l_error_number NUMBER := 0;
    BEGIN
      --
      -- First check to see if this is a PA error
      --
      IF (SUBSTRB(p_err_code, 1, 3) = 'PA_') THEN
        fnd_message.set_name('PA', p_err_code);
	l_error_msg := SUBSTRB(fnd_message.get, 1, 150);
      ELSE
	--
	-- Not a PA error; check to see if it's a SQL error
	--
	BEGIN
	  l_error_number := to_number(p_err_code);
	  l_error_msg := SUBSTRB(SQLERRM(l_error_number), 1, 150);

	EXCEPTION
	  WHEN OTHERS THEN
	    --
	    -- Not a SQL error either; just set the error msg to
	    -- the error code
	    --
	    l_error_msg := p_err_code;
	END;
      END IF;

      l_error_tab_index := l_error_tab_index + 1;
      l_Error_Tab(l_error_tab_index).line_id := p_line_id;
      l_Error_Tab(l_error_tab_index).rejection_reason := l_error_msg;

    END Set_Error;

  BEGIN
    ERRBUF := NULL;
    RETCODE := '0';

    OPEN l_batch_csr;
    FETCH l_batch_csr
     INTO l_batch_status_code, l_project_attribute, l_effective_date;
    IF (l_batch_csr%NOTFOUND) THEN
      CLOSE l_batch_csr;
      raise NO_DATA_FOUND;
    END IF;

    --
    -- If this procedure is being run as a concurrent process,
    -- we need to make sure that the the status of the batch is
    -- 'Submitted' and the effective date is before sysdate
    --
    IF (X_Concurrent = 'Y') THEN
      IF (l_batch_status_code = 'S') THEN
        IF (not (trunc(sysdate) >= trunc(nvl(l_effective_date, sysdate)))) THEN
          CLOSE l_batch_csr;
          raise l_INVALID_DATE;
        END IF;
        --
	-- Change the status to 'Running'
	--
        UPDATE pa_mass_update_batches
           SET batch_status_code = 'P',
	       rejection_code = NULL,
	       process_run_date = sysdate,
	       process_run_by = FND_GLOBAL.user_id,
	       request_id = FND_GLOBAL.Conc_Request_ID,
	       program_application_id = FND_GLOBAL.Prog_Appl_ID,
	       program_id = FND_GLOBAL.Conc_Program_ID,
	       last_update_login = FND_GLOBAL.Conc_Login_ID,
	       program_update_date = sysdate
         WHERE CURRENT OF l_batch_csr;
	--
	-- Commit to release the lock
	--
        COMMIT;
      ELSE
        CLOSE l_batch_csr;
        raise l_INVALID_STATUS;
      END IF;
    END IF;

    CLOSE l_batch_csr;

    -- Reset the rejection reason for all the lines
    UPDATE pa_mass_update_details
       SET rejection_reason = NULL,
	   last_updated_by = FND_GLOBAL.user_id,
	   last_update_date = sysdate,
	   last_update_login = FND_GLOBAL.login_id
     WHERE batch_id = X_Batch_ID
       AND rejection_reason IS NOT NULL;

    --
    -- Test the function security for Org changes
    --
    IF (fnd_function.test('PA_PAXPREPR_UPDATE_ORG') = TRUE) THEN
      l_org_func_security := 'Y';
    ELSE
      l_org_func_security := 'N';
    END IF;

    --
    -- We need to establish a savepoint here.  Once all the
    -- lines have been processed, if any error has occurred
    -- all the changes will have to be rolled back because
    -- we only apply changes on a ALL or NONE basis
    --
    SAVEPOINT Process_Batch;

    --
    -- Loop through all the lines to validate and process
    --
    FOR l_BatchLine_rec IN l_BatchLines_csr LOOP
      BEGIN
        IF (l_BatchLine_rec.update_flag = 'Y') THEN
	  --
	  -- Make sure user has proper security to update the project
	  --
	  IF (l_BatchLine_rec.allow_update = 'Y') THEN
	    null;
	  ELSE
	    raise l_UPDATE_NOT_ALLOWED;
	  END IF;

	  OPEN l_ProjTask_csr(l_BatchLine_rec.project_id,
			      l_BatchLine_rec.task_id);
	  FETCH l_ProjTask_csr INTO l_ProjTask_rec;
    	  IF (l_ProjTask_csr%NOTFOUND) THEN
      	    CLOSE l_ProjTask_csr;
      	    raise NO_DATA_FOUND;
    	  END IF;
	  CLOSE l_ProjTask_Csr;

          --
          -- Make sure project is not closed
	  --
          IF (l_ProjTask_rec.project_closed = 'Y') THEN
            raise l_PROJECT_CLOSED;
          END IF;

          --
	  -- Validate the attribute change to make sure that it is allowed
	  --
	  l_err_code := 0;
	  l_err_stage := NULL;
          PA_PROJECT_UTILS2.Validate_Attribute_Change(
		X_Context		  =>  'ORGANIZATION_VALIDATION',
		X_insert_update_mode	  =>  'UPDATE',
		X_calling_module 	  =>  'PAXBAUPD',
		X_project_id		  =>  l_ProjTask_rec.project_id,
		X_task_id		  =>  l_ProjTask_rec.task_id,
		X_old_value		  =>  l_ProjTask_rec.old_value,
		X_new_value		  =>  l_BatchLine_rec.new_attribute_value,
		X_project_type		  =>  l_ProjTask_rec.project_type,
		X_project_start_date	  =>  l_ProjTask_rec.project_start_date,
		X_project_end_date	  =>  l_ProjTask_rec.project_end_date,
		X_public_sector_flag	  =>  l_ProjTask_rec.public_sector_flag,
		X_task_manager_person_id  =>  l_ProjTask_rec.task_manager_person_id,
		X_Service_type		  =>  l_ProjTask_rec.service_type_code,
		X_task_start_date	  =>  l_ProjTask_rec.task_start_date,
		X_task_end_date		  =>  l_ProjTask_rec.task_end_date,
		X_entered_by_user_id	  =>  FND_GLOBAL.user_id,
		X_attribute_category	  =>  l_ProjTask_rec.attribute_category,
		X_attribute1		  =>  l_ProjTask_rec.attribute1,
		X_attribute2		  =>  l_ProjTask_rec.attribute2,
   		X_attribute3		  =>  l_ProjTask_rec.attribute3,
    		X_attribute4		  =>  l_ProjTask_rec.attribute4,
    		X_attribute5		  =>  l_ProjTask_rec.attribute5,
    		X_attribute6		  =>  l_ProjTask_rec.attribute6,
    		X_attribute7		  =>  l_ProjTask_rec.attribute7,
    		X_attribute8		  =>  l_ProjTask_rec.attribute8,
    		X_attribute9		  =>  l_ProjTask_rec.attribute9,
    		X_attribute10		  =>  l_ProjTask_rec.attribute10,
    		X_pm_product_code	  =>  l_ProjTask_rec.pm_product_code,
    		X_pm_project_reference	  =>  l_ProjTask_rec.pm_project_reference,
    		X_pm_task_reference	  =>  l_ProjTask_rec.pm_task_reference,
    		X_functional_security_flag => l_org_func_security,
	        x_warnings_only_flag      =>  l_warnings_only_flag, --bug3134205
    		X_err_code	   	  =>  l_err_code,
    		X_err_stage	   	  =>  l_err_stage,
    		X_err_stack	   	  =>  l_err_stack );

          IF (l_err_stage IS NOT NULL) THEN
            raise l_VALIDATION_ERROR;
	  END IF;

          --
	  -- Now we can process the line
	  --
          IF (l_project_attribute = 'ORGANIZATION') THEN

            IF (l_BatchLine_rec.task_id IS NULL) THEN
	      IF (X_Concurrent = 'Y') THEN

	        UPDATE pa_projects_all
	           SET carrying_out_organization_id =
			  to_number(l_BatchLine_rec.new_attribute_value),
		       request_id = FND_GLOBAL.Conc_Request_ID,
		       program_application_id = FND_GLOBAL.Prog_Appl_ID,
		       program_id = FND_GLOBAL.Conc_Program_ID,
		       last_update_login = FND_GLOBAL.Conc_Login_ID,
		       program_update_date = sysdate
	         WHERE project_id = l_BatchLine_rec.project_id;

	      ELSE

	        UPDATE pa_projects_all
	           SET carrying_out_organization_id =
			  to_number(l_BatchLine_rec.new_attribute_value),
		       last_updated_by = FND_GLOBAL.User_ID,
		       last_update_login = FND_GLOBAL.Login_ID,
		       last_update_date = sysdate
	         WHERE project_id = l_BatchLine_rec.project_id;

              END IF; -- (X_Concurrent = 'Y')
            ELSE
	      IF (X_Concurrent = 'Y') THEN

	        UPDATE pa_tasks
	           SET carrying_out_organization_id =
			  to_number(l_BatchLine_rec.new_attribute_value),
		       request_id = FND_GLOBAL.Conc_Request_ID,
		       program_application_id = FND_GLOBAL.Prog_Appl_ID,
		       program_id = FND_GLOBAL.Conc_Program_ID,
		       last_update_login = FND_GLOBAL.Conc_Login_ID,
		       program_update_date = sysdate
	         WHERE task_id = l_BatchLine_rec.task_id;

                /* Added for bug#5718668 by anuagraw */
                UPDATE pa_proj_elements
                   SET carrying_out_organization_id =
                          to_number(l_BatchLine_rec.new_attribute_value),
                       request_id = FND_GLOBAL.Conc_Request_ID,
                       program_application_id = FND_GLOBAL.Prog_Appl_ID,
                       program_id = FND_GLOBAL.Conc_Program_ID,
                       last_update_login = FND_GLOBAL.Conc_Login_ID,
                       program_update_date = sysdate
                 WHERE proj_element_id = l_BatchLine_rec.task_id;
                 /* Added for bug#5718668 by anuagraw */

	      ELSE

	        UPDATE pa_tasks
	           SET carrying_out_organization_id =
			  to_number(l_BatchLine_rec.new_attribute_value),
		       last_updated_by = FND_GLOBAL.User_ID,
		       last_update_login = FND_GLOBAL.Login_ID,
		       last_update_date = sysdate
	         WHERE task_id = l_BatchLine_rec.task_id;

                 /* Added for bug#5718668 by anuagraw */
                UPDATE pa_proj_elements
                   SET carrying_out_organization_id =
                          to_number(l_BatchLine_rec.new_attribute_value),
                       last_updated_by = FND_GLOBAL.User_ID,
                       last_update_login = FND_GLOBAL.Login_ID,
                       last_update_date = sysdate
                 WHERE proj_element_id = l_BatchLine_rec.task_id;
                 /* Added for bug#5718668 by anuagraw */


	      END IF;  -- (X_Concurrent = 'Y')
            END IF;   -- (l_BatchLine_rec.task_id IS NULL)
          END IF;   -- (l_project_attribute = 'ORGANIZATION')

          --
          -- See if we need to perform recalculation
	  --
          IF (l_BatchLine_rec.recalculate_flag = 'Y') THEN

	    PA_ADJUSTMENTS.MassAdjust(
		X_adj_action	=>  'COST AND REV RECALC',
		X_module	=>  'PAXBAUPD',
		X_user		=>  FND_GLOBAL.User_ID,
		X_login		=>  FND_GLOBAL.Login_ID,
		X_project_id	=>  l_BatchLine_rec.project_id,
		X_task_id	=>  l_BatchLine_rec.task_id,
		X_ei_date_low	=>  l_effective_date,
		X_outcome	=>  l_mass_adj_outcome,
		X_num_processed	=>  l_dummy1,
		X_num_rejected	=>  l_dummy2 );


          /* Added the following call to process Cross Charge Txn */
          /* Code Starts here                  */

           PA_ADJUSTMENTS.MassAdjust(
                X_adj_action    =>  'REPROCESS CROSS CHARGE',
                X_module        =>  'PAXBAUPD',
                X_user          =>  FND_GLOBAL.User_ID,
                X_login         =>  FND_GLOBAL.Login_ID,
                X_project_id    =>  l_BatchLine_rec.project_id,
                X_task_id       =>  l_BatchLine_rec.task_id,
                X_ei_date_low   =>  l_effective_date,
                X_outcome       =>  l_mass_adj_outcome,
                X_num_processed =>  l_dummy1,
                X_num_rejected  =>  l_dummy2 );

            /* Code ends here                  */


	    /* Bug 3421201 :Added the following call to process Recalculate
	       burden cost for 'VI' transactions */
            /* Code Starts here                  */

           PA_ADJUSTMENTS.MassAdjust(
                X_adj_action     =>  'INDIRECT COST RECALC',
                X_module         =>  'PAXBAUPD',
                X_user           =>  FND_GLOBAL.User_ID,
                X_login          =>  FND_GLOBAL.Login_ID,
                X_project_id     =>  l_BatchLine_rec.project_id,
                X_task_id        =>  l_BatchLine_rec.task_id,
		X_system_linkage =>  'VI',
                X_ei_date_low    =>  l_effective_date,
                X_outcome        =>  l_mass_adj_outcome,
                X_num_processed  =>  l_dummy1,
                X_num_rejected   =>  l_dummy2 );

            /* Code ends here                  */





          END IF;   -- (l_BatchLine_rec.recalculate_flag = 'Y')
        END IF;   -- (l_BatchLine_rec.update_flag = 'Y')

      EXCEPTION
        WHEN l_PROJECT_CLOSED THEN
	  l_err_stage := 'PA_MU_PROJECT_CLOSED';
          Set_Error(l_err_stage, l_BatchLine_rec.line_id);

	WHEN l_VALIDATION_ERROR THEN
          Set_Error(l_err_stage, l_BatchLine_rec.line_id);

	WHEN l_UPDATE_NOT_ALLOWED THEN
	  l_err_stage := 'PA_PR_UPDATE_NOT_ALLOWED';
          Set_Error(l_err_stage, l_BatchLine_rec.line_id);

	WHEN OTHERS THEN
	  l_error_tab_index := l_error_tab_index + 1;
	  l_Error_Tab(l_error_tab_index).line_id := l_BatchLine_rec.line_id;
	  l_Error_Tab(l_error_tab_index).rejection_reason := SUBSTRB(SQLERRM, 1, 150);

      END;
    END LOOP;

    --
    -- Check to see if there are any errors
    --
    IF (l_error_tab_index > 0) THEN
      --
      -- Roll back the previous changes and update the error
      -- information in each of the batch lines that failed
      --
      ROLLBACK TO Process_Batch;

      FOR i IN l_Error_Tab.FIRST .. l_Error_Tab.LAST LOOP
         UPDATE pa_mass_update_details
	    SET rejection_reason = l_Error_Tab(i).rejection_reason,
		last_updated_by = FND_GLOBAL.user_id,
		last_update_date = sysdate,
		last_update_login = FND_GLOBAL.login_id
	  WHERE batch_id = X_Batch_ID
	    AND line_id = l_Error_Tab(i).line_id;
      END LOOP;
      --
      -- Set the status to 'Rejected'
      --
      l_proc_status := 'R';
      RETCODE := '1';
      ERRBUF := 'LINES_REJECTED';
    END IF;

    IF (X_Concurrent = 'Y') THEN
      --
      -- Update the batch status
      --
      UPDATE pa_mass_update_batches
         SET batch_status_code = l_proc_status,
	     rejection_code = ERRBUF,
	     process_run_by = FND_GLOBAL.user_id,
	     process_run_date = sysdate,
	     program_application_id = FND_GLOBAL.Prog_Appl_ID,
	     program_id = FND_GLOBAL.Conc_Program_ID,
	     last_update_login = FND_GLOBAL.Conc_Login_ID,
	     program_update_date = sysdate
       WHERE batch_id = X_Batch_ID;

      COMMIT;

    END IF;

  EXCEPTION
    WHEN l_INVALID_STATUS THEN
      --
      -- Should only happen when run as a concurrent program
      -- Reset the status back to submitted
      --
      IF (X_All_Batches = 'N') THEN
        RETCODE := '1';
        ERRBUF := 'INVALID_STATUS';
        UPDATE pa_mass_update_batches
           SET batch_status_code = 'R',
	       rejection_code = 'INVALID_STATUS',
	       process_run_by = FND_GLOBAL.user_id,
	       process_run_date = sysdate,
	       program_application_id = FND_GLOBAL.Prog_Appl_ID,
	       program_id = FND_GLOBAL.Conc_Program_ID,
	       last_update_login = FND_GLOBAL.Conc_Login_ID,
	       program_update_date = sysdate
         WHERE batch_id = X_Batch_ID;
         COMMIT;
      END IF;

    WHEN l_INVALID_DATE THEN
      --
      -- Should only happen when run as a concurrent program
      -- Reset the status back to submitted
      --
      IF (X_All_Batches = 'N') THEN
        RETCODE := '1';
        ERRBUF := 'EFFECTIVE_DATE';
        UPDATE pa_mass_update_batches
           SET batch_status_code = 'R',
	       rejection_code = 'EFFECTIVE_DATE',
	       process_run_by = FND_GLOBAL.user_id,
	       process_run_date = sysdate,
	       program_application_id = FND_GLOBAL.Prog_Appl_ID,
	       program_id = FND_GLOBAL.Conc_Program_ID,
	       last_update_login = FND_GLOBAL.Conc_Login_ID,
	       program_update_date = sysdate
         WHERE batch_id = X_Batch_ID;
         COMMIT;
      END IF;

    WHEN OTHERS THEN
      IF (l_batch_csr%ISOPEN) THEN
        CLOSE l_batch_csr;
      END IF;

      RETCODE := '1';
      ERRBUF := 'SQL_ERROR';
      IF (X_Concurrent = 'Y') THEN
        UPDATE pa_mass_update_batches
           SET batch_status_code = 'R',
	       rejection_code = 'SQL_ERROR',
	       process_run_by = FND_GLOBAL.user_id,
	       process_run_date = sysdate,
	       program_application_id = FND_GLOBAL.Prog_Appl_ID,
	       program_id = FND_GLOBAL.Conc_Program_ID,
	       last_update_login = FND_GLOBAL.Conc_Login_ID,
	       program_update_date = sysdate
         WHERE batch_id = X_Batch_ID;
        COMMIT;
      END IF;
  END Process;


END PA_MU_BATCHES_V_PKG;

/
