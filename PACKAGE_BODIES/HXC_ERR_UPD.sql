--------------------------------------------------------
--  DDL for Package Body HXC_ERR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ERR_UPD" as
/* $Header: hxcerrrhi.pkb 120.2 2005/09/23 08:08:12 sechandr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_err_upd.';  -- Global package name
g_debug    boolean	:= hr_utility.debug_enabled;
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
  (p_rec in out nocopy hxc_err_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
	l_proc := g_package||'update_dml';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the hxc_errors Row
  --
  update hxc_errors
    set
     error_id                        = p_rec.error_id
    ,transaction_detail_id           = p_rec.transaction_detail_id
    ,time_building_block_id          = p_rec.time_building_block_id
    ,time_building_block_ovn         = p_rec.time_building_block_ovn
    ,time_attribute_id               = p_rec.time_attribute_id
    ,time_attribute_ovn              = p_rec.time_attribute_ovn
    ,message_name                    = p_rec.message_name
    ,message_level                   = p_rec.message_level
    ,message_field                   = p_rec.message_field
    ,message_tokens                  = p_rec.message_tokens
    ,application_short_name          = p_rec.application_short_name
    ,object_version_number           = p_rec.object_version_number
    ,date_from			     = p_rec.date_from
    ,date_to			     = p_rec.date_to
    where error_id = p_rec.error_id;
  --
  --
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hxc_err_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hxc_err_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hxc_err_shd.constraint_error
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
  (p_rec in hxc_err_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
	l_proc := g_package||'pre_update';
	hr_utility.set_location('Entering:'||l_proc, 5);
	--
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  (p_rec                          in hxc_err_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
	l_proc := g_package||'post_update';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
/*    hxc_err_rku.after_update
      (p_error_id
      => p_rec.error_id
      ,p_transaction_detail_id
      => p_rec.transaction_detail_id
      ,p_time_building_block_id
      => p_rec.time_building_block_id
      ,p_time_building_block_ovn
      => p_rec.time_building_block_ovn
      ,p_time_attribute_id
      => p_rec.time_attribute_id
      ,p_time_attribute_ovn
      => p_rec.time_attribute_ovn
      ,p_message_name
      => p_rec.message_name
      ,p_message_level
      => p_rec.message_level
      ,p_message_field
      => p_rec.message_field
      ,p_message_tokens
      => p_rec.message_tokens
      ,p_application_short_name
      => p_rec.application_short_name
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_transaction_detail_id_o
      => hxc_err_shd.g_old_rec.transaction_detail_id
      ,p_time_building_block_id_o
      => hxc_err_shd.g_old_rec.time_building_block_id
      ,p_time_building_block_ovn_o
      => hxc_err_shd.g_old_rec.time_building_block_ovn
      ,p_time_attribute_id_o
      => hxc_err_shd.g_old_rec.time_attribute_id
      ,p_time_attribute_ovn_o
      => hxc_err_shd.g_old_rec.time_attribute_ovn
      ,p_message_name_o
      => hxc_err_shd.g_old_rec.message_name
      ,p_message_level_o
      => hxc_err_shd.g_old_rec.message_level
      ,p_message_field_o
      => hxc_err_shd.g_old_rec.message_field
      ,p_message_tokens_o
      => hxc_err_shd.g_old_rec.message_tokens
      ,p_application_short_name_o
      => hxc_err_shd.g_old_rec.application_short_name
      ,p_object_version_number_o
      => hxc_err_shd.g_old_rec.object_version_number
      );
      */
      null;

    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_ERRORS'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  (p_rec in out nocopy hxc_err_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.transaction_detail_id = hr_api.g_number) then
    p_rec.transaction_detail_id :=
    hxc_err_shd.g_old_rec.transaction_detail_id;
  End If;
  If (p_rec.time_building_block_id = hr_api.g_number) then
    p_rec.time_building_block_id :=
    hxc_err_shd.g_old_rec.time_building_block_id;
  End If;
  If (p_rec.time_building_block_ovn = hr_api.g_number) then
    p_rec.time_building_block_ovn :=
    hxc_err_shd.g_old_rec.time_building_block_ovn;
  End If;
  If (p_rec.time_attribute_id = hr_api.g_number) then
    p_rec.time_attribute_id :=
    hxc_err_shd.g_old_rec.time_attribute_id;
  End If;
  If (p_rec.time_attribute_ovn = hr_api.g_number) then
    p_rec.time_attribute_ovn :=
    hxc_err_shd.g_old_rec.time_attribute_ovn;
  End If;
  If (p_rec.message_name = hr_api.g_varchar2) then
    p_rec.message_name :=
    hxc_err_shd.g_old_rec.message_name;
  End If;
  If (p_rec.message_level = hr_api.g_varchar2) then
    p_rec.message_level :=
    hxc_err_shd.g_old_rec.message_level;
  End If;
  If (p_rec.message_field = hr_api.g_varchar2) then
    p_rec.message_field :=
    hxc_err_shd.g_old_rec.message_field;
  End If;
  If (p_rec.message_tokens = hr_api.g_varchar2) then
    p_rec.message_tokens :=
    hxc_err_shd.g_old_rec.message_tokens;
  End If;
  If (p_rec.application_short_name = hr_api.g_varchar2) then
    p_rec.application_short_name :=
    hxc_err_shd.g_old_rec.application_short_name;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hxc_err_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'upd';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to update.
  --
  hxc_err_shd.lck
    (p_rec.error_id
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
  hxc_err_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  hxc_err_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hxc_err_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hxc_err_upd.post_update
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
  (p_error_id                     in     number
  ,p_object_version_number        in     number
  ,p_transaction_detail_id        in     number    default hr_api.g_number
  ,p_time_building_block_id       in     number    default hr_api.g_number
  ,p_time_building_block_ovn      in     number    default hr_api.g_number
  ,p_time_attribute_id            in     number    default hr_api.g_number
  ,p_time_attribute_ovn           in     number    default hr_api.g_number
  ,p_message_name                 in     varchar2  default hr_api.g_varchar2
  ,p_message_level                in     varchar2  default hr_api.g_varchar2
  ,p_message_field                in     varchar2  default hr_api.g_varchar2
  ,p_message_tokens               in     varchar2  default hr_api.g_varchar2
  ,p_application_short_name       in     varchar2  default hr_api.g_varchar2
  ,p_date_from			  in     date
  ,p_date_to                      in     date
  ) is
--
  l_rec   hxc_err_shd.g_rec_type;
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'upd';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hxc_err_shd.convert_args
  (p_error_id
  ,p_transaction_detail_id
  ,p_time_building_block_id
  ,p_time_building_block_ovn
  ,p_time_attribute_id
  ,p_time_attribute_ovn
  ,p_message_name
  ,p_message_level
  ,p_message_field
  ,p_message_tokens
  ,p_application_short_name
  ,p_object_version_number
  ,p_date_from
  ,p_date_to
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hxc_err_upd.upd
     (l_rec
     );
  --p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End upd;
--
end hxc_err_upd;

/
