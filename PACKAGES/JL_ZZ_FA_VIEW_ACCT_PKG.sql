--------------------------------------------------------
--  DDL for Package JL_ZZ_FA_VIEW_ACCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_FA_VIEW_ACCT_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzfvas.pls 120.0 2005/06/09 23:16:12 appradha ship $ */


 FUNCTION is_JL_FA_view_acct
  RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES ( is_JL_FA_drilldown, WNDS, WNPS, RNPS);

END jl_zz_fa_view_acct_pkg;

 

/
