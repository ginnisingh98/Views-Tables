--------------------------------------------------------
--  DDL for Package Body IEM_OP_ADMIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_OP_ADMIN_PUB" as
/* $Header: iemoadmb.pls 120.1 2005/07/14 10:40:38 appldev ship $*/

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'IEM_OP_ADMIN';
G_EXPIRE   CONSTANT    VARCHAR2(1)  := 'Y';
G_ACTIVE   CONSTANT    VARCHAR2(1)  := 'N';
DATE_FORMAT CONSTANT   VARCHAR2(30) := 'MM/DD/RRRR HH24:MI:SS';
G_NEWREROUTE CONSTANT  VARCHAR2(1)  := 'H';
G_DORMANT  CONSTANT    VARCHAR2(1)  := 'D';
G_ALL      CONSTANT    NUMBER       := -1;
G_PROCESSING  CONSTANT   VARCHAR2(1)  := 'G';


-- p_sort_by M: rt_media_item_id, T: action, A: agent, S: summary, D: detail, C: create_date
TYPE op_rectype IS RECORD (
    rt_media_item_id NUMBER(15),
    error_summary   VARCHAR2(500),
    error_detail    VARCHAR2(4000),
    create_date     DATE,
    create_date_str VARCHAR2(80));

procedure getItemError(p_api_version_number    IN   NUMBER,
                       p_init_msg_list         IN   VARCHAR2,
                       p_commit                IN   VARCHAR2,
                       p_page_no               IN   NUMBER,
                       p_disp_size             IN   NUMBER,
                       p_sort_by               IN   VARCHAR2,
                       p_sort_dir              IN   NUMBER, --0 asc, 1 desc
                       x_return_status         OUT NOCOPY  VARCHAR2,
                       x_msg_count             OUT NOCOPY  NUMBER,
                       x_msg_data              OUT NOCOPY  VARCHAR2,
                       x_total                 OUT NOCOPY  NUMBER,
                       x_item_err              OUT NOCOPY  SYSTEM.IEM_OP_ERR_OBJ_ARRAY)
IS


  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;

  l_op_rec               op_rectype;

  TYPE get_status is REF CURSOR;
  op_cur                  get_status;
  l_outbox_data           SYSTEM.IEM_OP_ERR_OBJ;
  l_outbox_array          SYSTEM.IEM_OP_ERR_OBJ_ARRAY;

  str                     VARCHAR2(500);

  l_rt_interaction_id     NUMBER;
  l_resource_id           NUMBER;
  l_action                VARCHAR2(1);
  l_name                  VARCHAR2(100);
  G_ACTIVE                VARCHAR2(1);
  G_DIR                   VARCHAR2(8);
  L_STR_SIZE              NUMBER := 200;
  l_start                 NUMBER;
  l_first                 NUMBER;
  l_last                  NUMBER;
  x                       BOOLEAN;


begin

-- Standard Start of API savepoint
        SAVEPOINT getItemError_pvt;

-- Init values
   l_api_name               :='getItemError';
   l_api_version_number     :=1.0;
   G_ACTIVE                := 'Y';
   G_DIR                   := 'asc';

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

----------------------code ------------------
  if (p_sort_by = 'M') then

     if (p_sort_dir = 0) then
       str := 'select a.RT_MEDIA_ITEM_ID, a.ERROR_SUMMARY, a.ERROR_MESSAGE, a.CREATE_DATE, to_char(a.create_date, :1) FROM IEM_OUTBOX_ERRORS a
where a.outbox_error_id = (select max(b.outbox_error_id)
from IEM_OUTBOX_ERRORS b where a.rt_media_item_id = b.rt_media_item_id and b.expire <> :2 and b.create_date = (select max(b.create_date) from IEM_OUTBOX_ERRORS c where a.rt_media_item_id = c.rt_media_item_id)) order by rt_media_item_id asc';
     else
       str := 'select a.RT_MEDIA_ITEM_ID, a.ERROR_SUMMARY, a.ERROR_MESSAGE, a.CREATE_DATE, to_char(a.create_date, :1) FROM IEM_OUTBOX_ERRORS a
where a.outbox_error_id = (select max(b.outbox_error_id)
from IEM_OUTBOX_ERRORS b where a.rt_media_item_id = b.rt_media_item_id and b.expire <> :2 and b.create_date = (select max(b.create_date) from IEM_OUTBOX_ERRORS c where a.rt_media_item_id = c.rt_media_item_id)) order by rt_media_item_id desc';
     end if;

  elsif (p_sort_by = 'S') then

     if (p_sort_dir = 0) then
       str := 'select a.RT_MEDIA_ITEM_ID, a.ERROR_SUMMARY, a.ERROR_MESSAGE, a.CREATE_DATE, to_char(a.create_date, :1) FROM IEM_OUTBOX_ERRORS a
where a.outbox_error_id = (select max(b.outbox_error_id)
from IEM_OUTBOX_ERRORS b where a.rt_media_item_id = b.rt_media_item_id and b.expire <> :2 and b.create_date = (select max(b.create_date) from IEM_OUTBOX_ERRORS c where a.rt_media_item_id = c.rt_media_item_id)) order by error_summary asc';
     else
       str := 'select a.RT_MEDIA_ITEM_ID, a.ERROR_SUMMARY, a.ERROR_MESSAGE, a.CREATE_DATE, to_char(a.create_date, :1) FROM IEM_OUTBOX_ERRORS a
where a.outbox_error_id = (select max(b.outbox_error_id)
from IEM_OUTBOX_ERRORS b where a.rt_media_item_id = b.rt_media_item_id and b.expire <> :2 and b.create_date = (select max(b.create_date) from IEM_OUTBOX_ERRORS c where a.rt_media_item_id = c.rt_media_item_id)) order by error_summary desc';
     end if;

  elsif (p_sort_by = 'D') then
     if (p_sort_dir = 0) then
       str := 'select a.RT_MEDIA_ITEM_ID, a.ERROR_SUMMARY, a.ERROR_MESSAGE, a.CREATE_DATE, to_char(a.create_date, :1) FROM IEM_OUTBOX_ERRORS a
where a.outbox_error_id = (select max(b.outbox_error_id)
from IEM_OUTBOX_ERRORS b where a.rt_media_item_id = b.rt_media_item_id and b.expire <> :2 and b.create_date = (select max(b.create_date) from IEM_OUTBOX_ERRORS c where a.rt_media_item_id = c.rt_media_item_id)) order by error_message asc';
     else
       str := 'select a.RT_MEDIA_ITEM_ID, a.ERROR_SUMMARY, a.ERROR_MESSAGE, a.CREATE_DATE, to_char(a.create_date, :1) FROM IEM_OUTBOX_ERRORS a
where a.outbox_error_id = (select max(b.outbox_error_id)
from IEM_OUTBOX_ERRORS b where a.rt_media_item_id = b.rt_media_item_id and b.expire <> :2 and b.create_date = (select max(b.create_date) from IEM_OUTBOX_ERRORS c where a.rt_media_item_id = c.rt_media_item_id)) order by error_message desc';
    end if;
  elsif (p_sort_by = 'C') then
     if (p_sort_dir = 0) then
       str := 'select a.RT_MEDIA_ITEM_ID, a.ERROR_SUMMARY, a.ERROR_MESSAGE, a.CREATE_DATE, to_char(a.create_date, :1) FROM IEM_OUTBOX_ERRORS a
where a.outbox_error_id = (select max(b.outbox_error_id)
from IEM_OUTBOX_ERRORS b where a.rt_media_item_id = b.rt_media_item_id and b.expire <> :2 and b.create_date = (select max(b.create_date) from IEM_OUTBOX_ERRORS c where a.rt_media_item_id = c.rt_media_item_id)) order by create_date asc';
     else
       str := 'select a.RT_MEDIA_ITEM_ID, a.ERROR_SUMMARY, a.ERROR_MESSAGE, a.CREATE_DATE, to_char(a.create_date, :1) FROM IEM_OUTBOX_ERRORS a
where a.outbox_error_id = (select max(b.outbox_error_id)
from IEM_OUTBOX_ERRORS b where a.rt_media_item_id = b.rt_media_item_id and b.expire <> :2 and b.create_date = (select max(b.create_date) from IEM_OUTBOX_ERRORS c where a.rt_media_item_id = c.rt_media_item_id)) order by create_date desc';
     end if;

  end if;

  OPEN op_cur FOR str USING DATE_FORMAT, G_ACTIVE;
  l_outbox_array := SYSTEM.IEM_OP_ERR_OBJ_ARRAY();
  l_start := 0;

  LOOP
    begin

      FETCH op_cur into l_op_rec;
      EXIT WHEN op_cur%NOTFOUND;

      x := false;
      if (l_start = 0) then
         x := true;
      else
	    -- Since there are multiple records for one msg at iem_outbox_errors,
	    -- l_op_rec can have multi-records for same rt_media_item_id.
         if (l_op_rec.rt_media_item_id <> l_outbox_array(l_outbox_array.LAST).rt_media_item_id) then
           x := true;
         end if;
     end if;
     if ( x ) then
	   l_rt_interaction_id := 0;
	   l_resource_id := 0;
        l_action := null;
	   l_name := null;
	   begin
          select rt_interaction_id into l_rt_interaction_id
		from iem_rt_media_items
          where rt_media_item_id = l_op_rec.rt_media_item_id;

          select resource_id, status into l_resource_id, l_action
          from iem_rt_interactions
          where rt_interaction_id = l_rt_interaction_id;
        exception
		-- If no data found because of descripancy in database
		-- ignore those messages.
	     when others then
		  null;
        end;
	   if ( l_resource_id > 0 ) then
		begin
            select user_name into l_name from jtf_rs_resource_extns
		  where resource_id = l_resource_id;
		exception
		  when others then
		    null;
          end;
          l_outbox_array.EXTEND;
          l_outbox_array(l_outbox_array.LAST) := SYSTEM.IEM_OP_ERR_OBJ(
                                l_op_rec.rt_media_item_id,
                                l_action, l_name,
                                l_op_rec.error_summary,
                                substr(l_op_rec.error_detail,1,200),
                                l_op_rec.create_date,
                                l_op_rec.create_date_str);

          l_start := 1;
        end if; -- l_resource_id exists.
      end if; -- x true.
    end;
  END LOOP;
  CLOSE op_cur;

  -- figure out what to return and display
  x_total := l_outbox_array.count;

  IF (p_disp_size is null OR p_disp_size = -1) THEN
    l_first := l_outbox_array.FIRST;
    l_last := l_outbox_array.LAST;
    x_item_err := l_outbox_array;
  ELSE
    l_first := (p_page_no - 1)*p_disp_size + 1;
    l_last := p_page_no*p_disp_size;
    if ( l_last > l_outbox_array.LAST ) then
      l_last := l_outbox_array.LAST;
    end if;

    x_item_err := SYSTEM.IEM_OP_ERR_OBJ_ARRAY();
    if ( x_total > 0 ) then
      FOR i in l_first..l_last LOOP
        x_item_err.EXTEND;
        x_item_err(x_item_err.LAST) := l_outbox_array(i);
      END LOOP;
    end if;
  END IF;

--------------------------
-- Standard Check Of p_commit.
     IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
     END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
               ( p_encoded => FND_API.G_TRUE,
                 p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
               );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO getItemError_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO getItemError_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO getItemError_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);



end;


procedure clearOutboxErrors(p_api_version_number    IN   NUMBER,
                   p_init_msg_list         IN   VARCHAR2,
                   p_commit                IN   VARCHAR2,
                   p_rt_media_item_id_array IN  SYSTEM.IEM_RT_MSG_KEY_ARRAY,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2)
IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;


begin

-- Standard Start of API savepoint
        SAVEPOINT clearOutboxErrors_pvt;

-- Init values
  l_api_name               :='clearOutboxErrors';
  l_api_version_number     :=1.0;

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

----------------------code ------------------

  if ( p_rt_media_item_id_array.COUNT > 0 ) then
    if ( p_rt_media_item_id_array(p_rt_media_item_id_array.FIRST).num = G_ALL ) then
        delete from iem_outbox_errors;
    else
      for i in p_rt_media_item_id_array.FIRST..p_rt_media_item_id_array.LAST loop
        delete from iem_outbox_errors where rt_media_item_id = p_rt_media_item_id_array(i).num;
      end loop;
    end if;
  end if;
--------------------------
-- Standard Check Of p_commit.
     IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
     END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
               ( p_encoded => FND_API.G_TRUE,
                 p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
               );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO clearOutboxErrors_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO clearOutboxErrors_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO clearOutboxErrors_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);



end;
procedure purgeOutboxItems(p_api_version_number    IN   NUMBER,
                   p_init_msg_list         IN   VARCHAR2,
                   p_commit                IN   VARCHAR2,
                   p_rt_media_item_id_array IN  SYSTEM.IEM_RT_MSG_KEY_ARRAY,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2)

IS
  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_rt_interaction_id      NUMBER;


begin

-- Standard Start of API savepoint
        SAVEPOINT purgeOutboxErrors_pvt;

--Init values
  l_api_name               :='purgeOutboxErrors';
  l_api_version_number     :=1.0;
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

----------------------code ------------------
  if ( p_rt_media_item_id_array.COUNT > 0 ) then
    if ( p_rt_media_item_id_array(p_rt_media_item_id_array.FIRST).num = G_ALL ) then
      begin
        update iem_rt_media_items set expire = G_EXPIRE
        where rt_interaction_id in
        (select rt_interaction_id from iem_rt_interactions
         where expire = G_PROCESSING);

        update iem_rt_interactions set expire = G_EXPIRE
        where expire = G_PROCESSING;

        update iem_outbox_errors set expire = G_EXPIRE;
      end;
    else
      for i in p_rt_media_item_id_array.FIRST..p_rt_media_item_id_array.LAST loop
      begin
        select rt_interaction_id into l_rt_interaction_id
          from iem_rt_media_items
          where rt_media_item_id = p_rt_media_item_id_array(i).num;

        update iem_rt_interactions set expire = G_EXPIRE where
          rt_interaction_id = l_rt_interaction_id;

        update iem_rt_media_items set expire = G_EXPIRE where
          rt_interaction_id = l_rt_interaction_id;

        update iem_outbox_errors set expire = G_EXPIRE where
          rt_media_item_id = p_rt_media_item_id_array(i).num;
      end;
      end loop;
    end if;
  end if;
--------------------------
-- Standard Check Of p_commit.
     IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
     END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
               ( p_encoded => FND_API.G_TRUE,
                 p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
               );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO purgeOutboxErrors_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO purgeOutboxErrors_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO purgeOutboxErrors_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);

end;

procedure getOpItem(p_api_version_number   IN  NUMBER,
                   p_init_msg_list         IN  VARCHAR2,
                   p_commit                IN  VARCHAR2,
                   p_rt_media_item_id      IN  NUMBER,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2,
                   x_item_obj              OUT NOCOPY  SYSTEM.IEM_OP_ITEM
                   )
IS
  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_rt_interaction_id      NUMBER;
  l_to_resource_id         NUMBER;
  l_agent_acct_id          NUMBER;
  l_reroute_type           NUMBER;
  l_ih_status              VARCHAR2(2);
  l_email_acct_id          NUMBER;
  l_rt_media_item_id       NUMBER;

  v_resource_id            NUMBER;
  v_mdt_msg_id             NUMBER;
  v_media_id               NUMBER;
  v_create_date            VARCHAR2(80);
  v_rt_media_status        VARCHAR2(2);
  v_interaction_id         NUMBER;
  v_mcp_id                 NUMBER;
  v_rt_ih_expire           VARCHAR2(2);
  v_action                 VARCHAR2(2);
  v_outb_rt_media_item_id  NUMBER;
  v_inb_rt_media_item_id   NUMBER;
  v_master_acct_id         NUMBER;
  v_subject                VARCHAR2(128);
  v_sender                 VARCHAR2(240);
  v_master_acct_name       VARCHAR2(256);
  v_to_resource_id         NUMBER;
  v_to_master_acct_id      NUMBER;
  v_to_group_id            NUMBER;
  v_rt_interaction_id      NUMBER;
  no_post_mdts             NUMBER;



begin

-- Standard Start of API savepoint
        SAVEPOINT getOpItem_pvt;

--Init values
  l_api_name               :='getOpItem';
  l_api_version_number     :=1.0;

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

----------------------code ------------------
select rt_interaction_id, resource_id, message_id, media_id,
       to_char(creation_date, DATE_FORMAT), status
into l_rt_interaction_id, v_resource_id, v_mdt_msg_id, v_media_id,
       v_create_date, v_rt_media_status
from iem_rt_media_items where rt_media_item_id = p_rt_media_item_id;

v_rt_interaction_id := l_rt_interaction_id;

select interaction_id, mc_parameter_id, status, expire, to_resource_id
into v_interaction_id, v_mcp_id, l_ih_status, v_rt_ih_expire, l_to_resource_id
from iem_rt_interactions where rt_interaction_id = l_rt_interaction_id;

v_action := l_ih_status;

-- to_resource_id - to agent id when transfer, to group id when redirect

begin
  select rt_media_item_id into v_outb_rt_media_item_id
  from iem_rt_media_items
  where rt_interaction_id = l_rt_interaction_id and email_type='O';
exception
  when NO_DATA_FOUND then
    v_outb_rt_media_item_id := null;
end;

begin
  select rt_media_item_id into v_inb_rt_media_item_id
  from iem_rt_media_items
  where rt_interaction_id = l_rt_interaction_id and email_type='I'
  and expire <> G_DORMANT;
exception
  when NO_DATA_FOUND then
    v_inb_rt_media_item_id := null;
end;

if ( v_inb_rt_media_item_id is not null ) then
  select message_id, media_id, to_char(creation_date, DATE_FORMAT), status
  into v_mdt_msg_id, v_media_id, v_create_date, v_rt_media_status
  from iem_rt_media_items where rt_media_item_id = v_inb_rt_media_item_id;
end if;

no_post_mdts := 1;
if ( v_mdt_msg_id > 0) then
begin
  no_post_mdts := 0;
  select email_account_id, subject, from_address
  into v_master_acct_id, v_subject, v_sender
  from iem_rt_proc_emails where message_id = v_mdt_msg_id;

  select from_name into v_master_acct_name from iem_mstemail_accounts
  where email_account_id = v_master_acct_id;
end;
end if; -- mdt_msg_id > 0

if ( no_post_mdts = 1 ) then

  if (v_inb_rt_media_item_id is not null) then
    l_rt_media_item_id := v_inb_rt_media_item_id;
  elsif (v_outb_rt_media_item_id is not null) then
    l_rt_media_item_id := v_outb_rt_media_item_id;
  end if;

  select email_account_id, agent_account_id
  into l_email_acct_id, l_agent_acct_id
  from iem_rt_media_items where rt_media_item_id = l_rt_media_item_id;

  if (l_email_acct_id > 0) then
    select from_name into v_master_acct_name from iem_mstemail_accounts
    where email_account_id = l_email_acct_id;
    v_master_acct_id := l_email_acct_id;

  elsif ( l_agent_acct_id > 0) then
    select a.from_name, a.email_account_id
    into v_master_acct_name, v_master_acct_id
    from iem_mstemail_accounts a, iem_agents b
    where a.email_account_id = b.email_account_id
    and b.agent_id = l_agent_acct_id;
  end if;

end if;


if ( l_ih_status = 'T' or l_ih_status = 'H' or l_ih_status = 'E' ) then  -- transfer
  select agent_account_id, resource_id into l_agent_acct_id, v_to_resource_id
  from iem_rt_media_items
  where media_id = v_media_id and rt_media_item_id <> p_rt_media_item_id
  and    expire <> G_EXPIRE
  and    rownum < 2;

  select email_account_id into v_to_master_acct_id from iem_agents
  where agent_id = l_agent_acct_id;
end if;

if ( l_ih_status = 'X' ) then
  select email_account_id, db_server_id
  into v_to_master_acct_id, l_reroute_type
  from iem_rt_media_items
  where rt_interaction_id = l_rt_interaction_id
  and status = G_NEWREROUTE and expire = G_DORMANT;

  if (l_reroute_type = 76) AND (l_to_resource_id > 0) then
    v_to_group_id := l_to_resource_id;
  end if;

end if;

if ( l_ih_status = 'R' ) then  -- redirect
  v_to_master_acct_id := l_to_resource_id;
end if;

x_item_obj := SYSTEM.IEM_OP_ITEM(v_inb_rt_media_item_id,
          v_outb_rt_media_item_id,
          v_mdt_msg_id,
          v_rt_interaction_id,
          v_interaction_id,
          v_media_id,
          v_mcp_id,
          v_resource_id,
          v_master_acct_id,
          v_to_master_acct_id,
          v_to_resource_id,
          v_to_group_id,
          v_rt_ih_expire,
          v_rt_media_status,
          v_create_date,
          v_sender,
          v_subject,
          v_action,
          v_master_acct_name);


--------------------------
-- Standard Check Of p_commit.
     IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
     END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
               ( p_encoded => FND_API.G_TRUE,
                 p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
               );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO getOpItem_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO getOpItem_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO getOpItem_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);

end;

/*
procedure getThreadStatus(p_api_version_number   IN  NUMBER,
                   p_init_msg_list         IN  VARCHAR2,
                   p_commit                IN  VARCHAR2,
                   p_thread_type           IN  NUMBER, -- 0 for Failed, 1 for Normal
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2,
                   x_thread_array          OUT NOCOPY  IEM_OP_THREAD_ARRAY
                   )
IS
  l_api_name               VARCHAR2(255):='getThreadStatus';
  l_api_version_number     NUMBER:=1.0;
  l_con_id                 NUMBER;
  l_jserv_id               NUMBER;
  l_jserv_post             NUMBER;
  l_host                   VARCHAR2(200);
  l_apache_port            NUMBER;
  l_con_start              VARCHAR2(80);
  l_con_update             VARCHAR2(80);
  l_con_fail               VARCHAR2(200);
  l_th_con_id              NUMBER;
  l_th_id                  VARCHAR2(80);
  l_th_start               VARCHAR2(80);
  l_msg_count              NUMBER;
  l_th_type                VARCHAR2(1);
  l_th_update              VARCHAR2(80);
  l_th_fail                VARCHAR2(200);

begin

-- Standard Start of API savepoint
        SAVEPOINT getThreadStatus_pvt;

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

----------------------code ------------------

select a.CONTROLLER_ID, a.JSERV_ID, a.JSERV_PORT,
       a.APACHE_HOST, a.APACHE_PORT, to_char(a.START_TIME, DATE_FORMAT),
       to_char(a.LAST_UPDATE_DATE, DATE_FORMAT), a.FAILED_REASON
into l_con_id, l_jserv_id, l_jserv_post, l_host, l_apache_port,
     l_con_start, l_con_update, l_con_fail
from IEM_OP_CONTROLLER_STATS a order by APACHE_HOST, CONTROLLER_ID desc

select b.CONTROLLER_ID, b.THREAD_ID, b.PROCESSED_MSG_COUNT,
       b.THREAD_TYPE, to_char(b.START_TIME, DATE_FORMAT),
       to_char(b.LAST_UPDATE_DATE, DATE_FORMAT), b.FAILED_REASON
into l_th_con_id, l_th_id, l_th_start, l_msg_count, l_th_type,
     l_th_update, l_th_fail
from IEM_OP_THREAD_STATS b, IEM_OP_CONTROLLER_STATS a
where a.CONTROLLER_ID = b.CONTROLLER_ID
order by a.APACHE_HOST, a.CONTROLLER_ID desc, b.THREAD_TYPE desc



--------------------------
-- Standard Check Of p_commit.
     IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
     END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
               ( p_encoded => FND_API.G_TRUE,
                 p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
               );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO getThreadStatus_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO getThreadStatus_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO getThreadStatus_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);


end;
*/


procedure pushbackToRework(p_api_version_number   IN  NUMBER,
                   p_init_msg_list         IN  VARCHAR2,
                   p_commit                IN  VARCHAR2,
                   p_rt_media_item_ids     IN  SYSTEM.IEM_RT_MSG_KEY_ARRAY,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2
                   )
IS
  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_rt_interaction_id      NUMBER;
  l_message_id             NUMBER;
  l_mcp_action             VARCHAR2(20);
  l_inb_media_id           NUMBER;
  l_interaction_id         NUMBER;
  l_customer_id            NUMBER;
  l_contact_id             NUMBER;
  l_relationship_id        NUMBER;
  l_status                 VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);
  l_mcp_id                 NUMBER;

  IEM_MDT_PROC_EX         EXCEPTION;
begin

-- Standard Start of API savepoint
   SAVEPOINT pushbackToRework_pvt;

-- Init values
  l_api_name               :='pushbackToRework';
  l_api_version_number     :=1.0;

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

----------------------code ------------------
for i in p_rt_media_item_ids.first..p_rt_media_item_ids.last loop

  select rt_interaction_id into l_rt_interaction_id
  from iem_rt_media_items
  where rt_media_item_id = p_rt_media_item_ids(i).num;

  select rti.mc_parameter_id, rti.interaction_id, rti.customer_id, rti.contact_id, rti.relationship_id
  into l_mcp_id, l_interaction_id, l_customer_id, l_contact_id, l_relationship_id
  from iem_rt_interactions rti
  where rti.rt_interaction_id = l_rt_interaction_id;

  l_mcp_action := null;
  if ( l_mcp_id > 0 ) then
    select mcp.action into l_mcp_action
    from iem_mc_parameters mcp
    where mcp.mc_parameter_id = l_mcp_id;
  end if;

  -- For auto-reply failed messages, reprocess the messages
  -- and push them back to queues.
  if (l_mcp_action = 'autoreply') then

    select media_id
    into l_inb_media_id
    from iem_rt_media_items
    where rt_interaction_id = l_rt_interaction_id
    and email_type = 'I';

    IEM_EMAIL_PROC_PVT. ReprocessAutoreply(
                      p_api_version_number    => 1.0,
                      p_init_msg_list  => FND_API.G_FALSE,
                      p_commit   => FND_API.G_FALSE,
                      p_media_id => l_inb_media_id,
                      p_interaction_id => l_interaction_id,
                      p_customer_id => l_customer_id,
                      p_contact_id => l_contact_id,
		      p_relationship_id => l_relationship_id,
                      x_return_status  => l_status,
                      x_msg_count    => l_msg_count,
                      x_msg_data => l_msg_data);

    if ( l_status = FND_API.G_RET_STS_ERROR ) then
       raise IEM_MDT_PROC_EX;
    end if;

    update iem_rt_media_items set expire = G_EXPIRE
    where rt_interaction_id = l_rt_interaction_id;

    update iem_rt_interactions set expire = G_EXPIRE
    where rt_interaction_id = l_rt_interaction_id;

    update iem_outbox_errors set expire = G_EXPIRE
    where rt_media_item_id in
    (select rt_media_item_id from iem_rt_media_items
    where rt_interaction_id = l_rt_interaction_id);

  else

    select message_id into l_message_id
    from iem_rt_media_items
    where rt_media_item_id = p_rt_media_item_ids(i).num and email_type = 'I';

    update iem_rt_media_items set expire = G_ACTIVE, status = 'U'
    where rt_interaction_id = l_rt_interaction_id and expire <> 'D';

    if ( l_message_id > 0 ) then
      update iem_rt_media_items set expire = G_EXPIRE
      where message_id = l_message_id and expire = 'D';
    end if;

    update iem_rt_interactions set expire = G_ACTIVE
    where rt_interaction_id = l_rt_interaction_id;

    if ( l_message_id > 0 ) then
      update iem_rt_proc_emails set queue_status = null
      where message_id = l_message_id;
    end if;

    update iem_outbox_errors set expire = G_EXPIRE
    where rt_media_item_id in
    (select rt_media_item_id from iem_rt_media_items
    where rt_interaction_id = l_rt_interaction_id);

  end if; -- message not auto-replied
end loop;

--------------------------
-- Standard Check Of p_commit.
     IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
     END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
               ( p_encoded => FND_API.G_TRUE,
                 p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
               );
EXCEPTION
   WHEN IEM_MDT_PROC_EX THEN
        ROLLBACK TO pushbackToRework_pvt;
	      x_return_status := l_status;
	   FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
              p_count => x_msg_count,
              p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO pushbackToRework_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO pushbackToRework_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO pushbackToRework_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);


end;

end IEM_OP_ADMIN_PUB;

/
