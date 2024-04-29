--------------------------------------------------------
--  DDL for Package Body IRC_RSE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_RSE_UPD" as
/* $Header: irrserhi.pkb 120.0.12010000.2 2010/01/18 14:37:22 mkjayara ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_rse_upd.';  -- Global package name
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
  (p_rec in out nocopy irc_rse_shd.g_rec_type
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
  irc_rse_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the irc_all_recruiting_sites Row
  --
  update irc_all_recruiting_sites
    set
     recruiting_site_id              = p_rec.recruiting_site_id
    ,date_from                       = p_rec.date_from
    ,date_to                         = p_rec.date_to
    ,posting_username                = p_rec.posting_username
    ,posting_password                = p_rec.posting_password
    ,internal                        = p_rec.internal
    ,external                        = p_rec.external
    ,third_party                     = p_rec.third_party
    ,posting_cost                    = p_rec.posting_cost
    ,posting_cost_period             = p_rec.posting_cost_period
    ,posting_cost_currency           = p_rec.posting_cost_currency
    ,stylesheet             = p_rec.stylesheet
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,attribute21                     = p_rec.attribute21
    ,attribute22                     = p_rec.attribute22
    ,attribute23                     = p_rec.attribute23
    ,attribute24                     = p_rec.attribute24
    ,attribute25                     = p_rec.attribute25
    ,attribute26                     = p_rec.attribute26
    ,attribute27                     = p_rec.attribute27
    ,attribute28                     = p_rec.attribute28
    ,attribute29                     = p_rec.attribute29
    ,attribute30                     = p_rec.attribute30
    ,object_version_number           = p_rec.object_version_number
    ,internal_name                   = p_rec.internal_name
    ,posting_impl_class              = p_rec.posting_impl_class
    where recruiting_site_id = p_rec.recruiting_site_id;
  --
  irc_rse_shd.g_api_dml := false;  -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    irc_rse_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_rse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    irc_rse_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_rse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    irc_rse_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_rse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    irc_rse_shd.g_api_dml := false;  -- Unset the api dml status
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
  (p_rec in irc_rse_shd.g_rec_type
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
  ,p_rec                          in irc_rse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_rse_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_recruiting_site_id
      => p_rec.recruiting_site_id
      ,p_date_from
      => p_rec.date_from
      ,p_date_to
      => p_rec.date_to
      ,p_posting_username
      => p_rec.posting_username
      ,p_posting_password
      => p_rec.posting_password
      ,p_internal
      => p_rec.internal
      ,p_external
      => p_rec.external
      ,p_third_party
      => p_rec.third_party
      ,p_posting_cost
      => p_rec.posting_cost
      ,p_posting_cost_period
      => p_rec.posting_cost_period
      ,p_posting_cost_currency
      => p_rec.posting_cost_currency
      ,p_stylesheet
      => p_rec.stylesheet
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_internal_name
      => p_rec.internal_name
      ,p_date_from_o
      => irc_rse_shd.g_old_rec.date_from
      ,p_date_to_o
      => irc_rse_shd.g_old_rec.date_to
      ,p_posting_username_o
      => irc_rse_shd.g_old_rec.posting_username
      ,p_posting_password_o
      => irc_rse_shd.g_old_rec.posting_password
      ,p_internal_o
      => irc_rse_shd.g_old_rec.internal
      ,p_external_o
      => irc_rse_shd.g_old_rec.external
      ,p_third_party_o
      => irc_rse_shd.g_old_rec.third_party
      ,p_posting_cost_o
      => irc_rse_shd.g_old_rec.posting_cost
      ,p_posting_cost_period_o
      => irc_rse_shd.g_old_rec.posting_cost_period
      ,p_posting_cost_currency_o
      => irc_rse_shd.g_old_rec.posting_cost_currency
      ,p_stylesheet_o
      => irc_rse_shd.g_old_rec.stylesheet
      ,p_attribute_category_o
      => irc_rse_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => irc_rse_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => irc_rse_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => irc_rse_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => irc_rse_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => irc_rse_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => irc_rse_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => irc_rse_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => irc_rse_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => irc_rse_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => irc_rse_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => irc_rse_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => irc_rse_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => irc_rse_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => irc_rse_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => irc_rse_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => irc_rse_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => irc_rse_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => irc_rse_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => irc_rse_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => irc_rse_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => irc_rse_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => irc_rse_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => irc_rse_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => irc_rse_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => irc_rse_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => irc_rse_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => irc_rse_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => irc_rse_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => irc_rse_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => irc_rse_shd.g_old_rec.attribute30
      ,p_object_version_number_o
      => irc_rse_shd.g_old_rec.object_version_number
      ,p_internal_name_o
      => irc_rse_shd.g_old_rec.internal_name
      ,p_posting_impl_class_o
      => irc_rse_shd.g_old_rec.posting_impl_class
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_ALL_RECRUITING_SITES'
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
  (p_rec in out nocopy irc_rse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    irc_rse_shd.g_old_rec.date_from;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    irc_rse_shd.g_old_rec.date_to;
  End If;
  If (p_rec.posting_username = hr_api.g_varchar2) then
    p_rec.posting_username :=
    irc_rse_shd.g_old_rec.posting_username;
  End If;
  If (p_rec.posting_password = hr_api.g_varchar2) then
    p_rec.posting_password :=
    irc_rse_shd.g_old_rec.posting_password;
  End If;
  If (p_rec.internal = hr_api.g_varchar2) then
    p_rec.internal :=
    irc_rse_shd.g_old_rec.internal;
  End If;
  If (p_rec.external = hr_api.g_varchar2) then
    p_rec.external :=
    irc_rse_shd.g_old_rec.external;
  End If;
  If (p_rec.third_party = hr_api.g_varchar2) then
    p_rec.third_party :=
    irc_rse_shd.g_old_rec.third_party;
  End If;
  If (p_rec.posting_cost = hr_api.g_number) then
    p_rec.posting_cost :=
    irc_rse_shd.g_old_rec.posting_cost;
  End If;
  If (p_rec.posting_cost_period = hr_api.g_varchar2) then
    p_rec.posting_cost_period :=
    irc_rse_shd.g_old_rec.posting_cost_period;
  End If;
  If (p_rec.posting_cost_currency = hr_api.g_varchar2) then
    p_rec.posting_cost_currency :=
    irc_rse_shd.g_old_rec.posting_cost_currency;
  End If;
  If (p_rec.stylesheet = hr_api.g_varchar2) then
    p_rec.stylesheet :=
    irc_rse_shd.g_old_rec.stylesheet;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    irc_rse_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    irc_rse_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    irc_rse_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    irc_rse_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    irc_rse_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    irc_rse_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    irc_rse_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    irc_rse_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    irc_rse_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    irc_rse_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    irc_rse_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    irc_rse_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    irc_rse_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    irc_rse_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    irc_rse_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    irc_rse_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    irc_rse_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    irc_rse_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    irc_rse_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    irc_rse_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    irc_rse_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    irc_rse_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    irc_rse_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    irc_rse_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    irc_rse_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    irc_rse_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    irc_rse_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    irc_rse_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    irc_rse_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    irc_rse_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    irc_rse_shd.g_old_rec.attribute30;
  End If;
  If (p_rec.internal_name = hr_api.g_varchar2) then
    p_rec.internal_name :=
    irc_rse_shd.g_old_rec.internal_name;
  END If;
  if (p_rec.posting_impl_class = hr_api.g_varchar2) then
    p_rec.posting_impl_class :=
    irc_rse_shd.g_old_rec.posting_impl_class;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_rse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  irc_rse_shd.lck
    (p_rec.recruiting_site_id
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
  irc_rse_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  irc_rse_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  irc_rse_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  irc_rse_upd.post_update
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
  ,p_recruiting_site_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_date_from                    in     date  default hr_api.g_date
  ,p_date_to                      in     date  default hr_api.g_date
  ,p_posting_username             in     varchar2 default hr_api.g_varchar2
  ,p_posting_password             in     varchar2 default hr_api.g_varchar2
  ,p_internal                     in     varchar2  default hr_api.g_varchar2
  ,p_external                     in     varchar2  default hr_api.g_varchar2
  ,p_third_party                  in     varchar2  default hr_api.g_varchar2
  ,p_posting_cost                 in     number    default hr_api.g_number
  ,p_posting_cost_period          in     varchar2  default hr_api.g_varchar2
  ,p_posting_cost_currency        in     varchar2  default hr_api.g_varchar2
  ,p_stylesheet          in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_internal_name                in     varchar2  default hr_api.g_varchar2
  ,p_posting_impl_class           in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   irc_rse_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  irc_rse_shd.convert_args
  (p_recruiting_site_id
  ,p_date_from
  ,p_date_to
  ,p_posting_username
  ,p_posting_password
  ,p_internal
  ,p_external
  ,p_third_party
  ,p_posting_cost
  ,p_posting_cost_period
  ,p_posting_cost_currency
  ,p_stylesheet
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_attribute21
  ,p_attribute22
  ,p_attribute23
  ,p_attribute24
  ,p_attribute25
  ,p_attribute26
  ,p_attribute27
  ,p_attribute28
  ,p_attribute29
  ,p_attribute30
  ,p_object_version_number
  ,p_internal_name
  ,p_posting_impl_class
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  irc_rse_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end irc_rse_upd;

/
