--------------------------------------------------------
--  DDL for Package RCV_PROCESSOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_PROCESSOR_PVT" AUTHID CURRENT_USER AS
/* $Header: RCVPROCS.pls 120.0.12010000.1 2008/07/24 14:36:25 appldev ship $ */
--
-- Purpose: APIs called from the receiving processor.
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- pparthas    08/31/01 Created Package
--
--
cursor lpn_grps_cur (x_request_id number, x_group_id NUMBER) is
select distinct lpn_group_id
from rcv_transactions_interface
where (processing_request_id is null or processing_request_id=x_request_id)
and   group_id = decode(x_group_id, 0, group_id, x_group_id)
and processing_status_code = 'RUNNING'
and lpn_group_id is not null;

PROCEDURE INSERT_RCV_LOTS_SUPPLY
(
p_api_version          IN NUMBER    ,
p_Init_Msg_List        IN VARCHAR2  ,
x_return_status        OUT NOCOPY VARCHAR2,
p_interface_transaction_id IN NUMBER ,
p_shipment_line_id IN NUMBER ,
p_supply_source_id IN NUMBER,
p_source_type_code IN VARCHAR2,
p_transaction_type IN VARCHAR2);

PROCEDURE INSERT_RCV_SERIALS_SUPPLY
(
p_api_version              IN NUMBER    ,
p_Init_Msg_List            IN VARCHAR2  ,
x_return_status            OUT NOCOPY VARCHAR2,
p_interface_transaction_id IN NUMBER ,
p_shipment_line_id IN NUMBER ,
p_supply_source_id IN NUMBER,
p_source_type_code         IN VARCHAR2,
p_transaction_type         IN VARCHAR2);


PROCEDURE SPLIT_SERIAL_NUMBER (
        p_sequence   IN     VARCHAR2,
        x_prefix     OUT    NOCOPY VARCHAR2,
        x_number     OUT    NOCOPY NUMBER);


PROCEDURE UPDATE_RCV_LOTS_SUPPLY
(
p_api_version          IN NUMBER    ,
p_Init_Msg_List        IN VARCHAR2  ,
x_return_status        OUT NOCOPY VARCHAR2,
p_interface_transaction_id IN NUMBER,
p_transaction_type     IN Varchar2,
p_shipment_line_id     IN number,
p_source_type_code     IN Varchar2,
p_parent_supply_id        IN number,
p_correction_type      IN Varchar2);


PROCEDURE UPDATE_RCV_SERIALS_SUPPLY
(
p_api_version          IN NUMBER    ,
p_Init_Msg_List        IN VARCHAR2  ,
x_return_status        OUT NOCOPY VARCHAR2,
p_interface_transaction_id IN NUMBER,
p_transaction_type     IN Varchar2,
p_shipment_line_id     IN number,
p_source_type_code     IN Varchar2,
p_parent_supply_id        IN number,
p_correction_type      IN Varchar2);


PROCEDURE INSERT_LOT_SUPPLY(p_interface_transaction_id IN number,
			    p_supply_type_code IN VARCHAR2,
			    p_supply_source_id IN number,
			    x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_SERIAL_SUPPLY(p_interface_transaction_id IN number,
			       p_lot_number IN Varchar2,
			       p_serial_number IN Varchar2,
			       p_supply_type_code IN VARCHAR2,
			       p_supply_source_id IN number,
			       x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_LOT_TRANSACTIONS(p_interface_transaction_id IN number,
				  p_lot_context IN Varchar2,
				  p_lot_context_id IN number,
				  p_source_transaction_id IN number,
				  p_correction_transaction_id IN number,
                                  p_negate_qty  IN VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_LPN_GROUPS (	p_request_id in number,
								p_group_id in number);

END RCV_PROCESSOR_PVT;

/
