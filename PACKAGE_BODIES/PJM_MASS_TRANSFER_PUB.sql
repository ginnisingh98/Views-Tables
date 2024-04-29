--------------------------------------------------------
--  DDL for Package Body PJM_MASS_TRANSFER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_MASS_TRANSFER_PUB" AS
/* $Header: PJMMXFRB.pls 115.15 2004/01/07 22:36:04 alaw noship $ */

--
-- Global Declarations
--
G_PKG_NAME     VARCHAR2(30) := 'PJM_MASS_TRANSFER_PUB';
G_MODULE       VARCHAR2(80) := 'pjm.plsql.pjm_mass_transfer_pub';

--
-- Private Procedures
--
FUNCTION Get_Acct_Period
( P_Organization_ID         IN      NUMBER
, P_Txn_Date                IN      DATE
) RETURN NUMBER IS

acct_period_id   NUMBER;
open_past_period BOOLEAN := fnd_profile.value('TRANSACTION_DATE') IN (3,4);

BEGIN

  INVTTMTX.TDATECHK
  ( P_Organization_ID
  , trunc(P_Txn_Date)
  , acct_period_id
  , open_past_period
  );

  RETURN( acct_period_id );

EXCEPTION
WHEN OTHERS THEN
  RETURN( -1 );

END Get_Acct_Period;


FUNCTION Get_Txn_Header
RETURN NUMBER IS

txn_header_id NUMBER;

BEGIN

  SELECT mtl_material_transactions_s.nextval
  INTO   txn_header_id
  FROM   dual;

  RETURN( txn_header_id );

END Get_Txn_Header;


PROCEDURE Create_Transfer_Transaction
( P_Txn_Header_ID           IN            NUMBER
, P_Process_Mode            IN            NUMBER
, P_Organization_ID         IN            NUMBER
, P_Item_ID                 IN            NUMBER
, P_Revision                IN            VARCHAR2
, P_Lot_Number              IN            VARCHAR2
, P_Txn_Quantity            IN            NUMBER
, P_Subinventory_Code       IN            VARCHAR2
, P_From_Locator_ID         IN            NUMBER
, P_To_Locator_ID           IN            NUMBER
, P_Txn_Date                IN            DATE
, P_Acct_Period_ID          IN            NUMBER
, P_Txn_Reason_ID           IN            NUMBER
, P_Txn_Reference           IN            VARCHAR2
, P_DFF                     IN            DFF_Rec_Type
, X_Return_Status           OUT NOCOPY    VARCHAR2
, X_Msg_Count               OUT NOCOPY    NUMBER
, X_Msg_Data                OUT NOCOPY    VARCHAR2
) IS

user_id        NUMBER := FND_GLOBAL.user_id;
login_id       NUMBER := FND_GLOBAL.login_id;
txn_xface_id   NUMBER;
ser_txn_id     NUMBER;
primary_uom    VARCHAR2(3);
lot_control    VARCHAR2(1);
serial_control VARCHAR2(1);
progress       NUMBER;

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT create_txfr_txn;

  PJM_DEBUG.Debug( 'CREATE_TRANSFER_TRANSACTION'
                 , G_MODULE , FND_LOG.LEVEL_PROCEDURE );

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Fetching value for TRANSACTION_TEMP_ID
  --
  txn_xface_id := Get_Txn_Header;

  --
  -- Fetching Primary UOM, lot control and serial control code
  -- from item
  --
  progress := 10;

  SELECT primary_uom_code
  ,      decode(lot_control_code , 1 , 'N' , 'Y')
  ,      decode(serial_number_control_code , 1 , 'N' , 'Y')
  INTO   primary_uom
  ,      lot_control
  ,      serial_control
  FROM   mtl_system_items
  WHERE  organization_id = P_Organization_ID
  AND    inventory_item_id = P_Item_ID;

  PJM_DEBUG.Debug(
  'txn_xface_id => ' || txn_xface_id ||
  ', lot_control => ' || lot_control ||
  ', serial_control => ' || serial_control);

  --
  -- Creating main transaction entry
  --
  progress := 20;

  PJM_DEBUG.Debug('Creating Transaction Header');

  INSERT INTO mtl_transactions_interface
  ( transaction_header_id
  , transaction_interface_id
  , source_code
  , source_header_id
  , source_line_id
  , transaction_mode
  , lock_flag
  , process_flag
  , validation_required
  , last_update_date
  , last_updated_by
  , creation_date
  , created_by
  , last_update_login
  , inventory_item_id
  , revision
  , organization_id
  , subinventory_code
  , locator_id
  , transaction_quantity
  , transaction_uom
  , primary_quantity
  , transaction_type_id
  , transaction_action_id
  , transaction_source_type_id
  , transaction_date
  , acct_period_id
  , reason_id
  , transfer_organization
  , transfer_subinventory
  , transfer_locator
  , transaction_reference
  , attribute_category
  , attribute1
  , attribute2
  , attribute3
  , attribute4
  , attribute5
  , attribute6
  , attribute7
  , attribute8
  , attribute9
  , attribute10
  , attribute11
  , attribute12
  , attribute13
  , attribute14
  , attribute15
  ) VALUES
  ( P_Txn_Header_ID
  , txn_xface_id
  , 'PJM MASS TRANSFER' /* Source Code */
  , 0 /* Source Header ID */
  , 0 /* Source Line ID */
  , P_Process_Mode
  , NULL /* Lock Flag */
  , 1 /* Process Flag */
  , 1 /* Validation Required */
  , sysdate
  , user_id
  , sysdate
  , user_id
  , login_id
  , P_Item_ID
  , P_Revision
  , P_Organization_ID
  , P_Subinventory_Code
  , P_From_Locator_ID
  , P_Txn_Quantity
  , primary_uom
  , P_Txn_Quantity
  , 67 /* Transaction Type ID - Project Transfer */
  , 2  /* Transaction Action ID - Subinventory Transfer */
  , 13 /* Trasaction Source Type ID - Inventory */
  , P_Txn_Date
  , P_Acct_Period_ID
  , P_Txn_Reason_ID
  , P_Organization_ID
  , P_Subinventory_Code
  , P_To_Locator_ID
  , P_Txn_Reference
  , P_DFF.Category
  , P_DFF.Attr1
  , P_DFF.Attr2
  , P_DFF.Attr3
  , P_DFF.Attr4
  , P_DFF.Attr5
  , P_DFF.Attr6
  , P_DFF.Attr7
  , P_DFF.Attr8
  , P_DFF.Attr9
  , P_DFF.Attr10
  , P_DFF.Attr11
  , P_DFF.Attr12
  , P_DFF.Attr13
  , P_DFF.Attr14
  , P_DFF.Attr15
  );

  --
  -- Populate Lot Table if item is lot controlled
  --
  IF ( lot_control = 'Y' AND P_Lot_Number IS NOT NULL ) THEN

    progress := 30;

    IF ( serial_control = 'Y' ) THEN
      --
      -- Fetching value for SERIAL_TRANSACTION_TEMP_ID
      --
      ser_txn_id := Get_Txn_Header;
    ELSE
      ser_txn_id := NULL;
    END IF;

    progress := 35;

    PJM_DEBUG.Debug('Creating Transaction Lot Information');

    INSERT INTO mtl_transaction_lots_interface
    ( transaction_interface_id
    , serial_transaction_temp_id
    , source_code
    , source_line_id
    , last_update_date
    , last_updated_by
    , creation_date
    , created_by
    , last_update_login
    , transaction_quantity
    , primary_quantity
    , lot_number
    )
    SELECT mti.transaction_interface_id
    ,      ser_txn_id
    ,      mti.source_code
    ,      mti.source_line_id
    ,      mti.last_update_date
    ,      mti.last_updated_by
    ,      mti.creation_date
    ,      mti.created_by
    ,      mti.last_update_login
    ,      mti.transaction_quantity
    ,      mti.primary_quantity
    ,      P_Lot_Number
    FROM mtl_transactions_interface mti
    WHERE mti.transaction_interface_id = txn_xface_id;

  END IF;

  --
  -- Populate Serial Table if item is serial controlled
  --
  IF ( serial_control = 'Y' ) THEN

    progress := 40;

    --
    -- MSNI.TRANSACTION_INTERFACE_ID points to
    -- > MTLI.SERIAL_TRANSACTION_TEMP_ID is lot controlled;
    -- > MTI.TRANSACTION_INTERFACE_ID otherwise
    IF ( ser_txn_id IS NULL ) THEN
      ser_txn_id := txn_xface_id;
    END IF;

    PJM_DEBUG.Debug('Creating Transaction Serial Information');

    INSERT INTO mtl_serial_numbers_interface
    ( transaction_interface_id
    , source_code
    , source_line_id
    , last_update_date
    , last_updated_by
    , creation_date
    , created_by
    , last_update_login
    , fm_serial_number
    , to_serial_number
    )
    SELECT ser_txn_id
    ,      mti.source_code
    ,      mti.source_line_id
    ,      mti.last_update_date
    ,      mti.last_updated_by
    ,      mti.creation_date
    ,      mti.created_by
    ,      mti.last_update_login
    ,      msn.serial_number
    ,      msn.serial_number
    FROM mtl_transactions_interface mti
    ,    mtl_serial_numbers msn
    WHERE mti.transaction_interface_id = txn_xface_id
    AND   msn.inventory_item_id = mti.inventory_item_id
    AND   msn.current_organization_id = mti.organization_id
    AND   msn.current_subinventory_code = mti.subinventory_code
    AND   msn.current_locator_id = mti.locator_id
    AND   nvl(msn.lot_number , '<No Lot Number>') =
             nvl(P_Lot_Number , '<No Lot Number>')
    AND   msn.current_status = 3;

    /*
    IF ( sql%rowcount <> ABS(P_Txn_Quantity) ) THEN
      --
      -- Serial count does not match transaction quantity, error out
      --
      FND_MESSAGE.set_name('INV' , 'INV_SERQTY_NOTMATCH');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    */
  END IF;

  PJM_DEBUG.Debug( 'CREATE_TRANSFER_TRANSACTION completed'
                 , G_MODULE , FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_txfr_txn;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_txfr_txn;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

  WHEN OTHERS THEN
    ROLLBACK TO create_txfr_txn;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => 'CREATE_TRANSFER_TRANSACTION:' || progress);
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

END Create_Transfer_Transaction;


--
-- Public Procedure
--
PROCEDURE Transfer
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2
, P_commit                  IN            VARCHAR2
, X_Return_Status           OUT NOCOPY    VARCHAR2
, X_Msg_Count               OUT NOCOPY    NUMBER
, X_Msg_Data                OUT NOCOPY    VARCHAR2
, P_Process_Mode            IN            NUMBER
, P_Transfer_Mode           IN            NUMBER
, P_Txn_Header_ID           IN            NUMBER
, P_Organization_ID         IN            NUMBER
, P_Item_ID                 IN            NUMBER
, P_Category_Set_ID         IN            NUMBER
, P_Category_ID             IN            NUMBER
, P_From_Project_ID         IN            NUMBER
, P_From_Task_ID            IN            NUMBER
, P_To_Project_ID           IN            NUMBER
, P_To_Task_ID              IN            NUMBER
, P_Txn_Date                IN            DATE
, P_Acct_Period_ID          IN            NUMBER
, P_Txn_Reason_ID           IN            NUMBER
, P_Txn_Reference           IN            VARCHAR2
, P_DFF                     IN            DFF_Rec_Type
, X_Txn_Header_ID           OUT NOCOPY    NUMBER
, X_Txn_Count               OUT NOCOPY    NUMBER
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'TRANSFER';
l_api_version  CONSTANT NUMBER       := 1.0;

TYPE item_rc IS REF CURSOR;

c              item_rc;
stmt           VARCHAR2(2000);
item_id        NUMBER;
acct_period    NUMBER;
txn_header_id  NUMBER;
txn_count      NUMBER := 0;

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT pjm_mass_transfer;

  PJM_DEBUG.Debug(
    l_api_name ||
    '( process_mode => '    || P_Process_Mode ||
    ', transfer_mode => '   || P_Transfer_Mode ||
    ', txn_header_id => '   || P_Txn_Header_ID ||
    ', organization_id => ' || P_Organization_ID ||
    ', item_id => '         || P_Item_ID ||
    ', category_set_id => ' || P_Category_Set_ID ||
    ', category_id => '     || P_Category_ID ||
    ', from_project_id => ' || P_From_Project_ID ||
    ', from_task_id => '    || P_From_Task_ID ||
    ', to_project_id => '   || P_To_Project_ID ||
    ', to_task_id => '      || P_To_Task_ID ||
    ', txn_date => '        || FND_DATE.Date_To_DisplayDT(P_Txn_Date) ||
    ', txn_reason_id => '   || P_Txn_Reason_ID ||
    ', acct_period_id => '  || P_Acct_Period_ID ||
    ', txn_reference => '   || P_Txn_Reference || ' )'
  , G_MODULE , FND_LOG.LEVEL_PROCEDURE);

  --
  -- Check API incompatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , P_api_version
                                    , l_api_name
                                    , G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize the message table if requested.
  --
  IF FND_API.TO_BOOLEAN( P_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- Set API return status to success
  --
  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get Current Open Accounting Period based on Transaction Date
  -- if not already done
  --
  IF ( P_Acct_Period_ID IS NULL ) THEN
    acct_period := Get_Acct_Period(P_Organization_ID , P_Txn_Date);
    PJM_DEBUG.Debug('acct_period => ' || acct_period);
  ELSE
    acct_period := P_Acct_Period_ID;
  END IF;

  --
  -- If open accounting period not found, error out
  --
  IF ( acct_period = 0 ) THEN
    FND_MESSAGE.set_name('INV' , 'INV_NO_OPEN_PERIOD');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( acct_period = -1 ) THEN
    FND_MESSAGE.set_name('INV' , 'INV_RETRIEVE_PERIOD');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Get Transaction Header ID if not already done
  --
  IF ( P_Txn_Header_ID IS NULL ) THEN
    txn_header_id := Get_Txn_Header;
    PJM_DEBUG.Debug('txn_header_id => ' || txn_header_id);
  ELSE
    txn_header_id := P_Txn_Header_ID;
  END IF;

  X_Txn_Count := 0;

  PJM_DEBUG.Debug('Loop for item...');

  IF ( P_Transfer_Mode = G_TXFR_MODE_ALL_ITEMS ) THEN

    OPEN c FOR
      SELECT DISTINCT moq.inventory_item_id
      FROM mtl_onhand_quantities_detail moq
      ,    mtl_item_locations mil
      WHERE moq.organization_id = P_Organization_ID
      AND   mil.organization_id = moq.organization_id
      AND   mil.inventory_location_id = moq.locator_id
      AND   mil.project_id = P_From_Project_ID
      AND   nvl(mil.task_id , 0) = nvl(P_From_Task_ID , 0);

  ELSIF ( P_Transfer_Mode = G_TXFR_MODE_CATEGORY ) THEN

    OPEN c FOR
      SELECT DISTINCT moq.inventory_item_id
      FROM mtl_onhand_quantities_detail moq
      ,    mtl_item_locations mil
      ,    mtl_item_categories mic
      WHERE mic.organization_id = P_Organization_ID
      AND   mic.category_set_id = P_Category_Set_ID
      AND   mic.category_id = P_Category_ID
      AND   moq.organization_id = mic.organization_id
      AND   moq.inventory_item_id = mic.inventory_item_id
      AND   mil.organization_id = moq.organization_id
      AND   mil.inventory_location_id = moq.locator_id
      AND   mil.project_id = P_From_Project_ID
      AND   nvl(mil.task_id , 0) = nvl(P_From_Task_ID , 0);

  ELSE

    OPEN c FOR
      SELECT P_Item_ID FROM DUAL
      WHERE P_Item_ID is not null;

  END IF;

  LOOP
    FETCH c INTO item_id;
    EXIT WHEN c%notfound;

    PJM_DEBUG.Debug('item_id => ' || item_id);

    Item_Transfer
    ( P_api_version       => P_api_version
    , P_init_msg_list     => FND_API.G_FALSE
    , P_commit            => FND_API.G_FALSE
    , X_Return_Status     => X_Return_Status
    , X_Msg_Count         => X_Msg_Count
    , X_Msg_Data          => X_Msg_Data
    , P_Process_Mode      => P_Process_Mode
    , P_Txn_Header_ID     => txn_header_id
    , P_Organization_ID   => P_Organization_ID
    , P_Item_ID           => item_id
    , P_From_Project_ID   => P_From_Project_ID
    , P_From_Task_ID      => P_From_Task_ID
    , P_To_Project_ID     => P_To_Project_ID
    , P_To_Task_ID        => P_To_Task_ID
    , P_Txn_Date          => P_Txn_Date
    , P_Acct_Period_ID    => acct_period
    , P_Txn_Reason_ID     => P_Txn_Reason_ID
    , P_Txn_Reference     => P_Txn_Reference
    , P_DFF               => P_DFF
    , X_Txn_Header_ID     => X_Txn_Header_ID
    , X_Txn_Count         => txn_count
    );

    IF ( X_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF ( X_Return_Status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    X_Txn_Count := X_Txn_Count + txn_count;

  END LOOP;

  --
  -- Stanard commit check
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                           , p_data  => X_Msg_Data );

  PJM_DEBUG.Debug( l_api_name || ' completed'
                 , G_MODULE , FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO pjm_mass_transfer;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO pjm_mass_transfer;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

  WHEN OTHERS THEN
    ROLLBACK TO pjm_mass_transfer;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => 'TRANSFER');
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

END Transfer;


PROCEDURE Item_Transfer
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2
, P_commit                  IN            VARCHAR2
, X_Return_Status           OUT NOCOPY    VARCHAR2
, X_Msg_Count               OUT NOCOPY    NUMBER
, X_Msg_Data                OUT NOCOPY    VARCHAR2
, P_Process_Mode            IN            NUMBER
, P_Txn_Header_ID           IN            NUMBER
, P_Organization_ID         IN            NUMBER
, P_Item_ID                 IN            NUMBER
, P_From_Project_ID         IN            NUMBER
, P_From_Task_ID            IN            NUMBER
, P_To_Project_ID           IN            NUMBER
, P_To_Task_ID              IN            NUMBER
, P_Txn_Date                IN            DATE
, P_Acct_Period_ID          IN            NUMBER
, P_Txn_Reason_ID           IN            NUMBER
, P_Txn_Reference           IN            VARCHAR2
, P_DFF                     IN            DFF_Rec_Type
, X_Txn_Header_ID           OUT NOCOPY    NUMBER
, X_Txn_Count               OUT NOCOPY    NUMBER
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'ITEM_TRANSFER';
l_api_version  CONSTANT NUMBER       := 1.0;

CURSOR onhand IS
  SELECT moq.subinventory_code
  ,      moq.locator_id
  ,      moq.lot_number
  ,      moq.revision
  ,      (-1) * sum(moq.transaction_quantity) txn_quantity
  FROM   mtl_onhand_quantities_detail moq
  ,      mtl_item_locations mil
  WHERE  moq.organization_id = P_Organization_ID
  AND    moq.inventory_item_id = P_Item_ID
  AND    mil.organization_id = moq.organization_id
  AND    mil.inventory_location_id = moq.locator_id
  AND    mil.project_id = P_From_Project_ID
  AND    nvl(mil.task_id , 0) = nvl(P_From_Task_ID , 0)
  AND NOT EXISTS (
      SELECT 'Expired lot'
      FROM   mtl_lot_numbers
      WHERE  organization_id = moq.organization_id
      AND    inventory_item_id = moq.inventory_item_id
      AND    lot_number = moq.lot_number
      AND    expiration_date < sysdate )
  GROUP BY moq.subinventory_code , moq.locator_id , moq.lot_number , moq.revision
  HAVING sum(moq.transaction_quantity) > 0;

acct_period       NUMBER;
txfr_locator_id   NUMBER;
txn_header_id     NUMBER;
txn_count         NUMBER;

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT pjm_mass_transfer_item;

  PJM_DEBUG.Debug(
    l_api_name ||
    '( process_mode => '    || P_Process_Mode ||
    ', txn_header_id => '   || P_Txn_Header_ID ||
    ', organization_id => ' || P_Organization_ID ||
    ', item_id => '         || P_Item_ID ||
    ', from_project_id => ' || P_From_Project_ID ||
    ', from_task_id => '    || P_From_Task_ID ||
    ', to_project_id => '   || P_To_Project_ID ||
    ', to_task_id => '      || P_To_Task_ID ||
    ', txn_date => '        || FND_DATE.Date_To_DisplayDT(P_Txn_Date) ||
    ', acct_period_id => '  || P_Acct_Period_ID ||
    ', txn_reason_id => '   || P_Txn_Reason_ID ||
    ', txn_reference => '   || P_Txn_Reference || ' )'
  , G_MODULE , FND_LOG.LEVEL_PROCEDURE);

  --
  -- Check API incompatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , P_api_version
                                    , l_api_name
                                    , G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize the message table if requested.
  --
  IF FND_API.TO_BOOLEAN( P_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- Set API return status to success
  --
  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get Current Open Accounting Period based on Transaction Date
  -- if not already done
  --
  IF ( P_Acct_Period_ID IS NULL ) THEN
    acct_period := Get_Acct_Period(P_Organization_ID , P_Txn_Date);
    PJM_DEBUG.Debug('acct_period => ' || acct_period);
  ELSE
    acct_period := P_Acct_Period_ID;
  END IF;

  --
  -- If open accounting period not found, error out
  --
  IF ( acct_period = 0 ) THEN
    FND_MESSAGE.set_name('INV' , 'INV_NO_OPEN_PERIOD');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( acct_period = -1 ) THEN
    FND_MESSAGE.set_name('INV' , 'INV_RETRIEVE_PERIOD');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Get Transaction Header ID if not already done
  --
  IF ( P_Txn_Header_ID IS NULL ) THEN
    txn_header_id := Get_Txn_Header;
    PJM_DEBUG.Debug('txn_header_id => ' || txn_header_id);
  ELSE
    txn_header_id := P_Txn_Header_ID;
  END IF;

  txn_count := 0;

  --
  -- Loop through all onhand quantity record for the item
  --
  PJM_DEBUG.Debug('Loop for onhand...');

  FOR ohrec IN onhand LOOP
    --
    -- Derive the destination locator based on current locator
    -- and transfer to project/task
    --
    PJM_PROJECT_LOCATOR.Get_DefaultProjectLocator
    ( P_Organization_ID    => P_Organization_ID
    , P_Locator_ID         => ohrec.locator_id
    , P_Project_ID         => P_To_Project_ID
    , P_Task_ID            => P_To_Task_ID
    , P_Project_Locator_ID => txfr_locator_id
    );

    PJM_DEBUG.Debug(
    'subinventory => ' || ohrec.subinventory_code ||
    ', locator_id => ' || ohrec.locator_id ||
    ', txfr_locator_id => ' || txfr_locator_id);

    --
    -- Call private function to create transaction
    --
    Create_Transfer_Transaction
    ( P_Txn_Header_ID     => txn_header_id
    , P_Process_Mode      => P_Process_Mode
    , P_Organization_ID   => P_Organization_ID
    , P_Item_ID           => P_Item_ID
    , P_Revision          => ohrec.revision
    , P_Lot_Number        => ohrec.lot_number
    , P_Txn_Quantity      => ohrec.txn_quantity
    , P_Subinventory_Code => ohrec.subinventory_code
    , P_From_Locator_ID   => ohrec.locator_id
    , P_To_Locator_ID     => txfr_locator_id
    , P_Txn_Date          => P_Txn_Date
    , P_Acct_Period_ID    => acct_period
    , P_Txn_Reason_ID     => P_Txn_Reason_ID
    , P_Txn_Reference     => P_Txn_Reference
    , P_DFF               => P_DFF
    , X_Return_Status     => X_Return_Status
    , X_Msg_Count         => X_Msg_Count
    , X_Msg_Data          => X_Msg_Data
    );

    IF ( X_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF ( X_Return_Status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    txn_count := txn_count + 1;

  END LOOP;

  X_Txn_Count := txn_count;

  X_Txn_Header_ID := txn_header_id;

  --
  -- Stanard commit check
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                           , p_data  => X_Msg_Data );

  PJM_DEBUG.Debug( l_api_name || ' completed'
                 , G_MODULE , FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO pjm_mass_transfer_item;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO pjm_mass_transfer_item;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

  WHEN OTHERS THEN
    ROLLBACK TO pjm_mass_transfer_item;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => 'ITEM_TRANSFER');
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );
END Item_Transfer;


PROCEDURE Mass_Transfer
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2
, P_commit                  IN            VARCHAR2
, X_Return_Status           OUT NOCOPY    VARCHAR2
, X_Msg_Count               OUT NOCOPY    NUMBER
, X_Msg_Data                OUT NOCOPY    VARCHAR2
, P_Transfer_ID             IN            NUMBER
, X_Txn_Header_ID           OUT NOCOPY    NUMBER
, X_Txn_Count               OUT NOCOPY    NUMBER
, X_Request_ID              OUT NOCOPY    NUMBER
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'MASS_TRANSFER';
l_api_version  CONSTANT NUMBER       := 1.0;

CURSOR h IS
  SELECT p.organization_id
  ,      p.acct_period_id
  ,      p.from_project_id
  ,      p.to_project_id
  ,      p.transfer_date
  ,      p.transfer_mode
  ,      p.inventory_item_id
  ,      p.category_set_id
  ,      p.category_id
  ,      p.transfer_reason_id
  ,      p.transfer_reference
  ,      p.process_mode
  ,      p.attribute_category
  ,      p.attribute1
  ,      p.attribute2
  ,      p.attribute3
  ,      p.attribute4
  ,      p.attribute5
  ,      p.attribute6
  ,      p.attribute7
  ,      p.attribute8
  ,      p.attribute9
  ,      p.attribute10
  ,      p.attribute11
  ,      p.attribute12
  ,      p.attribute13
  ,      p.attribute14
  ,      p.attribute15
  FROM   pjm_mass_transfers p
  WHERE  p.mass_transfer_id = P_Transfer_ID;

CURSOR l IS
  SELECT from_task_id
  ,      to_task_id
  FROM   pjm_mass_transfer_tasks
  WHERE  mass_transfer_id = P_Transfer_ID;

hrec             h%rowtype;
lrec             l%rowtype;

Txn_Count        NUMBER;
Txn_Header_IN    NUMBER;
Txn_Header_OUT   NUMBER;
DFF              PJM_MASS_TRANSFER_PUB.DFF_Rec_Type;

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT pjm_mass_transfer_item;

  PJM_DEBUG.Debug( 'Transfer_ID => ' || P_Transfer_ID
                 , G_MODULE , FND_LOG.LEVEL_EVENT );

  --
  -- Check API incompatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , P_api_version
                                    , l_api_name
                                    , G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize the message table if requested.
  --
  IF FND_API.TO_BOOLEAN( P_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- Set API return status to success
  --
  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  X_Txn_Count := 0;

  --
  -- Fetch transfer information
  --
  OPEN h;
  FETCH h INTO hrec;
  CLOSE h;

  FOR lrec IN l LOOP

    DFF.Category := hrec.attribute_category;
    DFF.Attr1    := hrec.attribute1;
    DFF.Attr2    := hrec.attribute2;
    DFF.Attr3    := hrec.attribute3;
    DFF.Attr4    := hrec.attribute4;
    DFF.Attr5    := hrec.attribute5;
    DFF.Attr6    := hrec.attribute6;
    DFF.Attr7    := hrec.attribute7;
    DFF.Attr8    := hrec.attribute8;
    DFF.Attr9    := hrec.attribute9;
    DFF.Attr10   := hrec.attribute10;
    DFF.Attr11   := hrec.attribute11;
    DFF.Attr12   := hrec.attribute12;
    DFF.Attr13   := hrec.attribute13;
    DFF.Attr14   := hrec.attribute14;
    DFF.Attr15   := hrec.attribute15;

    IF ( hrec.transfer_mode = G_TXFR_MODE_ONE_ITEM ) THEN
        --
        -- If Transfer Mode is Signle Item, call the single item
        -- transfer procedure directly
        --
        PJM_MASS_TRANSFER_PUB.Item_Transfer
        ( P_api_version      => 1.0
        , P_init_msg_list    => FND_API.G_FALSE
        , P_commit           => FND_API.G_FALSE
        , X_Return_Status    => X_Return_Status
        , X_Msg_Count        => X_Msg_Count
        , X_Msg_Data         => X_Msg_Data
        , P_Process_Mode     => hrec.process_mode
        , P_Txn_Header_ID    => Txn_Header_IN
        , P_Organization_ID  => hrec.organization_id
        , P_Item_ID          => hrec.inventory_item_id
        , P_From_Project_ID  => hrec.from_project_id
        , P_From_Task_ID     => lrec.from_task_id
        , P_To_Project_ID    => hrec.to_project_id
        , P_To_Task_ID       => lrec.to_task_id
        , P_Txn_Date         => hrec.transfer_date
        , P_Acct_Period_ID   => hrec.acct_period_id
        , P_Txn_Reason_ID    => hrec.transfer_reason_id
        , P_Txn_Reference    => hrec.transfer_reference
        , P_DFF              => DFF
        , X_Txn_Header_ID    => Txn_Header_OUT
        , X_Txn_Count        => Txn_Count
        );

    ELSE

        PJM_MASS_TRANSFER_PUB.Transfer
        ( P_api_version      => 1.0
        , P_init_msg_list    => FND_API.G_FALSE
        , P_commit           => FND_API.G_FALSE
        , X_Return_Status    => X_Return_Status
        , X_Msg_Count        => X_Msg_Count
        , X_Msg_Data         => X_Msg_Data
        , P_Process_Mode     => hrec.process_mode
        , P_Transfer_Mode    => hrec.transfer_mode
        , P_Txn_Header_ID    => Txn_Header_IN
        , P_Organization_ID  => hrec.organization_id
        , P_Item_ID          => hrec.inventory_item_id
        , P_Category_Set_ID  => hrec.category_set_id
        , P_Category_ID      => hrec.category_id
        , P_From_Project_ID  => hrec.from_project_id
        , P_From_Task_ID     => lrec.from_task_id
        , P_To_Project_ID    => hrec.to_project_id
        , P_To_Task_ID       => lrec.to_task_id
        , P_Txn_Date         => hrec.transfer_date
        , P_Acct_Period_ID   => hrec.acct_period_id
        , P_Txn_Reason_ID    => hrec.transfer_reason_id
        , P_Txn_Reference    => hrec.transfer_reference
        , P_DFF              => DFF
        , X_Txn_Header_ID    => Txn_Header_OUT
        , X_Txn_Count        => Txn_Count
        );

    END IF;

    X_Txn_Count := X_Txn_Count + Txn_Count;

    IF ( Txn_Header_IN IS NULL ) THEN
      Txn_Header_IN   := Txn_Header_OUT;
      X_Txn_Header_ID := Txn_Header_OUT;
    END IF;

  END LOOP;

  --
  -- Submit Request if process mode is Concurrent
  --

  IF ( X_Txn_Count > 0 AND hrec.process_mode = G_PROC_MODE_IMMEDIATE ) THEN

    FND_MESSAGE.Set_Name('PJM' , 'MXFR-CONC PROGRAM DESC');

    X_Request_ID := FND_REQUEST.Submit_Request
                   ( application => 'INV'
                   , program     => 'INCTCW'
                   , description => FND_MESSAGE.Get
                   , argument1   => X_Txn_Header_ID
                   , argument2   => '3' /* Process from MTI with full validation */
                   --
                   -- The following 3 arguments should not be needed; however,
                   -- the Inventory Transaction Worker fails without them
                   --
                   , argument3   => ''
                   , argument4   => ''
                   , argument5   => ''
                   );

  ELSE

    X_Request_ID := NULL;

  END IF;

  --
  -- Stanard commit check
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                           , p_data  => X_Msg_Data );

  PJM_DEBUG.Debug( l_api_name || ' completed'
                 , G_MODULE , FND_LOG.LEVEL_EVENT );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO pjm_mass_transfer;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO pjm_mass_transfer;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

  WHEN OTHERS THEN
    ROLLBACK TO pjm_mass_transfer;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => 'MASS_TRANSFER');
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );
END Mass_Transfer;

END PJM_MASS_TRANSFER_PUB;

/
