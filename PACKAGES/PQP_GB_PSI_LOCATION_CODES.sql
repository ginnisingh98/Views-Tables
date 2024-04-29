--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_LOCATION_CODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_LOCATION_CODES" AUTHID CURRENT_USER AS
--  /* $Header: pqpgbpsiloc.pkh 120.0 2006/04/13 05:02:31 anshghos noship $ */



--
-- Debug Variables.
--
   g_legislation_code   per_business_groups.legislation_code%TYPE   := 'GB';
   g_debug              BOOLEAN                      := hr_utility.debug_enabled;
   g_effective_date     DATE;
   g_extract_type       VARCHAR2(100);

   g_proc_name           VARCHAR2(61):= 'PQP_GB_PSI_LOCATION_CODES.';
   g_loc_code            VARCHAR2(150);
   g_business_group_id   NUMBER := NULL;
   g_paypoint            VARCHAR2(5);

----------------------------CURSORS ------------------

  --
  -- For location code to be fetched from location EIT
  --
  CURSOR csr_location_code
          (p_loc_id        NUMBER
          ) IS
  select lei_information2
  from hr_location_extra_info
  where information_type = 'PQP_GB_PENSERV_LOCATION_INFO'
    and location_id = p_loc_id;


  --
  -- For location code to be fetched from location EIT
  --
  CURSOR csr_location_name
          (p_loc_id        NUMBER
          ) IS
  select location_code
  from hr_locations_all
  where location_id = p_loc_id;



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
  FUNCTION chk_location_codes_crit
    (p_business_group_id       IN         NUMBER
    ,p_loc_id                  IN         VARCHAR2
    )
  RETURN VARCHAR2;



  FUNCTION location_extract_main
    (p_rule_parameter           IN         VARCHAR2 -- parameter
    ,p_output                   OUT NOCOPY VARCHAR2
    )
  RETURN number;


  FUNCTION location_codes_post_processing RETURN VARCHAR2;


END PQP_GB_PSI_LOCATION_CODES;

 

/
