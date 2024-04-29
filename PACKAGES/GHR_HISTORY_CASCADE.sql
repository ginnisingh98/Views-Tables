--------------------------------------------------------
--  DDL for Package GHR_HISTORY_CASCADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_HISTORY_CASCADE" AUTHID CURRENT_USER as
/* $Header: ghcascad.pkh 120.0.12010000.1 2008/07/28 10:22:54 appldev ship $ */
--

TYPE condition_rg_type IS TABLE of boolean index by binary_integer;
Procedure Cascade_History_data (
	p_table_name		in	varchar2,
	p_person_id			in	varchar2,
	p_pre_record		in	ghr_pa_history%rowtype,
	p_post_record        	in	ghr_pa_history%rowtype,
	p_cascade_type		in	varchar2,
	p_interv_on_table	 out nocopy   boolean,
	p_interv_on_eff_date out nocopy   boolean,
	p_hist_data_as_of_date	 out nocopy ghr_pa_history%rowtype );


Procedure Cascade_Appl_table_data (
	p_table_name			in	varchar2,
	p_person_id 			in	varchar2,
	p_pre_record			in	ghr_pa_history%rowtype,
	p_post_record			in	ghr_pa_history%rowtype,
	p_cascade_type			in	varchar2,
	p_interv_on_table			in	Boolean,
	p_interv_on_eff_date		in	Boolean,
	p_hist_data_as_of_date		in	ghr_pa_history%rowtype);

Procedure cascade_pa_req(p_rfrsh_rec	      in out nocopy ghr_pa_requests%rowtype,
				 p_shadow_rec           in out nocopy ghr_pa_requests%rowtype,
				 p_sf52_rec			in out nocopy ghr_pa_requests%rowtype,
				 p_changed			in out nocopy boolean);

End ghr_history_cascade;
--

/
