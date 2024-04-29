--------------------------------------------------------
--  DDL for Package Body PER_OBJ_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_OBJ_INS" as
/* $Header: peobjrhi.pkb 120.16.12010000.4 2008/11/05 05:52:10 rvagvala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_obj_ins.';  -- Global package name
--
g_objective_id_i number default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure set_base_key_value
  (p_objective_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_obj_ins.g_objective_id_i := p_objective_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
--
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
--   2) To insert the row into the schema.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy per_obj_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  -- Insert the row into: per_objectives
  --
  insert into per_objectives
  (	objective_id,
	name,
	target_date,
	start_date,
	business_group_id,
	object_version_number,
	owning_person_id,
	achievement_date,
	detail,
	comments,
	success_criteria,
	appraisal_id,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,

	attribute21,
	attribute22,
	attribute23,
	attribute24,
	attribute25,
	attribute26,
	attribute27,
	attribute28,
	attribute29,
	attribute30,

        scorecard_id,
        copied_from_library_id,
        copied_from_objective_id,
        aligned_with_objective_id,

        next_review_date,
        group_code,
        priority_code,
        appraise_flag,
        verified_flag,

        target_value,
        actual_value,
        weighting_percent,
        complete_percent,
        uom_code,

        measurement_style_code,
        measure_name,
        measure_type_code,
        measure_comments ,
        sharing_access_code

  )
  Values
  (	p_rec.objective_id,
	p_rec.name,
	p_rec.target_date,
	p_rec.start_date,
	p_rec.business_group_id,
	p_rec.object_version_number,
	p_rec.owning_person_id,
	p_rec.achievement_date,
	p_rec.detail,
	p_rec.comments,
	p_rec.success_criteria,
	p_rec.appraisal_id,
	p_rec.attribute_category,
	p_rec.attribute1,
	p_rec.attribute2,
	p_rec.attribute3,
	p_rec.attribute4,
	p_rec.attribute5,
	p_rec.attribute6,
	p_rec.attribute7,
	p_rec.attribute8,
	p_rec.attribute9,
	p_rec.attribute10,
	p_rec.attribute11,
	p_rec.attribute12,
	p_rec.attribute13,
	p_rec.attribute14,
	p_rec.attribute15,
	p_rec.attribute16,
	p_rec.attribute17,
	p_rec.attribute18,
	p_rec.attribute19,
	p_rec.attribute20,

	p_rec.attribute21,
	p_rec.attribute22,
	p_rec.attribute23,
	p_rec.attribute24,
	p_rec.attribute25,
	p_rec.attribute26,
	p_rec.attribute27,
	p_rec.attribute28,
	p_rec.attribute29,
	p_rec.attribute30,

        p_rec.scorecard_id,
        p_rec.copied_from_library_id,
        p_rec.copied_from_objective_id,
        p_rec.aligned_with_objective_id,

        p_rec.next_review_date,
        p_rec.group_code,
        p_rec.priority_code,
        p_rec.appraise_flag,
        p_rec.verified_flag,

        p_rec.target_value,
        p_rec.actual_value,
        p_rec.weighting_percent,
        p_rec.complete_percent,
        p_rec.uom_code,

        p_rec.measurement_style_code,
        p_rec.measure_name,
        p_rec.measure_type_code,
        p_rec.measure_comments ,
        p_rec.sharing_access_code

  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_obj_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_obj_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_obj_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_insert(p_rec  in out nocopy per_obj_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
  Cursor C_Sel1 is select per_objectives_s.nextval from sys.dual;
--
--
  Cursor C_Sel2 is
    Select null
      from per_objectives
     where objective_id =
             per_obj_ins.g_objective_id_i;
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
    IF (per_obj_ins.g_objective_id_i is not null)
    then
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
        fnd_message.set_token('TABLE_NAME','PER_OBJECTIVES');
        fnd_message.raise_error;
      End If;
      Close C_Sel2;
      --
      -- Use registered key values and clear globals
      --
        p_rec.objective_id := per_obj_ins.g_objective_id_i;
        per_obj_ins.g_objective_id_i := null;
    Else

  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.objective_id;
  Close C_Sel1;

  END IF;
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
Procedure post_insert
     (p_rec              in per_obj_shd.g_rec_type,
      p_effective_date   in date,
      p_weighting_over_100_warning   out nocopy boolean,
      p_weighting_appraisal_warning  out nocopy boolean
) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_insert.
  begin
    per_obj_rki.after_insert
      (
       p_objective_id                  => p_rec.objective_id,
       p_name                          => p_rec.name,
       p_target_date                   => p_rec.target_date,
       p_start_date                    => p_rec.start_date,
       p_business_group_id             => p_rec.business_group_id,
       p_object_version_number         => p_rec.object_version_number,
       p_owning_person_id              => p_rec.owning_person_id,
       p_achievement_date              => p_rec.achievement_date,
       p_detail                        => p_rec.detail,
       p_comments                      => p_rec.comments,
       p_success_criteria              => p_rec.success_criteria,
       p_appraisal_id                  => p_rec.appraisal_id,
       p_attribute_category            => p_rec.attribute_category,
       p_attribute1                    => p_rec.attribute1,
       p_attribute2                    => p_rec.attribute2,
       p_attribute3                    => p_rec.attribute3,
       p_attribute4                    => p_rec.attribute4,
       p_attribute5                    => p_rec.attribute5,
       p_attribute6                    => p_rec.attribute6,
       p_attribute7                    => p_rec.attribute7,
       p_attribute8                    => p_rec.attribute8,
       p_attribute9                    => p_rec.attribute9,
       p_attribute10                   => p_rec.attribute10,
       p_attribute11                   => p_rec.attribute11,
       p_attribute12                   => p_rec.attribute12,
       p_attribute13                   => p_rec.attribute13,
       p_attribute14                   => p_rec.attribute14,
       p_attribute15                   => p_rec.attribute15,
       p_attribute16                   => p_rec.attribute16,
       p_attribute17                   => p_rec.attribute17,
       p_attribute18                   => p_rec.attribute18,
       p_attribute19                   => p_rec.attribute19,
       p_attribute20                   => p_rec.attribute20,

       p_attribute21                   => p_rec.attribute21,
       p_attribute22                   => p_rec.attribute22,
       p_attribute23                   => p_rec.attribute23,
       p_attribute24                   => p_rec.attribute24,
       p_attribute25                   => p_rec.attribute25,
       p_attribute26                   => p_rec.attribute26,
       p_attribute27                   => p_rec.attribute27,
       p_attribute28                   => p_rec.attribute28,
       p_attribute29                   => p_rec.attribute29,
       p_attribute30                   => p_rec.attribute30,

       p_scorecard_id	  	        => p_rec.scorecard_id,
       p_copied_from_library_id		=> p_rec.copied_from_library_id,
       p_copied_from_objective_id	=> p_rec.copied_from_objective_id,
       p_aligned_with_objective_id	=> p_rec.aligned_with_objective_id,

       p_next_review_date		=> p_rec.next_review_date,
       p_group_code			=> p_rec.group_code,
       p_priority_code			=> p_rec.priority_code,
       p_appraise_flag			=> p_rec.appraise_flag,
       p_verified_flag			=> p_rec.verified_flag,

       p_target_value			=> p_rec.target_value,
       p_actual_value			=> p_rec.actual_value,
       p_weighting_percent		=> p_rec.weighting_percent,
       p_complete_percent		=> p_rec.complete_percent,
       p_uom_code			=> p_rec.uom_code,

       p_measurement_style_code		=> p_rec.measurement_style_code,
       p_measure_name			=> p_rec.measure_name,
       p_measure_type_code		=> p_rec.measure_type_code,
       p_measure_comments 		=> p_rec.measure_comments ,
       p_sharing_access_code		=> p_rec.sharing_access_code,

       p_weighting_over_100_warning    => p_weighting_over_100_warning,
       p_weighting_appraisal_warning   => p_weighting_appraisal_warning,

       p_effective_date	               => p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_OBJECTIVES'
        ,p_hook_type   => 'AI'
        );
  end;
  -- End of API User Hook for post_insert.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        		in out nocopy per_obj_shd.g_rec_type,
  p_effective_date	in date,
  p_validate   		in     boolean default false,
  p_weighting_over_100_warning      out nocopy boolean,
  p_weighting_appraisal_warning     out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
  l_effective_date        date;
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
    SAVEPOINT ins_per_obj;
  End If;

 --- begin--  bug fix  6027219---
 If(p_rec.scorecard_id IS NOT NULL AND p_rec.appraisal_id IS NOT NULL)
  THEN
  p_rec.appraise_flag:='Y';
 END IF;

 --- end--  bug fix 6027219 ---

  --
  -- Call the supporting insert validate operations
  --
  per_obj_bus.insert_validate
         (p_rec
         ,p_effective_date
         ,p_weighting_over_100_warning
         ,p_weighting_appraisal_warning
         );

  --
        hr_multi_message.end_validation_set;
  --

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
  post_insert(p_rec
             , p_effective_date
             , p_weighting_over_100_warning
             , p_weighting_appraisal_warning
             );

  --
        hr_multi_message.end_validation_set;
  --

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
    ROLLBACK TO ins_per_obj;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_objective_id                 out nocopy number,
  p_name                         in varchar2,
  p_target_date                  in date             default null,
  p_start_date                   in date,
  p_business_group_id            in number,
  p_object_version_number        out nocopy number,
  p_owning_person_id             in number,
  p_achievement_date             in date             default null,
  p_detail                       in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_success_criteria             in varchar2         default null,
  p_appraisal_id                 in number           default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,

   p_attribute21                  in varchar2         default null,
   p_attribute22                  in varchar2         default null,
   p_attribute23                  in varchar2         default null,
   p_attribute24                  in varchar2         default null,
   p_attribute25                  in varchar2         default null,
   p_attribute26                  in varchar2         default null,
   p_attribute27                  in varchar2         default null,
   p_attribute28                  in varchar2         default null,
   p_attribute29                  in varchar2         default null,
   p_attribute30                  in varchar2         default null,

   p_scorecard_id                 in number           default null,
   p_copied_from_library_id       in number           default null,
   p_copied_from_objective_id     in number           default null,
   p_aligned_with_objective_id    in number           default null,

   p_next_review_date             in date             default null,
   p_group_code                   in varchar2         default null,
   p_priority_code                in varchar2         default null,
   p_appraise_flag                in varchar2         default null,
   p_verified_flag                in varchar2         default null,

   p_target_value                 in number           default null,
   p_actual_value                 in number           default null,
   p_weighting_percent            in number           default null,
   p_complete_percent             in number           default null,
   p_uom_code                     in varchar2         default null,

   p_measurement_style_code       in varchar2         default null,
   p_measure_name                 in varchar2         default null,
   p_measure_type_code            in varchar2         default null,
   p_measure_comments             in varchar2         default null,
   p_sharing_access_code          in varchar2         default null,

  p_weighting_over_100_warning   out nocopy boolean,
  p_weighting_appraisal_warning  out nocopy boolean,

  p_effective_date		 in date,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  per_obj_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
  l_weighting_over_100_warning   boolean;
  l_weighting_appraisal_warning  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_obj_shd.convert_args
  (
  null,
  p_name,
  p_target_date,
  p_start_date,
  p_business_group_id,
  null,
  p_owning_person_id,
  p_achievement_date,
  p_detail,
  p_comments,
  p_success_criteria,
  p_appraisal_id,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20,

  p_attribute21,
  p_attribute22,
  p_attribute23,
  p_attribute24,
  p_attribute25,
  p_attribute26,
  p_attribute27,
  p_attribute28,
  p_attribute29,
  p_attribute30,

  p_scorecard_id,
  p_copied_from_library_id,
  p_copied_from_objective_id,
  p_aligned_with_objective_id,

  p_next_review_date,
  p_group_code,
  p_priority_code,
  p_appraise_flag,
  p_verified_flag,

  p_target_value,
  p_actual_value,
  p_weighting_percent,
  p_complete_percent,
  p_uom_code,

  p_measurement_style_code,
  p_measure_name,
  p_measure_type_code,
  p_measure_comments ,
  p_sharing_access_code

  );
  --
  -- Having converted the arguments into the per_obj_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec,
      p_effective_date,
      p_validate,
      l_weighting_over_100_warning,
      l_weighting_appraisal_warning
);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_objective_id := l_rec.objective_id;
  p_object_version_number := l_rec.object_version_number;

  p_weighting_over_100_warning  := l_weighting_over_100_warning;
  p_weighting_appraisal_warning := l_weighting_appraisal_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_obj_ins;

/
