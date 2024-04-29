--------------------------------------------------------
--  DDL for Package Body PQH_ATL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ATL_UPD" as
/* $Header: pqatlrhi.pkb 120.2 2006/05/23 15:58:59 srajakum ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_atl_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy pqh_atl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Update the pqh_attributes_tl Row
  --
  update pqh_attributes_tl
  set
  attribute_id                      = p_rec.attribute_id,
  attribute_name                    = p_rec.attribute_name,
  language                          = p_rec.language,
  source_lang                       = p_rec.source_lang
  where attribute_id = p_rec.attribute_id
  and   language = p_rec.language;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_atl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_atl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_atl_shd.constraint_error
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
Procedure pre_update(p_rec in pqh_atl_shd.g_rec_type) is
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
Procedure post_update(p_rec in pqh_atl_shd.g_rec_type) is
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
    pqh_atl_rku.after_update
      (
  p_attribute_id                  =>p_rec.attribute_id
 ,p_attribute_name                =>p_rec.attribute_name
 ,p_language                      =>p_rec.language
 ,p_source_lang                   =>p_rec.source_lang
 ,p_attribute_name_o              =>pqh_atl_shd.g_old_rec.attribute_name
 ,p_language_o                    =>pqh_atl_shd.g_old_rec.language
 ,p_source_lang_o                 =>pqh_atl_shd.g_old_rec.source_lang
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_attributes_tl'
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
Procedure convert_defs(p_rec in out nocopy pqh_atl_shd.g_rec_type) is
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
  If (p_rec.attribute_name = hr_api.g_varchar2) then
    p_rec.attribute_name :=
    pqh_atl_shd.g_old_rec.attribute_name;
  End If;
  If (p_rec.source_lang = hr_api.g_varchar2) then
    p_rec.source_lang :=
    pqh_atl_shd.g_old_rec.source_lang;
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
  p_rec        in out nocopy pqh_atl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_atl_shd.lck
	(
	p_rec.attribute_id,
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
  pqh_atl_bus.update_validate(p_rec);
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
  p_attribute_id                 in number,
  p_attribute_name               in varchar2         default hr_api.g_varchar2,
  p_language                     in varchar2,
  p_source_lang                  in varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec	  pqh_atl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_atl_shd.convert_args
  (
  p_attribute_id,
  p_attribute_name,
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
procedure upd_tl ( p_language_code              in varchar2,
                   p_attribute_id               in number,
                   p_attribute_name             in varchar2 ) is
--
cursor csr_upd_langs is
     select atl.language
       from pqh_attributes_tl atl
      where atl.attribute_id = p_attribute_id
        AND p_language_code in (atl.language,atl.source_lang);
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
      (p_attribute_id    => p_attribute_id,
       p_attribute_name                       => p_attribute_name,
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
    p_attribute_name                in varchar2,
    p_att_col_name                  in varchar2,
    p_att_master_table_alias_name   in varchar2,
    p_legislation_code              in varchar2,
    p_owner                         in varchar2 ) is

--
cursor csr_attribute_id(p_column_name IN VARCHAR2, p_table_id IN NUMBER, p_legislation_code in varchar2) is
 select attribute_id
 from pqh_attributes
 where key_column_name = p_att_col_name
   and nvl(legislation_code,'$$$') = nvl(p_legislation_code,'$$$')
   and nvl(master_table_route_id,-1) = nvl(p_table_id, -1);
--
cursor csr_table_id (p_table_alias IN VARCHAR2) is
 select table_route_id
 from pqh_table_route
 where table_alias = p_table_alias;
--

l_attribute_id                number(15);
l_att_master_table_route_id   number(15);

X_CREATION_DATE DATE;
X_CREATED_BY NUMBER;
X_LAST_UPDATE_DATE DATE;
X_LAST_UPDATED_BY NUMBER;
X_LAST_UPDATE_LOGIN NUMBER;


begin
-- get attribute_id
--
  open csr_table_id(p_table_alias => p_att_master_table_alias_name );
   fetch csr_table_id into l_att_master_table_route_id;
  close csr_table_id;
--
  open csr_attribute_id(p_column_name => p_att_col_name, p_table_id => l_att_master_table_route_id, p_legislation_code => p_legislation_code);
   fetch csr_attribute_id into l_attribute_id;
  close csr_attribute_id;
--

-- populate WHO columns
  if p_owner = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := -1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;

  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
  X_LAST_UPDATED_BY := fnd_load_util.owner_id(p_owner);

    update pqh_attributes_tl
    set attribute_name    = p_attribute_name ,
        last_update_date  = X_LAST_UPDATE_DATE,
        last_updated_by   = X_LAST_UPDATED_BY,
        last_update_login = X_LAST_UPDATE_LOGIN,
        source_lang = USERENV('LANG')
    where USERENV('LANG') in (language,source_lang)
    and attribute_id  = l_attribute_id ;
--
end translate_row;
--
end pqh_atl_upd;

/
