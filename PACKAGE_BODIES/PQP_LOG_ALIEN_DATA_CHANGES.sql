--------------------------------------------------------
--  DDL for Package Body PQP_LOG_ALIEN_DATA_CHANGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_LOG_ALIEN_DATA_CHANGES" as
/* $Header: pquslapc.pkb 115.2 2002/10/28 23:41:34 sshetty ship $*/
-----------------------------------------------------------------------------
-- CHECK_FOR_CHANGES
-----------------------------------------------------------------------------
PROCEDURE check_for_changes (p_assignment_id    in number
                            ,p_person_id        in number
                            ,p_effective_date   in date
                            ,p_new_value_char1  in varchar2
                            ,p_old_value_char1  in varchar2
                            ,p_new_value_char2  in varchar2
                            ,p_old_value_char2  in varchar2
                            ,p_new_value_char3  in varchar2
                            ,p_old_value_char3  in varchar2
                            ,p_new_value_char4  in varchar2
                            ,p_old_value_char4  in varchar2
                            ,p_new_value_char5  in varchar2
                            ,p_old_value_char5  in varchar2
                            ,p_new_value_char6  in varchar2
                            ,p_old_value_char6  in varchar2
                            ,p_new_value_char7  in varchar2
                            ,p_old_value_char7  in varchar2
                            ,p_new_value_char8  in varchar2
                            ,p_old_value_char8  in varchar2
                            ,p_new_value_char9  in varchar2
                            ,p_old_value_char9  in varchar2
                            ,p_new_value_char10 in varchar2
                            ,p_old_value_char10 in varchar2
                            ,p_new_value_date1  in date
                            ,p_old_value_date1  in date
                            ,p_new_value_date2  in date
                            ,p_old_value_date2  in date     ) IS
   --
   -- this procedure accepts old and new values, compares the values
   -- and if there are any changes, it calls the log events procedure.
   --
   l_proc  VARCHAR2(60) := 'pqp_log_alien_data_changes.check_for_changes';
   --
BEGIN
   hr_utility.set_location('Entering: '||l_proc, 10);
   --
   -- Log the events only if the process type is WINDSTAR
   --
   IF pqp_us_ff_functions.is_windstar
              (p_person_id     => p_person_id
              ,p_assignment_id => NULL ) = 'TRUE' THEN
      IF NVL(p_old_value_char1, ' ')    <> NVL(p_new_value_char1, ' ')    OR
         NVL(p_old_value_char2, ' ')    <> NVL(p_new_value_char2, ' ')    OR
         NVL(p_old_value_char3, ' ')    <> NVL(p_new_value_char3, ' ')    OR
         NVL(p_old_value_char4, ' ')    <> NVL(p_new_value_char4, ' ')    OR
         NVL(p_old_value_char5, ' ')    <> NVL(p_new_value_char5, ' ')    OR
         NVL(p_old_value_char6, ' ')    <> NVL(p_new_value_char6, ' ')    OR
         NVL(p_old_value_char7, ' ')    <> NVL(p_new_value_char7, ' ')    OR
         NVL(p_old_value_char8, ' ')    <> NVL(p_new_value_char8, ' ')    OR
         NVL(p_old_value_char9, ' ')    <> NVL(p_new_value_char9, ' ')    OR
         NVL(p_old_value_char10,' ')    <> NVL(p_new_value_char10,' ')    OR
         NVL(p_old_value_date1,sysdate) <> NVL(p_new_value_date1,sysdate) OR
         NVL(p_old_value_date2,sysdate) <> NVL(p_new_value_date2,sysdate) THEN
         --
         -- log the event
         --
         log_events(p_assignment_id  => p_assignment_id
                   ,p_effective_date => p_effective_date);
         --
         hr_utility.set_location(l_proc, 20);
      END IF;
   END IF;
   --
   hr_utility.set_location('Leaving: '||l_proc, 10);
   --
END check_for_changes;
-----------------------------------------------------------------------------
--                            ALIEN_ELEMENT_CHECK
-----------------------------------------------------------------------------
PROCEDURE alien_element_check (p_assignment_id    in number
                              ,p_effective_date   in date
                              ,p_element_link_id  in number ) IS
   --
   -- we need to log the event when a employee gets an alien earnings. This
   -- procedure checks this and calls the log_events procedure.
   --
   CURSOR c_element IS
   SELECT pet.element_type_id,
          pet.element_information1 inc_code             ---'x'
   FROM   pay_element_types_f  PET,
          pay_element_links_f  PEL
   WHERE  PEL.element_link_id = p_element_link_id
     AND  PEL.element_type_id = PET.element_type_id
     AND  p_effective_date BETWEEN PET.effective_start_date AND
                                   PET.effective_end_date
     AND  p_effective_date BETWEEN PEL.effective_start_date AND
                                   PEL.effective_end_date
     AND  EXISTS (SELECT 'x'
                  FROM   pay_element_classifications PEC
                  WHERE  PEC.classification_id   = PET.classification_id
                    AND  PEC.classification_name = 'Alien/Expat Earnings'
                    AND  PEC.legislation_code    = 'US' );

    CURSOR c_get_curent_code(cp_assignment_id NUMBER
                            ,cp_effective_date DATE
                            ,cp_inc_code  VARCHAR2) IS
    SELECT 'X'
      FROM pqp_analyzed_alien_details paad
          ,pqp_analyzed_alien_data pad
    where  pad.analyzed_data_id=paad.analyzed_data_id
      and pad.tax_year=to_number(to_char(cp_effective_date,'YYYY'))
      and pad.assignment_id=cp_assignment_id
      and pad.data_source='PQP_US_ALIEN_WINDSTAR'
      AND paad.income_code=cp_inc_code;

    l_get_curent_code c_get_curent_code%ROWTYPE;
    l_exist           VARCHAR2(1):='N';

   --
   l_proc  VARCHAR2(60) := 'pqp_log_alien_data_changes.alien_element_check';
   --
BEGIN
   hr_utility.set_location('Entering: '||l_proc, 10);
   --
   l_exist:='N';
   FOR c_element_rec in c_element LOOP
     OPEN c_get_curent_code (p_assignment_id,
                             p_effective_date,
                             c_element_rec.inc_code);
     FETCH c_get_curent_code INTO l_get_curent_code;
     IF c_get_curent_code%NOTFOUND THEN
        log_events(p_assignment_id  => p_assignment_id
                  ,p_effective_date => p_effective_date);
     END IF;
     CLOSE c_get_curent_code;
     --
     hr_utility.set_location(l_proc, 20);
   END LOOP;
   hr_utility.set_location('Leaving: '||l_proc, 10);
   --
END alien_element_check;
-----------------------------------------------------------------------------
--                            PERSON_LEVEL_CHECK
-----------------------------------------------------------------------------
PROCEDURE person_level_check
           (p_person_id         in number
           ,p_table_name        in varchar2
           ,p_effective_date    in date
           ,p_new_value_char1   in varchar2
           ,p_old_value_char1   in varchar2
           ,p_new_value_char2   in varchar2
           ,p_old_value_char2   in varchar2
           ,p_new_value_char3   in varchar2
           ,p_old_value_char3   in varchar2
           ,p_new_value_char4   in varchar2
           ,p_old_value_char4   in varchar2
           ,p_new_value_char5   in varchar2
           ,p_old_value_char5   in varchar2
           ,p_new_value_char6   in varchar2
           ,p_old_value_char6   in varchar2
           ,p_new_value_char7   in varchar2
           ,p_old_value_char7   in varchar2
           ,p_new_value_char8   in varchar2
           ,p_old_value_char8   in varchar2
           ,p_new_value_char9   in varchar2
           ,p_old_value_char9   in varchar2
           ,p_new_value_char10  in varchar2
           ,p_old_value_char10  in varchar2
           ,p_new_value_date1   in date
           ,p_old_value_date1   in date
           ,p_new_value_date2   in date
           ,p_old_value_date2   in date     ) IS
   --
   -- called from all the person related triggers like person, person extra
   -- info etc. Validates if there are any changes and logs all the
   -- assignments into the process log
   --
   l_proc  VARCHAR2(60) := 'pqp_log_alien_data_changes.person_level_check';
   --
   l_session_date    DATE          := p_effective_date;
   l_continue        BOOLEAN       := TRUE;
   l_new_char1       VARCHAR2(80);
   l_old_char1       VARCHAR2(80);
   l_new_char2       VARCHAR2(80);
   l_old_char2       VARCHAR2(80);
   l_new_char3       VARCHAR2(80);
   l_old_char3       VARCHAR2(80);
   l_new_char4       VARCHAR2(80);
   l_old_char4       VARCHAR2(80);
   l_new_char5       VARCHAR2(80);
   l_old_char5       VARCHAR2(80);
   l_new_char6       VARCHAR2(80);
   l_old_char6       VARCHAR2(80);
   l_new_char7       VARCHAR2(80);
   l_old_char7       VARCHAR2(80);
   l_new_char8       VARCHAR2(80);
   l_old_char8       VARCHAR2(80);
   l_new_char9       VARCHAR2(80);
   l_old_char9       VARCHAR2(80);
   l_new_char10      VARCHAR2(80);
   l_old_char10      VARCHAR2(80);
   --
   CURSOR c_session IS
   SELECT effective_date
   FROM   fnd_sessions
   WHERE  session_id = userenv('sessionid');
   --
   CURSOR c_assign IS
   SELECT assignment_id
   FROM   per_assignments_f
   WHERE  person_id           = p_person_id
   --AND  effective_end_date >= NVL(l_session_date, sysdate);
     AND  NVL(l_session_date, sysdate) BETWEEN
          effective_start_date AND effective_end_date;
   --
BEGIN
   hr_utility.set_location('Entering: '||l_proc, 10);
   --
   --   For address, log the changes only if the primary_flag = 'Y'
   --
   IF (p_table_name        = 'PER_ADDRESSES'         AND
      p_new_value_char1    = 'N')                    THEN
      hr_utility.set_location(l_proc, 20);
      -- do not do log changes if the address is secondary
   ELSIF p_table_name      = 'PER_PEOPLE_EXTRA_INFO' THEN
     /*
      *  ***  PLEASE NOTE the column mapping ***
      *
      *  p_new_value_char2  = pei_information5
      *  p_new_value_char3  = pei_information6
      *  p_new_value_char4  = pei_information7
      *  p_new_value_char5  = pei_information8
      *  p_new_value_char6  = pei_information9
      *  p_new_value_char7  = pei_information10
      *  p_new_value_char8  = pei_information11
      *  p_new_value_char9  = pei_information12
      *  p_new_value_char10 = pei_information13
      */
      IF p_new_value_char1 = 'PER_US_VISA_DETAILS'      THEN
         hr_utility.set_location(l_proc, 30);
         l_new_char2 := p_new_value_char2; -- Visa type (info 5)
         l_old_char2 := p_old_value_char2;
         l_new_char3 := p_new_value_char3; -- Visa number (info 6)
         l_old_char3 := p_old_value_char3;
         l_new_char4 := p_new_value_char4; -- Visa issue date (info 7)
         l_old_char4 := p_old_value_char4;
         l_new_char5 := p_new_value_char5; -- Visa expiry date (info 8)
         l_old_char5 := p_old_value_char5;
         l_new_char6 := p_new_value_char6; -- Visa category (info 9)
         l_old_char6 := p_old_value_char6;
         --
      ELSIF p_new_value_char1 = 'PER_US_PASSPORT_DETAILS' THEN
         hr_utility.set_location(l_proc, 40);
         l_new_char2 := p_new_value_char2; -- country (info 5)
         l_old_char2 := p_old_value_char2;
         --
      ELSIF p_new_value_char1 = 'PER_US_PAYROLL_DETAILS' THEN
         hr_utility.set_location(l_proc, 50);
         l_new_char2 := p_new_value_char2; -- Income code (info 5)
         l_old_char2 := p_old_value_char2;
         l_new_char3 := p_new_value_char3; -- Prev ER treaty ben amt(info 6)
         l_old_char3 := p_old_value_char3;
         l_new_char4 := p_new_value_char4; -- Prev ER treaty ben year (info 7)
         l_old_char4 := p_old_value_char4;
         --
      ELSIF p_new_value_char1 = 'PER_US_ADDITIONAL_DETAILS' THEN
         hr_utility.set_location(l_proc, 60);
         l_new_char2 := p_new_value_char2; -- Residency Status (info 5)
         l_old_char2 := p_old_value_char2;
         l_new_char3 := p_new_value_char4; -- Resident Status Date (info 8)
         l_old_char3 := p_old_value_char4;
         l_new_char4 := p_new_value_char5; -- First entry date (info 8)
         l_old_char4 := p_old_value_char5;
         l_new_char5 := p_new_value_char6; -- Tax res country code (info 9)
         l_old_char5 := p_old_value_char6;
         l_new_char6 := p_new_value_char9; -- Process Type (info 12)
         l_old_char6 := p_old_value_char9;
         --
      END IF;
      -- call for each assignment
      FOR c_rec in c_assign LOOP
         hr_utility.set_location(l_proc, 70);
         --
         FOR c_rec in c_session LOOP
            l_session_date := c_rec.effective_date;
         END LOOP;
         --
         check_for_changes(p_assignment_id    => c_rec.assignment_id
                          ,p_person_id        => p_person_id
                          ,p_effective_date   => l_session_date
                          ,p_new_value_char1  => l_new_char1
                          ,p_old_value_char1  => l_old_char1
                          ,p_new_value_char2  => l_new_char2
                          ,p_old_value_char2  => l_old_char2
                          ,p_new_value_char3  => l_new_char3
                          ,p_old_value_char3  => l_old_char3
                          ,p_new_value_char4  => l_new_char4
                          ,p_old_value_char4  => l_old_char4
                          ,p_new_value_char5  => l_new_char5
                          ,p_old_value_char5  => l_old_char5
                          ,p_new_value_char6  => l_new_char6
                          ,p_old_value_char6  => l_old_char6
                          ,p_new_value_char7  => l_new_char7
                          ,p_old_value_char7  => l_old_char7  );
      END LOOP;
   ELSE
      hr_utility.set_location(l_proc, 80);
      IF l_session_date IS NULL THEN
         FOR c_rec in c_session LOOP
            hr_utility.set_location(l_proc, 90);
            l_session_date := c_rec.effective_date;
         END LOOP;
      END IF;
      --
      FOR c_rec in c_assign LOOP
         hr_utility.set_location(l_proc, 100);
         check_for_changes(p_assignment_id    => c_rec.assignment_id
                          ,p_person_id        => p_person_id
                          ,p_effective_date   => l_session_date
                          ,p_new_value_char1  => p_new_value_char1
                          ,p_old_value_char1  => p_old_value_char1
                          ,p_new_value_char2  => p_new_value_char2
                          ,p_old_value_char2  => p_old_value_char2
                          ,p_new_value_char3  => p_new_value_char3
                          ,p_old_value_char3  => p_old_value_char3
                          ,p_new_value_char4  => p_new_value_char4
                          ,p_old_value_char4  => p_old_value_char4
                          ,p_new_value_char5  => p_new_value_char5
                          ,p_old_value_char5  => p_old_value_char5
                          ,p_new_value_char6  => p_new_value_char6
                          ,p_old_value_char6  => p_old_value_char6
                          ,p_new_value_char7  => p_new_value_char7
                          ,p_old_value_char7  => p_old_value_char7
                          ,p_new_value_char8  => p_new_value_char8
                          ,p_old_value_char8  => p_old_value_char8
                          ,p_new_value_char9  => p_new_value_char9
                          ,p_old_value_char9  => p_old_value_char9
                          ,p_new_value_char10 => p_new_value_char10
                          ,p_old_value_char10 => p_old_value_char10
                          ,p_new_value_date1  => p_new_value_date1
                          ,p_old_value_date1  => p_old_value_date1
                          ,p_new_value_date2  => p_new_value_date2
                          ,p_old_value_date2  => p_old_value_date2 );
         --
         hr_utility.set_location(l_proc, 110);
      END LOOP;
   END IF;
   hr_utility.set_location('Leaving: '||l_proc, 150);
   --
END person_level_check;
-----------------------------------------------------------------------------
-- LOG_EVENTS
-----------------------------------------------------------------------------
PROCEDURE log_events (p_assignment_id   in number
                     ,p_effective_date  in date   ) IS
   --
   -- Procedure to check whether the event is already logged, if not it logs
   -- the event in the table pay_process_events.
   --
   CURSOR c_asg_exists is
   SELECT 'x'
   FROM   pay_process_events
   WHERE  assignment_id = p_assignment_id
     AND  change_type   = 'PQP_US_ALIEN_WINDSTAR'
     AND  status in ('N', 'D'); -- NOT_READ, DATA_VALIDATION_FAILED
   --
   l_temp   varchar2(10);
   l_dummy1 number;
   l_dummy2 number;
   l_proc  VARCHAR2(60) := 'pqp_log_alien_data_changes.log_events';
   --
BEGIN
   hr_utility.set_location('Entering: '||l_proc, 10);
   --
   OPEN c_asg_exists;
   FETCH c_asg_exists into l_temp;
   IF c_asg_exists%NOTFOUND THEN
      BEGIN
         --call pay_process_events API
         pay_ppe_api.create_process_event
            (p_validate                  => FALSE
            ,p_assignment_id             => p_assignment_id
            ,p_effective_date            => p_effective_date
            ,p_change_type               => 'PQP_US_ALIEN_WINDSTAR'
            ,p_status                    => 'N'
            ,p_description               => 'PQP event logging'
            ,p_process_event_id          => l_dummy1
            ,p_object_version_number     => l_dummy2 );
      --
      hr_utility.set_location(l_proc, 20);
      --
      EXCEPTION
         WHEN OTHERS THEN
         hr_utility.set_location(l_proc, 50);
         raise;
      END;
   END IF;
   CLOSE c_asg_exists;
   --
   hr_utility.set_location('Leaving: '||l_proc, 100);
   --
END log_events;
-----------------------------------------------------------------------------
-- LOG_PEI_INSERT_CHANGES
-----------------------------------------------------------------------------
PROCEDURE log_pei_insert_changes (p_person_id          in number
                                 ,p_information_type   in varchar2
                                 ,p_pei_information5   in varchar2
                                 ,p_pei_information6   in varchar2
                                 ,p_pei_information7   in varchar2
                                 ,p_pei_information8   in varchar2
                                 ,p_pei_information9   in varchar2
                                 ,p_pei_information10  in varchar2
                                 ,p_pei_information11  in varchar2
                                 ,p_pei_information12  in varchar2
                                 ,p_pei_information13  in varchar2 ) IS
   --
   -- Procedure which will be called by the PER_PEOPLE_EXTRA_INFO API USER
   -- HOOKS to check whether the event is already logged.
   -- Legislative user hook is used due to mutating table problem for
   -- dynamic triggers on this table.
   --
   l_proc  VARCHAR2(60) := 'pqp_log_alien_data_changes.log_pei_insert_changes';
   --
BEGIN
   hr_utility.set_location('Entering: '||l_proc, 10);
   --
   person_level_check
           (p_person_id         => p_person_id
           ,p_table_name        => 'PER_PEOPLE_EXTRA_INFO'
           ,p_effective_date    => NULL
           ,p_new_value_char1   => p_information_type
           ,p_old_value_char1   => NULL
           ,p_new_value_char2   => p_pei_information5
           ,p_old_value_char2   => NULL
           ,p_new_value_char3   => p_pei_information6
           ,p_old_value_char3   => NULL
           ,p_new_value_char4   => p_pei_information7
           ,p_old_value_char4   => NULL
           ,p_new_value_char5   => p_pei_information8
           ,p_old_value_char5   => NULL
           ,p_new_value_char6   => p_pei_information9
           ,p_old_value_char6   => NULL
           ,p_new_value_char7   => p_pei_information10
           ,p_old_value_char7   => NULL
           ,p_new_value_char8   => p_pei_information11
           ,p_old_value_char8   => NULL
           ,p_new_value_char9   => p_pei_information12
           ,p_old_value_char9   => NULL
           ,p_new_value_char10  => p_pei_information13
           ,p_old_value_char10  => NULL );
   --
   hr_utility.set_location('Leaving: '||l_proc, 20);
   --
END log_pei_insert_changes;
-----------------------------------------------------------------------------
-- LOG_PEI_UPDATE_CHANGES
-----------------------------------------------------------------------------
PROCEDURE log_pei_update_changes
                   (p_person_id           in number
                   ,p_information_type    in varchar2
                   ,p_information_type_o  in varchar2
                   ,p_pei_information5    in varchar2
                   ,p_pei_information5_o  in varchar2
                   ,p_pei_information6    in varchar2
                   ,p_pei_information6_o  in varchar2
                   ,p_pei_information7    in varchar2
                   ,p_pei_information7_o  in varchar2
                   ,p_pei_information8    in varchar2
                   ,p_pei_information8_o  in varchar2
                   ,p_pei_information9    in varchar2
                   ,p_pei_information9_o  in varchar2
                   ,p_pei_information10   in varchar2
                   ,p_pei_information10_o in varchar2
                   ,p_pei_information11   in varchar2
                   ,p_pei_information11_o in varchar2
                   ,p_pei_information12   in varchar2
                   ,p_pei_information12_o in varchar2
                   ,p_pei_information13   in varchar2
                   ,p_pei_information13_o in varchar2 ) IS
   --
   l_proc  VARCHAR2(60) := 'pqp_log_alien_data_changes.log_pei_update_changes';
   --
BEGIN
   hr_utility.set_location('Entering: '||l_proc, 10);
   --
   person_level_check
           (p_person_id         => p_person_id
           ,p_table_name        => 'PER_PEOPLE_EXTRA_INFO'
           ,p_effective_date    => NULL
           ,p_new_value_char1   => p_information_type
           ,p_old_value_char1   => p_information_type_o
           ,p_new_value_char2   => p_pei_information5
           ,p_old_value_char2   => p_pei_information5_o
           ,p_new_value_char3   => p_pei_information6
           ,p_old_value_char3   => p_pei_information6_o
           ,p_new_value_char4   => p_pei_information7
           ,p_old_value_char4   => p_pei_information7_o
           ,p_new_value_char5   => p_pei_information8
           ,p_old_value_char5   => p_pei_information8_o
           ,p_new_value_char6   => p_pei_information9
           ,p_old_value_char6   => p_pei_information9_o
           ,p_new_value_char7   => p_pei_information10
           ,p_old_value_char7   => p_pei_information10_o
           ,p_new_value_char8   => p_pei_information11
           ,p_old_value_char8   => p_pei_information11_o
           ,p_new_value_char9   => p_pei_information12
           ,p_old_value_char9   => p_pei_information12_o
           ,p_new_value_char10  => p_pei_information13
           ,p_old_value_char10  => p_pei_information13_o );
           --
   hr_utility.set_location('Leaving: '||l_proc, 20);
   --
END log_pei_update_changes;
--
END pqp_log_alien_data_changes;

/
