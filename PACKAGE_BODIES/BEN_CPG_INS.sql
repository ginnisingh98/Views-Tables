--------------------------------------------------------
--  DDL for Package Body BEN_CPG_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPG_INS" as
/* $Header: becpgrhi.pkb 120.0 2005/05/28 01:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpg_ins.';  -- Global package name
g_debug  boolean := hr_utility.debug_enabled;
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_group_per_in_ler_id_i  number   default null;
g_group_pl_id_i  number   default null;
g_group_oipl_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_group_per_in_ler_id  in  number
  ,p_group_pl_id  in  number
  ,p_group_oipl_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  ben_cpg_ins.g_group_per_in_ler_id_i := p_group_per_in_ler_id;
  ben_cpg_ins.g_group_pl_id_i := p_group_pl_id;
  ben_cpg_ins.g_group_oipl_id_i := p_group_oipl_id;
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
  (p_rec in out nocopy ben_cpg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_cpg_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_cwb_person_groups
  --
  insert into ben_cwb_person_groups
      (group_per_in_ler_id
      ,group_pl_id
      ,group_oipl_id
      ,lf_evt_ocrd_dt
      ,bdgt_pop_cd
      ,due_dt
      ,access_cd
      ,approval_cd
      ,approval_date
      ,approval_comments
      ,submit_cd
      ,submit_date
      ,submit_comments
      ,dist_bdgt_val
      ,ws_bdgt_val
      ,rsrv_val
      ,dist_bdgt_mn_val
      ,dist_bdgt_mx_val
      ,dist_bdgt_incr_val
      ,ws_bdgt_mn_val
      ,ws_bdgt_mx_val
      ,ws_bdgt_incr_val
      ,rsrv_mn_val
      ,rsrv_mx_val
      ,rsrv_incr_val
      ,dist_bdgt_iss_val
      ,ws_bdgt_iss_val
      ,dist_bdgt_iss_date
      ,ws_bdgt_iss_date
      ,ws_bdgt_val_last_upd_date
      ,dist_bdgt_val_last_upd_date
      ,rsrv_val_last_upd_date
      ,ws_bdgt_val_last_upd_by
      ,dist_bdgt_val_last_upd_by
      ,rsrv_val_last_upd_by
      ,object_version_number
      )
  Values
    (p_rec.group_per_in_ler_id
    ,p_rec.group_pl_id
    ,p_rec.group_oipl_id
    ,p_rec.lf_evt_ocrd_dt
    ,p_rec.bdgt_pop_cd
    ,p_rec.due_dt
    ,p_rec.access_cd
    ,p_rec.approval_cd
    ,p_rec.approval_date
    ,p_rec.approval_comments
    ,p_rec.submit_cd
    ,p_rec.submit_date
    ,p_rec.submit_comments
    ,p_rec.dist_bdgt_val
    ,p_rec.ws_bdgt_val
    ,p_rec.rsrv_val
    ,p_rec.dist_bdgt_mn_val
    ,p_rec.dist_bdgt_mx_val
    ,p_rec.dist_bdgt_incr_val
    ,p_rec.ws_bdgt_mn_val
    ,p_rec.ws_bdgt_mx_val
    ,p_rec.ws_bdgt_incr_val
    ,p_rec.rsrv_mn_val
    ,p_rec.rsrv_mx_val
    ,p_rec.rsrv_incr_val
    ,p_rec.dist_bdgt_iss_val
    ,p_rec.ws_bdgt_iss_val
    ,p_rec.dist_bdgt_iss_date
    ,p_rec.ws_bdgt_iss_date
    ,p_rec.ws_bdgt_val_last_upd_date
    ,p_rec.dist_bdgt_val_last_upd_date
    ,p_rec.rsrv_val_last_upd_date
    ,p_rec.ws_bdgt_val_last_upd_by
    ,p_rec.dist_bdgt_val_last_upd_by
    ,p_rec.rsrv_val_last_upd_by
    ,p_rec.object_version_number
    );
  --
  ben_cpg_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_cpg_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_cpg_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_cpg_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cpg_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy ben_cpg_shd.g_rec_type
  ) is
--
  Cursor C_Sel2 is
    Select null
      from ben_cwb_person_groups
     where group_per_in_ler_id =
             ben_cpg_ins.g_group_per_in_ler_id_i
        or group_pl_id =
             ben_cpg_ins.g_group_pl_id_i
        or group_oipl_id =
             ben_cpg_ins.g_group_oipl_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  If (ben_cpg_ins.g_group_per_in_ler_id_i is not null or
      ben_cpg_ins.g_group_pl_id_i is not null or
      ben_cpg_ins.g_group_oipl_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ben_cwb_person_groups');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.group_per_in_ler_id :=
      ben_cpg_ins.g_group_per_in_ler_id_i;
    ben_cpg_ins.g_group_per_in_ler_id_i := null;
    p_rec.group_pl_id :=
      ben_cpg_ins.g_group_pl_id_i;
    ben_cpg_ins.g_group_pl_id_i := null;
    p_rec.group_oipl_id :=
      ben_cpg_ins.g_group_oipl_id_i;
    ben_cpg_ins.g_group_oipl_id_i := null;
  Else
    -- Commented out the following code as it is not required.
    null;
/*    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.group_oipl_id;
    Close C_Sel1; */
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
  (p_rec                          in ben_cpg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    ben_cpg_rki.after_insert
      (p_group_per_in_ler_id
      => p_rec.group_per_in_ler_id
      ,p_group_pl_id
      => p_rec.group_pl_id
      ,p_group_oipl_id
      => p_rec.group_oipl_id
      ,p_lf_evt_ocrd_dt
      => p_rec.lf_evt_ocrd_dt
      ,p_bdgt_pop_cd
      => p_rec.bdgt_pop_cd
      ,p_due_dt
      => p_rec.due_dt
      ,p_access_cd
      => p_rec.access_cd
      ,p_approval_cd
      => p_rec.approval_cd
      ,p_approval_date
      => p_rec.approval_date
      ,p_approval_comments
      => p_rec.approval_comments
      ,p_submit_cd
      => p_rec.submit_cd
      ,p_submit_date
      => p_rec.submit_date
      ,p_submit_comments
      => p_rec.submit_comments
      ,p_dist_bdgt_val
      => p_rec.dist_bdgt_val
      ,p_ws_bdgt_val
      => p_rec.ws_bdgt_val
      ,p_rsrv_val
      => p_rec.rsrv_val
      ,p_dist_bdgt_mn_val
      => p_rec.dist_bdgt_mn_val
      ,p_dist_bdgt_mx_val
      => p_rec.dist_bdgt_mx_val
      ,p_dist_bdgt_incr_val
      => p_rec.dist_bdgt_incr_val
      ,p_ws_bdgt_mn_val
      => p_rec.ws_bdgt_mn_val
      ,p_ws_bdgt_mx_val
      => p_rec.ws_bdgt_mx_val
      ,p_ws_bdgt_incr_val
      => p_rec.ws_bdgt_incr_val
      ,p_rsrv_mn_val
      => p_rec.rsrv_mn_val
      ,p_rsrv_mx_val
      => p_rec.rsrv_mx_val
      ,p_rsrv_incr_val
      => p_rec.rsrv_incr_val
      ,p_dist_bdgt_iss_val
      => p_rec.dist_bdgt_iss_val
      ,p_ws_bdgt_iss_val
      => p_rec.ws_bdgt_iss_val
      ,p_dist_bdgt_iss_date
      => p_rec.dist_bdgt_iss_date
      ,p_ws_bdgt_iss_date
      => p_rec.ws_bdgt_iss_date
      ,p_ws_bdgt_val_last_upd_date
      => p_rec.ws_bdgt_val_last_upd_date
      ,p_dist_bdgt_val_last_upd_date
      => p_rec.dist_bdgt_val_last_upd_date
      ,p_rsrv_val_last_upd_date
      => p_rec.rsrv_val_last_upd_date
      ,p_ws_bdgt_val_last_upd_by
      => p_rec.ws_bdgt_val_last_upd_by
      ,p_dist_bdgt_val_last_upd_by
      => p_rec.dist_bdgt_val_last_upd_by
      ,p_rsrv_val_last_upd_by
      => p_rec.rsrv_val_last_upd_by
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_PERSON_GROUPS'
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
  (p_rec                          in out nocopy ben_cpg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call the supporting insert validate operations
  --
  ben_cpg_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ben_cpg_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ben_cpg_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ben_cpg_ins.post_insert
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  if g_debug then
     hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- This procedure is asssuming group_per_in_ler_id, group_pl_id, group_oipl_id
-- as out parameters. But the values for these parameters are passed by the
-- corresponding api, changing the type of the parameters to in out.
-- Also modified the code so that it passes the value to overloaded ins
Procedure ins
  (p_group_per_in_ler_id            in     number
  ,p_group_pl_id                    in     number
  ,p_group_oipl_id                  in     number
  ,p_lf_evt_ocrd_dt                 in     date
  ,p_bdgt_pop_cd                    in     varchar2 default null
  ,p_due_dt                         in     date     default null
  ,p_access_cd                      in     varchar2 default null
  ,p_approval_cd                    in     varchar2 default null
  ,p_approval_date                  in     date     default null
  ,p_approval_comments              in     varchar2 default null
  ,p_submit_cd                      in     varchar2 default null
  ,p_submit_date                    in     date     default null
  ,p_submit_comments                in     varchar2 default null
  ,p_dist_bdgt_val                  in     number   default null
  ,p_ws_bdgt_val                    in     number   default null
  ,p_rsrv_val                       in     number   default null
  ,p_dist_bdgt_mn_val               in     number   default null
  ,p_dist_bdgt_mx_val               in     number   default null
  ,p_dist_bdgt_incr_val             in     number   default null
  ,p_ws_bdgt_mn_val                 in     number   default null
  ,p_ws_bdgt_mx_val                 in     number   default null
  ,p_ws_bdgt_incr_val               in     number   default null
  ,p_rsrv_mn_val                    in     number   default null
  ,p_rsrv_mx_val                    in     number   default null
  ,p_rsrv_incr_val                  in     number   default null
  ,p_dist_bdgt_iss_val              in     number   default null
  ,p_ws_bdgt_iss_val                in     number   default null
  ,p_dist_bdgt_iss_date             in     date     default null
  ,p_ws_bdgt_iss_date               in     date     default null
  ,p_ws_bdgt_val_last_upd_date      in     date     default null
  ,p_dist_bdgt_val_last_upd_date    in     date     default null
  ,p_rsrv_val_last_upd_date         in     date     default null
  ,p_ws_bdgt_val_last_upd_by        in     number   default null
  ,p_dist_bdgt_val_last_upd_by      in     number   default null
  ,p_rsrv_val_last_upd_by           in     number   default null
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ben_cpg_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_cpg_shd.convert_args
    (p_group_per_in_ler_id
    ,p_group_pl_id
    ,p_group_oipl_id
    ,p_lf_evt_ocrd_dt
    ,p_bdgt_pop_cd
    ,p_due_dt
    ,p_access_cd
    ,p_approval_cd
    ,p_approval_date
    ,p_approval_comments
    ,p_submit_cd
    ,p_submit_date
    ,p_submit_comments
    ,p_dist_bdgt_val
    ,p_ws_bdgt_val
    ,p_rsrv_val
    ,p_dist_bdgt_mn_val
    ,p_dist_bdgt_mx_val
    ,p_dist_bdgt_incr_val
    ,p_ws_bdgt_mn_val
    ,p_ws_bdgt_mx_val
    ,p_ws_bdgt_incr_val
    ,p_rsrv_mn_val
    ,p_rsrv_mx_val
    ,p_rsrv_incr_val
    ,p_dist_bdgt_iss_val
    ,p_ws_bdgt_iss_val
    ,p_dist_bdgt_iss_date
    ,p_ws_bdgt_iss_date
    ,p_ws_bdgt_val_last_upd_date
    ,p_dist_bdgt_val_last_upd_date
    ,p_rsrv_val_last_upd_date
    ,p_ws_bdgt_val_last_upd_by
    ,p_dist_bdgt_val_last_upd_by
    ,p_rsrv_val_last_upd_by
    ,null
    );
  --
  -- Having converted the arguments into the ben_cpg_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ben_cpg_ins.ins
     (l_rec
     );
  --
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End ins;
--
end ben_cpg_ins;

/
