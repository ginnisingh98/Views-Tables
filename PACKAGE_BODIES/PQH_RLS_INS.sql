--------------------------------------------------------
--  DDL for Package Body PQH_RLS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RLS_INS" as
/* $Header: pqrlsrhi.pkb 115.21 2004/02/18 12:06:25 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rls_ins.';  -- Global package name
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
--   If a check,unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported,the error will be raised after the
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
  ( p_rec in out NOCOPY pqh_rls_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: pqh_roles
  --
  insert into pqh_roles
      (role_id
      ,role_name
      ,role_type_cd
      ,enable_flag
      ,object_version_number
      ,business_group_id
      ,information_category
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,information11
      ,information12
      ,information13
      ,information14
      ,information15
      ,information16
      ,information17
      ,information18
      ,information19
      ,information20
      ,information21
      ,information22
      ,information23
      ,information24
      ,information25
      ,information26
      ,information27
      ,information28
      ,information29
      ,information30
      )
  Values
    (p_rec.role_id
    ,p_rec.role_name
    ,p_rec.role_type_cd
    ,p_rec.enable_flag
    ,p_rec.object_version_number
    ,p_rec.business_group_id
    ,p_rec.information_category
    ,p_rec.information1
    ,p_rec.information2
    ,p_rec.information3
    ,p_rec.information4
    ,p_rec.information5
    ,p_rec.information6
    ,p_rec.information7
    ,p_rec.information8
    ,p_rec.information9
    ,p_rec.information10
    ,p_rec.information11
    ,p_rec.information12
    ,p_rec.information13
    ,p_rec.information14
    ,p_rec.information15
    ,p_rec.information16
    ,p_rec.information17
    ,p_rec.information18
    ,p_rec.information19
    ,p_rec.information20
    ,p_rec.information21
    ,p_rec.information22
    ,p_rec.information23
    ,p_rec.information24
    ,p_rec.information25
    ,p_rec.information26
    ,p_rec.information27
    ,p_rec.information28
    ,p_rec.information29
    ,p_rec.information30
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqh_rls_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqh_rls_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_rls_shd.constraint_error
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
--   the insert dml. Presently,if the entity has a corresponding primary
--   key which is maintained by an associating sequence,the primary key for
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
--   If an error has occurred,an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above,a good example is the
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
  ( p_rec in out NOCOPY pqh_rls_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_roles_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.role_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
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
--   If an error has occurred,an error message and exception will be raised
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
  ,p_rec                        in pqh_rls_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  begin
    --
    pqh_rls_rki.after_insert
   (p_effective_date          => p_effective_date
    ,p_role_id                => p_rec.role_id
    ,p_role_name              => p_rec.role_name
    ,p_role_type_cd           => p_rec.role_type_cd
    ,p_enable_flag            => p_rec.enable_flag
    ,p_object_version_number  => p_rec.object_version_number
    ,p_business_group_id      => p_rec.business_group_id
    ,p_information_category   => p_rec.information_category
    ,p_information1	      => p_rec.information1
    ,p_information2	      => p_rec.information2
    ,p_information3	      => p_rec.information3
    ,p_information4	      => p_rec.information4
    ,p_information5	      => p_rec.information5
    ,p_information6	      => p_rec.information6
    ,p_information7           => p_rec.information7
    ,p_information8	      => p_rec.information8
    ,p_information9           => p_rec.information9
    ,p_information10	      => p_rec.information10
    ,p_information11	      => p_rec.information11
    ,p_information12	      => p_rec.information12
    ,p_information13	      => p_rec.information13
    ,p_information14	      => p_rec.information14
    ,p_information15	      => p_rec.information15
    ,p_information16	      => p_rec.information16
    ,p_information17	      => p_rec.information17
    ,p_information18	      => p_rec.information18
    ,p_information19	      => p_rec.information19
    ,p_information20	      => p_rec.information20
    ,p_information21	      => p_rec.information21
    ,p_information22	      => p_rec.information22
    ,p_information23	      => p_rec.information23
    ,p_information24	      => p_rec.information24
    ,p_information25	      => p_rec.information25
    ,p_information26	      => p_rec.information26
    ,p_information27	      => p_rec.information27
    ,p_information28	      => p_rec.information28
    ,p_information29	      => p_rec.information29
    ,p_information30	      => p_rec.information30
      );
    --
  hr_utility.set_location('Before calling WF_SYNC:'||l_proc, 5);
    if p_rec.enable_flag = 'Y' then
    declare
      l_plist wf_parameter_list_t;
    begin
      hr_utility.set_location('Before calling WF_SYNC parameters:'||l_proc, 5);
      WF_EVENT.AddParameterToList('USER_NAME','PQH_ROLE:'|| p_rec.role_id, l_plist);
      WF_EVENT.AddParameterToList('DISPLAYNAME',p_rec.role_name, l_plist);
      WF_EVENT.AddParameterToList('DESCRIPTION',p_rec.role_name, l_plist);
      WF_EVENT.AddParameterToList('orclWorkFlowNotificationPref', 'QUERY', l_plist);
      WF_EVENT.AddParameterToList('orclIsEnabled','ACTIVE', l_plist);
      WF_EVENT.AddParameterToList('orclWFOrigSystem','PQH_ROLE', l_plist);
      WF_EVENT.AddParameterToList('orclWFOrigSystemID',p_rec.role_id,l_plist);
      WF_EVENT.AddParameterToList('ExpirationDate',to_char(null),l_plist);
      WF_EVENT.AddParameterToList('StartDate',to_char(p_effective_date,wf_engine.date_format),l_plist);
      WF_EVENT.AddParameterToList('RaiseErrorS','FALSE',l_plist);

  hr_utility.set_location('Before calling WF_SYNC package role:'|| p_rec.role_id, 5);
      WF_LOCAL_SYNCH.propagate_role(p_orig_system     => 'PQH_ROLE',
                                  p_orig_system_id  => p_rec.role_id,
                                  p_attributes      => l_plist,
                                  p_start_date      => p_effective_date);
  hr_utility.set_location('After calling WF_SYNC package:'||l_proc, 5);
    end;
    end if;

    hr_utility.set_location('After calling WF_SYNC:'||l_proc, 5);

  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_ROLES'
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
  ,p_rec                        in out NOCOPY pqh_rls_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_rls_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  pqh_rls_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pqh_rls_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pqh_rls_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- mvanakda
-- Added DDF columns to the Procedure ins
Procedure ins
  (p_effective_date         in date
  ,p_role_name              in varchar2
  ,p_business_group_id      in number
  ,p_role_type_cd           in varchar2
  ,p_enable_flag            in varchar2
  ,p_information_category   in varchar2
  ,p_information1           in varchar2
  ,p_information2           in varchar2
  ,p_information3           in varchar2
  ,p_information4           in varchar2
  ,p_information5           in varchar2
  ,p_information6           in varchar2
  ,p_information7           in varchar2
  ,p_information8           in varchar2
  ,p_information9           in varchar2
  ,p_information10          in varchar2
  ,p_information11          in varchar2
  ,p_information12          in varchar2
  ,p_information13          in varchar2
  ,p_information14          in varchar2
  ,p_information15          in varchar2
  ,p_information16          in varchar2
  ,p_information17          in varchar2
  ,p_information18          in varchar2
  ,p_information19          in varchar2
  ,p_information20          in varchar2
  ,p_information21          in varchar2
  ,p_information22          in varchar2
  ,p_information23          in varchar2
  ,p_information24          in varchar2
  ,p_information25          in varchar2
  ,p_information26          in varchar2
  ,p_information27          in varchar2
  ,p_information28          in varchar2
  ,p_information29          in varchar2
  ,p_information30          in varchar2
  ,p_role_id                out NOCOPY number
  ,p_object_version_number  out NOCOPY number
  ) is
--
  l_rec	  pqh_rls_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Call conversion function to turn arguments into the
  --  structure.
  --
  l_rec :=
  pqh_rls_shd.convert_args
  (null
  ,p_role_name
  ,p_role_type_cd
  ,p_enable_flag
  ,null
  ,p_business_group_id
  ,p_information_category
  ,p_information1
  ,p_information2
  ,p_information3
  ,p_information4
  ,p_information5
  ,p_information6
  ,p_information7
  ,p_information8
  ,p_information9
  ,p_information10
  ,p_information11
  ,p_information12
  ,p_information13
  ,p_information14
  ,p_information15
  ,p_information16
  ,p_information17
  ,p_information18
  ,p_information19
  ,p_information20
  ,p_information21
  ,p_information22
  ,p_information23
  ,p_information24
  ,p_information25
  ,p_information26
  ,p_information27
  ,p_information28
  ,p_information29
  ,p_information30
    );
  --
  -- Having converted the arguments into the pqh_rls_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pqh_rls_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_role_id := l_rec.role_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
End ins;
--
end pqh_rls_ins;

/
