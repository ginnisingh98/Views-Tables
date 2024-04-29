--------------------------------------------------------
--  DDL for Package Body HXC_TAT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TAT_UPD" as
/* $Header: hxtatrhi.pkb 120.2 2005/09/23 07:03:57 rchennur noship $ */
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
g_package  varchar2(33)	:= '  hxc_tat_upd.';  -- global package name
g_debug boolean := hr_utility.debug_enabled;
-- --------------------------------------------------------------------------
-- |------------------------------< update_dml >----------------------------|
-- --------------------------------------------------------------------------
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
--   if a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   if any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure update_dml
  (p_rec in out nocopy hxc_tat_shd.g_rec_type
  ) is

l_proc  varchar2(72) ;

begin

  if g_debug then
  	l_proc := g_package||'update_dml';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- increment the object version

  p_rec.object_version_number := p_rec.object_version_number + 1;


  -- update the hxc_time_attributes row

  update hxc_time_attributes
    set
     time_attribute_id               = p_rec.time_attribute_id
    ,object_version_number           = p_rec.object_version_number
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
    ,bld_blk_info_type_id            = p_rec.bld_blk_info_type_id
    ,data_set_id                     = p_rec.data_set_id
    where time_attribute_id = p_rec.time_attribute_id;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

exception
  when hr_api.check_integrity_violated then
    hxc_tat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  when hr_api.parent_integrity_violated then
    hxc_tat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  when hr_api.unique_integrity_violated then
    hxc_tat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  when others then
    raise;

end update_dml;

-- --------------------------------------------------------------------------
-- |------------------------------< pre_update >----------------------------|
-- --------------------------------------------------------------------------
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
--   processing continues.
--
-- Post Failure:
--   if an error has occurred, an error message and exception wil be raised
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
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure pre_update
  (p_rec in hxc_tat_shd.g_rec_type
  ) is

l_proc  varchar2(72) ;

begin

  if g_debug then
  	l_proc := g_package||'pre_update';
  	hr_utility.set_location('Entering:'||l_proc, 5);
   	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end pre_update;

-- --------------------------------------------------------------------------
-- |-----------------------------< post_update >----------------------------|
-- --------------------------------------------------------------------------
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
--   processing continues.
--
-- Post Failure:
--   if an error has occurred, an error message and exception will be raised
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
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure post_update
  (p_effective_date in date
  ,p_rec            in hxc_tat_shd.g_rec_type
  ) is

l_proc  varchar2(72) ;

begin

  if g_debug then
  	l_proc := g_package||'post_update';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  begin

    hxc_tat_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_time_attribute_id
      => p_rec.time_attribute_id
      ,p_object_version_number
      => p_rec.object_version_number
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
      ,p_bld_blk_info_type_id
      => p_rec.bld_blk_info_type_id
      ,p_object_version_number_o
      => hxc_tat_shd.g_old_rec.object_version_number
      ,p_attribute_category_o
      => hxc_tat_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => hxc_tat_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => hxc_tat_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => hxc_tat_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => hxc_tat_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => hxc_tat_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => hxc_tat_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => hxc_tat_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => hxc_tat_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => hxc_tat_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => hxc_tat_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => hxc_tat_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => hxc_tat_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => hxc_tat_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => hxc_tat_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => hxc_tat_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => hxc_tat_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => hxc_tat_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => hxc_tat_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => hxc_tat_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => hxc_tat_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => hxc_tat_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => hxc_tat_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => hxc_tat_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => hxc_tat_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => hxc_tat_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => hxc_tat_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => hxc_tat_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => hxc_tat_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => hxc_tat_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => hxc_tat_shd.g_old_rec.attribute30
      ,p_bld_blk_info_type_id_o
      => hxc_tat_shd.g_old_rec.bld_blk_info_type_id
      );

  exception

    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_TIME_ATTRIBUTES'
        ,p_hook_type   => 'AU');
  end;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end post_update;

-- --------------------------------------------------------------------------
-- |-----------------------------< convert_defs >---------------------------|
-- --------------------------------------------------------------------------
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
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure convert_defs
  (p_rec in out nocopy hxc_tat_shd.g_rec_type
  ) is

begin

  -- we must now examine each argument value in the p_rec plsql record
  -- structure to see if a system default is being used.  if a system
  -- default is being used then we must set to the 'current' argument value.

  if (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    hxc_tat_shd.g_old_rec.attribute_category;
  end if;

  if (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    hxc_tat_shd.g_old_rec.attribute1;
  end if;

  if (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    hxc_tat_shd.g_old_rec.attribute2;
  end if;

  if (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    hxc_tat_shd.g_old_rec.attribute3;
  end if;

  if (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    hxc_tat_shd.g_old_rec.attribute4;
  end if;

  if (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    hxc_tat_shd.g_old_rec.attribute5;
  end if;

  if (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    hxc_tat_shd.g_old_rec.attribute6;
  end if;

  if (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    hxc_tat_shd.g_old_rec.attribute7;
  end if;

  if (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    hxc_tat_shd.g_old_rec.attribute8;
  end if;

  if (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    hxc_tat_shd.g_old_rec.attribute9;
  end if;

  if (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    hxc_tat_shd.g_old_rec.attribute10;
  end if;

  if (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    hxc_tat_shd.g_old_rec.attribute11;
  end if;

  if (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    hxc_tat_shd.g_old_rec.attribute12;
  end if;

  if (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    hxc_tat_shd.g_old_rec.attribute13;
  end if;

  if (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    hxc_tat_shd.g_old_rec.attribute14;
  end if;

  if (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    hxc_tat_shd.g_old_rec.attribute15;
  end if;

  if (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    hxc_tat_shd.g_old_rec.attribute16;
  end if;

  if (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    hxc_tat_shd.g_old_rec.attribute17;
  end if;

  if (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    hxc_tat_shd.g_old_rec.attribute18;
  end if;

  if (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    hxc_tat_shd.g_old_rec.attribute19;
  end if;

  if (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    hxc_tat_shd.g_old_rec.attribute20;
  end if;

  if (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    hxc_tat_shd.g_old_rec.attribute21;
  end if;

  if (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    hxc_tat_shd.g_old_rec.attribute22;
  end if;

  if (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    hxc_tat_shd.g_old_rec.attribute23;
  end if;

  if (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    hxc_tat_shd.g_old_rec.attribute24;
  end if;

  if (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    hxc_tat_shd.g_old_rec.attribute25;
  end if;

  if (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    hxc_tat_shd.g_old_rec.attribute26;
  end if;

  if (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    hxc_tat_shd.g_old_rec.attribute27;
  end if;

  if (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    hxc_tat_shd.g_old_rec.attribute28;
  end if;

  if (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    hxc_tat_shd.g_old_rec.attribute29;
  end if;

  if (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    hxc_tat_shd.g_old_rec.attribute30;
  end if;

  if (p_rec.bld_blk_info_type_id = hr_api.g_number) then
    p_rec.bld_blk_info_type_id :=
    hxc_tat_shd.g_old_rec.bld_blk_info_type_id;
  end if;

  if (p_rec.data_set_id = hr_api.g_number) then
    p_rec.data_set_id :=
    hxc_tat_shd.g_old_rec.data_set_id;
  end if;

end convert_defs;

-- --------------------------------------------------------------------------
-- |---------------------------------< upd >--------------------------------|
-- --------------------------------------------------------------------------
procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy hxc_tat_shd.g_rec_type
  ) is

l_proc  varchar2(72) ;

begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'upd';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- we must lock the row which we need to update.

  hxc_tat_shd.lck
    (p_rec.time_attribute_id
    ,p_rec.object_version_number
    );

  -- 1. during an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. call the supporting update validate operations.

  convert_defs(p_rec);
  hxc_tat_bus.update_validate
    (p_effective_date
    ,p_rec
    );

  -- call the supporting pre-update operation

  hxc_tat_upd.pre_update(p_rec);

  -- update the row.

  hxc_tat_upd.update_dml(p_rec);

  -- call the supporting post-update operation

  hxc_tat_upd.post_update
    (p_effective_date
    ,p_rec
    );
end upd;

-- --------------------------------------------------------------------------
-- |---------------------------------< upd >--------------------------------|
-- --------------------------------------------------------------------------
procedure upd
  (p_effective_date               in     date
  ,p_time_attribute_id            in     number
  ,p_object_version_number        in out nocopy number
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
  ,p_bld_blk_info_type_id         in     varchar2  default hr_api.g_number
  ,p_data_set_id                  in     number    default hr_api.g_number
  ) is

l_rec	  hxc_tat_shd.g_rec_type;
l_proc  varchar2(72) ;

begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'upd';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call conversion function to turn arguments into the l_rec structure.

  l_rec :=
  hxc_tat_shd.convert_args
  (p_time_attribute_id
  ,p_object_version_number
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
  ,p_bld_blk_info_type_id
  ,p_data_set_id
  );

  -- having converted the arguments into the plsql record structure,
  -- we call the corresponding record business process.

  hxc_tat_upd.upd
    (p_effective_date
    ,l_rec
    );

  p_object_version_number := l_rec.object_version_number;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end upd;

end hxc_tat_upd;

/
