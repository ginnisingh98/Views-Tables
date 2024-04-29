--------------------------------------------------------
--  DDL for Package POS_ASN_CREATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ASN_CREATE_PVT" AUTHID CURRENT_USER AS
/* $Header: POSVASNS.pls 120.2.12010000.3 2012/04/17 11:52:31 pneralla ship $*/

/* Inbound Logistics */

--TYPE t_error_msg_tbl IS TABLE OF VARCHAR2(2000);


PROCEDURE insert_msni (
      p_api_version                IN             NUMBER
    , x_return_status              OUT  NOCOPY    VARCHAR2
    , x_msg_count                  OUT  NOCOPY    NUMBER
    , x_msg_data                   OUT  NOCOPY    VARCHAR2
    , p_transaction_interface_id   IN OUT NOCOPY  NUMBER
    , p_fm_serial_number           IN             VARCHAR2
    , p_to_serial_number           IN             VARCHAR2
    , p_po_line_loc_id            IN             NUMBER
    , p_product_transaction_id     IN OUT NOCOPY  NUMBER
    , p_origination_date   	     IN  		  DATE	DEFAULT NULL
    , p_status_id		   	     IN  		  NUMBER	DEFAULT NULL
    , p_territory_code		     IN		  VARCHAR2	DEFAULT NULL
    , p_serial_attribute_category  IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute1               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute2               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute3               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute4               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute5               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute6               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute7               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute8               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute9               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute10              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute11              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute12              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute13              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute14              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute15              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute16              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute17              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute18              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute19              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute20              IN             VARCHAR2  DEFAULT NULL
    , p_d_attribute1               IN             DATE      DEFAULT NULL
    , p_d_attribute2               IN             DATE      DEFAULT NULL
    , p_d_attribute3               IN             DATE      DEFAULT NULL
    , p_d_attribute4               IN             DATE      DEFAULT NULL
    , p_d_attribute5               IN             DATE      DEFAULT NULL
    , p_d_attribute6               IN             DATE      DEFAULT NULL
    , p_d_attribute7               IN             DATE      DEFAULT NULL
    , p_d_attribute8               IN             DATE      DEFAULT NULL
    , p_d_attribute9               IN             DATE      DEFAULT NULL
    , p_d_attribute10              IN             DATE      DEFAULT NULL
    , p_n_attribute1               IN             NUMBER    DEFAULT NULL
    , p_n_attribute2               IN             NUMBER    DEFAULT NULL
    , p_n_attribute3               IN             NUMBER    DEFAULT NULL
    , p_n_attribute4               IN             NUMBER    DEFAULT NULL
    , p_n_attribute5               IN             NUMBER    DEFAULT NULL
    , p_n_attribute6               IN             NUMBER    DEFAULT NULL
    , p_n_attribute7               IN             NUMBER    DEFAULT NULL
    , p_n_attribute8               IN             NUMBER    DEFAULT NULL
    , p_n_attribute9               IN             NUMBER    DEFAULT NULL
    , p_n_attribute10              IN             NUMBER    DEFAULT NULL
    , p_attribute_category         IN             VARCHAR2  DEFAULT NULL
    , p_attribute1                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute2                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute3                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute4                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute5                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute6                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute7                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute8                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute9                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute10                IN             VARCHAR2  DEFAULT NULL
    , p_attribute11                IN             VARCHAR2  DEFAULT NULL
    , p_attribute12                IN             VARCHAR2  DEFAULT NULL
    , p_attribute13                IN             VARCHAR2  DEFAULT NULL
    , p_attribute14                IN             VARCHAR2  DEFAULT NULL
    , p_attribute15                IN             VARCHAR2  DEFAULT NULL
    );

PROCEDURE insert_mtli (
      p_api_version                IN             NUMBER
    , x_return_status              OUT  NOCOPY    VARCHAR2
    , x_msg_count                  OUT  NOCOPY    NUMBER
    , x_msg_data                   OUT  NOCOPY    VARCHAR2
    , p_transaction_interface_id   IN OUT NOCOPY  NUMBER
    , p_lot_number                 IN             VARCHAR2
    , p_transaction_quantity       IN             NUMBER
    , p_transaction_uom 			IN VARCHAR2
    , p_po_line_loc_id            IN             NUMBER
    , x_serial_transaction_temp_id OUT  NOCOPY    NUMBER
    , p_product_transaction_id     IN OUT NOCOPY  NUMBER
    , p_vendor_id			     	IN		NUMBER	DEFAULT NULL
    , p_grade_code			IN		VARCHAR2	DEFAULT NULL
    , p_origination_date     	   	IN		DATE		DEFAULT NULL
    , p_date_code				IN		VARCHAR2	DEFAULT NULL
    , p_status_id			      IN		NUMBER	DEFAULT NULL
    , p_change_date       		IN		DATE		DEFAULT NULL
    , p_age					IN		NUMBER	DEFAULT NULL
    , p_retest_date	  		IN		DATE		DEFAULT NULL
    , p_maturity_date  			IN		DATE		DEFAULT NULL
    , p_item_size				IN		NUMBER	DEFAULT NULL
    , p_color				IN		VARCHAR2	DEFAULT NULL
    , p_volume				IN		NUMBER	DEFAULT NULL
    , p_volume_uom			IN		VARCHAR2	DEFAULT NULL
    , p_place_of_origin			IN		VARCHAR2	DEFAULT NULL
    , p_best_by_date			IN		DATE		DEFAULT NULL
    , p_length				IN		NUMBER	DEFAULT NULL
    , p_length_uom			IN		VARCHAR2	DEFAULT NULL
    , p_recycled_content		IN		NUMBER	DEFAULT NULL
    , p_thickness				IN		NUMBER	DEFAULT NULL
    , p_thickness_uom			IN		VARCHAR2	DEFAULT NULL
    , p_width				IN		NUMBER	DEFAULT NULL
    , p_width_uom				IN		VARCHAR2	DEFAULT NULL
    , p_curl_wrinkle_fold		IN		VARCHAR2	DEFAULT NULL
    , p_supplier_lot_number		IN		VARCHAR2	DEFAULT NULL
    , p_territory_code			IN		VARCHAR2	DEFAULT NULL
    , p_vendor_name			IN		VARCHAR2	DEFAULT NULL
    , p_lot_attribute_category     IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute1               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute2               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute3               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute4               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute5               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute6               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute7               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute8               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute9               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute10              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute11              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute12              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute13              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute14              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute15              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute16              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute17              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute18              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute19              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute20              IN             VARCHAR2  DEFAULT NULL
    , p_d_attribute1               IN             DATE      DEFAULT NULL
    , p_d_attribute2               IN             DATE      DEFAULT NULL
    , p_d_attribute3               IN             DATE      DEFAULT NULL
    , p_d_attribute4               IN             DATE      DEFAULT NULL
    , p_d_attribute5               IN             DATE      DEFAULT NULL
    , p_d_attribute6               IN             DATE      DEFAULT NULL
    , p_d_attribute7               IN             DATE      DEFAULT NULL
    , p_d_attribute8               IN             DATE      DEFAULT NULL
    , p_d_attribute9               IN             DATE      DEFAULT NULL
    , p_d_attribute10              IN             DATE      DEFAULT NULL
    , p_n_attribute1               IN             NUMBER    DEFAULT NULL
    , p_n_attribute2               IN             NUMBER    DEFAULT NULL
    , p_n_attribute3               IN             NUMBER    DEFAULT NULL
    , p_n_attribute4               IN             NUMBER    DEFAULT NULL
    , p_n_attribute5               IN             NUMBER    DEFAULT NULL
    , p_n_attribute6               IN             NUMBER    DEFAULT NULL
    , p_n_attribute7               IN             NUMBER    DEFAULT NULL
    , p_n_attribute8               IN             NUMBER    DEFAULT NULL
    , p_n_attribute9               IN             NUMBER    DEFAULT NULL
    , p_n_attribute10              IN             NUMBER    DEFAULT NULL
    , p_attribute_category         IN             VARCHAR2  DEFAULT NULL
    , p_attribute1                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute2                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute3                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute4                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute5                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute6                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute7                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute8                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute9                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute10                IN             VARCHAR2  DEFAULT NULL
    , p_attribute11                IN             VARCHAR2  DEFAULT NULL
    , p_attribute12                IN             VARCHAR2  DEFAULT NULL
    , p_attribute13                IN             VARCHAR2  DEFAULT NULL
    , p_attribute14                IN             VARCHAR2  DEFAULT NULL
    , p_attribute15                IN             VARCHAR2  DEFAULT NULL
    , p_lot_exp_dt                 IN             DATE      DEFAULT NULL    -- Added for bug8404937
    );

procedure insert_wlpni
  (p_api_version		        IN  	NUMBER
   , x_return_status              OUT 	NOCOPY	VARCHAR2
   , x_msg_count                  OUT 	NOCOPY	NUMBER
   , x_msg_data                   OUT 	NOCOPY	VARCHAR2
   , p_po_line_loc_id            	IN 	NUMBER
   , p_license_plate_number             IN 	VARCHAR2
   , p_LPN_GROUP_ID                  	IN 	NUMBER
   , p_PARENT_LICENSE_PLATE_NUMBER      IN 	VARCHAR2
  );


procedure ValidateSerialRange(	p_api_version in number,
								x_return_status out nocopy varchar2,
								p_fm_serial_number in varchar2,
								p_to_serial_number in varchar2,
								p_quantity in number,
								p_lot_number in varchar2,
								p_line_loc_id in number,
								x_return_code out nocopy varchar2,
								x_return_msg out nocopy varchar2);

procedure ValidateLpn(	p_api_version in number,
						x_return_status out nocopy varchar2,
						p_lpn in varchar2,
						p_line_loc_id in number,
						x_return_code out nocopy varchar2,
						x_return_msg out nocopy varchar2);

procedure ValidateLot(
						p_api_version in number,
						x_return_status out nocopy varchar2,
						p_lot_number in varchar2,
						p_line_loc_id in number,
						p_validation_mode in number,

                                                p_lot_attribute_category in varchar2,
                                                p_c_attributes_tbl in PO_TBL_VARCHAR2000,
                                                p_n_attributes_tbl in PO_TBL_NUMBER,
                                                p_d_attributes_tbl in PO_TBL_DATE,
                                                p_grade_code in varchar2 ,
                                                p_origination_date in date ,
                                                p_date_code in varchar2,
                                                p_status_id in number,
                                                p_change_date in date,
                                                p_age in number,
                                                p_retest_date in date,
                                                p_maturity_date in date,
                                                p_item_size in number,
                                                p_color in varchar2,
                                                p_volume in number,
                                                p_volume_uom in varchar2,
                                                p_place_of_origin in varchar2,
                                                p_best_by_date in date,
                                                p_length in number,
                                                p_length_uom in varchar2,
                                                p_recycled_content in number,
                                                p_thickness in number,
                                                p_thickness_uom in varchar2,
                                                p_width in number,
                                                p_width_uom in varchar2,
                                                p_territory_code in varchar2,
                                                p_supplier_lot_number in varchar2,
                                                p_vendor_name in varchar2,
                                                p_lot_exp_dt in date default null,          --Added for bug 8404937
						x_return_code out nocopy varchar2,
						x_return_msg out nocopy varchar2,
						x_is_new_lot out nocopy varchar2);

procedure findLlsCode(p_line_location_id in number, x_llsCode out nocopy varchar2);


PROCEDURE start_wip_workflow (
		P_LINE_LOCATION_ID	    IN NUMBER,
		P_QUANTITY_T                IN NUMBER,
		P_UNIT_OF_MEASURE_T         IN VARCHAR2,
		P_SHIPPED_DATE              IN DATE,
		P_EXPECTED_RECEIPT_DATE     IN DATE,
		P_PACKING_SLIP_T            IN VARCHAR2,
		P_WAYBILL_AIRBILL_NUM       IN VARCHAR2,
		P_BILL_OF_LADING            IN VARCHAR2,
		P_PACKAGING_CODE            IN VARCHAR2,
		P_NUM_OF_CONTAINERS_T       IN NUMBER,
        	p_net_weight                IN NUMBER ,
       	 	p_net_weight_uom            IN VARCHAR2 ,
        	p_tar_weight                IN NUMBER ,
        	p_tar_weight_uom            IN VARCHAR2 ,
		P_SPECIAL_HANDLING_CODE     IN VARCHAR2 ,
		P_FREIGHT_CARRIER_CODE      IN VARCHAR2,
		P_FREIGHT_TERMS             IN VARCHAR2 );



FUNCTION get_invoice_qty (
		p_line_location_id 	IN NUMBER,
                p_asn_unit_of_measure 	IN VARCHAR2,
                p_item_id 		IN NUMBER,
                p_quantity 		IN NUMBER)
RETURN NUMBER;



PROCEDURE getShipmentQuantity (
		p_line_location_id   IN  NUMBER,
		p_available_quantity IN OUT nocopy NUMBER,
		p_tolerable_quantity IN OUT nocopy NUMBER,
		p_unit_of_measure    IN OUT nocopy VARCHAR2);



FUNCTION check_wms_install (
		p_api_version 	IN NUMBER,
		x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;


FUNCTION check_lpnlotserial_valid (
                p_asn_line_id IN NUMBER,
                p_lls_code IN VARCHAR2,
                p_processing_stage IN VARCHAR2)
RETURN VARCHAR2;

/* Inbound Logistics */
PROCEDURE validate_ship_from  (
    p_api_version_number       IN NUMBER,
    p_init_msg_list            IN VARCHAR2,
    x_return_status 	       OUT NOCOPY VARCHAR2,
    p_ship_from_locationId     IN NUMBER,
    p_po_line_id_tbl           IN po_tbl_number,
    p_po_line_loc_id_tbl       IN po_tbl_number,
    x_out_invalid_tbl          OUT NOCOPY po_tbl_varchar2000);

/*Added for bug:13680427*/
PROCEDURE  get_po_quantity(p_line_location_id  IN  NUMBER,
                           p_available_quantity IN OUT NOCOPY NUMBER,
						               p_interface_qty_in_po_uom IN OUT NOCOPY NUMBER,
						               p_return_msg out nocopy varchar2,
						               p_return_status      OUT 	NOCOPY	VARCHAR2);

FUNCTION get_po_pending_asn_quantity(
				p_line_location_id  IN  NUMBER)
return  NUMBER;

FUNCTION get_total_shippedquantity(
        p_line_location_id IN NUMBER)
RETURN NUMBER;

END POS_ASN_CREATE_PVT;


/
