--------------------------------------------------------
--  DDL for Package GMS_SUMM_FUNDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_SUMM_FUNDING_PKG" AUTHID CURRENT_USER AS
-- $Header: gmsmfsfs.pls 115.7 2002/11/26 00:37:46 jmuthuku ship $

p_msg_count NUMBER;

Procedure CREATE_GMS_SUMMARY_FUNDING(X_Installment_Id IN NUMBER,
                                       X_Project_Id     IN NUMBER,
                                       X_Task_Id        IN NUMBER DEFAULT NULL,
                                       X_Funding_Amount IN NUMBER,
                                       RETCODE          OUT NOCOPY VARCHAR2,
                                       ERRBUF           OUT NOCOPY VARCHAR2) ;

Procedure DELETE_GMS_SUMMARY_FUNDING(X_Installment_Id   IN NUMBER,
                                     X_Project_Id       IN NUMBER,
                                     X_Task_Id          IN NUMBER DEFAULT NULL,
                                     X_Funding_Amount   IN NUMBER,
                                     RETCODE            OUT NOCOPY VARCHAR2,
                                     ERRBUF             OUT NOCOPY VARCHAR2);

Procedure UPDATE_GMS_SUMMARY_FUNDING(X_Installment_Id   IN NUMBER,
                                     X_Project_Id       IN NUMBER,
                                     X_Task_Id          IN NUMBER DEFAULT NULL,
                                     X_old_amount       IN NUMBER,
                                     X_new_amount       IN NUMBER,
                                     RETCODE            OUT NOCOPY VARCHAR2,
                                     ERRBUF             OUT NOCOPY VARCHAR2);

End GMS_SUMM_FUNDING_PKG;

 

/
