--------------------------------------------------------
--  DDL for Package Body HR_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GEN_PKG" as
/* $Header: hrgen.pkb 115.11 2004/05/12 04:05:41 njaladi ship $
------------------------------------------------------------------------------
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
	05-JUN-1995	N Simpson	Modified legislation/business group
					restriction on
					get_customized_restriction.
	14 Jun 95	N Simpson	Added get_dates, change_ses_date
	23 Jun 95       D Kerr		Added bg_name and bg_currency_code
					to init_forms and temporary overload.
        11 Oct 95       J Thuringer     Removed spurious end of comment marker
	20 Dec 96       D Kerr		init_forms: Removed temp. overload.
				        Modified in line with changes to
					underlying procedure.
					Added tracing procedures.
	19 Aug 97	Sxshah	        Banner now on eack line.
	24 Dec 97	D Kerr          Added delete_ses_rows
        17-FEB-99       D Kerr          11.5: added get_dates overload

        05 Dec 99       Dave Kerr       This file now diverges from 11.0 version
                                        Added p_hr_trace_dest to init_forms
        06 Jul 00       G Perry         Changed comment text to 32000 for
                                        WWBUG 1382371.
        17 Jul 01       M Enderby       Addition of ADE related pipe code
        05 Feb 02       G Sayers        Added dbdrv and commit to comply with
                                        GSCC Standards.
        05-Dec-2002     A.Holt          NOCOPY Performance Changes for 11.5.9
	01-Jul-2003     tvankayl        procedure Get_customized_restriction modified
					to take values from PAY_CUSTOM_RESTRICTIONS_VL instead of
					PAY_CUSTOMIZED_RESTRICTIONS.
 115.10 21-Nov-2003     vramanai        Modified message name in Procedure
                                        Get_Customized_Restriction to
                                        HR_7070_CUST_INVALID_CUST_NAME .
 115.11 12-May-2003    njaladi          3577964- Added new autonomous transactin wrapper
                                        procedure putSessionAttributeValue which calls
                                        the icx_sec.putSessionAttributeValue.

*/
g_dummy	number;	-- Used in various places throughout the package
PROCEDURE init_forms(p_business_group_id      IN   NUMBER,
                     p_short_name             OUT NOCOPY  VARCHAR2,
                     p_bg_name                OUT NOCOPY  VARCHAR2,
                     p_bg_currency_code       OUT NOCOPY  VARCHAR2,
                     p_legislation_code       OUT NOCOPY  VARCHAR2,
                     p_session_date        IN OUT NOCOPY  DATE,
                     p_ses_yesterday          OUT NOCOPY  DATE,
                     p_start_of_time          OUT NOCOPY  DATE,
                     p_end_of_time            OUT NOCOPY  DATE,
                     p_sys_date               OUT NOCOPY  DATE,
		     p_enable_hr_trace        IN   BOOLEAN,
		     p_hr_trace_dest          IN   VARCHAR2 DEFAULT 'DBMS_PIPE'

		     /* This code not yet implemented
		     ,p_form_name	   	varchar2 default null
		     ,p_actual_version		varchar2 default null*/

		     ) IS
begin

hr_general.init_forms(p_business_group_id ,
                     p_short_name       ,
                     p_bg_name          ,
                     p_bg_currency_code ,
                     p_legislation_code ,
                     p_session_date     ,
                     p_ses_yesterday    ,
                     p_start_of_time    ,
                     p_end_of_time      ,
                     p_sys_date         ,
		     p_enable_hr_trace,
		     p_hr_trace_dest
		     /* This code not yet implemented
		     ,p_form_name
		     ,p_actual_version */
		     );
end init_forms;
--------------------------------------------------------------------------------
procedure get_customized_restriction (
--
-- Gets information about a customization of a form
--
	--
	p_restriction_name		in	varchar2,
	p_form_name			in	varchar2,
	p_business_group_id		in	number,
	p_legislation_code		in	varchar2,
	p_application_id	 out nocopy number,
	p_query_title		 out nocopy varchar2,
	p_standard_title	 out nocopy varchar2,
	p_customized_restriction_id out nocopy number,
	p_message_name		 out nocopy varchar2) is
--
cursor csr_restriction is
	select	application_id,
		query_form_title,
		standard_form_title,
		enabled_flag,
		customized_restriction_id
	from	pay_custom_restrictions_vl
	where	name = p_restriction_name
	and	form_name = p_form_name
	and	(business_group_id = p_business_group_id
		or business_group_id is null)
	and 	(legislation_code = p_legislation_code
		or legislation_code is null);
	--
cursor csr_form_name is
	select	1
	from	pay_customized_restrictions
	where	name = p_restriction_name;
	--
l_enabled_flag	varchar2 (30);
--
begin
--
hr_utility.set_location ('hr_gen_pkg.GET_CUSTOMIZED_RESTRICTION',1);
--
-- Get the details of the requested customization
--
open csr_restriction;
fetch csr_restriction into
	--
	p_application_id,
	p_query_title,
	p_standard_title,
	l_enabled_flag,
	p_customized_restriction_id;
	--
hr_utility.set_location ('hr_gen_pkg.GET_CUSTOMIZED_RESTRICTION',2);
--
if csr_restriction%found then
  --
  hr_utility.trace ('Customized restriction found');
  --
  close csr_restriction;
  --
  -- If the customization is disabled, pass this info to the client
  --
  if l_enabled_flag <> 'Y' then
    --
    hr_utility.trace ('Customization is disabled');
    p_message_name := 'HR_7074_CUST_NOT_ENABLED';
    --
  end if;
  --
else
  --
  hr_utility.trace ('Customization was not found for the current form');
  --
  -- If the customization was not found, then establish why.
  --
  open csr_form_name;	-- Is the customization for a different form?
  fetch csr_form_name into g_dummy;
  --
  if csr_form_name%found then	-- Tell the client that the customization applies to a different form
    --
    hr_utility.trace ('Customization was found for a different form');
    p_message_name := 'HR_7070_CUST_INVALID_CUST_NAME';
    --
  else	-- Tell the client that the requested customization does not exist
    --
    hr_utility.trace ('Customization was not found for any form');
    p_message_name := 'HR_7072_CUST_NO_EXIST_NAME';
    --
  end if;
  --
  close csr_form_name;
  --
end if;
--
hr_utility.set_location ('hr_gen_pkg.GET_CUSTOMIZED_RESTRICTION',3);
--
end get_customized_restriction;
--------------------------------------------------------------------------------
procedure insert_comment (
--
-- Inserts a comment into the HR comments table
--
	--
	p_source_table_name	varchar2,
	p_comment_text		varchar2,
	p_comment_id		in out nocopy number) is
--
cursor csr_next_comment_id is
	select	hr_comments_s.nextval
	from	sys.dual;
	--
begin
--
open csr_next_comment_id;
fetch csr_next_comment_id into p_comment_id;
close csr_next_comment_id;
--
insert into hr_comments (
	--
	comment_id,
	source_table_name,
	comment_text)
values (
	p_comment_id,
	p_source_table_name,
	p_comment_text);
	--
end insert_comment;
--------------------------------------------------------------------------------
function comment_text (p_comment_id number) return varchar2 is
--
-- Gets a comment from the HR comments table
--
cursor csr_comment is
	select	comment_text
	from	hr_comments
	where	comment_id = p_comment_id;
	--
/* Expanded to 32000 for WWBUG 1382371 */
l_comment_text	varchar2 (32000);
--
begin
--
open csr_comment;
fetch csr_comment into l_comment_text;
close csr_comment;
--
return l_comment_text;
--
end comment_text;
--------------------------------------------------------------------------------
procedure get_dates(
p_ses_date	 out nocopy date,
p_ses_yesterday_date out nocopy date,
p_start_of_time	 out nocopy date,
p_end_of_time	 out nocopy date,
p_sys_date	 out nocopy date ) is
l_commit number ;
begin

dt_fndate.get_dates(
    p_ses_date           => p_ses_date,
    p_ses_yesterday_date => p_ses_yesterday_date,
    p_start_of_time      => p_start_of_time,
    p_end_of_time        => p_end_of_time,
    p_sys_date           => p_sys_date,
    p_commit             => l_commit);

if l_commit = 1
then
   commit;
end if;

end get_dates;

procedure get_dates(
p_ses_date	 out nocopy date,
p_ses_yesterday_date out nocopy date,
p_start_of_time	 out nocopy date,
p_end_of_time	 out nocopy date,
p_sys_date	 out nocopy date,
p_commit	 out nocopy number) is

--
begin
--
dt_fndate.get_dates(
    p_ses_date           => p_ses_date,
    p_ses_yesterday_date => p_ses_yesterday_date,
    p_start_of_time      => p_start_of_time,
    p_end_of_time        => p_end_of_time,
    p_sys_date           => p_sys_date,
    p_commit             => p_commit);
--
end get_dates;
--------------------------------------------------------------------------------
procedure change_ses_date (
p_ses_date	date,
p_commit out nocopy number) is
--
begin
--
dt_fndate.change_ses_date (p_ses_date, p_commit);
--
end change_ses_date;
--------------------------------------------------------------------------------
procedure delete_ses_rows is
  v_commit number;
begin
  dt_fndate.delete_ses_rows(p_commit => v_commit);
  if v_commit = 1 then
    commit;
  end if;
end delete_ses_rows ;
--------------------------------------------------------------------------------
procedure trace_on(trace_mode in varchar2, session_identifier in varchar2) is
begin

  hr_utility.trace_on(trace_mode,session_identifier) ;

end trace_on ;
--------------------------------------------------------------------------------
procedure trace_off is
begin

  hr_utility.trace_off ;

end trace_off ;
--------------------------------------------------------------------------------
procedure trace(trace_data in varchar2) is
begin

   hr_utility.trace(trace_data) ;

end trace ;
--------------------------------------------------------------------------------
procedure set_location(procedure_name in varchar2, stage in number) is
begin

   hr_utility.set_location(procedure_name,stage);

end set_location;
--------------------------------------------------------------------------------
procedure set_trace_options(p_options in varchar2) is
begin

   hr_utility.set_trace_options(p_options);

end set_trace_options;
--------------------------------------------------------------------------------
-- ADE Procedures
--------------------------------------------------------------------------------
procedure pipe_ade_detail (p_detail IN varchar2) IS
BEGIN
  dbms_pipe.pack_message(p_detail);
END pipe_ade_detail;
--------------------------------------------------------------------------------
procedure reset_pipe_buffer IS
BEGIN
  dbms_pipe.reset_buffer;
END reset_pipe_buffer;
--------------------------------------------------------------------------------
procedure purge_pipe(p_pipename IN varchar2) IS
BEGIN
  dbms_pipe.purge(p_pipename);
END purge_pipe;
--------------------------------------------------------------------------------
procedure send_pipe_message(p_pipename IN varchar2) IS
  l_result integer;
BEGIN
  l_result := dbms_pipe.send_message(p_pipename, 60, 16384);
END send_pipe_message;
--------------------------------------------------------------------------------
procedure putSessionAttributeValue ( p_name in varchar2,
                                     p_value in varchar2,
                                     p_session_id in number) is
pragma AUTONOMOUS_TRANSACTION;
BEGIN
       icx_sec.putSessionAttributeValue(
                 p_name       => p_name,
                 p_value      => p_value,
                 p_session_id => p_session_id);
       commit;
END putSessionAttributeValue;

--
end	hr_gen_pkg;

/
