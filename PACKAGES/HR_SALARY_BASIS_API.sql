--------------------------------------------------------
--  DDL for Package HR_SALARY_BASIS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SALARY_BASIS_API" AUTHID CURRENT_USER as
/* $Header: peppbapi.pkh 120.1 2005/10/02 02:21:58 aroussel $ */
/*#
 * This package contains APIs to create and maintain a salary basis.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Salary Basis
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_salary_basis >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Salary Basis.
 *
 * Salary basis specifies the duration the enterprise uses to quote a salary
 * for an assignment. Salary basis is a combination of pay basis, annualization
 * factor, and element input value. Optionally, you can link salary basis to a
 * Grade Rate.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Input value for which the basis is set up must exist. Also Define Pay Basis
 * Flexfield - Additional Salary Basis Details.
 *
 * <p><b>Post Success</b><br>
 * Creates the salary basis record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the salary basis and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id Serves as a foreign key to HR_ORGANIZATION_UNITS.
 * Uniquely identifies the business group for which the salary basis is
 * created.
 * @param p_input_value_id {@rep:casecolumn PER_PAY_BASES.INPUT_VALUE_ID}
 * @param p_rate_id {@rep:casecolumn PER_PAY_BASES.RATE_ID}
 * @param p_name Unique name of the pay basis the process creates.
 * @param p_pay_basis The time basis for recording actual salary values, such
 * as Annual, Monthly, or Hourly. Valid values are identified by the
 * 'PAY_BASIS' lookup type.
 * @param p_rate_basis {@rep:casecolumn PER_PAY_BASES.RATE_BASIS}
 * @param p_pay_annualization_factor {@rep:casecolumn
 * PER_PAY_BASES.PAY_ANNUALIZATION_FACTOR}
 * @param p_grade_annualization_factor {@rep:casecolumn
 * PER_PAY_BASES.GRADE_ANNUALIZATION_FACTOR}
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_last_update_date {@rep:casecolumn PER_PAY_BASES.LAST_UPDATE_DATE}
 * @param p_last_updated_by {@rep:casecolumn PER_PAY_BASES.LAST_UPDATED_BY}
 * @param p_last_update_login {@rep:casecolumn PER_PAY_BASES.LAST_UPDATE_LOGIN}
 * @param p_created_by {@rep:casecolumn PER_PAY_BASES.CREATED_BY}
 * @param p_creation_date {@rep:casecolumn PER_PAY_BASES.CREATION_DATE}
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_pay_basis_id If p_validate is false, uniquely identifies the salary
 * basis created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created salary basis. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Salary Basis
 * @rep:category BUSINESS_ENTITY HR_SALARY_BASIS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_salary_basis
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_input_value_id		   in     number
  ,p_rate_id			   in 	  number   default null
  ,p_name			   in     varchar2
  ,p_pay_basis			   in     varchar2
  ,p_rate_basis 		   in     varchar2
  ,p_pay_annualization_factor      in 	  number   default null
  ,p_grade_annualization_factor    in 	  number   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_last_update_date              in 	  date     default null
  ,p_last_updated_by               in 	  number   default null
  ,p_last_update_login             in 	  number   default null
  ,p_created_by                    in 	  number   default null
  ,p_creation_date                 in 	  date     default null
  ,p_information_category          in     varchar2 default null
  ,p_information1 	           in     varchar2 default null
  ,p_information2 	           in     varchar2 default null
  ,p_information3 	           in     varchar2 default null
  ,p_information4 	           in     varchar2 default null
  ,p_information5 	           in     varchar2 default null
  ,p_information6 	           in     varchar2 default null
  ,p_information7 	           in     varchar2 default null
  ,p_information8 	           in     varchar2 default null
  ,p_information9 	           in     varchar2 default null
  ,p_information10 	           in     varchar2 default null
  ,p_information11 	           in     varchar2 default null
  ,p_information12 	           in     varchar2 default null
  ,p_information13 	           in     varchar2 default null
  ,p_information14 	           in     varchar2 default null
  ,p_information15 	           in     varchar2 default null
  ,p_information16 	           in     varchar2 default null
  ,p_information17 	           in     varchar2 default null
  ,p_information18 	           in     varchar2 default null
  ,p_information19 	           in     varchar2 default null
  ,p_information20 	           in     varchar2 default null
  ,p_pay_basis_id                  out    nocopy number
  ,p_object_version_number         out    nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_salary_basis >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing salary basis record.
 *
 * Salary basis specifies the duration the enterprise uses to quote a salary
 * for an assignment. Salary basis is a combination of pay basis, annualization
 * factor, and element input value. Optionally, you can link salary basis to a
 * Grade Rate.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A salary basis as specified by the in parameter p_pay_basis_id and the in
 * out parameter p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * Salary basis details are updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the salary basis and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pay_basis_id {@rep:casecolumn PER_PAY_BASES.PAY_BASIS_ID}
 * @param p_input_value_id {@rep:casecolumn PER_PAY_BASES.INPUT_VALUE_ID}
 * @param p_rate_id {@rep:casecolumn PER_PAY_BASES.RATE_ID}
 * @param p_name Unique name of the pay basis the process creates.
 * @param p_pay_basis The time basis for recording actual salary values, such
 * as Annual, Monthly, or Hourly. Valid values are identified by the
 * 'PAY_BASIS' lookup type.
 * @param p_rate_basis {@rep:casecolumn PER_PAY_BASES.RATE_BASIS}
 * @param p_pay_annualization_factor {@rep:casecolumn
 * PER_PAY_BASES.PAY_ANNUALIZATION_FACTOR}
 * @param p_grade_annualization_factor {@rep:casecolumn
 * PER_PAY_BASES.GRADE_ANNUALIZATION_FACTOR}
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_last_update_date {@rep:casecolumn PER_PAY_BASES.LAST_UPDATE_DATE}
 * @param p_last_updated_by {@rep:casecolumn PER_PAY_BASES.LAST_UPDATED_BY}
 * @param p_last_update_login {@rep:casecolumn PER_PAY_BASES.LAST_UPDATE_LOGIN}
 * @param p_created_by {@rep:casecolumn PER_PAY_BASES.CREATED_BY}
 * @param p_creation_date {@rep:casecolumn PER_PAY_BASES.CREATION_DATE}
 * @param p_object_version_number Pass in the current version number of the
 * salary basis to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated salary basis. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Salary Basis
 * @rep:category BUSINESS_ENTITY HR_SALARY_BASIS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
 procedure update_salary_basis
  (P_VALIDATE			    IN	  BOOLEAN default false
   ,P_PAY_BASIS_ID                  IN    NUMBER
   ,P_INPUT_VALUE_ID                IN    NUMBER default hr_api.g_number
   ,P_RATE_ID                       IN    NUMBER default hr_api.g_number
   ,P_NAME                          IN    VARCHAR2 default hr_api.g_varchar2
   ,P_PAY_BASIS                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_RATE_BASIS                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_PAY_ANNUALIZATION_FACTOR      IN    NUMBER default hr_api.g_number
   ,P_GRADE_ANNUALIZATION_FACTOR    IN    NUMBER default hr_api.g_number
   ,P_ATTRIBUTE_CATEGORY            IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE1                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE2                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE3                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE4                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE5                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE6                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE7                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE8                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE9                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE10                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE11                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE12                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE13                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE14                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE15                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE16                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE17                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE18                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE19                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE20                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION_CATEGORY          IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION1                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION2                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION3                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION4                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION5                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION6                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION7                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION8                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION9                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION10                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION11                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION12                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION13                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION14                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION15                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION16                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION17                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION18                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION19                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION20                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_LAST_UPDATE_DATE              IN    DATE default hr_api.g_date
   ,P_LAST_UPDATED_BY               IN    NUMBER default hr_api.g_number
   ,P_LAST_UPDATE_LOGIN             IN    NUMBER default hr_api.g_number
   ,P_CREATED_BY                    IN    NUMBER default hr_api.g_number
   ,P_CREATION_DATE                 IN    DATE default hr_api.g_date
   ,P_OBJECT_VERSION_NUMBER	    IN OUT nocopy NUMBER

  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_salary_basis >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing salary basis record.
 *
 * You can delete a salary basis record only when there are no assignments on
 * the salary basis.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The salary basis as identified by the in parameter p_pay_basis_id and the in
 * out parameter p_object_version_number must already exist; and no records
 * relating to the pay_basis_id in the reference tables can exist.
 *
 * <p><b>Post Success</b><br>
 * This API deletes the salary basis that corresponds to the ID value passed to
 * the API.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete Salary Basis and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pay_basis_id {@rep:casecolumn PER_PAY_BASES.PAY_BASIS_ID}
 * @param p_object_version_number Current version number of the salary basis to
 * be deleted.
 * @rep:displayname Delete Salary Basis
 * @rep:category BUSINESS_ENTITY HR_SALARY_BASIS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_salary_basis
  (p_validate                      in     boolean  default false
  ,p_pay_basis_id                     in     number
  ,p_object_version_number         in out nocopy number);

--
end hr_salary_basis_api;
--

 

/
