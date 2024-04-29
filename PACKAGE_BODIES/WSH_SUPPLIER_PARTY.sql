--------------------------------------------------------
--  DDL for Package Body WSH_SUPPLIER_PARTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SUPPLIER_PARTY" as
/*$Header: WSHSUPRB.pls 120.7.12010000.2 2008/09/18 08:58:17 sankarun ship $ */


G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SUPPLIER_PARTY';

--Global pl/sql table to store translated message from FND stack.
g_error_tbl		WSH_ROUTING_REQUEST.tbl_var2000;

--Line number of Supplier Address Book.
g_line_number		NUMBER;

--Constant to be used for calls made to TCA APIs
C_CREATED_BY_MODULE         CONSTANT VARCHAR2(30) := 'WSH';

-- Start of comments
-- API name : Check_Hz_Location
-- Type     : Private
-- Pre-reqs : None.
-- Function : API to check if location exist for given party in TCA. Api does
--            1.For location code and party_id search record in hz_location,
--              if found api returns true and else false.
-- Parameters :
-- IN:
--        p_location_code 		IN      Location Code.
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
-- OUT:
--        x_location_id                         Location Id
--        x_party_site_id                       Party Site Id.
-- End of comments
FUNCTION Check_Hz_Location(
        p_location_code 		IN      varchar2,
        P_party_id                      IN      number,
        P_address1                      IN      varchar2,
        P_address2                      IN      varchar2,
        P_address3                      IN      varchar2,
        P_address4                      IN      varchar2,
        P_city                          IN      varchar2,
        P_postal_code                   IN      varchar2,
        P_state                         IN      varchar2,
        P_Province                     IN      varchar2,
        P_county                        IN      varchar2,
        p_country                       IN      varchar2,
        x_location_id                   OUT NOCOPY number,
        x_party_site_id                   OUT NOCOPY number) RETURN BOOLEAN IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Hz_Location';

--Cursor to find, if location information is exists for location code
--of given party.
CURSOR Check_location_csr IS
    SELECT 	hl.location_id , hps.party_site_id
    FROM	hz_locations hl,
		hz_party_sites hps
    WHERE        hl.country =p_country
    AND          hl.address1 =p_address1
    AND          hl.address2 = decode(p_address2,NULL,hl.address2,p_address2)
    AND          hl.address3 = decode(p_address3,NULL,hl.address3,p_address3)
    AND          hl.address4 = decode(p_address4,NULL,hl.address4,p_address4)
    AND          hl.city = decode(p_city, NULL, hl.city,p_city)
    AND          hl.postal_code = decode(p_postal_code, NULL, hl.postal_code,p_postal_code)
    AND          hl.state = decode(p_state, NULL, hl.state,p_state)
    AND          hl.Province = decode(p_Province, NULL, hl.Province,p_Province)
    AND          hl.county = decode(p_county, NULL, hl.county,p_county)
    AND          hl.location_id = hps.location_id
    AND          hps.party_id = p_party_id
    AND          hps.party_site_number=p_location_code;

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_location_code',p_location_code);
      WSH_DEBUG_SV.log(l_module_name,'P_party_id',P_party_id);
      WSH_DEBUG_SV.log(l_module_name,'P_address1',P_address1);
      WSH_DEBUG_SV.log(l_module_name,'P_address2',P_address2);
      WSH_DEBUG_SV.log(l_module_name,'P_address3',P_address3);
      WSH_DEBUG_SV.log(l_module_name,'P_address4',P_address4);
      WSH_DEBUG_SV.log(l_module_name,'P_city',P_city);
      WSH_DEBUG_SV.log(l_module_name,'P_postal_code',P_postal_code);
      WSH_DEBUG_SV.log(l_module_name,'P_state',P_state);
      WSH_DEBUG_SV.log(l_module_name,'P_Province',P_Province);
      WSH_DEBUG_SV.log(l_module_name,'P_county',P_county);
      WSH_DEBUG_SV.log(l_module_name,'p_country',p_country);
 END IF;

 --Cursor to check for existing location information.
 OPEN Check_location_csr;
 FETCH Check_location_csr INTO x_location_id,x_party_site_id;

 IF (Check_location_csr%NOTFOUND ) THEN
    CLOSE Check_location_csr;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'RETURN false');
    END IF;
    RETURN false;
 END IF;

 CLOSE Check_location_csr;


 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'RETURN true');
 END IF;
 RETURN true;

EXCEPTION
 WHEN OTHERS THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
     RETURN false;

END Check_Hz_Location;


-- Start of comments
-- API name : Create_Hz_Party_site
-- Type     : Private
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
        x_return_status         OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_HZ_Party_Site';

l_return_status		varchar2(1);
l_msg_count		NUMBER;
l_msg_data		varchar2(2000);
l_party_site_number	varchar2(30);
l_site_rec                 HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
l_num_warnings          number;
l_num_errors            number;

-- Bug 7391414 Setting the profile option 'HZ GENERATE PARTY NUMBER' to Yes if it is No or Null
  l_hz_profile_option        varchar2(2);
  l_hz_profile_set           boolean;

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_party_id',P_party_id);
      WSH_DEBUG_SV.log(l_module_name,'P_location_id',P_location_id);
      WSH_DEBUG_SV.log(l_module_name,'P_location_code',P_location_code);
 END IF;

 IF (P_party_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','P_party_id');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF (P_location_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','P_location_id');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF (P_location_code IS NULL ) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','P_location_code');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 --Assign the party and location information to input parameter of below HZ api.
 l_site_rec.party_id          	:= p_party_id;
 l_site_rec.location_id       	:= p_location_id;
 l_site_rec.status              := 'A'; --Active
 l_site_rec.party_site_number 	:= p_location_code;
 l_site_rec.created_by_module 	:= C_CREATED_BY_MODULE;

 -- Bug 7391414 Setting the profile option 'HZ GENERATE PARTY NUMBER' to Yes if it is No or Null
    l_hz_profile_set := false;
    l_hz_profile_option := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');

    IF (l_hz_profile_option = 'Y' or l_hz_profile_option is null ) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Setting profile option  HZ_GENERATE_PARTY_SITE_NUMBER to No');
        END IF;
	 --Since location code is used as party site number.
        fnd_profile.put('HZ_GENERATE_PARTY_SITE_NUMBER','N');
        l_hz_profile_set := true;
    END IF;

 HZ_PARTY_SITE_V2PUB.Create_Party_Site (
               p_init_msg_list     => FND_API.g_false,
               p_party_site_rec    => l_site_rec,
               x_party_site_id     => x_party_site_id,
               x_party_site_number => l_party_site_number,
               x_return_status     => l_return_status,
               x_msg_count         => l_msg_count,
               x_msg_data          => l_msg_data);

 -- Bug 7391414 Setting the profile option 'HZ GENERATE PARTY NUMBER'  to previous value
	IF l_hz_profile_set THEN
	    IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,'Reverting the value of profile option HZ_GENERATE_PARTY_SITE_NUMBER');
	     END IF;
	    fnd_profile.put('HZ_GENERATE_PARTY_SITE_NUMBER',l_hz_profile_option);
	END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'HZ_PARTY_SITE_V2PUB.Create_Party_Site l_return_status',l_return_status);
    WSH_DEBUG_SV.log(l_module_name,'x_party_site_id',x_party_site_id);
    WSH_DEBUG_SV.log(l_module_name,'l_party_site_number',l_party_site_number);
 END IF;
 wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

 IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count: '||l_msg_count,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_data: '||l_msg_data,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
END Create_HZ_Party_Site;


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
    x_party_id  OUT NOCOPY NUMBER) RETURN VARCHAR2  -- Y for Yes, N for No
IS
CURSOR get_vendor_name IS
  SELECT pv.vendor_name
  FROM  po_vendors pv
  WHERE pv.vendor_id = p_vendor_id;

l_vendor_name  varchar2(400);

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VENDOR_PARTY_EXISTS';
BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_vendor_id',p_vendor_id);
 END IF;

 --IB-Phase-2 {

 SELECT PARTY_ID INTO x_party_id
 FROM PO_VENDORS
 WHERE VENDOR_ID = p_vendor_id;

--

 IF x_party_id IS NULL
 THEN
    OPEN get_vendor_name;
    FETCH get_vendor_name INTO l_vendor_name;
    CLOSE get_vendor_name;

    FND_MESSAGE.SET_NAME('WSH','WSH_SUPPLIER_NO_PARTY');
    FND_MESSAGE.SET_TOKEN('SUPPLIER_NAME',l_vendor_name);
    fnd_msg_pub.add;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN 'N';
 END IF;
 --}IB-Phase-2

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;
 RETURN 'Y';

EXCEPTION
 WHEN NO_DATA_FOUND THEN
     -- { IB-Phase-2
     FND_MESSAGE.SET_NAME('WSH','WSH_SUPPLIER_NO_PARTY');
     fnd_msg_pub.add;
     -- } IB-Phase-2
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

     RETURN 'N';

 WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
    RETURN 'N';

END vendor_party_exists;


-- Start of comments
-- THIS API WILL NOT BE USED BY R12 CODE, SINCE PARTY CREATION WILL NOW NOT BE INITIATED BY WSH.
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
--    x_party_id	OUT NUMBER,
    x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER
IS

CURSOR get_vendor_name IS
  SELECT pv.vendor_name
  FROM  po_vendors pv
  WHERE pv.vendor_id = p_vendor_id;

  --Cursor to check if code assignment is already exist for party.
  CURSOR get_code_assignments(p_party_id NUMBER) IS
    SELECT  'X'
    FROM hz_code_assignments
    WHERE owner_table_name = 'HZ_PARTIES'
    AND owner_table_id = p_party_id
    AND class_category = 'POS_CLASSIFICATION'
    AND class_code = 'PROCUREMENT_ORGANIZATION'
    AND status = 'A'
    AND (end_date_active IS NULL OR end_date_active > SYSDATE);

    l_vendor_name   VARCHAR2(255);

    l_party_rel_rec			HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
    l_org_rec                 hz_party_v2pub.organization_rec_type;
    l_ocon_rec                 HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
    l_code_assignment_rec     hz_classification_v2pub.code_assignment_rec_type;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(3000);
    exception_message     VARCHAR2(3000);
    l_code_assignment_id    NUMBER;

    l_status_class      VARCHAR2(10);
    l_return_status      VARCHAR2(10);
    l_party_number  NUMBER;
    l_profile_id        NUMBER;
  l_tmp		varchar2(1);
  l_party_relationship_id    number;
  l_contact_point_id         number;
  l_org_contact_id           number;
  l_party_id                 number;
  l_rel_party_id                 number;


  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'create_vendor_party';
l_num_warnings          number;
l_num_errors            number;
BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_vendor_id',p_vendor_id);
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 IF (VENDOR_PARTY_EXISTS(p_vendor_id,l_party_id) <> 'Y' ) THEN --{

    --Create only, if Party does not already exists.

    --Validate vendor
    OPEN get_vendor_name;
    FETCH get_vendor_name INTO l_vendor_name;

    IF (get_vendor_name%NOTFOUND ) THEN
       CLOSE get_vendor_name;
       raise FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_vendor_name;

    l_org_rec.organization_name := l_vendor_name;
    l_org_rec.created_by_module := C_CREATED_BY_MODULE;
    l_org_rec.party_rec.status := 'A';

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling HZ_PARTY_V2PUB.Create_Organization');
       WSH_DEBUG_SV.log(l_module_name,'l_org_rec.organization_name',l_org_rec.organization_name);
       WSH_DEBUG_SV.log(l_module_name,'l_org_rec.created_by_module',l_org_rec.created_by_module);
       WSH_DEBUG_SV.log(l_module_name,'l_org_rec.party_rec.status',l_org_rec.party_rec.status);
    END IF;

    --Party is created as Organization in TCA.
    HZ_PARTY_V2PUB.Create_Organization
           (
             p_init_msg_list     => FND_API.g_false,
             p_organization_rec  => l_org_rec,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data,
             x_party_id          => l_party_id,
             x_party_number      => l_party_number,
             x_profile_id        => l_profile_id
           );

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'After HZ_PARTY_V2PUB.Create_Organization l_return_status',l_return_status);
       WSH_DEBUG_SV.log(l_module_name,'x_party_id',l_party_id);
       WSH_DEBUG_SV.log(l_module_name,'l_party_number',l_party_number);
       WSH_DEBUG_SV.log(l_module_name,'l_profile_id',l_profile_id);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);


      --Need to create relationship between Vendor and Party.
      --Relationship type define as 'POS_VENDOR_PARTY', Subject as Party and
      --Object as Vendor, since relationship code used is 'PARTY_OF_VENDOR'
      l_party_rel_rec.subject_id               := l_party_id;
      l_party_rel_rec.subject_table_name       := 'HZ_PARTIES';
      l_party_rel_rec.subject_type             := 'ORGANIZATION';

      l_party_rel_rec.object_id                := p_vendor_id;
      l_party_rel_rec.object_table_name        := 'PO_VENDORS';
      l_party_rel_rec.object_type              := 'POS_VENDOR';

      l_party_rel_rec.relationship_code        := 'PARTY_OF_VENDOR';
      l_party_rel_rec.relationship_type        := 'POS_VENDOR_PARTY';

      l_party_rel_rec.status                   := 'A';
      l_party_rel_rec.start_date               := sysdate;
      l_party_rel_rec.created_by_module        := C_CREATED_BY_MODULE;


      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_CONTACT_V2PUB.create_org_contact');
      END IF;

      HZ_RELATIONSHIP_V2PUB.create_relationship(
             --p_init_msg_list     => FND_API.g_false,
             p_relationship_rec                  => l_party_rel_rec,
             x_relationship_id                     => l_party_relationship_id,
             x_party_id                         => l_rel_party_id,
             x_party_number                     => l_party_number,
             x_return_status                    => l_return_status,
             x_msg_count                        => l_msg_count,
             x_msg_data                         => l_msg_data );

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'After create_org_contact l_return_status',l_return_status);
        WSH_DEBUG_SV.log(l_module_name,'l_party_relationship_id',l_party_relationship_id);
        WSH_DEBUG_SV.log(l_module_name,'l_party_id',l_rel_party_id);
        WSH_DEBUG_SV.log(l_module_name,'l_party_number',l_party_number);
      END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);


     --Check if code assignment is already exist for party.
     OPEN get_code_assignments(l_party_id);
     FETCH get_code_assignments INTO  l_tmp;
     CLOSE get_code_assignments;

    IF (l_tmp IS NULL ) THEN
       --No code assignment exists, create for party.
       --These input values are standard for Vendor and Party as define
       --by PO receiving team.
       l_code_assignment_rec.owner_table_name := 'HZ_PARTIES';
       l_code_assignment_rec.owner_table_id := l_party_id;
       l_code_assignment_rec.class_category := 'POS_CLASSIFICATION';
       l_code_assignment_rec.class_code := 'PROCUREMENT_ORGANIZATION';
       l_code_assignment_rec.primary_flag := 'Y';
       l_code_assignment_rec.content_source_type := 'USER_ENTERED';
       l_code_assignment_rec.start_date_active := SYSDATE;
       l_code_assignment_rec.status := 'A';
       l_code_assignment_rec.created_by_module := C_CREATED_BY_MODULE;
       l_code_assignment_rec.application_id := 177;

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling HZ_CLASSIFICATION_V2PUB.create_code_assignment');
       END IF;

       HZ_CLASSIFICATION_V2PUB.create_code_assignment(
        FND_API.G_FALSE,
        l_code_assignment_rec,
        l_return_status,
        l_msg_count,
        exception_message,
        l_code_assignment_id);

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'After create_code_assignment l_return_status',l_return_status);
          WSH_DEBUG_SV.log(l_module_name,'l_msg_count',l_msg_count);
          WSH_DEBUG_SV.log(l_module_name,'exception_message',exception_message);
          WSH_DEBUG_SV.log(l_module_name,'l_code_assignment_id',l_code_assignment_id);
       END IF;

      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
     END IF;
  END IF; --}

 IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

 RETURN l_party_id;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

     RETURN null;

 WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

    RETURN null;

END create_vendor_party;



-- Start of comments
-- API name : Update_Hz_Location
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to Update Hz location. Api first get the object_version_number
--            from hz_locations and this is passed to
--            HZ_LOCATION_V2PUB.Update_Location api along with input parameter
--            for update of location.
-- Parameters :
-- IN:
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
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Update_Hz_Location(
        P_location_id                      IN      number,
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
        x_return_status                 OUT NOCOPY varchar2) IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Update_Hz_Location';

--Get the object_version_number for the location and this again
--passed to HZ api for update.
CURSOR Get_Location_Object_Number(p_location_id NUMBER) IS
  select object_version_number
  from   hz_locations
  where  location_id = p_location_id;

  l_location_object_NUMBER   NUMBER;

l_return_status         varchar2(1);
l_msg_count             NUMBER;
l_msg_data              varchar2(2000);
l_loc_rec                  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
l_num_warnings          number;
l_num_errors            number;

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_location_id',P_location_id);
      WSH_DEBUG_SV.log(l_module_name,'P_address1',P_address1);
      WSH_DEBUG_SV.log(l_module_name,'P_address2',P_address2);
      WSH_DEBUG_SV.log(l_module_name,'P_address3',P_address3);
      WSH_DEBUG_SV.log(l_module_name,'P_address4',P_address4);
      WSH_DEBUG_SV.log(l_module_name,'P_city',P_city);
      WSH_DEBUG_SV.log(l_module_name,'P_postal_code',P_postal_code);
      WSH_DEBUG_SV.log(l_module_name,'P_state',P_state);
      WSH_DEBUG_SV.log(l_module_name,'P_Province',P_Province);
      WSH_DEBUG_SV.log(l_module_name,'P_county',P_county);
      WSH_DEBUG_SV.log(l_module_name,'p_country',p_country);
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_loc_rec.location_id         := p_location_id;
    l_loc_rec.address1          := p_address1;
    l_loc_rec.address2          := p_address2;
    l_loc_rec.address3          := p_address3;
    l_loc_rec.address4          := p_address4;
    l_loc_rec.city                   := p_city;
    l_loc_rec.state                 := p_state;
    l_loc_rec.postal_code    := p_postal_code;
    l_loc_rec.province          := p_province;
    l_loc_rec.country            := p_country;
    l_loc_rec.county            := p_county;


     --Get the object_version_number for the location and this again
     --passed to HZ api for update.
     OPEN Get_Location_Object_Number(p_location_id);
     FETCH  Get_Location_Object_Number INTO l_location_object_number;
     CLOSE Get_Location_Object_Number;

         HZ_LOCATION_V2PUB.Update_Location
          (
            p_init_msg_list          => FND_API.G_FALSE,
            p_location_rec           => l_loc_rec,
            p_object_version_number  => l_location_object_number,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data
          );

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'HZ_LOCATION_V2PUB.Update_Location l_return_status',l_return_status);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

 IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count: '||l_msg_count,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_data: '||l_msg_data,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
END Update_Hz_Location;


-- Start of comments
-- API name : Create_Hz_Location_Party_Site
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to create Hz location and party site for address information and party. Api does
--            1.Check for mandatory parameter for creating party site and location.
--            2.Checks if location exist  for party, if not then it creates location
--            and party site, otherwise return the location id and party site id.
-- Parameters :
-- IN:
--        P_party_id                    IN      Party Id.
--        p_location_code               IN      Location Code.
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
-- OUT:
--      x_location_id                   OUT NOCOPY Location Id created.
--      x_party_site_id                 OUT NOCOPY Party Site Id created.
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Create_Hz_Location_Party_Site(
        P_party_id                      IN      number,
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
        x_location_id                   OUT NOCOPY number,
        x_party_site_id                 OUT NOCOPY number,
        x_return_status                 OUT NOCOPY varchar2) IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Hz_Location_Party_Site';

l_return_status         varchar2(1);
l_msg_count             NUMBER;
l_msg_data              varchar2(2000);
l_loc_rec                  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
l_num_warnings          number;
l_num_errors            number;
BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_party_id',P_party_id);
      WSH_DEBUG_SV.log(l_module_name,'p_location_code',p_location_code);
      WSH_DEBUG_SV.log(l_module_name,'P_address1',P_address1);
      WSH_DEBUG_SV.log(l_module_name,'P_address2',P_address2);
      WSH_DEBUG_SV.log(l_module_name,'P_address3',P_address3);
      WSH_DEBUG_SV.log(l_module_name,'P_address4',P_address4);
      WSH_DEBUG_SV.log(l_module_name,'P_city',P_city);
      WSH_DEBUG_SV.log(l_module_name,'P_postal_code',P_postal_code);
      WSH_DEBUG_SV.log(l_module_name,'P_state',P_state);
      WSH_DEBUG_SV.log(l_module_name,'P_Province',P_Province);
      WSH_DEBUG_SV.log(l_module_name,'P_county',P_county);
      WSH_DEBUG_SV.log(l_module_name,'p_country',p_country);
 END IF;

 IF (P_party_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','P_party_id');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF (P_address1 IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','P_address1');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF (p_country IS NULL ) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_country');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF (p_location_code IS NULL ) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_location_code');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 --Check if location is already created for party.
 IF ( NOT check_HZ_location(
        p_location_code => p_location_code,
        p_party_id	=> p_party_id,
	P_address1	=> p_address1,
	P_address2	=> p_address2,
	P_address3	=> p_address3,
	P_address4	=> p_address4,
	P_city		=> p_city,
	P_postal_code	=> p_postal_code,
	P_state		=> p_state,
	P_province	=> p_province,
	P_county	=> p_county,
	p_country	=> p_country,
	x_location_id	=> x_location_id,
	x_party_site_id	=> x_party_site_id)
       ) THEN

    --No existing location found for party, create new one.
    l_loc_rec.address1          := p_address1;
    l_loc_rec.address2          := p_address2;
    l_loc_rec.address3          := p_address3;
    l_loc_rec.address4          := p_address4;
    l_loc_rec.city                   := p_city;
    l_loc_rec.state                 := p_state;
    l_loc_rec.postal_code    := p_postal_code;
    l_loc_rec.province          := p_province;
    l_loc_rec.country            := p_country;
    l_loc_rec.county            := p_county;
    l_loc_rec.created_by_module := C_CREATED_BY_MODULE;

    HZ_LOCATION_V2PUB.Create_Location (
             p_init_msg_list   => FND_API.G_FALSE,
             p_location_rec    => l_loc_rec,
             x_location_id     => x_location_id,
             x_return_status   => l_return_status,
             x_msg_count       => l_msg_count,
             x_msg_data        => l_msg_data);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'HZ_LOCATION_V2PUB.Create_Location l_return_status',l_return_status);
      WSH_DEBUG_SV.log(l_module_name,'x_location_id',x_location_id);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

    --Once location is created, need to make relationship between location and party.
    Create_HZ_Party_Site(
        P_party_id      	=> P_party_id,
        P_location_id           => x_location_id,
        P_location_code         => P_location_code,
        x_party_site_id         => x_party_site_id,
        x_return_status         => l_return_status);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Create_HZ_Party_Site l_return_status',l_return_status);
      WSH_DEBUG_SV.log(l_module_name,'x_party_site_id',x_party_site_id);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
 END IF;

 IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count: '||l_msg_count,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_data: '||l_msg_data,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
END Create_Hz_Location_Party_Site;


-- Start of comments
-- API name : Is_Valid_ISP_User
-- Type     : Private
-- Pre-reqs : None.
-- Function : API to validate ISP User for input Supplier.
--
-- Parameters :
-- IN:
--      p_user_id       	IN  ISP User Id.
--      p_supplier_name   	IN  Supplier Name.
-- OUT:
--      Returns Ture/False.
-- End of comments
FUNCTION Is_Valid_ISP_User(p_user_id		IN	NUMBER,
			   p_supplier_name 	IN	VARCHAR2) RETURN boolean
IS

/*
 *
 * R12 Bug 4911516 : Please see the new version of the cursor below
 *
--Cursor to validate ISP user.The value for relationship type, subject and objects
--is same as when user is created.
CURSOR get_pos_user  IS
SELECT 1
FROM   hz_relationships h2,
       hz_parties hp,
       fnd_user fu
WHERE  h2.subject_type = 'ORGANIZATION'
and 	h2.object_type = 'PERSON'
and 	h2.relationship_type = 'POS_EMPLOYMENT'
and 	h2.relationship_code = 'EMPLOYER_OF'
and 	h2.subject_table_name = 'HZ_PARTIES'
and 	h2.object_table_name = 'HZ_PARTIES'
and 	h2.status  = 'A'
and 	h2.start_date <= sysdate
and 	h2.end_date >= sysdate
and 	h2.object_id = fu.person_party_id -- IB-PHASE-2 Vendor merge
and	h2.subject_id = hp.party_id
and	hp.party_name = p_supplier_name
and     fu.user_id = p_user_id
and 	h2.subject_id IN
          (select owner_table_id
	   from hz_code_assignments
	   where owner_table_name='HZ_PARTIES'
           and status = 'A'
           and class_category ='POS_PARTICIPANT_TYPE'
           and class_code='VENDOR');
*/

--
-- R12 Bug 4911516
--
CURSOR get_pos_user IS
SELECT 1
FROM pos_supplier_users_v pos, hz_parties hz
WHERE pos.user_id = p_user_id
AND pos.vendor_party_id = hz.party_id
AND hz.party_name = p_supplier_name;
--
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Is_Valid_ISP_User';

l_status	boolean:=true;
l_tmp		number;

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_user_id',p_user_id);
    WSH_DEBUG_SV.log(l_module_name, 'p_supplier_name', p_supplier_name);
 END IF;
 --
 --Validate the ISP user.
 OPEN get_pos_user;
 FETCH get_pos_user INTO l_tmp;
 IF (get_pos_user%NOTFOUND) THEN
    l_status:= false;
 END IF;
 CLOSE get_pos_user;

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

 RETURN l_status;

EXCEPTION
 WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
    raise ;
END Is_Valid_ISP_User;


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
        p_in_param              	IN      WSH_ROUTING_REQUEST.In_param_Rec_Type,
        P_supplier_name                 IN      varchar2,
        x_vendor_id                     OUT NOCOPY number,
        x_party_id                      OUT NOCOPY number,
        x_return_status                 OUT NOCOPY varchar2) IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Supplier';
l_return_status		varchar2(1);


CURSOR validate_vendor_csr(p_vendor_name varchar2) IS
 SELECT vendor_id
 FROM   po_vendors
 WHERE  vendor_name =ltrim(rtrim(p_vendor_name))
 AND    (end_date_active IS NULL OR end_date_active >= SYSDATE);  -- IB-phase-2 vendor merge

--

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_supplier_name',P_supplier_name);
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


 --Validate the ISP user.
 IF (p_in_param.caller= 'ISP' ) THEN
    IF ( NOT Is_Valid_ISP_User(p_in_param.user_id,P_supplier_name)) THEN
       FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_INVALID_ISP_USER');
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
    END IF;
 END IF;

 --Validate Vendor
 OPEN validate_vendor_csr(p_supplier_name);
 FETCH validate_vendor_csr INTO x_vendor_id;

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_vendor_id',x_vendor_id);
 END IF;

 IF (validate_vendor_csr%NOTFOUND) THEN
       CLOSE validate_vendor_csr;

       FND_MESSAGE.SET_NAME('WSH','WSH_RR_INV_SUPPLIER');
       FND_MESSAGE.SET_TOKEN('SUP_NAME',P_supplier_name);
       fnd_msg_pub.add;

       raise fnd_api.g_exc_error;
 END IF;
 CLOSE validate_vendor_csr;

 IF ( WSH_SUPPLIER_PARTY.VENDOR_PARTY_EXISTS(x_vendor_id,x_party_id) = 'N' ) THEN
   -- { IB-Phase-2
   IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Party does not Exist for the Vendor ');
   END IF;
   --
   raise fnd_api.g_exc_error;
   -- } IB-Phase-2
 END IF;



 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

 WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
END Validate_Supplier;


-- Start of comments
-- API name : Check_Hz_Party_site_Uses
-- Type     : Public
-- Pre-reqs : None.
-- Function : API to check if party site uses exist for given party site and uses type in TCA.
-- Parameters :
-- IN:
--      P_party_site_id      IN  Party Site Id.
--      P_site_use_type      IN  Site uses type.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
FUNCTION Check_Hz_Party_site_Uses(
        P_party_site_id                 IN      NUMBER,
        P_site_use_type                 IN      VARCHAR2,
        X_party_site_use_id            OUT NOCOPY      NUMBER) RETURN BOOLEAN IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Hz_Party_site_Uses';

--Cursor to check existence of Party Site Uses.
CURSOR check_party_site_uses_crs IS
  SELECT party_site_use_id
  FROM   hz_party_site_uses
  WHERE  party_site_id=p_party_site_id
  AND    site_use_type = p_site_use_type;

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_party_site_id',P_party_site_id);
      WSH_DEBUG_SV.log(l_module_name,'P_site_use_type',P_site_use_type);
 END IF;

 --Check existence of Party Site Uses.
 OPEN check_party_site_uses_crs;
 FETCH check_party_site_uses_crs INTO X_party_site_use_id;

 IF (check_party_site_uses_crs%NOTFOUND ) THEN
    CLOSE check_party_site_uses_crs;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'RETURN false');
    END IF;
    RETURN false;
 END IF;

 CLOSE check_party_site_uses_crs;

 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'RETURN true');
 END IF;
 RETURN true;

EXCEPTION
 WHEN OTHERS THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

     RETURN false;

END Check_Hz_Party_site_Uses;



-- Start of comments
-- API name : Create_Hz_Party_site_Uses
-- Type     : Public
-- Pre-reqs : None.
-- Procedure : API to create Hz Party Site uses for Party  Site and Uses Type.
--             This API first checks if party site uses exist in TCA, if not then create it,
--             otherwise return the party_site_use_id.
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
        x_return_status         OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_HZ_Party_Site_uses';

l_return_status		varchar2(1);
l_msg_count		NUMBER;
l_msg_data		varchar2(2000);
l_site_use_rec         HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
l_num_warnings          number;
l_num_errors            number;

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_party_site_id',P_party_site_id);
      WSH_DEBUG_SV.log(l_module_name,'P_site_use_type',P_site_use_type);
 END IF;

 IF (P_party_site_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','P_party_site_id');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 IF (P_site_use_type IS NULL ) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','P_site_use_type');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 --Check if Party site uses is already created.
 IF ( NOT check_HZ_Party_Site_uses(
	P_party_site_id	=> p_party_site_id,
	P_site_use_type	=> P_site_use_type,
        x_party_site_use_id	=>x_party_site_use_id)
       ) THEN

    l_site_use_rec.site_use_type     := p_site_use_type;
    l_site_use_rec.party_site_id     := p_party_site_id;
    l_site_use_rec.created_by_module := C_CREATED_BY_MODULE;

    HZ_PARTY_SITE_V2PUB.Create_Party_Site_Use (
           p_init_msg_list       => FND_API.G_FALSE,
           p_party_site_use_rec  => l_site_use_rec,
           x_party_site_use_id   => x_party_site_use_id,
           x_return_status       => l_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data            => l_msg_data);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'HZ_PARTY_SITE_V2PUB.Create_Party_Site_Use l_return_status',l_return_status);
       WSH_DEBUG_SV.log(l_module_name,'x_party_site_use_id',x_party_site_use_id);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

 END IF;

 IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count: '||l_msg_count,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_data: '||l_msg_data,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Create_HZ_Party_Site_uses;

-- Start of comments
-- API name : Create_hz_phone_contact
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to create Hz Contact for phone. If phone number input is not null
--            call api HZ_CONTACT_POINT_V2PUB.Create_phone_Contact_Point to create phone
--            contact.
-- Parameters :
-- IN:
--        P_phone                         IN Phone Number.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Create_hz_phone_contact(
  P_phone           IN     VARCHAR2,
  p_owner_table_id  IN     NUMBER,
  x_return_status	OUT NOCOPY VARCHAR2 )
  IS

  l_return_status            varchar2(100);
  l_msg_count                number;
  l_msg_data                 varchar2(2000);
  l_contact_point_id         number;

  l_contact_points_rec_type  hz_contact_point_v2pub.contact_point_rec_type;
  l_phone_rec_type           hz_contact_point_v2pub.phone_rec_type;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_hz_phone_contact';
l_num_warnings          number;
l_num_errors            number;
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_PHONE',P_PHONE);
       WSH_DEBUG_SV.log(l_module_name,'p_owner_table_id',p_owner_table_id);
   END IF;

       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      --Phone Number not is mandatory parameter for creating phone contact,
      --call api create only if it is not null.
      IF (p_phone IS NOT NULL) THEN
        l_contact_points_rec_type.owner_table_name   := 'HZ_PARTIES';
        l_contact_points_rec_type.owner_table_id     := p_owner_table_id;
        l_contact_points_rec_type.primary_flag       := 'Y';
        l_contact_points_rec_type.status             := 'A';
        l_contact_points_rec_type.created_by_module  := C_CREATED_BY_MODULE;
         l_contact_points_rec_type.contact_point_type := 'PHONE';
         l_phone_rec_type.phone_number       := p_phone;
         l_phone_rec_type.phone_line_type       := 'GEN';
         l_contact_points_rec_type.primary_flag       := 'N';

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_CONTACT_POINT_V2PUB.Create_Contact_Point for PHONE'
,WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         HZ_CONTACT_POINT_V2PUB.Create_phone_Contact_Point (
             p_init_msg_list       => FND_API.G_FALSE,
             p_contact_point_rec   => l_contact_points_rec_type,
             p_phone_rec           => l_phone_rec_type,
             x_contact_point_id    => l_contact_point_id,
             x_return_status       => l_return_status,
             x_msg_count           => l_msg_count,
             x_msg_data            => l_msg_data);

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'HZ_CONTACT_POINT_V2PUB.Create_phone_Contact_Point l_contact_point_id',l_contact_point_id);
           WSH_DEBUG_SV.log(l_module_name,'l_contact_point_id',l_contact_point_id);
         END IF;
         wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

      END IF;

 IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_ERROR_CR_CONTACT');
     fnd_msg_pub.add;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count: '||l_msg_count,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_data: '||l_msg_data,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
END Create_hz_phone_contact;


-- Start of comments
-- API name : Update_HZ_contact
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to Update Hz Contact for party site. Api update person ,phone
--          or email information by calling respective HZ api's. These api are
--          only called if input value is different from existing value.
-- Parameters :
-- IN:
--        P_person_id                     IN Person Id.
--        P_person_name                   IN Person Name.
--        P_phone_contact_point_id        IN Person contact point id.
--        P_phone                         IN Phone Number.
--        P_email_contact_point_id        IN Email Contact point id.
--        P_email                         IN Email.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Update_HZ_contact(
        P_person_id                     IN NUMBER,
        P_person_name                   IN VARCHAR2,
        P_old_person_name               IN VARCHAR2,
        P_phone_contact_point_id        IN NUMBER,
        P_phone                         IN VARCHAR2,
        P_old_phone                     IN VARCHAR2,
        P_email_contact_point_id        IN NUMBER,
        P_email                         IN VARCHAR2,
        P_old_email                     IN VARCHAR2,
        p_owner_table_id	        IN NUMBER,
  	x_return_status       		OUT NOCOPY VARCHAR2 )
IS

  l_person_rec               HZ_PARTY_V2PUB.person_rec_type;
  l_ocon_rec                 HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
  l_contact_points_rec_type  hz_contact_point_v2pub.contact_point_rec_type;
  l_email_rec_type           hz_contact_point_v2pub.email_rec_type;
  l_phone_rec_type           hz_contact_point_v2pub.phone_rec_type;

  l_return_status            varchar2(100);
  l_msg_count                number;
  l_msg_data                 varchar2(2000);
  l_profile_id               number;
  l_object_version_number    number;
  l_contact_object_version   number;
  l_rel_object_version       number;
  l_party_object_version     number;
  l_position                 number;
  l_call_procedure           varchar2(100);
  l_cont_point_version       number;

--Cursor to get object_version_number for party
CURSOR Get_Object_Version_Number(p_person_party_id NUMBER) IS
  select object_version_number
  from   hz_parties
  where  party_id = p_person_party_id;

--Cursor to get object_version_number for party contact.
CURSOR Get_Cont_Point_Version(p_contact_point_id NUMBER) IS
  select object_version_number
  from   hz_contact_points
  where  contact_point_id = p_contact_point_id;

l_person_party_id			NUMBER;
l_phone_contact_point_id	NUMBER;
l_email_contact_point_id	NUMBER;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Update_HZ_contact';
l_num_warnings          number;
l_num_errors            number;

BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
   END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


  IF (nvl(P_person_name,'#') <> nvl(p_old_person_name,'#') ) THEN --{
     l_person_rec.person_first_name           := p_person_name;
     l_person_rec.party_rec.party_id          := P_person_id;

     --Person record should exist for update, version number are not changed.
     OPEN Get_Object_Version_Number(P_person_id);
     FETCH Get_Object_Version_Number INTO l_object_version_number;
     IF (Get_Object_Version_Number%NOTFOUND) THEN
       raise fnd_api.g_exc_error;
     END IF;
     CLOSE Get_Object_Version_Number ;

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_V2PUB.Update_Person',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     HZ_PARTY_V2PUB.Update_Person (
          p_init_msg_list                => FND_API.G_FALSE,
          p_person_rec                   => l_person_rec,
          p_party_object_version_number  => l_object_version_number,
          x_profile_id                   => l_profile_id,
          x_return_status                => l_return_status,
          x_msg_count                    => l_msg_count,
          x_msg_data                     => l_msg_data);

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'HZ_PARTY_V2PUB.Update_Person l_return_status',l_return_status);
       WSH_DEBUG_SV.log(l_module_name,'x_profile_id',l_profile_id);
       WSH_DEBUG_SV.log(l_module_name,'l_msg_count',l_msg_count);
       WSH_DEBUG_SV.log(l_module_name,'l_msg_data',l_msg_data);
     END IF;

     wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

  END IF; --}


  IF (nvl(P_phone,'#') <> nvl(p_old_phone,'#')) THEN --{

    --If phone contact is not exist then create else update
    IF (p_phone_contact_point_id IS NULL) THEN  --{
     Create_hz_phone_contact(
           P_phone           => p_phone,
           p_owner_table_id  => p_owner_table_id,
           x_return_status   => l_return_status);

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Create_hz_phone_contact l_return_status',l_return_status);
         END IF;
         wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

    ELSE
     --Update only if Phone Number is not null. This check is only required
     --for phone, since this is not mandatory field.
     IF (P_phone IS NOT NULL) THEN
        l_contact_points_rec_type.contact_point_id := p_phone_contact_point_id;
        l_phone_rec_type.phone_number       := p_phone;

        --Phone record should exist for update, version number are not changed.
        OPEN Get_Cont_Point_Version(p_phone_contact_point_id);
        FETCH Get_Cont_Point_Version INTO l_cont_point_version;
        IF (Get_Cont_Point_Version%NOTFOUND) THEN
          raise fnd_api.g_exc_error;
        END IF;
        CLOSE Get_Cont_Point_Version ;


        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program Unit HZ_CONTACT_POINT_V2PUB.Update_Contact_Point for Phone',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        HZ_CONTACT_POINT_V2PUB.Update_Contact_Point(
           p_init_msg_list          => FND_API.G_FALSE,
           p_contact_point_rec      => l_contact_points_rec_type,
           p_phone_rec              => l_phone_rec_type,
           p_object_version_number  => l_cont_point_version,
           x_return_status          => l_return_status,
           x_msg_count              => l_msg_count,
           x_msg_data               => l_msg_data );

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'HZ_CONTACT_POINT_V2PUB.Update_Contact_Point l_return_status',l_return_status);
          WSH_DEBUG_SV.log(l_module_name,'l_msg_count',l_msg_count);
          WSH_DEBUG_SV.log(l_module_name,'l_msg_data',l_msg_data);
        END IF;
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
       END IF;
    END IF; --}
  END IF; --}


  IF (nvl(p_email,'#') <> nvl(p_old_email,'#') ) THEN --{
     l_contact_points_rec_type.contact_point_id := p_email_contact_point_id;
     l_email_rec_type.email_address             := P_email;

     --Email record should exist for update, version number are not changed.
     OPEN Get_Cont_Point_Version(p_email_contact_point_id);
     FETCH Get_Cont_Point_Version INTO l_cont_point_version;
     IF (Get_Cont_Point_Version%NOTFOUND) THEN
       raise fnd_api.g_exc_error;
     END IF;
     CLOSE Get_Cont_Point_Version ;


     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program Unit HZ_CONTACT_POINT_V2PUB.Update_Contact_Point',WSH_DEBUG_SV.
C_PROC_LEVEL);
     END IF;

     HZ_CONTACT_POINT_V2PUB.Update_Contact_Point(
        p_init_msg_list          => FND_API.G_FALSE,
        p_contact_point_rec      => l_contact_points_rec_type,
        p_email_rec              => l_email_rec_type,
        p_object_version_number  => l_cont_point_version,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data );

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'HZ_CONTACT_POINT_V2PUB.Update_Contact_Point l_return_status',l_return_status);
       WSH_DEBUG_SV.log(l_module_name,'l_msg_count',l_msg_count);
       WSH_DEBUG_SV.log(l_module_name,'l_msg_data',l_msg_data);
     END IF;

     wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

  END IF; --}


 IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_ERROR_UP_CONTACT');
     fnd_msg_pub.add;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count: '||l_msg_count,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_data: '||l_msg_data,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  IF (Get_Object_Version_Number%ISOPEN) THEN
     CLOSE Get_Object_Version_Number;
  END IF;

  IF (Get_Cont_Point_Version%ISOPEN) THEN
     CLOSE Get_Cont_Point_Version;
  END IF;

WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;


  IF (Get_Object_Version_Number%ISOPEN) THEN
     CLOSE Get_Object_Version_Number;
  END IF;

  IF (Get_Cont_Point_Version%ISOPEN) THEN
     CLOSE Get_Cont_Point_Version;
  END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;

END Update_HZ_contact;



-- Start of comments
-- API name : Create_HZ_contact
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to create Hz Contact for party site. This API first check if contact exists
--            for party site in TCA, if not then create it.
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
PROCEDURE Create_HZ_contact(
  P_PARTY_ID         	  IN     NUMBER,
  P_PARTY_SITE_ID         IN     NUMBER,
  P_PERSON_NAME           IN     VARCHAR2,
  P_phone           IN     VARCHAR2,
  P_EMAIL            IN     VARCHAR2,
  x_return_status	OUT NOCOPY VARCHAR2 )
  IS

  l_return_status            varchar2(100);
  l_msg_count                number;
  l_position                 number;
  l_call_procedure           varchar2(100);
  l_msg_data                 varchar2(2000);
  l_party_number             varchar2(100);
  l_profile_id               number;
  l_relationship_id          number;
  l_exception_msg            varchar2(1000);
  l_party_relationship_id    number;
  l_contact_point_id         number;
  l_org_contact_id           number;
  l_party_id                 number;

  l_per_rec                  HZ_PARTY_V2PUB.person_rec_type;
  l_person_party_id          number;

  l_rel_rec_type             HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
  l_ocon_rec                 HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
  l_contact_points_rec_type  hz_contact_point_v2pub.contact_point_rec_type;
  l_email_rec_type           hz_contact_point_v2pub.email_rec_type;
  l_phone_rec_type           hz_contact_point_v2pub.phone_rec_type;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_HZ_contact';
l_num_warnings          number;
l_num_errors            number;
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_PARTY_ID',P_PARTY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PARTY_SITE_ID',P_PARTY_SITE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PERSON_NAME',P_PERSON_NAME);
       WSH_DEBUG_SV.log(l_module_name,'P_PHONE',P_PHONE);
       WSH_DEBUG_SV.log(l_module_name,'P_EMAIL',P_EMAIL);
   END IF;

       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      l_per_rec.person_first_name       := P_PERSON_NAME;
      l_per_rec.created_by_module       := C_CREATED_BY_MODULE;
      l_per_rec.party_rec.status        := 'A';

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_V2PUB.Create_Person',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      HZ_PARTY_V2PUB.Create_Person (
            p_init_msg_list  => FND_API.G_FALSE,
            p_person_rec     => l_per_rec,
            x_party_id       => l_person_party_id,
            x_party_number   => l_party_number,
            x_profile_id     => l_profile_id,
            x_return_status  => l_return_status,
            x_msg_count      => l_msg_count,
            x_msg_data       => l_msg_data);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'HZ_PARTY_V2PUB.Create_Person l_return_status',l_return_status);
        WSH_DEBUG_SV.log(l_module_name,'l_person_party_id',l_person_party_id);
        WSH_DEBUG_SV.log(l_module_name,'l_party_number',l_party_number);
        WSH_DEBUG_SV.log(l_module_name,'l_profile_id',l_profile_id);
      END IF;
      --
      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

      -- Create Org Contact to related person to party.
      l_ocon_rec.party_rel_rec.subject_id               := l_person_party_id;
      l_ocon_rec.party_rel_rec.subject_table_name       := 'HZ_PARTIES';
      l_ocon_rec.party_rel_rec.subject_type             := 'PERSON';
      l_ocon_rec.party_rel_rec.object_id                := p_party_id;
      l_ocon_rec.party_rel_rec.object_table_name        := 'HZ_PARTIES';
      l_ocon_rec.party_rel_rec.object_type              := 'ORGANIZATION';
      l_ocon_rec.party_rel_rec.relationship_code        := 'CONTACT_OF';
      l_ocon_rec.party_rel_rec.relationship_type        := 'CONTACT';
      l_ocon_rec.party_rel_rec.status                   := 'A';
      l_ocon_rec.party_rel_rec.start_date               := sysdate;
      l_ocon_rec.party_rel_rec.created_by_module        := C_CREATED_BY_MODULE;
      l_ocon_rec.party_site_id                          := p_party_site_id;
      l_ocon_rec.created_by_module                      := C_CREATED_BY_MODULE;


      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_CONTACT_V2PUB.create_org_contact',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      HZ_PARTY_CONTACT_V2PUB.create_org_contact (
             p_org_contact_rec                  => l_ocon_rec,
             x_org_contact_id                   => l_org_contact_id,
             x_party_rel_id                     => l_party_relationship_id,
             x_party_id                         => l_party_id,
             x_party_number                     => l_party_number,
             x_return_status                    => l_return_status,
             x_msg_count                        => l_msg_count,
             x_msg_data                         => l_msg_data );

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'HZ_PARTY_CONTACT_V2PUB.create_org_contact l_return_status',l_return_status);
        WSH_DEBUG_SV.log(l_module_name,'l_org_contact_id',l_org_contact_id);
        WSH_DEBUG_SV.log(l_module_name,'l_party_relationship_id',l_party_relationship_id);
        WSH_DEBUG_SV.log(l_module_name,'l_party_id',l_party_id);
        WSH_DEBUG_SV.log(l_module_name,'l_party_number',l_party_number);
      END IF;
      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);


      -- Create a EMAIL contact point, this related email to party.
      l_contact_points_rec_type.owner_table_name   := 'HZ_PARTIES';
      l_contact_points_rec_type.owner_table_id     := l_party_id;
      l_contact_points_rec_type.primary_flag       := 'Y';
      l_contact_points_rec_type.status             := 'A';
      l_contact_points_rec_type.created_by_module  := C_CREATED_BY_MODULE;
      l_contact_points_rec_type.contact_point_type := 'EMAIL';
      l_email_rec_type.email_address               := p_email;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_CONTACT_POINT_V2PUB.Create_Contact_Point for EMAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      HZ_CONTACT_POINT_V2PUB.Create_email_Contact_Point (
             p_init_msg_list       => FND_API.G_FALSE,
             p_contact_point_rec   => l_contact_points_rec_type,
             p_email_rec           => l_email_rec_type,
             x_contact_point_id    => l_contact_point_id,
             x_return_status       => l_return_status,
             x_msg_count           => l_msg_count,
             x_msg_data            => l_msg_data);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'HZ_CONTACT_POINT_V2PUB.Create_email_Contact_Point l_return_status',l_return_status);
        WSH_DEBUG_SV.log(l_module_name,'l_contact_point_id',l_contact_point_id);
      END IF;
      wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);


      --Phone Number is not mandatory field, so create only if passed.
      IF (p_phone IS NOT NULL ) THEN
         Create_hz_phone_contact(
           P_phone           => p_phone,
           p_owner_table_id  => l_party_id,
           x_return_status   => l_return_status);

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Create_hz_phone_contact l_return_status',l_return_status);
         END IF;
         wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
      END IF;

 IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_ERROR_CR_CONTACT');
     fnd_msg_pub.add;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count: '||l_msg_count,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_data: '||l_msg_data,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
END Create_HZ_contact;


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
  x_return_status       OUT NOCOPY VARCHAR2 )
IS

  l_person_rec               HZ_PARTY_V2PUB.person_rec_type;
  l_ocon_rec                 HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
  l_contact_points_rec_type  hz_contact_point_v2pub.contact_point_rec_type;
  l_email_rec_type           hz_contact_point_v2pub.email_rec_type;
  l_phone_rec_type           hz_contact_point_v2pub.phone_rec_type;

  l_return_status            varchar2(100);
  l_msg_count                number;
  l_msg_data                 varchar2(2000);
  l_profile_id               number;
  l_object_version_number    number;
  l_contact_object_version   number;
  l_rel_object_version       number;
  l_party_object_version     number;
  l_position                 number;
  l_call_procedure           varchar2(100);
  l_cont_point_version       number;

--Cursor check for contact information already exists for party and party site.
--The relationship type, relationship code, object and subject are define same
--as it was created. For detail how contact information is created , please go
--through create_hz_contact api.
CURSOR Get_Contact_info(p_party_id	NUMBER,
			p_party_site_id NUMBER ) IS
select  contact_person.party_id l_contact_person_id,
	contact_person.party_name shipper_name,
	phone_record.contact_point_id phone_contact_point_id,
	phone_record.phone_number phone_number,
	email_record.contact_point_id email_contact_point_id,
	email_record.email_address,
        email_record.owner_table_id,
	hrel.relationship_id,    -- IB-Phase-2
        hrel.end_date end_date   -- IB-Phase-2
from    hz_party_sites      hps,
        hz_parties          contact_person,
        hz_org_contacts     supplier_contact,
        hz_contact_points   phone_record,
        hz_contact_points   email_record,
        hz_relationships    hrel
where   hrel.subject_id = contact_person.party_id
and     hrel.subject_table_name = 'HZ_PARTIES'
and     hrel.subject_type = 'PERSON'
and     hrel.object_id = hps.party_id
and     hrel.object_table_name = 'HZ_PARTIES'
and     hrel.object_type = 'ORGANIZATION'
and     hrel.relationship_code = 'CONTACT_OF'
and     hrel.directional_flag = 'F'
and  	supplier_contact.party_relationship_id =hrel.relationship_id
and     supplier_contact.party_site_id = hps.party_site_id
and     phone_record.owner_table_name(+) = 'HZ_PARTIES'
and     phone_record.owner_table_id(+) = hrel.party_id
and     phone_record.contact_point_type(+) = 'PHONE'
and     email_record.owner_table_name = 'HZ_PARTIES'
and     email_record.owner_table_id = hrel.party_id
and     email_record.contact_point_type = 'EMAIL'
and 	hps.party_site_id =p_party_site_id
and 	hps.party_id  = p_party_id;

l_person_id		NUMBER;
l_person_name			varchar2(240);
l_phone_contact_point_id	NUMBER;
l_phone				varchar2(40);
l_email_contact_point_id	NUMBER;
l_email				varchar2(2000);
l_owner_table_id		NUMBER;
-- { IB-Phase-2
l_relation_end_date             DATE;
l_relationship_id               NUMBER;
l_relationship_rec              HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;-- IB-Phase-2
l_party_object_version_number   NUMBER;
-- } IB-Phase-2

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_HZ_contact';
l_num_warnings          number;
l_num_errors            number;
BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_party_ID',P_party_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_party_site_ID',P_party_site_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PERSON_NAME',P_PERSON_NAME);
       WSH_DEBUG_SV.log(l_module_name,'P_phone',P_phone);
       WSH_DEBUG_SV.log(l_module_name,'P_EMAIL',P_EMAIL);
   END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --See if contact information are already exists for Party and Party site.
  OPEN Get_Contact_info(p_party_id,p_party_site_id);
  FETCH Get_Contact_info
  INTO  l_person_id, l_person_name,
	l_phone_contact_point_id,l_phone,
	l_email_contact_point_id,l_email,
        l_owner_table_id,
	l_relationship_id,
	l_relation_end_date;  --IB-Phase-2

  IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_person_id',l_person_id);
       WSH_DEBUG_SV.log(l_module_name,'l_person_name',l_person_name);
       WSH_DEBUG_SV.log(l_module_name,'l_phone_contact_point_id',l_phone_contact_point_id);
       WSH_DEBUG_SV.log(l_module_name,'l_phone',l_phone);
       WSH_DEBUG_SV.log(l_module_name,'l_email_contact_point_id',l_email_contact_point_id);
       WSH_DEBUG_SV.log(l_module_name,'l_email',l_email);
  END IF;

  IF (Get_Contact_info%NOTFOUND) THEN
    --Create new contact info
    Create_HZ_contact(
        P_party_id              => p_party_id,
        P_party_site_id         => p_party_site_id,
        P_person_name           => p_person_name,
        P_phone                 => p_phone,
        P_email                 => p_email,
        x_return_status         => l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Create_HZ_contact l_return_status',l_return_status);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

  ELSE

       --{ IB-Phase-2
       --Make this relation ship active, if it is not.
       IF l_relation_end_date < SYSDATE
       THEN
         l_relationship_rec.relationship_id := l_relationship_id;
         l_relationship_rec.end_date := FND_API.G_MISS_DATE;

	 HZ_RELATIONSHIP_V2PUB.update_relationship(
              p_init_msg_list               => FND_API.g_false,
              p_relationship_rec            => l_relationship_rec,
	      p_object_version_number       => l_object_version_number,
	      p_party_object_version_number => l_party_object_version_number,
	      x_return_status               => l_return_status,
	      x_msg_count                   => l_msg_count,
	      x_msg_data                    => l_msg_data
	      );

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'HZ_RELATIONSHIP_V2PUB.update_relationship l_return_status',l_return_status);
         END IF;
         wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_num_warnings,
             x_num_errors    => l_num_errors);

       END IF;
       --} IB-Phase-2


       --Upadte existing contact info
       Update_HZ_contact(
        P_person_id         		=> l_person_id,
        P_person_name           	=> p_person_name,
        P_old_person_name           	=> l_person_name,
        P_phone_contact_point_id	=> l_phone_contact_point_id,
        P_phone                 	=> p_phone,
        P_old_phone                 	=> l_phone,
        P_email_contact_point_id	=> l_email_contact_point_id,
        P_email                 	=> p_email,
        P_old_email                 	=> l_email,
        p_owner_table_id	        => l_owner_table_id,
        x_return_status         	=> l_return_status);

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Update_HZ_contact l_return_status',l_return_status);
       END IF;
       wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
  END IF;
  CLOSE Get_Contact_info;

 IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count: '||l_msg_count,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_data: '||l_msg_data,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  IF (Get_Contact_info%ISOPEN) THEN
     CLOSE Get_Contact_info;
  END IF;

WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

  IF (Get_Contact_info%ISOPEN) THEN
     CLOSE Get_Contact_info;
  END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
END Process_HZ_contact;


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
--        p_phone			IN      Phone Number.
--        p_email			IN      Email Address.
-- OUT:
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Update_Address(
        P_location_id                   IN      number,
        P_party_id                   	IN      number,
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
        p_phone				IN      varchar2,
        p_email				IN      varchar2,
        x_return_status                 OUT NOCOPY varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Update_Address';

l_return_status         varchar2(1);
l_location_id		NUMBER;
l_num_warnings          number;
l_num_errors            number;

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_location_id',p_location_id);
      WSH_DEBUG_SV.log(l_module_name,'p_party_site_id',p_party_site_id);
      WSH_DEBUG_SV.log(l_module_name,'P_address1',P_address1);
      WSH_DEBUG_SV.log(l_module_name,'P_address2',P_address2);
      WSH_DEBUG_SV.log(l_module_name,'P_address3',P_address3);
      WSH_DEBUG_SV.log(l_module_name,'P_address4',P_address4);
      WSH_DEBUG_SV.log(l_module_name,'P_city',P_city);
      WSH_DEBUG_SV.log(l_module_name,'P_postal_code',P_postal_code);
      WSH_DEBUG_SV.log(l_module_name,'P_state',P_state);
      WSH_DEBUG_SV.log(l_module_name,'P_Province',P_Province);
      WSH_DEBUG_SV.log(l_module_name,'P_county',P_county);
      WSH_DEBUG_SV.log(l_module_name,'p_country',p_country);
      WSH_DEBUG_SV.log(l_module_name,'p_phone',p_phone);
      WSH_DEBUG_SV.log(l_module_name,'p_email',p_email);
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 l_location_id := p_location_id;

 Update_Hz_Location(
        P_location_id   => p_location_id,
        P_address1      => P_address1,
        P_address2      => P_address2,
        P_address3      => P_address3,
        P_address4      => P_address4,
        P_city          => P_city,
        P_postal_code   => P_postal_code,
        P_state         => P_state,
        P_province      => P_province,
        P_county        => P_county,
        p_country       => p_country,
        x_return_status => l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Update_Hz_Location l_return_status',l_return_status);
    END IF;

    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

    --Validate new updated information.
    WSH_UTIL_VALIDATE.validate_location (
         p_location_id          =>l_location_id,
         p_location_code        =>NULL,
         p_caller		=> 'PO',
         x_return_status        =>l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,' WSH_UTIL_VALIDATE.validate_location l_return_status',l_return_status);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

    --Update Contact information.
    Process_HZ_contact(
        P_party_id         	=> p_party_id,
        P_party_site_id         => p_party_site_id,
        P_person_name           => p_shipper_name,
        P_phone                 => p_phone,
        P_email                 => p_email,
        x_return_status         => l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Process_HZ_contact l_return_status',l_return_status);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

 IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_ERROR_UP_LOC');
     fnd_msg_pub.add;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
END Update_Address;


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
        p_phone				IN      varchar2,
        p_email				IN      varchar2,
        x_location_id                   OUT NOCOPY number,
        x_party_site_id                 OUT NOCOPY number,
        x_return_status                 OUT NOCOPY varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Address';

l_return_status         varchar2(1);
l_party_site_id		NUMBER;
l_party_site_use_id	NUMBER;
l_num_warnings          number;
l_num_errors            number;
BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_vendor_id',P_vendor_id);
      WSH_DEBUG_SV.log(l_module_name,'p_location_code',p_location_code);
      WSH_DEBUG_SV.log(l_module_name,'P_address1',P_address1);
      WSH_DEBUG_SV.log(l_module_name,'P_address2',P_address2);
      WSH_DEBUG_SV.log(l_module_name,'P_address3',P_address3);
      WSH_DEBUG_SV.log(l_module_name,'P_address4',P_address4);
      WSH_DEBUG_SV.log(l_module_name,'P_city',P_city);
      WSH_DEBUG_SV.log(l_module_name,'P_postal_code',P_postal_code);
      WSH_DEBUG_SV.log(l_module_name,'P_state',P_state);
      WSH_DEBUG_SV.log(l_module_name,'P_Province',P_Province);
      WSH_DEBUG_SV.log(l_module_name,'P_county',P_county);
      WSH_DEBUG_SV.log(l_module_name,'p_country',p_country);
      WSH_DEBUG_SV.log(l_module_name,'p_phone',p_phone);
      WSH_DEBUG_SV.log(l_module_name,'p_email',p_email);
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --Create Location and Party Site
    Create_Hz_Location_Party_Site(
        P_party_id	=> p_party_id,
        P_location_code	=> P_location_code||'|'||p_party_id,
        P_address1	=> P_address1,
        P_address2	=> P_address2,
        P_address3	=> P_address3,
        P_address4	=> P_address4,
        P_city		=> P_city,
        P_postal_code	=> P_postal_code,
        P_state		=> P_state,
        P_province	=> P_province,
        P_county	=> P_county,
        p_country	=> p_country,
        x_location_id	=> x_location_id,
        x_party_site_id	=> x_party_site_id,
        x_return_status	=> l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Create_Hz_Location_Party_Site l_return_status',l_return_status);
       WSH_DEBUG_SV.log(l_module_name,'x_location_id',x_location_id);
       WSH_DEBUG_SV.log(l_module_name,'x_party_site_id',x_party_site_id);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

    -- Validate location information created and transfer from HZ to WSH.
    WSH_UTIL_VALIDATE.validate_location (
  	 p_location_id		=>x_location_id,
    	 p_location_code	=>NULL,
         p_caller		=> 'PO',
    	 x_return_status	=>l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,' WSH_UTIL_VALIDATE.validate_location l_return_status',l_return_status);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);


    --Create Party Site Uses
    Create_HZ_Party_Site_uses(
	p_party_site_id		=> x_party_site_id,
	p_site_use_type     	=> 'SUPPLIER_SHIP_FROM',
	x_party_site_use_id	=> l_party_site_use_id,
	x_return_status    	=> l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,' Create_HZ_Party_Site_uses l_return_status',l_return_status);
       WSH_DEBUG_SV.log(l_module_name,'l_party_site_use_id',l_party_site_use_id);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

    --Create Contact
    Process_HZ_contact(
	P_party_id		=> p_party_id,
	P_party_site_id		=> x_party_site_id,
        P_person_name		=> p_shipper_name,
	P_phone			=> p_phone,
	P_email			=> p_email,
	x_return_status    	=> l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Create_HZ_contact PHONE l_return_status',l_return_status);
    END IF;
    wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

 IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;


 IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_ERROR_CR_LOC');
     fnd_msg_pub.add;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
END CREATE_ADDRESS;


-- Start of comments
-- API name : Get_message
-- Type     : Private
-- Pre-reqs : None.
-- Procedure : API to get fnd stack messages and store in local message table.
--             These messages are out to Supplier Address Book UI.
--
-- Parameters :
-- IN:
--      None
-- OUT:
--      None
-- End of comments
PROCEDURE Get_message IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Message';
l_msg		varchar2(23767);

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
 END IF;

 FND_MESSAGE.SET_NAME('WSH','WSH_SAB_ADDRESS_ERROR');
 FND_MESSAGE.SET_TOKEN('LINE_NUMBER',g_line_number);
 fnd_msg_pub.add;

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Message Count:',FND_MSG_PUB.Count_Msg);
 END IF;


 FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
   l_msg :=  FND_MSG_PUB.get(i, FND_API.G_FALSE);
   IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Stack Message :',l_msg);
   END IF;

   g_error_tbl(g_error_tbl.count + 1) := l_msg;
 END LOOP;

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'After Message Count:',FND_MSG_PUB.Count_Msg);
 END IF;

 --Initialized the FND message to avoid duplicate message being
 --inserted to local message table.
 FND_MSG_PUB.initialize;

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
 WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     g_error_tbl(g_error_tbl.count + 1) := FND_MESSAGE.GET;
END Get_message;


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
        p_in_param              IN      WSH_ROUTING_REQUEST.In_param_Rec_Type,
        p_Address               IN      WSH_ROUTING_REQUEST.Address_rec_type,
        x_success_tbl           IN OUT NOCOPY WSH_FILE_MSG_TABLE,
        x_error_tbl             IN OUT NOCOPY WSH_ROUTING_REQUEST.tbl_var2000,
        x_return_status         IN OUT NOCOPY varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Address';
l_return_status		varchar2(1);

--Cursor to find existing address information in TCA.
CURSOR check_location_csr(p_location_code varchar2,p_party_id number) IS
   SELECT ps.location_id,ps.party_site_id,ps.status -- IB-Phase-2 Vendor Merge
   FROM   hz_party_sites ps,hz_party_site_uses psu
   WHERE ps.party_site_id = psu.party_site_id
   AND   psu.site_use_type = 'SUPPLIER_SHIP_FROM'
   and   party_site_number=p_location_code||'|'||p_party_id
   and   party_id =p_party_id;

l_msg_count		number:= 0;
l_index			number;
l_num_errors		number;
l_num_warning		number;
l_tot_line		number;

l_vendor_id		number;
l_party_id		number;
l_location_id		number;
l_party_site_id		number;
l_party_site_uses_id	number;
l_party_site_status     varchar2(1);
l_party_site_msg        varchar2(1000);

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_Address.count',P_Address.supplier_name.count);
    WSH_DEBUG_SV.log(l_module_name,'x_error_tbl.count',x_error_tbl.count);
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 l_num_errors := 0;
 l_num_warning := 0;
 --Initilize success and error message table.
 x_success_tbl := WSH_FILE_MSG_TABLE();
 g_error_tbl.delete;


 l_tot_line := P_Address.supplier_name.count;

 --Loop through address lines.
 l_index := P_Address.supplier_name.first;
 WHILE (l_index IS NOT NULL ) LOOP --{
 BEGIN
    g_line_number:= l_index;

    --Check for validate action code.
    IF (P_Address.action(l_index) NOT IN ('I','U') ) THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_RR_INV_ACTION');
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_index);
          fnd_msg_pub.add;

          wsh_util_core.api_post_call(p_return_status  =>WSH_UTIL_CORE.G_RET_STS_ERROR,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);
    END IF;

    IF (P_Address.error_flag(l_index) = 'Y' ) THEN
       wsh_util_core.api_post_call(p_return_status  =>WSH_UTIL_CORE.G_RET_STS_ERROR,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);
    END IF;

    --Validate Supplier Information.
    Validate_Supplier(
        p_in_param      => p_in_param,
        p_supplier_name => p_Address.supplier_name(l_index),
        x_vendor_id     => l_vendor_id,
        x_party_id      => l_party_id,
        x_return_status => l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Validate_Supplier l_return_status',l_return_status);
       WSH_DEBUG_SV.log(l_module_name,'l_vendor_id',l_vendor_id);
       WSH_DEBUG_SV.log(l_module_name,'l_party_id',l_party_id);
    END IF;
    wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);


    --Find the existing address information in TCA.
    OPEN check_location_csr(p_Address.ship_from_code(l_index),l_party_id);
    FETCH check_location_csr INTO l_location_id,l_party_site_id,l_party_site_status;-- IB-phase-2

    IF (check_location_csr%FOUND) THEN --{
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Location Found action',P_Address.action(l_index));
       END IF;

       --For existing record action should not be Insert.
       IF (P_Address.action(l_index) = 'I' ) THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_RR_INV_ACTION');
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_index);
          fnd_msg_pub.add;
          wsh_util_core.api_post_call(p_return_status  =>WSH_UTIL_CORE.G_RET_STS_ERROR,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);
       END IF;

       -- { IB-Phase-2
       -- If Party Site is not Active then error out, with a suitable message.
       IF l_party_site_status <> 'A'
       THEN
         l_party_site_msg := p_Address.ship_from_code(l_index);
         FND_MESSAGE.SET_NAME('WSH','WSH_INACTIVE_PARTY_SITE');
         FND_MESSAGE.SET_TOKEN('PARTY_SITE',l_party_site_msg);
         fnd_msg_pub.add;
	 l_num_errors := l_num_errors + 1;
         raise FND_API.G_EXC_ERROR;
       END IF;
       -- } IB-Phase-2

       Update_address(
        P_location_id   => l_location_id,
        P_party_id      => l_party_id,
        P_party_site_id => l_party_site_id,
        P_address1      => p_Address.ship_from_address1(l_index),
        P_address2      => p_Address.ship_from_address2(l_index),
        P_address3      => p_Address.ship_from_address3(l_index),
        P_address4      => p_Address.ship_from_address4(l_index),
        P_city          => p_Address.ship_from_city(l_index),
        P_postal_code   => p_Address.ship_from_postal_code(l_index),
        P_state         => p_Address.ship_from_state(l_index),
        P_province      => p_Address.ship_from_province(l_index),
        P_county        => p_Address.ship_from_county(l_index),
        p_country       => p_Address.ship_from_country(l_index),
        p_shipper_name  => p_Address.shipper_name(l_index),
        p_phone         => p_Address.phone(l_index),
        p_email         => p_Address.email(l_index),
        x_return_status => l_return_status);

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Update_Address l_return_status',l_return_status);
        END IF;

        wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

    ELSE --}{
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Location NOT Found action',P_Address.action(l_index));
       END IF;
       IF (P_Address.action(l_index) = 'U' ) THEN

          --For new record action should not be Update.
          FND_MESSAGE.SET_NAME('WSH','WSH_RR_INV_ACTION');
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_index);
          fnd_msg_pub.add;

          wsh_util_core.api_post_call(p_return_status  =>WSH_UTIL_CORE.G_RET_STS_ERROR,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);
       END IF;

       Create_Address(
        P_vendor_id     => l_vendor_id,
        P_party_id      => l_party_id,
        P_location_code => p_Address.ship_from_code(l_index),
        P_address1      => p_Address.ship_from_address1(l_index),
        P_address2      => p_Address.ship_from_address2(l_index),
        P_address3      => p_Address.ship_from_address3(l_index),
        P_address4      => p_Address.ship_from_address4(l_index),
        P_city          => p_Address.ship_from_city(l_index),
        P_postal_code   => p_Address.ship_from_postal_code(l_index),
        P_state         => p_Address.ship_from_state(l_index),
        P_province      => p_Address.ship_from_province(l_index),
        P_county        => p_Address.ship_from_county(l_index),
        p_country       => p_Address.ship_from_country(l_index),
        p_shipper_name 	=> p_Address.shipper_name(l_index),
        p_phone		=> p_Address.phone(l_index),
        p_email		=> p_Address.email(l_index),
        x_location_id   => l_location_id,
        x_party_site_id => l_party_site_id,
        x_return_status => l_return_status);


        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Create_Address l_return_status',l_return_status);
           WSH_DEBUG_SV.log(l_module_name,'l_location_id',l_location_id);
           WSH_DEBUG_SV.log(l_module_name,'l_party_site_id',l_party_site_id);
        END IF;

        wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);
    END IF; --}

    CLOSE check_location_csr;

    FND_MESSAGE.SET_NAME('WSH','WSH_SAB_ADDRESS_SUCCESS');
    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_index);
    l_msg_count := l_msg_count + 1;
    x_success_tbl.extend;
    x_success_tbl(l_msg_count):=FND_MESSAGE.Get;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'G_EXC_ERROR in the loop');
       END IF;
       get_message;

       IF (check_location_csr%ISOPEN) THEN
          CLOSE check_location_csr;
       END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF l_debug_on THEN
               wsh_debug_sv.log (l_module_name, 'G_EXC_UNEXPECTED_ERROR in the loop');
       END IF;
       get_message;

       IF (check_location_csr%ISOPEN) THEN
          CLOSE check_location_csr;
       END IF;
 END;

 l_index := P_Address.supplier_name.next(l_index);
 END LOOP; --}


 IF (l_num_errors >= l_tot_line ) THEN
     --Error if all the lines are error.
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
 ELSIF ( (l_num_errors > 0 and l_num_errors < l_tot_line) or (l_num_warning > 0 ) ) THEN
     --Warning , if error line is more than one and less than total number of address line.
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
 END IF;


 --Collect all the error message. Error messages are inserted in
 --after all the success messages.
 l_index:= g_error_tbl.first;
 WHILE (l_index IS NOT NULL) LOOP
      x_error_tbl(x_error_tbl.count + 1) := g_error_tbl(l_index);

 l_index:= g_error_tbl.next(l_index);
 END LOOP;



 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;
EXCEPTION
 WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     fnd_msg_pub.add;
END Process_Address;


END WSH_SUPPLIER_PARTY;

/
