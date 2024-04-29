--------------------------------------------------------
--  DDL for Package JTS_CONFIG_VERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_CONFIG_VERSION_PVT" AUTHID CURRENT_USER as
/* $Header: jtsvcvrs.pls 115.6 2002/04/10 18:10:22 pkm ship    $ */


-----------------------------------------------------------
-- PACKAGE
--    JTS_CONFIG_VERSION_PVT
--
-- PURPOSE
--    Private API for Oracle Setup Online Configuration Management
--
-- PROCEDURES
--
------------------------------------------------------------

G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'JTS_CONFIG_VERSION_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12)    := 'jtsvcvrb.pls';

C_QUEUE_PREFIX 		CONSTANT 	Varchar2(30) := 'JTSCONFIGXMLAQ';

--For Version Summary and Version Details pages
TYPE Config_Version_Rec_Type IS RECORD (
configuration_id	NUMBER,
version_id		NUMBER,
version_name		VARCHAR2(80),
version_number		NUMBER,
description		VARCHAR2(240),

queue_name		VARCHAR2(30),
attribute_category	VARCHAR2(150),
attribute1		VARCHAR2(150),
attribute2		VARCHAR2(150),
attribute3		VARCHAR2(150),
attribute4		VARCHAR2(150),
attribute5		VARCHAR2(150),
attribute6		VARCHAR2(150),
attribute7		VARCHAR2(150),
attribute8		VARCHAR2(150),
attribute9		VARCHAR2(150),
attribute10		VARCHAR2(150),
attribute11		VARCHAR2(150),
attribute12		VARCHAR2(150),
attribute13		VARCHAR2(150),
attribute14		VARCHAR2(150),
attribute15		VARCHAR2(150),
creation_date		DATE,
created_by	   	NUMBER(15),
last_update_date	DATE,
last_updated_by		NUMBER(15),
last_update_login	NUMBER(15),
created_by_name	   	VARCHAR2(100),
last_updated_by_name	VARCHAR2(100),

--start jts_configurations records
config_name		VARCHAR2(80),
config_desc		VARCHAR2(240),
config_flow_id		NUMBER,
config_flow_name	VARCHAR2(80), --from jts_setup_flows_vl
config_flow_type	VARCHAR2(30),
config_record_mode	VARCHAR2(30),
config_disp_record_mode	VARCHAR2(80),--from fnd_lookup_values_vl
--end jts_configurations records

--start jts_config_version_statuses records
replayed_date		DATE,
replayed_by_name	VARCHAR2(100),
replay_status_code	VARCHAR2(30),
version_status_code	VARCHAR2(30),
replay_status		VARCHAR2(80),
version_status		VARCHAR2(80),
--end jts_config_version_statuses records

--start jts_config_version_flows record
percent_completed	NUMBER
--end jts_config_version_flows record
); --End Record Config_Version_Rec_Type

TYPE Config_Version_Tbl_Type  IS TABLE OF Config_Version_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Version_Id_Tbl_Type      IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--
-- Returns the versionin jts_config_versions for
-- version_name and configuration_id
FUNCTION GET_VERSION_ID(p_version_name  IN VARCHAR2,
			p_config_id	IN NUMBER) return NUMBER;

-----------------------------------------------------------------
-- Creates a version, version flows for the setup summary data,
-- and version status with "NEW" as the value
-- Values passed in:
-- 	version_name
-- 	description
-- 	configuration_id
-----------------------------------------------------------------
PROCEDURE CREATE_VERSION(p_api_version	IN  Number,
	P_commit			IN   Varchar2 DEFAULT FND_API.G_FALSE,
   	p_configuration_id		IN  NUMBER,
        p_init_version 			IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
   	x_version_id			OUT NUMBER,
   	x_return_status      		OUT VARCHAR2,
   	x_msg_count          		OUT NUMBER,
   	x_msg_data           		OUT VARCHAR2);

-- Updates version name and description.
-- May insert into version_statuses table
PROCEDURE UPDATE_NAME_DESC(p_api_version	IN  NUMBER,
			   p_version_id		IN  NUMBER,
			   p_config_id		IN  NUMBER,
			   p_version_name 	IN  VARCHAR2,
			   p_version_desc 	IN  VARCHAR2,
   			   x_return_status      OUT VARCHAR2,
   			   x_msg_count          OUT NUMBER,
   			   x_msg_data           OUT VARCHAR2
);

-- Updates version_status_code, last_update_date, last_updated_by
PROCEDURE UPDATE_VERSION_STAT(p_api_version	IN  NUMBER,
			   p_version_id		IN  NUMBER,
			   p_status		IN  VARCHAR2
);

-- Updates version_status_code, last_update_date, last_updated_by
PROCEDURE UPDATE_REPLAY_DATA(p_api_version	IN  NUMBER,
			   p_version_id		IN  NUMBER,
			   p_status		IN  VARCHAR2
);

-- Updates last_update_date and last_updated_by
PROCEDURE UPDATE_LAST_MODIFIED(p_api_version	IN  NUMBER,
			   p_version_id		IN  NUMBER);

-- Deletes a version and its corresponding version_statuses and
-- version_flows
PROCEDURE DELETE_VERSION(p_api_version		IN  Number,
			 p_commit		IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			 p_version_id		IN  NUMBER
);

-- Deletes versions and their corresponding version_statuses and
-- version_flows given a table of version ids
PROCEDURE DELETE_SOME_VERSIONS(p_api_version		IN  Number,
   			       p_version_tbl		IN  Version_Id_Tbl_Type
);

-- Deletes all versions of a configuration and their corresponding -- version_statuses and version_flows
-- Commit is done in Configurations Pkg
PROCEDURE DELETE_VERSIONS(p_api_version		IN  NUMBER,
   			  p_config_id		IN  NUMBER
);

-- Gets version data based on version_id
PROCEDURE GET_VERSION(p_api_version	IN   NUMBER,
   		      p_version_id	IN   NUMBER,
		      x_version_rec 	OUT  NOCOPY Config_Version_Rec_Type,
      		      x_return_status   OUT  VARCHAR2,
      		      x_msg_count       OUT  NUMBER,
      		      x_msg_data        OUT  VARCHAR2);

-- Retrieves all versions under a configuration with a certain order by clause
-- Uses Dynamic SQL
PROCEDURE  GET_VERSIONS(
      p_api_version            	IN   NUMBER,
      p_config_id		IN   NUMBER,
      p_order_by  		IN   VARCHAR2,
      p_how_to_order 		IN   VARCHAR2,
      x_version_tbl 		OUT  NOCOPY Config_Version_Tbl_Type,
      x_return_status          	OUT  VARCHAR2,
      x_msg_count              	OUT  NUMBER,
      x_msg_data               	OUT  VARCHAR2
);

END JTS_CONFIG_VERSION_PVT;

 

/
