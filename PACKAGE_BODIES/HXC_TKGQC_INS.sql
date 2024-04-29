--------------------------------------------------------
--  DDL for Package Body HXC_TKGQC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TKGQC_INS" as
/* $Header: hxctkgqcrhi.pkb 120.2 2005/09/23 05:26:07 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_tkgqc_ins.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_tk_group_query_criteria_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_tk_group_query_criteria_id  in  number) is
--
  l_proc       varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'set_base_key_value';

	hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  hxc_tkgqc_ins.g_tk_group_query_criteria_id_i := p_tk_group_query_criteria_id;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;
End set_base_key_value;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec in out nocopy hxc_tkgqc_shd.g_rec_type
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
  hxc_tkgqc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: hxc_tk_group_query_criteria
  --
  insert into hxc_tk_group_query_criteria
      (tk_group_query_criteria_id
      ,tk_group_query_id
      ,criteria_type
      ,criteria_id
      ,object_version_number
      ,creation_date
,created_by
,last_updated_by
,last_update_date
,last_update_login
      )
  Values
    (p_rec.tk_group_query_criteria_id
    ,p_rec.tk_group_query_id
    ,p_rec.criteria_type
    ,p_rec.criteria_id
    ,p_rec.object_version_number
     ,sysdate
 ,fnd_global.user_id
 ,fnd_global.user_id
 ,sysdate
 ,fnd_global.login_id
    );
  --
  hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_tkgqc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_tkgqc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_tkgqc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec  in out nocopy hxc_tkgqc_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select hxc_tk_group_query_criteria_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from hxc_tk_group_query_criteria
     where tk_group_query_criteria_id =
             hxc_tkgqc_ins.g_tk_group_query_criteria_id_i;
--
  l_proc   varchar2(72) ;
  l_exists varchar2(1);
--
Begin

  if g_debug then
	l_proc := g_package||'pre_insert';

	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  If (hxc_tkgqc_ins.g_tk_group_query_criteria_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','hxc_tk_group_query_criteria');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.tk_group_query_criteria_id :=
      hxc_tkgqc_ins.g_tk_group_query_criteria_id_i;
    hxc_tkgqc_ins.g_tk_group_query_criteria_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.tk_group_query_criteria_id;
    Close C_Sel1;
  End If;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This private procedure contains any processing which is required after
--   the insert dml.
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
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_rec                          in hxc_tkgqc_shd.g_rec_type
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
    hxc_tkgqc_rki.after_insert
      (p_tk_group_query_criteria_id
      => p_rec.tk_group_query_criteria_id
      ,p_tk_group_query_id
      => p_rec.tk_group_query_id
      ,p_criteria_type
      => p_rec.criteria_type
      ,p_criteria_id
      => p_rec.criteria_id
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_TK_GROUP_QUERY_CRITERIA'
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
  (p_rec                          in out nocopy hxc_tkgqc_shd.g_rec_type
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
  hxc_tkgqc_bus.insert_validate
     (p_rec
     );
  --
  --
  -- Call the supporting pre-insert operation
  --
  hxc_tkgqc_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  hxc_tkgqc_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  hxc_tkgqc_ins.post_insert
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
  (p_tk_group_query_id              in     number
  ,p_criteria_type                  in     varchar2
  ,p_criteria_id                    in     number
  ,p_tk_group_query_criteria_id        out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   hxc_tkgqc_shd.g_rec_type;
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
  hxc_tkgqc_shd.convert_args
    (null
    ,p_tk_group_query_id
    ,p_criteria_type
    ,p_criteria_id
    ,null
    );
  --
  -- Having converted the arguments into the hxc_tkgqc_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hxc_tkgqc_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_tk_group_query_criteria_id := l_rec.tk_group_query_criteria_id;
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End ins;
--
end hxc_tkgqc_ins;

/
