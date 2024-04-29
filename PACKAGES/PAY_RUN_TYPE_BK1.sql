--------------------------------------------------------
--  DDL for Package PAY_RUN_TYPE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RUN_TYPE_BK1" AUTHID CURRENT_USER as
/* $Header: pyprtapi.pkh 120.1 2005/10/02 02:33:16 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
--
procedure create_run_type_b
  (p_effective_date                in     date
  ,p_language_code                 in     varchar2
  ,p_run_type_name                 in     varchar2
  ,p_run_method                    in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_shortname                     in     varchar2
  ,p_srs_flag                      in     varchar2
  ,p_run_information_category	   in     varchar2
  ,p_run_information1		   in     varchar2
  ,p_run_information2		   in     varchar2
  ,p_run_information3		   in     varchar2
  ,p_run_information4		   in     varchar2
  ,p_run_information5		   in     varchar2
  ,p_run_information6		   in     varchar2
  ,p_run_information7		   in     varchar2
  ,p_run_information8		   in     varchar2
  ,p_run_information9		   in     varchar2
  ,p_run_information10		   in     varchar2
  ,p_run_information11		   in     varchar2
  ,p_run_information12		   in     varchar2
  ,p_run_information13		   in     varchar2
  ,p_run_information14		   in     varchar2
  ,p_run_information15		   in     varchar2
  ,p_run_information16		   in     varchar2
  ,p_run_information17		   in     varchar2
  ,p_run_information18		   in     varchar2
  ,p_run_information19		   in     varchar2
  ,p_run_information20		   in     varchar2
  ,p_run_information21		   in     varchar2
  ,p_run_information22		   in     varchar2
  ,p_run_information23		   in     varchar2
  ,p_run_information24		   in     varchar2
  ,p_run_information25		   in     varchar2
  ,p_run_information26		   in     varchar2
  ,p_run_information27		   in     varchar2
  ,p_run_information28		   in     varchar2
  ,p_run_information29		   in     varchar2
  ,p_run_information30		   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_run_type_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_run_type_a
  (p_effective_date                in     date
  ,p_language_code                 in     varchar2
  ,p_run_type_name                 in     varchar2
  ,p_run_method                    in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_shortname                     in     varchar2
  ,p_srs_flag                      in     varchar2
  ,p_run_information_category	   in     varchar2
  ,p_run_information1		   in     varchar2
  ,p_run_information2		   in     varchar2
  ,p_run_information3		   in     varchar2
  ,p_run_information4		   in     varchar2
  ,p_run_information5		   in     varchar2
  ,p_run_information6		   in     varchar2
  ,p_run_information7		   in     varchar2
  ,p_run_information8		   in     varchar2
  ,p_run_information9		   in     varchar2
  ,p_run_information10		   in     varchar2
  ,p_run_information11		   in     varchar2
  ,p_run_information12		   in     varchar2
  ,p_run_information13		   in     varchar2
  ,p_run_information14		   in     varchar2
  ,p_run_information15		   in     varchar2
  ,p_run_information16		   in     varchar2
  ,p_run_information17		   in     varchar2
  ,p_run_information18		   in     varchar2
  ,p_run_information19		   in     varchar2
  ,p_run_information20		   in     varchar2
  ,p_run_information21		   in     varchar2
  ,p_run_information22		   in     varchar2
  ,p_run_information23		   in     varchar2
  ,p_run_information24		   in     varchar2
  ,p_run_information25		   in     varchar2
  ,p_run_information26		   in     varchar2
  ,p_run_information27		   in     varchar2
  ,p_run_information28		   in     varchar2
  ,p_run_information29		   in     varchar2
  ,p_run_information30		   in     varchar2
  ,p_run_type_id                   in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_object_version_number         in     number
  );
--
end pay_run_type_bk1;

 

/
