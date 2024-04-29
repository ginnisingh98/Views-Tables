--------------------------------------------------------
--  DDL for Package Body HR_NL_DAILY_SICK_AND_RECOVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_DAILY_SICK_AND_RECOVERY" AS
    /* $Header: pernldsr.pkb 120.3.12010000.2 2009/04/13 04:14:58 knadhan ship $ */
  --
  --  Description
  --    Calls to different procedures, will Insert, Update or Delete
  --    rows from table PER_NL_ABSENCE_CHANGES
  --
  --    Call to the local function will return absence category.
  --
  --    columns legislation_code, absence_attandnce_id, date_changed,
  --    update_type, reported_indicator and person_id in table
  --    PER_NL_ABSENCE_CHANGES are mandatory.
  --
  --  Declare local function
  --
  FUNCTION absence_category(p_absence_attendance_id IN number) return varchar2;
  --
  --
  PROCEDURE insert_person_absence_changes
    (p_absence_attendance_id        IN number
     ,p_effective_date              IN date
     ,p_person_id                   IN number
     ,p_date_projected_start        IN date
     ,p_date_start                  IN date
     ,p_abs_information1            IN varchar2
     ,p_date_projected_end          IN date
     ,p_date_end                    IN date) IS
    --
    v_update_type        varchar2(30) := 'START';
    v_reported_indicator varchar2(30) := 'N';
    --
    --
  BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'NL') THEN
     --
     --
     -- Row is inserted into PER_NL_ABSENCE_CHANGES when the
     -- absence category is "'S'ickness"
     --
     If absence_category(p_absence_attendance_id) = 'S' then
        insert into per_nl_absence_changes
         (absence_attendance_id
         ,date_changed
         ,update_type
         ,reported_indicator
         ,person_id
         ,sickness_start_date
         ,percentage_sick
         ,recovery_date
         )
         values
         (p_absence_attendance_id
         ,p_effective_date
         ,v_update_type
         ,v_reported_indicator
         ,p_person_id
         ,nvl(p_date_start,p_date_projected_start)
         ,TO_NUMBER(p_abs_information1,'990.90') /* Bug 4375570 */
         ,nvl(p_date_end,p_date_projected_end)
         );
     end if;
   END IF;
  END insert_person_absence_changes;
  --
  PROCEDURE update_person_absence_changes
    (p_absence_attendance_id        IN number
     ,p_effective_date              IN date
     ,p_date_end                    IN date
     ,p_date_projected_end          IN date
     ,p_date_start                  IN date
     ,p_date_projected_start        IN date
     ,p_abs_information1            IN varchar2) IS
    --
    v_update_type           varchar2(30) := NULL;
    v_reported_indicator    varchar2(30) := 'N';
    --
    -- This cursor will fetch old data to check
    -- changes to the data.
    --
    cursor cur_per_abs_chags is
      select  person_id
              ,date_end
              ,date_projected_end
              ,date_start
              ,date_projected_start
              ,abs_information1
      from    per_absence_attendances
      where   absence_attendance_id = p_absence_attendance_id;
    --
    l_rec     cur_per_abs_chags%ROWTYPE;
    --
    --
  BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'NL') THEN
    --
    --
    -- Row is inserted into PER_NL_ABSENCE_CHANGES when the
    -- absence category is "'S'ickness"
    --
    If absence_category(p_absence_attendance_id) = 'S' then
       open cur_per_abs_chags;
         fetch cur_per_abs_chags into l_rec;
           --
           if (nvl(p_date_end,hr_general.start_of_time) <>
                 nvl(l_rec.date_end,hr_general.start_of_time)
	       )
	       or
	       (nvl(p_date_projected_end,hr_general.start_of_time) <>
	          nvl(l_rec.date_projected_end,hr_general.start_of_time)
	        )
	        then
	        --
	        -- when there are any changes to DATE_END or
		-- DATE_PROJECTED_END, update type in
		-- PER_NL_ABSENCE_CHANGES is 'END'
                --
	        v_update_type := 'END';
	        --
	     elsif (nvl(p_date_start,hr_general.start_of_time) <>
	               nvl(l_rec.date_start,hr_general.start_of_time)
	             )
	             or
	             (nvl(p_date_projected_start,hr_general.start_of_time) <>
	   	           nvl(l_rec.date_projected_start,hr_general.start_of_time)
	   	       )
	   	     or
	             (nvl(p_abs_information1,'-1') <>
	  	           nvl(l_rec.abs_information1,'-1')
	  	        ) then
	          --
	          -- when there are any changes to DATE_START,
		  -- DATE_PROJECTED_START or ABS_INFORMATION1 update type in
		  -- PER_NL_ABSENCE_CHANGES is 'UPDATE'
                  --
	          v_update_type := 'UPDATE';
	          --
	       end if;
       --
       close cur_per_abs_chags;
       --
       -- when there is change to v_update_type
       -- then insert row into PER_NL_ABSENCE_CHANGES
       --
       if v_update_type is not null then
          insert into per_nl_absence_changes
            (absence_attendance_id
             ,date_changed
             ,update_type
             ,reported_indicator
             ,person_id
             ,sickness_start_date
             ,percentage_sick
             ,recovery_date
             )
            values
             (p_absence_attendance_id
              ,p_effective_date
              ,v_update_type
              ,v_reported_indicator
              ,l_rec.person_id
              ,nvl(p_date_start,p_date_projected_start)
              ,decode(p_abs_information1,NULL,NULL,TO_NUMBER(l_rec.abs_information1,'990.90')) /* Bug 4375570 */ -- 8342503
              ,nvl(p_date_end,p_date_projected_end)
              );
        end if;
    end if;
    --
   END IF;
   --
  END update_person_absence_changes;
  --
  PROCEDURE delete_person_absence_changes
    (p_absence_attendance_id     IN number) IS
    --
    --  This cursor fetchs old data from PER_ABSENCE_ATTENDANCES
    --  required to maitain the details of the deleted absence.
    --
    cursor cur_per_abs_chags is
      select  person_id
              ,date_end
              ,date_projected_end
              ,date_start
              ,date_projected_start
              ,abs_information1
      from    per_absence_attendances
      where   absence_attendance_id = p_absence_attendance_id;
      --
    l_rec     cur_per_abs_chags%ROWTYPE;
    --
    v_update_type        varchar2(30) := 'DELETE';
    v_reported_indicator varchar2(30) := 'N';
    v_effective_date     date;
    --
    --
  BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'NL') THEN
    --
    begin
      --
      --  This query return current session date
      --
      select    nvl(effective_date,trunc(sysdate))
      into      v_effective_date
      from      fnd_sessions
      where     userenv('sessionid') = session_id;
    exception
      when no_data_found then
        null;
    end;
    --
    open  cur_per_abs_chags;
      fetch cur_per_abs_chags into l_rec;
    close cur_per_abs_chags;
    --
    --  Insert data into table PER_NL_ABSENCE_CHANGES only
    --  only when absence category is "'S'ickness".
    --
    If absence_category(p_absence_attendance_id) = 'S' then
       insert into per_nl_absence_changes
         (absence_attendance_id
          ,date_changed
          ,update_type
          ,reported_indicator
          ,person_id
          ,sickness_start_date
          ,percentage_sick
          ,recovery_date
          )
         values
         (p_absence_attendance_id
          ,v_effective_date
          ,v_update_type
          ,v_reported_indicator
          ,l_rec.person_id
          ,nvl(l_rec.date_start,l_rec.date_projected_start)
          ,TO_NUMBER(l_rec.abs_information1,'990.90') /* BUG 4375570 */
          ,nvl(l_rec.date_end,l_rec.date_projected_end)
          );
    end if;
    --
   END IF;
  END delete_person_absence_changes;
  --
  procedure purge_per_nl_absence_changes
    (p_errbuf               OUT     nocopy  varchar2
     ,p_retcode             OUT     nocopy  varchar2
     ,p_effective_date      IN      varchar2
     ,p_business_group_id   IN      number) is
    --
    v_effective_date date := fnd_date.string_to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
    --
  begin
    --
    DELETE from per_nl_absence_changes pnac
    WHERE  months_between(trunc(v_effective_date), pnac.date_changed) > 12
    AND    person_id in (  SELECT person_id
                           FROM   per_all_people_f
                           WHERE  business_group_id = p_business_group_id);
    --
  end purge_per_nl_absence_changes;
  --
  procedure update_reported_absence_chgs
    (p_effective_date        IN date
     ,p_prev_rep_chg         IN varchar2
     ,p_structure_version_id IN number
     ,p_top_org_id           IN number) is
    --
    --  This cursor will fetch same rows as that of the rows
    --  fetched by the report 'Daily Sick and Recovery Report'
    --

    cursor cur_upd is
     select
            paaf.person_id   person_id
           ,paaf.effective_start_date effective_start_date
           ,paaf.effective_end_date effective_end_date
     from   per_all_assignments_f paaf
     where  paaf.primary_flag = 'Y'
     and    paaf.organization_id in
                                      (SELECT pose1.organization_id_child
	                               FROM   (SELECT pose.organization_id_child ,
		                                      pose.organization_id_parent
	                                       FROM   per_org_structure_elements pose
	                                       WHERE  pose.org_structure_version_id =  p_structure_version_id
	                                       ) pose1
	                               CONNECT BY PRIOR pose1.organization_id_child =
	                                              pose1.organization_id_parent
	                               START WITH pose1.organization_id_parent = p_top_org_id
                                       UNION
	                               SELECT   p_top_org_id
                                       from  dual
                                        );


    --
  begin
    --
    for rec_upd in cur_upd
    loop
      update    per_nl_absence_changes pnac
      set       pnac.reported_indicator = 'Y'
      WHERE   pnac.person_id  = rec_upd.person_id
      AND    nvl(p_effective_date,pnac.sickness_start_date )
	    BETWEEN rec_upd.effective_start_date  AND rec_upd.effective_end_date
      AND     pnac.reported_indicator = decode(p_prev_rep_chg, 'Y',pnac.reported_indicator, 'N')
      AND    pnac.date_changed = nvl(p_effective_date, pnac.date_changed);
    end loop;
    --
  end update_reported_absence_chgs;
  --
  --  This local function will return sickness category for a supplied
  --  absence_attedance_id.
  --
  FUNCTION absence_category
    (p_absence_attendance_id  IN number) return varchar2 is
    --
    -- cursor will fetch absence_category
    --
    cursor cur_per_abs_s_chags is
      select    paat.absence_category
      from      per_absence_attendances paa,
                per_absence_attendance_types paat
      where     paa.absence_attendance_type_id
                  = paat.absence_attendance_type_id
      and       paa.absence_attendance_id = p_absence_attendance_id
      and       paa.business_group_id = paat.business_group_id;
      --
      v_per_abs_chgs per_absence_attendance_types.absence_category%TYPE;
      --
  BEGIN
    --
    open  cur_per_abs_s_chags;
      fetch cur_per_abs_s_chags into v_per_abs_chgs;
    close cur_per_abs_s_chags;
    --
    return(v_per_abs_chgs);
    --
  END absence_category;
END HR_NL_DAILY_SICK_AND_RECOVERY;

/
