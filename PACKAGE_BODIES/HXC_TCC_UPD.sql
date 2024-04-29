--------------------------------------------------------
--  DDL for Package Body HXC_TCC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TCC_UPD" as
/* $Header: hxctccrhi.pkb 120.3 2006/07/07 06:27:47 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_tcc_upd.';  -- Global package name

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
  (p_rec in out nocopy hxc_tcc_shd.g_rec_type
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
  hxc_tcc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the hxc_time_category_comps Row
  --
  update hxc_time_category_comps
    set
       time_category_id     = p_rec.time_category_id
      ,ref_time_category_id = p_rec.ref_time_category_id
      ,component_type_id    = p_rec.component_type_id
      ,flex_value_set_id    = p_rec.flex_value_set_id
      ,value_id             = p_rec.value_id
      ,is_null              = p_rec.is_null
      ,equal_to             = p_rec.equal_to
      ,type                 = p_rec.type
      ,object_version_number= p_rec.object_version_number
      ,last_updated_by		     = fnd_global.user_id
    ,last_update_date		     = sysdate
    ,last_update_login	             = fnd_global.login_id

    where time_category_comp_id = p_rec.time_category_comp_id;

  hxc_tcc_shd.g_api_dml := false;   -- Unset the api dml status

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hxc_tcc_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_tcc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    hxc_tcc_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_tcc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hxc_tcc_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_tcc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hxc_tcc_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in hxc_tcc_shd.g_rec_type
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
  (p_rec                          in hxc_tcc_shd.g_rec_type
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

    hxc_tcc_rku.after_update (
     p_time_category_comp_id  => p_rec.time_category_comp_id
    ,p_time_category_id       => p_rec.time_category_id
    ,p_ref_time_category_id   => p_rec.ref_time_category_id
    ,p_component_type_id      => p_rec.component_type_id
    ,p_flex_value_set_id      => p_rec.flex_value_set_id
    ,p_value_id               => p_rec.value_id
    ,p_is_null                => p_rec.is_null
    ,p_equal_to               => p_rec.equal_to
    ,p_type                   => p_rec.type
    ,p_object_version_number  => p_rec.object_version_number
    ,p_time_category_comp_id_o=> hxc_tcc_shd.g_old_rec.time_category_comp_id
    ,p_time_category_id_o     => hxc_tcc_shd.g_old_rec.time_category_id
    ,p_ref_time_category_id_o => hxc_tcc_shd.g_old_rec.ref_time_category_id
    ,p_component_type_id_o    => hxc_tcc_shd.g_old_rec.component_type_id
    ,p_flex_value_set_id_o    => hxc_tcc_shd.g_old_rec.flex_value_set_id
    ,p_value_id_o             => hxc_tcc_shd.g_old_rec.value_id
    ,p_is_null_o              => hxc_tcc_shd.g_old_rec.is_null
    ,p_equal_to_o             => hxc_tcc_shd.g_old_rec.equal_to
    ,p_type_o                 => hxc_tcc_shd.g_old_rec.type
    ,p_object_version_number_o=> hxc_tcc_shd.g_old_rec.object_version_number );

  exception

    when hr_api.cannot_find_prog_unit then

      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_TIME_CATEGORY_COMPS'
        ,p_hook_type   => 'AU');

  end;

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
  (p_rec in out nocopy hxc_tcc_shd.g_rec_type
  ) is
--
Begin

  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.

  If (p_rec.time_category_id = hr_api.g_number) then
      p_rec.time_category_id := hxc_tcc_shd.g_old_rec.time_category_id;
  End If;

  If (p_rec.ref_time_category_id = hr_api.g_number) then
      p_rec.ref_time_category_id := hxc_tcc_shd.g_old_rec.ref_time_category_id;
  End If;

  If (p_rec.component_type_id = hr_api.g_number) then
      p_rec.component_type_id := hxc_tcc_shd.g_old_rec.component_type_id;
  End If;

  If (p_rec.flex_value_set_id = hr_api.g_number) then
      p_rec.flex_value_set_id := hxc_tcc_shd.g_old_rec.flex_value_set_id;
  End If;

  If (p_rec.value_id = hr_api.g_varchar2) then
      p_rec.value_id := hxc_tcc_shd.g_old_rec.value_id;
  End If;

  If (p_rec.is_null = hr_api.g_varchar2) then
      p_rec.is_null := hxc_tcc_shd.g_old_rec.is_null;
  End If;

  If (p_rec.equal_to = hr_api.g_varchar2) then
      p_rec.equal_to := hxc_tcc_shd.g_old_rec.equal_to;
  End If;

  If (p_rec.type = hr_api.g_varchar2) then
      p_rec.type := hxc_tcc_shd.g_old_rec.type;
  End If;

End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hxc_tcc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);

  l_sql_string CLOB; -- not used, needed for caching strategy which
                     -- reuses update_time_cat...
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'upd';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to update.
  --
  hxc_tcc_shd.lck
    (p_rec.time_category_comp_id
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
  hxc_tcc_bus.update_validate
     (p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  hxc_tcc_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hxc_tcc_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hxc_tcc_upd.post_update
     (p_rec
     );

  IF ( p_rec.type IN ( 'AN', 'MC_VS' ) )
  THEN
	hxc_time_category_utils_pkg.update_time_category_comp_sql ( p_rec );

  END IF;

  IF ( p_rec.type = 'MC' OR hxc_tcc_shd.g_old_rec.type = 'MC' )
  THEN
        hxc_time_category_api.set_dynamic_sql_string ( p_time_category_id => p_rec.time_category_id );

  END IF;

End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
   p_time_category_comp_id        in number
  ,p_time_category_id             in number
  ,p_object_version_number        in out nocopy number
  ,p_ref_time_category_id         in number default hr_api.g_number
  ,p_component_type_id            in number default hr_api.g_number
  ,p_flex_value_set_id            in number default hr_api.g_number
  ,p_value_id                     in varchar2 default hr_api.g_varchar2
  ,p_is_null                      in varchar2 default hr_api.g_varchar2
  ,p_equal_to                     in varchar2 default hr_api.g_varchar2
  ,p_type                         in varchar2 default hr_api.g_varchar2
  ) is
--
  l_rec	  hxc_tcc_shd.g_rec_type;
  l_proc  varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'upd';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- Call conversion function to turn arguments into the
  -- l_rec structure.

  l_rec :=
  hxc_tcc_shd.convert_args (
   p_time_category_comp_id
  ,p_time_category_id
  ,p_ref_time_category_id
  ,p_component_type_id
  ,p_flex_value_set_id
  ,p_value_id
  ,p_is_null
  ,p_equal_to
  ,p_type
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hxc_tcc_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End upd;
--
end hxc_tcc_upd;

/
