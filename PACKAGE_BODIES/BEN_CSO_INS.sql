--------------------------------------------------------
--  DDL for Package Body BEN_CSO_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CSO_INS" as
/* $Header: becsorhi.pkb 115.0 2003/03/17 13:37:07 csundar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cso_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_cwb_stock_optn_dtls_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_cwb_stock_optn_dtls_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ben_cso_ins.g_cwb_stock_optn_dtls_id_i := p_cwb_stock_optn_dtls_id;
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
  (p_rec in out nocopy ben_cso_shd.g_rec_type
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
  -- Insert the row into: ben_cwb_stock_optn_dtls
  --
  insert into ben_cwb_stock_optn_dtls
      (cwb_stock_optn_dtls_id
      ,grant_id
      ,grant_number
      ,grant_name
      ,grant_type
      ,grant_date
      ,grant_shares
      ,grant_price
      ,value_at_grant
      ,current_share_price
      ,current_shares_outstanding
      ,vested_shares
      ,unvested_shares
      ,exercisable_shares
      ,exercised_shares
      ,cancelled_shares
      ,trading_symbol
      ,expiration_date
      ,reason_code
      ,class
      ,misc
      ,employee_number
      ,person_id
      ,business_group_id
      ,prtt_rt_val_id
      ,object_version_number
      ,cso_attribute_category
      ,cso_attribute1
      ,cso_attribute2
      ,cso_attribute3
      ,cso_attribute4
      ,cso_attribute5
      ,cso_attribute6
      ,cso_attribute7
      ,cso_attribute8
      ,cso_attribute9
      ,cso_attribute10
      ,cso_attribute11
      ,cso_attribute12
      ,cso_attribute13
      ,cso_attribute14
      ,cso_attribute15
      ,cso_attribute16
      ,cso_attribute17
      ,cso_attribute18
      ,cso_attribute19
      ,cso_attribute20
      ,cso_attribute21
      ,cso_attribute22
      ,cso_attribute23
      ,cso_attribute24
      ,cso_attribute25
      ,cso_attribute26
      ,cso_attribute27
      ,cso_attribute28
      ,cso_attribute29
      ,cso_attribute30
      )
  Values
    (p_rec.cwb_stock_optn_dtls_id
    ,p_rec.grant_id
    ,p_rec.grant_number
    ,p_rec.grant_name
    ,p_rec.grant_type
    ,p_rec.grant_date
    ,p_rec.grant_shares
    ,p_rec.grant_price
    ,p_rec.value_at_grant
    ,p_rec.current_share_price
    ,p_rec.current_shares_outstanding
    ,p_rec.vested_shares
    ,p_rec.unvested_shares
    ,p_rec.exercisable_shares
    ,p_rec.exercised_shares
    ,p_rec.cancelled_shares
    ,p_rec.trading_symbol
    ,p_rec.expiration_date
    ,p_rec.reason_code
    ,p_rec.class
    ,p_rec.misc
    ,p_rec.employee_number
    ,p_rec.person_id
    ,p_rec.business_group_id
    ,p_rec.prtt_rt_val_id
    ,p_rec.object_version_number
    ,p_rec.cso_attribute_category
    ,p_rec.cso_attribute1
    ,p_rec.cso_attribute2
    ,p_rec.cso_attribute3
    ,p_rec.cso_attribute4
    ,p_rec.cso_attribute5
    ,p_rec.cso_attribute6
    ,p_rec.cso_attribute7
    ,p_rec.cso_attribute8
    ,p_rec.cso_attribute9
    ,p_rec.cso_attribute10
    ,p_rec.cso_attribute11
    ,p_rec.cso_attribute12
    ,p_rec.cso_attribute13
    ,p_rec.cso_attribute14
    ,p_rec.cso_attribute15
    ,p_rec.cso_attribute16
    ,p_rec.cso_attribute17
    ,p_rec.cso_attribute18
    ,p_rec.cso_attribute19
    ,p_rec.cso_attribute20
    ,p_rec.cso_attribute21
    ,p_rec.cso_attribute22
    ,p_rec.cso_attribute23
    ,p_rec.cso_attribute24
    ,p_rec.cso_attribute25
    ,p_rec.cso_attribute26
    ,p_rec.cso_attribute27
    ,p_rec.cso_attribute28
    ,p_rec.cso_attribute29
    ,p_rec.cso_attribute30
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ben_cso_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ben_cso_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ben_cso_shd.constraint_error
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
  (p_rec  in out nocopy ben_cso_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select ben_cwb_stock_optn_dtls_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ben_cwb_stock_optn_dtls
     where cwb_stock_optn_dtls_id =
             ben_cso_ins.g_cwb_stock_optn_dtls_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (ben_cso_ins.g_cwb_stock_optn_dtls_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ben_cwb_stock_optn_dtls');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.cwb_stock_optn_dtls_id :=
      ben_cso_ins.g_cwb_stock_optn_dtls_id_i;
    ben_cso_ins.g_cwb_stock_optn_dtls_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.cwb_stock_optn_dtls_id;
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
  ,p_rec                          in ben_cso_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_cso_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_cwb_stock_optn_dtls_id
      => p_rec.cwb_stock_optn_dtls_id
      ,p_grant_id
      => p_rec.grant_id
      ,p_grant_number
      => p_rec.grant_number
      ,p_grant_name
      => p_rec.grant_name
      ,p_grant_type
      => p_rec.grant_type
      ,p_grant_date
      => p_rec.grant_date
      ,p_grant_shares
      => p_rec.grant_shares
      ,p_grant_price
      => p_rec.grant_price
      ,p_value_at_grant
      => p_rec.value_at_grant
      ,p_current_share_price
      => p_rec.current_share_price
      ,p_current_shares_outstanding
      => p_rec.current_shares_outstanding
      ,p_vested_shares
      => p_rec.vested_shares
      ,p_unvested_shares
      => p_rec.unvested_shares
      ,p_exercisable_shares
      => p_rec.exercisable_shares
      ,p_exercised_shares
      => p_rec.exercised_shares
      ,p_cancelled_shares
      => p_rec.cancelled_shares
      ,p_trading_symbol
      => p_rec.trading_symbol
      ,p_expiration_date
      => p_rec.expiration_date
      ,p_reason_code
      => p_rec.reason_code
      ,p_class
      => p_rec.class
      ,p_misc
      => p_rec.misc
      ,p_employee_number
      => p_rec.employee_number
      ,p_person_id
      => p_rec.person_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_prtt_rt_val_id
      => p_rec.prtt_rt_val_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_cso_attribute_category
      => p_rec.cso_attribute_category
      ,p_cso_attribute1
      => p_rec.cso_attribute1
      ,p_cso_attribute2
      => p_rec.cso_attribute2
      ,p_cso_attribute3
      => p_rec.cso_attribute3
      ,p_cso_attribute4
      => p_rec.cso_attribute4
      ,p_cso_attribute5
      => p_rec.cso_attribute5
      ,p_cso_attribute6
      => p_rec.cso_attribute6
      ,p_cso_attribute7
      => p_rec.cso_attribute7
      ,p_cso_attribute8
      => p_rec.cso_attribute8
      ,p_cso_attribute9
      => p_rec.cso_attribute9
      ,p_cso_attribute10
      => p_rec.cso_attribute10
      ,p_cso_attribute11
      => p_rec.cso_attribute11
      ,p_cso_attribute12
      => p_rec.cso_attribute12
      ,p_cso_attribute13
      => p_rec.cso_attribute13
      ,p_cso_attribute14
      => p_rec.cso_attribute14
      ,p_cso_attribute15
      => p_rec.cso_attribute15
      ,p_cso_attribute16
      => p_rec.cso_attribute16
      ,p_cso_attribute17
      => p_rec.cso_attribute17
      ,p_cso_attribute18
      => p_rec.cso_attribute18
      ,p_cso_attribute19
      => p_rec.cso_attribute19
      ,p_cso_attribute20
      => p_rec.cso_attribute20
      ,p_cso_attribute21
      => p_rec.cso_attribute21
      ,p_cso_attribute22
      => p_rec.cso_attribute22
      ,p_cso_attribute23
      => p_rec.cso_attribute23
      ,p_cso_attribute24
      => p_rec.cso_attribute24
      ,p_cso_attribute25
      => p_rec.cso_attribute25
      ,p_cso_attribute26
      => p_rec.cso_attribute26
      ,p_cso_attribute27
      => p_rec.cso_attribute27
      ,p_cso_attribute28
      => p_rec.cso_attribute28
      ,p_cso_attribute29
      => p_rec.cso_attribute29
      ,p_cso_attribute30
      => p_rec.cso_attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_STOCK_OPTN_DTLS'
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
  ,p_rec                          in out nocopy ben_cso_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_cso_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ben_cso_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ben_cso_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ben_cso_ins.post_insert
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
  ,p_grant_id                       in     number   default null
  ,p_grant_number                   in     varchar2 default null
  ,p_grant_name                     in     varchar2 default null
  ,p_grant_type                     in     varchar2 default null
  ,p_grant_date                     in     date     default null
  ,p_grant_shares                   in     number   default null
  ,p_grant_price                    in     number   default null
  ,p_value_at_grant                 in     number   default null
  ,p_current_share_price            in     number   default null
  ,p_current_shares_outstanding     in     number   default null
  ,p_vested_shares                  in     number   default null
  ,p_unvested_shares                in     number   default null
  ,p_exercisable_shares             in     number   default null
  ,p_exercised_shares               in     number   default null
  ,p_cancelled_shares               in     number   default null
  ,p_trading_symbol                 in     varchar2 default null
  ,p_expiration_date                in     date     default null
  ,p_reason_code                    in     varchar2 default null
  ,p_class                          in     varchar2 default null
  ,p_misc                           in     varchar2 default null
  ,p_employee_number                in     varchar2 default null
  ,p_person_id                      in     number   default null
  ,p_business_group_id              in     number   default null
  ,p_prtt_rt_val_id                 in     number   default null
  ,p_cso_attribute_category         in     varchar2 default null
  ,p_cso_attribute1                 in     varchar2 default null
  ,p_cso_attribute2                 in     varchar2 default null
  ,p_cso_attribute3                 in     varchar2 default null
  ,p_cso_attribute4                 in     varchar2 default null
  ,p_cso_attribute5                 in     varchar2 default null
  ,p_cso_attribute6                 in     varchar2 default null
  ,p_cso_attribute7                 in     varchar2 default null
  ,p_cso_attribute8                 in     varchar2 default null
  ,p_cso_attribute9                 in     varchar2 default null
  ,p_cso_attribute10                in     varchar2 default null
  ,p_cso_attribute11                in     varchar2 default null
  ,p_cso_attribute12                in     varchar2 default null
  ,p_cso_attribute13                in     varchar2 default null
  ,p_cso_attribute14                in     varchar2 default null
  ,p_cso_attribute15                in     varchar2 default null
  ,p_cso_attribute16                in     varchar2 default null
  ,p_cso_attribute17                in     varchar2 default null
  ,p_cso_attribute18                in     varchar2 default null
  ,p_cso_attribute19                in     varchar2 default null
  ,p_cso_attribute20                in     varchar2 default null
  ,p_cso_attribute21                in     varchar2 default null
  ,p_cso_attribute22                in     varchar2 default null
  ,p_cso_attribute23                in     varchar2 default null
  ,p_cso_attribute24                in     varchar2 default null
  ,p_cso_attribute25                in     varchar2 default null
  ,p_cso_attribute26                in     varchar2 default null
  ,p_cso_attribute27                in     varchar2 default null
  ,p_cso_attribute28                in     varchar2 default null
  ,p_cso_attribute29                in     varchar2 default null
  ,p_cso_attribute30                in     varchar2 default null
  ,p_cwb_stock_optn_dtls_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ben_cso_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_cso_shd.convert_args
    (null
    ,p_grant_id
    ,p_grant_number
    ,p_grant_name
    ,p_grant_type
    ,p_grant_date
    ,p_grant_shares
    ,p_grant_price
    ,p_value_at_grant
    ,p_current_share_price
    ,p_current_shares_outstanding
    ,p_vested_shares
    ,p_unvested_shares
    ,p_exercisable_shares
    ,p_exercised_shares
    ,p_cancelled_shares
    ,p_trading_symbol
    ,p_expiration_date
    ,p_reason_code
    ,p_class
    ,p_misc
    ,p_employee_number
    ,p_person_id
    ,p_business_group_id
    ,p_prtt_rt_val_id
    ,null
    ,p_cso_attribute_category
    ,p_cso_attribute1
    ,p_cso_attribute2
    ,p_cso_attribute3
    ,p_cso_attribute4
    ,p_cso_attribute5
    ,p_cso_attribute6
    ,p_cso_attribute7
    ,p_cso_attribute8
    ,p_cso_attribute9
    ,p_cso_attribute10
    ,p_cso_attribute11
    ,p_cso_attribute12
    ,p_cso_attribute13
    ,p_cso_attribute14
    ,p_cso_attribute15
    ,p_cso_attribute16
    ,p_cso_attribute17
    ,p_cso_attribute18
    ,p_cso_attribute19
    ,p_cso_attribute20
    ,p_cso_attribute21
    ,p_cso_attribute22
    ,p_cso_attribute23
    ,p_cso_attribute24
    ,p_cso_attribute25
    ,p_cso_attribute26
    ,p_cso_attribute27
    ,p_cso_attribute28
    ,p_cso_attribute29
    ,p_cso_attribute30
    );
  --
  -- Having converted the arguments into the ben_cso_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ben_cso_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_cwb_stock_optn_dtls_id := l_rec.cwb_stock_optn_dtls_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_cso_ins;

/
