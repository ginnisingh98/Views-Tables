--------------------------------------------------------
--  DDL for Package Body HXC_ULQ_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ULQ_INS" as
/* $Header: hxculqrhi.pkb 120.2 2005/09/23 06:26:40 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ulq_ins.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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
  (p_rec in out nocopy hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
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
  -- Insert the row into: hxc_layout_comp_qualifiers
  --
  insert into hxc_layout_comp_qualifiers
      (layout_comp_qualifier_id
      ,layout_component_id
      ,qualifier_name
      ,qualifier_attribute_category
      ,qualifier_attribute1
      ,qualifier_attribute2
      ,qualifier_attribute3
      ,qualifier_attribute4
      ,qualifier_attribute5
      ,qualifier_attribute6
      ,qualifier_attribute7
      ,qualifier_attribute8
      ,qualifier_attribute9
      ,qualifier_attribute10
      ,qualifier_attribute11
      ,qualifier_attribute12
      ,qualifier_attribute13
      ,qualifier_attribute14
      ,qualifier_attribute15
      ,qualifier_attribute16
      ,qualifier_attribute17
      ,qualifier_attribute18
      ,qualifier_attribute19
      ,qualifier_attribute20
      ,qualifier_attribute21
      ,qualifier_attribute22
      ,qualifier_attribute23
      ,qualifier_attribute24
      ,qualifier_attribute25
      ,qualifier_attribute26
      ,qualifier_attribute27
      ,qualifier_attribute28
      ,qualifier_attribute29
      ,qualifier_attribute30
      ,object_version_number
      ,creation_date
,created_by
,last_updated_by
,last_update_date
,last_update_login
      )
  Values
    (p_rec.layout_comp_qualifier_id
    ,p_rec.layout_component_id
    ,p_rec.qualifier_name
    ,p_rec.qualifier_attribute_category
    ,p_rec.qualifier_attribute1
    ,p_rec.qualifier_attribute2
    ,p_rec.qualifier_attribute3
    ,p_rec.qualifier_attribute4
    ,p_rec.qualifier_attribute5
    ,p_rec.qualifier_attribute6
    ,p_rec.qualifier_attribute7
    ,p_rec.qualifier_attribute8
    ,p_rec.qualifier_attribute9
    ,p_rec.qualifier_attribute10
    ,p_rec.qualifier_attribute11
    ,p_rec.qualifier_attribute12
    ,p_rec.qualifier_attribute13
    ,p_rec.qualifier_attribute14
    ,p_rec.qualifier_attribute15
    ,p_rec.qualifier_attribute16
    ,p_rec.qualifier_attribute17
    ,p_rec.qualifier_attribute18
    ,p_rec.qualifier_attribute19
    ,p_rec.qualifier_attribute20
    ,p_rec.qualifier_attribute21
    ,p_rec.qualifier_attribute22
    ,p_rec.qualifier_attribute23
    ,p_rec.qualifier_attribute24
    ,p_rec.qualifier_attribute25
    ,p_rec.qualifier_attribute26
    ,p_rec.qualifier_attribute27
    ,p_rec.qualifier_attribute28
    ,p_rec.qualifier_attribute29
    ,p_rec.qualifier_attribute30
    ,p_rec.object_version_number
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
  (p_rec  in out nocopy hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
  Cursor C_Sel1 is select hxc_layout_comp_qualifiers_s.nextval from sys.dual;
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
  Fetch C_Sel1 Into p_rec.layout_comp_qualifier_id;
  Close C_Sel1;
  --
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
  (p_rec                          in hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin

  if g_debug then
  	l_proc := g_package||'post_insert';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    hxc_ulq_rki.after_insert
      (p_layout_comp_qualifier_id
      => p_rec.layout_comp_qualifier_id
      ,p_layout_component_id
      => p_rec.layout_component_id
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
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_LAYOUT_COMP_QUALIFIERS'
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
  (p_rec                          in out nocopy hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'ins';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call the supporting insert validate operations
  --
  hxc_ulq_bus.insert_validate
     (p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  hxc_ulq_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  hxc_ulq_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  hxc_ulq_ins.post_insert
     (p_rec
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
  (p_layout_component_id            in     number
  ,p_qualifier_name                 in     varchar2
  ,p_qualifier_attribute_category   in     varchar2 default null
  ,p_qualifier_attribute1           in     varchar2 default null
  ,p_qualifier_attribute2           in     varchar2 default null
  ,p_qualifier_attribute3           in     varchar2 default null
  ,p_qualifier_attribute4           in     varchar2 default null
  ,p_qualifier_attribute5           in     varchar2 default null
  ,p_qualifier_attribute6           in     varchar2 default null
  ,p_qualifier_attribute7           in     varchar2 default null
  ,p_qualifier_attribute8           in     varchar2 default null
  ,p_qualifier_attribute9           in     varchar2 default null
  ,p_qualifier_attribute10          in     varchar2 default null
  ,p_qualifier_attribute11          in     varchar2 default null
  ,p_qualifier_attribute12          in     varchar2 default null
  ,p_qualifier_attribute13          in     varchar2 default null
  ,p_qualifier_attribute14          in     varchar2 default null
  ,p_qualifier_attribute15          in     varchar2 default null
  ,p_qualifier_attribute16          in     varchar2 default null
  ,p_qualifier_attribute17          in     varchar2 default null
  ,p_qualifier_attribute18          in     varchar2 default null
  ,p_qualifier_attribute19          in     varchar2 default null
  ,p_qualifier_attribute20          in     varchar2 default null
  ,p_qualifier_attribute21          in     varchar2 default null
  ,p_qualifier_attribute22          in     varchar2 default null
  ,p_qualifier_attribute23          in     varchar2 default null
  ,p_qualifier_attribute24          in     varchar2 default null
  ,p_qualifier_attribute25          in     varchar2 default null
  ,p_qualifier_attribute26          in     varchar2 default null
  ,p_qualifier_attribute27          in     varchar2 default null
  ,p_qualifier_attribute28          in     varchar2 default null
  ,p_qualifier_attribute29          in     varchar2 default null
  ,p_qualifier_attribute30          in     varchar2 default null
  ,p_layout_comp_qualifier_id          out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec	  hxc_ulq_shd.g_rec_type;
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'ins';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hxc_ulq_shd.convert_args
    (null
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
    ,null
    );
  --
  -- Having converted the arguments into the hxc_ulq_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hxc_ulq_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_layout_comp_qualifier_id := l_rec.layout_comp_qualifier_id;
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End ins;
--
end hxc_ulq_ins;

/
