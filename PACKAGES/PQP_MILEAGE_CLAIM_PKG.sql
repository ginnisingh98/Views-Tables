--------------------------------------------------------
--  DDL for Package PQP_MILEAGE_CLAIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_MILEAGE_CLAIM_PKG" AUTHID CURRENT_USER AS
/* $Header: pqmlgclm.pkh 120.0 2005/05/29 01:53:08 appldev noship $ */

PROCEDURE pqp_insert_mileage_claim
        ( p_effective_date             IN DATE,
          p_web_adi_identifier         IN VARCHAR2  ,
          p_info_id                    IN VARCHAR2  ,
          p_time_stamp                 IN VARCHAR2  ,
          p_assignment_id              IN NUMBER,
          p_business_group_id          IN NUMBER,
          p_legislation_code           IN VARCHAR2,
          p_ownership                  IN VARCHAR2  ,
          p_usage_type                 IN VARCHAR2  ,
          p_vehicle_type               IN VARCHAR2,
          p_start_date                 IN DATE  ,
          p_end_date                   IN DATE  ,
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
          p_data_source                IN VARCHAR2  default 'I',
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_return_status              OUT NOCOPY VARCHAR2,
          p_purpose                    IN VARCHAR2  default null,
          p_user_type                  IN VARCHAR2  default 'PUI'
 );



PROCEDURE pqp_update_mileage_claim
        ( p_effective_date             IN DATE,
          p_assignment_id              IN number,
          p_business_group_id          IN NUMBER,
          p_legislation_code           IN VARCHAR2,
          p_ownership                  IN VARCHAR2  DEFAULT NULL,
          p_usage_type                 IN VARCHAR2  DEFAULT NULL,
          p_vehicle_type               IN VARCHAR2,
          p_start_date_o               IN DATE  DEFAULT NULL,
          p_start_date                 IN DATE  DEFAULT NULL,
          p_end_date_o                 IN DATE  DEFAULT NULL,
          p_end_date                   IN DATE  DEFAULT NULL,
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
          p_purpose                    IN VARCHAR2  default null,
          p_data_source                IN VARCHAR2  DEFAULT 'I',
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_return_status              OUT NOCOPY VARCHAR2
          );



PROCEDURE pqp_delete_mileage_claim
        ( p_effective_date             IN DATE,
          p_assignment_id              IN NUMBER,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_return_status              OUT NOCOPY VARCHAR2
         )  ;


---Called from JDEV


-- Function get_code returns the code of the meaning passed
--
-- The Code depends on the value of the p_option parameter
-- p_option = 'R' -> p_field has the rates table
--name and it Returns the Rates table id
--
FUNCTION get_code
        (p_option         IN VARCHAR2
        ,p_field          IN VARCHAR2
         )
RETURN VARCHAR2;

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
         )
      RETURN VARCHAR2;


---------

END;

 

/
