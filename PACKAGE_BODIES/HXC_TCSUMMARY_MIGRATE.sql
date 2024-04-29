--------------------------------------------------------
--  DDL for Package Body HXC_TCSUMMARY_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TCSUMMARY_MIGRATE" as
  /* $Header: hxcsummig.pkb 120.7 2007/07/13 09:27:29 asrajago noship $ */

  procedure delete_timecards is

    cursor c_timecards is
      select ts.timecard_id
            ,ts.timecard_ovn
      from   hxc_timecard_summary ts
      where  not exists (select 'Y'
              from   hxc_time_building_blocks tbb
              where  tbb.time_building_block_id = ts.timecard_id and
                     tbb.object_version_number = ts.timecard_ovn and
                     tbb.scope = 'TIMECARD' and
                     tbb.date_to = hr_general.end_of_time);

    cursor c_deleted_timecards is
      select ts.timecard_id
            ,ts.timecard_ovn
      from   hxc_timecard_summary ts
      where  exists (select 'Y'
              from   hxc_time_building_blocks tbb
              where  tbb.time_building_block_id = ts.timecard_id and
                     tbb.object_version_number = ts.timecard_ovn and
                     tbb.scope = 'TIMECARD' and
                     tbb.date_to <> hr_general.end_of_time);


    l_blocks hxc_block_table_type;

  Begin

    for timecard_rec in c_timecards loop

      hxc_timecard_summary_api.delete_timecard(timecard_rec.timecard_id);

    end loop;

    for timecard_rec in c_deleted_timecards loop

      hxc_timecard_summary_api.delete_timecard(timecard_rec.timecard_id);

    end loop;

  End delete_timecards;

  procedure delete_templates is

    cursor c_templates is
      select ts.template_id
            ,ts.template_ovn
      from   hxc_template_summary ts
      where  not exists (select 'Y'
              from   hxc_time_building_blocks tbb
              where  tbb.time_building_block_id = ts.template_id and
                     tbb.object_version_number = ts.template_ovn and
                     tbb.scope = 'TIMECARD_TEMPLATE' and
                     tbb.date_to = hr_general.end_of_time);

    cursor c_deleted_templates is
      select ts.template_id
            ,ts.template_ovn
      from   hxc_template_summary ts
      where  exists (select 'Y'
              from   hxc_time_building_blocks tbb
              where  tbb.time_building_block_id = ts.template_id and
                     tbb.object_version_number = ts.template_ovn and
                     tbb.scope = 'TIMECARD_TEMPLATE' and
                     tbb.date_to <> hr_general.end_of_time);

 --    l_blocks hxc_block_table_type;

Begin

    for template_rec in c_templates loop

      hxc_template_summary_api.delete_template(template_rec.template_id);

    end loop;

    for template_rec in c_deleted_templates loop

      hxc_template_summary_api.delete_template(template_rec.template_id);

    end loop;

End delete_templates;

procedure timecard_summary(p_resource_id in hxc_time_building_blocks.resource_id%type) is

    cursor c_timecards(p_rid in number) is
      select tbb.time_building_block_id
            ,tbb.object_version_number
      from   hxc_time_building_blocks tbb
      where  tbb.resource_id = p_rid and
             tbb.date_to = hr_general.end_of_time and
             tbb.scope = 'TIMECARD' and
             not exists
       (select 'Y'
              from   hxc_timecard_summary
              where  timecard_id = tbb.time_building_block_id and
                     timecard_ovn = tbb.object_version_number);

    l_blocks hxc_block_table_type;


  Begin

    for timecard_rec in c_timecards(p_resource_id) loop
	  hxc_timecard_summary_api.timecard_deposit
	  (p_timecard_id => timecard_rec.time_building_block_id
          ,p_mode        => hxc_timecard_summary_pkg.c_migration_mode
	  ,p_approval_item_type =>null
	  ,p_approval_process_name=> null
	  ,p_approval_item_key => null
	  ,p_tk_audit_item_type   => null
	  ,p_tk_audit_process_name => null
	  ,p_tk_audit_item_key     => null
	  );
    end loop;

  End timecard_summary;

procedure template_summary(p_resource_id in hxc_time_building_blocks.resource_id%type) is

    cursor c_templates(p_rid in number) is
      select tbb.time_building_block_id
            ,tbb.object_version_number
      from   hxc_time_building_blocks tbb
      where  tbb.resource_id = p_rid and
             tbb.date_to = hr_general.end_of_time and
             tbb.scope = 'TIMECARD_TEMPLATE'
	     and resource_id <>-1 and
             not exists
       (select 'Y'
              from   hxc_template_summary
              where  template_id = tbb.time_building_block_id and
                     template_ovn = tbb.object_version_number);

    l_blocks hxc_block_table_type;

  Begin

    for template_rec in c_templates(p_resource_id) loop
	  hxc_template_summary_api.template_deposit
	   (p_template_id => template_rec.time_building_block_id
           ,p_template_ovn =>template_rec.object_version_number
	  );
    end loop;

  End template_summary;

  Procedure application_period_summary(p_resource_id in hxc_time_building_blocks.resource_id%type) is


    type app_period_list is table of hxc_time_building_blocks.time_building_block_id%type;

    l_app_periods app_period_list;

    cursor c_app_periods(p_resource_id in hxc_time_building_blocks.resource_id%type) is
      select distinct tbb.time_building_block_id
      from   hxc_time_building_blocks  tbb
            ,hxc_time_attribute_usages tau
            ,hxc_time_attributes       ta
      where  tbb.scope = 'APPLICATION_PERIOD' and
             tbb.date_to = hr_general.end_of_time and
             tbb.resource_id = p_resource_id and
             tau.time_building_block_id = tbb.time_building_block_id and
             tau.time_building_block_ovn = tbb.object_version_number and
             ta.attribute_category = 'APPROVAL' and
             ta.time_attribute_id = tau.time_attribute_id and
             not exists
       (select 'Y'
              from   hxc_app_period_summary aps
              where  aps.application_period_id = tbb.time_building_block_id and
                     aps.application_period_ovn = tbb.object_version_number)
      order  by 1;

    l_index number := 1;

  Begin

    open c_app_periods(p_resource_id);
    fetch c_app_periods bulk collect
      into l_app_periods;
    close c_app_periods;

    l_index := l_app_periods.first;

    Loop
      Exit when not l_app_periods.exists(l_index);
      hxc_app_period_summary_api.app_period_create(l_app_periods(l_index)
                                                  ,hxc_timecard_summary_pkg.c_migration_mode);
      l_index := l_app_periods.next(l_index);
    end loop;

  End application_period_summary;


  procedure run_migration is

    cursor c_valid_resources is
      select distinct resource_id
      from   hxc_time_building_blocks tbb
      where  tbb.scope = 'TIMECARD' and
             tbb.date_to = hr_general.end_of_time and
             not exists
       (select 'Y'
              from   hxc_timecard_summary ts
              where  tbb.time_building_block_id = ts.timecard_id and
                     tbb.object_version_number = ts.timecard_ovn);

    cursor c_timecard_summary is
      select 1 from dual
      where exists ( select 'x' from hxc_timecard_summary);

   cursor c_template_summary is
      select 1 from dual
      where exists ( select 'x' from hxc_template_summary);

    cursor c_valid_template_resources is
      select distinct resource_id
      from   hxc_time_building_blocks tbb
      where  tbb.scope = 'TIMECARD_TEMPLATE' and
             tbb.date_to = hr_general.end_of_time and
             not exists
       (select 'Y'
              from   hxc_template_summary ts
              where  tbb.time_building_block_id = ts.template_id and
                     tbb.object_version_number = ts.template_ovn);
    l_dummy number;

    l_timecard_count number;

    l_timecard_found boolean;
    l_template_found boolean;

  begin

    l_timecard_found := false;
    l_template_found := false;

    -- even if there is a single record in hxc_timecard_summary, we are not going
    -- to allow the migration of timecards.
    open c_timecard_summary;
    fetch c_timecard_summary
      into l_dummy;

    if c_timecard_summary%found then
      close c_timecard_summary;
      l_timecard_found := true;
      --return;
    else
        close c_timecard_summary;
    end if;

     open c_template_summary;
    fetch c_template_summary
      into l_dummy;

    if c_template_summary%found then
      close c_template_summary;
      l_template_found := true;
      --return;
    else
        close c_template_summary;
    end if;

  if (l_timecard_found) and (l_template_found) then
	return;
  end if;

  if (l_timecard_found = false) then
    for resource_rec in c_valid_resources loop

      --
      -- 1. Create all the timecard summary information
      --
      timecard_summary(resource_rec.resource_id);

      --
      -- 2. Create all the application period summary information
      --    and populate other link tables.
      --
      application_period_summary(resource_rec.resource_id);


    end loop;

    --
    -- 3. Clean up summary tables if the migration has been run before
    --

    delete_timecards;
end if;

if (l_template_found = false) then

   for resource_rec in c_valid_template_resources loop

      --
      -- 1. Create all the template summary information
      --
      template_summary(resource_rec.resource_id);

    end loop;
    delete_templates;
end if;

end run_migration;


  function is_process_time_over(p_process_end_time in date) return boolean is
  begin
    if nvl(p_process_end_time, sysdate) < sysdate then
      return true;
    else
      return false;
    end if;
  end;

PROCEDURE update_appl_set_id(p_time_building_block_id in hxc_time_building_blocks.time_building_block_id%type
                                ,p_start_date        in date
                                ,p_end_date          in date
				,p_resource_id       in hxc_time_building_blocks.resource_id%type
				,p_object_version_number in hxc_time_building_blocks.object_version_number%type
                                ,p_upg_count         out nocopy number) IS

CURSOR C_Time_BB_Ids(p_Building_Block_Id number, p_Object_Version_Number number) is
      SELECT tbb1.time_building_block_id
            ,tbb1.object_version_number
            ,tbb1.scope
      FROM   hxc_time_building_blocks tbb1
      WHERE  scope IN ('TIMECARD', 'DAY', 'DETAIL') AND
             application_set_id IS NULL
      START  WITH ((tbb1.time_building_block_id = p_building_block_id) AND
                  (tbb1.object_version_number = p_object_version_number))
      CONNECT BY PRIOR tbb1.time_building_block_id =
                  tbb1.parent_building_block_id AND
                 PRIOR tbb1.object_version_number =
                  tbb1.parent_building_block_ovn;

    CURSOR C_get_Appl_Set_Id(p_rec_id number, p_start_time date, p_stop_time date) is
      SELECT a
      FROM   (SELECT application_set_id a
                    ,COUNT(*) cnt
              FROM   hxc_application_set_comps_v
              WHERE  time_recipient_id IN
                     (SELECT DISTINCT attribute1
                      FROM   hxc_time_attributes
                      WHERE  time_attribute_id IN
                             (SELECT time_attribute_id
                              FROM   hxc_time_attribute_usages
                              WHERE  time_building_block_id IN
                                     (SELECT htb2.time_building_block_id
                                      FROM   hxc_time_building_blocks htb2
                                      WHERE  htb2.scope = 'APPLICATION_PERIOD' AND
                                             htb2.resource_id = p_rec_id AND
                                             TRUNC(htb2.start_time) =
                                             p_start_time AND
                                             TRUNC(htb2.stop_time) =
                                             TRUNC(p_stop_time) AND
                                             htb2.object_version_number =
                                             (SELECT MAX(hb.object_version_number)
                                              FROM   hxc_time_building_blocks hb
                                              WHERE  hb.time_building_block_id =
                                                     htb2.time_building_block_id AND
                                                     hb.start_time =
                                                     htb2.start_time AND
                                                     hb.stop_time =
                                                     htb2.stop_time AND
                                                     hb.resource_id =
                                                     htb2.resource_id AND
                                                     hb.scope =
                                                     'APPLICATION_PERIOD'))) AND
                             attribute_category = 'APPROVAL')
              GROUP  BY application_set_id)
      WHERE  cnt =
             (SELECT COUNT(distinct attribute1)
              FROM   hxc_time_attributes
              WHERE  time_attribute_id IN
                     (SELECT time_attribute_id
                      FROM   hxc_time_attribute_usages
                      WHERE  time_building_block_id IN
                             (SELECT htb2.time_building_block_id
                              FROM   hxc_time_building_blocks htb2
                              WHERE  htb2.scope = 'APPLICATION_PERIOD' AND
                                     htb2.resource_id = p_rec_id AND
                                     TRUNC(htb2.start_time) = p_start_time AND
                                     TRUNC(htb2.stop_time) =
                                     TRUNC(p_stop_time) AND
                                     htb2.object_version_number =
                                     (SELECT MAX(hb.object_version_number)
                                      FROM   hxc_time_building_blocks hb
                                      WHERE  hb.time_building_block_id =
                                             htb2.time_building_block_id AND
                                             hb.start_time = htb2.start_time AND
                                             hb.stop_time = htb2.stop_time AND
                                             hb.resource_id = htb2.resource_id AND
                                             hb.scope = 'APPLICATION_PERIOD'))) AND
                     attribute_category = 'APPROVAL') AND
             a NOT IN
             (SELECT application_set_id a
              FROM   hxc_application_set_comps_v
              WHERE  time_recipient_id NOT IN
                     (SELECT DISTINCT attribute1
                      FROM   hxc_time_attributes
                      WHERE  time_attribute_id IN
                             (SELECT time_attribute_id
                              FROM   hxc_time_attribute_usages
                              WHERE  time_building_block_id IN
                                     (SELECT htb2.time_building_block_id
                                      FROM   hxc_time_building_blocks htb2
                                      WHERE  htb2.scope = 'APPLICATION_PERIOD' AND
                                             htb2.resource_id = p_rec_id AND
                                             TRUNC(htb2.start_time) =
                                             p_start_time AND
                                             TRUNC(htb2.stop_time) =
                                             TRUNC(p_stop_time) AND
                                             htb2.object_version_number =
                                             (SELECT MAX(hb.object_version_number)
                                              FROM   hxc_time_building_blocks hb
                                              WHERE  hb.time_building_block_id =
                                                     htb2.time_building_block_id AND
                                                     hb.start_time =
                                                     htb2.start_time AND
                                                     hb.stop_time =
                                                     htb2.stop_time AND
                                                     hb.resource_id =
                                                     htb2.resource_id AND
                                                     hb.scope =
                                                     'APPLICATION_PERIOD'))) AND
                             attribute_category = 'APPROVAL'));

    l_application_set_id hxc_time_building_blocks.APPLICATION_SET_ID%TYPE;
  Begin

	OPEN C_get_Appl_Set_Id(p_resource_id, p_start_date, p_end_date);
        FETCH C_get_Appl_Set_Id into l_application_set_id;
        CLOSE C_get_Appl_Set_Id;

        --
        -- Call to update the value in the table
        FOR C2 in C_Time_BB_Ids(p_time_building_block_id
                               ,p_object_version_number) LOOP

          BEGIN
            update hxc_time_building_blocks
            set    application_set_id = l_application_set_id
            where  time_building_block_id = C2.time_building_block_id and
                   object_version_number = C2.object_version_number;


            p_upg_count:=p_upg_count+1;

            IF (C2.scope = 'DETAIL') THEN

              BEGIN
                UPDATE hxc_latest_details hld
                SET    hld.application_set_id = l_application_set_id
                WHERE  hld.time_building_block_id =
                       C2.time_building_block_id AND
                       hld.object_version_number = C2.object_version_number;

              EXCEPTION
                WHEN OTHERS THEN
                  -- in case the DETAIL has not been upgraded
                  NULL;
              END;

            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              --dbms_output.put_line('Problematic IN UPD are = '||C2.time_building_block_id);
              raise;
          END;
        END LOOP;

      EXCEPTION
        -- Used to trap any exceptions that may occur due to BAD TIME CARDS
        -- in the system
        -- i.e. There may be resources for whom as of that effective date
        -- there does not exist any prefernece of Application Set ID
        -- An open issue as of now as to what needs to be done for such cases
        --
        -- The currnet code will just ignore such cases
        --
        WHEN OTHERS THEN
          --
          -- Increment the counter to check as to how many
          -- such cases exist in the system
          --ct:=ct+1;
          --
          -- Following will print the resource ids for the problematic TIMECARDS
          --
          -- dbms_output.put_line('Problematic Resources are = '||C1.RESOURCE_ID);
          raise;
  End update_appl_set_id;


PROCEDURE populate_appl_set_id(p_business_group_id in number default null
                                ,p_process_end_time  in date
                                ,p_start_date        in date
                                ,p_end_date          in date
                                ,p_upg_count         out nocopy number) IS

    CURSOR  C_Resource_Id is
      SELECT DISTINCT htb.time_building_block_id
                     ,htb.start_time
                     ,htb.stop_time
                     ,htb.resource_id
                     ,htb.object_version_number
      FROM   hxc_time_building_blocks htb
      WHERE  htb.scope = 'TIMECARD' AND
             htb.application_set_id IS NULL AND
             htb.object_version_number =
             (SELECT MAX(hb.object_version_number)
              FROM   hxc_time_building_blocks hb
              WHERE  hb.time_building_block_id = htb.time_building_block_id AND
                     hb.start_time = htb.start_time AND
                     hb.stop_time = htb.stop_time AND
                     hb.resource_id = htb.resource_id AND
                     hb.scope = 'TIMECARD' AND
                     hb.application_set_id IS NULL) and
             htb.start_time >= nvl(p_start_date, htb.start_time) and
             htb.stop_time <= nvl(p_end_date, htb.stop_time) and
             exists
       (select 1
              from   per_all_people_f per
              where  htb.resource_id = per.person_id);

    CURSOR C_Resource_Id_Bg is
      SELECT DISTINCT htb.time_building_block_id
                     ,htb.start_time
                     ,htb.stop_time
                     ,htb.resource_id
                     ,htb.object_version_number
      FROM   hxc_time_building_blocks htb
      WHERE  htb.scope = 'TIMECARD' AND
             htb.application_set_id IS NULL AND
             htb.object_version_number =
             (SELECT MAX(hb.object_version_number)
              FROM   hxc_time_building_blocks hb
              WHERE  hb.time_building_block_id = htb.time_building_block_id AND
                     hb.start_time = htb.start_time AND
                     hb.stop_time = htb.stop_time AND
                     hb.resource_id = htb.resource_id AND
                     hb.scope = 'TIMECARD' AND
                     hb.application_set_id IS NULL) and
             htb.start_time >= nvl(p_start_date, htb.start_time) and
             htb.stop_time <= nvl(p_end_date, htb.stop_time) and
             exists
       (select 1
              from   per_all_people_f per
              where  htb.resource_id = per.person_id and
                     per.business_group_id = p_business_group_id);
  BEGIN

    p_upg_count := 0;
 IF ( p_business_group_id is null) THEN
     FOR C1 in C_Resource_Id
	  LOOP
	   if (is_process_time_over(p_process_end_time)) then
		commit;
	        return;
	   end if;
           update_appl_set_id(p_time_building_block_id =>c1.time_building_block_id
                         ,p_start_date => c1.start_time
                         ,p_end_date => c1.stop_time
			 ,p_resource_id => c1.resource_id
			 ,p_object_version_number => c1.object_version_number
                         ,p_upg_count =>p_upg_count);
           END LOOP;
 ELSE
     FOR C1 in C_Resource_Id_Bg
         LOOP
	   if (is_process_time_over(p_process_end_time)) then
		commit;
	        return;
	   end if;
	  update_appl_set_id(p_time_building_block_id =>c1.time_building_block_id
                         ,p_start_date => c1.start_time
                         ,p_end_date => c1.stop_time
			 ,p_resource_id => c1.resource_id
			 ,p_object_version_number => c1.object_version_number
                         ,p_upg_count =>p_upg_count);
     END LOOP;
 End if;
 EXCEPTION
    -- For any other Exceptions
    WHEN Others THEN
      --
      -- Rollback to the start
      --
      raise;
      --
    --
END populate_appl_set_id;



PROCEDURE populate_details(p_business_group_id in number default null
                            ,p_start_date        in date
                            ,p_end_date          in date
                            ,p_process_end_time  in date default null
                            ,p_detail_count      out nocopy number) IS

    CURSOR csr_get_resource_details IS
      SELECT DISTINCT tbb.resource_id
                     ,tbb.time_building_Block_id
                     ,tbb.object_version_number
                     ,tbb.approval_status
                     ,tbb.application_set_id
                     ,tbb.last_update_date
                     ,tbb.resource_type
                     ,tbb.comment_text
                     ,tbb_day.start_time
                     ,tbb_day.stop_time
      FROM   hxc_time_building_blocks tbb
            ,hxc_time_building_Blocks tbb_day
      WHERE  tbb.scope = 'DETAIL' AND
             tbb.object_Version_number =
             (SELECT /*+ no_unnest */
               MAX(dovn.object_version_number)
              FROM   hxc_time_building_blocks dovn
              WHERE  dovn.time_building_block_id =
                     tbb.time_building_block_id) AND
             tbb_day.time_building_block_id = tbb.parent_building_block_id AND
             NOT EXISTS
       (SELECT 'x'
              FROM   hxc_latest_details hld
              WHERE  hld.time_building_block_id = tbb.time_building_block_id) AND
             tbb_day.object_Version_number =
             (SELECT /*+ no_unnest */
               MAX(dovn1.object_version_number)
              FROM   hxc_time_building_blocks dovn1
              WHERE  dovn1.time_building_block_id =
                     tbb_day.time_building_block_id) and
             tbb_day.start_time >= nvl(p_start_date, tbb_day.start_time) and
             tbb_day.stop_time <= nvl(p_end_date, tbb_day.stop_time) and
            EXISTS
             ( SELECT 'x'
               FROM   hxc_time_building_blocks tbb_timecard
               WHERE  tbb_timecard.time_building_block_id = tbb_day.parent_building_block_id
               AND    scope = 'TIMECARD' );




    TYPE resource_id_tab IS TABLE OF hxc_time_building_blocks.resource_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE tbb_id_tab IS TABLE OF hxc_time_building_blocks.time_building_block_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE ovn_tab IS TABLE OF hxc_time_building_blocks.object_version_number%TYPE INDEX BY BINARY_INTEGER;
    TYPE approval_status_tab IS TABLE OF hxc_time_building_blocks.approval_status%TYPE INDEX BY BINARY_INTEGER;
    TYPE application_set_id_tab IS TABLE OF hxc_time_building_blocks.application_set_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE last_update_date_tab IS TABLE OF hxc_time_building_blocks.last_update_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE resource_type_tab IS TABLE OF hxc_time_building_blocks.resource_type%TYPE INDEX BY BINARY_INTEGER;
    TYPE comment_text_tab IS TABLE OF hxc_time_building_blocks.comment_text%TYPE INDEX BY BINARY_INTEGER;
    TYPE start_time_tab IS TABLE OF hxc_time_building_blocks.start_time%TYPE INDEX BY BINARY_INTEGER;
    TYPE stop_time_tab IS TABLE OF hxc_time_building_blocks.stop_time%TYPE INDEX BY BINARY_INTEGER;

    t_resource_id        resource_id_tab;
    t_tbb_id             tbb_id_tab;
    t_ovn                ovn_tab;
    t_approval_status    approval_status_tab;
    t_application_set_id application_set_id_tab;
    t_last_update_date   last_update_date_tab;
    t_resource_type      resource_type_tab;
    t_comment_text       comment_text_tab;
    t_start_time         start_time_tab;
    t_stop_time          stop_time_tab;



  BEGIN
    p_detail_count := 0;

    open csr_get_resource_details;
    Loop

      if (is_process_time_over(p_process_end_time)) then
        close csr_get_resource_details;
        commit;
        return;
      end if;

      fetch csr_get_resource_details BULK COLLECT
        INTO t_resource_id,
             t_tbb_id, t_ovn,
             t_approval_status,
             t_application_set_id,
             t_last_update_date,
             t_resource_type,
             t_comment_text,
             t_start_time,
             t_stop_time LIMIT 100;

      IF (t_tbb_id.COUNT <> 0) THEN

        forall x in t_tbb_id.first .. t_tbb_id.last
          INSERT INTO hxc_latest_details
            (resource_id
            ,time_building_block_id
            ,object_version_number
            ,approval_status
            ,application_set_id
            ,last_update_date
            ,resource_type
            ,comment_text
            ,start_time
            ,stop_time)
          VALUES
            (t_resource_id(x)
            ,t_tbb_id(x)
            ,t_ovn(x)
            ,t_approval_status(x)
            ,t_application_set_id(x)
            ,t_last_update_date(x)
            ,t_resource_type(x)
            ,t_comment_text(x)
            ,t_start_time(x)
            ,t_stop_time(x));

        p_detail_count := p_detail_count + t_tbb_id.count;

        t_resource_id.DELETE;
        t_tbb_id.DELETE;
        t_ovn.DELETE;
        t_approval_status.DELETE;
        t_application_set_id.DELETE;
        t_last_update_date.DELETE;
        t_resource_type.DELETE;
        t_comment_text.DELETE;
        t_start_time.DELETE;
        t_stop_time.DELETE;

      END IF;

      EXIT WHEN csr_get_resource_details%NOTFOUND;
    END LOOP;

    CLOSE csr_get_resource_details;

  Exception
    When others then
      fnd_file.put_line(fnd_file.LOG,'Exception in populate_details is :' || SQLERRM);
      return;
  END populate_details;


 Procedure migrate_templates(errbuf              out nocopy varchar2
                            ,retcode             out nocopy number
                            ,p_business_group_id in number default null
                            ,p_start_date        in varchar2 default null
                            ,p_end_date          in varchar2 default null
                            ,p_stop_time         in varchar2 default null
                            ,p_batch_size        in number default 500
                            ,p_num_workers       in number
			    ) is

 cursor c_templates(p_start_date date, p_end_date date) is
      select tbb.time_building_block_id
            ,tbb.object_version_number
      from   hxc_time_building_blocks tbb
      where  tbb.date_to = hr_general.end_of_time and
             tbb.scope = 'TIMECARD_TEMPLATE'
	     and resource_id <>-1 and
             not exists
       (select 'Y'
              from   hxc_template_summary
              where  template_id = tbb.time_building_block_id and
                     template_ovn = tbb.object_version_number) and
             TRUNC(tbb.start_time) >= nvl(p_start_date, TRUNC(tbb.start_time)) and  -- 5985862 Added TRUNC to truncate time component from date
             TRUNC(tbb.stop_time) <= nvl(p_end_date, tbb.stop_time) and             -- 5985862 Added TRUNC to truncate time component from date
             exists
       (select 1
              from   per_all_people_f per
              where  tbb.resource_id = per.person_id);

  cursor c_templates_bg(p_start_date date, p_end_date date) is
      select tbb.time_building_block_id
            ,tbb.object_version_number
      from   hxc_time_building_blocks tbb
      where  tbb.date_to = hr_general.end_of_time and
             tbb.scope = 'TIMECARD_TEMPLATE'
	     and resource_id <>-1 and
             not exists
       (select 'Y'
              from   hxc_template_summary
              where  template_id = tbb.time_building_block_id and
                     template_ovn = tbb.object_version_number) and
             TRUNC(tbb.start_time) >= nvl(p_start_date, TRUNC(tbb.start_time)) and  -- 5985862 Added TRUNC to truncate time component from date
             TRUNC(tbb.stop_time) <= nvl(p_end_date, tbb.stop_time) and             -- 5985862 Added TRUNC to truncate time component from date
             exists
       (select 1
              from   per_all_people_f per
              where  tbb.resource_id = per.person_id and
                     per.business_group_id = p_business_group_id);


    TYPE tbb_id_tab IS TABLE OF hxc_time_building_blocks.time_building_block_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE ovn_tab IS TABLE OF hxc_time_building_blocks.object_version_number%TYPE INDEX BY BINARY_INTEGER;
    l_tbb_id_tab    tbb_id_tab;
    l_ovn_tab       ovn_tab;
    l_app_bb_id_tab tbb_id_tab;


    type req_id_tab is table of number index by binary_integer;
    l_req_id req_id_tab;

    l_request_id number;
    i            pls_integer;

    l_start_date date;
    l_end_date   date;

    l_process_end_time date;

    l_timecard_count   number;
    l_detail_count     number;
    l_batch_size       number;
    l_elp_upg_count    number;

  begin

    fnd_file.put_line(fnd_file.LOG, 'Starting Template Migration');
    fnd_file.put_line(fnd_file.LOG,'Starting Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));

    l_timecard_count   := 0;
    l_detail_count     := 0;
    l_elp_upg_count    := 0;

    l_request_id       := FND_GLOBAL.CONC_REQUEST_ID;
    l_process_end_time := fnd_date.canonical_to_date(p_stop_time);
    l_start_date       := trunc(fnd_date.canonical_to_date(p_start_date));
    l_end_date         := trunc(fnd_date.canonical_to_date(p_end_date)) + 1 - (1 / (24 * 60 * 60));
    l_batch_size       := nvl(p_batch_size,500);


    fnd_file.put_line(fnd_file.LOG,'-------------------------------------');
    fnd_file.put_line(fnd_file.LOG, 'Parameters');
    fnd_file.put_line(fnd_file.LOG, '----------');
    fnd_file.put_line(fnd_file.LOG,'Business Group Id :' || p_business_group_id);
    fnd_file.put_line(fnd_file.LOG, 'Start Date :' || l_start_date);
    fnd_file.put_line(fnd_file.LOG, 'End Date :' || l_end_date);
    fnd_file.put_line(fnd_file.LOG, 'Stop Processing At :' || p_stop_time);
    fnd_file.put_line(fnd_file.LOG, 'Batch Size :' || l_batch_size);
    fnd_file.put_line(fnd_file.LOG,'Number of Workers : ' || p_num_workers);
    fnd_file.put_line(fnd_file.LOG,'--------------------------------------');

    IF ( p_business_group_id is null) THEN
	open c_templates(l_start_date, l_end_date);
    ELSE
	open c_templates_bg(l_start_date, l_end_date);
    END IF;


    i := 1;
    loop

      if (is_process_time_over(l_process_end_time)) then
        fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
        fnd_file.put_line(fnd_file.LOG,'Total Number of templates processed : ' ||l_timecard_count);
        fnd_file.put_line(fnd_file.LOG,'Total Number of detail blocks processed : ' ||l_detail_count);
        fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
        fnd_file.put_line(fnd_file.LOG, 'Leaving Template Migration');
        fnd_file.put_line(fnd_file.LOG,'Ending Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));
        commit;
        return;
      end if;

      if not l_req_id.exists(i) then
        l_req_id(i) := FND_REQUEST.SUBMIT_REQUEST(application => 'HXC'
                                                 ,program     => 'HXCTCMIGRATEWK'
                                                 ,description => NULL
                                                 ,sub_request => FALSE
                                                 ,argument1   => l_request_id
                                                 ,argument2   => p_stop_time
						 ,argument3   => 'TEMPLATE');
        if l_req_id(i) = 0 then
          --some problem with the concurrent request. write to log file.
          fnd_file.put_line(fnd_file.LOG,'There was a problem while submitting the concurrent request for Worker ' || i);

        end if;
        commit;

      end if;

      IF ( p_business_group_id is null) THEN
	  fetch c_templates BULK COLLECT
            INTO l_tbb_id_tab, l_ovn_tab limit l_batch_size;
      ELSE
	  fetch c_templates_bg BULK COLLECT
	    INTO l_tbb_id_tab, l_ovn_tab limit l_batch_size;
      END IF;

      l_timecard_count := l_timecard_count + l_tbb_id_tab.count;


      BEGIN

        forall x in l_tbb_id_tab.first .. l_tbb_id_tab.last
          insert into hxc_temp_timecards
            (time_building_block_id
            ,object_version_number
            ,scope
            ,worker_id)
          values
            (l_tbb_id_tab(x)
            ,l_ovn_tab(x)
            ,'TIMECARD_TEMPLATE'
            ,l_req_id(i));

      EXCEPTION
        when others then
          null;
      END;
      commit;

      -- 5985862 Exit from whichever cursor is open.
      IF ( p_business_group_id is null) THEN
          exit when c_templates%notfound;
      ELSE
          exit when c_templates_bg%notfound;
      END IF;

      l_tbb_id_tab.delete;
      l_ovn_tab.delete;

      i := i + 1;
      if (i > p_num_workers) then
        i := 1;
      end if;

    end loop;

      -- 5985862 Close whichever is open
      IF ( p_business_group_id is null) THEN
          close c_templates;
      ELSE
          close c_templates_bg;
      END IF;

    fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
    fnd_file.put_line(fnd_file.LOG,'Total Number of templates processed : ' ||l_timecard_count);



    insert into hxc_temp_timecards
      (TIME_BUILDING_BLOCK_ID
      ,scope
      ,object_version_number
      ,worker_id
      ,processed)
    values
      (null
      ,'COMPLETED'
      ,null
      ,l_request_id
      ,'Y');
    commit;

    fnd_file.put_line(fnd_file.LOG,'Total Number of detail blocks processed : ' ||l_detail_count);
    fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
    fnd_file.put_line(fnd_file.LOG, 'Leaving Template Migration');
    fnd_file.put_line(fnd_file.LOG,'Ending Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));

--    delete_templates;
    commit;
  end migrate_templates;

Procedure migrate_timecards(errbuf              out nocopy varchar2
                            ,retcode             out nocopy number
                            ,p_business_group_id in number default null
                            ,p_start_date        in varchar2 default null
                            ,p_end_date          in varchar2 default null
                            ,p_stop_time         in varchar2 default null
                            ,p_batch_size        in number default 500
                            ,p_num_workers       in number
			    ) is

cursor c_timecards(p_start_date date, p_end_date date) is
      select tbb.time_building_block_id
            ,tbb.object_version_number
      from   hxc_time_building_blocks tbb
      where  tbb.date_to = hr_general.end_of_time and
             tbb.scope = 'TIMECARD' and
             not exists
       (select 'Y'
              from   hxc_timecard_summary
              where  timecard_id = tbb.time_building_block_id and
                     timecard_ovn = tbb.object_version_number) and
             TRUNC(tbb.start_time) >= nvl(p_start_date, TRUNC(tbb.start_time)) and  -- 5985862 Added TRUNC to truncate time component from date
             TRUNC(tbb.stop_time) <= nvl(p_end_date, tbb.stop_time) and             -- 5985862 Added TRUNC to truncate time component from date
             exists
       (select 1
              from   per_all_people_f per
              where  tbb.resource_id = per.person_id);

cursor c_timecards_bg(p_start_date date, p_end_date date) is
      select tbb.time_building_block_id
            ,tbb.object_version_number
      from   hxc_time_building_blocks tbb
      where  tbb.date_to = hr_general.end_of_time and
             tbb.scope = 'TIMECARD' and
             not exists
       (select 'Y'
              from   hxc_timecard_summary
              where  timecard_id = tbb.time_building_block_id and
                     timecard_ovn = tbb.object_version_number) and
             TRUNC(tbb.start_time) >= nvl(p_start_date, TRUNC(tbb.start_time)) and  -- 5985862 Added TRUNC to truncate time component from date
             TRUNC(tbb.stop_time) <= nvl(p_end_date, tbb.stop_time) and             -- 5985862 Added TRUNC to truncate time component from date
              exists
       (select 1
              from   per_all_people_f per
              where  tbb.resource_id = per.person_id and
                     per.business_group_id = p_business_group_id);

    cursor c_app_periods(p_start_date date, p_end_date date) is
      select distinct tbb.time_building_block_id
      from   hxc_time_building_blocks  tbb
            ,hxc_time_attribute_usages tau
            ,hxc_time_attributes       ta
      where  tbb.scope = 'APPLICATION_PERIOD' and
             tbb.date_to = hr_general.end_of_time and
             tau.time_building_block_id = tbb.time_building_block_id and
             tau.time_building_block_ovn = tbb.object_version_number and
             ta.attribute_category = 'APPROVAL' and
             ta.time_attribute_id = tau.time_attribute_id and
             TRUNC(tbb.start_time) >= nvl(p_start_date, TRUNC(tbb.start_time)) and  -- 5985862 Added TRUNC to truncate time component from date
             TRUNC(tbb.stop_time) <= nvl(p_end_date, tbb.stop_time) and             -- 5985862 Added TRUNC to truncate time component from date
             not exists
       (select 'Y'
              from   hxc_app_period_summary aps
              where  aps.application_period_id = tbb.time_building_block_id and
                     aps.application_period_ovn = tbb.object_version_number) and
             exists
       (select 1
              from   per_all_people_f per
              where  tbb.resource_id = person_id )
      order  by 1;

   cursor c_app_periods_bg(p_start_date date, p_end_date date) is
      select distinct tbb.time_building_block_id
      from   hxc_time_building_blocks  tbb
            ,hxc_time_attribute_usages tau
            ,hxc_time_attributes       ta
      where  tbb.scope = 'APPLICATION_PERIOD' and
             tbb.date_to = hr_general.end_of_time and
             tau.time_building_block_id = tbb.time_building_block_id and
             tau.time_building_block_ovn = tbb.object_version_number and
             ta.attribute_category = 'APPROVAL' and
             ta.time_attribute_id = tau.time_attribute_id and
             TRUNC(tbb.start_time) >= nvl(p_start_date, TRUNC(tbb.start_time)) and  -- 5985862 Added TRUNC to truncate time component from date
             TRUNC(tbb.stop_time) <= nvl(p_end_date, tbb.stop_time) and             -- 5985862 Added TRUNC to truncate time component from date
             not exists
       (select 'Y'
              from   hxc_app_period_summary aps
              where  aps.application_period_id = tbb.time_building_block_id and
                     aps.application_period_ovn = tbb.object_version_number) and
             exists
       (select 1
              from   per_all_people_f per
              where  tbb.resource_id = person_id and
                     per.business_group_id =
                     p_business_group_id)
      order  by 1;


    TYPE tbb_id_tab IS TABLE OF hxc_time_building_blocks.time_building_block_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE ovn_tab IS TABLE OF hxc_time_building_blocks.object_version_number%TYPE INDEX BY BINARY_INTEGER;
    l_tbb_id_tab    tbb_id_tab;
    l_ovn_tab       ovn_tab;
    l_app_bb_id_tab tbb_id_tab;


    type req_id_tab is table of number index by binary_integer;
    l_req_id req_id_tab;

    l_request_id number;
    i            pls_integer;

    l_start_date date;
    l_end_date   date;

    l_process_end_time date;

    l_timecard_count   number;
    l_app_period_count number;
    l_detail_count     number;
    l_batch_size       number;
    l_elp_upg_count    number;

  begin

    fnd_file.put_line(fnd_file.LOG, 'Starting Timecard Migration');
    fnd_file.put_line(fnd_file.LOG,'Starting Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));

    l_timecard_count   := 0;
    l_app_period_count := 0;
    l_detail_count     := 0;
    l_elp_upg_count    := 0;

    l_request_id       := FND_GLOBAL.CONC_REQUEST_ID;
    l_process_end_time := fnd_date.canonical_to_date(p_stop_time);
    l_start_date       := trunc(fnd_date.canonical_to_date(p_start_date));
    l_end_date         := trunc(fnd_date.canonical_to_date(p_end_date)) + 1 - (1 / (24 * 60 * 60));
    l_batch_size       := nvl(p_batch_size,500);


    fnd_file.put_line(fnd_file.LOG,'-------------------------------------');
    fnd_file.put_line(fnd_file.LOG, 'Parameters');
    fnd_file.put_line(fnd_file.LOG, '----------');
    fnd_file.put_line(fnd_file.LOG,'Business Group Id :' || p_business_group_id);
    fnd_file.put_line(fnd_file.LOG, 'Start Date :' || l_start_date);
    fnd_file.put_line(fnd_file.LOG, 'End Date :' || l_end_date);
    fnd_file.put_line(fnd_file.LOG, 'Stop Processing At :' || p_stop_time);
    fnd_file.put_line(fnd_file.LOG, 'Batch Size :' || l_batch_size);
    fnd_file.put_line(fnd_file.LOG,'Number of Workers : ' || p_num_workers);
    fnd_file.put_line(fnd_file.LOG,'--------------------------------------');

    IF(p_business_group_id is null) THEN
	open c_timecards(l_start_date, l_end_date);
    ELSE
	open c_timecards_bg(l_start_date, l_end_date);
    END IF;

    i := 1;
    loop

      if (is_process_time_over(l_process_end_time)) then
        fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
        fnd_file.put_line(fnd_file.LOG,'Total Number of timecards processed : ' ||l_timecard_count);
        fnd_file.put_line(fnd_file.LOG,'Total Number of application period blocks processed : ' ||l_app_period_count);
        fnd_file.put_line(fnd_file.LOG,'Total Number of detail blocks processed : ' ||l_detail_count);
        fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
        fnd_file.put_line(fnd_file.LOG, 'Leaving Timecard Migration');
        fnd_file.put_line(fnd_file.LOG,'Ending Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));
        commit;
        return;
      end if;

      if not l_req_id.exists(i) then
        l_req_id(i) := FND_REQUEST.SUBMIT_REQUEST(application => 'HXC'
                                                 ,program     => 'HXCTCMIGRATEWK'
                                                 ,description => NULL
                                                 ,sub_request => FALSE
                                                 ,argument1   => l_request_id
                                                 ,argument2   => p_stop_time
						 ,argument3   => 'TIMECARD');
        if l_req_id(i) = 0 then
          --some problem with the concurrent request. write to log file.
          fnd_file.put_line(fnd_file.LOG,'There was a problem while submitting the concurrent request for Worker ' || i);

        end if;
        commit;

      end if;

        IF(p_business_group_id is null) THEN
	      fetch c_timecards BULK COLLECT
  	          INTO l_tbb_id_tab, l_ovn_tab limit l_batch_size;
	ELSE
              fetch c_timecards_bg BULK COLLECT
	          INTO l_tbb_id_tab, l_ovn_tab limit l_batch_size;
	END IF;

	 l_timecard_count := l_timecard_count + l_tbb_id_tab.count;
      BEGIN

        forall x in l_tbb_id_tab.first .. l_tbb_id_tab.last
          insert into hxc_temp_timecards
            (time_building_block_id
            ,object_version_number
            ,scope
            ,worker_id)
          values
            (l_tbb_id_tab(x)
            ,l_ovn_tab(x)
            ,'TIMECARD'
            ,l_req_id(i));

      EXCEPTION
        when others then
          null;
      END;
      commit;

      -- 5985862 Exit from whichever cursor is open.
      IF(p_business_group_id is null) THEN
          exit when c_timecards%notfound;
      ELSE
          exit when c_timecards_bg%notfound;
      END IF;

      l_tbb_id_tab.delete;
      l_ovn_tab.delete;

      i := i + 1;
      if (i > p_num_workers) then
        i := 1;
      end if;


    end loop;

    -- 5985862 Close whichever cursor is open
    IF(p_business_group_id is null) THEN
        close c_timecards;
    ELSE
        close c_timecards_bg;
    END IF;

    fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
    fnd_file.put_line(fnd_file.LOG,'Total Number of timecards processed : ' ||l_timecard_count);

   if(p_business_group_id is null) then
    open c_app_periods(l_start_date, l_end_date);
   else
    open c_app_periods_bg(l_start_date, l_end_date);
   end if;

    i := 1;
    loop
      if (is_process_time_over(l_process_end_time)) then
        fnd_file.put_line(fnd_file.LOG,'Total Number of application period blocks processed : ' ||l_app_period_count);
        fnd_file.put_line(fnd_file.LOG,'Total Number of detail blocks processed : ' ||l_detail_count);
        fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
        fnd_file.put_line(fnd_file.LOG, 'Leaving Timecard Migration');
        fnd_file.put_line(fnd_file.LOG,'Ending Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));
        commit;
        return;
      end if;

      if not l_req_id.exists(i) then

        l_req_id(i) := FND_REQUEST.SUBMIT_REQUEST(application => 'HXC'
                                                 ,program     => 'HXCTCMIGRATEWK'
                                                 ,description => NULL
                                                 ,sub_request => FALSE
                                                 ,argument1   => l_request_id
                                                 ,argument2   => p_stop_time
						 ,argument3   => 'TIMECARD');
        if l_req_id(i) = 0 then
          --some problem with the concurrent request. write to log file.
          fnd_file.put_line(fnd_file.LOG,'There was a problem while submitting the concurrent request for Worker ' || i);
        end if;

        commit;

      end if;

       IF(p_business_group_id is null) THEN
	    fetch c_app_periods BULK COLLECT
	       INTO l_app_bb_id_tab limit l_batch_size;
       ELSE
	    fetch c_app_periods_bg BULK COLLECT
		INTO l_app_bb_id_tab limit l_batch_size;
       END IF;

      l_app_period_count := l_app_period_count + l_app_bb_id_tab.count;

      BEGIN
        forall x in l_app_bb_id_tab.first .. l_app_bb_id_tab.last
          insert into hxc_temp_timecards
            (time_building_block_id
            ,scope
            ,worker_id)
          values
            (l_app_bb_id_tab(x)
            ,'APPLICATION_PERIOD'
            ,l_req_id(i));

      EXCEPTION
        when others then
          null;
      END;
      commit;

       -- 5985862 Exit from whichever cursor is open.
       IF(p_business_group_id is null) THEN
           exit when c_app_periods%notfound;
       ELSE
           exit when c_app_periods_bg%notfound;
       END IF;

      l_app_bb_id_tab.delete;

      i := i + 1;
      if (i > p_num_workers) then
        i := 1;
      end if;

    end loop;

       -- 5985862 Close whichever is open
       IF(p_business_group_id is null) THEN
           close c_app_periods;
       ELSE
           close c_app_periods_bg;
       END IF;

    fnd_file.put_line(fnd_file.LOG,'Total Number of application period blocks processed : ' ||l_app_period_count);

    insert into hxc_temp_timecards
      (TIME_BUILDING_BLOCK_ID
      ,scope
      ,object_version_number
      ,worker_id
      ,processed)
    values
      (null
      ,'COMPLETED'
      ,null
      ,l_request_id
      ,'Y');
    commit;


    --we do not do parallel processing for details
    populate_details(p_business_group_id
                    ,l_start_date
                    ,l_end_date
                    ,l_process_end_time
                    ,l_detail_count);

    populate_appl_set_id(p_business_group_id, l_process_end_time, l_start_date, l_end_date,l_elp_upg_count);

    fnd_file.put_line(fnd_file.LOG,'Total Number of detail blocks processed : ' ||l_detail_count);
    fnd_file.put_line(fnd_file.LOG,'Total Number of blocks processsed for ELP upgrade : ' ||l_elp_upg_count);
    fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
    fnd_file.put_line(fnd_file.LOG, 'Leaving Timecard Migration');
    fnd_file.put_line(fnd_file.LOG,'Ending Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));

    delete_timecards;
    commit;

  end migrate_timecards;

procedure run_tc_migration(errbuf              out nocopy varchar2
                            ,retcode             out nocopy number
                            ,p_business_group_id in number default null
                            ,p_start_date        in varchar2 default null
                            ,p_end_date          in varchar2 default null
                            ,p_stop_time         in varchar2 default null
                            ,p_batch_size        in number default 500
                            ,p_num_workers       in number
			    ,p_migration_type in varchar2) is
l_timecard_req_id number;
l_template_req_id number;
begin
	IF(p_migration_type = 'TIMECARD') then
		 migrate_timecards(errbuf
		                  ,retcode
                                  ,p_business_group_id
                                  ,p_start_date
                                  ,p_end_date
                                  ,p_stop_time
                                  ,p_batch_size
                                  ,p_num_workers);
	ELSIF(p_migration_type = 'TEMPLATE') then
		 migrate_templates(errbuf
		                  ,retcode
                                  ,p_business_group_id
                                  ,p_start_date
                                  ,p_end_date
                                  ,p_stop_time
                                  ,p_batch_size
                                  ,p_num_workers);
	ELSIF(p_migration_type = 'BOTH') then
	 /*l_timecard_req_id := FND_REQUEST.SUBMIT_REQUEST(application => 'HXC'
                                                 ,program     => 'HXCTCMIGRATE'
                                                 ,description => NULL
                                                 ,sub_request => FALSE
				                  ,argument1   =>p_business_group_id
		                                  ,argument2   => p_start_date
				                  ,argument3   => p_end_date
						  ,argument4   => p_stop_time
		                                  ,argument5   => p_batch_size
				                  ,argument6   => p_num_workers
						  ,argument7   =>'TIMECARD');*/

	if (hr_update_utility.isUpdateComplete(p_app_shortname => 'HXC',
	                                       p_function_name => NULL,
	                                       p_business_group_id => p_business_group_id,
	                                       p_update_name => 'HXCTCMIGRATE'
	                                      ) = 'FALSE')
	then
		hr_update_utility.setUpdateProcessing(p_update_name => 'HXCTCMIGRATE' );
	end if;

	/* changed from FND_REQUEST.SUBMIT_REQUEST to hr_update_utility.submitRequest in order to reflect the
	   status in DTR report */
	hr_update_utility.submitRequest(p_app_shortname => 'HXC'
				   ,p_update_name       => 'HXCTCMIGRATE'
				   ,p_validate_proc     => 'hxc_tcsummary_migrate.check_hxt_installed'
				   ,p_business_group_id => p_business_group_id
				   --,p_legislation_code   in     varchar2 default null
				   ,p_argument1          =>p_business_group_id
				   ,p_argument2          => p_start_date
				   ,p_argument3          => p_end_date
				   ,p_argument4          => p_stop_time
				   ,p_argument5          => p_batch_size
				   ,p_argument6          => p_num_workers
				   ,p_argument7          =>'TIMECARD'
				   ,p_request_id        => l_timecard_req_id) ;


        if l_timecard_req_id = 0 then
          --some problem with the concurrent request. write to log file.
          fnd_file.put_line(fnd_file.LOG,'There was a problem while submitting the concurrent request for migrating tiemcards');

        end if;

	 /*l_template_req_id := FND_REQUEST.SUBMIT_REQUEST(application => 'HXC'
                                                 ,program     => 'HXCTCMIGRATE'
                                                 ,description => NULL
                                                 ,sub_request => FALSE
				                  ,argument1   =>p_business_group_id
		                                  ,argument2   => p_start_date
				                  ,argument3   => p_end_date
						  ,argument4   => p_stop_time
		                                  ,argument5   => p_batch_size
				                  ,argument6   => p_num_workers
						  ,argument7   =>'TEMPLATE');*/


	/* changed from FND_REQUEST.SUBMIT_REQUEST to hr_update_utility.submitRequest in order to reflect the
	   status in DTR report */
	hr_update_utility.submitRequest(p_app_shortname => 'HXC'
				   ,p_update_name       => 'HXCTCMIGRATE'
				   ,p_validate_proc     => 'hxc_tcsummary_migrate.check_hxt_installed'
				   ,p_business_group_id => p_business_group_id
				   --,p_legislation_code   in     varchar2 default null
				   ,p_argument1          =>p_business_group_id
				   ,p_argument2          => p_start_date
				   ,p_argument3          => p_end_date
				   ,p_argument4          => p_stop_time
				   ,p_argument5          => p_batch_size
				   ,p_argument6          => p_num_workers
				   ,p_argument7          =>'TEMPLATE'
				   ,p_request_id     => l_template_req_id) ;



        if l_template_req_id = 0 then
          --some problem with the concurrent request. write to log file.
          fnd_file.put_line(fnd_file.LOG,'There was a problem while submitting the concurrent request for migrating templates' );

        end if;

        if ( l_timecard_req_id <> 0 AND l_template_req_id <> 0
             AND hr_update_utility.isUpdateComplete(p_app_shortname => 'HXC',
	                                       p_function_name => NULL,
	                                       p_business_group_id => p_business_group_id,
	                                       p_update_name => 'HXCTCMIGRATE'
	                                      ) = 'FALSE'
	   )
        then
                	hr_update_utility.setUpdateComplete(p_update_name => 'HXCTCMIGRATE' );
        end if;

	END IF;
end run_tc_migration;

 procedure run_tc_migration_worker(errbuf          out nocopy varchar2
                                   ,retcode         out nocopy number
                                   ,p_parent_req_id in number
                                   ,p_stop_time     in varchar2 default null
				   ,p_migration_type in varchar2) IS

    cursor c_temp_resources(p_worker_id number, p_scope varchar2) is
      select time_building_block_id
            ,object_version_number
      from   hxc_temp_timecards
      where  worker_id = p_worker_id and
             scope = p_scope and
             processed = 'Y';

    cursor c_check_completion(p_worker_id number) is
      select 'Y'
      from   hxc_temp_timecards
      where  worker_id = p_worker_id and
             scope = 'COMPLETED';


    l_worker_id number;
    l_dummy     varchar2(1);

    l_req              boolean;
    l_phase            varchar2(80);
    l_status           varchar2(80);
    l_dev_phase        varchar2(30);
    l_dev_status       varchar2(30);
    l_message          varchar2(240);
    l_parent_req_id    number;
    l_process_end_time date;

    l_time_summary_count    number;
    l_app_per_summary_count number;

  Begin

    fnd_file.put_line(fnd_file.LOG,'Starting Worker Migration');
    fnd_file.put_line(fnd_file.LOG,'Starting Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));
    fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');

    l_process_end_time := fnd_date.canonical_to_date(p_stop_time);
    l_worker_id        := FND_GLOBAL.CONC_REQUEST_ID;
    l_parent_req_id    := p_parent_req_id;

    l_time_summary_count    := 0;
    l_app_per_summary_count := 0;

  if (p_migration_type ='TIMECARD') THEN
    loop
      if (is_process_time_over(l_process_end_time)) then
        fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
        fnd_file.put_line(fnd_file.LOG,'Number of Summary Records Processed :' ||
                          l_time_summary_count);
        fnd_file.put_line(fnd_file.LOG,'Number of Application Summary Records Processed :' ||l_app_per_summary_count);
        fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
        fnd_file.put_line(fnd_file.LOG, 'Leaving Worker Migration');
        fnd_file.put_line(fnd_file.LOG,'Ending Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));
        delete from hxc_temp_timecards where worker_id = l_worker_id;
        commit;
        return;
      end if;

      update hxc_temp_timecards
      set    processed = 'Y'
      where  worker_id = l_worker_id and
             scope in ('TIMECARD', 'APPLICATION_PERIOD');

      if sql%found then

        for timecard_rec in c_temp_resources(l_worker_id, 'TIMECARD') loop
	  hxc_timecard_summary_api.timecard_deposit
	  (p_timecard_id => timecard_rec.time_building_block_id
          ,p_mode        => hxc_timecard_summary_pkg.c_migration_mode
	  ,p_approval_item_type =>null
	  ,p_approval_process_name=> null
	  ,p_approval_item_key => null
	  ,p_tk_audit_item_type   => null
	  ,p_tk_audit_process_name => null
	  ,p_tk_audit_item_key     => null
	  );
          l_time_summary_count := l_time_summary_count + 1;
        end loop;

        for l_app_period_rec in c_temp_resources(l_worker_id,'APPLICATION_PERIOD') loop
          hxc_app_period_summary_api.app_period_create(l_app_period_rec.time_building_block_id
                                                      ,hxc_timecard_summary_pkg.c_migration_mode);
          l_app_per_summary_count := l_app_per_summary_count + 1;
        end loop;

        delete from hxc_temp_timecards
        where  worker_id = l_worker_id and
               scope in ('TIMECARD', 'APPLICATION_PERIOD') and
               processed = 'Y';

        commit;
      else
        -- check the parent request's status
        -- if it has got completed, we need to complete this worker too

        open c_check_completion(l_parent_req_id);
        fetch c_check_completion
          into l_dummy;
        if c_check_completion%found then
          fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
          fnd_file.put_line(fnd_file.LOG,'Number of Summary Records Processed :' ||l_time_summary_count);
          fnd_file.put_line(fnd_file.LOG,'Number of Application Summary Records Processed :' ||l_app_per_summary_count);
          fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
          fnd_file.put_line(fnd_file.LOG, 'Leaving Worker Migration');
          fnd_file.put_line(fnd_file.LOG,'Ending Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));
          commit;
          close c_check_completion;
          return;
        end if;
        close c_check_completion;

        l_req := FND_CONCURRENT.GET_REQUEST_STATUS(request_id => l_parent_req_id
                                                  ,phase      => l_phase
                                                  ,status     => l_status
                                                  ,dev_phase  => l_dev_phase
                                                  ,dev_status => l_dev_status
                                                  ,message    => l_message);

        if (l_dev_Phase = 'COMPLETE') then
          fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
          fnd_file.put_line(fnd_file.LOG,'Number of Summary Records Processed :' ||l_time_summary_count);
          fnd_file.put_line(fnd_file.LOG,'Number of Application Summary Records Processed :' ||l_app_per_summary_count);
          fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
          fnd_file.put_line(fnd_file.LOG, 'Leaving Worker Migration');
          fnd_file.put_line(fnd_file.LOG,'Ending Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));
          commit;
          return;
        end if;

      end if;
    end loop;
    elsif (p_migration_type ='TEMPLATE') THEN
	loop
	      if (is_process_time_over(l_process_end_time)) then
		fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
	        fnd_file.put_line(fnd_file.LOG,'Number of Summary Records Processed :' ||
                          l_time_summary_count);
	        fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
		fnd_file.put_line(fnd_file.LOG, 'Leaving Worker Migration');
	        fnd_file.put_line(fnd_file.LOG,'Ending Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));
		delete from hxc_temp_timecards where worker_id = l_worker_id;
	        commit;
		return;
	      end if;

      update hxc_temp_timecards
      set    processed = 'Y'
      where  worker_id = l_worker_id and
             scope in ('TIMECARD_TEMPLATE');

      if sql%found then

        for timecard_rec in c_temp_resources(l_worker_id, 'TIMECARD_TEMPLATE') loop
	  hxc_template_summary_api.template_deposit
	   (p_template_id => timecard_rec.time_building_block_id
           ,p_template_ovn =>timecard_rec.object_version_number
	  );
          l_time_summary_count := l_time_summary_count + 1;
        end loop;

        delete from hxc_temp_timecards
        where  worker_id = l_worker_id and
               scope in ('TIMECARD_TEMPLATE') and
               processed = 'Y';

        commit;
      else
        -- check the parent request's status
        -- if it has got completed, we need to complete this worker too

        open c_check_completion(l_parent_req_id);
        fetch c_check_completion
          into l_dummy;
        if c_check_completion%found then
          fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
          fnd_file.put_line(fnd_file.LOG,'Number of Summary Records Processed :' ||l_time_summary_count);
          fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
          fnd_file.put_line(fnd_file.LOG, 'Leaving Worker Migration');
          fnd_file.put_line(fnd_file.LOG,'Ending Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));
          commit;
          close c_check_completion;
          return;
        end if;
        close c_check_completion;

        l_req := FND_CONCURRENT.GET_REQUEST_STATUS(request_id => l_parent_req_id
                                                  ,phase      => l_phase
                                                  ,status     => l_status
                                                  ,dev_phase  => l_dev_phase
                                                  ,dev_status => l_dev_status
                                                  ,message    => l_message);

        if (l_dev_Phase = 'COMPLETE') then
          fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
          fnd_file.put_line(fnd_file.LOG,'Number of Summary Records Processed :' ||l_time_summary_count);
          fnd_file.put_line(fnd_file.LOG,'---------------------------------------------------');
          fnd_file.put_line(fnd_file.LOG, 'Leaving Worker Migration');
          fnd_file.put_line(fnd_file.LOG,'Ending Time :' ||to_char(sysdate, 'DD/MM/RRRR HH:MI:SS'));
          commit;
          return;
        end if;

      end if;
    end loop;
   END IF;

  End run_tc_migration_worker;

  /*****************************************************************************
   Function name :  CHECK_HXT_INSTALLED
   Creation date :  10-Oct-2006
   Purpose       :  This procedure returns true when OTL Product
                    is Installed.
  *****************************************************************************/
  PROCEDURE CHECK_HXT_INSTALLED(do_upg OUT NOCOPY VARCHAR2)
  is

       PSP_APPLICATION_ID constant   number:=809;
       PSP_STATUS_INSTALLED constant varchar2(2):='I';

       l_installed fnd_product_installations.status%type;

       cursor csr_psp_installed is
       select status
       from fnd_product_installations
       where application_id = PSP_APPLICATION_ID;

       l_do_submit varchar2(10) := 'FALSE';

  begin

      open csr_psp_installed;
      fetch csr_psp_installed into l_installed;
      if ( l_installed =PSP_STATUS_INSTALLED ) then
        l_do_submit := 'TRUE';
      end if;
      close csr_psp_installed;

      do_upg  := l_do_submit;

END CHECK_HXT_INSTALLED;

end hxc_tcsummary_migrate;

/
