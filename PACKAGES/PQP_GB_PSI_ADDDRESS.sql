--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_ADDDRESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_ADDDRESS" AUTHID CURRENT_USER AS
    --  /* $Header: pqpgbpsadd.pkh 120.2.12010000.1 2008/07/28 11:16:53 appldev ship $ */
    --
    -- Debug Variables.
    --
    g_debug                        BOOLEAN    := hr_utility.debug_enabled;
    g_package                      VARCHAR2(30) := 'PQP_GB_PSI_ADDDRESS'; -- package name
    c_application_id               CONSTANT NUMBER := 8303;-- application id
    c_configuration_type           CONSTANT VARCHAR2(30) := 'PQP_GB_PENSERVER_ADDRESS_MAP';
                                                          -- address mapping configuration name
    c_highest_date                 CONSTANT DATE := to_date('31/12/4712','DD/MM/YYYY');
                                                          -- highest date

    g_person_id                    per_all_people_f.person_id%type;
    g_assignment_id                NUMBER;
    g_business_group_id            per_addresses.business_group_id%TYPE;
    g_legislation_code             VARCHAR2(2);
    g_effective_date               DATE;
    g_current_run                  VARCHAR2(20);
    g_current_layout               VARCHAR2(20);

    g_pay_proc_evt_tab             ben_ext_person.t_detailed_output_table;

    g_office_address_type          per_addresses.address_type%TYPE;
    g_home_address_type            per_addresses.address_type%TYPE;
    g_office_address_id            per_addresses.address_id%TYPE;
    g_home_address_id              per_addresses.address_id%TYPE;

    g_country                      VARCHAR2(30);

    g_office_address_changed       VARCHAR2(1);-- this is used by the data elements functions
                                               --   to check if there is a change in office address
    g_home_address_changed         VARCHAR2(1);-- this is used by the data elements functions
                                               --   to check if there is a change in home address

    g_email_address                per_all_people_f.email_address%TYPE;
    g_curr_person_dtls             per_all_people_f%ROWTYPE;-- current perons details fetched from the
                                                            --  shared globals
    g_curr_assg_dtls               per_all_assignments_f%ROWTYPE;-- current assignment details fetched from the
                                                            --  shared globals
    g_paypoint                     VARCHAR2(30);-- paypoint value fetched from
    g_cutover_date                 DATE;
    g_ext_dfn_id                   NUMBER;

    g_include_home_address        VARCHAR2(1);-- this value will be set to 'N' when
                                              --     an DE error is raised
    g_include_office_address      VARCHAR2(1);-- this value will be set to 'N' when
                                              --     an DE error is raised
    g_report_non_pen_address      BOOLEAN :=  false; -- this will be set to true if the person details should be
                                           --  reported for a non-penserver address(added in version 115.4)

    g_office_address_reported     BOOLEAN :=  FALSE;
    --Cursor to fetch all the addresses for a person of the types specified
    --    in configuration value.
    -- Bug Fix - 5104319.
    CURSOR csr_get_addr_dtls
    IS
          SELECT pa.address_id
            ,pa.address_line1
            ,pa.address_line2
            ,pa.address_line3
            ,pa.town_or_city address_line4
            ,pa.address_type address_type
            ,hrl.MEANING address_meaning
            ,fcl.meaning  address_line5
            ,ftt.territory_short_name country
            ,pa.date_from
            ,pa.date_to
            ,pa.postal_code
            ,pa.telephone_number_1
            ,pa.telephone_number_2
            ,ppf.email_address
            ,ppf.mailstop
          FROM per_addresses pa
            ,per_all_people_f ppf
            ,fnd_territories_tl ftt
            ,fnd_common_lookups fcl
            ,HR_LOOKUPS hrl
          WHERE pa.person_id = ppf.person_id
          AND pa.person_id = g_person_id
          AND pa.business_group_id = g_business_group_id
          AND pa.country  = ftt.territory_code (+)
          AND 'GB_COUNTY' = fcl.lookup_type (+)
          AND pa.region_1 = fcl.lookup_code (+)
          AND 'ADDRESS_TYPE' = hrl.LOOKUP_TYPE (+)
          AND pa.address_type = hrl.LOOKUP_CODE (+)
          AND userenv('LANG')= ftt.language -- added as bugfix : 5525631
          AND g_effective_date BETWEEN ppf.effective_start_date
                      AND ppf.effective_end_date
          ORDER BY date_from,address_id DESC;

    TYPE t_person_addresses  IS TABLE OF csr_get_addr_dtls%ROWTYPE
      INDEX BY BINARY_INTEGER;
    -- global table to store the addresses for periodic changes extract
    g_person_addresses    t_person_addresses;
    -- global table to store the addresses for cutover extract
    g_person_cutover_addresses  t_person_addresses;



    CURSOR csr_get_email_mailstop
    IS
          SELECT email_address
            ,mailstop
          FROM per_all_people_f
          WHERE person_id = g_person_id
          AND g_effective_date BETWEEN effective_start_date
                      AND effective_end_date;


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

    -- ----------------------------------------------------------------------------
    -- |---------------------< address_cutover_ext_criteria >---------------------|
    --  Description: Cutover extract criteria.
    -- ----------------------------------------------------------------------------
    FUNCTION address_cutover_ext_criteria
                (
                p_business_group_id      NUMBER
                ,p_assignment_id         NUMBER
                ,p_effective_date        DATE
                )RETURN VARCHAR2;
    --------

    -- ----------------------------------------------------------------------------
    -- |--------------------< address_periodic_ext_criteria >---------------------|
    --  Description:  Address Periodic extract Criteria.
    -- ----------------------------------------------------------------------------
    FUNCTION address_periodic_ext_criteria
                (
                p_business_group_id      NUMBER
                ,p_assignment_id         NUMBER
                ,p_effective_date        DATE
                )RETURN VARCHAR2;
    ---------

    -- ----------------------------------------------------------------------------
    -- |----------------------< set_address_extract_globals >---------------------|
    --  Description: This procedure is to obtain set the extract level globals.
    -- ----------------------------------------------------------------------------
    PROCEDURE set_address_extract_globals
                (
                p_business_group_id     IN NUMBER
                ,p_assignment_id        IN NUMBER
                );
    ---------

    -- ----------------------------------------------------------------------------
    -- |----------------------< set_assignment_globals >--------------------------|
    --  Description:  This procedure is to set the assignment level globals.
    -- ----------------------------------------------------------------------------
    PROCEDURE set_assignment_globals
                (
                p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                );
    -- ----------------------------------------------------------------------------
    -- |---------------------< is_home_address_changed >------------------------|
    --  Description:  This process will return the value of the global variable
    --                  g_include_home_address, which indicates whether the home
    --                  address is to be picked or not. The value of this is checked
    --                  in the extra conditions on the home address record.
    --                  g_include_home_address is set to 'N' if there are any data
    --                  errors raised.
    -- ----------------------------------------------------------------------------
    FUNCTION is_home_address_changed RETURN VARCHAR2;
    --------

    -- ----------------------------------------------------------------------------
    -- |---------------------< is_office_address_changed >------------------------|
    --  Description:  This process will return the value of the global variable
    --                  g_include_office_address, which indicates whether the office
    --                  address is to be picked or not. The value of this is checked
    --                  in the extra conditions on the office address record.
    --                  g_include_office_address is set to 'N' if there are any data
    --                  errors raised.
    -- ----------------------------------------------------------------------------
    FUNCTION is_office_address_changed RETURN VARCHAR2;
    ----------

    -- ----------------------------------------------------------------------------
    -- |---------------------< address_data_element_value >-----------------------|
    --  Description:  This is a common function used by all the data elements to fetch
    --                  thier respective values. Depending the parameter p_ext_user_value
    --                  this procedure decides which value to be returned.
    -- ----------------------------------------------------------------------------
    FUNCTION address_data_element_value
             (
             p_ext_user_value     IN VARCHAR2
             ,p_output_value       OUT NOCOPY VARCHAR2
             )
    RETURN NUMBER;
    ----------

    -- ----------------------------------------------------------------------------
    -- |----------------------< address_post_processing >--------------------------|
    --  Description:  This is the post-processing rule  for the address layout.
    -- ----------------------------------------------------------------------------
    FUNCTION address_post_processing RETURN VARCHAR2;
    ------

    -- ----------------------------------------------------------------------------
    -- |----------------------< chk_pen_addresses_exist >--------------------------|
    --  Description:  This function is used to check if there are any perserver addresses
    --                  active on a particular date.
    -- ----------------------------------------------------------------------------
    FUNCTION chk_pen_addresses_exist
              (
              p_effective_date  DATE
              ) RETURN BOOLEAN;
    ---------
END PQP_GB_PSI_ADDDRESS;

/
