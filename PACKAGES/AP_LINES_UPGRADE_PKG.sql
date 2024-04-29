--------------------------------------------------------
--  DDL for Package AP_LINES_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_LINES_UPGRADE_PKG" AUTHID CURRENT_USER AS
/* $Header: aplnupgs.pls 120.0 2005/01/29 01:06:43 hredredd noship $ */


PROCEDURE Transaction_Upgrade_Main
               (Errbuf            IN OUT NOCOPY VARCHAR2,
                Retcode           IN OUT NOCOPY VARCHAR2,
                P_Upgrade_Mode    IN            VARCHAR2,
                P_Batch_Size      IN            VARCHAR2,
                P_Num_Workers     IN            NUMBER,
                P_Force_Upgrade   IN            VARCHAR2,
                P_Debug_Flag      IN            VARCHAR2);


PROCEDURE Transaction_Upgrade_Subworker
               (Errbuf                  IN OUT NOCOPY VARCHAR2,
                Retcode                 IN OUT NOCOPY VARCHAR2,
                P_Worker_No             IN            NUMBER,
                P_Init_Process          IN            VARCHAR2,
                P_Upgrade_Mode          IN            VARCHAR2,
                P_Batch_Size            IN            VARCHAR2,
                P_Num_Workers           IN            NUMBER,
                P_Parent_Request_ID     IN            NUMBER,
                P_Debug_Flag            IN            VARCHAR2);


PROCEDURE Populate_Lines
               (P_Start_Rowid           IN            ROWID,
                P_End_Rowid             IN            ROWID,
                P_Calling_Sequence      IN            VARCHAR2);



END AP_LINES_UPGRADE_PKG;

 

/
