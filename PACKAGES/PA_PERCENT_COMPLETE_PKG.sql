--------------------------------------------------------
--  DDL for Package PA_PERCENT_COMPLETE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERCENT_COMPLETE_PKG" AUTHID CURRENT_USER AS
/*$Header: PAXPRPCS.pls 120.1 2005/08/19 17:17:47 mwasowic noship $*/

-- -------------------------------------------------------------------------------------------------------
-- 	Globals
-- -------------------------------------------------------------------------------------------------------

G_PKG_NAME          		CONSTANT  	VARCHAR2(30) := 'PA_PERCENT_COMPLETE_PKG';

G_API_VERSION_NUMBER 	CONSTANT	NUMBER 	:= 1.0;
G_COMMIT			CONSTANT	VARCHAR2(1)	:= FND_API.G_TRUE;
G_INIT_MSG_LIST		CONSTANT	VARCHAR2(1)	:= FND_API.G_TRUE;

-- -------------------------------------------------------------------------------------------------------
-- 	Procedures
-- -------------------------------------------------------------------------------------------------------

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
	);


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
	);


PROCEDURE Delete_Row (x_rowid IN VARCHAR2);




END pa_percent_complete_pkg ;

 

/
