--------------------------------------------------------
--  DDL for Package CSD_REPAIR_ESTIMATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_ESTIMATE_PVT" AUTHID CURRENT_USER AS
    /* $Header: csdvests.pls 120.9 2008/05/14 01:13:18 swai ship $ */

    /*--------------------------------------------------*/
    /* Record name: REPAIR_ESTIMATE_REC                 */
    /* description : Record used for repair estimate rec*/
    /*                                                  */
    /*--------------------------------------------------*/

    TYPE REPAIR_ESTIMATE_REC IS RECORD(
        repair_estimate_id    NUMBER := Fnd_Api.G_MISS_NUM,
        repair_line_id        NUMBER := Fnd_Api.G_MISS_NUM,
        note_id               NUMBER := Fnd_Api.G_MISS_NUM,
        estimate_date         DATE := Fnd_Api.G_MISS_DATE,
        estimate_status       VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        lead_time             NUMBER := Fnd_Api.G_MISS_NUM,
        lead_time_uom         VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        estimate_freeze_flag  VARCHAR2(1) := Fnd_Api.G_MISS_CHAR,
        work_summary          VARCHAR2(240) := Fnd_Api.G_MISS_CHAR,
        po_number             VARCHAR2(50) := Fnd_Api.G_MISS_CHAR,
        estimate_reason_code  VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        not_to_exceed         NUMBER := Fnd_Api.G_MISS_NUM,  -- R12 Bug#5334454
        last_update_date      DATE := Fnd_Api.G_MISS_DATE,
        creation_date         DATE := Fnd_Api.G_MISS_DATE,
        last_updated_by       NUMBER := Fnd_Api.G_MISS_NUM,
        created_by            NUMBER := Fnd_Api.G_MISS_NUM,
        last_update_login     NUMBER := Fnd_Api.G_MISS_NUM,
        attribute1            VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute2            VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute3            VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute4            VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute5            VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute6            VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute7            VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute8            VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute9            VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute10           VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute11           VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute12           VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute13           VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute14           VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute15           VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        context               VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        object_version_number NUMBER := Fnd_Api.G_MISS_NUM,
        security_group_id     NUMBER := Fnd_Api.G_MISS_NUM

        );

    /*--------------------------------------------------*/
    /* Record name: REPAIR_ESTIMATE_LINE_REC            */
    /* description : Record used for repair estimate rec*/
    /*                                                  */
    /*--------------------------------------------------*/

    -- added contract_number to the record
    -- added charge_line_type and apply_contract_discount to the record
    -- travi forward port of Bug # 2789754 fix added override_charge_flag
    -- to the record

    TYPE REPAIR_ESTIMATE_LINE_REC IS RECORD(
        repair_estimate_line_id NUMBER := Fnd_Api.G_MISS_NUM,
        repair_estimate_id      NUMBER := Fnd_Api.G_MISS_NUM,
        repair_line_id          NUMBER := Fnd_Api.G_MISS_NUM,
        estimate_detail_id      NUMBER := Fnd_Api.G_MISS_NUM,
        incident_id             NUMBER := Fnd_Api.G_MISS_NUM,
        transaction_type_id     NUMBER := Fnd_Api.G_MISS_NUM,
        business_process_id     NUMBER := Fnd_Api.G_MISS_NUM,
        txn_billing_type_id     NUMBER := Fnd_Api.G_MISS_NUM,
        original_source_id      NUMBER := Fnd_Api.G_MISS_NUM,
        original_source_code    VARCHAR2(10) := Fnd_Api.G_MISS_CHAR,
        source_id               NUMBER := Fnd_Api.G_MISS_NUM,
        source_code             VARCHAR2(10) := Fnd_Api.G_MISS_CHAR,
        line_type_id            NUMBER := Fnd_Api.G_MISS_NUM,
        item_cost               NUMBER := Fnd_Api.G_MISS_NUM,
        resource_id             NUMBER := Fnd_Api.G_MISS_NUM,
        customer_product_id     NUMBER := Fnd_Api.G_MISS_NUM,
        reference_number        NUMBER := Fnd_Api.G_MISS_NUM,
        item_revision           VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        justification_notes     VARCHAR2(240) := Fnd_Api.G_MISS_CHAR,
        estimate_status         VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        order_number            VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        -- purchase_order_num         VARCHAR2(30)    := FND_API.G_MISS_CHAR,
        -- Above line replaced by line below. bugfix 3485965. vkjain
        purchase_order_num        VARCHAR2(50) := Fnd_Api.G_MISS_CHAR,
        source_number             VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        status                    VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        currency_code             VARCHAR2(15) := Fnd_Api.G_MISS_CHAR,
        line_category_code        VARCHAR2(6) := Fnd_Api.G_MISS_CHAR,
        unit_of_measure_code      VARCHAR2(3) := Fnd_Api.G_MISS_CHAR,
        original_source_number    VARCHAR2(3) := Fnd_Api.G_MISS_CHAR,
        add_to_order_flag         VARCHAR2(1) := Fnd_Api.G_MISS_CHAR,
        order_header_id           NUMBER := Fnd_Api.G_MISS_NUM,
        order_line_id             NUMBER := Fnd_Api.G_MISS_NUM,
        inventory_item_id         NUMBER := Fnd_Api.G_MISS_NUM,
        after_warranty_cost       NUMBER := Fnd_Api.G_MISS_NUM,
        selling_price             NUMBER := Fnd_Api.G_MISS_NUM,
        original_system_reference VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        estimate_quantity         NUMBER := Fnd_Api.G_MISS_NUM,
        serial_number             VARCHAR2(50) := Fnd_Api.G_MISS_CHAR,
        lot_number                VARCHAR2(80) := Fnd_Api.G_MISS_CHAR, -- fix for bug#4625226
        instance_id               NUMBER := Fnd_Api.G_MISS_NUM,
        instance_number           NUMBER := Fnd_Api.G_MISS_NUM,
        price_list_id             NUMBER := Fnd_Api.G_MISS_NUM,
        contract_id               NUMBER := Fnd_Api.G_MISS_NUM,
        contract_number           VARCHAR2(120) := Fnd_Api.G_MISS_CHAR,
        coverage_bill_rate_id     NUMBER := Fnd_Api.G_MISS_NUM,
        sub_inventory             VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        organization_id           NUMBER := Fnd_Api.G_MISS_NUM,
        invoice_to_org_id         NUMBER := Fnd_Api.G_MISS_NUM,
        ship_to_org_id            NUMBER := Fnd_Api.G_MISS_NUM,
        no_charge_flag            VARCHAR2(1) := Fnd_Api.G_MISS_CHAR,
        override_charge_flag      VARCHAR2(1) := Fnd_Api.G_MISS_CHAR,
        interface_to_om_flag      VARCHAR2(1) := Fnd_Api.G_MISS_CHAR,
        return_reason             VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        return_by_date            DATE := Fnd_Api.G_MISS_DATE,
        last_update_date          DATE := Fnd_Api.G_MISS_DATE,
        creation_date             DATE := Fnd_Api.G_MISS_DATE,
        last_updated_by           NUMBER := Fnd_Api.G_MISS_NUM,
        created_by                NUMBER := Fnd_Api.G_MISS_NUM,
        last_update_login         NUMBER := Fnd_Api.G_MISS_NUM,
        attribute1                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute2                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute3                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute4                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute5                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute6                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute7                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute8                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute9                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute10               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute11               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute12               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute13               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute14               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        attribute15               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        context                   VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        object_version_number     NUMBER := Fnd_Api.G_MISS_NUM,
        security_group_id         NUMBER := Fnd_Api.G_MISS_NUM,
        charge_line_type          VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        apply_contract_discount   VARCHAR2(1) := Fnd_Api.G_MISS_CHAR,
        coverage_id               NUMBER := Fnd_Api.G_MISS_NUM,
        coverage_txn_group_id     NUMBER := Fnd_Api.G_MISS_NUM,
        -- swai bug fix 3099740
        -- add contract discount amount to pass to charges
        contract_discount_amount NUMBER := Fnd_Api.G_MISS_NUM,
        -- end swai bug fix 3099740

        --
        -- swai 11.5.10
        -- new fields
        --
        EST_LINE_SOURCE_TYPE_CODE VARCHAR2(30),
        EST_LINE_SOURCE_ID1       NUMBER,
        EST_LINE_SOURCE_ID2       NUMBER,
        RO_SERVICE_CODE_ID        NUMBER,
        --
        -- end swai 11.5.10 new fields
        --
        pricing_context      VARCHAR2(30) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute1   VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute2   VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute3   VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute4   VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute5   VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute6   VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute7   VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute8   VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute9   VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute10  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute11  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute12  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute13  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute14  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute15  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute16  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute17  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute18  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute19  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute20  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute21  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute22  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute23  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute24  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute25  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute26  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute27  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute28  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute29  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute30  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute31  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute32  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute33  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute34  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute35  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute36  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute37  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute38  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute39  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute40  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute41  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute42  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute43  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute44  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute45  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute46  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute47  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute48  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute49  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute50  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute51  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute52  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute53  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute54  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute55  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute56  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute57  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute58  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute59  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute60  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute61  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute62  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute63  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute64  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute65  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute66  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute67  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute68  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute69  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute70  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute71  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute72  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute73  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute74  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute75  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute76  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute77  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute78  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute79  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute80  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute81  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute82  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute83  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute84  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute85  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute86  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute87  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute88  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute89  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute90  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute91  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute92  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute93  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute94  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute95  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute96  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute97  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute98  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute99  VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
        pricing_attribute100 VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,

	   -- R12 new fields, added for contract re arch changes.
	   contract_line_id     NUMBER,
	   rate_type_code  VARCHAR2(40) -- this is added because charges table has a new column, may not be used currently.

        );

    TYPE REPAIR_ESTIMATE_LINE_TBL IS TABLE OF REPAIR_ESTIMATE_LINE_REC INDEX BY BINARY_INTEGER;

    --
    -- swai 11.5.10
    --
    /*--------------------------------------------------*/
    /* Record name: MLE_LINES_REC_TYPE                  */
    /* description : Record used for mle lines          */
    /*                                                  */
    /*--------------------------------------------------*/

    TYPE MLE_LINES_REC_TYPE IS RECORD(
        INVENTORY_ITEM_ID         NUMBER,
        UOM                       VARCHAR2(3),
        QUANTITY                  NUMBER,
        SELLING_PRICE             NUMBER,
        ITEM_NAME                 VARCHAR2(100),
        COMMS_NL_TRACKABLE_FLAG   VARCHAR2(1),
        TXN_BILLING_TYPE_ID       NUMBER,
        EST_LINE_SOURCE_TYPE_CODE VARCHAR2(30),
        EST_LINE_SOURCE_ID1       NUMBER,
        EST_LINE_SOURCE_ID2       NUMBER,
        RO_SERVICE_CODE_ID        NUMBER,
        RESOURCE_ID               NUMBER -- vkjain. fix 3449978
        );
    TYPE MLE_LINES_TBL_TYPE IS TABLE OF MLE_LINES_REC_TYPE INDEX BY BINARY_INTEGER;

    --
    -- end swai 11.5.10
    --

    /*--------------------------------------------------*/
    /* swai: 12.1 Service costing (bug 6960295)         */
    /* procedure name: process_estimate_lines           */
    /* description   : procedure used to create/update  */
    /*                 delete charge lines. This        */
    /*                 procedure allows the overriding  */
    /*                 of the create/update/delete cost */
    /*                 flag introduced in the Charges   */
    /*                 API for 12.1 release             */
    /*--------------------------------------------------*/

    PROCEDURE PROCESS_ESTIMATE_LINES(p_api_version      IN NUMBER,
                                     p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                     p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                     p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                     p_action           IN VARCHAR2,
                                     p_cs_cost_flag     IN VARCHAR2 := 'Y',
                                     x_Charges_Rec      IN OUT NOCOPY Cs_Charge_Details_Pub.Charges_Rec_Type,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: update_ro_group_estimate         */
    /* description   : procedure used to update         */
    /*                 repair group for estimate changes*/
    /*--------------------------------------------------*/
    PROCEDURE UPDATE_RO_GROUP_ESTIMATE(p_api_version           IN NUMBER,
                                       p_commit                IN VARCHAR2 := Fnd_Api.g_false,
                                       p_init_msg_list         IN VARCHAR2 := Fnd_Api.g_false,
                                       p_validation_level      IN NUMBER := Fnd_Api.g_valid_level_full,
                                       p_repair_line_id        IN NUMBER,
                                       x_object_version_number OUT NOCOPY NUMBER,
                                       x_return_status         OUT NOCOPY VARCHAR2,
                                       x_msg_count             OUT NOCOPY NUMBER,
                                       x_msg_data              OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: create_repair_estimate           */
    /* description   : procedure used to create         */
    /*                 repair estimate header           */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE CREATE_REPAIR_ESTIMATE(p_api_version      IN NUMBER,
                                     p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                     p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                     p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                     x_estimate_rec     IN OUT NOCOPY REPAIR_ESTIMATE_REC,
                                     x_estimate_id      OUT NOCOPY NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: update_repair_estimate           */
    /* description   : procedure used to update         */
    /*                 repair estimate header           */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE UPDATE_REPAIR_ESTIMATE(p_api_version      IN NUMBER,
                                     p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                     p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                     p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                     x_estimate_rec     IN OUT NOCOPY REPAIR_ESTIMATE_REC,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: delete_repair_estimate           */
    /* description   : procedure used to delete         */
    /*                 repair estimate lines            */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE DELETE_REPAIR_ESTIMATE(p_api_version      IN NUMBER,
                                     p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                     p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                     p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                     p_estimate_id      IN NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: lock_repair_estimate             */
    /* description   : procedure used to lock           */
    /*                 repair estimate lines            */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE LOCK_REPAIR_ESTIMATE(p_api_version      IN NUMBER,
                                   p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                   p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                   p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                   p_estimate_rec     IN REPAIR_ESTIMATE_REC,
                                   x_return_status    OUT NOCOPY VARCHAR2,
                                   x_msg_count        OUT NOCOPY NUMBER,
                                   x_msg_data         OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: create_repair_estimate_lines     */
    /* description   : procedure used to create         */
    /*                 repair estimate lines            */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE CREATE_REPAIR_ESTIMATE_LINES(p_api_version       IN NUMBER,
                                           p_commit            IN VARCHAR2 := Fnd_Api.g_false,
                                           p_init_msg_list     IN VARCHAR2 := Fnd_Api.g_false,
                                           p_validation_level  IN NUMBER := Fnd_Api.g_valid_level_full,
                                           x_estimate_line_rec IN OUT NOCOPY CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_REC,
                                           x_estimate_line_id  OUT NOCOPY NUMBER,
                                           x_return_status     OUT NOCOPY VARCHAR2,
                                           x_msg_count         OUT NOCOPY NUMBER,
                                           x_msg_data          OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: update_repair_estimate_lines     */
    /* description   : procedure used to update         */
    /*                 repair estimate lines            */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE UPDATE_REPAIR_ESTIMATE_LINES(p_api_version       IN NUMBER,
                                           p_commit            IN VARCHAR2 := Fnd_Api.g_false,
                                           p_init_msg_list     IN VARCHAR2 := Fnd_Api.g_false,
                                           p_validation_level  IN NUMBER := Fnd_Api.g_valid_level_full,
                                           x_estimate_line_rec IN OUT NOCOPY CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_REC,
                                           x_return_status     OUT NOCOPY VARCHAR2,
                                           x_msg_count         OUT NOCOPY NUMBER,
                                           x_msg_data          OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: delete_repair_estimate_lines     */
    /* description   : procedure used to delete         */
    /*                 repair estimate lines            */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE DELETE_REPAIR_ESTIMATE_LINES(p_api_version      IN NUMBER,
                                           p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                           p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                           p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                           p_estimate_line_id IN NUMBER,
                                           x_return_status    OUT NOCOPY VARCHAR2,
                                           x_msg_count        OUT NOCOPY NUMBER,
                                           x_msg_data         OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: lock_repair_estimate_lines       */
    /* description   : procedure used to lock           */
    /*                 repair estimate lines            */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE LOCK_REPAIR_ESTIMATE_LINES(p_api_version       IN NUMBER,
                                         p_commit            IN VARCHAR2 := Fnd_Api.g_false,
                                         p_init_msg_list     IN VARCHAR2 := Fnd_Api.g_false,
                                         p_validation_level  IN NUMBER := Fnd_Api.g_valid_level_full,
                                         p_estimate_line_rec IN REPAIR_ESTIMATE_LINE_REC,
                                         x_return_status     OUT NOCOPY VARCHAR2,
                                         x_msg_count         OUT NOCOPY NUMBER,
                                         x_msg_data          OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: repair_estimate_print            */
    /* description   : procedure used to submit         */
    /*               repair estimate concurrent program */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE REPAIR_ESTIMATE_PRINT(p_api_version      IN NUMBER,
                                    p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                    p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                    p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                    p_repair_line_id   IN NUMBER,
                                    x_request_id       OUT NOCOPY NUMBER,
                                    x_return_status    OUT NOCOPY VARCHAR2,
                                    x_msg_count        OUT NOCOPY NUMBER,
                                    x_msg_data         OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: submit_estimate_lines            */
    /* description   : procedure used to submit         */
    /*               repair estimate lines              */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE SUBMIT_REPAIR_ESTIMATE_LINES(p_api_version      IN NUMBER,
                                           p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                           p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                           p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                           p_repair_line_id   IN NUMBER,
                                           x_return_status    OUT NOCOPY VARCHAR2,
                                           x_msg_count        OUT NOCOPY NUMBER,
                                           x_msg_data         OUT NOCOPY VARCHAR2);

    --
    -- swai 11.5.10
    --
    /*--------------------------------------------------*/
    /* procedure name:  Get_total_estimated_charge      */
    /* description   :  given a repair line id, returns */
    /*                  the total estimated charge  --  */
    /*                  total of MLE charges on estimate*/
    /*                  lines.  If no estimate lines for*/
    /*                  the repair line, return error   */
    /*                  status and null charge          */
    /*--------------------------------------------------*/
    PROCEDURE get_total_estimated_charge(p_repair_line_id   IN NUMBER,
                                         x_estimated_charge OUT NOCOPY NUMBER,
                                         x_return_status    OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: Autocreate_Estimate_Lines        */
    /* description   : The main procedure that is       */
    /*                 triggered by the click of the    */
    /*                 button on the `Estimates' tab.   */
    /*                 Creates all the estimate lines   */
    /*                 for TASK or BOM.                 */
    /* x_warning_flag : FND_API.G_TRUE if any non-fatal */
    /*                  errors occured. FND_API.G_FALSE */
    /*                  if everything was successful.   */
    /*                  Note that this value could be   */
    /*                  G_TRUE even if x_return_status  */
    /*                  is G_RET_STS_SUCCESS            */
    /* called from:  Depot Repair UI                    */
    /*--------------------------------------------------*/
    PROCEDURE Autocreate_Estimate_Lines(p_api_version         IN NUMBER,
                                        p_commit              IN VARCHAR2 := Fnd_Api.g_false,
                                        p_init_msg_list       IN VARCHAR2 := Fnd_Api.g_false,
                                        p_validation_level    IN NUMBER := Fnd_Api.g_valid_level_full,
                                        x_return_status       OUT NOCOPY VARCHAR2,
                                        x_msg_count           OUT NOCOPY NUMBER,
                                        x_msg_data            OUT NOCOPY VARCHAR2,
                                        p_repair_line_id      IN NUMBER,
                                        p_estimate_id         IN NUMBER,
                                        p_repair_type_id      IN NUMBER,
                                        p_business_process_id IN NUMBER,
                                        p_currency_code       IN VARCHAR2,
                                        p_incident_id         IN NUMBER,
                                        p_repair_mode         IN VARCHAR2,
                                        p_inventory_item_id   IN NUMBER,
                                        p_organization_id     IN NUMBER,
                                        x_warning_flag        OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: Get_Estimates_From_Task          */
    /* description   : Fetches ML lines for the tasks   */
    /*                 associated via Service Codes and */
    /*                 (optionally) Solution.           */
    /* x_warning_flag : FND_API.G_TRUE if any non-fatal */
    /*                  errors occured. FND_API.G_FALSE */
    /*                  if everything was successful.   */
    /*                  Note that this value could be   */
    /*                  G_TRUE even if x_return_status  */
    /*                  is G_RET_STS_SUCCESS            */
    /* called from:  Autocreate_Estimate_Lines          */
    /*--------------------------------------------------*/
    PROCEDURE Get_Estimates_From_Task(p_api_version         IN NUMBER,
                                      p_commit              IN VARCHAR2,
                                      p_init_msg_list       IN VARCHAR2,
                                      p_validation_level    IN NUMBER,
                                      x_return_status       OUT NOCOPY VARCHAR2,
                                      x_msg_count           OUT NOCOPY NUMBER,
                                      x_msg_data            OUT NOCOPY VARCHAR2,
                                      p_repair_line_id      IN NUMBER,
                                      p_estimate_id         IN NUMBER,
                                      p_repair_type_id      IN NUMBER,
                                      p_business_process_id IN NUMBER,
                                      p_currency_code       IN VARCHAR2,
                                      p_incident_id         IN NUMBER,
                                      p_repair_mode         IN VARCHAR2,
                                      p_inventory_item_id   IN NUMBER,
                                      p_organization_id     IN NUMBER,
                                      p_price_list_id       IN NUMBER,
                                      p_contract_line_id    IN NUMBER,
                                      x_est_lines_tbl       OUT NOCOPY CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_TBL,
                                      x_warning_flag        OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: Get_Estimates_From_BOM           */
    /* description   : Fetches ML lines for the         */
    /*                 BOM/Route references associated  */
    /*                 via Service Codes.               */
    /* x_warning_flag : FND_API.G_TRUE if any non-fatal */
    /*                  errors occured. FND_API.G_FALSE */
    /*                  if everything was successful.   */
    /*                  Note that this value could be   */
    /*                  G_TRUE even if x_return_status  */
    /*                  is G_RET_STS_SUCCESS            */
    /* called from:  Autocreate_Estimate_Lines          */
    /*--------------------------------------------------*/
    PROCEDURE Get_Estimates_From_BOM(p_api_version         IN NUMBER,
                                     p_commit              IN VARCHAR2,
                                     p_init_msg_list       IN VARCHAR2,
                                     p_validation_level    IN NUMBER,
                                     x_return_status       OUT NOCOPY VARCHAR2,
                                     x_msg_count           OUT NOCOPY NUMBER,
                                     x_msg_data            OUT NOCOPY VARCHAR2,
                                     p_repair_line_id      IN NUMBER,
                                     p_estimate_id         IN NUMBER,
                                     p_repair_type_id      IN NUMBER,
                                     p_business_process_id IN NUMBER,
                                     p_currency_code       IN VARCHAR2,
                                     p_incident_id         IN NUMBER,
                                     p_repair_mode         IN VARCHAR2,
                                     p_inventory_item_id   IN NUMBER,
                                     p_organization_id     IN NUMBER,
                                     p_price_list_id       IN NUMBER,
                                     p_contract_line_id    IN NUMBER,
                                     x_est_lines_tbl       OUT NOCOPY CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_TBL,
                                     x_warning_flag        OUT NOCOPY VARCHAR2);

    /*--------------------------------------------------*/
    /* procedure name: Convert_To_Est_Lines             */
    /* description   : The procedure to manipulate      */
    /*                 different structures. It converts*/
    /*                 data from MLE_LINES_REC_TYPE to  */
    /*                 REPAIR_ESTIMATE_LINE_REC. It also*/
    /*                 sets the item cost and logs      */
    /*                 warnings.                        */
    /* x_warning_flag : FND_API.G_TRUE if any non-fatal */
    /*                  errors occured. FND_API.G_FALSE */
    /*                  if everything was successful.   */
    /*                  Note that this value could be   */
    /*                  G_TRUE even if x_return_status  */
    /*                  is G_RET_STS_SUCCESS            */
    /* called from:  Get_Estimates_From_BOM             */
    /*               Get_Estimates_From_Task            */
    /*--------------------------------------------------*/
    PROCEDURE Convert_To_Est_Lines(p_api_version         IN NUMBER,
                                   p_commit              IN VARCHAR2,
                                   p_init_msg_list       IN VARCHAR2,
                                   p_validation_level    IN NUMBER,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   x_msg_count           OUT NOCOPY NUMBER,
                                   x_msg_data            OUT NOCOPY VARCHAR2,
                                   p_repair_line_id      IN NUMBER,
                                   p_estimate_id         IN NUMBER,
                                   p_repair_type_id      IN NUMBER,
                                   p_business_process_id IN NUMBER,
                                   p_currency_code       IN VARCHAR2,
                                   p_incident_id         IN NUMBER,
                                   p_organization_id     IN NUMBER,
                                   p_price_list_id       IN NUMBER,
                                   p_contract_line_id    IN NUMBER,
                                   p_MLE_lines_tbl       IN MLE_LINES_TBL_TYPE,
                                   x_est_lines_tbl       IN OUT NOCOPY REPAIR_ESTIMATE_LINE_TBL,
                                   x_warning_flag        OUT NOCOPY VARCHAR2);
    --
    -- end swai 11.5.10
    --

    ----Begin change for 3931317, wrpper aPI forward port

    /*----------------------------------------------------------------------------*/
    /* procedure name: CREATE_ESTIMATE_HEADER                                     */
    /* description   : Wrapper procedure used to create estimate header           */
    /*   Updates repair order estimate approved flag and creates Depot estimate   */
    /*   header record with information like, summary, lead time etc              */
    /*  Change History  : Created 7th Dec 2004 by Vijay                          */
    /*            20-June-2005: Vijay: Modified the name from CREATE_EST_WRAPR   */
    /*----------------------------------------------------------------------------*/
    PROCEDURE CREATE_ESTIMATE_HEADER(p_api_version      IN NUMBER,
                                     p_init_msg_list    IN VARCHAR2,
                                     p_commit           IN VARCHAR2,
                                     p_validation_level IN NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_estimate_hdr_rec IN Csd_Repair_Estimate_Pub.ESTIMATE_HDR_REC,
                                     x_estimate_hdr_id  OUT NOCOPY NUMBER);

    /*----------------------------------------------------------------------------*/
    /* procedure name: UPDATE_ESTIMATE_HEADER                                     */
    /* description   : procedure used to update estimate header                  */
    /*   Updates repair order estimate approved flag and creates Depot estimate   */
    /*   header record with information like, summary, lead time etc              */
    /*  Change History  : Created 24-June-2005 by Vijay                          */
    /*----------------------------------------------------------------------------*/
    PROCEDURE UPDATE_ESTIMATE_HEADER(p_api_version           IN NUMBER,
                                     p_init_msg_list         IN VARCHAR2,
                                     p_commit                IN VARCHAR2,
                                     p_validation_level      IN NUMBER,
                                     x_return_status         OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2,
                                     p_estimate_hdr_rec      IN Csd_Repair_Estimate_Pub.ESTIMATE_HDR_REC,
                                     x_object_version_number OUT NOCOPY NUMBER);

    /*----------------------------------------------------------------------------*/
    /* procedure name: CREATE_ESTIMATE_LINE                                       */
    /* description   : Wrapper procedure used to create estimate line             */
    /*   Creates Depot estimate line record and submits                           */
    /*   based on some validations.                                               */
    /*  Change History  : Created 7th Dec 2004 by Vijay                           */
    /*        20-June-2005: Vijay: Modified the name from CREATE_EST_LINE_WRAPR   */
    /*----------------------------------------------------------------------------*/

    PROCEDURE CREATE_ESTIMATE_LINE(p_api_version       IN NUMBER,
                                   p_init_msg_list     IN VARCHAR2,
                                   p_commit            IN VARCHAR2,
                                   p_validation_level  IN NUMBER,
                                   x_return_status     OUT NOCOPY VARCHAR2,
                                   x_msg_count         OUT NOCOPY NUMBER,
                                   x_msg_data          OUT NOCOPY VARCHAR2,
                                   p_estimate_line_rec IN Csd_Repair_Estimate_Pub.ESTIMATE_LINE_REC,
                                   x_estimate_line_id  OUT NOCOPY NUMBER);

    /*----------------------------------------------------------------------------*/
    /* procedure name: UPDATE_ESTIMATE_LINE                                       */
    /* description   :  procedure used to update  estimate line                  */
    /*   Updates Depot estimate line record and submits                           */
    /*   based on some validations.                                               */
    /*  Change History  : Created 24-June-2005 by Vijay                           */
    /*----------------------------------------------------------------------------*/

    PROCEDURE UPDATE_ESTIMATE_LINE(p_api_version           IN NUMBER,
                                   p_init_msg_list         IN VARCHAR2,
                                   p_commit                IN VARCHAR2,
                                   p_validation_level      IN NUMBER,
                                   x_return_status         OUT NOCOPY VARCHAR2,
                                   x_msg_count             OUT NOCOPY NUMBER,
                                   x_msg_data              OUT NOCOPY VARCHAR2,
                                   p_estimate_line_rec     IN Csd_Repair_Estimate_Pub.ESTIMATE_LINE_REC,
                                   x_object_version_number OUT NOCOPY NUMBER);

END Csd_Repair_Estimate_Pvt;

/
