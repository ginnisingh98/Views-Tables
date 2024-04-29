--------------------------------------------------------
--  DDL for Package Body HR_INT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_INT_UPD" as
/* $Header: hrintrhi.pkb 115.0 2004/01/09 01:40 vkarandi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_int_upd.';  -- Global package name
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
  (p_rec in out nocopy hr_int_shd.g_rec_type
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
  -- Update the hr_ki_integrations Row
  --
  update hr_ki_integrations
    set
     integration_id                  = p_rec.integration_id
    ,synched                         = p_rec.synched
    ,party_type                      = p_rec.party_type
    ,party_name                      = p_rec.party_name
    ,party_site_name                 = p_rec.party_site_name
    ,transaction_type                = p_rec.transaction_type
    ,transaction_subtype             = p_rec.transaction_subtype
    ,standard_code                   = p_rec.standard_code
    ,ext_trans_type                  = p_rec.ext_trans_type
    ,ext_trans_subtype               = p_rec.ext_trans_subtype
    ,trans_direction                 = p_rec.trans_direction
    ,url                             = p_rec.url
    ,ext_application_id              = p_rec.ext_application_id
    ,application_name                = p_rec.application_name
    ,application_type                = p_rec.application_type
    ,application_url                 = p_rec.application_url
    ,logout_url                      = p_rec.logout_url
    ,user_field                      = p_rec.user_field
    ,password_field                  = p_rec.password_field
    ,authentication_needed           = p_rec.authentication_needed
    ,field_name1                     = p_rec.field_name1
    ,field_value1                    = p_rec.field_value1
    ,field_name2                     = p_rec.field_name2
    ,field_value2                    = p_rec.field_value2
    ,field_name3                     = p_rec.field_name3
    ,field_value3                    = p_rec.field_value3
    ,field_name4                     = p_rec.field_name4
    ,field_value4                    = p_rec.field_value4
    ,field_name5                     = p_rec.field_name5
    ,field_value5                    = p_rec.field_value5
    ,field_name6                     = p_rec.field_name6
    ,field_value6                    = p_rec.field_value6
    ,field_name7                     = p_rec.field_name7
    ,field_value7                    = p_rec.field_value7
    ,field_name8                     = p_rec.field_name8
    ,field_value8                    = p_rec.field_value8
    ,field_name9                     = p_rec.field_name9
    ,field_value9                    = p_rec.field_value9
    ,object_version_number           = p_rec.object_version_number
    where integration_id = p_rec.integration_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_int_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_int_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_int_shd.constraint_error
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
  (p_rec in hr_int_shd.g_rec_type
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
  (p_rec                          in hr_int_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_int_rku.after_update
      (p_integration_id
      => p_rec.integration_id
      ,p_synched => p_rec.synched
      ,p_party_type
      => p_rec.party_type
      ,p_party_name
      => p_rec.party_name
      ,p_party_site_name
      => p_rec.party_site_name
      ,p_transaction_type
      => p_rec.transaction_type
      ,p_transaction_subtype
      => p_rec.transaction_subtype
      ,p_standard_code
      => p_rec.standard_code
      ,p_ext_trans_type
      => p_rec.ext_trans_type
      ,p_ext_trans_subtype
      => p_rec.ext_trans_subtype
      ,p_trans_direction
      => p_rec.trans_direction
      ,p_url
      => p_rec.url
      ,p_ext_application_id
      => p_rec.ext_application_id
      ,p_application_name
      => p_rec.application_name
      ,p_application_type
      => p_rec.application_type
      ,p_application_url
      => p_rec.application_url
      ,p_logout_url
      => p_rec.logout_url
      ,p_user_field
      => p_rec.user_field
      ,p_password_field
      => p_rec.password_field
      ,p_authentication_needed
      => p_rec.authentication_needed
      ,p_field_name1
      => p_rec.field_name1
      ,p_field_value1
      => p_rec.field_value1
      ,p_field_name2
      => p_rec.field_name2
      ,p_field_value2
      => p_rec.field_value2
      ,p_field_name3
      => p_rec.field_name3
      ,p_field_value3
      => p_rec.field_value3
      ,p_field_name4
      => p_rec.field_name4
      ,p_field_value4
      => p_rec.field_value4
      ,p_field_name5
      => p_rec.field_name5
      ,p_field_value5
      => p_rec.field_value5
      ,p_field_name6
      => p_rec.field_name6
      ,p_field_value6
      => p_rec.field_value6
      ,p_field_name7
      => p_rec.field_name7
      ,p_field_value7
      => p_rec.field_value7
      ,p_field_name8
      => p_rec.field_name8
      ,p_field_value8
      => p_rec.field_value8
      ,p_field_name9
      => p_rec.field_name9
      ,p_field_value9
      => p_rec.field_value9
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_integration_key_o
      => hr_int_shd.g_old_rec.integration_key
      ,p_party_type_o
      => hr_int_shd.g_old_rec.party_type
      ,p_party_name_o
      => hr_int_shd.g_old_rec.party_name
      ,p_party_site_name_o
      => hr_int_shd.g_old_rec.party_site_name
      ,p_transaction_type_o
      => hr_int_shd.g_old_rec.transaction_type
      ,p_transaction_subtype_o
      => hr_int_shd.g_old_rec.transaction_subtype
      ,p_standard_code_o
      => hr_int_shd.g_old_rec.standard_code
      ,p_ext_trans_type_o
      => hr_int_shd.g_old_rec.ext_trans_type
      ,p_ext_trans_subtype_o
      => hr_int_shd.g_old_rec.ext_trans_subtype
      ,p_trans_direction_o
      => hr_int_shd.g_old_rec.trans_direction
      ,p_url_o
      => hr_int_shd.g_old_rec.url
      ,p_synched_o
      => hr_int_shd.g_old_rec.synched
      ,p_ext_application_id_o
      => hr_int_shd.g_old_rec.ext_application_id
      ,p_application_name_o
      => hr_int_shd.g_old_rec.application_name
      ,p_application_type_o
      => hr_int_shd.g_old_rec.application_type
      ,p_application_url_o
      => hr_int_shd.g_old_rec.application_url
      ,p_logout_url_o
      => hr_int_shd.g_old_rec.logout_url
      ,p_user_field_o
      => hr_int_shd.g_old_rec.user_field
      ,p_password_field_o
      => hr_int_shd.g_old_rec.password_field
      ,p_authentication_needed_o
      => hr_int_shd.g_old_rec.authentication_needed
      ,p_field_name1_o
      => hr_int_shd.g_old_rec.field_name1
      ,p_field_value1_o
      => hr_int_shd.g_old_rec.field_value1
      ,p_field_name2_o
      => hr_int_shd.g_old_rec.field_name2
      ,p_field_value2_o
      => hr_int_shd.g_old_rec.field_value2
      ,p_field_name3_o
      => hr_int_shd.g_old_rec.field_name3
      ,p_field_value3_o
      => hr_int_shd.g_old_rec.field_value3
      ,p_field_name4_o
      => hr_int_shd.g_old_rec.field_name4
      ,p_field_value4_o
      => hr_int_shd.g_old_rec.field_value4
      ,p_field_name5_o
      => hr_int_shd.g_old_rec.field_name5
      ,p_field_value5_o
      => hr_int_shd.g_old_rec.field_value5
      ,p_field_name6_o
      => hr_int_shd.g_old_rec.field_name6
      ,p_field_value6_o
      => hr_int_shd.g_old_rec.field_value6
      ,p_field_name7_o
      => hr_int_shd.g_old_rec.field_name7
      ,p_field_value7_o
      => hr_int_shd.g_old_rec.field_value7
      ,p_field_name8_o
      => hr_int_shd.g_old_rec.field_name8
      ,p_field_value8_o
      => hr_int_shd.g_old_rec.field_value8
      ,p_field_name9_o
      => hr_int_shd.g_old_rec.field_name9
      ,p_field_value9_o
      => hr_int_shd.g_old_rec.field_value9
      ,p_object_version_number_o
      => hr_int_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_KI_INTEGRATIONS'
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
  (p_rec in out nocopy hr_int_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.integration_key = hr_api.g_varchar2) then
    p_rec.integration_key :=
    hr_int_shd.g_old_rec.integration_key;
  End If;
  If (p_rec.party_type = hr_api.g_varchar2) then
    p_rec.party_type :=
    hr_int_shd.g_old_rec.party_type;
  End If;
  If (p_rec.party_name = hr_api.g_varchar2) then
    p_rec.party_name :=
    hr_int_shd.g_old_rec.party_name;
  End If;
  If (p_rec.party_site_name = hr_api.g_varchar2) then
    p_rec.party_site_name :=
    hr_int_shd.g_old_rec.party_site_name;
  End If;
  If (p_rec.transaction_type = hr_api.g_varchar2) then
    p_rec.transaction_type :=
    hr_int_shd.g_old_rec.transaction_type;
  End If;
  If (p_rec.transaction_subtype = hr_api.g_varchar2) then
    p_rec.transaction_subtype :=
    hr_int_shd.g_old_rec.transaction_subtype;
  End If;
  If (p_rec.standard_code = hr_api.g_varchar2) then
    p_rec.standard_code :=
    hr_int_shd.g_old_rec.standard_code;
  End If;
  If (p_rec.ext_trans_type = hr_api.g_varchar2) then
    p_rec.ext_trans_type :=
    hr_int_shd.g_old_rec.ext_trans_type;
  End If;
  If (p_rec.ext_trans_subtype = hr_api.g_varchar2) then
    p_rec.ext_trans_subtype :=
    hr_int_shd.g_old_rec.ext_trans_subtype;
  End If;
  If (p_rec.trans_direction = hr_api.g_varchar2) then
    p_rec.trans_direction :=
    hr_int_shd.g_old_rec.trans_direction;
  End If;
  If (p_rec.url = hr_api.g_varchar2) then
    p_rec.url :=
    hr_int_shd.g_old_rec.url;
  End If;
  If (p_rec.synched = hr_api.g_varchar2) then
    p_rec.synched :=
    hr_int_shd.g_old_rec.synched;
  End If;
  If (p_rec.ext_application_id = hr_api.g_number) then
    p_rec.ext_application_id :=
    hr_int_shd.g_old_rec.ext_application_id;
  End If;
  If (p_rec.application_name = hr_api.g_varchar2) then
    p_rec.application_name :=
    hr_int_shd.g_old_rec.application_name;
  End If;
  If (p_rec.application_type = hr_api.g_varchar2) then
    p_rec.application_type :=
    hr_int_shd.g_old_rec.application_type;
  End If;
  If (p_rec.application_url = hr_api.g_varchar2) then
    p_rec.application_url :=
    hr_int_shd.g_old_rec.application_url;
  End If;
  If (p_rec.logout_url = hr_api.g_varchar2) then
    p_rec.logout_url :=
    hr_int_shd.g_old_rec.logout_url;
  End If;
  If (p_rec.user_field = hr_api.g_varchar2) then
    p_rec.user_field :=
    hr_int_shd.g_old_rec.user_field;
  End If;
  If (p_rec.password_field = hr_api.g_varchar2) then
    p_rec.password_field :=
    hr_int_shd.g_old_rec.password_field;
  End If;
  If (p_rec.authentication_needed = hr_api.g_varchar2) then
    p_rec.authentication_needed :=
    hr_int_shd.g_old_rec.authentication_needed;
  End If;
  If (p_rec.field_name1 = hr_api.g_varchar2) then
    p_rec.field_name1 :=
    hr_int_shd.g_old_rec.field_name1;
  End If;
  If (p_rec.field_value1 = hr_api.g_varchar2) then
    p_rec.field_value1 :=
    hr_int_shd.g_old_rec.field_value1;
  End If;
  If (p_rec.field_name2 = hr_api.g_varchar2) then
    p_rec.field_name2 :=
    hr_int_shd.g_old_rec.field_name2;
  End If;
  If (p_rec.field_value2 = hr_api.g_varchar2) then
    p_rec.field_value2 :=
    hr_int_shd.g_old_rec.field_value2;
  End If;
  If (p_rec.field_name3 = hr_api.g_varchar2) then
    p_rec.field_name3 :=
    hr_int_shd.g_old_rec.field_name3;
  End If;
  If (p_rec.field_value3 = hr_api.g_varchar2) then
    p_rec.field_value3 :=
    hr_int_shd.g_old_rec.field_value3;
  End If;
  If (p_rec.field_name4 = hr_api.g_varchar2) then
    p_rec.field_name4 :=
    hr_int_shd.g_old_rec.field_name4;
  End If;
  If (p_rec.field_value4 = hr_api.g_varchar2) then
    p_rec.field_value4 :=
    hr_int_shd.g_old_rec.field_value4;
  End If;
  If (p_rec.field_name5 = hr_api.g_varchar2) then
    p_rec.field_name5 :=
    hr_int_shd.g_old_rec.field_name5;
  End If;
  If (p_rec.field_value5 = hr_api.g_varchar2) then
    p_rec.field_value5 :=
    hr_int_shd.g_old_rec.field_value5;
  End If;
  If (p_rec.field_name6 = hr_api.g_varchar2) then
    p_rec.field_name6 :=
    hr_int_shd.g_old_rec.field_name6;
  End If;
  If (p_rec.field_value6 = hr_api.g_varchar2) then
    p_rec.field_value6 :=
    hr_int_shd.g_old_rec.field_value6;
  End If;
  If (p_rec.field_name7 = hr_api.g_varchar2) then
    p_rec.field_name7 :=
    hr_int_shd.g_old_rec.field_name7;
  End If;
  If (p_rec.field_value7 = hr_api.g_varchar2) then
    p_rec.field_value7 :=
    hr_int_shd.g_old_rec.field_value7;
  End If;
  If (p_rec.field_name8 = hr_api.g_varchar2) then
    p_rec.field_name8 :=
    hr_int_shd.g_old_rec.field_name8;
  End If;
  If (p_rec.field_value8 = hr_api.g_varchar2) then
    p_rec.field_value8 :=
    hr_int_shd.g_old_rec.field_value8;
  End If;
  If (p_rec.field_name9 = hr_api.g_varchar2) then
    p_rec.field_name9 :=
    hr_int_shd.g_old_rec.field_name9;
  End If;
  If (p_rec.field_value9 = hr_api.g_varchar2) then
    p_rec.field_value9 :=
    hr_int_shd.g_old_rec.field_value9;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hr_int_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  hr_int_shd.lck
    (p_rec.integration_id
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
  hr_int_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  hr_int_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hr_int_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hr_int_upd.post_update
     (p_rec
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
  (p_integration_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_synched                      in     varchar2  default hr_api.g_varchar2
  ,p_party_type                   in     varchar2  default hr_api.g_varchar2
  ,p_party_name                   in     varchar2  default hr_api.g_varchar2
  ,p_party_site_name              in     varchar2  default hr_api.g_varchar2
  ,p_transaction_type             in     varchar2  default hr_api.g_varchar2
  ,p_transaction_subtype          in     varchar2  default hr_api.g_varchar2
  ,p_standard_code                in     varchar2  default hr_api.g_varchar2
  ,p_ext_trans_type               in     varchar2  default hr_api.g_varchar2
  ,p_ext_trans_subtype            in     varchar2  default hr_api.g_varchar2
  ,p_trans_direction              in     varchar2  default hr_api.g_varchar2
  ,p_url                          in     varchar2  default hr_api.g_varchar2
  ,p_ext_application_id           in     number    default hr_api.g_number
  ,p_application_name             in     varchar2  default hr_api.g_varchar2
  ,p_application_type             in     varchar2  default hr_api.g_varchar2
  ,p_application_url              in     varchar2  default hr_api.g_varchar2
  ,p_logout_url                   in     varchar2  default hr_api.g_varchar2
  ,p_user_field                   in     varchar2  default hr_api.g_varchar2
  ,p_password_field               in     varchar2  default hr_api.g_varchar2
  ,p_authentication_needed        in     varchar2  default hr_api.g_varchar2
  ,p_field_name1                  in     varchar2  default hr_api.g_varchar2
  ,p_field_value1                 in     varchar2  default hr_api.g_varchar2
  ,p_field_name2                  in     varchar2  default hr_api.g_varchar2
  ,p_field_value2                 in     varchar2  default hr_api.g_varchar2
  ,p_field_name3                  in     varchar2  default hr_api.g_varchar2
  ,p_field_value3                 in     varchar2  default hr_api.g_varchar2
  ,p_field_name4                  in     varchar2  default hr_api.g_varchar2
  ,p_field_value4                 in     varchar2  default hr_api.g_varchar2
  ,p_field_name5                  in     varchar2  default hr_api.g_varchar2
  ,p_field_value5                 in     varchar2  default hr_api.g_varchar2
  ,p_field_name6                  in     varchar2  default hr_api.g_varchar2
  ,p_field_value6                 in     varchar2  default hr_api.g_varchar2
  ,p_field_name7                  in     varchar2  default hr_api.g_varchar2
  ,p_field_value7                 in     varchar2  default hr_api.g_varchar2
  ,p_field_name8                  in     varchar2  default hr_api.g_varchar2
  ,p_field_value8                 in     varchar2  default hr_api.g_varchar2
  ,p_field_name9                  in     varchar2  default hr_api.g_varchar2
  ,p_field_value9                 in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   hr_int_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_int_shd.convert_args
  (p_integration_id
  ,hr_api.g_varchar2
  ,p_party_type
  ,p_party_name
  ,p_party_site_name
  ,p_transaction_type
  ,p_transaction_subtype
  ,p_standard_code
  ,p_ext_trans_type
  ,p_ext_trans_subtype
  ,p_trans_direction
  ,p_url
  ,p_synched
  ,p_ext_application_id
  ,p_application_name
  ,p_application_type
  ,p_application_url
  ,p_logout_url
  ,p_user_field
  ,p_password_field
  ,p_authentication_needed
  ,p_field_name1
  ,p_field_value1
  ,p_field_name2
  ,p_field_value2
  ,p_field_name3
  ,p_field_value3
  ,p_field_name4
  ,p_field_value4
  ,p_field_name5
  ,p_field_value5
  ,p_field_name6
  ,p_field_value6
  ,p_field_name7
  ,p_field_value7
  ,p_field_name8
  ,p_field_value8
  ,p_field_name9
  ,p_field_value9
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hr_int_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end hr_int_upd;

/
