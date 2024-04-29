--------------------------------------------------------
--  DDL for Package Body AMS_LIST_OPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_OPTIONS_PVT" AS
/* $Header: amsvlopb.pls 120.6 2005/12/21 01:43 bmuthukr noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_List_Options_Pvt
-- Purpose
--  Created to move all the code related to optional processes
--  like random list generation, suppression, max size restriction
--  control group generation from the list generation engine code.
-- History
--   Created bmuthukr 19-Jul-2005.
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_LIST_OPTIONS_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvlopb.pls';

CURSOR c_get_header_info(p_list_header_id in number) IS
SELECT *
  FROM ams_list_headers_all
 WHERE list_header_id = p_list_header_id;

CURSOR c_get_count (p_list_header_id IN number ) is
SELECT count(1)
  FROM ams_list_entries
 WHERE list_header_id = p_list_header_id
   AND enabled_flag = 'Y';

TYPE g_entries_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_list_entries_id            g_entries_table_type ;
g_list_entry_count           number := 0;
g_list_header_info           c_get_header_info%ROWTYPE;
g_log_level                  varchar2(100) := null;
g_msg_tbl                    g_msg_tbl_type;
g_count                      number := 0;

PROCEDURE WRITE_TO_ACT_LOG(p_msg_data in VARCHAR2,
                           p_arc_log_used_by in VARCHAR2 ,
                           p_log_used_by_id in  number,
                           p_level in varchar2 default 'LOW')
                           IS

BEGIN
   if g_log_level is not null then       -- for remote no logging will be done..
      if g_log_level = 'HIGH' and p_level = 'LOW' then
         return;
      end if;
      g_msg_tbl(g_count) := p_msg_data;
      g_count := g_count + 1;
   else
      --Not doing anything for logging messages from remote DB for now. Will do it later.
      null;
   end if;

exception
   when others then
      null; --will add later if reqd..
END WRITE_TO_ACT_LOG;

PROCEDURE CG_Gen_Process(errbuf             OUT NOCOPY VARCHAR2,
                         retcode            OUT NOCOPY VARCHAR2,
			 p_list_header_id   IN NUMBER
                         ) is

X_RETURN_STATUS VARCHAR2(1);
X_MSG_COUNT NUMBER;
X_MSG_DATA VARCHAR2(200);
x_ctrl_grp_status varchar2(100);
begin

   Control_Group_Generation(p_list_header_id => to_number(p_list_header_id),
	    	            p_log_level => 'LOW',
		            x_ctrl_grp_status => x_ctrl_grp_status,
		            x_return_status => x_return_status ,
                            x_msg_count => x_return_status,
                            x_msg_data => x_msg_data);
   commit;

end;


PROCEDURE Control_Group_Generation(
                  p_list_header_id  IN  NUMBER,
  	          p_log_level       IN  varchar2 DEFAULT NULL,
	          p_msg_tbl         OUT NOCOPY AMS_LIST_OPTIONS_PVT.G_MSG_TBL_TYPE,
		  x_ctrl_grp_status OUT NOCOPY VARCHAR2,
		  x_return_status   OUT NOCOPY VARCHAR2,
                  x_msg_count       OUT NOCOPY NUMBER,
                  x_msg_data        OUT NOCOPY VARCHAR2) IS

begin
   g_log_level := p_log_level;

   Control_Group_Generation(p_list_header_id => p_list_header_id,
	    	            p_log_level => g_log_level,
		            x_ctrl_grp_status => x_ctrl_grp_status,
		            x_return_status => x_return_status ,
                            x_msg_count => x_return_status,
                            x_msg_data => x_msg_data);
   commit;
   p_msg_tbl := g_msg_tbl;
   g_msg_tbl.delete;
exception
   when others then
      write_to_act_log('Error while executing control_group_generation '||sqlcode||'  '||sqlerrm,'LIST',p_list_header_id,'LOW');
      x_msg_data := 'Error while executing control_group_generation '||sqlcode||'  '||sqlerrm;
      x_return_status := 'E';
end;

PROCEDURE Control_Group_Generation(
                  p_list_header_id  IN  NUMBER,
  	          p_log_level       IN  varchar2 DEFAULT NULL,
		  x_ctrl_grp_status OUT NOCOPY VARCHAR2,
		  x_return_status   OUT NOCOPY VARCHAR2,
                  x_msg_count       OUT NOCOPY NUMBER,
                  x_msg_data        OUT NOCOPY VARCHAR2)
		  IS

l_total_random_rows                number := 0;

CURSOR c_list_entries (p_list_header_id IN number ) is
SELECT list_entry_id
  FROM ams_list_entries
 WHERE list_header_id = p_list_header_id
   AND enabled_flag  = 'Y'
ORDER BY randomly_generated_number ;

/*cursor c_status_id(p_status_code in varchar2) is
select user_status_id
from ams_user_Statuses_vl
where system_status_code = p_status_code
  and system_status_type = 'AMS_LIST_STATUS';*/

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
l_TCA_FAILED_RECORDS	number;
l_status_id             number;
cursor c_count_list_entries(p_list_header_id in number) is
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
where list_header_id = p_list_header_id ;

l_sample_size    number := 0;
l_status         varchar2(100);
l_rows           number := 0;
l_sc             varchar2(100);
l_status_code    varchar2(100) := null;

BEGIN
   g_log_level := p_log_level;

   -- fnd_file.put(1, 'Started control group generation procedure.');
   -- fnd_file.new_line(1,1);
   x_return_status := 'S';

   open c_get_header_info(p_list_header_id);
   fetch c_get_header_info into g_list_header_info;
   close c_get_header_info;

   if g_list_header_info.status_code_old is not null then
      l_status_code := g_list_header_info.status_code_old;
   else
      l_status_code := g_list_header_info.status_code;
   end if;

   /*open c_status_id(l_status_code);
   fetch c_status_id into l_status_id;
   close c_status_id;*/

   if l_status_code = 'DRAFT' then
      l_status_id := 300;
   elsif l_status_code = 'AVAILABLE' then
      l_status_id := 303;
   elsif l_status_code = 'GENERATING' then
      l_status_id := 302;
   elsif l_status_code = 'FAILED' then
      l_status_id := 311;
   elsif l_status_code = 'SCHEDULED' then
      l_status_id := 301;
   elsif l_status_code = 'ARCHIVED' then
      l_status_id := 306;
   elsif l_status_code = 'LOCKED' then
      l_status_id := 304;
   end if;

   update ams_list_entries  -- need this when the CG is generated seperately..
      set part_of_control_group_flag = 'N',
          enabled_flag = 'Y'
    where part_of_control_group_flag = 'Y'
      and enabled_flag = 'N'
      and list_header_id = p_list_header_id;

   if nvl(g_list_header_info.ctrl_gen_mode,'NONE') = 'NONE' then
      write_to_act_log('CG option not selected.','LIST',p_list_header_id,'LOW');
   else
      write_to_act_log('Executing procedure control group generation.','LIST',p_list_header_id,'LOW');

      open c_get_count(p_list_header_id);
      fetch c_get_count into g_list_entry_count;
      close c_get_count;

      write_to_act_log(g_list_entry_count ||' are there in the list for control group generation','LIST',p_list_header_id,'LOW');

      if nvl(g_list_header_info.ctrl_gen_mode,'NONE') = 'DEFBYCNT' then

         l_total_random_rows  := nvl(g_list_header_info.ctrl_random_nth_row_selection,0);
         write_to_act_log('Control group generation option is count. No of rows to be made part of control group is '||l_total_random_rows,'LIST',p_list_header_id,'LOW');

      elsif nvl(g_list_header_info.ctrl_gen_mode,'NONE') = 'DEFBYPCT' then

         write_to_act_log('Control group generation option is percentage. % of rows to be made part of control group is '||g_list_header_info.ctrl_random_pct_row_selection,'LIST',p_list_header_id,'LOW');
         l_total_random_rows  := floor((g_list_entry_count * nvl(g_list_header_info.ctrl_random_pct_row_selection,0)) / 100);
         write_to_act_log('No of rows to be made part of control group is '||l_total_random_rows,'LIST',p_list_header_id,'LOW');

      elsif nvl(g_list_header_info.ctrl_gen_mode,'NONE') = 'DEFBYSAM' then

         l_sample_size := (power(g_list_header_info.ctrl_conf_level,2) * g_list_header_info.ctrl_req_resp_rate * (100 - g_list_header_info.ctrl_req_resp_rate))/(power(g_list_header_info.ctrl_limit_of_error,2));
         write_to_act_log('Control group generation option is statistical formula. Sample size of the control group is '||l_sample_size,'LIST',p_list_header_id,'LOW');
         l_total_random_rows  := l_sample_size/(1+((l_sample_size-1)/g_list_entry_count));
         write_to_act_log('No of rows to be made part of control group is '||l_total_random_rows,'LIST',p_list_header_id,'LOW');

      end if;

      write_to_act_log('Total no of rows to be made part of control group is ' || to_char(l_total_random_rows), 'LIST', p_list_header_id,'LOW');

      DBMS_RANDOM.initialize (TO_NUMBER (TO_CHAR (SYSDATE, 'SSSSDD')));

      UPDATE ams_list_entries
         SET randomly_generated_number = DBMS_RANDOM.random
       WHERE list_header_id  = p_list_header_id
         AND enabled_flag = 'Y';

      write_to_act_log('Randomly generated number assigned to '||sql%rowcount||' entries','LIST',p_list_header_id,'LOW');

      DBMS_RANDOM.terminate;

      if nvl(l_total_random_rows,0) > 0 then
         OPEN c_list_entries (p_list_header_id);
         FETCH c_list_entries BULK COLLECT INTO g_list_entries_id LIMIT l_total_random_rows;
         CLOSE c_list_entries;

         FORALL i in g_list_entries_id.FIRST .. g_list_entries_id.LAST
         UPDATE ams_list_entries
            SET part_of_control_group_flag = 'Y',
                enabled_flag = 'N'
          WHERE list_header_id  = p_list_header_id
            AND list_entry_id   = g_list_entries_id(i);
         write_to_act_log(sql%rowcount||' entries made part of the control group for this target group.', 'LIST', p_list_header_id,'HIGH');
      else
         write_to_act_log('0 entries made part of the control group for this target group.', 'LIST', p_list_header_id,'HIGH');
      end if;
   end if;

   open c_count_list_entries(p_list_header_id);
   fetch c_count_list_entries
    into l_no_of_rows_active            ,
         l_no_of_rows_inactive          ,
         l_no_of_rows_in_list           ,
         l_no_of_rows_in_ctrl_group     ,
         l_no_of_rows_random            ,
         l_no_of_rows_duplicates        ,
         l_no_of_rows_manually_entered  ,
         l_no_of_rows_suppressed        ,
         l_no_of_rows_fatigued          ,
         l_TCA_FAILED_RECORDS;
   close c_count_list_entries;

   update ams_list_headers_all
      set no_of_rows_in_list           = nvl(l_no_of_rows_in_list,0),
          no_of_rows_active            = nvl(l_no_of_rows_active,0),
          no_of_rows_inactive          = nvl(l_no_of_rows_inactive,0),
          no_of_rows_in_ctrl_group     = nvl(l_no_of_rows_in_ctrl_group,0),
          no_of_rows_random            = nvl(l_no_of_rows_random,0),
          no_of_rows_duplicates        = nvl(l_no_of_rows_duplicates,0),
          no_of_rows_manually_entered  = nvl(l_no_of_rows_manually_entered,0),
          no_of_rows_suppressed        = nvl(l_no_of_rows_suppressed,0),
          no_of_rows_fatigued          = nvl(l_no_of_rows_fatigued,0),
          tca_failed_records           = nvl(l_TCA_FAILED_RECORDS,0),
          ctrl_status_code = decode(ctrl_gen_mode,'NONE','DRAFT','AVAILABLE'),
          status_code = nvl(status_code_old,status_code),
          last_update_date = sysdate,
	  user_status_id = l_status_id
    where list_header_id = p_list_header_id;

   update ams_list_headers_all
      set status_code_old = null
    where list_header_id = p_list_header_id;

   -- Bug 4615797. bmuthukr. Need to update the ctrl grp cnt if cg size < cnt given.
   if nvl(g_list_header_info.ctrl_gen_mode,'NONE') = 'DEFBYCNT' and nvl(g_list_header_info.ctrl_random_nth_row_selection,0) > 0 then
      if nvl(l_no_of_rows_in_ctrl_group,0) < nvl(g_list_header_info.ctrl_random_nth_row_selection,0) then
         write_to_act_log('Resetting the control group count to '||l_no_of_rows_in_ctrl_group||' since the given CG size is higher than actual size.', 'LIST', p_list_header_id,'HIGH');
         update ams_list_headers_all
            set ctrl_random_nth_row_selection = l_no_of_rows_in_ctrl_group
          where list_header_id = p_list_header_id;
      end if;
   end if;


  --  COMMIT;

exception
   when others then
      update ams_list_headers_all
         set ctrl_status_code = 'FAILED',
             status_code = nvl(status_code_old,status_code),
             last_update_date = sysdate,
             user_status_id = l_status_id
       where list_header_id = p_list_header_id;

      write_to_act_log(p_msg_data => 'Error while executing control_group_generation procedure '||sqlcode||'  '||sqlerrm,
                       p_arc_log_used_by => 'LIST',
                       p_log_used_by_id  => p_list_header_id,
		       p_level=>'HIGH');
      x_msg_count := 1;
      x_msg_data := 'Error during CG generation'||' '|| sqlcode || '-->'||sqlerrm;
      x_return_status  :=  'E'; --  FND_API.G_RET_STS_ERROR ;

END Control_Group_Generation;

PROCEDURE random_list_entries (p_list_header_id in number,
                               x_return_status  out nocopy varchar2,
			       x_msg_count      out nocopy number,
                               x_msg_data       out nocopy varchar2) IS

CURSOR c_list_entries (p_list_header_id IN number ) is
SELECT list_entry_id
  FROM ams_list_entries
 WHERE list_header_id = p_list_header_id
   AND marked_as_random_flag = 'Y'
   AND enabled_flag  = 'N'
ORDER BY randomly_generated_number ;

l_total_random_rows    number := 0;

BEGIN
   write_to_act_log('Random list generation started', 'LIST', p_list_header_id,'LOW');

   x_return_status := 'S';

   open c_get_header_info(p_list_header_id);
   fetch c_get_header_info into g_list_header_info;
   close c_get_header_info;

   open c_get_count(p_list_header_id);
   fetch c_get_count into g_list_entry_count;
   close c_get_count;

   write_to_act_log(g_list_header_info.main_random_pct_row_selection||' % of rows to be generated randomly ','LIST',p_list_header_id,'LOW');
   write_to_act_log(g_list_entry_count ||' are there in the list for random list generation','LIST',p_list_header_id,'LOW');

   if nvl(g_list_header_info.main_random_pct_row_selection,0) between 1 and 100 then
      l_total_random_rows  := FLOOR ((g_list_entry_count * g_list_header_info.main_random_pct_row_selection) / 100);
   else
      write_to_act_log('Random % should be between 1 and 100. Could nt generate randomly. ' || to_char(l_total_random_rows), 'LIST', p_list_header_id,'HIGH');
   end if;

   write_to_act_log('Total no of rows to be generated randomly is ' || to_char(l_total_random_rows), 'LIST', p_list_header_id,'LOW');

   DBMS_RANDOM.initialize (TO_NUMBER (TO_CHAR (SYSDATE, 'SSSSDD')));

   UPDATE ams_list_entries
      SET randomly_generated_number = DBMS_RANDOM.random,
          marked_as_random_flag = 'Y',
          enabled_flag = 'N'
    WHERE list_header_id  = p_list_header_id
      AND enabled_flag = 'Y';
   write_to_act_log('Randomly generated number assigned to '||sql%rowcount||' list entries','LIST',p_list_header_id,'LOW');

   DBMS_RANDOM.terminate;

   OPEN c_list_entries (p_list_header_id);
   FETCH c_list_entries BULK COLLECT INTO g_list_entries_id LIMIT l_total_random_rows;
   CLOSE c_list_entries;

   FORALL i in g_list_entries_id.FIRST .. g_list_entries_id.LAST
      UPDATE ams_list_entries
         SET marked_as_random_flag = 'Y',
             enabled_flag = 'Y'
       WHERE list_header_id  = g_list_header_info.list_header_id
         AND list_entry_id   = g_list_entries_id(i);
   write_to_act_log(sql%rowcount||' entries generated randomly for this list', 'LIST', p_list_header_id,'HIGH');
   write_to_act_log('Procedure random_list_entries executed successfully. ','LIST', p_list_header_id,'LOW');
exception
   when others then
      write_to_act_log('Error occurred while generating entries randomly ' || sqlerrm , 'LIST', p_list_header_id,'HIGH');
      x_msg_count := 1;
      x_msg_data := 'Error during random list generation'||' '|| sqlcode || '-->'||sqlerrm;
      x_return_status := 'E';
END random_list_entries;

PROCEDURE CHECK_MAX_ENTRIES_DIST_PCT
          (p_list_header_id in number,
           x_return_status  out nocopy varchar2,
	   x_msg_count      out nocopy number,
           x_msg_data       out nocopy varchar2) is

   l_sel_excess        number := 0;

  -- need to consider only the entries from ams_list_entries..no need to be specific about the selections.
  CURSOR c_list_entries is
  SELECT e.list_entry_id
    FROM ams_list_entries e
   WHERE e.list_header_id = p_list_header_id
     AND e.enabled_flag ='Y';

BEGIN

   x_return_status := 'S';

   open c_get_header_info(p_list_header_id);
   fetch c_get_header_info into g_list_header_info;
   close c_get_header_info;

   open c_get_count(p_list_header_id);
   fetch c_get_count into g_list_entry_count;
   close c_get_count;

   write_to_act_log('Executing procedure check_max_entries_dist_pct to restrict list size based on max size','LIST', p_list_header_id, 'LOW');
   write_to_act_log('No of enabled entries is ' || g_list_entry_count , 'LIST', p_list_header_id, 'LOW');

   if (nvl(g_list_header_info.no_of_rows_max_requested,0)  > 0 )  then -- already the row selection type is set to MAX.
      if (g_list_entry_count  <= g_list_header_info.no_of_rows_max_requested) then
         write_to_act_log('No of max entries specified is greater than or equal to the no of available entries. No need to reduce the size.'
			, 'LIST', p_list_header_id, 'HIGH');
      else
         l_sel_excess := g_list_entry_count  - g_list_header_info.no_of_rows_max_requested;
         open c_list_entries;
         fetch c_list_entries bulk collect into g_list_entries_id limit l_sel_excess ;
         close c_list_entries;
         FORALL i in g_list_entries_id.FIRST .. g_list_entries_id.LAST
         UPDATE ams_list_entries
            SET enabled_flag = 'N'
          WHERE list_header_id  = p_list_header_id
            AND list_entry_id   = g_list_entries_id(i);
         write_to_act_log(sql%rowcount||' entries disabled to restrict list size.' , 'LIST', p_list_header_id, 'HIGH');
      end if;
   end if;
   write_to_act_log('Procedure check_max_entries_dist_pct executed.', 'LIST', p_list_header_id, 'HIGH');

EXCEPTION
   WHEN OTHERS THEN
    write_to_act_log('Error while executing procedure check_max_entries_dist_pct '||sqlcode||'   '||sqlerrm, 'LIST', p_list_header_id,'HIGH');
      x_msg_count := 1;
      x_msg_data := 'Error during executing max size restriction procedure. '||' '|| sqlcode || '-->'||sqlerrm;
      x_return_status := 'E';
END CHECK_MAX_ENTRIES_DIST_PCT;

procedure apply_size_reduction
             (p_list_header_id     IN  number,
	      p_log_level          IN  varchar2 DEFAULT NULL,
	      p_msg_tbl            OUT NOCOPY AMS_LIST_OPTIONS_PVT.G_MSG_TBL_TYPE,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2) is

BEGIN
   g_log_level := p_log_level;

   apply_size_reduction(p_list_header_id => p_list_header_id,
                        p_log_level => g_log_level,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data);

   p_msg_tbl := g_msg_tbl;
   g_msg_tbl.delete;
END;

procedure apply_size_reduction
             (p_list_header_id     IN  number,
	      p_log_level          IN  varchar2 DEFAULT NULL,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2) is

-- Added by bmuthukr to honor size reduction based on RANDOM/MAX
-- options in R12. since this would be applicable for both
-- list and target group, we will have this procedure and from
-- here either random/max procedure will be called.
-- this proc will be called from both generate_list and
-- generate_target_group procedures.

l_null_c varchar2(100) := null;
l_null_n number := null;

begin
   g_log_level := p_log_level;

   write_to_act_log('Executing procedure apply_size_reduction ','LIST',p_list_header_id,'LOW');

   open c_get_header_info(p_list_header_id);
   fetch c_get_header_info into g_list_header_info;
   close c_get_header_info;


   if nvl(g_list_header_info.row_selection_type,'x') = 'MAX' then
      write_to_act_log('Max size option chosen for size reduction','LIST',p_list_header_id,'LOW');
      --call max
      check_max_entries_dist_pct(p_list_header_id => p_list_header_id,
                                 x_return_status  => x_return_status,
				 x_msg_count      => x_msg_count,
                                 x_msg_data       => x_msg_data);

   elsif nvl(g_list_header_info.row_selection_type,'x') = 'RANDOM' then
      write_to_act_log('Random % option chosen for size reduction','LIST',p_list_header_id,'LOW');
      --call random
      random_list_entries(p_list_header_id => p_list_header_id,
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data);
   elsif nvl(g_list_header_info.row_selection_type,'x') = 'STANDARD' then
      write_to_act_log('All records option chosen. Hence not restricting the size.','LIST',p_list_header_id,'LOW');
   end if;

   if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
      write_to_act_log('Error in generating list entries randomly in remote instance.', 'LIST', p_list_header_id,'HIGH');
      write_to_act_log('Error '||x_msg_data , 'LIST', p_list_header_id,'HIGH');
   elsif nvl(x_return_status,'S') = 'S' then
      write_to_act_log('Size restriction procedure executed successfully.', 'LIST', p_list_header_id,'HIGH');
   end if;

exception
   when others then
      write_to_act_log('Error while executing procedure apply_size_reduction '||sqlcode||'   '||sqlerrm,'LIST',p_list_header_id,'HIGH');
      x_return_status := 'E';
      x_msg_data := 'Error while executing procedure apply_size_reduction '||sqlcode||'  '||sqlerrm;
      x_msg_count := 1;
end apply_size_reduction;

END AMS_List_Options_Pvt;

/
