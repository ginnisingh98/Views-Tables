--------------------------------------------------------
--  DDL for Package PA_LIFECYCLE_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_LIFECYCLE_USAGES_PKG" AUTHID CURRENT_USER AS
/* $Header: PALCUPKS.pls 115.0 2002/10/21 09:30:52 amksingh noship $ */

-- Start of comments
--	API name 	: INSERT_ROW
--	Type		: Table Handler
--	Pre-reqs	: None.
--	Purpose  	: Insert data in pa_lifecycle_usages table
--	Parameters	:
--	X_LIFECYCLE_USAGE_ID		IN	NUMBER 		Required
--	X_RECORD_VERSION_NUMBER		IN	NUMBER 		Optional	Default 1.0
--	X_LIFECYCLE_ID			IN	NUMBER 		Required
--	X_USAGE_TYPE			IN	NUMBER 		Required
--
--	History         :
--				15-OCT-02  amksingh   Created
-- End of comments

PROCEDURE INSERT_ROW (
  X_LIFECYCLE_USAGE_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER := 1,
  X_LIFECYCLE_ID in NUMBER,
  X_USAGE_TYPE in VARCHAR2
);

-- Start of comments
--	API name 	: LOCK_ROW
--	Type		: Table Handler
--	Pre-reqs	: None.
--	Purpose  	: Locks row before updation and deletion in pa_lifecycle_usages table
--	Parameters	:
--	X_LIFECYCLE_USAGE_ID		IN	NUMBER 		Required
--	X_RECORD_VERSION_NUMBER		IN	NUMBER 		Required
--	X_LIFECYCLE_ID			IN	NUMBER 		Required
--	X_USAGE_TYPE			IN	NUMBER 		Required
--
--	History         :
--				15-OCT-02  amksingh   Created
-- End of comments

PROCEDURE LOCK_ROW (
  X_LIFECYCLE_USAGE_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_LIFECYCLE_ID in NUMBER,
  X_USAGE_TYPE in VARCHAR2
);

-- Start of comments
--	API name 	: UPDATE_ROW
--	Type		: Table Handler
--	Pre-reqs	: None.
--	Purpose  	: Updates row in pa_lifecycle_usages table
--	Parameters	:
--	X_LIFECYCLE_USAGE_ID		IN	NUMBER 		Required
--	X_RECORD_VERSION_NUMBER		IN	NUMBER 		Required
--	X_LIFECYCLE_ID			IN	NUMBER 		Required
--	X_USAGE_TYPE			IN	NUMBER 		Required
--
--	History         :
--				15-OCT-02  amksingh   Created
-- End of comments

PROCEDURE UPDATE_ROW (
  X_LIFECYCLE_USAGE_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_LIFECYCLE_ID in NUMBER,
  X_USAGE_TYPE in VARCHAR2
);

-- Start of comments
--	API name 	: UPDATE_ROW
--	Type		: Table Handler
--	Pre-reqs	: None.
--	Purpose  	: Deletes row in pa_lifecycle_usages table
--	Parameters	:
--	X_LIFECYCLE_USAGE_ID		IN	NUMBER 		Required
--
--	History         :
--				15-OCT-02  amksingh   Created
-- End of comments

PROCEDURE DELETE_ROW (
  X_LIFECYCLE_USAGE_ID in NUMBER
);

END PA_LIFECYCLE_USAGES_PKG;

 

/
