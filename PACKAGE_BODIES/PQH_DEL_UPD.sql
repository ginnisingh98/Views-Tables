--------------------------------------------------------
--  DDL for Package Body PQH_DEL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DEL_UPD" as
/* $Header: pqdelrhi.pkb 115.7 2002/12/05 19:31:43 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_del_upd.';  -- Global package name
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
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
Procedure update_dml(p_rec in out nocopy pqh_del_shd.g_rec_type) is
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
  --
  -- Update the pqh_dflt_budget_elements Row
  --
  update pqh_dflt_budget_elements
  set
  dflt_budget_element_id            = p_rec.dflt_budget_element_id,
  dflt_budget_set_id                = p_rec.dflt_budget_set_id,
  element_type_id                   = p_rec.element_type_id,
  dflt_dist_percentage              = p_rec.dflt_dist_percentage,
  object_version_number             = p_rec.object_version_number
  where dflt_budget_element_id = p_rec.dflt_budget_element_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_del_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_del_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_del_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in pqh_del_shd.g_rec_type) is
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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in pqh_del_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
-- check if sum of percentage is more then 100 after the update
--
l_sum       number(15,2) := 0;

 cursor csr_element(p_dflt_budget_set_id in number) is
 select SUM(NVL(dflt_dist_percentage,0))
 from pqh_dflt_budget_elements
 where dflt_budget_set_id = p_dflt_budget_set_id;


--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  open csr_element(p_dflt_budget_set_id      => p_rec.dflt_budget_set_id );
   fetch csr_element into l_sum;
  close csr_element;

   if l_sum > 100 then
     -- sum cannot be more then 100
     --
      hr_utility.set_message(8302,'PQH_WKS_INVALID_ELMNT_SUM');
      hr_utility.raise_error;
    --
   end if;
  --
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    pqh_del_rku.after_update
      (
  p_dflt_budget_element_id        =>p_rec.dflt_budget_element_id
 ,p_dflt_budget_set_id            =>p_rec.dflt_budget_set_id
 ,p_element_type_id               =>p_rec.element_type_id
 ,p_dflt_dist_percentage          =>p_rec.dflt_dist_percentage
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_dflt_budget_set_id_o          =>pqh_del_shd.g_old_rec.dflt_budget_set_id
 ,p_element_type_id_o             =>pqh_del_shd.g_old_rec.element_type_id
 ,p_dflt_dist_percentage_o        =>pqh_del_shd.g_old_rec.dflt_dist_percentage
 ,p_object_version_number_o       =>pqh_del_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_dflt_budget_elements'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy pqh_del_shd.g_rec_type) is
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
  If (p_rec.dflt_budget_set_id = hr_api.g_number) then
    p_rec.dflt_budget_set_id :=
    pqh_del_shd.g_old_rec.dflt_budget_set_id;
  End If;
  If (p_rec.element_type_id = hr_api.g_number) then
    p_rec.element_type_id :=
    pqh_del_shd.g_old_rec.element_type_id;
  End If;
  If (p_rec.dflt_dist_percentage = hr_api.g_number) then
    p_rec.dflt_dist_percentage :=
    pqh_del_shd.g_old_rec.dflt_dist_percentage;
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
  p_rec        in out nocopy pqh_del_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_del_shd.lck
	(
	p_rec.dflt_budget_element_id,
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
  pqh_del_bus.update_validate(p_rec);
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
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_dflt_budget_element_id       in number,
  p_dflt_budget_set_id           in number           default hr_api.g_number,
  p_element_type_id              in number           default hr_api.g_number,
  p_dflt_dist_percentage         in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  pqh_del_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_del_shd.convert_args
  (
  p_dflt_budget_element_id,
  p_dflt_budget_set_id,
  p_element_type_id,
  p_dflt_dist_percentage,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_del_upd;

/
