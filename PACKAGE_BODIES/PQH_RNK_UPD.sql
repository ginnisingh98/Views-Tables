--------------------------------------------------------
--  DDL for Package Body PQH_RNK_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RNK_UPD" as
/* $Header: pqrnkrhi.pkb 120.1 2005/06/23 13:27 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package constant varchar2(33) := '  pqh_rnk_upd.';  -- Global package name
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
  (p_rec in out nocopy pqh_rnk_shd.g_rec_type
  ) is
--
  l_proc constant  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the pqh_rank_processes Row
  --
  update pqh_rank_processes
    set
     rank_process_id                 = p_rec.rank_process_id
    ,pgm_id                          = p_rec.pgm_id
    ,pl_id                           = p_rec.pl_id
    ,oipl_id                         = p_rec.oipl_id
    ,process_cd                      = p_rec.process_cd
    ,process_date                    = p_rec.process_date
    ,benefit_action_id               = p_rec.benefit_action_id
    ,person_id                       = p_rec.person_id
    ,assignment_id                   = p_rec.assignment_id
    ,total_score                     = p_rec.total_score
    ,object_version_number           = p_rec.object_version_number
    ,request_id                      = p_rec.request_id
    ,business_group_id               = p_rec.business_group_id
    ,per_in_ler_id                   = p_rec.per_in_ler_id
    where rank_process_id = p_rec.rank_process_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqh_rnk_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqh_rnk_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_rnk_shd.constraint_error
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
  (p_rec in pqh_rnk_shd.g_rec_type
  ) is
--
  l_proc constant  varchar2(72) := g_package||'pre_update';
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
  ,p_rec                          in pqh_rnk_shd.g_rec_type
  ) is
--
  l_proc constant  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_rnk_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_rank_process_id
      => p_rec.rank_process_id
      ,p_pgm_id
      => p_rec.pgm_id
      ,p_pl_id
      => p_rec.pl_id
      ,p_oipl_id
      => p_rec.oipl_id
      ,p_process_cd
      => p_rec.process_cd
      ,p_process_date
      => p_rec.process_date
      ,p_benefit_action_id
      => p_rec.benefit_action_id
      ,p_person_id
      => p_rec.person_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_total_score
      => p_rec.total_score
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_request_id
      => p_rec.request_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_per_in_ler_id
      => p_rec.per_in_ler_id
      ,p_pgm_id_o
      => pqh_rnk_shd.g_old_rec.pgm_id
      ,p_pl_id_o
      => pqh_rnk_shd.g_old_rec.pl_id
      ,p_oipl_id_o
      => pqh_rnk_shd.g_old_rec.oipl_id
      ,p_process_cd_o
      => pqh_rnk_shd.g_old_rec.process_cd
      ,p_process_date_o
      => pqh_rnk_shd.g_old_rec.process_date
      ,p_benefit_action_id_o
      => pqh_rnk_shd.g_old_rec.benefit_action_id
      ,p_person_id_o
      => pqh_rnk_shd.g_old_rec.person_id
      ,p_assignment_id_o
      => pqh_rnk_shd.g_old_rec.assignment_id
      ,p_total_score_o
      => pqh_rnk_shd.g_old_rec.total_score
      ,p_object_version_number_o
      => pqh_rnk_shd.g_old_rec.object_version_number
      ,p_request_id_o
      => pqh_rnk_shd.g_old_rec.request_id
      ,p_business_group_id_o
      => pqh_rnk_shd.g_old_rec.business_group_id
      ,p_per_in_ler_id_o
      => pqh_rnk_shd.g_old_rec.per_in_ler_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESSES'
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
  (p_rec in out nocopy pqh_rnk_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    pqh_rnk_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    pqh_rnk_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.oipl_id = hr_api.g_number) then
    p_rec.oipl_id :=
    pqh_rnk_shd.g_old_rec.oipl_id;
  End If;
  If (p_rec.process_cd = hr_api.g_varchar2) then
    p_rec.process_cd :=
    pqh_rnk_shd.g_old_rec.process_cd;
  End If;
  If (p_rec.process_date = hr_api.g_date) then
    p_rec.process_date :=
    pqh_rnk_shd.g_old_rec.process_date;
  End If;
  If (p_rec.benefit_action_id = hr_api.g_number) then
    p_rec.benefit_action_id :=
    pqh_rnk_shd.g_old_rec.benefit_action_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    pqh_rnk_shd.g_old_rec.person_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pqh_rnk_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.total_score = hr_api.g_number) then
    p_rec.total_score :=
    pqh_rnk_shd.g_old_rec.total_score;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    pqh_rnk_shd.g_old_rec.request_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqh_rnk_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.per_in_ler_id = hr_api.g_number) then
    p_rec.per_in_ler_id :=
    pqh_rnk_shd.g_old_rec.per_in_ler_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqh_rnk_shd.g_rec_type
  ) is
--
  l_proc constant  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_rnk_shd.lck
    (p_rec.rank_process_id
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
  pqh_rnk_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqh_rnk_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqh_rnk_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqh_rnk_upd.post_update
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
  ,p_rank_process_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_process_date                 in     date      default hr_api.g_date
  ,p_pgm_id                       in     number    default hr_api.g_number
  ,p_pl_id                        in     number    default hr_api.g_number
  ,p_oipl_id                      in     number    default hr_api.g_number
  ,p_process_cd                   in     varchar2  default hr_api.g_varchar2
  ,p_benefit_action_id            in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_total_score                  in     number    default hr_api.g_number
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_per_in_ler_id                in     number    default hr_api.g_number
  ) is
--
  l_rec   pqh_rnk_shd.g_rec_type;
  l_proc constant  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_rnk_shd.convert_args
  (p_rank_process_id
  ,p_pgm_id
  ,p_pl_id
  ,p_oipl_id
  ,p_process_cd
  ,p_process_date
  ,p_benefit_action_id
  ,p_person_id
  ,p_assignment_id
  ,p_total_score
  ,p_object_version_number
  ,p_request_id
  ,p_business_group_id
  ,p_per_in_ler_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_rnk_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_rnk_upd;

/
