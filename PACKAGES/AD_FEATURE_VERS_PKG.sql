--------------------------------------------------------
--  DDL for Package AD_FEATURE_VERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_FEATURE_VERS_PKG" AUTHID CURRENT_USER as
/* $Header: adufeats.pls 115.0 2003/03/01 19:07:52 vharihar ship $ */

procedure load_row
(
  p_feature_name       varchar2,
  p_db_version         number,
  p_enabled_flag       varchar2,
  p_rcs_file_keyword   varchar2,
  p_rcs_vers_keyword   varchar2
);


end ad_feature_vers_pkg;

 

/
