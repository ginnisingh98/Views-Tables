--------------------------------------------------------
--  DDL for Package Body PER_QAT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QAT_INS" as
/* $Header: peqatrhi.pkb 120.0.12010000.2 2008/11/20 12:27:31 kgowripe ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_qat_ins.';  -- Global package name
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
  (p_rec in out nocopy per_qat_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Insert the row into: per_qualifications_tl
  --
  insert into per_qualifications_tl
      (qualification_id
      ,language
      ,source_lang
      ,title
      ,group_ranking
      ,license_restrictions
      ,awarding_body
      ,grade_attained
      ,reimbursement_arrangements
      ,training_completed_units
      ,membership_category
      )
  Values
    (p_rec.qualification_id
    ,p_rec.language
    ,p_rec.source_lang
    ,p_rec.title
    ,p_rec.group_ranking
    ,p_rec.license_restrictions
    ,p_rec.awarding_body
    ,p_rec.grade_attained
    ,p_rec.reimbursement_arrangements
    ,p_rec.training_completed_units
    ,p_rec.membership_category
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_qat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_qat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_qat_shd.constraint_error
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec                          in out nocopy per_qat_shd.g_rec_type
  ,p_qualification_id             in number
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_rec.qualification_id                 := p_qualification_id;
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
  (p_rec                          in per_qat_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_qat_rki.after_insert
      (p_qualification_id
      => p_rec.qualification_id
      ,p_language
      => p_rec.language
      ,p_source_lang
      => p_rec.source_lang
      ,p_title
      => p_rec.title
      ,p_group_ranking
      => p_rec.group_ranking
      ,p_license_restrictions
      => p_rec.license_restrictions
      ,p_awarding_body
      => p_rec.awarding_body
      ,p_grade_attained
      => p_rec.grade_attained
      ,p_reimbursement_arrangements
      => p_rec.reimbursement_arrangements
      ,p_training_completed_units
      => p_rec.training_completed_units
      ,p_membership_category
      => p_rec.membership_category
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_QUALIFICATIONS_TL'
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
  (p_rec                          in out nocopy per_qat_shd.g_rec_type
  ,p_qualification_id             in number
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Call the supporting insert validate operations
  --
  per_qat_bus.insert_validate
    (p_rec                         => p_rec
    ,p_qualification_id            => p_qualification_id
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  per_qat_ins.pre_insert
    (p_rec                         => p_rec
    ,p_qualification_id            => p_qualification_id
    );
  --
  -- Insert the row
  --
  per_qat_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_qat_ins.post_insert
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
  (p_qualification_id               in     number
  ,p_language                       in     varchar2
  ,p_source_lang                    in     varchar2
  ,p_title                          in     varchar2
  ,p_group_ranking                  in     varchar2
  ,p_license_restrictions           in     varchar2
  ,p_awarding_body                  in     varchar2
  ,p_grade_attained                 in     varchar2
  ,p_reimbursement_arrangements     in     varchar2
  ,p_training_completed_units       in     varchar2
  ,p_membership_category            in     varchar2
  ) is
--
  l_rec   per_qat_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_qat_shd.convert_args
    (null
    ,p_language
    ,p_source_lang
    ,p_title
    ,p_group_ranking
    ,p_license_restrictions
    ,p_awarding_body
    ,p_grade_attained
    ,p_reimbursement_arrangements
    ,p_training_completed_units
    ,p_membership_category
    );
  --
  -- Having converted the arguments into the per_qat_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_qat_ins.ins
     (p_rec                         => l_rec
     ,p_qualification_id            => p_qualification_id
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< ins_tl >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins_tl
  (p_language_code               in varchar2
  ,p_qualification_id             in number
  ,p_title                        in varchar2 default null
  ,p_group_ranking                in varchar2 default null
  ,p_license_restrictions         in varchar2 default null
  ,p_awarding_body                in varchar2 default null
  ,p_grade_attained               in varchar2 default null
  ,p_reimbursement_arrangements   in varchar2 default null
  ,p_training_completed_units     in varchar2 default null
  ,p_membership_category          in varchar2 default null
  ) is
  --
  -- Cursor to obtain the list of base and installed languages
  --
  cursor csr_ins_langs is
    select l.language_code
      from fnd_languages l
     where l.installed_flag in ('I','B')
       and not exists (select null
                         from per_qualifications_tl qat
                        where qat.qualification_id = p_qualification_id
                          and qat.language = l.language_code);
  --
  l_proc  varchar2(72)  := g_package || 'ins_tl';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Insert a row for the base language and every installed language.
  --
  for l_lang in csr_ins_langs loop
    per_qat_ins.ins
      (p_qualification_id            => p_qualification_id
      ,p_language                    => l_lang.language_code
      ,p_source_lang                 => p_language_code
      ,p_title                       => p_title
      ,p_group_ranking               => p_group_ranking
      ,p_license_restrictions        => p_license_restrictions
      ,p_awarding_body               => p_awarding_body
      ,p_grade_attained              => p_grade_attained
      ,p_reimbursement_arrangements  => p_reimbursement_arrangements
      ,p_training_completed_units    => p_training_completed_units
      ,p_membership_category         => p_membership_category
      );
  end loop;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
End ins_tl;
--
end per_qat_ins;

/
