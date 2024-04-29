--------------------------------------------------------
--  DDL for Package MRP_CRP_HORIZONTAL_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_CRP_HORIZONTAL_PLAN" AUTHID CURRENT_USER AS
/*	$Header: MRPHCPLS.pls 120.1 2005/06/15 11:18:27 svaidyan noship $ */

/* 2663505 - Removed the default value for p_current_data to comply to
PL/SQL Stds. changes */

FUNCTION populate_horizontal_plan(
			p_item_list_id		IN NUMBER,
			p_planned_org		IN NUMBER,
			p_org_id		IN NUMBER,
			p_compile_designator	IN VARCHAR2,
			p_bucket_type		IN NUMBER,
			p_cutoff_date		IN DATE,
			p_current_data		IN NUMBER) RETURN NUMBER;

FUNCTION compute_days_between(
            spread_load NUMBER,
            start_date  DATE,
            end_date    DATE) RETURN NUMBER ;

procedure MrpAppletPage(filename Varchar2,appname Varchar2);

    PRAGMA RESTRICT_REFERENCES (compute_days_between, WNDS);

END mrp_crp_horizontal_plan;

 

/
