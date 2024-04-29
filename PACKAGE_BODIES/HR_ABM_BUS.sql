--------------------------------------------------------
--  DDL for Package Body HR_ABM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ABM_BUS" as
/* $Header: hrabmrhi.pkb 115.4 99/10/12 07:03:51 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_abm_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_batch_run_number >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This process validates the batch_run_number on insert.
--   Checks are:
--   1: ensure the batch_run_number exists (I)
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   p_batch_run_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_batch_run_number is null
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_batch_run_number(p_batch_run_number in number) is
--
  l_proc varchar2(72) := g_package||'chk_batch_run_number';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'batch_run_number',
     p_argument_value => p_batch_run_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_batch_run_number;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_api_name >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This process validates the api_name on insert.
--   Checks are:
--   1: ensure the api_name exists (I)
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   p_api_name
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_api_name is null
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_api_name(p_api_name in varchar2) is
--
  l_proc varchar2(72) := g_package||'chk_api_name';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'api_name',
     p_argument_value => p_api_name);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_api_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_status >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This process validates the status on insert.
--   We don't need to check that the status is either 'F' or 'S' because the
--   process constraint_error will handle this.
--   Checks are:
--   1: ensure the status exists (I)
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   p_status
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_status is null
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_status(p_status in varchar2) is
--
  l_proc varchar2(72) := g_package||'chk_status';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'status',
     p_argument_value => p_status);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_abm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the date is not within the context of a business group
  -- the set_security_group_id has zero passed to it
  -- as the default security_group_id
  --
  hr_api.set_security_group_id(p_security_group_id => 0);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  --  Call all supporting business operations
  --
  chk_batch_run_number(p_batch_run_number => p_rec.batch_run_number);
  chk_api_name(p_api_name => p_rec.api_name);
  chk_status(p_status => p_rec.status);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
End insert_validate;
--
end hr_abm_bus;

/
