--------------------------------------------------------
--  DDL for Package WSH_OTM_REF_DATA_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_OTM_REF_DATA_GEN_PKG" AUTHID CURRENT_USER as
/* $Header: WSHTMRGS.pls 120.0.12010000.1 2008/07/29 06:19:05 appldev ship $ */

  --
--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Send_Locations          This procedure is called only from
--                                     the Inbound Reconciliation UI
--                                     when the user performs the revert
--                                     matching of a matched or
--                                     partially matched receipt.
--
-- PARAMETERS: p_shipment_header_id    Shipment Header Id of the transaction
--             p_transaction_type      transaction type (ASN or RECEIPT)
--             x_return_status         return status of the API
--========================================================================

procedure SEND_LOCATIONS
            (
              p_entity_in_rec    IN WSH_OTM_ENTITY_REC_TYPE,
              x_loc_xmission_rec OUT NOCOPY WSH_OTM_LOC_XMISSION_REC_TYPE,
              x_transmission_id  OUT NOCOPY NUMBER,
              x_return_status    OUT NOCOPY VARCHAR2,
              x_msg_data        OUT NOCOPY VARCHAR2
            );
function GET_STOP_LOCATION_XID
            (
              p_stop_id          IN  NUMBER
            ) RETURN VARCHAR2;

procedure VALIDATE_TKT
            (
              p_operation          IN  VARCHAR2,
              p_argument           IN  VARCHAR2,
              p_ticket             IN  VARCHAR2,
              x_tkt_valid          OUT NOCOPY VARCHAR2,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_data           OUT NOCOPY VARCHAR2
            );

procedure GET_INT_LOCATION_XID
            (
              p_location_id          IN  NUMBER,
              x_location_xid         OUT NOCOPY VARCHAR2,
              x_return_status        OUT NOCOPY VARCHAR2
            );

END WSH_OTM_REF_DATA_GEN_PKG;

/
