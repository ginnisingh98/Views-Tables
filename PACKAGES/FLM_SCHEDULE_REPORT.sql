--------------------------------------------------------
--  DDL for Package FLM_SCHEDULE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_SCHEDULE_REPORT" AUTHID CURRENT_USER AS
/* $Header: FLMFSCHS.pls 115.0 99/10/01 16:10:25 porting ship  $ */

  FUNCTION get_revision(p_org_id NUMBER,
                        p_item_id NUMBER,
                        p_date DATE) return VARCHAR2;

  FUNCTION display_item(p_level NUMBER,
                        p_sort_order VARCHAR2,
                        p_top_bill_seq_id NUMBER,
                        p_org_id NUMBER) return number;
END flm_schedule_report;

 

/
