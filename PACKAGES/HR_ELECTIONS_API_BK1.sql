--------------------------------------------------------
--  DDL for Package HR_ELECTIONS_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ELECTIONS_API_BK1" AUTHID CURRENT_USER as
/* $Header: peelcapi.pkh 120.1 2005/10/02 02:15:24 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_election_information_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_election_information_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_election_date                 in     date
  ,p_description		   in	  varchar2
  ,p_rep_body_id	 	   in	  number
  ,p_previous_election_date	   in	  date
  ,p_next_election_date		   in	  date
  ,p_result_publish_date	   in	  date
  ,p_attribute_category		   in	  varchar2
  ,p_attribute1			   in	  varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_election_info_category 		in	  varchar2
  ,p_election_information1	     in	  varchar2
  ,p_election_information2         in     varchar2
  ,p_election_information3         in     varchar2
  ,p_election_information4         in     varchar2
  ,p_election_information5         in     varchar2
  ,p_election_information6         in     varchar2
  ,p_election_information7         in     varchar2
  ,p_election_information8         in     varchar2
  ,p_election_information9         in     varchar2
  ,p_election_information10        in     varchar2
  ,p_election_information11        in     varchar2
  ,p_election_information12        in     varchar2
  ,p_election_information13        in     varchar2
  ,p_election_information14        in     varchar2
  ,p_election_information15        in     varchar2
  ,p_election_information16        in     varchar2
  ,p_election_information17        in     varchar2
  ,p_election_information18        in     varchar2
  ,p_election_information19        in     varchar2
  ,p_election_information20        in     varchar2
  ,p_election_information21        in     varchar2
  ,p_election_information22        in     varchar2
  ,p_election_information23        in     varchar2
  ,p_election_information24        in     varchar2
  ,p_election_information25        in     varchar2
  ,p_election_information26        in     varchar2
  ,p_election_information27        in     varchar2
  ,p_election_information28        in     varchar2
  ,p_election_information29        in     varchar2
  ,p_election_information30        in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_election_information_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_election_information_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_election_date		   		in	  date
  ,p_description		   in	  varchar2
  ,p_rep_body_id				in 	  number
  ,p_previous_election_date	   	in	  date
  ,p_next_election_date		   	in	  date
  ,p_result_publish_date	   		in	  date
  ,p_attribute_category		   	in	  varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2			   	in 	  varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_election_info_category 		in	  varchar2
  ,p_election_information1	   	in	  varchar2
  ,p_election_information2         in     varchar2
  ,p_election_information3         in     varchar2
  ,p_election_information4         in     varchar2
  ,p_election_information5         in     varchar2
  ,p_election_information6         in     varchar2
  ,p_election_information7         in     varchar2
  ,p_election_information8         in     varchar2
  ,p_election_information9         in     varchar2
  ,p_election_information10        in     varchar2
  ,p_election_information11        in     varchar2
  ,p_election_information12        in     varchar2
  ,p_election_information13        in     varchar2
  ,p_election_information14        in     varchar2
  ,p_election_information15        in     varchar2
  ,p_election_information16        in     varchar2
  ,p_election_information17        in     varchar2
  ,p_election_information18        in     varchar2
  ,p_election_information19        in     varchar2
  ,p_election_information20        in     varchar2
  ,p_election_information21        in     varchar2
  ,p_election_information22        in     varchar2
  ,p_election_information23        in     varchar2
  ,p_election_information24        in     varchar2
  ,p_election_information25        in     varchar2
  ,p_election_information26        in     varchar2
  ,p_election_information27        in     varchar2
  ,p_election_information28        in     varchar2
  ,p_election_information29        in     varchar2
  ,p_election_information30        in     varchar2
  ,p_election_id		   		in	  number
  ,p_object_version_number	   	in	  number
  );
--
end hr_elections_api_bk1;

 

/
