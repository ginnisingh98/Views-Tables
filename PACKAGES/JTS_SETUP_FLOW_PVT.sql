--------------------------------------------------------
--  DDL for Package JTS_SETUP_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_SETUP_FLOW_PVT" AUTHID CURRENT_USER as
/* $Header: jtsvcsfs.pls 115.5 2002/04/10 18:10:15 pkm ship    $ */


-----------------------------------------------------------
-- PACKAGE
--    JTS_SETUP_FLOW_PVT
--
-- PURPOSE
--    Private API for Oracle Setup Online Configuration Management
--
-- PROCEDURES
--    GET_PARENT_FLOW_ID
--    GET_FLOW_ROOT_FLOWS
--    GET_MODULE_ROOT_FLOWS
--    GET_FLOW_HIEARCHY
------------------------------------------------------------

G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'JTS_SETUP_FLOW_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12)    := 'jtsvcsfb.pls';

C_FLOW_FLOW_TYPE 	CONSTANT	Varchar2(30) := 'FLOW';
C_MODULE_FLOW_TYPE	CONSTANT	Varchar2(30) := 'MODULE';

-- Stores Setup Summary hiearchy
TYPE Setup_Flow_Rec_Type IS RECORD (
flow_id	     	  NUMBER,
flow_name	  VARCHAR2(80),
flow_code	  VARCHAR2(30),
parent_id	  NUMBER,
level		  NUMBER,
flow_sequence	  NUMBER,
overview_url	  VARCHAR2(240),
diagnostics_url   VARCHAR2(240),
dpf_code	  VARCHAR2(50),
dpf_asn		  VARCHAR2(50),
num_steps	  NUMBER,
flow_type	  VARCHAR2(30),
has_child_flag    VARCHAR2(1)
); -- End Setup_Flow_Rec_Type

-- Stores Setup Summary hiearchy
TYPE Flow_Rec_Type IS RECORD (
flow_id	     	  NUMBER,
flow_name	  VARCHAR2(80),
flow_code	  VARCHAR2(30),
parent_id	  NUMBER,
level		  NUMBER,
flow_sequence	  NUMBER,
overview_url	  VARCHAR2(240),
diagnostics_url   VARCHAR2(240),
dpf_code	  VARCHAR2(50),
dpf_asn		  VARCHAR2(50),
num_steps	  NUMBER,
flow_type	  VARCHAR2(30),
has_child_flag    VARCHAR2(1),
--columns from jts_config_version_flows
version_id 		NUMBER,
complete_flag     VARCHAR2(1),
creation_date	  DATE,
last_update_date  DATE,
created_by_name		VARCHAR2(100),
last_updated_by_name	VARCHAR2(100)
--end columns from jts_config_version_flows
); -- End Flow_Rec_Type

-- Stores Configuration Types
TYPE Root_Setup_Flow_Rec_Type IS RECORD (
flow_id	     		NUMBER,
flow_name		VARCHAR2(80),
flow_type		VARCHAR2(30)
); -- End Root_Setup_Flow_Rec_Type

TYPE Setup_Flow_Tbl_Type IS TABLE OF Setup_Flow_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Flow_Tbl_Type IS TABLE OF Flow_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Root_Setup_Flow_Tbl_Type IS TABLE OF Root_Setup_Flow_Rec_Type INDEX BY BINARY_INTEGER;

-- Returns the flow id of a flow's parent
FUNCTION GET_PARENT_FLOW_ID(p_flow_id	IN NUMBER)
RETURN NUMBER;

-- Returns the flow name of a flow given a flow id
FUNCTION GET_FLOW_NAME(p_flow_id	IN NUMBER)
RETURN VARCHAR2;

-- Gets Configuration Types that is a Complete Business Flow
PROCEDURE GET_FLOW_ROOT_FLOWS(p_api_version	IN  NUMBER,
   		    x_flow_tbl			OUT NOCOPY Root_Setup_Flow_Tbl_Type);

-- Gets Configuration Types that are indivdual modules
PROCEDURE GET_MODULE_ROOT_FLOWS(p_api_version	IN  NUMBER,
   		      x_flow_tbl		OUT NOCOPY  Root_Setup_Flow_Tbl_Type);

-- Gets Setup Hiearchy through recursion, starting from the root
PROCEDURE GET_FLOW_HIEARCHY(p_api_version	IN  Number,
   		  p_flow_id		IN  NUMBER,
 	   	  x_flow_tbl		OUT NOCOPY Setup_Flow_Tbl_Type);

-- Gets Setup Hiearchy and Data for each subflow through recursion, starting from the root
PROCEDURE GET_FLOW_DATA_HIEARCHY(p_api_version	IN  Number,
   		  p_flow_id		IN  NUMBER,
		  p_version_id		IN  NUMBER,
 	   	  x_flow_tbl		OUT NOCOPY Flow_Tbl_Type);


END JTS_SETUP_FLOW_PVT;

 

/
