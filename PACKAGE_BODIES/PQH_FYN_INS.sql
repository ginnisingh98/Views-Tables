--------------------------------------------------------
--  DDL for Package Body PQH_FYN_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FYN_INS" as
/* $Header: pqfynrhi.pkb 115.6 2002/12/06 18:06:27 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_fyn_ins.';  -- Global package name
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy pqh_fyn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';

  l_count              number(9) := 0;

-- check if the combo already exists and only then insert record
CURSOR csr_cnt_combo(p_transaction_category_id IN number,
                     p_transaction_id     IN number,
                     p_notification_event_cd IN varchar2,
                     p_notified_type_cd   IN varchar2,
                     p_notified_name     IN varchar2)  IS
 SELECT COUNT(*)
 FROM pqh_fyi_notify
 WHERE transaction_category_id = p_transaction_category_id
   AND transaction_id   = p_transaction_id
   AND notification_event_cd = p_notification_event_cd
   AND NVL(notified_type_cd,'X') = NVL(p_notified_type_cd,'X')
   AND NVL(notified_name,'X')   = NVL(p_notified_name,'X')
   AND NVL(status,'X') <> 'SENT';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --

  --
  -- check for the combo before inserting
  --
   OPEN csr_cnt_combo(p_transaction_category_id   =>  p_rec.transaction_category_id,
                      p_transaction_id            =>  p_rec.transaction_id,
                      p_notification_event_cd     =>  p_rec.notification_event_cd,
                      p_notified_type_cd          =>  p_rec.notified_type_cd,
                      p_notified_name             =>  p_rec.notified_name );
       FETCH csr_cnt_combo  INTO l_count;

   CLOSE csr_cnt_combo;
  --
  hr_utility.set_location(' fyi_notified_id: '||p_rec.fyi_notified_id, 6);
  hr_utility.set_location(' transaction_category_id: '||p_rec.transaction_category_id, 7);
  hr_utility.set_location(' transaction_id: '||p_rec.transaction_id, 8);
  hr_utility.set_location(' notification_event_cd: '||p_rec.notification_event_cd, 9);
  hr_utility.set_location(' notified_type_cd: '||p_rec.notified_type_cd, 10);
  hr_utility.set_location(' notified_name: '||p_rec.notified_name, 11);
  hr_utility.set_location(' notification_date: '||p_rec.notification_date, 12);
  hr_utility.set_location(' status: '||p_rec.status, 13);
  hr_utility.set_location(' object_version_number: '||p_rec.object_version_number, 14);
  hr_utility.set_location(' COUNT COMBO: '||l_count, 15);
  --
  --
  -- Insert the row into: pqh_fyi_notify  ONLY if the row does not exists i.e l_count = 0
  --

if NVL(l_count,0) = 0 THEN
  --
  hr_utility.set_location('Inserting INTO pqh_fyi_notify ....',16);

  insert into pqh_fyi_notify
  (	fyi_notified_id,
	transaction_category_id,
	transaction_id,
	notification_event_cd,
	notified_type_cd,
	notified_name,
	notification_date,
	status,
	object_version_number
  )
  Values
  (	p_rec.fyi_notified_id,
	p_rec.transaction_category_id,
	p_rec.transaction_id,
	p_rec.notification_event_cd,
	p_rec.notified_type_cd,
	p_rec.notified_name,
	p_rec.notification_date,
	p_rec.status,
	p_rec.object_version_number
  );

  --
end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_fyn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_fyn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_fyn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_insert(p_rec  in out nocopy pqh_fyn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_fyi_notify_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.fyi_notified_id;
  Close C_Sel1;
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
Procedure post_insert(
p_effective_date in date,p_rec in pqh_fyn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    pqh_fyn_rki.after_insert
      (
  p_fyi_notified_id               =>p_rec.fyi_notified_id
 ,p_transaction_category_id       =>p_rec.transaction_category_id
 ,p_transaction_id                =>p_rec.transaction_id
 ,p_notification_event_cd         =>p_rec.notification_event_cd
 ,p_notified_type_cd              =>p_rec.notified_type_cd
 ,p_notified_name                 =>p_rec.notified_name
 ,p_notification_date             =>p_rec.notification_date
 ,p_status                        =>p_rec.status
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_fyi_notify'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_rec        in out nocopy pqh_fyn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_fyn_bus.insert_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(
p_effective_date,p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_fyi_notified_id              out nocopy number,
  p_transaction_category_id      in number,
  p_transaction_id               in number,
  p_notification_event_cd        in varchar2,
  p_notified_type_cd             in varchar2         default null,
  p_notified_name                in varchar2         default null,
  p_notification_date            in date             default null,
  p_status                       in varchar2         default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  pqh_fyn_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_fyn_shd.convert_args
  (
  null,
  p_transaction_category_id,
  p_transaction_id,
  p_notification_event_cd,
  p_notified_type_cd,
  p_notified_name,
  p_notification_date,
  p_status,
  null
  );
  --
  -- Having converted the arguments into the pqh_fyn_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_fyi_notified_id := l_rec.fyi_notified_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_fyn_ins;

/
