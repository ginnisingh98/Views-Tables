--------------------------------------------------------
--  DDL for Package Body CN_GET_SRP_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GET_SRP_DATA_PVT" AS
  /*$Header: cnvsfgtb.pls 115.18.115100.3 2004/05/11 01:33:08 sbadami ship $*/

PROCEDURE Get_Srp_List
  (x_srp_data                   OUT NOCOPY    srp_data_tbl_type) IS

   CURSOR get_data IS
   select srp_id, name, emp_num from cn_srp_hr_data order by name;

   rownum      NUMBER := 0;

BEGIN
   for c in get_data loop
      rownum := rownum + 1;
      x_srp_data(rownum).srp_id  := c.srp_id;
      x_srp_data(rownum).name    := c.name;
      x_srp_data(rownum).emp_num := c.emp_num;
   end loop;
END Get_Srp_List;

PROCEDURE Search_Srp_Data
  (p_range_low                  IN     NUMBER,
   p_range_high                 IN     NUMBER,
   p_date                       IN     DATE,
   p_search_name                IN     VARCHAR2 := '%',
   p_search_job                 IN     VARCHAR2 := '%',
   p_search_emp_num             IN     VARCHAR2 := '%',
   p_search_group               IN     VARCHAR2 := '%',
   p_order_by                   IN     NUMBER   := 1,
   p_order_dir                  IN     VARCHAR2 := 'ASC',
   x_total_rows                 OUT NOCOPY    NUMBER,
   x_srp_data                   OUT NOCOPY    srp_data_tbl_type) IS

   TYPE rc IS ref cursor;

   query   VARCHAR2(4000) := '
   select distinct
          s.srp_id             srp_id,
          s.name               name,
          s.emp_num            emp_num,
          s.start_date         start_date,
          s.end_date           end_date,
          s.cost_center        cost_center,
          sg.group_id          comp_group_id,
          c.group_name         comp_group_name,
          j.job_id             job_code,
          j.name               job_title,
          srd.job_discretion   disc_job_title,
          -- sr.role_id          role_id,
          -- null                role_name
          1                    role_id,
          ''A''                role_name
     from cn_srp_hr_data       s,
          cn_srp_role_dtls     srd,
          cn_srp_roles         sr,
          per_jobs             j,
          jtf_rs_group_members sg,
          jtf_rs_groups_tl     c,
          jtf_rs_group_usages  u,
          jtf_rs_role_relations rr2
    where s.srp_id           = sr.salesrep_id
      and sr.srp_role_id     = srd.srp_role_id
      and srd.job_title_id   = j.job_id (+)
      and s.resource_id      = sg.resource_id
      and sg.group_id        = c.group_id
      and c.language = userenv(''LANG'')
      and u.group_id = c.group_id
      and rr2.role_resource_id = sg.group_member_id
      and rr2.role_resource_type = ''RS_GROUP_MEMBER''
      and rr2.role_id = sr.role_id
      and rr2.delete_flag = ''N''
      and sg.delete_flag = ''N''
      and u.usage = ''SF_PLANNING''';

   cursor get_job_code (l_job_title_id in number) is
   select job_code
     from cn_job_titles
    where job_title_id = l_job_title_id;

   rec            srp_data_rec_type;
   l_index        NUMBER := 0;
   query_cur      rc;
   l_name         VARCHAR2(241) := upper(p_search_name)    || '%';
   l_emp_num      VARCHAR2(31)  := upper(p_search_emp_num) || '%';

BEGIN
   x_total_rows   := 0;

   if (p_search_name <> '%') then
      query := query || ' and upper(s.name) like :1';
    else
      query := query || ' and :1 is not null'; -- dummy to get past :1
   end if;

   if (p_search_emp_num <> '%') then
      query := query || ' and upper(s.emp_num) like :2';
    else
      query := query || ' and :2 is not null';
   end if;

   if (p_search_job <> '%') then
      query := query || ' and j.job_id = :3';
    else
      query := query || ' and :3 is not null';
   end if;

   if (p_search_group <> '%') then
      query := query || ' and c.group_id = :4';
    else
      query := query || ' and :4 is not null';
   end if;

   query := query || ' and :5 between rr2.start_date_active and' ||
                                ' nvl(rr2.end_date_active, :6)' || 'and (:7 between sr.start_date and nvl(sr.end_date,:8))';

   -- order by clause
   query := query || ' order by ' || p_order_by || ' ' || p_order_dir;

   open query_cur for query using l_name, l_emp_num, p_search_job,
                                  p_search_group, p_date, p_date,p_date,p_date;
   loop
      fetch query_cur into rec;
      exit when query_cur%notfound;

      x_total_rows := x_total_rows + 1;
      if x_total_rows between p_range_low and p_range_high then
	 l_index := l_index + 1;
	 x_srp_data(l_index).srp_id         := rec.srp_id;
	 x_srp_data(l_index).name           := rec.name;
	 x_srp_data(l_index).emp_num        := rec.emp_num;
	 x_srp_data(l_index).job_title      := rec.job_title;
	 x_srp_data(l_index).disc_job_title := rec.disc_job_title;
	 x_srp_data(l_index).comp_group_id  := rec.comp_group_id;
	 x_srp_data(l_index).comp_group_name:= rec.comp_group_name;

	 -- get job_code
	 open  get_job_code(rec.job_code);
	 fetch get_job_code into x_srp_data(l_index).job_code;
	 close get_job_code;

      end if;
   end loop;
   close query_cur;

END Search_Srp_Data;

PROCEDURE Get_Srp_Data
  (p_srp_id                     IN     NUMBER,
   x_srp_data                   OUT NOCOPY    srp_data_tbl_type) IS

   CURSOR c is
   select s.srp_id,
	  s.name,
	  s.emp_num,
	  s.start_date,
	  s.end_date,
	  s.cost_center,
          null comp_group_name, null comp_group_id,
          null job_code, null job_title, null disc_job_title,
          null role_id,  null role_name  --recycle rec type
     from cn_srp_hr_data    s
    where s.srp_id = p_srp_id;
BEGIN
   open  c;
   fetch c into x_srp_data(1);
   close c;
END;

PROCEDURE Get_Managers
  (p_srp_id                     IN     NUMBER,
   p_date                       IN     DATE,
   p_comp_group_id              IN     NUMBER,
   x_srp_data                   OUT NOCOPY    srp_data_tbl_type) IS

   g_end_of_time                DATE := to_date('12/31/9999', 'MM/DD/YYYY');

   -- working variables
   l_fy_start_date              DATE;
   l_cg_start_date              DATE;
   l_cg_end_date                DATE;
   l_mgr_assign_start           DATE;
   l_mgr_assign_end             DATE;
   l_manager_flag               VARCHAR2(1);
   l_rownum                     NUMBER := 0;

   cursor get_fy_start_date is
   select min(p2.start_date)
     from cn_period_statuses p1,
          cn_period_statuses p2
    where p_date between p1.start_date and p1.end_date
      and p1.period_year = p2.period_year;

   cursor get_srp_group_info is
   select manager_flag, start_date_active,
	  nvl(end_date_active, g_end_of_time) end_date_active
     from cn_qm_mgr_srp_groups
    where srp_id = p_srp_id and comp_group_id = p_comp_group_id;

   cursor get_group_members (l_comp_group_id in number) is
   select sg.role_id, sg.role_name, sg.start_date_active, sg.group_name,
          nvl(sg.end_date_active, g_end_of_time) end_date_active,
          sg.srp_id, sd.name srp_name, sd.emp_num, sg.manager_flag,
          decode(sg.manager_flag, 'Y', sd.name || ' *', sd.name) ast_name
     from cn_qm_mgr_srp_groups sg, cn_srp_hr_data sd
    where sg.comp_group_id = l_comp_group_id and sg.srp_id = sd.srp_id;

   cursor get_parent_groups is
   select parent_comp_group_id, start_date_active,
          nvl(end_date_active, g_end_of_time) end_date_active
     from cn_qm_group_hier
    where comp_group_id = p_comp_group_id;

BEGIN
   -- get information of current srp comp_group assignment
   open  get_srp_group_info;
   fetch get_srp_group_info into l_manager_flag, l_cg_start_date,l_cg_end_date;
   close get_srp_group_info;

   -- get date range we are interested in for this query
   -- (beginning of current FY until p_date)
   open  get_fy_start_date;
   fetch get_fy_start_date into l_fy_start_date;
   close get_fy_start_date;

   -- if the current srp_id is a salesrep in its group, add its own
   -- group's manager to mgr list if it exists.  if it exists, indicate
   -- with (*) and don't fetch higher managers
   if l_manager_flag = 'N' then
      for pgm in get_group_members(p_comp_group_id) loop
	 -- make sure this group_member is a manager
	 if pgm.manager_flag = 'Y' then
	    -- check date range intersections
	    -- we want (current group assign dates) int
	    -- (parent member assign dates)
	    l_mgr_assign_start := greatest(l_cg_start_date,
					   pgm.start_date_active);
	    l_mgr_assign_end   :=    least(l_cg_end_date,
					   pgm.end_date_active);
	    -- if date range exists (start <= end) and it intersects current
	    -- date interval then insert into result tbl
	    if (l_mgr_assign_start <= l_mgr_assign_end AND
		greatest(l_mgr_assign_start, l_fy_start_date) <=
		least   (l_mgr_assign_end,   p_date)) then
	       -- realize that g_end_of_time is really null
	       if l_mgr_assign_end = g_end_of_time then
		  l_mgr_assign_end := null;
	       end if;
	       l_rownum := l_rownum + 1;
	       x_srp_data(l_rownum).srp_id          := pgm.srp_id;
	       x_srp_data(l_rownum).name            := pgm.ast_name;
	       x_srp_data(l_rownum).emp_num         := pgm.emp_num;
	       x_srp_data(l_rownum).start_date      := l_mgr_assign_start;
	       x_srp_data(l_rownum).end_date        := l_mgr_assign_end;
	       x_srp_data(l_rownum).comp_group_id   := p_comp_group_id;
	       x_srp_data(l_rownum).comp_group_name := pgm.group_name;
	       x_srp_data(l_rownum).role_id         := pgm.role_id;
	       x_srp_data(l_rownum).role_name       := pgm.role_name;
	    end if;
	 end if;
      end loop;
   end if;

   -- get info about members of parent groups and add it to result table
   -- if salesrep doesn't already have a manger
   if l_rownum = 0 then
   for pg in get_parent_groups loop
      -- for each parent group, get its members
      for pgm in get_group_members(pg.parent_comp_group_id) loop
	 -- check date range intersections
	 -- we want (current group assign dates) int
	 -- (dates on hierarchy edge) int (parent group assign dates)
	 l_mgr_assign_start := greatest(l_cg_start_date,
					pg.start_date_active,
					pgm.start_date_active);
	 l_mgr_assign_end   :=    least(l_cg_end_date,
					pg.end_date_active,
					pgm.end_date_active);
	 -- if date range exists (start <= end) and it intersects current
	 -- date interval then insert into result tbl
	 if (l_mgr_assign_start <= l_mgr_assign_end AND
	     greatest(l_mgr_assign_start, l_fy_start_date) <=
  	     least   (l_mgr_assign_end,   p_date)) then
	    -- realize that g_end_of_time is really null
	    if l_mgr_assign_end = g_end_of_time then
	       l_mgr_assign_end := null;
	    end if;
	    l_rownum := l_rownum + 1;
	    x_srp_data(l_rownum).srp_id          := pgm.srp_id;
	    x_srp_data(l_rownum).name            := pgm.ast_name;
	    x_srp_data(l_rownum).emp_num         := pgm.emp_num;
	    x_srp_data(l_rownum).start_date      := l_mgr_assign_start;
	    x_srp_data(l_rownum).end_date        := l_mgr_assign_end;
	    x_srp_data(l_rownum).comp_group_id   := pg.parent_comp_group_id;
	    x_srp_data(l_rownum).comp_group_name := pgm.group_name;
	    x_srp_data(l_rownum).role_id         := pgm.role_id;
	    x_srp_data(l_rownum).role_name       := pgm.role_name;
	 end if;
      end loop;
   end loop;
   end if;

END Get_Managers;

END CN_GET_SRP_DATA_PVT;


/
