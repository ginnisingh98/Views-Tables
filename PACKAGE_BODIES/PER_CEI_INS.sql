--------------------------------------------------------
--  DDL for Package Body PER_CEI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CEI_INS" as
/* $Header: peceirhi.pkb 120.1 2006/10/18 08:58:46 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_cei_ins.';  -- Global package name
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
Procedure insert_dml
  (p_rec in out nocopy per_cei_shd.g_rec_type
  ) is
  --
  l_proc  varchar2(72) := g_package||'insert_dml';
  l_created_by          per_cagr_entitlement_items.created_by%TYPE;
  l_creation_date       per_cagr_entitlement_items.creation_date%TYPE;
  l_last_update_date    per_cagr_entitlement_items.last_update_date%TYPE;
  l_last_updated_by     per_cagr_entitlement_items.last_updated_by%TYPE;
  l_last_update_login   per_cagr_entitlement_items.last_update_login%TYPE;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  -- Set the who columns
  --
  l_creation_date      := sysdate;
  l_created_by         := fnd_global.user_id;
  l_last_update_date   := sysdate;
  l_last_updated_by    := fnd_global.user_id;
  l_last_update_login  := fnd_global.login_id;
  --
  -- Insert the row into: per_cagr_entitlement_items
  --
  insert into per_cagr_entitlement_items
      (cagr_entitlement_item_id
      ,item_name
      ,element_type_id
      ,input_value_id
	  ,column_type
	  ,column_size
      ,legislation_code
      ,beneficial_rule
      ,cagr_api_id
      ,cagr_api_param_id
      ,business_group_id
      ,category_name
      ,uom
      ,flex_value_set_id
      ,beneficial_formula_id
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,object_version_number
      ,beneficial_rule_value_set_id
      ,multiple_entries_allowed_flag
      ,auto_create_entries_flag -- CEI Enh
      ,opt_id
      )
  Values
    (p_rec.cagr_entitlement_item_id
    ,p_rec.item_name
    ,p_rec.element_type_id
    ,p_rec.input_value_id
	,p_rec.column_type
	,p_rec.column_size
    ,p_rec.legislation_code
    ,p_rec.beneficial_rule
    ,p_rec.cagr_api_id
    ,p_rec.cagr_api_param_id
    ,p_rec.business_group_id
    ,p_rec.category_name
    ,p_rec.uom
    ,p_rec.flex_value_set_id
    ,p_rec.beneficial_formula_id
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    ,p_rec.object_version_number
    ,p_rec.ben_rule_value_set_id
    ,p_rec.mult_entries_allowed_flag
    ,p_rec.auto_create_entries_flag -- CEI Enh
    ,p_rec.opt_id
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_cei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_cei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_cei_shd.constraint_error
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
  (p_rec  in out nocopy per_cei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_cagr_entitlement_items_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.cagr_entitlement_item_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
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
Procedure post_insert
  (p_effective_date               in date
  ,p_rec                          in per_cei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  begin
    --
    per_cei_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_cagr_entitlement_item_id    => p_rec.cagr_entitlement_item_id
      ,p_item_name                   => p_rec.item_name
      ,p_element_type_id             => p_rec.element_type_id
      ,p_input_value_id              => p_rec.input_value_id
      ,p_column_type                 => p_rec.column_type
      ,p_column_size                 => p_rec.column_size
      ,p_legislation_code            => p_rec.legislation_code
      ,p_cagr_api_id                 => p_rec.cagr_api_id
      ,p_cagr_api_param_id           => p_rec.cagr_api_param_id
      ,p_beneficial_formula_id       => p_rec.beneficial_formula_id
      ,p_business_group_id           => p_rec.business_group_id
      ,p_beneficial_rule             => p_rec.beneficial_rule
      ,p_category_name               => p_rec.category_name
      ,p_uom                         => p_rec.uom
      ,p_flex_value_set_id           => p_rec.flex_value_set_id
      ,p_object_version_number       => p_rec.object_version_number
      ,p_ben_rule_value_set_id       => p_rec.ben_rule_value_set_id
      ,p_mult_entries_allowed_flag   => p_rec.mult_entries_allowed_flag
      ,p_auto_create_entries_flag    => p_rec.auto_create_entries_flag -- CEI Enh
      ,p_opt_id                      => p_rec.opt_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CAGR_ENTITLEMENT_ITEMS'
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
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_cei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_cei_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  per_cei_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_cei_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_cei_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_item_name                      in     varchar2
  ,p_legislation_code               in     varchar2
  ,p_business_group_id              in     number
  ,p_category_name                  in     varchar2
  ,p_uom                            in     varchar2
  ,p_flex_value_set_id              in     number
  ,p_element_type_id                in     number   default null
  ,p_input_value_id                 in     varchar2 default null
  ,p_column_type                    in     varchar2
  ,p_column_size                    in     number
  ,p_cagr_api_id                    in     number   default null
  ,p_cagr_api_param_id              in     number   default null
  ,p_beneficial_formula_id          in     number   default null
  ,p_beneficial_rule                in     varchar2 default null
  ,p_ben_rule_value_set_id          in     number   default null
  ,p_mult_entries_allowed_flag      in     varchar2 default null
  ,p_auto_create_entries_flag       in     varchar2 default null -- CEI Enh
  ,p_opt_id                         in     number
  ,p_cagr_entitlement_item_id       out nocopy    number
  ,p_object_version_number          out nocopy    number

  ) is
--
  l_rec      per_cei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec := per_cei_shd.convert_args
    (NULL
    ,p_item_name
    ,p_element_type_id
    ,p_input_value_id
	,p_column_type
	,p_column_size
    ,p_legislation_code
    ,p_cagr_api_id
    ,p_cagr_api_param_id
    ,p_business_group_id
    ,p_beneficial_rule
    ,p_category_name
    ,p_uom
    ,p_flex_value_set_id
    ,p_beneficial_formula_id
    ,p_object_version_number
    ,p_ben_rule_value_set_id
    ,p_mult_entries_allowed_flag
    ,p_auto_create_entries_flag -- CEI Enh
    ,p_opt_id) ;
  --
  -- Having converted the arguments into the per_cei_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_cei_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_cagr_entitlement_item_id := l_rec.cagr_entitlement_item_id;
  p_object_version_number    := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_cei_ins;

/
