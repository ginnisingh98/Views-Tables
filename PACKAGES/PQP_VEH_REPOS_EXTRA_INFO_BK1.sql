--------------------------------------------------------
--  DDL for Package PQP_VEH_REPOS_EXTRA_INFO_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEH_REPOS_EXTRA_INFO_BK1" AUTHID CURRENT_USER as
/* $Header: pqvriapi.pkh 120.0.12010000.3 2008/08/08 07:23:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< CREATE_VEH_REPOS_EXTRA_INFO_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_veh_repos_extra_info_b
 ( p_vehicle_repository_id         in     number
  ,p_information_type               in     varchar2
  ,p_vrei_attribute_category        in     varchar2
  ,p_vrei_attribute1                in     varchar2
  ,p_vrei_attribute2                in     varchar2
  ,p_vrei_attribute3                in     varchar2
  ,p_vrei_attribute4                in     varchar2
  ,p_vrei_attribute5                in     varchar2
  ,p_vrei_attribute6                in     varchar2
  ,p_vrei_attribute7                in     varchar2
  ,p_vrei_attribute8                in     varchar2
  ,p_vrei_attribute9                in     varchar2
  ,p_vrei_attribute10               in     varchar2
  ,p_vrei_attribute11               in     varchar2
  ,p_vrei_attribute12               in     varchar2
  ,p_vrei_attribute13               in     varchar2
  ,p_vrei_attribute14               in     varchar2
  ,p_vrei_attribute15               in     varchar2
  ,p_vrei_attribute16               in     varchar2
  ,p_vrei_attribute17               in     varchar2
  ,p_vrei_attribute18               in     varchar2
  ,p_vrei_attribute19               in     varchar2
  ,p_vrei_attribute20               in     varchar2
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
--
-- ----------------------------------------------------------------------------
-- |------------------< CREATE_VEH_REPOS_EXTRA_INFO_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_veh_repos_extra_info_a
 ( p_vehicle_repository_id         in     number
  ,p_information_type               in     varchar2
  ,p_vrei_attribute_category        in     varchar2
  ,p_vrei_attribute1                in     varchar2
  ,p_vrei_attribute2                in     varchar2
  ,p_vrei_attribute3                in     varchar2
  ,p_vrei_attribute4                in     varchar2
  ,p_vrei_attribute5                in     varchar2
  ,p_vrei_attribute6                in     varchar2
  ,p_vrei_attribute7                in     varchar2
  ,p_vrei_attribute8                in     varchar2
  ,p_vrei_attribute9                in     varchar2
  ,p_vrei_attribute10               in     varchar2
  ,p_vrei_attribute11               in     varchar2
  ,p_vrei_attribute12               in     varchar2
  ,p_vrei_attribute13               in     varchar2
  ,p_vrei_attribute14               in     varchar2
  ,p_vrei_attribute15               in     varchar2
  ,p_vrei_attribute16               in     varchar2
  ,p_vrei_attribute17               in     varchar2
  ,p_vrei_attribute18               in     varchar2
  ,p_vrei_attribute19               in     varchar2
  ,p_vrei_attribute20               in     varchar2
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
  ,p_veh_repos_extra_info_id        in     number
  ,p_object_version_number          in     number
  );
--
end  PQP_VEH_REPOS_EXTRA_INFO_BK1;

/