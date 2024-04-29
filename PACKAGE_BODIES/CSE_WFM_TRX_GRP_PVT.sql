--------------------------------------------------------
--  DDL for Package Body CSE_WFM_TRX_GRP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_WFM_TRX_GRP_PVT" AS
/* $Header: CSEWBWRB.pls 120.1 2006/05/31 20:52:33 brmanesh noship $ */

  PROCEDURE wfm_transactions(
    p_api_version      IN NUMBER,
    p_commit           IN VARCHAR2,
    p_validation_level IN NUMBER,
    p_init_msg_list    IN VARCHAR2,
    p_transaction_type IN VARCHAR2,
    p_wfm_values_tbl IN OUT NOCOPY cse_datastructures_pub.wfm_trx_values_tbl,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2)
  IS

    g_pkg_name            VARCHAR2(30) := 'CSE_WFMSG_TRX_GRP_PVT';
    l_wfm_values_tbl      cse_datastructures_pub.WFM_TRX_VALUES_TBL;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_error_msg           VARCHAR2(2000);
    l_sql_error           VARCHAR2(2000);
    l_api_name            VARCHAR2(100) := 'wfm_transactions';
    j                     PLS_INTEGER;
    l_file                VARCHAR2(500);
    l_sysdate             DATE := SYSDATE;
    l_tbl_count           NUMBER := 0;
    l_fnd_success         VARCHAR2(1);
    l_fnd_unexpected      VARCHAR2(1);
    l_return_status       VARCHAR2(1);
    l_txn_type            VARCHAR2(30);
    e_error               EXCEPTION;
    TYPE return_Status_tbl_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
    TYPE error_message_tbl_type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
    l_return_status_tbl return_Status_tbl_type;
    l_error_message_tbl error_message_tbl_type;

  BEGIN

    l_fnd_success         := FND_API.G_RET_STS_SUCCESS;
    l_fnd_unexpected      := FND_API.G_RET_STS_UNEXP_ERROR;

    IF p_transaction_type = 'PROJECT_ITEM_INSTALLED' THEN
      l_txn_type :='PROJ_ITEM_INSTALLED';
    ELSIF p_transaction_type = 'PROJECT_ITEM_UNINSTALLED' THEN
      l_txn_type :='PROJ_ITEM_UNINSTALLED';
    ELSIF p_transaction_type = 'PROJECT_ITEM_IN_SERVICE' THEN
      l_txn_type :='PROJ_ITEM_IN_SERVICE';
    ELSE
      l_txn_type := p_transaction_type;
    END IF;

    x_return_status := l_fnd_success;
    x_msg_data      := NULL;

    j := 1;

    l_tbl_count := 0;
    l_tbl_count := p_wfm_values_tbl.count;

    IF NOT l_tbl_count = 0 THEN
      l_wfm_values_tbl := p_wfm_values_tbl;
      BEGIN
        FOR j in l_wfm_values_tbl.FIRST .. l_wfm_values_tbl.LAST LOOP
          IF l_wfm_values_tbl.EXISTS(j) THEN

            cse_wfm_proc_logic.processing_logic(
              p_item_id             => l_wfm_values_tbl(j).inventory_item_id,
              p_revision            => l_wfm_values_tbl(j).inventory_revision,
              p_lot_number          => l_wfm_values_tbl(j).lot_number,
              p_serial_number       => l_wfm_values_tbl(j).serial_number,
              p_quantity            => l_wfm_values_tbl(j).quantity,
              p_project_id          => l_wfm_values_tbl(j).project_id,
              p_task_id             => l_wfm_values_tbl(j).task_id,
              p_from_network_loc_id  => l_wfm_values_tbl(j).from_network_location_id,
              p_to_network_loc_id    => l_wfm_values_tbl(j).to_network_location_id,
              p_from_party_site_id   => l_wfm_values_tbl(j).from_party_site_id,
              p_to_party_site_id     => l_wfm_values_tbl(j).to_party_site_id,
              p_work_order_number    => l_wfm_values_tbl(j).work_order_number,
              p_transaction_date     => nvl(l_wfm_values_tbl(j).transaction_date,sysdate),
              p_effective_date       => l_wfm_values_tbl(j).effective_date,
              p_transacted_by        => nvl(l_wfm_values_tbl(j).transacted_by,-1),
              p_message_id           => null,
              p_transaction_type     => l_txn_type,
              x_return_status        => l_return_status,
              x_error_message        => l_msg_data);

            IF NOT l_return_status = FND_API.g_ret_sts_success THEN
              RAISE e_error;
            END IF;
          END IF;
        END LOOP;  -- End of Main FOR LOOP
      EXCEPTION
        WHEN e_error THEN
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data := l_msg_data;
          x_msg_count := 1;
          l_return_Status_tbl(j) := fnd_api.g_ret_sts_error;
          l_error_message_tbl(j) := l_msg_data;

      END;

      IF NOT l_return_status_tbl.COUNT = 0 THEN
        FOR j in l_return_status_tbl.FIRST .. l_return_status_tbl.LAST
        LOOP
          IF l_return_status_tbl.EXISTS(j) THEN
            p_wfm_values_tbl(j).return_status := l_return_status_tbl(j);
          END IF;
          IF l_error_message_tbl.EXISTS(j) THEN
            p_wfm_values_tbl(j).error_message := l_error_message_tbl(j);
          END IF;
        END LOOP;
      END IF;
    END IF;

  EXCEPTION
    WHEN others THEN
      l_sql_error := SQLERRM;
      fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
      x_msg_data      := fnd_message.get;
      x_return_status := l_fnd_unexpected;

  END wfm_transactions;

END cse_wfm_trx_grp_pvt;

/
