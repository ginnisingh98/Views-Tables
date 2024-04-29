--------------------------------------------------------
--  DDL for Package PER_RU_VEH_REPOS_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RU_VEH_REPOS_EXTRA_INFO" AUTHID CURRENT_USER AS
/* $Header: peruvehr.pkh 120.0.12000000.1 2007/01/22 03:59:26 appldev noship $ */
PROCEDURE create_ru_veh_repos_extra_info(p_vehicle_repository_id          in     number
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
					);

PROCEDURE update_ru_veh_repos_extra_info(p_veh_repos_extra_info_id      in     number
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
		);

END per_ru_veh_repos_extra_info;

 

/
