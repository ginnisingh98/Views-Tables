--------------------------------------------------------
--  DDL for Package EDW_ORGANIZATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_ORGANIZATION_PKG" AUTHID CURRENT_USER AS
/* $Header: hriekorg.pkh 120.1 2005/06/07 05:37:41 anmajumd noship $  */
-- ------------------------
-- Public Functions
-- ------------------------
--
Function INT_ORGANIZATION_fk(
        p_id               in NUMBER := NULL,
        p_instance_code    in VARCHAR2:=NULL) return VARCHAR2;
--
Function Operating_Unit_fk(p_id in NUMBER :=NULL,
                           p_instance_code    in VARCHAR2:=NULL) return VARCHAR2;
--
PRAGMA RESTRICT_REFERENCES(int_organization_fk, WNDS, WNPS, RNPS);
--
PRAGMA RESTRICT_REFERENCES (operating_unit_fk,WNDS, WNPS, RNPS);
--
---------------------------------------------------
-- Function Demand_cls()
-- No function created for demand class because the
-- primary key is simply:  demand class code
---------------------------------------------------
--
END EDW_ORGANIZATION_PKG;

 

/
