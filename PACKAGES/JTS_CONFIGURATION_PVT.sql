--------------------------------------------------------
--  DDL for Package JTS_CONFIGURATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_CONFIGURATION_PVT" AUTHID CURRENT_USER as
/* $Header: jtsvcfgs.pls 115.5 2002/04/10 18:10:13 pkm ship    $ */


-----------------------------------------------------------
-- PACKAGE
--    JTS_CONFIGURATION_PVT
--
-- PURPOSE
--    Private API for Oracle Setup Online Configuration
--	Management
-- PROCEDURES
--
------------------------------------------------------------


G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'JTS_CONFIGURATION_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12)    := 'jtsvcfgs.pls';

C_RECORD_MODE_TYPE 	CONSTANT Varchar2(15) := 'JTS_RECORD_MODE';
C_FLOW_TYPE 		CONSTANT Varchar2(15) := 'JTS_FLOW_TYPE';

--For Configuration Summary and Detail pages
TYPE Config_Rec_Type IS RECORD (
configuration_id		NUMBER,
config_name			VARCHAR2(80),
description			VARCHAR2(240),
flow_id				NUMBER,
flow_name			VARCHAR2(80),
flow_type_code			VARCHAR2(30),  --lookup_code
flow_type			VARCHAR2(80),  --meaning
record_mode			VARCHAR2(30),  --lookup_code
displayed_record_mode		VARCHAR2(80),  --meaning
attribute_category		VARCHAR2(150),
attribute1			VARCHAR2(150),
attribute2			VARCHAR2(150),
attribute3		      	VARCHAR2(150),
attribute4		      	VARCHAR2(150),
attribute5		      	VARCHAR2(150),
attribute6		      	VARCHAR2(150),
attribute7		      	VARCHAR2(150),
attribute8		      	VARCHAR2(150),
attribute9		      	VARCHAR2(150),
attribute10		      	VARCHAR2(150),
attribute11		      	VARCHAR2(150),
attribute12		      	VARCHAR2(150),
attribute13		      	VARCHAR2(150),
attribute14		      	VARCHAR2(150),
attribute15		      	VARCHAR2(150),
creation_date		      	DATE,
created_by		      	NUMBER(15),
last_update_date	      	DATE,
last_updated_by		      	NUMBER(15),
last_update_login	      	NUMBER(15),
created_by_name			VARCHAR2(100), --derived from created_by
last_updated_by_name	      	VARCHAR2(100)  --derived from last_updated_by
); -- end TYPE Config_Rec_Type

TYPE Config_Rec_Tbl_Type IS TABLE OF Config_Rec_Type INDEX BY BINARY_INTEGER;

-----------------------------------------------------------
--Creates a configuration and an initial version
--Values passed in:
--config_name			config_configName,
--description			config_desc,
--flow_id				config_flowId,
--flow_type			setupFlow_flowType,
--record_mode			config_recordMode,
-----------------------------------------------------------
PROCEDURE  CREATE_CONFIGURATION(
      p_api_version            IN       NUMBER,
      p_configuration_rec      IN  	Config_Rec_Type,
      x_config_id	       OUT 	NUMBER,
      x_return_status          OUT      VARCHAR2,
      x_msg_count              OUT      NUMBER,
      x_msg_data               OUT      VARCHAR2
);

-----------------------------------------------------------
--Updates a configuration
--Values passed in:
--config_name			config_configName,
--description			config_desc,
--Updated: config_name, description, last_update_date,
--last_updated_by, last_update_login
-----------------------------------------------------------
PROCEDURE  UPDATE_NAME_DESC (
      p_api_version            IN       NUMBER,
      p_config_id	       IN	NUMBER,
      p_config_name 	       IN  	VARCHAR2,
      p_config_desc 	       IN  	VARCHAR2,
      x_return_status          OUT      VARCHAR2,
      x_msg_count              OUT      NUMBER,
      x_msg_data               OUT      VARCHAR2
);

-- Deletes a configuration and its versions
PROCEDURE  DELETE_CONFIGURATION(
      p_api_version            IN       NUMBER,
      p_config_id  	       IN 	NUMBER,
      x_return_status          OUT      VARCHAR2,
      x_msg_count              OUT      NUMBER,
      x_msg_data               OUT      VARCHAR2
);

-- Retrieves a configuration given a config_id
PROCEDURE  GET_CONFIGURATION(
      p_api_version             IN       NUMBER,
      p_init_msg_list		IN 	 VARCHAR2 DEFAULT FND_API.G_FALSE,
      p_config_id  		IN   	 NUMBER,
      x_configuration_rec 	OUT  	 NOCOPY  Config_Rec_Type,
      x_return_status          	OUT      VARCHAR2,
      x_msg_count              	OUT      NUMBER,
      x_msg_data               	OUT      VARCHAR2
);

-- Retrieves all configurations with a certain order by clause
-- Uses Dynamic SQL
PROCEDURE  GET_CONFIGURATIONS(
      p_api_version            	IN   NUMBER,
      p_where_clause		IN   VARCHAR2,
      p_order_by  		IN   VARCHAR2,
      p_how_to_order		IN   VARCHAR2,
      x_configuration_tbl 	OUT  NOCOPY  Config_Rec_Tbl_Type,
      x_return_status          	OUT  VARCHAR2,
      x_msg_count              	OUT  NUMBER,
      x_msg_data               	OUT  VARCHAR2
);

-- Retrieves flow_id for a particular configuration
PROCEDURE  GET_FLOW_ID(
      p_config_id 		IN   NUMBER,
      x_flow_id          	OUT  NUMBER
);

FUNCTION GET_CONFIG_ID(p_config_name IN VARCHAR2) RETURN NUMBER;
FUNCTION GET_CONFIG_NAME(p_config_id IN NUMBER) RETURN VARCHAR2;

END JTS_CONFIGURATION_PVT;

 

/
