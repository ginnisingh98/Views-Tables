--------------------------------------------------------
--  DDL for Package Body OTA_CATALOG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CATALOG_UTIL" as
/* $Header: otctgutl.pkb 120.0 2006/03/21 03:08 pgupta noship $ */

g_package  varchar2(33) := 'ota_catalog_util.';  -- Global package name

--
--  ---------------------------------------------------------------------------
--  |--------------------< Get_Forum_Topic_Count >----------------------------|
--  ---------------------------------------------------------------------------
--
Function Get_Forum_Topic_Count
  (p_forum_id IN Number
  ,p_person_id IN Number
  )
  Return Number Is
  --
  -- Declare cursor
  --
  Cursor cur_forum_topics is
    select count(thread_id)
  from
    ( select fth.forum_thread_id thread_id
      from ota_forum_threads fth
      where fth.private_thread_flag = 'N'
            and fth.forum_id = p_forum_id
      UNION ALL
      select fth.forum_thread_id
      from ota_forum_threads fth,
           ota_pvt_frm_thread_users users
      where fth.forum_thread_id = users.forum_thread_id
            and fth.private_thread_flag = 'Y'
            and users.person_id = p_person_id
            and  fth.forum_id = p_forum_id);
  --
  -- Declare local variables
  --
  l_thread_count Number(9);
  l_proc     Varchar2(72)  :=  g_package||'Get_Forum_Topic_Count';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  Open cur_forum_topics;
  Fetch cur_forum_topics into l_thread_count;
  Close cur_forum_topics;
  --
  hr_utility.set_location('Returning:'|| l_proc, 20);
  --
  return l_thread_count;
  --
End Get_Forum_Topic_Count;

--
--  ---------------------------------------------------------------------------
--  |-------------------< Get_Forum_Message_Count >---------------------------|
--  ---------------------------------------------------------------------------
--
Function Get_Forum_Message_Count
 (p_forum_id IN Number
 ,p_person_id IN Number
 )
 Return Number Is
  --
  -- Declare cursor
  --
  Cursor cur_forum_messages is
    select count(message_id)
    from
    (
      select message.forum_message_id message_id
      from ota_forum_messages message, ota_forum_threads threads
      where message.forum_thread_id = threads.forum_thread_id
      and threads.private_thread_flag = 'N'
      and message.forum_id = p_forum_id
    UNION ALL
      select message.forum_message_id message_id
      from ota_forum_messages message, ota_forum_threads threads,
           ota_pvt_frm_thread_users pvtusers
      where message.forum_thread_id = threads.forum_thread_id
            and  threads.forum_id = p_forum_id
            and threads.private_thread_flag = 'Y'
            and message.forum_thread_id = pvtusers.forum_thread_id
            and pvtusers.person_id = p_person_id
            and (message.message_scope = 'T'
                 or (message.message_scope = 'U'
                     and (message.person_id = p_person_id
                          or message.target_person_id = p_person_id
                         )
                     )
                 )
     );
  --
  -- Declare local variables
  --
  l_message_count Number(9);
  l_proc     Varchar2(72)  :=  g_package||'Get_Forum_Message_Count';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  Open cur_forum_messages;
  Fetch cur_forum_messages into l_message_count;
  Close cur_forum_messages;
  --
  hr_utility.set_location('Returning:'|| l_proc, 20);
  --
  Return l_message_count;
  --
End Get_Forum_Message_Count;
--

--
--  ---------------------------------------------------------------------------
--  |------------------< Get_Forum_Last_Post_Date >---------------------------|
--  ---------------------------------------------------------------------------
--
Function Get_Forum_Last_Post_Date
 (p_forum_id IN Number
 )
 Return Date Is
  --
  -- Declare cursor
  --
  Cursor cur_forum_last_post_date is
    select max(message.creation_date)
    from ota_forum_messages message, ota_forum_threads thread
    where message.forum_thread_id = thread.forum_thread_id
          and message.forum_id = p_forum_id;
  --
  -- Declare local variables
  --
  l_message_last_post_date Date;
  l_proc     Varchar2(72)  :=  g_package||'Get_Forum_Last_Post_Date';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  Open cur_forum_last_post_date;
  Fetch cur_forum_last_post_date into l_message_last_post_date;
  Close cur_forum_last_post_date;
  --
  hr_utility.set_location('Returning:'|| l_proc, 20);
  --
  Return l_message_last_post_date;
  --
End Get_Forum_Last_Post_Date;
--
end ota_catalog_util;


/
