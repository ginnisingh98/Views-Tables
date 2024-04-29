--------------------------------------------------------
--  DDL for Package Body BEN_XDF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XDF_INS" as
/* $Header: bexdfrhi.pkb 120.6 2006/07/10 21:53:55 tjesumic ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xdf_ins.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure inserts a row into the HR_APPLICATION_OWNERSHIPS table
--   when the row handler is called in the appropriate mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column  IN varchar2
                               ,p_pk_value   IN varchar2) IS
--
CURSOR csr_definition (p_session_id NUMBER) IS
  SELECT product_short_name
    FROM hr_owner_definitions
   WHERE session_id = p_session_id;
--
l_session_id NUMBER;
--
BEGIN
  --
  IF (hr_startup_data_api_support.return_startup_mode IN
                               ('STARTUP','GENERIC')) THEN
  --
  l_session_id := nvl(hr_startup_data_api_support.g_startup_session_id
                     ,hr_startup_data_api_support.g_session_id);
     --
     FOR c1 IN csr_definition(l_session_id) LOOP
       --
       INSERT INTO hr_application_ownerships
         (key_name
         ,key_value
         ,product_name
         )
       VALUES
         (p_pk_column
         ,fnd_number.number_to_canonical(p_pk_value)
         ,c1.product_short_name
         );
     END LOOP;
  END IF;
END create_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column IN varchar2
                               ,p_pk_value  IN number) IS
--
BEGIN
  create_app_ownerships(p_pk_column, to_char(p_pk_value));
END create_app_ownerships;
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
Procedure insert_dml(p_rec in out nocopy ben_xdf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_xdf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_ext_dfn
  --
  insert into ben_ext_dfn
  (	ext_dfn_id,
	name,
	xml_tag_name,
	xdo_template_id,
	data_typ_cd,
	ext_typ_cd,
	output_name,
	output_type,
	apnd_rqst_id_flag,
	prmy_sort_cd,
	scnd_sort_cd,
	strt_dt,
	end_dt,
	ext_crit_prfl_id,
	ext_file_id,
	business_group_id,
        legislation_code,
	xdf_attribute_category,
	xdf_attribute1,
	xdf_attribute2,
	xdf_attribute3,
	xdf_attribute4,
	xdf_attribute5,
	xdf_attribute6,
	xdf_attribute7,
	xdf_attribute8,
	xdf_attribute9,
	xdf_attribute10,
	xdf_attribute11,
	xdf_attribute12,
	xdf_attribute13,
	xdf_attribute14,
	xdf_attribute15,
	xdf_attribute16,
	xdf_attribute17,
	xdf_attribute18,
	xdf_attribute19,
	xdf_attribute20,
	xdf_attribute21,
	xdf_attribute22,
	xdf_attribute23,
	xdf_attribute24,
	xdf_attribute25,
	xdf_attribute26,
	xdf_attribute27,
	xdf_attribute28,
	xdf_attribute29,
	xdf_attribute30,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by,
	object_version_number,
	drctry_name,
	kickoff_wrt_prc_flag,
	upd_cm_sent_dt_flag,
	spcl_hndl_flag,
	ext_global_flag,
	cm_display_flag,
	use_eff_dt_for_chgs_flag,
      ext_post_prcs_rl
  )
  Values
  (	p_rec.ext_dfn_id,
	p_rec.name,
	p_rec.xml_tag_name,
	p_rec.xdo_template_id,
	p_rec.data_typ_cd,
	p_rec.ext_typ_cd,
	p_rec.output_name,
	p_rec.output_type,
	p_rec.apnd_rqst_id_flag,
	p_rec.prmy_sort_cd,
	p_rec.scnd_sort_cd,
	p_rec.strt_dt,
	p_rec.end_dt,
	p_rec.ext_crit_prfl_id,
	p_rec.ext_file_id,
	p_rec.business_group_id,
        p_rec.legislation_code,
	p_rec.xdf_attribute_category,
	p_rec.xdf_attribute1,
	p_rec.xdf_attribute2,
	p_rec.xdf_attribute3,
	p_rec.xdf_attribute4,
	p_rec.xdf_attribute5,
	p_rec.xdf_attribute6,
	p_rec.xdf_attribute7,
	p_rec.xdf_attribute8,
	p_rec.xdf_attribute9,
	p_rec.xdf_attribute10,
	p_rec.xdf_attribute11,
	p_rec.xdf_attribute12,
	p_rec.xdf_attribute13,
	p_rec.xdf_attribute14,
	p_rec.xdf_attribute15,
	p_rec.xdf_attribute16,
	p_rec.xdf_attribute17,
	p_rec.xdf_attribute18,
	p_rec.xdf_attribute19,
	p_rec.xdf_attribute20,
	p_rec.xdf_attribute21,
	p_rec.xdf_attribute22,
	p_rec.xdf_attribute23,
	p_rec.xdf_attribute24,
	p_rec.xdf_attribute25,
	p_rec.xdf_attribute26,
	p_rec.xdf_attribute27,
	p_rec.xdf_attribute28,
	p_rec.xdf_attribute29,
	p_rec.xdf_attribute30,
        p_rec.last_update_date,
        p_rec.creation_date,
        p_rec.last_updated_by,
        p_rec.last_update_login,
        p_rec.created_by,
	p_rec.object_version_number,
	p_rec.drctry_name,
	p_rec.kickoff_wrt_prc_flag,
	p_rec.upd_cm_sent_dt_flag,
	p_rec.spcl_hndl_flag,
	p_rec.ext_global_flag,
	p_rec.cm_display_flag,
	p_rec.use_eff_dt_for_chgs_flag,
      p_rec.ext_post_prcs_rl
  );
  --
  ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xdf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xdf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xdf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_xdf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_ext_dfn_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.ext_dfn_id;
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
Procedure post_insert(
p_effective_date in date,p_rec in ben_xdf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
    -- insert ownerships if applicable
    --
    create_app_ownerships('EXT_DFN_ID', p_rec.ext_dfn_id);

  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_xdf_rki.after_insert
      (
  p_ext_dfn_id                    =>p_rec.ext_dfn_id
 ,p_name                          =>p_rec.name
 ,p_xml_tag_name                  =>p_rec.xml_tag_name
 ,p_xdo_template_id               =>p_rec.xdo_template_id
 ,p_data_typ_cd                   =>p_rec.data_typ_cd
 ,p_ext_typ_cd                    =>p_rec.ext_typ_cd
 ,p_output_name                   =>p_rec.output_name
 ,p_output_type                   =>p_rec.output_type
 ,p_apnd_rqst_id_flag             =>p_rec.apnd_rqst_id_flag
 ,p_prmy_sort_cd                  =>p_rec.prmy_sort_cd
 ,p_scnd_sort_cd                  =>p_rec.scnd_sort_cd
 ,p_strt_dt                       =>p_rec.strt_dt
 ,p_end_dt                        =>p_rec.end_dt
 ,p_ext_crit_prfl_id              =>p_rec.ext_crit_prfl_id
 ,p_ext_file_id                   =>p_rec.ext_file_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_legislation_code              =>p_rec.legislation_code
 ,p_xdf_attribute_category        =>p_rec.xdf_attribute_category
 ,p_xdf_attribute1                =>p_rec.xdf_attribute1
 ,p_xdf_attribute2                =>p_rec.xdf_attribute2
 ,p_xdf_attribute3                =>p_rec.xdf_attribute3
 ,p_xdf_attribute4                =>p_rec.xdf_attribute4
 ,p_xdf_attribute5                =>p_rec.xdf_attribute5
 ,p_xdf_attribute6                =>p_rec.xdf_attribute6
 ,p_xdf_attribute7                =>p_rec.xdf_attribute7
 ,p_xdf_attribute8                =>p_rec.xdf_attribute8
 ,p_xdf_attribute9                =>p_rec.xdf_attribute9
 ,p_xdf_attribute10               =>p_rec.xdf_attribute10
 ,p_xdf_attribute11               =>p_rec.xdf_attribute11
 ,p_xdf_attribute12               =>p_rec.xdf_attribute12
 ,p_xdf_attribute13               =>p_rec.xdf_attribute13
 ,p_xdf_attribute14               =>p_rec.xdf_attribute14
 ,p_xdf_attribute15               =>p_rec.xdf_attribute15
 ,p_xdf_attribute16               =>p_rec.xdf_attribute16
 ,p_xdf_attribute17               =>p_rec.xdf_attribute17
 ,p_xdf_attribute18               =>p_rec.xdf_attribute18
 ,p_xdf_attribute19               =>p_rec.xdf_attribute19
 ,p_xdf_attribute20               =>p_rec.xdf_attribute20
 ,p_xdf_attribute21               =>p_rec.xdf_attribute21
 ,p_xdf_attribute22               =>p_rec.xdf_attribute22
 ,p_xdf_attribute23               =>p_rec.xdf_attribute23
 ,p_xdf_attribute24               =>p_rec.xdf_attribute24
 ,p_xdf_attribute25               =>p_rec.xdf_attribute25
 ,p_xdf_attribute26               =>p_rec.xdf_attribute26
 ,p_xdf_attribute27               =>p_rec.xdf_attribute27
 ,p_xdf_attribute28               =>p_rec.xdf_attribute28
 ,p_xdf_attribute29               =>p_rec.xdf_attribute29
 ,p_xdf_attribute30               =>p_rec.xdf_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_drctry_name                   =>p_rec.drctry_name
 ,p_kickoff_wrt_prc_flag          =>p_rec.kickoff_wrt_prc_flag
 ,p_upd_cm_sent_dt_flag           =>p_rec.upd_cm_sent_dt_flag
 ,p_spcl_hndl_flag                =>p_rec.spcl_hndl_flag
 ,p_ext_global_flag               =>p_rec.ext_global_flag
 ,p_cm_display_flag               =>p_rec.cm_display_flag
 ,p_use_eff_dt_for_chgs_flag      =>p_rec.use_eff_dt_for_chgs_flag
 ,p_ext_post_prcs_rl              =>p_rec.ext_post_prcs_rl
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ext_dfn'
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
  p_effective_date in date,
  p_rec        in out nocopy ben_xdf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_xdf_bus.insert_validate(p_rec
  ,p_effective_date);

   ben_xel_bus.chk_xml_name_format
          ( p_xml_tag_name    => p_rec.xml_tag_name
          ) ;

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
  post_insert(
p_effective_date,p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_ext_dfn_id                   out nocopy number,
  p_name                         in varchar2         default null,
  p_xml_tag_name                 in varchar2         default null,
  p_xdo_template_id              in number         default null,
  p_data_typ_cd                  in varchar2         default null,
  p_ext_typ_cd                   in varchar2         default null,
  p_output_name                  in varchar2         default null,
  p_output_type                  in varchar2         default null,
  p_apnd_rqst_id_flag            in varchar2,
  p_prmy_sort_cd                 in varchar2         default null,
  p_scnd_sort_cd                 in varchar2         default null,
  p_strt_dt                      in varchar2         default null,
  p_end_dt                       in varchar2         default null,
  p_ext_crit_prfl_id             in number           default null,
  p_ext_file_id                  in number           default null,
  p_business_group_id            in number,
  p_legislation_code             in varchar2,
  p_xdf_attribute_category       in varchar2         default null,
  p_xdf_attribute1               in varchar2         default null,
  p_xdf_attribute2               in varchar2         default null,
  p_xdf_attribute3               in varchar2         default null,
  p_xdf_attribute4               in varchar2         default null,
  p_xdf_attribute5               in varchar2         default null,
  p_xdf_attribute6               in varchar2         default null,
  p_xdf_attribute7               in varchar2         default null,
  p_xdf_attribute8               in varchar2         default null,
  p_xdf_attribute9               in varchar2         default null,
  p_xdf_attribute10              in varchar2         default null,
  p_xdf_attribute11              in varchar2         default null,
  p_xdf_attribute12              in varchar2         default null,
  p_xdf_attribute13              in varchar2         default null,
  p_xdf_attribute14              in varchar2         default null,
  p_xdf_attribute15              in varchar2         default null,
  p_xdf_attribute16              in varchar2         default null,
  p_xdf_attribute17              in varchar2         default null,
  p_xdf_attribute18              in varchar2         default null,
  p_xdf_attribute19              in varchar2         default null,
  p_xdf_attribute20              in varchar2         default null,
  p_xdf_attribute21              in varchar2         default null,
  p_xdf_attribute22              in varchar2         default null,
  p_xdf_attribute23              in varchar2         default null,
  p_xdf_attribute24              in varchar2         default null,
  p_xdf_attribute25              in varchar2         default null,
  p_xdf_attribute26              in varchar2         default null,
  p_xdf_attribute27              in varchar2         default null,
  p_xdf_attribute28              in varchar2         default null,
  p_xdf_attribute29              in varchar2         default null,
  p_xdf_attribute30              in varchar2         default null,
  p_last_update_date             in date             default null,
  p_creation_date                in date             default null,
  p_last_updated_by              in number           default null,
  p_last_update_login            in number           default null,
  p_created_by                   in number           default null,
  p_object_version_number        out nocopy number,
  p_drctry_name                  in varchar2         default null,
  p_kickoff_wrt_prc_flag         in varchar2,
  p_upd_cm_sent_dt_flag          in varchar2         default null,
  p_spcl_hndl_flag               in varchar2         default null,
  p_ext_global_flag              in varchar2         default null,
  p_cm_display_flag              in varchar2         default null,
  p_use_eff_dt_for_chgs_flag     in varchar2         default null,
  p_ext_post_prcs_rl             in number           default null
  ) is
--
  l_rec	  ben_xdf_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_xdf_shd.convert_args
  (
  null,
  p_name,
  p_xml_tag_name,
  p_xdo_template_id,
  p_data_typ_cd,
  p_ext_typ_cd,
  p_output_name,
  p_output_type,
  p_apnd_rqst_id_flag,
  p_prmy_sort_cd,
  p_scnd_sort_cd,
  p_strt_dt,
  p_end_dt,
  p_ext_crit_prfl_id,
  p_ext_file_id,
  p_business_group_id,
  p_legislation_code,
  p_xdf_attribute_category,
  p_xdf_attribute1,
  p_xdf_attribute2,
  p_xdf_attribute3,
  p_xdf_attribute4,
  p_xdf_attribute5,
  p_xdf_attribute6,
  p_xdf_attribute7,
  p_xdf_attribute8,
  p_xdf_attribute9,
  p_xdf_attribute10,
  p_xdf_attribute11,
  p_xdf_attribute12,
  p_xdf_attribute13,
  p_xdf_attribute14,
  p_xdf_attribute15,
  p_xdf_attribute16,
  p_xdf_attribute17,
  p_xdf_attribute18,
  p_xdf_attribute19,
  p_xdf_attribute20,
  p_xdf_attribute21,
  p_xdf_attribute22,
  p_xdf_attribute23,
  p_xdf_attribute24,
  p_xdf_attribute25,
  p_xdf_attribute26,
  p_xdf_attribute27,
  p_xdf_attribute28,
  p_xdf_attribute29,
  p_xdf_attribute30,
  p_last_update_date,
  p_creation_date   ,
  p_last_updated_by ,
  p_last_update_login,
  p_created_by       ,
  null,
  p_drctry_name,
  p_kickoff_wrt_prc_flag,
  p_upd_cm_sent_dt_flag,
  p_spcl_hndl_flag,
  p_ext_global_flag,
  p_cm_display_flag,
  p_use_eff_dt_for_chgs_flag,
  p_ext_post_prcs_rl
  );
  --
  -- Having converted the arguments into the ben_xdf_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_ext_dfn_id := l_rec.ext_dfn_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_xdf_ins;

/
