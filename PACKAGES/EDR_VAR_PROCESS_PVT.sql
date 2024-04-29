--------------------------------------------------------
--  DDL for Package EDR_VAR_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_VAR_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: EDRVVARS.pls 120.0.12000000.1 2007/01/18 05:56:46 appldev ship $ */

-- Global Constants
G_PKG_NAME   CONSTANT varchar2(30) := 'EDR_VAR_PROCESS_PVT';

-- -------------- Start of comments -------------------
-- API name     : Ackn_Var_EresDone
-- Type         : Private Utility.
-- Function     : Acknowledges configuration variable eSignature compeltion
-- Pre-reqs     : None.
-- Parameters   :
-- IN           : p_event_name     event name or transaction id, eg. oracle.apps.edr.amevar.update
--              : p_event_key      event key or tran/rule_config_id number,
-- Versions	: 1.0	04-Dec-03  created for eSignature acknowledgement
-- -------------- End of comments ---------------------

PROCEDURE Ackn_Var_EresDone (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name            IN	VARCHAR2,
        p_event_key             IN      VARCHAR2      );

END EDR_VAR_PROCESS_PVT;

 

/
