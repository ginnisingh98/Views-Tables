--------------------------------------------------------
--  DDL for Package Body AMS_LISTGENERATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTGENERATION_PKG" as
/* $Header: amsvlgnb.pls 120.33.12010000.3 2009/07/27 05:47:18 hbandi ship $ */
-- Start of Comments
-- NAME
--   AMS_LISTGENERATION
-- PURPOSE
--   This package performs the generation of all oracle marketing defined lists.
-------------------------------------------------------------------------------
-- NOTES
--
-- HISTORY
--   06/21/1999 tdonohoe created
--   07/07/2000 tdonohoe modified Validate_SQL to fix BUG 1349322.
--   07/26/2000 tdonohoe added code to get all list entry data when
--                       deduplication of a list is requested.
--                       this occurs before the call to random_generation.
--   10/4/2000  vbhandar modified to fix bug 1420272
--   11/8/2000  gjoby    modified to fix bug 1482180
--                       Performance bug Used bind variables and Modified where
--                       clause in sub query to eliminate additional conditions
--   21/1/2001  gjoby    Recreated for hornet release
--   03/09/2005 sthattil Got rid of unwanted code with Balaji
--   05/23/2005 sthattil changes for list generation cancel
--   07/11/2005 ryedator Modified process_list_actions to select 'include'
--			 selections by rank number - bug 4443619
--   08/17/2005	bmuthukr With more R12 changes.
--   08/13/2007 AMLAL    Bug#6338292 : Truncated the Input parameters passed for
--                                     list generation.
-- End of Comments


G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_LISTGENERATION_PKG';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amslsgnb.pls';

G_MAX_SQL_STR_LEN  CONSTANT NUMBER := 2000;
G_MAX_STRING_LEN   CONSTANT NUMBER := 32767;
G_OVERFLOW_AMOUNT  CONSTANT NUMBER := 100;
--g_count             NUMBER := 1;
/*
g_message_table  sql_string;
g_message_table_null  sql_string;
*/
--g_message_table  sql_string_4K;
--g_message_table_null  sql_string_4K;
--g_date           t_date;

g_remote_list		VARCHAR2(1) := 'N';



g_reqd_num_tbl                  t_number;
g_act_num_tbl                   t_number;
g_no_of_rows_ini_selected  number :=0;

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
------------------------------------------------------------------
--This Variable stores the primary key of the list header.      --
------------------------------------------------------------------
g_list_header_id         ams_list_headers_all.list_header_id%type;
----------------------------------------------------------------------------

cursor g_initial_count is
select count(1)
  from ams_list_entries
 where list_header_id = g_list_header_id
   and enabled_flag = 'Y';

PROCEDURE logger is
--  This procedure was written to replace Autonomous Transactions
--
 l_return_status VARCHAR2(1);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT logger_save;
--  g_message_table(g_count) := 'Calling logger';
--  g_count := g_count +1;
  -- Not reqd since we are not storing it in pl/sql table anymore.
  /*
  FORALL I in g_message_table.first .. g_message_table.last
      INSERT INTO ams_act_logs(
         activity_log_id
         ,last_update_date
         ,last_updated_by
         ,creation_date
         ,created_by
         ,last_update_login
         ,object_version_number
         ,act_log_used_by_id
         ,arc_act_log_used_by
         ,log_transaction_id
         ,log_message_text
      )
      VALUES (
         ams_act_logs_s.NEXTVAL
         ,g_date(i)
         ,FND_GLOBAL.User_Id
         ,g_date(i)
         ,FND_GLOBAL.User_Id
         ,FND_GLOBAL.Conc_Login_Id
         ,1
         ,g_list_header_id
         ,'LIST'
         ,ams_act_logs_transaction_id_s.NEXTVAL
         ,g_message_table(i)
      ) ;*/
     commit;
exception
   -- Logger has failed
   when others then
      null;
END logger;

--Procedure to identify the message log level for this user(list owner).
-- Will be called from generate_list and generate_target_group_list_old.

PROCEDURE find_log_level(p_list_header_id number) is
l_debug_prof_level   number := -1;

cursor c_get_user_id(l_list_header_id number) is
select jtf.user_id
  from jtf_rs_resource_extns jtf, ams_list_headers_all hd
 where jtf.resource_id = hd.owner_user_id
   and hd.list_header_id = l_list_header_id;

begin
   open c_get_user_id(p_list_header_id);
   fetch c_get_user_id into g_user_id;
   close c_get_user_id;

   delete from ams_act_logs
    where arc_act_log_used_by = 'LIST'
      and act_log_used_by_id  = p_list_header_id ;

   g_list_header_id := p_list_header_id;
   g_message_table  := g_message_table_null ;
   g_count := 0;
   g_log_level := null;

   --Will take the value of the profile "FND: Message Level Threshold" for the list owner.
   l_debug_prof_level := fnd_profile.value_specific(name => 'FND_AS_MSG_LEVEL_THRESHOLD',
                                                    user_id =>  g_user_id);
   if nvl(l_debug_prof_level,-1) = 10  then --Profile set to Debug Low. All the messages will be logged.
      g_log_level := 'LOW';
      write_to_act_log('All the debug messages will be logged. To view only critical messages set the profile (at user level) FND: Message Level Threshold to a value other than Debug Low',
                       'LIST',
		       g_list_header_id,
		       'HIGH');
      --g_message_table(g_count) := 'All the debug messages will be logged. To view only critical messages set the profile (at user level) FND: Message Level Threshold to a value other than Debug Low';
   else --Only messages with HIGH severity will be logged.
      g_log_level := 'HIGH';
      write_to_act_log('Only messages with high severity will be logged. To view all the messages set the profile (at user level) FND: Message Level Threshold to Debug Low',
                       'LIST',
		       g_list_header_id,
		       'HIGH');
      --g_message_table(g_count) := 'Only messages with high severity will be logged. To view all the messages set the profile (at user level) FND: Message Level Threshold to Debug Low';
   end if;
   g_date(g_count) := sysdate;
   g_count   := g_count + 1;
exception
   when others then
      null;
END find_log_level;

-- Start of Comments
-- NAME ---   WRITE_TO_ACT_LOG
-- PURPOSE
--     writes to the Ams_Act_Logs table.
-- NOTES
-- HISTORY
--   08/02/1999        tdonohoe            created
--                     gjoby    Commented out  ams_utility_pvt part
--                              Autonomous trans fails in distributed trans
-- End of Comments
----------------------------------------------------------------------------

PROCEDURE WRITE_TO_ACT_LOG(p_msg_data in VARCHAR2,
                           p_arc_log_used_by in VARCHAR2,
                           p_log_used_by_id in number,
			   p_level          in varchar2 := 'LOW')
                           IS
 --PRAGMA AUTONOMOUS_TRANSACTION;
 l_return_status VARCHAR2(1);

BEGIN
   if nvl(g_log_level,'HIGH') = 'HIGH' and p_level = 'LOW' then
      return;
   end if;

   INSERT INTO ams_act_logs(
         activity_log_id
         ,last_update_date
         ,last_updated_by
         ,creation_date
         ,created_by
         ,last_update_login
         ,object_version_number
         ,act_log_used_by_id
         ,arc_act_log_used_by
         ,log_transaction_id
         ,log_message_text
      )
   VALUES (
         ams_act_logs_s.NEXTVAL
         ,sysdate
         ,FND_GLOBAL.User_Id
         ,sysdate
         ,FND_GLOBAL.User_Id
         ,FND_GLOBAL.Conc_Login_Id
         ,1
         ,nvl(p_log_used_by_id,g_list_header_id)
         ,'LIST'
         ,ams_act_logs_transaction_id_s.NEXTVAL
         ,p_msg_data
      ) ;
     commit;

--   g_message_table(g_count) := p_msg_data;
--   g_date(g_count) := sysdate;
--   g_count   := g_count + 1;

   fnd_file.put(1,substr(p_msg_data,1,255));
   fnd_file.new_line(1,1);

/*
  AMS_UTILITY_PVT.CREATE_LOG(
                             x_return_status    => l_return_status,
                             p_arc_log_used_by  => 'LIST',
                             p_log_used_by_id   => g_list_header_id,
                             p_msg_data         => p_msg_data);
*/
-- logger;
--  COMMIT;
END WRITE_TO_ACT_LOG;

PROCEDURE get_count(p_list_select_action_id in number,
                    p_order_number in number,
		    p_incl_type in varchar2 default 'OTHERS',
		    p_sql_string in varchar2 default null) is

l_no_of_rows_in_list  number := 0;
l_sql_string      varchar2(32767) := p_sql_string;
l_str_len         number := 0;
l_position        number := 0;
l_rep_str         varchar2(32767) := 'SELECT COUNT(1) FROM ';

l_replaced_str    varchar2(32767);
l_cnt_string      varchar2(32767);
l_cnt		  number := 0;
l_cnt1		  number := 0;
l_dist_pct        number := 0;
l_no_of_rows_reqd number := 0;
l_incl_object_id  number := 0;
l_import_type     varchar2(100) := null;
l_selection_cnt   number := 0;
l_gen_type        varchar2(100) := null;
x_msg_count       number;
x_msg_data        varchar2(1000);
x_return_status   varchar2(1);


cursor c_gen_type is
select generation_type
  from ams_list_headers_all
 where list_header_id = g_list_header_id;

cursor c_no_of_rows_reqd is
select distribution_pct,incl_object_id
  from ams_list_select_actions
 where list_select_action_id = p_list_select_action_id;

cursor c_no_of_rows_in_list is
select no_of_rows_active
  from ams_list_headers_all
 where list_header_id = l_incl_object_id;

cursor c_import_type is
select decode(import_type,'B2C','PERSON_LIST','ORGANIZATION_CONTACT_LIST')
  from ams_imp_list_headers_all
 where import_list_header_id = l_incl_object_id;

cursor c_no_of_rows_in_b2b_list is
select count(1)
  from ams_hz_b2b_mapping_v
 where import_list_header_id = l_incl_object_id
   and enabled_flag = 'Y';

cursor c_no_of_rows_in_b2c_list is
select count(1)
  from ams_hz_b2c_mapping_v
 where import_list_header_id = l_incl_object_id
   and enabled_flag = 'Y';

cursor c_get_cnt_from_sel is
select count(1)
  from ams_list_entries
 where list_header_id = g_list_header_id
   and list_select_action_id = p_list_select_action_id;

begin
   open c_no_of_rows_reqd;
   fetch c_no_of_rows_reqd into l_dist_pct,l_incl_object_id;
   close c_no_of_rows_reqd;

   write_to_act_log('Executing procedure get_count','LIST',g_list_header_id,'HIGH');
   write_to_act_log('Included object id is '||l_incl_object_id,'LIST',g_list_header_id,'LOW');

   if nvl(l_dist_pct,100) = 100 then
      write_to_act_log('All the rows will be taken from this selection','LIST',g_list_header_id,'HIGH');
      g_act_num_tbl(p_order_number)  := -1;
      g_reqd_num_tbl(p_order_number) := -1;
      return;
   end if;


   if p_incl_type  = 'LIST' then
      open c_no_of_rows_in_list;
      fetch c_no_of_rows_in_list into l_cnt;
      close c_no_of_rows_in_list;
      write_to_act_log('No of rows in the included list is '||l_cnt,'LIST',g_list_header_id,'LOW');
   elsif p_incl_type = 'IMPH' then
      open c_import_type;
      fetch c_import_type into l_import_type;
      close c_import_type;
      if l_import_type = 'PERSON_LIST' then
         open c_no_of_rows_in_b2c_list;
   	 fetch c_no_of_rows_in_b2c_list into l_cnt;
         close c_no_of_rows_in_b2c_list;
      elsif l_import_type = 'ORGANIZATION_CONTACT_LIST' then
         open c_no_of_rows_in_b2b_list;
	 fetch c_no_of_rows_in_b2b_list into l_cnt;
	 close c_no_of_rows_in_b2b_list;
      end if;
      write_to_act_log('No of rows in the included import list is '||l_cnt,'LIST',g_list_header_id,'LOW');
   elsif (p_incl_type in ('OTHERS') and p_sql_string is not null) then
      if nvl(g_remote_list_gen,'N') = 'Y' then
         execute immediate
            'begin
               ams_remote_listgen_pkg.remote_get_count'||'@'||g_database_link||'(:1,:2,:3,:4,:5)'||';'||
            ' end;'
            using p_sql_string,
            out l_cnt,
            out x_msg_count,
            out x_msg_data,
            out x_return_status;
            write_to_act_log('Total # of rows from this selection is '||l_cnt , 'LIST', g_list_header_id,'LOW');
            if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
               write_to_act_log('Error while executing remote_get_count procedure.', 'LIST', g_list_header_id,'HIGH');
               write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
            elsif nvl(x_return_status,'S') = 'S' then
               write_to_act_log('Procedure remote_get_count executed successfully.', 'LIST', g_list_header_id,'HIGH');
            end if;
      else
         --execute immediate l_rep_str||'('||p_sql_string||')' INTO l_cnt;
	 execute immediate p_sql_string INTO l_cnt;
      end if;
      write_to_act_log('No of rows returned by the sql/segment/workbook is '||l_cnt,'LIST',g_list_header_id,'LOW');
   end if;

   open c_gen_type;
   fetch c_gen_type into l_gen_type;
   close c_gen_type;

   l_no_of_rows_reqd := round(l_cnt * (l_dist_pct/100));
   write_to_act_log('No of rows to be taken from this selection is '||l_no_of_rows_reqd,'LIST',g_list_header_id,'LOW');

   if nvl(l_gen_type,'NONE') = 'INCREMENTAL' then
      open c_get_cnt_from_sel;
      fetch c_get_cnt_from_sel into l_selection_cnt;
      close c_get_cnt_from_sel;

      if l_no_of_rows_reqd > l_selection_cnt then
         l_no_of_rows_reqd := l_no_of_rows_reqd - l_selection_cnt;
         write_to_act_log('Already there are '||l_selection_cnt||' entries. Need to insert '||l_no_of_rows_reqd||' entries.','LIST',g_list_header_id,'LOW');
      elsif l_no_of_rows_reqd <= l_selection_cnt then
         l_no_of_rows_reqd := 0;
         write_to_act_log('Already there are '||l_selection_cnt||' entries. No need to insert.','LIST',g_list_header_id,'LOW');
      end if;
   end if;

   g_act_num_tbl(p_order_number) := l_cnt;
   g_reqd_num_tbl(p_order_number) := l_no_of_rows_reqd;

exception
   when others then
      write_to_act_log('Error while executing get_count procedure','LIST',g_list_header_id,'HIGH');
      write_to_act_log('Error '||sqlcode||'  '||sqlerrm,'LIST',g_list_header_id,'HIGH');
end get_count;

--Added for bug 4577528 by bmuthukr.
PROCEDURE UPDATE_REMOTE_LIST_HEADER(P_LIST_HEADER_ID NUMBER,
                                    X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
				    X_MSG_COUNT      OUT NOCOPY NUMBER,
				    X_MSG_DATA       OUT NOCOPY VARCHAR2) IS
CURSOR C1(p_list_header_id number) IS
SELECT list_header_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       list_used_by_id,
       arc_list_used_by,
       list_type,
       status_code,
       status_date,
       generation_type,
       owner_user_id,
       row_selection_type,
       no_of_rows_max_requested,
       main_random_pct_row_selection,
       ctrl_gen_mode,
       ctrl_status_code,
       ctrl_conc_job_id,
       status_code_old,
       ctrl_limit_of_error,
       ctrl_req_resp_rate,
       ctrl_conf_level,
       ctrl_random_nth_row_selection,
       ctrl_random_pct_row_selection
  FROM ams_list_headers_all
 WHERE list_header_id = p_list_header_id;
c1_rec c1%rowtype;

BEGIN
   x_return_status := 'S';

   if nvl(g_remote_list_gen,'N') = 'N' then
      return;
   end if;

   open c1(p_list_header_id);
   fetch c1 into c1_rec;
   close c1;

   write_to_act_log('Passing the details to remote database to update the header info.', 'LIST', p_list_header_id,'HIGH');
   execute immediate
      'begin
         ams_remote_listgen_pkg.remote_insert_list_headers'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24,:25,:26,:27,:28)'||';'||
      ' end;'
      using
    c1_rec.list_header_id,
    c1_rec.last_update_date,
    c1_rec.last_updated_by,
    c1_rec.creation_date,
    c1_rec.created_by,
    c1_rec.last_update_login,
    c1_rec.list_used_by_id,
    c1_rec.arc_list_used_by,
    c1_rec.list_type,
    c1_rec.status_code,
    c1_rec.status_date,
    c1_rec.generation_type,
    c1_rec.owner_user_id,
    c1_rec.row_selection_type,
    c1_rec.no_of_rows_max_requested,
    c1_rec.main_random_pct_row_selection,
    c1_rec.ctrl_gen_mode,
    c1_rec.ctrl_status_code,
    c1_rec.ctrl_conc_job_id,
    c1_rec.status_code_old,
    c1_rec.ctrl_limit_of_error,
    c1_rec.ctrl_req_resp_rate,
    c1_rec.ctrl_conf_level,
    c1_rec.ctrl_random_nth_row_selection,
    c1_rec.ctrl_random_pct_row_selection,
    out x_msg_count,
    out x_msg_data,
    out x_return_status;
    write_to_act_log('Header info updated in the remote database.', 'LIST', g_list_header_id,'HIGH');
    if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
       write_to_act_log('Error in executing remote_insert_list_headers procedure', 'LIST', g_list_header_id,'HIGH');
       write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
    else
       write_to_act_log('remote_insert_list_headers procedure executed successfully.' ,'LIST',g_list_header_id,'LOW');
    end if;

EXCEPTION
   when others then
      write_to_act_log('Error while executing update_remote_list_header '||sqlcode||'  '||sqlerrm,'LIST',g_list_header_id,'HIGH');
END UPDATE_REMOTE_LIST_HEADER;
------------------------------------------------------------------------------
-- Start of Comments
--
-- NAME
--  migrate_lists
--
-- PURPOSE
--   This procedure migrates the list from the remote instance.
PROCEDURE migrate_lists(
                            p_list_header_id NUMBER
                            );


------------------------------------------------------------------------------
-- Start of Comments
--
-- NAME
--   Update_List_Result_Text
--
-- PURPOSE
--   This procedure updates the result text field on the list header table with
--   processing information such as progress so far and any error messages
--   encountered.
--   The Procedure is an AUTONOMOUS_TRANSACTION which will cause the
--   messages to be saved even if the main transaction is rolled back.
--
-- CALLED BY.
--     Initialize_List.
--     Process_List_Actions.
--
-- NOTES
--
--
-- HISTORY
--   06/23/1999        tdonohoe            created
--                     gjoby           Not being used
-- End of Comments
---------------------------------------------------------------------------------
PROCEDURE update_list_result_text is
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_msg_data       VARCHAR2(2000);
  l_msg_count      number;
BEGIN
  l_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF(l_msg_count <> 0)THEN
     FOR l_iterator IN 1 .. l_msg_count LOOP
        FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
                        FND_API.G_FALSE,
                        l_msg_data,
                        l_msg_count);
        UPDATE ams_list_headers_all
        SET    result_text    = result_text||' '|| l_msg_data
        WHERE  list_header_id = g_list_header_id;
      END LOOP;
      COMMIT;
   END IF;
end update_list_result_text;

----------------------------------------------------------------------------
-- Start of Comments
--
-- NAME
--    Update_List_Action_Dets
--
-- PURPOSE
--    1. Updates The No Available,
--                   No Requested,
--             No Used fields
--         for each List Select Action.
--
--    2. The Values in these fields will be calculated differently
--       depending on the row selection type of the list.
-- CALLED BY.
--    1. Random_List_Generation.
--    2. Check_Max_Entries_Dist_Pct.
--
--
-- HISTORY
--   07/29/1999        tdonohoe            created
--                     gjoby               Changed for hornet
-- End of Comments
----------------------------------------------------------------------------
PROCEDURE UPDATE_LIST_ACTION_DETS( p_list_select_action_id in t_number ,
                                   p_no_of_rows_used       in t_number ,
                                   p_no_of_rows_available  in t_number ,
                                   p_no_of_rows_duplicates in t_number      ) IS
BEGIN

 write_to_act_log(p_msg_data => 'Updating list selections. No of selections =  '||to_char(p_list_select_action_id.count),
                  p_arc_log_used_by => 'LIST',
		  p_log_used_by_id  => g_list_header_id,
		  p_level => 'LOW');


  FORALL I in p_list_select_action_id.first .. p_list_select_action_id.last
     UPDATE ams_list_select_actions
     SET    no_of_rows_used       = p_no_of_rows_used(i),
            no_of_rows_available  = p_no_of_rows_available(i),
	    no_of_rows_duplicates = p_no_of_rows_duplicates(i)
    WHERE  list_select_action_id = p_list_select_action_id(i);

 --write_to_act_log('Update_List_Action_Dets : Finished');

EXCEPTION
  WHEN OTHERS THEN
       -- Minor error not rolling back
       write_to_act_log(p_msg_data => 'Error while executing procedure update_list_action_dets '||sqlcode||sqlerrm,
                        p_arc_log_used_by => 'LIST',
                        p_log_used_by_id => g_list_header_id,
			p_level =>'HIGH');
END UPDATE_LIST_ACTION_DETS;

---------------------------------------------------------------------------------
-- Start of Comments
--
-- NAME
--    UPDATE_LIST_DETS
--
-- PURPOSE
--  1. Updates The No_of_Rows_In_List,
--                 No_of_Rows_In_Ctrl_Group,
--                 No_of_Rows_Duplicates,
--                 Last_Generation_Success_Flag,
--                 Main_Gen_End_Time columns on The Ams_List_Headers_All table.
--                     gjoby               Changed for hornet

-- CALLED BY.
--    1. Generate_List.

--
-- HISTORY
-- END of Comments

procedure Update_List_Dets(p_list_header_id IN NUMBER,
                           x_return_status OUT NOCOPY varchar2) is

--------------------------------------------------------------
--This Variable stores the result of cursor c_list_gen_type.--
--------------------------------------------------------------
l_generation_type AMS_LIST_HEADERS_ALL.GENERATION_TYPE%TYPE;

-- updates the count of ams_list_entries and list selections
-- Calls update_list_action_dets for updating selection records
-- If the list criteria is not met then the list status is set back to draft
------------------------------------------------------------------------------
--gets the number of entries in the list for a particular list select action--
------------------------------------------------------------------------------
CURSOR C_LIST_ACTION_DETS(p_list_header_id NUMBER) IS
SELECT b.no_of_rows_active Count,
       sum(decode(e.enabled_flag,'Y',1,0)),
       e.List_select_action_id,
       a.distribution_pct,
       a.rank rank_col,
       sum(decode(e.marked_as_duplicate_flag,'Y',1,0))
FROM   ams_list_entries e,
       ams_list_select_actions a
       ,ams_list_headers_all b
WHERE  e.list_header_id = p_list_header_id
AND    e.list_select_action_id = a.list_select_action_id
AND    a.arc_action_used_by = 'LIST'
AND    a.action_used_by_id = p_list_header_id
AND    b.list_header_id = a.incl_object_id
and    a.arc_incl_object_from = 'LIST'
GROUP  BY e.list_select_action_id,a.distribution_pct,a.rank,b.no_of_rows_active
UNION ALL
SELECT COUNT(e.List_Entry_Id) Count,
       sum(decode(e.enabled_flag,'Y',1,0)),
       e.List_select_action_id,
       a.distribution_pct,
       a.rank rank_col,
       sum(decode(e.marked_as_duplicate_flag,'Y',1,0))
FROM   ams_list_entries e,
       ams_list_select_actions a
WHERE  e.list_header_id = p_list_header_id
AND    e.list_select_action_id = a.list_select_action_id
AND    a.arc_action_used_by = 'LIST'
AND    a.action_used_by_id = p_list_header_id
and    a.arc_incl_object_from <> 'LIST'
GROUP  BY e.list_select_action_id,a.distribution_pct,a.rank
ORDER  BY rank_col desc ;

CURSOR C_LIST_ACTION_DETS_TG(p_list_header_id NUMBER) IS
SELECT COUNT(e.List_Entry_Id),
       sum(decode(e.enabled_flag,'Y',1,0)),
       a.List_select_action_id,
       a.distribution_pct,
       a.rank,
       sum(decode(e.marked_as_duplicate_flag,'Y',1,0))
FROM   ams_list_entries e,
       ams_list_select_actions a,
       ams_act_lists t
WHERE  e.list_header_id = p_list_header_id
AND    e.list_select_action_id   = t.act_list_header_id
and    t.list_header_id = a.INCL_OBJECT_ID
AND    a.arc_action_used_by = 'LIST'
AND    a.action_used_by_id = p_list_header_id
GROUP  BY a.list_select_action_id,a.distribution_pct,a.rank
ORDER  BY a.rank desc ;

cursor c_count_list_entries(cur_p_list_header_id number) is
select sum(decode(enabled_flag,'N',0,1)),
       sum(decode(enabled_flag,'Y',0,1)),
       sum(1),
       sum(decode(part_of_control_group_flag,'Y',1,0)),
       sum(decode(marked_as_random_flag,'Y',1,0)),
       sum(decode(marked_as_duplicate_flag,'Y',1,0)),
       sum(decode(manually_entered_flag,
                     'Y',decode(enabled_flag,'Y','1',0),
                     0)),
       sum(decode(MARKED_AS_SUPPRESSED_FLAG,'Y',1,0)),
       sum(decode(MARKED_AS_FATIGUED_FLAG,'Y',1,0)),
       sum(decode(TCA_LOAD_STATUS,'ERROR',1,0))
from ams_list_entries
where list_header_id = cur_p_list_header_id ;

l_tca_error_recs	number;
l_TCA_FAILED_RECORDS	number;

cursor c_tca_error is
select count(1) from ams_list_entries
where list_header_id = p_list_header_id
  and TCA_LOAD_STATUS = 'ERROR';

l_list_type	varchar2(100);
cursor c_list_type is
select list_type from ams_list_headers_all where list_header_id = p_list_header_id;


l_list_entry_action_count NUMBER;
l_list_select_action_id   NUMBER;
l_distribution_pct        NUMBER;
l_rank                    NUMBER;
l_iterator                NUMBER := 1;
l_min_rows                number;
l_new_status              varchar2(30);
l_new_status_id           number;

l_no_of_rows_duplicates         number;
l_no_of_rows_in_list            number;
l_no_of_rows_active             number;
l_no_of_rows_inactive           number;
l_no_of_rows_manually_entered   number;
l_no_of_rows_in_ctrl_group      number;
l_no_of_rows_random             number;
l_no_of_rows_used               number;
l_no_of_rows_suppressed         number := 0;
l_no_of_rows_fatigued           number := 0;
t_list_select_action_id   t_number;
t_no_of_rows_requested    t_number;
t_no_of_rows_available    t_number;
t_no_of_rows_used         t_number;
t_no_of_rows_duplicates   t_number;
l_no_of_rows_dup          number;
x_msg_count		  number;
x_msg_data		  varchar2(2000);

/* Added by rrajesh on 08/02/04. Bugfix: 3799191*/
CURSOR C_GET_LIST_TYPE(p_list_header_id NUMBER) IS
   select list_type from ams_list_headers_all
   where list_header_id = p_list_header_id;
l_type   varchar2(30);
/* End Bugfix: 3799191*/

BEGIN
  if g_list_header_id is null then
     g_list_header_id := p_list_header_id;
  end if;
  write_to_act_log('Executing update_list_dets to update the list header details','LIST', g_list_header_id,'LOW');
/* Bugfix: 3799191. Modified by rrajesh. Number of TCA error records not getting updated for remote based TG */
Open C_GET_LIST_TYPE(p_list_header_id);
Fetch C_GET_LIST_TYPE into l_type;
Close C_GET_LIST_TYPE;
--if g_remote_list_gen = 'N' then
if ((g_remote_list_gen = 'N') OR (l_type = 'TARGET'))
then
/* End Bugfix: 3799191. */
  open c_count_list_entries(p_list_header_id);
  fetch c_count_list_entries
   into l_no_of_rows_active            ,
        l_no_of_rows_inactive          ,
        l_no_of_rows_in_list           ,
        l_no_of_rows_in_ctrl_group     ,
        l_no_of_rows_random            ,
        l_no_of_rows_duplicates        ,
        l_no_of_rows_manually_entered  ,
        l_no_of_rows_suppressed,
        l_no_of_rows_fatigued,
        l_TCA_FAILED_RECORDS;
  close c_count_list_entries;
 ELSE
  write_to_act_log('Calling remote procedure to update list header details','LIST', g_list_header_id,'LOW');
  execute immediate
      'BEGIN
         AMS_Remote_ListGen_PKG.remote_list_status_detils'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11)'||';'||
      ' END;'
      using  p_list_header_id,
             OUT l_no_of_rows_active,
             OUT l_no_of_rows_inactive,
             OUT l_no_of_rows_in_list,
             OUT l_no_of_rows_in_ctrl_group,
	     OUT l_no_of_rows_random,
	     OUT l_no_of_rows_duplicates,
	     OUT l_no_of_rows_manually_entered,
             OUT x_msg_count,
             OUT x_msg_data,
             OUT x_return_status;

   if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
      write_to_act_log('Error in executing remote procedure while updating list details', 'LIST', g_list_header_id,'HIGH');
      write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
   else
      write_to_act_log('Remote procedure executed. No of active rows '||l_no_of_rows_active||' , No of inactive rows '||l_no_of_rows_inactive||
                        ' ,No of rows in list '||l_no_of_rows_in_list||' , No of duplicates '||l_no_of_rows_duplicates,'LIST', g_list_header_id,'LOW');
   end if;


 end if;



-- Start changes for migration
/*
 SELECT nvl(no_of_rows_min_requested,0)
 INTO   l_min_rows
 FROM   ams_list_headers_all
 WHERE  list_header_id = p_list_header_id;

 if l_min_rows > l_no_of_rows_active then
    l_new_status :=  'DRAFT';
    l_new_status_id   :=  300;
 else
    l_new_status :=  'AVAILABLE';
    l_new_status_id   :=  303;
 end if;
*/

--  if l_no_of_rows_active >= 0 then
    l_new_status := 'AVAILABLE';
    l_new_status_id := 303;
--  end if;

-- End changes for migration

  update ams_list_headers_all
  set no_of_rows_in_list           = nvl(l_no_of_rows_in_list,0),
      no_of_rows_active            = nvl(l_no_of_rows_active,0),
      no_of_rows_inactive          = nvl(l_no_of_rows_inactive,0),
      no_of_rows_in_ctrl_group     = nvl(l_no_of_rows_in_ctrl_group,0),
      no_of_rows_random            = nvl(l_no_of_rows_random,0),
      no_of_rows_duplicates        = nvl(l_no_of_rows_duplicates,0),
      no_of_rows_manually_entered  = nvl(l_no_of_rows_manually_entered,0),
      no_of_rows_suppressed        = nvl(l_no_of_rows_suppressed,0),
      NO_OF_ROWS_FATIGUED          = nvl(l_no_of_rows_fatigued,0),
      TCA_FAILED_RECORDS           = nvl(l_TCA_FAILED_RECORDS,0),
      last_generation_success_flag = decode(l_new_status_id,303,'Y','N'),
      -- MIGRATION_DATE               = decode(g_remote_list_gen,'Y',null,MIGRATION_DATE),
      status_code                  = l_new_status,
      user_status_id               = l_new_status_id,
      status_date                  = sysdate,
      last_update_date             = sysdate,
      main_gen_end_time            = sysdate,
      no_of_rows_initially_selected = g_no_of_rows_ini_selected,
      remote_gen_flag              = nvl(g_remote_list_gen,'N')
  WHERE  list_header_id            = p_list_header_id;
  write_to_act_log('No of rows in list/target group = '||nvl(l_no_of_rows_in_list,0),'LIST', g_list_header_id,'HIGH');
  write_to_act_log('No of active rows in list/target group = '||nvl(l_no_of_rows_active,0),'LIST', g_list_header_id,'HIGH');
  write_to_act_log('No of inactive rows in list/target group = '||nvl(l_no_of_rows_inactive,0),'LIST', g_list_header_id,'HIGH');
  write_to_act_log('No of duplicates in list/target group = '||nvl(l_no_of_rows_duplicates,0),'LIST', g_list_header_id,'HIGH');
  write_to_act_log('List header table updated','LIST', g_list_header_id,'LOW');
  -- Added for cancel list gen as it prevents parallel update- Raghu
  -- of list headers when cancel button is pressed
  commit;

  if g_remote_list = 'Y' then
     -- bug # 3839014. even if the tg, based on remote DS, is generated locally we are
     --calling tca_updload_process..so we need this validation,
        open c_tca_error;
	fetch c_tca_error into l_tca_error_recs;
	close c_tca_error;
	/* Modified by rrajesh on 08/02/04. Bugfix: 3799191. Even if one record fails,
	the target group/list status should be failed */
	--if l_no_of_rows_in_list = l_tca_error_recs then
	if l_tca_error_recs > 0 then
	/* End fix: 3799191 */
	  update ams_list_headers_all
		set status_code = 'FAILED',
		user_status_id  = 311
      WHERE list_header_id = p_list_header_id;
      write_to_act_log('TCA fields not mapped for atleast one record. Marking the status as FAILED.','LIST', g_list_header_id,'HIGH');
  -- Added for cancel list gen as it prevents parallel update- Raghu
  -- of list headers when cancel button is pressed
      commit;
    end if;
end if;

open  c_list_type;
fetch c_list_type into l_list_type;
close c_list_type;

 write_to_act_log('Updating list select actions for each selection.'||l_list_type, 'LIST', g_list_header_id,'LOW');
 OPEN C_LIST_ACTION_DETS(p_list_header_id);
 LOOP
    FETCH C_LIST_ACTION_DETS INTO l_list_entry_action_count,
                                  l_no_of_rows_used  ,
                                  l_list_select_action_id,
                                  l_distribution_pct,
                                  l_rank,
                                  l_no_of_rows_dup;

    EXIT WHEN C_LIST_ACTION_DETS%NOTFOUND;

    t_list_select_action_id(l_iterator) := l_list_select_action_id;
    t_no_of_rows_requested(l_iterator)  := l_list_entry_action_count;
    t_no_of_rows_available(l_iterator)  := l_list_entry_action_count;
    t_no_of_rows_used(l_iterator)       := l_no_of_rows_used               ;
    t_no_of_rows_duplicates(l_iterator) := l_no_of_rows_dup;
    write_to_act_log('Calling update_list_action_dets to update the list selection '||l_list_select_action_id, 'LIST', g_list_header_id,'LOW');
    update_list_action_dets( t_list_select_action_id,
                             t_no_of_rows_used,
                             t_no_of_rows_available,
			     t_no_of_rows_duplicates);

    l_iterator := l_iterator +1;

  END LOOP;
  CLOSE C_LIST_ACTION_DETS;
-- end if;


if l_list_type = 'TARGET' then
 l_iterator := 1;
 write_to_act_log('Updating selections in TG ', 'LIST', g_list_header_id,'LOW');
 OPEN C_LIST_ACTION_DETS_TG(p_list_header_id);
-- dbms_output.put_line('UPDATE_LIST_DETS: 2222222');
 LOOP
    FETCH C_LIST_ACTION_DETS_TG INTO l_list_entry_action_count,
                                  l_no_of_rows_used  ,
                                  l_list_select_action_id,
                                  l_distribution_pct,
                                  l_rank,
                                  l_no_of_rows_dup;

    EXIT WHEN C_LIST_ACTION_DETS_TG%NOTFOUND;
    t_list_select_action_id(l_iterator) := l_list_select_action_id;
    t_no_of_rows_requested(l_iterator)  := l_list_entry_action_count;
    t_no_of_rows_available(l_iterator)  := l_list_entry_action_count;
    t_no_of_rows_used(l_iterator)       := l_no_of_rows_used               ;
    t_no_of_rows_duplicates(l_iterator) := l_no_of_rows_dup;
    write_to_act_log('Calling update_list_action_dets for updating the TG selection '||l_list_select_action_id, 'LIST', g_list_header_id,'LOW');
    update_list_action_dets( t_list_select_action_id,
                             t_no_of_rows_used,
                             t_no_of_rows_available,
                             t_no_of_rows_duplicates);

    l_iterator := l_iterator +1;

  END LOOP;
  CLOSE C_LIST_ACTION_DETS_TG;

end if;

write_to_act_log('List summary details updated in header and selection tables','LIST', g_list_header_id,'LOW');

EXCEPTION
 WHEN OTHERS THEN
  -- Minor error not rolling back
   write_to_act_log( 'Error while executing procedure update_list_dets '||sqlcode||'   '||sqlerrm, 'LIST',  g_list_header_id,'HIGH');
END UPDATE_LIST_DETS ;




-----------------------------------------------------------------------------
--  Delete_List_Entries
--  1.  Delete List entries which may have occured from previous generations
---     of the list. Table Name : ams_list_tmp_entries and ams_list_entries
--  2.  Delete from ams_list_src_type_usages
--      List_src_type_usages store the source type code against each type
--      of list
--  10/29/1999 TDONOHOE   Created
--  01/24/2001 GJOBY      Changed from function to Procedure
--                        Added FND Message procedures
------------------------------------------------------------------------------

PROCEDURE delete_list_entries(p_list_header_id     number ,
                              x_msg_count      OUT NOCOPY number,
                              x_msg_data       OUT NOCOPY varchar2,
                              x_return_status  OUT NOCOPY varchar2)  IS

l_delete_action varchar2(80);
l_total_recs	number;
l_null		varchar2(30) := null;
-- deletes from ams_list_entries in case of standard type of generation
BEGIN
   write_to_act_log('Executing delete_list_entries to delete entries from ams_list_entries(Since list/target group is generated in STANDARD mode).', 'LIST', g_list_header_id,'LOW');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
-------------------------------------------------------------------------------
--Delete all existing entries for this list which are in the temporary table.--
-------------------------------------------------------------------------------
   l_delete_action   := 'List tmp Entries delete';
----------------------------------------------
--Delete all existing entries for this list.--
----------------------------------------------
   l_delete_action   := 'List Entries delete';
   DELETE FROM ams_list_entries
   WHERE  list_header_id = p_list_header_id;
   write_to_act_log(sql%rowcount||' entries deleted from ams_list_entries in local instance.', 'LIST', g_list_header_id,'LOW');
   /********************************************************************
    Dynamic procedure will delete the list from the remote instance in
    case of remote list
   *********************************************************************/
   if g_remote_list = 'Y' then
      write_to_act_log('Calling remote procedure with process type as DELETE_LIST_ENTRIES to delete entries in remote instance', 'LIST', g_list_header_id,'LOW');
      execute immediate
      'BEGIN
       AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
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
         write_to_act_log('Error in executing remote procedure', 'LIST', g_list_header_id,'HIGH');
         write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
      else
         write_to_act_log('Entries deleted succesfully in remote instance','LIST', g_list_header_id,'LOW');
     end if;
   end if;
------------------------------------------------------------------------------
--Delete all entries in the ams_list_src_type_usages table.                 --
--These entries must be refreshed each time that a list is refreshed.       --
------------------------------------------------------------------------------
   l_delete_action   := 'List Source Type usages';
   write_to_act_log('Deleting entries from list src type usages tables.', 'LIST', g_list_header_id,'LOW');
   DELETE FROM ams_list_src_type_usages
   WHERE  list_header_id = p_list_header_id;
   write_to_act_log('Procedure delete_list_entries executed successfully.', 'LIST', g_list_header_id,'LOW');
EXCEPTION
    WHEN OTHERS THEN
       write_to_act_log('Error while executing delete_list_entries '||sqlcode || ' '||sqlerrm, 'LIST',g_list_header_id,'HIGH');
       FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT', 'Delete List Entries ' ||
                         l_delete_action || ' '|| SQLERRM||' '||SQLCODE);
       FND_MSG_PUB.Add;
       x_return_status  := FND_API.G_RET_STS_ERROR ;

END delete_list_entries;



-----------------------------------------------------------------------------
--  initialize_list_header
--
--  PURPOSE
--  list header fields must be initialized.
--  updates the result_text, main_gen_start_time, main_gen_end_time
--  01/24/2001 GJOBY      Modified for hornet
-----------------------------------------------------------------------------
PROCEDURE initialize_list_header (p_list_header_id     NUMBER,
                                  x_msg_count      OUT NOCOPY number,
                                  x_msg_data       OUT NOCOPY varchar2,
                                  x_return_status  OUT NOCOPY VARCHAR2)  IS
BEGIN
  write_to_act_log('Executing procedure initialize_list_header', 'LIST', g_list_header_id,'LOW');
  UPDATE ams_list_headers_all
  SET  result_text         = NULL,
       main_gen_start_time = SYSDATE,
       last_update_date    = SYSDATE,
       main_gen_end_time   = NULL
  WHERE  list_header_id    =   p_list_header_id;
  -- Added for cancel list gen as it prevents parallel update- Raghu
  -- of list headers when cancel button is pressed
  commit;

  UPDATE ams_list_select_actions
  SET  no_of_rows_used =  0
  WHERE  arc_action_used_by = 'LIST'
    and  action_used_by_id    =   p_list_header_id;

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
       write_to_act_log('Error while executing initialize_list_header procedure', 'LIST', g_list_header_id,'HIGH');
       FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT', 'Initialize List Header ' ||
                               SQLERRM||' '||SQLCODE);
       FND_MSG_PUB.Add;
       x_return_status  := FND_API.G_RET_STS_ERROR ;
END initialize_list_header;

-------------------------------------------------------------------------------
-- Start of Comments
-- NAME initialize_list
-- PURPOSE
--  1. Deletes the log information from ams_act_logs
--  2. Initializes List header (initialize_list_header)
--  3. deletes list entries    (delete_list_entries )
-- CALLED BY.
--    1. Generate_List.
-- HISTORY
--   06/21/1999   tdonohoe  created
--   01/20/2000   tdonohoe  added code to delete any existing log entries
--                          for the list.
--   01/23/2001   gjoby     Modification for Hornet Release
--                          Changed the initiliaze list to procedure
--                          Removed unnecessary procedures
--                          removed the global variables
--                          Changed from function to procedure
--                          Error logging at each stage
-- END of Comments
-----------------------------------------------------------------------------
PROCEDURE initialize_list
     (p_list_header_rec    ams_listheader_pvt.list_header_rec_type,
      x_msg_count          OUT NOCOPY number,
      x_msg_data           OUT NOCOPY varchar2,
      x_return_status      OUT NOCOPY VARCHAR2   ) IS
BEGIN
   write_to_act_log('Executing procedure initialize_list', 'LIST', g_list_header_id,'LOW');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -----------------------------------------------------------------
   --Delete any existing log entries for this list.               --
   -----------------------------------------------------------------
   --DELETE FROM ams_act_logs
   --WHERE  arc_act_log_used_by = 'LIST'
   --AND    act_log_used_by_id  = p_list_header_rec.list_header_id ;
   --write_to_act_log(sql%rowcount||' entries deleted from ams_act_logs table for this list.', 'LIST', g_list_header_id,'LOW');

   --------------------------------------------------------------------------
   -- Initializes the list header  generation date and time as null        --
   --------------------------------------------------------------------------
   initialize_list_header(p_list_header_id => p_list_header_rec.list_header_id,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          x_return_status  => x_return_status);
   if x_return_status <> FND_API.g_ret_sts_success then
         write_to_act_log('Error while executing initialize_list_header. Unable to Initialize List ', 'LIST', g_list_header_id,'HIGH');
      raise FND_API.g_exc_unexpected_error;
   end if;
   -----------------------------------------------------------------
   --Deleting any existing entries. if generation type is Standard--
   -----------------------------------------------------------------
   if p_list_header_rec.generation_type = 'STANDARD' then
      write_to_act_log('Calling delete_list_entries to delete the existing entries.(The generation type is STANDARD).', 'LIST', g_list_header_id,'LOW');
      delete_list_entries (p_list_header_id => p_list_header_rec.list_header_id,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           x_return_status  => x_return_status);
      if x_return_status <> FND_API.g_ret_sts_success then
         write_to_act_log('Error while executing delete_list_entries. Unable to delete entries.', 'LIST', g_list_header_id,'HIGH');
         raise FND_API.g_exc_unexpected_error;
      end if;
  end if;
  write_to_act_log('Procedure initialize_list executed successfully.', 'LIST', g_list_header_id,'LOW');
   -- CHECK if we need to initlialize list select actions and
   -- and list header number of rows etc.
EXCEPTION
   WHEN FND_API.g_exc_error THEN
     write_to_act_log('Error while executing procedure initialize_list '||sqlcode||'  '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
     write_to_act_log('Error while executing procedure initialize_list '||sqlcode||'  '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
     write_to_act_log('Error while executing procedure initialize_list '||sqlcode||'  '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, g_file_name);
     END IF;
     FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END initialize_list;

---------------------------------------------------------------------------
-- Start of Comments
--
-- NAME
--    Insert_List_Mapping_Usage
--
-- PURPOSE

--    1. Performs a Check to ensure that the list mapping has not already been
--       inserted into the Usage table.
--    2. Inserts a Mapping type into the ams_list_src_usages table for each
--       master
--       and sub type found in any list action source, i.e. List or WorkBooks.
--    3. Tracking this information allows us to update sub sets of the lists
--       entries in the future.
-- HISTORY
--  01/24/2001 GJOBY      Modified for hornet
---------------------------------------------------------------------------

PROCEDURE insert_list_mapping_usage
                (p_list_header_id   AMS_LIST_HEADERS_ALL.LIST_HEADER_ID%TYPE,
                 p_source_type_code AMS_LIST_SRC_TYPES.SOURCE_TYPE_CODE%TYPE) IS

l_found NUMBER;
BEGIN


   INSERT INTO ams_list_src_type_usages
   (
      list_source_type_usage_id
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,object_version_number
      ,source_type_code
      ,list_header_id
    )
    select
      AMS_LIST_SRC_TYPE_USAGES_S.NEXTVAL,
      SYSDATE,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.USER_ID,
      1,
      p_source_type_code,
      p_list_header_id
   from dual
   where not exists
      ( select  'x'
        from  ams_list_src_type_usages
        where list_header_id = p_list_header_id
          and source_type_code = p_source_type_code ) ;
EXCEPTION
  WHEN OTHERS THEN
    write_to_act_log('Error while executing procedure insert_list_mapping_usage '||sqlerrm||sqlcode, 'LIST', g_list_header_id,'HIGH');
END INSERT_LIST_MAPPING_USAGE;

PROCEDURE process_imph
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              ) is
l_list_entry_source_type  varchar2(30);
cursor c_get_source_type
is select  decode(import_type,'B2C','PERSON_LIST','ORGANIZATION_CONTACT_LIST')
from ams_imp_list_headers_all
where  import_list_header_id = p_incl_object_id;
l_no_of_chunks  number;

l_created_by                NUMBER;

CURSOR cur_get_created_by (x_list_header_id IN NUMBER) IS
      SELECT created_by
      FROM ams_list_headers_all
      WHERE list_header_id= x_list_header_id;

BEGIN
    write_to_act_log('Executing process_imph since imported list has been included in list/target group selections.', 'LIST', g_list_header_id,'LOW');
    open  c_get_source_type ;
    fetch c_get_source_type into l_list_entry_source_type  ;
    close  c_get_source_type ;
    write_to_act_log('List entry source type is '||l_list_entry_source_type, 'LIST', g_list_header_id,'LOW');


    if p_list_action_type  = 'INCLUDE' then
       --get_count(p_list_select_action_id,p_order_number,'IMPH',null);
       if   l_list_entry_source_type <> 'PERSON_LIST' then
          l_created_by := 0;

	 OPEN cur_get_created_by(p_action_used_by_id);

	 FETCH cur_get_created_by INTO l_created_by;
         CLOSE cur_get_created_by;

       x_include_sql  := ' insert into ams_list_entries
             (list_header_id ,
              list_entry_id,
              imp_source_line_id,
              object_version_number,
              source_code                     ,
              source_code_for_id              ,
              arc_list_used_by_source         ,
              arc_list_select_action_from     ,
              pin_code                        ,
              view_application_id             ,
              manually_entered_flag           ,
              marked_as_random_flag           ,
              marked_as_duplicate_flag        ,
              part_of_control_group_flag      ,
              exclude_in_triggered_list_flag  ,
              enabled_flag ,
              LIST_SELECT_ACTION_FROM_NAME,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              list_entry_source_system_id,
              list_entry_source_system_type,
              list_select_action_id,
	      rank,
              ADDRESS_LINE1,
              ADDRESS_LINE2,
              COL127,
              COL128,
              COL227,
              CITY,
              COUNTRY,
              COL118,
              COL142,
              COL138,
              COL122,
              EMAIL_ADDRESS,
              COL239,
              FIRST_NAME,
              COL243,
              COL144,
	      COL145, --Added by bmuthukr for bug 5156979
              LAST_NAME,
              COL251,
              COL252,
              COL137,
              SUFFIX,
              COL259,
              COL6,
              COL5,
              COL7,
              PHONE,
              ZIPCODE,
              COL120,
              STATE,
              COL125,
              COL2,
              TITLE,
              customer_name,
              party_id,
              COL276 ,
              NOTES                                    ,
              VEHICLE_RESPONSE_CODE                   ,
              SALES_AGENT_EMAIL_ADDRESS               ,
              RESOURCE_ID                              ,
              col147,
              location_id ,
              contact_point_id ,
              orig_system_reference,
              col116,
              col117,
	      CUSTOM_COLUMN1,
	      CUSTOM_COLUMN2,
	      CUSTOM_COLUMN3,
	      CUSTOM_COLUMN4,
	      CUSTOM_COLUMN5,
	      CUSTOM_COLUMN6,
	      CUSTOM_COLUMN7,
	      CUSTOM_COLUMN8,
	      CUSTOM_COLUMN9,
	      CUSTOM_COLUMN10,
	      CUSTOM_COLUMN11,
	      CUSTOM_COLUMN12,
	      CUSTOM_COLUMN13,
	      CUSTOM_COLUMN14,
	      CUSTOM_COLUMN15,
	      CUSTOM_COLUMN16,
	      CUSTOM_COLUMN17,
	      CUSTOM_COLUMN18,
	      CUSTOM_COLUMN19,
	      CUSTOM_COLUMN20,
	      CUSTOM_COLUMN21,
	      CUSTOM_COLUMN22,
	      CUSTOM_COLUMN23,
	      CUSTOM_COLUMN24,
	      CUSTOM_COLUMN25,
              FAX
              )
              select
                     ' || p_action_used_by_id || ' ,
              ams_list_entries_s.nextval, import_source_line_id,
              1 ,' ||
              ''''||'NONE'                ||''''     || ','||
              0                           || ','     ||
              ''''||'NONE'                ||''''     || ','||
              ''''||'IMPH'                ||''''     || ','||
              'ams_list_entries_s.currval'|| ','||
              530              || ','||
              ''''||'N'  ||''''|| ','||
              ''''||'N'  ||''''|| ','||
              ''''||'N'  ||''''|| ','||
              ''''||'N'  ||''''|| ','||
              ''''||'N'  ||''''|| ','||
              ''''||'Y'  ||''''||',
              '||p_action_used_by_id || ',
              sysdate,
              FND_GLOBAL.USER_ID,
              sysdate,
              '||nvl(l_created_by,FND_GLOBAL.USER_ID)||',
              FND_GLOBAL.USER_ID,
              nvl(party_id,import_source_line_id), ' ||
              ''''|| l_list_entry_source_type||''''|| ' , '||
              p_list_select_action_id   || ' ,'||
              p_rank   ||',
              ADDRESS1,
              ADDRESS2,
              BEST_TIME_CONTACT_BEGIN,
              BEST_TIME_CONTACT_END,
              CEO_NAME,
              CITY,
              COUNTRY,
              COUNTY,
              DECISION_MAKER_FLAG,
              DEPARTMENT,
              DUNS_NUMBER,
              EMAIL_ADDRESS,
              EMPLOYEES_TOTAL,
              PERSON_FIRST_NAME,
              FISCAL_YEAREND_MONTH,
              JOB_TITLE,
	      JOB_TITLE_CODE, --Added by bmuthukr for bug 5156979
              PERSON_LAST_NAME,
              LEGAL_STATUS,
              LINE_OF_BUSINESS,
              PERSON_MIDDLE_NAME,
              PERSON_NAME_SUFFIX,
              party_name,
              PHONE_AREA_CODE,
              PHONE_COUNTRY_CODE,
              PHONE_EXTENTION,
              PHONE_NUMBER,
              POSTAL_CODE,
              PROVINCE,
              STATE,
              TAX_REFERENCE,
              TIME_ZONE,
              PERSON_NAME_PREFIX,
              party_name,
              party_id,
              YEAR_ESTABLISHED,
              NOTES                                    ,
              VEHICLE_RESPONSE_CODE                   ,
              SALES_AGENT_EMAIL_ADDRESS               ,
              RESOURCE_ID                              ,
              ORGANIZATION_ID,
              location_id ,
              contact_point_id ,
              orig_system_reference,
              address3,
              address4,
	      CUSTOM_COLUMN1,
	      CUSTOM_COLUMN2,
	      CUSTOM_COLUMN3,
	      CUSTOM_COLUMN4,
	      CUSTOM_COLUMN5,
	      CUSTOM_COLUMN6,
	      CUSTOM_COLUMN7,
	      CUSTOM_COLUMN8,
	      CUSTOM_COLUMN9,
	      CUSTOM_COLUMN10,
	      CUSTOM_COLUMN11,
	      CUSTOM_COLUMN12,
	      CUSTOM_COLUMN13,
	      CUSTOM_COLUMN14,
	      CUSTOM_COLUMN15,
	      CUSTOM_COLUMN16,
	      CUSTOM_COLUMN17,
	      CUSTOM_COLUMN18,
	      CUSTOM_COLUMN19,
	      CUSTOM_COLUMN20,
	      CUSTOM_COLUMN21,
	      CUSTOM_COLUMN22,
	      CUSTOM_COLUMN23,
	      CUSTOM_COLUMN24,
	      CUSTOM_COLUMN25,
	      FAX_NUMBER
       from   ams_hz_b2b_mapping_v ail
            where  enabled_flag = '||''''||'Y'||''''||
             ' and import_list_header_id =' || p_incl_object_id   ||
             ' and nvl(party_id, import_source_line_id) in (' ;
          write_to_act_log('Insert statement constructed for imported B2B list', 'LIST', g_list_header_id,'LOW');
      else
       x_include_sql  := ' insert into ams_list_entries
             (list_header_id ,
              list_entry_id,
              imp_source_line_id,
              source_code                     ,
              source_code_for_id              ,
              arc_list_used_by_source         ,
              arc_list_select_action_from     ,
              pin_code                        ,
              view_application_id             ,
              manually_entered_flag           ,
              marked_as_random_flag           ,
              marked_as_duplicate_flag        ,
              part_of_control_group_flag      ,
              exclude_in_triggered_list_flag  ,
              enabled_flag ,
              LIST_SELECT_ACTION_FROM_NAME,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              object_version_number,
              list_entry_source_system_id,
              list_entry_source_system_type,
              list_select_action_id,
              rank,
              ADDRESS_LINE1,
              ADDRESS_LINE2,
              CITY,
              COL127,
              COL128,
              COL118,
              COUNTRY,
              FIRST_NAME,
              LAST_NAME,
              COL137,
              EMAIL_ADDRESS,
              col70,
              COL145,
              STATE,
              ZIPCODE,
              COL120,
              TITLE,
              COL2,
              col5,
              col6,
              PHONE,
              col7,
              party_id,
              customer_name,
              SUFFIX  ,
              NOTES                                    ,
              VEHICLE_RESPONSE_CODE                   ,
              SALES_AGENT_EMAIL_ADDRESS               ,
              RESOURCE_ID                              ,
              location_id,
              contact_point_id ,
              orig_system_reference,
              col116,
              col117,
	      CUSTOM_COLUMN1,
	      CUSTOM_COLUMN2,
	      CUSTOM_COLUMN3,
	      CUSTOM_COLUMN4,
	      CUSTOM_COLUMN5,
	      CUSTOM_COLUMN6,
	      CUSTOM_COLUMN7,
	      CUSTOM_COLUMN8,
	      CUSTOM_COLUMN9,
	      CUSTOM_COLUMN10,
	      CUSTOM_COLUMN11,
	      CUSTOM_COLUMN12,
	      CUSTOM_COLUMN13,
	      CUSTOM_COLUMN14,
	      CUSTOM_COLUMN15,
	      CUSTOM_COLUMN16,
	      CUSTOM_COLUMN17,
	      CUSTOM_COLUMN18,
	      CUSTOM_COLUMN19,
	      CUSTOM_COLUMN20,
	      CUSTOM_COLUMN21,
	      CUSTOM_COLUMN22,
	      CUSTOM_COLUMN23,
	      CUSTOM_COLUMN24,
	      CUSTOM_COLUMN25,
	      FAX
              )
            select
                     ' || p_action_used_by_id || ' ,
              ams_list_entries_s.nextval, ' ||
              ' import_source_line_id , ' ||
              ''''||'NONE'                ||''''     || ','||
             0                           || ','     ||
             ''''||'NONE'                ||''''     || ','||
             ''''||'IMPH'                ||''''     || ','||
             'ams_list_entries_s.currval'|| ','||
             530              || ','||
             ''''||'N'  ||''''|| ','||
             ''''||'N'  ||''''|| ','||
             ''''||'N'  ||''''|| ','||
             ''''||'N'  ||''''|| ','||
             ''''||'N'  ||''''|| ','||
             ''''||'Y'  ||''''||',
              '||p_action_used_by_id || ',
              sysdate,
              FND_GLOBAL.USER_ID,
              sysdate,
              '||nvl(l_created_by,FND_GLOBAL.USER_ID)||',
              FND_GLOBAL.USER_ID,
              1,
              nvl(party_id,import_source_line_id), ' ||
              ''''|| l_list_entry_source_type||''''|| ' , '||
              p_list_select_action_id   || ' ,'||
              p_rank   ||',
              ADDRESS1,
              ADDRESS2,
              CITY,
              BEST_TIME_CONTACT_BEGIN,
              BEST_TIME_CONTACT_END,
              COUNTY,
              COUNTRY,
              PERSON_FIRST_NAME,
              PERSON_LAST_NAME,
              PERSON_MIDDLE_NAME,
              EMAIL_ADDRESS,
              GENDER,
              HOUSEHOLD_INCOME,
              STATE,
              POSTAL_CODE,
              PROVINCE,
              PERSON_NAME_PREFIX,
              TIME_ZONE  ,
              PHONE_COUNTRY_CODE,
              PHONE_AREA_CODE   ,
              PHONE_NUMBER      ,
              PHONE_EXTENTION   ,
              party_id,
              PERSON_LAST_NAME || '|| ''''|| ' , ' || ''''||
                                 ' || PERSON_FIRST_NAME,
              PERSON_NAME_SUFFIX ,
              NOTES                                    ,
              VEHICLE_RESPONSE_CODE                   ,
              SALES_AGENT_EMAIL_ADDRESS               ,
              RESOURCE_ID                              ,
          location_id ,
          contact_point_id ,
              orig_system_reference,
              address3,
              address4 ,
	      CUSTOM_COLUMN1,
	      CUSTOM_COLUMN2,
	      CUSTOM_COLUMN3,
	      CUSTOM_COLUMN4,
	      CUSTOM_COLUMN5,
	      CUSTOM_COLUMN6,
	      CUSTOM_COLUMN7,
	      CUSTOM_COLUMN8,
	      CUSTOM_COLUMN9,
	      CUSTOM_COLUMN10,
	      CUSTOM_COLUMN11,
	      CUSTOM_COLUMN12,
	      CUSTOM_COLUMN13,
	      CUSTOM_COLUMN14,
	      CUSTOM_COLUMN15,
	      CUSTOM_COLUMN16,
	      CUSTOM_COLUMN17,
	      CUSTOM_COLUMN18,
	      CUSTOM_COLUMN19,
	      CUSTOM_COLUMN20,
	      CUSTOM_COLUMN21,
	      CUSTOM_COLUMN22,
	      CUSTOM_COLUMN23,
	      CUSTOM_COLUMN24,
	      CUSTOM_COLUMN25,
              FAX_NUMBER
            from ams_hz_b2c_mapping_v
            where  enabled_flag = '||''''||'Y'||''''||
             ' and import_list_header_id =' || p_incl_object_id   ||
             ' and nvl(party_id, import_source_line_id) in (' ;
            write_to_act_log('Insert statement constructed for imported B2B list', 'LIST', g_list_header_id,'LOW');
        end if;
   end if;
   l_no_of_chunks  := ceil(length(x_include_sql)/2000 );
   if l_no_of_chunks is not null then
      for i in 1 ..l_no_of_chunks
        loop
           WRITE_TO_ACT_LOG(substrb(x_include_sql,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
      end loop;
   end if;
/*
  commented OUT NOCOPY because of performance reasons

   x_std_sql := ' select party_idl_list_entry_source_type
                  ' from ams_imp_source_lines
                     where  import_list_header_id = ' ||   p_incl_object_id   ;
*/
   x_std_sql := ' select nvl(party_id,import_source_line_id)
                  from ams_imp_source_lines
                  where  import_list_header_id = ' ||   p_incl_object_id   ||
             '  and    nvl(duplicate_flag,' ||''''||'N'||''''||') = '||
                                              ''''||'N'||'''' ;
  write_to_act_log('Execution of procedure process_imph completed.', 'LIST', g_list_header_id,'LOW');
END process_imph ;

PROCEDURE process_list
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              ) is
l_no_of_chunks  number;
BEGIN
    write_to_act_log('Executing process_list since list has been included in list/target group selections.', 'LIST', g_list_header_id,'LOW');
    if p_list_action_type  = 'INCLUDE' then
        --bmuthukr for lpo
       --get_count(p_list_select_action_id,p_order_number,'LIST',null);
       x_include_sql := 'insert into ams_list_entries
        (list_header_id ,
         list_entry_id,
         object_version_number,
         source_code                     ,
         source_code_for_id              ,
         arc_list_used_by_source         ,
         arc_list_select_action_from     ,
         pin_code                        ,
         view_application_id             ,
         manually_entered_flag           ,
         marked_as_random_flag           ,
         marked_as_duplicate_flag        ,
         part_of_control_group_flag      ,
         exclude_in_triggered_list_flag  ,
         enabled_flag ,
         LIST_SELECT_ACTION_FROM_NAME,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         list_entry_source_system_id,
         list_entry_source_system_type,
         list_select_action_id,
 	 Rank,
         SUFFIX,
         FIRST_NAME,
         LAST_NAME,
         CUSTOMER_NAME,
         TITLE,
         ADDRESS_LINE1,
         ADDRESS_LINE2,
         CITY,
         STATE,
         ZIPCODE,
         COUNTRY,
         FAX,
         PHONE,
         EMAIL_ADDRESS,
         CUSTOMER_ID                              ,
         LIST_SOURCE                              ,
         PARTY_ID                                 ,
         PARENT_PARTY_ID                          ,
         IMP_SOURCE_LINE_ID                       ,
         COL1,
         COL2,
         COL3,
         COL4,
         COL5,
         COL6,
         COL7,
         COL8,
         COL9,
         COL10,
         COL11,
         COL12,
         COL13,
         COL14,
         COL15,
         COL16,
         COL17,
         COL18,
         COL19,
         COL20,
         COL21,
         COL22,
         COL23,
         COL24,
         COL25,
         COL26,
         COL27,
         COL28,
         COL29,
         COL30,
         COL31,
         COL32,
         COL33,
         COL34,
         COL35,
         COL36,
         COL37,
         COL38,
         COL39,
         COL40,
         COL41,
         COL42,
         COL43,
         COL44,
         COL45,
         COL46,
         COL47,
         COL48,
         COL49,
         COL50,
         COL51,
         COL52,
         COL53,
         COL54,
         COL55,
         COL56,
         COL57,
         COL58,
         COL59,
         COL60,
         COL61,
         COL62,
         COL63,
         COL64,
         COL65,
         COL66,
         COL67,
         COL68,
         COL69,
         COL70,
         COL71,
         COL72,
         COL73,
         COL74,
         COL75,
         COL76,
         COL77,
         COL78,
         COL79,
         COL80,
         COL81,
         COL82,
         COL83,
         COL84,
         COL85,
         COL86,
         COL87,
         COL88,
         COL89,
         COL90,
         COL91,
         COL92,
         COL93,
         COL94,
         COL95,
         COL96,
         COL97,
         COL98,
         COL99,
         COL100,
         COL101,
         COL102,
         COL103,
         COL104,
         COL105,
         COL106,
         COL107,
         COL108,
         COL109,
         COL110,
         COL111,
         COL112,
         COL113,
         COL114,
         COL115,
         COL116,
         COL117,
         COL118,
         COL119,
         COL120,
         COL121,
         COL122,
         COL123,
         COL124,
         COL125,
         COL126,
         COL127,
         COL128,
         COL129,
         COL130,
         COL131,
         COL132,
         COL133,
         COL134,
         COL135,
         COL136,
         COL137,
         COL138,
         COL139,
         COL140,
         COL141,
         COL142,
         COL143,
         COL144,
         COL145,
         COL146,
         COL147,
         COL148,
         COL149,
         COL150,
         COL151,
         COL152,
         COL153,
         COL154,
         COL155,
         COL156,
         COL157,
         COL158,
         COL159,
         COL160,
         COL161,
         COL162,
         COL163,
         COL164,
         COL165,
         COL166,
         COL167,
         COL168,
         COL169,
         COL170,
         COL171,
         COL172,
         COL173,
         COL174,
         COL175,
         COL176,
         COL177,
         COL178,
         COL179,
         COL180,
         COL181,
         COL182,
         COL183,
         COL184,
         COL185,
         COL186,
         COL187,
         COL188,
         COL189,
         COL190,
         COL191,
         COL192,
         COL193,
         COL194,
         COL195,
         COL196,
         COL197,
         COL198,
         COL199,
         COL200,
         COL201,
         COL202,
         COL203,
         COL204,
         COL205,
         COL206,
         COL207,
         COL208,
         COL209,
         COL210,
         COL211,
         COL212,
         COL213,
         COL214,
         COL215,
         COL216,
         COL217,
         COL218,
         COL219,
         COL220,
         COL221,
         COL222,
         COL223,
         COL224,
         COL225,
         COL226,
         COL227,
         COL228,
         COL229,
         COL230,
         COL231,
         COL232,
         COL233,
         COL234,
         COL235,
         COL236,
         COL237,
         COL238,
         COL239,
         COL240,
         COL241,
         COL242,
         COL243,
         COL244,
         COL245,
         COL246,
         COL247,
         COL248,
         COL249,
         COL250 ,
         COL251     ,
         COL252     ,
         COL253     ,
         COL254     ,
         COL256     ,
         COL255     ,
         COL257     ,
         COL258     ,
         COL259     ,
         COL260     ,
         COL261     ,
         COL262     ,
         COL263     ,
         COL264     ,
         COL265     ,
         COL266     ,
         COL267     ,
         COL268     ,
         COL269     ,
         COL270     ,
         COL271     ,
         COL272     ,
         COL273     ,
         COL274     ,
         COL275     ,
         COL276     ,
         COL277     ,
         COL278     ,
         COL279     ,
         COL280     ,
         COL281     ,
         COL282     ,
         COL283     ,
         COL284     ,
         COL285     ,
         COL286     ,
         COL287     ,
         COL288     ,
         COL289     ,
         COL290     ,
         COL291     ,
         COL292     ,
         COL293     ,
         COL294     ,
         COL295     ,
         COL296     ,
         COL297     ,
         COL298     ,
         COL299     ,
         COL300     ,
              NOTES                                    ,
              VEHICLE_RESPONSE_CODE                   ,
              SALES_AGENT_EMAIL_ADDRESS               ,
              RESOURCE_ID                              ,
              location_id ,
              contact_point_id ,
              orig_system_reference,
              CUSTOM_COLUMN1,
              CUSTOM_COLUMN2,
              CUSTOM_COLUMN3,
              CUSTOM_COLUMN4,
              CUSTOM_COLUMN5,
              CUSTOM_COLUMN6,
              CUSTOM_COLUMN7,
              CUSTOM_COLUMN8,
              CUSTOM_COLUMN9,
              CUSTOM_COLUMN10,
              CUSTOM_COLUMN11,
              CUSTOM_COLUMN12,
              CUSTOM_COLUMN13,
              CUSTOM_COLUMN14,
              CUSTOM_COLUMN15,
              CUSTOM_COLUMN16,
              CUSTOM_COLUMN17,
              CUSTOM_COLUMN18,
              CUSTOM_COLUMN19,
              CUSTOM_COLUMN20,
              CUSTOM_COLUMN21,
              CUSTOM_COLUMN22,
              CUSTOM_COLUMN23,
              CUSTOM_COLUMN24,
              CUSTOM_COLUMN25
        )
        select ' ||
         p_action_used_by_id ||',
         ams_list_entries_s.nextval,
         1 ,' ||
         ''''||'NONE'                ||''''     || ','||
        0                           || ','     ||
        ''''||'NONE'                ||''''     || ','||
        ''''||'LIST'                ||''''     || ','||
        'ams_list_entries_s.currval'|| ','||
        530              || ','||
        ''''||'N'  ||''''|| ','||
        ''''||'N'  ||''''|| ','||
        ''''||'N'  ||''''|| ','||
        ''''||'N'  ||''''|| ','||
        ''''||'N'  ||''''|| ','||
        ''''||'Y'  ||''''||',
         list_entry_source_system_id||list_entry_source_system_type,
         sysdate,
         last_updated_by,
         sysdate,
         created_by,
         last_update_login,
         list_entry_source_system_id,
         list_entry_source_system_type, '||
         p_list_select_action_id   ||','||
         p_rank   ||',
         SUFFIX,
         FIRST_NAME,
         LAST_NAME,
         CUSTOMER_NAME,
         TITLE,
         ADDRESS_LINE1,
         ADDRESS_LINE2,
         CITY,
         STATE,
         ZIPCODE,
          COUNTRY,
          FAX,
          PHONE,
          EMAIL_ADDRESS,
          CUSTOMER_ID                              ,
          LIST_SOURCE                              ,
          PARTY_ID                                 ,
          PARENT_PARTY_ID                          ,
          IMP_SOURCE_LINE_ID                       ,
          COL1,
          COL2,
          COL3,
          COL4,
          COL5,
          COL6,
          COL7,
          COL8,
          COL9,
          COL10,
          COL11,
          COL12,
          COL13,
          COL14,
          COL15,
          COL16,
          COL17,
          COL18,
          COL19,
          COL20,
          COL21,
          COL22,
          COL23,
          COL24,
          COL25,
          COL26,
          COL27,
          COL28,
          COL29,
          COL30,
          COL31,
          COL32,
          COL33,
          COL34,
          COL35,
          COL36,
          COL37,
          COL38,
          COL39,
          COL40,
          COL41,
          COL42,
          COL43,
          COL44,
          COL45,
          COL46,
          COL47,
          COL48,
          COL49,
          COL50,
          COL51,
          COL52,
          COL53,
          COL54,
          COL55,
          COL56,
          COL57,
          COL58,
          COL59,
          COL60,
          COL61,
          COL62,
          COL63,
          COL64,
          COL65,
          COL66,
          COL67,
          COL68,
          COL69,
          COL70,
          COL71,
          COL72,
          COL73,
          COL74,
          COL75,
          COL76,
          COL77,
          COL78,
          COL79,
          COL80,
          COL81,
          COL82,
          COL83,
          COL84,
          COL85,
          COL86,
          COL87,
          COL88,
          COL89,
          COL90,
          COL91,
          COL92,
          COL93,
          COL94,
          COL95,
          COL96,
          COL97,
          COL98,
          COL99,
          COL100,
          COL101,
          COL102,
          COL103,
          COL104,
          COL105,
          COL106,
          COL107,
          COL108,
          COL109,
          COL110,
          COL111,
          COL112,
          COL113,
          COL114,
          COL115,
          COL116,
          COL117,
          COL118,
          COL119,
          COL120,
          COL121,
          COL122,
          COL123,
          COL124,
          COL125,
          COL126,
          COL127,
          COL128,
          COL129,
          COL130,
          COL131,
          COL132,
          COL133,
          COL134,
          COL135,
          COL136,
          COL137,
          COL138,
          COL139,
          COL140,
          COL141,
          COL142,
          COL143,
          COL144,
          COL145,
          COL146,
          COL147,
          COL148,
          COL149,
          COL150,
          COL151,
          COL152,
          COL153,
          COL154,
          COL155,
          COL156,
          COL157,
          COL158,
          COL159,
          COL160,
          COL161,
          COL162,
          COL163,
          COL164,
          COL165,
          COL166,
          COL167,
          COL168,
          COL169,
          COL170,
          COL171,
          COL172,
          COL173,
          COL174,
          COL175,
          COL176,
          COL177,
          COL178,
          COL179,
          COL180,
          COL181,
          COL182,
          COL183,
          COL184,
          COL185,
          COL186,
          COL187,
          COL188,
          COL189,
          COL190,
          COL191,
          COL192,
          COL193,
          COL194,
          COL195,
          COL196,
          COL197,
          COL198,
          COL199,
          COL200,
          COL201,
          COL202,
          COL203,
          COL204,
          COL205,
          COL206,
          COL207,
          COL208,
          COL209,
          COL210,
          COL211,
          COL212,
          COL213,
          COL214,
          COL215,
          COL216,
          COL217,
          COL218,
          COL219,
          COL220,
          COL221,
          COL222,
          COL223,
          COL224,
          COL225,
          COL226,
          COL227,
          COL228,
          COL229,
          COL230,
          COL231,
          COL232,
          COL233,
          COL234,
          COL235,
          COL236,
          COL237,
          COL238,
          COL239,
          COL240,
          COL241,
          COL242,
          COL243,
          COL244,
          COL245,
          COL246,
          COL247,
          COL248,
          COL249,
          COL250 ,
          COL251 ,
          COL252 ,
          COL253 ,
          COL254 ,
          COL256 ,
          COL255 ,
          COL257 ,
          COL258 ,
          COL259 ,
          COL260 ,
          COL261 ,
          COL262 ,
          COL263 ,
          COL264 ,
          COL265 ,
          COL266 ,
          COL267 ,
          COL268 ,
          COL269 ,
          COL270 ,
          COL271 ,
          COL272 ,
          COL273 ,
          COL274 ,
          COL275 ,
          COL276 ,
          COL277 ,
          COL278 ,
          COL279 ,
          COL280 ,
          COL281 ,
          COL282 ,
          COL283 ,
          COL284 ,
          COL285 ,
          COL286 ,
          COL287 ,
          COL288 ,
          COL289 ,
          COL290 ,
          COL291 ,
          COL292 ,
          COL293 ,
          COL294 ,
          COL295 ,
          COL296 ,
          COL297 ,
          COL298 ,
          COL299 ,
          COL300     ,
              NOTES                                    ,
              VEHICLE_RESPONSE_CODE                   ,
              SALES_AGENT_EMAIL_ADDRESS               ,
              RESOURCE_ID                              ,
              location_id ,
              contact_point_id ,
              orig_system_reference,
              CUSTOM_COLUMN1,
              CUSTOM_COLUMN2,
              CUSTOM_COLUMN3,
              CUSTOM_COLUMN4,
              CUSTOM_COLUMN5,
              CUSTOM_COLUMN6,
              CUSTOM_COLUMN7,
              CUSTOM_COLUMN8,
              CUSTOM_COLUMN9,
              CUSTOM_COLUMN10,
              CUSTOM_COLUMN11,
              CUSTOM_COLUMN12,
              CUSTOM_COLUMN13,
              CUSTOM_COLUMN14,
              CUSTOM_COLUMN15,
              CUSTOM_COLUMN16,
              CUSTOM_COLUMN17,
              CUSTOM_COLUMN18,
              CUSTOM_COLUMN19,
              CUSTOM_COLUMN20,
              CUSTOM_COLUMN21,
              CUSTOM_COLUMN22,
              CUSTOM_COLUMN23,
              CUSTOM_COLUMN24,
              CUSTOM_COLUMN25
       from ams_list_entries
       where   list_header_id = ' ||   p_incl_object_id   ||
        '  and    nvl(enabled_flag,' ||''''||'N'||''''||') = '||
                                              ''''||'Y'||'''' ||
       ' and list_entry_source_system_id in (' ;

    /*Commented OUT NOCOPY due to perf  reasons
       and list_entry_source_system_id||list_entry_source_system_type in (' ;
   */
       INSERT INTO ams_list_src_type_usages
       (
          list_source_type_usage_id
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,object_version_number
          ,source_type_code
          ,list_header_id
        )
        select
          AMS_LIST_SRC_TYPE_USAGES_S.NEXTVAL,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.USER_ID,
          1,
          als.source_type_code,
          p_action_used_by_id
       from ams_list_src_type_usages  als
       where not exists
          ( select  'x'
            from  ams_list_src_type_usages  als1
            where als1.list_header_id = p_action_used_by_id -- p_incl_object_id
              and als.source_type_code = als1.source_type_code )
       and als.list_header_id = p_incl_object_id ;
   write_to_act_log('Insert statement constructed based on the list included.', 'LIST', g_list_header_id,'LOW');
   l_no_of_chunks  := ceil(length(x_include_sql)/2000 );
   for i in 1 ..l_no_of_chunks
     loop
        WRITE_TO_ACT_LOG(substrb(x_include_sql,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
   end loop;
   end if;
   --     WRITE_TO_ACT_LOG('Outside Include ');
/*
  Commented OUT NOCOPY  because of preformance issues
  list_entry_source_syetem_type is not selected
   x_std_sql := ' select list_entry_source_system_id||
                     list_entry_source_system_type from ams_list_entries
                     where   list_header_id = ' ||   p_incl_object_id   ||
                     ' and     enabled_flag = ' || ''''||'Y' || '''' ;
*/
   x_std_sql := ' select list_entry_source_system_id
                     from ams_list_entries
                     where   list_header_id = ' ||   p_incl_object_id   ||
                     ' and     enabled_flag = ' || ''''||'Y' || '''' ;
  write_to_act_log('Execution of procedure process_list completed', 'LIST', g_list_header_id,'LOW');
END process_list ;

PROCEDURE process_manual
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
             ) IS
BEGIN
     process_list
             (p_action_used_by_id => p_action_used_by_id,
              p_incl_object_id => p_incl_object_id,
              p_list_action_type  => p_list_action_type,
              p_list_select_action_id   => p_list_select_action_id,
              p_order_number   => p_order_number,
              p_rank   => p_rank,
              p_include_control_group  => p_include_control_group,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data,
              x_return_status  => x_return_status,
              x_std_sql => x_std_sql ,
              x_include_sql  => x_include_sql  );
END;
PROCEDURE process_standard
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2 ) is
BEGIN
     process_list
             (p_action_used_by_id => p_action_used_by_id,
              p_incl_object_id => p_incl_object_id,
              p_list_action_type  => p_list_action_type,
              p_list_select_action_id   => p_list_select_action_id,
              p_order_number   => p_order_number,
              p_rank   => p_rank,
              p_include_control_group  => p_include_control_group,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data,
              x_return_status  => x_return_status,
              x_std_sql => x_std_sql ,
              x_include_sql  => x_include_sql  );
END;
PROCEDURE check_char(p_input_string          in  varchar2
                    ,p_comma_valid  in varchar2
                    ,p_valid_string OUT NOCOPY varchar2) IS
BEGIN
   if p_input_string = ' ' then
      p_valid_string :='Y';
   elsif p_input_string = fnd_global.newline then
      p_valid_string :='Y';
   elsif p_input_string = fnd_global.tab then
      p_valid_string :='Y';
   elsif p_input_string = '
' then
      p_valid_string :='Y';
   elsif p_input_string = ',' then
      if p_comma_valid = 'Y' then
         p_valid_string :='Y';
      else
         p_valid_string :='N';
      end if;
   else
      p_valid_string :='N';
   end if;
exception
    when others then
      write_to_act_log('check_char  sqlerrm : ' || sqlerrm, 'LIST', g_list_header_id );
END check_char;

PROCEDURE form_sql_statement(p_select_statement in varchar2,
                             p_select_add_statement in varchar2,
                             p_master_type        in varchar2,
                             p_child_types     in child_type,
                             p_from_string in sql_string_4K,
                             p_action_used_by_id  in number,
                             p_list_select_action_id  in number,
                             p_list_action_type  in varchar2,
                             p_order_number in number,
                             p_rank  in number,
                             x_final_string OUT NOCOPY varchar2
                             ) is
-- child_type      IS TABLE OF VARCHAR2(80) INDEX  BY BINARY_INTEGER;
l_data_source_types varchar2(2000);
l_field_col_tbl JTF_VARCHAR2_TABLE_100;
l_source_col_tbl JTF_VARCHAR2_TABLE_100;
l_view_tbl JTF_VARCHAR2_TABLE_100;
l_source_col_dt_tbl JTF_VARCHAR2_TABLE_100;
cursor c_master_source_type is
select source_object_name , source_object_name || '.' || source_object_pk_field ,  list_source_type_id
from ams_list_src_types
where source_type_code = p_master_type;
l_master_source_type_id number;
cursor c_child_source_type (l_child_src_type varchar2 )is
select a.source_object_name ,
       a.source_object_name || '.' || b.sub_source_type_pk_column
       ,b.master_source_type_pk_column
from ams_list_src_types  a, ams_list_src_type_assocs b
where a.source_type_code = l_child_src_type
and   b.sub_source_type_id = a.list_source_type_id
and   b.master_source_type_id =  l_master_source_type_id ;
l_count                   number;
l_master_object_name      varchar2(4000);
l_child_object_name       varchar2(4000);
l_master_primary_key      varchar2(1000);
l_child_primary_key       varchar2(32767);
l_from_clause             varchar2(32767);
l_where_clause            varchar2(32767);
l_select_clause           varchar2(32767);
l_insert_clause           varchar2(32767);
l_final_sql               varchar2(32767);
l_insert_sql              varchar2(32767);
l_no_of_chunks            number;
l_master_fkey             Varchar2(1000);
l_dummy_primary_key      varchar2(1000);

l_created_by                NUMBER;

CURSOR cur_get_created_by (x_list_header_id IN NUMBER) IS
      SELECT created_by
      FROM ams_list_headers_all
      WHERE list_header_id= x_list_header_id;

begin
    WRITE_TO_ACT_LOG('Execution of procedure form_sql_statement started' || p_master_type, 'LIST', g_list_header_id,'LOW');
open  c_master_source_type;
fetch c_master_source_type into l_master_object_name , l_master_primary_key, l_master_source_type_id;
close c_master_source_type;
   write_to_act_log('Master object name is ' || p_master_type||' , primary key is '||l_master_primary_key||' ,l_master_source_type_id is '||l_master_source_type_id, 'LIST', g_list_header_id,'LOW');
     --WRITE_TO_ACT_LOG('form_sql_statement->after master' || l_master_object_name);
l_from_clause :=  ' FROM ' || l_master_object_name;
l_data_source_types := ' ('|| ''''|| p_master_type ||'''';
l_where_clause := 'where 1 = 1 ';

l_count  := p_child_types.count();
if l_count > 0  then
   for i in 1..p_child_types.last
   loop
      l_data_source_types := l_data_source_types || ','|| ''''
                             || p_child_types(i)||'''' ;
      open  c_child_source_type(p_child_types(i));
      fetch c_child_source_type into l_child_object_name , l_child_primary_key
                                     ,l_master_fkey;
      l_dummy_primary_key := '';
      if l_master_fkey is not null then
         l_dummy_primary_key     := l_master_object_name || '.'|| l_master_fkey;
      else
         l_dummy_primary_key      := l_master_primary_key;
      end if;
      l_from_clause := l_from_clause || ','|| l_child_object_name ;
      l_where_clause := l_where_clause || 'and '
                              ||l_dummy_primary_key || ' = '
                        || l_child_primary_key || '(+)';
      close c_child_source_type;
   end loop;
end if;
l_data_source_types := l_data_source_types || ') ' ;


  /* change made by savio here for bug 3916350  added condition AND   c.list_source_type = ''TARGET'' */
 EXECUTE IMMEDIATE
     'BEGIN
      SELECT b.field_column_name ,
               c.source_object_name,
               b.source_column_name,
               b.field_data_type
        BULK COLLECT INTO :1 ,:2  ,:3 ,:4
        FROM ams_list_src_fields b, ams_list_src_types c
        WHERE b.list_source_type_id = c.list_source_type_id
	AND   c.list_source_type = ''TARGET''
          and b.DE_LIST_SOURCE_TYPE_CODE IN  '|| l_data_source_types ||
          ' AND b.ROWID >= (SELECT MAX(a.ROWID)
                            FROM ams_list_src_fields a
                           WHERE a.field_column_name= b.field_column_name
	                    AND  a.DE_LIST_SOURCE_TYPE_CODE IN '
                                 || l_data_source_types || ') ;
      END; '
  USING OUT l_field_col_tbl ,OUT l_view_tbl , OUT l_source_col_tbl ,OUT l_source_col_dt_tbl;
for i in 1 .. l_field_col_tbl.last
loop
  l_insert_clause  := l_insert_clause || ' ,' || l_field_col_tbl(i) ;
  if l_source_col_dt_tbl(i) = 'DATE' then
     l_select_clause  := l_select_clause || ' ,' ||
                      'to_char('||l_view_tbl(i) || '.'||l_source_col_tbl(i)||','||''''||'DD-MM-RRRR'||''''||')' ;
  else
     l_select_clause  := l_select_clause || ' ,' ||
                      l_view_tbl(i) || '.'||l_source_col_tbl(i) ;
  end if;
end loop;
  write_to_act_log('Insert clause formed is '||l_insert_clause, 'LIST', g_list_header_id,'LOW');
  write_to_act_log('Select clause formed is '||l_insert_clause, 'LIST', g_list_header_id,'LOW');


l_created_by := 0;

       OPEN cur_get_created_by(p_action_used_by_id);

       FETCH cur_get_created_by INTO l_created_by;
       CLOSE cur_get_created_by;

  l_insert_sql := 'insert into ams_list_entries        '||
                   '( LIST_SELECT_ACTION_FROM_NAME,    '||
                   '  LIST_ENTRY_SOURCE_SYSTEM_ID ,    '||
                   '  LIST_ENTRY_SOURCE_SYSTEM_TYPE,   '||
                   ' list_select_action_id ,           '||
                   ' rank                  ,           '||
                   ' list_header_id,last_update_date,  '||
                   ' last_updated_by,creation_date,created_by,'||
                   'list_entry_id, '||
                   'object_version_number, ' ||
                   'source_code                     , ' ||
                   'source_code_for_id              , ' ||
                   'arc_list_used_by_source         , ' ||
                   'arc_list_select_action_from     , ' ||
                   'pin_code                        , ' ||
                   'view_application_id             , ' ||
                   'manually_entered_flag           , ' ||
                   'marked_as_random_flag           , ' ||
                   'marked_as_duplicate_flag        , ' ||
                   'part_of_control_group_flag      , ' ||
                   'exclude_in_triggered_list_flag  , ' ||
                   'enabled_flag ' ||
                   l_insert_clause || ' ) ' ||

                   'select ' ||
                   l_master_primary_key ||','||
                   l_master_primary_key ||','||
                   ''''||p_master_type||''''||','||
                   p_list_select_action_id || ',' ||
                   p_rank                  || ',' ||
                   to_char(p_action_used_by_id )|| ',' ||''''||
                   to_char(sysdate )|| ''''||','||
                   to_char(FND_GLOBAL.login_id )|| ',' ||''''||
                   to_char(sysdate )|| ''''||','||
                   to_char(nvl(l_created_by, FND_GLOBAL.login_id) )|| ',' ||
                   'ams_list_entries_s.nextval'  || ','||
                   1 || ','||
                   ''''||'NONE'                ||''''     || ','||
                   0                           || ','     ||
                   ''''||'NONE'                ||''''     || ','||
                   ''''||'NONE'                ||''''     || ','||
                   'ams_list_entries_s.currval'|| ','||
                   530              || ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'Y'  ||''''||
                   l_select_clause ;

/* commented OUT NOCOPY becuase of performance reasons
     l_final_sql := l_insert_sql || '  ' ||
                  l_from_clause ||  '  '||
                  l_where_clause   || ' and  ' ||
                   l_master_primary_key ||
                     '||  '||''''||p_master_type ||''''|| ' in  ( ' ;
*/
     l_final_sql := l_insert_sql || '  ' ||
                  l_from_clause ||  '  '||
                  l_where_clause   || ' and  ' ||
                   l_master_primary_key|| ' in  ( ' ;
     x_final_string := l_final_sql;
  WRITE_TO_ACT_LOG('SQL statement formed finally ', 'LIST', g_list_header_id,'LOW');
     l_no_of_chunks  := ceil(length(l_final_sql)/2000 );
     for i in 1 ..l_no_of_chunks
     loop
        WRITE_TO_ACT_LOG(substrb(l_final_sql,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
     end loop;
exception
   when others then
     write_to_act_log('Error while executing procedure form_sql_statement '||sqlcode||'  '||sqlerrm , 'LIST', g_list_header_id,'HIGH');
end form_sql_statement;

PROCEDURE process_insert_sql(p_select_statement in varchar2,
                             p_select_add_statement in varchar2,
                             p_master_type        in varchar2,
                             p_child_types     in child_type,
                             p_from_string in sql_string_4K,
                             p_action_used_by_id  in number,
                             p_list_select_action_id  in number,
                             p_list_action_type  in varchar2,
                             p_order_number in number,
                             p_rank  in number,
                             x_std_sql OUT NOCOPY varchar2 ,
                             x_include_sql OUT NOCOPY varchar2
                             ) is
l_final_sql   varchar2(32767);
l_insert_sql varchar2(32767);
l_insert_sql1 varchar2(32767);
l_table_name  varchar2(80) := ' ams_list_tmp_entries ';
BEGIN
  write_to_act_log('Executing process_insert_sql procedure', 'LIST', g_list_header_id,'LOW');
/*
  if p_list_action_type <> 'INCLUDE' then
    l_table_name := ' ams_list_delete_tmp_entries ';
  end if;
   l_insert_sql := 'insert into '|| l_table_name  || ' '||
                   '(list_entry_source_key, ' ||
                   ' list_entry_source_id,list_entry_source_type, ' ||
                   ' list_select_action_id ,' ||
                   ' list_header_id,last_update_date, ' ||
                   ' last_updated_by,creation_date,created_by,'||
                   ' rank) '||
                   p_select_statement || '  '||
                   p_select_add_statement || ' ,' ||
                   p_list_select_action_id || ',' ||
                   to_char(p_action_used_by_id )|| ',' ||''''||
                   to_char(sysdate )|| ''''||','||
                   to_char(FND_GLOBAL.login_id )|| ',' ||''''||
                   to_char(sysdate )|| ''''||','||
                   to_char(FND_GLOBAL.login_id )|| ',' ||
                   to_char( nvl(p_rank,9999999));
  --write_to_act_log(l_insert_sql);
*/
  l_insert_sql := p_select_statement ;
  for i in 1 .. p_from_string.last
  loop
--    write_to_act_log('length p_from_string(i)= '||lengthb(p_from_string(i)), 'LIST', g_list_header_id,'LOW');
--    write_to_act_log(p_from_string(i), 'LIST', g_list_header_id,'LOW');
    l_insert_sql  := l_insert_sql || p_from_string(i);
  end loop;
  x_std_sql := l_insert_sql;

  write_to_act_log('Calling form_sql_statement', 'LIST', g_list_header_id,'LOW');
  if p_list_action_type = 'INCLUDE' then
          form_sql_statement(p_select_statement ,
                             p_select_add_statement ,
                             p_master_type        ,
                             p_child_types     ,
                             p_from_string ,
                             p_action_used_by_id  ,
                             p_list_select_action_id  ,
                             p_list_action_type  ,
                             p_order_number ,
                             p_rank  ,
                             l_final_sql
                             ) ;
  end if;
  x_include_sql := l_final_sql;
  write_to_act_log('Procedure process_insert_sql completed', 'LIST', g_list_header_id,'LOW');
exception
   when others then
   write_to_act_log('Error while executing procedure process_insert_sql  '||sqlcode||'   '||sqlerrm , 'LIST', g_list_header_id,'HIGH');
END process_insert_sql;

PROCEDURE validate_sql_string
             (p_sql_string     in sql_string
              ,p_search_string in varchar2
              ,p_comma_valid   in varchar2
              ,x_found         OUT NOCOPY varchar2
              ,x_position      OUT NOCOPY number
              ,x_counter       OUT NOCOPY number
              )  IS
l_sql_string_1           varchar2(2000) := ' ';
l_sql_string_2           varchar2(2000) ;
l_concat_string          varchar2(4000) ;
l_valid_string           varchar2(1) := 'N';
l_position               varchar2(200);
BEGIN
--  write_to_act_log('FIRST LINE IN validate_sql_string  ', 'LIST', g_list_header_id );
  /* Searching of the string is done by concatenating the two strings of
     2000 each   gjoby more expln needed
  */
  x_found    := 'N';
  l_sql_string_1  := lpad(l_sql_string_1,2000,' ');
--  write_to_act_log('length(l_sql_string_1) =  '||length(l_sql_string_1), 'LIST', g_list_header_id );
--  write_to_act_log('p_sql_string.count  =  '||p_sql_string.count, 'LIST', g_list_header_id );

  for i in 1 .. p_sql_string.last
  loop

     l_sql_string_2 := p_sql_string(i);
--  write_to_act_log('length(l_sql_string_2) =  '||length(l_sql_string_2), 'LIST', g_list_header_id );
--  write_to_act_log('p_search_string  =  '||p_search_string, 'LIST', g_list_header_id );
     if p_search_string = 'FROM' then
        l_concat_string := upper(l_sql_string_1) || upper(l_sql_string_2);
--  write_to_act_log('IF length(l_concat_string) =  '||length(l_concat_string), 'LIST', g_list_header_id );
     else
        l_concat_string := l_sql_string_1 || l_sql_string_2;
--  write_to_act_log('ELSE length(l_concat_string) =  '||length(l_concat_string), 'LIST', g_list_header_id );
     end if;

     x_position := instrb(l_concat_string ,p_search_string);
--  write_to_act_log('x_position =   '||to_char(x_position), 'LIST', g_list_header_id );
     if x_position > 0 then
        loop
             l_valid_string := 'N' ;
             if x_position = 0 then
                exit;
             else
               check_char
                   (p_input_string=>substrb(l_concat_string, x_position -1, 1)
                    ,p_comma_valid =>p_comma_valid
                    ,p_valid_string=> l_valid_string);
--  write_to_act_log('ELSE check_char l_valid_string  =   '||l_valid_string, 'LIST', g_list_header_id );
               if l_valid_string = 'Y' then
                  check_char
                      (p_input_string=>substrb(l_concat_string,
                                 x_position + length(p_search_string)
                                  , 1)
                       ,p_comma_valid =>p_comma_valid
                       ,p_valid_string=> l_valid_string);
--  write_to_act_log('l_valid_string = Y check_char l_valid_string  =   '||l_valid_string, 'LIST', g_list_header_id );
               end if;
             end if;
             if l_valid_string = 'Y' then
                if x_position > 2000 then
                   x_found    := 'Y';
                   x_counter  := i;
                   x_position := x_position - 2000;
                   exit;
                end if;
                if x_position < 2001 then
                   x_found    := 'Y';
                   x_counter  := i -1 ;
                   exit;
                end if;
             end if;
/*
  write_to_act_log('BEFORE LOOP x_position ', 'LIST', g_list_header_id );
  write_to_act_log('length(l_concat_string) =  '||length(l_concat_string), 'LIST', g_list_header_id );
  write_to_act_log(''||substr(l_concat_string,1,2000), 'LIST', g_list_header_id );
  write_to_act_log(''||substr(l_concat_string,2001,4000), 'LIST', g_list_header_id );
  write_to_act_log('x_position+1  =   '||to_char(x_position+1), 'LIST', g_list_header_id );
  write_to_act_log('p_search_string =   '||p_search_string , 'LIST', g_list_header_id );
*/
              x_position := instrb(l_concat_string ,  p_search_string,x_position+1);
              -- x_position := instrb(l_concat_string , x_position+1, p_search_string);


--  write_to_act_log('AFTER LOOP x_position  =   ', 'LIST', g_list_header_id );
--  write_to_act_log('in LOOP x_position  =   '||x_position, 'LIST', g_list_header_id );
        end loop;
        exit;
     end if;
  l_sql_string_1 := l_sql_string_2;
  end loop;
--  write_to_act_log('LAST LINE IN validate_sql_string  ', 'LIST', g_list_header_id );
exception
    when others then
      write_to_act_log('validate_sql_string sqlerrm : ' || sqlerrm, 'LIST', g_list_header_id );
END validate_sql_string;

PROCEDURE get_child_types (p_sql_string in sql_string,
                           p_start_length      in number,
                           p_start_counter      in number,
                           p_end_length      in number,
                           p_end_counter      in number,
                           p_master_type_id     in number,
                           x_child_types     OUT NOCOPY child_type,
                           x_found     OUT NOCOPY varchar2 ) is


cursor c_mapping_subtypes(p_master_type_id
                          ams_list_src_type_assocs.master_source_type_id%type)
IS
select source_type_code
from   ams_list_src_types a,
       ams_list_src_type_assocs b
where  b.master_source_type_id = p_master_type_id
  and  b.sub_source_type_id  = a.list_source_type_id
and    b.enabled_flag = 'Y'
and    a.enabled_flag = 'Y'
and  exists (select 'x' from ams_list_src_fields
                 where list_source_type_id = b.sub_source_type_id
                   and field_column_name is not null) ;

p_mapping_subtype_rec c_mapping_subtypes%rowtype;
l_counter number :=0;
l_child_count number :=0;
l_position         number;
l_found            varchar2(1) := 'N';
l_sql_string    sql_string;

BEGIN
  for i in 1 .. p_sql_string.last
  loop
    l_sql_string(i) := p_sql_string(i);

    if p_start_counter > i then
      l_sql_string(i) := substrb(lpad(' ',2000,' '),1,2000);
    elsif p_start_counter = i then
      l_sql_string(i) := substrb(lpad(' ',p_start_length -1 ,' ')||
                         substrb(l_sql_string(i),p_start_length ),1,2000);
    end if;
    if p_end_counter < i then
      l_sql_string(i) := substrb(lpad(' ',2000,' '),1,2000);
    elsif p_end_counter = i then
      l_sql_string(i) := substrb(rpad(substrb(l_sql_string(i),1,p_end_length ),2000,' '),1,2000);

    end if;

  end loop;
  open c_mapping_subtypes(p_master_type_id);
  loop
  fetch c_mapping_subtypes
     into p_mapping_subtype_rec;
  exit when c_mapping_subtypes%notfound;
/*
     validate_sql_string(p_sql_string => l_sql_string ,
                      p_search_string => ''''||
                                         p_mapping_subtype_rec.source_type_code
                                         ||'''',
                      p_comma_valid   => 'Y',
                      x_found    => l_found,

                      x_position =>l_position,
                      x_counter => l_counter) ;
      if l_found = 'Y' then*
*/
         l_child_count := l_child_count +1;
         x_found := 'Y' ;
         x_child_types(l_child_count) := p_mapping_subtype_rec.source_type_code;


--      end if;
  end loop;

  close c_mapping_subtypes;

      --l_found := 'Y' ;
      --l_child_count := l_child_count +1;
      --x_found := 'Y' ;
      --x_child_types(l_child_count) := 'FAX';
END;

procedure process_sql_string( p_sql_string in sql_string,
                              p_start_length in number,
                              p_start_counter in number,
                              p_end_length in number,
                              p_end_counter in number,
                              x_sql_string OUT NOCOPY sql_string ) is
begin
  for i in 1 .. p_sql_string.last
  loop
    x_sql_string(i) := p_sql_string(i);
    if p_start_counter > i then
      x_sql_string(i) := substrb(lpad(' ',2000,' '),1,2000);
    elsif p_start_counter = i then
      x_sql_string(i) := substrb(lpad(' ',p_start_length -1 ,' ')||
                         substrb(x_sql_string(i),p_start_length ),1,2000);
    end if;
    if p_end_counter < i then
      x_sql_string(i) := substrb(lpad(' ',2000,' '),1,2000);
    elsif p_start_counter = i then
      x_sql_string(i) := substrb(rpad(substrb(x_sql_string(i),1,p_end_length ),2000,' '),1,2000);
    end if;
  end loop;
end;

PROCEDURE get_master_types
          (p_sql_string in sql_string,
           p_start_length in number,
           p_start_counter in number,
           p_end_length in number,
           p_end_counter in number,
           x_master_type_id OUT NOCOPY number,
           x_master_type OUT NOCOPY varchar2,
           x_found OUT NOCOPY varchar2,
           x_source_object_name OUT NOCOPY varchar2,
           x_source_object_pk_field  OUT NOCOPY varchar2)   IS
cursor c_mapping_types IS
SELECT list_source_type_id,
       source_type_code,
       source_object_name,
       source_object_pk_field
  FROM ams_list_src_types
 WHERE master_source_type_flag = 'Y'
   AND list_source_type in ('ANALYTICS', 'TARGET');

cursor c_default_mapping_types IS
SELECT a.list_source_type_id,
       a.source_type_code,
       a.source_object_name,
       a.source_object_pk_field
  FROM ams_list_src_types a,ams_list_headers_all b
 WHERE a.master_source_type_flag = 'Y'
   and a.source_type_code = b.list_source_type
   and b.list_header_id = g_list_header_id
   AND a.list_source_type in ('ANALYTICS', 'TARGET');

p_mapping_type_rec c_mapping_types%rowtype;
p_default_mapping_type_rec c_default_mapping_types%rowtype;
l_position         number;
l_counter          number;
l_found            varchar2(1) := 'N';
l_sql_string    sql_string;
BEGIN
  process_sql_string( p_sql_string => p_sql_string ,
                      p_start_length => p_start_length,
                      p_start_counter => p_start_counter,
                      p_end_length => p_end_length,
                      p_end_counter => p_end_counter,
                      x_sql_string => l_sql_string ) ;

  open c_mapping_types;
  loop
  fetch c_mapping_types
     into p_mapping_type_rec;
  exit when c_mapping_types%notfound;
     validate_sql_string(p_sql_string => l_sql_string ,
                      p_search_string => ''''||
                                         p_mapping_type_rec.source_type_code
                                         ||'''',
                      p_comma_valid   => 'Y',
                      x_found    => l_found,
                      x_position =>l_position,
                      x_counter => l_counter) ;
      if l_found = 'Y' then
         x_found := 'Y' ;
         x_master_type_id          := p_mapping_type_rec.list_source_type_id;
         x_master_type             := p_mapping_type_rec.source_type_code;
         x_source_object_name      := p_mapping_type_rec.source_object_name;
         x_source_object_pk_field  := p_mapping_type_rec.source_object_pk_field;
         exit;
      end if;
  end loop;
  close c_mapping_types;
  if l_found = 'Y' then
     null;
  else
     open c_default_mapping_types;
     loop
     fetch c_default_mapping_types
     into p_default_mapping_type_rec;
     exit when c_default_mapping_types%notfound;
         x_found := 'Y' ;
         x_master_type_id          := p_default_mapping_type_rec.list_source_type_id;
         x_master_type             := p_default_mapping_type_rec.source_type_code;
         x_source_object_name      := p_default_mapping_type_rec.source_object_name;
         x_source_object_pk_field  := p_default_mapping_type_rec.source_object_pk_field;
     end loop;
     close c_default_mapping_types;
  end if;
EXCEPTION
       WHEN  others THEN
         write_to_act_log('Error whie executing procedure get_master_types '||sqlcode||'   '||sqlerrm,'LIST', g_list_header_id,'HIGH');
END get_master_types;

PROCEDURE get_condition(p_sql_string in sql_string ,
                        p_search_string     in varchar2,
                        p_comma_valid   in varchar2,
                        x_position OUT NOCOPY number,
                        x_counter OUT NOCOPY number,
                        x_found    OUT NOCOPY varchar2,
                        x_sql_string OUT NOCOPY sql_string_4K) is
l_where_position   number;
l_where_counter   number;
l_counter   number := 0;
l_sql_string      sql_string;
begin
  write_to_act_log('Executing procedure get_condition. Calling validate_sql_string','LIST', g_list_header_id,'LOW');
  validate_sql_string(p_sql_string => p_sql_string ,
                      p_search_string => p_search_string,
                      p_comma_valid   => 'N',
                      x_found    => x_found,
                      x_position =>x_position,
                      x_counter => x_counter) ;

  write_to_act_log('get_condition x_position =  '||x_position||' , x_counter = '||x_counter,'LIST', g_list_header_id,'LOW');
  if x_counter > 0 then
    for i in x_counter .. p_sql_string.last
    loop
      l_counter := l_counter +1;
      write_to_act_log('get_condition length(p_sql_string('||i||'))  =  '||length(p_sql_string(i)),'LIST', g_list_header_id,'LOW');
      x_sql_string(l_counter) := p_sql_string(i);
      if x_counter = i then
         write_to_act_log('get_condition lpad  =  '||length(lpad(substrb(x_sql_string(l_counter), x_position),2000) ),'LIST', g_list_header_id);
         x_sql_string(l_counter) := lpad(substrb(x_sql_string(l_counter), x_position),2000);
      end if;
    end loop;
  end if;
exception
    when others then
      write_to_act_log('Error while executing procedure get_condition ' ||sqlcode||'    '||sqlerrm, 'LIST', g_list_header_id ,'HIGH');
end get_condition;

PROCEDURE process_all_sql  (p_action_used_by_id in number,
                            p_incl_object_id in number,
                            p_list_action_type  in varchar2,
                            p_list_select_action_id   in number,
                            p_order_number   in number,
                            p_rank   in number,
                            p_include_control_group  in varchar2,
                            p_sql_string    in sql_string,
                            p_primary_key   in  varchar2,
                            p_source_object_name in  varchar2,
                            x_msg_count      OUT NOCOPY number,
                            x_msg_data       OUT NOCOPY varchar2,
                            x_return_status  IN OUT NOCOPY VARCHAR2,
                            x_std_sql OUT NOCOPY varchar2 ,
                            x_include_sql OUT NOCOPY varchar2
                            ) is
l_sql_string         sql_string;
l_where_string       sql_string;
-- l_from_string       sql_string;
l_from_string       sql_string_4K;
l_counter            NUMBER := 1;
l_from_position      number;
l_from_counter       number;
l_end_position      number;
l_end_counter       number;
l_order_position      number;
l_order_counter       number;
l_group_position      number;
l_group_counter       number;
l_found              varchar2(1) := 'N';
l_master_type        varchar2(80);
l_master_type_id     number;
l_source_object_name  varchar2(80);
l_source_object_pk_field  varchar2(80);
l_child_types        child_type;
l_select_condition    varchar2(2000);
l_select_add_condition    varchar2(2000);
l_sql_string_v2           varchar2(4000);

--for list processing order..
l_no_of_rows_reqd      number := 0;
l_string varchar2(32767);
--for list processing order..

BEGIN
  /* Validate Sql String will take all the sql statement fragement and
     check if the search string is present. If it is present it will
     return the position of fragement and the counter
  */
  --
  --for i in p_sql_string.first..p_sql_string.last
  --loop
  --   l_string := l_string||p_sql_string(i);
  --end loop;
  --get_count(p_list_select_action_id,p_order_number,'OTHERS',l_string);
  --g_reqd_num_tbl(p_order_number) := l_no_of_rows_reqd;
  --

  l_sql_string := p_sql_string;
  write_to_act_log('Executing process_all_sql to process the sql string','LIST',g_list_header_id,'LOW');
  l_found  := 'N';
  write_to_act_log('Calling validate_sql_string to validate the sql','LIST',g_list_header_id,'LOW');
  validate_sql_string(p_sql_string => l_sql_string ,
                      p_search_string => 'FROM',
                      p_comma_valid   => 'N',
                      x_found    => l_found,
                      x_position =>l_from_position,
                      x_counter => l_from_counter) ;

  if l_found = 'N' then
     write_to_act_log('Validation failed for this SQL string in validate_sql_string procedure'||l_found,'LIST', g_list_header_id,'HIGH');
     FND_MESSAGE.set_name('AMS', 'AMS_LIST_FROM_NOT_FOUND');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  end if;
  write_to_act_log('SQL string validated successfully in validate_sql_string','LIST', g_list_header_id,'LOW');

  l_found  := 'N';
  write_to_act_log('Calling get_master_types','LIST', g_list_header_id,'LOW');
  get_master_types (p_sql_string => l_sql_string,
                    p_start_length => 1,
                    p_start_counter => 1,
                    p_end_length => l_from_position,
                    p_end_counter => l_from_counter,
                    x_master_type_id=> l_master_type_id,
                    x_master_type=> l_master_type,
                    x_found=> l_found,
                    x_source_object_name => l_source_object_name,
                    x_source_object_pk_field  => l_source_object_pk_field);

  if l_found = 'N' then
     write_to_act_log('No master type found','LIST', g_list_header_id,'LOW');
     FND_MESSAGE.set_name('AMS', 'AMS_LIST_NO_MASTER_TYPE');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  end if;

  if p_list_action_type  = 'INCLUDE' then
     l_found  := 'N';
     write_to_act_log('Calling get_child_types','LIST', g_list_header_id,'LOW');
     get_child_types (p_sql_string => l_sql_string,
                      p_start_length => 1,
                      p_start_counter => 1,
                      p_end_length => l_from_position,
                      p_end_counter => l_from_counter,
                      p_master_type_id=> l_master_type_id,
                      x_child_types=> l_child_types,
                      x_found=> l_found);

     if l_found = 'Y' then
         write_to_act_log('No of child types '||l_child_types.count,'LIST', g_list_header_id,'LOW');
         if l_child_types.last > 0 then
            for i in 1 .. l_child_types.last
            loop
               write_to_act_log('Child type '|| l_child_types(i), 'LIST', g_list_header_id,'LOW');
	       write_to_act_log('Calling insert list_mapping usage', 'LIST', g_list_header_id,'LOW');
               insert_list_mapping_usage
                      (p_list_header_id   => p_action_used_by_id,
                       p_source_type_code => l_child_types(i) ) ;
            end loop;
         end if;
     end if;
  end if;

  l_found  := 'N';
  write_to_act_log('Calling get_condition', 'LIST', g_list_header_id,'LOW');
  get_condition(p_sql_string => l_sql_string ,
                p_search_string => 'FROM',
                p_comma_valid   => 'N',
                x_position =>l_from_position,
                x_counter => l_from_counter,
                x_found    => l_found,
                x_sql_string => l_from_string) ;

  /* FOR SQL STATEMENTS  WHICH ARE NOT FROM THE DERIVING MASTER SOURCE TABLE  */
  if p_primary_key is not null then
     l_source_object_pk_field := p_primary_key;
     l_source_object_name     := p_source_object_name ;
  end if;
  l_select_condition := 'SELECT ' ||l_source_object_name||'.'
                        ||l_source_object_pk_field;
                        --||'||'||''''
                        --||l_master_type||'''';
  l_select_add_condition := ','||l_source_object_name||'.'
                        ||l_source_object_pk_field||','||''''
                        ||l_master_type||'''' ;

   write_to_act_log('Calling process_insert_sql', 'LIST', g_list_header_id,'LOW');
   process_insert_sql(p_select_statement       => l_select_condition,
                      p_select_add_statement   => l_select_add_condition,
                      p_master_type            => l_master_type,
                      p_child_types            => l_child_types,
                      p_from_string            => l_from_string  ,
                      p_list_select_action_id  => p_list_select_action_id  ,
                      p_action_used_by_id      => p_action_used_by_id ,
                      p_list_action_type       => p_list_action_type ,
                      p_order_number           => p_order_number,
                      p_rank                   => p_rank,
                      x_std_sql                => x_std_sql,
                      x_include_sql            => x_include_sql
                      );

   if  p_list_action_type   = 'INCLUDE' then
      write_to_act_log('Calling insert_list_mapping_usage', 'LIST', g_list_header_id,'LOW');
      insert_list_mapping_usage
                (p_list_header_id   => p_action_used_by_id,
                 p_source_type_code => l_master_type ) ;

      if l_child_types.last > 0 then
         for i in 1 .. l_child_types.last
         loop
            write_to_act_log('child_type ->' || i || '->'||l_child_types(i), 'LIST', g_list_header_id,'LOW');
            insert_list_mapping_usage
                      (p_list_header_id   => p_action_used_by_id,
                       p_source_type_code => l_child_types(i) ) ;
         end loop;
      end if;
   end if;
   write_to_act_log('Execution of process_all_sql ends ', 'LIST', g_list_header_id,'LOW');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     write_to_act_log('Error while executing process_all_sql '||sqlcode||'   '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     write_to_act_log('Error while executing process_all_sql '||sqlcode||'   '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

  WHEN OTHERS THEN
     write_to_act_log('Error while executing process_all_sql '||sqlcode||'   '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


END process_all_sql;

PROCEDURE process_sql (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              ) is

------------------------------------------------------------------------------
-- Given the sql id from ams_list_select_actions it will retrieve the
-- sql_srtings from ams_discoverer_sql for a particular worksheet_name and
-- workbook_name.
------------------------------------------------------------------------------
cursor cur_sql  is
SELECT query,primary_key, source_object_name
FROM   ams_list_queries_all
WHERE  (list_query_id = p_incl_object_id )
or (parent_list_query_id = p_incl_object_id )
order by sequence_order;

/* sql_string column is obsolete: bug 4604653
cursor cur_old_sql  is
SELECT sql_string, primary_key, source_object_name
FROM   ams_list_queries_all
WHERE  (list_query_id = p_incl_object_id )
or (parent_list_query_id = p_incl_object_id )
order by sequence_order;
*/

cursor cur_primary_key_sql  is
SELECT lc.SOURCE_OBJECT_NAME, lc.SOURCE_OBJECT_PK_FIELD
FROM   ams_list_queries_all  lq,
       ams_list_headers_all lh,
       ams_list_src_types  lc
WHERE lq.list_query_id = p_incl_object_id
and   lq.ARC_ACT_LIST_QUERY_USED_BY = 'LIST'
and   lq.ACT_LIST_QUERY_USED_BY_ID = lh.list_header_id
and   lc.source_type_code = lh.list_source_type;


l_sql_string         sql_string;
l_where_string       sql_string;
l_from_string       sql_string;
l_counter            NUMBER := 1;
l_from_position      number;
l_from_counter       number;
l_end_position      number;
l_end_counter       number;
l_order_position      number;
l_order_counter       number;
l_group_position      number;
l_group_counter       number;
l_found              varchar2(1);
l_master_type        varchar2(80);
l_master_type_id     number;
l_source_object_name  varchar2(80);
l_source_object_pk_field  varchar2(80);
l_child_types        child_type;
l_select_condition    varchar2(2000);
l_select_add_condition    varchar2(2000);
l_sql_string_v2           varchar2(4000);
l_primary_key          varchar2(80);
l_no_pieces            number :=0;
l_big_sql VARCHAR2(32767);
BEGIN
    write_to_act_log('Executing procedure process_sql. Incl object id is '||p_incl_object_id  , 'LIST', g_list_header_id,'LOW');
  open cur_sql;
  loop
    fetch cur_sql into l_big_sql,l_primary_key,l_source_object_name;
    exit when cur_sql%notfound ;
--    write_to_act_log('Process_sql query cursor:' || p_incl_object_id, 'LIST', g_list_header_id);
    l_no_pieces := ceil(length(l_big_sql)/2000);
    write_to_act_log('No of chunks for this sql' || l_no_pieces, 'LIST', g_list_header_id,'LOW');
    if l_no_pieces  > 0 then
       for i  in 1 .. l_no_pieces
       loop
         -- write_to_act_log('number of pieces:->' || i, 'LIST', g_list_header_id);
          --write_to_act_log('Process_sql: before ' );
          l_sql_string(l_counter):= substrb(l_big_sql,2000*i -1999,2000);
          --write_to_act_log('Process_sql:' || l_sql_string(l_counter));
          l_counter  := l_counter +1 ;
       end loop;
    end if;
    -- l_sql_string(l_counter):= substrb(l_sql_string_v2,2001,2000);
    -- l_counter  := l_counter +1 ;
  end loop;
  close cur_sql;

    write_to_act_log('lenth of pieces:' || l_no_pieces, 'LIST', g_list_header_id);
/*
  if l_no_pieces = 0   or
     l_no_pieces is null then
     open cur_old_sql;
     loop
       fetch cur_old_sql into l_sql_string_v2,l_primary_key,l_source_object_name;
--       write_to_act_log('Process_sql old cursor 4000->:' || p_incl_object_id, 'LIST', g_list_header_id);
       exit when cur_old_sql%notfound ;
       --write_to_act_log('Process_sql: before ' );
       l_sql_string(l_counter):= substrb(l_sql_string_v2,1,2000);
       --write_to_act_log('Process_sql:' || l_sql_string(l_counter));
       l_counter  := l_counter +1 ;
       l_sql_string(l_counter):= substrb(l_sql_string_v2,2001,2000);
       l_counter  := l_counter +1 ;
     end loop;
     close cur_old_sql;
  end if;
  */
  if l_source_object_name is null or
     l_primary_key is null then
     open cur_primary_key_sql  ;
     loop
       fetch cur_primary_key_sql into l_source_object_name,l_primary_key;
       exit when cur_primary_key_sql%notfound ;
     end loop;
     close cur_primary_key_sql  ;
  end if;
  write_to_act_log('Source object name is '||l_source_object_name||' and primary key is '||l_primary_key, 'LIST', g_list_header_id,'HIGH');
  process_all_sql(p_action_used_by_id => p_action_used_by_id ,
                  p_incl_object_id => p_incl_object_id ,
                  p_list_action_type  => p_list_action_type  ,
                  p_list_select_action_id   => p_list_select_action_id   ,
                  p_order_number   => p_order_number   ,
                  p_rank   => p_rank   ,
                  p_include_control_group  => p_include_control_group,
                  p_sql_string    => l_sql_string    ,
                  p_primary_key   => l_primary_key,
                  p_source_object_name   => l_source_object_name,
                  x_msg_count      => x_msg_count      ,
                  x_msg_data   => x_msg_data   ,
                  x_return_status   => x_return_status   ,
                  x_std_sql                => x_std_sql,
                  x_include_sql            => x_include_sql
                  );
  write_to_act_log('Procedure process_sql executed.', 'LIST', g_list_header_id,'LOW'  );
exception
   when others then
    write_to_act_log('Error while executing procedure process_sql '||sqlcode||'  '|| sqlerrm, 'LIST', g_list_header_id,'HIGH');
    x_return_status := FND_API.G_RET_STS_ERROR ;
END process_sql;

PROCEDURE process_diwb (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              ) is

------------------------------------------------------------------------------
-- Given the sql id from ams_list_select_actions it will retrieve the
-- sql_srtings from ams_discoverer_sql for a particular worksheet_name and
-- workbook_name.
------------------------------------------------------------------------------
--bmuthukr 4351740. this cursor should be used to pick the disc sql
--since sql could be stored in more than one record this reqd.
cursor cur_diwb(l_incl_object_id  in number )  is
SELECT sql_string
FROM   ams_discoverer_sql
WHERE  (workbook_name, worksheet_name )
IN
( SELECT workbook_name, worksheet_name
  FROM   ams_discoverer_sql
  WHERE  discoverer_sql_id = l_incl_object_id)
ORDER BY sequence_order;

l_sql_string         sql_string;
l_where_string       sql_string;
l_from_string       sql_string;
l_counter            NUMBER := 1;
l_from_position      number;
l_from_counter       number;
l_end_position      number;
l_end_counter       number;
l_order_position      number;
l_order_counter       number;
l_group_position      number;
l_group_counter       number;
l_found              varchar2(1);
l_master_type        varchar2(80);
l_master_type_id     number;
l_source_object_name  varchar2(80);
l_source_object_pk_field  varchar2(80);
l_child_types        child_type;
l_select_condition    varchar2(2000);
l_select_add_condition    varchar2(2000);
BEGIN
  write_to_act_log('Executing process_diwb since workbook has been included in list/target group selections.', 'LIST', g_list_header_id,'LOW');

  /* Populating l_sql_string with sql statements from ams_discoverer_sql
     l_sql_string is of table type of varchar2(2000)
  */
  open cur_diwb(p_incl_object_id);
  loop
    fetch cur_diwb into l_sql_string(l_counter);
    exit when cur_diwb%notfound ;
    --Added by bmuthukr for bug 3944161.
    if instr(l_sql_string(l_counter), 'ORDER BY') > 0  or instr(l_sql_string(l_counter), 'GROUP BY') > 0 then
      write_to_act_log('Workbook sql has ORDER BY or GROUP BY clause. Aborting list/target group generation.', 'LIST', g_list_header_id,'HIGH');
      update ams_list_headers_all
        set last_generation_success_flag = 'N',
            status_code                  = 'FAILED',
            user_status_id               = 311,
            status_date                  = sysdate,
            last_update_date             = sysdate,
            main_gen_end_time            = sysdate
      where list_header_id               = g_list_header_id;
  -- Added for cancel list gen as it prevents parallel update- Raghu
  -- of list headers when cancel button is pressed
      commit;
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    end if;
    --
    l_counter  := l_counter +1 ;
  end loop;
  close cur_diwb;
  write_to_act_log('Passing sql from ams_discoverer sql for this workbook to process_all_sql procedure', 'LIST', g_list_header_id,'LOW');
  process_all_sql(p_action_used_by_id => p_action_used_by_id ,
                  p_incl_object_id => p_incl_object_id ,
                  p_list_action_type  => p_list_action_type  ,
                  p_list_select_action_id   => p_list_select_action_id   ,
                  p_order_number   => p_order_number   ,
                  p_rank   => p_rank   ,
                  p_include_control_group  => p_include_control_group,
                  p_sql_string    => l_sql_string,
						p_primary_key   => null,
						p_source_object_name => null,
                  x_msg_count      => x_msg_count      ,
                  x_msg_data   => x_msg_data   ,
                  x_return_status   => x_return_status   ,
                  x_std_sql                => x_std_sql,
                  x_include_sql            => x_include_sql);
  write_to_act_log('Execution of process_diwb ends', 'LIST', g_list_header_id,'LOW');

END process_diwb ;

PROCEDURE process_cell
             (p_action_used_by_id in  number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
               ) is

------------------------------------------------------------------------------
-- Given the sql id from ams_list_select_actions it will retrieve the
-- sql_srtings from ams_discoverer_sql for a particular worksheet_name and
-- workbook_name.
------------------------------------------------------------------------------
l_sql_string         sql_string;
l_where_string       sql_string;
l_from_string       sql_string;
l_counter            NUMBER := 1;
l_from_position      number;
l_from_counter       number;
l_end_position      number;
l_end_counter       number;
l_order_position      number;
l_order_counter       number;
l_group_position      number;
l_group_counter       number;
l_found              varchar2(1);
l_master_type        varchar2(80);
l_master_type_id     number;
l_source_object_name  varchar2(80);
l_source_object_pk_field  varchar2(80);
l_child_types        child_type;
l_select_condition    varchar2(2000);
l_select_add_condition    varchar2(2000);
l_msg_data       VARCHAR2(2000);
l_msg_count      number;
l_sql_2          DBMS_SQL.VARCHAR2S;
l_sql_string_final    varchar2(4000);
j number     := 1;
BEGIN
  write_to_act_log('Executing process_cell since segment has been included in list/target group selections.', 'LIST', g_list_header_id,'LOW');
  write_to_act_log('Calling ams_cell_pvt.get_comp_sql to get the sql', 'LIST', g_list_header_id,'LOW');
  ams_cell_pvt.get_comp_sql(
      p_api_version       => 1.0,
      p_init_msg_list     => FND_API.g_false,
      p_validation_level  => FND_API.g_valid_level_full,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count ,
      x_msg_data           =>x_msg_data,
      p_cell_id           => p_incl_object_id ,
      p_party_id_only     => FND_API.g_true, --bug 4635925
      x_sql_tbl           => l_sql_2
   );
  write_to_act_log('Procedure ams_cell_pvt.get_comp_sql executed. Return status is '||x_return_status, 'LIST', g_list_header_id,'LOW');
  l_sql_string_final := '';
  for i in 1 .. l_sql_2.last
  loop
      l_sql_string_final := l_sql_string_final || l_sql_2(i);
     if length(l_sql_string_final) > 2000 then
        l_sql_string(j) := substrb(l_sql_string_final,1,2000);
        l_sql_string_final := substrb(l_sql_string_final,2001 ,2000);
        j := j+1;
     end if;
  end loop;
  l_sql_string(j) := substrb(l_sql_string_final,1,2000);
  if length(l_sql_string_final) > 2000 then
    j := j+1;
    l_sql_string(j) := substrb(l_sql_string_final,2001 ,2000);
  end if;

  write_to_act_log('Passing sql associated with this segment to process_all_sql procedure', 'LIST', g_list_header_id,'LOW');
  process_all_sql(p_action_used_by_id => p_action_used_by_id ,
                  p_incl_object_id => p_incl_object_id ,
                  p_list_action_type  => p_list_action_type  ,
                  p_list_select_action_id   => p_list_select_action_id   ,
                  p_order_number   => p_order_number   ,
                  p_rank   => p_rank   ,
                  p_include_control_group  => p_include_control_group,
                  p_sql_string    => l_sql_string    ,
                  x_msg_count      => x_msg_count      ,
                  x_msg_data   => x_msg_data   ,
                  x_return_status   => x_return_status   ,
                  x_std_sql                => x_std_sql,
                  x_include_sql            => x_include_sql,
                  p_primary_key   => null,
                  p_source_object_name => null);
  write_to_act_log('Execution of process_cell completed. Return status is '||x_return_status, 'LIST', g_list_header_id,'LOW');
exception
    when others then
        write_to_act_log('Error while executing process cell procedure. Please check the segment definitions', 'LIST', g_list_header_id,'HIGH');

END process_cell ;
-----------------------------------------------------------------------------
-- START OF COMMENTS
-- NAME : PROCESS_LIST_ACTIONS
-- PURPOSE
-- CALLED BY.
--    1. Generate_List.
--
-- HISTORY
--   02/01/2001      gjoby  created
-- END OF COMMENTS
-----------------------------------------------------------------------------

PROCEDURE process_list_actions
             (p_action_used_by_id  in  number,
              p_action_used_by     in  varchar2  ,-- DEFAULT 'LIST',
              p_log_flag           in  varchar2  ,-- DEFAULT 'Y',
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2) IS

  -- AMS_LIST_SELECT_ACTIONS Record for init record and complete record
  l_tmp_action_rec             ams_listaction_pvt.action_rec_type;
  p_action_rec                 ams_listaction_pvt.action_rec_type;
  l_list_select_action_id      number;
  l_return_status             VARCHAR2(100) := FND_API.G_FALSE;

  ----------------------------------------------------------------------------
  -- Cursor definition to select list_select_action_id.Will be used in loop to
  -- Process each cursor record according to order specified by the user
  ----------------------------------------------------------------------------
/*
  CURSOR c_action_dets is
  SELECT list_select_action_id
    FROM ams_list_select_actions
   WHERE action_used_by_id   = p_action_used_by_id
     AND arc_action_used_by  = p_action_used_by
   ORDER by rank; -- Raghu Jul 07
--   ORDER by order_number;
*/
  CURSOR c_action_dets is
  SELECT list_select_action_id
    FROM ams_list_select_actions
   WHERE action_used_by_id   = p_action_used_by_id
     AND arc_action_used_by  = p_action_used_by
   ORDER by order_number;

  TYPE big_tbl_type is table of VARCHAR2(32767) index by BINARY_INTEGER;
  l_std_sql VARCHAR2(32767);
  l_include_sql VARCHAR2(32767);
  l_include_count number:=0;
  l_final_big_sql VARCHAR2(32767);
  l_include_sql_tbl  big_tbl_type ;
  l_std_sql_tbl  big_tbl_type ;
  l_join_string   varchar2(50);
  l_no_of_chunks  number;
  l_const_sql varchar2(4000) ;
  TYPE char_tbl_type is table of VARCHAR2(100) index by BINARY_INTEGER;
  TYPE num_tbl_type is table of number index by BINARY_INTEGER;
--  l_rank_tbl      char_tbl_type;
  l_rank_num_tbl      num_tbl_type;
  l_order_num_tbl     num_tbl_type; -- added for bug fix 4443619
  l_order_num   number;
l_sorted   number;
l_update_sql  VARCHAR2(32767);
l_list_header_id number ;
l_string VARCHAR2(32767);

cursor c1 is
select generation_type
from ams_list_headers_all
where list_header_id = l_list_header_id;
l_generation_type varchar2(60);
l_PARAMETERIZED_FLAG  varchar2(1) := 'N';
TYPE table_char  IS TABLE OF VARCHAR2(80) INDEX  BY BINARY_INTEGER;
l_table_char table_char;

cursor c_query(l_query_id number) is select
nvl(PARAMETERIZED_FLAG ,'N')
from ams_list_queries_all
where  list_query_id = l_query_id ;

cursor c_param_values(l_query_id in number) is
select PARAMETER_ORDER, PARAMETER_VALUE,parameter_name
from ams_list_queries_param
where list_query_id = l_query_id
order by PARAMETER_ORDER;

l_remote_update_sql  VARCHAR2(32767);
l_total_chunks  number;
l_null		number;
l_total_recs    number;
l_query_templ_flag   varchar2(1) ;

cursor c_count1  is select count(1)
from ams_list_entries
where list_header_id  = g_list_header_id ;
l_count1 number:= 0;

cursor c_query_temp_type is
select 'Y'
from ams_list_headers_vl  a ,
     ams_query_template_all b
where a.list_header_id = g_list_header_id
  and b.template_type  = 'PARAMETERIZED'
  and a.query_template_id = b.template_id ;

l_param_string VARCHAR2(32767);
l_const_sql1 varchar2(4000) ;
l_l_sele_action_id      number;

l_temp_sql            varchar2(32767);

l_dist_pct_tbl        num_tbl_type;
l_list_select_id      num_tbl_type;
l_incl_object_type    char_tbl_type;



/*  CURSOR c_action_dets1 is
  SELECT list_select_action_id
    FROM ams_list_select_actions
   WHERE action_used_by_id   = p_action_used_by_id
     AND arc_action_used_by  = p_action_used_by
     AND order_number        = l_order_num; -- added for bug fix 4443619
--     AND order_number        = l_sorted;-- removed for bug fix 4443619*/
  CURSOR c_action_dets1 is
  SELECT list_select_action_id,order_number
    FROM ams_list_select_actions
   WHERE action_used_by_id   = p_action_used_by_id
     AND arc_action_used_by  = p_action_used_by
     AND order_number        = l_order_num;

l_order_number number := 0;

--Bug 4685389. bmuthukr. to check the total # of parameters
cursor c_check_num_params(p_incl_object_id number) is
select count(1)
  from ams_list_queries_param
 where list_query_id = p_incl_object_id;

 l_tot_params   number := 0;
--

BEGIN
   write_to_act_log('Executing process_list_actions','LIST',g_list_header_id, 'HIGH');
l_const_sql := ' minus '||
               ' select list_entry_source_system_id ' ||
               ' from ams_list_entries ' ||
               ' where list_header_id  = ' || p_action_used_by_id   ;

l_const_sql1 := '   and LIST_SELECT_ACTION_ID = ';

  write_to_act_log('Fetching info for the selections','LIST',g_list_header_id, 'LOW');
  OPEN c_action_dets;
  LOOP

/******************************************************************************/
/**************** call for cancel list generation added 05/23/2005 ************/
/******************************************************************************/
-- Inside process_list_actions

   AMS_LISTGENERATION_UTIL_PKG.cancel_list_gen(
                p_list_header_id => g_list_header_id ,
                p_remote_gen     => g_remote_list    ,
                p_remote_gen_list=> g_remote_list_gen,
                p_database_link  => g_database_link,
                x_msg_count      => x_msg_count ,
                x_msg_data       => x_msg_data ,
                x_return_status  => x_return_status
               );

  IF(x_return_status <> FND_API.G_RET_STS_SUCCESS )THEN
     if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
        write_to_act_log('Error in Cancel List generation', 'LIST', g_list_header_id,'HIGH');
        write_to_act_log('Error while executing Cancel List generation '||sqlerrm||sqlcode, 'LIST', g_list_header_id,'HIGH');
     end if;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     write_to_act_log('Success in Cancel List generation', 'LIST', g_list_header_id,'LOW');
  END IF;

/******************************************************************************/
/**************** call for cancel list generation added 05/23/2005 ************/
/******************************************************************************/

    FETCH c_action_dets INTO l_list_select_action_id;
    EXIT WHEN c_action_dets%NOTFOUND;

    -------------------------------------------------------------------------
    -- Gets list select actions record details
    -- Intialize the record, set the list_select_action_id and get the
    -- details
    -------------------------------------------------------------------------
    ams_listaction_pvt.init_action_rec(l_tmp_action_rec);
    l_tmp_action_rec.list_select_action_id := l_list_select_action_id;
    ams_listaction_pvt.complete_action_rec
                       (p_action_rec   => l_tmp_action_rec,
                        x_complete_rec => p_action_rec);
    -------------------------------------------------------------------------
    write_to_act_log('Included object is of type '||p_action_rec.arc_incl_object_from||' , action type is '||p_action_rec.list_action_type||' , included object_id is '||to_char(p_action_rec.incl_object_id),'LIST',g_list_header_id,'LOW');

   ----------------------------------------------------------------------
    --validating that the first executed action has a type of "INCLUDE".--
    ----------------------------------------------------------------------
    IF (c_action_dets%ROWCOUNT = 1) THEN
       IF (p_action_rec.list_action_type <> 'INCLUDE')then
           write_to_act_log('Action type of the first selection should always be INCLUDE. Aborting list generation.', 'LIST', g_list_header_id,'HIGH');
           FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_FIRST_INCLUDE');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
       END IF;  -- End of if for list_action_type check
    END IF; --End of Validation:- First Action Include Check

    write_to_act_log('Calling validate_listaction procedure to validate the list selection attributes','LIST',g_list_header_id, 'LOW');
    ams_listaction_pvt.Validate_ListAction
    ( p_api_version            => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_validation_level       => JTF_PLSQL_API.G_VALID_LEVEL_RECORD,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_action_rec             => p_action_rec
    );

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
      write_to_act_log('Error while validating list selections', 'LIST', g_list_header_id,'HIGH');
      write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
   end if;

   if p_action_rec.ARC_INCL_OBJECT_FROM = 'SQL' then
      OPEN c_query( p_action_rec.incl_object_id );
      FETCH c_query INTO l_PARAMETERIZED_FLAG  ;
      close  c_query;
   end if;
   /********************************************************************
      This dynamic procedure will process action for each object type
      If the object type is of CELL the process will be procecss_cell
      Using the same logic the procedure could be extended for new
      action types
   *********************************************************************/
   -- Bug 4685389. bmuthukr. to check the total # of parameters. If it exceeds 100 abort the process
   if nvl(l_parameterized_flag,'N') = 'Y' then

      open c_check_num_params(p_action_rec.incl_object_id);
      fetch c_check_num_params into l_tot_params;
      close c_check_num_params;

      if nvl(l_tot_params,0) > 100 then
         write_to_act_log('Number of parameters used exceeds 100. Aborting list generation process. Please redefine your criteria and restrict it to 100.',
  	 'LIST',g_list_header_id,'HIGH');
         UPDATE ams_list_headers_all
            SET last_generation_success_flag = 'N',
                status_code                  = 'FAILED',
                user_status_id               = 311,
                status_date                  = sysdate,
                last_update_date             = sysdate,
                main_gen_end_time            = sysdate
          WHERE list_header_id               = g_list_header_id;
         x_return_status := 'E';
         logger;
	 commit;
         RETURN;
      end if;
   end if;
   --

   -- Employeee list changes..
   if p_action_rec.arc_incl_object_from NOT IN ('IMPH','LIST','SQL','DIWB','CELL') then
      write_to_act_log(p_msg_data => 'Invalid included object -- Valid inclusions are imported list, list, custom sql, segment, work book. Aborting list generation process.',
                       p_arc_log_used_by => 'LIST',
                       p_log_used_by_id  => g_list_header_id,
		       p_level => 'HIGH');

        UPDATE ams_list_headers_all
        SET    last_generation_success_flag = 'N',
               status_code                  = 'FAILED',
               user_status_id               = 311,
               status_date                  = sysdate,
               last_update_date             = sysdate,
               main_gen_end_time            = sysdate
        WHERE  list_header_id               = g_list_header_id;
  -- Added for cancel list gen as it prevents parallel update- Raghu
  -- of list headers when cancel button is pressed
        commit;

     x_return_status := 'E';
     x_msg_count := 1;
     x_msg_data := ' Invalid Included Object-- Valid inclusions are imported list, list, custom sql, segment, work book. Aborting list generation process.';
     RETURN;
   end if;

      write_to_act_log('Calling process_'||p_action_rec.arc_incl_object_from,'LIST',g_list_header_id,'LOW');
   write_to_act_log('p_action_rec.list_select_action_id = '||p_action_rec.list_select_action_id, 'LIST', g_list_header_id,'LOW');
      execute immediate
      'BEGIN
        AMS_ListGeneration_PKG.process_'||p_action_rec.arc_incl_object_from ||
         '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12) ;
      END;'
      using  p_action_used_by_id,
             p_action_rec.incl_object_id ,
             p_action_rec.list_action_type,
             p_action_rec.list_select_action_id,
             p_action_rec.order_number,
             p_action_rec.rank,
             'N',--CHECK p_action_rec.incl_control_group,
             OUT x_msg_data,
             OUT x_msg_count,
             in OUT x_return_status ,
             OUT l_std_sql ,
             OUT l_include_sql;

    if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
       write_to_act_log('Error when executing process_'||p_action_rec.arc_incl_object_from, 'LIST', g_list_header_id,'HIGH');
       write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
       UPDATE ams_list_headers_all
          SET last_generation_success_flag = 'N',
              status_code                  = 'FAILED',
              user_status_id               = 311,
              status_date                  = sysdate,
              last_update_date             = sysdate,
              main_gen_end_time            = sysdate
        WHERE list_header_id               = g_list_header_id;
       logger;
       commit;
       RETURN;
    else
       write_to_act_log('Process_'||p_action_rec.arc_incl_object_from||' executed successfully.', 'LIST', g_list_header_id,'LOW');
    end if;

     if p_action_rec.list_action_type = 'INCLUDE' then
        l_include_count := l_include_count + 1 ;
        l_include_sql_tbl(l_include_count) := l_include_sql ;
        l_std_sql_tbl(l_include_count) := l_std_sql;
        --l_rank_tbl(l_include_count) := lpad(p_action_rec.rank,50,'0')
                         --|| lpad(p_action_rec.order_number,50,'0');
        l_order_num_tbl(l_include_count) := p_action_rec.order_number;-- Raghu Jul 07
	l_rank_num_tbl(l_include_count) := p_action_rec.rank; -- Raghu Jul 07
	l_dist_pct_tbl(l_include_count) := p_action_rec.distribution_pct;
        l_list_select_id(l_include_count) := p_action_rec.list_select_action_id;
        l_incl_object_type(l_include_count) := p_action_rec.arc_incl_object_from;
     else
       if p_action_rec.list_action_type = 'EXCLUDE' then
          l_join_string := ' minus ';
          l_list_header_id := p_action_rec.action_used_by_id;
          open c1;
          FETCH c1 into l_generation_type;
          close c1;
       else
          l_join_string := ' intersect ';
          l_list_header_id := p_action_rec.action_used_by_id;
          open c1;
          FETCH c1 into l_generation_type;
          close c1;
       end if;
       write_to_act_log('SQL statement for INCLUSION','LIST',g_list_header_id,'LOW');
     FOR i IN 1 .. l_include_count
     loop
        l_std_sql_tbl(i) := l_std_sql_tbl(i)  ||
                             l_join_string ||
                             l_std_sql;
        l_no_of_chunks := ceil(length(l_std_sql_tbl(i))/2000 );
        for j in 1..l_no_of_chunks
        loop
           WRITE_TO_ACT_LOG(substrb(l_std_sql_tbl(i),(2000*j) - 1999,2000), 'LIST', g_list_header_id,'LOW');
        end loop;
     end loop;

     end if;

     IF(x_return_status <>FND_API.G_RET_STS_SUCCESS )THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   write_to_act_log('Action on the list/target group selection completed. ', 'LIST', g_list_header_id,'LOW');
-- end Of Dynamic Procedure
   l_join_string :='';
---------------------------------------------------------------------------
  END LOOP;  --  End loop c_action_dets
  CLOSE c_action_dets;

   write_to_act_log('No of inclusions in the selection '|| l_include_count, 'LIST', g_list_header_id,'LOW');
   write_to_act_log('Sorting based on rank for the selection. '|| l_include_count, 'LIST', g_list_header_id,'LOW');
/*
       -- Sorting According to rank
       FOR i IN 1 .. l_include_count
       loop
          l_rank_num_tbl(i) := i;
          if i <> 1 then
             for j in 1 .. i-1
             loop
               if l_rank_tbl(i)  < l_rank_tbl(l_rank_num_tbl(j)) then
                  for k in reverse j .. i-1
                  loop
                     l_rank_num_tbl(k+1) := l_rank_num_tbl(k);
                  end loop;
                  l_rank_num_tbl(j) := i;
                  exit;
               end if;
             end loop;
	  end if;
       end loop;
*/


  for  i in 1 .. l_include_count
  loop
	l_l_sele_action_id := null;
        --l_sorted := l_rank_num_tbl(i);
        l_sorted := i;--l_rank_num_tbl(i);
        l_order_num := l_order_num_tbl(i);
        --open c_action_dets1;
        --fetch c_action_dets1 into l_l_sele_action_id,l_order_number;
        --close c_action_dets1;
        WRITE_TO_ACT_LOG('List selection id is '||l_l_sele_action_id||' for order number '||l_order_num, 'LIST', g_list_header_id,'LOW');
/*
l_final_big_sql := l_include_sql_tbl(l_sorted) ||l_std_sql_tbl(l_sorted) || l_const_sql ||l_const_sql1||l_l_sele_action_id ||')';
*/
       -- l_std_sql_tbl(l_sorted) || l_const_sql || ')';
     WRITE_TO_ACT_LOG('Final SQL formed for generating list.', 'LIST', g_list_header_id,'LOW');
     if l_final_big_sql is not null then
      l_no_of_chunks  := ceil(length(l_final_big_sql)/2000 );
      for i in 1 ..l_no_of_chunks
      loop
        WRITE_TO_ACT_LOG(substrb(l_final_big_sql,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
      end loop;
     end if;

     if l_include_sql_tbl(l_sorted) is not null then
      l_no_of_chunks := 0;
      l_no_of_chunks  := ceil(length(l_include_sql_tbl(l_sorted))/2000 );
      for i in 1 ..l_no_of_chunks
       loop
        WRITE_TO_ACT_LOG(substrb(l_include_sql_tbl(l_sorted),(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
       end loop;
     end if;
    if l_std_sql_tbl(l_sorted) is not null then
      l_no_of_chunks := 0;
      l_no_of_chunks  := ceil(length(l_std_sql_tbl(l_sorted))/2000 );
      for i in 1 ..l_no_of_chunks
       loop
        WRITE_TO_ACT_LOG(substrb(l_std_sql_tbl(l_sorted),(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
       end loop;
    end if;
    if l_const_sql is not null then
     l_no_of_chunks := 0;
     l_no_of_chunks  := ceil(length(l_const_sql)/2000 );
     for i in 1 ..l_no_of_chunks
     loop
        WRITE_TO_ACT_LOG(substrb(l_const_sql,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
     end loop;
    end if;

      if l_PARAMETERIZED_FLAG  = 'N' then
         write_to_act_log('No parameters required for generating this list', 'LIST', g_list_header_id,'LOW');
         if nvl(l_dist_pct_tbl(l_sorted),100) <> 100 then
	    write_to_act_log('Included object is of type '||l_incl_object_type(l_sorted),'LIST',g_list_header_id,'LOW');
	    write_to_act_log('% Requested for this selection is '||l_dist_pct_tbl(l_sorted),'LIST',g_list_header_id,'LOW');
   	    if l_incl_object_type(l_sorted) in ('SQL','DIWB','CELL') then
	       write_to_act_log('Inclusion No is '||l_sorted||'  '||'Included object is of type '||l_incl_object_type(l_sorted),'LIST',g_list_header_id,'LOW');
	       l_temp_sql := l_include_sql_tbl(l_sorted);
	       l_temp_sql := 'SELECT count(1) '||substr(l_temp_sql,instr(l_temp_sql, ' FROM '));
               -- Modified for bug 5238900. bmuthukr
	       -- get_count(l_list_select_id(l_sorted),l_sorted,'OTHERS',l_temp_sql||l_std_sql_tbl(l_sorted)||l_const_sql||l_const_sql1||l_l_sele_action_id||')' );
               get_count(l_list_select_id(l_sorted),l_sorted,'OTHERS',l_temp_sql||l_std_sql_tbl(l_sorted)||l_const_sql||')' );
            elsif l_incl_object_type(l_sorted) = 'LIST' then
               get_count(l_list_select_id(l_sorted),l_sorted,'LIST',null);
            elsif l_incl_object_type(l_sorted) = 'IMPH' then
               get_count(l_list_select_id(l_sorted),l_sorted,'IMPH',null);
            end if;
            write_to_act_log('No of rows requested from the selection is '||g_reqd_num_tbl(l_sorted),'LIST',g_list_header_id,'LOW');
         else
            g_act_num_tbl(l_sorted)  := -1;
            g_reqd_num_tbl(l_sorted) := -1;
         end if;
         if g_remote_list_gen = 'N' then
		/* If the list is not based on the remote data source and if it's based on remote data source
                   but needs to be generated in the local instance means it's migrated to the local instance */
 	   l_const_sql1 := ' ';
           l_l_sele_action_id := null;

	   if g_reqd_num_tbl(l_sorted) <> -1 then
              EXECUTE IMMEDIATE l_include_sql_tbl(l_sorted) ||l_std_sql_tbl(l_sorted) || l_const_sql ||l_const_sql1||l_l_sele_action_id ||')'||' and rownum <= '||g_reqd_num_tbl(l_sorted);
           else
              EXECUTE IMMEDIATE l_include_sql_tbl(l_sorted) ||l_std_sql_tbl(l_sorted) || l_const_sql ||l_const_sql1||l_l_sele_action_id ||')';
           end if;
           write_to_act_log('List generated in local instance', 'LIST', g_list_header_id,'HIGH');
	  else
		/* If the list is based on the remote data source and it's not migrated to the local instance or
                   a segment , sql or workbook is in the list selection then it will be generated in the remote
                   instance through a dynamic procedure call */
               write_to_act_log('Calling remote procedure to generate list in remote instance', 'LIST', g_list_header_id,'LOW');
 	   l_const_sql1 := ' ';
           l_l_sele_action_id := null;

	   if g_reqd_num_tbl(l_sorted) <> -1 then
	      write_to_act_log(' % Requested at selection level for this selection ','LIST',g_list_header_id,'LOW');
	       execute immediate
      	      'BEGIN
               AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
              ' END;'
              using  '1',
              l_null,
              'T',
              l_null,
              OUT x_return_status,
              OUT x_msg_count,
              OUT x_msg_data,
              g_list_header_id,
              l_include_sql_tbl(l_sorted) ||l_std_sql_tbl(l_sorted) || l_const_sql ||l_const_sql1||l_l_sele_action_id ||')'||' and rownum <= '||g_reqd_num_tbl(l_sorted),
	      --   l_final_big_sql,
              l_null,
             OUT l_total_recs,
             'LISTGEN';
          else
	     write_to_act_log(' % Not Requested at selection level for this selection ','LIST',g_list_header_id,'LOW');
             execute immediate
      	      'BEGIN
               AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
              ' END;'
              using  '1',
              l_null,
              'T',
              l_null,
              OUT x_return_status,
              OUT x_msg_count,
              OUT x_msg_data,
              g_list_header_id,
              l_include_sql_tbl(l_sorted) ||l_std_sql_tbl(l_sorted) || l_const_sql ||l_const_sql1||l_l_sele_action_id ||')',
	   --   l_final_big_sql,
              l_null,
             OUT l_total_recs,
             'LISTGEN';
          end if;
           if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
              write_to_act_log('Error while executing remote procedure for generating list', 'LIST', g_list_header_id,'HIGH');
              write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
              --Added for bug 4577528 by bmuthukr.
              update ams_list_headers_all
                 set last_generation_success_flag = 'N',
                     status_code                  = 'FAILED',
                     user_status_id               = 311,
                     status_date                  = sysdate,
                     last_update_date             = sysdate,
                     main_gen_end_time            = sysdate
               where list_header_id               = g_list_header_id;
 	      update_remote_list_header(g_list_header_id,x_return_status,x_msg_count,x_msg_data);
              write_to_act_log('Aborting list generation ', 'LIST', g_list_header_id,'HIGH');
	      x_return_status := FND_API.g_ret_sts_error; --Gen return status should go to error.
	      return;
	      --
           else
              write_to_act_log('List generated successfully in remote instance', 'LIST', g_list_header_id,'HIGH');
           end if;
	end if;
      else  -- FOR l_PARAMETERIZED_FLAG = 'Y'
--       if g_remote_list_gen = 'N' then
        write_to_act_log('Fetching parameters required for generating this list', 'LIST', g_list_header_id,'LOW');
        for i in 1 .. 100 loop
           l_table_char(i) := ' ';
        end loop;
        for i in c_param_values(p_action_rec.incl_object_id )
        loop
           l_table_char(i.PARAMETER_ORDER) := trim(i.PARAMETER_VALUE);
	   write_to_act_log('Parameter - '||i.parameter_order||' is '||'*'||l_table_char(i.PARAMETER_ORDER)||'*','LIST', g_list_header_id,'LOW');
        end loop;
        l_const_sql1 := ' ';
        l_l_sele_action_id := null;
	-- l_final_big_sql := ' insert into t11 values (99,:PARTY_TYPE)';
        l_string := 'DECLARE   ' ||
        'l_string1 varchar2(10000) ; ' ||
        'begin    ' ||
        ' l_string1 :=   :1  || ' || ' :2  || ' || ' :3  || ' || ' :4  || ' ||
                       ' :5  || ' || ' :6  || ' || ' :7  || ' || ' :8  || ' ||
                       ' :9  || ' || ' :10  || ' || ' :11  || ' || ' :12  || ' ||
                       ' :13  || ' || ' :14  || ' || ' :15  || ' || ' :16  || ' ||
                       ' :17  || ' || ' :18  || ' || ' :19  || ' || ' :20  || ' ||
                       ' :21  || ' || ' :22  || ' || ' :23  || ' || ' :24  || ' ||
                       ' :25  || ' || ' :26  || ' || ' :27  || ' || ' :28  || ' ||
                       ' :29  || ' || ' :30  || ' || ' :31  || ' || ' :32  || ' ||
                       ' :33  || ' || ' :34  || ' || ' :35  || ' || ' :36  || ' ||
                       ' :37  || ' || ' :38  || ' || ' :39  || ' || ' :40  || ' ||
                       ' :41  || ' || ' :42  || ' || ' :43  || ' || ' :44  || ' ||
                       ' :45  || ' || ' :46  || ' || ' :47  || ' || ' :48  || ' ||
                       ' :49  || ' || ' :50  || ' || ' :51  || ' || ' :52  || ' ||
                       ' :53  || ' || ' :54  || ' || ' :55  || ' || ' :56  || ' ||
                       ' :57  || ' || ' :58  || ' || ' :59  || ' || ' :60  || ' ||
                       ' :61  || ' || ' :62  || ' || ' :63  || ' || ' :64  || ' ||
                       ' :65  || ' || ' :66  || ' || ' :67  || ' || ' :68  || ' ||
                       ' :69  || ' || ' :70  || ' || ' :71  || ' || ' :72  || ' ||
                       ' :73  || ' || ' :74  || ' || ' :75  || ' || ' :76  || ' ||
                       ' :77  || ' || ' :78  || ' || ' :79  || ' || ' :80  || ' ||
                       ' :81  || ' || ' :82  || ' || ' :83  || ' || ' :84  || ' ||
                       ' :85  || ' || ' :86  || ' || ' :87  || ' || ' :88  || ' ||
                       ' :89  || ' || ' :90  || ' || ' :91  || ' || ' :92  || ' ||
                       ' :93  || ' || ' :94  || ' || ' :95  || ' || ' :96  || ' ||
                       ' :97  || ' || ' :98  || ' || ' :99  || ' || ' :100  ; ' ||' '||
 --    l_final_big_sql ||
      l_include_sql_tbl(l_sorted) ||l_std_sql_tbl(l_sorted) || l_const_sql ||l_const_sql1||l_l_sele_action_id ||')'||
       ';  end;  '  ;
/* Changed to fix :1 and :name issue */
     open c_query_temp_type ;
        fetch  c_query_temp_type into l_query_templ_flag   ;
           --EXIT WHEN c_query_temp_type%NOTFOUND;
           if l_query_templ_flag  = 'Y' then
              l_no_of_chunks := 0;
              for i in c_param_values(p_action_rec.incl_object_id )
              loop
                 l_no_of_chunks := l_no_of_chunks + 1;
                 l_string := replace(l_string,':' || l_no_of_chunks  || ' ' , ':'|| i.parameter_name||' ' );
              end loop;
           end if;
           l_no_of_chunks := 0;
     close c_query_temp_type ;
 /*END Changed to fix :1 and :name issue */
     WRITE_TO_ACT_LOG('SQL to be executed to generate list', 'LIST', g_list_header_id,'LOW');
     WRITE_TO_ACT_LOG('Length of the sql  '||length(l_string), 'LIST', g_list_header_id,'LOW');
     l_no_of_chunks  := ceil(length(l_string)/2000 );
     for i in 1 ..l_no_of_chunks
     loop
        WRITE_TO_ACT_LOG(substrb(l_string,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
     end loop;
if g_remote_list_gen = 'N' then

     WRITE_TO_ACT_LOG('Generating list with parameters ','LIST', g_list_header_id,'LOW');
execute immediate   l_string
using l_table_char(1), l_table_char(2), l_table_char(3), l_table_char(4),
      l_table_char(5), l_table_char(6), l_table_char(7), l_table_char(8),
      l_table_char(9), l_table_char(10), l_table_char(11), l_table_char(12),
      l_table_char(13), l_table_char(14), l_table_char(15), l_table_char(16),
      l_table_char(17), l_table_char(18), l_table_char(19), l_table_char(20),
      l_table_char(21), l_table_char(22), l_table_char(23), l_table_char(24),
      l_table_char(25), l_table_char(26), l_table_char(27), l_table_char(28),
      l_table_char(29), l_table_char(30), l_table_char(31), l_table_char(32),
      l_table_char(33), l_table_char(34), l_table_char(35), l_table_char(36),
      l_table_char(37), l_table_char(38), l_table_char(39), l_table_char(40),
      l_table_char(41), l_table_char(42), l_table_char(43), l_table_char(44),
      l_table_char(45), l_table_char(46), l_table_char(47), l_table_char(48),
      l_table_char(49), l_table_char(50),
      l_table_char(51), l_table_char(52), l_table_char(53), l_table_char(54),
      l_table_char(55), l_table_char(56), l_table_char(57), l_table_char(58),
      l_table_char(59), l_table_char(60), l_table_char(61), l_table_char(62),
      l_table_char(63), l_table_char(64), l_table_char(65), l_table_char(66),
      l_table_char(67), l_table_char(68), l_table_char(69), l_table_char(70),
      l_table_char(71), l_table_char(72), l_table_char(73), l_table_char(74),
      l_table_char(75), l_table_char(76), l_table_char(77), l_table_char(78),
      l_table_char(79), l_table_char(80), l_table_char(81), l_table_char(82),
      l_table_char(83), l_table_char(84), l_table_char(85), l_table_char(86),
      l_table_char(87), l_table_char(88), l_table_char(89), l_table_char(90),
      l_table_char(91), l_table_char(92), l_table_char(93), l_table_char(94),
      l_table_char(95), l_table_char(96), l_table_char(97), l_table_char(98),
      l_table_char(99), l_table_char(100);
      open c_count1;
      fetch c_count1 into l_count1;
      close c_count1;
      write_to_act_log('Number of entries in list is '|| l_count1, 'LIST', g_list_header_id,'LOW');
 end if;

 if g_remote_list_gen = 'Y' then
  	   l_const_sql1 := ' ';
           l_l_sele_action_id := null;

        write_to_act_log('Calling remote procedure with parameters to generate list in remote instance ', 'LIST', g_list_header_id,'LOW');
      	       execute immediate
      	      'BEGIN
	AMS_Remote_ListGen_PKG.remote_param_list_gen'||'@'||g_database_link||'( :1  , :2  , :3  , :4  , :5  , :6  , :7  , :8  , :9  , :10  , :11  , :12  ,
       :13   , :14   , :15  , :16   , :17   , :18   , :19   , :20   ,
       :21   , :22   , :23  , :24   , :25   , :26   , :27   , :28   , :29   , :30   ,
       :31   , :32   , :33  , :34   , :35   , :36   , :37   , :38   , :39   , :40   ,
       :41   , :42   , :43  , :44   , :45   , :46   , :47   , :48   , :49   , :50   ,
       :51   , :52   , :53  , :54   , :55   , :56   , :57   , :58   , :59   , :60   ,
       :61   , :62   , :63  , :64   , :65   , :66   , :67   , :68   , :69   , :70   ,
       :71   , :72   , :73  , :74   , :75   , :76   , :77   , :78   , :79   , :80   ,
       :81   , :82   , :83  , :84   , :85   , :86   , :87   , :88   , :89   , :90   ,
       :91   , :92   , :93  , :94   , :95   , :96   , :97   , :98   , :99   , :100  ,
       :101   , :102   , :103   , :104   , :105   , :106   , :107   , :108   , :109   , :110   , :111   , :112
           )'||';'||
              ' END;'
              using  '1',
              l_null,
              'T',
              l_null,
              OUT x_return_status,
              OUT x_msg_count,
              OUT x_msg_data,
              g_list_header_id,
	      l_string,
              l_null,
             OUT l_total_recs,
             'PARAMLISTGEN',
      l_table_char(1), l_table_char(2), l_table_char(3), l_table_char(4),
      l_table_char(5), l_table_char(6), l_table_char(7), l_table_char(8),
      l_table_char(9), l_table_char(10), l_table_char(11), l_table_char(12),
      l_table_char(13), l_table_char(14), l_table_char(15), l_table_char(16),
      l_table_char(17), l_table_char(18), l_table_char(19), l_table_char(20),
      l_table_char(21), l_table_char(22), l_table_char(23), l_table_char(24),
      l_table_char(25), l_table_char(26), l_table_char(27), l_table_char(28),
      l_table_char(29), l_table_char(30), l_table_char(31), l_table_char(32),
      l_table_char(33), l_table_char(34), l_table_char(35), l_table_char(36),
      l_table_char(37), l_table_char(38), l_table_char(39), l_table_char(40),
      l_table_char(41), l_table_char(42), l_table_char(43), l_table_char(44),
      l_table_char(45), l_table_char(46), l_table_char(47), l_table_char(48),
      l_table_char(49), l_table_char(50),
      l_table_char(51), l_table_char(52), l_table_char(53), l_table_char(54),
      l_table_char(55), l_table_char(56), l_table_char(57), l_table_char(58),
      l_table_char(59), l_table_char(60), l_table_char(61), l_table_char(62),
      l_table_char(63), l_table_char(64), l_table_char(65), l_table_char(66),
      l_table_char(67), l_table_char(68), l_table_char(69), l_table_char(70),
      l_table_char(71), l_table_char(72), l_table_char(73), l_table_char(74),
      l_table_char(75), l_table_char(76), l_table_char(77), l_table_char(78),
      l_table_char(79), l_table_char(80), l_table_char(81), l_table_char(82),
      l_table_char(83), l_table_char(84), l_table_char(85), l_table_char(86),
      l_table_char(87), l_table_char(88), l_table_char(89), l_table_char(90),
      l_table_char(91), l_table_char(92), l_table_char(93), l_table_char(94),
      l_table_char(95), l_table_char(96), l_table_char(97), l_table_char(98),
      l_table_char(99), l_table_char(100);
      if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
         write_to_act_log('Error while generating  list in remote instance.', 'LIST', g_list_header_id,'HIGH');
         write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
         --Added for bug 4577528 by bmuthukr.
         update ams_list_headers_all
            set last_generation_success_flag = 'N',
                status_code                  = 'FAILED',
                user_status_id               = 311,
                status_date                  = sysdate,
                last_update_date             = sysdate,
                main_gen_end_time            = sysdate
          where list_header_id               = g_list_header_id;
         update_remote_list_header(g_list_header_id,x_return_status,x_msg_count,x_msg_data);
         write_to_act_log('Aborting list generation ', 'LIST', g_list_header_id,'HIGH');
	 x_return_status := FND_API.g_ret_sts_error; --Gen return status should go to error.
	 return;
	 --
      else
         write_to_act_log('List generated successfully in remote instance', 'LIST', g_list_header_id,'HIGH');
      end if;
    end if;
   end if;
  end loop;
  WRITE_TO_ACT_LOG('Execution of Process_list_action completed', 'LIST', g_list_header_id,'LOW');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     IF(c_action_dets%ISOPEN)THEN
        CLOSE c_action_dets;
     END IF;
     write_to_act_log('Error while executing process_list_actions '
                      ||sqlerrm||sqlcode, 'LIST', g_list_header_id,'HIGH');
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF(c_action_dets%ISOPEN)THEN
        CLOSE c_action_dets;
     END IF;
     write_to_act_log('Error while executing process_list_actions '
                      ||sqlerrm||sqlcode, 'LIST', g_list_header_id,'HIGH');
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN AMS_LISTGENERATION_UTIL_PKG.cancelListGen THEN
     IF(c_action_dets%ISOPEN)THEN
        CLOSE c_action_dets;
     END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     write_to_act_log('executing process_list_actions - user action to cancel list generation detected ' ||sqlerrm||sqlcode, 'LIST', g_list_header_id,'HIGH');
     -- Got to raise the exception again because Listgen has to end generation.
     raise AMS_LISTGENERATION_UTIL_PKG.cancelListGen;

  WHEN OTHERS THEN
     IF(c_action_dets%ISOPEN)THEN
        CLOSE c_action_dets;
     END IF;
     write_to_act_log('Error while executing process_list_actions '
                      ||sqlerrm||sqlcode, 'LIST', g_list_header_id,'HIGH');
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END process_list_actions;

-- START OF COMMENTS
--
-- NAME
--   CREATE_LIST_ENTRIES
--
-- PURPOSE

--    1. Populate The AMS_LIST_ENTRIES table with a DISTINCT set of
--       Entries from The AMS_LIST_TMP_ENTRIES table.
--    2. An Entry is considered UNIQUE by values in The list_entry_source_id
--       and List_Entry_Source_Type fields from The AMS_LIST_TMP_ENTRIES table.
--    3. There may be more than one Entry in The AMS_LIST_TMP_ENTRIES table
--       with The same values for The list_entry_source_id and
--       List_Entry_Source_Type fields, in this case The Entry with
--       the Highest Rank is choosen, if Two Equivalent entries have
--       the same rank then one entry is choosen arbitrarily.
--    4. The set of distinct entries in The AMS_LIST_TMP_ENTRIES table
--       have the SAVE_ROW_FLAG updated to 'Y'.
--       Rows with this value are then inserted into the AMS_LIST_ENTRIES table.
--    5. if less entries exist in the AMS_LIST_ENTRIES_TABLE than specifed
--       in the AMS_LIST_HEADERS_ALL
--       .NO_OF_ROWS_MIN_REQUESTED column then an error is reported.


-- CALLED BY.
--    1. GENERATE_LIST.
--  01/24/2001 GJOBY      Modified for hornet
--
-- HISTORY
-- END of Comments


procedure create_list_entries (p_list_header_id in number,
                               p_no_of_rows_min_requested  in number,
                               x_return_status OUT NOCOPY  VARCHAR2 ) IS

  l_entry_count              NUMBER;
  l_return_status            VARCHAR2(100) := FND_API.G_FALSE;
  l_source_code              VARCHAR2(100) := 'NONE';
  l_source_id                NUMBER        := 0;

  l_created_by                NUMBER;

   CURSOR cur_get_created_by (x_list_header_id IN NUMBER) IS
      SELECT created_by
      FROM ams_list_headers_all
      WHERE list_header_id= x_list_header_id;

BEGIN
   write_to_act_log('Executing procedure create_list_entries', 'LIST', g_list_header_id,'LOW');
   delete from ams_list_tmp_entries alte1
   where alte1.rowid > (select min(alte2.rowid)
                        from  ams_list_tmp_entries alte2
                        where alte2.list_header_id = alte1.list_header_id
                          and alte2.list_select_action_id
                                    = alte1.list_select_action_id
                          and alte2.list_entry_source_key
                                    =  alte1.list_entry_source_key  );

   delete from ams_list_tmp_entries alte1
   where alte1.rank > (select min(alte2.rank)
                        from  ams_list_tmp_entries alte2
                        where alte2.list_header_id = alte1.list_header_id
                          and alte2.list_entry_source_key
                                    =  alte1.list_entry_source_key  );

      l_created_by := 0;

       OPEN cur_get_created_by(p_list_header_id);

       FETCH cur_get_created_by INTO l_created_by;
       CLOSE cur_get_created_by;


   INSERT INTO ams_List_Entries
   ( list_entry_id                   ,
     last_update_date                ,
     last_updated_by                 ,
     creation_date                   ,
     created_by                      ,
     last_update_login               ,
     list_header_id                  ,
     list_select_action_id           ,
     arc_list_select_action_from     ,
     list_select_action_from_name    ,
     source_code                     ,
     source_code_for_id              ,
     arc_list_used_by_source         ,
     pin_code                        ,
     list_entry_source_system_id     ,
     list_entry_source_system_type   ,
     view_application_id             ,
     manually_entered_flag           ,
     marked_as_random_flag           ,
     marked_as_duplicate_flag        ,
     part_of_control_group_flag      ,
     exclude_in_triggered_list_flag  ,
     enabled_flag,
     object_version_number
   )
   ( select ams_list_entries_s.nextval,
            sysdate,
            fnd_global.user_id,
            sysdate,
            nvl(l_created_by, fnd_global.user_id),
            fnd_global.conc_login_id,
            p_list_header_id,
            s.list_select_action_id,
            s.arc_incl_object_from,
            s.incl_object_name,
            'NONE',
            0,
            h.list_used_by_id,
            ams_list_entries_s.currval,
            t.list_entry_source_id,
            t.list_entry_source_type,
            fnd_global.conc_login_id,
            'N',
            'N',
            'N',
            'N',
            'N',
            'Y',
             1
     from   ams_list_select_actions s,
            ams_list_tmp_entries    t,
            ams_list_headers_all    h
     where  h.list_header_id        = p_list_header_id
     and    t.list_header_id        = h.list_header_id
     and    t.list_select_action_id = s.list_select_action_id
     );

     select count(*)
     into   l_entry_count
     from   ams_list_entries
     where  list_header_id = p_list_header_id;

     update ams_list_headers_all
     set no_of_rows_in_list = l_entry_count,
         last_update_date  = sysdate
     where  list_header_id = p_list_header_id;

   write_to_act_log('Procedure create_list_entries executed', 'LIST', g_list_header_id,'LOW');
  -- Added for cancel list gen as it prevents parallel update- Raghu
  -- of list headers when cancel button is pressed
  commit;

-- Start changes for migration
/*
    if(l_entry_count < p_no_of_rows_min_requested)then
          FND_MESSAGE.set_name('AMS', 'AMS_LIST_MINIMUM_NOT_REACHED');
          FND_MESSAGE.Set_Token('NO_AVAILABLE',TO_CHAR(l_entry_count));
          FND_MESSAGE.Set_Token('NO_REQUESTED',TO_CHAR(p_no_of_rows_min_requested));
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
          x_return_status := FND_API.G_RET_STS_SUCCESS;
     END if;
*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;
-- End changes for migration
  exception
   when others then
   write_to_act_log('Error while executing procedure create_list_entries', 'LIST', g_list_header_id,'HIGH');
   x_return_status := FND_API.G_RET_STS_ERROR;

end create_list_entries;


procedure update_list_entries(p_list_header_id in number) is
l_tg_check	varchar2(1) := null;
cursor c_check_tg is
select 'Y' from ams_act_lists where list_header_id = p_list_header_id;

begin
open  c_check_tg;
fetch c_check_tg into l_tg_check;
close c_check_tg;

if l_tg_check = 'Y' then
   write_to_act_log('Generating target group(which has selections based on LIST) in update mode.','LIST',g_list_header_id,'LOW');
   update ams_list_entries  ale
   set (
       ale.newly_updated_flag ,
       ale.enabled_flag ,
       ale.SUFFIX,
       ale.FIRST_NAME,
       ale.LAST_NAME,
       ale.CUSTOMER_NAME,
       ale.TITLE,
       ale.ADDRESS_LINE1,
       ale.ADDRESS_LINE2,
       ale.CITY,
       ale.STATE,
       ale.ZIPCODE,
       ale.COUNTRY,
       ale.FAX,
       ale.PHONE,
       ale.EMAIL_ADDRESS,
       ale.COL1,
       ale.COL2,
       ale.COL3,
       ale.COL4,
       ale.COL5,
       ale.COL6,
       ale.COL7,
       ale.COL8,
       ale.COL9,
       ale.COL10,
       ale.COL11,
       ale.COL12,
       ale.COL13,
       ale.COL14,
       ale.COL15,
       ale.COL16,
       ale.COL17,
       ale.COL18,
       ale.COL19,
       ale.COL20,
       ale.COL21,
       ale.COL22,
       ale.COL23,
       ale.COL24,
       ale.COL25,
       ale.COL26,
       ale.COL27,
       ale.COL28,
       ale.COL29,
       ale.COL30,
       ale.COL31,
       ale.COL32,
       ale.COL33,
       ale.COL34,
       ale.COL35,
       ale.COL36,
       ale.COL37,
       ale.COL38,
       ale.COL39,
       ale.COL40,
       ale.COL41,
       ale.COL42,
       ale.COL43,
       ale.COL44,
       ale.COL45,
       ale.COL46,
       ale.COL47,
       ale.COL48,
       ale.COL49,
       ale.COL50,
       ale.COL51,
       ale.COL52,
       ale.COL53,
       ale.COL54,
       ale.COL55,
       ale.COL56,
       ale.COL57,
       ale.COL58,
       ale.COL59,
       ale.COL60,
       ale.COL61,
       ale.COL62,
       ale.COL63,
       ale.COL64,
       ale.COL65,
       ale.COL66,
       ale.COL67,
       ale.COL68,
       ale.COL69,
       ale.COL70,
       ale.COL71,
       ale.COL72,
       ale.COL73,
       ale.COL74,
       ale.COL75,
       ale.COL76,
       ale.COL77,
       ale.COL78,
       ale.COL79,
       ale.COL80,
       ale.COL81,
       ale.COL82,
       ale.COL83,
       ale.COL84,
       ale.COL85,
       ale.COL86,
       ale.COL87,
       ale.COL88,
       ale.COL89,
       ale.COL90,
       ale.COL91,
       ale.COL92,
       ale.COL93,
       ale.COL94,
       ale.COL95,
       ale.COL96,
       ale.COL97,
       ale.COL98,
       ale.COL99,
       ale.COL100,
       ale.COL101,
       ale.COL102,
       ale.COL103,
       ale.COL104,
       ale.COL105,
       ale.COL106,
       ale.COL107,
       ale.COL108,
       ale.COL109,
       ale.COL110,
       ale.COL111,
       ale.COL112,
       ale.COL113,
       ale.COL114,
       ale.COL115,
       ale.COL116,
       ale.COL117,
       ale.COL118,
       ale.COL119,
       ale.COL120,
       ale.COL121,
       ale.COL122,
       ale.COL123,
       ale.COL124,
       ale.COL125,
       ale.COL126,
       ale.COL127,
       ale.COL128,
       ale.COL129,
       ale.COL130,
       ale.COL131,
       ale.COL132,
       ale.COL133,
       ale.COL134,
       ale.COL135,
       ale.COL136,
       ale.COL137,
       ale.COL138,
       ale.COL139,
       ale.COL140,
       ale.COL141,
       ale.COL142,
       ale.COL143,
       ale.COL144,
       ale.COL145,
       ale.COL146,
       ale.COL147,
       ale.COL148,
       ale.COL149,
       ale.COL150,
       ale.COL151,
       ale.COL152,
       ale.COL153,
       ale.COL154,
       ale.COL155,
       ale.COL156,
       ale.COL157,
       ale.COL158,
       ale.COL159,
       ale.COL160,
       ale.COL161,
       ale.COL162,
       ale.COL163,
       ale.COL164,
       ale.COL165,
       ale.COL166,
       ale.COL167,
       ale.COL168,
       ale.COL169,
       ale.COL170,
       ale.COL171,
       ale.COL172,
       ale.COL173,
       ale.COL174,
       ale.COL175,
       ale.COL176,
       ale.COL177,
       ale.COL178,
       ale.COL179,
       ale.COL180,
       ale.COL181,
       ale.COL182,
       ale.COL183,
       ale.COL184,
       ale.COL185,
       ale.COL186,
       ale.COL187,
       ale.COL188,
       ale.COL189,
       ale.COL190,
       ale.COL191,
       ale.COL192,
       ale.COL193,
       ale.COL194,
       ale.COL195,
       ale.COL196,
       ale.COL197,
       ale.COL198,
       ale.COL199,
       ale.COL200,
       ale.COL201,
       ale.COL202,
       ale.COL203,
       ale.COL204,
       ale.COL205,
       ale.COL206,
       ale.COL207,
       ale.COL208,
       ale.COL209,
       ale.COL210,
       ale.COL211,
       ale.COL212,
       ale.COL213,
       ale.COL214,
       ale.COL215,
       ale.COL216,
       ale.COL217,
       ale.COL218,
       ale.COL219,
       ale.COL220,
       ale.COL221,
       ale.COL222,
       ale.COL223,
       ale.COL224,
       ale.COL225,
       ale.COL226,
       ale.COL227,
       ale.COL228,
       ale.COL229,
       ale.COL230,
       ale.COL231,
       ale.COL232,
       ale.COL233,
       ale.COL234,
       ale.COL235,
       ale.COL236,
       ale.COL237,
       ale.COL238,
       ale.COL239,
       ale.COL240,
       ale.COL241,
       ale.COL242,
       ale.COL243,
       ale.COL244,
       ale.COL245,
       ale.COL246,
       ale.COL247,
       ale.COL248,
       ale.COL249,
       ale.COL250 ,
       ale.COL251     ,
       ale.COL252     ,
       ale.COL253     ,
       ale.COL254     ,
       ale.COL256     ,
       ale.COL255     ,
       ale.COL257     ,
       ale.COL258     ,
       ale.COL259     ,
       ale.COL260     ,
       ale.COL261     ,
       ale.COL262     ,
       ale.COL263     ,
       ale.COL264     ,
       ale.COL265     ,
       ale.COL266     ,
       ale.COL267     ,
       ale.COL268     ,
       ale.COL269     ,
       ale.COL270     ,
       ale.COL271     ,
       ale.COL272     ,
       ale.COL273     ,
       ale.COL274     ,
       ale.COL275     ,
       ale.COL276     ,
       ale.COL277     ,
       ale.COL278     ,
       ale.COL279     ,
       ale.COL280     ,
       ale.COL281     ,
       ale.COL282     ,
       ale.COL283     ,
       ale.COL284     ,
       ale.COL285     ,
       ale.COL286     ,
       ale.COL287     ,
       ale.COL288     ,
       ale.COL289     ,
       ale.COL290     ,
       ale.COL291     ,
       ale.COL292     ,
       ale.COL293     ,
       ale.COL294     ,
       ale.COL295     ,
       ale.COL296     ,
       ale.COL297     ,
       ale.COL298     ,
       ale.COL299     ,
       ale.COL300     ,
       ale.SALES_AGENT_EMAIL_ADDRESS,
       ale.RESOURCE_ID,
       ale.location_id,
       ale.contact_point_id,
       ale.orig_system_reference,
       ale.CUSTOM_COLUMN1,
       ale.CUSTOM_COLUMN2,
       ale.CUSTOM_COLUMN3,
       ale.CUSTOM_COLUMN4,
       ale.CUSTOM_COLUMN5,
       ale.CUSTOM_COLUMN6,
       ale.CUSTOM_COLUMN7,
       ale.CUSTOM_COLUMN8,
       ale.CUSTOM_COLUMN9,
       ale.CUSTOM_COLUMN10,
       ale.CUSTOM_COLUMN11,
       ale.CUSTOM_COLUMN12,
       ale.CUSTOM_COLUMN13,
       ale.CUSTOM_COLUMN14,
       ale.CUSTOM_COLUMN15,
       ale.CUSTOM_COLUMN16,
       ale.CUSTOM_COLUMN17,
       ale.CUSTOM_COLUMN18,
       ale.CUSTOM_COLUMN19,
       ale.CUSTOM_COLUMN20,
       ale.CUSTOM_COLUMN21,
       ale.CUSTOM_COLUMN22,
       ale.CUSTOM_COLUMN23,
       ale.CUSTOM_COLUMN24,
       ale.CUSTOM_COLUMN25
       ) =
        (select
        'Y',
        'Y',
       ail.SUFFIX,
       ail.FIRST_NAME,
       ail.LAST_NAME,
       ail.CUSTOMER_NAME,
       ail.TITLE,
       ail.ADDRESS_LINE1,
       ail.ADDRESS_LINE2,
       ail.CITY,
       ail.STATE,
       ail.ZIPCODE,
       ail.COUNTRY,
       ail.FAX,
       ail.PHONE,
       ail.EMAIL_ADDRESS,
       ail.COL1,
       ail.COL2,
       ail.COL3,
       ail.COL4,
       ail.COL5,
       ail.COL6,
       ail.COL7,
       ail.COL8,
       ail.COL9,
       ail.COL10,
       ail.COL11,
       ail.COL12,
       ail.COL13,
       ail.COL14,
       ail.COL15,
       ail.COL16,
       ail.COL17,
       ail.COL18,
       ail.COL19,
       ail.COL20,
       ail.COL21,
       ail.COL22,
       ail.COL23,
       ail.COL24,
       ail.COL25,
       ail.COL26,
       ail.COL27,
       ail.COL28,
       ail.COL29,
       ail.COL30,
       ail.COL31,
       ail.COL32,
       ail.COL33,
       ail.COL34,
       ail.COL35,
       ail.COL36,
       ail.COL37,
       ail.COL38,
       ail.COL39,
       ail.COL40,
       ail.COL41,
       ail.COL42,
       ail.COL43,
       ail.COL44,
       ail.COL45,
       ail.COL46,
       ail.COL47,
       ail.COL48,
       ail.COL49,
       ail.COL50,
       ail.COL51,
       ail.COL52,
       ail.COL53,
       ail.COL54,
       ail.COL55,
       ail.COL56,
       ail.COL57,
       ail.COL58,
       ail.COL59,
       ail.COL60,
       ail.COL61,
       ail.COL62,
       ail.COL63,
       ail.COL64,
       ail.COL65,
       ail.COL66,
       ail.COL67,
       ail.COL68,
       ail.COL69,
       ail.COL70,
       ail.COL71,
       ail.COL72,
       ail.COL73,
       ail.COL74,
       ail.COL75,
       ail.COL76,
       ail.COL77,
       ail.COL78,
       ail.COL79,
       ail.COL80,
       ail.COL81,
       ail.COL82,
       ail.COL83,
       ail.COL84,
       ail.COL85,
       ail.COL86,
       ail.COL87,
       ail.COL88,
       ail.COL89,
       ail.COL90,
       ail.COL91,
       ail.COL92,
       ail.COL93,
       ail.COL94,
       ail.COL95,
       ail.COL96,
       ail.COL97,
       ail.COL98,
       ail.COL99,
       ail.COL100,
       ail.COL101,
       ail.COL102,
       ail.COL103,
       ail.COL104,
       ail.COL105,
       ail.COL106,
       ail.COL107,
       ail.COL108,
       ail.COL109,
       ail.COL110,
       ail.COL111,
       ail.COL112,
       ail.COL113,
       ail.COL114,
       ail.COL115,
       ail.COL116,
       ail.COL117,
       ail.COL118,
       ail.COL119,
       ail.COL120,
       ail.COL121,
       ail.COL122,
       ail.COL123,
       ail.COL124,
       ail.COL125,
       ail.COL126,
       ail.COL127,
       ail.COL128,
       ail.COL129,
       ail.COL130,
       ail.COL131,
       ail.COL132,
       ail.COL133,
       ail.COL134,
       ail.COL135,
       ail.COL136,
       ail.COL137,
       ail.COL138,
       ail.COL139,
       ail.COL140,
       ail.COL141,
       ail.COL142,
       ail.COL143,
       ail.COL144,
       ail.COL145,
       ail.COL146,
       ail.COL147,
       ail.COL148,
       ail.COL149,
       ail.COL150,
       ail.COL151,
       ail.COL152,
       ail.COL153,
       ail.COL154,
       ail.COL155,
       ail.COL156,
       ail.COL157,
       ail.COL158,
       ail.COL159,
       ail.COL160,
       ail.COL161,
       ail.COL162,
       ail.COL163,
       ail.COL164,
       ail.COL165,
       ail.COL166,
       ail.COL167,
       ail.COL168,
       ail.COL169,
       ail.COL170,
       ail.COL171,
       ail.COL172,
       ail.COL173,
       ail.COL174,
       ail.COL175,
       ail.COL176,
       ail.COL177,
       ail.COL178,
       ail.COL179,
       ail.COL180,
       ail.COL181,
       ail.COL182,
       ail.COL183,
       ail.COL184,
       ail.COL185,
       ail.COL186,
       ail.COL187,
       ail.COL188,
       ail.COL189,
       ail.COL190,
       ail.COL191,
       ail.COL192,
       ail.COL193,
       ail.COL194,
       ail.COL195,
       ail.COL196,
       ail.COL197,
       ail.COL198,
       ail.COL199,
       ail.COL200,
       ail.COL201,
       ail.COL202,
       ail.COL203,
       ail.COL204,
       ail.COL205,
       ail.COL206,
       ail.COL207,
       ail.COL208,
       ail.COL209,
       ail.COL210,
       ail.COL211,
       ail.COL212,
       ail.COL213,
       ail.COL214,
       ail.COL215,
       ail.COL216,
       ail.COL217,
       ail.COL218,
       ail.COL219,
       ail.COL220,
       ail.COL221,
       ail.COL222,
       ail.COL223,
       ail.COL224,
       ail.COL225,
       ail.COL226,
       ail.COL227,
       ail.COL228,
       ail.COL229,
       ail.COL230,
       ail.COL231,
       ail.COL232,
       ail.COL233,
       ail.COL234,
       ail.COL235,
       ail.COL236,
       ail.COL237,
       ail.COL238,
       ail.COL239,
       ail.COL240,
       ail.COL241,
       ail.COL242,
       ail.COL243,
       ail.COL244,
       ail.COL245,
       ail.COL246,
       ail.COL247,
       ail.COL248,
       ail.COL249,
       ail.COL250 ,
       ail.COL251 ,
       ail.COL252 ,
       ail.COL253 ,
       ail.COL254 ,
       ail.COL256 ,
       ail.COL255 ,
       ail.COL257 ,
       ail.COL258 ,
       ail.COL259 ,
       ail.COL260 ,
       ail.COL261 ,
       ail.COL262 ,
       ail.COL263 ,
       ail.COL264 ,
       ail.COL265 ,
       ail.COL266 ,
       ail.COL267 ,
       ail.COL268 ,
       ail.COL269 ,
       ail.COL270 ,
       ail.COL271 ,
       ail.COL272 ,
       ail.COL273 ,
       ail.COL274 ,
       ail.COL275 ,
       ail.COL276 ,
       ail.COL277 ,
       ail.COL278 ,
       ail.COL279 ,
       ail.COL280 ,
       ail.COL281 ,
       ail.COL282 ,
       ail.COL283 ,
       ail.COL284 ,
       ail.COL285 ,
       ail.COL286 ,
       ail.COL287 ,
       ail.COL288 ,
       ail.COL289 ,
       ail.COL290 ,
       ail.COL291 ,
       ail.COL292 ,
       ail.COL293 ,
       ail.COL294 ,
       ail.COL295 ,
       ail.COL296 ,
       ail.COL297 ,
       ail.COL298 ,
       ail.COL299 ,
       ail.COL300     ,
       ail.SALES_AGENT_EMAIL_ADDRESS,
       ail.RESOURCE_ID,
       ail.location_id,
       ail.contact_point_id,
       ail.orig_system_reference,
       ail.CUSTOM_COLUMN1,
       ail.CUSTOM_COLUMN2,
       ail.CUSTOM_COLUMN3,
       ail.CUSTOM_COLUMN4,
       ail.CUSTOM_COLUMN5,
       ail.CUSTOM_COLUMN6,
       ail.CUSTOM_COLUMN7,
       ail.CUSTOM_COLUMN8,
       ail.CUSTOM_COLUMN9,
       ail.CUSTOM_COLUMN10,
       ail.CUSTOM_COLUMN11,
       ail.CUSTOM_COLUMN12,
       ail.CUSTOM_COLUMN13,
       ail.CUSTOM_COLUMN14,
       ail.CUSTOM_COLUMN15,
       ail.CUSTOM_COLUMN16,
       ail.CUSTOM_COLUMN17,
       ail.CUSTOM_COLUMN18,
       ail.CUSTOM_COLUMN19,
       ail.CUSTOM_COLUMN20,
       ail.CUSTOM_COLUMN21,
       ail.CUSTOM_COLUMN22,
       ail.CUSTOM_COLUMN23,
       ail.CUSTOM_COLUMN24,
       ail.CUSTOM_COLUMN25
    from   ams_list_entries ail,
           ams_act_lists als
   where   als.ACT_LIST_HEADER_ID = ale.list_select_action_id
     and   als.LIST_HEADER_ID = ail.list_header_id
     and   ail.list_entry_source_system_id = ale.list_entry_source_system_id
     and   ail.enabled_flag = 'Y'
     and   rownum <=1 )
  where arc_list_select_action_from = 'LIST'
  and list_header_id = p_list_header_id
  and exists (select 'x'
             from ams_list_entries ail,
                  ams_act_lists als
             where   als.ACT_LIST_HEADER_ID = ale.list_select_action_id
               and   als.LIST_HEADER_ID = ail.list_header_id
               and   ail.list_entry_source_system_id = ale.list_entry_source_system_id
               and   ail.enabled_flag = 'Y' )
  and exists (select 'x'
             from ams_act_lists als1
             where als1.ACT_LIST_HEADER_ID = ale.list_select_action_id
               and als1.LIST_ACTION_TYPE = 'INCLUDE' );
  write_to_act_log(sql%rowcount||' entries updated.','LIST',g_list_header_id,'LOW');

 ELSE -- For List Generation
   write_to_act_log('Generating list(which has selections based on LIST) in update mode.','LIST',g_list_header_id,'LOW');
   update ams_list_entries  ale
   set (
       ale.newly_updated_flag ,
       ale.enabled_flag ,
       ale.SUFFIX,
       ale.FIRST_NAME,
       ale.LAST_NAME,
       ale.CUSTOMER_NAME,
       ale.TITLE,
       ale.ADDRESS_LINE1,
       ale.ADDRESS_LINE2,
       ale.CITY,
       ale.STATE,
       ale.ZIPCODE,
       ale.COUNTRY,
       ale.FAX,
       ale.PHONE,
       ale.EMAIL_ADDRESS,
       ale.COL1,
       ale.COL2,
       ale.COL3,
       ale.COL4,
       ale.COL5,
       ale.COL6,
       ale.COL7,
       ale.COL8,
       ale.COL9,
       ale.COL10,
       ale.COL11,
       ale.COL12,
       ale.COL13,
       ale.COL14,
       ale.COL15,
       ale.COL16,
       ale.COL17,
       ale.COL18,
       ale.COL19,
       ale.COL20,
       ale.COL21,
       ale.COL22,
       ale.COL23,
       ale.COL24,
       ale.COL25,
       ale.COL26,
       ale.COL27,
       ale.COL28,
       ale.COL29,
       ale.COL30,
       ale.COL31,
       ale.COL32,
       ale.COL33,
       ale.COL34,
       ale.COL35,
       ale.COL36,
       ale.COL37,
       ale.COL38,
       ale.COL39,
       ale.COL40,
       ale.COL41,
       ale.COL42,
       ale.COL43,
       ale.COL44,
       ale.COL45,
       ale.COL46,
       ale.COL47,
       ale.COL48,
       ale.COL49,
       ale.COL50,
       ale.COL51,
       ale.COL52,
       ale.COL53,
       ale.COL54,
       ale.COL55,
       ale.COL56,
       ale.COL57,
       ale.COL58,
       ale.COL59,
       ale.COL60,
       ale.COL61,
       ale.COL62,
       ale.COL63,
       ale.COL64,
       ale.COL65,
       ale.COL66,
       ale.COL67,
       ale.COL68,
       ale.COL69,
       ale.COL70,
       ale.COL71,
       ale.COL72,
       ale.COL73,
       ale.COL74,
       ale.COL75,
       ale.COL76,
       ale.COL77,
       ale.COL78,
       ale.COL79,
       ale.COL80,
       ale.COL81,
       ale.COL82,
       ale.COL83,
       ale.COL84,
       ale.COL85,
       ale.COL86,
       ale.COL87,
       ale.COL88,
       ale.COL89,
       ale.COL90,
       ale.COL91,
       ale.COL92,
       ale.COL93,
       ale.COL94,
       ale.COL95,
       ale.COL96,
       ale.COL97,
       ale.COL98,
       ale.COL99,
       ale.COL100,
       ale.COL101,
       ale.COL102,
       ale.COL103,
       ale.COL104,
       ale.COL105,
       ale.COL106,
       ale.COL107,
       ale.COL108,
       ale.COL109,
       ale.COL110,
       ale.COL111,
       ale.COL112,
       ale.COL113,
       ale.COL114,
       ale.COL115,
       ale.COL116,
       ale.COL117,
       ale.COL118,
       ale.COL119,
       ale.COL120,
       ale.COL121,
       ale.COL122,
       ale.COL123,
       ale.COL124,
       ale.COL125,
       ale.COL126,
       ale.COL127,
       ale.COL128,
       ale.COL129,
       ale.COL130,
       ale.COL131,
       ale.COL132,
       ale.COL133,
       ale.COL134,
       ale.COL135,
       ale.COL136,
       ale.COL137,
       ale.COL138,
       ale.COL139,
       ale.COL140,
       ale.COL141,
       ale.COL142,
       ale.COL143,
       ale.COL144,
       ale.COL145,
       ale.COL146,
       ale.COL147,
       ale.COL148,
       ale.COL149,
       ale.COL150,
       ale.COL151,
       ale.COL152,
       ale.COL153,
       ale.COL154,
       ale.COL155,
       ale.COL156,
       ale.COL157,
       ale.COL158,
       ale.COL159,
       ale.COL160,
       ale.COL161,
       ale.COL162,
       ale.COL163,
       ale.COL164,
       ale.COL165,
       ale.COL166,
       ale.COL167,
       ale.COL168,
       ale.COL169,
       ale.COL170,
       ale.COL171,
       ale.COL172,
       ale.COL173,
       ale.COL174,
       ale.COL175,
       ale.COL176,
       ale.COL177,
       ale.COL178,
       ale.COL179,
       ale.COL180,
       ale.COL181,
       ale.COL182,
       ale.COL183,
       ale.COL184,
       ale.COL185,
       ale.COL186,
       ale.COL187,
       ale.COL188,
       ale.COL189,
       ale.COL190,
       ale.COL191,
       ale.COL192,
       ale.COL193,
       ale.COL194,
       ale.COL195,
       ale.COL196,
       ale.COL197,
       ale.COL198,
       ale.COL199,
       ale.COL200,
       ale.COL201,
       ale.COL202,
       ale.COL203,
       ale.COL204,
       ale.COL205,
       ale.COL206,
       ale.COL207,
       ale.COL208,
       ale.COL209,
       ale.COL210,
       ale.COL211,
       ale.COL212,
       ale.COL213,
       ale.COL214,
       ale.COL215,
       ale.COL216,
       ale.COL217,
       ale.COL218,
       ale.COL219,
       ale.COL220,
       ale.COL221,
       ale.COL222,
       ale.COL223,
       ale.COL224,
       ale.COL225,
       ale.COL226,
       ale.COL227,
       ale.COL228,
       ale.COL229,
       ale.COL230,
       ale.COL231,
       ale.COL232,
       ale.COL233,
       ale.COL234,
       ale.COL235,
       ale.COL236,
       ale.COL237,
       ale.COL238,
       ale.COL239,
       ale.COL240,
       ale.COL241,
       ale.COL242,
       ale.COL243,
       ale.COL244,
       ale.COL245,
       ale.COL246,
       ale.COL247,
       ale.COL248,
       ale.COL249,
       ale.COL250 ,
       ale.COL251     ,
       ale.COL252     ,
       ale.COL253     ,
       ale.COL254     ,
       ale.COL256     ,
       ale.COL255     ,
       ale.COL257     ,
       ale.COL258     ,
       ale.COL259     ,
       ale.COL260     ,
       ale.COL261     ,
       ale.COL262     ,
       ale.COL263     ,
       ale.COL264     ,
       ale.COL265     ,
       ale.COL266     ,
       ale.COL267     ,
       ale.COL268     ,
       ale.COL269     ,
       ale.COL270     ,
       ale.COL271     ,
       ale.COL272     ,
       ale.COL273     ,
       ale.COL274     ,
       ale.COL275     ,
       ale.COL276     ,
       ale.COL277     ,
       ale.COL278     ,
       ale.COL279     ,
       ale.COL280     ,
       ale.COL281     ,
       ale.COL282     ,
       ale.COL283     ,
       ale.COL284     ,
       ale.COL285     ,
       ale.COL286     ,
       ale.COL287     ,
       ale.COL288     ,
       ale.COL289     ,
       ale.COL290     ,
       ale.COL291     ,
       ale.COL292     ,
       ale.COL293     ,
       ale.COL294     ,
       ale.COL295     ,
       ale.COL296     ,
       ale.COL297     ,
       ale.COL298     ,
       ale.COL299     ,
       ale.COL300
       ) =
        (select
        'Y',
        'Y',
       ail.SUFFIX,
       ail.FIRST_NAME,
       ail.LAST_NAME,
       ail.CUSTOMER_NAME,
       ail.TITLE,
       ail.ADDRESS_LINE1,
       ail.ADDRESS_LINE2,
       ail.CITY,
       ail.STATE,
       ail.ZIPCODE,
       ail.COUNTRY,
       ail.FAX,
       ail.PHONE,
       ail.EMAIL_ADDRESS,
       ail.COL1,
       ail.COL2,
       ail.COL3,
       ail.COL4,
       ail.COL5,
       ail.COL6,
       ail.COL7,
       ail.COL8,
       ail.COL9,
       ail.COL10,
       ail.COL11,
       ail.COL12,
       ail.COL13,
       ail.COL14,
       ail.COL15,
       ail.COL16,
       ail.COL17,
       ail.COL18,
       ail.COL19,
       ail.COL20,
       ail.COL21,
       ail.COL22,
       ail.COL23,
       ail.COL24,
       ail.COL25,
       ail.COL26,
       ail.COL27,
       ail.COL28,
       ail.COL29,
       ail.COL30,
       ail.COL31,
       ail.COL32,
       ail.COL33,
       ail.COL34,
       ail.COL35,
       ail.COL36,
       ail.COL37,
       ail.COL38,
       ail.COL39,
       ail.COL40,
       ail.COL41,
       ail.COL42,
       ail.COL43,
       ail.COL44,
       ail.COL45,
       ail.COL46,
       ail.COL47,
       ail.COL48,
       ail.COL49,
       ail.COL50,
       ail.COL51,
       ail.COL52,
       ail.COL53,
       ail.COL54,
       ail.COL55,
       ail.COL56,
       ail.COL57,
       ail.COL58,
       ail.COL59,
       ail.COL60,
       ail.COL61,
       ail.COL62,
       ail.COL63,
       ail.COL64,
       ail.COL65,
       ail.COL66,
       ail.COL67,
       ail.COL68,
       ail.COL69,
       ail.COL70,
       ail.COL71,
       ail.COL72,
       ail.COL73,
       ail.COL74,
       ail.COL75,
       ail.COL76,
       ail.COL77,
       ail.COL78,
       ail.COL79,
       ail.COL80,
       ail.COL81,
       ail.COL82,
       ail.COL83,
       ail.COL84,
       ail.COL85,
       ail.COL86,
       ail.COL87,
       ail.COL88,
       ail.COL89,
       ail.COL90,
       ail.COL91,
       ail.COL92,
       ail.COL93,
       ail.COL94,
       ail.COL95,
       ail.COL96,
       ail.COL97,
       ail.COL98,
       ail.COL99,
       ail.COL100,
       ail.COL101,
       ail.COL102,
       ail.COL103,
       ail.COL104,
       ail.COL105,
       ail.COL106,
       ail.COL107,
       ail.COL108,
       ail.COL109,
       ail.COL110,
       ail.COL111,
       ail.COL112,
       ail.COL113,
       ail.COL114,
       ail.COL115,
       ail.COL116,
       ail.COL117,
       ail.COL118,
       ail.COL119,
       ail.COL120,
       ail.COL121,
       ail.COL122,
       ail.COL123,
       ail.COL124,
       ail.COL125,
       ail.COL126,
       ail.COL127,
       ail.COL128,
       ail.COL129,
       ail.COL130,
       ail.COL131,
       ail.COL132,
       ail.COL133,
       ail.COL134,
       ail.COL135,
       ail.COL136,
       ail.COL137,
       ail.COL138,
       ail.COL139,
       ail.COL140,
       ail.COL141,
       ail.COL142,
       ail.COL143,
       ail.COL144,
       ail.COL145,
       ail.COL146,
       ail.COL147,
       ail.COL148,
       ail.COL149,
       ail.COL150,
       ail.COL151,
       ail.COL152,
       ail.COL153,
       ail.COL154,
       ail.COL155,
       ail.COL156,
       ail.COL157,
       ail.COL158,
       ail.COL159,
       ail.COL160,
       ail.COL161,
       ail.COL162,
       ail.COL163,
       ail.COL164,
       ail.COL165,
       ail.COL166,
       ail.COL167,
       ail.COL168,
       ail.COL169,
       ail.COL170,
       ail.COL171,
       ail.COL172,
       ail.COL173,
       ail.COL174,
       ail.COL175,
       ail.COL176,
       ail.COL177,
       ail.COL178,
       ail.COL179,
       ail.COL180,
       ail.COL181,
       ail.COL182,
       ail.COL183,
       ail.COL184,
       ail.COL185,
       ail.COL186,
       ail.COL187,
       ail.COL188,
       ail.COL189,
       ail.COL190,
       ail.COL191,
       ail.COL192,
       ail.COL193,
       ail.COL194,
       ail.COL195,
       ail.COL196,
       ail.COL197,
       ail.COL198,
       ail.COL199,
       ail.COL200,
       ail.COL201,
       ail.COL202,
       ail.COL203,
       ail.COL204,
       ail.COL205,
       ail.COL206,
       ail.COL207,
       ail.COL208,
       ail.COL209,
       ail.COL210,
       ail.COL211,
       ail.COL212,
       ail.COL213,
       ail.COL214,
       ail.COL215,
       ail.COL216,
       ail.COL217,
       ail.COL218,
       ail.COL219,
       ail.COL220,
       ail.COL221,
       ail.COL222,
       ail.COL223,
       ail.COL224,
       ail.COL225,
       ail.COL226,
       ail.COL227,
       ail.COL228,
       ail.COL229,
       ail.COL230,
       ail.COL231,
       ail.COL232,
       ail.COL233,
       ail.COL234,
       ail.COL235,
       ail.COL236,
       ail.COL237,
       ail.COL238,
       ail.COL239,
       ail.COL240,
       ail.COL241,
       ail.COL242,
       ail.COL243,
       ail.COL244,
       ail.COL245,
       ail.COL246,
       ail.COL247,
       ail.COL248,
       ail.COL249,
       ail.COL250 ,
       ail.COL251 ,
       ail.COL252 ,
       ail.COL253 ,
       ail.COL254 ,
       ail.COL256 ,
       ail.COL255 ,
       ail.COL257 ,
       ail.COL258 ,
       ail.COL259 ,
       ail.COL260 ,
       ail.COL261 ,
       ail.COL262 ,
       ail.COL263 ,
       ail.COL264 ,
       ail.COL265 ,
       ail.COL266 ,
       ail.COL267 ,
       ail.COL268 ,
       ail.COL269 ,
       ail.COL270 ,
       ail.COL271 ,
       ail.COL272 ,
       ail.COL273 ,
       ail.COL274 ,
       ail.COL275 ,
       ail.COL276 ,
       ail.COL277 ,
       ail.COL278 ,
       ail.COL279 ,
       ail.COL280 ,
       ail.COL281 ,
       ail.COL282 ,
       ail.COL283 ,
       ail.COL284 ,
       ail.COL285 ,
       ail.COL286 ,
       ail.COL287 ,
       ail.COL288 ,
       ail.COL289 ,
       ail.COL290 ,
       ail.COL291 ,
       ail.COL292 ,
       ail.COL293 ,
       ail.COL294 ,
       ail.COL295 ,
       ail.COL296 ,
       ail.COL297 ,
       ail.COL298 ,
       ail.COL299 ,
       ail.COL300
    from   ams_list_entries ail,
           ams_list_select_actions als
   where   als.list_select_action_id = ale.list_select_action_id
     and   als.incl_object_id = ail.list_header_id
     and   ail.list_entry_source_system_id = ale.list_entry_source_system_id
     and   ail.enabled_flag = 'Y'
     and   rownum <=1 )
  where arc_list_select_action_from = 'LIST'
  and list_header_id = p_list_header_id
  and exists (select 'x'
    from   ams_list_entries ail,
           ams_list_select_actions als
   where   als.list_select_action_id = ale.list_select_action_id
     and   als.incl_object_id = ail.list_header_id
     and   ail.list_entry_source_system_id = ale.list_entry_source_system_id
     and   ail.enabled_flag = 'Y' )
  and exists (select 'x'
             from ams_list_select_actions als1
             where als1.list_select_action_id = ale.list_select_action_id
               and als1.list_action_type = 'INCLUDE' );
  write_to_act_log(sql%rowcount||' entries updated.','LIST',g_list_header_id,'LOW');
end if;
end;
procedure update_import_list_entries(p_list_header_id in number) is
cursor c1 is
select imp.import_type
from  ams_imp_list_headers_all imp,
      ams_list_select_actions ail,
      ams_list_headers_all alh
where alh.list_header_id = p_list_header_id
and   alh.list_header_id = ail.action_used_by_id
and   ail.arc_action_used_by = 'LIST'
and   ail.arc_incl_object_from  = 'IMPH'
and   imp.import_list_header_id = ail.incl_object_id ;
l_b2b_flag varchar2(5) := 'U' ;
begin
  open c1;
  fetch c1 into l_b2b_flag ;
  close c1;
  write_to_act_log('Import type is '||l_b2b_flag,'LIST',g_list_header_id,'LOW');
  if l_b2b_flag = 'B2B' then
     write_to_act_log('Generating list(which has selections based on imported B2B list) in update mode.','LIST',g_list_header_id,'LOW');
     update ams_list_entries  ale
     set (
       ale.newly_updated_flag ,
--       ale.enabled_flag ,
       ale.ADDRESS_LINE1,
       ale.ADDRESS_LINE2,
       ale.COL127,
       ale.COL128,
       ale.COL227,
       ale.CITY,
       ale.COUNTRY,
       ale.COL118,
       ale.COL142,
       ale.COL138,
       ale.COL122,
       ale.EMAIL_ADDRESS,
       ale.COL239,
       ale.FIRST_NAME,
       ale.COL243,
       ale.COL144,
       ale.LAST_NAME,
       ale.COL251,
       ale.COL252,
       ale.COL137,
       ale.SUFFIX,
       ale.COL259,
       ale.COL6,
       ale.COL5,
       ale.COL7,
       ale.PHONE,
       ale.ZIPCODE,
       ale.COL120,
       ale.STATE,
       ale.COL125,
       ale.COL2,
       ale.TITLE,
       ale.customer_name,
       ale.party_id,
       ale.COL276 ,
       ale.NOTES                                    ,
              ale.VEHICLE_RESPONSE_CODE                   ,
              ale.SALES_AGENT_EMAIL_ADDRESS               ,
              ale.RESOURCE_ID                              ,
              ale.col147,
              ale.location_id ,
              ale.contact_point_id ,
              ale.orig_system_reference,
              col116,
              col117
       )
     =
     ( select
           'Y',
--           'Y',
           ail.ADDRESS1,
           ail.ADDRESS2,
           ail.BEST_TIME_CONTACT_BEGIN,
           ail.BEST_TIME_CONTACT_END,
           ail.CEO_NAME,
           ail.CITY,
           ail.COUNTRY,
           ail.COUNTY,
           ail.DECISION_MAKER_FLAG,
           ail.DEPARTMENT,
           ail.DUNS_NUMBER,
           ail.EMAIL_ADDRESS,
           ail.EMPLOYEES_TOTAL,
           ail.PERSON_FIRST_NAME,
           ail.FISCAL_YEAREND_MONTH,
           ail.JOB_TITLE,
           ail.PERSON_LAST_NAME,
           ail.LEGAL_STATUS,
           ail.LINE_OF_BUSINESS,
           ail.PERSON_MIDDLE_NAME,
           ail.PERSON_NAME_SUFFIX,
           ail.party_name,
           ail.PHONE_AREA_CODE,
           ail.PHONE_COUNTRY_CODE,
           ail.PHONE_EXTENTION,
           ail.PHONE_NUMBER,
           ail.POSTAL_CODE,
           ail.PROVINCE,
           ail.STATE,
           ail.TAX_REFERENCE,
           ail.TIME_ZONE,
           ail.PERSON_NAME_PREFIX,
           ail.party_name
           ,ail.party_id
           ,ail.YEAR_ESTABLISHED
           ,ail.NOTES                                    ,
              ail.VEHICLE_RESPONSE_CODE                   ,
              ail.SALES_AGENT_EMAIL_ADDRESS               ,
              ail.RESOURCE_ID                              ,
              ail.ORGANIZATION_ID,
             ail.location_id ,
             ail.contact_point_id ,
             ail.orig_system_reference,
              ail.address3,
              ail.address4
    from   ams_hz_b2b_mapping_v ail,
           ams_list_select_actions als
   where   ail.import_list_header_id = als.incl_object_id
     and   als.list_select_action_id = ale.list_select_action_id
     and   ail.party_id = ale.list_entry_source_system_id
     and   ail.IMPORT_SOURCE_LINE_ID = ale.IMP_SOURCE_LINE_ID)
  where arc_list_select_action_from = 'IMPH'
  and list_header_id = p_list_header_id
  and exists (select 'x'
             from ams_list_select_actions als1
             where als1.list_select_action_id = ale.list_select_action_id
               and als1.list_action_type = 'INCLUDE' );
  write_to_act_log(sql%rowcount||' entries updated.','LIST',g_list_header_id,'LOW');
  end if;
  if l_b2b_flag = 'B2C' then
     write_to_act_log('Generating list(which has selections based on imported B2C list) in update mode.','LIST',g_list_header_id,'LOW');
     update ams_list_entries  ale
     set (
       ale.newly_updated_flag ,
--       ale.enabled_flag ,
       ale.customer_name,
       ale.ADDRESS_LINE1,
       ale.ADDRESS_LINE2,
       ale.CITY,
       ale.COL127,
       ale.COL128,
       ale.COL118,
       ale.COUNTRY,
       ale.FIRST_NAME,
       ale.LAST_NAME,
       ale.COL137,
       ale.EMAIL_ADDRESS,
       ale.col70,
       ale.COL145,
       ale.STATE,
       ale.ZIPCODE,
       ale.COL120,
       ale.TITLE,
       ale.COL2,
       ale.col5,
       ale.col6,
       ale.PHONE,
       ale.col7,
       ale.party_id,
       ale.SUFFIX  ,
       ale.NOTES                                    ,
              ale.VEHICLE_RESPONSE_CODE                   ,
              ale.SALES_AGENT_EMAIL_ADDRESS               ,
              ale.RESOURCE_ID                              ,
              ale.location_id ,
              ale.contact_point_id ,
              ale.orig_system_reference,
              ale.col116,
              ale.col117
       )
      =
     (select
           'Y',
--           'Y',
           ail.PERSON_LAST_NAME || ' , ' || ail.PERSON_FIRST_NAME ,
           ail.ADDRESS1,
           ail.ADDRESS2,
           ail.CITY,
           ail.BEST_TIME_CONTACT_BEGIN,
           ail.BEST_TIME_CONTACT_END,
           ail.COUNTY,
           ail.COUNTRY,
           ail.PERSON_FIRST_NAME,
           ail.PERSON_LAST_NAME,
           ail.PERSON_MIDDLE_NAME,
           ail.EMAIL_ADDRESS,
           ail.GENDER,
           ail.HOUSEHOLD_INCOME,
           ail.STATE,
           ail.POSTAL_CODE,
           ail.PROVINCE,
           ail.PERSON_NAME_PREFIX,
           ail.TIME_ZONE  ,
           ail.PHONE_COUNTRY_CODE,
           ail.PHONE_AREA_CODE   ,
           ail.PHONE_NUMBER      ,
           ail.PHONE_EXTENTION   ,
           ail.party_id,
           ail.PERSON_NAME_SUFFIX ,
           ail.NOTES                                    ,
              ail.VEHICLE_RESPONSE_CODE                   ,
              ail.SALES_AGENT_EMAIL_ADDRESS               ,
              ail.RESOURCE_ID                              ,
          ail.location_id ,
          ail.contact_point_id ,
          ail.orig_system_reference,
              ail.address3,
              ail.address4
    from   ams_hz_b2c_mapping_v ail,
           ams_list_select_actions als
   where   ail.import_list_header_id = als.incl_object_id
     and   als.list_select_action_id = ale.list_select_action_id
     and   ail.party_id = ale.list_entry_source_system_id
     and   ail.IMPORT_SOURCE_LINE_ID = ale.IMP_SOURCE_LINE_ID)
  where   ale.arc_list_select_action_from = 'IMPH'
  and ale.list_header_id = p_list_header_id
  and exists (select 'x'
             from ams_list_select_actions als1
             where als1.list_select_action_id = ale.list_select_action_id
               and als1.list_action_type = 'INCLUDE' );
  write_to_act_log(sql%rowcount||' entries updated.','LIST',g_list_header_id,'LOW');
 end if;
end;
--
-- NAME
--   GET_LIST_ENTRY_DATA.
--
-- PURPOSE
--
--  01/24/2001 GJOBY      Modified for hornet
-- END OF COMMENTS

PROCEDURE GET_LIST_ENTRY_DATA
                 (p_list_header_id in number,
                  p_additional_where_condition in varchar2,
                  x_return_status OUT NOCOPY varchar2 )IS

--------------------------------------------------------------------------
--Retrieve all mapping types used in  an action workbook sql statement. --
--this includes all master and sub types, if a type is a sub type there --
--will be values in the c.sub_source_type_pk_column and source_type_code--
--fields.                                                               --
--------------------------------------------------------------------------
CURSOR  C_MAPPING_TYPES_USED(p_list_header_id
                             AMS_LIST_HEADERS_ALL.LIST_HEADER_ID%TYPE)
IS SELECT a.list_source_type_id,
	  a.source_type_code,
	  a.source_object_name,
	  a.source_object_pk_field,
	  a.master_source_type_flag
     FROM ams_list_src_types a,
	  ams_list_src_type_usages b
    WHERE a.source_type_code       = b.source_type_code
      AND b.list_header_id         = p_list_header_id
      AND master_source_type_flag = 'Y'  ;
cursor c_child_mapping(c_master_type_id in number) is
	SELECT al.SUB_SOURCE_TYPE_ID,
               al.SUB_SOURCE_TYPE_PK_COLUMN,
               als.source_object_name,
               als.source_type_code,
               al.master_source_type_pk_column
	 FROM ams_list_src_type_assocs al,
              ams_list_src_types als ,
              ams_list_src_type_usages b
	WHERE al.MASTER_SOURCE_TYPE_ID   = c_master_type_id
	  AND als.list_source_type_id    = al.sub_source_type_id
	  AND als.source_type_code       = b.source_type_code
	  AND b.list_header_id           = p_list_header_id ;
l_list_source_type_id      AMS_LIST_SRC_TYPES.LIST_SOURCE_TYPE_ID%TYPE;
l_source_type_code         AMS_LIST_SRC_TYPES.SOURCE_TYPE_CODE%TYPE;
l_source_object_name       AMS_LIST_SRC_TYPES.SOURCE_OBJECT_NAME%TYPE;
l_source_object_pk_field   AMS_LIST_SRC_TYPES.SOURCE_OBJECT_PK_FIELD%TYPE;
l_master_source_type_flag  AMS_LIST_SRC_TYPES.MASTER_SOURCE_TYPE_FLAG%TYPE;
l_sub_source_type_pk_column      AMS_LIST_SRC_TYPE_ASSOCS.SUB_SOURCE_TYPE_PK_COLUMN%TYPE;
l_dummy_pk_column      AMS_LIST_SRC_TYPE_ASSOCS.master_SOURCE_TYPE_PK_COLUMN%TYPE;
l_SUB_SOURCE_TYPE_ID      number;
l_SUB_SOURCE_OBJECT_NAME      varchar2(300);
l_sub_source_type_code   AMS_LIST_SRC_TYPES.SOURCE_TYPE_CODE%TYPE;
l_sub_source_master_type   AMS_LIST_SRC_TYPES.SOURCE_TYPE_CODE%TYPE;
l_source_code              AMS_LIST_SRC_TYPES.SOURCE_TYPE_CODE%TYPE;

------------------------------------------------------------
--Retrive all the fields to be used for each mapping type.--
------------------------------------------------------------
CURSOR C_MAPPING_TYPE_FIELDS(p_list_source_type_id
                             AMS_LIST_SRC_TYPES.LIST_SOURCE_TYPE_ID%TYPE)
IS
SELECT field_column_name,
       source_column_name
FROM   ams_list_src_fields
WHERE  list_source_type_id = p_list_source_type_id
  and  used_in_list_entries = 'Y';


------------------------------------------------
--a table which holds list entry column names.--
------------------------------------------------
TYPE t_list_columns is Table of VARCHAR2(30) index by binary_integer;

--------------------------------------------------
--a local table variable of type t_list_columns.--
--------------------------------------------------
l_list_entry_columns t_list_columns;

--------------------------------------------------
--a local table variable of type t_list_columns.--
--------------------------------------------------
l_source_columns t_list_columns;

--------------------------------------------------------
--Used to initialize variables of type t_list_columns.--
--------------------------------------------------------
l_NULL_table t_list_columns;

------------------------------------------
--the number of columns for the mapping.--
------------------------------------------
l_column_count NUMBER;
l_iterator NUMBER;
l_sub_type_detected NUMBER;

--------------------------------------------------------------
--The composite strings which compose a valid SQL statement.--
--------------------------------------------------------------
l_update_str      VARCHAR2(32767);
l_select_str      VARCHAR2(32767);
l_header_clause   VARCHAR2(1000);
l_type_clause     VARCHAR2(1000);
l_where_clause    VARCHAR2(1000);

l_add_where_clause   VARCHAR2(2000);
cursor c_source_map is
select field_column_name
from ams_list_src_fields
where list_source_type_id = l_list_source_type_id--l_sub_source_type_id
and   source_column_name = l_dummy_pk_column;

l_dummy_sr_column      AMS_LIST_SRC_FIELDS.Field_column_name%TYPE;
l_no_of_chunks number;

x_msg_count        number;
x_msg_data         varchar2(1000);
l_tot_cnt          number;
l_null		   varchar2(30) := null;
l_remote_cnt       number := 0;


BEGIN

    if g_list_header_id is null  then
       g_list_header_id := p_list_header_id;
    end if;

    if nvl(g_remote_list,'N') = 'Y' then
       execute immediate 'select count(1) from ams_list_entries@'||g_database_link||' where list_header_id = '||p_list_header_id||' and rownum = 1' into l_remote_cnt;
       if l_remote_cnt = 0 then
          write_to_act_log('No entries in remote schema for this list/target group. Cannot update.', 'LIST', g_list_header_id,'LOW');
          x_return_status := 'S';
	  return;
       else
          write_to_act_log('List entries will be updated in remote schema.', 'LIST', g_list_header_id,'LOW');
          g_remote_list_gen := 'Y';
       end if;
    end if;

    write_to_act_log('Executing procedure get_list_entry_data.', 'LIST', g_list_header_id,'LOW');
    OPEN C_MAPPING_TYPES_USED(p_list_header_id);
    LOOP
      l_update_str         := 'UPDATE ams_list_entries SET (';
      l_select_str         := ' ) = ( SELECT ';
      l_header_clause      := ' AND list_header_id = '||
                               to_char(p_list_header_id);
      l_type_clause        := ' AND list_entry_source_system_type = ';

      l_add_where_clause   :=  ' AND arc_list_select_action_from not in  ' ||
                                   -- ' (''LIST'', ''IMPH'') ';LPO
				   ' (''IMPH'') ';

      l_add_where_clause  := l_add_where_clause||' and enabled_flag = '||'''Y''';

      l_add_where_clause   :=  l_add_where_clause ||
                               p_additional_where_condition ;

      l_sub_type_detected  :=0;
      l_iterator           :=0;
      l_list_entry_columns := l_NULL_table;
      l_source_columns     := l_NULL_table;

     FETCH C_MAPPING_TYPES_USED INTO l_list_source_type_id,
                                      l_source_type_code,
                                      l_source_object_name,
                                      l_source_object_pk_field,
                                      l_master_source_type_flag;

     write_to_act_log('List source type id = '||l_list_source_type_id , 'LIST', g_list_header_id,'LOW');
     write_to_act_log('List source type code = '||l_source_type_code , 'LIST', g_list_header_id,'LOW');
     write_to_act_log('Source object name = '||l_source_object_name , 'LIST', g_list_header_id,'LOW');
     write_to_act_log('Source object primary key = '||l_source_object_pk_field, 'LIST', g_list_header_id,'LOW');
     write_to_act_log('Master source type flag= '||l_master_source_type_flag, 'LIST', g_list_header_id,'LOW');
     EXIT WHEN C_MAPPING_TYPES_USED%NOTFOUND;

      ------------------------------------------------------------
      --getting the field mappings between the mapping type     --
      --source object and the list entry table.                 --
      ------------------------------------------------------------
      OPEN C_MAPPING_TYPE_FIELDS(l_list_source_type_id);
      LOOP
         l_iterator := l_iterator + 1;
         FETCH c_mapping_type_fields
         INTO l_list_entry_columns(l_iterator),
              l_source_columns(l_iterator);
         EXIT WHEN  C_MAPPING_TYPE_FIELDS%NOTFOUND;
         write_to_act_log('Field column name = '||l_list_entry_columns(l_iterator), 'LIST', g_list_header_id,'LOW');
         write_to_act_log('Source column name = '||l_source_columns(l_iterator), 'LIST', g_list_header_id,'LOW');
      END LOOP;
      CLOSE C_MAPPING_TYPE_FIELDS;

      FOR i IN l_list_entry_columns.FIRST .. l_list_entry_columns.LAST LOOP
            l_update_str := l_update_str||l_list_entry_columns(i)||',';
            l_select_str := l_select_str||l_source_columns(i)||',';
      END LOOP;
      l_update_str := substr(l_update_str,1,length(l_update_str) - 1);
      l_select_str := substr(l_select_str,1,length(l_select_str) - 1);

      --l_update_str := substrb(l_update_str,1,length(l_update_str)-1);
      --l_select_str := substrb(l_select_str,1,length(l_select_str)-1);
     /* l_update_str := l_update_str || 'newly_updated_flag' ;
      l_select_str := l_select_str || ''''|| 'Y'||'''';
      l_update_str := l_update_str || ','|| 'enabled_flag' ;
      l_select_str := l_select_str || ','|| ''''|| 'Y'||'''';*/

      l_select_str := l_select_str||' FROM '||
                      l_source_object_name||' WHERE '||
                      l_source_object_pk_field
                      ||' = list_entry_source_system_id ';
      l_type_clause := l_type_clause||' :b2 ';
      l_source_code :=  l_source_type_code;
      l_where_clause:= ' WHERE list_header_id = :b1 ';

      l_update_str := l_update_str||l_select_str||')'||
                       l_where_clause||l_type_clause || l_add_where_clause;
      write_to_act_log('Source_code = '||l_source_code, 'LIST', g_list_header_id,'LOW');
      write_to_act_log('Update statement : '||l_update_str, 'LIST', g_list_header_id,'LOW');

      if nvl(g_remote_list,'N') = 'N' then
         write_to_act_log('Executing the update statement in local schema', 'LIST', g_list_header_id,'LOW');
         EXECUTE IMMEDIATE l_update_str using to_char(p_list_header_id) , l_source_code;
      else
        write_to_act_log('Executing the update statement in remote schema', 'LIST', g_list_header_id,'LOW');
	execute immediate
	'BEGIN
	 AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
	' END;'
	 using  '1',
	 l_null,
	 'T',
	 l_null,
	 OUT x_return_status,
	 OUT x_msg_count,
	 OUT x_msg_data,
	 g_list_header_id,
	 l_update_str,
	 l_source_code,
	 OUT l_tot_cnt,
	 'UPDATE';
      end if;

    write_to_act_log('Identifying attributes from child datasource', 'LIST',g_list_header_id,'LOW');

    OPEN c_child_mapping(l_list_source_type_id);
    LOOP
      l_dummy_pk_column := '';
      l_dummy_sr_column := '';
     FETCH c_child_mapping
           INTO l_SUB_SOURCE_TYPE_ID,
                l_SUB_SOURCE_TYPE_PK_COLUMN,
                l_SUB_SOURCE_OBJECT_NAME,
                l_sub_source_type_code,
                l_dummy_pk_column;

      EXIT WHEN c_child_mapping%NOTFOUND;
      if l_dummy_pk_column is not null then
         open c_source_map ;
         fetch c_source_map into l_dummy_sr_column;
         close c_source_map ;
         --l_dummy_sr_column := '';
      end if;
       l_iterator := 0;
      l_list_entry_columns := l_NULL_table;
      l_source_columns     := l_NULL_table;
      l_update_str         := 'UPDATE ams_list_entries SET (';
      l_select_str         := ' ) = ( SELECT ';
      l_header_clause      := ' AND list_header_id = '||
                               to_char(p_list_header_id);
      l_type_clause        := ' AND list_entry_source_system_type = ';
      l_add_where_clause       := ' AND arc_list_select_action_from not in  ' ||
                                   -- ' (''LIST'', ''IMPH'') ';LPO
				   ' (''IMPH'') ';
      l_add_where_clause  := l_add_where_clause || ' and enabled_flag = '||'''Y''';
      l_add_where_clause       :=  l_add_where_clause ||
                               p_additional_where_condition ;


      OPEN C_MAPPING_TYPE_FIELDS(l_sub_source_type_id);
      LOOP
        l_iterator := l_iterator + 1;
        FETCH c_mapping_type_fields
         INTO l_list_entry_columns(l_iterator),
              l_source_columns(l_iterator);
         EXIT WHEN  C_MAPPING_TYPE_FIELDS%NOTFOUND;
         write_to_act_log('Field column name = '||l_list_entry_columns(l_iterator), 'LIST', g_list_header_id,'LOW');
         write_to_act_log('Source column name = '||l_source_columns(l_iterator), 'LIST', g_list_header_id,'LOW');
      END LOOP;
      CLOSE C_MAPPING_TYPE_FIELDS;

      if l_list_entry_columns.count > 0 then
         FOR i IN l_list_entry_columns.FIRST .. l_list_entry_columns.LAST LOOP
            l_update_str := l_update_str||l_list_entry_columns(i)||',';
            l_select_str := l_select_str||l_source_columns(i)||',';
         END LOOP;
         l_update_str := substrb(l_update_str,1,length(l_update_str)-1);
         l_select_str := substrb(l_select_str,1,length(l_select_str)-1);

         if l_dummy_sr_column is NULL OR l_SUB_SOURCE_TYPE_PK_COLUMN = l_dummy_sr_column then
            l_select_str := l_select_str||' FROM '||
                            l_SUB_SOURCE_OBJECT_NAME||' WHERE '||
                            l_SUB_SOURCE_TYPE_PK_COLUMN
                            ||' = list_entry_source_system_id ';
         else

             l_select_str := l_select_str||' FROM '||
                             l_SUB_SOURCE_OBJECT_NAME||' WHERE '||
                             l_SUB_SOURCE_TYPE_PK_COLUMN
                            ||' = ' || l_dummy_sr_column ;
          end if;
          l_type_clause := l_type_clause||' :b2 ';
          l_source_code :=  l_source_type_code;
          l_where_clause:= ' WHERE list_header_id = :b1 ';

          l_update_str := l_update_str||l_select_str||')'||
                          l_where_clause||l_type_clause || l_add_where_clause;

          l_no_of_chunks  := ceil(length(l_update_str)/2000 );
          for i in 1 ..l_no_of_chunks
          loop
             write_to_act_log(substrb(l_update_str,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
          end loop;
          write_to_act_log('Source_code = '||l_source_code, 'LIST', g_list_header_id,'LOW');
          if nvl(g_remote_list,'N') = 'N' then
             EXECUTE IMMEDIATE l_update_str using to_char(p_list_header_id) , l_source_code;
          else
	     execute immediate
	     'BEGIN
              AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
             ' END;'
             using  '1',
             l_null,
             'T',
             l_null,
             OUT x_return_status,
             OUT x_msg_count,
             OUT x_msg_data,
             g_list_header_id,
             l_update_str,
             l_source_code,
             OUT l_tot_cnt,
             'UPDATE';
	     g_remote_list_gen := 'Y';
          end if;
       else
          write_to_act_log('No field is updated since no field is mapped for data source : '||l_SUB_SOURCE_OBJECT_NAME, 'LIST', g_list_header_id,'LOW');
      end if; -- if l_list_entry_columns.count > 0 then
    END LOOP;
    CLOSE c_child_mapping;
    END LOOP;
    CLOSE C_MAPPING_TYPES_USED;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
    write_to_act_log('Calling update_list_entries to update selections based on list.','LIST', g_list_header_id,'LOW');
   -- update_list_entries(p_list_header_id); LPO
    write_to_act_log('Calling update_import_list_entries to update selections based on import.','LIST', g_list_header_id,'LOW');
    update_import_list_entries (p_list_header_id);
EXCEPTION
  WHEN OTHERS THEN

    IF(C_MAPPING_TYPES_USED%ISOPEN )THEN
       CLOSE  C_MAPPING_TYPES_USED;
    END IF;

    IF(C_MAPPING_TYPE_FIELDS%ISOPEN )THEN
         CLOSE  C_MAPPING_TYPE_FIELDS;
    END IF;

    write_to_act_log('Error while generating list in update mode : '||sqlerrm||sqlcode, 'LIST', g_list_header_id,'HIGH');
    x_return_status := FND_API.G_RET_STS_ERROR;
END GET_LIST_ENTRY_DATA;


-- START OF COMMENTS
-- NAME  :   GENERATE_LIST.
-- PURPOSE
--   1. Public Procedure which when called will generate a set of list
--      entries into the ams_list_entries table.
-- HISTORY
--   06/01/1999        tdonohoe            created
--   01/24/2001        gjoby               Re-Created for Hornet
-- END OF COMMENTS
-------------------------------------------------------------------------------

PROCEDURE GENERATE_LIST
( p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_header_id         IN     NUMBER,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_msg_count              OUT NOCOPY    NUMBER,
  x_msg_data               OUT NOCOPY    VARCHAR2) IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'GENERATE_LIST';
  l_api_version         CONSTANT NUMBER        := 1.0;

  -----------------------------------------------------------
  --The no. of entries flagged as duplicates for this list.--
  --Only populated if deduplication is requested.          --
  -----------------------------------------------------------
  --gjoby check if l_no_of_duplicates required
  l_no_of_duplicates      NUMBER := 0;

  -- Two records are required for init rec and complete rec
  -- Table ams_list_headers_all_tl and ams_list_headers_all
  l_listheader_rec        ams_listheader_pvt.list_header_rec_type;
  l_tmp_listheader_rec    ams_listheader_pvt.list_header_rec_type;

  -- Two records are required for init rec and complete rec
  -- Table ams_list_select_actions
  l_listaction_rec        ams_listaction_pvt.action_rec_type;
  l_tmp_listaction_rec    ams_listaction_pvt.action_rec_type;
  l_no_of_rows_in_list number ;
  cursor c_get_rows (c_list_header_id in number ) is
  select no_of_rows_in_list
  from ams_list_headers_all
  where list_header_id = c_list_header_id ;
  l_error_position       varchar2(100);

  cursor c_remote_list is
  select nvl(stypes.remote_flag,'N') ,database_link
    from ams_list_src_types stypes, ams_list_headers_all list
   where list.list_source_type = stypes.source_type_code
     and list_header_id  =  p_list_header_id;

  l_list_selection 	varchar2(1);
  l_onlylist_selection  varchar2(1);
  l_no_of_rows  number := 0;

cursor c_check_gen_mode is
select nvl(no_of_rows_in_list ,0)
  from ams_list_headers_all
 where list_header_id = p_list_header_id;

  cursor c_list_selection is
  select 'Y' from ams_list_select_actions
   where  action_used_by_id = p_list_header_id
     and  arc_action_used_by = 'LIST'
     and  arc_incl_object_from in ('CELL','DIWB','SQL');

  cursor c_only_list_selection is
  select 'Y' from ams_list_select_actions act, ams_list_headers_all head
   where  act.action_used_by_id = p_list_header_id
   and  act.arc_incl_object_from = 'LIST' and act.arc_action_used_by = 'LIST'
   and  act.INCL_OBJECT_ID = head.list_header_id
   and  head.status_code = 'AVAILABLE'
   and  head.MIGRATION_DATE is null;

l_null		varchar2(30) := null;
l_total_recs	number;
l_request_id    number :=0;
--Bug 5235979. Bmuthukr

/* cursor c1 is
    SELECT list_rule_id
       FROM ams_list_rule_usages
       WHERE list_header_id = g_list_header_id;*/

CURSOR C1 IS
SELECT us.list_rule_id
  FROM ams_list_rule_usages us, ams_list_rules_all rules
 WHERE us.list_header_id = g_list_header_id
   AND us.list_rule_id = rules.list_rule_id
   AND rules.list_source_type = l_listheader_rec.list_source_type
   AND rules.list_rule_type = 'TARGET';

-- Ends changes

l_list_rule_id number := 0;
l_action varchar2(30) := 'LIST';

l_list_field_mapped  varchar2(1);

-- SOLIN, bug 4410333
-- check whether datasource is enabled.
cursor c_check_datasource(c_list_header_id NUMBER) is
  SELECT a.enabled_flag
  FROM ams_list_src_types a,
       ams_list_headers_all b
  WHERE a.source_type_code = b.list_source_type
    AND b.list_header_id = c_list_header_id;

l_ds_enabled_flag      VARCHAR2(1);
-- SOLIN, end

cursor c_master_ds_fields_mapped is
select 'Y' from ams_list_src_fields fd, ams_list_headers_all hd, ams_list_src_types ty
where hd.list_header_id = p_list_header_id
  and hd.LIST_SOURCE_TYPE = ty.source_type_code
  and ty.list_source_type_id = fd.LIST_SOURCE_TYPE_ID
  and fd.FIELD_COLUMN_NAME is NOT NULL;

cursor c_child_ds_fields_mapped is
select 'Y' from ams_list_src_fields fd, ams_list_headers_all hd, ams_list_src_types ty,
ams_list_src_type_assocs ats
where hd.list_header_id = p_list_header_id
  and hd.LIST_SOURCE_TYPE = ty.source_type_code
  and ty.list_source_type_id = ats.master_source_type_id
  and ats.sub_source_type_id = fd.LIST_SOURCE_TYPE_ID
  and fd.FIELD_COLUMN_NAME is NOT NULL;

-- SOLIN, bug 3484653
CURSOR c_get_dup_fields(c_list_header_id NUMBER) IS
SELECT min(master_child.field_column_name1) ,count(master_child.field_column_name) from
  (
  SELECT d.field_column_name field_column_name1,d.field_column_name
  FROM ams_list_src_types a,
       ams_list_headers_all b,
       ams_list_src_fields d
  WHERE a.source_type_code = b.list_source_type
   and b.list_header_id = p_list_header_id
   and d.list_source_type_id = a.list_source_type_id
   and d.USED_IN_LIST_ENTRIES = 'Y'
  union all
   SELECT d.field_column_name field_column_name1,d.field_column_name
  FROM ams_list_src_types a,
       ams_list_headers_all b,
       ams_list_src_fields d,
       ams_list_src_type_assocs e
  WHERE a.source_type_code = b.list_source_type
   and b.list_header_id = p_list_header_id
   and e.master_source_type_id = a.list_source_type_id
   and d.list_source_type_id = e.sub_source_type_id
   and d.USED_IN_LIST_ENTRIES = 'Y'
   ) master_child
  GROUP BY master_child.field_column_name
  having COUNT(master_child.field_column_name) > 1;

--bmuthukr bug 4997699
l_ds_name         varchar2(1000);
l_field_col_name  varchar2(1000);
l_source_col_name varchar2(1000);

cursor c_get_dup_mapping(p_col_name in varchar2) is
SELECT d.source_column_name, d.field_column_name , d.de_list_source_type_code  stc
  FROM ams_list_src_types a,
       ams_list_headers_all b,
       ams_list_src_fields d
 WHERE a.source_type_code = b.list_source_type
   and b.list_header_id = g_list_header_id
   and d.list_source_type_id = a.list_source_type_id
   and d.field_column_name = p_col_name
   and d.USED_IN_LIST_ENTRIES = 'Y'
union all
SELECT d.source_column_name, d.field_column_name,  d.de_list_source_type_code stc
  FROM ams_list_src_types a,
       ams_list_headers_all b,
       ams_list_src_fields d,
       ams_list_src_type_assocs e
 WHERE a.source_type_code = b.list_source_type
   and b.list_header_id = g_list_header_id
   and e.master_source_type_id = a.list_source_type_id
   and d.list_source_type_id = e.sub_source_type_id
   and d.field_column_name = p_col_name
   and d.USED_IN_LIST_ENTRIES = 'Y';

l_field_column_name VARCHAR2(30);
l_count             NUMBER;
-- SOLIN, end

/* added for remote bug ... savio ******/
/*************************************************/
CURSOR C10(P_LIST_HEADER_ID NUMBER) IS
  SELECT
    LIST_HEADER_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LIST_USED_BY_ID,
    ARC_LIST_USED_BY,
    LIST_TYPE,
    STATUS_CODE,
    STATUS_DATE,
    GENERATION_TYPE,
    OWNER_USER_ID,
    ROW_SELECTION_TYPE,
    NO_OF_ROWS_MAX_REQUESTED
  FROM AMS_LIST_HEADERS_ALL
 WHERE LIST_HEADER_ID = P_LIST_HEADER_ID;

CURSOR C11(P_LIST_HEADER_ID NUMBER,
           P_ACTION         VARCHAR2) IS
  SELECT
    LIST_SELECT_ACTION_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ORDER_NUMBER,
    LIST_ACTION_TYPE,
    INCL_OBJECT_NAME,
    ARC_INCL_OBJECT_FROM,
    RANK,
    NO_OF_ROWS_AVAILABLE,
    NO_OF_ROWS_REQUESTED,
    NO_OF_ROWS_USED,
    DISTRIBUTION_PCT,
    ARC_ACTION_USED_BY,
    ACTION_USED_BY_ID,
    INCL_CONTROL_GROUP,
    NO_OF_ROWS_TARGETED,
    NO_OF_ROWS_DUPLICATES,
    RUNNING_TOTAL,
    DELTA
 FROM  AMS_LIST_SELECT_ACTIONS
 WHERE ACTION_USED_BY_ID = P_LIST_HEADER_ID
   AND ARC_ACTION_USED_BY = P_ACTION;

c11_rec  c11%rowtype;
c10_rec  c10%rowtype;
l_main_random_nth_row_select number;


l_remote_list_gen varchar2(1) := 'N';

/* added for remote bug ... savio ******/

  l_is_manual   varchar2(1) := 'N'; --Added by bmuthukr for bug 3710720


BEGIN
  l_error_position := '<- start List generate ->';
  -----------------------------------------------------------------------------
  -- g_list_header_id global variable for this session
  -- This eliminates the need for passing variables across procedures
  -- Particularly for logging debug messages ams_act_logs
  -----------------------------------------------------------------------------

  l_request_id := nvl(FND_GLOBAL.conc_request_id, -1);

  g_remote_list           := 'N';
  g_remote_list_gen       := 'N';
  g_database_link         := ' ';
  g_list_header_id        :=  p_list_header_id;
  g_count                 := 1;
  g_message_table  := g_message_table_null ;

  find_log_level(p_list_header_id);

  write_to_act_log(p_msg_data => 'Executing procedure generate_list. List generation started.',p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level => 'HIGH');
  --write_to_act_log(p_msg_data => 'Concurrent request id is '||l_request_id,p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level => 'HIGH');
  write_to_act_log(p_msg_data => 'Work flow item key(list header id) is '||p_list_header_id||' Process type is AMS List Generation',p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level => 'HIGH');

  --Added by bmuthukr for bug 3710720
  is_manual(p_list_header_id  => p_list_header_id,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            x_is_manual       => l_is_manual);
  if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
     write_to_act_log('Error in executing is_manual procedure', 'LIST', g_list_header_id,'HIGH');
     write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
     logger;
     return;
  end if;

  if nvl(l_is_manual,'N') = 'Y' then
     write_to_act_log('	Either list is a manual list, or incl are based on EMP list. Cannot generate','LIST',p_list_header_id,'HIGH');
     logger;
     return;
  end if;
  --Ends changes.

  -- SOLIN, bug 4410333
  l_ds_enabled_flag := 'N';
  OPEN c_check_datasource(p_list_header_id);
  FETCH c_check_datasource INTO l_ds_enabled_flag;
  CLOSE c_check_datasource;

  IF l_ds_enabled_flag = 'N' THEN
     write_to_act_log(
          p_msg_data => 'Aborting the List generation process. The datasource for this list is not enabled. Contact your administrator to enable the datasource, and generate the list again.',
          p_arc_log_used_by => 'LIST',
          p_log_used_by_id  => p_list_header_id,
	  p_level => 'HIGH');
     UPDATE ams_list_headers_all
        SET last_generation_success_flag = 'N',
            status_code                  = 'FAILED',
            user_status_id               = 311,
            status_date                  = sysdate,
            last_update_date             = sysdate,
            main_gen_end_time            = sysdate
      WHERE list_header_id               = g_list_header_id;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
      x_return_status := FND_API.g_ret_sts_error;
      --
      logger;
      RETURN;
  END IF;
-- SOLIN, end


  open  c_master_ds_fields_mapped;
  fetch c_master_ds_fields_mapped into l_list_field_mapped;
  close c_master_ds_fields_mapped;

  open  c_child_ds_fields_mapped;
  fetch c_child_ds_fields_mapped into l_list_field_mapped;
  close c_child_ds_fields_mapped;

  if l_list_field_mapped is NULL THEN
     write_to_act_log(p_msg_data => 'Master/Child datasource fields are not mapped. Aborting list generation. ' ,
                      p_arc_log_used_by => 'LIST',
                      p_log_used_by_id  => p_list_header_id,
  	  	      p_level =>'HIGH');

      UPDATE ams_list_headers_all
      SET    last_generation_success_flag = 'N',
             status_code                  = 'FAILED',
             user_status_id               = 311,
             status_date                  = sysdate,
             last_update_date             = sysdate,
             main_gen_end_time            = sysdate
      WHERE  list_header_id               = p_list_header_id;
   -- calling logging program
      logger;
   --
     IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
     END IF;
     --Modified by bmuthukr. Bug # 4083665
     x_return_status := FND_API.g_ret_sts_error;
     --
     RETURN;
  end if;

  -- SOLIN, bug 3484653
  OPEN c_get_dup_fields(p_list_header_id);
  FETCH c_get_dup_fields INTO l_field_column_name, l_count;
  CLOSE c_get_dup_fields;

  IF l_count>1 THEN
     /*delete from ams_act_logs
      where arc_act_log_used_by = 'LIST'
        and act_log_used_by_id  = p_list_header_id ;*/


     write_to_act_log(
          p_msg_data => 'Aborting the List generation process. Atleast one list entry column is mapped morethan once in the datasources.Pls see the following details for more info.',
          p_arc_log_used_by => 'LIST',
          p_log_used_by_id  => p_list_header_id,
	  p_level => 'HIGH');
     --bmuthukr bug 4997699
     open c_get_dup_mapping(l_field_column_name);
     loop
        fetch c_get_dup_mapping into l_source_col_name, l_field_col_name  ,l_ds_name;
	exit when c_get_dup_mapping%notfound;
        write_to_Act_log('Data Source Name :- '||l_ds_name||'          '||' Source Column :- '||l_source_col_name||'          '||' List Entries Col :- '||l_field_col_name,'LIST',p_list_header_id,'HIGH');
     end loop;
     --
     UPDATE ams_list_headers_all
        SET last_generation_success_flag = 'N',
            status_code                  = 'FAILED',
            user_status_id               = 311,
            status_date                  = sysdate,
            last_update_date             = sysdate,
            main_gen_end_time            = sysdate
      WHERE list_header_id               = g_list_header_id;
      --Modified by bmuthukr. Bug # 4083665
      x_return_status := FND_API.g_ret_sts_error;
      --
      logger;
      RETURN;
  END IF;
-- SOLIN, end

  write_to_act_log(p_msg_data => 'List header id is '||g_list_header_id,
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => p_list_header_id,
		   p_level => 'LOW');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Checking if Debug is set. If debug is set then log debugging message
  IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration : Start');
     FND_MSG_PUB.Add;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  open c_remote_list;
  fetch c_remote_list into g_remote_list,g_database_link;
  close c_remote_list;

  if nvl(g_remote_list,'N') = 'N' then
     write_to_act_log(p_msg_data => 'List is based not on remote datasource.',
                      p_arc_log_used_by => 'LIST',
                      p_log_used_by_id  => p_list_header_id,
   	   	      p_level => 'LOW');
  elsif nvl(g_remote_list,'Y') = 'Y' then
     write_to_act_log(p_msg_data => 'List is based on remote datasource. Database link is  ' ||g_database_link,
                      p_arc_log_used_by => 'LIST',
                      p_log_used_by_id  => p_list_header_id,
   	   	      p_level => 'HIGH');
  end if;

  if g_remote_list = 'Y' then

     remote_list_gen(p_list_header_id  => p_list_header_id,
                     x_return_status   => x_return_status,
                     x_msg_count       => x_msg_count,
                     x_msg_data        => x_msg_data,
                     x_remote_gen      => g_remote_list_gen);
     if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
        write_to_act_log('Error in executing remote_list_gen procedure', 'LIST', g_list_header_id,'HIGH');
        write_to_act_log('Error '||x_msg_data, 'LIST', g_list_header_id,'HIGH');
     else
        write_to_act_log(p_msg_data => 'remote_list_gen procedure executed successfully.' ,
                         p_arc_log_used_by => 'LIST',
                         p_log_used_by_id  => p_list_header_id,
 			 p_level => 'LOW');
     end if;

  end if;

  l_error_position := '<- Init List->';
  -----------------------------------------------------------------------------
  -- Gets list header record details
  -- Intialize the record, set the list header id and retrieve the records
  -----------------------------------------------------------------------------
  write_to_act_log(p_msg_data => 'Calling ams_listheader_pvt to get the list header details.' ,
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => p_list_header_id,
   	   	   p_level => 'LOW');

  ams_listheader_pvt.init_listheader_rec(l_tmp_listheader_rec);
  l_tmp_listheader_rec.list_header_id := p_list_header_id;

  l_error_position := '<- complete rec ->';
  ams_listheader_pvt.complete_listheader_rec
                   (p_listheader_rec  =>l_tmp_listheader_rec,
                    x_complete_rec    =>l_listheader_rec);
  -----------------------------------------------------------------------------

  -----------------------------------------------------------
  -- Initializes the list header record
  -----------------------------------------------------------
  l_error_position := '<- Initialize List ->';

  write_to_act_log(p_msg_data => 'Calling initialize_list to initialize the list.' ,
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => p_list_header_id,
   	   	   p_level => 'LOW');

  initialize_List(p_list_header_rec => l_listheader_rec,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  x_return_status   => x_return_status);
  if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
     write_to_act_log('Error in executing remote procedure', 'LIST', g_list_header_id,'HIGH');
     write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
  else
     write_to_act_log(p_msg_data => 'List initialized.' ,
                      p_arc_log_used_by => 'LIST',
                      p_log_used_by_id  => p_list_header_id,
   	       	      p_level => 'LOW');
  end if;

  IF x_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;

  if l_listheader_rec.generation_type = 'UPD' then
     open c_check_gen_mode;
     fetch c_check_gen_mode into l_no_of_rows;
     close c_check_gen_mode;

     if l_no_of_rows = 0 then
        write_to_act_log('No entries in list entries table. Unable to generate list in update mode. Pls generate in full refresh/append mode.','LIST',g_list_header_id,'HIGH');
        UPDATE ams_list_headers_all
           SET last_generation_success_flag = 'N',
               status_code                  = 'FAILED',
               ctrl_status_code             = 'DRAFT',
               user_status_id               = 311,
               status_date                  = sysdate,
               last_update_date             = sysdate,
               main_gen_end_time            = sysdate,
               no_of_rows_in_ctrl_group     = null
         WHERE list_header_id               = g_list_header_id;
         x_return_status := FND_API.g_ret_sts_error;
         logger;
         RETURN;
      end if;
   end if;

--From R12, only enabled entries will be updated in the update mode.
--So no need to enable all the entries before generation.
  -- if l_listheader_rec.generation_type = 'UPDATE' then
/*  if l_listheader_rec.generation_type = 'UPD' then
     write_to_act_log(' List is generated in UPDATE mode', 'LIST', g_list_header_id,'HIGH');
       update ams_list_entries
       set newly_updated_flag = 'N',
	   enabled_flag = 'Y'
       where list_header_id = l_listheader_rec.list_header_id;
*/
   /********************************************************************
    Dynamic procedure will update the list from the remote instance in
    case of remote list
   *********************************************************************/
 /*    write_to_act_log(p_msg_data => 'Updating the list in remote instance. ',
                      p_arc_log_used_by => 'LIST',
                      p_log_used_by_id  => p_list_header_id,
		      p_level => 'LOW');
     if g_remote_list = 'Y' then
       execute immediate
      'BEGIN
      AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
      ' END;'
      using  '1',
             l_null,
             'T',
             l_null,
             OUT x_return_status,
             OUT x_msg_count,
             OUT x_msg_data,
             l_listheader_rec.list_header_id,
             l_null,
             l_null,
             OUT l_total_recs,
             'UPDATE';
       if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
          write_to_act_log('Error in executing remote procedure', 'LIST', g_list_header_id,'HIGH');
          write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
       else
          write_to_act_log(p_msg_data => 'List generated in UPDATE mode in remote instance. ' ,
                           p_arc_log_used_by => 'LIST',
                           p_log_used_by_id  => p_list_header_id,
	  		   p_level => 'LOW');
       end if;
     end if;
  end if;
*/
  update_remote_list_header(g_list_header_id,x_return_status,x_msg_count,x_msg_data);
  if l_listheader_rec.generation_type = 'UPD' then
       l_error_position := '<- Get_list_entry_data inside deduplication ->';
--For bug 5216890
--   if g_remote_list <> 'Y' then
     write_to_act_log('List is generated in UPDATE mode in local instance.', 'LIST', g_list_header_id,'HIGH');
   --
   -- This will not be performed for the remote list generation
   --
     GET_LIST_ENTRY_DATA(
           p_list_header_id =>l_listheader_rec.list_header_id,
           x_return_status => x_return_status);
     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;
  -- end if;
--  END IF;
  ELSE --
  l_error_position := '<- Process List Actions  ->';
  write_to_act_log('List will be generated in '||l_listheader_rec.generation_type||' mode.','LIST', g_list_header_id,'HIGH');
  write_to_act_log('Calling process_list_actions to generate list.', 'LIST', g_list_header_id,'LOW');
  process_list_Actions(p_action_used_by_id => l_listheader_rec.list_header_id,
                       p_action_used_by    => 'LIST',
                       p_log_flag          => l_listheader_rec.enable_log_flag,
                       x_return_status     => x_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data);
  if x_return_status = 'E' then
     logger;
     commit;
     return;
  end if;
  END IF;

  if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
     write_to_act_log('Error in generating list.', 'LIST', g_list_header_id,'HIGH');
     write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
  end if;

  IF x_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;


/******************************************************************************/
/**************** call for cancel list generation added 05/23/2005 ************/
/******************************************************************************/
-- Inside generate_list 1

   AMS_LISTGENERATION_UTIL_PKG.cancel_list_gen(
               p_list_header_id => g_list_header_id ,
               p_remote_gen     => g_remote_list    ,
               p_remote_gen_list=> g_remote_list_gen,
               p_database_link  => g_database_link,
               x_msg_count      => x_msg_count ,
               x_msg_data       => x_msg_data ,
               x_return_status  => x_return_status
         );

  IF(x_return_status <> FND_API.G_RET_STS_SUCCESS )THEN
     if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
        write_to_act_log('Error in Cancel List generation', 'LIST', g_list_header_id,'HIGH');
        write_to_act_log('Error while executing Cancel List generation '||sqlerrm||sqlcode, 'LIST', g_list_header_id,'HIGH');
     end if;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     write_to_act_log('Success in Cancel List generation', 'LIST', g_list_header_id,'LOW');
  END IF;

/******************************************************************************/
/**************** call for cancel list generation added 05/23/2005 ************/
/******************************************************************************/
/*
  -- if l_listheader_rec.generation_type = 'UPDATE' then
  if l_listheader_rec.generation_type = 'UPD' then
     l_error_position := '<- set enabled flag for gen type UPDATE ';
    if g_remote_list <> 'Y' then
       update ams_list_entries
       set enabled_flag  = 'N'
       where newly_updated_flag = 'N'
         and list_header_id = l_listheader_rec.list_header_id;
      write_to_act_log(sql%rowcount||' entries disabled when generating list in update mode','LIST',g_list_header_id,'HIGH');
     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;
-- -----------------------
   else --  if g_remote_list = 'Y' then
      write_to_act_log('Updating list in remote instance.', 'LIST', p_list_header_id,'HIGH');
      execute immediate
      'BEGIN
       AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';
'||
      ' END;'
      using  '1',
             l_null,
             'T',
             l_null,
             OUT x_return_status,
             OUT x_msg_count,
             OUT x_msg_data,
             l_listheader_rec.list_header_id,
             l_null,
             l_null,
             OUT l_total_recs,
             'UPDATE';
        if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
          write_to_act_log('Error in updating list in remote instance', 'LIST', g_list_header_id,'HIGH');
          write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
       end if;
     end if;

-- -----------------------
  END IF;
-- --------------------------------
*/
if g_remote_list_gen = 'N' then
   if l_listheader_rec.generation_type = 'STANDARD' then --R12 applicable only for full refresh mode
      write_to_act_log('Identifying duplicate records(based on party id) in the list.','LIST',g_list_header_id,'HIGH');
      UPDATE ams_list_entries a
         SET a.enabled_flag  = 'N',
             a.marked_as_duplicate_flag = 'Y'
       WHERE a.list_header_id = p_list_header_id
         and a.enabled_flag = 'Y'
         AND a.rowid >  (SELECT min(b.rowid)
                           from ams_list_entries  b
                          where b.list_header_id = p_list_header_id
                            and b.party_id = a.party_id
                            and b.enabled_flag = 'Y'
                   );
      write_to_act_log('No of duplicates identified.'||sql%rowcount,'LIST',g_list_header_id,'HIGH');
      write_to_act_log('Duplicate records(based on party) identified and marked.','LIST',g_list_header_id,'LOW');
/*    UPDATE ams_list_entries a
         SET a.enabled_flag  = 'N',
            a.marked_as_duplicate_flag = 'Y'
       WHERE a.list_header_id = p_list_header_id
         and a.enabled_flag = 'Y'
         -- AND a.rowid >  (SELECT min(b.rowid)
         AND a.rank >  (SELECT min(b.rank)
                   from ams_list_entries  b
                   where b.list_header_id = p_list_header_id
                     and b.party_id = a.party_id
                     and b.enabled_flag = 'Y'
                   );*/
   end if;
end if;
-- --------------------------------

   open g_initial_count;
   fetch g_initial_count into g_no_of_rows_ini_selected;
   close g_initial_count;

   if l_listheader_rec.generation_type = 'STANDARD' then --lpo
      open c1;
      fetch c1 into l_list_rule_id ;
      close c1;

      IF (l_list_rule_id <> 0 ) THEN   --Deduplication of the list has been requested.--
         write_to_act_log('De Duplication requested for this list', 'LIST', g_list_header_id,'HIGH');
         l_error_position := '<- de dupe ->';
         if g_remote_list_gen = 'N' then
            /* For local list generation */
            write_to_act_log('Calling ams_listdedupe_pvt for deduplication.', 'LIST', g_list_header_id,'HIGH');
            l_no_of_duplicates := AMS_LISTDEDUPE_PVT.DEDUPE_LIST
                           (p_list_header_id               => p_list_header_id,
                            p_enable_word_replacement_flag => 'Y',
                                  -- l_listheader_rec.enable_word_replacement_flag,
                            p_send_to_log    => l_listheader_rec.enable_log_flag,
                           p_object_name    => 'AMS_LIST_ENTRIES');
            write_to_act_log('Deduplication done for this list.', 'LIST', g_list_header_id,'HIGH');
         else
            /* For Remote list generation */
            write_to_act_log('Call Execute_Remote_Dedupe_List for deduplication in remote instance.', 'LIST', g_list_header_id,'HIGH');
            Execute_Remote_Dedupe_List
                          (p_list_header_id               => p_list_header_id,
                            p_enable_word_replacement_flag => 'Y',
                                --   l_listheader_rec.enable_word_replacement_flag,
                            p_send_to_log    => 'Y', -- l_listheader_rec.enable_log_flag,
                            p_object_name    => 'AMS_LIST_ENTRIES');
            write_to_act_log('Deduplication done for this list in remote instance.', 'LIST', g_list_header_id,'LOW');
         end if;
      end if;
   end if;


   if l_listheader_rec.generation_type in ('STANDARD','INCREMENTAL') then --lpo
      if nvl(g_remote_list_gen,'N') = 'N' then
         AMS_List_Options_Pvt.apply_size_reduction(p_list_header_id => g_list_header_id ,
                                                   p_log_level => g_log_level,
                                                   p_msg_tbl   => g_msg_tbl_opt,
                                                   x_return_status  => x_return_status,
                                                   x_msg_count      => x_msg_count,
                                                   x_msg_data       => x_msg_data);
         if g_msg_tbl_opt.count > 0 then
            for i in g_msg_tbl_opt.first .. g_msg_tbl_opt.last
	    loop
	       write_to_Act_log(g_msg_tbl_opt(I),'LIST',g_list_header_id,'HIGH');
               --g_message_table(g_count) := g_msg_tbl_opt(I);
               --g_date(g_count) := sysdate;
               --g_count   := g_count + 1;
            end loop;
	    g_msg_tbl_opt.delete;
         end if;
      else
         write_to_act_log('Calling apply_size_reduction procedure in the remote instance.', 'LIST', g_list_header_id,'LOW');
         execute immediate
         'BEGIN
          AMS_LIST_OPTIONS_PVT.apply_size_reduction'||'@'||g_database_link||'(:1,:2,:3,:4,:5)'||';'||
         ' END;'
         using g_list_header_id,
         'NULL',
         out x_return_status,
         out x_msg_count,
         out x_msg_data;
         write_to_act_log('x return status '||x_return_status, 'LIST', g_list_header_id,'LOW');
         write_to_act_log('apply_size_reduction procedure executed in the remote instance.', 'LIST', g_list_header_id,'LOW');
      end if;
      IF (x_return_status <>FND_API.G_RET_STS_SUCCESS )THEN
         if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
            write_to_act_log('Error in while executing size reduction procedure.', 'LIST', g_list_header_id,'HIGH');
         end if;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         write_to_act_log('Procedure apply_size_reduction executed successfully.', 'LIST', g_list_header_id,'LOW');
         IF FND_API.To_Boolean ( p_commit ) THEN
            COMMIT;
         END IF;
      END IF;
   end if;
-- end if;

 if g_remote_list = 'Y' then
    write_to_act_log('Updating the list header info in the remote instance.', 'LIST', p_list_header_id,'HIGH');
    write_to_act_log('Deleting the existing ist header record deleted in remote instance.', 'LIST', p_list_header_id,'LOW');
    --execute immediate 'begin Delete from ams_list_headers_all'||'@'||g_database_link||' where list_header_id = :1 ; end;' using p_list_header_id;

/*********** added by savio for remote bug 3764343 **************************/

/*    open c10(p_list_header_id);
    fetch c10 into c10_rec;
    close c10;

   write_to_act_log('Passing list header details to the remote procedure, to insert it there.', 'LIST', p_list_header_id,'HIGH');
   execute immediate
      'begin
         ams_remote_listgen_pkg.remote_insert_list_headers'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18)'||';'||
      ' end;'
      using
    c10_rec.list_header_id,
    c10_rec.last_update_date,
    c10_rec.last_updated_by,
    c10_rec.creation_date,
    c10_rec.created_by,
    c10_rec.last_update_login,
    c10_rec.list_used_by_id,
    c10_rec.arc_list_used_by,
    c10_rec.list_type,
    c10_rec.status_code,
    c10_rec.status_date,
    c10_rec.generation_type,
    c10_rec.owner_user_id,
    c10_rec.row_selection_type,
    c10_rec.no_of_rows_max_requested,
    out x_msg_count,
    out x_msg_data,
    out x_return_status;

    if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
       write_to_act_log('Error updating list header information in remote instance.', 'LIST', g_list_header_id,'HIGH');
       write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
    else
       write_to_act_log('List header information updated.', 'LIST', g_list_header_id,'LOW');
    end if;*/

/**********  added by savio for remote bug 3764343 *************************/

/**********  added by savio for remote bug 3764343 ******************************************/
    open c11(p_list_header_id, l_action);
    fetch c11 into c11_rec;
    close c11;
    write_to_act_log('Updating the list selections in the remote instance.', 'LIST', p_list_header_id,'HIGH');
    write_to_act_log('Passing the selecions values to remote_insert_list_sel_actions proceudure, to insert it there.', 'LIST', p_list_header_id,'LOW');

    execute immediate
      'begin
         ams_remote_listgen_pkg.remote_insert_list_sel_actions'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24,:25)'||';'||
      ' end;'
      using
    c11_rec.list_select_action_id,
    c11_rec.last_update_date,
    c11_rec.last_updated_by,
    c11_rec.creation_date,
    c11_rec.created_by,
    c11_rec.last_update_login,
    c11_rec.order_number,
    c11_rec.list_action_type,
    c11_rec.incl_object_name,
    c11_rec.arc_incl_object_from,
    c11_rec.rank,
    c11_rec.no_of_rows_available,
    c11_rec.no_of_rows_requested,
    c11_rec.no_of_rows_used,
    c11_rec.distribution_pct,
    c11_rec.arc_action_used_by,
    c11_rec.action_used_by_id,
    c11_rec.incl_control_group,
    c11_rec.no_of_rows_targeted,
    c11_rec.no_of_rows_duplicates,
    c11_rec.running_total,
    c11_rec.delta,
    out x_msg_count,
    out x_msg_data,
    out x_return_status;

    if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
       write_to_act_log('Error updating list selections in remote instance.', 'LIST', g_list_header_id,'HIGH');
       write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
    else
       write_to_act_log('List selections updated in remote instance.', 'LIST', g_list_header_id,'LOW');
    end if;

/**********  added by savio for remote bug 3764343 ******************************************/
    execute immediate 'begin Update ams_list_select_actions a1  set no_of_rows_requested =
            (select  no_of_rows_requested from ams_list_select_actions'||'@'||g_database_link||
	    ' b1 where b1.list_select_action_id = a1.list_select_action_id)
	    where action_used_by_id = :1 and arc_action_used_by = :2; end; ' using p_list_header_id, l_action;
    write_to_act_log('No_of_rows_requested in list header table updated with values from remote instance.', 'LIST', p_list_header_id,'LOW');

  end if;

  l_error_position := '<- update list dets ->';

  write_to_act_log('Calling update_list_dets to update list header and selections info.'||x_msg_data , 'LIST', g_list_header_id,'HIGH');
  Update_List_Dets(p_list_header_id,x_return_status);

  if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
     write_to_act_log('Error in updating list header/selections info', 'LIST', g_list_header_id,'HIGH');
     write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
  elsif nvl(x_return_status,'S') = 'S' then
     write_to_act_log('List header and selections info updated.'||x_msg_data , 'LIST', g_list_header_id,'LOW');
  end if;

  IF(x_return_status <>FND_API.G_RET_STS_SUCCESS )THEN
     write_to_act_log('Error after calling update_list_dets procedure', 'LIST', p_list_header_id,'HIGH');
     RAISE FND_API.G_EXC_ERROR;
  ELSE
   IF FND_API.To_Boolean ( p_commit ) THEN
     write_to_act_log('Generate_list : Commit', 'LIST', g_list_header_id,'LOW');
     COMMIT;
   END IF;
  END IF;
  write_to_act_log('Procedure generate_list executed. List generated successfully.','LIST',g_list_header_id,'HIGH');
  -- calling logging program
  logger;
  --
  -- END of API body.
  --
/******************************************************************************/
/**************** call for cancel list generation added 05/26/2005 ************/
/******************************************************************************/
--inside generate_list 2

   AMS_LISTGENERATION_UTIL_PKG.cancel_list_gen(
                p_list_header_id => g_list_header_id ,
                p_remote_gen     => g_remote_list    ,
                p_remote_gen_list=> g_remote_list_gen,
                p_database_link  => g_database_link,
                x_msg_count      => x_msg_count ,
                x_msg_data       => x_msg_data ,
                x_return_status  => x_return_status
               );

  logger;
  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Success Message
  -- MMSG
  --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  --THEN
  FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
  FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration_PKG.Generate_List');
  FND_MSG_PUB.Add;
  --END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --IF (AMS_DEBUG_HIGH_ON) THEN
  --THEN
  FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
  FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration_PKG.Generate_List: END');
  FND_MSG_PUB.Add;
  --END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
  -- calling logging program
  write_to_act_log('Error in generating list while executing procedure generate_list '||sqlcode||'   '||sqlerrm,'LIST',g_list_header_id,'HIGH');

  --
        UPDATE ams_list_headers_all
        SET    last_generation_success_flag = 'N',
               status_code         = 'FAILED',
               user_status_id      = 311,
               status_date         = sysdate,
               last_update_date    = sysdate,
               main_gen_end_time   = sysdate
        WHERE  list_header_id      = p_list_header_id;
     logger;
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  -- calling logging program
  write_to_act_log('Error in generating list while executing procedure generate_list '||sqlcode||'   '||sqlerrm,'LIST',g_list_header_id,'HIGH');
  --
        UPDATE ams_list_headers_all
        SET    last_generation_success_flag = 'N',
               status_code         = 'FAILED',
               user_status_id      = 311,
               last_update_date    = sysdate,
               status_date         = sysdate,
               main_gen_end_time   = sysdate
        WHERE  list_header_id      = p_list_header_id;
     logger;
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
---------------Cancel List Gen Exception Begin --------------
  WHEN AMS_LISTGENERATION_UTIL_PKG.cancelListGen THEN
    write_to_act_log('In GENERATE_LIST: User cancel list gen action detected. ' ,'LIST',g_list_header_id,'HIGH');
    write_to_act_log('List Generation Stopped successfully.','LIST',g_list_header_id,'HIGH');

  UPDATE ams_list_headers_all
     SET    last_generation_success_flag = 'N',
               status_code         = 'DRAFT',
               user_status_id      = 300,
               last_update_date    = sysdate,
               status_date         = sysdate,
               main_gen_end_time   = sysdate
     WHERE  list_header_id         = p_list_header_id;
  logger;

  FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
  FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration_PKG.Generate_List');
  FND_MSG_PUB.Add;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
  FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration_PKG.Generate_List: END');
  FND_MSG_PUB.Add;

  FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
---------------Cancel List Gen Exception End --------------

  WHEN OTHERS THEN
  -- calling logging program
  write_to_act_log('Error in generating list while executing procedure generate_list '||sqlcode||'   '||sqlerrm,'LIST',g_list_header_id,'HIGH');
  --
        UPDATE ams_list_headers_all
        SET    last_generation_success_flag = 'N',
               status_code                  = 'FAILED',
               user_status_id               = 311,
               last_update_date             = sysdate,
               status_date                  = sysdate,
               main_gen_end_time            = sysdate
        WHERE  list_header_id               = p_list_header_id;
      logger;
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END GENERATE_LIST;

PROCEDURE create_list
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_name              in    varchar2,
  p_list_type              in    varchar2,
  p_owner_user_id          in    number,
  p_sql_string             in  OUT NOCOPY varchar2,
  p_primary_key            in    varchar2,
  p_source_object_name     in    varchar2,
  p_master_type            in    varchar2,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2,
  x_list_header_id         OUT NOCOPY   NUMBER  ) is
l_list_header_rec   AMS_ListHeader_PVT.list_header_rec_type;
l_init_msg_list     varchar2(2000) := FND_API.G_FALSE;
l_api_version       number         := 1.0;
l_api_name          constant varchar2(30) := 'Create_List';
l_list_query_rec    AMS_List_Query_PVT.list_query_rec_type ;
l_list_query_id     number ;
l_action_rec        AMS_ListAction_PVT.action_rec_type ;
l_action_id         number;
cursor c_mapping_types(p_master_type varchar2) is
SELECT list_source_type_id
FROM   ams_list_src_types a
WHERE a.source_type_code = p_master_type
  AND a.master_source_type_flag = 'Y';
cursor c_mapping_subtypes(p_master_type_id
                          ams_list_src_type_assocs.master_source_type_id%type)is
select ','||''''||source_type_code||''''
from   ams_list_src_types a,
       ams_list_src_type_assocs b
where  b.master_source_type_id = p_master_type_id
  and  b.sub_source_type_id  = a.list_source_type_id;

l_master_type_id number;
l_source_type_code varchar2(30);
l_select_string varchar2(2000) := 'SELECT ' ||''''|| p_master_type || '''';
BEGIN
  open c_mapping_types(p_master_type )  ;
  fetch c_mapping_types into l_master_type_id;
  close c_mapping_types;
/*
  open c_mapping_subtypes(l_master_type_id )  ;
  loop
  fetch c_mapping_subtypes
  into l_source_type_code;
  exit when c_mapping_subtypes%notfound;
  l_select_string := l_select_string || l_source_type_code;
  end loop;
  close c_mapping_subtypes;
*/

  p_sql_string := l_select_string ||','|| substrb(p_sql_string,instr(upper(p_sql_string),'SELECT',1)+6);
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration_PKG.cerate_list: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Perform the database operation

  -- ams_listheader_pvt.init_listheader_rec(l_list_header_rec);
  l_list_header_rec.list_name :=  p_list_name;
  l_list_header_rec.list_type :=  p_list_type;
  l_list_header_rec.owner_user_id :=  p_owner_user_id;
l_list_header_rec.list_source_type := p_master_type            ;
if l_list_header_rec.view_application_id is null then
l_list_header_rec.view_application_id := 530;
end if;
  AMS_ListHeader_PVT.Create_Listheader
  ( p_api_version           => 1.0,
  p_init_msg_list           => l_init_msg_list,
  p_commit                  => p_commit,
  p_validation_level        => p_validation_level ,
  x_return_status           => x_return_status,
  x_msg_count               => x_msg_count,
  x_msg_data                => x_msg_data,
  p_listheader_rec          => l_list_header_rec,
  x_listheader_id           => x_list_header_id
  );

  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;

     FND_MESSAGE.set_name('AMS', 'bfore list query');
     FND_MSG_PUB.Add;
   l_list_query_rec.name        :=  p_list_name || x_list_header_id;
   l_list_query_rec.sql_string  :=  p_sql_string ;
   l_list_query_rec.primary_key  :=  p_primary_key ;
   l_list_query_rec.type  :=  p_master_type ;
   l_list_query_rec.source_object_name  :=  p_source_object_name ;
   AMS_List_Query_PVT.Create_List_Query(
       p_api_version_number  => 1.0,
       p_init_msg_list       => l_init_msg_list,
       p_commit              => p_commit,
       p_validation_level    => p_validation_level,
       x_return_status       => x_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data,
       p_list_query_rec      => l_list_query_rec ,
       x_list_query_id       => l_list_query_id
     );
  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;

  l_action_rec.arc_action_used_by := 'LIST';
  l_action_rec.action_used_by_id := x_list_header_id ;
  l_action_rec.order_number := 1 ;
  l_action_rec.list_action_type := 'INCLUDE';
  l_action_rec.arc_incl_object_from := 'SQL';
  l_action_rec.incl_object_id := l_list_query_id;
  l_action_rec.rank := 1;
  AMS_ListAction_PVT.Create_ListAction
  ( p_api_version           => 1.0,
    p_init_msg_list         => l_init_msg_list,
    p_commit                => p_commit,
    p_validation_level      => p_validation_level,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data,
    p_action_rec            => l_action_rec,
    x_action_id             => l_action_id
    ) ;
  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;
  --For bug 4351391
    ams_list_wf.StartListBizEventProcess(p_list_header_id  => x_list_header_id);

  /*
  GENERATE_LIST
  ( p_api_version           => 1.0,
    p_init_msg_list         => l_init_msg_list,
    p_commit                => p_commit,
    p_validation_level      => p_validation_level,
    p_list_header_id        => x_list_header_id,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data);

  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;
  -- END of API body.

  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;
  -- END of API body.
  --
  */
  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Success Message
  -- MMSG
  --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  --THEN
  FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
  FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration_PKG.create_list: ');
  FND_MSG_PUB.Add;
  --END IF;

  --IF (AMS_DEBUG_HIGH_ON) THEN
  --THEN
  FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
  FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration_PKG.create_list: END');
  FND_MSG_PUB.Add;
  --END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END CREATE_LIST;

PROCEDURE create_import_list
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_owner_user_id          in    number,
  p_imp_list_header_id     in    number,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2,
  x_list_header_id         OUT NOCOPY   NUMBER  ,
  p_list_name              in    VARCHAR2 ) is
l_list_header_rec   AMS_ListHeader_PVT.list_header_rec_type;
l_init_msg_list     varchar2(2000) := FND_API.G_FALSE;
l_api_version       number         := 1.0;
l_api_name          constant varchar2(30) := 'Create_import_List';
l_action_rec        AMS_ListAction_PVT.action_rec_type ;
l_action_id         number;
l_import_list_name  varchar2(200);
cursor c_chk_name is
select  'x'
from ams_list_headers_vl
where list_name = p_list_name ;
cursor c_get_source_type
is select  decode(import_type,'B2C','PERSON_LIST','ORGANIZATION_CONTACT_LIST'),
      name
from ams_imp_list_headers_vl
where  import_list_header_id = p_imp_list_header_id     ;
l_source_type varchar2(100);
l_var  varchar2(1);
BEGIN
 open c_get_source_type ;
 fetch c_get_source_type into l_source_type ,l_import_list_name   ;
 close c_get_source_type ;
 if l_source_type is null then
   l_source_type := 'PERSON_LIST';
 end if;
  if p_list_name is not null then
     open c_chk_name ;
     fetch c_chk_name into l_var   ;
     close c_chk_name ;
  else
     l_var := 'x';
  end if;
  if  l_var is not null  then
      select l_import_list_name|| ' -:'|| to_char(sysdate,'DD-MON-YY HH:MM:SS')
      into l_import_list_name
      from ams_imp_list_headers_vl
      where import_list_header_id = p_imp_list_header_id     ;
 else
    l_import_list_name := p_list_name ;
 end if;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration_PKG.cerate_list: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Perform the database operation

  -- ams_listheader_pvt.init_listheader_rec(l_list_header_rec);
  l_list_header_rec.list_name :=  l_import_list_name  ;
  l_list_header_rec.list_type :=  'STANDARD';
  l_list_header_rec.list_source_type :=  l_source_type;
  l_list_header_rec.owner_user_id :=  p_owner_user_id;
  l_list_header_rec.view_application_id :=  530;
--  l_list_header_rec.purpose_code :=  'GENERAL';

  AMS_ListHeader_PVT.Create_Listheader
  ( p_api_version           => 1.0,
  p_init_msg_list           => l_init_msg_list,
  p_commit                  => p_commit,
  p_validation_level        => p_validation_level ,
  x_return_status           => x_return_status,
  x_msg_count               => x_msg_count,
  x_msg_data                => x_msg_data,
  p_listheader_rec          => l_list_header_rec,
  x_listheader_id           => x_list_header_id
  );

  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;

  l_action_rec.arc_action_used_by := 'LIST';
  l_action_rec.action_used_by_id := x_list_header_id ;
  l_action_rec.order_number := 1 ;
  l_action_rec.list_action_type := 'INCLUDE';
  l_action_rec.arc_incl_object_from := 'IMPH';
  l_action_rec.incl_object_id := p_imp_list_header_id     ;
  l_action_rec.rank := 1;
  AMS_ListAction_PVT.Create_ListAction
  ( p_api_version           => 1.0,
    p_init_msg_list         => l_init_msg_list,
    p_commit                => p_commit,
    p_validation_level      => p_validation_level,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data,
    p_action_rec            => l_action_rec,
    x_action_id             => l_action_id
    ) ;
     FND_MESSAGE.set_name('AMS','after list action->'|| l_action_id|| '<-');
     FND_MSG_PUB.Add;
  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;

  GENERATE_LIST
  ( p_api_version           => 1.0,
    p_init_msg_list         => l_init_msg_list,
    p_commit                => p_commit,
    p_validation_level      => p_validation_level,
    p_list_header_id        => x_list_header_id,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data);

  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;
  -- END of API body.
  --

  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Success Message
  -- MMSG
  --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  --THEN
  FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
  FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration_PKG.create_list: ');
  FND_MSG_PUB.Add;
  --END IF;


  --IF (AMS_DEBUG_HIGH_ON) THEN
  --THEN
  FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
  FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration_PKG.create_list: END');
  FND_MSG_PUB.Add;
  --END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END CREATE_import_LIST;

PROCEDURE create_list_from_query
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_name              in    varchar2,
  p_list_type              in    varchar2,
  p_owner_user_id          in    number,
  p_list_header_id         in    number,
  p_sql_string_tbl         in    AMS_List_Query_PVT.sql_string_tbl      ,
  p_primary_key            in    varchar2,
  p_source_object_name     in    varchar2,
  p_master_type            in    varchar2,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2
  ) is
l_list_header_rec   AMS_ListHeader_PVT.list_header_rec_type;
l_init_msg_list     varchar2(2000) := FND_API.G_FALSE;
l_api_version       number         := 1.0;
l_api_name          constant varchar2(30) := 'Create_List';
l_list_query_rec_tbl    AMS_List_Query_PVT.list_query_rec_type_tbl ;
l_list_query_id     number ;
l_action_rec        AMS_ListAction_PVT.action_rec_type ;
l_action_id         number;

l_master_type_id number;
l_source_type_code varchar2(30);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration_PKG.cerate_list: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Perform the database operation

   l_list_query_rec_tbl.name        :=  p_list_name ||'_'|| p_list_header_id;
  -- l_list_query_rec_tbl.sql_string  :=  p_sql_string ;
   l_list_query_rec_tbl.primary_key  :=  p_primary_key ;
   l_list_query_rec_tbl.type  :=  p_master_type ;
   l_list_query_rec_tbl.source_object_name  :=  p_source_object_name ;
   AMS_List_Query_PVT.Create_List_Query(
       p_api_version_number  => 1.0,
       p_init_msg_list       => l_init_msg_list,
       p_commit              => p_commit,
       p_validation_level    => p_validation_level,
       x_return_status       => x_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data,
       p_list_query_rec_tbl    => l_list_query_rec_tbl ,
       p_sql_string_tbl       => p_sql_string_tbl         ,
       x_parent_list_query_id   => l_list_query_id
     );


  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;

  l_action_rec.arc_action_used_by := 'LIST';
  l_action_rec.action_used_by_id := p_list_header_id ;
  l_action_rec.order_number := 1 ;
  l_action_rec.list_action_type := 'INCLUDE';
  l_action_rec.arc_incl_object_from := 'SQL';
  l_action_rec.incl_object_id := l_list_query_id;
  l_action_rec.rank := 1;
  l_action_rec.order_number := 1 ;
  AMS_ListAction_PVT.Create_ListAction
  ( p_api_version           => 1.0,
    p_init_msg_list         => l_init_msg_list,
    p_commit                => p_commit,
    p_validation_level      => p_validation_level,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data,
    p_action_rec            => l_action_rec,
    x_action_id             => l_action_id
    ) ;
  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;

  GENERATE_LIST
  ( p_api_version           => 1.0,
    p_init_msg_list         => l_init_msg_list,
    p_commit                => p_commit,
    p_validation_level      => p_validation_level,
    p_list_header_id        => p_list_header_id,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data);

  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;
  -- END of API body.
  --

  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Success Message
  -- MMSG
  --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  --THEN
  FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
  FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration_PKG.create_list: ');
  FND_MSG_PUB.Add;
  --END IF;


  --IF (AMS_DEBUG_HIGH_ON) THEN
  --THEN
  FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
  FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration_PKG.create_list: END');
  FND_MSG_PUB.Add;
  --END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END CREATE_LIST_FROM_QUERY ;

PROCEDURE create_list_from_query
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_name              in    varchar2,
  p_list_type              in    varchar2,
  p_owner_user_id          in    number,
  p_list_header_id         in    number,
  p_sql_string_tbl         in    AMS_List_Query_PVT.sql_string_tbl      ,
  p_primary_key            in    varchar2,
  p_source_object_name     in    varchar2,
  p_master_type            in    varchar2,
  p_query_param            in    AMS_List_Query_PVT.sql_string_tbl      ,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2
  ) is
l_list_header_rec   AMS_ListHeader_PVT.list_header_rec_type;
l_init_msg_list     varchar2(2000) := FND_API.G_FALSE;
l_api_version       number         := 1.0;
l_api_name          constant varchar2(30) := 'Create_List';
l_list_query_rec_tbl    AMS_List_Query_PVT.list_query_rec_type_tbl ;
l_list_query_id     number ;
l_action_rec        AMS_ListAction_PVT.action_rec_type ;
l_action_id         number;

l_master_type_id number;
l_source_type_code varchar2(30);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration_PKG.cerate_list: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Perform the database operation

   l_list_query_rec_tbl.name        :=  p_list_name ||'_'|| p_list_header_id;
  -- l_list_query_rec_tbl.sql_string  :=  p_sql_string ;
   l_list_query_rec_tbl.primary_key  :=  p_primary_key ;
   l_list_query_rec_tbl.type  :=  p_master_type ;
   l_list_query_rec_tbl.source_object_name  :=  p_source_object_name ;

   AMS_List_Query_PVT.Create_List_Query(
       p_api_version_number  => 1.0,
       p_init_msg_list       => l_init_msg_list,
       p_commit              => p_commit,
       p_validation_level    => p_validation_level,
       x_return_status       => x_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data,
       p_list_query_rec_tbl    => l_list_query_rec_tbl ,
       p_sql_string_tbl       => p_sql_string_tbl         ,
       p_query_param          => p_query_param          ,
       x_parent_list_query_id   => l_list_query_id
     );


  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;

  l_action_rec.arc_action_used_by := 'LIST';
  l_action_rec.action_used_by_id := p_list_header_id ;
  l_action_rec.order_number := 1 ;
  l_action_rec.list_action_type := 'INCLUDE';
  l_action_rec.arc_incl_object_from := 'SQL';
  l_action_rec.incl_object_id := l_list_query_id;
  l_action_rec.rank := 1;
  l_action_rec.order_number := 1 ;
  AMS_ListAction_PVT.Create_ListAction
  ( p_api_version           => 1.0,
    p_init_msg_list         => l_init_msg_list,
    p_commit                => p_commit,
    p_validation_level      => p_validation_level,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data,
    p_action_rec            => l_action_rec,
    x_action_id             => l_action_id
    ) ;
  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;

  GENERATE_LIST
  ( p_api_version           => 1.0,
    p_init_msg_list         => l_init_msg_list,
    p_commit                => p_commit,
    p_validation_level      => p_validation_level,
    p_list_header_id        => p_list_header_id,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data);

  if x_return_status <> FND_API.g_ret_sts_success  THEN
     RAISE FND_API.G_EXC_ERROR;
  end if;
  -- END of API body.
  --

  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Success Message
  -- MMSG
  --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  --THEN
  FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
  FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration_PKG.create_list: ');
  FND_MSG_PUB.Add;
  --END IF;


  --IF (AMS_DEBUG_HIGH_ON) THEN
  --THEN
  FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
  FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration_PKG.create_list: END');
  FND_MSG_PUB.Add;
  --END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END CREATE_LIST_FROM_QUERY ;
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.

PROCEDURE process_tar_actions
             (p_action_used_by_id  in  number,
              p_action_used_by     in  varchar2  ,-- DEFAULT 'LIST',
              p_log_flag           in  varchar2  ,-- DEFAULT 'Y',
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2) IS

  -- AMS_LIST_SELECT_ACTIONS Record for init record and complete record
  l_tmp_action_rec             ams_listaction_pvt.action_rec_type;
  p_action_rec                 ams_listaction_pvt.action_rec_type;
  l_list_select_action_id      number;

  ----------------------------------------------------------------------------
  -- Cursor definition to select list_select_action_id.Will be used in loop to
  -- Process each cursor record according to order specified by the user
  ----------------------------------------------------------------------------
  CURSOR c_action_dets is
  SELECT a.list_act_type, a.list_used_by,
         a.list_action_type, a.order_number,
         a.list_header_id  ,
         -- a.act_list_header_id,
	 c.list_select_action_id act_list_header_id,
         c.distribution_pct distribution_pct,
	 c.arc_incl_object_from arc_incl_object_from
    FROM ams_act_lists a ,ams_act_lists b, ams_list_select_actions c
   WHERE a.list_used_by_id   = b.list_used_by_id
     AND a.list_used_by =   b.list_used_by
     AND b.list_header_id =  p_action_used_by_id
     AND b.list_act_type  =   'TARGET'
     and a.list_act_type <> 'TARGET'
	 and b.list_header_id = c.action_used_by_id
	 and a.order_number = c.order_number
   ORDER by c.order_number;

l_action_dets_rec  c_action_dets%ROWTYPE;

  TYPE big_tbl_type is table of VARCHAR2(32767) index by BINARY_INTEGER;
  l_std_sql VARCHAR2(32767);
  l_include_sql VARCHAR2(32767);
  l_include_count number:=0;
  l_final_big_sql VARCHAR2(32767);
  l_include_sql_tbl  big_tbl_type ;
  l_std_sql_tbl  big_tbl_type ;
  l_join_string   varchar2(50);
l_no_of_chunks            number;
l_const_sql varchar2(4000) ;
  TYPE char_tbl_type is table of VARCHAR2(100) index by BINARY_INTEGER;
  TYPE num_tbl_type is table of number index by BINARY_INTEGER;
  l_rank_tbl      char_tbl_type;
  l_rank_num_tbl      num_tbl_type;
l_sorted   number;
l_update_sql  VARCHAR2(32767);
l_list_header_id number ;
cursor c1 is
select generation_type
from ams_list_headers_all
where list_header_id = l_list_header_id;
l_generation_type varchar2(60);
l_PARAMETERIZED_FLAG  varchar2(1) := 'N';
TYPE table_char  IS TABLE OF VARCHAR2(80) INDEX  BY BINARY_INTEGER;
l_table_char table_char;

cursor c_query(l_query_id number) is select
nvl(PARAMETERIZED_FLAG ,'N')
from ams_list_queries_all
where  list_query_id = l_query_id ;

cursor c_param_values(l_query_id in number) is
select PARAMETER_ORDER, PARAMETER_VALUE,parameter_name
from ams_list_queries_param
where list_query_id = l_query_id
order by PARAMETER_ORDER;

l_string VARCHAR2(32767);
l1 varchar2(2000);
l_remote_update_sql  VARCHAR2(32767);
l_null          number;
l_total_recs    number;
l_query_templ_flag   varchar2(1) ;

l_temp_sql   varchar2(32767);
l_dist_pct_tbl        num_tbl_type;
l_list_select_id      num_tbl_type;
l_incl_object_type    char_tbl_type;

cursor c_query_temp_type is
select 'Y'
from ams_list_headers_vl  a ,
     ams_query_template_all b
where a.list_header_id = g_list_header_id
 and b.template_type  = 'PARAMETERIZED'
  and a.query_template_id = b.template_id ;

l_const_sql1 varchar2(4000) ;
l_l_sele_action_id      number;

  CURSOR c_action_dets1 is
  SELECT list_select_action_id,order_number
    FROM ams_list_select_actions
   WHERE action_used_by_id   = p_action_used_by_id
     AND arc_action_used_by  = p_action_used_by
     AND order_number        = l_sorted;
l_order_number number := 0;

l_repeat_tg	varchar2(1);
CURSOR c_repeat_tg is
select 'Y' from ams_campaign_schedules_b b, ams_list_headers_all h
where h.list_header_id = g_list_header_id
  and h.LIST_USED_BY_ID = b.schedule_id
  and b.orig_csch_id is not null;

l_incl_header_id	number;

CURSOR c_repeat_tg_id is
  SELECT a.list_header_id
    FROM ams_act_lists a ,ams_act_lists b
   WHERE a.list_used_by_id   = b.list_used_by_id
     AND a.list_used_by =   b.list_used_by
     AND b.list_header_id =   g_list_header_id
     AND b.list_act_type  =   'TARGET'
     and a.list_act_type <> 'TARGET'
	 and a.list_action_type = 'INCLUDE'
   ORDER by a.order_number;


--Bug 4685389. bmuthukr. to check the total # of parameters
cursor c_check_num_params(p_incl_object_id number) is
select count(1)
  from ams_list_queries_param
 where list_query_id = p_incl_object_id;

 l_tot_params   number := 0;
--

BEGIN
  --IF(p_log_flag ='Y')then
  write_to_act_log('Executing process_tar_actions. ','LIST',g_list_header_id, 'HIGH');
  --END IF;

l_const_sql := ' minus '||
               ' select list_entry_source_system_id ' ||
               ' from ams_list_entries ' ||
               ' where list_header_id  = ' || p_action_used_by_id   ;

l_const_sql1 := '   and LIST_SELECT_ACTION_ID = ';

  open c_repeat_tg;
  fetch c_repeat_tg into l_repeat_tg;
  close c_repeat_tg;
 write_to_act_log(p_msg_data => 'Repeat  TG - '||l_repeat_tg,
		  p_arc_log_used_by => 'LIST',
		  p_log_used_by_id  => g_list_header_id,
		  p_level=>'LOW');
  OPEN C_ACTION_DETS;
  LOOP
    FETCH c_action_dets INTO l_action_dets_rec;
    EXIT WHEN c_action_dets%NOTFOUND;

     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration : before IMMEDIATE');
     FND_MSG_PUB.Add;
     write_to_act_log('Selection included in target group is of type '||l_action_dets_rec.list_act_type||' , action type is '||l_action_dets_rec.list_action_type, 'LIST', g_list_header_id,'HIGH');
     write_to_act_log('List header id is '||l_action_dets_rec.list_header_id||' act list header id is '||l_action_dets_rec.act_list_header_id||' and order no is '||l_action_dets_rec.order_number, 'LIST', g_list_header_id,'HIGH');
   if l_action_dets_rec.list_act_type = 'SQL' then
      OPEN c_query( l_action_dets_rec.list_header_id );
      FETCH c_query INTO l_PARAMETERIZED_FLAG  ;
      close  c_query;
   end if;

   -- Bug 4685389. bmuthukr. to check the total # of parameters. If it exceeds 100 abort the process
   if nvl(l_parameterized_flag,'N') = 'Y' then

      open c_check_num_params(l_action_dets_rec.list_header_id);
      fetch c_check_num_params into l_tot_params;
      close c_check_num_params;

      if nvl(l_tot_params,0) > 100 then
         write_to_act_log('Numbers of parameters exceed 100. Aborting list generation process. Please redefine your criteria and restrict it to 100.',
	 'LIST',g_list_header_id,'HIGH');

         UPDATE ams_list_headers_all
            SET last_generation_success_flag = 'N',
                status_code                  = 'FAILED',
                ctrl_status_code             = 'DRAFT',
                user_status_id               = 311,
                status_date                  = sysdate,
                last_update_date             = sysdate,
                main_gen_end_time            = sysdate,
                no_of_rows_in_ctrl_group     = null
          WHERE list_header_id               = g_list_header_id;
         x_return_status := 'E';
         logger;
   	 commit;
         RETURN;
      end if;
   end if;
   --

   -- Changes for employee list issue..
   if l_action_dets_rec.list_act_type NOT IN ('IMPH','LIST','SQL','DIWB','CELL') then
      write_to_act_log(p_msg_data => 'Invalid included object-- Valid inclusions are imported list, list, custom sql, segment, work book. Aborting list generation process.',
                       p_arc_log_used_by => 'LIST',
                       p_log_used_by_id  => g_list_header_id,
		       p_level => 'HIGH');

        UPDATE ams_list_headers_all
        SET    last_generation_success_flag = 'N',
               status_code                  = 'FAILED',
               user_status_id               = 311,
               status_date                  = sysdate,
               last_update_date             = sysdate,
               main_gen_end_time            = sysdate,
	       ctrl_status_code             = 'DRAFT',
	       no_of_rows_in_ctrl_group     = null
        WHERE  list_header_id               = g_list_header_id;

    -- Added for cancel list gen as it prevents parallel update- Raghu
    -- of list headers when cancel button is pressed
    commit;

     x_return_status := 'E';
     x_msg_count := 1;
     x_msg_data := ' Invalid Included Object--Valid inclusions are imported list, list, custom sql, segment, work book';
     RETURN;
   end if;
   --

/******************************************************************************/
/************** call for cancel list generation added 05/23/2005 **************/
/******************************************************************************/
-- inside process_tar_actions

   AMS_LISTGENERATION_UTIL_PKG.cancel_list_gen(
                  p_list_header_id => g_list_header_id ,
                  p_remote_gen     => g_remote_list    ,
                  p_remote_gen_list=> g_remote_list_gen,
                  p_database_link  => g_database_link,
                  x_msg_count      => x_msg_count ,
                  x_msg_data       => x_msg_data ,
                  x_return_status  => x_return_status
             );

  IF(x_return_status <> FND_API.G_RET_STS_SUCCESS )THEN
     if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
        write_to_act_log('Error in Cancel List generation', 'LIST', g_list_header_id,'HIGH');
        write_to_act_log('Error while executing Cancel List generation '||sqlerrm||sqlcode, 'LIST', g_list_header_id,'HIGH');
     end if;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     write_to_act_log('Success in Cancel List generation', 'LIST', g_list_header_id,'LOW');
  END IF;

/******************************************************************************/
/************** call for cancel list generation added 05/23/2005 **************/
/******************************************************************************/

      write_to_act_log('Calling process_'||l_action_dets_rec.list_act_type,'LIST',g_list_header_id,'LOW');
      execute immediate
      'BEGIN
        AMS_ListGeneration_PKG.process_'||l_action_dets_rec.list_act_type ||
         '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12) ;
      END;'
      using  p_action_used_by_id,
             l_action_dets_rec.list_header_id ,
             l_action_dets_rec.list_action_type,
             l_action_dets_rec.act_list_header_id,
             l_action_dets_rec.order_number,
             l_action_dets_rec.order_number,
             'N',--CHECK p_action_rec.incl_control_group,
             OUT  x_msg_data,
             OUT  x_msg_count,
             in OUT  x_return_status ,
             OUT l_std_sql ,
             OUT l_include_sql;
    if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
       write_to_act_log('Error when executing process_'||l_action_dets_rec.list_act_type, 'LIST', g_list_header_id,'HIGH');
       write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
       UPDATE ams_list_headers_all
          SET last_generation_success_flag = 'N',
              status_code                  = 'FAILED',
              user_status_id               = 311,
              status_date                  = sysdate,
              last_update_date             = sysdate,
              main_gen_end_time            = sysdate
        WHERE list_header_id               = g_list_header_id;
       commit;
       RETURN;
    else
       write_to_act_log('Process_'||l_action_dets_rec.list_act_type||' executed successfully.', 'LIST', g_list_header_id,'LOW');
    end if;

     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration : AFTER IMMEDIATE');
     FND_MSG_PUB.Add;

     if l_action_dets_rec.list_action_type  = 'INCLUDE' then
        l_include_count := l_include_count +1  ;
        l_include_sql_tbl(l_include_count) := l_include_sql ;
        l_std_sql_tbl(l_include_count)  := l_std_sql;
        l_rank_tbl(l_include_count)  :=  lpad(l_action_dets_rec.Order_number,50,'0')
                         || lpad(l_action_dets_rec.order_number,50,'0');

	l_dist_pct_tbl(l_include_count) := l_action_dets_rec.distribution_pct;
        l_list_select_id(l_include_count) := l_action_dets_rec.act_list_header_id;
        l_incl_object_type(l_include_count) := l_action_dets_rec.arc_incl_object_from;

     else
        if l_action_dets_rec.list_action_type  = 'EXCLUDE' then
           l_join_string := ' minus ';
           l_list_header_id := l_action_dets_rec.list_header_id;
           open c1;
           FETCH c1 into l_generation_type;
           close c1;
        else
           l_join_string := ' intersect ';
           l_list_header_id := l_action_dets_rec.list_header_Id;
           open c1;
           FETCH c1 into l_generation_type;
           close c1;
        end if;

        write_to_act_log('SQL statement for INCLUSION','LIST',g_list_header_id,'LOW');

       FOR i IN 1 .. l_include_count
       loop
        l_std_sql_tbl(i)  :=
                               l_std_sql_tbl(i)   ||
                               l_join_string ||
                               l_std_sql;
     l_no_of_chunks  := ceil(length(l_std_sql_tbl(i))/2000 );
     for j in 1 ..l_no_of_chunks
     loop
          null;
        WRITE_TO_ACT_LOG(substrb(l_std_sql_tbl(i),(2000*j) - 1999,2000),'LIST',g_list_header_id, 'LOW');
     end loop;
       end loop;
     end if;


     IF(x_return_status <>FND_API.G_RET_STS_SUCCESS )THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
-- end Of Dynamic Procedure
   l_join_string :='';
   write_to_act_log('Action on this selection completed. ', 'LIST', g_list_header_id,'LOW');
---------------------------------------------------------------------------
  END LOOP;  --  End loop c_action_dets
  CLOSE c_action_dets;

     write_to_act_log('No of inclusions in the selection '|| l_include_count, 'LIST', g_list_header_id,'LOW');
     write_to_act_log('Sorting based on rank for the selection. ', 'LIST', g_list_header_id,'LOW');

/*       -- Sorting According to rank
       FOR i IN 1 .. l_include_count
       loop
          l_rank_num_tbl(i) := i;
          if i <> 1 then
             for j in 1 .. i-1
             loop
               if l_rank_tbl(i)  < l_rank_tbl(l_rank_num_tbl(j)) then
                  for k in reverse j .. i-1
                  loop
                     l_rank_num_tbl(k+1) := l_rank_num_tbl(k);
                  end loop;
                  l_rank_num_tbl(j) := i;
                  exit;
               end if;
             end loop;
	  end if;
       end loop;*/
  for  i in 1 .. l_include_count
  loop
        l_l_sele_action_id := null;
        l_sorted := i;--l_rank_num_tbl(i);
  --      open c_action_dets1;
  --      fetch c_action_dets1 into l_l_sele_action_id,l_order_number;
   --     close c_action_dets1;
        WRITE_TO_ACT_LOG('List selection id is '||l_l_sele_action_id||' for order number '||l_sorted, 'LIST', g_list_header_id,'LOW');
-- l_final_big_sql := l_include_sql_tbl(l_sorted)||l_std_sql_tbl(l_sorted)||l_const_sql||l_const_sql1||l_l_sele_action_id ||')';
     --  l_std_sql_tbl(l_sorted) || l_const_sql || ')';
     WRITE_TO_ACT_LOG('Final SQL formed for generating TG.', 'LIST', g_list_header_id,'LOW');
    if l_final_big_sql is not null then
     l_no_of_chunks  := ceil(length(l_final_big_sql)/2000 );
     for i in 1 ..l_no_of_chunks
     loop
          null;
          WRITE_TO_ACT_LOG(substrb(l_final_big_sql,(2000*i) - 1999,2000),'LIST',g_list_header_id,'LOW');
     end loop;
   end if;

     if l_include_sql_tbl(l_sorted) is not null then
      l_no_of_chunks := 0;
      l_no_of_chunks  := ceil(length(l_include_sql_tbl(l_sorted))/2000 );
      for i in 1 ..l_no_of_chunks
       loop
        WRITE_TO_ACT_LOG(substrb(l_include_sql_tbl(l_sorted),(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
       end loop;
     end if;
    if l_std_sql_tbl(l_sorted) is not null then
      l_no_of_chunks := 0;
      l_no_of_chunks  := ceil(length(l_std_sql_tbl(l_sorted))/2000 );
      for i in 1 ..l_no_of_chunks
       loop
        WRITE_TO_ACT_LOG(substrb(l_std_sql_tbl(l_sorted),(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
       end loop;
    end if;
    if l_const_sql is not null then
     l_no_of_chunks := 0;
     l_no_of_chunks  := ceil(length(l_const_sql)/2000 );
     for i in 1 ..l_no_of_chunks
     loop
        WRITE_TO_ACT_LOG(substrb(l_const_sql,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
     end loop;
    end if;
   -- write_to_act_log(' '||l_const_sql1||to_char(l_l_sele_action_id), 'LIST', g_list_header_id,'LOW');
    if l_PARAMETERIZED_FLAG  = 'N' then
        write_to_act_log('No parameters required for generating this TG', 'LIST', g_list_header_id,'LOW');
        if nvl(l_dist_pct_tbl(l_sorted),100) <> 100 then
           write_to_act_log('Included object is of type '||l_incl_object_type(l_sorted),'LIST',g_list_header_id,'LOW');
	   write_to_act_log('% Requested for this selection is '||l_dist_pct_tbl(l_sorted),'LIST',g_list_header_id,'LOW');
   	   if l_incl_object_type(l_sorted) in ('SQL','DIWB','CELL') then
	      write_to_act_log('Inclusion No is '||l_sorted||'  '||'Included object is of type '||l_incl_object_type(l_sorted),'LIST',g_list_header_id,'LOW');
	      l_temp_sql := l_include_sql_tbl(l_sorted);
	      l_temp_sql := 'SELECT count(1) '||substr(l_temp_sql,instr(l_temp_sql, ' FROM '));
              -- Modified for bug 5238900. bmuthukr
	      -- get_count(l_list_select_id(l_sorted),l_sorted,'OTHERS',l_temp_sql||l_std_sql_tbl(l_sorted)||l_const_sql||l_const_sql1||l_l_sele_action_id||')' );
	      get_count(l_list_select_id(l_sorted),l_sorted,'OTHERS',l_temp_sql||l_std_sql_tbl(l_sorted)||l_const_sql||')' );
           elsif l_incl_object_type(l_sorted) = 'LIST' then
              get_count(l_list_select_id(l_sorted),l_sorted,'LIST',null);
           elsif l_incl_object_type(l_sorted) = 'IMPH' then
              get_count(l_list_select_id(l_sorted),l_sorted,'IMPH',null);
           end if;
           write_to_act_log('No of rows requested from the selection is '||g_reqd_num_tbl(l_sorted),'LIST',g_list_header_id,'LOW');
        else
           g_act_num_tbl(l_sorted)  := -1;
           g_reqd_num_tbl(l_sorted) := -1;
        end if;
        if g_remote_list_gen = 'N' then
                /* If the list is not based on the remote data source and if it's based on remote data source
                   but needs to be generated in the local instance means it's migrated to the local instance */
 	   l_const_sql1 := ' ';
           l_l_sele_action_id := null;
           if g_reqd_num_tbl(l_sorted) <> -1 then
              EXECUTE IMMEDIATE l_include_sql_tbl(l_sorted) ||l_std_sql_tbl(l_sorted) || l_const_sql ||l_const_sql1||l_l_sele_action_id ||')'||' and rownum <= '||g_reqd_num_tbl(l_sorted);
           else
              EXECUTE IMMEDIATE l_include_sql_tbl(l_sorted) ||l_std_sql_tbl(l_sorted) || l_const_sql ||l_const_sql1||l_l_sele_action_id ||')';
           end if;

	   write_to_act_log('Target group generated in local instance', 'LIST', g_list_header_id,'HIGH');
        else
                /* If the list is based on the remote data source and it's not migrated to the local instance or
                   a segment , sql or workbook is in the list selection then it will be generated in the remote
                   instance through a dynamic procedure call */
 	   l_const_sql1 := ' ';
           l_l_sele_action_id := null;

       	   if g_reqd_num_tbl(l_sorted) <> -1 then
	      write_to_act_log('Calling remote procedure to generate target group in remote instance', 'LIST', g_list_header_id,'LOW');
              execute immediate
              'BEGIN
               AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
              ' END;'
              using  '1',
              l_null,
              'T',
              l_null,
              OUT x_return_status,
              OUT x_msg_count,
              OUT x_msg_data,
              g_list_header_id,
              l_include_sql_tbl(l_sorted) ||l_std_sql_tbl(l_sorted) || l_const_sql ||l_const_sql1||l_l_sele_action_id ||')'||' and rownum <= '||g_reqd_num_tbl(l_sorted),
--              l_final_big_sql,
              l_null,
              OUT l_total_recs,
              'LISTGEN';
           else
              execute immediate
      	      'BEGIN
               AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
              ' END;'
              using  '1',
              l_null,
              'T',
              l_null,
              OUT x_return_status,
              OUT x_msg_count,
              OUT x_msg_data,
              g_list_header_id,
              l_include_sql_tbl(l_sorted) ||l_std_sql_tbl(l_sorted) || l_const_sql ||l_const_sql1||l_l_sele_action_id ||')',
	      --   l_final_big_sql,
              l_null,
              OUT l_total_recs,
              'LISTGEN';
           end if;
           if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
              write_to_act_log('Error while executing remote procedure for generating target group', 'LIST', g_list_header_id,'HIGH');
              write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
              --Added for bug 4577528 by bmuthukr.
              update ams_list_headers_all
                 set last_generation_success_flag = 'N',
                     status_code                  = 'FAILED',
                     user_status_id               = 311,
                     status_date                  = sysdate,
                     last_update_date             = sysdate,
                     main_gen_end_time            = sysdate,
		     ctrl_status_code             = 'DRAFT',
                     no_of_rows_in_ctrl_group     = null
               where list_header_id               = g_list_header_id;
 	      update_remote_list_header(g_list_header_id,x_return_status,x_msg_count,x_msg_data);
              write_to_act_log('Aborting list generation ', 'LIST', g_list_header_id,'HIGH');
	      x_return_status := FND_API.g_ret_sts_error; --Gen return status should go to error.
	      return;
	      --
           else
              write_to_act_log('Target group generated in remote instance', 'LIST', g_list_header_id,'HIGH');
           end if;

        end if;
 else  -- For l_PARAMETERIZED_FLAG  = 'Y'
        write_to_act_log('Fetching parameters required for generating this target group', 'LIST', g_list_header_id,'LOW');
 	   l_const_sql1 := ' ';
           l_l_sele_action_id := null;

        for i in 1 .. 100 loop
           l_table_char(i) := ' ';
        end loop;
	 write_to_act_log(p_msg_data => 'Repeat TG = '||l_repeat_tg,
						p_arc_log_used_by => 'LIST',
						p_log_used_by_id  => g_list_header_id,
						p_level =>'LOW');
	l_incl_header_id	:= null;
	if l_repeat_tg = 'Y' then
		open c_repeat_tg_id;
		fetch c_repeat_tg_id into l_incl_header_id;
		close c_repeat_tg_id;
           else
		l_incl_header_id := l_action_dets_rec.list_header_id;
	end if;

--	for i in c_param_values(l_action_dets_rec.list_header_id )
        for i in c_param_values(l_incl_header_id)
        loop
           l_table_char(i.PARAMETER_ORDER) := i.PARAMETER_VALUE;
	   write_to_act_log('Parameter - '||i.parameter_order||' is '||l_table_char(i.PARAMETER_ORDER),'LIST', g_list_header_id,'LOW');
        end loop;
        l_string := 'DECLARE   ' ||
        'l_string1 varchar2(10000) ; ' ||
        'begin    ' ||
	        ' l_string1 :=   :1  || ' || ' :2  || ' || ' :3  || ' || ' :4  || ' ||
                       ' :5  || ' || ' :6  || ' || ' :7  || ' || ' :8  || ' ||
                       ' :9  || ' || ' :10  || ' || ' :11  || ' || ' :12  || ' ||
                       ' :13  || ' || ' :14  || ' || ' :15  || ' || ' :16  || ' ||
                       ' :17  || ' || ' :18  || ' || ' :19  || ' || ' :20  || ' ||
                       ' :21  || ' || ' :22  || ' || ' :23  || ' || ' :24  || ' ||
                       ' :25  || ' || ' :26  || ' || ' :27  || ' || ' :28  || ' ||
                       ' :29  || ' || ' :30  || ' || ' :31  || ' || ' :32  || ' ||
                       ' :33  || ' || ' :34  || ' || ' :35  || ' || ' :36  || ' ||
                       ' :37  || ' || ' :38  || ' || ' :39  || ' || ' :40  || ' ||
                       ' :41  || ' || ' :42  || ' || ' :43  || ' || ' :44  || ' ||
                       ' :45  || ' || ' :46  || ' || ' :47  || ' || ' :48  || ' ||
                       ' :49  || ' || ' :50  || ' || ' :51  || ' || ' :52  || ' ||
                       ' :53  || ' || ' :54  || ' || ' :55  || ' || ' :56  || ' ||
                       ' :57  || ' || ' :58  || ' || ' :59  || ' || ' :60  || ' ||
                       ' :61  || ' || ' :62  || ' || ' :63  || ' || ' :64  || ' ||
                       ' :65  || ' || ' :66  || ' || ' :67  || ' || ' :68  || ' ||
                       ' :69  || ' || ' :70  || ' || ' :71  || ' || ' :72  || ' ||
                       ' :73  || ' || ' :74  || ' || ' :75  || ' || ' :76  || ' ||
                       ' :77  || ' || ' :78  || ' || ' :79  || ' || ' :80  || ' ||
                       ' :81  || ' || ' :82  || ' || ' :83  || ' || ' :84  || ' ||
                       ' :85  || ' || ' :86  || ' || ' :87  || ' || ' :88  || ' ||
                       ' :89  || ' || ' :90  || ' || ' :91  || ' || ' :92  || ' ||
                       ' :93  || ' || ' :94  || ' || ' :95  || ' || ' :96  || ' ||
                       ' :97  || ' || ' :98  || ' || ' :99  || ' || ' :100  ; ' ||' '||
       --  l_final_big_sql ||
l_include_sql_tbl(l_sorted)||l_std_sql_tbl(l_sorted)||l_const_sql||l_const_sql1||l_l_sele_action_id ||')'||
       '; end;  '  ;
/* Changed to fix :1 and :name issue */

     open C_QUERY_TEMP_TYPE ;
        fetch  c_query_temp_type into l_query_templ_flag   ;
           if l_query_templ_flag  = 'Y' then
              l_no_of_chunks := 0;
		-- bmuthukr 4339703
              for i in c_param_values(l_incl_header_id)
              loop
                 l_no_of_chunks := l_no_of_chunks + 1;
                 l_string := replace(l_string,':' || l_no_of_chunks  || ' ' , ':'|| i.parameter_name||' ' );
	      end loop;
           end if;
           l_no_of_chunks := 0;
     close c_query_temp_type ;
 /*END Changed to fix :1 and :name issue */
     WRITE_TO_ACT_LOG('SQL to be executed to generate target group', 'LIST', g_list_header_id,'LOW');
     WRITE_TO_ACT_LOG('Length of the sql  '||length(l_string), 'LIST', g_list_header_id,'LOW');
     l_no_of_chunks  := ceil(length(l_string)/80 );
     for i in 1 ..l_no_of_chunks
     loop
        WRITE_TO_ACT_LOG(substrb(l_string,(80*i) - 79,80), 'LIST', g_list_header_id,'LOW');
        l1 := substrb(l_string,(80*i)-79,80);
     end loop;
if g_remote_list_gen = 'N' then
     WRITE_TO_ACT_LOG('Generating target group with parameters ','LIST', g_list_header_id,'LOW');
execute immediate   l_string
using l_table_char(1), l_table_char(2), l_table_char(3), l_table_char(4),
      l_table_char(5), l_table_char(6), l_table_char(7), l_table_char(8),
      l_table_char(9), l_table_char(10), l_table_char(11), l_table_char(12),
      l_table_char(13), l_table_char(14), l_table_char(15), l_table_char(16),
      l_table_char(17), l_table_char(18), l_table_char(19), l_table_char(20),
      l_table_char(21), l_table_char(22), l_table_char(23), l_table_char(24),
      l_table_char(25), l_table_char(26), l_table_char(27), l_table_char(28),
      l_table_char(29), l_table_char(30), l_table_char(31), l_table_char(32),
      l_table_char(33), l_table_char(34), l_table_char(35), l_table_char(36),
      l_table_char(37), l_table_char(38), l_table_char(39), l_table_char(40),
      l_table_char(41), l_table_char(42), l_table_char(43), l_table_char(44),
      l_table_char(45), l_table_char(46), l_table_char(47), l_table_char(48),
      l_table_char(49), l_table_char(50),
      l_table_char(51), l_table_char(52), l_table_char(53), l_table_char(54),
      l_table_char(55), l_table_char(56), l_table_char(57), l_table_char(58),
      l_table_char(59), l_table_char(60), l_table_char(61), l_table_char(62),
      l_table_char(63), l_table_char(64), l_table_char(65), l_table_char(66),
      l_table_char(67), l_table_char(68), l_table_char(69), l_table_char(70),
      l_table_char(71), l_table_char(72), l_table_char(73), l_table_char(74),
      l_table_char(75), l_table_char(76), l_table_char(77), l_table_char(78),
      l_table_char(79), l_table_char(80), l_table_char(81), l_table_char(82),
      l_table_char(83), l_table_char(84), l_table_char(85), l_table_char(86),
      l_table_char(87), l_table_char(88), l_table_char(89), l_table_char(90),
      l_table_char(91), l_table_char(92), l_table_char(93), l_table_char(94),
      l_table_char(95), l_table_char(96), l_table_char(97), l_table_char(98),
      l_table_char(79), l_table_char(100);
      WRITE_TO_ACT_LOG('Generating target group in local instance.','LIST', g_list_header_id,'HIGH');

 end if;

 if g_remote_list_gen = 'Y' then
    write_to_act_log('Calling remote procedure with parameters to generate target group in remote instance ', 'LIST', g_list_header_id,'LOW');
      	       execute immediate
      	      'BEGIN
       AMS_Remote_ListGen_PKG.remote_param_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,
       :13,:14,:15,:16,:17,:18,:19,:20,
       :21,:22,:23,:24,:25,:26,:27,:28,:29,:30,
       :31,:32,:33,:34,:35,:36,:37,:38,:39,:40,
       :41,:42,:43,:44,:45,:46,:47,:48,:49,:50,
       :51,:52,:53,:54,:55,:56,:57,:58,:59,:60,
       :61,:62,:63,:64,:65,:66,:67,:68,:69,:70,
       :71,:72,:73,:74,:75,:76,:77,:78,:79,:80,
       :81,:82,:83,:84,:85,:86,:87,:88,:89,:90,
       :91,:92,:93,:94,:95,:96,:97,:98,:99,:100,
       :101,:102,:103,:104,:105,:106,:107,:108,:109,:110,:111,:112
       )'||';'||
              ' END;'
              using  '1',
              l_null,
              'T',
              l_null,
              OUT x_return_status,
              OUT x_msg_count,
              OUT x_msg_data,
              g_list_header_id,
	      l_string,
              l_null,
             OUT l_total_recs,
             'PARAMLISTGEN',
      l_table_char(1), l_table_char(2), l_table_char(3), l_table_char(4),
      l_table_char(5), l_table_char(6), l_table_char(7), l_table_char(8),
      l_table_char(9), l_table_char(10), l_table_char(11), l_table_char(12),
      l_table_char(13), l_table_char(14), l_table_char(15), l_table_char(16),
      l_table_char(17), l_table_char(18), l_table_char(19), l_table_char(20),
      l_table_char(21), l_table_char(22), l_table_char(23), l_table_char(24),
      l_table_char(25), l_table_char(26), l_table_char(27), l_table_char(28),
      l_table_char(29), l_table_char(30), l_table_char(31), l_table_char(32),
      l_table_char(33), l_table_char(34), l_table_char(35), l_table_char(36),
      l_table_char(37), l_table_char(38), l_table_char(39), l_table_char(40),
      l_table_char(41), l_table_char(42), l_table_char(43), l_table_char(44),
      l_table_char(45), l_table_char(46), l_table_char(47), l_table_char(48),
      l_table_char(49), l_table_char(50),
      l_table_char(51), l_table_char(52), l_table_char(53), l_table_char(54),
      l_table_char(55), l_table_char(56), l_table_char(57), l_table_char(58),
      l_table_char(59), l_table_char(60), l_table_char(61), l_table_char(62),
      l_table_char(63), l_table_char(64), l_table_char(65), l_table_char(66),
      l_table_char(67), l_table_char(68), l_table_char(69), l_table_char(70),
      l_table_char(71), l_table_char(72), l_table_char(73), l_table_char(74),
      l_table_char(75), l_table_char(76), l_table_char(77), l_table_char(78),
      l_table_char(79), l_table_char(80), l_table_char(81), l_table_char(82),
      l_table_char(83), l_table_char(84), l_table_char(85), l_table_char(86),
      l_table_char(87), l_table_char(88), l_table_char(89), l_table_char(90),
      l_table_char(91), l_table_char(92), l_table_char(93), l_table_char(94),
      l_table_char(95), l_table_char(96), l_table_char(97), l_table_char(98),
      l_table_char(79), l_table_char(100);
      if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
         write_to_act_log('Error while generating target group in remote instance.', 'LIST', g_list_header_id,'HIGH');
         write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
         --Added for bug 4577528 by bmuthukr.
         update ams_list_headers_all
            set last_generation_success_flag = 'N',
                status_code                  = 'FAILED',
                user_status_id               = 311,
                status_date                  = sysdate,
                last_update_date             = sysdate,
                main_gen_end_time            = sysdate,
                ctrl_status_code             = 'DRAFT',
                no_of_rows_in_ctrl_group     = null
          where list_header_id               = g_list_header_id;
         update_remote_list_header(g_list_header_id,x_return_status,x_msg_count,x_msg_data);
         write_to_act_log('Aborting list generation ', 'LIST', g_list_header_id,'HIGH');
	 x_return_status := FND_API.g_ret_sts_error; --Gen return status should go to error.
	 return;
	 --
      else
         write_to_act_log('Target group generated successfully in remote instance', 'LIST', g_list_header_id,'HIGH');
      end if;
    end if;

end if;
  end loop;
    WRITE_TO_ACT_LOG('Execution of procedure process_tar_action completed.', 'LIST', g_list_header_id,'LOW');

EXCEPTION

  WHEN AMS_LISTGENERATION_UTIL_PKG.cancelListGen THEN
     IF(c_action_dets%ISOPEN)THEN
        CLOSE c_action_dets;
     END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     write_to_act_log('executing process_tar_actions - user action to cancel list generation detected ', 'LIST', g_list_header_id,'HIGH');
     -- Got to raise the exception again because Listgen has to end generation.
     raise AMS_LISTGENERATION_UTIL_PKG.cancelListGen;

   WHEN FND_API.G_EXC_ERROR THEN
     IF(c_action_dets%ISOPEN)THEN
        CLOSE c_action_dets;
     END IF;
     -- Check if reset of the status is required
     write_to_act_log('Error while executing procedure process_tar_actions '||sqlcode||'   '||sqlerrm,'LIST',g_list_header_id,'HIGH');
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF(c_action_dets%ISOPEN)THEN
        CLOSE c_action_dets;
     END IF;
     write_to_act_log('Error while executing procedure process_tar_actions '||sqlcode||'   '||sqlerrm,'LIST',g_list_header_id,'HIGH');
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
     IF(c_action_dets%ISOPEN)THEN
        CLOSE c_action_dets;
     END IF;
     write_to_act_log('Error while executing procedure process_tar_actions '||sqlcode||'   '||sqlerrm,'LIST',g_list_header_id,'HIGH');
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END process_tar_actions;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.

PROCEDURE GENERATE_TARGET_GROUP
( p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_header_id         IN     NUMBER,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_msg_count              OUT NOCOPY    NUMBER,
  x_msg_data               OUT NOCOPY    VARCHAR2) IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'GENERATE_LIST';
  l_api_version         CONSTANT NUMBER        := 1.0;

  -----------------------------------------------------------
  --The no. of entries flagged as duplicates for this list.--
  --Only populated if deduplication is requested.          --
  -----------------------------------------------------------
  --gjoby check if l_no_of_duplicates required
  l_no_of_duplicates      NUMBER := 0;

  -- Two records are required for init rec and complete rec
  -- Table ams_list_headers_all_tl and ams_list_headers_all
  l_listheader_rec        ams_listheader_pvt.list_header_rec_type;
  l_tmp_listheader_rec    ams_listheader_pvt.list_header_rec_type;

  -- Two records are required for init rec and complete rec
  -- Table ams_list_select_actions
  l_listaction_rec        ams_listaction_pvt.action_rec_type;
  l_tmp_listaction_rec    ams_listaction_pvt.action_rec_type;
  l_no_of_rows_in_list number ;
  cursor c_get_rows (c_list_header_id in number ) is
  select no_of_rows_in_list
  from ams_list_headers_all
  where list_header_id = c_list_header_id ;
  l_error_position       varchar2(100);


  cursor c_remote_list is
  select nvl(stypes.remote_flag,'N') ,database_link
    from ams_list_src_types stypes, ams_list_headers_all list
   where list.list_source_type = stypes.source_type_code
     and list_header_id  =  p_list_header_id;

  l_list_selection      varchar2(1);
  l_onlylist_selection  varchar2(1);
  cursor c_list_selection is
  select 'Y' from ams_list_select_actions
   where  action_used_by_id = p_list_header_id
     and  arc_action_used_by = 'LIST'
     and  arc_incl_object_from in ('CELL','DIWB','SQL');

  cursor c_only_list_selection is
  select 'Y' from ams_list_select_actions act, ams_list_headers_all head
   where  act.action_used_by_id = p_list_header_id
   and  act.arc_incl_object_from = 'LIST' and act.arc_action_used_by = 'LIST'
   and  act.INCL_OBJECT_ID = head.list_header_id
   and  head.status_code = 'AVAILABLE'
   and  head.MIGRATION_DATE is null;

l_null          varchar2(30) := null;
l_total_recs    number;
l_field_column_name VARCHAR2(30);
l_count             NUMBER;


--Bug 5235979. Bmuthukr

/* cursor c1 is
    SELECT list_rule_id
       FROM ams_list_rule_usages
       WHERE list_header_id = g_list_header_id;*/

CURSOR C1 IS
SELECT us.list_rule_id
  FROM ams_list_rule_usages us, ams_list_rules_all rules
 WHERE us.list_header_id = g_list_header_id
   AND us.list_rule_id = rules.list_rule_id
   AND rules.list_source_type = l_listheader_rec.list_source_type
   AND rules.list_rule_type = 'TARGET';

-- Ends changes

l_list_rule_id number := 0;
l_hd_status	varchar(60);
l_entry_count	number;
cursor c_hd_status is
select STATUS_CODE from ams_list_headers_all
where list_header_id = p_list_header_id;

cursor c_entry_count is
select count(1) from ams_list_entries
where list_header_id = p_list_header_id;

l_list_field_mapped  varchar2(1);

cursor c_master_ds_fields_mapped is
select 'Y' from ams_list_src_fields fd, ams_list_headers_all hd, ams_list_src_types ty
where hd.list_header_id = p_list_header_id
  and hd.LIST_SOURCE_TYPE = ty.source_type_code
  and ty.list_source_type_id = fd.LIST_SOURCE_TYPE_ID
  and fd.FIELD_COLUMN_NAME is NOT NULL;

cursor c_child_ds_fields_mapped is
select 'Y' from ams_list_src_fields fd, ams_list_headers_all hd, ams_list_src_types ty,
ams_list_src_type_assocs ats
where hd.list_header_id = p_list_header_id
  and hd.LIST_SOURCE_TYPE = ty.source_type_code
  and ty.list_source_type_id = ats.master_source_type_id
  and ats.sub_source_type_id = fd.LIST_SOURCE_TYPE_ID
  and fd.FIELD_COLUMN_NAME is NOT NULL;

l_tca_field_mapped  varchar2(1);

l_no_of_rows   number := 0;

cursor c_check_gen_mode is
select nvl(no_of_rows_in_list ,0)
  from ams_list_headers_all
 where list_header_id = g_list_header_id;

-- SOLIN, bug 4410333
-- check whether datasource is enabled.
cursor c_check_datasource(c_list_header_id NUMBER) is
  SELECT a.enabled_flag
  FROM ams_list_src_types a,
       ams_list_headers_all b
  WHERE a.source_type_code = b.list_source_type
    AND b.list_header_id = c_list_header_id;

l_ds_enabled_flag      VARCHAR2(1);
-- SOLIN, end

cursor c_master_ds_tca_mapped is
select 'Y' from ams_list_src_fields fd, ams_list_headers_all hd, ams_list_src_types ty
where hd.list_header_id = p_list_header_id
  and hd.LIST_SOURCE_TYPE = ty.source_type_code
  and ty.list_source_type_id = fd.LIST_SOURCE_TYPE_ID
  and fd.tca_column_id is NOT NULL;

cursor c_child_ds_tca_mapped is
select 'Y' from ams_list_src_fields fd, ams_list_headers_all hd, ams_list_src_types ty,
ams_list_src_type_assocs ats
where hd.list_header_id = p_list_header_id
  and hd.LIST_SOURCE_TYPE = ty.source_type_code
  and ty.list_source_type_id = ats.master_source_type_id
  and ats.sub_source_type_id = fd.LIST_SOURCE_TYPE_ID
  and fd.tca_column_id is NOT NULL;

CURSOR c_get_dup_fields(c_list_header_id NUMBER) IS
SELECT min(master_child.field_column_name1) ,count(master_child.field_column_name) from
  (
  SELECT d.field_column_name field_column_name1,d.field_column_name
  FROM ams_list_src_types a,
       ams_list_headers_all b,
       ams_list_src_fields d
  WHERE a.source_type_code = b.list_source_type
   and b.list_header_id = p_list_header_id
   and d.list_source_type_id = a.list_source_type_id
   and d.USED_IN_LIST_ENTRIES = 'Y'
  union all
   SELECT d.field_column_name field_column_name1,d.field_column_name
  FROM ams_list_src_types a,
       ams_list_headers_all b,
       ams_list_src_fields d,
       ams_list_src_type_assocs e
  WHERE a.source_type_code = b.list_source_type
   and b.list_header_id = p_list_header_id
   and e.master_source_type_id = a.list_source_type_id
   and d.list_source_type_id = e.sub_source_type_id
   and d.USED_IN_LIST_ENTRIES = 'Y'
   ) master_child
  GROUP BY master_child.field_column_name
  having COUNT(master_child.field_column_name) > 1;
l_ctrl_grp_status   VARCHAR2(100);

--bmuthukr bug 4997699
l_ds_name         varchar2(1000);
l_field_col_name  varchar2(1000);
l_source_col_name varchar2(1000);

cursor c_get_dup_mapping(p_col_name in varchar2) is
SELECT d.source_column_name, d.field_column_name , d.de_list_source_type_code  stc
  FROM ams_list_src_types a,
       ams_list_headers_all b,
       ams_list_src_fields d
 WHERE a.source_type_code = b.list_source_type
   and b.list_header_id = g_list_header_id
   and d.list_source_type_id = a.list_source_type_id
   and d.field_column_name = p_col_name
   and d.USED_IN_LIST_ENTRIES = 'Y'
union all
SELECT d.source_column_name, d.field_column_name,  d.de_list_source_type_code stc
  FROM ams_list_src_types a,
       ams_list_headers_all b,
       ams_list_src_fields d,
       ams_list_src_type_assocs e
 WHERE a.source_type_code = b.list_source_type
   and b.list_header_id = g_list_header_id
   and e.master_source_type_id = a.list_source_type_id
   and d.list_source_type_id = e.sub_source_type_id
   and d.field_column_name = p_col_name
   and d.USED_IN_LIST_ENTRIES = 'Y';
--
cursor c_check_supp is
select nvl(apply_suppression_flag,'N')
  from ams_list_headers_all
 where list_header_id = p_list_header_id;

l_supp_flag   varchar2(1) := 'N';

BEGIN


  l_error_position := '<- start List generate ->';
  -----------------------------------------------------------------------------
  -- g_list_header_id global variable for this session
  -- This eliminates the need for passing variables across procedures
  -- Particularly for logging debug messages ams_act_logs
  -----------------------------------------------------------------------------
  g_remote_list           := 'N';
  g_remote_list_gen       := 'N';
  g_database_link         := ' ';
  g_list_header_id        :=  p_list_header_id;

  write_to_act_log(p_msg_data => 'Executing procedure generate_target_group. Target group generation started.',
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => p_list_header_id,
		   p_level => 'HIGH');

  --write_to_act_log(p_msg_data => 'Concurrent request id is '||fnd_global.conc_request_id,p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level => 'HIGH');

  write_to_act_log(p_msg_data => 'Work flow item key(list header id) is '||p_list_header_id||'	 Process type is AMS List Generation',p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level => 'HIGH');

  -- SOLIN, bug 4410333
  l_ds_enabled_flag := 'N';
  OPEN c_check_datasource(p_list_header_id);
  FETCH c_check_datasource INTO l_ds_enabled_flag;
  CLOSE c_check_datasource;

  IF l_ds_enabled_flag = 'N' THEN
     write_to_act_log(
          p_msg_data => 'Aborting the List generation process. The datasource for this list is not enabled. Contact your administrator to enable the datasource, and generate the list again.',
          p_arc_log_used_by => 'LIST',
          p_log_used_by_id  => p_list_header_id,
	  p_level => 'HIGH');
     UPDATE ams_list_headers_all
        SET last_generation_success_flag = 'N',
            status_code                  = 'FAILED',
            user_status_id               = 311,
            status_date                  = sysdate,
            last_update_date             = sysdate,
            main_gen_end_time            = sysdate,
            ctrl_status_code             = 'DRAFT',
            no_of_rows_in_ctrl_group     = null
      WHERE list_header_id               = p_list_header_id;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
      x_return_status := FND_API.g_ret_sts_error;
      --
      logger;
      RETURN;
  END IF;
-- SOLIN, end

  write_to_act_log(p_msg_data => 'Checking if Master/Child datasource fields are mapped.' ,
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => p_list_header_id,
                   p_level =>'LOW');

  open  c_master_ds_fields_mapped;
  fetch c_master_ds_fields_mapped into l_list_field_mapped;
  close c_master_ds_fields_mapped;

  open  c_child_ds_fields_mapped;
  fetch c_child_ds_fields_mapped into l_list_field_mapped;
  close c_child_ds_fields_mapped;

  if l_list_field_mapped is NULL THEN
     write_to_act_log(p_msg_data => 'Master/Child datasource fields are not mapped. Aborting target group generation. ' ,
                      p_arc_log_used_by => 'LIST',
                      p_log_used_by_id  => p_list_header_id,
	     	      p_level =>'HIGH');

      UPDATE ams_list_headers_all
         SET last_generation_success_flag = 'N',
             status_code                  = 'FAILED',
             user_status_id               = 311,
             status_date                  = sysdate,
             last_update_date             = sysdate,
             main_gen_end_time            = sysdate,
             ctrl_status_code             = 'DRAFT',
             no_of_rows_in_ctrl_group     = null
       WHERE list_header_id               = p_list_header_id;
      -- calling logging program
        logger;
      --
      IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
      END IF;
      --Modified by bmuthukr. Bug # 4083665
      x_return_status := FND_API.g_ret_sts_error;
      --
      RETURN;
   end if;




  OPEN c_get_dup_fields(p_list_header_id);
  FETCH c_get_dup_fields INTO l_field_column_name, l_count;
  CLOSE c_get_dup_fields;

  IF l_count>1 THEN
     /*DELETE FROM ams_act_logs
      WHERE arc_act_log_used_by = 'LIST'
        AND act_log_used_by_id  = p_list_header_id ;*/

     write_to_act_log(
          p_msg_data => 'Aborting the Target group generation process. Atleast one list entry column is mapped morethan once in the datasources.Pls see the following details for more info.',
          p_arc_log_used_by => 'LIST',
          p_log_used_by_id  => p_list_header_id,
	  p_level => 'HIGH');

     --bmuthukr bug 4997699
     open c_get_dup_mapping(l_field_column_name);
     loop
        fetch c_get_dup_mapping into l_source_col_name, l_field_col_name  ,l_ds_name;
	exit when c_get_dup_mapping%notfound;
        write_to_Act_log('Data Source Name :- '||l_ds_name||'          '||' Source Column :- '||l_source_col_name||'          '||' List Entries Col :- '||l_field_col_name,'LIST',p_list_header_id,'HIGH');
     end loop;
     --
     UPDATE ams_list_headers_all
        SET last_generation_success_flag = 'N',
            status_code                  = 'FAILED',
            user_status_id               = 311,
            status_date                  = sysdate,
            last_update_date             = sysdate,
            main_gen_end_time            = sysdate,
            ctrl_status_code             = 'DRAFT',
            no_of_rows_in_ctrl_group     = null
      WHERE list_header_id               = g_list_header_id;
      --Modified by bmuthukr. Bug # 4083665
      x_return_status := FND_API.g_ret_sts_error;
      --
      logger;
      RETURN;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Checking if Debug is set. If debug is set then log debugging message
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
  THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration : Start');
     FND_MSG_PUB.Add;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_error_position := '<- Init List->';
  --These values need to be fetched before calling initialize_list. Changes done by bmuthukr.


  open c_remote_list;
  fetch c_remote_list into g_remote_list,g_database_link;
  close c_remote_list;

  if nvl(g_remote_list,'N') = 'N' then
     write_to_act_log(p_msg_data => 'Target group is based not on remote datasource.',
                      p_arc_log_used_by => 'LIST',
                      p_log_used_by_id  => p_list_header_id,
   	   	      p_level => 'LOW');
  elsif nvl(g_remote_list,'Y') = 'Y' then
     write_to_act_log(p_msg_data => 'Target group is based on remote datasource. Database link is  ' ||g_database_link,
                      p_arc_log_used_by => 'LIST',
                      p_log_used_by_id  => p_list_header_id,
   	   	      p_level => 'HIGH');
  end if;

  --

  -----------------------------------------------------------------------------
  -- Gets list header record details
  -- Intialize the record, set the list header id and retrieve the records
  -----------------------------------------------------------------------------
  write_to_act_log(p_msg_data => 'Calling ams_listheader_pvt to get the header details.' ,
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => p_list_header_id,
   	   	   p_level => 'LOW');

  ams_listheader_pvt.init_listheader_rec(l_tmp_listheader_rec);
  l_tmp_listheader_rec.list_header_id   := p_list_header_id;

  l_error_position := '<- complete rec ->';
  ams_listheader_pvt.complete_listheader_rec
                   (p_listheader_rec  =>l_tmp_listheader_rec,
                    x_complete_rec    =>l_listheader_rec);
  -----------------------------------------------------------------------------

  -----------------------------------------------------------
  -- Initializes the list header record
  -----------------------------------------------------------
  l_error_position := '<- Initialize List ->';
  write_to_act_log(p_msg_data => 'Calling initialize_list to initialize the list.' ,
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => p_list_header_id,
   	   	   p_level => 'LOW');

  initialize_List(p_list_header_rec => l_listheader_rec,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  x_return_status   => x_return_status);

  if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
     write_to_act_log('Error while executing procedure initialize_list', 'LIST', g_list_header_id,'HIGH');
     write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
  else
     write_to_act_log('Target group initialized.' ,'LIST',p_list_header_id,'HIGH');
  end if;

  IF x_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;
-- -------------------------------------------------------------------------
  if g_remote_list = 'Y' then
       remote_list_gen(p_list_header_id  => p_list_header_id,
                     x_return_status   => x_return_status,
                     x_msg_count       => x_msg_count,
                     x_msg_data        => x_msg_data,
                     x_remote_gen      => g_remote_list_gen);
     if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
        write_to_act_log('Error in executing remote_list_gen procedure', 'LIST', g_list_header_id,'HIGH');
        write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
     else
        write_to_act_log(p_msg_data => 'remote_list_gen procedure executed successfully.' ,
                         p_arc_log_used_by => 'LIST',
                         p_log_used_by_id  => p_list_header_id,
 			 p_level => 'LOW');
     end if;
  end if;

  if l_listheader_rec.generation_type = 'UPD' then
     open c_check_gen_mode;
     fetch c_check_gen_mode into l_no_of_rows;
     close c_check_gen_mode;

     if l_no_of_rows = 0 then
        write_to_act_log('No entries in list entries table. Unable to generate target group in update mode. Pls generate in full refresh/append mode.','LIST',g_list_header_id,'HIGH');
        UPDATE ams_list_headers_all
           SET last_generation_success_flag = 'N',
               status_code                  = 'FAILED',
               ctrl_status_code             = 'DRAFT',
               user_status_id               = 311,
               status_date                  = sysdate,
               last_update_date             = sysdate,
               main_gen_end_time            = sysdate
         WHERE list_header_id               = g_list_header_id;
         x_return_status := FND_API.g_ret_sts_error;
         logger;
         RETURN;
      end if;
   end if;

--In Update mode need to update only the enabled entries from R12.
/*
  if l_listheader_rec.generation_type = 'UPD' then
     write_to_act_log('Target group is generated in UPDATE mode', 'LIST', g_list_header_id,'HIGH');
       update ams_list_entries
       set newly_updated_flag = 'N' , enabled_flag = 'Y'
         where list_header_id = l_listheader_rec.list_header_id;
*/
   /********************************************************************
    Dynamic procedure will update the list from the remote instance in
    case of remote list
   *********************************************************************/
/*     if g_remote_list = 'Y' then
        write_to_act_log(p_msg_data => 'Updating the target group in remote instance. ' ,
                         p_arc_log_used_by => 'LIST',
                         p_log_used_by_id  => p_list_header_id,
	   	         p_level => 'LOW');
      execute immediate
      'BEGIN
      AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
      ' END;'
      using  '1',
             l_null,
             'T',
             l_null,
             OUT x_return_status,
             OUT x_msg_count,
             OUT x_msg_data,
             l_listheader_rec.list_header_id,
             l_null,
             l_null,
             OUT l_total_recs,
             'UPDATE';
       if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
          write_to_act_log('Error in executing remote procedure', 'LIST', g_list_header_id,'HIGH');
          write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
       else
          write_to_act_log(p_msg_data => 'Target group updated in remote instance. ' ,
                           p_arc_log_used_by => 'LIST',
                           p_log_used_by_id  => p_list_header_id,
	  		   p_level => 'LOW');
       end if;
     end if;
  end if;
*/
  update_remote_list_header(g_list_header_id,x_return_status,x_msg_count,x_msg_data);
  if l_listheader_rec.generation_type = 'UPD' then
     l_error_position := '<- Get_list_entry_data inside deduplication ->';
   -- For bug 5216890
   -- if g_remote_list <> 'Y' then
   --
   -- This will not be performed for the remote list generation
   --
     write_to_act_log('Target group is generated in UPDATE mode in local instance.', 'LIST', g_list_header_id,'HIGH');
     GET_LIST_ENTRY_DATA(
                 p_list_header_id =>l_listheader_rec.list_header_id,
                  x_return_status => x_return_status);
     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;
   --end if;
  -- END IF;
  else
  l_error_position := '<- Process List Actions  ->';
  write_to_act_log('Target group is generated in '||l_listheader_rec.generation_type||' mode.','LIST', g_list_header_id,'HIGH');
  write_to_act_log('Calling process_tar_actions to generate Target group.', 'LIST', g_list_header_id,'LOW');
  process_tar_Actions(p_action_used_by_id => l_listheader_rec.list_header_id,
                       p_action_used_by    => 'LIST',
                       p_log_flag          => l_listheader_rec.enable_log_flag,
                       x_return_status     => x_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data);
     if x_return_status = 'E' then
        logger;
        commit;
        return;
     end if;

  END IF;

  if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
     write_to_act_log('Error in generating list', 'LIST', g_list_header_id,'HIGH');
     write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
  end if;

  IF x_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;


  -- added for R12. bmuthukr
  if l_listheader_rec.generation_type = 'STANDARD' then
     if g_remote_list_gen = 'N' then
        write_to_act_log('Identifying duplicate records(based on party id) in the target group.','LIST',g_list_header_id,'HIGH');
        UPDATE ams_list_entries a
           SET a.enabled_flag  = 'N',
               a.marked_as_duplicate_flag = 'Y'
         WHERE a.list_header_id = p_list_header_id
           AND a.enabled_flag = 'Y'
           AND a.rowid >  (SELECT min(b.rowid)
                             from ams_list_entries  b
                            where b.list_header_id = p_list_header_id
                              and b.party_id = a.party_id
                              and b.enabled_flag = 'Y'
                           );
        write_to_act_log('No of duplicates identified.'||sql%rowcount,'LIST',g_list_header_id,'HIGH');
        open g_initial_count;
        fetch g_initial_count into g_no_of_rows_ini_selected;
        close g_initial_count;
     end if;
  end if;

  --

--** DE DUPLICATION FOR TG START **--
   write_to_act_log('Checking if dedupe is requested for target group. ', 'LIST', p_list_header_id,'HIGH');
   if l_listheader_rec.generation_type = 'STANDARD' then
      open c1;
      fetch c1 into l_list_rule_id ;
      close c1;

      IF (l_list_rule_id <> 0 ) THEN                                  -- NEW logic is base on l_list_rule_id (dedupe rule)
         write_to_act_log('De duplication requested for this target group', 'LIST', g_list_header_id,'LOW');
         l_error_position := '<- de dupe ->';
         if g_remote_list_gen = 'N' then
            /* For local Target Group generation */
            write_to_act_log('Calling ams_listdedupe_pvt for deduplication.', 'LIST', g_list_header_id,'HIGH');
            l_no_of_duplicates := AMS_LISTDEDUPE_PVT.DEDUPE_LIST
                             (p_list_header_id               => p_list_header_id,
                              p_enable_word_replacement_flag => 'Y', -- l_listheader_rec.enable_word_replacement_flag,
                              p_send_to_log    => 'Y', -- l_listheader_rec.enable_log_flag,
                              p_object_name    => 'AMS_LIST_ENTRIES');
            write_to_act_log('Deduplication done for target group.', 'LIST', g_list_header_id,'HIGH');
         else
            /* For Remote Target Group generation */
            write_to_act_log('Calling Execute_Remote_Dedupe_List for deduplication in remote instance.', 'LIST', g_list_header_id,'LOW');
            Execute_Remote_Dedupe_List
                             (p_list_header_id               => p_list_header_id,
                              p_enable_word_replacement_flag => 'Y', -- l_listheader_rec.enable_word_replacement_flag,
                              p_send_to_log    => 'Y', -- l_listheader_rec.enable_log_flag,
                              p_object_name    => 'AMS_LIST_ENTRIES');
         end if;
      END IF; -- for l_list_rule_id
   end if;
   -- Call to suppresion to be done..
   --** DE DUPLICATION FOR TG END   **--
   write_to_Act_log('Generation type is '||l_listheader_rec.generation_type,'LIST',g_list_header_id,'LOW');
   if l_listheader_rec.generation_type in ('STANDARD','INCREMENTAL') then
      open c_check_supp;
      fetch c_check_supp into l_supp_flag;
      close c_check_supp;
      write_to_Act_log('Suppression flag is '||l_supp_flag,'LIST',g_list_header_id,'LOW');
      if nvl(l_supp_flag,'N') = 'Y' then
         write_to_Act_log('Calling suppression api','LIST',g_list_header_id,'LOW');
         ams_act_list_pvt.check_supp(p_list_used_by    =>  l_listheader_rec.arc_list_used_by,
                                     p_list_used_by_id =>  l_listheader_rec.list_used_by_id,
                                     p_list_header_id  =>  l_listheader_rec.list_header_id,
  				     x_return_status   =>  x_return_status,
                                     x_msg_count       =>  x_msg_count,
                                     x_msg_data        =>  x_msg_data);

      end if;

      if nvl(g_remote_list_gen,'N') = 'N' then
         write_to_Act_log('Calling apply_size_reduction procedure','LIST',g_list_header_id,'LOW');
         AMS_List_Options_Pvt.apply_size_reduction(p_list_header_id => g_list_header_id ,
                                                   p_log_level      => g_log_level,
                                                   p_msg_tbl        => g_msg_tbl_opt,
                                                   x_return_status  => x_return_status,
                                                   x_msg_count      => x_msg_count,
                                                   x_msg_data       => x_msg_data);
         if g_msg_tbl_opt.count > 0 then
            for i in g_msg_tbl_opt.first .. g_msg_tbl_opt.last
	    loop
	       write_to_Act_log(g_msg_tbl_opt(I),'LIST',g_list_header_id,'HIGH');
               g_message_table(g_count) := g_msg_tbl_opt(I);
               g_date(g_count) := sysdate;
               g_count   := g_count + 1;
            end loop;
            g_msg_tbl_opt.delete;
         end if;
         write_to_Act_log('apply_size_reduction procedure executed successfully','LIST',g_list_header_id,'LOW');
      else
         write_to_Act_log('Calling apply_size_reduction procedure in the remote database','LIST',g_list_header_id,'LOW');
         execute immediate
         'BEGIN
          AMS_LIST_OPTIONS_PVT.apply_size_reduction'||'@'||g_database_link||'(:1,:2,:3,:4,:5)'||';'||
         ' END;'
         using g_list_header_id,
         'NULL',
	 out x_return_status,
         out x_msg_count,
         out x_msg_data;
         if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
            write_to_act_log('Error while executing apply_size_reduction in the remote database.', 'LIST', g_list_header_id,'HIGH');
            write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
         else
            write_to_act_log('apply_size_reduction procedure executed successfully in the remote database', 'LIST', g_list_header_id,'HIGH');
         end if;
      end if;
   end if;

   -- Call to CG
   if l_listheader_rec.generation_type = 'STANDARD' then
      --if nvl(l_listheader_rec.generate_control_group_flag,'N') <> 'N' then--for now will have to change it later lpo
         if nvl(g_remote_list_gen,'N') = 'N' then
            write_to_Act_log('Calling control_group_generation procedure ','LIST',g_list_header_id,'LOW');
	    AMS_List_Options_Pvt.Control_Group_Generation(p_list_header_id  => g_list_header_id,
  	                                                  p_log_level       => g_log_level,
                                                          p_msg_tbl         => g_msg_tbl_opt,
                                                          x_ctrl_grp_status => l_ctrl_grp_status,
		                                          x_return_status   => x_return_status,
                                                          x_msg_count       => x_msg_count,
                                                          x_msg_data        => x_msg_data);

            if g_msg_tbl_opt.count > 0 then
               for i in g_msg_tbl_opt.first .. g_msg_tbl_opt.last
	       loop
   	          write_to_Act_log(g_msg_tbl_opt(I),'LIST',g_list_header_id,'HIGH');
                  --g_message_table(g_count) := g_msg_tbl_opt(I);
                  --g_date(g_count) := sysdate;
                  --g_count   := g_count + 1;
               end loop;
	       g_msg_tbl_opt.delete;
            end if;
            write_to_act_log('Control group generated successfully', 'LIST', g_list_header_id,'HIGH');
         else
            write_to_Act_log('Calling control_group_generation procedure in the remote database','LIST',g_list_header_id,'LOW');
            execute immediate
            'BEGIN
            AMS_LIST_OPTIONS_PVT.Control_Group_Generation'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6)'||';'||
            ' END;'
            using g_list_header_id,
                  'NULL',
                  out l_ctrl_grp_status,
                  out x_return_status,
		  out x_msg_count,
                  out x_msg_data;
         end if;
         if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
            write_to_act_log('Error while generating control group in the remote database.', 'LIST', g_list_header_id,'HIGH');
            write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
         end if;

      --end if;
   end if;


   if g_remote_list = 'Y' then
       -- ------------------------------------------------
       write_to_act_log(p_msg_data => 'Checking Master/Child datasource fields are mapped with TCA fields.',
                                       p_arc_log_used_by => 'LIST',
                                       p_log_used_by_id  => p_list_header_id,
	  			       p_level => 'LOW');
       open  c_master_ds_tca_mapped;
       fetch c_master_ds_tca_mapped into l_tca_field_mapped;
       close c_master_ds_tca_mapped;

       open  c_child_ds_tca_mapped;
       fetch c_child_ds_tca_mapped into l_tca_field_mapped;
       close c_child_ds_tca_mapped;

       if l_tca_field_mapped is NULL THEN
          write_to_act_log(p_msg_data => 'Master/Child datasource fields are NOT mapped with TCA fields. Aborting target group generation.',
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => p_list_header_id,
		   p_level=>'HIGH');
          write_to_act_log(p_msg_data => 'Deleting entries in the remote instance. Calling remote procedure with process type as DELETE_LIST_ENTRIES.' ,
                      p_arc_log_used_by => 'LIST',
                      p_log_used_by_id  => p_list_header_id,
		      p_level=>'LOW');
          execute immediate
          'BEGIN
	   AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
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
             write_to_act_log('Error in executing remote procedure for deleting target group entries', 'LIST', g_list_header_id,'HIGH');
             write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
          end if;

          UPDATE ams_list_headers_all
             SET last_generation_success_flag = 'N',
	         NO_OF_ROWS_ACTIVE            = null,
	         NO_OF_ROWS_IN_LIST           = null,
                 status_code                  = 'FAILED',
                 user_status_id               = 311,
                 status_date                  = sysdate,
                 last_update_date             = sysdate,
                 main_gen_end_time            = sysdate,
                 ctrl_status_code             = 'DRAFT',
  	         no_of_rows_in_ctrl_group     = null
           WHERE list_header_id               = p_list_header_id;
    -- calling logging program
      logger;
     RETURN;
end if;

  -- ------------------------------------------------

       open c_hd_status;
       fetch c_hd_status into l_hd_status;
       close c_hd_status;

/*********************** changed by savio per bug 3817650 *************/
/* if target group has been generatad locally there is no need to migrate it */

      if g_remote_list_gen = 'Y' then
       write_to_act_log('Status of the list before migrating to local instance : '||l_hd_status, 'LIST', p_list_header_id,'LOW');
       migrate_lists(p_list_header_id);
       write_to_act_log('List migrated to local instance.', 'LIST', p_list_header_id,'LOW');
      end if;
/*********************** changed by savio per bug 3817650 *************/



       open c_hd_status;
       fetch c_hd_status into l_hd_status;
       close c_hd_status;
	if l_hd_status = 'AVAILABLE'  then
       UPDATE ams_list_headers_all
       SET     status_code      = 'GENERATING',
               user_status_id   = 302
       WHERE  list_header_id    = p_list_header_id;
    -- Added for cancel list gen as it prevents parallel update- Raghu
    -- of list headers when cancel button is pressed
      commit;

    end if;

       open c_entry_count;
       fetch c_entry_count into l_entry_count;
       close c_entry_count;

       write_to_act_log('No of entries after migration is '||to_char(l_entry_count), 'LIST', p_list_header_id,'LOW');
       if l_listheader_rec.generation_type <> 'UPD' then
          write_to_act_log('Calling tca_upload_process to upload data in TCA.','LIST', p_list_header_id,'HIGH');
          tca_upload_process
                (p_list_header_id  ,
                 'Y',      -- p_log_flag,
                 x_return_status ,
                 x_msg_count     ,
                 x_msg_data      );
       end if;
       if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
          write_to_act_log('Error while uploading data in TCA.', 'LIST', g_list_header_id,'HIGH');
          write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
       else
          write_to_act_log('TCA upload process completed successfully', 'LIST', g_list_header_id,'HIGH');
       end if;

    END if;
    --Code movded from tg api.
/*    UPDATE ams_list_entries set
           source_code = l_source_code    ,
           arc_list_used_by_source = p_list_used_by ,
           source_code_for_id = p_list_used_by_id
     where list_header_id = g_list_header_id ;

   AMS_LISTGENERATION_PKG.Update_List_Dets(g_list_header_id ,x_return_status ) ;
  */
  -- calling logging program
  write_to_act_log('Execution of procedure generate_target_group completed. Target group generated successfully ','LIST', g_list_header_id, 'HIGH');
  --logger;  -- will be called from ams_act_list_pvt proc.
  --
  -- END of API body.
  --
  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Success Message
  -- MMSG
  --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  --THEN
  FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
  FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration_PKG.Generate_List');
  FND_MSG_PUB.Add;
  --END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
  --THEN
  FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
  FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration_PKG.Generate_List: END');
  FND_MSG_PUB.Add;
  --END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
  -- calling logging program
  write_to_act_log('Error while executing procedure generate_target_group for generating target group.', 'LIST', g_list_header_id,'HIGH');

        UPDATE ams_list_headers_all
        SET    last_generation_success_flag = 'N',
               status_code                  = 'FAILED',
               user_status_id               = 311,
               status_date                  = sysdate,
               last_update_date             = sysdate,
               main_gen_end_time            = sysdate,
               ctrl_status_code             = 'DRAFT',
	       no_of_rows_in_ctrl_group     = null
        WHERE  list_header_id               = p_list_header_id;

        logger;

     --write_to_act_log('Error: AMS_ListGeneration_PKG.Generate_List: '||
           --l_error_position||sqlerrm||sqlcode);
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  -- calling logging program
  write_to_act_log('Error while executing procedure generate_target_group for generating target group.', 'LIST', g_list_header_id,'HIGH');

        UPDATE ams_list_headers_all
        SET    last_generation_success_flag = 'N',
               status_code                  = 'FAILED',
               user_status_id               = 311,
               last_update_date             = sysdate,
               status_date                  = sysdate,
               main_gen_end_time            = sysdate,
               ctrl_status_code             = 'DRAFT',
	       no_of_rows_in_ctrl_group     = null
        WHERE  list_header_id               = p_list_header_id;
        logger;
     --write_to_act_log('Error: AMS_ListGeneration_PKG.Generate_List:'||
                      --l_error_position||sqlerrm||sqlcode);
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
  -- calling logging program
  write_to_act_log('Error while executing procedure generate_target_group for generating target group.', 'LIST', g_list_header_id,'HIGH');

        UPDATE ams_list_headers_all
        SET    last_generation_success_flag = 'N',
               status_code                  = 'FAILED',
               user_status_id               = 311,
               last_update_date             = sysdate,
               status_date                  = sysdate,
               main_gen_end_time            = sysdate,
               ctrl_status_code             = 'DRAFT',
	       no_of_rows_in_ctrl_group     = null
        WHERE  list_header_id               = p_list_header_id;

        logger;

     --write_to_act_log('Error: AMS_ListGeneration_PKG.Generate_List:'||
                       --l_error_position||sqlerrm||sqlcode);
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END GENERATE_TARGET_GROUP;

-- -----------------------------------------------------------------------
PROCEDURE Execute_Remote_Dedupe_List
 (p_list_header_id        AMS_LIST_HEADERS_ALL.LIST_HEADER_ID%TYPE
 ,p_enable_word_replacement_flag
                          AMS_LIST_HEADERS_ALL.ENABLE_WORD_REPLACEMENT_FLAG%TYPE
 ,p_send_to_log           VARCHAR2 := 'N'
 ,p_object_name           VARCHAR2 := 'AMS_LIST_ENTRIES'
 )
IS
    -- the set of rules associated with a list.
    CURSOR c_list_rules (my_list_header_id IN NUMBER)
    IS SELECT list_rule_id
       FROM ams_list_rule_usages
       WHERE list_header_id = my_list_header_id
       ORDER BY priority;

    -- the list of fields for the list rule which are used to generate the key.
    CURSOR c_rule_fields
           (my_list_rule_id IN
            ams_list_rules_all.list_rule_id%TYPE)
    IS
        SELECT field_table_name,
               field_column_name,
               substring_length,
               word_replacement_code
        FROM ams_list_rule_fields
        WHERE list_rule_id = my_list_rule_id;

    -- perform a check to see if this list has been deduped already.
    CURSOR c_deduped_before (my_list_header_id IN NUMBER)
    IS
        SELECT last_deduped_by_user_id
        FROM ams_list_headers_all
        WHERE list_header_id = my_list_header_id;

    -- get a distinct list of merge keys for the list and a
    -- count of the occurance of each key
    -- we also exclude any records where the dedupe flag is already set.
    CURSOR c_dedupe_keys (my_list_header_id IN NUMBER)
    IS
        SELECT DISTINCT dedupe_key, COUNT (dedupe_key)
        FROM ams_list_entries
         WHERE list_header_id = my_list_header_id
         GROUP BY dedupe_key;


    CURSOR c_minimum_rank (my_list_header_id IN NUMBER)
    IS
    SELECT min(b.rank) FROM ams_list_select_actions b
    WHERE b.action_used_by_id = p_list_header_id
    and b.arc_action_used_by = 'LIST'
    GROUP BY b.rank;


    l_sql_stmt1         VARCHAR2(10000);
    l_sql_stmt2         VARCHAR2(10000);

    l_fields            VARCHAR2(10000);
    l_no_of_masters     NUMBER := 0;
    l_list_rule_id      ams_list_rules_all.list_rule_id%TYPE;
    l_last_dedupe_by    ams_list_headers_all.last_deduped_by_user_id%TYPE;
    l_dedupe_key        ams_list_entries.dedupe_key%TYPE;
    l_dedupe_key_count  NUMBER;
    l_rank_count        NUMBER;
    i                   BINARY_INTEGER := 1;

    TYPE rule_details
    IS TABLE OF c_rule_fields%ROWTYPE
    INDEX BY BINARY_INTEGER;

    list_rules          rule_details;
    empty_list_rules    rule_details;

    l_null		varchar(30) := NULL;
    l_total_dup_recs	number;
    l_return_status     varchar(1);
    l_msg_count		number;
    l_msg_data		varchar(2000);
    l_rank              number := 0;
BEGIN
    write_to_act_log('Executing procedure execute_remote_dedupe_list', 'LIST', p_list_header_id,'LOW');
    IF (p_object_name = 'AMS_LIST_ENTRIES') THEN
        l_sql_stmt1 := 'update ams_list_entries set dedupe_key = ';
    END IF;

    --performing check to see if this list has been deduped before.
    OPEN c_deduped_before (p_list_header_id);
    FETCH c_deduped_before INTO l_last_dedupe_by;
    CLOSE c_deduped_before;

    Write_To_Act_Log ('Dedupe started on ' ||TO_CHAR (SYSDATE, 'DD-MON-RRRR HH24:MM:SS'),'LIST',p_list_header_id,'LOW');
        IF  (p_enable_word_replacement_flag = 'Y') THEN
            Write_To_Act_Log ('Word replacement flag is set ' ,'LIST',p_list_header_id,'LOW' );
        END IF;

    -- we must ensure that this flag gets reset to NULL for the list to
    -- ensure accurate results.
    -- if a dedupe has never been perfomed then this field will contains
    -- NULLS and there is no
    -- need to perform this update
    IF  (l_last_dedupe_by IS NOT NULL) THEN
    /*    UPDATE ams_list_entries
           SET dedupe_key = NULL
         WHERE list_header_id = p_list_header_id; */
      write_to_act_log('Executing remote procedure with process type as DEDUPE1', 'LIST', p_list_header_id,'HIGH');
      execute immediate
      'BEGIN
       AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
      ' END;'
      using  '1',
             l_null,
             'T',
             l_null,
             OUT l_return_status,
             OUT l_msg_count,
             OUT l_msg_data,
             p_list_header_id,
             'UPDATE ams_list_entries SET dedupe_key = NULL WHERE list_header_id = '||to_char(p_list_header_id),
             l_null,
             l_null,
             OUT l_total_dup_recs,
             'DEDUPE1';
        if nvl(l_return_status,'S') in ('E','U') then -- resulted in error.
           write_to_act_log('Error in executing remote procedure for dedupe.', 'LIST', p_list_header_id,'HIGH');
           write_to_act_log('Error '||l_msg_data , 'LIST', p_list_header_id,'HIGH');
        else
           write_to_act_log('Remote procedure executed successfully. Dedupe key set to null.', 'LIST', p_list_header_id,'LOW');
        end if;

    END IF;

    -- checking to see if there are any List Source Ranks associated
    -- with the List.
    SELECT COUNT (rank)
      INTO l_rank_count
      FROM ams_list_select_actions
     WHERE action_used_by_id = p_list_header_id
       and arc_action_used_by = 'LIST';

--   Write_To_Act_Log (' # of Ranks for this list = ' ||TO_CHAR (l_rank_count),'LIST',p_list_header_id ,'LOW');

    --getting the list rules for the list.
    OPEN c_list_rules (p_list_header_id);
    LOOP
        FETCH c_list_rules INTO l_list_rule_id;
        Write_To_Act_Log ('List rule id is  ' ||TO_CHAR (l_list_rule_id), 'LIST',p_list_header_id,'LOW' );
        IF (c_list_rules%notfound) THEN
  	   IF  (p_send_to_log = 'Y') THEN
            Write_To_Act_Log ('No more rules associated with the List','LIST',p_list_header_id ,'LOW');
	      NULL;
            END IF;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
                 FND_MESSAGE.set_name('AMS', 'AMS_LIST_NO_LIST_RULE');
                 FND_MSG_PUB.add;
            END IF;

            CLOSE c_list_rules;
            return;
        END IF;

      IF  (c_list_rules%rowcount > 1) THEN
          --we have more than one rule for this list
          --we must ensure that the key gets reset to NULL for the list to
          -- ensure accurate results.
          -- removed khung 07/07/1999
/*
         IF (p_object_name = 'AMS_LIST_ENTRIES') THEN
             UPDATE ams_list_entries
             SET dedupe_key = NULL
             WHERE list_header_id = p_list_header_id
             AND marked_as_duplicate_flag IS NULL;
             COMMIT;
         END IF;
*/
         Write_To_Act_Log ( 'More than one rule cannot be applied to the list','LIST',p_list_header_id ,'HIGH');
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ONLY_ONE_LIST_RULE');
            FND_MSG_PUB.add;
         END IF;

         CLOSE c_list_rules;
         RETURN;
      END IF; -- End of if for more than 1 rule count
      Write_To_Act_Log ('Fetching attributes associated with this rule','LIST',p_list_header_id,'LOW' );
        --fetch the rule entries associated with this list.
        OPEN c_rule_fields (l_list_rule_id);
        LOOP
            FETCH c_rule_fields INTO
                         list_rules (i).field_table_name,
                         list_rules (i).field_column_name,
                         list_rules (i).substring_length,
                         list_rules (i).word_replacement_code;
            EXIT WHEN c_rule_fields%notfound;

            Write_To_Act_Log ('Table name is '||list_rules (i).field_table_name||' ,field column name is '||list_rules (i).field_column_name,'LIST',p_list_header_id ,'LOW');
            -- if the enable word replacement flag is set we construct the sql
            -- to call the filter word function.
            IF  (p_enable_word_replacement_flag = 'Y') THEN
               Write_To_Act_Log ('Calling replact_word procedure for word replacement','LIST',p_list_header_id,'LOW' );
                l_fields :=
                  l_fields ||
                      'AMS_Remote_ListGen_PKG.replace_word(' ||
                      upper(list_rules (i).field_column_name) ||
                      ',' ||
                      '''' ||
                      list_rules (i).word_replacement_code||
                      '''' ||
                      ')' ||
                      '||' ||
                      '''' ||
                      '.' ||
                      '''' ||
                      '||';

            ELSE
            --no substr specified for the rule field.
                IF  (list_rules (i).substring_length IS NULL)
                THEN
                    l_fields :=
                      l_fields ||
                      'upper(' ||
                      list_rules (i).field_column_name ||
                      ')||' ||
                      '''' ||
                      '.' ||
                      '''' ||
                      '||';
                ELSE
                    l_fields :=
                      l_fields ||
                      'upper(substr(' ||
                      list_rules (i).field_column_name ||
                      ',1,' ||
                      TO_CHAR (list_rules (i).substring_length) ||
                      '))||' ||
                      '''' ||
                      '.' ||
                      '''' ||
                      '||';
                END IF;
            END IF;

            i := i + 1;

        END LOOP;   --c_rule_fields

        i := 1;   --reseting to one.
        list_rules := empty_list_rules;   --re-initializing because we can have many rules.
        CLOSE c_rule_fields;

        -- removing the last '.' from the string as this will cause an invalid syntax error
        -- in the query.

        l_fields := SUBSTR (l_fields, 1, LENGTH (l_fields) - 7);

        l_sql_stmt2 := l_sql_stmt1;
        l_sql_stmt2 := l_sql_stmt2 ||
                l_fields ||
                ' where list_header_id =' ||
                TO_CHAR (p_list_header_id);


        Write_To_Act_Log ('SQL generated ' ||l_sql_stmt2 ,'LIST',p_list_header_id,'LOW' );
        --09/27/2000 vbhandar,modified Execute immediate , INTO should only be used for single row queries
        --notice that l_no_of_masters is not really used, left it there to keep the signature of the function
        --Dedupe_LIST unchanged.
--         EXECUTE IMMEDIATE l_sql_stmt2;

      write_to_act_log('Calling remote procedure with process type as DEDUPE2', 'LIST', p_list_header_id,'LOW');
      execute immediate
      'BEGIN
       AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
      ' END;'
      using  '1',
             l_null,
             'T',
             l_null,
             OUT l_return_status,
             OUT l_msg_count,
             OUT l_msg_data,
             p_list_header_id,
             l_sql_stmt2,
             l_null,
             OUT l_total_dup_recs,
             'DEDUPE2';
    if nvl(l_return_status,'S') in ('E','U') then -- resulted in error.
       write_to_act_log('Error in executing remote procedure with process type as DEDUPE2', 'LIST', p_list_header_id,'HIGH');
       write_to_act_log('Error '||l_msg_data , 'LIST', p_list_header_id,'HIGH');
    else
       write_to_act_log('Remote procedure executed successfully for dedupe', 'LIST', p_list_header_id,'LOW');
    end if;

      open c_minimum_rank(p_list_header_id);
      fetch c_minimum_rank into l_rank;
      close c_minimum_rank;

      write_to_act_log('Calling remote procedure with process type as DEDUPE3 for identifying duplicates based on rank', 'LIST', p_list_header_id,'LOW');
      execute immediate
      'BEGIN
      AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||g_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
      ' END;'
      using  '1',
             l_null,
             'T',
             l_null,
             OUT l_return_status,
             OUT l_msg_count,
             OUT l_msg_data,
             p_list_header_id,
             l_rank_count,
             l_rank,
             OUT l_total_dup_recs,
             'DEDUPE3';
        if nvl(l_return_status,'S') in ('E','U') then -- resulted in error.
           write_to_act_log('Error in executing remote procedure with process type as DEDUPE3', 'LIST', p_list_header_id,'HIGH');
           write_to_act_log('Error '||l_msg_data , 'LIST', p_list_header_id,'HIGH');
        else
          write_to_act_log('Remote procedure executed successfully, duplicated identified based on rank', 'LIST', p_list_header_id,'LOW');
        end if;

        --initializing as we may have more than one rule.

        l_fields := NULL;
        l_sql_stmt2 := l_sql_stmt1;

    END LOOP;   --c_list_rules loop

    --recording who performed the deduplication and at what time.
    --recording the number of duplicates found.
    UPDATE ams_list_headers_all
       SET last_deduped_by_user_id = FND_GLOBAL.User_Id
           ,last_dedupe_date = SYSDATE
           ,no_of_rows_duplicates = l_total_dup_recs
     WHERE list_header_id = p_list_header_id;

   /*   savio removing potential multiple update statement */
   /*
--    UPDATE ams_list_headers_all
--       SET no_of_rows_duplicates = l_total_dup_recs
--     WHERE list_header_id = p_list_header_id;
   */

    write_to_act_log('Updated list header table with the userid and the time','LIST',p_list_header_id, 'LOW');
    write_to_act_log('Procedure execute_remote_dedupe_list executed','LIST',p_list_header_id, 'LOW');

    COMMIT;

END Execute_Remote_Dedupe_List;
-- -----------------------------

PROCEDURE migrate_lists_from_remote(
                            Errbuf          OUT NOCOPY     VARCHAR2,
                            Retcode         OUT NOCOPY     VARCHAR2,
                            p_list_header_id NUMBER
                            ) IS

l_list_header_id	NUMBER;
  cursor c_migrate_list is
  select head.list_header_id
    from ams_list_headers_all head, ams_list_src_types stypes
   where head.status_code = 'AVAILABLE'
     and head.MIGRATION_DATE is NULL
     and head.list_source_type = stypes.source_type_code
     and stypes.remote_flag = 'Y';

Begin

Ams_Utility_Pvt.Write_Conc_log('Start migrate_lists_from_remote : ');
if p_list_header_id is not null then
     migrate_lists( p_list_header_id ) ;
 else
  open c_migrate_list;
  LOOP
    fetch c_migrate_list into l_list_header_id;
    exit when c_migrate_list%notfound;
     migrate_lists( l_list_header_id ) ;
  END LOOP;
  close c_migrate_list;
end if;
commit;
Ams_Utility_Pvt.Write_Conc_log('End migrate_lists_from_remote : ');
EXCEPTION
  WHEN OTHERS THEN
   Ams_Utility_Pvt.Write_Conc_log('Exception in migrate_lists_from_remote : '||SQLERRM);
    errbuf:= substr(SQLERRM,1,254);
    retcode:= 2;
   raise;
End migrate_lists_from_remote;
-- -----------------------------------------------------------------

PROCEDURE migrate_lists(
                            p_list_header_id NUMBER
                            ) IS

l_dblink        varchar2(100);
l_start_rownum	number := 1;
l_end_rownum	number := 10000;
l_total_records number;
l_insert_sql   varchar2(32767);
l_return_status varchar2(1);
l_lookup_code                         VARCHAR2(30);
l_user_status_id                      NUMBER;
l_no_of_chunks				number;


  cursor c_dblink is
  select database_link
    from ams_list_src_types stypes, ams_list_headers_all list
   where list.list_source_type = stypes.source_type_code
     and list_header_id  =  p_list_header_id;

begin
 Ams_Utility_Pvt.Write_Conc_log('Start migrate_lists : '||to_char(p_list_header_id));

 open c_dblink;
 fetch c_dblink into l_dblink;
 close c_dblink;
 Ams_Utility_Pvt.Write_Conc_log('l_dblink : '||l_dblink);

 write_to_act_log('Database link is '||l_dblink,'LIST',p_list_header_id,'LOW');
 Ams_Utility_Pvt.Write_Conc_log('Start Delete list entries from local instance  : ');
 write_to_act_log('Deleting existing entries from the local instance.','LIST',p_list_header_id,'LOW');
  delete from ams_list_entries
   where list_header_id = p_list_header_id;
 Ams_Utility_Pvt.Write_Conc_log('End Delete list entries from local instance  : ');

       l_insert_sql := 'insert into ams_list_entries
        (list_header_id ,
         list_entry_id,
         object_version_number,
         source_code                     ,
         source_code_for_id              ,
         arc_list_used_by_source         ,
         arc_list_select_action_from     ,
         pin_code                        ,
         view_application_id             ,
         manually_entered_flag           ,
         marked_as_random_flag           ,
         marked_as_duplicate_flag        ,
         part_of_control_group_flag      ,
         exclude_in_triggered_list_flag  ,
         enabled_flag ,
         LIST_SELECT_ACTION_FROM_NAME,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         list_entry_source_system_id,
         list_entry_source_system_type,
         list_select_action_id,
         SUFFIX,
         FIRST_NAME,
         LAST_NAME,
         CUSTOMER_NAME,
         TITLE,
         ADDRESS_LINE1,
         ADDRESS_LINE2,
         CITY,
         STATE,
         ZIPCODE,
         COUNTRY,
         FAX,
         PHONE,
         EMAIL_ADDRESS,
         CUSTOMER_ID                              ,
         LIST_SOURCE                              ,
         PARTY_ID                                 ,
         PARENT_PARTY_ID                          ,
         IMP_SOURCE_LINE_ID                       ,
         COL1,
         COL2,
         COL3,
         COL4,
         COL5,
         COL6,
         COL7,
         COL8,
         COL9,
         COL10,
         COL11,
         COL12,
         COL13,
         COL14,
         COL15,
         COL16,
         COL17,
         COL18,
         COL19,
         COL20,
         COL21,
         COL22,
         COL23,
         COL24,
         COL25,
         COL26,
         COL27,
         COL28,
         COL29,
         COL30,
         COL31,
         COL32,
         COL33,
         COL34,
         COL35,
         COL36,
         COL37,
         COL38,
         COL39,
         COL40,
         COL41,
         COL42,
         COL43,
         COL44,
         COL45,
         COL46,
         COL47,
         COL48,
         COL49,
         COL50,
         COL51,
         COL52,
         COL53,
         COL54,
         COL55,
         COL56,
         COL57,
         COL58,
         COL59,
         COL60,
         COL61,
         COL62,
         COL63,
         COL64,
         COL65,
         COL66,
         COL67,
         COL68,
         COL69,
         COL70,
         COL71,
         COL72,
         COL73,
         COL74,
         COL75,
         COL76,
         COL77,
         COL78,
         COL79,
         COL80,
         COL81,
         COL82,
         COL83,
         COL84,
         COL85,
         COL86,
         COL87,
         COL88,
         COL89,
         COL90,
         COL91,
         COL92,
         COL93,
         COL94,
         COL95,
         COL96,
         COL97,
         COL98,
         COL99,
         COL100,
         COL101,
         COL102,
         COL103,
         COL104,
         COL105,
         COL106,
         COL107,
         COL108,
         COL109,
         COL110,
         COL111,
         COL112,
         COL113,
         COL114,
         COL115,
         COL116,
         COL117,
         COL118,
         COL119,
         COL120,
         COL121,
         COL122,
         COL123,
         COL124,
         COL125,
         COL126,
         COL127,
         COL128,
         COL129,
         COL130,
         COL131,
         COL132,
         COL133,
         COL134,
         COL135,
         COL136,
         COL137,
         COL138,
         COL139,
         COL140,
         COL141,
         COL142,
         COL143,
         COL144,
         COL145,
         COL146,
         COL147,
         COL148,
         COL149,
         COL150,
         COL151,
         COL152,
         COL153,
         COL154,
         COL155,
         COL156,
         COL157,
         COL158,
         COL159,
         COL160,
         COL161,
         COL162,
         COL163,
         COL164,
         COL165,
         COL166,
         COL167,
         COL168,
         COL169,
         COL170,
         COL171,
         COL172,
         COL173,
         COL174,
         COL175,
         COL176,
         COL177,
         COL178,
         COL179,
         COL180,
         COL181,
         COL182,
         COL183,
         COL184,
         COL185,
         COL186,
         COL187,
         COL188,
         COL189,
         COL190,
         COL191,
         COL192,
         COL193,
         COL194,
         COL195,
         COL196,
         COL197,
         COL198,
         COL199,
         COL200,
         COL201,
         COL202,
         COL203,
         COL204,
         COL205,
         COL206,
         COL207,
         COL208,
         COL209,
         COL210,
         COL211,
         COL212,
         COL213,
         COL214,
         COL215,
         COL216,
         COL217,
         COL218,
         COL219,
         COL220,
         COL221,
         COL222,
         COL223,
         COL224,
         COL225,
         COL226,
         COL227,
         COL228,
         COL229,
         COL230,
         COL231,
         COL232,
         COL233,
         COL234,
         COL235,
         COL236,
         COL237,
         COL238,
         COL239,
         COL240,
         COL241,
         COL242,
         COL243,
         COL244,
         COL245,
         COL246,
         COL247,
         COL248,
         COL249,
         COL250 ,
         COL251     ,
         COL252     ,
         COL253     ,
         COL254     ,
         COL256     ,
         COL255     ,
         COL257     ,
         COL258     ,
         COL259     ,
         COL260     ,
         COL261     ,
         COL262     ,
         COL263     ,
         COL264     ,
         COL265     ,
         COL266     ,
         COL267     ,
         COL268     ,
         COL269     ,
         COL270     ,
         COL271     ,
         COL272     ,
         COL273     ,
         COL274     ,
         COL275     ,
         COL276     ,
         COL277     ,
         COL278     ,
         COL279     ,
         COL280     ,
         COL281     ,
         COL282     ,
         COL283     ,
         COL284     ,
         COL285     ,
         COL286     ,
         COL287     ,
         COL288     ,
         COL289     ,
         COL290     ,
         COL291     ,
         COL292     ,
         COL293     ,
         COL294     ,
         COL295     ,
         COL296     ,
         COL297     ,
         COL298     ,
         COL299     ,
         COL300     ,
GROUP_CODE,
NEWLY_UPDATED_FLAG,
OUTCOME_ID,
RESULT_ID,
REASON_ID,
NOTES,
VEHICLE_RESPONSE_CODE,
SALES_AGENT_EMAIL_ADDRESS,
RESOURCE_ID,
LOCATION_ID,
CONTACT_POINT_ID,
ORIG_SYSTEM_REFERENCE,
MARKED_AS_FATIGUED_FLAG,
MARKED_AS_SUPPRESSED_FLAG,
REMOTE_LIST_ENTRY_ID,
-- ERROR_TEXT,
-- ERROR_FLAG,
LAST_CONTACTED_DATE,
CUSTOM_COLUMN1,
CUSTOM_COLUMN2,
CUSTOM_COLUMN3,
CUSTOM_COLUMN4,
CUSTOM_COLUMN5,
CUSTOM_COLUMN6,
CUSTOM_COLUMN7,
CUSTOM_COLUMN8,
CUSTOM_COLUMN9,
CUSTOM_COLUMN10,
CUSTOM_COLUMN11,
CUSTOM_COLUMN12,
CUSTOM_COLUMN13,
CUSTOM_COLUMN14,
CUSTOM_COLUMN15,
CUSTOM_COLUMN16,
CUSTOM_COLUMN17,
CUSTOM_COLUMN18,
CUSTOM_COLUMN19,
CUSTOM_COLUMN20,
CUSTOM_COLUMN21,
CUSTOM_COLUMN22,
CUSTOM_COLUMN23,
CUSTOM_COLUMN24,
CUSTOM_COLUMN25,
RANK
        )
	SELECT
         list_header_id,
         ams_list_entries_s.nextval,
         object_version_number,
         source_code                     ,
         source_code_for_id              ,
         arc_list_used_by_source         ,
         arc_list_select_action_from     ,
         pin_code                        ,
         view_application_id             ,
         manually_entered_flag           ,
         marked_as_random_flag           ,
         marked_as_duplicate_flag        ,
         part_of_control_group_flag      ,
         exclude_in_triggered_list_flag  ,
         enabled_flag ,
         LIST_SELECT_ACTION_FROM_NAME,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         list_entry_source_system_id,
         list_entry_source_system_type,
         list_select_action_id,
         SUFFIX,
         FIRST_NAME,
         LAST_NAME,
         CUSTOMER_NAME,
         TITLE,
         ADDRESS_LINE1,
         ADDRESS_LINE2,
         CITY,
         STATE,
         ZIPCODE,
         COUNTRY,
         FAX,
         PHONE,
         EMAIL_ADDRESS,
         CUSTOMER_ID                              ,
         LIST_SOURCE                              ,
         null,  -- PARTY_ID                                 ,
         null,  -- PARENT_PARTY_ID                          ,
         IMP_SOURCE_LINE_ID                       ,
         COL1,
         COL2,
         COL3,
         COL4,
         COL5,
         COL6,
         COL7,
         COL8,
         COL9,
         COL10,
         COL11,
         COL12,
         COL13,
         COL14,
         COL15,
         COL16,
         COL17,
         COL18,
         COL19,
         COL20,
         COL21,
         COL22,
         COL23,
         COL24,
         COL25,
         COL26,
         COL27,
         COL28,
         COL29,
         COL30,
         COL31,
         COL32,
         COL33,
         COL34,
         COL35,
         COL36,
         COL37,
         COL38,
         COL39,
         COL40,
         COL41,
         COL42,
         COL43,
         COL44,
         COL45,
         COL46,
         COL47,
         COL48,
         COL49,
         COL50,
         COL51,
         COL52,
         COL53,
         COL54,
         COL55,
         COL56,
         COL57,
         COL58,
         COL59,
         COL60,
         COL61,
         COL62,
         COL63,
         COL64,
         COL65,
         COL66,
         COL67,
         COL68,
         COL69,
         COL70,
         COL71,
         COL72,
         COL73,
         COL74,
         COL75,
         COL76,
         COL77,
         COL78,
         COL79,
         COL80,
         COL81,
         COL82,
         COL83,
         COL84,
         COL85,
         COL86,
         COL87,
         COL88,
         COL89,
         COL90,
         COL91,
         COL92,
         COL93,
         COL94,
         COL95,
         COL96,
         COL97,
         COL98,
         COL99,
         COL100,
         COL101,
         COL102,
         COL103,
         COL104,
         COL105,
         COL106,
         COL107,
         COL108,
         COL109,
         COL110,
         COL111,
         COL112,
         COL113,
         COL114,
         COL115,
         COL116,
         COL117,
         COL118,
         COL119,
         COL120,
         COL121,
         COL122,
         COL123,
         COL124,
         COL125,
         COL126,
         COL127,
         COL128,
         COL129,
         COL130,
         COL131,
         COL132,
         COL133,
         COL134,
         COL135,
         COL136,
         COL137,
         COL138,
         COL139,
         COL140,
          COL141,
          COL142,
          COL143,
          COL144,
          COL145,
          COL146,
          COL147,
          COL148,
          COL149,
          COL150,
          COL151,
          COL152,
          COL153,
          COL154,
          COL155,
          COL156,
          COL157,
          COL158,
          COL159,
          COL160,
          COL161,
          COL162,
          COL163,
          COL164,
          COL165,
          COL166,
          COL167,
          COL168,
          COL169,
          COL170,
          COL171,
          COL172,
          COL173,
          COL174,
          COL175,
          COL176,
          COL177,
          COL178,
          COL179,
          COL180,
          COL181,
          COL182,
          COL183,
          COL184,
          COL185,
          COL186,
          COL187,
          COL188,
          COL189,
          COL190,
          COL191,
          COL192,
          COL193,
          COL194,
          COL195,
          COL196,
          COL197,
          COL198,
          COL199,
          COL200,
          COL201,
          COL202,
          COL203,
          COL204,
          COL205,
          COL206,
          COL207,
          COL208,
          COL209,
          COL210,
          COL211,
          COL212,
          COL213,
          COL214,
          COL215,
          COL216,
          COL217,
          COL218,
          COL219,
          COL220,
          COL221,
          COL222,
          COL223,
          COL224,
          COL225,
          COL226,
          COL227,
          COL228,
          COL229,
          COL230,
          COL231,
          COL232,
          COL233,
          COL234,
          COL235,
          COL236,
          COL237,
          COL238,
          COL239,
          COL240,
          COL241,
          COL242,
          COL243,
          COL244,
          COL245,
          COL246,
          COL247,
          COL248,
          COL249,
          COL250 ,
          COL251 ,
          COL252 ,
          COL253 ,
          COL254 ,
          COL256 ,
          COL255 ,
          COL257 ,
          COL258 ,
          COL259 ,
          COL260 ,
          COL261 ,
          COL262 ,
          COL263 ,
          COL264 ,
          COL265 ,
          COL266 ,
          COL267 ,
          COL268 ,
          COL269 ,
          COL270 ,
          COL271 ,
          COL272 ,
          COL273 ,
          COL274 ,
          COL275 ,
          COL276 ,
          COL277 ,
          COL278 ,
          COL279 ,
          COL280 ,
          COL281 ,
          COL282 ,
          COL283 ,
          COL284 ,
          COL285 ,
          COL286 ,
          COL287 ,
          COL288 ,
          COL289 ,
          COL290 ,
          COL291 ,
          COL292 ,
          COL293 ,
          COL294 ,
          COL295 ,
          COL296 ,
          COL297 ,
          COL298 ,
          COL299 ,
          COL300 ,
GROUP_CODE,
NEWLY_UPDATED_FLAG,
OUTCOME_ID,
RESULT_ID,
REASON_ID,
NOTES,
VEHICLE_RESPONSE_CODE,
SALES_AGENT_EMAIL_ADDRESS,
RESOURCE_ID,
LOCATION_ID,
CONTACT_POINT_ID,
ORIG_SYSTEM_REFERENCE,
MARKED_AS_FATIGUED_FLAG,
MARKED_AS_SUPPRESSED_FLAG,
LIST_ENTRY_ID,
-- ERROR_TEXT,
-- ERROR_FLAG,
LAST_CONTACTED_DATE,
CUSTOM_COLUMN1,
CUSTOM_COLUMN2,
CUSTOM_COLUMN3,
CUSTOM_COLUMN4,
CUSTOM_COLUMN5,
CUSTOM_COLUMN6,
CUSTOM_COLUMN7,
CUSTOM_COLUMN8,
CUSTOM_COLUMN9,
CUSTOM_COLUMN10,
CUSTOM_COLUMN11,
CUSTOM_COLUMN12,
CUSTOM_COLUMN13,
CUSTOM_COLUMN14,
CUSTOM_COLUMN15,
CUSTOM_COLUMN16,
CUSTOM_COLUMN17,
CUSTOM_COLUMN18,
CUSTOM_COLUMN19,
CUSTOM_COLUMN20,
CUSTOM_COLUMN21,
CUSTOM_COLUMN22,
CUSTOM_COLUMN23,
CUSTOM_COLUMN24,
CUSTOM_COLUMN25,
RANK
       from ams_list_entries@'||l_dblink||'  '||
       'where   list_header_id = ' ||to_char(p_list_header_id);
--       ||' and rownum between '||to_char(l_start_rownum)||' and '||to_char(l_end_rownum);
 l_no_of_chunks := 0;
 l_no_of_chunks  := ceil(length(l_insert_sql)/2000 );
 write_to_act_log('Insert statement formed for migrating the list is..','LIST',p_list_header_id,'LOW');
 for i in 1 ..l_no_of_chunks
 loop
      Ams_Utility_Pvt.Write_Conc_log('l_insert_sql = '||substrb(l_insert_sql,(2000*i) - 1999,2000));
 end loop;
 execute immediate l_insert_sql;
 commit;
/*
      l_start_rownum := l_start_rownum + 10000;
      l_end_rownum   := l_end_rownum   + 10000;
    END LOOP;
*/
 Ams_Utility_Pvt.Write_Conc_log('End migrate_lists : '||to_char(p_list_header_id));
         SELECT user_status_id into l_user_status_id FROM ams_user_statuses_vl
         WHERE system_status_type = 'AMS_LIST_STATUS' AND
         system_status_code = 'AVAILABLE' and default_flag = 'Y';
         UPDATE ams_list_headers_all
         set status_code      = 'AVAILABLE',
            user_status_id    =  l_user_status_id,
            migration_date = sysdate
         where list_header_id = p_list_header_id;
     write_to_act_log('List migrated to local instance. Updating list header details.','LIST',p_list_header_id,'HIGH');
     -- Added for cancel list gen as it prevents parallel update- Raghu
     -- of list headers when cancel button is pressed
     commit;

 Update_List_Dets(p_list_header_id,l_return_status);
 if nvl(l_return_status,'S') in ('E','U') then -- resulted in error.
    write_to_act_log('Error while updating list header details.', 'LIST', g_list_header_id,'HIGH');
 end if;

 Ams_Utility_Pvt.Write_Conc_log('After Update_List_Dets call : ');

  IF(l_return_status <>FND_API.G_RET_STS_SUCCESS )THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
        UPDATE ams_list_headers_all
        SET    last_generation_success_flag = 'N',
               status_code                  = 'FAILED',
               user_status_id               = 311,
               last_update_date             = sysdate,
               status_date                  = sysdate,
               main_gen_end_time            = sysdate
        WHERE  list_header_id               = p_list_header_id;
   write_to_act_log('Error while migrating list from remote instance. '||sqlcode||'   '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     -- Added for cancel list gen as it prevents parallel update- Raghu
     -- of list headers when cancel button is pressed
     commit;

     Ams_Utility_Pvt.Write_Conc_log('Exception in migrate_lists : '||SQLERRM);
  --  errbuf:= substr(SQLERRM,1,254);
  --  retcode:= 2;
   raise;
end migrate_lists;
-- --------------------------------------------
PROCEDURE migrate_word_replacements(
                            Errbuf          OUT NOCOPY     VARCHAR2,
                            Retcode         OUT NOCOPY     VARCHAR2,
                            dblink          VARCHAR2
                            ) IS

l_insert_sql   varchar2(32767);
l_delete_sql   varchar2(32767);
begin
Ams_Utility_Pvt.Write_Conc_log('Start migrate_word_replacements : ');
l_delete_sql := 'Delete from AMS_HZ_WORD_REPLACEMENTS@'||dblink;
l_insert_sql := 'Insert into AMS_HZ_WORD_REPLACEMENTS@'||dblink||' (
			ORIGINAL_WORD,
			REPLACEMENT_WORD,
			TYPE,
			COUNTRY_CODE,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15,
			WORD_LIST_ID,
			OBJECT_VERSION_NUMBER
		)
		 SELECT
                        ORIGINAL_WORD,
                        REPLACEMENT_WORD,
                        TYPE,
                        COUNTRY_CODE,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        WORD_LIST_ID,
                        OBJECT_VERSION_NUMBER
                FROM  	HZ_WORD_REPLACEMENTS ';
Ams_Utility_Pvt.Write_Conc_log('l_delete_sql =  '||l_delete_sql);
	execute immediate l_delete_sql;
	commit;
Ams_Utility_Pvt.Write_Conc_log('l_insert_sql =  '||l_insert_sql);
	execute immediate l_insert_sql;
        commit;
Ams_Utility_Pvt.Write_Conc_log('End migrate_word_replacements : ');
EXCEPTION
  WHEN OTHERS THEN
   Ams_Utility_Pvt.Write_Conc_log('Exception in migrate_word_replacements : '||SQLERRM);
    errbuf:= substr(SQLERRM,1,254);
    retcode:= 2;
   raise;
end migrate_word_replacements;
-- --------------------------------------------------
PROCEDURE UPDATE_FOR_TRAFFIC_COP( p_list_header_id      in number ,
                                  p_list_entry_id       in t_number ) IS
l_return_status varchar2(1);
l_fatigued_records      number;
l_no_of_rows_active     number;

cursor c_count_list_entries(cur_p_list_header_id number) is
select sum(decode(enabled_flag,'Y',1,0)),
       sum(decode(marked_as_fatigued_flag,'Y',1,0))
from ams_list_entries
where list_header_id = cur_p_list_header_id ;


begin

             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'LIST',
              p_log_used_by_id  => p_list_header_id,
              p_msg_data        => 'UPDATE_FOR_TRAFFIC_COP : Started ',
              p_msg_type        => 'DEBUG');

  FORALL I in p_list_entry_id.first .. p_list_entry_id.last
     UPDATE ams_list_entries
     SET    ENABLED_FLAG            = 'N',
            MARKED_AS_FATIGUED_FLAG = 'Y'
    WHERE  list_entry_id = p_list_entry_id(i)
      AND  list_header_id = p_list_header_id ;

  open c_count_list_entries(p_list_header_id);
  fetch c_count_list_entries
   into l_no_of_rows_active            ,
        l_fatigued_records      ;
  close c_count_list_entries;

    UPDATE ams_list_headers_all
     SET    NO_OF_ROWS_FATIGUED = l_fatigued_records,
            NO_OF_ROWS_ACTIVE = l_no_of_rows_active
    WHERE  list_header_id = p_list_header_id ;
 -- Added for cancel list gen as it prevents parallel update- Raghu
 -- of list headers when cancel button is pressed
 commit;

             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'LIST',
              p_log_used_by_id  => p_list_header_id,
              p_msg_data        => 'UPDATE_FOR_TRAFFIC_COP : End ',
              p_msg_type        => 'DEBUG');

EXCEPTION
  WHEN OTHERS THEN
             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'LIST',
              p_log_used_by_id  => p_list_header_id,
              p_msg_data        => sqlerrm,
              p_msg_type        => 'DEBUG');

end UPDATE_FOR_TRAFFIC_COP;

-- --------------------------------------------------
-- **********************************************************************************************
PROCEDURE calc_selection_running_total
             (p_action_used_by_id  in  number,
              p_action_used_by     in  varchar2  ,-- DEFAULT 'LIST',
              p_log_flag           in  varchar2  ,-- DEFAULT 'Y',
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2) IS
l_request_id	number;
l_msg_count number := 0;

begin
  IF(p_log_flag ='Y')then
       write_to_act_log('Process calc_running_total : started', 'LIST', g_list_header_id,'LOW');
  END IF;
	l_request_id := FND_REQUEST.SUBMIT_REQUEST(
			application => 'AMS',
			program     => 'AMSLSRTC',
			argument1   => p_action_used_by_id);
		commit;
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT',  'request_id->'||l_request_id || '<-');
     FND_MSG_PUB.Add;
          --    FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
           --   FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
            --  FND_MSG_PUB.Add;
               FND_MSG_PUB.count_and_get(
                     p_encoded => FND_API.g_false,
                     p_count   => x_msg_count,
                     p_data    => x_msg_data  );
      x_return_status := 'S';
      x_msg_data := to_char(l_request_id);

           IF l_request_id = 0 THEN
              write_to_act_log('Unexpected Error for the program--concurrent program_id is '||to_char(l_request_id), 'LIST', g_list_header_id,'HIGH');


              FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
              FND_MESSAGE.Set_Token('TEXT', 'Error '|| sqlerrm||' '||sqlcode);
              FND_MSG_PUB.Add;
               FND_MSG_PUB.count_and_get(
                     p_encoded => FND_API.g_false,
                     p_count   => x_msg_count,
                     p_data    => x_msg_data
      );
      x_return_status := 'E';
              RAISE FND_API.g_exc_unexpected_error;
           end if;
end calc_selection_running_total;

-- ----------------------------------------------------------------------------
PROCEDURE calc_running_total (
              Errbuf               OUT NOCOPY     VARCHAR2,
              Retcode              OUT NOCOPY     VARCHAR2,
              p_action_used_by_id  in  number ) IS

  -- AMS_LIST_SELECT_ACTIONS Record for init record and complete record
  l_tmp_action_rec             ams_listaction_pvt.action_rec_type;
  p_action_rec                 ams_listaction_pvt.action_rec_type;
  l_list_select_action_id      number;
  l_running_total               number := 0;
   p_action_used_by  varchar2(30) := 'LIST';
   p_log_flag   	varchar2(1) := 'Y';
              x_return_status    varchar2(30);
              x_msg_count        number;
              x_msg_data         varchar2(4000);

  ----------------------------------------------------------------------------
  -- Cursor definition to select list_select_action_id.Will be used in loop to
  -- Process each cursor record according to order specified by the user
  ----------------------------------------------------------------------------
  CURSOR c_action_dets is
  SELECT list_select_action_id
    FROM ams_list_select_actions
   WHERE action_used_by_id   = p_action_used_by_id
     AND arc_action_used_by  = p_action_used_by
   ORDER by order_number;

  TYPE big_tbl_type is table of VARCHAR2(32767) index by BINARY_INTEGER;
  l_std_sql VARCHAR2(32767);
  l_include_sql VARCHAR2(32767);
  l_include_count number:=0;
  l_final_big_sql VARCHAR2(32767);
  l_include_sql_tbl  big_tbl_type ;
  l_std_sql_tbl  big_tbl_type ;
  l_join_string   varchar2(50);
l_no_of_chunks            number;
l_const_sql varchar2(4000) ;
  TYPE char_tbl_type is table of VARCHAR2(100) index by BINARY_INTEGER;
  TYPE num_tbl_type is table of number index by BINARY_INTEGER;
  l_rank_tbl      char_tbl_type;
  l_rank_num_tbl      num_tbl_type;
l_sorted   number;
l_update_sql  VARCHAR2(32767);
l_list_header_id number ;
cursor c1 is
select generation_type
from ams_list_headers_all
where list_header_id = l_list_header_id;
l_generation_type varchar2(60);
l_selection_results   t_number;
l_list_select_action   t_number;

l_delta			number := 0;
l_previous_incl_total	number := 0;
l_list_act_id		number;
l_ord_num		number;
l_r_totals		number;
cursor c_delta is
select list_select_action_id,order_number,running_total from ams_list_select_actions where
action_used_by_id = p_action_used_by_id and arc_action_used_by = 'LIST'
and list_action_type = 'INCLUDE' order by order_number;
l_last_generation_success_flag varchar2(1);

cursor c_last_gen is
select nvl(last_generation_success_flag,'N')
from  ams_list_headers_all
where list_header_id = p_action_used_by_id;

BEGIN
g_list_header_id := p_action_used_by_id;
Ams_Utility_Pvt.Write_Conc_log('Start calc_running_total : ');
   UPDATE ams_list_select_actions
      SET RUNNING_TOTAL = null, DELTA = null
   WHERE action_used_by_id   = p_action_used_by_id
     AND arc_action_used_by  = 'LIST';

  IF(p_log_flag ='Y')then
       write_to_act_log('Executing procedure calc_running_total', 'LIST', g_list_header_id,'LOW');
  END IF;
l_const_sql := ' minus '||
               ' select list_entry_source_system_id ' ||
               ' from ams_list_entries ' ||
               ' where list_header_id  = ' || p_action_used_by_id   ;
open c_last_gen;
fetch c_last_gen into l_last_generation_success_flag;
close c_last_gen;
if l_last_generation_success_flag = 'Y' then
        l_const_sql := NULL;
end if;

  OPEN c_action_dets;
  LOOP
    FETCH c_action_dets INTO l_list_select_action_id;
    EXIT WHEN c_action_dets%NOTFOUND;

    -------------------------------------------------------------------------
    -- Gets list select actions record details
    -- Intialize the record, set the list_select_action_id and get the
    -- details
    -------------------------------------------------------------------------
    ams_listaction_pvt.init_action_rec(l_tmp_action_rec);
    l_tmp_action_rec.list_select_action_id := l_list_select_action_id;
    ams_listaction_pvt.complete_action_rec
                       (p_action_rec      =>l_tmp_action_rec,
                        x_complete_rec    =>p_action_rec);

    ----------------------------------------------------------------------
    --validating that the first executed action has a type of "INCLUDE".--
    ----------------------------------------------------------------------
    IF (c_action_dets%ROWCOUNT = 1) THEN
       IF (p_action_rec.list_action_type <> 'INCLUDE')then
           write_to_act_log('Error. The action type of the first selection is NOT INCLUDE.', 'LIST', g_list_header_id,'HIGH');
           Ams_Utility_Pvt.Write_Conc_log('process list actions : first action INCLUDE check failed');
           FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_FIRST_INCLUDE');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
       END IF;  -- End of if for list_action_type check
    END IF; --End of Validation:- First Action Include Check


    ams_listaction_pvt.Validate_ListAction
    ( p_api_version            => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_validation_level       => JTF_PLSQL_API.G_VALID_LEVEL_RECORD,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_action_rec             => p_action_rec
    );

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

Ams_Utility_Pvt.Write_Conc_log('calc_selection_running_total : Dynamic ');
   /********************************************************************
      This dynamic procedure will process action for each object type
      If the object type is of CELL the process will be procecss_cell
      Using the same logic the procedure could be extended for new
      action types
   *********************************************************************/
      write_to_act_log('Calling AMS_ListGeneration_PKG.process_run_total_'||p_action_rec.arc_incl_object_from, 'LIST', g_list_header_id,'LOW');
      execute immediate
      'BEGIN
        AMS_ListGeneration_PKG.process_run_total_'||p_action_rec.arc_incl_object_from ||
         '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12) ;
      END;'
      using  p_action_used_by_id,
             p_action_rec.incl_object_id ,
             p_action_rec.list_action_type,
             p_action_rec.list_select_action_id,
             p_action_rec.order_number,
             p_action_rec.rank,
             'N',--CHECK p_action_rec.incl_control_group,
             OUT x_msg_data,
             OUT x_msg_count,
             in OUT x_return_status ,
             OUT l_std_sql ,
             OUT l_include_sql;
Ams_Utility_Pvt.Write_Conc_log('calc_selection_running_total : End Dynamic 001-> ');
      write_to_act_log('Executed AMS_ListGeneration_PKG.process_run_total_'||p_action_rec.arc_incl_object_from, 'LIST', g_list_header_id,'LOW');
     if p_action_rec.list_action_type  = 'INCLUDE' then
Ams_Utility_Pvt.Write_Conc_log('calc_selection_running_total include: '||to_char(l_include_count));
        l_include_count := l_include_count +1  ;
        l_include_sql_tbl(l_include_count) := l_include_sql ;
        l_std_sql_tbl(l_include_count)  := l_std_sql;
	l_list_select_action(l_include_count)  := l_list_select_action_id;
        l_rank_tbl(l_include_count)  :=  lpad(p_action_rec.rank,50,'0')
                         || lpad(p_action_rec.order_number,50,'0');
     else
       if p_action_rec.list_action_type  = 'EXCLUDE' then
          l_join_string := ' minus ';
       l_list_header_id := p_action_rec.action_used_by_id;
       else
          l_join_string := ' intersect ';
       l_list_header_id := p_action_rec.action_used_by_id;
     end if;
    Ams_Utility_Pvt.Write_Conc_log('process list actions noinclude: '||to_char(l_include_count));
   write_to_act_log('No of inclusions is ' || l_include_count, 'LIST', g_list_header_id,'LOW');
       FOR i IN 1 .. l_include_count
       loop
        l_std_sql_tbl(i)  :=
                               l_std_sql_tbl(i)   ||
                               l_join_string ||
                               l_std_sql;
     l_no_of_chunks  := ceil(length(l_std_sql_tbl(i))/2000 );
     for j in 1 ..l_no_of_chunks
     loop
        Ams_Utility_Pvt.Write_Conc_log('l_std_sql_tbl : '||substrb(l_std_sql_tbl(i),(2000*j) - 1999,2000));
        WRITE_TO_ACT_LOG(substrb(l_std_sql_tbl(i),(2000*j) - 1999,2000), 'LIST', g_list_header_id,'LOW');
     end loop;
    end loop;
  end if; -- if p_action_rec.list_action_type  = 'INCLUDE'


     IF(x_return_status <>FND_API.G_RET_STS_SUCCESS )THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
Ams_Utility_Pvt.Write_Conc_log('calc_selection_running_total : End Dynamic ');
-- end Of Dynamic Procedure
   l_join_string :='';
---------------------------------------------------------------------------
  END LOOP;  --  End loop c_action_dets
  CLOSE c_action_dets;
Ams_Utility_Pvt.Write_Conc_log('***************** '||to_char(l_include_count));

     WRITE_TO_ACT_LOG('Sorting according to rank', 'LIST', g_list_header_id,'LOW');

-- SOLIN, bug 3759988, use order_number, not rank for running total
       -- Sorting According to rank
--       FOR i IN 1 .. l_include_count
--       loop
--          l_rank_num_tbl(i) := i;
--          if i <> 1 then
--             for j in 1 .. i-1
--             loop
--Ams_Utility_Pvt.Write_Conc_log('***************** '||l_rank_tbl(i) || '*i*' || i);
--     WRITE_TO_ACT_LOG(l_rank_tbl(i) || '*i*' || i, 'LIST', g_list_header_id,'LOW');
--               if l_rank_tbl(i)  < l_rank_tbl(l_rank_num_tbl(j)) then
--                  for k in reverse j .. i-1
--                  loop
--                     l_rank_num_tbl(k+1) := l_rank_num_tbl(k);
--                  end loop;
--                  l_rank_num_tbl(j) := i;
--                  exit;
--               end if;
--             end loop;
--	  end if;
--       end loop;
-- SOLIN, end
  for  i in 1 .. l_include_count
  loop
        l_sorted := i; -- l_rank_num_tbl(i); SOLIN, bug 3759988
Ams_Utility_Pvt.Write_Conc_log('*****************SORTED '|| l_sorted ||' '||l_rank_tbl(i));
        l_final_big_sql := l_include_sql_tbl(l_sorted) ||
        l_std_sql_tbl(l_sorted) || l_const_sql || ')';
     WRITE_TO_ACT_LOG('Final SQL formed in calc_running_total proc', 'LIST', g_list_header_id,'LOW');
Ams_Utility_Pvt.Write_Conc_log('********calc_selection_running_total: FINAL SQL ************');
     l_no_of_chunks  := ceil(length(l_final_big_sql)/2000 );
     for i in 1 ..l_no_of_chunks
     loop
        WRITE_TO_ACT_LOG(substrb(l_final_big_sql,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
        Ams_Utility_Pvt.Write_Conc_log('l_final_big_sql :'||substrb(l_final_big_sql,(2000*i) - 1999,2000));
     end loop;
Ams_Utility_Pvt.Write_Conc_log('*******Process_list_actions: FINAL SQL END************');
  l_final_big_sql := 'BEGIN '||l_final_big_sql||' ; END;';
   EXECUTE IMMEDIATE l_final_big_sql using out l_selection_results(l_sorted);
Ams_Utility_Pvt.Write_Conc_log('*******l_list_select_action(l_sorted) = '||l_list_select_action(l_sorted));
Ams_Utility_Pvt.Write_Conc_log('*******l_selection_results(l_sorted) = '||l_selection_results(l_sorted));
   l_running_total := l_running_total + l_selection_results(l_sorted);
Ams_Utility_Pvt.Write_Conc_log('*******l_running_total = '||l_running_total);
   Update ams_list_select_actions set RUNNING_TOTAL = l_running_total
   Where LIST_SELECT_ACTION_ID = l_list_select_action(l_sorted)
      and arc_action_used_by = 'LIST';

  end loop;
 commit;

Ams_Utility_Pvt.Write_Conc_log('*******Delta Calculation*********');
Ams_Utility_Pvt.Write_Conc_log('*******p_action_used_by_id = '||p_action_used_by_id);
   open c_delta;
   loop
     fetch c_delta into l_list_act_id,l_ord_num,l_r_totals;
Ams_Utility_Pvt.Write_Conc_log('*******l_list_act_id = '||l_list_act_id);
Ams_Utility_Pvt.Write_Conc_log('*******l_ord_num = '||l_ord_num);
Ams_Utility_Pvt.Write_Conc_log('*******l_r_totals = '||l_r_totals);
     exit when c_delta%notfound;
     if l_ord_num = 1 then
        l_delta := 0;
Ams_Utility_Pvt.Write_Conc_log('l_ord_num = 1 *******l_delta = '||l_delta);
     end if;
     if l_ord_num > 1 then
        l_delta := l_r_totals - l_previous_incl_total;
Ams_Utility_Pvt.Write_Conc_log(' l_ord_num > 1 *******l_delta = '||l_delta);
     end if;
     Update ams_list_select_actions set delta = l_delta
     Where LIST_SELECT_ACTION_ID = l_list_act_id;
     l_delta := 0;
     l_previous_incl_total := l_r_totals;
Ams_Utility_Pvt.Write_Conc_log('*******l_previous_incl_total = '||l_previous_incl_total);
   end loop;
   close c_delta;
commit;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   write_to_act_log('Error while executing procedure calc_running_total '||sqlcode||'   '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     IF(c_action_dets%ISOPEN)THEN
        CLOSE c_action_dets;
     END IF;
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   write_to_act_log('Error while executing procedure calc_running_total '||sqlcode||'   '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     IF(c_action_dets%ISOPEN)THEN
        CLOSE c_action_dets;
     END IF;
Ams_Utility_Pvt.Write_Conc_log('Error: AMS_ListGeneration_PKG.Process_list_actions: '||sqlerrm||sqlcode);
     write_to_act_log('Error: AMS_ListGeneration_PKG.Process_list_actions:'
                      ||sqlerrm||sqlcode, 'LIST', g_list_header_id);
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
   write_to_act_log('Error while executing procedure calc_running_total '||sqlcode||'   '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     IF(c_action_dets%ISOPEN)THEN
        CLOSE c_action_dets;
     END IF;
Ams_Utility_Pvt.Write_Conc_log('Error: AMS_ListGeneration_PKG.Process_list_actions: '||sqlerrm||sqlcode);
     write_to_act_log('Error: AMS_ListGeneration_PKG.Process_list_actions:'
                       ||sqlerrm||sqlcode, 'LIST', g_list_header_id,'HIGH');
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END calc_running_total;

-- ----------------------------------------------------------

PROCEDURE process_run_total_imph
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              ) is
l_list_entry_source_type  varchar2(30);
cursor c_get_source_type
is select  decode(import_type,'B2C','PERSON_LIST','ORGANIZATION_CONTACT_LIST')
from ams_imp_list_headers_all
where  import_list_header_id = p_incl_object_id;
l_no_of_chunks  number;
BEGIN
    write_to_act_log('Executing procedure process_run_total_imph', 'LIST', g_list_header_id,'LOW');
    open  c_get_source_type ;
    fetch c_get_source_type into l_list_entry_source_type  ;
    close  c_get_source_type ;

    if p_list_action_type  = 'INCLUDE' then
       if   l_list_entry_source_type <> 'PERSON_LIST' then
       x_include_sql  := '
              select
              count(*) into :1
       from   ams_hz_b2b_mapping_v ail
            where  enabled_flag = '||''''||'Y'||''''||
             ' and import_list_header_id =' || p_incl_object_id   ||
             ' and nvl(party_id, import_source_line_id) in (' ;
      else
       x_include_sql  := '
            select
              count(*) :1
            from ams_hz_b2c_mapping_v
            where  enabled_flag = '||''''||'Y'||''''||
             ' and import_list_header_id =' || p_incl_object_id   ||
             ' and nvl(party_id, import_source_line_id) in (' ;
        end if;
   end if;
   l_no_of_chunks  := ceil(length(x_include_sql)/2000 );
   if l_no_of_chunks is not null then
      for i in 1 ..l_no_of_chunks
        loop
           WRITE_TO_ACT_LOG(substrb(x_include_sql,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
      end loop;
   end if;

   x_std_sql := ' select nvl(party_id,import_source_line_id)
                  from ams_imp_source_lines
                  where  import_list_header_id = ' ||   p_incl_object_id   ||
             '  and    nvl(duplicate_flag,' ||''''||'N'||''''||') = '||
                                              ''''||'N'||'''' ;
   WRITE_TO_ACT_LOG(x_std_sql, 'LIST', g_list_header_id,'LOW');
   write_to_act_log('Procedure process_run_total_imph executed', 'LIST', g_list_header_id,'LOW');
END process_run_total_imph ;


-- ----------------------------------------------------------------------------
PROCEDURE process_run_total_list
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              ) is
l_no_of_chunks  number;
BEGIN
    write_to_act_log('Executing procedure process_run_total_list', 'LIST', g_list_header_id,'LOW');
    if p_list_action_type  = 'INCLUDE' then
       x_include_sql := '
                   select
              count(*) into :1
       from ams_list_entries
       where   list_header_id = ' ||   p_incl_object_id   ||
        '  and    nvl(enabled_flag,' ||''''||'N'||''''||') = '||
                                              ''''||'Y'||'''' ||
       ' and list_entry_source_system_id in (' ;

   l_no_of_chunks  := ceil(length(x_include_sql)/2000 );
   for i in 1 ..l_no_of_chunks
     loop
        WRITE_TO_ACT_LOG(substrb(x_include_sql,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
   end loop;
   end if;

   x_std_sql := ' select list_entry_source_system_id
                     from ams_list_entries
                     where   list_header_id = ' ||   p_incl_object_id   ||
                     ' and     enabled_flag = ' || ''''||'Y' || '''' ;
        --WRITE_TO_ACT_LOG('std nclude ');
   WRITE_TO_ACT_LOG(x_std_sql, 'LIST', g_list_header_id,'LOW');
   write_to_act_log('Procedure process_run_total_list executed', 'LIST', g_list_header_id,'LOW');
END process_run_total_list ;
-- ----------------------------------------------------------------------------------
PROCEDURE form_rt_sql_statement(p_select_statement in varchar2,
                             p_select_add_statement in varchar2,
                             p_master_type        in varchar2,
                             p_child_types     in child_type,
                             p_from_string in sql_string_4K,
                             p_action_used_by_id  in number,
                             p_list_select_action_id  in number,
                             p_list_action_type  in varchar2,
                             p_order_number in number,
                             p_rank  in number,
                             x_final_string OUT NOCOPY varchar2
                             ) is
-- child_type      IS TABLE OF VARCHAR2(80) INDEX  BY BINARY_INTEGER;
l_data_source_types varchar2(2000);
l_field_col_tbl JTF_VARCHAR2_TABLE_100;
l_source_col_tbl JTF_VARCHAR2_TABLE_100;
l_view_tbl JTF_VARCHAR2_TABLE_100;
l_source_col_dt_tbl JTF_VARCHAR2_TABLE_100;
cursor c_master_source_type is
select source_object_name , source_object_name || '.' || source_object_pk_field
from ams_list_src_types
where source_type_code = p_master_type;
cursor c_child_source_type (l_child_src_type varchar2 )is
select a.source_object_name ,
       a.source_object_name || '.' || b.sub_source_type_pk_column
       ,b.master_source_type_pk_column
from ams_list_src_types  a, ams_list_src_type_assocs b
where a.source_type_code = l_child_src_type
and   b.sub_source_type_id = a.list_source_type_id;
l_count                   number;
l_master_object_name      varchar2(4000);
l_child_object_name       varchar2(4000);
l_master_primary_key      varchar2(1000);
l_child_primary_key       varchar2(32767);
l_from_clause             varchar2(32767);
l_where_clause            varchar2(32767);
l_select_clause           varchar2(32767);
l_insert_clause           varchar2(32767);
l_final_sql               varchar2(32767);
l_insert_sql              varchar2(32767);
l_no_of_chunks            number;
l_master_fkey             Varchar2(1000);
l_dummy_primary_key      varchar2(1000);
begin
    write_to_act_log('Executing procedure form_rt_sql_statement', 'LIST', g_list_header_id,'LOW');
    WRITE_TO_ACT_LOG('master type is ' || p_master_type, 'LIST', g_list_header_id,'LOW');
open  c_master_source_type;
fetch c_master_source_type into l_master_object_name , l_master_primary_key;
close c_master_source_type;
    WRITE_TO_ACT_LOG('master object name is ' || l_master_object_name||' , master primary key is '||l_master_primary_key, 'LIST', g_list_header_id,'LOW');
l_from_clause :=  ' FROM ' || l_master_object_name;
l_data_source_types := ' ('|| ''''|| p_master_type ||'''';
l_where_clause := 'where 1 = 1 ';

l_count  := p_child_types.count();
if l_count > 0  then
   for i in 1..p_child_types.last
   loop
      l_data_source_types := l_data_source_types || ','|| ''''
                             || p_child_types(i)||'''' ;
      open  c_child_source_type(p_child_types(i));
      fetch c_child_source_type into l_child_object_name , l_child_primary_key
                                     ,l_master_fkey;
      l_dummy_primary_key := '';
      if l_master_fkey is not null then
         l_dummy_primary_key     := l_master_object_name || '.'|| l_master_fkey;
      else
         l_dummy_primary_key      := l_master_primary_key;
      end if;
      l_from_clause := l_from_clause || ','|| l_child_object_name ;
      l_where_clause := l_where_clause || 'and '
                              ||l_dummy_primary_key || ' = '
                        || l_child_primary_key || '(+)';
      close c_child_source_type;
   end loop;
end if;
l_data_source_types := l_data_source_types || ') ' ;

 EXECUTE IMMEDIATE
     'BEGIN
      SELECT b.field_column_name ,
               c.source_object_name,
               b.source_column_name,
               b.field_data_type
        BULK COLLECT INTO :1 ,:2  ,:3 ,:4
        FROM ams_list_src_fields b, ams_list_src_types c
        WHERE b.list_source_type_id = c.list_source_type_id
          and b.DE_LIST_SOURCE_TYPE_CODE IN  '|| l_data_source_types ||
          ' AND b.ROWID >= (SELECT MAX(a.ROWID)
                            FROM ams_list_src_fields a
                           WHERE a.field_column_name= b.field_column_name
	                    AND  a.DE_LIST_SOURCE_TYPE_CODE IN '
                                 || l_data_source_types || ') ;
      END; '
  USING OUT l_field_col_tbl ,OUT l_view_tbl , OUT l_source_col_tbl,OUT l_source_col_dt_tbl ;
  --WRITE_TO_ACT_LOG('imp: p_select_statement' || p_select_statement);
  --WRITE_TO_ACT_LOG('imp: p_select_add_statement' || p_select_add_statement);
  --WRITE_TO_ACT_LOG('imp: select clause ' || l_select_clause);
for i in 1 .. l_field_col_tbl.last
loop
  l_insert_clause  := l_insert_clause || ' ,' || l_field_col_tbl(i) ;
    if l_source_col_dt_tbl(i) = 'DATE' then
     l_select_clause  := l_select_clause || ' ,' ||
                      'to_char('||l_view_tbl(i) || '.'||l_source_col_tbl(i)||','||''''||'DD-MM-RRRR'||''''||')' ;
     else
      l_select_clause  := l_select_clause || ' ,' ||
                      l_view_tbl(i) || '.'||l_source_col_tbl(i) ;
    end if;
  --WRITE_TO_ACT_LOG('imp: select clause'||i||':->' || l_select_clause);
end loop;
--  WRITE_TO_ACT_LOG('form_sql_statement:before insert_sql ', 'LIST', g_list_header_id);
  l_insert_sql := 'select count(*) into :1 ';
   --insert into test3 values (6,'l_insert_sql = :'||l_insert_sql);
  --commit;
   --insert into test3 values (7,'l_from_clause = :'||l_from_clause);
  --commit;
     --insert into test3 values (8,'l_where_clause = :'||l_where_clause);
  --commit;
  --WRITE_TO_ACT_LOG('form_rt_sql_statement:before final sql ', 'LIST', g_list_header_id);
     l_final_sql := l_insert_sql || '  ' ||
                  l_from_clause ||  '  '||
                  l_where_clause   || ' and  ' ||
                   l_master_primary_key|| ' in  ( ' ;
     x_final_string := l_final_sql;
  WRITE_TO_ACT_LOG('Final SQL formed in form_rt_sql_statement', 'LIST', g_list_header_id,'LOW');
     l_no_of_chunks  := ceil(length(l_final_sql)/2000 );
     for i in 1 ..l_no_of_chunks
     loop
        WRITE_TO_ACT_LOG(substrb(l_final_sql,(2000*i) - 1999,2000), 'LIST', g_list_header_id,'LOW');
     end loop;
     write_to_act_log('Procedure form_rt_sql_statement executed', 'LIST', g_list_header_id,'LOW');
exception
   when others then
     write_to_act_log('Error while executing procedure form_rt_sql_statement '||sqlcode||'   '||sqlerrm , 'LIST', g_list_header_id,'HIGH');
end form_rt_sql_statement;

-- ----------------------------------------------------------------------------------
PROCEDURE process_rt_insert_sql(p_select_statement in varchar2,
                             p_select_add_statement in varchar2,
                             p_master_type        in varchar2,
                             p_child_types     in child_type,
                             p_from_string in sql_string_4K ,
                             p_action_used_by_id  in number,
                             p_list_select_action_id  in number,
                             p_list_action_type  in varchar2,
                             p_order_number in number,
                             p_rank  in number,
                             x_std_sql OUT NOCOPY varchar2 ,
                             x_include_sql OUT NOCOPY varchar2
                             ) is
l_final_sql   varchar2(32767);
l_insert_sql varchar2(32767);
l_insert_sql1 varchar2(32767);
l_table_name  varchar2(80) := ' ams_list_tmp_entries ';
BEGIN
  write_to_act_log('Execution of procedure process_rt_insert_sql started', 'LIST', g_list_header_id,'LOW');

  l_insert_sql := p_select_statement ;
  for i in 1 .. p_from_string.last
  loop
--     write_to_act_log(p_from_string(i), 'LIST', g_list_header_id);
    l_insert_sql  := l_insert_sql || p_from_string(i);
  end loop;
  x_std_sql := l_insert_sql;
  if p_list_action_type = 'INCLUDE' then
          form_rt_sql_statement(p_select_statement ,
                             p_select_add_statement ,
                             p_master_type        ,
                             p_child_types     ,
                             p_from_string ,
                             p_action_used_by_id  ,
                             p_list_select_action_id  ,
                             p_list_action_type  ,
                             p_order_number ,
                             p_rank  ,
                             l_final_sql
                             ) ;
  end if;
  x_include_sql := l_final_sql;

   write_to_act_log('Procedure process_rt_insert_sql executed', 'LIST', g_list_header_id,'LOW');
exception
   when others then
   write_to_act_log('Error while executing process_rt_insert_sql '||sqlcode||'  '||sqlerrm , 'LIST', g_list_header_id,'HIGH');
END process_rt_insert_sql;

-- ----------------------------------------------------------------------------------
PROCEDURE process_rt_all_sql  (p_action_used_by_id in number,
                            p_incl_object_id in number,
                            p_list_action_type  in varchar2,
                            p_list_select_action_id   in number,
                            p_order_number   in number,
                            p_rank   in number,
                            p_include_control_group  in varchar2,
                            p_sql_string    in sql_string,
                            p_primary_key   in  varchar2,
                            p_source_object_name in  varchar2,
                            x_msg_count      OUT NOCOPY number,
                            x_msg_data       OUT NOCOPY varchar2,
                            x_return_status  IN OUT NOCOPY VARCHAR2,
                            x_std_sql OUT NOCOPY varchar2 ,
                            x_include_sql OUT NOCOPY varchar2
                            ) is
l_sql_string         sql_string;
l_where_string       sql_string;
-- l_from_string       sql_string;
l_from_string       sql_string_4K;
l_counter            NUMBER := 1;
l_from_position      number;
l_from_counter       number;
l_end_position      number;
l_end_counter       number;
l_order_position      number;
l_order_counter       number;
l_group_position      number;
l_group_counter       number;
l_found              varchar2(1) := 'N';
l_master_type        varchar2(80);
l_master_type_id     number;
l_source_object_name  varchar2(80);
l_source_object_pk_field  varchar2(80);
l_child_types        child_type;
l_select_condition    varchar2(2000);
l_select_add_condition    varchar2(2000);
l_sql_string_v2           varchar2(4000);
BEGIN
  /* Validate Sql String will take all the sql statement fragement and
     check if the search string is present. If it is present it will
     return the position of fragement and the counter
  */
  write_to_act_log('Execution of procedure process_rt_all_sql started', 'LIST', g_list_header_id,'LOW');

  l_sql_string := p_sql_string;

  --write_to_act_log('Process_rt_all_sql: start ');
  l_found  := 'N';
  validate_sql_string(p_sql_string => l_sql_string ,
                      p_search_string => 'FROM',
                      p_comma_valid   => 'N',
                      x_found    => l_found,
                      x_position =>l_from_position,
                      x_counter => l_from_counter) ;

--  write_to_act_log('Process_rt_all_sql l_found : '||l_found,'LIST', g_list_header_id);
--  write_to_act_log('Process_rt_all_sql return status: After validate_sql_string call  ','LIST', g_list_header_id);
  if l_found = 'N' then
     FND_MESSAGE.set_name('AMS', 'AMS_LIST_FROM_NOT_FOUND');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  end if;
/*     write_to_act_log('Process_rt_all_sql: FROM Position ->'|| l_from_position ||
                                   '<--FROM Counter ->' || l_from_counter ||
                                   '<--FROM Found ->' || l_found, 'LIST', g_list_header_id);*/
  l_found  := 'N';
  get_master_types (p_sql_string => l_sql_string,
                    p_start_length => 1,
                    p_start_counter => 1,
                    p_end_length => l_from_position,
                    p_end_counter => l_from_counter,
                    x_master_type_id=> l_master_type_id,
                    x_master_type=> l_master_type,
                    x_found=> l_found,
                    x_source_object_name => l_source_object_name,
                    x_source_object_pk_field  => l_source_object_pk_field);

  if l_found = 'N' then
     FND_MESSAGE.set_name('AMS', 'AMS_LIST_NO_MASTER_TYPE');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  end if;
  write_to_act_log('Master type is '|| l_master_type ||'<--'  , 'LIST', g_list_header_id,'LOW');

  l_found  := 'N';
  write_to_act_log('Calling procedure get_condition'  , 'LIST', g_list_header_id,'LOW');

  get_condition(p_sql_string => l_sql_string ,
                p_search_string => 'FROM',
                p_comma_valid   => 'N',
                x_position =>l_from_position,
                x_counter => l_from_counter,
                x_found    => l_found,
                x_sql_string => l_from_string) ;

  /* FOR SQL STATEMENTS  WHICH ARE NOT FROM THE DERIVING MASTER SOURCE TABLE  */
  if p_primary_key is not null then
     l_source_object_pk_field := p_primary_key;
     l_source_object_name     := p_source_object_name ;
  end if;
  l_select_condition := 'SELECT ' ||l_source_object_name||'.'
                        ||l_source_object_pk_field;
                        --||'||'||''''
                        --||l_master_type||'''';
  l_select_add_condition := ','||l_source_object_name||'.'
                        ||l_source_object_pk_field||','||''''
                        ||l_master_type||'''' ;

   write_to_act_log('Calling procedure process_rt_insert_sql'  , 'LIST', g_list_header_id,'LOW');
   process_rt_insert_sql(p_select_statement       => l_select_condition,
                      p_select_add_statement   => l_select_add_condition,
                      p_master_type            => l_master_type,
                      p_child_types            => l_child_types,
                      p_from_string            => l_from_string  ,
                      p_list_select_action_id  => p_list_select_action_id  ,
                      p_action_used_by_id      => p_action_used_by_id ,
                      p_list_action_type       => p_list_action_type ,
                      p_order_number           => p_order_number,
                      p_rank                   => p_rank,
                      x_std_sql                => x_std_sql,
                      x_include_sql            => x_include_sql
                      );

   write_to_act_log('Procedure process_rt_all_sql executed ', 'LIST', g_list_header_id ,'LOW');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     write_to_act_log('Error when executing procedure process_rt_all_sql '||sqlcode||'  '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     write_to_act_log('Error when executing procedure process_rt_all_sql '||sqlcode||'  '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

  WHEN OTHERS THEN
     write_to_act_log('Error when executing procedure process_rt_all_sql '||sqlcode||'  '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


END process_rt_all_sql;

-- ----------------------------------------------------------------------------------


PROCEDURE process_run_total_sql (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              ) is

------------------------------------------------------------------------------
-- Given the sql id from ams_list_select_actions it will retrieve the
-- sql_srtings from ams_discoverer_sql for a particular worksheet_name and
-- workbook_name.
------------------------------------------------------------------------------
cursor cur_sql  is
SELECT query, primary_key, source_object_name
FROM   ams_list_queries_all
WHERE  (list_query_id = p_incl_object_id )
or (parent_list_query_id = p_incl_object_id )
order by sequence_order;

/* sql_string column is obsolete: bug 4604653
cursor cur_old_sql  is
SELECT sql_string, primary_key, source_object_name
FROM   ams_list_queries_all
WHERE  (list_query_id = p_incl_object_id )
or (parent_list_query_id = p_incl_object_id )
order by sequence_order;
*/

cursor cur_primary_key_sql  is
SELECT lc.SOURCE_OBJECT_NAME, lc.SOURCE_OBJECT_PK_FIELD
FROM   ams_list_queries_all  lq,
       ams_list_headers_all lh,
       ams_list_src_types  lc
WHERE lq.list_query_id = p_incl_object_id
and   lq.ARC_ACT_LIST_QUERY_USED_BY = 'LIST'
and   lq.ACT_LIST_QUERY_USED_BY_ID = lh.list_header_id
and   lc.source_type_code = lh.list_source_type;

l_sql_string         sql_string;
l_where_string       sql_string;
l_from_string       sql_string;
l_counter            NUMBER := 1;
l_from_position      number;
l_from_counter       number;
l_end_position      number;
l_end_counter       number;
l_order_position      number;
l_order_counter       number;
l_group_position      number;
l_group_counter       number;
l_found              varchar2(1);
l_master_type        varchar2(80);
l_master_type_id     number;
l_source_object_name  varchar2(80);
l_source_object_pk_field  varchar2(80);
l_child_types        child_type;
l_select_condition    varchar2(2000);
l_select_add_condition    varchar2(2000);
l_sql_string_v2           varchar2(4000);
l_primary_key          varchar2(80);
l_no_pieces            number :=0;
l_big_sql VARCHAR2(32767);
BEGIN
  write_to_act_log('Procedure process_run_total_sql started ', 'LIST', g_list_header_id ,'LOW');
  open cur_sql;
  loop
    fetch cur_sql into l_big_sql,l_primary_key,l_source_object_name;
    exit when cur_sql%notfound ;
    write_to_act_log('Incl object id' || p_incl_object_id, 'LIST', g_list_header_id,'LOW');
    l_no_pieces := ceil(length(l_big_sql)/2000);
    write_to_act_log('length of SQL' || l_no_pieces, 'LIST', g_list_header_id,'LOW');
    if l_no_pieces  > 0 then
       for i  in 1 .. l_no_pieces
       loop
          write_to_act_log('number of chunks ' || i, 'LIST', g_list_header_id,'LOW');
          --write_to_act_log('Process_sql: before ' );
          l_sql_string(l_counter):= substrb(l_big_sql,2000*i -1999,2000);
          --write_to_act_log('Process_sql:' || l_sql_string(l_counter));
          l_counter  := l_counter +1 ;
       end loop;
    end if;
    -- l_sql_string(l_counter):= substrb(l_sql_string_v2,2001,2000);
    -- l_counter  := l_counter +1 ;
  end loop;
  close cur_sql;

--    write_to_act_log('lenth of pieces:' || l_no_pieces, 'LIST', g_list_header_id);
/*
  if l_no_pieces = 0   or
     l_no_pieces is null then
     open cur_old_sql;
     loop
       fetch cur_old_sql into l_sql_string_v2,l_primary_key,l_source_object_name;
  --     write_to_act_log('Process_sql old cursor 4000->:' || p_incl_object_id, 'LIST', g_list_header_id);
       exit when cur_old_sql%notfound ;
       --write_to_act_log('Process_sql: before ' );
       l_sql_string(l_counter):= substrb(l_sql_string_v2,1,2000);
       --write_to_act_log('Process_sql:' || l_sql_string(l_counter));
       l_counter  := l_counter +1 ;
       l_sql_string(l_counter):= substrb(l_sql_string_v2,2001,2000);
       l_counter  := l_counter +1 ;
     end loop;
     close cur_old_sql;
  end if;
  */
  if l_source_object_name is null or
     l_primary_key is null then
     open cur_primary_key_sql  ;
     loop
       fetch cur_primary_key_sql into l_primary_key,l_source_object_name;
       exit when cur_primary_key_sql%notfound ;
     end loop;
     close cur_primary_key_sql  ;
  end if;
  write_to_act_log('Calling procedure process_rt_all_sql', 'LIST', g_list_header_id,'LOW');
  process_rt_all_sql(p_action_used_by_id => p_action_used_by_id ,
                  p_incl_object_id => p_incl_object_id ,
                  p_list_action_type  => p_list_action_type  ,
                  p_list_select_action_id   => p_list_select_action_id   ,
                  p_order_number   => p_order_number   ,
                  p_rank   => p_rank   ,
                  p_include_control_group  => p_include_control_group,
                  p_sql_string    => l_sql_string    ,
                  p_primary_key   => l_primary_key,
                  p_source_object_name   => l_source_object_name,
                  x_msg_count      => x_msg_count      ,
                  x_msg_data   => x_msg_data   ,
                  x_return_status   => x_return_status   ,
                  x_std_sql                => x_std_sql,
                  x_include_sql            => x_include_sql
                  );
  write_to_act_log('Procedure process_run_total_sql executed', 'LIST', g_list_header_id,'LOW'  );

exception
   when others then
    write_to_act_log('Error while executing process_run_total_sql ' ||sqlcode||'   '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
    x_return_status := FND_API.G_RET_STS_ERROR ;
END process_run_total_sql;

-- ----------------------------------------------------------------------------------------------
PROCEDURE process_run_total_cell
             (p_action_used_by_id in  number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
               ) is

------------------------------------------------------------------------------
-- Given the sql id from ams_list_select_actions it will retrieve the
-- sql_srtings from ams_discoverer_sql for a particular worksheet_name and
-- workbook_name.
------------------------------------------------------------------------------
l_sql_string         sql_string;
l_where_string       sql_string;
l_from_string       sql_string;
l_counter            NUMBER := 1;
l_from_position      number;
l_from_counter       number;
l_end_position      number;
l_end_counter       number;
l_order_position      number;
l_order_counter       number;
l_group_position      number;
l_group_counter       number;
l_found              varchar2(1);
l_master_type        varchar2(80);
l_master_type_id     number;
l_source_object_name  varchar2(80);
l_source_object_pk_field  varchar2(80);
l_child_types        child_type;
l_select_condition    varchar2(2000);
l_select_add_condition    varchar2(2000);
l_msg_data       VARCHAR2(2000);
l_msg_count      number;
l_sql_2          DBMS_SQL.VARCHAR2S;
l_sql_string_final    varchar2(4000);
j number     := 1;
BEGIN

  write_to_act_log('Executing procedure process_run_total_cell', 'LIST', g_list_header_id,'LOW'  );
  ams_cell_pvt.get_comp_sql(
      p_api_version       => 1.0,
      p_init_msg_list     => FND_API.g_false,
      p_validation_level  => FND_API.g_valid_level_full,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count ,
      x_msg_data           =>x_msg_data,
      p_cell_id           => p_incl_object_id ,
      p_party_id_only     => FND_API.g_false,
      x_sql_tbl           => l_sql_2
   );
    write_to_act_log('AMS_ListGeneration_PKG.After Comp sql:', 'LIST', g_list_header_id,'LOW');

  l_sql_string_final := '';
  for i in 1 .. l_sql_2.last
  loop
      l_sql_string_final := l_sql_string_final || l_sql_2(i);
     if length(l_sql_string_final) > 2000 then
        l_sql_string(j) := substrb(l_sql_string_final,1,2000);
        l_sql_string_final := substrb(l_sql_string_final,2001 ,2000);
        j := j+1;
     end if;
  end loop;
  l_sql_string(j) := substrb(l_sql_string_final,1,2000);
  if length(l_sql_string_final) > 2000 then
    j := j+1;
    l_sql_string(j) := substrb(l_sql_string_final,2001 ,2000);
  end if;
  write_to_act_log('process_rt_all_sql', 'LIST', g_list_header_id,'LOW');

  process_rt_all_sql(p_action_used_by_id => p_action_used_by_id ,
                  p_incl_object_id => p_incl_object_id ,
                  p_list_action_type  => p_list_action_type  ,
                  p_list_select_action_id   => p_list_select_action_id   ,
                  p_order_number   => p_order_number   ,
                  p_rank   => p_rank   ,
                  p_include_control_group  => p_include_control_group,
                  p_sql_string    => l_sql_string    ,
                  x_msg_count      => x_msg_count      ,
                  x_msg_data   => x_msg_data   ,
                  x_return_status   => x_return_status   ,
                  x_std_sql                => x_std_sql,
                  x_include_sql            => x_include_sql,
                  p_primary_key   => null,
                  p_source_object_name => null);

    write_to_act_log('Procedure process_run_total_cell executed.', 'LIST', g_list_header_id,'LOW');
--No exception??? need to include one..

END process_run_total_cell ;

-- -----------------------------------------------------------------------------------------------
PROCEDURE process_run_total_diwb (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              ) is

------------------------------------------------------------------------------
-- Given the sql id from ams_list_select_actions it will retrieve the
-- sql_srtings from ams_discoverer_sql for a particular worksheet_name and
-- workbook_name.
------------------------------------------------------------------------------
cursor cur_diwb(l_incl_object_id  in number )  is
SELECT sql_string
FROM   ams_discoverer_sql
WHERE  (workbook_name, worksheet_name )
IN
( SELECT workbook_name, worksheet_name
  FROM   ams_discoverer_sql
  WHERE  discoverer_sql_id = l_incl_object_id)
ORDER BY sequence_order;

l_sql_string         sql_string;
l_where_string       sql_string;
l_from_string       sql_string;
l_counter            NUMBER := 1;
l_from_position      number;
l_from_counter       number;
l_end_position      number;
l_end_counter       number;
l_order_position      number;
l_order_counter       number;
l_group_position      number;
l_group_counter       number;
l_found              varchar2(1);
l_master_type        varchar2(80);
l_master_type_id     number;
l_source_object_name  varchar2(80);
l_source_object_pk_field  varchar2(80);
l_child_types        child_type;
l_select_condition    varchar2(2000);
l_select_add_condition    varchar2(2000);
BEGIN
  write_to_act_log('Executing procedure process_run_total_diwb', 'LIST', g_list_header_id,'LOW');

  /* Populating l_sql_string with sql statements from ams_discoverer_sql
     l_sql_string is of table type of varchar2(2000)
  */
  open cur_diwb(p_incl_object_id);
  loop
    fetch cur_diwb into l_sql_string(l_counter);
    exit when cur_diwb%notfound ;
    l_counter  := l_counter +1 ;
  end loop;
  close cur_diwb;
  write_to_act_log('Calling procedure process_rt_all_sql','LIST', g_list_header_id,'LOW');
  process_rt_all_sql(p_action_used_by_id => p_action_used_by_id ,
                  p_incl_object_id => p_incl_object_id ,
                  p_list_action_type  => p_list_action_type  ,
                  p_list_select_action_id   => p_list_select_action_id   ,
                  p_order_number   => p_order_number   ,
                  p_rank   => p_rank   ,
                  p_include_control_group  => p_include_control_group,
                  p_sql_string    => l_sql_string,
		  p_primary_key   => null,
		  p_source_object_name => null,
                  x_msg_count      => x_msg_count      ,
                  x_msg_data   => x_msg_data   ,
                  x_return_status   => x_return_status   ,
                  x_std_sql                => x_std_sql,
                  x_include_sql            => x_include_sql);
    write_to_act_log('Procedure process_run_total_diwb executed','LIST', g_list_header_id,'LOW');
END process_run_total_diwb ;

-- ------------------------------------------------------------------------------------------------
PROCEDURE  tca_upload_process
             (p_list_header_id  in  number,
              p_log_flag           in  varchar2  ,-- DEFAULT 'Y',
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2) IS

l_list_entry_id		Number;
list_column_name	Varchar2(30);
tca_column_name		Varchar2(30);
l_string		Varchar2(2000);
l_entry_value		Varchar2(1000);
l_b2b_flag		Varchar2(6);
l_b2b			Varchar2(1);
l_party_id		Number;
l_component_name	Varchar2(30);
l_new_party		Varchar2(1);
x_tmp_var                       VARCHAR2(4000);
x_tmp_var1                      VARCHAR2(4000);

 party_rec       hz_party_v2pub.party_rec_type;
 org_rec         hz_party_v2pub.organization_rec_type;
 person_rec      hz_party_v2pub.person_rec_type;
 location_rec    hz_location_v2pub.location_rec_type;
 psite_rec       hz_party_site_v2pub.party_site_rec_type;
 psiteuse_rec    hz_party_site_v2pub.party_site_use_rec_type;
 cpoint_rec      hz_contact_point_v2pub.contact_point_rec_type;
 email_rec       hz_contact_point_v2pub.email_rec_type;
 phone_rec       hz_contact_point_v2pub.phone_rec_type;
 fax_rec         hz_contact_point_v2pub.phone_rec_type;
 ocon_rec        hz_party_contact_v2pub.org_contact_rec_type;
 edi_rec         hz_contact_point_v2pub.edi_rec_type;
 telex_rec       hz_contact_point_v2pub.telex_rec_type;
 web_rec         hz_contact_point_v2pub.web_rec_type;


cursor c_list_entries is
select list_entry_id from ams_list_entries where list_header_id = p_list_header_id
   -- and party_id is null
   and nvl(tca_load_status,'x') not in ('SUCCESS','ERROR')
   and enabled_flag = 'Y'; --bmuthukr. R12 Need to upload only the enabled entries.

cursor c_tca_columns is
select flds.field_column_name , tca.column_name
from ams_list_src_fields flds, AMS_DS_TCA_ENTITY_COLS tca,
      ams_list_headers_all hdr, ams_list_src_types typ
where hdr.list_header_id = p_list_header_id
  and hdr.LIST_SOURCE_TYPE = typ.SOURCE_TYPE_CODE
  and typ.list_source_type_id = flds.list_source_type_id
  and flds.enabled_flag = 'Y'
  and used_in_list_entries = 'Y'
  and flds.tca_column_id = tca.ENTITY_COLUMN_ID;

cursor c_data_type is
select source_category from ams_list_src_types types, ams_list_headers_all head
where head.list_header_id = p_list_header_id
and head.list_source_type = types.source_type_code;

l_prof VARCHAR2(50);

BEGIN
  write_to_act_log('Executing procedure tca_upload_process', 'LIST', p_list_header_id,'LOW');

  --TCA mandate: bug 4587049
  --Disable TCA events before bulk TCA data processing
  l_prof := fnd_profile.value('HZ_EXECUTE_API_CALLOUTS');
  if l_prof <> 'N' then
     fnd_profile.put('HZ_EXECUTE_API_CALLOUTS','N');
  end if;

  open c_data_type;
  fetch c_data_type into l_b2b_flag;
  close c_data_type;
  write_to_act_log('Source category is '||l_b2b_flag, 'LIST', p_list_header_id,'LOW');
  open c_list_entries;
  LOOP
     fetch c_list_entries into l_list_entry_id;
     Exit when c_list_entries%notfound;
     open c_tca_columns;
     loop
       fetch c_tca_columns into list_column_name, tca_column_name;
       exit when c_tca_columns%notfound;
       l_string := 'begin select '||list_column_name||' into :l_entry_value from ams_list_entries where
                    list_entry_id = '||to_char(l_list_entry_id)||' ; end;';
 -- DBMS_OUTPUT.PUT_LINE('l_string  = '||l_string);
	execute immediate l_string using out l_entry_value;
  -- DBMS_OUTPUT.PUT_LINE('l_entry_value = '||l_entry_value);
    if l_b2b_flag = 'B2B' then
	l_b2b := 'Y';
       if tca_column_name = 'PARTY_NAME' then
	 org_rec.organization_name := l_entry_value;
  -- DBMS_OUTPUT.PUT_LINE('org_rec.organization_name = '||org_rec.organization_name);
       end if;
       if tca_column_name = 'FISCAL_YEAREND_MONTH' then
           org_rec.fiscal_yearend_month := l_entry_value;
       elsif tca_column_name = 'DUNS_NUMBER_C' then
           org_rec.duns_number_c := l_entry_value;
       elsif tca_column_name = 'EMPLOYEES_TOTAL' then
           org_rec.employees_total := l_entry_value;
       elsif tca_column_name = 'LINE_OF_BUSINESS' then
           org_rec.line_of_business := l_entry_value;
       elsif tca_column_name = 'YEAR-ESTABLISHED' then
           org_rec.year_established := l_entry_value;
       elsif tca_column_name = 'TAX_REFERENCE' then
           org_rec.tax_reference := l_entry_value;
       elsif tca_column_name = 'CEO_NAME' then
           org_rec.ceo_name := l_entry_value;
       elsif tca_column_name = 'PERSON_FIRST_NAME' then
           person_rec.person_first_name := l_entry_value;
       elsif tca_column_name = 'PERSON_MIDDLE_NAME' then
           person_rec.person_middle_name := l_entry_value;
       elsif tca_column_name = 'PERSON_LAST_NAME' then
           person_rec.person_last_name := l_entry_value;
       elsif tca_column_name = 'PERSON_NAME_SUFFIX' then
           person_rec.person_name_suffix := l_entry_value;
       elsif tca_column_name = 'PERSON_PRE_NAME_ADJUNCT' then
           person_rec.person_pre_name_adjunct := l_entry_value;
       elsif tca_column_name = upper('country') then
           location_rec.country := l_entry_value;
       elsif tca_column_name = upper('address1') then
           location_rec.address1 := l_entry_value;
       elsif tca_column_name = upper('address2') then
           location_rec.address2 := l_entry_value;
       elsif tca_column_name = upper('city') then
           location_rec.city := l_entry_value;
       elsif tca_column_name = upper('county') then
           location_rec.county := l_entry_value;
       elsif tca_column_name = upper('state') then
           location_rec.state := l_entry_value;
       elsif tca_column_name = upper('province') then
           location_rec.province := l_entry_value;
       elsif tca_column_name = upper('postal_code') then
           location_rec.postal_code := l_entry_value;
       elsif tca_column_name = upper('email_address') then
           email_rec.email_address := l_entry_value;
       elsif tca_column_name = upper('phone_country_code') then
           phone_rec.phone_country_code := l_entry_value;
       elsif tca_column_name = upper('phone_area_code') then
           phone_rec.phone_area_code := l_entry_value;
       elsif tca_column_name = upper('phone_number') then
           phone_rec.phone_number := l_entry_value;
       elsif tca_column_name = upper('phone_extension') then
           phone_rec.phone_extension := l_entry_value;
       elsif tca_column_name = upper('department') then
           ocon_rec.department := l_entry_value;
       elsif tca_column_name = upper('job_title') then
           ocon_rec.job_title := l_entry_value;
       elsif tca_column_name = upper('decision_maker_flag') then
           ocon_rec.decision_maker_flag := l_entry_value;
       elsif tca_column_name = upper('sic_code') then
           org_rec.sic_code := l_entry_value;
       elsif tca_column_name = upper('sic_code_type') then
           org_rec.sic_code_type := l_entry_value;
       elsif tca_column_name = upper('analysis_fy') then
           org_rec.analysis_fy := l_entry_value;
       elsif tca_column_name = upper('CURR_FY_POTENTIAL_REVENUE') then
           org_rec.CURR_FY_POTENTIAL_REVENUE := l_entry_value;
       elsif tca_column_name = upper('NEXT_FY_POTENTIAL_REVENUE') then
           org_rec.NEXT_FY_POTENTIAL_REVENUE := l_entry_value;
       elsif tca_column_name = upper('GSA_INDICATOR_FLAG') then
           org_rec.GSA_INDICATOR_FLAG := l_entry_value;
       elsif tca_column_name = upper('MISSION_STATEMENT') then
           org_rec.MISSION_STATEMENT := l_entry_value;
       elsif tca_column_name = upper('ORGANIZATION_NAME_PHONETIC') then
           org_rec.ORGANIZATION_NAME_PHONETIC := l_entry_value;
       elsif tca_column_name = upper('CATEGORY_CODE') then
           org_rec.party_rec.CATEGORY_CODE := l_entry_value;
       elsif tca_column_name = upper('JGZZ_FISCAL_CODE') then
           org_rec.JGZZ_FISCAL_CODE := l_entry_value;
       elsif tca_column_name = upper('ADDRESS3') then
           location_rec.ADDRESS3 := l_entry_value;
       elsif tca_column_name = upper('ADDRESS4') then
           location_rec.ADDRESS4 := l_entry_value;
       elsif tca_column_name = upper('ADDRESS_LINES_PHONETIC') then
           location_rec.ADDRESS_LINES_PHONETIC := l_entry_value;
       elsif tca_column_name = upper('PO_BOX_NUMBER') then
           -- location_rec.PO_BOX_NUMBER := l_entry_value; Refer bug 4704727
	   location_rec.PO_BOX_NUMBER := null;
       elsif tca_column_name = upper('HOUSE_NUMBER') then
           -- location_rec.HOUSE_NUMBER := l_entry_value; Refer bug 4704727
	   location_rec.HOUSE_NUMBER := null;
       elsif tca_column_name = upper('STREET_SUFFIX') then
           -- location_rec.STREET_SUFFIX := l_entry_value; Refer bug 4704727
	   location_rec.STREET_SUFFIX := null;
       elsif tca_column_name = upper('STREET') then
           -- location_rec.STREET := l_entry_value; Refer bug 4704727
	   location_rec.STREET := null;
       elsif tca_column_name = upper('STREET_NUMBER') then
	   -- location_rec.STREET_NUMBER := l_entry_value; Refer bug 4704727
	   location_rec.STREET_NUMBER := null;
       elsif tca_column_name = upper('FLOOR') then
           -- location_rec.FLOOR := l_entry_value; Refer bug 4704727
	   location_rec.FLOOR := null;
       elsif tca_column_name = upper('SUITE') then
           -- location_rec.SUITE := l_entry_value; Refer bug 4704727
	   location_rec.SUITE := null;
       elsif tca_column_name = upper('POSTAL_PLUS4_CODE') then
           location_rec.POSTAL_PLUS4_CODE := l_entry_value;
       elsif tca_column_name = upper('identifying_address_flag') then
           psite_rec.identifying_address_flag := l_entry_value;
       elsif tca_column_name = upper('address_effective_date') then
           location_rec.address_effective_date := l_entry_value;
       elsif tca_column_name = upper('address_expiration_date') then
           location_rec.address_expiration_date := l_entry_value;
       elsif tca_column_name = upper('branch_flag') then
           org_rec.branch_flag := l_entry_value;
       elsif tca_column_name = upper('line_of_business') then
           org_rec.line_of_business := l_entry_value;
       elsif tca_column_name = upper('business_scope') then
           org_rec.business_scope := l_entry_value;
       elsif tca_column_name = upper('ceo_title') then
           org_rec.ceo_title := l_entry_value;
       elsif tca_column_name = upper('cong_dist_code') then
           org_rec.cong_dist_code := l_entry_value;
       elsif tca_column_name = upper('control_yr') then
           org_rec.control_yr := l_entry_value;
       elsif tca_column_name = upper('corporation_class') then
           org_rec.corporation_class := l_entry_value;
       elsif tca_column_name = upper('credit_score') then
           org_rec.credit_score := l_entry_value;
       elsif tca_column_name = upper('credit_score_commentary') then
           org_rec.credit_score_commentary := l_entry_value;
       elsif tca_column_name = upper('db_rating') then
           org_rec.db_rating := l_entry_value;
       elsif tca_column_name = upper('date_of_birth') then
           person_rec.date_of_birth := l_entry_value;
       elsif tca_column_name = upper('') then
           person_rec.date_of_death := l_entry_value;
       elsif tca_column_name = upper('date_of_death') then
           org_rec.debarments_count := l_entry_value;
       elsif tca_column_name = upper('debarments_date') then
           org_rec.debarments_date := l_entry_value;
       elsif tca_column_name = upper('declared_ethnicity') then
           person_rec.declared_ethnicity := l_entry_value;
       elsif tca_column_name = upper('debarment_ind') then
           org_rec.debarment_ind := l_entry_value;
       elsif tca_column_name = upper('description') then
           location_rec.description := l_entry_value;
       elsif tca_column_name = upper('disadv_8a_ind') then
           org_rec.disadv_8a_ind := l_entry_value;
       elsif tca_column_name = upper('enquiry_duns') then
           org_rec.enquiry_duns := l_entry_value;
       elsif tca_column_name = upper('export_ind') then
           org_rec.export_ind := l_entry_value;
       elsif tca_column_name = upper('failure_score') then
           org_rec.failure_score := l_entry_value;
       elsif tca_column_name = upper('failure_score_commentary') then
           org_rec.failure_score_commentary := l_entry_value;
       elsif tca_column_name = upper('failure_score_natnl_percentile') then
           org_rec.failure_score_natnl_percentile := l_entry_value;
       elsif tca_column_name = upper('failure_score_override_code') then
           org_rec.failure_score_override_code := l_entry_value;
       elsif tca_column_name = upper('global_failure_score') then
           org_rec.global_failure_score := l_entry_value;
       elsif tca_column_name = upper('hq_branch_ind') then
           org_rec.hq_branch_ind := l_entry_value;
       elsif tca_column_name = upper('head_of_household_flag') then
           person_rec.head_of_household_flag := l_entry_value;
       elsif tca_column_name = upper('household_size') then
           person_rec.household_size := l_entry_value;
       elsif tca_column_name = upper('import_ind') then
           org_rec.import_ind := l_entry_value;
       elsif tca_column_name = upper('known_as') then
           org_rec.known_as := l_entry_value;
       elsif tca_column_name = upper('known_as2') then
           org_rec.known_as2 := l_entry_value;
       elsif tca_column_name = upper('known_as3') then
           org_rec.known_as3 := l_entry_value;
       elsif tca_column_name = upper('known_as4') then
           org_rec.known_as4 := l_entry_value;
       elsif tca_column_name = upper('known_as5') then
           org_rec.known_as5 := l_entry_value;
       elsif tca_column_name = upper('known_as') then
           person_rec.known_as := l_entry_value;
       elsif tca_column_name = upper('known_as2') then
           person_rec.known_as2 := l_entry_value;
       elsif tca_column_name = upper('') then
           person_rec.known_as3 := l_entry_value;
       elsif tca_column_name = upper('known_as3') then
           person_rec.known_as4 := l_entry_value;
       elsif tca_column_name = upper('known_as5') then
           person_rec.known_as5 := l_entry_value;
       elsif tca_column_name = upper('labor_surplus_ind') then
           org_rec.labor_surplus_ind := l_entry_value;
       elsif tca_column_name = upper('local_activity_code') then
           org_rec.local_activity_code := l_entry_value;
       elsif tca_column_name = upper('local_activity_code_type') then
           org_rec.local_activity_code_type := l_entry_value;
       elsif tca_column_name = upper('location_directions') then
           location_rec.location_directions := l_entry_value;
       elsif tca_column_name = upper('marital_status') then
           person_rec.marital_status := l_entry_value;
       elsif tca_column_name = upper('marital_status_effective_date') then
           person_rec.marital_status_effective_date := l_entry_value;
       elsif tca_column_name = upper('minority_owned_ind') then
           org_rec.minority_owned_ind := l_entry_value;
       elsif tca_column_name = upper('minority_owned_type') then
           org_rec.minority_owned_type := l_entry_value;
       elsif tca_column_name = upper('organization_type') then
           org_rec.organization_type := l_entry_value;
       elsif tca_column_name = upper('') then
           web_rec.url := l_entry_value;
       elsif tca_column_name = upper('url') then
           org_rec.oob_ind := l_entry_value;
       elsif tca_column_name = upper('personal_income') then
           person_rec.personal_income := l_entry_value;
       elsif tca_column_name = upper('person_academic_title') then
           person_rec.person_academic_title := l_entry_value;
       elsif tca_column_name = upper('person_first_name_phonetic') then
           person_rec.person_first_name_phonetic := l_entry_value;
       elsif tca_column_name = upper('person_last_name_phonetic') then
           person_rec.person_last_name_phonetic := l_entry_value;
       elsif tca_column_name = upper('middle_name_phonetic') then
           person_rec.middle_name_phonetic := l_entry_value;
       elsif tca_column_name = upper('person_name_phonetic') then
           person_rec.person_name_phonetic := l_entry_value;
       elsif tca_column_name = upper('person_previous_last_name') then
           person_rec.person_previous_last_name := l_entry_value;
       elsif tca_column_name = upper('place_of_birth') then
           person_rec.place_of_birth := l_entry_value;
       elsif tca_column_name = upper('principal_name') then
           org_rec.principal_name := l_entry_value;
       elsif tca_column_name = upper('principal_title') then
           org_rec.principal_title := l_entry_value;
       elsif tca_column_name = upper('public_private_ownership_flag') then
           org_rec.public_private_ownership_flag := l_entry_value;
       elsif tca_column_name = upper('') then
           org_rec.rent_own_ind := l_entry_value;
       elsif tca_column_name = upper('person_academic_title') then
           person_rec.person_academic_title := l_entry_value;
       elsif tca_column_name = upper('short_description') then
           location_rec.short_description := l_entry_value;
       elsif tca_column_name = upper('small_bus_ind') then
           org_rec.small_bus_ind := l_entry_value;
       elsif tca_column_name = upper('woman_owned_ind') then
           org_rec.woman_owned_ind := l_entry_value;
       elsif tca_column_name = upper('attribute1') then
           org_rec.party_rec.attribute1 := l_entry_value;
       elsif tca_column_name = upper('attribute2') then
           org_rec.party_rec.attribute2 := l_entry_value;
       elsif tca_column_name = upper('attribute3') then
           org_rec.party_rec.attribute3 := l_entry_value;
       elsif tca_column_name = upper('attribute4') then
           org_rec.party_rec.attribute4 := l_entry_value;
       elsif tca_column_name = upper('attribute5') then
           org_rec.party_rec.attribute5 := l_entry_value;
       elsif tca_column_name = upper('attribute6') then
           org_rec.party_rec.attribute6 := l_entry_value;
       elsif tca_column_name = upper('attribute7') then
           org_rec.party_rec.attribute7 := l_entry_value;
       elsif tca_column_name = upper('attribute8') then
           org_rec.party_rec.attribute8 := l_entry_value;
       elsif tca_column_name = upper('attribute9') then
           org_rec.party_rec.attribute9 := l_entry_value;
       elsif tca_column_name = upper('attribute10') then
           org_rec.party_rec.attribute10 := l_entry_value;
       elsif tca_column_name = upper('attribute11') then
           org_rec.party_rec.attribute11 := l_entry_value;
       elsif tca_column_name = upper('attribute12') then
           org_rec.party_rec.attribute12 := l_entry_value;
       elsif tca_column_name = upper('attribute13') then
           org_rec.party_rec.attribute13 := l_entry_value;
       elsif tca_column_name = upper('attribute14') then
           org_rec.party_rec.attribute14 := l_entry_value;
       elsif tca_column_name = upper('') then
           org_rec.party_rec.attribute15 := l_entry_value;
       elsif tca_column_name = upper('attribute1') then
           person_rec.attribute1 := l_entry_value;
       elsif tca_column_name = upper('attribute2') then
           person_rec.attribute2 := l_entry_value;
       elsif tca_column_name = upper('attribute3') then
           person_rec.attribute3 := l_entry_value;
       elsif tca_column_name = upper('attribute4') then
           person_rec.attribute4 := l_entry_value;
       elsif tca_column_name = upper('attribute5') then
           person_rec.attribute5 := l_entry_value;
       elsif tca_column_name = upper('attribute6') then
           person_rec.attribute6 := l_entry_value;
       elsif tca_column_name = upper('attribute7') then
           person_rec.attribute7 := l_entry_value;
       elsif tca_column_name = upper('attribute8') then
           person_rec.attribute8 := l_entry_value;
       elsif tca_column_name = upper('attribute9') then
           person_rec.attribute9 := l_entry_value;
       elsif tca_column_name = upper('attribute10') then
           person_rec.attribute10 := l_entry_value;
       elsif tca_column_name = upper('attribute11') then
           person_rec.attribute11 := l_entry_value;
       elsif tca_column_name = upper('attribute12') then
           person_rec.attribute12 := l_entry_value;
       elsif tca_column_name = upper('attribute13') then
           person_rec.attribute13 := l_entry_value;
       elsif tca_column_name = upper('attribute14') then
           person_rec.attribute14 := l_entry_value;
       elsif tca_column_name = upper('attribute15') then
           person_rec.attribute15 := l_entry_value;
       elsif tca_column_name = upper('attribute1') then
           ocon_rec.attribute1 := l_entry_value;
       elsif tca_column_name = upper('attribute2') then
           ocon_rec.attribute2 := l_entry_value;
       elsif tca_column_name = upper('attribute3') then
           ocon_rec.attribute3 := l_entry_value;
       elsif tca_column_name = upper('attribute4') then
           ocon_rec.attribute4 := l_entry_value;
       elsif tca_column_name = upper('attribute5') then
           ocon_rec.attribute5 := l_entry_value;
       elsif tca_column_name = upper('attribute6') then
           ocon_rec.attribute6 := l_entry_value;
       elsif tca_column_name = upper('attribute7') then
           ocon_rec.attribute7 := l_entry_value;
       elsif tca_column_name = upper('attribute8') then
           ocon_rec.attribute8 := l_entry_value;
       elsif tca_column_name = upper('attribute9') then
           ocon_rec.attribute9 := l_entry_value;
       elsif tca_column_name = upper('attribute10') then
           ocon_rec.attribute10 := l_entry_value;
       elsif tca_column_name = upper('attribute11') then
           ocon_rec.attribute11 := l_entry_value;
       elsif tca_column_name = upper('attribute12') then
           ocon_rec.attribute12 := l_entry_value;
       elsif tca_column_name = upper('attribute13') then
           ocon_rec.attribute13 := l_entry_value;
       elsif tca_column_name = upper('attribute14') then
           ocon_rec.attribute14 := l_entry_value;
       elsif tca_column_name = upper('attribute15') then
           ocon_rec.attribute15 := l_entry_value;
       elsif tca_column_name = upper('attribute1') then
           location_rec.attribute1 := l_entry_value;
       elsif tca_column_name = upper('attribute2') then
           location_rec.attribute2 := l_entry_value;
       elsif tca_column_name = upper('attribute3') then
           location_rec.attribute3 := l_entry_value;
       elsif tca_column_name = upper('attribute4') then
           location_rec.attribute4 := l_entry_value;
       elsif tca_column_name = upper('attribute5') then
           location_rec.attribute5 := l_entry_value;
       elsif tca_column_name = upper('attribute6') then
           location_rec.attribute6 := l_entry_value;
       elsif tca_column_name = upper('attribute7') then
           location_rec.attribute7 := l_entry_value;
       elsif tca_column_name = upper('attribute8') then
           location_rec.attribute8 := l_entry_value;
       elsif tca_column_name = upper('attribute9') then
           location_rec.attribute9 := l_entry_value;
       elsif tca_column_name = upper('attribute10') then
           location_rec.attribute10 := l_entry_value;
       elsif tca_column_name = upper('attribute11') then
           location_rec.attribute11 := l_entry_value;
       elsif tca_column_name = upper('attribute12') then
           location_rec.attribute12 := l_entry_value;
       elsif tca_column_name = upper('attribute13') then
           location_rec.attribute13 := l_entry_value;
       elsif tca_column_name = upper('attribute14') then
           location_rec.attribute14 := l_entry_value;
       elsif tca_column_name = upper('attribute15') then
           location_rec.attribute15 := l_entry_value;
       elsif tca_column_name = upper('phone_country_code') then
           fax_rec.phone_country_code := l_entry_value;
       elsif tca_column_name = upper('phone_area_code') then
           fax_rec.phone_area_code := l_entry_value;
       elsif tca_column_name = upper('phone_number') then
           fax_rec.phone_number := l_entry_value;
       elsif tca_column_name = upper('attribute_category') then
           org_rec.party_rec.attribute_category := l_entry_value;
       elsif tca_column_name = upper('attribute_category') then
           person_rec.attribute_category := l_entry_value;
       elsif tca_column_name = upper('attribute_category') then
           ocon_rec.attribute_category := l_entry_value;
       elsif tca_column_name = upper('attribute_category') then
           location_rec.attribute_category := l_entry_value;
       elsif tca_column_name = upper('site_use_type') then
           psiteuse_rec.site_use_type := l_entry_value;
       end if;

       --TCA mandate: bug 4587049
         --party_rec.created_by_module := 'AMS';
         org_rec.created_by_module := 'AMS';
         person_rec.created_by_module := 'AMS';
         ocon_rec.created_by_module := 'AMS';
         location_rec.created_by_module := 'AMS';
         psite_rec.created_by_module := 'AMS';
         psiteuse_rec.created_by_module := 'AMS';

   end if;   -- l_b2b_flag = 'Y'

   if l_b2b_flag = 'B2C' then
	l_b2b := 'N';
        if tca_column_name = upper('person_first_name') then
           person_rec.person_first_name := l_entry_value;
       elsif tca_column_name = upper('person_middle_name') then
           person_rec.person_middle_name := l_entry_value;
       elsif tca_column_name = upper('person_last_name') then
           person_rec.person_last_name := l_entry_value;
       elsif tca_column_name = upper('person_name_suffix') then
           person_rec.person_name_suffix := l_entry_value;
       elsif tca_column_name = upper('person_pre_name_adjunct') then
           person_rec.person_pre_name_adjunct := l_entry_value;
       elsif tca_column_name = upper('country') then
           location_rec.country := l_entry_value;
       elsif tca_column_name = upper('address1') then
           location_rec.address1 := l_entry_value;
       elsif tca_column_name = upper('address2') then
           location_rec.address2 := l_entry_value;
       elsif tca_column_name = upper('city') then
           location_rec.city := l_entry_value;
       elsif tca_column_name = upper('county') then
           location_rec.county := l_entry_value;
       elsif tca_column_name = upper('state') then
           location_rec.state := l_entry_value;
       elsif tca_column_name = upper('province') then
           location_rec.province := l_entry_value;
       elsif tca_column_name = upper('postal_code') then
           location_rec.postal_code := l_entry_value;
       elsif tca_column_name = upper('email_address') then
           email_rec.email_address := l_entry_value;
       elsif tca_column_name = upper('phone_country_code') then
           phone_rec.phone_country_code := l_entry_value;
       elsif tca_column_name = upper('phone_area_code') then
           phone_rec.phone_area_code := l_entry_value;
       elsif tca_column_name = upper('phone_number') then
           phone_rec.phone_number := l_entry_value;
       elsif tca_column_name = upper('phone_extension') then
           phone_rec.phone_extension := l_entry_value;
       elsif tca_column_name = upper('SALUTATION') then
           person_rec.party_rec.SALUTATION := l_entry_value;
       elsif tca_column_name = upper('ADDRESS3') then
           location_rec.ADDRESS3 := l_entry_value;
       elsif tca_column_name = upper('ADDRESS4') then
           location_rec.ADDRESS4 := l_entry_value;
       elsif tca_column_name = upper('ADDRESS_LINES_PHONETIC') then
           location_rec.ADDRESS_LINES_PHONETIC := l_entry_value;
       elsif tca_column_name = upper('PO_BOX_NUMBER') then
           -- location_rec.PO_BOX_NUMBER := l_entry_value; Refer bug 4704727
	   location_rec.PO_BOX_NUMBER := null;
       elsif tca_column_name = upper('HOUSE_NUMBER') then
           -- location_rec.HOUSE_NUMBER := l_entry_value; Refer bug 4704727
	   location_rec.HOUSE_NUMBER := null;
       elsif tca_column_name = upper('STREET_SUFFIX') then
           -- location_rec.STREET_SUFFIX := l_entry_value; Refer bug 4704727
	   location_rec.STREET_SUFFIX := null;
       elsif tca_column_name = upper('STREET') then
           -- location_rec.STREET := l_entry_value; Refer bug 4704727
	   location_rec.STREET := null;
       elsif tca_column_name = upper('STREET_NUMBER') then
	   -- location_rec.STREET_NUMBER := l_entry_value; Refer bug 4704727
	   location_rec.STREET_NUMBER := null;
       elsif tca_column_name = upper('FLOOR') then
           -- location_rec.FLOOR := l_entry_value; Refer bug 4704727
	   location_rec.FLOOR := null;
       elsif tca_column_name = upper('SUITE') then
           -- location_rec.SUITE := l_entry_value; Refer bug 4704727
	   location_rec.SUITE := null;
       elsif tca_column_name = upper('POSTAL_PLUS4_CODE') then
           location_rec.POSTAL_PLUS4_CODE := l_entry_value;
       elsif tca_column_name = upper('identifying_address_flag') then
           psite_rec.identifying_address_flag := l_entry_value;
       elsif tca_column_name = upper('person_last_name_phonetic') then
           person_rec.person_last_name_phonetic := l_entry_value;
       elsif tca_column_name = upper('person_first_name_phonetic') then
           person_rec.person_first_name_phonetic := l_entry_value;
       elsif tca_column_name = upper('url') then
           web_rec.url := l_entry_value;
       elsif tca_column_name = upper('person_academic_title') then
           person_rec.person_academic_title := l_entry_value;
       elsif tca_column_name = upper('date_of_birth') then
           person_rec.date_of_birth := l_entry_value;
       elsif tca_column_name = upper('person_academic_title') then
           person_rec.person_academic_title := l_entry_value;
       elsif tca_column_name = upper('person_previous_last_name') then
           person_rec.person_previous_last_name := l_entry_value;
       elsif tca_column_name = upper('known_as') then
           person_rec.known_as := l_entry_value;
       elsif tca_column_name = upper('known_as2') then
           person_rec.known_as2 := l_entry_value;
       elsif tca_column_name = upper('known_as3') then
           person_rec.known_as3 := l_entry_value;
       elsif tca_column_name = upper('known_as4') then
           person_rec.known_as4 := l_entry_value;
       elsif tca_column_name = upper('known_as5') then
           person_rec.known_as5 := l_entry_value;
       elsif tca_column_name = upper('person_name_phonetic') then
           person_rec.person_name_phonetic := l_entry_value;
       elsif tca_column_name = upper('middle_name_phonetic') then
           person_rec.middle_name_phonetic := l_entry_value;
       elsif tca_column_name = upper('jgzz_fiscal_code') then
           person_rec.jgzz_fiscal_code := l_entry_value;
       elsif tca_column_name = upper('place_of_birth') then
           person_rec.place_of_birth := l_entry_value;
       elsif tca_column_name = upper('date_of_death') then
           person_rec.date_of_death := l_entry_value;
       elsif tca_column_name = upper('declared_ethnicity') then
           person_rec.declared_ethnicity := l_entry_value;
       elsif tca_column_name = upper('marital_status') then
           person_rec.marital_status := l_entry_value;
       elsif tca_column_name = upper('personal_income') then
           person_rec.personal_income := l_entry_value;
       elsif tca_column_name = upper('marital_status_effective_date') then
           person_rec.marital_status_effective_date := l_entry_value;
       elsif tca_column_name = upper('head_of_household_flag') then
           person_rec.head_of_household_flag := l_entry_value;
       elsif tca_column_name = upper('household_size') then
           person_rec.household_size := l_entry_value;
       elsif tca_column_name = upper('location_directions') then
           location_rec.location_directions := l_entry_value;
       elsif tca_column_name = upper('address_effective_date') then
           location_rec.address_effective_date := l_entry_value;
       elsif tca_column_name = upper('address_expiration_date') then
	   location_rec.address_expiration_date := l_entry_value;
       elsif tca_column_name = upper('attribute1') then
           person_rec.party_rec.attribute1 := l_entry_value;
       elsif tca_column_name = upper('attribute2') then
           person_rec.party_rec.attribute2 := l_entry_value;
       elsif tca_column_name = upper('attribute3') then
           person_rec.party_rec.attribute3 := l_entry_value;
       elsif tca_column_name = upper('attribute4') then
           person_rec.party_rec.attribute4 := l_entry_value;
       elsif tca_column_name = upper('attribute5') then
           person_rec.party_rec.attribute5 := l_entry_value;
       elsif tca_column_name = upper('attribute6') then
           person_rec.party_rec.attribute6 := l_entry_value;
       elsif tca_column_name = upper('attribute7') then
           person_rec.party_rec.attribute7 := l_entry_value;
       elsif tca_column_name = upper('attribute8') then
           person_rec.party_rec.attribute8 := l_entry_value;
       elsif tca_column_name = upper('') then
           person_rec.party_rec.attribute9 := l_entry_value;
       elsif tca_column_name = upper('attribute9') then
           person_rec.party_rec.attribute10 := l_entry_value;
       elsif tca_column_name = upper('attribute11') then
           person_rec.party_rec.attribute11 := l_entry_value;
       elsif tca_column_name = upper('attribute12') then
           person_rec.party_rec.attribute12 := l_entry_value;
       elsif tca_column_name = upper('attribute13') then
           person_rec.party_rec.attribute13 := l_entry_value;
       elsif tca_column_name = upper('attribute14') then
           person_rec.party_rec.attribute14 := l_entry_value;
       elsif tca_column_name = upper('attribute15') then
           person_rec.party_rec.attribute15 := l_entry_value;
       elsif tca_column_name = upper('attribute1') then
           location_rec.attribute1 := l_entry_value;
       elsif tca_column_name = upper('attribute2') then
           location_rec.attribute2 := l_entry_value;
       elsif tca_column_name = upper('attribute3') then
           location_rec.attribute3 := l_entry_value;
       elsif tca_column_name = upper('attribute4') then
           location_rec.attribute4 := l_entry_value;
       elsif tca_column_name = upper('attribute5') then
           location_rec.attribute5 := l_entry_value;
       elsif tca_column_name = upper('attribute6') then
           location_rec.attribute6 := l_entry_value;
       elsif tca_column_name = upper('attribute7') then
           location_rec.attribute7 := l_entry_value;
       elsif tca_column_name = upper('attribute8') then
           location_rec.attribute8 := l_entry_value;
       elsif tca_column_name = upper('attribute9') then
           location_rec.attribute9 := l_entry_value;
       elsif tca_column_name = upper('attribute10') then
           location_rec.attribute10 := l_entry_value;
       elsif tca_column_name = upper('attribute11') then
           location_rec.attribute11 := l_entry_value;
       elsif tca_column_name = upper('attribute12') then
           location_rec.attribute12 := l_entry_value;
       elsif tca_column_name = upper('attribute13') then
           location_rec.attribute13 := l_entry_value;
       elsif tca_column_name = upper('attribute14') then
           location_rec.attribute14 := l_entry_value;
       elsif tca_column_name = upper('attribute15') then
           location_rec.attribute15 := l_entry_value;
       elsif tca_column_name = upper('phone_country_code') then
           fax_rec.phone_country_code := l_entry_value;
       elsif tca_column_name = upper('phone_area_code') then
           fax_rec.phone_area_code := l_entry_value;
       elsif tca_column_name = upper('phone_number') then
	   fax_rec.phone_number := l_entry_value;
       elsif tca_column_name = upper('attribute_category') then
           person_rec.party_rec.attribute_category := l_entry_value;
       elsif tca_column_name = upper('attribute_category') then
           location_rec.attribute_category  := l_entry_value;
       elsif tca_column_name = upper('short_description') then
           location_rec.short_description := l_entry_value;
       elsif tca_column_name = upper('description') then
           location_rec.description := l_entry_value;
       elsif tca_column_name = upper('site_use_type') then
           psiteuse_rec.site_use_type := l_entry_value;
       elsif tca_column_name = upper('orig_system_reference') then
           person_rec.party_rec.orig_system_reference := l_entry_value;
       elsif tca_column_name = upper('tax_reference') then
           person_rec.tax_reference := l_entry_value;
       elsif tca_column_name = upper('rent_own_ind') then
           person_rec.rent_own_ind := l_entry_value;
       elsif tca_column_name = upper('gender') then
           person_rec.gender := l_entry_value;
       elsif tca_column_name = upper('HOUSEHOLD_INCOME') then
           person_rec.HOUSEHOLD_INCOME  := l_entry_value;
       end if;

       --TCA mandate: bug 4587049
         --party_rec.created_by_module := 'AMS';
         person_rec.created_by_module := 'AMS';
         location_rec.created_by_module := 'AMS';
         psite_rec.created_by_module := 'AMS';
         psiteuse_rec.created_by_module := 'AMS';

      end if; -- l_b2b_flag = 'N'
     end loop; -- for c_tca_columns
     close c_tca_columns;
     l_entry_value := NULL;

 -- DBMS_OUTPUT.PUT_LINE('before tca call');
  --write_to_act_log('Calling ams_list_import_pub to create customer', 'LIST', p_list_header_id,'LOW');

     -- ---------------------------TCA CALL ---------------------------------


  AMS_List_Import_PUB.Create_Customer (
  p_api_version              => 1,
  p_init_msg_list            => 'T',
  p_commit                   => 'F',
  x_return_status            => x_return_status,
  x_msg_count                => x_msg_count,
  x_msg_data                 => x_msg_data,
  p_party_id                 => l_party_id,
  p_b2b_flag                 => l_b2b,
  p_import_list_header_id    =>null,
  p_party_rec                => party_rec,
  p_org_rec                  => org_rec,
  p_person_rec               => person_rec,
  p_location_rec             => location_rec,
  p_psite_rec                => psite_rec,
  p_cpoint_rec               => cpoint_rec,
  p_email_rec                => email_rec,
  p_phone_rec                => phone_rec,
  p_fax_rec                  => fax_rec,
  p_ocon_rec                 => ocon_rec,
  p_siteuse_rec              => psiteuse_rec,
  p_web_rec                  => web_rec,
  x_new_party                => l_new_party,
  p_component_name           => l_component_name,
  l_import_source_line_id    => null
  );
   -- write_to_act_log('Total no of messages '||x_msg_count, 'LIST', p_list_header_id,'LOW');
   -- write_to_act_log('List entry id is '||l_list_entry_id, 'LIST', p_list_header_id,'LOW');
   -- write_to_act_log('Party id is '||l_party_id, 'LIST', p_list_header_id,'LOW');
  if x_msg_count > 0 then
    FOR i IN 1..x_msg_count  LOOP
         -- Following code was modified by bmuthukr
         --x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
         --x_tmp_var1 := substrb(x_tmp_var1 || ' '|| x_tmp_var,1,4000);
	 x_tmp_var := 'Please make sure that the required fields (eg. person first name, last name) are available in the remote database';
         write_to_act_log('Updating the tca_load_status as ERROR', 'LIST', p_list_header_id,'HIGH');

	 -- DBMS_OUTPUT.PUT_LINE('TCA Upload Process : x_tmp_var  ->' || x_tmp_var );
	 -- DBMS_OUTPUT.PUT_LINE('TCA Upload Process : x_tmp_var  ->' || x_tmp_var1 );
    END LOOP;
    update ams_list_entries set error_flag = 'E',
				tca_load_status = 'ERROR',
				ENABLED_FLAG = 'N',
				--error_text = 'TCA API ERROR :'||substr(x_tmp_var1,1,3000)
				error_text = 'TCA API ERROR :'||x_tmp_var
    where list_entry_id = l_list_entry_id;
  end if;
    if l_party_id is  null then
    update ams_list_entries set error_flag = 'E',
				tca_load_status = 'ERROR',
				ENABLED_FLAG = 'N',
				--error_text = 'TCA API ERROR :'||nvl(x_tmp_var,substr(x_tmp_var1,1,3000))
				error_text = 'TCA API ERROR :'||x_tmp_var
    where list_entry_id = l_list_entry_id;
   end if;

  if l_party_id is not null then
    update ams_list_entries set party_id = l_party_id,
				error_flag = 'S',
				ENABLED_FLAG = 'Y',
                                tca_load_status = 'SUCCESS'
    where list_entry_id = l_list_entry_id;
   end if;
   l_party_id := NULL;
 -- DBMS_OUTPUT.PUT_LINE('after tca call');

     -- ---------------------------TCA CALL ---------------------------------

  END LOOP; -- For c_list_entries
  close c_list_entries;
  update ams_list_headers_all
     set migration_date = sysdate
   where list_header_id = p_list_header_id;

  write_to_act_log('Executed procedure tca_upload_process', 'LIST', g_list_header_id,'LOW');

  -- Added for cancel list gen as it prevents parallel update- Raghu
  -- of list headers when cancel button is pressed

  --TCA mandate: bug 4587049
  --Enable/restore TCA events after bulk TCA data processing
  if l_prof <> 'N' then
     fnd_profile.put('HZ_EXECUTE_API_CALLOUTS',l_prof);
  end if;

  commit;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     write_to_act_log('Error while executing procedure tca_upload_process '||sqlcode||'  '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     x_return_status := FND_API.G_RET_STS_ERROR ;

     if l_prof <> 'N' then
        fnd_profile.put('HZ_EXECUTE_API_CALLOUTS',l_prof);
     end if;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );



  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     write_to_act_log('Error while executing procedure tca_upload_process '||sqlcode||'  '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     x_return_status := FND_API.G_RET_STS_ERROR ;

     if l_prof <> 'N' then
        fnd_profile.put('HZ_EXECUTE_API_CALLOUTS',l_prof);
     end if;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

  WHEN OTHERS THEN
     write_to_act_log('Error while executing procedure tca_upload_process '||sqlcode||'  '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     x_return_status := FND_API.G_RET_STS_ERROR ;

     if l_prof <> 'N' then
        fnd_profile.put('HZ_EXECUTE_API_CALLOUTS',l_prof);
     end if;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END tca_upload_process;

PROCEDURE remote_list_gen
             (p_list_header_id     in  number,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2,
	      x_remote_gen         OUT NOCOPY VARCHAR2)
IS
  l_remote_list_gen	varchar2(1) := 'N';
  l_list_selection      varchar2(1);
  l_onlylist_selection  varchar2(1);

  cursor c_list_selection is
  select 'Y' from ams_list_select_actions
   where  action_used_by_id = p_list_header_id
     and  arc_action_used_by = 'LIST'
     and  arc_incl_object_from in ('CELL','DIWB','SQL');

  cursor c_only_list_selection is
  select 'Y' from ams_list_select_actions act, ams_list_headers_all head
   where  act.action_used_by_id = p_list_header_id
     and  act.arc_incl_object_from = 'LIST' and act.arc_action_used_by = 'LIST'
     and  act.INCL_OBJECT_ID = head.list_header_id
     and  head.status_code = 'AVAILABLE'
     and  (head.MIGRATION_DATE is null or head.main_gen_end_time > head.migration_date);

begin

     open c_list_selection;
     fetch c_list_selection into l_list_selection;
     close c_list_selection;

     if nvl(l_list_selection,'N') = 'Y' then
        write_to_act_log(p_msg_data => 'List selection includes segments/workbook/SQL.' ,
                         p_arc_log_used_by => 'LIST',
                         p_log_used_by_id  => p_list_header_id,
                         p_level => 'LOW');
        x_remote_gen := 'Y';
        x_return_status := FND_API.G_RET_STS_SUCCESS;
     else
        write_to_act_log(p_msg_data => 'List selection does not include segments/workbook/SQL.' ,
                         p_arc_log_used_by => 'LIST',
                         p_log_used_by_id  => p_list_header_id,
                         p_level => 'LOW');
     end if;

     if l_list_selection is null then
        open c_only_list_selection;
        fetch c_only_list_selection into l_onlylist_selection;
        close c_only_list_selection;
        if nvl(l_onlylist_selection,'N') = 'Y' then
           write_to_act_log(p_msg_data => 'List/TG will be generated in remote instance.' ,
                            p_arc_log_used_by => 'LIST',
                            p_log_used_by_id  => p_list_header_id,
			    p_level => 'LOW');
           x_remote_gen := 'Y';
           x_return_status := FND_API.G_RET_STS_SUCCESS;
        else
           write_to_act_log(p_msg_data => 'List/TG will be generated in local instance.' ,
                            p_arc_log_used_by => 'LIST',
                            p_log_used_by_id  => p_list_header_id,
                            p_level => 'LOW');
           x_remote_gen := 'N';
           x_return_status := FND_API.G_RET_STS_SUCCESS;
        end if;
     end if;

  EXCEPTION
  WHEN OTHERS THEN
    write_to_act_log('Error while executing procedure remote_list_gen '||sqlcode||'  '||sqlerrm, 'LIST', g_list_header_id,'HIGH');
     x_return_status := FND_API.G_RET_STS_ERROR ;
     x_msg_data := 'Error while executing procedure remote_list_gen '||sqlcode||'  '||sqlerrm;
     x_msg_count := 1;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

end remote_list_gen;

--Procedure is_manual added by bmuthukr for bug 3710720
PROCEDURE is_manual
             (p_list_header_id     in  number,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2,
              x_is_manual          OUT NOCOPY varchar2 ) is

  cursor c1 is
  select list_type
    from ams_list_headers_all
   where list_header_id = p_list_header_id;

  cursor c2 is
  select 1
    from ams_list_entries
   where list_header_id = p_list_header_id
     and enabled_flag = 'Y'
     and rownum = 1;

  cursor c_get_list_used_by_id is
  select list_used_by_id
    from ams_act_lists
   where list_header_id = p_list_header_id
     and list_used_by = 'CSCH'
     and list_act_type = 'TARGET';

  cursor c3 is
  select 1
    from ams_list_select_actions
   where list_header_id = p_list_header_id
     and arc_incl_object_from  = 'EMPLOYEE';

  cursor c4(l_list_used_by_id number) is
  select 1
    from ams_act_lists
   where list_used_by_id = l_list_used_by_id
     and list_act_type = 'EMPLOYEE';

l_list_type        varchar2(100) := null;
l_dummy            number := 0;
l_list_used_by_id  number := 0;


begin
   open c1;
   fetch c1 into l_list_type;
   close c1;

   write_to_act_log('List is of type '||l_list_type,'LIST',p_list_header_id,'HIGH');

   if l_list_type = 'MANUAL' then --List type is manual. Make the status as either available/draft.
      write_to_act_log('List is of type MANUAL. Cannot regenerate. ','LIST',p_list_header_id,'HIGH');
      x_is_manual := 'Y';
   else
      x_is_manual := 'N';
   end if;

   if l_list_type = 'TARGET' then -- To see if any of the incl are based on emp list in TG
      open c_get_list_used_by_id;
      fetch c_get_list_used_by_id into l_list_used_by_id;
      close c_get_list_used_by_id;

      open c4(l_list_used_by_id);
      fetch c4 into l_dummy;
      if c4%found then
         write_to_act_log('Target group inclusions has EMPLOYEE list. Cannot generate','LIST',p_list_header_id,'HIGH');
         x_is_manual := 'Y';
      end if;
      close c4;
   end if;

   if l_list_type = 'STANDARD' then -- To see if any of the incl are based on emp list in std list
      open c3;
      fetch c3 into l_dummy;
      if c3%found then
         write_to_act_log('List inclusions has EMPLOYEE list. Cannot generate','LIST',p_list_header_id,'HIGH');
         x_is_manual := 'Y';
      end if;
      close c3;
   end if;


   if nvl(x_is_manual,'N') = 'Y' then --Either if it is manual list or if any of the incl are of type emp list.
      open c2;
      fetch c2 into l_dummy;
      if c2%found then -- List already has enabled entries.. So making it as available.
         update ams_list_headers_all
            set status_code          = 'AVAILABLE',
                user_status_id       = 303,
                status_date          = sysdate,
                last_update_date     = sysdate
          where list_header_id       = p_list_header_id;
      else  -- No enabled entries..So it will be in DRAFT status
         update ams_list_headers_all
            set status_code          = 'DRAFT',
                user_status_id       = 300,
                status_date          = sysdate,
                last_update_date     = sysdate
          where list_header_id       = p_list_header_id;
      end if;
      close c2;

      -- Added for cancel list gen as it prevents parallel update- Raghu
      -- of list headers when cancel button is pressed
      commit;
   end if;

exception
   when others then
      write_to_act_log('Error while executing procedure is_manual '||sqlcode||'   '||sqlerrm,'LIST',p_list_header_id,'HIGH');
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_msg_data := 'Error while executing procedure is_manual '||sqlcode||'  '||sqlerrm;
      x_msg_count := 1;
end is_manual;

procedure upd_list_header_info(p_list_header_id in number,
                               x_msg_count      out nocopy number,
                               x_msg_data       out nocopy varchar2,
                               x_return_status  out nocopy varchar2) is

l_list_type                     varchar2(100);
l_remote_flag                   varchar2(1);
l_database_link                 varchar2(200);

l_no_of_rows_duplicates         number;
l_no_of_rows_in_list            number;
l_no_of_rows_active             number;
l_no_of_rows_inactive           number;
l_no_of_rows_manually_entered   number;
l_no_of_rows_in_ctrl_group      number;
l_no_of_rows_random             number;
l_no_of_rows_used               number;
l_no_of_rows_suppressed         number;
l_no_of_rows_fatigued           number;

cursor c_list_det is
select stypes.database_link,
       list.remote_gen_flag,
       list.list_type
  from ams_list_src_types stypes, ams_list_headers_all list
 where list.list_source_type = stypes.source_type_code
   and list_header_id  =  p_list_header_id;

cursor c_count_list_entries is
select sum(decode(enabled_flag,'N',0,1)),
       sum(decode(enabled_flag,'Y',0,1)),
       sum(1),
       sum(decode(manually_entered_flag,'Y',decode(enabled_flag,'Y','1',0),0))
  from ams_list_entries
 where list_header_id = p_list_header_id;

begin
   open c_list_det;
   fetch c_list_det into l_database_link,l_remote_flag,l_list_type;
   close c_list_det;

   if l_remote_flag = 'N' or l_list_type <> 'TARGET' then
      open c_count_list_entries;
      fetch c_count_list_entries
       into l_no_of_rows_active            ,
            l_no_of_rows_inactive          ,
            l_no_of_rows_in_list           ,
            l_no_of_rows_manually_entered  ;
      close c_count_list_entries;
   else
      execute immediate
      'BEGIN
         AMS_Remote_ListGen_PKG.remote_list_status_detils'||'@'||l_database_link||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11)'||';'||
      ' END;'
      using  p_list_header_id,
             OUT l_no_of_rows_active,
             OUT l_no_of_rows_inactive,
             OUT l_no_of_rows_in_list,
             OUT l_no_of_rows_in_ctrl_group,
	     OUT l_no_of_rows_random,
	     OUT l_no_of_rows_duplicates,
	     OUT l_no_of_rows_manually_entered,
             OUT x_msg_count,
             OUT x_msg_data,
             OUT x_return_status;
   end if;

   update ams_list_headers_all
      set no_of_rows_in_list          = nvl(l_no_of_rows_in_list,0),
          no_of_rows_active           = nvl(l_no_of_rows_active,0),
          no_of_rows_inactive         = nvl(l_no_of_rows_inactive,0),
          no_of_rows_manually_entered = nvl(l_no_of_rows_manually_entered,0)
    where list_header_id = p_list_header_id;
    commit;

exception
   when others then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'Error while executing upd_list_header_info. '||sqlcode||'  '||sqlerrm;
      x_msg_count     := 1;
end upd_list_header_info;

END AMS_ListGeneration_PKG;

/
