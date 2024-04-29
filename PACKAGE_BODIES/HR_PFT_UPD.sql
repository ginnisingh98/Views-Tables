--------------------------------------------------------
--  DDL for Package Body HR_PFT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PFT_UPD" as
/* $Header: hrpftrhi.pkb 120.0 2005/05/31 02:07:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_pft_upd.';  -- Global package name
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
  (p_rec in out nocopy hr_pft_shd.g_rec_type
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
  -- Update the hr_all_positions_f_tl Row
  --
  update hr_all_positions_f_tl
    set
     position_id                     = p_rec.position_id
    ,language                        = p_rec.language
    ,source_lang                     = p_rec.source_lang
    ,name                            = p_rec.name
    where position_id = p_rec.position_id
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
    hr_pft_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_pft_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_pft_shd.constraint_error
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
  (p_rec in hr_pft_shd.g_rec_type
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
  (p_rec                          in hr_pft_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_pft_rku.after_update
      (p_position_id
      => p_rec.position_id
      ,p_language
      => p_rec.language
      ,p_source_lang
      => p_rec.source_lang
      ,p_name
      => p_rec.name
      ,p_source_lang_o
      => hr_pft_shd.g_old_rec.source_lang
      ,p_name_o
      => hr_pft_shd.g_old_rec.name
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_ALL_POSITIONS_F_TL'
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
  (p_rec in out nocopy hr_pft_shd.g_rec_type
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
    hr_pft_shd.g_old_rec.source_lang;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    hr_pft_shd.g_old_rec.name;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hr_pft_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  hr_pft_shd.lck
    (p_rec.position_id
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
  hr_pft_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  hr_pft_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hr_pft_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hr_pft_upd.post_update
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_position_id                  in     number
  ,p_language                     in     varchar2
  ,p_source_lang                  in     varchar2  default hr_api.g_varchar2
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   hr_pft_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_pft_shd.convert_args
  (p_position_id
  ,p_language
  ,p_source_lang
  ,p_name
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hr_pft_upd.upd
     (l_rec
     );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd_key_flex_meanings >-------------------|
-- ----------------------------------------------------------------------------
--
Procedure upd_key_flex_meanings
  ( p_position_id                 in number --Primary key of base table
  , p_position_definition_id      in number
  ) IS
  --
  l_current_language_code  fnd_languages.nls_language%TYPE := userenv('LANG');
  --
  l_pft_rec                hr_pft_shd.g_rec_type;

  --
  --Will return a cartesian set (we want every installed/base lang)
  cursor c_languages IS
  select l.language_code
       , l.nls_language
       , pd.id_flex_num
    from fnd_languages l
       , per_position_definitions pd
   where pd.position_definition_id = p_position_definition_id
     and l.installed_flag IN ('B', 'I');

  begin

    for l_language IN c_languages LOOP

       -- Lock the existing record (which may already be updated)
       hr_pft_shd.lck
         ( p_position_id
         , l_language.language_code
         );

       --Get the local record values from the locked record
       l_pft_rec := hr_pft_shd.g_old_rec;

       --Set the session language (this also clears the key flex cache)
       hr_kflex_utility.set_session_nls_language(l_language.nls_language);

       --Populate the local record with translated key flex meanings
       l_pft_rec.name := fnd_flex_ext.get_segs( 'PER'
                                              , 'POS'
                                              , l_language.id_flex_num
                                              , p_position_definition_id
                                              );

       --When generated name is null, use hr_all_positions_f.name
       if l_pft_rec.name is null then
         begin
           select psf.name into  l_pft_rec.name
           from hr_all_positions_f psf
           where psf.position_id = p_position_id
           and psf.effective_end_date = hr_general.end_of_time;
         exception
           when others then
             null;
         end;
       end if;

       --Update the record
       update_dml(l_pft_rec);

    end loop;

    -- Set the session language back to original (this also clears the key flex cache)
    hr_kflex_utility.set_session_language_code(l_current_language_code);
  exception
    when others then
      if ( l_current_language_code IS NOT NULL ) then
        hr_kflex_utility.set_session_language_code(l_current_language_code);
      end if;
    raise;
  end;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd_tl >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_tl
  (p_language_code                 in varchar2
  ,p_position_id                  in number
  ,p_position_definition_id       in number
  ) is
  --
  -- Cursor to obtain the translation rows where the language or
  -- source_lang match the specified language.
  --
  cursor csr_upd_langs is
    select pft.language
      from hr_all_positions_f_tl pft
     where pft.position_id = p_position_id
       and p_language_code in (pft.language
                              ,pft.source_lang);
  --
  l_proc  varchar2(72) := g_package||'upd_tl';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Update the translated values for every matching row
  -- setting SOURCE_LANG to the specified language.
  --
  -- PMFLETCH Only need to do this update if there are additional
  -- translated columns (i.e. more than just the key flex values)
  --for l_lang in csr_upd_langs loop
  --  hr_pft_upd.upd
  --    (p_position_id                 => p_position_id
  --    ,p_language                    => l_lang.language
  --    ,p_source_lang                 => p_language_code
  --    ,p_name                        => p_name
  --    );
  --end loop;
  --
  -- PMFLETCH Update the key flex meanings
  upd_key_flex_meanings( p_position_id
                       , p_position_definition_id
                       );
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
End upd_tl;
--
end hr_pft_upd;

/
