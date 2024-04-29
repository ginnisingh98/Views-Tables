--------------------------------------------------------
--  DDL for Package Body BEN_XCR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCR_INS" as
/* $Header: bexcrrhi.pkb 120.0 2005/05/28 12:25:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xcr_ins.';  -- Global package name

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
Procedure insert_dml(p_rec in out nocopy ben_xcr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_xcr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_ext_crit_prfl
  --
  insert into ben_ext_crit_prfl
  (	ext_crit_prfl_id,
	name,
	business_group_id,
	legislation_code,
	xcr_attribute_category,
	xcr_attribute1,
	xcr_attribute2,
	xcr_attribute3,
	xcr_attribute4,
	xcr_attribute5,
	xcr_attribute6,
	xcr_attribute7,
	xcr_attribute8,
	xcr_attribute9,
	xcr_attribute10,
	xcr_attribute11,
	xcr_attribute12,
	xcr_attribute13,
	xcr_attribute14,
	xcr_attribute15,
	xcr_attribute16,
	xcr_attribute17,
	xcr_attribute18,
	xcr_attribute19,
	xcr_attribute20,
	xcr_attribute21,
	xcr_attribute22,
	xcr_attribute23,
	xcr_attribute24,
	xcr_attribute25,
	xcr_attribute26,
	xcr_attribute27,
	xcr_attribute28,
	xcr_attribute29,
	xcr_attribute30,
	ext_global_flag,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by,
	object_version_number
  )
  Values
  (	p_rec.ext_crit_prfl_id,
	p_rec.name,
	p_rec.business_group_id,
	p_rec.legislation_code,
	p_rec.xcr_attribute_category,
	p_rec.xcr_attribute1,
	p_rec.xcr_attribute2,
	p_rec.xcr_attribute3,
	p_rec.xcr_attribute4,
	p_rec.xcr_attribute5,
	p_rec.xcr_attribute6,
	p_rec.xcr_attribute7,
	p_rec.xcr_attribute8,
	p_rec.xcr_attribute9,
	p_rec.xcr_attribute10,
	p_rec.xcr_attribute11,
	p_rec.xcr_attribute12,
	p_rec.xcr_attribute13,
	p_rec.xcr_attribute14,
	p_rec.xcr_attribute15,
	p_rec.xcr_attribute16,
	p_rec.xcr_attribute17,
	p_rec.xcr_attribute18,
	p_rec.xcr_attribute19,
	p_rec.xcr_attribute20,
	p_rec.xcr_attribute21,
	p_rec.xcr_attribute22,
	p_rec.xcr_attribute23,
	p_rec.xcr_attribute24,
	p_rec.xcr_attribute25,
	p_rec.xcr_attribute26,
	p_rec.xcr_attribute27,
	p_rec.xcr_attribute28,
	p_rec.xcr_attribute29,
	p_rec.xcr_attribute30,
	p_rec.ext_global_flag,
        p_rec.last_update_date,
        p_rec.creation_date,
        p_rec.last_updated_by,
        p_rec.last_update_login,
        p_rec.created_by,
	p_rec.object_version_number
  );
  --
  ben_xcr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_xcr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xcr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_xcr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xcr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_xcr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xcr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_xcr_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_xcr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_ext_crit_prfl_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.ext_crit_prfl_id;
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
Procedure post_insert(p_rec in ben_xcr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  create_app_ownerships('EXT_CRIT_PRFL_ID', p_rec.ext_crit_prfl_id);
  --
  -- Start of API User Hook for post_insert.
  --
  begin

    --
    ben_xcr_rki.after_insert
      (
  p_ext_crit_prfl_id              =>p_rec.ext_crit_prfl_id
 ,p_name                          =>p_rec.name
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_legislation_code              =>p_rec.legislation_code
 ,p_xcr_attribute_category        =>p_rec.xcr_attribute_category
 ,p_xcr_attribute1                =>p_rec.xcr_attribute1
 ,p_xcr_attribute2                =>p_rec.xcr_attribute2
 ,p_xcr_attribute3                =>p_rec.xcr_attribute3
 ,p_xcr_attribute4                =>p_rec.xcr_attribute4
 ,p_xcr_attribute5                =>p_rec.xcr_attribute5
 ,p_xcr_attribute6                =>p_rec.xcr_attribute6
 ,p_xcr_attribute7                =>p_rec.xcr_attribute7
 ,p_xcr_attribute8                =>p_rec.xcr_attribute8
 ,p_xcr_attribute9                =>p_rec.xcr_attribute9
 ,p_xcr_attribute10               =>p_rec.xcr_attribute10
 ,p_xcr_attribute11               =>p_rec.xcr_attribute11
 ,p_xcr_attribute12               =>p_rec.xcr_attribute12
 ,p_xcr_attribute13               =>p_rec.xcr_attribute13
 ,p_xcr_attribute14               =>p_rec.xcr_attribute14
 ,p_xcr_attribute15               =>p_rec.xcr_attribute15
 ,p_xcr_attribute16               =>p_rec.xcr_attribute16
 ,p_xcr_attribute17               =>p_rec.xcr_attribute17
 ,p_xcr_attribute18               =>p_rec.xcr_attribute18
 ,p_xcr_attribute19               =>p_rec.xcr_attribute19
 ,p_xcr_attribute20               =>p_rec.xcr_attribute20
 ,p_xcr_attribute21               =>p_rec.xcr_attribute21
 ,p_xcr_attribute22               =>p_rec.xcr_attribute22
 ,p_xcr_attribute23               =>p_rec.xcr_attribute23
 ,p_xcr_attribute24               =>p_rec.xcr_attribute24
 ,p_xcr_attribute25               =>p_rec.xcr_attribute25
 ,p_xcr_attribute26               =>p_rec.xcr_attribute26
 ,p_xcr_attribute27               =>p_rec.xcr_attribute27
 ,p_xcr_attribute28               =>p_rec.xcr_attribute28
 ,p_xcr_attribute29               =>p_rec.xcr_attribute29
 ,p_xcr_attribute30               =>p_rec.xcr_attribute30
 ,p_ext_global_flag               =>p_rec.ext_global_flag
 ,p_object_version_number         =>p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ext_crit_prfl'
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
  p_rec        in out nocopy ben_xcr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_xcr_bus.insert_validate(p_rec);
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
  post_insert(p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_ext_crit_prfl_id             out nocopy number,
  p_name                         in varchar2         default null,
  p_business_group_id            in number,
  p_legislation_code             in varchar2         default null,
  p_xcr_attribute_category       in varchar2         default null,
  p_xcr_attribute1               in varchar2         default null,
  p_xcr_attribute2               in varchar2         default null,
  p_xcr_attribute3               in varchar2         default null,
  p_xcr_attribute4               in varchar2         default null,
  p_xcr_attribute5               in varchar2         default null,
  p_xcr_attribute6               in varchar2         default null,
  p_xcr_attribute7               in varchar2         default null,
  p_xcr_attribute8               in varchar2         default null,
  p_xcr_attribute9               in varchar2         default null,
  p_xcr_attribute10              in varchar2         default null,
  p_xcr_attribute11              in varchar2         default null,
  p_xcr_attribute12              in varchar2         default null,
  p_xcr_attribute13              in varchar2         default null,
  p_xcr_attribute14              in varchar2         default null,
  p_xcr_attribute15              in varchar2         default null,
  p_xcr_attribute16              in varchar2         default null,
  p_xcr_attribute17              in varchar2         default null,
  p_xcr_attribute18              in varchar2         default null,
  p_xcr_attribute19              in varchar2         default null,
  p_xcr_attribute20              in varchar2         default null,
  p_xcr_attribute21              in varchar2         default null,
  p_xcr_attribute22              in varchar2         default null,
  p_xcr_attribute23              in varchar2         default null,
  p_xcr_attribute24              in varchar2         default null,
  p_xcr_attribute25              in varchar2         default null,
  p_xcr_attribute26              in varchar2         default null,
  p_xcr_attribute27              in varchar2         default null,
  p_xcr_attribute28              in varchar2         default null,
  p_xcr_attribute29              in varchar2         default null,
  p_xcr_attribute30              in varchar2         default null,
  p_ext_global_flag              in varchar2         default null,
  p_last_update_date             in date             default null,
  p_creation_date                in date             default null,
  p_last_updated_by              in number           default null,
  p_last_update_login            in number           default null,
  p_created_by                   in number           default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_xcr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_xcr_shd.convert_args
  (
  null,
  p_name,
  p_business_group_id,
  p_legislation_code,
  p_xcr_attribute_category,
  p_xcr_attribute1,
  p_xcr_attribute2,
  p_xcr_attribute3,
  p_xcr_attribute4,
  p_xcr_attribute5,
  p_xcr_attribute6,
  p_xcr_attribute7,
  p_xcr_attribute8,
  p_xcr_attribute9,
  p_xcr_attribute10,
  p_xcr_attribute11,
  p_xcr_attribute12,
  p_xcr_attribute13,
  p_xcr_attribute14,
  p_xcr_attribute15,
  p_xcr_attribute16,
  p_xcr_attribute17,
  p_xcr_attribute18,
  p_xcr_attribute19,
  p_xcr_attribute20,
  p_xcr_attribute21,
  p_xcr_attribute22,
  p_xcr_attribute23,
  p_xcr_attribute24,
  p_xcr_attribute25,
  p_xcr_attribute26,
  p_xcr_attribute27,
  p_xcr_attribute28,
  p_xcr_attribute29,
  p_xcr_attribute30,
  p_ext_global_flag,
  p_last_update_date,
  p_creation_date   ,
  p_last_updated_by ,
  p_last_update_login,
  p_created_by       ,
  null
  );
  --
  -- Having converted the arguments into the ben_xcr_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_ext_crit_prfl_id := l_rec.ext_crit_prfl_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_xcr_ins;

/
