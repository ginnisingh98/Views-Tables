--------------------------------------------------------
--  DDL for Package Body HXT_HDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HDR" AS
/* $Header: hxthdrdm.pkb 115.0 99/07/16 14:28:49 porting ship $ */

procedure insert_HXT_HOUR_DEDUCTION_RULE(
p_rowid                      IN OUT VARCHAR2,
p_hdp_id                     NUMBER,
p_fcl_deduction_type         VARCHAR2,
p_effective_start_date       DATE,
p_hours                      NUMBER,
p_time_period                NUMBER,
p_effective_end_date         DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER
) is

cursor c2 is select rowid
            from   HXT_HOUR_DEDUCTION_RULES
            where  effective_start_date = p_effective_start_date
            and    effective_end_date = p_effective_end_date
            and    hdp_id = p_hdp_id;

begin

insert into HXT_HOUR_DEDUCTION_RULES(
hdp_id,
fcl_deduction_type,
effective_start_date,
hours,
time_period,
effective_end_date,
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login)
VALUES(
p_hdp_id,
p_fcl_deduction_type,
p_effective_start_date,
p_hours,
p_time_period,
p_effective_end_date,
p_created_by,
p_creation_date,
p_last_updated_by,
p_last_update_date,
p_last_update_login);

open c2;
fetch c2 into p_rowid;
close c2;
null;

end insert_HXT_HOUR_DEDUCTION_RULE;


procedure update_HXT_HOUR_DEDUCTION_RULE(
p_rowid                      IN VARCHAR2,
p_hdp_id                     NUMBER,
p_fcl_deduction_type         VARCHAR2,
p_effective_start_date       DATE,
p_hours                      NUMBER,
p_time_period                NUMBER,
p_effective_end_date         DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER
) is

begin

update HXT_HOUR_DEDUCTION_RULES
set
fcl_deduction_type = p_fcl_deduction_type,
effective_start_date = p_effective_start_date,
hours = p_hours,
time_period = p_time_period,
effective_end_date = p_effective_end_date,
created_by = p_created_by,
creation_date = p_creation_date,
last_updated_by = p_last_updated_by,
last_update_date = p_last_update_date,
last_update_login = p_last_update_login
where rowid = p_rowid;

end update_HXT_HOUR_DEDUCTION_RULE;


procedure delete_HXT_HOUR_DEDUCTION_RULE(p_rowid VARCHAR2) is
begin
   delete from HXT_HOUR_DEDUCTION_RULES
   where rowid = chartorowid(p_rowid);
end delete_HXT_HOUR_DEDUCTION_RULE;

procedure lock_HXT_HOUR_DEDUCTION_RULES(p_rowid VARCHAR2) is
vnull number;
begin
if p_rowid is not null then
   select HDP_ID into vnull
   from HXT_HOUR_DEDUCTION_RULES
   where rowid = p_rowid
   for update of HXT_HOUR_DEDUCTION_RULES.HDP_ID nowait;

end if;
end lock_HXT_HOUR_DEDUCTION_RULES;

end HXT_HDR;

/
