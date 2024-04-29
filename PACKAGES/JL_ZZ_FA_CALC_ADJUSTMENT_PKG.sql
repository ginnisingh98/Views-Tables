--------------------------------------------------------
--  DDL for Package JL_ZZ_FA_CALC_ADJUSTMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_FA_CALC_ADJUSTMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzfcas.pls 115.4 2002/11/06 00:09:36 cleyvaol ship $ */
----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   Calc_adjustments                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to calculate adjustments in view                   --
--   JL_ZZ_FA_ADJ_SUMMARY_V.                                              --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   p_book_type_code - Book Type Code                                    --
--   p_period_counter - Period Counter                                    --
--   p_asset_id    - Asset ID                                             --
--   P_adjustment_type - Adjustment Type                                  --
--   P_mode -  Mode                                                       --
--                                                                        --
-- HISTORY:                                                               --
--    02/19/99     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

 FUNCTION calc_adjustments
          ( p_book_type_code         VARCHAR2,
            p_period_counter            NUMBER,
            p_asset_id                       NUMBER,
            p_adjustment_type          VARCHAR2,
            p_mode                           VARCHAR2
          )
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES ( calc_adjustments, WNDS, WNPS, RNPS);

 FUNCTION calc_corp_book_cost
          ( p_book_type_code         VARCHAR2,
            p_period_counter         NUMBER,
            p_asset_id               NUMBER,
            p_mode                   VARCHAR2
          )
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES ( calc_corp_book_cost, WNDS, WNPS, RNPS);

 FUNCTION calc_corp_deprn_reserve
          ( p_book_type_code         VARCHAR2,
            p_period_counter         NUMBER,
            p_asset_id               NUMBER,
            p_mode                   VARCHAR2
          )
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES ( calc_corp_deprn_reserve, WNDS, WNPS, RNPS);

 FUNCTION calc_corp_ytd_deprn
          ( p_book_type_code         VARCHAR2,
            p_period_counter         NUMBER,
            p_asset_id               NUMBER,
            p_mode                   VARCHAR2
          )
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES ( calc_corp_ytd_deprn, WNDS, WNPS, RNPS);

END jl_zz_fa_calc_adjustment_pkg;

 

/
