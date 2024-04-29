--------------------------------------------------------
--  DDL for Package Body BEN_EAT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EAT_INS" as
/* $Header: beeatrhi.pkb 115.11 2002/12/16 11:53:54 vsethi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_eat_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_eat_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_eat_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_actn_typ
  --
  insert into ben_actn_typ
  (	actn_typ_id,
	business_group_id,
	type_cd,
	name,
        description,
	eat_attribute_category,
	eat_attribute1,
	eat_attribute2,
	eat_attribute3,
	eat_attribute4,
	eat_attribute5,
	eat_attribute6,
	eat_attribute7,
	eat_attribute8,
	eat_attribute9,
	eat_attribute10,
	eat_attribute11,
	eat_attribute12,
	eat_attribute13,
	eat_attribute14,
	eat_attribute15,
	eat_attribute16,
	eat_attribute17,
	eat_attribute18,
	eat_attribute19,
	eat_attribute20,
	eat_attribute21,
	eat_attribute22,
	eat_attribute23,
	eat_attribute24,
	eat_attribute25,
	eat_attribute26,
	eat_attribute27,
	eat_attribute28,
	eat_attribute29,
	eat_attribute30,
	object_version_number
  )
  Values
  (	p_rec.actn_typ_id,
	p_rec.business_group_id,
	p_rec.type_cd,
	p_rec.name,
        p_rec.description,
	p_rec.eat_attribute_category,
	p_rec.eat_attribute1,
	p_rec.eat_attribute2,
	p_rec.eat_attribute3,
	p_rec.eat_attribute4,
	p_rec.eat_attribute5,
	p_rec.eat_attribute6,
	p_rec.eat_attribute7,
	p_rec.eat_attribute8,
	p_rec.eat_attribute9,
	p_rec.eat_attribute10,
	p_rec.eat_attribute11,
	p_rec.eat_attribute12,
	p_rec.eat_attribute13,
	p_rec.eat_attribute14,
	p_rec.eat_attribute15,
	p_rec.eat_attribute16,
	p_rec.eat_attribute17,
	p_rec.eat_attribute18,
	p_rec.eat_attribute19,
	p_rec.eat_attribute20,
	p_rec.eat_attribute21,
	p_rec.eat_attribute22,
	p_rec.eat_attribute23,
	p_rec.eat_attribute24,
	p_rec.eat_attribute25,
	p_rec.eat_attribute26,
	p_rec.eat_attribute27,
	p_rec.eat_attribute28,
	p_rec.eat_attribute29,
	p_rec.eat_attribute30,
	p_rec.object_version_number
  );
  --
  --  Insert into MLS table.
  --
  insert into ben_actn_typ_tl (
    actn_typ_id,
    name,
    description,
    language,
    type_cd,
    source_lang,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date
    )
  select
    p_rec.actn_typ_id,
    p_rec.name,
    p_rec.description,
    l.language_code,
    p_rec.type_cd,
    userenv('LANG'),
    null,
    null,
    null,
    fnd_global.user_id,
    sysdate
  from fnd_languages l
  where l.installed_flag in ('I', 'B')
  and not exists
    (select null
    from ben_actn_typ_tl t
    where t.actn_typ_id = p_rec.actn_typ_id
    and   t.language = l.language_code);
  --
  ben_eat_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_eat_shd.g_api_dml := false;   -- Unset the api dml status
    ben_eat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_eat_shd.g_api_dml := false;   -- Unset the api dml status
    ben_eat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_eat_shd.g_api_dml := false;   -- Unset the api dml status
    ben_eat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_eat_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_eat_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
  cursor c1 is select ben_actn_typ_s.nextval
               from   sys.dual;
--
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into p_rec.actn_typ_id;
  close c1;
  --
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
p_effective_date in date,p_rec in ben_eat_shd.g_rec_type) is
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
    ben_eat_rki.after_insert
      (
  p_actn_typ_id                   =>p_rec.actn_typ_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_type_cd                       =>p_rec.type_cd
 ,p_name                          =>p_rec.name
 ,p_description                   =>p_rec.description
 ,p_eat_attribute_category        =>p_rec.eat_attribute_category
 ,p_eat_attribute1                =>p_rec.eat_attribute1
 ,p_eat_attribute2                =>p_rec.eat_attribute2
 ,p_eat_attribute3                =>p_rec.eat_attribute3
 ,p_eat_attribute4                =>p_rec.eat_attribute4
 ,p_eat_attribute5                =>p_rec.eat_attribute5
 ,p_eat_attribute6                =>p_rec.eat_attribute6
 ,p_eat_attribute7                =>p_rec.eat_attribute7
 ,p_eat_attribute8                =>p_rec.eat_attribute8
 ,p_eat_attribute9                =>p_rec.eat_attribute9
 ,p_eat_attribute10               =>p_rec.eat_attribute10
 ,p_eat_attribute11               =>p_rec.eat_attribute11
 ,p_eat_attribute12               =>p_rec.eat_attribute12
 ,p_eat_attribute13               =>p_rec.eat_attribute13
 ,p_eat_attribute14               =>p_rec.eat_attribute14
 ,p_eat_attribute15               =>p_rec.eat_attribute15
 ,p_eat_attribute16               =>p_rec.eat_attribute16
 ,p_eat_attribute17               =>p_rec.eat_attribute17
 ,p_eat_attribute18               =>p_rec.eat_attribute18
 ,p_eat_attribute19               =>p_rec.eat_attribute19
 ,p_eat_attribute20               =>p_rec.eat_attribute20
 ,p_eat_attribute21               =>p_rec.eat_attribute21
 ,p_eat_attribute22               =>p_rec.eat_attribute22
 ,p_eat_attribute23               =>p_rec.eat_attribute23
 ,p_eat_attribute24               =>p_rec.eat_attribute24
 ,p_eat_attribute25               =>p_rec.eat_attribute25
 ,p_eat_attribute26               =>p_rec.eat_attribute26
 ,p_eat_attribute27               =>p_rec.eat_attribute27
 ,p_eat_attribute28               =>p_rec.eat_attribute28
 ,p_eat_attribute29               =>p_rec.eat_attribute29
 ,p_eat_attribute30               =>p_rec.eat_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_actn_typ'
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
  p_rec        in out nocopy ben_eat_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_eat_bus.insert_validate(p_rec
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
  p_actn_typ_id                  out nocopy number,
  p_business_group_id            in number,
  p_type_cd                      in varchar2,
  p_name                         in varchar2,
  p_description                  in varchar2,
  p_eat_attribute_category       in varchar2         default null,
  p_eat_attribute1               in varchar2         default null,
  p_eat_attribute2               in varchar2         default null,
  p_eat_attribute3               in varchar2         default null,
  p_eat_attribute4               in varchar2         default null,
  p_eat_attribute5               in varchar2         default null,
  p_eat_attribute6               in varchar2         default null,
  p_eat_attribute7               in varchar2         default null,
  p_eat_attribute8               in varchar2         default null,
  p_eat_attribute9               in varchar2         default null,
  p_eat_attribute10              in varchar2         default null,
  p_eat_attribute11              in varchar2         default null,
  p_eat_attribute12              in varchar2         default null,
  p_eat_attribute13              in varchar2         default null,
  p_eat_attribute14              in varchar2         default null,
  p_eat_attribute15              in varchar2         default null,
  p_eat_attribute16              in varchar2         default null,
  p_eat_attribute17              in varchar2         default null,
  p_eat_attribute18              in varchar2         default null,
  p_eat_attribute19              in varchar2         default null,
  p_eat_attribute20              in varchar2         default null,
  p_eat_attribute21              in varchar2         default null,
  p_eat_attribute22              in varchar2         default null,
  p_eat_attribute23              in varchar2         default null,
  p_eat_attribute24              in varchar2         default null,
  p_eat_attribute25              in varchar2         default null,
  p_eat_attribute26              in varchar2         default null,
  p_eat_attribute27              in varchar2         default null,
  p_eat_attribute28              in varchar2         default null,
  p_eat_attribute29              in varchar2         default null,
  p_eat_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_eat_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_eat_shd.convert_args
  (
  null,
  p_business_group_id,
  p_type_cd,
  p_name,
  p_description,
  p_eat_attribute_category,
  p_eat_attribute1,
  p_eat_attribute2,
  p_eat_attribute3,
  p_eat_attribute4,
  p_eat_attribute5,
  p_eat_attribute6,
  p_eat_attribute7,
  p_eat_attribute8,
  p_eat_attribute9,
  p_eat_attribute10,
  p_eat_attribute11,
  p_eat_attribute12,
  p_eat_attribute13,
  p_eat_attribute14,
  p_eat_attribute15,
  p_eat_attribute16,
  p_eat_attribute17,
  p_eat_attribute18,
  p_eat_attribute19,
  p_eat_attribute20,
  p_eat_attribute21,
  p_eat_attribute22,
  p_eat_attribute23,
  p_eat_attribute24,
  p_eat_attribute25,
  p_eat_attribute26,
  p_eat_attribute27,
  p_eat_attribute28,
  p_eat_attribute29,
  p_eat_attribute30,
  null
  );
  --
  -- Having converted the arguments into the ben_eat_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_actn_typ_id := l_rec.actn_typ_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_eat_ins;

/
