--------------------------------------------------------
--  DDL for Package HR_PERIODS_OF_SERVICE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERIODS_OF_SERVICE_BK1" AUTHID CURRENT_USER as
/* $Header: pepdsapi.pkh 120.7 2007/04/19 06:04:29 pdkundu noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_pds_details_b >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pds_details_b
   (
   p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_termination_accepted_person   in     number
  ,p_accepted_termination_date     in     date
  ,p_object_version_number         in     number
  ,p_comments                      in     varchar2
  ,p_leaving_reason                in     varchar2
  ,p_notified_termination_date     in     date
  ,p_projected_termination_date    in     date
   -- START Added for bug 5623631 as the parameters have been indroduced in main API
  ,p_actual_termination_date       in     date
  ,p_last_standard_process_date    in     date
  ,p_final_process_date            in     date
   -- END Added for bug 5623631 as the parameters have been indroduced in main API
  ,p_attribute_category            in varchar2
  ,p_attribute1                    in varchar2
  ,p_attribute2                    in varchar2
  ,p_attribute3                    in varchar2
  ,p_attribute4                    in varchar2
  ,p_attribute5                    in varchar2
  ,p_attribute6                    in varchar2
  ,p_attribute7                    in varchar2
  ,p_attribute8                    in varchar2
  ,p_attribute9                    in varchar2
  ,p_attribute10                   in varchar2
  ,p_attribute11                   in varchar2
  ,p_attribute12                   in varchar2
  ,p_attribute13                   in varchar2
  ,p_attribute14                   in varchar2
  ,p_attribute15                   in varchar2
  ,p_attribute16                   in varchar2
  ,p_attribute17                   in varchar2
  ,p_attribute18                   in varchar2
  ,p_attribute19                   in varchar2
  ,p_attribute20                   in varchar2
  ,p_pds_information_category      in varchar2
  ,p_pds_information1              in varchar2
  ,p_pds_information2              in varchar2
  ,p_pds_information3              in varchar2
  ,p_pds_information4              in varchar2
  ,p_pds_information5              in varchar2
  ,p_pds_information6              in varchar2
  ,p_pds_information7              in varchar2
  ,p_pds_information8              in varchar2
  ,p_pds_information9              in varchar2
  ,p_pds_information10             in varchar2
  ,p_pds_information11             in varchar2
  ,p_pds_information12             in varchar2
  ,p_pds_information13             in varchar2
  ,p_pds_information14             in varchar2
  ,p_pds_information15             in varchar2
  ,p_pds_information16             in varchar2
  ,p_pds_information17             in varchar2
  ,p_pds_information18             in varchar2
  ,p_pds_information19             in varchar2
  ,p_pds_information20             in varchar2
  ,p_pds_information21             in varchar2
  ,p_pds_information22             in varchar2
  ,p_pds_information23             in varchar2
  ,p_pds_information24             in varchar2
  ,p_pds_information25             in varchar2
  ,p_pds_information26             in varchar2
  ,p_pds_information27             in varchar2
  ,p_pds_information28             in varchar2
  ,p_pds_information29             in varchar2
  ,p_pds_information30             in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_pds_details_a >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pds_details_a
  (
   p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_termination_accepted_person   in     number
  ,p_accepted_termination_date     in     date
  ,p_object_version_number         in     number
  ,p_comments                      in     varchar2
  ,p_leaving_reason                in     varchar2
  ,p_notified_termination_date     in     date
  ,p_projected_termination_date    in     date
   -- START Added for bug 5623631 as the parameters have been indroduced in main API
  ,p_actual_termination_date       in     date
  ,p_last_standard_process_date    in     date
  ,p_final_process_date            in     date
   -- END Added for bug 5623631 as the parameters have been indroduced in main API
  ,p_attribute_category            in varchar2
  ,p_attribute1                    in varchar2
  ,p_attribute2                    in varchar2
  ,p_attribute3                    in varchar2
  ,p_attribute4                    in varchar2
  ,p_attribute5                    in varchar2
  ,p_attribute6                    in varchar2
  ,p_attribute7                    in varchar2
  ,p_attribute8                    in varchar2
  ,p_attribute9                    in varchar2
  ,p_attribute10                   in varchar2
  ,p_attribute11                   in varchar2
  ,p_attribute12                   in varchar2
  ,p_attribute13                   in varchar2
  ,p_attribute14                   in varchar2
  ,p_attribute15                   in varchar2
  ,p_attribute16                   in varchar2
  ,p_attribute17                   in varchar2
  ,p_attribute18                   in varchar2
  ,p_attribute19                   in varchar2
  ,p_attribute20                   in varchar2
  ,p_pds_information_category      in varchar2
  ,p_pds_information1              in varchar2
  ,p_pds_information2              in varchar2
  ,p_pds_information3              in varchar2
  ,p_pds_information4              in varchar2
  ,p_pds_information5              in varchar2
  ,p_pds_information6              in varchar2
  ,p_pds_information7              in varchar2
  ,p_pds_information8              in varchar2
  ,p_pds_information9              in varchar2
  ,p_pds_information10             in varchar2
  ,p_pds_information11             in varchar2
  ,p_pds_information12             in varchar2
  ,p_pds_information13             in varchar2
  ,p_pds_information14             in varchar2
  ,p_pds_information15             in varchar2
  ,p_pds_information16             in varchar2
  ,p_pds_information17             in varchar2
  ,p_pds_information18             in varchar2
  ,p_pds_information19             in varchar2
  ,p_pds_information20             in varchar2
  ,p_pds_information21             in varchar2
  ,p_pds_information22             in varchar2
  ,p_pds_information23             in varchar2
  ,p_pds_information24             in varchar2
  ,p_pds_information25             in varchar2
  ,p_pds_information26             in varchar2
  ,p_pds_information27             in varchar2
  ,p_pds_information28             in varchar2
  ,p_pds_information29             in varchar2
  ,p_pds_information30             in varchar2
 );
--
end hr_periods_of_service_bk1;

/
