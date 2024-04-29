--------------------------------------------------------
--  DDL for Package Body INV_3PL_BILLING_COUNTER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_3PL_BILLING_COUNTER_PVT" AS
/* $Header: INVVBLCB.pls 120.0.12010000.3 2010/04/28 13:26:46 gjyoti noship $ */


    g_debug     NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_3PL_BILLING_COUNTER_PVT';

    PROCEDURE debug( p_message  IN  VARCHAR2 )
    IS
    BEGIN
        inv_log_util.trace(p_message, G_PKG_NAME , 10 );
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END debug;

    FUNCTION get_top_counter_details (p_contract_id NUMBER, p_cle_id NUMBER)
    RETURN NUMBER
    AS
        l_counter_item_id NUMBER;

        CURSOR c_top_cntr IS
            SELECT  counter_details.counter_item_id,
                    counter_details.counter_name
             FROM (
                    SELECT cnt_itm.jtot_object1_code, cont_headers.id contract_id,
                            cont_headers.contract_number, cnt_itm.object1_id1 counter_item_id,
                            counters.counter_name,line_Details.cle_id parent_service_line_id,
                            cnt_itm.id cntr_id , cnt_itm.cle_id
                        FROM okc_k_items cnt_itm
                            , csi_counters_v counters
                            , okc_k_lines_b line_details
                            , okc_k_headers_all_b cont_headers
                        WHERE cnt_itm.jtot_object1_code = 'OKX_COUNTER'
                        AND cont_headers.id = line_Details.dnz_chr_id
                        AND line_details.lse_id=13
                        AND cnt_itm.dnz_chr_id = line_Details.dnz_chr_id
                        AND cnt_itm.cle_id =  line_Details.id
                        and cnt_itm.object1_id1 = counters.counter_id
                        AND cont_headers.id = p_contract_id
                        AND line_details.cle_id = p_cle_id
                        ORDER BY cnt_itm.id ASC
                    ) counter_details
            WHERE ROWNUM <2 ;

    BEGIN

        FOR counter_rec IN c_top_cntr
        LOOP
          l_counter_item_id := counter_rec.counter_item_id ;
        END LOOP;

        RETURN l_counter_item_id;

    EXCEPTION
      WHEN OTHERS THEN
          RETURN -99;

    END get_top_counter_details;


    PROCEDURE inv_insert_readings_using_api ( p_counter_id NUMBER,
                                              p_count_date DATE,
                                              p_new_reading NUMBER,
                                              p_net_reading NUMBER,
                                              p_transaction_id NUMBER
                                             )
    AS
        l_return_status              VARCHAR2(30);
        l_msg_count                  NUMBER;
        l_msg_data                   VARCHAR2(2000);
        l_c_ind_txn                  BINARY_INTEGER := 0;
        l_c_ind_rdg                  BINARY_INTEGER := 0;
        l_c_ind_prop                 BINARY_INTEGER := 0;
        l_transaction_tbl            csi_datastructures_pub.transaction_tbl;
        l_counter_readings_tbl       csi_ctr_datastructures_pub.counter_readings_tbl;
        l_ctr_property_readings_tbl  csi_ctr_datastructures_pub.ctr_property_readings_tbl;
        l_transaction_type_id        NUMBER;
        l_source_transaction_id      NUMBER;
        l_transaction_id             NUMBER; /* Added for bug 9657044 */

    BEGIN
        IF g_debug = 1 THEN
            debug('In INV_3PL_BILLING_COUNTER_PVT.inv_insert_readings_using_api ');
        END IF;

        l_transaction_tbl(l_c_ind_txn) := NULL;


        SELECT cii.instance_id reference_number
        INTO l_source_transaction_id
        FROM    okx_system_items_v       it,
                csi_item_instances       cii,
                cs_csi_counter_groups    cg,
                csi_counter_associations cca,
                csi_counters_b           ct,
                csi_counter_readings cv
        WHERE it.id1 = cii.inventory_item_id
        AND it.organization_id = okc_context.get_okc_organization_id
        AND cca.source_object_id = cii.instance_id
        AND cca.source_object_code = 'CP'
        AND ct.counter_id = cca.counter_id
        AND ct.group_id = cg.counter_group_id
        AND cv.counter_id (+) = ct.counter_id
        AND cv.counter_value_id (+) = oks_auth_util_pvt.get_net_reading(ct.counter_id)
        AND ct.counter_id = p_counter_id;

        IF g_debug = 1 THEN
            debug('Got item instance number for counter -> '||l_source_transaction_id);
        END IF;

        l_transaction_type_id := 80;
        /* Added for bug 9657044 */
        SELECT csi_transactions_s.NEXTVAL
        INTO l_transaction_id
        FROM dual;

        -- ------ Starting  Building Readings tables --------------

        l_transaction_tbl(l_c_ind_txn).TRANSACTION_ID                 := NULL;
        l_transaction_tbl(l_c_ind_txn).TRANSACTION_DATE               := SYSDATE;
        l_transaction_tbl(l_c_ind_txn).SOURCE_TRANSACTION_DATE        := SYSDATE;
        l_transaction_tbl(l_c_ind_txn).TRANSACTION_TYPE_ID            := l_transaction_type_id;
        l_transaction_tbl(l_c_ind_txn).TXN_SUB_TYPE_ID                := NULL;
        l_transaction_tbl(l_c_ind_txn).SOURCE_GROUP_REF_ID            := NULL;
        l_transaction_tbl(l_c_ind_txn).SOURCE_GROUP_REF               := NULL;
        l_transaction_tbl(l_c_ind_txn).SOURCE_HEADER_REF_ID           := l_source_transaction_id;
        l_transaction_tbl(l_c_ind_txn).SOURCE_HEADER_REF              := NULL;
        l_transaction_tbl(l_c_ind_txn).SOURCE_LINE_REF_ID             := NULL;
        l_transaction_tbl(l_c_ind_txn).SOURCE_LINE_REF                := NULL;
        l_transaction_tbl(l_c_ind_txn).SOURCE_DIST_REF_ID1            := NULL;
        l_transaction_tbl(l_c_ind_txn).SOURCE_DIST_REF_ID2            := NULL;
        l_transaction_tbl(l_c_ind_txn).INV_MATERIAL_TRANSACTION_ID    := NULL;
        l_transaction_tbl(l_c_ind_txn).TRANSACTION_QUANTITY           := NULL;
        l_transaction_tbl(l_c_ind_txn).TRANSACTION_UOM_CODE           := NULL;
        l_transaction_tbl(l_c_ind_txn).TRANSACTED_BY                  := NULL;
        l_transaction_tbl(l_c_ind_txn).TRANSACTION_STATUS_CODE        := NULL;
        l_transaction_tbl(l_c_ind_txn).TRANSACTION_ACTION_CODE        := NULL;
        l_transaction_tbl(l_c_ind_txn).MESSAGE_ID                     := NULL;
        l_transaction_tbl(l_c_ind_txn).CONTEXT                        := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE1                     := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE2                     := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE3                     := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE4                     := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE5                     := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE6                     := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE7                     := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE8                     := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE9                     := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE10                    := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE11                    := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE12                    := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE13                    := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE14                    := NULL;
        l_transaction_tbl(l_c_ind_txn).ATTRIBUTE15                    := NULL;
        l_transaction_tbl(l_c_ind_txn).OBJECT_VERSION_NUMBER          := NULL;
        l_transaction_tbl(l_c_ind_txn).SPLIT_REASON_CODE              := NULL;
        l_transaction_tbl(l_c_ind_txn).SRC_TXN_CREATION_DATE          := NULL;

        IF g_debug = 1 THEN
            debug('After L_TRANSACTION_TBL ');
        END IF;

        l_counter_readings_tbl(l_c_ind_rdg).COUNTER_VALUE_ID         :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).COUNTER_ID               :=  p_counter_id;
        l_counter_readings_tbl(l_c_ind_rdg).VALUE_TIMESTAMP          :=  p_count_date;
        l_counter_readings_tbl(l_c_ind_rdg).COUNTER_READING          :=  p_new_reading;
        l_counter_readings_tbl(l_c_ind_rdg).RESET_MODE               :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).RESET_REASON             :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ADJUSTMENT_TYPE          :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ADJUSTMENT_READING       :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).OBJECT_VERSION_NUMBER    :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).LAST_UPDATE_DATE         :=  SYSDATE;
        l_counter_readings_tbl(l_c_ind_rdg).LAST_UPDATED_BY          :=  fnd_global.user_id;
        l_counter_readings_tbl(l_c_ind_rdg).CREATION_DATE            :=  SYSDATE;
        l_counter_readings_tbl(l_c_ind_rdg).CREATED_BY               :=  fnd_global.user_id;
        l_counter_readings_tbl(l_c_ind_rdg).LAST_UPDATE_LOGIN        :=  fnd_global.login_id;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE1               :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE2               :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE3               :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE4               :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE5               :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE6               :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE7               :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE8               :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE9               :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE10              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE11              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE12              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE13              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE14              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE15              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE16              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE17              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE18              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE19              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE20              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE21              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE22              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE23              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE24              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE25              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE26              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE27              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE28              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE29              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE30              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).ATTRIBUTE_CATEGORY       :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).MIGRATED_FLAG            :=  'N';
        l_counter_readings_tbl(l_c_ind_rdg).COMMENTS                 :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).LIFE_TO_DATE_READING     :=  NULL;
        /* Added l_transaction_id for bug 9657044 */
        l_counter_readings_tbl(l_c_ind_rdg).TRANSACTION_ID           :=  l_transaction_id;
        l_counter_readings_tbl(l_c_ind_rdg).AUTOMATIC_ROLLOVER_FLAG  :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).INCLUDE_TARGET_RESETS    :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).SOURCE_COUNTER_VALUE_ID  :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).NET_READING              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).DISABLED_FLAG            :=  'N';
        l_counter_readings_tbl(l_c_ind_rdg).SOURCE_CODE              :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).SOURCE_LINE_ID           :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).SECURITY_GROUP_ID        :=  NULL;
        l_counter_readings_tbl(l_c_ind_rdg).PARENT_TBL_INDEX         :=  l_c_ind_txn;


        IF g_debug = 1 THEN
            debug('After L_COUNTER_READINGS_TBL ');
        END IF;

        l_ctr_property_readings_tbl(l_c_ind_prop).COUNTER_PROP_VALUE_ID    := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).COUNTER_VALUE_ID         := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).COUNTER_PROPERTY_ID      := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).PROPERTY_VALUE           := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).VALUE_TIMESTAMP          := SYSDATE;
        l_ctr_property_readings_tbl(l_c_ind_prop).OBJECT_VERSION_NUMBER    := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).LAST_UPDATE_DATE         := SYSDATE;
        l_ctr_property_readings_tbl(l_c_ind_prop).LAST_UPDATED_BY          := fnd_global.user_id;
        l_ctr_property_readings_tbl(l_c_ind_prop).CREATION_DATE            := SYSDATE;
        l_ctr_property_readings_tbl(l_c_ind_prop).CREATED_BY               := fnd_global.user_id;
        l_ctr_property_readings_tbl(l_c_ind_prop).LAST_UPDATE_LOGIN        := fnd_global.login_id;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE1               := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE2               := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE3               := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE4               := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE5               := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE6               := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE7               := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE8               := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE9               := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE10              := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE11              := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE12              := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE13              := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE14              := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE15              := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).ATTRIBUTE_CATEGORY       := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).MIGRATED_FLAG            := 'N';
        l_ctr_property_readings_tbl(l_c_ind_prop).SECURITY_GROUP_ID        := NULL;
        l_ctr_property_readings_tbl(l_c_ind_prop).PARENT_TBL_INDEX         := NULL;

        IF g_debug = 1 THEN
            debug('After L_CTR_PROPERTY_READINGS_TBL ');
        END IF;

        csi_counter_readings_pub.capture_counter_reading(
            p_api_version           => 1.0,
            p_commit                => 'F',
            p_init_msg_list         => 'T',
            p_validation_level      => 10,
            p_txn_tbl               => l_transaction_tbl,
            p_ctr_rdg_tbl           => l_counter_readings_tbl,
            p_ctr_prop_rdg_tbl      => l_ctr_property_readings_tbl,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data
        );

        -- If API returns error, display the error message
        -- otherwise commit the transaction.

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF g_debug = 1 THEN
                debug('Error from IB api');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
            COMMIT;
            IF g_debug = 1 THEN
                debug('Reading updated in IB counter table');
            END IF;
        END IF;

        EXCEPTION
            WHEN OTHERS THEN
                RAISE;
    END inv_insert_readings_using_api;

END INV_3PL_BILLING_COUNTER_PVT;

/
