--------------------------------------------------------
--  DDL for Package PO_AP_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AP_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGAPIS.pls 115.0 2004/03/25 06:59:44 axian noship $ */

PROCEDURE get_invoice_numbering_options
(
  p_api_version                 IN  NUMBER,
  p_org_id                      IN  NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2,
  x_msg_data                    OUT NOCOPY VARCHAR2,
  x_buying_company_identifier   OUT NOCOPY VARCHAR2,
  x_gapless_inv_num_flag        OUT NOCOPY VARCHAR2
);
END PO_AP_INTEGRATION_GRP;

 

/
