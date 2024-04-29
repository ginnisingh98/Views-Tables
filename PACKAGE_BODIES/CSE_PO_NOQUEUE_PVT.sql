--------------------------------------------------------
--  DDL for Package Body CSE_PO_NOQUEUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_PO_NOQUEUE_PVT" AS
/* $Header: CSEPONQB.pls 120.5 2006/05/31 21:12:13 brmanesh noship $ */

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');

  PROCEDURE process_noqueue_txn(
    P_Ref_Id        IN  NUMBER,
    P_Txn_Type      IN  VARCHAR2,
    x_Return_Status OUT NOCOPY VARCHAR2,
    x_msg_Count     OUT NOCOPY NUMBER,
    x_Msg_data      OUT NOCOPY VARCHAR2)
  IS
    l_Error_Message         VARCHAR2(2000);
    l_Api_Version           NUMBER := 1;
    l_Init_Msg_List         VARCHAR2(1) :=FND_API.G_TRUE;
    l_return_status         VARCHAR2(1);
    l_fnd_success           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_rcv_attributes_rec    CSE_DATASTRUCTURES_PUB.RCV_ATTRIBUTES_REC_TYPE;
    l_Rcv_Txn_tbl           CSE_Datastructures_Pub.Rcv_Txn_Tbl_Type;
    l_ipv_attributes_rec    CSE_DATASTRUCTURES_PUB.IPV_ATTRIBUTES_REC_TYPE;
    l_ipv_Txn_tbl           CSE_Datastructures_Pub.Ipv_Txn_Tbl_Type;
    l_txn_error_rec         CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_txn_error_id          NUMBER;
    e_dpl_Error             EXCEPTION;
    l_Transaction_Id        NUMBER;
    l_eib_Installed         VARCHAR2(1);
    l_debug                 VARCHAR2(1);
    l_file                  VARCHAR2(500);
    l_type_id               NUMBER;
    l_xml_string            VARCHAR2(2000);
    l_error_stage           VARCHAR2(30);
  BEGIN
    l_return_status := l_fnd_success;
    l_error_message := NULL;
    savepoint one;

    cse_util_pkg.set_debug;

    IF P_Txn_Type = 'PO_RECEIPT_INTO_PROJECT' THEN

      l_type_id := cse_util_pkg.get_txn_type_id('PO_RECEIPT_INTO_PROJECT','PO');

      cse_util_pkg.build_error_string(l_xml_string,'RCV_TRANSACTION_ID',p_ref_id);

      l_rcv_attributes_rec.Rcv_Transaction_Id := P_Ref_Id;
      IF (l_debug = 'Y') THEN
        cse_debug_pub.add('No Queue PO_RECEIPT_INTO_PROJECT');
      END IF;

      cse_po_receipt_into_project.update_csi_data(
        l_rcv_attributes_rec,
        l_Rcv_Txn_Tbl,
        l_return_status,
        l_error_message);

      IF NOT l_return_status = l_fnd_success THEN
        l_error_stage := cse_datastructures_pub.g_ib_update;
        RAISE e_dpl_error;
      END IF;

      IF (l_debug = 'Y') THEN
        cse_debug_pub.add('No Queue calling interface_nl_to_pa');
      END IF;

      l_Transaction_Id := l_Rcv_Txn_Tbl(1).CSI_Transaction_Id;

      cse_po_receipt_into_project.interface_nl_to_pa(
        l_Rcv_Txn_Tbl,
        l_return_status,
        l_error_message);

      IF NOT l_return_status = l_fnd_success THEN
        l_error_stage := cse_datastructures_pub.g_pa_interface;
        RAISE e_dpl_error;
      END IF;
    END IF;

  EXCEPTION
    WHEN e_dpl_error THEN
      IF (l_debug = 'Y') THEN
        cse_debug_pub.add('No Queue error'||l_error_Message);
      END IF;

      l_txn_error_rec                     := cse_util_pkg.Init_Txn_Error_Rec;
      l_txn_error_rec.transaction_id      := l_transaction_id;
      l_txn_error_rec.error_text          := l_error_message;
      l_txn_error_rec.source_type         := P_Txn_Type;
      l_txn_error_rec.source_id           := P_Ref_Id;
      l_txn_error_rec.transaction_type_id := l_type_Id;
      l_txn_error_rec.message_string      := l_xml_string;
      l_txn_error_rec.error_stage         := l_error_stage;

      rollback to one;

      csi_transactions_pvt.create_txn_error(
        l_api_version,
        l_init_msg_list,
        'F',
        1,
        l_txn_error_rec,
        l_return_status,
        l_msg_count,
        l_msg_data,
        l_txn_error_id);

  END process_noqueue_txn;

  PROCEDURE pa_interface(
    P_Rcv_Txn_Id    IN  NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2)
  IS
    l_rcv_txn_tbl    cse_datastructures_pub.rcv_txn_tbl_type;
    l_txn_id         NUMBER;

    l_txn_error_rec  csi_datastructures_pub.transaction_error_rec;
    l_txn_error_id   number;
    l_xml_string   varchar2(512);

    l_error_message  varchar2(2000);
    l_msg_count      number;
    l_msg_data       varchar2(2000);
    l_return_status  varchar2(1);

    CURSOR txn_id_cur IS
      SELECT transaction_id
      FROM   csi_transactions
      WHERE  source_dist_ref_id2 = p_rcv_txn_id
      AND    Transaction_Type_Id = cse_util_pkg.get_txn_type_id('PO_RECEIPT_INTO_PROJECT','PO');
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    x_error_message := null;

    savepoint one;

    cse_po_receipt_into_project.get_rcv_transaction_details(
      P_rcv_txn_id,
      l_rcv_txn_tbl,
      x_return_status,
      x_error_message);

    IF x_return_status = fnd_api.g_ret_sts_success THEN

      OPEN  txn_id_cur;
      FETCH txn_id_cur INTO l_txn_id;
      CLOSE txn_id_cur;

      IF NOT l_rcv_txn_tbl.COUNT = 0 THEN
        FOR i IN l_rcv_txn_tbl.FIRST .. l_rcv_txn_tbl.LAST
        LOOP
          l_rcv_txn_tbl(i).csi_transaction_id := l_txn_id;
        END LOOP;

        cse_po_receipt_into_project.interface_nl_to_pa(
          l_rcv_txn_tbl,
          l_return_status,
          l_error_message);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        cse_po_receipt_into_project.cleanup_transaction_temps(p_rcv_txn_id);

      END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      l_txn_error_rec                     := cse_util_pkg.Init_Txn_Error_Rec;
      l_txn_error_rec.transaction_id      := l_txn_id;
      l_txn_error_rec.error_text          := l_error_message;
      l_txn_error_rec.source_type         := 'CSEPORCV';
      l_txn_error_rec.source_id           := l_txn_id;
      l_txn_error_rec.transaction_type_id := 105;
      cse_util_pkg.build_error_string(l_xml_string,'RCV_TRANSACTION_ID',p_rcv_txn_id);
      l_txn_error_rec.message_string      := l_xml_string;
      l_txn_error_rec.error_stage         := cse_datastructures_pub.g_pa_interface;

      rollback to one;

      csi_transactions_pvt.create_txn_error(
        1.0,
        fnd_api.g_true,
        'F',
        1,
        l_txn_error_rec,
        l_return_status,
        l_msg_count,
        l_msg_data,
        l_txn_error_id);
  END Pa_Interface;

END cse_po_noqueue_pvt;

/
