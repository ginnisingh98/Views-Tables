--------------------------------------------------------
--  DDL for Package PQH_DE_DETACH_WP_SP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_DETACH_WP_SP_PKG" AUTHID CURRENT_USER as
/* $Header: pqhdedsp.pkh 115.0 2002/04/03 02:32:35 pkm ship        $ */
/*---------------------------------------------------------------------------------------------+
                            Procedure DELETE_STELLEN_PLAN
 ----------------------------------------------------------------------------------------------+
 Description:
  This Procedure is called for OA Framework pages of Stellen Processing to delete
  Stellen Plan Item Attached to Workplace
   1. Find if the Stelle of Stellen Plan Item are Attached to Workplace
   2. Delete the attachment from Position Extra Information 'DE_PQH_WRKPLC_STELLE_LINK'
 In Parameters:
   1. Workplace Id
   2. Stellen Plan Id
 Post Success:
      Deleted the Workplace attachments of Stellens in the Stellen Plan Item
      from Extra Position Information
-------------------------------------------------------------------------------------------------*/
PROCEDURE DELETE_STELLEN_PLAN(pWrkplc_id IN NUMBER ,pStellen_Plan_id IN NUMBER);
 END PQH_DE_DETACH_WP_SP_PKG;

 

/
