--------------------------------------------------------
--  DDL for Package Body POS_ASN_CREATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ASN_CREATE_PVT" AS
/* $Header: POSVASNB.pls 120.4.12010000.6 2012/04/17 12:14:58 pneralla ship $*/
l_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

procedure log(			p_level in number,
						p_api_name in varchar2,
						p_msg in varchar2);

procedure log(			p_level in number,
						p_api_name in varchar2,
						p_msg in varchar2)
IS
l_module varchar2(2000);
BEGIN
/* Taken from Package FND_LOG
   LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
   LEVEL_ERROR      CONSTANT NUMBER  := 5;
   LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
   LEVEL_EVENT      CONSTANT NUMBER  := 3;
   LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
   LEVEL_STATEMENT  CONSTANT NUMBER  := 1;
*/

	IF(l_fnd_debug = 'Y')THEN
		l_module := 'pos.plsql.pos_asn_create_pvt.'||p_api_name;

    	IF ( p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	  FND_LOG.string(	LOG_LEVEL => p_level,
    					MODULE => l_module,
    					MESSAGE => p_msg);
    	END IF;

    END IF;
END log;

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
    )
IS
l_api_name varchar2(50) := 'insert_msni';
l_progress varchar2(20) := '000';
l_org_id number;
l_inventory_item_id number;
BEGIN
	select
		plla.ship_to_organization_id,
		pla.item_id
	into
		l_org_id,
		l_inventory_item_id
	from po_lines_all pla,
		po_line_locations_all plla
	where plla.line_location_id = p_po_line_loc_id
	and pla.po_line_id = plla.po_line_id;

	l_progress := '001'||p_po_line_loc_id;

	inv_rcv_integration_apis.insert_msni (
			      p_api_version => p_api_version
			    , x_return_status => x_return_status
			    , x_msg_count => x_msg_count
			    , x_msg_data => x_msg_data
			    , p_transaction_interface_id => p_transaction_interface_id
			    , p_fm_serial_number => p_fm_serial_number
			    , p_to_serial_number => p_to_serial_number
			    , p_organization_id => l_org_id
			    , p_inventory_item_id => l_inventory_item_id
			    , p_product_transaction_id => p_product_transaction_id
			    , p_product_code => 'RCV'
   			    , p_origination_date => p_origination_date
			    , p_status_id => p_status_id
			    , p_territory_code => p_territory_code
			    , p_serial_attribute_category => p_serial_attribute_category
			    , p_c_attribute1 => p_c_attribute1
			    , p_c_attribute2 => p_c_attribute2
			    , p_c_attribute3 => p_c_attribute3
			    , p_c_attribute4 => p_c_attribute4
			    , p_c_attribute5 => p_c_attribute5
			    , p_c_attribute6 => p_c_attribute6
			    , p_c_attribute7 => p_c_attribute7
			    , p_c_attribute8 => p_c_attribute8
			    , p_c_attribute9 => p_c_attribute9
			    , p_c_attribute10 => p_c_attribute10
			    , p_c_attribute11 => p_c_attribute11
			    , p_c_attribute12 => p_c_attribute12
			    , p_c_attribute13 => p_c_attribute13
			    , p_c_attribute14 => p_c_attribute14
			    , p_c_attribute15 => p_c_attribute15
			    , p_c_attribute16 => p_c_attribute16
			    , p_c_attribute17 => p_c_attribute17
			    , p_c_attribute18 => p_c_attribute18
			    , p_c_attribute19 => p_c_attribute19
			    , p_c_attribute20 => p_c_attribute20
			    , p_d_attribute1 => p_d_attribute1
			    , p_d_attribute2 => p_d_attribute2
			    , p_d_attribute3 => p_d_attribute3
			    , p_d_attribute4 => p_d_attribute4
			    , p_d_attribute5 => p_d_attribute5
			    , p_d_attribute6 => p_d_attribute6
			    , p_d_attribute7 => p_d_attribute7
			    , p_d_attribute8 => p_d_attribute8
			    , p_d_attribute9 => p_d_attribute9
			    , p_d_attribute10 => p_d_attribute10
			    , p_n_attribute1 => p_n_attribute1
			    , p_n_attribute2 => p_n_attribute2
			    , p_n_attribute3 => p_n_attribute3
			    , p_n_attribute4 => p_n_attribute4
			    , p_n_attribute5 => p_n_attribute5
			    , p_n_attribute6 => p_n_attribute6
			    , p_n_attribute7 => p_n_attribute7
			    , p_n_attribute8 => p_n_attribute8
			    , p_n_attribute9 => p_n_attribute9
			    , p_n_attribute10 => p_n_attribute10
			    , p_attribute_category => p_attribute_category
			    , p_attribute1 => p_attribute1
			    , p_attribute2 => p_attribute2
			    , p_attribute3 => p_attribute3
			    , p_attribute4 => p_attribute4
			    , p_attribute5 => p_attribute5
			    , p_attribute6 => p_attribute6
			    , p_attribute7 => p_attribute7
			    , p_attribute8 => p_attribute8
			    , p_attribute9 => p_attribute9
			    , p_attribute10 => p_attribute10
			    , p_attribute11 => p_attribute11
			    , p_attribute12 => p_attribute12
			    , p_attribute13 => p_attribute13
			    , p_attribute14 => p_attribute14
			    , p_attribute15 => p_attribute15
			    , p_att_exist => 'N'
			    );

exception when others then
	x_return_status := 'U';
	x_msg_data := 'Unexpected Error:'||sqlerrm;
	LOG(FND_LOG.LEVEL_UNEXPECTED,l_api_name,l_progress||':'||sqlerrm);
END insert_msni;

/**
* Public Procedure: insert_mtli
* Requires: p_api_version, p_transaction_interface_id, p_lot_number
*           p_transaction_quantity, p_transaction_uom, p_po_line_loc_id,
*           p_product_transaction_id
* Effects:  This procedure inserts the record into MTL_TRANSACTION_LOTS_INTERFACE
*           table during the creation of ASN.
* Returns:  x_return_status, x_msg_count, x_msg_data, p_transaction_interface_id,
*           x_serial_transaction_temp_id, p_product_transaction_id
*
* Bugs Fixed :  7476612 - Modified the code to get the Primary UOM from
*               po_uom_s.get_primary_uom by passing item_id, org_id, and
*               transaction_uom.
*/
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
    , p_vendor_id			     IN		NUMBER	DEFAULT NULL
    , p_grade_code		     IN		VARCHAR2	DEFAULT NULL
    , p_origination_date     	     IN		DATE		DEFAULT NULL
    , p_date_code			     IN		VARCHAR2	DEFAULT NULL
    , p_status_id			     IN		NUMBER	DEFAULT NULL
    , p_change_date       	     IN		DATE		DEFAULT NULL
    , p_age				     IN		NUMBER	DEFAULT NULL
    , p_retest_date	  	     IN		DATE		DEFAULT NULL
    , p_maturity_date  		     IN		DATE		DEFAULT NULL
    , p_item_size			     IN		NUMBER	DEFAULT NULL
    , p_color			     IN		VARCHAR2	DEFAULT NULL
    , p_volume		  	     IN		NUMBER	DEFAULT NULL
    , p_volume_uom		     IN		VARCHAR2	DEFAULT NULL
    , p_place_of_origin		     IN		VARCHAR2	DEFAULT NULL
    , p_best_by_date		     IN		DATE		DEFAULT NULL
    , p_length			     IN		NUMBER	DEFAULT NULL
    , p_length_uom		     IN		VARCHAR2	DEFAULT NULL
    , p_recycled_content	     IN		NUMBER	DEFAULT NULL
    , p_thickness			     IN		NUMBER	DEFAULT NULL
    , p_thickness_uom		     IN		VARCHAR2	DEFAULT NULL
    , p_width		  	     IN		NUMBER	DEFAULT NULL
    , p_width_uom			     IN		VARCHAR2	DEFAULT NULL
    , p_curl_wrinkle_fold	     IN		VARCHAR2	DEFAULT NULL
    , p_supplier_lot_number	     IN		VARCHAR2	DEFAULT NULL
    , p_territory_code		     IN		VARCHAR2	DEFAULT NULL
    , p_vendor_name	           IN		VARCHAR2	DEFAULT NULL
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
    , p_lot_exp_dt                 IN             DATE      DEFAULT NULL        -- Added for bug7137189
    )
IS
l_api_name varchar2(50) := 'insert_mtli';
l_progress varchar2(20) := '000';
l_primary_quantity number;
l_org_id number;
l_inventory_item_id number;
l_expiration_date date := p_lot_exp_dt;      -- Added for bug8404937
l_serial_txn_temp_id number;
l_uom po_lines_all.UNIT_MEAS_LOOKUP_CODE%type;
BEGIN
        -- Bug 7476612 - Start
	select
		plla.ship_to_organization_id,
		pla.item_id
		--pla.UNIT_MEAS_LOOKUP_CODE
	into
		l_org_id,
		l_inventory_item_id
		--l_uom
	from
		po_lines_all pla,
		po_line_locations_all plla
	where plla.line_location_id = p_po_line_loc_id
	and plla.po_line_id = pla.po_line_id;

        l_uom := po_uom_s.get_primary_uom(l_inventory_item_id,l_org_id,p_transaction_uom);
        -- Bug 7476612 - End

	select RCV_TRANSACTIONS_INTERFACE_S.nextval into l_serial_txn_temp_id from dual;

	PO_UOM_S.uom_convert (
       from_quantity => p_transaction_quantity,
       from_uom => p_transaction_uom,
       item_id => l_inventory_item_id ,
       to_uom => l_uom,
       to_quantity => l_primary_quantity );


	l_progress := '001'||p_po_line_loc_id;
	inv_rcv_integration_apis.insert_mtli(
      p_api_version => p_api_version
    , x_return_status => x_return_status
    , x_msg_count => x_msg_count
    , x_msg_data => x_msg_data
    , p_transaction_interface_id => p_transaction_interface_id
    , p_lot_number => p_lot_number
    , p_transaction_quantity => p_transaction_quantity
    , p_primary_quantity => l_primary_quantity
    , p_organization_id => l_org_id
    , p_inventory_item_id => l_inventory_item_id
    , p_expiration_date => l_expiration_date           -- bug8404937
    , x_serial_transaction_temp_id => x_serial_transaction_temp_id
    , p_product_transaction_id => p_product_transaction_id
    , p_product_code => 'RCV'
    , p_vendor_id => p_vendor_id
    , p_grade_code => p_grade_code
    , p_origination_date => p_origination_date
    , p_date_code => p_date_code
    , p_status_id => p_status_id
    , p_change_date => p_change_date
    , p_age => p_age
    , p_retest_date => p_retest_date
    , p_maturity_date => p_maturity_date
    , p_item_size => p_item_size
    , p_color => p_color
    , p_volume => p_volume
    , p_volume_uom => p_volume_uom
    , p_place_of_origin => p_place_of_origin
    , p_best_by_date => p_best_by_date
    , p_length => p_length
    , p_length_uom => p_length_uom
    , p_recycled_content => p_recycled_content
    , p_thickness => p_thickness
    , p_thickness_uom => p_thickness_uom
    , p_width => p_width
    , p_width_uom => p_width_uom
    , p_curl_wrinkle_fold => p_curl_wrinkle_fold
    , p_supplier_lot_number => p_supplier_lot_number
    , p_territory_code => p_territory_code
    , p_vendor_name => p_vendor_name
    , p_lot_attribute_category => p_lot_attribute_category
    , p_c_attribute1 => p_c_attribute1
    , p_c_attribute2 => p_c_attribute2
    , p_c_attribute3 => p_c_attribute3
    , p_c_attribute4 => p_c_attribute4
    , p_c_attribute5 => p_c_attribute5
    , p_c_attribute6 => p_c_attribute6
    , p_c_attribute7 => p_c_attribute7
    , p_c_attribute8 => p_c_attribute8
    , p_c_attribute9 => p_c_attribute9
    , p_c_attribute10 => p_c_attribute10
    , p_c_attribute11 => p_c_attribute11
    , p_c_attribute12 => p_c_attribute12
    , p_c_attribute13 => p_c_attribute13
    , p_c_attribute14 => p_c_attribute14
    , p_c_attribute15 => p_c_attribute15
    , p_c_attribute16 => p_c_attribute16
    , p_c_attribute17 => p_c_attribute17
    , p_c_attribute18 => p_c_attribute18
    , p_c_attribute19 => p_c_attribute19
    , p_c_attribute20 => p_c_attribute20
    , p_d_attribute1 => p_d_attribute1
    , p_d_attribute2 => p_d_attribute2
    , p_d_attribute3 => p_d_attribute3
    , p_d_attribute4 => p_d_attribute4
    , p_d_attribute5 => p_d_attribute5
    , p_d_attribute6 => p_d_attribute6
    , p_d_attribute7 => p_d_attribute7
    , p_d_attribute8 => p_d_attribute8
    , p_d_attribute9 => p_d_attribute9
    , p_d_attribute10 => p_d_attribute10
    , p_n_attribute1 => p_n_attribute1
    , p_n_attribute2 => p_n_attribute2
    , p_n_attribute3 => p_n_attribute3
    , p_n_attribute4 => p_n_attribute4
    , p_n_attribute5 => p_n_attribute5
    , p_n_attribute6 => p_n_attribute6
    , p_n_attribute7 => p_n_attribute7
    , p_n_attribute8 => p_n_attribute8
    , p_n_attribute9 => p_n_attribute9
    , p_n_attribute10 => p_n_attribute10
    , p_attribute_category => p_attribute_category
    , p_attribute1 => p_attribute1
    , p_attribute2 => p_attribute2
    , p_attribute3 => p_attribute3
    , p_attribute4 => p_attribute4
    , p_attribute5 => p_attribute5
    , p_attribute6 => p_attribute6
    , p_attribute7 => p_attribute7
    , p_attribute8 => p_attribute8
    , p_attribute9 => p_attribute9
    , p_attribute10 => p_attribute10
    , p_attribute11 => p_attribute11
    , p_attribute12 => p_attribute12
    , p_attribute13 => p_attribute13
    , p_attribute14 => p_attribute14
    , p_attribute15 => p_attribute15
    , p_att_exist => 'N'
    );


exception when others then
	x_return_status := 'U';
	x_msg_data := 'Unexpected Error:'||sqlerrm;
	LOG(FND_LOG.LEVEL_UNEXPECTED,l_api_name,l_progress||':'||sqlerrm);
END insert_mtli;

procedure insert_wlpni
  (p_api_version		        IN  	NUMBER
   , x_return_status              OUT 	NOCOPY	VARCHAR2
   , x_msg_count                  OUT 	NOCOPY	NUMBER
   , x_msg_data                   OUT 	NOCOPY	VARCHAR2
   , p_po_line_loc_ID            	IN 	NUMBER
   , p_license_plate_number             IN 	VARCHAR2
   , p_LPN_GROUP_ID                  	IN 	NUMBER
   , p_PARENT_LICENSE_PLATE_NUMBER      IN 	VARCHAR2
  )
IS
l_api_name varchar2(50) := 'insert_wlpni';
l_progress varchar2(20) := '000';
l_org_id number;
l_exist number;
l_parent_lpn wms_lpn_interface.parent_license_plate_number%type;

cursor l_lpn_exist_csr(p_lpn varchar2, p_grp_id number)
is
select 1, parent_license_plate_number
from wms_lpn_interface
where license_plate_number = p_lpn
and source_group_id = p_grp_id;

BEGIN
	select plla.ship_to_organization_id
	into l_org_id
	from po_line_locations_all plla
	where line_location_id = p_po_line_loc_id;

	if(p_parent_license_plate_number is null) then
	--Parent LPN is null ==> Insert LPN record, if not exist yet
		--Check if LPN already exist
		open l_lpn_exist_csr(p_license_plate_number, p_lpn_group_id);
		fetch l_lpn_exist_csr into l_exist, l_parent_lpn;
		close l_lpn_exist_csr;

		if(l_exist is null) then
			--If LPN does not exist, insert
			inv_rcv_integration_apis.insert_wlpni(
						p_api_version => p_api_version,
						x_return_status => x_return_status,
						x_msg_count => x_msg_count,
						x_msg_data => x_msg_data,
						p_ORGANIZATION_ID => l_ORG_ID,
						p_LPN_ID => null,
						p_license_plate_number => p_license_plate_number,
						p_LPN_GROUP_ID => p_LPN_GROUP_ID,
						p_PARENT_LICENSE_PLATE_NUMBER => null);
		end if;
	else
	--Parent LPN is not null ==> 	1. Insert new record with LPN and Parent LPN or update existing LPN with Parent LPN or return error if existing LPN has other Parent LPN
	--								2. Insert new record for Parent LPN if does not exist
		--Check if LPN already exist
		l_exist := null;
		open l_lpn_exist_csr(p_license_plate_number, p_lpn_group_id);
		fetch l_lpn_exist_csr into l_exist, l_parent_lpn;
		close l_lpn_exist_csr;

		if(l_exist is null) then
			--If LPN does not exist, insert
			inv_rcv_integration_apis.insert_wlpni(
						p_api_version => p_api_version,
						x_return_status => x_return_status,
						x_msg_count => x_msg_count,
						x_msg_data => x_msg_data,
						p_ORGANIZATION_ID => l_ORG_ID,
						p_LPN_ID => null,
						p_license_plate_number => p_license_plate_number,
						p_LPN_GROUP_ID => p_LPN_GROUP_ID,
						p_PARENT_LICENSE_PLATE_NUMBER => p_parent_license_plate_number);
		elsif(l_parent_lpn is not null AND l_parent_lpn <> p_parent_license_plate_number) then
			--Existing LPN has different parent_lpn
			x_return_status := 'E';
			x_msg_data := 'This LPN Child Parent relationship error should have been caught in the UI. A-->X, A-->Y exist';
		else
			--Existing LPN has NO Parent LPN
			update wms_lpn_interface
			set parent_license_plate_number = p_parent_license_plate_number
			where source_group_id = p_lpn_group_id
			and license_plate_number = p_license_plate_number;
		end if;

		--To see if we need to insert new record for the Parent LPN
		l_exist := null;
		open l_lpn_exist_csr(p_parent_license_plate_number, p_lpn_group_id);
		fetch l_lpn_exist_csr into l_exist, l_parent_lpn;
		close l_lpn_exist_csr;
		if(l_exist is null) then
			--Parent LPN as LPN does NOT exist ==> Insert
			inv_rcv_integration_apis.insert_wlpni(
						p_api_version => p_api_version,
						x_return_status => x_return_status,
						x_msg_count => x_msg_count,
						x_msg_data => x_msg_data,
						p_ORGANIZATION_ID => l_ORG_ID,
						p_LPN_ID => null,
						p_license_plate_number => p_parent_license_plate_number,
						p_LPN_GROUP_ID => p_LPN_GROUP_ID,
						p_PARENT_LICENSE_PLATE_NUMBER => null);

		end if;

	end if;

EXCEPTION WHEN OTHERS THEN
	LOG(FND_LOG.LEVEL_UNEXPECTED,l_api_name,l_progress||':'||sqlerrm);
	x_return_status := 'U';
	x_msg_data := 'Unexpected Error:'||sqlerrm;
END insert_wlpni;

procedure ValidateSerialRange(	p_api_version in number,
								x_return_status out nocopy varchar2,
								p_fm_serial_number in varchar2,
								p_to_serial_number in varchar2,
								p_quantity in number,
								p_lot_number in varchar2,
								p_line_loc_id in number,
								x_return_code out nocopy varchar2,
								x_return_msg out nocopy varchar2)
IS
l_api_name varchar2(50) := 'ValidateSerialRange';
l_progress varchar2(20) := '000';
l_valid_sr boolean;
l_ret_status varchar2(1);
l_ret_count number;
l_ret_data varchar2(2000);
l_val_mode number;
l_org_id number;
l_item_id number;
l_revision po_lines_all.item_revision%type; /* Bug 9734095 */
l_to_serial_number mtl_serial_numbers_interface.to_serial_number%type;
BEGIN
	l_to_serial_number := p_to_serial_number;

	select
		plla.ship_to_organization_id,
		pla.item_id,
		pla.item_revision,
		decode(msi.serial_number_control_code,2,inv_rcv_integration_apis.G_EXISTS_ONLY,inv_rcv_integration_apis.G_EXISTS_OR_CREATE)
	into
		l_org_id,
		l_item_id,
		l_revision,
		l_val_mode
	from
		po_lines_all pla,
		mtl_system_items msi,
		po_line_locations_all plla
	where pla.item_id = msi.inventory_item_id
	and plla.ship_to_organization_id = msi.organization_id
	and plla.line_location_id = p_line_loc_id
	and plla.po_line_id = pla.po_line_id;

	l_valid_sr := inv_rcv_integration_apis.validate_serial_range (
		p_api_version	 => 1.0
		, x_return_status     => l_ret_status
		, x_msg_count         => l_ret_count
		, x_msg_data          => l_ret_data
		, p_validation_mode	 => l_val_mode
		, p_org_id           => l_org_id
		, p_inventory_item_id => l_item_id
		, p_quantity	      => p_quantity
		, p_revision	      => l_revision
		, p_lot_number	 => p_lot_number
		, p_fm_serial_number  => p_fm_serial_number
		, p_to_serial_number	 => l_to_serial_number
		, p_txn_type	         => inv_rcv_integration_apis.G_SHIP) ;

	if(l_valid_sr = true) then
		x_return_code := 'T';
	else
		x_return_code := 'F';
		x_return_msg := fnd_msg_pub.get(l_ret_count,'F');
	end if;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

exception when others then
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_return_msg := 'Unexpected Error at POSVASNB.pls.ValidateSerialRange:'||sqlerrm;
	LOG(FND_LOG.LEVEL_UNEXPECTED,l_api_name,l_progress||':'||sqlerrm);
END ValidateSerialRange;

procedure ValidateLpn(	p_api_version in number,
						x_return_status out nocopy varchar2,
						p_lpn in varchar2,
						p_line_loc_id in number,
						x_return_code out nocopy varchar2,
						x_return_msg out nocopy varchar2)
IS
l_api_name varchar2(50) := 'ValidateLpn';
l_progress varchar2(20) := '000';
l_return_status varchar2(1);
l_msg_count number;
l_msg_data varchar2(2000);
l_ans boolean;
l_org_id number;
l_lpn_id number;
l_lpn_context wms_license_plate_numbers.lpn_context%type;
l_error_msg varchar2(2000);
BEGIN

	select
		plla.ship_to_organization_id
	into
		l_org_id
	from
		po_line_locations_all plla
	where plla.line_location_id = p_line_loc_id;

	l_ans := inv_rcv_integration_apis.validate_lpn
	  (p_api_version	=> 1.0
	   , x_return_status    => l_return_status
	   , x_msg_count        => l_msg_count
	   , x_msg_data         => l_msg_data
	   , p_validation_mode	=> inv_rcv_integration_apis.G_EXISTS_OR_CREATE
	   , p_org_id           => l_org_id
	   , p_lpn_id     	=> l_lpn_id
	   , p_lpn     		=> p_lpn);

        --the inv api does not check for context value
        if(l_ans = true) then
	   	select lpn_context into l_lpn_context
	   	from wms_license_plate_numbers
	   	where lpn_id = l_lpn_id;

                --can only reuse the LPNs that have a context of 5
                if(l_lpn_context is not null AND l_lpn_context <>  5) then
       			fnd_message.set_name('WMS', 'WMS_CONT_DUPLICATE_LPN');
    			fnd_msg_pub.ADD;
			fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
            		fnd_msg_pub.ADD;
                        FND_MSG_PUB.Count_And_Get(p_count => l_msg_count,
                                                  p_data => l_msg_data);
                        l_ans := false;
                end if;
        end if;

	if(l_ans = true ) then
		x_return_code := 'T';
	else
		x_return_code := 'F';
		for i in 1..l_msg_count
		loop
			l_error_msg := l_error_msg || ' ' || fnd_msg_pub.get(l_msg_count-i+1,'F');
		end loop;
		x_return_msg := l_error_msg;
	end if;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
exception when others then
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_return_msg := 'Unexpected Error at POSVASNB.pls.ValidateLpn:'||sqlerrm;
	LOG(FND_LOG.LEVEL_UNEXPECTED,l_api_name,l_progress||':'||sqlerrm);
END ValidateLpn;

procedure ValidateLot(
						p_api_version in number,
						x_return_status out nocopy varchar2,
						p_lot_number in varchar2,
						p_line_loc_id in number,
						p_validation_mode in number,

						p_lot_attribute_category in varchar2 ,
						p_c_attributes_tbl in PO_TBL_VARCHAR2000,
						p_n_attributes_tbl in PO_TBL_NUMBER,
						p_d_attributes_tbl in PO_TBL_DATE,
						p_grade_code in varchar2,
						p_origination_date in date,
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
                                                p_lot_exp_dt in date default null,          --Added for bug 7137189
						x_return_code out nocopy varchar2,
						x_return_msg out nocopy varchar2,
                                                x_is_new_lot out nocopy varchar2)
IS
l_c_attributes_tbl             inv_lot_api_pub.char_tbl;
l_n_attributes_tbl             inv_lot_api_pub.number_tbl;
l_d_attributes_tbl             inv_lot_api_pub.date_tbl;
l_api_name varchar2(50) := 'ValidateLot';
l_progress varchar2(20) := '000';
l_return_status varchar2(1);
l_msg_count number;
l_msg_data varchar2(2000);
l_ans boolean;
l_org_id number;
l_item_id number;
l_exp_date date;
BEGIN

	select
		plla.ship_to_organization_id,
		pla.item_id,
		pla.expiration_date
	into
		l_org_id,
		l_item_id,
		l_exp_date
	from
		po_lines_all pla,
		po_line_locations_all plla
	where plla.line_location_id = p_line_loc_id
	and plla.po_line_id = pla.po_line_id;

        l_c_attributes_tbl(1) := p_c_attributes_tbl(1);
        l_c_attributes_tbl(2) := p_c_attributes_tbl(2);
        l_c_attributes_tbl(3) := p_c_attributes_tbl(3);
        l_c_attributes_tbl(4) := p_c_attributes_tbl(4);
        l_c_attributes_tbl(5) := p_c_attributes_tbl(5);
        l_c_attributes_tbl(6) := p_c_attributes_tbl(6);
        l_c_attributes_tbl(7) := p_c_attributes_tbl(7);
        l_c_attributes_tbl(8) := p_c_attributes_tbl(8);
        l_c_attributes_tbl(9) := p_c_attributes_tbl(9);
        l_c_attributes_tbl(10) := p_c_attributes_tbl(10);
        l_c_attributes_tbl(11) := p_c_attributes_tbl(11);
        l_c_attributes_tbl(12) := p_c_attributes_tbl(12);
        l_c_attributes_tbl(13) := p_c_attributes_tbl(13);
        l_c_attributes_tbl(14) := p_c_attributes_tbl(14);
        l_c_attributes_tbl(15) := p_c_attributes_tbl(15);
        l_c_attributes_tbl(16) := p_c_attributes_tbl(16);
        l_c_attributes_tbl(17) := p_c_attributes_tbl(17);
        l_c_attributes_tbl(18) := p_c_attributes_tbl(18);
        l_c_attributes_tbl(19) := p_c_attributes_tbl(19);
        l_c_attributes_tbl(20) := p_c_attributes_tbl(20);

        l_n_attributes_tbl(1) := p_n_attributes_tbl(1);
        l_n_attributes_tbl(2) := p_n_attributes_tbl(2);
        l_n_attributes_tbl(3) := p_n_attributes_tbl(3);
        l_n_attributes_tbl(4) := p_n_attributes_tbl(4);
        l_n_attributes_tbl(5) := p_n_attributes_tbl(5);
        l_n_attributes_tbl(6) := p_n_attributes_tbl(6);
        l_n_attributes_tbl(7) := p_n_attributes_tbl(7);
        l_n_attributes_tbl(8) := p_n_attributes_tbl(8);
        l_n_attributes_tbl(9) := p_n_attributes_tbl(9);
        l_n_attributes_tbl(10) := p_n_attributes_tbl(10);


        l_d_attributes_tbl(1) := p_d_attributes_tbl(1);
        l_d_attributes_tbl(2) := p_d_attributes_tbl(2);
        l_d_attributes_tbl(3) := p_d_attributes_tbl(3);
        l_d_attributes_tbl(4) := p_d_attributes_tbl(4);
        l_d_attributes_tbl(5) := p_d_attributes_tbl(5);
        l_d_attributes_tbl(6) := p_d_attributes_tbl(6);
        l_d_attributes_tbl(7) := p_d_attributes_tbl(7);
        l_d_attributes_tbl(8) := p_d_attributes_tbl(8);
        l_d_attributes_tbl(9) := p_d_attributes_tbl(9);
        l_d_attributes_tbl(10) := p_d_attributes_tbl(10);



	l_ans := inv_rcv_integration_apis.validate_lot_number(
		p_api_version	=> 1
	   	, p_init_msg_lst	=> fnd_api.g_false
	   	, x_return_status   => l_return_status
	   	, x_msg_count       => l_msg_count
	   	, x_msg_data        => l_msg_data
                , x_is_new_lot      => x_is_new_lot
		, p_validation_mode	=> p_validation_mode
		, p_org_id              => l_org_id
		, p_inventory_item_id	=> l_item_id
		, p_lot_number     	=> p_lot_number
                , p_expiration_date     => p_lot_exp_dt         --Added for bug 8404937
		, p_txn_type		=> inv_rcv_integration_apis.G_SHIP

		, p_lot_attribute_category => p_lot_attribute_category
		, p_c_attributes_tbl => l_c_attributes_tbl
		, p_n_attributes_tbl => l_n_attributes_tbl
		, p_d_attributes_tbl => l_d_attributes_tbl
		, p_grade_code => p_grade_code
		, p_origination_date => p_origination_date
		, p_date_code => p_date_code
		, p_status_id => p_status_id
		, p_change_date => p_change_date
		, p_age => p_age
		, p_retest_date => p_retest_date
		, p_maturity_date => p_maturity_date
		, p_item_size => p_item_size
		, p_color => p_color
		, p_volume => p_volume
		, p_volume_uom => p_volume_uom
		, p_place_of_origin => p_place_of_origin
		, p_best_by_date => p_best_by_date
		, p_length => p_length
		, p_length_uom => p_length_uom
		, p_recycled_content => p_recycled_content
		, p_thickness => p_thickness
		, p_thickness_uom => p_thickness_uom
		, p_width => p_width
		, p_width_uom => p_width_uom
		, p_territory_code => p_territory_code
		, p_supplier_lot_number => p_supplier_lot_number
		, p_vendor_name => p_vendor_name
		);
	if(l_ans = true) then
		x_return_code := 'T';
	else
		x_return_code := 'F';
		x_return_msg := fnd_msg_pub.get(l_msg_count,'F');
	end if;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_return_msg := 'Unexpected Error at POSVASNB.pls.ValidateLot:'||sqlerrm;
	LOG(FND_LOG.LEVEL_UNEXPECTED,l_api_name,l_progress||':'||sqlerrm);
END ValidateLot;

procedure findLlsCode(p_line_location_id in number, x_llsCode out nocopy varchar2)
IS
l_api_name varchar2(50) := 'findLlsCode';
l_progress varchar2(20) := '000';
l_lot_code mtl_system_items.lot_control_code%type;
l_serial_code mtl_system_items.serial_number_control_code%type;
l_item_id number;
l_org_id  po_line_locations_all.ship_to_organization_id%type;
BEGIN
	l_progress := '001'||p_line_location_id;

    select pla.item_id,
           plla.ship_to_organization_id
    into   l_item_id,
           l_org_id
    from   po_lines_all pla ,po_line_locations_all plla
    where  plla.line_location_id = p_line_location_id
    and    pla.po_line_id=plla.po_line_id
    and    pla.po_header_id=plla.po_header_id ;

	if(l_item_id is null) then
		x_llsCode := 'LPN';
	else

		select
			msi.lot_control_code,
			msi.serial_number_control_code
	 	into
	 		l_lot_code,
	 		l_serial_code
		from
		 	mtl_system_items msi
        where msi.inventory_item_id=l_item_id
        and msi.organization_id=l_org_id;


		if(l_lot_code = 2 and l_serial_code in (2,5)) then
			x_llsCode := 'LAS';
		elsif(l_lot_code = 2) then
			x_llsCode := 'LOT';
		elsif(l_serial_code in (2,5)) then
			x_llsCode := 'SER';
		else
			x_llsCode := 'LPN';
		end if;
	end if;
exception when others then
	LOG(FND_LOG.LEVEL_UNEXPECTED,l_api_name,l_progress||':'||sqlerrm);
	x_llsCode := 'ERR:'||sqlerrm;

END findLlsCode;



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
		P_FREIGHT_TERMS             IN VARCHAR2)

IS

  cursor dis_details_cur is
	select WIP_ENTITY_ID,
               WIP_LINE_ID,
               WIP_OPERATION_SEQ_NUM,
               PO_DISTRIBUTION_ID
	from   po_distributions_all
	where  line_location_id = p_line_location_id;

  dis_details_rec 	dis_details_cur%rowtype;


BEGIN

  OPEN dis_details_cur;
  LOOP
	fetch dis_details_cur into dis_details_rec;
	exit when dis_details_cur%notfound;

  	-- The wip workflow needs to be called only for wip jobs
   	IF dis_details_rec.wip_entity_id is not null THEN

    	  wip_osp_shp_i_wf.StartWFProcToAnotherSupplier (
			dis_details_rec.po_distribution_id,
         		P_QUANTITY_T,
         		P_UNIT_OF_MEASURE_T,
         		P_SHIPPED_DATE,
         		P_EXPECTED_RECEIPT_DATE,
         		P_PACKING_SLIP_T,
         		P_WAYBILL_AIRBILL_NUM,
         		p_bill_of_lading,
         		p_packaging_code,
         		p_num_of_containers_t,
         		null,			  /* p_gross_weight */
         		null, 			  /* p_gross_weight_uom */
         		p_net_weight,
         		p_net_weight_uom,
         		p_tar_weight,
         		p_tar_weight_uom,
         		null,                      /* p_hazard_class */
         		null,                      /* p_hazard_code  */
         		null,                      /* p_hazard_desc  */
         		p_special_handling_code,
         		p_freight_carrier_code,
         		p_freight_terms,
         		null, 			   /* p_carrier_equipment */
         		null, 			   /* p_carrier_method */
         		null, 			   /* p_freight_bill_num */
         		null,                      /* p_receipt_num    */
         		null                       /* p_ussgl_txn_code */
          );

        END IF;

  END LOOP;

  CLOSE dis_details_cur;


 EXCEPTION

  WHEN OTHERS THEN
    raise;
END start_wip_workflow;



FUNCTION getAvailableShipmentQuantity (p_lineLocationID IN NUMBER)
RETURN NUMBER IS
    v_availableQuantity NUMBER;
    v_tolerableQuantity NUMBER;
    v_unitOfMeasure     VARCHAR2(25);
    x_progress          VARCHAR2(3);

BEGIN

    x_progress := '001';

    getShipmentQuantity( p_lineLocationID,
                         v_availableQuantity,
                         v_tolerableQuantity,
                         v_unitOfMeasure);

    RETURN v_availableQuantity;

EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('getAvailableShipmentQuantity', x_progress, sqlcode);
      RAISE;

END getAvailableShipmentQuantity;


FUNCTION getTolerableShipmentQuantity(p_lineLocationID IN NUMBER)
RETURN NUMBER IS
    v_availableQuantity NUMBER;
    v_tolerableQuantity NUMBER;
    v_unitOfMeasure     VARCHAR2(25);
    x_progress          VARCHAR2(3);

BEGIN

    x_progress := '001';

    getShipmentQuantity( p_lineLocationID,
                         v_availableQuantity,
                         v_tolerableQuantity,
                         v_unitOfMeasure);

    RETURN v_tolerableQuantity;

EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('getTolerableShipmentQuantity', x_progress, sqlcode);
      RAISE;

END getTolerableShipmentQuantity;


PROCEDURE getShipmentQuantity ( p_line_location_id      IN  NUMBER,
                                p_available_quantity IN OUT nocopy NUMBER,
                                p_tolerable_quantity IN OUT nocopy NUMBER,
                                p_unit_of_measure    IN OUT nocopy VARCHAR2) IS

x_progress                      VARCHAR2(3)     := NULL;
x_quantity_ordered              NUMBER          := 0;
x_quantity_received             NUMBER          := 0;
x_quantity_shipped              NUMBER          := 0;
x_interface_quantity            NUMBER          := 0; /* in primary_uom */
x_quantity_cancelled            NUMBER          := 0;
x_qty_rcv_tolerance             NUMBER          := 0;
x_qty_rcv_exception_code        VARCHAR2(26);
x_po_uom                        VARCHAR2(26);
x_item_id                       NUMBER;
x_primary_uom                   VARCHAR2(26);
x_interface_qty_in_po_uom       NUMBER          := 0;

BEGIN

   x_progress := '005';


   /*
   ** Get PO quantity information.
   */

   SELECT nvl(pll.quantity, 0),
          nvl(pll.quantity_received, 0),
          nvl(pll.quantity_shipped, 0),
          nvl(pll.quantity_cancelled,0),
          1 + (nvl(pll.qty_rcv_tolerance,0)/100),
          pll.qty_rcv_exception_code,
          pl.item_id,
          pl.unit_meas_lookup_code
   INTO   x_quantity_ordered,
          x_quantity_received,
          x_quantity_shipped,
          x_quantity_cancelled,
          x_qty_rcv_tolerance,
          x_qty_rcv_exception_code,
          x_item_id,
          x_po_uom
   FROM   po_line_locations_all pll,
          po_lines_all pl
   WHERE  pll.line_location_id = p_line_location_id
   AND    pll.po_line_id = pl.po_line_id;


   x_progress := '010';

   /*
   ** Get any unprocessed receipt or match transaction against the
   ** PO shipment. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
   */

   SELECT nvl(sum(primary_quantity),0),
          min(primary_unit_of_measure)
   INTO   x_interface_quantity,
          x_primary_uom
   FROM   rcv_transactions_interface
   WHERE  processing_status_code = 'PENDING'
   AND    transaction_type IN ('RECEIVE', 'MATCH','CORRECT','SHIP')
   AND    po_line_location_id = p_line_location_id;

   IF (x_interface_quantity = 0) THEN

        /*
        ** There is no unprocessed quantity. Simply set the
        ** x_interface_qty_in_po_uom to 0. There is no need for uom
        ** conversion.
        */

        x_interface_qty_in_po_uom := 0;

   ELSE

        /*
        ** There is unprocessed quantity. Convert it to the PO uom
        ** so that the available quantity can be calculated in the PO uom
        */

        x_progress := '015';
        po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
                             x_po_uom, x_interface_qty_in_po_uom);

   END IF;

   /*
   ** Calculate the quantity available to be received.
   */

   p_available_quantity := x_quantity_ordered - x_quantity_received - x_quantity_shipped -
                           x_quantity_cancelled - x_interface_qty_in_po_uom;

   /*
   ** p_available_quantity can be negative if this shipment has been over
   ** received. In this case, the available quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_available_quantity < 0) THEN
        p_available_quantity := 0;
   END IF;

   /*
   ** Calculate the maximum quantity that can be received allowing for
   ** tolerance.
   */

   p_tolerable_quantity := (x_quantity_ordered * x_qty_rcv_tolerance) -
                            x_quantity_received - x_quantity_shipped - x_quantity_cancelled -
                            x_interface_qty_in_po_uom;

   /*
   ** p_tolerable_quantity can be negative if this shipment has been over
   ** received. In this case, the tolerable quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_tolerable_quantity < 0) THEN
        p_tolerable_quantity := 0;
   END IF;

   /*
   ** Return the PO unit of measure
   */
   p_unit_of_measure := x_po_uom;

EXCEPTION
   WHEN OTHERS THEN
        po_message_s.sql_error('getShipmentQuantity', x_progress, sqlcode);
        RAISE;

END getShipmentQuantity;



/* procedure added to get converted quantity based on new UOM */

PROCEDURE getConvertedQuantity ( p_line_location_id      IN  NUMBER,
                                 p_available_quantity    IN  NUMBER,
                                 p_new_unit_of_measure   IN  VARCHAR2,
                                 p_converted_quantity  OUT nocopy NUMBER ) IS

/* p_available_quantity  is in new UOM */

x_converted_quantity            NUMBER          := 0;
x_po_uom                        VARCHAR2(26);
x_item_id                       NUMBER;

BEGIN

   SELECT pl.item_id,
          pl.unit_meas_lookup_code
   INTO   x_item_id,
          x_po_uom
   FROM   po_line_locations_all pll,
          po_lines_all pl
   WHERE  pll.line_location_id = p_line_location_id
   AND    pll.po_line_id = pl.po_line_id;


 IF (x_po_uom = p_new_unit_of_measure)  THEN
   p_converted_quantity := p_available_quantity;

 ELSE

   po_uom_s.uom_convert(p_available_quantity, p_new_unit_of_measure, x_item_id,
                        x_po_uom, x_converted_quantity);
   p_converted_quantity := x_converted_quantity;

 END IF;


END getConvertedQuantity;

/* end of procedure added to get converted quantity based on new UOM */




FUNCTION get_invoice_qty (
		p_line_location_id 	IN NUMBER,
                p_asn_unit_of_measure 	IN VARCHAR2,
                p_item_id 		IN NUMBER,
                p_quantity 		IN NUMBER)
RETURN NUMBER IS

  l_conversion_rate number := 0;
  l_asn_uom_code    varchar2(30);
  l_po_uom_code     varchar2(30);

BEGIN

  IF (p_asn_unit_of_measure is not null) THEN

    SELECT uom_code
    INTO   l_asn_uom_code
    FROM   mtl_units_of_measure
    WHERE  unit_of_measure = p_asn_unit_of_measure;

    SELECT uom_code
    INTO   l_po_uom_code
    FROM   mtl_units_of_measure
    WHERE  unit_of_measure =
                ( select nvl(poll.UNIT_MEAS_LOOKUP_CODE, pol.UNIT_MEAS_LOOKUP_CODE)
                  from   po_line_locations_all poll,
                         po_lines_all pol
                  where  poll.line_location_id = p_line_location_id
                  and    poll.po_line_id = pol.po_line_id );

    INV_CONVERT.inv_um_conversion(l_asn_uom_code,
				 l_po_uom_code,
				 p_item_id,
                                 l_conversion_rate);

   END IF;

   return (l_conversion_rate * p_quantity);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END get_invoice_qty;



FUNCTION check_wms_install (
		p_api_version 	IN NUMBER,
		x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2 IS


BEGIN

  IF (INV_CONTROL.Get_Current_Release_Level >= INV_RELEASE.Get_J_Release_Level) THEN
    return 'Y';

  ELSE
    return 'N';

  END IF;

  x_return_status := 'S';

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    RAISE;

END check_wms_install;


FUNCTION check_lpnlotserial_valid (
	p_asn_line_id IN NUMBER,
	p_lls_code IN VARCHAR2,
	p_processing_stage IN VARCHAR2)

RETURN VARCHAR2 IS  /*returns 'Y' or 'N' or 'E' on error*/

	l_rows number :=0;
	l_temp number :=0;

BEGIN

	IF ((p_lls_code = 'LAS') or (p_lls_code = 'LOT')) THEN

		IF (p_processing_stage = 'I') THEN
		/*only for I*/

			select count(*)
			into l_rows
			from rcv_transactions_interface rti,
				 mtl_transaction_lots_interface mtli
			where rti.INTERFACE_TRANSACTION_ID = mtli.PRODUCT_TRANSACTION_ID
			and mtli.PRODUCT_CODE = 'RCV'
			and rti.INTERFACE_TRANSACTION_ID = p_asn_line_id
			and mtli.LOT_NUMBER is not null;


		ELSE


			select count(*)
			into l_rows
			from rcv_shipment_lines rsl, rcv_transactions rt,
			mtl_transaction_lot_numbers mtln
			where rsl.shipment_line_id = rt.shipment_line_id
			and rt.transaction_type = 'RECEIVE'
			and rt.transaction_id = mtln.PRODUCT_TRANSACTION_ID
			and mtln.PRODUCT_CODE = 'RCV'
			and rsl.shipment_line_id = p_asn_line_id
			and mtln.LOT_NUMBER is not null;

			select count(*)
			into l_temp
			from rcv_shipment_lines rsl, rcv_lots_supply rcvls, mtl_lot_numbers mln
			where rsl.SHIPMENT_LINE_ID= rcvls.SHIPMENT_LINE_ID
			and rsl.to_organization_id = mln.ORGANIZATION_ID
			and rsl.ITEM_ID = mln.INVENTORY_ITEM_ID
			and rcvls.LOT_NUM = mln.LOT_NUMBER
			and rsl.shipment_line_id = p_asn_line_id
			and rcvls.LOT_NUM is not null;

			l_rows := l_rows + l_temp;



		END IF;

	ELSIF p_lls_code = 'SER' THEN

		IF (p_processing_stage = 'I') THEN
		/*only for I*/
			select  count(*)
			into l_rows
			from mtl_serial_numbers_interface msni,
				rcv_transactions_interface rti
			where rti.INTERFACE_TRANSACTION_ID = msni.PRODUCT_TRANSACTION_ID
			and msni.PRODUCT_CODE = 'RCV'
			and rti.INTERFACE_TRANSACTION_ID = p_asn_line_id
			and msni.FM_SERIAL_NUMBER is not null;

		ELSE


		/*only for S*/
			select count(*)
			into l_rows
			from rcv_shipment_lines rsl, rcv_transactions rt,
			mtl_unit_transactions mut
			where rsl.shipment_line_id = rt.shipment_line_id
			and rt.transaction_type = 'RECEIVE'
			and rt.transaction_id = mut.PRODUCT_TRANSACTION_ID
			and mut.PRODUCT_CODE = 'RCV'
			and rsl.shipment_line_id = p_asn_line_id
			and mut.SERIAL_NUMBER is not null;

			select count(*)
			into l_temp
			from rcv_serials_supply rss, rcv_shipment_lines rsl,
				mtl_serial_numbers msn
			where rsl.SHIPMENT_LINE_ID = rss.SHIPMENT_LINE_ID
			and rsl.to_organization_id = msn.CURRENT_ORGANIZATION_ID
			and rsl.ITEM_ID = msn.INVENTORY_ITEM_ID
			and rss.SERIAL_NUM = msn.SERIAL_NUMBER
			and rsl.SHIPMENT_LINE_ID = p_asn_line_id
			and rss.SERIAL_NUM is not null;

			l_rows := l_rows + l_temp;

		END IF;

	END IF;


	IF(l_rows=0) THEN


		IF (p_processing_stage = 'I') THEN
		/*only for I*/

			select count(*)
			into l_rows
			from rcv_transactions_interface rti, po_headers_all poh, po_releases_all por,
			po_line_locations_all pll
			where rti.po_header_id = poh.po_header_id
			and rti.po_release_id = por.po_release_id(+)
			and rti.po_line_location_id = pll.line_location_id
			and rti.INTERFACE_TRANSACTION_ID = p_asn_line_id
			and rti.LICENSE_PLATE_NUMBER is not null;

		ELSE
		/*only for S*/

			select count(*)
			into l_rows
			from rcv_shipment_lines rsl, po_headers_all poh, po_releases_all por,
			wms_license_plate_numbers wlpn, po_line_locations_all pll
			where rsl.po_header_id = poh.po_header_id
			and rsl.po_release_id = por.po_release_id(+)
			and rsl.ASN_LPN_ID = wlpn.LPN_ID
			and rsl.po_line_location_id = pll.line_location_id
			and rsl.SHIPMENT_LINE_ID = p_asn_line_id
			and wlpn.LICENSE_PLATE_NUMBER is not null;

		END IF;

	END IF;


	IF l_rows>0 THEN
	    	RETURN 'Y';
	ELSE
		RETURN 'N';
	END IF;

EXCEPTION

	WHEN OTHERS  THEN
	 	RETURN 'E';

END check_lpnlotserial_valid;

/* Inbound Logistics */
PROCEDURE validate_ship_from  (
    p_api_version_number       IN NUMBER,
    p_init_msg_list            IN VARCHAR2,
    x_return_status 	       OUT NOCOPY VARCHAR2,
    p_ship_from_locationId     IN NUMBER,
    p_po_line_id_tbl           IN po_tbl_number,
    p_po_line_loc_id_tbl       IN po_tbl_number,
    x_out_invalid_tbl          OUT NOCOPY po_tbl_varchar2000) IS


  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);

l_wsh_in_rec  WSH_PO_INTEGRATION_GRP.validateSF_in_rec_type;
l_wsh_out_rec WSH_PO_INTEGRATION_GRP.validateSF_out_rec_type;
BEGIN

  -- Clear global message table.
  IF (p_init_msg_list = 'Y') THEN
	 FND_MSG_PUB.initialize;
  END IF;


  -- Construct the record to pass in WSH api.
  for i in p_po_line_id_tbl.first .. p_po_line_id_tbl.last loop
     l_wsh_in_rec.po_line_id_tbl(i) := p_po_line_id_tbl(i);
  end loop;

  for j in p_po_line_loc_id_tbl.first .. p_po_line_loc_id_tbl.last loop
     l_wsh_in_rec.po_shipment_line_id_tbl(j) := p_po_line_loc_id_tbl(j);
  end loop;

  l_wsh_in_rec.ship_from_location_id := p_ship_from_locationid;


 --  Call WSH API
 -- TODO : uncomment the following call after applying the WSH package to the instance
  WSH_PO_INTEGRATION_GRP.validateASNReceiptShipFrom (
    p_api_version_number    => p_api_version_number,
    p_init_msg_list         => p_init_msg_list,
    p_in_rec                => l_wsh_in_rec,
    p_commit                => fnd_api.g_false,
    x_return_status         => x_return_status,
    x_out_rec               => l_wsh_out_rec ,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data );

   x_out_invalid_tbl := po_tbl_varchar2000();
  -- Construct the error message table as out parameter.
  IF (NOT l_wsh_out_rec.is_valid) THEN

     -- If error message count is 1, l_msg_data contains the error message.
     IF (l_msg_count = 1) THEN

         x_out_invalid_tbl.extend;
         x_out_invalid_tbl(x_out_invalid_tbl.last) := l_msg_data;

     -- Otherwise we need to get the error messages from the global  FND table.
     ELSE

        FOR l_index IN 1.. l_msg_count LOOP

           x_out_invalid_tbl.extend;
           x_out_invalid_tbl(x_out_invalid_tbl.last) :=
                fnd_msg_pub.get( p_encoded 	=> FND_API.G_FALSE, p_msg_index	=> l_index );
        END LOOP;

      END IF;

    END IF;


END validate_ship_from;

/**************************************Added for bug:13680427*******************************************/

PROCEDURE  get_po_quantity(p_line_location_id  IN  NUMBER,
                           p_available_quantity IN OUT NOCOPY NUMBER,
						               p_interface_qty_in_po_uom IN OUT NOCOPY NUMBER,
						               p_return_msg out nocopy varchar2,
						               p_return_status      OUT 	NOCOPY	VARCHAR2

)
as


p_tolerable_quantity NUMBER;
p_unit_of_measure     VARCHAR2(200);
x_quantity_ordered		NUMBER		:= 0;
x_quantity_received		NUMBER		:= 0;
x_interface_quantity  		NUMBER		:= 0; /* in primary_uom */
x_quantity_cancelled		NUMBER		:= 0;

x_qty_rcv_tolerance		NUMBER		:= 0;
x_qty_rcv_exception_code	VARCHAR2(26);
x_po_uom			VARCHAR2(26);
x_item_id			NUMBER;
x_primary_uom			VARCHAR2(26);
l_api_name varchar2(50):='get_po_quantity';
l_progress varchar2(20) := '000';


BEGIN

  /*
   ** Get PO quantity information.
   */

   SELECT nvl(pll.quantity, 0),
	  nvl(pll.quantity_received, 0),
	  nvl(pll.quantity_cancelled,0),
	  1 + (nvl(pll.qty_rcv_tolerance,0)/100),
	  pll.qty_rcv_exception_code,
	  pl.item_id,
	  pl.unit_meas_lookup_code
   INTO   x_quantity_ordered,
	  x_quantity_received,
	  x_quantity_cancelled,
	  x_qty_rcv_tolerance,
	  x_qty_rcv_exception_code,
	  x_item_id,
	  x_po_uom
   FROM   po_line_locations_all pll,  --<Shared Proc FPJ>
	  po_lines_all pl  --<Shared Proc FPJ>
   WHERE  pll.line_location_id = p_line_location_id
   AND    pll.po_line_id = pl.po_line_id;


   l_progress :='001'|| p_line_location_id;

    /*
   ** Get any unprocessed receipt or match transaction against the
   ** PO shipment. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
    Primary Unit of Measure cannot have value
     for One time Items. So Added a decode statement to fetch
     unit_of_measure in case of One Time Items and Primary
     Unit of Measure for Inventory Items.
  */


   SELECT nvl(sum(decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),0),
	  decode(min(item_id),null,min(unit_of_measure),min(primary_unit_of_measure))
   INTO   x_interface_quantity,
	  x_primary_uom
   FROM   rcv_transactions_interface rti
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    transaction_type IN ('RECEIVE', 'MATCH','CORRECT','SHIP','CANCEL')  -- bug 657347 should include 'SHIP'
                                                                     -- when calculating total quantity
                                                                     -- in the interface table
   AND NOT EXISTS(SELECT 1 FROM rcv_transactions rt                  -- bug 9583207 should not include
                  WHERE rt.transaction_type='DELIVER'                -- Correction to Deliver transaction
		              AND rt.transaction_id = rti.parent_transaction_id
		              AND rti.transaction_type = 'CORRECT')
   AND    po_line_location_id = p_line_location_id;


   l_progress :='002'|| p_line_location_id||x_interface_quantity;



   IF (x_interface_quantity = 0) THEN

	p_interface_qty_in_po_uom := 0;

   ELSE

	/*
	** There is unprocessed quantity. Convert it to the PO uom
	** so that the available quantity can be calculated in the PO uom
	*/

    po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
			     x_po_uom, p_interface_qty_in_po_uom);

   END IF;


   /*
   ** Calculate the quantity available to be received.
   */

   p_available_quantity := x_quantity_ordered - x_quantity_received -
			   x_quantity_cancelled - p_interface_qty_in_po_uom;


   /*
   ** p_available_quantity can be negative if this shipment has been over
   ** received. In this case, the available quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_available_quantity < 0) THEN

	p_available_quantity := 0;

   END IF;

   /*
   ** Calculate the maximum quantity that can be received allowing for
   ** tolerance.
   */
   p_tolerable_quantity := (x_quantity_ordered * x_qty_rcv_tolerance) -
			    x_quantity_received - x_quantity_cancelled -
			    p_interface_qty_in_po_uom;
   /*
   ** p_tolerable_quantity can be negative if this shipment has been over
   ** received. In this case, the tolerable quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_tolerable_quantity < 0) THEN

	p_tolerable_quantity := 0;

   END IF;

  p_return_status := 'S';

   EXCEPTION WHEN OTHERS THEN
	LOG(FND_LOG.LEVEL_UNEXPECTED,l_api_name,l_progress||':'||sqlerrm);
	p_return_status := 'E';
	p_return_msg := 'Unexpected Error:'||sqlerrm;


END get_po_quantity;



FUNCTION get_po_pending_asn_quantity(p_line_location_id  IN  NUMBER) return  NUMBER AS
p_interface_quantity NUMBER:=0;
p_available_quantity NUMBER:=0;
p_interface_qty_in_po_uom NUMBER:=0;
x_return_msg varchar2(100);
x_return_status varchar2(100);


begin
get_po_quantity(p_line_location_id ,p_available_quantity , p_interface_qty_in_po_uom,x_return_msg,x_return_status);
if (x_return_status='S') then
return p_interface_qty_in_po_uom;
else
return null;
END IF;

exception when others
then return null;

end get_po_pending_asn_quantity;


FUNCTION get_total_shippedquantity(p_line_location_id IN NUMBER) RETURN NUMBER AS


x_interface_qty_in_po_uom NUMBER;
p_quantity_shipped NUMBER:=0;
p_unit_of_measure     VARCHAR2(200);

x_quantity_shipped  NUMBER :=0;
x_interface_quantity  		NUMBER		:= 0;

x_qty_rcv_exception_code	VARCHAR2(26);
x_po_uom			VARCHAR2(26);
x_item_id			NUMBER;
x_primary_uom			VARCHAR2(26);
l_api_name varchar2(50):='get_po_quantity';
l_progress varchar2(20) := '000';


BEGIN

  /*
   ** Get PO quantity information.
   */

   SELECT nvl(pll.quantity_shipped, 0),
	   pll.qty_rcv_exception_code,
	  pl.item_id,
	  pl.unit_meas_lookup_code
   INTO   x_quantity_shipped,
	   x_qty_rcv_exception_code,
	  x_item_id,
	  x_po_uom
   FROM   po_line_locations_all pll,
	  po_lines_all pl
   WHERE  pll.line_location_id = p_line_location_id
   AND    pll.po_line_id = pl.po_line_id;


   l_progress :='001'|| p_line_location_id;

    /*
   ** Get any unprocessed receipt or match transaction against the
   ** PO shipment. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
    Primary Unit of Measure cannot have value
     for One time Items. So Added a decode statement to fetch
     unit_of_measure in case of One Time Items and Primary
     Unit of Measure for Inventory Items.
  */


   SELECT nvl(sum(decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),0),
	  decode(min(item_id),null,min(unit_of_measure),min(primary_unit_of_measure))
   INTO   x_interface_quantity,
	  x_primary_uom
   FROM   rcv_transactions_interface rti
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    transaction_type IN ('SHIP')
   AND NOT EXISTS(SELECT 1 FROM rcv_transactions rt
                  WHERE rt.transaction_type='DELIVER'
		              AND rt.transaction_id = rti.parent_transaction_id
		              AND rti.transaction_type = 'CORRECT')
   AND    po_line_location_id = p_line_location_id;


   l_progress :='001'|| p_line_location_id||x_interface_quantity;



   IF (x_interface_quantity = 0) THEN

	x_interface_qty_in_po_uom := 0;

   ELSE

	/*
	** There is unprocessed quantity. Convert it to the PO uom
	** so that the available quantity can be calculated in the PO uom
	*/

    po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
			     x_po_uom, x_interface_qty_in_po_uom);
           l_progress := '002'|| p_line_location_id|| x_interface_qty_in_po_uom;

   END IF;

     p_quantity_shipped:=Nvl((x_interface_qty_in_po_uom+Nvl(x_quantity_shipped,0)),0);

     RETURN p_quantity_shipped ;



  EXCEPTION WHEN OTHERS THEN
	LOG(FND_LOG.LEVEL_UNEXPECTED,l_api_name,l_progress||':'||sqlerrm);
	RETURN NULL;

 END   get_total_shippedquantity;

END POS_ASN_CREATE_PVT;

/
