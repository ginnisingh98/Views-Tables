--------------------------------------------------------
--  DDL for Package Body HXC_HTR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HTR_INS" as
/* $Header: hxchtrrhi.pkb 120.2 2005/09/23 07:45:11 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_htr_ins.';  -- Global package name

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
  (p_rec in out nocopy hxc_htr_shd.g_rec_type
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
  hxc_htr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: hxc_time_recipients
  --
  insert into hxc_time_recipients
      (time_recipient_id
      ,name
      ,application_id
      ,object_version_number
      ,application_retrieval_function
      ,application_update_process
      ,appl_validation_process
      ,application_period_function
      ,appl_dynamic_template_process
      ,extension_function1
      ,extension_function2
      ,creation_date
,created_by
,last_updated_by
,last_update_date
,last_update_login
      )
  Values
    (p_rec.time_recipient_id
    ,p_rec.name
    ,p_rec.application_id
    ,p_rec.object_version_number
    ,p_rec.application_retrieval_function
    ,p_rec.application_update_process
    ,p_rec.appl_validation_process
    ,p_rec.application_period_function
    ,p_rec.appl_dynamic_template_process
    ,p_rec.extension_function1
    ,p_rec.extension_function2
     ,sysdate
 ,fnd_global.user_id
 ,fnd_global.user_id
 ,sysdate
 ,fnd_global.login_id
    );
  --
  hxc_htr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hxc_htr_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_htr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    hxc_htr_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_htr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hxc_htr_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_htr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hxc_htr_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy hxc_htr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
  Cursor C_Sel1 is select hxc_time_recipients_s.nextval from sys.dual;
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
  Fetch C_Sel1 Into p_rec.time_recipient_id;
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
  ,p_rec                          in hxc_htr_shd.g_rec_type
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
    hxc_htr_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_time_recipient_id
      => p_rec.time_recipient_id
      ,p_name
      => p_rec.name
      ,p_application_id
      => p_rec.application_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_appl_retrieval_function
      => p_rec.application_retrieval_function
      ,p_appl_update_process
      => p_rec.application_update_process
      ,p_appl_validation_process
      => p_rec.appl_validation_process
      ,p_appl_period_function
      => p_rec.application_period_function
      ,p_appl_dyn_template_process
      => p_rec.appl_dynamic_template_process
      ,p_extension_function1
      => p_rec.extension_function1
      ,p_extension_function2
      => p_rec.extension_function2
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_TIME_RECIPIENTS'
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
  ,p_rec                          in out nocopy hxc_htr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'ins';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call the supporting insert validate operations
  --
  hxc_htr_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  hxc_htr_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  hxc_htr_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  hxc_htr_ins.post_insert
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
  (p_effective_date                 in     date
  ,p_name                           in     varchar2
  ,p_appl_retrieval_function        in     varchar2 default NULL
  ,p_appl_update_process            in     varchar2 default NULL
  ,p_appl_validation_process        in     varchar2 default NULL
  ,p_appl_period_function           in     varchar2 default NULL
  ,p_appl_dyn_template_process      in     varchar2 default NULL
  ,p_extension_function1            in     varchar2 default NULL
  ,p_extension_function2            in     varchar2 default NULL
  ,p_application_id                 in     number   default null
  ,p_time_recipient_id              out nocopy number
  ,p_object_version_number          out nocopy number
  ) is
--
  l_rec	  hxc_htr_shd.g_rec_type;
  l_proc  varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'ins';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hxc_htr_shd.convert_args
    (null
    ,p_name
    ,p_appl_retrieval_function
    ,p_appl_update_process
    ,p_appl_validation_process
    ,p_appl_period_function
    ,p_appl_dyn_template_process
    ,p_extension_function1
    ,p_extension_function2
    ,p_application_id
    ,null
    );
  --
  -- Having converted the arguments into the hxc_htr_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hxc_htr_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_time_recipient_id := l_rec.time_recipient_id;
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End ins;
--
end hxc_htr_ins;

/
