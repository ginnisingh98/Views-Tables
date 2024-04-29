--------------------------------------------------------
--  DDL for Package POS_REQUEST_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_REQUEST_UTILS_PKG" AUTHID CURRENT_USER AS
/*$Header: POSRQUTS.pls 120.4 2005/08/04 12:51:56 bitang noship $ */

-- This procedure is called by Sourcing to invite a supplier to
-- register
PROCEDURE pos_src_register_supplier
  ( p_supplier_reg_id	IN  NUMBER,
    p_org_id            IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    ) ;

-- This procedure is called by Sourcing to create a RFQ Only supplier
PROCEDURE pos_src_approve_rfq_supplier
  ( p_supplier_reg_id	IN  NUMBER,
    x_party_id          OUT NOCOPY NUMBER,
    x_vendor_id         OUT NOCOPY NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    ) ;

PROCEDURE pos_src_get_supplier_det
  (p_supplier_party_id	IN  NUMBER,
   p_org_id             IN  NUMBER,
   x_vendor_id          OUT NOCOPY NUMBER,
   x_party_site_id      OUT NOCOPY NUMBER,
   x_vendor_site_id     OUT NOCOPY NUMBER,
   x_contact_party_id   OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
   ) ;

PROCEDURE pos_get_contact_approved_det
  (p_contact_req_id	IN  NUMBER,
   x_contact_party_id   OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
   ) ;

END POS_REQUEST_UTILS_PKG;

 

/
