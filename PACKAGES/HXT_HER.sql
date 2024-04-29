--------------------------------------------------------
--  DDL for Package HXT_HER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HER" AUTHID CURRENT_USER AS
/* $Header: hxterdml.pkh 115.2 99/07/16 13:39:51 porting ship $ */

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
);

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
);

procedure delete_HXT_EARNING_RULES(p_rowid VARCHAR2);

procedure lock_HXT_EARNING_RULES(p_rowid VARCHAR2);

END HXT_HER;

 

/
