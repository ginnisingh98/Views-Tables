--------------------------------------------------------
--  DDL for Package POR_RCV_TRANSACTION_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_RCV_TRANSACTION_SV" AUTHID CURRENT_USER AS
/* $Header: PORRCVTS.pls 115.1 2002/03/06 10:36:42 pkm ship       $*/

/******************************************************************
 **  Function :     insert_transaction_interface
 **  Description :  This is a function called from Java layer
 **                 currently used by return items and correction on the web.
 ******************************************************************/

function insert_transaction_interface(
		p_Transaction_Type       in varchar2,
                p_caller                 in varchar2,
		p_Parent_Transaction_Id  in number,
                p_Quantity               in number,
                p_Group_Id               in number,
                p_Group_Id2              in number,
                p_Transaction_Date       in date      default sysdate,
                p_Unit_Of_Measure        in varchar2  default null,
                p_Return_Reason_Id       in number    default null,
                p_RMA_reference          in varchar2  default null,
                p_Subinventory           in varchar2  default null,
                p_Receiving_Location_Id  in number    default null,
		p_Comments		 in varchar2  default null) return number;

/*************************************************************
 **  Function :     Process_Transactions
 **  Description :  This is a procedure that validates
 **                 the transactions and call_txn_processor.
 **************************************************************/

function process_transactions(p_group_id  in number,
                              p_group_id2 in number,
                              p_caller    in varchar2)
return number;

function get_net_delivered_qty(p_txn_id in number) return number;
PRAGMA   RESTRICT_REFERENCES(get_net_delivered_qty, WNDS, WNPS);

function get_net_returned_qty(p_txn_id in number) return number;
PRAGMA   RESTRICT_REFERENCES(get_net_returned_qty, WNDS, WNPS);

function GET_SHIPMENT_NUM(p_order_type_code in varchar2,
                          p_key_id in number)
return varchar2;

end POR_RCV_TRANSACTION_SV;

 

/
