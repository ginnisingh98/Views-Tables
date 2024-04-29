--------------------------------------------------------
--  DDL for Package PY_FI_TAX_CARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_FI_TAX_CARD" AUTHID CURRENT_USER AS
/* $Header: pyfitaxc.pkh 120.1 2007/02/22 11:51:18 dbehera noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< ins >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will insert a tax and tax card entry for a Finland Assignment.
--      This API delegates to the create_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_tc           Yes             VARCHAR2                Element entry Id for Tax Card Element.
--      p_element_entry_id_t            Yes             VARCHAR2                Element entry Id for Tax Element.
--      p_taxcard_type                                  VARCHAR2                Tax Card Type.
--      p_method_of_receipt                             VARCHAR2                Method of Receipt.
--      p_base_rate                                     NUMBER                  Base Rate.
--      p_tax_municipality                              VARCHAR2                Tax Municipality
--      p_additional_rate                               NUMBER                  Additional Rate.
--      p_override_manual_upd                           VARCHAR2                Override Manual Update Flag.
--      p_previous_income                               NUMBER                  Previous Income.
--      p_yearly_income_limit                           NUMBER                  Yearly Income Limit.
--      p_date_returned                                 DATE                    Date Returned.
--      p_registration_date                             DATE                    Registration Date.
--      p_lower_income_percentage          Number                Lower Income Percentage
--      p_primary_employment                            VARCHAR2                Primary Employment Flag.
--      p_extra_income_rate                             NUMBER                  Extra Income Rate.
--      p_extra_income_add_rate                         NUMBER                  Extra Income Additional Rate.
--      p_extra_income_limit                            NUMBER                  Extra Income Limit.
--      p_prev_extra_income                             NUMBER                  Previous Extra Income.
--
-- Post Success:
--      The API successfully inserts a tax card and/or tax entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
   PROCEDURE ins (
        p_legislation_code              IN      VARCHAR2
        ,p_effective_date               IN      DATE
        ,p_assignment_id                IN      VARCHAR2
        ,p_person_id                    IN      VARCHAR2
        ,p_business_group_id            IN      VARCHAR2
        ,p_element_entry_id_tc          IN      VARCHAR2
        ,p_element_entry_id_t           IN      VARCHAR2
        ,p_taxcard_type                 IN      VARCHAR2        DEFAULT NULL
        ,p_method_of_receipt            IN      VARCHAR2        DEFAULT NULL
        ,p_base_rate                    IN      NUMBER          DEFAULT NULL
        ,p_tax_municipality             IN      VARCHAR2        DEFAULT NULL
        ,p_additional_rate              IN      NUMBER          DEFAULT NULL
        ,p_override_manual_upd          IN      VARCHAR2        DEFAULT NULL
        ,p_previous_income              IN      NUMBER          DEFAULT NULL
        ,p_yearly_income_limit          IN      NUMBER          DEFAULT NULL
        ,p_date_returned                IN      DATE            DEFAULT NULL
        ,p_registration_date            IN      DATE            DEFAULT NULL
	,p_lower_income_percentage          IN      NUMBER          DEFAULT NULL
        ,p_primary_employment           IN      VARCHAR2        DEFAULT NULL
        ,p_extra_income_rate            IN      NUMBER          DEFAULT NULL
        ,p_extra_income_add_rate        IN      NUMBER          DEFAULT NULL
        ,p_extra_income_limit           IN      NUMBER          DEFAULT NULL
        ,p_prev_extra_income            IN      NUMBER          DEFAULT NULL);
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_taxcard >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will insert a tax card entry for a Finland Assignment.
--      This API delegates to the create_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_tc           Yes             VARCHAR2                Element entry Id for Tax Card Element.
--      p_element_entry_id_t            Yes             VARCHAR2                Element entry Id for Tax Element.
--      p_taxcard_type                                  VARCHAR2                Tax Card Type.
--      p_method_of_receipt                             VARCHAR2                Method of Receipt.
--      p_base_rate                                     NUMBER                  Base Rate.
--      p_tax_municipality                              VARCHAR2                Tax Municipality
--      p_additional_rate                               NUMBER                  Additional Rate.
--      p_override_manual_upd                           VARCHAR2                Override Manual Update Flag.
--      p_previous_income                               NUMBER                  Previous Income.
--      p_yearly_income_limit                           NUMBER                  Yearly Income Limit.
--      p_date_returned                                 DATE                    Date Returned.
--      p_registration_date                             DATE                    Registration Date.
--      p_lower_income_percentage          Number                Lower Income Percentage
--
-- Post Success:
--      The API successfully inserts the tax card entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
PROCEDURE insert_taxcard (
        p_legislation_code              IN      VARCHAR2
        ,p_effective_date               IN      DATE
        ,p_assignment_id                IN      VARCHAR2
        ,p_person_id                    IN      VARCHAR2
        ,p_business_group_id            IN      VARCHAR2
        ,p_element_entry_id_tc          IN      VARCHAR2
        ,p_taxcard_type                 IN      VARCHAR2        DEFAULT NULL
        ,p_method_of_receipt            IN      VARCHAR2        DEFAULT NULL
        ,p_base_rate                    IN      NUMBER          DEFAULT NULL
        ,p_tax_municipality             IN      VARCHAR2        DEFAULT NULL
        ,p_additional_rate              IN      NUMBER          DEFAULT NULL
        ,p_override_manual_upd          IN      VARCHAR2        DEFAULT NULL
        ,p_previous_income              IN      NUMBER          DEFAULT NULL
        ,p_yearly_income_limit          IN      NUMBER          DEFAULT NULL
        ,p_date_returned                IN      DATE            DEFAULT NULL
        ,p_registration_date            IN      DATE            DEFAULT NULL
	,p_lower_income_percentage              IN      NUMBER          DEFAULT NULL);
--
-- ----------------------------------------------------------------------------
-- |------------------------< insert_tax >-------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will insert a tax  entry for a Finland Assignment.
--      This API delegates to the create_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_tc           Yes             VARCHAR2                Element entry Id for Tax Card Element.
--      p_element_entry_id_t            Yes             VARCHAR2                Element entry Id for Tax Element.
--      p_primary_employment                            VARCHAR2                Primary Employment Flag.
--      p_extra_income_rate                             NUMBER                  Extra Income Rate.
--      p_extra_income_add_rate                         NUMBER                  Extra Income Additional Rate.
--      p_extra_income_limit                            NUMBER                  Extra Income Limit.
--      p_prev_extra_income                             NUMBER                  Previous Extra Income.
--
-- Post Success:
--      The API successfully inserts the tax card entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
  PROCEDURE insert_tax (
        p_legislation_code              IN      VARCHAR2
        ,p_effective_date               IN      DATE
        ,p_assignment_id                IN      VARCHAR2
        ,p_person_id                    IN      VARCHAR2
        ,p_business_group_id            IN      VARCHAR2
        ,p_element_entry_id_t           IN      VARCHAR2
        ,p_primary_employment           IN      VARCHAR2        DEFAULT NULL
        ,p_extra_income_rate            IN      NUMBER          DEFAULT NULL
        ,p_extra_income_add_rate        IN      NUMBER          DEFAULT NULL
        ,p_extra_income_limit           IN      NUMBER          DEFAULT NULL
        ,p_prev_extra_income            IN      NUMBER          DEFAULT NULL);
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< upd >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will update a tax and tax card entry for a Finland Assignment.
--      This API delegates to the update_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element entry (of element type 'Tax Card' and 'Tax) and the
--      corresponding element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_tc           Yes             VARCHAR2                Element entry Id for Tax Card Element.
--      p_element_entry_id_t            Yes             VARCHAR2                Element entry Id for Tax Element.
--      p_taxcard_type                                  VARCHAR2                Tax Card Type.
--      p_method_of_receipt                             VARCHAR2                Method of Receipt.
--      p_base_rate                                     NUMBER                  Base Rate.
--      p_tax_municipality                              VARCHAR2                Tax Municipality
--      p_additional_rate                               NUMBER                  Additional Rate.
--      p_override_manual_upd                           VARCHAR2                Override Manual Update Flag.
--      p_previous_income                               NUMBER                  Previous Income.
--      p_yearly_income_limit                           NUMBER                  Yearly Income Limit.
--      p_date_returned                                 DATE                    Date Returned.
--      p_registration_date                             DATE                    Registration Date.
--      p_lower_income_percentage          Number                Lower Income Percentage
--      p_primary_employment                            VARCHAR2                Primary Employment Flag.
--      p_extra_income_rate                             NUMBER                  Extra Income Rate.
--      p_extra_income_add_rate                         NUMBER                  Extra Income Additional Rate.
--      p_extra_income_limit                            NUMBER                  Extra Income Limit.
--      p_prev_extra_income                             NUMBER                  Previous Extra Income.
--      p_input_value_id1                               VARCHAR2                Input Value Id for Entry 1
--      p_input_value_id2                               VARCHAR2                Input Value Id for Entry 2
--      p_input_value_id3                               VARCHAR2                Input Value Id for Entry 3
--      p_input_value_id4                               VARCHAR2                Input Value Id for Entry 4
--      p_input_value_id5                               VARCHAR2                Input Value Id for Entry 5
--      p_input_value_id6                               VARCHAR2                Input Value Id for Entry 6
--      p_input_value_id7                               VARCHAR2                Input Value Id for Entry 7
--      p_input_value_id8                               VARCHAR2                Input Value Id for Entry 8
--      p_input_value_id9                               VARCHAR2                Input Value Id for Entry 9
--      p_input_value_id10                              VARCHAR2                Input Value Id for Entry 10
--      p_input_value_id11                              VARCHAR2                Input Value Id for Entry 11
--      p_input_value_id12                              VARCHAR2                Input Value Id for Entry 12
--      p_input_value_id13                              VARCHAR2                Input Value Id for Entry 13
--      p_input_value_id14                              VARCHAR2                Input Value Id for Entry 14
--      p_input_value_id15                              VARCHAR2                Input Value Id for Entry 15
--      p_input_value_id16                              VARCHAR2                Input Value Id for Entry 16
--      p_datetrack_update_mode                         VARCHAR2                The date track mode.
--      p_object_version_number_tc                      VARCHAR2                Object Version Number for Tax Card.
--      p_object_version_number_t                       VARCHAR2                Object Version Number for Tax.
--
-- Post Success:
--      The API successfully updates the tax card and/or tax entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
PROCEDURE upd (
        p_legislation_code                      IN      VARCHAR2
        ,p_effective_date                       IN      DATE
        ,p_assignment_id                        IN      VARCHAR2
        ,p_person_id                            IN      VARCHAR2
        ,p_business_group_id                    IN      VARCHAR2
        ,p_element_entry_id_tc                  IN      VARCHAR2
        ,p_element_entry_id_t                   IN      VARCHAR2
        ,p_taxcard_type                         IN      VARCHAR2        DEFAULT NULL
        ,p_method_of_receipt                    IN      VARCHAR2        DEFAULT NULL
        ,p_base_rate                            IN      NUMBER          DEFAULT NULL
        ,p_tax_municipality                     IN      VARCHAR2        DEFAULT NULL
        ,p_additional_rate                      IN      NUMBER          DEFAULT NULL
        ,p_override_manual_upd                  IN      VARCHAR2        DEFAULT NULL
        ,p_previous_income                      IN      NUMBER          DEFAULT NULL
        ,p_yearly_income_limit                  IN      NUMBER          DEFAULT NULL
        ,p_date_returned                        IN      DATE            DEFAULT NULL
        ,p_registration_date                    IN      DATE            DEFAULT NULL
	,p_lower_income_percentage  IN      NUMBER          DEFAULT NULL
        ,p_primary_employment                   IN      VARCHAR2        DEFAULT NULL
        ,p_extra_income_rate                    IN      NUMBER          DEFAULT NULL
        ,p_extra_income_add_rate                IN      NUMBER          DEFAULT NULL
        ,p_extra_income_limit                   IN      NUMBER          DEFAULT NULL
        ,p_prev_extra_income                    IN      NUMBER          DEFAULT NULL
        ,p_input_value_id1                      IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id2                      IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id3                      IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id4                      IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id5                      IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id6                      IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id7                      IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id8                      IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id9                      IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id10                     IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id11                     IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id12                     IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id13                     IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id14                     IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id15                     IN      VARCHAR2        DEFAULT NULL
       ,p_input_value_id16                     IN      VARCHAR2        DEFAULT NULL
        ,p_datetrack_update_mode                IN      VARCHAR2        DEFAULT NULL
        ,p_object_version_number_tc             IN      VARCHAR2
        ,p_object_version_number_t              IN      VARCHAR2        DEFAULT NULL);
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_taxcard >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will update a tax card entry for a Finland Assignment.
--      This API delegates to the update_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element entry (of element type 'Tax Card' ) and the
--      corresponding element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_tc           Yes             VARCHAR2                Element entry Id for Tax Card Element.
--      p_taxcard_type                                  VARCHAR2                Tax Card Type.
--      p_method_of_receipt                             VARCHAR2                Method of Receipt.
--      p_base_rate                                     NUMBER                  Base Rate.
--      p_tax_municipality                              VARCHAR2                Tax Municipality
--      p_additional_rate                               NUMBER                  Additional Rate.
--      p_override_manual_upd                           VARCHAR2                Override Manual Update Flag.
--      p_previous_income                               NUMBER                  Previous Income.
--      p_yearly_income_limit                           NUMBER                  Yearly Income Limit.
--      p_date_returned                                 DATE                    Date Returned.
--      p_registration_date                             DATE                    Registration Date.
--      p_lower_income_percentage          Number                Lower Income Percentage
--      p_input_value_id1                               VARCHAR2                Input Value Id for Entry 1
--      p_input_value_id2                               VARCHAR2                Input Value Id for Entry 2
--      p_input_value_id3                               VARCHAR2                Input Value Id for Entry 3
--      p_input_value_id4                               VARCHAR2                Input Value Id for Entry 4
--      p_input_value_id5                               VARCHAR2                Input Value Id for Entry 5
--      p_input_value_id6                               VARCHAR2                Input Value Id for Entry 6
--      p_input_value_id7                               VARCHAR2                Input Value Id for Entry 7
--      p_input_value_id8                               VARCHAR2                Input Value Id for Entry 8
--      p_input_value_id9                               VARCHAR2                Input Value Id for Entry 9
--      p_input_value_id10                              VARCHAR2                Input Value Id for Entry 10
--      p_input_value_id11                              VARCHAR2                Input Value Id for Entry 11
--      p_datetrack_update_mode                         VARCHAR2                The date track mode.
--      p_object_version_number                         VARCHAR2                Object Version Number for Tax Card.
--
-- Post Success:
--      The API successfully updates the tax card and/or tax entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
        PROCEDURE update_taxcard (
        p_legislation_code              IN      VARCHAR2
        ,p_effective_date               IN      DATE
        ,p_assignment_id                IN      VARCHAR2
        ,p_person_id                    IN      VARCHAR2
        ,p_business_group_id            IN      VARCHAR2
        ,p_element_entry_id_tc          IN      VARCHAR2
        ,p_taxcard_type                 IN      VARCHAR2        DEFAULT NULL
        ,p_method_of_receipt            IN      VARCHAR2        DEFAULT NULL
        ,p_base_rate                    IN      NUMBER          DEFAULT NULL
        ,p_tax_municipality             IN      VARCHAR2        DEFAULT NULL
        ,p_additional_rate              IN      NUMBER          DEFAULT NULL
        ,p_override_manual_upd          IN      VARCHAR2        DEFAULT NULL
        ,p_previous_income              IN      NUMBER          DEFAULT NULL
        ,p_yearly_income_limit          IN      NUMBER          DEFAULT NULL
        ,p_date_returned                IN      DATE            DEFAULT NULL
        ,p_registration_date            IN      DATE            DEFAULT NULL
	,p_lower_income_percentage        IN      NUMBER          DEFAULT NULL
        ,p_input_value_id1              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id2              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id3              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id4              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id5              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id6              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id7              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id8              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id9              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id10             IN      VARCHAR2        DEFAULT NULL
	,p_input_value_id11             IN      VARCHAR2        DEFAULT NULL
        ,p_datetrack_update_mode        IN      VARCHAR2        DEFAULT NULL
        ,p_object_version_number        IN      VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_tax >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will update a tax entry for a Finland Assignment.
--      This API delegates to the update_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element entry (of element type  'Tax) and the
--      corresponding element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_t            Yes             VARCHAR2                Element entry Id for Tax Element.
--      p_primary_employment                            VARCHAR2                Primary Employment Flag.
--      p_extra_income_rate                             NUMBER                  Extra Income Rate.
--      p_extra_income_add_rate                         NUMBER                  Extra Income Additional Rate.
--      p_extra_income_limit                            NUMBER                  Extra Income Limit.
--      p_prev_extra_income                             NUMBER                  Previous Extra Income.
--      p_input_value_id1                               VARCHAR2                Input Value Id for Entry 1
--      p_input_value_id2                               VARCHAR2                Input Value Id for Entry 2
--      p_input_value_id3                               VARCHAR2                Input Value Id for Entry 3
--      p_input_value_id4                               VARCHAR2                Input Value Id for Entry 4
--      p_input_value_id5                               VARCHAR2                Input Value Id for Entry 5
--      p_datetrack_update_mode                         VARCHAR2                The date track mode.
--      p_object_version_number                         VARCHAR2                Object Version Number for Tax.
--
-- Post Success:
--      The API successfully updates the tax card and/or tax entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
        PROCEDURE update_tax (
        p_legislation_code              IN      VARCHAR2
        ,p_effective_date               IN      DATE
        ,p_assignment_id                IN      VARCHAR2
        ,p_person_id                    IN      VARCHAR2
        ,p_business_group_id            IN      VARCHAR2
        ,p_element_entry_id_t           IN      VARCHAR2
        ,p_primary_employment           IN      VARCHAR2        DEFAULT NULL
        ,p_extra_income_rate            IN      NUMBER          DEFAULT NULL
        ,p_extra_income_add_rate        IN      NUMBER          DEFAULT NULL
        ,p_extra_income_limit           IN      NUMBER          DEFAULT NULL
        ,p_prev_extra_income            IN      NUMBER          DEFAULT NULL
        ,p_input_value_id1              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id2              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id3              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id4              IN      VARCHAR2        DEFAULT NULL
        ,p_input_value_id5              IN      VARCHAR2        DEFAULT NULL
        ,p_datetrack_update_mode        IN      VARCHAR2        DEFAULT NULL
        ,p_object_version_number        IN      VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< find_dt_upd_modes >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns the DT modes for pay_element_entries_f for a given
--      element_entry_id (base key value) on a specified date
--
-- Prerequisites:
--   The element_entry (p_base_key_value) must exist as of the effective date
--   of the change (p_effective_date).
--
-- In Parameters:
--      Name                            Reqd            Type            Description
--      p_effective_date                Yes             DATE            The effective date of the change.
--      p_base_key_value                Yes             NUMBER          ID of the element entry.
--
--
-- Post Success:
--
--   The API sets the following out parameters:
--
--      Name                            Type            Description
--      p_correction                    BOOLEAN         True if  correction mode is valid.
--      p_update                        BOOLEAN         True if update mode is valid.
--      p_update_override               BOOLEAN         True if update override mode is valid.
--      p_update_change_insert          BOOLEAN         True if update change insert mode is valid.
--      p_update_start_date             DATE            Start date for Update record.
--      p_update_end_date               DATE            End date for Update record.
--      p_override_start_date           DATE            Start date for Override.
--      p_override_end_date             DATE            End date for Overrride.
--      p_upd_chg_start_date            DATE            Start date for Update Change.
--      p_upd_chg_end_date              DATE            End date for Update Change.

-- Post Failure:
--   The API will raise an error.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
--
PROCEDURE  find_dt_upd_modes(
        p_effective_date                IN              DATE
        ,p_base_key_value               IN              NUMBER
        ,p_correction                   OUT NOCOPY      BOOLEAN
        ,p_update                       OUT NOCOPY      BOOLEAN
        ,p_update_override              OUT NOCOPY      BOOLEAN
        ,p_update_change_insert         OUT NOCOPY      BOOLEAN
        ,p_correction_start_date        OUT NOCOPY      DATE
        ,p_correction_end_date          OUT NOCOPY      DATE
        ,p_update_start_date            OUT NOCOPY      DATE
        ,p_update_end_date              OUT NOCOPY      DATE
        ,p_override_start_date          OUT NOCOPY      DATE
        ,p_override_end_date            OUT NOCOPY      DATE
        ,p_upd_chg_start_date           OUT NOCOPY      DATE
        ,p_upd_chg_end_date             OUT NOCOPY      DATE);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< is_primary_asg >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns true / false based on whether the given
--      assignment Id is a Primary Assignment or not.
--
-- Prerequisites:
--   The assignment Id should exist as of the effective date specified.
--
-- In Parameters:
--      Name                    Reqd            Type                                            Description
--      p_effective_date        Yes             VARCHAR2                                        The effective date of the change.
--      p_assignment_id         Yes             per_all_assignments_f.assignment_id%TYPE        ID of the assignment
--
--
-- Post Success:
--      The function returns true if the assignment is Primary and false otherwise
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
  FUNCTION is_primary_asg (
        p_assignment_id                 IN      per_all_assignments_f.assignment_id%TYPE,
        p_effective_date                IN      VARCHAR2) RETURN BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< is_element_attached >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns true / false based on whether the given
--      element is attached to the assignment Id on the given effective date
--
-- Prerequisites:
--   The assignment and the element entry should exist as of the effective date specified.
--
-- In Parameters:
--      Name                    Reqd            Type                                            Description
--      p_effective_date        Yes             VARCHAR2                                        The effective date of the change.
--      p_assignment_id         Yes             per_all_assignments_f.assignment_id%TYPE        ID of the assignment
--      p_business_group_id     Yes             pay_element_links_f.business_group_id%TYPE      Business Group Id.
--      p_element_name  Yes                     pay_element_types_f.element_name%TYPE           Name of the Element to be checked.
--
--
-- Post Success:
--      The function returns true if the element is attached to the assignment and false otherwise.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
  FUNCTION is_element_attached (
        p_assignment_id                 IN      pay_element_entries_f.assignment_id%TYPE,
        p_business_group_id             IN      pay_element_links_f.business_group_id%TYPE,
        p_element_name          IN      pay_element_types_f.element_name%TYPE,
        p_effective_date                        IN      VARCHAR2) RETURN BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |---------------< is_element_started_today >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns true / false based on whether the given
--      elements start date is the effective date.
--
-- Prerequisites:
--   The assignment and the element entry should exist as of the effective date specified.
--
-- In Parameters:
--      Name                            Reqd            Type                                            Description
--      p_effective_date                Yes             VARCHAR2                                        The effective date of the change.
--      p_assignment_id                 Yes             per_all_assignments_f.assignment_id%TYPE        ID of the assignment
--      p_element_name  Yes                             pay_element_types_f.element_name%TYPE           Name of the Element to be checked.
--
--
-- Post Success:
--      The function returns true if the start date of the element is equals the effectived date
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
  FUNCTION is_element_started_today (
        p_assignment_id          IN      pay_element_entries_f.assignment_id%TYPE,
        p_element_name           IN      pay_element_types_f.element_name%TYPE,
        p_effective_date         IN      VARCHAR2) RETURN BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |------------------< find_element_entry_id >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns the element entry id of the element whose name is specified , that is attached to
--       the assignment on the given effective date
--
-- Prerequisites:
--   The assignment and the element entry should exist as of the effective date specified.
--
-- In Parameters:
--      Name                            Reqd            Type                                            Description
--      p_effective_date                Yes             VARCHAR2                                        The effective date of the change.
--      p_assignment_id                 Yes             per_all_assignments_f.assignment_id%TYPE        ID of the assignment
--      p_business_group_id             Yes             pay_element_links_f.business_group_id%TYPE      Business Group Id.
--      p_element_name                  Yes             pay_element_types_f.element_name%TYPE           Name of the Element to be checked.
--
--
-- Post Success:
--      The function returns  the id of the element entry.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
  FUNCTION find_element_entry_id (
        p_assignment_id                 IN      pay_element_entries_f.assignment_id%TYPE,
        p_business_group_id             IN      pay_element_links_f.business_group_id%TYPE,
        p_element_name                  IN      pay_element_types_f.element_name%TYPE,
        p_effective_date                IN      VARCHAR2) RETURN pay_element_entries_f.element_entry_id%TYPE;

END py_fi_tax_card;


/
