--------------------------------------------------------
--  DDL for Package INV_DS_LOGICAL_TRX_INFO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DS_LOGICAL_TRX_INFO_PUB" AUTHID CURRENT_USER AS
/* $Header: INVLTIPS.pls 115.3 2003/11/03 23:04:55 vipartha noship $ */

-- Global constant holding the package name
G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_DS_LOGICAL_TRX_INFO_PUB';

G_TRUE                 CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
G_FALSE                CONSTANT VARCHAR2(1) := FND_API.G_FALSE;
G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR        CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;


/*==========================================================================*
 | Procedure : GET_LOGICAL_ATTR_VALUES                                      |
 |                                                                          |
 | Description : This API will be called by Install base for a              |
 |                 specific transafction to get all the attributes tied to  |
 |                  a drop shipment so that they can update the inventory   |
 |               accordingly                                                |
 |                                                                          |
 |                                                                          |
 | Input Parameters :                                                       |
 |   p_api_version_number - API version number                              |
 |   p_init_msg_lst       - Whether initialize the error message list or not|
 |                          Should be fnd_api.g_false or fnd_api.g_true     |
 |   p_transaction_id     - transaction id of the inserted SO issue MMT     |
 |                          record.                                         |
 | Output Parameters :                                                      |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded         |
 |                          fnd_api.g_ret_sts_exc_error, if an expected     |
 |                          error occurred                                  |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected |
 |                          eror occurred                                   |
 |   x_msg_count          - Number of error message in the error message    |
 |                          list                                            |
 |   x_msg_data           - If the number of error message in the error     |
 |                          message list is one, the error message is in    |
 |                          this output parameter                           |
 |   x_logical_trx_attr_values - returns a record type with all the attributes|
 |                                  for a logical transaction.              |
 *==========================================================================*/
   PROCEDURE GET_LOGICAL_ATTR_VALUES
           (
	    x_return_status       OUT NOCOPY  VARCHAR2
	    , x_msg_count           OUT NOCOPY  NUMBER
	    , x_msg_data            OUT nocopy VARCHAR2
	    , x_logical_trx_attr_values  OUT NOCOPY INV_DROPSHIP_GLOBALS.logical_trx_attr_tbl
	    , p_api_version_number  IN          NUMBER   := 1.0
	    , p_init_msg_lst        IN          VARCHAR2 := G_FALSE
	    , p_transaction_id      IN          NUMBER
	    );



END INV_DS_LOGICAL_TRX_INFO_PUB;


 

/
