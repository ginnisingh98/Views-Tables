--------------------------------------------------------
--  DDL for Package Body IEM_MGINBOX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MGINBOX_PUB" as
/* $Header: iemmginboxb.pls 120.3 2006/09/01 22:28:06 rtripath noship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_MGINBOX_PUB';
PROCEDURE runInbox (p_api_version_number    IN   NUMBER,
                    p_init_msg_list         IN   VARCHAR2,
                    p_commit                IN   VARCHAR2,
                    p_email_account_id      IN   NUMBER,
                    p_agent_Account_id      IN   NUMBER,
                    p_inb_migration_id      IN   NUMBER,
                    p_outb_migration_id     IN   NUMBER,
				            p_type                  IN   VARCHAR2, --'I' or 'O'
				            p_rerun                 IN   VARCHAR2, --'Y'/'N'
                    x_return_status         OUT NOCOPY  VARCHAR2,
                    x_msg_count             OUT NOCOPY  NUMBER,
                    x_msg_data              OUT NOCOPY  VARCHAR2
                    )
  IS
  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_rt_media_item_id       NUMBER;
  l_rt_interaction_id      NUMBER;
  l_agent_account_id       NUMBER;
  l_resource_id            NUMBER;
  l_folder_name            VARCHAR2(255);
  l_msg_uid                NUMBER;
  l_outb_rt_media_item_id  NUMBER;
  l_outb_agent_account_id  NUMBER;
  l_outb_folder_name       VARCHAR2(255);
  l_outb_msg_uid           NUMBER;
  l_dblink                 VARCHAR2(128);
  l_reply_to_str           VARCHAR2(240);
  l_cc_str           VARCHAR2(240);
  l_bcc_str           VARCHAR2(240);
  l_sequence               NUMBER;
  l_userid                 NUMBER;
  l_loginid                NUMBER;
  l_mig_status_inb         VARCHAR2(1);
  l_mig_status_outb        VARCHAR2(1);
  l_mig_status             VARCHAR2(1);
  l_err_msg                VARCHAR2(1000);
  mdts                     IEM_POST_MDTS%ROWTYPE;

--    select a.message_id, a.email_account_id, a.rfc822_message_id, a.sender_name,
--      a.to_address, a.sent_date, a.subject, a.ih_media_item_id, a.message_size,
--      a.source_message_id

  -- Cursor for p_rerun == 'N'
  Cursor acq_cur IS
    select a.*
    from iem_post_mdts a, iem_agent_accounts b
    where a.email_account_id = p_email_account_id and a.agent_id =
      b.resource_id and b.agent_account_id = p_agent_account_id and
	 a.email_account_id = b.email_account_id;

  -- Cursor for p_rerun == 'Y' and p_type == 'I'
  Cursor acq_inb_re_cur IS
    select a.*
      from iem_post_mdts a, iem_agent_accounts b
      where a.email_account_id = p_email_account_id and a.agent_id =
      b.resource_id and b.agent_account_id = p_agent_account_id and
	    a.email_account_id = b.email_account_id
      and a.message_id not in (select message_id from iem_migration_store_temp
      where migration_id = p_inb_migration_id and message_type = 'I'
      and mig_status = 'R');

  -- Cursor for p_rerun == 'Y' and p_type == 'O'
  Cursor acq_outb_re_cur IS
    select a.*
      from iem_post_mdts a, iem_agent_accounts b
      where a.email_account_id = p_email_account_id and a.agent_id =
      b.resource_id and b.agent_account_id = p_agent_account_id and
	    a.email_account_id = b.email_account_id
      and a.message_id not in (select message_id from iem_migration_store_temp
      where migration_id = p_inb_migration_id and message_type = 'O'
      and mig_status = 'R');
BEGIN
  l_userid := NVL(to_number(FND_PROFILE.VALUE('USER_ID')), -1);
  l_loginid := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

-- Standard Start of API savepoint
  SAVEPOINT runInbox_pvt;

-- Initialize variables
  l_api_name           :='runInbox';
  l_api_version_number :=1.0;


-- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
        FND_MSG_PUB.initialize;
  END IF;

-- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------Code------------------------
if (p_rerun = 'N') then
  OPEN acq_cur;
  LOOP
    FETCH acq_cur INTO mdts;
    EXIT WHEN acq_cur%NOTFOUND;
    l_err_msg := null;
	  begin
      begin
         l_rt_interaction_id := -1;
         select rtm.rt_media_item_id, rtm.rt_interaction_id,
             rtm.agent_account_id, rtm.resource_id, rtm.folder_name,
             rtm.folder_uid
             into l_rt_media_item_id, l_rt_interaction_id, l_agent_account_id,
             l_resource_id, l_folder_name, l_msg_uid
             from iem_rt_media_items rtm, iem_rt_interactions rti
             where rtm.message_id = mdts.message_id and rtm.email_type ='I'
             and rtm.rt_interaction_id = rti.rt_interaction_id
             and rti.expire = 'N';
      exception
             when others then
               l_err_msg := substr('Error in query iem_rt_media_items and iem_rt_interactions'||SQLERRM, 1000);
      end;
	    if (p_type = 'I') then
         begin -- inbound message
           begin
             select a.db_link into l_dblink
               from iem_db_connections a, iem_email_accounts b
               where a.db_server_id=b.db_Server_id
               and b.email_account_id = mdts.email_account_id and a.is_admin='A';
           exception
             when others then
               l_err_msg := substr(l_err_msg ||'Error in query iem_db_connection and iem_email_accounts'||SQLERRM, 1000);
           end;

           begin
             execute immediate 'select reply_to_str, cc_str, bcc_str from '
               ||'OM_HEADER@'||l_dblink||' where msg_id = mdts.source_message_id'
               into l_reply_to_str, l_cc_str, l_bcc_str;
           exception
             when others then
               l_err_msg := substr(l_err_msg || 'Error in query iem_db_connection and iem_email_accounts'||SQLERRM, 1000);
           end;

           if (l_err_msg is null) then
             l_mig_status := 'R';
           else
             l_mig_status := 'E';
           end if;
           select IEM_MIGRATION_STORE_TEMP_S1.nextval into l_sequence from DUAL;
           insert into IEM_MIGRATION_STORE_TEMP (
             mail_id, message_id, migration_id, message_type, email_account_id,
             agent_account_id, resource_id, folder_name, rt_media_item_id,
             msg_uid, rfc822_message_id, from_str, to_str, reply_to_str,
             cc_str, bcc_str, sent_date, subject, ih_media_item_id,
             message_size, created_by, creation_date, last_update_date,
             last_updated_by, last_update_login, mig_status, error_text)
           values (
             l_sequence, mdts.message_id, p_inb_migration_id, 'I', mdts.email_account_id,
             l_agent_account_id, l_resource_id, l_folder_name,
             l_rt_media_item_id, l_msg_uid, mdts.rfc822_message_id,
             mdts.sender_name, mdts.to_address, l_reply_to_str, l_cc_str,
             l_bcc_str, to_char(mdts.sent_date,'DD-MON-YYYY HH24:MI:SS'), mdts.subject,
             mdts.ih_media_item_id, mdts.message_size,
             l_userid, sysdate, sysdate, l_userid, l_loginid, l_mig_status, l_err_msg
             );
         end; -- inbound
	  else -- type 'O'
       begin  -- check for draft
         begin
           select rtm.rt_media_item_id, rtm.agent_account_id, rtm.folder_name,
             rtm.folder_uid into l_outb_rt_media_item_id,
             l_outb_agent_account_id, l_outb_folder_name, l_outb_msg_uid
           from iem_rt_media_items rtm, iem_msg_parts part
           where rtm.rt_interaction_id = l_rt_interaction_id
             and rtm.email_type = 'O' and rtm.folder_uid > 0
             and rtm.folder_name = 'Drafts'
             and part.ref_key = rtm.rt_media_item_id
             and part.part_type = 'HEADERS'
             and part.delete_flag <> 'Y';
         exception
           when NO_DATA_FOUND then
             l_outb_rt_media_item_id := -1;
           when others then
             l_err_msg := substr(l_err_msg ||'Error in query draft' || SQLERRM, 1000);
         end;

         if ( l_outb_rt_media_item_id > 0 ) then
           if (l_err_msg is null) then
             l_mig_status := 'R';
           else
             l_mig_status := 'E';
           end if;
           begin
             select IEM_MIGRATION_STORE_TEMP_S1.nextval into l_sequence from DUAL;
             insert into IEM_MIGRATION_STORE_TEMP (
               mail_id, message_id, migration_id, message_type, email_account_id,
               agent_account_id, resource_id, folder_name,
               rt_media_item_id, msg_uid, created_by, creation_date,
               last_update_date, last_updated_by, last_update_login, mig_status, error_text)
             values (
               l_sequence, mdts.message_id, p_outb_migration_id, 'D', mdts.email_account_id,
               l_outb_agent_account_id, l_resource_id, l_outb_folder_name,
               l_outb_rt_media_item_id, l_outb_msg_uid,
               l_userid, sysdate, sysdate, l_userid, l_loginid, l_mig_status, l_err_msg
               );
           end;
         end if;  -- draft exists
       end;  -- check for draft
	   end if; -- type
   end;
  END LOOP;
  CLOSE acq_cur;
else
  if (p_type = 'I') then
    OPEN acq_inb_re_cur;
    LOOP
         FETCH acq_inb_re_cur INTO mdts;
         EXIT WHEN acq_inb_re_cur%NOTFOUND;
         l_err_msg := null;
         begin -- inbound message
           begin
             select rtm.rt_media_item_id, rtm.rt_interaction_id,
               rtm.agent_account_id, rtm.resource_id, rtm.folder_name,
               rtm.folder_uid
             into l_rt_media_item_id, l_rt_interaction_id, l_agent_account_id,
               l_resource_id, l_folder_name, l_msg_uid
             from iem_rt_media_items rtm, iem_rt_interactions rti
             where rtm.message_id = mdts.message_id and rtm.email_type ='I'
               and rtm.rt_interaction_id = rti.rt_interaction_id
               and rti.expire = 'N';
           exception
             when others then
               l_err_msg := substr('Error in query iem_rt_media_items and iem_rt_interactions'||SQLERRM, 1000);
           end;

           begin
             select a.db_link into l_dblink
               from iem_db_connections a, iem_email_accounts b
               where a.db_server_id=b.db_Server_id
               and b.email_account_id = mdts.email_account_id and a.is_admin='A';
           exception
             when others then
               l_err_msg := substr(l_err_msg ||'Error in query iem_db_connection and iem_email_accounts'||SQLERRM, 1000);
           end;

           begin
             execute immediate 'select reply_to_str, cc_str, bcc_str from '
               ||'OM_HEADER@'||l_dblink||' where msg_id = mdts.source_message_id'
               into l_reply_to_str, l_cc_str, l_bcc_str;
           exception
             when others then
               l_err_msg := substr(l_err_msg || 'Error in query iem_db_connection and iem_email_accounts'||SQLERRM, 1000);
           end;

           if (l_err_msg is null) then
             l_mig_status := 'R';
           else
             l_mig_status := 'E';
           end if;
           select IEM_MIGRATION_STORE_TEMP_S1.nextval into l_sequence from DUAL;
           insert into IEM_MIGRATION_STORE_TEMP (
             mail_id, message_id, migration_id, message_type, email_account_id,
             agent_account_id, resource_id, folder_name, rt_media_item_id,
             msg_uid, rfc822_message_id, from_str, to_str, reply_to_str,
             cc_str, bcc_str, sent_date, subject, ih_media_item_id,
             message_size, created_by, creation_date, last_update_date,
             last_updated_by, last_update_login, mig_status, error_text)
           values (
             l_sequence, mdts.message_id, p_inb_migration_id, 'I', mdts.email_account_id,
             l_agent_account_id, l_resource_id, l_folder_name,
             l_rt_media_item_id, l_msg_uid, mdts.rfc822_message_id,
             mdts.sender_name, mdts.to_address, l_reply_to_str, l_cc_str,
             l_bcc_str,to_char(mdts.sent_date,'DD-MON-YYYY HH24:MI:SS'), mdts.subject,
             mdts.ih_media_item_id, mdts.message_size,
             l_userid, sysdate, sysdate, l_userid, l_loginid, l_mig_status, l_err_msg
             );
           delete from IEM_MIGRATION_STORE_TEMP where migration_id = p_inb_migration_id
             and message_id = mdts.message_id and message_type = 'I'
             and mig_status <> 'R' and mail_id <> l_sequence;
         end; -- inbound
     END LOOP;
     CLOSE acq_inb_re_cur;
  else
    OPEN acq_outb_re_cur;
    LOOP
       FETCH acq_outb_re_cur INTO mdts;
       EXIT WHEN acq_outb_re_cur%NOTFOUND;
       begin  -- check for draft
         begin
           l_err_msg := null;
           select rtm.rt_media_item_id, rtm.agent_account_id, rtm.folder_name,
             rtm.folder_uid into l_outb_rt_media_item_id,
             l_outb_agent_account_id, l_outb_folder_name, l_outb_msg_uid
           from iem_rt_media_items rtm, iem_msg_parts part
           where rtm.rt_interaction_id = l_rt_interaction_id
             and rtm.email_type = 'O' and rtm.folder_uid > 0
             and rtm.folder_name = 'Drafts'
             and part.ref_key = rtm.rt_media_item_id
             and part.part_type = 'HEADERS'
             and part.delete_flag <> 'Y';
         exception
           when NO_DATA_FOUND then
             l_outb_rt_media_item_id := -1;
           when others then
             l_err_msg := substr('Error in query draft' || SQLERRM, 1000);
         end;

         if ( l_outb_rt_media_item_id > 0 ) then
           if (l_err_msg is null) then
             l_mig_status := 'R';
           else
             l_mig_status := 'E';
           end if;
           begin
             select IEM_MIGRATION_STORE_TEMP_S1.nextval into l_sequence from DUAL;
             insert into IEM_MIGRATION_STORE_TEMP (
               mail_id, message_id, migration_id, message_type, email_account_id,
               agent_account_id, resource_id, folder_name,
               rt_media_item_id, msg_uid, created_by, creation_date,
               last_update_date, last_updated_by, last_update_login, mig_status, error_text)
             values (
               l_sequence, mdts.message_id, p_outb_migration_id, 'D', mdts.email_account_id,
               l_outb_agent_account_id, l_resource_id, l_outb_folder_name,
               l_outb_rt_media_item_id, l_outb_msg_uid,
               l_userid, sysdate, sysdate, l_userid, l_loginid, l_mig_status, l_err_msg
               );
             delete from IEM_MIGRATION_STORE_TEMP where migration_id = p_outb_migration_id
               and message_id = mdts.message_id and message_type = 'O'
               and mig_status <> 'R' and mail_id <> l_sequence;
           end;
         end if;  -- draft exists
       end;  -- check for draft
    END LOOP;
    CLOSE acq_outb_re_cur;
  end if; -- rerun draft
end if; -- check rerun

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                            p_count =>  x_msg_count,
                            p_data  =>  x_msg_data
	);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO runInbox_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);
   WHEN OTHERS THEN
          ROLLBACK TO runInbox_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);

End runInbox;
End IEM_MGINBOX_PUB;

/
