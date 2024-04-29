--------------------------------------------------------
--  DDL for Package Body FND_APPFLDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_APPFLDR" AS
/* $Header: AFFLDRB.pls 120.1 2005/07/02 04:06:47 appldev ship $ */


FUNCTION insert_fnd_folders (l_object		 VARCHAR2,
                             l_name		 VARCHAR2,
                             l_language 	 VARCHAR2,
                             l_window_width	 NUMBER,
                             l_public_flag	 VARCHAR2,
                             l_autoquery_flag	 VARCHAR2,
                             l_created_by	 NUMBER,
                             l_last_updated_by	 NUMBER,
                             l_where_clause	 VARCHAR2 default null,
                             l_order_by	         VARCHAR2 default null) RETURN NUMBER IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_folder_id    number;
  cursor next_folder_id is
    select fnd_folders_s.nextval
    from dual;

BEGIN
  --
  -- Get the folder_id from the sequence
  --
  open next_folder_id;
  fetch next_folder_id into l_folder_id;
  close next_folder_id;
  --
  insert into fnd_folders(
    folder_id,
    object,
    name,
    language,
    window_width,
    public_flag,
    autoquery_flag,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    where_clause,
    order_by)
  values (
    l_folder_id,
    l_object,
    l_name,
    l_language,
    l_window_width,
    l_public_flag,
    l_autoquery_flag,
    sysdate,
    l_created_by,
    sysdate,
    l_last_updated_by,
    null,
    l_where_clause,
    l_order_by);

  COMMIT;
  return l_folder_id;
END insert_fnd_folders;


PROCEDURE insert_fnd_folder_columns (l_folder_id	 NUMBER,
				     l_display_mode 	 VARCHAR2,
                                     l_item_name	 VARCHAR2,
                                     l_sequence		 NUMBER,
                                     l_created_by	 NUMBER,
                                     l_last_updated_by	 NUMBER,
                                     l_item_width	 NUMBER,
                                     l_item_prompt	 VARCHAR2,
                                     l_x_position	 NUMBER,
                                     l_y_position	 NUMBER) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  insert into fnd_folder_columns(
    folder_id,
    display_mode,
    item_name,
    sequence,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    item_width,
    item_prompt,
    x_position,
    y_position)
  values (
    l_folder_id,
    l_display_mode,
    l_item_name,
    l_sequence,
    sysdate,
    l_created_by,
    sysdate,
    l_last_updated_by,
    null,
    l_item_width,
    l_item_prompt,
    l_x_position,
    l_y_position);

  COMMIT;
END insert_fnd_folder_columns;


PROCEDURE insert_fnd_default_folders (l_object		VARCHAR2,
                                      l_user_id		NUMBER,
                                      l_folder_id	NUMBER,
                                      l_created_by	NUMBER,
                                      l_last_updated_by	NUMBER) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  insert into fnd_default_folders(
    object,
    user_id,
    folder_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login)
  values (
    l_object,
    l_user_id,
    l_folder_id,
    sysdate,
    l_created_by,
    sysdate,
    l_last_updated_by,
    null);

  COMMIT;
END insert_fnd_default_folders;


PROCEDURE update_fnd_folders (l_folder_id               NUMBER,
                              l_name		        VARCHAR2,
                              l_window_width            NUMBER,
                              l_public_flag             VARCHAR2,
                              l_autoquery_flag          VARCHAR2,
                              l_created_by              NUMBER,
                              l_last_updated_by         NUMBER,
                              l_where_clause            VARCHAR2,
                              l_order_by                VARCHAR2) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  update fnd_folders
  set
     name              = l_name,
     window_width      = l_window_width,
     public_flag       = l_public_flag,
     autoquery_flag    = l_autoquery_flag,
     creation_date     = sysdate,
     created_by        = l_created_by,
     last_update_date  = sysdate,
     last_updated_by   = l_last_updated_by,
     last_update_login = null,
     where_clause      = l_where_clause,
     order_by          = l_order_by
   where
     folder_id = l_folder_id;

  COMMIT;
END update_fnd_folders;


PROCEDURE delete_fnd_default_folders(l_object   VARCHAR2,
                                     l_user_id  NUMBER,
                                     l_language VARCHAR2) is
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  DELETE from fnd_default_folders fdf
  WHERE object = l_object
  and user_id = l_user_id
  and exists (select null
              from   fnd_folders ff
              where  fdf.folder_id = ff.folder_id
              and    ff.language = l_language);

  commit;
END delete_fnd_default_folders;


PROCEDURE delete_fnd_default_folders (l_folder_id NUMBER) is
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  DELETE from fnd_default_folders
  WHERE folder_id = l_folder_id;

  commit;
END delete_fnd_default_folders;


PROCEDURE delete_fnd_folder_columns (l_folder_id NUMBER) is
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  DELETE from fnd_folder_columns
  WHERE folder_id = l_folder_id;

  commit;
END delete_fnd_folder_columns;


PROCEDURE delete_fnd_folders (l_folder_id NUMBER) is
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  DELETE from fnd_folders
  WHERE folder_id = l_folder_id;

  commit;
END delete_fnd_folders;

END fnd_appfldr;

/
