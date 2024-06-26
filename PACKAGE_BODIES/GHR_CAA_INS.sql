--------------------------------------------------------
--  DDL for Package Body GHR_CAA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CAA_INS" as
/* $Header: ghcaarhi.pkb 115.1 2003/01/30 19:24:47 asubrahm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_caa_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_compl_agency_appeal_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_compl_agency_appeal_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ghr_caa_ins.g_compl_agency_appeal_id_i := p_compl_agency_appeal_id;
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
  (p_rec in out nocopy ghr_caa_shd.g_rec_type
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
  -- Insert the row into: ghr_compl_agency_appeals
  --
  insert into ghr_compl_agency_appeals
      (compl_agency_appeal_id
      ,complaint_id
      ,appeal_date
      ,reason_for_appeal
      ,source_decision_date
      ,docket_num
      ,agency_recvd_req_for_files
      ,files_due
      ,files_forwd
      ,agency_brief_due
      ,agency_brief_forwd
      ,agency_recvd_appellant_brief
      ,decision_date
      ,dec_recvd_by_agency
      ,decision
      ,dec_forwd_to_org
      ,agency_rfr_suspense
      ,request_for_rfr
      ,rfr_docket_num
      ,rfr_requested_by
      ,agency_rfr_due
      ,rfr_forwd_to_org
      ,org_forwd_rfr_to_agency
      ,agency_forwd_rfr_ofo
      ,rfr_decision_date
      ,agency_recvd_rfr_dec
      ,rfr_decision_forwd_to_org
      ,rfr_decision
      ,object_version_number
      )
  Values
    (p_rec.compl_agency_appeal_id
    ,p_rec.complaint_id
    ,p_rec.appeal_date
    ,p_rec.reason_for_appeal
    ,p_rec.source_decision_date
    ,p_rec.docket_num
    ,p_rec.agency_recvd_req_for_files
    ,p_rec.files_due
    ,p_rec.files_forwd
    ,p_rec.agency_brief_due
    ,p_rec.agency_brief_forwd
    ,p_rec.agency_recvd_appellant_brief
    ,p_rec.decision_date
    ,p_rec.dec_recvd_by_agency
    ,p_rec.decision
    ,p_rec.dec_forwd_to_org
    ,p_rec.agency_rfr_suspense
    ,p_rec.request_for_rfr
    ,p_rec.rfr_docket_num
    ,p_rec.rfr_requested_by
    ,p_rec.agency_rfr_due
    ,p_rec.rfr_forwd_to_org
    ,p_rec.org_forwd_rfr_to_agency
    ,p_rec.agency_forwd_rfr_ofo
    ,p_rec.rfr_decision_date
    ,p_rec.agency_recvd_rfr_dec
    ,p_rec.rfr_decision_forwd_to_org
    ,p_rec.rfr_decision
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
    ghr_caa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ghr_caa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ghr_caa_shd.constraint_error
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
  (p_rec  in out nocopy ghr_caa_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select ghr_compl_agency_appeals_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ghr_compl_agency_appeals
     where compl_agency_appeal_id =
             ghr_caa_ins.g_compl_agency_appeal_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (ghr_caa_ins.g_compl_agency_appeal_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ghr_compl_agency_appeals');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.compl_agency_appeal_id :=
      ghr_caa_ins.g_compl_agency_appeal_id_i;
    ghr_caa_ins.g_compl_agency_appeal_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.compl_agency_appeal_id;
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
  ,p_rec                          in ghr_caa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ghr_caa_rki.after_insert
      (p_effective_date               => p_effective_date
      ,p_compl_agency_appeal_id       => p_rec.compl_agency_appeal_id
      ,p_complaint_id                 => p_rec.complaint_id
      ,p_appeal_date                  => p_rec.appeal_date
      ,p_reason_for_appeal            => p_rec.reason_for_appeal
      ,p_source_decision_date         => p_rec.source_decision_date
      ,p_docket_num                   => p_rec.docket_num
      ,p_agency_recvd_req_for_files   => p_rec.agency_recvd_req_for_files
      ,p_files_due                    => p_rec.files_due
      ,p_files_forwd                  => p_rec.files_forwd
      ,p_agency_brief_due             => p_rec.agency_brief_due
      ,p_agency_brief_forwd           => p_rec.agency_brief_forwd
      ,p_agency_recvd_appellant_brief => p_rec.agency_recvd_appellant_brief
      ,p_decision_date                => p_rec.decision_date
      ,p_dec_recvd_by_agency          => p_rec.dec_recvd_by_agency
      ,p_decision                     => p_rec.decision
      ,p_dec_forwd_to_org             => p_rec.dec_forwd_to_org
      ,p_agency_rfr_suspense          => p_rec.agency_rfr_suspense
      ,p_request_for_rfr              => p_rec.request_for_rfr
      ,p_rfr_docket_num               => p_rec.rfr_docket_num
      ,p_rfr_requested_by             => p_rec.rfr_requested_by
      ,p_agency_rfr_due               => p_rec.agency_rfr_due
      ,p_rfr_forwd_to_org             => p_rec.rfr_forwd_to_org
      ,p_org_forwd_rfr_to_agency      => p_rec.org_forwd_rfr_to_agency
      ,p_agency_forwd_rfr_ofo         => p_rec.agency_forwd_rfr_ofo
      ,p_rfr_decision_date            => p_rec.rfr_decision_date
      ,p_agency_recvd_rfr_dec         => p_rec.agency_recvd_rfr_dec
      ,p_rfr_decision_forwd_to_org    => p_rec.rfr_decision_forwd_to_org
      ,p_rfr_decision                 => p_rec.rfr_decision
      ,p_object_version_number        => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'GHR_COMPL_AGENCY_APPEALS'
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
  ,p_rec                          in out nocopy ghr_caa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ghr_caa_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  ghr_caa_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ghr_caa_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ghr_caa_ins.post_insert
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
  ,p_complaint_id                   in     number
  ,p_appeal_date                    in     date     default null
  ,p_reason_for_appeal              in     varchar2 default null
  ,p_source_decision_date           in     date     default null
  ,p_docket_num                     in     varchar2 default null
  ,p_agency_recvd_req_for_files     in     date     default null
  ,p_files_due                      in     date     default null
  ,p_files_forwd                    in     date     default null
  ,p_agency_brief_due               in     date     default null
  ,p_agency_brief_forwd             in     date     default null
  ,p_agency_recvd_appellant_brief   in     date     default null
  ,p_decision_date                  in     date     default null
  ,p_dec_recvd_by_agency            in     date     default null
  ,p_decision                       in     varchar2 default null
  ,p_dec_forwd_to_org               in     date     default null
  ,p_agency_rfr_suspense            in     date     default null
  ,p_request_for_rfr                in     date     default null
  ,p_rfr_docket_num                 in     varchar2 default null
  ,p_rfr_requested_by               in     varchar2 default null
  ,p_agency_rfr_due                 in     date     default null
  ,p_rfr_forwd_to_org               in     date     default null
  ,p_org_forwd_rfr_to_agency        in     date     default null
  ,p_agency_forwd_rfr_ofo           in     date     default null
  ,p_rfr_decision_date              in     date     default null
  ,p_agency_recvd_rfr_dec           in     date     default null
  ,p_rfr_decision_forwd_to_org      in     date     default null
  ,p_rfr_decision                   in     varchar2 default null
  ,p_compl_agency_appeal_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ghr_caa_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ghr_caa_shd.convert_args
    (null
    ,p_complaint_id
    ,p_appeal_date
    ,p_reason_for_appeal
    ,p_source_decision_date
    ,p_docket_num
    ,p_agency_recvd_req_for_files
    ,p_files_due
    ,p_files_forwd
    ,p_agency_brief_due
    ,p_agency_brief_forwd
    ,p_agency_recvd_appellant_brief
    ,p_decision_date
    ,p_dec_recvd_by_agency
    ,p_decision
    ,p_dec_forwd_to_org
    ,p_agency_rfr_suspense
    ,p_request_for_rfr
    ,p_rfr_docket_num
    ,p_rfr_requested_by
    ,p_agency_rfr_due
    ,p_rfr_forwd_to_org
    ,p_org_forwd_rfr_to_agency
    ,p_agency_forwd_rfr_ofo
    ,p_rfr_decision_date
    ,p_agency_recvd_rfr_dec
    ,p_rfr_decision_forwd_to_org
    ,p_rfr_decision
    ,null
    );
  --
  -- Having converted the arguments into the ghr_caa_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ghr_caa_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_compl_agency_appeal_id := l_rec.compl_agency_appeal_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ghr_caa_ins;

/
