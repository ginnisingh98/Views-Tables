--------------------------------------------------------
--  DDL for Package Body JL_ZZ_FA_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_FA_UTILITIES_PKG" AS
/* $Header: jlzzsutb.pls 115.1 99/09/03 13:16:51 porting shi $ */

  ------------------------------------------------------------
  -- Procedure raise_error                                  --
  --                                                        --
  -- Retrieves an application code and message and stops    --
  -- the execution of the program.                          --
  ------------------------------------------------------------
  PROCEDURE raise_error (p_app_name IN VARCHAR2
                       , p_msg_name IN VARCHAR2
                       , p_msg_type IN VARCHAR2) IS

    l_err_msg VARCHAR2(1000);

  BEGIN
    fnd_message.set_name (p_app_name,p_msg_name);
    l_err_msg := fnd_message.get;
    app_exception.raise_exception (exception_type => p_msg_type
    , exception_code =>
      jl_zz_fa_utilities_pkg.get_app_errnum(p_app_name,p_msg_name)
                                , exception_text => l_err_msg);

  END raise_error;

  ------------------------------------------------------------
  -- Procedure raise_ora_error                              --
  --                                                        --
  -- Retrieves an Oracle error and stops the execution of   --
  -- the program.                                           --
  ------------------------------------------------------------
  PROCEDURE raise_ora_error IS
    l_err_msg VARCHAR2(1000);

  BEGIN

    l_err_msg := SQLERRM;
    app_exception.raise_exception (exception_text => l_err_msg);

  END raise_ora_error;

  ------------------------------------------------------------
  -- Function get_app_errnum                                --
  --                                                        --
  -- Retrieves the application error number, with the       --
  -- application short name and message name given.         --
  ------------------------------------------------------------
  FUNCTION get_app_errnum(p_app_name IN VARCHAR2,
                          p_msg_name IN VARCHAR2)
                          return number IS
    msg_num FND_NEW_MESSAGES.MESSAGE_NUMBER%TYPE;

  BEGIN
    BEGIN
      select message_number
      into msg_num
      from fnd_new_messages a, fnd_application b
      where upper(a.language_code) = upper(userenv('LANG'))
      and   upper(a.message_name)  = upper(p_msg_name)
      and   a.application_id       = b.application_id
      and   b.application_short_name = upper(p_app_name);
    EXCEPTION
      when others then
        msg_num := 0;
    END;
     return(msg_num);
  END get_app_errnum;

  ------------------------------------------------------------
  -- Procedure do_commit                                    --
  --                                                        --
  -- Execute commit at server side, to be able to execute   --
  -- a "commit" in forms regardless of the trigger where    --
  -- the code is being executed.                            --
  ------------------------------------------------------------
  PROCEDURE do_commit is
  BEGIN
    commit;
  END do_commit;

END JL_ZZ_FA_UTILITIES_PKG;

/
