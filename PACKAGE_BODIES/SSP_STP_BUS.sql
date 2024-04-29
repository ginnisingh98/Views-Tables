--------------------------------------------------------
--  DDL for Package Body SSP_STP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_STP_BUS" as
/* $Header: spstprhi.pkb 115.3 99/10/13 01:54:40 porting ship  $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ssp_stp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_permanent_stoppage >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates that stoppages may not have a withhold_to date if
--   they are for withholding reasons said to be 'permanent'.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Error handled by constraint_error procedure.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_permanent_stoppage (p_rec in ssp_stp_shd.g_rec_type) is
--
  l_proc varchar2 (72) := g_package||'chk_system_does_not_override';
--
cursor csr_withholding_reason is
	--
	-- Get the details of the withholding reason for the stoppage
	--
	select	*
	from	ssp_withholding_reasons
	where	reason_id = p_rec.reason_id;
	--
l_withholding_reason	csr_withholding_reason%rowtype;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_rec.withhold_to is not null then
    --
    -- Check that a withhold_to date is allowed
    --
    open csr_withholding_reason;
    fetch csr_withholding_reason into l_withholding_reason;
    --
    if csr_withholding_reason%notfound then
      --
      close csr_withholding_reason;
      ssp_stp_shd.constraint_error
		(p_constraint_name => 'SSP_STOPPAGES_FK2');
      --
    end if;
    --
    close csr_withholding_reason;
    --
    if l_withholding_reason.withhold_temporarily = 'N' then
      --
      -- The withholding reason is a permanent one. No withhold_to date is
      -- allowed.
      --
      ssp_stp_shd.constraint_error
		(p_constraint_name => 'SSP_STP_WITHHOLD_TO_PERMANENT');
      --
    end if;
    --
  end if;
--
end chk_permanent_stoppage;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ssp_stp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_permanent_stoppage (p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ssp_stp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_permanent_stoppage (p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ssp_stp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ssp_stp_bus;

/
