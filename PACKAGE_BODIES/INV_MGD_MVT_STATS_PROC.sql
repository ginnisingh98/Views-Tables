--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_STATS_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_STATS_PROC" AS
-- $Header: INVSTATB.pls 120.13.12010000.5 2010/01/11 10:29:20 abhissri ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVSTATB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of INV_MGD_MVT_STATS_PROC                                    |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Process_Transaction                                               |
--|     Process_INV_Transaction                                           |
--|     Process_SO_Transaction                                            |
--|     Process_TwoLeOneCntry_Txn                                         |
--|     Process_Triangulation_Txn                                         |
--|     Process_PO_Transaction                                            |
--|     Process_RMA_Transaction                                           |
--|     Update_Invoice_Info                                               |
--|     Update_PO_With_Correction                                         |
--|     Process_Pending_Transactions                                      |
--|     Process_IO_Arrival_Txn                                            |
--|     Update_PO_With_RTV                                                |
--|     Update_SO_With_RMA                                                |
--|                                                                       |
--| HISTORY                                                               |
--| 07-Nov-06  nesoni   Process_SO_Transaction method modified for bug    |
--|                     5440432 to calculate invoice for SO Arrival       |
--| 16/04/2007 nesoni   Bug 5920143. Added support for Include            |
--|                              Establishments.
--| 02/08/2008 ajmittal Bug 7165989 - Movement Statistics  RMA    |
--|                             Triangulation uptake.			  |
--|				Modified procs:Process_IO_Arrival_Txn,    |
--|				Process_RMA_Transaction			  |
--|				New procedure : Process_RMA_Triangulation |
--+=======================================================================

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_MGD_MVT_STATS_PROC';
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_STATS_PROC.';

--===================
-- GLOBAL VARIABLES
--===================
g_records_processed  NUMBER      := 0;
g_records_inserted   NUMBER      := 0;

--===================
-- PRIVATE PROCEDURES
--===================

/* 7165989 - New procedure added to process RMA Triangulation transactions */
--========================================================================
-- PROCEDURE : Process_RMA_Triangulation     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      RMA
-- COMMENT   : This processes all the RMA triangulation txn for the specified
--		legal entity where the RMA is booked
--========================================================================

PROCEDURE Process_RMA_Triangulation
( p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_stat_typ_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_api_name CONSTANT    VARCHAR2(30) := 'Process_RMA_Triangulation';
  l_error                VARCHAR2(600);
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(2000);
  l_insert_status        VARCHAR2(10);
  l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  l_return_status        VARCHAR2(1);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_movement_transaction  := p_movement_transaction;
  l_stat_typ_transaction  := p_stat_typ_transaction;

  INV_MGD_MVT_UTILS_PKG.Mvt_Stats_Util_Info
  ( p_stat_typ_transaction => l_stat_typ_transaction
  , x_movement_transaction => l_movement_transaction
  , x_return_status        => l_return_status
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
		    , G_MODULE_NAME || l_api_name
		      || '.Failed when call mvt_stats_util_info'
		    ,'Failed'
		    );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    l_movement_transaction.customer_vat_number :=
    INV_MGD_MVT_UTILS_PKG.Get_Cust_VAT_Number
    (l_movement_transaction.bill_to_site_use_id);

    IF l_movement_transaction.invoice_id IS NULL
    THEN
      l_movement_transaction.invoice_quantity        := NULL;
      l_movement_transaction.financial_document_flag := 'MISSING';
    ELSE
      l_movement_transaction.financial_document_flag
					  := 'PROCESSED_INCLUDED';
    END IF;

    /* Set the parameters for the RMA Dispatch transaction */
    l_movement_transaction.movement_type := 'D';
    l_movement_transaction.dispatch_territory_code :=
      INV_MGD_MVT_UTILS_PKG.Get_Org_Location(p_warehouse_id => l_movement_transaction.sold_from_org_id);
    l_movement_transaction.destination_territory_code :=
      INV_MGD_MVT_UTILS_PKG.Get_Org_Location(p_warehouse_id => l_movement_transaction.organization_id);
    /* triangulation country would be the country where the RMA was created/booked */
    l_movement_transaction.triangulation_country_code := l_movement_transaction.dispatch_territory_code;

    INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
    (p_api_version_number   => 1.0
    ,p_init_msg_list        => FND_API.G_FALSE
    ,x_movement_transaction => l_movement_transaction
    ,x_msg_count            => x_msg_count
    ,x_msg_data             => x_msg_data
    ,x_return_status        => l_insert_status
   );
 END IF;



  IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
  THEN
      COMMIT;
  END IF;
  g_records_processed     := g_records_processed +1;
  g_records_inserted     := g_records_inserted +1;
  l_movement_transaction  := p_movement_transaction;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Unexpected exception'
                    , l_error
                    );
    END IF;

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , l_error
                    );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Others exception in '||l_api_name
                             );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;
    RAISE;

END Process_RMA_Triangulation;
--========================================================================
-- PROCEDURE : Process_Transaction     PRIVATE
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              message text
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      Transaction type (SO,PO etc)
-- COMMENT   :
--             This processes all the transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Process_Transaction
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_legal_entity_id      IN  NUMBER
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_source_type          IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(100);
  l_movement_transaction  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  x_movement_transaction  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_api_name CONSTANT VARCHAR2(30) := 'Process_Transaction';
  l_debug    CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.Value('AFLOG_ENABLED'),'N');
  l_error             VARCHAR2(600);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the setup info to determine if the transactions are to be
  -- processed further.

  l_movement_transaction.entity_org_id := p_legal_entity_id;

  -- Process the INV transaction
  IF p_source_type IN ('ALL','INV') THEN

    Process_INV_Transaction
         ( p_movement_transaction => l_movement_transaction
         , p_start_date           => p_start_date
         , p_end_date             => p_end_date
         , p_transaction_type     => p_source_type
         , x_return_status        => l_return_status
         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_api_name
                        || '.Failed in process_inv_transaction'
                      ,'Failed'
                      );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  IF p_source_type IN ('ALL','SO','PO','RMA','RTV')
  THEN
    -- Update the invoice info before retrieving new records.
    Update_Invoice_Info
      ( p_movement_transaction => l_movement_transaction
      , p_start_date           => p_start_date
      , p_end_date             => p_end_date
      , p_transaction_type     => p_source_type
      , x_return_status        => l_return_status
      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_api_name
                        || '.Failed in Update_Invoice_Info'
                      ,'Failed'
                      );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  /*bug 8294483 Process Pending Transaction Shifted to End*/
  /*
  --Process pending transactions
    Process_Pending_Transaction
      ( p_movement_transaction => l_movement_transaction
      , p_start_date           => p_start_date
      , p_end_date             => p_end_date
      , p_transaction_type     => p_source_type
      , x_return_status        => l_return_status
      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_api_name
                        || '.Failed in Process_Pending_Transactions'
                      ,'Failed'
                      );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;*/
    /*End bug 8294483*/
  END IF;

  -- Process the SO transaction
  IF p_source_type IN ('ALL','SO')
  THEN
    Process_SO_Transaction
         ( p_movement_transaction => l_movement_transaction
         , p_start_date           => p_start_date
         , p_end_date             => p_end_date
         , p_transaction_type     => p_source_type
         , x_return_status        => l_return_status
         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_api_name
                        || '.Failed in Process_SO_Transaction'
                      ,'Failed'
                      );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Process_Triangulation_Txn
         ( p_movement_transaction => l_movement_transaction
         , p_start_date           => p_start_date
         , p_end_date             => p_end_date
         , p_transaction_type     => p_source_type
         , x_return_status        => l_return_status
         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_api_name
                        || '.Failed in Process_Triangulation_Txn'
                      ,'Failed'
                      );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF p_source_type IN ('ALL','IO') THEN

    l_movement_transaction.document_source_type := 'IO';
    Process_SO_Transaction
         ( p_movement_transaction => l_movement_transaction
         , p_start_date           => p_start_date
         , p_end_date             => p_end_date
         , p_transaction_type     => p_source_type
         , x_return_status        => l_return_status
         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_api_name
                        || '.Failed in Process_SO_Trangsaction - IO'
                      ,'Failed'
                      );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Process_IO_Arrival_Txn
       ( p_movement_transaction => l_movement_transaction
         , p_start_date           => p_start_date
         , p_end_date             => p_end_date
         , p_transaction_type     => p_source_type
         , x_return_status        => l_return_status
         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_api_name
                        || '.Failed in Process_IO_Arrival_Txn'
                      ,'Failed'
                      );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;


  -- Process the PO transaction
  IF p_source_type IN ('ALL','PO','RTV') THEN
    Update_PO_With_Correction
       ( p_legal_entity_id      => p_legal_entity_id
       , p_start_date           => p_start_date
       , p_end_date             => p_end_date
       , p_transaction_type     => p_source_type
       , x_return_status        => l_return_status
       );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_api_name
                        || '.Failed in Update_PO_With_Correction'
                      ,'Failed'
                      );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Process_PO_Transaction
         ( p_movement_transaction => l_movement_transaction
         , p_start_date           => p_start_date
         , p_end_date             => p_end_date
         , p_transaction_type     => p_source_type
         , x_return_status        => l_return_status
         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_api_name
                        || '.Failed in Process_PO_Transaction'
                      ,'Failed'
                      );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;


  -- Process the RMA transaction
  IF p_source_type IN ('ALL','RMA') THEN
    Process_RMA_Transaction
         ( p_movement_transaction => l_movement_transaction
         , p_start_date           => p_start_date
         , p_end_date             => p_end_date
         , p_transaction_type     => p_source_type
         , x_return_status        => l_return_status
         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_api_name
                        || '.Failed in Process_RMA_Transaction'
                      ,'Failed'
                      );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
    /*bug 8294483 Process Pending Transaction added after all new record processed*/
  IF p_source_type IN ('ALL','SO','PO','RMA','RTV')
  THEN
       --Process pending transactions
    Process_Pending_Transaction
      ( p_movement_transaction => l_movement_transaction
      , p_start_date           => p_start_date
      , p_end_date             => p_end_date
      , p_transaction_type     => p_source_type
      , x_return_status        => l_return_status
      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                      , G_MODULE_NAME || l_api_name
                        || '.Failed in Process_Pending_Transactions'
                      ,'Failed'
                      );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
 /*End bug 8294483*/
  /*INV_MGD_RPT_GENERATOR_PROC.Print_Transaction_Proxy_Stats;*/

  IF l_debug = 'Y'
  THEN
    FND_FILE.put_line
    ( FND_FILE.log
    , '< ***** Records Processed:  '||g_records_processed
      );

    FND_FILE.put_line
    ( FND_FILE.log
    , '< ***** Records Inserted:   '||g_records_inserted
      );
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Unexpected exception'
                    , l_error
                    );
    END IF;

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , l_error
                    );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Others exception in '||l_api_name
                             );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;
    RAISE;

END Process_Transaction;

--========================================================================
-- PROCEDURE : Process_Transaction     OVERLOADED
-- PARAMETERS:
--             x_return_status         return status
--             p_movement_transaction  Movement Transaction record
-- COMMENT   :
--             This procedure is overloaded so that the form can use
--             this proceure to directly enter data in the mvt stats
--             table.
--========================================================================

PROCEDURE Process_Transaction
( p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
IS
   l_return_status         VARCHAR2(1);
   l_movement_transaction  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(100);
   l_api_name CONSTANT VARCHAR2(300) := 'Process_Transaction (OVERLOADED)';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  l_movement_transaction  := p_movement_transaction;

IF l_movement_transaction.document_source_type = 'INV' THEN

   Process_INV_Transaction
   ( p_movement_transaction => l_movement_transaction
   , p_start_date           => l_movement_transaction.transaction_date
   , p_end_date             => l_movement_transaction.transaction_date
   , p_transaction_type     => l_movement_transaction.document_source_type
   , x_return_status        => l_return_status
    );

ELSIF l_movement_transaction.document_source_type='PO' THEN

   Process_PO_Transaction
   ( p_movement_transaction => l_movement_transaction
   , p_start_date           => l_movement_transaction.transaction_date
   , p_end_date             => l_movement_transaction.transaction_date
   , p_transaction_type     => l_movement_transaction.document_source_type
   , x_return_status        => l_return_status
    );

   Process_RMA_Transaction
   ( p_movement_transaction => l_movement_transaction
   , p_start_date           => l_movement_transaction.transaction_date
   , p_end_date             => l_movement_transaction.transaction_date
   , p_transaction_type     => l_movement_transaction.document_source_type
   , x_return_status        => l_return_status
    );

ELSIF l_movement_transaction.document_source_type='SO' THEN
   Process_SO_Transaction
   ( p_movement_transaction => l_movement_transaction
   , p_start_date           => l_movement_transaction.transaction_date
   , p_end_date             => l_movement_transaction.transaction_date
   , p_transaction_type     => l_movement_transaction.document_source_type
   , x_return_status        => l_return_status
    );
ELSE
  NULL;

END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  RAISE;

  WHEN NO_DATA_FOUND THEN
  RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Process_Transaction (OVERLOADED)'
                             );
    RAISE;
    END IF;

END Process_Transaction;

--========================================================================
-- PROCEDURE : Process_INV_Transaction     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      INV
-- COMMENT   :
--             This processes all the INV transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Process_INV_Transaction
( p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  inv_crsr               INV_MGD_MVT_DATA_STR.invCurTyp;
  setup_crsr             INV_MGD_MVT_DATA_STR.setupCurTyp;
  ref_crsr               INV_MGD_MVT_DATA_STR.setupCurTyp;
  l_material_transaction INV_MGD_MVT_DATA_STR.Material_Transaction_Rec_Type;
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_movement_transaction_outer INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(2000);
  l_insert_flag          VARCHAR2(1);
  l_insert_status        VARCHAR2(10);
  l_movement_id          NUMBER;
  l_subinv_code          VARCHAR2(10);
  l_transfer_subinv      VARCHAR2(10);
  l_subinv_terr_code     VARCHAR2(2);
  l_transfer_subinv_terr_code VARCHAR2(2);
  l_org_terr_code             VARCHAR2(2);
  l_transfer_org_terr_code    VARCHAR2(2);
  l_le_terr_code              VARCHAR2(2);
  l_return_status        VARCHAR2(1);
  l_api_name CONSTANT VARCHAR2(30) := 'Process_INV_Transaction';
  l_error             VARCHAR2(600);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_movement_transaction  := p_movement_transaction;

  -- Get all the Inventory Transactions between the specified date ranges
  INV_MGD_MVT_INV_MDTR.Get_INV_Transactions
  ( inv_crsr                => inv_crsr
  , p_movement_transaction => l_movement_transaction
  , p_start_date           => p_start_date
  , p_end_date             => p_end_date
  , x_return_status        => l_return_status);

  IF l_return_status = 'Y'
  THEN
    <<l_outer>>
    LOOP
      --Reset the movement record for each transaction
      l_movement_transaction  := p_movement_transaction;
      l_movement_id := NULL;

      FETCH inv_crsr INTO
        l_movement_transaction.mtl_transaction_id
      , l_material_transaction.transaction_type_id
      , l_material_transaction.transaction_action_id
      , l_movement_transaction.transfer_organization_id
      , l_movement_transaction.transaction_date
      , l_movement_transaction.organization_id
      , l_movement_transaction.transaction_quantity
      , l_subinv_code
      , l_transfer_subinv;

      EXIT WHEN inv_crsr%NOTFOUND;

      SAVEPOINT INV_Transaction;

      --Timezone support, convert server transaction date to legal entity timezone
      l_movement_transaction.transaction_date :=
      INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Server
      ( p_trxn_date => l_movement_transaction.transaction_date
      , p_le_id     => l_movement_transaction.entity_org_id
      );

      -- Get the setup info from the stat type usages table for the
      -- specified legal entity.
      INV_MGD_MVT_SETUP_MDTR.Get_Setup_Context
      ( p_legal_entity_id      => l_movement_transaction.entity_org_id
       , p_movement_transaction => l_movement_transaction
       , x_return_status        => l_return_status
       , setup_crsr             => setup_crsr
       );

      --Back up the movement statistics record
      l_movement_transaction_outer := l_movement_transaction;

      <<l_inner>>
      LOOP
        --Reset movement transaction record, fix bug 2888046
        l_movement_transaction := l_movement_transaction_outer;

        FETCH setup_crsr INTO
          l_movement_transaction.zone_code
        , l_movement_transaction.usage_type
        , l_movement_transaction.stat_type
        , l_stat_typ_transaction.reference_period_rule
        , l_stat_typ_transaction.pending_invoice_days
        , l_stat_typ_transaction.prior_invoice_days
        , l_stat_typ_transaction.triangulation_mode;

        EXIT  l_inner WHEN setup_crsr%NOTFOUND;

        INV_MGD_MVT_SETUP_MDTR.Get_Reference_Context
        ( p_legal_entity_id      => l_movement_transaction.entity_org_id
        , p_start_date           => p_start_date
        , p_end_date             => p_end_date
        , p_transaction_type     => p_transaction_type
        , p_movement_transaction => l_movement_transaction
        , x_return_status        => l_return_status
        , ref_crsr               => ref_crsr
        );

        -- Reset the movement_id before fetching the transaction
        l_movement_transaction.movement_id := NULL;

        -- Bug:5920143. Added new parameter include_establishments in result.
        FETCH ref_crsr INTO
          l_movement_transaction.zone_code
        , l_movement_transaction.usage_type
        , l_movement_transaction.stat_type
        , l_stat_typ_transaction.start_period_name
        , l_stat_typ_transaction.end_period_name
        , l_stat_typ_transaction.period_set_name
        , l_stat_typ_transaction.period_type
        , l_stat_typ_transaction.weight_uom_code
        , l_stat_typ_transaction.conversion_type
        , l_stat_typ_transaction.attribute_rule_set_code
        , l_stat_typ_transaction.alt_uom_rule_set_code
        , l_stat_typ_transaction.start_date
        , l_stat_typ_transaction.end_date
        , l_stat_typ_transaction.category_set_id
        , l_movement_transaction.set_of_books_period
        , l_stat_typ_transaction.gl_currency_code
        , l_movement_transaction.gl_currency_code
        , l_stat_typ_transaction.conversion_option
        , l_stat_typ_transaction.triangulation_mode
        , l_stat_typ_transaction.reference_period_rule
        , l_stat_typ_transaction.pending_invoice_days
        , l_stat_typ_transaction.prior_invoice_days
        , l_stat_typ_transaction.returns_processing
        , l_stat_typ_transaction.kit_method
        , l_stat_typ_transaction.include_establishments;

        IF ref_crsr%NOTFOUND
        THEN
          --the transaction is not inside of start period and end period
          --so not create transaction
          CLOSE ref_crsr;
        ELSE
          INV_MGD_MVT_STATS_PVT.Init_Movement_Record
          ( x_movement_transaction => l_movement_transaction);

          --Get subinventory location fix bug 2683302
          l_subinv_terr_code :=
          INV_MGD_MVT_UTILS_PKG.Get_Subinv_Location
          ( p_warehouse_id => l_movement_transaction.organization_id
          , p_subinv_code  => l_subinv_code);

          l_transfer_subinv_terr_code :=
          INV_MGD_MVT_UTILS_PKG.Get_Subinv_Location
          ( p_warehouse_id => l_movement_transaction.transfer_organization_id
          , p_subinv_code  => l_transfer_subinv);

          --Get organization location
          l_org_terr_code :=
          INV_MGD_MVT_UTILS_PKG.Get_Org_Location
          (p_warehouse_id => l_movement_transaction.organization_id);

          l_transfer_org_terr_code :=
          INV_MGD_MVT_UTILS_PKG.Get_Org_Location
          (p_warehouse_id => l_movement_transaction.transfer_organization_id);

          --Get legal entity location
          -- Bug: 5920143. Calculate LE Territory code only when
          -- user has selected Include Establishments as No
          IF(l_stat_typ_transaction.include_establishments = 'N')
          THEN
            l_le_terr_code :=
              INV_MGD_MVT_UTILS_PKG.Get_LE_Location
              (p_le_id => l_movement_transaction.entity_org_id);
           END IF;
          -- For every record fetched get the dispatch and destination territory
          -- codes.
          IF ((l_material_transaction.transaction_type_id = 12 AND
              l_material_transaction.transaction_action_id = 12)
             OR
             (l_material_transaction.transaction_type_id IN (2,3) AND
              l_material_transaction.transaction_action_id IN (2,3) AND
              l_movement_transaction.transaction_quantity > 0))
          THEN
            l_movement_transaction.dispatch_territory_code :=
            NVL(l_transfer_subinv_terr_code, l_transfer_org_terr_code);

            l_movement_transaction.destination_territory_code :=
            NVL(l_subinv_terr_code, l_org_terr_code);
          ELSE
            l_movement_transaction.dispatch_territory_code :=
            NVL(l_subinv_terr_code, l_org_terr_code);

            l_movement_transaction.destination_territory_code :=
            NVL(l_transfer_subinv_terr_code, l_transfer_org_terr_code);
          END IF;

          -- If the stat type is ESL ignore the INV transactions.
	  -- Bug: 5920143 Validation that LE Territory Code and
          -- Shipping Org Territory Code should be same, is needed only when
          -- user has selected Include Establishments as No.
          IF ((UPPER(l_movement_transaction.stat_type) = 'ESL' AND
    	     UPPER(l_movement_transaction.usage_type) = 'INTERNAL')
             OR
              ((l_stat_typ_transaction.include_establishments = 'N')
              AND (l_le_terr_code <> NVL(l_subinv_terr_code, l_org_terr_code))))
          THEN
            l_insert_flag := 'N';
          ELSE
            l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
            ( p_movement_transaction => l_movement_transaction);
	        END IF;

          -- Process the inventory transaction
          IF l_insert_flag = 'Y'
          THEN
            INV_MGD_MVT_INV_MDTR.Get_INV_Details
            ( x_movement_transaction => l_movement_transaction
            , x_return_status        => l_return_status
            );

            IF l_return_status = 'Y'
            THEN
              INV_MGD_MVT_UTILS_PKG.Mvt_Stats_Util_Info
              ( p_stat_typ_transaction => l_stat_typ_transaction
              , x_movement_transaction => l_movement_transaction
              , x_return_status        => l_return_status
              );

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS
              THEN
                IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                                , G_MODULE_NAME || l_api_name
                                  || '.Failed when call mvt_stats_util_info'
                                ,'Failed'
                                );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSE

                --Get legal entity vat number stored in customer_vat_number
                l_movement_transaction.customer_vat_number :=
                INV_MGD_MVT_UTILS_PKG.Get_Org_VAT_Number
                ( p_entity_org_id => l_movement_transaction.entity_org_id
                , p_date          => l_movement_transaction.transaction_date);

                INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
                  ( p_api_version_number    => 1.0
                  , p_init_msg_list        => FND_API.G_FALSE
                  , x_movement_transaction => l_movement_transaction
                  , x_msg_count            => x_msg_count
                  , x_msg_data             => x_msg_data
                  , x_return_status        => l_insert_status
                  );

                --yawang fix bug 2268875 only insert record when successfully
                IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
                THEN
                  l_movement_id      := l_movement_transaction.movement_id;
                  g_records_inserted     := g_records_inserted +1;
                END IF;
              END IF;
            END IF; --< end of IF from Get_INV_Details >
          END IF;
          CLOSE ref_crsr;
        END IF;
      END LOOP l_inner;
      CLOSE setup_crsr;

      -- If the insert procedure did not error out, update the transactions and
      -- set the flag to PROCESSED.
      IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
      THEN
        l_movement_transaction.movement_id := l_movement_id;

        INV_MGD_MVT_INV_MDTR.Update_INV_Transactions
        ( p_movement_transaction => l_movement_transaction
        , x_return_status        => l_return_status );

        COMMIT;
      ELSE
        ROLLBACK TO SAVEPOINT INV_Transaction;
      END IF;

      l_movement_transaction  := p_movement_transaction;
      g_records_processed     := g_records_processed +1;
    END LOOP l_outer;
    CLOSE inv_crsr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Unexpected exception'
                    , l_error
                    );
    END IF;

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , l_error
                    );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Others exception in '||l_api_name
                             );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;
    RAISE;

END Process_INV_Transaction;


--========================================================================
-- PROCEDURE : Process_SO_Transaction     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      SO
-- COMMENT   :
--             This processes all the SO transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Process_SO_Transaction
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT    VARCHAR2(30) := 'Process_SO_Transaction';
  l_error                VARCHAR2(600);
  so_crsr                INV_MGD_MVT_DATA_STR.soCurTyp;
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_shipment_transaction INV_MGD_MVT_DATA_STR.Shipment_Transaction_Rec_Type;
  l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  l_movement_transaction_outer INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  setup_crsr             INV_MGD_MVT_DATA_STR.setupCurTyp;
  ref_crsr               INV_MGD_MVT_DATA_STR.setupCurTyp;
  l_insert_flag          VARCHAR2(1);
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(2000);
  l_so_le_id             NUMBER;
  l_insert_status        VARCHAR2(10);
  l_so_le_terri_code     VARCHAR2(10);
  l_shipping_le_terri_code VARCHAR2(10);
  l_shipping_org_terri_code VARCHAR2(10);
  l_customer_terri_code  VARCHAR2(10);
  l_movement_id          NUMBER;
  --l_trans_date           DATE;
  l_cross_le_status      VARCHAR2(20);
  l_mvt_stat_status      VARCHAR2(20);
  l_return_status        VARCHAR2(1);

  --Added for bug4185582, 4238563
  l_item_type_code       VARCHAR2(30);
  l_link_to_line_id      NUMBER;
  l_line_id              NUMBER;
  l_need_create_kit      VARCHAR2(1);
  l_kit_record_status    VARCHAR2(1);
  l_parent_item_type_code VARCHAR2(30);
  l_shipped_qty          NUMBER;

  CURSOR l_parent
  IS
  SELECT
    item_type_code
  , NVL(shipped_quantity, fulfilled_quantity)
  FROM
    oe_order_lines_all
  WHERE line_id = l_link_to_line_id;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_movement_transaction  := p_movement_transaction;

  -- Call the transaction proxy which processes all the transactions.
  INV_MGD_MVT_SO_MDTR.Get_SO_Transactions
  (  so_crsr                => so_crsr
   , p_movement_transaction => l_movement_transaction
   , p_start_date           => p_start_date
   , p_end_date             => p_end_date
   , x_return_status        => l_return_status);

  IF l_return_status = 'Y'
  THEN
  <<l_outer>>
  LOOP
    --Reset the movement record for each picking line
    l_movement_transaction  := p_movement_transaction;
    l_movement_id := NULL;

    FETCH so_crsr
    INTO l_movement_transaction.picking_line_detail_id
      ,  l_movement_transaction.organization_id
      ,  l_movement_transaction.ship_to_site_use_id
      ,  l_movement_transaction.transaction_date
      ,  l_movement_transaction.order_line_id
      ,  l_movement_transaction.order_number
      ,  l_movement_transaction.bill_to_site_use_id
      ,  l_item_type_code
      ,  l_link_to_line_id;

    EXIT WHEN so_crsr%NOTFOUND;

    SAVEPOINT SO_Transaction;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                     , G_MODULE_NAME ||'.The SO num,ln id,pk line id,txn date are '
                       ||l_movement_transaction.order_number
                       ||','||l_movement_transaction.order_line_id
                       ||','||l_movement_transaction.picking_line_detail_id
                       ||','||l_movement_transaction.transaction_date
                     ,'debug msg');
    END IF;

    --Timezone support, convert server transaction date to legal entity timezone
    l_movement_transaction.transaction_date :=
    INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Server
    ( p_trxn_date => l_movement_transaction.transaction_date
    , p_le_id     => l_movement_transaction.entity_org_id
    );

    INV_MGD_MVT_SETUP_MDTR.Get_Setup_Context
    (  p_legal_entity_id      => l_movement_transaction.entity_org_id
     , p_movement_transaction => l_movement_transaction
     , x_return_status        => l_return_status
     , setup_crsr             => setup_crsr
     );

    --Back up the movement statistics record
    l_movement_transaction_outer := l_movement_transaction;

    <<l_inner>>
    LOOP
      --Reset movement transaction record
      l_movement_transaction := l_movement_transaction_outer;

      FETCH setup_crsr INTO
          l_movement_transaction.zone_code
        , l_movement_transaction.usage_type
        , l_movement_transaction.stat_type
        , l_stat_typ_transaction.reference_period_rule
        , l_stat_typ_transaction.pending_invoice_days
        , l_stat_typ_transaction.prior_invoice_days
        , l_stat_typ_transaction.triangulation_mode;

      EXIT  l_inner WHEN setup_crsr%NOTFOUND;

      IF NVL(l_stat_typ_transaction.reference_period_rule,'SHIPMENT_BASED')
                                                       = 'INVOICE_BASED'
         AND NVL(l_movement_transaction.document_source_type,'SO') = 'SO'
      THEN
        IF l_movement_transaction.document_source_type IS NULL
        THEN
          l_movement_transaction.document_source_type := 'SO';
        END IF;

        l_line_id := l_movement_transaction.order_line_id;

        --For included item, use parent invoice info
        IF l_item_type_code = 'INCLUDED'
        THEN
          l_movement_transaction.order_line_id := l_link_to_line_id;
        END IF;

        INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
        ( p_stat_typ_transaction => l_stat_typ_transaction
        , x_movement_transaction => l_movement_transaction
        );

        INV_MGD_MVT_FIN_MDTR. Get_Reference_Date
        ( p_stat_typ_transaction  => l_stat_typ_transaction
        , x_movement_transaction  => l_movement_transaction
        );

        l_movement_transaction.transaction_date :=
          l_movement_transaction.reference_date;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                        , G_MODULE_NAME ||'.The reference txn date is '
                          ||l_movement_transaction.transaction_date
                        ,'debug msg');
        END IF;

        --Set back the included item line id
        l_movement_transaction.order_line_id := l_line_id;
      END IF;

      INV_MGD_MVT_SETUP_MDTR.Get_Reference_Context
      ( p_legal_entity_id       => l_movement_transaction.entity_org_id
       , p_start_date           => p_start_date
       , p_end_date             => p_end_date
       , p_transaction_type     => p_transaction_type
       , p_movement_transaction => l_movement_transaction
       , x_return_status        => l_return_status
       , ref_crsr               => ref_crsr
      );

      --Reset the movement_id before fetching the transaction
      l_movement_transaction.movement_id := NULL;

      -- Bug:5920143. Added new parameter include_establishments in result.
      FETCH ref_crsr INTO
          l_movement_transaction.zone_code
        , l_movement_transaction.usage_type
        , l_movement_transaction.stat_type
        , l_stat_typ_transaction.start_period_name
        , l_stat_typ_transaction.end_period_name
        , l_stat_typ_transaction.period_set_name
        , l_stat_typ_transaction.period_type
        , l_stat_typ_transaction.weight_uom_code
        , l_stat_typ_transaction.conversion_type
        , l_stat_typ_transaction.attribute_rule_set_code
        , l_stat_typ_transaction.alt_uom_rule_set_code
        , l_stat_typ_transaction.start_date
        , l_stat_typ_transaction.end_date
        , l_stat_typ_transaction.category_set_id
        , l_movement_transaction.set_of_books_period
        , l_stat_typ_transaction.gl_currency_code
        , l_movement_transaction.gl_currency_code
        , l_stat_typ_transaction.conversion_option
        , l_stat_typ_transaction.triangulation_mode
        , l_stat_typ_transaction.reference_period_rule
        , l_stat_typ_transaction.pending_invoice_days
        , l_stat_typ_transaction.prior_invoice_days
        , l_stat_typ_transaction.returns_processing
        , l_stat_typ_transaction.kit_method
        , l_stat_typ_transaction.include_establishments;

      IF ref_crsr%NOTFOUND
      THEN
        -- the transaction is not inside of start period and
        -- end period so not create transaction
        CLOSE ref_crsr;
      ELSE
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                        , G_MODULE_NAME ||'.The usg,stat type,currency,tri mode,ref rule is '
                         ||l_movement_transaction.usage_type
                         ||','||l_movement_transaction.stat_type
                         ||','||l_stat_typ_transaction.gl_currency_code
                         ||','||l_stat_typ_transaction.triangulation_mode
                         ||','||l_stat_typ_transaction.reference_period_rule
                       ,'debug msg');
        END IF;

        INV_MGD_MVT_STATS_PVT.Init_Movement_Record
        (x_movement_transaction => l_movement_transaction);

        --Get legal entity where this SO is created
        l_so_le_id := INV_MGD_MVT_UTILS_PKG.Get_SO_Legal_Entity
        (p_order_line_id => l_movement_transaction.order_line_id);

        --Find out the territory code
        l_so_le_terri_code :=
          INV_MGD_MVT_UTILS_PKG.Get_LE_Location
          (p_le_id => l_so_le_id);

        l_shipping_le_terri_code :=
          INV_MGD_MVT_UTILS_PKG.Get_LE_Location
          (p_le_id => l_movement_transaction.entity_org_id);

        l_shipping_org_terri_code :=
          INV_MGD_MVT_UTILS_PKG.Get_Org_Location
          (p_warehouse_id => l_movement_transaction.organization_id);

        l_customer_terri_code :=
          INV_MGD_MVT_UTILS_PKG.Get_Site_Location
          (p_site_use_id =>l_movement_transaction.ship_to_site_use_id);

        -- If cross legal entity transaction,the destination
        -- territory code is depend on if it's invoiced based
        -- triangulation mode
        IF (l_so_le_id IS NOT NULL
          AND l_so_le_id <> l_movement_transaction.entity_org_id
          AND NVL(l_stat_typ_transaction.triangulation_mode,
              'INVOICE_BASED') = 'INVOICE_BASED')
        THEN
          l_movement_transaction.dispatch_territory_code := l_shipping_le_terri_code;
          l_movement_transaction.destination_territory_code := l_so_le_terri_code;
        ELSE
          -- Regular SO or shipment based cross legal entity transaction
          l_movement_transaction.dispatch_territory_code := l_shipping_org_terri_code;
          l_movement_transaction.destination_territory_code := l_customer_terri_code;
        END IF;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_MODULE_NAME
                         ||'.The so le,shp le,shp org,cust,dest,disp terr code are '
                         ||l_so_le_terri_code||','||l_shipping_le_terri_code
                         ||','||l_shipping_org_terri_code||','||l_customer_terri_code
                         ||','||l_movement_transaction.destination_territory_code
                         ||','||l_movement_transaction.dispatch_territory_code
                       ,'debug msg');
        END IF;

        --Added for bug4185582, 4238563, find out if parent is KIT
        OPEN l_parent;
        FETCH l_parent INTO
          l_parent_item_type_code
        , l_shipped_qty;
        CLOSE l_parent;

        --Find out if we need to treat this develivery as kit
        IF (l_item_type_code = 'INCLUDED'
           AND l_parent_item_type_code = 'KIT'
           AND l_shipped_qty IS NOT NULL
           AND l_stat_typ_transaction.kit_method = 'KIT')
        THEN
          l_need_create_kit := 'Y';
        ELSE
          l_need_create_kit := 'N';
        END IF;

        --Find out if there is already a movement record created for this kit
        --if no, set l_kit_record to 'N' else set to 'Y'
        l_kit_record_status := INV_MGD_MVT_SO_MDTR.Get_KIT_Status
        (p_delivery_detail_id => l_movement_transaction.picking_line_detail_id);
        --End of bug 4185582, 4238563.

        --Only create record for organization located in the same country as legal entity
        --If kit record has been created, do not need to create again
	-- Bug:5920143. Validation that LE Territory Code and
        -- Shipping Org Territory Code should be same, is needed only when
        -- user has selected Include Establishments as No.
        IF (((l_shipping_le_terri_code <> l_shipping_org_terri_code) AND
           (l_stat_typ_transaction.include_establishments = 'N'))
           OR (l_need_create_kit = 'Y' AND l_kit_record_status = 'Y'))
        THEN
          l_insert_flag := 'N';
        ELSE
          l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
          ( p_movement_transaction => l_movement_transaction);
        END IF;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_MODULE_NAME
                         ||'.The need crt kit,kit rec status,insert flg are '
                         ||l_need_create_kit||','||l_kit_record_status
                         ||','||l_insert_flag
                       ,'debug msg');
        END IF;

        -- Process the SO transaction
        IF l_insert_flag = 'Y'
        THEN
          INV_MGD_MVT_SO_MDTR.Get_SO_Details
           (x_movement_transaction => l_movement_transaction
          ,x_return_status        => l_return_status
           );

          IF l_need_create_kit = 'Y'
          THEN
            INV_MGD_MVT_SO_MDTR.Get_KIT_SO_Details
            ( p_link_to_line_id => l_link_to_line_id
            , x_movement_transaction => l_movement_transaction
            );
          END IF;


          IF l_return_status <> 'Y'
          THEN
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                            , G_MODULE_NAME || l_api_name
                              || '.Failed when call get_so_details'
                            ,'Failed'
                            );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSE
            INV_MGD_MVT_UTILS_PKG.Mvt_Stats_Util_Info
            (p_stat_typ_transaction => l_stat_typ_transaction
            ,x_movement_transaction => l_movement_transaction
            ,x_return_status        => l_return_status
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
              IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
              THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                              , G_MODULE_NAME || l_api_name
                                || '.Failed when call mvt_stats_util_info'
                              ,'Failed'
                              );
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
              l_movement_transaction.customer_vat_number :=
                INV_MGD_MVT_UTILS_PKG.Get_Cust_VAT_Number
                (l_movement_transaction.bill_to_site_use_id);

              IF l_movement_transaction.document_source_type <> 'IO'
              THEN
                IF l_movement_transaction.invoice_id IS NULL
                THEN
                  l_movement_transaction.invoice_quantity        := NULL;
                  l_movement_transaction.financial_document_flag := 'MISSING';
                ELSE
                  l_movement_transaction.financial_document_flag := 'PROCESSED_INCLUDED';
                END IF;
              END IF;

              -- Clear existing movement id if the mvt_stat_status is
              -- 'FORDISP in wsh_delivery_details table, otherwise
              -- the existing movement id will be populated as parent
              -- movement id for new record and we don't want that
              IF l_movement_transaction.picking_line_detail_id IS NOT NULL
              THEN
                SELECT mvt_stat_status
                INTO   l_mvt_stat_status
                FROM   wsh_delivery_details_ob_grp_v
                WHERE  delivery_detail_id = l_movement_transaction.picking_line_detail_id;
              END IF;

              IF (l_mvt_stat_status IS NOT NULL
                AND l_mvt_stat_status = 'FORDISP')
              THEN
                l_movement_transaction.movement_id := null;
              END IF;

              INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
                (p_api_version_number   => 1.0
                 ,p_init_msg_list        => FND_API.G_FALSE
                 ,x_movement_transaction => l_movement_transaction
                 ,x_msg_count            => x_msg_count
                 ,x_msg_data             => x_msg_data
                 ,x_return_status        => l_insert_status
                );

              --yawang fix bug 2268875
              IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
              THEN
                l_movement_id      := l_movement_transaction.movement_id;
                g_records_inserted     := g_records_inserted +1;

                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                               , G_MODULE_NAME || l_api_name
                                 ||'.Created mvt id is '||l_movement_id
                               ,'debug msg');
                END IF;
              END IF;
            END IF; --<end of IF from Mvt_Stats_Util_Info >
          END IF; --< end of IF from Get_SO_Details >
        END IF; --< end of IF from l_insert_flag = 'Y' >
        CLOSE ref_crsr;
      END IF; -- ref_crsr
    END LOOP l_inner;
    CLOSE setup_crsr;

    IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
    THEN
      l_movement_transaction.movement_id := l_movement_id;

      --If the dispatch is cross legal entity, then set the status to "DISPPROCESSED"
      --used in update so transaction(wsh table)
      IF (l_so_le_id IS NOT NULL
          AND l_so_le_id <> l_movement_transaction.entity_org_id)
      THEN
        l_cross_le_status := 'DISPPROCESSED';
      ELSE
        l_cross_le_status := 'REGULAR';
      END IF;

      IF l_need_create_kit = 'Y'
      THEN
        IF l_kit_record_status = 'N'
        THEN
          INV_MGD_MVT_SO_MDTR.Update_KIT_SO_Transactions
          ( p_movement_id        => l_movement_transaction.movement_id
          , p_delivery_detail_id => l_movement_transaction.picking_line_detail_id
          , p_link_to_line_id    => l_link_to_line_id
          , p_status             => l_cross_le_status
          , x_return_status     => l_return_status
          );
        END IF;
      ELSE
        INV_MGD_MVT_SO_MDTR.Update_SO_Transactions
        ( p_movement_transaction => l_movement_transaction
        , p_status             => l_cross_le_status
        , x_return_status      => l_return_status
        );
      END IF;

       COMMIT;
     ELSE
       ROLLBACK TO SAVEPOINT SO_Transaction;
     END IF;

     g_records_processed     := g_records_processed +1;
     l_movement_transaction  := p_movement_transaction;
  END LOOP l_outer;
  CLOSE so_crsr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Unexpected exception'
                    , l_error
                    );
    END IF;

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , l_error
                    );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Others exception in '||l_api_name
                             );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;
    RAISE;

END Process_SO_Transaction;

--========================================================================
-- PROCEDURE : Process_Triangulation_Txn     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      SO
-- COMMENT   :
--             This processes all the SO triangulation transactions (create
--             transaction in one legal entity and pick release in another
--             legal entity of different country) for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--             This procedure will create arrival record only for the
--             creation side of cross legal entity transactions for invoice
--             based triangulation mode. The pick release side will be taken
--             care of by the regular process_so_transaction.
--========================================================================

PROCEDURE Process_Triangulation_Txn
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'Process_Triangulation_Txn';
  l_error             VARCHAR2(600);
  sot_crsr                INV_MGD_MVT_DATA_STR.soCurTyp;
  l_movement_transaction  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_movement_transaction2 INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_movement_transaction_outer INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_shipment_transaction  INV_MGD_MVT_DATA_STR.Shipment_Transaction_Rec_Type;
  l_stat_typ_transaction  INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  l_stat_typ_transaction2 INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  setup_crsr              INV_MGD_MVT_DATA_STR.setupCurTyp;
  ref_crsr                INV_MGD_MVT_DATA_STR.setupCurTyp;
  l_insert_flag           VARCHAR2(1);
  x_msg_count             NUMBER;
  x_msg_data              VARCHAR2(2000);
  l_insert_status         VARCHAR2(10);
  l_movement_id           NUMBER;
  l_movement_id2          NUMBER;

  -- Bug: 5741580. Added variable l_trans_date to store trabsaction date
  l_trans_date            DATE;

  l_shipping_le_id        NUMBER;
  l_le_territory_code     VARCHAR2(10);
  l_customer_terri_code   VARCHAR2(10);
  l_return_status         VARCHAR2(1);

  --Added for bug4185582, 4238563
  l_need_create_kit       VARCHAR2(1);
  l_kit_record_status     VARCHAR2(1);
  l_parent_item_type_code VARCHAR2(30);
  l_shipped_qty           NUMBER;
  l_item_type_code        VARCHAR2(30);
  l_link_to_line_id       NUMBER;
  l_line_id               NUMBER;

  CURSOR l_parent
  IS
  SELECT
    item_type_code
  , NVL(shipped_quantity, fulfilled_quantity)
  FROM
    oe_order_lines_all
  WHERE line_id = l_link_to_line_id;

  CURSOR l_order_currency
  IS
  SELECT
    transactional_curr_code
  , conversion_rate
  , conversion_type_code
  , conversion_rate_date
  FROM oe_order_headers_all
  WHERE header_id = l_movement_transaction2.order_header_id;

  CURSOR bill_to_site IS
  SELECT
    bill_to_site_use_id
  FROM
    hz_cust_site_uses_all
  WHERE site_use_id = l_movement_transaction.ship_to_site_use_id;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_movement_transaction  := p_movement_transaction;

  -- Call the transaction proxy which processes all the transactions.
  INV_MGD_MVT_SO_MDTR.Get_Triangulation_Txns
  ( sot_crsr               => sot_crsr
  , p_movement_transaction => l_movement_transaction
  , p_start_date           => p_start_date
  , p_end_date             => p_end_date
  , x_return_status        => l_return_status);

  IF l_return_status = 'Y' THEN
  <<l_outer>>
  LOOP
    --Reset movement record for each picking line
    l_movement_transaction  := p_movement_transaction;
    l_movement_id := null;

    FETCH sot_crsr
    INTO l_movement_transaction.picking_line_detail_id
      ,  l_movement_transaction.organization_id
      ,  l_movement_transaction.ship_to_site_use_id
      ,  l_movement_transaction.transaction_date
      ,  l_movement_transaction.order_line_id
      ,  l_movement_transaction.order_number
      ,  l_item_type_code
      ,  l_link_to_line_id;

    EXIT WHEN sot_crsr%NOTFOUND;

    SAVEPOINT SOT_Transaction;

    --Timezone support, convert server transaction date to legal entity timezone
    l_movement_transaction.transaction_date :=
    INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Server
    ( p_trxn_date => l_movement_transaction.transaction_date
    , p_le_id     => l_movement_transaction.entity_org_id
    );

    --Bug:5741580, Actual transaction date stored in temperory variable
    l_trans_date := l_movement_transaction.transaction_date;

    --Find out the legal entity of the shipping warehouse
    l_shipping_le_id := INV_MGD_MVT_UTILS_PKG.Get_Shipping_Legal_Entity
                        (p_warehouse_id => l_movement_transaction.organization_id);

    --Only process those SO which cross legal entities
    IF (l_shipping_le_id IS NOT NULL
       AND l_shipping_le_id <> l_movement_transaction.entity_org_id)
    THEN
      --Initialize movement record
      INV_MGD_MVT_STATS_PVT.Init_Movement_Record
      (x_movement_transaction => l_movement_transaction);

      --Find out territory code for legal entity
      l_le_territory_code :=
      INV_MGD_MVT_UTILS_PKG.Get_LE_Location
      (p_le_id => l_movement_transaction.entity_org_id);

      --Find out territory code for customer
      l_customer_terri_code :=
      INV_MGD_MVT_UTILS_PKG.Get_Site_Location
      (p_site_use_id => l_movement_transaction.ship_to_site_use_id);

      --For creating Arrival SO record
      --Find out dispatch territory code and destination territory code
      l_movement_transaction.dispatch_territory_code :=
      INV_MGD_MVT_UTILS_PKG.Get_LE_Location
      (p_le_id => l_shipping_le_id);

      l_movement_transaction.destination_territory_code := l_le_territory_code;

      INV_MGD_MVT_SETUP_MDTR.Get_Setup_Context
      ( p_legal_entity_id       => l_movement_transaction.entity_org_id
       , p_movement_transaction => l_movement_transaction
       , x_return_status        => l_return_status
       , setup_crsr             => setup_crsr
       );

      --Back up the movement statistics record
      l_movement_transaction_outer := l_movement_transaction;

      <<l_inner>>
      LOOP
        --Reset movement transaction record
        l_movement_transaction := l_movement_transaction_outer;

        FETCH setup_crsr INTO
          l_movement_transaction.zone_code
        , l_movement_transaction.usage_type
        , l_movement_transaction.stat_type
        , l_stat_typ_transaction.reference_period_rule
        , l_stat_typ_transaction.pending_invoice_days
        , l_stat_typ_transaction.prior_invoice_days
        , l_stat_typ_transaction.triangulation_mode;

        EXIT l_inner WHEN setup_crsr%NOTFOUND;

        --Only attempt to create an Arrival record for cross legal entity SO
        --when the triangulation mode is invoice based
        --Also create record for Belgium when the SO is created in Belgium for
        --Beilgium customer (exception case, see Belgium INTRASTAT guide 14.4)
        IF (NVL(l_stat_typ_transaction.triangulation_mode,'INVOICE_BASED') = 'INVOICE_BASED'
            OR (l_le_territory_code = l_movement_transaction.destination_territory_code
               AND l_le_territory_code = 'BE'))
        THEN
          IF NVL(l_stat_typ_transaction.reference_period_rule,'SHIPMENT_BASED')
                                                       = 'INVOICE_BASED'
          THEN
            IF l_movement_transaction.document_source_type IS NULL
            THEN
              l_movement_transaction.document_source_type := 'SO';
            END IF;

            --Bug: 5440432. Change the movement type to 'A' before invoice creation.
            --since this procedure is creating an Arrival record for cross legal entity SO
            l_movement_transaction.movement_type := 'A';

            l_line_id := l_movement_transaction.order_line_id;

            --For included item, use parent invoice info
            IF l_item_type_code = 'INCLUDED'
            THEN
              l_movement_transaction.order_line_id := l_link_to_line_id;
            END IF;

            INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
            ( p_stat_typ_transaction => l_stat_typ_transaction
            , x_movement_transaction => l_movement_transaction
            );

            INV_MGD_MVT_FIN_MDTR. Get_Reference_Date
            ( p_stat_typ_transaction  => l_stat_typ_transaction
            , x_movement_transaction  => l_movement_transaction
            );

            l_movement_transaction.transaction_date :=
            l_movement_transaction.reference_date;

            --Set back the included item line id
            l_movement_transaction.order_line_id := l_line_id;
          END IF;

          INV_MGD_MVT_SETUP_MDTR.Get_Reference_Context
          ( p_legal_entity_id     => l_movement_transaction.entity_org_id
          , p_start_date          => p_start_date
          , p_end_date            => p_end_date
          , p_transaction_type    => p_transaction_type
          , p_movement_transaction => l_movement_transaction
          , x_return_status       => l_return_status
          , ref_crsr            => ref_crsr
          );

          --Reset the movement_id before fetching the transaction
          l_movement_transaction.movement_id := NULL;

          -- Bug:5920143. Added new parameter include_establishments in result.
          FETCH ref_crsr INTO
          l_movement_transaction.zone_code
          , l_movement_transaction.usage_type
          , l_movement_transaction.stat_type
          , l_stat_typ_transaction.start_period_name
          , l_stat_typ_transaction.end_period_name
          , l_stat_typ_transaction.period_set_name
          , l_stat_typ_transaction.period_type
          , l_stat_typ_transaction.weight_uom_code
          , l_stat_typ_transaction.conversion_type
          , l_stat_typ_transaction.attribute_rule_set_code
          , l_stat_typ_transaction.alt_uom_rule_set_code
          , l_stat_typ_transaction.start_date
          , l_stat_typ_transaction.end_date
          , l_stat_typ_transaction.category_set_id
          , l_movement_transaction.set_of_books_period
          , l_stat_typ_transaction.gl_currency_code
          , l_movement_transaction.gl_currency_code
          , l_stat_typ_transaction.conversion_option
          , l_stat_typ_transaction.triangulation_mode
          , l_stat_typ_transaction.reference_period_rule
          , l_stat_typ_transaction.pending_invoice_days
          , l_stat_typ_transaction.prior_invoice_days
          , l_stat_typ_transaction.returns_processing
          , l_stat_typ_transaction.kit_method
          , l_stat_typ_transaction.include_establishments;

        IF ref_crsr%NOTFOUND
        THEN
          --the transaction is not inside of start period and end period
          --so not create transaction
          CLOSE ref_crsr;
        ELSE
          --Fix bug 4185582,4238563, find out if parent is KIT
          OPEN l_parent;
          FETCH l_parent INTO
           l_parent_item_type_code
          , l_shipped_qty;
          CLOSE l_parent;

          --Find out if we need to treat this develivery as kit
          IF (l_item_type_code = 'INCLUDED'
              AND l_parent_item_type_code = 'KIT'
              AND l_shipped_qty IS NOT NULL
              AND l_stat_typ_transaction.kit_method = 'KIT')
          THEN
            l_need_create_kit := 'Y';

            --Find out if there is already a movement record created for this kit
            --if no, set l_kit_record to 'N' else set to 'Y'
            l_kit_record_status := INV_MGD_MVT_SO_MDTR.Get_KIT_Triangulation_Status
            (p_delivery_detail_id => l_movement_transaction.picking_line_detail_id);
          ELSE
            l_need_create_kit := 'N';
          END IF;
          --End of fix bug 4185582

          --If kit record has been created, do not need to create again
          IF (l_need_create_kit = 'Y' AND l_kit_record_status = 'Y')
          THEN
            l_insert_flag := 'N';
          ELSE
            l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
            ( p_movement_transaction => l_movement_transaction);
          END IF;

          -- Process the SO transaction
          IF l_insert_flag = 'Y'
          THEN
            INV_MGD_MVT_SO_MDTR.Get_SO_Details
            (x_movement_transaction => l_movement_transaction
            ,x_return_status        => l_return_status
            );

            IF l_need_create_kit = 'Y'
            THEN
              INV_MGD_MVT_SO_MDTR.Get_KIT_SO_Details
              ( p_link_to_line_id => l_link_to_line_id
              , x_movement_transaction => l_movement_transaction
              );
            END IF;

            --Clear any existing movement id since this procedure is creating new record
            --without parent
            l_movement_transaction.movement_id := null;

            --Change the movement type to 'A' since this procedure is creating
            --an Arrival record for cross legal entity SO
            l_movement_transaction.movement_type := 'A';

            IF l_return_status = 'Y'
            THEN
              INV_MGD_MVT_UTILS_PKG.Mvt_Stats_Util_Info
              (p_stat_typ_transaction => l_stat_typ_transaction
              ,x_movement_transaction => l_movement_transaction
              ,x_return_status        => l_return_status
              );

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS
              THEN
                IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                                , G_MODULE_NAME || l_api_name
                                  || '.Failed when call mvt_stats_util_info'
                                ,'Failed'
                                );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSE

                --Get bill to site id,performance reason to get bill to site id here
                --instead of in initial get_triangulation_transaction
                OPEN bill_to_site;
                FETCH bill_to_site INTO
                  l_movement_transaction.bill_to_site_use_id;
                CLOSE bill_to_site;

                l_movement_transaction.customer_vat_number :=
                INV_MGD_MVT_UTILS_PKG.Get_Cust_VAT_Number
                (l_movement_transaction.bill_to_site_use_id);

                IF l_movement_transaction.invoice_id IS NULL
                THEN
                  l_movement_transaction.invoice_quantity        := NULL;
                  l_movement_transaction.financial_document_flag := 'MISSING';
                ELSE
                  l_movement_transaction.financial_document_flag := 'PROCESSED_INCLUDED';
                END IF;

                INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
                (p_api_version_number   => 1.0
                ,p_init_msg_list        => FND_API.G_FALSE
                ,x_movement_transaction => l_movement_transaction
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
                ,x_return_status        => l_insert_status
                );

                --yawang fix bug 2268875
                IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
                THEN
                  l_movement_id      := l_movement_transaction.movement_id;
                  g_records_inserted := g_records_inserted +1;
                END IF;
              END IF;
            END IF;
          END IF;

          --Start here: Create second SO with movement type of D,this one follows
          --the regular invoice from the legal entity which creates this SO to
          --the customer
          l_movement_transaction2 := l_movement_transaction;
          l_stat_typ_transaction2 := l_stat_typ_transaction;

          --Fix bug 5659898, initialize to 'Y' to be checked below. Without this
          --initialization, this variable may inherit value 'S' from upper part
          --code, so it will never pass below checking and hence no dispatch
          --SO will be created
          l_return_status := 'Y';

          --Find out dispatch territory code and destination territory code
          l_movement_transaction2.dispatch_territory_code := l_le_territory_code;
          l_movement_transaction2.destination_territory_code := l_customer_terri_code;

          --If kit record has been created, do not need to create again
          IF (l_need_create_kit = 'Y' AND l_kit_record_status = 'Y')
          THEN
            l_insert_flag := 'N';
          ELSE
            l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
            ( p_movement_transaction => l_movement_transaction2);
          END IF;

          -- Process the SO transaction
          IF l_insert_flag = 'Y'
          THEN
            --Clear invoice information
            l_movement_transaction2.invoice_id := null;
            l_movement_transaction2.invoice_line_ext_value := null;
            l_movement_transaction2.invoice_quantity := null;
            l_movement_transaction2.invoice_unit_price := null;
            l_movement_transaction2.distribution_line_number := null;
            l_movement_transaction2.currency_code := null;
            l_movement_transaction2.currency_conversion_rate := null;
            l_movement_transaction2.currency_conversion_type := null;
            l_movement_transaction2.currency_conversion_date := null;
            l_movement_transaction2.invoice_batch_id := null;
            l_movement_transaction2.invoice_date_reference := null;

            --Bug 5741580. Reset following parameters.
            l_movement_transaction2.movement_status := 'O';
            l_movement_transaction2.period_name := null;
            l_movement_transaction2.transaction_date := l_trans_date;

            --Before call invoice pkg to get invoice currency conversion info, first
            --default from order header. If movement is is not null, don't not need
            --to call get_so_details only for currency info, since movement_transaction2
            --is a copied record, other info is already populated
            IF l_movement_transaction2.movement_id IS NOT NULL
            THEN
              OPEN l_order_currency;
              FETCH l_order_currency INTO
                l_movement_transaction2.currency_code
              , l_movement_transaction2.currency_conversion_rate
              , l_movement_transaction2.currency_conversion_type
              , l_movement_transaction2.currency_conversion_date;
              CLOSE l_order_currency;
            ELSE
              -- when create the first so, the insert flag is 'N', no so info populated
              INV_MGD_MVT_SO_MDTR.Get_SO_Details
              (x_movement_transaction => l_movement_transaction2
              ,x_return_status        => l_return_status
              );

              IF l_need_create_kit = 'Y'
              THEN
                INV_MGD_MVT_SO_MDTR.Get_KIT_SO_Details
                ( p_link_to_line_id => l_link_to_line_id
                , x_movement_transaction => l_movement_transaction2
                );
              END IF;
            END IF;

            --Clear any existing movement id since this procedure is creating new record
            --without parent
            l_movement_transaction2.movement_id := null;

            --Change the movement type to 'D' since this procedure is creating
            --an Dispatch record from legal entity where initiate this SO to the customer
            l_movement_transaction2.movement_type := 'D';

            IF l_return_status = 'Y'
            THEN
              --Bug 5741580. Again calculate the Invoice and reference date for
              -- SO Dispatch triangulation transaction and assigne it to
              -- to Transaction Date.
              IF NVL(l_stat_typ_transaction2.reference_period_rule,'SHIPMENT_BASED')
                                                       = 'INVOICE_BASED'
              THEN
                INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
                  ( p_stat_typ_transaction => l_stat_typ_transaction2
                  , x_movement_transaction => l_movement_transaction2
                  );
                INV_MGD_MVT_FIN_MDTR.Get_Reference_Date
                  ( p_stat_typ_transaction  => l_stat_typ_transaction2
                  , x_movement_transaction  => l_movement_transaction2
                  );
                l_movement_transaction2.transaction_date :=
                  l_movement_transaction2.reference_date;
              END IF;

              INV_MGD_MVT_UTILS_PKG.Mvt_Stats_Util_Info
              (p_stat_typ_transaction => l_stat_typ_transaction2
              ,x_movement_transaction => l_movement_transaction2
              ,x_return_status        => l_return_status
              );

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS
              THEN
                IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                                , G_MODULE_NAME || l_api_name
                                  || '.Failed when call mvt_stats_util_info -second SO'
                                ,'Failed'
                                );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSE

                /*l_movement_transaction2.customer_vat_number :=
                INV_MGD_MVT_UTILS_PKG.Get_Cust_VAT_Number
                (l_movement_transaction2.bill_to_site_use_id);*/

                IF l_movement_transaction2.invoice_id IS NULL
                THEN
                  l_movement_transaction2.invoice_quantity        := NULL;
                  l_movement_transaction2.financial_document_flag := 'MISSING';
                ELSE
                  l_movement_transaction2.financial_document_flag := 'PROCESSED_INCLUDED';
                END IF;

                INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
                (p_api_version_number   => 1.0
                ,p_init_msg_list        => FND_API.G_FALSE
                ,x_movement_transaction => l_movement_transaction2
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
                ,x_return_status        => l_insert_status
                );

                IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
                THEN
                  l_movement_id2      := l_movement_transaction2.movement_id;
                  g_records_inserted  := g_records_inserted +1;
                END IF;
              END IF;
            END IF;
          END IF;
          CLOSE ref_crsr;
          END IF;
        END IF;
      END LOOP l_inner;
      CLOSE setup_crsr;

      IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
      THEN
        l_movement_transaction.movement_id := l_movement_id;

        IF l_need_create_kit = 'Y'
        THEN
          IF l_kit_record_status = 'N'
          THEN
            INV_MGD_MVT_SO_MDTR.Update_KIT_SO_Transactions
            ( p_movement_id        => l_movement_transaction.movement_id
            , p_delivery_detail_id => l_movement_transaction.picking_line_detail_id
            , p_link_to_line_id    => l_link_to_line_id
            , p_status             => 'ARRIVALPROCESSED'
            , x_return_status     => l_return_status
            );
          END IF;
        ELSE
          INV_MGD_MVT_SO_MDTR.Update_SO_Transactions
          ( p_movement_transaction => l_movement_transaction
          , p_status               => 'ARRIVALPROCESSED'
          , x_return_status        => l_return_status
          );
        END IF;

        COMMIT;
      ELSE
        ROLLBACK TO SAVEPOINT SOT_Transaction;
      END IF;

      g_records_processed     := g_records_processed +1;
      l_movement_transaction  := p_movement_transaction;
    END IF;
  END LOOP l_outer;
  CLOSE sot_crsr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Unexpected exception'
                    , l_error
                    );
    END IF;

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , l_error
                    );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Others exception in '||l_api_name
                             );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;
    RAISE;

END Process_Triangulation_Txn;

--========================================================================
-- PROCEDURE : Process_IO_Arrival_Txn     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      SO
-- COMMENT   :
--             This processes all the internal order arrival transactions
--             for the specified legal entity that have a transaction date
--             within the specified date range.
--             This procedure will create arrival record only for the
--             receiving side of internal order transactions. The dispatch
--             side will be taken care by the regular process_so_transaction.
--========================================================================

PROCEDURE Process_IO_Arrival_Txn
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  -- Declare the REF Cursor
  io_arrival_crsr        INV_MGD_MVT_DATA_STR.soCurTyp;
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_movement_transaction_outer INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_shipment_transaction INV_MGD_MVT_DATA_STR.Shipment_Transaction_Rec_Type;
  l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  setup_crsr             INV_MGD_MVT_DATA_STR.setupCurTyp;
  ref_crsr               INV_MGD_MVT_DATA_STR.setupCurTyp;
  l_insert_flag          VARCHAR2(1);
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(2000);
  l_insert_status        VARCHAR2(10);
  l_shipping_org_id      NUMBER;
  l_movement_id          NUMBER;
  l_cross_le_status      VARCHAR2(20);
  l_mvt_stat_status      VARCHAR2(20);
  l_subinv_code          VARCHAR2(10);
  l_subinv_terr_code     VARCHAR2(2);
  l_recv_org_terr_code   VARCHAR2(2);
  l_le_terr_code         VARCHAR2(2);
  l_shipping_org_terri_code VARCHAR2(10);
  l_req_number           po_requisition_headers_all.segment1%TYPE;
  l_return_status        VARCHAR2(1);
  l_api_name CONSTANT    VARCHAR2(30) := 'Process_IO_Arrival_Txn';
  l_error                VARCHAR2(600);

  --Fix bug 3364811, move order lines and delivery table out of
  --io_arrival_crsr so that no duplicate rcv transactions picked
  --in outer loop.
  --This new cursor is created to fetch shipping org etc info
 /*bug 8548641 added new cursor Picking_line_id to fetch picking_line_detail_id and changed shipping_org cursor to fetch only shipping_organization_id on the basis of picking_line_detail_id */
  CURSOR Picking_line_id IS
  SELECT
    MAX(oola.line_id)
  , MAX(wdd.delivery_detail_id) picking_line_detail_id
  FROM
    oe_order_lines_all oola
  , wsh_delivery_details_ob_grp_v wdd
  WHERE oola.order_source_id = 10   --combine 1st and 2nd condition to use index 11
    AND oola.orig_sys_document_ref = l_req_number
    AND oola.source_document_line_id = l_movement_transaction.requisition_line_id
    AND oola.line_id = wdd.source_line_id
    /* Bugfix 9024785 - When shipping lines are split and quantity is partially shipped,
    the existing logic was failing. Added the following and clauses
    */
    AND oola.line_id=nvl(l_movement_transaction.order_line_id,oola.line_id)
    AND wdd.shipped_quantity > 0
    AND wdd.source_code   = 'OE';

  CURSOR shipping_org IS
  SELECT
     wdd.organization_id shipping_organization_id
  FROM
   wsh_delivery_details_ob_grp_v wdd
  WHERE wdd.delivery_detail_id=l_movement_transaction.picking_line_detail_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_movement_transaction  := p_movement_transaction;

  -- Call the transaction proxy which processes all the transactions.
  INV_MGD_MVT_PO_MDTR.Get_IO_Arrival_Txn
  ( io_arrival_crsr         => io_arrival_crsr
   , p_movement_transaction => l_movement_transaction
   , p_start_date           => p_start_date
   , p_end_date             => p_end_date
   , x_return_status        => l_return_status);

  IF l_return_status = 'Y' THEN
  <<l_outer>>
  LOOP
    --Reset the movement record for each picking line
    l_movement_transaction  := p_movement_transaction;
    l_movement_id := NULL;

    FETCH io_arrival_crsr
    INTO l_movement_transaction.rcv_transaction_id
      ,  l_movement_transaction.transaction_date
      ,  l_movement_transaction.organization_id
      ,  l_subinv_code
      ,  l_movement_transaction.requisition_line_id
      ,  l_req_number
      ,  l_movement_transaction.order_line_id;/* Added for bug 9024785*/

    EXIT WHEN io_arrival_crsr%NOTFOUND;

    SAVEPOINT IO_Transaction;

    --Timezone support, convert server transaction date to legal entity timezone
    l_movement_transaction.transaction_date :=
    INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Server
    ( p_trxn_date => l_movement_transaction.transaction_date
    , p_le_id     => l_movement_transaction.entity_org_id
    );

    --Fix bug 3364811,populate shipping org
     OPEN Picking_line_id;           /*bug 8548641*/
    FETCH Picking_line_id INTO
      l_movement_transaction.order_line_id
    , l_movement_transaction.picking_line_detail_id;
    CLOSE Picking_line_id;

    OPEN shipping_org;             /*bug 8548641*/
    FETCH shipping_org INTO
      l_shipping_org_id;
    CLOSE shipping_org;


    INV_MGD_MVT_STATS_PVT.Init_Movement_Record
       (x_movement_transaction => l_movement_transaction);

    --Find out territory code
    l_subinv_terr_code :=
    INV_MGD_MVT_UTILS_PKG.Get_Subinv_Location
    ( p_warehouse_id => l_movement_transaction.organization_id
    , p_subinv_code  => l_subinv_code);

    l_recv_org_terr_code :=
    INV_MGD_MVT_UTILS_PKG.Get_Org_Location
    (p_warehouse_id => l_movement_transaction.organization_id);

    l_le_terr_code :=
    INV_MGD_MVT_UTILS_PKG.Get_LE_Location
    (p_le_id => l_movement_transaction.entity_org_id);

    l_shipping_org_terri_code :=
    INV_MGD_MVT_UTILS_PKG.Get_Org_Location
    (p_warehouse_id => l_shipping_org_id);

    l_movement_transaction.dispatch_territory_code := l_shipping_org_terri_code;
    l_movement_transaction.destination_territory_code :=
    NVL(l_subinv_terr_code, l_recv_org_terr_code);

    -- Bug: 5920143 Validation that LE Territory Code and
    -- Destination Org Territory Code should be same, is commented here.
    -- Its added in later section.
    --IF l_le_terr_code = l_movement_transaction.destination_territory_code
    --THEN
      INV_MGD_MVT_SETUP_MDTR.Get_Setup_Context
      ( p_legal_entity_id       => l_movement_transaction.entity_org_id
      , p_movement_transaction => l_movement_transaction
      , x_return_status        => l_return_status
      , setup_crsr             => setup_crsr
      );

      --Back up the movement statistics record
      l_movement_transaction_outer := l_movement_transaction;

      <<l_inner>>
      LOOP
        --Reset movement transaction record
        l_movement_transaction := l_movement_transaction_outer;

      FETCH setup_crsr INTO
          l_movement_transaction.zone_code
        , l_movement_transaction.usage_type
        , l_movement_transaction.stat_type
        , l_stat_typ_transaction.reference_period_rule
        , l_stat_typ_transaction.pending_invoice_days
        , l_stat_typ_transaction.prior_invoice_days
        , l_stat_typ_transaction.triangulation_mode;

      EXIT l_inner WHEN setup_crsr%NOTFOUND;

      INV_MGD_MVT_SETUP_MDTR.Get_Reference_Context
      ( p_legal_entity_id     => l_movement_transaction.entity_org_id
      , p_start_date          => p_start_date
      , p_end_date            => p_end_date
      , p_transaction_type    => p_transaction_type
      , p_movement_transaction => l_movement_transaction
      , x_return_status       => l_return_status
      , ref_crsr            => ref_crsr
      );

      --Reset the movement_id before fetching the transaction
      l_movement_transaction.movement_id := NULL;

      -- Bug:5920143. Added new parameter include_establishments in result.
      FETCH ref_crsr INTO
          l_movement_transaction.zone_code
        , l_movement_transaction.usage_type
        , l_movement_transaction.stat_type
        , l_stat_typ_transaction.start_period_name
        , l_stat_typ_transaction.end_period_name
        , l_stat_typ_transaction.period_set_name
        , l_stat_typ_transaction.period_type
        , l_stat_typ_transaction.weight_uom_code
        , l_stat_typ_transaction.conversion_type
        , l_stat_typ_transaction.attribute_rule_set_code
        , l_stat_typ_transaction.alt_uom_rule_set_code
        , l_stat_typ_transaction.start_date
        , l_stat_typ_transaction.end_date
        , l_stat_typ_transaction.category_set_id
        , l_movement_transaction.set_of_books_period
        , l_stat_typ_transaction.gl_currency_code
        , l_movement_transaction.gl_currency_code
        , l_stat_typ_transaction.conversion_option
        , l_stat_typ_transaction.triangulation_mode
        , l_stat_typ_transaction.reference_period_rule
        , l_stat_typ_transaction.pending_invoice_days
        , l_stat_typ_transaction.prior_invoice_days
        , l_stat_typ_transaction.returns_processing
        , l_stat_typ_transaction.kit_method
        , l_stat_typ_transaction.include_establishments;

      IF ref_crsr%NOTFOUND
      THEN
        --the transaction is not inside of start period and end period
        --so not create transaction
        CLOSE ref_crsr;
      ELSE
        -- Bug: 5920143 Validation that LE Territory Code and
        -- Destination Org Territory Code should be same, is needed only when
        -- user has selected Include Establishments as No.

        --Only create record for organization located in the same country as legal entity
        IF ((l_movement_transaction.stat_type = 'ESL'
             AND l_movement_transaction.usage_type = 'INTERNAL')
             OR ((l_le_terr_code <> l_movement_transaction.destination_territory_code)
              AND (l_stat_typ_transaction.include_establishments = 'N')))
        THEN
          l_insert_flag := 'N';
        ELSE
          l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
          ( p_movement_transaction => l_movement_transaction);
        END IF;

        -- Process the SO transaction
        IF l_insert_flag = 'Y'
        THEN
          INV_MGD_MVT_PO_MDTR.Get_IO_Arrival_Details
          ( x_movement_transaction => l_movement_transaction
          , x_return_status        => l_return_status
          );

          IF l_return_status = 'Y'
          THEN
            INV_MGD_MVT_UTILS_PKG.Mvt_Stats_Util_Info
            (p_stat_typ_transaction => l_stat_typ_transaction
            ,x_movement_transaction => l_movement_transaction
            ,x_return_status        => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_SUCCESS
            THEN

              l_movement_transaction.customer_vat_number :=
              INV_MGD_MVT_UTILS_PKG.Get_Cust_VAT_Number
              (l_movement_transaction.bill_to_site_use_id);

              INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
              (p_api_version_number   => 1.0
               ,p_init_msg_list        => FND_API.G_FALSE
               ,x_movement_transaction => l_movement_transaction
               ,x_msg_count            => x_msg_count
               ,x_msg_data             => x_msg_data
               ,x_return_status        => l_insert_status
               );

              --yawang fix bug 2268875
              IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
              THEN
                l_movement_id      := l_movement_transaction.movement_id;
                g_records_inserted     := g_records_inserted +1;
              END IF;
            ELSE
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF; --< end of if from Get_IO_Arrival_Details>
        END IF;   --< end of if from l_insert_flag>
        CLOSE ref_crsr;
      END IF;
      END LOOP l_inner;
      CLOSE setup_crsr;
    --END IF;

    IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
    THEN
      l_movement_transaction.movement_id := l_movement_id;
    /* 7165989 - Pass mvt_stat_status as NULL for non-RMA triangulation txns */
      INV_MGD_MVT_PO_MDTR.Update_PO_Transactions
      ( p_movement_transaction => l_movement_transaction
      , p_mvt_stat_status      => NULL
      , x_return_status        => l_return_status
      );

      COMMIT;
    ELSE
      ROLLBACK TO SAVEPOINT IO_Transaction;
    END IF;

    g_records_processed     := g_records_processed +1;
    l_movement_transaction  := p_movement_transaction;
  END LOOP l_outer;
  CLOSE io_arrival_crsr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Unexpected exception'
                    , l_error
                    );
    END IF;

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , l_error
                    );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Others exception in '||l_api_name
                             );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;
    RAISE;

END Process_IO_Arrival_Txn;

--========================================================================
-- PROCEDURE : Update_PO_With_RTV      PRIVATE
-- PARAMETERS: x_return_status         return status
--             x_mvt_rtv_transaction   IN OUT  Movement Statistics Record
-- COMMENT   : pocedure that process RTV transaction depend on if
--             the parent PO is closed
--=========================================================================
PROCEDURE Update_PO_With_RTV
( x_mvt_rtv_transaction IN OUT  NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
l_parent_mvt_id          NUMBER;
l_parent_mvt_status      VARCHAR2(30);
l_parent_mvt_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
x_msg_count              NUMBER;
x_msg_data               VARCHAR2(2000);
l_return_status          VARCHAR2(1);
l_api_name CONSTANT      VARCHAR2(30) := 'Update_PO_With_RTV';
l_error                  VARCHAR2(600);

CURSOR parent_status IS
SELECT
  mms.movement_id
, mms.movement_status
FROM
  mtl_movement_statistics mms
, rcv_transactions rt
WHERE mms.rcv_transaction_id = rt.parent_transaction_id
  AND rt.transaction_id = x_mvt_rtv_transaction.rcv_transaction_id
  AND mms.entity_org_id = x_mvt_rtv_transaction.entity_org_id
  AND mms.zone_code     = x_mvt_rtv_transaction.zone_code
  AND mms.usage_type    = x_mvt_rtv_transaction.usage_type
  AND mms.stat_type     = x_mvt_rtv_transaction.stat_type
  AND mms.movement_type <> 'AA';


CURSOR parent_mvt_record IS
SELECT
  movement_id
, organization_id
, entity_org_id
, movement_type
, movement_status
, transaction_date
, last_update_date
, last_updated_by
, creation_date
, created_by
, last_update_login
, document_source_type
, creation_method
, document_reference
, document_line_reference
, document_unit_price
, document_line_ext_value
, receipt_reference
, shipment_reference
, shipment_line_reference
, pick_slip_reference
, customer_name
, customer_number
, customer_location
, transacting_from_org
, transacting_to_org
, vendor_name
, vendor_number
, vendor_site
, bill_to_name
, bill_to_number
, bill_to_site
, po_header_id
, po_line_id
, po_line_location_id
, order_header_id
, order_line_id
, picking_line_id
, shipment_header_id
, shipment_line_id
, ship_to_customer_id
, ship_to_site_use_id
, bill_to_customer_id
, bill_to_site_use_id
, vendor_id
, vendor_site_id
, from_organization_id
, to_organization_id
, parent_movement_id
, inventory_item_id
, item_description
, item_cost
, transaction_quantity
, transaction_uom_code
, primary_quantity
, invoice_batch_id
, invoice_id
, customer_trx_line_id
, invoice_batch_reference
, invoice_reference
, invoice_line_reference
, invoice_date_reference
, invoice_quantity
, invoice_unit_price
, invoice_line_ext_value
, outside_code
, outside_ext_value
, outside_unit_price
, currency_code
, currency_conversion_rate
, currency_conversion_type
, currency_conversion_date
, period_name
, report_reference
, report_date
, category_id
, weight_method
, unit_weight
, total_weight
, transaction_nature
, delivery_terms
, transport_mode
, alternate_quantity
, alternate_uom_code
, dispatch_territory_code
, destination_territory_code
, origin_territory_code
, stat_method
, stat_adj_percent
, stat_adj_amount
, stat_ext_value
, area
, port
, stat_type
, comments
, attribute_category
, commodity_code
, commodity_description
, requisition_header_id
, requisition_line_id
, picking_line_detail_id
, usage_type
, zone_code
, edi_sent_flag
, statistical_procedure_code
, movement_amount
, triangulation_country_code
, csa_code
, oil_reference_code
, container_type_code
, flow_indicator_code
, affiliation_reference_code
, origin_territory_eu_code
, destination_territory_eu_code
, dispatch_territory_eu_code
, set_of_books_period
, taric_code
, preference_code
, rcv_transaction_id
, mtl_transaction_id
, total_weight_uom_code
, financial_document_flag
--, opm_trans_id
, customer_vat_number
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
, triangulation_country_eu_code
, distribution_line_number
, ship_to_name
, ship_to_number
, ship_to_site
, edi_transaction_date
, edi_transaction_reference
, esl_drop_shipment_code
FROM
  mtl_movement_statistics
WHERE movement_id = l_parent_mvt_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Get parent PO record status
  OPEN parent_status;
  FETCH parent_status INTO
    l_parent_mvt_id
  , l_parent_mvt_status;

  IF parent_status%NOTFOUND
  THEN
    l_parent_mvt_id := null;
    l_parent_mvt_status := null;
  END IF;
  CLOSE parent_status;

  --If parent PO is Frozen, then create new arrival adjustment RTV
  --with negative qty and amt,else update parent PO
  IF (l_parent_mvt_status IS NULL
     OR l_parent_mvt_status IN ('F', 'X'))
  THEN
    x_mvt_rtv_transaction.movement_type := 'AA';

    --Set qty and amt to negative
    x_mvt_rtv_transaction.transaction_quantity :=
       0 - x_mvt_rtv_transaction.transaction_quantity;
    x_mvt_rtv_transaction.primary_quantity :=
       0 - x_mvt_rtv_transaction.primary_quantity;
    x_mvt_rtv_transaction.document_line_ext_value :=
       0 - x_mvt_rtv_transaction.document_line_ext_value;
    x_mvt_rtv_transaction.total_weight := 0 - x_mvt_rtv_transaction.total_weight;

    IF x_mvt_rtv_transaction.movement_amount > 0
    THEN
      x_mvt_rtv_transaction.movement_amount :=
         0 - x_mvt_rtv_transaction.movement_amount;
      x_mvt_rtv_transaction.stat_ext_value :=
         0 - x_mvt_rtv_transaction.stat_ext_value;
    END IF;

    IF x_mvt_rtv_transaction.alternate_quantity IS NOT NULL
    THEN
      x_mvt_rtv_transaction.alternate_quantity :=
         0- x_mvt_rtv_transaction.alternate_quantity;
    END IF;

    --Set movement_id,used to insert into parent_movement_id for new record
    x_mvt_rtv_transaction.movement_id := l_parent_mvt_id;

    --Insert rtv arrival adjustment record
    INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
    ( p_api_version_number   => 1.0
    , p_init_msg_list        => FND_API.G_FALSE
    , x_movement_transaction => x_mvt_rtv_transaction
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    , x_return_status        => l_return_status
    );
  ELSE
    OPEN parent_mvt_record;
    FETCH parent_mvt_record
    INTO
      l_parent_mvt_transaction.movement_id
    , l_parent_mvt_transaction.organization_id
    , l_parent_mvt_transaction.entity_org_id
    , l_parent_mvt_transaction.movement_type
    , l_parent_mvt_transaction.movement_status
    , l_parent_mvt_transaction.transaction_date
    , l_parent_mvt_transaction.last_update_date
    , l_parent_mvt_transaction.last_updated_by
    , l_parent_mvt_transaction.creation_date
    , l_parent_mvt_transaction.created_by
    , l_parent_mvt_transaction.last_update_login
    , l_parent_mvt_transaction.document_source_type
    , l_parent_mvt_transaction.creation_method
    , l_parent_mvt_transaction.document_reference
    , l_parent_mvt_transaction.document_line_reference
    , l_parent_mvt_transaction.document_unit_price
    , l_parent_mvt_transaction.document_line_ext_value
    , l_parent_mvt_transaction.receipt_reference
    , l_parent_mvt_transaction.shipment_reference
    , l_parent_mvt_transaction.shipment_line_reference
    , l_parent_mvt_transaction.pick_slip_reference
    , l_parent_mvt_transaction.customer_name
    , l_parent_mvt_transaction.customer_number
    , l_parent_mvt_transaction.customer_location
    , l_parent_mvt_transaction.transacting_from_org
    , l_parent_mvt_transaction.transacting_to_org
    , l_parent_mvt_transaction.vendor_name
    , l_parent_mvt_transaction.vendor_number
    , l_parent_mvt_transaction.vendor_site
    , l_parent_mvt_transaction.bill_to_name
    , l_parent_mvt_transaction.bill_to_number
    , l_parent_mvt_transaction.bill_to_site
    , l_parent_mvt_transaction.po_header_id
    , l_parent_mvt_transaction.po_line_id
    , l_parent_mvt_transaction.po_line_location_id
    , l_parent_mvt_transaction.order_header_id
    , l_parent_mvt_transaction.order_line_id
    , l_parent_mvt_transaction.picking_line_id
    , l_parent_mvt_transaction.shipment_header_id
    , l_parent_mvt_transaction.shipment_line_id
    , l_parent_mvt_transaction.ship_to_customer_id
    , l_parent_mvt_transaction.ship_to_site_use_id
    , l_parent_mvt_transaction.bill_to_customer_id
    , l_parent_mvt_transaction.bill_to_site_use_id
    , l_parent_mvt_transaction.vendor_id
    , l_parent_mvt_transaction.vendor_site_id
    , l_parent_mvt_transaction.from_organization_id
    , l_parent_mvt_transaction.to_organization_id
    , l_parent_mvt_transaction.parent_movement_id
    , l_parent_mvt_transaction.inventory_item_id
    , l_parent_mvt_transaction.item_description
    , l_parent_mvt_transaction.item_cost
    , l_parent_mvt_transaction.transaction_quantity
    , l_parent_mvt_transaction.transaction_uom_code
    , l_parent_mvt_transaction.primary_quantity
    , l_parent_mvt_transaction.invoice_batch_id
    , l_parent_mvt_transaction.invoice_id
    , l_parent_mvt_transaction.customer_trx_line_id
    , l_parent_mvt_transaction.invoice_batch_reference
    , l_parent_mvt_transaction.invoice_reference
    , l_parent_mvt_transaction.invoice_line_reference
    , l_parent_mvt_transaction.invoice_date_reference
    , l_parent_mvt_transaction.invoice_quantity
    , l_parent_mvt_transaction.invoice_unit_price
    , l_parent_mvt_transaction.invoice_line_ext_value
    , l_parent_mvt_transaction.outside_code
    , l_parent_mvt_transaction.outside_ext_value
    , l_parent_mvt_transaction.outside_unit_price
    , l_parent_mvt_transaction.currency_code
    , l_parent_mvt_transaction.currency_conversion_rate
    , l_parent_mvt_transaction.currency_conversion_type
    , l_parent_mvt_transaction.currency_conversion_date
    , l_parent_mvt_transaction.period_name
    , l_parent_mvt_transaction.report_reference
    , l_parent_mvt_transaction.report_date
    , l_parent_mvt_transaction.category_id
    , l_parent_mvt_transaction.weight_method
    , l_parent_mvt_transaction.unit_weight
    , l_parent_mvt_transaction.total_weight
    , l_parent_mvt_transaction.transaction_nature
    , l_parent_mvt_transaction.delivery_terms
    , l_parent_mvt_transaction.transport_mode
    , l_parent_mvt_transaction.alternate_quantity
    , l_parent_mvt_transaction.alternate_uom_code
    , l_parent_mvt_transaction.dispatch_territory_code
    , l_parent_mvt_transaction.destination_territory_code
    , l_parent_mvt_transaction.origin_territory_code
    , l_parent_mvt_transaction.stat_method
    , l_parent_mvt_transaction.stat_adj_percent
    , l_parent_mvt_transaction.stat_adj_amount
    , l_parent_mvt_transaction.stat_ext_value
    , l_parent_mvt_transaction.area
    , l_parent_mvt_transaction.port
    , l_parent_mvt_transaction.stat_type
    , l_parent_mvt_transaction.comments
    , l_parent_mvt_transaction.attribute_category
    , l_parent_mvt_transaction.commodity_code
    , l_parent_mvt_transaction.commodity_description
    , l_parent_mvt_transaction.requisition_header_id
    , l_parent_mvt_transaction.requisition_line_id
    , l_parent_mvt_transaction.picking_line_detail_id
    , l_parent_mvt_transaction.usage_type
    , l_parent_mvt_transaction.zone_code
    , l_parent_mvt_transaction.edi_sent_flag
    , l_parent_mvt_transaction.statistical_procedure_code
    , l_parent_mvt_transaction.movement_amount
    , l_parent_mvt_transaction.triangulation_country_code
    , l_parent_mvt_transaction.csa_code
    , l_parent_mvt_transaction.oil_reference_code
    , l_parent_mvt_transaction.container_type_code
    , l_parent_mvt_transaction.flow_indicator_code
    , l_parent_mvt_transaction.affiliation_reference_code
    , l_parent_mvt_transaction.origin_territory_eu_code
    , l_parent_mvt_transaction.destination_territory_eu_code
    , l_parent_mvt_transaction.dispatch_territory_eu_code
    , l_parent_mvt_transaction.set_of_books_period
    , l_parent_mvt_transaction.taric_code
    , l_parent_mvt_transaction.preference_code
    , l_parent_mvt_transaction.rcv_transaction_id
    , l_parent_mvt_transaction.mtl_transaction_id
    , l_parent_mvt_transaction.total_weight_uom_code
    , l_parent_mvt_transaction.financial_document_flag
    --, l_parent_mvt_transaction.opm_trans_id
    , l_parent_mvt_transaction.customer_vat_number
    , l_parent_mvt_transaction.attribute1
    , l_parent_mvt_transaction.attribute2
    , l_parent_mvt_transaction.attribute3
    , l_parent_mvt_transaction.attribute4
    , l_parent_mvt_transaction.attribute5
    , l_parent_mvt_transaction.attribute6
    , l_parent_mvt_transaction.attribute7
    , l_parent_mvt_transaction.attribute8
    , l_parent_mvt_transaction.attribute9
    , l_parent_mvt_transaction.attribute10
    , l_parent_mvt_transaction.attribute11
    , l_parent_mvt_transaction.attribute12
    , l_parent_mvt_transaction.attribute13
    , l_parent_mvt_transaction.attribute14
    , l_parent_mvt_transaction.attribute15
    , l_parent_mvt_transaction.triangulation_country_eu_code
    , l_parent_mvt_transaction.distribution_line_number
    , l_parent_mvt_transaction.ship_to_name
    , l_parent_mvt_transaction.ship_to_number
    , l_parent_mvt_transaction.ship_to_site
    , l_parent_mvt_transaction.edi_transaction_date
    , l_parent_mvt_transaction.edi_transaction_reference
    , l_parent_mvt_transaction.esl_drop_shipment_code;

    --Net rtv value into parent po
    l_parent_mvt_transaction.transaction_quantity :=
          l_parent_mvt_transaction.transaction_quantity -
          x_mvt_rtv_transaction.transaction_quantity;
    l_parent_mvt_transaction.primary_quantity :=
          l_parent_mvt_transaction.primary_quantity -
          x_mvt_rtv_transaction.primary_quantity;
    l_parent_mvt_transaction.document_line_ext_value :=
          l_parent_mvt_transaction.document_line_ext_value -
          x_mvt_rtv_transaction.document_line_ext_value;
    l_parent_mvt_transaction.movement_amount :=
          l_parent_mvt_transaction.movement_amount -
          x_mvt_rtv_transaction.movement_amount;
    l_parent_mvt_transaction.stat_ext_value :=
          l_parent_mvt_transaction.stat_ext_value -
          NVL(x_mvt_rtv_transaction.stat_ext_value,
              x_mvt_rtv_transaction.movement_amount);
    l_parent_mvt_transaction.total_weight :=
          l_parent_mvt_transaction.total_weight -
          x_mvt_rtv_transaction.total_weight;

    IF l_parent_mvt_transaction.transaction_quantity IS NOT NULL
       AND l_parent_mvt_transaction.transaction_quantity <> 0
    THEN
      l_parent_mvt_transaction.document_unit_price :=
          l_parent_mvt_transaction.document_line_ext_value/
          l_parent_mvt_transaction.transaction_quantity;
      l_parent_mvt_transaction.unit_weight :=
          l_parent_mvt_transaction.total_weight/
          l_parent_mvt_transaction.transaction_quantity;
    END IF;

    IF l_parent_mvt_transaction.alternate_quantity IS NOT NULL
       AND x_mvt_rtv_transaction.alternate_quantity IS NOT NULL
    THEN
      l_parent_mvt_transaction.alternate_quantity :=
          l_parent_mvt_transaction.alternate_quantity -
          x_mvt_rtv_transaction.alternate_quantity;
    END IF;

    IF l_parent_mvt_transaction.invoice_quantity IS NOT NULL
       AND x_mvt_rtv_transaction.invoice_quantity IS NOT NULL
    THEN
      l_parent_mvt_transaction.invoice_quantity :=
          l_parent_mvt_transaction.invoice_quantity +
          x_mvt_rtv_transaction.invoice_quantity;
    END IF;

    IF l_parent_mvt_transaction.invoice_line_ext_value IS NOT NULL
       AND x_mvt_rtv_transaction.invoice_line_ext_value IS NOT NULL
    THEN
      l_parent_mvt_transaction.invoice_line_ext_value :=
          l_parent_mvt_transaction.invoice_line_ext_value +
          x_mvt_rtv_transaction.invoice_line_ext_value;
    END IF;

    IF l_parent_mvt_transaction.invoice_quantity IS NOT NULL
      AND l_parent_mvt_transaction.invoice_quantity <> 0
    THEN
      l_parent_mvt_transaction.invoice_unit_price :=
          l_parent_mvt_transaction.invoice_line_ext_value/
          l_parent_mvt_transaction.invoice_quantity;
    END IF;

    --Update parent PO
    INV_MGD_MVT_STATS_PVT.Update_Movement_Statistics
    ( p_movement_statistics  => l_parent_mvt_transaction
    , x_return_status        => l_return_status
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    );

    --set movement id in rtv record to null, because we didn't
    --insert new record and this will be used in calling procedure
    x_mvt_rtv_transaction.movement_id := null;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;

END Update_PO_With_RTV;

--========================================================================
-- PROCEDURE : Process_PO_Transaction     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      PO
-- COMMENT   :
--             This processes all the PO transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Process_PO_Transaction
( p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  -- Declare the REF Cursor
  po_crsr                INV_MGD_MVT_DATA_STR.poCurTyp;
  rtv_crsr               INV_MGD_MVT_DATA_STR.rtvCurTyp;
  setup_crsr             INV_MGD_MVT_DATA_STR.setupCurTyp;
  ref_crsr               INV_MGD_MVT_DATA_STR.setupCurTyp;
  l_receipt_transaction  INV_MGD_MVT_DATA_STR.Receipt_Transaction_Rec_Type;
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  x_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_movement_transaction_outer INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(2000);
  l_insert_flag          VARCHAR2(1);
  l_vendor_site_id       NUMBER;
  l_site_id              NUMBER;
  l_parent_id            NUMBER;
  l_parent_trans_type    VARCHAR2(25);
  l_return_status        VARCHAR2(1);
  l_quantity             NUMBER;
  l_insert_status        VARCHAR2(10);
  l_movement_id          NUMBER;
 -- l_trans_date           DATE;
  l_par_mvt_id           NUMBER;
  l_par_movement_status  mtl_movement_statistics.movement_status%TYPE;
  l_par_source_type      mtl_movement_statistics.document_source_type%TYPE;
  l_update_status        VARCHAR2(1);
  l_dropship_source_id   NUMBER;
  l_le_terr_code         VARCHAR2(2);
  l_subinv_code          RCV_SHIPMENT_LINES.To_Subinventory%TYPE;
  l_subinv_terr_code     VARCHAR2(2);
  l_org_terr_code        VARCHAR2(2);
  l_api_name CONSTANT VARCHAR2(30) := 'Process_PO_Transaction';
  l_error             VARCHAR2(600);

  CURSOR l_drpshp IS
  SELECT
    drop_ship_source_id
  FROM
    OE_DROP_SHIP_SOURCES
  WHERE po_header_id        = l_movement_transaction.po_header_id
    AND po_line_id          = l_movement_transaction.po_line_id
    AND line_location_id    = l_movement_transaction.po_line_location_id;

  CURSOR l_vendor_site IS
  SELECT
    vendor_site_id
  FROM
    po_headers_all
  WHERE po_header_id = l_movement_transaction.po_header_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_movement_transaction  := p_movement_transaction;

  -- Call the transaction proxy which processes all the transactions.
  INV_MGD_MVT_PO_MDTR.Get_PO_Transactions
  ( po_crsr                => po_crsr
   , p_movement_transaction => l_movement_transaction
   , p_start_date           => p_start_date
   , p_end_date             => p_end_date
   , x_return_status        => l_return_status);

  IF l_return_status = 'Y'
  THEN
    <<l_outer>>
    LOOP
      --yawang initialize l_insert_status
      --l_insert_status := 'E';

      --Reset the movement record for each transaction
      l_movement_transaction  := p_movement_transaction;
      l_movement_id := NULL;

      --Fix bug5010132, reset dropship status
      l_dropship_source_id := null;

      FETCH po_crsr INTO
        l_movement_transaction.rcv_transaction_id
      , l_receipt_transaction.parent_transaction_id
      , l_receipt_transaction.transaction_type
      , l_movement_transaction.po_header_id
      , l_movement_transaction.po_line_id
      , l_movement_transaction.po_line_location_id
      , l_receipt_transaction.source_document_code
      , l_movement_transaction.vendor_site_id
      , l_movement_transaction.transaction_date
      , l_movement_transaction.organization_id
      , l_subinv_code;

      EXIT WHEN po_crsr%NOTFOUND;

      SAVEPOINT PO_Transaction;

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_MODULE_NAME ||'.The PO hd,ln,loc,rcv id,txn date are '
                         ||l_movement_transaction.po_header_id
                         ||','||l_movement_transaction.po_line_id
                         ||','||l_movement_transaction.po_line_location_id
                         ||','||l_movement_transaction.rcv_transaction_id
                         ||','||l_movement_transaction.transaction_date
                       ,'debug msg');
      END IF;

      --Timezone support, convert server transaction date to legal entity timezone
      l_movement_transaction.transaction_date :=
      INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Server
      ( p_trxn_date => l_movement_transaction.transaction_date
      , p_le_id     => l_movement_transaction.entity_org_id
      );

      INV_MGD_MVT_SETUP_MDTR.Get_Setup_Context
      ( p_legal_entity_id      => l_movement_transaction.entity_org_id
      , p_movement_transaction => l_movement_transaction
      , x_return_status        => l_return_status
      , setup_crsr             => setup_crsr
      );

      --Back up the movement statistics record
      l_movement_transaction_outer := l_movement_transaction;
      <<l_inner>>
      LOOP
        --Reset movement transaction record
        l_movement_transaction := l_movement_transaction_outer;

        FETCH setup_crsr INTO
          l_movement_transaction.zone_code
        , l_movement_transaction.usage_type
        , l_movement_transaction.stat_type
        , l_stat_typ_transaction.reference_period_rule
        , l_stat_typ_transaction.pending_invoice_days
        , l_stat_typ_transaction.prior_invoice_days
        , l_stat_typ_transaction.triangulation_mode;

        EXIT  l_inner WHEN setup_crsr%NOTFOUND;

        --Populate transaction date (reference date)
        --Correction transaction does not have invoice
        IF (NVL(l_stat_typ_transaction.reference_period_rule,'SHIPMENT_BASED')
                                                       = 'INVOICE_BASED'
            AND l_receipt_transaction.transaction_type <> 'CORRECT')
        THEN
          --Document source type
          IF l_receipt_transaction.transaction_type = 'RETURN TO VENDOR'
          THEN
            l_movement_transaction.document_source_type := 'RTV';
          ELSE
            l_movement_transaction.document_source_type := 'PO';
          END IF;

          INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
          ( p_stat_typ_transaction => l_stat_typ_transaction
          , x_movement_transaction => l_movement_transaction
          );

          INV_MGD_MVT_FIN_MDTR. Get_Reference_Date
          ( p_stat_typ_transaction  => l_stat_typ_transaction
          , x_movement_transaction  => l_movement_transaction
          );

          l_movement_transaction.transaction_date :=
                l_movement_transaction.reference_date;

          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_MODULE_NAME ||'.The reference txn date is '
                         ||l_movement_transaction.transaction_date
                       ,'debug msg');
          END IF;
        END IF;

        INV_MGD_MVT_SETUP_MDTR.Get_Reference_Context
        ( p_legal_entity_id     => l_movement_transaction.entity_org_id
        , p_start_date          => p_start_date
        , p_end_date            => p_end_date
        , p_transaction_type    => p_transaction_type
        , p_movement_transaction => l_movement_transaction
        , x_return_status       => l_return_status
        , ref_crsr            => ref_crsr
        );

        --   Reset the movement_id before fetching the transaction
        l_movement_transaction.movement_id := NULL;

        -- Bug:5920143. Added new parameter include_establishments in result.
        FETCH ref_crsr INTO
          l_movement_transaction.zone_code
        , l_movement_transaction.usage_type
        , l_movement_transaction.stat_type
        , l_stat_typ_transaction.start_period_name
        , l_stat_typ_transaction.end_period_name
        , l_stat_typ_transaction.period_set_name
        , l_stat_typ_transaction.period_type
        , l_stat_typ_transaction.weight_uom_code
        , l_stat_typ_transaction.conversion_type
        , l_stat_typ_transaction.attribute_rule_set_code
        , l_stat_typ_transaction.alt_uom_rule_set_code
        , l_stat_typ_transaction.start_date
        , l_stat_typ_transaction.end_date
        , l_stat_typ_transaction.category_set_id
        , l_movement_transaction.set_of_books_period
        , l_stat_typ_transaction.gl_currency_code
        , l_movement_transaction.gl_currency_code
        , l_stat_typ_transaction.conversion_option
        , l_stat_typ_transaction.triangulation_mode
        , l_stat_typ_transaction.reference_period_rule
        , l_stat_typ_transaction.pending_invoice_days
        , l_stat_typ_transaction.prior_invoice_days
        , l_stat_typ_transaction.returns_processing
        , l_stat_typ_transaction.kit_method
        , l_stat_typ_transaction.include_establishments;

        IF ref_crsr%NOTFOUND
        THEN
          --the transaction is not inside of start period and end period
          --so not create transaction
          CLOSE ref_crsr;
        ELSE
          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_MODULE_NAME ||'.The usg,stat type,currency,tri mode,ref rule are '
                         ||l_movement_transaction.usage_type
                         ||','||l_movement_transaction.stat_type
                         ||','||l_stat_typ_transaction.gl_currency_code
                         ||','||l_stat_typ_transaction.triangulation_mode
                         ||','||l_stat_typ_transaction.reference_period_rule
                       ,'debug msg');
          END IF;

        INV_MGD_MVT_STATS_PVT.Init_Movement_Record
        (x_movement_transaction => l_movement_transaction);

        IF (p_transaction_type = 'RTV')
           AND (l_receipt_transaction.transaction_type = 'RECEIVE')
        THEN
          --Do not process PO RECEIVE, but if CORRECT we should process
          EXIT;
        ELSE
          l_movement_transaction.movement_id := NULL;

          -- For every record fetched get the dispatch and destination territory
          -- codes.
          IF (l_receipt_transaction.parent_transaction_id IS NOT NULL
            AND (l_receipt_transaction.transaction_type = 'CORRECT')
            AND (l_movement_transaction.vendor_site_id IS NULL))
            OR
            (l_receipt_transaction.parent_transaction_id IS NOT NULL
            AND (l_receipt_transaction.transaction_type = 'RETURN TO VENDOR')
            AND (l_movement_transaction.vendor_site_id IS NULL))
          THEN
            l_vendor_site_id  := l_movement_transaction.vendor_site_id;
            l_parent_id       := l_receipt_transaction.parent_transaction_id;

            WHILE  NVL(l_vendor_site_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
            LOOP
              IF (l_parent_id IS  NULL)
              THEN
                EXIT;
              ELSE
                INV_MGD_MVT_PO_MDTR.Get_RTV_Transactions
                ( rtv_crsr               => rtv_crsr
                , p_parent_id            => l_parent_id
                , x_return_status        => l_return_status);

                FETCH rtv_crsr
                INTO
                  l_movement_transaction.vendor_site_id
                , l_receipt_transaction.parent_transaction_id
                , l_parent_trans_type;

                IF rtv_crsr%NOTFOUND
                THEN
                  CLOSE rtv_crsr;
                  EXIT;
                END IF;

                CLOSE rtv_crsr;

                l_parent_id := l_receipt_transaction.parent_transaction_id;
                l_vendor_site_id := l_movement_transaction.vendor_site_id;
              END IF;
            END LOOP;
          END IF;

          --Get vendor site id for unordered match
          IF l_receipt_transaction.transaction_type = 'MATCH'
          THEN
            OPEN l_vendor_site;
            FETCH l_vendor_site INTO
              l_movement_transaction.vendor_site_id;
            CLOSE l_vendor_site;
          END IF;

          --Check if it's a drop shipment
          OPEN l_drpshp;
          FETCH l_drpshp INTO
            l_dropship_source_id;
          CLOSE l_drpshp;

          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_MODULE_NAME || l_api_name
                         ||'.The drpshp source id is '||l_dropship_source_id
                       ,'debug msg');
          END IF;

          --Get subinventory location fix bug 2683302
          l_subinv_terr_code :=
          INV_MGD_MVT_UTILS_PKG.Get_Subinv_Location
          ( p_warehouse_id => l_movement_transaction.organization_id
          , p_subinv_code  => l_subinv_code);

          l_org_terr_code :=
          INV_MGD_MVT_UTILS_PKG.Get_Org_Location
          (p_warehouse_id => l_movement_transaction.organization_id);

          l_le_terr_code := INV_MGD_MVT_UTILS_PKG.Get_LE_Location
                            (p_le_id => l_movement_transaction.entity_org_id);

          l_movement_transaction.dispatch_territory_code :=
          INV_MGD_MVT_UTILS_PKG.Get_Vendor_Location
          (p_vendor_site_id =>l_movement_transaction.vendor_site_id);

          --If dropship,do not consider subinventory location,because dropship
          --receipt is logical receipt,not real receipt.
          IF l_dropship_source_id IS NOT NULL
          THEN
            --Bug:5920143. l_org_terr_code is replaced with l_le_terr_code because
            -- this is logical record so logical PO destination should be LE.
            l_movement_transaction.destination_territory_code := l_le_terr_code;
          ELSE
            l_movement_transaction.destination_territory_code :=
            NVL(l_subinv_terr_code, l_org_terr_code);
          END IF;

          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_MODULE_NAME ||'.The subinv,org,dest,disp terr code are '
                         ||l_subinv_terr_code
                         ||','||l_org_terr_code
                         ||','||l_movement_transaction.destination_territory_code
                         ||','||l_movement_transaction.dispatch_territory_code
                       ,'debug msg');
          END IF;

          --Only create record for dest territory located in the same country as
          --legal entity and ignore if the stat type is ESL
          -- Bug: 5920143 Validation that LE Territory Code and
          -- Destination Org Territory Code should be same, is needed only when
          -- user has selected Include Establishments as No.
          IF (((l_le_terr_code <> l_movement_transaction.destination_territory_code)
                AND (l_stat_typ_transaction.include_establishments = 'N'))
              OR (l_movement_transaction.stat_type = 'ESL'
                  AND l_movement_transaction.usage_type = 'INTERNAL'))
          THEN
            l_insert_flag := 'N';
          ELSE
            l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
            ( p_movement_transaction => l_movement_transaction);
          END IF;

          --Find out the parent movement id and movement status of a correct
          --transaction. If there is a movement id and if the status is closed,
          --then create a new movement record for this correction,otherwise do
          --not create new record
          IF l_receipt_transaction.transaction_type='CORRECT'
          THEN
            INV_MGD_MVT_PO_MDTR.Get_Parent_Mvt
            ( p_movement_transaction => l_movement_transaction
            , p_rcv_transaction_id   => l_receipt_transaction.parent_transaction_id
            , x_movement_id          => l_par_mvt_id
            , x_movement_status      => l_par_movement_status
            , x_source_type          => l_par_source_type
            );

            --Initialize update status for this transaction
            l_update_status := 'N';

            IF (NVL(l_insert_flag,'N') = 'Y'
                AND l_par_mvt_id IS NOT NULL
                AND l_par_movement_status IN ('F','X'))
            THEN
              l_insert_flag := 'Y';

              --Invoice information is not required for correction transaction
              l_movement_transaction.financial_document_flag := 'NOT_REQUIRED_CORRECT';

              --Parent movement id is the movement id of original PO
              l_movement_transaction.parent_movement_id := l_par_mvt_id;
            ELSE
              l_insert_flag := 'N';

              --set following, used in calling update_po_transaction at the end
              --set mvt id of correction to the same as parent mvt id
              --IF transaction type is RTV, do not update this rcv transaction
              --if its parent is not RTV(only process rtv's correction)
              IF (p_transaction_type = 'RTV'
                 AND l_par_source_type <> 'RTV')
              THEN
                l_update_status := 'N';
              ELSE
                l_update_status := 'Y';
                l_movement_id := l_par_mvt_id;
              END IF;
            END IF;
          END IF;

          IF l_insert_flag = 'Y'
          THEN
            INV_MGD_MVT_PO_MDTR.Get_PO_Details
            (p_stat_typ_transaction => l_stat_typ_transaction
            ,x_movement_transaction => l_movement_transaction
            ,x_return_status        => l_return_status
            );

            IF l_return_status = 'Y'
            THEN
              INV_MGD_MVT_UTILS_PKG.Mvt_Stats_Util_Info
              (p_stat_typ_transaction => l_stat_typ_transaction
              ,x_movement_transaction => l_movement_transaction
              ,x_return_status        => l_return_status
              );

              IF l_return_status = FND_API.G_RET_STS_SUCCESS
              THEN
                IF l_movement_transaction.invoice_id IS NULL
                THEN
                  l_movement_transaction.invoice_quantity        := NULL;

                  -- Set financial flag. Change back to NOT_REQUIRED for correction
                  -- transaction
                  IF l_movement_transaction.financial_document_flag = 'NOT_REQUIRED_CORRECT'
                  THEN
                    l_movement_transaction.financial_document_flag := 'NOT_REQUIRED';
                  ELSE
                    l_movement_transaction.financial_document_flag := 'MISSING';
                  END IF;
                ELSE
                  l_movement_transaction.financial_document_flag
                                                   := 'PROCESSED_INCLUDED';
                END IF;

                IF l_movement_transaction.transaction_nature='17'
                THEN
                  IF NVL(l_stat_typ_transaction.triangulation_mode,'INVOICE_BASED')=
                     'INVOICE_BASED'
                  THEN
                    l_quantity := l_movement_transaction.transaction_quantity;
                    l_movement_transaction.total_weight := 0;
                    l_movement_transaction.transaction_quantity := 0;
                  ELSE -- don't report the movement if triangulation mode is shipment
                    l_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
                END IF;

                IF l_return_status = FND_API.G_RET_STS_SUCCESS
                THEN
                  -- A RTV transaction may need to be netted into its parent
                  -- PO if the returns processing parameter is set to "Aggregate Return"
                  -- and the parent PO is not Frozen or Exported
                  IF (l_movement_transaction.document_source_type = 'RTV'
                    AND l_stat_typ_transaction.returns_processing = 'AGGRTN')
                  THEN
                    Update_PO_With_RTV
                    ( x_mvt_rtv_transaction => l_movement_transaction
                    , x_return_status       => l_insert_status
                    );
                  ELSE
                    INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
                    (p_api_version_number   => 1.0
                    ,p_init_msg_list        => FND_API.G_FALSE
                    ,x_movement_transaction => l_movement_transaction
                    ,x_msg_count            => x_msg_count
                    ,x_msg_data             => x_msg_data
                    ,x_return_status        => l_insert_status
                  );
                  END IF;

                  --yawang fix bug 2268875
                  IF l_insert_status = FND_API.G_RET_STS_SUCCESS
                  THEN
                    l_movement_id      := l_movement_transaction.movement_id;

                    --If rtv is netted into po, movement id is null and no new
                    --record inserted
                    IF l_movement_id IS NOT NULL
                    THEN
                      g_records_inserted     := g_records_inserted +1;

                      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                      THEN
                        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                                      , G_MODULE_NAME || l_api_name
                                        ||'.Created mvt id is '||l_movement_id
                                      ,'debug msg');
                      END IF;
                    END IF;
                  END IF;

                  --  If it is a drop shipment make quantity=0, this assignment is done here so
                  --  that all the Movement amount calcns are done with the right quantity.
                  --  Create a SO for drop shipment
                  IF l_movement_transaction.transaction_nature='17'
                  THEN
                    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                    THEN
                      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                                    , G_MODULE_NAME ||'Process_PO_Dropship_Transaction1.begin'
                                    ,'enter dropship');
                    END IF;

                    l_movement_transaction.transaction_quantity := l_quantity;
                    l_movement_transaction.movement_id := NULL;

                    INV_MGD_MVT_PO_MDTR.Get_DropShipment_Details
                    (p_stat_typ_transaction => l_stat_typ_transaction
                    ,x_movement_transaction => l_movement_transaction
                    ,x_return_status        => l_return_status);

                    --Set dispatch/destination territory code
                    l_movement_transaction.dispatch_territory_code :=
                        l_movement_transaction.destination_territory_code;

                    --Bug:5920143. Following code is commented becasue
                    --value is already assigned to Triangulation Country.
                    --l_movement_transaction.triangulation_country_code :=
                    --    l_movement_transaction.destination_territory_code;

                    l_movement_transaction.destination_territory_code :=
                    INV_MGD_MVT_UTILS_PKG.Get_Site_Location
                    (l_movement_transaction.ship_to_site_use_id);

                    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                    THEN
                      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                                    , G_MODULE_NAME ||'Process_PO_Dropship_Transaction1'
                                      ||'dest and disp terr code are '
                                      ||l_movement_transaction.destination_territory_code
                                      ||','||l_movement_transaction.dispatch_territory_code
                                    ,'enter dropship');
                    END IF;

                    IF l_return_status = 'Y'
                    THEN
                      -- Bug: 5920143. Following condition added. If Dispatch and
                      -- and LE countries are not same for SO dispatch dropship
                      -- record and user has selected Include Establishments as No
                      -- then no record will be created for original LE.
                      IF(((l_le_terr_code <> l_movement_transaction.dispatch_territory_code) ) AND
                       (l_stat_typ_transaction.include_establishments = 'N'))
                      THEN
                        l_insert_flag := 'N';
                      ELSE
                       --Find out the insert flag
                       l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
                       ( p_movement_transaction => l_movement_transaction);
                      END IF;
                    ELSE
                      l_insert_flag := 'N';
                    END IF;

                    --Continue if the insert flag is Yes
                    IF l_insert_flag = 'Y'
                    THEN
                      INV_MGD_MVT_UTILS_PKG.Mvt_Stats_Util_Info
                      (p_stat_typ_transaction => l_stat_typ_transaction
                      ,x_movement_transaction => l_movement_transaction
                      ,x_return_status        => l_return_status
                      );

                      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                      THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      ELSE

                        l_movement_transaction.total_weight := 0;
                        l_movement_transaction.transaction_quantity := 0;

                        IF l_movement_transaction.invoice_id IS NULL
                        THEN
                          l_movement_transaction.invoice_quantity        := NULL;
                          l_movement_transaction.financial_document_flag := 'MISSING';
                        ELSE
                          l_movement_transaction.financial_document_flag
                                                     := 'PROCESSED_INCLUDED';
                        END IF;

                        INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
                        (p_api_version_number   => 1.0
                        ,p_init_msg_list        => FND_API.G_FALSE
                        ,x_movement_transaction => l_movement_transaction
                        ,x_msg_count            => x_msg_count
                        ,x_msg_data             => x_msg_data
                        ,x_return_status        => l_return_status
                        );

                        --yawang fix bug 2268875
                        IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS) =
                           FND_API.G_RET_STS_SUCCESS
                        THEN
                          g_records_inserted     := g_records_inserted +1;
                          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                          THEN
                            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                                          , G_MODULE_NAME ||'Process_PO_Dropship_Transaction1'
                                            ||'.Created mvt id is '
                                            ||l_movement_transaction.movement_id
                                          ,'debug msg');
                          END IF;
                        END IF;
                      END IF; -- end success from Mvt_Stats_Util_Info
                    END IF; -- end l_insert_flag

                    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                    THEN
                      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                                    , G_MODULE_NAME ||'Process_PO_Dropship_Transaction1.end'
                                    ,'exit dropship');
                    END IF;
                  END IF;   -- end dropship SO creation
                END IF;
              ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;       -- end success from Mvt_Stats_Util_Info
            END IF; -- < end insert>
          --Fix bug 2586495 case 8,PO insert flag is N, but dropship SO insert
          --flag maybe Y, then a dropship SO needs to be created
          ELSE
            --Fix bug5010132, replace x_return_status with l_return_status
            --in this block. The x_return_status is used to check the status
            --of whole procedure and set in exception section. It is not
            --used to check local status
            IF l_dropship_source_id IS NOT NULL
            THEN
              --Only create dropshop SO for invoice based
              --Bug 5060410, filter out transaction type of 'CORRECT'
              --only process transaction type of 'RECEIVE'
              IF (NVL(l_stat_typ_transaction.triangulation_mode,'INVOICE_BASED')=
                   'INVOICE_BASED'
                  AND l_receipt_transaction.transaction_type = 'RECEIVE')
              THEN
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                                , G_MODULE_NAME ||'Process_PO_Dropship_Transaction2.begin'
                                ,'enter dropship');
                END IF;

                INV_MGD_MVT_PO_MDTR.Get_PO_Details
                (p_stat_typ_transaction => l_stat_typ_transaction
                ,x_movement_transaction => l_movement_transaction
                ,x_return_status        => l_return_status
                );

                IF l_return_status = 'Y'
                THEN
                  l_movement_transaction.movement_id := NULL;

                  INV_MGD_MVT_PO_MDTR.Get_DropShipment_Details
                  (p_stat_typ_transaction => l_stat_typ_transaction
                  ,x_movement_transaction => l_movement_transaction
                  ,x_return_status        => l_return_status);

                  --Set dispatch/destination territory code
                  l_movement_transaction.dispatch_territory_code :=
                      l_movement_transaction.destination_territory_code;

                  l_movement_transaction.triangulation_country_code :=
                      l_movement_transaction.destination_territory_code;

                  l_movement_transaction.destination_territory_code :=
                  INV_MGD_MVT_UTILS_PKG.Get_Site_Location
                  (l_movement_transaction.ship_to_site_use_id);

                  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                  THEN
                    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                                  , G_MODULE_NAME ||'Process_PO_Dropship_Transaction2'
                                    ||'dest and disp terr code are '
                                    ||l_movement_transaction.destination_territory_code
                                    ||','||l_movement_transaction.dispatch_territory_code
                                  ,'enter dropship');
                  END IF;

                  IF l_return_status = 'Y'
                  THEN
                    -- Bug: 5920143. Following condition added. If Dispatch and
                    -- and LE countries are not same for SO dispatch dropship
                    -- record and user has selected Include Establishments as No
                    -- then no record will be created for original LE.
                    IF(((l_le_terr_code <> l_movement_transaction.dispatch_territory_code) ) AND
                     (l_stat_typ_transaction.include_establishments = 'N'))
                    THEN
                      l_insert_flag := 'N';
                    ELSE
                     --Find out the insert flag
                     l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
                     ( p_movement_transaction => l_movement_transaction);
                    END IF;
                  ELSE
                    l_insert_flag := 'N';
                  END IF;
                ELSE
                  l_insert_flag := 'N';
                END IF;

                --Continue if the insert flag is Yes
                IF l_insert_flag = 'Y'
                THEN
                  INV_MGD_MVT_UTILS_PKG.Mvt_Stats_Util_Info
                  (p_stat_typ_transaction => l_stat_typ_transaction
                  ,x_movement_transaction => l_movement_transaction
                  ,x_return_status        => l_return_status
                  );

                  IF l_return_status = FND_API.G_RET_STS_SUCCESS
                  THEN

                    l_movement_transaction.total_weight := 0;
                    l_movement_transaction.transaction_quantity := 0;

                    IF l_movement_transaction.invoice_id IS NULL
                    THEN
                      l_movement_transaction.invoice_quantity        := NULL;
                      l_movement_transaction.financial_document_flag := 'MISSING';
                    ELSE
                      l_movement_transaction.financial_document_flag
                                                   := 'PROCESSED_INCLUDED';
                    END IF;

                    INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
                    (p_api_version_number   => 1.0
                    ,p_init_msg_list        => FND_API.G_FALSE
                    ,x_movement_transaction => l_movement_transaction
                    ,x_msg_count            => x_msg_count
                    ,x_msg_data             => x_msg_data
                    ,x_return_status        => l_insert_status
                    );

                    --yawang fix bug 2268875
                    IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) =
                       FND_API.G_RET_STS_SUCCESS
                    THEN
                      l_movement_id := l_movement_transaction.movement_id;
                      g_records_inserted     := g_records_inserted +1;

                      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                      THEN
                        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                                      , G_MODULE_NAME ||'Process_PO_Dropship_Transaction2'
                                        ||'.Created mvt id is ' ||l_movement_transaction.movement_id
                                      ,'debug msg');
                      END IF;
                    END IF;
                  ELSE
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF; --end sucess from Mvt_Stats_Util_Info
                END IF;  --end insert flag Y

                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                                , G_MODULE_NAME ||'Process_PO_Dropship_Transaction2.end'
                                ,'exit dropship');
                END IF;
              END IF;    --end invoice based
            END IF;      --end l_dropship_source_id
          END IF; --end if for l_insert_flag
        END IF;   --end if 'RTV' and 'RECEIVE' condition
        CLOSE ref_crsr;
        END IF; --end if ref_crsr found
      END LOOP l_inner;
      CLOSE setup_crsr;

      IF (p_transaction_type = 'RTV')
         AND (l_receipt_transaction.transaction_type = 'RECEIVE')
      THEN
        NULL;
      ELSE
        IF (NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
             OR l_update_status = 'Y')
        THEN
          l_movement_transaction.movement_id := l_movement_id;
 /* 7165989 - Pass null for mvt_stat_status for non-RMA triangulation txns*/
          INV_MGD_MVT_PO_MDTR.Update_PO_Transactions
          (  p_movement_transaction => l_movement_transaction
	   , p_mvt_stat_status      => NULL
           , x_return_status        => l_return_status
           );

          COMMIT;
        ELSE
          ROLLBACK TO SAVEPOINT PO_Transaction;
        END IF;
      END IF;

      g_records_processed     := g_records_processed +1;

      l_movement_transaction := p_movement_transaction;
    END LOOP l_outer;
    CLOSE po_crsr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Unexpected exception'
                    , l_error
                    );
    END IF;

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , l_error
                    );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Others exception in '||l_api_name
                             );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;
    RAISE;

END Process_PO_Transaction;

--========================================================================
-- PROCEDURE : Update_SO_With_RMA      PRIVATE
-- PARAMETERS: x_return_status         return status
--             x_mvt_rma_transaction   IN OUT  Movement Statistics Record
-- COMMENT   : pocedure that process RMA transaction depend on if
--             the parent SO is closed
--=========================================================================
PROCEDURE Update_SO_With_RMA
( x_mvt_rma_transaction IN OUT  NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
l_parent_mvt_id          NUMBER;
l_parent_mvt_status      VARCHAR2(30);
l_parent_mvt_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
x_msg_count              NUMBER;
x_msg_data               VARCHAR2(2000);
l_return_status          VARCHAR2(1);
l_api_name CONSTANT      VARCHAR2(30) := 'Update_SO_With_RMA';
l_error                  VARCHAR2(600);

CURSOR parent_status IS
SELECT
  mms.movement_id
, mms.movement_status
FROM
  mtl_movement_statistics mms
, oe_order_lines_all oola
WHERE mms.order_header_id = oola.reference_header_id
  AND mms.order_line_id   = oola.reference_line_id
  AND oola.line_id        = x_mvt_rma_transaction.order_line_id
  AND mms.entity_org_id   = x_mvt_rma_transaction.entity_org_id
  AND mms.zone_code       = x_mvt_rma_transaction.zone_code
  AND mms.usage_type      = x_mvt_rma_transaction.usage_type
  AND mms.stat_type       = x_mvt_rma_transaction.stat_type
  AND mms.movement_type   <> 'DA';

CURSOR parent_mvt_record IS
SELECT
  movement_id
, organization_id
, entity_org_id
, movement_type
, movement_status
, transaction_date
, last_update_date
, last_updated_by
, creation_date
, created_by
, last_update_login
, document_source_type
, creation_method
, document_reference
, document_line_reference
, document_unit_price
, document_line_ext_value
, receipt_reference
, shipment_reference
, shipment_line_reference
, pick_slip_reference
, customer_name
, customer_number
, customer_location
, transacting_from_org
, transacting_to_org
, vendor_name
, vendor_number
, vendor_site
, bill_to_name
, bill_to_number
, bill_to_site
, po_header_id
, po_line_id
, po_line_location_id
, order_header_id
, order_line_id
, picking_line_id
, shipment_header_id
, shipment_line_id
, ship_to_customer_id
, ship_to_site_use_id
, bill_to_customer_id
, bill_to_site_use_id
, vendor_id
, vendor_site_id
, from_organization_id
, to_organization_id
, parent_movement_id
, inventory_item_id
, item_description
, item_cost
, transaction_quantity
, transaction_uom_code
, primary_quantity
, invoice_batch_id
, invoice_id
, customer_trx_line_id
, invoice_batch_reference
, invoice_reference
, invoice_line_reference
, invoice_date_reference
, invoice_quantity
, invoice_unit_price
, invoice_line_ext_value
, outside_code
, outside_ext_value
, outside_unit_price
, currency_code
, currency_conversion_rate
, currency_conversion_type
, currency_conversion_date
, period_name
, report_reference
, report_date
, category_id
, weight_method
, unit_weight
, total_weight
, transaction_nature
, delivery_terms
, transport_mode
, alternate_quantity
, alternate_uom_code
, dispatch_territory_code
, destination_territory_code
, origin_territory_code
, stat_method
, stat_adj_percent
, stat_adj_amount
, stat_ext_value
, area
, port
, stat_type
, comments
, attribute_category
, commodity_code
, commodity_description
, requisition_header_id
, requisition_line_id
, picking_line_detail_id
, usage_type
, zone_code
, edi_sent_flag
, statistical_procedure_code
, movement_amount
, triangulation_country_code
, csa_code
, oil_reference_code
, container_type_code
, flow_indicator_code
, affiliation_reference_code
, origin_territory_eu_code
, destination_territory_eu_code
, dispatch_territory_eu_code
, set_of_books_period
, taric_code
, preference_code
, rcv_transaction_id
, mtl_transaction_id
, total_weight_uom_code
, financial_document_flag
--, opm_trans_id
, customer_vat_number
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
, triangulation_country_eu_code
, distribution_line_number
, ship_to_name
, ship_to_number
, ship_to_site
, edi_transaction_date
, edi_transaction_reference
, esl_drop_shipment_code
FROM
  mtl_movement_statistics
WHERE movement_id = l_parent_mvt_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Get parent PO record status
  OPEN parent_status;
  FETCH parent_status INTO
    l_parent_mvt_id
  , l_parent_mvt_status;

  IF parent_status%NOTFOUND
  THEN
    l_parent_mvt_id := null;
    l_parent_mvt_status := null;
  END IF;
  CLOSE parent_status;

  --If parent SO is Frozen, then create new dispaatch adjustment RMA
  --with negative qty and amt,else update parent SO
  IF (l_parent_mvt_status IS NULL
     OR l_parent_mvt_status IN ('F', 'X'))
  THEN
    x_mvt_rma_transaction.movement_type := 'DA';

    --Set qty and amt to negative
    x_mvt_rma_transaction.transaction_quantity :=
       0 - x_mvt_rma_transaction.transaction_quantity;
    x_mvt_rma_transaction.primary_quantity :=
       0 - x_mvt_rma_transaction.primary_quantity;
    x_mvt_rma_transaction.document_line_ext_value :=
       0 - x_mvt_rma_transaction.document_line_ext_value;
    x_mvt_rma_transaction.total_weight := 0 - x_mvt_rma_transaction.total_weight;

    IF x_mvt_rma_transaction.movement_amount >0
    THEN
      x_mvt_rma_transaction.movement_amount :=
         0 - x_mvt_rma_transaction.movement_amount;
      x_mvt_rma_transaction.stat_ext_value :=
         0 - x_mvt_rma_transaction.stat_ext_value;
    END IF;

    IF x_mvt_rma_transaction.alternate_quantity IS NOT NULL
    THEN
      x_mvt_rma_transaction.alternate_quantity :=
         0- x_mvt_rma_transaction.alternate_quantity;
    END IF;

    --Set movement_id,used to insert into parent_movement_id for new record
    x_mvt_rma_transaction.movement_id := l_parent_mvt_id;

    --Insert rma arrival adjustment record
    INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
    ( p_api_version_number   => 1.0
    , p_init_msg_list        => FND_API.G_FALSE
    , x_movement_transaction => x_mvt_rma_transaction
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    , x_return_status        => l_return_status
    );
  ELSE
    OPEN parent_mvt_record;
    FETCH parent_mvt_record
    INTO
      l_parent_mvt_transaction.movement_id
    , l_parent_mvt_transaction.organization_id
    , l_parent_mvt_transaction.entity_org_id
    , l_parent_mvt_transaction.movement_type
    , l_parent_mvt_transaction.movement_status
    , l_parent_mvt_transaction.transaction_date
    , l_parent_mvt_transaction.last_update_date
    , l_parent_mvt_transaction.last_updated_by
    , l_parent_mvt_transaction.creation_date
    , l_parent_mvt_transaction.created_by
    , l_parent_mvt_transaction.last_update_login
    , l_parent_mvt_transaction.document_source_type
    , l_parent_mvt_transaction.creation_method
    , l_parent_mvt_transaction.document_reference
    , l_parent_mvt_transaction.document_line_reference
    , l_parent_mvt_transaction.document_unit_price
    , l_parent_mvt_transaction.document_line_ext_value
    , l_parent_mvt_transaction.receipt_reference
    , l_parent_mvt_transaction.shipment_reference
    , l_parent_mvt_transaction.shipment_line_reference
    , l_parent_mvt_transaction.pick_slip_reference
    , l_parent_mvt_transaction.customer_name
    , l_parent_mvt_transaction.customer_number
    , l_parent_mvt_transaction.customer_location
    , l_parent_mvt_transaction.transacting_from_org
    , l_parent_mvt_transaction.transacting_to_org
    , l_parent_mvt_transaction.vendor_name
    , l_parent_mvt_transaction.vendor_number
    , l_parent_mvt_transaction.vendor_site
    , l_parent_mvt_transaction.bill_to_name
    , l_parent_mvt_transaction.bill_to_number
    , l_parent_mvt_transaction.bill_to_site
    , l_parent_mvt_transaction.po_header_id
    , l_parent_mvt_transaction.po_line_id
    , l_parent_mvt_transaction.po_line_location_id
    , l_parent_mvt_transaction.order_header_id
    , l_parent_mvt_transaction.order_line_id
    , l_parent_mvt_transaction.picking_line_id
    , l_parent_mvt_transaction.shipment_header_id
    , l_parent_mvt_transaction.shipment_line_id
    , l_parent_mvt_transaction.ship_to_customer_id
    , l_parent_mvt_transaction.ship_to_site_use_id
    , l_parent_mvt_transaction.bill_to_customer_id
    , l_parent_mvt_transaction.bill_to_site_use_id
    , l_parent_mvt_transaction.vendor_id
    , l_parent_mvt_transaction.vendor_site_id
    , l_parent_mvt_transaction.from_organization_id
    , l_parent_mvt_transaction.to_organization_id
    , l_parent_mvt_transaction.parent_movement_id
    , l_parent_mvt_transaction.inventory_item_id
    , l_parent_mvt_transaction.item_description
    , l_parent_mvt_transaction.item_cost
    , l_parent_mvt_transaction.transaction_quantity
    , l_parent_mvt_transaction.transaction_uom_code
    , l_parent_mvt_transaction.primary_quantity
    , l_parent_mvt_transaction.invoice_batch_id
    , l_parent_mvt_transaction.invoice_id
    , l_parent_mvt_transaction.customer_trx_line_id
    , l_parent_mvt_transaction.invoice_batch_reference
    , l_parent_mvt_transaction.invoice_reference
    , l_parent_mvt_transaction.invoice_line_reference
    , l_parent_mvt_transaction.invoice_date_reference
    , l_parent_mvt_transaction.invoice_quantity
    , l_parent_mvt_transaction.invoice_unit_price
    , l_parent_mvt_transaction.invoice_line_ext_value
    , l_parent_mvt_transaction.outside_code
    , l_parent_mvt_transaction.outside_ext_value
    , l_parent_mvt_transaction.outside_unit_price
    , l_parent_mvt_transaction.currency_code
    , l_parent_mvt_transaction.currency_conversion_rate
    , l_parent_mvt_transaction.currency_conversion_type
    , l_parent_mvt_transaction.currency_conversion_date
    , l_parent_mvt_transaction.period_name
    , l_parent_mvt_transaction.report_reference
    , l_parent_mvt_transaction.report_date
    , l_parent_mvt_transaction.category_id
    , l_parent_mvt_transaction.weight_method
    , l_parent_mvt_transaction.unit_weight
    , l_parent_mvt_transaction.total_weight
    , l_parent_mvt_transaction.transaction_nature
    , l_parent_mvt_transaction.delivery_terms
    , l_parent_mvt_transaction.transport_mode
    , l_parent_mvt_transaction.alternate_quantity
    , l_parent_mvt_transaction.alternate_uom_code
    , l_parent_mvt_transaction.dispatch_territory_code
    , l_parent_mvt_transaction.destination_territory_code
    , l_parent_mvt_transaction.origin_territory_code
    , l_parent_mvt_transaction.stat_method
    , l_parent_mvt_transaction.stat_adj_percent
    , l_parent_mvt_transaction.stat_adj_amount
    , l_parent_mvt_transaction.stat_ext_value
    , l_parent_mvt_transaction.area
    , l_parent_mvt_transaction.port
    , l_parent_mvt_transaction.stat_type
    , l_parent_mvt_transaction.comments
    , l_parent_mvt_transaction.attribute_category
    , l_parent_mvt_transaction.commodity_code
    , l_parent_mvt_transaction.commodity_description
    , l_parent_mvt_transaction.requisition_header_id
    , l_parent_mvt_transaction.requisition_line_id
    , l_parent_mvt_transaction.picking_line_detail_id
    , l_parent_mvt_transaction.usage_type
    , l_parent_mvt_transaction.zone_code
    , l_parent_mvt_transaction.edi_sent_flag
    , l_parent_mvt_transaction.statistical_procedure_code
    , l_parent_mvt_transaction.movement_amount
    , l_parent_mvt_transaction.triangulation_country_code
    , l_parent_mvt_transaction.csa_code
    , l_parent_mvt_transaction.oil_reference_code
    , l_parent_mvt_transaction.container_type_code
    , l_parent_mvt_transaction.flow_indicator_code
    , l_parent_mvt_transaction.affiliation_reference_code
    , l_parent_mvt_transaction.origin_territory_eu_code
    , l_parent_mvt_transaction.destination_territory_eu_code
    , l_parent_mvt_transaction.dispatch_territory_eu_code
    , l_parent_mvt_transaction.set_of_books_period
    , l_parent_mvt_transaction.taric_code
    , l_parent_mvt_transaction.preference_code
    , l_parent_mvt_transaction.rcv_transaction_id
    , l_parent_mvt_transaction.mtl_transaction_id
    , l_parent_mvt_transaction.total_weight_uom_code
    , l_parent_mvt_transaction.financial_document_flag
    --, l_parent_mvt_transaction.opm_trans_id
    , l_parent_mvt_transaction.customer_vat_number
    , l_parent_mvt_transaction.attribute1
    , l_parent_mvt_transaction.attribute2
    , l_parent_mvt_transaction.attribute3
    , l_parent_mvt_transaction.attribute4
    , l_parent_mvt_transaction.attribute5
    , l_parent_mvt_transaction.attribute6
    , l_parent_mvt_transaction.attribute7
    , l_parent_mvt_transaction.attribute8
    , l_parent_mvt_transaction.attribute9
    , l_parent_mvt_transaction.attribute10
    , l_parent_mvt_transaction.attribute11
    , l_parent_mvt_transaction.attribute12
    , l_parent_mvt_transaction.attribute13
    , l_parent_mvt_transaction.attribute14
    , l_parent_mvt_transaction.attribute15
    , l_parent_mvt_transaction.triangulation_country_eu_code
    , l_parent_mvt_transaction.distribution_line_number
    , l_parent_mvt_transaction.ship_to_name
    , l_parent_mvt_transaction.ship_to_number
    , l_parent_mvt_transaction.ship_to_site
    , l_parent_mvt_transaction.edi_transaction_date
    , l_parent_mvt_transaction.edi_transaction_reference
    , l_parent_mvt_transaction.esl_drop_shipment_code;

    --Net rma value into parent po
    l_parent_mvt_transaction.transaction_quantity :=
          l_parent_mvt_transaction.transaction_quantity -
          x_mvt_rma_transaction.transaction_quantity;
    l_parent_mvt_transaction.primary_quantity :=
          l_parent_mvt_transaction.primary_quantity -
          x_mvt_rma_transaction.primary_quantity;
    l_parent_mvt_transaction.document_line_ext_value :=
          l_parent_mvt_transaction.document_line_ext_value -
          x_mvt_rma_transaction.document_line_ext_value;
    l_parent_mvt_transaction.movement_amount :=
          l_parent_mvt_transaction.movement_amount -
          x_mvt_rma_transaction.movement_amount;
    l_parent_mvt_transaction.stat_ext_value :=
          l_parent_mvt_transaction.stat_ext_value -
          NVL(x_mvt_rma_transaction.stat_ext_value,
              x_mvt_rma_transaction.movement_amount);
    l_parent_mvt_transaction.total_weight :=
          l_parent_mvt_transaction.total_weight -
          x_mvt_rma_transaction.total_weight;

    IF l_parent_mvt_transaction.transaction_quantity IS NOT NULL
       AND l_parent_mvt_transaction.transaction_quantity <> 0
    THEN
      l_parent_mvt_transaction.document_unit_price :=
          l_parent_mvt_transaction.document_line_ext_value/
          l_parent_mvt_transaction.transaction_quantity;
      l_parent_mvt_transaction.unit_weight :=
          l_parent_mvt_transaction.total_weight/
          l_parent_mvt_transaction.transaction_quantity;
    END IF;

    IF l_parent_mvt_transaction.alternate_quantity IS NOT NULL
       AND x_mvt_rma_transaction.alternate_quantity IS NOT NULL
    THEN
      l_parent_mvt_transaction.alternate_quantity :=
          l_parent_mvt_transaction.alternate_quantity -
          x_mvt_rma_transaction.alternate_quantity;
    END IF;

    IF l_parent_mvt_transaction.invoice_quantity IS NOT NULL
       AND x_mvt_rma_transaction.invoice_quantity IS NOT NULL
    THEN
      l_parent_mvt_transaction.invoice_quantity :=
          l_parent_mvt_transaction.invoice_quantity +
          x_mvt_rma_transaction.invoice_quantity;
    END IF;

    IF l_parent_mvt_transaction.invoice_line_ext_value IS NOT NULL
       AND x_mvt_rma_transaction.invoice_line_ext_value IS NOT NULL
    THEN
      l_parent_mvt_transaction.invoice_line_ext_value :=
          l_parent_mvt_transaction.invoice_line_ext_value +
          x_mvt_rma_transaction.invoice_line_ext_value;
    END IF;

    IF l_parent_mvt_transaction.invoice_quantity IS NOT NULL
      AND l_parent_mvt_transaction.invoice_quantity <> 0
    THEN
      l_parent_mvt_transaction.invoice_unit_price :=
          l_parent_mvt_transaction.invoice_line_ext_value/
          l_parent_mvt_transaction.invoice_quantity;
    END IF;

    --Update parent SO
    INV_MGD_MVT_STATS_PVT.Update_Movement_Statistics
    ( p_movement_statistics  => l_parent_mvt_transaction
    , x_return_status        => l_return_status
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    );

    --set movement id in rma record to null, because we didn't
    --insert new record and this will be used in calling procedure
    x_mvt_rma_transaction.movement_id := null;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'.Others exception'
                    , l_error
                    );
    END IF;

END Update_SO_With_RMA;

--========================================================================
-- PROCEDURE : Process_RMA_Transaction     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      RMA
-- COMMENT   :
--             This processes all the RMA transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Process_RMA_Transaction
( p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  -- Declare the REF Cursor
  rma_crsr               INV_MGD_MVT_DATA_STR.rtvCurTyp;
  setup_crsr             INV_MGD_MVT_DATA_STR.setupCurTyp;
  ref_crsr               INV_MGD_MVT_DATA_STR.setupCurTyp;
  l_receipt_transaction  INV_MGD_MVT_DATA_STR.Receipt_Transaction_Rec_Type;
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  x_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_movement_transaction_outer INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(2000);
  l_insert_flag          VARCHAR2(1);
  l_vendor_site_id       NUMBER;
  l_site_id              NUMBER;
  l_parent_id            NUMBER;
  l_parent_trans_type    VARCHAR2(25);
  l_return_status        VARCHAR2(1);
  l_insert_status        VARCHAR2(10);
  l_movement_id          NUMBER;
  --l_trans_date           DATE;
  l_subinv_code          RCV_SHIPMENT_LINES.To_Subinventory%TYPE;
  l_subinv_terr_code     VARCHAR2(2);
  l_org_terr_code        VARCHAR2(2);
  l_rma_le_id            NUMBER;
  l_receiving_le_id      NUMBER;
  l_le_terr_code         VARCHAR2(2);
  l_process_flag         VARCHAR2(2);

  --Fix bug 2695323
  l_item_type_code       VARCHAR2(30);

  l_api_name CONSTANT    VARCHAR2(30) := 'Process_RMA_Transaction';
  l_error                VARCHAR2(600);
   l_sold_from_org_code   VARCHAR2(2);  -- 7165989
  l_mvt_stat_status       RCV_TRANSACTIONS.mvt_stat_status%TYPE; -- 7165989
  l_dispatch             mtl_movement_statistics.dispatch_territory_code%TYPE;-- 7165989
  l_destination          mtl_movement_statistics.destination_territory_code%TYPE;-- 7165989
  l_insert	         VARCHAR2(1);-- 7165989
  l_ship_from_loc        VARCHAR2(10);-- 7165989
  l_ship_to_loc          VARCHAR2(10);-- 7165989

  CURSOR c_item_type IS
  SELECT
    oola2.item_type_code
  FROM
    oe_order_lines_all oola1
  , oe_order_lines_all oola2
  WHERE oola1.line_id = l_movement_transaction.order_line_id
    AND oola2.line_id = oola1.reference_line_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;
  l_mvt_stat_status := NULL ; -- 7165989 : initialize the mvt_stat_status in rcv_transactions
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_movement_transaction  := p_movement_transaction;

  -- Call the transaction proxy which processes all the transactions.
  INV_MGD_MVT_PO_MDTR.Get_RMA_Transactions
     ( rma_crsr                => rma_crsr
     , p_movement_transaction => l_movement_transaction
     , p_start_date           => p_start_date
     , p_end_date             => p_end_date
     , x_return_status        => l_return_status);

  IF l_return_status = 'Y' THEN

  <<l_outer>>
  LOOP
    --Reset the movement record for each transaction
    l_movement_transaction  := p_movement_transaction;
    l_movement_id := NULL;

    FETCH rma_crsr INTO
      l_movement_transaction.rcv_transaction_id
    , l_receipt_transaction.parent_transaction_id
    , l_receipt_transaction.transaction_type
    , l_receipt_transaction.source_document_code
    , l_movement_transaction.ship_to_site_use_id
    , l_movement_transaction.order_header_id
    , l_movement_transaction.order_line_id
    , l_movement_transaction.transaction_date
    , l_movement_transaction.organization_id
    , l_subinv_code
    , l_mvt_stat_status;-- 7165989
    /*bug#7165989 : Added code to fetch Order Number. In the absence of Order Number
                    Movement Statistic Processor was not able to pick Invoice detail
                    in First run.*/
    IF (l_movement_transaction.order_header_id IS NOT NULL
        AND l_movement_transaction.order_number IS null) Then
        Begin
			  SELECT  ooha.order_number order_number
			  INTO  l_movement_transaction.order_number
			  FROM OE_ORDER_HEADERS_ALL ooha
			  WHERE ooha.header_id= l_movement_transaction.order_header_id;
	EXCEPTION
	  WHEN OTHERS THEN
	                  NULL;
	END;
    END IF;
/*bug#7165989 : End */

    EXIT WHEN rma_crsr%NOTFOUND;

    SAVEPOINT RMA_Transaction;

    OPEN c_item_type;
    FETCH c_item_type INTO
      l_item_type_code;

    IF c_item_type%NOTFOUND
    THEN
      l_item_type_code := 'STANDARD';
    END IF;
    CLOSE c_item_type;

    --Timezone support, convert server transaction date to legal entity timezone
    l_movement_transaction.transaction_date :=
    INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Server
    ( p_trxn_date => l_movement_transaction.transaction_date
    , p_le_id     => l_movement_transaction.entity_org_id
    );

    INV_MGD_MVT_SETUP_MDTR.Get_Setup_Context
    ( p_legal_entity_id      => l_movement_transaction.entity_org_id
    , p_movement_transaction => l_movement_transaction
    , x_return_status        => l_return_status
    , setup_crsr             => setup_crsr
    );

    --Back up the movement statistics record
    l_movement_transaction_outer := l_movement_transaction;

    <<l_inner>>
    LOOP
      --Reset movement transaction record
      l_movement_transaction := l_movement_transaction_outer;

      FETCH setup_crsr INTO
        l_movement_transaction.zone_code
      , l_movement_transaction.usage_type
      , l_movement_transaction.stat_type
      , l_stat_typ_transaction.reference_period_rule
      , l_stat_typ_transaction.pending_invoice_days
      , l_stat_typ_transaction.prior_invoice_days
      , l_stat_typ_transaction.triangulation_mode;

      EXIT  l_inner WHEN setup_crsr%NOTFOUND;

      IF NVL(l_stat_typ_transaction.reference_period_rule,'SHIPMENT_BASED')
                                                       = 'INVOICE_BASED'
      THEN
        IF l_movement_transaction.document_source_type IS NULL
        THEN
          l_movement_transaction.document_source_type := 'RMA';
        END IF;

        INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
        ( p_stat_typ_transaction => l_stat_typ_transaction
        , x_movement_transaction => l_movement_transaction
        );

        INV_MGD_MVT_FIN_MDTR. Get_Reference_Date
        ( p_stat_typ_transaction  => l_stat_typ_transaction
        , x_movement_transaction  => l_movement_transaction
        );

        l_movement_transaction.transaction_date :=
        l_movement_transaction.reference_date;
      END IF;

      INV_MGD_MVT_SETUP_MDTR.Get_Reference_Context
      ( p_legal_entity_id     => l_movement_transaction.entity_org_id
       , p_start_date          => p_start_date
       , p_end_date            => p_end_date
       , p_transaction_type    => p_transaction_type
       , p_movement_transaction => l_movement_transaction
       , x_return_status       => l_return_status
       , ref_crsr            => ref_crsr
       );

      --   Reset the movement_id before fetching the transaction

      l_movement_transaction.movement_id := NULL;

      -- Bug:5920143. Added new parameter include_establishments in result.
      FETCH ref_crsr INTO
        l_movement_transaction.zone_code
      , l_movement_transaction.usage_type
      , l_movement_transaction.stat_type
      , l_stat_typ_transaction.start_period_name
      , l_stat_typ_transaction.end_period_name
      , l_stat_typ_transaction.period_set_name
      , l_stat_typ_transaction.period_type
      , l_stat_typ_transaction.weight_uom_code
      , l_stat_typ_transaction.conversion_type
      , l_stat_typ_transaction.attribute_rule_set_code
      , l_stat_typ_transaction.alt_uom_rule_set_code
      , l_stat_typ_transaction.start_date
      , l_stat_typ_transaction.end_date
      , l_stat_typ_transaction.category_set_id
      , l_movement_transaction.set_of_books_period
      , l_stat_typ_transaction.gl_currency_code
      , l_movement_transaction.gl_currency_code
      , l_stat_typ_transaction.conversion_option
      , l_stat_typ_transaction.triangulation_mode
      , l_stat_typ_transaction.reference_period_rule
      , l_stat_typ_transaction.pending_invoice_days
      , l_stat_typ_transaction.prior_invoice_days
      , l_stat_typ_transaction.returns_processing
      , l_stat_typ_transaction.kit_method
      , l_stat_typ_transaction.include_establishments;

      IF ref_crsr%NOTFOUND
      THEN
        --the transaction is not inside of start period and end period
        --so not create transaction
        CLOSE ref_crsr;
      ELSE
        INV_MGD_MVT_STATS_PVT.Init_Movement_Record
        (x_movement_transaction => l_movement_transaction);

        -- The RMA details is fetched here because sometimes the ship_to_site
        -- is not present in the RCV table; hence we get the ship to site from
        -- the sales order. This guarentees that the ship to site is not null

        INV_MGD_MVT_PO_MDTR.Get_RMA_Details
        ( p_stat_typ_transaction => l_stat_typ_transaction
        , x_movement_transaction => l_movement_transaction
        , x_return_status        => l_return_status
         );

        --Fix bug3057775. Consider to create mvt RMA at the LE where this
        --RMA is created when the triangulation mode is invoice based.
        --Find out the legal entity where this RMA is created(use existing
        --procedure for SO)
        l_rma_le_id := INV_MGD_MVT_UTILS_PKG.Get_SO_Legal_Entity
                      (p_order_line_id => l_movement_transaction.order_line_id);

        --Find out the legal entity where this RMA is received
        l_receiving_le_id := INV_MGD_MVT_UTILS_PKG.Get_Shipping_Legal_Entity
                             (p_warehouse_id => l_movement_transaction.organization_id);

        --Get subinventory location fix bug 2683302
        l_subinv_terr_code :=
        INV_MGD_MVT_UTILS_PKG.Get_Subinv_Location
        ( p_warehouse_id => l_movement_transaction.organization_id
        , p_subinv_code  => l_subinv_code);

        l_org_terr_code :=
        INV_MGD_MVT_UTILS_PKG.Get_Org_Location
        (p_warehouse_id => l_movement_transaction.organization_id);

        --Get the country where the processor is run
        l_le_terr_code :=
        INV_MGD_MVT_UTILS_PKG.Get_LE_Location
        (p_le_id => l_movement_transaction.entity_org_id);

        l_movement_transaction.dispatch_territory_code :=
        INV_MGD_MVT_UTILS_PKG.Get_Site_Location
        (p_site_use_id => l_movement_transaction.ship_to_site_use_id);
        /*7165989*/
	l_sold_from_org_code :=
        INV_MGD_MVT_UTILS_PKG.Get_Org_Location
        (p_warehouse_id => l_movement_transaction.sold_from_org_id);
	FND_FILE.put_line (FND_FILE.log  , '< l_sold_from_org_code - '|| l_sold_from_org_code );
        /*7165989*/
        --Initialize insert flag
        l_insert_flag := 'N';

        --Fix bug3057775. Initialize process flag, only when this flag is 'Y'
        --the mvt_stat_status in rcv_transactions will be upgrade to 'PROCESSED'
        --otherwise the status remians to 'NEW', so that it will be picked up again
        --when run processor in the other legal entity
        --Fix bug 5453241 do not initialize here. This will cause status reset
        --to 'N' after successfully create a record in first loop. If the
        --status is set back to 'N', the final rcv mvt_status will not be updated
        --to 'PROCESSED'
        --l_process_flag := 'N';

        --Fix bug3057775. Depend on the triangulation mode, the mvt RMA
        --record maybe created at the creating LE not the receiving LE
        IF l_rma_le_id IS NOT NULL AND (l_rma_le_id <> l_receiving_le_id)
        THEN
          --Processor is run at the legal entity where the RMA is created
          IF l_rma_le_id = l_movement_transaction.entity_org_id
          THEN
	  /* 7165989 - check for mvt_stat_status in RCV_TRANSACTIONS before creating triangulation records */
	  /* Create records only when the status is 'NEW' or 'FORDISP'(record already created in the receiving LE)*/
  IF ((NVL(l_stat_typ_transaction.triangulation_mode,'INVOICE_BASED')
               = 'INVOICE_BASED') AND (l_mvt_stat_status is NOT NULL )
	       AND (l_mvt_stat_status = 'NEW' OR l_mvt_stat_status = 'FORDISP')
	       )
   THEN
              l_movement_transaction.destination_territory_code := l_le_terr_code;
	      /* 7165989 triangulation country would be the country where the RMA was created / booked */
	       l_movement_transaction.triangulation_country_code := l_sold_from_org_code;

              l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
                               ( p_movement_transaction => l_movement_transaction);
              l_process_flag := 'Y';
	       /* 7165989*/
      IF (l_insert_flag = 'Y' ) THEN
	        Process_RMA_Triangulation
         	( p_movement_transaction => l_movement_transaction
		, p_stat_typ_transaction => l_stat_typ_transaction
		, x_return_status        =>  x_return_status
		);
 	        /* 7165989 - Change mvt_stat_status in RCV_TRANSACTIONS based on the triangulation records created */
	        /* If status is NEW , change status to 'FORARVL' so that the arrival record can be created in the*/
	        /* receiving LE. If status is 'FORDISP', set status to 'PROCESSED' */
	         IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	          IF (l_mvt_stat_status is NOT NULL AND l_mvt_stat_status = 'NEW') THEN
		      l_mvt_stat_status := 'FORARVL';
	  	  ELSIF (l_mvt_stat_status is NOT NULL AND l_mvt_stat_status = 'FORDISP') THEN
		     l_mvt_stat_status := 'PROCESSED';
		  END IF;
	        END IF;

                FND_FILE.put_line (FND_FILE.log  ,'mvt stat status after update'||l_mvt_stat_status );
	        FND_FILE.put_line (FND_FILE.log  ,'Case 1 : RMA Invoice Based Triangulation run at booking LE' );

      ELSIF (l_insert_flag = 'N') THEN
	        l_dispatch :=
		  INV_MGD_MVT_UTILS_PKG.Get_Org_Location(p_warehouse_id => l_movement_transaction.sold_from_org_id);
		l_destination :=
                  INV_MGD_MVT_UTILS_PKG.Get_Org_Location(p_warehouse_id => l_movement_transaction.organization_id);

	  if (l_dispatch <> l_destination ) THEN

		  l_ship_from_loc :=
		      INV_MGD_MVT_UTILS_PKG.Get_Zone_Code
		     ( p_territory_code => l_dispatch
		     , p_zone_code      => l_movement_transaction.zone_code
		     , p_trans_date     => l_movement_Transaction.transaction_date
		     );

		    l_ship_to_loc :=
		      INV_MGD_MVT_UTILS_PKG.Get_Zone_Code
		   ( p_territory_code => l_destination
		     , p_zone_code      => l_movement_transaction.zone_code
		     , p_trans_date     => l_movement_Transaction.transaction_date
		     );

	     IF l_movement_transaction.usage_type = 'INTERNAL'
             THEN

		  IF (l_ship_from_loc IS NOT NULL)
		       AND (l_ship_to_loc IS NOT NULL)
		       AND (l_ship_from_loc = l_ship_to_loc)
		  THEN
		      l_insert := 'Y';
		  ELSE
		      l_insert := 'N';
		  END If;
	     ELSIF l_movement_transaction.usage_type = 'EXTERNAL'
	     THEN
		    IF (l_ship_from_loc IS NULL)
		       AND (l_ship_to_loc IS NULL)
		    THEN
		      l_insert_flag := 'N';
		    ELSIF  (l_ship_from_loc IS NULL)
		       OR  (l_ship_to_loc   IS NULL)
		       AND (NVL(l_ship_from_loc,'NONE') <> NVL(l_ship_to_loc,'NONE'))
		    THEN
		      l_insert := 'Y';
		    ELSE
		      l_insert := 'N';
		    END IF;
	     ELSE
		 l_insert := 'N';
   	     END IF;

            if (l_insert = 'Y') THEN

			  Process_RMA_Triangulation
			  ( p_movement_transaction => l_movement_transaction
			  , p_stat_typ_transaction => l_stat_typ_transaction
			  , x_return_status        =>  x_return_status
			  );
			  /* 6732517 - Change mvt_stat_status in RCV_TRANSACTIONS based on the triangulation records created */
			  /* If status is NEW , change status to 'FORARVL' so that the arrival record can be created in the*/
			  /* receiving LE. If status is 'FORDISP', set status to 'PROCESSED' */


			  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			    IF (l_mvt_stat_status is NOT NULL AND l_mvt_stat_status = 'NEW') THEN
				l_mvt_stat_status := 'FORARVL';
			    ELSIF (l_mvt_stat_status is NOT NULL AND l_mvt_stat_status = 'FORDISP') THEN
			       l_mvt_stat_status := 'PROCESSED';
			    END IF;
			  END IF;

			  FND_FILE.put_line (FND_FILE.log  ,'mvt stat status after update'||l_mvt_stat_status );
			  FND_FILE.put_line (FND_FILE.log  ,'Case 1.1 : RMA Invoice Based Triangulation run at booking LE where booking LE country is same as the customer country' );
                END IF;
            END IF ;

	END IF;
  /* 7165989*/
     END IF;
          --Processor is run at the legal entity where the RMA is received
          ELSIF l_receiving_le_id = l_movement_transaction.entity_org_id
          THEN
            IF (NVL(l_stat_typ_transaction.triangulation_mode,'INVOICE_BASED')
               = 'SHIPMENT_BASED')
            THEN
              l_movement_transaction.destination_territory_code :=
                         NVL(l_subinv_terr_code, l_org_terr_code);
              l_process_flag := 'Y';

              --Only create record if organization id is located in the same country
              --as legal entity
              -- Bug: 5920143 Validation that LE Territory Code and
              -- Destination Org Territory Code should be same, is needed only when
              -- user has selected Include Establishments as No.
              IF (l_stat_typ_transaction.include_establishments = 'Y' OR
               l_le_terr_code = l_movement_transaction.destination_territory_code)
              THEN
                l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
                                 ( p_movement_transaction => l_movement_transaction);
              END IF;
	       FND_FILE.put_line (FND_FILE.log  ,'Case 2 : RMA Shipment Based Triangulation run at receiving LE' );
            END IF;
	     /********************** Process RMA Triangulation at receiving LE- 7165989 - Start ****************************/

            /* 7165989 - check for mvt_stat_status in RCV_TRANSACTIONS before creating triangulation records */
	    /* Create records only when the status is 'NEW' or 'ARVL(record already created in the selling LE)*/
	    IF ((NVL(l_stat_typ_transaction.triangulation_mode,'INVOICE_BASED') = 'INVOICE_BASED')
	       AND (l_mvt_stat_status is NOT NULL )
	       AND (l_mvt_stat_status = 'NEW' OR l_mvt_stat_status = 'FORARVL')
	       )
            THEN

              l_movement_transaction.destination_territory_code :=
                         NVL(l_subinv_terr_code, l_org_terr_code);
              l_process_flag := 'Y';

	      /* The dispatch territory code   will be the country where the RMA
	         was booked  - sold_from_org_id from OE_ORDER_HEADERS_ALL */
	      l_movement_transaction.dispatch_territory_code := l_sold_from_org_code;
      	      /* triangulation country would be the country where the RMA was created / booked */
	       l_movement_transaction.triangulation_country_code := l_sold_from_org_code;


              --Only create record if organization id is located in the same country
              --as legal entity
              -- Bug: 5765897 Validation that LE Territory Code and
              -- Destination Org Territory Code should be same, is needed only when
              -- user has selected Include Establishments as No.
              IF (l_stat_typ_transaction.include_establishments = 'Y' OR
               l_le_terr_code = l_movement_transaction.destination_territory_code)
              THEN
                l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
                                 ( p_movement_transaction => l_movement_transaction);
              END IF;
	      /* 6732517 - Change mvt_stat_status in RCV_TRANSACTIONS based on the triangulation records created */
	      /* If status is NEW , change status to 'FORARVL' so that the arrival record can be created in the*/
	      /* receiving LE. If status is 'FORDISP', set status to 'PROCESSED' */

              IF (l_insert_flag  = 'Y') THEN
	        IF (l_mvt_stat_status is NOT NULL AND l_mvt_stat_status = 'NEW') THEN
		    l_mvt_stat_status := 'FORDISP';
		ELSIF (l_mvt_stat_status is NOT NULL AND l_mvt_stat_status = 'FORARVL') THEN
		   l_mvt_stat_status := 'PROCESSED';
		END IF;
	      END IF;
	      FND_FILE.put_line (FND_FILE.log  ,'Case 3 : RMA Invoice Based Triangulation run at receiving LE' );

	    END IF;

	    /********************** Process RMA Triangulation at receiving LE - 7165989 - End ****************************/

          END IF;
        ELSE --regular RMA case,the creating LE is same as received LE
          l_movement_transaction.destination_territory_code :=
                     NVL(l_subinv_terr_code, l_org_terr_code);
          l_process_flag := 'Y';

          --Only create record if organization id is located in the same country
          --as legal entity
          -- Bug: 5920143 Validation that LE Territory Code and
          -- Destination Org Territory Code should be same, is needed only when
          -- user has selected Include Establishments as No.
          IF (l_stat_typ_transaction.include_establishments = 'Y' OR
          l_le_terr_code = l_movement_transaction.destination_territory_code )
          THEN
            l_insert_flag := INV_MGD_MVT_SETUP_MDTR.Process_Setup_Context
                           ( p_movement_transaction => l_movement_transaction);
          END IF;

        END IF;

        IF (l_insert_flag = 'Y'
           AND l_return_status = 'Y')
        THEN
          l_process_flag := 'Y';

          INV_MGD_MVT_UTILS_PKG.Mvt_Stats_Util_Info
          ( p_stat_typ_transaction => l_stat_typ_transaction
          , x_movement_transaction => l_movement_transaction
          , x_return_status        => l_return_status
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                            , G_MODULE_NAME || l_api_name
                              || '.Failed when call mvt_stats_util_info'
                            ,'Failed'
                            );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSE
            l_movement_transaction.customer_vat_number :=
            INV_MGD_MVT_UTILS_PKG.Get_Cust_VAT_Number
            (l_movement_transaction.bill_to_site_use_id);

            IF l_movement_transaction.invoice_id IS NULL
            THEN
              l_movement_transaction.invoice_quantity        := NULL;
              l_movement_transaction.financial_document_flag := 'MISSING';
            ELSE
              l_movement_transaction.financial_document_flag
                                                  := 'PROCESSED_INCLUDED';
            END IF;

            --A RMA transaction may need to be netted into its parent
            --SO if the returns processing parameter is set to "Aggregate Return"
            --and the parent SO is not Frozen or Exported
            IF l_stat_typ_transaction.returns_processing = 'AGGRTN'
            THEN
              Update_SO_With_RMA
              ( x_mvt_rma_transaction => l_movement_transaction
              , x_return_status       => l_insert_status
              );
            ELSE
              INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
              (p_api_version_number   => 1.0
              ,p_init_msg_list        => FND_API.G_FALSE
              ,x_movement_transaction => l_movement_transaction
              ,x_msg_count            => x_msg_count
              ,x_msg_data             => x_msg_data
              ,x_return_status        => l_insert_status
              );
            END IF;

            --yawang fix bug 2268875
            IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
               AND l_movement_transaction.movement_id IS NOT NULL
            THEN
              l_movement_id      := l_movement_transaction.movement_id;
              g_records_inserted     := g_records_inserted +1;
            END IF;
          END IF;
        END IF;

        CLOSE ref_crsr;
      END IF;
    END LOOP l_inner;
    CLOSE setup_crsr;

    IF NVL(l_insert_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS
    THEN
      l_movement_transaction.movement_id := l_movement_id;

      IF NVL(l_process_flag,'N') = 'Y'
      THEN
        INV_MGD_MVT_PO_MDTR.Update_PO_Transactions
        ( p_movement_transaction => l_movement_transaction
	 , p_mvt_stat_status      => l_mvt_stat_status /* 7165989 - Pass the appropriate mvt_stat_status for RMA triangulation txns */
        , x_return_status        => l_return_status
         );
      END IF;

      COMMIT;
    ELSE
      ROLLBACK TO SAVEPOINT RMA_Transaction;
    END IF;

    g_records_processed     := g_records_processed +1;
    l_movement_transaction  := p_movement_transaction;
  END LOOP l_outer;
  CLOSE rma_crsr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Unexpected exception'
                    , l_error
                    );
    END IF;

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , l_error
                    );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Others exception in '||l_api_name
                             );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;
    RAISE;

END Process_RMA_Transaction;


--========================================================================
-- PROCEDURE : Update_Invoice_Info     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      Transaction Type
-- COMMENT   :
--             This updates the invoice information for the particular
--             transaction_type
--========================================================================

PROCEDURE Update_Invoice_Info
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  -- Declare the REF Cursor
  inv_crsr               INV_MGD_MVT_DATA_STR.invCurTyp;
  setup_crsr             INV_MGD_MVT_DATA_STR.setupCurTyp;
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  l_insert_flag          VARCHAR2(1);
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(2000);
  l_insert_status        VARCHAR2(10);
  l_movement_id          NUMBER;
  l_return_status        VARCHAR2(1);
  l_api_name CONSTANT    VARCHAR2(30) := 'Update_Invoice_Info';
  l_error                VARCHAR2(600);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_movement_transaction  := p_movement_transaction;

-- Call the transaction proxy which processes all the transactions.

   INV_MGD_MVT_STATS_PVT.Get_Invoice_Transactions
     ( inv_crsr               => inv_crsr
     , p_movement_transaction => l_movement_transaction
     , p_start_date           => p_start_date
     , p_end_date             => p_end_date
     , p_transaction_type     => p_transaction_type
     , x_return_status        => l_return_status);

  IF l_return_status = 'Y' THEN
  LOOP
    --Reset the movement record for each transaction
    l_movement_transaction  := p_movement_transaction;
    l_movement_id := NULL;

    FETCH inv_crsr INTO
      l_movement_transaction.movement_id
    , l_movement_transaction.organization_id
    , l_movement_transaction.entity_org_id
    , l_movement_transaction.movement_type
    , l_movement_transaction.movement_status
    , l_movement_transaction.transaction_date
    , l_movement_transaction.last_update_date
    , l_movement_transaction.last_updated_by
    , l_movement_transaction.creation_date
    , l_movement_transaction.created_by
    , l_movement_transaction.last_update_login
    , l_movement_transaction.document_source_type
    , l_movement_transaction.creation_method
    , l_movement_transaction.document_reference
    , l_movement_transaction.document_line_reference
    , l_movement_transaction.document_unit_price
    , l_movement_transaction.document_line_ext_value
    , l_movement_transaction.receipt_reference
    , l_movement_transaction.shipment_reference
    , l_movement_transaction.shipment_line_reference
    , l_movement_transaction.pick_slip_reference
    , l_movement_transaction.customer_name
    , l_movement_transaction.customer_number
    , l_movement_transaction.customer_location
    , l_movement_transaction.transacting_from_org
    , l_movement_transaction.transacting_to_org
    , l_movement_transaction.vendor_name
    , l_movement_transaction.vendor_number
    , l_movement_transaction.vendor_site
    , l_movement_transaction.bill_to_name
    , l_movement_transaction.bill_to_number
    , l_movement_transaction.bill_to_site
    , l_movement_transaction.po_header_id
    , l_movement_transaction.po_line_id
    , l_movement_transaction.po_line_location_id
    , l_movement_transaction.order_header_id
    , l_movement_transaction.order_line_id
    , l_movement_transaction.picking_line_id
    , l_movement_transaction.shipment_header_id
    , l_movement_transaction.shipment_line_id
    , l_movement_transaction.ship_to_customer_id
    , l_movement_transaction.ship_to_site_use_id
    , l_movement_transaction.bill_to_customer_id
    , l_movement_transaction.bill_to_site_use_id
    , l_movement_transaction.vendor_id
    , l_movement_transaction.vendor_site_id
    , l_movement_transaction.from_organization_id
    , l_movement_transaction.to_organization_id
    , l_movement_transaction.parent_movement_id
    , l_movement_transaction.inventory_item_id
    , l_movement_transaction.item_description
    , l_movement_transaction.item_cost
    , l_movement_transaction.transaction_quantity
    , l_movement_transaction.transaction_uom_code
    , l_movement_transaction.primary_quantity
    , l_movement_transaction.invoice_batch_id
    , l_movement_transaction.invoice_id
    , l_movement_transaction.customer_trx_line_id
    , l_movement_transaction.invoice_batch_reference
    , l_movement_transaction.invoice_reference
    , l_movement_transaction.invoice_line_reference
    , l_movement_transaction.invoice_date_reference
    , l_movement_transaction.invoice_quantity
    , l_movement_transaction.invoice_unit_price
    , l_movement_transaction.invoice_line_ext_value
    , l_movement_transaction.outside_code
    , l_movement_transaction.outside_ext_value
    , l_movement_transaction.outside_unit_price
    , l_movement_transaction.currency_code
    , l_movement_transaction.currency_conversion_rate
    , l_movement_transaction.currency_conversion_type
    , l_movement_transaction.currency_conversion_date
    , l_movement_transaction.period_name
    , l_movement_transaction.report_reference
    , l_movement_transaction.report_date
    , l_movement_transaction.category_id
    , l_movement_transaction.weight_method
    , l_movement_transaction.unit_weight
    , l_movement_transaction.total_weight
    , l_movement_transaction.transaction_nature
    , l_movement_transaction.delivery_terms
    , l_movement_transaction.transport_mode
    , l_movement_transaction.alternate_quantity
    , l_movement_transaction.alternate_uom_code
    , l_movement_transaction.dispatch_territory_code
    , l_movement_transaction.destination_territory_code
    , l_movement_transaction.origin_territory_code
    , l_movement_transaction.stat_method
    , l_movement_transaction.stat_adj_percent
    , l_movement_transaction.stat_adj_amount
    , l_movement_transaction.stat_ext_value
    , l_movement_transaction.area
    , l_movement_transaction.port
    , l_movement_transaction.stat_type
    , l_movement_transaction.comments
    , l_movement_transaction.attribute_category
    , l_movement_transaction.commodity_code
    , l_movement_transaction.commodity_description
    , l_movement_transaction.requisition_header_id
    , l_movement_transaction.requisition_line_id
    , l_movement_transaction.picking_line_detail_id
    , l_movement_transaction.usage_type
    , l_movement_transaction.zone_code
    , l_movement_transaction.edi_sent_flag
    , l_movement_transaction.statistical_procedure_code
    , l_movement_transaction.movement_amount
    , l_movement_transaction.triangulation_country_code
    , l_movement_transaction.csa_code
    , l_movement_transaction.oil_reference_code
    , l_movement_transaction.container_type_code
    , l_movement_transaction.flow_indicator_code
    , l_movement_transaction.affiliation_reference_code
    , l_movement_transaction.origin_territory_eu_code
    , l_movement_transaction.destination_territory_eu_code
    , l_movement_transaction.dispatch_territory_eu_code
    , l_movement_transaction.set_of_books_period
    , l_movement_transaction.taric_code
    , l_movement_transaction.preference_code
    , l_movement_transaction.rcv_transaction_id
    , l_movement_transaction.mtl_transaction_id
    , l_movement_transaction.total_weight_uom_code
    , l_movement_transaction.financial_document_flag
    --, l_movement_transaction.opm_trans_id
    , l_movement_transaction.customer_vat_number
    , l_movement_transaction.attribute1
    , l_movement_transaction.attribute2
    , l_movement_transaction.attribute3
    , l_movement_transaction.attribute4
    , l_movement_transaction.attribute5
    , l_movement_transaction.attribute6
    , l_movement_transaction.attribute7
    , l_movement_transaction.attribute8
    , l_movement_transaction.attribute9
    , l_movement_transaction.attribute10
    , l_movement_transaction.attribute11
    , l_movement_transaction.attribute12
    , l_movement_transaction.attribute13
    , l_movement_transaction.attribute14
    , l_movement_transaction.attribute15
    , l_movement_transaction.triangulation_country_eu_code
    , l_movement_transaction.distribution_line_number
    , l_movement_transaction.ship_to_name
    , l_movement_transaction.ship_to_number
    , l_movement_transaction.ship_to_site
    , l_movement_transaction.edi_transaction_date
    , l_movement_transaction.edi_transaction_reference
    , l_movement_transaction.esl_drop_shipment_code;

    EXIT WHEN inv_crsr%NOTFOUND;

  INV_MGD_MVT_SETUP_MDTR.Get_Invoice_Context
    (  p_legal_entity_id     => l_movement_transaction.entity_org_id
     , p_start_date          => p_start_date
     , p_end_date            => p_end_date
     , p_transaction_type    => p_transaction_type
     , p_movement_transaction => l_movement_transaction
     , x_return_status       => l_return_status
     , setup_crsr            => setup_crsr
     );


  IF l_return_status = 'Y' THEN

    LOOP

      FETCH setup_crsr INTO
        l_stat_typ_transaction.start_period_name
      , l_stat_typ_transaction.end_period_name
      , l_stat_typ_transaction.period_set_name
      , l_stat_typ_transaction.period_type
      , l_stat_typ_transaction.weight_uom_code
      , l_stat_typ_transaction.conversion_type
      , l_stat_typ_transaction.attribute_rule_set_code
      , l_stat_typ_transaction.alt_uom_rule_set_code
      , l_stat_typ_transaction.start_date
      , l_stat_typ_transaction.end_date
      , l_stat_typ_transaction.category_set_id
      , l_stat_typ_transaction.gl_currency_code
      , l_movement_transaction.gl_currency_code
      , l_stat_typ_transaction.conversion_option
      , l_stat_typ_transaction.triangulation_mode
      , l_stat_typ_transaction.reference_period_rule
      , l_stat_typ_transaction.pending_invoice_days
      , l_stat_typ_transaction.prior_invoice_days
      , l_stat_typ_transaction.returns_processing;

    EXIT WHEN setup_crsr%NOTFOUND;

    INV_MGD_MVT_UTILS_PKG.Get_Order_Number
      ( x_movement_transaction => l_movement_transaction
        );

    INV_MGD_MVT_PO_MDTR.Get_Blanket_Info
      ( x_movement_transaction => l_movement_transaction
        );

    INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
      ( p_stat_typ_transaction => l_stat_typ_transaction
      , x_movement_transaction => l_movement_transaction
        );

    l_movement_transaction.movement_amount :=
       INV_MGD_MVT_FIN_MDTR.Calc_Movement_Amount
       (p_movement_transaction  => l_movement_transaction
        );

    --Calculate freight charge and include in statistics value
    l_movement_transaction.stat_ext_value :=
    INV_MGD_MVT_FIN_MDTR.Calc_Statistics_Value
    (p_movement_transaction => l_movement_transaction);

    IF l_movement_transaction.invoice_id IS NOT NULL
    THEN
      IF l_movement_transaction.financial_document_flag = 'MISSING'
      THEN
        l_movement_transaction.financial_document_flag := 'PROCESSED_INCLUDED';
      END IF;
    ELSE
      l_movement_transaction.invoice_line_ext_value := null;
      l_movement_transaction.invoice_unit_price     := null;
      l_movement_transaction.invoice_quantity       := null;
    END IF;


      INV_MGD_MVT_STATS_PVT.Update_Movement_Statistics
       (p_movement_statistics  => l_movement_transaction
      , x_return_status        => l_return_status
      , x_msg_count            => x_msg_count
      , x_msg_data             => x_msg_data
      );


     END LOOP ;
     CLOSE setup_crsr;
    END IF;
   END LOOP ;
   CLOSE inv_crsr;
 END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Unexpected exception'
                    , l_error
                    );
    END IF;

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , l_error
                    );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Others exception in '||l_api_name
                             );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;
    RAISE;

END Update_Invoice_Info;


--========================================================================
-- PROCEDURE : Update_PO_With_Correction     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      Transaction Type
-- COMMENT   :
--             This updates the PO transaction with correction if the original
--             PO is not closed yet
--========================================================================


PROCEDURE Update_PO_With_Correction
( p_legal_entity_id      IN  NUMBER
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  -- Declare the REF Cursor
  inv_crsr                 INV_MGD_MVT_DATA_STR.invCurTyp;
  l_movement_transaction   INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(2000);
  l_correct_qty            NUMBER;
  l_correct_parimary_qty   NUMBER;
  l_weight_uom_code        VARCHAR2(3);
  l_weight_precision       NUMBER;
  l_total_weight           NUMBER;
  l_rounding_method        VARCHAR2(30);
  l_return_status          VARCHAR2(1);
  l_api_name CONSTANT      VARCHAR2(30) := 'Update_PO_With_Correction';
  l_error                  VARCHAR2(600);

  --cursor to get correction quantity
  CURSOR l_correct_quantity IS
  SELECT
    SUM(quantity)
  , SUM(primary_quantity)
  FROM
    rcv_transactions
  WHERE parent_transaction_id = l_movement_transaction.rcv_transaction_id
    AND mvt_stat_status = 'NEW'
    AND transaction_type = 'CORRECT';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Call the transaction proxy which processes all the PO and RTV transactions
  -- with corrections in the specified date range.
  INV_MGD_MVT_STATS_PVT.Get_PO_Trans_With_Correction
  ( inv_crsr               => inv_crsr
  , p_legal_entity_id      => p_legal_entity_id
  , p_start_date           => p_start_date
  , p_end_date             => p_end_date
  , p_transaction_type     => p_transaction_type
  , x_return_status        => l_return_status);

  IF l_return_status = 'Y'
  THEN
    LOOP
    FETCH inv_crsr INTO
      l_movement_transaction.movement_id
    , l_movement_transaction.organization_id
    , l_movement_transaction.entity_org_id
    , l_movement_transaction.movement_type
    , l_movement_transaction.movement_status
    , l_movement_transaction.transaction_date
    , l_movement_transaction.last_update_date
    , l_movement_transaction.last_updated_by
    , l_movement_transaction.creation_date
    , l_movement_transaction.created_by
    , l_movement_transaction.last_update_login
    , l_movement_transaction.document_source_type
    , l_movement_transaction.creation_method
    , l_movement_transaction.document_reference
    , l_movement_transaction.document_line_reference
    , l_movement_transaction.document_unit_price
    , l_movement_transaction.document_line_ext_value
    , l_movement_transaction.receipt_reference
    , l_movement_transaction.shipment_reference
    , l_movement_transaction.shipment_line_reference
    , l_movement_transaction.pick_slip_reference
    , l_movement_transaction.customer_name
    , l_movement_transaction.customer_number
    , l_movement_transaction.customer_location
    , l_movement_transaction.transacting_from_org
    , l_movement_transaction.transacting_to_org
    , l_movement_transaction.vendor_name
    , l_movement_transaction.vendor_number
    , l_movement_transaction.vendor_site
    , l_movement_transaction.bill_to_name
    , l_movement_transaction.bill_to_number
    , l_movement_transaction.bill_to_site
    , l_movement_transaction.po_header_id
    , l_movement_transaction.po_line_id
    , l_movement_transaction.po_line_location_id
    , l_movement_transaction.order_header_id
    , l_movement_transaction.order_line_id
    , l_movement_transaction.picking_line_id
    , l_movement_transaction.shipment_header_id
    , l_movement_transaction.shipment_line_id
    , l_movement_transaction.ship_to_customer_id
    , l_movement_transaction.ship_to_site_use_id
    , l_movement_transaction.bill_to_customer_id
    , l_movement_transaction.bill_to_site_use_id
    , l_movement_transaction.vendor_id
    , l_movement_transaction.vendor_site_id
    , l_movement_transaction.from_organization_id
    , l_movement_transaction.to_organization_id
    , l_movement_transaction.parent_movement_id
    , l_movement_transaction.inventory_item_id
    , l_movement_transaction.item_description
    , l_movement_transaction.item_cost
    , l_movement_transaction.transaction_quantity
    , l_movement_transaction.transaction_uom_code
    , l_movement_transaction.primary_quantity
    , l_movement_transaction.invoice_batch_id
    , l_movement_transaction.invoice_id
    , l_movement_transaction.customer_trx_line_id
    , l_movement_transaction.invoice_batch_reference
    , l_movement_transaction.invoice_reference
    , l_movement_transaction.invoice_line_reference
    , l_movement_transaction.invoice_date_reference
    , l_movement_transaction.invoice_quantity
    , l_movement_transaction.invoice_unit_price
    , l_movement_transaction.invoice_line_ext_value
    , l_movement_transaction.outside_code
    , l_movement_transaction.outside_ext_value
    , l_movement_transaction.outside_unit_price
    , l_movement_transaction.currency_code
    , l_movement_transaction.currency_conversion_rate
    , l_movement_transaction.currency_conversion_type
    , l_movement_transaction.currency_conversion_date
    , l_movement_transaction.period_name
    , l_movement_transaction.report_reference
    , l_movement_transaction.report_date
    , l_movement_transaction.category_id
    , l_movement_transaction.weight_method
    , l_movement_transaction.unit_weight
    , l_movement_transaction.total_weight
    , l_movement_transaction.transaction_nature
    , l_movement_transaction.delivery_terms
    , l_movement_transaction.transport_mode
    , l_movement_transaction.alternate_quantity
    , l_movement_transaction.alternate_uom_code
    , l_movement_transaction.dispatch_territory_code
    , l_movement_transaction.destination_territory_code
    , l_movement_transaction.origin_territory_code
    , l_movement_transaction.stat_method
    , l_movement_transaction.stat_adj_percent
    , l_movement_transaction.stat_adj_amount
    , l_movement_transaction.stat_ext_value
    , l_movement_transaction.area
    , l_movement_transaction.port
    , l_movement_transaction.stat_type
    , l_movement_transaction.comments
    , l_movement_transaction.attribute_category
    , l_movement_transaction.commodity_code
    , l_movement_transaction.commodity_description
    , l_movement_transaction.requisition_header_id
    , l_movement_transaction.requisition_line_id
    , l_movement_transaction.picking_line_detail_id
    , l_movement_transaction.usage_type
    , l_movement_transaction.zone_code
    , l_movement_transaction.edi_sent_flag
    , l_movement_transaction.statistical_procedure_code
    , l_movement_transaction.movement_amount
    , l_movement_transaction.triangulation_country_code
    , l_movement_transaction.csa_code
    , l_movement_transaction.oil_reference_code
    , l_movement_transaction.container_type_code
    , l_movement_transaction.flow_indicator_code
    , l_movement_transaction.affiliation_reference_code
    , l_movement_transaction.origin_territory_eu_code
    , l_movement_transaction.destination_territory_eu_code
    , l_movement_transaction.dispatch_territory_eu_code
    , l_movement_transaction.set_of_books_period
    , l_movement_transaction.taric_code
    , l_movement_transaction.preference_code
    , l_movement_transaction.rcv_transaction_id
    , l_movement_transaction.mtl_transaction_id
    , l_movement_transaction.total_weight_uom_code
    , l_movement_transaction.financial_document_flag
    --, l_movement_transaction.opm_trans_id
    , l_movement_transaction.customer_vat_number
    , l_movement_transaction.attribute1
    , l_movement_transaction.attribute2
    , l_movement_transaction.attribute3
    , l_movement_transaction.attribute4
    , l_movement_transaction.attribute5
    , l_movement_transaction.attribute6
    , l_movement_transaction.attribute7
    , l_movement_transaction.attribute8
    , l_movement_transaction.attribute9
    , l_movement_transaction.attribute10
    , l_movement_transaction.attribute11
    , l_movement_transaction.attribute12
    , l_movement_transaction.attribute13
    , l_movement_transaction.attribute14
    , l_movement_transaction.attribute15
    , l_movement_transaction.triangulation_country_eu_code
    , l_movement_transaction.distribution_line_number
    , l_movement_transaction.ship_to_name
    , l_movement_transaction.ship_to_number
    , l_movement_transaction.ship_to_site
    , l_movement_transaction.edi_transaction_date
    , l_movement_transaction.edi_transaction_reference
    , l_movement_transaction.esl_drop_shipment_code;

    EXIT WHEN inv_crsr%NOTFOUND;

    --yawang open correct quantity cursor
    OPEN l_correct_quantity;
    FETCH l_correct_quantity
    INTO
      l_correct_qty
    , l_correct_parimary_qty;

    IF l_correct_quantity%NOTFOUND
    THEN
      l_correct_qty := 0;
      l_correct_parimary_qty := 0;
      CLOSE l_correct_quantity;
    END IF;

    CLOSE l_correct_quantity;

    --Net correction quantity into original transaction quantity
    l_movement_transaction.transaction_quantity :=
        l_movement_transaction.transaction_quantity + NVL(l_correct_qty,0);
    l_movement_transaction.primary_quantity :=
        l_movement_transaction.primary_quantity + NVL(l_correct_parimary_qty,0);

    --Recalculate document lin ext value
    l_movement_transaction.document_line_ext_value :=
                               abs(l_movement_transaction.document_unit_price *
                               l_movement_transaction.transaction_quantity);

    --Recalculate movement amount
    l_movement_transaction.movement_amount :=
    INV_MGD_MVT_FIN_MDTR.Calc_Movement_Amount
      (p_movement_transaction => l_movement_transaction);

    --Calculate freight charge and include in statistics value
    l_movement_transaction.stat_ext_value :=
    INV_MGD_MVT_FIN_MDTR.Calc_Statistics_Value
    (p_movement_transaction => l_movement_transaction);

    --Fix bug 4866967 and 5203245
    INV_MGD_MVT_UTILS_PKG.Get_Weight_Precision
    (p_legal_entity_id      => l_movement_transaction.entity_org_id
    , p_zone_code           => l_movement_transaction.zone_code
    , p_usage_type          => l_movement_transaction.usage_type
    , p_stat_type           => l_movement_transaction.stat_type
    , x_weight_precision    => l_weight_precision
    , x_rep_rounding        => l_rounding_method
    );

    --Recalculate transaction total weight and alternate quantity
    IF l_movement_transaction.transaction_quantity IS NOT NULL
    THEN
      l_total_weight := l_movement_transaction.unit_weight *
                        l_movement_transaction.transaction_quantity;

      l_movement_transaction.total_weight := INV_MGD_MVT_UTILS_PKG.Round_Number
      ( p_number          => l_total_weight
      , p_precision       => l_weight_precision
      , p_rounding_method => l_rounding_method
      );


      IF (l_movement_transaction.alternate_uom_code IS NOT NULL)
      THEN
        l_movement_transaction.alternate_quantity :=
        INV_MGD_MVT_UTILS_PKG.Convert_alternate_Quantity
        ( p_transaction_quantity  => l_movement_transaction.transaction_quantity
        , p_alternate_uom_code    => l_movement_transaction.alternate_uom_code
        , p_transaction_uom_code  => l_movement_transaction.transaction_uom_code
        , p_inventory_item_id     => l_movement_transaction.inventory_item_id
        );
      END IF;
    ELSE
      l_movement_transaction.total_weight := null;
      l_movement_transaction.unit_weight := null;
    END IF;

    --Update original movement records
    INV_MGD_MVT_STATS_PVT.Update_Movement_Statistics
    ( p_movement_statistics  => l_movement_transaction
    , x_return_status        => l_return_status
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
      UPDATE rcv_transactions
      SET
        mvt_stat_status   = 'PROCESSED'
      , movement_id       = l_movement_transaction.movement_id
      WHERE mvt_stat_status = 'NEW'
        AND transaction_type = 'CORRECT'
        AND parent_transaction_id  = l_movement_transaction.rcv_transaction_id;

      COMMIT;
    END IF;

    END LOOP ;
    CLOSE inv_crsr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Unexpected exception'
                    , l_error
                    );
    END IF;

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , l_error
                    );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Others exception in '||l_api_name
                             );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;
    RAISE;

END Update_PO_With_Correction;

--========================================================================
-- PROCEDURE : Process_Pending_Transaction
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      Transaction Type
-- COMMENT   :
--             This updates the invoice information for the particular
--             transaction_type
--========================================================================

PROCEDURE Process_Pending_Transaction
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
  -- Declare the REF Cursor
  inv_crsr               INV_MGD_MVT_DATA_STR.invCurTyp;
  setup_crsr             INV_MGD_MVT_DATA_STR.setupCurTyp;
  ref_crsr               INV_MGD_MVT_DATA_STR.setupCurTyp;
  mvt_crsr               INV_MGD_MVT_DATA_STR.valCurTyp;
  l_movement_transaction INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_stat_typ_transaction INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;
  l_insert_flag          VARCHAR2(1);
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(2000);
  l_insert_status        VARCHAR2(10);
  l_movement_id          NUMBER;
  l_trans_date           DATE;
  l_return_status        VARCHAR2(1);
  l_api_name CONSTANT    VARCHAR2(30) := 'Process_Pending_Transaction';
  l_error                VARCHAR2(600);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_movement_transaction  := p_movement_transaction;

-- Call the transaction proxy which processes all the transactions.

  INV_MGD_MVT_STATS_PVT.Get_Pending_Txns
     ( p_movement_transaction => l_movement_transaction
     , val_crsr               => mvt_crsr
     , p_document_source_type => p_transaction_type
     , x_return_status        => l_return_status);

  IF l_return_status = 'Y' THEN
  LOOP
    --Reset the movement record for each transaction
    l_movement_transaction  := p_movement_transaction;
    l_movement_id := NULL;

    FETCH mvt_crsr INTO
      l_movement_transaction.movement_id
    , l_movement_transaction.organization_id
    , l_movement_transaction.entity_org_id
    , l_movement_transaction.movement_type
    , l_movement_transaction.movement_status
    , l_movement_transaction.transaction_date
    , l_movement_transaction.last_update_date
    , l_movement_transaction.last_updated_by
    , l_movement_transaction.creation_date
    , l_movement_transaction.created_by
    , l_movement_transaction.last_update_login
    , l_movement_transaction.document_source_type
    , l_movement_transaction.creation_method
    , l_movement_transaction.document_reference
    , l_movement_transaction.document_line_reference
    , l_movement_transaction.document_unit_price
    , l_movement_transaction.document_line_ext_value
    , l_movement_transaction.receipt_reference
    , l_movement_transaction.shipment_reference
    , l_movement_transaction.shipment_line_reference
    , l_movement_transaction.pick_slip_reference
    , l_movement_transaction.customer_name
    , l_movement_transaction.customer_number
    , l_movement_transaction.customer_location
    , l_movement_transaction.transacting_from_org
    , l_movement_transaction.transacting_to_org
    , l_movement_transaction.vendor_name
    , l_movement_transaction.vendor_number
    , l_movement_transaction.vendor_site
    , l_movement_transaction.bill_to_name
    , l_movement_transaction.bill_to_number
    , l_movement_transaction.bill_to_site
    , l_movement_transaction.po_header_id
    , l_movement_transaction.po_line_id
    , l_movement_transaction.po_line_location_id
    , l_movement_transaction.order_header_id
    , l_movement_transaction.order_line_id
    , l_movement_transaction.picking_line_id
    , l_movement_transaction.shipment_header_id
    , l_movement_transaction.shipment_line_id
    , l_movement_transaction.ship_to_customer_id
    , l_movement_transaction.ship_to_site_use_id
    , l_movement_transaction.bill_to_customer_id
    , l_movement_transaction.bill_to_site_use_id
    , l_movement_transaction.vendor_id
    , l_movement_transaction.vendor_site_id
    , l_movement_transaction.from_organization_id
    , l_movement_transaction.to_organization_id
    , l_movement_transaction.parent_movement_id
    , l_movement_transaction.inventory_item_id
    , l_movement_transaction.item_description
    , l_movement_transaction.item_cost
    , l_movement_transaction.transaction_quantity
    , l_movement_transaction.transaction_uom_code
    , l_movement_transaction.primary_quantity
    , l_movement_transaction.invoice_batch_id
    , l_movement_transaction.invoice_id
    , l_movement_transaction.customer_trx_line_id
    , l_movement_transaction.invoice_batch_reference
    , l_movement_transaction.invoice_reference
    , l_movement_transaction.invoice_line_reference
    , l_movement_transaction.invoice_date_reference
    , l_movement_transaction.invoice_quantity
    , l_movement_transaction.invoice_unit_price
    , l_movement_transaction.invoice_line_ext_value
    , l_movement_transaction.outside_code
    , l_movement_transaction.outside_ext_value
    , l_movement_transaction.outside_unit_price
    , l_movement_transaction.currency_code
    , l_movement_transaction.currency_conversion_rate
    , l_movement_transaction.currency_conversion_type
    , l_movement_transaction.currency_conversion_date
    , l_movement_transaction.period_name
    , l_movement_transaction.report_reference
    , l_movement_transaction.report_date
    , l_movement_transaction.category_id
    , l_movement_transaction.weight_method
    , l_movement_transaction.unit_weight
    , l_movement_transaction.total_weight
    , l_movement_transaction.transaction_nature
    , l_movement_transaction.delivery_terms
    , l_movement_transaction.transport_mode
    , l_movement_transaction.alternate_quantity
    , l_movement_transaction.alternate_uom_code
    , l_movement_transaction.dispatch_territory_code
    , l_movement_transaction.destination_territory_code
    , l_movement_transaction.origin_territory_code
    , l_movement_transaction.stat_method
    , l_movement_transaction.stat_adj_percent
    , l_movement_transaction.stat_adj_amount
    , l_movement_transaction.stat_ext_value
    , l_movement_transaction.area
    , l_movement_transaction.port
    , l_movement_transaction.stat_type
    , l_movement_transaction.comments
    , l_movement_transaction.attribute_category
    , l_movement_transaction.commodity_code
    , l_movement_transaction.commodity_description
    , l_movement_transaction.requisition_header_id
    , l_movement_transaction.requisition_line_id
    , l_movement_transaction.picking_line_detail_id
    , l_movement_transaction.usage_type
    , l_movement_transaction.zone_code
    , l_movement_transaction.edi_sent_flag
    , l_movement_transaction.statistical_procedure_code
    , l_movement_transaction.movement_amount
    , l_movement_transaction.triangulation_country_code
    , l_movement_transaction.csa_code
    , l_movement_transaction.oil_reference_code
    , l_movement_transaction.container_type_code
    , l_movement_transaction.flow_indicator_code
    , l_movement_transaction.affiliation_reference_code
    , l_movement_transaction.origin_territory_eu_code
    , l_movement_transaction.destination_territory_eu_code
    , l_movement_transaction.dispatch_territory_eu_code
    , l_movement_transaction.set_of_books_period
    , l_movement_transaction.taric_code
    , l_movement_transaction.preference_code
    , l_movement_transaction.rcv_transaction_id
    , l_movement_transaction.mtl_transaction_id
    , l_movement_transaction.total_weight_uom_code
    , l_movement_transaction.financial_document_flag
    --, l_movement_transaction.opm_trans_id
    , l_movement_transaction.customer_vat_number
    , l_movement_transaction.attribute1
    , l_movement_transaction.attribute2
    , l_movement_transaction.attribute3
    , l_movement_transaction.attribute4
    , l_movement_transaction.attribute5
    , l_movement_transaction.attribute6
    , l_movement_transaction.attribute7
    , l_movement_transaction.attribute8
    , l_movement_transaction.attribute9
    , l_movement_transaction.attribute10
    , l_movement_transaction.attribute11
    , l_movement_transaction.attribute12
    , l_movement_transaction.attribute13
    , l_movement_transaction.attribute14
    , l_movement_transaction.attribute15
    , l_movement_transaction.triangulation_country_eu_code
    , l_movement_transaction.distribution_line_number
    , l_movement_transaction.ship_to_name
    , l_movement_transaction.ship_to_number
    , l_movement_transaction.ship_to_site
    , l_movement_transaction.edi_transaction_date
    , l_movement_transaction.edi_transaction_reference
    , l_movement_transaction.esl_drop_shipment_code;

    EXIT WHEN mvt_crsr%NOTFOUND;

    l_trans_date := l_movement_transaction.transaction_date;

    INV_MGD_MVT_SETUP_MDTR.Get_Invoice_Context
    (  p_legal_entity_id     => l_movement_transaction.entity_org_id
     , p_start_date          => p_start_date
     , p_end_date            => p_end_date
     , p_transaction_type    => p_transaction_type
     , p_movement_transaction => l_movement_transaction
     , x_return_status       => l_return_status
     , setup_crsr            => setup_crsr
     );


    IF l_return_status = 'Y' THEN
    LOOP

      l_movement_transaction.transaction_date := l_trans_date;

      FETCH setup_crsr INTO
        l_stat_typ_transaction.start_period_name
      , l_stat_typ_transaction.end_period_name
      , l_stat_typ_transaction.period_set_name
      , l_stat_typ_transaction.period_type
      , l_stat_typ_transaction.weight_uom_code
      , l_stat_typ_transaction.conversion_type
      , l_stat_typ_transaction.attribute_rule_set_code
      , l_stat_typ_transaction.alt_uom_rule_set_code
      , l_stat_typ_transaction.start_date
      , l_stat_typ_transaction.end_date
      , l_stat_typ_transaction.category_set_id
      , l_stat_typ_transaction.gl_currency_code
      , l_movement_transaction.gl_currency_code
      , l_stat_typ_transaction.conversion_option
      , l_stat_typ_transaction.triangulation_mode
      , l_stat_typ_transaction.reference_period_rule
      , l_stat_typ_transaction.pending_invoice_days
      , l_stat_typ_transaction.prior_invoice_days
      , l_stat_typ_transaction.returns_processing;

      EXIT WHEN setup_crsr%NOTFOUND;

      INV_MGD_MVT_UTILS_PKG.Get_Order_Number
      ( x_movement_transaction => l_movement_transaction
      );

      INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
      ( p_stat_typ_transaction => l_stat_typ_transaction
      , x_movement_transaction => l_movement_transaction
        );

      --Fix bug 4927726
      --Only continue if the invoice is found, otherwise, everything
      --is same as before, no need to go through following code
      IF l_movement_transaction.invoice_id IS NOT NULL
      THEN
        INV_MGD_MVT_FIN_MDTR. Get_Reference_Date
        ( p_stat_typ_transaction  => l_stat_typ_transaction
        , x_movement_transaction  => l_movement_transaction
        );

        l_movement_transaction.transaction_date :=
        NVL(l_movement_transaction.reference_date,
            l_movement_transaction.transaction_date);

        l_movement_transaction.period_name :=
        INV_MGD_MVT_FIN_MDTR.Get_Period_Name
        (p_movement_transaction => l_movement_transaction
        ,p_stat_typ_transaction => l_stat_typ_transaction);

        /* Bug: 5291257. Call to function INV_MGD_MVT_FIN_MDTR.Get_Set_Of_Books_Period
         is modified becasue p_period_type is no more required. */
        l_movement_transaction.set_of_books_period :=
        INV_MGD_MVT_FIN_MDTR.Get_Set_Of_Books_Period
        (p_legal_entity_id => l_movement_transaction.entity_org_id
        ,p_period_date     => NVL(l_movement_transaction.invoice_date_reference,
                                  l_movement_transaction.transaction_date)
        --,p_period_type     => NVL(l_stat_typ_transaction.period_type,'Month')
        );

        /*l_movement_transaction.currency_conversion_date :=
        INV_MGD_MVT_FIN_MDTR.
        Calc_Conversion_Date(p_movement_transaction => l_movement_transaction
                            , p_stat_typ_transaction => l_stat_typ_transaction
                             );

        l_movement_transaction.currency_conversion_rate :=
        INV_MGD_MVT_FIN_MDTR.
        Calc_Exchange_Rate(p_movement_transaction => l_movement_transaction
                          , p_stat_typ_transaction => l_stat_typ_transaction
                          );
        */


       l_movement_transaction.movement_amount :=
       INV_MGD_MVT_FIN_MDTR.Calc_Movement_Amount
       (p_movement_transaction  => l_movement_transaction
        );

        --Calculate freight charge and include in statistics value
        l_movement_transaction.stat_ext_value :=
        INV_MGD_MVT_FIN_MDTR.Calc_Statistics_Value
        (p_movement_transaction => l_movement_transaction);

        l_movement_transaction.financial_document_flag := 'PROCESSED_INCLUDED';
        l_movement_transaction.movement_status         := 'O';

        INV_MGD_MVT_STATS_PVT.Update_Movement_Statistics
        (p_movement_statistics  => l_movement_transaction
        , x_return_status        => l_return_status
        , x_msg_count            => x_msg_count
        , x_msg_data             => x_msg_data
        );
      --Bug: 5911911, Following else clause is added  to change the MS record
      --status from Pending to Open if it has crossed timeframe specified by
      --the Pending Invoice Days parameter.
      ELSE
        IF ( sysdate > l_movement_transaction.transaction_date )
        THEN
         l_movement_transaction.movement_status :='O';
         INV_MGD_MVT_STATS_PVT.Update_Movement_Statistics
          (p_movement_statistics  => l_movement_transaction
         , x_return_status        => l_return_status
         , x_msg_count            => x_msg_count
         , x_msg_data             => x_msg_data
          );
        END IF;
      END IF;
    END LOOP ;
    CLOSE setup_crsr;
    END IF;
  END LOOP ;
  CLOSE mvt_crsr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Unexpected exception'
                    , l_error
                    );
    END IF;

  WHEN NO_DATA_FOUND THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. No data found exception'
                    , l_error
                    );
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Others exception in '||l_api_name
                             );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_api_name||'. Others exception'
                    , l_error
                    );
    END IF;
    RAISE;

END Process_Pending_Transaction;

END INV_MGD_MVT_STATS_PROC;

/
