--------------------------------------------------------
--  DDL for Package PER_ABS_SHADOW_BOOKING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABS_SHADOW_BOOKING_PKG" AUTHID CURRENT_USER AS
  -- $Header: peabsbkg.pkh 120.0 2005/05/31 04:45:10 appldev noship $

  ----------------------------------------------------------------------------
  --
  -- Purpose:-
  --
  -- Create a shadow booking for the absence record.
  --
  -- Parameters:-
  --
  -- P_PERSON_ID       = Identifier of person for whom a shadow booking
  --                     is being created. Must be supplied if Assignment Id
  --                     is not given.
  -- P_ASSIGNMENT_ID   = Identifier of assignment for whom a shadow booking
  --                     is being created. Must be supplied if Person Id is
  --                     not given.
  -- P_ABSENCE_ID      = Identifier of absence for which a shadow booking
  --                     is being created.
  -- P_START_DATE      = Start date of the absence.
  -- P_END_DATE        = End date of the absence.
  -- X_BOOKING_ID      = Identifier generated for the newly created booking
  -- X_RETURN_STATUS   = '0' = success, '1' = warning, '2' = error.
  -- X_RETURN_MESSAGE  = Message in case of return status '1' or '2'.
  --
  ----------------------------------------------------------------------------
  PROCEDURE create_shadow_booking( p_person_id      IN         NUMBER DEFAULT NULL
                                 , p_assignment_id  IN         NUMBER DEFAULT NULL
                                 , p_absence_id     IN         NUMBER
                                 , p_start_date     IN         DATE
                                 , p_end_date       IN         DATE   DEFAULT NULL
                                 , x_booking_id     OUT NOCOPY NUMBER
                                 , x_return_status  OUT NOCOPY NUMBER
                                 , x_return_message OUT NOCOPY VARCHAR2
                                 );

  ----------------------------------------------------------------------------
  --
  -- Purpose:-
  --
  -- Update an existing shadow booking correcponding to changes to the
  -- absence record.
  --
  -- Parameters:-
  --
  -- P_PERSON_ID       = Identifier of person for whom a shadow booking
  --                     is being updated. Must be supplied if Assignment Id
  --                     is not given.
  -- P_ASSIGNMENT_ID   = Identifier of assignment for whom a shadow booking
  --                     is being updated. Must be supplied if Person Id is
  --                     not given.
  -- P_ABSENCE_ID      = Identifier of absence for which a shadow booking
  --                     is being updated.
  -- P_START_DATE      = Start date of the absence.
  -- P_END_DATE        = End date of the absence.
  -- X_RETURN_STATUS   = '0' = success, '1' = warning, '2' = error.
  -- X_RETURN_MESSAGE  = Message in case of return status '1' or '2'.
  --
  ----------------------------------------------------------------------------
  PROCEDURE update_shadow_booking( p_person_id      IN         NUMBER DEFAULT NULL
                                 , p_assignment_id  IN         NUMBER DEFAULT NULL
                                 , p_absence_id     IN         NUMBER
                                 , p_start_date     IN         DATE
                                 , p_end_date       IN         DATE
                                 , x_return_status  OUT NOCOPY NUMBER
                                 , x_return_message OUT NOCOPY VARCHAR2
                                 );

  ----------------------------------------------------------------------------
  --
  -- Purpose:-
  --
  -- Delete an existing shadow booking correcponding to delete of the
  -- absence record.
  --
  -- Parameters:-
  --
  -- P_PERSON_ID       = Identifier of person for whom a shadow booking
  --                     is being deleted. Must be supplied if Assignment Id
  --                     is not given.
  -- P_ASSIGNMENT_ID   = Identifier of assignment for whom a shadow booking
  --                     is being deleted. Must be supplied if Person Id is
  --                     not given.
  -- P_ABSENCE_ID      = Identifier of absence for which a shadow booking
  --                     is being deleted.
  -- X_RETURN_STATUS   = '0' = success, '1' = warning, '2' = error.
  -- X_RETURN_MESSAGE  = Message in case of return status '1' or '2'.
  --
  ----------------------------------------------------------------------------
  PROCEDURE delete_shadow_booking( p_person_id      IN         NUMBER DEFAULT NULL
                                 , p_assignment_id  IN         NUMBER DEFAULT NULL
                                 , p_absence_id     IN         NUMBER
                                 , x_return_status  OUT NOCOPY NUMBER
                                 , x_return_message OUT NOCOPY VARCHAR2
                                 );

  ----------------------------------------------------------------------------
  --
  -- Purpose:-
  --
  -- Retrieve absences as shadow bookings for the given person assignment.
  --
  -- Parameters:-
  --
  -- P_PERSON_ID       = Identifier of person for whom shadow bookings
  --                     are being retrieved. Must be supplied if Assignment
  --                     Id is not given.
  -- P_ASSIGNMENT_ID   = Identifier of assignment for whom shadow bookings
  --                     are being retrieved. Must be supplied if Person
  --                     Id is not given.
  -- P_START_DATE      = Start date of period of interest.
  -- P_END_DATE        = End date of period of interest.
  -- X_BOOKINGS        = Varray of bookings retrieved for the person and
  --                     period.
  -- X_RETURN_STATUS   = '0' = success, '1' = warning, '2' = error.
  -- X_RETURN_MESSAGE  = Message in case of return status '1' or '2'.
  --
  ----------------------------------------------------------------------------
  PROCEDURE get_shadow_booking( p_person_id      IN         NUMBER DEFAULT NULL
                              , p_assignment_id  IN         NUMBER DEFAULT NULL
                              , p_start_date     IN         DATE   DEFAULT NULL
                              , p_end_date       IN         DATE   DEFAULT NULL
                              , x_bookings       OUT NOCOPY per_abs_booking_varray
                              , x_return_status  OUT NOCOPY NUMBER
                              , x_return_message OUT NOCOPY VARCHAR2
                              );

END per_abs_shadow_booking_pkg;

 

/
