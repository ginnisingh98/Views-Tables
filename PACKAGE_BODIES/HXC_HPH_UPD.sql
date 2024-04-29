--------------------------------------------------------
--  DDL for Package Body HXC_HPH_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HPH_UPD" as
/* $Header: hxchphrhi.pkb 120.2.12000000.2 2007/03/16 13:22:54 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_hph_upd.';  -- Global package name
g_debug	   boolean	:= hr_utility.debug_enabled;
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
  (p_rec in out nocopy hxc_hph_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
	l_proc := g_package||'update_dml';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the hxc_pref_hierarchies Row
  --
  update hxc_pref_hierarchies
    set
     pref_hierarchy_id               = p_rec.pref_hierarchy_id
    ,type                            = p_rec.type
    ,name                            = p_rec.name
    ,business_group_id		     = p_rec.business_group_id
    ,legislation_code		     = p_rec.legislation_code
    ,parent_pref_hierarchy_id        = p_rec.parent_pref_hierarchy_id
    ,edit_allowed                    = p_rec.edit_allowed
    ,displayed                       = p_rec.displayed
    ,pref_definition_id              = p_rec.pref_definition_id
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,attribute21                     = p_rec.attribute21
    ,attribute22                     = p_rec.attribute22
    ,attribute23                     = p_rec.attribute23
    ,attribute24                     = p_rec.attribute24
    ,attribute25                     = p_rec.attribute25
    ,attribute26                     = p_rec.attribute26
    ,attribute27                     = p_rec.attribute27
    ,attribute28                     = p_rec.attribute28
    ,attribute29                     = p_rec.attribute29
    ,attribute30                     = p_rec.attribute30
    ,object_version_number           = p_rec.object_version_number
    ,orig_pref_hierarchy_id          = p_rec.orig_pref_hierarchy_id
    ,orig_parent_hierarchy_id        = p_rec.orig_parent_hierarchy_id
    ,top_level_parent_id             = p_rec.top_level_parent_id  --performance Fix
    ,code                            = p_rec.code
        ,last_updated_by		     = fnd_global.user_id
    ,last_update_date		     = sysdate
    ,last_update_login	             = fnd_global.login_id

    where pref_hierarchy_id = p_rec.pref_hierarchy_id;
  --
  --
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hxc_hph_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hxc_hph_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hxc_hph_shd.constraint_error
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
  (p_rec in out nocopy hxc_hph_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--Performance Fix
  cursor c_top_level_node(p_pref_hierarchy_id number)
        is
                select pref_hierarchy_id
                  from  hxc_pref_hierarchies
		 where parent_pref_hierarchy_id is null
               connect by prior parent_pref_hierarchy_id = pref_hierarchy_id
                 start with pref_hierarchy_id = p_pref_hierarchy_id;

  Cursor c_code(p_pref_definition_id number)
       is
                select hpd.code
                from   hxc_pref_definitions hpd
                where  pref_definition_id = p_pref_definition_id;

  l_top_node_id number := p_rec.pref_hierarchy_id;
  l_node_id     number;
  l_code        varchar2(30);
--

--
Begin
  if g_debug then
	l_proc := g_package||'pre_update';
	hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  --
	if (p_rec.pref_definition_id is not null) then
        -- Get the top level parent ID
        open c_top_level_node(l_top_node_id);
           fetch c_top_level_node into l_top_node_id;
        close c_top_level_node;
	if (l_top_node_id <> p_rec.pref_hierarchy_id) then
          p_rec.top_level_parent_id := l_top_node_id;
	else
	  p_rec.top_level_parent_id := null;
	end if;
        -- Get the code for the node
        open c_code(p_rec.pref_definition_id);
        fetch c_code into l_code;
           p_rec.code := l_code;
        close c_code;
	else
	   p_rec.top_level_parent_id := null;
	   p_rec.code := null;
	end if;

  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  (p_effective_date               in date
  ,p_rec                          in hxc_hph_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;

--
Begin
  if g_debug then
	l_proc:= g_package||'post_update';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    hxc_hph_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_pref_hierarchy_id
      => p_rec.pref_hierarchy_id
      ,p_type
      => p_rec.type
      ,p_name
      => p_rec.name
       ,p_business_group_id	     => p_rec.business_group_id
      ,p_legislation_code	     => p_rec.legislation_code
      ,p_parent_pref_hierarchy_id
      => p_rec.parent_pref_hierarchy_id
      ,p_edit_allowed
      => p_rec.edit_allowed
      ,p_displayed
      => p_rec.displayed
      ,p_pref_definition_id
      => p_rec.pref_definition_id
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_orig_pref_hierarchy_id
      => p_rec.orig_pref_hierarchy_id
      ,p_orig_parent_hierarchy_id
      => p_rec.orig_parent_hierarchy_id
      ,p_top_level_parent_id    --Performance Fix
      => p_rec.top_level_parent_id
      ,p_code
      => p_rec.code
      ,p_type_o
      => hxc_hph_shd.g_old_rec.type
      ,p_name_o
      => hxc_hph_shd.g_old_rec.name
      ,p_business_group_id_o	     => hxc_ter_shd.g_old_rec.business_group_id
      ,p_legislation_code_o	     => hxc_ter_shd.g_old_rec.legislation_code
      ,p_parent_pref_hierarchy_id_o
      => hxc_hph_shd.g_old_rec.parent_pref_hierarchy_id
      ,p_edit_allowed_o
      => hxc_hph_shd.g_old_rec.edit_allowed
      ,p_displayed_o
      => hxc_hph_shd.g_old_rec.displayed
      ,p_pref_definition_id_o
      => hxc_hph_shd.g_old_rec.pref_definition_id
      ,p_attribute_category_o
      => hxc_hph_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => hxc_hph_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => hxc_hph_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => hxc_hph_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => hxc_hph_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => hxc_hph_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => hxc_hph_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => hxc_hph_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => hxc_hph_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => hxc_hph_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => hxc_hph_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => hxc_hph_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => hxc_hph_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => hxc_hph_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => hxc_hph_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => hxc_hph_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => hxc_hph_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => hxc_hph_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => hxc_hph_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => hxc_hph_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => hxc_hph_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => hxc_hph_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => hxc_hph_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => hxc_hph_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => hxc_hph_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => hxc_hph_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => hxc_hph_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => hxc_hph_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => hxc_hph_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => hxc_hph_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => hxc_hph_shd.g_old_rec.attribute30
      ,p_object_version_number_o
      => hxc_hph_shd.g_old_rec.object_version_number
      ,p_orig_pref_hierarchy_id_o
      => hxc_hph_shd.g_old_rec.orig_pref_hierarchy_id
      ,p_orig_parent_hierarchy_id_o
      => hxc_hph_shd.g_old_rec.orig_parent_hierarchy_id
      ,p_top_level_parent_id_o   --Performance Fix
      => hxc_hph_shd.g_old_rec.top_level_parent_id
      ,p_code_o
      => hxc_hph_shd.g_old_rec.code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_PREF_HIERARCHIES'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  (p_rec in out nocopy hxc_hph_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.type = hr_api.g_varchar2) then
    p_rec.type :=
    hxc_hph_shd.g_old_rec.type;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    hxc_hph_shd.g_old_rec.name;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    hxc_ter_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    hxc_ter_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.parent_pref_hierarchy_id = hr_api.g_number) then
    p_rec.parent_pref_hierarchy_id :=
    hxc_hph_shd.g_old_rec.parent_pref_hierarchy_id;
  End If;
  If (p_rec.edit_allowed = hr_api.g_varchar2) then
    p_rec.edit_allowed :=
    hxc_hph_shd.g_old_rec.edit_allowed;
  End If;
  If (p_rec.displayed = hr_api.g_varchar2) then
    p_rec.displayed :=
    hxc_hph_shd.g_old_rec.displayed;
  End If;
  If (p_rec.pref_definition_id = hr_api.g_number) then
    p_rec.pref_definition_id :=
    hxc_hph_shd.g_old_rec.pref_definition_id;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    hxc_hph_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    hxc_hph_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    hxc_hph_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    hxc_hph_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    hxc_hph_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    hxc_hph_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    hxc_hph_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    hxc_hph_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    hxc_hph_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    hxc_hph_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    hxc_hph_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    hxc_hph_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    hxc_hph_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    hxc_hph_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    hxc_hph_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    hxc_hph_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    hxc_hph_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    hxc_hph_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    hxc_hph_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    hxc_hph_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    hxc_hph_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    hxc_hph_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    hxc_hph_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    hxc_hph_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    hxc_hph_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    hxc_hph_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    hxc_hph_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    hxc_hph_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    hxc_hph_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    hxc_hph_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    hxc_hph_shd.g_old_rec.attribute30;
  End If;
  If (p_rec.orig_pref_hierarchy_id = hr_api.g_number) then
    p_rec.orig_pref_hierarchy_id :=
    hxc_hph_shd.g_old_rec.orig_pref_hierarchy_id;
  End If;
  If (p_rec.orig_parent_hierarchy_id = hr_api.g_number) then
    p_rec.orig_parent_hierarchy_id :=
    hxc_hph_shd.g_old_rec.orig_parent_hierarchy_id;
  End If;
  If (p_rec.top_level_parent_id = hr_api.g_number) then -- Performance Fix
    p_rec.top_level_parent_id :=
    hxc_hph_shd.g_old_rec.top_level_parent_id;
  End If;
  If (p_rec.code = hr_api.g_varchar2) then
    p_rec.code :=
    hxc_hph_shd.g_old_rec.code;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy hxc_hph_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	  l_proc := g_package||'upd';
	  hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to update.
  --
  hxc_hph_shd.lck
    (p_rec.pref_hierarchy_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  hxc_hph_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  hxc_hph_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hxc_hph_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hxc_hph_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_pref_hierarchy_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_edit_allowed                 in     varchar2  default hr_api.g_varchar2
  ,p_displayed                    in     varchar2  default hr_api.g_varchar2
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_parent_pref_hierarchy_id     in     number    default hr_api.g_number
  ,p_pref_definition_id           in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_orig_pref_hierarchy_id       in     number    default hr_api.g_number
  ,p_orig_parent_hierarchy_id     in     number    default hr_api.g_number
  ,p_top_level_parent_id          in     number    default hr_api.g_number --Performance Fix
  ,p_code                         in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  hxc_hph_shd.g_rec_type;
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'upd';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hxc_hph_shd.convert_args
  (p_pref_hierarchy_id
  ,p_type
  ,p_name
  ,p_business_group_id
  ,p_legislation_code
  ,p_parent_pref_hierarchy_id
  ,p_edit_allowed
  ,p_displayed
  ,p_pref_definition_id
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_attribute21
  ,p_attribute22
  ,p_attribute23
  ,p_attribute24
  ,p_attribute25
  ,p_attribute26
  ,p_attribute27
  ,p_attribute28
  ,p_attribute29
  ,p_attribute30
  ,p_object_version_number
  ,p_orig_pref_hierarchy_id
  ,p_orig_parent_hierarchy_id
  ,p_top_level_parent_id   --Performance Fix
  ,p_code
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hxc_hph_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End upd;
--
end hxc_hph_upd;

/
