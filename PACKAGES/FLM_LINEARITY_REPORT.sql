--------------------------------------------------------
--  DDL for Package FLM_LINEARITY_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_LINEARITY_REPORT" AUTHID CURRENT_USER AS
/* $Header: FLMFLINS.pls 115.1 2002/11/27 11:06:31 nrajpal ship $ */

PROCEDURE populate_flow_summary (
        x_return_status         OUT     NOCOPY	VARCHAR2,
        p_line_from             IN      VARCHAR2,
        p_line_to               IN      VARCHAR2,
        p_sch_group             IN      VARCHAR2,
        p_org_id                IN      NUMBER,
        p_begin_date            IN      DATE,
        p_last_date             IN      DATE,
        p_query_id              IN      NUMBER);

END flm_linearity_report;

 

/
