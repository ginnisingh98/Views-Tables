--------------------------------------------------------
--  DDL for Package Body PQP_SS_VEHICLE_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_SS_VEHICLE_TRANSACTIONS" AS
/* $Header: pqpssvehinfo.pkb 120.0 2005/05/29 02:22:18 appldev noship $*/




---Check if extra info exists
PROCEDURE IS_EXTRA_INFO_EXISTS (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 )

IS
l_transaction_id  number;
l_attr  varchar2(30);
l_ignore  boolean  ;
 Begin

 --Get the status whether the Extra info exists or not
 --returns 'Y' or 'N'

 l_attr:=  wf_engine.GetItemAttrText(
                         itemtype => itemtype,
                         itemkey =>itemkey,
                         aname =>'PQP_EXTRA_INFO_EXISTS_ATTR',
                         ignore_notfound =>l_ignore);

 --Set the same value to determine the process

  result    := 'COMPLETE:'||l_attr ; --'COMPLETE:I' ; --l_attr;

 end;

---Get global valie for extra info exist checking
PROCEDURE set_extra_info_val  (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 )
  IS
 l_transaction_id  number;
 l_attr  varchar2(30);
 l_ignore  boolean  ;
 l_responsibility_id  number;
 l_count  number:=0;
 l_exists  VARCHAR2(1);
 CURSOR c_get_info IS
 SELECT COUNT(1)
 FROM pqp_veh_repos_info_types ait, fnd_descr_flex_contexts_vl flv
 WHERE ait.information_type = flv.descriptive_flex_context_code
  AND flv.descriptive_flexfield_name IN ( 'Vehicle Repos Extra Info DDF'
        ,'Vehicle Alloc Extra Info DDF')
   AND flv.enabled_flag = 'Y'
   AND exists (  SELECT NULL
   FROM per_info_type_security its,
        pqp_veh_repos_info_types ait
  WHERE its.info_type_table_name IN ( 'PQP_VEH_REPOS_INFO_TYPES'
                       ,'PQP_VEH_ALLOC_INFO_TYPES')
   AND its.information_type = ait.information_type
   AND  responsibility_id = l_responsibility_id  );

 Begin

 --Get the status whether the process is in Update or Insert mode

 l_responsibility_id:=  wf_engine.GetItemAttrNumber(
                         itemtype => itemtype,
                         itemkey =>itemkey,
                         aname =>'PQP_RESPONSIBILITY_ID_ATTR',
                       --  actid =>actid ,
                         ignore_notfound =>l_ignore);

 --Set the same value to determine the process
 OPEN c_get_info;
 FETCH c_get_info INTO l_count;
 CLOSE  c_get_info;

 IF l_count > 0 THEN
  l_exists :='Y';
 ELSE
  l_exists :='N';
 END IF;


   wf_engine.SetItemAttrText(
                         itemtype => itemtype,
                         itemkey =>itemkey,
                         aname =>'PQP_EXTRA_INFO_EXISTS_ATTR',
                         avalue =>l_exists);
  result    := 'Success'; --'COMPLETE:I' ; --l_attr;
 end;


--This process is called after the approval process is over
--for delete operation
--this will end date the vehicle.
--Note:This call is not currently used as the delete
--operation is done directly.
function get_transaction_id
  (p_transaction_step_id in number) return number is
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
  return(l_transaction_id);


  hr_utility.set_location(' Leaving:'||l_proc, 10);


end get_transaction_id;
PROCEDURE delete_process (
    p_validate             IN BOOLEAN
   ,p_effective_date         IN DATE
   ,p_person_id              IN NUMBER
   ,p_assignment_id          IN NUMBER
   ,p_business_group_id      IN NUMBER
   ,p_vehicle_allocation_id  IN NUMBER
   ,p_error_status           OUT NOCOPY VARCHAR2
                      )
--
--
IS

l_person_id             NUMBER;
l_ovn                   NUMBER :=1;

CURSOR c_get_ovn (cp_allocation_id     NUMBER
                 ,cp_business_group_id NUMBER
                 ,cp_assignment_id     NUMBER
                 ,cp_effective_date    DATE
                 )
IS
SELECT pva.object_version_number
      ,pva.vehicle_repository_id repository_id
  FROM pqp_vehicle_allocations_f pva
 WHERE pva.vehicle_allocation_id =cp_allocation_id
   AND pva.assignment_id =cp_assignment_id
   AND pva.business_group_id =cp_business_group_id
   AND rtrim(ltrim(cp_effective_date)) BETWEEN pva.effective_start_date
                             AND pva.effective_end_date;

CURSOR c_get_tot_users (cp_repository_id     NUMBER
                       ,cp_business_group_id NUMBER
                       ,cp_assignment_id     NUMBER
                       ,cp_effective_date    DATE
                        )
IS
SELECT COUNT(pva.vehicle_repository_id) usr_count
  FROM pqp_vehicle_allocations_f pva
 WHERE pva.vehicle_repository_id = cp_repository_id
   AND pva.business_group_id =cp_business_group_id
   AND pva.assignment_id    = cp_assignment_id
   AND rtrim(ltrim(cp_effective_date)) BETWEEN pva.effective_start_date
                             AND pva.effective_end_date;

CURSOR c_get_rep_ovn (cp_repository_id     NUMBER
                     ,cp_business_group_id NUMBER
                     ,cp_effective_date    DATE
                        )
IS
SELECT pvr.object_version_number ovn
  FROM pqp_vehicle_repository_f pvr
 WHERE pvr.vehicle_repository_id = cp_repository_id
   AND pvr.business_group_id     = cp_business_group_id
   AND rtrim(ltrim(cp_effective_date)) BETWEEN pvr.effective_start_date
                             AND pvr.effective_end_date;

l_get_rep_ovn   c_get_rep_ovn%ROWTYPE;
l_get_ovn       c_get_ovn%ROWTYPE;
l_get_tot_users c_get_tot_users%ROWTYPE;
l_effective_start_date DATE;
l_effective_end_date   DATE;
BEGIN

 OPEN c_get_ovn (
                 p_vehicle_allocation_id
                ,p_business_group_id
                ,p_assignment_id
                ,p_effective_date
                 );
  FETCH c_get_ovn INTO l_get_ovn;
 CLOSE c_get_ovn;
 OPEN c_get_tot_users (l_get_ovn.repository_id
                      ,p_business_group_id
                      ,p_assignment_id
                      ,p_effective_date
                      );
  FETCH c_get_tot_users INTO l_get_tot_users;
 CLOSE c_get_tot_users;

--Calling delete api for allocation.
   PQP_VEHICLE_ALLOCATIONS_API.delete_vehicle_allocation(
           p_validate                       => p_validate
          ,p_effective_date                 => ltrim(rtrim(p_effective_date))
          ,p_datetrack_mode                 =>'DELETE'
          ,p_vehicle_allocation_id          =>p_vehicle_allocation_id
          ,p_object_version_number          =>l_get_ovn.object_version_number
          ,p_effective_start_date           =>l_effective_start_date
          ,p_effective_end_date             =>l_effective_end_date
         );

 IF l_get_tot_users.usr_count = 0 THEN
  OPEN c_get_rep_ovn (l_get_ovn.repository_id
                      ,p_business_group_id
                      ,p_effective_date
                      );
   FETCH c_get_rep_ovn INTO l_get_rep_ovn;

  CLOSE c_get_rep_ovn;

--Callin delete api for vehicles.
  pqp_vehicle_repository_api.delete_vehicle
  (p_validate                         =>     p_validate
  ,p_effective_date                   =>     ltrim(rtrim(p_effective_date))
  ,p_datetrack_mode                   =>     'DELETE'
  ,p_vehicle_repository_id            =>     l_get_ovn.repository_id
  ,p_object_version_number            =>     l_get_rep_ovn.ovn
  ,p_effective_start_date             =>     l_effective_start_date
  ,p_effective_end_date               =>     l_effective_end_date
  );
 END IF;




END;

--This is not used.(obselete)
--This was introduced when the page flow was not
--based on work flow process
PROCEDURE update_transaction_itemkey (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
       result          OUT NOCOPY    VARCHAR2 )

 IS
 l_transaction_id  number;
 l_attr  varchar2(30);
 l_ignore  boolean  ;
 Begin
 l_transaction_id:= wf_engine.GetItemAttrNumber(itemtype => itemtype,
                           itemkey =>itemkey,
                           aname => 'TRANSACTION_ID',
                           ignore_notfound =>l_ignore);

    l_attr:=  wf_engine.GetActivityAttrText(itemtype => itemtype,
                         itemkey =>itemkey,
                         aname =>'PQP_APPROVAL_REQUIRED',
                         actid =>actid , --'PQP_APPROVAL_REQUIRED',
                         ignore_notfound =>l_ignore);
                     wf_engine.SetItemAttrText(itemtype => itemtype,
                          itemkey =>itemkey,
                          aname =>'HR_RUNTIME_APPROVAL_REQ_FLAG',
                          avalue =>'YES');

  UPDATE hr_api_transactions hat
  set hat.item_key = itemkey
  WHERE hat.transaction_id=l_transaction_id;

  UPDATE hr_api_transaction_steps hats
  set hats.item_key = itemkey
  WHERE hats.transaction_id=l_transaction_id;
  result    :='Y';
 end;

FUNCTION  get_vehicle_details_hgrid  (
 p_transaction_step_id   in     varchar2 ) RETURN ref_cursor IS
  csr ref_cursor;
BEGIN
  OPEN csr FOR
   SELECT Vehtrn.*,lkp.meaning vehicletype from (SELECT
   hr_transaction_api.get_number_Value
              (  p_transaction_step_id,'P_LOGIN_PERSON_ID') login_person_id
  ,hr_transaction_api.get_number_Value
              (  p_transaction_step_id, 'P_PERSON_ID' ) person_id
  ,hr_transaction_api.get_number_Value
              (p_transaction_step_id,'P_ASSIGNMENT_ID') assignment_id
  ,hr_transaction_api.get_date_Value
              (p_transaction_step_id, 'P_EFFECTIVE_DATE' ) effective_date
  ,hr_transaction_api.get_number_Value
              (p_transaction_step_id ,'P_ITEM_TYPE')  item_type
  ,hr_transaction_api.get_number_Value
              (p_transaction_step_id, 'P_item_key') item_key
  ,hr_transaction_api.get_number_Value
              (p_transaction_step_id, 'P_ACTIVITY_ID' ) activity_id
  ,hr_transaction_api.get_varchar2_Value
              (p_transaction_step_id,'P_REGISTRATION_NUMBER') registration_number
  ,hr_transaction_api.get_varchar2_Value
              (p_transaction_step_id, 'P_VEHICLE_OWNERSHIP') vehicle_ownership
  ,hr_transaction_api.get_varchar2_Value
              (p_transaction_step_id, 'P_VEHICLE_TYPE' ) vehicle_type
  ,hr_transaction_api.get_varchar2_Value
              (p_transaction_step_id, 'P_VEHICLE_ID_NUMBER') vehicle_id_number
  ,hr_transaction_api.get_number_Value
              (p_transaction_step_id, 'P_BUSINESS_GROUP_ID') business_group_id
  ,hr_transaction_api.get_varchar2_Value
              (p_transaction_step_id, 'P_MAKE') make
  ,hr_transaction_api.get_number_Value
              (p_transaction_step_id, 'P_ENGINE_CAPACITY_IN_CC') engine_capacity_in_cc
  , hr_transaction_api.get_number_Value
              (p_transaction_step_id, 'P_MODEL_YEAR' ) model_year
  ,hr_transaction_api.get_varchar2_Value
              (p_transaction_step_id, 'P_INSURANCE_NUMBER' ) insurance_number
  ,hr_transaction_api.get_date_Value
              (p_transaction_step_id, 'P_INSURANCE_EXPIRY_DATE') insurance_expiry_date
  ,hr_transaction_api.get_varchar2_Value
              (p_transaction_step_id, 'P_MODEL' ) model
  ,hr_transaction_api.get_number_value
                  (p_transaction_step_id, 'P_VEHICLE_ALLOCATION_ID') vehicle_allocation_id
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_VEHICLE_REPOSITORY_ID' ) vehicle_repository_id
   FROM DUAL)  Vehtrn
               ,hr_lookups lkp
          WHERE vehtrn.vehicle_type=lkp.lookup_code
            AND lkp.lookup_type='PQP_VEHICLE_TYPE' ;

  RETURN csr;
END get_vehicle_details_hgrid;

--
--
---This function that get the vehicle user details
---when the back button is clicked.
---The data that are inserted into transaction table is
---again queried to populate all the entered fields.
--Here user of the vehicle could be one or many.
FUNCTION get_vehicle_usr_details
    (p_transaction_step_id   in     VARCHAR2 )
RETURN ref_cursor IS
 csr ref_cursor;


BEGIN
 OPEN csr FOR
 SELECT DISTINCT  (a.number_value) person_usr_id
       , b.number_value assignment_usr_id
       , c.varchar2_value usr_type
    FROM hr_api_transaction_steps s,
         hr_api_transaction_values a,
         hr_api_transaction_steps s1,
         hr_api_transaction_values b,
         hr_api_transaction_steps s2,
         hr_api_transaction_values c
   WHERE s.transaction_step_id = a.transaction_step_id
     AND s1.transaction_step_id = b.transaction_step_id
     AND s2.transaction_step_id = c.transaction_step_id
     AND s.transaction_step_id = p_transaction_step_id
     AND s.api_name = 'PQP_SS_VEHICLE_TRANSACTIONS.PROCESS_API'
     AND a.name like 'P_PERSON_USR_ID%'
     AND s1.transaction_step_id = p_transaction_step_id
     AND s1.api_name = 'PQP_SS_VEHICLE_TRANSACTIONS.PROCESS_API'
     AND b.name like 'P_ASSIGNMENT_USR_ID%'
     AND s2.transaction_step_id = p_transaction_step_id
     AND s2.api_name = 'PQP_SS_VEHICLE_TRANSACTIONS.PROCESS_API'
     AND c.name like 'P_USER_TYPE%'
     AND substr(a.name,-1) =  substr(b.name,-1)
     AND substr(a.name,-1) =  substr(c.name,-1);

RETURN csr;
END;

--This Function gets all other details related to vehicles
--that are there in the transaction table
--when back button is clicked.

FUNCTION  get_vehicle_details  (
 p_transaction_step_id   in     varchar2 ) RETURN ref_cursor IS
  csr ref_cursor;
BEGIN
  OPEN csr FOR
  SELECT
   hr_transaction_api.get_number_Value
                  (p_transaction_step_id,'P_LOGIN_PERSON_ID') login_person_id
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_PERSON_ID' ) person_id
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id,'P_ASSIGNMENT_ID') assignment_id
  ,hr_transaction_api.get_date_Value
                  (p_transaction_step_id, 'P_EFFECTIVE_DATE' ) effective_date
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id ,'P_ITEM_TYPE')  item_type
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_item_key') item_key
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_ACTIVITY_ID' ) activity_id
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id,'P_REGISTRATION_NUMBER') registration_number
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_VEHICLE_OWNERSHIP') vehicle_ownership
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_VEHICLE_TYPE' ) vehicle_type
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_VEHICLE_ID_NUMBER') vehicle_id_number
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_BUSINESS_GROUP_ID') business_group_id
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_MAKE') make
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_ENGINE_CAPACITY_IN_CC') engine_capacity_in_cc
  , hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_MODEL_YEAR' ) model_year
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_INSURANCE_NUMBER' ) insurance_number
  ,hr_transaction_api.get_date_Value
                  (p_transaction_step_id, 'P_INSURANCE_EXPIRY_DATE') insurance_expiry_date
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_MODEL' ) model
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_FUEL_TYPE' ) fuel_type
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_VEHICLE_REPOSITORY_ID' ) vehicle_repository_id
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_OBJECT_VERSION_NUMBER') object_version_number
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_CURRENCY_CODE') currency_code
  ,hr_transaction_api.get_date_Value
                  (p_transaction_step_id, 'P_INITIAL_REGISTRATION') initial_registration
  ,hr_transaction_api.get_date_Value
                  (p_transaction_step_id, 'P_LAST_REGISTRATION_RENEW_DATE' )
                   last_registration_renew_date
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_FISCAL_RATINGS' ) fiscal_ratings
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_SHARED_VEHICLE' ) shared_vehicle
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_COLOR' ) color
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_SEATING_CAPACITY' ) seating_capacity
  ,hr_transaction_api.get_number_Value
                  (p_transaction_step_id, 'P_WEIGHT' ) weight
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_WEIGHT_UOM' ) weight_uom
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_TAXATION_METHOD' ) taxation_method
  ,hr_transaction_api.get_varchar2_Value
                  (p_transaction_step_id, 'P_COMMENTS' ) comments
   ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE_CATEGORY')
                  vre_attribute_category
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE1') vre_attribute1
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE2') vre_attribute2
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE3') vre_attribute3
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE4') vre_attribute4
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE5') vre_attribute5
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE6') vre_attribute6
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE7') vre_attribute7
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE8') vre_attribute8
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE9') vre_attribute9
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE10') vre_attribute10
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE11')vre_attribute11
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE12') vre_attribute12
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE13') vre_attribute13
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE14') vre_attribute14
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE15') vre_attribute15
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id,  'P_VRE_ATTRIBUTE16') vre_attribute16
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE17') vre_attribute17
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE18') vre_attribute18
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE19') vre_attribute19
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_ATTRIBUTE20') vre_attribute20
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION_CATEGORY')
                   vre_information_category
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION1') vre_information1
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION2') vre_information2
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION3') vre_information3
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION4') vre_information4
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION5') vre_information5
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION6') vre_information6
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION7') vre_information7
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION8') vre_information8
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION9') vre_information9
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION10') vre_information10
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION11') vre_information11
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION12') vre_information12
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION13') vre_information13
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION14') vre_information14
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION15') vre_information15
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION16') vre_information16
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION17') vre_information17
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION18') vre_information18
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION19') vre_information19
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VRE_INFORMATION20') vre_information20
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_ACROSS_ASSIGNMENTS') across_assignments
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_USAGE_TYPE') usage_type
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_DEFAULT_VEHICLE') default_vehicle
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_FUEL_CARD') fuel_card
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_FUEL_CARD_NUMBER') fuel_card_number
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_FUEL_BENEFIT') fuel_benefit
  ,hr_transaction_api.get_number_value
                  (p_transaction_step_id, 'P_VEHICLE_ALLOCATION_ID') vehicle_allocation_id
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE_CATEGORY')
                  val_attribute_category
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE1') val_attribute1
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE2') val_attribute2
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE3') val_attribute3
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE4') val_attribute4
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE5') val_attribute5
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE6') val_attribute6
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE7') val_attribute7
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE8') val_attribute8
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE9') val_attribute9
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE10') val_attribute10
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE11') val_attribute11
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE12') val_attribute12
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE13') val_attribute13
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE14') val_attribute14
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE15') val_attribute15
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE16') val_attribute16
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE17') val_attribute17
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE18') val_attribute18
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE19') val_attribute19
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_ATTRIBUTE20') val_attribute20
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION_CATEGORY')
                   val_information_category
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION1') val_information1
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION2') val_information2
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION3') val_information3
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION4') val_information4
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION5') val_information5
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION6') val_information6
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION7') val_information7
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION8') val_information8
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION9') val_information9
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION10') val_information10
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION11') val_information11
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION12') val_information12
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION13') val_information13
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION14') val_information14
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION15') val_information15
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION16') val_information16
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION17') val_information17
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION18') val_information18
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION19') val_information19
  ,hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id, 'P_VAL_INFORMATION20') val_information20
  FROM DUAL;

  RETURN csr;
END get_vehicle_details;





--
--

--Updates the vehicle allocation when the transaction mode update
PROCEDURE update_vehicle_allocations
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_registration_number          in     varchar2
  ,p_vehicle_repository_id        in     number
  ,p_across_assignments           in     varchar2
  ,p_usage_type                   in     varchar2
  ,p_default_vehicle              in     varchar2
  ,p_fuel_card                    in     varchar2
  ,p_fuel_card_number             in     varchar2
  ,p_insurance_number             in     varchar2
  ,p_insurance_expiry_date        in     date
  ,p_val_attribute_category       in     varchar2
  ,p_val_attribute1               in     varchar2
  ,p_val_attribute2               in     varchar2
  ,p_val_attribute3               in     varchar2
  ,p_val_attribute4               in     varchar2
  ,p_val_attribute5               in     varchar2
  ,p_val_attribute6               in     varchar2
  ,p_val_attribute7               in     varchar2
  ,p_val_attribute8               in     varchar2
  ,p_val_attribute9               in     varchar2
  ,p_val_attribute10              in     varchar2
  ,p_val_attribute11              in     varchar2
  ,p_val_attribute12              in     varchar2
  ,p_val_attribute13              in     varchar2
  ,p_val_attribute14              in     varchar2
  ,p_val_attribute15              in     varchar2
  ,p_val_attribute16              in     varchar2
  ,p_val_attribute17              in     varchar2
  ,p_val_attribute18              in     varchar2
  ,p_val_attribute19              in     varchar2
  ,p_val_attribute20              in     varchar2
  ,p_val_information_category     in     varchar2
  ,p_val_information1             in     varchar2
  ,p_val_information2             in     varchar2
  ,p_val_information3             in     varchar2
  ,p_val_information4             in     varchar2
  ,p_val_information5             in     varchar2
  ,p_val_information6             in     varchar2
  ,p_val_information7             in     varchar2
  ,p_val_information8             in     varchar2
  ,p_val_information9             in     varchar2
  ,p_val_information10            in     varchar2
  ,p_val_information11            in     varchar2
  ,p_val_information12            in     varchar2
  ,p_val_information13            in     varchar2
  ,p_val_information14            in     varchar2
  ,p_val_information15            in     varchar2
  ,p_val_information16            in     varchar2
  ,p_val_information17            in     varchar2
  ,p_val_information18            in     varchar2
  ,p_val_information19            in     varchar2
  ,p_val_information20            in     varchar2
  ,p_fuel_benefit                 in     varchar2
  ,p_user_info                    in     t_user_info
  ,p_error_message                in     varchar2
  )
IS


lc_object_version_number  NUMBER;
l_assignment_id          per_all_assignments_f.assignment_id%TYPE;
TYPE r_assignment_rec  IS RECORD
         (assignment_id per_all_assignments_f.assignment_id%TYPE,
          allocation_id pqp_vehicle_allocations_f.vehicle_allocation_id%TYPE
          ,user_type      VARCHAR2(10));

TYPE t_assignment_tab IS TABLE OF r_assignment_rec
          INDEX BY BINARY_INTEGER;

l_assignment_tab     t_assignment_tab;
l_new_assignment_tab t_assignment_tab;
l_del_assignment_tab t_assignment_tab;
l_user_info          t_assignment_tab;

CURSOR c_get_alloc_info (cp_registration_number VARCHAR2
                        ,cp_business_group_id   NUMBER
                        ,cp_effective_date      DATE
                        )
IS
SELECT pva.assignment_id ,
       pva.vehicle_allocation_id allocation_id
 FROM pqp_vehicle_allocations_f pva
     ,pqp_vehicle_repository_f pvr
WHERE pvr.registration_number = cp_registration_number
  AND pvr.business_group_id = cp_business_group_id
  AND pvr.business_group_id=pva.business_group_id
  AND pvr.vehicle_repository_id=pva.vehicle_repository_id
  AND cp_effective_date BETWEEN pvr.effective_start_date
                            AND pvr.effective_end_date
  AND cp_effective_date BETWEEN pva.effective_start_date
                             AND pva.effective_end_date;


CURSOR c_get_object_version_number (
                                   cp_vehicle_allocation_id NUMBER
                                  ,cp_assignment_id         NUMBER
                                  ,cp_business_group_id     NUMBER
                                  ,cp_effective_date        DATE
                                  )
IS
SELECT pva.object_version_number
  FROM pqp_vehicle_allocations_f pva
 WHERE pva.vehicle_allocation_id =cp_vehicle_allocation_id
   AND pva.assignment_id = cp_assignment_id
   AND pva.business_group_id = cp_business_group_id
   AND cp_effective_date BETWEEN pva.effective_start_date
                             AND pva.effective_end_date;


CURSOR c_get_repository (cp_registration_number VARCHAR2
                        ,cp_business_group_id   NUMBER
                        ,cp_effective_date      DATE
                        )
IS
SELECT pvr.vehicle_repository_id
  FROM pqp_vehicle_repository_f pvr
 WHERE pvr.registration_number = cp_registration_number
   AND pvr.business_group_id = cp_business_group_id
   AND cp_effective_date BETWEEN pvr.effective_start_date
                            AND pvr.effective_end_date;

l_object_version_number     NUMBER;
l_datetrack_mode            VARCHAr2(30);
l_get_alloc_info            c_get_alloc_info%ROWTYPE;
l_count                     NUMBER :=0;
l_assignment_present        VARCHAR2(1) :=NULL;
l_assignment_add            VARCHAr2(1) :=NULL;
l_new_assignment_id         per_all_assignments_f.assignment_id%TYPE;
l_correction                NUMBER;
l_update                    NUMBER;
l_update_override           NUMBER;
l_update_change_insert      NUMBER;
l_effective_start_date      DATE;
l_effective_end_date        DATE;
l_vehicle_repository_id     pqp_vehicle_repository_f.vehicle_repository_id%TYPE;
l_vehicle_allocation_id     pqp_vehicle_allocations_f.vehicle_allocation_id%TYPE;
l_cnt                       NUMBER :=0;


BEGIN

--Get all the users for that registration number
--from the allocation table.
--The reason for the logic is to compare
--incoming useri id where it could be
--same or less or even more than what
--is present in the allocation table.
 l_count :=0;

 OPEN c_get_alloc_info (p_registration_number
                       ,p_business_group_id
                       ,p_effective_date
                       );
  LOOP
   FETCH c_get_alloc_info INTO l_get_alloc_info;
   EXIT WHEN c_get_alloc_info%NOTFOUND;

   l_assignment_tab(l_count+1).assignment_id :=l_get_alloc_info.assignment_id;
   l_assignment_tab(l_count+1).allocation_id :=l_get_alloc_info.allocation_id;

   l_count:=l_count+1;
  END LOOP;
 CLOSE c_get_alloc_info;

--compare the assignments with the incoming table parameter for
--assignments and check for reduced assignments.
--This check is for the users who are no longer using the vehicle
 FOR i in 1..l_assignment_tab.count
  LOOP
   FOR j in 1..p_user_info.count
   LOOP

     --check if the already allocated assignments is present in the param
     --table.
    IF l_assignment_tab(i).assignment_id = p_user_info(j).assignment_id THEN
     l_assignment_present :='Y';

    END IF;
   END LOOP;
   --Add the users into the delete table for further processing
   IF   l_assignment_present is NULL OR l_assignment_present <>'Y' THEN

    l_del_assignment_tab(l_cnt+1).assignment_id:=
                             l_assignment_tab(i).assignment_id;
    l_del_assignment_tab(l_cnt+1).allocation_id:=
                             l_assignment_tab(i).allocation_id;

     l_cnt :=l_cnt+1;
   END IF;
   l_assignment_present:='N';
  END LOOP;




  l_count:=0;
--Check if there are any new asignments in the param table.
--There could be additional user and this information will be
--stored in the other plsql table for further processing
  FOR i in 1..p_user_info.count
   LOOP
   FOR j in 1..l_assignment_tab.count
    LOOP
     IF p_user_info(i).assignment_id = l_assignment_tab(j).assignment_id THEN
      l_assignment_add := 'N' ;
      l_user_info(l_count+1).assignment_id
                         := p_user_info(i).assignment_id;
      l_user_info(l_count+1).allocation_id
                         := l_assignment_tab(j).allocation_id;
      l_user_info(l_count+1).user_type :=p_user_info(i).user_type;
      l_count:=l_count+1;

     ENd IF;
    END LOOP;
    IF l_assignment_add IS NULL OR l_assignment_add <> 'N' THEN
     l_new_assignment_tab(l_new_assignment_tab.count+1).assignment_id
                                      := p_user_info(i).assignment_id;
    END IF;
     l_assignment_add := 'Y' ;
   END LOOP;

--Create allocation for new assignments

 IF (l_new_assignment_tab.count) > 0 THEN
/*  OPEN c_get_repository (p_registration_number
                           ,p_business_group_id
                           ,p_effective_date
                           );
   FETCH c_get_repository INTO l_vehicle_repository_id;

  CLOSE c_get_repository;*/

  FOR i in 1..(l_new_assignment_tab.count)
  LOOP
   pqp_vehicle_allocations_api.create_vehicle_allocation
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_assignment_id                => l_new_assignment_tab(i).assignment_id
    ,p_business_group_id            => p_business_group_id
    ,p_vehicle_repository_id        => p_vehicle_repository_id
    ,p_across_assignments           => p_across_assignments
    ,p_usage_type                   => p_usage_type
    ,p_default_vehicle              => p_default_vehicle
    ,p_fuel_card                    => p_fuel_card
    ,p_fuel_card_number             => p_fuel_card_number
    ,p_insurance_number             => p_insurance_number
    ,p_insurance_expiry_date        => p_insurance_expiry_date
    ,p_val_attribute_category       => p_val_attribute_category
    ,p_val_attribute1               => p_val_attribute1
    ,p_val_attribute2               => p_val_attribute2
    ,p_val_attribute3               => p_val_attribute3
    ,p_val_attribute4               => p_val_attribute4
    ,p_val_attribute5               => p_val_attribute5
    ,p_val_attribute6               => p_val_attribute6
    ,p_val_attribute7               => p_val_attribute7
    ,p_val_attribute8               => p_val_attribute8
    ,p_val_attribute9               => p_val_attribute9
    ,p_val_attribute10              => p_val_attribute10
    ,p_val_attribute11              => p_val_attribute11
    ,p_val_attribute12              => p_val_attribute12
    ,p_val_attribute13              => p_val_attribute13
    ,p_val_attribute14              => p_val_attribute14
    ,p_val_attribute15              => p_val_attribute15
    ,p_val_attribute16              => p_val_attribute16
    ,p_val_attribute17              => p_val_attribute17
    ,p_val_attribute18              => p_val_attribute18
    ,p_val_attribute19              => p_val_attribute19
    ,p_val_attribute20              => p_val_attribute20
    ,p_val_information_category     => p_val_information_category
    ,p_val_information1             => p_val_information1
    ,p_val_information2             => p_val_information2
    ,p_val_information3             => p_val_information3
    ,p_val_information4             => p_val_information4
    ,p_val_information5             => p_val_information5
    ,p_val_information6             => p_val_information6
    ,p_val_information7             => p_val_information7
    ,p_val_information8             => p_val_information8
    ,p_val_information9             => p_val_information9
    ,p_val_information10            => p_val_information10
    ,p_val_information11            => p_val_information11
    ,p_val_information12            => p_val_information12
    ,p_val_information13            => p_val_information13
    ,p_val_information14            => p_val_information14
    ,p_val_information15            => p_val_information15
    ,p_val_information16            => p_val_information16
    ,p_val_information17            => p_val_information17
    ,p_val_information18            => p_val_information18
    ,p_val_information19            => p_val_information19
    ,p_val_information20            => p_val_information20
    ,p_fuel_benefit                 => p_fuel_benefit
    ,p_vehicle_allocation_id        => l_vehicle_allocation_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );


  END LOOP;
 END IF;

--End date the allocation for those assignments
--that are no longer using the vehicle.
 IF  (l_del_assignment_tab.count) > 0 THEN
  FOR i in 1..(l_del_assignment_tab.count)
  LOOP
   OPEN c_get_object_version_number
                           (
                            l_del_assignment_tab(i).allocation_id
                           ,l_del_assignment_tab(i).assignment_id
                           ,p_business_group_id
                           ,p_effective_date
                            );
   FETCH c_get_object_version_number INTO lc_object_version_number;
   CLOSE c_get_object_version_number;

   pqp_vehicle_allocations_api.delete_vehicle_allocation
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => 'DELETE'
    ,p_vehicle_allocation_id        => l_del_assignment_tab(i).allocation_id
    ,p_object_version_number        => lc_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  END LOOP;
 END IF;



--Update rest of the assignments for any change in
--allocations.

 FOR i in 1..l_user_info.count
 LOOP
    --get object_version_number
  IF l_user_info(i).user_type <>'OA' THEN
   OPEN c_get_object_version_number
                           (
                            l_user_info(i).allocation_id
                           ,l_user_info(i).assignment_id
                           ,p_business_group_id
                           ,p_effective_date
                            );
   FETCH c_get_object_version_number INTO lc_object_version_number;
   CLOSE c_get_object_version_number;
---get_date track mode
   pqp_get_date_mode.find_dt_upd_modes
   (p_effective_date         =>p_effective_date
   ,p_base_table_name        =>'PQP_VEHICLE_ALLOCATIONS_F'
   ,p_base_key_column        =>'VEHICLE_ALLOCATION_ID'
   ,p_base_key_value         =>l_user_info(i).allocation_id
   ,p_correction             =>l_correction
   ,p_update                 =>l_update
   ,p_update_override        =>l_update_override
   ,p_update_change_insert   =>l_update_change_insert
   );

   IF l_correction = 1 THEN
    l_datetrack_mode :='CORRECTION' ;
   ELSIF l_update = 1 THEN
    l_datetrack_mode :='UPDATE' ;
   END IF;


--Call update api for allocation.
  pqp_vehicle_allocations_api.update_vehicle_allocation
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => l_datetrack_mode
    ,p_vehicle_allocation_id        => l_user_info(i).allocation_id
    ,p_object_version_number        => lc_object_version_number
    ,p_assignment_id                => l_user_info(i).assignment_id
    ,p_business_group_id            => p_business_group_id
    ,p_across_assignments           => p_across_assignments
    ,p_usage_type                   => p_usage_type
    ,p_default_vehicle              => p_default_vehicle
    ,p_fuel_card                    => p_fuel_card
    ,p_fuel_card_number             => p_fuel_card_number
    ,p_insurance_number             => p_insurance_number
    ,p_insurance_expiry_date        => p_insurance_expiry_date
    ,p_val_attribute_category       => p_val_attribute_category
    ,p_val_attribute1               => p_val_attribute1
    ,p_val_attribute2               => p_val_attribute2
    ,p_val_attribute3               => p_val_attribute3
    ,p_val_attribute4               => p_val_attribute4
    ,p_val_attribute5               => p_val_attribute5
    ,p_val_attribute6               => p_val_attribute6
    ,p_val_attribute7               => p_val_attribute7
    ,p_val_attribute8               => p_val_attribute8
    ,p_val_attribute9               => p_val_attribute9
    ,p_val_attribute10              => p_val_attribute10
    ,p_val_attribute11              => p_val_attribute11
    ,p_val_attribute12              => p_val_attribute12
    ,p_val_attribute13              => p_val_attribute13
    ,p_val_attribute14              => p_val_attribute14
    ,p_val_attribute15              => p_val_attribute15
    ,p_val_attribute16              => p_val_attribute16
    ,p_val_attribute17              => p_val_attribute17
    ,p_val_attribute18              => p_val_attribute18
    ,p_val_attribute19              => p_val_attribute19
    ,p_val_attribute20              => p_val_attribute20
    ,p_val_information1             => p_val_information1
    ,p_val_information2             => p_val_information2
    ,p_val_information3             => p_val_information3
    ,p_val_information4             => p_val_information4
    ,p_val_information5             => p_val_information5
    ,p_val_information6             => p_val_information6
    ,p_val_information7             => p_val_information7
    ,p_val_information8             => p_val_information8
    ,p_val_information9             => p_val_information9
    ,p_val_information10            => p_val_information10
    ,p_val_information11            => p_val_information11
    ,p_val_information12            => p_val_information12
    ,p_val_information13            => p_val_information13
    ,p_val_information14            => p_val_information14
    ,p_val_information15            => p_val_information15
    ,p_val_information16            => p_val_information16
    ,p_val_information17            => p_val_information17
    ,p_val_information18            => p_val_information18
    ,p_val_information19            => p_val_information19
    ,p_val_information20            => p_val_information20
    ,p_fuel_benefit                 => p_fuel_benefit
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
   END IF;
  END LOOP;
END update_vehicle_allocations;





--This procedure is called to create vehicle information in both
--allocation and repository.
PROCEDURE create_vehicle_details
  (
   p_validate                     in     boolean default false
  ,p_effective_date               in     date
  ,p_registration_number          in     varchar2
  ,p_vehicle_type                 in     varchar2
  ,p_vehicle_id_number            in     varchar2
  ,p_business_group_id            in     number
  ,p_make                         in     varchar2
  ,p_engine_capacity_in_cc        in     number
  ,p_fuel_type                    in     varchar2
  ,p_currency_code                in     varchar2
  ,p_model                        in     varchar2
  ,p_initial_registration         in     date
  ,p_last_registration_renew_date in     date
  ,p_fiscal_ratings               in     number
  ,p_vehicle_ownership            in     varchar2
  ,p_shared_vehicle               in     varchar2
  ,p_color                        in     varchar2
  ,p_seating_capacity             in     number
  ,p_weight                       in     number
  ,p_weight_uom                   in     varchar2
  ,p_model_year                   in     number
  ,p_insurance_number             in     varchar2
  ,p_insurance_expiry_date        in     date
  ,p_taxation_method              in     varchar2
  ,p_comments                     in     varchar2
  ,p_vre_attribute_category       in     varchar2
  ,p_vre_attribute1               in     varchar2
  ,p_vre_attribute2               in     varchar2
  ,p_vre_attribute3               in     varchar2
  ,p_vre_attribute4               in     varchar2
  ,p_vre_attribute5               in     varchar2
  ,p_vre_attribute6               in     varchar2
  ,p_vre_attribute7               in     varchar2
  ,p_vre_attribute8               in     varchar2
  ,p_vre_attribute9               in     varchar2
  ,p_vre_attribute10              in     varchar2
  ,p_vre_attribute11              in     varchar2
  ,p_vre_attribute12              in     varchar2
  ,p_vre_attribute13              in     varchar2
  ,p_vre_attribute14              in     varchar2
  ,p_vre_attribute15              in     varchar2
  ,p_vre_attribute16              in     varchar2
  ,p_vre_attribute17              in     varchar2
  ,p_vre_attribute18              in     varchar2
  ,p_vre_attribute19              in     varchar2
  ,p_vre_attribute20              in     varchar2
  ,p_vre_information_category     in     varchar2
  ,p_vre_information1             in     varchar2
  ,p_vre_information2             in     varchar2
  ,p_vre_information3             in     varchar2
  ,p_vre_information4             in     varchar2
  ,p_vre_information5             in     varchar2
  ,p_vre_information6             in     varchar2
  ,p_vre_information7             in     varchar2
  ,p_vre_information8             in     varchar2
  ,p_vre_information9             in     varchar2
  ,p_vre_information10            in     varchar2
  ,p_vre_information11            in     varchar2
  ,p_vre_information12            in     varchar2
  ,p_vre_information13            in     varchar2
  ,p_vre_information14            in     varchar2
  ,p_vre_information15            in     varchar2
  ,p_vre_information16            in     varchar2
  ,p_vre_information17            in     varchar2
  ,p_vre_information18            in     varchar2
  ,p_vre_information19            in     varchar2
  ,p_vre_information20            in     varchar2
  ,p_across_assignments           in     varchar2
  ,p_usage_type                   in     varchar2
  ,p_default_vehicle              in     varchar2
  ,p_fuel_card                    in     varchar2
  ,p_fuel_card_number             in     varchar2
  ,p_val_attribute_category       in     varchar2
  ,p_val_attribute1               in     varchar2
  ,p_val_attribute2               in     varchar2
  ,p_val_attribute3               in     varchar2
  ,p_val_attribute4               in     varchar2
  ,p_val_attribute5               in     varchar2
  ,p_val_attribute6               in     varchar2
  ,p_val_attribute7               in     varchar2
  ,p_val_attribute8               in     varchar2
  ,p_val_attribute9               in     varchar2
  ,p_val_attribute10              in     varchar2
  ,p_val_attribute11              in     varchar2
  ,p_val_attribute12              in     varchar2
  ,p_val_attribute13              in     varchar2
  ,p_val_attribute14              in     varchar2
  ,p_val_attribute15              in     varchar2
  ,p_val_attribute16              in     varchar2
  ,p_val_attribute17              in     varchar2
  ,p_val_attribute18              in     varchar2
  ,p_val_attribute19              in     varchar2
  ,p_val_attribute20              in     varchar2
  ,p_val_information_category     in     varchar2
  ,p_val_information1             in     varchar2
  ,p_val_information2             in     varchar2
  ,p_val_information3             in     varchar2
  ,p_val_information4             in     varchar2
  ,p_val_information5             in     varchar2
  ,p_val_information6             in     varchar2
  ,p_val_information7             in     varchar2
  ,p_val_information8             in     varchar2
  ,p_val_information9             in     varchar2
  ,p_val_information10            in     varchar2
  ,p_val_information11            in     varchar2
  ,p_val_information12            in     varchar2
  ,p_val_information13            in     varchar2
  ,p_val_information14            in     varchar2
  ,p_val_information15            in     varchar2
  ,p_val_information16            in     varchar2
  ,p_val_information17            in     varchar2
  ,p_val_information18            in     varchar2
  ,p_val_information19            in     varchar2
  ,p_val_information20            in     varchar2
  ,p_fuel_benefit                 in     varchar2
  ,p_user_info                    in     t_user_info
  ,p_vehicle_repository_id        in     number
  ,p_vehicle_allocation_id        in     number
  ,p_object_version_number        in     number
  ,p_error_message                OUT    nocopy varchar2
  ,p_error_status                 OUT    nocopy varchar2
   )
IS


CURSOR c_get_user_assignments (cp_person_id NUMBER
                              ,cp_business_group_id NUMBER
                              ,cp_effective_date DATE
                              )
IS
SELECT paa.assignment_id
 FROM per_all_assignments_f paa
WHERE paa.person_id = cp_person_id
  AND paa.primary_flag ='Y'
  AND paa.business_group_id = cp_business_group_id
  AND cp_effective_date BETWEEN paa.effective_start_date
                            AND paa.effective_end_date;

CURSOR c_get_main_user_assignments
                           (cp_person_id NUMBER
                           ,cp_assignment_id NUMBER
                           ,cp_business_group_id NUMBER
                           ,cp_effective_date DATE
                           )
IS
SELECT paa.assignment_id
 FROM per_all_assignments_f paa
WHERE paa.person_id = cp_person_id
  AND paa.assignment_id <> cp_assignment_id
  AND paa.business_group_id = cp_business_group_id
  AND cp_effective_date BETWEEN paa.effective_start_date
                            AND paa.effective_end_date;

 CURSOR c_fiscal_uom IS
   SELECT hrl.lookup_code
     FROM hr_lookups hrl
    WHERE lookup_type = 'PQP_FISCAL_RATINGS_UOM'
      AND enabled_flag    = 'Y';

CURSOR c_get_repository_id (cp_registration_number VARCHAR2
                           ,cp_business_group_id  NUMBER
                           ,cp_effective_date  DATE
                           )
IS
SELECT pvr.vehicle_repository_id
      ,pvr.object_version_number
      ,pvr.shared_vehicle
 FROM pqp_vehicle_repository_f pvr
WHERE pvr.registration_number = cp_registration_number
  AND pvr.business_group_id = cp_business_group_id
  AND cp_effective_date BETWEEN pvr.effective_start_date
                            AND pvr.effective_end_date;


l_vehicle_repository_id    pqp_vehicle_repository_f.vehicle_repository_id%TYPE;
l_object_version_number1   NUMBER;
l_object_version_number    NUMBER;
l_user_info                t_user_info;
l_vehicle_allocation_id    pqp_vehicle_allocations_f.vehicle_allocation_id%TYPE;
l_get_repository_id        c_get_repository_id%ROWTYPE;
l_lookup_code              hr_lookups.lookup_code%TYPE;
l_leg_code                 pqp_configuration_values.legislation_code%TYPE;
l_assignment_id            per_all_assignments_f.assignment_id%TYPE;
l_correction               NUMBER;
l_update                   NUMBER;
l_update_override          NUMBER;
l_update_change_insert     NUMBER;
l_datetrack_mode           VARCHAR2(30);
l_cnt                      NUMBER :=0;
l_effective_start_date     DATE;
l_effective_end_date       DATE;
l_cnt1                     NUMBER;
l_chk                      NUMBER:=0;
l_dt_adj                   number:=0;
e_exist_other_asg          EXCEPTION;
BEGIN

 l_user_info(1).person_id     := p_user_info(1).person_id;
 l_user_info(1).assignment_id := p_user_info(1).assignment_id;
 l_user_info(1).user_type     := p_user_info(1).user_type;

 --Check if the main user has chosen to share across his own
 --assignments, get all assignemnts for that person
 -- and store it in a plsql table.
 IF p_across_assignments = 'Y' THEN
  l_cnt1:=l_user_info.count;
  OPEN c_get_main_user_assignments (
                                  p_user_info(1).person_id
                                 ,p_user_info(1).assignment_id
                                 ,p_business_group_id
                                 ,p_effective_date
                                  );
  LOOP
   FETCH c_get_main_user_assignments INTO l_assignment_id;
   EXIT WHEN c_get_main_user_assignments%NOTFOUND;
    l_user_info(l_cnt1+1).person_id := p_user_info(1).person_id;
    l_user_info(l_cnt1+1).assignment_id
                                := l_assignment_id;
     --'SA' Stands for secondary assignment
    l_user_info(l_cnt1+1).user_type := 'SA';
    l_cnt1:=l_cnt1+1;
  END LOOP;
  CLOSE c_get_main_user_assignments;
 END IF;

 BEGIN

  IF p_shared_vehicle='Y' AND p_user_info.count>1  THEN
   l_cnt:=l_user_info.count;

   FOR k in 2..(p_user_info.count)
   LOOP
    l_cnt:=l_cnt+1;
    l_user_info(l_cnt).person_id := p_user_info(k).person_id;
    l_user_info(l_cnt).assignment_id
                                 := p_user_info(k).assignment_id;
    --'OA' Stands for other employee's assignments
    l_user_info(l_cnt).user_type := 'OA';

   END LOOP;
  END IF; --shared vehicle;
  EXCEPTION
   WHEN hr_utility.hr_error THEN
  	hr_utility.raise_error;
   WHEN OTHERS THEN
        RAISE;  -- Raise error here relevant to the new tech stack.
 END;
---check if other users flag is set to yes, if set to yes
--then  get the assignments for all their person ids

--Call create apis for both repository and allocations
--and based on number of users and whether the allocation
--is for all the assignments of that person, the api is
--called in the loop.

--Call Create vehicle repository  api

 IF p_vehicle_repository_id is NULL THEN
  Begin

   --Getting the legislationId for business groupId
   l_leg_code :=
                  pqp_vre_bus.get_legislation_code(p_business_group_id);
   --setting the lg context
   hr_api.set_legislation_context(l_leg_code);

   OPEN c_fiscal_uom;
   FETCH c_fiscal_uom INTO  l_lookup_code;
   CLOSE c_fiscal_uom;
  EXCEPTION
   WHEN no_data_found THEN
    l_lookup_code := NULL;
  End ;
  pqp_vehicle_repository_api.create_vehicle
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_registration_number          => p_registration_number
    ,p_vehicle_type                 => p_vehicle_type
    ,p_vehicle_id_number            => p_vehicle_id_number
    ,p_business_group_id            => p_business_group_id
    ,p_make                         => p_make
    ,p_engine_capacity_in_cc        => p_engine_capacity_in_cc
    ,p_fuel_type                    => p_fuel_type
    ,p_currency_code                => p_currency_code
    ,p_vehicle_status               => 'A'
    ,p_model                        => p_model
    ,p_initial_registration         => p_initial_registration
    ,p_last_registration_renew_date => p_last_registration_renew_date
    ,p_fiscal_ratings               => p_fiscal_ratings
    ,p_fiscal_ratings_uom           => l_lookup_code --p_fiscal_ratings_uom
    ,p_vehicle_ownership            => p_vehicle_ownership
    ,p_shared_vehicle               => p_shared_vehicle
    ,p_taxation_method              => p_taxation_method
    ,p_color                        => p_color
    ,p_seating_capacity             => p_seating_capacity
    ,p_weight                       => p_weight
    ,p_weight_uom                   => p_weight_uom
    ,p_model_year                   => p_model_year
    ,p_insurance_number             => p_insurance_number
    ,p_insurance_expiry_date        => p_insurance_expiry_date
    ,p_comments                     => p_comments
    ,p_vre_attribute_category       => p_vre_attribute_category
    ,p_vre_attribute1               => p_vre_attribute1
    ,p_vre_attribute2               => p_vre_attribute2
    ,p_vre_attribute3               => p_vre_attribute3
    ,p_vre_attribute4               => p_vre_attribute4
    ,p_vre_attribute5               => p_vre_attribute5
    ,p_vre_attribute6               => p_vre_attribute6
    ,p_vre_attribute7               => p_vre_attribute7
    ,p_vre_attribute8               => p_vre_attribute8
    ,p_vre_attribute9               => p_vre_attribute9
    ,p_vre_attribute10              => p_vre_attribute10
    ,p_vre_attribute11              => p_vre_attribute11
    ,p_vre_attribute12              => p_vre_attribute12
    ,p_vre_attribute13              => p_vre_attribute13
    ,p_vre_attribute14              => p_vre_attribute14
    ,p_vre_attribute15              => p_vre_attribute15
    ,p_vre_attribute16              => p_vre_attribute16
    ,p_vre_attribute17              => p_vre_attribute17
    ,p_vre_attribute18              => p_vre_attribute18
    ,p_vre_attribute19              => p_vre_attribute19
    ,p_vre_attribute20              => p_vre_attribute20
    ,p_vre_information_category     => p_vre_information_category
    ,p_vre_information1             => p_vre_information1
    ,p_vre_information2             => p_vre_information2
    ,p_vre_information3             => p_vre_information3
    ,p_vre_information4             => p_vre_information4
    ,p_vre_information5             => p_vre_information5
    ,p_vre_information6             => p_vre_information6
    ,p_vre_information7             => p_vre_information7
    ,p_vre_information8             => p_vre_information8
    ,p_vre_information9             => p_vre_information9
    ,p_vre_information10            => p_vre_information10
    ,p_vre_information11            => p_vre_information11
    ,p_vre_information12            => p_vre_information12
    ,p_vre_information13            => p_vre_information13
    ,p_vre_information14            => p_vre_information14
    ,p_vre_information15            => p_vre_information15
    ,p_vre_information16            => p_vre_information16
    ,p_vre_information17            => p_vre_information17
    ,p_vre_information18            => p_vre_information18
    ,p_vre_information19            => p_vre_information19
    ,p_vre_information20            => p_vre_information20
    ,p_vehicle_repository_id        => l_vehicle_repository_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );

-- Create allocations

   FOR i in 1..l_user_info.count
    LOOP
     pqp_vehicle_allocations_api.create_vehicle_allocation
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_assignment_id                => l_user_info(i).assignment_id
    ,p_business_group_id            => p_business_group_id
    ,p_vehicle_repository_id        => l_vehicle_repository_id
    ,p_across_assignments           => p_across_assignments
    ,p_usage_type                   => p_usage_type
    ,p_default_vehicle              => p_default_vehicle
    ,p_fuel_card                    => p_fuel_card
    ,p_fuel_card_number             => p_fuel_card_number
    ,p_insurance_number             => p_insurance_number
    ,p_insurance_expiry_date        => p_insurance_expiry_date
    ,p_val_attribute_category       => p_val_attribute_category
    ,p_val_attribute1               => p_val_attribute1
    ,p_val_attribute2               => p_val_attribute2
    ,p_val_attribute3               => p_val_attribute3
    ,p_val_attribute4               => p_val_attribute4
    ,p_val_attribute5               => p_val_attribute5
    ,p_val_attribute6               => p_val_attribute6
    ,p_val_attribute7               => p_val_attribute7
    ,p_val_attribute8               => p_val_attribute8
    ,p_val_attribute9               => p_val_attribute9
    ,p_val_attribute10              => p_val_attribute10
    ,p_val_attribute11              => p_val_attribute11
    ,p_val_attribute12              => p_val_attribute12
    ,p_val_attribute13              => p_val_attribute13
    ,p_val_attribute14              => p_val_attribute14
    ,p_val_attribute15              => p_val_attribute15
    ,p_val_attribute16              => p_val_attribute16
    ,p_val_attribute17              => p_val_attribute17
    ,p_val_attribute18              => p_val_attribute18
    ,p_val_attribute19              => p_val_attribute19
    ,p_val_attribute20              => p_val_attribute20
    ,p_val_information_category     => p_val_information_category
    ,p_val_information1             => p_val_information1
    ,p_val_information2             => p_val_information2
    ,p_val_information3             => p_val_information3
    ,p_val_information4             => p_val_information4
    ,p_val_information5             => p_val_information5
    ,p_val_information6             => p_val_information6
    ,p_val_information7             => p_val_information7
    ,p_val_information8             => p_val_information8
    ,p_val_information9             => p_val_information9
    ,p_val_information10            => p_val_information10
    ,p_val_information11            => p_val_information11
    ,p_val_information12            => p_val_information12
    ,p_val_information13            => p_val_information13
    ,p_val_information14            => p_val_information14
    ,p_val_information15            => p_val_information15
    ,p_val_information16            => p_val_information16
    ,p_val_information17            => p_val_information17
    ,p_val_information18            => p_val_information18
    ,p_val_information19            => p_val_information19
    ,p_val_information20            => p_val_information20
    ,p_fuel_benefit                 => p_fuel_benefit
    ,p_vehicle_allocation_id        => l_vehicle_allocation_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
   END LOOP;


 ELSE
 --Update
  l_dt_adj:=0;

  OPEN c_get_repository_id (p_registration_number
                           ,p_business_group_id
                           ,p_effective_date
                           );

   FETCH c_get_repository_id INTO l_get_repository_id;
  CLOSE c_get_repository_id;

  l_object_version_number := l_get_repository_id.object_version_number;
  pqp_get_date_mode.find_dt_upd_modes
  (p_effective_date         => p_effective_date
  ,p_base_table_name        => 'PQP_VEHICLE_REPOSITORY_F'
  ,p_base_key_column        => 'VEHICLE_REPOSITORY_ID'
  ,p_base_key_value         => l_get_repository_id.vehicle_repository_id
  ,p_correction             => l_correction
  ,p_update                 => l_update
  ,p_update_override        => l_update_override
  ,p_update_change_insert   => l_update_change_insert
  );

  IF l_correction = 1 THEN
   l_datetrack_mode :='CORRECTION' ;
  ELSIF l_update = 1 THEN
   l_datetrack_mode :='UPDATE' ;
  END IF;

--Update vehicle repository
    <<update_vehicle>>
  BEGIN
  --Checking to see if the shared_vehicle is switched from Yes to No
  --This will reverse the process of calling the API as
  -- we need to end date all the allocations for the additional
  --users and then comeback to update the vehicle repository
  --by incrementing the update date by one. Without incrementing
  --the date the api will give an error because the end dated
  --allocation will fall on the same day when updating vehicle
  --repository with flag 'N' and this would give an error.
   IF l_get_repository_id.shared_vehicle ='Y'
    AND p_shared_vehicle ='N' AND l_chk<>2THEN
    RAISE e_exist_other_asg;
   END IF;

   pqp_vehicle_repository_api.update_vehicle
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date+(l_dt_adj)
    ,p_datetrack_mode               => l_datetrack_mode
    ,p_vehicle_repository_id        => l_get_repository_id.vehicle_repository_id
    ,p_object_version_number        => l_object_version_number
    ,p_registration_number          => p_registration_number
    ,p_vehicle_type                 => p_vehicle_type
    ,p_vehicle_id_number            => p_vehicle_id_number
    ,p_business_group_id            => p_business_group_id
    ,p_make                         => p_make
    ,p_engine_capacity_in_cc        => p_engine_capacity_in_cc
    ,p_fuel_type                    => p_fuel_type
    ,p_currency_code                => p_currency_code
    ,p_vehicle_status               => 'A'
    ,p_model                        => p_model
    ,p_initial_registration         => p_initial_registration
    ,p_last_registration_renew_date => p_last_registration_renew_date
    ,p_fiscal_ratings               => p_fiscal_ratings
    ,p_fiscal_ratings_uom           => l_lookup_code
    ,p_vehicle_ownership            => p_vehicle_ownership
    ,p_shared_vehicle               => p_shared_vehicle
    ,p_taxation_method              => p_taxation_method
    ,p_color                        => p_color
    ,p_seating_capacity             => p_seating_capacity
    ,p_weight                       => p_weight
    ,p_weight_uom                   => p_weight_uom
    ,p_model_year                   => p_model_year
     ,p_insurance_number             => p_insurance_number
    ,p_insurance_expiry_date        => p_insurance_expiry_date
    ,p_comments                     => p_comments
    ,p_vre_attribute_category       => p_vre_attribute_category
    ,p_vre_attribute1               => p_vre_attribute1
    ,p_vre_attribute2               => p_vre_attribute2
    ,p_vre_attribute3               => p_vre_attribute3
    ,p_vre_attribute4               => p_vre_attribute4
    ,p_vre_attribute5               => p_vre_attribute5
    ,p_vre_attribute6               => p_vre_attribute6
    ,p_vre_attribute7               => p_vre_attribute7
    ,p_vre_attribute8               => p_vre_attribute8
    ,p_vre_attribute9               => p_vre_attribute9
    ,p_vre_attribute10              => p_vre_attribute10
    ,p_vre_attribute11              => p_vre_attribute11
    ,p_vre_attribute12              => p_vre_attribute12
    ,p_vre_attribute13              => p_vre_attribute13
    ,p_vre_attribute14              => p_vre_attribute14
    ,p_vre_attribute15              => p_vre_attribute15
    ,p_vre_attribute16              => p_vre_attribute16
    ,p_vre_attribute17              => p_vre_attribute17
    ,p_vre_attribute18              => p_vre_attribute18
    ,p_vre_attribute19              => p_vre_attribute19
    ,p_vre_attribute20              => p_vre_attribute20
    ,p_vre_information1             => p_vre_information1
    ,p_vre_information2             => p_vre_information2
    ,p_vre_information3             => p_vre_information3
    ,p_vre_information4             => p_vre_information4
    ,p_vre_information5             => p_vre_information5
    ,p_vre_information6             => p_vre_information6
    ,p_vre_information7             => p_vre_information7
    ,p_vre_information8             => p_vre_information8
    ,p_vre_information9             => p_vre_information9
    ,p_vre_information10            => p_vre_information10
    ,p_vre_information11            => p_vre_information11
    ,p_vre_information12            => p_vre_information12
    ,p_vre_information13            => p_vre_information13
    ,p_vre_information14            => p_vre_information14
    ,p_vre_information15            => p_vre_information15
    ,p_vre_information16            => p_vre_information16
    ,p_vre_information17            => p_vre_information17
    ,p_vre_information18            => p_vre_information18
    ,p_vre_information19            => p_vre_information19
    ,p_vre_information20            => p_vre_information20
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
    EXCEPTION
    WHEN e_exist_other_asg THEN

     l_chk :=1;
     l_dt_adj:=1;


  END;
-- call update allocation process
--this process works in two different ways
--first it checks for number of assignments that are using the
--vehicle and if the assignment has increased then it will
--create allocation for that assignment and then updates
--all other existing assignments
---if the assignment has reduced then it will end date the allocation
--for that assignment and updates the rest.
  IF l_chk < 2 THEN

   update_vehicle_allocations
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_registration_number          => p_registration_number
    ,p_vehicle_repository_id        => l_get_repository_id.vehicle_repository_id
    ,p_across_assignments           => p_across_assignments
    ,p_usage_type                   => p_usage_type
    ,p_default_vehicle              => p_default_vehicle
    ,p_fuel_card                    => p_fuel_card
    ,p_fuel_card_number             => p_fuel_card_number
    ,p_insurance_number             => p_insurance_number
    ,p_insurance_expiry_date        => p_insurance_expiry_date
    ,p_val_attribute_category       => p_val_attribute_category
    ,p_val_attribute1               => p_val_attribute1
    ,p_val_attribute2               => p_val_attribute2
    ,p_val_attribute3               => p_val_attribute3
    ,p_val_attribute4               => p_val_attribute4
    ,p_val_attribute5               => p_val_attribute5
    ,p_val_attribute6               => p_val_attribute6
    ,p_val_attribute7               => p_val_attribute7
    ,p_val_attribute8               => p_val_attribute8
    ,p_val_attribute9               => p_val_attribute9
    ,p_val_attribute10              => p_val_attribute10
    ,p_val_attribute11              => p_val_attribute11
    ,p_val_attribute12              => p_val_attribute12
    ,p_val_attribute13              => p_val_attribute13
    ,p_val_attribute14              => p_val_attribute14
    ,p_val_attribute15              => p_val_attribute15
    ,p_val_attribute16              => p_val_attribute16
    ,p_val_attribute17              => p_val_attribute17
    ,p_val_attribute18              => p_val_attribute18
    ,p_val_attribute19              => p_val_attribute19
    ,p_val_attribute20              => p_val_attribute20
    ,p_val_information_category     => p_val_information_category
    ,p_val_information1             => p_val_information1
    ,p_val_information2             => p_val_information2
    ,p_val_information3             => p_val_information3
    ,p_val_information4             => p_val_information4
    ,p_val_information5             => p_val_information5
    ,p_val_information6             => p_val_information6
    ,p_val_information7             => p_val_information7
    ,p_val_information8             => p_val_information8
    ,p_val_information9             => p_val_information9
    ,p_val_information10            => p_val_information10
    ,p_val_information11            => p_val_information11
    ,p_val_information12            => p_val_information12
    ,p_val_information13            => p_val_information13
    ,p_val_information14            => p_val_information14
    ,p_val_information15            => p_val_information15
    ,p_val_information16            => p_val_information16
    ,p_val_information17            => p_val_information17
    ,p_val_information18            => p_val_information18
    ,p_val_information19            => p_val_information19
    ,p_val_information20            => p_val_information20
    ,p_fuel_benefit                 => p_fuel_benefit
    ,p_user_info                    => l_user_info
    ,p_error_message                => p_error_message
    );

   IF l_chk=1 THEN
    l_chk:=2;
    GOTO update_vehicle;
   END IF;
  END IF;
 END IF;
 EXCEPTION
  WHEN hr_utility.hr_error THEN
   hr_utility.raise_error;
  WHEN OTHERS THEN
   RAISE;  -- Raise error here relevant to the new tech stack.
END;

--This procedure is called to validate the incomming data
--before inserting into the transaction table.
PROCEDURE val_create_vehicle_details
  (
   p_validate                     in     boolean default false
  ,p_effective_date               in     date
  ,p_registration_number          in     varchar2
  ,p_vehicle_type                 in     varchar2
  ,p_vehicle_id_number            in     varchar2
  ,p_business_group_id            in     number
  ,p_make                         in     varchar2
  ,p_engine_capacity_in_cc        in     number
  ,p_fuel_type                    in     varchar2
  ,p_currency_code                in     varchar2
  ,p_model                        in     varchar2
  ,p_initial_registration         in     date
  ,p_last_registration_renew_date in     date
  ,p_fiscal_ratings               in     number
  ,p_vehicle_ownership            in     varchar2
  ,p_shared_vehicle               in     varchar2
  ,p_color                        in     varchar2
  ,p_seating_capacity             in     number
  ,p_weight                       in     number
  ,p_weight_uom                   in     varchar2
  ,p_model_year                   in     number
  ,p_insurance_number             in     varchar2
  ,p_insurance_expiry_date        in     date
  ,p_taxation_method              in     varchar2
  ,p_comments                     in     varchar2
  ,p_vre_attribute_category       in     varchar2
  ,p_vre_attribute1               in     varchar2
  ,p_vre_attribute2               in     varchar2
  ,p_vre_attribute3               in     varchar2
  ,p_vre_attribute4               in     varchar2
  ,p_vre_attribute5               in     varchar2
  ,p_vre_attribute6               in     varchar2
  ,p_vre_attribute7               in     varchar2
  ,p_vre_attribute8               in     varchar2
  ,p_vre_attribute9               in     varchar2
  ,p_vre_attribute10              in     varchar2
  ,p_vre_attribute11              in     varchar2
  ,p_vre_attribute12              in     varchar2
  ,p_vre_attribute13              in     varchar2
  ,p_vre_attribute14              in     varchar2
  ,p_vre_attribute15              in     varchar2
  ,p_vre_attribute16              in     varchar2
  ,p_vre_attribute17              in     varchar2
  ,p_vre_attribute18              in     varchar2
  ,p_vre_attribute19              in     varchar2
  ,p_vre_attribute20              in     varchar2
  ,p_vre_information_category     in     varchar2
  ,p_vre_information1             in     varchar2
  ,p_vre_information2             in     varchar2
  ,p_vre_information3             in     varchar2
  ,p_vre_information4             in     varchar2
  ,p_vre_information5             in     varchar2
  ,p_vre_information6             in     varchar2
  ,p_vre_information7             in     varchar2
  ,p_vre_information8             in     varchar2
  ,p_vre_information9             in     varchar2
  ,p_vre_information10            in     varchar2
  ,p_vre_information11            in     varchar2
  ,p_vre_information12            in     varchar2
  ,p_vre_information13            in     varchar2
  ,p_vre_information14            in     varchar2
  ,p_vre_information15            in     varchar2
  ,p_vre_information16            in     varchar2
  ,p_vre_information17            in     varchar2
  ,p_vre_information18            in     varchar2
  ,p_vre_information19            in     varchar2
  ,p_vre_information20            in     varchar2
  ,p_across_assignments           in     varchar2
  ,p_usage_type                   in     varchar2
  ,p_default_vehicle              in     varchar2
  ,p_fuel_card                    in     varchar2
  ,p_fuel_card_number             in     varchar2
  ,p_val_attribute_category       in     varchar2
  ,p_val_attribute1               in     varchar2
  ,p_val_attribute2               in     varchar2
  ,p_val_attribute3               in     varchar2
  ,p_val_attribute4               in     varchar2
  ,p_val_attribute5               in     varchar2
  ,p_val_attribute6               in     varchar2
  ,p_val_attribute7               in     varchar2
  ,p_val_attribute8               in     varchar2
  ,p_val_attribute9               in     varchar2
  ,p_val_attribute10              in     varchar2
  ,p_val_attribute11              in     varchar2
  ,p_val_attribute12              in     varchar2
  ,p_val_attribute13              in     varchar2
  ,p_val_attribute14              in     varchar2
  ,p_val_attribute15              in     varchar2
  ,p_val_attribute16              in     varchar2
  ,p_val_attribute17              in     varchar2
  ,p_val_attribute18              in     varchar2
  ,p_val_attribute19              in     varchar2
  ,p_val_attribute20              in     varchar2
  ,p_val_information_category     in     varchar2
  ,p_val_information1             in     varchar2
  ,p_val_information2             in     varchar2
  ,p_val_information3             in     varchar2
  ,p_val_information4             in     varchar2
  ,p_val_information5             in     varchar2
  ,p_val_information6             in     varchar2
  ,p_val_information7             in     varchar2
  ,p_val_information8             in     varchar2
  ,p_val_information9             in     varchar2
  ,p_val_information10            in     varchar2
  ,p_val_information11            in     varchar2
  ,p_val_information12            in     varchar2
  ,p_val_information13            in     varchar2
  ,p_val_information14            in     varchar2
  ,p_val_information15            in     varchar2
  ,p_val_information16            in     varchar2
  ,p_val_information17            in     varchar2
  ,p_val_information18            in     varchar2
  ,p_val_information19            in     varchar2
  ,p_val_information20            in     varchar2
  ,p_fuel_benefit                 in     varchar2
  ,p_user_info                    in     t_user_info
  ,p_vehicle_repository_id        in     number
  ,p_vehicle_allocation_id        in     number
  ,p_object_version_number        in     number
  ,p_error_message                OUT    nocopy varchar2
  ,p_error_status                 OUT    nocopy varchar2

          )
IS
pragma autonomous_transaction;
BEGIN

 create_vehicle_details
  (
   p_validate                     => false
  ,p_effective_date               =>p_effective_date
  ,p_registration_number          =>p_registration_number
  ,p_vehicle_type                 =>p_vehicle_type
  ,p_vehicle_id_number            =>p_vehicle_id_number
  ,p_business_group_id            =>p_business_group_id
  ,p_make                         =>p_make
  ,p_engine_capacity_in_cc        =>p_engine_capacity_in_cc
  ,p_fuel_type                    =>p_fuel_type
  ,p_currency_code                =>p_currency_code
  ,p_model                        =>p_model
  ,p_initial_registration         =>p_initial_registration
  ,p_last_registration_renew_date =>p_last_registration_renew_date
  ,p_fiscal_ratings               =>p_fiscal_ratings
  ,p_vehicle_ownership            =>p_vehicle_ownership
  ,p_shared_vehicle               =>p_shared_vehicle
  ,p_color                        =>p_color
  ,p_seating_capacity             =>p_seating_capacity
  ,p_weight                       =>p_weight
  ,p_weight_uom                   =>p_weight_uom
  ,p_model_year                   =>p_model_year
  ,p_insurance_number             =>p_insurance_number
  ,p_insurance_expiry_date        =>p_insurance_expiry_date
  ,p_taxation_method              =>p_taxation_method
  ,p_comments                     =>p_comments
  ,p_vre_attribute_category       =>p_vre_attribute_category
  ,p_vre_attribute1               =>p_vre_attribute1
  ,p_vre_attribute2               =>p_vre_attribute2
  ,p_vre_attribute3               =>p_vre_attribute3
  ,p_vre_attribute4               =>p_vre_attribute4
  ,p_vre_attribute5               =>p_vre_attribute5
  ,p_vre_attribute6               =>p_vre_attribute6
  ,p_vre_attribute7               =>p_vre_attribute7
  ,p_vre_attribute8               =>p_vre_attribute8
  ,p_vre_attribute9               =>p_vre_attribute9
  ,p_vre_attribute10              =>p_vre_attribute10
  ,p_vre_attribute11              =>p_vre_attribute11
  ,p_vre_attribute12              =>p_vre_attribute12
  ,p_vre_attribute13              =>p_vre_attribute13
  ,p_vre_attribute14              =>p_vre_attribute14
  ,p_vre_attribute15              =>p_vre_attribute15
  ,p_vre_attribute16              =>p_vre_attribute16
  ,p_vre_attribute17              =>p_vre_attribute17
  ,p_vre_attribute18              =>p_vre_attribute18
  ,p_vre_attribute19              =>p_vre_attribute19
  ,p_vre_attribute20              =>p_vre_attribute20
  ,p_vre_information_category     =>p_vre_information_category
  ,p_vre_information1             =>p_vre_information1
  ,p_vre_information2             =>p_vre_information2
  ,p_vre_information3             =>p_vre_information3
  ,p_vre_information4             =>p_vre_information4
  ,p_vre_information5             =>p_vre_information5
  ,p_vre_information6             =>p_vre_information6
  ,p_vre_information7             =>p_vre_information7
  ,p_vre_information8             =>p_vre_information8
  ,p_vre_information9             =>p_vre_information9
  ,p_vre_information10            =>p_vre_information10
  ,p_vre_information11            =>p_vre_information11
  ,p_vre_information12            =>p_vre_information12
  ,p_vre_information13            =>p_vre_information13
  ,p_vre_information14            =>p_vre_information14
  ,p_vre_information15            =>p_vre_information15
  ,p_vre_information16            =>p_vre_information16
  ,p_vre_information17            =>p_vre_information17
  ,p_vre_information18            =>p_vre_information18
  ,p_vre_information19            =>p_vre_information19
  ,p_vre_information20            =>p_vre_information20
  ,p_across_assignments           =>p_across_assignments
  ,p_usage_type                   =>p_usage_type
  ,p_default_vehicle              =>p_default_vehicle
  ,p_fuel_card                    =>p_fuel_card
  ,p_fuel_card_number             =>p_fuel_card_number
  ,p_val_attribute_category       =>p_val_attribute_category
  ,p_val_attribute1               =>p_val_attribute1
  ,p_val_attribute2               =>p_val_attribute2
  ,p_val_attribute3               =>p_val_attribute3
  ,p_val_attribute4               =>p_val_attribute4
  ,p_val_attribute5               =>p_val_attribute5
  ,p_val_attribute6               =>p_val_attribute6
  ,p_val_attribute7               =>p_val_attribute7
  ,p_val_attribute8               =>p_val_attribute8
  ,p_val_attribute9               =>p_val_attribute9
  ,p_val_attribute10              =>p_val_attribute10
  ,p_val_attribute11              =>p_val_attribute11
  ,p_val_attribute12              =>p_val_attribute12
  ,p_val_attribute13              =>p_val_attribute13
  ,p_val_attribute14              =>p_val_attribute14
  ,p_val_attribute15              =>p_val_attribute15
  ,p_val_attribute16              =>p_val_attribute16
  ,p_val_attribute17              =>p_val_attribute17
  ,p_val_attribute18              =>p_val_attribute18
  ,p_val_attribute19              =>p_val_attribute19
  ,p_val_attribute20              =>p_val_attribute20
  ,p_val_information_category     =>p_val_information_category
  ,p_val_information1             =>p_val_information1
  ,p_val_information2             =>p_val_information2
  ,p_val_information3             =>p_val_information3
  ,p_val_information4             =>p_val_information4
  ,p_val_information5             =>p_val_information5
  ,p_val_information6             =>p_val_information6
  ,p_val_information7             =>p_val_information7
  ,p_val_information8             =>p_val_information8
  ,p_val_information9             =>p_val_information9
  ,p_val_information10            =>p_val_information10
  ,p_val_information11            =>p_val_information11
  ,p_val_information12            =>p_val_information12
  ,p_val_information13            =>p_val_information13
  ,p_val_information14            =>p_val_information14
  ,p_val_information15            =>p_val_information15
  ,p_val_information16            =>p_val_information16
  ,p_val_information17            =>p_val_information17
  ,p_val_information18            =>p_val_information18
  ,p_val_information19            =>p_val_information19
  ,p_val_information20            =>p_val_information20
  ,p_fuel_benefit                 =>p_fuel_benefit
  ,p_user_info                    =>p_user_info
  ,p_vehicle_repository_id        =>p_vehicle_repository_id
  ,p_vehicle_allocation_id        =>p_vehicle_allocation_id
  ,p_object_version_number        =>p_object_version_number
  ,p_error_message                =>p_error_message
  ,p_error_status                 =>p_error_status
  );


 ROLLBACK;
END;


---Not used at the moment

PROCEDURE delete_vehicle_details(
   x_p_validate             IN BOOLEAN
  ,x_effective_date         IN DATE
  ,x_login_person_id        IN NUMBER
  ,x_person_id              IN NUMBER
  ,x_assignment_id          IN NUMBER
  ,x_business_group_id      IN NUMBER
  ,x_item_key               IN NUMBER
  ,x_item_type              IN VARCHAR2
  ,x_activity_id            IN NUMBER
  ,x_vehicle_allocation_id  IN NUMBER
  ,x_status                 IN VARCHAR2
  ,x_transaction_id         IN OUT NOCOPY NUMBER
  ,x_error_status           OUT NOCOPY VARCHAR2
                      )

IS



CURSOR c_del_values
IS
SELECT transaction_step_id
 FROM  hr_api_transaction_steps hats
 WHERE transaction_id = x_transaction_id;

l_del_values                  c_del_values%ROWTYPE;
l_transaction_id              NUMBER;
l_trans_tbl                   hr_transaction_ss.transaction_table;
l_count                       NUMBER :=0;
l_transaction_step_id         NUMBER;
l_api_name                    hr_api_transaction_steps.api_name%TYPE
                              := 'PQP_SS_VEHICLE_TRANSACTIONS.DELETE_PROCESS_API';
l_result                      VARCHAR2(100);
l_trns_object_version_number  NUMBER;
l_review_proc_call            VARCHAR2(30) := 'PqpVehDelReview';
l_effective_date              DATE     := SYSDATE;
l_ovn                         NUMBER;
l_error_message               VARCHAR2(80);
l_error_status                VARCHAR2(10);
BEGIN

   --Validate the data before inserting into
   -- transaction table.
   delete_process (
    p_validate               => true
   ,p_effective_date         => x_effective_date
   ,p_person_id              => x_person_id
   ,p_assignment_id          => x_assignment_id
   ,p_business_group_id      => x_business_group_id
   ,p_vehicle_allocation_id  => x_vehicle_allocation_id
   ,p_error_status           => l_error_status
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
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_PROC_CALL';
  l_trans_tbl(l_count).param_value     :=  l_review_proc_call;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

   l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_ACTID';
  l_trans_tbl(l_count).param_value     :=  x_activity_id;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

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
  l_trans_tbl(l_count).param_name      := 'P_ALLOCATION_ID';
  l_trans_tbl(l_count).param_value     :=  x_vehicle_allocation_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  IF x_transaction_id is NULl THEN
    hr_transaction_api.create_transaction(
               p_validate                   => false
              ,p_creator_person_id          => x_login_person_id
              ,p_transaction_privilege      => 'PRIVATE'
              ,p_product_code               => 'PQP'
              ,p_url                        => NULL
              ,p_status                     => x_status
              ,p_section_display_name       => NULL
              ,p_function_id                => NULL
              ,p_transaction_ref_table      => NULL
              ,p_transaction_ref_id         => NULL
              ,p_transaction_type           => 'WF'
              ,p_assignment_id              => x_assignment_id
              ,p_selected_person_id         => x_person_id
              ,p_item_type                  => x_item_type
              ,p_item_key                   => x_item_key
              ,p_transaction_effective_date => x_effective_date
              ,p_process_name               => NULL
              ,p_plan_id                    => NULL
              ,p_rptg_grp_id                => NULL
              ,p_effective_date_option      => x_effective_date
              ,p_transaction_id             => l_transaction_id
              );
              wf_engine.setitemattrnumber
              (itemtype => x_item_type
              ,itemkey  => x_item_key
              ,aname    => 'TRANSACTION_ID'
              ,avalue   => l_transaction_id);
              x_transaction_id         :=  l_transaction_id;
 --Create transaction steps
   hr_transaction_api.create_transaction_step
              (p_validate                   => false
              ,p_creator_person_id          =>  x_login_person_id
              ,p_transaction_id             => l_transaction_id
              ,p_api_name                   => l_api_name
              ,p_api_display_name           => l_api_name
              ,p_item_type                  => x_item_type
              ,p_item_key                   => x_item_key
              ,p_activity_id                => x_activity_id
              ,p_transaction_step_id        => l_transaction_step_id
              ,p_object_version_number      =>  l_ovn
             );
  ELSE

   OPEN c_del_values;
    FETCH c_del_values INTO l_del_values;
   CLOSE c_del_values;

   DELETE from hr_api_transaction_values
     WHERE transaction_step_id = l_del_values.transaction_step_id;
    l_transaction_step_id := l_del_values.transaction_step_id;
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
                                  (l_trans_tbl (i).param_value ) );
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

  EXCEPTION
    WHEN hr_utility.hr_error THEN
  	hr_utility.raise_error;
    WHEN OTHERS THEN
        RAISE;  -- Raise error here relevant to the new tech stack.

END;

PROCEDURE set_vehicle_details (
   x_p_validate                   IN BOOLEAN
  ,x_effective_date               IN DATE
  ,x_login_person_id              IN NUMBER
  ,x_person_id                    IN NUMBER
  ,x_assignment_id                IN NUMBER
  ,x_item_type                    IN VARCHAR2
  ,x_item_key                     IN NUMBER
  ,x_activity_id                  IN NUMBER
  ,x_registration_number          IN VARCHAR2
  ,x_vehicle_ownership            IN VARCHAR2
  ,x_vehicle_type                 IN VARCHAR2
  ,x_vehicle_id_number            IN VARCHAR2
  ,x_business_group_id            IN NUMBER
  ,x_make                         IN VARCHAR2
  ,x_engine_capacity_in_cc        IN NUMBER
  ,x_fuel_type                    IN VARCHAR2
  ,x_currency_code                IN VARCHAR2
  ,x_model                        IN VARCHAR2
  ,x_initial_registration         IN DATE
  ,x_last_registration_renew_date IN DATE
  ,x_fiscal_ratings               IN NUMBER
  ,x_shared_vehicle               IN VARCHAR2
  ,x_color                        IN VARCHAR2
  ,x_seating_capacity             IN NUMBER
  ,x_weight                       IN NUMBER
  ,x_weight_uom                   IN VARCHAR2
  ,x_model_year                   IN NUMBER
  ,x_insurance_number             IN VARCHAR2
  ,x_insurance_expiry_date        IN DATE
  ,x_taxation_method              IN VARCHAR2
  ,x_comments                     IN VARCHAR2
  ,x_vre_attribute_category       IN VARCHAR2
  ,x_vre_attribute1               IN VARCHAR2
  ,x_vre_attribute2               IN VARCHAR2
  ,x_vre_attribute3               IN VARCHAR2
  ,x_vre_attribute4               IN VARCHAR2
  ,x_vre_attribute5               IN VARCHAR2
  ,x_vre_attribute6               IN VARCHAR2
  ,x_vre_attribute7               IN VARCHAR2
  ,x_vre_attribute8               IN VARCHAR2
  ,x_vre_attribute9               IN VARCHAR2
  ,x_vre_attribute10              IN VARCHAR2
  ,x_vre_attribute11              IN VARCHAR2
  ,x_vre_attribute12              IN VARCHAR2
  ,x_vre_attribute13              IN VARCHAR2
  ,x_vre_attribute14              IN VARCHAR2
  ,x_vre_attribute15              IN VARCHAR2
  ,x_vre_attribute16              IN VARCHAR2
  ,x_vre_attribute17              IN VARCHAR2
  ,x_vre_attribute18              IN VARCHAR2
  ,x_vre_attribute19              IN VARCHAR2
  ,x_vre_attribute20              IN VARCHAR2
  ,x_vre_information_category     IN VARCHAR2
  ,x_vre_information1             IN VARCHAR2
  ,x_vre_information2             IN VARCHAR2
  ,x_vre_information3             IN VARCHAR2
  ,x_vre_information4             IN VARCHAR2
  ,x_vre_information5             IN VARCHAR2
  ,x_vre_information6             IN VARCHAR2
  ,x_vre_information7             IN VARCHAR2
  ,x_vre_information8             IN VARCHAR2
  ,x_vre_information9             IN VARCHAR2
  ,x_vre_information10            IN VARCHAR2
  ,x_vre_information11            IN VARCHAR2
  ,x_vre_information12            IN VARCHAR2
  ,x_vre_information13            IN VARCHAR2
  ,x_vre_information14            IN VARCHAR2
  ,x_vre_information15            IN VARCHAR2
  ,x_vre_information16            IN VARCHAR2
  ,x_vre_information17            IN VARCHAR2
  ,x_vre_information18            IN VARCHAR2
  ,x_vre_information19            IN VARCHAR2
  ,x_vre_information20            IN VARCHAR2
  ,x_across_assignments           IN VARCHAR2
  ,x_usage_type                   IN VARCHAR2
  ,x_default_vehicle              IN VARCHAR2
  ,x_fuel_card                    IN VARCHAR2
  ,x_fuel_card_number             IN VARCHAR2
  ,x_val_attribute_category       IN VARCHAR2
  ,x_val_attribute1               IN VARCHAR2
  ,x_val_attribute2               IN VARCHAR2
  ,x_val_attribute3               IN VARCHAR2
  ,x_val_attribute4               IN VARCHAR2
  ,x_val_attribute5               IN VARCHAR2
  ,x_val_attribute6               IN VARCHAR2
  ,x_val_attribute7               IN VARCHAR2
  ,x_val_attribute8               IN VARCHAR2
  ,x_val_attribute9               IN VARCHAR2
  ,x_val_attribute10              IN VARCHAR2
  ,x_val_attribute11              IN VARCHAR2
  ,x_val_attribute12              IN VARCHAR2
  ,x_val_attribute13              IN VARCHAR2
  ,x_val_attribute14              IN VARCHAR2
  ,x_val_attribute15              IN VARCHAR2
  ,x_val_attribute16              IN VARCHAR2
  ,x_val_attribute17              IN VARCHAR2
  ,x_val_attribute18              IN VARCHAR2
  ,x_val_attribute19              IN VARCHAR2
  ,x_val_attribute20              IN VARCHAR2
  ,x_val_information_category     IN VARCHAR2
  ,x_val_information1             IN VARCHAR2
  ,x_val_information2             IN VARCHAR2
  ,x_val_information3             IN VARCHAR2
  ,x_val_information4             IN VARCHAR2
  ,x_val_information5             IN VARCHAR2
  ,x_val_information6             IN VARCHAR2
  ,x_val_information7             IN VARCHAR2
  ,x_val_information8             IN VARCHAR2
  ,x_val_information9             IN VARCHAR2
  ,x_val_information10            IN VARCHAR2
  ,x_val_information11            IN VARCHAR2
  ,x_val_information12            IN VARCHAR2
  ,x_val_information13            IN VARCHAR2
  ,x_val_information14            IN VARCHAR2
  ,x_val_information15            IN VARCHAR2
  ,x_val_information16            IN VARCHAR2
  ,x_val_information17            IN VARCHAR2
  ,x_val_information18            IN VARCHAR2
  ,x_val_information19            IN VARCHAR2
  ,x_val_information20            IN VARCHAR2
  ,x_fuel_benefit                 IN VARCHAR2
  ,x_user_info                    IN t_user_info
  ,x_status                       IN VARCHAR2
  ,x_effective_date_option        IN VARCHAR2
  ,x_vehicle_repository_id        IN NUMBER
  ,x_vehicle_allocation_id        IN NUMBER
  ,x_object_version_number        in NUMBER
  ,x_error_status                 OUT NOCOPY VARCHAR2
  ,x_transaction_id               IN OUT NOCOPY NUMBER
)
IS
CURSOR c_del_values
IS
SELECT transaction_step_id
 FROM  hr_api_transaction_steps hats
 WHERE transaction_id = x_transaction_id;

l_del_values                 c_del_values%ROWTYPE;
l_transaction_id             NUMBER;
l_trans_tbl                  hr_transaction_ss.transaction_table;
l_count                      NUMBER :=0;
l_transaction_step_id        NUMBER;
l_api_name                   hr_api_transaction_steps.api_name%TYPE
                             := 'PQP_SS_VEHICLE_TRANSACTIONS.PROCESS_API';
l_result                     VARCHAR2(100);
l_trns_object_version_number number;
l_review_proc_call           VARCHAR2(30) := 'PqpVehInfoReview';
l_effective_date             DATE         := SYSDATE;
l_ovn                        NUMBER;
l_error_message              VARCHAR2(80);
l_error_status               VARCHAR2(10);
u_count                      NUMBER;
l_sec_result                     VARCHAR2(100);
BEGIN
 hr_utility.set_location('Enter:Set Vehicle Details' ,5);
 SAVEPOINT pqp_vehicle_proc_start;
 BEGIN
   hr_utility.set_location('Enter:Set Paramaters' ,10);
  SAVEPOINT pqp_vehicle_validate;
   hr_multi_message.enable_message_list;
  hr_utility.set_location('Entering: enter set vehicle details',5);
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
  l_trans_tbl(l_count).param_name      := 'P_REGISTRATION_NUMBER';
  l_trans_tbl(l_count).param_value     :=  x_registration_number;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VEHICLE_OWNERSHIP';
  l_trans_tbl(l_count).param_value     :=  x_vehicle_ownership;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VEHICLE_TYPE';
  l_trans_tbl(l_count).param_value     :=  x_vehicle_type;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VEHICLE_ID_NUMBER';
  l_trans_tbl(l_count).param_value     :=  x_vehicle_id_number;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_BUSINESS_GROUP_ID';
  l_trans_tbl(l_count).param_value     :=  x_business_group_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_MAKE';
  l_trans_tbl(l_count).param_value     :=  x_make;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ENGINE_CAPACITY_IN_CC';
  l_trans_tbl(l_count).param_value     :=  x_engine_capacity_in_cc;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_FUEL_TYPE';
  l_trans_tbl(l_count).param_value     :=  x_fuel_type;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_CURRENCY_CODE';
  l_trans_tbl(l_count).param_value     :=  x_currency_code;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_MODEL';
  l_trans_tbl(l_count).param_value     :=  x_model;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_INITIAL_REGISTRATION';
  l_trans_tbl(l_count).param_value     :=  x_initial_registration;
  l_trans_tbl(l_count).param_data_type := 'DATE';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_LAST_REGISTRATION_RENEW_DATE';
  l_trans_tbl(l_count).param_value     :=  x_last_registration_renew_date;
  l_trans_tbl(l_count).param_data_type := 'DATE';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_FISCAL_RATINGS';
  l_trans_tbl(l_count).param_value     :=  x_fiscal_ratings;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_SHARED_VEHICLE';
  l_trans_tbl(l_count).param_value     :=  x_shared_vehicle;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_COLOR';
  l_trans_tbl(l_count).param_value     :=  x_color;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_SEATING_CAPACITY';
  l_trans_tbl(l_count).param_value     :=  x_seating_capacity;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';



  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_WEIGHT';
  l_trans_tbl(l_count).param_value     :=  x_weight;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_WEIGHT_UOM';
  l_trans_tbl(l_count).param_value     :=  x_weight_uom;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_MODEL_YEAR';
  l_trans_tbl(l_count).param_value     :=  x_model_year;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_INSURANCE_NUMBER';
  l_trans_tbl(l_count).param_value     :=  x_insurance_number;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_INSURANCE_EXPIRY_DATE';
  l_trans_tbl(l_count).param_value     :=  x_insurance_expiry_date;
  l_trans_tbl(l_count).param_data_type := 'DATE';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_TAXATION_METHOD';
  l_trans_tbl(l_count).param_value     :=  x_taxation_method;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_COMMENTS';
  l_trans_tbl(l_count).param_value     :=  x_comments;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE_CATEGORY';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute_category;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE1';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute1;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE2';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute2;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE3';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute3;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE4';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute4;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE5';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute5;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';



  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE6';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute6;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE7';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute7;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE8';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute8;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE9';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute9;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE10';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute10;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE11';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute11;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE12';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute12;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE13';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute13;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE14';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute14;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE15';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute15;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE16';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute16;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE17';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute17;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE18';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute18;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE19';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute19;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_ATTRIBUTE20';
  l_trans_tbl(l_count).param_value     :=  x_vre_attribute20;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION_CATEGORY';
  l_trans_tbl(l_count).param_value     :=  x_vre_information_category;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION1';
  l_trans_tbl(l_count).param_value     :=  x_vre_information1;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION2';
  l_trans_tbl(l_count).param_value     :=  x_vre_information2;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION3';
  l_trans_tbl(l_count).param_value     :=  x_vre_information3;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION4';
  l_trans_tbl(l_count).param_value     :=  x_vre_information4;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION5';
  l_trans_tbl(l_count).param_value     :=  x_vre_information5;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION6';
  l_trans_tbl(l_count).param_value     :=  x_vre_information6;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION7';
  l_trans_tbl(l_count).param_value     :=  x_vre_information7;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION8';
  l_trans_tbl(l_count).param_value     :=  x_vre_information8;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION9';
  l_trans_tbl(l_count).param_value     :=  x_vre_information9;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION10';
  l_trans_tbl(l_count).param_value     :=  x_vre_information10;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION11';
  l_trans_tbl(l_count).param_value     :=  x_vre_information11;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION12';
  l_trans_tbl(l_count).param_value     :=  x_vre_information12;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION13';
  l_trans_tbl(l_count).param_value     :=  x_vre_information13;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION14';
  l_trans_tbl(l_count).param_value     :=  x_vre_information14;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION15';
  l_trans_tbl(l_count).param_value     :=  x_vre_information15;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION16';
  l_trans_tbl(l_count).param_value     :=  x_vre_information16;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION17';
  l_trans_tbl(l_count).param_value     :=  x_vre_information17;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION18';
  l_trans_tbl(l_count).param_value     :=  x_vre_information18;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION19';
  l_trans_tbl(l_count).param_value     :=  x_vre_information19;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VRE_INFORMATION20';
  l_trans_tbl(l_count).param_value     :=  x_vre_information20;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ACROSS_ASSIGNMENTS';
  l_trans_tbl(l_count).param_value     :=  x_across_assignments;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_USAGE_TYPE';
  l_trans_tbl(l_count).param_value     :=  x_usage_type;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_DEFAULT_VEHICLE';
  l_trans_tbl(l_count).param_value     :=  x_default_vehicle;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_FUEL_CARD';
  l_trans_tbl(l_count).param_value     :=  x_fuel_card;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_FUEL_CARD_NUMBER';
  l_trans_tbl(l_count).param_value     :=  x_fuel_card_number;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE_CATEGORY';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute_category;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE1';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute1;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE2';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute2;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE3';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute3;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE4';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute4;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE5';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute5;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE6';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute6;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE7';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute7;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE8';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute8;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE9';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute9;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE10';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute10;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';



  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE11';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute11;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE12';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute12;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE13';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute13;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE14';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute14;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE15';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute15;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE16';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute16;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE17';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute17;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE18';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute18;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE19';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute19;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_ATTRIBUTE20';
  l_trans_tbl(l_count).param_value     :=  x_val_attribute20;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION_CATEGORY';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION_category;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION1';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION1;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION2';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION2;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION3';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION3;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION4';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION4;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


 l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION5';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION5;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION6';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION6;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION7';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION7;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION8';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION8;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION9';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION9;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION10';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION10;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

 l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION11';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION11;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION12';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION12;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION13';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION13;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION14';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION14;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION15';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION15;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION16';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION16;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION17';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION17;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION18';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION18;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION19';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION19;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VAL_INFORMATION20';
  l_trans_tbl(l_count).param_value     :=  x_val_INFORMATION20;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_FUEL_BENEFIT';
  l_trans_tbl(l_count).param_value     :=  x_fuel_benefit;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_OBJECT_VERSION_NUMBER';
  l_trans_tbl(l_count).param_value     :=  x_object_version_number;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
   hr_utility.set_location('Entering: Second',5);
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_PROC_CALL';
  l_trans_tbl(l_count).param_value     :=  l_review_proc_call;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_ACTID';
  l_trans_tbl(l_count).param_value     :=  x_activity_id;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VEHICLE_REPOSITORY_ID';
  l_trans_tbl(l_count).param_value     :=  x_vehicle_repository_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
   hr_utility.set_location('Entering: Set p_vehicle_allocation_id',5);
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VEHICLE_ALLOCATION_ID';
  l_trans_tbl(l_count).param_value     :=  x_vehicle_allocation_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
   hr_utility.set_location('Leaving:Set Paramaters' ,15);

  u_count:=x_user_info.count;
  FOR i in 1..x_user_info.count
  LOOP
   hr_utility.set_location('Entering: userinfo',5);
   l_count:=l_count+1;
   hr_utility.set_location('Entering: enter loop',10);
   l_trans_tbl(l_count).param_name      := 'P_PERSON_USR_ID'||i;
   l_trans_tbl(l_count).param_value     :=  x_user_info(i).person_id;
   l_trans_tbl(l_count).param_data_type := 'NUMBER';
   l_count:=l_count+1;
   l_trans_tbl(l_count).param_name      := 'P_ASSIGNMENT_USR_ID'||i;
   l_trans_tbl(l_count).param_value     :=  x_user_info(i).assignment_id;
   l_trans_tbl(l_count).param_data_type := 'NUMBER';
   l_count:=l_count+1;
   l_trans_tbl(l_count).param_name      := 'P_USER_TYPE'||i;
   l_trans_tbl(l_count).param_value     :=  x_user_info(i).user_type;
   l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
   hr_utility.set_location('Leaving: userinfo',10);
   END LOOP;
  ---Validate the incomming values against acual table.
  --The validation is done in false mode and then
  --rolled back using autonomous transaction.The resaon for going
  --in for Validate false mode is due to the fact that
  -- the when two apis are called where some of the condition in
  --first api could affect the validation of the second api. Validate True mode
  --would rollback once the transaction is completed and this would
  -- get the second api with the wrong info as the value is alredy rolled back
  --in the first Api.
   hr_utility.set_location('Entering val_create_vehicle_details:',15);
   val_create_vehicle_details
  (
   p_validate                     => false
  ,p_effective_date               =>x_effective_date
  ,p_registration_number          =>x_registration_number
  ,p_vehicle_type                 =>x_vehicle_type
  ,p_vehicle_id_number            =>x_vehicle_id_number
  ,p_business_group_id            =>x_business_group_id
  ,p_make                         =>x_make
  ,p_engine_capacity_in_cc        =>x_engine_capacity_in_cc
  ,p_fuel_type                    =>x_fuel_type
  ,p_currency_code                =>x_currency_code
  ,p_model                        =>x_model
  ,p_initial_registration         =>x_initial_registration
  ,p_last_registration_renew_date =>x_last_registration_renew_date
  ,p_fiscal_ratings               =>x_fiscal_ratings
  ,p_vehicle_ownership            =>x_vehicle_ownership
  ,p_shared_vehicle               =>x_shared_vehicle
  ,p_color                        =>x_color
  ,p_seating_capacity             =>x_seating_capacity
  ,p_weight                       =>x_weight
  ,p_weight_uom                   =>x_weight_uom
  ,p_model_year                   =>x_model_year
  ,p_insurance_number             =>x_insurance_number
  ,p_insurance_expiry_date        =>x_insurance_expiry_date
  ,p_taxation_method              =>x_taxation_method
  ,p_comments                     =>x_comments
  ,p_vre_attribute_category       =>x_vre_attribute_category
  ,p_vre_attribute1               =>x_vre_attribute1
  ,p_vre_attribute2               =>x_vre_attribute2
  ,p_vre_attribute3               =>x_vre_attribute3
  ,p_vre_attribute4               =>x_vre_attribute4
  ,p_vre_attribute5               =>x_vre_attribute5
  ,p_vre_attribute6               =>x_vre_attribute6
  ,p_vre_attribute7               =>x_vre_attribute7
  ,p_vre_attribute8               =>x_vre_attribute8
  ,p_vre_attribute9               =>x_vre_attribute9
  ,p_vre_attribute10              =>x_vre_attribute10
  ,p_vre_attribute11              =>x_vre_attribute11
  ,p_vre_attribute12              =>x_vre_attribute12
  ,p_vre_attribute13              =>x_vre_attribute13
  ,p_vre_attribute14              =>x_vre_attribute14
  ,p_vre_attribute15              =>x_vre_attribute15
  ,p_vre_attribute16              =>x_vre_attribute16
  ,p_vre_attribute17              =>x_vre_attribute17
  ,p_vre_attribute18              =>x_vre_attribute18
  ,p_vre_attribute19              =>x_vre_attribute19
  ,p_vre_attribute20              =>x_vre_attribute20
  ,p_vre_information_category     =>x_vre_information_category
  ,p_vre_information1             =>x_vre_information1
  ,p_vre_information2             =>x_vre_information2
  ,p_vre_information3             =>x_vre_information3
  ,p_vre_information4             =>x_vre_information4
  ,p_vre_information5             =>x_vre_information5
  ,p_vre_information6             =>x_vre_information6
  ,p_vre_information7             =>x_vre_information7
  ,p_vre_information8             =>x_vre_information8
  ,p_vre_information9             =>x_vre_information9
  ,p_vre_information10            =>x_vre_information10
  ,p_vre_information11            =>x_vre_information11
  ,p_vre_information12            =>x_vre_information12
  ,p_vre_information13            =>x_vre_information13
  ,p_vre_information14            =>x_vre_information14
  ,p_vre_information15            =>x_vre_information15
  ,p_vre_information16            =>x_vre_information16
  ,p_vre_information17            =>x_vre_information17
  ,p_vre_information18            =>x_vre_information18
  ,p_vre_information19            =>x_vre_information19
  ,p_vre_information20            =>x_vre_information20
  ,p_across_assignments           =>x_across_assignments
  ,p_usage_type                   =>x_usage_type
  ,p_default_vehicle              =>x_default_vehicle
  ,p_fuel_card                    =>x_fuel_card
  ,p_fuel_card_number             =>x_fuel_card_number
  ,p_val_attribute_category       =>x_val_attribute_category
  ,p_val_attribute1               =>x_val_attribute1
  ,p_val_attribute2               =>x_val_attribute2
  ,p_val_attribute3               =>x_val_attribute3
  ,p_val_attribute4               =>x_val_attribute4
  ,p_val_attribute5               =>x_val_attribute5
  ,p_val_attribute6               =>x_val_attribute6
  ,p_val_attribute7               =>x_val_attribute7
  ,p_val_attribute8               =>x_val_attribute8
  ,p_val_attribute9               =>x_val_attribute9
  ,p_val_attribute10              =>x_val_attribute10
  ,p_val_attribute11              =>x_val_attribute11
  ,p_val_attribute12              =>x_val_attribute12
  ,p_val_attribute13              =>x_val_attribute13
  ,p_val_attribute14              =>x_val_attribute14
  ,p_val_attribute15              =>x_val_attribute15
  ,p_val_attribute16              =>x_val_attribute16
  ,p_val_attribute17              =>x_val_attribute17
  ,p_val_attribute18              =>x_val_attribute18
  ,p_val_attribute19              =>x_val_attribute19
  ,p_val_attribute20              =>x_val_attribute20
  ,p_val_information_category     =>x_val_information_category
  ,p_val_information1             =>x_val_information1
  ,p_val_information2             =>x_val_information2
  ,p_val_information3             =>x_val_information3
  ,p_val_information4             =>x_val_information4
  ,p_val_information5             =>x_val_information5
  ,p_val_information6             =>x_val_information6
  ,p_val_information7             =>x_val_information7
  ,p_val_information8             =>x_val_information8
  ,p_val_information9             =>x_val_information9
  ,p_val_information10            =>x_val_information10
  ,p_val_information11            =>x_val_information11
  ,p_val_information12            =>x_val_information12
  ,p_val_information13            =>x_val_information13
  ,p_val_information14            =>x_val_information14
  ,p_val_information15            =>x_val_information15
  ,p_val_information16            =>x_val_information16
  ,p_val_information17            =>x_val_information17
  ,p_val_information18            =>x_val_information18
  ,p_val_information19            =>x_val_information19
  ,p_val_information20            =>x_val_information20
  ,p_fuel_benefit                 =>x_fuel_benefit
  ,p_user_info                    =>x_user_info
  ,p_vehicle_repository_id        =>x_vehicle_repository_id
  ,p_vehicle_allocation_id        =>x_vehicle_allocation_id
  ,p_object_version_number        =>x_object_version_number
  ,p_error_message                =>l_error_message
  ,p_error_status                 =>l_error_status
  );
  hr_utility.set_location('Leaving val_create_vehicle_details:',20);
  exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
   rollback to savepoint pqp_vehicle_validate;
    --
    -- Reset IN OUT parameters and set OUT parameters
    x_error_status := hr_multi_message.get_return_status_disable;

    hr_utility.set_location(' Leaving:' ,40);
     when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
   rollback to savepoint pqp_vehicle_validate;
   if hr_multi_message.unexpected_error_add('l_proc') then
       --raise;
    x_error_status := hr_multi_message.get_return_status_disable;
    end if;
     -- Reset IN OUT parameters and set OUT parameters

    x_error_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || 'l_proc',50);
    --raise;
    hr_utility.set_location('Leaving validation :',30);
 END;
-- If there are no error messages then insert values into transaction table
  SAVEPOINT pqp_create_transaction;
  IF x_transaction_id is NULl THEN
   hr_utility.set_location('Entering create_transaction :',10);
   hr_transaction_api.create_transaction(
               p_validate                   => false
              ,p_creator_person_id          =>  x_login_person_id
              ,p_transaction_privilege      => 'PRIVATE'
              ,p_product_code               => 'PQP'
              ,p_url                        => NULL
              ,p_status                     => x_status
              ,p_section_display_name       =>NULL
              ,p_function_id                =>NULL
              ,p_transaction_ref_table      =>NULL
              ,p_transaction_ref_id         =>NULL
              ,p_transaction_type           =>NULL
              ,p_assignment_id              =>x_assignment_id
              ,p_selected_person_id         =>x_person_id
              ,p_item_type                  =>x_item_type
              ,p_item_key                   =>x_item_key
              ,p_transaction_effective_date =>x_effective_date
              ,p_process_name               =>NULL
              ,p_plan_id                    =>NULL
              ,p_rptg_grp_id                =>NULL
              ,p_effective_date_option      =>x_effective_date_option
              ,p_transaction_id             =>l_transaction_id
              );

   hr_utility.set_location('Leaving create_transaction :',15);
   wf_engine.setitemattrnumber
             (itemtype => x_item_type
             ,itemkey  => x_item_key
             ,aname    => 'TRANSACTION_ID'
             ,avalue   => l_transaction_id
             );

              x_transaction_id         :=  l_transaction_id;
   hr_utility.set_location('Leaving setitemattrnumber :',20);
 --Create transaction steps
   hr_transaction_api.create_transaction_step
              (p_validate                   =>false
              ,p_creator_person_id          =>x_login_person_id
              ,p_transaction_id             =>l_transaction_id
              ,p_api_name                   =>l_api_name
              ,p_api_display_name           =>l_api_name
              ,p_item_type                  =>x_item_type
              ,p_item_key                   =>x_item_key
              ,p_activity_id                =>x_activity_id
              ,p_transaction_step_id        =>l_transaction_step_id
              ,p_object_version_number      =>l_ovn
             );
   hr_utility.set_location('Leaving create_transaction_step :',25);
  ELSE
   hr_utility.set_location('Entering update transaction :',10);
   hr_transaction_api.update_transaction
           (p_transaction_id => x_transaction_id
            ,p_status         => x_status
           );
   hr_utility.set_location('leaving update transaction :',15);
   OPEN c_del_values;
   FETCH c_del_values INTO l_del_values;
   CLOSE c_del_values;

   hr_utility.set_location('leaving c del value :',20);
   DELETE from hr_api_transaction_values
     WHERE transaction_step_id = l_del_values.transaction_step_id;
   l_transaction_step_id := l_del_values.transaction_step_id;
   hr_utility.set_location('leaving delete :',25);
  END IF;
  FOR i in 1..l_trans_tbl.count
   LOOP
    IF l_trans_tbl(i).param_data_type ='VARCHAR2' THEN
     hr_utility.set_location('Enter varchar param||l_trans_tbl (i).param_name :',10);
     hr_utility.set_location('Enter varchar param value||l_trans_tbl (i).param_value :',10);
     hr_transaction_api.set_varchar2_value
       (p_transaction_step_id  =>l_transaction_step_id
       ,p_person_id            =>x_person_id
       ,p_name                 =>l_trans_tbl (i).param_name
       ,p_value                =>l_trans_tbl (i).param_value
       );
     hr_utility.set_location('Leaving param data type :',20);

    ELSIF  l_trans_tbl(i).param_data_type ='DATE' THEN
     hr_utility.set_location('Enter date Param||l_trans_tbl (i).param_name :',10);
     hr_utility.set_location('Enter date Param Value||
                             l_trans_tbl (i).param_value :',10);
     hr_transaction_api.set_date_value
        (
        p_transaction_step_id  => l_transaction_step_id
       ,p_person_id            => x_person_id
       ,p_name                 => l_trans_tbl (i).param_name
       ,p_value                => fnd_date.displaydate_to_date(l_trans_tbl (i)
                                  .param_value ) );
     hr_utility.set_location('Leaving param date  :',20);
    ELSIF  l_trans_tbl(i).param_data_type ='NUMBER' THEN
     hr_utility.set_location('Enter number param||l_trans_tbl (i).param_name :',10);
     hr_utility.set_location('Enter number param value||l_trans_tbl (i).param_value :',10);
     hr_transaction_api.set_number_value
        (
        p_transaction_step_id       => l_transaction_step_id
       ,p_person_id                 => x_person_id
       ,p_name                      =>l_trans_tbl (i).param_name
       ,p_value                     =>TO_NUMBER(l_trans_tbl (i).param_value ));
     hr_utility.set_location('Leaving param number  :',20);
    END IF;
   END LOOP;


  ---Set Global value to open extra info page
   set_extra_info_val  (
      itemtype        =>x_item_type,
      itemkey         =>x_item_key,
      result          =>l_sec_result );
  EXCEPTION
  WHEN hr_multi_message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
   ROLLBACK TO SAVEPOINT pqp_vehicle_proc_start;
    --
    -- Reset IN OUT parameters and set OUT parameters
    x_error_status := hr_multi_message.get_return_status_disable;

    hr_utility.set_location(' Leaving:' ,40);
     WHEN others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
   ROLLBACK TO SAVEPOINT pqp_vehicle_proc_start;
   IF hr_multi_message.unexpected_error_add('l_proc') then
       --raise;
    x_error_status := hr_multi_message.get_return_status_disable;
   END IF;
     -- Reset IN OUT parameters and set OUT parameters

    x_error_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || 'l_proc',50);
    --raise;





END;
--
--not used at the moment

PROCEDURE delete_process_api (
   p_validate                   IN BOOLEAN DEFAULT FALSE,
   p_transaction_step_id        IN NUMBER,
   p_effective_date             IN VARCHAR2 DEFAULT NULL ) IS
--
--
l_ovn                  NUMBER :=1;
l_error_status         VARCHAR2(10);
l_effective_start_date DATE;
l_effective_end_date   DATE;
l_person_id            per_all_people_f.person_id%TYPE;
l_assignment_id        per_all_assignments_f.assignment_id%TYPE;
l_business_group_id    per_all_assignments_f.business_group_id%TYPE;
l_allocation_id        pqp_vehicle_allocations_f.vehicle_allocation_id%TYPE;
l_effective_date       DATE;
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
l_allocation_id                     :=hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_ALLOCATION_ID' );




  delete_process (
    p_validate               => false
   ,p_effective_date         => l_effective_date
   ,p_person_id              => l_person_id
   ,p_assignment_id          => l_assignment_id
   ,p_business_group_id      => l_business_group_id
   ,p_vehicle_allocation_id  => l_allocation_id
   ,p_error_status           => l_error_status
                 );

 --  EXCEPTION
   -- WHEN hr_utility.hr_error THEN
  	--hr_utility.raise_error;
  --  WHEN OTHERS THEN
  --      RAISE;  -- Raise error here relevant to the new tech stack.

END;

--This process is called when the transaction is approved and
--the information is created in the base tables.
PROCEDURE process_api (
   p_validate			IN BOOLEAN DEFAULT FALSE,
   p_transaction_step_id	IN NUMBER,
   p_effective_date             IN VARCHAR2 DEFAULT NULL ) IS
--
--
l_person_id	               	   NUMBER;
l_ovn			           NUMBER :=1;
l_assignment_id                    NUMBER;
l_effective_date                   DATE;
l_registration_number              pqp_vehicle_repository_f.registration_number%TYPE;
l_vehicle_type                     pqp_vehicle_repository_f.vehicle_type%TYPE;
l_vehicle_id_number                pqp_vehicle_repository_f.vehicle_id_number%TYPE;
l_business_group_id                pqp_vehicle_repository_f.business_group_id%TYPE;
l_make                             pqp_vehicle_repository_f.make%TYPE;
l_engine_capacity_in_cc            pqp_vehicle_repository_f.engine_capacity_in_cc%TYPE;
l_fuel_type                        pqp_vehicle_repository_f.fuel_type%TYPE;
l_currency_code                    pqp_vehicle_repository_f.currency_code%TYPE;
l_model                            pqp_vehicle_repository_f.model%TYPE;
l_initial_registration             pqp_vehicle_repository_f.initial_registration%TYPE;
l_last_registration_renew_date     pqp_vehicle_repository_f.last_registration_renew_date%TYPE;
l_fiscal_ratings                   pqp_vehicle_repository_f.fiscal_ratings%TYPE;
l_vehicle_ownership                pqp_vehicle_repository_f.vehicle_ownership%TYPE;
l_shared_vehicle                   pqp_vehicle_repository_f.shared_vehicle%TYPE;
l_color                            pqp_vehicle_repository_f.color%TYPE;
l_seating_capacity                 pqp_vehicle_repository_f.seating_capacity%TYPE;
l_weight                           pqp_vehicle_repository_f.weight%TYPE;
l_weight_uom                       pqp_vehicle_repository_f.weight_uom%TYPE;
l_model_year                       pqp_vehicle_repository_f.model_year%TYPE;
l_insurance_number                 pqp_vehicle_repository_f.insurance_number%TYPE;
l_insurance_expiry_date            pqp_vehicle_repository_f.insurance_expiry_date%TYPE;
l_taxation_method                  pqp_vehicle_repository_f.taxation_method%TYPE;
l_comments                         pqp_vehicle_repository_f.comments%TYPE;
l_vre_attribute_category           pqp_vehicle_repository_f.vre_attribute_category%TYPE;
l_vre_attribute1                   pqp_vehicle_repository_f.vre_attribute1%TYPE;
l_vre_attribute2                   pqp_vehicle_repository_f.vre_attribute2%TYPE;
l_vre_attribute3                   pqp_vehicle_repository_f.vre_attribute3%TYPE;
l_vre_attribute4                   pqp_vehicle_repository_f.vre_attribute4%TYPE;
l_vre_attribute5                   pqp_vehicle_repository_f.vre_attribute5%TYPE;
l_vre_attribute6                   pqp_vehicle_repository_f.vre_attribute6%TYPE;
l_vre_attribute7                   pqp_vehicle_repository_f.vre_attribute7%TYPE;
l_vre_attribute8                   pqp_vehicle_repository_f.vre_attribute8%TYPE;
l_vre_attribute9                   pqp_vehicle_repository_f.vre_attribute9%TYPE;
l_vre_attribute10                  pqp_vehicle_repository_f.vre_attribute10%TYPE;
l_vre_attribute11                  pqp_vehicle_repository_f.vre_attribute11%TYPE;
l_vre_attribute12                  pqp_vehicle_repository_f.vre_attribute12%TYPE;
l_vre_attribute13                  pqp_vehicle_repository_f.vre_attribute13%TYPE;
l_vre_attribute14                  pqp_vehicle_repository_f.vre_attribute14%TYPE;
l_vre_attribute15                  pqp_vehicle_repository_f.vre_attribute15%TYPE;
l_vre_attribute16                  pqp_vehicle_repository_f.vre_attribute16%TYPE;
l_vre_attribute17                  pqp_vehicle_repository_f.vre_attribute17%TYPE;
l_vre_attribute18                  pqp_vehicle_repository_f.vre_attribute18%TYPE;
l_vre_attribute19                  pqp_vehicle_repository_f.vre_attribute19%TYPE;
l_vre_attribute20                  pqp_vehicle_repository_f.vre_attribute20%TYPE;
l_vre_information_category         pqp_vehicle_repository_f.vre_information_category%TYPE;
l_vre_information1                 pqp_vehicle_repository_f.vre_information1%TYPE;
l_vre_information2                 pqp_vehicle_repository_f.vre_information2%TYPE;
l_vre_information3                 pqp_vehicle_repository_f.vre_information3%TYPE;
l_vre_information4                 pqp_vehicle_repository_f.vre_information4%TYPE;
l_vre_information5                 pqp_vehicle_repository_f.vre_information5%TYPE;
l_vre_information6                 pqp_vehicle_repository_f.vre_information6%TYPE;
l_vre_information7                 pqp_vehicle_repository_f.vre_information7%TYPE;
l_vre_information8                 pqp_vehicle_repository_f.vre_information8%TYPE;
l_vre_information9                 pqp_vehicle_repository_f.vre_information9%TYPE;
l_vre_information10                pqp_vehicle_repository_f.vre_information10%TYPE;
l_vre_information11                pqp_vehicle_repository_f.vre_information11%TYPE;
l_vre_information12                pqp_vehicle_repository_f.vre_information12%TYPE;
l_vre_information13                pqp_vehicle_repository_f.vre_information13%TYPE;
l_vre_information14                pqp_vehicle_repository_f.vre_information14%TYPE;
l_vre_information15                pqp_vehicle_repository_f.vre_information15%TYPE;
l_vre_information16                pqp_vehicle_repository_f.vre_information16%TYPE;
l_vre_information17                pqp_vehicle_repository_f.vre_information17%TYPE;
l_vre_information18                pqp_vehicle_repository_f.vre_information18%TYPE;
l_vre_information19                pqp_vehicle_repository_f.vre_information19%TYPE;
l_vre_information20                pqp_vehicle_repository_f.vre_information20%TYPE;
l_across_assignments               pqp_vehicle_allocations_f.across_assignments%TYPE;
l_usage_type                       pqp_vehicle_allocations_f.usage_type%TYPE;
l_default_vehicle                  pqp_vehicle_allocations_f.default_vehicle%TYPE;
l_fuel_card                        pqp_vehicle_allocations_f.fuel_card%TYPE;
l_fuel_card_number                 pqp_vehicle_allocations_f.fuel_card_number%TYPE;
l_val_attribute_category           pqp_vehicle_allocations_f.val_attribute_category%TYPE;
l_val_attribute1                   pqp_vehicle_allocations_f.val_attribute1%TYPE;
l_val_attribute2                   pqp_vehicle_allocations_f.val_attribute2%TYPE;
l_val_attribute3                   pqp_vehicle_allocations_f.val_attribute3%TYPE;
l_val_attribute4                   pqp_vehicle_allocations_f.val_attribute4%TYPE;
l_val_attribute5                   pqp_vehicle_allocations_f.val_attribute5%TYPE;
l_val_attribute6                   pqp_vehicle_allocations_f.val_attribute6%TYPE;
l_val_attribute7                   pqp_vehicle_allocations_f.val_attribute7%TYPE;
l_val_attribute8                   pqp_vehicle_allocations_f.val_attribute8%TYPE;
l_val_attribute9                   pqp_vehicle_allocations_f.val_attribute9%TYPE;
l_val_attribute10                  pqp_vehicle_allocations_f.val_attribute10%TYPE;
l_val_attribute11                  pqp_vehicle_allocations_f.val_attribute11%TYPE;
l_val_attribute12                  pqp_vehicle_allocations_f.val_attribute12%TYPE;
l_val_attribute13                  pqp_vehicle_allocations_f.val_attribute13%TYPE;
l_val_attribute14                  pqp_vehicle_allocations_f.val_attribute14%TYPE;
l_val_attribute15                  pqp_vehicle_allocations_f.val_attribute15%TYPE;
l_val_attribute16                  pqp_vehicle_allocations_f.val_attribute16%TYPE;
l_val_attribute17                  pqp_vehicle_allocations_f.val_attribute17%TYPE;
l_val_attribute18                  pqp_vehicle_allocations_f.val_attribute18%TYPE;
l_val_attribute19                  pqp_vehicle_allocations_f.val_attribute19%TYPE;
l_val_attribute20                  pqp_vehicle_allocations_f.val_attribute20%TYPE;
l_val_information_category         pqp_vehicle_allocations_f.val_information_category%TYPE;
l_val_information1                 pqp_vehicle_allocations_f.val_information1%TYPE;
l_val_information2                 pqp_vehicle_allocations_f.val_information2%TYPE;
l_val_information3                 pqp_vehicle_allocations_f.val_information3%TYPE;
l_val_information4                 pqp_vehicle_allocations_f.val_information4%TYPE;
l_val_information5                 pqp_vehicle_allocations_f.val_information5%TYPE;
l_val_information6                 pqp_vehicle_allocations_f.val_information6%TYPE;
l_val_information7                 pqp_vehicle_allocations_f.val_information7%TYPE;
l_val_information8                 pqp_vehicle_allocations_f.val_information8%TYPE;
l_val_information9                 pqp_vehicle_allocations_f.val_information9%TYPE;
l_val_information10                pqp_vehicle_allocations_f.val_information10%TYPE;
l_val_information11                pqp_vehicle_allocations_f.val_information11%TYPE;
l_val_information12                pqp_vehicle_allocations_f.val_information12%TYPE;
l_val_information13                pqp_vehicle_allocations_f.val_information13%TYPE;
l_val_information14                pqp_vehicle_allocations_f.val_information14%TYPE;
l_val_information15                pqp_vehicle_allocations_f.val_information15%TYPE;
l_val_information16                pqp_vehicle_allocations_f.val_information16%TYPE;
l_val_information17                pqp_vehicle_allocations_f.val_information17%TYPE;
l_val_information18                pqp_vehicle_allocations_f.val_information18%TYPE;
l_val_information19                pqp_vehicle_allocations_f.val_information19%TYPE;
l_val_information20                pqp_vehicle_allocations_f.val_information20%TYPE;
l_fuel_benefit                     pqp_vehicle_allocations_f.fuel_benefit%TYPE;
l_object_version_number            NUMBER;
l_error_message                    VARCHAr2(80);
l_error_status                     VARCHAr2(30);
l_vehicle_allocation_id            NUMBER;
l_vehicle_repository_id            NUMBER;
l_user_info                        t_user_info;
l_get_count                        NUMBER;
l_transaction_id                   NUMBER;
CURSOR c_get_count
IS
SELECT count(hatv.name)
  FROM hr_api_transaction_values hatv
 WHERE hatv.transaction_step_id=p_transaction_step_id
   AND hatv.name like 'P_PERSON_USR_ID%';
--
--
--
--
p_user_info     t_user_info;
CURSOR c_get_other_tstep
IS
SELECT hats.item_type,hats.item_key
  FROM hr_api_transaction_steps hats
 WHERE hats.transaction_id=l_transaction_id
   AND hats.transaction_step_id =p_transaction_step_id;

l_get_other_tstep  c_get_other_tstep%ROWTYPE;
  CURSOR c_get_details IS
SELECT pvr.vehicle_repository_id
       ,pva.vehicle_allocation_id
  FROM pqp_vehicle_repository_f pvr
       ,pqp_vehicle_allocations_f pva
 WHERE pvr.vehicle_repository_id =pva.vehicle_repository_id
   AND pva.assignment_id =l_assignment_id
   AND NVL(l_effective_date,SYSDATE) BETWEEN pvr.effective_start_date
                            AND pvr.effective_end_date
   AND NVL(l_effective_date,sysdate) BETWEEN pva.effective_start_date
                            AND pva.effective_end_date
                            AND pvr.registration_number=l_registration_number;
l_get_details c_get_details%ROWTYPE;
BEGIN
--  hr_utility.trace_on(NULL,'gattu');
  hr_utility.set_location('Entering:process_api',5);
  hr_utility.set_location('  p_transaction_step_id'||  p_transaction_step_id,5);

  --
  savepoint  process_veh_details;
  --
 l_transaction_id :=get_transaction_id(
                     p_transaction_step_id =>p_transaction_step_id);


 l_person_id                       :=  hr_transaction_api.get_number_value (
                                         p_transaction_step_id   => p_transaction_step_id,
                                         p_name                  =>'P_PERSON_ID' );


l_effective_date                    :=  hr_transaction_api.get_date_value (
                                         p_transaction_step_id   => p_transaction_step_id,
                                         p_name                  =>'P_EFFECTIVE_DATE' );

l_registration_number               :=  hr_transaction_api.get_varchar2_value (
                                          p_transaction_step_id   => p_transaction_step_id,
                                          p_name                  =>'P_REGISTRATION_NUMBER' );

l_vehicle_type                      :=  hr_transaction_api.get_varchar2_value (
                                          p_transaction_step_id   => p_transaction_step_id,
                                          p_name                  =>'P_VEHICLE_TYPE' );

l_vehicle_id_number                 :=  hr_transaction_api.get_varchar2_value (
                                          p_transaction_step_id   => p_transaction_step_id,
                                          p_name                  =>'P_VEHICLE_ID_NUMBER' );
l_business_group_id                 :=  hr_transaction_api.get_number_value (
                                          p_transaction_step_id   => p_transaction_step_id,
                                          p_name                  =>'P_BUSINESS_GROUP_ID');

l_make                              :=  hr_transaction_api.get_varchar2_value (
                                          p_transaction_step_id   => p_transaction_step_id,
                                          p_name                  =>'P_MAKE' );

l_engine_capacity_in_cc             :=  hr_transaction_api.get_number_value (
                                          p_transaction_step_id  => p_transaction_step_id,
                                          p_name                 =>'P_ENGINE_CAPACITY_IN_CC');

l_fuel_type                         :=  hr_transaction_api.get_varchar2_value (
                                          p_transaction_step_id   => p_transaction_step_id,
                                          p_name                  =>'P_FUEL_TYPE');

l_currency_code                     :=  hr_transaction_api.get_varchar2_value (
                                          p_transaction_step_id   => p_transaction_step_id,
                                          p_name                  =>'P_CURRENCY_CODE');

l_model                             :=  hr_transaction_api.get_varchar2_value (
                                          p_transaction_step_id   => p_transaction_step_id,
                                          p_name                  =>'P_MODEL' );

l_initial_registration              :=  hr_transaction_api.get_date_value (
                                          p_transaction_step_id   => p_transaction_step_id,
                                          p_name                  =>'P_INITIAL_REGISTRATION');

l_last_registration_renew_date      :=  hr_transaction_api.get_date_value (
                                          p_transaction_step_id => p_transaction_step_id,
                                          p_name          =>'P_LAST_REGISTRATION_RENEW_DATE');

l_fiscal_ratings                    :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_FISCAL_RATINGS' );

l_vehicle_ownership                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VEHICLE_OWNERSHIP');

l_shared_vehicle                    :=  hr_transaction_api.get_varchar2_value (
                                           p_transaction_step_id   => p_transaction_step_id,
                                           p_name                  =>'P_SHARED_VEHICLE' );

l_color                             :=  hr_transaction_api.get_varchar2_value (
                                           p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_COLOR' );

l_seating_capacity                  :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_SEATING_CAPACITY' );

l_weight                            :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_WEIGHT' );

l_weight_uom                        :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_WEIGHT_UOM' );

l_model_year                        :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_MODEL_YEAR' );

l_insurance_number                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_INSURANCE_NUMBER' );

l_insurance_expiry_date             :=  hr_transaction_api.get_date_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name              =>'P_INSURANCE_EXPIRY_DATE' );

l_taxation_method                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_TAXATION_METHOD');

l_comments                          :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_COMMENTS' );

l_vre_attribute_category            :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name             =>'P_VRE_ATTRIBUTE_CATEGORY' );

l_vre_attribute1                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE1' );

l_vre_attribute2                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE2' );

l_vre_attribute3                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE3' );

l_vre_attribute4                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE4' );


l_vre_attribute5                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE5' );

l_vre_attribute6                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE6' );

l_vre_attribute7                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE7' );

l_vre_attribute8                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE8' );

l_vre_attribute9                    :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE9' );

l_vre_attribute10                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE10' );

l_vre_attribute11                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE11' );

l_vre_attribute12                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE12' );

l_vre_attribute13                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE13' );

l_vre_attribute14                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE14' );

l_vre_attribute15                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE15' );

l_vre_attribute16                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE16' );

l_vre_attribute17                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE17' );

l_vre_attribute18                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE18' );

l_vre_attribute19                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE19' );

l_vre_attribute20                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_ATTRIBUTE20' );

l_vre_information_category          :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name           =>'P_VRE_INFORMATION_CATEGORY' );

l_vre_information1                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION1' );

l_vre_information2                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION2' );

l_vre_information3                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION3' );

l_vre_information4                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION4' );

l_vre_information5                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION5' );

l_vre_information6                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION6' );

l_vre_information7                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION7' );

l_vre_information8                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION8' );

l_vre_information9                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION9' );

l_vre_information10                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION10' );

l_vre_information11                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION11' );

l_vre_information12                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION12' );

l_vre_information13                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION13' );

l_vre_information14                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION14' );

l_vre_information15                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION15' );

l_vre_information16                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION16' );

l_vre_information17                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION17' );

l_vre_information18                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION18' );


l_vre_information19                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION19' );


l_vre_information20                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VRE_INFORMATION20' );


l_across_assignments               :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_ACROSS_ASSIGNMENTS');


l_usage_type                       :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_USAGE_TYPE');

l_default_vehicle                  :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_DEFAULT_VEHICLE');

l_fuel_card                        :=  hr_transaction_api.get_varchar2_value (
                                           p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_FUEL_CARD');

l_fuel_card_number                 := hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_FUEL_CARD_NUMBER');

l_val_attribute_category           :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name             =>'P_VAL_ATTRIBUTE_CATEGORY');

l_val_attribute1                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE1');

l_val_attribute2                   := hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE2');

l_val_attribute3                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE3');

l_val_attribute4                   := hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE4');

l_val_attribute5                   :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE5');
l_val_attribute6                   :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE6');
l_val_attribute7                   :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE7');
l_val_attribute8                   :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE8');
l_val_attribute9                   :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE9');
l_val_attribute10                  :=hr_transaction_api.get_varchar2_value (
                                           p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE10');
l_val_attribute11                  := hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE11');

l_val_attribute12                  :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE12');
l_val_attribute13                  :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE13');
l_val_attribute14                  :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE14');
l_val_attribute15                  :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE15');
l_val_attribute16                  :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE16');
l_val_attribute17                  :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE17');
l_val_attribute18                  :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE18');
l_val_attribute19                  :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE19');
l_val_attribute20                  :=hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_ATTRIBUTE20');
l_val_information_category         :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name            =>'P_VAL_INFORMATION_CATEGORY');

l_val_information1                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION1');


l_val_information2                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION2');

l_val_information3                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION3');

l_val_information4                 := hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION4');

l_val_information5                 := hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION5');

l_val_information6                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION6');

l_val_information7                 := hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION7');

l_val_information8                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION8');

l_val_information9                 :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION9');

l_val_information10                :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION10');

l_val_information11                :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION11');

l_val_information12                :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION12');

l_val_information13                :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION13');

l_val_information14                :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION14');

l_val_information15                :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION15');

l_val_information16                :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION16');

l_val_information17                :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION17');

l_val_information18                :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION18');

l_val_information19                :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION19');

l_val_information20                := hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_VAL_INFORMATION20');

l_fuel_benefit                     :=  hr_transaction_api.get_varchar2_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name                  =>'P_FUEL_BENEFIT');


l_vehicle_repository_id            :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name             =>'P_VEHICLE_REPOSITORY_ID');
l_vehicle_allocation_id            :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name             =>'P_VEHICLE_ALLOCATION_ID');
l_object_version_number            :=  hr_transaction_api.get_number_value (
                                            p_transaction_step_id   => p_transaction_step_id,
                                            p_name              =>'P_OBJECT_VERSION_NUMBER');


 OPEN c_get_count;
  FETCH c_get_count INTO l_get_count;
 CLOSE c_get_count;

FOR i in 1..l_get_count
 LOOP
  l_user_info (i).person_id :=hr_transaction_api.get_number_value (
                                   p_transaction_step_id   => p_transaction_step_id,
                                   p_name                  =>'P_PERSON_USR_ID'||i);

  l_user_info (i).assignment_id :=hr_transaction_api.get_number_value (
                                   p_transaction_step_id   => p_transaction_step_id,
                                   p_name                  =>'P_ASSIGNMENT_USR_ID'||i);


  l_user_info (i).user_type :=hr_transaction_api.get_varchar2_value (
                                   p_transaction_step_id   => p_transaction_step_id,
                                   p_name                  =>'P_USER_TYPE'||i);


 END LOOP;




 create_vehicle_details
  (
   p_validate                     => false
  ,p_effective_date               => l_effective_date
  ,p_registration_number          =>l_registration_number
  ,p_vehicle_type                 =>l_vehicle_type
  ,p_vehicle_id_number            =>l_vehicle_id_number
  ,p_business_group_id            =>l_business_group_id
  ,p_make                         =>l_make
  ,p_engine_capacity_in_cc        =>l_engine_capacity_in_cc
  ,p_fuel_type                    =>l_fuel_type
  ,p_currency_code                =>l_currency_code
  ,p_model                        =>l_model
  ,p_initial_registration         =>l_initial_registration
  ,p_last_registration_renew_date =>l_last_registration_renew_date
  ,p_fiscal_ratings               =>l_fiscal_ratings
  ,p_vehicle_ownership            =>l_vehicle_ownership
  ,p_shared_vehicle               =>l_shared_vehicle
  ,p_color                        =>l_color
  ,p_seating_capacity             =>l_seating_capacity
  ,p_weight                       =>l_weight
  ,p_weight_uom                   =>l_weight_uom
  ,p_model_year                   =>l_model_year
  ,p_insurance_number             =>l_insurance_number
  ,p_insurance_expiry_date        =>l_insurance_expiry_date
  ,p_taxation_method              =>l_taxation_method
  ,p_comments                     =>l_comments
  ,p_vre_attribute_category       =>l_vre_attribute_category
  ,p_vre_attribute1               =>l_vre_attribute1
  ,p_vre_attribute2               =>l_vre_attribute2
  ,p_vre_attribute3               =>l_vre_attribute3
  ,p_vre_attribute4               =>l_vre_attribute4
  ,p_vre_attribute5               =>l_vre_attribute5
  ,p_vre_attribute6               =>l_vre_attribute6
  ,p_vre_attribute7               =>l_vre_attribute7
  ,p_vre_attribute8               =>l_vre_attribute8
  ,p_vre_attribute9               =>l_vre_attribute9
  ,p_vre_attribute10              =>l_vre_attribute10
  ,p_vre_attribute11              =>l_vre_attribute11
  ,p_vre_attribute12              =>l_vre_attribute12
  ,p_vre_attribute13              =>l_vre_attribute13
  ,p_vre_attribute14              =>l_vre_attribute14
  ,p_vre_attribute15              =>l_vre_attribute15
  ,p_vre_attribute16              =>l_vre_attribute16
  ,p_vre_attribute17              =>l_vre_attribute17
  ,p_vre_attribute18              =>l_vre_attribute18
  ,p_vre_attribute19              =>l_vre_attribute19
  ,p_vre_attribute20              =>l_vre_attribute20
  ,p_vre_information_category     =>l_vre_information_category
  ,p_vre_information1             =>l_vre_information1
  ,p_vre_information2             =>l_vre_information2
  ,p_vre_information3             =>l_vre_information3
  ,p_vre_information4             =>l_vre_information4
  ,p_vre_information5             =>l_vre_information5
  ,p_vre_information6             =>l_vre_information6
  ,p_vre_information7             =>l_vre_information7
  ,p_vre_information8             =>l_vre_information8
  ,p_vre_information9             =>l_vre_information9
  ,p_vre_information10            =>l_vre_information10
  ,p_vre_information11            =>l_vre_information11
  ,p_vre_information12            =>l_vre_information12
  ,p_vre_information13            =>l_vre_information13
  ,p_vre_information14            =>l_vre_information14
  ,p_vre_information15            =>l_vre_information15
  ,p_vre_information16            =>l_vre_information16
  ,p_vre_information17            =>l_vre_information17
  ,p_vre_information18            =>l_vre_information18
  ,p_vre_information19            =>l_vre_information19
  ,p_vre_information20            =>l_vre_information20
  ,p_across_assignments           =>l_across_assignments
  ,p_usage_type                   =>l_usage_type
  ,p_default_vehicle              =>l_default_vehicle
  ,p_fuel_card                    =>l_fuel_card
  ,p_fuel_card_number             =>l_fuel_card_number
  ,p_val_attribute_category       =>l_val_attribute_category
  ,p_val_attribute1               =>l_val_attribute1
  ,p_val_attribute2               =>l_val_attribute2
  ,p_val_attribute3               =>l_val_attribute3
  ,p_val_attribute4               =>l_val_attribute4
  ,p_val_attribute5               =>l_val_attribute5
  ,p_val_attribute6               =>l_val_attribute6
  ,p_val_attribute7               =>l_val_attribute7
  ,p_val_attribute8               =>l_val_attribute8
  ,p_val_attribute9               =>l_val_attribute9
  ,p_val_attribute10              =>l_val_attribute10
  ,p_val_attribute11              =>l_val_attribute11
  ,p_val_attribute12              =>l_val_attribute12
  ,p_val_attribute13              =>l_val_attribute13
  ,p_val_attribute14              =>l_val_attribute14
  ,p_val_attribute15              =>l_val_attribute15
  ,p_val_attribute16              =>l_val_attribute16
  ,p_val_attribute17              =>l_val_attribute17
  ,p_val_attribute18              =>l_val_attribute18
  ,p_val_attribute19              =>l_val_attribute19
  ,p_val_attribute20              =>l_val_attribute20
  ,p_val_information_category     =>l_val_information_category
  ,p_val_information1             =>l_val_information1
  ,p_val_information2             =>l_val_information2
  ,p_val_information3             =>l_val_information3
  ,p_val_information4             =>l_val_information4
  ,p_val_information5             =>l_val_information5
  ,p_val_information6             =>l_val_information6
  ,p_val_information7             =>l_val_information7
  ,p_val_information8             =>l_val_information8
  ,p_val_information9             =>l_val_information9
  ,p_val_information10            =>l_val_information10
  ,p_val_information11            =>l_val_information11
  ,p_val_information12            =>l_val_information12
  ,p_val_information13            =>l_val_information13
  ,p_val_information14            =>l_val_information14
  ,p_val_information15            =>l_val_information15
  ,p_val_information16            =>l_val_information16
  ,p_val_information17            =>l_val_information17
  ,p_val_information18            =>l_val_information18
  ,p_val_information19            =>l_val_information19
  ,p_val_information20            =>l_val_information20
  ,p_fuel_benefit                 =>l_fuel_benefit
  ,p_user_info                    =>l_user_info
  ,p_vehicle_repository_id        =>l_vehicle_repository_id
  ,p_vehicle_allocation_id        =>l_vehicle_allocation_id
  ,p_object_version_number        =>l_object_version_number
  ,p_error_message                =>l_error_message
  ,p_error_status                 =>l_error_status
  );
  l_assignment_id:=l_user_info(1).assignment_id;
  OPEN c_get_other_tstep;
  LOOP
   FETCH c_get_other_tstep INTO l_get_other_tstep;
   EXIT WHEN c_get_other_tstep%NOTFOUND;


  END LOOP;
 CLOSE c_get_other_tstep;

  OPEN c_get_details;
    FETCH c_get_details INTO l_get_details;
        CLOSE c_get_details;

  wf_engine.SetItemAttrNumber(        itemtype =>l_get_other_tstep.item_type,
                            itemkey =>l_get_other_tstep.item_key,
                            aname =>'PQP_VEH_REPOSITORY_ID_ATTR',
                            avalue =>l_get_details.vehicle_repository_id);

     wf_engine.SetItemAttrNumber(        itemtype =>l_get_other_tstep.item_type,
                            itemkey =>l_get_other_tstep.item_key,
                            aname =>'PQP_VEH_ALLOCATION_ID_ATTR',
                            avalue =>l_get_details.vehicle_allocation_id);

  --
  --
  --
  hr_utility.set_location('Leaving: process_api',10);
--hr_utility.trace_off;
EXCEPTION
  WHEN hr_utility.hr_error THEN
	ROLLBACK TO process_veh_details;

	hr_utility.raise_error;
  WHEN OTHERS THEN
   RAISE;  -- Raise error here relevant to the new tech stack.
END process_api;

--
---Delete call
PROCEDURE delete_allocation(
   p_validate             IN BOOLEAN
  ,p_effective_date         IN DATE
  ,p_assignment_id          IN NUMBER
  ,p_vehicle_allocation_id  IN NUMBER
  ,p_business_group_id      IN NUMBER
  ,p_error_status           OUT NOCOPY VARCHAR2
                      )

IS

 CURSOR c_get_ovn (cp_allocation_id     NUMBER
                 ,cp_business_group_id NUMBER
                 ,cp_assignment_id     NUMBER
                 ,cp_effective_date    DATE
                 )
IS
SELECT pva.object_version_number
      ,pva.vehicle_repository_id repository_id
  FROM pqp_vehicle_allocations_f pva
 WHERE pva.vehicle_allocation_id =cp_allocation_id
   AND pva.assignment_id =cp_assignment_id
   AND pva.business_group_id =cp_business_group_id
   AND rtrim(ltrim(cp_effective_date)) BETWEEN pva.effective_start_date
                             AND pva.effective_end_date;

CURSOR c_get_tot_users (cp_repository_id     NUMBER
                       ,cp_business_group_id NUMBER
                       ,cp_assignment_id     NUMBER
                       ,cp_effective_date    DATE
                        )
IS
SELECT COUNT(pva.vehicle_repository_id) usr_count
  FROM pqp_vehicle_allocations_f pva
 WHERE pva.vehicle_repository_id = cp_repository_id
   AND pva.business_group_id =cp_business_group_id
   AND pva.assignment_id    = cp_assignment_id
   AND rtrim(ltrim(cp_effective_date)) BETWEEN pva.effective_start_date
                             AND pva.effective_end_date;

CURSOR c_get_rep_ovn (cp_repository_id     NUMBER
                     ,cp_business_group_id NUMBER
                     ,cp_effective_date    DATE
                        )
IS
SELECT pvr.object_version_number ovn
  FROM pqp_vehicle_repository_f pvr
 WHERE pvr.vehicle_repository_id = cp_repository_id
   AND pvr.business_group_id     = cp_business_group_id
   AND rtrim(ltrim(cp_effective_date)) BETWEEN pvr.effective_start_date
                             AND pvr.effective_end_date;

l_get_rep_ovn   c_get_rep_ovn%ROWTYPE;
l_get_ovn       c_get_ovn%ROWTYPE;
l_get_tot_users c_get_tot_users%ROWTYPE;
l_effective_start_date DATE;
l_effective_end_date   DATE;

BEGIN

  hr_utility.set_location('Leaving: process_api',10);


  OPEN c_get_ovn (
                 p_vehicle_allocation_id
                ,p_business_group_id
                ,p_assignment_id
                ,p_effective_date
                 );
  FETCH c_get_ovn INTO l_get_ovn;
 CLOSE c_get_ovn;

 OPEN c_get_tot_users (l_get_ovn.repository_id
                      ,p_business_group_id
                      ,p_assignment_id
                      ,p_effective_date
                      );
  FETCH c_get_tot_users INTO l_get_tot_users;
 CLOSE c_get_tot_users;


--Calling delete api for allocation.
   PQP_VEHICLE_ALLOCATIONS_API.delete_vehicle_allocation(
           p_validate                       => p_validate
          ,p_effective_date                 => ltrim(rtrim(p_effective_date))
          ,p_datetrack_mode                 =>'DELETE'
          ,p_vehicle_allocation_id          =>p_vehicle_allocation_id
          ,p_object_version_number          =>l_get_ovn.object_version_number
          ,p_effective_start_date           =>l_effective_start_date
          ,p_effective_end_date             =>l_effective_end_date
         );

 IF l_get_tot_users.usr_count = 0 THEN
  OPEN c_get_rep_ovn (l_get_ovn.repository_id
                      ,p_business_group_id
                      ,p_effective_date
                      );
   FETCH c_get_rep_ovn INTO l_get_rep_ovn;

  CLOSE c_get_rep_ovn;

--Callin delete api for vehicles.
  pqp_vehicle_repository_api.delete_vehicle
  (p_validate                         =>     p_validate
  ,p_effective_date                   =>     ltrim(rtrim(p_effective_date))
  ,p_datetrack_mode                   =>     'DELETE'
  ,p_vehicle_repository_id            =>     l_get_ovn.repository_id
  ,p_object_version_number            =>     l_get_rep_ovn.ovn
  ,p_effective_start_date             =>     l_effective_start_date
  ,p_effective_end_date               =>     l_effective_end_date
  );
 END IF;

 p_error_status := 'Y';

  EXCEPTION
    WHEN hr_utility.hr_error THEN
       p_error_status := 'N';
  	hr_utility.raise_error;
    WHEN OTHERS THEN
        RAISE;  -- Raise error here relevant to the new tech stack.

END delete_allocation;
END  PQP_SS_VEHICLE_TRANSACTIONS;

/
