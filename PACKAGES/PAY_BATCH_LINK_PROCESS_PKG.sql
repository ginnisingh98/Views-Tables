--------------------------------------------------------
--  DDL for Package PAY_BATCH_LINK_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BATCH_LINK_PROCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: pybatlnk.pkh 120.0 2006/09/28 14:33:46 thabara noship $ */

procedure action_archinit
  (p_payroll_action_id in number);

procedure action_range_cursor
  (p_payroll_action_id in         number
  ,p_sqlstr            out nocopy varchar2
  );

procedure action_action_creation
  (p_payroll_action_id in number
  ,p_start_person_id   in number
  ,p_end_person_id     in number
  ,p_chunk             in number
  );

procedure action_archive_data
  (p_assactid in number
  ,p_effective_date in date
  );

procedure action_deinit
  (p_payroll_action_id in number);

end pay_batch_link_process_pkg;

/
