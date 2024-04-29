--------------------------------------------------------
--  DDL for Package IES_SURVEY_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_SURVEY_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: iessumms.pls 120.1 2005/06/16 11:15:56 appldev  $ */

Procedure  Compute_Summary(p_deployment_id  	    IN NUMBER := NULL);


Procedure  Compute_Summary_Non_List(p_deployment_id  	    IN NUMBER := NULL);


Procedure  Summarize_Survey_Data(
			ERRBUF	    OUT NOCOPY /* file.sql.39 change */ VARCHAR2		,
			RETCODE 	    OUT NOCOPY /* file.sql.39 change */ BINARY_INTEGER		,
			p_cycle_id      IN  NUMBER);
Procedure Update_Question_Frequency
(
    p_error_msg     OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_retcode       OUT NOCOPY /* file.sql.39 change */ NUMBER,
    p_cycle_id      IN  NUMBER
);

PROCEDURE  Update_List_Entry_Summ
(
    p_error_msg           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_retcode             OUT NOCOPY /* file.sql.39 change */ NUMBER,
    p_cycle_id            IN  NUMBER
);


Procedure Check_Question_Type
( p_error_msg OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  p_retcode 	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_cycle_id      IN  NUMBER
);

END; -- Package spec

 

/
