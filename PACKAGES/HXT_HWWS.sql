--------------------------------------------------------
--  DDL for Package HXT_HWWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HWWS" AUTHID CURRENT_USER AS
/* $Header: hxtwwsdm.pkh 120.0 2005/05/29 06:06:38 appldev noship $ */

procedure insert_HXT_WEEKLY_WORK_SCHEDUL(
p_rowid                      IN OUT NOCOPY VARCHAR2,
p_id                         NUMBER,
p_name                       VARCHAR2,
p_business_group_id          NUMBER,  --HXT11i1
p_start_day                  VARCHAR2,
p_date_from                  DATE,
p_description                VARCHAR2,
p_date_to                    DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER
);

procedure update_HXT_WEEKLY_WORK_SCHEDUL(
p_rowid                      IN VARCHAR2,
p_id                         NUMBER,
p_name                       VARCHAR2,
p_business_group_id          NUMBER,  --HXT11i1
p_start_day                  VARCHAR2,
p_date_from                  DATE,
p_description                VARCHAR2,
p_date_to                    DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER
);

procedure delete_HXT_WEEKLY_WORK_SCHEDUL(p_rowid VARCHAR2);

procedure lock_HXT_WEEKLY_WORK_SCHEDULES(p_rowid VARCHAR2);

END HXT_HWWS;

 

/
