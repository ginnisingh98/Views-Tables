--------------------------------------------------------
--  DDL for Package PO_CORE_S4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CORE_S4" AUTHID CURRENT_USER AS
/* $Header: POXCOC4S.pls 120.0.12010000.3 2011/03/03 06:54:33 sbontala ship $*/

/*===========================================================================
  PACKAGE NAME:		PO_CORE_S4

  DESCRIPTION:

  CLIENT/SERVER:	Server

  HISTORY:

  LIBRARY NAME:

  OWNER:

  PROCEDURE NAMES:      cleanup_po_tables
		        get_mtl_parameters

===========================================================================*/
---<Bug: 11071489 REQ_AUTOCREATE- Start>--

  TYPE p_parameter_record IS RECORD (name VARCHAR2(100), value VARCHAR2(50));

  TYPE p_parameter_list IS TABLE OF p_parameter_record INDEX BY BINARY_INTEGER;

---<REQ_AUTOCREATE- End>--


/*===========================================================================
  PROCEDURE NAME:	cleanup_po_tables

  DESCRIPTION:		this script replaces autosubmit for 10sc.
                        it removes inactive notifications and invalid
                        data from the interface tables

  PARAMETERS:

  DESIGN REFERENCES:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	04-apr-96	K MIller
===========================================================================*/

PROCEDURE cleanup_po_tables;

/*===========================================================================
  PROCEDURE NAME:	get_mtl_parameters()

  DESCRIPTION:		this procedure retrieves the parameters from the
                        material parameters table.

  PARAMETERS:

  DESIGN REFERENCES:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	12-17-1996	WLAU
===========================================================================*/

PROCEDURE  get_mtl_parameters  (x_org_id		     IN      NUMBER,
				x_org_code                   IN      VARCHAR2,
				x_project_reference_enabled  IN OUT NOCOPY  NUMBER,
			        x_project_control_level      IN OUT NOCOPY  NUMBER);
---<Bug: 11071489 REQ_AUTOCREATE- Start>--
/*===========================================================================
  PROCEDURE NAME:	autocreate_business_event()

  DESCRIPTION:		The procedure raises business event for the
                        event name and event paramters passed
===========================================================================*/

PROCEDURE raise_business_event(x_event_name VARCHAR2 ,x_parameter_list IN p_parameter_list);
---<REQ_AUTOCREATE- End>--

END PO_CORE_S4;

/
