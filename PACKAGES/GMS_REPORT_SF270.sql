--------------------------------------------------------
--  DDL for Package GMS_REPORT_SF270
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_REPORT_SF270" AUTHID CURRENT_USER AS
--$Header: gmsgrras.pls 120.1 2005/07/26 14:22:26 appldev ship $
Procedure Populate_270_History(X_Award_Id IN NUMBER,
			       X_Report_Start_Date IN DATE,
			       X_Report_End_Date   IN DATE,
			       RETCODE OUT NOCOPY VARCHAR2,
                               ERRBUF  OUT NOCOPY VARCHAR2);

End GMS_REPORT_SF270;

 

/
