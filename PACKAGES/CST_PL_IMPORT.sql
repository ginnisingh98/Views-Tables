--------------------------------------------------------
--  DDL for Package CST_PL_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PL_IMPORT" AUTHID CURRENT_USER as
/* $Header: CSTPLIMS.pls 120.1 2006/03/21 11:49:15 vtkamath noship $ */

PROCEDURE START_PROCESS(ERRBUF                  OUT NOCOPY     VARCHAR2,
                        RETCODE                 OUT NOCOPY     NUMBER ,
                        p_pl_hdr_id             IN      NUMBER ,
                        p_range                 IN      NUMBER ,
                        p_item_dummy		IN      NUMBER ,
                        p_category_dummy        IN      NUMBER ,
                        p_specific_item_id      IN      NUMBER ,
                        p_category_set          IN      NUMBER ,
                        p_category_validate_flag IN     VARCHAR2,
                        p_category_structure    IN      NUMBER ,
                        p_specific_category_id  IN      NUMBER ,
                        p_organization_id       IN      NUMBER ,
                        p_item_price_eff_date   IN      VARCHAR2,
                        p_based_on_rollup       IN      NUMBER,
                        p_ad_qp_mult            IN      VARCHAR2,
                        p_conv_type             IN      VARCHAR2,
                        p_conv_date             IN      VARCHAR2,
                        p_def_mtl_subelement    IN      NUMBER ,
                        p_group_id_dummy        IN      NUMBER ,
                        p_group_id              IN      NUMBER
                        ) ;

-- The  function is used for generating unique group id's
-- for import cost from price list SRS launch form.
--

FUNCTION GET_GROUP_ID
  return integer ;

END CST_PL_IMPORT ;


 

/
