--------------------------------------------------------
--  DDL for Package PER_GET_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GET_ELIG" AUTHID CURRENT_USER AS
  -- $Header: perellst.pkh 120.0 2005/05/31 17:36:24 appldev noship $

  ----------------------------------------------------------------------------
  --
  -- Purpose:-
  --
  -- List the Eligibility Objects that the given Person Assignment
  -- is eligible for.
  --
  -- Parameters:-
  --
  -- P_PERSON_ID       = Identifier of person for whom eligible objects
  --                     are required to be listed.
  -- P_ASSIGNMENT_ID   = Identifier of assignment for which eligible objects
  --                     are required to be listed. If null, objects are
  --                     listed for all the assignments.
  -- P_EFFECTIVE_DATE  = Effective date for testing eligibility.
  -- P_TABLE_NAME      = Eligibility object type.
  -- P_DATA_MODE       = 'L' for Live date (default)
  --                     'C' for Cached data.
  -- X_ELIGIBLE_OBJECT = VARRAY listing eligible object details.
  -- X_RETURN_STATUS   = '0' = success, '1' = warning, '2' = error.
  -- X_RETURN_MESSAGE  = Message in case of return status '1' or '2'.
  --
  ----------------------------------------------------------------------------
  PROCEDURE get_elig_obj_for_per_asg( p_person_id       IN         NUMBER
                                    , p_assignment_id   IN         NUMBER   DEFAULT NULL
                                    , p_effective_date  IN         DATE
                                    , p_table_name      IN         VARCHAR2
                                    , p_data_mode       IN         VARCHAR2 DEFAULT NULL
                                    , x_eligible_object OUT NOCOPY per_elig_obj_varray
                                    , x_return_status   OUT NOCOPY NUMBER
                                    , x_return_message  OUT NOCOPY VARCHAR2
                                    );

  ----------------------------------------------------------------------------
  --
  -- Purpose:-
  --
  -- List the Person Assignment that are eligible for the given
  -- Eligibility Object.
  --
  -- Parameters:-
  --
  -- P_TABLE_NAME        = Eligibility object type.
  -- P_COLUMN_NAME       = Key column for eligibility object type.
  -- P_COLUMN_VALUE      = Eligibility object instance.
  -- P_EFFECTIVE_DATE    = Effective date for testing eligibility.
  -- P_BUSINESS_GROUP_ID = Business group identifier to which the listed
  --                       person assignments should belong.
  -- P_DATA_MODE         = 'L' for Live date (default)
  --                       'C' for Cached data.
  -- P_PERSON_ASSIGNMENT = VARRAY listing person assignment details.
  -- X_RETURN_STATUS     = '0' = success, '1' = warning, '2' = error.
  -- X_RETURN_MESSAGE    = Message in case of return status '1' or '2'.
  --
  ----------------------------------------------------------------------------
  PROCEDURE get_per_asg_for_elig_obj( p_table_name        IN         VARCHAR2
                                    , p_column_name       IN         VARCHAR2
                                    , p_column_value      IN         VARCHAR2
                                    , p_effective_date    IN         DATE
                                    , p_business_group_id IN         NUMBER
                                    , p_data_mode         IN         VARCHAR2 DEFAULT NULL
                                    , x_person_assignment OUT NOCOPY per_asg_varray
                                    , x_return_status     OUT NOCOPY NUMBER
                                    , x_return_message    OUT NOCOPY VARCHAR2
                                    );

  ----------------------------------------------------------------------------
  --
  -- Purpose:-
  --
  -- List the Work Schedules that the given Person Assignment
  -- is eligible for.
  --
  -- Parameters:-
  --
  -- P_PERSON_ID       = Identifier of person for whom work schedules are
  --                     required to be listed.
  -- P_ASSIGNMENT_ID   = Identifier of assignment for which work schedules
  --                     are required to be listed. If null, schedules are
  --                     listed for all the assignments.
  -- P_EFFECTIVE_DATE  = Effective date for testing eligibility.
  -- P_DATA_MODE       = 'L' for Live date (default)
  --                     'C' for Cached data.
  -- X_SCHEDULE        = VARRAY listing eligible work schedule details.
  -- X_RETURN_STATUS   = '0' = success, '1' = warning, '2' = error.
  -- X_RETURN_MESSAGE  = Message in case of return status '1' or '2'.
  --
  ----------------------------------------------------------------------------
  PROCEDURE get_sch_for_per_asg( p_person_id         IN         NUMBER
                               , p_assignment_id     IN         NUMBER   DEFAULT NULL
                               , p_effective_date    IN         DATE
                               , p_data_mode         IN         VARCHAR2 DEFAULT NULL
                               , x_schedule          OUT NOCOPY per_work_sch_varray
                               , x_return_status     OUT NOCOPY NUMBER
                               , x_return_message    OUT NOCOPY VARCHAR2
                               );

  ----------------------------------------------------------------------------
  --
  -- Purpose:-
  --
  -- List the Person Assignment that are eligible for the given
  -- Schedule.
  --
  -- Parameters:-
  --
  -- P_SCHEDULE_CATEGORY = Work schedule category.
  -- P_SCHEDULE_NAME     = Work schedule name.
  -- P_EFFECTIVE_DATE    = Effective date for testing eligibility.
  -- P_BUSINESS_GROUP_ID = Business group identifier to which the listed
  --                       person assignments should belong.
  -- P_DATA_MODE         = 'L' for Live date (default)
  --                       'C' for Cached data.
  -- P_PERSON_ASSIGNMENT = VARRAY listing person assignment details.
  -- X_RETURN_STATUS     = '0' = success, '1' = warning, '2' = error.
  -- X_RETURN_MESSAGE    = Message in case of return status '1' or '2'.
  --
  ----------------------------------------------------------------------------
  PROCEDURE get_per_asg_for_sch( p_schedule_category IN         VARCHAR2
                               , p_schedule_name     IN         VARCHAR2
                               , p_effective_date    IN         DATE
                               , p_business_group_id IN         NUMBER
                               , p_data_mode         IN         VARCHAR2 DEFAULT NULL
                               , x_person_assignment OUT NOCOPY per_asg_varray
                               , x_return_status     OUT NOCOPY NUMBER
                               , x_return_message    OUT NOCOPY VARCHAR2
                               );

END per_get_elig;

 

/
