--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_DEF_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_DEF_ATTR" AS
/* $Header: INVDEFSB.pls 120.0 2005/05/25 05:22:47 appldev noship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVDEFSB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of INV_MGD_MVT_DEF_ATTR                                     |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Default_Attr                                                      |
--| HISTORY                                                               |
--|     05/11/1999 pseshadr     Created                                   |
--|     12/04/2002 vma          Default_Attr: added NOCOPY to x_return_sta|
--|                             tus, x_msg_count, x_msg data. Change the  |
--|                             other OUT parameters to IN OUT NOCOPY     |
--|                             parameters. This is to comply with new    |
--|                             PL/SQL standards for better performance.  |
--|                           ! Following this change, l_movement_transact|
--|                           ! ion should be used whenever the program   |
--|                           ! wants to read the original input value of |
--|                           ! p_movement_transaction.                   |
--|    03/17/2005 yawang        Add new program for default movement amt  |
--|                             stat_ext_value, document price and vlaue  |
--+======================================================================*/

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_MGD_MVT_DEF_ATTR';
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_DEF_ATTR.';

--========================================================================
-- PROCEDURE : Default_Attr      PRIVATE
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_movement_transaction
--             x_transaction_nature    Transaction Nature
--             x_delivery_terms        Delivery Terms
--             x_area                  Area where goods arrive/depart
--             x_Port                  Port where goods arrive/depart
--             x_csa_code              Csa code
--             x_oil_reference_code    Used in oil industry
--             x_container_type_code   Container Type
--             x_flow_indicator_code   Used in the oil industry
--             x_affiliation_reference_code
--             x_traic_code            Taric Code
--             x_preference_code       Preference Code
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              message text
-- COMMENT   : This is the callout procedure which is called before
--             inserting records into MVt Stats table to default some of the
--             attributes if the user wanted to define their own values.
--========================================================================

PROCEDURE Default_Attr
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_movement_transaction IN
    Inv_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_transaction_nature         IN OUT NOCOPY VARCHAR2
, x_delivery_terms             IN OUT NOCOPY VARCHAR2
, x_area                       IN OUT NOCOPY VARCHAR2
, x_port                       IN OUT NOCOPY VARCHAR2
, x_csa_code                   IN OUT NOCOPY VARCHAR2
, x_oil_reference_code         IN OUT NOCOPY VARCHAR2
, x_container_type_code        IN OUT NOCOPY VARCHAR2
, x_flow_indicator_code        IN OUT NOCOPY VARCHAR2
, x_affiliation_reference_code IN OUT NOCOPY VARCHAR2
, x_taric_code                 IN OUT NOCOPY VARCHAR2
, x_preference_code            IN OUT NOCOPY VARCHAR2
, x_statistical_procedure_code IN OUT NOCOPY VARCHAR2
, x_transport_mode             IN OUT NOCOPY VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
)
IS

l_movement_transaction
    Inv_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_return_status           VARCHAR2(1);
l_api_version_number      NUMBER := 1.0;
l_procedure_name          CONSTANT VARCHAR2(30) := 'Default_Attr';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , l_procedure_name
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

  l_movement_transaction       := p_movement_transaction;
  x_transaction_nature         := l_movement_transaction.transaction_nature;
  x_delivery_terms             := l_movement_transaction.delivery_terms;
  x_area                       := l_movement_transaction.area;
  x_port                       := l_movement_transaction.port;
  x_csa_code                   := l_movement_transaction.csa_code;
  x_oil_reference_code         := l_movement_transaction.oil_reference_code;
  x_container_type_code        := l_movement_transaction.container_type_code;
  x_flow_indicator_code        := l_movement_transaction.flow_indicator_code;
  x_affiliation_reference_code :=
     l_movement_transaction.affiliation_reference_code;
  x_taric_code                 := l_movement_transaction.taric_code;
  x_preference_code            := l_movement_transaction.preference_code;
  x_statistical_procedure_code := l_movement_transaction.statistical_procedure_code;
  x_transport_mode             := l_movement_transaction.transport_mode;

/* If you need to modify the default values for the following columns
   DO IT HERE. If there is no change required then the values for these
   columns are the same values obtained when calling this procedure

   To define your own defaults:
   STEP 1: replace the value required with the columns as
           indicated by <replace transaction_nature>
   STEP 2: Remove the comment from the line which is indicated by
	   "--" in the beginning of the line.

  For eg: If you want to replace the transaction_nature with a value
          10, then the first line would read as follows:
          x_transaction_nature := '10';

*/

--  x_transaction_nature         := <replace transaction_nature>;
--  x_delivery_terms             := <replace delivery_terms>;
--  x_area                       := <replace area>;
--  x_port                       := <replace port>;
--  x_csa_code                   := <replace csa_code>;
--  x_oil_reference_code         := <replace oil_reference_code>;
--  x_container_type_code        := <replace container_type_code>;
--  x_flow_indicator_code        := <replace flow_indicator_code>;
--  x_affiliation_reference_code :=
--     <replace affiliation_reference_code>;
--  x_taric_code                 := <replace taric_code>;
--  x_preference_code            := <replace preference_code>;
--  x_statistical_procedure_code := <replace statistical_procedure_code>;
--  x_transport_mode             := <replace transport_mode>;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
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
      , 'Default_Attr'
      );
     END IF;
     --  Get message count and data
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     );

END Default_Attr;

--========================================================================
-- PROCEDURE : Default_Value
-- PARAMETERS: p_api_version_number       known api version
--             p_init_msg_list            FND_API.G_TRUE to reset list
--             p_movement_transaction     IN Movement Statistics Record Type
--             x_document_unit_price      IN OUT Unit price on SO/PO
--             x_document_line_ext_vlaue  IN OUT Line value on SO/PO
--             x_movement_amount          IN OUT Movement amount
--             x_stat_ext_value           IN OUT Statistics value
--             x_return_status            return status
--             x_msg_count                number of messages in the list
--             x_msg_data                 message text
-- COMMENT   : This is the callout procedure which is called before
--             inserting records into MVt Stats table to default some of the
--             values if the user wanted to define their own.
--========================================================================

PROCEDURE Default_Value
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_movement_transaction IN
    Inv_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_document_unit_price        IN OUT NOCOPY NUMBER
, x_document_line_ext_value    IN OUT NOCOPY NUMBER
, x_movement_amount            IN OUT NOCOPY NUMBER
, x_stat_ext_value             IN OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
l_movement_transaction
    Inv_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_return_status           VARCHAR2(1);
l_api_version_number      NUMBER := 1.0;
l_procedure_name          CONSTANT VARCHAR2(30) := 'Default_Value';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , l_procedure_name
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

  l_movement_transaction       := p_movement_transaction;
  x_document_unit_price        := l_movement_transaction.document_unit_price;
  x_document_line_ext_value    := l_movement_transaction.document_line_ext_value;
  x_movement_amount            := l_movement_transaction.movement_amount;
  x_stat_ext_value             := l_movement_transaction.stat_ext_value;

/* If you need to modify the values for the following columns
   DO IT HERE. If there is no change required then the values for these
   columns are the same values obtained when calling this procedure

   To define your own values:
   STEP 1: replace the value required with the columns as
           indicated by <replace document_unit_price>
   STEP 2: Remove the comment from the line which is indicated by
	   "--" in the beginning of the line.

  For eg: If you want to replace the document_unit_price with a value 1500
          from your own logic, then the first line would read as follows:
          x_document_unit_price := 1500;

*/

--  x_document_unit_price         := <replace document_unit_price>;
--  x_document_line_ext_value     := <replace document_line_ext_value>;
--  x_movement_amount             := <replace movement_amount>;
--  x_stat_ext_value              := <replace stat_ext_value>;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
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
      , 'Default_Attr'
      );
     END IF;
     --  Get message count and data
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     );
END Default_Value;

END INV_MGD_MVT_DEF_ATTR;

/
