--------------------------------------------------------
--  DDL for Package Body PER_GRA_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GRA_DEL" as
/* $Header: pegrarhi.pkb 115.4 2003/08/31 00:48:34 kjagadee ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_gra_del.';  -- Global package name
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
Procedure delete_dml(p_rec in per_gra_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_gra_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the per_cagr_grades row.
  --
  delete from per_cagr_grades
  where cagr_grade_id = p_rec.cagr_grade_id;
  --
  per_gra_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_gra_shd.g_api_dml := false;   -- Unset the api dml status
    per_gra_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_gra_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in per_gra_shd.g_rec_type,
		     p_effective_date   in date ) is
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
Procedure post_delete(p_rec in per_gra_shd.g_rec_type,
		      p_effective_date   in date ) is
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
    per_gra_rkd.after_delete
      (
  p_cagr_grade_id                 =>p_rec.cagr_grade_id
 ,p_cagr_grade_structure_id_o     =>per_gra_shd.g_old_rec.cagr_grade_structure_id
 ,p_cagr_grade_def_id_o           =>per_gra_shd.g_old_rec.cagr_grade_def_id
 ,p_sequence_o                    =>per_gra_shd.g_old_rec.sequence
 ,p_object_version_number_o       =>per_gra_shd.g_old_rec.object_version_number
 ,p_effective_date   		  =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'per_cagr_grades'
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
  p_rec	      in per_gra_shd.g_rec_type,
  p_effective_date   in date
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_gra_shd.lck
	(
	p_cagr_grade_id			=>p_rec.cagr_grade_id,
	p_object_version_number		=>p_rec.object_version_number,
	p_effective_date   		=>p_effective_date
	);
  --
  -- Call the supporting delete validate operation
  --
  per_gra_bus.delete_validate(p_rec	=> p_rec,
  			      p_effective_date   =>p_effective_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec	=>p_rec,
  	     p_effective_date   =>p_effective_date);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec	=> p_rec,
  	      p_effective_date   =>p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_cagr_grade_id                      in number,
  p_object_version_number              in number,
  p_effective_date   		       in date
  ) is
--
  l_rec	  per_gra_shd.g_rec_type;
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
  l_rec.cagr_grade_id:= p_cagr_grade_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_gra_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(p_rec	=> l_rec,
      p_effective_date 	=>p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_gra_del;

/
