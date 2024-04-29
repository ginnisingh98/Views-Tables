--------------------------------------------------------
--  DDL for Package Body HXC_HAC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAC_INS" as
/* $Header: hxchacrhi.pkb 120.4 2006/06/13 08:42:23 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_hac_ins.';  -- Global package name
g_debug    boolean		:= hr_utility.debug_enabled;
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
  (p_rec in out nocopy hxc_hac_shd.g_rec_type
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
  hxc_hac_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: hxc_approval_comps
  --
  insert into hxc_approval_comps
      (approval_comp_id
      ,approval_style_id
      ,time_recipient_id
      ,approval_mechanism
      ,approval_mechanism_id
      ,wf_item_type
      ,wf_name
      ,start_date
      ,end_date
      ,object_version_number
      ,approval_order
      ,time_category_id
      ,parent_comp_id
      ,parent_comp_ovn
      ,run_recipient_extensions
      ,creation_date
,created_by
,last_updated_by
,last_update_date
,last_update_login
      )
  Values
    (p_rec.approval_comp_id
    ,p_rec.approval_style_id
    ,p_rec.time_recipient_id
    ,p_rec.approval_mechanism
    ,p_rec.approval_mechanism_id
    ,p_rec.wf_item_type
    ,p_rec.wf_name
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.object_version_number
    ,p_rec.approval_order
    ,p_rec.time_category_id
	,p_rec.parent_comp_id
    ,p_rec.parent_comp_ovn
    ,p_rec.run_recipient_extensions
     ,sysdate
 ,fnd_global.user_id
 ,fnd_global.user_id
 ,sysdate
 ,fnd_global.login_id
    );
  --
  hxc_hac_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hxc_hac_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_hac_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    hxc_hac_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_hac_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hxc_hac_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_hac_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hxc_hac_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy hxc_hac_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
  Cursor C_Sel1 is select hxc_approval_comps_s.nextval from sys.dual;
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
  Fetch C_Sel1 Into p_rec.approval_comp_id;
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
  (p_effective_date               in date
  ,p_rec                          in hxc_hac_shd.g_rec_type
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








   hxc_hac_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_approval_comp_id
      => p_rec.approval_comp_id
      ,p_approval_style_id
      => p_rec.approval_style_id
      ,p_time_recipient_id
      => p_rec.time_recipient_id
      ,p_approval_mechanism
      => p_rec.approval_mechanism
      ,p_approval_mechanism_id
      => p_rec.approval_mechanism_id
      ,p_wf_item_type
      => p_rec.wf_item_type
      ,p_wf_name
      => p_rec.wf_name
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_approval_order
      => p_rec.approval_order
      ,p_time_category_id
      => p_rec.time_category_id
      ,p_parent_comp_id
      => p_rec.parent_comp_id
      ,p_parent_comp_ovn
      => p_rec.parent_comp_ovn
      ,p_run_recipient_extensions =>p_rec.run_recipient_extensions
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_APPROVAL_COMPS'
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
  ,p_rec                          in out nocopy hxc_hac_shd.g_rec_type
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
  hxc_hac_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  hxc_hac_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  hxc_hac_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  hxc_hac_ins.post_insert
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
  ,p_approval_style_id              in     number
  ,p_time_recipient_id              in     number
  ,p_approval_mechanism             in     varchar2
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  ,p_approval_mechanism_id          in     number   default null
  ,p_wf_item_type                   in     varchar2 default null
  ,p_wf_name                        in     varchar2 default null
  ,p_approval_order                 in     number   default null
  ,p_approval_comp_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_time_category_id              in     number   default null
  ,p_parent_comp_id                in     number   default null
  ,p_parent_comp_ovn               in     number   default null
  ,p_run_recipient_extensions      in     varchar2 default null
   ) is
--
  l_rec	  hxc_hac_shd.g_rec_type;
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
  hxc_hac_shd.convert_args
    (null
    ,p_approval_style_id
    ,p_time_recipient_id
    ,p_approval_mechanism
    ,p_approval_mechanism_id
    ,p_wf_item_type
    ,p_wf_name
    ,p_start_date
    ,p_end_date
    ,null
    ,p_approval_order
    ,p_time_category_id
    ,p_parent_comp_id
    ,p_parent_comp_ovn
    ,p_run_recipient_extensions
   );
  --
  -- Having converted the arguments into the hxc_hac_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hxc_hac_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_approval_comp_id := l_rec.approval_comp_id;
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End ins;
--
end hxc_hac_ins;

/
