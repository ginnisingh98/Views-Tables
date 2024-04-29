--------------------------------------------------------
--  DDL for Package JTS_SETUP_FLOW_HIEARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_SETUP_FLOW_HIEARCHY_PKG" AUTHID CURRENT_USER as
/* $Header: jtstcsfs.pls 115.2 2002/06/07 11:53:19 pkm ship    $ */


-----------------------------------------------------------
-- PACKAGE
--    JTS_SETUP_FLOW_HIEARCHY_PKG
--
-- PURPOSE
--    Private API for Oracle Setup Online Configuration Management
--
-- PROCEDURES
--    DELETE_ROW(varchar2)
--    DELETE_ROW(NUMBER)
--    LOAD_ROW
--    TRANSLATE_ROW
--    In body: INSERT_ROW
--    	       UPDATE_ROW
------------------------------------------------------------

G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'JTS_SETUP_FLOW_HIEARCHY_PKG';
G_FILE_NAME     CONSTANT VARCHAR2(12)    := 'jtstcsfb.pls';

-------------------------------------------------
-- This is for seeding the Flow hiearchy.
-- Deletes a flow based on flow_code
-------------------------------------------------
PROCEDURE DELETE_ROW(p_flow_code IN VARCHAR2);

-------------------------------------------------
-- This is for seeding the Flow hiearchy.
-- Deletes a flow based on flow_id
-------------------------------------------------
PROCEDURE DELETE_ROW(p_flow_id	IN NUMBER);

-------------------------------------------------
-- This is for seeding the Flow hiearchy.
--
-- Translates the flow name
-------------------------------------------------
PROCEDURE TRANSLATE_ROW (
         p_flow_code  		IN VARCHAR2,
         p_owner    		IN VARCHAR2,
         p_flow_name  		IN VARCHAR2
        );

-------------------------------------------------y
-- This is for seeding the Flow hiearchy.
--
-- Uploads a flow
-- If p_flow_id is not NULL and there is no flow with
-- such flow_id in the database, then a new flow_id will be used
-------------------------------------------------
PROCEDURE LOAD_ROW (
          P_FLOW_CODE      	IN VARCHAR2,
          P_OWNER              	IN VARCHAR2,
          p_flow_type   	IN VARCHAR2,
          p_parent_code        	IN VARCHAR2,
          p_has_child_flag      IN VARCHAR2,
          p_flow_sequence      	IN NUMBER,
          p_num_steps    	IN NUMBER,
  	  P_OVERVIEW_URL 	in VARCHAR2,
  	  P_DIAGNOSTICS_URL 	in VARCHAR2,
  	  P_DPF_CODE 		in VARCHAR2,
  	  P_DPF_ASN 		in VARCHAR2,
          P_FLOW_NAME         	IN VARCHAR2
         );

procedure LOCK_ROW (
  X_FLOW_ID in NUMBER,
  X_FLOW_CODE in VARCHAR2,
  X_FLOW_TYPE in VARCHAR2,
  X_PARENT_ID in NUMBER,
  X_HAS_CHILD_FLAG in VARCHAR2,
  X_FLOW_SEQUENCE in NUMBER,
  X_OVERVIEW_URL in VARCHAR2,
  X_DIAGNOSTICS_URL in VARCHAR2,
  X_DPF_CODE in VARCHAR2,
  X_DPF_ASN in VARCHAR2,
  X_NUM_STEPS in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FLOW_NAME in VARCHAR2
);

procedure ADD_LANGUAGE;

END JTS_SETUP_FLOW_HIEARCHY_PKG;

 

/
