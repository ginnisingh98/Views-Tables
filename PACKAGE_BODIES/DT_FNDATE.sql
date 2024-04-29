--------------------------------------------------------
--  DDL for Package Body DT_FNDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DT_FNDATE" as
/* $Header: dtfndate.pkb 120.1.12010000.3 2009/08/27 06:51:30 avarri ship $ */
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


 Change List
 -----------
 Date        Name          Vers    Bug No     Description
 -----------+-------------+-------+----------+-------------------------------+
 01-OCT-1993 P.K.Attwood   4.0                First Created.
 03-MAR-1994 P.K.Attwood   4.1                Changed select statement in
                                              get_dates to query
                                              trunc(sysdate). Added
                                              delete_ses_rows procedure.
 13-MAY-1994 P.K.Attwood   3.0                Transferred out nocopy of version 4 DT
                                              into version 3, so all server
                                              side code is in the same place.
 05-OCT-1994 R.M.Fine      30.1               Renamed package to dt_fndate to
                                              conform to naming convention that
                                              all objects begin '<prod>_'.
 30-MAR-1999 P.K.Attwood   110.1   861272     In get_dates corrected setting
                           115.1              g_sys_date when globals
                                              variables have not been set and
                                              a row already exists in
                                              fnd_sessions.
 22-APR-1999 P.K.Attwood   115.2   854170     Rewrote the delete_ses_rows
                                              procedure to remove the join
                                              between FND_SESSIONS and a v$
                                              view.
 13-AUG-1999 P.K.Attwood   115.3              In change_ses_date when no row
                                              is found in FND_SESSIONS added
                                              raise exception.
 22-JUN-2001 P.K.Attwood   115.4   1841141    To support OPS (Oracle Parallel
                                              Server) inside the
                                              delete_ses_rows procedure
                                              changed references from
                                              v$session to gv$session.
 13-SEP-2001 P.K.Attwood   115.5              Added set_effective_date
                                              procedure.
 19-DEC-2001 G.Perry       115.6              Added dbdrv
 31-JAN-2002 G.Sayers      115.7              Added validation to get_dates and
                                              change_ses_date to ensure
                                              g_ses_yesterday_date is set to
                                              null when g_ses_date=01/01/0001
 01-FEB-2002 G.Sayers      115.8              Removed hr_utility commands.
 06-Dec-2002 A.Holt        115.9              NOCOPY Performance Changes for 11.5.9
 09-Feb-2005 K.Tangeeda    115.10             Versions 115.10 and 115.11 contain
                                              the same code as version 115.9
 09-Feb-2005 K.Tangeeda    115.11             This version contains the same
                                              code as the version 115.9
 07-May-2006 V.Kaduban     120.1              Procedure delete_old_ses_rows has
                                              been added which is exact copy of
                                              delete_ses_rows. Existing
                                              delete_ses_rows has been modified
                                              so that all it does is to delete the
                                              row from fnd_sessions for the current
                                              session. Also the procedure
                                              clean_fnd_sessions has been added
                                              which does the same thing as
                                              delete_old_ses_rows but used by
                                              a concurrent program to do that
                                              cleanup periodically.All these
                                              changes are as a part of long term
                                              solution to the bug 4163689.
 14-Aug-2008 avarri     120.2      7260450    Modified delete_old_ses_rows to
                                              resolve the performance issue.
 27-Aug-2009 avarri     120.1.12000000.3      Modified delete_old_ses_rows to
                                              replace fndSessionId.FIRST with 1 and
                                              fndSessionId.LAST with
                                              fndSessionId.COUNT to resolve 8839784
  -----------+-------------+-------+----------+-------------------------------+
*/
--
-- Declare globals to this package
--
  g_ses_date           date;
  g_ses_yesterday_date date;
  g_start_of_time      date;
  g_end_of_time        date;
  g_sys_date           date;
--
  procedure get_dates (p_ses_date           out nocopy date,
                       p_ses_yesterday_date out nocopy date,
                       p_start_of_time      out nocopy date,
                       p_end_of_time        out nocopy date,
                       p_sys_date           out nocopy date,
                       p_commit             out nocopy number) is
    v_commit boolean;
  begin
    v_commit := FALSE;
    if g_ses_date is null then
      --
      -- Only select date fields, if globals have not been set
      --
      begin
        select fs.effective_date
             , fs.effective_date -1
             , to_date('01/01/0001','DD/MM/YYYY')
             , to_date('31/12/4712','DD/MM/YYYY')
             , trunc(sysdate)
          into g_ses_date
             , g_ses_yesterday_date
             , g_start_of_time
             , g_end_of_time
             , g_sys_date
          from fnd_sessions fs
         where fs.session_id = userenv('sessionid');
      exception
        when no_data_found then
          --
          -- Set date fields
          --
          g_ses_date           := trunc(sysdate);
          if g_ses_date =  to_date('01/01/0001', 'DD/MM/YYYY') then
             g_ses_yesterday_date := null;
          else
             g_ses_yesterday_date := g_ses_date - 1;
          end if;
          g_start_of_time      := to_date('01/01/0001', 'DD/MM/YYYY');
          g_end_of_time        := to_date('31/12/4712', 'DD/MM/YYYY');
          g_sys_date           := g_ses_date;
          --
          -- Insert row in fnd_sessions as one does not
          -- already exist.
          --
          insert into fnd_sessions (session_id, effective_date)
            values (userenv('sessionid'), g_ses_date);
          --
          v_commit := TRUE;
      end;
    end if;
    --
    if g_ses_date = to_date('01/01/0001', 'DD/MM/YYYY') then
       g_ses_yesterday_date := null;
    else
       g_ses_yesterday_date := g_ses_date - 1;
    end if;
    --
    p_ses_date           := g_ses_date;
    p_ses_yesterday_date := g_ses_yesterday_date;
    p_start_of_time      := g_start_of_time;
    p_end_of_time        := g_end_of_time;
    p_sys_date           := g_sys_date;
    if (v_commit) then
      p_commit := 1;
    else
      p_commit := 0;
    end if;
  end get_dates;
--
--
--
  procedure change_ses_date (p_ses_date in  date,
                             p_commit   out nocopy number) is
    v_commit              boolean;
    no_row_need_to_insert exception;
  begin
    begin
      --
      -- Update row in fnd_sessions
      --
      v_commit := FALSE;
      --
      update fnd_sessions
         set effective_date = trunc(p_ses_date)
       where session_id = userenv('sessionid');
      --
      -- When no row is found in FND_SESSIONS
      -- raise an exception to insert a row.
      --
      if sql%rowcount = 0 then
        raise no_row_need_to_insert;
      end if;
      --
      v_commit := TRUE;
   exception
      when no_row_need_to_insert then
        g_ses_date           := trunc(p_ses_date);
        if g_ses_date = to_date('01/01/0001', 'DD/MM/YYYY') then
           g_ses_yesterday_date := null;
        else
           g_ses_yesterday_date := g_ses_date - 1;
        end if;
        g_start_of_time      := to_date('01/01/0001', 'DD/MM/YYYY');
        g_end_of_time        := to_date('31/12/4712', 'DD/MM/YYYY');
        g_sys_date           := trunc(sysdate);
        --
        -- Insert row in fnd_sessions as one does not
        -- already exist.
        --
        insert into fnd_sessions (session_id, effective_date)
          values (userenv('sessionid'), g_ses_date);
        --
        v_commit := TRUE;
    end;
    --
    -- Update package globals
    --
    g_ses_date           := trunc(p_ses_date);
    if g_ses_date= to_date('01/01/0001', 'DD/MM/YYYY') then
       g_ses_yesterday_date := null;
    else
       g_ses_yesterday_date := g_ses_date - 1;
    end if;
    --
    if (v_commit) then
      p_commit := 1;
    else
      p_commit := 0;
    end if;
  end change_ses_date;
--
--
--
  procedure set_effective_date
  (p_effective_date                in     date     default null
  ,p_do_commit                     in     boolean  default false
  ) is
   v_commit number;
  begin
    change_ses_date(p_ses_date => nvl(p_effective_date, sysdate)
                   ,p_commit   => v_commit);
    if p_do_commit and v_commit = 1 then
      commit;
    end if;
  end set_effective_date;
--
--
--
  procedure delete_ses_rows(p_commit out nocopy number) is
    --
    -- Declare exceptions to be handled
    --
  begin
          delete from fnd_sessions f
            where session_id = userenv('sessionid');
          p_commit := 1;
          if(SQL%ROWCOUNT = 0) then
            p_commit := 0 ;
          end if ;
          exception
          when Others then
            p_commit := 0;
  end delete_ses_rows;
--
--
--
  procedure init_dates is
  begin
    --
    -- Initializes globals to NULL to ensure first call to get_dates
    -- will insert a row into fnd_sessions. (It is not possible to
    -- commit here, so don't insert the row into fnd_sessions.)
    --
    g_ses_date           := NULL;
    g_ses_yesterday_date := NULL;
    g_start_of_time      := NULL;
    g_end_of_time        := NULL;
    g_sys_date           := NULL;
  end init_dates;
--
--
--
  procedure delete_old_ses_rows(p_commit out nocopy number) is
    --
    -- Declare cursors
    --
    cursor csr_fnd_ses is
      select session_id
        from fnd_sessions;
    --
    -- To fix Bug 1841141 the v$ view in the
    -- following cursor was changed to gv$. Inspite of
    -- comments in the RDBMS manual it should be safe
    -- to always reference the gv$ view even when a
    -- non-parallel server is being used. This
    -- is because the v$ views are based on the gv$
    -- views with filter INST_ID = userenv('Instance').
    --
    cursor csr_gv_ses  is
      select audsid
        from gv$session;
    --
    -- Declare exceptions to be handled
    --
    Resource_Busy  exception;
    Pragma Exception_Init(Resource_Busy, -54);
    --
    -- Local variables
    --
    v_exists  varchar2(30);
    TYPE sessionId IS TABLE OF fnd_sessions.session_id%TYPE INDEX BY BINARY_INTEGER;
    fndSessionId  sessionId;
    gvSessionId   sessionId;
    delSessionId  sessionId;
    l_session_exists number := 0;
    k   number := 1;
    bulkFetchRowLimit number := 10000;
  begin
    --
    -- Bug 854170: Changed original delete statement as joins
    -- between delete a v$ view and a standard table are not
    -- supported by the RDBMS.
    -- Original like code:
    --   delete from fnd_sessions f
    --    where not exists (select null
    --                        from v$session s
    --                        where s.audsid = f.session_id);
    --   p_commit := 1;
    --
    -- Attempt to obtain an exclusive lock on the DateTrack date
    -- prompts table. This table lock acts as a gatekeeper to
    -- the FND_SESSIONS delete logic.
    --
    -- When this process obtains the table lock then it should go
    -- on to remove old session rows from FND_SESSIONS. i.e. Where
    -- there is no corresponding row in GV$SESSION. When this
    -- process does not obtain the table lock it indicates that
    -- another process must be performing the FND_SESSIONS delete
    -- logic. So this session does not need to do anything extra.
    --
    begin
      lock table dt_date_prompts_tl in exclusive mode nowait;
      --
      -- If this point is reached then the table lock
      -- has been obtained by this process.
      --
      -- Get all the rows from gv$session using bulk collect.
      --
      open csr_gv_ses;
      fetch csr_gv_ses BULK COLLECT INTO gvSessionId;
      close csr_gv_ses;
      --
      -- For each row in FND_SESSIONS see if a corresponding
      -- row exists in GV$SESSION. When there is no matching
      -- row delete the FND_SESSIONS row.
      --
      open csr_fnd_ses;
      loop
      fetch csr_fnd_ses BULK COLLECT INTO fndSessionId limit bulkFetchRowLimit;
        for i in 1..fndSessionId.COUNT loop
          for j in  1.. gvSessionId.COUNT loop
            if (fndSessionId(i) =  gvSessionId(j)) then
               l_session_exists := 1;
               exit;
            end if;
          end loop;
          --
          if l_session_exists = 0 then
            delSessionId(k) := fndSessionId(i);
            k := k + 1;
          end if;
          l_session_exists := 0;
        end loop;
      exit when csr_fnd_ses%notfound;
      end loop;
      close csr_fnd_ses;
      --
      forall l in 1..delSessionId.count
        delete from fnd_sessions where session_id = delSessionId(l);
      --
      p_commit := 1;
    exception
      when Resource_Busy then
        --
        -- If this point is reached then the table lock
        -- has not been obtained by this process. This
        -- means another process must be currently
        -- performing the FND_SESSIONS delete logic.
        -- So this process does not need to do anything
        -- with the FND_SESSIONS table.
        --
        p_commit := 0;
    end;
  end delete_old_ses_rows;
--
--
--
  procedure clean_fnd_sessions ( errbuf  out nocopy varchar2,
                                 retcode out nocopy varchar2 ) is
    l_commit_flag number;
  begin
    delete_old_ses_rows(l_commit_flag);
    if l_commit_flag = 1 then
      commit;
    end if;
  end clean_fnd_sessions;
--
end dt_fndate;

/
