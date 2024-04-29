--------------------------------------------------------
--  DDL for Package Body PQP_PL_VEH_REPOS_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PL_VEH_REPOS_EXTRA_INFO" AS
/* $Header: pqplvrip.pkb 120.1 2006/09/13 13:24:45 mseshadr noship $ */
g_package VARCHAR2(30);
--

PROCEDURE create_pl_veh_repos_extra_info(p_vehicle_repository_id          in     number
					  ,p_information_type               in     varchar2
					  ,p_vrei_attribute_category        in     varchar2
					  ,p_vrei_information_category      in     varchar2
					  ,p_vrei_information1              in     varchar2
					  ,p_vrei_information2              in     varchar2
					  ,p_vrei_information3              in     varchar2
					  ,p_vrei_information4              in     varchar2
					  ,p_vrei_information5              in     varchar2
					  ,p_vrei_information6              in     varchar2
					  ,p_vrei_information7              in     varchar2
					  ,p_vrei_information8              in     varchar2
					  ,p_vrei_information9              in     varchar2
					  ,p_vrei_information10             in     varchar2
					  ,p_vrei_information11             in     varchar2
					  ,p_vrei_information12             in     varchar2
					  ,p_vrei_information13             in     varchar2
					  ,p_vrei_information14             in     varchar2
					  ,p_vrei_information15             in     varchar2
					  ,p_vrei_information16             in     varchar2
					  ,p_vrei_information17             in     varchar2
					  ,p_vrei_information18             in     varchar2
					  ,p_vrei_information19             in     varchar2
					  ,p_vrei_information20             in     varchar2
					  ,p_vrei_information21             in     varchar2
					  ,p_vrei_information22             in     varchar2
					  ,p_vrei_information23             in     varchar2
					  ,p_vrei_information24             in     varchar2
					  ,p_vrei_information25             in     varchar2
					  ,p_vrei_information26             in     varchar2
					  ,p_vrei_information27             in     varchar2
					  ,p_vrei_information28             in     varchar2
					  ,p_vrei_information29             in     varchar2
					  ,p_vrei_information30             in     varchar2
					  ,p_request_id                     in     number
					  ,p_program_application_id         in     number
					  ,p_program_id                     in     number
					  ,p_program_update_date            in     date
					) is

  cursor cur_eff is select effective_start_date,
					 effective_end_date from pqp_vehicle_repository_f
					where vehicle_repository_id = p_vehicle_repository_id;
 l_effective_start_date date;
 l_effective_end_date date;

Begin

  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving create_pl_veh_repos_extra_info');
   return;
END IF;

 If p_vrei_information_category in ('PL_VEHICLE_INSURANCE_INFO','PL_VEHICLE_ACCIDENT_INFO','PL_VEHICLE_ADDITIONAL_INFO') Then
  Open cur_eff;
  fetch cur_eff into  l_effective_start_date, l_effective_end_date;
  If fnd_date.canonical_to_date(p_vrei_information1) < l_effective_start_date or fnd_date.canonical_to_date(p_vrei_information1) > l_effective_end_date Then
   close cur_eff;

    hr_utility.set_message(800,'HR_375832_VRE_PL_EFF_DATE');
    hr_utility.set_message_token('STARTDATE',l_effective_start_date);
    hr_utility.set_message_token('ENDDATE',l_effective_end_date);
    hr_utility.raise_error;
  End if;
 close cur_eff;
 End if;

End create_pl_veh_repos_extra_info;

PROCEDURE update_pl_veh_repos_extra_info(p_veh_repos_extra_info_id      in     number
		  ,p_vehicle_repository_id        in     number
		  ,p_information_type             in     varchar2
		  ,p_vrei_attribute_category      in     varchar2
		  ,p_vrei_information_category    in     varchar2
		  ,p_vrei_information1            in     varchar2
		  ,p_vrei_information2            in     varchar2
		  ,p_vrei_information3            in     varchar2
		  ,p_vrei_information4            in     varchar2
		  ,p_vrei_information5            in     varchar2
		  ,p_vrei_information6            in     varchar2
		  ,p_vrei_information7            in     varchar2
		  ,p_vrei_information8            in     varchar2
		  ,p_vrei_information9            in     varchar2
		  ,p_vrei_information10           in     varchar2
		  ,p_vrei_information11           in     varchar2
		  ,p_vrei_information12           in     varchar2
		  ,p_vrei_information13           in     varchar2
		  ,p_vrei_information14           in     varchar2
		  ,p_vrei_information15           in     varchar2
		  ,p_vrei_information16           in     varchar2
		  ,p_vrei_information17           in     varchar2
		  ,p_vrei_information18           in     varchar2
		  ,p_vrei_information19           in     varchar2
		  ,p_vrei_information20           in     varchar2
		  ,p_vrei_information21           in     varchar2
		  ,p_vrei_information22           in     varchar2
		  ,p_vrei_information23           in     varchar2
		  ,p_vrei_information24           in     varchar2
		  ,p_vrei_information25           in     varchar2
		  ,p_vrei_information26           in     varchar2
		  ,p_vrei_information27           in     varchar2
		  ,p_vrei_information28           in     varchar2
		  ,p_vrei_information29           in     varchar2
		  ,p_vrei_information30           in     varchar2
		  ,p_request_id                   in     number
		  ,p_program_application_id       in     number
		  ,p_program_id                   in     number
		  ,p_program_update_date          in     date
		) is

  cursor cur_eff is select effective_start_date,
					 effective_end_date from pqp_vehicle_repository_f
					where vehicle_repository_id = p_vehicle_repository_id;
 l_effective_start_date date;
 l_effective_end_date date;

Begin

  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving update_pl_veh_repos_extra_info');
   return;
END IF;

 If p_vrei_information_category in ('PL_VEHICLE_INSURANCE_INFO','PL_VEHICLE_ACCIDENT_INFO','PL_VEHICLE_ADDITIONAL_INFO') Then
  Open cur_eff;
  fetch cur_eff into  l_effective_start_date, l_effective_end_date;
  If fnd_date.canonical_to_date(p_vrei_information1) < l_effective_start_date or fnd_date.canonical_to_date(p_vrei_information1) > l_effective_end_date Then
   close cur_eff;
    hr_utility.set_message(800,'HR_375832_VRE_PL_EFF_DATE');
    hr_utility.set_message_token('STARTDATE',l_effective_start_date);
    hr_utility.set_message_token('ENDDATE',l_effective_end_date);
    hr_utility.raise_error;
  End if;
 close cur_eff;
 End if;

End update_pl_veh_repos_extra_info;

END pqp_pl_veh_repos_extra_info;

/
