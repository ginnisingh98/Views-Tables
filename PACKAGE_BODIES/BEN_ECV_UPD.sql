--------------------------------------------------------
--  DDL for Package Body BEN_ECV_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ECV_UPD" as
/* $Header: beecvrhi.pkb 120.1 2005/07/29 09:50:17 rbingi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ecv_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
	(p_rec 			 in out nocopy ben_ecv_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
	  (p_base_table_name	=> 'ben_eligy_crit_values_f',
	   p_base_key_column	=> 'eligy_crit_values_id',
	   p_base_key_value	=> p_rec.eligy_crit_values_id);
    --
    ben_ecv_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_eligy_crit_vlaues_f Row
    --
update ben_eligy_crit_values_f
  set
    eligy_crit_values_id                	    =  p_rec.eligy_crit_values_id,
    eligy_prfl_id                            	=  p_rec.eligy_prfl_id,
    eligy_criteria_id                       	=  p_rec.eligy_criteria_id,
 --   effective_start_date                    	=  p_rec.effective_start_date,
 --   effective_end_date                      	=  p_rec.effective_end_date,
    ordr_num                                	=  p_rec.ordr_num,
    number_value1                           	=  p_rec.number_value1,
    number_value2                           	=  p_rec.number_value2,
    char_value1                             	=  p_rec.char_value1,
    char_value2                             	=  p_rec.char_value2,
	date_value1                             	=  p_rec.date_value1,
	date_value2                             	=  p_rec.date_value2,
        excld_flag                                      =  p_rec.excld_flag,
	business_group_id                       	=  p_rec.business_group_id,
	legislation_code                        	=  p_rec.legislation_code,
	ecv_attribute_category                  	=  p_rec.ecv_attribute_category,
	ecv_attribute1                          	=  p_rec.ecv_attribute1,
	ecv_attribute2                          	=  p_rec.ecv_attribute2,
	ecv_attribute3                          	=  p_rec.ecv_attribute3,
	ecv_attribute4                          	=  p_rec.ecv_attribute4,
	ecv_attribute5                          	=  p_rec.ecv_attribute5,
	ecv_attribute6                          	=  p_rec.ecv_attribute6,
	ecv_attribute7                          	=  p_rec.ecv_attribute7,
	ecv_attribute8                          	=  p_rec.ecv_attribute8,
	ecv_attribute9                          	=  p_rec.ecv_attribute9,
	ecv_attribute10                         	=  p_rec.ecv_attribute10,
	ecv_attribute11                         	=  p_rec.ecv_attribute11,
	ecv_attribute12                         	=  p_rec.ecv_attribute12,
	ecv_attribute13                         	=  p_rec.ecv_attribute13,
	ecv_attribute14                         	=  p_rec.ecv_attribute14,
	ecv_attribute15                         	=  p_rec.ecv_attribute15,
	ecv_attribute16                         	=  p_rec.ecv_attribute16,
	ecv_attribute17                         	=  p_rec.ecv_attribute17,
	ecv_attribute18                         	=  p_rec.ecv_attribute18,
	ecv_attribute19                         	=  p_rec.ecv_attribute19,
	ecv_attribute20                         	=  p_rec.ecv_attribute20,
	ecv_attribute21                         	=  p_rec.ecv_attribute21,
	ecv_attribute22                         	=  p_rec.ecv_attribute22,
	ecv_attribute23                         	=  p_rec.ecv_attribute23,
	ecv_attribute24                         	=  p_rec.ecv_attribute24,
	ecv_attribute25                         	=  p_rec.ecv_attribute25,
	ecv_attribute26                         	=  p_rec.ecv_attribute26,
	ecv_attribute27                         	=  p_rec.ecv_attribute27,
	ecv_attribute28                         	=  p_rec.ecv_attribute28,
	ecv_attribute29                         	=  p_rec.ecv_attribute29,
	ecv_attribute30                         	=  p_rec.ecv_attribute30,
	object_version_number                   	=  p_rec.object_version_number,
	criteria_score                                  =  p_rec.criteria_score,
	criteria_weight                                 =  p_rec.criteria_weight,
        char_value3                                     =  p_rec.char_value3,
	char_value4  					=  p_rec.char_value4,
	number_value3					=  p_rec.number_value3,
	number_value4					=  p_rec.number_value4,
	date_value3					=  p_rec.date_value3,
	date_value4  					=  p_rec.date_value4
	where eligy_crit_values_id = p_rec.eligy_crit_values_id
	 and  effective_start_date = p_validation_start_date
	 and  effective_end_date   = p_validation_end_date;
	 --
	 ben_ecv_shd.g_api_dml := false;  --unset the api dml status
	 --
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
	 ben_ecv_shd.g_api_dml := false;  --unset the api dml status
     ben_ecv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_ecv_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ecv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ecv_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
	(p_rec 			 in out nocopy ben_ecv_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--	the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
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
Procedure dt_pre_update
	(p_rec 			 in out nocopy ben_ecv_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	         varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    ben_ecv_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.eligy_crit_values_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      ben_ecv_del.delete_dml
    (p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => p_validation_start_date,
	 p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_ecv_ins.insert_dml
      (p_rec			=> p_rec,
       p_effective_date		=> p_effective_date,
       p_datetrack_mode		=> p_datetrack_mode,
       p_validation_start_date	=> p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
	(p_rec 			 in out nocopy ben_ecv_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering :'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
	(p_rec 			 in ben_ecv_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
      ben_ecv_rku.after_update
      (
        p_eligy_crit_values_id              =>p_rec.eligy_crit_values_id
 ,p_eligy_prfl_id                           =>p_rec.eligy_prfl_id
 ,p_eligy_criteria_id                       =>p_rec.eligy_criteria_id
 ,p_effective_start_date                    =>p_rec.effective_start_date
 ,p_effective_end_date                      =>p_rec.effective_end_date
 ,p_ordr_num                                =>p_rec.ordr_num
 ,p_number_value1                           =>p_rec.number_value1
 ,p_number_value2                           =>p_rec.number_value2
 ,p_char_value1                             =>p_rec.char_value1
 ,p_char_value2                             =>p_rec.char_value2
 ,p_date_value1                             =>p_rec.date_value1
 ,p_date_value2                             =>p_rec.date_value2
 ,p_excld_flag                              =>p_rec.excld_flag
 ,p_business_group_id                       =>p_rec.business_group_id
 ,p_legislation_code                        =>p_rec.legislation_code
 ,p_ecv_attribute_category                  =>p_rec.ecv_attribute_category
 ,p_ecv_attribute1                          =>p_rec.ecv_attribute1
 ,p_ecv_attribute2                          =>p_rec.ecv_attribute2
 ,p_ecv_attribute3                          =>p_rec.ecv_attribute3
 ,p_ecv_attribute4                          =>p_rec.ecv_attribute4
 ,p_ecv_attribute5                          =>p_rec.ecv_attribute5
 ,p_ecv_attribute6                          =>p_rec.ecv_attribute6
 ,p_ecv_attribute7                          =>p_rec.ecv_attribute7
 ,p_ecv_attribute8                          =>p_rec.ecv_attribute8
 ,p_ecv_attribute9                          =>p_rec.ecv_attribute9
 ,p_ecv_attribute10                         =>p_rec.ecv_attribute10
 ,p_ecv_attribute11                         =>p_rec.ecv_attribute11
 ,p_ecv_attribute12                         =>p_rec.ecv_attribute12
 ,p_ecv_attribute13                         =>p_rec.ecv_attribute13
 ,p_ecv_attribute14                         =>p_rec.ecv_attribute14
 ,p_ecv_attribute15                         =>p_rec.ecv_attribute15
 ,p_ecv_attribute16                         =>p_rec.ecv_attribute16
 ,p_ecv_attribute17                         =>p_rec.ecv_attribute17
 ,p_ecv_attribute18                         =>p_rec.ecv_attribute18
 ,p_ecv_attribute19                         =>p_rec.ecv_attribute19
 ,p_ecv_attribute20                         =>p_rec.ecv_attribute20
 ,p_ecv_attribute21                         =>p_rec.ecv_attribute21
 ,p_ecv_attribute22                         =>p_rec.ecv_attribute22
 ,p_ecv_attribute23                         =>p_rec.ecv_attribute23
 ,p_ecv_attribute24                         =>p_rec.ecv_attribute24
 ,p_ecv_attribute25                         =>p_rec.ecv_attribute25
 ,p_ecv_attribute26                         =>p_rec.ecv_attribute26
 ,p_ecv_attribute27                         =>p_rec.ecv_attribute27
 ,p_ecv_attribute28                         =>p_rec.ecv_attribute28
 ,p_ecv_attribute29                         =>p_rec.ecv_attribute29
 ,p_ecv_attribute30                         =>p_rec.ecv_attribute30
 ,p_object_version_number                   =>p_rec.object_version_number
 ,p_effective_date                          =>p_effective_date
 ,p_datetrack_mode                          =>p_datetrack_mode
 ,p_validation_start_date                   =>p_validation_start_date
 ,p_criteria_score                          =>p_rec.criteria_score
 ,p_criteria_weight                         =>p_rec.criteria_weight
 ,p_validation_end_date                     =>p_validation_end_date
 ,p_char_value3                             =>p_rec.char_value3
 ,p_char_value4  			    =>p_rec.char_value4
 ,p_number_value3			    =>p_rec.number_value3
 ,p_number_value4			    =>p_rec.number_value4
 ,p_date_value3				    =>p_rec.date_value3
 ,p_date_value4  			    =>p_rec.date_value4
 ,p_eligy_prfl_id_o                         =>ben_ecv_shd.g_old_rec.eligy_prfl_id
 ,p_eligy_criteria_id_o                     =>ben_ecv_shd.g_old_rec.eligy_criteria_id
 ,p_effective_start_date_o                  =>ben_ecv_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o                    =>ben_ecv_shd.g_old_rec.effective_end_date
 ,p_ordr_num_o                              =>ben_ecv_shd.g_old_rec.ordr_num
 ,p_number_value1_o                         =>ben_ecv_shd.g_old_rec.number_value1
 ,p_number_value2_o                         =>ben_ecv_shd.g_old_rec.number_value2
 ,p_char_value1_o                           =>ben_ecv_shd.g_old_rec.char_value1
 ,p_char_value2_o                           =>ben_ecv_shd.g_old_rec.char_value2
 ,p_date_value1_o                           =>ben_ecv_shd.g_old_rec.date_value1
 ,p_date_value2_o                           =>ben_ecv_shd.g_old_rec.date_value2
 ,p_excld_flag_o                            =>ben_ecv_shd.g_old_rec.excld_flag
 ,p_business_group_id_o                     =>ben_ecv_shd.g_old_rec.business_group_id
 ,p_legislation_code_o                      =>ben_ecv_shd.g_old_rec.legislation_code
 ,p_ecv_attribute_category_o                =>ben_ecv_shd.g_old_rec.ecv_attribute_category
 ,p_ecv_attribute1_o                        =>ben_ecv_shd.g_old_rec.ecv_attribute1
 ,p_ecv_attribute2_o                        =>ben_ecv_shd.g_old_rec.ecv_attribute2
 ,p_ecv_attribute3_o                        =>ben_ecv_shd.g_old_rec.ecv_attribute3
 ,p_ecv_attribute4_o                        =>ben_ecv_shd.g_old_rec.ecv_attribute4
 ,p_ecv_attribute5_o                        =>ben_ecv_shd.g_old_rec.ecv_attribute5
 ,p_ecv_attribute6_o                        =>ben_ecv_shd.g_old_rec.ecv_attribute6
 ,p_ecv_attribute7_o                        =>ben_ecv_shd.g_old_rec.ecv_attribute7
 ,p_ecv_attribute8_o                        =>ben_ecv_shd.g_old_rec.ecv_attribute8
 ,p_ecv_attribute9_o                        =>ben_ecv_shd.g_old_rec.ecv_attribute9
 ,p_ecv_attribute10_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute10
 ,p_ecv_attribute11_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute11
 ,p_ecv_attribute12_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute12
 ,p_ecv_attribute13_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute13
 ,p_ecv_attribute14_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute14
 ,p_ecv_attribute15_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute15
 ,p_ecv_attribute16_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute16
 ,p_ecv_attribute17_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute17
 ,p_ecv_attribute18_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute18
 ,p_ecv_attribute19_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute19
 ,p_ecv_attribute20_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute20
 ,p_ecv_attribute21_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute21
 ,p_ecv_attribute22_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute22
 ,p_ecv_attribute23_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute23
 ,p_ecv_attribute24_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute24
 ,p_ecv_attribute25_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute25
 ,p_ecv_attribute26_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute26
 ,p_ecv_attribute27_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute27
 ,p_ecv_attribute28_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute28
 ,p_ecv_attribute29_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute29
 ,p_ecv_attribute30_o                       =>ben_ecv_shd.g_old_rec.ecv_attribute30
 ,p_object_version_number_o                 =>ben_ecv_shd.g_old_rec.object_version_number
 ,p_criteria_score_o                        =>ben_ecv_shd.g_old_rec.criteria_score
 ,p_criteria_weight_o                       =>ben_ecv_shd.g_old_rec.criteria_weight
 ,p_char_value3_o                           =>ben_ecv_shd.g_old_rec.char_value3
 ,p_char_value4_o  			    =>ben_ecv_shd.g_old_rec.char_value4
 ,p_number_value3_o			    =>ben_ecv_shd.g_old_rec.number_value3
 ,p_number_value4_o			    =>ben_ecv_shd.g_old_rec.number_value4
 ,p_date_value3_o			    =>ben_ecv_shd.g_old_rec.date_value3
 ,p_date_value4_o  			    =>ben_ecv_shd.g_old_rec.date_value4
  );
	 --
	 exception
	 --
	   when hr_api.cannot_find_prog_unit then
	    --
	     hr_api.cannot_find_prog_unit_error
	       (p_module_name =>  'ben_eligy_crit_values_f'
	       ,p_hook_type   =>  'AU'
	       );
	    --
	end;
  --
  -- End of API User Hook for post_update.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_ecv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.eligy_prfl_id = hr_api.g_number) then
      p_rec.eligy_prfl_id := ben_ecv_shd.g_old_rec.eligy_prfl_id;
  end if;
  If (p_rec.eligy_criteria_id = hr_api.g_number) then
      p_rec.eligy_criteria_id := ben_ecv_shd.g_old_rec.eligy_criteria_id;
  end if;
  If (p_rec.number_value1 = hr_api.g_number) then
      p_rec.number_value1 := ben_ecv_shd.g_old_rec.number_value1;
  end if;
  If (p_rec.number_value2 = hr_api.g_number) then
      p_rec.number_value2 := ben_ecv_shd.g_old_rec.number_value2;
  end if;
  If (p_rec.char_value1 = hr_api.g_varchar2) then
      p_rec.char_value1 := ben_ecv_shd.g_old_rec.char_value1;
  end if;
  If (p_rec.char_value2 = hr_api.g_varchar2) then
      p_rec.char_value2 := ben_ecv_shd.g_old_rec.char_value2;
  end if;
  If (p_rec.date_value1 = hr_api.g_date) then
      p_rec.date_value1 := ben_ecv_shd.g_old_rec.date_value1;
  end if;
  If (p_rec.date_value2 = hr_api.g_date) then
      p_rec.date_value2 := ben_ecv_shd.g_old_rec.date_value2;
  end if;
  If (p_rec.excld_flag = hr_api.g_varchar2) then
      p_rec.excld_flag := ben_ecv_shd.g_old_rec.excld_flag;
  end if;
  If (p_rec.business_group_id = hr_api.g_number) then
      p_rec.business_group_id := ben_ecv_shd.g_old_rec.business_group_id;
  end if;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
      p_rec.legislation_code := ben_ecv_shd.g_old_rec.legislation_code;
  end if;
  If (p_rec.ecv_attribute_category = hr_api.g_varchar2) then
      p_rec.ecv_attribute_category := ben_ecv_shd.g_old_rec.ecv_attribute_category;
  end if;
  If (p_rec.ecv_attribute1 = hr_api.g_varchar2) then
      p_rec.ecv_attribute1 := ben_ecv_shd.g_old_rec.ecv_attribute1;
  end if;
  If (p_rec.ecv_attribute2 = hr_api.g_varchar2) then
      p_rec.ecv_attribute2 := ben_ecv_shd.g_old_rec.ecv_attribute2;
  end if;
  If (p_rec.ecv_attribute3 = hr_api.g_varchar2) then
      p_rec.ecv_attribute3 := ben_ecv_shd.g_old_rec.ecv_attribute3;
  end if;
  If (p_rec.ecv_attribute4 = hr_api.g_varchar2) then
      p_rec.ecv_attribute4 := ben_ecv_shd.g_old_rec.ecv_attribute4;
  end if;
  If (p_rec.ecv_attribute5 = hr_api.g_varchar2) then
      p_rec.ecv_attribute5 := ben_ecv_shd.g_old_rec.ecv_attribute5;
  end if;
  If (p_rec.ecv_attribute6 = hr_api.g_varchar2) then
      p_rec.ecv_attribute6 := ben_ecv_shd.g_old_rec.ecv_attribute6;
  end if;
  If (p_rec.ecv_attribute7 = hr_api.g_varchar2) then
      p_rec.ecv_attribute7 := ben_ecv_shd.g_old_rec.ecv_attribute7;
  end if;
  If (p_rec.ecv_attribute8 = hr_api.g_varchar2) then
      p_rec.ecv_attribute8 := ben_ecv_shd.g_old_rec.ecv_attribute8;
  end if;
  If (p_rec.ecv_attribute9 = hr_api.g_varchar2) then
      p_rec.ecv_attribute9 := ben_ecv_shd.g_old_rec.ecv_attribute9;
  end if;
  If (p_rec.ecv_attribute10 = hr_api.g_varchar2) then
      p_rec.ecv_attribute10 := ben_ecv_shd.g_old_rec.ecv_attribute10;
  end if;
  If (p_rec.ecv_attribute11 = hr_api.g_varchar2) then
      p_rec.ecv_attribute11 := ben_ecv_shd.g_old_rec.ecv_attribute11;
  end if;
  If (p_rec.ecv_attribute12 = hr_api.g_varchar2) then
      p_rec.ecv_attribute12 := ben_ecv_shd.g_old_rec.ecv_attribute12;
  end if;
  If (p_rec.ecv_attribute13 = hr_api.g_varchar2) then
      p_rec.ecv_attribute13 := ben_ecv_shd.g_old_rec.ecv_attribute13;
  end if;
  If (p_rec.ecv_attribute14 = hr_api.g_varchar2) then
      p_rec.ecv_attribute14 := ben_ecv_shd.g_old_rec.ecv_attribute14;
  end if;
  If (p_rec.ecv_attribute15 = hr_api.g_varchar2) then
      p_rec.ecv_attribute15 := ben_ecv_shd.g_old_rec.ecv_attribute15;
  end if;
  If (p_rec.ecv_attribute16 = hr_api.g_varchar2) then
      p_rec.ecv_attribute16 := ben_ecv_shd.g_old_rec.ecv_attribute16;
  end if;
  If (p_rec.ecv_attribute17 = hr_api.g_varchar2) then
      p_rec.ecv_attribute17 := ben_ecv_shd.g_old_rec.ecv_attribute17;
  end if;
  If (p_rec.ecv_attribute18 = hr_api.g_varchar2) then
      p_rec.ecv_attribute18 := ben_ecv_shd.g_old_rec.ecv_attribute18;
  end if;
  If (p_rec.ecv_attribute19 = hr_api.g_varchar2) then
      p_rec.ecv_attribute19 := ben_ecv_shd.g_old_rec.ecv_attribute19;
  end if;
  If (p_rec.ecv_attribute20 = hr_api.g_varchar2) then
      p_rec.ecv_attribute20 := ben_ecv_shd.g_old_rec.ecv_attribute20;
  end if;
  If (p_rec.ecv_attribute21 = hr_api.g_varchar2) then
      p_rec.ecv_attribute21 := ben_ecv_shd.g_old_rec.ecv_attribute21;
  end if;
  If (p_rec.ecv_attribute22 = hr_api.g_varchar2) then
      p_rec.ecv_attribute22 := ben_ecv_shd.g_old_rec.ecv_attribute22;
  end if;
  If (p_rec.ecv_attribute23 = hr_api.g_varchar2) then
      p_rec.ecv_attribute23 := ben_ecv_shd.g_old_rec.ecv_attribute23;
  end if;
  If (p_rec.ecv_attribute24 = hr_api.g_varchar2) then
      p_rec.ecv_attribute24 := ben_ecv_shd.g_old_rec.ecv_attribute24;
  end if;
  If (p_rec.ecv_attribute25 = hr_api.g_varchar2) then
      p_rec.ecv_attribute25 := ben_ecv_shd.g_old_rec.ecv_attribute25;
  end if;
  If (p_rec.ecv_attribute26 = hr_api.g_varchar2) then
      p_rec.ecv_attribute26 := ben_ecv_shd.g_old_rec.ecv_attribute26;
  end if;
  If (p_rec.ecv_attribute27 = hr_api.g_varchar2) then
      p_rec.ecv_attribute27 := ben_ecv_shd.g_old_rec.ecv_attribute27;
  end if;
  If (p_rec.ecv_attribute28 = hr_api.g_varchar2) then
      p_rec.ecv_attribute28 := ben_ecv_shd.g_old_rec.ecv_attribute28;
  end if;
  If (p_rec.ecv_attribute29 = hr_api.g_varchar2) then
      p_rec.ecv_attribute29 := ben_ecv_shd.g_old_rec.ecv_attribute29;
  end if;
  If (p_rec.ecv_attribute30 = hr_api.g_varchar2) then
      p_rec.ecv_attribute30 := ben_ecv_shd.g_old_rec.ecv_attribute30;
  end if;
  If (p_rec.criteria_score = hr_api.g_number) then
      p_rec.criteria_score := ben_ecv_shd.g_old_rec.criteria_score;
  end if;
  If (p_rec.criteria_weight = hr_api.g_number) then
      p_rec.criteria_weight := ben_ecv_shd.g_old_rec.criteria_weight;
  end if;
  If (p_rec.Char_value3 = hr_api.g_varchar2) then
      p_rec.Char_value3 := ben_ecv_shd.g_old_rec.Char_value3;
  end if;
  If (p_rec.Char_value4 = hr_api.g_varchar2) then
      p_rec.Char_value4 := ben_ecv_shd.g_old_rec.Char_value4;
  end if;
  If (p_rec.Number_value3 = hr_api.g_number) then
      p_rec.Number_value3 := ben_ecv_shd.g_old_rec.Number_value3;
  end if;
  If (p_rec.Number_value4 = hr_api.g_number) then
      p_rec.Number_value4 := ben_ecv_shd.g_old_rec.Number_value4;
  end if;
  If (p_rec.Date_value3 = hr_api.g_date) then
      p_rec.Date_value3 := ben_ecv_shd.g_old_rec.Date_value3;
  end if;
  If (p_rec.Date_value4 = hr_api.g_date) then
      p_rec.Date_value4 := ben_ecv_shd.g_old_rec.Date_value4;
  end if;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec			in out nocopy 	ben_ecv_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'upd';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  ben_ecv_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_eligy_crit_values_id	 => p_rec.eligy_crit_values_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_ecv_bus.update_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode  	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
end upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
   p_eligy_crit_values_id         In  Number
  ,p_eligy_prfl_id                In  Number       default hr_api.g_number
  ,p_eligy_criteria_id            In  Number       default hr_api.g_number
  ,p_effective_start_date         Out nocopy Date
  ,p_effective_end_date           Out nocopy Date
  ,p_ordr_num                     In  Number       default hr_api.g_number
  ,p_number_value1                In  Number       default hr_api.g_number
  ,p_number_value2                In  Number       default hr_api.g_number
  ,p_char_value1                  In  Varchar2     default hr_api.g_varchar2
  ,p_char_value2                  In  Varchar2     default hr_api.g_varchar2
  ,p_date_value1                  In  Date         default hr_api.g_date
  ,p_date_value2                  In  Date         default hr_api.g_date
  ,p_excld_flag                   In  Varchar2     default hr_api.g_Varchar2
  ,p_business_group_id            In  Number       default hr_api.g_number
  ,p_legislation_code             In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute_category       In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute1               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute2               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute3               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute4               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute5               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute6               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute7               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute8               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute9               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute10              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute11              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute12              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute13              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute14              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute15              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute16              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute17              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute18              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute19              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute20              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute21              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute22              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute23              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute24              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute25              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute26              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute27              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute28              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute29              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute30              In  Varchar2     default hr_api.g_varchar2
  ,p_object_version_number        In Out nocopy Number
  ,p_effective_date               In  Date
  ,p_datetrack_mode               In  varchar2
  ,p_criteria_score               In  Number       default hr_api.g_number
  ,p_criteria_weight              In  Number       default hr_api.g_number
  ,p_Char_value3                  In  Varchar2     default hr_api.g_varchar2
  ,p_Char_value4                  In  Varchar2     default hr_api.g_varchar2
  ,p_Number_value3                In  Number       default hr_api.g_number
  ,p_Number_value4                In  Number       default hr_api.g_number
  ,p_Date_value3                  In  Date         default hr_api.g_date
  ,p_Date_value4                  In  Date         default hr_api.g_date
  ) is
--
  l_rec		ben_ecv_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_ecv_shd.convert_args
  (
  p_eligy_crit_values_id,
  p_eligy_prfl_id,
  p_eligy_criteria_id,
  NULL,
  NULL,
  p_ordr_num,
  p_number_value1,
  p_number_value2,
  p_char_value1,
  p_char_value2,
  p_date_value1,
  p_date_value2,
  p_excld_flag,
  p_business_group_id,
  p_legislation_code,
  p_ecv_attribute_category,
  p_ecv_attribute1,
  p_ecv_attribute2,
  p_ecv_attribute3,
  p_ecv_attribute4,
  p_ecv_attribute5,
  p_ecv_attribute6,
  p_ecv_attribute7,
  p_ecv_attribute8,
  p_ecv_attribute9,
  p_ecv_attribute10,
  p_ecv_attribute11,
  p_ecv_attribute12,
  p_ecv_attribute13,
  p_ecv_attribute14,
  p_ecv_attribute15,
  p_ecv_attribute16,
  p_ecv_attribute17,
  p_ecv_attribute18,
  p_ecv_attribute19,
  p_ecv_attribute20,
  p_ecv_attribute21,
  p_ecv_attribute22,
  p_ecv_attribute23,
  p_ecv_attribute24,
  p_ecv_attribute25,
  p_ecv_attribute26,
  p_ecv_attribute27,
  p_ecv_attribute28,
  p_ecv_attribute29,
  p_ecv_attribute30,
  p_object_version_number,
  p_criteria_score,
  p_criteria_weight,
  p_Char_value3,
  p_Char_value4,
  p_Number_value3,
  p_Number_value4,
  p_Date_value3,
  p_Date_value4
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end upd;
--
end ben_ecv_upd;

/
