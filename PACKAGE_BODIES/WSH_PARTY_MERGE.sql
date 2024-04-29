--------------------------------------------------------
--  DDL for Package Body WSH_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PARTY_MERGE" as
/* $Header: WSHPAMRB.pls 120.12 2007/11/21 06:02:56 ueshanka noship $ */
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_PARTY_MERGE';

--
-- R12 FP Bug 5075838
--
TYPE Shipping_Param_Tab IS TABLE OF WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ INDEX BY BINARY_INTEGER;

--
G_PARAM_INFO_TAB    Shipping_Param_Tab;
G_WMS_ENABLED       WSH_UTIL_CORE.Column_Tab_Type;
G_DELIVERY_ID       WSH_UTIL_CORE.Id_Tab_Type;
G_FTE_INSTALLED     VARCHAR2(10);
G_FETCH_LIMIT       CONSTANT NUMBER        := 10000;


 --========================================================================
  -- PROCEDURE :merge_carriers
  -- PARAMETERS:
  --		p_entity_name			Name of Entity Being Merged
  --		p_from_id				Primary Key Id of the entity that is being merged
  --		p_to_id				The record under the 'To Parent' that is being merged
  --		p_from_fk_id			Foreign Key id of the Old Parent Record
 --		p_to_fk_id			Foreign  Key id of the New Parent Record
 --		p_parent_entity_name	Name of Parent Entity
 --		p_batch_id			Id of the Batch
 --		p_batch_party_id		Id uniquely identifies the batch and party record that is being merged
 --		x_return_status			 Returns the staus of call
 --
 -- COMMENT   : Carriers cannot be merged.
 --========================================================================
PROCEDURE merge_carriers(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       IN  OUT NOCOPY VARCHAR2) IS

l_from_carrier_num NUMBER;

Cursor C_Carriers(p_carrier_id NUMBER) IS
SELECT 1
FROM wsh_carriers
WHERE carrier_id = p_carrier_id;
 --
 -- R12 Vendor Merge
 --
 CURSOR c_GetVendorId(p_partyId IN NUMBER) IS
 SELECT vendor_id, vendor_name
 FROM po_vendors
 WHERE party_id = p_partyId;
 --
 l_fromVendorID    NUMBER;
 l_toVendorID      NUMBER;
 l_fromSupName     VARCHAR2(360);
 l_toSupName       VARCHAR2(360);
 l_return_Status   VARCHAR2(1);
 --
BEGIN

  x_return_status := FND_API.G_RET_STS_ERROR;

  IF (p_from_fk_id = p_to_fk_id) THEN
    p_to_id := p_from_id;
    RETURN;
  END IF;

  IF (p_from_fk_id <> p_to_fk_id) THEN
    IF (p_parent_entity_name = 'HZ_PARTIES') THEN

      OPEN C_Carriers(p_from_fk_id);
      FETCH C_Carriers INTO l_from_carrier_num;
      CLOSE C_Carriers;

      IF ( l_from_carrier_num > 0  )  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_NO_MERGE');
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;
    END IF;
  END IF;
  --
  -- R12 Vendor Merge
  --
  -- (a) Derive vendor IDs for the from/to party IDs
  -- (b) Check if both parties are Vendors
  -- (c) If both from and to parties are vendors, then call
  -- Update_Entities_During_Merge
  -- (d) Else If fromVendor ID is not NULL, then
  -- delete from wsh_calendar_assignments
  --
  OPEN c_GetVendorId(p_from_id);
  FETCH c_GetVendorId INTO l_fromVendorID, l_fromSupName;
  CLOSE c_GetVendorId;
  --
  OPEN c_GetVendorId(p_to_id);
  FETCH c_GetVendorId INTO l_toVendorID, l_toSupName;
  CLOSE c_GetVendorId;
  --
  IF l_fromVendorID IS NOT NULL AND l_toVendorID IS NOT NULL THEN
   --
   Update_Entities_During_Merge
      (
        p_to_id              => l_toVendorID,
        p_from_id            => l_fromVendorID,
        p_from_party_id      => p_from_id ,
        p_to_party_id        => p_to_id ,
        p_to_site_id         => NULL,
        p_from_site_id       => NULL,
        p_site_merge         => FALSE,
        p_from_supplier_name => l_fromSupName,
        x_return_status      => l_return_status
      );
   --
   x_return_status := l_return_status;
   --
  ELSIF l_fromVendorID IS NOT NULL THEN
   --
   DELETE wsh_calendar_assignments
   WHERE vendor_id = l_fromVendorID
   AND vendor_site_id IS NULL;
   --
  END IF;
  --
EXCEPTION WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR','HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
  FND_MSG_PUB.ADD;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END merge_carriers;

 --========================================================================
  -- PROCEDURE :merge_carrier_sites
  -- PARAMETERS:
  --		p_entity_name			Name of Entity Being Merged
  --		p_from_id				Primary Key Id of the entity that is being merged
  --		p_to_id				The record under the 'To Parent' that is being merged
  --		p_from_fk_id			Foreign Key id of the Old Parent Record
 --		p_to_fk_id			Foreign  Key id of the New Parent Record
 --		p_parent_entity_name	Name of Parent Entity
 --		p_batch_id			Id of the Batch
 --		p_batch_party_id		Id uniquely identifies the batch and party record that is being merged
 --		x_return_status			 Returns the staus of call
 --
 -- COMMENT   : Carriers Sites cannot be merged.
 --========================================================================
PROCEDURE merge_carrier_sites(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       IN  OUT NOCOPY VARCHAR2) IS

Cursor C_Carrier_Sites(p_carrier_site_id NUMBER) IS
	SELECT 1
	FROM wsh_carrier_sites
	WHERE carrier_site_id = p_carrier_site_id;

l_from_carrier_site_num NUMBER;

BEGIN

  IF (p_from_fk_id = p_to_fk_id) THEN
    p_to_id := p_from_id;
    RETURN;
  END IF;

  IF (p_from_fk_id <> p_to_fk_id) THEN
    IF (p_parent_entity_name = 'HZ_PARTY_SITES') THEN

      OPEN C_Carrier_Sites(p_from_fk_id);
      FETCH C_Carrier_Sites INTO l_from_carrier_site_num;
      CLOSE C_Carrier_Sites;

      IF ( l_from_carrier_site_num > 0 ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_SITE_NO_MERGE');
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;

   END IF;
 END IF;

EXCEPTION WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR','HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
  FND_MSG_PUB.ADD;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END merge_carrier_sites;

--========================================================================
  -- PROCEDURE :check_duplicate_rec
  -- PARAMETERS:
  --		p_from_pk			        Primary key id of the FROM record
  --		p_to_party_id			        Owner party id of the TO record
  --		x_dup_rec_pk 			        Return -1 if duplicate record exists
  --		x_return_status				 Returns the staus of call
  --
  -- COMMENT :  Procedure to Check Duplicates
 --========================================================================


PROCEDURE check_duplicate_rec(
		p_from_pk				IN	NUMBER,
		p_to_party_id			        IN	NUMBER,
	        x_dup_rec_pk 				IN  OUT NOCOPY NUMBER,
		x_return_status				IN  OUT NOCOPY VARCHAR2)
IS

CURSOR c_check_duplicate(p_location_id IN NUMBER,  p_party_id IN NUMBER) IS
SELECT location_owner_id
FROM    wsh_location_owners
WHERE wsh_location_id =  p_location_id
AND      owner_party_id =  p_party_id;

CURSOR c_populate_data(p_loc_owner_id IN NUMBER) IS
SELECT  wsh_location_id
FROM     wsh_location_owners
WHERE  location_owner_id = p_loc_owner_id;

l_location_id	NUMBER;
--l_owner_type	NUMBER;
l_dup_rowid     NUMBER;

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	OPEN  c_populate_data(p_from_pk);
	FETCH c_populate_data INTO l_location_id;
	CLOSE c_populate_data;

	OPEN  c_check_duplicate(l_location_id,p_to_party_id);
	FETCH c_check_duplicate INTO l_dup_rowid;
	IF (c_check_duplicate%NOTFOUND) THEN
		x_dup_rec_pk := -1;
	ELSE
		x_dup_rec_pk := l_dup_rowid;
	END IF;
	CLOSE c_check_duplicate;

EXCEPTION
WHEN others THEN
        IF  c_populate_data%ISOPEN THEN
	    CLOSE  c_populate_data;
	END IF;
        IF  c_check_duplicate%ISOPEN THEN
	    CLOSE  c_check_duplicate;
	END IF;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
END check_duplicate_rec;


 --========================================================================
  -- PROCEDURE :merge_party_locations
  -- PARAMETERS:
  --		p_entity_name			Name of Entity Being Merged
  --		p_from_id				Primary Key Id of the entity that is being merged
  --		p_to_id				The record under the 'To Parent' that is being merged
  --		p_from_fk_id			Foreign Key id of the Old Parent Record
 --		p_to_fk_id			Foreign  Key id of the New Parent Record
 --		p_parent_entity_name	Name of Parent Entity
 --		p_batch_id			Id of the Batch
 --		p_batch_party_id		Id uniquely identifies the batch and party record that is being merged
 --		x_return_status			 Returns the staus of call
 --
 -- COMMENT :  To merge locations for parties.-Parent Entity is HZ_PARTIES.
 --			   Owner Type can be either Supplier or Customer, Carriers cannot be merged
 --			   Updates OWNER_PARTY_ID and OWNER_TYPE in WSH_LOCATION_OWNERS
 --========================================================================

PROCEDURE  merge_party_locations(
p_entity_name			IN				  VARCHAR2,
p_from_id			        IN				  NUMBER,
p_to_id				IN	OUT NOCOPY NUMBER,
p_from_fk_id			IN				  NUMBER,
p_to_fk_id			IN				  NUMBER,
p_parent_entity_name	IN				  VARCHAR2,
p_batch_id			IN				  NUMBER,
p_batch_party_id		IN				  NUMBER,
x_return_status			IN  OUT NOCOPY   VARCHAR2) IS

Cursor C_Owner_Type(p_party_id NUMBER) IS
SELECT owner_type
FROM   wsh_location_owners
WHERE  owner_party_id = p_party_id;

CURSOR check_party_carrier_supplier(c_party_id IN NUMBER) IS
SELECT 3
FROM   wsh_carriers c
WHERE  c.carrier_id = c_party_id
UNION ALL
SELECT 4
FROM   hz_relationships r, po_vendors v
WHERE  r.relationship_type = 'POS_VENDOR_PARTY' AND
       r.subject_id = v.vendor_id AND
       r.object_id = c_party_id;

CURSOR get_loc_owners_for_update(p_from_party_id IN NUMBER,p_from_id IN NUMBER) IS
SELECT owner_party_id,
       owner_type,
       last_update_date,
       last_updated_by,
       last_update_login
FROM   wsh_location_owners
WHERE  location_owner_id =  p_from_id
AND    owner_party_id = p_from_party_id
FOR UPDATE NOWAIT;

l_owner_type_from		NUMBER;
l_owner_type_to		        NUMBER;
x_dup_pk			NUMBER;
l_loc_owners_rec                get_loc_owners_for_update%rowtype;

RESOURCE_BUSY                   EXCEPTION;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	/*     If the parent has NOT change then nothing needs to be done
		Set Merged To Id is same as Merged From Id
	*/
	IF  p_from_FK_id = p_to_FK_id THEN
			p_to_id:=p_from_id;
			return;
	END IF;

       /*Business Validations - Carriers cannot be merged */
       OPEN  C_Owner_Type(p_from_FK_id);
       FETCH C_Owner_Type INTO l_owner_type_from;
       CLOSE C_Owner_Type;

       IF  (l_owner_type_from=3) THEN
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_SITE_NO_MERGE');
		 FND_MSG_PUB.ADD;
		RETURN;
       END IF;

       l_owner_type_to := 2;

       OPEN  C_Owner_Type(p_to_FK_id);
       FETCH C_Owner_Type INTO l_owner_type_to;

       IF C_Owner_Type%NOTFOUND THEN
            OPEN check_party_carrier_supplier(p_to_FK_id);
            FETCH check_party_carrier_supplier INTO l_owner_type_to;
            CLOSE check_party_carrier_supplier;

            -- If party is carrier OR supplier,
            -- l_owner_type will be 3 OR 4 ( <> 2)
            -- Otherwise, value of l_owner_type will not change

            IF (l_owner_type_to IS NULL) THEN
               l_owner_type_to := 2;
            END IF;
       END IF;
       CLOSE C_Owner_Type;
       IF  (l_owner_type_to=3) THEN
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_SITE_NO_MERGE');
		 FND_MSG_PUB.ADD;
	 	 RETURN;
       END IF;

       check_duplicate_rec(	p_from_pk		=>	p_from_id,
				p_to_party_id		=>	p_To_fk_id,
				x_dup_rec_pk		=>	x_dup_pk,
				x_return_status		=>      x_return_status);

       IF (x_return_status =  FND_API.G_RET_STS_SUCCESS) THEN

				IF  (x_dup_pk = -1)  THEN
					-- Duplicate row does not exist.

					OPEN     get_loc_owners_for_update( p_from_fk_id,p_from_id);
					FETCH    get_loc_owners_for_update  INTO l_loc_owners_rec;

                                        IF get_loc_owners_for_update%FOUND THEN
					--No Wait will raise the exception

					  UPDATE  wsh_location_owners
					  SET	owner_party_id		=  p_to_fk_id,
						owner_type		=  l_owner_type_to,
						last_update_date	=  hz_utility_pub.last_update_date,
						last_updated_by	        =  hz_utility_pub.user_id,
						last_update_login	=  hz_utility_pub.request_id
					  WHERE owner_party_id          =  p_from_fk_id
                                          AND   location_owner_id       =  p_from_id;

                                        END IF;

			                IF  get_loc_owners_for_update%ISOPEN THEN
					    CLOSE  get_loc_owners_for_update;
					END IF;

					RETURN;
				 ELSE
					-- duplicate row exists
					p_to_id := x_dup_pk;
					RETURN;
				 END IF;
       ELSE
                                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

EXCEPTION
WHEN RESOURCE_BUSY THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_NO_LOCK');
	FND_MSG_PUB.ADD;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	FND_MESSAGE.SET_NAME('AR','HZ_API_OTHERS_EXCEP');
	FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
WHEN others THEN
        IF  C_Owner_Type%ISOPEN THEN
	    CLOSE  C_Owner_Type;
	END IF;
        IF  check_party_carrier_supplier%ISOPEN THEN
	    CLOSE  check_party_carrier_supplier;
	END IF;
        IF  get_loc_owners_for_update%ISOPEN THEN
	    CLOSE  get_loc_owners_for_update;
	END IF;
	FND_MESSAGE.SET_NAME('AR','HZ_API_OTHERS_EXCEP');
	FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END merge_party_locations;

 --========================================================================
  -- PROCEDURE :        Merge_supplier_sf_sites
  -- PARAMETERS:
  --            p_entity_name              Name of registered table/entity
  --            p_from_id                  Value of PK of the record being merged
  --            x_to_id                    Value of the PK of the record to which this record is mapped
  --            p_from_fk_id               Value of the from ID (e.g. Party, Party Site, etc.) when merge is executed
 --             p_to_fk_id                 Value of the to ID (e.g. Party, Party Site, etc.) when merge is executed
 --             p_parent_entity_name       Name of parent HZ table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
 --             p_batch_id                 ID of the batch
 --             p_batch_party_id           ID of the batch and Party record
 --             x_return_status            Return status
 --
 -- COMMENT :
 --========================================================================
Procedure Merge_supplier_sf_sites (
        p_entity_name          IN           VARCHAR2,
        p_from_id              IN           NUMBER,
        x_to_id                OUT  NOCOPY  NUMBER,
        p_from_fk_id           IN           NUMBER,
        p_to_fk_id             IN           NUMBER,
        p_parent_entity_name   IN           VARCHAR2,
        p_batch_id             IN           NUMBER,
        p_batch_party_id       IN           NUMBER,
        x_return_status        OUT  NOCOPY  VARCHAR2  ) IS
        --
        l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'merge_supplier_sf_sites';
        l_debug_on         BOOLEAN;
        --
        l_query_count      NUMBER;
        l_msg              VARCHAR2(2000);
        l_to_vendor_id     NUMBER;
        l_to_party_id      NUMBER;
        l_from_party_id    NUMBER;
        l_location_id      NUMBER;
        l_num_errors       NUMBER := 0;
        l_num_warnings     NUMBER := 0;
        l_Return_Status    VARCHAR2(1);
        --
        CURSOR getPartyId(p_party_site_id IN NUMBER) IS
        SELECT party_id
        FROM hz_party_Sites
        WHERE party_site_id = p_party_site_id;
        --
        CURSOR getVendorID(p_party_id IN NUMBER) IS
        SELECT vendor_id
        FROM po_vendors
        WHERE party_id = p_party_id;
        --
        CURSOR getLocationID(p_party_site_id NUMBER) IS
        SELECT location_id
        FROM hz_party_sites
        WHERE party_site_id = p_from_fk_id;
        --
BEGIN
 --{
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL THEN
           l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
         WSH_DEBUG_SV.log(l_module_name, 'p_entity_name', p_entity_name);
         WSH_DEBUG_SV.log(l_module_name, 'p_from_id', p_from_id);
         WSH_DEBUG_SV.log(l_module_name, 'p_from_fk_id', p_from_fk_id);
         WSH_DEBUG_SV.log(l_module_name, 'p_to_fk_id', p_to_fk_id);
         WSH_DEBUG_SV.log(l_module_name, 'p_parent_entity_name', p_parent_entity_name);
         WSH_DEBUG_SV.log(l_module_name, 'p_batch_id', p_batch_id);
         WSH_DEBUG_SV.log(l_module_name, 'p_batch_party_id', p_batch_party_id);
        END IF;
        --
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        IF  p_from_FK_id = p_to_FK_id THEN
          --
          x_to_id:=p_from_id;
          --
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'p_from_fk_id = p_to_fk_id', WSH_DEBUG_SV.C_STMT_LEVEL);
           WSH_DEBUG_SV.log(l_module_name, 'x_to_id', x_to_id);
           WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          RETURN;
          --
        END IF;
        --
        IF p_from_FK_id <> p_to_FK_id THEN
        --{
                IF p_parent_entity_name = 'HZ_PARTY_SITES' THEN
                --{
                        BEGIN
                             --
                             -- R12 Perf Bug 4949639 : Replace WND with WDD
                             -- since all we are looking for existence of records
                             -- with a particular SF location ID
                             --
                             SELECT 1
                             INTO l_query_count
                             FROM wsh_delivery_details wdd,
                                  hz_party_Sites hps,
                                  wsh_locations wl
                             WHERE hps.party_site_id = p_from_fk_id
                             AND wdd.ship_from_location_id = wl.wsh_location_id
                             AND hps.location_id = wl.source_location_id
                             AND wdd.party_id = hps.party_id
                             AND rownum =1;
                        EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                      l_query_count := 0;
                        END;
                        --
                        IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name, 'l_query_count', l_query_count);
                        END IF;
                        --
                        IF l_query_count > 0 THEN
                         --{
                                --Put an error messge on stack
                                fnd_message.set_name ( 'WSH', 'WSH_IB_SP_SHIP_SITE_NO_MERGE' );
                                wsh_util_core.add_message (WSH_UTIL_CORE.G_RET_STS_ERROR, l_Module_name);
                                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                                --
                                IF l_debug_on THEN
                                 WSH_DEBUG_SV.logmsg(l_module_name, 'Supplier SF sites cannot be merged', WSH_DEBUG_SV.C_STMT_LEVEL);
                                 WSH_DEBUG_SV.log(l_module_name, 'x_Return_Status', x_Return_Status);
                                 WSH_DEBUG_SV.pop(l_module_name);
                                END IF;
                                --
                                RETURN;
                         --}
                        ELSIF l_query_count = 0 THEN
                         --{
                         OPEN getPartyId(p_from_fk_id);
                         FETCH getPartyID INTO l_from_party_id;
                         CLOSE getPartyID;
                         --
                         IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name, 'Merge From Party ID', l_from_party_id);
                         END IF;
                         --
                         OPEN getPartyID(p_to_fk_id);
                         FETCH getPartyID INTO l_to_party_id;
                         CLOSE getPartyID;
                         --
                         IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name, 'Merge to Party ID', l_to_party_id);
                         END IF;
                         --
                         OPEN getVendorID(l_to_party_id);
                         FETCH getVendorID INTO l_to_vendor_id;
                         CLOSE getVendorID;
                         --
                         IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name, 'Merge to Vendor ID', l_to_vendor_id);
                         END IF;
                         --
                         OPEN getLocationID(p_from_fk_id);
                         FETCH getLocationID INTO l_location_id;
                         CLOSE getLocationID;
                         --
                         IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name, 'Location ID', l_location_id);
                         END IF;
                         --
                         IF l_from_party_id <> l_to_party_id THEN
                          --{
                          IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name, 'Calling create_site', WSH_DEBUG_SV.C_PROC_LEVEL);
                          END IF;
                          --
                          WSH_VENDOR_PARTY_MERGE_PKG.Create_Site
                             (
                               p_from_id      => l_from_party_id,
                               p_to_id        => l_to_party_id,
                               p_to_vendor_id => l_to_vendor_id,
                               p_delivery_id  => NULL,
                               p_delivery_name => NULL,
                               p_location_id   => l_location_id,
                               x_return_status => l_return_status
                             );
                          --
                          IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name, 'After calling Create_Site, return status', l_return_status);
                          END IF;
                          --
                          WSH_UTIL_CORE.api_post_call
                             (
                               p_return_status    => l_return_status,
                               x_num_warnings     => l_num_warnings,
                               x_num_errors       => l_num_errors
                             );
                          --}
                         END IF;
                         --}
                        END IF;
                --}
                END IF ;
        --}
        END IF;
        --
        IF l_num_errors > 0 THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        ELSIF l_num_warnings > 0 THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        END IF;
        --
        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'x_return_Status', x_return_status);
         WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
EXCEPTION
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'In When Others, Error Msg is', SUBSTRB(SQLERRM, 1, 200));
         WSH_DEBUG_SV.log(l_module_name, 'x_return_Status', x_return_status);
         WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --

--}
END Merge_supplier_sf_sites;


--========================================================================
-- PROCEDURE : Update_Entities_During_merge
--
-- PARAMETERS:
--
--     p_to_id                     Merge To Vendor ID
--     p_from_id                   Merge From Vendor ID
--     p_from_party_id             Merge From Party ID
--     p_to_party_id               Merge To Party ID
--     p_to_site_id                Merge To Site ID
--     p_from_site_id              Merge From Site ID
--     p_site_merge                Indicates whether this is a site merge
--     p_from_supplier_name        Merge From Supplier Name
--     x_return_status             Return status
--
--
-- COMMENT : This procedure is used to merge vendor level calendar assignments
--           during Party Merge and Vendor Merge.
--
--==========================================================================
PROCEDURE Update_Entities_during_Merge
       (
         p_to_id         IN NUMBER,
         p_from_id       IN NUMBER,
         p_from_party_id IN NUMBER,
         p_to_party_id   IN NUMBER,
         p_to_site_id    IN NUMBER,
         p_from_site_id  IN NUMBER,
         p_site_merge    IN BOOLEAN,
         p_from_supplier_name IN VARCHAR2,
         x_return_status OUT NOCOPY VARCHAR2
       )
IS
  --
  CURSOR check_calendar IS
  SELECT calendar_type,
         calendar_assignment_id,
         vendor_site_id,
         association_type,
         freight_code
  FROM wsh_calendar_assignments a
  WHERE vendor_id = p_from_id
  AND vendor_site_id IS NULL;
  --
  CURSOR check_dup_assignment(p_vendor_id NUMBER,
                              p_calendar_Type VARCHAR2,
                              p_vendor_site_id NUMBER,
                              p_association_type VARCHAR2,
                              p_freight_code VARCHAR2 )
  IS
  SELECT 1
  FROM wsh_calendar_assignments
  WHERE vendor_id = p_vendor_id
  AND calendar_type=p_calendar_type
  AND nvl( vendor_site_id,-999999 ) = nvl( p_vendor_site_id,-999999 )
  AND association_type = p_association_type
  AND nvl( freight_code, '!!!' ) = nvl( p_freight_code, '!!!' );
  --
  l_debug_on    BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.update_entities_during_merge';
  --
  l_msg         VARCHAR2(32767);
  l_dummy       NUMBER;
  --
BEGIN
  --
  WSH_UTIL_CORE.enable_concurrent_log_print;
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.push(l_module_name);
   WSH_DEBUG_SV.log(l_module_name,'P_TO_ID',p_to_id);
   WSH_DEBUG_SV.log(l_module_name,'P_FROM_ID',p_from_id);
   WSH_DEBUG_SV.log(l_module_name,'P_TO_PARTY_ID',p_to_party_id);
   WSH_DEBUG_SV.log(l_module_name,'P_FROM_PARTY_ID',p_from_party_id);
   WSH_DEBUG_SV.log(l_module_name,'P_TO_SITE_ID',p_to_site_id);
   WSH_DEBUG_SV.log(l_module_name,'P_FROM_SITE_ID',p_from_site_id);
   WSH_DEBUG_SV.log(l_module_name,'P_SITE_MERGE',p_site_merge);
   WSH_DEBUG_SV.log(l_module_name,'P_FROM_SUPPLIER_NAME',p_from_supplier_name);
  END IF;
  --
  IF NOT (p_site_merge) THEN
   --{
   UPDATE wsh_carriers
   SET supplier_id = p_to_id,
       last_update_date = sysdate,
       last_updated_by = fnd_global.user_id,
       last_update_login = fnd_global.login_id
   WHERE supplier_id = p_from_id
   AND   supplier_site_id IS NULL;
   --
   IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'No. of rows in WSH_carriers that were updated', SQL%ROWCOUNT);
   END IF;
   --
   FOR check_calendar_rec IN check_calendar
   LOOP
    --{
    IF l_debug_on THEN
     --
     WSH_DEBUG_SV.logmsg(l_module_name, '----------------------------', WSH_DEBUG_SV.C_STMT_LEVEL);
     WSH_DEBUG_SV.log(l_module_name,'CHECK_CALENDAR_REC.CALENDAR_TYPE', check_calendar_rec.calendar_type);
     WSH_DEBUG_SV.log(l_module_name,'CHECK_CALENDAR_REC.CALENDAR_ASSIGNMENT_ID',check_calendar_rec.calendar_assignment_id);
     WSH_DEBUG_SV.log(l_module_name,'CHECK_CALENDAR_REC.VENDOR_SITE_ID', check_calendar_rec.vendor_site_id);
     WSH_DEBUG_SV.log(l_module_name,'CHECK_CALENDAR_REC.ASSOCIATION_TYPE', check_calendar_rec.association_type);
     WSH_DEBUG_SV.log(l_module_name,'CHECK_CALENDAR_REC.FREIGHT_CODE', check_calendar_rec.freight_code);
     --
    END IF;
    --
    OPEN check_dup_assignment
                 (
                  p_vendor_id      => p_to_id,
                  p_calendar_Type  => check_calendar_Rec.calendar_type,
                  p_vendor_site_id => check_calendar_rec.vendor_site_id,
                  p_association_type => check_calendar_rec.association_type ,
                  p_freight_code     => check_calendar_rec.freight_code
                 );
    FETCH check_dup_assignment INTO l_dummy;
    --
    IF (check_dup_assignment%NOTFOUND) THEN
     --{
     -- Update vendor level assignments
     --
     UPDATE wsh_calendar_assignments
     SET  vendor_id = p_to_id,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
     WHERE calendar_assignment_id = check_calendar_rec.calendar_assignment_id;
     --
     IF l_debug_on THEN
      --
      WSH_DEBUG_SV.log(l_module_name, 'Calendar Assgn ID updated', check_calendar_rec.calendar_assignment_id);
      WSH_DEBUG_SV.log(l_module_name,'Number of Rows updated is', sql%rowcount);
      --
     END IF;
     --}
    ELSE
     --{
     --
     DELETE wsh_calendar_assignments
     WHERE calendar_assignment_id = check_calendar_rec.calendar_assignment_id;
     --
     IF l_debug_on THEN
      --
      WSH_DEBUG_SV.log(l_module_name, 'Deleted cal. assgn ID',
                       check_calendar_rec.calendar_assignment_id);
      WSH_DEBUG_SV.log(l_module_name,'Number of Rows deleted is', sql%rowcount);
      --
     END IF;
     --
     IF check_calendar_rec.freight_code IS NULL THEN
      fnd_message.set_name('WSH', 'WSH_IB_DEL_SP_CAL_ASGN' );
     ELSE
      fnd_message.set_name('WSH', 'WSH_IB_DEL_SP_FC_CAL_ASGN' );
      fnd_message.set_token('FREIGHT_CODE', check_calendar_rec.freight_code);
     END IF;
     --
     fnd_message.set_token('SUPPLIER_NAME' , p_from_supplier_name );
     fnd_message.set_token('CAL_TYPE' , check_calendar_Rec.calendar_type );
     l_msg := FND_MESSAGE.GET;
     wsh_util_core.printMsg(l_msg);
     --}
    END IF;-- IF (check_dup_assignment %NOTFOUND)
    --
    CLOSE check_dup_assignment;
    --}
   END LOOP;-- FOR check_calendar_rec IN check_calendar
   --}
  END IF;
  --
  IF l_debug_on THEN
   wsh_debug_sv.log(l_module_name, 'x_return_status', x_return_status);
   wsh_debug_sv.pop(l_module_name);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
   wsh_util_core.default_handler('WSH_PARTY_MERGE.Update_Entities_during_merge');
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occurred.
occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    --
   END IF;
   --
END Update_Entities_During_Merge;

/* Start of comment for bug 5749968
--
-- Start : R12 FP Bug 5075838
--
-- ===============================================================================
-- PROCEDURE  :    ADJUST_WEIGHT_VOLUME
-- PARAMETERS :
--   p_entity_type             CONT      - While unassigning from Containers
--                             DEL-CONT  - While unassigning from Deliveries/LPN's
--
--   p_delivery_detail         array of delivery detail id
--   p_parent_delivery_detail  array of parent delivery detail id
--   p_delivery_id             array of delivery id
--   p_delivery_leg_id         array of delivery leg id
--   p_net_weight              array of net weight
--   p_gross_weight            array of gross weight
--   p_volume                  array of volume
--   p_inventory_item_id       array inventory item id
--   p_organization_id         array of organization id
--   p_weight_uom              array of weight UOM code
--   p_volume_uom              array of volume UOM code
--   x_return_status           Returns the status of call
--
-- COMMENT :
--   API to decrement the delivery detail weight from LPN/Delivery while
--   unassigning delivery line from LPN/Delivery
--   Code is similar to WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_From_Cont
--   when p_entity_type is 'CONT'
--   Code is similar to WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_From_Delivery
--   when p_entity_type is 'DEL-CONT'
-- ===============================================================================
-- Bug 5606960# G-Log Changes: Removed Weight/Volume calculation while
--              unassigning delivery from Trip.

PROCEDURE Adjust_Weight_Volume (
                 p_entity_type            IN  VARCHAR2,
                 p_delivery_detail        IN  WSH_UTIL_CORE.Id_Tab_Type,
                 p_parent_delivery_detail IN  WSH_UTIL_CORE.Id_Tab_Type,
                 p_delivery_id            IN  WSH_UTIL_CORE.Id_Tab_Type,
                 p_delivery_leg_id        IN  WSH_UTIL_CORE.Id_Tab_Type,
                 p_net_weight             IN  WSH_UTIL_CORE.Id_Tab_Type,
                 p_gross_weight           IN  WSH_UTIL_CORE.Id_Tab_Type,
                 p_volume                 IN  WSH_UTIL_CORE.Id_Tab_Type,
                 x_return_status          OUT NOCOPY VARCHAR2 )
IS
   l_return_status               VARCHAR2(10);
   Weight_Volume_Exp             EXCEPTION;

   --
   l_debug_on                    BOOLEAN;
   l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Adjust_Weight_Volume';
   --
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      -- Printing the parameters passed to API
      WSH_DEBUG_SV.log(l_module_name, 'p_entity_type', p_entity_type );
   END IF;
   --

   -- Call Mark_Reprice_Reqired, only when Unassigning from delivery
   -- and FTE is Installed
   IF ( p_entity_type = 'DEL-CONT' and
        G_FTE_INSTALLED = 'Y' )
   THEN
   -- { Mark Reprice
      l_return_status := NULL;

      WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required (
                 p_entity_type   => 'DELIVERY',
                 p_entity_ids    => p_delivery_id,
                 x_return_status => l_return_status);

      IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                    WSH_UTIL_CORE.G_RET_STS_WARNING) )
      THEN
         --
         IF ( l_debug_on ) THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error While Calling WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required');
            WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
         END IF;
         --
         RAISE Weight_Volume_Exp;
      END IF;
   -- } Mark Reprice
   END IF;

   IF ( p_entity_type in ( 'CONT', 'DEL-CONT' ) )
   THEN
   -- { Entity type
      -- Weight/Volume adjustments
      FOR wvCnt IN p_delivery_detail.FIRST..p_delivery_detail.LAST
      LOOP
      -- { W/V adjustment Loop
         -- Call WV API, If
         --   1. CONT
         --      When Unassigning from container(delivery detail is assigned to
         --      container but not assigned to a delivery.
         -- OR
         --   2. DEL-CONT
         --      When Unassigning from delivery
         IF ( ( p_entity_type = 'CONT'       AND
                p_delivery_id(wvCnt) IS NULL AND
                p_parent_delivery_detail(wvCnt) IS NOT NULL ) OR
              ( p_entity_type = 'DEL-CONT' ) )
         THEN
            l_return_status := NULL;

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_WV_UTILS.DD_WV_Post_Process', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --

            WSH_WV_UTILS.DD_WV_Post_Process (
                   p_delivery_detail_id  =>   p_delivery_detail(wvCnt),
                   p_diff_gross_wt       =>  -1 * p_gross_weight(wvCnt),
                   p_diff_net_wt         =>  -1 * p_net_weight(wvCnt),
                   p_diff_volume         =>  -1 * p_volume(wvCnt),
                   p_diff_fill_volume    =>  -1 * p_volume(wvCnt),
                   p_check_for_empty     =>  'Y',
                   x_return_status       =>  l_return_status );

            IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                          WSH_UTIL_CORE.G_RET_STS_WARNING) )
            THEN
               --
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Error While Calling WSH_WV_UTILS.DD_WV_Post_Process : ' || l_return_status);
               END IF;
               --
               RAISE Weight_Volume_Exp;
            END IF;
         END IF;
      -- } W/V adjustment Loop
      END LOOP;
   -- } Entity Type

   END IF;

   --
   IF ( l_debug_on ) THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

EXCEPTION
   WHEN Weight_Volume_Exp THEN
      x_return_status := l_return_status;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Weight_Volume_Exp Exception occurred in Adjust_Weight_Volume');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Unexpected Error in Adjust_Weight_Volume');
         WSH_DEBUG_SV.log(l_module_name, 'Error Code', sqlcode);
         WSH_DEBUG_SV.log(l_module_name, 'Error Mesg', sqlerrm);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
END Adjust_Weight_Volume;
--
--
-- ===============================================================================
-- PROCEDURE  :    ADJUST_PARENT_WV
-- PARAMETERS :
--   p_entity_type             CONT      - While unassigning from Containers
--                             DEL-CONT  - While unassigning from Deliveries/LPN's
--   p_delivery_detail         array of delivery detail id
--   p_parent_delivery_detail  array of parent delivery detail id
--   p_delivery_id             array of delivery id
--   p_inventory_item_id       array inventory item id
--   p_organization_id         array of organization id
--   p_weight_uom              array of weight UOM code
--   p_volume_uom              array of volume UOM code
--   x_return_status           Returns the status of call
--
-- COMMENT :
--   API to adjust the 'Fill Percent' if Percent Fill Basis is defined as Quantity.
--   Code is similar to WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_From_Cont
--   when p_entity_type is 'CONT'
--   Code is similar to WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_From_Delivery
--   when p_entity_type is 'DEL-CONT'
-- ===============================================================================
PROCEDURE Adjust_Parent_WV (
                 p_entity_type            IN  VARCHAR2,
                 p_delivery_detail        IN  WSH_UTIL_CORE.Id_Tab_Type,
                 p_parent_delivery_detail IN  WSH_UTIL_CORE.Id_Tab_Type,
                 p_delivery_id            IN  WSH_UTIL_CORE.Id_Tab_Type,
                 p_inventory_item_id      IN  WSH_UTIL_CORE.Id_Tab_Type,
                 p_organization_id        IN  WSH_UTIL_CORE.Id_Tab_Type,
                 p_weight_uom             IN  WSH_UTIL_CORE.Column_Tab_Type,
                 p_volume_uom             IN  WSH_UTIL_CORE.Column_Tab_Type,
                 x_return_status  OUT NOCOPY  VARCHAR2 )
IS
   l_param_info                  WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
   l_return_status               VARCHAR2(10);

   Weight_Volume_Exp             EXCEPTION;

   --
   l_debug_on                    BOOLEAN;
   l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || 'WSH_PARTY_MERGE' || '.' || 'Adjust_Parent_WV';
   --
   --
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      -- Printing the parameters passed to API
      WSH_DEBUG_SV.log(l_module_name, 'p_entity_type', p_entity_type );
   END IF;
   --

   -- Weight/Volume adjustments
   FOR wvCnt IN p_delivery_detail.FIRST..p_delivery_detail.LAST
   LOOP
   -- { W/V adjustment Loop
      -- Call WV API, If
      --   1. CONT
      --      When Unassigning from container(i.e., delivery detail is assigned to
      --      container but not assigned to a delivery.
      -- OR
      --   2. DEL-CONT
      --      When Unassigning from delivery
      IF ( ( p_entity_type = 'CONT'       AND
             p_delivery_id(wvCnt) IS NULL AND
             p_parent_delivery_detail(wvCnt) IS NOT NULL ) OR
           ( p_entity_type = 'DEL-CONT' ) )
      THEN
      -- {
         l_return_status := NULL;

         IF ( NOT G_PARAM_INFO_TAB.EXISTS(p_organization_id(wvCnt)) )
         THEN
            l_return_status := NULL;

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_SHIPPING_PARAMS_PVT.Get', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --

            WSH_SHIPPING_PARAMS_PVT.Get(
                p_organization_id => p_organization_id(wvCnt),
                x_param_info      => l_param_info,
                x_return_status   => l_return_status);

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
               --
               IF ( l_debug_on ) THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'WSH_SHIPPING_PARAMS_PVT.Get returned '||l_return_status);
               END IF;
               --
               RAISE Weight_Volume_Exp;
            END IF;

            G_PARAM_INFO_TAB(p_organization_id(wvCnt)) := l_param_info;
         END IF;

         IF ( G_PARAM_INFO_TAB(p_organization_id(wvCnt)).Percent_Fill_Basis_Flag = 'Q' AND
              ( ( p_entity_type = 'DEL-CONT' AND p_parent_delivery_detail(wvCnt) IS NOT NULL ) OR
                ( p_entity_type = 'CONT' ) ) )
         THEN
            l_return_status := NULL;

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_WV_UTILS.Adjust_Parent_WV', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --

            WSH_WV_UTILS.Adjust_Parent_WV(
                   p_entity_type   => 'CONTAINER',
                   p_entity_id     => p_parent_delivery_detail(wvCnt),
                   p_gross_weight  => 0,
                   p_net_weight    => 0,
                   p_volume        => 0,
                   p_filled_volume => 0,
                   p_wt_uom_code   => p_weight_uom(wvCnt),
                   p_vol_uom_code  => p_volume_uom(wvCnt),
                   p_inv_item_id   => p_inventory_item_id(wvCnt),
                   x_return_status => l_return_status);

            IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                          WSH_UTIL_CORE.G_RET_STS_WARNING) )
            THEN
               --
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Error While Calling WSH_WV_UTILS.Adjust_Parent_WV : ' || l_return_status);
               END IF;
               --
               RAISE Weight_Volume_Exp;
            END IF;
         END IF;
      -- }
      END IF;
   -- } W/V adjustment Loop
   END LOOP;

   --
   IF ( l_debug_on ) THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

EXCEPTION
   WHEN Weight_Volume_Exp THEN
      x_return_status := l_return_status;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Weight_Volume_Exp Exception occurred in Adjust_Parent_WV');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Unexpected Error in Adjust_Parent_WV');
         WSH_DEBUG_SV.log(l_module_name, 'Error Code', sqlcode);
         WSH_DEBUG_SV.log(l_module_name, 'Error Mesg', sqlerrm);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
END Adjust_Parent_WV;
End of comment for bug 5749968 */
--
--
--
-- PROCEDURE   : GET_DELIVERY_HASH
--
-- DESCRIPTION :
--     Get_Delivery_Hash generates new hash value and hash string for
--     deliveries(from wsh_tmp table) which are to be updated with new
--     Customer/Location ids
--
-- PARAMETERS  :
--   p_delivery_id       => Delivery Id for which Hash String to be generated
--   p_delivery_detail_id=> Delivery detail for which Hash String to be generated
--   x_hash_string       => Hash string generated
--   x_hash_value        => Hash value generatedds
--   x_return_status   => Return status of API
--   Bug 5471560# Modified API for G-Log Changes
PROCEDURE Get_Delivery_Hash (
          p_delivery_id          IN      NUMBER,
          p_delivery_detail_id   IN      NUMBER,
          x_hash_string     OUT  NOCOPY  VARCHAR2,
          x_hash_value      OUT  NOCOPY  NUMBER,
          x_return_status   OUT  NOCOPY   VARCHAR2 )
IS

   l_grp_attr_tab_type        WSH_DELIVERY_AUTOCREATE.grp_attr_tab_type;
   l_action_code              VARCHAR2(30);
   l_return_status            VARCHAR2(1);


   Update_Hash_Exp            EXCEPTION;
   --
   --
   l_debug_on BOOLEAN;
   l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Delivery_Hash';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



      IF ( NOT G_DELIVERY_ID.EXISTS(p_delivery_id) )
      THEN
      -- {
         -- Need to delete the pl/sql table since its a IN/OUT parameter
         -- Identified it while testing Party Merge Fix
         IF ( l_grp_attr_tab_type.EXISTS(1) ) THEN
            l_grp_attr_tab_type.DELETE(1);
         END IF;

         l_grp_attr_tab_type(1).Entity_Type := 'DELIVERY_DETAIL';
         l_grp_attr_tab_type(1).Entity_Id   := p_delivery_detail_id;

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_DELIVERY_AUTOCREATE.Create_Hash', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         WSH_DELIVERY_AUTOCREATE.Create_Hash (
                      p_grouping_attributes  => l_grp_attr_tab_type,
                      p_group_by_header      => 'N',
                      p_action_code          => l_action_code,
                      x_return_status        => l_return_status );

         --

         --

         IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                       WSH_UTIL_CORE.G_RET_STS_WARNING) )
         THEN
            --
            IF ( l_debug_on ) THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error While Calling WSH_DELIVERY_AUTOCREATE.Create_Hash : ' || l_return_status);
            END IF;
            --
            RAISE Update_Hash_Exp;
         END IF;

      x_hash_string := l_grp_attr_tab_type(1).l1_hash_string;
      x_hash_value  := l_grp_attr_tab_type(1).l1_hash_value;
      G_DELIVERY_ID(p_delivery_id) := p_delivery_id;
      -- }
      END IF;


   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN Update_Hash_Exp THEN
      x_return_status := l_return_status;
      --
      IF ( l_debug_on ) THEN
         WSH_DEBUG_SV.log(l_module_name, 'Update_Hash_Exp Exception occurred in Get_Delivery_Hash');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF ( l_debug_on ) THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Unexpected Error in Get_Delivery_Hash');
         WSH_DEBUG_SV.log(l_module_name, 'Error Code', sqlcode);
         WSH_DEBUG_SV.log(l_module_name, 'Error Mesg', sqlerrm);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
END Get_Delivery_Hash;
--
--
Procedure Check_Wms_Details (
          p_party_site_id    IN   NUMBER,
          p_location_id      IN   NUMBER,
          x_return_status OUT NOCOPY VARCHAR2 )
IS
   CURSOR C1
   IS
      SELECT DISTINCT wdd.organization_id
      from   wsh_delivery_details     wdd,
             wsh_delivery_assignments_v wda,
             hz_cust_acct_sites_all   ca,
             hz_cust_site_uses_all    su
      where  wda.parent_delivery_detail_id is not null
      and    wda.delivery_id is null
      and    wda.delivery_detail_id = wdd.delivery_detail_id
      and    nvl(wdd.line_direction, 'O') in ( 'O', 'IO' )
      and    wdd.container_flag = 'N'
      and    wdd.released_status = 'Y'
      and    wdd.ship_to_location_id = p_location_id
      and    wdd.ship_to_site_use_id = su.site_use_id
      and    su.cust_acct_site_id = ca.cust_acct_site_id
      and    ca.party_site_id = p_party_site_id;

   CURSOR C2
   IS
      SELECT DISTINCT wdd.organization_id
      from   wsh_delivery_details     wdd,
             wsh_delivery_assignments_v wda,
             hz_cust_acct_sites_all   ca,
             hz_cust_site_uses_all    su
      where  wda.parent_delivery_detail_id is not null
      and    wda.delivery_id is not null
      and    wda.delivery_detail_id = wdd.delivery_detail_id
      and    nvl(wdd.line_direction, 'O') in ( 'O', 'IO' )
      and    wdd.container_flag = 'N'
      and    wdd.released_status = 'Y'
      and    wdd.ship_to_location_id = p_location_id
      and    wdd.ship_to_site_use_id = su.site_use_id
      and    su.cust_acct_site_id = ca.cust_acct_site_id
      and    ca.party_site_id = p_party_site_id
      and    exists
           ( select 'X'
             from   wsh_delivery_details     det,
                    wsh_delivery_assignments_v asgn
             where  det.ship_to_site_use_id <> wdd.ship_to_site_use_id
             and    det.delivery_detail_id = asgn.delivery_detail_id
             and    asgn.delivery_id = wda.delivery_id );

   l_org_id_tab       WSH_UTIL_CORE.Id_Tab_Type;
   Wms_Exception      EXCEPTION;
   --
   l_debug_on         BOOLEAN;
   l_module_name      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Wms_Details';
   l_orgn_id          NUMBER;
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name, 'Party Site Id : ' || p_party_site_id || ', Location Id : ' || p_location_id);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN C1;
   LOOP
   -- { Cursor Loop
      FETCH C1 BULK COLLECT INTO l_org_id_tab LIMIT G_FETCH_LIMIT;

      IF ( l_org_id_tab.COUNT > 0 )
      THEN
         FOR orgCnt in l_org_id_tab.FIRST..l_org_id_tab.LAST
         LOOP
            IF ( NOT G_WMS_ENABLED.EXISTS(l_org_id_tab(orgCnt)) )
            THEN
               G_WMS_ENABLED(l_org_id_tab(orgCnt)) := WSH_UTIL_VALIDATE.Check_Wms_Org(l_org_id_tab(orgCnt));
            END IF;

            IF ( G_WMS_ENABLED(l_org_id_tab(orgCnt)) = 'Y' )
            THEN
               --
               IF ( l_debug_on ) THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'There exists WMS records in shipping which are assigned to Containers for organization : ' || WSH_UTIL_CORE.Get_Org_Name(l_org_id_tab(orgCnt)) );
               END IF;
               --
               CLOSE C1;
               RAISE Wms_Exception;
            END IF;
         END LOOP;
      END IF;
      EXIT WHEN C1%NOTFOUND;
   -- } Cursor Loop
   END LOOP;

   CLOSE C1;

   OPEN C2;
   LOOP
   -- { Cursor Loop
      FETCH C2 BULK COLLECT INTO l_org_id_tab LIMIT G_FETCH_LIMIT;

      IF ( l_org_id_tab.COUNT > 0 )
      THEN
         FOR orgCnt in l_org_id_tab.FIRST..l_org_id_tab.LAST
         LOOP
            IF ( NOT G_WMS_ENABLED.EXISTS(l_org_id_tab(orgCnt)) )
            THEN
               G_WMS_ENABLED(l_org_id_tab(orgCnt)) := WSH_UTIL_VALIDATE.Check_Wms_Org(l_org_id_tab(orgCnt));
            END IF;

            IF ( G_WMS_ENABLED(l_org_id_tab(orgCnt)) = 'Y' )
            THEN
               --
               IF ( l_debug_on ) THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'There exists WMS records in shipping which are assigned to Containers and Deliveries for organization : ' || WSH_UTIL_CORE.Get_Org_Name(l_org_id_tab(orgCnt)) );
               END IF;
               --
               CLOSE C2;
               RAISE Wms_Exception;
            END IF;
         END LOOP;
      END IF;
      EXIT WHEN C2%NOTFOUND;
   -- } Cursor Loop
   END LOOP;

   CLOSE C2;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN Wms_Exception THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF ( l_debug_on ) THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      IF ( C1%ISOPEN ) THEN
         CLOSE C1;
      END IF;
      --
      IF ( C2%ISOPEN ) THEN
         CLOSE C2;
      END IF;
      --
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'WMS_Exception occurred');
       WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF ( l_debug_on ) THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Unexpected Error in Check_Wms_Details');
         WSH_DEBUG_SV.log(l_module_name, 'Error Code', sqlcode);
         WSH_DEBUG_SV.log(l_module_name, 'Error Mesg', sqlerrm);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      IF ( C1%ISOPEN ) THEN
         CLOSE C1;
      END IF;

      IF ( C2%ISOPEN ) THEN
         CLOSE C2;
      END IF;
END Check_Wms_Details;


--
--
-- Merge Locations API created for party merge
-- ============================================================================
-- PROCEDURE  :    MERGE_LOCATION
-- PARAMETERS :
--   p_entity_name         Name of Entity Being Merged
--   p_from_id             Primary Key Id of the entity that is being merged
--   p_to_id               The record under the 'To Parent' that is being
--                         merged
--   p_from_fk_id          Foreign Key id of the Old Parent Record
--   p_to_fk_id            Foreign  Key id of the New Parent Record
--   p_parent_entity_name  Name of Parent Entity
--   p_batch_id            Id of the Batch
--   p_batch_party_id      Id uniquely identifies the batch and party record
--                         that is being merged
--   x_return_status       Returns the status of call
--
-- COMMENT :
--   To update locations in Wsh_Delivery_Details, Wsh_New_Deliveries,
--   Wsh_Trip_Stops tables for Unshipped delivery lines during party
--   merge. Also updates Wsh_Picking_Rules tables during party merge.
-- ============================================================================
PROCEDURE merge_location(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       IN  OUT NOCOPY VARCHAR2)
IS

   -- Cursor to fetch the location id from Hz_Party_Sites table.
   CURSOR Get_Location_Id ( p_party_site_id NUMBER )
   IS
      SELECT Party_Id, Party_Site_Id, Location_Id
      FROM   HZ_PARTY_SITES HPS
      WHERE  PARTY_SITE_ID = p_party_site_id;

   -- Fetches delivery details with new party sites and old locations.
   -- Old locations to be updated with new locations in Shipping
   -- tables for records fetched by Cursor.
   -- Cursor fetches only delivery details which as deliver_to_site_use_id
   -- same as ship_to_site_use_id or deliver_to_site_use_id is NULL since
   -- we populate deliver_to_location_id same as ship_to_location id if
   -- deliver_to_site_use_id is NULL.
   -- Cursor does not select container records
   -- Added following condition for Bug 4247177
   -- "AND    NVL(WTS.Stop_Location_Id, WDD.Ship_To_Location_Id) = WDD.Ship_To_Location_Id"
   -- Above condition will eliminate drop off stop with different stop location, if multiple
   -- legs are present in a delivery.
   CURSOR Get_Wsh_Details ( p_party_site_id NUMBER, p_location_id NUMBER )
   IS
      SELECT Wdd.Rowid Del_Detail_Rowid, Wnd.RowId Delivery_RowId, Wts.Rowid Stop_RowId,
             Wnd.Delivery_Id Delivery_Id, Wts.Stop_Id Stop_Id,
             Wdd.Delivery_Detail_Id Delivery_Detail_Id,
             Wda.Parent_Delivery_Detail_Id Parent_Delivery_Detail_Id,
             Wdd.Net_Weight, Wdd.Gross_Weight, Wdd.Volume,
             Wdd.Weight_Uom_code, Wdd.Volume_Uom_Code, Wdd.Inventory_Item_Id,
             Wdd.Organization_Id, WDA.Rowid Wda_Rowid
      FROM   WSH_DELIVERY_DETAILS WDD,
             WSH_DELIVERY_ASSIGNMENTS_V WDA,
             WSH_NEW_DELIVERIES WND,
             WSH_DELIVERY_LEGS WDL,
             WSH_TRIP_STOPS WTS,
             HZ_CUST_ACCT_SITES_ALL CA,
             HZ_CUST_SITE_USES_ALL  SU
      WHERE  SU.Cust_Acct_Site_Id = CA.Cust_Acct_Site_Id
      AND    CA.Party_Site_Id     = p_party_site_id
      AND    WDD.Container_Flag   = 'N'
      AND    NVL(WDD.Line_Direction, 'O') in ( 'O', 'IO' )
      AND    WDD.Ship_To_Location_id = p_location_id
      AND    WDD.Ship_To_Site_Use_Id   = SU.Site_Use_Id
      AND    WDD.Released_Status IN ( 'R', 'N', 'X', 'Y', 'S', 'B' )
      AND    WDA.Delivery_Detail_Id = WDD.Delivery_Detail_Id
      AND    NVL(WND.Status_Code, 'OP') IN ( 'OP', 'CO' )
      AND    WND.Delivery_Id (+) = WDA.Delivery_Id
      AND    WDL.Delivery_Id (+) = WND.Delivery_Id
      AND    NVL(WTS.Stop_Location_Id, WDD.Ship_To_Location_Id) = WDD.Ship_To_Location_Id
      AND    NVL(WTS.Status_Code, 'OP') = 'OP'
      AND    WTS.Stop_Id     (+) = WDL.Drop_Off_Stop_Id
     FOR UPDATE of Wdd.Delivery_Detail_Id, Wnd.Delivery_Id, Wts.Stop_Id NOWAIT;

   CURSOR Get_Wsh_Unassign_Details ( p_party_site_id NUMBER, p_location_id NUMBER )
   IS
      SELECT Wda.rowid Del_Assignments_Rowid, Wda.Delivery_id,
             Wdd.Delivery_Detail_Id Delivery_Detail_Id,
             Wda.Parent_Delivery_Detail_Id Parent_Delivery_Detail_Id,
             Wdd.Net_Weight, Wdd.Gross_Weight, Wdd.Volume,
             Wdd.Weight_Uom_code, Wdd.Volume_Uom_Code, Wdd.Inventory_Item_Id,
             Wdd.Organization_Id, Wnd.Name Delivery_Name,
             Wdd.Move_Order_Line_Id, Wdd.Released_Status
      FROM   WSH_DELIVERY_DETAILS WDD,
             WSH_DELIVERY_ASSIGNMENTS_V WDA,
             WSH_NEW_DELIVERIES WND,
             HZ_CUST_ACCT_SITES_ALL CA,
             HZ_CUST_SITE_USES_ALL  SU
      WHERE  SU.Cust_Acct_Site_Id = CA.Cust_Acct_Site_Id
      AND    CA.Party_Site_Id     = p_party_site_id
      AND    WDD.Container_Flag   = 'N'
      AND    NVL(WDD.Line_Direction, 'O') in ( 'O', 'IO' )
      AND    WDD.Ship_To_Location_id = p_location_id
      AND    WDD.Ship_To_Site_Use_Id   = SU.Site_Use_Id
      AND    WDD.Released_Status IN ( 'R', 'N', 'X', 'Y', 'S', 'B' )
      AND    WND.Ultimate_Dropoff_Location_Id <> p_location_id
      AND    WDA.Delivery_Detail_Id = WDD.Delivery_Detail_Id
      AND    WND.Status_Code IN ( 'OP', 'CO' )
      AND    WDA.delivery_id is not null
      AND    WND.Delivery_Id  = WDA.Delivery_Id
      AND    exists (
                SELECT 'x'
                FROM   WSH_DELIVERY_ASSIGNMENTS_V WDA1,
                       WSH_DELIVERY_DETAILS WDD1
                WHERE  WDD1.DELIVERY_DETAIL_ID = WDA1.DELIVERY_DETAIL_ID
                AND    WDD1.Container_Flag = 'N'
                AND    WDA1.Delivery_Id = WND.Delivery_Id
                AND    WDD1.Ship_To_Location_id = WND.Ultimate_Dropoff_Location_Id)
      FOR UPDATE OF Wda.Delivery_Detail_Id, Wnd.Delivery_Id NOWAIT;

   CURSOR Get_Delivery_Containers
   IS
      SELECT Wdd.Rowid
      FROM   Wsh_Delivery_Details     Wdd,
            Wsh_Delivery_Assignments_V Wda,
             Wsh_Tmp                  Tmp
      WHERE  Wdd.container_flag = 'Y'
      AND    NVL(WDD.Line_Direction, 'O') in ( 'O', 'IO' )
      AND    Wdd.delivery_detail_id = Wda.Delivery_Detail_Id
      AND    Wda.Delivery_Id = Tmp.Column1
      FOR UPDATE OF Wdd.Delivery_Detail_id NOWAIT;

   --Bug 5606960# G-Log Changes: Included Wnd.organization_id in query
   CURSOR Get_Del_Unassign_From_Stop (
              p_to_location_id      NUMBER,
              p_from_location_id    NUMBER )
   IS
      SELECT Wdl.Delivery_Id, Wts.Stop_Id, Wts.Trip_Id,
             Wdl.Delivery_Leg_Id, Wnd.organization_id,
             Wnd.Net_Weight, Wnd.Gross_Weight, Wnd.Volume,
             Wdl.Rowid, Tmp.Rowid
      FROM   Wsh_Trip_Stops           Wts,
             Wsh_New_Deliveries       Wnd,
             Wsh_Delivery_Legs        Wdl,
             Wsh_Tmp                  Tmp
      WHERE  Wnd.Ultimate_DropOff_Location_Id = p_to_location_id
      AND    nvl(Wnd.Shipment_Direction, 'O') in ( 'O', 'IO' )
      AND    Wnd.Delivery_Id = Wdl.Delivery_Id
      AND    Wts.Stop_Location_Id = p_from_location_id
      AND    Wts.Stop_Id = Wdl.Drop_Off_Stop_Id
      AND    Wdl.Delivery_Id = Tmp.Column1
      AND    exists (
                SELECT 'x'
                FROM   Wsh_New_Deliveries  Del,
                       Wsh_Delivery_Legs   Legs
                WHERE  Del.Ultimate_Dropoff_Location_Id <> p_to_location_id
                AND    Del.Delivery_Id = Legs.Delivery_Id
                AND    Legs.Drop_Off_Stop_Id = Wdl.Drop_Off_Stop_Id )
      FOR UPDATE OF Wdl.Delivery_Leg_Id NOWAIT;


   -- Cursor fetches delivery details which has deliver_to_site_use_id
   -- different from ship_to_site_use_id.
   CURSOR Get_Deliver_Loc_Details ( p_party_site_id NUMBER, p_location_id NUMBER )
   IS
      SELECT WDD.Rowid
      FROM   WSH_DELIVERY_DETAILS WDD,
             HZ_CUST_ACCT_SITES_ALL CA,
             HZ_CUST_SITE_USES_ALL  SU
      WHERE  SU.Cust_Acct_Site_Id        = CA.Cust_Acct_Site_Id
      AND    CA.Party_Site_Id            = p_party_site_id
      AND    NVL(WDD.Line_Direction, 'O') in ( 'O', 'IO' )
      AND    WDD.Deliver_To_Location_id  = p_location_id
      AND    WDD.Deliver_To_Site_Use_Id  = SU.Site_Use_Id
      AND    WDD.Deliver_To_Site_Use_Id <> WDD.Ship_To_Site_Use_Id
      AND    WDD.Released_Status IN ( 'R', 'N', 'X', 'Y', 'S', 'B' )
   FOR UPDATE of Wdd.Delivery_Detail_Id NOWAIT;

   -- Cursor to update deliver_to_location for container records.
   CURSOR Get_Del_Loc_Cont_Details ( p_party_site_id NUMBER, p_location_id NUMBER )
   IS
   SELECT WDA.Parent_Delivery_Detail_Id
   FROM   WSH_DELIVERY_ASSIGNMENTS_V WDA
   WHERE  WDA.Parent_Delivery_Detail_Id IS NOT NULL
   CONNECT BY PRIOR WDA.Parent_Delivery_Detail_Id = WDA.Delivery_Detail_Id
   START   WITH wda.delivery_detail_id IN
   (  SELECT WDD.Delivery_Detail_Id
      FROM   WSH_DELIVERY_DETAILS WDD,
             HZ_CUST_ACCT_SITES_ALL CA,
             HZ_CUST_SITE_USES_ALL  SU
       WHERE  SU.Cust_Acct_Site_Id = CA.Cust_Acct_Site_Id
       AND    CA.Party_Site_Id     = p_party_site_id
       AND    WDD.Container_Flag   = 'N'
       AND    NVL(WDD.Line_Direction, 'O') in ( 'O', 'IO' )
       AND    WDD.Deliver_To_Location_id  = p_location_id
       AND    WDD.Deliver_To_Site_Use_Id  = SU.Site_Use_Id
       AND    WDD.Deliver_To_Site_Use_Id <> WDD.Ship_To_Site_Use_Id
       AND    WDD.Released_Status IN ( 'R', 'N', 'X', 'Y', 'S', 'B' ) )
   FOR UPDATE OF Wda.Delivery_Detail_Id;

   CURSOR Get_Grouping_Id is
      SELECT Wsh_Delivery_Group_S.NEXTVAL
      FROM   Dual;

   -- Bug 5606960# Cursor added for G-Log Changes
   CURSOR Get_Tmp_Deliveries
   IS
      SELECT wnd.delivery_id, wnd.rowid, to_number(wt.Column3) delivery_detail_id
      FROM   Wsh_Tmp wt,
             Wsh_New_Deliveries Wnd
      WHERE  Wnd.Delivery_Id = to_number(Wt.Column1);

   -- Create Pl/Sql table type for storing RowIds
   TYPE Rowid_Tab_Type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
   l_to_location_id              NUMBER;
   l_to_party_id                 NUMBER;
   l_to_party_site_id            NUMBER;
   l_from_party_id               NUMBER;
   l_from_party_site_id          NUMBER;
   l_from_location_id            NUMBER;
   l_tmp_cnt                     NUMBER;
   l_msg_count                   NUMBER;
   l_carton_grouping_id          NUMBER;
   l_exception_id                NUMBER;
   l_msg_data                    VARCHAR2(32767);
   l_message_name                VARCHAR2(50);
   l_message_text                VARCHAR2(32767);
   l_return_status               VARCHAR2(10);

   l_del_detail_rowid_tab        Rowid_Tab_Type;
   l_del_assignments_rowid_tab   Rowid_Tab_Type;
   l_delivery_rowid_tab          Rowid_Tab_Type;
   l_stop_rowid_tab              Rowid_Tab_Type;
   l_legs_rowid_tab              Rowid_Tab_Type;
   l_tmp_rowid_tab               Rowid_Tab_Type;

   l_delivery_name_tab           WSH_UTIL_CORE.Column_Tab_Type;
   l_weight_uom_tab              WSH_UTIL_CORE.Column_Tab_Type;
   l_volume_uom_tab              WSH_UTIL_CORE.Column_Tab_Type;
   l_released_status_tab         WSH_UTIL_CORE.Column_Tab_Type;

   l_del_detail_id_tab           WSH_UTIL_CORE.Id_Tab_Type;
   l_parent_del_detail_id_tab    WSH_UTIL_CORE.Id_Tab_Type;
   l_delivery_id_tab             WSH_UTIL_CORE.Id_Tab_Type;
   l_delivery_leg_id_tab         WSH_UTIL_CORE.Id_Tab_Type;
   l_stop_id_tab                 WSH_UTIL_CORE.Id_Tab_Type;
   l_trip_id_tab                 WSH_UTIL_CORE.Id_Tab_Type;
   l_net_weight_tab              WSH_UTIL_CORE.Id_Tab_Type;
   l_gross_weight_tab            WSH_UTIL_CORE.Id_Tab_Type;
   l_volume_tab                  WSH_UTIL_CORE.Id_Tab_Type;
   l_organization_id_tab         WSH_UTIL_CORE.Id_Tab_Type;
   l_inventory_item_id_tab       WSH_UTIL_CORE.Id_Tab_Type;
   l_move_order_line_id_tab      WSH_UTIL_CORE.Id_Tab_Type;

   --Bug 5606960# Variable(s) added for G-Log changes
   l_delivery_rec                WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
   l_hash_string                 VARCHAR2(100);
   l_hash_value                  NUMBER;
   l_del_action_prms             WSH_DELIVERIES_GRP.action_parameters_rectype;
   l_del_attrs                   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
   l_del_action_rec              WSH_DELIVERIES_GRP.delivery_action_out_rec_type;
   l_del_defaults                WSH_DELIVERIES_GRP.default_parameters_rectype;

   l_loc_rec                     WSH_MAP_LOCATION_REGION_PKG.loc_rec_type;

   Merge_Location_Exp            EXCEPTION;

   --
   l_debug_on                    BOOLEAN;
   l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MERGE_LOCATION';
   --

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);

      -- Printing the parameters passed to API
      WSH_DEBUG_SV.log(l_module_name,'WSH_PARTY_MERGE.merge_location()+', TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'));
      WSH_DEBUG_SV.log(l_module_name, 'p_entity_name', p_entity_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_from_id', p_from_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_to_id', p_to_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_from_fk_id', p_from_fk_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_to_fk_id', p_to_fk_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_parent_entity_name', p_parent_entity_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_batch_id', p_batch_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_batch_party_id', p_batch_party_id);
   END IF;
   --

   -- Get To_Location_Id which is to be updated in Shipping tables.
   OPEN Get_Location_Id ( p_to_fk_id );
   FETCH Get_Location_Id INTO l_to_party_id, l_to_party_site_id, l_to_location_id;
   IF Get_Location_Id%NOTFOUND
   THEN     -- {
      -- Error Handling Part
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Invaild To Party Site Id', p_to_fk_id);
      END IF;
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      CLOSE Get_Location_Id;
      RAISE Merge_Location_Exp;
   END IF;  -- }
   CLOSE Get_Location_Id;


   -- Get From_Location_Id from Hz_Party_Sites
   OPEN Get_Location_Id ( p_from_fk_id );
   FETCH Get_Location_Id INTO l_from_party_id, l_from_party_site_id, l_from_location_id;
   IF Get_Location_Id%NOTFOUND
   THEN     -- {
      -- Error Handling Part
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Invalid From Party Site Id', p_from_fk_id);
      END IF;
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      CLOSE Get_Location_Id;
      RAISE Merge_Location_Exp;
   END IF;  -- }
   CLOSE Get_Location_Id;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'To Party Id', l_to_party_id);
      WSH_DEBUG_SV.log(l_module_name, 'To Location Id', l_to_location_id);
      WSH_DEBUG_SV.log(l_module_name, 'From Party Id', l_from_party_id);
      WSH_DEBUG_SV.log(l_module_name, 'From Location Id', l_from_location_id);
   END IF;
   --

   -- If FROM and TO Locations are same return Success.
   IF ( l_from_location_id = l_to_location_id )
   THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'From and To Location IDs are the same');
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;

   -- Deleting records from from temp table before processing
   DELETE FROM WSH_TMP;


   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_MAP_LOCATION_REGION_PKG.Transfer_Location', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --

   -- Check whether the To_Location exists in WSH_LOCATIONS table
   WSH_MAP_LOCATION_REGION_PKG.Transfer_Location(
                                p_source_type            => 'HZ',
                                p_source_location_id     => l_to_location_id,
                                p_transfer_location      => TRUE,
                                p_online_region_mapping  => FALSE,
                                x_loc_rec                => l_loc_rec,
                                x_return_status          => l_return_status );

   IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
   THEN    -- { Error Handling
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Error While Calling WSH_MAP_LOCATION_REGION_PKG.Transfer_Location : ' || l_return_status);
      END IF;
      --
      x_return_status := l_return_status;
      RAISE Merge_Location_Exp;
   END IF; -- } Error Handling

   -- Check whether FTE is Installed
   IF ( G_FTE_INSTALLED IS NULL )
   THEN
      G_FTE_INSTALLED := WSH_UTIL_CORE.Fte_Is_Installed;
   END IF;

   -- Check for WMS records
   l_return_status := NULL;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Check_Wms_Details', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --

   WSH_PARTY_MERGE.Check_Wms_Details (
             p_party_site_id   => l_to_party_site_id,
             p_location_id     => l_from_location_id,
             x_return_status   => l_return_status );

   IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
   THEN
      -- { Error Handling
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Error While Calling WSH_PARTY_MERGE.Check_Wms_Details : ' || l_return_status);
      END IF;
      --
      x_return_status := l_return_status;
      RAISE Merge_Location_Exp;
   END IF; -- } Error Handling

   --
   IF ( l_debug_on ) THEN
      WSH_DEBUG_SV.log(l_module_name, 'Starting updates on shipping tables', TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'));
   END IF;
   --

   -- Get Shipping details based on ship_to_location for which the location
   -- has to be updated during Party Merge.
   -- Passing l_to_party_site_id, since party_site_id is already updated
   -- in HZ_CUST_ACCT_SITES_ALL API before calling our API.
   OPEN Get_Wsh_Details ( l_to_party_site_id, l_from_location_id );

   LOOP      -- {
      FETCH Get_Wsh_Details BULK COLLECT INTO
            l_del_detail_rowid_tab,
            l_delivery_rowid_tab,
            l_stop_rowid_tab,
            l_delivery_id_tab,
            l_stop_id_tab,
            l_del_detail_id_tab,
            l_parent_del_detail_id_tab,
            l_net_weight_tab,
            l_gross_weight_tab,
            l_volume_tab,
            l_weight_uom_tab,
            l_volume_uom_tab,
            l_inventory_item_id_tab,
            l_organization_id_tab,
            l_del_assignments_rowid_tab
      LIMIT G_FETCH_LIMIT;

      --
      IF ( l_debug_on ) THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows fetched from Get_Wsh_Details', l_del_detail_rowid_tab.COUNT);
      END IF;
      --

      -- Update Ship_to_Location and Deliver_to_Location in Wsh_Delivery_Details
      -- table during party merge.

      IF ( l_del_detail_rowid_tab.COUNT > 0 )
      THEN    -- { WDD Update
         FORALL i IN l_del_detail_rowid_tab.FIRST..l_del_detail_rowid_tab.LAST
         UPDATE WSH_DELIVERY_DETAILS Wdd
         SET    ship_to_location_id    = l_to_location_id,
                deliver_to_location_id = decode( nvl(deliver_to_site_use_id, ship_to_site_use_id),
                                                 ship_to_site_use_id, l_to_location_id,
                                                 deliver_to_location_id ),
                last_update_date       = SYSDATE,
                last_updated_by        = fnd_global.user_id,
                last_update_login      = fnd_global.conc_login_id,
                program_application_id = fnd_global.prog_appl_id,
                program_id             = fnd_global.conc_program_id,
                program_update_date    = SYSDATE
         WHERE  WDD.Rowid = l_del_detail_rowid_tab(i);

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'No of Rows Updated in WDD : '
                                                || sql%rowcount || ', Time : '
                                                || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
         END IF;
         --
      END IF; -- } WDD Update

      IF ( l_del_assignments_rowid_tab.COUNT > 0 )
      THEN     -- { WDA Update

         l_return_status := NULL;
         l_delivery_leg_id_tab.delete;

/****
         FORALL i IN l_del_assignments_rowid_tab.FIRST..l_del_assignments_rowid_tab.LAST
         UPDATE WSH_DELIVERY_ASSIGNMENTS
         SET    parent_delivery_detail_id = null,
                last_update_date       = SYSDATE,
                last_updated_by        = fnd_global.user_id,
                last_update_login      = fnd_global.conc_login_id,
                program_application_id = fnd_global.prog_appl_id,
                program_id             = fnd_global.conc_program_id,
                program_update_date    = SYSDATE
         WHERE  rowid = l_del_assignments_rowid_tab(i)
         AND    Parent_Delivery_Detail_Id IS NOT NULL
         AND    Delivery_Id IS NULL;
****/

         --Start of fix for bug 5749968
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Before calling container unassign standard api: '
                                               || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
         END IF;
         --

         FOR unassignCnt in l_del_detail_id_tab.FIRST..l_del_detail_id_tab.LAST
         LOOP
            --Unassign from container only if delivery detail is packed and
            --not assigned to delivery.
            IF ( l_parent_del_detail_id_tab(unassignCnt) IS NOT NULL AND
                 l_delivery_id_tab(unassignCnt) IS NULL )
            THEN
               l_return_status := NULL;
               -- Calling Standard api to unassign detail from container
               WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_Cont (
                       p_detail_id     => l_del_detail_id_tab(unassignCnt),
                       x_return_status => l_return_status );

               IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                             WSH_UTIL_CORE.G_RET_STS_WARNING) )
               THEN
                  --
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Unassign_Detail_from_Cont returned error : ' || l_return_status);
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Error while processing delivery detail : ' || l_del_detail_id_tab(unassignCnt) );
                  END IF;
                  --
                  x_return_status := l_return_status;
                  RAISE Merge_Location_Exp;
               END IF;
            END IF;
         END LOOP;

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'After calling container unassign standard api: '
                                               || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
         END IF;
         --
         --End of fix for bug 5749968
      END IF;  -- } WDA Update

      IF ( l_delivery_id_tab.COUNT > 0 ) THEN
        -- Inserting records in bulk into temp table for future reference during processing
        -- Dulplicate entries are avoided using NOT EXISTS condition
        FORALL i IN l_delivery_id_tab.FIRST..l_delivery_id_tab.LAST
          INSERT INTO wsh_tmp(column1, column2, column3)
                SELECT l_delivery_id_tab(i), l_stop_id_tab(i), l_del_detail_id_tab(i)
                FROM   dual
                WHERE  l_delivery_id_tab(i) is not null
                AND    NOT EXISTS
                     ( SELECT 'x'
                       FROM   Wsh_Tmp
                       WHERE  Column1 = l_delivery_id_tab(i)
                       AND    ( Column2 = l_stop_id_tab(i) OR l_stop_id_tab(i) IS NULL ) );

          --
          IF ( l_debug_on ) THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'No of rows inserted into wsh_temp : '
                                                || sql%rowcount || ', Time : '
                                                || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
          END IF;
          --
      END IF;

      -- Logging Exceptions for Delivery Details Unassigned from LPNs
      IF ( l_parent_del_detail_id_tab.COUNT > 0 )
      THEN    -- { Log Exception

         l_message_name := 'WSH_PMRG_UNASSIGN_CONTAINER';

         FOR ExpCnt in l_parent_del_detail_id_tab.FIRST..l_parent_del_detail_id_tab.LAST
         LOOP      -- { Loop for logging Expceptions

            -- We should log exceptions only if Parent Delivery Detail IS NOT NULL
            -- and is not assigned to a delivery
            IF ( l_parent_del_detail_id_tab(ExpCnt) IS NOT NULL AND
                 l_delivery_id_tab(ExpCnt) IS NULL )
            THEN    -- {
               -- Setting the Messages
               FND_MESSAGE.Set_Name  ('WSH', l_message_name );
               FND_MESSAGE.Set_Token ('PS1', p_from_fk_id );
               FND_MESSAGE.Set_Token ('PS2', p_to_fk_id );
               FND_MESSAGE.Set_Token ('DELIVERY_DETAIL_ID', l_del_detail_id_tab(ExpCnt) );

               l_message_text := FND_MESSAGE.Get;

               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_XC_UTIL.Log_Exception', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --

               l_return_status := NULL;
               l_msg_count     := NULL;
               l_msg_data      := NULL;
               l_exception_id  := NULL;

               WSH_XC_UTIL.Log_Exception
                         (
                           p_api_version            => 1.0,
                           x_return_status          => l_return_status,
                           x_msg_count              => l_msg_count,
                           x_msg_data               => l_msg_data,
                           x_exception_id           => l_exception_id,
                           p_exception_location_id  => l_to_location_id,
                           p_logged_at_location_id  => l_to_location_id,
                           p_logging_entity         => 'SHIPPER',
                           p_logging_entity_id      => Fnd_Global.user_id,
                           p_exception_name         => 'WSH_PARTY_MERGE_CHANGE',
                           p_message                => l_message_name,
                           p_severity               => 'LOW',
                           p_manually_logged        => 'N',
                           p_delivery_detail_id     => l_parent_del_detail_id_tab(ExpCnt),
                           p_error_message          => l_message_text
                          );

               IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
               THEN
                  --
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Error While Calling WSH_XC_UTIL.Log_Exception : ' || l_return_status);
                  END IF;
                  --
                  x_return_status := l_return_status;
                  RAISE Merge_Location_Exp;
               END IF;

            END IF; -- }
         END LOOP; -- } Loop for logging Expceptions


      END IF; -- } Log Exception

      EXIT WHEN Get_Wsh_Details%NOTFOUND;
   END LOOP; -- }

   CLOSE Get_Wsh_Details;

   OPEN Get_Wsh_Unassign_Details ( l_to_party_site_id, l_to_location_id );

   LOOP      -- {
      FETCH Get_Wsh_Unassign_Details BULK COLLECT INTO
            l_del_assignments_rowid_tab,
            l_delivery_id_tab,
            l_del_detail_id_tab,
            l_parent_del_detail_id_tab,
            l_net_weight_tab,
            l_gross_weight_tab,
            l_volume_tab,
            l_weight_uom_tab,
            l_volume_uom_tab,
            l_inventory_item_id_tab,
            l_organization_id_tab,
            l_delivery_name_tab,
            l_move_order_line_id_tab,
            l_released_status_tab
      LIMIT G_FETCH_LIMIT;

      --
      IF ( l_debug_on ) THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of rows fetched from Get_Wsh_Unassign_Details', l_del_assignments_rowid_tab.COUNT);
      END IF;
      --

      IF ( l_del_assignments_rowid_tab.COUNT > 0 )
      THEN    -- { WDA Update

         l_return_status := NULL;
         l_delivery_leg_id_tab.delete;

/**
         -- Unassigning delivery details from delivery and LPN's
         FORALL i IN l_del_assignments_rowid_tab.FIRST..l_del_assignments_rowid_tab.LAST
         UPDATE WSH_DELIVERY_ASSIGNMENTS
         SET    parent_delivery_detail_id = null,
                delivery_id            = null,
                last_update_date       = SYSDATE,
                last_updated_by        = fnd_global.user_id,
                last_update_login      = fnd_global.conc_login_id,
                program_application_id = fnd_global.prog_appl_id,
                program_id             = fnd_global.conc_program_id,
                program_update_date    = SYSDATE
         WHERE  rowid = l_del_assignments_rowid_tab(i);
***/

         --Start of fix for bug 5749968
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Before calling delivery unassign standard api: '
                                               || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
         END IF;
         --

         FOR unassignDelCnt in l_del_detail_id_tab.FIRST..l_del_detail_id_tab.LAST
         LOOP
            l_return_status := NULL;
            -- Calling Standard api to unassign detail from delivery
            WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_delivery (
                    p_detail_id     => l_del_detail_id_tab(unassignDelCnt),
                    x_return_status => l_return_status );

            IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                          WSH_UTIL_CORE.G_RET_STS_WARNING) )
            THEN
               --
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Unassign_Detail_from_Delivery returned error : ' || l_return_status);
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Error while processing delivery detail : ' || l_del_detail_id_tab(unassignDelCnt) );
               END IF;
               --
               x_return_status := l_return_status;
               RAISE Merge_Location_Exp;
            END IF;
         END LOOP;

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'After calling delivery unassign standard api: '
                                               || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
         END IF;
         --
         --End of fix for bug 5749968
      END IF; -- } WDA Update


      IF ( l_delivery_id_tab.COUNT > 0 ) THEN
         FORALL i IN l_delivery_id_tab.FIRST..l_delivery_id_tab.LAST
            DELETE FROM wsh_tmp WHERE column1 = l_delivery_id_tab(i);

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'No of records deleted from wsh_tmp table after unassigning from delivery : '
                                                || sql%rowcount || ', Time : '
                                                || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
         END IF;
         --
      END IF;
      -- Logging Exceptions for Delivery Details Unassigned from Delivery
      IF ( l_delivery_id_tab.COUNT > 0 )
      THEN    -- { Log Exception
         l_message_name := 'WSH_PMRG_UNASSIGN_DELIVERY';

         FOR ExpCnt in l_delivery_id_tab.FIRST..l_delivery_id_tab.LAST
         LOOP      -- { Loop for logging Expceptions
            -- Setting the Messages
            FND_MESSAGE.Set_Name  ('WSH', l_message_name );
            FND_MESSAGE.Set_Token ('PS1', p_from_fk_id );
            FND_MESSAGE.Set_Token ('PS2', p_to_fk_id );
            FND_MESSAGE.Set_Token ('DELIVERY_DETAIL_ID', l_del_detail_id_tab(ExpCnt) );

            l_message_text := FND_MESSAGE.Get;

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_XC_UTIL.Log_Exception', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --

            l_return_status := NULL;
            l_msg_count     := NULL;
            l_msg_data      := NULL;
            l_exception_id  := NULL;

            WSH_XC_UTIL.log_exception
                      (
                        p_api_version            => 1.0,
                        x_return_status          => l_return_status,
                        x_msg_count              => l_msg_count,
                        x_msg_data               => l_msg_data,
                        x_exception_id           => l_exception_id,
                        p_exception_location_id  => l_to_location_id,
                        p_logged_at_location_id  => l_to_location_id,
                        p_logging_entity         => 'SHIPPER',
                        p_logging_entity_id      => Fnd_Global.user_id,
                        p_exception_name         => 'WSH_PARTY_MERGE_CHANGE',
                        p_message                => l_message_name,
                        p_severity               => 'LOW',
                        p_manually_logged        => 'N',
                        p_delivery_id            => l_delivery_id_tab(ExpCnt),
                        p_delivery_name          => l_delivery_name_tab(ExpCnt),
                        p_error_message          => l_message_text
                       );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Error While Calling WSH_XC_UTIL.Log_Exception', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               x_return_status := l_return_status;
               RAISE Merge_Location_Exp;
            END IF;

         END LOOP; -- } Loop for logging Expceptions

      END IF; -- } Log Exception

      EXIT WHEN Get_Wsh_Unassign_Details%NOTFOUND;
   END LOOP; -- }

   CLOSE Get_Wsh_Unassign_Details;

   SELECT COUNT(*)
   INTO   l_tmp_cnt
   FROM   WSH_TMP;

   IF ( l_tmp_cnt > 0 )
   THEN    -- { Temp Table Count

      OPEN Get_Delivery_Containers;

      LOOP
      -- { Updation of Container records
         FETCH Get_Delivery_Containers BULK COLLECT INTO
               l_del_detail_rowid_tab
         LIMIT G_FETCH_LIMIT;

         IF ( l_del_detail_rowid_tab.COUNT > 0 )
        THEN
            FORALL updCnt IN l_del_detail_rowid_tab.FIRST..l_del_detail_rowid_tab.LAST
            UPDATE WSH_DELIVERY_DETAILS Wdd
            SET    ship_to_location_id    = l_to_location_id,
                   deliver_to_location_id = decode(deliver_to_location_id,
                                                   ship_to_location_id, l_to_location_id,
                                                   deliver_to_location_id),
                   last_update_date       = SYSDATE,
                   last_updated_by        = fnd_global.user_id,
                   last_update_login      = fnd_global.conc_login_id,
                   program_application_id = fnd_global.prog_appl_id,
                   program_id             = fnd_global.conc_program_id,
                   program_update_date    = SYSDATE
            WHERE  Wdd.Rowid = l_del_detail_rowid_tab(updCnt);

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'No of Container records Updated in WDD : '
                                                || sql%rowcount || ', Time : '
                                                || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
            END IF;
            --
         END IF;

         EXIT WHEN Get_Delivery_Containers%NOTFOUND;
      -- } Updation of Container records
      END LOOP;

      CLOSE Get_Delivery_Containers;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'After Container records Update', TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'));
      END IF;
      --

      FOR TmpDelRec IN Get_Tmp_Deliveries
      LOOP
         -- Bug 5606960# G-Log Changes: Calling API's to update delivery's location.
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling API WSH_NEW_DELIVERIES_PVT.Table_To_Record', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         l_return_status := NULL;
         WSH_NEW_DELIVERIES_PVT.Table_To_Record (
                                p_delivery_id   => TmpDelRec.Delivery_Id,
                                x_delivery_rec  => l_delivery_rec,
                                x_return_status => l_return_status );

         IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
         THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'Error returned from WSH_NEW_DELIVERIES_PVT.Table_To_Record : ' || l_return_status);
            END IF;
            --
            Raise Merge_Location_Exp;
         END IF;
      l_return_status := NULL;

Get_Delivery_Hash (
                p_delivery_id        => TmpDelRec.delivery_id,
                p_delivery_detail_id => TmpDelRec.delivery_detail_id,
                x_hash_string        => l_hash_string,
                x_hash_value         => l_hash_value,
                x_return_status      => l_return_status );

      IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
      THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Error returned from Get_Delivery_Hash : ' || l_return_status);
         END IF;
         --
         Raise Merge_Location_Exp;
      END IF;

         l_delivery_rec.ultimate_dropoff_location_id := l_to_location_id;
         l_delivery_rec.hash_string                  := l_hash_string;
         l_delivery_rec.hash_value                   := l_hash_value;
         l_delivery_rec.last_update_date             := SYSDATE;
         l_delivery_rec.last_updated_by              := fnd_global.user_id;
         l_delivery_rec.last_update_login            := fnd_global.conc_login_id;
         l_delivery_rec.program_application_id       := fnd_global.prog_appl_id;
         l_delivery_rec.program_id                   := fnd_global.conc_program_id;
         l_delivery_rec.program_update_date          := SYSDATE;

         --
         IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling API WSH_NEW_DELIVERIES_PVT.Update_Delivery', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         l_return_status := NULL;
         WSH_NEW_DELIVERIES_PVT.Update_Delivery(
                                p_rowid => TmpDelRec.Rowid,
                                p_delivery_info => l_delivery_rec,
                                x_return_status => l_return_status );

         IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
         THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'Error returned from WSH_NEW_DELIVERIES_PVT.Update_Delivery : ' || l_return_status);
            END IF;
            --
            Raise Merge_Location_Exp;
      END IF;
      END LOOP;

      -- Unassigns delivery from stop, if a stop has deliveries with
      -- different location.
      OPEN Get_Del_Unassign_From_Stop ( l_to_location_id, l_from_location_id );

      LOOP

         FETCH Get_Del_Unassign_From_Stop BULK COLLECT INTO
          l_delivery_id_tab,
                           l_stop_id_tab,
                           l_trip_id_tab,
                           l_delivery_leg_id_tab,
			   l_organization_id_tab,
                           l_net_weight_tab,
                           l_gross_weight_tab,
                           l_volume_tab,
                           l_legs_rowid_tab,
                           l_tmp_rowid_tab
         LIMIT G_FETCH_LIMIT;

         IF ( l_legs_rowid_tab.COUNT > 0 )
         THEN

            -- Bug 5606960# G-Log Changes: Calling API to Unassign delivery from TRIP.
            FOR i in l_legs_rowid_tab.FIRST..l_legs_rowid_tab.LAST
            LOOP
               l_del_action_prms.caller      := 'WSH_PUB';
               l_del_action_prms.action_code := 'UNASSIGN-TRIP';
               l_del_action_prms.trip_id     := l_trip_id_tab(i);

               l_del_attrs(1).delivery_id     := l_delivery_id_tab(i);
               l_del_attrs(1).organization_id := l_organization_id_tab(i);
               l_return_status                := NULL;
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling API WSH_DELIVERIES_GRP.Delivery_Action', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --

WSH_DELIVERIES_GRP.Delivery_Action (
                              p_api_version_number => 1.0,
                              p_init_msg_list      => FND_API.G_TRUE,
                              p_commit             => FND_API.G_FALSE,
                              p_action_prms        => l_del_action_prms,
                              p_rec_attr_tab       => l_del_attrs,
                              x_delivery_out_rec   => l_del_action_rec,
                              x_defaults_rec       => l_del_defaults,
                              x_return_status      => l_return_status,
                              x_msg_count          => l_msg_count,
                              x_msg_data           => l_msg_data );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'Error returned from WSH_DELIVERIES_GRP.Delivery_Action : ' || l_return_status);
            END IF;
            --
	     Raise Merge_Location_Exp;
               END IF;
            END LOOP;
         END IF;

         IF ( l_tmp_rowid_tab.COUNT > 0 )
         THEN
            -- Delete the records from Wsh_Tmp table, so that location are not
            -- updated for stops which are assigned to deliveries with different
            -- locations after party merge.
            FORALL updCnt IN l_tmp_rowid_tab.FIRST..l_tmp_rowid_tab.LAST
               DELETE FROM Wsh_Tmp
               WHERE  Rowid = l_tmp_rowid_tab(updCnt);

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'No of records deleted from Wsh_Tmp : '
                                                || sql%rowcount || ', Time : '
                                                || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
            END IF;
            --
         END IF;

         EXIT WHEN Get_Del_Unassign_From_Stop%NOTFOUND;
      END LOOP; -- }

      CLOSE Get_Del_Unassign_From_Stop;

      -- Logging Exceptions for Deliveries Unassigned from Stop
      IF ( l_stop_id_tab.COUNT > 0 )
      THEN    -- { Log Exception
         l_message_name := 'WSH_PMRG_UNASSIGN_STOP';

         FOR ExpCnt in l_stop_id_tab.FIRST..l_stop_id_tab.LAST
         LOOP      -- { Loop for logging Expceptions
            -- Setting the Messages
            FND_MESSAGE.Set_Name  ('WSH', l_message_name );
            FND_MESSAGE.Set_Token ('PS1', p_from_fk_id );
            FND_MESSAGE.Set_Token ('PS2', p_to_fk_id );
            FND_MESSAGE.Set_Token ('DELIVERY_ID', l_delivery_id_tab(ExpCnt) );

            l_message_text := FND_MESSAGE.Get;

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_XC_UTIL.Log_Exception', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --

            l_return_status := NULL;
            l_msg_count     := NULL;
            l_msg_data      := NULL;
            l_exception_id  := NULL;

            WSH_XC_UTIL.log_exception
                      (
                        p_api_version            => 1.0,
                        x_return_status          => l_return_status,
                        x_msg_count              => l_msg_count,
                        x_msg_data               => l_msg_data,
                        x_exception_id           => l_exception_id,
                        p_exception_location_id  => l_to_location_id,
                        p_logged_at_location_id  => l_to_location_id,
                        p_logging_entity         => 'SHIPPER',
                        p_logging_entity_id      => Fnd_Global.user_id,
                        p_exception_name         => 'WSH_PARTY_MERGE_CHANGE',
                        p_message                => l_message_name,
                        p_severity               => 'LOW',
                        p_manually_logged        => 'N',
                        p_trip_id                => l_trip_id_tab(ExpCnt),
                        p_trip_stop_id           => l_stop_id_tab(ExpCnt),
                        p_error_message          => l_message_text
                       );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Error While Calling WSH_XC_UTIL.Log_Exception', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               x_return_status := l_return_status;
               RAISE Merge_Location_Exp;
            END IF;

         END LOOP; -- } Loop for logging Expceptions
      END IF; -- } Log Exception

      UPDATE WSH_TRIP_STOPS Wts
      SET    stop_location_id       = l_to_location_id,
             last_update_date       = SYSDATE,
             last_updated_by        = fnd_global.user_id,
             last_update_login      = fnd_global.conc_login_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id             = fnd_global.conc_program_id,
             program_update_date    = SYSDATE
      WHERE  Wts.Stop_Id in (
               SELECT Column2
               FROM   WSH_TMP
               WHERE  Column2 IS NOT NULL);

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'No of Stop records Updated in WTS : '
                                                || sql%rowcount || ', Time : '
                                                || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
      END IF;
      --

      -- Deleting records from temp table
      DELETE FROM wsh_tmp;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'No of records deleted from temp table : '
                                                || sql%rowcount || ', Time : '
                                                || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
      END IF;
      --
   END IF; -- } Temp Table Count

   -- Get Shipping details based on deliver_to_location for which the location
   -- has to be updated during party merge.
   -- Passing l_to_party_site_id, since party_site_id is already updated
   -- in HZ_CUST_ACCT_SITES_ALL API before calling our API.
   OPEN Get_Deliver_Loc_Details ( l_to_party_site_id, l_from_location_id );

   LOOP      -- {
      FETCH Get_Deliver_Loc_Details BULK COLLECT INTO
            l_del_detail_rowid_tab LIMIT G_FETCH_LIMIT;

      --
      IF ( l_debug_on ) THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of Records Fetched from Get_Deliver_Loc_details', l_del_detail_rowid_tab.COUNT);
      END IF;
      --

      -- Update Deliver to Locations in Wsh_Delivery_Details table during
      -- party merge.

      IF ( l_del_detail_rowid_tab.COUNT > 0 )
      THEN    -- { WDD Update

         FORALL i IN l_del_detail_rowid_tab.FIRST..l_del_detail_rowid_tab.LAST
         UPDATE WSH_DELIVERY_DETAILS Wdd
         SET    deliver_to_location_id = l_to_location_id,
                last_update_date       = SYSDATE,
                last_updated_by        = fnd_global.user_id,
                last_update_login      = fnd_global.conc_login_id,
                program_application_id = fnd_global.prog_appl_id,
                program_id             = fnd_global.conc_program_id,
                program_update_date    = SYSDATE
         WHERE  WDD.Rowid = l_del_detail_rowid_tab(i);

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'No of Rows Updated in WDD : '
                                                || sql%rowcount || ', Time : '
                                                || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
         END IF;
         --
      END IF; -- } WDD Update

      EXIT WHEN Get_Deliver_Loc_Details%NOTFOUND;
   END LOOP; -- }

   CLOSE Get_Deliver_Loc_Details;

   -- Update deliver_to_location for container records in WDD table
   OPEN Get_Del_Loc_Cont_Details ( l_to_party_site_id, l_to_location_id );

   LOOP      -- {
      FETCH Get_Del_Loc_Cont_Details BULK COLLECT INTO
            l_del_detail_id_tab LIMIT G_FETCH_LIMIT;

      --
      IF ( l_debug_on ) THEN
         WSH_DEBUG_SV.log(l_module_name, 'No of Records Fetched from Get_Del_Loc_Cont_Details', l_del_detail_id_tab.COUNT);
      END IF;
      --

      -- Update Deliver to Locations in Wsh_Delivery_Details table during
      -- party merge for Container records.
      IF ( l_del_detail_id_tab.COUNT > 0 )
      THEN    -- { WDD Cont Update

         FORALL i IN l_del_detail_id_tab.FIRST..l_del_detail_id_tab.LAST
         UPDATE WSH_DELIVERY_DETAILS Wdd
         SET    deliver_to_location_id = l_to_location_id,
                last_update_date       = SYSDATE,
                last_updated_by        = fnd_global.user_id,
                last_update_login      = fnd_global.conc_login_id,
                program_application_id = fnd_global.prog_appl_id,
                program_id             = fnd_global.conc_program_id,
                program_update_date    = SYSDATE
         WHERE  WDD.Delivery_Detail_Id = l_del_detail_id_tab(i)
         AND    WDD.Container_Flag     = 'Y'; -- To make sure that we are updating container records

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'No of Rows Updated in WDD Cont Del Loc : '
                                                || sql%rowcount || ', Time : '
                                                || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
         END IF;
         --
      END IF; -- } WDD Cont Update

      EXIT WHEN Get_Del_Loc_Cont_Details%NOTFOUND;
   END LOOP; -- }

   CLOSE Get_Del_Loc_Cont_Details;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Before WPR Update', TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'));
   END IF;
   --

   UPDATE WSH_PICKING_RULES WPR
   SET    ship_to_location_id    = l_to_location_id,
          last_update_date       = SYSDATE,
          last_updated_by        = fnd_global.user_id,
          last_update_login      = fnd_global.conc_login_id,
          program_application_id = fnd_global.prog_appl_id,
          program_id             = fnd_global.conc_program_id,
          program_update_date    = SYSDATE
   WHERE  ship_to_location_id = l_from_location_id
   AND    EXISTS
        ( SELECT 'X'
          FROM   HZ_CUST_ACCT_SITES_ALL CA
          WHERE  CA.Party_Site_Id   = l_to_party_site_id
          AND    CA.Cust_Account_Id = WPR.Customer_Id );

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'No of rows updated in WPR : '
                                                || sql%rowcount || ', Time : '
                                                || TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') );
      WSH_DEBUG_SV.pop(l_module_name);
   END IF ;
   --
EXCEPTION
   --
   WHEN Merge_Location_Exp THEN
      --
      -- Close the Cursors if they are OPEN
      --
      IF ( Get_Location_Id %ISOPEN ) THEN
         CLOSE Get_Location_Id ;
      END IF;

      IF ( Get_Wsh_Details%ISOPEN ) THEN
         CLOSE Get_Wsh_Details;
      END IF;

      IF ( Get_Wsh_Unassign_Details%ISOPEN ) THEN
         CLOSE Get_Wsh_Unassign_Details;
      END IF;

      IF ( Get_Delivery_Containers%ISOPEN ) THEN
         CLOSE Get_Delivery_Containers;
      END IF;

      IF ( Get_Del_Unassign_From_Stop%ISOPEN ) THEN
         CLOSE Get_Del_Unassign_From_Stop;
      END IF;

      IF ( Get_Deliver_Loc_Details%ISOPEN ) THEN
         CLOSE Get_Deliver_Loc_Details;
      END IF;

      IF ( Get_Del_Loc_Cont_Details%ISOPEN ) THEN
         CLOSE Get_Del_Loc_Cont_Details;
      END IF;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Merge_Location_Exp occurred');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AR','HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Close the Cursors if it is OPEN
      IF ( Get_Location_Id %ISOPEN ) THEN
         CLOSE Get_Location_Id ;
      END IF;

      IF ( Get_Wsh_Details%ISOPEN ) THEN
         CLOSE Get_Wsh_Details;
      END IF;

      IF ( Get_Wsh_Unassign_Details%ISOPEN ) THEN
         CLOSE Get_Wsh_Unassign_Details;
      END IF;

      IF ( Get_Delivery_Containers%ISOPEN ) THEN
         CLOSE Get_Delivery_Containers;
      END IF;

      IF ( Get_Del_Unassign_From_Stop%ISOPEN ) THEN
         CLOSE Get_Del_Unassign_From_Stop;
      END IF;

      IF ( Get_Deliver_Loc_Details%ISOPEN ) THEN
         CLOSE Get_Deliver_Loc_Details;
      END IF;

      IF ( Get_Del_Loc_Cont_Details%ISOPEN ) THEN
         CLOSE Get_Del_Loc_Cont_Details;
      END IF;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Unexpected Error......');
         WSH_DEBUG_SV.log(l_module_name, 'Error Code', sqlcode);
         WSH_DEBUG_SV.log(l_module_name, 'Error Mesg', sqlerrm);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
END Merge_Location;

--
-- End R12 FP Bug 5075838
--

END WSH_PARTY_MERGE;

/
