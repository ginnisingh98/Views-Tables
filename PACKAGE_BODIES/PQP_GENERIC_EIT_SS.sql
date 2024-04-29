--------------------------------------------------------
--  DDL for Package Body PQP_GENERIC_EIT_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GENERIC_EIT_SS" as
/* $Header: pqpexssvehinfo.pkb 120.0 2005/05/29 02:23:01 appldev noship $ */
--
-- Package Variables
--
-- Package scope global variables.
 l_transaction_table hr_transaction_ss.transaction_table;
 l_count INTEGER := 0;
 l_praddr_ovrlap VARCHAR2(2);
 l_transaction_step_id  hr_api_transaction_steps.transaction_step_id%type;
 l_trs_object_version_number  hr_api_transaction_steps.object_version_number%type;
 g_package      varchar2(31)   := 'PQP_GENERIC_EIT_SS';
 g_data_error            exception;
 l_message_number VARCHAR2(10);
 g_trans_rec_count integer;


--
--
FUNCTION get_ovn ( p_eit_type       in varchar2
                   ,p_extra_info_id in number
                   ,p_key_id        in number
                   )
RETURN number IS
CURSOR c_get_ovn_rep
IS
SELECT pvrei.object_version_number
  FROM pqp_veh_repos_extra_info pvrei
 WHERE pvrei.veh_repos_extra_info_id = p_extra_info_id
   AND pvrei.vehicle_repository_id=p_key_id;

CURSOR c_get_ovn_alloc
IS
SELECT pvaei.object_version_number
  FROM pqp_veh_alloc_extra_info pvaei
 WHERE pvaei.veh_alloc_extra_info_id = p_extra_info_id
   AND pvaei.vehicle_allocation_id=p_key_id;

  l_ovn  pqp_veh_alloc_extra_info.object_version_number%TYPE;
BEGIN
 IF p_eit_type='REPOSITORY' THEN
  OPEN c_get_ovn_rep;
  FETCH c_get_ovn_rep INTO l_ovn;
  CLOSE c_get_ovn_rep;
 ELSIF p_eit_type='ALLOCATION' THEN
  OPEN c_get_ovn_alloc;
  FETCH c_get_ovn_alloc INTO l_ovn;
  CLOSE c_get_ovn_alloc;
 END IF;
 RETURN l_ovn;
END;

--This procedure clears delete row data that is just
--created in rthe transaction table and not present
--in the actual tables.
PROCEDURE clear_delete_trans (p_item_type           in     varchar2,
                              p_item_key            in     varchar2,
                              p_transaction_step_id in     number
                             )
IS
BEGIN
 DELETE from hr_api_transaction_values
  WHERE transaction_step_id = p_transaction_step_id;

  DELETE from hr_api_transaction_steps
   WHERE transaction_step_id = p_transaction_step_id;

EXCEPTION
---------
WHEn OTHERS THEN
NULL;
END;


--This procedure is called to create vehicle information in both
--allocation and repository.
PROCEDURE create_generic_eit
  (
   p_validate                 in     boolean default false
  ,p_effective_date           in     date
  ,p_login_person_id          in     number
  ,p_person_id                in     number
  ,p_assignment_id            in     number
  ,p_business_group_id        in     number
  ,p_action                   in     varchar2
  ,p_eit_type                 in     varchar2
  ,p_eit_type_id              in     number
  ,p_information_type         in     varchar2
  ,p_attribute_category       in     varchar2
  ,p_attribute1               in     varchar2
  ,p_attribute2               in     varchar2
  ,p_attribute3               in     varchar2
  ,p_attribute4               in     varchar2
  ,p_attribute5               in     varchar2
  ,p_attribute6               in     varchar2
  ,p_attribute7               in     varchar2
  ,p_attribute8               in     varchar2
  ,p_attribute9               in     varchar2
  ,p_attribute10              in     varchar2
  ,p_attribute11              in     varchar2
  ,p_attribute12              in     varchar2
  ,p_attribute13              in     varchar2
  ,p_attribute14              in     varchar2
  ,p_attribute15              in     varchar2
  ,p_attribute16              in     varchar2
  ,p_attribute17              in     varchar2
  ,p_attribute18              in     varchar2
  ,p_attribute19              in     varchar2
  ,p_attribute20              in     varchar2
  ,p_information_category     in     varchar2
  ,p_information1             in     varchar2
  ,p_information2             in     varchar2
  ,p_information3             in     varchar2
  ,p_information4             in     varchar2
  ,p_information5             in     varchar2
  ,p_information6             in     varchar2
  ,p_information7             in     varchar2
  ,p_information8             in     varchar2
  ,p_information9             in     varchar2
  ,p_information10            in     varchar2
  ,p_information11            in     varchar2
  ,p_information12            in     varchar2
  ,p_information13            in     varchar2
  ,p_information14            in     varchar2
  ,p_information15            in     varchar2
  ,p_information16            in     varchar2
  ,p_information17            in     varchar2
  ,p_information18            in     varchar2
  ,p_information19            in     varchar2
  ,p_information20            in     varchar2
  ,p_information21            in     varchar2
  ,p_information22            in     varchar2
  ,p_information23            in     varchar2
  ,p_information24            in     varchar2
  ,p_information25            in     varchar2
  ,p_information26            in     varchar2
  ,p_information27            in     varchar2
  ,p_information28            in     varchar2
  ,p_information29            in     varchar2
  ,p_information30            in     varchar2
  ,p_object_version_number    in out nocopy number
  ,p_extra_info_id            in out nocopy number
  ,p_error_message            out    nocopy varchar2
  ,p_error_status             out    nocopy varchar2
   )
IS


l_object_version_number1   NUMBER;
l_object_version_number    NUMBER;
l_vehicle_allocation_id    pqp_vehicle_allocations_f.vehicle_allocation_id%TYPE;
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
 IF p_action = 'NEW_ROW' THEN
  IF  p_eit_type ='REPOSITORY' THEN

   pqp_veh_repos_extra_info_api.create_veh_repos_extra_info
    (p_validate                     => false
    ,p_vehicle_repository_id        => p_eit_type_id
    ,p_information_type             => p_information_type
    ,p_vrei_attribute_category      => p_attribute_category
    ,p_vrei_attribute1              => p_attribute1
    ,p_vrei_attribute2              => p_attribute2
    ,p_vrei_attribute3              => p_attribute3
    ,p_vrei_attribute4              => p_attribute4
    ,p_vrei_attribute5              => p_attribute5
    ,p_vrei_attribute6              => p_attribute6
    ,p_vrei_attribute7              => p_attribute7
    ,p_vrei_attribute8              => p_attribute8
    ,p_vrei_attribute9              => p_attribute9
    ,p_vrei_attribute10             => p_attribute10
    ,p_vrei_attribute11             => p_attribute11
    ,p_vrei_attribute12             => p_attribute12
    ,p_vrei_attribute13             => p_attribute13
    ,p_vrei_attribute14             => p_attribute14
    ,p_vrei_attribute15             => p_attribute15
    ,p_vrei_attribute16             => p_attribute16
    ,p_vrei_attribute17             => p_attribute17
    ,p_vrei_attribute18             => p_attribute18
    ,p_vrei_attribute19             => p_attribute19
    ,p_vrei_attribute20             => p_attribute20
    ,p_vrei_information_category    => p_information_category
    ,p_vrei_information1            => p_information1
    ,p_vrei_information2            => p_information2
    ,p_vrei_information3            => p_information3
    ,p_vrei_information4            => p_information4
    ,p_vrei_information5            => p_information5
    ,p_vrei_information6            => p_information6
    ,p_vrei_information7            => p_information7
    ,p_vrei_information8            => p_information8
    ,p_vrei_information9            => p_information9
    ,p_vrei_information10           => p_information10
    ,p_vrei_information11           => p_information11
    ,p_vrei_information12           => p_information12
    ,p_vrei_information13           => p_information13
    ,p_vrei_information14           => p_information14
    ,p_vrei_information15           => p_information15
    ,p_vrei_information16           => p_information16
    ,p_vrei_information17           => p_information17
    ,p_vrei_information18           => p_information18
    ,p_vrei_information19           => p_information19
    ,p_vrei_information20           => p_information20
    ,p_vrei_information21           => p_information21
    ,p_vrei_information22           => p_information22
    ,p_vrei_information23           => p_information23
    ,p_vrei_information24           => p_information24
    ,p_vrei_information25           => p_information25
    ,p_vrei_information26           => p_information26
    ,p_vrei_information27           => p_information27
    ,p_vrei_information28           => p_information28
    ,p_vrei_information29           => p_information29
    ,p_vrei_information30           => p_information30
    ,p_veh_repos_extra_info_id      => p_extra_info_id
    ,p_object_version_number        => p_object_version_number
    );

   ELSIF p_eit_type= 'ALLOCATION' THEN
     pqp_veh_alloc_extra_info_api.create_veh_alloc_extra_info
    (p_validate                     => false
    ,p_vehicle_allocation_id        => p_eit_type_id
    ,p_information_type             => p_information_type
    ,p_vaei_attribute_category      => p_attribute_category
    ,p_vaei_attribute1              => p_attribute1
    ,p_vaei_attribute2              => p_attribute2
    ,p_vaei_attribute3              => p_attribute3
    ,p_vaei_attribute4              => p_attribute4
    ,p_vaei_attribute5              => p_attribute5
    ,p_vaei_attribute6              => p_attribute6
    ,p_vaei_attribute7              => p_attribute7
    ,p_vaei_attribute8              => p_attribute8
    ,p_vaei_attribute9              => p_attribute9
    ,p_vaei_attribute10             => p_attribute10
    ,p_vaei_attribute11             => p_attribute11
    ,p_vaei_attribute12             => p_attribute12
    ,p_vaei_attribute13             => p_attribute13
    ,p_vaei_attribute14             => p_attribute14
    ,p_vaei_attribute15             => p_attribute15
    ,p_vaei_attribute16             => p_attribute16
    ,p_vaei_attribute17             => p_attribute17
    ,p_vaei_attribute18             => p_attribute18
    ,p_vaei_attribute19             => p_attribute19
    ,p_vaei_attribute20             => p_attribute20
    ,p_vaei_information_category    => p_information_category
    ,p_vaei_information1            => p_information1
    ,p_vaei_information2            => p_information2
    ,p_vaei_information3            => p_information3
    ,p_vaei_information4            => p_information4
    ,p_vaei_information5            => p_information5
    ,p_vaei_information6            => p_information6
    ,p_vaei_information7            => p_information7
    ,p_vaei_information8            => p_information8
    ,p_vaei_information9            => p_information9
    ,p_vaei_information10           => p_information10
    ,p_vaei_information11           => p_information11
    ,p_vaei_information12           => p_information12
    ,p_vaei_information13           => p_information13
    ,p_vaei_information14           => p_information14
    ,p_vaei_information15           => p_information15
    ,p_vaei_information16           => p_information16
    ,p_vaei_information17           => p_information17
    ,p_vaei_information18           => p_information18
    ,p_vaei_information19           => p_information19
    ,p_vaei_information20           => p_information20
    ,p_vaei_information21           => p_information21
    ,p_vaei_information22           => p_information22
    ,p_vaei_information23           => p_information23
    ,p_vaei_information24           => p_information24
    ,p_vaei_information25           => p_information25
    ,p_vaei_information26           => p_information26
    ,p_vaei_information27           => p_information27
    ,p_vaei_information28           => p_information28
    ,p_vaei_information29           => p_information29
    ,p_vaei_information30           => p_information30
    ,p_veh_alloc_extra_info_id      => p_extra_info_id
    ,p_object_version_number        => p_object_version_number
    );

   END IF;
  ELSIF p_action = 'UPDATE_ROW' THEN
   IF p_eit_type= 'REPOSITORY' THEN
    l_object_version_number:=get_ovn
           ( p_eit_type      => p_eit_type
            ,p_extra_info_id => p_extra_info_id
            ,p_key_id        => p_eit_type_id
           );

    pqp_veh_repos_extra_info_api.update_veh_repos_extra_info
    (p_validate                     => false
    ,p_veh_repos_extra_info_id      => p_extra_info_id
    ,p_object_version_number        => l_object_version_number
    ,p_vehicle_repository_id        => p_eit_type_id
    ,p_information_type             => p_information_type
    ,p_vrei_attribute_category      => p_attribute_category
    ,p_vrei_attribute1              => p_attribute1
    ,p_vrei_attribute2              => p_attribute2
    ,p_vrei_attribute3              => p_attribute3
    ,p_vrei_attribute4              => p_attribute4
    ,p_vrei_attribute5              => p_attribute5
    ,p_vrei_attribute6              => p_attribute6
    ,p_vrei_attribute7              => p_attribute7
    ,p_vrei_attribute8              => p_attribute8
    ,p_vrei_attribute9              => p_attribute9
    ,p_vrei_attribute10             => p_attribute10
    ,p_vrei_attribute11             => p_attribute11
    ,p_vrei_attribute12             => p_attribute12
    ,p_vrei_attribute13             => p_attribute13
    ,p_vrei_attribute14             => p_attribute14
    ,p_vrei_attribute15             => p_attribute15
    ,p_vrei_attribute16             => p_attribute16
    ,p_vrei_attribute17             => p_attribute17
    ,p_vrei_attribute18             => p_attribute18
    ,p_vrei_attribute19             => p_attribute19
    ,p_vrei_attribute20             => p_attribute20
    ,p_vrei_information_category    => p_information_category
    ,p_vrei_information1            => p_information1
    ,p_vrei_information2            => p_information2
    ,p_vrei_information3            => p_information3
    ,p_vrei_information4            => p_information4
    ,p_vrei_information5            => p_information5
    ,p_vrei_information6            => p_information6
    ,p_vrei_information7            => p_information7
    ,p_vrei_information8            => p_information8
    ,p_vrei_information9            => p_information9
    ,p_vrei_information10           => p_information10
    ,p_vrei_information11           => p_information11
    ,p_vrei_information12           => p_information12
    ,p_vrei_information13           => p_information13
    ,p_vrei_information14           => p_information14
    ,p_vrei_information15           => p_information15
    ,p_vrei_information16           => p_information16
    ,p_vrei_information17           => p_information17
    ,p_vrei_information18           => p_information18
    ,p_vrei_information19           => p_information19
    ,p_vrei_information20           => p_information20
    ,p_vrei_information21           => p_information21
    ,p_vrei_information22           => p_information22
    ,p_vrei_information23           => p_information23
    ,p_vrei_information24           => p_information24
    ,p_vrei_information25           => p_information25
    ,p_vrei_information26           => p_information26
    ,p_vrei_information27           => p_information27
    ,p_vrei_information28           => p_information28
    ,p_vrei_information29           => p_information29
    ,p_vrei_information30           => p_information30
    );

   ELSIF p_eit_type = 'ALLOCATION' THEN
    l_object_version_number:=get_ovn
           ( p_eit_type      => p_eit_type
            ,p_extra_info_id => p_extra_info_id
            ,p_key_id        => p_eit_type_id
           );
    pqp_veh_alloc_extra_info_api.update_veh_alloc_extra_info
    (p_validate                     => false
    ,p_veh_alloc_extra_info_id      => p_extra_info_id
    ,p_object_version_number        => l_object_version_number
    ,p_vehicle_allocation_id        => p_eit_type_id
    ,p_information_type             => p_information_type
    ,p_vaei_attribute_category      => p_attribute_category
    ,p_vaei_attribute1              => p_attribute1
    ,p_vaei_attribute2              => p_attribute2
    ,p_vaei_attribute3              => p_attribute3
    ,p_vaei_attribute4              => p_attribute4
    ,p_vaei_attribute5              => p_attribute5
    ,p_vaei_attribute6              => p_attribute6
    ,p_vaei_attribute7              => p_attribute7
    ,p_vaei_attribute8              => p_attribute8
    ,p_vaei_attribute9              => p_attribute9
    ,p_vaei_attribute10             => p_attribute10
    ,p_vaei_attribute11             => p_attribute11
    ,p_vaei_attribute12             => p_attribute12
    ,p_vaei_attribute13             => p_attribute13
    ,p_vaei_attribute14             => p_attribute14
    ,p_vaei_attribute15             => p_attribute15
    ,p_vaei_attribute16             => p_attribute16
    ,p_vaei_attribute17             => p_attribute17
    ,p_vaei_attribute18             => p_attribute18
    ,p_vaei_attribute19             => p_attribute19
    ,p_vaei_attribute20             => p_attribute20
    ,p_vaei_information_category    => p_information_category
    ,p_vaei_information1            => p_information1
    ,p_vaei_information2            => p_information2
    ,p_vaei_information3            => p_information3
    ,p_vaei_information4            => p_information4
    ,p_vaei_information5            => p_information5
    ,p_vaei_information6            => p_information6
    ,p_vaei_information7            => p_information7
    ,p_vaei_information8            => p_information8
    ,p_vaei_information9            => p_information9
    ,p_vaei_information10           => p_information10
    ,p_vaei_information11           => p_information11
    ,p_vaei_information12           => p_information12
    ,p_vaei_information13           => p_information13
    ,p_vaei_information14           => p_information14
    ,p_vaei_information15           => p_information15
    ,p_vaei_information16           => p_information16
    ,p_vaei_information17           => p_information17
    ,p_vaei_information18           => p_information18
    ,p_vaei_information19           => p_information19
    ,p_vaei_information20           => p_information20
    ,p_vaei_information21           => p_information21
    ,p_vaei_information22           => p_information22
    ,p_vaei_information23           => p_information23
    ,p_vaei_information24           => p_information24
    ,p_vaei_information25           => p_information25
    ,p_vaei_information26           => p_information26
    ,p_vaei_information27           => p_information27
    ,p_vaei_information28           => p_information28
    ,p_vaei_information29           => p_information29
    ,p_vaei_information30           => p_information30
    );
   END IF;
  ELSIF p_action= 'DELETE_ROW' THEN

   IF  p_eit_type='REPOSITORY' THEN
    l_object_version_number:=get_ovn
           ( p_eit_type      => p_eit_type
            ,p_extra_info_id => p_extra_info_id
            ,p_key_id        => p_eit_type_id
           );
    pqp_veh_repos_extra_info_api.delete_veh_repos_extra_info
    (p_validate                     => false
    ,p_veh_repos_extra_info_id      => p_extra_info_id
    ,p_object_version_number        => l_object_version_number
    );

   ELSIF p_eit_type = 'ALLOCATION' THEN
    l_object_version_number:=get_ovn
           ( p_eit_type      => p_eit_type
            ,p_extra_info_id => p_extra_info_id
            ,p_key_id        => p_eit_type_id
           );
    pqp_veh_alloc_extra_info_api.delete_veh_alloc_extra_info
    (p_validate                     => false
    ,p_veh_alloc_extra_info_id      => p_extra_info_id
    ,p_object_version_number        => l_object_version_number
    );

   END IF;

  END IF;
 EXCEPTION
  WHEN hr_utility.hr_error THEN
   hr_utility.raise_error;
  WHEN OTHERS THEN
   RAISE;  -- Raise error here relevant to the new tech stack.
END;



PROCEDURE set_extra_info
    (p_effective_date            in   DATE
    ,p_person_id                 in   number
    ,p_login_person_id           in   number
    ,p_assignment_id             in   number
    ,p_business_group_id         in   number
    ,p_eit_type	                 in   varchar2
    ,p_eit_type_id	         in   number
    ,p_eit_number	         in   number
    ,p_eit_table	         in   HR_EIT_STRUCTURE_TABLE
    ,p_item_type                 in   varchar2
    ,p_item_key                  in   varchar2
    ,p_activity_id               in   number
    ,p_transaction_step_id       in out nocopy  number
    ,p_error_message             out nocopy  varchar2
    ,p_active_view               in   varchar2
    ,p_active_row_id	         in   number
    ,p_status                    in varchar2
    ,p_key_id                    in VARCHAR2 --this is registration_number
    ,p_flow_mode                 in   varchar2 default null
  ) is
  l_transaction_id             NUMBER DEFAULT NULL;
  l_trans_obj_vers_num         NUMBER DEFAULT NULL;
  l_trans_step_rows	       NUMBER DEFAULT NULL;
  l_result                     VARCHAR2(100) DEFAULT NULL;
  l_count                      NUMBER DEFAULT 0;
  l_transaction_table          hr_transaction_ss.transaction_table;
  l_review_item_name           VARCHAR2(50);
  l_eit_number                 NUMBER := 0;
  l_object_version_number      NUMBER:=1;
  l_api_name                   hr_api_transaction_steps.api_name%TYPE
                               := 'PQP_GENERIC_EIT_SS.PROCESS_API';
  l_review_proc_call           VARCHAR2(30) := 'PqpVehInfoReview';
  l_get_action                 VARCHAR2(30);
  l_extra_info_id            NUMBER;

BEGIN
-- First, check if transaction id exists or not
   l_transaction_id := hr_transaction_ss.get_transaction_id
                       (p_item_type   => p_item_type
                       ,p_item_key    => p_item_key);
hr_utility.set_location(' l_transaction_id: '||l_transaction_id,5   );
  --


  --
  -- Create a transaction step
  --

 l_count := 1;
 l_transaction_table(l_count).param_name := 'P_PERSON_ID';
 l_transaction_table(l_count).param_value := p_person_id;
 l_transaction_table(l_count).param_data_type := 'NUMBER';

 l_count := l_count +1;
 l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
 l_transaction_table(l_count).param_value :=fnd_date.displaydate_to_date( p_effective_date);
 l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 l_count := l_count + 1;
 l_transaction_table(l_count).param_name := 'P_LOGIN_PERSON_ID';
 l_transaction_table(l_count).param_value := p_login_person_id;
 l_transaction_table(l_count).param_data_type := 'NUMBER';

 l_count := l_count + 1;
 l_transaction_table(l_count).param_name := 'P_ASSIGNMENT_ID';
 l_transaction_table(l_count).param_value := p_assignment_id;
 l_transaction_table(l_count).param_data_type := 'NUMBER';

 l_count := l_count + 1;
 l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
 l_transaction_table(l_count).param_value := p_business_group_id;
 l_transaction_table(l_count).param_data_type := 'NUMBER';

 l_count := l_count + 1;
 l_transaction_table(l_count).param_name := 'P_EIT_TYPE';
 l_transaction_table(l_count).param_value := p_eit_type;
 l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 l_count := l_count + 1;
 l_transaction_table(l_count).param_name := 'P_EIT_TYPE_ID';
 l_transaction_table(l_count).param_value := p_eit_type_id;
 l_transaction_table(l_count).param_data_type := 'NUMBER';

 l_count := l_count + 1;
 l_transaction_table(l_count).param_name := 'P_EIT_NUMBER';
 l_transaction_table(l_count).param_value := p_eit_number;
 l_transaction_table(l_count).param_data_type := 'NUMBER';

 l_count := l_count + 1;
 l_transaction_table(l_count).param_name := 'P_KEY_ID';
 l_transaction_table(l_count).param_value := p_key_id;
 l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 hr_utility.set_location('..p_login_person_id'||p_login_person_id, 6);
 hr_utility.set_location('..p_assignment_id'||p_assignment_id, 6);
 hr_utility.set_location('..p_eit_type'||p_eit_type, 6);
 hr_utility.set_location('..p_eit_number'||p_eit_number, 6);
 hr_utility.set_location('..p_business_group_id'||p_business_group_id, 6);
 hr_utility.set_location('..p_eit_type_id'||p_eit_type_id, 6);
 hr_utility.set_location('..p_item_type'||p_item_type, 6);
 hr_utility.set_location('..p_item_key'||p_item_key, 6);
 hr_utility.set_location('..p_activity_id'||p_activity_id, 6);


 l_review_item_name :=
   wf_engine.GetActivityAttrText(itemtype  => p_item_type,
                                 itemkey   => p_item_key,
                                 actid     => p_activity_id,
                                 aname     => gv_wf_review_region_item);


 l_count := l_count + 1;
 l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
 l_transaction_table(l_count).param_value := l_review_proc_call;
 l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 hr_utility.set_location('..l_review_item_name'||l_review_item_name, 6);
 hr_utility.set_location('..p_active_view'||p_active_view, 6);
 hr_utility.set_location('..p_active_row_id'||p_active_row_id, 6);


 l_count := l_count + 1;
 l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
 l_transaction_table(l_count).param_value := p_activity_id;
 l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 -- for the update page when we rebuild the page after a
 -- save for later
 l_count := l_count + 1;
 l_transaction_table(l_count).param_name := 'P_ACTIVE_VIEW';
 l_transaction_table(l_count).param_value := p_active_view;
 l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 l_count := l_count + 1;
 l_transaction_table(l_count).param_name := 'P_ACTIVE_ROW_ID';
 l_transaction_table(l_count).param_value := p_active_row_id;
 l_transaction_table(l_count).param_data_type := 'NUMBER';



 l_eit_number := p_eit_number;

 FOR i in 1..l_eit_number
 LOOP

  hr_utility.set_location('..p_eit_table(i).action'||p_eit_table(i).action, 6);
  hr_utility.set_location('..p_eit_table(i).action'||p_eit_table(i).extra_info_id, 6);
  hr_utility.set_location('..p_eit_table(i).object_version_number'||p_eit_table(i).object_version_number, 6);
  hr_utility.set_location('..p_eit_table(i).information_type'||p_eit_table(i).information_type, 6);

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ACTION_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).action;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  l_get_action:=p_eit_table(i).action;
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EXTRA_INFO_ID_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).extra_info_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  l_extra_info_id :=	p_eit_table(i).extra_info_id;
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).object_version_number;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION_TYPE_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

-- Now add all the Descriptive flex fields into transactions tables

  l_count := l_count + 1; -- CONTEXT
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_CATEGORY_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE1_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE2_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE3_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE4_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE5_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE6_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE7_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE8_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE9_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE10_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE11_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE12_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE13_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE14_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE15_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE16_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE17_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE18_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE19_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE20_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).attribute20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

   ---Information Category Context
  hr_utility.set_location('.inside loop '||p_eit_table(i).information_category, 6);
  hr_utility.set_location('.inside loop information1'||p_eit_table(i).information1, 6);
  hr_utility.set_location('.inside loop information1'||p_eit_table(i).information2, 6);

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION_CATEGORY_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION1_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION2_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION3_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION4_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION5_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION6_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION7_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION8_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION9_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION10_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION11_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION12_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION13_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION14_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION15_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION16_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION17_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION18_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION19_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION20_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION21_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION22_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION23_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION24_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION25_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION26_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION27_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION28_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION29_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INFORMATION30_'||i;
  l_transaction_table(l_count).param_value := p_eit_table(i).information20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
     -- EndRegistration
     --
 END LOOP;

 IF l_transaction_id is NULL THEN
  hr_transaction_api.create_transaction(
               p_validate                       =>false
              ,p_creator_person_id              =>p_login_person_id
              ,p_transaction_privilege          =>'PRIVATE'
              ,p_product_code                   =>'PQP'
              ,p_url                            =>NULL
              ,p_status                         =>p_status
              ,p_section_display_name           =>NULL
              ,p_function_id                    =>NULL
              ,p_transaction_ref_table          =>NULL
              ,p_transaction_ref_id             =>NULL
              ,p_transaction_type               =>NULL
              ,p_assignment_id                  =>p_assignment_id
              ,p_selected_person_id             =>p_person_id
              ,p_item_type                      =>p_item_type
              ,p_item_key                       =>p_item_key
              ,p_transaction_effective_date     =>p_effective_date
              ,p_process_name                   =>NULL
              ,p_plan_id                        =>NULL
              ,p_rptg_grp_id                    =>NULL
              ,p_effective_date_option          =>p_effective_date
              ,p_transaction_id                 => l_transaction_id
              );

  wf_engine.setitemattrnumber
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,aname    => 'TRANSACTION_ID'
        ,avalue   => l_transaction_id);
  -- x_transaction_id         :=  l_transaction_id;
 --Create transaction steps
  hr_transaction_api.create_transaction_step
              (p_validate                       =>false
              ,p_creator_person_id              =>p_login_person_id
              ,p_transaction_id                 =>l_transaction_id
              ,p_api_name                       =>l_api_name
              ,p_api_display_name               =>l_api_name
              ,p_item_type                      =>p_item_type
              ,p_item_key                       =>p_item_key
              ,p_activity_id                    =>p_activity_id
              ,p_transaction_step_id            =>l_transaction_step_id
              ,p_object_version_number          =>l_object_version_number
             );
 ELSE
  IF p_transaction_step_id IS NOT NULL AND
   p_transaction_step_id <>0 THEN
   hr_transaction_api.update_transaction
                      (p_transaction_id        =>l_transaction_id
                      ,p_status                =>p_status
                      );
   DELETE from hr_api_transaction_values
    WHERE transaction_step_id = p_transaction_step_id;
    l_transaction_step_id := p_transaction_step_id;
  ELSE
    --l_transaction_step_id := p_transaction_step_id;

    --l_transaction_step_id := p_transaction_step_id;
    l_transaction_step_id:=NULL;

   hr_transaction_api.create_transaction_step
              (p_validate                       =>false
              ,p_creator_person_id              =>p_login_person_id
              ,p_transaction_id                 =>l_transaction_id
              ,p_api_name                       =>l_api_name
              ,p_api_display_name               =>l_api_name
              ,p_item_type                      =>p_item_type
              ,p_item_key                       =>p_item_key
              ,p_activity_id                    =>p_activity_id
             -- ,p_processing_order               =>2
              ,p_transaction_step_id            =>l_transaction_step_id
              ,p_object_version_number          =>l_object_version_number
             );

  END IF;
 END IF;
  FOR i in 1..l_transaction_table.count
   LOOP
    IF l_transaction_table(i).param_data_type ='VARCHAR2' THEN
     hr_transaction_api.set_varchar2_value
        (p_transaction_step_id  => l_transaction_step_id
        ,p_person_id            => p_person_id
        ,p_name                 => l_transaction_table(i).param_name
        ,p_value                =>  l_transaction_table(i).param_value
        );

    ELSIF  l_transaction_table(i).param_data_type ='DATE' THEN
     hr_transaction_api.set_date_value
        (
        p_transaction_step_id  => l_transaction_step_id
        ,p_person_id            => p_person_id
        ,p_name                 => l_transaction_table (i).param_name
        ,p_value                =>fnd_date.displaydate_to_date
                                 (l_transaction_table (i).param_value)  );
       -- ,p_original_value             );


    ELSIF  l_transaction_table(i).param_data_type ='NUMBER' THEN
     hr_transaction_api.set_number_value
        (
        p_transaction_step_id       => l_transaction_step_id
       ,p_person_id                 => p_person_id
       ,p_name                      =>l_transaction_table (i).param_name
       ,p_value                     =>TO_NUMBER(l_transaction_table (i).param_value ));
    END IF;
   END LOOP;

Commit;


--hr_utility.trace_off;
EXCEPTION
  -- Catch any exception thrown while storing transaction data
 WHEN OTHERS THEN
  p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                           p_error_message => p_error_message);




END set_extra_info;






-- ---------------------------------------------------------------------------
-- ---------------------- < get_eit_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a given person id, workflow process name
--          and workflow activity name.  This is the overloaded version.
-- ---------------------------------------------------------------------------
PROCEDURE get_eit_data_from_tt
  (p_item_type                       in            varchar2
  ,p_item_key                        in            varchar2
  ,p_activity_id                     in            number
  ,p_effective_date                  out nocopy    date
  ,p_person_id                       out nocopy    number
  ,p_login_person_id                 out nocopy    number
  ,p_assignment_id                   out nocopy    number
  ,p_business_group_id               out nocopy    number
  ,p_eit_type		             out nocopy    varchar2
  ,p_eit_type_id	             out nocopy    number
  ,p_eit_number		             out nocopy    number
  ,p_key_id		             out nocopy    varchar2
  ,p_eit_table	            	     out nocopy    HR_EIT_STRUCTURE_TABLE
  ,p_error_message                   out nocopy    long
  ,p_active_view               	     out nocopy    varchar2
  ,p_active_row_id		     out nocopy    number
)
IS

  l_transaction_id             number;
  l_trans_step_id              number;
  l_trans_obj_vers_num         number;
  l_count                      number default 0;
  l_trans_rec_count            number;
  l_effective_date             date;

BEGIN

  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the current
  -- transaction. This is used for re-display the Update page when a user
  -- clicks the Back button on the Review page to go back to the Update page
  -- to make further changes or to correct errors.
  -----------------------------------------------------------------------------

  hr_transaction_api.get_transaction_step_info
     (p_item_type              => p_item_type
     ,p_item_key               => p_item_key
     ,p_activity_id            => p_activity_id
     ,p_transaction_step_id    => l_trans_step_id
     ,p_object_version_number  => l_trans_obj_vers_num);


  IF l_trans_step_id IS NOT NULL OR
     l_trans_step_id > 0
  THEN
     l_trans_rec_count := 1;
  ELSE
     l_trans_rec_count := 0;
     return;
  END IF;

  --
  -- -------------------------------------------------------------------
  -- There are some changes made earlier in the transaction.
  -- Retrieve the data and return to caller.
  -- -------------------------------------------------------------------

  -- Now get the transaction data for the given step
  get_eit_data_from_tt
  (p_transaction_step_id       => l_trans_step_id
  ,p_effective_date            => l_effective_date
  ,p_person_id                 => p_person_id
  ,p_login_person_id           => p_login_person_id
  ,p_assignment_id             => p_assignment_id
  ,p_business_group_id         => p_business_group_id
  ,p_eit_type		       => p_eit_type
  ,p_eit_type_id	       => p_eit_type_id
  ,p_eit_number		       => p_eit_number
  ,p_key_id                   =>p_key_id
  ,p_eit_table	       	       => p_eit_table
  ,p_error_message             => p_error_message
  ,p_active_view               => p_active_view
  ,p_active_row_id	       => p_active_row_id
);

  g_trans_rec_count := l_trans_rec_count;

EXCEPTION
  -- Catch any exception thrown while storing transaction data
  WHEN OTHERS THEN
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);


END get_eit_data_from_tt;


-- ---------------------------------------------------------------------------
-- ---------------------- < get_eit_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
-- ---------------------------------------------------------------------------
PROCEDURE get_eit_data_from_tt
  (p_transaction_step_id             in            number
  ,p_effective_date                  out nocopy    date
  ,p_person_id                       out nocopy    number
  ,p_login_person_id                 out nocopy    number
  ,p_assignment_id                   out nocopy    number
  ,p_business_group_id               out nocopy    number
  ,p_eit_type		             out nocopy    varchar2
  ,p_eit_type_id		     out nocopy    number
  ,p_eit_number		             out nocopy    number
  ,p_key_id		             out nocopy    varchar2
  ,p_eit_table	             	     out nocopy    HR_EIT_STRUCTURE_TABLE
  ,p_error_message                   out nocopy    long
  ,p_active_view               	     out nocopy    varchar2
  ,p_active_row_id		     out nocopy    number
)IS

l_number_eit 	NUMBER := 0;
l_eit_table 	HR_EIT_STRUCTURE_TABLE;

BEGIN


 p_effective_date := hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EFFECTIVE_DATE');

 p_person_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERSON_ID');

 p_login_person_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LOGIN_PERSON_ID');

 p_assignment_id := hr_transaction_api.get_number_value
   (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_ID');

 p_business_group_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BUSINESS_GROUP_ID');

 p_eit_type := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EIT_TYPE');

 p_eit_type_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EIT_TYPE_ID');

 p_key_id := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_KEY_ID');

 p_eit_number := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EIT_NUMBER');

 p_active_view := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ACTIVE_VIEW');

 p_active_row_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ACTIVE_ROW_ID');


 l_number_eit := p_eit_number;

 l_eit_table := HR_EIT_STRUCTURE_TABLE();


 FOR i in 1 ..l_number_eit LOOP
--
  l_eit_table.extend;

  --
  l_eit_table(i) := HR_EIT_STRUCTURE_TYPE
  (
-- action
   hr_transaction_api.get_varchar2_value
    	(p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ACTION_'||i)

-- extra info id
   ,hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EXTRA_INFO_ID_'||i)

--object_version_number
   ,hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER_'||i)

--information_type
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION_TYPE_'||i)

--attribute_category
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE_CATEGORY_'||i)

--attribute1
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE1_'||i)

--attribute2
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE2_'||i)

--attribute3
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE3_'||i)

--attribute4
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE4_'||i)

--attribute5
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE5_'||i)

--attribute6
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE6_'||i)

--attribute7
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE7_'||i)

--attribute8
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE8_'||i)

--attribute9
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE9_'||i)

--attribute10
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE10_'||i)

--attribute11
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE11_'||i)

--attribute12
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE12_'||i)

--attribute13
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE13_'||i)

--attribute14
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE14_'||i)

--attribute15
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE15_'||i)

--attribute16
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE16_'||i)

--attribute17
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE17_'||i)

--attribute18
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE18_'||i)

--attribute19
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE19_'||i)

--attribute20
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE20_'||i)

--information_category
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION_CATEGORY_'||i)

--information1
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION1_'||i)

--information2
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION2_'||i)

--information3
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION3_'||i)

--information4
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION4_'||i)

--information5
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION5_'||i)

--information6
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION6_'||i)

--information7
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION7_'||i)

--information8
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION8_'||i)

--information9
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION9_'||i)

--information10
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION10_'||i)

--information11
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION11_'||i)

--information12
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION12_'||i)

--information13
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION13_'||i)

--information14
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION14_'||i)

--information15
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION15_'||i)

--information16
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION16_'||i)

--information17
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION17_'||i)

--information18
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION18_'||i)

--information19
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION19_'||i)

--information20
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION20_'||i)

--information21
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION21_'||i)

--information22
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION22_'||i)

--information23
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION23_'||i)

--information24
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION24_'||i)

--information25
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION25_'||i)

--information26
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION26_'||i)

--information27
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION27_'||i)

--information28
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION28_'||i)

--information29
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION29_'||i)

--information30
   ,hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INFORMATION30_'||i));

 END LOOP;
 p_eit_table := l_eit_table;
 --dump_eit_table(p_eit_table);

EXCEPTION
  -- Catch any exception thrown while storing transaction data
WHEN OTHERS THEN
 p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);

END get_eit_data_from_tt;

PROCEDURE del_transaction_data
    (p_item_type                 in   varchar2
    ,p_item_key                  in   varchar2
    ,p_activity_id               in   varchar2
    ,p_login_person_id           in   varchar2
    ,p_flow_mode                 in   varchar2 default null
) IS

BEGIN


  hr_transaction_ss.delete_transaction_steps(
    p_item_type           => p_item_type
    ,p_item_key           => p_item_key
    ,p_actid              => p_activity_id
    ,p_login_person_id    => p_login_person_id
  );

END del_transaction_data;

-- ----------------------------------------------------------------------------
-- |----------------------------< process_api >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE PROCESS_API
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
        ,p_effective_date      IN VARCHAR2 default null
)IS

l_person_id 		    NUMBER;
l_assignment_id             NUMBER;
l_business_group_id         NUMBER;
l_login_person_id 	    NUMBER;
l_eit_type 		    VARCHAR2(80);
l_eit_type_id 		    NUMBER;
l_eit_number 		    NUMBER;
l_eit_table		    HR_EIT_STRUCTURE_TABLE;
l_extra_info_id             NUMBER;
l_object_version_number     NUMBER;
l_error_message		    LONG;
l_active_view               VARCHAR2(200);
l_active_row_id             NUMBER;
l_index                     NUMBER;
l_effective_date            DATE;
l_key_id                    VARCHAR2(80);
l_error_status              VARCHAR2(100);
l_ignore                    BOOLEAN;
CURSOR c_get_other_tstep
IS
SELECT hats.item_type,hats.item_key
  FROM hr_api_transaction_steps hats
 WHERE  hats.transaction_step_id =p_transaction_step_id;
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
                            AND pvr.registration_number=l_key_id;
l_get_details c_get_details%ROWTYPE;
BEGIN
  --insert session because some flex uses the session effective date.
 IF p_effective_date is not null then
  hr_util_misc_web.insert_session_row(to_date(p_effective_date, 'RRRR-MM-DD'));
 ELSE
  hr_util_misc_web.insert_session_row(SYSDATE);
 END IF;

 get_eit_data_from_tt
   (p_transaction_step_id       => p_transaction_step_id
   ,p_effective_date            => l_effective_date
   ,p_person_id                 => l_person_id
   ,p_login_person_id           => l_login_person_id
   ,p_assignment_id             => l_assignment_id
   ,p_business_group_id         => l_business_group_id
   ,p_eit_type		            => l_eit_type
   ,p_eit_type_id	            => l_eit_type_id
   ,p_eit_number		        => l_eit_number
   ,p_key_id		            => l_key_id
   ,p_eit_table		            => l_eit_table
   ,p_error_message             => l_error_message
   ,p_active_view               => l_active_view
   ,p_active_row_id	        => l_active_row_id
  );

 IF l_eit_type_id =0 OR l_eit_type_id=-1 THEN
  OPEN c_get_other_tstep;
  FETCH c_get_other_tstep INTO l_get_other_tstep;
  CLOSE c_get_other_tstep;
  ---dbms_output.put_line('zero'||l_eit_type_id);
  OPEN c_get_details;
  FETCH c_get_details INTO l_get_details;
  IF l_eit_type='REPOSITORY' THEN
   -- l_eit_type_id :=l_get_details.vehicle_repository_id;
   l_eit_type_id :=wf_engine.GetItemAttrNumber(
                            itemtype =>l_get_other_tstep.item_type,
                            itemkey =>l_get_other_tstep.item_key,
                            aname =>'PQP_VEH_REPOSITORY_ID_ATTR',
                            ignore_notfound =>l_ignore);

  ELSIF l_eit_type='ALLOCATION' THEN
   l_eit_type_id :=wf_engine.GetItemAttrNumber(
                            itemtype =>l_get_other_tstep.item_type,
                            itemkey =>l_get_other_tstep.item_key,
                            aname =>'PQP_VEH_ALLOCATION_ID_ATTR',
                            ignore_notfound =>l_ignore);
  END IF;
  CLOSE c_get_details;
 END IF;
   --debug


 --  FOR j IN 1..l_eit_table.count LOOP
 l_index := l_eit_table.first;
  -- LOOP
  -- EXIT WHEN
   --  (NOT l_eit_table.exists(l_index));


 l_extra_info_id  :=l_eit_table(l_index).extra_info_id;

 create_generic_eit
 (p_validate                  => false
 ,p_effective_date            => l_effective_date
 ,p_login_person_id           => l_login_person_id
 ,p_person_id                 => l_person_id
 ,p_assignment_id             => l_assignment_id
 ,p_business_group_id         => l_business_group_id
 ,p_action                    => l_eit_table(l_index).action
 ,p_eit_type	  	      => l_eit_type
 ,p_eit_type_id	  	      => l_eit_type_id
 ,p_information_type          => l_eit_table(l_index).information_type
 ,p_attribute_category        => l_eit_table(l_index).attribute_category
 ,p_attribute1                => l_eit_table(l_index).attribute1
 ,p_attribute2                => l_eit_table(l_index).attribute2
 ,p_attribute3                => l_eit_table(l_index).attribute3
 ,p_attribute4                => l_eit_table(l_index).attribute4
 ,p_attribute5                => l_eit_table(l_index).attribute5
 ,p_attribute6                => l_eit_table(l_index).attribute6
 ,p_attribute7                => l_eit_table(l_index).attribute7
 ,p_attribute8                => l_eit_table(l_index).attribute8
 ,p_attribute9                => l_eit_table(l_index).attribute9
 ,p_attribute10               => l_eit_table(l_index).attribute10
 ,p_attribute11               => l_eit_table(l_index).attribute11
 ,p_attribute12               => l_eit_table(l_index).attribute12
 ,p_attribute13               => l_eit_table(l_index).attribute13
 ,p_attribute14               => l_eit_table(l_index).attribute14
 ,p_attribute15               => l_eit_table(l_index).attribute15
 ,p_attribute16               => l_eit_table(l_index).attribute16
 ,p_attribute17               => l_eit_table(l_index).attribute17
 ,p_attribute18               => l_eit_table(l_index).attribute18
 ,p_attribute19               => l_eit_table(l_index).attribute19
 ,p_attribute20               => l_eit_table(l_index).attribute20
 ,p_information_category      => l_eit_table(l_index).information_category
 ,p_information1              => l_eit_table(l_index).information1
 ,p_information2              => l_eit_table(l_index).information2
 ,p_information3              => l_eit_table(l_index).information3
 ,p_information4              => l_eit_table(l_index).information4
 ,p_information5              => l_eit_table(l_index).information5
 ,p_information6              => l_eit_table(l_index).information6
 ,p_information7              => l_eit_table(l_index).information7
 ,p_information8              => l_eit_table(l_index).information8
 ,p_information9              => l_eit_table(l_index).information9
 ,p_information10             => l_eit_table(l_index).information10
 ,p_information11             => l_eit_table(l_index).information11
 ,p_information12             => l_eit_table(l_index).information12
 ,p_information13             => l_eit_table(l_index).information13
 ,p_information14             => l_eit_table(l_index).information14
 ,p_information15             => l_eit_table(l_index).information15
 ,p_information16             => l_eit_table(l_index).information16
 ,p_information17             => l_eit_table(l_index).information17
 ,p_information18             => l_eit_table(l_index).information18
 ,p_information19             => l_eit_table(l_index).information19
 ,p_information20             => l_eit_table(l_index).information20
 ,p_information21             => l_eit_table(l_index).information21
 ,p_information22             => l_eit_table(l_index).information22
 ,p_information23             => l_eit_table(l_index).information23
 ,p_information24             => l_eit_table(l_index).information24
 ,p_information25             => l_eit_table(l_index).information25
 ,p_information26             => l_eit_table(l_index).information26
 ,p_information27             => l_eit_table(l_index).information27
 ,p_information28             => l_eit_table(l_index).information28
 ,p_information29             => l_eit_table(l_index).information29
 ,p_information30             => l_eit_table(l_index).information30
 ,p_object_version_number     => l_object_version_number
  	-- EndRegistration
 ,p_extra_info_id            =>l_extra_info_id
 ,p_error_message            => l_error_message
 ,p_error_status            =>l_error_status
 );

 l_index := l_eit_table.next(l_index);

   -- END LOOP;
  --  END LOOP;

  --remove session
 hr_util_misc_web.remove_session_row();

 IF l_error_message is not null then
    hr_utility.raise_error;
 END IF;

EXCEPTION
 WHEN OTHERS THEN
  RAISE;

END process_api;




END;



/
