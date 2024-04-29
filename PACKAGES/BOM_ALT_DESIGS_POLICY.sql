--------------------------------------------------------
--  DDL for Package BOM_ALT_DESIGS_POLICY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_ALT_DESIGS_POLICY" AUTHID DEFINER
/* $Header: BOMSPOLS.pls 120.0 2005/05/25 05:06:25 appldev noship $*/
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--    BOMSPOLB.pls
--
--  DESCRIPTION
--
--      Package Bom_alt_desigs_policy
--	This is the package used to set the fine-grained security
--	policy for bom_alternate_designators table
--
--  NOTES
--
--  HISTORY
--
--  24-SEP-2003 Deepak Jebar      Initial Creation
--  03-SEP-2004 Hari Gelli        Added constant G_EGO_APPLICATION.
--
AS
   G_EAM_APPLICATION constant NUMBER := 426;
   G_EGO_APPLICATION constant NUMBER := 431;
   PROCEDURE  add_policy;
   procedure  drop_policy;
   FUNCTION   get_alt_predicate( p_namespace in varchar2
				,p_object in varchar2) RETURN VARCHAR2;
END Bom_alt_desigs_policy;

 

/
