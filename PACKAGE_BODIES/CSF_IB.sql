--------------------------------------------------------
--  DDL for Package Body CSF_IB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_IB" AS
/* $Header: csfibasb.pls 120.2.12000000.2 2007/07/26 00:18:50 hhaugeru ship $ */


PROCEDURE create_base_product1(
	p_api_version	IN 	NUMBER,
	x_return_status OUT NOCOPY	varchar2,
	x_msg_count	OUT NOCOPY	number,
	x_msg_data	OUT NOCOPY	varchar2,
	x_cp_id		OUT NOCOPY 	number,
	x_object_version_number	OUT NOCOPY number,
    p_customer_id	IN	NUMBER,
	p_inv_item_id	IN	number,
	p_cp_status_id	in	number,
	p_quantity	in	number,
	p_uom_code	in	varchar2,
	p_currency_code	in	varchar2,
	p_delivered_flag	in	varchar2	,
	p_installation_date	in	date		,
    p_serial_number     in   varchar2     ,
    p_shipped_date      in   date         ) IS

    l_cp_rec	   cs_installedbase_pub.cp_prod_rec_type;
    l_ship_rec     cs_installedbase_pub.CP_Ship_Rec_Type;
    xx_cp_id       number;

  BEGIN
	l_cp_rec.customer_id := p_customer_id;
	l_cp_rec.inv_item_id	:= p_inv_item_id;
	l_cp_rec.cp_status_id	:= p_cp_status_id;
	l_cp_rec.quantity	:= p_quantity;
	l_cp_rec.uom_code	:= p_uom_code;
	l_cp_rec.currency_code	:= p_currency_code;
	l_cp_rec.delivered_flag  := p_delivered_flag;
	l_cp_rec.installation_date := p_installation_date;

	cs_installedbase_pub.create_base_product(
	p_api_version	=>	1.0,
	x_return_status	=>	x_return_status,
	x_msg_count	=>	x_msg_count,
	x_msg_data	=>	x_msg_data,
	p_cp_rec	=>	l_cp_rec,
	x_cp_id		=>	x_cp_id,
	x_object_version_number	=> x_object_version_number);

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       if p_serial_number is not null then
         l_ship_rec.cp_id := x_cp_id;
         l_ship_rec.shipped_qty := p_quantity;
         l_ship_rec.shipped_date := p_shipped_date;
         l_ship_rec.serial_number := p_serial_number;
         CS_InstalledBase_PUB.Record_Shipment_Info
                   (
                     p_api_version  => 1.0,
                     p_init_msg_list => FND_API.G_FALSE,
                     p_commit    => FND_API.G_FALSE,
                     x_return_status => x_return_status,
                     x_msg_count   => x_msg_count,
                     x_msg_data   => x_msg_data,
                     p_ship_rec   => l_ship_rec,
                     x_new_cp_id   => xx_cp_id
                    );
        End if;
     End if;

END create_base_product1;


PROCEDURE create_base_product2(
	p_api_version	IN 	NUMBER,
	x_return_status OUT NOCOPY	varchar2,
	x_msg_count	OUT NOCOPY	number,
	x_msg_data	OUT NOCOPY	varchar2,
	x_cp_id		OUT NOCOPY 	number,
	X_object_version_number OUT NOCOPY number,
        p_customer_id	IN	NUMBER,
	p_inv_item_id	IN	number,
	p_cp_status_id	in	number,
	p_quantity	in	number,
	p_uom_code	in	varchar2,
	p_currency_code	in	varchar2,
 	p_config_parent_cp_id	in 	number,
	p_delivered_flag	in	varchar2	,
	p_installation_date	in	date		,
    p_serial_number     in   varchar2     ,
    p_shipped_date      in   date         ) IS

   l_cp_rec	   cs_installedbase_pub.cp_prod_rec_type;
   l_ship_rec     cs_installedbase_pub.CP_Ship_Rec_Type;
   xx_cp_id       number;

  BEGIN
	l_cp_rec.customer_id := p_customer_id;
	l_cp_rec.inv_item_id	:= p_inv_item_id;
	l_cp_rec.cp_status_id	:= p_cp_status_id;
	l_cp_rec.quantity	:= p_quantity;
	l_cp_rec.uom_code	:= p_uom_code;
	l_cp_rec.currency_code	:= p_currency_code;
	l_cp_rec.config_parent_cp_id	:=	p_config_parent_cp_id;
	l_cp_rec.delivered_flag  := p_delivered_flag;
	l_cp_rec.installation_date := p_installation_date;

	cs_installedbase_pub.create_base_product(
	p_api_version	=>	1.0,
	x_return_status	=>	x_return_status,
	x_msg_count	=>	x_msg_count,
	x_msg_data	=>	x_msg_data,
	p_cp_rec	=>	l_cp_rec,
	x_cp_id		=>	x_cp_id,
	x_object_version_number => x_object_version_number);

    --Added for recording serial number
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       if p_serial_number is not null then
         l_ship_rec.cp_id := x_cp_id;
         l_ship_rec.shipped_qty := p_quantity;
         l_ship_rec.shipped_date := p_shipped_date;
         l_ship_rec.serial_number := p_serial_number;
         CS_InstalledBase_PUB.Record_Shipment_Info
                   (
                     p_api_version  => 1.0,
                     p_init_msg_list => FND_API.G_FALSE,
                     p_commit    => FND_API.G_FALSE,
                     x_return_status => x_return_status,
                     x_msg_count   => x_msg_count,
                     x_msg_data   => x_msg_data,
                     p_ship_rec   => l_ship_rec,
                     x_new_cp_id   => xx_cp_id
                    );
         end if;
     End if;
END create_base_product2;



/*
  case 3:
     part is replacing a node in a tree. Create a new CPID
     using the item, set its parents to point to parent of
     the replaced cpid, and make all the cild of the replaced
     cpid to the newly created record.
*/

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
    p_qty_mismatch_ok in Varchar2 ,
 	p_config_parent_cp_id	in 	number,
    p_serial_number     in   varchar2     ,
    p_shipped_date      in   date
	) is

   l_cp_rec	      cs_installedbase_pub.cp_prod_rec_type;
   l_ship_rec     cs_installedbase_pub.CP_Ship_Rec_Type;
   xx_cp_id       number;


  BEGIN
	l_cp_rec.customer_id := p_customer_id;
	l_cp_rec.inv_item_id	:= p_inv_item_id;
	l_cp_rec.cp_status_id	:= p_cp_status_id;
	l_cp_rec.quantity	:= p_quantity;
	l_cp_rec.uom_code	:= p_uom_code;
	l_cp_rec.currency_code	:= p_currency_code;
	l_cp_rec.config_parent_cp_id	:=	p_config_parent_cp_id;

	cs_installedbase_pub.replace_product(
	p_api_version	=>	1.0,
	x_return_status	=>	x_return_status,
	x_msg_count	=>	x_msg_count,
	x_msg_data	=>	x_msg_data,
	p_cp_id		=>	p_cp_id,
    p_old_cp_status_id =>  p_old_cp_status_id,
	p_cp_rec	=>	l_cp_rec,
	x_new_cp_id	=>	x_new_cp_id,
	p_qty_mismatch_ok => p_qty_mismatch_ok);

    --Added for recording serial number
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      if p_serial_number is not null then
         l_ship_rec.cp_id := x_new_cp_id;
         l_ship_rec.shipped_date := p_shipped_date;
         l_ship_rec.serial_number := p_serial_number;
         l_ship_rec.shipped_qty := p_quantity;
         CS_InstalledBase_PUB.Record_Shipment_Info
                   (
                     p_api_version  => 1.0,
                     p_init_msg_list => FND_API.G_FALSE,
                     p_commit    => FND_API.G_FALSE,
                     x_return_status => x_return_status,
                     x_msg_count   => x_msg_count,
                     x_msg_data   => x_msg_data,
                     p_ship_rec   => l_ship_rec,
                     x_new_cp_id   => xx_cp_id
                    );
       end if;
     End if;
END replace_product;

Procedure Update_Product(
	p_api_version	in 	number,
	x_return_status OUT NOCOPY	varchar2,
	x_msg_count	 OUT NOCOPY	number,
	x_msg_data	 OUT NOCOPY	varchar2,
	p_cp_id		in	number ,
    p_customer_id	IN	NUMBER ,
	p_inv_item_id	IN	number ,
	p_quantity	in	number ,
	p_uom_code	in	varchar2,
	p_cp_status_id	in	number,
	p_config_parent_cp_id number,
    p_serial_number     in   varchar2     ,
    p_shipped_date      in   date         ) Is

l_abort_on_warn_flag	Cs_InstalledBase_Pub.Abort_Upd_On_Warn_Rec_Type;
l_cascade_updates_flag	Cs_InstalledBase_Pub.Cascade_Upd_Flag_Rec_Type;
l_cp_rec		Cs_InstalledBase_Pub.CP_Prod_Rec_Type;
l_ship_rec	Cs_InstalledBase_Pub.CP_Ship_Rec_Type;


Begin

    if p_cp_status_id is not Null Then
    	l_cp_rec.cp_status_id	:= p_cp_status_id;
    End If;
    If p_customer_id is Not Null Then
    	l_cp_rec.customer_id := p_customer_id;
    End if;
    If p_inv_item_id is not null Then
    	l_cp_rec.inv_item_id	:= p_inv_item_id;
    End If;
    If p_quantity is Not Null Then
       l_cp_rec.quantity	:= p_quantity;
    End If;
    If p_uom_code is Not Null Then
	   l_cp_rec.uom_code	:= p_uom_code;
    End If;
    If p_config_parent_cp_id is Not Null Then
    	l_cp_rec.config_parent_cp_id	:=	p_config_parent_cp_id;
    End If;
    --Added for recording serial number
    If p_serial_number is Not Null Then
        l_ship_rec.shipped_date := p_shipped_date;
        l_ship_rec.serial_number := p_serial_number;
    End If;

	Cs_InstalledBase_Pub.Update_Product
	(
		p_api_version			=> 1.0,
		x_return_status          => x_return_status,
		x_msg_count              => x_msg_count,
		x_msg_data               => x_msg_data,
		p_cp_id                  => p_cp_id,
		p_cp_rec	         => l_cp_rec,
		p_ship_rec	         => l_ship_rec,
		p_abort_on_warn_flag	 => l_abort_on_warn_flag,
          p_cascade_updates_flag  => l_cascade_updates_flag
	);

End Update_Product;

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
    p_parent_instance_id         in  number,
 p_instance_status_id         in number := 9.99E125,  --fnd_api.g_miss_num) --added for bug 3192060
p_item_operational_status_code in varchar2
) is

  l_api_version             NUMBER := 1.0;
  l_commit                  VARCHAR2(1)  := fnd_api.g_false;
  l_init_msg_list           VARCHAR2(1)  := fnd_api.g_false;
  l_validation_level        NUMBER       := fnd_api.g_valid_level_full;
  l_validate_only_flag      VARCHAR2(1)  := fnd_api.g_false;
  l_in_out_flag             VARCHAR2(30) := p_in_out_flag;
  l_dest_location_rec       csi_process_txn_grp.dest_location_rec;
  l_txn_rec                 csi_datastructures_pub.transaction_rec;
  l_instances_tbl           csi_process_txn_grp.txn_instances_tbl;
  l_i_parties_tbl           csi_process_txn_grp.txn_i_parties_tbl;
  l_ip_accounts_tbl         csi_process_txn_grp.txn_ip_accounts_tbl;
  l_org_units_tbl           csi_process_txn_grp.txn_org_units_tbl;
  l_ext_attrib_values_tbl   csi_process_txn_grp.txn_ext_attrib_values_tbl;
  l_pricing_attribs_tbl     csi_process_txn_grp.txn_pricing_attribs_tbl;
  l_instance_asset_tbl      csi_process_txn_grp.txn_instance_asset_tbl;
  l_ii_relationships_tbl    csi_process_txn_grp.txn_ii_relationships_tbl;
  l_return_status           VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(240);
  l_msg_index_out           binary_integer;
l_instance_status_id number:=  9.99E125 ;--FND_API.G_MISS_NUM; --added for bug 3192060

BEGIN
l_instance_status_id:=p_instance_status_id; --added for bug 3192060
IF p_in_out_flag               = 'OUT' Then ---Install a part at customer's site
--
--
  l_dest_location_rec.location_type_code    := 'HZ_PARTY_SITES';
  l_dest_location_rec.location_id           := p_party_site_id;
  l_dest_location_rec.INV_ORGANIZATION_ID   := null;
  l_dest_location_rec.INV_SUBINVENTORY_NAME := null;
  l_dest_location_rec.INV_LOCATOR_ID        := null;
  l_dest_location_rec.PA_PROJECT_ID         := null;
  l_dest_location_rec.PA_PROJECT_TASK_ID    := null;
  l_dest_location_rec.IN_TRANSIT_ORDER_LINE_ID := null;
  l_dest_location_rec.WIP_JOB_ID            := null;
  l_dest_location_rec.PO_ORDER_LINE_ID      := null;
--
--
  l_txn_rec.source_transaction_date         := sysdate;
  l_txn_rec.transaction_date                := sysdate;
  l_txn_rec.transaction_type_id             := p_transaction_type_id;
  l_txn_rec.txn_sub_type_id                 := p_txn_sub_type_id;
--
--
  l_instances_tbl(1).ib_txn_segment_flag    := 'S';
  l_instances_tbl(1).instance_id            := p_instance_id ;
  l_instances_tbl(1).inventory_item_id      := p_inventory_item_id;
  l_instances_tbl(1).inv_organization_id    := p_inv_organization_id;
  l_instances_tbl(1).vld_organization_id    := p_inv_organization_id;
  l_instances_tbl(1).inv_subinventory_name  := p_inv_subinventory_name;
  l_instances_tbl(1).inv_locator_id         := p_inv_locator_id;
  l_instances_tbl(1).location_type_code     := 'INVENTORY';
  l_instances_tbl(1).quantity               := p_quantity ;
  l_instances_tbl(1).inv_master_organization_id  := p_inv_master_organization_id;
  l_instances_tbl(1).object_version_number  := 1.0;
  l_instances_tbl(1).mfg_serial_number_flag := p_mfg_serial_number_flag;
  l_instances_tbl(1).unit_of_measure        := p_unit_of_measure;
  l_instances_tbl(1).serial_number          := p_serial_number;
  l_instances_tbl(1).lot_number             := p_lot_number;
  l_instances_tbl(1).inventory_revision     := p_revision;
  l_instances_tbl(1).instance_status_id     := l_instance_status_id; --added for bug 3192060
  l_instances_tbl(1).instance_usage_code    := 'OUT_OF_ENTERPRISE';
  l_instances_tbl(1).operational_status_code := p_item_operational_status_code;
--
--
  l_i_parties_tbl(1).parent_tbl_index       := 1;
  l_i_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
  l_i_parties_tbl(1).party_id               := p_party_id;
  l_i_parties_tbl(1).relationship_type_code := 'OWNER';
  l_i_parties_tbl(1).contact_flag           := 'N';
--
--
  l_ip_accounts_tbl(1).parent_tbl_index     := 1;
  l_ip_accounts_tbl(1).party_account_id     := p_party_account_id;
  l_ip_accounts_tbl(1).relationship_type_code:= 'OWNER';
--
   if p_parent_instance_id is not null Then
      l_instances_tbl(2).ib_txn_segment_flag    := 'P';
      l_instances_tbl(2).instance_id            := p_parent_instance_id;
      --
      --
      l_ii_relationships_tbl(1).subject_index          := 1;
      l_ii_relationships_tbl(1).object_index           := 2;
      l_ii_relationships_tbl(1).relationship_type_code := 'COMPONENT-OF';
   end if;
 end if;

 IF p_in_out_flag               = 'IN' Then ---Remove a part from customer's site

--
  l_dest_location_rec.location_type_code        := 'INVENTORY';
  l_dest_location_rec.inv_organization_id       := p_inv_organization_id;
  l_dest_location_rec.inv_subinventory_name     := p_inv_subinventory_name;
  l_dest_location_rec.inv_locator_id            := p_inv_locator_id;
--
--
  l_txn_rec.source_transaction_date             := sysdate;
  l_txn_rec.transaction_date                    := sysdate;
  l_txn_rec.transaction_type_id                 := p_transaction_type_id;
  l_txn_rec.txn_sub_type_id                     := p_txn_sub_type_id;
--
--
  l_instances_tbl(1).ib_txn_segment_flag        := 'S';
  l_instances_tbl(1).instance_id                := p_instance_id;
  l_instances_tbl(1).inventory_item_id          := p_inventory_item_id;
  l_instances_tbl(1).quantity                   := p_quantity;
  l_instances_tbl(1).inv_organization_id        := p_inv_organization_id;
  l_instances_tbl(1).vld_organization_id        := p_inv_organization_id;
  l_instances_tbl(1).inv_master_organization_id := p_inv_master_organization_id;
  l_instances_tbl(1).object_version_number      := 1.0;
  l_instances_tbl(1).mfg_serial_number_flag     := p_mfg_serial_number_flag;
  l_instances_tbl(1).unit_of_measure            := p_unit_of_measure;
  l_instances_tbl(1).serial_number              := p_serial_number;
  l_instances_tbl(1).lot_number                 := p_lot_number;
  l_instances_tbl(1).inventory_revision         := p_revision;
l_instances_tbl(1).instance_status_id     := l_instance_status_id; --added for bug 3192060
  l_instances_tbl(1).instance_usage_code        := 'IN_INVENTORY';
  l_instances_tbl(1).operational_status_code    := 'OUT_OF_SERVICE';

--

  l_i_parties_tbl(1).parent_tbl_index           := 1;
  l_i_parties_tbl(1).party_source_table         := 'HZ_PARTIES';
  l_i_parties_tbl(1).party_id                   := p_party_id;
  l_i_parties_tbl(1).relationship_type_code     := 'OWNER';
  l_i_parties_tbl(1).contact_flag               := 'N';

--
--
  /*
  l_ip_accounts_tbl(1).parent_tbl_index         := 1;
  l_ip_accounts_tbl(1).party_account_id         := p_party_account_id;
  l_ip_accounts_tbl(1).relationship_type_code   := 'OWNER';
  */
--
--

 End If;

  csi_process_txn_grp.process_transaction (
    p_api_version             => l_api_version,
    p_commit                  => l_commit,
    p_init_msg_list           => l_init_msg_list,
    p_validation_level        => l_validation_level,
    p_validate_only_flag      => l_validate_only_flag,
    p_in_out_flag             => l_in_out_flag,
    p_dest_location_rec       => l_dest_location_rec,
    p_txn_rec                 => l_txn_rec,
    p_instances_tbl           => l_instances_tbl,
    p_i_parties_tbl           => l_i_parties_tbl,
    p_ip_accounts_tbl         => l_ip_accounts_tbl,
    p_org_units_tbl           => l_org_units_tbl,
    p_ext_attrib_vlaues_tbl   => l_ext_attrib_values_tbl,
    p_pricing_attribs_tbl     => l_pricing_attribs_tbl,
    p_instance_asset_tbl      => l_instance_asset_tbl,
    p_ii_relationships_tbl    => l_ii_relationships_tbl,
    x_return_status           => x_return_status,
    x_msg_count               => x_msg_count,
    x_msg_data                => x_msg_data );

if x_return_status='S' Then x_new_instance_id := l_instances_tbl(1).new_instance_id;
End If;


END UPDATE_INSTALL_BASE;


END csf_IB;



/
