--------------------------------------------------------
--  DDL for Package Body PRP_GROUP_TOKENS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRP_GROUP_TOKENS_PKG" as
/* $Header: PRPTGTKB.pls 120.1 2005/10/21 17:39:08 hekkiral noship $ */

--
-- Should be called only from lct file
--+
procedure LOAD_ROW
  (
  p_owner                 IN VARCHAR2,
  p_group_token_id        IN NUMBER,
  p_object_version_number IN NUMBER,
  p_group_id              IN NUMBER,
  p_token_id              IN NUMBER
  )
is
  l_user_id                        NUMBER := 0;
  l_login_id                       NUMBER := 0;
  l_rowid                          VARCHAR2(256);

  CURSOR c(c_group_token_id NUMBER) IS SELECT rowid FROM prp_group_tokens
    WHERE group_token_id = c_group_token_id;

begin

    l_user_id := fnd_load_util.owner_id(p_owner);

  UPDATE prp_group_tokens SET
    object_version_number = p_object_version_number,
    group_id = p_group_id,
    token_id = p_token_id,
    last_update_date = sysdate,
    last_updated_by = l_user_id,
    last_update_login = l_login_id
    WHERE group_token_id = p_group_token_id;

  IF (sql%NOTFOUND) THEN

    INSERT INTO prp_group_tokens
      (
      group_token_id,
      object_version_number,
      group_id,
      token_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
      )
      VALUES
      (
      p_group_token_id,
      p_object_version_number,
      p_group_id,
      p_token_id,
      sysdate,
      l_user_id,
      sysdate,
      l_user_id,
      l_login_id
      );

    OPEN c(p_group_token_id);
    FETCH c INTO l_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END IF;

end LOAD_ROW;

end PRP_GROUP_TOKENS_PKG;

/
