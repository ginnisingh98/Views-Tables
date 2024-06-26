--------------------------------------------------------
--  DDL for Package Body PSP_PSO_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PSO_INS" as
/* $Header: PSPSORHB.pls 120.2 2005/11/28 23:27 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_pso_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_salary_cap_override_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_salary_cap_override_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  psp_pso_ins.g_salary_cap_override_id_i := p_salary_cap_override_id;
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
  (p_rec in out nocopy psp_pso_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: psp_salary_cap_overrides
  --
  insert into psp_salary_cap_overrides
      (salary_cap_override_id
      ,funding_source_code
      ,project_id
      ,start_date
      ,end_date
      ,currency_code
      ,annual_salary_cap
      ,object_version_number
      )
  Values
    (p_rec.salary_cap_override_id
    ,p_rec.funding_source_code
    ,p_rec.project_id
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.currency_code
    ,p_rec.annual_salary_cap
    ,p_rec.object_version_number
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    psp_pso_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    psp_pso_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    psp_pso_shd.constraint_error
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
  (p_rec  in out nocopy psp_pso_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select psp_salary_cap_overrides_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from psp_salary_cap_overrides
     where salary_cap_override_id =
             psp_pso_ins.g_salary_cap_override_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (psp_pso_ins.g_salary_cap_override_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','psp_salary_cap_overrides');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.salary_cap_override_id :=
      psp_pso_ins.g_salary_cap_override_id_i;
    psp_pso_ins.g_salary_cap_override_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.salary_cap_override_id;
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
  (p_rec                          in psp_pso_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    psp_pso_rki.after_insert
      (p_salary_cap_override_id
      => p_rec.salary_cap_override_id
      ,p_funding_source_code
      => p_rec.funding_source_code
      ,p_project_id
      => p_rec.project_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_currency_code
      => p_rec.currency_code
      ,p_annual_salary_cap
      => p_rec.annual_salary_cap
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PSP_SALARY_CAP_OVERRIDES'
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
  (p_rec                          in out nocopy psp_pso_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  psp_pso_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  psp_pso_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  psp_pso_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  psp_pso_ins.post_insert
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_funding_source_code            in     varchar2
  ,p_project_id                     in     number
  ,p_start_date                     in     date
  ,p_currency_code                  in     varchar2
  ,p_annual_salary_cap              in     number
  ,p_end_date                       in     date     default null
  ,p_salary_cap_override_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   psp_pso_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  psp_pso_shd.convert_args
    (null
    ,p_funding_source_code
    ,p_project_id
    ,p_start_date
    ,p_end_date
    ,p_currency_code
    ,p_annual_salary_cap
    ,null
    );
  --
  -- Having converted the arguments into the psp_pso_rec
  -- plsql record structure we call the corresponding record business process.
  --
  psp_pso_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_salary_cap_override_id := l_rec.salary_cap_override_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end psp_pso_ins;

/
