--------------------------------------------------------
--  DDL for Package Body PQP_SS_VEHICLE_MILEAGE_CLAIMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_SS_VEHICLE_MILEAGE_CLAIMS" AS
/* $Header: pqpssvehmlgclm.pkb 120.0 2005/05/29 02:23:13 appldev noship $*/

--This function gets the confirmation number which is
--the transaction step id which was created originally
--when the claim is created.
--This function is currently not used as it was decided that
--the confirmation number will not be given.
--if the confirmation number is decided to be shown then
-- we need to uncomment in few places where metioned
--uncomment for conf
FUNCTION get_conf_number (p_element_entry_id IN NUMBER)
RETURN NUMBER
IS

CURSOR c_get_conf_no (cp_element_entry_id  NUMBER)
IS
SELECT psvh.value conf_number
  FROM pqh_ss_value_history psvh
 WHERE psvh.name='P_CONFIRMATION_NUMBER'
   AND psvh.value IS NOT NULL
   AND psvh.step_history_id IN
    (SELECT psvh1.step_history_id
       FROM pqh_ss_value_history psvh1
      WHERE psvh1.name='P_ELEMENT_ENTRY_ID'
        AND psvh1.value =cp_element_entry_id);


l_get_conf_no c_get_conf_no%ROWTYPE;


BEGIN
 OPEN c_get_conf_no (p_element_entry_id);
  LOOP
   FETCH c_get_conf_no INTO l_get_conf_no;
   EXIT WHEN c_get_conf_no%NOTFOUND;
  END LOOP;
 RETURN TO_NUMBER(l_get_conf_no.conf_number);
END;

--This function will be used in the work flow to determine
--which page to open based on the update,insert and delete.

PROCEDURE get_dml_status (
      itemtype        IN         VARCHAR2,
      itemkey         IN         VARCHAR2,
      actid           IN         NUMBER,
      funcmode        IN         VARCHAR2,
      result          OUT NOCOPY VARCHAR2 )

 IS
 l_transaction_id  number;
 l_attr  varchar2(30);
 l_ignore  boolean  ;
 BEGIN

 --Get the status whether the process is in Update or Insert mode

 l_attr:=  wf_engine.GetItemAttrText(
                         itemtype => itemtype,
                         itemkey =>itemkey,
                         aname =>'PQP_DML_STATUS_TYPE_ATTR',
                         ignore_notfound =>l_ignore);

 --Set the same value to determine the process
  result    := l_attr ; --'COMPLETE:I' ; --l_attr;
 END;

--This function is not used currently,but may need when the
--pages are not fully based on WF.
PROCEDURE update_transaction_itemkey (
      itemtype        IN         VARCHAR2,
      itemkey         IN         VARCHAR2,
      actid           IN         NUMBER,
      funcmode        IN         VARCHAR2,
      result          OUT NOCOPY VARCHAR2 )

 IS
 l_transaction_id  number;
 l_attr  varchar2(30);
 l_ignore  boolean  ;
 BEGIN
 l_transaction_id:= wf_engine.GetItemAttrNumber(
                           itemtype => itemtype,
                           itemkey =>itemkey,
                           aname => 'TRANSACTION_ID',
                           ignore_notfound =>l_ignore);

 --Check if approval flag is set to yes in the WF

 l_attr:=  wf_engine.GetActivityAttrText(
                         itemtype => itemtype,
                         itemkey =>itemkey,
                         aname =>'PQP_APPROVAL_REQUIRED',
                         actid =>actid , --'PQP_APPROVAL_REQUIRED',
                         ignore_notfound =>l_ignore);

 --Set the same value to determine the process
 wf_engine.SetItemAttrText(itemtype => itemtype,
                           itemkey =>itemkey,
                           aname =>'HR_RUNTIME_APPROVAL_REQ_FLAG',
                           avalue =>'YES');

 UPDATE hr_api_transactions hat
    SET hat.item_key = itemkey
  WHERE hat.transaction_id=l_transaction_id;

 UPDATE hr_api_transaction_steps hats
    SET hats.item_key = itemkey
  WHERE hats.transaction_id=l_transaction_id;
  result    :='Y';
 end;


PROCEDURE rollback_transaction(
	itemType IN         VARCHAR2,
	itemKey	 IN         VARCHAR2,
        result	 OUT NOCOPY VARCHAR2) IS
BEGIN
--
   savepoint rollback_transaction;
   --
 wf_engine.setItemAttrNumber (
      itemType	=> itemType,
      itemKey   => itemKey,
      aname     => 'TRANSACTION_ID',
      avalue    => null );
   --
   --
 hr_transaction_ss.rollback_transaction (
      itemType	=> itemType,
      itemKey   => itemKey,
      actid     => 0,
      funmode   => 'RUN',
      result    => result );
   --
   --
 result := 'SUCCESS';
   --
   --
EXCEPTION
   --
   WHEN Others THEN
	rollback to rollback_transaction;
	result := 'FAILURE';
   --
END;

--
--
--This function is used to get the values that are inserted into
--the transaction table, this can be used during back button click
--or to show the data from the query page.
FUNCTION  get_vehicle_mileage_claim  (
                  p_transaction_step_id   IN     VARCHAR2
                     )
RETURN ref_cursor
IS
  csr ref_cursor;
BEGIN
 OPEN csr FOR
  SELECT
   hr_transaction_api.get_number_Value
              (p_transaction_step_id, 'P_LOGIN_PERSON_ID') login_person_id
  ,hr_transaction_api.get_number_Value
              (p_transaction_step_id, 'P_PERSON_ID' ) person_id
  ,hr_transaction_api.get_number_Value
              (p_transaction_step_id, 'P_ASSIGNMENT_ID') assignment_id
  ,hr_transaction_api.get_number_Value
              (p_transaction_step_id ,'P_ITEM_TYPE')  item_type
  ,hr_transaction_api.get_number_Value
              (p_transaction_step_id, 'P_ITEM_KEY') item_key
  ,hr_transaction_api.get_number_Value
              (p_transaction_step_id, 'P_ACTIVITY_ID' ) activity_id
  ,hr_transaction_api.get_varchar2_Value
              (p_transaction_step_id, 'P_REGISTRATION_NUMBER' ) registration_number
  ,hr_transaction_api.get_varchar2_Value
              (p_transaction_step_id, 'P_OWNERSHIP') ownership
  ,hr_transaction_api.get_varchar2_Value
              (p_transaction_step_id, 'P_VEHICLE_TYPE' ) vehicle_type
  ,hr_transaction_api.get_date_Value
             (p_transaction_step_id,  'P_START_DATE') start_date
  ,hr_transaction_api.get_date_Value
             (p_transaction_step_id,  'P_END_DATE' ) end_date
  ,hr_transaction_api.get_varchar2_Value
             (p_transaction_step_id,  'P_CLAIMED_MILEAGE' ) claimed_mileage
  ,hr_transaction_api.get_varchar2_Value
             (p_transaction_step_id,  'P_ACTUAL_MILEAGE' ) actual_mileage
  ,hr_transaction_api.get_number_Value
             (p_transaction_step_id,  'P_BUSINESS_GROUP_ID') business_group_id
  ,hr_transaction_api.get_varchar2_Value
             (p_transaction_step_id,  'P_ENGINE_CAPACITY' ) engine_capacity
  ,hr_transaction_api.get_varchar2_Value
             (p_transaction_step_id,  'P_FUEL_TYPE' ) fuel_type
  ,hr_transaction_api.get_varchar2_Value
             (p_transaction_step_id,  'P_FISCAL_RATINGS') fiscal_ratings
  ,hr_transaction_api.get_varchar2_Value
             (p_transaction_step_id,  'P_USAGE_TYPE') usage_type
  ,hr_transaction_api.get_varchar2_Value
             (p_transaction_step_id,  'P_NO_OF_PASSENGERS') no_of_passengers
  ,hr_transaction_api.get_varchar2_Value
             (p_transaction_step_id,  'P_PURPOSE') purpose
  ,hr_transaction_api.get_number_Value
             (p_transaction_step_id,  'P_ELEMENT_ENTRY_ID') element_entry_id
  ,hr_transaction_api.get_number_Value
             (p_transaction_step_id,  'P_OBJECT_VERSION_NUMBER') object_version_number
  ,hr_transaction_api.get_date_Value
             (p_transaction_step_id,  'P_EFFECTIVE_DATE') p_effective_date
 FROM dual;

 RETURN csr;
END get_vehicle_mileage_claim;

--
--
--This procedure is called before the data is inserted into transaction table,
--This procedure makes sure the data entered is valid by validating against
--the base table.
PROCEDURE create_validate_mileage_claim
         (
          p_effective_date             IN DATE,
          p_web_adi_identifier         IN VARCHAR2 ,
          p_info_id                    IN VARCHAR2 ,
          p_time_stamp                 IN VARCHAR2 ,
          p_assignment_id              IN NUMBER   ,
          p_business_group_id          IN NUMBER   ,
          p_ownership                  IN VARCHAR2 ,
          p_usage_type                 IN VARCHAR2 ,
          p_vehicle_type               IN VARCHAR2 ,
          p_start_date                 IN DATE ,
          p_end_date                   IN DATE ,
          p_claimed_mileage            IN VARCHAR2 ,
          p_actual_mileage             IN VARCHAR2 ,
          p_claimed_mileage_o          IN VARCHAR2 ,
          p_actual_mileage_o           IN VARCHAR2 ,
          p_registration_number        IN VARCHAR2 ,
          p_engine_capacity            IN VARCHAR2 ,
          p_fuel_type                  IN VARCHAR2 ,
          p_fiscal_ratings             IN VARCHAR2 ,
          p_no_of_passengers           IN VARCHAR2 ,
          p_purpose                    IN VARCHAR2 ,
          p_user_type                  IN VARCHAR2 ,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_mode                       OUT NOCOPY VARCHAR2,
          p_return_status              OUT NOCOPY VARCHAR2

          )
IS

pragma autonomous_transaction;
BEGIN
 create_vehicle_mileage_claims
 (
  p_effective_date             => p_effective_date,
  p_web_adi_identifier         => p_web_adi_identifier ,
  p_info_id                    => p_info_id,
  p_time_stamp                 => p_time_stamp,
  p_assignment_id              => p_assignment_id,
  p_business_group_id          => p_business_group_id,
  p_ownership                  => p_ownership,
  p_usage_type                 => p_usage_type,
  p_vehicle_type               => p_vehicle_type,
  p_start_date                 => p_start_date,
  p_end_date                   => p_end_date,
  p_claimed_mileage            => p_claimed_mileage,
  p_actual_mileage             => p_actual_mileage,
  p_claimed_mileage_o          => p_claimed_mileage_o,
  p_actual_mileage_o           => p_actual_mileage_o,
  p_registration_number        => p_registration_number,
  p_engine_capacity            => p_engine_capacity,
  p_fuel_type                  => p_fuel_type,
  p_fiscal_ratings             => p_fiscal_ratings,
  p_no_of_passengers           => p_no_of_passengers,
  p_purpose                    => p_purpose,
  p_user_type                  => p_user_type,
  p_mileage_claim_element      => p_mileage_claim_element,
  p_element_entry_id           => p_element_entry_id,
  p_element_entry_date         => p_element_entry_date,
  p_mode                       => p_mode,
  p_return_status              => p_return_status
  );
 ROLLBACK;
  EXCEPTION
  WHEN hr_utility.hr_error THEN
  hr_utility.raise_error;
  WHEN OTHERS THEN
  RAISE;  -- Raise error here relevant to the new tech stack.
END;



-- ----------------------------------------------------------------------------
-- |------------------------< get_transaction_id >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_transaction_id
  (p_transaction_step_id IN NUMBER
   ,p_transaction        OUT NOCOPY NUMBER) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc varchar2(72);
  l_transaction_id    hr_api_transactions.transaction_id%type;
  -- cursor to select the transaction_id of the step
  cursor csr_hats is
    select hats.transaction_id
    from   hr_api_transaction_steps  hats
    where  hats.transaction_step_id = p_transaction_step_id;
begin


  open csr_hats;
  fetch csr_hats into l_transaction_id;
  if csr_hats%notfound then
    -- the transaction step doesn't exist
    close csr_hats;
    hr_utility.set_message(801, 'HR_51751_WEB_TRA_STEP_EXISTS');
    hr_utility.raise_error;
  end if;
  close csr_hats;
  p_transaction := l_transaction_id;



end get_transaction_id;
--This procedure creates mileage claims after the approval process.
--This procedure handles both update and create.

PROCEDURE create_vehicle_mileage_claims
         (
          p_effective_date             IN DATE,
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
          p_actual_mileage             IN VARCHAR2  ,
          p_claimed_mileage_o          IN VARCHAR2  ,
          p_actual_mileage_o           IN VARCHAR2  ,
          p_registration_number        IN VARCHAR2  ,
          p_engine_capacity            IN VARCHAR2  ,
          p_fuel_type                  IN VARCHAR2  ,
          p_fiscal_ratings             IN VARCHAR2  ,
          p_no_of_passengers           IN VARCHAR2  ,
          p_purpose                    IN VARCHAR2  ,
          p_user_type                  IN VARCHAR2  ,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_mode                       OUT NOCOPY VARCHAR2,
          p_return_status              OUT NOCOPY VARCHAR2


          )
IS


BEGIN
 IF p_element_entry_id is NULL THEN
  pqp_gb_mileage_claim_pkg.insert_mileage_claim
         (
          p_effective_date             => RTRIM(LTRIM(p_effective_date)),
          p_web_adi_identifier         => p_web_adi_identifier,
          p_info_id                    => p_info_id,
          p_time_stamp                 => p_time_stamp,
          p_assignment_id              => p_assignment_id,
          p_business_group_id          => p_business_group_id,
          p_ownership                  => p_ownership,
          p_usage_type                 => p_usage_type,
          p_vehicle_type               => p_vehicle_type,
          p_start_date                 => p_start_date,
          p_end_date                   => p_end_date,
          p_claimed_mileage            => p_claimed_mileage,
          p_actual_mileage             => p_actual_mileage,
          p_registration_number        => p_registration_number,
          p_engine_capacity            => p_engine_capacity,
          p_fuel_type                  => p_fuel_type,
          p_fiscal_ratings             => p_fiscal_ratings,
          p_no_of_passengers           => p_no_of_passengers,
          p_purpose                    => p_purpose,
          p_user_type                  => p_user_type,
          p_mileage_claim_element      => p_mileage_claim_element,
          p_element_entry_id           => p_element_entry_id,
          p_element_entry_date         => p_element_entry_date
         );



  p_mode:='I';

 ELSE
  pqp_gb_mileage_claim_pkg.update_mileage_claim
         (
          p_effective_date             =>  RTRIM(LTRIM(p_effective_date)),
          p_assignment_id              => p_assignment_id,
          p_business_group_id          => p_business_group_id,
          p_ownership                  => p_ownership,
          p_usage_type                 => p_usage_type,
          p_vehicle_type               => p_vehicle_type,
          p_start_date                 => p_start_date,
          p_end_date                   => p_end_date,
          p_claimed_mileage_o          => p_claimed_mileage_o,
          p_claimed_mileage            => p_claimed_mileage,
          p_actual_mileage_o           => p_actual_mileage_o,
          p_actual_mileage             => p_actual_mileage,
          p_registration_number        => p_registration_number,
          p_engine_capacity            => p_engine_capacity,
          p_fuel_type                  => p_fuel_type,
          p_fiscal_ratings             => p_fiscal_ratings,
          p_no_of_passengers           => p_no_of_passengers,
          p_purpose                    => p_purpose,
          p_mileage_claim_element      => p_mileage_claim_element,
          p_element_entry_id           => p_element_entry_id,
          p_element_entry_date         => p_element_entry_date
         );
  p_mode:='U';
 END IF;

  EXCEPTION
    WHEN hr_utility.hr_error THEN
  	hr_utility.raise_error;
    WHEN OTHERS THEN
        RAISE;  -- Raise error here relevant to the new tech stack.
END;

PROCEDURE delete_validate_mileage_claim (
   p_effective_date         IN DATE
  ,p_assignment_id          IN NUMBER
  ,p_mileage_claim_element  IN NUMBER
  ,p_element_entry_id       IN OUT NOCOPY NUMBER
  ,p_element_entry_date     IN OUT NOCOPY DATE
  ,p_error_status           OUT NOCOPY VARCHAR2
   )

IS
pragma autonomous_transaction;
l_mileage_claim_element  NUMBER;
BEGIN
 pqp_mileage_claim_pkg.pqp_delete_mileage_claim
        ( p_effective_date             =>p_effective_date,
          p_assignment_id              =>p_assignment_id,
          p_mileage_claim_element      =>l_mileage_claim_element  ,
          p_element_entry_id           =>p_element_entry_id  ,
          p_element_entry_date         =>p_element_entry_date,
          p_return_status              =>p_error_status
         );
ROLLBACK;
  EXCEPTION
    WHEN hr_utility.hr_error THEN
  	hr_utility.raise_error;
    WHEN OTHERS THEN
        RAISE;  -- Raise error here relevant to the new tech stack.


END;


PROCEDURE delete_vehicle_mileage_claim(
   x_effective_date         IN DATE
  ,x_login_person_id        IN NUMBER
  ,x_person_id              IN NUMBER
  ,x_assignment_id          IN NUMBER
  ,x_business_group_id      IN NUMBER
  ,x_item_key               IN NUMBER
  ,x_item_type              IN VARCHAR2
  ,x_element_entry_id       IN NUMBER
  ,p_status                 IN VARCHAR2
  ,x_transaction_id         IN OUT NOCOPY NUMBER
  ,x_transaction_step_id    IN OUT NOCOPY NUMBER
  ,x_confirmation_number    OUT NOCOPY NUMBER
  ,x_error_status           OUT NOCOPY VARCHAR2
                      )

IS



CURSOR c_del_values
IS
SELECT transaction_step_id
 FROM  hr_api_transaction_steps hats
 WHERE transaction_id = x_transaction_id;

l_del_values                    c_del_values%ROWTYPE;
l_transaction_id                NUMBER;
l_trans_tbl                     hr_transaction_ss.transaction_table;
l_count                         NUMBER :=0;
l_transaction_step_id           NUMBER;
l_api_name                      hr_api_transaction_steps.api_name%TYPE
                                := 'PQP_SS_VEHICLE_MILEAGE_CLAIMS.DELETE_PROCESS_API';
l_result                        VARCHAR2(100);
l_trns_object_version_number    NUMBER;
l_review_proc_call              VARCHAR2(30);-- := 'PqpVehStatusReview';
l_effective_date                DATE            := SYSDATE;
l_ovn                           NUMBER ;
l_error_message                 VARCHAR2(80);
l_error_status                  VARCHAR2(10);
l_mileage_claim_element         NUMBER;
l_element_entry_date            DATE ;
l_element_entry_id              NUMBER;
BEGIN

   --Validate the data before inserting into
   -- transaction table.
  l_element_entry_id :=x_element_entry_id;
  delete_validate_mileage_claim
     ( p_effective_date             =>x_effective_date,
       p_assignment_id              =>x_assignment_id,
       p_mileage_claim_element      =>l_mileage_claim_element  ,
       p_element_entry_id           =>l_element_entry_id  ,
       p_element_entry_date         =>l_element_entry_date,
       p_error_status              =>l_error_status
       );




  l_count:=1;
  l_trans_tbl(l_count).param_name      := 'P_LOGIN_PERSON_ID';
  l_trans_tbl(l_count).param_value     :=  x_login_person_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_EFFECTIVE_DATE';
  l_trans_tbl(l_count).param_value     :=  x_effective_date;
  l_trans_tbl(l_count).param_data_type := 'DATE';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PERSON_ID';
  l_trans_tbl(l_count).param_value     :=  x_person_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASSIGNMENT_ID';
  l_trans_tbl(l_count).param_value     :=  x_ASSIGNMENT_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_BUSINESS_GROUP_ID';
  l_trans_tbl(l_count).param_value     :=  x_business_group_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ELEMENT_ENTRY_ID';
  l_trans_tbl(l_count).param_value     :=  x_element_entry_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  IF x_transaction_id is NULl THEN
   hr_transaction_api.create_transaction(
               p_validate                    => false
              ,p_creator_person_id           =>  x_login_person_id
              ,p_transaction_privilege       => 'PRIVATE'
              ,p_product_code                => 'PQP'
              ,p_url                         => NULL
              ,p_status                      =>NULL
              ,p_section_display_name        =>NULL
              ,p_function_id                 =>NULL
              ,p_transaction_ref_table       =>NULL
              ,p_transaction_ref_id          =>NULL
              ,p_transaction_type            =>'WF'
              ,p_assignment_id               =>x_assignment_id
              ,p_selected_person_id          =>x_person_id
              ,p_item_type                   => x_item_type
              ,p_item_key                    =>x_item_key
              ,p_transaction_effective_date  =>x_effective_date
              ,p_process_name                =>NULL
              ,p_plan_id                     =>NULL
              ,p_rptg_grp_id                 =>NULL
              ,p_effective_date_option       =>x_effective_date
              ,p_transaction_id              => l_transaction_id
              );
   x_transaction_id         :=  l_transaction_id;
 --Create transaction steps
   hr_transaction_api.create_transaction_step
              (p_validate                    => false
              ,p_creator_person_id           => x_login_person_id
              ,p_transaction_id              => l_transaction_id
              ,p_api_name                    => l_api_name
              ,p_api_display_name            => l_api_name
              ,p_item_type                   => null --x_item_type
              ,p_item_key                    => NULL --x_item_key
              ,p_activity_id                 => NULL --x_activity_id
              ,p_transaction_step_id         => l_transaction_step_id
              ,p_object_version_number       =>  l_ovn
             );
  ELSE
   DELETE from hr_api_transaction_values
     WHERE transaction_step_id = x_transaction_step_id;
    l_transaction_step_id := x_transaction_step_id;
  END IF;

  FOR i in 1..l_trans_tbl.count
   LOOP
    IF l_trans_tbl(i).param_data_type ='VARCHAR2' THEN
     hr_transaction_api.set_varchar2_value
       (p_transaction_step_id  => l_transaction_step_id
       ,p_person_id            => x_person_id
       ,p_name                 => l_trans_tbl (i).param_name
       ,p_value                =>  l_trans_tbl (i).param_value
       );

   ELSIF  l_trans_tbl(i).param_data_type ='DATE' THEN
    hr_transaction_api.set_date_value
       (
       p_transaction_step_id  => l_transaction_step_id
      ,p_person_id            => x_person_id
      ,p_name                 => l_trans_tbl (i).param_name
      ,p_value                => fnd_date.displaydate_to_date
                                (l_trans_tbl (i).param_value  )  );
   ELSIF  l_trans_tbl(i).param_data_type ='NUMBER' THEN
    hr_transaction_api.set_number_value
      (
      p_transaction_step_id       => l_transaction_step_id
     ,p_person_id                 => x_person_id
     ,p_name                      =>l_trans_tbl (i).param_name
     ,p_value                     =>TO_NUMBER(l_trans_tbl (i).param_value ));
   END IF;
  END LOOP;

  EXCEPTION
    WHEN hr_utility.hr_error THEN
  	hr_utility.raise_error;
    WHEN OTHERS THEN
        RAISE;  -- Raise error here relevant to the new tech stack.



END;

PROCEDURE set_vehicle_mileage_claim (
   x_p_validate                 IN BOOLEAN
  ,x_effective_date             IN DATE
  ,x_login_person_id            IN NUMBER
  ,x_person_id                  IN NUMBER
  ,x_assignment_id              IN NUMBER
  ,x_item_type                  IN VARCHAR2
  ,x_item_key                   IN NUMBER
  ,x_activity_id                IN NUMBER
  ,x_business_group_id          IN NUMBER
  ,x_legislation_code           IN VARCHAR2
  ,x_ownership                  IN VARCHAR2
  ,x_usage_type                 IN VARCHAR2
  ,x_vehicle_type               IN VARCHAR2
  ,x_start_date                 IN DATE
  ,x_end_date                   IN DATE
  ,x_claimed_mileage            IN VARCHAR2
  ,x_actual_mileage             IN VARCHAR2  DEFAULT NULL
  ,x_claimed_mileage_o          IN VARCHAR2  DEFAULT NULL
  ,x_actual_mileage_o           IN VARCHAR2  DEFAULT NULL
  ,x_registration_number        IN VARCHAR2  DEFAULT NULL
  ,x_engine_capacity            IN VARCHAR2  DEFAULT NULL
  ,x_fuel_type                  IN VARCHAR2  DEFAULT NULL
  ,x_fiscal_ratings             IN VARCHAR2  DEFAULT NULL
  ,x_no_of_passengers           IN VARCHAR2  DEFAULT NULL
  ,x_purpose                    IN VARCHAR2  DEFAULT NULL
  ,x_element_entry_id           IN NUMBER    DEFAULT NULL
  ,x_status                     IN VARCHAR2  DEFAULT NULL
  ,x_effective_date_option      IN VARCHAR2  DEFAULT NULL
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_object_version_number      IN NUMBER
  ,x_error_status               OUT NOCOPY VARCHAR2
  ,x_transaction_id             IN OUT NOCOPY NUMBER
  ,x_transaction_step_id        IN OUT NOCOPY NUMBER
  ,x_confirmation_number        OUT    NOCOPY NUMBER
)
IS
CURSOR c_del_values
IS
SELECT transaction_step_id
 FROM  hr_api_transaction_steps hats
 WHERE transaction_id = x_transaction_id;
l_del_values                   c_del_values%ROWTYPE;
l_transaction_id               NUMBER;
l_trans_tbl                    hr_transaction_ss.transaction_table;
l_count                        NUMBER :=0;
l_transaction_step_id          NUMBER;
l_api_name                     hr_api_transaction_steps.api_name%TYPE
                               := 'PQP_SS_VEHICLE_MILEAGE_CLAIMS.PROCESS_API';
l_result                       VARCHAR2(100);
l_trns_object_version_number   NUMBER;
l_review_proc_call             VARCHAR2(30) := 'PqpMileageClaimReview';
l_effective_date               DATE            := SYSDATE;
l_ovn                          NUMBER;
l_error_message                VARCHAR2(80);
l_error_status                 VARCHAR2(10);
l_mileage_claim_element        VARCHAR2(80);
l_element_entry_id             NUMBER;
l_element_entry_date           DATE;
l_mode                         VARCHAR2(10);
l_function_id                  hr_api_transactions.function_id%TYPE;
p_function_id                  hr_api_transactions.function_id%TYPE;
ln_selected_person_id          hr_api_transactions.selected_person_id%TYPE;
lv_process_name                hr_api_transactions.process_name%TYPE;
lv_status                      hr_api_transactions.status%TYPE;
lv_section_display_name        hr_api_transactions.section_display_name%TYPE;
ln_assignment_id               hr_api_transactions.assignment_id%TYPE;
ld_trans_effec_date            hr_api_transactions.transaction_effective_date%TYPE;
lv_transaction_type            hr_api_transactions.transaction_type%TYPE;
BEGIN
      hr_multi_message.enable_message_list;

   hr_utility.set_location('Entering: Set_vehicle_mileage_claim',5);

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_LOGIN_PERSON_ID';
  l_trans_tbl(l_count).param_value     :=  x_login_person_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_PROC_CALL';
  l_trans_tbl(l_count).param_value     :=  l_review_proc_call;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

   l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_ACTID';
  l_trans_tbl(l_count).param_value     :=  x_activity_id;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_EFFECTIVE_DATE';
  l_trans_tbl(l_count).param_value     :=  x_effective_date;
  l_trans_tbl(l_count).param_data_type := 'DATE';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PERSON_ID';
  l_trans_tbl(l_count).param_value     :=  x_person_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASSIGNMENT_ID';
  l_trans_tbl(l_count).param_value     :=  x_ASSIGNMENT_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_BUSINESS_GROUP_ID';
  l_trans_tbl(l_count).param_value     :=  x_business_group_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_LEGISLATION_CODE';
  l_trans_tbl(l_count).param_value     :=  x_legislation_code;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_OWNERSHIP';
  l_trans_tbl(l_count).param_value     :=  x_ownership;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_USAGE_TYPE';
  l_trans_tbl(l_count).param_value     :=  x_usage_type;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VEHICLE_TYPE';
  l_trans_tbl(l_count).param_value     :=  x_vehicle_type;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_START_DATE';
  l_trans_tbl(l_count).param_value     :=  x_start_date;
  l_trans_tbl(l_count).param_data_type := 'DATE';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_END_DATE';
  l_trans_tbl(l_count).param_value     :=  x_end_date;
  l_trans_tbl(l_count).param_data_type := 'DATE';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_CLAIMED_MILEAGE';
  l_trans_tbl(l_count).param_value     :=  x_claimed_mileage;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ACTUAL_MILEAGE';
  l_trans_tbl(l_count).param_value     :=  x_actual_mileage;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_CLAIMED_MILEAGE_O';
  l_trans_tbl(l_count).param_value     :=  x_claimed_mileage_o;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ACTUAL_MILEAGE_O';
  l_trans_tbl(l_count).param_value     :=  x_actual_mileage_o;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REGISTRATION_NUMBER';
  l_trans_tbl(l_count).param_value     :=  x_registration_number;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ENGINE_CAPACITY';
  l_trans_tbl(l_count).param_value     :=  x_engine_capacity;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_FUEL_TYPE';
  l_trans_tbl(l_count).param_value     :=  x_fuel_type;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_FISCAL_RATINGS';
  l_trans_tbl(l_count).param_value     :=  x_fiscal_ratings;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_NO_OF_PASSENGERS';
  l_trans_tbl(l_count).param_value     :=  x_no_of_passengers;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PURPOSE';
  l_trans_tbl(l_count).param_value     :=  x_purpose;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ELEMENT_ENTRY_ID';
  l_trans_tbl(l_count).param_value     :=  x_element_entry_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';


  ---Now Validate the incomming values against actual table.
  ---Setting the mode determines the dml status.
  IF x_element_entry_id is NULL THEN
   l_mode :='I' ;

  ELSE
   l_mode:='U';
  END IF;




   create_validate_mileage_claim
              (
          p_effective_date             => x_effective_date,
          p_web_adi_identifier         => NULL ,
          p_info_id                    => NULL,
          p_time_stamp                 => NULL,
          p_assignment_id              => x_assignment_id,
          p_business_group_id          => x_business_group_id,
          p_ownership                  => x_ownership,
          p_usage_type                 => x_usage_type,
          p_vehicle_type               => x_vehicle_type,
          p_start_date                 => x_start_date,
          p_end_date                   => x_end_date,
          p_claimed_mileage            => x_claimed_mileage,
          p_actual_mileage             => x_actual_mileage,
          p_claimed_mileage_o          => x_claimed_mileage_o,
          p_actual_mileage_o           => x_actual_mileage_o,
          p_registration_number        => x_registration_number,
          p_engine_capacity            => x_engine_capacity,
          p_fuel_type                  => x_fuel_type,
          p_fiscal_ratings             => x_fiscal_ratings,
          p_no_of_passengers           => x_no_of_passengers,
          p_purpose                    => x_purpose,
          p_user_type                  =>'SS',
          p_mileage_claim_element      => l_mileage_claim_element,
          p_element_entry_id           => l_element_entry_id,
          p_element_entry_date         => l_element_entry_date,
          p_mode                       => l_mode,
          p_return_status              => l_error_status
              );
-- If there are no error messages then insert values into transaction table

  IF x_transaction_id is NULL THEN

    hr_transaction_api.create_transaction(
               p_validate                       =>false
              ,p_creator_person_id              =>x_login_person_id
              ,p_transaction_privilege          =>'PRIVATE'
              ,p_product_code                   =>'PQP'
              ,p_url                            =>NULL
              ,p_status                         =>x_status
              ,p_section_display_name           =>NULL
              ,p_function_id                    =>NULL
              ,p_transaction_ref_table          =>NULL
              ,p_transaction_ref_id             =>NULL
              ,p_transaction_type               =>NULL
              ,p_assignment_id                  =>x_assignment_id
              ,p_selected_person_id             =>x_person_id
              ,p_item_type                      =>x_item_type
              ,p_item_key                       =>x_item_key
              ,p_transaction_effective_date     =>x_effective_date
              ,p_process_name                   =>NULL
              ,p_plan_id                        =>NULL
              ,p_rptg_grp_id                    =>NULL
              ,p_effective_date_option          =>x_effective_date_option
              ,p_transaction_id                 => l_transaction_id
              );

    wf_engine.setitemattrnumber
        (itemtype => x_item_type
        ,itemkey  => x_item_key
        ,aname    => 'TRANSACTION_ID'
        ,avalue   => l_transaction_id);
   x_transaction_id         :=  l_transaction_id;
 --Create transaction steps
   hr_transaction_api.create_transaction_step
              (p_validate                       =>false
              ,p_creator_person_id              =>x_login_person_id
              ,p_transaction_id                 =>l_transaction_id
              ,p_api_name                       =>l_api_name
              ,p_api_display_name               =>l_api_name
              ,p_item_type                      =>x_item_type
              ,p_item_key                       =>x_item_key
              ,p_activity_id                    =>x_activity_id
              ,p_transaction_step_id            =>l_transaction_step_id
              ,p_object_version_number          =>l_ovn
             );
  ELSE
   IF x_transaction_step_id IS NOT NULL THEN
    hr_transaction_api.update_transaction
                      (p_transaction_id        =>x_transaction_id
                      ,p_status                =>x_status
                      );
   DELETE from hr_api_transaction_values
    WHERE transaction_step_id = x_transaction_step_id;
    l_transaction_step_id := x_transaction_step_id;
   ELSE
    l_transaction_step_id := x_transaction_step_id;
    l_transaction_id := x_transaction_id;

   hr_transaction_api.create_transaction_step
              (p_validate                       =>false
              ,p_creator_person_id              =>x_login_person_id
              ,p_transaction_id                 =>l_transaction_id
              ,p_api_name                       =>l_api_name
              ,p_api_display_name               =>l_api_name
              ,p_item_type                      =>x_item_type
              ,p_item_key                       =>x_item_key
              ,p_activity_id                    =>x_activity_id
              ,p_transaction_step_id            =>l_transaction_step_id
              ,p_object_version_number          =>l_ovn
             );


   END IF;
  END IF;
  FOR i in 1..l_trans_tbl.count
   LOOP
    IF l_trans_tbl(i).param_data_type ='VARCHAR2' THEN
     hr_transaction_api.set_varchar2_value
        (p_transaction_step_id  => l_transaction_step_id
        ,p_person_id            => x_person_id
        ,p_name                 => l_trans_tbl (i).param_name
        ,p_value                =>  l_trans_tbl (i).param_value
        );

    ELSIF  l_trans_tbl(i).param_data_type ='DATE' THEN
     hr_transaction_api.set_date_value
        (
        p_transaction_step_id  => l_transaction_step_id
        ,p_person_id            => x_person_id
        ,p_name                 => l_trans_tbl (i).param_name
        ,p_value                => fnd_date.displaydate_to_date
                                  (l_trans_tbl (i).param_value ));
       -- ,p_original_value             );


    ELSIF  l_trans_tbl(i).param_data_type ='NUMBER' THEN
     hr_transaction_api.set_number_value
        (
        p_transaction_step_id       => l_transaction_step_id
       ,p_person_id                 => x_person_id
       ,p_name                      =>l_trans_tbl (i).param_name
       ,p_value                     =>TO_NUMBER(l_trans_tbl (i).param_value ));
    END IF;
   END LOOP;
Commit;
EXCEPTION
 WHEN hr_multi_message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
   --
    -- Reset IN OUT parameters and set OUT parameters
    x_return_status := hr_multi_message.get_return_status_disable;

    hr_utility.set_location(' Leaving:' ,40);
     WHEN others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
   IF hr_multi_message.unexpected_error_add('l_proc') then
       --raise;
    x_return_status := hr_multi_message.get_return_status_disable;
   END IF;
     -- Reset IN OUT parameters and set OUT parameters

    x_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || 'l_proc',50);

  /*  WHEN hr_utility.hr_error THEN
  	hr_utility.raise_error;
    WHEN OTHERS THEN
        RAISE;  -- Raise error here relevant to the new tech stack.
	*/
END;
--
--

PROCEDURE delete_process_api (
   p_validate                   IN BOOLEAN DEFAULT FALSE,
   p_transaction_step_id        IN NUMBER ) IS
--
--
l_ovn                           NUMBER :=1;
l_error_status                  VARCHAR2(10);
l_effective_start_date          DATE;
l_effective_end_date            DATE;
l_person_id                     per_all_people_f.person_id%TYPE;
l_assignment_id                 per_all_assignments_f.assignment_id%TYPE;
l_business_group_id             per_all_assignments_f.business_group_id%TYPE;
l_element_entry_id              NUMBER;
l_effective_date                DATE;
l_mileage_claim_element         NUMBER;
l_confirmation_number           NUMBER;
l_element_entry_date            DATE;
BEGIN
l_person_id                         :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_PERSON_ID' );

l_effective_date                    :=  hr_transaction_api.get_date_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_EFFECTIVE_DATE' );
l_assignment_id                     :=hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_ASSIGNMENT_ID' );

l_business_group_id                 :=hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_BUSINESS_GROUP_ID' );
l_element_entry_id                  :=hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_ELEMENT_ENTRY_ID' );




  pqp_mileage_claim_pkg.pqp_delete_mileage_claim
        ( p_effective_date             =>l_effective_date,
          p_assignment_id              =>l_assignment_id,
          p_mileage_claim_element      =>l_mileage_claim_element  ,
          p_element_entry_id           =>l_element_entry_id  ,
          p_element_entry_date         =>l_element_entry_date,
          p_return_status              =>l_error_status
         );

  EXCEPTION
    WHEN hr_utility.hr_error THEN
  	hr_utility.raise_error;
    WHEN OTHERS THEN
        RAISE;  -- Raise error here relevant to the new tech stack.

END;

PROCEDURE process_api
  (p_validate             in  boolean  default false
  ,p_transaction_step_id  in  number   default null
  ,p_effective_date       in  varchar2 default null
  ) is
--
--
l_assignment_id                 NUMBER;
l_person_id		        NUMBER;
l_ovn		        	NUMBER :=1;
l_effective_date                DATE;
l_registration_number           VARCHAR2(80);
l_vehicle_type                  VARCHAR2(80);
l_business_group_id             NUMBER;
l_engine_capacity               VARCHAR2(80);
l_fuel_type                     VARCHAR2(80);
l_fiscal_ratings                VARCHAR2(80);
l_ownership                     VARCHAR2(80);
l_usage_type                    VARCHAR2(80);
l_object_version_number         NUMBER;
l_error_message                 VARCHAR2(80);
l_error_status                  VARCHAR2(30);
l_get_count                     NUMBER;
l_mileage_claim_element         NUMBER;
l_element_entry_date            DATE;
l_confirmation_number           NUMBER;
l_start_date                     DATE;
l_end_date                      DATE;
l_claimed_mileage               VARCHAR2(30);
l_actual_mileage                VARCHAR2(30);
l_claimed_mileage_o             VARCHAR2(30);
l_actual_mileage_o              VARCHAR2(30);
l_no_of_passengers              VARCHAR2(30);
l_mode                          VARCHAR2(30);
l_purpose                       VARCHAR2(80);
l_element_entry_id              NUMBER;

BEGIN
  hr_utility.set_location('Entering:process_api',5);
  --
  savepoint  process_veh_mileage;
  --



 l_person_id                         :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_PERSON_ID' );

 l_assignment_id                     :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_ASSIGNMENT_ID' );


l_effective_date                     :=  hr_transaction_api.get_date_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_EFFECTIVE_DATE' );

l_registration_number                :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_REGISTRATION_NUMBER' );

l_vehicle_type                       :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VEHICLE_TYPE' );

l_business_group_id                  :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_BUSINESS_GROUP_ID');


l_engine_capacity                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_ENGINE_CAPACITY');



l_start_date                        :=  hr_transaction_api.get_date_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_START_DATE');


l_end_date                          :=  hr_transaction_api.get_date_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_END_DATE');

l_claimed_mileage                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_CLAIMED_MILEAGE');

l_actual_mileage                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_ACTUAL_MILEAGE');


l_claimed_mileage_o                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_CLAIMED_MILEAGE_O');

l_actual_mileage_o                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_ACTUAL_MILEAGE_O');

l_fuel_type                          :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_FUEL_TYPE');

l_fiscal_ratings                     :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_FISCAL_RATINGS' );

l_ownership                          :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_OWNERSHIP');

l_usage_type                          :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_USAGE_TYPE');


l_no_of_passengers                     :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_NO_OF_PASSENGERS');


l_purpose                              :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_PURPOSE');


l_element_entry_id                  :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_ELEMENT_ENTRY_ID');
 create_vehicle_mileage_claims
         (
          p_effective_date             => l_effective_date,
          p_web_adi_identifier         => NULL,
          p_info_id                    => NULL,
          p_time_stamp                 => NULL,
          p_assignment_id              => l_assignment_id,
          p_business_group_id          => l_business_group_id,
          p_ownership                  => l_ownership,
          p_usage_type                 => l_usage_type,
          p_vehicle_type               => l_vehicle_type,
          p_start_date                 => l_start_date,
          p_end_date                   => l_end_date,
          p_claimed_mileage            => l_claimed_mileage,
          p_actual_mileage             => l_actual_mileage,
          p_claimed_mileage_o          => l_claimed_mileage_o,
          p_actual_mileage_o           => l_actual_mileage_o,
          p_registration_number        => l_registration_number,
          p_engine_capacity            => l_engine_capacity,
          p_fuel_type                  => l_fuel_type,
          p_fiscal_ratings             => l_fiscal_ratings,
          p_no_of_passengers           => l_no_of_passengers,
          p_purpose                    => l_purpose,
          p_user_type                  => 'SS',
          p_mileage_claim_element      => l_mileage_claim_element,
          p_element_entry_id           => l_element_entry_id,
          p_element_entry_date         => l_element_entry_date,
          p_mode                       => l_mode,
          p_return_status              => l_error_status
          );




  --
  --
  --
  hr_utility.set_location('Leaving: process_api',10);
 EXCEPTION
    WHEN hr_utility.hr_error THEN
        ROLLBACK TO process_veh_mileage;
  	hr_utility.raise_error;
    WHEN OTHERS THEN
        RAISE;  -- Raise error here relevant to the new tech stack.
END process_api;

PROCEDURE self_or_subordinate (
	itemtype   	IN VARCHAR2,
        itemkey    	IN VARCHAR2,
        actid      	IN NUMBER,
        funcmode   	IN VARCHAR2,
        resultout  	IN OUT NOCOPY VARCHAR2) IS
--
nval1    number;
nval2    number;
l_resultout varchar2(200) := resultout;
--
BEGIN
--
    nval1 := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey,actid, 'VALUE1');
    nval2 := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey,actid, 'VALUE2');

    IF nval1 = nval2 THEN
	resultout := 'SELF';
    ELSE
	resultout := 'SUBORDINATE';
    END IF;
EXCEPTION
  WHEN OTHERS THEN
  resultout := l_resultout;
      RAISE;
--
END self_or_subordinate;
--

END  PQP_SS_VEHICLE_MILEAGE_CLAIMS;


/
