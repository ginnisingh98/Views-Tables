--------------------------------------------------------
--  DDL for Package Body PAY_EXA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EXA_INS" AS
/* $Header: pyexarhi.pkb 115.13 2003/09/26 06:48:50 tvankayl ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_exa_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The functions of this
--   procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure insert_dml(
   p_rec               in out nocopy pay_exa_shd.g_rec_type,
   p_business_group_id in number
  ) is
  --
  l_proc  varchar2(72) := g_package||'insert_dml';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_exa_shd.g_api_dml := true;  -- set the api dml status

  --
  -- insert_validate(), chk_territory_code(), pay_exa_shd.api_updating()
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
end insert_dml;
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
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure pre_insert(
   p_rec               in out nocopy pay_exa_shd.g_rec_type
  ,p_business_group_id in number
  ) is
  --
  l_proc  varchar2(72) := g_package||'pre_insert';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure post_insert(
   p_rec               in pay_exa_shd.g_rec_type
  ,p_business_group_id in number
  ) is
  --
  l_proc  varchar2(72) := g_package||'post_insert';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
procedure ins(
   p_rec               in out nocopy pay_exa_shd.g_rec_type
  ,p_business_group_id in     number
  ,p_validate          in     boolean default false
   ) is
  --
  l_proc  varchar2(72) := g_package||'ins';
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
    SAVEPOINT ins_pay_exa;
  End If;

  --
  -- call the supporting insert validate operations
  --
  pay_exa_bus.insert_validate(p_rec, p_business_group_id);

  --
  -- call the supporting pre-insert operation
  --
  pre_insert(p_rec, p_business_group_id);

  --
  -- insert the row
  --
  insert_dml(p_rec, p_business_group_id);

  --
  -- call the supporting post-insert operation
  --
  post_insert(p_rec, p_business_group_id);

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
    ROLLBACK TO ins_pay_exa;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
procedure ins(
   p_business_group_id            in number
  ,p_external_account_id          in number
  ,p_territory_code               in varchar2         default null
  ,p_prenote_date                 in date             default null
  ,p_segment1                     in varchar2         default null
  ,p_segment2                     in varchar2         default null
  ,p_segment3                     in varchar2         default null
  ,p_segment4                     in varchar2         default null
  ,p_segment5                     in varchar2         default null
  ,p_segment6                     in varchar2         default null
  ,p_segment7                     in varchar2         default null
  ,p_segment8                     in varchar2         default null
  ,p_segment9                     in varchar2         default null
  ,p_segment10                    in varchar2         default null
  ,p_segment11                    in varchar2         default null
  ,p_segment12                    in varchar2         default null
  ,p_segment13                    in varchar2         default null
  ,p_segment14                    in varchar2         default null
  ,p_segment15                    in varchar2         default null
  ,p_segment16                    in varchar2         default null
  ,p_segment17                    in varchar2         default null
  ,p_segment18                    in varchar2         default null
  ,p_segment19                    in varchar2         default null
  ,p_segment20                    in varchar2         default null
  ,p_segment21                    in varchar2         default null
  ,p_segment22                    in varchar2         default null
  ,p_segment23                    in varchar2         default null
  ,p_segment24                    in varchar2         default null
  ,p_segment25                    in varchar2         default null
  ,p_segment26                    in varchar2         default null
  ,p_segment27                    in varchar2         default null
  ,p_segment28                    in varchar2         default null
  ,p_segment29                    in varchar2         default null
  ,p_segment30                    in varchar2         default null
  ,p_object_version_number        out nocopy number
  ,p_validate                     in boolean          default false
  ) is
  --
  l_rec   pay_exa_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
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
  -- call conversion function to turn arguments into the p_rec structure
  --
  l_rec :=
  pay_exa_shd.convert_args
  (
    p_external_account_id,
    p_territory_code,
    p_prenote_date,
    --
    -- do need to maintain these columns, set by aol api
    --
    null,  -- id_flex_num
    null,  -- summary_flag
    null,  -- enabled_flag
    null,  -- start_date_active
    null,  -- end_date_active
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
    null
    );
  --
  -- having converted the arguments into the pay_exa_rec plsql record
  -- structure we call the corresponding record business process
  --
  ins(
    p_rec               => l_rec,
    p_business_group_id => p_business_group_id,
    p_validate          => p_validate);
  --
  -- as the primary key argument(s) are specified as an OUT's we
  -- must set these values
  --
  -- object version number may have changed,
  -- select the latest value and pass as out paramter
  --
  open  csr_ovn(l_rec.external_account_id);
  fetch csr_ovn into p_object_version_number;
  close csr_ovn;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end ins;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
procedure ins_or_sel(
   p_segment1              in  varchar2 default null
  ,p_segment2              in  varchar2 default null
  ,p_segment3              in  varchar2 default null
  ,p_segment4              in  varchar2 default null
  ,p_segment5              in  varchar2 default null
  ,p_segment6              in  varchar2 default null
  ,p_segment7              in  varchar2 default null
  ,p_segment8              in  varchar2 default null
  ,p_segment9              in  varchar2 default null
  ,p_segment10             in  varchar2 default null
  ,p_segment11             in  varchar2 default null
  ,p_segment12             in  varchar2 default null
  ,p_segment13             in  varchar2 default null
  ,p_segment14             in  varchar2 default null
  ,p_segment15             in  varchar2 default null
  ,p_segment16             in  varchar2 default null
  ,p_segment17             in  varchar2 default null
  ,p_segment18             in  varchar2 default null
  ,p_segment19             in  varchar2 default null
  ,p_segment20             in  varchar2 default null
  ,p_segment21             in  varchar2 default null
  ,p_segment22             in  varchar2 default null
  ,p_segment23             in  varchar2 default null
  ,p_segment24             in  varchar2 default null
  ,p_segment25             in  varchar2 default null
  ,p_segment26             in  varchar2 default null
  ,p_segment27             in  varchar2 default null
  ,p_segment28             in  varchar2 default null
  ,p_segment29             in  varchar2 default null
  ,p_segment30             in  varchar2 default null
  ,p_concat_segments       in  varchar2 default null
  ,p_business_group_id     in  number
-- make territory_code code a mandatory parameter on I interface
  ,p_territory_code        in  varchar2
  ,p_prenote_date          in  date     default null
  ,p_external_account_id   out nocopy number
  ,p_object_version_number out nocopy number
  ,p_validate              in boolean   default false
  ) is
  --
  l_external_account_id   pay_external_accounts.external_account_id%type;
  l_proc                  varchar2(72) := g_package||'ins_or_sel';
  l_object_version_number pay_external_accounts.object_version_number%type;
  l_prenote_date          pay_external_accounts.prenote_date%type;
  --
  l_concat_segments_out     varchar2(4600);
  --
begin
  hr_utility.set_location('***** Entering:' || l_proc || ' *****', 5);
  --
  -- stub - do we need to validate prenote_date,
  --        could be null ?
  --
  -- territory_code code must be specified as its value may be
  -- placed on a fresh combination record
  --
  hr_api.mandatory_arg_error(
    p_api_name          => l_proc,
    p_argument          => 'territory_code',
    p_argument_value    => p_territory_code
    );
  --
  -- call wrapper,
  -- generates formatted msg upon segement validation failure,
  -- do not need to deal with out parameters on failure as this is
  -- only an internal call,
  -- out paramters used by ins_or_sel() are explicitly set to null
  -- on failure
  --
  pay_exa_shd.keyflex_comb(
    p_dml_mode               => 'INSERT',
    p_business_group_id      => p_business_group_id,
    p_appl_short_name        => 'PAY',
    p_territory_code         => p_territory_code,
    p_flex_code              => 'BANK',
    p_segment1               => p_segment1,
    p_segment2               => p_segment2,
    p_segment3               => p_segment3,
    p_segment4               => p_segment4,
    p_segment5               => p_segment5,
    p_segment6               => p_segment6,
    p_segment7               => p_segment7,
    p_segment8               => p_segment8,
    p_segment9               => p_segment9,
    p_segment10              => p_segment10,
    p_segment11              => p_segment11,
    p_segment12              => p_segment12,
    p_segment13              => p_segment13,
    p_segment14              => p_segment14,
    p_segment15              => p_segment15,
    p_segment16              => p_segment16,
    p_segment17              => p_segment17,
    p_segment18              => p_segment18,
    p_segment19              => p_segment19,
    p_segment20              => p_segment20,
    p_segment21              => p_segment21,
    p_segment22              => p_segment22,
    p_segment23              => p_segment23,
    p_segment24              => p_segment24,
    p_segment25              => p_segment25,
    p_segment26              => p_segment26,
    p_segment27              => p_segment27,
    p_segment28              => p_segment28,
    p_segment29              => p_segment29,
    p_segment30              => p_segment30,
    p_concat_segments_in     => p_concat_segments,
    p_ccid                   => l_external_account_id,
    p_concat_segments_out    => l_concat_segments_out
    );
  --
  -- I interface is now actually doing an U,
  -- set territory_code, prenote_date on corresponding external
  -- account row,
  -- all parameters are required to generate p_rec structure
  --
  pay_exa_ins.ins(
    p_business_group_id      => p_business_group_id,
    p_external_account_id    => l_external_account_id,
    p_territory_code         => p_territory_code,
    p_prenote_date           => p_prenote_date,
    p_segment1               => p_segment1,
    p_segment2               => p_segment2,
    p_segment3               => p_segment3,
    p_segment4               => p_segment4,
    p_segment5               => p_segment5,
    p_segment6               => p_segment6,
    p_segment7               => p_segment7,
    p_segment8               => p_segment8,
    p_segment9               => p_segment9,
    p_segment10              => p_segment10,
    p_segment11              => p_segment11,
    p_segment12              => p_segment12,
    p_segment13              => p_segment13,
    p_segment14              => p_segment14,
    p_segment15              => p_segment15,
    p_segment16              => p_segment16,
    p_segment17              => p_segment17,
    p_segment18              => p_segment18,
    p_segment19              => p_segment19,
    p_segment20              => p_segment20,
    p_segment21              => p_segment21,
    p_segment22              => p_segment22,
    p_segment23              => p_segment23,
    p_segment24              => p_segment24,
    p_segment25              => p_segment25,
    p_segment26              => p_segment26,
    p_segment27              => p_segment27,
    p_segment28              => p_segment28,
    p_segment29              => p_segment29,
    p_segment30              => p_segment30,
    p_object_version_number  => l_object_version_number,
    p_validate               => p_validate
    );
  --
  -- set out arguments
  --
  p_object_version_number := l_object_version_number;
  p_external_account_id := l_external_account_id;
  --
  -- explicitly set out arguments to null if in validate only mode
  --
  if p_validate then
    p_external_account_id   := null;
    p_object_version_number := null;
  end if;
  --
  hr_utility.set_location('***** Leaving:' || l_proc || ' *****', 100);
end ins_or_sel;
--
END pay_exa_ins;

/
