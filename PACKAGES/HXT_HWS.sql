--------------------------------------------------------
--  DDL for Package HXT_HWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HWS" AUTHID CURRENT_USER AS
/* $Header: hxtwsdml.pkh 115.0 99/07/16 14:31:58 porting ship $ */

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
);

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
);

procedure delete_HXT_WORK_SHIFTS(p_rowid VARCHAR2);

procedure lock_HXT_WORK_SHIFTS(p_rowid VARCHAR2);

END HXT_HWS;

 

/
