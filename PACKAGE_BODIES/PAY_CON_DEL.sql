--------------------------------------------------------
--  DDL for Package Body PAY_CON_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CON_DEL" as
/* $Header: pyconrhi.pkb 115.3 1999/12/03 16:45:29 pkm ship      $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_con_del.';  -- Global package name
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
Procedure delete_dml(p_rec in pay_con_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_con_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pay_us_contribution_history row.
  --
  delete from pay_us_contribution_history
  where contr_history_id = p_rec.contr_history_id;
  --
  pay_con_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pay_con_shd.g_api_dml := false;   -- Unset the api dml status
    pay_con_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_con_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in pay_con_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pay_con_shd.g_rec_type) is
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
    pay_con_rkd.after_delete
      (
  p_contr_history_id              =>p_rec.contr_history_id
 ,p_person_id_o                   =>pay_con_shd.g_old_rec.person_id
 ,p_date_from_o                   =>pay_con_shd.g_old_rec.date_from
 ,p_date_to_o                     =>pay_con_shd.g_old_rec.date_to
 ,p_contr_type_o                  =>pay_con_shd.g_old_rec.contr_type
 ,p_business_group_id_o           =>pay_con_shd.g_old_rec.business_group_id
 ,p_legislation_code_o            =>pay_con_shd.g_old_rec.legislation_code
 ,p_amt_contr_o                   =>pay_con_shd.g_old_rec.amt_contr
 ,p_max_contr_allowed_o           =>pay_con_shd.g_old_rec.max_contr_allowed
 ,p_includable_comp_o             =>pay_con_shd.g_old_rec.includable_comp
 ,p_tax_unit_id_o                 =>pay_con_shd.g_old_rec.tax_unit_id
 ,p_source_system_o               =>pay_con_shd.g_old_rec.source_system
 ,p_contr_information_category_o  =>pay_con_shd.g_old_rec.contr_information_category
 ,p_contr_information1_o          =>pay_con_shd.g_old_rec.contr_information1
 ,p_contr_information2_o          =>pay_con_shd.g_old_rec.contr_information2
 ,p_contr_information3_o          =>pay_con_shd.g_old_rec.contr_information3
 ,p_contr_information4_o          =>pay_con_shd.g_old_rec.contr_information4
 ,p_contr_information5_o          =>pay_con_shd.g_old_rec.contr_information5
 ,p_contr_information6_o          =>pay_con_shd.g_old_rec.contr_information6
 ,p_contr_information7_o          =>pay_con_shd.g_old_rec.contr_information7
 ,p_contr_information8_o          =>pay_con_shd.g_old_rec.contr_information8
 ,p_contr_information9_o          =>pay_con_shd.g_old_rec.contr_information9
 ,p_contr_information10_o         =>pay_con_shd.g_old_rec.contr_information10
 ,p_contr_information11_o         =>pay_con_shd.g_old_rec.contr_information11
 ,p_contr_information12_o         =>pay_con_shd.g_old_rec.contr_information12
 ,p_contr_information13_o         =>pay_con_shd.g_old_rec.contr_information13
 ,p_contr_information14_o         =>pay_con_shd.g_old_rec.contr_information14
 ,p_contr_information15_o         =>pay_con_shd.g_old_rec.contr_information15
 ,p_contr_information16_o         =>pay_con_shd.g_old_rec.contr_information16
 ,p_contr_information17_o         =>pay_con_shd.g_old_rec.contr_information17
 ,p_contr_information18_o         =>pay_con_shd.g_old_rec.contr_information18
 ,p_contr_information19_o         =>pay_con_shd.g_old_rec.contr_information19
 ,p_contr_information20_o         =>pay_con_shd.g_old_rec.contr_information20
 ,p_contr_information21_o         =>pay_con_shd.g_old_rec.contr_information21
 ,p_contr_information22_o         =>pay_con_shd.g_old_rec.contr_information22
 ,p_contr_information23_o         =>pay_con_shd.g_old_rec.contr_information23
 ,p_contr_information24_o         =>pay_con_shd.g_old_rec.contr_information24
 ,p_contr_information25_o         =>pay_con_shd.g_old_rec.contr_information25
 ,p_contr_information26_o         =>pay_con_shd.g_old_rec.contr_information26
 ,p_contr_information27_o         =>pay_con_shd.g_old_rec.contr_information27
 ,p_contr_information28_o         =>pay_con_shd.g_old_rec.contr_information28
 ,p_contr_information29_o         =>pay_con_shd.g_old_rec.contr_information29
 ,p_contr_information30_o         =>pay_con_shd.g_old_rec.contr_information30
 ,p_object_version_number_o       =>pay_con_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pay_contribution_history'
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
  p_rec	      in pay_con_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pay_con_shd.lck
	(
	p_rec.contr_history_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pay_con_bus.delete_validate(p_rec);
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
  post_delete(p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_contr_history_id                   in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  pay_con_shd.g_rec_type;
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
  l_rec.contr_history_id:= p_contr_history_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pay_con_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_con_del;

/
