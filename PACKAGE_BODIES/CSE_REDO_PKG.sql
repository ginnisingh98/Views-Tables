--------------------------------------------------------
--  DDL for Package Body CSE_REDO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_REDO_PKG" AS
-- $Header: CSEREDOB.pls 120.6 2006/05/31 21:11:54 brmanesh noship $

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');

  PROCEDURE Redo_Logic(
    P_Body_Text           IN    VARCHAR2,
    P_Txn_Type_Id         IN    NUMBER,
    P_Stage               IN    VARCHAR2,
    X_Return_Status       OUT   NOCOPY VARCHAR2,
    X_Error_Message       OUT   NOCOPY VARCHAR2)
  IS

    l_Txn_Type             VARCHAR2(100);
    l_Transaction_Id       NUMBER;
    l_Project_Id           NUMBER;
    l_Task_Id              NUMBER;
    l_Item_Id              NUMBER;
    l_Org_Id               NUMBER;
    l_Transaction_Date     DATE;
    l_Transaction_date_Str VARCHAR2(50);
    l_Effective_Date       DATE;
    l_Effective_date_Str   VARCHAR2(50);
    l_Transacted_By        NUMBER;
    l_Quantity             NUMBER;
    l_Serial_Number        VARCHAR2(50);
    l_Lot_Number           VARCHAR2(30);
    l_Revision             VARCHAR2(30);
    l_From_Network_Loc_id  NUMBER;
    l_To_Network_Loc_id    NUMBER;
    l_From_Party_Site_id   NUMBER;
    l_To_Party_Site_id     NUMBER;
    l_Work_order_number    VARCHAR2(500);
    l_Msg_Count            NUMBER;
    l_trx_error_message    VARCHAR2(2000);
    l_error_message        VARCHAR2(2000);
    l_return_status        VARCHAR2(1);
    l_date_str             VARCHAR2(50);
    l_asset_attributes_rec cse_Datastructures_pub.asset_attributes_rec_type;
    l_file                          VARCHAR2(500);
    l_sysdate                       DATE:=sysdate;
  BEGIN

    cse_util_pkg.set_debug;

    l_Txn_type :=   nvl(CSE_UTIL_Pkg.Get_Txn_Type_Code(P_Txn_Type_Id),NULL);

    IF (l_Txn_Type = 'PO_RECEIPT_INTO_PROJECT' AND p_Stage  = 'IB_UPDATE') THEN

      CSE_UTIL_PKG.Get_String_Value(P_Body_Text,'RCV_TRANSACTION_ID',l_Transaction_Id);

      CSE_PO_NOQUEUE_PVT.Process_NoQueue_Txn(
        P_Ref_Id              => l_Transaction_Id,
        p_txn_type            => l_txn_type,
        x_return_status       => l_return_status,
        x_msg_count           => l_msg_count,
        x_msg_data            => l_error_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    ELSIF (l_Txn_Type = 'PO_RECEIPT_INTO_PROJECT' AND p_stage = 'PA_INTERFACE') THEN

      CSE_UTIL_PKG.Get_String_Value(P_Body_Text,'RCV_TRANSACTION_ID',l_Transaction_Id);

      CSE_PO_NOQUEUE_PVT.pa_interface(
        P_Rcv_txn_Id          => l_Transaction_Id,
        x_return_status       => l_return_status,
        x_error_message       => l_error_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    -- Always return Success because we log our own error and we want IB to
    -- update the existing error to P so we have a history.

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_success;
      l_error_message := x_error_message;
    WHEN OTHERS THEN
      x_error_message := SQLERRM;
      x_Return_Status := FND_API.G_Ret_Sts_Unexp_Error;
  END Redo_Logic;

END cse_redo_pkg;

/
