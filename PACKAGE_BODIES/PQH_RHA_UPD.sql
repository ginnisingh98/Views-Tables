--------------------------------------------------------
--  DDL for Package Body PQH_RHA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RHA_UPD" as
/* $Header: pqrharhi.pkb 120.1 2005/08/03 13:43:25 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rha_upd.';  -- Global package name
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
  (p_rec in out nocopy pqh_rha_shd.g_rec_type
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
  -- Update the pqh_routing_hist_attribs Row
  --
  update pqh_routing_hist_attribs
    set
     routing_hist_attrib_id          = p_rec.routing_hist_attrib_id
    ,routing_history_id              = p_rec.routing_history_id
    ,attribute_id                    = p_rec.attribute_id
    ,from_char                       = p_rec.from_char
    ,from_date                       = p_rec.from_date
    ,from_number                     = p_rec.from_number
    ,to_char                         = p_rec.to_char
    ,to_date                         = p_rec.to_date
    ,to_number                       = p_rec.to_number
    ,object_version_number           = p_rec.object_version_number
    ,range_type_cd                   = p_rec.range_type_cd
    ,value_date                      = p_rec.value_date
    ,value_number                    = p_rec.value_number
    ,value_char                      = p_rec.value_char
    where routing_hist_attrib_id = p_rec.routing_hist_attrib_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqh_rha_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqh_rha_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_rha_shd.constraint_error
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
  (p_rec in pqh_rha_shd.g_rec_type
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
  (p_effective_date               in date
  ,p_rec                          in pqh_rha_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_rha_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_routing_hist_attrib_id
      => p_rec.routing_hist_attrib_id
      ,p_routing_history_id
      => p_rec.routing_history_id
      ,p_attribute_id
      => p_rec.attribute_id
      ,p_from_char
      => p_rec.from_char
      ,p_from_date
      => p_rec.from_date
      ,p_from_number
      => p_rec.from_number
      ,p_to_char
      => p_rec.to_char
      ,p_to_date
      => p_rec.to_date
      ,p_to_number
      => p_rec.to_number
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_range_type_cd
      => p_rec.range_type_cd
      ,p_value_date
      => p_rec.value_date
      ,p_value_number
      => p_rec.value_number
      ,p_value_char
      => p_rec.value_char
      ,p_routing_history_id_o
      => pqh_rha_shd.g_old_rec.routing_history_id
      ,p_attribute_id_o
      => pqh_rha_shd.g_old_rec.attribute_id
      ,p_from_char_o
      => pqh_rha_shd.g_old_rec.from_char
      ,p_from_date_o
      => pqh_rha_shd.g_old_rec.from_date
      ,p_from_number_o
      => pqh_rha_shd.g_old_rec.from_number
      ,p_to_char_o
      => pqh_rha_shd.g_old_rec.to_char
      ,p_to_date_o
      => pqh_rha_shd.g_old_rec.to_date
      ,p_to_number_o
      => pqh_rha_shd.g_old_rec.to_number
      ,p_object_version_number_o
      => pqh_rha_shd.g_old_rec.object_version_number
      ,p_range_type_cd_o
      => pqh_rha_shd.g_old_rec.range_type_cd
      ,p_value_date_o
      => pqh_rha_shd.g_old_rec.value_date
      ,p_value_number_o
      => pqh_rha_shd.g_old_rec.value_number
      ,p_value_char_o
      => pqh_rha_shd.g_old_rec.value_char
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_ROUTING_HIST_ATTRIBS'
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
  (p_rec in out nocopy pqh_rha_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.routing_history_id = hr_api.g_number) then
    p_rec.routing_history_id :=
    pqh_rha_shd.g_old_rec.routing_history_id;
  End If;
  If (p_rec.attribute_id = hr_api.g_number) then
    p_rec.attribute_id :=
    pqh_rha_shd.g_old_rec.attribute_id;
  End If;
  If (p_rec.from_char = hr_api.g_varchar2) then
    p_rec.from_char :=
    pqh_rha_shd.g_old_rec.from_char;
  End If;
  If (p_rec.from_date = hr_api.g_date) then
    p_rec.from_date :=
    pqh_rha_shd.g_old_rec.from_date;
  End If;
  If (p_rec.from_number = hr_api.g_number) then
    p_rec.from_number :=
    pqh_rha_shd.g_old_rec.from_number;
  End If;
  If (p_rec.to_char = hr_api.g_varchar2) then
    p_rec.to_char :=
    pqh_rha_shd.g_old_rec.to_char;
  End If;
  If (p_rec.to_date = hr_api.g_date) then
    p_rec.to_date :=
    pqh_rha_shd.g_old_rec.to_date;
  End If;
  If (p_rec.to_number = hr_api.g_number) then
    p_rec.to_number :=
    pqh_rha_shd.g_old_rec.to_number;
  End If;
  If (p_rec.range_type_cd = hr_api.g_varchar2) then
    p_rec.range_type_cd :=
    pqh_rha_shd.g_old_rec.range_type_cd;
  End If;
  If (p_rec.value_date = hr_api.g_date) then
    p_rec.value_date :=
    pqh_rha_shd.g_old_rec.value_date;
  End If;
  If (p_rec.value_number = hr_api.g_number) then
    p_rec.value_number :=
    pqh_rha_shd.g_old_rec.value_number;
  End If;
  If (p_rec.value_char = hr_api.g_varchar2) then
    p_rec.value_char :=
    pqh_rha_shd.g_old_rec.value_char;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqh_rha_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_rha_shd.lck
    (p_rec.routing_hist_attrib_id
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
  pqh_rha_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  pqh_rha_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqh_rha_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqh_rha_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_routing_hist_attrib_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_routing_history_id           in     number    default hr_api.g_number
  ,p_attribute_id                 in     number    default hr_api.g_number
  ,p_from_char                    in     varchar2  default hr_api.g_varchar2
  ,p_from_date                    in     date      default hr_api.g_date
  ,p_from_number                  in     number    default hr_api.g_number
  ,p_to_char                      in     varchar2  default hr_api.g_varchar2
  ,p_to_date                      in     date      default hr_api.g_date
  ,p_to_number                    in     number    default hr_api.g_number
  ,p_range_type_cd                in     varchar2  default hr_api.g_varchar2
  ,p_value_date                   in     date      default hr_api.g_date
  ,p_value_number                 in     number    default hr_api.g_number
  ,p_value_char                   in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  pqh_rha_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_rha_shd.convert_args
  (p_routing_hist_attrib_id
  ,p_routing_history_id
  ,p_attribute_id
  ,p_from_char
  ,p_from_date
  ,p_from_number
  ,p_to_char
  ,p_to_date
  ,p_to_number
  ,p_object_version_number
  ,p_range_type_cd
  ,p_value_date
  ,p_value_number
  ,p_value_char
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_rha_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_rha_upd;

/
