--------------------------------------------------------
--  DDL for Package JL_ZZ_FA_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_FA_UTILITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzsuts.pls 115.1 99/09/03 13:16:54 porting shi $ */

  ------------------------------------------------------------
  -- Procedure raise_error                                  --
  --                                                        --
  -- Retrieves an application code and message and stops    --
  -- the execution of the program.                          --
  ------------------------------------------------------------
  PROCEDURE raise_error (p_app_name IN VARCHAR2
                       , p_msg_name IN VARCHAR2
                       , p_msg_type IN VARCHAR2);

  ------------------------------------------------------------
  -- Procedure raise_ora_error                              --
  --                                                        --
  -- Retrieves an Oracle error and stops the execution of   --
  -- the program.                                           --
  ------------------------------------------------------------
  PROCEDURE raise_ora_error;

  ------------------------------------------------------------
  -- Function get_app_errnum                                --
  --                                                        --
  -- Retrieves the application error number, with the       --
  -- application short name and message name given.         --
  ------------------------------------------------------------
  FUNCTION get_app_errnum(p_app_name IN VARCHAR2,
                          p_msg_name IN VARCHAR2)
                          return number;
  PRAGMA RESTRICT_REFERENCES(get_app_errnum,WNDS);

  ------------------------------------------------------------
  -- Procedure do_commit                                    --
  --                                                        --
  -- Execute commit at server side, to be able to execute   --
  -- a "commit" in forms regardless of the trigger where    --
  -- the action is being executed.                          --
  ------------------------------------------------------------
  PROCEDURE do_commit;

END JL_ZZ_FA_UTILITIES_PKG;

 

/
