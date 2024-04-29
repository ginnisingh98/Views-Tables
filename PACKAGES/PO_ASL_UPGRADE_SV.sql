--------------------------------------------------------
--  DDL for Package PO_ASL_UPGRADE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_UPGRADE_SV" AUTHID CURRENT_USER AS
/* $Header: POXA1LUS.pls 120.1.12010000.1 2008/09/18 12:20:40 appldev noship $*/

/*===========================================================================
  PROCEDURE NAME: 	upgrade_autosource_rules

  DESCRIPTION:		This procedure upgrades the purchasing autosource rules
			to the new mrp sourcing rules.

  PARAMETERS:		NONE

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	8/13/96		created
===========================================================================*/

PROCEDURE upgrade_autosource_rules(
	x_asl_status_id			NUMBER,
	x_usr_upgrade_docs		VARCHAR2
);

END PO_ASL_UPGRADE_SV;

/
