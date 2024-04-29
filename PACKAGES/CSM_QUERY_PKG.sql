--------------------------------------------------------
--  DDL for Package CSM_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_QUERY_PKG" AUTHID CURRENT_USER AS
/* $Header: csmqrys.pls 120.6.12010000.7 2010/06/14 10:18:35 ravir noship $ */


  /*
   * The function to be called by Mobile Admin screen to insert/update/delete a query
   */

-- Purpose: Insert/Delete/Update a Mobile Query
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- TRAJASEK    12th April 2009      Created
--
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below
--Procedure to insert the new query
PROCEDURE INSERT_QUERY
( p_QUERY_ID             IN  NUMBER,
  p_QUERY_NAME           IN  VARCHAR2,
  P_QUERY_DESC           IN  VARCHAR2,
  P_QUERY_TYPE           IN  VARCHAR2,
  p_QUERY_TEXT1          IN  VARCHAR2,
  p_QUERY_TEXT2          IN  VARCHAR2,
  p_LEVEL_ID             IN  NUMBER,
  p_LEVEL_VALUE          IN  NUMBER,
  p_PARENT_QUERY_ID      IN  NUMBER,
  p_SAVED_QUERY          IN  VARCHAR2,
  p_QUERY_OUTPUT_FORMAT  IN  VARCHAR2,
  p_MIME_TYPE            IN  VARCHAR2,
  p_WORK_FLOW            IN  VARCHAR2,
  p_PROCEDURE            IN  VARCHAR2,
  p_RETENTION_POLICY     IN  VARCHAR2,
  p_RETENTION_DAYS       IN  NUMBER,
  p_TEMPLATE             IN  VARCHAR2,
  p_TEMPLATE_FILE        IN  VARCHAR2,
  p_EXECUTION_MODE       IN  VARCHAR2,
  p_VARIABLE_NAME        IN  CSM_VARCHAR_LIST,
  p_VARIABLE_TYPE        IN  CSM_VARCHAR_LIST,
  p_VARIABLE_VALUE_CHAR  IN  CSM_VARCHAR_LIST,
  p_VARIABLE_VALUE_DATE  IN  CSM_DATE_LIST,
  p_HIDDEN_FLAG          IN  CSM_VARCHAR_LIST,
  p_DEFAULT_FLAG         IN  CSM_VARCHAR_LIST,
  p_EMAIL_ENABLED        IN  VARCHAR2,
  p_RESTRICTED_FLAG      IN  VARCHAR2,
  p_DISABLED_FLAG        IN  VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
);

--Procedure to update the existing query
PROCEDURE UPDATE_QUERY
( p_QUERY_ID             IN  NUMBER,
  p_QUERY_NAME           IN  VARCHAR2,
  P_QUERY_DESC           IN  VARCHAR2,
  P_QUERY_TYPE           IN  VARCHAR2,
  p_QUERY_TEXT1          IN  VARCHAR2,
  p_QUERY_TEXT2          IN  VARCHAR2,
  p_LEVEL_ID             IN  NUMBER,
  p_LEVEL_VALUE          IN  NUMBER,
  p_PARENT_QUERY_ID      IN  NUMBER,
  p_SAVED_QUERY          IN  VARCHAR2,
  p_QUERY_OUTPUT_FORMAT  IN  VARCHAR2,
  p_MIME_TYPE            IN  VARCHAR2,
  p_WORK_FLOW            IN  VARCHAR2,
  p_PROCEDURE            IN  VARCHAR2,
  p_RETENTION_POLICY     IN  VARCHAR2,
  p_RETENTION_DAYS       IN  NUMBER,
  p_TEMPLATE             IN  VARCHAR2,
  p_TEMPLATE_FILE        IN  VARCHAR2,
  p_EXECUTION_MODE       IN  VARCHAR2,
  p_VARIABLE_NAME        IN  CSM_VARCHAR_LIST,
  p_VARIABLE_TYPE        IN  CSM_VARCHAR_LIST,
  p_VARIABLE_VALUE_CHAR  IN  CSM_VARCHAR_LIST,
  p_VARIABLE_VALUE_DATE  IN  CSM_DATE_LIST,
  p_HIDDEN_FLAG          IN  CSM_VARCHAR_LIST,
  p_DEFAULT_FLAG         IN  CSM_VARCHAR_LIST,
  p_EMAIL_ENABLED        IN  VARCHAR2,
  p_RESTRICTED_FLAG      IN  VARCHAR2,
  p_DISABLED_FLAG        IN  VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
);


--Prodecure to delete a query that is wrongly added or that is no longer required
PROCEDURE DELETE_QUERY
( p_QUERY_ID             IN  NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
);

--Procedure to Validate a Given Query
PROCEDURE VALIDATE_QUERY
( p_QUERY_ID             IN  NUMBER DEFAULT NULL,
  p_QUERY_TEXT1          IN VARCHAR2 DEFAULT NULL,
  p_QUERY_TEXT2          IN VARCHAR2 DEFAULT NULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
);

--Procedure to Execute a Given Query and store in the Result table
PROCEDURE EXECUTE_QUERY
( p_USER_ID              IN NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2,
  p_commit               IN  VARCHAR2 DEFAULT fnd_api.G_TRUE,
  p_source_module        IN  VARCHAR2 DEFAULT 'MOBILEADMIN'
);

--Procedure to Create a Instance for a Given Query and store in the Acc table

PROCEDURE INSERT_INSTANCE
( p_USER_ID              IN  NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN  VARCHAR2 DEFAULT NULL,
  p_INSTANCE_NAME        IN  VARCHAR2,
  p_VARIABLE_ID          IN  CSM_INTEGER_LIST,
  p_VARIABLE_VALUE_CHAR  IN  CSM_VARCHAR_LIST,
  p_VARIABLE_VALUE_DATE  IN  CSM_DATE_LIST,
  p_commit               IN  VARCHAR2 DEFAULT fnd_api.G_TRUE,
  x_INSTANCE_ID          OUT NOCOPY NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
);

--Procedure to Delete a Instance for a Given Query and store in the Acc table

PROCEDURE DELETE_INSTANCE
( p_USER_ID              IN  NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN  NUMBER,
  p_commit               IN  VARCHAR2 DEFAULT fnd_api.G_TRUE,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
);

--Procedure to Validate Query Access
PROCEDURE VALIDATE_ACCESS
( p_QUERY_ID             IN  NUMBER DEFAULT NULL,
  p_QUERY_TEXT1          IN  VARCHAR2 DEFAULT NULL,
  p_QUERY_TEXT2          IN  VARCHAR2 DEFAULT NULL,
  p_RESPONSIBILITY_ID    IN  NUMBER DEFAULT NULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
);

--Procedure to Validate Work Flow
PROCEDURE VALIDATE_WORKFLOW
( p_QUERY_ID             IN  NUMBER DEFAULT NULL,
  p_WORKFLOW             IN  VARCHAR2 DEFAULT NULL,
  p_VARIABLE_NAME        IN  CSM_VARCHAR_LIST,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
);

--Procedure to Validate PL/SQL Procedure
PROCEDURE VALIDATE_PROCEDURE
( p_QUERY_ID             IN  NUMBER DEFAULT NULL,
  p_PROCEDURE             IN  VARCHAR2 DEFAULT NULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
);

--Procedure to Insert a Result once a Given Query is executed by Custom code

PROCEDURE INSERT_RESULT
( p_USER_ID              IN  NUMBER,
  p_QUERY_ID             IN  NUMBER,
  p_INSTANCE_ID          IN  VARCHAR2 DEFAULT NULL,
  p_QUERY_RESULT         IN  BLOB,
  p_commit               IN  VARCHAR2 DEFAULT fnd_api.G_TRUE,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_error_message        OUT NOCOPY VARCHAR2
);

END CSM_QUERY_PKG; -- Package spec

/
