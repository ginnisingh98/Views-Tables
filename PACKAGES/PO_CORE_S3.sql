--------------------------------------------------------
--  DDL for Package PO_CORE_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CORE_S3" AUTHID CURRENT_USER AS
/* $Header: POXCOC3S.pls 115.2 2002/11/23 03:32:28 sbull ship $*/

/*===========================================================================
  PACKAGE NAME:		PO_CORE_S3

  DESCRIPTION:

  CLIENT/SERVER:	Server

  HISTORY:

  LIBRARY NAME:

  OWNER:

  PROCEDURE NAMES:      get_window_org_sob

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	get_window_org_sob

  DESCRIPTION:		Based on whether the calling form supports true
			multi-org (e.g. the Receiving forms in 10SC) or
			is single org (e.g. Purchase Orders), retrieve
			either the appropriate menu org code or sob short
			name.


  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:		If the form is true multiorg, find the org code
			associated with the MANUFACTURING_ORG_ID profile
			option setting.

			If the form is single-org, but it is operating as
			multi-org using the 10.6 org_id column, then return
			the org code associated with the org_id in
			purchasing system parameters.

			If the form is single-org and is being run in a
			single-org context, find the set of books short name
			associated with the sob specified in financials
			system parameters.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	01-NOV-95	LBROADBE
===========================================================================*/
PROCEDURE get_window_org_sob(x_multi_org_form_flag IN OUT NOCOPY BOOLEAN,
			     x_org_sob_id	   IN OUT NOCOPY NUMBER,
			     x_org_sob_name	   IN OUT NOCOPY VARCHAR2);

END PO_CORE_S3;

 

/
