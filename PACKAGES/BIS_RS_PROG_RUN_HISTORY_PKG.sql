--------------------------------------------------------
--  DDL for Package BIS_RS_PROG_RUN_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RS_PROG_RUN_HISTORY_PKG" AUTHID CURRENT_USER AS
/*$Header: BISPRTHS.pls 120.0 2005/06/01 18:15 appldev noship $*/

PROCEDURE Insert_Row(	 p_Set_request_id	Number,
			 p_Stage_request_id 	Number,
			 p_Request_id		Number,
			 p_Program_id		Number,
			 p_Prog_app_id		Number,
			 p_Status_code		Varchar2,
			 p_Phase_code		Varchar2,
			 p_Start_date		DATE,
			 p_Completion_date	Date,
			 p_Creation_date         DATE,
			 p_Created_by            NUMBER,
			 p_Last_update_date      DATE,
			 p_Last_updated_by       NUMBER,
                         p_completion_text       VARCHAR2
                      );

FUNCTION Update_Row(	 p_Set_request_id	Number,
			 p_Stage_request_id 	Number,
			 p_Request_id		Number,
			 p_Program_id		Number DEFAULT NULL,
			 p_Prog_app_id		Number DEFAULT NULL,
			 p_Status_code		Varchar2 DEFAULT NULL,
			 p_Phase_code		Varchar2 DEFAULT NULL,
			 p_Completion_date	Date DEFAULT NULL,
			 p_Last_update_date      DATE,
			 p_Last_updated_by       NUMBER,
                         p_completion_text       VARCHAR2 DEFAULT NULL) RETURN BOOLEAN;

PROCEDURE Delete_Row (p_set_rq_id number);


END BIS_RS_PROG_RUN_HISTORY_PKG;

 

/
