--------------------------------------------------------
--  DDL for Package Body HXT_HT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HT" AS
/* $Header: hxttkdml.pkb 115.0 99/07/16 14:30:54 porting ship $ */

procedure insert_HXT_TASKS(
p_rowid                      IN OUT VARCHAR2,
p_id                         NUMBER,
p_pro_id                     NUMBER,
p_name                       VARCHAR2,
p_date_from                  DATE,
p_description                VARCHAR2,
p_estimated_time             NUMBER,
p_fcl_units                  VARCHAR2,
p_date_to                    DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER,
p_task_number                VARCHAR2
) is

cursor c2 is select rowid
            from   HXT_TASKS
            where  id = p_id;

begin

insert into HXT_TASKS(
id,
pro_id,
name,
date_from,
description,
estimated_time,
fcl_units,
date_to,
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login,
task_number)
VALUES(
p_id,
p_pro_id,
p_name,
p_date_from,
p_description,
p_estimated_time,
p_fcl_units,
p_date_to,
p_created_by,
p_creation_date,
p_last_updated_by,
p_last_update_date,
p_last_update_login,
p_task_number);

open c2;
fetch c2 into p_rowid;
close c2;
null;

end insert_HXT_TASKS;


procedure update_HXT_TASKS(
p_rowid                      IN VARCHAR2,
p_id                         NUMBER,
p_pro_id                     NUMBER,
p_name                       VARCHAR2,
p_date_from                  DATE,
p_description                VARCHAR2,
p_estimated_time             NUMBER,
p_fcl_units                  VARCHAR2,
p_date_to                    DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER,
p_task_number                VARCHAR2
) is

begin

update HXT_TASKS
set
pro_id = p_pro_id,
name = p_name,
date_from = p_date_from,
description = p_description,
estimated_time = p_estimated_time,
fcl_units = p_fcl_units,
date_to = p_date_to,
created_by = p_created_by,
creation_date = p_creation_date,
last_updated_by = p_last_updated_by,
last_update_date = p_last_update_date,
last_update_login = p_last_update_login,
task_number = p_task_number
where rowid = p_rowid;

end update_HXT_TASKS;


procedure delete_HXT_TASKS(p_rowid VARCHAR2) is
begin
   delete from HXT_TASKS
   where rowid = chartorowid(p_rowid);
end delete_HXT_TASKS;

procedure lock_HXT_TASKS(p_rowid VARCHAR2) is
vnull number;
begin
if p_rowid is not null then
   select ID into vnull
   from HXT_TASKS
   where rowid = p_rowid
   for update of HXT_TASKS.ID nowait;

end if;
end lock_HXT_TASKS;

end HXT_HT;

/
