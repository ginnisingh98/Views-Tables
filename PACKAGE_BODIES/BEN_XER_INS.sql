--------------------------------------------------------
--  DDL for Package Body BEN_XER_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XER_INS" as
/* $Header: bexerrhi.pkb 120.1 2006/03/22 13:57:32 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xer_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_xer_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_xer_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_ext_data_elmt_in_rcd
  --
  insert into ben_ext_data_elmt_in_rcd
  (	ext_data_elmt_in_rcd_id,
	seq_num,
	strt_pos,
	dlmtr_val,
	rqd_flag,
	sprs_cd,
	any_or_all_cd,
	ext_data_elmt_id,
	ext_rcd_id,
	business_group_id,
        legislation_code,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by,
	object_version_number,
	hide_flag
  )
  Values
  (	p_rec.ext_data_elmt_in_rcd_id,
	p_rec.seq_num,
	p_rec.strt_pos,
	p_rec.dlmtr_val,
	p_rec.rqd_flag,
	p_rec.sprs_cd,
	p_rec.any_or_all_cd,
	p_rec.ext_data_elmt_id,
	p_rec.ext_rcd_id,
	p_rec.business_group_id,
        p_rec.legislation_code,
        p_rec.last_update_date,
        p_rec.creation_date,
        p_rec.last_updated_by,
        p_rec.last_update_login,
        p_rec.created_by,
	p_rec.object_version_number,
	p_rec.hide_flag
  );
  --
  ben_xer_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_xer_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xer_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_xer_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xer_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_xer_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xer_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_xer_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_xer_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_ext_data_elmt_in_rcd_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.ext_data_elmt_in_rcd_id;
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
p_effective_date in date,p_rec in ben_xer_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    -- insert ownerships if applicable
    --
    create_app_ownerships('EXT_DATA_ELMT_IN_RCD_ID', p_rec.ext_data_elmt_in_rcd_id);
    --
    --
    ben_xer_rki.after_insert
      (
  p_ext_data_elmt_in_rcd_id       =>p_rec.ext_data_elmt_in_rcd_id
 ,p_seq_num                       =>p_rec.seq_num
 ,p_strt_pos                      =>p_rec.strt_pos
 ,p_dlmtr_val                     =>p_rec.dlmtr_val
 ,p_rqd_flag                      =>p_rec.rqd_flag
 ,p_sprs_cd                       =>p_rec.sprs_cd
 ,p_any_or_all_cd                 =>p_rec.any_or_all_cd
 ,p_ext_data_elmt_id              =>p_rec.ext_data_elmt_id
 ,p_ext_rcd_id                    =>p_rec.ext_rcd_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_legislation_code              =>p_rec.legislation_code
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_hide_flag                     =>p_rec.hide_flag
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ext_data_elmt_in_rcd'
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
  p_rec        in out nocopy ben_xer_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_xer_bus.insert_validate(p_rec
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
  p_ext_data_elmt_in_rcd_id      out nocopy number,
  p_seq_num                      in number           default null,
  p_strt_pos                     in number           default null,
  p_dlmtr_val                    in varchar2         default null,
  p_rqd_flag                     in varchar2,
  p_sprs_cd                      in varchar2         default null,
  p_any_or_all_cd                in varchar2         default null,
  p_ext_data_elmt_id             in number,
  p_ext_rcd_id                   in number,
  p_business_group_id            in number,
  p_legislation_code             in varchar2         default null,
  p_last_update_date             in date             default null,
  p_creation_date                in date             default null,
  p_last_updated_by              in number           default null,
  p_last_update_login            in number           default null,
  p_created_by                   in number           default null,
  p_object_version_number        out nocopy number,
  p_hide_flag                    in varchar2
  ) is
--
  l_rec	  ben_xer_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_xer_shd.convert_args
  (
  null,
  p_seq_num,
  p_strt_pos,
  p_dlmtr_val,
  p_rqd_flag,
  p_sprs_cd,
  p_any_or_all_cd,
  p_ext_data_elmt_id,
  p_ext_rcd_id,
  p_business_group_id,
  p_legislation_code,
  p_last_update_date,
  p_creation_date   ,
  p_last_updated_by ,
  p_last_update_login,
  p_created_by       ,
  null,
  p_hide_flag
  );
  --
  -- Having converted the arguments into the ben_xer_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_ext_data_elmt_in_rcd_id := l_rec.ext_data_elmt_in_rcd_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_xer_ins;

/
