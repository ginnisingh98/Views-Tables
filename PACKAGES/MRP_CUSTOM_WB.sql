--------------------------------------------------------
--  DDL for Package MRP_CUSTOM_WB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_CUSTOM_WB" AUTHID CURRENT_USER AS
/* $Header: MRPWBCDS.pls 115.0 99/07/16 12:42:34 porting ship $ */

PROCEDURE mrp_custom_wb_bucket_dates(
			   arg_organization_id IN NUMBER,
                           arg_compile_designator IN VARCHAR2);

END mrp_custom_wb;

 

/
