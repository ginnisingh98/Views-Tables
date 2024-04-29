--------------------------------------------------------
--  DDL for Package Body PAY_AIF_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AIF_DEL" as
/* $Header: pyaifrhi.pkb 120.2.12000000.2 2007/03/30 05:34:36 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_aif_del.';  -- Global package name
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
  (p_rec in pay_aif_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the pay_action_information row.
  --
  delete from pay_action_information
  where action_information_id = p_rec.action_information_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    pay_aif_shd.constraint_error
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
Procedure pre_delete(p_rec in pay_aif_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pay_aif_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    pay_aif_rkd.after_delete
      (p_action_information_id
      => p_rec.action_information_id
      ,p_action_context_id_o
      => pay_aif_shd.g_old_rec.action_context_id
      ,p_action_context_type_o
      => pay_aif_shd.g_old_rec.action_context_type
      ,p_tax_unit_id_o
      => pay_aif_shd.g_old_rec.tax_unit_id
      ,p_jurisdiction_code_o
      => pay_aif_shd.g_old_rec.jurisdiction_code
      ,p_source_id_o
      => pay_aif_shd.g_old_rec.source_id
      ,p_source_text_o
      => pay_aif_shd.g_old_rec.source_text
      ,p_tax_group_o
      => pay_aif_shd.g_old_rec.tax_group
      ,p_object_version_number_o
      => pay_aif_shd.g_old_rec.object_version_number
      ,p_effective_date_o
      => pay_aif_shd.g_old_rec.effective_date
      ,p_assignment_id_o
      => pay_aif_shd.g_old_rec.assignment_id
      ,p_action_information_categor_o
      => pay_aif_shd.g_old_rec.action_information_category
      ,p_action_information1_o
      => pay_aif_shd.g_old_rec.action_information1
      ,p_action_information2_o
      => pay_aif_shd.g_old_rec.action_information2
      ,p_action_information3_o
      => pay_aif_shd.g_old_rec.action_information3
      ,p_action_information4_o
      => pay_aif_shd.g_old_rec.action_information4
      ,p_action_information5_o
      => pay_aif_shd.g_old_rec.action_information5
      ,p_action_information6_o
      => pay_aif_shd.g_old_rec.action_information6
      ,p_action_information7_o
      => pay_aif_shd.g_old_rec.action_information7
      ,p_action_information8_o
      => pay_aif_shd.g_old_rec.action_information8
      ,p_action_information9_o
      => pay_aif_shd.g_old_rec.action_information9
      ,p_action_information10_o
      => pay_aif_shd.g_old_rec.action_information10
      ,p_action_information11_o
      => pay_aif_shd.g_old_rec.action_information11
      ,p_action_information12_o
      => pay_aif_shd.g_old_rec.action_information12
      ,p_action_information13_o
      => pay_aif_shd.g_old_rec.action_information13
      ,p_action_information14_o
      => pay_aif_shd.g_old_rec.action_information14
      ,p_action_information15_o
      => pay_aif_shd.g_old_rec.action_information15
      ,p_action_information16_o
      => pay_aif_shd.g_old_rec.action_information16
      ,p_action_information17_o
      => pay_aif_shd.g_old_rec.action_information17
      ,p_action_information18_o
      => pay_aif_shd.g_old_rec.action_information18
      ,p_action_information19_o
      => pay_aif_shd.g_old_rec.action_information19
      ,p_action_information20_o
      => pay_aif_shd.g_old_rec.action_information20
      ,p_action_information21_o
      => pay_aif_shd.g_old_rec.action_information21
      ,p_action_information22_o
      => pay_aif_shd.g_old_rec.action_information22
      ,p_action_information23_o
      => pay_aif_shd.g_old_rec.action_information23
      ,p_action_information24_o
      => pay_aif_shd.g_old_rec.action_information24
      ,p_action_information25_o
      => pay_aif_shd.g_old_rec.action_information25
      ,p_action_information26_o
      => pay_aif_shd.g_old_rec.action_information26
      ,p_action_information27_o
      => pay_aif_shd.g_old_rec.action_information27
      ,p_action_information28_o
      => pay_aif_shd.g_old_rec.action_information28
      ,p_action_information29_o
      => pay_aif_shd.g_old_rec.action_information29
      ,p_action_information30_o
      => pay_aif_shd.g_old_rec.action_information30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ACTION_INFORMATION'
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
  (p_rec	      in pay_aif_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pay_aif_shd.lck
    (p_rec.action_information_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_aif_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  --
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pay_aif_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pay_aif_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pay_aif_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  --
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_action_information_id                in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec	  pay_aif_shd.g_rec_type;
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
  l_rec.action_information_id := p_action_information_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pay_aif_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_aif_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_aif_del;

/
