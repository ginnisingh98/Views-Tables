--------------------------------------------------------
--  DDL for Package JTS_CONFIG_VER_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_CONFIG_VER_STATUS_PVT" AUTHID CURRENT_USER as
/* $Header: jtsvcvss.pls 115.3 2002/04/10 18:10:25 pkm ship    $ */


-----------------------------------------------------------
-- PACKAGE
--    JTS_CONFIG_VER_STATUS_PVT
--
-- PURPOSE
--    Private API for Oracle Setup Online Configuration Management
--
-- PROCEDURES
--
------------------------------------------------------------

G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'JTS_CONFIG_VER_STATUS_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12)    := 'jtsvcvsb.pls';

C_STATUS_TYPE 		CONSTANT		VARCHAR2(30):= 'JTS_STATUS';

-- Lookup Codes for JTS_STATUS
C_INIT_VERSION_STATUS 		CONSTANT		VARCHAR2(30):= 'NEW';
C_PROCESS_VERSION_STATUS 	CONSTANT		VARCHAR2(30):= 'PROCESS';
C_COMPLETE_VERSION_STATUS 	CONSTANT		VARCHAR2(30):= 'COMPLETE';
C_SUBMIT_REPLAY_STATUS 		CONSTANT		VARCHAR2(30):= 'SUBMIT';
C_NOSUBMIT_REPLAY_STATUS 	CONSTANT		VARCHAR2(30):= 'NOSUBMIT';
C_FAIL_REPLAY_STATUS 		CONSTANT		VARCHAR2(30):= 'FAIL';
C_CANCEL_REPLAY_STATUS 		CONSTANT		VARCHAR2(30):= 'CANCEL';
C_SUCCESS_REPLAY_STATUS 	CONSTANT		VARCHAR2(30):= 'SUCCESS';
C_ERROR_REPLAY_STATUS 		CONSTANT		VARCHAR2(30):= 'ERRORS';
C_RUNNING_REPLAY_STATUS 	CONSTANT		VARCHAR2(30):= 'RUNNING';

-- Inserts a row into jts_config_version_statuses table with a
-- a certain version_id and status
PROCEDURE CREATE_VERSION_STATUS(p_api_version	IN  Number,
				p_commit	IN  Varchar2,
   				p_version_id	IN  Number,
 				p_status	IN  Varchar2
);

-- Deletes records from jts_config_version_statuses table
PROCEDURE DELETE_VERSION_STATUSES(p_api_version	IN  Number,
   				p_version_id	IN  Number);


-- Deletes records from jts_config_version_statuses table for all
-- versions with a certain configuration id
PROCEDURE DELETE_CONFIG_VER_STATUSES(p_api_version	IN  Number,
   				p_config_id		IN  Number);

-- Checks if any version under a configuration has been replayed
PROCEDURE ANY_VERSION_REPLAYED(p_api_version	IN  Number,
   				p_config_id	IN  Number,
				x_replayed	OUT BOOLEAN);

-- Returns replay status, version status, replayed_date,
-- replayed_by for a version
PROCEDURE GET_VERSION_STATUS_DATA (
		p_api_version		IN  Number,
		p_version_id 		IN  NUMBER,
		x_replay_status_code 	OUT VARCHAR2,
		x_version_status_code	OUT VARCHAR2,
		x_replay_status 	OUT VARCHAR2,
		x_version_status	OUT VARCHAR2,
		x_replayed_date		OUT DATE,
		x_replayed_by_name	OUT VARCHAR2);

-- Checks if status is a Replay Status
FUNCTION IN_REPLAY_STATUS(p_api_version	IN  Number,
 			p_status	IN  Varchar2) return BOOLEAN;

-- Checks if status is Version Status
FUNCTION IN_VERSION_STATUS(p_api_version	IN  Number,
   				p_status	IN  Varchar2) return BOOLEAN;

-- Checks if status indicates that a version has not been replayed
-- Assumption: in_replay_status has already been called
PROCEDURE NOT_REPLAYED(p_api_version		IN  Number,
   			p_status		IN  Varchar2,
 			x_in_notreplayed	OUT boolean);

END JTS_CONFIG_VER_STATUS_PVT;

 

/
