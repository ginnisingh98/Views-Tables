--------------------------------------------------------
--  DDL for Package Body AMS_LISTGENERATION_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTGENERATION_UTIL_PKG" AS
/* $Header: amsvlgub.pls 120.6 2006/02/23 01:36:26 bmuthukr noship $*/

G_PKG_NAME    CONSTANT VARCHAR2(30):='AMS_LIST_UTIL_PKG';
G_FILE_NAME   CONSTANT VARCHAR2(12):='amsvlgub.pls';

g_remote_gen       VARCHAR2(1) := 'N';
g_remote_gen_list   VARCHAR2(1) := 'N';
g_database_link     VARCHAR2(128);

cancelexcep exception;

/* This is the only procedure called in this package.
 * Which in turn calls the rest. However, the function getWFItemStatus is called
 * elsewhere.
 *
 *
 */

PROCEDURE cancel_list_gen(p_list_header_id in NUMBER,
			  p_remote_gen in VARCHAR2,
			  p_remote_gen_list in VARCHAR2,
			  p_database_link in VARCHAR2,
			  x_msg_count OUT NOCOPY NUMBER,
			  x_msg_data OUT NOCOPY VARCHAR2,
			  x_return_status OUT NOCOPY VARCHAR2)
IS
  l_msg_count   NUMBER ;
  l_msg_data    VARCHAR2(2000);
  l_return_status    VARCHAR2(10);
  l_error_position   varchar2(100);
--  l_listheader_rec   ams_listheader_pvt.list_header_rec_type;
  l_total_recs    number;

  l_status_code   varchar2(100);
--  cancel_list_gen Exception ;

Begin

  l_error_position := '<- Start Cancel List Generation ->';

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  AMS_LISTGENERATION_PKG.write_to_act_log(p_msg_data => 'Canceling List Generation',
            p_arc_log_used_by => 'LIST',
            p_log_used_by_id  => p_list_header_id,
            p_level => 'HIGH');

  g_remote_gen := p_remote_gen; -- 'Y' ==> remote data source
  g_remote_gen_list := p_remote_gen_list; -- 'Y' ==> generate remotely
  g_database_link := p_database_link;

--  Get status for list = Listheaderid;
  open get_status_code(p_list_header_id);
  fetch get_status_code into l_status_code;
  close get_status_code;

  AMS_LISTGENERATION_PKG.write_to_act_log(p_msg_data => 'In cancel List gen, Status code: '|| l_status_code,
            p_arc_log_used_by => 'LIST',
            p_log_used_by_id  => p_list_header_id,
            p_level => 'HIGH');

--  l_status_code := 'FAILED';

  If (l_status_code = 'FAILED') -- This is changing in R12
  then

  /* for now calling delete procedure in the Generation package because this
is what is needed here. Later that Procedure can be migrated here. */

  AMS_LISTGENERATION_PKG.write_to_act_log(p_msg_data => 'Before delete in Cancel List Gen'|| l_status_code,
         p_arc_log_used_by => 'LIST',
         p_log_used_by_id  => p_list_header_id,
         p_level => 'LOW');

    delete_list_entries(p_list_header_id, x_msg_count, x_msg_data, x_return_status);

  AMS_LISTGENERATION_PKG.write_to_act_log(p_msg_data => 'After delete in Cancel List Gen'|| l_status_code,
         p_arc_log_used_by => 'LIST',
         p_log_used_by_id  => p_list_header_id,
         p_level => 'HIGH');

    if x_return_status <> FND_API.g_ret_sts_success then
       AMS_LISTGENERATION_PKG.write_to_act_log('Error while executing delete_list_entries. Unable to delete entries.', 'LIST', p_list_header_id,'HIGH');
--       raise FND_API.g_exc_unexpected_error;
    end if;

  AMS_LISTGENERATION_PKG.write_to_act_log(p_msg_data => 'Updating list header info '|| l_status_code,
         p_arc_log_used_by => 'LIST',
         p_log_used_by_id  => p_list_header_id,
         p_level => 'LOW');

	Update_List_Header (p_list_header_id, x_return_status);

  AMS_LISTGENERATION_PKG.write_to_act_log(p_msg_data => 'List header info updated '|| l_status_code,
         p_arc_log_used_by => 'LIST',
         p_log_used_by_id  => p_list_header_id,
         p_level => 'LOW');

	if x_return_status <> FND_API.g_ret_sts_success then
	  AMS_LISTGENERATION_PKG.write_to_act_log('Error while executing UpdateListHeader. Unable to update List header.', 'LIST', p_list_header_id,'HIGH');
        end if;

	Commit;

	Raise cancelexcep;

  else

  AMS_LISTGENERATION_PKG.write_to_act_log(p_msg_data => 'Cancel List Gen: Status code is not FAILED so exiting. Status code is '||x_return_Status,
         p_arc_log_used_by => 'LIST',
         p_log_used_by_id  => p_list_header_id,
         p_level => 'LOW');

	return;
  end if;

Exception
/*
    WHEN FND_API.g_exc_unexpected_error THEN
     AMS_LISTGENERATION_PKG.write_to_act_log('Error while executing procedure cancel_list_gen '||sqlcode||'  '||sqlerrm, 'LIST', p_list_header_id,'HIGH');
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
*/

  --WHEN cancelListGen then
  WHEN cancelexcep then

     AMS_LISTGENERATION_PKG.write_to_act_log('In procedure cancel_list_gen: User termination detected '||sqlcode||'  '||sqlerrm, 'LIST', p_list_header_id, 'HIGH');
     x_return_status := FND_API.g_ret_sts_unexp_error ;
	Raise cancelListGen;

    WHEN OTHERS THEN
     AMS_LISTGENERATION_PKG.write_to_act_log('Error while executing procedure cancel_list_gen '||sqlcode||'  '||sqlerrm, 'LIST', p_list_header_id, 'HIGH');
     x_return_status := FND_API.g_ret_sts_unexp_error ;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	FND_MSG_PUB.add_exc_msg(g_pkg_name, g_file_name);
     END IF;

     FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
	);

End cancel_list_gen;

Procedure Delete_List_entries(p_list_header_id in NUMBER,
		x_msg_count OUT NOCOPY NUMBER,
		x_msg_data OUT NOCOPY VARCHAR2,
		x_return_status out nocopy VARCHAR2)
is
 -- l_gen_type	VARCHAR2(200);
l_delete_action varchar2(80);
l_total_recs	number;
l_null		varchar2(30) := null;
l_gen_type	VARCHAR2(20);

Begin

   AMS_LISTGENERATION_PKG.write_to_act_log('Executing delete_list_entries in listcancelgen.', 'LIST', p_list_header_id,'LOW');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

--    If p_listheader_rec.list_type = 'TARGET'
   select generation_type into l_gen_type
   from ams_list_headers_all
   where list_header_id = p_list_header_id;

--   If p_listheader_rec.generation_type = 'STANDARD' then
   If l_gen_type = 'STANDARD' then

	DELETE FROM ams_list_entries
	WHERE list_header_id = p_list_header_id;

	AMS_LISTGENERATION_PKG.write_to_act_log(sql%rowcount||' entries deleted from ams_list_entries in local instance.', 'LIST', p_list_header_id,'LOW');

	If g_remote_gen = 'Y' -- based on remote DS so delete remotely
	then
	   AMS_LISTGENERATION_PKG.write_to_act_log('Calling remote procedure with process type as DELETE_LIST_ENTRIES to delete entries in remote instance', 'LIST', p_list_header_id,'LOW');
	   execute immediate
           'BEGIN AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
      ' END;'
            using  '1',
             l_null,
             'T',
             l_null,
             OUT x_return_status,
             OUT x_msg_count,
             OUT x_msg_data,
             p_list_header_id,
             l_null,
             l_null,
             OUT l_total_recs,
             'DELETE_LIST_ENTRIES';
	  if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
             AMS_LISTGENERATION_PKG.write_to_act_log('Error in executing remote procedure', 'LIST', p_list_header_id,'HIGH');
             AMS_LISTGENERATION_PKG.write_to_act_log('Error '||x_msg_data , 'LIST', p_list_header_id,'HIGH');
          else
             AMS_LISTGENERATION_PKG.write_to_act_log('Entries deleted succesfully in remote instance','LIST', p_list_header_id,'LOW');
          end if;
	end if; --g_remote_gen = 'Y'
    End if; -- STANDARD

    AMS_LISTGENERATION_PKG.write_to_act_log('Deleting entries from list src type usages tables.', 'LIST', p_list_header_id,'LOW');

    DELETE FROM ams_list_src_type_usages
    WHERE list_header_id = p_list_header_id;

    AMS_LISTGENERATION_PKG.write_to_act_log('Procedure delete_list_entries executed successfully.', 'LIST', p_list_header_id,'LOW');

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    AMS_LISTGENERATION_PKG.write_to_act_log(p_msg_data => 'Error Deleting in CancelListGen',
            p_arc_log_used_by => 'LIST',
            p_log_used_by_id  => p_list_header_id,
            p_level => 'HIGH');
    FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('TEXT', 'Delete List Entries ' || l_delete_action || ' '|| SQLERRM||' '||SQLCODE);
    FND_MSG_PUB.Add;

End Delete_list_entries;

Procedure Update_list_header(p_list_header_id in Number,
--			     x_msg_count IN NUMBER,
--                             x_msg_data IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2)
AS
Begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
  If g_remote_gen = 'Y'
   Currently, I don't see the remote list header table getting updated.
  Endif
*/

 update ams_list_headers_all
     set --WORKFLOW_ITEM_KEY  = NULL,
	status_code      = 'DRAFT',
	ctrl_status_code = 'DRAFT',
	user_status_id   = 311,
	last_update_date = sysdate,
	status_date      = sysdate,
	NO_OF_ROWS_DUPLICATES = null,
	NO_OF_ROWS_MIN_REQUESTED = null,
	NO_OF_ROWS_MAX_REQUESTED = null,
	NO_OF_ROWS_IN_LIST = null,
	NO_OF_ROWS_IN_CTRL_GROUP = null,
	NO_OF_ROWS_ACTIVE = null,
	NO_OF_ROWS_INACTIVE = null,
	NO_OF_ROWS_MANUALLY_ENTERED = null,
	NO_OF_ROWS_DO_NOT_CALL  = null,
	NO_OF_ROWS_DO_NOT_MAIL  = null,
	NO_OF_ROWS_RANDOM = null
    where list_header_id = p_list_header_id;

Exception
    When Others then

     AMS_LISTGENERATION_PKG.write_to_act_log('Error while executing procedure Update_list_header '||sqlcode||'  '||sqlerrm, 'LIST', p_list_header_id,'HIGH');

	x_return_status := FND_API.g_ret_sts_unexp_error ;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, g_file_name);
     END IF;
/*
     FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
*/
End Update_list_header;

Function getWFItemStatus(p_list_header_id in Number) return VARCHAR2
IS

 l_item_type	CONSTANT VARCHAR2(20) :='AMSLISTG';
 l_item_key	NUMBER;
 l_status 	VARCHAR2(20);
 l_result 	VARCHAR2(1000);

cursor wf_item_key(p_list_header_id NUMBER) IS
select workflow_item_key
from ams_list_headers_all
where list_header_id = p_list_header_id;

Begin
  -- Get the work flow item key
  open wf_item_key(p_list_header_id);
  fetch wf_item_key into l_item_key;
  close wf_item_key;

  if wf_item_key%Notfound then
    return null;
  elsif l_item_key = null then
    return null;
  end if;

  WF_Engine.ItemStatus(l_item_type, l_item_key, l_status, l_result);
  return l_status;

Exception
  When others then
    AMS_LISTGENERATION_PKG.write_to_act_log('Error getting ItemStatus. ItemKey = '||l_item_key||' and Status = '|| l_status,'LIST', p_list_header_id, 'HIGH');

End getWFItemStatus;

Function isListCancelling(p_list_header_id in Number) return VARCHAR2
IS
  l_status_code   varchar2(100);
Begin

  open get_status_code(p_list_header_id);
  fetch get_status_code into l_status_code;
  close get_status_code;

  IF (l_status_code='FAILED') AND (getWFItemStatus(p_list_header_id) = 'ACTIVE')
  THEN
    return 'Y';
  ELSE
    return 'N';
  END IF;

Exception

 When others then
    AMS_LISTGENERATION_PKG.write_to_act_log('Error getting status code = '|| l_status_code, 'LIST', p_list_header_id, 'HIGH');
    return 'N';
End isListCancelling;

PROCEDURE START_CTRL_GRP_PROCESS
             (p_list_header_id  in  number) is

l_request_id    number :=NULL;
X_CTRL_STATUS VARCHAR2(200);
l_log_level varchar2(200);

cursor c_count_entries is
select sum(decode(enabled_flag,'N',0,1)),
       sum(decode(enabled_flag,'Y',0,1)),
       sum(1),
       sum(decode(part_of_control_group_flag,'Y',1,0))
from ams_list_entries
where list_header_id = p_list_header_id ;

cursor c_list_header_info is
select list_type, ctrl_gen_mode
  from ams_list_headers_all
 where list_header_id = p_list_header_id;

l_no_of_rows_in_list            number;
l_no_of_rows_active             number;
l_no_of_rows_inactive           number;
l_no_of_rows_in_ctrl_group      number;

l_list_header_info_rec  c_list_header_info%rowtype;

X_RETURN_STATUS VARCHAR2(1);
X_MSG_COUNT NUMBER;
X_MSG_DATA VARCHAR2(200);
x_msg_data1 varchar2(200);

BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   open c_list_header_info;
   fetch c_list_header_info into l_list_header_info_rec;
   close c_list_header_info;

   if l_list_header_info_rec.list_type <> 'TARGET' then
        return;
   end if;

   --select decode(p_log_flag,'Y','HIGH','LOW') into l_log_level from dual;

   l_request_id := FND_REQUEST.SUBMIT_REQUEST(
			application => 'AMS',
			program     => 'AMSCGSP',
			argument1   => p_LIST_HEADER_id);

   update ams_list_headers_all
      set ctrl_conc_job_id = l_request_id,
          last_update_date = sysdate
    where list_header_id = p_list_header_id;
   commit;


exception
   when others then
     update ams_list_headers_all
        set ctrl_status_code = 'FAILED',
            status_code = status_code_old,
	    status_code_old = null,
            last_update_date = sysdate,
   	    user_status_id = 303
      where list_header_id = p_list_header_id;
     commit;
END START_CTRL_GRP_PROCESS;

PROCEDURE CANCEL_CTRL_GRP_PROCESS
             (p_list_header_id  in  number) IS

cursor c1 is
select ctrl_conc_job_id,status_code_old,status_code
  from ams_list_headers_all
 where list_header_id = p_list_header_id;

cursor c_user_status(p_status_code in varchar2) is
select user_status_id
  from ams_user_statuses_vl
 where system_status_code = p_status_code
  and system_status_type = 'AMS_LIST_STATUS';

l_request_id      number := 0;
l_status_code_old varchar2(100);
l_old_status_id   number;
l_msg_text        varchar2(1000);
l_cancel_status   boolean;
l_status_code     varchar2(100);

BEGIN
   -- Initialize API return status to SUCCESS
   --x_return_status := FND_API.G_RET_STS_SUCCESS;

   open c1;
   fetch c1 into l_request_id,l_status_code_old,l_status_code;
   close c1;

   if l_status_code_old is not null then
      open c_user_status(l_status_code_old);
      fetch c_user_status into l_old_status_id;
      close c_user_status;
   else
      open c_user_status(l_status_code);
      fetch c_user_status into l_old_status_id;
      close c_user_status;
   end if;

   l_cancel_status := fnd_concurrent.cancel_request(l_request_id,l_msg_text);

   update ams_list_headers_all
      set ctrl_status_code = 'DRAFT',
          status_code = nvl(status_code_old,status_code),
          last_update_date = sysdate,
	  user_status_id = l_old_status_id
    where list_header_id = p_list_header_id;

    commit;


exception
   when others then
        null;
END CANCEL_CTRL_GRP_PROCESS;

--Procedure added by bmuthukr for CR#4886329
procedure get_split_preview_count(p_split_preview_count_tbl IN OUT NOCOPY AMS_LISTGENERATION_UTIL_PKG.split_preview_count_tbl%type,
                                  p_list_header_id          IN NUMBER,
                                  x_return_status           OUT NOCOPY VARCHAR2,
                                  x_msg_count               OUT NOCOPY NUMBER,
                                  x_msg_data                OUT NOCOPY VARCHAR2) is



cursor c_remote_list is
select nvl(stypes.remote_flag,'N') ,database_link
  from ams_list_src_types stypes, ams_list_headers_all list
 where list.list_source_type = stypes.source_type_code
   and list_header_id  =  p_list_header_id;

l_remote_flag  varchar2(1) := 'N';
l_db_link      varchar2(100) := null;
l_cnt          number;
remote_exp     exception;

begin

   open c_remote_list;
   fetch c_remote_list into l_remote_flag, l_db_link;
   close c_remote_list;

   for i in 1..p_split_preview_count_tbl.count
   loop
      p_split_preview_count_tbl(i).sp_query := 'SELECT count(1) '||substr(p_split_preview_count_tbl(i).sp_query,instr(upper(p_split_preview_count_tbl(i).sp_query), ' FROM '));
      if nvl(l_remote_flag,'N') = 'N' then
         execute immediate p_split_preview_count_tbl(i).sp_query INTO l_cnt;
      else --need to execute the sql in remote instance.
         execute immediate
            'begin
               ams_remote_listgen_pkg.remote_get_count'||'@'||l_db_link||'(:1,:2,:3,:4,:5)'||';'||
            ' end;'
            using p_split_preview_count_tbl(i).sp_query,
            out l_cnt,
            out x_msg_count,
            out x_msg_data,
            out x_return_status;
         if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
            raise remote_exp;
         end if;
      end if;
      p_split_preview_count_tbl(i).prv_count := l_cnt;
   end loop;
exception
   when remote_exp then
      x_msg_count := 1;
      x_return_status := 'E';
      x_msg_data := 'Error while executing the sql in remote schema '||x_msg_data;
   when others then
      x_msg_count := 1;
      x_return_status := 'E';
      x_msg_data := sqlcode||'   '||sqlerrm;
end get_split_preview_count;

END AMS_LISTGENERATION_UTIL_PKG;

/
