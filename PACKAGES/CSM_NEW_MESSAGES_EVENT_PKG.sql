--------------------------------------------------------
--  DDL for Package CSM_NEW_MESSAGES_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_NEW_MESSAGES_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmenmgs.pls 120.0.12010000.2 2008/10/22 11:02:05 trajasek ship $ */

PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2);

--Bug 7239431
PROCEDURE REFRESH_USER(p_user_id NUMBER);

END CSM_NEW_MESSAGES_EVENT_PKG;

/