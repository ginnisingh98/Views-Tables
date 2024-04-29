--------------------------------------------------------
--  DDL for Package Body PAY_AUD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AUD_DEL" as
/* $Header: pyaudrhi.pkb 115.4 2002/12/09 10:29:32 alogue ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_aud_del.';  -- Global package name
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
  (p_rec in pay_aud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the pay_stat_trans_audit row.
  --
  delete from pay_stat_trans_audit
  where stat_trans_audit_id = p_rec.stat_trans_audit_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    pay_aud_shd.constraint_error
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
Procedure pre_delete(p_rec in pay_aud_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pay_aud_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    pay_aud_rkd.after_delete
      (p_stat_trans_audit_id
      => p_rec.stat_trans_audit_id
      ,p_transaction_type_o
      => pay_aud_shd.g_old_rec.transaction_type
      ,p_transaction_subtype_o
      => pay_aud_shd.g_old_rec.transaction_subtype
      ,p_transaction_date_o
      => pay_aud_shd.g_old_rec.transaction_date
      ,p_transaction_effective_date_o
      => pay_aud_shd.g_old_rec.transaction_effective_date
      ,p_business_group_id_o
      => pay_aud_shd.g_old_rec.business_group_id
      ,p_person_id_o
      => pay_aud_shd.g_old_rec.person_id
      ,p_assignment_id_o
      => pay_aud_shd.g_old_rec.assignment_id
      ,p_source1_o
      => pay_aud_shd.g_old_rec.source1
      ,p_source1_type_o
      => pay_aud_shd.g_old_rec.source1_type
      ,p_source2_o
      => pay_aud_shd.g_old_rec.source2
      ,p_source2_type_o
      => pay_aud_shd.g_old_rec.source2_type
      ,p_source3_o
      => pay_aud_shd.g_old_rec.source3
      ,p_source3_type_o
      => pay_aud_shd.g_old_rec.source3_type
      ,p_source4_o
      => pay_aud_shd.g_old_rec.source4
      ,p_source4_type_o
      => pay_aud_shd.g_old_rec.source4_type
      ,p_source5_o
      => pay_aud_shd.g_old_rec.source5
      ,p_source5_type_o
      => pay_aud_shd.g_old_rec.source5_type
      ,p_transaction_parent_id_o
      => pay_aud_shd.g_old_rec.transaction_parent_id
      ,p_audit_information_category_o
      => pay_aud_shd.g_old_rec.audit_information_category
      ,p_audit_information1_o
      => pay_aud_shd.g_old_rec.audit_information1
      ,p_audit_information2_o
      => pay_aud_shd.g_old_rec.audit_information2
      ,p_audit_information3_o
      => pay_aud_shd.g_old_rec.audit_information3
      ,p_audit_information4_o
      => pay_aud_shd.g_old_rec.audit_information4
      ,p_audit_information5_o
      => pay_aud_shd.g_old_rec.audit_information5
      ,p_audit_information6_o
      => pay_aud_shd.g_old_rec.audit_information6
      ,p_audit_information7_o
      => pay_aud_shd.g_old_rec.audit_information7
      ,p_audit_information8_o
      => pay_aud_shd.g_old_rec.audit_information8
      ,p_audit_information9_o
      => pay_aud_shd.g_old_rec.audit_information9
      ,p_audit_information10_o
      => pay_aud_shd.g_old_rec.audit_information10
      ,p_audit_information11_o
      => pay_aud_shd.g_old_rec.audit_information11
      ,p_audit_information12_o
      => pay_aud_shd.g_old_rec.audit_information12
      ,p_audit_information13_o
      => pay_aud_shd.g_old_rec.audit_information13
      ,p_audit_information14_o
      => pay_aud_shd.g_old_rec.audit_information14
      ,p_audit_information15_o
      => pay_aud_shd.g_old_rec.audit_information15
      ,p_audit_information16_o
      => pay_aud_shd.g_old_rec.audit_information16
      ,p_audit_information17_o
      => pay_aud_shd.g_old_rec.audit_information17
      ,p_audit_information18_o
      => pay_aud_shd.g_old_rec.audit_information18
      ,p_audit_information19_o
      => pay_aud_shd.g_old_rec.audit_information19
      ,p_audit_information20_o
      => pay_aud_shd.g_old_rec.audit_information20
      ,p_audit_information21_o
      => pay_aud_shd.g_old_rec.audit_information21
      ,p_audit_information22_o
      => pay_aud_shd.g_old_rec.audit_information22
      ,p_audit_information23_o
      => pay_aud_shd.g_old_rec.audit_information23
      ,p_audit_information24_o
      => pay_aud_shd.g_old_rec.audit_information24
      ,p_audit_information25_o
      => pay_aud_shd.g_old_rec.audit_information25
      ,p_audit_information26_o
      => pay_aud_shd.g_old_rec.audit_information26
      ,p_audit_information27_o
      => pay_aud_shd.g_old_rec.audit_information27
      ,p_audit_information28_o
      => pay_aud_shd.g_old_rec.audit_information28
      ,p_audit_information29_o
      => pay_aud_shd.g_old_rec.audit_information29
      ,p_audit_information30_o
      => pay_aud_shd.g_old_rec.audit_information30
      ,p_title_o
      => pay_aud_shd.g_old_rec.title
      ,p_object_version_number_o
      => pay_aud_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_STAT_TRANS_AUDIT'
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
  (p_rec	      in pay_aud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pay_aud_shd.lck
    (p_rec.stat_trans_audit_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_aud_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pay_aud_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pay_aud_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pay_aud_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_stat_trans_audit_id                 in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec	  pay_aud_shd.g_rec_type;
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
  l_rec.stat_trans_audit_id := p_stat_trans_audit_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pay_aud_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_aud_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_aud_del;

/
