--------------------------------------------------------
--  DDL for Package WIP_BIS_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_BIS_COMMON" AUTHID CURRENT_USER AS
/* $Header: wipbcoms.pls 120.0 2005/05/25 08:32:37 appldev noship $ */


/* Public Procedures  */

FUNCTION GET_SEGMENT( str IN VARCHAR2,
                      delim IN VARCHAR2,
                      segment_num IN NUMBER ) return VARCHAR2;

  function Avg_Employee_Num
		       (p_acct_period_id    IN  NUMBER,
			p_organization_id   IN  NUMBER)
  return NUMBER ;


  function get_Legal_Entity return NUMBER ;

  procedure set_Legal_Entity(p_legal_Entity in NUMBER);

  function get_Period_Target
                       (p_calendar      IN  VARCHAR2,
                        p_period_value  IN  VARCHAR2,
                        p_organization_id IN NUMBER,
                        p_indicator     IN VARCHAR2)
  return NUMBER ;


  PRAGMA RESTRICT_REFERENCES (get_Legal_Entity, WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES (get_Period_Target, WNDS, WNPS);


END WIP_BIS_COMMON ;

 

/
