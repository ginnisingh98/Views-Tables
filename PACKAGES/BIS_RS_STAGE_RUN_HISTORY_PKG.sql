--------------------------------------------------------
--  DDL for Package BIS_RS_STAGE_RUN_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RS_STAGE_RUN_HISTORY_PKG" AUTHID CURRENT_USER AS
/*$Header: BISSTTHS.pls 120.0 2005/06/01 16:00 appldev noship $*/

PROCEDURE Insert_Row (	p_Request_set_id   NUMBER
			, p_Set_app_id       NUMBER
			, p_Stage_id         NUMBER
			, p_Request_id       NUMBER
			, p_Set_request_id   NUMBER
			, p_Start_date       DATE
			, p_Completion_date  DATE
			, p_Status_code      VARCHAR2
			, p_phase_code       VARCHAR2
			, p_Creation_date    DATE
			, p_Created_by       NUMBER
			, p_Last_update_date DATE
			, p_Last_updated_by  NUMBER
                        , p_completion_text       VARCHAR2
                      );

function Update_Row (	p_Request_id        NUMBER
			, p_Set_request_id   NUMBER
			, p_start_date       DATE DEFAULT NULL
			, p_Completion_date  DATE DEFAULT NULL
			, p_Status_code      VARCHAR2 DEFAULT NULL
			, p_phase_code       VARCHAR2 DEFAULT NULL
			, p_Last_update_date DATE
			, p_Last_updated_by  NUMBER
                        , p_completion_text  VARCHAR2  DEFAULT NULL) return boolean;

PROCEDURE Delete_Row (p_set_req_id number);



END BIS_RS_STAGE_RUN_HISTORY_PKG;

 

/
