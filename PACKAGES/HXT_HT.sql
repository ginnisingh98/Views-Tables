--------------------------------------------------------
--  DDL for Package HXT_HT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HT" AUTHID CURRENT_USER AS
/* $Header: hxttkdml.pkh 115.0 99/07/16 14:31:00 porting ship $ */

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
);

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
);

procedure delete_HXT_TASKS(p_rowid VARCHAR2);

procedure lock_HXT_TASKS(p_rowid VARCHAR2);

END HXT_HT;

 

/
