--------------------------------------------------------
--  DDL for Package BEN_CWB_REFRESH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_REFRESH_PKG" AUTHID CURRENT_USER as
/* $Header: bencwbrf.pkh 120.3.12010000.1 2008/07/29 12:07:44 appldev ship $ */
-- --------------------------------------------------------------------------
-- |------------------------------< refresh >--------------------------------|
-- --------------------------------------------------------------------------
-- Description
--	This procedure contains calls for refreshing person_info, pl_dsgn,
-- summary and consolidation of summary. This will be called by a concurent
-- process. If no value is passed for effective_date, then lf_evt_ocrd_dt
-- will be considered as the effective_date.
--
procedure refresh(errbuf  out  nocopy  varchar2
                 ,retcode out  nocopy  number
	         ,p_group_pl_id number
                 ,p_lf_evt_ocrd_dt varchar2
		 ,p_effective_date varchar2 default null
		 ,p_refresh_summary_flag varchar2
		 ,p_refresh_person_info_flag varchar2
		 ,p_refresh_pl_dsgn_flag varchar2
		 ,p_consolidate_summary_flag varchar2
		 ,p_init_rank varchar2
                 ,p_refresh_xchg varchar2
		 ,p_refresh_rate_from_rule varchar2 default 'N');

end BEN_CWB_REFRESH_PKG;


/
