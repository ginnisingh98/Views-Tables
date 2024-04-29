--------------------------------------------------------
--  DDL for Package PQP_LOG_ALIEN_DATA_CHANGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_LOG_ALIEN_DATA_CHANGES" AUTHID CURRENT_USER AS
/* $Header: pquslapc.pkh 120.0 2005/05/29 02:13:38 appldev noship $*/
-----------------------------------------------------------------------------
-- CHECK_FOR_CHANGES
-----------------------------------------------------------------------------
PROCEDURE check_for_changes (p_assignment_id    in number
                            ,p_person_id        in number
                            ,p_effective_date   in date
                            ,p_new_value_char1  in varchar2 default null
                            ,p_old_value_char1  in varchar2 default null
                            ,p_new_value_char2  in varchar2 default null
                            ,p_old_value_char2  in varchar2 default null
                            ,p_new_value_char3  in varchar2 default null
                            ,p_old_value_char3  in varchar2 default null
                            ,p_new_value_char4  in varchar2 default null
                            ,p_old_value_char4  in varchar2 default null
                            ,p_new_value_char5  in varchar2 default null
                            ,p_old_value_char5  in varchar2 default null
                            ,p_new_value_char6  in varchar2 default null
                            ,p_old_value_char6  in varchar2 default null
                            ,p_new_value_char7  in varchar2 default null
                            ,p_old_value_char7  in varchar2 default null
                            ,p_new_value_char8  in varchar2 default null
                            ,p_old_value_char8  in varchar2 default null
                            ,p_new_value_char9  in varchar2 default null
                            ,p_old_value_char9  in varchar2 default null
                            ,p_new_value_char10 in varchar2 default null
                            ,p_old_value_char10 in varchar2 default null
                            ,p_new_value_date1  in date     default null
                            ,p_old_value_date1  in date     default null
                            ,p_new_value_date2  in date     default null
                            ,p_old_value_date2  in date     default null);
   -- procedrue to check for changes in values and calls the log events
   -- procedure
-----------------------------------------------------------------------------
--                            ALIEN_ELEMENT_CHECK
-----------------------------------------------------------------------------
PROCEDURE alien_element_check (p_assignment_id    in number
                              ,p_effective_date   in date
                              ,p_element_link_id  in number );
  --
  -- we need to log the event when a employee gets a alien earnings. This
  -- procedure checks this and calls the log_events procedure.
  --
-----------------------------------------------------------------------------
--                            PERSON_LEVEL_CHECK
-----------------------------------------------------------------------------
PROCEDURE person_level_check
           (p_person_id         in number
           ,p_table_name        in varchar2
           ,p_effective_date    in date     default NULL
           ,p_new_value_char1   in varchar2 default null
           ,p_old_value_char1   in varchar2 default null
           ,p_new_value_char2   in varchar2 default null
           ,p_old_value_char2   in varchar2 default null
           ,p_new_value_char3   in varchar2 default null
           ,p_old_value_char3   in varchar2 default null
           ,p_new_value_char4   in varchar2 default null
           ,p_old_value_char4   in varchar2 default null
           ,p_new_value_char5   in varchar2 default null
           ,p_old_value_char5   in varchar2 default null
           ,p_new_value_char6   in varchar2 default null
           ,p_old_value_char6   in varchar2 default null
           ,p_new_value_char7   in varchar2 default null
           ,p_old_value_char7   in varchar2 default null
           ,p_new_value_char8   in varchar2 default null
           ,p_old_value_char8   in varchar2 default null
           ,p_new_value_char9   in varchar2 default null
           ,p_old_value_char9   in varchar2 default null
           ,p_new_value_char10  in varchar2 default null
           ,p_old_value_char10  in varchar2 default null
           ,p_new_value_date1   in date     default null
           ,p_old_value_date1   in date     default null
           ,p_new_value_date2   in date     default null
           ,p_old_value_date2   in date     default null);
   --
   -- called by all person level triggers, gets the assignment and checks
   -- for changes before logging
   --
-----------------------------------------------------------------------------
-- LOG_EVENTS
-----------------------------------------------------------------------------
PROCEDURE log_events (p_assignment_id   in number
                     ,p_effective_date  in date   );
  --
  -- Procedure to check whether the event is already logged, if not it logs
  -- the event in the table pay_process_events.
  --
-----------------------------------------------------------------------------
-- LOG_EXTRA_INFO_CHANGES
-----------------------------------------------------------------------------
PROCEDURE log_pei_insert_changes
                   (p_person_id          in number
                   ,p_information_type   in varchar2
                   ,p_pei_information5   in varchar2
                   ,p_pei_information6   in varchar2
                   ,p_pei_information7   in varchar2
                   ,p_pei_information8   in varchar2
                   ,p_pei_information9   in varchar2
                   ,p_pei_information10  in varchar2
                   ,p_pei_information11  in varchar2
                   ,p_pei_information12  in varchar2
                   ,p_pei_information13  in varchar2 );
   --
   -- Procedure which will be called by the PER_PEOPLE_EXTRA_INFO API USER
   -- HOOKS to check whether the event is already logged.
   -- Legislative user hook is used due to mutating table problem for
   -- dynamic triggers on this table.
   --
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
                   ,p_pei_information13_o in varchar2 );
   --
   -- Procedure which will be called by the PER_PEOPLE_EXTRA_INFO API USER
   -- HOOKS to check whether the event is already logged.
   --
-------------------------------
END pqp_log_alien_data_changes;

 

/
