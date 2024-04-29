--------------------------------------------------------
--  DDL for Package Body PQH_STS_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_STS_DEL" as
/* $Header: pqstsrhi.pkb 120.0 2005/05/29 02:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_sts_del.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec in pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
if g_debug then
   --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;

  --
  --
  --
  -- Delete the pqh_fr_stat_situations row.
  --
  delete from pqh_fr_stat_situations
  where statutory_situation_id = p_rec.statutory_situation_id;
  --
  --
  --
  if g_debug then
   --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    pqh_sts_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in pqh_sts_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
 if g_debug then
   --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;

End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in pqh_sts_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
   --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;
  begin
    --
    pqh_sts_rkd.after_delete
      (p_statutory_situation_id
      => p_rec.statutory_situation_id
      ,p_business_group_id_o
      => pqh_sts_shd.g_old_rec.business_group_id
      ,p_situation_name_o
      => pqh_sts_shd.g_old_rec.situation_name
      ,p_type_of_ps_o
      => pqh_sts_shd.g_old_rec.type_of_ps
      ,p_situation_type_o
      => pqh_sts_shd.g_old_rec.situation_type
      ,p_sub_type_o
      => pqh_sts_shd.g_old_rec.sub_type
      ,p_source_o
      => pqh_sts_shd.g_old_rec.source
      ,p_location_o
      => pqh_sts_shd.g_old_rec.location
      ,p_reason_o
      => pqh_sts_shd.g_old_rec.reason
      ,p_is_default_o
      => pqh_sts_shd.g_old_rec.is_default
      ,p_date_from_o
      => pqh_sts_shd.g_old_rec.date_from
      ,p_date_to_o
      => pqh_sts_shd.g_old_rec.date_to
      ,p_request_type_o
      => pqh_sts_shd.g_old_rec.request_type
      ,p_employee_agreement_needed_o
      => pqh_sts_shd.g_old_rec.employee_agreement_needed
      ,p_manager_agreement_needed_o
      => pqh_sts_shd.g_old_rec.manager_agreement_needed
      ,p_print_arrette_o
      => pqh_sts_shd.g_old_rec.print_arrette
      ,p_reserve_position_o
      => pqh_sts_shd.g_old_rec.reserve_position
      ,p_allow_progressions_o
      => pqh_sts_shd.g_old_rec.allow_progressions
      ,p_extend_probation_period_o
      => pqh_sts_shd.g_old_rec.extend_probation_period
      ,p_remuneration_paid_o
      => pqh_sts_shd.g_old_rec.remuneration_paid
      ,p_pay_share_o
      => pqh_sts_shd.g_old_rec.pay_share
      ,p_pay_periods_o
      => pqh_sts_shd.g_old_rec.pay_periods
      ,p_frequency_o
      => pqh_sts_shd.g_old_rec.frequency
      ,p_first_period_max_duration_o
      => pqh_sts_shd.g_old_rec.first_period_max_duration
      ,p_min_duration_per_request_o
      => pqh_sts_shd.g_old_rec.min_duration_per_request
      ,p_max_duration_per_request_o
      => pqh_sts_shd.g_old_rec.max_duration_per_request
      ,p_max_duration_whole_career_o
      => pqh_sts_shd.g_old_rec.max_duration_whole_career
      ,p_renewable_allowed_o
      => pqh_sts_shd.g_old_rec.renewable_allowed
      ,p_max_no_of_renewals_o
      => pqh_sts_shd.g_old_rec.max_no_of_renewals
      ,p_max_duration_per_renewal_o
      => pqh_sts_shd.g_old_rec.max_duration_per_renewal
      ,p_max_tot_continuous_duratio_o
      => pqh_sts_shd.g_old_rec.max_tot_continuous_duration
      ,p_object_version_number_o
      => pqh_sts_shd.g_old_rec.object_version_number
      ,p_remunerate_assign_stat_id_o
      => pqh_sts_shd.g_old_rec.remunerate_assign_status_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_STAT_SITUATIONS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  if g_debug then
   --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
 if g_debug then
   --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;
  --
  -- We must lock the row which we need to delete.
  --
  pqh_sts_shd.lck
    (p_rec.statutory_situation_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pqh_sts_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pqh_sts_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pqh_sts_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pqh_sts_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_statutory_situation_id               in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   pqh_sts_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin

 g_debug := hr_utility.debug_enabled;

 if g_debug then
   --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.statutory_situation_id := p_statutory_situation_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_sts_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqh_sts_del.del(l_rec);
  --
  if g_debug then
   --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;

End del;
--
end pqh_sts_del;

/
