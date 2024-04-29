--------------------------------------------------------
--  DDL for Package RCV_CHARGES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_CHARGES_GRP" AUTHID CURRENT_USER AS
/* $Header: RCVGFSCS.pls 120.4 2005/10/14 04:21:02 sumboh noship $ */

TYPE charge_interface_table_type IS TABLE OF rcv_charges_interface%ROWTYPE INDEX BY PLS_INTEGER;

--
--    API name    : Preprocess_Charges
--    Type        : Group
--    Function    : Derive, default and validate data in charge interface
--                  table for each item transaction interface record.
--    Pre-reqs    :
--    Parameters  :
--    IN          :
--    OUT         :
--    Version     : Initial version     1.0
--    Notes       : Note text
--
Procedure Preprocess_Charges
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_header_record      IN RCV_ROI_PREPROCESSOR.headers_cur%ROWTYPE
, p_transaction_record IN RCV_ROI_PREPROCESSOR.txns_cur%ROWTYPE
);

--
--    API name    : Process_Charges
--    Type        : Group
--    Function    : Populate charge tables with the interface data
--    Pre-reqs    :
--    Parameters  :
--    IN          :
--    OUT         :
--    Version     : Initial version     1.0
--    Notes       : Note text
--
PROCEDURE Process_Charges
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_rhi_id             IN RCV_HEADERS_INTERFACE.header_interface_id%TYPE
, p_rti_id             IN RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE
, p_shipment_header_id IN RCV_SHIPMENT_HEADERS.shipment_header_id%TYPE
, p_shipment_line_id   IN RCV_SHIPMENT_LINES.shipment_line_id%TYPE
);

--
--    API name    : Allocate_Charges
--    Type        : Group
--    Function    : Allocate header level and line level charges
--    Pre-reqs    :
--    Parameters  :
--    IN          :
--    OUT         :
--    Version     : Initial version     1.0
--    Notes       : Note text
--
Procedure Allocate_Charges
( p_charge_table IN OUT NOCOPY PO_CHARGES_GRP.charge_table_type
, p_charge_allocation_table IN OUT NOCOPY PO_CHARGES_GRP.charge_allocation_table_type
, p_charge_interface_table IN OUT NOCOPY charge_interface_table_type
);
END RCV_CHARGES_GRP;

 

/
