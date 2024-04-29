--------------------------------------------------------
--  DDL for Package Body ISC_FS_TASK_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_TASK_PARTY_MERGE_PKG" 
/* $Header: iscfshzmgb.pls 120.0 2005/08/28 14:57:32 kreardon noship $ */
as

procedure task_merge_party
( p_entity_name        in varchar2
, p_from_id            in number
, x_to_id              out nocopy number
, p_from_fk_id         in number
, p_to_fk_id           in number
, p_parent_entity_name in varchar2
, p_batch_id           in number
, p_batch_party_id     in number
, x_return_status      out nocopy varchar2
) is

l_merge_reason_code  varchar2(30);

 cursor c_duplicate is
   select merge_reason_code
   from hz_merge_batch
   where batch_id = p_batch_id;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- only bother with attempting merge if events are enabled (CSF-DBI implemented)
  if isc_fs_event_log_etl_pkg.check_events_enabled <> 'Y' then
    return;
  end if;

  open c_duplicate;
  fetch c_duplicate into l_merge_reason_code;
  close c_duplicate;

  if l_merge_reason_code <> 'DUPLICATE' then

      -- if there are any validations to be done, include it in this section
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.

      null;

  end if;

  -- perform the merge operation

  -- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
  -- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

  if p_from_fk_id = p_to_fk_id  then

      x_to_id := p_from_id;
      return;

  end if;


  -- If the parent has changed(ie. Parent is getting merged) then transfer the
  -- dependent record to the new parent.
  -- For ISC_FS_TASKS_F table, if party_id 1000 got merged to party_id 2000
  -- then we have to insert an event row for each task.  When the incremental
  -- load is next run it will capture the "current" (party_id 2000) data from JTF_TASKS_B

  insert into isc_fs_party_merge_events
  ( send_date
  , event_name
  , source_object_type_code
  , source_object_id
  , task_id
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  )
  select
    hz_utility_pub.last_update_date
  , 'task_merge_party'
  , 'SR'
  , source_object_id
  , task_id
  , hz_utility_pub.user_id
  , hz_utility_pub.last_update_date
  , hz_utility_pub.user_id
  , hz_utility_pub.last_update_date
  , hz_utility_pub.last_update_login
  from
    isc_fs_tasks_f
  where customer_id = p_from_fk_id;

exception
  when others then
    fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
    fnd_message.set_token('ERROR' ,SQLERRM);
    fnd_msg_pub.add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

end task_merge_party;

procedure task_merge_address
( p_entity_name        in varchar2
, p_from_id            in number
, x_to_id              out nocopy number
, p_from_fk_id         in number
, p_to_fk_id           in number
, p_parent_entity_name in varchar2
, p_batch_id           in number
, p_batch_party_id     in number
, x_return_status      out nocopy varchar2
) is

  l_merge_reason_code  varchar2(30);

 cursor c_duplicate is
   select merge_reason_code
   from hz_merge_batch
   where batch_id = p_batch_id;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- only bother with attempting merge if events are enabled (CSF-DBI implemented)
  if isc_fs_event_log_etl_pkg.check_events_enabled <> 'Y' then
    return;
  end if;

  open    c_duplicate;
  fetch   c_duplicate into l_merge_reason_code;
  close   c_duplicate;

  if l_merge_reason_code <> 'DUPLICATE' then

      -- if there are any validations to be done, include it in this section
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.

      null;

  end if;

  -- perform the merge operation

  -- if the parent has NOT changed(i.e. parent  getting transferred)  then nothing
  -- needs to be done. Set merged to id (x_to_id) the same as merged from id and return
  -- If the party_site has been transferred then nothing should be done.

  if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

  end if;


  -- If the parent has changed(ie. Parent is getting merged) then transfer the
  -- dependent record to the new parent.
  -- For ISC_FS_TASKS_F table, if party_site_id 1111 got merged to party_site_id 2222
  -- then we have to insert an event row for each task.  When the incremental
  -- load is next run it will capture the "current" (party_site_id 2222) data from JTF_TASKS_B

  insert into isc_fs_party_merge_events
  ( send_date
  , event_name
  , source_object_type_code
  , source_object_id
  , task_id
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  )
  select
    hz_utility_pub.last_update_date
  , 'task_merge_address'
  , 'SR'
  , source_object_id
  , task_id
  , hz_utility_pub.user_id
  , hz_utility_pub.last_update_date
  , hz_utility_pub.user_id
  , hz_utility_pub.last_update_date
  , hz_utility_pub.last_update_login
  from
    isc_fs_tasks_f
  where address_id = p_from_fk_id;

exception
  when others then
    fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
    fnd_message.set_token('ERROR' ,SQLERRM);
    fnd_msg_pub.add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

end task_merge_address;

end isc_fs_task_party_merge_pkg;

/
