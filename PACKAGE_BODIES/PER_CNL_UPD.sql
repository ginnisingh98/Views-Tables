--------------------------------------------------------
--  DDL for Package Body PER_CNL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CNL_UPD" as
/* $Header: pecnlrhi.pkb 120.0 2005/05/31 06:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cnl_upd.';  -- Global package name
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
  (p_rec in out nocopy per_cnl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the per_ri_config_locations Row
  --
  update per_ri_config_locations
    set
     configuration_code              = p_rec.configuration_code
    ,configuration_context           = p_rec.configuration_context
    ,location_id                     = p_rec.location_id
    ,location_code                   = p_rec.location_code
    ,description                     = p_rec.description
    ,style                           = p_rec.style
    ,address_line_1                  = p_rec.address_line_1
    ,address_line_2                  = p_rec.address_line_2
    ,address_line_3                  = p_rec.address_line_3
    ,town_or_city                    = p_rec.town_or_city
    ,country                         = p_rec.country
    ,postal_code                     = p_rec.postal_code
    ,region_1                        = p_rec.region_1
    ,region_2                        = p_rec.region_2
    ,region_3                        = p_rec.region_3
    ,telephone_number_1              = p_rec.telephone_number_1
    ,telephone_number_2              = p_rec.telephone_number_2
    ,telephone_number_3              = p_rec.telephone_number_3
    ,loc_information13               = p_rec.loc_information13
    ,loc_information14               = p_rec.loc_information14
    ,loc_information15               = p_rec.loc_information15
    ,loc_information16               = p_rec.loc_information16
    ,loc_information17               = p_rec.loc_information17
    ,loc_information18               = p_rec.loc_information18
    ,loc_information19               = p_rec.loc_information19
    ,loc_information20               = p_rec.loc_information20
    ,object_version_number           = p_rec.object_version_number
    where location_id = p_rec.location_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_cnl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_cnl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_cnl_shd.constraint_error
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
  (p_rec in per_cnl_shd.g_rec_type
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
--   This private procedure contains any processing which is required after
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
  ,p_rec                          in per_cnl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_cnl_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_configuration_code          => p_rec.configuration_code
      ,p_configuration_context       => p_rec.configuration_context
      ,p_location_id                 => p_rec.location_id
      ,p_location_code               => p_rec.location_code
      ,p_description                 => p_rec.description
      ,p_style                       => p_rec.style
      ,p_address_line_1              => p_rec.address_line_1
      ,p_address_line_2              => p_rec.address_line_2
      ,p_address_line_3              => p_rec.address_line_3
      ,p_town_or_city                => p_rec.town_or_city
      ,p_country                     => p_rec.country
      ,p_postal_code                 => p_rec.postal_code
      ,p_region_1                    => p_rec.region_1
      ,p_region_2                    => p_rec.region_2
      ,p_region_3                    => p_rec.region_3
      ,p_telephone_number_1          => p_rec.telephone_number_1
      ,p_telephone_number_2          => p_rec.telephone_number_2
      ,p_telephone_number_3          => p_rec.telephone_number_3
      ,p_loc_information13           => p_rec.loc_information13
      ,p_loc_information14           => p_rec.loc_information14
      ,p_loc_information15           => p_rec.loc_information15
      ,p_loc_information16           => p_rec.loc_information16
      ,p_loc_information17           => p_rec.loc_information17
      ,p_loc_information18           => p_rec.loc_information18
      ,p_loc_information19           => p_rec.loc_information19
      ,p_loc_information20           => p_rec.loc_information20
      ,p_object_version_number       => p_rec.object_version_number
      ,p_configuration_code_o        => per_cnl_shd.g_old_rec.configuration_code
      ,p_configuration_context_o     => per_cnl_shd.g_old_rec.configuration_context
      ,p_location_code_o             => per_cnl_shd.g_old_rec.location_code
      ,p_description_o               => per_cnl_shd.g_old_rec.description
      ,p_style_o                     => per_cnl_shd.g_old_rec.style
      ,p_address_line_1_o            => per_cnl_shd.g_old_rec.address_line_1
      ,p_address_line_2_o            => per_cnl_shd.g_old_rec.address_line_2
      ,p_address_line_3_o            => per_cnl_shd.g_old_rec.address_line_3
      ,p_town_or_city_o              => per_cnl_shd.g_old_rec.town_or_city
      ,p_country_o                   => per_cnl_shd.g_old_rec.country
      ,p_postal_code_o               => per_cnl_shd.g_old_rec.postal_code
      ,p_region_1_o                  => per_cnl_shd.g_old_rec.region_1
      ,p_region_2_o                  => per_cnl_shd.g_old_rec.region_2
      ,p_region_3_o                  => per_cnl_shd.g_old_rec.region_3
      ,p_telephone_number_1_o        => per_cnl_shd.g_old_rec.telephone_number_1
      ,p_telephone_number_2_o        => per_cnl_shd.g_old_rec.telephone_number_2
      ,p_telephone_number_3_o        => per_cnl_shd.g_old_rec.telephone_number_3
      ,p_loc_information13_o         => per_cnl_shd.g_old_rec.loc_information13
      ,p_loc_information14_o         => per_cnl_shd.g_old_rec.loc_information14
      ,p_loc_information15_o         => per_cnl_shd.g_old_rec.loc_information15
      ,p_loc_information16_o         => per_cnl_shd.g_old_rec.loc_information16
      ,p_loc_information17_o         => per_cnl_shd.g_old_rec.loc_information17
      ,p_loc_information18_o         => per_cnl_shd.g_old_rec.loc_information18
      ,p_loc_information19_o         => per_cnl_shd.g_old_rec.loc_information19
      ,p_loc_information20_o         => per_cnl_shd.g_old_rec.loc_information20
      ,p_object_version_number_o     => per_cnl_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_RI_CONFIG_LOCATIONS'
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
  (p_rec in out nocopy per_cnl_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.configuration_code = hr_api.g_varchar2) then
    p_rec.configuration_code :=
    per_cnl_shd.g_old_rec.configuration_code;
  End If;
  If (p_rec.configuration_context = hr_api.g_varchar2) then
    p_rec.configuration_context :=
    per_cnl_shd.g_old_rec.configuration_context;
  End If;
  If (p_rec.location_code = hr_api.g_varchar2) then
    p_rec.location_code :=
    per_cnl_shd.g_old_rec.location_code;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    per_cnl_shd.g_old_rec.description;
  End If;
  If (p_rec.style = hr_api.g_varchar2) then
    p_rec.style :=
    per_cnl_shd.g_old_rec.style;
  End If;
  If (p_rec.address_line_1 = hr_api.g_varchar2) then
    p_rec.address_line_1 :=
    per_cnl_shd.g_old_rec.address_line_1;
  End If;
  If (p_rec.address_line_2 = hr_api.g_varchar2) then
    p_rec.address_line_2 :=
    per_cnl_shd.g_old_rec.address_line_2;
  End If;
  If (p_rec.address_line_3 = hr_api.g_varchar2) then
    p_rec.address_line_3 :=
    per_cnl_shd.g_old_rec.address_line_3;
  End If;
  If (p_rec.town_or_city = hr_api.g_varchar2) then
    p_rec.town_or_city :=
    per_cnl_shd.g_old_rec.town_or_city;
  End If;
  If (p_rec.country = hr_api.g_varchar2) then
    p_rec.country :=
    per_cnl_shd.g_old_rec.country;
  End If;
  If (p_rec.postal_code = hr_api.g_varchar2) then
    p_rec.postal_code :=
    per_cnl_shd.g_old_rec.postal_code;
  End If;
  If (p_rec.region_1 = hr_api.g_varchar2) then
    p_rec.region_1 :=
    per_cnl_shd.g_old_rec.region_1;
  End If;
  If (p_rec.region_2 = hr_api.g_varchar2) then
    p_rec.region_2 :=
    per_cnl_shd.g_old_rec.region_2;
  End If;
  If (p_rec.region_3 = hr_api.g_varchar2) then
    p_rec.region_3 :=
    per_cnl_shd.g_old_rec.region_3;
  End If;
  If (p_rec.telephone_number_1 = hr_api.g_varchar2) then
    p_rec.telephone_number_1 :=
    per_cnl_shd.g_old_rec.telephone_number_1;
  End If;
  If (p_rec.telephone_number_2 = hr_api.g_varchar2) then
    p_rec.telephone_number_2 :=
    per_cnl_shd.g_old_rec.telephone_number_2;
  End If;
  If (p_rec.telephone_number_3 = hr_api.g_varchar2) then
    p_rec.telephone_number_3 :=
    per_cnl_shd.g_old_rec.telephone_number_3;
  End If;
  If (p_rec.loc_information13 = hr_api.g_varchar2) then
    p_rec.loc_information13 :=
    per_cnl_shd.g_old_rec.loc_information13;
  End If;
  If (p_rec.loc_information14 = hr_api.g_varchar2) then
    p_rec.loc_information14 :=
    per_cnl_shd.g_old_rec.loc_information14;
  End If;
  If (p_rec.loc_information15 = hr_api.g_varchar2) then
    p_rec.loc_information15 :=
    per_cnl_shd.g_old_rec.loc_information15;
  End If;
  If (p_rec.loc_information16 = hr_api.g_varchar2) then
    p_rec.loc_information16 :=
    per_cnl_shd.g_old_rec.loc_information16;
  End If;
  If (p_rec.loc_information17 = hr_api.g_varchar2) then
    p_rec.loc_information17 :=
    per_cnl_shd.g_old_rec.loc_information17;
  End If;
  If (p_rec.loc_information18 = hr_api.g_varchar2) then
    p_rec.loc_information18 :=
    per_cnl_shd.g_old_rec.loc_information18;
  End If;
  If (p_rec.loc_information19 = hr_api.g_varchar2) then
    p_rec.loc_information19 :=
    per_cnl_shd.g_old_rec.loc_information19;
  End If;
  If (p_rec.loc_information20 = hr_api.g_varchar2) then
    p_rec.loc_information20 :=
    per_cnl_shd.g_old_rec.loc_information20;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_cnl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_cnl_shd.lck
    (p_rec.location_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  per_cnl_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  per_cnl_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_cnl_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_cnl_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_location_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_configuration_code           in     varchar2  default hr_api.g_varchar2
  ,p_configuration_context        in     varchar2  default hr_api.g_varchar2
  ,p_location_code                in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_style                        in     varchar2  default hr_api.g_varchar2
  ,p_address_line_1               in     varchar2  default hr_api.g_varchar2
  ,p_address_line_2               in     varchar2  default hr_api.g_varchar2
  ,p_address_line_3               in     varchar2  default hr_api.g_varchar2
  ,p_town_or_city                 in     varchar2  default hr_api.g_varchar2
  ,p_country                      in     varchar2  default hr_api.g_varchar2
  ,p_postal_code                  in     varchar2  default hr_api.g_varchar2
  ,p_region_1                     in     varchar2  default hr_api.g_varchar2
  ,p_region_2                     in     varchar2  default hr_api.g_varchar2
  ,p_region_3                     in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_1           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_2           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_3           in     varchar2  default hr_api.g_varchar2
  ,p_loc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information20            in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   per_cnl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_cnl_shd.convert_args
  (p_configuration_code
  ,p_configuration_context
  ,p_location_id
  ,p_location_code
  ,p_description
  ,p_style
  ,p_address_line_1
  ,p_address_line_2
  ,p_address_line_3
  ,p_town_or_city
  ,p_country
  ,p_postal_code
  ,p_region_1
  ,p_region_2
  ,p_region_3
  ,p_telephone_number_1
  ,p_telephone_number_2
  ,p_telephone_number_3
  ,p_loc_information13
  ,p_loc_information14
  ,p_loc_information15
  ,p_loc_information16
  ,p_loc_information17
  ,p_loc_information18
  ,p_loc_information19
  ,p_loc_information20
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_cnl_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_cnl_upd;

/
