--------------------------------------------------------
--  DDL for Package JL_ZZ_FA_DRILL_DOWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_FA_DRILL_DOWN_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzfdds.pls 115.3 2002/11/06 00:09:49 cleyvaol ship $ */


 FUNCTION is_JL_FA_drilldown
          ( p_je_header_id             NUMBER,
            p_je_source                VARCHAR2,
            p_je_category              VARCHAR2
          )
  RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES ( is_JL_FA_drilldown, WNDS, WNPS, RNPS);

END jl_zz_fa_drill_down_pkg;

 

/
