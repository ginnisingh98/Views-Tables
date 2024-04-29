--------------------------------------------------------
--  DDL for Package Body PAY_PGP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PGP_INS" as
/* $Header: pypgprhi.pkb 115.0 99/07/17 06:22:02 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pgp_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The functions of this
--   procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To insert the row into the schema.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set.
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
Procedure insert_dml(p_rec in out pay_pgp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_pgp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_people_groups
  --
  insert into pay_people_groups
  (	people_group_id,
	group_name,
	id_flex_num,
	summary_flag,
	enabled_flag,
	start_date_active,
	end_date_active,
	segment1,
	segment2,
	segment3,
	segment4,
	segment5,
	segment6,
	segment7,
	segment8,
	segment9,
	segment10,
	segment11,
	segment12,
	segment13,
	segment14,
	segment15,
	segment16,
	segment17,
	segment18,
	segment19,
	segment20,
	segment21,
	segment22,
	segment23,
	segment24,
	segment25,
	segment26,
	segment27,
	segment28,
	segment29,
	segment30
  )
  Values
  (	p_rec.people_group_id,
	p_rec.group_name,
	p_rec.id_flex_num,
	p_rec.summary_flag,
	p_rec.enabled_flag,
	p_rec.start_date_active,
	p_rec.end_date_active,
	p_rec.segment1,
	p_rec.segment2,
	p_rec.segment3,
	p_rec.segment4,
	p_rec.segment5,
	p_rec.segment6,
	p_rec.segment7,
	p_rec.segment8,
	p_rec.segment9,
	p_rec.segment10,
	p_rec.segment11,
	p_rec.segment12,
	p_rec.segment13,
	p_rec.segment14,
	p_rec.segment15,
	p_rec.segment16,
	p_rec.segment17,
	p_rec.segment18,
	p_rec.segment19,
	p_rec.segment20,
	p_rec.segment21,
	p_rec.segment22,
	p_rec.segment23,
	p_rec.segment24,
	p_rec.segment25,
	p_rec.segment26,
	p_rec.segment27,
	p_rec.segment28,
	p_rec.segment29,
	p_rec.segment30
  );
  --
  pay_pgp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_pgp_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pgp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_pgp_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pgp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_pgp_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pgp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_pgp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
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
Procedure pre_insert(p_rec  in out pay_pgp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_people_groups_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.people_group_id;
  Close C_Sel1;
  --
  --
  -- initialise the hardcode flexfield specific attributes:
  --
  p_rec.summary_flag      := 'N';
  p_rec.enabled_flag      := 'Y';
  p_rec.start_date_active := null;
  p_rec.end_date_active   := null;
  --
  -- concatenate the segments for the group_name using a period as a
  -- separator
  --
  p_rec.group_name :=
    hr_api.return_concat_kf_segments
      (p_id_flex_num    => p_rec.id_flex_num,
       p_application_id => 801,
       p_id_flex_code   => 'GRP',
       p_segment1       => p_rec.segment1,
       p_segment2       => p_rec.segment2,
       p_segment3       => p_rec.segment3,
       p_segment4       => p_rec.segment4,
       p_segment5       => p_rec.segment5,
       p_segment6       => p_rec.segment6,
       p_segment7       => p_rec.segment7,
       p_segment8       => p_rec.segment8,
       p_segment9       => p_rec.segment9,
       p_segment10      => p_rec.segment10,
       p_segment11      => p_rec.segment11,
       p_segment12      => p_rec.segment12,
       p_segment13      => p_rec.segment13,
       p_segment14      => p_rec.segment14,
       p_segment15      => p_rec.segment15,
       p_segment16      => p_rec.segment16,
       p_segment17      => p_rec.segment17,
       p_segment18      => p_rec.segment18,
       p_segment19      => p_rec.segment19,
       p_segment20      => p_rec.segment20,
       p_segment21      => p_rec.segment21,
       p_segment22      => p_rec.segment22,
       p_segment23      => p_rec.segment23,
       p_segment24      => p_rec.segment24,
       p_segment25      => p_rec.segment25,
       p_segment26      => p_rec.segment26,
       p_segment27      => p_rec.segment27,
       p_segment28      => p_rec.segment28,
       p_segment29      => p_rec.segment29,
       p_segment30      => p_rec.segment30);
  --
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
Procedure post_insert(p_rec in pay_pgp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out pay_pgp_shd.g_rec_type,
  p_validate   in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_pay_pgp;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  pay_pgp_bus.insert_validate(p_rec);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
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
    ROLLBACK TO ins_pay_pgp;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_people_group_id              out number,
  p_group_name                   out varchar2,
  p_id_flex_num                  in number,
  p_summary_flag                 in varchar2,
  p_enabled_flag                 in varchar2,
  p_start_date_active            in date             default null,
  p_end_date_active              in date             default null,
  p_segment1                     in varchar2         default null,
  p_segment2                     in varchar2         default null,
  p_segment3                     in varchar2         default null,
  p_segment4                     in varchar2         default null,
  p_segment5                     in varchar2         default null,
  p_segment6                     in varchar2         default null,
  p_segment7                     in varchar2         default null,
  p_segment8                     in varchar2         default null,
  p_segment9                     in varchar2         default null,
  p_segment10                    in varchar2         default null,
  p_segment11                    in varchar2         default null,
  p_segment12                    in varchar2         default null,
  p_segment13                    in varchar2         default null,
  p_segment14                    in varchar2         default null,
  p_segment15                    in varchar2         default null,
  p_segment16                    in varchar2         default null,
  p_segment17                    in varchar2         default null,
  p_segment18                    in varchar2         default null,
  p_segment19                    in varchar2         default null,
  p_segment20                    in varchar2         default null,
  p_segment21                    in varchar2         default null,
  p_segment22                    in varchar2         default null,
  p_segment23                    in varchar2         default null,
  p_segment24                    in varchar2         default null,
  p_segment25                    in varchar2         default null,
  p_segment26                    in varchar2         default null,
  p_segment27                    in varchar2         default null,
  p_segment28                    in varchar2         default null,
  p_segment29                    in varchar2         default null,
  p_segment30                    in varchar2         default null,
  p_validate                     in boolean          default false
  ) is
--
  l_rec	  pay_pgp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_pgp_shd.convert_args
  (
  null,
  null,
  p_id_flex_num,
  p_summary_flag,
  p_enabled_flag,
  p_start_date_active,
  p_end_date_active,
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
  p_segment30
  );
  --
  -- Having converted the arguments into the pay_pgp_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_people_group_id := l_rec.people_group_id;
  p_group_name      := l_rec.group_name;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
procedure ins_or_sel
         (p_segment1              in  varchar2 default null,
          p_segment2              in  varchar2 default null,
          p_segment3              in  varchar2 default null,
          p_segment4              in  varchar2 default null,
          p_segment5              in  varchar2 default null,
          p_segment6              in  varchar2 default null,
          p_segment7              in  varchar2 default null,
          p_segment8              in  varchar2 default null,
          p_segment9              in  varchar2 default null,
          p_segment10             in  varchar2 default null,
          p_segment11             in  varchar2 default null,
          p_segment12             in  varchar2 default null,
          p_segment13             in  varchar2 default null,
          p_segment14             in  varchar2 default null,
          p_segment15             in  varchar2 default null,
          p_segment16             in  varchar2 default null,
          p_segment17             in  varchar2 default null,
          p_segment18             in  varchar2 default null,
          p_segment19             in  varchar2 default null,
          p_segment20             in  varchar2 default null,
          p_segment21             in  varchar2 default null,
          p_segment22             in  varchar2 default null,
          p_segment23             in  varchar2 default null,
          p_segment24             in  varchar2 default null,
          p_segment25             in  varchar2 default null,
          p_segment26             in  varchar2 default null,
          p_segment27             in  varchar2 default null,
          p_segment28             in  varchar2 default null,
          p_segment29             in  varchar2 default null,
          p_segment30             in  varchar2 default null,
          p_business_group_id     in  number,
          p_people_group_id       out number,
          p_group_name            out varchar2,
          p_validate              in  boolean default false) is
--
  l_people_group_id       pay_people_groups.people_group_id%type;
  l_group_name            pay_people_groups.group_name%type;
  l_id_flex_num           pay_people_groups.id_flex_num%type;
  l_proc                  varchar2(72) := g_package||'ins_or_sel';
--
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- determine if a people group combination exists
  --
  pay_pgp_shd.segment_combination_check
    (p_segment1               => p_segment1,
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
     p_business_group_id      => p_business_group_id,
     p_people_group_id        => l_people_group_id,
     p_group_name             => l_group_name,
     p_id_flex_num            => l_id_flex_num);
  --
  -- determine the state of p_people_group_id
  --
  -- p_people_group_id
  -- state                 meaning
  -- ===================== =======
  -- -1                    Segment combination does not exist
  -- null                  The segment combination is null
  -- id                    A segment combination has been found
  --
  if (l_people_group_id = -1) then
    hr_utility.set_location(l_proc, 10);
    --
    -- a new combination needs to be inserted
    --
    pay_pgp_ins.ins
      (p_people_group_id        => p_people_group_id,
       p_group_name             => p_group_name,
       p_id_flex_num            => l_id_flex_num,
       p_summary_flag           => null,
       p_enabled_flag           => null,
       p_start_date_active      => null,
       p_end_date_active        => null,
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
       p_validate               => p_validate);
  elsif l_people_group_id is not null then
    --
    -- As the combination already exists we must ensure that the
    -- we return the primary key
    --
    p_people_group_id       := l_people_group_id;
    p_group_name            := l_group_name;
  else
    --
    -- The combination must be null therefore we must ensure that the
    -- we return the primary key as nulls
    --
    p_people_group_id       := null;
    p_group_name            := null;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end ins_or_sel;
--
end pay_pgp_ins;

/
