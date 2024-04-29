--------------------------------------------------------
--  DDL for Package PA_PARALLEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PARALLEL" AUTHID CURRENT_USER AS
-- $Header: PACPAIUS.pls 115.1 99/08/19 17:42:03 porting ship  $

PROCEDURE PA_PARALLEL_AI_RESTART
(script_name	IN	VARCHAR2,
 worker_number  IN      NUMBER,
 total_workers  IN	NUMBER,
 action		IN      VARCHAR2,
 min_id		IN OUT  NUMBER,
 max_id         IN      NUMBER);

FUNCTION get_currency( P_org_id IN pa_implementations_all.org_id%TYPE)
   RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(get_currency, WNDS, WNPS);

G_Curr_Tab pa_utils.Char15TabTyp;

END PA_PARALLEL;

 

/
