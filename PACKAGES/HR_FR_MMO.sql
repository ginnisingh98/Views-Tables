--------------------------------------------------------
--  DDL for Package HR_FR_MMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_MMO" AUTHID CURRENT_USER as
/* $Header: hrfrmmo.pkh 120.0 2005/05/30 21:03:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
-- None.
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< Get_formula >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the formula_id of the formula to be used
-- to get the starting and leaving reason in the MMO report .. It will either
-- be the id for the USER_MMO_REASON or TEMPLATE_MMO_REASON formula
--
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_session_date
--
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function Get_formula (p_business_group_id IN Number,
                      p_session_date      IN  date) Return Number;
--
pragma restrict_references(Get_formula,WNDS,WNPS);

-- ----------------------------------------------------------------------------
-- |------------------------< Get_start_date >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the start date of people found to have left
--   the establishment in the period.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   person_id
--   establishment_id
--   end date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function Get_start_date
            (p_person_id         IN Number,
             p_establishment_id  IN Number,
             p_end_date          IN date,
             p_include_suspended IN VARCHAR
            )                  RETURN Date;
pragma restrict_references(Get_start_date,WNDS,WNPS);

--
-- ----------------------------------------------------------------------------
-- |---------------------------< Get_end_date >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the end date of people found to have joined the
--   establishment in the period
--
-- Prerequisites:
--
--
-- In Parameter:
--   Person_id
--   establishment_id
--   Start_date
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Developer Implementation Notes:
--
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function Get_end_date
            (p_person_id         IN Number,
             p_establishment_id  IN Number,
             p_start_date        IN Date,
             p_include_suspended IN VARCHAR
            )                  RETURN Date;
pragma restrict_references(Get_end_date,WNDS,WNPS);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< Get_reason >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the starting reason of a person
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   assignment_id
--   start date
--   seeded formula_id to be called
--   switch to identify which value for Starting "S" or Leaving "L" we want
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function Get_reason
            (p_assignment_id           IN Number,
             p_starting_date           IN varchar2,
             p_formula_id              IN Number,
             p_switch_starting_leaving IN varchar2
            ) RETURN Varchar2;
/* pragma restrict_references(Get_starting_reason,WNDS,WNPS); */
--
-- ----------------------------------------------------------------------------
end hr_fr_mmo;

 

/
