--------------------------------------------------------
--  DDL for Package PO_SETUP_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SETUP_S1" AUTHID CURRENT_USER as
/* $Header: POXSES2S.pls 115.5 2003/07/25 18:01:16 anhuang ship $*/

/*===========================================================================
  PROCEDURE NAME:	get_install_status()

  DESCRIPTION:
	                o PRO - Need to review product installation requirements
		                installed or shared.  waiting for new prod installation
		                strategy
	                o PRO - Check related product installation status. for example,
		                inventory, quality.
  PARAMETERS:           x_inv_status            - Stores the installation status of 'INV' module
                        x_po_status             - Stores the installation status of 'PO' module
                        x_qa_status             - Stores the installation status of 'QA' module
			x_wip_status		- Stores the installation status of Oracle
					          Work in Process.
			x_pa_status		- Stores the installation status of Oracle
						  Project Accounting.
			x_oe_status		- Stores the installation status of Oracle
						  Order Entry.

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVRCMUR.dd
			RCVTXERT.dd
  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE get_install_status(x_inv_status            OUT NOCOPY VARCHAR2,
                             x_po_status             OUT NOCOPY VARCHAR2,
                             x_qa_status             OUT NOCOPY VARCHAR2,
			     x_wip_status	     OUT NOCOPY VARCHAR2,
			     x_oe_status	     OUT NOCOPY VARCHAR2,
			     x_pa_status	     OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	test_get_install_status()

  DESCRIPTION:          test the function to get the install status

  PARAMETERS:

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVRCMUR.dd
			RCVTXERT.dd
  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE test_get_install_status;

/*===========================================================================
  PROCEDURE NAME:	get_eam_startup()

  DESCRIPTION:
	                o x_eam_install_status stores the installation stuts of EAM

	                o x_eam_profile stores the value of the profile
					PO: Enable Direct Delivery To Shop floor

  REFERENCED BY:	init_po_control_block, POXCOSEU.pld

===========================================================================*/

PROCEDURE get_eam_startup   (x_eam_install_status    OUT NOCOPY VARCHAR2,
                             x_eam_profile           OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       get_oke_startup()

  DESCRIPTION:        1.x_oke_install_status stores the installation stuts
	              of OKE
  REFERENCED BY:        init_po_control_block, POXCOSEU.pld
===========================================================================*/

PROCEDURE get_oke_startup    (x_oke_install_status    OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       get_gms_startup()

  DESCRIPTION:     1.x_gms_install_status stores the installation stuts
		      of GMS
  REFERENCED BY:        init_po_control_block, POXCOSEU.pld
===========================================================================*/

PROCEDURE get_gms_startup    (x_gms_install_status    OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       get_sourcing_startup()

  DESCRIPTION:     Requisition To Sourcing FPH
                   x_pon_install_status stores the installation status
		      of sourcing product
  REFERENCED BY:        init_po_control_block, POXCOSEU.pld
===========================================================================*/

PROCEDURE get_sourcing_startup    (x_pon_install_status    OUT NOCOPY VARCHAR2);

FUNCTION get_services_enabled_flag RETURN VARCHAR2;           -- <SERVICES FPJ>


END PO_SETUP_S1;

 

/
