--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_STATS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_STATS_PUB" AS
-- $Header: INVPMVTB.pls 115.5 2002/12/11 00:46:19 yawang ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVPMVTB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Body of INV_MGD_MVT_STATS_PUB                                |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Process_Transaction                                               |
--|     Create_Movement_Statistics                                        |
--|     Reset_Transaction_Status                                            |
--|     Validate_Movement_Statistics                                      |
--|     Update_Movement_Statistics                                        |
--|                                                                       |
--| HISTORY                                                               |
--|     06/14/00 pseshadr        Created                                  |
--|     06/15/00 ksaini          Added Procedures                         |
--+======================================================================*/

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_MGD_MVT_STATS_PUB';

--===================
-- PUBLIC PROCEDURES
--===================
--========================================================================
-- PROCEDURE : Process_Transaction PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              message text
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_source type           Transaction type (SO,PO etc)
-- COMMENT   : Public Procedure
-- COMMENT   :
--             This processes all the transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Process_Transaction
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
, p_legal_entity_id      IN  NUMBER
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_source_type          IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
l_return_status           VARCHAR2(1);
l_api_version_number      NUMBER := 1.0;
L_API_NAME                CONSTANT VARCHAR2(30) := 'Process_Transaction';

BEGIN

  --  Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , L_API_NAME
         , G_PKG_NAME
         )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message stack if required
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Call the Private Process Transaction which does the logic for
-- Movement Statistics before inserting the record in the
-- Movement Statistics table.

   INV_MGD_MVT_STATS_PROC.PROCESS_TRANSACTION
   ( p_api_version_number   => l_api_version_number
   , p_init_msg_list        => FND_API.G_FALSE
   , p_legal_entity_id      => p_legal_entity_id
   , p_start_date           => p_start_date
   , p_end_date             => p_end_date
   , p_source_type          => p_source_type
   , x_return_status        => l_return_status
   , x_msg_count            => x_msg_count
   , x_msg_data             => x_msg_data
   );

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Process_Transaction'
      );
     END IF;
     --  Get message count and data
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     );

END Process_Transaction;

--========================================================================
-- PROCEDURE : Create_Movement_Statistics PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              message text
--             p_movement_transaction  movement transaction data record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Public Procedure
--=======================================================================

PROCEDURE Create_Movement_Statistics
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_movement_transaction OUT
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)

IS
l_return_status       VARCHAR2(1);
l_api_version_number  NUMBER := 1.0;
L_API_NAME            CONSTANT VARCHAR2(30) := 'Create_Movement_Statistics';
l_movement_transaction
  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;

BEGIN

  --  Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , L_API_NAME
         , G_PKG_NAME
         )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message stack if required
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_movement_transaction := p_movement_transaction;

-- Call the Private package which does the insert in the
-- Movement Statistics table.

  INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
  ( p_api_version_number   => l_api_version_number
  , p_init_msg_list        => FND_API.G_FALSE
  , x_movement_transaction => l_movement_transaction
  , x_return_status        => x_return_status
  , x_msg_count            => x_msg_count
  , x_msg_data             => x_msg_data
  );

  x_movement_transaction := l_movement_transaction;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Create_Movement_Statistics'
      );
     END IF;
     --  Get message count and data
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     );
END Create_Movement_Statistics;




--========================================================================
-- PROCEDURE : Reset_Transaction_Status   PUBLIC
--
-- PARAMETERS: x_return_status      Procedure return status
--             x_msg_count          Number of messages in the list
--             x_msg_data           Message text
--             p_api_version_number Known Version Number
--             p_init_msg_list      Empty PL/SQL Table listfor
--                                  Initialization
--
--             p_legal_entity_id    Legal Entity
--             p_zone_code          Zonal Code
--             p_usage_type         Usage Type
--             p_stat_type          Stat Type
----           p_period_name        Period Name for processing
--             p_document_source_type Document Source Type
--                                    (PO,SO,INV,RMA,RTV)
--             p_reset_option       Reset for All, Ignore only or exclude
--                                  Ignore record
--
-- VERSION   : current version         1.0
--             initial version         1.0
--
-- Updated   :  18/Apr/2002
-- History   :  yawang add parameter p_reset_option
--=======================================================================--

PROCEDURE Reset_Transaction_Status
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
, p_legal_entity_id      IN   NUMBER
, p_zone_code            IN   VARCHAR2
, p_usage_type           IN   VARCHAR2
, p_stat_type            IN   VARCHAR2
, p_period_name          IN   VARCHAR2
, p_document_source_type IN   VARCHAR2
, p_reset_option         IN   VARCHAR2
, x_return_status        OUT NOCOPY  VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS

 l_api_version_number      NUMBER := 1.0;
 l_init_msg_list          VARCHAR2(300)   := FND_API.G_FALSE ;
 l_api_name      CONSTANT VARCHAR2(30)    := 'Reset_Transaction_Status';
 l_period_name            VARCHAR2(15);
 l_legal_entity_id        NUMBER;
 l_zone_code              VARCHAR2(10);
 l_usage_type             VARCHAR2(30);
 l_stat_type              VARCHAR2(30);
 l_document_source_type   VARCHAR2(30);
 l_reset_option           VARCHAR2(30);
 l_return_status          VARCHAR2(1);

BEGIN

--  Standard call to check for call compatibility
 IF NOT FND_API.Compatible_API_Call
  ( l_api_version_number
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
 THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

--  Initialize message stack if required
 IF FND_API.to_Boolean(p_init_msg_list)
 THEN
   FND_MSG_PUB.initialize;
 END IF;

 l_return_status := FND_API.G_RET_STS_SUCCESS;


-- Assign the Local Variables

  l_api_version_number   :=   p_api_version_number ;
  l_init_msg_list        :=   p_init_msg_list ;
  l_period_name          :=   p_period_name;
  l_legal_entity_id      :=   p_legal_entity_id;
  l_zone_code            :=   p_zone_code ;
  l_usage_type           :=   p_usage_type;
  l_stat_type            :=   p_stat_type;
  l_document_source_type :=   p_document_source_type ;
  l_reset_option         :=   p_reset_option;
  x_return_status        :=   l_return_status ;


-- Call the Reset_Transaction_Status procedure from the
-- INV_MGD_MVT_STATS_PVT package
--

 INV_MGD_MVT_RESET_TRANS.Reset_Transaction_Status
 ( p_api_version_number   => l_api_version_number
 , p_init_msg_list        => FND_API.G_FALSE
 , p_legal_entity_id      => l_legal_entity_id
 , p_zone_code            => l_zone_code
 , p_usage_type           => l_stat_type
 , p_stat_type            => l_stat_type
 , p_period_name          => l_period_name
 , p_document_source_type => l_document_source_type
 , p_reset_option         => l_reset_option
 , x_return_status        => l_return_status
 , x_msg_count            => x_msg_count
 , x_msg_data             => x_msg_data
 );


IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Reset_Transaction_Status'
      );
     END IF;
     --  Get message count and data
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     );

END Reset_Transaction_Status ;

--========================================================================
-- PROCEDURE : Purge_Movement_Transactions   PUBLIC
--
-- PARAMETERS: x_return_status      Procedure return status
--             p_legal_entity_id    Legal Entity
--             p_zone_code          Zonal Code
--             p_usage_type         Usage Type
--             p_stat_type          Stat Type
----           p_period_name        Period Name for processing
--             p_document_source_type Document Source Type
--                                    (PO,SO,INV,RMA,RTV)
--
-- VERSION   : current version         1.0
--             initial version         1.0
--
-- COMMENT   : Procedure specification

-- Updated   :  09/Jul/2000
--=======================================================================--

PROCEDURE Purge_Movement_Transactions
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
, p_legal_entity_id      IN   NUMBER
, p_zone_code            IN   VARCHAR2
, p_usage_type           IN   VARCHAR2
, p_stat_type            IN   VARCHAR2
, p_period_name          IN   VARCHAR2
, p_document_source_type IN   VARCHAR2
, x_return_status        OUT NOCOPY  VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS

 l_api_version_number     NUMBER          := 1.0 ;
 l_init_msg_list          VARCHAR2(300)   := FND_API.G_FALSE ;
 l_api_name      CONSTANT VARCHAR2(30)    := 'Reset_Transaction_Status';
 l_period_name            VARCHAR2(15);
 l_legal_entity_id        NUMBER;
 l_zone_code              VARCHAR2(10);
 l_usage_type             VARCHAR2(30);
 l_stat_type              VARCHAR2(30);
 l_document_source_type   VARCHAR2(30);
 l_return_status          VARCHAR2(1);

BEGIN

--  Standard call to check for call compatibility
 IF NOT FND_API.Compatible_API_Call
  ( l_api_version_number
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
 THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

--  Initialize message stack if required
 IF FND_API.to_Boolean(p_init_msg_list)
 THEN
   FND_MSG_PUB.initialize;
 END IF;

 l_return_status := FND_API.G_RET_STS_SUCCESS;


-- Assign the Local Variables

  l_api_version_number   :=   p_api_version_number ;
  l_init_msg_list        :=   p_init_msg_list ;
  l_period_name          :=   p_period_name;
  l_legal_entity_id      :=   p_legal_entity_id;
  l_zone_code            :=   p_zone_code ;
  l_usage_type           :=   p_usage_type;
  l_stat_type            :=   p_stat_type;
  l_document_source_type :=   p_document_source_type ;
  x_return_status        :=   l_return_status ;


-- Call the Reset_Transaction_Status procedure from the
-- INV_MGD_MVT_STATS_PVT package
--

 INV_MGD_MVT_PURGE_TRANS.Purge_Movement_Transactions
( p_api_version_number   => l_api_version_number
 , p_init_msg_list        => FND_API.G_FALSE
 , p_legal_entity_id      => l_legal_entity_id
 , p_zone_code            => l_zone_code
 , p_usage_type           => l_stat_type
 , p_stat_type            => l_stat_type
 , p_period_name          => l_period_name
 , p_document_source_type => l_document_source_type
 , x_return_status        => l_return_status
 , x_msg_count            => x_msg_count
 , x_msg_data             => x_msg_data
 );


IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Purge_Movement_Transactions'
      );
     END IF;
     --  Get message count and data
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     );

END Purge_Movement_Transactions ;

--=============================================================================-
-- PROCEDURE : Validate_Movement_Statistics  PUBLIC
--
-- PARAMETERS:
--             p_movement_statistics     Material Movement Statistics transaction
--                                       Input data record
--             p_movement_stat_usages_rec usage record
--             x_excp_list               PL/SQL Table type list for storing
--                                       and returning the Exception messages
--             x_return_status           Procedure return status
--             x_msg_count               Number of messages in the list
--             x_msg_data                Message text
--             x_movement_statistics     Material Movement Statistics transaction
--                                       Output data record
--
-- VERSION   : current version           1.0
--             initial version           1.0
--
-- COMMENT   :  Procedure specification to Perform the
--              Validation for the Movement
--             Statistics Record FOR Exceptions
--
-- CREATED  : 10/20/1999
--=============================================================================-
PROCEDURE Validate_Movement_Statistics
 ( p_movement_statistics     IN
     INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 , p_movement_stat_usages_rec IN
     INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
 , x_excp_list                OUT NOCOPY
     INV_MGD_MVT_DATA_STR.excp_list
 , x_updated_flag             OUT NOCOPY VARCHAR2
 , x_return_status            OUT NOCOPY VARCHAR2
 , x_msg_count                OUT NOCOPY NUMBER
 , x_msg_data                 OUT NOCOPY VARCHAR2
 , x_movement_statistics      OUT
     INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 )
IS

-- local variables
 l_mtl_movement_statistics
                   INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
 l_movement_stat_usages_rec
                   INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type;

 l_excp_list       INV_MGD_MVT_DATA_STR.excp_list;
 l_ret_movement_statistics
                   INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
 l_record_status   VARCHAR2(1);
 l_return_status   VARCHAR2(1);
 l_updated_flag    VARCHAR2(1);

BEGIN

 l_return_status := FND_API.G_RET_STS_SUCCESS;

 INV_MGD_MVT_STATS_PVT.Validate_Movement_Statistics
    ( p_movement_statistics      => p_movement_statistics
    , p_movement_stat_usages_rec => p_movement_stat_usages_rec
    , x_return_status            => l_return_status
    , x_updated_flag             => x_updated_flag
    , x_msg_count                => x_msg_count
    , x_msg_data                 => x_msg_data
    , x_excp_list                => l_excp_list
    , x_movement_statistics      => l_ret_movement_statistics
    );

x_movement_statistics := l_ret_movement_statistics;

IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    l_return_status := FND_API.G_RET_STS_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Validate_Movement_Statistics'
      );
     END IF;
     --  Get message count and data
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     );

END Validate_Movement_Statistics;


--========================================================================
-- PROCEDURE : Update_Movement_Statistics   PUBLIC
--
-- PARAMETERS: x_return_status      Procedure return status
--             x_msg_count          Number of messages in the list
--             x_msg_data           Message text
--             p_movement_statistics  Material Movement Statistics transaction
--                                  Input data record
--
-- COMMENT   : Procedure body to Update the Movement
--             Statistics record with the
--             calculated values ( EX: Invoice information, Status etc ).
-- Updated   : 09/Jul/1999
--=======================================================================--

PROCEDURE Update_Movement_Statistics (
  p_movement_statistics  IN
  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status                OUT NOCOPY    VARCHAR2
, x_msg_count                    OUT NOCOPY    NUMBER
, x_msg_data                     OUT NOCOPY    VARCHAR2
)
IS

  l_ret_movement_statistics
                   INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(100);

BEGIN


  x_return_status := FND_API.G_RET_STS_SUCCESS;

INV_MGD_MVT_STATS_PVT.Update_Movement_Statistics
               ( p_movement_statistics => l_ret_movement_statistics
               , x_return_status   => l_return_status
               , x_msg_count  => l_msg_count
               , x_msg_data   => l_msg_data
               );

IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    l_return_status := FND_API.G_RET_STS_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Update_Movement_Statistics'
      );
     END IF;
     --  Get message count and data
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     );
  END Update_Movement_Statistics;


END INV_MGD_MVT_STATS_PUB;

/
