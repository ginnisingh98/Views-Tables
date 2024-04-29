--------------------------------------------------------
--  DDL for Package AD_MO_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_MO_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: admoutls.pls 120.0 2005/06/24 16:20 athies noship $ */

PROCEDURE r12_moac_conv
           (p_prod_user_name         in VARCHAR2,
            p_view_name              in VARCHAR2,
            p_prod_tab_name          in VARCHAR2,
            p_prod_schema_name       in VARCHAR2,
            p_application_short_name in VARCHAR2,
            p_apps_user_name         in VARCHAR2,
            p_sec_policy_name        in VARCHAR2,
            p_action                 in VARCHAR2);

end ad_mo_util_pkg;

 

/
