--------------------------------------------------------
--  DDL for Package Body HR_SCL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SCL_INS" as
/* $Header: hrsclrhi.pkb 115.3 2002/12/03 08:23:56 raranjan ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_scl_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
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
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
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
Procedure insert_dml(p_rec in out nocopy hr_scl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_scl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: hr_soft_coding_keyflex
  --
  insert into hr_soft_coding_keyflex
  (	soft_coding_keyflex_id,
	concatenated_segments,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
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
  (	p_rec.soft_coding_keyflex_id,
	p_rec.concatenated_segments,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
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
  hr_scl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hr_scl_shd.g_api_dml := false;   -- Unset the api dml status
    hr_scl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    hr_scl_shd.g_api_dml := false;   -- Unset the api dml status
    hr_scl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hr_scl_shd.g_api_dml := false;   -- Unset the api dml status
    hr_scl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hr_scl_shd.g_api_dml := false;   -- Unset the api dml status
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
-- In Parameters:
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
Procedure pre_insert(p_rec  in out nocopy hr_scl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select hr_soft_coding_keyflex_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.soft_coding_keyflex_id;
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
  p_rec.concatenated_segments :=
    hr_api.return_concat_kf_segments
      (p_id_flex_num    => p_rec.id_flex_num,
       p_application_id => 800,
       p_id_flex_code   => 'SCL',
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
-- In Parameters:
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
Procedure post_insert(p_rec in hr_scl_shd.g_rec_type) is
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
  (p_rec        in out nocopy hr_scl_shd.g_rec_type,
   p_validate   in     boolean default false) is
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
    SAVEPOINT ins_hr_scl;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  hr_scl_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_hr_scl;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_soft_coding_keyflex_id       out nocopy number,
  p_concatenated_segments        out nocopy varchar2,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
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
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  hr_scl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_scl_shd.convert_args
  (
  null,
  null,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
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
  -- Having converted the arguments into the hr_scl_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_soft_coding_keyflex_id := l_rec.soft_coding_keyflex_id;
  p_concatenated_segments  := l_rec.concatenated_segments;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
procedure ins_or_sel
         (p_segment1               in  varchar2 default null,
          p_segment2               in  varchar2 default null,
          p_segment3               in  varchar2 default null,
          p_segment4               in  varchar2 default null,
          p_segment5               in  varchar2 default null,
          p_segment6               in  varchar2 default null,
          p_segment7               in  varchar2 default null,
          p_segment8               in  varchar2 default null,
          p_segment9               in  varchar2 default null,
          p_segment10              in  varchar2 default null,
          p_segment11              in  varchar2 default null,
          p_segment12              in  varchar2 default null,
          p_segment13              in  varchar2 default null,
          p_segment14              in  varchar2 default null,
          p_segment15              in  varchar2 default null,
          p_segment16              in  varchar2 default null,
          p_segment17              in  varchar2 default null,
          p_segment18              in  varchar2 default null,
          p_segment19              in  varchar2 default null,
          p_segment20              in  varchar2 default null,
          p_segment21              in  varchar2 default null,
          p_segment22              in  varchar2 default null,
          p_segment23              in  varchar2 default null,
          p_segment24              in  varchar2 default null,
          p_segment25              in  varchar2 default null,
          p_segment26              in  varchar2 default null,
          p_segment27              in  varchar2 default null,
          p_segment28              in  varchar2 default null,
          p_segment29              in  varchar2 default null,
          p_segment30              in  varchar2 default null,
          p_business_group_id      in  number,
          p_request_id             in  number   default null,
          p_program_application_id in  number   default null,
          p_program_id             in  number   default null,
          p_program_update_date    in  date     default null,
          p_soft_coding_keyflex_id out nocopy number,
          p_concatenated_segments  out nocopy varchar2,
          p_validate               in  boolean  default false) is
--
  l_soft_coding_keyflex_id hr_soft_coding_keyflex.soft_coding_keyflex_id%type;
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%type;
  l_id_flex_num            hr_soft_coding_keyflex.id_flex_num%type;
  l_proc                   varchar2(72) := g_package||'ins_or_sel';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- determine if a people group combination exists
  --
  hr_scl_shd.segment_combination_check
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
     p_soft_coding_keyflex_id => l_soft_coding_keyflex_id,
     p_concatenated_segments  => l_concatenated_segments,
     p_id_flex_num            => l_id_flex_num);
  --
  -- determine the state of soft_coding_keyflex_id
  --
  -- l_soft_coding_keyflex_id
  -- state                 meaning
  -- ===================== =======
  -- -1                    Segment combination does not exist
  -- null                  The segment combination is null
  -- id                    A segment combination has been found
  --
  if (l_soft_coding_keyflex_id = -1) then
    hr_utility.set_location(l_proc, 10);
    --
    -- a new combination needs to be inserted
    --
    hr_scl_ins.ins
      (p_soft_coding_keyflex_id => p_soft_coding_keyflex_id,
       p_concatenated_segments  => p_concatenated_segments,
       p_request_id             => p_request_id,
       p_program_application_id => p_program_application_id,
       p_program_id             => p_program_id,
       p_program_update_date    => p_program_update_date,
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
  elsif l_soft_coding_keyflex_id is not null then
    --
    -- As the combination already exists we must ensure that the
    -- we return the primary key
    --
    p_soft_coding_keyflex_id := l_soft_coding_keyflex_id;
    p_concatenated_segments  := l_concatenated_segments;
  else
    --
    -- The combination must be null therefore we must ensure that the
    -- we return the primary key as nulls
    --
    p_soft_coding_keyflex_id := null;
    p_concatenated_segments  := null;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end ins_or_sel;
--
end hr_scl_ins;

/
