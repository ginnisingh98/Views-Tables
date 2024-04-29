--------------------------------------------------------
--  DDL for Package Body PER_OSV_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_OSV_INS" as
/* $Header: peosvrhi.pkb 120.0 2005/05/31 12:37:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_osv_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_org_structure_version_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_org_structure_version_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_osv_ins.g_org_structure_version_id_i := p_org_structure_version_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
  (p_rec in out nocopy per_osv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_osv_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_org_structure_versions
  --
  insert into per_org_structure_versions
      (org_structure_version_id
      ,business_group_id
      ,organization_structure_id
      ,date_from
      ,version_number
      ,copy_structure_version_id
      ,date_to
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,object_version_number
      ,topnode_pos_ctrl_enabled_flag
      )
  Values
    (p_rec.org_structure_version_id
    ,p_rec.business_group_id
    ,p_rec.organization_structure_id
    ,p_rec.date_from
    ,p_rec.version_number
    ,p_rec.copy_structure_version_id
    ,p_rec.date_to
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    ,p_rec.object_version_number
    ,p_rec.topnode_pos_ctrl_enabled_flag
    );
  --
  per_osv_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_osv_shd.g_api_dml := false;   -- Unset the api dml status
    per_osv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_osv_shd.g_api_dml := false;   -- Unset the api dml status
    per_osv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_osv_shd.g_api_dml := false;   -- Unset the api dml status
    per_osv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_osv_shd.g_api_dml := false;   -- Unset the api dml status
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec  in out nocopy per_osv_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select per_org_structure_versions_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from per_org_structure_versions
     where org_structure_version_id =
             per_osv_ins.g_org_structure_version_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (per_osv_ins.g_org_structure_version_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','per_org_structure_versions');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.org_structure_version_id :=
      per_osv_ins.g_org_structure_version_id_i;
    per_osv_ins.g_org_structure_version_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.org_structure_version_id;
    Close C_Sel1;

  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_effective_date               in date
  ,p_rec                          in per_osv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_osv_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_org_structure_version_id
      => p_rec.org_structure_version_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_organization_structure_id
      => p_rec.organization_structure_id
      ,p_date_from
      => p_rec.date_from
      ,p_version_number
      => p_rec.version_number
      ,p_copy_structure_version_id
      => p_rec.copy_structure_version_id
      ,p_date_to
      => p_rec.date_to
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_topnode_pos_ctrl_enabled_fla
      => p_rec.topnode_pos_ctrl_enabled_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ORG_STRUCTURE_VERSIONS'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_osv_shd.g_rec_type
  ,p_gap_warning                     out nocopy boolean
) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_osv_bus.insert_validate
     (p_effective_date
     ,p_rec
     ,p_gap_warning);
  --
  -- Call the supporting pre-insert operation
  --
  per_osv_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_osv_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_osv_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date
  ,p_organization_structure_id      in     number
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number   default null
  ,p_date_to                        in     date     default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_topnode_pos_ctrl_enabled_fla   in     varchar2 default null
  ,p_org_structure_version_id          out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_gap_warning                       out nocopy boolean) is
--
  l_rec   per_osv_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
  l_business_group_id number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --

per_osv_bus.get_business_group_id
  (p_organization_structure_id      =>  p_organization_structure_id
  ,p_business_group_id              =>  l_business_group_id);

  l_rec :=
  per_osv_shd.convert_args
    (null
    ,l_business_group_id
    ,p_organization_structure_id
    ,p_date_from
    ,p_version_number
    ,p_copy_structure_version_id
    ,p_date_to
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,null
    ,p_topnode_pos_ctrl_enabled_fla
    );
  --
  -- Having converted the arguments into the per_osv_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_osv_ins.ins
     (p_effective_date
     ,l_rec
     ,p_gap_warning
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_org_structure_version_id := l_rec.org_structure_version_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_osv_ins;

/