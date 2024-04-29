--------------------------------------------------------
--  DDL for Package MRP_WB_BUCKET_DATES_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_WB_BUCKET_DATES_SC" AUTHID CURRENT_USER AS
/* $Header: MRPPWBBS.pls 115.0 99/07/16 12:35:49 porting ship $ */
PROCEDURE populate_bucket_dates ( arg_organization_id IN NUMBER,
                                  arg_compile_designator IN VARCHAR2,
                                  arg_planned_organization IN NUMBER DEFAULT NULL);
PROCEDURE populate_row(arg_organization_id IN NUMBER,
                       arg_planned_organization IN NUMBER,
      		       arg_compile_designator IN VARCHAR2,
                       arg_bucket_type IN NUMBER,
                       arg_bucket_desc IN VARCHAR2 DEFAULT NULL,
                       arg_num_days IN NUMBER DEFAULT NULL,
                       arg_num_weeks IN NUMBER DEFAULT NULL);
END MRP_WB_BUCKET_DATES_SC;

 

/
