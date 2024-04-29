--------------------------------------------------------
--  DDL for Package HXT_CHK_BG_AND_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_CHK_BG_AND_UPGRADE_PKG" AUTHID CURRENT_USER as
/* $Header: hxtbgupg.pkh 115.2 2002/06/10 00:38:23 pkm ship      $ */


-------------------------------------------------------------------------------
PROCEDURE hxt_bg_message_insert(P_PHASE IN VARCHAR2, P_TEXT IN VARCHAR2);
-------------------------------------------------------------------------------
FUNCTION hxt_bg_checker return boolean;
-------------------------------------------------------------------------------
PROCEDURE hxt_bg_workplans_update;
-------------------------------------------------------------------------------
PROCEDURE hxt_bg_earnings_update;
-------------------------------------------------------------------------------


end HXT_CHK_BG_AND_UPGRADE_PKG;

 

/
