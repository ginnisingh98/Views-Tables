--------------------------------------------------------
--  DDL for Package JTS_CONFIG_VERSION_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_CONFIG_VERSION_FLOW_PVT" AUTHID CURRENT_USER as
/* $Header: jtsvcvfs.pls 115.2 2002/04/10 18:10:20 pkm ship    $ */


-----------------------------------------------------------
-- PACKAGE
--    JTS_CONFIG_VERSION_FLOW_PVT
--
-- PURPOSE
--    Private API for Oracle Setup Online Configuration Management
--
-- PROCEDURES
--
------------------------------------------------------------

G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'JTS_CONFIG_VERSION_FLOW_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12)    := 'jtsvcvfb.pls';

TYPE Version_Flow_Rec_Type IS RECORD (
version_id 		NUMBER,
flow_id			NUMBER,
complete_flag		VARCHAR2(1),
creation_date		DATE,
created_by		NUMBER(15),
last_update_date	DATE,
last_updated_by		NUMBER(15),
last_update_login	NUMBER(15),
created_by_name		VARCHAR2(100),
last_updated_by_name	VARCHAR2(100)
);  -- End Record Version_Flow_Rec_Type

TYPE Version_Flow_Tbl_Type IS TABLE OF Version_Flow_Rec_Type INDEX BY BINARY_INTEGER;

-- Precondition: Complete Flag for all the parents have been set
--  		 UPDATE_COMPLETE_FLAGS have been called
FUNCTION GET_PERCENT_COMPLETE(p_api_version	IN  NUMBER,
   			      p_version_id	IN  NUMBER) RETURN NUMBER;

-- Updates last_update_date, last_updated_by of a subflow and its
-- parent up to one level below the root
PROCEDURE UPDATE_FLOW_DETAILS(p_api_version	IN NUMBER,
   			p_version_id		IN NUMBER,
			p_flow_id		IN NUMBER,
			p_complete_flag 	IN VARCHAR2
);

-- Creates Setup Summary data by getting the flow hiearchy
-- and inserting with the appropriate flow_id
PROCEDURE CREATE_VERSION_FLOWS(p_api_version	IN  NUMBER,
   				p_version_id	IN  NUMBER,
				p_flow_hiearchy IN  JTS_SETUP_FLOW_PVT.Setup_Flow_Tbl_Type);

--Deletes from jts_config_version_flows
PROCEDURE DELETE_VERSION_FLOWS(p_api_version	IN  NUMBER,
   				p_version_id 	IN  NUMBER);


-- Deletes all records from jts_config_version_flows where
-- version_id exists for p_config_id in versions table
PROCEDURE DELETE_CONFIG_VERSION_FLOWS(p_api_version	IN  NUMBER,
   					p_config_id 	IN  NUMBER);

-- Gets all the version flows
PROCEDURE GET_VERSION_FLOWS(p_api_version	IN  NUMBER,
   		p_version_id	IN  NUMBER,
		p_flow_tbl	OUT NOCOPY Version_Flow_Tbl_Type);


END JTS_CONFIG_VERSION_FLOW_PVT;

 

/
