--------------------------------------------------------
--  DDL for Package JL_CO_FA_TA_REVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CO_FA_TA_REVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: jlcoftrs.pls 120.3.12010000.1 2008/07/31 04:23:49 appldev ship $ */

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   revaluate                                                            --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to validate technical appraisals                  --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_book                                                      --
--            p_fiscal_year                                               --
--            p_appraisal_id                                              --
--                                                                        --
-- HISTORY:                                                               --
--    07/15/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE revaluate( ERRBUF        OUT NOCOPY VARCHAR2,
                     RETCODE       OUT NOCOPY VARCHAR2,
                     p_book            VARCHAR2,
                     p_appraisal_id    NUMBER);


end jl_co_fa_ta_reval_pkg;

/
