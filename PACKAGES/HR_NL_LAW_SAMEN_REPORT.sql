--------------------------------------------------------
--  DDL for Package HR_NL_LAW_SAMEN_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_LAW_SAMEN_REPORT" AUTHID CURRENT_USER AS
/* $Header: pernllsr.pkh 115.5 2002/08/24 14:17:48 gpadmasa noship $ */
--

TYPE HQOrgTableType is record
  (
   total                NUMBER
  ,ls_total 		NUMBER
  ,acht_total 		NUMBER
  ,full_time 		NUMBER
  ,acht_full_time 	NUMBER
  ,part_time 		NUMBER
  ,acht_part_time 	NUMBER
  ,total_hired 		NUMBER
  ,acht_hired 		NUMBER
  ,terminated           NUMBER
  ,acht_terminated      NUMBER
  ,current_total        NUMBER
  ,last_acht_total      NUMBER
  ,last_perc_acht       NUMBER
  ,perc_acht            NUMBER
  ,perc_full_time       NUMBER
  ,perc_acht_ftime      NUMBER
  ,perc_part_time       NUMBER
  ,perc_acht_ptime      NUMBER
  ,perc_acht_hired      NUMBER
  ,perc_acht_term       NUMBER
   );

   TYPE HQOrgTable is TABLE of HQOrgTableType
Index by binary_integer;
--
HQOrgData HQOrgTable;
--
function get_total(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_total,WNDS,WNPS);
--
function get_ls_total(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_ls_total,WNDS,WNPS);
--
function get_acht_total(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_acht_total,WNDS,WNPS);
--
function get_full_time(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_full_time,WNDS,WNPS);
--
function get_acht_full_time(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_acht_full_time,WNDS,WNPS);
--
function get_part_time(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_part_time,WNDS,WNPS);
--
function get_acht_part_time(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_acht_part_time,WNDS,WNPS);

function get_total_hired(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_total_hired,WNDS,WNPS);
--
function get_acht_hired(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_acht_hired,WNDS,WNPS);
--
function get_terminated(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_terminated,WNDS,WNPS);
--
function get_acht_terminated(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_acht_terminated,WNDS,WNPS);
--
function get_current_total(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_current_total,WNDS,WNPS);
--
function get_last_acht_total(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_last_acht_total,WNDS,WNPS);
--
function get_last_perc_acht(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_last_perc_acht,WNDS,WNPS);
--
function get_perc_acht(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_perc_acht,WNDS,WNPS);

function get_perc_full_time(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_perc_full_time,WNDS,WNPS);
--
function get_perc_acht_ftime(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_perc_acht_ftime,WNDS,WNPS);
--
function get_perc_part_time(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_perc_part_time,WNDS,WNPS);
--
function get_perc_acht_ptime(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_perc_acht_ptime,WNDS,WNPS);
--
function get_perc_acht_hired(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_perc_acht_hired,WNDS,WNPS);
--
function get_perc_acht_term(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_perc_acht_term,WNDS,WNPS);
--
procedure populate_lawsamen_table
( P_BUSINESS_GROUP_ID         IN NUMBER
, P_TOP_ORGANIZATION_ID       IN NUMBER
, P_ORGANIZATION_STRUCTURE_ID IN NUMBER
, P_ROLL_UP              	  IN VARCHAR2
, P_REPORT_YEAR               IN NUMBER
, P_REGION                    IN VARCHAR2);

procedure calculate_values
(   P_REPORT_YEAR                 IN NUMBER
  , P_ORGANIZATION_ID             IN NUMBER
  , P_BUSINESS_GROUP_ID           IN NUMBER
  , P_TOPORG_ID                   IN NUMBER);

END HR_NL_LAW_SAMEN_REPORT;


 

/
