--------------------------------------------------------
--  DDL for Package PY_DK_TAX_CARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_DK_TAX_CARD" AUTHID CURRENT_USER AS
/* $Header: pydktaxc.pkh 120.0.12010000.1 2008/07/27 22:27:29 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_taxcard >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API will insert a tax card entry for a Norway Assignment.
--  This API delegates to the create_element_entry procedure of the
--  pay_element_entry_api package.
--
-- Prerequisites:
--  The element entry (of element type 'Tax Card') and the corresponding
--  element link should exist for the given assignment and business group.
--
-- In Parameters:
--  Name                Reqd    Type     Description
--  p_legislation_code  Yes     VARCHAR2 Legislation code.
--  p_effective_date    Yes     DATE     The effective date of the
--                                       change.
--  p_assignment_id     Yes     VARCHAR2 Id of the assignment.
--  p_person_id         Yes     VARCHAR2 Id of the person.
--  p_business_group_id Yes     VARCHAR2 Id of the business group.
--  p_tax_free_threshold        NUMBER   Element entry value.
--  p_weekly_td                 NUMBER   Element entry value.
--  p_daily_td                  DATE     Element entry value.
--  p_registration_date         DATE     Element entry value.
--  p_method_of_receipt         VARCHAR2 Element entry value.
--  p_tax_card_type             VARCHAR2 Element entry value.
--  p_tax_percentage            VARCHAR2 Element entry value.
--  p_monthly_td                VARCHAR2 Element entry value.
--  p_biweekly_td               VARCHAR2 Element entry value.
--  p_date_returned             DATE     Element entry value.
--  p_element_entry_id          VARCHAR2 Id of the element entry.
--  p_element_link_id           VARCHAR2 Id of the element link.
--
--
-- Post Success:
--
--  The API successfully updates the tax card entry.
--
-- Post Failure:
--   The API will raise an error.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
--
   PROCEDURE insert_taxcard (
    p_legislation_code      IN  VARCHAR2
    ,p_effective_date       IN  DATE
    ,p_assignment_id        IN  VARCHAR2
    ,p_person_id            IN  VARCHAR2
    ,p_business_group_id    IN  VARCHAR2
    ,p_tax_free_threshold   IN  NUMBER      DEFAULT NULL
    ,p_weekly_td            IN  NUMBER      DEFAULT NULL
    ,p_daily_td             IN  NUMBER      DEFAULT NULL
    ,p_registration_date    IN  DATE        DEFAULT NULL
    ,p_method_of_receipt    IN  VARCHAR2    DEFAULT NULL
    ,p_tax_card_type        IN  VARCHAR2    DEFAULT NULL
    ,p_tax_percentage       IN  NUMBER      DEFAULT NULL
    ,p_monthly_td           IN  NUMBER      DEFAULT NULL
    ,p_biweekly_td          IN  NUMBER      DEFAULT NULL
    ,p_date_returned        IN  DATE        DEFAULT NULL);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_taxcard >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API will update the tax card entry for a Norway Assignment.
--  This API delegates to the update_element_entry procedure of the
--  pay_element_entry_api package.
--
-- Prerequisites:
--  The element entry (of element type 'Tax Card') and the corresponding
--  element link should exist for the given assignment and business group.
--
-- In Parameters:
--  Name            Reqd    Type     Description
--  p_legislation_code      Yes     VARCHAR2 Legislation code.
--  p_effective_date        Yes     DATE     The effective date of the
--                                       change.
--  p_assignment_id         Yes     VARCHAR2 Id of the assignment.
--  p_person_id             Yes     VARCHAR2 Id of the person.
--  p_business_group_id     Yes     VARCHAR2 Id of the business group.
--  p_tax_free_threshold            NUMBER   Element entry value.
--  p_weekly_td                     NUMBER   Element entry value.
--  p_daily_td                      DATE     Element entry value.
--  p_registration_date             DATE     Element entry value.
--  p_method_of_receipt             VARCHAR2 Element entry value.
--  p_tax_card_type                 VARCHAR2 Element entry value.
--  p_tax_percentage                VARCHAR2 Element entry value.
--  p_monthly_td                    VARCHAR2 Element entry value.
--  p_biweekly_td                   VARCHAR2 Element entry value.
--  p_date_returned                 DATE     Element entry value.
--  p_element_entry_id              VARCHAR2 Id of the element entry.
--  p_element_link_id               VARCHAR2 Id of the element link.
--  p_object_version_number Yes     VARCHAR2 Version number of the element
--                                           entry record.
--  p_input_value_id1               VARCHAR2 Id of the input value 1 for the
--                                              element.
--  p_input_value_id2               VARCHAR2 Id of the input value 2 for the
--                                               element.
--  p_input_value_id3               VARCHAR2 Id of the input value 3 for the
--                                              element.
--  p_input_value_id4               VARCHAR2 Id of the input value 4 for the
--                                              element.
--  p_input_value_id5               VARCHAR2 Id of the input value 5 for the
--                                              element.
--  p_input_value_id6               VARCHAR2 Id of the input value 6 for the
--                                              element.
--  p_input_value_id7               VARCHAR2 Id of the input value 7 for the
--                                               element.
--  p_input_value_id8               VARCHAR2 Id of the input value 8 for the
--                                               element.
--  p_input_value_id9               VARCHAR2 Id of the input value 9 for the
--                                               element.
--  p_datetrack_update_mode         VARCHAR2 The date track update mode for
--                                              the record
--
--
-- Post Success:
--
--  The API successfully updates the tax card entry.
--
-- Post Failure:
--   The API will raise an error.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
--
PROCEDURE update_taxcard (
    p_legislation_code      IN  VARCHAR2
    ,p_effective_date       IN  DATE
    ,p_assignment_id        IN  VARCHAR2
    ,p_person_id            IN  VARCHAR2
    ,p_business_group_id    IN  VARCHAR2
    ,p_tax_free_threshold   IN  NUMBER      DEFAULT NULL
    ,p_weekly_td            IN  NUMBER      DEFAULT NULL
    ,p_daily_td             IN  NUMBER      DEFAULT NULL
    ,p_registration_date    IN  DATE        DEFAULT NULL
    ,p_method_of_receipt    IN  VARCHAR2    DEFAULT NULL
    ,p_tax_card_type        IN  VARCHAR2    DEFAULT NULL
    ,p_tax_percentage       IN  NUMBER      DEFAULT NULL
    ,p_monthly_td           IN  NUMBER      DEFAULT NULL
    ,p_biweekly_td          IN  NUMBER      DEFAULT NULL
    ,p_date_returned        IN  DATE        DEFAULT NULL
    ,p_element_entry_id     IN  VARCHAR2
    ,p_element_link_id      IN  VARCHAR2
    ,p_object_version_number IN  VARCHAR2
    ,p_input_value_id1      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id2      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id3      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id4      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id5      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id6      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id7      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id8      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id9      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id10     IN  VARCHAR2    DEFAULT NULL
    ,p_datetrack_update_mode    IN  VARCHAR2    DEFAULT NULL);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns the DT modes for pay_element_entries_f for a given
--  element_entry_id (base key value) on a specified date
--
-- Prerequisites:
--   The element_entry (p_base_key_value) must exist as of the effective date
--   of the change (p_effective_date).
--
-- In Parameters:
--  Name                Reqd    Type    Description
--  p_effective_date    Yes     DATE    The effective date of the
--                                              change.
--  p_base_key_value    Yes     NUMBER  ID of the element entry.
--
--
-- Post Success:
--
--   The API sets the following out parameters:
--
--  Name                    Type    Description
--  p_correction            BOOLEAN True if correction mode is valid.
--  p_update                BOOLEAN True if update mode is valid.
--  p_update_override       BOOLEAN True if update override mode is valid.
--  p_update_change_insert  BOOLEAN True if update change insert mode is
--                                  valid.
--  p_update_start_date     DATE    Start date for Update record.
--  p_update_end_date       DATE    End date for Update record.
--  p_override_start_date   DATE    Start date for Override.
--  p_override_end_date     DATE    End date for Overrride.
--  p_upd_chg_start_date    DATE    Start date for Update Change.
--  p_upd_chg_end_date      DATE    End date for Update Change.

-- Post Failure:
--   The API will raise an error.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
--
PROCEDURE  find_dt_upd_modes(
    p_effective_date            IN          DATE
    ,p_base_key_value           IN          NUMBER
    ,p_correction               OUT NOCOPY  BOOLEAN
    ,p_update                   OUT NOCOPY  BOOLEAN
    ,p_update_override          OUT NOCOPY  BOOLEAN
    ,p_update_change_insert     OUT NOCOPY  BOOLEAN
    ,p_correction_start_date    OUT NOCOPY  DATE
    ,p_correction_end_date      OUT NOCOPY  DATE
    ,p_update_start_date        OUT NOCOPY  DATE
    ,p_update_end_date          OUT NOCOPY  DATE
    ,p_override_start_date      OUT NOCOPY  DATE
    ,p_override_end_date        OUT NOCOPY  DATE
    ,p_upd_chg_start_date       OUT NOCOPY  DATE
    ,p_upd_chg_end_date         OUT NOCOPY  DATE);
--
-- -----------------------------------------------------------------------------
-- |--------------------------< get_global_value >-----------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start of Comments}
--
-- Description:
--   Returns the value for the global on a given date.
--
-- Prerequisites:
--   None
--
-- In Parameters
--  Name            Reqd    Type        Description
--  p_global_name       Yes VARCHAR2    Assignment id
--  p_legislation_code  Yes VARCHAR2    Legislation Code
--  p_effective_date    Yes DATE        Effective date
--
-- Post Success:
--   The value of the global of type FF_GLOBALS_F.GLOBAL_VALUE is returned
--
-- Post Failure:
--   An error is raised
--
-- Access Status:
--   Internal Development Use Only
--
-- {End of Comments}
--
FUNCTION get_global_value(
    p_global_name       VARCHAR2
    ,p_legislation_code VARCHAR2
    ,p_effective_date   DATE) RETURN ff_globals_f.global_value%TYPE;


END py_dk_tax_card;


/
