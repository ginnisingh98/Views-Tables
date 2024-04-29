--------------------------------------------------------
--  DDL for Package JL_CO_FA_POST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CO_FA_POST_PKG" AUTHID CURRENT_USER AS
/* $Header: jlcofgps.pls 115.0 99/07/16 03:09:56 porting ship $ */

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   purge_adjustment                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure for posting from jl_co_fa_adjustments table to    --               --
-- gl_interface table.                                                                       --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_book                                                      --
--                                                                        --
-- HISTORY:                                                               --
--    08/21/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE post( ERRBUF     OUT VARCHAR2,
                RETCODE    OUT VARCHAR2,
                p_book         VARCHAR2);



END jl_co_fa_post_pkg;

 

/
