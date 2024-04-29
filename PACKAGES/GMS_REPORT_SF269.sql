--------------------------------------------------------
--  DDL for Package GMS_REPORT_SF269
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_REPORT_SF269" AUTHID CURRENT_USER AS
--$Header: gmsgrfls.pls 120.1 2005/08/23 20:05:21 spunathi noship $
Procedure Populate_269_History(RETCODE OUT NOCOPY VARCHAR2,
                               ERRBUF  OUT NOCOPY VARCHAR2,
                               X_Award_Id IN NUMBER,
			       X_Report_Start_Date IN DATE,
			       X_Report_End_Date   IN DATE
                               );
End GMS_REPORT_SF269;

 

/
