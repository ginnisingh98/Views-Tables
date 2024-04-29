--------------------------------------------------------
--  DDL for Package JL_ZZ_GL_COPY_JE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_GL_COPY_JE_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzgcjs.pls 120.4 2005/04/08 20:57:49 vsidhart ship $ */

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   copy                                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to copy journal entry from one                    --
--   sets of books and put them in gl_interface table to be imported      --
--   for another sets of books.                                           --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_from_book                                                 --
--            p_to_book                                                   --
--            p_period                                                    --
--                                                                        --
-- HISTORY:                                                               --
--    12/10/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE copy( ERRBUF      OUT NOCOPY VARCHAR2,
                RETCODE     OUT NOCOPY VARCHAR2,
                p_from_ledger   NUMBER,
                p_to_ledger     NUMBER,
                p_period        VARCHAR2);


END jl_zz_gl_copy_je_pkg;

 

/
