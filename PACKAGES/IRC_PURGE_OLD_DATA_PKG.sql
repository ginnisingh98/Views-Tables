--------------------------------------------------------
--  DDL for Package IRC_PURGE_OLD_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PURGE_OLD_DATA_PKG" AUTHID CURRENT_USER AS
/* $Header: ircpurge.pkh 120.1.12010000.1 2008/07/28 12:39:07 appldev ship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< purge_record_process >------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure will be called from the concurrent program.
--
procedure purge_record_process
(
   errbuf           out nocopy varchar2
  ,retcode          out nocopy varchar2
  ,p_effective_date in varchar2
  ,p_process_type   in varchar2
  ,p_measure_type   in varchar2
  ,p_months         in number
);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_max_updated_date >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will be called to get the maximum updation date. Based
--   on this date data of the candidate will be purged
--
--
function get_max_updated_date
(
  p_person_id in number
) return date;
function is_free_to_purge(p_party_id number,p_effective_date date) return string;
PRAGMA RESTRICT_REFERENCES (is_free_to_purge, WNDS);

-- ----------------------------------------------------------------------------
-- |--------------------------< last_application_date >-----------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   This function will be called to get the last application date. Based
--   on this date data of the candidate will be purged
--
function last_application_date
(
  p_party_id       in number
 ,p_effective_date in date
)
return date;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< clean_employee_data >------------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- This procedure will be called by the sql script irpurcln.sql for clearing
-- the employee_id in fnd_user table which do not have person record in
-- per_all_people_f table
--
procedure clean_employee_data(p_process_ctrl      IN varchar2
                             ,p_start_pkid        IN number
                             ,p_end_pkid          IN number
                             ,p_rows_processed    OUT nocopy number
                             );
--
end irc_purge_old_data_pkg;

/
