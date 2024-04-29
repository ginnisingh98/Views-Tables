--------------------------------------------------------
--  DDL for Package BIS_RG_SEND_NOTIFICATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RG_SEND_NOTIFICATIONS_PVT" AUTHID CURRENT_USER as
/* $Header: BISVRGNS.pls 115.7 2003/07/28 06:22:27 nkishore noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_SCHEDULE_PVT
--                                                                        --
--  DESCRIPTION:  Private package to create records in BIS_SCHEDULER
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                --
--  02-25-00   amkulkar   Initial creation                                --
--  05-16-01   mdamle     Changed document from VARCHAR to clob		  --
--  07-28-03   nkishore   Changed signature of send_notification          --
----------------------------------------------------------------------------
--Email Component include role
PROCEDURE  SEND_NOTIFICATION
(p_user_id		IN	VARCHAR2
,p_file_id		IN	VARCHAR2 DEFAULT NULL
,p_schedule_id		IN	VARCHAR2 DEFAULT NULL
,p_role            IN      VARCHAR2 DEFAULT NULL
,p_title           IN      VARCHAR2 DEFAULT NULL
);
PROCEDURE RETRIEVE_REPORT
(document_id           IN       VARCHAR2
,display_Type          IN       VARCHAR2 DEFAULT 'TEXT/HTML'
,document              IN OUT   NOCOPY clob
,document_type         IN OUT   NOCOPY VARCHAR2
);
END BIS_RG_SEND_NOTIFICATIONS_PVT;

 

/
