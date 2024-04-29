--------------------------------------------------------
--  DDL for Package Body DT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DT_PKG" as
/* $Header: dt.pkb 115.1 2002/12/09 15:18:15 apholt ship $ */
/*
  ===========================================================================
 |               Copyright (c) 1996 Oracle Corporation                       |
 |                       All rights reserved.                                |
  ===========================================================================
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
110.1	03 sep 97	Khabibul	Fixed problem with 255 char width
115.1   09-Dec-2002     A.Holt          NOCOPY Performance Changes for 11.5.9
*/
procedure get_dates
(
    p_ses_date            out nocopy date,
    p_ses_yesterday_date  out nocopy date,
    p_start_of_time       out nocopy date,
    p_end_of_time         out nocopy date,
    p_sys_date            out nocopy date,
    p_commit              out nocopy number
) is
--
begin
--
dt_fndate.get_dates (
	p_ses_date,
	p_ses_yesterday_date,
	p_start_of_time,
	p_end_of_time,
	p_sys_date,
	p_commit);
--
end get_dates;
--
end	DT_PKG;

/
