--------------------------------------------------------
--  DDL for Package PAY_FR_DADS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_DADS_F_PKG" AUTHID CURRENT_USER as
/* $Header: pyfrdadf.pkh 115.3 2003/12/11 02:17 abhaduri noship $ */
Procedure PROCESS(errbuf                   OUT NOCOPY VARCHAR2,
                  retcode                  OUT NOCOPY NUMBER,
                  P_BUSINESS_GROUP_ID       IN NUMBER,
                  P_ISSUING_ESTABLISHMENT   IN NUMBER,
                  P_DADS_REFERENCE          IN VARCHAR2,
                  P_REPORT_TYPE             IN VARCHAR2,
                  P_DUMMY                   IN VARCHAR2, --Added for enabling P_SUBMISSION_TYPE
                  P_DECLARATION_NATURE      IN VARCHAR2,
                  P_DECLARATION_TYPE        IN VARCHAR2,
                  P_REPORT_INCLUSIONS       IN VARCHAR2,
                  P_SORT_ORDER_1            IN VARCHAR2,
                  P_SORT_ORDER_2            IN VARCHAR2,
                  P_SUBMISSION_TYPE         IN VARCHAR2);
--
PROCEDURE write_user_file_report (P_BUSINESS_GROUP_ID       IN NUMBER,
                                  P_ISSUING_ESTABLISHMENT   IN NUMBER,
                                  P_DADS_REFERENCE          IN VARCHAR2,
                                  P_REPORT_TYPE             IN VARCHAR2,
                                  P_DECLARATION_NATURE      IN VARCHAR2,
                                  P_DECLARATION_TYPE        IN VARCHAR2,
                                  P_REPORT_INCLUSIONS       IN VARCHAR2,
                                  P_SORT_ORDER_1            IN VARCHAR2,
                                  P_SORT_ORDER_2            IN VARCHAR2,
                                  P_SUBMISSION_TYPE         IN VARCHAR2);

Procedure control_proc (P_BUSINESS_GROUP_ID       IN NUMBER,
                        P_ISSUING_ESTABLISHMENT   IN NUMBER,
                        P_DADS_REFERENCE          IN VARCHAR2,
                        P_REPORT_TYPE             IN VARCHAR2,
                        P_DECLARATION_NATURE      IN VARCHAR2,
                        P_DECLARATION_TYPE        IN VARCHAR2,
                        P_REPORT_INCLUSIONS       IN VARCHAR2,
                        P_SORT_ORDER_1            IN VARCHAR2,
                        P_SORT_ORDER_2            IN VARCHAR2);
--
end;

 

/
