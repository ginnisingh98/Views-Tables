--------------------------------------------------------
--  DDL for Package Body PQH_VER_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_VER_DEL" as
/* $Header: pqverrhi.pkb 115.3 2002/12/05 00:30:42 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_ver_del.';  -- Global package name
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
  (p_rec in pqh_ver_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the pqh_de_wrkplc_vldtn_vers row.
  --
  delete from pqh_de_wrkplc_vldtn_vers
  where wrkplc_vldtn_ver_id = p_rec.wrkplc_vldtn_ver_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    pqh_ver_shd.constraint_error
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
Procedure pre_delete(p_rec in pqh_ver_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
Procedure post_delete(p_rec in pqh_ver_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_ver_rkd.after_delete
      (p_wrkplc_vldtn_ver_id
      => p_rec.wrkplc_vldtn_ver_id
      ,p_wrkplc_vldtn_id_o
      => pqh_ver_shd.g_old_rec.wrkplc_vldtn_id
      ,p_version_number_o
      => pqh_ver_shd.g_old_rec.version_number
      ,p_business_group_id_o
      => pqh_ver_shd.g_old_rec.business_group_id
      ,p_tariff_contract_code_o
      => pqh_ver_shd.g_old_rec.tariff_contract_code
      ,p_tariff_group_code_o
      => pqh_ver_shd.g_old_rec.tariff_group_code
      ,p_remuneration_job_descripti_o
      => pqh_ver_shd.g_old_rec.remuneration_job_description
      ,p_job_group_id_o
      => pqh_ver_shd.g_old_rec.job_group_id
      ,p_remuneration_job_id_o
      => pqh_ver_shd.g_old_rec.remuneration_job_id
      ,p_derived_grade_id_o
      => pqh_ver_shd.g_old_rec.derived_grade_id
      ,p_derived_case_group_id_o
      => pqh_ver_shd.g_old_rec.derived_case_group_id
      ,p_derived_subcasgrp_id_o
      => pqh_ver_shd.g_old_rec.derived_subcasgrp_id
      ,p_user_enterable_grade_id_o
      => pqh_ver_shd.g_old_rec.user_enterable_grade_id
      ,p_user_enterable_case_group__o
      => pqh_ver_shd.g_old_rec.user_enterable_case_group_id
      ,p_user_enterable_subcasgrp_i_o
      => pqh_ver_shd.g_old_rec.user_enterable_subcasgrp_id
      ,p_freeze_o
      => pqh_ver_shd.g_old_rec.freeze
      ,p_object_version_number_o
      => pqh_ver_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_DE_WRKPLC_VLDTN_VERS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in pqh_ver_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqh_ver_shd.lck
    (p_rec.wrkplc_vldtn_ver_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pqh_ver_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pqh_ver_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pqh_ver_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pqh_ver_del.post_delete(p_rec);
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
  (p_wrkplc_vldtn_ver_id                  in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   pqh_ver_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.wrkplc_vldtn_ver_id := p_wrkplc_vldtn_ver_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_ver_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqh_ver_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqh_ver_del;

/