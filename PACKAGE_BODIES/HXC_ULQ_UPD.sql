--------------------------------------------------------
--  DDL for Package Body HXC_ULQ_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ULQ_UPD" as
/* $Header: hxculqrhi.pkb 120.2 2005/09/23 06:26:40 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ulq_upd.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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
  (p_rec in out nocopy hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
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
  -- Update the hxc_layout_comp_qualifiers Row
  --
  update hxc_layout_comp_qualifiers
    set
     layout_comp_qualifier_id        = p_rec.layout_comp_qualifier_id
    ,qualifier_name                  = p_rec.qualifier_name
    ,qualifier_attribute_category    = p_rec.qualifier_attribute_category
    ,qualifier_attribute1            = p_rec.qualifier_attribute1
    ,qualifier_attribute2            = p_rec.qualifier_attribute2
    ,qualifier_attribute3            = p_rec.qualifier_attribute3
    ,qualifier_attribute4            = p_rec.qualifier_attribute4
    ,qualifier_attribute5            = p_rec.qualifier_attribute5
    ,qualifier_attribute6            = p_rec.qualifier_attribute6
    ,qualifier_attribute7            = p_rec.qualifier_attribute7
    ,qualifier_attribute8            = p_rec.qualifier_attribute8
    ,qualifier_attribute9            = p_rec.qualifier_attribute9
    ,qualifier_attribute10           = p_rec.qualifier_attribute10
    ,qualifier_attribute11           = p_rec.qualifier_attribute11
    ,qualifier_attribute12           = p_rec.qualifier_attribute12
    ,qualifier_attribute13           = p_rec.qualifier_attribute13
    ,qualifier_attribute14           = p_rec.qualifier_attribute14
    ,qualifier_attribute15           = p_rec.qualifier_attribute15
    ,qualifier_attribute16           = p_rec.qualifier_attribute16
    ,qualifier_attribute17           = p_rec.qualifier_attribute17
    ,qualifier_attribute18           = p_rec.qualifier_attribute18
    ,qualifier_attribute19           = p_rec.qualifier_attribute19
    ,qualifier_attribute20           = p_rec.qualifier_attribute20
    ,qualifier_attribute21           = p_rec.qualifier_attribute21
    ,qualifier_attribute22           = p_rec.qualifier_attribute22
    ,qualifier_attribute23           = p_rec.qualifier_attribute23
    ,qualifier_attribute24           = p_rec.qualifier_attribute24
    ,qualifier_attribute25           = p_rec.qualifier_attribute25
    ,qualifier_attribute26           = p_rec.qualifier_attribute26
    ,qualifier_attribute27           = p_rec.qualifier_attribute27
    ,qualifier_attribute28           = p_rec.qualifier_attribute28
    ,qualifier_attribute29           = p_rec.qualifier_attribute29
    ,qualifier_attribute30           = p_rec.qualifier_attribute30
    ,object_version_number           = p_rec.object_version_number
        ,last_updated_by		     = fnd_global.user_id
    ,last_update_date		     = sysdate
    ,last_update_login	             = fnd_global.login_id

    where layout_comp_qualifier_id = p_rec.layout_comp_qualifier_id;
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
    hxc_ulq_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hxc_ulq_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hxc_ulq_shd.constraint_error
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
  (p_rec in hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin

  if g_debug then
  	l_proc := g_package||'pre_update';
  	hr_utility.set_location('Entering:'||l_proc, 5);
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
  (p_rec                          in hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin

  if g_debug then
  	l_proc := g_package||'post_update';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    hxc_ulq_rku.after_update
      (p_layout_comp_qualifier_id
      => p_rec.layout_comp_qualifier_id
      ,p_qualifier_name
      => p_rec.qualifier_name
      ,p_qualifier_attribute_category
      => p_rec.qualifier_attribute_category
      ,p_qualifier_attribute1
      => p_rec.qualifier_attribute1
      ,p_qualifier_attribute2
      => p_rec.qualifier_attribute2
      ,p_qualifier_attribute3
      => p_rec.qualifier_attribute3
      ,p_qualifier_attribute4
      => p_rec.qualifier_attribute4
      ,p_qualifier_attribute5
      => p_rec.qualifier_attribute5
      ,p_qualifier_attribute6
      => p_rec.qualifier_attribute6
      ,p_qualifier_attribute7
      => p_rec.qualifier_attribute7
      ,p_qualifier_attribute8
      => p_rec.qualifier_attribute8
      ,p_qualifier_attribute9
      => p_rec.qualifier_attribute9
      ,p_qualifier_attribute10
      => p_rec.qualifier_attribute10
      ,p_qualifier_attribute11
      => p_rec.qualifier_attribute11
      ,p_qualifier_attribute12
      => p_rec.qualifier_attribute12
      ,p_qualifier_attribute13
      => p_rec.qualifier_attribute13
      ,p_qualifier_attribute14
      => p_rec.qualifier_attribute14
      ,p_qualifier_attribute15
      => p_rec.qualifier_attribute15
      ,p_qualifier_attribute16
      => p_rec.qualifier_attribute16
      ,p_qualifier_attribute17
      => p_rec.qualifier_attribute17
      ,p_qualifier_attribute18
      => p_rec.qualifier_attribute18
      ,p_qualifier_attribute19
      => p_rec.qualifier_attribute19
      ,p_qualifier_attribute20
      => p_rec.qualifier_attribute20
      ,p_qualifier_attribute21
      => p_rec.qualifier_attribute21
      ,p_qualifier_attribute22
      => p_rec.qualifier_attribute22
      ,p_qualifier_attribute23
      => p_rec.qualifier_attribute23
      ,p_qualifier_attribute24
      => p_rec.qualifier_attribute24
      ,p_qualifier_attribute25
      => p_rec.qualifier_attribute25
      ,p_qualifier_attribute26
      => p_rec.qualifier_attribute26
      ,p_qualifier_attribute27
      => p_rec.qualifier_attribute27
      ,p_qualifier_attribute28
      => p_rec.qualifier_attribute28
      ,p_qualifier_attribute29
      => p_rec.qualifier_attribute29
      ,p_qualifier_attribute30
      => p_rec.qualifier_attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_qualifier_name_o
      => hxc_ulq_shd.g_old_rec.qualifier_name
      ,p_qualifier_attribute_catego_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute_category
      ,p_qualifier_attribute1_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute1
      ,p_qualifier_attribute2_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute2
      ,p_qualifier_attribute3_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute3
      ,p_qualifier_attribute4_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute4
      ,p_qualifier_attribute5_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute5
      ,p_qualifier_attribute6_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute6
      ,p_qualifier_attribute7_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute7
      ,p_qualifier_attribute8_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute8
      ,p_qualifier_attribute9_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute9
      ,p_qualifier_attribute10_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute10
      ,p_qualifier_attribute11_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute11
      ,p_qualifier_attribute12_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute12
      ,p_qualifier_attribute13_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute13
      ,p_qualifier_attribute14_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute14
      ,p_qualifier_attribute15_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute15
      ,p_qualifier_attribute16_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute16
      ,p_qualifier_attribute17_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute17
      ,p_qualifier_attribute18_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute18
      ,p_qualifier_attribute19_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute19
      ,p_qualifier_attribute20_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute20
      ,p_qualifier_attribute21_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute21
      ,p_qualifier_attribute22_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute22
      ,p_qualifier_attribute23_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute23
      ,p_qualifier_attribute24_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute24
      ,p_qualifier_attribute25_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute25
      ,p_qualifier_attribute26_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute26
      ,p_qualifier_attribute27_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute27
      ,p_qualifier_attribute28_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute28
      ,p_qualifier_attribute29_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute29
      ,p_qualifier_attribute30_o
      => hxc_ulq_shd.g_old_rec.qualifier_attribute30
      ,p_object_version_number_o
      => hxc_ulq_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_LAYOUT_COMP_QUALIFIERS'
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
  (p_rec in out nocopy hxc_ulq_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.qualifier_name = hr_api.g_varchar2) then
    p_rec.qualifier_name :=
    hxc_ulq_shd.g_old_rec.qualifier_name;
  End If;
  If (p_rec.qualifier_attribute_category = hr_api.g_varchar2) then
    p_rec.qualifier_attribute_category :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute_category;
  End If;
  If (p_rec.qualifier_attribute1 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute1 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute1;
  End If;
  If (p_rec.qualifier_attribute2 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute2 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute2;
  End If;
  If (p_rec.qualifier_attribute3 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute3 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute3;
  End If;
  If (p_rec.qualifier_attribute4 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute4 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute4;
  End If;
  If (p_rec.qualifier_attribute5 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute5 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute5;
  End If;
  If (p_rec.qualifier_attribute6 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute6 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute6;
  End If;
  If (p_rec.qualifier_attribute7 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute7 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute7;
  End If;
  If (p_rec.qualifier_attribute8 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute8 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute8;
  End If;
  If (p_rec.qualifier_attribute9 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute9 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute9;
  End If;
  If (p_rec.qualifier_attribute10 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute10 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute10;
  End If;
  If (p_rec.qualifier_attribute11 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute11 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute11;
  End If;
  If (p_rec.qualifier_attribute12 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute12 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute12;
  End If;
  If (p_rec.qualifier_attribute13 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute13 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute13;
  End If;
  If (p_rec.qualifier_attribute14 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute14 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute14;
  End If;
  If (p_rec.qualifier_attribute15 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute15 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute15;
  End If;
  If (p_rec.qualifier_attribute16 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute16 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute16;
  End If;
  If (p_rec.qualifier_attribute17 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute17 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute17;
  End If;
  If (p_rec.qualifier_attribute18 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute18 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute18;
  End If;
  If (p_rec.qualifier_attribute19 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute19 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute19;
  End If;
  If (p_rec.qualifier_attribute20 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute20 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute20;
  End If;
  If (p_rec.qualifier_attribute21 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute21 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute21;
  End If;
  If (p_rec.qualifier_attribute22 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute22 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute22;
  End If;
  If (p_rec.qualifier_attribute23 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute23 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute23;
  End If;
  If (p_rec.qualifier_attribute24 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute24 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute24;
  End If;
  If (p_rec.qualifier_attribute25 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute25 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute25;
  End If;
  If (p_rec.qualifier_attribute26 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute26 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute26;
  End If;
  If (p_rec.qualifier_attribute27 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute27 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute27;
  End If;
  If (p_rec.qualifier_attribute28 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute28 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute28;
  End If;
  If (p_rec.qualifier_attribute29 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute29 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute29;
  End If;
  If (p_rec.qualifier_attribute30 = hr_api.g_varchar2) then
    p_rec.qualifier_attribute30 :=
    hxc_ulq_shd.g_old_rec.qualifier_attribute30;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'upd';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to update.
  --
  hxc_ulq_shd.lck
    (p_rec.layout_comp_qualifier_id
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
  hxc_ulq_bus.update_validate
     (p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  hxc_ulq_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hxc_ulq_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hxc_ulq_upd.post_update
     (p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_layout_comp_qualifier_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_layout_component_id          in     number    default hr_api.g_number
  ,p_qualifier_name               in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute_category in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute1         in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute2         in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute3         in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute4         in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute5         in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute6         in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute7         in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute8         in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute9         in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute10        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute11        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute12        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute13        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute14        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute15        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute16        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute17        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute18        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute19        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute20        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute21        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute22        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute23        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute24        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute25        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute26        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute27        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute28        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute29        in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_attribute30        in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  hxc_ulq_shd.g_rec_type;
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'upd';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hxc_ulq_shd.convert_args
  (p_layout_comp_qualifier_id
  ,p_layout_component_id
  ,p_qualifier_name
  ,p_qualifier_attribute_category
  ,p_qualifier_attribute1
  ,p_qualifier_attribute2
  ,p_qualifier_attribute3
  ,p_qualifier_attribute4
  ,p_qualifier_attribute5
  ,p_qualifier_attribute6
  ,p_qualifier_attribute7
  ,p_qualifier_attribute8
  ,p_qualifier_attribute9
  ,p_qualifier_attribute10
  ,p_qualifier_attribute11
  ,p_qualifier_attribute12
  ,p_qualifier_attribute13
  ,p_qualifier_attribute14
  ,p_qualifier_attribute15
  ,p_qualifier_attribute16
  ,p_qualifier_attribute17
  ,p_qualifier_attribute18
  ,p_qualifier_attribute19
  ,p_qualifier_attribute20
  ,p_qualifier_attribute21
  ,p_qualifier_attribute22
  ,p_qualifier_attribute23
  ,p_qualifier_attribute24
  ,p_qualifier_attribute25
  ,p_qualifier_attribute26
  ,p_qualifier_attribute27
  ,p_qualifier_attribute28
  ,p_qualifier_attribute29
  ,p_qualifier_attribute30
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hxc_ulq_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End upd;
--
end hxc_ulq_upd;

/
