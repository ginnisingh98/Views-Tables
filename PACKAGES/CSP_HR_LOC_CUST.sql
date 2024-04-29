--------------------------------------------------------
--  DDL for Package CSP_HR_LOC_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_HR_LOC_CUST" AUTHID CURRENT_USER AS
/* $Header: csphrloccusts.pls 120.0.12010000.1 2012/01/27 15:38:55 htank noship $ */


-- Start of Comments
-- Package name     : CSP_HR_LOC_CUST
-- Purpose          : Custom code to override return information
-- History          :
-- NOTE             :
-- End of Comments

FUNCTION user_hook (
   p_hr_loc_record  IN hr_location_record.location_rectype
) RETURN hr_location_record.location_rectype;

End CSP_HR_LOC_CUST;

/
