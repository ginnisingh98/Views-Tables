--------------------------------------------------------
--  DDL for Package BOM_PA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_PA_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMPAUTS.pls 115.1 2003/06/27 23:26:45 rfarook noship $ */
/***************************************************************************
--
--
--  FILENAME
--
--      BOMPAUTS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_PA_Util
--
--  NOTES
--
--  HISTORY
--
--  27-JUN-03 Refai Farook  Initial Creation
--
--
****************************************************************************/

  Function Get_Lifecycle(p_lifecycle_id NUMBER) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(Get_Lifecycle,WNDS,WNPS);

  Function Get_Phase(p_phase_id NUMBER) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(Get_Phase,WNDS,WNPS);

END BOM_PA_Util;

 

/
