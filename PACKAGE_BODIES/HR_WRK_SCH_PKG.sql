--------------------------------------------------------
--  DDL for Package Body HR_WRK_SCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WRK_SCH_PKG" AS
  -- $Header: pewrksch.pkb 120.6.12010000.2 2008/08/06 09:39:30 ubhat ship $
-- this procedure will check if the entered absence is overlapping with any of
-- the schedules attached at BG , Pos, Job, HROrg, Loc . Level
-- NOTE : this procedure will only be called when there exists an Schedule at Person Asg Level.
-- fix for the bug 6711896
  --
    -----------------------------------------------------------------------------
  --------------------------< check_overlap_schedules >---------------------------
  -----------------------------------------------------------------------------

  overlapped     EXCEPTION;

  Procedure check_overlap_schedules (p_person_assignment_id IN NUMBER
                                ,p_period_start_date    IN DATE
                                ,p_period_end_date      IN DATE
                                ,p_schedule_category    IN VARCHAR2
                                ,p_include_exceptions   IN VARCHAR2
                                ,p_busy_tentative_as    IN VARCHAR2
                                ,x_schedule_source      IN OUT NOCOPY VARCHAR2
                                ,x_schedule             IN OUT NOCOPY cac_avlblty_time_varray) is


 l_proc               VARCHAR2(50);
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_sch_inh_seq        NUMBER;
    l_wrk_sch_found      BOOLEAN;
    l_wrk_sch_count      NUMBER;
    l_bus_grp_id         NUMBER;
    l_hr_org_id          NUMBER;
    l_job_id             NUMBER;
    l_pos_id             NUMBER;
    l_loc_id             NUMBER;
    l_include_exceptions VARCHAR2(1);
    l_busy_tentative_as  VARCHAR2(30);


 -- Get max schedule inheritance level
    CURSOR c_max_inh_seq IS
      SELECT MAX(hier_seq)
      FROM   per_sch_inherit_hier
      WHERE  in_hier = 'Y'
      AND    hier_seq IS NOT NULL;

    -- Get schedule inheritance level from hierarchy
    CURSOR c_sch_inh_lvl (cp_inh_seq IN NUMBER) IS
      SELECT inherit_level
      FROM   per_sch_inherit_hier
      WHERE  hier_seq = cp_inh_seq;

    -- Cursor to get person assignment attributes
    CURSOR c_per_asg (cp_per_asg_id IN NUMBER
                     ,cp_eff_date   IN DATE) IS
      SELECT business_group_id
            ,organization_id
            ,job_id
            ,position_id
            ,location_id
      FROM   per_all_assignments_f
      WHERE  assignment_id = cp_per_asg_id
      AND    cp_eff_date BETWEEN effective_start_date
                         ANd     effective_end_date;

    -- Cursor to test if schedule exists
    CURSOR c_sch_found (cp_object_type IN VARCHAR2
                       ,cp_object_id   IN NUMBER
                       ,cp_start_date  IN DATE
                       ,cp_end_date    IN DATE
                       ,cp_sch_cat     IN VARCHAR2
                       ) IS
      SELECT COUNT(*)
      FROM   cac_sr_schdl_objects CSSO
            ,cac_sr_schedules_b   CSSB
      WHERE  CSSO.object_type = cp_object_type
      AND    CSSO.object_id = cp_object_id
      AND    CSSO.start_date_active <= cp_end_date
      AND    CSSO.end_date_active >= cp_start_date
      AND    CSSO.schedule_id = CSSB.schedule_id
      AND    CSSB.deleted_date IS NULL
      AND    (CSSB.schedule_category = cp_sch_cat
              OR
              CSSB.schedule_id IN (SELECT schedule_id
                                   FROM   cac_sr_publish_schedules
                                   WHERE  object_type = cp_object_type
                                   AND    object_id = cp_object_id
                                   AND    cp_sch_cat IS NULL
                                  )
             );

CURSOR c_sch_dates (cp_object_type IN VARCHAR2
                       ,cp_object_id   IN NUMBER
                       ,cp_start_date  IN DATE
                       ,cp_end_date    IN DATE
                       ,cp_sch_cat     IN VARCHAR2
                       ) IS
      SELECT CSSO.start_date_active,CSSO.end_date_active
      FROM   cac_sr_schdl_objects CSSO
            ,cac_sr_schedules_b   CSSB
      WHERE  CSSO.object_type = cp_object_type
      AND    CSSO.object_id = cp_object_id
      AND    CSSO.start_date_active <= cp_end_date
      AND    CSSO.end_date_active >= cp_start_date
      AND    CSSO.schedule_id = CSSB.schedule_id
      AND    CSSB.deleted_date IS NULL
      AND    (CSSB.schedule_category = cp_sch_cat
              OR
              CSSB.schedule_id IN (SELECT schedule_id
                                   FROM   cac_sr_publish_schedules
                                   WHERE  object_type = cp_object_type
                                   AND    object_id = cp_object_id
                                   AND    cp_sch_cat IS NULL
                                  )
             );

             l_sch_start_date date:=null;
             l_sch_end_date date :=null;



begin

hr_utility.set_location('entering overlap check: ', 10);

 OPEN c_max_inh_seq;
      FETCH c_max_inh_seq INTO l_sch_inh_seq;
      CLOSE c_max_inh_seq;

      hr_utility.set_location('MaxSeq: '||l_sch_inh_seq, 10);

      -- Get person assignment attributes
      OPEN c_per_asg (p_person_assignment_id
                     ,p_period_start_date
                     );
      FETCH c_per_asg INTO l_bus_grp_id
                          ,l_hr_org_id
                          ,l_job_id
                          ,l_pos_id
                          ,l_loc_id;
      CLOSE c_per_asg;

      hr_utility.set_location('BGId:'||l_bus_grp_id||
                             ' HROrgId:'||l_hr_org_id||
                             ' JobId:'||l_job_id||
                             ' PosId:'||l_pos_id||
                             ' LocId:'||l_loc_id, 15);

      WHILE l_sch_inh_seq > 0
      LOOP
        -- Get inheritance level
        OPEN c_sch_inh_lvl (l_sch_inh_seq);
        FETCH c_sch_inh_lvl INTO x_schedule_source;
        CLOSE c_sch_inh_lvl;

        hr_utility.set_location('SchInhLvl: '||x_schedule_source, 20);

        CASE x_schedule_source
          WHEN 'BUS_GRP' THEN
            -- Get schedule from business group
            hr_utility.set_location('overlap check', 30);
            cac_avlblty_pub.get_schedule(p_api_version       => 1.0
                                        ,p_init_msg_list     => 'F'
                                        ,p_object_type       => 'BUSINESS_GROUP'
                                        ,p_object_id         => l_bus_grp_id
                                        ,p_start_date_time   => p_period_start_date
                                        ,p_end_date_time     => p_period_end_date
                                        ,p_schedule_category => p_schedule_category
                                        ,p_include_exception => l_include_exceptions
                                        ,p_busy_tentative    => l_busy_tentative_as
                                        ,x_schedule          => x_schedule
                                        ,x_return_status     => l_return_status
                                        ,x_msg_count         => l_msg_count
                                        ,x_msg_data          => l_msg_data
                                        );
            hr_utility.set_location('SchCnt:'||x_schedule.COUNT, 45);

           IF x_schedule.COUNT >= 1 then
           hr_utility.set_location(l_proc||' Before opening cursor ', 1);
           OPEN c_sch_dates ('BUSINESS_GROUP'
	                     ,l_bus_grp_id
	                     ,p_period_start_date
	                     ,p_period_end_date
	                     ,p_schedule_category
                               );

            hr_utility.set_location(l_proc||' After opening cursor ', 2);
	       fetch c_sch_dates into l_sch_start_date,l_sch_end_date;
	       hr_utility.set_location(l_proc||' After fetching', 3);
	         if(c_sch_dates%found) then
	               hr_utility.set_location(l_proc||' Record found', 40);
	               close c_sch_dates;
	               hr_utility.set_location(l_proc||': start date '||l_sch_start_date||' end date '||to_char(l_sch_end_date), 20);
	              -- if(p_period_start_date < l_sch_start_date  or p_period_end_date > l_sch_end_date) then
              if ( p_period_start_date between l_sch_start_date and l_sch_end_date ) then
	                     hr_utility.set_location(l_proc||' Raising error', 20);
	                     raise overlapped;
                        hr_utility.set_location(l_proc||' Raising error', 21);

	               end if;
	               hr_utility.set_location(l_proc||' Exiting with success', 5);
	         ELSE
	                hr_utility.set_location(l_proc||' No Record found ', 6);
	               close c_sch_dates;
	               l_sch_start_date:=null;
            l_sch_end_date:=null;

           end if;
   end if;

          WHEN 'HR_ORG' THEN
            -- Get schedule from hr organization
            hr_utility.set_location(l_proc, 80);
            cac_avlblty_pub.get_schedule(p_api_version       => 1.0
                                        ,p_init_msg_list     => 'F'
                                        ,p_object_type       => 'HR_ORGANIZATION'
                                        ,p_object_id         => l_hr_org_id
                                        ,p_start_date_time   => p_period_start_date
                                        ,p_end_date_time     => p_period_end_date
                                        ,p_schedule_category => p_schedule_category
                                        ,p_include_exception => l_include_exceptions
                                        ,p_busy_tentative    => l_busy_tentative_as
                                        ,x_schedule          => x_schedule
                                        ,x_return_status     => l_return_status
                                        ,x_msg_count         => l_msg_count
                                        ,x_msg_data          => l_msg_data
                                        );
            hr_utility.set_location('SchCnt:'||x_schedule.COUNT, 85);
             IF x_schedule.COUNT >= 1 then
           hr_utility.set_location(l_proc||' Before opening cursor ', 21);
           OPEN c_sch_dates ('HR_ORGANIZATION'
	                     ,l_hr_org_id
	                     ,p_period_start_date
	                     ,p_period_end_date
	                     ,p_schedule_category
                               );

            hr_utility.set_location(l_proc||' After opening cursor ', 22);
	       fetch c_sch_dates into l_sch_start_date,l_sch_end_date;
	       hr_utility.set_location(l_proc||' After fetching', 3);
	         if(c_sch_dates%found) then
	               hr_utility.set_location(l_proc||' Record found', 23);
	               close c_sch_dates;
	               hr_utility.set_location(l_proc||': start date '||l_sch_start_date||' end date '||to_char(l_sch_end_date), 20);
	              -- if(p_period_start_date < l_sch_start_date  or p_period_end_date > l_sch_end_date) then
              if ( p_period_start_date between l_sch_start_date and l_sch_end_date ) then
	                     hr_utility.set_location(l_proc||' Raising error', 24);
	                     raise overlapped;
                        hr_utility.set_location(l_proc||' Raising error', 25);

	               end if;
	               hr_utility.set_location(l_proc||' Exiting with success', 26);
	         ELSE
	                hr_utility.set_location(l_proc||' No Record found ', 27);
	               close c_sch_dates;
	               l_sch_start_date:=null;
            l_sch_end_date:=null;

           end if;
   end if;

          WHEN 'JOB' THEN
            -- Get schedule from job
            hr_utility.set_location(l_proc, 90);
            cac_avlblty_pub.get_schedule(p_api_version       => 1.0
                                        ,p_init_msg_list     => 'F'
                                        ,p_object_type       => 'HR_JOB'
                                        ,p_object_id         => l_job_id
                                        ,p_start_date_time   => p_period_start_date
                                        ,p_end_date_time     => p_period_end_date
                                        ,p_schedule_category => p_schedule_category
                                        ,p_include_exception => l_include_exceptions
                                        ,p_busy_tentative    => l_busy_tentative_as
                                        ,x_schedule          => x_schedule
                                        ,x_return_status     => l_return_status
                                        ,x_msg_count         => l_msg_count
                                        ,x_msg_data          => l_msg_data
                                        );
            hr_utility.set_location('SchCnt:'||x_schedule.COUNT, 95);
             IF x_schedule.COUNT >= 1 then
           hr_utility.set_location(l_proc||' Before opening cursor ', 41);
           OPEN c_sch_dates ('HR_JOB'
	                     ,l_job_id
	                     ,p_period_start_date
	                     ,p_period_end_date
	                     ,p_schedule_category
                               );

            hr_utility.set_location(l_proc||' After opening cursor ', 42);
	       fetch c_sch_dates into l_sch_start_date,l_sch_end_date;
	       hr_utility.set_location(l_proc||' After fetching', 3);
	         if(c_sch_dates%found) then
	               hr_utility.set_location(l_proc||' Record found', 43);
	               close c_sch_dates;
	               hr_utility.set_location(l_proc||': start date '||l_sch_start_date||' end date '||to_char(l_sch_end_date), 20);
	              -- if(p_period_start_date < l_sch_start_date  or p_period_end_date > l_sch_end_date) then
              if ( p_period_start_date between l_sch_start_date and l_sch_end_date ) then
	                     hr_utility.set_location(l_proc||' Raising error', 44);
	                     raise overlapped;
                        hr_utility.set_location(l_proc||' Raising error', 45);

	               end if;
	               hr_utility.set_location(l_proc||' Exiting with success', 46);
	         ELSE
	                hr_utility.set_location(l_proc||' No Record found ', 47);
	               close c_sch_dates;
	               l_sch_start_date:=null;
            l_sch_end_date:=null;

           end if;
   end if;

          WHEN 'POS' THEN
            -- Get schedule from position
            hr_utility.set_location(l_proc, 100);
            cac_avlblty_pub.get_schedule(p_api_version       => 1.0
                                        ,p_init_msg_list     => 'F'
                                        ,p_object_type       => 'HR_POSITION'
                                        ,p_object_id         => l_pos_id
                                        ,p_start_date_time   => p_period_start_date
                                        ,p_end_date_time     => p_period_end_date
                                        ,p_schedule_category => p_schedule_category
                                        ,p_include_exception => l_include_exceptions
                                        ,p_busy_tentative    => l_busy_tentative_as
                                        ,x_schedule          => x_schedule
                                        ,x_return_status     => l_return_status
                                        ,x_msg_count         => l_msg_count
                                        ,x_msg_data          => l_msg_data
                                        );
            hr_utility.set_location('SchCnt:'||x_schedule.COUNT, 105);
              IF x_schedule.COUNT >= 1 then
           hr_utility.set_location(l_proc||' Before opening cursor ', 41);
           OPEN c_sch_dates ('HR_POSITION'
	                     ,l_pos_id
	                     ,p_period_start_date
	                     ,p_period_end_date
	                     ,p_schedule_category
                               );

            hr_utility.set_location(l_proc||' After opening cursor ', 42);
	       fetch c_sch_dates into l_sch_start_date,l_sch_end_date;
	       hr_utility.set_location(l_proc||' After fetching', 3);
	         if(c_sch_dates%found) then
	               hr_utility.set_location(l_proc||' Record found', 43);
	               close c_sch_dates;
	               hr_utility.set_location(l_proc||': start date '||l_sch_start_date||' end date '||to_char(l_sch_end_date), 20);
	              -- if(p_period_start_date < l_sch_start_date  or p_period_end_date > l_sch_end_date) then
              if ( p_period_start_date between l_sch_start_date and l_sch_end_date ) then
	                     hr_utility.set_location(l_proc||' Raising error', 44);
	                     raise overlapped;
                        hr_utility.set_location(l_proc||' Raising error', 45);

	               end if;
	               hr_utility.set_location(l_proc||' Exiting with success', 46);
	         ELSE
	                hr_utility.set_location(l_proc||' No Record found ', 47);
	               close c_sch_dates;
	               l_sch_start_date:=null;
            l_sch_end_date:=null;

           end if;
   end if;

          WHEN 'LOC' THEN
            -- Get schedule from location
            hr_utility.set_location(l_proc, 110);
            cac_avlblty_pub.get_schedule(p_api_version       => 1.0
                                        ,p_init_msg_list     => 'F'
                                        ,p_object_type       => 'HR_LOCATION'
                                        ,p_object_id         => l_loc_id
                                        ,p_start_date_time   => p_period_start_date
                                        ,p_end_date_time     => p_period_end_date
                                        ,p_schedule_category => p_schedule_category
                                        ,p_include_exception => l_include_exceptions
                                        ,p_busy_tentative    => l_busy_tentative_as
                                        ,x_schedule          => x_schedule
                                        ,x_return_status     => l_return_status
                                        ,x_msg_count         => l_msg_count
                                        ,x_msg_data          => l_msg_data
                                        );
            hr_utility.set_location('SchCnt:'||x_schedule.COUNT, 115);

             IF x_schedule.COUNT >= 1 then
           hr_utility.set_location(l_proc||' Before opening cursor ', 51);
           OPEN c_sch_dates ('HR_LOCATION'
	                     ,l_loc_id
	                     ,p_period_start_date
	                     ,p_period_end_date
	                     ,p_schedule_category
                               );

            hr_utility.set_location(l_proc||' After opening cursor ', 52);
	       fetch c_sch_dates into l_sch_start_date,l_sch_end_date;
	       hr_utility.set_location(l_proc||' After fetching', 3);
	         if(c_sch_dates%found) then
	               hr_utility.set_location(l_proc||' Record found', 53);
	               close c_sch_dates;
	               hr_utility.set_location(l_proc||': start date '||l_sch_start_date||' end date '||to_char(l_sch_end_date), 20);
	              -- if(p_period_start_date < l_sch_start_date  or p_period_end_date > l_sch_end_date) then
              if ( p_period_start_date between l_sch_start_date and l_sch_end_date ) then
	                     hr_utility.set_location(l_proc||' Raising error', 54);
	                     raise overlapped;
                        hr_utility.set_location(l_proc||' Raising error', 55);

	               end if;
	               hr_utility.set_location(l_proc||' Exiting with success', 56);
	         ELSE
	                hr_utility.set_location(l_proc||' No Record found ', 57);
	               close c_sch_dates;
	               l_sch_start_date:=null;
            l_sch_end_date:=null;

           end if;
   end if;

        END CASE;


 l_sch_inh_seq := l_sch_inh_seq - 1;
      END LOOP;


end check_overlap_schedules;
--
--fix for the bug 6711896
  --
  -----------------------------------------------------------------------------
  --------------------------< get_per_asg_schedule >---------------------------
  -----------------------------------------------------------------------------
  --
  -- Schedule Source Return Values:-
  --        PER_ASG - HR Person Assignment
  --        BUS_GRP - Business Group
  --        HR_ORG  - HR Organization
  --        JOB     - HR Job
  --        POS     - HR Position
  --        LOC     - HR Location
  --
  -- Return Status Values:-
  --        0 - Success
  --        1 - Warning
  --        2 - Failure
  --
  PROCEDURE get_per_asg_schedule(p_person_assignment_id IN NUMBER
                                ,p_period_start_date    IN DATE
                                ,p_period_end_date      IN DATE
                                ,p_schedule_category    IN VARCHAR2
                                ,p_include_exceptions   IN VARCHAR2
                                ,p_busy_tentative_as    IN VARCHAR2
                                ,x_schedule_source      IN OUT NOCOPY VARCHAR2
                                ,x_schedule             IN OUT NOCOPY cac_avlblty_time_varray
                                ,x_return_status        OUT NOCOPY NUMBER
                                ,x_return_message       OUT NOCOPY VARCHAR2
                                ) IS

    l_proc               VARCHAR2(50);
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_sch_inh_seq        NUMBER;
    l_wrk_sch_found      BOOLEAN;
    l_wrk_sch_count      NUMBER;
    l_bus_grp_id         NUMBER;
    l_hr_org_id          NUMBER;
    l_job_id             NUMBER;
    l_pos_id             NUMBER;
    l_loc_id             NUMBER;
    l_include_exceptions VARCHAR2(1);
    l_busy_tentative_as  VARCHAR2(30);
    e_invalid_params     EXCEPTION;

    -- Get max schedule inheritance level
    CURSOR c_max_inh_seq IS
      SELECT MAX(hier_seq)
      FROM   per_sch_inherit_hier
      WHERE  in_hier = 'Y'
      AND    hier_seq IS NOT NULL;

    -- Get schedule inheritance level from hierarchy
    CURSOR c_sch_inh_lvl (cp_inh_seq IN NUMBER) IS
      SELECT inherit_level
      FROM   per_sch_inherit_hier
      WHERE  hier_seq = cp_inh_seq;

    -- Cursor to get person assignment attributes
    CURSOR c_per_asg (cp_per_asg_id IN NUMBER
                     ,cp_eff_date   IN DATE) IS
      SELECT business_group_id
            ,organization_id
            ,job_id
            ,position_id
            ,location_id
      FROM   per_all_assignments_f
      WHERE  assignment_id = cp_per_asg_id
      AND    cp_eff_date BETWEEN effective_start_date
                         ANd     effective_end_date;

    -- Cursor to test if schedule exists
    CURSOR c_sch_found (cp_object_type IN VARCHAR2
                       ,cp_object_id   IN NUMBER
                       ,cp_start_date  IN DATE
                       ,cp_end_date    IN DATE
                       ,cp_sch_cat     IN VARCHAR2
                       ) IS
      SELECT COUNT(*)
      FROM   cac_sr_schdl_objects CSSO
            ,cac_sr_schedules_b   CSSB
      WHERE  CSSO.object_type = cp_object_type
      AND    CSSO.object_id = cp_object_id
      AND    CSSO.start_date_active <= cp_end_date
      AND    CSSO.end_date_active >= cp_start_date
      AND    CSSO.schedule_id = CSSB.schedule_id
      AND    CSSB.deleted_date IS NULL
      AND    (CSSB.schedule_category = cp_sch_cat
              OR
              CSSB.schedule_id IN (SELECT schedule_id
                                   FROM   cac_sr_publish_schedules
                                   WHERE  object_type = cp_object_type
                                   AND    object_id = cp_object_id
                                   AND    cp_sch_cat IS NULL
                                  )
             );
    --
    --- fix for the bug 6711896

 CURSOR c_sch_dates (cp_object_type IN VARCHAR2
                       ,cp_object_id   IN NUMBER
                       ,cp_start_date  IN DATE
                       ,cp_end_date    IN DATE
                       ,cp_sch_cat     IN VARCHAR2
                       ) IS
      SELECT CSSO.start_date_active,CSSO.end_date_active
      FROM   cac_sr_schdl_objects CSSO
            ,cac_sr_schedules_b   CSSB
      WHERE  CSSO.object_type = cp_object_type
      AND    CSSO.object_id = cp_object_id
      AND    CSSO.start_date_active <= cp_end_date
      AND    CSSO.end_date_active >= cp_start_date
      AND    CSSO.schedule_id = CSSB.schedule_id
      AND    CSSB.deleted_date IS NULL
      AND    (CSSB.schedule_category = cp_sch_cat
              OR
              CSSB.schedule_id IN (SELECT schedule_id
                                   FROM   cac_sr_publish_schedules
                                   WHERE  object_type = cp_object_type
                                   AND    object_id = cp_object_id
                                   AND    cp_sch_cat IS NULL
                                  )
             );

             l_sch_start_date date:=null;
             l_sch_end_date date :=null;
-- fix for the bug 6711896

  BEGIN
    l_proc := 'hr_wrk_sch_pkg.get_per_asg_schedule';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    --
    -- Initialize
    x_return_status := 0;
    x_schedule := cac_avlblty_time_varray();
    x_schedule_source := 'PER_ASG';
    l_busy_tentative_as := NVL(p_busy_tentative_as, 'BUSY');
    l_wrk_sch_found := FALSE;
    l_wrk_sch_count := 0;
    SELECT DECODE(p_include_exceptions, 'Y','T', 'N','F', 'T','T', 'F','F', 'T')
    INTO l_include_exceptions FROM DUAL;

    -- Validate parameters
    IF p_person_assignment_id IS NULL THEN
      x_return_message := 'NULL P_PERSON_ASSIGNMENT_ID';
      RAISE e_invalid_params;
    ELSIF p_period_start_date IS NULL THEN
        x_return_message := 'NULL P_PERIOD_START_DATE';
        RAISE e_invalid_params;
    ELSIF p_period_end_date IS NULL THEN
        x_return_message := 'NULL P_PERIOD_END_DATE';
        RAISE e_invalid_params;
    END IF;

    hr_utility.set_location(l_proc, 20);

    -- Get schedule from person assignment
    cac_avlblty_pub.get_schedule(p_api_version       => 1.0
                                ,p_init_msg_list     => 'F'
                                ,p_object_type       => 'PERSON_ASSIGNMENT'
                                ,p_object_id         => p_person_assignment_id
                                ,p_start_date_time   => p_period_start_date
                                ,p_end_date_time     => p_period_end_date
                                ,p_schedule_category => p_schedule_category
                                ,p_include_exception => l_include_exceptions
                                ,p_busy_tentative    => l_busy_tentative_as
                                ,x_schedule          => x_schedule
                                ,x_return_status     => l_return_status
                                ,x_msg_count         => l_msg_count
                                ,x_msg_data          => l_msg_data
                                );
    --
    hr_utility.set_location('SchCnt:'||x_schedule.COUNT, 30);
    --
    IF x_schedule.COUNT > 1 OR (x_schedule.COUNT = 1 AND x_schedule(1).period_name IS NOT NULL) THEN
      l_wrk_sch_found := TRUE;
    END IF;
    --
    IF x_schedule.COUNT = 1 AND x_schedule(1).period_name IS NULL THEN
      -- Either schedule is found with no working time or schedule is not found.
      -- Test if work schedule exists at PER ASG level
      OPEN c_sch_found ('PERSON_ASSIGNMENT'
                       ,p_person_assignment_id
                       ,p_period_start_date
                       ,p_period_end_date
                       ,p_schedule_category
                       );
      FETCH c_sch_found INTO l_wrk_sch_count;
      CLOSE c_sch_found;
      IF l_wrk_sch_count > 0 THEN
        l_wrk_sch_found := TRUE;
      END IF;
      --
      hr_utility.set_location('PerAsg SchCnt:'||l_wrk_sch_count, 35);
    END IF;
-- fix for the bug 6711896
--
OPEN c_sch_dates ('PERSON_ASSIGNMENT'
                       ,p_person_assignment_id
                       ,p_period_start_date
                       ,p_period_end_date
                       ,p_schedule_category
                       );
   fetch c_sch_dates into l_sch_start_date,l_sch_end_date;

      if(c_sch_dates%found) then
          close c_sch_dates;
  hr_utility.set_location(l_proc||' start date :'||to_char(l_sch_start_date),20);
    hr_utility.set_location(l_proc||' end date :'||to_char(l_sch_end_date),20);

        if ( p_period_start_date < l_sch_start_date and p_period_end_date > l_sch_start_date )
          then
          hr_utility.set_location('call the check overlap function :' ,20);
      check_overlap_schedules(p_person_assignment_id,
                              p_period_start_date,
                              p_period_end_date,
                              p_schedule_category,
                              p_include_exceptions,
                              p_busy_tentative_as,
                              x_schedule_source,
                              x_schedule );
    end if;
 end if;
       hr_utility.set_location('after checking overlaps :' ,20);
    --
   -- fix for the bug 6711896
-- fix for the bug 6711896
--

    -- If explicit schedule not found, use default schedule inheritance
    IF NOT l_wrk_sch_found THEN
      -- Get max schedule inheritance hierarchy level
      OPEN c_max_inh_seq;
      FETCH c_max_inh_seq INTO l_sch_inh_seq;
      CLOSE c_max_inh_seq;

      hr_utility.set_location('MaxSeq: '||l_sch_inh_seq, 40);

      -- Get person assignment attributes
      OPEN c_per_asg (p_person_assignment_id
                     ,p_period_start_date
                     );
      FETCH c_per_asg INTO l_bus_grp_id
                          ,l_hr_org_id
                          ,l_job_id
                          ,l_pos_id
                          ,l_loc_id;
      CLOSE c_per_asg;

      hr_utility.set_location('BGId:'||l_bus_grp_id||
                             ' HROrgId:'||l_hr_org_id||
                             ' JobId:'||l_job_id||
                             ' PosId:'||l_pos_id||
                             ' LocId:'||l_loc_id, 50);

      WHILE l_sch_inh_seq > 0 AND NOT l_wrk_sch_found LOOP
        -- Get inheritance level
        OPEN c_sch_inh_lvl (l_sch_inh_seq);
        FETCH c_sch_inh_lvl INTO x_schedule_source;
        CLOSE c_sch_inh_lvl;

        hr_utility.set_location('SchInhLvl: '||x_schedule_source, 60);

        CASE x_schedule_source
          WHEN 'BUS_GRP' THEN
            -- Get schedule from business group
            hr_utility.set_location(l_proc, 70);
            cac_avlblty_pub.get_schedule(p_api_version       => 1.0
                                        ,p_init_msg_list     => 'F'
                                        ,p_object_type       => 'BUSINESS_GROUP'
                                        ,p_object_id         => l_bus_grp_id
                                        ,p_start_date_time   => p_period_start_date
                                        ,p_end_date_time     => p_period_end_date
                                        ,p_schedule_category => p_schedule_category
                                        ,p_include_exception => l_include_exceptions
                                        ,p_busy_tentative    => l_busy_tentative_as
                                        ,x_schedule          => x_schedule
                                        ,x_return_status     => l_return_status
                                        ,x_msg_count         => l_msg_count
                                        ,x_msg_data          => l_msg_data
                                        );
            hr_utility.set_location('SchCnt:'||x_schedule.COUNT, 75);

          WHEN 'HR_ORG' THEN
            -- Get schedule from hr organization
            hr_utility.set_location(l_proc, 80);
            cac_avlblty_pub.get_schedule(p_api_version       => 1.0
                                        ,p_init_msg_list     => 'F'
                                        ,p_object_type       => 'HR_ORGANIZATION'
                                        ,p_object_id         => l_hr_org_id
                                        ,p_start_date_time   => p_period_start_date
                                        ,p_end_date_time     => p_period_end_date
                                        ,p_schedule_category => p_schedule_category
                                        ,p_include_exception => l_include_exceptions
                                        ,p_busy_tentative    => l_busy_tentative_as
                                        ,x_schedule          => x_schedule
                                        ,x_return_status     => l_return_status
                                        ,x_msg_count         => l_msg_count
                                        ,x_msg_data          => l_msg_data
                                        );
            hr_utility.set_location('SchCnt:'||x_schedule.COUNT, 85);

          WHEN 'JOB' THEN
            -- Get schedule from job
            hr_utility.set_location(l_proc, 90);
            cac_avlblty_pub.get_schedule(p_api_version       => 1.0
                                        ,p_init_msg_list     => 'F'
                                        ,p_object_type       => 'HR_JOB'
                                        ,p_object_id         => l_job_id
                                        ,p_start_date_time   => p_period_start_date
                                        ,p_end_date_time     => p_period_end_date
                                        ,p_schedule_category => p_schedule_category
                                        ,p_include_exception => l_include_exceptions
                                        ,p_busy_tentative    => l_busy_tentative_as
                                        ,x_schedule          => x_schedule
                                        ,x_return_status     => l_return_status
                                        ,x_msg_count         => l_msg_count
                                        ,x_msg_data          => l_msg_data
                                        );
            hr_utility.set_location('SchCnt:'||x_schedule.COUNT, 95);

          WHEN 'POS' THEN
            -- Get schedule from position
            hr_utility.set_location(l_proc, 100);
            cac_avlblty_pub.get_schedule(p_api_version       => 1.0
                                        ,p_init_msg_list     => 'F'
                                        ,p_object_type       => 'HR_POSITION'
                                        ,p_object_id         => l_pos_id
                                        ,p_start_date_time   => p_period_start_date
                                        ,p_end_date_time     => p_period_end_date
                                        ,p_schedule_category => p_schedule_category
                                        ,p_include_exception => l_include_exceptions
                                        ,p_busy_tentative    => l_busy_tentative_as
                                        ,x_schedule          => x_schedule
                                        ,x_return_status     => l_return_status
                                        ,x_msg_count         => l_msg_count
                                        ,x_msg_data          => l_msg_data
                                        );
            hr_utility.set_location('SchCnt:'||x_schedule.COUNT, 105);

          WHEN 'LOC' THEN
            -- Get schedule from location
            hr_utility.set_location(l_proc, 110);
            cac_avlblty_pub.get_schedule(p_api_version       => 1.0
                                        ,p_init_msg_list     => 'F'
                                        ,p_object_type       => 'HR_LOCATION'
                                        ,p_object_id         => l_loc_id
                                        ,p_start_date_time   => p_period_start_date
                                        ,p_end_date_time     => p_period_end_date
                                        ,p_schedule_category => p_schedule_category
                                        ,p_include_exception => l_include_exceptions
                                        ,p_busy_tentative    => l_busy_tentative_as
                                        ,x_schedule          => x_schedule
                                        ,x_return_status     => l_return_status
                                        ,x_msg_count         => l_msg_count
                                        ,x_msg_data          => l_msg_data
                                        );
            hr_utility.set_location('SchCnt:'||x_schedule.COUNT, 115);
        END CASE;

        -- Loop exit conditions
        IF x_schedule.COUNT > 1 OR (x_schedule.COUNT = 1 AND x_schedule(1).period_name IS NOT NULL) THEN
          l_wrk_sch_found := TRUE;
        END IF;
        -- Check if schedule found with no working time.
        IF x_schedule.COUNT = 1 AND x_schedule(1).period_name IS NULL THEN
          -- Either schedule is found with no working time or schedule is not found.
          -- Test if work schedule exists at PER ASG level
          CASE x_schedule_source
            WHEN 'BUS_GRP' THEN
              OPEN c_sch_found ('BUSINESS_GROUP'
                               ,l_bus_grp_id
                               ,p_period_start_date
                               ,p_period_end_date
                               ,p_schedule_category
                               );
              FETCH c_sch_found INTO l_wrk_sch_count;
              CLOSE c_sch_found;
              IF l_wrk_sch_count > 0 THEN
                l_wrk_sch_found := TRUE;
              END IF;
              --
              hr_utility.set_location('BusGrp SchCnt:'||l_wrk_sch_count, 117);
              --
            WHEN 'HR_ORG' THEN
              OPEN c_sch_found ('HR_ORGANIZATION'
                               ,l_hr_org_id
                               ,p_period_start_date
                               ,p_period_end_date
                               ,p_schedule_category
                               );
              FETCH c_sch_found INTO l_wrk_sch_count;
              CLOSE c_sch_found;
              IF l_wrk_sch_count > 0 THEN
                l_wrk_sch_found := TRUE;
              END IF;
              --
              hr_utility.set_location('HROrg SchCnt:'||l_wrk_sch_count, 117);
              --
            WHEN 'JOB' THEN
              OPEN c_sch_found ('HR_JOB'
                               ,l_job_id
                               ,p_period_start_date
                               ,p_period_end_date
                               ,p_schedule_category
                               );
              FETCH c_sch_found INTO l_wrk_sch_count;
              CLOSE c_sch_found;
              IF l_wrk_sch_count > 0 THEN
                l_wrk_sch_found := TRUE;
              END IF;
              --
              hr_utility.set_location('HRJob SchCnt:'||l_wrk_sch_count, 117);
              --
            WHEN 'POS' THEN
              OPEN c_sch_found ('HR_POSITION'
                               ,l_pos_id
                               ,p_period_start_date
                               ,p_period_end_date
                               ,p_schedule_category
                               );
              FETCH c_sch_found INTO l_wrk_sch_count;
              CLOSE c_sch_found;
              IF l_wrk_sch_count > 0 THEN
                l_wrk_sch_found := TRUE;
              END IF;
              --
              hr_utility.set_location('HRPos SchCnt:'||l_wrk_sch_count, 117);
              --
            WHEN 'LOC' THEN
              OPEN c_sch_found ('HR_LOCATION'
                               ,l_loc_id
                               ,p_period_start_date
                               ,p_period_end_date
                               ,p_schedule_category
                               );
              FETCH c_sch_found INTO l_wrk_sch_count;
              CLOSE c_sch_found;
              IF l_wrk_sch_count > 0 THEN
                l_wrk_sch_found := TRUE;
              END IF;
              --
              hr_utility.set_location('HRLoc SchCnt:'||l_wrk_sch_count, 117);
              --
          END CASE;
        END IF;
        --
        l_sch_inh_seq := l_sch_inh_seq - 1;
      END LOOP;
    END IF; -- Explicit schedule not found

    IF NOT l_wrk_sch_found THEN
      x_schedule_source := '';
    END IF;

    IF l_return_status = 'S' THEN
      x_return_status := 0;
    END IF;

    hr_utility.set_location('Leaving: '|| l_proc, 120);

  EXCEPTION
    WHEN e_invalid_params THEN
      hr_utility.set_location('Leaving: '|| l_proc, 130);
      hr_utility.set_location(SQLERRM, 135);
      x_return_status := 1;

    WHEN overlapped THEN
    hr_utility.set_location('raising: '|| l_proc, 125);
    fnd_message.set_name('PER', 'HR_449835_ABS_SCHEDULE_OVERLAP');
    fnd_message.set_token('STARTDATE', fnd_date.date_to_chardate(l_sch_start_date));
    fnd_message.set_token('ENDDATE', fnd_date.date_to_chardate(l_sch_end_date));
    fnd_message.raise_error;

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 140);
      hr_utility.set_location(SQLERRM, 145);
      x_return_status := 2;
      x_return_message := SQLERRM;

  END get_per_asg_schedule;

    --
  -----------------------------------------------------------------------------
  --------------------------< get_working_day >---------------------------
  -----------------------------------------------------------------------------
  --
  -- input parameters : Valid value for prev_next flag is N and P
  -- returns the next/previous working day for a leave request.

    function get_working_day
(
  p_person_assignment_id IN NUMBER
  ,loa_start_date in DATE
  ,loa_end_date in DATE
  ,prev_next_flag in VARCHAR2 default 'N'

) return DATE IS

l_working_date DATE;
l_flag Boolean;
l_schedule_source varchar2(1000);
l_schedule cac_avlblty_time_varray;
l_return_status number;
l_return_message varchar2(1000);
l_busy_tentative_as varchar2(30);
l_wrk_sch_found boolean;
l_free_busy varchar2(30);
l_count NUMBER;



BEGIN

l_flag := true;
l_return_status := 0;
l_schedule := cac_avlblty_time_varray();
l_schedule_source := 'PER_ASG';
l_busy_tentative_as := NVL(l_busy_tentative_as, 'BUSY');
l_wrk_sch_found := false;
l_count := 0;

if prev_next_flag = 'N' then
  l_working_date := loa_end_date + 1;
else
  l_working_date := loa_start_date -1 ;
end if;

 while l_flag LOOP
--get the schedule
 l_count := l_count +1;
 get_per_asg_schedule(p_person_assignment_id
                      ,l_working_date
                      ,l_working_date+1
                      ,null
		              ,null
		              ,l_busy_tentative_as
		              ,l_schedule_source
                      ,l_schedule
                      ,l_return_status
                      ,l_return_message
                      );

  IF l_schedule.COUNT > 1 or (l_schedule.COUNT =1 and l_schedule(1).period_name is not null) THEN
      l_wrk_sch_found := TRUE;
    END IF;

 if l_wrk_sch_found then
  for i in 1..l_schedule.COUNT loop
  l_free_busy := l_schedule(i).FREE_BUSY_TYPE ;
   if l_free_busy is not null and l_free_busy = 'FREE' then
    -- found the working day
     l_flag := false;
   exit ;
   end if;
  end loop;
 end if;

 if l_flag then
  if prev_next_flag = 'N' then
   l_working_date := l_working_date + 1;
  else
   l_working_date := l_working_date -1;
  end if;
 end if ;

 if l_count > 50 then
   -- this condition has been added as an exception condition
   -- to prevent an infinite loop.
   return null;
 end if;


END LOOP;
return l_working_date;

END get_working_day; --end of function

END hr_wrk_sch_pkg;

/
