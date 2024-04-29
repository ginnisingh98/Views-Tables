--------------------------------------------------------
--  DDL for Package Body WIP_TRANSACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_TRANSACTION_PVT" AS
/* $Header: WIPVTXNB.pls 120.1.12010000.4 2010/03/10 21:07:11 hliew ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Transaction_PVT';

-- Process_OSP_Transaction

PROCEDURE Process_OSP_Transaction
(   p_OSP_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
,   p_validation_level              IN  NUMBER DEFAULT COMPLETE
,   p_return_status                 OUT NOCOPY VARCHAR2
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_msg_count                     OUT NOCOPY NUMBER
,   p_msg_data                      OUT NOCOPY VARCHAR2
)
IS
   l_direct_item_flag   NUMBER;
   l_return_status      VARCHAR2(1);
   l_OSP_rec            WIP_Transaction_PUB.Res_Rec_Type :=
                          WIP_Transaction_PUB.G_MISS_RES_REC;
   l_ShopFloorMove_rec  WIP_Transaction_PUB.ShopFloorMove_Rec_Type  :=
                          WIP_Transaction_PUB.G_MISS_SHOPFLOORMOVE_REC;

 /* this variable is passed as a value for the p_old_res_rec
        in the procedure wip_validate_res.Attributes. Enhancement No: 2665334
*/

   l_old_OSP_rec WIP_Transaction_PUB.Res_Rec_Type :=
                          WIP_Transaction_PUB.G_MISS_RES_REC;

  l_old_ShopFloorMove_rec        WIP_Transaction_PUB.Shopfloormove_Rec_Type :=
                                        WIP_Transaction_PUB.G_MISS_SHOPFLOORMOVE_REC;

  l_log_level     NUMBER := fnd_log.g_current_runtime_level;
  l_error_msg     VARCHAR2(240);
  l_process_phase VARCHAR2(3);
  l_params        wip_logger.param_tbl_t;
  /*Fix bug 9356683*/
  l_receiving_transaction_id   NUMBER;
  l_entity_type                NUMBER;
  l_encumbrance_amount         NUMBER;
  l_encumbrance_quantity       NUMBER;
  l_encumbrance_ccid           NUMBER;
  l_encumbrance_type_id        NUMBER;
  l_logLevel number := fnd_log.g_current_runtime_level;

BEGIN
  l_process_phase := '1';
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_validation_level';
    l_params(1).paramValue  :=  p_validation_level;
    l_params(2).paramName   := 'p_init_msg_list';
    l_params(2).paramValue  :=  p_init_msg_list;

    wip_logger.entryPoint(p_procName     => 'WIP_Transaction_PVT.Process_OSP_Transaction',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  l_OSP_rec := p_OSP_rec;
  l_process_phase := '2';
  -- Check for direct items
  CST_eamCost_PUB.check_if_direct_item (
                  p_api_version      => 1.0,
                  p_validation_level => p_validation_level,
                  p_interface_txn_id => l_OSP_rec.rcv_transaction_id,
                  x_direct_item_flag => l_direct_item_flag,
                  x_return_status    => p_return_status,
                  x_msg_count        => p_msg_count,
                  x_msg_data         => p_msg_data);

  if (p_return_status <> fnd_api.g_ret_sts_success) then
    Raise fnd_api.g_exc_unexpected_error ;
  end if;

  if (l_direct_item_flag = 1) then
    l_process_phase := '3';
    CST_eamCost_PUB.process_direct_item_txn (
                  p_api_version => 1.0,
                  p_validation_level => p_validation_level,
                  p_directItem_rec => l_osp_rec,
                  x_directItem_rec => l_osp_rec,
                  x_return_status => p_return_status,
                  x_msg_count => p_msg_count,
                  x_msg_data => p_msg_data);

    if (p_return_status <> fnd_api.g_ret_sts_success) then
      Raise fnd_api.g_exc_unexpected_error ;
    end if;
  else
     l_process_phase := '4';
     --Default the OSP Record
     WIP_Default_Res.Attributes(
                                p_Res_rec    => l_OSP_rec
                                ,x_Res_rec   => l_OSP_rec);

     /* Fix bug 9356683, for costing encumbrance project*/
     l_receiving_transaction_id := l_OSP_rec.rcv_transaction_id;
     l_entity_type := l_OSP_rec.entity_type;
     /*Call CST_eamCost_PUB.Get_Encumbrance_Data only for EAM Work Order and receiving_
     transaction_id not null*/
     if (l_entity_type = wip_constants.eam and l_receiving_transaction_id is not null) then
        if (l_logLevel <= wip_constants.full_logging) then
           wip_logger.log(p_msg => 'Calling CST_eamCost_PUB.Get_Encumbrance_Data',
                          x_returnStatus => l_return_status);
         end if;

         CST_eamCost_PUB.Get_Encumbrance_Data(
           p_receiving_transaction_id   => l_receiving_transaction_id
           ,x_encumbrance_amount        => l_encumbrance_amount
           ,x_encumbrance_quantity      => l_encumbrance_quantity
           ,x_encumbrance_ccid          => l_encumbrance_ccid
           ,x_encumbrance_type_id       => l_encumbrance_type_id
           ,x_return_status             => p_return_status
           ,x_msg_count                 => p_msg_count
           ,x_msg_data                  => p_msg_data);

         if (l_logLevel <= wip_constants.full_logging) then
           wip_logger.log(p_msg => 'CST_eamCost_PUB.Get_Encumbrance_Data returns '
                                   || p_return_status,
                          x_returnStatus => l_return_status);
         end if;

         if ( p_return_status <> fnd_api.g_ret_sts_success ) then
           raise fnd_api.g_exc_unexpected_error;
         end if;

         l_OSP_rec.encumbrance_type_id   :=  l_encumbrance_type_id;
         l_OSP_rec.encumbrance_amount    :=  l_encumbrance_amount;
         l_OSP_rec.encumbrance_quantity  :=  l_encumbrance_quantity;
         l_OSP_rec.encumbrance_ccid      := l_encumbrance_ccid;
    end if;  --end if entity_type = eam & receiving_transaction_id not null
    /* End of Fix bug 9356683*/
  end if;
  l_process_phase := '5';
  l_OSP_rec := WIP_Res_Util.Convert_Miss_To_Null(l_OSP_rec);
  l_process_phase := '6';
  --Validate the OSP Record
  WIP_Validate_Res.Attributes(x_return_status  => l_return_status
                               ,p_Res_rec       => l_OSP_rec
                               ,p_validation_level => p_validation_level
                               ,p_old_Res_rec  => l_old_OSP_rec);

  l_process_phase := '7';
  if (l_return_status <> FND_API.G_RET_STS_ERROR) then
    WIP_Validate_Res.Entity(
             x_return_status  => l_return_status
            ,p_Res_rec       => l_OSP_rec
            ,p_validation_level => p_validation_level
             ,p_old_Res_rec  => l_old_OSP_rec);
  end if;

  --Bug 7409477(FP 6991030): Resource to be charged must be an OSP resource
   if (l_return_status <> FND_API.G_RET_STS_ERROR) then
        if (l_OSP_rec.autocharge_type IS NOT NULL AND
            l_OSP_rec.autocharge_type <> WIP_CONSTANTS.PO_MOVE AND
            l_OSP_rec.autocharge_type <> WIP_CONSTANTS.PO_RECEIPT)
        then
                l_return_status := FND_API.G_RET_STS_ERROR;
                WIP_Globals.Add_Error_Message
                        (p_message_name => 'WIP_INVALID_OSP_RESOURCE');
        end if;
   end if;

  l_process_phase := '8';
  --Create the OSP record (resource transaction)
  if (l_return_status <> FND_API.G_RET_STS_ERROR) then
    WIP_Res_Util.Insert_Row(p_Res_rec   => l_OSP_rec);
  end if;
  l_process_phase := '9';
  if (l_direct_item_flag <> 1) then
    --Perform the Move transaction if the autocharge is PO Move
    -- do not do this if direct item
    if (l_return_status <> FND_API.G_RET_STS_ERROR) then
       IF l_OSP_rec.autocharge_type = WIP_CONSTANTS.PO_MOVE THEN
           l_process_phase := '10';
           --Default the ShopFloorMove record
           WIP_Default_ShopFloorMove.Attributes(
                   p_ShopFloorMove_rec   => l_ShopFloorMove_rec,
                   x_ShopFloorMove_rec   => l_ShopFloorMove_rec,
                   p_OSP_rec             => l_OSP_rec);
           l_process_phase := '11';
           l_ShopFloorMove_rec :=
             WIP_ShopFloorMove_Util.Convert_Miss_To_Null(l_ShopFloorMove_rec);
           l_process_phase := '12';
           --Validate the ShopFloorMove record
           WIP_Validate_ShopFloorMove.Attributes(
                   x_return_status       => l_return_status,
                   p_ShopFloorMove_rec   => l_ShopFloorMove_rec,
                   p_validation_level    => p_validation_level
                   ,p_old_ShopFloorMove_rec => l_old_ShopFloorMove_rec);
           l_process_phase := '13';
           if (l_return_status <> FND_API.G_RET_STS_ERROR) then
             l_process_phase := '14';
             WIP_Validate_ShopFloorMove.Entity(
                   x_return_status       => l_return_status,
                   p_ShopFloorMove_rec   => l_ShopFloorMove_rec,
                   p_validation_level    => p_validation_level
                   ,p_old_ShopFloorMove_rec => l_old_ShopFloorMove_rec);
           end if;
           l_process_phase := '15';
           --Create the ShopFloorMove record
           if (l_return_status <> FND_API.G_RET_STS_ERROR) then
             WIP_ShopFloorMove_Util.Insert_Row(
                   p_ShopFloorMove_rec   => l_ShopFloorMove_rec);
           end if;
           l_process_phase := '16';
       end if;   -- if autocharge_type = PO_MOVE
     END IF;
   END IF;  -- end of check for direct items

   FND_MSG_PUB.Count_And_Get
   (       p_encoded               =>      FND_API.G_FALSE ,
           p_count                 =>      p_msg_count     ,
           p_data                  =>      p_msg_data
   );
   p_return_status := l_return_status;
   -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'WIP_Transaction_PVT.Process_OSP_Transaction',
                         p_procReturnStatus => p_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      l_OSP_rec.return_status := FND_API.G_RET_STS_ERROR;

      p_return_status := l_OSP_rec.return_status ;

      FND_MSG_PUB.Count_And_Get
      (   p_count                       => p_msg_count
      ,   p_data                        => p_msg_data
      );
      l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                    ' unexpected error: ' || p_msg_data;
      IF (l_log_level <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
          p_procName         => 'WIP_Transaction_PVT.Process_OSP_Transaction',
          p_procReturnStatus => p_return_status,
          p_msg              => l_error_msg,
          x_returnStatus     => l_return_status);
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      l_OSP_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_return_status := l_OSP_rec.return_status ;

      FND_MSG_PUB.Count_And_Get
      (   p_count                       => p_msg_count
      ,   p_data                        => p_msg_data
      );
      l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                    ' unexpected error: ' || p_msg_data;
      IF (l_log_level <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
          p_procName         => 'WIP_Transaction_PVT.Process_OSP_Transaction',
          p_procReturnStatus => p_return_status,
          p_msg              => l_error_msg,
          x_returnStatus     => l_return_status);
      END IF;

   WHEN OTHERS THEN

      l_OSP_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
               ,   'Process_OSP_Transaction' || SQLERRM
               );
      END IF;
      p_return_status := l_OSP_rec.return_status ;

      FND_MSG_PUB.Count_And_Get
      (   p_count                       => p_msg_count
      ,   p_data                        => p_msg_data
      );
      l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                    ' unexpected error: ' || SQLERRM;
      IF (l_log_level <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
          p_procName         => 'WIP_Transaction_PVT.Process_OSP_Transaction',
          p_procReturnStatus => p_return_status,
          p_msg              => l_error_msg,
          x_returnStatus     => l_return_status);
      END IF;
END Process_OSP_Transaction;


--  Start of Comments
--  API name    Get_Transaction
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Transaction
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_dummy                         IN  VARCHAR2
,   x_WIPTransaction_tbl            OUT NOCOPY WIP_Transaction_PUB.Wiptransaction_Tbl_Type
,   x_Res_tbl                       OUT NOCOPY WIP_Transaction_PUB.Res_Tbl_Type
,   x_ShopFloorMove_tbl             OUT NOCOPY WIP_Transaction_PUB.Shopfloormove_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Transaction';
l_WIPTransaction_tbl          WIP_Transaction_PUB.Wiptransaction_Tbl_Type;
l_Res_tbl                     WIP_Transaction_PUB.Res_Tbl_Type;
l_x_Res_tbl                   WIP_Transaction_PUB.Res_Tbl_Type;
l_ShopFloorMove_tbl           WIP_Transaction_PUB.Shopfloormove_Tbl_Type;
l_x_ShopFloorMove_tbl         WIP_Transaction_PUB.Shopfloormove_Tbl_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        NULL;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Get WIPTransaction ( parent = WIPTransaction )
    -- Since I am using WIP Transactions as a dummy parent, the following lines of code don't make sense.
/*
    l_WIPTransaction_tbl :=  WIP_Wiptransaction_Util.Query_Rows
    (   p_dummy               => p_dummy
    );

    --  Loop over WIPTransaction's children

    FOR I1 IN 1..l_WIPTransaction_tbl.COUNT LOOP

        --  Get OSP ( parent = WIPTransaction )

        l_OSP_tbl :=  WIP_Res_Util.Query_Rows
        (   p_dummy                 => l_WIPTransaction_tbl(I1).dummy
        );

        FOR I2 IN 1..l_Res_tbl.COUNT LOOP
            l_Res_tbl(I2).WIPTransaction_Index := I1;
            l_x_Res_tbl
            (l_x_Res_tbl.COUNT + 1)        := l_Res_tbl(I2);
        END LOOP;


        --  Get ShopFloorMove ( parent = WIPTransaction )

        l_ShopFloorMove_tbl :=  WIP_Shopfloormove_Util.Query_Rows
        (   p_dummy                 => l_WIPTransaction_tbl(I1).dummy
        );

        FOR I2 IN 1..l_ShopFloorMove_tbl.COUNT LOOP
            l_ShopFloorMove_tbl(I2).WIPTransaction_Index := I1;
            l_x_ShopFloorMove_tbl
            (l_x_ShopFloorMove_tbl.COUNT + 1) := l_ShopFloorMove_tbl(I2);
        END LOOP;

    END LOOP;

*/
    --  Load out parameters

    x_WIPTransaction_tbl           := l_WIPTransaction_tbl;
    x_Res_tbl                      := l_x_Res_tbl;
    x_ShopFloorMove_tbl            := l_x_ShopFloorMove_tbl;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Transaction'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Transaction;


-- ----------------------------
-- Process_Resource_Transaction
-- ----------------------------

PROCEDURE Process_Resource_Transaction
(   p_res_txn_rec                   IN  WIP_Transaction_PUB.Res_Rec_Type
,   p_validation_level              IN  NUMBER DEFAULT COMPLETE
,   p_return_status                 OUT NOCOPY VARCHAR2
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_msg_count                     OUT NOCOPY NUMBER
,   p_msg_data                      OUT NOCOPY VARCHAR2
)
IS
   l_return_status      VARCHAR2(1);
   l_res_txn_rec        WIP_Transaction_PUB.Res_Rec_Type;

 /* this variable is passed as a value for the p_old_res_rec
        in the procedure wip_validate_res.Attributes. Enhancement No: 2665334
*/

   l_old_OSP_rec WIP_Transaction_PUB.Res_Rec_Type :=
                          WIP_Transaction_PUB.G_MISS_RES_REC;

  l_log_level     NUMBER := fnd_log.g_current_runtime_level;
  l_error_msg     VARCHAR2(240);
  l_process_phase VARCHAR2(3);
  l_params        wip_logger.param_tbl_t;
BEGIN
  l_process_phase := '1';
  -- write parameter value to log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_validation_level';
    l_params(1).paramValue  :=  p_validation_level;
    l_params(2).paramName   := 'p_init_msg_list';
    l_params(2).paramValue  :=  p_init_msg_list;

    wip_logger.entryPoint(p_procName     => 'WIP_Transaction_PVT.Process_Resource_Transaction',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   l_res_txn_rec := p_res_txn_rec;
   l_process_phase := '2';
   --Default the Resource Record
   WIP_Default_Res.Attributes(
                               p_Res_rec    => l_res_txn_rec
                              ,x_Res_rec   => l_res_txn_rec);
   l_process_phase := '3';

   WIP_Res_Util.Print_Record(l_res_txn_rec);
   l_process_phase := '4';
   l_res_txn_rec := WIP_Res_Util.Convert_Miss_To_Null(l_res_txn_rec);
   l_process_phase := '5';
   -- Validate the Resource Record in 2 stages :
   --  1. The Resource Record Attributes
   --  2. The Resource Record Entity as such

   WIP_Validate_Res.Attributes(
                               x_return_status    => l_return_status
                              ,p_Res_rec          => l_res_txn_rec
                              ,p_validation_level => p_validation_level
                              ,p_old_Res_rec  => l_old_OSP_rec);

   l_process_phase := '6';
   WIP_Validate_Res.Entity(
                           x_return_status    => l_return_status
                          ,p_Res_rec         => l_res_txn_rec
                          ,p_validation_level => p_validation_level
                           ,p_old_Res_rec  => l_old_OSP_rec);

   l_process_phase := '7';
   --Create the Resource record (resource transaction)
   WIP_Res_Util.Insert_Row(p_Res_rec   => l_res_txn_rec);
   l_process_phase := '8';
   FND_MSG_PUB.Count_And_Get
   (       p_encoded               =>      FND_API.G_FALSE ,
           p_count                 =>      p_msg_count     ,
           p_data                  =>      p_msg_data
   );

   p_return_status := l_return_status;
   -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'WIP_Transaction_PVT.Process_Resource_Transaction',
                         p_procReturnStatus => p_return_status,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     l_res_txn_rec.return_status := FND_API.G_RET_STS_ERROR;
     l_error_msg := 'process_phase = ' || l_process_phase || ';';
     IF (l_log_level <= wip_constants.trace_logging) THEN
       wip_logger.exitPoint(
          p_procName         => 'WIP_Transaction_PVT.Process_Resource_Transaction',
          p_procReturnStatus => p_return_status,
          p_msg              => l_error_msg,
          x_returnStatus     => l_return_status);
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     l_res_txn_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     l_error_msg := 'process_phase = ' || l_process_phase || ';';
     IF (l_log_level <= wip_constants.trace_logging) THEN
       wip_logger.exitPoint(
          p_procName         => 'WIP_Transaction_PVT.Process_Resource_Transaction',
          p_procReturnStatus => p_return_status,
          p_msg              => l_error_msg,
          x_returnStatus     => l_return_status);
      END IF;
   WHEN OTHERS THEN
     l_res_txn_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
               ,   'Process_Resource_Transaction' || SQLERRM
               );
      END IF;
     l_error_msg := 'process_phase = ' || l_process_phase || ';' ||
                    ' unexpected error: ' || SQLERRM;
      IF (l_log_level <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(
          p_procName         => 'WIP_Transaction_PVT.Process_Resource_Transaction',
          p_procReturnStatus => p_return_status,
          p_msg              => l_error_msg,
          x_returnStatus     => l_return_status);
      END IF;
END Process_Resource_Transaction;



END WIP_Transaction_PVT;

/
