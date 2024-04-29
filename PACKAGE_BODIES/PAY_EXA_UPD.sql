--------------------------------------------------------
--  DDL for Package Body PAY_EXA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EXA_UPD" AS
/* $Header: pyexarhi.pkb 115.13 2003/09/26 06:48:50 tvankayl ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_exa_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure update_dml(
   p_rec in out nocopy pay_exa_shd.g_rec_type
   ) is
  --
  l_proc  varchar2(72) := g_package||'update_dml';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  pay_exa_shd.g_api_dml := true;  -- set the api dml status
  --
  -- update_validate(), chk_territory_code(), pay_exa_shd.api_updating()
  -- has been called,
  -- this selects a row into g_old_rec and returns true if the PK value
  -- passed in matches a row on the db,
  -- nb. no locking is done
  --
  pay_exa_shd.lck
    (p_rec.external_account_id,
     p_rec.object_version_number);
  --
  -- only do U if values have changed
  --
  if ( nvl(p_rec.territory_code, hr_api.g_varchar2) <>
       nvl(pay_exa_shd.g_old_rec.territory_code, hr_api.g_varchar2) )
       or
     ( nvl(p_rec.prenote_date, hr_api.g_date) <>
       nvl(pay_exa_shd.g_old_rec.prenote_date, hr_api.g_date) ) then
    hr_utility.trace('| doing update on combination table');
    --
    -- fresh combination record
    --
    if ( pay_exa_shd.g_old_rec.territory_code is null ) then
      hr_utility.trace('| updating territory_code');
      --
      UPDATE PAY_EXTERNAL_ACCOUNTS
      SET    territory_code = p_rec.territory_code
      WHERE  external_account_id = p_rec.external_account_id
      ;
    end if;
    ------------------------------------------------------------------------
    -- bug2307154 changes for prenote_date
    ------------------------------------------------------------------------
    --
    -- Check for defaulted prenote_date.
    --
    if p_rec.prenote_date = hr_api.g_date then
      hr_utility.trace('| not updating prenote_date (default passed in)');
      --
      -- No change to be made: existing combination's date is not updated,
      -- and fresh combination must have date clear (for prenotification to
      -- take place).
      --
      null;
    elsif ( nvl(p_rec.prenote_date, hr_api.g_date) <>
         nvl(pay_exa_shd.g_old_rec.prenote_date, hr_api.g_date) ) then
      hr_utility.trace('| updating prenote_date');
      --
      UPDATE PAY_EXTERNAL_ACCOUNTS
      SET    prenote_date = p_rec.prenote_date
      WHERE  external_account_id = p_rec.external_account_id
      ;
    end if;
    --
    -- U has occurred, increment object version number
    --
    UPDATE PAY_EXTERNAL_ACCOUNTS
    SET    object_version_number = nvl(object_version_number, 0) + 1
    WHERE  external_account_id = p_rec.external_account_id
    ;
  end if;
  --
  pay_exa_shd.g_api_dml := false;   -- unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_exa_shd.g_api_dml := false;   -- Unset the api dml status
    pay_exa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_exa_shd.g_api_dml := false;   -- Unset the api dml status
    pay_exa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_exa_shd.g_api_dml := false;   -- Unset the api dml status
    pay_exa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_exa_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
end update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure pre_update(
   p_rec in pay_exa_shd.g_rec_type
   ) is
  --
  l_proc  varchar2(72) := g_package||'pre_update';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure post_update(
   p_rec in pay_exa_shd.g_rec_type
   ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
procedure convert_defs(
   p_rec in out nocopy pay_exa_shd.g_rec_type
   ) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- we must now examine each argument value in the p_rec plsql record
  -- structure to see if a system default is being used,
  -- if a system default is being used then we must set to the 'current'
  -- argument value
  --
  If (p_rec.territory_code = hr_api.g_varchar2) then
    p_rec.territory_code :=
    pay_exa_shd.g_old_rec.territory_code;
  End If;
  --------------------------------------------------------------------------
  -- bug2307154: do not convert prenote_date if it has been defaulted.
  --
  -- If p_prenote_date is defaulted (hr_api.g_varchar2) then no change if
  -- the update results in an existing flex combination. If the update
  -- results in a fresh combination the prenote date remains as NULL
  -- (bug1776298) as prenotification must be done on fresh bank details.
  --
  -- Note: this is a deviation from the API strategy as convert_defs will
  -- not convert a defaulted prenote date value, and the update logic
  -- will look for hr_api.g_date when it handles the prenote_date.
  --------------------------------------------------------------------------
  If (p_rec.id_flex_num = hr_api.g_number) then
    p_rec.id_flex_num :=
    pay_exa_shd.g_old_rec.id_flex_num;
  End If;
  If (p_rec.summary_flag = hr_api.g_varchar2) then
    p_rec.summary_flag :=
    pay_exa_shd.g_old_rec.summary_flag;
  End If;
  If (p_rec.enabled_flag = hr_api.g_varchar2) then
    p_rec.enabled_flag :=
    pay_exa_shd.g_old_rec.enabled_flag;
  End If;
  If (p_rec.start_date_active = hr_api.g_date) then
    p_rec.start_date_active :=
    pay_exa_shd.g_old_rec.start_date_active;
  End If;
  If (p_rec.end_date_active = hr_api.g_date) then
    p_rec.end_date_active :=
    pay_exa_shd.g_old_rec.end_date_active;
  End If;
  If (p_rec.segment1 = hr_api.g_varchar2) then
    p_rec.segment1 :=
    pay_exa_shd.g_old_rec.segment1;
  End If;
  If (p_rec.segment2 = hr_api.g_varchar2) then
    p_rec.segment2 :=
    pay_exa_shd.g_old_rec.segment2;
  End If;
  If (p_rec.segment3 = hr_api.g_varchar2) then
    p_rec.segment3 :=
    pay_exa_shd.g_old_rec.segment3;
  End If;
  If (p_rec.segment4 = hr_api.g_varchar2) then
    p_rec.segment4 :=
    pay_exa_shd.g_old_rec.segment4;
  End If;
  If (p_rec.segment5 = hr_api.g_varchar2) then
    p_rec.segment5 :=
    pay_exa_shd.g_old_rec.segment5;
  End If;
  If (p_rec.segment6 = hr_api.g_varchar2) then
    p_rec.segment6 :=
    pay_exa_shd.g_old_rec.segment6;
  End If;
  If (p_rec.segment7 = hr_api.g_varchar2) then
    p_rec.segment7 :=
    pay_exa_shd.g_old_rec.segment7;
  End If;
  If (p_rec.segment8 = hr_api.g_varchar2) then
    p_rec.segment8 :=
    pay_exa_shd.g_old_rec.segment8;
  End If;
  If (p_rec.segment9 = hr_api.g_varchar2) then
    p_rec.segment9 :=
    pay_exa_shd.g_old_rec.segment9;
  End If;
  If (p_rec.segment10 = hr_api.g_varchar2) then
    p_rec.segment10 :=
    pay_exa_shd.g_old_rec.segment10;
  End If;
  If (p_rec.segment11 = hr_api.g_varchar2) then
    p_rec.segment11 :=
    pay_exa_shd.g_old_rec.segment11;
  End If;
  If (p_rec.segment12 = hr_api.g_varchar2) then
    p_rec.segment12 :=
    pay_exa_shd.g_old_rec.segment12;
  End If;
  If (p_rec.segment13 = hr_api.g_varchar2) then
    p_rec.segment13 :=
    pay_exa_shd.g_old_rec.segment13;
  End If;
  If (p_rec.segment14 = hr_api.g_varchar2) then
    p_rec.segment14 :=
    pay_exa_shd.g_old_rec.segment14;
  End If;
  If (p_rec.segment15 = hr_api.g_varchar2) then
    p_rec.segment15 :=
    pay_exa_shd.g_old_rec.segment15;
  End If;
  If (p_rec.segment16 = hr_api.g_varchar2) then
    p_rec.segment16 :=
    pay_exa_shd.g_old_rec.segment16;
  End If;
  If (p_rec.segment17 = hr_api.g_varchar2) then
    p_rec.segment17 :=
    pay_exa_shd.g_old_rec.segment17;
  End If;
  If (p_rec.segment18 = hr_api.g_varchar2) then
    p_rec.segment18 :=
    pay_exa_shd.g_old_rec.segment18;
  End If;
  If (p_rec.segment19 = hr_api.g_varchar2) then
    p_rec.segment19 :=
    pay_exa_shd.g_old_rec.segment19;
  End If;
  If (p_rec.segment20 = hr_api.g_varchar2) then
    p_rec.segment20 :=
    pay_exa_shd.g_old_rec.segment20;
  End If;
  If (p_rec.segment21 = hr_api.g_varchar2) then
    p_rec.segment21 :=
    pay_exa_shd.g_old_rec.segment21;
  End If;
  If (p_rec.segment22 = hr_api.g_varchar2) then
    p_rec.segment22 :=
    pay_exa_shd.g_old_rec.segment22;
  End If;
  If (p_rec.segment23 = hr_api.g_varchar2) then
    p_rec.segment23 :=
    pay_exa_shd.g_old_rec.segment23;
  End If;
  If (p_rec.segment24 = hr_api.g_varchar2) then
    p_rec.segment24 :=
    pay_exa_shd.g_old_rec.segment24;
  End If;
  If (p_rec.segment25 = hr_api.g_varchar2) then
    p_rec.segment25 :=
    pay_exa_shd.g_old_rec.segment25;
  End If;
  If (p_rec.segment26 = hr_api.g_varchar2) then
    p_rec.segment26 :=
    pay_exa_shd.g_old_rec.segment26;
  End If;
  If (p_rec.segment27 = hr_api.g_varchar2) then
    p_rec.segment27 :=
    pay_exa_shd.g_old_rec.segment27;
  End If;
  If (p_rec.segment28 = hr_api.g_varchar2) then
    p_rec.segment28 :=
    pay_exa_shd.g_old_rec.segment28;
  End If;
  If (p_rec.segment29 = hr_api.g_varchar2) then
    p_rec.segment29 :=
    pay_exa_shd.g_old_rec.segment29;
  End If;
  If (p_rec.segment30 = hr_api.g_varchar2) then
    p_rec.segment30 :=
    pay_exa_shd.g_old_rec.segment30;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
procedure upd(
   p_rec        in out nocopy pay_exa_shd.g_rec_type
  ,p_validate   in     boolean default false
  ) is
  --
  l_proc  varchar2(72) := g_package||'upd';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- determine if the business process is to be validated
  --
  If p_validate then
    --
    -- issue the savepoint
    --
    SAVEPOINT upd_pay_exa;
  End If;
  --
  -- we must lock the row which we need to update
  --
  pay_exa_shd.lck
    (p_rec.external_account_id,
     p_rec.object_version_number);
  --
  -- stub - not sure if this is necessary as other parameters are
  --        not used by U logic
  --
  pay_exa_upd.convert_defs(p_rec);
  pay_exa_bus.update_validate(p_rec);
  --
  -- call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- update the row.
  --
  update_dml(p_rec);
  --
  -- call the supporting post-update operation
  --
  post_update(p_rec);
  --
  -- if we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_pay_exa;
end upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
procedure upd(
   p_external_account_id          in number
  ,p_territory_code               in varchar2
  ,p_prenote_date                 in date             default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_validate                     in boolean          default false
  ) is
  --
  l_rec   pay_exa_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
  --
  cursor csr_ovn(p_external_account_id number) is
    SELECT pea.object_version_number
    FROM   PAY_EXTERNAL_ACCOUNTS pea
    WHERE  pea.external_account_id = p_external_account_id
    ;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- call conversion function to turn arguments into the l_rec structure,
  -- nb. only parameters used by U logic are set
  --
  l_rec :=
  pay_exa_shd.convert_args(
    p_external_account_id         => p_external_account_id,
    p_territory_code              => p_territory_code,
    p_prenote_date                => p_prenote_date,
    p_id_flex_num                 => null,
    p_summary_flag                => null,
    p_enabled_flag                => null,
    p_start_date_active           => null,
    p_end_date_active             => null,
    p_segment1                    => null,
    p_segment2                    => null,
    p_segment3                    => null,
    p_segment4                    => null,
    p_segment5                    => null,
    p_segment6                    => null,
    p_segment7                    => null,
    p_segment8                    => null,
    p_segment9                    => null,
    p_segment10                   => null,
    p_segment11                   => null,
    p_segment12                   => null,
    p_segment13                   => null,
    p_segment14                   => null,
    p_segment15                   => null,
    p_segment16                   => null,
    p_segment17                   => null,
    p_segment18                   => null,
    p_segment19                   => null,
    p_segment20                   => null,
    p_segment21                   => null,
    p_segment22                   => null,
    p_segment23                   => null,
    p_segment24                   => null,
    p_segment25                   => null,
    p_segment26                   => null,
    p_segment27                   => null,
    p_segment28                   => null,
    p_segment29                   => null,
    p_segment30                   => null,
    p_object_version_number       => p_object_version_number
    );
  --
  -- having converted the arguments into the plsql record structure we
  -- call the corresponding record business process
  --
  upd(l_rec, p_validate);
  --p_object_version_number := l_rec.object_version_number;
  --
  -- object version number may have changed,
  -- select the latest value and pass as out paramter
  --
  open  csr_ovn(l_rec.external_account_id);
  fetch csr_ovn into p_object_version_number;
  close csr_ovn;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end upd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< upd_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
procedure upd_or_sel(
   p_segment1              in     varchar2 default hr_api.g_varchar2
  ,p_segment2              in     varchar2 default hr_api.g_varchar2
  ,p_segment3              in     varchar2 default hr_api.g_varchar2
  ,p_segment4              in     varchar2 default hr_api.g_varchar2
  ,p_segment5              in     varchar2 default hr_api.g_varchar2
  ,p_segment6              in     varchar2 default hr_api.g_varchar2
  ,p_segment7              in     varchar2 default hr_api.g_varchar2
  ,p_segment8              in     varchar2 default hr_api.g_varchar2
  ,p_segment9              in     varchar2 default hr_api.g_varchar2
  ,p_segment10             in     varchar2 default hr_api.g_varchar2
  ,p_segment11             in     varchar2 default hr_api.g_varchar2
  ,p_segment12             in     varchar2 default hr_api.g_varchar2
  ,p_segment13             in     varchar2 default hr_api.g_varchar2
  ,p_segment14             in     varchar2 default hr_api.g_varchar2
  ,p_segment15             in     varchar2 default hr_api.g_varchar2
  ,p_segment16             in     varchar2 default hr_api.g_varchar2
  ,p_segment17             in     varchar2 default hr_api.g_varchar2
  ,p_segment18             in     varchar2 default hr_api.g_varchar2
  ,p_segment19             in     varchar2 default hr_api.g_varchar2
  ,p_segment20             in     varchar2 default hr_api.g_varchar2
  ,p_segment21             in     varchar2 default hr_api.g_varchar2
  ,p_segment22             in     varchar2 default hr_api.g_varchar2
  ,p_segment23             in     varchar2 default hr_api.g_varchar2
  ,p_segment24             in     varchar2 default hr_api.g_varchar2
  ,p_segment25             in     varchar2 default hr_api.g_varchar2
  ,p_segment26             in     varchar2 default hr_api.g_varchar2
  ,p_segment27             in     varchar2 default hr_api.g_varchar2
  ,p_segment28             in     varchar2 default hr_api.g_varchar2
  ,p_segment29             in     varchar2 default hr_api.g_varchar2
  ,p_segment30             in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments       in     varchar2 default null
  ,p_business_group_id     in     number
-- make territory_code code a mandatory parameter on U interface
  ,p_territory_code        in     varchar2
  ,p_prenote_date          in     date     default hr_api.g_date
  ,p_external_account_id   in out nocopy number
  ,p_object_version_number in out nocopy number
  ,p_validate              in     boolean  default false
  ) is
  --
  l_proc          varchar2(72) := g_package||'upd_or_sel';
  l_rec           pay_exa_shd.g_rec_type;
  l_concat_segments_out varchar2(4600);
  l_external_account_id_init   pay_external_accounts.external_account_id%type;
  l_prenote_date               pay_external_accounts.prenote_date%type;
  l_object_version_number_init pay_external_accounts.object_version_number%type;
  --
begin
  hr_utility.set_location('***** Entering:' || l_proc || ' *****', 5);
  --
  -- store initial value of IN OUT paramters,
  -- set back to IN state if validate only is true
  --
  l_external_account_id_init := p_external_account_id;
  l_object_version_number_init := p_object_version_number;

  --
  -- stub - do we need to validate prenote_date,
  --        could be null ?
  --

  --
  -- may still need to set territory code incase fresh combination
  -- record is being I'ed
  --
  hr_api.mandatory_arg_error(
    p_api_name          => l_proc,
    p_argument          => 'territory_code',
    p_argument_value    => p_territory_code
    );

  --
  -- convert args into record format
  --
  l_rec :=
    pay_exa_shd.convert_args(
      p_external_account_id,
      p_territory_code,
      p_prenote_date,
      --
      -- use system defaults so that pay_exa_upd.convert_defs()
      -- will convert the components to their current db values
      --
      hr_api.g_number,    -- id_flex_num
      hr_api.g_varchar2,  -- summary_flag
      hr_api.g_varchar2,  -- enabled_flag
      hr_api.g_date,      -- start_date_active
      hr_api.g_date,      -- end_date_active
      --
      p_segment1,
      p_segment2,
      p_segment3,
      p_segment4,
      p_segment5,
      p_segment6,
      p_segment7,
      p_segment8,
      p_segment9,
      p_segment10,
      p_segment11,
      p_segment12,
      p_segment13,
      p_segment14,
      p_segment15,
      p_segment16,
      p_segment17,
      p_segment18,
      p_segment19,
      p_segment20,
      p_segment21,
      p_segment22,
      p_segment23,
      p_segment24,
      p_segment25,
      p_segment26,
      p_segment27,
      p_segment28,
      p_segment29,
      p_segment30,
      p_object_version_number);

  --
  -- nb. at this point id_flex_num, summary_flag, enabled_flag,
  -- start_date_active and end_date_active have system defaulted
  -- values in l_rec
  --

  --
  -- ccid passed in must always point to a combination row,
  -- ie. a row in PAY_EXTERNAL_ACCOUNTS,
  --
  -- if segments1 ... 30 are changed, then we may be I'ing a
  -- new combination row or changing the ccid to point to an
  -- existing row
  --

  --
  -- always true,
  -- used to populate g_old_rec
  --
  if pay_exa_shd.api_updating
      (p_external_account_id   => l_rec.external_account_id,
       p_object_version_number => l_rec.object_version_number) then
    --
    -- copy any system defaulted values from db row(g_old_rec) into l_rec
    --
    pay_exa_upd.convert_defs(p_rec => l_rec);
  end if;

  --
  -- nb. at this point id_flex_num, summary_flag, enabled_flag,
  -- start_date_active and end_date_active have values
  -- as on the db
  --

  --
  -- call wrapper,
  -- generates formatted msg upon segement validation failure
  --
  pay_exa_shd.keyflex_comb(
    p_dml_mode               => 'UPDATE',
    p_business_group_id      => p_business_group_id,
    p_appl_short_name        => 'PAY',
    p_territory_code         => p_territory_code,
    p_flex_code              => 'BANK',
    p_segment1               => l_rec.segment1,
    p_segment2               => l_rec.segment2,
    p_segment3               => l_rec.segment3,
    p_segment4               => l_rec.segment4,
    p_segment5               => l_rec.segment5,
    p_segment6               => l_rec.segment6,
    p_segment7               => l_rec.segment7,
    p_segment8               => l_rec.segment8,
    p_segment9               => l_rec.segment9,
    p_segment10              => l_rec.segment10,
    p_segment11              => l_rec.segment11,
    p_segment12              => l_rec.segment12,
    p_segment13              => l_rec.segment13,
    p_segment14              => l_rec.segment14,
    p_segment15              => l_rec.segment15,
    p_segment16              => l_rec.segment16,
    p_segment17              => l_rec.segment17,
    p_segment18              => l_rec.segment18,
    p_segment19              => l_rec.segment19,
    p_segment20              => l_rec.segment20,
    p_segment21              => l_rec.segment21,
    p_segment22              => l_rec.segment22,
    p_segment23              => l_rec.segment23,
    p_segment24              => l_rec.segment24,
    p_segment25              => l_rec.segment25,
    p_segment26              => l_rec.segment26,
    p_segment27              => l_rec.segment27,
    p_segment28              => l_rec.segment28,
    p_segment29              => l_rec.segment29,
    p_segment30              => l_rec.segment30,
    p_concat_segments_in     => p_concat_segments,
    --
    -- OUT parameter,
    -- l_rec.external_account_id may have a new value
    --
    p_ccid                   => l_rec.external_account_id,
    p_concat_segments_out    => l_concat_segments_out
    );
  --
  -- nb. object_version_number is a IN OUT parameter,
  -- territory code is mandatory parameter,
  -- update_validate() calls chk_territory_code()
  -- to check that territory code is not mutating,
  -- however if a fresh combination record has been I'ed then this
  -- parameter is used to set territory code on the new record
  --
  upd(
    l_rec.external_account_id,
    l_rec.territory_code,
    l_rec.prenote_date,
    l_rec.object_version_number,
    p_validate);
  --
  -- set the out arguments
  --
  p_external_account_id   := l_rec.external_account_id;
  p_object_version_number := l_rec.object_version_number;
  --
  -- if in validate only mode restore IN OUT parameters to their initial state
  --
  if p_validate then
    p_external_account_id := l_external_account_id_init;
    p_object_version_number := l_object_version_number_init;
  end if;
  --
  hr_utility.set_location('***** Leaving:' || l_proc || ' *****', 20);
end upd_or_sel;
--
END pay_exa_upd;

/
