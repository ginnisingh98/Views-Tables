--------------------------------------------------------
--  DDL for Package Body HXC_TBB_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TBB_INS" as
/* $Header: hxctbbrhi.pkb 120.6.12010000.1 2008/07/28 11:19:46 appldev ship $ */

-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------

g_package  varchar2(33)	:= '  hxc_tbb_ins.';  -- global package name

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
  (p_rec in out nocopy hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

begin



  if g_debug then
  	l_proc := g_package||'insert_dml';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  p_rec.object_version_number := 1;  -- Initialise the object version

  -- insert the row into: hxc_time_building_blocks

  insert into hxc_time_building_blocks
    (time_building_block_id
    ,type
    ,measure
    ,unit_of_measure
    ,start_time
    ,stop_time
    ,parent_building_block_id
    ,parent_building_block_ovn
    ,scope
    ,object_version_number
    ,approval_status
    ,resource_id
    ,resource_type
    ,approval_style_id
    ,date_from
    ,date_to
    ,comment_text
    ,application_set_id
    ,data_set_id
    ,translation_display_key
    ,creation_date
    ,created_by
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    )
  values
    (p_rec.time_building_block_id
    ,p_rec.type
    ,p_rec.measure
    ,p_rec.unit_of_measure
    ,p_rec.start_time
    ,p_rec.stop_time
    ,p_rec.parent_building_block_id
    ,p_rec.parent_building_block_ovn
    ,p_rec.scope
    ,p_rec.object_version_number
    ,p_rec.approval_status
    ,p_rec.resource_id
    ,p_rec.resource_type
    ,p_rec.approval_style_id
    ,p_rec.date_from
    ,p_rec.date_to
    ,p_rec.comment_text
    ,p_rec.application_set_id
    ,p_rec.data_set_id
    ,p_rec.translation_display_key
    ,sysdate
    ,fnd_global.user_id
    ,fnd_global.user_id
    ,sysdate
    ,fnd_global.login_id
    );

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

exception
  when hr_api.check_integrity_violated then
    -- a check constraint has been violated
    hxc_tbb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  when hr_api.parent_integrity_violated then
    -- Parent integrity has been violated
    hxc_tbb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  when hr_api.unique_integrity_violated then
    -- Unique integrity has been violated
    hxc_tbb_shd.constraint_error
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
--   Processing continues.
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
  (p_rec in out nocopy hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

  cursor c_sel1 is select hxc_time_building_blocks_s.nextval from dual;

begin



  if g_debug then
  	l_proc := g_package||'pre_insert';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;


  -- select the next sequence number

  open c_sel1;
  fetch c_sel1 into p_rec.time_building_block_id;
  close c_sel1;

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
--   Processing continues.
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
  ,p_rec            in hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

begin



  if g_debug then
  	l_proc := g_package||'post_insert';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
/*
    hxc_tbb_rki.after_insert
      (p_effective_date
      => p_effective_date
      ,p_time_building_block_id
      => p_rec.time_building_block_id
      ,p_type
      => p_rec.type
      ,p_measure
      => p_rec.measure
      ,p_unit_of_measure
      => p_rec.unit_of_measure
      ,p_start_time
      => p_rec.start_time
      ,p_stop_time
      => p_rec.stop_time
      ,p_parent_building_block_id
      => p_rec.parent_building_block_id
      ,p_parent_building_block_ovn
      => p_rec.parent_building_block_ovn
      ,p_scope
      => p_rec.scope
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_approval_status
      => p_rec.approval_status
      ,p_resource_id
      => p_rec.resource_id
      ,p_resource_type
      => p_rec.resource_type
      ,p_approval_style_id
      => p_rec.approval_style_id
      ,p_date_from
      => p_rec.date_from
      ,p_date_to
      => p_rec.date_to
      ,p_comment_text
      => p_rec.comment_text
      ,p_application_set_id
      =>p_application_set_id
      );
 */null;
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_TIME_BUILDING_BLOCKS'
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
  (p_effective_date in     date
  ,p_rec            in out nocopy hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'ins';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call the supporting insert validate operations

  hxc_tbb_bus.insert_validate
    (p_effective_date
    ,p_rec
    );

  -- call the supporting pre-insert operation

  hxc_tbb_ins.pre_insert(p_rec);

  -- insert the row

  hxc_tbb_ins.insert_dml(p_rec);

  -- call the supporting post-insert operation

  hxc_tbb_ins.post_insert
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
  (p_effective_date            in     date
  ,p_type                      in     varchar2
  ,p_scope                     in     varchar2
  ,p_approval_status           in     varchar2
  ,p_measure                   in     number   default null
  ,p_unit_of_measure           in     varchar2 default null
  ,p_start_time                in     date     default null
  ,p_stop_time                 in     date     default null
  ,p_parent_building_block_id  in     number   default null
  ,p_parent_building_block_ovn in     number   default null
  ,p_resource_id               in     number   default null
  ,p_resource_type             in     varchar2 default null
  ,p_approval_style_id         in     number   default null
  ,p_date_from                 in     date     default null
  ,p_date_to                   in     date     default null
  ,p_comment_text              in     varchar2 default null
  ,p_application_set_id        in     number   default null
  ,p_data_set_id               in     number   default null
  ,p_translation_display_key   in     varchar2 default null
  ,p_time_building_block_id       out nocopy number
  ,p_object_version_number        out nocopy number
  ) is

  l_rec	  hxc_tbb_shd.g_rec_type;
  l_proc  varchar2(72);

begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'ins';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call conversion function to turn arguments into the
  -- p_rec structure.

  l_rec :=
  hxc_tbb_shd.convert_args
    (null
    ,p_type
    ,p_measure
    ,p_unit_of_measure
    ,p_start_time
    ,p_stop_time
    ,p_parent_building_block_id
    ,p_parent_building_block_ovn
    ,p_scope
    ,null
    ,p_approval_status
    ,p_resource_id
    ,p_resource_type
    ,p_approval_style_id
    ,p_date_from
    ,p_date_to
    ,p_comment_text
    ,p_application_set_id
    ,p_data_set_id
    ,p_translation_display_key
    );

  -- having converted the arguments into the hxc_tbb_rec
  -- plsql record structure we call the corresponding record business process.

  hxc_tbb_ins.ins
     (p_effective_date
     ,l_rec
     );

  -- as the primary key argument is specified as an out,
  -- we must set this value

  p_time_building_block_id := l_rec.time_building_block_id;
  p_object_version_number := l_rec.object_version_number;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end ins;

end hxc_tbb_ins;

/
