--------------------------------------------------------
--  DDL for Package AP_LINES_UPGRADE_SYNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_LINES_UPGRADE_SYNC_PKG" AUTHID CURRENT_USER AS
/* $Header: aplnsyns.pls 120.0 2005/01/29 00:43:25 hredredd noship $ */


PROCEDURE Transaction_Upgrade_Sync
               (Errbuf            IN OUT NOCOPY VARCHAR2,
                Retcode           IN OUT NOCOPY VARCHAR2,
                P_Upgrade_Mode    IN            VARCHAR2,
                P_Debug_Flag      IN            VARCHAR2);


PROCEDURE Populate_Lines
               (P_Calling_Sequence     IN       VARCHAR2);


END AP_LINES_UPGRADE_SYNC_PKG;

 

/
