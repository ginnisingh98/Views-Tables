--------------------------------------------------------
--  DDL for Package PQP_GB_ABSENCE_PLAN_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_ABSENCE_PLAN_PROCESS" AUTHID CURRENT_USER AS
/* $Header: pqgbabpr.pkh 115.5 2003/07/17 05:48:23 rrazdan noship $ */

  CURSOR csr_absence_pay_plan_category(p_pl_id NUMBER)
  IS
    SELECT eit.eei_information30 -- Absence Pay Plan Category
                                                    absence_pay_plan_category
    FROM   pay_element_type_extra_info eit
    WHERE  UPPER(eit.eei_information19) = 'ABSENCE INFO'
    AND    eit.information_type IN -- either
              ('PQP_GB_OSP_ABSENCE_PLAN_INFO', 'PQP_GB_OMP_ABSENCE_PLAN_INFO')
    AND    eit.eei_information1 = fnd_number.number_to_canonical(p_pl_id)
    AND    ROWNUM < 2; -- any element will do
--
--
--
  CURSOR csr_abs_plan_category_by_eid(p_element_type_id NUMBER) IS
  SELECT eit.eei_information30 absence_pay_plan_category
  FROM   pay_element_type_extra_info eit
  WHERE  eit.element_type_id = p_element_type_id
    AND  ( -- is OSP Primary Element
          ( eit.information_type = 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
           AND
           eit.eei_information16 = 'Y' -- primary OSP
          )
       OR -- is OMP Primary Element
          ( eit.information_type =  'PQP_GB_OMP_ABSENCE_PLAN_INFO'
            AND
            eit.eei_information17 = 'Y' -- primary OMP
          )
         )
    AND  UPPER(eit.eei_information19) = 'ABSENCE INFO';
--
--
--
  PROCEDURE create_absence_plan_details(
    p_person_id                 IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_legislation_code          IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_element_type_id           IN       NUMBER
   ,p_effective_start_date      IN       DATE
   ,p_effective_end_date        IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_per_in_ler_id             IN       NUMBER
   ,p_absence_attendance_id     IN       NUMBER
   ,p_absence_date_start        IN       DATE
   ,p_absence_date_end          IN       DATE
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  );

  PROCEDURE update_absence_plan_details(
    p_person_id                 IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_legislation_code          IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_element_type_id           IN       NUMBER
   ,p_effective_start_date      IN       DATE
   ,p_effective_end_date        IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_per_in_ler_id             IN       NUMBER
   ,p_absence_attendance_id     IN       NUMBER
   ,p_absence_date_start        IN       DATE
   ,p_absence_date_end          IN       DATE
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  );

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
   ,p_effective_end_date        IN       DATE
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_element_type_id           IN       NUMBER DEFAULT NULL
  );
END;

 

/
