--------------------------------------------------------
--  DDL for Package RCV_SETUP_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_SETUP_S2" AUTHID CURRENT_USER AS
/* $Header: RCVSTS2S.pls 120.0 2005/06/01 21:04:37 appldev noship $*/

/*===========================================================================
  FUNCTION NAME: get_receiving_flags()

  DESCRIPTION:
	o DEF - For the organization, get the blind receiving flag

  PARAMETERS:

  DESIGN REFERENCES:	RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
PROCEDURE get_receiving_flags (x_org_id  IN  NUMBER,
			     x_blind   OUT NOCOPY VARCHAR2,
                             x_express OUT NOCOPY VARCHAR2,
                             x_cascade OUT NOCOPY VARCHAR2,
                             x_unordered OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	get_startup_values()

  DESCRIPTION:
	o DEF - Get receiving defaults including:
		- control option for allowing routing override
		- transaction processing mode; default to ONLINE
		  if the profile is not set
	        - flag to determine if you should print a receipt traveller
		  at commit time or not
		- setting for auto/manual receipt number generation
		- determine if a receipt number is required or not
		- determine if receipt number should be numeric or alpha
		- control option for allowing express transactions
		- control option for allowing cascade transactions
		- get the org that your receiving in from
		  fsp_financial_system_parameters if inv is not installed
		  otherwise get it from user_profile which is set when
		  you use the change_org form
	o DEF - We need to add a receiving option to default whether this
		checkbox is set on or off when you initially bring up this
		window

  PARAMETERS:		x_org_id	    IN     NUMBER
			x_override_routing  IN OUT VARCHAR2
                        x_transaction_mode  IN OUT VARCHAR2
                        x_receipt_traveller IN OUT VARCHAR2
                        x_receipt_num_code  IN OUT VARCHAR2
                        x_receipt_num_type  IN OUT VARCHAR2
                        x_po_num_type       IN OUT VARCHAR2
			x_allow_express	    IN OUT VARCHAR2
			x_allow_cascade	    IN OUT VARCHAR2
                        x_coa_id            IN OUT NUMBER

  DESIGN REFERENCES:	RCVRCERC.dd

			RCVRCMUR.dd
			RCVTXECO.dd
			RCVTXERE.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE get_startup_values(x_sob_id            IN OUT NOCOPY NUMBER,
                             x_org_id            IN OUT NOCOPY NUMBER,
                             x_org_name             OUT NOCOPY VARCHAR2,
                             x_ussgl_value          OUT NOCOPY VARCHAR2 ,
                             x_override_routing     OUT NOCOPY VARCHAR2,
                             x_transaction_mode     OUT NOCOPY VARCHAR2,
                             x_receipt_traveller    OUT NOCOPY VARCHAR2,
                             x_period_name          OUT NOCOPY VARCHAR2,
                             x_gl_date              OUT NOCOPY DATE,
                             x_category_set_id      OUT NOCOPY NUMBER,
                             x_structure_id         OUT NOCOPY NUMBER,
                             x_receipt_num_code     OUT NOCOPY VARCHAR2,
                             x_receipt_num_type     OUT NOCOPY VARCHAR2,
                             x_po_num_type          OUT NOCOPY VARCHAR2,
			     x_allow_express	    OUT NOCOPY VARCHAR2,
			     x_allow_cascade	    OUT NOCOPY VARCHAR2,
                             x_user_id              OUT NOCOPY NUMBER,
                             x_logonid              OUT NOCOPY NUMBER,
                             x_creation_date        OUT NOCOPY DATE,
                             x_update_date          OUT NOCOPY DATE,
                             x_coa_id               OUT NOCOPY NUMBER,
                             x_org_locator_control  OUT NOCOPY NUMBER,
                             x_negative_inv_receipt_code OUT NOCOPY NUMBER,
                             x_gl_set_of_bks_id     OUT NOCOPY VARCHAR2,
                             x_blind_Receiving_flag OUT NOCOPY VARCHAR2,
			     x_allow_unordered      OUT NOCOPY VARCHAR2);



END RCV_SETUP_S2;

 

/
