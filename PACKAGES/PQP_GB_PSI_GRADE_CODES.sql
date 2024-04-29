--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_GRADE_CODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_GRADE_CODES" AUTHID CURRENT_USER AS
--  /* $Header: pqpgbpsigrd.pkh 120.0 2006/04/13 04:59:59 anshghos noship $ */



--
-- Debug Variables.
--
   g_legislation_code   per_business_groups.legislation_code%TYPE   := 'GB';
   g_debug              BOOLEAN                      := hr_utility.debug_enabled;
   g_effective_date     DATE;
   g_extract_type       VARCHAR2(100);

   g_proc_name           VARCHAR2(61):= 'PQP_GB_PSI_GRADE_CODES.';
   g_business_group_id   NUMBER := NULL;
   g_paypoint            VARCHAR2(5);

   g_grade_details       per_grades%rowtype;

----------------------------CURSORS ------------------

  --
  -- For grade details to be fetched from grade DDFF
  --
  CURSOR csr_grade_details
          (p_business_group_id   NUMBER
          ,p_grade_id            NUMBER
          ) IS
  select *
  from PER_GRADES
  where information_category = 'GB_PQP_PENSERV_GRADE_INFO'
	and business_group_id = p_business_group_id
	and grade_id = p_grade_id;



  --

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


---
---
---
  FUNCTION chk_grade_codes_crit
    (p_business_group_id       IN         NUMBER
    ,p_grade_id                IN         VARCHAR2
    )
  RETURN VARCHAR2;



  FUNCTION grade_extract_main
    (p_rule_parameter           IN         VARCHAR2 -- parameter
    ,p_output                   OUT NOCOPY VARCHAR2
    )
  RETURN number;

  FUNCTION grade_codes_post_processing RETURN VARCHAR2;


END PQP_GB_PSI_GRADE_CODES;

 

/
