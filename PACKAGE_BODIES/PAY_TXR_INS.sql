--------------------------------------------------------
--  DDL for Package Body PAY_TXR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TXR_INS" as
/* $Header: pytxrrhi.pkb 120.0 2005/05/29 09:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_txr_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_jurisdiction_code_i  number   default null;
g_tax_type_i  number   default null;
g_tax_category_i  number   default null;
g_classification_id_i  number   default null;
g_taxability_rules_date_id_i  number   default null;
g_secondary_class_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_jurisdiction_code  in  number
  ,p_tax_type  in  number
  ,p_tax_category  in  number
  ,p_classification_id  in  number
  ,p_taxability_rules_date_id  in  number
  ,p_secondary_classification_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pay_txr_ins.g_jurisdiction_code_i := p_jurisdiction_code;
  pay_txr_ins.g_tax_type_i := p_tax_type;
  pay_txr_ins.g_tax_category_i := p_tax_category;
  pay_txr_ins.g_classification_id_i := p_classification_id;
  pay_txr_ins.g_taxability_rules_date_id_i := p_taxability_rules_date_id;
  pay_txr_ins.g_secondary_class_id_i := p_secondary_classification_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
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
Procedure insert_dml
  (p_rec in out nocopy pay_txr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
num number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Insert the row into: pay_taxability_rules
  --
  hr_utility.trace('p_rec.jurisdiction_code '||p_rec.jurisdiction_code);
  hr_utility.trace('p_rec.tax_type '||p_rec.tax_type);
  hr_utility.trace('p_rec.tax_category '||p_rec.tax_category);
  hr_utility.trace('p_rec.classification_id '||to_char(p_rec.classification_id));
  hr_utility.trace('p_rec.legislation_code '||p_rec.legislation_code);
  hr_utility.trace('p_rec.status '||p_rec.status);
  hr_utility.trace('p_rec.secondary_classification_id '||
                    to_char(p_rec.secondary_classification_id));
  insert into pay_taxability_rules
      (jurisdiction_code
      ,tax_type
      ,tax_category
      ,classification_id
      ,taxability_rules_date_id
      ,legislation_code
      ,status
      ,secondary_classification_id
      )
  Values
    (p_rec.jurisdiction_code
    ,p_rec.tax_type
    ,p_rec.tax_category
    ,p_rec.classification_id
    ,p_rec.taxability_rules_date_id
    ,p_rec.legislation_code
    ,p_rec.status
    ,p_rec.secondary_classification_id
    );
  --
select count(*)
into num
from pay_taxability_rules
where jurisdiction_code = p_rec.jurisdiction_code;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  hr_utility.set_location(' Num:'|| to_char(num), 20);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_txr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_txr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_txr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
   hr_utility.trace('Exception  in '||SQLERRM);
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
--   A Pl/Sql record structure.
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
  (p_rec  in out nocopy pay_txr_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is
   select taxability_rules_date_id
   from pay_taxability_rules_dates
   where legislation_code = p_rec.legislation_code
   and sysdate between valid_date_from and
                       valid_date_to;

--
  Cursor C_Sel2 is
    Select null
      from pay_taxability_rules
     where jurisdiction_code =
             pay_txr_ins.g_jurisdiction_code_i
        or tax_type =
             pay_txr_ins.g_tax_type_i
        or tax_category =
             pay_txr_ins.g_tax_category_i
        or classification_id =
             pay_txr_ins.g_classification_id_i
        or secondary_classification_id =
             pay_txr_ins.g_secondary_class_id_i
        or taxability_rules_date_id =
             pay_txr_ins.g_taxability_rules_date_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
  ln_rules_nextval pay_taxability_rules_dates.taxability_rules_date_id%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (pay_txr_ins.g_jurisdiction_code_i is not null or
      pay_txr_ins.g_tax_type_i is not null or
      pay_txr_ins.g_tax_category_i is not null or
      pay_txr_ins.g_classification_id_i is not null or
      pay_txr_ins.g_taxability_rules_date_id_i is not null or
      pay_txr_ins.g_secondary_class_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','pay_taxability_rules');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.jurisdiction_code :=
      pay_txr_ins.g_jurisdiction_code_i;
    pay_txr_ins.g_jurisdiction_code_i := null;

    p_rec.tax_type :=
      pay_txr_ins.g_tax_type_i;
    pay_txr_ins.g_tax_type_i := null;

    p_rec.tax_category :=
      pay_txr_ins.g_tax_category_i;
    pay_txr_ins.g_tax_category_i := null;

    p_rec.classification_id :=
      pay_txr_ins.g_classification_id_i;
    pay_txr_ins.g_classification_id_i := null;

    p_rec.taxability_rules_date_id :=
      pay_txr_ins.g_taxability_rules_date_id_i;
    pay_txr_ins.g_taxability_rules_date_id_i := null;

    p_rec.secondary_classification_id :=
      pay_txr_ins.g_secondary_class_id_i;
    pay_txr_ins.g_secondary_class_id_i := null;

  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.taxability_rules_date_id;

    IF C_Sel1%NOTFOUND THEN

       --There is no record available for this legislation code in the PAY_TAXABILITY_RULES_DATES.
       --So create a record there.

       select PAY_TAXABILITY_RULES_DATES_S.nextval
       into ln_rules_nextval
       from sys.dual;

       insert into pay_taxability_rules_dates
       (taxability_rules_date_id, valid_date_from, valid_date_to,
       legislation_code
       --last_update_date, last_updated_by, last_update_login, created_by, creation_date, object_version_number
       ) values
      (ln_rules_nextval,
       to_date('0001/01/01', 'YYYY/MM/DD HH24:MI:SS'),
       to_date('4712/12/31', 'YYYY/MM/DD HH24:MI:SS'),
       p_rec.legislation_code
    --   to_date(:last_update_date, 'YYYY/MM/DD HH24:MI:SS'),
   --    ln_last_updated_by, ln_last_updated_by, ln_last_updated_by,
   --    to_date(:last_update_date, 'YYYY/MM/DD HH24:MI:SS'), ln_object_version_number
       );
       p_rec.taxability_rules_date_id := ln_rules_nextval;

    END IF;

    Close C_Sel1;
  End If;
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
  (p_effective_date               in date
  ,p_rec                          in pay_txr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_txr_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_jurisdiction_code
      => p_rec.jurisdiction_code
      ,p_tax_type
      => p_rec.tax_type
      ,p_tax_category
      => p_rec.tax_category
      ,p_classification_id
      => p_rec.classification_id
      ,p_taxability_rules_date_id
      => p_rec.taxability_rules_date_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_status
      => p_rec.status
      ,p_secondary_classification_id
      => p_rec.secondary_classification_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_TAXABILITY_RULES'
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
  ,p_rec                          in out nocopy pay_txr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_txr_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pay_txr_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pay_txr_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pay_txr_ins.post_insert
     (p_effective_date
     ,p_rec
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
  (p_effective_date               in     date
  ,p_legislation_code             in     varchar2
  ,p_status                       in     varchar2 default null
  ,p_jurisdiction_code            in     varchar2
  ,p_tax_type                     in     varchar2 default null
  ,p_tax_category                 in     varchar2 default null
  ,p_classification_id            in     number   default null
  ,p_taxability_rules_date_id     in     number
  ,p_secondary_classification_id  in     number   default null
  ) is
--
  l_rec   pay_txr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   hr_utility.trace('In Procedure ins');
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
   hr_utility.trace('Before calling pay_txr_shd.convert_args ');
  l_rec :=
  pay_txr_shd.convert_args
    (p_jurisdiction_code
    ,p_tax_type
    ,p_tax_category
    ,p_classification_id
    ,p_taxability_rules_date_id
    ,p_legislation_code
    ,p_status
    ,p_secondary_classification_id
    );
  --
   hr_utility.trace('After calling pay_txr_shd.convert_args ');
  -- Having converted the arguments into the pay_txr_rec
  -- plsql record structure we call the corresponding record business process.
  --
   hr_utility.trace('Before calling pay_txr_ins.ins ');
  pay_txr_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_txr_ins;

/
