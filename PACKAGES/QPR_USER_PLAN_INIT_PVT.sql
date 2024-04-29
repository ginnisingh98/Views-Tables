--------------------------------------------------------
--  DDL for Package QPR_USER_PLAN_INIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_USER_PLAN_INIT_PVT" AUTHID CURRENT_USER AS
/* $Header: QPRPUSRS.pls 120.0 2007/10/11 13:12:00 agbennet noship $ */
/*
 * This package holds the procedures to be
 * called when initializing the user-plan assignment
 */

/*
 * This procedure would create all the initial data
 * delegating work as necessary
 */

PROCEDURE Initialize
( 	p_api_version           IN	     NUMBER  ,
  	p_init_msg_list		IN	     VARCHAR2,
	p_commit	    	IN  	     VARCHAR2,
        p_validation_level	IN  	     NUMBER	,
        p_user_id               IN           NUMBER  ,
        p_plan_id               IN           NUMBER  ,
        p_event_id              IN           NUMBER  ,
	x_return_status		OUT  NOCOPY  VARCHAR2,
	x_msg_count		OUT  NOCOPY  NUMBER  ,
	x_msg_data		OUT  NOCOPY  VARCHAR2
);

Procedure Validate_params
(
        p_event_id              IN           NUMBER,
        p_user_id               IN           NUMBER,
        p_plan_id               IN           NUMBER,
        x_return_status         OUT  NOCOPY  VARCHAR2
);

Procedure Initialize_reports
(
        p_user_id               IN           NUMBER,
        p_plan_id               IN           NUMBER,
        x_return_status         OUT  NOCOPY  VARCHAR2
);

Procedure Reset_report_flags
(
        p_user_id               IN            NUMBER,
        p_plan_id               IN            NUMBER,
        x_return_status         OUT  NOCOPY   VARCHAR2
);

exc_invalid_input EXCEPTION;
exc_severe_error EXCEPTION;

G_INITIALIZE_REPORTS VARCHAR2(1) := '1';
G_MAINTAIN_DATAMART VARCHAR2(1) := '2';
G_REPORT_REFRESH_FLAG VARCHAR2(1) := 'R';
G_YES                 VARCHAR2(1) := 'Y';
G_NO                 VARCHAR2(1) := 'N';
G_FOLDER_NAME       VARCHAR2(15) := 'oracle/apps/qpr';

END QPR_USER_PLAN_INIT_PVT;


/
