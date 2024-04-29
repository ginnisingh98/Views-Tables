--------------------------------------------------------
--  DDL for Package Body CSP_HR_LOC_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_HR_LOC_CUST" AS
/* $Header: csphrloccustb.pls 120.0.12010000.1 2012/01/27 15:40:19 htank noship $ */


-- Start of Comments
-- Package name     : CSP_HR_LOC_CUST
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

FUNCTION user_hook (
   p_hr_loc_record  IN hr_location_record.location_rectype
   ) RETURN hr_location_record.location_rectype
IS
   x_hr_loc_record    hr_location_record.location_rectype;
BEGIN

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                'csp.plsql.csp_hr_loc_cust.user_hook',
                'Begin...');
    end if;

    x_hr_loc_record := p_hr_loc_record;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                'csp.plsql.csp_hr_loc_cust.user_hook',
                'Returning...');
    end if;

    RETURN x_hr_loc_record;
END user_hook;

End CSP_HR_LOC_CUST;

/
