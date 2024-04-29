--------------------------------------------------------
--  DDL for Package Body PER_RVR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RVR_INS" as
/* $Header: pervrrhi.pkb 120.5 2006/06/12 23:57:11 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rvr_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_workbench_view_report_code_i  per_ri_view_reports.workbench_view_report_code%Type   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_workbench_view_report_code  in  Varchar2) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_rvr_ins.g_workbench_view_report_code_i := p_workbench_view_report_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec in out nocopy per_rvr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: per_ri_view_reports
  --
  insert into per_ri_view_reports
      (workbench_item_code
      ,workbench_view_report_code
      ,workbench_view_report_type
      ,workbench_view_report_action
      ,workbench_view_country
      ,wb_view_report_instruction
      ,object_version_number
      ,primary_industry
      ,enabled_flag
      )
  Values
    (p_rec.workbench_item_code
    ,p_rec.workbench_view_report_code
    ,p_rec.workbench_view_report_type
    ,p_rec.workbench_view_report_action
    ,p_rec.workbench_view_country
    ,p_rec.wb_view_report_instruction
    ,p_rec.object_version_number
    ,p_rec.primary_industry
    ,p_rec.enabled_flag
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_rvr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_rvr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_rvr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec  in out nocopy per_rvr_shd.g_rec_type
  ) is

--
  Cursor C_Sel2 is
    Select null
      from per_ri_view_reports
     where workbench_view_report_code =
             per_rvr_ins.g_workbench_view_report_code_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (per_rvr_ins.g_workbench_view_report_code_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','per_ri_view_reports');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.workbench_view_report_code :=
      per_rvr_ins.g_workbench_view_report_code_i;
    per_rvr_ins.g_workbench_view_report_code_i := null;
  Else

    -- No registerd key values, so raise error
    --
    hr_utility.set_message(801, 'HR_7207_API_MANDATORY_ARG');
    hr_utility.set_message_token('API_NAME', g_package);
    hr_utility.set_message_token('ARGUMENT', 'workbench_item_code');
    hr_utility.raise_error;

  End If;
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
--   This private procedure contains any processing which is required after
--   the insert dml.
--
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_rec                          in per_rvr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_rvr_rki.after_insert
      (p_workbench_item_code           => p_rec.workbench_item_code
      ,p_workbench_view_report_code    => p_rec.workbench_view_report_code
      ,p_workbench_view_report_type    => p_rec.workbench_view_report_type
      ,p_workbench_view_report_action  => p_rec.workbench_view_report_action
      ,p_workbench_view_country        => p_rec.workbench_view_country
      ,p_wb_view_report_instruction    => p_rec.wb_view_report_instruction
      ,p_object_version_number         => p_rec.object_version_number
      ,p_primary_industry	           => p_rec.primary_industry
      ,p_enabled_flag                  => p_rec.enabled_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_RI_VIEW_REPORTS'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec                          in out nocopy per_rvr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_rvr_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  per_rvr_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_rvr_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_rvr_ins.post_insert
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_workbench_item_code            in     varchar2
  ,p_workbench_view_report_type     in     varchar2 default null
  ,p_workbench_view_report_action   in     varchar2 default null
  ,p_workbench_view_country         in     varchar2 default null
  ,p_wb_view_report_instruction     in     varchar2 default null
  ,p_workbench_view_report_code     In     varchar2
  ,p_object_version_number             out nocopy number
  ,p_primary_industry		        in	   varchar2 default null
  ,p_enabled_flag                   in     varchar2 default null
  ) is
--
  l_rec   per_rvr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_rvr_shd.convert_args
    (p_workbench_item_code
    ,null
    ,p_workbench_view_report_type
    ,p_workbench_view_report_action
    ,p_workbench_view_country
    ,p_wb_view_report_instruction
    ,null
    ,p_primary_industry
    ,p_enabled_flag
    );
  --
  -- Having converted the arguments into the per_rvr_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_rvr_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
   p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_rvr_ins;

/
