--------------------------------------------------------
--  DDL for Package WMS_RETURN_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RETURN_SV" AUTHID CURRENT_USER AS
/* $Header: WMSRETNS.pls 120.0.12010000.2 2013/01/29 17:17:55 ssingams ship $ */

TYPE t_genref IS REF CURSOR;

/* Called from INVRCVFB.pls
** This procedure is used to unpack LPN for Return To Vendor and Correction
** Transactions with parent transaction type = RECEIVING as Inventory Manager
** is not called for these transactions.
*/

PROCEDURE txn_complete(
                          p_group_id      	IN  NUMBER,
                          p_txn_status    	IN  VARCHAR2, -- TRUE/FALSE
                          p_txn_mode      	IN  VARCHAR2, -- ONLINE/IMMEDIATE
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER);

/*
** This Procedure is called from the Returns/Corrections Form to Mark the LPN Contents
** that are selected for return/correction.
*/

PROCEDURE mark_returns (
                       x_return_status        OUT NOCOPY VARCHAR2,
                       x_msg_count            OUT NOCOPY NUMBER,
                       x_msg_data             OUT NOCOPY VARCHAR2,
                       p_rcv_trx_interface_id IN NUMBER,
                       p_ret_transaction_type IN VARCHAR2,
                       p_lpn_id               IN NUMBER,
                       p_item_id              IN NUMBER,
                       p_item_revision        IN VARCHAR2,
                       p_quantity             IN NUMBER,
                       p_uom                  IN VARCHAR2,
                       p_serial_controlled    IN NUMBER,
                       p_lot_controlled       IN NUMBER,
                       p_org_id               IN NUMBER,
                       p_subinventory         IN VARCHAR2,
                       p_locator_id           IN NUMBER
                       );

/*
--16197273
--Description:API to unmark the wms_lpn_contents table at the time of processing new rti/mti.
--This api will be called from RTV specific package :RCVWSHIB.pls
*/

PROCEDURE unmark_returns (
                       x_return_status        OUT NOCOPY VARCHAR2,
                       x_msg_count		      	OUT NOCOPY NUMBER,
                       x_msg_data		      	OUT NOCOPY VARCHAR2,
                       p_rcv_trx_interface_id IN NUMBER,
                       p_ret_transaction_type IN VARCHAR2,
                       p_lpn_id               IN NUMBER,
                       p_item_id              IN NUMBER,
                       p_item_revision        IN VARCHAR2,
                       p_org_id               IN NUMBER,
                       p_lot_number           IN VARCHAR2  );



/*
--16197273
--Description:API to create container WDD and WDA  for Return order.
--This api will be called from RTV specific package :RCVWSHIB.pls

*/

PROCEDURE Create_Update_Containers_RTV (
          x_return_status OUT NOCOPY VARCHAR2
          ,x_msg_count     OUT NOCOPY NUMBER
          , x_msg_data      OUT NOCOPY VARCHAR2
          , p_interface_txn_id   IN   NUMBER
        , p_wdd_table WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type

);

/*
 --16197273
 --Description;API created to do post TM updates from WMS side .

 */

PROCEDURE perform_post_TM_wms_updates (
                    x_return_status        OUT NOCOPY VARCHAR2,
                    p_rcv_trx_interface_id IN NUMBER   ) ;

/*
** This Procedure is called from the Corrections Form to Pack and Mark the LPN Contents
** that are selected for Positive Correction on RECEIVE/RETURN TO VENDOR/RETURN TO CUSTOMER
*/

PROCEDURE PACK_INTO_RECEIVING (	x_return_status	   	OUT NOCOPY VARCHAR2,
				x_msg_count		OUT NOCOPY NUMBER,
				x_msg_data		OUT NOCOPY VARCHAR2,
				p_rcv_trx_interface_id 	IN NUMBER,
				p_ret_transaction_type 	IN VARCHAR2,
				p_lpn_id 		IN NUMBER,
				p_item_id 		IN NUMBER,
				p_item_revision 	IN VARCHAR2,
				p_quantity 		IN NUMBER,
				p_uom 			IN VARCHAR2,
				p_serial_controlled 	IN NUMBER,
				p_lot_controlled 	IN NUMBER,
				p_org_id 		IN NUMBER
				);

/*
** This procedure is called from Mobile Returns when the input LPN
** is totally marked for Return.
*/

PROCEDURE PROCESS_WHOLE_LPN_RETURN (
                           x_return_status        OUT NOCOPY VARCHAR2,         --1
                           x_msg_count            OUT NOCOPY NUMBER,           --2
                           x_msg_data             OUT NOCOPY VARCHAR2,         --3
                           p_org_id               IN  NUMBER,           --4
                           p_lpn_id               IN  NUMBER,           --5
                           p_txn_proc_mode        IN  VARCHAR2,         --6
                           p_group_id             IN  NUMBER            --7
                           );

/*
** This procedure is called from Mobile Returns when the input LPN
** is partially marked for Return.
*/

PROCEDURE PROCESS_RETURNS (
                          x_return_status        OUT NOCOPY VARCHAR2,		--1
                          x_msg_count            OUT NOCOPY NUMBER,		--2
                          x_msg_data             OUT NOCOPY VARCHAR2,		--3
                          p_org_id               IN  NUMBER,		--4
                          p_lpn_id               IN  NUMBER,		--5
                          p_item_id              IN  NUMBER,		--6
                          p_item_revision        IN  VARCHAR2,		--7
                          p_uom                  IN  VARCHAR2,		--8
                          p_lot_code	         IN  VARCHAR2,		--9
                          p_serial_code          IN  VARCHAR2,		--10
                          p_quantity             IN  NUMBER,		--11
                          p_serial_controlled    IN  NUMBER,		--12
                          p_lot_controlled       IN  NUMBER,		--13
                          p_txn_proc_mode        IN  VARCHAR2,      --14
                          p_group_id             IN  NUMBER,        --15
                          p_to_lpn_id		  	 IN  NUMBER		    --16
                          );

/*
** This procedure is called from Mobile Returns to determine the
** Receiving Processing Mode and Group ID from sequence that are used
** to stamp on RTI. This single wrapper procedure is created so that Mobile
** Returns visits Database only once to get both Receiving Processing Mode
** and Group ID.
*/

PROCEDURE GET_TRX_VALUES(
                          transaction_processor_value OUT NOCOPY VARCHAR2,
                          group_id 		    OUT NOCOPY NUMBER);


/*
** This procedure is called from Mobile Returns to launch the Receiving
** Processor after setting the input group ID and receiving processing mode.
*/

PROCEDURE RCV_PROCESS_WRAPPER(
                                x_return_status OUT NOCOPY VARCHAR2
                ,               x_msg_data      OUT NOCOPY VARCHAR2
                ,               p_trx_proc_mode IN  VARCHAR2
                ,               p_group_id      IN  NUMBER);

/*
** This procedure is called from Mobile Returns to get the suggested 'To LPN'
** if any, for the input From LPN and Item.
*/

PROCEDURE GET_SUGGESTED_TO_LPN(
                x_lpn_lov  OUT  NOCOPY t_genref
        ,       p_org_id   IN   NUMBER
        ,       p_lpn_id   IN   NUMBER
        ,       p_item_id  IN   NUMBER
        ,       p_revision IN   VARCHAR2);

/*
** This Function is called from procedure 'GET_TRX_VALUES' to get Receiving
** Processing Mode.
*/

FUNCTION GET_TRX_PROC_MODE RETURN VARCHAR2;

/* This function is called from LOV Cursor procedure 'GET_RETURN_LPN' of
** WMSLPNLB.pls to determine if the LPN is fully marked or partially marked.
*/

FUNCTION GET_LPN_MARKED_STATUS (
					p_lpn_id IN NUMBER,
					p_org_id IN NUMBER) RETURN VARCHAR2;

g_pkg_name varchar2(30) := 'WMS_RETURN_SV';

/* This procedure is used to create a reservation during a Return. Called
** from WMSTXERE.pld after creating an rcv_transaction_interface_record
*/
  PROCEDURE CREATE_RETURN_RESV(
			       x_return_status     OUT NOCOPY VARCHAR2,
			       x_msg_count         OUT NOCOPY VARCHAR2,
			       x_msg_data          OUT NOCOPY VARCHAR2,
			       p_org_id            IN NUMBER,
			       p_item_id           IN NUMBER,
			       p_revision          IN VARCHAR2,
			       p_subinventory_code IN VARCHAR2,
			       p_locator_id        IN NUMBER,
			       p_lpn_id            IN NUMBER,
			       p_reservation_qty   IN NUMBER,
			       p_unit_of_measure   IN VARCHAR2,
			       p_requirement_date  IN DATE,
			       p_dem_src_type_id   IN NUMBER,
			       p_dem_src_hdr_id    IN NUMBER,
			       p_dem_src_line_id   IN NUMBER,
			       p_intf_txn_id       IN NUMBER DEFAULT NULL);

END;

/
