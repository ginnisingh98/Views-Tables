--------------------------------------------------------
--  DDL for Package Body GHR_PDI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDI_INS" as
/* $Header: ghpdirhi.pkb 120.1 2005/06/13 12:28:25 vravikan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pdi_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ghr_pdi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --ghr_pdi_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ghr_position_descriptions
  --
  insert into ghr_position_descriptions
  (	position_description_id,
	routing_group_id,
	date_from,
	date_to,
	opm_cert_num,
	flsa,
	financial_statement,
	subject_to_ia_action,
	position_status,
	position_is,
	position_sensitivity,
	competitive_level,
	pd_remarks,
	position_class_std,
	category,
	career_ladder,
        supervisor_name,
  	supervisor_title,
  	supervisor_date,
  	manager_name,
  	manager_title,
  	manager_date,
  	classifier_name,
  	classifier_title,
  	classifier_date,
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
        business_group_id,
	object_version_number
  )
  Values
  (	p_rec.position_description_id,
	p_rec.routing_group_id,
	p_rec.date_from,
	p_rec.date_to,
	p_rec.opm_cert_num,
	p_rec.flsa,
	p_rec.financial_statement,
	p_rec.subject_to_ia_action,
	p_rec.position_status,
	p_rec.position_is,
	p_rec.position_sensitivity,
	p_rec.competitive_level,
	p_rec.pd_remarks,
	p_rec.position_class_std,
	p_rec.category,
	p_rec.career_ladder,
        p_rec.supervisor_name,
  	p_rec.supervisor_title,
  	p_rec.supervisor_date,
  	p_rec.manager_name,
  	p_rec.manager_title,
  	p_rec.manager_date,
  	p_rec.classifier_name,
  	p_rec.classifier_title,
  	p_rec.classifier_date,
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
        p_rec.business_group_id,
	p_rec.object_version_number
  );
  --
  --ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ghr_pdi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ghr_position_descriptions_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.position_description_id;
  Close C_Sel1;
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
Procedure post_insert(p_rec in ghr_pdi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     ghr_pdi_rki.after_insert	(
      p_position_description_id => p_rec.position_description_id,
      p_classifier_date         => p_rec.classifier_date,
--      p_pa_request_id           => p_rec.pa_request_id,
      p_attribute_category      => p_rec.attribute_category,
      p_routing_group_id        => p_rec.routing_group_id,
      p_date_from               => p_rec.date_from,
      p_date_to                 => p_rec.date_to,
      p_opm_cert_num            => p_rec.opm_cert_num,
      p_flsa                    => p_rec.flsa,
      p_financial_statement     => p_rec.financial_statement,
      p_subject_to_ia_action    => p_rec.subject_to_ia_action,
      p_position_status         => p_rec.position_status,
      p_position_is             => p_rec.position_is,
      p_position_sensitivity    => p_rec.position_sensitivity,
      p_competitive_level       => p_rec.competitive_level,
      p_pd_remarks              => p_rec.pd_remarks,
      p_position_class_std      => p_rec.position_class_std,
      p_category                => p_rec.category,
      p_career_ladder           => p_rec.career_ladder,
      p_supervisor_name         => p_rec.supervisor_name,
      p_supervisor_title        => p_rec.supervisor_title,
      p_supervisor_date         => p_rec.supervisor_date,
      p_manager_name            => p_rec.manager_name,
      p_manager_title           => p_rec.manager_title,
      p_manager_date            => p_rec.manager_date,
      p_classifier_name         => p_rec.classifier_name,
      p_classifier_title        => p_rec.classifier_title,
      p_attribute1              => p_rec.attribute1,
      p_attribute2              => p_rec.attribute2,
      p_attribute3              => p_rec.attribute3,
      p_attribute4              => p_rec.attribute4,
      p_attribute5              => p_rec.attribute5,
      p_attribute6              => p_rec.attribute6,
      p_attribute7              => p_rec.attribute7,
      p_attribute8              => p_rec.attribute8,
      p_attribute9              => p_rec.attribute9,
      p_attribute10             => p_rec.attribute10,
      p_attribute11             => p_rec.attribute11,
      p_attribute12             => p_rec.attribute12,
      p_attribute13             => p_rec.attribute13,
      p_attribute14             => p_rec.attribute14,
      p_attribute15             => p_rec.attribute15,
      p_attribute16             => p_rec.attribute16,
      p_attribute17             => p_rec.attribute17,
      p_attribute18             => p_rec.attribute18,
      p_attribute19             => p_rec.attribute19,
      p_attribute20             => p_rec.attribute20,
      p_business_group_id       => p_rec.business_group_id,
      p_object_version_number   => p_rec.object_version_number
      );
  exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	 p_module_name => 'GHR_POSITION_DESCRIPTIONS'
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
  p_rec        in out nocopy ghr_pdi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ghr_pdi_bus.insert_validate(p_rec);
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
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_position_description_id      out nocopy number,
  p_routing_group_id             in number           default null,
  p_date_from                    in date,
  p_date_to                      in date             default null,
  p_opm_cert_num                 in varchar2         default null,
  p_flsa                         in varchar2         default null,
  p_financial_statement          in varchar2         default null,
  p_subject_to_ia_action         in varchar2         default null,
  p_position_status              in number           default null,
  p_position_is                  in varchar2         default null,
  p_position_sensitivity         in varchar2         default null,
  p_competitive_level            in varchar2         default null,
  p_pd_remarks                   in varchar2         default null,
  p_position_class_std           in varchar2         default null,
  p_category                     in varchar2         default null,
  p_career_ladder                in varchar2         default null,
  p_supervisor_name		 in varchar2         default null,
  p_supervisor_title 		 in varchar2         default null,
  p_supervisor_date              in date             default null,
  p_manager_name		 in varchar2         default null,
  p_manager_title 		 in varchar2         default null,
  p_manager_date                 in date             default null,
  p_classifier_name		 in varchar2         default null,
  p_classifier_title 		 in varchar2         default null,
  p_classifier_date              in date             default null,
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
  p_business_group_id            in number           default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ghr_pdi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ghr_pdi_shd.convert_args
  (
  null,
  p_routing_group_id,
  p_date_from,
  p_date_to,
  p_opm_cert_num,
  p_flsa,
  p_financial_statement,
  p_subject_to_ia_action,
  p_position_status,
  p_position_is,
  p_position_sensitivity,
  p_competitive_level,
  p_pd_remarks,
  p_position_class_std,
  p_category,
  p_career_ladder,
  p_supervisor_name,
  p_supervisor_title,
  p_supervisor_date,
  p_manager_name,
  p_manager_title,
  p_manager_date,
  p_classifier_name,
  p_classifier_title,
  p_classifier_date,
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
  p_business_group_id,
  null
  );
  --
  -- Having converted the arguments into the ghr_pdi_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_position_description_id := l_rec.position_description_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ghr_pdi_ins;

/
