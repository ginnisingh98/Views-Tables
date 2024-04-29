--------------------------------------------------------
--  DDL for Package Body PQP_SHP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_SHP_DEL" as
/* $Header: pqshprhi.pkb 115.8 2003/02/17 22:14:48 tmehra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_shp_del.';  -- Global package name
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
  (p_rec in pqp_shp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_shp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pqp_service_history_periods row.
  --
  delete from pqp_service_history_periods
  where service_history_period_id = p_rec.service_history_period_id;
  --
  pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_shp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in pqp_shp_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pqp_shp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    pqp_shp_rkd.after_delete
      (p_service_history_period_id
      => p_rec.service_history_period_id
      ,p_business_group_id_o
      => pqp_shp_shd.g_old_rec.business_group_id
      ,p_assignment_id_o
      => pqp_shp_shd.g_old_rec.assignment_id
      ,p_start_date_o
      => pqp_shp_shd.g_old_rec.start_date
      ,p_end_date_o
      => pqp_shp_shd.g_old_rec.end_date
      ,p_employer_name_o
      => pqp_shp_shd.g_old_rec.employer_name
      ,p_employer_address_o
      => pqp_shp_shd.g_old_rec.employer_address
      ,p_employer_type_o
      => pqp_shp_shd.g_old_rec.employer_type
      ,p_employer_subtype_o
      => pqp_shp_shd.g_old_rec.employer_subtype
      ,p_period_years_o
      => pqp_shp_shd.g_old_rec.period_years
      ,p_period_days_o
      => pqp_shp_shd.g_old_rec.period_days
      ,p_description_o
      => pqp_shp_shd.g_old_rec.description
      ,p_continuous_service_o
      => pqp_shp_shd.g_old_rec.continuous_service
      ,p_all_assignments_o
      => pqp_shp_shd.g_old_rec.all_assignments
      ,p_object_version_number_o
      => pqp_shp_shd.g_old_rec.object_version_number
      ,p_shp_attribute_category_o
      => pqp_shp_shd.g_old_rec.shp_attribute_category
      ,p_shp_attribute1_o
      => pqp_shp_shd.g_old_rec.shp_attribute1
      ,p_shp_attribute2_o
      => pqp_shp_shd.g_old_rec.shp_attribute2
      ,p_shp_attribute3_o
      => pqp_shp_shd.g_old_rec.shp_attribute3
      ,p_shp_attribute4_o
      => pqp_shp_shd.g_old_rec.shp_attribute4
      ,p_shp_attribute5_o
      => pqp_shp_shd.g_old_rec.shp_attribute5
      ,p_shp_attribute6_o
      => pqp_shp_shd.g_old_rec.shp_attribute6
      ,p_shp_attribute7_o
      => pqp_shp_shd.g_old_rec.shp_attribute7
      ,p_shp_attribute8_o
      => pqp_shp_shd.g_old_rec.shp_attribute8
      ,p_shp_attribute9_o
      => pqp_shp_shd.g_old_rec.shp_attribute9
      ,p_shp_attribute10_o
      => pqp_shp_shd.g_old_rec.shp_attribute10
      ,p_shp_attribute11_o
      => pqp_shp_shd.g_old_rec.shp_attribute11
      ,p_shp_attribute12_o
      => pqp_shp_shd.g_old_rec.shp_attribute12
      ,p_shp_attribute13_o
      => pqp_shp_shd.g_old_rec.shp_attribute13
      ,p_shp_attribute14_o
      => pqp_shp_shd.g_old_rec.shp_attribute14
      ,p_shp_attribute15_o
      => pqp_shp_shd.g_old_rec.shp_attribute15
      ,p_shp_attribute16_o
      => pqp_shp_shd.g_old_rec.shp_attribute16
      ,p_shp_attribute17_o
      => pqp_shp_shd.g_old_rec.shp_attribute17
      ,p_shp_attribute18_o
      => pqp_shp_shd.g_old_rec.shp_attribute18
      ,p_shp_attribute19_o
      => pqp_shp_shd.g_old_rec.shp_attribute19
      ,p_shp_attribute20_o
      => pqp_shp_shd.g_old_rec.shp_attribute20
      ,p_shp_information_category_o
      => pqp_shp_shd.g_old_rec.shp_information_category
      ,p_shp_information1_o
      => pqp_shp_shd.g_old_rec.shp_information1
      ,p_shp_information2_o
      => pqp_shp_shd.g_old_rec.shp_information2
      ,p_shp_information3_o
      => pqp_shp_shd.g_old_rec.shp_information3
      ,p_shp_information4_o
      => pqp_shp_shd.g_old_rec.shp_information4
      ,p_shp_information5_o
      => pqp_shp_shd.g_old_rec.shp_information5
      ,p_shp_information6_o
      => pqp_shp_shd.g_old_rec.shp_information6
      ,p_shp_information7_o
      => pqp_shp_shd.g_old_rec.shp_information7
      ,p_shp_information8_o
      => pqp_shp_shd.g_old_rec.shp_information8
      ,p_shp_information9_o
      => pqp_shp_shd.g_old_rec.shp_information9
      ,p_shp_information10_o
      => pqp_shp_shd.g_old_rec.shp_information10
      ,p_shp_information11_o
      => pqp_shp_shd.g_old_rec.shp_information11
      ,p_shp_information12_o
      => pqp_shp_shd.g_old_rec.shp_information12
      ,p_shp_information13_o
      => pqp_shp_shd.g_old_rec.shp_information13
      ,p_shp_information14_o
      => pqp_shp_shd.g_old_rec.shp_information14
      ,p_shp_information15_o
      => pqp_shp_shd.g_old_rec.shp_information15
      ,p_shp_information16_o
      => pqp_shp_shd.g_old_rec.shp_information16
      ,p_shp_information17_o
      => pqp_shp_shd.g_old_rec.shp_information17
      ,p_shp_information18_o
      => pqp_shp_shd.g_old_rec.shp_information18
      ,p_shp_information19_o
      => pqp_shp_shd.g_old_rec.shp_information19
      ,p_shp_information20_o
      => pqp_shp_shd.g_old_rec.shp_information20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_SERVICE_HISTORY_PERIODS'
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
  (p_rec	      in pqp_shp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqp_shp_shd.lck
    (p_rec.service_history_period_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pqp_shp_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pqp_shp_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pqp_shp_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pqp_shp_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_service_history_period_id            in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec	  pqp_shp_shd.g_rec_type;
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
  l_rec.service_history_period_id := p_service_history_period_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqp_shp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqp_shp_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqp_shp_del;

/
