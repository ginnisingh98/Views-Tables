--------------------------------------------------------
--  DDL for Package Body PA_PERCENT_COMPLETE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERCENT_COMPLETE_PKG" AS
/*$Header: PAXPRPCB.pls 120.2 2005/08/23 22:43:44 avaithia noship $*/


PROCEDURE Lock_Row
            (
	x_rowid			IN 	  	VARCHAR2
	, x_project_id		IN 	  	NUMBER
	, x_task_id		IN		NUMBER
	, x_percent_complete	IN		NUMBER
	, x_as_of_date		IN		DATE
	, x_current_flag		IN		VARCHAR2
	, x_pm_product_code	IN		VARCHAR2
	, x_description		IN		VARCHAR2
	, x_last_update_date	IN		DATE
	, x_last_updated_by	IN		NUMBER
	, x_creation_date		IN		DATE
	, x_created_by		IN		NUMBER
	, x_last_update_login	IN		NUMBER
	) IS

	CURSOR  l_percent_cmpl_csr
	IS
	SELECT	*
	FROM		pa_percent_completes
	WHERE		rowid = x_rowid
	FOR UPDATE	of  project_id NOWAIT;

	Recinfo  l_percent_cmpl_csr%ROWTYPE;

BEGIN

	OPEN l_percent_cmpl_csr;

	FETCH l_percent_cmpl_csr INTO Recinfo;

	IF (l_percent_cmpl_csr%NOTFOUND) THEN
		CLOSE l_percent_cmpl_csr;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	END IF;

	IF (

			(recinfo.task_id = x_task_id)
		AND	(recinfo.date_computed = x_as_of_date)
		AND	(   (recinfo.completed_percentage = x_percent_complete)
			   OR  (	 (recinfo.completed_percentage IS NULL)
				  AND (x_percent_complete IS NULL) ) )

		AND	(   (RTRIM(recinfo.description) = RTRIM(x_description))
			   OR  (	 (recinfo.description IS NULL)
				  AND (x_description IS NULL) ) )

		AND	(   (recinfo.project_id = x_project_id)
			   OR  (	 (recinfo.project_id IS NULL)
				  AND (x_project_id IS NULL) ) )

		)  THEN
			CLOSE l_percent_cmpl_csr;
			RETURN;
	ELSE
			CLOSE l_percent_cmpl_csr;
			FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
			APP_EXCEPTION.Raise_Exception;
	END IF;
END Lock_Row;
-- =================================================

PROCEDURE Insert_Row
            (
	 x_project_id		IN 	  	NUMBER
	, x_task_id		IN		NUMBER
	, x_percent_complete	IN		NUMBER
	, x_as_of_date		IN		DATE
	, x_description		IN		VARCHAR2
	, x_last_update_date	IN		DATE
	, x_last_updated_by	IN		NUMBER
	, x_creation_date		IN		DATE
	, x_created_by		IN		NUMBER
	, x_last_update_login	IN		NUMBER
	, x_return_status		OUT		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	, x_msg_data		OUT		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	) IS

	l_msg_count		NUMBER		:= 0;

BEGIN

PA_STATUS_PUB.Update_Progress
	( p_api_version_number  		=>	G_API_VERSION_NUMBER
	  , p_commit			=>	G_COMMIT
	  , p_msg_count			=>	l_msg_count
	  , p_msg_data			=>	x_msg_data
	  , p_init_msg_list		=>	G_INIT_MSG_LIST
	  , p_return_status			=>   	x_return_status
	  , p_project_id			=> 	x_project_id
	  , p_task_id			=> 	x_task_id
	  , p_as_of_date			=>  	x_as_of_date
	  , p_percent_complete		=>  	x_percent_complete
	  , p_description		=>	x_description
	  );

END Insert_Row;
-- ==================================================

PROCEDURE Delete_Row (x_rowid IN VARCHAR2)  IS

BEGIN

	DELETE FROM pa_percent_completes
	WHERE		rowid = x_rowid;
	IF (SQL%NOTFOUND)	THEN
		RAISE NO_DATA_FOUND;
	END IF;

END Delete_Row;
-- ================================================
END pa_percent_complete_pkg ;

/
