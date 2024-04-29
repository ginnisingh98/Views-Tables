--------------------------------------------------------
--  DDL for Package WF_WORKLIST_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_WORKLIST_ENGINE" AUTHID CURRENT_USER as
/* $Header: wfwrks.pls 120.1 2005/07/02 02:53:07 appldev ship $ */

type colRecType is record (
  name       varchar2(320),
  def_type   varchar2(8),            /* SELECT, WHERE, ORDER */
  value_type varchar2(8),            /* NUMBER, VARCHAR, DATE */
  col_type   varchar2(8),            /* BASE, SEND, RESPOND */
  text_value   varchar2(4000)
);

type colTabType is table of colRecType index by binary_integer;

type wrkRecType is record (
  nid        number,
  priority   number,
  locked_by  varchar2(320),
  status     varchar2(8),
  language   varchar2(4),
  result_type varchar2(30),
  more_resp_req  boolean,
  attach_present boolean,
  col01      varchar2(4000),
  col02      varchar2(4000),
  col03      varchar2(4000),
  col04      varchar2(4000),
  col05      varchar2(4000),
  col06      varchar2(4000),
  col07      varchar2(4000),
  col08      varchar2(4000),
  col09      varchar2(4000),
  col10      varchar2(4000),
  col11      varchar2(4000),
  col12      varchar2(4000),
  col13      varchar2(4000),
  col14      varchar2(4000),
  col15      varchar2(4000),
  col16      varchar2(4000),
  col17      varchar2(4000),
  col18      varchar2(4000),
  col19      varchar2(4000),
  col20      varchar2(4000),
  col21      varchar2(4000),
  col22      varchar2(4000),
  col23      varchar2(4000),
  col24      varchar2(4000),
  col25      varchar2(4000),
  col26      varchar2(4000),
  col27      varchar2(4000),
  col28      varchar2(4000),
  col29      varchar2(4000),
  col30      varchar2(4000)
);

type wrkTabType is table of wrkRecType index by binary_integer;

debug boolean := FALSE;
max_expand_roles pls_integer := 10;  -- maximum number of roles got expanded

--
-- List
--   Populate a plsql table with query values.
-- IN
--   startrow   - the Nth row that you want to start your query.
--   numrow     - the number of rows that you want to get back.
--   colin      - column definition including query criteria.
-- OUT
--   totalrow   - total number of rows returned by such query.
--   colout     - plsql table contains the query values.
--
procedure List(
  startrow   in  number,
  numrow     in  number,
  colin      in  colTabType,
  totalrow   out nocopy number,
  colout     out nocopy wrkTabType);

--
-- Debug_On
--   Turn on debug info.  You must set serveroutput on in sqlplus session.
--
procedure debug_on;

--
-- Debug_Off
--   Turn off debug info.
--
procedure debug_off;

--
-- GetRoleClause3 (Internal Public)
--   For use only by "Advanced Worklist" in Self Service Framework.
--   Based on GetRoleClause and GetRoleClause2
--   Returns the expanded roles list separated by commas.
--
function GetRoleClause3(
name   in varchar2
) return varchar2;

end WF_WORKLIST_ENGINE;

 

/
