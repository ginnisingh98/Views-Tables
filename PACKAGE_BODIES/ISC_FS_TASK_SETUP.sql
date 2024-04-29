--------------------------------------------------------
--  DDL for Package Body ISC_FS_TASK_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_TASK_SETUP" as
/*$Header: iscfsbftskb.pls 120.0 2005/08/28 14:56:33 kreardon noship $ */

g_user_id  number;
g_login_id number;

PROCEDURE merge_tasks
IS

BEGIN

  g_user_id  := fnd_global.user_id;
  g_login_id := fnd_global.login_id;


  insert into ISC_FS_BREAK_FIX_TASKS
  ( task_type_id
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , enabled
  )
  select
    task_type_id
  , fnd_global.user_id
  , sysdate
  , fnd_global.user_id
  , sysdate
  , fnd_global.login_id
  , 'N'
  from JTF_TASK_TYPES_B jtfb
  where jtfb.rule='DISPATCH'
  and jtfb.task_type_id NOT in ( select task_type_id
                                 from ISC_FS_BREAK_FIX_TASKS
                               );

  commit;

END merge_tasks;

END ISC_FS_TASK_SETUP;


/
