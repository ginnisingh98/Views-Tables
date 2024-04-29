--------------------------------------------------------
--  DDL for Package Body HR_LOT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOT_INS" as
/* $Header: hrlotrhi.pkb 115.10 2002/12/04 05:45:04 hjonnala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_lot_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy hr_lot_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Insert the row into: hr_locations_all_tl
  --
  insert into hr_locations_all_tl
  (	location_id,
	language,
	source_lang,
	location_code,
	description
  )
  Values
  (	p_rec.location_id,
	p_rec.language,
	p_rec.source_lang,
	p_rec.location_code,
	p_rec.description
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hr_lot_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    hr_lot_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hr_lot_shd.constraint_error
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
Procedure pre_insert(p_rec         in out nocopy hr_lot_shd.g_rec_type,
		     p_location_id in number) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_rec.location_id := p_location_id;
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
Procedure post_insert(p_rec in hr_lot_shd.g_rec_type) is
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
    hr_lot_rki.after_insert
      (
    p_location_id                   =>p_rec.location_id
   ,p_language                      =>p_rec.language
   ,p_source_lang                   =>p_rec.source_lang
   ,p_location_code                 =>p_rec.location_code
   ,p_description                   =>p_rec.description
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_LOCATIONS_ALL_TL'
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
   p_rec                  in out nocopy hr_lot_shd.g_rec_type,
   p_location_id          in     number,
   p_business_group_id    in     number
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  hr_lot_bus.insert_validate(p_rec, p_business_group_id);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec, p_location_id);
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
  p_location_id                  in number,
  p_language                     in varchar2,
  p_source_lang                  in varchar2,
  p_location_code                in varchar2,
  p_description                  in varchar2         default null,
  p_business_group_id            in number
  ) is
--
  l_rec	  hr_lot_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  -- api_updating() expects the location_id to be NULL on insert.  For a TL insert,
  -- however, we already know the location_id because we have just inserted a row on
  -- the non-translated table.  So to ensure api_updating() still works, pass
  -- through NULL to convert_args, but add an extra parameter - p_location_id -
  -- to the call to ins().  This parameter contains the real location_id.
  --
  l_rec :=
  hr_lot_shd.convert_args
  (
    NULL,
    p_language,
    p_source_lang,
    p_location_code,
    p_description
  );
  --
  -- Having converted the arguments into the hr_lot_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec,
      p_location_id,
      p_business_group_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
-- -------------------------------------------------------------------------
-- |------------------------------< ins_tl >-------------------------------|
-- -------------------------------------------------------------------------
Procedure ins_tl
 (p_language_code                in varchar2,
  p_location_id                  in number,
  p_location_code                in varchar2,
  p_description                  in varchar2,
  p_business_group_id            in number
  ) is
  --
  -- Cursor to obtain the list of base and installed languages
  --
  cursor csr_ins_langs is
    select l.language_code
      from fnd_languages l
     where l.installed_flag in ('I', 'B')
       and not exists (select null
                         from hr_locations_all_tl lot
                         where lot.location_id = p_location_id
                         and   lot.language    = l.language_code);
    --
    --
  l_proc                  varchar2(72) := g_package||'ins_tl';
  l_inserted_anything    boolean := false;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Insert a row for the base language and every installed language.
  --
  hr_utility.set_location(l_proc, 15);
  for l_lang in csr_ins_langs loop
    ins
     (p_location_id        => p_location_id
     ,p_language           => l_lang.language_code
     ,p_source_lang        => p_language_code
     ,p_location_code      => p_location_code
     ,p_description        => p_description
     ,p_business_group_id  => p_business_group_id
     );
     l_inserted_anything := true;
  end loop;
  --
  if not l_inserted_anything then
     hr_utility.set_message(800, 'PER_52517_NO_MLS_INSERTS');
     hr_utility.raise_error;
  end if;
  --
  -- Finally, set the global g_loc_bg_id for use when updating.
  --
  hr_lot_shd.set_value_business_group_id (p_business_group_id => p_business_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End ins_tl;
--
end hr_lot_ins;

/
