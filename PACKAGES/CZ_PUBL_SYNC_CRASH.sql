--------------------------------------------------------
--  DDL for Package CZ_PUBL_SYNC_CRASH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_PUBL_SYNC_CRASH" AUTHID CURRENT_USER AS
/*      $Header: czpsyns.pls 115.1 2003/03/03 16:47:57 rheramba ship $       */

PROCEDURE SET_DBMS_INFO(p_module_name        IN VARCHAR2);
------------------------------------------------------------------------------------------
/* clear CZ_SYNC session */
PROCEDURE RESET_DBMS_INFO;
------------------------------------------------------------------------------------------
/* Sync source instance with a single target instance */
PROCEDURE SYNC_SINGLE_SOURCE_CP(ERRNO			IN OUT NOCOPY  NUMBER,
					  ERRBUF			IN OUT NOCOPY  VARCHAR2,
					  p_run_id			IN OUT NOCOPY  NUMBER,
					  p_target_server_id	IN             NUMBER);
------------------------------------------------------------------------------------------
-- should validate be in spec??
/* Validate if the serverId is the right source server */
FUNCTION ValidateSource(p_target_server_id	IN       NUMBER)
RETURN BOOLEAN;
------------------------------------------------------------------------------------------
/* Sync source instance with all target instances */
PROCEDURE SYNC_ALL_SOURCE_CP	 (ERRNO		IN OUT  NOCOPY NUMBER,
					  ERRBUF		IN OUT  NOCOPY VARCHAR2,
					  p_run_id		IN OUT  NOCOPY NUMBER);
------------------------------------------------------------------------------------------
/* Sync target instance with its source instance */
PROCEDURE SYNC_TARGET_CP (ERRNO	IN OUT NOCOPY  NUMBER,
		 ERRBUF			IN OUT NOCOPY  VARCHAR2,
		 p_run_id			IN OUT NOCOPY  NUMBER,
		 p_source_server_id	IN       NUMBER,
		 p_date			IN	   DATE,
		 p_commitYesNo		IN 	   NUMBER DEFAULT 0 );
/*Backup date from which the db has been restored */
------------------------------------------------------------------------------------------
/* Report all publications that will get republished if SYNC_TARGET_CP  is run */
PROCEDURE SYNC_TARGET_LIST_CP(ERRNO				IN OUT NOCOPY  NUMBER,
				      ERRBUF			IN OUT NOCOPY  VARCHAR2,
				 	p_run_id			IN OUT NOCOPY  NUMBER,
				 	p_source_server_id	IN       NUMBER,
				 	p_date			IN	   DATE);
------------------------------------------------------------------------------------------
/* Validate if the serverId is the right target server */
FUNCTION ValidateTarget(p_server_id	IN       NUMBER)
RETURN BOOLEAN;
------------------------------------------------------------------------------------------
TYPE ref_cursor IS REF CURSOR;

/* Constant Declarations */
pbSourceClone		CONSTANT VARCHAR2(30):='CZ_SYNC_SOURCE_CLONE'; /*Source clone*/
pbTargetClone		CONSTANT VARCHAR2(30):='CZ_SYNC_TARGET_CLONE'; /*Target clone*/
pbSourceCrash		CONSTANT VARCHAR2(30):='CZ_SYNC_SOURCE_CRASH'; /*Source crash*/
pbTargetCrash		CONSTANT VARCHAR2(30):='CZ_SYNC_TARGET_CRASH'; /*Target crash*/

/* Error variables */
xERROR 	BOOLEAN := FALSE;
errNo 	NUMBER;
errBuf	VARCHAR2(255);

/* Oracle Error values */
czOk                        CONSTANT NUMBER:=0;
czWarning                   CONSTANT NUMBER:=1;
czError	                CONSTANT NUMBER:=2;

/* Db linkvalues */

/* Publication error values */
PUBLICATION_ERROR		CONSTANT	VARCHAR2(3)  := 'ERR';
PUBLICATION_OK		CONSTANT	VARCHAR2(3)  := 'OK' ;
PUBLICATION_PROCESSING	CONSTANT	VARCHAR2(3)  := 'PRC';
PUBLICATION_PENDING	CONSTANT	VARCHAR2(3)  := 'PEN';
PUBLICATION_PEN_UPDATE	CONSTANT	VARCHAR2(3)  := 'PUP';

/* Exceptions */
WRONG_INCR    					EXCEPTION;
INCORRECT_SOURCE    				EXCEPTION;
CZ_SYNC_ERROR    					EXCEPTION;
SERVER_NOT_FOUND    				EXCEPTION;
DB_LINK_DOWN    					EXCEPTION;
DB_TNS_INCORRECT    				EXCEPTION;
TNS_INCORRECT    					EXCEPTION;
VALIDATE_SERVER_ERROR    			EXCEPTION;
DELETE_PUBLICATION_ERROR    			EXCEPTION;
CREATE_PUBLICATION_ERROR    			EXCEPTION;
REDO_SEQUENCE_ERROR    				EXCEPTION;
DELETE_DEL_PUBLICATION_ERROR 		   	EXCEPTION;
REPUBLISH_ERROR    				EXCEPTION;
REPORT_RESULTS_ERROR				EXCEPTION;
APPLICABILITY_PARAM_ERR				EXCEPTION;

------------------------------------------------------------------------------------------
END CZ_PUBL_SYNC_CRASH;

 

/
