--------------------------------------------------------
--  DDL for Package Body HR_ICX_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ICX_UPD" as
/* $Header: hricxrhi.pkb 115.5 2003/10/23 01:44:08 bsubrama noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_icx_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
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
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy hr_icx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the hr_item_contexts Row
  --
  update hr_item_contexts
    set
     item_context_id                 = p_rec.item_context_id
    ,object_version_number           = p_rec.object_version_number
    ,id_flex_num                     = p_rec.id_flex_num
    ,summary_flag                    = p_rec.summary_flag
    ,enabled_flag                    = p_rec.enabled_flag
    ,start_date_active               = p_rec.start_date_active
    ,end_date_active                 = p_rec.end_date_active
    ,segment1                        = p_rec.segment1
    ,segment2                        = p_rec.segment2
    ,segment3                        = p_rec.segment3
    ,segment4                        = p_rec.segment4
    ,segment5                        = p_rec.segment5
    ,segment6                        = p_rec.segment6
    ,segment7                        = p_rec.segment7
    ,segment8                        = p_rec.segment8
    ,segment9                        = p_rec.segment9
    ,segment10                       = p_rec.segment10
    ,segment11                       = p_rec.segment11
    ,segment12                       = p_rec.segment12
    ,segment13                       = p_rec.segment13
    ,segment14                       = p_rec.segment14
    ,segment15                       = p_rec.segment15
    ,segment16                       = p_rec.segment16
    ,segment17                       = p_rec.segment17
    ,segment18                       = p_rec.segment18
    ,segment19                       = p_rec.segment19
    ,segment20                       = p_rec.segment20
    ,segment21                       = p_rec.segment21
    ,segment22                       = p_rec.segment22
    ,segment23                       = p_rec.segment23
    ,segment24                       = p_rec.segment24
    ,segment25                       = p_rec.segment25
    ,segment26                       = p_rec.segment26
    ,segment27                       = p_rec.segment27
    ,segment28                       = p_rec.segment28
    ,segment29                       = p_rec.segment29
    ,segment30                       = p_rec.segment30
    where item_context_id = p_rec.item_context_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_icx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_icx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_icx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End update_dml;
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
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in hr_icx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
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
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_effective_date               in date
  ,p_rec                          in hr_icx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_icx_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_item_context_id
      => p_rec.item_context_id
      ,p_id_flex_num
      => p_rec.id_flex_num
      ,p_summary_flag
      => p_rec.summary_flag
      ,p_enabled_flag
      => p_rec.enabled_flag
      ,p_start_date_active
      => p_rec.start_date_active
      ,p_end_date_active
      => p_rec.end_date_active
      ,p_segment1
      => p_rec.segment1
      ,p_segment2
      => p_rec.segment2
      ,p_segment3
      => p_rec.segment3
      ,p_segment4
      => p_rec.segment4
      ,p_segment5
      => p_rec.segment5
      ,p_segment6
      => p_rec.segment6
      ,p_segment7
      => p_rec.segment7
      ,p_segment8
      => p_rec.segment8
      ,p_segment9
      => p_rec.segment9
      ,p_segment10
      => p_rec.segment10
      ,p_segment11
      => p_rec.segment11
      ,p_segment12
      => p_rec.segment12
      ,p_segment13
      => p_rec.segment13
      ,p_segment14
      => p_rec.segment14
      ,p_segment15
      => p_rec.segment15
      ,p_segment16
      => p_rec.segment16
      ,p_segment17
      => p_rec.segment17
      ,p_segment18
      => p_rec.segment18
      ,p_segment19
      => p_rec.segment19
      ,p_segment20
      => p_rec.segment20
      ,p_segment21
      => p_rec.segment21
      ,p_segment22
      => p_rec.segment22
      ,p_segment23
      => p_rec.segment23
      ,p_segment24
      => p_rec.segment24
      ,p_segment25
      => p_rec.segment25
      ,p_segment26
      => p_rec.segment26
      ,p_segment27
      => p_rec.segment27
      ,p_segment28
      => p_rec.segment28
      ,p_segment29
      => p_rec.segment29
      ,p_segment30
      => p_rec.segment30
      ,p_object_version_number_o
      => hr_icx_shd.g_old_rec.object_version_number
      ,p_id_flex_num_o
      => hr_icx_shd.g_old_rec.id_flex_num
      ,p_summary_flag_o
      => hr_icx_shd.g_old_rec.summary_flag
      ,p_enabled_flag_o
      => hr_icx_shd.g_old_rec.enabled_flag
      ,p_start_date_active_o
      => hr_icx_shd.g_old_rec.start_date_active
      ,p_end_date_active_o
      => hr_icx_shd.g_old_rec.end_date_active
      ,p_segment1_o
      => hr_icx_shd.g_old_rec.segment1
      ,p_segment2_o
      => hr_icx_shd.g_old_rec.segment2
      ,p_segment3_o
      => hr_icx_shd.g_old_rec.segment3
      ,p_segment4_o
      => hr_icx_shd.g_old_rec.segment4
      ,p_segment5_o
      => hr_icx_shd.g_old_rec.segment5
      ,p_segment6_o
      => hr_icx_shd.g_old_rec.segment6
      ,p_segment7_o
      => hr_icx_shd.g_old_rec.segment7
      ,p_segment8_o
      => hr_icx_shd.g_old_rec.segment8
      ,p_segment9_o
      => hr_icx_shd.g_old_rec.segment9
      ,p_segment10_o
      => hr_icx_shd.g_old_rec.segment10
      ,p_segment11_o
      => hr_icx_shd.g_old_rec.segment11
      ,p_segment12_o
      => hr_icx_shd.g_old_rec.segment12
      ,p_segment13_o
      => hr_icx_shd.g_old_rec.segment13
      ,p_segment14_o
      => hr_icx_shd.g_old_rec.segment14
      ,p_segment15_o
      => hr_icx_shd.g_old_rec.segment15
      ,p_segment16_o
      => hr_icx_shd.g_old_rec.segment16
      ,p_segment17_o
      => hr_icx_shd.g_old_rec.segment17
      ,p_segment18_o
      => hr_icx_shd.g_old_rec.segment18
      ,p_segment19_o
      => hr_icx_shd.g_old_rec.segment19
      ,p_segment20_o
      => hr_icx_shd.g_old_rec.segment20
      ,p_segment21_o
      => hr_icx_shd.g_old_rec.segment21
      ,p_segment22_o
      => hr_icx_shd.g_old_rec.segment22
      ,p_segment23_o
      => hr_icx_shd.g_old_rec.segment23
      ,p_segment24_o
      => hr_icx_shd.g_old_rec.segment24
      ,p_segment25_o
      => hr_icx_shd.g_old_rec.segment25
      ,p_segment26_o
      => hr_icx_shd.g_old_rec.segment26
      ,p_segment27_o
      => hr_icx_shd.g_old_rec.segment27
      ,p_segment28_o
      => hr_icx_shd.g_old_rec.segment28
      ,p_segment29_o
      => hr_icx_shd.g_old_rec.segment29
      ,p_segment30_o
      => hr_icx_shd.g_old_rec.segment30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_ITEM_CONTEXTS'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy hr_icx_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.id_flex_num = hr_api.g_number) then
    p_rec.id_flex_num :=
    hr_icx_shd.g_old_rec.id_flex_num;
  End If;
  If (p_rec.summary_flag = hr_api.g_varchar2) then
    p_rec.summary_flag :=
    hr_icx_shd.g_old_rec.summary_flag;
  End If;
  If (p_rec.enabled_flag = hr_api.g_varchar2) then
    p_rec.enabled_flag :=
    hr_icx_shd.g_old_rec.enabled_flag;
  End If;
  If (p_rec.start_date_active = hr_api.g_date) then
    p_rec.start_date_active :=
    hr_icx_shd.g_old_rec.start_date_active;
  End If;
  If (p_rec.end_date_active = hr_api.g_date) then
    p_rec.end_date_active :=
    hr_icx_shd.g_old_rec.end_date_active;
  End If;
  If (p_rec.segment1 = hr_api.g_varchar2) then
    p_rec.segment1 :=
    hr_icx_shd.g_old_rec.segment1;
  End If;
  If (p_rec.segment2 = hr_api.g_varchar2) then
    p_rec.segment2 :=
    hr_icx_shd.g_old_rec.segment2;
  End If;
  If (p_rec.segment3 = hr_api.g_varchar2) then
    p_rec.segment3 :=
    hr_icx_shd.g_old_rec.segment3;
  End If;
  If (p_rec.segment4 = hr_api.g_varchar2) then
    p_rec.segment4 :=
    hr_icx_shd.g_old_rec.segment4;
  End If;
  If (p_rec.segment5 = hr_api.g_varchar2) then
    p_rec.segment5 :=
    hr_icx_shd.g_old_rec.segment5;
  End If;
  If (p_rec.segment6 = hr_api.g_varchar2) then
    p_rec.segment6 :=
    hr_icx_shd.g_old_rec.segment6;
  End If;
  If (p_rec.segment7 = hr_api.g_varchar2) then
    p_rec.segment7 :=
    hr_icx_shd.g_old_rec.segment7;
  End If;
  If (p_rec.segment8 = hr_api.g_varchar2) then
    p_rec.segment8 :=
    hr_icx_shd.g_old_rec.segment8;
  End If;
  If (p_rec.segment9 = hr_api.g_varchar2) then
    p_rec.segment9 :=
    hr_icx_shd.g_old_rec.segment9;
  End If;
  If (p_rec.segment10 = hr_api.g_varchar2) then
    p_rec.segment10 :=
    hr_icx_shd.g_old_rec.segment10;
  End If;
  If (p_rec.segment11 = hr_api.g_varchar2) then
    p_rec.segment11 :=
    hr_icx_shd.g_old_rec.segment11;
  End If;
  If (p_rec.segment12 = hr_api.g_varchar2) then
    p_rec.segment12 :=
    hr_icx_shd.g_old_rec.segment12;
  End If;
  If (p_rec.segment13 = hr_api.g_varchar2) then
    p_rec.segment13 :=
    hr_icx_shd.g_old_rec.segment13;
  End If;
  If (p_rec.segment14 = hr_api.g_varchar2) then
    p_rec.segment14 :=
    hr_icx_shd.g_old_rec.segment14;
  End If;
  If (p_rec.segment15 = hr_api.g_varchar2) then
    p_rec.segment15 :=
    hr_icx_shd.g_old_rec.segment15;
  End If;
  If (p_rec.segment16 = hr_api.g_varchar2) then
    p_rec.segment16 :=
    hr_icx_shd.g_old_rec.segment16;
  End If;
  If (p_rec.segment17 = hr_api.g_varchar2) then
    p_rec.segment17 :=
    hr_icx_shd.g_old_rec.segment17;
  End If;
  If (p_rec.segment18 = hr_api.g_varchar2) then
    p_rec.segment18 :=
    hr_icx_shd.g_old_rec.segment18;
  End If;
  If (p_rec.segment19 = hr_api.g_varchar2) then
    p_rec.segment19 :=
    hr_icx_shd.g_old_rec.segment19;
  End If;
  If (p_rec.segment20 = hr_api.g_varchar2) then
    p_rec.segment20 :=
    hr_icx_shd.g_old_rec.segment20;
  End If;
  If (p_rec.segment21 = hr_api.g_varchar2) then
    p_rec.segment21 :=
    hr_icx_shd.g_old_rec.segment21;
  End If;
  If (p_rec.segment22 = hr_api.g_varchar2) then
    p_rec.segment22 :=
    hr_icx_shd.g_old_rec.segment22;
  End If;
  If (p_rec.segment23 = hr_api.g_varchar2) then
    p_rec.segment23 :=
    hr_icx_shd.g_old_rec.segment23;
  End If;
  If (p_rec.segment24 = hr_api.g_varchar2) then
    p_rec.segment24 :=
    hr_icx_shd.g_old_rec.segment24;
  End If;
  If (p_rec.segment25 = hr_api.g_varchar2) then
    p_rec.segment25 :=
    hr_icx_shd.g_old_rec.segment25;
  End If;
  If (p_rec.segment26 = hr_api.g_varchar2) then
    p_rec.segment26 :=
    hr_icx_shd.g_old_rec.segment26;
  End If;
  If (p_rec.segment27 = hr_api.g_varchar2) then
    p_rec.segment27 :=
    hr_icx_shd.g_old_rec.segment27;
  End If;
  If (p_rec.segment28 = hr_api.g_varchar2) then
    p_rec.segment28 :=
    hr_icx_shd.g_old_rec.segment28;
  End If;
  If (p_rec.segment29 = hr_api.g_varchar2) then
    p_rec.segment29 :=
    hr_icx_shd.g_old_rec.segment29;
  End If;
  If (p_rec.segment30 = hr_api.g_varchar2) then
    p_rec.segment30 :=
    hr_icx_shd.g_old_rec.segment30;
  End If;
  --
End convert_defs;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< upd_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure upd_or_sel
         (p_segment1               in     varchar2 default hr_api.g_varchar2,
          p_segment2               in     varchar2 default hr_api.g_varchar2,
          p_segment3               in     varchar2 default hr_api.g_varchar2,
          p_segment4               in     varchar2 default hr_api.g_varchar2,
          p_segment5               in     varchar2 default hr_api.g_varchar2,
          p_segment6               in     varchar2 default hr_api.g_varchar2,
          p_segment7               in     varchar2 default hr_api.g_varchar2,
          p_segment8               in     varchar2 default hr_api.g_varchar2,
          p_segment9               in     varchar2 default hr_api.g_varchar2,
          p_segment10              in     varchar2 default hr_api.g_varchar2,
          p_segment11              in     varchar2 default hr_api.g_varchar2,
          p_segment12              in     varchar2 default hr_api.g_varchar2,
          p_segment13              in     varchar2 default hr_api.g_varchar2,
          p_segment14              in     varchar2 default hr_api.g_varchar2,
          p_segment15              in     varchar2 default hr_api.g_varchar2,
          p_segment16              in     varchar2 default hr_api.g_varchar2,
          p_segment17              in     varchar2 default hr_api.g_varchar2,
          p_segment18              in     varchar2 default hr_api.g_varchar2,
          p_segment19              in     varchar2 default hr_api.g_varchar2,
          p_segment20              in     varchar2 default hr_api.g_varchar2,
          p_segment21              in     varchar2 default hr_api.g_varchar2,
          p_segment22              in     varchar2 default hr_api.g_varchar2,
          p_segment23              in     varchar2 default hr_api.g_varchar2,
          p_segment24              in     varchar2 default hr_api.g_varchar2,
          p_segment25              in     varchar2 default hr_api.g_varchar2,
          p_segment26              in     varchar2 default hr_api.g_varchar2,
          p_segment27              in     varchar2 default hr_api.g_varchar2,
          p_segment28              in     varchar2 default hr_api.g_varchar2,
          p_segment29              in     varchar2 default hr_api.g_varchar2,
          p_segment30              in     varchar2 default hr_api.g_varchar2,
          p_context_type           in     varchar2 default hr_api.g_varchar2,
          p_item_context_id        in out nocopy number,
          p_object_version_number  in out nocopy number,
          p_concatenated_segments     out nocopy varchar2
          ) is
  --
  CURSOR cur_id_flex
  IS
  SELECT id_flex_num
  FROM fnd_id_flex_structures
  WHERE id_flex_structure_code = p_context_type
  AND application_id = 800
  AND id_flex_code = 'ICX';

  l_proc          varchar2(72) := g_package||'upd_or_sel';
  l_rec           hr_icx_shd.g_rec_type;
  l_concatenated_segments   varchar2(2000);
  l_segs_changed           boolean;
  l_id_flex_num number ;
  l_context_type varchar2(30);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- deriving id_flex_num
    OPEN cur_id_flex;
    FETCH cur_id_flex INTO l_id_flex_num;
    CLOSE cur_id_flex;
  --
  -- Derive if any segments are changing
  If ((l_rec.segment1 = hr_api.g_varchar2) AND
     (l_rec.segment2 = hr_api.g_varchar2)  AND
     (l_rec.segment3 = hr_api.g_varchar2)  AND
     (l_rec.segment4 = hr_api.g_varchar2)  AND
     (l_rec.segment5 = hr_api.g_varchar2)  AND
     (l_rec.segment6 = hr_api.g_varchar2)  AND
     (l_rec.segment7 = hr_api.g_varchar2)  AND
     (l_rec.segment8 = hr_api.g_varchar2)  AND
     (l_rec.segment9 = hr_api.g_varchar2)  AND
     (l_rec.segment10 = hr_api.g_varchar2) AND
     (l_rec.segment11 = hr_api.g_varchar2) AND
     (l_rec.segment12 = hr_api.g_varchar2) AND
     (l_rec.segment13 = hr_api.g_varchar2) AND
     (l_rec.segment14 = hr_api.g_varchar2) AND
     (l_rec.segment15 = hr_api.g_varchar2) AND
     (l_rec.segment16 = hr_api.g_varchar2) AND
     (l_rec.segment17 = hr_api.g_varchar2) AND
     (l_rec.segment18 = hr_api.g_varchar2) AND
     (l_rec.segment19 = hr_api.g_varchar2) AND
     (l_rec.segment20 = hr_api.g_varchar2) AND
     (l_rec.segment21 = hr_api.g_varchar2) AND
     (l_rec.segment22 = hr_api.g_varchar2) AND
     (l_rec.segment23 = hr_api.g_varchar2) AND
     (l_rec.segment24 = hr_api.g_varchar2) AND
     (l_rec.segment25 = hr_api.g_varchar2) AND
     (l_rec.segment26 = hr_api.g_varchar2) AND
     (l_rec.segment27 = hr_api.g_varchar2) AND
     (l_rec.segment28 = hr_api.g_varchar2) AND
     (l_rec.segment29 = hr_api.g_varchar2) AND
     (l_rec.segment30 = hr_api.g_varchar2)) THEN
     l_segs_changed := true;
   Else
     l_segs_changed := false;
   End if;
   --
  -- Do not need to go any further if there is nothing to do.
  If (p_context_type = hr_api.g_varchar2)
    AND (l_segs_changed = false) THEN
    --
    -- nothing to do
    p_concatenated_segments  := null;
    --
  ELSE
    --
    -- convert args into record format
    l_rec :=
      hr_icx_shd.convert_args (
       p_item_context_id    => p_item_context_id,
       p_object_version_number => p_object_version_number,
       p_id_flex_num        => l_id_flex_num,
       p_summary_flag       => null,
       p_enabled_flag       => null,
       p_start_date_active  => null,
       p_end_date_active    => null,
       p_segment1           => p_segment1,
       p_segment2           => p_segment2,
       p_segment3           => p_segment3,
       p_segment4           => p_segment4,
       p_segment5           => p_segment5,
       p_segment6           => p_segment6,
       p_segment7           => p_segment7,
       p_segment8           => p_segment8,
       p_segment9           => p_segment9,
       p_segment10          => p_segment10,
       p_segment11          => p_segment11,
       p_segment12          => p_segment12,
       p_segment13          => p_segment13,
       p_segment14          => p_segment14,
       p_segment15          => p_segment15,
       p_segment16          => p_segment16,
       p_segment17          => p_segment17,
       p_segment18          => p_segment18,
       p_segment19          => p_segment19,
       p_segment20          => p_segment20,
       p_segment21          => p_segment21,
       p_segment22          => p_segment22,
       p_segment23          => p_segment23,
       p_segment24          => p_segment24,
       p_segment25          => p_segment25,
       p_segment26          => p_segment26,
       p_segment27          => p_segment27,
       p_segment28          => p_segment28,
       p_segment29          => p_segment29,
       p_segment30          => p_segment30
       );
    --
    -- check to see if we are updating a row
    --
    if hr_icx_shd.api_updating
       (p_item_context_id => l_rec.item_context_id
       ,p_object_version_number => l_rec.object_version_number
       ) then
      --
      hr_utility.set_location(l_proc, 10);
      --
      -- the current row exists and we have populated the g_old_rec
      -- we must now build up the new record by converting the
      -- arguments into a record structure and converting any of the
      -- system default values
      --
      convert_defs(l_rec);
    else
      --
      -- as we are actually doing an insert we need to reset the
      -- arguments if they are using a system default value
      -- to null otherwise the segments will have the system default
      -- values when being inserted
      --
      if (l_rec.segment1 = hr_api.g_varchar2) then
        l_rec.segment1 := null;
      end if;
    if (l_rec.segment2 = hr_api.g_varchar2) then
      l_rec.segment2 := null;
    end if;
    if (l_rec.segment3 = hr_api.g_varchar2) then
      l_rec.segment3 := null;
    end if;
    if (l_rec.segment4 = hr_api.g_varchar2) then
      l_rec.segment4 := null;
    end if;
    if (l_rec.segment5 = hr_api.g_varchar2) then
      l_rec.segment5 := null;
    end if;
    if (l_rec.segment6 = hr_api.g_varchar2) then
      l_rec.segment6 := null;
    end if;
    if (l_rec.segment7 = hr_api.g_varchar2) then
      l_rec.segment7 := null;
    end if;
    if (l_rec.segment8 = hr_api.g_varchar2) then
      l_rec.segment8 := null;
    end if;
    if (l_rec.segment9 = hr_api.g_varchar2) then
      l_rec.segment9 := null;
    end if;
    if (l_rec.segment10 = hr_api.g_varchar2) then
      l_rec.segment10 := null;
    end if;
    if (l_rec.segment11 = hr_api.g_varchar2) then
      l_rec.segment11 := null;
    end if;
    if (l_rec.segment12 = hr_api.g_varchar2) then
      l_rec.segment12 := null;
    end if;
    if (l_rec.segment13 = hr_api.g_varchar2) then
      l_rec.segment13 := null;
    end if;
    if (l_rec.segment14 = hr_api.g_varchar2) then
      l_rec.segment14 := null;
    end if;
    if (l_rec.segment15 = hr_api.g_varchar2) then
      l_rec.segment15 := null;
    end if;
    if (l_rec.segment16 = hr_api.g_varchar2) then
      l_rec.segment16 := null;
    end if;
    if (l_rec.segment17 = hr_api.g_varchar2) then
      l_rec.segment17 := null;
    end if;
    if (l_rec.segment18 = hr_api.g_varchar2) then
      l_rec.segment18 := null;
    end if;
    if (l_rec.segment19 = hr_api.g_varchar2) then
      l_rec.segment19 := null;
    end if;
    if (l_rec.segment20 = hr_api.g_varchar2) then
      l_rec.segment20 := null;
    end if;
    if (l_rec.segment21 = hr_api.g_varchar2) then
      l_rec.segment21 := null;
    end if;
    if (l_rec.segment22 = hr_api.g_varchar2) then
      l_rec.segment22 := null;
    end if;
    if (l_rec.segment23 = hr_api.g_varchar2) then
      l_rec.segment23 := null;
    end if;
    if (l_rec.segment24 = hr_api.g_varchar2) then
      l_rec.segment24 := null;
    end if;
    if (l_rec.segment25 = hr_api.g_varchar2) then
      l_rec.segment25 := null;
    end if;
    if (l_rec.segment26 = hr_api.g_varchar2) then
      l_rec.segment26 := null;
    end if;
    if (l_rec.segment27 = hr_api.g_varchar2) then
      l_rec.segment27 := null;
    end if;
    if (l_rec.segment28 = hr_api.g_varchar2) then
      l_rec.segment28 := null;
    end if;
    if (l_rec.segment29 = hr_api.g_varchar2) then
      l_rec.segment29 := null;
    end if;
    if (l_rec.segment30 = hr_api.g_varchar2) then
      l_rec.segment30 := null;
    end if;
    if (p_context_type = hr_api.g_varchar2) then
      l_context_type := null;
    else
      l_context_type := p_context_type;
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- call the ins_or_sel process
  --
  hr_icx_ins.ins_or_sel
    (p_segment1               => l_rec.segment1,
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
     p_context_type           => l_context_type,
     p_item_context_id        => l_rec.item_context_id,
     p_concatenated_segments  => l_concatenated_segments
     );
  --
  -- set the out arguments
  --
  -- p_id_flex_num            := l_rec.id_flex_num;
  p_concatenated_segments  := l_concatenated_segments;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  END IF;
--
end upd_or_sel;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy hr_icx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  hr_icx_shd.lck
    (p_rec.item_context_id,
     p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  hr_icx_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  hr_icx_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hr_icx_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hr_icx_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_item_context_id              in     number
  ,p_id_flex_num                  in     number    default hr_api.g_number
  ,p_summary_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_segment1                     in     varchar2  default hr_api.g_varchar2
  ,p_segment2                     in     varchar2  default hr_api.g_varchar2
  ,p_segment3                     in     varchar2  default hr_api.g_varchar2
  ,p_segment4                     in     varchar2  default hr_api.g_varchar2
  ,p_segment5                     in     varchar2  default hr_api.g_varchar2
  ,p_segment6                     in     varchar2  default hr_api.g_varchar2
  ,p_segment7                     in     varchar2  default hr_api.g_varchar2
  ,p_segment8                     in     varchar2  default hr_api.g_varchar2
  ,p_segment9                     in     varchar2  default hr_api.g_varchar2
  ,p_segment10                    in     varchar2  default hr_api.g_varchar2
  ,p_segment11                    in     varchar2  default hr_api.g_varchar2
  ,p_segment12                    in     varchar2  default hr_api.g_varchar2
  ,p_segment13                    in     varchar2  default hr_api.g_varchar2
  ,p_segment14                    in     varchar2  default hr_api.g_varchar2
  ,p_segment15                    in     varchar2  default hr_api.g_varchar2
  ,p_segment16                    in     varchar2  default hr_api.g_varchar2
  ,p_segment17                    in     varchar2  default hr_api.g_varchar2
  ,p_segment18                    in     varchar2  default hr_api.g_varchar2
  ,p_segment19                    in     varchar2  default hr_api.g_varchar2
  ,p_segment20                    in     varchar2  default hr_api.g_varchar2
  ,p_segment21                    in     varchar2  default hr_api.g_varchar2
  ,p_segment22                    in     varchar2  default hr_api.g_varchar2
  ,p_segment23                    in     varchar2  default hr_api.g_varchar2
  ,p_segment24                    in     varchar2  default hr_api.g_varchar2
  ,p_segment25                    in     varchar2  default hr_api.g_varchar2
  ,p_segment26                    in     varchar2  default hr_api.g_varchar2
  ,p_segment27                    in     varchar2  default hr_api.g_varchar2
  ,p_segment28                    in     varchar2  default hr_api.g_varchar2
  ,p_segment29                    in     varchar2  default hr_api.g_varchar2
  ,p_segment30                    in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   hr_icx_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_icx_shd.convert_args
  (p_item_context_id
  ,p_object_version_number
  ,p_id_flex_num
  ,p_summary_flag
  ,p_enabled_flag
  ,p_start_date_active
  ,p_end_date_active
  ,p_segment1
  ,p_segment2
  ,p_segment3
  ,p_segment4
  ,p_segment5
  ,p_segment6
  ,p_segment7
  ,p_segment8
  ,p_segment9
  ,p_segment10
  ,p_segment11
  ,p_segment12
  ,p_segment13
  ,p_segment14
  ,p_segment15
  ,p_segment16
  ,p_segment17
  ,p_segment18
  ,p_segment19
  ,p_segment20
  ,p_segment21
  ,p_segment22
  ,p_segment23
  ,p_segment24
  ,p_segment25
  ,p_segment26
  ,p_segment27
  ,p_segment28
  ,p_segment29
  ,p_segment30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hr_icx_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end hr_icx_upd;

/
