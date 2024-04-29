--------------------------------------------------------
--  DDL for Package DT_FNDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DT_FNDATE" AUTHID CURRENT_USER as
/* $Header: dtfndate.pkh 120.1 2006/05/07 00:09:15 vkaduban noship $ */
/*
 Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved

/*

 Name         : dt_fndate
 Author       : P.K.Attwood
 Date Created : 01-OCT-1993
 Synopsis     : This package containes procedures for maintaining the
                session date held in fnd_sessions.
 Contents     : change_ses_date
                get_dates
 Version      : $Revision: 120.1 $

 Change List
 -----------
 Date        Name          Vers    Bug No     Description
 -----------+-------------+-------+----------+-------------------------------+
 01-OCT-1993 P.K.Attwood   4.0                First Created.
 07-MAR-1994 P.K.Attwood   4.1                Added delete_ses_rows procedure.
 13-MAY-1994 P.K.Attwood   3.0                Transferred out of version 4 DT
                                              into version 3, so all server
                                              side code is in the same place.
 05-OCT-1994 R.M.Fine      30.1               Renamed package to dt_fndate to
                                              conform to naming convention that
                                              all objects begin '<prod>_'.
 13-SEP-2001 P.K.Attwood   115.1              Added set_effective_date
                                              procedure.
 13-DEC-2001 G.Perry       115.2              Added dbdrv
 06-dec-2002 A.Holt        115.3              NOCOPY Performance Changes
                                              for 11.5.9
 09-jan-2005 K.Tangeeda    115.4              This version is same as 115.3
 07-May-2006 V.Kaduban     120.1              Added the declaration for
                                              procedures delete_old_ses_rows
                                              and clean_fnd_sessions and
                                              updated the description for
                                              delete_ses_rows as part of long
                                              term solution for Bug 4163689.
 -----------+-------------+-------+----------+-------------------------------+
*/
--
/*
 Name            : get_dates
 Parameters      : No input parameters
 Values Returned : p_ses_date           is set to the session date. The value
                                        will be a trunc(date).
                   p_ses_yesterday_date is set to p_ses_date minus one
                                        date.
                   p_start_of_time      is set to 01-JAN-0001.
                   p_end_of time        is set to 31-DEC-4712.
                   p_sys_date           is set to sysdate.
                   p_commit             will be set to 1 if the procedure
                                        has inserted/updated/deleted rows.
                                        The forms code should then do a
                                        commit. If p_commit is 0 then
                                        a commit is not required.
 Description     : This procedure obtains session date from fnd_sessions.
                   If there is no row in fnd_sessions for this sessions, one
                   will be inserted. p_ses_date will then set to
                   trunc(sysdate).
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
/*
 Name            : change_session_date
 Parameters      : p_ses_date
 Values Returned : p_commit             will be set to 1 if the procedure
                                        has inserted/updated/deleted rows.
                                        The forms code should then do a
                                        commit. If p_commit is 0 then
                                        a commit is not required.
 Description     : Updates the row in fnd_sessions with the new session
                   date.
*/
procedure change_ses_date
(
   p_ses_date in  date,
   p_commit   out nocopy number
);
--
/*
 Name            : set_effective_date
 Parameters      : p_effective_date
                   p_do_commit
 Values Returned : None
 Description     : Acts as a cover procedure to change_ses_date.
                   Inserts or updates a row into FND_SESSIONS for the
                   current session. If the p_effective_date parameter
                   is provided the row will be modified with
                   a truncated version of that date. If p_effective_date
                   is set to null then trunc(sysdate) will be used.
                   If p_do_commit is set to true this procedure will
                   issue a commit when required. If p_do_commit is set
                   to false this procedure will not issue a commit.
                   It is then the calling code's responsibility to issue
                   a commit as soon as possible. Otherwise there is
                   a risk of the internal package global variables
                   getting out of synchronisation with the
                   FND_SESSIONS column values.

*/
procedure set_effective_date
  (p_effective_date                in     date     default null
  ,p_do_commit                     in     boolean  default false
  );
--
/*
 Name            : delete_ses_rows
 Parameters      : None
 Values Returned : p_commit             Will be set to 1 if the procedure
                                        has deleted any row from fnd_sessions.
 Description     : Deletes the row in fnd_sessions table corresponding to the
                   current session. If a successful row deletion takes place
                   then the parameter p_commit is set to 1, otherwise it is
                   set to 0. The calling form issues a commit if the value
                   of p_commit is 1.
*/
procedure delete_ses_rows
(
   p_commit     out nocopy number
) ;
--
/*
 Name            : delete_old_ses_rows
 Parameters      : None
 Values Returned : p_commit             will be set to 1 if the procedure
                                        has deleted rows from fnd_sessions.
                                        The forms code should then do a
                                        commit. If p_commit is 0 then
                                        a commit is not required.
 Description     : Removes old rows from fnd_sessions. i.e. Rows where the
                   corresponding sql session no longer exists. The row for
                   this session is NOT deleted.
*/
procedure delete_old_ses_rows
(
   p_commit   out nocopy number
);
--
/*
 Name            : clean_fnd_sessions
 Parameters      : None
 Values Returned : errbuf,retcode       The procedure is used as the
                                        executable by a concurrent program
                                        which removes old rows from
                                        fnd_sessions. These are
                                        the out parameters that are
                                        mandatory for any executable.
 Description     : Does the same thing as delete_old_ses_rows
                   but used by a concurrent program for doing that
                   periodically.
*/
procedure clean_fnd_sessions
(
   errbuf  out nocopy varchar2,
   retcode out nocopy varchar2
);
end dt_fndate;

 

/
