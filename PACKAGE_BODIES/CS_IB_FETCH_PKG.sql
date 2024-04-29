--------------------------------------------------------
--  DDL for Package Body CS_IB_FETCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_IB_FETCH_PKG" as
/* $Header: csifetb.pls 115.27 2003/12/03 19:00:00 spariti ship $ */


procedure getContactTypes( x_contacttypes OUT contact_type_info_csr_type ) is
begin

  null;

end;

/* Added by arajagop for CSI implemenation */
procedure getSystems(customer_id_in in number ,
                     csi_enabled in varchar2,
                     user_id in number,
                     x_systeminfo OUT system_info_csr_type ) is

BEGIN

  null;

END;


procedure getSystems(customer_id_in in number ,
                        x_systeminfo OUT system_info_csr_type ) is

begin
  null;

end;


procedure getConfigTypes(x_configtype_info OUT config_type_info_csr_type) is
begin

  null;

end;

procedure getContracts(product_id IN  number,
                       listOfContracts  OUT varchar2
                      ) is

begin
  null;

end;


procedure getNotes(productId in number,
                   x_notestype OUT notes_info_csr_type) is
begin
  null;

end;

/**
 * Added by Xiangyang Li(xili) for CSI Handling
 * - 12/28/2000
 */
procedure getproduct( product_id in number,
                        customer_id in number,
                        user_id in number,
                        csi_enabled in varchar2,
                        x_proddetail OUT product_info_csr_type,
                        x_contactinfo OUT contacts_info_csr_type,
                        x_statusinfo OUT status_info_csr_type,
                        x_contacttypes OUT contact_type_info_csr_type,
                        x_notestype OUT notes_info_csr_type,
                        x_configtype_info OUT config_type_info_csr_type,
                        x_systeminfo OUT system_info_csr_type,
                        x_unit_of_measure OUT varchar2,
                        x_contracts OUT varchar2 ) is
begin
  null;

end;


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
                        x_contracts OUT varchar2 ) is

begin
  null;
end;

procedure getAddressList(x_address  OUT address_info_csr_type)  is
begin
  null;

end;

procedure getStatusList(x_status OUT status_info_csr_type)  is
begin
  null;

end;


procedure getRevisionList(inv_item_id in number ,
                           x_revisioninfo OUT revision_info_csr_type) is
begin
  null;

end;

procedure getUnitOfMeasures(invItemId  number,
                              x_uominfo OUT uom_info_csr_type) is
begin
  null;

end;

procedure getProductTypes(x_product_type_info OUT product_type_info_csr_type) is
begin

  null;

end;



procedure getProductInfo(product_id in number,
                        x_productinfo OUT product_info_csr_type) is
begin

  null;

end;


procedure getPatches(product_id in number,
                     inventory_item in number,
                     x_patch_products out product_info_csr_type ) is
begin
  null;

end;

/****** arajagop : Added for CSI implementaion **/
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
                              x_configtype_info OUT config_type_info_csr_type) is
BEGIN

  null;

END;

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
                              x_configtype_info OUT config_type_info_csr_type) is
BEGIN

  null;

END;

procedure getSearchProductScreenInfo(customer_id in HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%type,
                                     x_party_name out HZ_PARTIES.PARTY_NAME%type,
                                     x_product_type_info OUT product_type_info_csr_type,
                                        x_systeminfo OUT system_info_csr_type,
                                     x_status out status_info_csr_type) is
begin

  null;

end;

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
                                     x_status out status_info_csr_type) is
begin

  null;

end;

procedure getDownLoadStatus(x_status OUT status_info_csr_type) is

begin

  null;

end;


procedure getPatchChildren(product_id in number,
                           x_proddetail OUT product_info_csr_type ) is

begin

  null;

end;

procedure getPatchInventoryId(x_inventory_item_id out number ) is

begin

  null;

end;

end cs_ib_fetch_pkg;


/
