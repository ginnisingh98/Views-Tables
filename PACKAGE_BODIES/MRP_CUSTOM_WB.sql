--------------------------------------------------------
--  DDL for Package Body MRP_CUSTOM_WB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_CUSTOM_WB" AS
/* $Header: MRPWBCDB.pls 115.0 99/07/16 12:42:27 porting ship $ */

PROCEDURE mrp_custom_wb_bucket_dates(
			   arg_organization_id IN NUMBER,
                           arg_compile_designator IN VARCHAR2) IS
BEGIN
/* $Header: MRPWBCDB.pls 115.0 99/07/16 12:42:27 porting ship $ */

 -- ----------------------------------------------------------------
 -- Put your calls to populate_row here or insert rows directly into
 -- MRP_WORKBENCH_BUCKET_DATES.  If you insert rows directly you must
 -- ensure that all dates are in ascending order.
 -- Also, you must insert a row into MFG_LOOKUPS if you create a new
 -- type of row.  The LOOKUP_TYPE is 'MRP_WORKBENCH_BUCKET_TYPE'
 --
 -- The following example illustrates how to create a display with
 -- 10 days , 10 weeks and 16 periods using the procedure
 -- mrp_wb_bucket_dates.populate_row
 -- -----------------------------------------------------------------
 -- mrp_wb_bucket_dates.populate_row(arg_organization_id,
 --                                  arg_compile_designator,
 --                                  4,  -- Bucket type NOT IN 1, 2, 3
 --                                  'My Favorite Display',
 --                                  10, -- Days
 --				     10); -- Weeks
 NULL;

END mrp_custom_wb_bucket_dates;
END mrp_custom_wb;

/
