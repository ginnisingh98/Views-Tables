--------------------------------------------------------
--  DDL for Package PQP_GB_PENSION_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PENSION_FUNCTIONS" 
--  /* $Header: pqpgbpef.pkh 120.0.12010000.1 2008/07/28 11:16:44 appldev ship $ */
AUTHID CURRENT_USER AS
   --
   -- Debug Variables.
   --
   g_proc_name          VARCHAR2 (61)              := 'pqp_gb_pension_functions.';
   g_legislation_code   per_business_groups.legislation_code%TYPE   := 'GB';
   g_debug              BOOLEAN                      := hr_utility.debug_enabled;

   -- Cursor to retrieve element entries information
   -- for a given assignment
   -- retrieve only those elements classified as "Pre Tax Deductions" and
   -- "Voluntary Deductions"

   CURSOR csr_get_ele_entry_info (
      c_assignment_id     NUMBER
     ,c_element_type_id   NUMBER
     ,c_effective_date    DATE
   )
   IS
      SELECT DISTINCT (pee.element_link_id)
                 FROM pay_element_entries_f pee
                WHERE pee.assignment_id = c_assignment_id
                  AND c_effective_date BETWEEN pee.effective_start_date
                                           AND pee.effective_end_date
                  AND entry_type = 'E'
                  AND EXISTS (
                            SELECT 1
                              FROM pay_element_links_f pel
                                  ,pay_element_types_f pet
                                  ,pay_element_classifications pec
                             WHERE pel.element_link_id = pee.element_link_id
                               AND pel.element_type_id <> c_element_type_id
                               AND pet.element_type_id = pel.element_type_id
                               AND pet.classification_id =
                                                        pec.classification_id
                               -- Added to improve performance
                               AND pec.classification_name IN
                                      ('Pre Tax Deductions'
                                      ,'Voluntary Deductions'
                                      )
                               AND pec.legislation_code = g_legislation_code);

   TYPE t_number IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   -- Cursor to get the element type information
   -- from element links
   CURSOR csr_get_ele_type_id (c_element_link_id NUMBER, c_effective_date DATE)
   IS
      SELECT element_type_id
        FROM pay_element_links_f
       WHERE element_link_id = c_element_link_id
         AND c_effective_date BETWEEN effective_start_date
                                  AND effective_end_date;

   -- Cursor to get the element link information
   -- from element links for a given type id
   CURSOR csr_get_ele_link_id (
      c_element_type_id     NUMBER
     ,c_business_group_id   NUMBER
     ,c_effective_date      DATE
   )
   IS
      SELECT element_link_id
        FROM pay_element_links_f
       WHERE element_type_id = c_element_type_id
         AND business_group_id = c_business_group_id
         AND c_effective_date BETWEEN effective_start_date
                                  AND effective_end_date;

   -- Cursor to check whether the element type is
   -- a pension element for a given pension category
   CURSOR csr_chk_is_this_pens_ele (
      c_element_type_id    NUMBER
     ,c_effective_date     DATE
     ,c_pension_category   VARCHAR2
   )
   IS
      SELECT 'X'
        FROM pay_element_types_f pet
       WHERE pet.element_type_id = c_element_type_id
         AND c_effective_date BETWEEN pet.effective_start_date
                                  AND pet.effective_end_date
         AND EXISTS ( SELECT 1
                        FROM pay_element_type_extra_info
                       WHERE element_type_id = pet.element_type_id
                         AND information_type = 'PQP_GB_PENSION_SCHEME_INFO'
                         AND eei_information4 = c_pension_category
                         AND eei_information12 IS NULL);

   -- Cursor to retrieve pension type information
   CURSOR csr_get_pens_type_info (
      c_pension_type_id     NUMBER
     ,c_business_group_id   NUMBER
     ,c_effective_date      DATE
   )
   IS
      SELECT pension_type_id, pension_type_name, pension_category
            ,NVL (minimum_age, 0) minimum_age, NVL (maximum_age, 0) maximum_age
            ,effective_start_date, effective_end_date
        FROM pqp_pension_types_f
       WHERE pension_type_id = c_pension_type_id
         AND (   (    business_group_id IS NOT NULL
                  AND business_group_id = c_business_group_id
                 )
              OR (    legislation_code IS NOT NULL
                  AND legislation_code = g_legislation_code
                 )
              OR (business_group_id IS NULL AND legislation_code IS NULL)
             )
         AND c_effective_date BETWEEN effective_start_date
                                  AND effective_end_date;

   TYPE r_pension_types IS RECORD (
      pension_type_id               pqp_pension_types_f.pension_type_id%TYPE
     ,pension_type_name             pqp_pension_types_f.pension_type_name%TYPE
     ,pension_category              pqp_pension_types_f.pension_category%TYPE
     ,minimum_age                   pqp_pension_types_f.minimum_age%TYPE
     ,maximum_age                   pqp_pension_types_f.maximum_age%TYPE
     ,effective_start_date          pqp_pension_types_f.effective_start_date%TYPE
     ,effective_end_date            pqp_pension_types_f.effective_end_date%TYPE);

   TYPE t_pension_types IS TABLE OF r_pension_types
      INDEX BY BINARY_INTEGER;

   TYPE r_element_types IS RECORD (
      element_type_id               NUMBER
     ,assignment_id                 NUMBER
     ,effective_start_date          DATE
     ,effective_end_date            DATE
     ,yes_no_opt                    VARCHAR2 (1));

   TYPE t_element_types IS TABLE OF r_element_types
      INDEX BY BINARY_INTEGER;

   -- Changed cursor for BUG 3637584
   -- Cursor to check existence of an element entry
   -- for an assignment
   CURSOR csr_chk_ele_entry_exists (
      c_assignment_id     NUMBER
--     ,c_element_link_id   NUMBER
     ,c_element_type_id   NUMBER
     ,c_business_group_id NUMBER
     ,c_effective_date    DATE
   )
   IS
      SELECT pee.element_entry_id, pee.effective_start_date, pee.effective_end_date
        FROM pay_element_entries_f pee
            ,pay_element_links_f   pel
       WHERE pee.assignment_id     = c_assignment_id
         AND pee.element_link_id   = pel.element_link_id
         AND pee.entry_type        = 'E'
         AND c_effective_date BETWEEN pee.effective_start_date
                                  AND pee.effective_end_date
         AND pel.element_type_id   = c_element_type_id
         AND pel.business_group_id = c_business_group_id
         AND c_effective_date BETWEEN pel.effective_start_date
                                  AND pel.effective_end_date;

   -- Cursor to get element name
   CURSOR csr_get_ele_name (c_element_type_id NUMBER, c_effective_date DATE)
   IS
      SELECT element_name
        FROM pay_element_types_f
       WHERE element_type_id = c_element_type_id
         AND c_effective_date BETWEEN effective_start_date
                                  AND effective_end_date;

   -- Cursor to get the second base element for
   -- the same pension scheme name
   CURSOR csr_get_sch_oth_ele_id (
      c_element_type_id     NUMBER
     ,c_business_group_id   NUMBER
   )
   IS
      SELECT pps.element_type_id
        FROM pqp_gb_pension_schemes_v pps, pay_element_type_extra_info eeit
       WHERE pps.element_type_id <> c_element_type_id
         AND pps.pension_scheme_name = eeit.eei_information1
         AND eeit.element_type_id = c_element_type_id
         AND eeit.information_type = 'PQP_GB_PENSION_SCHEME_INFO'
         AND pps.business_group_id = c_business_group_id;

   -- Procedures

   -- Debug
   PROCEDURE DEBUG (
      p_trace_message    IN   VARCHAR2
     ,p_trace_location   IN   NUMBER DEFAULT NULL
   );

   -- Debug_Enter
   PROCEDURE debug_enter (
      p_proc_name   IN   VARCHAR2
     ,p_trace_on    IN   VARCHAR2 DEFAULT NULL
   );

   -- Debug_Exit
   PROCEDURE debug_exit (
      p_proc_name   IN   VARCHAR2
     ,p_trace_off   IN   VARCHAR2 DEFAULT NULL
   );

   -- Debug Others
   PROCEDURE debug_others (
      p_proc_name   IN   VARCHAR2
     ,p_proc_step   IN   NUMBER DEFAULT NULL
   );

   -- Public Functions

   -- Function to check multiple pension membership for the same
   -- pension category

   FUNCTION chk_multiple_membership (
      p_assignment_id      IN              NUMBER -- Context
     ,p_element_type_id    IN              NUMBER -- Context
     ,p_effective_date     IN              DATE -- Context
     ,p_pension_category   IN              VARCHAR2
     ,p_yes_no             OUT NOCOPY      VARCHAR2
     ,p_error_msg          OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER;

   --
   -- Function to get the pension type information
   FUNCTION get_ele_pens_type_info (
      p_business_group_id   IN              NUMBER -- Context
     ,p_effective_date      IN              DATE -- Context
     ,p_element_type_id     IN              NUMBER -- Context
     ,p_minimum_age         OUT NOCOPY      NUMBER
     ,p_maximum_age         OUT NOCOPY      NUMBER
     ,p_error_msg           OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER;

   --
   -- Function to check whether an element entry exists for
   -- a given assignment and element type
   FUNCTION chk_element_entry_exists (
      p_assignment_id       IN              NUMBER -- Context
     ,p_business_group_id   IN              NUMBER -- Context
     ,p_effective_date      IN              DATE -- Context
     ,p_element_type_id     IN              NUMBER
     ,p_yes_no              OUT NOCOPY      VARCHAR2
     ,p_error_msg           OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER;
--

END pqp_gb_pension_functions;

/
