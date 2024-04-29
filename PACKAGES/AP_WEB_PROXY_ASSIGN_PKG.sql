--------------------------------------------------------
--  DDL for Package AP_WEB_PROXY_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_PROXY_ASSIGN_PKG" AUTHID CURRENT_USER AS
/* $Header: apwprass.pls 120.1 2005/10/02 20:18:38 albowicz noship $ */

  -- used by OIE developer
FUNCTION proxy_assignments  (p_subscription_guid  IN RAW,
   p_event              IN OUT NOCOPY WF_EVENT_T) return VARCHAR2;

-- used by OIE developer
PROCEDURE send_notification(p_user_name     IN VARCHAR2,
                            p_resp_name     IN VARCHAR2,
                            p_assignor_name IN VARCHAR2,
                            p_start_date IN VARCHAR2,
                            p_end_date      IN VARCHAR2) ;

END AP_WEB_PROXY_ASSIGN_PKG;

 

/
