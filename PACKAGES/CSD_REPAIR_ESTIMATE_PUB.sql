--------------------------------------------------------
--  DDL for Package CSD_REPAIR_ESTIMATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_ESTIMATE_PUB" AUTHID CURRENT_USER AS
    /* $Header: csdpests.pls 120.4.12010000.2 2010/03/17 21:05:47 swai ship $ */
    /*#
--    * This is the public interface for managing a repair estimate. It allows
--    * creation  of repair estimate for a repair order.
    */

    /*--------------------------------------------------*/
    /* Record name: ESTIMATE_HDR_REC_TYPE               */
    /* description : Record used for repair estimate rec*/
    /*                                                  */
    /*--------------------------------------------------*/

    TYPE ESTIMATE_HDR_REC IS RECORD(
        repair_estimate_id    NUMBER,
        repair_line_id        NUMBER,
        note_id               NUMBER,
        estimate_date         DATE,
        estimate_status       VARCHAR2(30),
        lead_time             NUMBER,
        lead_time_uom         VARCHAR2(30),
        estimate_freeze_flag  VARCHAR2(1),
        work_summary          VARCHAR2(240),
        po_number             VARCHAR2(50),
        estimate_reason_code  VARCHAR2(30),
        last_update_date      DATE,
        creation_date         DATE,
        last_updated_by       NUMBER,
        created_by            NUMBER,
        last_update_login     NUMBER,
        attribute1            VARCHAR2(150),
        attribute2            VARCHAR2(150),
        attribute3            VARCHAR2(150),
        attribute4            VARCHAR2(150),
        attribute5            VARCHAR2(150),
        attribute6            VARCHAR2(150),
        attribute7            VARCHAR2(150),
        attribute8            VARCHAR2(150),
        attribute9            VARCHAR2(150),
        attribute10           VARCHAR2(150),
        attribute11           VARCHAR2(150),
        attribute12           VARCHAR2(150),
        attribute13           VARCHAR2(150),
        attribute14           VARCHAR2(150),
        attribute15           VARCHAR2(150),
        context               VARCHAR2(30),
        object_version_number NUMBER,
        -- These two are added for updating repair order status when the status is
        -- accepted or rejected.
        repair_line_quantity     NUMBER,
        ro_object_version_number NUMBER,
        not_to_exceed            NUMBER := NULL -- swai: bug 9462789
        );

    /*--------------------------------------------------*/
    /* Record name: ESTIMATE_LINE_REC            */
    /* description : Record used for repair estimate rec*/
    /*                                                  */
    /*--------------------------------------------------*/

    TYPE ESTIMATE_LINE_REC IS RECORD(
		billing_Category          VARCHAR2(30),
	    repair_estimate_line_id   NUMBER,
        repair_estimate_id        NUMBER,
        repair_line_id            NUMBER,
        estimate_detail_id        NUMBER,
        incident_id               NUMBER,
        transaction_type_id       NUMBER,
        business_process_id       NUMBER,
        txn_billing_type_id       NUMBER,
        original_source_id        NUMBER,
        original_source_code      VARCHAR2(10),
        source_id                 NUMBER,
        source_code               VARCHAR2(10),
        line_type_id              NUMBER,
        item_cost                 NUMBER,
        resource_id               NUMBER,
        customer_product_id       NUMBER,
        reference_number          NUMBER,
        item_revision             VARCHAR2(30),
        justification_notes       VARCHAR2(240),
        estimate_status           VARCHAR2(30),
        order_number              VARCHAR2(30),
        purchase_order_num        VARCHAR2(50),
        source_number             VARCHAR2(30),
        status                    VARCHAR2(30),
        currency_code             VARCHAR2(15),
        line_category_code        VARCHAR2(6),
        unit_of_measure_code      VARCHAR2(3),
        original_source_number    VARCHAR2(3),
        add_to_order_flag         VARCHAR2(1),
        order_header_id           NUMBER,
        order_line_id             NUMBER,
        inventory_item_id         NUMBER,
        after_warranty_cost       NUMBER,
        selling_price             NUMBER,
        original_system_reference VARCHAR2(30),
        estimate_quantity         NUMBER,
        serial_number             VARCHAR2(50),
        lot_number                VARCHAR2(80), -- fix for bug#4625226
        instance_id               NUMBER,
        instance_number           NUMBER,
        price_list_id             NUMBER,
        contract_id               NUMBER,
        contract_number           VARCHAR2(120),
        coverage_bill_rate_id     NUMBER,
        sub_inventory             VARCHAR2(30),
        organization_id           NUMBER,
        invoice_to_org_id         NUMBER,
        ship_to_org_id            NUMBER,
        no_charge_flag            VARCHAR2(1),
        override_charge_flag      VARCHAR2(1),
        interface_to_om_flag      VARCHAR2(1),
        return_reason             VARCHAR2(30),
        return_by_date            DATE,
        last_update_date          DATE,
        creation_date             DATE,
        last_updated_by           NUMBER,
        created_by                NUMBER,
        last_update_login         NUMBER,
        attribute1                VARCHAR2(150),
        attribute2                VARCHAR2(150),
        attribute3                VARCHAR2(150),
        attribute4                VARCHAR2(150),
        attribute5                VARCHAR2(150),
        attribute6                VARCHAR2(150),
        attribute7                VARCHAR2(150),
        attribute8                VARCHAR2(150),
        attribute9                VARCHAR2(150),
        attribute10               VARCHAR2(150),
        attribute11               VARCHAR2(150),
        attribute12               VARCHAR2(150),
        attribute13               VARCHAR2(150),
        attribute14               VARCHAR2(150),
        attribute15               VARCHAR2(150),
        context                   VARCHAR2(30),
        object_version_number     NUMBER,
        security_group_id         NUMBER,
        charge_line_type          VARCHAR2(30),
        apply_contract_discount   VARCHAR2(1),
        coverage_id               NUMBER,
        coverage_txn_group_id     NUMBER,
        contract_discount_amount  NUMBER,
        EST_LINE_SOURCE_TYPE_CODE VARCHAR2(30),
        EST_LINE_SOURCE_ID1       NUMBER,
        EST_LINE_SOURCE_ID2       NUMBER,
        RO_SERVICE_CODE_ID        NUMBER,
        pricing_context           VARCHAR2(30),
        pricing_attribute1        VARCHAR2(150),
        pricing_attribute2        VARCHAR2(150),
        pricing_attribute3        VARCHAR2(150),
        pricing_attribute4        VARCHAR2(150),
        pricing_attribute5        VARCHAR2(150),
        pricing_attribute6        VARCHAR2(150),
        pricing_attribute7        VARCHAR2(150),
        pricing_attribute8        VARCHAR2(150),
        pricing_attribute9        VARCHAR2(150),
        pricing_attribute10       VARCHAR2(150),
        pricing_attribute11       VARCHAR2(150),
        pricing_attribute12       VARCHAR2(150),
        pricing_attribute13       VARCHAR2(150),
        pricing_attribute14       VARCHAR2(150),
        pricing_attribute15       VARCHAR2(150),
        pricing_attribute16       VARCHAR2(150),
        pricing_attribute17       VARCHAR2(150),
        pricing_attribute18       VARCHAR2(150),
        pricing_attribute19       VARCHAR2(150),
        pricing_attribute20       VARCHAR2(150),
        pricing_attribute21       VARCHAR2(150),
        pricing_attribute22       VARCHAR2(150),
        pricing_attribute23       VARCHAR2(150),
        pricing_attribute24       VARCHAR2(150),
        pricing_attribute25       VARCHAR2(150),
        pricing_attribute26       VARCHAR2(150),
        pricing_attribute27       VARCHAR2(150),
        pricing_attribute28       VARCHAR2(150),
        pricing_attribute29       VARCHAR2(150),
        pricing_attribute30       VARCHAR2(150),
        pricing_attribute31       VARCHAR2(150),
        pricing_attribute32       VARCHAR2(150),
        pricing_attribute33       VARCHAR2(150),
        pricing_attribute34       VARCHAR2(150),
        pricing_attribute35       VARCHAR2(150),
        pricing_attribute36       VARCHAR2(150),
        pricing_attribute37       VARCHAR2(150),
        pricing_attribute38       VARCHAR2(150),
        pricing_attribute39       VARCHAR2(150),
        pricing_attribute40       VARCHAR2(150),
        pricing_attribute41       VARCHAR2(150),
        pricing_attribute42       VARCHAR2(150),
        pricing_attribute43       VARCHAR2(150),
        pricing_attribute44       VARCHAR2(150),
        pricing_attribute45       VARCHAR2(150),
        pricing_attribute46       VARCHAR2(150),
        pricing_attribute47       VARCHAR2(150),
        pricing_attribute48       VARCHAR2(150),
        pricing_attribute49       VARCHAR2(150),
        pricing_attribute50       VARCHAR2(150),
        pricing_attribute51       VARCHAR2(150),
        pricing_attribute52       VARCHAR2(150),
        pricing_attribute53       VARCHAR2(150),
        pricing_attribute54       VARCHAR2(150),
        pricing_attribute55       VARCHAR2(150),
        pricing_attribute56       VARCHAR2(150),
        pricing_attribute57       VARCHAR2(150),
        pricing_attribute58       VARCHAR2(150),
        pricing_attribute59       VARCHAR2(150),
        pricing_attribute60       VARCHAR2(150),
        pricing_attribute61       VARCHAR2(150),
        pricing_attribute62       VARCHAR2(150),
        pricing_attribute63       VARCHAR2(150),
        pricing_attribute64       VARCHAR2(150),
        pricing_attribute65       VARCHAR2(150),
        pricing_attribute66       VARCHAR2(150),
        pricing_attribute67       VARCHAR2(150),
        pricing_attribute68       VARCHAR2(150),
        pricing_attribute69       VARCHAR2(150),
        pricing_attribute70       VARCHAR2(150),
        pricing_attribute71       VARCHAR2(150),
        pricing_attribute72       VARCHAR2(150),
        pricing_attribute73       VARCHAR2(150),
        pricing_attribute74       VARCHAR2(150),
        pricing_attribute75       VARCHAR2(150),
        pricing_attribute76       VARCHAR2(150),
        pricing_attribute77       VARCHAR2(150),
        pricing_attribute78       VARCHAR2(150),
        pricing_attribute79       VARCHAR2(150),
        pricing_attribute80       VARCHAR2(150),
        pricing_attribute81       VARCHAR2(150),
        pricing_attribute82       VARCHAR2(150),
        pricing_attribute83       VARCHAR2(150),
        pricing_attribute84       VARCHAR2(150),
        pricing_attribute85       VARCHAR2(150),
        pricing_attribute86       VARCHAR2(150),
        pricing_attribute87       VARCHAR2(150),
        pricing_attribute88       VARCHAR2(150),
        pricing_attribute89       VARCHAR2(150),
        pricing_attribute90       VARCHAR2(150),
        pricing_attribute91       VARCHAR2(150),
        pricing_attribute92       VARCHAR2(150),
        pricing_attribute93       VARCHAR2(150),
        pricing_attribute94       VARCHAR2(150),
        pricing_attribute95       VARCHAR2(150),
        pricing_attribute96       VARCHAR2(150),
        pricing_attribute97       VARCHAR2(150),
        pricing_attribute98       VARCHAR2(150),
        pricing_attribute99       VARCHAR2(150),
        pricing_attribute100      VARCHAR2(150)

        );

    TYPE ESTIMATE_LINE_TBL IS TABLE OF ESTIMATE_LINE_REC INDEX BY BINARY_INTEGER;

    /*--------------------------------------------------*/
    /* procedure name: create_estimate_header           */
    /* description   : procedure used to create         */
    /*                 repair estimate header           */
    /*                                                  */
    /*--------------------------------------------------*/

    /*#
--    * Creates a new Repair Estimate header for the given Repair order. The Estimate Header
    */
    PROCEDURE CREATE_ESTIMATE_HEADER(p_api_version      IN NUMBER,
                                     p_commit           IN VARCHAR2,
                                     p_init_msg_list    IN VARCHAR2,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_estimate_hdr_rec IN Csd_Repair_Estimate_Pub.ESTIMATE_HDR_REC,
                                     x_estimate_hdr_id  OUT NOCOPY NUMBER);

    /*--------------------------------------------------*/
    /* procedure name: update_estimate_header           */
    /* description   : procedure used to update         */
    /*                 repair estimate header           */
    /*                                                  */
    /*--------------------------------------------------*/

    /*#
--    * Updates a given estimate header record.
    */
    PROCEDURE UPDATE_ESTIMATE_HEADER(p_api_version           IN NUMBER,
                                     p_commit                IN VARCHAR2,
                                     p_init_msg_list         IN VARCHAR2,
                                     x_return_status         OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2,
                                     p_estimate_hdr_rec      IN Csd_Repair_Estimate_Pub.ESTIMATE_HDR_REC,
                                     x_object_version_number OUT NOCOPY NUMBER);

    /*#
--    * Creates an estimate line record under an estimate header.
    */
   PROCEDURE CREATE_ESTIMATE_LINE(p_api_version       IN NUMBER,
                                   p_commit            IN VARCHAR2,
                                   p_init_msg_list     IN VARCHAR2,
                                   x_return_status     OUT NOCOPY VARCHAR2,
                                   x_msg_count         OUT NOCOPY NUMBER,
                                   x_msg_data          OUT NOCOPY VARCHAR2,
                                   p_estimate_line_rec IN Csd_Repair_Estimate_Pub.ESTIMATE_LINE_REC,
                                   x_estimate_line_id  OUT NOCOPY NUMBER);

    /*#
--    * Updates a given estimate line record.
    */
    PROCEDURE UPDATE_ESTIMATE_LINE(p_api_version           IN NUMBER,
                                   p_init_msg_list         IN VARCHAR2,
                                   p_commit                IN VARCHAR2,
                                   x_return_status         OUT NOCOPY VARCHAR2,
                                   x_msg_count             OUT NOCOPY NUMBER,
                                   x_msg_data              OUT NOCOPY VARCHAR2,
                                   p_estimate_line_rec     IN Csd_Repair_Estimate_Pub.ESTIMATE_LINE_REC,
                                   x_object_version_number OUT NOCOPY NUMBER);

END Csd_Repair_Estimate_Pub;

/
