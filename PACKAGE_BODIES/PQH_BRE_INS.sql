--------------------------------------------------------
--  DDL for Package Body PQH_BRE_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BRE_INS" as
/* $Header: pqbrerhi.pkb 115.6 2003/06/04 08:19:51 ggnanagu noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_bre_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_reallocation_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_reallocation_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pqh_bre_ins.g_reallocation_id_i := p_reallocation_id;
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
  (p_rec in out nocopy  pqh_bre_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pqh_bre_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pqh_bdgt_pool_realloctions
  --
  insert into pqh_bdgt_pool_realloctions
      (reallocation_id
      ,position_id
      ,pool_id
      ,reallocation_amt
      ,reserved_amt
      ,object_version_number
      ,txn_detail_id
      ,transaction_type
      ,budget_detail_id
      ,budget_period_id
      ,entity_id
      ,start_date
      ,end_date
      )
  Values
    (p_rec.reallocation_id
    ,p_rec.position_id
    ,p_rec.pool_id
    ,p_rec.reallocation_amt
    ,p_rec.reserved_amt
    ,p_rec.object_version_number
    ,p_rec.txn_detail_id
    ,p_rec.transaction_type
    ,p_rec.budget_detail_id
    ,p_rec.budget_period_id
    ,p_rec.entity_id
    ,p_rec.start_date
    ,p_rec.end_date
    );
  --
  pqh_bre_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_bre_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_bre_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_bre_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_bre_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_bre_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_bre_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqh_bre_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy pqh_bre_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select pqh_bdgt_pool_realloctions_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from pqh_bdgt_pool_realloctions
     where reallocation_id =
             pqh_bre_ins.g_reallocation_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (pqh_bre_ins.g_reallocation_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','pqh_bdgt_pool_realloctions');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.reallocation_id :=
      pqh_bre_ins.g_reallocation_id_i;
    pqh_bre_ins.g_reallocation_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.reallocation_id;
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
  ,p_rec                          in pqh_bre_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_bre_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_reallocation_id
      => p_rec.reallocation_id
      ,p_position_id
      => p_rec.position_id
      ,p_pool_id
      => p_rec.pool_id
      ,p_reallocation_amt
      => p_rec.reallocation_amt
      ,p_reserved_amt
      => p_rec.reserved_amt
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_txn_detail_id
      => p_rec.txn_detail_id
      ,p_transaction_type
      => p_rec.transaction_type
      ,p_budget_detail_id
      => p_rec.budget_detail_id
      ,p_budget_period_id
      => p_rec.budget_period_id
      ,p_entity_id
      => p_rec.entity_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_BDGT_POOL_REALLOCTIONS'
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
  ,p_rec                          in out nocopy pqh_bre_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_bre_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pqh_bre_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pqh_bre_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pqh_bre_ins.post_insert
     (p_effective_date
     ,p_rec
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
  (p_effective_date               in     date
  ,p_position_id                    in     number   default null
  ,p_pool_id                        in     number   default null
  ,p_reallocation_amt               in     number   default null
  ,p_reserved_amt                   in     number   default null
  ,p_txn_detail_id                 in     number   default null
  ,p_transaction_type               in     varchar2 default null
  ,p_budget_detail_id               in     number   default null
  ,p_budget_period_id               in     number   default null
  ,p_entity_id                      in     number   default null
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_reallocation_id                   out  nocopy  number
  ,p_object_version_number             out  nocopy  number
  ) is
--
  l_rec   pqh_bre_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_bre_shd.convert_args
    (null
    ,p_position_id
    ,p_pool_id
    ,p_reallocation_amt
    ,p_reserved_amt
    ,null
    ,p_txn_detail_id
    ,p_transaction_type
    ,p_budget_detail_id
    ,p_budget_period_id
    ,p_entity_id
    ,p_start_date
    ,p_end_date
    );
  --
  -- Having converted the arguments into the pqh_bre_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pqh_bre_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_reallocation_id := l_rec.reallocation_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_bre_ins;

/
