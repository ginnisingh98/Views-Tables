--------------------------------------------------------
--  DDL for Package Body HXC_ULP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ULP_UPD" as
/* $Header: hxculprhi.pkb 120.2 2005/09/23 09:52:13 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ulp_upd.';  -- Global package name
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
  (p_rec in out nocopy hxc_ulp_shd.g_rec_type
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
  -- Update the hxc_layout_comp_prompts Row
  --
  update hxc_layout_comp_prompts
    set
     layout_comp_prompt_id           = p_rec.layout_comp_prompt_id
    ,layout_component_id             = p_rec.layout_component_id
    ,prompt_alias                    = p_rec.prompt_alias
    ,prompt_type                     = p_rec.prompt_type
    ,region_code                     = p_rec.region_code
    ,region_application_id           = p_rec.region_application_id
    ,attribute_code                  = p_rec.attribute_code
    ,attribute_application_id        = p_rec.attribute_application_id
    ,object_version_number           = p_rec.object_version_number
        ,last_updated_by		     = fnd_global.user_id
    ,last_update_date		     = sysdate
    ,last_update_login	             = fnd_global.login_id

    where layout_comp_prompt_id = p_rec.layout_comp_prompt_id;
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
    hxc_ulp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hxc_ulp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hxc_ulp_shd.constraint_error
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
  (p_rec in hxc_ulp_shd.g_rec_type
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
  (p_rec                          in hxc_ulp_shd.g_rec_type
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
    hxc_ulp_rku.after_update
      (p_layout_comp_prompt_id
      => p_rec.layout_comp_prompt_id
      ,p_layout_component_id
      => p_rec.layout_component_id
      ,p_prompt_alias
      => p_rec.prompt_alias
      ,p_prompt_type
      => p_rec.prompt_type
      ,p_region_code
      => p_rec.region_code
      ,p_region_application_id
      => p_rec.region_application_id
      ,p_attribute_code
      => p_rec.attribute_code
      ,p_attribute_application_id
      => p_rec.attribute_application_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_layout_component_id_o
      => hxc_ulp_shd.g_old_rec.layout_component_id
      ,p_prompt_alias_o
      => hxc_ulp_shd.g_old_rec.prompt_alias
      ,p_prompt_type_o
      => hxc_ulp_shd.g_old_rec.prompt_type
      ,p_region_code_o
      => hxc_ulp_shd.g_old_rec.region_code
      ,p_region_application_id_o
      => hxc_ulp_shd.g_old_rec.region_application_id
      ,p_attribute_code_o
      => hxc_ulp_shd.g_old_rec.attribute_code
      ,p_attribute_application_id_o
      => hxc_ulp_shd.g_old_rec.attribute_application_id
      ,p_object_version_number_o
      => hxc_ulp_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_LAYOUT_COMP_PROMPTS'
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
  (p_rec in out nocopy hxc_ulp_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.layout_component_id = hr_api.g_number) then
    p_rec.layout_component_id :=
    hxc_ulp_shd.g_old_rec.layout_component_id;
  End If;
  If (p_rec.prompt_alias = hr_api.g_varchar2) then
    p_rec.prompt_alias :=
    hxc_ulp_shd.g_old_rec.prompt_alias;
  End If;
  If (p_rec.prompt_type = hr_api.g_varchar2) then
    p_rec.prompt_type :=
    hxc_ulp_shd.g_old_rec.prompt_type;
  End If;
  If (p_rec.region_code = hr_api.g_varchar2) then
    p_rec.region_code :=
    hxc_ulp_shd.g_old_rec.region_code;
  End If;
  If (p_rec.region_application_id = hr_api.g_number) then
    p_rec.region_application_id :=
    hxc_ulp_shd.g_old_rec.region_application_id;
  End If;
  If (p_rec.attribute_code = hr_api.g_varchar2) then
    p_rec.attribute_code :=
    hxc_ulp_shd.g_old_rec.attribute_code;
  End If;
  If (p_rec.attribute_application_id = hr_api.g_number) then
    p_rec.attribute_application_id :=
    hxc_ulp_shd.g_old_rec.attribute_application_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hxc_ulp_shd.g_rec_type
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
  hxc_ulp_shd.lck
    (p_rec.layout_comp_prompt_id
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
  hxc_ulp_bus.update_validate
     (p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  hxc_ulp_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hxc_ulp_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hxc_ulp_upd.post_update
     (p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_layout_comp_prompt_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_layout_component_id          in     number    default hr_api.g_number
  ,p_prompt_alias                 in     varchar2  default hr_api.g_varchar2
  ,p_prompt_type                  in     varchar2  default hr_api.g_varchar2
  ,p_region_code                  in     varchar2  default hr_api.g_varchar2
  ,p_region_application_id        in     number    default hr_api.g_number
  ,p_attribute_code               in     varchar2  default hr_api.g_varchar2
  ,p_attribute_application_id     in     number    default hr_api.g_number
  ) is
--
  l_rec	  hxc_ulp_shd.g_rec_type;
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
  hxc_ulp_shd.convert_args
  (p_layout_comp_prompt_id
  ,p_layout_component_id
  ,p_prompt_alias
  ,p_prompt_type
  ,p_region_code
  ,p_region_application_id
  ,p_attribute_code
  ,p_attribute_application_id
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hxc_ulp_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End upd;
--
end hxc_ulp_upd;

/