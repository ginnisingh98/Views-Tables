--------------------------------------------------------
--  DDL for Package MRP_REPORTING_BUCKETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_REPORTING_BUCKETS" AUTHID CURRENT_USER AS
  /* $Header: MRPPRBKS.pls 115.0 99/07/16 12:33:47 porting ship $ */

PROCEDURE mrp_weeks_months(
                            arg_query_id IN NUMBER,
                            arg_user_id IN NUMBER,
                            arg_weeks   IN NUMBER,
                            arg_periods IN NUMBER,
                            arg_start_date IN DATE,
                            arg_org_id  IN NUMBER);

END mrp_reporting_buckets;

 

/
