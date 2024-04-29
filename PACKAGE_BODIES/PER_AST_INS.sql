--------------------------------------------------------
--  DDL for Package Body PER_AST_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_AST_INS" as
/* $Header: peastrhi.pkb 120.7.12010000.2 2008/10/20 14:11:39 kgowripe ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ast_ins.';  -- Global package name
--
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_assessment_type_id_i number default null;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_assessment_type_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_ast_ins.g_assessment_type_id_i := p_assessment_type_id;
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
Procedure insert_dml(p_rec in out nocopy per_ast_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: per_assessment_types
  --
  insert into per_assessment_types
  (	assessment_type_id,
	name,
	business_group_id,
	description,
	rating_scale_id,
	weighting_scale_id,
	rating_scale_comment,
	weighting_scale_comment,
	assessment_classification,
	display_assessment_comments,
	date_from,
        date_to,
	comments,
	instructions,
        weighting_classification,
        line_score_formula,
        total_score_formula,
	object_version_number,
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
    type,
    line_score_formula_id,
    default_job_competencies,
    available_flag
  )
  Values
  (	p_rec.assessment_type_id,
	p_rec.name,
	p_rec.business_group_id,
	p_rec.description,
	p_rec.rating_scale_id,
	p_rec.weighting_scale_id,
	p_rec.rating_scale_comment,
	p_rec.weighting_scale_comment,
	p_rec.assessment_classification,
	p_rec.display_assessment_comments,
	p_rec.date_from,
        p_rec.date_to,
	p_rec.comments,
	p_rec.instructions,
	p_rec.weighting_classification,
        p_rec.line_score_formula,
        p_rec.total_score_formula,
	p_rec.object_version_number,
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
    p_rec.type,
    p_rec.line_score_formula_id,
    p_rec.default_job_competencies,
    p_rec.available_flag
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    -- Bug#885806
    -- dbms_output.put_line('A check constraint has been violated insert-dml');
    hr_utility.trace('A check constraint has been violated insert-dml');
    -- dbms_output.put_line('p_rec.rating_scale_id is :'|| p_rec.rating_scale_id);
    hr_utility.trace('p_rec.rating_scale_id is :'|| p_rec.rating_scale_id);
    per_ast_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Bug#885806
    -- dbms_output.put_line('Parent integrity has been violated insert-dml');
    hr_utility.trace('Parent integrity has been violated insert-dml');
    -- Parent integrity has been violated
    per_ast_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Bug#885806
    -- dbms_output.put_line('Unique integrity has been violated insert-dml');
    hr_utility.trace('Unique integrity has been violated insert-dml');
    -- Unique integrity has been violated
    per_ast_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    -- Bug#885806
    -- dbms_output.put_line('Something else has been violated insert-dml');
    hr_utility.trace('Something else has been violated insert-dml');
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
Procedure pre_insert(p_rec  in out nocopy per_ast_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
Cursor C_Sel1 is select per_assessment_types_s.nextval from sys.dual;
Cursor C_Sel2 is
   select null from per_assessment_types
        where assessment_type_id  = per_ast_ins.g_assessment_type_id_i;

--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Select the next sequence number
  --
  if  ( per_ast_ins.g_assessment_type_id_i is not null ) then

   Open C_Sel2;
   Fetch C_Sel2 Into l_exists;
   if C_Sel2%Found then
      Close C_Sel2;
      --
      -- The primary key values are already in use.
      --
      fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
      fnd_message.set_token('TABLE_NAME','PER_ASSESSMENT_TYPES');
      fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.assessment_type_id  := per_ast_ins.g_assessment_type_id_i;
    per_ast_ins.g_assessment_type_id_i := null;

  Else
      Open C_Sel1;
      Fetch C_Sel1 Into p_rec.assessment_type_id;
      Close C_Sel1;
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End pre_insert;
--
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
Procedure post_insert(p_rec in per_ast_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     per_ast_rki.after_insert	(
      p_assessment_type_id          => p_rec.assessment_type_id          ,
      p_business_group_id           => p_rec.business_group_id           ,
      p_object_version_number       => p_rec.object_version_number       ,
      p_name                        => p_rec.name                        ,
      p_date_to                     => p_rec.date_to                     ,
      p_date_from                   => p_rec.date_from                   ,
      p_assessment_classification   => p_rec.assessment_classification   ,
      p_display_assessment_comments => p_rec.display_assessment_comments ,
      p_description                 => p_rec.description                 ,
      p_rating_scale_comment        => p_rec.rating_scale_comment        ,
      p_weighting_scale_comment     => p_rec.weighting_scale_comment     ,
      p_comments                    => p_rec.comments                    ,
      p_instructions                => p_rec.instructions                ,
      p_line_score_formula          => p_rec.line_score_formula          ,
      p_total_score_formula         => p_rec.total_score_formula         ,
      p_weighting_classification    => p_rec.weighting_classification    ,
      p_rating_scale_id             => p_rec.rating_scale_id             ,
      p_weighting_scale_id          => p_rec.weighting_scale_id          ,
      p_attribute_category          => p_rec.attribute_category          ,
      p_attribute1                  => p_rec.attribute1   ,
      p_attribute2                  => p_rec.attribute2   ,
      p_attribute3                  => p_rec.attribute3   ,
      p_attribute4                  => p_rec.attribute4   ,
      p_attribute5                  => p_rec.attribute5   ,
      p_attribute6                  => p_rec.attribute6   ,
      p_attribute7                  => p_rec.attribute7   ,
      p_attribute8                  => p_rec.attribute8   ,
      p_attribute9                  => p_rec.attribute9   ,
      p_attribute10                 => p_rec.attribute10  ,
      p_attribute11                 => p_rec.attribute11  ,
      p_attribute12                 => p_rec.attribute12  ,
      p_attribute13                 => p_rec.attribute13  ,
      p_attribute14                 => p_rec.attribute14  ,
      p_attribute15                 => p_rec.attribute15  ,
      p_attribute16                 => p_rec.attribute16  ,
      p_attribute17                 => p_rec.attribute17  ,
      p_attribute18                 => p_rec.attribute18  ,
      p_attribute19                 => p_rec.attribute19  ,
      p_attribute20                 => p_rec.attribute20  ,
      p_type                        => p_rec.type,
      p_line_score_formula_id       => p_rec.line_score_formula_id,
      p_default_job_competencies    => p_rec.default_job_competencies,
      p_available_flag              => p_rec.available_flag
      );
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	 p_module_name => 'PER_ASSESSMENT_TYPES'
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
  (p_rec        		in out nocopy per_ast_shd.g_rec_type
  ,p_validate   		in     boolean default false
  ,p_effective_date	in 	date
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
    SAVEPOINT ins_per_ast;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  hr_utility.set_location(' insert_validate called :'||l_proc, 11);
  per_ast_bus.insert_validate(p_rec
  			     ,p_effective_date);
  --
  hr_utility.set_location(' insert_validate finished :'||l_proc, 11);
  --
  -- Call the supporting pre-insert operation
  --
  -- Bug#885806
  -- dbms_output.put_line('about to do pre_insert');
  hr_utility.trace('about to do pre_insert');
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
    ROLLBACK TO ins_per_ast;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_assessment_type_id           out nocopy number,
  p_name                         in varchar2,
  p_business_group_id            in number           default null,
  p_description                  in varchar2         default null,
  p_rating_scale_id              in number           default null,
  p_weighting_scale_id           in number           default null,
  p_rating_scale_comment         in varchar2         default null,
  p_weighting_scale_comment      in varchar2         default null,
  p_assessment_classification    in varchar2,
  p_display_assessment_comments  in varchar2         default 'Y',
  p_date_from			 in date,
  p_date_to			 in date,
  p_comments                     in varchar2         default null,
  p_instructions                 in varchar2         default null,
  p_weighting_classification     in varchar2	     default null,
  p_line_score_formula           in varchar2         default null,
  p_total_score_formula          in varchar2         default null,
  p_object_version_number        out nocopy number,
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
  p_type                         in varchar2         default null,
  p_line_score_formula_id        in number           default null,
  p_default_job_competencies     in varchar2         default null,
  p_available_flag               in varchar2         default null,
  p_validate                     in boolean   default false,
  p_effective_date		 in date
  ) is
--
  l_rec	  per_ast_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_ast_shd.convert_args
  (
  null,
  p_name,
  p_business_group_id,
  p_description,
  p_rating_scale_id,
  p_weighting_scale_id,
  p_rating_scale_comment,
  p_weighting_scale_comment,
  p_assessment_classification,
  p_display_assessment_comments,
  p_date_from,
  p_date_to,
  p_comments,
  p_instructions,
  p_weighting_classification,
  p_line_score_formula,
  p_total_score_formula,
  null,
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
  p_type,
  p_line_score_formula_id,
  p_default_job_competencies,
  p_available_flag
  );
  --
  -- Having converted the arguments into the per_ast_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec
     ,p_validate
     ,p_effective_date);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_assessment_type_id := l_rec.assessment_type_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_ast_ins;

/
