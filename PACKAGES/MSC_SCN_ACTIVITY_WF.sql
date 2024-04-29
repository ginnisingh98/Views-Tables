--------------------------------------------------------
--  DDL for Package MSC_SCN_ACTIVITY_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SCN_ACTIVITY_WF" AUTHID CURRENT_USER AS
/* $Header: MSCSCWFS.pls 120.1 2008/02/19 12:31:27 skakani noship $ */

PROCEDURE SendFYINotification ( userID IN NUMBER, --- sender user id
                               respID in NUMBER, --sender resp id
                               language IN Varchar2,
                               wfName IN VARCHAR2,
                               wfProcessName IN varchar2,
                               p_activity_id IN number,
                               status IN OUT NOCOPY VARCHAR2
                               );

PROCEDURE Monitor_Scn_Changes(errbuf OUT NOCOPY VARCHAR2,
                              retcode OUT NOCOPY VARCHAR2);

END MSC_SCN_ACTIVITY_WF;

/
