--------------------------------------------------------
--  DDL for Package WSH_DD_TXNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DD_TXNS_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHDXTHS.pls 120.0 2005/05/26 17:48:09 appldev noship $ */

TYPE DD_Txn_Rec_Type IS RECORD
        (DD_TXN_ID                     NUMBER,
         DD_TXN_DATE                   DATE,
         DELIVERY_DETAIL_ID            NUMBER,
         RELEASED_STATUS               VARCHAR2(1),
         REQUESTED_QUANTITY            NUMBER,
         REQUESTED_QUANTITY_UOM        VARCHAR2(3),
         REQUESTED_QUANTITY2           NUMBER,
         REQUESTED_QUANTITY_UOM2       VARCHAR2(3),
         PICKED_QUANTITY               NUMBER,
         PICKED_QUANTITY2              NUMBER,
         ATTRIBUTE_CATEGORY            VARCHAR2(150),
         ATTRIBUTE1                    VARCHAR2(150),
         ATTRIBUTE2                    VARCHAR2(150),
         ATTRIBUTE3                    VARCHAR2(150),
         ATTRIBUTE4                    VARCHAR2(150),
         ATTRIBUTE5                    VARCHAR2(150),
         ATTRIBUTE6                    VARCHAR2(150),
         ATTRIBUTE7                    VARCHAR2(150),
         ATTRIBUTE8                    VARCHAR2(150),
         ATTRIBUTE9                    VARCHAR2(150),
         ATTRIBUTE10                   VARCHAR2(150),
         ATTRIBUTE11                   VARCHAR2(150),
         ATTRIBUTE12                   VARCHAR2(150),
         ATTRIBUTE13                   VARCHAR2(150),
         ATTRIBUTE14                   VARCHAR2(150),
         ATTRIBUTE15                   VARCHAR2(150),
         CREATION_DATE                 DATE,
         CREATED_BY                    NUMBER,
         LAST_UPDATE_DATE              DATE,
         LAST_UPDATED_BY               NUMBER,
         LAST_UPDATE_LOGIN             NUMBER);


    --
    --  Procedure:   Insert_DD_Txn
    --  Parameters:  All Attributes of a Delivery Detail Record,
    --			 Row_id out
    --			 DD_Txn_id out
    --			 Return_Status out
    --  Description: This procedure will create a delivery detail transaction.
    --               It will return to the user the dd_txn_id as a
    --               parameter.

PROCEDURE Insert_DD_Txn(
	p_dd_txn_info	IN DD_Txn_Rec_Type,
	x_rowid		OUT NOCOPY  VARCHAR2,
	x_dd_txn_id       OUT NOCOPY  NUMBER,
	x_return_status	OUT NOCOPY  VARCHAR2
	);

--  Procedure:   Get_DD_Snapshot
--  Parameters:  p_delivery_detail_id : Delivery detail id for which the record to be populated.
--  Description: This procedure will copy the attributes of a delivery detail in wsh_delivery_details
--               and copy it to a dd transaction record.

PROCEDURE Get_DD_Snapshot (p_delivery_detail_id IN NUMBER,
                           x_dd_txn_info OUT NOCOPY DD_Txn_Rec_Type,
                           x_return_status OUT NOCOPY VARCHAR2);

--  Procedure:   Create_DD_txn_from_dd
--  Parameters:  p_delivery_detail_id : Delivery detail id for which the record to be populated.
--  Description: This procedure will create a dd txn record with the help of passed DD_ID and
--               return the status along with the dd_txn_id.

PROCEDURE create_dd_txn_from_dd  (p_delivery_detail_id IN NUMBER,
                                  x_dd_txn_id OUT NOCOPY NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2);



END WSH_DD_TXNS_PVT;

 

/
