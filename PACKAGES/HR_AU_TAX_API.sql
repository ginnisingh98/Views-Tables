--------------------------------------------------------
--  DDL for Package HR_AU_TAX_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AU_TAX_API" AUTHID CURRENT_USER AS
/* $Header: hrauwrtx.pkh 120.5.12010000.3 2008/09/29 09:38:39 keyazawa ship $ */
/*#
 * This package contains tax APIs for Australia.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Tax for Australia
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< maintain_paye_tax_info >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API maintains PAYE Tax information for Australia.
 *
 * This API updates the element entries of Paye Tax element for the Australian
 * legislation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business_group_id for Australian Legislation and if valid
 * person_type_id is specified.A primary assignment must exist, a corresponding
 * system type of 'APL', must be active and in the same business group as that
 * of the applicant being created. If a person_type_id is not specified the API
 * will use the DEFAULT 'APL' type for the business group
 *
 * <p><b>Post Success</b><br>
 * The element entries of Paye Tax element will be successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the element entries of Paye Tax element and raises
 * an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_id Identifies the assignment for which you create the
 * tax information record.
 * @param p_effective_start_date Passes the element entry effective start date
 * for an existing Paye Tax element for an Assignment. If p_validate is false,
 * then set to the Element entry effective start date of the tax information
 * Element. If p_validate is true, then set to null.
 * @param p_effective_end_date Passes the element entry effective end date for
 * existing Paye Tax elements for an Assignment. If p_validate is false, then
 * set to the Element entry effective end date of the tax information Element.
 * If p_validate is true, then set to null.
 * @param p_session_date Determines when the DateTrack operation takes effect.
 * @param p_mode Indicates which DateTrack mode to use when updating the
 * record. You must set the Date Track mode to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_business_group_id Australia Business group in which the employee is
 * present
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
 * @param p_entry_information_category {@rep:casecolumn
 * PAY_ELEMENT_ENTRIES_F.ENTRY_INFORMATION_CATEGORY}
 * @param p_entry_information1 This field holds the current sysdate if no
 * previous entry exists. Alternatively it holds the previous entries entry
 * information1 value.
 * @param p_australian_resident_flag Indicates if the employee is an Australian
 * resident. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_tax_free_threshold_flag Indicates if the tax free threshold is
 * applicable to the employee. Valid values are defined by the 'YES_NO' lookup
 * type.
 * @param p_rebate_amount Rebate amount.
 * @param p_fta_claim_flag Indicates if a Family Tax Allowance claim applies to
 * the employee. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_savings_rebate_flag Indicates if the employee is eligible for a
 * savings rebate. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_help_sfss_flag Indicates if the employee has any HELP or SFSS as
 * tax deductions. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_declaration_signed_date Indicates the date the declaration was
 * signed by the employee.
 * @param p_medicare_levy_variation_code Medicare levy variation code.Valid
 * Values are defined by the 'AU_MED_LEV_VAR' lookup type.
 * @param p_spouse_mls_flag Indicates if the employee's spouse has the Medicare
 * Levy Surcharge as a tax deduction. Valid values are defined by the 'YES_NO'
 * lookup type.
 * @param p_dependent_children Indicates if the employee has any dependent
 * children. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_tax_variation_type Tax variation type.Valid values are
 * Percentage,Fixed amount,Exempt.
 * @param p_tax_variation_amount Tax variation amount.
 * @param p_tax_file_number Tax File Number.
 * @param p_update_warning If p_validate is false,set to true if warnings
 * occurred while processing the element entry.If p_validate is true,then the
 * value will be null.
 * @rep:displayname Maintain PAYE Tax Information for Australia
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  PROCEDURE maintain_PAYE_tax_info
    (p_validate                     IN      BOOLEAN  DEFAULT FALSE
    ,p_assignment_id                IN      NUMBER
    ,p_effective_start_date         IN OUT nocopy DATE
    ,p_effective_end_date           IN OUT nocopy DATE
    ,p_session_date                 IN      DATE
    ,p_mode                         IN      VARCHAR2
    ,p_business_group_id            IN      NUMBER
    ,p_attribute_category           IN      VARCHAR2  DEFAULT NULL
    ,p_attribute1                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute2                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute3                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute4                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute5                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute6                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute7                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute8                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute9                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute10                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute11                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute12                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute13                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute14                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute15                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute16                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute17                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute18                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute19                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute20                  IN      VARCHAR2  DEFAULT NULL
    ,p_entry_information_category   IN      VARCHAR2  DEFAULT NULL
    ,p_entry_information1           IN      VARCHAR2  DEFAULT NULL
    ,p_australian_resident_flag     IN      VARCHAR2
    ,p_tax_free_threshold_flag      IN      VARCHAR2
    ,p_rebate_amount                IN      NUMBER   DEFAULT NULL
    ,p_fta_claim_flag               IN      VARCHAR2
    ,p_savings_rebate_flag          IN      VARCHAR2
    ,p_help_sfss_flag               IN      VARCHAR2     /* Bug# 5258625*/
    ,p_declaration_signed_date      IN      VARCHAR2
    ,p_medicare_levy_variation_code IN      VARCHAR2
    ,p_spouse_mls_flag              IN      VARCHAR2
    ,p_dependent_children           IN      VARCHAR2 DEFAULT NULL
    ,p_tax_variation_type           IN      VARCHAR2
    ,p_tax_variation_amount         IN      NUMBER  DEFAULT NULL
    ,p_tax_file_number              IN      VARCHAR2
    ,p_update_warning                  OUT nocopy  BOOLEAN
    ) ;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< maintain_super_info >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API maintains Superannuation information for Australia.
 *
 * This API updates the element entries of Superannuation element.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business_group_id for Australian Legislation and if valid
 * person_type_id is specified, a corresponding system type of 'APL', must be
 * active and in the same business group as that of the applicant being
 * created. If a person_type_id is not specified the API will use the DEFAULT
 * 'APL' type for the business group
 *
 * <p><b>Post Success</b><br>
 * The element entries of Superannuation Tax element will be successfully
 * updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the element entries of Superannuation element and
 * raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_id Identifies the assignment for which you create the
 * tax information record.
 * @param p_effective_start_date Pass the element entry effective start date
 * for existing Superannuation Tax elements for the assignment. If p_validate
 * is false, then set to the effective start date on the tax information row
 * which now exists as of the effective date. If p_validate is true, then set
 * to null.
 * @param p_effective_end_date Passes the element entry effective end date for
 * existing Superannuation Tax elements for the assignment. If p_validate is
 * false, then set to the effective end date for the tax information. If
 * p_validate is true, then set to null.
 * @param p_session_date Determines when the DateTrack operation takes effect.
 * @param p_mode Indicates which DateTrack mode to use when updating the
 * record. You must set the Date Track mode to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_business_group_id Australia Business group in which the employee is
 * present
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
 * @param p_tfn_for_super_flag Indicates the Tax File Number for Superannuation
 * Contributions. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_update_warning If p_validate is false,set to true if warnings
 * occurred while processing the element entry.If p_validate is true,then the
 * value will be null.
 * @rep:displayname Maintain Superannuation Information for Australia
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  PROCEDURE maintain_SUPER_info
    (p_validate                     IN      BOOLEAN  DEFAULT FALSE
    ,p_assignment_id                IN      NUMBER
    ,p_effective_start_date         IN OUT nocopy  DATE
    ,p_effective_end_date           IN OUT nocopy  DATE
    ,p_session_date                 IN      DATE
    ,p_mode                         IN      VARCHAR2
    ,p_business_group_id            IN      NUMBER
    ,p_attribute_category           IN      VARCHAR2  DEFAULT NULL
    ,p_attribute1                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute2                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute3                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute4                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute5                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute6                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute7                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute8                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute9                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute10                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute11                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute12                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute13                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute14                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute15                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute16                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute17                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute18                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute19                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute20                  IN      VARCHAR2  DEFAULT NULL
    ,p_tfn_for_super_flag           IN      VARCHAR2  DEFAULT NULL
    ,p_update_warning               OUT nocopy     BOOLEAN
    ) ;


    FUNCTION tax_scale
      (p_tax_file_number               IN   VARCHAR2
      ,p_australian_resident_flag      IN   VARCHAR2
      ,p_tax_free_threshold_flag       IN   VARCHAR2
      ,p_lev_lod_flg                   IN   VARCHAR2
      ,p_medicare_levy_variation_code  IN   VARCHAR2
      ,p_tax_variation_type            IN   VARCHAR2
      )
    RETURN INTEGER;

    PROCEDURE Validate_TFN
      (p_tax_file_number               IN   VARCHAR2
      );

procedure create_paye_tax_info
(p_validate                         in      boolean     default false
,p_effective_date                   in      date
,p_business_group_id                in      number
,p_original_entry_id                in      number      default null
,p_assignment_id                    in      number
,p_entry_type                       in      varchar2
,p_cost_allocation_keyflex_id       in      number      default null
,p_updating_action_id               in      number      default null
,p_comment_id                       in      number      default null
,p_reason                           in      varchar2    default null
,p_target_entry_id                  in      number      default null
,p_subpriority                      in      number      default null
,p_date_earned                      in      date        default null
,p_attribute_category               in      varchar2    default null
,p_attribute1                       in      varchar2    default null
,p_attribute2                       in      varchar2    default null
,p_attribute3                       in      varchar2    default null
,p_attribute4                       in      varchar2    default null
,p_attribute5                       in      varchar2    default null
,p_attribute6                       in      varchar2    default null
,p_attribute7                       in      varchar2    default null
,p_attribute8                       in      varchar2    default null
,p_attribute9                       in      varchar2    default null
,p_attribute10                      in      varchar2    default null
,p_attribute11                      in      varchar2    default null
,p_attribute12                      in      varchar2    default null
,p_attribute13                      in      varchar2    default null
,p_attribute14                      in      varchar2    default null
,p_attribute15                      in      varchar2    default null
,p_attribute16                      in      varchar2    default null
,p_attribute17                      in      varchar2    default null
,p_attribute18                      in      varchar2    default null
,p_attribute19                      in      varchar2    default null
,p_attribute20                      in      varchar2    default null
,p_australian_resident_flag         in      varchar2
,p_tax_free_threshold_flag          in      varchar2
,p_rebate_amount                    in      number      default null
,p_fta_claim_flag                   in      varchar2
,p_savings_rebate_flag              in      varchar2
,p_hecs_sfss_flag                   in      varchar2
,p_declaration_signed_date          in      varchar2
,p_medicare_levy_variation_code     in      varchar2
,p_spouse_mls_flag                  in      varchar2
,p_dependent_children               in      varchar2    default null
,p_tax_variation_type               in      varchar2
,p_tax_variation_amount             in      number      default null
,p_tax_file_number                  in      varchar2
,p_effective_start_date                out nocopy date
,p_effective_end_date                  out nocopy date
,p_element_entry_id                    out nocopy number
,p_object_version_number               out nocopy number
,p_create_warning                      out nocopy boolean
);

-- ----------------------------------------------------------------------------
-- |--------------------------< update_adi_tax_crp >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Tax information for Australia for use by Web ADI in the HRMS
 * Configuration Workbench CRP section.  It updates the element entry for the Tax Information
 * element for the Australian legislation, along with updating Assignment
 * information for the given assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business_group_id for Australian Legislation and if valid
 * person_type_id is specified.  An Employee with a primary assignment must exist and be active
 * in the same business group as that of the Tax Information being created.
 *
 * <p><b>Post Success</b><br>
 * The element entries of Tax Information element will be successfully updated and
 * Assignment information successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the element entries of Tax Information element and raises
 * an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_id Identifies the assignment for which you create the
 * tax information record.
 * @param p_effective_date Effective date of information.
 * @param p_hire_date Date when the Employee was hired.  Used as effective date.
 * @param p_business_group_id Australia Business group in which the employee is
 * present
 * @param p_payroll_id Indicates the payroll the Employee's primary assignment belongs to
 * @param p_legal_employer Indicated the Legal Employer Employee's primary assignment belongs to
 * @param p_leave_loading Indicates if Leave Loading is paid to the
 * Employee.  This is a factor when the Tax scale is calculated. Valid  values
 * are defined by the 'YES_NO' lookup type.
 * @param p_basis_of_payment Valid values are Full Time Payees,Part Time Payee, Casual Payee
 * @param p_australian_resident Indicates if the employee is an Australian
 * resident. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_tax_free_threshold Indicates if the tax free threshold is
 * applicable to the employee. Valid values are defined by the 'YES_NO' lookup
 * type.
 * @param p_rebate_amount Rebate amount.
 * @param p_ftb_claim Indicates if a Family Tax Allowance claim applies to
 * the employee. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_savings_rebate Indicates if the employee is eligible for a
 * savings rebate. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_hecs Indicates if the employee has any HECS as a
 * tax deduction. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_sfss Indicates if the employee has any SFSS as a tax deduction.
 * Valid values are defined by the 'YES_NO' lookup type.
 * @param p_declaration_signed_date Indicates the date the declaration was
 * signed by the employee.
 * @param p_medicare_levy_exemption Medicare levy exemption code.Valid
 * values are defined by the 'AU_MED_LEV_VAR' lookup type.
 * @param p_medicare_levy_spouse Indicates if the employee has a spouse
 * @param p_medicare_levy_surcharge Indicates if the employee's spouse has the Medicare
 * Levy Surcharge as a tax deduction. Valid values are defined by the 'YES_NO'
 * lookup type.
 * @param p_medicare_levy_dep_children Indicates if the employee has any dependent
 * children.
 * @param p_tax_variation_type Tax variation type.Valid values are
 * Percentage,Fixed amount,Exempt,None.
 * @param p_tax_variation_amount Tax variation amount.
 * @param p_tax_variation_bonus  Tax variation on Bonus. Valid values 'Yes','No'.
 * @param p_tax_file_number Tax File Number.
 * @param p_senior_australian Indicates if the Employee is a senior citizen.
 * @rep:displayname Create Tax Information for Australia
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
  procedure update_adi_tax_crp
  (p_validate                     in boolean     default false
  ,p_assignment_id                in number
  ,p_hire_date                    in date
  ,p_business_group_id            in number
  ,p_payroll_id                   in number
  ,p_legal_employer               in varchar2
  ,p_tax_file_number              in varchar2
  ,p_tax_free_threshold           in varchar2
  ,p_australian_resident          in varchar2
  ,p_hecs                         in varchar2
  ,p_sfss                         in varchar2
  ,p_leave_loading                in varchar2
  ,p_basis_of_payment             in varchar2
  ,p_declaration_signed_date      in varchar2
  ,p_medicare_levy_surcharge      in varchar2
  ,p_medicare_levy_exemption      in varchar2
  ,p_medicare_levy_dep_children   in varchar2    default null
  ,p_medicare_levy_spouse         in varchar2
  ,p_tax_variation_type           in varchar2
  ,p_tax_variation_amount         in number      default null
  ,p_tax_variation_bonus          in varchar2
  ,p_rebate_amount                in number      default null
  ,p_savings_rebate               in varchar2
  ,p_ftb_claim                    in varchar2
  ,p_senior_australian            in varchar2
  ,p_effective_date               in date        default null
  );

END hr_au_tax_api ;

/
