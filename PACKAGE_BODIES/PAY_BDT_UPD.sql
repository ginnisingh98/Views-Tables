--------------------------------------------------------
--  DDL for Package Body PAY_BDT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BDT_UPD" as
/* $Header: pybdtrhi.pkb 120.3 2005/11/24 05:36 arashid noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_bdt_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy pay_bdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Update the pay_balance_dimensions_tl Row
  --
  update pay_balance_dimensions_tl
    set
     balance_dimension_id            = p_rec.balance_dimension_id
    ,language                        = p_rec.language
    ,source_lang                     = p_rec.source_lang
    ,dimension_name                  = p_rec.dimension_name
    ,database_item_suffix            = p_rec.database_item_suffix
    ,description                     = p_rec.description
    where balance_dimension_id = p_rec.balance_dimension_id
    and language = p_rec.language;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_bdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_bdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_bdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in pay_bdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_rec                          in pay_bdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_bdt_rku.after_update
      (p_balance_dimension_id
      => p_rec.balance_dimension_id
      ,p_language
      => p_rec.language
      ,p_source_lang
      => p_rec.source_lang
      ,p_dimension_name
      => p_rec.dimension_name
      ,p_database_item_suffix
      => p_rec.database_item_suffix
      ,p_description
      => p_rec.description
      ,p_source_lang_o
      => pay_bdt_shd.g_old_rec.source_lang
      ,p_dimension_name_o
      => pay_bdt_shd.g_old_rec.dimension_name
      ,p_database_item_suffix_o
      => pay_bdt_shd.g_old_rec.database_item_suffix
      ,p_description_o
      => pay_bdt_shd.g_old_rec.description
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_BALANCE_DIMENSIONS_TL'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy pay_bdt_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.source_lang = hr_api.g_varchar2) then
    p_rec.source_lang :=
    pay_bdt_shd.g_old_rec.source_lang;
  End If;
  If (p_rec.dimension_name = hr_api.g_varchar2) then
    p_rec.dimension_name :=
    pay_bdt_shd.g_old_rec.dimension_name;
  End If;
  If (p_rec.database_item_suffix = hr_api.g_varchar2) then
    p_rec.database_item_suffix :=
    pay_bdt_shd.g_old_rec.database_item_suffix;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    pay_bdt_shd.g_old_rec.description;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pay_bdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_bdt_shd.lck
    (p_rec.balance_dimension_id
    ,p_rec.language
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pay_bdt_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pay_bdt_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_bdt_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  --pay_bdt_upd.post_update(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_balance_dimension_id         in     number
  ,p_language                     in     varchar2
  ,p_source_lang                  in     varchar2  default hr_api.g_varchar2
  ,p_dimension_name               in     varchar2  default hr_api.g_varchar2
  ,p_database_item_suffix         in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   pay_bdt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_bdt_shd.convert_args
  (p_balance_dimension_id
  ,p_language
  ,p_source_lang
  ,p_dimension_name
  ,p_database_item_suffix
  ,p_description
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_bdt_upd.upd
     (l_rec
     );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd_tl >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_tl
  (p_language_code                 in varchar2
  ,p_balance_dimension_id         in number
  ,p_dimension_name               in varchar2 default hr_api.g_varchar2
  ,p_database_item_suffix         in varchar2 default hr_api.g_varchar2
  ,p_description                  in varchar2 default hr_api.g_varchar2
  ,p_record_dbi_changes           in boolean default false
  ) is
  --
  -- Cursor to obtain the translation rows where the language or
  -- source_lang match the specified language.
  --
  cursor csr_upd_langs is
    select bdt.language
    ,      bdt.database_item_suffix
      from pay_balance_dimensions_tl bdt
     where bdt.balance_dimension_id = p_balance_dimension_id
       and p_language_code in (bdt.language
                              ,bdt.source_lang);
  --
  l_proc  varchar2(72) := g_package||'upd_tl';
  l_leg_code varchar2(100);
  l_langs    dbms_sql.varchar2s;
  i          binary_integer := 1;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_record_dbi_changes then
    l_leg_code := pay_bdt_bus.return_legislation_code
                  (p_balance_dimension_id => p_balance_dimension_id
                  ,p_language             => p_language_code
                  );
  end if;
  --
  -- Update the translated values for every matching row
  -- setting SOURCE_LANG to the specified language.
  --
  for l_lang in csr_upd_langs loop
    pay_bdt_upd.upd
      (p_balance_dimension_id        => p_balance_dimension_id
      ,p_language                    => l_lang.language
      ,p_source_lang                 => p_language_code
      ,p_dimension_name              => p_dimension_name
      ,p_database_item_suffix        => p_database_item_suffix
      ,p_description                 => p_description
      );
    --
    -- Record the affected rows in PAY_DYNDBI_CHANGES. This is only
    -- done if translations are supported and if the translation is
    -- actually different.
    --
    if p_record_dbi_changes and
       ff_dbi_utils_pkg.translations_supported
       (p_legislation_code => l_leg_code
       ) then
      if upper(p_database_item_suffix) <>
         upper(l_lang.database_item_suffix) then
        l_langs(i) := l_lang.language;
        i := i + 1;
      end if;
    end if;
  end loop;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
  --
  -- Write any changes to PAY_DYNDBI_CHANGES.
  --
  if p_record_dbi_changes and l_langs.count > 0 then
    pay_dyndbi_changes_pkg.balance_dimension_change
    (p_balance_dimension_id => p_balance_dimension_id
    ,p_languages            => l_langs
    );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,30);
End upd_tl;
--
end pay_bdt_upd;

/
