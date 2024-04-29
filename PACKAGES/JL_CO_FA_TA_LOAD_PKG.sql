--------------------------------------------------------
--  DDL for Package JL_CO_FA_TA_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CO_FA_TA_LOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: jlcoftls.pls 115.0 99/07/16 03:10:18 porting sh $ */


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   load                                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to load  technical appraisals information into    --
--   system, validates loaded informatiom and generate a report on loaded --
--   information.                                                         --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--       p_file_name    - Full path name of file that contains appraisal  --                                                              --
--       information.                                                     --
-- HISTORY:                                                               --
--    05/18/99     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
PROCEDURE load  ( ERRBUF    OUT VARCHAR2,
                  RETCODE   OUT VARCHAR2,
                  p_file_name   VARCHAR2);


END jl_co_fa_ta_load_pkg;

 

/
