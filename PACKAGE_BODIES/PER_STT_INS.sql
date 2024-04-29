--------------------------------------------------------
--  DDL for Package Body PER_STT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_STT_INS" as
/* $Header: pesttrhi.pkb 115.4 2002/12/09 14:19:55 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_stt_ins.';  -- Global package name
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy per_stt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Insert the row into: per_shared_types_tl
  --
  insert into per_shared_types_tl
  (	shared_type_id,
	language,
	source_lang,
	shared_type_name
  )
  Values
  (	p_rec.shared_type_id,
	p_rec.language,
	p_rec.source_lang,
	p_rec.shared_type_name
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_stt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_stt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_stt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_insert(p_rec            in out nocopy per_stt_shd.g_rec_type,
                     p_shared_type_id in number ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_rec.shared_type_id := p_shared_type_id ;
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
Procedure post_insert(p_rec in per_stt_shd.g_rec_type) is
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
    per_stt_rki.after_insert
      (
  p_shared_type_id                =>p_rec.shared_type_id
 ,p_language                      =>p_rec.language
 ,p_source_lang                   =>p_rec.source_lang
 ,p_shared_type_name              =>p_rec.shared_type_name
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'per_shared_types_tl'
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
  p_rec            in out nocopy per_stt_shd.g_rec_type ,
  p_shared_type_id in number
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_stt_bus.insert_validate(p_rec);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec            => p_rec,
             p_shared_type_id => p_shared_type_id );
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
  p_shared_type_id               in  number,
  p_language                     in  varchar2,
  p_source_lang                  in varchar2,
  p_shared_type_name             in varchar2
  ) is
--
  l_rec	  per_stt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_stt_shd.convert_args
  (
  null,
  p_language,
  p_source_lang,
  p_shared_type_name
  );
  --
  -- Having converted the arguments into the per_stt_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_rec       => l_rec,
      p_shared_type_id => p_shared_type_id );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
procedure ins_tl (
  p_language_code          in varchar2,
  p_shared_type_id         in number,
  p_shared_type_name       in varchar2 ) is
   cursor csr_ins_langs is
      select l.language_code
      from fnd_languages l
      where l.installed_flag in ('I','B')
      and not exists ( select null
                       from per_shared_types_tl stt
                       where stt.shared_type_id = p_shared_type_id
                       and stt.language         = l.language_code );
  l_proc  varchar2(72) := g_package||'ins_tl';
begin
  hr_utility.set_location(' Entering:'||l_proc, 10);
  for l_lang in csr_ins_langs loop
    ins
      (p_shared_type_id    => p_shared_type_id,
       p_shared_type_name  => p_shared_type_name,
       p_language          => l_lang.language_code,
       p_source_lang       => p_language_code) ;
  end loop;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end ins_tl;
--
end per_stt_ins;

/
