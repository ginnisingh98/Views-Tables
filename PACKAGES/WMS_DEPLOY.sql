--------------------------------------------------------
--  DDL for Package WMS_DEPLOY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_DEPLOY" AUTHID CURRENT_USER AS
/* $Header: WMSDEPLS.pls 120.0.12010000.8 2010/01/25 14:31:26 abasheer noship $ */
/*#
 * This package provides routine to obtain the Oracle Warehouse Management
 * (WMS) deployment mode and related Standalone and LSP installation utilities
 * @rep:scope public
 * @rep:product WMS
 * @rep:lifecycle active
 * @rep:displayname WMS Deploy
 * @rep:category BUSINESS_ENTITY WMS_DEPLOY
 */
/*
** -------------------------------------------------------------------------
** To prevent requery of database as much as possible within the same session,
** the following global variables are cached and used suitably:
**
** -------------------------------------------------------------------------
*/


/* function returns the deployment mode based on the profile WMS_DEPLOYMENT_MODE
 * 'I' - Integrated Deployment
 * 'D' - Distributed (Standalone) Deployment
 * 'L' - LSP Deployment
 */
function wms_deployment_mode return varchar2;

/* Returns the Item flex field delimiters.             */
FUNCTION get_item_flex_delimiter
  RETURN VARCHAR2;

/* Returns the Item flex field segment count.          */
FUNCTION get_item_flex_segment_count
  RETURN NUMBER;

TYPE t_in_txn_rec IS RECORD (
                              inventory_item_id  NUMBER,
                              organization_id    NUMBER
                            );

TYPE t_client_rec IS RECORD (
                              client_id      NUMBER,
                              client_name    hz_parties.party_name%type
                            );

/*
** -------------------------------------------------------------------------
** To prevent requery of database as much as possible within the same session,
** the following global variables are cached and used suitably:
**
** g_wms_deployment_mode :
** 	Can be I/D/L based on WMS_DEPLOYMENT_MODE profile option
** -------------------------------------------------------------------------
*/
g_wms_deployment_mode VARCHAR2(2);

/* function returns whether the item / transaction can be costed or not (Y/N)
 * Takes input a record structure with inventory_item_id and organization_id
 */
function Costed_Txn ( p_in_txn_rec IN t_in_txn_rec ) return varchar2;

/* Wrapper of Costed_Txn to obtain whether the item / transaction can be costed or not (Y/N)
 * given Item_id and Org_id
*/
FUNCTION Costed_Txn_For_Item (p_organization_id			NUMBER,
							  p_inventory_item_id		NUMBER
				              ) RETURN VARCHAR2;

/* procedure returns the outsourcer/client information pertaining to transaction details provided
 * Takes input a record structure with inventory_item_id and organization_id
 */
procedure Get_Client_Info ( p_in_txn_rec    IN         t_in_txn_rec,
                            x_client_rec    OUT NOCOPY t_client_rec,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2
                          );


/* Wrapper of Get_Client_Info to obtain Outsourcer_id for a
 * given Item_id and Org_id
*/
procedure Get_Client_Info_For_Item (x_return_status 		OUT NOCOPY VARCHAR2,
				                            x_msg_count     		OUT NOCOPY NUMBER,
				                            x_msg_data      		OUT NOCOPY VARCHAR2,
				                            p_organization_id		NUMBER,
				                            p_inventory_item_id	NUMBER,
																		x_outsourcer_id			OUT NOCOPY NUMBER
				                          );

/* Returns the Item Category Id for a given outsourcer_id
*/
procedure Get_Category_Info (x_return_status        OUT NOCOPY VARCHAR2,
		                    x_msg_count           OUT NOCOPY NUMBER,
		                    x_msg_data            OUT NOCOPY VARCHAR2,
		                    p_outsourcer_id       NUMBER,
		                    x_item_category_id    OUT NOCOPY NUMBER
                        );

 /* Added for LSP Project */

function get_client_code
    (
      p_item_id number)
    return VARCHAR2;


PROCEDURE get_client_details
    (
          x_client_id            IN   OUT NOCOPY MTL_CLIENT_PARAMETERS.CLIENT_ID%TYPE
        , x_client_code          IN   OUT NOCOPY MTL_CLIENT_PARAMETERS.CLIENT_CODE%TYPE
        , x_client_name          OUT NOCOPY HZ_PARTIES.PARTY_NAME%TYPE
        , x_return_status        OUT NOCOPY VARCHAR2
    );

procedure Get_Client_item_Name ( x_item_id    NUMBER,
                                 x_org_id     NUMBER,
                                 x_item_name OUT NOCOPY VARCHAR2
                                 );

procedure Get_Client_PONum_Info ( x_po_header_id      NUMBER,
                                  x_po_num OUT NOCOPY VARCHAR2) ;

/* Returns PO Number excluding the Client Code */
FUNCTION get_client_po_num
   (
     p_po_header_id  NUMBER)
    RETURN VARCHAR2;


/* Returns the Client Item Name.                       */
FUNCTION GET_CLIENT_ITEM
  (
    P_ORG_ID  NUMBER,
    P_ITEM_ID NUMBER)
  RETURN VARCHAR2;

/* Returns the Client Name to which the Item belongs.  */
FUNCTION get_item_client_name
  (
    p_item_id NUMBER)
  RETURN VARCHAR2;

/* Returns the Item appending logic for LSP Deployment */
FUNCTION get_item_suffix_for_lov
  (
    p_concatenated_segments VARCHAR2)
  RETURN VARCHAR2;

/* Returns the Client Code to which the PO belongs.    */
FUNCTION get_po_client_code
    (
          p_po_header_id NUMBER)
    RETURN VARCHAR2;

/* Returns the Client Code to which the PO belongs.    */
FUNCTION get_po_client_name
    (
          p_po_header_id NUMBER)
    RETURN VARCHAR2;

/* End of changes for LSP Project */

/*
**  Added function for bug 9274233
*/
FUNCTION get_po_number
   (
          p_segment1 VARCHAR2)
    RETURN NUMBER;
/*
**End of bug 9274233
*/

end WMS_DEPLOY;

/
