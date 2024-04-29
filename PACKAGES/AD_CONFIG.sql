--------------------------------------------------------
--  DDL for Package AD_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_CONFIG" AUTHID CURRENT_USER as
/* $Header: adconfgs.pls 115.0 99/07/17 04:30:04 porting ship $ */

FUNCTION release_name(
    p_release_type IN varchar2 default null)  RETURN varchar2;

FUNCTION is_multi_org        RETURN varchar2;
FUNCTION is_multi_lingual    RETURN varchar2;
FUNCTION is_multi_currency   RETURN varchar2;
FUNCTION get_default_org_id  RETURN number;

end AD_CONFIG;

 

/
