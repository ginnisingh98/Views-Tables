--------------------------------------------------------
--  DDL for Package PO_IP_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_IP_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_IP_INTEGRATION_GRP.pls 120.1 2005/07/26 14:32 mbhargav noship $ */

PROCEDURE get_mapped_ip_category
( p_po_category_id IN NUMBER,
  x_ip_category_id OUT nocopy NUMBER
);

PROCEDURE get_mapped_po_category
( p_ip_category_id IN NUMBER,
  x_po_category_id OUT nocopy NUMBER
);

PROCEDURE get_shopping_category_from_id
( p_ip_category_id IN NUMBER,
  p_language IN VARCHAR2,
  x_shopping_category_name OUT nocopy VARCHAR2
);

END PO_IP_INTEGRATION_GRP;

 

/
