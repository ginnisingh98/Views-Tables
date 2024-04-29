--------------------------------------------------------
--  DDL for Package AP_WEB_EXPORT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_EXPORT_WF" AUTHID CURRENT_USER AS
/* $Header: apwexpws.pls 120.0 2005/06/09 20:26:29 rlangi noship $ */

------------------------
-- Item Type
------------------------
C_APWEXPRT      CONSTANT VARCHAR2(8) := 'APWEXPRT';

------------------------------------------------------------------------
PROCEDURE RaiseRejectionEvent(
                                 p_request_id    IN NUMBER,
                                 p_role    IN VARCHAR2);
------------------------------------------------------------------------

END AP_WEB_EXPORT_WF;

 

/
