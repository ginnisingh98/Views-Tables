--------------------------------------------------------
--  DDL for Package MTL_SERIAL_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_SERIAL_CHECK" AUTHID CURRENT_USER AS
/* $Header: INVSERLS.pls 115.6 2004/02/13 22:53:57 gayu ship $ */

/*==========================================================================+
|---------------------------------------------------------------------------
|  TITLE:    PROCEDURE : INV_QTYBTWN
|---------------------------------------------------------------------------
|  PURPOSE:  Takes two alphanumeric serial numbers and returns both the
|      quantity of individual serial numbers which fall between them and
|      the alpha prefix of the first serial number.
|
|  PARAMETERS:
|      P_FROM_SERIAL_NUMBER and P_TO_SERIAL_NUMBER specify the range of
|      alphanumeric serial numbers from which QTYBTWN is to determine the
|      quantity.  P_QUANTITY is the field name to which the quantity of
|      serial numbers is to bewritten.  P_PREFIX is the field name to which
|      the alpha prefix is to be written.
|
|  RETURN:   Returns RET_FAILURE if failure.
+==========================================================================*/
PROCEDURE INV_QTYBETWN
( p_api_version                IN    NUMBER,
  p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit                     IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level           IN    NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2,
  x_errorcode                  OUT NOCOPY    NUMBER,

  P_FROM_SERIAL_NUMBER         IN    VARCHAR2,
  P_TO_SERIAL_NUMBER           IN    VARCHAR2,
  X_QUANTITY                   OUT NOCOPY    NUMBER,
  X_PREFIX                     OUT NOCOPY    VARCHAR2,
  P_ITEM_ID                    IN    NUMBER,
  P_ORGANIZATION_ID            IN    NUMBER,
  P_SERIAL_NUMBER_TYPE         IN    NUMBER,
  P_TRANSACTION_ACTION_ID      IN    NUMBER,
  P_TRANSACTION_SOURCE_TYPE_ID IN    NUMBER,
  P_SERIAL_CONTROL             IN    NUMBER,
  P_REVISION                   IN    VARCHAR2,
  P_LOT_NUMBER                 IN    VARCHAR2,
  P_SUBINVENTORY               IN    VARCHAR2,
  P_LOCATOR_ID                 IN    NUMBER,
  P_RECEIPT_ISSUE_FLAG         IN    VARCHAR2,
  p_simulate                   IN    VARCHAR2 DEFAULT FND_API.G_FALSE
)  ;

/*==========================================================================+
|---------------------------------------------------------------------------
|  TITLE:    FUNCTION : SNUniqueCheck
|---------------------------------------------------------------------------
|  PURPOSE:
|      Determine whether or not a given serial can be created without
|      violating the organization's uniqueness criteria.
|
|  PARAMETERS:
|      org_id is the organization_id, serial_number_type is the value from
|      MTL_PARAMETERS, ser_number is the serial number in question, message
|      is expected to point to a text[241].
|
|  RETURN:
|      Returns TRUE on success, FALSE on error.
|
|  ERROR CONDITIONS:
|      SQLERROR.
|      Violation of uniqueness criteria.
+==========================================================================*/
PROCEDURE SNUniqueCheck
 ( p_api_version               IN    NUMBER,
   p_init_msg_list             IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_commit                    IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_validation_level          IN    NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
   x_return_status             OUT NOCOPY    VARCHAR2,
   x_msg_count                 OUT NOCOPY    NUMBER,
   x_msg_data                  OUT NOCOPY    VARCHAR2,
   x_errorcode                 OUT NOCOPY    NUMBER,

   p_org_id                    IN    NUMBER,
   p_serial_number_type        IN    NUMBER ,
   p_serial_number             IN    VARCHAR2 )

;
/*==========================================================================+
|---------------------------------------------------------------------------
|  TITLE:  FUNCTION : SNGetMask
|---------------------------------------------------------------------------
|  PURPOSE:
|      Get the sn_mask row appropriate for a given transaction from the array
|      sn_mask defined at the top of this file.
|
|  PARAMETERS:
|      transaction_type and disposition_type are self-explanatory.
|      receipt_issue_flag should be a pointer to 'I' or 'R'.
|      serial_control is the serial control value for the item being
|      transacted.
|      to_status is an sb2 pointer.  The resultant current_status that the
|      transacted serial number should get is written to this variable.
|      dynamic_ok is an sb2 pointer.  If dynamic inserts are possible for
|      the transaction, a 1 is written to this variable.
|      mask is a pointer to a text (*x)[15] (pointer to an array of 15 text
|      characters).  The address of the appropriate sn_mask row is
|      written to this variable.
|      message is expected to point to a text[241].
+==========================================================================*/
FUNCTION SNGetMask
(P_txn_act_id       IN         NUMBER,
 P_txn_src_type_id  IN         NUMBER,
 P_serial_control   IN         NUMBER,
 x_to_status       OUT NOCOPY          NUMBER,
 x_dynamic_ok      OUT NOCOPY          NUMBER,
 P_receipt_issue_flag  IN      VARCHAR2,
 x_mask            OUT NOCOPY          VARCHAR2,
 x_errorcode       OUT NOCOPY          NUMBER)
 RETURN BOOLEAN;

/*==========================================================================+
|---------------------------------------------------------------------------
|  TITLE:  FUNCTION : SNValidate
|---------------------------------------------------------------------------
|  PURPOSE:
|      Check the validity of a particular serial number for a particular
|      transaction.
|
|  PARAMETERS:
|      inltis_args is a pointer to an INLTIS_ARGS array.  Some of the
|      elements of the array are not used by this function.
|      sncur_args is a pointer to an SNCUR_ARGS array.  If the serial
|      number already exists, then the current values of the serial number
|      are written to this array, otherwise the array is filled with 0's.
|      ser_number is the serial number to be validated.
|      dynamic_ok (0,1) indicates whether dynamic entry is allowed.
|      message is expected to point to a text[241].
+==========================================================================*/
PROCEDURE SNValidate
  (p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2 DEFAULT FND_API.G_FALSE ,
   p_commit                     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_validation_level           IN   NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY   VARCHAR2,
   x_msg_count                  OUT NOCOPY   NUMBER,
   x_msg_data                   OUT NOCOPY   VARCHAR2,
   x_errorcode                  OUT NOCOPY   NUMBER,

   p_item_id                    IN   NUMBER,
   p_org_id                     IN   NUMBER,
   p_subinventory               IN   VARCHAR2,
   p_txn_src_type_id            IN   NUMBER,
   p_txn_action_id              IN   NUMBER,
   p_serial_number              IN   VARCHAR2,
   p_locator_id                 IN   NUMBER,
   p_lot_number                 IN   VARCHAR2,
   p_revision                   IN   VARCHAR2,
   x_SerExists                  OUT NOCOPY   NUMBER,
   P_mask                       IN   VARCHAR2,
   P_dynamic_ok                 IN   NUMBER)
 ;
/*==========================================================================*/
FUNCTION INV_SERIAL_INFO
(P_FROM_SERIAL_NUMBER       IN       VARCHAR2,
 P_TO_SERIAL_NUMBER         IN       VARCHAR2,
 x_PREFIX                   OUT NOCOPY       VARCHAR2,
 x_QUANTITY                 OUT NOCOPY       VARCHAR2,
 X_FROM_NUMBER              OUT NOCOPY       VARCHAR2,
 X_TO_NUMBER                OUT NOCOPY       VARCHAR2,
 x_errorcode                OUT NOCOPY       NUMBER)

RETURN BOOLEAN;
END MTL_SERIAL_CHECK;

 

/
