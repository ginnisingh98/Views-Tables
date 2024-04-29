--------------------------------------------------------
--  DDL for Package HR_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GEN_PKG" AUTHID CURRENT_USER as
/* $Header: hrgen.pkh 115.6 2004/05/12 04:05:23 njaladi ship $ */
------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
	HR Libraries server-side agent
Purpose
	Agent handles all server-side traffic to and from forms libraries. This
	is particularly necessary because we wish to avoid the situation where
	a form and its libraries both refer to the same server-side package.
	Forms/libraries appears to be unable to cope with this situation in
	circumstances which we cannot yet define.
History
	21 Apr 95	N Simpson	Created
	17 May 95	N Simpson	Added comment_text, insert_comment
					and get_customized_restriction to
					remove all sql from client side, and
					thus allow the library to be made
					global.
	14 Jun 95	N Simpson	Added change_ses_date, get_dates
	23 Jun 95       D Kerr		Added bg_name and bg_currency_code to
					to init_forms and temporary overload.
        20 Dec 96       D Kerr          Removed temporary overload
					Changes to init_forms interface
					Added tracing procedures.
	19 Aug 97	Sxshah	        Banner now on eack line.
	24 Dec 97	D Kerr          Added delete_ses_rows
        17 Feb 99       D Kerr          11.5:Added overload for get_dates

        05 Dec 99       Dave Kerr       This file now diverges from 11.0 version
                                        init_forms: added p_hr_trace_dest param
                                        Cover for hr_utility.set_trace_options.
        18 Jul 01       M Enderby       Addition of ADE related pipe code
        05 Feb 02       G Sayers        Added dbdrv and commit to comply with
                                        GSCC standards.
        03-Dec-02       A.Holt          NOCOPY Performance Changes for 11.5.9
        12-May-04    njaladi       3577964- Added new autonomous transactin wrapper
                                   procedure putSessionAttributeValue which calls
                                   the icx_sec.putSessionAttributeValue.
*/
PROCEDURE init_forms(
	--
	p_business_group_id        IN   NUMBER,
        p_short_name               OUT NOCOPY  VARCHAR2,
        p_bg_name                  OUT NOCOPY  VARCHAR2,
        p_bg_currency_code         OUT NOCOPY  VARCHAR2,
        p_legislation_code         OUT NOCOPY  VARCHAR2,
        p_session_date        IN   OUT NOCOPY  DATE,
        p_ses_yesterday            OUT NOCOPY  DATE,
        p_start_of_time            OUT NOCOPY  DATE,
        p_end_of_time              OUT NOCOPY  DATE,
        p_sys_date                 OUT NOCOPY  DATE,
        p_enable_hr_trace          IN   BOOLEAN,
        p_hr_trace_dest            IN   VARCHAR2 DEFAULT 'DBMS_PIPE'
	/* This code not yet implemented
	,p_form_name	   	varchar2 default null
	,p_actual_version       varchar2 default null*/
	);
	--
procedure get_customized_restriction (
	--
	p_restriction_name		in	varchar2,
	p_form_name			in	varchar2,
	p_business_group_id		in	number,
	p_legislation_code		in	varchar2,
	p_application_id	 out nocopy number,
	p_query_title		 out nocopy varchar2,
	p_standard_title	 out nocopy varchar2,
	p_customized_restriction_id out nocopy number,
	p_message_name		 out nocopy varchar2);
	--
procedure insert_comment (
	--
	p_source_table_name	varchar2,
	p_comment_text		varchar2,
	p_comment_id		in out nocopy number);
	--
function comment_text (p_comment_id number) return varchar2;
--
procedure get_dates(
p_ses_date	 out nocopy date,
p_ses_yesterday_date out nocopy date,
p_start_of_time	 out nocopy date,
p_end_of_time	 out nocopy date,
p_sys_date	 out nocopy date,
p_commit	 out nocopy number);

procedure get_dates(
p_ses_date	 out nocopy date,
p_ses_yesterday_date out nocopy date,
p_start_of_time	 out nocopy date,
p_end_of_time	 out nocopy date,
p_sys_date	 out nocopy date);
--
procedure change_ses_date (
p_ses_date	date,
p_commit out nocopy number);
--
procedure delete_ses_rows ;
--
procedure trace_on(trace_mode in varchar2,session_identifier in varchar2);
procedure trace_off;
procedure trace(trace_data in varchar2) ;
procedure set_location(procedure_name in varchar2, stage in number) ;
procedure set_trace_options(p_options in varchar2) ;
procedure pipe_ade_detail(p_detail IN varchar2);
procedure reset_pipe_buffer;
procedure purge_pipe(p_pipename IN varchar2);
procedure send_pipe_message(p_pipename IN varchar2);

procedure putSessionAttributeValue ( p_name in varchar2,
                                     p_value in varchar2,
                                     p_session_id in number);

end	hr_gen_pkg;

 

/
