--------------------------------------------------------
--  DDL for Package PSP_PREGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PREGEN" AUTHID CURRENT_USER AS
-- $Header: PSPLDPGS.pls 120.0.12000000.1 2007/01/18 12:21:06 appldev noship $
--
--
g_auto_population VARCHAR2(1);

PROCEDURE IMPORT_PREGEN_LINES (ERRBUF              out NOCOPY varchar2,
			       RETCODE             out NOCOPY number,
			       p_batch_name        IN VARCHAR2 ,
		               p_business_group_id IN NUMBER,
			       p_set_of_books_id   IN NUMBER,
	                       p_operating_unit    IN NUMBER,
			       p_gms_pa_install    IN VARCHAR2 DEFAULT NULL);
--
Function get_least_date(x_time_period_id IN Number,x_person_id IN Number, x_gl_ccid IN Number,x_project_id IN Number,
                        x_award_id IN Number,x_task_id IN Number,x_distribution_date IN Date) Return Date;
PRAGMA RESTRICT_REFERENCES(get_least_date,WNDS,WNPS,RNPS);
--
Procedure Autopop( X_Batch_name        IN VARCHAR2,
               X_Set_of_Books_Id    IN NUMBER,
               X_Business_Group_ID  IN NUMBER,
               X_Operating_Unit     IN NUMBER,
               X_Gms_Pa_Install     IN VARCHAR2,
               X_Return_Status      OUT NOCOPY VARCHAR2);

END PSP_PREGEN;

 

/
