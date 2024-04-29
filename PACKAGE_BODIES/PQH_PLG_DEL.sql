--------------------------------------------------------
--  DDL for Package Body PQH_PLG_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PLG_DEL" as
/* $Header: pqplgrhi.pkb 115.5 2002/12/12 23:13:49 sgoyal ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_plg_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in pqh_plg_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the pqh_process_log row.
  --
  delete from pqh_process_log
  where process_log_id = p_rec.process_log_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqh_plg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_delete(p_rec in pqh_plg_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after the
--   delete dml.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(
p_effective_date in date,p_rec in pqh_plg_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    pqh_plg_rkd.after_delete
      (
  p_process_log_id                =>p_rec.process_log_id
 ,p_module_cd_o                   =>pqh_plg_shd.g_old_rec.module_cd
 ,p_txn_id_o                      =>pqh_plg_shd.g_old_rec.txn_id
 ,p_master_process_log_id_o       =>pqh_plg_shd.g_old_rec.master_process_log_id
 ,p_message_text_o                =>pqh_plg_shd.g_old_rec.message_text
 ,p_message_type_cd_o             =>pqh_plg_shd.g_old_rec.message_type_cd
 ,p_batch_status_o                =>pqh_plg_shd.g_old_rec.batch_status
 ,p_batch_start_date_o            =>pqh_plg_shd.g_old_rec.batch_start_date
 ,p_batch_end_date_o              =>pqh_plg_shd.g_old_rec.batch_end_date
 ,p_txn_table_route_id_o          =>pqh_plg_shd.g_old_rec.txn_table_route_id
 ,p_log_context_o                 =>pqh_plg_shd.g_old_rec.log_context
 ,p_information_category_o        =>pqh_plg_shd.g_old_rec.information_category
 ,p_information1_o                =>pqh_plg_shd.g_old_rec.information1
 ,p_information2_o                =>pqh_plg_shd.g_old_rec.information2
 ,p_information3_o                =>pqh_plg_shd.g_old_rec.information3
 ,p_information4_o                =>pqh_plg_shd.g_old_rec.information4
 ,p_information5_o                =>pqh_plg_shd.g_old_rec.information5
 ,p_information6_o                =>pqh_plg_shd.g_old_rec.information6
 ,p_information7_o                =>pqh_plg_shd.g_old_rec.information7
 ,p_information8_o                =>pqh_plg_shd.g_old_rec.information8
 ,p_information9_o                =>pqh_plg_shd.g_old_rec.information9
 ,p_information10_o               =>pqh_plg_shd.g_old_rec.information10
 ,p_information11_o               =>pqh_plg_shd.g_old_rec.information11
 ,p_information12_o               =>pqh_plg_shd.g_old_rec.information12
 ,p_information13_o               =>pqh_plg_shd.g_old_rec.information13
 ,p_information14_o               =>pqh_plg_shd.g_old_rec.information14
 ,p_information15_o               =>pqh_plg_shd.g_old_rec.information15
 ,p_information16_o               =>pqh_plg_shd.g_old_rec.information16
 ,p_information17_o               =>pqh_plg_shd.g_old_rec.information17
 ,p_information18_o               =>pqh_plg_shd.g_old_rec.information18
 ,p_information19_o               =>pqh_plg_shd.g_old_rec.information19
 ,p_information20_o               =>pqh_plg_shd.g_old_rec.information20
 ,p_information21_o               =>pqh_plg_shd.g_old_rec.information21
 ,p_information22_o               =>pqh_plg_shd.g_old_rec.information22
 ,p_information23_o               =>pqh_plg_shd.g_old_rec.information23
 ,p_information24_o               =>pqh_plg_shd.g_old_rec.information24
 ,p_information25_o               =>pqh_plg_shd.g_old_rec.information25
 ,p_information26_o               =>pqh_plg_shd.g_old_rec.information26
 ,p_information27_o               =>pqh_plg_shd.g_old_rec.information27
 ,p_information28_o               =>pqh_plg_shd.g_old_rec.information28
 ,p_information29_o               =>pqh_plg_shd.g_old_rec.information29
 ,p_information30_o               =>pqh_plg_shd.g_old_rec.information30
 ,p_object_version_number_o       =>pqh_plg_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_process_log'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_rec	      in pqh_plg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqh_plg_shd.lck
	(
	p_rec.process_log_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pqh_plg_bus.delete_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(
p_effective_date,p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_process_log_id                     in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  pqh_plg_shd.g_rec_type;
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
  l_rec.process_log_id:= p_process_log_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_plg_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqh_plg_del;

/