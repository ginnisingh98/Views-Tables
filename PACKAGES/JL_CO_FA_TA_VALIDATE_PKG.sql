--------------------------------------------------------
--  DDL for Package JL_CO_FA_TA_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CO_FA_TA_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: jlcoftvs.pls 115.0 99/07/16 03:10:51 porting ship $ */
----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   validate_status                                                      --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to validate technical appraisals                  --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--       p_appraisal_id - Appraisal identification number                 --                                                              --
--                                                                        --
-- HISTORY:                                                               --
--    07/15/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------


PROCEDURE validate_status ( ERRBUF OUT VARCHAR2,
                            RETCODE OUT VARCHAR2,
                            p_appraisal_id  IN NUMBER
                          );

END jl_co_fa_ta_validate_pkg;

 

/
