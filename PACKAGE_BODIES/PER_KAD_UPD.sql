--------------------------------------------------------
--  DDL for Package Body PER_KAD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KAD_UPD" as
/* $Header: pekadrhi.pkb 115.6 2002/12/06 11:27:37 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_kad_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
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
-- In Arguments:
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
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy per_kad_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
hr_utility.set_location(l_proc, 6);
  per_kad_shd.g_api_dml := true;  -- Set the api dml status
  --
hr_utility.set_location(l_proc, 7);
  -- Update the per_addresses Row
  --
  update per_addresses
  set
  address_id                        = p_rec.address_id,
-- 70.2 change a start.
  date_from                         = p_rec.date_from,
-- 70.2 change a end.
  address_line1                     = p_rec.address_line1,
  address_line2                     = p_rec.address_line2,
  address_line3                     = p_rec.address_line3,
  address_type                      = p_rec.address_type,
  comments                          = p_rec.comments,
  country                           = p_rec.country,
  date_to                           = p_rec.date_to,
  postal_code                       = p_rec.postal_code,
  region_1                          = p_rec.region_1,
  region_2                          = p_rec.region_2,
  region_3                          = p_rec.region_3,
  telephone_number_1                = p_rec.telephone_number_1,
  telephone_number_2                = p_rec.telephone_number_2,
  telephone_number_3                = p_rec.telephone_number_3,
  town_or_city                      = p_rec.town_or_city,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  addr_attribute_category           = p_rec.addr_attribute_category,
  addr_attribute1                   = p_rec.addr_attribute1,
  addr_attribute2                   = p_rec.addr_attribute2,
  addr_attribute3                   = p_rec.addr_attribute3,
  addr_attribute4                   = p_rec.addr_attribute4,
  addr_attribute5                   = p_rec.addr_attribute5,
  addr_attribute6                   = p_rec.addr_attribute6,
  addr_attribute7                   = p_rec.addr_attribute7,
  addr_attribute8                   = p_rec.addr_attribute8,
  addr_attribute9                   = p_rec.addr_attribute9,
  addr_attribute10                  = p_rec.addr_attribute10,
  addr_attribute11                  = p_rec.addr_attribute11,
  addr_attribute12                  = p_rec.addr_attribute12,
  addr_attribute13                  = p_rec.addr_attribute13,
  addr_attribute14                  = p_rec.addr_attribute14,
  addr_attribute15                  = p_rec.addr_attribute15,
  addr_attribute16                  = p_rec.addr_attribute16,
  addr_attribute17                  = p_rec.addr_attribute17,
  addr_attribute18                  = p_rec.addr_attribute18,
  addr_attribute19                  = p_rec.addr_attribute19,
  addr_attribute20                  = p_rec.addr_attribute20,
  object_version_number             = p_rec.object_version_number
  where address_id = p_rec.address_id;
  --
hr_utility.set_location(l_proc, 8);
  per_kad_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_kad_shd.g_api_dml := false;   -- Unset the api dml status
    per_kad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_kad_shd.g_api_dml := false;   -- Unset the api dml status
    per_kad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_kad_shd.g_api_dml := false;   -- Unset the api dml status
    per_kad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_kad_shd.g_api_dml := false;   -- Unset the api dml status
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in per_kad_shd.g_rec_type) is
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec            in per_kad_shd.g_rec_type,
                      p_effective_date in date) is
  --
  l_proc  varchar2(72) := g_package||'post_update';
  --
  -- Fix for WWBUG 1408379
  --
  l_old               ben_add_ler.g_add_ler_rec;
  l_new               ben_add_ler.g_add_ler_rec;
  --
  -- End of Fix for WWBUG 1408379
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Fix for WWBUG 1408379
  --
  l_old.person_id := per_kad_shd.g_old_rec.person_id;
  l_old.business_group_id := per_kad_shd.g_old_rec.business_group_id;
  l_old.date_from := per_kad_shd.g_old_rec.date_from;
  l_old.date_to := per_kad_shd.g_old_rec.date_to;
  l_old.primary_flag := per_kad_shd.g_old_rec.primary_flag;
  l_old.postal_code := per_kad_shd.g_old_rec.postal_code;
  l_old.region_2 := per_kad_shd.g_old_rec.region_2;
  l_old.address_type := per_kad_shd.g_old_rec.address_type;
  l_old.address_id := per_kad_shd.g_old_rec.address_id;
  l_new.person_id := p_rec.person_id;
  l_new.business_group_id := p_rec.business_group_id;
  l_new.date_from := p_rec.date_from;
  l_new.date_to := p_rec.date_to;
  l_new.primary_flag := p_rec.primary_flag;
  l_new.postal_code := p_rec.postal_code;
  l_new.region_2 := p_rec.region_2;
  l_new.address_type := p_rec.address_type;
  l_new.address_id := p_rec.address_id;
  --
  ben_add_ler.ler_chk(p_old            => l_old,
                      p_new            => l_new,
                      p_effective_date => l_new.date_from);
  --
  -- End of Fix for WWBUG 1408379
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
--   The Convert_Defs function has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
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
Function convert_defs(p_rec in out nocopy per_kad_shd.g_rec_type)
         Return per_kad_shd.g_rec_type is
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
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_kad_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_kad_shd.g_old_rec.person_id;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    per_kad_shd.g_old_rec.date_from;
  End If;
  If (p_rec.primary_flag = hr_api.g_varchar2) then
    p_rec.primary_flag :=
    per_kad_shd.g_old_rec.primary_flag;
  End If;
  If (p_rec.style = hr_api.g_varchar2) then
    p_rec.style :=
    per_kad_shd.g_old_rec.style;
  End If;
  If (p_rec.address_line1 = hr_api.g_varchar2) then
    p_rec.address_line1 :=
    per_kad_shd.g_old_rec.address_line1;
  End If;
  If (p_rec.address_line2 = hr_api.g_varchar2) then
    p_rec.address_line2 :=
    per_kad_shd.g_old_rec.address_line2;
  End If;
  If (p_rec.address_line3 = hr_api.g_varchar2) then
    p_rec.address_line3 :=
    per_kad_shd.g_old_rec.address_line3;
  End If;
  If (p_rec.address_type = hr_api.g_varchar2) then
    p_rec.address_type :=
    per_kad_shd.g_old_rec.address_type;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_kad_shd.g_old_rec.comments;
  End If;
  If (p_rec.country = hr_api.g_varchar2) then
    p_rec.country :=
    per_kad_shd.g_old_rec.country;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    per_kad_shd.g_old_rec.date_to;
  End If;
  If (p_rec.postal_code = hr_api.g_varchar2) then
    p_rec.postal_code :=
    per_kad_shd.g_old_rec.postal_code;
  End If;
  If (p_rec.region_1 = hr_api.g_varchar2) then
    p_rec.region_1 :=
    per_kad_shd.g_old_rec.region_1;
  End If;
  If (p_rec.region_2 = hr_api.g_varchar2) then
    p_rec.region_2 :=
    per_kad_shd.g_old_rec.region_2;
  End If;
  If (p_rec.region_3 = hr_api.g_varchar2) then
    p_rec.region_3 :=
    per_kad_shd.g_old_rec.region_3;
  End If;
  If (p_rec.telephone_number_1 = hr_api.g_varchar2) then
    p_rec.telephone_number_1 :=
    per_kad_shd.g_old_rec.telephone_number_1;
  End If;
  If (p_rec.telephone_number_2 = hr_api.g_varchar2) then
    p_rec.telephone_number_2 :=
    per_kad_shd.g_old_rec.telephone_number_2;
  End If;
  If (p_rec.telephone_number_3 = hr_api.g_varchar2) then
    p_rec.telephone_number_3 :=
    per_kad_shd.g_old_rec.telephone_number_3;
  End If;
  If (p_rec.town_or_city = hr_api.g_varchar2) then
    p_rec.town_or_city :=
    per_kad_shd.g_old_rec.town_or_city;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_kad_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_kad_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_kad_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_kad_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.addr_attribute_category = hr_api.g_varchar2) then
    p_rec.addr_attribute_category :=
    per_kad_shd.g_old_rec.addr_attribute_category;
  End If;
  If (p_rec.addr_attribute1 = hr_api.g_varchar2) then
    p_rec.addr_attribute1 :=
    per_kad_shd.g_old_rec.addr_attribute1;
  End If;
  If (p_rec.addr_attribute2 = hr_api.g_varchar2) then
    p_rec.addr_attribute2 :=
    per_kad_shd.g_old_rec.addr_attribute2;
  End If;
  If (p_rec.addr_attribute3 = hr_api.g_varchar2) then
    p_rec.addr_attribute3 :=
    per_kad_shd.g_old_rec.addr_attribute3;
  End If;
  If (p_rec.addr_attribute4 = hr_api.g_varchar2) then
    p_rec.addr_attribute4 :=
    per_kad_shd.g_old_rec.addr_attribute4;
  End If;
  If (p_rec.addr_attribute5 = hr_api.g_varchar2) then
    p_rec.addr_attribute5 :=
    per_kad_shd.g_old_rec.addr_attribute5;
  End If;
  If (p_rec.addr_attribute6 = hr_api.g_varchar2) then
    p_rec.addr_attribute6 :=
    per_kad_shd.g_old_rec.addr_attribute6;
  End If;
  If (p_rec.addr_attribute7 = hr_api.g_varchar2) then
    p_rec.addr_attribute7 :=
    per_kad_shd.g_old_rec.addr_attribute7;
  End If;
  If (p_rec.addr_attribute8 = hr_api.g_varchar2) then
    p_rec.addr_attribute8 :=
    per_kad_shd.g_old_rec.addr_attribute8;
  End If;
  If (p_rec.addr_attribute9 = hr_api.g_varchar2) then
    p_rec.addr_attribute9 :=
    per_kad_shd.g_old_rec.addr_attribute9;
  End If;
  If (p_rec.addr_attribute10 = hr_api.g_varchar2) then
    p_rec.addr_attribute10 :=
    per_kad_shd.g_old_rec.addr_attribute10;
  End If;
  If (p_rec.addr_attribute11 = hr_api.g_varchar2) then
    p_rec.addr_attribute11 :=
    per_kad_shd.g_old_rec.addr_attribute11;
  End If;
  If (p_rec.addr_attribute12 = hr_api.g_varchar2) then
    p_rec.addr_attribute12 :=
    per_kad_shd.g_old_rec.addr_attribute12;
  End If;
  If (p_rec.addr_attribute13 = hr_api.g_varchar2) then
    p_rec.addr_attribute13 :=
    per_kad_shd.g_old_rec.addr_attribute13;
  End If;
  If (p_rec.addr_attribute14 = hr_api.g_varchar2) then
    p_rec.addr_attribute14 :=
    per_kad_shd.g_old_rec.addr_attribute14;
  End If;
  If (p_rec.addr_attribute15 = hr_api.g_varchar2) then
    p_rec.addr_attribute15 :=
    per_kad_shd.g_old_rec.addr_attribute15;
  End If;
  If (p_rec.addr_attribute16 = hr_api.g_varchar2) then
    p_rec.addr_attribute16 :=
    per_kad_shd.g_old_rec.addr_attribute16;
  End If;
  If (p_rec.addr_attribute17 = hr_api.g_varchar2) then
    p_rec.addr_attribute17 :=
    per_kad_shd.g_old_rec.addr_attribute17;
  End If;
  If (p_rec.addr_attribute18 = hr_api.g_varchar2) then
    p_rec.addr_attribute18 :=
    per_kad_shd.g_old_rec.addr_attribute18;
  End If;
  If (p_rec.addr_attribute19 = hr_api.g_varchar2) then
    p_rec.addr_attribute19 :=
    per_kad_shd.g_old_rec.addr_attribute19;
  End If;
  If (p_rec.addr_attribute20 = hr_api.g_varchar2) then
    p_rec.addr_attribute20 :=
    per_kad_shd.g_old_rec.addr_attribute20;
  End If;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(p_rec);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
   p_rec            in out nocopy per_kad_shd.g_rec_type
  ,p_validate       in     boolean default false
  ,p_effective_date in     date
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
  l_convert per_kad_shd.g_rec_type;
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
    SAVEPOINT upd_per_add;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  per_kad_shd.lck
	(
	p_rec.address_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  l_convert := convert_defs(p_rec);
  --
  per_kad_bus.update_validate(l_convert
                             ,p_effective_date
                             );
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
  post_update(p_rec,p_effective_date);
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
    ROLLBACK TO upd_per_add;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
   p_address_id               in     number
-- 70.2 change a start.
  ,p_date_from                in     date             default hr_api.g_date
-- 70.2 change a end.
  ,p_address_line1            in     varchar2         default hr_api.g_varchar2
  ,p_address_line2            in     varchar2         default hr_api.g_varchar2
  ,p_address_line3            in     varchar2         default hr_api.g_varchar2
  ,p_address_type             in     varchar2         default hr_api.g_varchar2
  ,p_comments                 in     long             default hr_api.g_varchar2
  ,p_country                  in     varchar2         default hr_api.g_varchar2
  ,p_date_to                  in     date             default hr_api.g_date
  ,p_postal_code              in     varchar2         default hr_api.g_varchar2
  ,p_region_1                 in     varchar2         default hr_api.g_varchar2
  ,p_region_2                 in     varchar2         default hr_api.g_varchar2
  ,p_region_3                 in     varchar2         default hr_api.g_varchar2
  ,p_telephone_number_1       in     varchar2         default hr_api.g_varchar2
  ,p_telephone_number_2       in     varchar2         default hr_api.g_varchar2
  ,p_telephone_number_3       in     varchar2         default hr_api.g_varchar2
  ,p_town_or_city             in     varchar2         default hr_api.g_varchar2
  ,p_request_id               in     number           default hr_api.g_number
  ,p_program_application_id   in     number           default hr_api.g_number
  ,p_program_id               in     number           default hr_api.g_number
  ,p_program_update_date      in     date             default hr_api.g_date
  ,p_addr_attribute_category  in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute1          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute2          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute3          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute4          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute5          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute6          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute7          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute8          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute9          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute10         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute11         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute12         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute13         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute14         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute15         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute16         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute17         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute18         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute19         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute20         in     varchar2         default hr_api.g_varchar2
  ,p_object_version_number    in out nocopy number
  ,p_validate                 in     boolean      default false
  ,p_effective_date           in     date
  ) is
--
  l_rec	  per_kad_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_kad_shd.convert_args
  (
  p_address_id,
-- 70.2 change a start.
  hr_api.g_number,
  hr_api.g_number,
  p_date_from,
  hr_api.g_varchar2,
  hr_api.g_varchar2,
-- 70.2 change a end.
  p_address_line1,
  p_address_line2,
  p_address_line3,
  p_address_type,
  p_comments,
  p_country,
  p_date_to,
  p_postal_code,
  p_region_1,
  p_region_2,
  p_region_3,
  p_telephone_number_1,
  p_telephone_number_2,
  p_telephone_number_3,
  p_town_or_city,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_addr_attribute_category,
  p_addr_attribute1,
  p_addr_attribute2,
  p_addr_attribute3,
  p_addr_attribute4,
  p_addr_attribute5,
  p_addr_attribute6,
  p_addr_attribute7,
  p_addr_attribute8,
  p_addr_attribute9,
  p_addr_attribute10,
  p_addr_attribute11,
  p_addr_attribute12,
  p_addr_attribute13,
  p_addr_attribute14,
  p_addr_attribute15,
  p_addr_attribute16,
  p_addr_attribute17,
  p_addr_attribute18,
  p_addr_attribute19,
  p_addr_attribute20,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec
     ,p_validate
     ,p_effective_date
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_kad_upd;

/
