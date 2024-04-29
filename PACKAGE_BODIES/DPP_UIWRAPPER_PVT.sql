--------------------------------------------------------
--  DDL for Package Body DPP_UIWRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_UIWRAPPER_PVT" as
/* $Header: dppvuiwb.pls 120.16.12010000.2 2010/03/26 12:21:28 rvkondur ship $ */
PROCEDURE check_transaction(
   p_transaction_header_id IN NUMBER
  ,p_status_change             IN VARCHAR2
  ,x_rec_count                 OUT NOCOPY NUMBER
  ,x_msg_data                  OUT NOCOPY VARCHAR2
  ,x_return_status             OUT NOCOPY      VARCHAR2)
  IS

 BEGIN
 --Call Dpp_utility_pvt.check_txnclose
 DPP_UTILITY_PVT.check_transaction(p_transaction_header_id => p_transaction_header_id
                                ,p_status_change => p_status_change
                                ,x_rec_count  =>      x_rec_count
                                ,x_msg_data   =>      x_msg_data
                                ,x_return_status  =>  x_return_status);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.check_txnclose');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
      END IF;
END check_transaction;

PROCEDURE search_vendors(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_vendor_tbl OUT NOCOPY vendor_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS

    l_search_criteria_tbl	DPP_UTILITY_PVT.search_criteria_tbl_type;
    l_vendor_tbl   				DPP_UTILITY_PVT.vendor_tbl_type;

BEGIN

   FOR i IN p_search_criteria.FIRST..p_search_criteria.LAST LOOP
				l_search_criteria_tbl(i).search_criteria := p_search_criteria(i).search_criteria;
				l_search_criteria_tbl(i).search_text := p_search_criteria(i).search_text;
   END LOOP;

		DPP_UTILITY_PVT.search_vendors(
				p_search_criteria => l_search_criteria_tbl
			 ,x_vendor_tbl => l_vendor_tbl
			 ,x_rec_count	=> x_rec_count
			 ,x_return_status => x_return_status
			 );

   IF x_rec_count > 0 THEN
     FOR j IN l_vendor_tbl.FIRST..l_vendor_tbl.LAST LOOP
        x_vendor_tbl(j).vendor_id := l_vendor_tbl(j).vendor_id;
				x_vendor_tbl(j).vendor_number := l_vendor_tbl(j).vendor_number;
				x_vendor_tbl(j).vendor_name := l_vendor_tbl(j).vendor_name;
     END LOOP;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.search_vendors');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END search_vendors;

PROCEDURE search_vendor_sites(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_vendor_site_tbl OUT NOCOPY vendor_site_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl	DPP_UTILITY_PVT.search_criteria_tbl_type;
    l_vendor_site_tbl			DPP_UTILITY_PVT.vendor_site_tbl_type;
BEGIN
   FOR i IN p_search_criteria.FIRST..p_search_criteria.LAST LOOP
				l_search_criteria_tbl(i).search_criteria := p_search_criteria(i).search_criteria;
				l_search_criteria_tbl(i).search_text := p_search_criteria(i).search_text;
   END LOOP;

   		DPP_UTILITY_PVT.search_vendor_sites(
	 				p_search_criteria => l_search_criteria_tbl
	 			 ,x_vendor_site_tbl => l_vendor_site_tbl
	 			 ,x_rec_count				=> x_rec_count
	 			 ,x_return_status 	=> x_return_status
	 			 );

	    IF x_rec_count > 0 THEN

	      FOR j IN l_vendor_site_tbl.FIRST..l_vendor_site_tbl.LAST LOOP

	        x_vendor_site_tbl(j).vendor_id 				:= l_vendor_site_tbl(j).vendor_id;
	 				x_vendor_site_tbl(j).vendor_site_id 	:= l_vendor_site_tbl(j).vendor_site_id;
	 				x_vendor_site_tbl(j).vendor_site_code := l_vendor_site_tbl(j).vendor_site_code;
	        x_vendor_site_tbl(j).address_line1 		:= l_vendor_site_tbl(j).address_line1;
	 				x_vendor_site_tbl(j).address_line2 		:= l_vendor_site_tbl(j).address_line2;
	 				x_vendor_site_tbl(j).address_line3 		:= l_vendor_site_tbl(j).address_line3;
	        x_vendor_site_tbl(j).city 						:= l_vendor_site_tbl(j).city;
	 				x_vendor_site_tbl(j).state 						:= l_vendor_site_tbl(j).state;
	 				x_vendor_site_tbl(j).zip 							:= l_vendor_site_tbl(j).zip;
	        x_vendor_site_tbl(j).country 					:= l_vendor_site_tbl(j).country;

	      END LOOP;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.search_vendor_sites');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END search_vendor_sites;

PROCEDURE search_vendor_contacts(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_vendor_contact_tbl OUT NOCOPY vendor_contact_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl		DPP_UTILITY_PVT.search_criteria_tbl_type;
    l_vendor_contact_tbl		DPP_UTILITY_PVT.vendor_contact_tbl_type;
BEGIN
   FOR i IN p_search_criteria.FIRST..p_search_criteria.LAST LOOP
				l_search_criteria_tbl(i).search_criteria := p_search_criteria(i).search_criteria;
				l_search_criteria_tbl(i).search_text := p_search_criteria(i).search_text;
   END LOOP;
   		DPP_UTILITY_PVT.search_vendor_contacts(
	 				p_search_criteria 		=> l_search_criteria_tbl
	 			 ,x_vendor_contact_tbl 	=> l_vendor_contact_tbl
	 			 ,x_rec_count						=> x_rec_count
	 			 ,x_return_status 			=> x_return_status
	 			 );

	    IF x_rec_count > 0 THEN

	      FOR j IN l_vendor_contact_tbl.FIRST..l_vendor_contact_tbl.LAST LOOP
	 				x_vendor_contact_tbl(j).vendor_site_id 		:= l_vendor_contact_tbl(j).vendor_site_id;
	 				x_vendor_contact_tbl(j).vendor_contact_id := l_vendor_contact_tbl(j).vendor_contact_id;
	        x_vendor_contact_tbl(j).contact_first_name 				:= l_vendor_contact_tbl(j).contact_first_name;
	 				x_vendor_contact_tbl(j).contact_middle_name 			:= l_vendor_contact_tbl(j).contact_middle_name;
	 				x_vendor_contact_tbl(j).contact_last_name 				:= l_vendor_contact_tbl(j).contact_last_name;
	        x_vendor_contact_tbl(j).contact_phone 						:= l_vendor_contact_tbl(j).contact_phone;
	 				x_vendor_contact_tbl(j).contact_email_address 		:= l_vendor_contact_tbl(j).contact_email_address;
	 				x_vendor_contact_tbl(j).contact_fax 							:= l_vendor_contact_tbl(j).contact_fax;

	      END LOOP;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.search_vendor_contacts');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END search_vendor_contacts;

PROCEDURE search_items(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_item_tbl OUT NOCOPY itemnum_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl	DPP_UTILITY_PVT.search_criteria_tbl_type;
    l_itemnum_tbl   			DPP_UTILITY_PVT.itemnum_tbl_type;
BEGIN
   FOR i IN p_search_criteria.FIRST..p_search_criteria.LAST LOOP
				l_search_criteria_tbl(i).search_criteria := p_search_criteria(i).search_criteria;
				l_search_criteria_tbl(i).search_text := p_search_criteria(i).search_text;
   END LOOP;

   		DPP_UTILITY_PVT.search_items(
	 				p_search_criteria 		=> l_search_criteria_tbl
	 			 ,x_item_tbl 						=> l_itemnum_tbl
	 			 ,x_rec_count						=> x_rec_count
	 			 ,x_return_status 			=> x_return_status
	 			 );

	    IF x_rec_count > 0 THEN

	      FOR j IN l_itemnum_tbl.FIRST..l_itemnum_tbl.LAST LOOP

	 				x_item_tbl(j).inventory_item_id 	:= l_itemnum_tbl(j).inventory_item_id;
	 				x_item_tbl(j).item_number 				:= l_itemnum_tbl(j).item_number;
	        x_item_tbl(j).description 				:= l_itemnum_tbl(j).description;
	 				x_item_tbl(j).vendor_part_no 			:= l_itemnum_tbl(j).vendor_part_no;

	      END LOOP;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.search_items');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END search_items;

PROCEDURE search_customer_items(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_item_tbl OUT NOCOPY item_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl		DPP_UTILITY_PVT.search_criteria_tbl_type;
    l_customer_item_tbl   	DPP_UTILITY_PVT.item_tbl_type;
BEGIN
   FOR i IN p_search_criteria.FIRST..p_search_criteria.LAST LOOP
				l_search_criteria_tbl(i).search_criteria := p_search_criteria(i).search_criteria;
				l_search_criteria_tbl(i).search_text := p_search_criteria(i).search_text;
   END LOOP;

   		DPP_UTILITY_PVT.search_customer_items(
	 				p_search_criteria 		=> l_search_criteria_tbl
	 			 ,x_customer_item_tbl 	=> l_customer_item_tbl
	 			 ,x_rec_count						=> x_rec_count
	 			 ,x_return_status 			=> x_return_status
	 			 );

	    IF x_rec_count > 0 THEN

	      FOR j IN l_customer_item_tbl.FIRST..l_customer_item_tbl.LAST LOOP

	 				x_customer_item_tbl(j).inventory_item_id 	:= l_customer_item_tbl(j).inventory_item_id;
	 				x_customer_item_tbl(j).item_number 				:= l_customer_item_tbl(j).item_number;
	        x_customer_item_tbl(j).description 				:= l_customer_item_tbl(j).description;

	      END LOOP;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.search_customer_items');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END search_customer_items;


PROCEDURE search_customer_items_all(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_item_tbl OUT NOCOPY item_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl		DPP_UTILITY_PVT.search_criteria_tbl_type;
    l_customer_item_tbl   	DPP_UTILITY_PVT.item_tbl_type;
BEGIN
   FOR i IN p_search_criteria.FIRST..p_search_criteria.LAST LOOP
				l_search_criteria_tbl(i).search_criteria := p_search_criteria(i).search_criteria;
				l_search_criteria_tbl(i).search_text := p_search_criteria(i).search_text;
   END LOOP;

   		DPP_UTILITY_PVT.search_customer_items_all(
	 				p_search_criteria 		=> l_search_criteria_tbl
	 			 ,x_customer_item_tbl 	=> l_customer_item_tbl
	 			 ,x_rec_count						=> x_rec_count
	 			 ,x_return_status 			=> x_return_status
	 			 );

	    IF x_rec_count > 0 THEN

	      FOR j IN l_customer_item_tbl.FIRST..l_customer_item_tbl.LAST LOOP

	 				x_customer_item_tbl(j).inventory_item_id 	:= l_customer_item_tbl(j).inventory_item_id;
	 				x_customer_item_tbl(j).item_number 				:= l_customer_item_tbl(j).item_number;
	        x_customer_item_tbl(j).description 				:= l_customer_item_tbl(j).description;

	      END LOOP;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.search_customer_items_all');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END search_customer_items_all;


PROCEDURE search_warehouses(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_warehouse_tbl OUT NOCOPY warehouse_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl	DPP_UTILITY_PVT.search_criteria_tbl_type;
    l_warehouse_tbl   		DPP_UTILITY_PVT.warehouse_tbl_type;
BEGIN
   FOR i IN p_search_criteria.FIRST..p_search_criteria.LAST LOOP
				l_search_criteria_tbl(i).search_criteria := p_search_criteria(i).search_criteria;
				l_search_criteria_tbl(i).search_text := p_search_criteria(i).search_text;
   END LOOP;

   		DPP_UTILITY_PVT.search_warehouses(
	 				p_search_criteria 		=> l_search_criteria_tbl
	 			 ,x_warehouse_tbl 			=> l_warehouse_tbl
	 			 ,x_rec_count						=> x_rec_count
	 			 ,x_return_status 			=> x_return_status
	 			 );

	    IF x_rec_count > 0 THEN

	      FOR j IN l_warehouse_tbl.FIRST..l_warehouse_tbl.LAST LOOP

	 				x_warehouse_tbl(j).warehouse_id 	:= l_warehouse_tbl(j).warehouse_id;
	 				x_warehouse_tbl(j).warehouse_code := l_warehouse_tbl(j).warehouse_code;
	        x_warehouse_tbl(j).Warehouse_Name := l_warehouse_tbl(j).Warehouse_Name;

	      END LOOP;
     END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.search_warehouses');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END search_warehouses;

PROCEDURE Get_InventoryDetails(
		p_hdr_rec								IN dpp_inv_hdr_rec_type
	 ,p_inventorydetails_tbl	IN OUT NOCOPY inventorydetails_tbl_type
	 ,x_rec_count							OUT NOCOPY NUMBER
   ,x_return_status	     		OUT 	  NOCOPY VARCHAR2
)
IS
    l_inventorydetails_tbl   		DPP_UTILITY_PVT.inventorydetails_tbl_type;
    l_hdr_rec  									DPP_UTILITY_PVT.dpp_inv_hdr_rec_type;

BEGIN

   l_hdr_rec.org_id 							:= p_hdr_rec.org_id;
   l_hdr_rec.effective_start_date := p_hdr_rec.effective_start_date;
   l_hdr_rec.effective_end_date 	:= p_hdr_rec.effective_end_date;
   l_hdr_rec.currency_code 				:= p_hdr_rec.currency_code;

   FOR i IN p_inventorydetails_tbl.FIRST..p_inventorydetails_tbl.LAST LOOP
				l_inventorydetails_tbl(i).Transaction_Line_Id := p_inventorydetails_tbl(i).Transaction_Line_Id;
				l_inventorydetails_tbl(i).Inventory_Item_ID 	:= p_inventorydetails_tbl(i).Inventory_Item_ID;

   END LOOP;

   		DPP_UTILITY_PVT.Get_InventoryDetails(
	 				p_hdr_rec 							=> l_hdr_rec
	 			 ,p_inventorydetails_tbl 	=> l_inventorydetails_tbl
	 			 ,x_rec_count							=> x_rec_count
	 			 ,x_return_status 				=> x_return_status
	 			 );

   FOR i IN l_inventorydetails_tbl.FIRST..l_inventorydetails_tbl.LAST LOOP
				p_inventorydetails_tbl(i).Transaction_Line_Id := l_inventorydetails_tbl(i).Transaction_Line_Id;
				p_inventorydetails_tbl(i).Inventory_Item_ID 	:= l_inventorydetails_tbl(i).Inventory_Item_ID;
				p_inventorydetails_tbl(i).Onhand_Quantity 		:= l_inventorydetails_tbl(i).Onhand_Quantity;
				p_inventorydetails_tbl(i).Covered_quantity 		:= l_inventorydetails_tbl(i).Covered_quantity;
				p_inventorydetails_tbl(i).UOM_Code				 		:= l_inventorydetails_tbl(i).UOM_Code;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Get_InventoryDetails');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Get_InventoryDetails;

PROCEDURE Get_CustomerInventory(
		p_hdr_rec			IN dpp_inv_hdr_rec_type
	 ,p_cust_inv_tbl	     IN OUT NOCOPY dpp_cust_inv_tbl_type
	 ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status	     OUT 	  NOCOPY VARCHAR2
)
IS
    l_hdr_rec  									DPP_UTILITY_PVT.dpp_inv_hdr_rec_type;
    l_cust_inv_tbl   						DPP_UTILITY_PVT.dpp_cust_inv_tbl_type;
BEGIN
   l_hdr_rec.org_id 							:= p_hdr_rec.org_id;
   l_hdr_rec.effective_start_date := p_hdr_rec.effective_start_date;
   l_hdr_rec.effective_end_date 	:= p_hdr_rec.effective_end_date;
   l_hdr_rec.currency_code 				:= p_hdr_rec.currency_code;

   FOR i IN p_cust_inv_tbl.FIRST..p_cust_inv_tbl.LAST LOOP
				l_cust_inv_tbl(i).Customer_ID 				:= p_cust_inv_tbl(i).Customer_ID;
				l_cust_inv_tbl(i).Inventory_Item_ID 	:= p_cust_inv_tbl(i).Inventory_Item_ID;
				l_cust_inv_tbl(i).UOM_Code 						:= p_cust_inv_tbl(i).UOM_Code;

   END LOOP;

   		DPP_UTILITY_PVT.Get_CustomerInventory(
	 				p_hdr_rec 							=> l_hdr_rec
	 			 ,p_cust_inv_tbl 					=> l_cust_inv_tbl
	 			 ,x_rec_count							=> x_rec_count
	 			 ,x_return_status 				=> x_return_status
	 			 );

   FOR i IN l_cust_inv_tbl.FIRST..l_cust_inv_tbl.LAST LOOP
				p_cust_inv_tbl(i).Customer_ID 				:= l_cust_inv_tbl(i).Customer_ID;
				p_cust_inv_tbl(i).Inventory_Item_ID 	:= l_cust_inv_tbl(i).Inventory_Item_ID;
				p_cust_inv_tbl(i).UOM_Code 						:= l_cust_inv_tbl(i).UOM_Code;
				p_cust_inv_tbl(i).Onhand_Quantity 		:= l_cust_inv_tbl(i).Onhand_Quantity;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Get_CustomerInventory');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Get_CustomerInventory;

PROCEDURE search_customers(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_tbl OUT NOCOPY customer_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl	DPP_UTILITY_PVT.search_criteria_tbl_type;
    l_customer_tbl				DPP_UTILITY_PVT.customer_tbl_type;
BEGIN
   FOR i IN p_search_criteria.FIRST..p_search_criteria.LAST LOOP
				l_search_criteria_tbl(i).search_criteria := p_search_criteria(i).search_criteria;
				l_search_criteria_tbl(i).search_text := p_search_criteria(i).search_text;
   END LOOP;

   		DPP_UTILITY_PVT.search_customers(
	 				p_search_criteria 		=> l_search_criteria_tbl
	 			 ,x_customer_tbl 				=> l_customer_tbl
	 			 ,x_rec_count						=> x_rec_count
	 			 ,x_return_status 			=> x_return_status
	 			 );

	    IF x_rec_count > 0 THEN

	      FOR j IN l_customer_tbl.FIRST..l_customer_tbl.LAST LOOP

	 				x_customer_tbl(j).customer_id 		:= l_customer_tbl(j).customer_id;
	 				x_customer_tbl(j).customer_number := l_customer_tbl(j).customer_number;
	        x_customer_tbl(j).customer_name 	:= l_customer_tbl(j).customer_name;

	      END LOOP;
     END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.search_customers');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END search_customers;


PROCEDURE search_customers_all(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_tbl OUT NOCOPY customer_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   )
IS
    l_search_criteria_tbl	DPP_UTILITY_PVT.search_criteria_tbl_type;
    l_customer_tbl				DPP_UTILITY_PVT.customer_tbl_type;
BEGIN
   FOR i IN p_search_criteria.FIRST..p_search_criteria.LAST LOOP
				l_search_criteria_tbl(i).search_criteria := p_search_criteria(i).search_criteria;
				l_search_criteria_tbl(i).search_text := p_search_criteria(i).search_text;
   END LOOP;

   		DPP_UTILITY_PVT.search_customers_all(
	 				p_search_criteria 		=> l_search_criteria_tbl
	 			 ,x_customer_tbl 				=> l_customer_tbl
	 			 ,x_rec_count						=> x_rec_count
	 			 ,x_return_status 			=> x_return_status
	 			 );

	    IF x_rec_count > 0 THEN

	      FOR j IN l_customer_tbl.FIRST..l_customer_tbl.LAST LOOP

	 				x_customer_tbl(j).customer_id 		:= l_customer_tbl(j).customer_id;
	 				x_customer_tbl(j).customer_number := l_customer_tbl(j).customer_number;
	        x_customer_tbl(j).customer_name 	:= l_customer_tbl(j).customer_name;

	      END LOOP;
     END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.search_customers_all');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END search_customers_all;

PROCEDURE Get_LastPrice(
		p_hdr_rec			IN dpp_inv_hdr_rec_type
	 ,p_cust_price_tbl	IN OUT NOCOPY dpp_cust_price_tbl_type
	 ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status	     OUT 	  NOCOPY VARCHAR2
)
IS
    l_hdr_rec  									DPP_UTILITY_PVT.dpp_inv_hdr_rec_type;
    l_cust_price_tbl   					DPP_UTILITY_PVT.dpp_cust_price_tbl_type;

BEGIN
   l_hdr_rec.org_id 							:= p_hdr_rec.org_id;
   l_hdr_rec.effective_start_date := p_hdr_rec.effective_start_date;
   l_hdr_rec.effective_end_date 	:= p_hdr_rec.effective_end_date;
   l_hdr_rec.currency_code 				:= p_hdr_rec.currency_code;

   FOR i IN p_cust_price_tbl.FIRST..p_cust_price_tbl.LAST LOOP
				l_cust_price_tbl(i).Customer_ID 				:= p_cust_price_tbl(i).Customer_ID;
				l_cust_price_tbl(i).Inventory_Item_ID 	:= p_cust_price_tbl(i).Inventory_Item_ID;
				l_cust_price_tbl(i).UOM_Code 						:= p_cust_price_tbl(i).UOM_Code;
                                l_cust_price_tbl(i).price_change 	:= p_cust_price_tbl(i).price_change;

   END LOOP;

   		DPP_UTILITY_PVT.Get_LastPrice(
	 				p_hdr_rec 							=> l_hdr_rec
	 			 ,p_cust_price_tbl 				=> l_cust_price_tbl
	 			 ,x_rec_count							=> x_rec_count
	 			 ,x_return_status 				=> x_return_status
	 			 );

   FOR i IN l_cust_price_tbl.FIRST..l_cust_price_tbl.LAST LOOP
				p_cust_price_tbl(i).Customer_ID 					:= l_cust_price_tbl(i).Customer_ID;
				p_cust_price_tbl(i).Inventory_Item_ID 		:= l_cust_price_tbl(i).Inventory_Item_ID;
				p_cust_price_tbl(i).UOM_Code 							:= l_cust_price_tbl(i).UOM_Code;
				p_cust_price_tbl(i).Last_Price 						:= l_cust_price_tbl(i).Last_Price;
				p_cust_price_tbl(i).invoice_currency_code		:= l_cust_price_tbl(i).invoice_currency_code;
                                p_cust_price_tbl(i).converted_price_change		:= l_cust_price_tbl(i).converted_price_change;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Get_LastPrice');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Get_LastPrice;

PROCEDURE Get_ListPrice(
		p_hdr_rec			IN dpp_inv_hdr_rec_type
	 ,p_listprice_tbl	     IN OUT NOCOPY dpp_list_price_tbl_type
	 ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
)
IS
    l_hdr_rec  									DPP_UTILITY_PVT.dpp_inv_hdr_rec_type;
    l_listprice_tbl   					DPP_UTILITY_PVT.dpp_list_price_tbl_type;
BEGIN
   l_hdr_rec.org_id 							:= p_hdr_rec.org_id;
   l_hdr_rec.effective_start_date := p_hdr_rec.effective_start_date;
   l_hdr_rec.effective_end_date 	:= p_hdr_rec.effective_end_date;
   l_hdr_rec.currency_code 				:= p_hdr_rec.currency_code;

   FOR i IN p_listprice_tbl.FIRST..p_listprice_tbl.LAST LOOP
				l_listprice_tbl(i).Inventory_Item_ID 	:= p_listprice_tbl(i).Inventory_Item_ID;

   END LOOP;

   		DPP_UTILITY_PVT.Get_ListPrice(
	 				p_hdr_rec 							=> l_hdr_rec
	 			 ,p_listprice_tbl 				=> l_listprice_tbl
	 			 ,x_rec_count							=> x_rec_count
	 			 ,x_return_status 				=> x_return_status
	 			 );

   FOR i IN l_listprice_tbl.FIRST..l_listprice_tbl.LAST LOOP
				p_listprice_tbl(i).Inventory_Item_ID 		:= l_listprice_tbl(i).Inventory_Item_ID;
				p_listprice_tbl(i).List_Price 					:= l_listprice_tbl(i).List_Price;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Get_ListPrice');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Get_ListPrice;

PROCEDURE Get_Vendor(
	p_vendor_rec IN OUT NOCOPY vendor_rec_type
	,x_rec_count		OUT NOCOPY NUMBER
  ,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS
    l_vendor_rec  									DPP_UTILITY_PVT.vendor_rec_type;
BEGIN
   l_vendor_rec.vendor_id 							:= p_vendor_rec.vendor_id;

   DPP_UTILITY_PVT.Get_Vendor(
	 	 				p_vendor_rec						=> l_vendor_rec
	 	 			 ,x_rec_count							=> x_rec_count
	 	 			 ,x_return_status 				=> x_return_status
	 			 );

   p_vendor_rec.vendor_number 	:= l_vendor_rec.vendor_number;
   p_vendor_rec.vendor_name 		:= l_vendor_rec.vendor_name;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Get_Vendor');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Get_Vendor;

PROCEDURE Get_Vendor_Site(
	p_vendor_site_rec IN OUT NOCOPY vendor_site_rec_type
	,x_rec_count		OUT NOCOPY NUMBER
  ,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS
    l_vendor_site_rec  									DPP_UTILITY_PVT.vendor_site_rec_type;
BEGIN

   l_vendor_site_rec.vendor_id 				:= p_vendor_site_rec.vendor_id;
   l_vendor_site_rec.vendor_site_id 	:= p_vendor_site_rec.vendor_site_id;

   DPP_UTILITY_PVT.Get_Vendor_Site(
	 	 				p_vendor_site_rec				=> l_vendor_site_rec
	 	 			 ,x_rec_count							=> x_rec_count
	 	 			 ,x_return_status 				=> x_return_status
	 			 );

   p_vendor_site_rec.vendor_site_code := l_vendor_site_rec.vendor_site_code;
   p_vendor_site_rec.address_line1 		:= l_vendor_site_rec.address_line1;
   p_vendor_site_rec.address_line2 		:= l_vendor_site_rec.address_line2;
   p_vendor_site_rec.address_line3 		:= l_vendor_site_rec.address_line3;
   p_vendor_site_rec.city 						:= l_vendor_site_rec.city;
   p_vendor_site_rec.state 						:= l_vendor_site_rec.state;
   p_vendor_site_rec.zip 							:= l_vendor_site_rec.zip;
   p_vendor_site_rec.country					:= l_vendor_site_rec.country;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Get_Vendor_Site');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Get_Vendor_Site;

PROCEDURE Get_Vendor_Contact(
	 p_vendor_contact_rec IN OUT NOCOPY vendor_contact_rec_type
	,x_rec_count		OUT NOCOPY NUMBER
  ,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS
    l_vendor_contact_rec						DPP_UTILITY_PVT.vendor_contact_rec_type;
BEGIN

   l_vendor_contact_rec.vendor_site_id 		:= p_vendor_contact_rec.vendor_site_id;
   l_vendor_contact_rec.vendor_contact_id := p_vendor_contact_rec.vendor_contact_id;

   DPP_UTILITY_PVT.Get_Vendor_Contact(
	 	 				p_vendor_contact_rec		=> l_vendor_contact_rec
	 	 			 ,x_rec_count							=> x_rec_count
	 	 			 ,x_return_status 				=> x_return_status
	 			 );

   p_vendor_contact_rec.contact_first_name 	:= l_vendor_contact_rec.contact_first_name;
   p_vendor_contact_rec.contact_middle_name := l_vendor_contact_rec.contact_middle_name;
   p_vendor_contact_rec.contact_last_name 	:= l_vendor_contact_rec.contact_last_name;
   p_vendor_contact_rec.contact_phone 			:= l_vendor_contact_rec.contact_phone;
   p_vendor_contact_rec.contact_email_address 	:= l_vendor_contact_rec.contact_email_address;
   p_vendor_contact_rec.contact_fax 			:= l_vendor_contact_rec.contact_fax;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Get_Vendor_Contact');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Get_Vendor_Contact;

PROCEDURE Get_Warehouse(
	  p_warehouse_tbl	     	IN OUT NOCOPY warehouse_tbl_type
	 ,x_rec_count		OUT NOCOPY NUMBER
   ,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS

    l_warehouse_tbl   					DPP_UTILITY_PVT.warehouse_tbl_type;
BEGIN

   FOR i IN p_warehouse_tbl.FIRST..p_warehouse_tbl.LAST LOOP
				l_warehouse_tbl(i).warehouse_id 	:= p_warehouse_tbl(i).warehouse_id;
   END LOOP;

   		DPP_UTILITY_PVT.Get_Warehouse(
	 			 p_warehouse_tbl 				=> l_warehouse_tbl
	 			 ,x_rec_count							=> x_rec_count
	 			 ,x_return_status 				=> x_return_status
	 			 );

   FOR i IN l_warehouse_tbl.FIRST..l_warehouse_tbl.LAST LOOP
				p_warehouse_tbl(i).warehouse_id 		:= l_warehouse_tbl(i).warehouse_id;
				p_warehouse_tbl(i).warehouse_code 	:= l_warehouse_tbl(i).warehouse_code;
				p_warehouse_tbl(i).Warehouse_Name 	:= l_warehouse_tbl(i).Warehouse_Name;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Get_Warehouse');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Get_Warehouse;

PROCEDURE Get_Customer(
	  p_customer_tbl IN OUT NOCOPY customer_tbl_type
	 ,x_rec_count		OUT NOCOPY NUMBER
   	,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS

    l_customer_tbl   					DPP_UTILITY_PVT.customer_tbl_type;
BEGIN

   FOR i IN p_customer_tbl.FIRST..p_customer_tbl.LAST LOOP
				l_customer_tbl(i).customer_id 	:= p_customer_tbl(i).customer_id;
   END LOOP;

   		DPP_UTILITY_PVT.Get_Customer(
	 			  p_customer_tbl 					=> l_customer_tbl
	 			 ,x_rec_count							=> x_rec_count
	 			 ,x_return_status 				=> x_return_status
	 			 );

   FOR i IN l_customer_tbl.FIRST..l_customer_tbl.LAST LOOP
				p_customer_tbl(i).customer_id 		:= l_customer_tbl(i).customer_id;
				p_customer_tbl(i).customer_number := l_customer_tbl(i).customer_number;
				p_customer_tbl(i).customer_name 	:= l_customer_tbl(i).customer_name;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Get_Customer');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Get_Customer;

PROCEDURE Get_Product(
	  p_item_tbl	     	IN OUT NOCOPY item_tbl_type
  	,p_org_id    IN    NUMBER
	 ,x_rec_count		OUT NOCOPY NUMBER
   	,x_return_status	OUT NOCOPY	  VARCHAR2
)
IS

    l_item_tbl   					DPP_UTILITY_PVT.item_tbl_type;
BEGIN

   FOR i IN p_item_tbl.FIRST..p_item_tbl.LAST LOOP
				l_item_tbl(i).inventory_item_id 	:= p_item_tbl(i).inventory_item_id;
   END LOOP;

   		DPP_UTILITY_PVT.Get_Product(
	 			  p_item_tbl		 					=> l_item_tbl
				 ,p_org_id                                                      => p_org_id
	 			 ,x_rec_count							=> x_rec_count
	 			 ,x_return_status 				=> x_return_status
	 			 );

   FOR i IN l_item_tbl.FIRST..l_item_tbl.LAST LOOP
				p_item_tbl(i).inventory_item_id := l_item_tbl(i).inventory_item_id;
				p_item_tbl(i).item_number 			:= l_item_tbl(i).item_number;
				p_item_tbl(i).description 			:= l_item_tbl(i).description;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Get_Product');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Get_Product;
--- for AME

PROCEDURE Get_AllApprovers(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER

   ,p_approval_rec        IN  approval_rec_type
   ,p_approversOut        OUT NOCOPY approversTable
)
IS
l_approversOut   		DPP_APPROVAL_PVT.approversTable;
l_approval_rec  		DPP_APPROVAL_PVT.approval_rec_type;
BEGIN
   l_approval_rec.object_type 	        := p_approval_rec.object_type;
   l_approval_rec.object_id 	        := p_approval_rec.object_id;
   l_approval_rec.status_code 	        := p_approval_rec.status_code;
   l_approval_rec.action_code 		:= p_approval_rec.action_code;
   l_approval_rec.action_performed_by 	:= p_approval_rec.action_performed_by;
   DPP_APPROVAL_PVT.Get_AllApprovers(p_api_version       => p_api_version
                                    ,p_init_msg_list     => p_init_msg_list
                                    ,p_validation_level  => p_validation_level
                                    ,x_return_status     => x_return_status
                                    ,x_msg_data          => x_msg_data
                                    ,x_msg_count         => x_msg_count
                                    ,p_approval_rec      => l_approval_rec
                                    ,p_approversOut      => l_approversOut
                                    );
  IF l_approversOut.COUNT > 0  THEN
     FOR i IN l_approversOut.FIRST..l_approversOut.LAST LOOP
       p_approversOut(i).user_id 	     := l_approversOut(i).user_id;
       p_approversOut(i).person_id 	     := l_approversOut(i).person_id;
       p_approversOut(i).first_name 	     := l_approversOut(i).first_name;
       p_approversOut(i).last_name 	     := l_approversOut(i).last_name;
       p_approversOut(i).api_insertion        := l_approversOut(i).api_insertion;
       p_approversOut(i).authority 		:= l_approversOut(i).authority;
       p_approversOut(i).approval_status 		:= l_approversOut(i).approval_status;
       p_approversOut(i).approval_type_id 		:= l_approversOut(i).approval_type_id;
       p_approversOut(i).group_or_chain_id 	:= l_approversOut(i).group_or_chain_id;
       p_approversOut(i).occurrence 		:= l_approversOut(i).occurrence;
       p_approversOut(i).source 				:= l_approversOut(i).source;
       p_approversOut(i).approver_email := l_approversOut(i).approver_email;
       p_approversOut(i).approver_group_name := l_approversOut(i).approver_group_name;
       p_approversOut(i).approver_sequence := l_approversOut(i).approver_sequence;
     END LOOP;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Get_AllApprovers');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Get_AllApprovers;

PROCEDURE  Process_User_Action (
   p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

  ,x_return_status          OUT NOCOPY   VARCHAR2
  ,x_msg_data               OUT NOCOPY   VARCHAR2
  ,x_msg_count              OUT NOCOPY   NUMBER

  ,p_approval_rec           IN  approval_rec_type
  ,p_approver_id            IN  NUMBER
  ,x_final_approval_flag    OUT NOCOPY VARCHAR2
)
IS

   l_approval_rec  		DPP_APPROVAL_PVT.approval_rec_type;

BEGIN

   l_approval_rec.object_type 					:= p_approval_rec.object_type;
   l_approval_rec.object_id 						:= p_approval_rec.object_id;
   l_approval_rec.status_code 					:= p_approval_rec.status_code;
   l_approval_rec.action_code 					:= p_approval_rec.action_code;
   l_approval_rec.action_performed_by 	:= p_approval_rec.action_performed_by;

 		DPP_APPROVAL_PVT.Process_User_Action(
				p_api_version       => p_api_version
			 ,p_init_msg_list     => p_init_msg_list
			 ,p_validation_level  => p_validation_level
			 ,x_return_status     => x_return_status
			 ,x_msg_data          => x_msg_data
			 ,x_msg_count         => x_msg_count
			 ,p_approval_rec      => l_approval_rec
  		 ,p_approver_id       => p_approver_id
  		 ,x_final_approval_flag => x_final_approval_flag
	 		 );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Process_User_Action');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Process_User_Action;

PROCEDURE Raise_Business_Event(
	 p_api_version   	 IN 	        NUMBER
  	,p_init_msg_list	 IN 	        VARCHAR2     := FND_API.G_FALSE
   	,p_commit	         IN 	        VARCHAR2     := FND_API.G_FALSE
   	,p_validation_level	 IN 	        NUMBER       := FND_API.G_VALID_LEVEL_FULL

   	,x_return_status	 OUT NOCOPY     VARCHAR2
        ,x_msg_count	         OUT NOCOPY     NUMBER
        ,x_msg_data	         OUT NOCOPY     VARCHAR2

   	,p_txn_hdr_rec           IN       dpp_txn_hdr_rec_type
        ,p_txn_line_id           IN       dpp_txn_line_tbl_type
     )
IS
l_txn_hdr_rec  DPP_BUSINESSEVENTS_PVT.dpp_txn_hdr_rec_type;
l_txn_line_id  DPP_BUSINESSEVENTS_PVT.dpp_txn_line_tbl_type;
BEGIN

   l_txn_hdr_rec.Transaction_Header_ID := p_txn_hdr_rec.Transaction_Header_ID;
   l_txn_hdr_rec.Transaction_number := p_txn_hdr_rec.Transaction_number;
   l_txn_hdr_rec.Process_code := p_txn_hdr_rec.Process_code;
   l_txn_hdr_rec.claim_id := p_txn_hdr_rec.claim_id;
   l_txn_hdr_rec.claim_type_flag := p_txn_hdr_rec.claim_type_flag;
   l_txn_hdr_rec.claim_creation_source := p_txn_hdr_rec.claim_creation_source;

   FOR i IN p_txn_line_id.FIRST..p_txn_line_id.LAST LOOP
      l_txn_line_id(i) := p_txn_line_id(i);
   END LOOP;

  --Raise business event for updating the on hand inventory
          DPP_BUSINESSEVENTS_PVT.Raise_Business_Event( p_api_version         =>    p_api_version
                                                      ,p_init_msg_list	     =>    p_init_msg_list
                                                      ,p_commit	             =>    p_commit
                                                      ,p_validation_level    =>    p_validation_level
                                                      ,x_return_status	     =>    x_return_status
                                                      ,x_msg_count	     =>    x_msg_count
                                                      ,x_msg_data	     =>    x_msg_data
                                                      ,p_txn_hdr_rec         =>    l_txn_hdr_rec
                                                      ,p_txn_line_id         =>    l_txn_line_id
                                                      );
EXCEPTION
WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.Raise_Business_Event');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
      END IF;
END Raise_Business_Event;

PROCEDURE convert_currency(
   p_from_currency   IN       VARCHAR2
  ,p_to_currency     IN       VARCHAR2
  ,p_conv_type       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  ,p_conv_rate       IN       NUMBER   DEFAULT FND_API.G_MISS_NUM
  ,p_conv_date       IN       DATE     DEFAULT SYSDATE
  ,p_from_amount     IN       NUMBER
  ,x_return_status   OUT NOCOPY      VARCHAR2
  ,x_to_amount       OUT NOCOPY      NUMBER
  ,x_rate            OUT NOCOPY      NUMBER
  )
IS
BEGIN
--Clearing the msg stack and Initialize the message stack.
  fnd_message.clear();
  FND_MSG_PUB.initialize;
--Call Dpp_utility_pvt.convert_currency
DPP_UTILITY_PVT.convert_currency(p_from_currency => p_from_currency
                                ,p_to_currency => p_to_currency
                                ,p_conv_type  =>      FND_API.G_MISS_CHAR
                                ,p_conv_rate   =>      FND_API.G_MISS_NUM
                                ,p_conv_date   =>      sysdate
                                ,p_from_amount   =>      p_from_amount
                                ,x_return_status   =>      x_return_status
                                ,x_to_amount   =>      x_to_amount
                                ,x_rate   =>      x_rate);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_UIWRAPPER_PVT.convert_currency');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
      END IF;

END convert_currency;

END DPP_UIWRAPPER_PVT;

/
