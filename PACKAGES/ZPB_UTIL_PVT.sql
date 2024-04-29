--------------------------------------------------------
--  DDL for Package ZPB_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: ZPBUTILS.pls 120.4 2007/12/04 14:36:23 mbhat noship $ */

-- this procedure returns can return 4 different values in the output variable
-- 0: both queries are identical
-- 1: first query is a subset of second
-- 2: second query is a subset of first
-- 3: both queries are different
PROCEDURE compare_dim_members(p_dim_name IN varchar2,
                              p_first_query IN varchar2,
                              p_second_query IN varchar2,
                              x_equal OUT NOCOPY integer);

procedure AddUsersToAdHocRole(role_name         in varchar2,
                              role_users        in  varchar2);

function CLOBToChar(p_clob     in CLOB) return VARCHAR2;

procedure populate_SVDEFVAR (p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE);

-- This procedure modifies the olap page pool size session parameter
-- setting_id corresponds to ZPB profile parameters.  If the corresponding profile
-- is not set, the page pool size is unchanged
-- 1 = ZPB_OPPS_DATA_MOVE
-- 2 = ZPB_OPPS_DATA_SOLVE
-- 3 = ZPB_OPPS_AW_BUILD
procedure set_opps(setting_id in number, user_id in number);

ZPB_OPPS_DATA_MOVE constant number:= 1;
ZPB_OPPS_DATA_SOLVE constant number:= 2;
ZPB_OPPS_AW_BUILD constant number:= 3;

-- This function returns the current olap page pool size
function get_opps return number;

-- This procedure modifies the olap page pool size session parameter
-- setting it to the passed in parameter
procedure set_opps_spec(setting in number);

procedure exec_ddl(p_cmd varchar2);

END; -- Package spec

/
