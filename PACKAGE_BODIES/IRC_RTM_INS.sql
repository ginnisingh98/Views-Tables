--------------------------------------------------------
--  DDL for Package Body IRC_RTM_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_RTM_INS" as
/* $Header: irrtmrhi.pkb 120.3 2008/01/22 10:17:45 mkjayara noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_rtm_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_rec_team_member_id_i  number   default null;
-- ----------------------------------------------------------------------------
-- |----------------------< set_base_key_value >------------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
(p_rec_team_member_id in number) is
  l_proc varchar2(72):=g_package||'set_base_key_value';
begin
  hr_utility.set_location('Entering'||l_proc,10);
  irc_rtm_ins.g_rec_team_member_id_i := p_rec_team_member_id;
  hr_utility.set_location('Leaving'||l_proc,20);
end set_base_key_value;
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
  (p_rec in out nocopy irc_rtm_shd.g_rec_type
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
  -- Insert the row into: irc_rec_team_members
  --
  insert into irc_rec_team_members
      (rec_team_member_id
      ,person_id
      ,party_id
      ,vacancy_id
      ,job_id
      ,start_date
      ,end_date
      ,update_allowed
      ,delete_allowed
      ,object_version_number
      ,interview_security
      )
  Values
    (p_rec.rec_team_member_id
    ,p_rec.person_id
    ,p_rec.party_id
    ,p_rec.vacancy_id
    ,p_rec.job_id
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.update_allowed
    ,p_rec.delete_allowed
    ,p_rec.object_version_number
    ,p_rec.interview_security
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    irc_rtm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    irc_rtm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    irc_rtm_shd.constraint_error
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
  (p_rec  in out nocopy irc_rtm_shd.g_rec_type
  ) is
--
cursor c1 is select irc_rec_team_members_s.nextval from sys.dual;
cursor c2 is
select null from irc_rec_team_members
where rec_team_member_id = irc_rtm_ins.g_rec_team_member_id_i;
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (irc_rtm_ins.g_rec_team_member_id_i is not null) Then

   open c2;
   fetch c2 into l_exists;
   if c2%found then
    close c2;
    fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
    fnd_message.set_token('TABLE_NAME','irc_rec_team_members');
    fnd_message.raise_error;
  end if;
  close c2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.rec_team_member_id :=
      irc_rtm_ins.g_rec_team_member_id_i;
    irc_rtm_ins.g_rec_team_member_id_i := null;
  --
  else
    open c1;
    fetch c1 into p_rec.rec_team_member_id;
    close c1;
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
  (p_rec                          in irc_rtm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_rtm_rki.after_insert
      (p_rec_team_member_id => p_rec.rec_team_member_id
      ,p_person_id => p_rec.person_id
      ,p_vacancy_id
      => p_rec.vacancy_id
      ,p_job_id
      => p_rec.job_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_update_allowed
      => p_rec.update_allowed
      ,p_interview_security
      => p_rec.interview_security
      ,p_delete_allowed
      => p_rec.delete_allowed
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_REC_TEAM_MEMBERS'
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
  (p_rec                          in out nocopy irc_rtm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  irc_rtm_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  irc_rtm_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  irc_rtm_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  irc_rtm_ins.post_insert
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_job_id                        in     number
  ,p_update_allowed                 in     varchar2
  ,p_delete_allowed                 in     varchar2
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_vacancy_id                     in     number
  ,p_person_id                      in     number
  ,p_object_version_number          out nocopy    number
  ,p_rec_team_member_id             out nocopy number
  ,p_interview_security              in    varchar2  default 'SELF'
  ) is
--
  l_rec   irc_rtm_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  irc_rtm_shd.convert_args
    (null
    ,p_person_id
    ,null
    ,p_vacancy_id
    ,p_job_id
    ,p_start_date
    ,p_end_date
    ,p_update_allowed
    ,p_delete_allowed
    ,null
    ,p_interview_security
    );
  --
  -- Having converted the arguments into the irc_rtm_rec
  -- plsql record structure we call the corresponding record business process.
  --
  irc_rtm_ins.ins
     (l_rec
     );
  --
  -- The OUT argument's values must be set.
  --
  p_rec_team_member_id := l_rec.rec_team_member_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end irc_rtm_ins;

/
