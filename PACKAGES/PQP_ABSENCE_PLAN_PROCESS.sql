--------------------------------------------------------
--  DDL for Package PQP_ABSENCE_PLAN_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ABSENCE_PLAN_PROCESS" AUTHID CURRENT_USER AS
/* $Header: pqabproc.pkh 120.0 2005/05/29 01:41:10 appldev noship $ */
--
  PROCEDURE create_absence_plan_details(
    p_person_id                 IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_legislation_code          IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_element_type_id           IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_per_in_ler_id             IN       NUMBER
   ,p_absence_attendance_id     IN       NUMBER
   ,p_effective_start_date      IN       DATE
   ,p_effective_end_date        IN       DATE
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  );
--
  PROCEDURE update_absence_plan_details(
    p_person_id                 IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_legislation_code          IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_element_type_id           IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_per_in_ler_id             IN       NUMBER
   ,p_absence_attendance_id     IN       NUMBER
   ,p_effective_start_date      IN       DATE
   ,p_effective_end_date        IN       DATE -- NULL 31-DEC-4712
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  );
--
  PROCEDURE delete_absence_plan_details(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_legislation_code          IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_per_in_ler_id             IN       NUMBER
   ,p_absence_attendance_id     IN       NUMBER
   ,p_effective_start_date      IN       DATE
   ,p_effective_end_date        IN       DATE -- NULL 31-DEC-4712
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_element_type_id           IN       NUMBER DEFAULT NULL
  );


FUNCTION is_gap_absence_type(
 p_absence_attendance_type_id IN NUMBER
 )
RETURN NUMBER ;


FUNCTION is_absence_overlapped(
 p_absence_attendance_id IN NUMBER
 )
RETURN BOOLEAN ;

END;

 

/
