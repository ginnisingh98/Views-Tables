--------------------------------------------------------
--  DDL for Package Body PER_PSE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PSE_UPD" as
/* $Header: pepserhi.pkb 120.0.12010000.2 2008/08/06 09:29:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pse_upd.';  -- Global package name
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
  (p_rec in out nocopy per_pse_shd.g_rec_type
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
  per_pse_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_pos_structure_elements Row
  --
  update per_pos_structure_elements
    set
     pos_structure_element_id        = p_rec.pos_structure_element_id
    ,business_group_id               = p_rec.business_group_id
    ,pos_structure_version_id        = p_rec.pos_structure_version_id
    ,subordinate_position_id         = p_rec.subordinate_position_id
    ,parent_position_id              = p_rec.parent_position_id
    ,request_id                      = p_rec.request_id
    ,program_application_id          = p_rec.program_application_id
    ,program_id                      = p_rec.program_id
    ,program_update_date             = p_rec.program_update_date
    ,object_version_number           = p_rec.object_version_number
    where pos_structure_element_id = p_rec.pos_structure_element_id;
  --
  per_pse_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_pse_shd.g_api_dml := false;   -- Unset the api dml status
    per_pse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_pse_shd.g_api_dml := false;   -- Unset the api dml status
    per_pse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_pse_shd.g_api_dml := false;   -- Unset the api dml status
    per_pse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_pse_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in per_pse_shd.g_rec_type
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
  (p_rec                          in per_pse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pse_rku.after_update
      (p_pos_structure_element_id
      => p_rec.pos_structure_element_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_pos_structure_version_id
      => p_rec.pos_structure_version_id
      ,p_subordinate_position_id
      => p_rec.subordinate_position_id
      ,p_parent_position_id
      => p_rec.parent_position_id
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_business_group_id_o
      => per_pse_shd.g_old_rec.business_group_id
      ,p_pos_structure_version_id_o
      => per_pse_shd.g_old_rec.pos_structure_version_id
      ,p_subordinate_position_id_o
      => per_pse_shd.g_old_rec.subordinate_position_id
      ,p_parent_position_id_o
      => per_pse_shd.g_old_rec.parent_position_id
      ,p_request_id_o
      => per_pse_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_pse_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_pse_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_pse_shd.g_old_rec.program_update_date
      ,p_object_version_number_o
      => per_pse_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_POS_STRUCTURE_ELEMENTS'
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
  (p_rec in out nocopy per_pse_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_pse_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.pos_structure_version_id = hr_api.g_number) then
    p_rec.pos_structure_version_id :=
    per_pse_shd.g_old_rec.pos_structure_version_id;
  End If;
  If (p_rec.subordinate_position_id = hr_api.g_number) then
    p_rec.subordinate_position_id :=
    per_pse_shd.g_old_rec.subordinate_position_id;
  End If;
  If (p_rec.parent_position_id = hr_api.g_number) then
    p_rec.parent_position_id :=
    per_pse_shd.g_old_rec.parent_position_id;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_pse_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_pse_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_pse_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_pse_shd.g_old_rec.program_update_date;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy per_pse_shd.g_rec_type
  ,p_effective_date               in date
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';

  --Bug no 3888749 starts here
  l_old_parent_pos_id	per_pos_structure_elements.PARENT_POSITION_ID%type;
  l_new_parent_pos_id	per_pos_structure_elements.PARENT_POSITION_ID%type;
  l_myexception		Exception;
  --Bug no 3888749 ends here
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_pse_shd.lck
    (p_rec.pos_structure_element_id
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
  per_pse_bus.update_validate
     (p_rec
     ,p_effective_date
     );

  --Bug no 3888749 starts here
  select PARENT_POSITION_ID into l_old_parent_pos_id from per_pos_structure_elements x
  where POS_STRUCTURE_VERSION_ID = p_rec.pos_structure_version_id
  and not exists (select null from per_pos_structure_elements
  where SUBORDINATE_POSITION_ID = x.PARENT_POSITION_ID)
  and rownum=1;
  --Bug no 3888749 ends here

  --
  -- Call the supporting pre-update operation
  --
  per_pse_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_pse_upd.update_dml(p_rec);

/* Bug no 3888749 starts here

  Putting extra check on Top Node in the Position hierarchy so that it can not be updated.*/

  select PARENT_POSITION_ID into l_new_parent_pos_id from per_pos_structure_elements x
  where POS_STRUCTURE_VERSION_ID = p_rec.pos_structure_version_id
  and not exists (select null from per_pos_structure_elements
  where SUBORDINATE_POSITION_ID = x.PARENT_POSITION_ID)
  and rownum=1;

  hr_utility.set_location('old_parent_id '||l_old_parent_pos_id||'new_parent_id '||l_new_parent_pos_id,10);

 if (l_old_parent_pos_id<>l_new_parent_pos_id) then
	raise l_myexception;
 end if;

--Bug no 3888749 starts here

--
  -- Call the supporting post-update operation
  --
  per_pse_upd.post_update
     (p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_pos_structure_element_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_pos_structure_version_id     in     number    default hr_api.g_number
  ,p_subordinate_position_id      in     number    default hr_api.g_number
  ,p_parent_position_id           in     number    default hr_api.g_number
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ) is
--
  l_rec	  per_pse_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pse_shd.convert_args
  (p_pos_structure_element_id
  ,p_business_group_id
  ,p_pos_structure_version_id
  ,p_subordinate_position_id
  ,p_parent_position_id
  ,p_request_id
  ,p_program_application_id
  ,p_program_id
  ,p_program_update_date
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_pse_upd.upd
     (l_rec
     ,p_effective_date
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_pse_upd;

/
