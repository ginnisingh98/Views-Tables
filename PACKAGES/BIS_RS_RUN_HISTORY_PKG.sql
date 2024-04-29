--------------------------------------------------------
--  DDL for Package BIS_RS_RUN_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RS_RUN_HISTORY_PKG" AUTHID CURRENT_USER AS
/*$Header: BISRSTHS.pls 120.0 2005/06/01 14:15 appldev noship $*/

PROCEDURE Insert_Row (	p_Request_set_id     NUMBER
			, p_Set_app_id       NUMBER
                        , p_request_set_name VARCHAR2
			, p_Request_id       NUMBER
			, p_rs_refresh_type  VARCHAR2
			, p_Start_date       DATE
			, p_Completion_date  DATE
			, p_Phase_code	     Varchar2
			, p_Status_code      VARCHAR2
			, p_Creation_date    DATE
			, p_Created_by       NUMBER
			, p_Last_update_date DATE
			, p_Last_updated_by  NUMBER
                        , p_completion_text   VARCHAR2
                      );

FUNCTION Update_Row ( p_Request_id       NUMBER
			, p_Request_set_id   NUMBER     DEFAULT NULL
			, p_Set_app_id       NUMBER DEFAULT NULL
			, p_Start_date       DATE DEFAULT NULL
			, p_Completion_date  DATE DEFAULT NULL
			, p_Phase_code	     VARCHAR2 DEFAULT NULL
			, p_Status_code      VARCHAR2 DEFAULT NULL
			, p_Last_update_date DATE
			, p_Last_updated_by  NUMBER
                        , p_completion_text  VARCHAR2 DEFAULT NULL) RETURN boolean;

PROCEDURE Delete_Row (p_last_update_date date);


END BIS_RS_RUN_HISTORY_PKG;

 

/
