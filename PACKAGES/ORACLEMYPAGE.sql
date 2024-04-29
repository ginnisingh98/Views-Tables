--------------------------------------------------------
--  DDL for Package ORACLEMYPAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ORACLEMYPAGE" AUTHID CURRENT_USER as
/* $Header: ICXSEMS.pls 120.0 2005/10/07 12:18:59 gjimenez noship $ */

g_start  varchar2(30);
g_end    varchar2(30);

JAVA_MODE                  constant number := 1;
PLSQL_MODE                 constant number := 2;

function openHTML return varchar2;

function METAtag return varchar2;

function CSStag return varchar2;

procedure Regions;

procedure updateCurrentPageID(
        p_session_id    in      varchar2,
        p_page_id       in      varchar2
);

procedure Home(rmode       in     number,
               i_1         in     varchar2 default NULL,
               i_2         in     varchar2 default NULL,
               home_url    in     varchar2 default NULL,
               i_direct    IN     VARCHAR2 DEFAULT NULL,
               c_sec_grp_id IN    VARCHAR2 DEFAULT NULL); -- mputman hosted update


procedure Home(i_1         in     varchar2 default NULL,
               i_2         in     varchar2 default NULL,
               home_url    in     varchar2 default NULL,
               validate_flag in   varchar2 default 'Y');

procedure DrawTabContent;

/* for rendering portlets with OAS approach
function getRegionURL(
        user_id         in      number,
        session_id      in      number,
	page_id			in		number
) return varchar2;
*/

TYPE plugTable IS TABLE OF varchar2(500) index by binary_integer;

end OracleMyPage;

 

/
