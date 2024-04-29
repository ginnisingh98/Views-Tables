--------------------------------------------------------
--  DDL for Package Body HXT_HWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HWS" AS
/* $Header: hxtwsdml.pkb 115.0 99/07/16 14:31:53 porting ship $ */

procedure insert_HXT_WORK_SHIFTS(
p_rowid                      IN OUT VARCHAR2,
p_sht_id                     NUMBER,
p_tws_id                     NUMBER,
p_week_day                   VARCHAR2,
p_seq_no                     NUMBER,
p_early_start                NUMBER,
p_late_stop                  NUMBER,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER,
p_off_shift_prem_id          NUMBER,
p_shift_diff_ovrrd_id        NUMBER
) is

cursor c2 is select rowid
            from   HXT_WORK_SHIFTS
            where  sht_id = p_sht_id;

begin

insert into HXT_WORK_SHIFTS(
sht_id,
tws_id,
week_day,
seq_no,
early_start,
late_stop,
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login,
off_shift_prem_id,
shift_diff_ovrrd_id)
VALUES(
p_sht_id,
p_tws_id,
p_week_day,
p_seq_no,
p_early_start,
p_late_stop,
p_created_by,
p_creation_date,
p_last_updated_by,
p_last_update_date,
p_last_update_login,
p_off_shift_prem_id,
p_shift_diff_ovrrd_id);

open c2;
fetch c2 into p_rowid;
close c2;
null;

end insert_HXT_WORK_SHIFTS;


procedure update_HXT_WORK_SHIFTS(
p_rowid                      IN VARCHAR2,
p_sht_id                     NUMBER,
p_tws_id                     NUMBER,
p_week_day                   VARCHAR2,
p_seq_no                     NUMBER,
p_early_start                NUMBER,
p_late_stop                  NUMBER,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER,
p_off_shift_prem_id          NUMBER,
p_shift_diff_ovrrd_id        NUMBER
) is

begin

update HXT_WORK_SHIFTS
set
sht_id = p_sht_id,
tws_id = p_tws_id,
week_day = p_week_day,
seq_no = p_seq_no,
early_start = p_early_start,
late_stop = p_late_stop,
created_by = p_created_by,
creation_date = p_creation_date,
last_updated_by = p_last_updated_by,
last_update_date = p_last_update_date,
last_update_login = p_last_update_login,
off_shift_prem_id = p_off_shift_prem_id,
shift_diff_ovrrd_id = p_shift_diff_ovrrd_id
where rowid = p_rowid;

end update_HXT_WORK_SHIFTS;


procedure delete_HXT_WORK_SHIFTS(p_rowid VARCHAR2) is
begin
   delete from HXT_WORK_SHIFTS
   where rowid = chartorowid(p_rowid);
end delete_HXT_WORK_SHIFTS;

procedure lock_HXT_WORK_SHIFTS(p_rowid VARCHAR2) is
vnull number;
begin
if p_rowid is not null then
   select SHT_ID into vnull
   from HXT_WORK_SHIFTS
   where rowid = p_rowid
   for update of HXT_WORK_SHIFTS.SHT_ID nowait;

end if;
end lock_HXT_WORK_SHIFTS;

end HXT_HWS;

/
