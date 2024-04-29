--------------------------------------------------------
--  DDL for Package PQP_ALIEN_EXPAT_TAXATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ALIEN_EXPAT_TAXATION_PKG" AUTHID DEFINER AS
/* $Header: pqalnexp.pkh 120.0.12010000.1 2008/07/28 11:07:48 appldev ship $ */
TYPE t_people_rec_type IS RECORD
(
    person_id             per_people_f.person_id%TYPE            ,
    last_name             per_people_f.last_name%TYPE            ,
    first_name            per_people_f.first_name%TYPE           ,
    middle_names          per_people_f.middle_names%TYPE         ,
    national_identifier   per_people_f.national_identifier%TYPE  ,
    employee_number       per_people_f.employee_number%TYPE      ,
    date_of_birth         per_people_f.date_of_birth%TYPE        ,
    title                 per_people_f.title%TYPE                ,
    suffix                per_people_f.suffix%TYPE               ,
    marital_status        per_people_f.marital_status%TYPE       ,
    spouse_here           VARCHAR2(30)                           ,
    dependents            NUMBER                                 ,
    address_line1         hr_locations.address_line_1%TYPE       ,
    address_line2         hr_locations.address_line_2%TYPE       ,
    address_line3         hr_locations.address_line_3%TYPE       ,
    city                  hr_locations.loc_information17%TYPE    ,
    state                 hr_locations.loc_information18%TYPE    ,
    telephone_number_1    hr_locations.telephone_number_1%TYPE   ,
    telephone_number_2    hr_locations.telephone_number_2%TYPE   ,
    telephone_number_3    hr_locations.telephone_number_3%TYPE   ,
    postal_code           hr_locations.postal_code%TYPE          ,
    non_us_address_line1  per_addresses.address_line1%TYPE       ,
    non_us_address_line2  per_addresses.address_line2%TYPE       ,
    non_us_address_line3  per_addresses.address_line3%TYPE       ,
    non_us_city_postal_cd per_addresses.postal_code%TYPE         ,
    non_us_city           per_addresses.town_or_city%TYPE        ,
    non_us_region         per_addresses.region_1%TYPE            ,
    non_us_region_postal_cd per_addresses.region_2%TYPE            ,
    non_us_country_code   VARCHAR2(100)                          ,
    non_us_country_name   VARCHAR2(100)                          ,
    citizenship_c_code    VARCHAR2(100)                          ,
    citizenship_c_name    VARCHAR2(100)                          ,
    passport_number       VARCHAR2(100)                          ,
    date_first_entered_us DATE                                   ,
    date_employment_us    DATE                                   ,
    validation_flag       VARCHAR2(2)                            ,
    error_mesg            VARCHAR2(240)
);

/*****
The above Record Type t_people_rec_type stores the personal info data
*****/

TYPE t_balance_rec_type IS RECORD
(
    person_id                      per_people_f.person_id%TYPE                ,
    last_name                      per_people_f.last_name%TYPE                ,
    first_name                     per_people_f.first_name%TYPE               ,
    middle_names                   per_people_f.middle_names%TYPE             ,
    national_identifier            per_people_f.national_identifier%TYPE      ,
    date_of_birth                  per_people_f.date_of_birth%TYPE            ,
    income_code                    pqp_analyzed_alien_details.income_code%TYPE,
    exemption_code              pqp_analyzed_alien_details.exemption_code%TYPE,
    gross_amount                   NUMBER                                     ,
    withholding_allowance
                      pqp_analyzed_alien_data.withldg_allow_eligible_flag%TYPE,
    withholding_rate          pqp_analyzed_alien_details.withholding_rate%TYPE,
    withheld_amount                NUMBER                                     ,
    income_code_sub_type  pqp_analyzed_alien_details.income_code_sub_type%TYPE,
    country_code                   VARCHAR2(100)                              ,
    cycle_date                     VARCHAR2(100)                              ,
    tax_year                       pqp_analyzed_alien_data.tax_year%TYPE      ,
    state_withheld_amount          NUMBER                                     ,
    state_code                     VARCHAR2(100)                              ,
    record_source                  VARCHAR2(100)                              ,
    no_of_days_in_cycle            NUMBER                                     ,
    payment_type                   VARCHAR2(100)                              ,
    last_date_of_earnings          DATE                                       ,
    constant_addl_tax        pqp_analyzed_alien_details.constant_addl_tax%TYPE,
    record_status                  VARCHAR2(100)                              ,
    prev_er_treaty_benefit_amount  NUMBER
);

/*****
 The above Record Type t_balance_rec_type stores the data the balance
 information
*****/

TYPE t_visa_rec_type IS RECORD
(
    person_id                   per_people_f.person_id%TYPE             ,
    last_name                   per_people_f.last_name%TYPE             ,
    first_name                  per_people_f.first_name%TYPE            ,
    middle_names                per_people_f.middle_names%TYPE          ,
    national_identifier         per_people_f.national_identifier%TYPE   ,
    date_of_birth               per_people_f.date_of_birth%TYPE         ,
    visa_type                   VARCHAR2(100)                           ,
    j_category_code             VARCHAR2(100)                           ,
    primary_activity_code       VARCHAR2(100)                           ,
    visa_start_date             DATE                                    ,
    visa_end_date               DATE                                    ,
    visa_number                 VARCHAR2(100)                           ,
    tax_residence_country_code  VARCHAR2(100)
);

/*****
 The above Record Type stores the data selected of the visa information
*****/
TYPE t_payment_export_type IS RECORD
(  id                            per_people_f.person_id%TYPE             ,
   last_name                     per_people_f.last_name%TYPE             ,
   first_name                    per_people_f.first_name%TYPE            ,
   middle_names                  per_people_f.middle_names%TYPE          ,
   system_id_number              NUMBER        ,
   social_security_number        VARCHAR2(11)  ,
   institution_indiv_id          VARCHAR2(15)  ,
   date_of_birth                 DATE          ,
   taxyear                       NUMBER        ,
   income_code                   VARCHAR2(2)   ,
   withholding_rate              VARCHAR2(3)   ,
   scholarship_type              VARCHAR2(1)   ,
   exemption_code                VARCHAR2(1)   ,
   maximum_benefit               NUMBER        ,
   retro_lose_on_amount          NUMBER        ,
   date_benefit_ends             DATE          ,
   retro_lose_on_date            NUMBER        ,
   residency_status              VARCHAR2(1)   ,
   date_becomes_ra               DATE          ,
   target_departure_date         DATE          ,
   date_record_created           DATE          ,
   tax_residence_country_code    VARCHAR2(2)   ,
   date_treaty_updated           DATE          ,
   exempt_fica                   NUMBER        ,
   exempt_student_fica           NUMBER        ,
   add_wh_for_nra_whennotreaty   NUMBER        ,
   amount_of_addl_withholding    NUMBER        ,
   personal_exemption            VARCHAR2(1)   ,
   additional_exemptions_allowed NUMBER        ,
   days_in_usa                   NUMBER        ,
   eligible_for_whallowance      NUMBER        ,
   treatybenefits_allowed        NUMBER        ,
   treatybenefit_startdate       DATE          ,
   ra_effective_date             DATE          ,
   state_code                    VARCHAR2(2)   ,
   state_honours_treaty          NUMBER        ,
   ytd_payments                  NUMBER        ,
   ytd_w2payments                NUMBER        ,
   ytd_withholding               NUMBER        ,
   ytd_whallowance               NUMBER        ,
   ytd_treaty_payments           NUMBER        ,
   ytd_treaty_withheld_amts      NUMBER        ,
   record_source                 VARCHAR2(3)   ,
   visa_type                     VARCHAR2(4)   ,
   jsub_type                     VARCHAR2(2)   ,
   primary_activity              VARCHAR2(2)   ,
   nus_countrycode               VARCHAR2(2)   ,
   citizenship                   VARCHAR2(2)   ,
   constant_additional_tax       NUMBER        ,
   out_of_system_treaty          NUMBER        ,
   amount_of_addl_wh_type        VARCHAR2(1)   ,
   error_indicator               VARCHAR2(30)  ,
   error_text                    VARCHAR2(4000),
   date_w4_signed                DATE          ,
   date_8233_signed              DATE
);

SUBTYPE out_mesg_type IS VARCHAR2(240);
/*****
 The above Record Type stores the message for error processing
*****/
    TYPE t_error_rec_type IS RECORD
    (
        person_id             per_people_f.person_id%TYPE              ,
        process_event_id      pay_process_events.process_event_id%TYPE
    );

TYPE t_error_tab_type IS TABLE OF t_error_rec_type INDEX BY BINARY_INTEGER;

TYPE t_people_tab_type IS TABLE OF t_people_rec_type INDEX BY BINARY_INTEGER;
/*****
 This is the definition of the table of the t_people_rec_type record type
*****/

TYPE t_balance_tab_type IS TABLE OF t_balance_rec_type INDEX BY BINARY_INTEGER;
/*****
 This is the definition of the table of the t_per_balance_rec_type record type
*****/
TYPE t_visa_tab_type IS TABLE OF t_visa_rec_type INDEX BY BINARY_INTEGER   ;

/*****
  This is the definition of the table of the t_per_visa_rec_type record type
*****/
PROCEDURE pqp_read_public
(
    p_selection_criterion        IN    VARCHAR2 DEFAULT NULL         ,
    p_effective_date             IN    DATE                          ,
    p_batch_size                OUT NOCOPY    NUMBER                        ,
    t_people_tab                OUT NOCOPY    t_people_tab_type             ,
    t_balance_tab               OUT NOCOPY    t_balance_tab_type            ,
    t_visa_tab                  OUT NOCOPY    t_visa_tab_type               ,
    p_person_read_count         OUT NOCOPY    NUMBER                        ,
    p_person_err_count          OUT NOCOPY    NUMBER
);
/*****
 The above procedure pqp_windstar_read  is a public procedure and is called
 from the wrapper script.
*****/
PROCEDURE  update_pay_process_events
(
    p_person_id       IN  NUMBER   ,
    p_effective_date  IN  DATE     ,
    p_source_type     IN  VARCHAR2 ,
    p_status          IN  VARCHAR2 ,
    p_desc            IN  VARCHAR2
);

PROCEDURE pqp_write_public
(
    p_id                            IN NUMBER        ,
    p_last_name                     IN VARCHAR2      ,
    p_first_name                    IN VARCHAR2      ,
    p_middle_names                  IN VARCHAR2      ,
    p_system_id_number              IN NUMBER        ,
    p_social_security_number        IN VARCHAR2      ,
    p_institution_indiv_id          IN VARCHAR2      ,
    p_date_of_birth                 IN DATE          ,
    p_taxyear                       IN NUMBER        ,
    p_income_code                   IN VARCHAR2      ,
    p_withholding_rate              IN VARCHAR2      ,
    p_scholarship_type              IN VARCHAR2      ,
    p_exemption_code                IN VARCHAR2      ,
    p_maximum_benefit               IN NUMBER        ,
    p_retro_lose_on_amount          IN NUMBER        ,
    p_date_benefit_ends             IN DATE          ,
    p_retro_lose_on_date            IN NUMBER        ,
    p_residency_status              IN VARCHAR2      ,
    p_date_becomes_ra               IN DATE          ,
    p_target_departure_date         IN DATE          ,
    p_date_record_created           IN DATE          ,
    p_tax_residence_country_code    IN VARCHAR2      ,
    p_date_treaty_updated           IN DATE          ,
    p_exempt_fica                   IN NUMBER        ,
    p_exempt_student_fica           IN NUMBER        ,
    p_add_wh_for_nra_whennotreaty   IN NUMBER        ,
    p_amount_of_addl_withholding    IN NUMBER        ,
    p_personal_exemption            IN VARCHAR2      ,
    p_add_exemptions_allowed        IN NUMBER        ,
    p_days_in_usa                   IN NUMBER        ,
    p_eligible_for_whallowance      IN NUMBER        ,
    p_treatybenefits_allowed        IN NUMBER        ,
    p_treatybenefit_startdate       IN DATE          ,
    p_ra_effective_date             IN DATE          ,
    p_state_code                    IN VARCHAR2      ,
    p_state_honours_treaty          IN NUMBER        ,
    p_ytd_payments                  IN NUMBER        ,
    p_ytd_w2payments                IN NUMBER        ,
    p_ytd_withholding               IN NUMBER        ,
    p_ytd_whallowance               IN NUMBER        ,
    p_ytd_treaty_payments           IN NUMBER        ,
    p_ytd_treaty_withheld_amts      IN NUMBER        ,
    p_record_source                 IN VARCHAR2      ,
    p_visa_type                     IN VARCHAR2      ,
    p_jsub_type                     IN VARCHAR2      ,
    p_primary_activity              IN VARCHAR2      ,
    p_nus_countrycode               IN VARCHAR2      ,
    p_citizenship                   IN VARCHAR2      ,
    p_constant_additional_tax       IN NUMBER        ,
    p_out_of_system_treaty          IN NUMBER        ,
    p_amount_of_addl_wh_type        IN VARCHAR2      ,
    p_error_indicator               IN VARCHAR2      ,
    p_error_text                    IN VARCHAR2      ,
    p_date_w4_signed                IN DATE          ,
    p_date_8233_signed              IN DATE          ,
    p_reconcile                     IN BOOLEAN       ,
    p_effective_date                IN DATE          ,
    p_current_analysis              IN NUMBER        ,
    p_forecast_income_code          IN VARCHAR2      ,
    p_error_message                OUT NOCOPY VARCHAR2
);

PROCEDURE pqp_batch_size(p_batch_size OUT NOCOPY NUMBER);

/*****
 The above procedure pqp_windstar_write is a public procedure and is called
 from the wrapper script. The p_payment_export_id is NOT a Mandatory parameter.
 If a null value is passed, then all the records with a rec_read_by_external_sys = 0 in payment_export table are selected. Otherwise, if the p_payment_export_id
 is specified, then only the record with payment_export.id = one that is
 specified is selected.
*****/
PROCEDURE ResetForReadAPI(p_process_event_id IN NUMBER);
PROCEDURE AbortReadAPI(p_process_event_id IN NUMBER);
END pqp_alien_expat_taxation_pkg;

/
