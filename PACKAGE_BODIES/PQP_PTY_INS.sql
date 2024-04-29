--------------------------------------------------------
--  DDL for Package Body PQP_PTY_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PTY_INS" as
/* $Header: pqptyrhi.pkb 120.0.12000000.1 2007/01/16 04:29:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_pty_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_pension_type_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_pension_type_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pqp_pty_ins.g_pension_type_id_i := p_pension_type_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
  (p_rec                     in out nocopy pqp_pty_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   pqp_pension_types_f t
    where  t.pension_type_id       = p_rec.pension_type_id
    and    t.effective_start_date =
             pqp_pty_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pqp_pension_types_f.created_by%TYPE;
  l_creation_date       pqp_pension_types_f.creation_date%TYPE;
  l_last_update_date    pqp_pension_types_f.last_update_date%TYPE;
  l_last_updated_by     pqp_pension_types_f.last_updated_by%TYPE;
  l_last_update_login   pqp_pension_types_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'pqp_pension_types_f'
      ,p_base_key_column => 'pension_type_id'
      ,p_base_key_value  => p_rec.pension_type_id
      );
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  --
  --
  -- Insert the row into: pqp_pension_types_f
  --
  insert into pqp_pension_types_f
      (pension_type_id
      ,effective_start_date
      ,effective_end_date
      ,pension_type_name
      ,pension_category
      ,pension_provider_type
      ,salary_calculation_method
      ,threshold_conversion_rule
      ,contribution_conversion_rule
      ,er_annual_limit
      ,ee_annual_limit
      ,er_annual_salary_threshold
      ,ee_annual_salary_threshold
      ,object_version_number
      ,business_group_id
      ,legislation_code
      ,description
      ,minimum_age
      ,ee_contribution_percent
      ,maximum_age
      ,er_contribution_percent
      ,ee_annual_contribution
      ,er_annual_contribution
      ,annual_premium_amount
      ,ee_contribution_bal_type_id
      ,er_contribution_bal_type_id
      ,balance_init_element_type_id
      ,ee_contribution_fixed_rate -- added for UK
      ,er_contribution_fixed_rate -- added for UK
      ,pty_attribute_category
      ,pty_attribute1
      ,pty_attribute2
      ,pty_attribute3
      ,pty_attribute4
      ,pty_attribute5
      ,pty_attribute6
      ,pty_attribute7
      ,pty_attribute8
      ,pty_attribute9
      ,pty_attribute10
      ,pty_attribute11
      ,pty_attribute12
      ,pty_attribute13
      ,pty_attribute14
      ,pty_attribute15
      ,pty_attribute16
      ,pty_attribute17
      ,pty_attribute18
      ,pty_attribute19
      ,pty_attribute20
      ,pty_information_category
      ,pty_information1
      ,pty_information2
      ,pty_information3
      ,pty_information4
      ,pty_information5
      ,pty_information6
      ,pty_information7
      ,pty_information8
      ,pty_information9
      ,pty_information10
      ,pty_information11
      ,pty_information12
      ,pty_information13
      ,pty_information14
      ,pty_information15
      ,pty_information16
      ,pty_information17
      ,pty_information18
      ,pty_information19
      ,pty_information20
      ,special_pension_type_code      -- added for NL Phase 2B
      ,pension_sub_category           -- added for NL Phase 2B
      ,pension_basis_calc_method      -- added for NL Phase 2B
      ,pension_salary_balance         -- added for NL Phase 2B
      ,recurring_bonus_percent        -- added for NL Phase 2B
      ,non_recurring_bonus_percent    -- added for NL Phase 2B
      ,recurring_bonus_balance        -- added for NL Phase 2B
      ,non_recurring_bonus_balance    -- added for NL Phase 2B
      ,std_tax_reduction              -- added for NL Phase 2B
      ,spl_tax_reduction              -- added for NL Phase 2B
      ,sig_sal_spl_tax_reduction      -- added for NL Phase 2B
      ,sig_sal_non_tax_reduction      -- added for NL Phase 2B
      ,sig_sal_std_tax_reduction      -- added for NL Phase 2B
      ,sii_std_tax_reduction          -- added for NL Phase 2B
      ,sii_spl_tax_reduction          -- added for NL Phase 2B
      ,sii_non_tax_reduction          -- added for NL Phase 2B
      ,previous_year_bonus_included   -- added for NL Phase 2B
      ,recurring_bonus_period         -- added for NL Phase 2B
      ,non_recurring_bonus_period     -- added for NL Phase 2B
      ,ee_age_threshold               -- added for ABP TAR fixes
      ,er_age_threshold               -- added for ABP TAR fixes
      ,ee_age_contribution            -- added for ABP TAR fixes
      ,er_age_contribution            -- added for ABP TAR fixes
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.pension_type_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.pension_type_name
    ,p_rec.pension_category
    ,p_rec.pension_provider_type
    ,p_rec.salary_calculation_method
    ,p_rec.threshold_conversion_rule
    ,p_rec.contribution_conversion_rule
    ,p_rec.er_annual_limit
    ,p_rec.ee_annual_limit
    ,p_rec.er_annual_salary_threshold
    ,p_rec.ee_annual_salary_threshold
    ,p_rec.object_version_number
    ,p_rec.business_group_id
    ,p_rec.legislation_code
    ,p_rec.description
    ,p_rec.minimum_age
    ,p_rec.ee_contribution_percent
    ,p_rec.maximum_age
    ,p_rec.er_contribution_percent
    ,p_rec.ee_annual_contribution
    ,p_rec.er_annual_contribution
    ,p_rec.annual_premium_amount
    ,p_rec.ee_contribution_bal_type_id
    ,p_rec.er_contribution_bal_type_id
    ,p_rec.balance_init_element_type_id
    ,p_rec.ee_contribution_fixed_rate         -- added for UK
    ,p_rec.er_contribution_fixed_rate         -- added for UK
    ,p_rec.pty_attribute_category
    ,p_rec.pty_attribute1
    ,p_rec.pty_attribute2
    ,p_rec.pty_attribute3
    ,p_rec.pty_attribute4
    ,p_rec.pty_attribute5
    ,p_rec.pty_attribute6
    ,p_rec.pty_attribute7
    ,p_rec.pty_attribute8
    ,p_rec.pty_attribute9
    ,p_rec.pty_attribute10
    ,p_rec.pty_attribute11
    ,p_rec.pty_attribute12
    ,p_rec.pty_attribute13
    ,p_rec.pty_attribute14
    ,p_rec.pty_attribute15
    ,p_rec.pty_attribute16
    ,p_rec.pty_attribute17
    ,p_rec.pty_attribute18
    ,p_rec.pty_attribute19
    ,p_rec.pty_attribute20
    ,p_rec.pty_information_category
    ,p_rec.pty_information1
    ,p_rec.pty_information2
    ,p_rec.pty_information3
    ,p_rec.pty_information4
    ,p_rec.pty_information5
    ,p_rec.pty_information6
    ,p_rec.pty_information7
    ,p_rec.pty_information8
    ,p_rec.pty_information9
    ,p_rec.pty_information10
    ,p_rec.pty_information11
    ,p_rec.pty_information12
    ,p_rec.pty_information13
    ,p_rec.pty_information14
    ,p_rec.pty_information15
    ,p_rec.pty_information16
    ,p_rec.pty_information17
    ,p_rec.pty_information18
    ,p_rec.pty_information19
    ,p_rec.pty_information20
    ,p_rec.special_pension_type_code      -- added for NL Phase 2B
    ,p_rec.pension_sub_category           -- added for NL Phase 2B
    ,p_rec.pension_basis_calc_method      -- added for NL Phase 2B
    ,p_rec.pension_salary_balance         -- added for NL Phase 2B
    ,p_rec.recurring_bonus_percent        -- added for NL Phase 2B
    ,p_rec.non_recurring_bonus_percent    -- added for NL Phase 2B
    ,p_rec.recurring_bonus_balance        -- added for NL Phase 2B
    ,p_rec.non_recurring_bonus_balance    -- added for NL Phase 2B
    ,p_rec.std_tax_reduction              -- added for NL Phase 2B
    ,p_rec.spl_tax_reduction              -- added for NL Phase 2B
    ,p_rec.sig_sal_spl_tax_reduction      -- added for NL Phase 2B
    ,p_rec.sig_sal_non_tax_reduction      -- added for NL Phase 2B
    ,p_rec.sig_sal_std_tax_reduction      -- added for NL Phase 2B
    ,p_rec.sii_std_tax_reduction          -- added for NL Phase 2B
    ,p_rec.sii_spl_tax_reduction          -- added for NL Phase 2B
    ,p_rec.sii_non_tax_reduction          -- added for NL Phase 2B
    ,p_rec.previous_year_bonus_included   -- added for NL Phase 2B
    ,p_rec.recurring_bonus_period         -- added for NL Phase 2B
    ,p_rec.non_recurring_bonus_period     -- added for NL Phase 2B
    ,p_rec.ee_age_threshold               -- added for ABP TAR fixes
    ,p_rec.er_age_threshold               -- added for ABP TAR fixes
    ,p_rec.ee_age_contribution            -- added for ABP TAR fixes
    ,p_rec.er_age_contribution            -- added for ABP TAR fixes
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqp_pty_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqp_pty_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure inserts a row into the HR_APPLICATION_OWNERSHIPS table
--   when the row handler is called in the appropriate mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column  IN varchar2
                               ,p_pk_value   IN varchar2) IS
--
CURSOR csr_definition IS
  SELECT product_short_name
    FROM hr_owner_definitions
   WHERE session_id = hr_startup_data_api_support.g_session_id;
--
BEGIN
  --
  IF (hr_startup_data_api_support.return_startup_mode IN
                               ('STARTUP','GENERIC')) THEN
     --
     FOR c1 IN csr_definition LOOP
       --
       INSERT INTO hr_application_ownerships
         (key_name
         ,key_value
         ,product_name
         )
       VALUES
         (p_pk_column
         ,fnd_number.number_to_canonical(p_pk_value)
         ,c1.product_short_name
         );
     END LOOP;
  END IF;
END create_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column IN varchar2
                               ,p_pk_value  IN number) IS
--
BEGIN
  create_app_ownerships(p_pk_column, to_char(p_pk_value));
END create_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy pqp_pty_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_pty_ins.dt_insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec                   in out nocopy pqp_pty_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  Cursor C_Sel1 is select pqp_pension_types_s.nextval from sys.dual;
--
 Cursor C_Sel2 is
    Select null
      from pqp_pension_types_f
     where pension_type_id =
             pqp_pty_ins.g_pension_type_id_i;
--
  l_proc        varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (pqp_pty_ins.g_pension_type_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','pqp_pension_types_f');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.pension_type_id :=
      pqp_pty_ins.g_pension_type_id_i;
    pqp_pty_ins.g_pension_type_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.pension_type_id;
    Close C_Sel1;
  End If;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_insert >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_rec                   in pqp_pty_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
      --
    -- insert ownerships if applicable
    create_app_ownerships
      ('PENSION_TYPE_ID', p_rec.pension_type_id
      );
    --
    --
    pqp_pty_rki.after_insert
      (p_effective_date
      => p_effective_date
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_pension_type_id
      => p_rec.pension_type_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_pension_type_name
      => p_rec.pension_type_name
      ,p_pension_category
      => p_rec.pension_category
      ,p_pension_provider_type
      => p_rec.pension_provider_type
      ,p_salary_calculation_method
      => p_rec.salary_calculation_method
      ,p_threshold_conversion_rule
      => p_rec.threshold_conversion_rule
      ,p_contribution_conversion_rule
      => p_rec.contribution_conversion_rule
      ,p_er_annual_limit
      => p_rec.er_annual_limit
      ,p_ee_annual_limit
      => p_rec.ee_annual_limit
      ,p_er_annual_salary_threshold
      => p_rec.er_annual_salary_threshold
      ,p_ee_annual_salary_threshold
      => p_rec.ee_annual_salary_threshold
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_description
      => p_rec.description
      ,p_minimum_age
      => p_rec.minimum_age
      ,p_ee_contribution_percent
      => p_rec.ee_contribution_percent
      ,p_maximum_age
      => p_rec.maximum_age
      ,p_er_contribution_percent
      => p_rec.er_contribution_percent
      ,p_ee_annual_contribution
      => p_rec.ee_annual_contribution
      ,p_er_annual_contribution
      => p_rec.er_annual_contribution
      ,p_annual_premium_amount
      => p_rec.annual_premium_amount
      ,p_ee_contribution_bal_type_id
      => p_rec.ee_contribution_bal_type_id
      ,p_er_contribution_bal_type_id
      => p_rec.er_contribution_bal_type_id
      ,p_balance_init_element_type_id
      => p_rec.balance_init_element_type_id
      ,p_ee_contribution_fixed_rate
      => p_rec.ee_contribution_fixed_rate
      ,p_er_contribution_fixed_rate
      => p_rec.er_contribution_fixed_rate
      ,p_pty_attribute_category
      => p_rec.pty_attribute_category
      ,p_pty_attribute1
      => p_rec.pty_attribute1
      ,p_pty_attribute2
      => p_rec.pty_attribute2
      ,p_pty_attribute3
      => p_rec.pty_attribute3
      ,p_pty_attribute4
      => p_rec.pty_attribute4
      ,p_pty_attribute5
      => p_rec.pty_attribute5
      ,p_pty_attribute6
      => p_rec.pty_attribute6
      ,p_pty_attribute7
      => p_rec.pty_attribute7
      ,p_pty_attribute8
      => p_rec.pty_attribute8
      ,p_pty_attribute9
      => p_rec.pty_attribute9
      ,p_pty_attribute10
      => p_rec.pty_attribute10
      ,p_pty_attribute11
      => p_rec.pty_attribute11
      ,p_pty_attribute12
      => p_rec.pty_attribute12
      ,p_pty_attribute13
      => p_rec.pty_attribute13
      ,p_pty_attribute14
      => p_rec.pty_attribute14
      ,p_pty_attribute15
      => p_rec.pty_attribute15
      ,p_pty_attribute16
      => p_rec.pty_attribute16
      ,p_pty_attribute17
      => p_rec.pty_attribute17
      ,p_pty_attribute18
      => p_rec.pty_attribute18
      ,p_pty_attribute19
      => p_rec.pty_attribute19
      ,p_pty_attribute20
      => p_rec.pty_attribute20
      ,p_pty_information_category
      => p_rec.pty_information_category
      ,p_pty_information1
      => p_rec.pty_information1
      ,p_pty_information2
      => p_rec.pty_information2
      ,p_pty_information3
      => p_rec.pty_information3
      ,p_pty_information4
      => p_rec.pty_information4
      ,p_pty_information5
      => p_rec.pty_information5
      ,p_pty_information6
      => p_rec.pty_information6
      ,p_pty_information7
      => p_rec.pty_information7
      ,p_pty_information8
      => p_rec.pty_information8
      ,p_pty_information9
      => p_rec.pty_information9
      ,p_pty_information10
      => p_rec.pty_information10
      ,p_pty_information11
      => p_rec.pty_information11
      ,p_pty_information12
      => p_rec.pty_information12
      ,p_pty_information13
      => p_rec.pty_information13
      ,p_pty_information14
      => p_rec.pty_information14
      ,p_pty_information15
      => p_rec.pty_information15
      ,p_pty_information16
      => p_rec.pty_information16
      ,p_pty_information17
      => p_rec.pty_information17
      ,p_pty_information18
      => p_rec.pty_information18
      ,p_pty_information19
      => p_rec.pty_information19
      ,p_pty_information20
      => p_rec.pty_information20
      ,p_special_pension_type_code
      => p_rec.special_pension_type_code
      ,p_pension_sub_category
      => p_rec.pension_sub_category
      ,p_pension_basis_calc_method
      => p_rec.pension_basis_calc_method
      ,p_pension_salary_balance
      => p_rec.pension_salary_balance
      ,p_recurring_bonus_percent
      => p_rec.recurring_bonus_percent
      ,p_non_recurring_bonus_percent
      => p_rec.non_recurring_bonus_percent
      ,p_recurring_bonus_balance
      => p_rec.recurring_bonus_balance
      ,p_non_recurring_bonus_balance
      => p_rec.non_recurring_bonus_balance
      ,p_std_tax_reduction
      => p_rec.std_tax_reduction
      ,p_spl_tax_reduction
      => p_rec.spl_tax_reduction
      ,p_sig_sal_spl_tax_reduction
      => p_rec.sig_sal_spl_tax_reduction
      ,p_sig_sal_non_tax_reduction
      => p_rec.sig_sal_non_tax_reduction
      ,p_sig_sal_std_tax_reduction
      => p_rec.sig_sal_std_tax_reduction
      ,p_sii_std_tax_reduction
      => p_rec.sii_std_tax_reduction
      ,p_sii_spl_tax_reduction
      => p_rec.sii_spl_tax_reduction
      ,p_sii_non_tax_reduction
      => p_rec.sii_non_tax_reduction
      ,p_previous_year_bonus_included
      => p_rec.previous_year_bonus_included
      ,p_recurring_bonus_period
      => p_rec.recurring_bonus_period
      ,p_non_recurring_bonus_period
      => p_rec.non_recurring_bonus_period
      ,p_ee_age_threshold
      => p_rec.ee_age_threshold
      ,p_er_age_threshold
      => p_rec.er_age_threshold
      ,p_ee_age_contribution
      => p_rec.ee_age_contribution
      ,p_er_age_contribution
      => p_rec.er_age_contribution
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_PENSION_TYPES_F'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
  (p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_rec                   in pqp_pty_shd.g_rec_type
  ,p_validation_start_date out nocopy date
  ,p_validation_end_date   out nocopy date
  ) is
--
  l_proc                  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date   date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
    (p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    ,p_base_table_name         => 'pqp_pension_types_f'
    ,p_base_key_column         => 'pension_type_id'
    ,p_base_key_value          => p_rec.pension_type_id
    ,p_enforce_foreign_locking => true
    ,p_validation_start_date   => l_validation_start_date
    ,p_validation_end_date     => l_validation_end_date
    );
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date in     date
  ,p_rec            in out nocopy pqp_pty_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'ins';
  l_datetrack_mode              varchar2(30) := hr_api.g_insert;
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  pqp_pty_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  pqp_pty_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pqp_pty_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  pqp_pty_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  pqp_pty_ins.post_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_pension_type_name              in     varchar2
  ,p_pension_category               in     varchar2
  ,p_pension_provider_type          in     varchar2
  ,p_salary_calculation_method      in     varchar2
  ,p_threshold_conversion_rule      in     varchar2
  ,p_contribution_conversion_rule   in     varchar2
  ,p_er_annual_limit                in     number
  ,p_ee_annual_limit                in     number
  ,p_er_annual_salary_threshold     in     number
  ,p_ee_annual_salary_threshold     in     number
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_minimum_age                    in     number   default null
  ,p_ee_contribution_percent        in     number   default null
  ,p_maximum_age                    in     number   default null
  ,p_er_contribution_percent        in     number   default null
  ,p_ee_annual_contribution         in     number   default null
  ,p_er_annual_contribution         in     number   default null
  ,p_annual_premium_amount          in     number   default null
  ,p_ee_contribution_bal_type_id    in     number   default null
  ,p_er_contribution_bal_type_id    in     number   default null
  ,p_balance_init_element_type_id   in     number   default null
  ,p_ee_contribution_fixed_rate     in     number   default null   --added for UK
  ,p_er_contribution_fixed_rate     in     number   default null   --added for UK
  ,p_pty_attribute_category         in     varchar2 default null
  ,p_pty_attribute1                 in     varchar2 default null
  ,p_pty_attribute2                 in     varchar2 default null
  ,p_pty_attribute3                 in     varchar2 default null
  ,p_pty_attribute4                 in     varchar2 default null
  ,p_pty_attribute5                 in     varchar2 default null
  ,p_pty_attribute6                 in     varchar2 default null
  ,p_pty_attribute7                 in     varchar2 default null
  ,p_pty_attribute8                 in     varchar2 default null
  ,p_pty_attribute9                 in     varchar2 default null
  ,p_pty_attribute10                in     varchar2 default null
  ,p_pty_attribute11                in     varchar2 default null
  ,p_pty_attribute12                in     varchar2 default null
  ,p_pty_attribute13                in     varchar2 default null
  ,p_pty_attribute14                in     varchar2 default null
  ,p_pty_attribute15                in     varchar2 default null
  ,p_pty_attribute16                in     varchar2 default null
  ,p_pty_attribute17                in     varchar2 default null
  ,p_pty_attribute18                in     varchar2 default null
  ,p_pty_attribute19                in     varchar2 default null
  ,p_pty_attribute20                in     varchar2 default null
  ,p_pty_information_category       in     varchar2 default null
  ,p_pty_information1               in     varchar2 default null
  ,p_pty_information2               in     varchar2 default null
  ,p_pty_information3               in     varchar2 default null
  ,p_pty_information4               in     varchar2 default null
  ,p_pty_information5               in     varchar2 default null
  ,p_pty_information6               in     varchar2 default null
  ,p_pty_information7               in     varchar2 default null
  ,p_pty_information8               in     varchar2 default null
  ,p_pty_information9               in     varchar2 default null
  ,p_pty_information10              in     varchar2 default null
  ,p_pty_information11              in     varchar2 default null
  ,p_pty_information12              in     varchar2 default null
  ,p_pty_information13              in     varchar2 default null
  ,p_pty_information14              in     varchar2 default null
  ,p_pty_information15              in     varchar2 default null
  ,p_pty_information16              in     varchar2 default null
  ,p_pty_information17              in     varchar2 default null
  ,p_pty_information18              in     varchar2 default null
  ,p_pty_information19              in     varchar2 default null
  ,p_pty_information20              in     varchar2 default null
  ,p_special_pension_type_code      in     varchar2  default null    -- added for NL Phase 2B
  ,p_pension_sub_category           in     varchar2  default null    -- added for NL Phase 2B
  ,p_pension_basis_calc_method      in     varchar2  default null    -- added for NL Phase 2B
  ,p_pension_salary_balance         in     number    default null    -- added for NL Phase 2B
  ,p_recurring_bonus_percent        in     number    default null    -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent    in     number    default null    -- added for NL Phase 2B
  ,p_recurring_bonus_balance        in     number    default null    -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance    in     number    default null    -- added for NL Phase 2B
  ,p_std_tax_reduction              in     varchar2  default null    -- added for NL Phase 2B
  ,p_spl_tax_reduction              in     varchar2  default null    -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction      in     varchar2  default null    -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction      in     varchar2  default null    -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction      in     varchar2  default null    -- added for NL Phase 2B
  ,p_sii_std_tax_reduction          in     varchar2  default null    -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction          in     varchar2  default null    -- added for NL Phase 2B
  ,p_sii_non_tax_reduction          in     varchar2  default null    -- added for NL Phase 2B
  ,p_previous_year_bonus_included   in     varchar2  default null    -- added for NL Phase 2B
  ,p_recurring_bonus_period         in     varchar2  default null    -- added for NL Phase 2B
  ,p_non_recurring_bonus_period     in     varchar2  default null    -- added for NL Phase 2B
  ,p_ee_age_threshold               in     varchar2  default null    -- added for ABP TAR fixes
  ,p_er_age_threshold               in     varchar2  default null    -- added for ABP TAR fixes
  ,p_ee_age_contribution            in     varchar2  default null    -- added for ABP TAR fixes
  ,p_er_age_contribution            in     varchar2  default null    -- added for ABP TAR fixes
  ,p_pension_type_id                   out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ) is
--
  l_rec         pqp_pty_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqp_pty_shd.convert_args
    (null
    ,null
    ,null
    ,p_pension_type_name
    ,p_pension_category
    ,p_pension_provider_type
    ,p_salary_calculation_method
    ,p_threshold_conversion_rule
    ,p_contribution_conversion_rule
    ,p_er_annual_limit
    ,p_ee_annual_limit
    ,p_er_annual_salary_threshold
    ,p_ee_annual_salary_threshold
    ,null
    ,p_business_group_id
    ,p_legislation_code
    ,p_description
    ,p_minimum_age
    ,p_ee_contribution_percent
    ,p_maximum_age
    ,p_er_contribution_percent
    ,p_ee_annual_contribution
    ,p_er_annual_contribution
    ,p_annual_premium_amount
    ,p_ee_contribution_bal_type_id
    ,p_er_contribution_bal_type_id
    ,p_balance_init_element_type_id
    ,p_ee_contribution_fixed_rate     --added for UK
    ,p_er_contribution_fixed_rate     --added for UK
    ,p_pty_attribute_category
    ,p_pty_attribute1
    ,p_pty_attribute2
    ,p_pty_attribute3
    ,p_pty_attribute4
    ,p_pty_attribute5
    ,p_pty_attribute6
    ,p_pty_attribute7
    ,p_pty_attribute8
    ,p_pty_attribute9
    ,p_pty_attribute10
    ,p_pty_attribute11
    ,p_pty_attribute12
    ,p_pty_attribute13
    ,p_pty_attribute14
    ,p_pty_attribute15
    ,p_pty_attribute16
    ,p_pty_attribute17
    ,p_pty_attribute18
    ,p_pty_attribute19
    ,p_pty_attribute20
    ,p_pty_information_category
    ,p_pty_information1
    ,p_pty_information2
    ,p_pty_information3
    ,p_pty_information4
    ,p_pty_information5
    ,p_pty_information6
    ,p_pty_information7
    ,p_pty_information8
    ,p_pty_information9
    ,p_pty_information10
    ,p_pty_information11
    ,p_pty_information12
    ,p_pty_information13
    ,p_pty_information14
    ,p_pty_information15
    ,p_pty_information16
    ,p_pty_information17
    ,p_pty_information18
    ,p_pty_information19
    ,p_pty_information20
    ,p_special_pension_type_code      -- added for NL Phase 2B
    ,p_pension_sub_category           -- added for NL Phase 2B
    ,p_pension_basis_calc_method      -- added for NL Phase 2B
    ,p_pension_salary_balance         -- added for NL Phase 2B
    ,p_recurring_bonus_percent        -- added for NL Phase 2B
    ,p_non_recurring_bonus_percent    -- added for NL Phase 2B
    ,p_recurring_bonus_balance        -- added for NL Phase 2B
    ,p_non_recurring_bonus_balance    -- added for NL Phase 2B
    ,p_std_tax_reduction              -- added for NL Phase 2B
    ,p_spl_tax_reduction              -- added for NL Phase 2B
    ,p_sig_sal_spl_tax_reduction      -- added for NL Phase 2B
    ,p_sig_sal_non_tax_reduction      -- added for NL Phase 2B
    ,p_sig_sal_std_tax_reduction      -- added for NL Phase 2B
    ,p_sii_std_tax_reduction          -- added for NL Phase 2B
    ,p_sii_spl_tax_reduction          -- added for NL Phase 2B
    ,p_sii_non_tax_reduction          -- added for NL Phase 2B
    ,p_previous_year_bonus_included   -- added for NL Phase 2B
    ,p_recurring_bonus_period         -- added for NL Phase 2B
    ,p_non_recurring_bonus_period     -- added for NL Phase 2B
    ,p_ee_age_threshold               -- added for ABP TAR fixes
    ,p_er_age_threshold               -- added for ABP TAR fixes
    ,p_ee_age_contribution            -- added for ABP TAR fixes
    ,p_er_age_contribution            -- added for ABP TAR fixes
    );
  --
  -- Having converted the arguments into the pqp_pty_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_pty_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_pension_type_id                  := l_rec.pension_type_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--

end pqp_pty_ins;


/
