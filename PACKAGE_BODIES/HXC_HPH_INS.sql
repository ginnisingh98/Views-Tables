--------------------------------------------------------
--  DDL for Package Body HXC_HPH_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HPH_INS" as
/* $Header: hxchphrhi.pkb 120.2.12000000.2 2007/03/16 13:22:54 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_hph_ins.';  -- Global package name
g_debug	   boolean	:= hr_utility.debug_enabled;
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
  (p_rec in out nocopy hxc_hph_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
	  l_proc := g_package||'insert_dml';
	  hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: hxc_pref_hierarchies
  --
  insert into hxc_pref_hierarchies
      (pref_hierarchy_id
      ,type
      ,name
      ,business_group_id
      ,legislation_code
      ,parent_pref_hierarchy_id
      ,edit_allowed
      ,displayed
      ,pref_definition_id
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
      ,object_version_number
      ,orig_pref_hierarchy_id
      ,orig_parent_hierarchy_id
      ,top_level_parent_id         --Performance Fix
      ,code
      ,creation_date
,created_by
,last_updated_by
,last_update_date
,last_update_login
      )
  Values
    (p_rec.pref_hierarchy_id
    ,p_rec.type
    ,p_rec.name
    ,p_rec.business_group_id
    ,p_rec.legislation_code
    ,p_rec.parent_pref_hierarchy_id
    ,p_rec.edit_allowed
    ,p_rec.displayed
    ,p_rec.pref_definition_id
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
    ,p_rec.object_version_number
    ,p_rec.orig_pref_hierarchy_id
    ,p_rec.orig_parent_hierarchy_id
    ,p_rec.top_level_parent_id   --Performance Fix
    ,p_rec.code
     ,sysdate
 ,fnd_global.user_id
 ,fnd_global.user_id
 ,sysdate
 ,fnd_global.login_id
    );
  --
  --
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  (p_rec  in out nocopy hxc_hph_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
  Cursor C_Sel1 is select hxc_pref_hierarchies_s.nextval from sys.dual;
  cursor c_top_level_node(p_pref_hierarchy_id number)
  is
          select  pref_hierarchy_id
            from  hxc_pref_hierarchies
	   where parent_pref_hierarchy_id is null
           connect by prior parent_pref_hierarchy_id = pref_hierarchy_id
           start with pref_hierarchy_id = p_pref_hierarchy_id;

  Cursor c_code(p_pref_definition_id number)
  is
          select hpd.code
          from   hxc_pref_definitions hpd
          where  pref_definition_id = p_pref_definition_id;

l_top_node_id number := p_rec.parent_pref_hierarchy_id;
l_node_id     number;
l_code        varchar2(30);
--
Begin
  if g_debug then
	l_proc := g_package||'pre_insert';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pref_hierarchy_id;
  Close C_Sel1;

--Performance Fix
  if (p_rec.pref_definition_id is not null) then
  -- Get the top level parent ID
     open c_top_level_node(l_top_node_id);
         fetch c_top_level_node into l_top_node_id;
     close c_top_level_node;
     p_rec.top_level_parent_id := l_top_node_id;
  -- Get the code for the node
     open c_code(p_rec.pref_definition_id);
     fetch c_code into l_code;
        p_rec.code := l_code;
     close c_code;
  --
   else
     p_rec.top_level_parent_id := null;
     p_rec.code := null;
   end if;
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
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
  ,p_rec                          in hxc_hph_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
	l_proc := g_package||'post_insert';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    hxc_hph_rki.after_insert
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
      ,p_top_level_parent_id  --Performance Fix
      =>p_rec.top_level_parent_id
      ,p_code
      => p_rec.code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_PREF_HIERARCHIES'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy hxc_hph_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'ins';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call the supporting insert validate operations
  --
  hxc_hph_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  hxc_hph_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  hxc_hph_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  hxc_hph_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  if g_debug then
	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date
  ,p_name                           in     varchar2
  ,p_business_group_id		    in     number   default null
  ,p_legislation_code		    in     varchar2 default null
  ,p_edit_allowed                   in     varchar2
  ,p_displayed                      in     varchar2
  ,p_type                           in     varchar2 default null
  ,p_parent_pref_hierarchy_id       in     number   default null
  ,p_pref_definition_id             in     number   default null
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
  ,p_orig_pref_hierarchy_id         in     number   default null
  ,p_orig_parent_hierarchy_id       in     number   default null
  ,p_pref_hierarchy_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_top_level_parent_id            in     number   default null--Performance Fix
  ,p_code                           in     varchar2 default null
  ) is
--
  l_rec	  hxc_hph_shd.g_rec_type;
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'ins';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hxc_hph_shd.convert_args
    (null
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
    ,null
    ,p_orig_pref_hierarchy_id
    ,p_orig_parent_hierarchy_id
    ,p_top_level_parent_id        --Performance Fix
    ,p_code
    );
  --
  -- Having converted the arguments into the hxc_hph_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hxc_hph_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pref_hierarchy_id := l_rec.pref_hierarchy_id;
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End ins;
--
end hxc_hph_ins;

/
