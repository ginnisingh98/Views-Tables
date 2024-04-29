--------------------------------------------------------
--  DDL for Package PO_INV_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_INV_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_INV_INTEGRATION_GRP.pls 120.1 2005/08/19 16:24:20 dreddy noship $ */

PROCEDURE get_converted_qty(p_api_version    IN NUMBER,
                         p_item_id        IN number,
                         p_from_quantity        IN NUMBER,
                         p_from_unit_of_measure IN VARCHAR2,
                         p_to_unit_of_measure   IN VARCHAR2 ,
                         x_to_quantity    OUT NOCOPY NUMBER,
                         x_return_status  OUT NOCOPY VARCHAR2 ) ;

PROCEDURE within_deviation(p_api_version    IN NUMBER,
                           p_organization_id     IN NUMBER,
                           p_item_id             IN NUMBER,
                           p_pri_quantity        IN NUMBER,
                           p_sec_quantity        IN NUMBER,
                           p_pri_unit_of_measure IN VARCHAR2,
                           p_sec_unit_of_measure IN VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_data       OUT NOCOPY VARCHAR2) ;


END PO_INV_INTEGRATION_GRP;

 

/
