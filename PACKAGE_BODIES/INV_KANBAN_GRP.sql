--------------------------------------------------------
--  DDL for Package Body INV_KANBAN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_KANBAN_GRP" as
/* $Header: INVGKBNB.pls 115.1 2003/08/21 01:11:53 cjandhya noship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_KANBAN_GRP';

PROCEDURE mydebug(msg IN VARCHAR2) IS
BEGIN
   inv_log_util.trace(msg, 'INV_KANBAN_GRP', 9);
END mydebug;

/*****************************************************************
** API name    INV_KANBAN_GRP
** Type        Group
**
**
**Version     Current version = 1.0
**            Initial version = 1.0
**Name
** PROCEDURE UPDATE_CARD_SUPPLY_STATUS
**
** Purpose
**    This procedure updates the supply status of the kanban card.
** Input parameters
**  p_api_version      IN  NUMBER (required)
**                API Version of this procedure
**  p_init_msg_level   IN  VARCHAR2 (optional)
**                     DEFAULT = FND_API.G_FALSE,
**  p_commit           IN  VARCHAR2 (optional)
**                     DEFAULT = FND_API.G_FALSE,
**  p_kanban_card_id   In VARCHAR2 (required)
**                     kanban card id to be updated
**  p_supply_status    IN varchar2 (required)
**                       INV_KANBAN_PVT.G_Supply_Status_New
**                       INV_KANBAN_PVT.G_Supply_Status_Full
**                       INV_KANBAN_PVT.G_Supply_Status_Empty
**                       INV_KANBAN_PVT.G_Supply_Status_InProcess
**                       INV_KANBAN_PVT.G_Supply_Status_InTransit
**  p_document_type   IN NUMBER
**                     INV_KANBAN_PVT.G_Doc_type_PO          	  1;
**                     INV_KANBAN_PVT.G_Doc_type_Release    	  2;
**                     INV_KANBAN_PVT.G_Doc_type_Internal_Req	  3;
**                     INV_KANBAN_PVT.G_Doc_type_Transfer_Order     4;
**                     INV_KANBAN_PVT.G_Doc_type_Discrete_Job       5;
**                     INV_KANBAN_PVT.G_Doc_type_Rep_Schedule       6;
**                     INV_KANBAN_PVT.G_Doc_type_Flow_Schedule      7;
**                     INV_KANBAN_PVT.G_Doc_type_lot_job   	  8;
**  p_Document_Header_Id IN  NUMBER
**                     Document header id displayed on card activity
**  p_Document_detail_Id IN  NUMBER
**                     Document detail id displayed on card activity
**  p_need_by_date       IN  DATE
**                     Need by date to be specified on the requisition
**  P_replenish_quantity IN  NUMBER
**                     Overrides the kanban size if passed
**  p_source_wip_entity_id IN NUMBER
**                     SOURCE_WIP_ENTITY diplayed on card activity.
**  Output Parameters
**    x_msg_count - number of error messages in the buffer
**    x_msg_data  - error messages
**    x_return_status - fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_success,
**                      fnd_api.g_ret_unexp_error
******************************************************************/

PROCEDURE UPDATE_CARD_SUPPLY_STATUS
  (x_msg_count                     OUT NOCOPY NUMBER,
   x_msg_data                      OUT NOCOPY VARCHAR2,
   x_return_status                 OUT NOCOPY VARCHAR2,
   p_api_version_number            IN  NUMBER,
   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE,
   p_kanban_card_id                IN  NUMBER,
   p_supply_status                 IN  NUMBER,
   p_document_type                 IN  NUMBER DEFAULT NULL,
   p_document_header_id            IN  NUMBER DEFAULT NULL,
   p_document_detail_id            IN  NUMBER DEFAULT NULL,
   p_replenish_quantity            IN  NUMBER DEFAULT NULL,
   p_need_by_date                  IN  DATE   DEFAULT NULL,
   p_source_wip_entity_id          IN  NUMBER DEFAULT NULL
 )
  IS

     l_api_version_number          CONSTANT NUMBER := 1.0;
     l_api_name                    CONSTANT VARCHAR2(30):= 'UPDATE_CARD_SUPPLY_STATUS';
BEGIN
   mydebug('Input: kcard id '||p_kanban_card_id||
	   'Sup_Sts  '||p_supply_status||
	   'doc type '||p_document_type||
	   'doc Hdr  '||p_document_header_id||
	   'doc dtl  '||p_document_detail_id);

   mydebug('need by date '||p_need_by_date||
	   'source wip id '||p_source_wip_entity_id);
   --  Standard call to check for call compatibility

   IF NOT FND_API.COMPATIBLE_API_CALL
     (   l_api_version_number
	 ,   p_api_version_number
	 ,   l_api_name
	 ,   G_PKG_NAME
	 )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   mydebug('Calling INV_Kanban_PVT.Update_Card_Supply_Status');

   INV_KANBAN_PVT.UPDATE_CARD_SUPPLY_STATUS
     (   p_api_version_number          => 1.0
	 ,   p_init_msg_list               => p_init_msg_list
	 ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
	 ,   p_commit                      => p_commit
	 ,   x_return_status               => x_return_status
	 ,   x_msg_count                   => x_msg_count
	 ,   x_msg_data                    => x_msg_data
	 ,   p_kanban_card_id              => p_kanban_card_id
	 ,   p_supply_status               => p_supply_status
	 ,   p_document_type               => p_document_type
	 ,   p_document_header_id          => p_document_header_id
	 ,   p_document_detail_id          => p_document_detail_id
	 ,   p_replenish_quantity          => p_replenish_quantity
	 ,   p_need_by_date                => p_need_by_date
	 ,   p_source_wip_entity_id        => p_source_wip_entity_id);

   mydebug('ret_sts '||x_return_status||
	   'msg '||x_msg_data||
	   'msg cnt'||x_msg_count);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --  Get message count and data
      FND_MSG_PUB.Count_And_Get
        (   p_count  => x_msg_count
	    ,p_data  => x_msg_data
	    );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         --  Get message count and data

	 FND_MSG_PUB.Count_And_Get
	   (   p_count  => x_msg_count
	       ,p_data  => x_msg_data
	       );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PKG_NAME
	       ,'Update_Card_Supply_Status'
	       );
      END IF;
      --  Get message count and data
      FND_MSG_PUB.Count_And_Get
        (   p_count   => x_msg_count
	    ,p_data   => x_msg_data
	    );

END UPDATE_CARD_SUPPLY_STATUS;




PROCEDURE Create_Non_Replenishable_Card
  (X_Return_Status      Out NOCOPY Varchar2,
   x_msg_data           OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   X_Kanban_Card_Id 	OUT NOCOPY NUMBER,
   p_pull_sequence_id   IN  NUMBER,
   p_kanban_size        IN  NUMBER)
  IS
     CURSOR pullseq IS
	SELECT
          pull_sequence_id , organization_id , inventory_item_id ,
          subinventory_name , locator_id , source_type , supplier_id,
          supplier_site_id, source_organization_id, source_subinventory,
	  source_locator_id, wip_line_id, kanban_size, number_of_cards,
	  release_kanban_flag
	  from
          MTL_KANBAN_PULL_SEQUENCES
	  where
          pull_sequence_id = p_pull_sequence_id;

     l_kanban_card_ids    INV_Kanban_PVT.kanban_card_id_tbl_type;
     l_pull_seq_rec       INV_Kanban_PVT.pull_sequence_rec_type;
     l_return_status      varchar2(1) := FND_API.G_RET_STS_SUCCESS;
     l_pullseq_found BOOLEAN := FALSE;
BEGIN

   mydebug('p_pull_sequence_id '||p_pull_sequence_id);
   mydebug('p_kanban_size      '||p_kanban_size);

   FOR pullseq_rec IN pullseq LOOP

      l_pullseq_found := TRUE;

      l_pull_seq_rec.pull_sequence_id          := pullseq_rec.pull_sequence_id;
      l_pull_seq_rec.organization_id           := pullseq_rec.organization_id;
      l_pull_seq_rec.inventory_item_id         := pullseq_rec.inventory_item_id;
      l_pull_seq_rec.subinventory_name         := pullseq_rec.subinventory_name;
      l_pull_seq_rec.locator_id                := pullseq_rec.locator_id;
      l_pull_seq_rec.source_type               := pullseq_rec.source_type;
      l_pull_seq_rec.Kanban_size               := Nvl(p_kanban_size, pullseq_rec.kanban_size);
      l_pull_seq_rec.number_of_cards           := 1;
      l_pull_seq_rec.supplier_id               := pullseq_rec.supplier_id;
      l_pull_seq_rec.supplier_site_id          := pullseq_rec.supplier_site_id;
      l_pull_seq_rec.source_organization_id    := pullseq_rec.source_organization_id;
      l_pull_seq_rec.source_subinventory       := pullseq_rec.source_subinventory;
      l_pull_seq_rec.source_locator_id         := pullseq_rec.source_locator_id;
      l_pull_seq_rec.wip_line_id       	       := pullseq_rec.wip_line_id;
      l_pull_seq_rec.release_kanban_flag       := pullseq_rec.release_kanban_flag;
      l_pull_seq_rec.Kanban_Card_Type 	       := INV_Kanban_Pvt.g_card_type_nonreplenishable;

      -- No need to check for non replenishable cards
      -- if  INV_kanban_PVT.Ok_To_Create_Kanban_Cards(p_pull_sequence_id => p_Pull_sequence_id )  then

	 mydebug('OK to create kanban cards');

	 INV_kanban_PVT.create_kanban_cards( X_return_status          => l_return_status,
					     x_kanban_card_ids        => l_kanban_card_ids,
					     p_pull_sequence_rec      => l_pull_seq_rec,
					     p_supply_status          => inv_kanban_pvt.g_supply_status_new);

	 mydebug('INV_kanban_PVT.create_kanban_cards ret_sts '||l_return_status);

	  if  l_return_status = FND_API.G_RET_STS_ERROR  then
	    Raise FND_API.G_EXC_ERROR;
	  elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
	     Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	   ELSIF  l_return_status <>  FND_API.g_ret_sts_success THEN
	     Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	 end if;

	 IF l_kanban_card_ids.count >= 1 THEN
	    mydebug(' Created Kanban_card '||l_kanban_card_ids(1));
	    x_kanban_card_id := l_kanban_card_ids(1);
	  ELSE
	    mydebug(' No cards created') ;
	    x_kanban_card_id := NULL;
	 END IF;

       --ELSE --if  INV_kanban_PVT.Ok_To_Create_Kanban_Cards(p_pull_sequence_id => p_Pull_sequence_id )
       -- mydebug('Not OK to create kanban cards');
       -- Raise FND_API.G_EXC_ERROR;
       --END if;--if  INV_kanban_PVT.Ok_To_Create_Kanban_Cards(p_pull_sequence_id => p_Pull_sequence_id )

   END LOOP;--FOR pullseq_rec IN pullseq LOOP

   IF l_pullseq_found = FALSE THEN
      mydebug('No pull sequence found');
      FND_MESSAGE.SET_NAME('INV','INV_INVALID_PULL_SEQ');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

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
		  ,'Create_Non_Replenishable_Card'
		  );
       END IF;

       --  Get message count and data

       FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
	    ,p_data                        => x_msg_data
	    );


END Create_Non_Replenishable_Card;

END INV_Kanban_GRP;

/
