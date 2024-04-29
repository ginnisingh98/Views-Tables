--------------------------------------------------------
--  DDL for Package DT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DT_PKG" AUTHID CURRENT_USER as
/* $Header: dt.pkh 115.1 2002/12/09 15:29:17 apholt ship $ */
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
110.1	03 Sep 97	Khabibul	Fixed problem with 255 chars width
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
);
--
end	DT_PKG;

 

/
