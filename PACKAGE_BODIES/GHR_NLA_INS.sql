--------------------------------------------------------
--  DDL for Package Body GHR_NLA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_NLA_INS" as
/* $Header: ghnlarhi.pkb 120.1.12010000.1 2009/03/26 10:12:16 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_nla_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out NOCOPY ghr_nla_shd.g_rec_type) is
--
  l_proc  varchar2(72);
--
  l_rec ghr_nla_shd.g_rec_type;
Begin
  l_proc  := g_package||'insert_dml';
  l_rec := p_rec; -- NOCOPY changes
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: ghr_noac_las
  --
  insert into ghr_noac_las
  (	noac_la_id,
	nature_of_action_id,
	lac_lookup_code,
	enabled_flag,
	date_from,
	date_to,
	object_version_number,
	valid_first_lac_flag,
	valid_second_lac_flag
  )
  Values
  (	p_rec.noac_la_id,
	p_rec.nature_of_action_id,
	p_rec.lac_lookup_code,
	p_rec.enabled_flag,
	p_rec.date_from,
	p_rec.date_to,
	p_rec.object_version_number,
	p_rec.valid_first_lac_flag,
	p_rec.valid_second_lac_flag
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    p_rec := l_rec;
    ghr_nla_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    p_rec := l_rec;
    ghr_nla_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    p_rec := l_rec;
    ghr_nla_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    p_rec := l_rec;
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
Procedure pre_insert(p_rec  in out NOCOPY ghr_nla_shd.g_rec_type) is
--
  l_proc  varchar2(72);
--
  Cursor C_Sel1 is select ghr_noac_las_s.nextval from sys.dual;
--
  l_rec ghr_nla_shd.g_rec_type;
Begin
  l_proc := g_package||'pre_insert';
  l_rec := p_rec;
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.noac_la_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when others then -- NOCOPY changes
	p_rec := l_rec;
	raise;
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
p_effective_date in date,p_rec in ghr_nla_shd.g_rec_type) is
--
  l_proc  varchar2(72) ;
--
Begin
  l_proc  := g_package||'post_insert';
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ghr_nla_rki.after_insert
      (
  p_noac_la_id                    =>p_rec.noac_la_id
 ,p_nature_of_action_id           =>p_rec.nature_of_action_id
 ,p_lac_lookup_code               =>p_rec.lac_lookup_code
 ,p_enabled_flag                  =>p_rec.enabled_flag
 ,p_date_from                     =>p_rec.date_from
 ,p_date_to                       =>p_rec.date_to
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_valid_first_lac_flag          =>p_rec.valid_first_lac_flag
 ,p_valid_second_lac_flag         =>p_rec.valid_second_lac_flag
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ghr_noac_las'
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
  p_rec        in out NOCOPY ghr_nla_shd.g_rec_type
  ) is
--
  l_rec	  ghr_nla_shd.g_rec_type;
  l_proc  varchar2(72) ;
--
Begin
  l_proc := g_package||'ins';
  l_rec := p_rec;
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ghr_nla_bus.insert_validate(p_rec
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
exception
   when others then
     p_rec := l_rec;
       raise;

end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_noac_la_id                   out NOCOPY number,
  p_nature_of_action_id          in number,
  p_lac_lookup_code              in varchar2,
  p_enabled_flag                 in varchar2,
  p_date_from                    in date,
  p_date_to                      in date             default null,
  p_object_version_number        out NOCOPY number,
  p_valid_first_lac_flag         in varchar2,
  p_valid_second_lac_flag        in varchar2
  ) is
--
  l_rec	  ghr_nla_shd.g_rec_type;
  l_proc  varchar2(72) ;
--
Begin
  l_proc := g_package||'ins';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ghr_nla_shd.convert_args
  (
  null,
  p_nature_of_action_id,
  p_lac_lookup_code,
  p_enabled_flag,
  p_date_from,
  p_date_to,
  null,
  p_valid_first_lac_flag,
  p_valid_second_lac_flag
  );
  --
  -- Having converted the arguments into the ghr_nla_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_noac_la_id := l_rec.noac_la_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
   when others then
       p_noac_la_id := null;
       p_object_version_number := null;
       raise;
End ins;
--
end ghr_nla_ins;

/
