--------------------------------------------------------
--  DDL for Package Body HXT_HWWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HWWS" AS
/* $Header: hxtwwsdm.pkb 120.0 2005/05/29 06:06:32 appldev noship $ */

procedure insert_HXT_WEEKLY_WORK_SCHEDUL(
p_rowid                      IN OUT NOCOPY VARCHAR2,
p_id                         NUMBER,
p_name                       VARCHAR2,
p_business_group_id          NUMBER,
p_start_day                  VARCHAR2,
p_date_from                  DATE,
p_description                VARCHAR2,
p_date_to                    DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER
) is

cursor c2 is select rowid
            from   HXT_WEEKLY_WORK_SCHEDULES
            where  id = p_id;

begin

insert into HXT_WEEKLY_WORK_SCHEDULES(
id,
name,
business_group_id,
start_day,
date_from,
description,
date_to,
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login
)
VALUES(
p_id,
p_name,
p_business_group_id,
p_start_day,
p_date_from,
p_description,
p_date_to,
p_created_by,
p_creation_date,
p_last_updated_by,
p_last_update_date,
p_last_update_login);

open c2;
fetch c2 into p_rowid;
close c2;
null;

end insert_HXT_WEEKLY_WORK_SCHEDUL;


procedure update_HXT_WEEKLY_WORK_SCHEDUL(
p_rowid                      IN VARCHAR2,
p_id                         NUMBER,
p_name                       VARCHAR2,
p_business_group_id          NUMBER,
p_start_day                  VARCHAR2,
p_date_from                  DATE,
p_description                VARCHAR2,
p_date_to                    DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER
) is

begin

update HXT_WEEKLY_WORK_SCHEDULES
set
name = p_name,
business_group_id = p_business_group_id,
start_day = p_start_day,
date_from = p_date_from,
description = p_description,
date_to = p_date_to,
created_by = p_created_by,
creation_date = p_creation_date,
last_updated_by = p_last_updated_by,
last_update_date = p_last_update_date,
last_update_login = p_last_update_login
where rowid = p_rowid;

end update_HXT_WEEKLY_WORK_SCHEDUL;


procedure delete_HXT_WEEKLY_WORK_SCHEDUL(p_rowid VARCHAR2) is
begin
   delete from HXT_WEEKLY_WORK_SCHEDULES
   where rowid = chartorowid(p_rowid);
end delete_HXT_WEEKLY_WORK_SCHEDUL;

procedure lock_HXT_WEEKLY_WORK_SCHEDULES(p_rowid VARCHAR2) is
vnull number;
begin
if p_rowid is not null then
   select ID into vnull
   from HXT_WEEKLY_WORK_SCHEDULES
   where rowid = p_rowid
   for update of HXT_WEEKLY_WORK_SCHEDULES.ID nowait;

end if;
end lock_HXT_WEEKLY_WORK_SCHEDULES;

end HXT_HWWS;

/
