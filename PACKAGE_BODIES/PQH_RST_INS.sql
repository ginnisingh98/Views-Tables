--------------------------------------------------------
--  DDL for Package Body PQH_RST_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RST_INS" as
/* $Header: pqrstrhi.pkb 120.2.12000000.2 2007/04/19 12:46:34 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rst_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy pqh_rst_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pqh_rule_sets
  --
  insert into pqh_rule_sets
  (	business_group_id,
	rule_set_id,
	rule_set_name,
	organization_structure_id,
	organization_id,
	referenced_rule_set_id,
	rule_level_cd,
	object_version_number,
	short_name,
	rule_applicability,
	rule_category,
  	starting_organization_id,
  	seeded_rule_flag,
        status
  )
  Values
  (	p_rec.business_group_id,
	p_rec.rule_set_id,
	p_rec.rule_set_name,
	p_rec.organization_structure_id,
	p_rec.organization_id,
	p_rec.referenced_rule_set_id,
	p_rec.rule_level_cd,
	p_rec.object_version_number,
	p_rec.short_name,
	p_rec.rule_applicability,
	p_rec.rule_category,
	p_rec.starting_organization_id,
	p_rec.seeded_rule_flag,
        p_rec.status
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_rst_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_rst_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_rst_shd.constraint_error
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
Procedure pre_insert(p_rec  in out nocopy pqh_rst_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
--
  Cursor C_Sel1 is select pqh_rule_sets_s.nextval from sys.dual;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   open C_Sel1;
   fetch C_Sel1 into p_rec.rule_set_id ;
   close C_Sel1;
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
p_effective_date in date,p_rec in pqh_rst_shd.g_rec_type) is
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
    pqh_rst_rki.after_insert
      (
  p_business_group_id             =>p_rec.business_group_id
 ,p_rule_set_id                   =>p_rec.rule_set_id
 ,p_rule_set_name                 =>p_rec.rule_set_name
 ,p_organization_structure_id     =>p_rec.organization_structure_id
 ,p_organization_id               =>p_rec.organization_id
 ,p_referenced_rule_set_id        =>p_rec.referenced_rule_set_id
 ,p_rule_level_cd                 =>p_rec.rule_level_cd
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_short_name                    =>p_rec.short_name
 ,p_rule_applicability		  =>p_rec.rule_applicability
 ,p_rule_category		  =>p_rec.rule_category
 ,p_starting_organization_id	  =>p_rec.starting_organization_id
 ,p_seeded_rule_flag		  =>p_rec.seeded_rule_flag
 ,p_status                     	  =>p_rec.status
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_rule_sets'
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
  p_rec        in out nocopy pqh_rst_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_rst_bus.insert_validate(p_rec
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
  p_business_group_id            in number,
  p_rule_set_id                  out nocopy number,
  p_rule_set_name                in varchar2         default null,
  p_organization_structure_id    in number           default null,
  p_organization_id              in number           default null,
  p_referenced_rule_set_id       in number           default null,
  p_rule_level_cd                in varchar2,
  p_object_version_number        out nocopy number,
  p_short_name                   in varchar2,
  p_rule_applicability		in varchar2	     default 'NONE',
  p_rule_category		in varchar2,
  p_starting_organization_id	in number	     default null,
  p_seeded_rule_flag		in varchar2	     default 'N',
  p_status                     	in varchar2	     default null
  ) is
--
  l_rec	  pqh_rst_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_rst_shd.convert_args
  (
  p_business_group_id,
  null,
  p_rule_set_name,
  p_organization_structure_id,
  p_organization_id,
  p_referenced_rule_set_id,
  p_rule_level_cd,
  null,
  p_short_name,
  p_rule_applicability,
  p_rule_category,
  p_starting_organization_id,
  p_seeded_rule_flag,
  p_status
  );
  --
  -- Having converted the arguments into the pqh_rst_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_rule_set_id := l_rec.rule_set_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_rst_ins;

/
