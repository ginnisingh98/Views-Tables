--------------------------------------------------------
--  DDL for Package Body PER_DPF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DPF_INS" as
/* $Header: pedpfrhi.pkb 115.13 2002/12/05 10:20:52 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_dpf_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy per_dpf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_dpf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_deployment_factors
  --
  insert into per_deployment_factors
  (	deployment_factor_id,
	position_id,
	person_id,
	job_id,
	business_group_id,
	work_any_country,
	work_any_location,
	relocate_domestically,
	relocate_internationally,
	travel_required,
	country1,
	country2,
	country3,
	work_duration,
	work_schedule,
	work_hours,
	fte_capacity,
	visit_internationally,
	only_current_location,
	no_country1,
	no_country2,
	no_country3,
	comments,
	earliest_available_date,
	available_for_transfer,
	relocation_preference,
	relocation_required,
	passport_required,
	location1,
	location2,
	location3,
	other_requirements,
	service_minimum,
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
	attribute20
  )
  Values
  (	p_rec.deployment_factor_id,
	p_rec.position_id,
	p_rec.person_id,
	p_rec.job_id,
	p_rec.business_group_id,
	p_rec.work_any_country,
	p_rec.work_any_location,
	p_rec.relocate_domestically,
	p_rec.relocate_internationally,
	p_rec.travel_required,
	p_rec.country1,
	p_rec.country2,
	p_rec.country3,
	p_rec.work_duration,
	p_rec.work_schedule,
	p_rec.work_hours,
	p_rec.fte_capacity,
	p_rec.visit_internationally,
	p_rec.only_current_location,
	p_rec.no_country1,
	p_rec.no_country2,
	p_rec.no_country3,
	p_rec.comments,
	p_rec.earliest_available_date,
	p_rec.available_for_transfer,
	p_rec.relocation_preference,
	p_rec.relocation_required,
	p_rec.passport_required,
	p_rec.location1,
	p_rec.location2,
	p_rec.location3,
	p_rec.other_requirements,
	p_rec.service_minimum,
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
	p_rec.attribute20
  );
  --
  per_dpf_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_dpf_shd.g_api_dml := false;   -- Unset the api dml status
    per_dpf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_dpf_shd.g_api_dml := false;   -- Unset the api dml status
    per_dpf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_dpf_shd.g_api_dml := false;   -- Unset the api dml status
    per_dpf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_dpf_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy per_dpf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_deployment_factors_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.deployment_factor_id;
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
Procedure post_insert(p_rec in per_dpf_shd.g_rec_type, p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
 -- Start of API User Hook for post_insert.
  Begin
    per_dpf_rki.after_insert
      (
      p_deployment_factor_id              =>p_rec.deployment_factor_id,
      p_job_id                      	  =>p_rec.job_id,
      p_position_id                       =>p_rec.position_id,
      p_person_id                 	  =>p_rec.person_id,
      p_business_group_id           	  =>p_rec.business_group_id,
      p_work_any_country            	  =>p_rec.work_any_country,
      p_work_any_location           	  =>p_rec.work_any_location,
      p_relocate_domestically       	  =>p_rec.relocate_domestically,
      p_relocate_internationally    	  =>p_rec.relocate_internationally,
      p_travel_required                   =>p_rec.travel_required,
      p_country1                    	  =>p_rec.country1,
      p_country2                    	  =>p_rec.country2,
      p_country3                    	  =>p_rec.country3,
      p_work_duration               	  =>p_rec.work_duration,
      p_work_schedule               	  =>p_rec.work_schedule,
      p_work_hours                  	  =>p_rec.work_hours,
      p_fte_capacity  			  =>p_rec.fte_capacity,
      p_visit_internationally       	  =>p_rec.visit_internationally,
      p_only_current_location       	  =>p_rec.only_current_location,
      p_no_country1                 	  =>p_rec.no_country1,
      p_no_country2                 	  =>p_rec.no_country2,
      p_no_country3                 	  =>p_rec.no_country3,
      p_comments                    	  =>p_rec.comments,
      p_earliest_available_date     	  =>p_rec.earliest_available_date,
      p_available_for_transfer      	  =>p_rec.available_for_transfer,
      p_relocation_preference             =>p_rec.relocation_preference,
      p_relocation_required        	  =>p_rec.relocation_required,
      p_passport_required                 =>p_rec.passport_required,
      p_location1                         =>p_rec.location1,
      p_location2                    	  =>p_rec.location2,
      p_location3                  	  =>p_rec.location3,
      p_other_requirements        	  =>p_rec.other_requirements,
      p_service_minimum          	  =>p_rec.service_minimum,
      p_object_version_number   	  =>p_rec.object_version_number,
      p_effective_date                    =>p_effective_date,
      p_attribute_category    		  =>p_rec.attribute_category,
      p_attribute1                  	  =>p_rec.attribute1,
      p_attribute2                  	  =>p_rec.attribute2,
      p_attribute3                 	  =>p_rec.attribute3,
      p_attribute4                	  =>p_rec.attribute4,
      p_attribute5               	  =>p_rec.attribute5,
      p_attribute6              	  =>p_rec.attribute6,
      p_attribute7             		  =>p_rec.attribute7,
      p_attribute8            		  =>p_rec.attribute8,
      p_attribute9           		  =>p_rec.attribute9,
      p_attribute10         	 	  =>p_rec.attribute10,
      p_attribute11        		  =>p_rec.attribute11,
      p_attribute12                       =>p_rec.attribute12,
      p_attribute13                       =>p_rec.attribute13,
      p_attribute14                       =>p_rec.attribute14,
      p_attribute15                       =>p_rec.attribute15,
      p_attribute16                       =>p_rec.attribute16,
      p_attribute17                       =>p_rec.attribute17,
      p_attribute18                       =>p_rec.attribute18,
      p_attribute19                       =>p_rec.attribute19,
      p_attribute20                       =>p_rec.attribute20
      );
       exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
                 (       p_module_name => 'PER_DEPLOYMENT_FACTORS',
                         p_hook_type   => 'AI'
                 );
     end;
--   End of API User Hook for post_insert.
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy per_dpf_shd.g_rec_type,
  p_effective_date in date
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_dpf_bus.insert_validate(p_rec,p_effective_date);
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
  post_insert(p_rec, p_effective_date);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_deployment_factor_id         out nocopy number,
  p_position_id                  in number           ,
  p_person_id                    in number           ,
  p_job_id                       in number           ,
  p_business_group_id            in number,
  p_work_any_country             in varchar2,
  p_work_any_location            in varchar2,
  p_relocate_domestically        in varchar2,
  p_relocate_internationally     in varchar2,
  p_travel_required              in varchar2,
  p_country1                     in varchar2         ,
  p_country2                     in varchar2         ,
  p_country3                     in varchar2         ,
  p_work_duration                in varchar2         ,
  p_work_schedule                in varchar2         ,
  p_work_hours                   in varchar2         ,
  p_fte_capacity                 in varchar2         ,
  p_visit_internationally        in varchar2         ,
  p_only_current_location        in varchar2         ,
  p_no_country1                  in varchar2         ,
  p_no_country2                  in varchar2         ,
  p_no_country3                  in varchar2         ,
  p_comments                     in varchar2         ,
  p_earliest_available_date      in date             ,
  p_available_for_transfer       in varchar2         ,
  p_relocation_preference        in varchar2         ,
  p_relocation_required          in varchar2         ,
  p_passport_required            in varchar2         ,
  p_location1                    in varchar2         ,
  p_location2                    in varchar2         ,
  p_location3                    in varchar2         ,
  p_other_requirements           in varchar2         ,
  p_service_minimum              in varchar2         ,
  p_object_version_number        out nocopy number,
  p_effective_date               in date,
  p_attribute_category           in varchar2         ,
  p_attribute1                   in varchar2         ,
  p_attribute2                   in varchar2         ,
  p_attribute3                   in varchar2         ,
  p_attribute4                   in varchar2         ,
  p_attribute5                   in varchar2         ,
  p_attribute6                   in varchar2         ,
  p_attribute7                   in varchar2         ,
  p_attribute8                   in varchar2         ,
  p_attribute9                   in varchar2         ,
  p_attribute10                  in varchar2         ,
  p_attribute11                  in varchar2         ,
  p_attribute12                  in varchar2         ,
  p_attribute13                  in varchar2         ,
  p_attribute14                  in varchar2         ,
  p_attribute15                  in varchar2         ,
  p_attribute16                  in varchar2         ,
  p_attribute17                  in varchar2         ,
  p_attribute18                  in varchar2         ,
  p_attribute19                  in varchar2         ,
  p_attribute20                  in varchar2         ) is
--
  l_rec	  per_dpf_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_dpf_shd.convert_args
  (
  null,
  p_position_id,
  p_person_id,
  p_job_id,
  p_business_group_id,
  p_work_any_country,
  p_work_any_location,
  p_relocate_domestically,
  p_relocate_internationally,
  p_travel_required,
  p_country1,
  p_country2,
  p_country3,
  p_work_duration,
  p_work_schedule,
  p_work_hours,
  p_fte_capacity,
  p_visit_internationally,
  p_only_current_location,
  p_no_country1,
  p_no_country2,
  p_no_country3,
  p_comments,
  p_earliest_available_date,
  p_available_for_transfer,
  p_relocation_preference,
  p_relocation_required,
  p_passport_required,
  p_location1,
  p_location2,
  p_location3,
  p_other_requirements,
  p_service_minimum,
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
  p_attribute20
  );
  --
  -- Having converted the arguments into the per_dpf_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec,p_effective_date);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_deployment_factor_id := l_rec.deployment_factor_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_dpf_ins;

/
