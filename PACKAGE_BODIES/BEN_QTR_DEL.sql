--------------------------------------------------------
--  DDL for Package Body BEN_QTR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_QTR_DEL" as
/* $Header: beqtrrhi.pkb 120.2.12010000.2 2008/08/05 15:25:12 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_qtr_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
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
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
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
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
	(p_rec 			 in out nocopy ben_qtr_shd.g_rec_type,
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
    ben_qtr_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from ben_qual_titl_rt_f
    where       qual_titl_rt_id = p_rec.qual_titl_rt_id
    and	  effective_start_date = p_validation_start_date;
    --
    ben_qtr_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    ben_qtr_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from ben_qual_titl_rt_f
    where        qual_titl_rt_id = p_rec.qual_titl_rt_id
    and	  effective_start_date >= p_validation_start_date;
    --
    ben_qtr_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    ben_qtr_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
	(p_rec 			 in out nocopy ben_qtr_shd.g_rec_type,
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
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Prerequisites:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
	(p_rec 			 in out nocopy ben_qtr_shd.g_rec_type,
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
    p_rec.effective_start_date := ben_qtr_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    ben_qtr_shd.upd_effective_end_date
      (p_effective_date	        => p_effective_date,
       p_base_key_value	        => p_rec.qual_titl_rt_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
	(p_rec 			 in out nocopy ben_qtr_shd.g_rec_type,
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
	(p_rec 			 in ben_qtr_shd.g_rec_type,
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
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    ben_qtr_rkd.after_delete
      (
  p_qual_titl_rt_id    =>p_rec.qual_titl_rt_id
 ,p_datetrack_mode                =>p_datetrack_mode
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_effective_start_date_o        =>ben_qtr_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o          =>ben_qtr_shd.g_old_rec.effective_end_date
 ,p_business_group_id_o           =>ben_qtr_shd.g_old_rec.business_group_id
 ,p_vrbl_rt_prfl_id_o               =>ben_qtr_shd.g_old_rec.vrbl_rt_prfl_id
 ,p_ordr_num_o                    =>ben_qtr_shd.g_old_rec.ordr_num
 ,p_excld_flag_o                  =>ben_qtr_shd.g_old_rec.excld_flag
 ,p_qualification_type_id_o       =>ben_qtr_shd.g_old_rec.qualification_type_id
 ,p_title_o                       =>ben_qtr_shd.g_old_rec.title
 ,p_qtr_attribute_category_o      =>ben_qtr_shd.g_old_rec.qtr_attribute_category
 ,p_qtr_attribute1_o              =>ben_qtr_shd.g_old_rec.qtr_attribute1
 ,p_qtr_attribute2_o              =>ben_qtr_shd.g_old_rec.qtr_attribute2
 ,p_qtr_attribute3_o              =>ben_qtr_shd.g_old_rec.qtr_attribute3
 ,p_qtr_attribute4_o              =>ben_qtr_shd.g_old_rec.qtr_attribute4
 ,p_qtr_attribute5_o              =>ben_qtr_shd.g_old_rec.qtr_attribute5
 ,p_qtr_attribute6_o              =>ben_qtr_shd.g_old_rec.qtr_attribute6
 ,p_qtr_attribute7_o              =>ben_qtr_shd.g_old_rec.qtr_attribute7
 ,p_qtr_attribute8_o              =>ben_qtr_shd.g_old_rec.qtr_attribute8
 ,p_qtr_attribute9_o              =>ben_qtr_shd.g_old_rec.qtr_attribute9
 ,p_qtr_attribute10_o             =>ben_qtr_shd.g_old_rec.qtr_attribute10
 ,p_qtr_attribute11_o             =>ben_qtr_shd.g_old_rec.qtr_attribute11
 ,p_qtr_attribute12_o             =>ben_qtr_shd.g_old_rec.qtr_attribute12
 ,p_qtr_attribute13_o             =>ben_qtr_shd.g_old_rec.qtr_attribute13
 ,p_qtr_attribute14_o             =>ben_qtr_shd.g_old_rec.qtr_attribute14
 ,p_qtr_attribute15_o             =>ben_qtr_shd.g_old_rec.qtr_attribute15
 ,p_qtr_attribute16_o             =>ben_qtr_shd.g_old_rec.qtr_attribute16
 ,p_qtr_attribute17_o             =>ben_qtr_shd.g_old_rec.qtr_attribute17
 ,p_qtr_attribute18_o             =>ben_qtr_shd.g_old_rec.qtr_attribute18
 ,p_qtr_attribute19_o             =>ben_qtr_shd.g_old_rec.qtr_attribute19
 ,p_qtr_attribute20_o             =>ben_qtr_shd.g_old_rec.qtr_attribute20
 ,p_qtr_attribute21_o             =>ben_qtr_shd.g_old_rec.qtr_attribute21
 ,p_qtr_attribute22_o             =>ben_qtr_shd.g_old_rec.qtr_attribute22
 ,p_qtr_attribute23_o             =>ben_qtr_shd.g_old_rec.qtr_attribute23
 ,p_qtr_attribute24_o             =>ben_qtr_shd.g_old_rec.qtr_attribute24
 ,p_qtr_attribute25_o             =>ben_qtr_shd.g_old_rec.qtr_attribute25
 ,p_qtr_attribute26_o             =>ben_qtr_shd.g_old_rec.qtr_attribute26
 ,p_qtr_attribute27_o             =>ben_qtr_shd.g_old_rec.qtr_attribute27
 ,p_qtr_attribute28_o             =>ben_qtr_shd.g_old_rec.qtr_attribute28
 ,p_qtr_attribute29_o             =>ben_qtr_shd.g_old_rec.qtr_attribute29
 ,p_qtr_attribute30_o             =>ben_qtr_shd.g_old_rec.qtr_attribute30
 ,p_object_version_number_o       =>ben_qtr_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_qual_titl_rt_f'
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
  p_rec			in out nocopy 	ben_qtr_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
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
  -- We must lock the row which we need to delete.
  --
  ben_qtr_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_qual_titl_rt_id	 => p_rec.qual_titl_rt_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  ben_qtr_bus.delete_validate
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
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_qual_titl_rt_id	  in 	 number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date	     out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date	  in     date,
  p_datetrack_mode  	  in     varchar2
  ) is
--
  l_rec		ben_qtr_shd.g_rec_type;
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
  l_rec.qual_titl_rt_id  := p_qual_titl_rt_id;
  l_rec.object_version_number 	:= p_object_version_number;
  --
  -- Having converted the arguments into the ben_qtr_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode);
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
end ben_qtr_del;

/
