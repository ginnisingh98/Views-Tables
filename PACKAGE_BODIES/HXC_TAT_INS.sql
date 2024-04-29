--------------------------------------------------------
--  DDL for Package Body HXC_TAT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TAT_INS" as
/* $Header: hxtatrhi.pkb 120.2 2005/09/23 07:03:57 rchennur noship $ */
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
g_package  varchar2(33)	:= '  hxc_tat_ins.';  -- global package name
g_debug boolean := hr_utility.debug_enabled;
-- --------------------------------------------------------------------------
-- |------------------------------< insert_dml >----------------------------|
-- --------------------------------------------------------------------------
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
--   if a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   if any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure insert_dml
  (p_rec in out nocopy hxc_tat_shd.g_rec_type
  ) is

l_proc  varchar2(72) ;

begin

  if g_debug then
  	l_proc := g_package||'insert_dml';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  p_rec.object_version_number := 1;  -- initialise the object version

  -- insert the row into: hxc_time_attributes

  insert into hxc_time_attributes
    (time_attribute_id
    ,object_version_number
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,attribute16
    ,attribute17
    ,attribute18
    ,attribute19
    ,attribute20
    ,attribute21
    ,attribute22
    ,attribute23
    ,attribute24
    ,attribute25
    ,attribute26
    ,attribute27
    ,attribute28
    ,attribute29
    ,attribute30
    ,bld_blk_info_type_id
    ,data_set_id
    )
  values
    (hxc_time_attributes_s.nextval         --Fix for Bug#3062133
    ,p_rec.object_version_number
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.attribute21
    ,p_rec.attribute22
    ,p_rec.attribute23
    ,p_rec.attribute24
    ,p_rec.attribute25
    ,p_rec.attribute26
    ,p_rec.attribute27
    ,p_rec.attribute28
    ,p_rec.attribute29
    ,p_rec.attribute30
    ,p_rec.bld_blk_info_type_id
    ,p_rec.data_set_id
    )
    returning time_attribute_id into p_rec.time_attribute_id;  --Fix for Bug#3062133

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
  when hr_api.unique_integrity_violated Then
    hxc_tat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  when others then
    raise;

end insert_dml;

-- --------------------------------------------------------------------------
-- |------------------------------< pre_insert >----------------------------|
-- --------------------------------------------------------------------------
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
--   processing continues.
--
-- Post Failure:
--   if an error has occurred, an error message and exception will be raised
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
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure pre_insert
  (p_rec  in out nocopy hxc_tat_shd.g_rec_type
  ) is

l_proc  varchar2(72) ;
--cursor c_sel1 is select hxc_time_attributes_s.nextval from dual;  --Fix for Bug#3062133

begin

  if g_debug then
  	l_proc := g_package||'pre_insert';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

 -- Fix for Bug#3062133 starts

  --open c_sel1;
  --  fetch c_sel1 into p_rec.time_attribute_id;
  --close c_Sel1;

-- Fix for Bug#3062133 ends

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end pre_insert;

-- --------------------------------------------------------------------------
-- |-----------------------------< post_insert >----------------------------|
-- --------------------------------------------------------------------------
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
--   processing continues.
--
-- Post Failure:
--   if an error has occurred, an error message and exception will be raised
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
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure post_insert
  (p_effective_date in date
  ,p_rec            in hxc_tat_shd.g_rec_type
  ) is

l_proc  varchar2(72) ;

begin

  if g_debug then
  	l_proc := g_package||'post_insert';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  begin
/*
    hxc_tat_rki.after_insert
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
      );
*/null;
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_TIME_ATTRIBUTES'
        ,p_hook_type   => 'AI');

  end;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end post_insert;

-- --------------------------------------------------------------------------
-- |---------------------------------< ins >--------------------------------|
-- --------------------------------------------------------------------------
procedure ins
  (p_effective_date in date
  ,p_rec            in out nocopy hxc_tat_shd.g_rec_type
  ) is

l_proc  varchar2(72) ;

begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'ins';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call the supporting insert validate operations

  hxc_tat_bus.insert_validate
    (p_effective_date
    ,p_rec
    );

  -- call the supporting pre-insert operation

  hxc_tat_ins.pre_insert(p_rec);

  -- insert the row

  hxc_tat_ins.insert_dml(p_rec);

  -- call the supporting post-insert operation

  hxc_tat_ins.post_insert
    (p_effective_date
    ,p_rec
    );

  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;

end ins;

-- --------------------------------------------------------------------------
-- |---------------------------------< ins >--------------------------------|
-- --------------------------------------------------------------------------
procedure ins
  (p_effective_date                 in     date
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_bld_blk_info_type_id           in     number   default null
  ,p_data_set_id                    in     number   default null
  ,p_time_attribute_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ) is

l_rec	  hxc_tat_shd.g_rec_type;
l_proc  varchar2(72) ;

begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'ins';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call conversion function to turn arguments into the p_rec structure.

  l_rec :=
  hxc_tat_shd.convert_args
    (null
    ,null
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

  -- having converted the arguments into the hxc_tat_rec
  -- plsql record structure we call the corresponding record business process.

  hxc_tat_ins.ins
    (p_effective_date
    ,l_rec
    );

  -- as the primary key argument(s) are specified as an out we must set
  -- these values.

  p_time_attribute_id := l_rec.time_attribute_id;
  p_object_version_number := l_rec.object_version_number;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end ins;

end hxc_tat_ins;

/
