--------------------------------------------------------
--  DDL for Package CS_IB_FETCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_IB_FETCH_PKG" AUTHID CURRENT_USER as
/* $Header: csifets.pls 115.20 2003/12/03 19:00:15 spariti ship $ */
type product_info_csr_type  is REF CURSOR;
type contacts_info_csr_type is REF CURSOR;
type status_info_csr_type   is REF CURSOR;

type address_info_csr_type  is REF CURSOR;

type contact_type_info_csr_type is REF CURSOR;

type account_info_csr_tpye is REF CURSOR;
type notes_info_csr_type is REF CURSOR;

type revision_info_csr_type is REF CURSOR;
type uom_info_csr_type is REF CURSOR;
type product_type_info_csr_type is REF CURSOR;
type system_info_csr_type is REF CURSOR;
type config_type_info_csr_type is REF CURSOR;

procedure getContactTypes( x_contacttypes OUT contact_type_info_csr_type );

procedure getproduct( product_id in number,
			customer_id in number,
			x_proddetail OUT product_info_csr_type,
			x_contactinfo OUT contacts_info_csr_type,
			x_statusinfo OUT status_info_csr_type,
			x_contacttypes OUT contact_type_info_csr_type,
			x_notestype OUT notes_info_csr_type,
			x_configtype_info OUT config_type_info_csr_type,
			x_systeminfo OUT system_info_csr_type,
			x_unit_of_measure OUT varchar2,
			x_contracts OUT varchar2);

/**
 * Added by Xiangyang Li(xili) for CSI Handling
 * - 12/28/2000
 */
procedure getproduct( product_id in number,
			customer_id in number,
			user_id in number,
			csi_enabled in varchar2 DEFAULT FND_API.G_FALSE,
			x_proddetail OUT product_info_csr_type,
			x_contactinfo OUT contacts_info_csr_type,
			x_statusinfo OUT status_info_csr_type,
			x_contacttypes OUT contact_type_info_csr_type,
			x_notestype OUT notes_info_csr_type,
			x_configtype_info OUT config_type_info_csr_type,
			x_systeminfo OUT system_info_csr_type,
			x_unit_of_measure OUT varchar2,
			x_contracts OUT varchar2);

procedure getContracts(product_id IN  number,
                       listOfContracts  OUT varchar2 );

procedure getAddressList(x_address  OUT address_info_csr_type );

procedure getStatusList(x_status OUT status_info_csr_type);

procedure getProductHierarchy(product_id in number,
			      parent_id  in number,
			      root_id    in number,
			      inv_item_id in number,
			      customer_id in number,
			      x_prodinfo OUT product_info_csr_type,
			      x_parentinfo OUT product_info_csr_type,
			      x_rootinfo  OUT  product_info_csr_type,
			      x_statusinfo OUT status_info_csr_type,
			      x_contacttypes OUT contact_type_info_csr_type,
			      x_revisioninfo OUT revision_info_csr_type,
			      x_uominfo OUT uom_info_csr_type,
			      x_product_type_info OUT product_type_info_csr_type,
			      x_systeminfo OUT system_info_csr_type,
			      x_configtype_info OUT config_type_info_csr_type);

procedure getProductHierarchy(product_id in number,
			      parent_id  in number,
			      root_id    in number,
			      inv_item_id in number,
			      customer_id in number,
                              csi_enabled in varchar2 DEFAULT FND_API.G_FALSE,
                              user_id in number,
			      x_prodinfo OUT product_info_csr_type,
			      x_parentinfo OUT product_info_csr_type,
			      x_rootinfo  OUT  product_info_csr_type,
			      x_statusinfo OUT status_info_csr_type,
			      x_contacttypes OUT contact_type_info_csr_type,
			      x_revisioninfo OUT revision_info_csr_type,
			      x_uominfo OUT uom_info_csr_type,
			      x_product_type_info OUT product_type_info_csr_type,
			      x_systeminfo OUT system_info_csr_type,
			      x_configtype_info OUT config_type_info_csr_type);


procedure getSearchProductScreenInfo(customer_id in HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%type,
				     x_party_name out HZ_PARTIES.PARTY_NAME%type,
				     x_product_type_info OUT product_type_info_csr_type,
					x_systeminfo OUT system_info_csr_type,
				     x_status out status_info_csr_type);

/**
 * Added by Xiangyang Li(xili) for CSI Handling
 * - 12/28/2000
 */
procedure getSearchProductScreenInfo(customer_id in HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%type,
			         user_id in number,
			         csi_enabled in varchar2 DEFAULT FND_API.G_FALSE,
				     x_party_name out HZ_PARTIES.PARTY_NAME%type,
				     x_product_type_info OUT product_type_info_csr_type,
					x_systeminfo OUT system_info_csr_type,
				     x_status out status_info_csr_type);

procedure getNotes(productId in number,
		   x_notestype OUT notes_info_csr_type);

procedure getDownLoadStatus(x_status OUT status_info_csr_type);

procedure getPatchChildren(product_id in number,
			   x_proddetail OUT product_info_csr_type );

procedure getPatchInventoryId(x_inventory_item_id out number );

end cs_ib_fetch_pkg;


 

/
