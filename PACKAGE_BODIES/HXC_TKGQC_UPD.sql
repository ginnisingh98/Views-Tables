--------------------------------------------------------
--  DDL for Package Body HXC_TKGQC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TKGQC_UPD" as
/* $Header: hxctkgqcrhi.pkb 120.2 2005/09/23 05:26:07 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_tkgqc_upd.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy hxc_tkgqc_shd.g_rec_type
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
  hxc_tkgqc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the hxc_tk_group_query_criteria Row
  --
  update hxc_tk_group_query_criteria
    set
     tk_group_query_criteria_id      = p_rec.tk_group_query_criteria_id
    ,tk_group_query_id               = p_rec.tk_group_query_id
    ,criteria_type                   = p_rec.criteria_type
    ,criteria_id                     = p_rec.criteria_id
    ,object_version_number           = p_rec.object_version_number
        ,last_updated_by		     = fnd_global.user_id
    ,last_update_date		     = sysdate
    ,last_update_login	             = fnd_global.login_id

    where tk_group_query_criteria_id = p_rec.tk_group_query_criteria_id;
  --
  hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_tkgqc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_tkgqc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_tkgqc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in hxc_tkgqc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin

  if g_debug then
	l_proc := g_package||'pre_update';

	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_rec                          in hxc_tkgqc_shd.g_rec_type
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
    hxc_tkgqc_rku.after_update
      (p_tk_group_query_criteria_id
      => p_rec.tk_group_query_criteria_id
      ,p_tk_group_query_id
      => p_rec.tk_group_query_id
      ,p_criteria_type
      => p_rec.criteria_type
      ,p_criteria_id
      => p_rec.criteria_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_tk_group_query_id_o
      => hxc_tkgqc_shd.g_old_rec.tk_group_query_id
      ,p_criteria_type_o
      => hxc_tkgqc_shd.g_old_rec.criteria_type
      ,p_criteria_id_o
      => hxc_tkgqc_shd.g_old_rec.criteria_id
      ,p_object_version_number_o
      => hxc_tkgqc_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_TK_GROUP_QUERY_CRITERIA'
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
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy hxc_tkgqc_shd.g_rec_type
  ) is
--
Begin

  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.tk_group_query_id = hr_api.g_number) then
    p_rec.tk_group_query_id :=
    hxc_tkgqc_shd.g_old_rec.tk_group_query_id;
  End If;
  If (p_rec.criteria_type = hr_api.g_varchar2) then
    p_rec.criteria_type :=
    hxc_tkgqc_shd.g_old_rec.criteria_type;
  End If;
  If (p_rec.criteria_id = hr_api.g_number) then
    p_rec.criteria_id :=
    hxc_tkgqc_shd.g_old_rec.criteria_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hxc_tkgqc_shd.g_rec_type
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
  hxc_tkgqc_shd.lck
    (p_rec.tk_group_query_criteria_id
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
  hxc_tkgqc_bus.update_validate
     (p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  hxc_tkgqc_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hxc_tkgqc_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hxc_tkgqc_upd.post_update
     (p_rec
     );
  --
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_tk_group_query_criteria_id   in     number
  ,p_object_version_number        in out nocopy number
  ,p_tk_group_query_id            in     number    default hr_api.g_number
  ,p_criteria_type                in     varchar2  default hr_api.g_varchar2
  ,p_criteria_id                  in     number    default hr_api.g_number
  ) is
--
  l_rec   hxc_tkgqc_shd.g_rec_type;
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
  hxc_tkgqc_shd.convert_args
  (p_tk_group_query_criteria_id
  ,p_tk_group_query_id
  ,p_criteria_type
  ,p_criteria_id
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hxc_tkgqc_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End upd;
--
end hxc_tkgqc_upd;

/
