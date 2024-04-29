--------------------------------------------------------
--  DDL for Package PQP_GB_MILEAGE_CLAIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_MILEAGE_CLAIM_PKG" AUTHID CURRENT_USER AS
/* $Header: pqgbmgcm.pkh 120.0.12010000.2 2009/10/14 11:26:24 nchinnam ship $ */


TYPE r_purpose_det is Record ( category               VARCHAR2(60)
                              ,value                  VARCHAr2(80)
                               );
TYPE t_purpose_det is Table of r_purpose_det
                   INDEX BY binary_integer;



PROCEDURE get_purpose_details (p_business_group_id  IN NUMBER
                              ,p_assignment_id      IN NUMBER
                              ,p_effective_date     IN DATE
                              ,p_purpose            IN VARCHAR2
                              ,p_ownership          IN VARCHAR2
                              ,p_vehicle_type       IN VARCHAR2
                              ,p_rate_type          IN VARCHAR2
                              ,p_element_id         OUT NOCOPY NUMBER
                              ,p_element_name       OUT NOCOPY VARCHAR2
                              ,p_rate_table_id      OUT NOCOPY VARCHAR2
                              ,p_rate_table         OUT NOCOPY VARCHAR2
                              ,p_taxable            OUT NOCOPY VARCHAR2
                             );


PROCEDURE insert_mileage_claim
        ( p_effective_date             IN DATE,
          p_web_adi_identifier         IN VARCHAR2  ,
          p_info_id                    IN VARCHAR2  ,
          p_time_stamp                 IN VARCHAR2  ,
          p_assignment_id              IN NUMBER,
          p_business_group_id          IN NUMBER,
          p_ownership                  IN VARCHAR2  ,
          p_usage_type                 IN VARCHAR2  ,
          p_vehicle_type               IN VARCHAR2,
          p_start_date                 IN VARCHAR2  ,
          p_end_date                   IN VARCHAR2  ,
          p_claimed_mileage            IN VARCHAR2  ,
          p_actual_mileage             IN VARCHAR2  default null,
          p_registration_number        IN VARCHAR2  default null,
          p_engine_capacity            IN VARCHAR2  default null,
          p_fuel_type                  IN VARCHAR2  default null,
          p_calculation_method         IN VARCHAR2  default null,
          p_user_rates_table           IN VARCHAR2  default null,
          p_fiscal_ratings             IN VARCHAR2  default null,
          p_PAYE_taxable               IN VARCHAR2  default null,
          p_no_of_passengers           IN VARCHAR2  default null,
          p_purpose                    IN VARCHAR2  default null,
          p_data_source                IN VARCHAR2  default 'I',
          p_user_type                  IN VARCHAR2  default 'PUI',
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE
         );


PROCEDURE update_mileage_claim
         ( p_effective_date            IN DATE,
         p_assignment_id               IN number,
          p_business_group_id          IN NUMBER,
          p_ownership                  IN VARCHAR2  DEFAULT NULL,
          p_usage_type                 IN VARCHAR2  DEFAULT NULL,
          p_vehicle_type               IN VARCHAR2  DEFAULT NULL,
          p_start_date_o               IN VARCHAR2  DEFAULT NULL,
          p_start_date                 IN VARCHAR2  DEFAULT NULL,
          p_end_date_o                 IN VARCHAR2  DEFAULT NULL,
          p_end_date                   IN VARCHAR2  DEFAULT NULL,
          p_claimed_mileage_o          IN VARCHAR2  DEFAULT NULL,
          p_claimed_mileage            IN VARCHAR2  DEFAULT NULL,
          p_actual_mileage_o           IN VARCHAR2  DEFAULT NULL,
          p_actual_mileage             IN VARCHAR2  DEFAULT NULL,
          p_registration_number        IN VARCHAR2  DEFAULT NULL,
          p_engine_capacity            IN VARCHAR2  DEFAULT NULL,
          p_fuel_type                  IN VARCHAR2  DEFAULT NULL,
          p_calculation_method         IN VARCHAR2  DEFAULT NULL,
          p_user_rates_table           IN VARCHAR2  DEFAULT NULL,
          p_fiscal_ratings_o           IN VARCHAR2  DEFAULT NULL,
          p_fiscal_ratings             IN VARCHAR2  DEFAULT NULL,
          p_PAYE_taxable               IN VARCHAR2  DEFAULT NULL,
          p_no_of_passengers_o         IN VARCHAR2  DEFAULT NULL,
          p_no_of_passengers           IN VARCHAR2  DEFAULT NULL,
          p_purpose                    IN VARCHAR2  DEFAULT NULL ,
          p_data_source                IN VARCHAR2  DEFAULT 'I',
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE
         );

PROCEDURE delete_mileage_claim
        ( p_effective_date             IN DATE,
          p_assignment_id              IN NUMBER,
          p_mileage_claim_element      IN NUMBER  ,
          p_element_entry_id           IN NUMBER  ,
          p_element_entry_date         IN DATE
         );

--get element or rates from configuration
PROCEDURE get_config_info ( p_business_group_id   IN NUMBER
                           ,p_ownership           IN VARCHAR2
                           ,p_usage_type          IN VARCHAR2
                           ,p_vehicle_type        IN VARCHAR2
                           ,p_fuel_type           IN VARCHAR2
                           ,p_sl_rates_type       IN  VARCHAR2
                           ,p_rates               OUT NOCOPY NUMBER
                           ,p_element_id          IN OUT NOCOPY NUMBER
                          );

--Check for Mandatory columns
FUNCTION chk_mndtry_fields (  p_effective_date        IN DATE
                           ,p_assignment_id         IN NUMBER
                           ,p_business_group_id     IN NUMBER
                           ,p_ownership             IN VARCHAR2
                           ,p_usage_type            IN VARCHAR2
                           ,p_vehicle_type          IN VARCHAR2
                           ,p_start_date            IN VARCHAR2
                           ,p_end_date              IN VARCHAR2
                           ,p_claimed_mileage       IN VARCHAR2
                           ,p_actual_mileage        IN VARCHAR2
                           ,p_registration_number   IN VARCHAR2
                           ,p_engine_capacity       IN VARCHAR2
                           ,p_fuel_type             IN VARCHAR2
                           ,p_element_type_id       IN NUMBER
                           ,p_data_source           IN VARCHAR2
                           ,p_message               OUT NOCOPY VARCHAR2
                          )

RETURN VARCHAR2;


--Check for eligibility

FUNCTION chk_eligibility (  p_effective_date        IN DATE
                           ,p_assignment_id         IN NUMBER
                           ,p_business_group_id     IN NUMBER
                           ,p_ownership             IN VARCHAR2
                           ,p_usage_type            IN VARCHAR2
                           ,p_vehicle_type          IN VARCHAR2
                           ,p_start_date            IN VARCHAR2
                           ,p_end_date              IN VARCHAR2
                           ,p_claimed_mileage       IN VARCHAR2
                           ,p_actual_mileage        IN VARCHAR2  default null
                           ,p_registration_number   IN VARCHAR2  default null
                           ,p_data_source           IN VARCHAR2  default 'I'
                           ,p_message               OUT NOCOPY VARCHAR2
                          )
RETURN VARCHAR2;

---Called from JDEV
 --This is used to delete the cliam import recodes for infoID
 --Procedure returns 'S' means sucessfully deleted
 PROCEDURE delete_claim_import
                 ( p_info_id        IN  VARCHAR2
                  ,p_assignment_id     IN  NUMBER
		  ,p_business_group_id IN  NUMBER
		  ,p_effective_date    IN  DATE
                  ,p_return_status     OUT NOCOPY VARCHAR2
                 ) ;
-- Function get_code returns the code of the meaning passed
--
-- The Code depends on the value of the p_option parameter
-- p_option = 'R' -> p_field has the rates table name and
--it Returns the Rates table id
--
FUNCTION get_code
(p_option         IN VARCHAR2
,p_field          IN VARCHAR2
) RETURN VARCHAR2;

--
-- Function get_meaning returns the meaning string of the id passed
--
-- The Meaning depends on the value of the p_option parameter
-- p_option = 'R' -> p_field_id has the rates table id and it Returns the Rates table Name
-- p_option = 'E' -> p_field_id has the element type id and it Returns the Element Name
--
FUNCTION get_meaning
(p_option         IN VARCHAR2
,p_field_id       IN NUMBER
) RETURN VARCHAR2;


---------
---Get lookup meaning
FUNCTION get_lkp_meaning (p_lookup_code IN VARCHAR2,
                          p_lookup_type IN VARCHAR2
                          )
RETURN VARCHAR2;

--chk if vehicle is active during the claim period

FUNCTION chk_vehicle_active ( p_ownership           IN VARCHAR2
                             ,p_usage_type          IN VARCHAR2
                             ,p_assignment_id       IN NUMBER
                             ,p_business_group_id   IN NUMBER
                             ,p_start_date          IN VARCHAR2
                             ,p_end_date            IN VARCHAR2
                             ,p_registration_number IN VARCHAR2
                             ,p_message             OUT NOCOPY VARCHAR2
                            )
RETURN NUMBER;

--Function used in query
FUNCTION get_meaning ( p_inp_type VARCHAR2
                      ,p_code     VARCHAR2
                      )
RETURN VARCHAR2;

--Temporary function
FUNCTION get_total ( p_element_name          IN VARCHAR2
                    ,p_assignment_action_id  IN NUMBER
                    ,p_element_entry_id      IN NUMBER
                    ,p_business_group_id     IN NUMBER
                    )
RETURN NUMBER;

--Function to get balance for a view
FUNCTION get_amount ( p_element_name      IN VARCHAR2
                     ,p_element_type_id   IN NUMBER
                     ,p_effective_date    IN DATE
                     ,p_assignment_id     IN NUMBER
                     )
RETURN NUMBER;

---Usage type proc

PROCEDURE insert_company_mileage_claim
        ( p_effective_date             IN DATE,
          p_assignment_id              IN NUMBER,
          p_business_group_id          IN NUMBER,
          p_ownership                  IN VARCHAR2  ,
          p_usage_type                 IN VARCHAR2  ,
          p_vehicle_type               IN VARCHAR2,
          p_start_date                 IN VARCHAR2  ,
          p_end_date                   IN VARCHAR2  ,
          p_claimed_mileage            IN VARCHAR2  ,
          p_actual_mileage             IN VARCHAR2  default null,
          p_registration_number        IN VARCHAR2  default null,
          p_engine_capacity            IN VARCHAR2  default null,
          p_fuel_type                  IN VARCHAR2  default null,
          p_calculation_method         IN VARCHAR2  default null,
          p_user_rates_table           IN VARCHAR2  default null,
          p_fiscal_ratings             IN VARCHAR2  default null,
          p_PAYE_taxable               IN VARCHAR2  default null,
          p_no_of_passengers           IN VARCHAR2  default null,
          p_purpose                    IN VARCHAR2  default null,
          p_payroll_id                 IN NUMBER,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_element_link_id            IN NUMBER
         );

PROCEDURE insert_private_mileage_claim
        ( p_effective_date             IN DATE,
          p_assignment_id              IN NUMBER,
          p_business_group_id          IN NUMBER,
          p_ownership                  IN VARCHAR2  ,
          p_usage_type                 IN VARCHAR2  ,
          p_vehicle_type               IN VARCHAR2,
          p_start_date                 IN VARCHAR2  ,
          p_end_date                   IN VARCHAR2  ,
          p_claimed_mileage            IN VARCHAR2  ,
          p_actual_mileage             IN VARCHAR2  default null,
          p_registration_number        IN VARCHAR2  default null,
          p_engine_capacity            IN VARCHAR2  default null,
          p_fuel_type                  IN VARCHAR2  default null,
          p_calculation_method         IN VARCHAR2  default null,
          p_user_rates_table           IN VARCHAR2  default null,
          p_fiscal_ratings             IN VARCHAR2  default null,
          p_PAYE_taxable               IN VARCHAR2  default null,
          p_no_of_passengers           IN VARCHAR2  default null,
          p_purpose                    IN VARCHAR2  default null,
          p_payroll_id                 IN NUMBER,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_element_link_id            IN NUMBER
         );


END;

/
