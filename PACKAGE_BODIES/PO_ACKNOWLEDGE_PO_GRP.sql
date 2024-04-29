--------------------------------------------------------
--  DDL for Package Body PO_ACKNOWLEDGE_PO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ACKNOWLEDGE_PO_GRP" AS
/* $Header: POXGACKB.pls 120.1 2005/06/29 18:31:38 shsiung noship $ */

  g_pkg_name CONSTANT VARCHAR2(50) := 'PO_ACKNOWLEDGE_PO_GRP';
  g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

  -- Read the profile option that enables/disables the debug log
  g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


/**
 * Public function: Get_Po_Status_Code
 * Requires: PO_HEADER_ID,PO_RELEASE_ID
 * Modifies:
 * Effects: Return the overall status of the entire order.
 *          Possible values are:
 *          1. CANCELLED
 *          2. FROZEN
 *          3. ON HOLD
 *          4. INTERNAL CHANGE
 *          5. SUPPLIER_CHANGE_PENDING
 *          6. ACCEPTED
 *          7. REJECTED
 *          8. ACKNOWLEDGED
 *          9. PARTIALLY_ACKNOWLEDGED
 *         10. ACK_REQUIRED
 *         11. ''
 */

FUNCTION Get_Po_Status_Code (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER )
RETURN VARCHAR2 IS

  l_status_code	VARCHAR2(30) := NULL;
  l_api_name	CONSTANT VARCHAR2(30) := 'GET_PO_STATUS_CODE';
  l_api_version	CONSTANT NUMBER := 1.0;


BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
		l_api_name || '.invoked', 'po_header_id: ' ||
        	NVL(TO_CHAR(p_po_header_id), ' ') || ' po_release_id: ' ||
        	NVL(TO_CHAR(p_po_release_id), ' ') );
    END IF;
  END IF;

  l_status_code := PO_ACKNOWLEDGE_PO_PVT.Get_Po_Status_Code (
    			p_api_version	=>	1.0,
    			p_init_msg_list	=>	FND_API.G_FALSE,
			p_po_header_id	=>	p_po_header_id,
			p_po_release_id	=>	p_po_release_id );

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
		l_api_name || '.before return', 'status_code: ' ||
		NVL(l_status_code, ''));
    END IF;
  END IF;

  return l_status_code;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                   l_api_name || '.others_exception', sqlcode);
        END IF;
      END IF;
    END IF;
    raise;

END Get_Po_Status_Code;



/**
 * Public function: Get_Shipment_Ack_Change_Status
 * Requires: PO_HEADER_ID,PO_RELEASE_ID
 * Modifies:
 * Effects: Return the acknowledgement status of individual shipment.
 *          Possible values are:
 *          1. ACK_REQUIRED
 *          2. PENDING_CHANGE
 *          3. PENDING_CANCEL
 *          4. ACCEPTED
 *          5. REJECTED
 *          6. ''
 */

FUNCTION Get_Shipment_Ack_Change_Status (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
	P_line_location_id	IN	NUMBER,
	p_po_header_id		IN 	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER )
RETURN VARCHAR2 IS

  l_shipment_status	VARCHAR2(30) := NULL;
  l_api_name	CONSTANT VARCHAR2(30) := 'GET_SHIPMENT_ACK_CHANGE_STATUS';
  l_api_version	CONSTANT NUMBER := 1.0;


BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
		l_api_name || '.invoked', 'line_location_id: ' ||
		NVL(TO_CHAR(P_line_location_id), ''));
    END IF;
  END IF;

  l_shipment_status := PO_ACKNOWLEDGE_PO_PVT.Get_Shipment_Ack_Change_Status(
    			p_api_version		=>	1.0,
    			p_init_msg_list		=>	FND_API.G_FALSE,
			P_line_location_id	=>	P_line_location_id,
			p_po_header_id		=>	P_po_header_id,
			p_po_release_id		=>	p_po_release_id,
			p_revision_num 		=>	p_revision_num );


  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
		l_api_name || '.before return', 'shipment_status: ' ||
		NVL(l_shipment_status, ''));
    END IF;
  END IF;

  return l_shipment_status;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                   l_api_name || '.others_exception', sqlcode);
        END IF;
      END IF;
    END IF;
    raise;

END Get_Shipment_Ack_Change_Status;



/**
 * Public procedure: Acknowledge_Shipment
 * Requires: LINE_LOCATION_ID, PO_HEADER_ID, PO_RELEASE_ID, REVISION_NUM,
 *           ACCEPTED_FLAG, COMMENT, BUYER_ID, USER_ID
 * Modifies: PO_ACCEPTANCES
 * Effects: Insert shipment level acknowledgement result into PO_ACCEPTANCES
 *          table.  It also checks if all shipments are acknowledged after
 *          inserting the record, if yes then post the header level acknowledge
 *          result.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */

PROCEDURE Acknowledge_Shipment (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
    	x_return_status		OUT 	NOCOPY VARCHAR2,
	p_line_location_id	IN	NUMBER,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER,
	p_accepted_flag		IN	VARCHAR2,
	p_comment		IN	VARCHAR2 default null,
	p_buyer_id		IN	NUMBER,
	p_user_id		IN	NUMBER )
IS

  l_api_name		CONSTANT VARCHAR2(30) := 'ACKNOWLEDGE_SHIPMENT';
  l_api_version		CONSTANT NUMBER := 1.0;

BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call (	l_api_version,
					p_api_version,
					l_api_name,
					g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
		l_api_name || '.invoked', 'Line_location_id: ' ||
		NVL(TO_CHAR(p_line_location_id),'null'));
    END IF;
  END IF;

  PO_ACKNOWLEDGE_PO_PVT.Acknowledge_shipment(
	p_api_version		=>	1.0,
    	p_Init_Msg_List		=>	FND_API.G_FALSE,
    	x_return_status		=>	x_return_status,
	p_line_location_id	=>	p_line_location_id,
	p_po_header_id		=>	p_po_header_id,
	p_po_release_id		=>	p_po_release_id,
	p_revision_num		=>	p_revision_num,
	p_accepted_flag		=>	p_accepted_flag,
	p_comment		=>	p_comment,
	p_buyer_id		=>	p_buyer_id,
	p_user_id		=> 	p_user_id );



EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', sqlcode);
        END IF;
      END IF;
    END IF;
    raise;
END Acknowledge_Shipment;



/**
 * Public procedure: Carry_Over_Acknowledgement
 * Requires: PO_HEADER_ID, PO_RELEASE_ID, REVISION_NUM,
 * Modifies: PO_ACCEPTANCES
 * Effects:  Carry over the shipment_level acknowledgement results from the
 *           previous revision, it is called before launching PO approval
 *           workflow after supplier's change has been accepted by buyer.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE Carry_Over_Acknowledgement (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
    	x_return_status		OUT 	NOCOPY VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER )    -- current revision_num
IS

  l_api_name	CONSTANT VARCHAR2(30) := 'CARRY_OVER_ACKNOWLEDGEMENT';
  l_api_version	CONSTANT NUMBER := 1.0;


BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
	l_api_name || '.invoked', 'po_header_id: ' ||
	NVL(TO_CHAR(p_po_header_id),'null') || ' po_release_id: ' ||
	NVL(TO_CHAR(p_po_release_id),'null'));
    END IF;
  END IF;

  PO_ACKNOWLEDGE_PO_PVT.Carry_Over_Acknowledgement(
    	p_api_version		=>	1.0,
    	p_Init_Msg_List		=>	FND_API.G_FALSE,
    	x_return_status		=>	x_return_status,
	p_po_header_id		=>	p_po_header_id,
	p_po_release_id		=>	p_po_release_id,
	p_revision_num		=>	p_revision_num );


EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                   l_api_name || '.others_exception', sqlcode);
        END IF;
      END IF;
    END IF;
    raise;

END Carry_Over_Acknowledgement;


/**
 * Public function: All_Shipments_Responded
 * Requires: PO_HEADER_ID,PO_RELEASE_ID,REVISION_NUM
 * Modifies:
 * Effects:  Returns if all the shipments have been either changed
 *           or acknowledged.
 * Returns:  FND_API.G_FALSE or FND_API.G_TRUE
 */

FUNCTION All_Shipments_Responded (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER )
RETURN VARCHAR2 IS

  l_api_name	CONSTANT VARCHAR2(30) := 'ALL_SHIPMENTS_RESPONDED';
  l_api_version	CONSTANT NUMBER := 1.0;
  l_result	VARCHAR2(1) := NULL;

BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
		l_api_name || '.invoked', 'po_header_id: ' ||
        	NVL(TO_CHAR(p_po_header_id), ' ') || ' po_release_id: ' ||
        	NVL(TO_CHAR(p_po_release_id), ' ') || ' revision_num: ' ||
		NVL(TO_CHAR(p_revision_num), ' '));
    END IF;
  END IF;

  l_result := PO_ACKNOWLEDGE_PO_PVT.All_Shipments_Responded (
		p_api_version	=>	1.0,
    		p_Init_Msg_List	=>	FND_API.G_FALSE,
		p_po_header_id	=>	p_po_header_id,
		p_po_release_id	=>	p_po_release_id,
		p_revision_num	=>	p_revision_num );

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
		l_api_name || '.before return', 'All shipments acknowledged: ' ||
		NVL(l_result, ''));
    END IF;
  END IF;

  return l_result;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', sqlcode);
        END IF;
      END IF;
    END IF;
    raise;

END All_Shipments_Responded;



/**
 * Public procedure: Set_Header_Acknowledgement
 * Requires: PO_HEADER_ID, PO_RELEASE_ID
 * Modifies: PO_ACCEPTANCES
 * Effects:  For ack required PO, check if all shipments has been acknowledged
 *           and if there is no supplier change pending, if both conditions
 *           satisfied, post the header level acknowledgement record.
 * This API should be called after supplier submits the change requests and
 * after buyer responds to all supplier changes without revision increase.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE Set_Header_Acknowledgement (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
    	x_return_status		OUT 	NOCOPY VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER )
IS

  l_api_name	CONSTANT VARCHAR2(30) := 'SET_HEADER_ACKNOWLEDGEMENT';
  l_api_version	CONSTANT NUMBER := 1.0;


BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
	l_api_name || '.invoked', 'po_header_id: ' ||
	NVL(TO_CHAR(p_po_header_id),'null') || ' po_release_id: ' ||
	NVL(TO_CHAR(p_po_release_id),'null'));
    END IF;
  END IF;

  PO_ACKNOWLEDGE_PO_PVT.Set_Header_Acknowledgement (
    	p_api_version		=>	1.0,
    	p_Init_Msg_List		=>	FND_API.G_FALSE,
    	x_return_status		=>	x_return_status,
	p_po_header_id		=>	p_po_header_id,
	p_po_release_id		=>	p_po_release_id );


EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                   l_api_name || '.others_exception', sqlcode);
        END IF;
      END IF;
    END IF;
    raise;

END Set_Header_Acknowledgement;


END PO_ACKNOWLEDGE_PO_GRP;

/
