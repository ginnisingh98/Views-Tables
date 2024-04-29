--------------------------------------------------------
--  DDL for Package FND_OAM_METALINK_CREDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_METALINK_CREDS" AUTHID CURRENT_USER AS
  /* $Header: AFOAMMCS.pls 120.2 2005/10/19 11:25:23 ilawler noship $ */

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
        p_retcode OUT NOCOPY number);


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
        p_retcode OUT NOCOPY number);

  PROCEDURE test;

END fnd_oam_metalink_creds;

 

/
