--------------------------------------------------------
--  DDL for Package FTE_FPA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_FPA_UTIL" AUTHID CURRENT_USER AS
/* $Header: FTEFPUTS.pls 120.1 2005/10/18 10:08:17 samuthuk noship $ */

PROCEDURE GET_PAYMENT_METHOD(
			     p_init_msg_list IN  VARCHAR2 default FND_API.G_FALSE,
			     p_invoice_header_id  in NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
			     x_return_status OUT NOCOPY VARCHAR2,
		 	     x_payment_method OUT NOCOPY VARCHAR2);


PROCEDURE CALCULATE_PO_FREIGHT(p_bol_no IN VARCHAR2,
                                p_inv_header_id IN NUMBER,
				p_mode_of_transport IN VARCHAR2);


PROCEDURE callDBI
(p_invoice_header_id  IN    NUMBER,
 p_dml_type           IN    VARCHAR2,
 p_return_status      OUT NOCOPY   VARCHAR2);

  PROCEDURE Get_Legal_Entity(p_org_id IN NUMBER,
                             x_legal_entity_id OUT NOCOPY NUMBER,
			     x_return_status   OUT NOCOPY VARCHAR2,
			     x_msg_data  OUT NOCOPY  VARCHAR2,
			     x_msg_count  OUT NOCOPY NUMBER);



PROCEDURE Update_Status(itemtype  IN  		VARCHAR2,
                        itemkey   IN  		VARCHAR2,
                        actid     IN  		NUMBER,
                        funcmode  IN  		VARCHAR2,
                        resultout OUT NOCOPY 	VARCHAR2);



PROCEDURE GET_FRACCT_CCID
(
        itemtype        IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        result      OUT NOCOPY VARCHAR2);

PROCEDURE LOG_FAILURE_REASON(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_parent_name		  IN	 VARCHAR2,
			p_parent_id		  IN	 NUMBER,
			p_failure_type		  IN	 VARCHAR2,
			p_failure_reason	  IN	 VARCHAR2,
	        	x_return_status           OUT   NOCOPY VARCHAR2,
	        	x_msg_count               OUT   NOCOPY NUMBER,
	        	x_msg_data                OUT   NOCOPY VARCHAR2);


FUNCTION START_FRACCT_WF_PROCESS
(
    p_carrier_id        IN              NUMBER,
    p_ship_from_org_id  IN              NUMBER,
    p_ship_to_org_id    IN              NUMBER,
    p_supplier_id       IN              NUMBER,
    p_supplier_site_id  IN              NUMBER,
    p_trip_id           IN              NUMBER,
    p_delivery_id       IN              NUMBER,
    x_return_ccid       OUT     NOCOPY  NUMBER,
    x_concat_segs       OUT     NOCOPY  VARCHAR2,
    x_concat_ids        OUT     NOCOPY  VARCHAR2,
    x_concat_descrs     OUT     NOCOPY  VARCHAR2,
    x_msg_count         OUT     NOCOPY  NUMBER,
    x_msg_data          OUT     NOCOPY  VARCHAR2)
RETURN VARCHAR2;

END FTE_FPA_UTIL;

 

/
