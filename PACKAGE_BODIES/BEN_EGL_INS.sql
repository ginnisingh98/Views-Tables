--------------------------------------------------------
--  DDL for Package Body BEN_EGL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EGL_INS" as

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_egl_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
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
Procedure insert_dml(p_rec in out nocopy ben_egl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_egl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_eligy_criteria
  --
  insert into ben_eligy_criteria
  (
    eligy_criteria_id,
    name,
    short_code,
    description,
    criteria_type,
    crit_col1_val_type_cd,
    crit_col1_datatype,
    col1_lookup_type,
    col1_value_set_id,
    access_table_name1,
    access_column_name1,
    time_entry_access_table_name1,
    time_entry_access_col_name1,
    crit_col2_val_type_cd,
    crit_col2_datatype,
    col2_lookup_type,
    col2_value_set_id,
    access_table_name2,
    access_column_name2,
    time_entry_access_table_name2,
    time_entry_access_col_name2,
    access_calc_rule,
    allow_range_validation_flag,
    user_defined_flag,
    business_group_id,
    legislation_code,
    egl_attribute_category,
    egl_attribute1,
    egl_attribute2,
    egl_attribute3,
    egl_attribute4,
    egl_attribute5,
    egl_attribute6,
    egl_attribute7,
    egl_attribute8,
    egl_attribute9,
    egl_attribute10,
    egl_attribute11,
    egl_attribute12,
    egl_attribute13,
    egl_attribute14,
    egl_attribute15,
    egl_attribute16,
    egl_attribute17,
    egl_attribute18,
    egl_attribute19,
    egl_attribute20,
    egl_attribute21,
    egl_attribute22,
    egl_attribute23,
    egl_attribute24,
    egl_attribute25,
    egl_attribute26,
    egl_attribute27,
    egl_attribute28,
    egl_attribute29,
    egl_attribute30,
    object_version_number,
    allow_range_validation_flag2,
    access_calc_rule2,
    time_access_calc_rule1,
    time_access_calc_rule2
  )
  Values
  (	p_rec.eligy_criteria_id,
	p_rec.name,
	p_rec.short_code,
	p_rec.description,
	p_rec.criteria_type,
	p_rec.crit_col1_val_type_cd,
	p_rec.crit_col1_datatype,
	p_rec.col1_lookup_type,
	p_rec.col1_value_set_id,
	p_rec.access_table_name1,
	p_rec.access_column_name1,
	p_rec.time_entry_access_tab_nam1,
	p_rec.time_entry_access_col_nam1,
	p_rec.crit_col2_val_type_cd,
	p_rec.crit_col2_datatype,
	p_rec.col2_lookup_type,
	p_rec.col2_value_set_id,
	p_rec.access_table_name2,
	p_rec.access_column_name2,
	p_rec.time_entry_access_tab_nam2,
	p_rec.time_entry_access_col_nam2,
	p_rec.access_calc_rule,
	p_rec.allow_range_validation_flg,
	p_rec.user_defined_flag,
	p_rec.business_group_id,
	p_rec.legislation_code,
	p_rec.egl_attribute_category,
	p_rec.egl_attribute1,
	p_rec.egl_attribute2,
	p_rec.egl_attribute3,
	p_rec.egl_attribute4,
	p_rec.egl_attribute5,
	p_rec.egl_attribute6,
	p_rec.egl_attribute7,
	p_rec.egl_attribute8,
	p_rec.egl_attribute9,
	p_rec.egl_attribute10,
	p_rec.egl_attribute11,
	p_rec.egl_attribute12,
	p_rec.egl_attribute13,
	p_rec.egl_attribute14,
	p_rec.egl_attribute15,
	p_rec.egl_attribute16,
	p_rec.egl_attribute17,
	p_rec.egl_attribute18,
	p_rec.egl_attribute19,
	p_rec.egl_attribute20,
	p_rec.egl_attribute21,
	p_rec.egl_attribute22,
	p_rec.egl_attribute23,
	p_rec.egl_attribute24,
	p_rec.egl_attribute25,
	p_rec.egl_attribute26,
	p_rec.egl_attribute27,
	p_rec.egl_attribute28,
	p_rec.egl_attribute29,
	p_rec.egl_attribute30,
	p_rec.object_version_number,
        p_Rec.allow_range_validation_flag2,
        p_rec.access_calc_rule2,
        p_rec.time_access_calc_rule1,
        p_Rec.time_access_calc_rule2
  );
  --
  ben_egl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_egl_shd.g_api_dml := false;   -- Unset the api dml status
    ben_egl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_egl_shd.g_api_dml := false;   -- Unset the api dml status
    ben_egl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_egl_shd.g_api_dml := false;   -- Unset the api dml status
    ben_egl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_egl_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ben_egl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_eligy_criteria_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.eligy_criteria_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ben_egl_shd.g_rec_type
		      ,p_effective_date in date) is
--
  l_proc  varchar2(72)      := g_package||'post_insert';
  l_eligy_criteria_id       ben_eligy_criteria.eligy_criteria_id%TYPE;
--
Begin

hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_egl_rki.after_insert
      (
         p_eligy_criteria_id                =>   p_rec.eligy_criteria_id
        ,p_name                             => 	 p_rec.name
        ,p_short_code                       => 	 p_rec.short_code
        ,p_description                      => 	 p_rec.description
        ,p_criteria_type		    => 	 p_rec.criteria_type
        ,p_crit_col1_val_type_cd	    => 	 p_rec.crit_col1_val_type_cd
        ,p_crit_col1_datatype	      	    => 	 p_rec.crit_col1_datatype
        ,p_col1_lookup_type		    => 	 p_rec.col1_lookup_type
        ,p_col1_value_set_id          	    => 	 p_rec.col1_value_set_id
        ,p_access_table_name1         	    => 	 p_rec.access_table_name1
        ,p_access_column_name1	      	    => 	 p_rec.access_column_name1
        ,p_time_entry_access_tab_nam1 	    => 	 p_rec.time_entry_access_tab_nam1
        ,p_time_entry_access_col_nam1 	    => 	 p_rec.time_entry_access_col_nam1
        ,p_crit_col2_val_type_cd	    => 	 p_rec.crit_col2_val_type_cd
        ,p_crit_col2_datatype	      	    => 	 p_rec.crit_col2_datatype
        ,p_col2_lookup_type		    => 	 p_rec.col2_lookup_type
        ,p_col2_value_set_id          	    => 	 p_rec.col2_value_set_id
        ,p_access_table_name2	      	    => 	 p_rec.access_table_name2
        ,p_access_column_name2	      	    => 	 p_rec.access_column_name2
        ,p_time_entry_access_tab_nam2 	    => 	 p_rec.time_entry_access_tab_nam2
        ,p_time_entry_access_col_nam2 	    => 	 p_rec.time_entry_access_col_nam2
        ,p_access_calc_rule		    => 	 p_rec.access_calc_rule
        ,p_allow_range_validation_flg 	    => 	 p_rec.allow_range_validation_flg
        ,p_user_defined_flag          	    => 	 p_rec.user_defined_flag
        ,p_business_group_id 	      	    => 	 p_rec.business_group_id
        ,p_legislation_code 	      	    => 	 p_rec.legislation_code
        ,p_egl_attribute_category           => 	 p_rec.egl_attribute_category
        ,p_egl_attribute1                   => 	 p_rec.egl_attribute1
        ,p_egl_attribute2                   => 	 p_rec.egl_attribute2
        ,p_egl_attribute3                   => 	 p_rec.egl_attribute3
        ,p_egl_attribute4                   => 	 p_rec.egl_attribute4
        ,p_egl_attribute5                   => 	 p_rec.egl_attribute5
        ,p_egl_attribute6                   => 	 p_rec.egl_attribute6
        ,p_egl_attribute7                   => 	 p_rec.egl_attribute7
        ,p_egl_attribute8                   => 	 p_rec.egl_attribute8
        ,p_egl_attribute9                   => 	 p_rec.egl_attribute9
        ,p_egl_attribute10                  => 	 p_rec.egl_attribute10
        ,p_egl_attribute11                  => 	 p_rec.egl_attribute11
        ,p_egl_attribute12                  => 	 p_rec.egl_attribute12
        ,p_egl_attribute13                  => 	 p_rec.egl_attribute13
        ,p_egl_attribute14                  => 	 p_rec.egl_attribute14
        ,p_egl_attribute15                  => 	 p_rec.egl_attribute15
        ,p_egl_attribute16                  => 	 p_rec.egl_attribute16
        ,p_egl_attribute17                  => 	 p_rec.egl_attribute17
        ,p_egl_attribute18                  => 	 p_rec.egl_attribute18
        ,p_egl_attribute19                  => 	 p_rec.egl_attribute19
        ,p_egl_attribute20                  => 	 p_rec.egl_attribute20
        ,p_egl_attribute21                  => 	 p_rec.egl_attribute21
        ,p_egl_attribute22                  => 	 p_rec.egl_attribute22
        ,p_egl_attribute23                  => 	 p_rec.egl_attribute23
        ,p_egl_attribute24                  => 	 p_rec.egl_attribute24
        ,p_egl_attribute25                  => 	 p_rec.egl_attribute25
        ,p_egl_attribute26                  => 	 p_rec.egl_attribute26
        ,p_egl_attribute27                  =>	 p_rec.egl_attribute27
        ,p_egl_attribute28                  =>	 p_rec.egl_attribute28
        ,p_egl_attribute29                  =>	 p_rec.egl_attribute29
        ,p_egl_attribute30                  =>	 p_rec.egl_attribute30
        ,p_object_version_number            =>	 p_rec.object_version_number
	,p_effective_date     		    =>   p_effective_date
        ,p_allow_range_validation_flag2     =>   p_rec.allow_range_validation_flag2
        ,p_access_calc_rule2		    => 	 p_rec.access_calc_rule2
        ,p_time_access_calc_rule1	    => 	 p_rec.time_access_calc_rule1
        ,p_time_access_calc_rule2	    => 	 p_rec.time_access_calc_rule2

     );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_eligy_criteria'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ben_egl_shd.g_rec_type
  ,p_effective_date in date
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_egl_bus.insert_validate(p_rec
  			      ,p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec
  	     ,p_effective_date);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
    p_eligy_criteria_id              out nocopy number
   ,p_name                           in  varchar2     default null
   ,p_short_code                     in  varchar2     default null
   ,p_description                    in  varchar2     default null
   ,p_criteria_type		     in  varchar2     default null
   ,p_crit_col1_val_type_cd	     in  varchar2     default null
   ,p_crit_col1_datatype	     in  varchar2     default null
   ,p_col1_lookup_type		     in  varchar2     default null
   ,p_col1_value_set_id              in  number       default null
   ,p_access_table_name1             in  varchar2     default null
   ,p_access_column_name1	     in  varchar2     default null
   ,p_time_entry_access_tab_nam1     in  varchar2     default null
   ,p_time_entry_access_col_nam1     in  varchar2     default null
   ,p_crit_col2_val_type_cd	     in  varchar2     default null
   ,p_crit_col2_datatype	     in  varchar2     default null
   ,p_col2_lookup_type		     in  varchar2     default null
   ,p_col2_value_set_id              in  number       default null
   ,p_access_table_name2	     in  varchar2     default null
   ,p_access_column_name2	     in  varchar2     default null
   ,p_time_entry_access_tab_nam2     in  varchar2     default null
   ,p_time_entry_access_col_nam2     in  varchar2     default null
   ,p_access_calc_rule		     in  number       default null
   ,p_allow_range_validation_flg     in  varchar2     default null
   ,p_user_defined_flag              in  varchar2     default null
   ,p_business_group_id 	     in  number       default null
   ,p_legislation_code 	             in  varchar2     default null
   ,p_egl_attribute_category         in  varchar2     default null
   ,p_egl_attribute1                 in  varchar2     default null
   ,p_egl_attribute2                 in  varchar2     default null
   ,p_egl_attribute3                 in  varchar2     default null
   ,p_egl_attribute4                 in  varchar2     default null
   ,p_egl_attribute5                 in  varchar2     default null
   ,p_egl_attribute6                 in  varchar2     default null
   ,p_egl_attribute7                 in  varchar2     default null
   ,p_egl_attribute8                 in  varchar2     default null
   ,p_egl_attribute9                 in  varchar2     default null
   ,p_egl_attribute10                in  varchar2     default null
   ,p_egl_attribute11                in  varchar2     default null
   ,p_egl_attribute12                in  varchar2     default null
   ,p_egl_attribute13                in  varchar2     default null
   ,p_egl_attribute14                in  varchar2     default null
   ,p_egl_attribute15                in  varchar2     default null
   ,p_egl_attribute16                in  varchar2     default null
   ,p_egl_attribute17                in  varchar2     default null
   ,p_egl_attribute18                in  varchar2     default null
   ,p_egl_attribute19                in  varchar2     default null
   ,p_egl_attribute20                in  varchar2     default null
   ,p_egl_attribute21                in  varchar2     default null
   ,p_egl_attribute22                in  varchar2     default null
   ,p_egl_attribute23                in  varchar2     default null
   ,p_egl_attribute24                in  varchar2     default null
   ,p_egl_attribute25                in  varchar2     default null
   ,p_egl_attribute26                in  varchar2     default null
   ,p_egl_attribute27                in  varchar2     default null
   ,p_egl_attribute28                in  varchar2     default null
   ,p_egl_attribute29                in  varchar2     default null
   ,p_egl_attribute30                in  varchar2     default null
   ,p_object_version_number          out nocopy number
   ,p_effective_date                 in date
   ,p_allow_range_validation_flag2   in  varchar2     default null
   ,p_access_calc_rule2		     in  number       default null
   ,p_time_access_calc_rule1	     in  number       default null
   ,p_time_access_calc_rule2	     in  number       default null
  ) is
--
  l_rec	  ben_egl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
    -- Call conversion function to turn arguments into the
    -- p_rec structure.
    --
    l_rec :=
    ben_egl_shd.convert_args
    (
     null
    ,p_name
    ,p_short_code
    ,p_description
    ,p_criteria_type
    ,p_crit_col1_val_type_cd
    ,p_crit_col1_datatype
    ,p_col1_lookup_type
    ,p_col1_value_set_id
    ,p_access_table_name1
    ,p_access_column_name1
    ,p_time_entry_access_tab_nam1
    ,p_time_entry_access_col_nam1
    ,p_crit_col2_val_type_cd
    ,p_crit_col2_datatype
    ,p_col2_lookup_type
    ,p_col2_value_set_id
    ,p_access_table_name2
    ,p_access_column_name2
    ,p_time_entry_access_tab_nam2
    ,p_time_entry_access_col_nam2
    ,p_access_calc_rule
    ,p_allow_range_validation_flg
    ,p_user_defined_flag
    ,p_business_group_id
    ,p_legislation_code
    ,p_egl_attribute_category
    ,p_egl_attribute1
    ,p_egl_attribute2
    ,p_egl_attribute3
    ,p_egl_attribute4
    ,p_egl_attribute5
    ,p_egl_attribute6
    ,p_egl_attribute7
    ,p_egl_attribute8
    ,p_egl_attribute9
    ,p_egl_attribute10
    ,p_egl_attribute11
    ,p_egl_attribute12
    ,p_egl_attribute13
    ,p_egl_attribute14
    ,p_egl_attribute15
    ,p_egl_attribute16
    ,p_egl_attribute17
    ,p_egl_attribute18
    ,p_egl_attribute19
    ,p_egl_attribute20
    ,p_egl_attribute21
    ,p_egl_attribute22
    ,p_egl_attribute23
    ,p_egl_attribute24
    ,p_egl_attribute25
    ,p_egl_attribute26
    ,p_egl_attribute27
    ,p_egl_attribute28
    ,p_egl_attribute29
    ,p_egl_attribute30
    ,null
    ,p_allow_range_validation_flag2
    ,p_access_calc_rule2
    ,p_time_access_calc_rule1
    ,p_time_access_calc_rule2
    );
    --
    -- Having converted the arguments into the ben_egl_rec
    -- plsql record structure we call the corresponding record business process.
    --
    ins(l_rec
       ,p_effective_date);
    --
    -- As the primary key argument(s)
    -- are specified as an OUT's we must set these values.
    --
    p_eligy_criteria_id     := l_rec.eligy_criteria_id;
    p_object_version_number := l_rec.object_version_number;
    --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_egl_ins;

/