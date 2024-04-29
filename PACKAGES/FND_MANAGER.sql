--------------------------------------------------------
--  DDL for Package FND_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_MANAGER" AUTHID CURRENT_USER AS
/* $Header: AFCPMGRS.pls 120.2.12000000.2 2007/07/16 04:39:04 ggupta ship $ */


--
-- Procedure
--   SET_SESSION_MODE
--
-- Purpose
--   Sets the package mode for the current session.
--
-- Arguments:
--   session_mode - 'seed_data' if new data is for Datamerge.
--                  'customer_data' is the default.
--
PROCEDURE set_session_mode(session_mode IN VARCHAR2);


-- Function
--   MESSAGE
--
-- Purpose
--   Return an error message.  Messages are set when
--   validation (program) errors occur.
--
FUNCTION message RETURN VARCHAR2;

-- Function
--  GET_SPECIALIZATION_TYPE_ID
--
-- Purpose
--  Get a Type (Object) ID  from FND_CONCURRENT_QUEUE_CONTENT
--  (fcqc.TYPE_ID) given the Object's Name, Application ID, and
--  Lookup Code
--
-- Arguments:
--  obj_name    - The name of the specialization object
--                (complex rule name/oracle username/program name/
--                request class name/apps username)
--  obj_appl_id - The application id (fcqc.TYPE_APPLICATION_ID) of the
--                specialization object
--  obj_code    - The lookup code (fcqc.TYPE_CODE) of the specialization
--                object which corresponds to CP_SPECIAL_RULES lookup type
--                (C/O/P/R/U)

FUNCTION get_specialization_type_id(obj_name varchar2,
                                    obj_appl_id number,
                                    obj_code varchar2) return number;


-- Procedure
--   REGISTER
--
-- Purpose
--   Register a concurrent manager.
--
-- Arguments
--   Manager         - Concurrent manager name.
--   Application     - Manager application short name.
--   Short_Name      - Short (non-translated) name
--   Description     - Manager description (Optional).
--   Type            - 'Concurrent Manager', 'Internal Monitor', or
--                     'Transaction Manager'.
--   Cache_Size      - Request cache size (Optional; Concurrent Managers only).
--   Data_Group      - Data group name (Transaction Managers only).
--   Primary_Node    - Primary node (optional).
--   Primary_Queue   - Primary OS queue (Optional).
--   Secondary_Node  - Secondary node (optional).
--   Secondary_Queue - Secondary OS queue (Optional).
--   Library         - Concurrent processing library (e.g. FNDLIBR).
--   Library_Application - Library application short name.
--   Data_Group_id   - Optional.  Overrides 'data_group' parameter.
--   Language_code   - Langauge code for translated values.
--   Last_Update_Date- Who information for FNDLOAD standards
--   Last_Updated_By - Who information for FNDLOAD standards
--
PROCEDURE register(manager		IN VARCHAR2,
		   application          IN VARCHAR2,
                   short_name           IN VARCHAR2,
		   description		IN VARCHAR2 DEFAULT NULL,
		   type			IN VARCHAR2,
		   cache_size		IN NUMBER   DEFAULT NULL,
		   data_group		IN VARCHAR2 DEFAULT NULL,
		   primary_node		IN VARCHAR2 DEFAULT NULL,
		   primary_queue        IN VARCHAR2 DEFAULT NULL,
		   secondary_node       IN VARCHAR2 DEFAULT NULL,
		   secondary_queue 	IN VARCHAR2 DEFAULT NULL,
		   library		IN VARCHAR2,
		   library_application  IN VARCHAR2,
		   data_group_id        IN NUMBER   DEFAULT NULL,
                   language_code        IN VARCHAR2 DEFAULT 'US',
                   last_update_date     IN DATE     DEFAULT NULL,
                   last_updated_by      IN NUMBER   DEFAULT NULL);

-- Procedure
--   REGISTER_SI
--
-- Purpose
--   Register a Service Instance.
--
-- Arguments
--   Manager         - Service Instance name.
--   Application     - Manager application short name.
--   Short_Name      - Short (non-translated) name
--   Description     - Manager description (Optional).
--   Service_Type    -
--   Primary_Node    - Primary node (optional).
--   Primary_Queue   - Primary OS queue (Optional).
--   Secondary_Node  - Secondary node (optional).
--   Secondary_Queue - Secondary OS queue (Optional).
--   Language_code   - Langauge code for translated values.
--   Last_Update_Date- Who information for FNDLOAD standards
--   Last_Updated_By - Who information for FNDLOAD standards
--
PROCEDURE register_si (manager          IN VARCHAR2,
                   application          IN VARCHAR2,
                   short_name           IN VARCHAR2,
                   description          IN VARCHAR2 DEFAULT NULL,
                   service_handle       IN VARCHAR2,
                   primary_node         IN VARCHAR2 DEFAULT NULL,
                   primary_queue        IN VARCHAR2 DEFAULT NULL,
                   secondary_node       IN VARCHAR2 DEFAULT NULL,
                   secondary_queue      IN VARCHAR2 DEFAULT NULL,
                   language_code        IN VARCHAR2 DEFAULT 'US',
                   last_update_date     IN DATE     DEFAULT NULL,
                   last_updated_by      IN VARCHAR2 DEFAULT NULL);


-- Procedure
--   REGISTER_SVC
--
-- Purpose
--   Register a Service .
--
-- Arguments
--   Service_name     - Service name.
--   Service_Handle  - Service Handle
--   DESCRIPTION
--   CARTRIDGE_HANDLE
--   ALLOW_MULTIPLE_PROC_INSTANCE -Y/N
--   ALLOW_MULTIPLE_PROC_NODE -Y/N
--   MIGRATE_ON_FAILURE -Y/N
--   ALLOW_SUSPEND -Y/N
--   ALLOW_VERIFY -Y/N
--   ALLOW_PARAMETER -Y/N
--   ALLOW_START -Y/N
--   ALLOW_RESTART -Y/N
--   ALLOW_RCG -Y/N
--   ALLOW_CREATE - Y/N
--   ALLOW_EDIT -Y/N
--   PARAMETER_CHANGE_ACTION  V=Verify, R=Restart
--   DEVELOPER_PARAMETERS
--   SERVER_TYPE
--   ENV_FILE_NAME -might not be used
--   SERVICE_CLASS
--   SERVICE_INSTANCE_CLASS
--   OAM_DISPLAY_ORDER
--   DEBUG_CHANGE_ACTION N=No followup action V=Verify X=Dynamic change off
--   ENABLED -Y/N
--   CARTRIDGE_APPLICATION - Defaults to 'FND'
--   DEBUG_TYPE
--   SERVICE_PLURAL_NAME
--   ALLOW_MULTIPLE_PROC_SI -Y/N
--   DEFAULT_DEBUG_LEVEL

PROCEDURE register_svc (
 SERVICE_NAME                    IN  VARCHAR2,
 SERVICE_HANDLE                  IN  VARCHAR2,
 DESCRIPTION                     IN  VARCHAR2 DEFAULT NULL,
 CARTRIDGE_HANDLE                IN  VARCHAR2,
 ALLOW_MULTIPLE_PROC_INSTANCE    IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_MULTIPLE_PROC_NODE        IN  VARCHAR2 DEFAULT 'Y',
 MIGRATE_ON_FAILURE              IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_SUSPEND                   IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_VERIFY                    IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_PARAMETER                 IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_START                     IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_RESTART                   IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_RCG                       IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_CREATE                    IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_EDIT                      IN  VARCHAR2 DEFAULT 'Y',
 PARAMETER_CHANGE_ACTION         IN  VARCHAR2 DEFAULT 'V',
 DEVELOPER_PARAMETERS            IN  VARCHAR2 DEFAULT NULL,
 SERVER_TYPE                     IN  VARCHAR2 DEFAULT 'C',
 language_code                   IN  VARCHAR2 DEFAULT 'US',
 ENV_FILE_NAME                   IN  VARCHAR2 DEFAULT NULL,
 SERVICE_CLASS                   IN  VARCHAR2 DEFAULT NULL,
 SERVICE_INSTANCE_CLASS          IN  VARCHAR2 DEFAULT NULL,
 OAM_DISPLAY_ORDER               IN  NUMBER   DEFAULT NULL,
 DEBUG_CHANGE_ACTION             IN  VARCHAR2 DEFAULT 'N',
 ENABLED                         IN  VARCHAR2 DEFAULT 'Y',
 CARTRIDGE_APPLICATION           IN  VARCHAR2 DEFAULT NULL,
 DEBUG_TYPE			 IN  VARCHAR2 DEFAULT NULL,
 SERVICE_PLURAL_NAME		 IN  VARCHAR2 DEFAULT NULL,
 ALLOW_MULTIPLE_PROC_SI          IN  VARCHAR2 DEFAULT 'Y',
 DEFAULT_DEBUG_LEVEL	 	 IN  VARCHAR2 DEFAULT NULL,
 last_updated_by		 IN  NUMBER   DEFAULT NULL);

-- Procedure
--   DELETE_MANAGER
--
-- Purpose
--   Delete a concurrent manager and all its dependent data.
--
-- Arguments
--   Manager_Short_Name  - Concurrent manager short name.
--   Application         - Manager application short name.
--
-- Warning:
--   This will delete request and process data belonging to the
--   manager.
--
PROCEDURE delete_manager (manager_short_name IN VARCHAR2,
		              application        IN VARCHAR2);



-- Procedure
--   ASSIGN_WORK_SHIFT
--
-- Purpose
--   Assign a work shift to a manager.
--
-- Arguments
--   Manager_Short_Name  - Concurrent manager name.
--   Manager_Application - Manager application short name.
--   Work_Shift          - Work shift name.
--   Processes           - Number of concurrent processes.
--   Sleep_Seconds       - Length of sleep interval.
--   Work_Shift_ID       - ID of Work Shift (Optional, overrides parameter
--                         'work_shift')
--   Last_Update_Date- Who information for FNDLOAD standards
--   Last_Updated_By - Who information for FNDLOAD standards
--
PROCEDURE assign_work_shift(manager_short_name		IN VARCHAR2,
 			    manager_application	IN VARCHAR2,
			    work_shift		IN VARCHAR2 DEFAULT NULL,
			    processes           IN NUMBER,
			    sleep_seconds       IN NUMBER,
			    work_shift_id       IN NUMBER   DEFAULT NULL,
                            svc_params          in VARCHAR2 DEFAULT NULL,
                            last_update_date    IN DATE     DEFAULT NULL,
                            last_updated_by      IN VARCHAR2 DEFAULT NULL);

-- Procedure
--   CREATE_LIBRARY
--
-- Purpose
--   Create a concurrent program library.
--
-- Arguments
--   Library		- Library name.
--   Application 	- Library application short name.
--   Description	- Library description.
--   Type 		- 'Concurrent Programs Library' or
--			  'Transaction Programs Library'
--
PROCEDURE create_library(library	IN VARCHAR2,
			 application    IN VARCHAR2,
			 description    IN VARCHAR2 DEFAULT NULL,
			 type           IN VARCHAR2);


-- Procedure
--   DELETE_LIBRARY
--
-- Purpose
--   Delete a concurrent program library.
--
-- Arguments
--   Library		- Library name.
--   Application 	- Library application short name.
--
PROCEDURE delete_library(library	IN VARCHAR2,
			 application    IN VARCHAR2);

-- Procedure
--   ADD_PROGRAM_TO_LIBRARY
--
-- Purpose
--   Add a concurrent program to a concurrent library.
--
-- Arguments
--   Library		 - Library name.
--   Library_Application - Library application short name.
--   Program 	 	 - Program short name.
--   Program_Application - Program application short name.
--
PROCEDURE add_program_to_library(library		IN VARCHAR2,
			 	 library_application    IN VARCHAR2,
			 	 program	    	IN VARCHAR2,
			 	 program_application    IN VARCHAR2);


-- Procedure
--   SPECIALIZE
--
-- Purpose
--   Register a specialization rule for a manager.
--
-- Arguments
--   manager_short_name  - Concurrent manager short name.
--   manager_application - Manager application short name.
--   action              - 'Include' or 'Exclude'.
--   object_type         - 'Combined Rule', 'ORACLE ID', 'Program',
--                         'Request Type', 'User'.
--   object_name         - Name of the object being included or excluded.
--                         (Short name for Programs.)
--   object_application  - Application short name of the object being
--                         included or excluded. (Not used for Oracle IDs
--                         or Users.)
--   Last_Update_Date- Who information for FNDLOAD standards
--   Last_Updated_By - Who information for FNDLOAD standards
--
PROCEDURE specialize(manager_short_name 		 in VARCHAR2,
		     manager_application in VARCHAR2,
		     action              in VARCHAR2,
		     object_type         in VARCHAR2,
		     object_name	 in VARCHAR2 DEFAULT NULL,
		     object_application  in VARCHAR2 DEFAULT NULL,
                     last_update_date    in DATE     DEFAULT NULL,
                     last_updated_by     in NUMBER   DEFAULT NULL);


-- Function
--   MANAGER_EXISTS
--
-- Purpose
--   Return TRUE if a manager exists.
--
-- Arguments
--   Manager_Short_Name - Manager short name.
--   Application - Manager application short name.
--
FUNCTION manager_exists(manager_short_name		IN VARCHAR2,
			application     IN VARCHAR2
     ) RETURN BOOLEAN;

-- Function
--   SERVICE_EXISTS
--
-- Purpose
--   Return TRUE if a service exists.
--
-- Arguments
--   svc_handle - service_handle.
--
FUNCTION Service_exists(svc_handle IN VARCHAR2) RETURN BOOLEAN;

-- Function
--   MANAGER_WORK_SHIFT_EXISTS
--
-- Purpose
--   Return TRUE if a manager has an assignment for a work shift.
--
-- Arguments
--   Manager_Short_Name  - Manager short name.
--   Manager_Application - Manager application short name.
--   Work_Shift		 - Work shift name.
--   Work_Shift_ID       - ID of Work Shift (Optional, overrides parameter
--                         'work_shift')
--
FUNCTION manager_work_shift_exists(
			manager_short_name IN VARCHAR2,
			manager_application IN VARCHAR2,
	           	work_shift          IN VARCHAR2 DEFAULT NULL,
                        work_shift_id       IN NUMBER   DEFAULT NULL)
			RETURN BOOLEAN;


-- Function
--   LIBRARY_EXISTS
--
-- Purpose
--   Return TRUE if a library exists.
--
-- Arguments
--   Library 	 - Library name.
--   Application - Library application short name.
--
FUNCTION library_exists(library		IN VARCHAR2,
			application     IN VARCHAR2) RETURN BOOLEAN;


-- Function
--   PROGRAM_IN_LIBRARY
--
-- Purpose
--   Return TRUE if a library exists.
--
-- Arguments
--   Library 	 	 - Library name.
--   Library_Application - Library application short name.
--   Program             - Program short name.
--   Program_Application - Program application short name.
--
FUNCTION program_in_library(library			IN VARCHAR2,
			    library_application		IN VARCHAR2,
                            program         		IN VARCHAR2,
                            program_application     	IN VARCHAR2)
			    RETURN BOOLEAN;


-- FUNCTION
--   SPECIALIZATION_EXISTS
--
-- Purpose
--   Check if a manager has been specialized for an object.
--
-- Arguments
--   manager_short_name  - Concurrent manager short name.
--   manager_application - Manager application short name.
--   object_type         - 'Combined Rule', 'Oracle ID', 'Program',
--                         'Request Type', 'User'.
--   object_name         - Name of the object being included or excluded.
--                         (Short name for Programs.)
--   object_application  - Application short name of the object being
--                         included or excluded. (Not used for Oracle IDs
--                         or Users.)
--
FUNCTION specialization_exists(
		    manager_short_name 		in VARCHAR2,
		    manager_application in VARCHAR2,
		    object_type         in VARCHAR2,
		    object_name	        in VARCHAR2 DEFAULT NULL,
		    object_application  in VARCHAR2 DEFAULT NULL)
		    RETURN BOOLEAN;

-- Procedure
--   STANDARDIZE
--
-- Purpose
--   Changes the value of a concurrent_queue_id and all references
--   to that ID.
--
-- Arguments
--   Manager_short_name - Concurrent manager short name.
--   Application        - Manager application short name.
--   Queue_ID           - New ID
--
PROCEDURE standardize (manager_short_name IN VARCHAR2,
		       application        IN VARCHAR2,
                       manager_id         IN number);
-- Procedure
--   UPDATE_NODE
--
-- Purpose
--   Set Primary and/or Secondary Node assignment for a Service Instance
--
-- Arguments

--   Short_Name      - Concurrent Queue Name
--   Application     - Application short name
--   Primary_Node    - Primary node
--   Secondary_Node  - Secondary node
--
--   Node names may be set to null.

PROCEDURE update_node(short_name    IN VARCHAR2,
                  application       IN VARCHAR2,
                  primary_node      IN VARCHAR2 DEFAULT fnd_api.g_miss_char,
                  secondary_node    IN VARCHAR2 DEFAULT fnd_api.g_miss_char);


END fnd_manager;

 

/
