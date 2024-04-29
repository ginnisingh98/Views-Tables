--------------------------------------------------------
--  DDL for Package OTA_OCL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OCL_API" AUTHID CURRENT_USER as
/* $Header: otoclapi.pkh 120.1 2007/02/07 09:16:52 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <create_competence_language> >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_competence_language
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_competence_language_id            out nocopy number
  ,p_competence_id                 in     number
  ,p_language_code                   in     varchar2
  ,p_business_group_id             in     number
  ,p_min_proficiency_level_id      in     number   default null
  ,p_ocl_information_category      in     varchar2 default null
  ,p_ocl_information1              in     varchar2 default null
  ,p_ocl_information2              in     varchar2 default null
  ,p_ocl_information3              in     varchar2 default null
  ,p_ocl_information4              in     varchar2 default null
  ,p_ocl_information5              in     varchar2 default null
  ,p_ocl_information6              in     varchar2 default null
  ,p_ocl_information7              in     varchar2 default null
  ,p_ocl_information8              in     varchar2 default null
  ,p_ocl_information9              in     varchar2 default null
  ,p_ocl_information10             in     varchar2 default null
  ,p_ocl_information11             in     varchar2 default null
  ,p_ocl_information12             in     varchar2 default null
  ,p_ocl_information13             in     varchar2 default null
  ,p_ocl_information14             in     varchar2 default null
  ,p_ocl_information15             in     varchar2 default null
  ,p_ocl_information16             in     varchar2 default null
  ,p_ocl_information17             in     varchar2 default null
  ,p_ocl_information18             in     varchar2 default null
  ,p_ocl_information19             in     varchar2 default null
  ,p_ocl_information20             in     varchar2 default null
  ,p_object_version_number             out nocopy number
  ,p_some_warning                     out nocopy boolean
  );
--

-- ----------------------------------------------------------------------------
-- |--------------------------< <update_competence_language> >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_competence_language
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_competence_language_id        in	number
  ,p_competence_id                 in     number
  ,p_language_code                   in    varchar2
  ,p_business_group_id             in     number
  ,p_min_proficiency_level_id      in     number   default null
  ,p_ocl_information_category      in     varchar2 default null
  ,p_ocl_information1              in     varchar2 default null
  ,p_ocl_information2              in     varchar2 default null
  ,p_ocl_information3              in     varchar2 default null
  ,p_ocl_information4              in     varchar2 default null
  ,p_ocl_information5              in     varchar2 default null
  ,p_ocl_information6              in     varchar2 default null
  ,p_ocl_information7              in     varchar2 default null
  ,p_ocl_information8              in     varchar2 default null
  ,p_ocl_information9              in     varchar2 default null
  ,p_ocl_information10             in     varchar2 default null
  ,p_ocl_information11             in     varchar2 default null
  ,p_ocl_information12             in     varchar2 default null
  ,p_ocl_information13             in     varchar2 default null
  ,p_ocl_information14             in     varchar2 default null
  ,p_ocl_information15             in     varchar2 default null
  ,p_ocl_information16             in     varchar2 default null
  ,p_ocl_information17             in     varchar2 default null
  ,p_ocl_information18             in     varchar2 default null
  ,p_ocl_information19             in     varchar2 default null
  ,p_ocl_information20             in     varchar2 default null
  ,p_object_version_number         in  out nocopy number
  ,p_some_warning                     out nocopy boolean
  );
--
end OTA_OCL_API ;

/
