--------------------------------------------------------
--  DDL for Package JL_CO_FA_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CO_FA_PURGE_PKG" AUTHID CURRENT_USER AS
/* $Header: jlcoftps.pls 115.6 2002/11/13 23:31:32 vsidhart ship $ */

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   purge_adjustment                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to purge jl_co-fa_adjustments table               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_book                                                      --
--            p_fiscal_year                                               --
--            p_option                                                    --
--                                                                        --
-- HISTORY:                                                               --
--    08/21/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE purge_adjustment( ERRBUF     OUT NOCOPY VARCHAR2,
                            RETCODE    OUT NOCOPY VARCHAR2,
                            p_book         VARCHAR2,
                            p_fiscal_year  NUMBER,
                            p_option       VARCHAR2);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   purge_appraisal                                                      --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to purge the tables jl_co-fa_appraisals and       --
--   jl_co_fa_asset_apprs                                                 --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_fiscal_year                                               --
--            p_option                                                    --
--                                                                        --
-- HISTORY:                                                               --
--    08/21/98     Sujit Dalai    Created                                 --
--    04/26/00   Santosh Vaze  Bug Fix 1100863: Technical Appraisals can  --
--                             not be archived for the fiscal year if     --
--                             there is any unprocessed appraisal. But    --
--                             there is no prevision in the application   --
--                             to delete the erroneous appraisals. This   --
--                             dead lock is removed in this bug fix.      --
----------------------------------------------------------------------------
PROCEDURE purge_appraisal( ERRBUF    OUT NOCOPY VARCHAR2,
                           RETCODE   OUT NOCOPY VARCHAR2,
                           p_fiscal_year NUMBER,
                           p_option      VARCHAR2,
                           p_del_unproc_app VARCHAR2);

END jl_co_fa_purge_pkg;

 

/
