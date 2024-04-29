--------------------------------------------------------
--  DDL for Package Body WIP_EAM_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EAM_TRANSACTIONS_PVT" AS
/* $Header: WIPVETXB.pls 115.4 2003/03/27 00:45:26 hkarmach noship $*/

G_PKG_NAME             CONSTANT VARCHAR2(30) := 'WIP_EAM_TRANSACTIONS_PVT';

PROCEDURE process_eam_txn(
                       p_subinventory               IN  VARCHAR2 := null,
                       p_lot_number                 IN  VARCHAR2 := null,
                       p_serial_number              IN  VARCHAR2 := null,
                       p_organization_id            IN  NUMBER   := null,
                       p_locator_id                 IN  NUMBER   := null,
                       p_qa_collection_id           IN  NUMBER   := null,
                       p_inventory_item_id          IN  NUMBER   := null,
                       p_dist_acct_id               IN  NUMBER   := null,
                       p_user_id                    IN  NUMBER   := FND_GLOBAL.USER_ID,
                       p_transaction_type_id        IN  NUMBER   := null,
                       p_transaction_source_type_id IN  NUMBER   := null,
                       p_transaction_action_id      IN  NUMBER   := null,
                       p_transaction_quantity       IN  number   := 0,
		       p_revision		    IN  VARCHAR2 := null,
                       p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
                       x_errCode                    OUT NOCOPY NUMBER,
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2,
                       x_statement                  OUT NOCOPY NUMBER) IS

  l_transaction_header_id      NUMBER;
  l_transaction_temp_id        NUMBER;
  l_serial_transaction_temp_id NUMBER;
  l_transaction_temp_id_s      NUMBER;
  l_transaction_quantity       NUMBER;
  l_primary_quantity           NUMBER;
  l_transaction_action_id      NUMBER;
  l_transaction_type_id        NUMBER;
  l_transaction_source_type_id NUMBER;
  l_project_id                 NUMBER;
  l_transaction_flag	       VARCHAR2(3);
  l_task_id                    NUMBER;
  l_revision                   VARCHAR2(3);
  item                         wma_common.Item;
  l_statement                  NUMBER := 0;

BEGIN


    savepoint eam_transaction;


-- prepare the data to insert into MTL_MATERIAL_TRANSACTIONS_TEMP,
-- MTL_SERIAL_NUMBERS_TEMP, and MTL_TRANSACTION_LOTS_TEMP
    select mtl_material_transactions_s.nextval
      into l_transaction_header_id
      from dual;

    x_statement := 10;

   --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get the item info
    item := wma_derive.getItem(p_inventory_item_id, p_organization_id, p_locator_id);

    if (item.invItemID is null) then

        fnd_message.set_name ('WIP', 'WIP_EAM_ITEM_DOES_NOT_EXIST');
        x_errCode := 1;
        x_return_status := 'E';
        x_msg_data  := fnd_message.get;

        return;

    end if; -- end item info check

    x_statement := 20;

--  check if the item is transactable and in active status.
--  If not, raise an error.

	select mtl_transactions_enabled_flag
	into l_transaction_flag
	from mtl_system_items
	where inventory_item_id = p_inventory_item_id
	and organization_id = p_organization_id;

	if l_transaction_flag = 'N' then
		fnd_message.set_name('WIP', 'WIP_EAM_ITEM_NONTRANSACTABLE');
        	FND_MSG_PUB.ADD;
        	RAISE FND_API.G_EXC_ERROR;
	end if;

    l_revision := p_revision;

    l_primary_quantity := p_transaction_quantity;

-- call inventory API to insert data to mtl_material_transactions_temp
-- the spec file is INVTRXUS.pls

    x_errCode := inv_trx_util_pub.insert_line_trx(
                 p_trx_hdr_id      => l_transaction_header_id,
                 p_item_id         => p_inventory_item_id,
                 p_revision        => l_revision,
                 p_org_id          => p_organization_id,
--               p_transaction_mode => 1,
                 p_trx_action_id   => p_transaction_action_id,
                 p_subinv_code     => p_subinventory,
                 p_locator_id      => p_locator_id,
                 p_trx_type_id     => p_transaction_type_id,
                 p_trx_src_type_id => p_transaction_source_type_id,
                 p_dist_id         => p_dist_acct_id,
                 p_trx_qty         => p_transaction_quantity,
                 p_pri_qty         => l_primary_quantity,
                 p_uom             => item.primaryUOMCode,
                 p_date            => sysdate,
                 p_user_id         => p_user_id,
                 x_trx_tmp_id      => l_transaction_temp_id,
                 x_proc_msg        => x_msg_data);

    x_statement := 30;

    if (x_errCode <> 0) then

        x_return_status := 'E';
        return;

    end if;

-- Check whether the item is under lot or serial control or not
-- If it is, insert the data to coresponding tables

    if(item.lotControlCode = WIP_CONSTANTS.LOT) then
    -- the item is under lot control

-- call inventory API to insert data to mtl_transaction_lots_temp
-- the spec file is INVTRXUS.pls
        x_errCode := inv_trx_util_pub.insert_lot_trx(
                     p_trx_tmp_id    => l_transaction_temp_id,
                     p_user_id       => p_user_id,
                     p_lot_number    => p_lot_number,
                     p_trx_qty       => p_transaction_quantity,
                     p_pri_qty       => l_primary_quantity,
                     x_ser_trx_id    => l_serial_transaction_temp_id,
                     x_proc_msg      => x_msg_data);

        if (x_errCode <> 0) then

            x_return_status := 'E';
            return;

        end if;

--    else
--        null;

    end if; -- end lot control check

  -- Check if the item is under serial control or not
    if(item.serialNumberControlCode in (WIP_CONSTANTS.FULL_SN, WIP_CONSTANTS.DYN_RCV_SN)) then
    -- item is under serial control

    -- Check if the item is under lot control or not
        if(item.lotControlCode = WIP_CONSTANTS.LOT) then
        -- under lot control
            l_transaction_temp_id_s := l_serial_transaction_temp_id;

        else

            l_transaction_temp_id_s := l_transaction_temp_id;

        end if;   -- end lot control check

    -- call inventory API to insert data to mtl_serial_numbers_temp
    -- the spec file is INVTRXUS.pls
        x_errCode := inv_trx_util_pub.insert_ser_trx(
                       p_trx_tmp_id     => l_transaction_temp_id_s,
                       p_user_id        => p_user_id,
                       p_fm_ser_num     => p_serial_number,
                       p_to_ser_num     => p_serial_number,
                       x_proc_msg       => x_msg_data);

        if (x_errCode <> 0) then

            return;

        end if;

    else

        null;

    end if;  -- end serial control check

    x_statement := 40;

-- Call Inventory API to process to item
-- the spec file is INVTRXWS.pls

/*
             UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
             SET TRANSACTION_MODE = 1
             WHERE TRANSACTION_HEADER_ID = l_transaction_temp_id;
*/

    x_errCode := inv_lpn_trx_pub.process_lpn_trx(
                       p_trx_hdr_id => l_transaction_header_id,
                       p_proc_mode  => 1,
                       p_commit     => p_commit,
                       x_proc_msg   => x_msg_data);

    x_statement := 50;

    exception
    WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO eam_transaction;

        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get
        (   p_encoded           =>      FND_API.G_FALSE,
            p_count             =>      x_msg_count,
            p_data              =>      x_msg_data
        );

     WHEN OTHERS THEN

        ROLLBACK TO eam_transaction;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get
        (   p_encoded           =>      FND_API.G_FALSE,
            p_count             =>      x_msg_count,
            p_data              =>      x_msg_data
        );

END process_eam_txn;

END WIP_EAM_TRANSACTIONS_PVT;

/
