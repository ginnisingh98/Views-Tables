--------------------------------------------------------
--  DDL for Package IGI_IAC_RECLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_RECLASS_PKG" AUTHID CURRENT_USER AS
/* $Header: igiiarls.pls 120.3.12000000.3 2007/10/22 13:46:57 gkumares ship $ */

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Reclass                                                           |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process reclassification for IAC and    |
 |    called from Reclass API(FA_RECLASS_PUB.Do_Reclass).                  |
 |                                                                         |
 +=========================================================================*/
FUNCTION Do_Reclass(
   p_trans_rec                      FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec_old              FA_API_TYPES.asset_cat_rec_type,
   p_asset_cat_rec_new              FA_API_TYPES.asset_cat_rec_type,
   p_asset_desc_rec                 FA_API_TYPES.asset_desc_rec_type,
   p_asset_type_rec                 FA_API_TYPES.asset_type_rec_type,
   p_calling_function               VARCHAR2,
   p_event_id                       number   --R12 uptake
) return BOOLEAN;

-- ======================================================================
-- DEBUG
-- ======================================================================
/* Bug 3299718 Start
PROCEDURE debug_on;

PROCEDURE debug_off;
Bug 3299718 End */
END; --reclass package


 

/
