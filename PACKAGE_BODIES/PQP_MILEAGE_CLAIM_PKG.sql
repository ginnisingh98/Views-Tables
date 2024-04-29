--------------------------------------------------------
--  DDL for Package Body PQP_MILEAGE_CLAIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_MILEAGE_CLAIM_PKG" AS
/* $Header: pqmlgclm.pkb 120.0 2005/05/29 01:53:03 appldev noship $ */

g_package  varchar2(33):='pqp_insert_mileage_claim.';

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
          p_actual_mileage             IN VARCHAR2 ,
          p_registration_number        IN VARCHAR2  ,
          p_engine_capacity            IN VARCHAR2  ,
          p_fuel_type                  IN VARCHAR2  ,
          p_calculation_method         IN VARCHAR2  ,
          p_user_rates_table           IN VARCHAR2  ,
          p_fiscal_ratings             IN VARCHAR2  ,
          p_PAYE_taxable               IN VARCHAR2  ,
          p_no_of_passengers           IN VARCHAR2  ,
          p_data_source                IN VARCHAR2  ,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_return_status              OUT NOCOPY varchar2,
          p_purpose                    IN VARCHAR2  ,
          p_user_type                  IN VARCHAR2
 )
IS

l_proc            varchar2(72) := g_package ||'insert_mileage_claim';
l_return_status   VARCHAR2(10);
l_start_date      VARCHAR2(20);
l_end_date        VARCHAR2(20);
l_disp_st_date    DATE;
l_disp_ed_date    DATE;

BEGIN
l_start_date := FND_DATE.DATE_TO_CHARDATE(p_start_date);
l_end_date   := FND_DATE.DATE_TO_CHARDATE(p_end_date);
 savepoint pqp_insert_mileage_claim;

  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;

pqp_gb_mileage_claim_pkg.insert_mileage_claim
        ( p_effective_date            =>p_effective_date,
          p_web_adi_identifier         =>p_web_adi_identifier  ,
          p_info_id                    =>p_info_id  ,
          p_time_stamp                 =>p_time_stamp  ,
          p_assignment_id              =>p_assignment_id,
          p_business_group_id          =>p_business_group_id,
          p_ownership                  =>p_ownership ,
          p_usage_type                 =>p_usage_type  ,
          p_vehicle_type               =>p_vehicle_type,
          p_start_date                 =>l_start_date  ,
          p_end_date                   =>l_end_date  ,
          p_claimed_mileage            =>p_claimed_mileage ,
          p_actual_mileage             =>p_actual_mileage,
          p_registration_number        =>p_registration_number,
          p_engine_capacity            =>p_engine_capacity,
          p_fuel_type                  =>p_fuel_type ,
          p_calculation_method         =>p_calculation_method ,
          p_user_rates_table           =>p_user_rates_table,
          p_fiscal_ratings             =>p_fiscal_ratings,
          p_PAYE_taxable               =>p_PAYE_taxable,
          p_no_of_passengers           =>p_no_of_passengers,
          p_purpose                    =>p_purpose,
          p_data_source                =>p_data_source,
          p_user_type                  =>p_user_type  ,
          p_mileage_claim_element      =>p_mileage_claim_element  ,
          p_element_entry_id           =>p_element_entry_id  ,
          p_element_entry_date         =>p_element_entry_date
 );


    p_return_status := hr_multi_message.get_return_status_disable;
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
   rollback to savepoint pqp_insert_mileage_claim;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_mileage_claim_element       :=null;
    p_element_entry_id            := null;
    p_element_entry_date          := null;
    p_return_status := hr_multi_message.get_return_status_disable;

    hr_utility.set_location(' Leaving:' || l_proc,40);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
   rollback to savepoint pqp_insert_mileage_claim;
   if hr_multi_message.unexpected_error_add(l_proc) then
       --raise;
    p_return_status := hr_multi_message.get_return_status_disable;
    end if;
     -- Reset IN OUT parameters and set OUT parameters
    --
    p_mileage_claim_element       :=null;
    p_element_entry_id            := null;
    p_element_entry_date          := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
    --raise;
END;


PROCEDURE pqp_update_mileage_claim
        ( p_effective_date             IN DATE,
          p_assignment_id              IN number,
          p_business_group_id          IN NUMBER,
          p_legislation_code           IN VARCHAR2,
          p_ownership                  IN VARCHAR2  ,
          p_usage_type                 IN VARCHAR2  ,
          p_vehicle_type               IN VARCHAR2,
          p_start_date_o               IN DATE  ,
          p_start_date                 IN DATE  ,
          p_end_date_o                 IN DATE  ,
          p_end_date                   IN DATE  ,
          p_claimed_mileage_o          IN VARCHAR2  ,
          p_claimed_mileage            IN VARCHAR2  ,
          p_actual_mileage_o           IN VARCHAR2  ,
          p_actual_mileage             IN VARCHAR2  ,
          p_registration_number        IN VARCHAR2  ,
          p_engine_capacity            IN VARCHAR2  ,
          p_fuel_type                  IN VARCHAR2  ,
          p_calculation_method         IN VARCHAR2  ,
          p_user_rates_table           IN VARCHAR2  ,
          p_fiscal_ratings_o           IN VARCHAR2  ,
          p_fiscal_ratings             IN VARCHAR2  ,
          p_PAYE_taxable               IN VARCHAR2  ,
          p_no_of_passengers_o         IN VARCHAR2  ,
          p_no_of_passengers           IN VARCHAR2  ,
          p_purpose                    IN VARCHAR2  ,
          p_data_source                IN VARCHAR2  ,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_return_status              OUT nocopy varchar2
 )
IS
l_start_date  VARCHAR2(20);
l_end_date     VARCHAR2(20);
l_start_date_o  VARCHAR2(20);
l_end_date_o     VARCHAR2(20);
l_proc    varchar2(72) := g_package ||'update_mileage_claim';
BEGIN
l_start_date :=FND_DATE.DATE_TO_CHARDATE(p_start_date);
l_end_date   :=FND_DATE.DATE_TO_CHARDATE(p_end_date);
l_start_date_o :=p_start_date_o;
l_end_date_o   :=p_end_date_o;
 hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_mileage_claim;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --

 pqp_gb_mileage_claim_pkg.update_mileage_claim
         ( p_effective_date           => p_effective_date  ,
           p_assignment_id            => p_assignment_id   ,
          p_business_group_id         => p_business_group_id ,
          p_ownership                 => p_ownership ,
          p_usage_type                => p_usage_type ,
          p_vehicle_type              => p_vehicle_type ,
          p_start_date_o              => l_start_date_o ,
          p_start_date                => l_start_date ,
          p_end_date_o                => l_end_date_o  ,
          p_end_date                  => l_end_date ,
          p_claimed_mileage_o         => p_claimed_mileage_o  ,
          p_claimed_mileage           => p_claimed_mileage ,
          p_actual_mileage_o          => p_actual_mileage_o ,
          p_actual_mileage            => p_actual_mileage ,
          p_registration_number       => p_registration_number ,
          p_engine_capacity           => p_engine_capacity ,
          p_fuel_type                 => p_fuel_type  ,
          p_calculation_method        => p_calculation_method ,
          p_user_rates_table          => p_user_rates_table ,
          p_fiscal_ratings_o          => p_fiscal_ratings_o ,
          p_fiscal_ratings            => p_fiscal_ratings ,
          p_PAYE_taxable              => p_PAYE_taxable ,
          p_no_of_passengers_o        => p_no_of_passengers_o  ,
          p_no_of_passengers          => p_no_of_passengers ,
          p_purpose                   => p_purpose,
          p_data_source               => p_data_source ,
          p_mileage_claim_element     => p_mileage_claim_element ,
          p_element_entry_id          => p_element_entry_id ,
          p_element_entry_date        => p_element_entry_date
         );

 -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_mileage_claim;
    --
    -- Reset IN OUT parameters and set OUT parameters
     p_mileage_claim_element       :=null;
     p_element_entry_id            := null;
     p_element_entry_date          := null;
     p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_mileage_claim;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
     p_return_status := hr_multi_message.get_return_status_disable;
     --  raise;
    end if;
    --
     -- Reset IN OUT and set OUT parameters
    --
     p_mileage_claim_element       :=null;
     p_element_entry_id            := null;
     p_element_entry_date          := null;
     p_return_status := hr_multi_message.get_return_status_disable;
     hr_utility.set_location(' Leaving:' || l_proc,50);
     --raise;


END;


PROCEDURE pqp_delete_mileage_claim
        (  p_effective_date            IN DATE,
          p_assignment_id              IN number,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_return_status              OUT NOCOPY varchar2
 )
IS
l_proc    varchar2(72) := g_package ||'delete_mileage_claim';
BEGIN
hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_mileage_claim;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;


pqp_gb_mileage_claim_pkg.delete_mileage_claim
        ( p_effective_date             => p_effective_date,
          p_assignment_id              => p_assignment_id,
          p_mileage_claim_element      => p_mileage_claim_element  ,
          p_element_entry_id           => p_element_entry_id  ,
          p_element_entry_date         => p_element_entry_date
         );


-- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_mileage_claim;
    --
    -- Reset IN OUT parameters and set OUT parameters

     p_mileage_claim_element       :=null;
     p_element_entry_id            := null;
     p_element_entry_date          := null;
     p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_mileage_claim;
    if hr_multi_message.unexpected_error_add(l_proc) then
     p_return_status := hr_multi_message.get_return_status_disable;
       hr_utility.set_location(' Leaving:' || l_proc,40);
      -- raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters

     p_mileage_claim_element       :=null;
     p_element_entry_id            := null;
     p_element_entry_date          := null;
     p_return_status := hr_multi_message.get_return_status_disable;
     hr_utility.set_location(' Leaving:' || l_proc,50);
     --raise;

END;


---Called from JDEV ----
--
-- Function get_code returns the code of the meaning passed
--
-- The Code depends on the value of the p_option parameter
-- p_option = 'R' -> p_field has the rates table name and it Returns the Rates table id
--
FUNCTION get_code
(p_option         IN VARCHAR2
,p_field          IN VARCHAR2
) RETURN VARCHAR2
IS

  --
  -- Cursor to fetch the Rate Table id given the rates table name
  --
  CURSOR c_get_rates_table_id
  IS
  select user_table_id
    from pay_user_tables
   where range_or_match = 'M'
     and user_table_name = p_field;

l_field varchar2(100);
BEGIN

  IF (p_field IS NULL) THEN
    RETURN null;
  END IF;
  IF (p_option = 'R') THEN
    OPEN c_get_rates_table_id;
    FETCH c_get_rates_table_id INTO l_field;
    CLOSE c_get_rates_table_id;
  END IF;
  RETURN l_field;
END get_code;

--
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
) RETURN VARCHAR2
IS

  --
  -- Cursor to fetch the Element Name given the element type id
  --
  CURSOR c_get_element_name
  IS
  select element_name
    from pay_element_types_f_tl
   where element_type_id = p_field_id;

  --
  -- Cursor to fetch the Rates Table Name given the rates table id
  --
  CURSOR c_get_rates_table_name
  IS
  select user_table_name
    from pay_user_tables
   where user_table_id = p_field_id;

l_field_meaning varchar2(100);
BEGIN

  IF (p_field_id IS NULL) THEN
    RETURN null;
  END IF;
  IF (p_option = 'R') THEN
    OPEN c_get_rates_table_name;
    FETCH c_get_rates_table_name INTO l_field_meaning;
    CLOSE c_get_rates_table_name;
  ELSIF (p_option = 'E') THEN
    OPEN c_get_element_name;
    FETCH c_get_element_name INTO l_field_meaning;
    CLOSE c_get_element_name;
  END IF;
  RETURN l_field_meaning;
END get_meaning;

END;

/
