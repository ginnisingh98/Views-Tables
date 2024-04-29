--------------------------------------------------------
--  DDL for Package Body MTL_SERIAL_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_SERIAL_CHECK" AS
/* $Header: INVSERLB.pls 120.1 2005/10/10 08:51:05 methomas noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_SERIAL_CHECK';


/*====================================================+
| debugging utility                                   |
+-----------------------------------------------------*/
procedure mdebug(msg in varchar2)
is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
   --dbms_output.put_line(msg);
   null;
end;

/*=========================================================================
| Error numbers
105 INV_SER_INVALID_STATUS
106 INV_SER_STATUS_NA
107 INV_SER_ORG_INVALID
108 INV_SER_REV_INVALID
109 INV_SER_LOT_INVALID
110 INV_SER_SUB_INVALID
111 INV_SER_LOC_INVALID
113 INV_SER_UNIQ1
114 INV_SER_UNIACR
115 INV_INLTIS_SER1
116 INV_QTYBTWN_ISSREC
118 INV_SER_NOTEXIST
119 INV_QTYBTWN_PFX
120 INV_QTYBTWN_LGTH
121 INV_QTYBTWN_LAST
122 INV_QTYBTWN_NUM
123 INV_INLTIS_SNGET_MASK
124 INV_QTYBTWN_NO_SERIAL
===========================================================================*/
/*==========================================================================+
|  TITLE:    qtybtwn (user exit QTYBTWN)
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

/*-------------------------------------------------------------------------+
|  Every serial number is given a current_status which indicates where the
|  unit is and for what transactions it is available.  Supported statuses
|  are:
|      o 1  The unit is defined but has not been received into or issued out
|           of stores.
|      o 3  The unit has been received into stores.
|      o 4  The unit has been issued out of stores.
|      o 5  The unit has been issued out of stores and now resides in
|           intransit.
|  A serialized unit is available to be used for a particular transaction
|  according to the following criteria:
|      o 1  Available to be received into or issued out of stores in any
|           transaction requiring serialized units.
|      o 3  Available to be issued out of stores in any transaction requiring
|           serialized units
|      o 4  Available to be received into stores in any transaction requiring
|           serialized units
|      o 5  Available to be received into stores by an intransit receipt
|           transaction.
|  In addition, there are several types of serial control which determine
|  under what conditions serialized units are required.  Supported serial
|  controls are:
|      o 1  No serial number control.
|      o 2  Predefined S/N - full control.
|      o 3  Predefined S/N - inventory receipt.
|      o 5  Dynamic entry at inventory receipt.
|      o 6  Dynamic entry at sales order issue.
|
|  The type of transaction determines which statuses are valid for the
|  transaction, and which status will be assigned to the unit after the
|  transaction.  The supported transactions can be divided into four basic
|  groups, with a further division between issues and receipts in each
|  group.  The four groups are SO/RMA, Standard, Subinventory Transfer, and
|  Intransit.  The following diagram shows the relationships between
|  the type of transaction, serial control, and status.
|
|  A transaction may accept one or more statuses, but it only assigns one
|  status.  A transaction may accept serial numbers which have not yet
|  been defined (Dynamic entry).
|
|  SO/RMA
|     Issue/     Serial       Available      Assigned
|     Receipt    Control       Status         Status
|     -------   ---------   ------------   ------------
|     issue     1
|     issue       2 3 5       3                4
|     issue             6   1 3     Dyn        4
|     receipt   1
|     receipt     2 3       1   4            3
|     receipt         5     1   4   Dyn      3
|     receipt           6   1   4   Dyn    1
|
|  Standard
|     Issue/     Serial       Available      Assigned
|     Receipt    Control       Status         Status
|     -------   ---------   ------------   ------------
|     receipt   1       6
|     receipt     2 3       1   4            3
|     receipt         5     1   4   Dyn      3
|     issue     1       6
|     issue       2 3 5       3                4
|
|  Subinventory Transfer
|     Issue/     Serial       Available      Assigned
|     Receipt    Control       Status         Status
|     -------   ---------   ------------   ------------
|     receipt   1       6
|     receipt     2 3 5       3              3
|     issue     1       6
|     issue       2 3 5       3              3
|
|  Intransit
|     Issue/     Serial       Available      Assigned
|     Receipt    Control       Status         Status
|     -------   ---------   ------------   ------------
|     receipt   1       6
|     receipt     2 3       1   4 5          3
|     receipt         5     1   4 5 Dyn      3
|     issue     1       6
|     issue       2 3 5       3                  5
|
|  The array sn_mask is declared below.  It is a representation of the
|  above diagram.
+-------------------------------------------------------------------------*/

PROCEDURE INV_QTYBETWN
( p_api_version                IN    NUMBER,
  p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit                     IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level           IN    NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT NOCOPY   VARCHAR2,
  x_msg_count                  OUT NOCOPY   NUMBER,
  x_msg_data                   OUT NOCOPY   VARCHAR2,
  x_errorcode                  OUT NOCOPY   NUMBER,

  P_FROM_SERIAL_NUMBER         IN    VARCHAR2,
  P_TO_SERIAL_NUMBER           IN    VARCHAR2,
  X_QUANTITY                   OUT NOCOPY   NUMBER,
  X_PREFIX                     OUT NOCOPY   VARCHAR2,
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
) IS

   -- Start OF comments
   -- API name  : INV_QTYBETWN
   -- TYPE      : Private
   -- Pre-reqs  : None
   -- FUNCTION  :
   -- as explained above
   -- Parameters:
   --     IN    :
   --  p_api_version      IN  NUMBER (required)
   --  API Version of this procedure
   --
   --  p_init_msg_list   IN  VARCHAR2 (optional)
   --    DEFAULT = FND_API.G_FALSE,
   --
   -- p_commit           IN  VARCHAR2 (optional)
   --     DEFAULT = FND_API.G_FALSE
   --
   --  p_validation_level IN  NUMBER (optional)
   --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
   --
   --  P_FROM_SERIAL_NUMBER          VARCHAR2
   --  P_TO_SERIAL_NUMBER            VARCHAR2
   --  X_QUANTITY                    VARCHAR2
   --  X_PREFIX                      VARCHAR2
   --  P_ITEM_ID                     NUMBER
   --  P_ORGANIZATION_ID             NUMBER
   --  P_SERIAL_NUMBER_TYPE          NUMBER
   --  P_TRANSACTION_ACTION_ID       NUMBER
   --  P_TRANSACTION_SOURCE_TYPE_ID  NUMBER
   --  P_SERIAL_CONTROL              NUMBER
   --  P_REVISION                    VARCHAR2
   --  P_LOT_NUMBER                  VARCHAR2
   --  P_SUBINVENTORY                VARCHAR2
   --  P_LOCATOR_ID                  NUMBER
   --  P_RECEIPT_ISSUE_FLAG          VARCHAR2
   --  P_VALIDATE                    VARCHAR2
   -- p_simulate  - flag that signals whether to do any insertions/updates
   -- if equals to FND_API.G_TRUE then no inserts/updates will be done
   -- and procedure will run in simulation mode. by default does necessary
   -- inserts/updates
   --
   --     OUT   :
   --  X_Return_Status    OUT NUMBER
   --  Result of all the operations
   --
   --  X_Msg_Count        OUT NUMBER,
   --
   --  X_Msg_Data         OUT VARCHAR2,
   --
   --  X_ErrorCode        OUT NUMBER
   --  X_QUANTITY         OUT VARCHAR2
   --  X_PREFIX           OUT VARCHAR2

   -- Version: Current Version 0.9
   --              Changed : Nothing
   --          No Previous Version 0.0
   --          Initial version 0.9
   -- Notes  : Note text
   -- END OF comments

   l_api_version   CONSTANT NUMBER := 0.9;
   l_api_name      CONSTANT VARCHAR2(30) := 'INV_QTYBETWN';

   -- Initialization of local variables

   l_number_part     NUMBER := 0;
   l_counter         NUMBER := 0;
   l_serial_number   VARCHAR2(30);
   l_to_status       NUMBER := 0;
   l_dynamic_ok      NUMBER := 0 ;
   l_mask            VARCHAR2(14);
   l_SerExists       NUMBER:= 1;
   l_user_id         NUMBER;
   l_from_number     VARCHAR2(30);
   l_to_number       VARCHAR2(30);
   l_length          NUMBER;
   l_padded_length   NUMBER;
   l_obj_seq_num     NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   --
   -- Standard start of API savepoint
   SAVEPOINT InvQtyBetwn;
   -- Standard Call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version
     , p_api_version
     , l_api_name
     , G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to true
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   -- Initialisize API return status to access
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_errorcode := 0;

   --
   -- API Body
   --


   -- Check the Input variable receipt_issue is either Issue or Receipt
   -- Otherwise return error message
   IF p_receipt_issue_flag NOT IN ('I','R') then
      FND_MESSAGE.set_name('INV','INV_QTYBTWN_ISSREC');
      FND_MSG_PUB.Add;
      x_errorcode := 116;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Calling Serial Info Routine
   --

   IF NOT INV_SERIAL_INFO
     (p_from_serial_number  =>  p_from_serial_number ,
      p_to_serial_number    =>  p_to_serial_number ,
      x_prefix              =>  x_prefix,
      x_quantity            =>  x_quantity,
      x_from_number         =>  l_from_number,
      x_to_number           =>  l_to_number,
      x_errorcode           =>  x_errorcode)
     THEN
      -- no need to process error here since it was already added to msg
      -- list inside inv_serial_info subroutine
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (l_debug = 1) THEN
      mdebug('Quantity ' || to_char(x_quantity));
      mdebug('Prefix ' || x_prefix );
      mdebug('FROM QTY ' || l_from_number);
      mdebug('TO QTY ' || l_to_number);
   END IF;

   IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN

      l_mask := '00000000000000';
      --
      IF (l_debug = 1) THEN
         mdebug('Mask before '||l_mask);
      END IF;
      --
      IF NOT SNGetMask(P_transaction_action_id,
	P_transaction_source_type_id,
	P_serial_control,
	l_to_status,
	l_dynamic_ok,
	P_receipt_issue_flag,
	l_mask,
	x_errorcode) then

	 IF (l_debug = 1) THEN
   	 mdebug('Mask Proc - Error');
	 END IF;
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;

      IF (l_debug = 1) THEN
         mdebug('Mask ' || l_mask);
         mdebug('x_quantity ' || x_quantity);
         mdebug('l_counter ' || l_counter);
      END IF;

      /*---------------------------------------------------------------+
      | Generate the serial numbers starting from from_serial_number
      | upto To serial number. Validate the serial numbers as you generate.
      +---------------------------------------------------------------*/


      l_number_part := TO_NUMBER(l_FROM_NUMBER);
      l_counter := 1;
      -- Get the length of the serial number
      l_length := length(p_from_serial_number);

      WHILE (l_counter <= x_quantity) LOOP
	 -- The padded length will be the length of the serial number minus
	 -- the length of the number part
	 -- Fix by etam
	 l_padded_length := l_length - nvl(length(l_number_part),0);
	 l_serial_number := RPAD(nvl(x_Prefix, '0'), l_padded_length, '0') ||
	   l_number_part;

	 IF (l_debug = 1) THEN
   	 mdebug('Calling SNValidate procedure ');
   	 mdebug('Item: =======> '|| to_char(p_item_id));
   	 mdebug('Org: ========> '|| to_char(p_organization_id));
   	 mdebug('Subinv: =====> '|| P_subinventory);
   	 mdebug('Txn Src Id: => '|| to_char(P_transaction_source_type_id));
   	 mdebug('Txn Act Id: => '|| to_char(P_transaction_action_id));
   	 mdebug('Serial: =====> '|| l_serial_number);
   	 mdebug('Loc: ========> '|| to_char(P_locator_id));
   	 mdebug('Lot: ========> '|| P_lot_number);
   	 mdebug('Rev: ========> '|| P_revision);
   	 mdebug('Mask: =======> '|| l_mask);
   	 mdebug('Dynamic: ====> '|| to_char(l_dynamic_ok));
	 END IF;

	 SNValidate
	   (p_api_version      =>  0.9,
	    x_return_status    =>  x_return_status,
	    x_errorcode        =>  x_errorcode,
	    x_msg_count        =>  x_msg_count,
	    x_msg_data         =>  x_msg_data,
	    p_item_id          =>  P_item_id,
	    p_org_id           =>  P_organization_id,
	    p_subinventory     =>  P_subinventory,
	    p_txn_src_type_id  =>  P_transaction_source_type_id,
	    p_txn_action_id    =>  P_transaction_action_id,
	    p_serial_number    =>  l_serial_number,
	    p_locator_id       =>  p_locator_id,
	    p_lot_number       =>  P_lot_number,
	    p_revision         =>  P_revision,
	    x_SerExists        =>  l_SerExists,
	    p_mask             =>  l_mask,
	    p_dynamic_ok       =>  l_dynamic_ok);


	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
   	    mdebug('Calling SNValidate : Error!');
	    END IF;
	    RAISE FND_API.G_EXC_ERROR ;
	 END IF;

	 IF (l_debug = 1) THEN
   	 mdebug('After Calling SNValidate procedure ');
	 END IF;

	 --
	 IF l_SerExists = 0  then   -- serial num does not exist
	    IF (l_debug = 1) THEN
   	    mdebug('Calling SNUniqueCheck Proc ');
	    END IF;

	    SNUniqueCheck(
	      p_api_version         =>  0.9,
	      x_return_status       =>  x_return_status,
	      x_errorcode           =>  x_errorcode,
	      x_msg_count           =>  x_msg_count,
	      x_msg_data            =>  x_msg_data,
	      p_org_id              =>  P_Organization_Id,
	      p_serial_number_type  =>  P_Serial_number_type,
	      p_serial_number       =>  l_Serial_number);

	    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	       RAISE FND_API.G_EXC_ERROR ;
	    END IF;


	    IF (l_debug = 1) THEN
   	    mdebug('After Calling SNUniqueCheck Proc ');
	    END IF;
    /*
     * Get the next sequence number for this 'object' and insert
     * into GEN_OBJECT_ID field : Object Genealogy
     */

    SELECT MTL_GEN_OBJECT_ID_S.NEXTVAL
    INTO l_obj_seq_num FROM DUAL;


	    IF NOT FND_API.to_Boolean(p_simulate) THEN
	       l_user_id := FND_GLOBAL.USER_ID ;
	       BEGIN
		  IF (l_debug = 1) THEN
   		  mdebug('Inserting row with SL NO '||l_serial_number);
		  END IF;
		  INSERT INTO MTL_SERIAL_NUMBERS
		    (INVENTORY_ITEM_ID,
		    SERIAL_NUMBER,
		    LAST_UPDATE_DATE,
		    LAST_UPDATED_BY,
		    INITIALIZATION_DATE,
		    CREATION_DATE,
		    CREATED_BY,
		    LAST_UPDATE_LOGIN,
		    CURRENT_STATUS,
		    CURRENT_ORGANIZATION_ID,
        GEN_OBJECT_ID)
		    VALUES
		    (P_Item_id, l_serial_number, sysdate,
		    l_user_id, sysdate, sysdate,
		    l_user_id, -1, 6, P_organization_id,l_obj_seq_num);

		  IF SQL%FOUND THEN
		     IF (l_debug = 1) THEN
   		     mdebug('Inserted row with SL NO '||l_serial_number);
		     END IF;
		   ELSE
		     IF (l_debug = 1) THEN
   		     mdebug('Inserted failure');
		     END IF;
		  END IF;

	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
   		     mdebug('Exception : Inserted failure:');
		     END IF;
		     NULL;
	       END;
	    END IF;  -- if not in simulation mode

	 END IF;  -- if serial number does not exist
         /*---------------------------------------------------------+
         | Get next serial number
	 +---------------------------------------------------------*/
         l_number_part := l_number_part + 1;
	 l_counter :=  l_counter + 1;
      END LOOP;

   END IF;

   --
   -- END of API Body
   --

   -- Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
     , p_data => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      --
      ROLLBACK TO InvQtyBetwn;
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
      --
      IF (l_debug = 1) THEN
         mdebug('Exception :FND_API.G_EXC_ERROR');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 1) THEN
         mdebug('InvQtyBetwn: Unexpected error');
      END IF;
      --
      ROLLBACK TO InvQtyBetwn;
      --
      IF (l_debug = 1) THEN
         mdebug('InvQtyBetwn: Unexpected error-2');
      END IF;
      x_errorcode := -1;
      IF (l_debug = 1) THEN
         mdebug('InvQtyBetwn: Unexpected error-3');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 1) THEN
         mdebug('InvQtyBetwn: x_return_status='||x_return_status);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
      --
      IF (l_debug = 1) THEN
         mdebug('Exception :FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

   WHEN OTHERS THEN
      --
      ROLLBACK TO InvQtyBetwn;
      --
      x_errorcode := -1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
			       , p_data => x_msg_data);
     IF (l_debug = 1) THEN
        mdebug('Exception :');
     END IF;

END INV_QTYBETWN ;
/*---------------------------------------------------------------------------
----------------------------End of INV_QTYBETWN -----------------------------
----------------------------------------------------------------------------*/

/*==========================================================================+
|  TITLE:    FUNCTION : SNUniqueCheck
|  PURPOSE:
|      Determine whether or not a given serial can be created without
|      violating the organization uniqueness criteria.
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
|
|      Violation of uniqueness criteria.
+==========================================================================*/
/*------------------------------------------------------------+
| Dynamically create a new serial number record.  We must
| follow the serial number uniqueness criteria specified
| in the inventory parameters of this organization.  The
| possible criteria are:
|
|  o 1  Unique serial numbers within inventory items.
|       No duplicate serial numbers for any particular
|       inventory item across all organizations.
|
|       A serial number may be assigned to at most one
|       unit of each item across all organizations. This
|       translates into at most one record in
|       MTL_SERIAL_NUMBERS for each combination of
|       SERIAL_NUMBER and INVENTORY_ITEM_ID.
|
|  o 2  Unique serial numbers within organization.
|       No duplicate serial numbers within any particular
|       organization.
|
|       A serial number may be assigned to at most one unit
|       of one item in each organization, with the caveat
|       that the same serial number may not be assigned to
|       the same item in two different organizations.  This
|       translates into at most one record in
|       MTL_SERIAL_NUMBERS for each combination of
|       SERIAL_NUMBER and INVENTORY_ITEM_ID with the
|       overriding condition that there be at most one
|       record for any given combination of SERIAL_NUMBER
|       and ORGANIZATION_ID.
|
|  o 3  Unique serial numbers across organizations.
|       No duplicate serial numbers in the entire system.
|
|       A serial number may be assigned to at most one unit
|       of one item across all organizations.  This
|       translates into at most one record in
|       MTL_SERIAL_NUMBERS for each value of SERIAL_NUMBER.
+-------------------------------------------------------------*/
PROCEDURE SNUniqueCheck
  (
   p_api_version                 IN    NUMBER,
   p_init_msg_list               IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_commit                      IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_validation_level            IN    NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
   x_return_status               OUT NOCOPY   VARCHAR2,
   x_msg_count                   OUT NOCOPY   NUMBER,
   x_msg_data                    OUT NOCOPY   VARCHAR2,
   x_errorcode                   OUT NOCOPY   NUMBER,

   p_org_id                      IN    NUMBER,
   p_serial_number_type          IN    NUMBER ,
   p_serial_number               IN    VARCHAR2 )
IS
   l_api_version constant number := 0.9;
   l_api_name constant varchar2(30) := 'SNUniqueCheck';

   L_nothing VARCHAR2(10) ;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT SNUniqueCheck;
   -- Standard Call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version
     , p_api_version
     , l_api_name
     , G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to true
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   -- Initialisize API return status to access
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_errorcode := 0;

   --
   -- API Body
   --

   IF P_serial_number_type = 2 then
      BEGIN
         SELECT  'X'
         INTO    L_nothing
         FROM    MTL_SERIAL_NUMBERS
         WHERE   SERIAL_NUMBER = P_serial_number
         AND     CURRENT_ORGANIZATION_ID + 0 = P_org_id;
         --
         if L_nothing is not NULL then
            FND_MESSAGE.set_name('INV','INV_SER_UNIQ1');
	    FND_MESSAGE.SET_TOKEN('TOKEN1',P_serial_number);
	    FND_MSG_PUB.Add;
	    x_errorcode := 113;
	    RAISE FND_API.G_EXC_ERROR;
         end if;
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
	  FND_MESSAGE.set_name('INV','INV_SER_UNIQ1');
	  FND_MESSAGE.SET_TOKEN('TOKEN1',P_serial_number);
	  FND_MSG_PUB.Add;
	  x_errorcode := 113;
	  RAISE FND_API.G_EXC_ERROR;

	 WHEN NO_DATA_FOUND  then
	   null;
      END;

      BEGIN
	 SELECT 'x'
	   INTO L_nothing
	     FROM MTL_SERIAL_NUMBERS S,
	     MTL_PARAMETERS P
	     WHERE S.CURRENT_ORGANIZATION_ID = P.ORGANIZATION_ID
	     AND S.SERIAL_NUMBER = P_serial_number
	     AND P.SERIAL_NUMBER_TYPE = 3;

	   if L_nothing is not NULL then
	      FND_MESSAGE.set_name('INV','INV_SER_UNIACR');
	      FND_MESSAGE.SET_TOKEN('TOKEN1',P_serial_number);
	      FND_MSG_PUB.Add;
	      x_errorcode := 114;
	      raise FND_API.G_EXC_ERROR;
	   end if;

      EXCEPTION
	 WHEN TOO_MANY_ROWS THEN
	   FND_MESSAGE.set_name('INV','INV_SER_UNIACR');
	   FND_MESSAGE.SET_TOKEN('TOKEN1',P_serial_number);
	   FND_MSG_PUB.Add;
	   x_errorcode := 114;
	   RAISE FND_API.G_EXC_ERROR;
	 WHEN NO_DATA_FOUND THEN
	   null;
      END;

   ELSIF P_serial_number_type = 3 then
      BEGIN
         SELECT 'x'
         INTO L_nothing
         FROM MTL_SERIAL_NUMBERS
         WHERE SERIAL_NUMBER = P_serial_number;
         if L_nothing is not NULL then
            FND_MESSAGE.set_name('INV','INV_INLTIS_SER1');
	    FND_MESSAGE.SET_TOKEN('TOKEN1',P_serial_number);
	    FND_MSG_PUB.Add;
	    x_errorcode := 115;
	    RAISE FND_API.G_EXC_ERROR;
         end if;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
              FND_MESSAGE.set_name('INV','INV_INLTIS_SER1');
	   FND_MESSAGE.SET_TOKEN('TOKEN1',P_serial_number);
	   FND_MSG_PUB.Add;
	   x_errorcode := 115;
	   RAISE FND_API.G_EXC_ERROR;
         WHEN NO_DATA_FOUND THEN
	   null;
      END;
   END IF;

   --
   -- END of API body
   --

   -- Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
     , p_data => x_msg_data);


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     --
     ROLLBACK TO SNUniqueCheck;
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     ROLLBACK TO SNUniqueCheck;

     x_errorcode := -1;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);

   WHEN OTHERS THEN
     --
     ROLLBACK TO SNUniqueCheck;
     --
     x_errorcode := -1;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);

END SNUniqueCheck;
/*----------------------------------------------------------------------------
-----------------------End of SNUniqueCheck Function -----------------------
----------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 | Retrieves mask corresponding to passed transaction action id, transaction
 | source type id, serial number control code and receive or issue flag
 | the mask represents the above serial number status transition diagram
 | also returns whether dynamic creation is ok, and to what status the
 | serial number would go as result of this transaction
 | in case of error returns false and x_errorcode indicates error
 +--------------------------------------------------------------------------*/
FUNCTION SNGetMask(P_txn_act_id          IN      NUMBER,
                   P_txn_src_type_id     IN      NUMBER,
                   P_serial_control      IN      NUMBER,
                   x_to_status           OUT NOCOPY     NUMBER,
                   x_dynamic_ok          OUT NOCOPY     NUMBER,
                   P_receipt_issue_flag  IN      VARCHAR2,
		   x_mask                OUT NOCOPY     VARCHAR2,
		   x_errorcode           OUT NOCOPY     NUMBER)
                   RETURN BOOLEAN IS
   --
   TYPE L_mask_tab IS TABLE OF VARCHAR2(14)
        INDEX BY BINARY_INTEGER;
   L_sn_mask  L_mask_tab;
   L_group NUMBER := 0;
   --
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- initialize out variables
   x_errorcode := 0;
   x_to_status := 0;
   x_dynamic_ok := 0;

   L_sn_mask(1) := 'I0110100010004';
   L_sn_mask(2) := 'I0000011010014';
   L_sn_mask(3) := 'R0110001001003';
   L_sn_mask(4) := 'R0000101991013';
   L_sn_mask(5) := 'R0000011001011';
   L_sn_mask(6) := '00000000000000';
   L_sn_mask(7) := 'R0110001001003';
   L_sn_mask(8) := 'R0000101001013';
   L_sn_mask(9) := 'I0110100010004';
   L_sn_mask(10):= '00000000000000';
   L_sn_mask(11):= 'R0110110001003';
   L_sn_mask(12):= 'I0110110010004';
   L_sn_mask(13):= '00000000000000';
   L_sn_mask(14):= 'R0110001001103';
   L_sn_mask(15):= 'R0000101001113';
   L_sn_mask(16):= 'I0110100010005';
   L_sn_mask(17):= '00000000000000';
   /*---------------------------------------------------------------------
   | Determine which group the transactions to.  the value of
   |  group will be used to provide the appropriate offset in the sn_mask
   |  array table
   +----------------------------------------------------------------------*/
   -- Sales Order [SO] - 2
   -- RMA              - 12
   -- SO RMA GROUP     - 0
   IF P_txn_src_type_id in (2,12) then
       L_group := 0;
   ELSE
      IF P_txn_act_id = 2 then                -- SUBXFR
         L_group := 10 ;                      -- SUB_XFER_GROUP
      ELSIF P_txn_act_id = 12 then            -- INTERECEIPT
         null;                                -- Not defined yet
      ELSIF P_txn_act_id = 21 then            -- INTSHIP
         L_group := 13 ;                      -- INTRANS_GROUP
      ELSE                                    -- Default Value
         L_group := 6 ;                       -- STD_GROUP
      END IF;
   END IF;
   L_group := L_group + 1;    -- It starts from 0th position, just to avoid
   x_mask := L_sn_mask(L_group);
   /*---------------------------------------------------------------------
   | Match up the transaction with the appropriate mas and get the assigned
   | status.  If there is no match, then to_status will still be zero after
   | the loop
   +-----------------------------------------------------------------------*/
   WHILE ( substr(x_mask,1,1) <> '0' )
   LOOP
      if ( substr(x_mask,1,1) = P_receipt_issue_flag ) AND
         ( substr(x_mask,P_serial_control+1,1) = '1' ) then
         x_to_status := to_number(substr(x_mask,14,1));  -- get the 14th character from mask
         x_dynamic_ok := to_number(substr(x_mask,13,1)); -- get the 13th character from mask
         exit;
      end if;
      L_group := L_group + 1;  -- go to next mask group
      x_mask := L_sn_mask(L_group);
   END LOOP;

   IF x_to_status = 0  then
      FND_MESSAGE.SET_NAME('INV', 'INV_INLTIS_SNGET_MASK');
      FND_MSG_PUB.Add;
      x_errorcode := 123;
      return(FALSE);
   ELSE
      return(TRUE);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_errorcode := -1;
     return(FALSE);
END SNGetmask;
/*---------------------------------------------------------------------------
-----------------------End of SNGetmask Function ---------------------------
----------------------------------------------------------------------------*/

-- TODO: need to add serial geneology stuff
PROCEDURE SNValidate
  (p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2 DEFAULT FND_API.G_FALSE ,
   p_commit                     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_validation_level           IN   NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   x_errorcode                  OUT NOCOPY  NUMBER,

   p_item_id                    IN   NUMBER,
   p_org_id                     IN   NUMBER,
   p_subinventory               IN   VARCHAR2,
   p_txn_src_type_id            IN   NUMBER,
   p_txn_action_id              IN   NUMBER,
   p_serial_number              IN   VARCHAR2,
   p_locator_id                 IN   NUMBER,
   p_lot_number                 IN   VARCHAR2,
   p_revision                   IN   VARCHAR2,
   x_SerExists                  OUT NOCOPY  NUMBER,
   P_mask                       IN   VARCHAR2,
   P_dynamic_ok                 IN   NUMBER)
IS
   L_api_version CONSTANT NUMBER := 0.9;
   L_api_name CONSTANT VARCHAR2(30) := 'SNValidate';

  -- Declare Local variables
  L_current_status          NUMBER;
  L_current_revision        VARCHAR2(4);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
  L_current_lot_number      VARCHAR2(80);
  L_current_subinventory    VARCHAR2(10);
  L_current_locator_id      NUMBER;
  L_current_organization_id NUMBER;
  L_wip_entity_id           NUMBER;
  L_nothing                 VARCHAR2(10);
  L_user_id                 NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   SAVEPOINT SNValidate;
   -- Standard Call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version
     , p_api_version
     , l_api_name
     , G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to true
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   -- Initialisize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_errorcode := 0;


   --
   x_serexists := 1;

   --
   -- API Body
   --


  /*-------------------------------------------+
  |  Check for existence of the serial number
  +-------------------------------------------*/
  IF (l_debug = 1) THEN
     mdebug ('SNValidate : Begin ');
  END IF;
  -- Validate Serial Number for exist
  BEGIN
     SELECT  decode(current_status,6,1,current_status),
       revision,
       lot_number,
       current_subinventory_code,
       current_locator_id,
       current_organization_id,
       original_wip_entity_id
       INTO    L_current_status,
       L_current_revision,
       L_current_lot_number,
       L_current_subinventory,
       L_current_locator_id,
       L_current_organization_id,
       L_wip_entity_id
       FROM    MTL_SERIAL_NUMBERS
       WHERE   inventory_item_id = P_Item_id
       AND     serial_number = P_serial_number;
     IF (l_debug = 1) THEN
        mdebug ('SNValidate : After SQL ');
     END IF;


     IF L_current_locator_id is null then
	L_current_locator_id := 0;
     END IF;

     IF L_current_organization_id is null then
	L_current_organization_id := 0;
     END IF;

     IF (l_debug = 1) THEN
        mdebug ('SNValidate : Before status check ');
     END IF;

     IF L_current_status is NULL or
       L_current_status = 2 or
       L_current_status < 1 or
        L_current_status > 5 then
	FND_MESSAGE.set_name('INV','INV_SER_INVALID_STATUS');
	FND_MESSAGE.SET_TOKEN('TOKEN',P_serial_number);
	FND_MSG_PUB.Add;
	x_errorcode := 105;
	raise FND_API.G_EXC_ERROR;
     END IF;

     IF (l_debug = 1) THEN
        mdebug ('SNValidate : After status check ');
     END IF;
     /* Check the current status aginst the available status in the mask
     */

     IF (l_debug = 1) THEN
        mdebug ('SNValidate : current status '||to_char(L_current_status));
        mdebug ('SNValidate : Mask '||P_mask);
     END IF;
     IF substr(P_mask,L_current_status+7,1)='0' then
	FND_MESSAGE.set_name('INV','INV_SER_STATUS_NA');
	FND_MESSAGE.SET_TOKEN('TOKEN',P_serial_number);
	FND_MSG_PUB.Add;
	x_errorcode := 106;
	raise FND_API.G_EXC_ERROR;
     END IF;
     IF (l_debug = 1) THEN
        mdebug ('SNValidate : After Stats+7 ');
     END IF;

     /*-----------------------------------------------------------+
     |  If the unit is currently in inventory (status 3), then it
     |  must be issued or transferred to the same revision,
     |  lot number, and org that it was received against.
     |  If the unit is defined but not transacted (status 1) then
     |  it must be received to or issued from the organization
     |  for which it is defined.
     +----------------------------------------------------------*/
     IF (l_debug = 1) THEN
        mdebug ('SNValidate : Curr Stat'||to_char(L_current_status));
        mdebug ('SNValidate : P_Org '||to_char(p_org_id));
        mdebug ('SNValidate : L_Org '||to_char(L_current_organization_id));
     END IF;

     IF (L_current_status = 3 or
       L_current_status = 1) AND
       L_current_organization_id <> p_org_id then
	FND_MESSAGE.set_name('INV','INV_SER_ORG_INVALID');
	FND_MESSAGE.SET_TOKEN('TOKEN',P_serial_number);
	FND_MSG_PUB.Add;
	x_errorcode := 107;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (l_debug = 1) THEN
        mdebug ('SNValidate : After Stats - not org ');
     END IF;

     IF  L_current_status = 3 then
	IF L_current_revision <> P_revision then
	   FND_MESSAGE.set_name('INV','INV_SER_REV_INVALID');
	   FND_MESSAGE.SET_TOKEN('TOKEN1',P_serial_number);
	   FND_MESSAGE.SET_TOKEN('TOKEN2',L_current_revision);
	   FND_MSG_PUB.Add;
	   x_errorcode := 108;
	   raise FND_API.G_EXC_ERROR;
	ELSIF L_current_lot_number <> P_lot_number then
	   FND_MESSAGE.set_name('INV','INV_SER_LOT_INVALID');
	   FND_MESSAGE.SET_TOKEN('TOKEN1',P_serial_number);
	   FND_MESSAGE.SET_TOKEN('TOKEN2',L_current_lot_number);
	   FND_MSG_PUB.Add;
	   x_errorcode := 109;
	   raise FND_API.G_EXC_ERROR;
	END IF;
     END IF;
     /*--------------------------------------------------------------+
      |  If issuing a unit which is currently in inventory, then we
      |  must issue from the organization, subinventory, and locator
      |  in which the unit is currently located.
      +--------------------------------------------------------------*/
     IF (l_debug = 1) THEN
        mdebug ('SNValidate : Before mask check 0 - 3 ');
     END IF;
     IF substr(P_mask,1,1)='I' and L_current_status = 3 then
	IF L_current_subinventory <> P_subinventory then
	   FND_MESSAGE.set_name('INV','INV_SER_SUB_INVALID');
	   FND_MESSAGE.SET_TOKEN('TOKEN1',P_serial_number);
	   FND_MESSAGE.SET_TOKEN('TOKEN2',L_current_subinventory);
	   FND_MSG_PUB.Add;
	   x_errorcode := 110;
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF L_current_locator_id <> P_locator_id then
	   FND_MESSAGE.set_name('INV','INV_SER_LOC_INVALID');
	   FND_MESSAGE.SET_TOKEN('TOKEN1',P_serial_number);
	   FND_MSG_PUB.Add;
	   x_errorcode := 111;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
     END IF;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
           mdebug('Exception :whennodatafound dynamic '||to_char(nvl(P_dynamic_ok,0)));
        END IF;

        IF nvl(P_dynamic_ok,0)= 0 then
           FND_MESSAGE.set_name('INV','INV_SER_NOTEXIST');
	   FND_MESSAGE.SET_TOKEN('TOKEN',P_serial_number);
	   FND_MSG_PUB.Add;
	   x_errorcode := 118;
	   RAISE FND_API.G_EXC_ERROR;
        ELSE
           x_SerExists := 0;
        END IF;
  END;


  IF P_txn_src_type_id = 5 AND
    (( P_txn_action_id = 31 and L_current_status <> 1) OR
    ( P_txn_action_id = 32 ) OR
    ( P_txn_action_id = 27 ) ) AND
    L_wip_entity_id is  NULL  then
     FND_MESSAGE.set_name('INV','INV_SER_STATUS_NA');
     FND_MESSAGE.SET_TOKEN('TOKEN',P_serial_number);
     FND_MSG_PUB.Add;
     x_errorcode := 106;
     raise FND_API.G_EXC_ERROR;
  END IF;

  --
  -- SERIAL GENEOLOGY UPDATE GOES HERE
  --


  --
  -- END of API body
  --

  IF FND_API.to_Boolean(p_commit) THEN
     COMMIT;
  END IF;
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
    , p_data => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     --
     ROLLBACK TO SNValidate;
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
       --

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (l_debug = 1) THEN
        mdebug('InvQtyBetwn: Unexpected error '||sqlerrm);
     END IF;
     --
     ROLLBACK TO SNValidate;
     --
     x_errorcode := -1;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);


   WHEN OTHERS THEN
     IF (l_debug = 1) THEN
        mdebug('SNValidate other:' || sqlerrm);
     END IF;
     --
     ROLLBACK TO SNValidate;
     --
     x_errorcode := -1;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);

END SNValidate;
/*---------------------------------------------------------------------------
-----------------------End of SNValidate Function --------------------------
----------------------------------------------------------------------------*/

/* ========================================================================
 | Helper procedure called form inv_qtybetwn
 | takes p_from_serial_number and p_to_serial_number and
 | parses out common prefix and range of numbers from them
 | (if p_to_serial_number is not supplied than it will be assumed to be the
 | same as p_from_serial_number)
 |
 | pre: none
 |
 | returns: true upon successful completion
 |
 |    false upon failure, x_errorcode will contain error number
 |
 | if function completes successfully then
 | x_prefix will contain common prefix or null if both from and two do not
 | have alpha prefix
 | x_quantity will contain positive quantity (# of serial numbers between
 | p_from_serial_number and p_to_serial_number)
 | x_from number will contain starting number
 | x_to_serial_number will contain ending range number
 +-------------------------------------------------------------------------*/


 FUNCTION INV_SERIAL_INFO(P_FROM_SERIAL_NUMBER       IN       VARCHAR2,
                          P_TO_SERIAL_NUMBER         IN       VARCHAR2,
                          x_PREFIX                   OUT NOCOPY      VARCHAR2,
                          x_QUANTITY                 OUT NOCOPY      VARCHAR2,
                          X_FROM_NUMBER              OUT NOCOPY      VARCHAR2,
			  X_TO_NUMBER                OUT NOCOPY      VARCHAR2,
			  x_errorcode                OUT NOCOPY      NUMBER)
 RETURN BOOLEAN IS
   L_f_alp_part VARCHAR2(30);
   L_t_alp_part VARCHAR2(30);
   L_f_num_part VARCHAR2(30);
   L_t_num_part VARCHAR2(30);
   L_ser_col_val VARCHAR2(30);
   L_ser_col_num NUMBER;
   L_from_length NUMBER;
   L_to_length NUMBER;
   L_f_ser_num VARCHAR2(30);
   L_t_ser_num VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
    x_errorcode := 0;

    L_f_ser_num := P_FROM_SERIAL_NUMBER;
    L_t_ser_num := P_TO_SERIAL_NUMBER;



        /*--------------------------------------------------------------+
        | Get the lengths of the two serial numbers. If the to serial
        | number is not specified copy from serial number to it.
        +--------------------------------------------------------------*/
       L_from_length := nvl(LENGTH(L_f_ser_num),0);
       L_to_length   := nvl(LENGTH(L_t_ser_num),0);
       IF (l_debug = 1) THEN
          mdebug('L_from_length='||L_from_length);
          mdebug('L_to_length='||L_to_length);
       END IF;

       --
       IF L_from_length = 0 then
	  FND_MESSAGE.SET_NAME('INV', 'INV_QTYBTWN_NO_SERIAL');
	  FND_MSG_PUB.Add;
	  x_errorcode := 124;
	  return (FALSE);
       END IF;

       IF L_to_length = 0 then
          L_t_ser_num := L_f_ser_num;
          L_to_length := L_from_length;
       END IF;
        /*-----------------------------------------------------------------+
        | Split the given serial number into alpha
        | prefix and numeric part.
        +-----------------------------------------------------------------*/
       -- From Serial Number
       L_ser_col_num := L_from_length;
       --
       while (L_ser_col_num > 0 )
       loop
         L_ser_col_val := substr(L_f_ser_num,L_ser_col_num,1);
         if ASCII(L_ser_col_val) >= 48 and ASCII(L_ser_col_val) <= 57 then
            L_f_num_part := L_ser_col_val||L_f_num_part;
         else
            L_f_alp_part := substr(L_f_ser_num,1,L_ser_col_num);
            exit;
         end if;
         L_ser_col_num := L_ser_col_num - 1;
       end loop;
       -- To Serial Number
       -- Values for 0 to 9 is corresponds to ASCII value 48 TO 57
       -- All other values are Non-numeric value
       --
       L_ser_col_num := L_to_length;
       while (L_ser_col_num > 0)
       loop
         L_ser_col_val := substr(L_t_ser_num,L_ser_col_num,1);
         if ascii(L_ser_col_val) >= 48 and ascii(L_ser_col_val) <= 57 then
            L_t_num_part := L_ser_col_val||L_t_num_part;
         else
            L_t_alp_part := substr(L_t_ser_num,1,L_ser_col_num);
            exit;
         end if;
         L_ser_col_num := L_ser_col_num - 1;
       end loop;
        /*----------------------------------------------------------------+
        | We compare the prefixes to see if they are the same
	+----------------------------------------------------------------*/

	if (L_f_alp_part <> L_t_alp_part) or
	  (l_f_alp_part is null and l_t_alp_part is not null) or
	   (l_f_alp_part is not null and l_t_alp_part is null)
	then
	   FND_MESSAGE.set_name('INV','INV_QTYBTWN_PFX');
	   FND_MSG_PUB.Add;
	   x_errorcode := 119;
	   RETURN(FALSE);

	end if;
        /*---------------------------------------------------------------+
        | Check the lengths of the two serial numbers to make sure they
        | match.
        +---------------------------------------------------------------*/
       if (L_from_length <> L_to_length) then
          -- Message Name : INV_QTYBTWN_LGTH
	  FND_MESSAGE.set_name('INV','INV_QTYBTWN_LGTH');
	  FND_MSG_PUB.Add;
	  x_errorcode := 120;
          RETURN(FALSE);
       end if;
       /*-------------------------------------------------------
       | Check whether the serial numbers are matched
       | If not, check the last character of serial number is character
       | If yes, return error message
       +-------------------------------------*/
       -- XXX checks only one
       if L_f_ser_num <> L_t_ser_num then
          if ascii(substr(L_f_ser_num,LENGTH(L_f_ser_num),1)) < 48 and
             ascii(substr(L_f_ser_num,LENGTH(L_f_ser_num),1)) > 57  then
	     FND_MESSAGE.set_name('INV','INV_QTYBTWN_LAST');
	     FND_MSG_PUB.Add;
	     x_errorcode := 121;
	     RETURN (FALSE);
	  end if;
       end if;
       -- Calculate the difference of serial numbers
       -- How many serial nos are there in the given range
       --
       IF (l_debug = 1) THEN
          mdebug('L_t_num_part='||L_t_num_part);
          mdebug('L_f_num_part='||L_f_num_part);
       END IF;

       -- Out variables
       X_Quantity :=
	 nvl(to_number(L_t_num_part),0) - nvl(to_number(L_f_num_part),0) + 1;

       if (X_Quantity <= 0) then
        --  Message Name : INV_QTYBTWN_NUM
          FND_MESSAGE.set_name('INV','INV_QTYBTWN_NUM');
          FND_MSG_PUB.Add;
	  x_errorcode := 122;
          RETURN (FALSE);
       end if;
       --
       /*--------------------------------------------------------------+
       | Check to make sure To serial number is greater than
       | From serial number.
       +--------------------------------------------------------------*/

       X_PREFIX := L_f_alp_part;
       X_FROM_NUMBER := L_f_num_part ;
       X_TO_NUMBER   := L_t_num_part;

       RETURN(TRUE);

 EXCEPTION
    WHEN OTHERS THEN
      x_errorcode := -1;
      RETURN(FALSE);
 END;
END MTL_SERIAL_CHECK;

/
