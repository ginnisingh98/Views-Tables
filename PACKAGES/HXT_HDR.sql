--------------------------------------------------------
--  DDL for Package HXT_HDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HDR" AUTHID CURRENT_USER AS
/* $Header: hxthdrdm.pkh 115.0 99/07/16 14:28:54 porting ship $ */

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
);

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
);

procedure delete_HXT_HOUR_DEDUCTION_RULE(p_rowid VARCHAR2);

procedure lock_HXT_HOUR_DEDUCTION_RULES(p_rowid VARCHAR2);

END HXT_HDR;

 

/
