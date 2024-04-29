--------------------------------------------------------
--  DDL for Package Body PAY_GRR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GRR_DEL" as
/* $Header: pygrrrhi.pkb 115.4 2002/12/10 09:48:17 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_grr_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGES and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Table Handler USe Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
	(p_rec 			 in out nocopy pay_grr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    pay_grr_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pay_grade_rules_f
    where       grade_rule_id = p_rec.grade_rule_id
    and	  effective_start_date = p_validation_start_date;
    --
    pay_grr_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    pay_grr_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pay_grade_rules_f
    where        grade_rule_id = p_rec.grade_rule_id
    and	  effective_start_date >= p_validation_start_date;
    --
    pay_grr_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  -- 40.1 change a start.
  --
  -- Moved 'ZAP' effective_[start|end]_date processing to dt_pre_delete.
  --
  -- 40.1 change a end.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    pay_grr_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
	(p_rec 			 in out nocopy pay_grr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, DELETE_FUTURE_CHANGES
--   and DELETE_NEXT_CHANGE only.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
--
-- In Arguments:
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Table Handler USe Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
	(p_rec 			 in out nocopy pay_grr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    --
    -- 40.1 change a start.
    --
    p_rec.effective_start_date := pay_grr_shd.g_old_rec.effective_start_date;
    --
    -- 40.1 change a end.
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    pay_grr_shd.upd_effective_end_date
      (p_effective_date	        => p_effective_date,
       p_base_key_value	        => p_rec.grade_rule_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
    --
    -- 40.1 change a start.
    --
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
    --
    -- 40.1 change a end.
    --
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End dt_pre_delete;
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
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Table Handler USe Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
	(p_rec 			 in out nocopy pay_grr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_delete
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
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
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
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
--   Internal Table Handler USe Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
	(p_rec 			 in pay_grr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec			in out nocopy 	pay_grr_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2,
  p_validate   		in 	boolean default false
  ) is
--
  l_proc			varchar2(72) := g_package||'del';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_pay_grr;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  pay_grr_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_grade_rule_id	 => p_rec.grade_rule_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  pay_grr_bus.delete_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_pay_grr;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_grade_rule_id	  in 	 number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date	     out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date	  in     date,
  p_datetrack_mode  	  in     varchar2,
  p_validate		  in     boolean default false
  ) is
--
  l_rec		pay_grr_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.grade_rule_id		:= p_grade_rule_id;
  l_rec.object_version_number 	:= p_object_version_number;
  --
  -- Having converted the arguments into the pay_grr_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode, p_validate);
  --
  -- Set the out arguments
  --
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date  := l_rec.effective_start_date;
  p_effective_end_date    := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_grr_del;

/