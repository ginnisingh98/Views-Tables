--------------------------------------------------------
--  DDL for Package CSF_IB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_IB" AUTHID CURRENT_USER AS
/* $Header: csfibass.pls 120.1 2006/01/31 14:25:48 ibalint noship $ */

-- case 1:
--     part is going to be stand alone, create a new CPID using the item.
--     return the CPID number

PROCEDURE create_base_product1(
	p_api_version	IN 	NUMBER,
	x_return_status OUT NOCOPY	varchar2,
	x_msg_count	OUT NOCOPY	number,
	x_msg_data	OUT NOCOPY	varchar2,
	x_cp_id		OUT NOCOPY 	number,
	x_object_version_number OUT NOCOPY number,
    p_customer_id	IN	NUMBER,
	p_inv_item_id	IN	number,
	p_cp_status_id	in	number,
	p_quantity	in	number,
	p_uom_code	in	varchar2,
	p_currency_code	in	varchar2,
	p_delivered_flag	in	varchar2	default null,
	p_installation_date	in	date		default null,
    p_serial_number in varchar2 default null,
    p_shipped_date      in   date          default null);

--case 2:
--      part is inserted as a child in a tree.
--      create a new CPID using the item. Set its parent
--      column to point to the value parent_cp_id.

PROCEDURE create_base_product2(
	p_api_version	IN 	NUMBER,
	x_return_status OUT NOCOPY	varchar2,
	x_msg_count	OUT NOCOPY	number,
	x_msg_data	OUT NOCOPY	varchar2,
	x_cp_id		OUT NOCOPY 	number,
	x_object_version_number OUT NOCOPY number,
        p_customer_id	IN	NUMBER,
	p_inv_item_id	IN	number,
	p_cp_status_id	in	number,
	p_quantity	in	number,
	p_uom_code	in	varchar2,
	p_currency_code	in	varchar2,
 	p_config_parent_cp_id	in 	number,
	p_delivered_flag	in	varchar2	default null,
	p_installation_date	in	date		default null,
    p_serial_number in varchar2 default null,
    p_shipped_date      in   date          default null);

--  case 3:
--     part is replacing a node in a tree. Create a new CPID
--     using the item, set its parents to point to parent of
--     the replaced cpid, and make all the cild of the replaced
--     cpid to the newly created record.

Procedure replace_product(
	p_api_version	in 	number,
	x_return_status OUT NOCOPY	varchar2,
	x_msg_count	OUT NOCOPY	number,
	x_msg_data	OUT NOCOPY	varchar2,
	x_new_cp_id		OUT NOCOPY 	number,
	 p_customer_id	IN	NUMBER,
	p_inv_item_id	IN	number,
	p_cp_status_id	in	number,
	p_old_cp_status_id in   number,
	p_quantity	in	number,
	p_uom_code	in	varchar2,
	p_currency_code	in	varchar2,
	p_cp_id		in	number,
	p_qty_mismatch_ok  in Varchar2 default null,
 	p_config_parent_cp_id	in 	number,
    p_serial_number in varchar2 default null,
    p_shipped_date      in   date          default null);

-- This procedure is used to update a Installed Base Product
Procedure Update_Product(
	p_api_version	in 	number,
	x_return_status OUT NOCOPY	varchar2,
	x_msg_count	 OUT NOCOPY	number,
	x_msg_data	 OUT NOCOPY	varchar2,
	p_cp_id		in	number,
     p_customer_id	IN	NUMBER,
	p_inv_item_id	IN	number,
	p_quantity	in	number,
	p_uom_code	in	varchar2,
	p_cp_status_id	in	number,
	p_config_parent_cp_id IN Number,
    p_serial_number in varchar2 default null,
    p_shipped_date      in   date          default null) ;

Procedure Update_install_base (
    p_api_version                in  number,
    p_init_msg_list              in  varchar2 := fnd_api.g_false,
    p_commit                     in  varchar2 := fnd_api.g_false,
    p_validation_level           in  number := fnd_api.g_valid_level_full,
    x_return_status              OUT NOCOPY varchar2,
    x_msg_count                  OUT NOCOPY number,
    x_msg_data                   OUT NOCOPY varchar2,
    x_new_instance_id            OUT NOCOPY  number,
    p_in_out_flag                in  varchar2,
    p_transaction_type_id        in  number,
    p_txn_sub_type_id            in  number,
    p_instance_id                in  number,
    p_inventory_item_id          in  number,
    p_inv_organization_id        in  number,
    p_inv_subinventory_name      in  varchar2,
    p_inv_locator_id             in  number,
    p_quantity                   in  number,
    p_inv_master_organization_id in  number,
    p_mfg_serial_number_flag     in  varchar2,
    p_serial_number              in  varchar2,
    p_lot_number                 in  varchar2,
    p_revision                   in  varchar2,
    p_unit_of_measure            in  varchar2,
    p_party_id                   in  number,
    p_party_account_id           in  number,
    p_party_site_id              in  number,
    p_parent_instance_id         in  number default null,
 p_instance_status_id         in number  := 9.99E125, --fnd_api.g_miss_num); --added for bug 3192060
p_item_operational_status_code in varchar2
            );



END csf_IB;

 

/
