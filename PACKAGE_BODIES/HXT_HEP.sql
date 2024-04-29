--------------------------------------------------------
--  DDL for Package Body HXT_HEP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HEP" AS
/* $Header: hxtepdml.pkb 120.0 2005/05/29 06:02:55 appldev noship $ */

procedure insert_HXT_EARNING_POLICIES(
p_rowid                      IN OUT NOCOPY VARCHAR2,
p_id                         NUMBER,
p_hcl_id                     NUMBER,
p_fcl_earn_type              VARCHAR2,
p_name                       VARCHAR2,
p_business_group_id          NUMBER,  --HXT11i1
p_effective_start_date       DATE,
p_pip_id                     NUMBER,
p_pep_id                     NUMBER,
p_egt_id                     NUMBER,
p_description                VARCHAR2,
p_effective_end_date         DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER,
p_organization_id            NUMBER,
p_round_up                   NUMBER,
p_min_tcard_intvl            NUMBER,
p_use_points_assigned        VARCHAR2
) is

cursor c2 is select rowid
            from   HXT_EARNING_POLICIES
            where  effective_start_date = p_effective_start_date
            and    effective_end_date = p_effective_end_date
            and    id = p_id;

begin

insert into HXT_EARNING_POLICIES
(id
,hcl_id
,fcl_earn_type
,name
,business_group_id  --HXT11i1
,effective_start_date
,pip_id
,pep_id
,egt_id
,description
,effective_end_date
,created_by
,creation_date
,last_updated_by
,last_update_date
,last_update_login
,organization_id
,round_up
,min_tcard_intvl
,use_points_assigned
)
VALUES
(p_id
,p_hcl_id
,p_fcl_earn_type
,p_name
,p_business_group_id  --HXT11i1
,p_effective_start_date
,p_pip_id
,p_pep_id
,p_egt_id
,p_description
,p_effective_end_date
,p_created_by
,p_creation_date
,p_last_updated_by
,p_last_update_date
,p_last_update_login
,p_organization_id
,p_round_up
,p_min_tcard_intvl
,p_use_points_assigned
);

open c2;
fetch c2 into p_rowid;
close c2;
null;

end insert_HXT_EARNING_POLICIES;


procedure update_HXT_EARNING_POLICIES
(p_rowid                      IN VARCHAR2
,p_id                         NUMBER
,p_hcl_id                     NUMBER
,p_fcl_earn_type              VARCHAR2
,p_name                       VARCHAR2
,p_business_group_id          NUMBER  --HXT11i1
,p_effective_start_date       DATE
,p_pip_id                     NUMBER
,p_pep_id                     NUMBER
,p_egt_id                     NUMBER
,p_description                VARCHAR2
,p_effective_end_date         DATE
,p_created_by                 NUMBER
,p_creation_date              DATE
,p_last_updated_by            NUMBER
,p_last_update_date           DATE
,p_last_update_login          NUMBER
,p_organization_id            NUMBER
,p_round_up                   NUMBER
,p_min_tcard_intvl            NUMBER
,p_use_points_assigned        VARCHAR2
) is

begin

UPDATE HXT_EARNING_POLICIES
SET
hcl_id               = p_hcl_id,
fcl_earn_type        = p_fcl_earn_type,
name                 = p_name,
business_group_id    = p_business_group_id,  --HXT11i1
effective_start_date = p_effective_start_date,
pip_id               = p_pip_id,
pep_id               = p_pep_id,
egt_id               = p_egt_id,
description          = p_description,
effective_end_date   = p_effective_end_date,
created_by           = p_created_by,
creation_date        = p_creation_date,
last_updated_by      = p_last_updated_by,
last_update_date     = p_last_update_date,
last_update_login    = p_last_update_login,
organization_id      = p_organization_id,
round_up             = p_round_up,
min_tcard_intvl      = p_min_tcard_intvl,
use_points_assigned  = p_use_points_assigned
where rowid          = p_rowid;

end update_HXT_EARNING_POLICIES;


procedure delete_HXT_EARNING_POLICIES(p_rowid VARCHAR2) is
begin
   delete from HXT_EARNING_POLICIES
   where rowid = chartorowid(p_rowid);
end delete_HXT_EARNING_POLICIES;

procedure lock_HXT_EARNING_POLICIES(p_rowid VARCHAR2) is
vnull number;
begin
if p_rowid is not null then
   select ID into vnull
   from HXT_EARNING_POLICIES
   where rowid = p_rowid
   for update of HXT_EARNING_POLICIES.ID nowait;

end if;
end lock_HXT_EARNING_POLICIES;

end HXT_HEP;

/
