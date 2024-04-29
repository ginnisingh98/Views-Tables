--------------------------------------------------------
--  DDL for Package Body PQH_RTL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RTL_UPD" as
/* $Header: pqrtlrhi.pkb 115.7 2003/01/26 02:01:52 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rtl_upd.';  -- Global package name
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
--   2) To update the specified row in the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
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
Procedure update_dml(p_rec in out nocopy pqh_rtl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Update the pqh_rule_sets_tl Row
  --
  update pqh_rule_sets_tl
  set
  rule_set_id                       = p_rec.rule_set_id,
  rule_set_name                     = p_rec.rule_set_name,
  description			    = p_rec.description,
  language                          = p_rec.language,
  source_lang                       = p_rec.source_lang
  where rule_set_id = p_rec.rule_set_id
  and   language = p_rec.language;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_rtl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_rtl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_rtl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in pqh_rtl_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in pqh_rtl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    pqh_rtl_rku.after_update
      (
  p_rule_set_id                   =>p_rec.rule_set_id
 ,p_rule_set_name                 =>p_rec.rule_set_name
 ,p_description			  =>p_rec.description
 ,p_language                      =>p_rec.language
 ,p_source_lang                   =>p_rec.source_lang
 ,p_rule_set_name_o               =>pqh_rtl_shd.g_old_rec.rule_set_name
 ,p_description_o		  =>pqh_rtl_shd.g_old_rec.description
 ,p_language_o                    =>pqh_rtl_shd.g_old_rec.language
 ,p_source_lang_o                 =>pqh_rtl_shd.g_old_rec.source_lang
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_rule_sets_tl'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
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
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy pqh_rtl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.rule_set_name = hr_api.g_varchar2) then
    p_rec.rule_set_name :=
    pqh_rtl_shd.g_old_rec.rule_set_name;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    pqh_rtl_shd.g_old_rec.description;
  End If;
  If (p_rec.source_lang = hr_api.g_varchar2) then
    p_rec.source_lang :=
    pqh_rtl_shd.g_old_rec.source_lang;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy pqh_rtl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_rtl_shd.lck
	(
	p_rec.rule_set_id,
	p_rec.language
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pqh_rtl_bus.update_validate(p_rec);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rule_set_id                  in number,
  p_rule_set_name                in varchar2         default hr_api.g_varchar2,
  p_description			 in varchar2	     default hr_api.g_varchar2,
  p_language                     in varchar2,
  p_source_lang                  in varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec	  pqh_rtl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_rtl_shd.convert_args
  (
  p_rule_set_id,
  p_rule_set_name,
  p_description,
  p_language,
  p_source_lang
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd_tl >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure upd_tl ( p_language_code         in varchar2,
                   p_rule_set_id           in number,
                   p_rule_set_name         in varchar2,
                   p_description	   in varchar2
                   ) is
--
cursor csr_upd_langs is
     select rtl.language
       from pqh_rule_sets_tl rtl
      where rtl.rule_set_id = p_rule_set_id
        AND p_language_code in (rtl.language,rtl.source_lang);
--
  l_proc  varchar2(72) := g_package||'upd_tl';
--
begin
  --
  hr_utility.set_location(' Entering:'||l_proc, 10);
  --
  for l_lang in csr_upd_langs loop
  --
  --
    upd
      (p_rule_set_id    => p_rule_set_id,
       p_rule_set_name              => p_rule_set_name,
       p_description		    => p_description,
       p_language                   => l_lang.language,
       p_source_lang                => p_language_code) ;
  --
  --
  end loop;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
end upd_tl;
--
--  -----------    Translate Row    -------------------------------------------
--
Procedure translate_row (
                   p_short_name            in varchar2,
                   p_rule_set_name         in varchar2 ,
                   p_description	   in varchar2,
                   p_owner                 in varchar2
                   ) is

--
 l_rule_set_id           pqh_rule_sets.rule_set_id%type := 0;
--
--
   l_created_by                 pqh_rule_sets.created_by%TYPE;
   l_last_updated_by            pqh_rule_sets.last_updated_by%TYPE;
   l_creation_date              pqh_rule_sets.creation_date%TYPE;
   l_last_update_date           pqh_rule_sets.last_update_date%TYPE;
   l_last_update_login          pqh_rule_sets.last_update_login%TYPE;
--
--
  Cursor c1 is select rule_set_id
               from pqh_rule_sets
               where short_name = p_short_name ;
--
--
BEGIN
--
--
   Open c1;
   Fetch c1 into l_rule_set_id;
   Close c1;
--
--
-- populate WHO columns
--
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := -1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;

  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;

--
--
    update pqh_rule_sets_tl
    set rule_set_name  = p_rule_set_name ,
        description    = p_description,
         last_updated_by                =  l_last_updated_by,
         last_update_date               =  l_last_update_date,
         last_update_login              =  l_last_update_login,
        source_lang    = USERENV('LANG')
    where USERENV('LANG') in (language,source_lang)
    and rule_set_id  = l_rule_set_id ;
--
end translate_row;
--
--
end pqh_rtl_upd;

/
