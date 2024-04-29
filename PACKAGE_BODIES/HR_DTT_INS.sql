--------------------------------------------------------
--  DDL for Package Body HR_DTT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DTT_INS" as
/* $Header: hrdttrhi.pkb 120.0 2005/05/30 23:52:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_dtt_ins.';  -- Global package name
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
--   2) To insert the row into the schema.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec in out nocopy hr_dtt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Insert the row into: hr_document_types_tl
  --
  insert into hr_document_types_tl
      (document_type_id
      ,language
      ,source_language
      ,document_type
      ,description
      )
  Values
    (p_rec.document_type_id
    ,p_rec.language
    ,p_rec.source_language
    ,p_rec.document_type
    ,p_rec.description
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_dtt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_dtt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_dtt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
Procedure pre_insert
  (p_rec                          in out nocopy hr_dtt_shd.g_rec_type
  ,p_document_type_id             in number
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_rec.document_type_id                 := p_document_type_id;
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
--   This private procedure contains any processing which is required after
--   the insert dml.
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
Procedure post_insert
  (p_rec                          in hr_dtt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --


    hr_dtt_rki.after_insert
      (p_document_type_id
      => p_rec.document_type_id
      ,p_language
      => p_rec.language
      ,p_source_language
      => p_rec.source_language
      ,p_document_type
      => p_rec.document_type
      ,p_description
      => p_rec.description
      );



    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_DOCUMENT_TYPES_TL'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec                          in out nocopy hr_dtt_shd.g_rec_type
  ,p_document_type_id             in number
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin


  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  hr_dtt_bus.insert_validate
     (p_rec
     );


  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  hr_dtt_ins.pre_insert
    (p_rec                         => p_rec
    ,p_document_type_id            => p_document_type_id
    );


  --
  -- Insert the row
  --
  hr_dtt_ins.insert_dml(p_rec);


  --
  -- Call the supporting post-insert operation
  --
  hr_dtt_ins.post_insert
     (p_rec
     );


  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_document_type_id               in     number
  ,p_language                       in     varchar2
  ,p_source_language                in     varchar2
  ,p_document_type                  in     varchar2
  ,p_description                    in     varchar2
  ) is
--
  l_rec   hr_dtt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin


  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_dtt_shd.convert_args
    (null
    ,p_language
    ,p_source_language
    ,p_document_type
    ,p_description
    );


  --
  -- Having converted the arguments into the hr_dtt_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hr_dtt_ins.ins
     (p_rec                         => l_rec
     ,p_document_type_id            => p_document_type_id
     );


  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< ins_tl >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins_tl
  (p_language_code                in varchar2
  ,p_document_type_id             in number
  ,p_document_type                in varchar2
  ,p_description                  in varchar2 default null
  ) is
  --
  -- Cursor to obtain the list of base and installed languages
  --
  cursor csr_ins_langs is
    select l.language_code
      from fnd_languages l
     where l.installed_flag in ('I','B')
       and not exists (select null
                         from hr_document_types_tl dtt
                        where dtt.document_type_id = p_document_type_id
                          and dtt.language = l.language_code);
  --
  l_proc  varchar2(72)  := g_package || 'ins_tl';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

  --
  -- Insert a row for the base language and every installed language.
  --
  for l_lang in csr_ins_langs loop
    hr_dtt_ins.ins
      (p_document_type_id            => p_document_type_id
      ,p_language                    => l_lang.language_code
      ,p_source_language             => p_language_code
      ,p_document_type               => p_document_type
      ,p_description                 => p_description
      );
  end loop;
  --


  hr_utility.set_location('Leaving:'||l_proc,20);
End ins_tl;
--
end hr_dtt_ins;

/
