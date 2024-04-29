--------------------------------------------------------
--  DDL for Package Body HXT_HER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HER" AS
/* $Header: hxterdml.pkb 115.2 99/07/16 13:39:47 porting ship $ */

procedure insert_HXT_EARNING_RULES(
p_rowid                      IN OUT VARCHAR2,
p_id                         NUMBER,
p_element_type_id            NUMBER,
p_egp_id                     NUMBER,
p_seq_no                     NUMBER,
p_name                       VARCHAR2,
p_egr_type                   VARCHAR2,
p_hours                      NUMBER,
p_effective_start_date       DATE,
p_days                       NUMBER,
p_effective_end_date         DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER
) is

cursor c2 is select rowid
            from   HXT_EARNING_RULES
            where  effective_start_date = p_effective_start_date
            and    effective_end_date = p_effective_end_date
            and    id = p_id;

begin

insert into HXT_EARNING_RULES(
id,
element_type_id,
egp_id,
seq_no,
name,
egr_type,
hours,
effective_start_date,
days,
effective_end_date,
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login)
VALUES(
p_id,
p_element_type_id,
p_egp_id,
p_seq_no,
p_name,
p_egr_type,
p_hours,
p_effective_start_date,
p_days,
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

end insert_HXT_EARNING_RULES;


procedure update_HXT_EARNING_RULES(
p_rowid                      IN VARCHAR2,
p_id                         NUMBER,
p_element_type_id            NUMBER,
p_egp_id                     NUMBER,
p_seq_no                     NUMBER,
p_name                       VARCHAR2,
p_egr_type                   VARCHAR2,
p_hours                      NUMBER,
p_effective_start_date       DATE,
p_days                       NUMBER,
p_effective_end_date         DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER
) is

begin

update HXT_EARNING_RULES
set
element_type_id = p_element_type_id,
egp_id = p_egp_id,
seq_no = p_seq_no,
name = p_name,
egr_type = p_egr_type,
hours = p_hours,
effective_start_date = p_effective_start_date,
days = p_days,
effective_end_date = p_effective_end_date,
created_by = p_created_by,
creation_date = p_creation_date,
last_updated_by = p_last_updated_by,
last_update_date = p_last_update_date,
last_update_login = p_last_update_login
where rowid = p_rowid;

end update_HXT_EARNING_RULES;


procedure delete_HXT_EARNING_RULES(p_rowid VARCHAR2) is
begin
   delete from HXT_EARNING_RULES
   where rowid = chartorowid(p_rowid);
end delete_HXT_EARNING_RULES;

procedure lock_HXT_EARNING_RULES(p_rowid VARCHAR2) is
vnull number;
begin
if p_rowid is not null then
   select ID into vnull
   from HXT_EARNING_RULES
   where rowid = p_rowid
   for update of HXT_EARNING_RULES.ID nowait;

end if;
end lock_HXT_EARNING_RULES;

end HXT_HER;

/
