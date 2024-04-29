--------------------------------------------------------
--  DDL for Package HR_SALARY_BASIS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SALARY_BASIS_BK1" AUTHID CURRENT_USER as
/* $Header: peppbapi.pkh 120.1 2005/10/02 02:21:58 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_salary_basis_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_salary_basis_b
  (p_business_group_id             in     number
  ,p_input_value_id		   in     number
  ,p_rate_id			   in 	  number
  ,p_name			   in     varchar2
  ,p_pay_basis			   in     varchar2
  ,p_rate_basis 		   in     varchar2
  ,p_pay_annualization_factor      in 	  number
  ,p_grade_annualization_factor    in 	  number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
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
  ,p_last_update_date              in 	  date
  ,p_last_updated_by               in 	  number
  ,p_last_update_login             in 	  number
  ,p_created_by                    in 	  number
  ,p_creation_date                 in 	  date
  ,p_information_category          in     varchar2
  ,p_information1 	           in     varchar2
  ,p_information2 	           in     varchar2
  ,p_information3 	           in     varchar2
  ,p_information4 	           in     varchar2
  ,p_information5 	           in     varchar2
  ,p_information6 	           in     varchar2
  ,p_information7 	           in     varchar2
  ,p_information8 	           in     varchar2
  ,p_information9 	           in     varchar2
  ,p_information10 	           in     varchar2
  ,p_information11 	           in     varchar2
  ,p_information12 	           in     varchar2
  ,p_information13 	           in     varchar2
  ,p_information14 	           in     varchar2
  ,p_information15 	           in     varchar2
  ,p_information16 	           in     varchar2
  ,p_information17 	           in     varchar2
  ,p_information18 	           in     varchar2
  ,p_information19 	           in     varchar2
  ,p_information20 	           in     varchar2
  ,p_pay_basis_id                  in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_salary_basis_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_salary_basis_a
  (p_business_group_id             in     number
  ,p_input_value_id		   in     number
  ,p_rate_id			   in 	  number
  ,p_name			   in     varchar2
  ,p_pay_basis			   in     varchar2
  ,p_rate_basis 		   in     varchar2
  ,p_pay_annualization_factor      in 	  number
  ,p_grade_annualization_factor    in 	  number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
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
  ,p_last_update_date              in 	  date
  ,p_last_updated_by               in 	  number
  ,p_last_update_login             in 	  number
  ,p_created_by                    in 	  number
  ,p_creation_date                 in 	  date
  ,p_information_category          in     varchar2
  ,p_information1 	           in     varchar2
  ,p_information2 	           in     varchar2
  ,p_information3 	           in     varchar2
  ,p_information4 	           in     varchar2
  ,p_information5 	           in     varchar2
  ,p_information6 	           in     varchar2
  ,p_information7 	           in     varchar2
  ,p_information8 	           in     varchar2
  ,p_information9 	           in     varchar2
  ,p_information10 	           in     varchar2
  ,p_information11 	           in     varchar2
  ,p_information12 	           in     varchar2
  ,p_information13 	           in     varchar2
  ,p_information14 	           in     varchar2
  ,p_information15 	           in     varchar2
  ,p_information16 	           in     varchar2
  ,p_information17 	           in     varchar2
  ,p_information18 	           in     varchar2
  ,p_information19 	           in     varchar2
  ,p_information20 	           in     varchar2
  ,p_pay_basis_id                  in     number
  ,p_object_version_number         in     number
  );
--
end hr_salary_basis_bk1;

 

/
