--------------------------------------------------------
--  DDL for Package Body FND_OAM_METALINK_CREDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_METALINK_CREDS" AS
  /* $Header: AFOAMMCB.pls 120.2 2005/10/19 11:26:34 ilawler noship $ */

  PROCEDURE dbg_print(p_msg varchar2)
  AS

  BEGIN
        null;
        --dbms_output.put_line(p_msg);
  END dbg_print;


  --
  -- Name
  --   put_credentials
  --
  -- Purpose
  --   Stores the given metalink credentials for the given user in
  --   fnd_oam_metalink_cred. If a row already exists for given username
  --   it will update, otherwise it will insert a new row
  --
  -- Input Arguments
  --    p_username - Applications username
  --    p_metalink_userid - Metalink User id
  --    p_metalink_password - Metalink password
  --    p_email_address - Email address
  -- Output Arguments
  --    p_errmsg - Error message if any error occurs
  --    p_retcode - Return code. 0 if success otherwise error.
  -- Notes:
  --
  --
  PROCEDURE put_credentials(
        p_username varchar2,
        p_metalink_userid varchar2,
        p_metalink_password varchar2,
        p_email_address varchar2,
        p_errmsg OUT NOCOPY varchar2,
        p_retcode OUT NOCOPY number)
  AS
        v_userid number;

        v_key raw(24);
        v_encr raw(2000);
        v_dec raw(2000);
        v_enc fnd_oam_metalink_cred.metalink_password%TYPE;

  BEGIN
        p_retcode := 0;
        p_errmsg := '';

        select user_id into v_userid
          from fnd_user where upper(user_name) = upper(p_username);

        v_key := fnd_crypto.randombytes(24);

        --
        -- Note: The call to utl_raw.cast_to_raw as coded below
        -- may cause problems if database characterset changes.
        -- Ideally it should be converted to UTF8 first.
        --
        -- Proper call.  Works in 10g.
        -- plaintext => utl_raw.cast_to_raw(
        --     convert(p_metalink_password, 'AL32UTF8'));
        --

        v_encr := fnd_crypto.encrypt(
                plaintext => utl_raw.cast_to_raw(p_metalink_password),
                key => v_key);
        v_dec := v_key || v_encr;
        v_enc := fnd_crypto.encode(
                source => v_dec,
                fmt_type => fnd_crypto.ENCODE_B64);


         begin
          select user_id into v_userid
           from fnd_oam_metalink_cred
           where user_id = v_userid;

          update fnd_oam_metalink_cred set
                metalink_user_id = p_metalink_userid,
                metalink_password = v_enc,
                email_address = p_email_address,
                last_updated_by = v_userid,
                last_update_date = sysdate,
                last_update_login = 0
            where user_id = v_userid;
         exception
          when no_data_found then
            insert into fnd_oam_metalink_cred (
                user_id,
                metalink_user_id,
                metalink_password,
                email_address,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login)
            values (
                v_userid,
                p_metalink_userid,
                v_enc,
                p_email_address,
                v_userid,
                sysdate,
                v_userid,
                sysdate,
                0);
         end;
  EXCEPTION
        when others then
                p_retcode := 1;
                p_errmsg := SQLERRM;
  END put_credentials;

  --
  -- Name
  --   get_credentials
  --
  -- Purpose
  --   Retrieves the given metalink credentials for the given user
  --
  -- Input Arguments
  --    p_username - Applications username
  --
  -- Output Arguments
  --    p_metalink_userid - Metalink User id
  --    p_metalink_password - Metalink password
  --    p_email_address - Email address
  --    p_errmsg - Error message if any error occurs
  --    p_retcode - Return code. 0 if success otherwise error.
  -- Notes:
  --
  PROCEDURE get_credentials(
        p_username varchar2,
        p_metalink_userid OUT NOCOPY varchar2,
        p_metalink_password OUT NOCOPY varchar2,
        p_email_address OUT NOCOPY varchar2,
        p_errmsg OUT NOCOPY varchar2,
        p_retcode OUT NOCOPY number)
  AS
        v_key raw(24);
        v_encr raw(2000);
        v_dec raw(2000);
        v_enc fnd_oam_metalink_cred.metalink_password%TYPE;
  BEGIN
        p_retcode := 0;
        p_errmsg := '';
        p_metalink_userid := '';
        p_metalink_password := '';
        p_email_address := '';

        select  fom.metalink_user_id,
                fom.metalink_password,
                fom.email_address
         into   p_metalink_userid,
                v_enc,
                p_email_address
         from   fnd_oam_metalink_cred fom,
                fnd_user fu
         where  fu.user_id = fom.user_id
          and   upper(fu.user_name) = upper(p_username);

        v_dec := fnd_crypto.decode(
                source => v_enc,
                fmt_type => fnd_crypto.ENCODE_B64);
        v_key := utl_raw.substr(v_dec, 1, 24);
        v_encr := utl_raw.substr(v_dec, 25);


        --
        -- Note: The call to utl_raw.cast_to_varchar2 as coded below
        -- may cause problems if database characterset changes.
        -- Ideally it should be converted to UTF8 first.
        --
        -- Proper call.  Works in 10g.
        -- p_metalink_password := utl_raw.cast_to_varchar2
        --       (utl_raw.convert(src, userenv('language'),
        --              'AMERICAN_AMERICA.AL32UTF8'));
        --

        p_metalink_password := utl_raw.cast_to_varchar2(fnd_crypto.decrypt(
                cryptext => v_encr,
                key => v_key));

  EXCEPTION
        when no_data_found then
                null;
        when others then
                p_retcode := 1;
                p_errmsg := SQLERRM;
  END get_credentials;

  --
  -- For testing only
  --
  PROCEDURE test
  AS
        v_errmsg varchar2(1000);
        v_retcode binary_integer;
        v_mlink_userid varchar2(100);
        v_mlink_pw varchar2(240);
        v_email varchar2(240);

        v_username varchar2(30) := 'anonymous';

  BEGIN
    dbg_print('Adding credentials .. ');
    fnd_oam_metalink_creds.put_credentials(
        p_username => v_username,
        p_metalink_userid => 'test_user',
        p_metalink_password => 'welcome1',
        p_email_address => 'test@oracle.com',
        p_errmsg => v_errmsg,
        p_retcode => v_retcode);
    dbg_print('Ret code: ' || to_char(v_retcode));
    dbg_print('Err msg: ' || v_errmsg);

    dbg_print('Getting credentials .. ');
    fnd_oam_metalink_creds.get_credentials(
        p_username => v_username,
        p_metalink_userid => v_mlink_userid,
        p_metalink_password => v_mlink_pw,
        p_email_address => v_email,
        p_errmsg => v_errmsg,
        p_retcode => v_retcode);
    dbg_print('Ret code: ' || to_char(v_retcode));
    dbg_print('Err msg: ' || v_errmsg);
    dbg_print('Mlink user: ' || v_mlink_userid);
    dbg_print('Mlink pw: ' || v_mlink_pw);
    dbg_print('Email: ' || v_email);

    dbg_print('Updating credentials .. ');
    fnd_oam_metalink_creds.put_credentials(
        p_username => v_username,
        p_metalink_userid => 'test_user2',
        p_metalink_password => 'abcdefghijklmnopqrstuvwxyz0123456789',
        p_email_address => 'test2@oracle.com',
        p_errmsg => v_errmsg,
        p_retcode => v_retcode);
    dbg_print('Ret code: ' || to_char(v_retcode));
    dbg_print('Err msg: ' || v_errmsg);

    dbg_print('Getting credentials .. ');
    fnd_oam_metalink_creds.get_credentials(
        p_username => v_username,
        p_metalink_userid => v_mlink_userid,
        p_metalink_password => v_mlink_pw,
        p_email_address => v_email,
        p_errmsg => v_errmsg,
        p_retcode => v_retcode);
    dbg_print('Ret code: ' || to_char(v_retcode));
    dbg_print('Err msg: ' || v_errmsg);
    dbg_print('Mlink user: ' || v_mlink_userid);
    dbg_print('Mlink pw: ' || v_mlink_pw);
    dbg_print('Email: ' || v_email);

    dbg_print('Rolling back test data .. ');
    rollback;
  END test;

END fnd_oam_metalink_creds;

/
