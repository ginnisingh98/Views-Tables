--------------------------------------------------------
--  DDL for Package WSH_SUPPLIER_PARTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SUPPLIER_PARTY" AUTHID CURRENT_USER as
/*$Header: WSHSUPRS.pls 120.2.12010000.1 2008/07/29 06:18:55 appldev ship $ */

-- Start of comments
-- API name : Process_Address
-- Type     : Public
-- Pre-reqs : None.
-- Procedure : API to Create/Update address line information of Supplier Address book. Api does.
--            1.Validate the action code.
--            2.Check if Address information is already exists for Shipping Code
--              and Supplier.
--            3.If address information is exist,validate that action code
--              should not be insert 'I'. Than call api Update_address to update
--              address information.
--            4.If address information is not exists ,validate that
--              action code should not be update 'U'. Than call api
--              Create_address to update address information.
--
-- Parameters :
-- IN:
--      p_in_param      IN  Hold additional parameter as passed by UI.
--      p_Address       IN  Hold Supplier Address book record as passed by UI
-- OUT:
--      x_success_tbl   OUT NOCOPY List of Success messages passed back to UI for display.
--      x_error_tbl     OUT NOCOPY List of Error messages passed back to UI for display.
--      x_return_status OUT NOCOPY Standard to output api status.
-- End of comments
PROCEDURE Process_Address(
	p_in_param		IN 	WSH_ROUTING_REQUEST.In_param_Rec_Type,
        p_Address      		IN	WSH_ROUTING_REQUEST.Address_rec_type,
        x_success_tbl  		IN OUT NOCOPY WSH_FILE_MSG_TABLE,
        x_error_tbl  		IN OUT NOCOPY WSH_ROUTING_REQUEST.tbl_var2000,
        x_return_status		IN OUT NOCOPY varchar2);


-- Start of comments
-- API name : Create_Address
-- Type     : Public
-- Pre-reqs : None.
-- Procedure : API to create address information. Api does
--            1.Create location and party site.
--            2.Validate location.
--            3.Create Party Site Uses.
--            4.Create contact information.
-- Parameters :
-- IN:
--        p_location_code               IN      Location Code.
--        P_party_id                    IN      Party Id.
--        P_address1                    IN      Address1.
--        P_address2                    IN      Address2.
--        P_address3                    IN      Address3.
--        P_address4                    IN      Address4.
--        P_city                        IN      City.
--        P_postal_code                 IN      Postal Code.
--        P_state                       IN      State.
--        P_Province                    IN      Province.
--        P_county                      IN      County.
--        p_country                     IN      Country.
--        p_shipper_name                IN      Shipper Name
--        p_phone                       IN      Phone Number.
--        p_email                       IN      Email Address.
-- OUT:
--      x_location_id                   OUT NOCOPY Location id create.
--      x_party_site_id                 OUT NOCOPY Party Site id created.
--      x_return_status OUT NOCOPY      OUT NOCOPY Standard to output api status.
-- End of comments
PROCEDURE Create_Address(
        P_vendor_id                     IN      number,
        P_party_id                     IN      number,
        P_location_code                 IN      varchar2,
        P_address1                      IN      varchar2,
        P_address2                      IN      varchar2,
        P_address3                      IN      varchar2,
        P_address4                      IN      varchar2,
        P_city                          IN      varchar2,
        P_postal_code                   IN      varchar2,
        P_state                         IN      varchar2,
        P_Province                      IN      varchar2,
        P_county                        IN      varchar2,
        p_country                       IN      varchar2,
        p_shipper_name                  IN      varchar2,
        p_phone                         IN      varchar2,
        p_email                         IN      varchar2,
        x_location_id                   OUT NOCOPY number,
        x_party_site_id                 OUT NOCOPY number,
        x_return_status                 OUT NOCOPY varchar2);


-- Start of comments
-- API name : Update_Address
-- Type     : Public
-- Pre-reqs : None.
-- Procedure : API to update address information. This wrapper api
--             calls api to update location and contact information.
-- Parameters :
-- IN:
--        p_location_code               IN      Location Code.
--        P_party_id                    IN      Party Id.
--        P_address1                    IN      Address1.
--        P_address2                    IN      Address2.
--        P_address3                    IN      Address3.
--        P_address4                    IN      Address4.
--        P_city                        IN      City.
--        P_postal_code                 IN      Postal Code.
--        P_state                       IN      State.
--        P_Province                    IN      Province.
--        P_county                      IN      County.
--        p_country                     IN      Country.
--        p_shipper_name                IN      Shipper Name
--        p_phone                       IN      Phone Number.
--        p_email                       IN      Email Address.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Update_Address(
        P_location_id                   IN      number,
        P_party_id                     IN      number,
        P_party_site_id                 IN      number,
        P_address1                      IN      varchar2,
        P_address2                      IN      varchar2,
        P_address3                      IN      varchar2,
        P_address4                      IN      varchar2,
        P_city                          IN      varchar2,
        P_postal_code                   IN      varchar2,
        P_state                         IN      varchar2,
        P_Province                      IN      varchar2,
        P_county                        IN      varchar2,
        p_country                       IN      varchar2,
        p_shipper_name                  IN      varchar2,
        p_phone                         IN      varchar2,
        p_email                         IN      varchar2,
        x_return_status                 OUT NOCOPY varchar2);


-- Start of comments
-- API name : Validate_Supplier
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to Create/Validate Supplier. Api does
--            1. Check for mandatory parameters.
--            2. Validate the ISP user.
--            3. Validate Vendor.
--            4. Check for Party exist for vendor, if not create one.
-- Parameters :
-- IN:
--      p_in_param              IN  Type WSH_ROUTING_REQUEST.In_param_Rec_Type,use p_in_param.caller to get the caller.
--      P_supplier_name         IN  Supplier Name.
-- OUT:
--      x_vendor_id           vendor id.
--      x_party_id            Party Id.
--      x_return_status       Standard to output api status.
-- End of comments
PROCEDURE Validate_Supplier(
        p_in_param                      IN      WSH_ROUTING_REQUEST.In_param_Rec_Type,
        P_supplier_name                 IN      varchar2,
        x_vendor_id                     OUT NOCOPY number,
        x_party_id                      OUT NOCOPY number,
        x_return_status                 OUT NOCOPY varchar2);


-- Start of comments
-- API name : VENDOR_PARTY_EXISTS
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to find Party for a Vendor. Based on input vendor_id check
--            for existing party in hz_relationships.
-- Parameters :
-- IN:
--      p_vendor_id           Vendor Id
-- OUT:
--      x_party_id            Party Id
--      RETURN Y/N
-- End of comments
FUNCTION VENDOR_PARTY_EXISTS(
    p_vendor_id IN NUMBER,
    x_party_id  OUT NOCOPY NUMBER) RETURN VARCHAR2;


-- Start of comments
-- API name : create_vendor_party
-- Type     : Public
-- Pre-reqs : None.
-- Procedure : API to create Creates a TCA party of type Organization from a PO_VENDOR,if the party doesn't already exist.
--
-- Parameters :
-- IN:
--      Vendor_id       IN  PK for the Vendor from which the party is being created.
--      p_file_fields   IN  Hold Supplier Address book record as passed by UI
-- OUT:
--    Return_status:  Indicates outcome of function:
--       S:  Successful, party was created and committed
--       E:  Some validation failed, the party was not created
-- End of comments
FUNCTION create_vendor_party(
    p_vendor_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER;


-- Start of comments
-- API name : Create_Hz_Party_site
-- Type     : Public
-- Pre-reqs : None.
-- Procedure : API to create Hz Party Site for Party and Location. Api does
--           1.Check for mandatory field for creating Party sites.
--           2.Calls api HZ_PARTY_SITE_V2PUB.Create_Party_Site for creating Party sites.
-- Parameters :
-- IN:
--        P_party_id                    IN      Party Id.
--        P_location_id                 IN      Location id.
--        P_location_code               IN      Location Code.
-- OUT:
--        x_party_site_id OUT NOCOPY      Party Site Id.
--        x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Create_HZ_Party_Site(
        P_party_id              IN      NUMBER,
        P_location_id           IN      NUMBER,
        P_location_code         IN      VARCHAR2,
        x_party_site_id         OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2);


-- Start of comments
-- API name : Process_HZ_contact
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to Process Hz Contact for party site. Api first check if
--            contact information is already exists for party and party site. If
--            exist then update the information else create new contact.
-- Parameters :
-- IN:
--        P_party_id                      IN Party Id.
--        P_party_site_id                 IN Party Site Id.
--        P_person_name                   IN Person Name.
--        P_phone                         IN Phone Number.
--        P_email                         IN Email.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Process_HZ_contact(
  P_PARTY_ID              IN     NUMBER,
  P_PARTY_SITE_ID         IN     NUMBER,
  P_PERSON_NAME           IN     VARCHAR2,
  P_phone           IN     VARCHAR2,
  P_EMAIL            IN     VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2 );



-- Start of comments
-- API name : Create_Hz_Party_site_Uses
-- Type     : Public
-- Pre-reqs : None.
-- Procedure : API to create Hz Party Site uses for Party Site and Uses Type.
--             (a) First check if party site uses exist in TCA
--             (b) If not, create it
--             (c) Return the party_site_use_id.
-- Parameters :
-- IN:
--      P_party_site_id      IN  Party Site Id.
--      P_site_use_type      IN  Site uses type.
-- OUT:
--      x_party_site_use_id OUT NOCOPY      Party site use Id created.
--      x_return_status     OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Create_HZ_Party_Site_uses(
        P_party_site_id         IN      NUMBER,
        P_site_use_type         IN      VARCHAR2,
        x_party_site_use_id     OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2);


END WSH_SUPPLIER_PARTY;

/
