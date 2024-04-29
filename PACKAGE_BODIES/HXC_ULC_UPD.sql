--------------------------------------------------------
--  DDL for Package Body HXC_ULC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ULC_UPD" as
/* $Header: hxculcrhi.pkb 120.2 2005/09/23 06:07:43 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ulc_upd.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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
  (p_rec in out nocopy hxc_ulc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
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
  -- Update the hxc_layout_components Row
  --
  update hxc_layout_components
    set
     layout_component_id             = p_rec.layout_component_id
    ,layout_id                       = p_rec.layout_id
    ,parent_component_id             = p_rec.parent_component_id
    ,component_name                  = p_rec.component_name
    ,component_value                 = p_rec.component_value
    ,sequence                        = p_rec.sequence
    ,name_value_string               = p_rec.name_value_string
    ,region_code                     = p_rec.region_code
    ,region_code_app_id              = p_rec.region_code_app_id
    ,attribute_code                  = p_rec.attribute_code
    ,attribute_code_app_id           = p_rec.attribute_code_app_id
    ,object_version_number           = p_rec.object_version_number
    ,layout_comp_definition_id       = p_rec.layout_comp_definition_id
    ,component_alias                 = p_rec.component_alias
    ,parent_bean                     = p_rec.parent_bean
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
        ,last_updated_by		     = fnd_global.user_id
    ,last_update_date		     = sysdate
    ,last_update_login	             = fnd_global.login_id

    where layout_component_id = p_rec.layout_component_id;
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
    hxc_ulc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hxc_ulc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hxc_ulc_shd.constraint_error
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
  (p_rec in hxc_ulc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin

  if g_debug then
  	l_proc := g_package||'pre_update';
  	hr_utility.set_location('Entering:'||l_proc, 5);
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
--   This private procedure contains any processing which is required after the
--   update dml.
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
  (p_rec                          in hxc_ulc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin

  if g_debug then
  	l_proc := g_package||'post_update';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    hxc_ulc_rku.after_update
      (p_layout_component_id
      => p_rec.layout_component_id
      ,p_layout_id
      => p_rec.layout_id
      ,p_parent_component_id
      => p_rec.parent_component_id
      ,p_component_name
      => p_rec.component_name
      ,p_component_value
      => p_rec.component_value
      ,p_sequence
      => p_rec.sequence
      ,p_name_value_string
      => p_rec.name_value_string
      ,p_region_code
      => p_rec.region_code
      ,p_region_code_app_id
      => p_rec.region_code_app_id
      ,p_attribute_code
      => p_rec.attribute_code
      ,p_attribute_code_app_id
      => p_rec.attribute_code_app_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_layout_comp_definition_id
      => p_rec.layout_comp_definition_id
      ,p_component_alias
      => p_rec.component_alias
      ,p_parent_bean
      => p_rec.parent_bean
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
      ,p_layout_id_o
      => hxc_ulc_shd.g_old_rec.layout_id
      ,p_parent_component_id_o
      => hxc_ulc_shd.g_old_rec.parent_component_id
      ,p_component_name_o
      => hxc_ulc_shd.g_old_rec.component_name
      ,p_component_value_o
      => hxc_ulc_shd.g_old_rec.component_value
      ,p_sequence_o
      => hxc_ulc_shd.g_old_rec.sequence
      ,p_name_value_string_o
      => hxc_ulc_shd.g_old_rec.name_value_string
      ,p_region_code_o
      => hxc_ulc_shd.g_old_rec.region_code
      ,p_region_code_app_id_o
      => hxc_ulc_shd.g_old_rec.region_code_app_id
      ,p_attribute_code_o
      => hxc_ulc_shd.g_old_rec.attribute_code
      ,p_attribute_code_app_id_o
      => hxc_ulc_shd.g_old_rec.attribute_code_app_id
      ,p_object_version_number_o
      => hxc_ulc_shd.g_old_rec.object_version_number
      ,p_layout_comp_definition_id_o
      => hxc_ulc_shd.g_old_rec.layout_comp_definition_id
      ,p_component_alias_o
      => hxc_ulc_shd.g_old_rec.component_alias
      ,p_parent_bean_o
      => hxc_ulc_shd.g_old_rec.parent_bean
      ,p_attribute1_o
      => hxc_ulc_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => hxc_ulc_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => hxc_ulc_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => hxc_ulc_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => hxc_ulc_shd.g_old_rec.attribute5
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_LAYOUT_COMPONENTS'
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
  (p_rec in out nocopy hxc_ulc_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.layout_id = hr_api.g_number) then
    p_rec.layout_id :=
    hxc_ulc_shd.g_old_rec.layout_id;
  End If;
  If (p_rec.layout_comp_definition_id = hr_api.g_number) then
    p_rec.layout_comp_definition_id :=
    hxc_ulc_shd.g_old_rec.layout_comp_definition_id;
  End If;
  If (p_rec.parent_component_id = hr_api.g_number) then
    p_rec.parent_component_id :=
    hxc_ulc_shd.g_old_rec.parent_component_id;
  End If;
  If (p_rec.component_name = hr_api.g_varchar2) then
    p_rec.component_name :=
    hxc_ulc_shd.g_old_rec.component_name;
  End If;
  If (p_rec.component_value = hr_api.g_varchar2) then
    p_rec.component_value :=
    hxc_ulc_shd.g_old_rec.component_value;
  End If;
  If (p_rec.sequence = hr_api.g_number) then
    p_rec.sequence :=
    hxc_ulc_shd.g_old_rec.sequence;
  End If;
  If (p_rec.name_value_string = hr_api.g_varchar2) then
    p_rec.name_value_string :=
    hxc_ulc_shd.g_old_rec.name_value_string;
  End If;
  If (p_rec.region_code = hr_api.g_varchar2) then
    p_rec.region_code :=
    hxc_ulc_shd.g_old_rec.region_code;
  End If;
  If (p_rec.region_code_app_id = hr_api.g_number) then
    p_rec.region_code_app_id :=
    hxc_ulc_shd.g_old_rec.region_code_app_id;
  End If;
  If (p_rec.attribute_code = hr_api.g_varchar2) then
    p_rec.attribute_code :=
    hxc_ulc_shd.g_old_rec.attribute_code;
  End If;
  If (p_rec.attribute_code_app_id = hr_api.g_number) then
    p_rec.attribute_code_app_id :=
    hxc_ulc_shd.g_old_rec.attribute_code_app_id;
  End If;
  If (p_rec.component_alias = hr_api.g_varchar2) then
    p_rec.component_alias :=
    hxc_ulc_shd.g_old_rec.component_alias;
  End If;
  If (p_rec.parent_bean = hr_api.g_varchar2) then
    p_rec.parent_bean :=
    hxc_ulc_shd.g_old_rec.parent_bean;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    hxc_ulc_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    hxc_ulc_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    hxc_ulc_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    hxc_ulc_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    hxc_ulc_shd.g_old_rec.attribute5;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hxc_ulc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'upd';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to update.
  --
  hxc_ulc_shd.lck
    (p_rec.layout_component_id
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
  hxc_ulc_bus.update_validate
     (p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  hxc_ulc_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hxc_ulc_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hxc_ulc_upd.post_update
     (p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_layout_component_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_layout_id                    in     number    default hr_api.g_number
  ,p_parent_component_id          in     number    default hr_api.g_number
  ,p_sequence                     in     number    default hr_api.g_number
  ,p_component_name               in     varchar2  default hr_api.g_varchar2
  ,p_component_value              in     varchar2  default hr_api.g_varchar2
  ,p_name_value_string            in     varchar2  default hr_api.g_varchar2
  ,p_region_code                  in     varchar2  default hr_api.g_varchar2
  ,p_region_code_app_id           in     number    default hr_api.g_number
  ,p_attribute_code               in     varchar2  default hr_api.g_varchar2
  ,p_attribute_code_app_id        in     number    default hr_api.g_number
  ,p_layout_comp_definition_id    in     number    default hr_api.g_number
  ,p_component_alias              in     varchar2  default hr_api.g_varchar2
  ,p_parent_bean                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  hxc_ulc_shd.g_rec_type;
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'upd';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hxc_ulc_shd.convert_args
  (p_layout_component_id
  ,p_layout_id
  ,p_parent_component_id
  ,p_component_name
  ,p_component_value
  ,p_sequence
  ,p_name_value_string
  ,p_region_code
  ,p_region_code_app_id
  ,p_attribute_code
  ,p_attribute_code_app_id
  ,p_object_version_number
  ,p_layout_comp_definition_id
  ,p_component_alias
  ,p_parent_bean
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hxc_ulc_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End upd;
--
end hxc_ulc_upd;

/
