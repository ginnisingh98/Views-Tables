--------------------------------------------------------
--  DDL for Package Body PER_ZA_EQT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_EQT_UPD" as
/* $Header: pezaequp.pkb 115.3 2002/12/05 06:36:07 nsugavan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_za_eqt_upd.';  -- Global package name
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy per_za_eqt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
  l_dummy number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  per_za_eqt_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_qualification_types Row
  --
  update per_qualification_types
  set
  qualification_type_id       = p_rec.qualification_type_id,
  name                        = p_rec.name,
  category                    = p_rec.category,
  rank                        = p_rec.rank,
  attribute_category          = p_rec.attribute_category,
  attribute1                  = p_rec.attribute1,
  attribute2                  = p_rec.attribute2,
  attribute3                  = p_rec.attribute3,
  attribute4                  = p_rec.attribute4,
  attribute5                  = p_rec.attribute5,
  attribute6                  = p_rec.attribute6,
  attribute7                  = p_rec.attribute7,
  attribute8                  = p_rec.attribute8,
  attribute9                  = p_rec.attribute9,
  attribute10                 = p_rec.attribute10,
  attribute11                 = p_rec.attribute11,
  attribute12                 = p_rec.attribute12,
  attribute13                 = p_rec.attribute13,
  attribute14                 = p_rec.attribute14,
  attribute15                 = p_rec.attribute15,
  attribute16                 = p_rec.attribute16,
  attribute17                 = p_rec.attribute17,
  attribute18                 = p_rec.attribute18,
  attribute19                 = p_rec.attribute19,
  attribute20                 = p_rec.attribute20,
  object_version_number       = p_rec.object_version_number
  where qualification_type_id = p_rec.qualification_type_id;

  begin
    select 1
	into l_dummy
	from per_za_qualification_types
    where qualification_type_id = p_rec.qualification_type_id;

	-- Record exists, can update.
    update per_za_qualification_types
    set nqf_qualification_type  = p_rec.nqf_qualification_type
    where qualification_type_id = p_rec.qualification_type_id;

  exception
    -- Record does not exists, must insert.
    when no_data_found then
	  insert into per_za_qualification_types(qualification_type_id,
	  		 	  							 nqf_qualification_type)
									  values(p_rec.qualification_type_id,
									  		 p_rec.nqf_qualification_type);
  end;

  --
  per_za_eqt_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_za_eqt_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_eqt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_za_eqt_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_eqt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_za_eqt_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_eqt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_za_eqt_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in per_za_eqt_shd.g_rec_type) is
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
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in per_za_eqt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy per_za_eqt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    per_za_eqt_shd.g_old_rec.name;
  End If;
  If (p_rec.nqf_qualification_type = hr_api.g_varchar2) then
    p_rec.nqf_qualification_type :=
    per_za_eqt_shd.g_old_rec.nqf_qualification_type;
  End If;
  If (p_rec.category = hr_api.g_varchar2) then
    p_rec.category :=
    per_za_eqt_shd.g_old_rec.category;
  End If;
  If (p_rec.rank = hr_api.g_number) then
    p_rec.rank :=
    per_za_eqt_shd.g_old_rec.rank;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_za_eqt_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_za_eqt_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_za_eqt_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_za_eqt_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_za_eqt_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_za_eqt_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_za_eqt_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_za_eqt_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_za_eqt_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_za_eqt_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_za_eqt_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_za_eqt_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_za_eqt_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_za_eqt_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_za_eqt_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_za_eqt_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_za_eqt_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_za_eqt_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_za_eqt_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_za_eqt_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_za_eqt_shd.g_old_rec.attribute20;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec            in out nocopy per_za_eqt_shd.g_rec_type,
  p_effective_date in     date,
  p_validate       in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
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
    SAVEPOINT upd_per_za_eqt;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  per_za_eqt_shd.lck
	(
	p_rec.qualification_type_id,
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
  per_za_eqt_bus.update_validate(p_rec,p_effective_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
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
    ROLLBACK TO upd_per_za_eqt;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_qualification_type_id  in number,
  p_nqf_qualification_type in varchar2         default hr_api.g_varchar2,
  p_name                   in varchar2         default hr_api.g_varchar2,
  p_category               in varchar2         default hr_api.g_varchar2,
  p_rank                   in number           default hr_api.g_number,
  p_attribute_category     in varchar2         default hr_api.g_varchar2,
  p_attribute1             in varchar2         default hr_api.g_varchar2,
  p_attribute2             in varchar2         default hr_api.g_varchar2,
  p_attribute3             in varchar2         default hr_api.g_varchar2,
  p_attribute4             in varchar2         default hr_api.g_varchar2,
  p_attribute5             in varchar2         default hr_api.g_varchar2,
  p_attribute6             in varchar2         default hr_api.g_varchar2,
  p_attribute7             in varchar2         default hr_api.g_varchar2,
  p_attribute8             in varchar2         default hr_api.g_varchar2,
  p_attribute9             in varchar2         default hr_api.g_varchar2,
  p_attribute10            in varchar2         default hr_api.g_varchar2,
  p_attribute11            in varchar2         default hr_api.g_varchar2,
  p_attribute12            in varchar2         default hr_api.g_varchar2,
  p_attribute13            in varchar2         default hr_api.g_varchar2,
  p_attribute14            in varchar2         default hr_api.g_varchar2,
  p_attribute15            in varchar2         default hr_api.g_varchar2,
  p_attribute16            in varchar2         default hr_api.g_varchar2,
  p_attribute17            in varchar2         default hr_api.g_varchar2,
  p_attribute18            in varchar2         default hr_api.g_varchar2,
  p_attribute19            in varchar2         default hr_api.g_varchar2,
  p_attribute20            in varchar2         default hr_api.g_varchar2,
  p_object_version_number  in out nocopy number,
  p_effective_date         in date,
  p_validate               in boolean      default false
  ) is
--
  l_rec	  per_za_eqt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_za_eqt_shd.convert_args
  (
  p_qualification_type_id,
  p_nqf_qualification_type,
  p_name,
  p_category,
  p_rank,
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
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_za_eqt_upd;

/
