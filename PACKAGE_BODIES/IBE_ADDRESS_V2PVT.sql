--------------------------------------------------------
--  DDL for Package Body IBE_ADDRESS_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_ADDRESS_V2PVT" AS
/* $Header: IBEVADB.pls 120.9 2006/01/09 00:59:56 banatara ship $ */


G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_ADDRESS_V2PVT';
l_true VARCHAR2(1) := FND_API.G_TRUE;


----------------- private procedures -----------------------------------------

PROCEDURE do_create_address(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_location           IN  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
  p_party_site         IN  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
  p_primary_billto     IN  VARCHAR2 := FND_API.G_FALSE,
  p_primary_shipto     IN  VARCHAR2 := FND_API.G_FALSE,
  p_billto             IN  VARCHAR2 := FND_API.G_FALSE,
  p_shipto             IN  VARCHAR2 := FND_API.G_FALSE,
  p_default_primary    IN  VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_location_id        OUT NOCOPY NUMBER,
  x_party_site_id      OUT NOCOPY NUMBER
);

PROCEDURE do_delete_address(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_party_id           IN  NUMBER,
  p_party_site_id      IN  NUMBER,
  p_ps_object_version_number   IN  NUMBER,
  p_bill_object_version_number   IN  NUMBER,
  p_ship_object_version_number   IN  NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2);

FUNCTION is_location_changed(
  p_location           IN HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
) RETURN BOOLEAN;

FUNCTION is_party_site_changed(
  p_party_site         IN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE
) RETURN BOOLEAN;

FUNCTION is_party_site_use_changed(
  p_party_site_use     IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE
) RETURN VARCHAR;

-----------------------public procedures -------------------------------------

PROCEDURE create_address(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_location           IN  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
  p_party_site         IN  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
  p_primary_billto     IN  VARCHAR2 := FND_API.G_FALSE,
  p_primary_shipto     IN  VARCHAR2 := FND_API.G_FALSE,
  p_billto             IN  VARCHAR2 := FND_API.G_FALSE,
  p_shipto             IN  VARCHAR2 := FND_API.G_FALSE,
  p_default_primary    IN  VARCHAR2 := FND_API.G_TRUE,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_location_id        OUT NOCOPY NUMBER,
  x_party_site_id      OUT NOCOPY NUMBER)
IS

  l_api_name               CONSTANT VARCHAR2(30) := 'create_address';
  l_api_version            CONSTANT NUMBER       := 1.0;

  l_party_site             HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE := p_party_site;

  l_count                  NUMBER;
  l_gen_party_site_number  VARCHAR2(1);
  l_party_site_number      VARCHAR2(30) := p_party_site.party_site_number;
  l_party_site_use         HZ_PARTY_SITE_V2PUB.party_site_use_rec_type;
  l_party_site_use_id      NUMBER;
  l_loc_id                 NUMBER;

BEGIN

  --IBE_UTIL.enable_debug();

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('enter IBE_ADDRESS_V2PVT.create_address');
  END IF;

  -- standard start of API savepoint
  SAVEPOINT create_address_pvt;

  -- standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  begin
  do_create_address(
    p_api_version,
    p_init_msg_list,
    p_commit,
    p_location,
    p_party_site,
    p_primary_billto,
    p_primary_shipto,
    p_billto,
    p_shipto,
    p_default_primary,
    x_return_status,
    x_msg_count,
    x_msg_data,
    x_location_id,
    x_party_site_id
  );
  end;
  --3639679 begin
  if p_primary_shipto = FND_API.G_TRUE then
    UPDATE
      IBE_ORD_ONECLICK_ALL
    SET
      LAST_UPDATE_DATE = sysdate,
      SHIP_TO_PTY_SITE_ID = x_party_site_id
    WHERE
      party_id = p_party_site.party_id
      and SHIP_TO_PTY_SITE_ID is null;
  end if;

  if p_primary_billto = FND_API.G_TRUE then
    UPDATE
      IBE_ORD_ONECLICK_ALL
    SET
      LAST_UPDATE_DATE = sysdate,
      BILL_TO_PTY_SITE_ID = x_party_site_id
    WHERE
      party_id = p_party_site.party_id
      and BILL_TO_PTY_SITE_ID is null;
  end if;
  --3639679 end

  -- standard check of p_commit
  IF FND_API.to_boolean(p_commit) THEN
    commit;
  END IF;

  -- standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data => x_msg_data
  );

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('exit IBE_ADDRESS_V2PVT.create_address');
  END IF;

  --IBE_UTIL.disable_debug();

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO create_address_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO create_address_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_UNEXPECTED_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

  WHEN OTHERS THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO create_address_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('OTHER exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();
END;

PROCEDURE update_address(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_party_site_id      IN  NUMBER,
  p_ps_object_version_number  IN  NUMBER,
  p_bill_object_version_number  IN  NUMBER,
  p_ship_object_version_number  IN  NUMBER,
  p_location           IN  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
  p_party_site         IN  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
  p_primary_billto     IN  VARCHAR2 := NULL,
  p_primary_shipto     IN  VARCHAR2 := NULL,
  p_billto         IN  VARCHAR2 := NULL,
  p_shipto         IN  VARCHAR2 := NULL,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_location_id        OUT NOCOPY NUMBER,
  x_party_site_id      OUT NOCOPY NUMBER)
IS

  l_api_name           VARCHAR2(30) := 'update_address';
  l_api_version        NUMBER := 1.0;

  l_party_site_use_id  NUMBER;

  l_loc_changed        BOOLEAN := false;
  l_ps_changed         BOOLEAN := false;
  l_psu_changed        VARCHAR(1);
  l_chk_ps             HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE := p_party_site;
  l_chk_loc            HZ_LOCATION_V2PUB.LOCATION_REC_TYPE := p_location;
  l_chk_psu            HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
  l_ps_object_version_number  NUMBER := p_ps_object_version_number;
  l_bill_object_version_number  NUMBER := p_bill_object_version_number;
  l_ship_object_version_number  NUMBER := p_ship_object_version_number;
  l_loc_object_version_number   NUMBER := 1;

  CURSOR c_party_site_use(l_site_use_id NUMBER) IS
    SELECT object_version_number
    FROM hz_party_site_uses
    WHERE party_site_use_id = l_site_use_id
    ORDER BY party_site_use_id DESC;

  CURSOR c_get_location_ovn(l_location_id VARCHAR2) IS
    Select object_version_number
    from hz_locations
    where location_id = l_location_id;

BEGIN

  --IBE_UTIL.enable_debug();

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('enter IBE_ADDRESS_V2PVT.update_address');
  END IF;

  -- standard start of API savepoint
  SAVEPOINT update_address_pvt;

  -- standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- Check if anything is changed before decide what to do
  --
  l_loc_changed := is_location_changed(p_location);
  l_chk_ps.party_site_id := p_party_site_id;
  l_ps_changed  := is_party_site_changed(l_chk_ps);


  --
  -- Process the following conditions:
  --   1. not loc, not ps, not psu => do nothing
  --   2. not loc
  --   2.1 check ps, if changed, create
  --   2.2 check psu, if changed, update, otherwise create
  --   3. else create new loc, ps, psu as usual
  --

  IF l_loc_changed = false AND
     l_ps_changed = false  AND
     l_psu_changed = 'F' THEN

    x_return_status := 'S';
    x_location_id := p_location.location_id;
    x_party_site_id := p_party_site_id;


    --
    -- Do nothing
    --

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('no need to update anything');
    END IF;

  ELSIF l_loc_changed = false then

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('party_site update status: ' || x_return_status);
    END IF;

    --
    -- Update party_site if it's changed
    --
    if l_ps_changed = true  then
--        l_chk_ps.party_id := FND_API.G_MISS_NUM;

        HZ_PARTY_SITE_V2PUB.update_party_site(
          p_init_msg_list,
          l_chk_ps,
          l_ps_object_version_number,
          x_return_status,
          x_msg_count,
          x_msg_data
        );
    end if;

    --check BILL_TO usage
    -- value T=changed, F=not changed, N=usage not found
    l_chk_psu.party_site_id := l_chk_ps.party_site_id;
    l_chk_psu.site_use_type := 'BILL_TO';
    --TCA API doesn't alllowing unsetting primary, NOOP
    l_chk_psu.primary_per_type := 'N';
    --if both billto flags are false, inactivate billto usage
    if p_primary_billto = FND_API.G_FALSE and p_billto = FND_API.G_FALSE then
        l_chk_psu.status := 'I';
    elsif p_primary_billto = FND_API.G_TRUE then
        l_chk_psu.status := 'A';
        l_chk_psu.primary_per_type := 'Y';
    elsif p_billto = FND_API.G_TRUE then
        l_chk_psu.status := 'A';
        --TCA API doesn't alllowing unsetting primary, NOOP
        l_chk_psu.primary_per_type := 'N';
    end if;
    --see if BILL_TO PSU is changed or need to create new one
    l_psu_changed := is_party_site_use_changed(l_chk_psu);
    --if l_psu_changed = 'F', do nothing as nothing changed
    -- if BILL _TO PSU is changed, update PSU record
    if l_psu_changed = 'T' THEN
        OPEN c_party_site_use(l_chk_psu.party_site_use_id);
        FETCH c_party_site_use INTO l_bill_object_version_number;
           HZ_PARTY_SITE_V2PUB.update_party_site_use(
                p_init_msg_list,
                l_chk_psu,
                l_bill_object_version_number,
                x_return_status,
                x_msg_count,
                x_msg_data
            );
        close c_party_site_use;
    --if BILL _TO PSU record not found, create a new one
    elsif l_psu_changed = 'N' and (p_billto = FND_API.G_TRUE or p_primary_billto = FND_API.G_TRUE) THEN
        l_chk_psu.created_by_module := l_chk_ps.created_by_module;
        l_chk_psu.party_site_use_id := NULL;
        if l_chk_psu.created_by_module is NULL then
            l_chk_psu.created_by_module := 'USER MANAGEMENT';
        end if;
        l_chk_psu.application_id := 671;
        HZ_PARTY_SITE_V2PUB.create_party_site_use(
            p_init_msg_list,
            l_chk_psu,
            l_party_site_use_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );
    end if;

    --check SHIP_TO usage record
    -- value T=changed, F=not changed, N=usage not found
    l_chk_psu.party_site_id := l_chk_ps.party_site_id;
    l_chk_psu.site_use_type := 'SHIP_TO';
    --TCA API doesn't alllowing unsetting primary, NOOP
    l_chk_psu.primary_per_type := 'N';
    --if both shipto flags are false, inactivate shipto usage
    if p_primary_shipto = FND_API.G_FALSE and p_shipto = FND_API.G_FALSE then
        l_chk_psu.status:='I';
    elsif p_primary_shipto = FND_API.G_TRUE then
        l_chk_psu.status:='A';
        l_chk_psu.primary_per_type:='Y';
    elsif p_shipto = FND_API.G_TRUE then
        l_chk_psu.status:='A';
        --TCA API doesn't alllowing unsetting primary, NOOP
        l_chk_psu.primary_per_type:='N';
    end if;
    --see if SHIP _TO PSU is changed or need to create one
    l_psu_changed := is_party_site_use_changed(l_chk_psu);

    -- if SHIP_TO PSU is changed, update PSU record
    if l_psu_changed = 'T' THEN
        l_chk_psu.created_by_module := NULL;
        OPEN c_party_site_use(l_chk_psu.party_site_use_id);
        FETCH c_party_site_use INTO l_ship_object_version_number;
        HZ_PARTY_SITE_V2PUB.update_party_site_use(
            p_init_msg_list,
            l_chk_psu,
            l_ship_object_version_number,
            x_return_status,
            x_msg_count,
            x_msg_data
        );
        close c_party_site_use;
    --if SHIP_TO PSU record not found, create a new one
    elsif l_psu_changed = 'N' and (p_shipto = FND_API.G_TRUE or p_primary_shipto = FND_API.G_TRUE) THEN
        l_chk_psu.party_site_use_id := NULL;
        l_chk_psu.created_by_module := l_chk_ps.created_by_module;
        if l_chk_psu.created_by_module is NULL then
            l_chk_psu.created_by_module := 'USER MANAGEMENT';
        end if;
        l_chk_psu.application_id := 671;
        HZ_PARTY_SITE_V2PUB.create_party_site_use(
            p_init_msg_list,
            l_chk_psu,
            l_party_site_use_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );
    end if;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- set return parameters
    --
    x_location_id := p_location.location_id;
    x_party_site_id := p_party_site_id;
    if x_return_status is null then
        x_return_status := 'S';
    end if;

  ELSIF  l_loc_changed = true and  l_ps_changed = false THEN

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.update_address, location changed but no PS change');
    END IF;

      Open c_get_location_ovn(p_location.location_id);
      FETCH c_get_location_ovn INTO l_loc_object_version_number;
       --Convert null to G_Miss, as TCA is ignoring null
       l_chk_loc.address2 := nvl(l_chk_loc.address2,FND_API.G_MISS_CHAR);
       l_chk_loc.address3 := nvl(l_chk_loc.address3,FND_API.G_MISS_CHAR);
       l_chk_loc.address4 := nvl(l_chk_loc.address4,FND_API.G_MISS_CHAR);
       l_chk_loc.city := nvl(l_chk_loc.city,FND_API.G_MISS_CHAR);
       l_chk_loc.postal_code := nvl(l_chk_loc.postal_code,FND_API.G_MISS_CHAR);
       l_chk_loc.state := nvl(l_chk_loc.state,FND_API.G_MISS_CHAR);
       l_chk_loc.province := nvl(l_chk_loc.province,FND_API.G_MISS_CHAR);
       l_chk_loc.county := nvl(l_chk_loc.county,FND_API.G_MISS_CHAR);
       l_chk_loc.address_lines_phonetic := nvl(l_chk_loc.address_lines_phonetic,FND_API.G_MISS_CHAR);
       --End conversion
         HZ_LOCATION_V2PUB.update_location(
          p_init_msg_list,
          l_chk_loc,
          l_loc_object_version_number,
          x_return_status,
          x_msg_count,
          x_msg_data
        );
      Close c_get_location_ovn;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --check BILL_TO usage
    -- value T=changed, F=not changed, N=usage not found
    l_chk_psu.party_site_id := l_chk_ps.party_site_id;
    l_chk_psu.site_use_type := 'BILL_TO';
    --TCA API doesn't alllowing unsetting primary, NOOP
    l_chk_psu.primary_per_type := 'N';
    --if both billto flags are false, inactivate billto usage
    if p_primary_billto = FND_API.G_FALSE and p_billto = FND_API.G_FALSE then
        l_chk_psu.status := 'I';
    elsif p_primary_billto = FND_API.G_TRUE then
        l_chk_psu.status := 'A';
        l_chk_psu.primary_per_type := 'Y';
    elsif p_billto = FND_API.G_TRUE then
        l_chk_psu.status := 'A';
        --TCA API doesn't alllowing unsetting primary, NOOP
        l_chk_psu.primary_per_type := 'N';
    end if;
    --see if BILL_TO PSU is changed or need to create new one
    l_psu_changed := is_party_site_use_changed(l_chk_psu);
    --if l_psu_changed = 'F', do nothing as nothing changed
    -- if BILL _TO PSU is changed, update PSU record
    if l_psu_changed = 'T' THEN
        OPEN c_party_site_use(l_chk_psu.party_site_use_id);
        FETCH c_party_site_use INTO l_bill_object_version_number;
           HZ_PARTY_SITE_V2PUB.update_party_site_use(
                p_init_msg_list,
                l_chk_psu,
                l_bill_object_version_number,
                x_return_status,
                x_msg_count,
                x_msg_data
            );
        close c_party_site_use;
    --if BILL _TO PSU record not found, create a new one
    elsif l_psu_changed = 'N' and (p_billto = FND_API.G_TRUE or p_primary_billto = FND_API.G_TRUE) THEN
        l_chk_psu.created_by_module := l_chk_ps.created_by_module;
        l_chk_psu.party_site_use_id := NULL;
        if l_chk_psu.created_by_module is NULL then
            l_chk_psu.created_by_module := 'USER MANAGEMENT';
        end if;
        l_chk_psu.application_id := 671;
        HZ_PARTY_SITE_V2PUB.create_party_site_use(
            p_init_msg_list,
            l_chk_psu,
            l_party_site_use_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );
    end if;

    --check SHIP_TO usage record
    -- value T=changed, F=not changed, N=usage not found
    l_chk_psu.party_site_id := l_chk_ps.party_site_id;
    l_chk_psu.site_use_type := 'SHIP_TO';
    --TCA API doesn't alllowing unsetting primary, NOOP
    l_chk_psu.primary_per_type := 'N';
    --if both shipto flags are false, inactivate shipto usage
    if p_primary_shipto = FND_API.G_FALSE and p_shipto = FND_API.G_FALSE then
        l_chk_psu.status:='I';
    elsif p_primary_shipto = FND_API.G_TRUE then
        l_chk_psu.status:='A';
        l_chk_psu.primary_per_type:='Y';
    elsif p_shipto = FND_API.G_TRUE then
        l_chk_psu.status:='A';
        --TCA API doesn't alllowing unsetting primary, NOOP
        l_chk_psu.primary_per_type:='N';
    end if;
    --see if SHIP _TO PSU is changed or need to create one
    l_psu_changed := is_party_site_use_changed(l_chk_psu);

    -- if SHIP_TO PSU is changed, update PSU record
    if l_psu_changed = 'T' THEN
        l_chk_psu.created_by_module := NULL;
        OPEN c_party_site_use(l_chk_psu.party_site_use_id);
        FETCH c_party_site_use INTO l_ship_object_version_number;
        HZ_PARTY_SITE_V2PUB.update_party_site_use(
            p_init_msg_list,
            l_chk_psu,
            l_ship_object_version_number,
            x_return_status,
            x_msg_count,
            x_msg_data
        );
        close c_party_site_use;
    --if SHIP_TO PSU record not found, create a new one
    elsif l_psu_changed = 'N' and (p_shipto = FND_API.G_TRUE or p_primary_shipto = FND_API.G_TRUE) THEN
        l_chk_psu.party_site_use_id := NULL;
        l_chk_psu.created_by_module := l_chk_ps.created_by_module;
        if l_chk_psu.created_by_module is NULL then
            l_chk_psu.created_by_module := 'USER MANAGEMENT';
        end if;
        l_chk_psu.application_id := 671;
        HZ_PARTY_SITE_V2PUB.create_party_site_use(
            p_init_msg_list,
            l_chk_psu,
            l_party_site_use_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );
    end if;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_location_id := p_location.location_id;
    x_party_site_id := p_party_site_id;
    if x_return_status is null then
        x_return_status := 'S';
    end if;

  ELSE --Both Loc and PartySite are change, create new address, ps

    --
    -- delete an existing party site
    --

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.delete_address(+)');
    END IF;

    do_delete_address(
      p_api_version,
      p_init_msg_list,
      p_commit,
      p_party_site.party_id,
      p_party_site_id,
      l_ps_object_version_number,
      l_bill_object_version_number,
      l_ship_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.delete_address(-)');
       IBE_UTIL.debug('party_site_id: ' || to_char(p_party_site_id) || ' deleted');
    END IF;


    --
    -- create a new location and party site
    --

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.do_create_address(+)');
    END IF;
    if l_chk_ps.created_by_module is NULL then
        l_chk_ps.created_by_module := 'USER MANAGEMENT';
    end if;
    l_chk_ps.application_id := 671;
    if l_chk_loc.created_by_module is NULL then
        l_chk_loc.created_by_module := 'USER MANAGEMENT';
    end if;
    l_chk_loc.application_id := 671;
    do_create_address(
      p_api_version,
      p_init_msg_list,
      p_commit,
      l_chk_loc,
      l_chk_ps,
      p_primary_billto,
      p_primary_shipto,
      p_billto,
      p_shipto,
      FND_API.G_FALSE,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_location_id,
      x_party_site_id
    );

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.do_create_address(-)');
       IBE_UTIL.debug('location_id = ' || to_char(x_location_id));
       IBE_UTIL.debug('party_site_id = ' || to_char(x_party_site_id));
    END IF;

    --
    -- Update one click setting with new party site id
    --
    --fix 2766830
    UPDATE
      IBE_ORD_ONECLICK_ALL
    SET
      LAST_UPDATE_DATE = sysdate,
      SHIP_TO_PTY_SITE_ID = x_party_site_id
    WHERE
      SHIP_TO_PTY_SITE_ID = p_party_site_id;

    UPDATE
      IBE_ORD_ONECLICK_ALL
    SET
      LAST_UPDATE_DATE = sysdate,
      BILL_TO_PTY_SITE_ID = x_party_site_id
    WHERE
      BILL_TO_PTY_SITE_ID = p_party_site_id;

  END IF;


  -- standard check of p_commit
  IF FND_API.to_boolean(p_commit) THEN
    commit;
  END IF;

  -- standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data => x_msg_data
  );

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('exit IBE_ADDRESS_V2PVT.update_address');
  END IF;

  --IBE_UTIL.disable_debug();

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO update_address_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO update_address_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_UNEXPECTED_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

  WHEN OTHERS THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO update_address_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('OTHER exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();
END;


PROCEDURE delete_address(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_party_id           IN  NUMBER,
  p_party_site_id      IN  NUMBER,
  p_ps_object_version_number   IN  NUMBER,
  p_bill_object_version_number   IN  NUMBER,
  p_ship_object_version_number   IN  NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2)
IS

  l_api_name           CONSTANT VARCHAR2(30) := 'delete_address';
  l_api_version        CONSTANT NUMBER       := 1.0;
  l_party_site         HZ_PARTY_SITE_V2PUB.party_site_rec_type;
  l_ps_object_version_number   NUMBER := p_ps_object_version_number;
  l_bill_object_version_number   NUMBER := p_bill_object_version_number;
  l_ship_object_version_number   NUMBER := p_ship_object_version_number;

BEGIN

  --IBE_UTIL.enable_debug();

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('enter IBE_ADDRESS_V2PVT.delete_address');
  END IF;

  -- standard start of API savepoint
  SAVEPOINT delete_address_pvt;

  -- standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- delete the address
  --

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('IBE_ADDRESS_V2PVT.delete_address(+)');
  END IF;

  do_delete_address(
    p_api_version,
    p_init_msg_list,
    p_commit,
    p_party_id,
    p_party_site_id,
    p_ps_object_version_number,
    p_bill_object_version_number,
    p_ship_object_version_number,
    x_return_status,
    x_msg_count,
    x_msg_data
  );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('IBE_ADDRESS_V2PVT.do_delete_address(-)');
     IBE_UTIL.debug('party_site_id: ' || to_char(p_party_site_id) || ' deleted');
  END IF;


  --
  -- Update one click record
  -- Set party site id to null
  --
  --fix 2766830
  UPDATE
    IBE_ORD_ONECLICK_ALL
  SET
    ENABLED_FLAG = 'N',
    LAST_UPDATE_DATE = sysdate,
    SHIP_TO_PTY_SITE_ID = null
  WHERE
    SHIP_TO_PTY_SITE_ID = p_party_site_id;

  UPDATE
    IBE_ORD_ONECLICK_ALL
  SET
    ENABLED_FLAG = 'N',
    LAST_UPDATE_DATE = sysdate,
    BILL_TO_PTY_SITE_ID = null
  WHERE
    BILL_TO_PTY_SITE_ID = p_party_site_id;


  -- standard check of p_commit
  IF FND_API.to_boolean(p_commit) THEN
    commit;
  END IF;

  -- standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data => x_msg_data
  );

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('exit IBE_ADDRESS_V2PVT.delete_address');
  END IF;

  --IBE_UTIL.disable_debug();

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO delete_address_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO delete_address_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_UNEXPECTED_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

  WHEN OTHERS THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO delete_address_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('OTHER exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

END;

PROCEDURE set_address_usage(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_party_site_id      IN  NUMBER,
  p_primary_flag	   IN  VARCHAR2 := FND_API.G_FALSE,
  p_site_use_type      IN  VARCHAR2,
  p_createdby          IN  VARCHAR2 := 'User Management',
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_party_site_use_id  OUT NOCOPY NUMBER)
IS

  l_api_version        NUMBER := 1.0;
  l_api_name           VARCHAR2(30) := 'set_primary_address';

  l_party_site_use     HZ_PARTY_SITE_V2PUB.party_site_use_rec_type;
  l_party_site_use_id  NUMBER;
--V2
  l_object_version_number  NUMBER;
--l_last_update_date   DATE;

  --v2
  CURSOR c_party_site_use IS
    SELECT party_site_use_id, object_version_number
    FROM ( SELECT party_site_use_id, object_version_number
               FROM hz_party_site_uses
               WHERE party_site_id = p_party_site_id
               AND   site_use_type = p_site_use_type
               ORDER BY status, party_site_use_id DESC
         )
    WHERE rownum = 1;

BEGIN

  --IBE_UTIL.enable_debug();

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('enter IBE_ADDRESS_V2PVT.set_primary_address');
  END IF;

  -- standard start of API savepoint
  SAVEPOINT set_address__usage_pvt;

  -- standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- try finding an existing party site use

  OPEN c_party_site_use;
  FETCH c_party_site_use INTO l_party_site_use_id, l_object_version_number;


	if (p_primary_flag = FND_API.G_TRUE) then
	  l_party_site_use.primary_per_type := 'Y';
	end if;

  IF c_party_site_use%FOUND THEN

    -- update an existing party site use
    l_party_site_use.party_site_use_id := l_party_site_use_id;
    l_party_site_use.status := 'A';

    HZ_PARTY_SITE_V2PUB.update_party_site_use (
        p_init_msg_list,
        l_party_site_use,
        l_object_version_number,
        x_return_status,
        x_msg_count,
        x_msg_data);

    x_party_site_use_id := l_party_site_use_id;

  ELSE

    -- create a party site if not found
    l_party_site_use.party_site_id := p_party_site_id;
    l_party_site_use.site_use_type := p_site_use_type;
    l_party_site_use.created_by_module := p_createdby;

    l_party_site_use.application_id := 671;
    --V2
--    l_party_site_use.begin_date := sysdate;
    l_party_site_use.status := 'A';


    HZ_PARTY_SITE_V2PUB.create_party_site_use (
        p_init_msg_list,
        l_party_site_use,
        x_party_site_use_id,
        x_return_status,
        x_msg_count,
        x_msg_data);
     --V2
    /*HZ_PARTY_PUB.create_party_site_use(
      p_api_version,
      p_init_msg_list,
      p_commit,
      l_party_site_use,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_party_site_use_id
    );
    */
  END IF;

  CLOSE c_party_site_use;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- standard check of p_commit
  IF FND_API.to_boolean(p_commit) THEN
    commit;
  END IF;

  -- standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data => x_msg_data
  );

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('exit IBE_ADDRESS_V2PVT.set_primary_address');
  END IF;

  --IBE_UTIL.disable_debug();

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO set_address__usage_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO set_address__usage_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_UNEXPECTED_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

  WHEN OTHERS THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO set_address__usage_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('OTHER exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();
END;

PROCEDURE get_primary_addr_details(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
    p_party_id           IN  NUMBER,
    p_site_use_type      IN  VARCHAR2,
    p_org_id		 IN  NUMBER,
    p_alt_party_id       IN  NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_party_site_id      OUT NOCOPY NUMBER,
    x_party_id           OUT NOCOPY NUMBER
    )
IS
BEGIN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Starting getPrimary Addr Details ');
     END IF;
     x_party_id     := p_party_id;
     get_primary_addr_id
     (p_api_version => p_api_version,
      p_party_id => p_party_id,
      p_site_use_type => p_site_use_type,
      p_org_id => p_org_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data     => x_msg_data,
      x_party_site_id => x_party_site_id
     );
     if(x_party_site_id = FND_API.G_MISS_NUM OR x_party_site_id is null) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug(' getPrimary Addr Details of alt PartyId ');
      END IF;
      x_party_id := p_alt_party_id;
      get_primary_addr_id
      (p_api_version => p_api_version,
      p_party_id => p_alt_party_id,
      p_site_use_type => p_site_use_type,
      p_org_id => p_org_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data     => x_msg_data,
      x_party_site_id => x_party_site_id
     );
     END IF;
     if(x_party_Site_id = FND_API.G_MISS_NUM OR x_party_site_id is null) then
       x_party_id := null;
     end if;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Ending getPrimary Addr Details with party_site_id '||x_party_site_id);
     END IF;
END;

PROCEDURE get_primary_addr_id(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_party_id           IN  NUMBER,
  p_site_use_type      IN  VARCHAR2,
  p_org_id	       IN  NUMBER,
  p_get_org_prim_addr  IN VARCHAR2  := FND_API.G_FALSE,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_party_site_id      OUT NOCOPY NUMBER)
IS

  l_api_name           CONSTANT VARCHAR2(30) := 'get_primary_addr_id';
  l_api_version        CONSTANT NUMBER := 1.0;
  site_type		   VARCHAR2(30) := ' ';
  hr_type              VARCHAR2(30) := ' ';
  l_party_id		   NUMBER;
  l_org_id             NUMBER;
  l_contact_org_id     NUMBER;

   cursor c_getPrimAddrId_2(l_party_id NUMBER,l_org_id NUMBER,hr_type VARCHAR2,site_type VARCHAR2) IS
          SELECT ps.party_site_id
          FROM hz_party_sites ps, hz_party_site_uses psu, hz_locations loc, hr_organization_information hr
          WHERE
             ps.party_id = l_party_id AND
             ps.status = 'A' AND
             ps.location_id = loc.location_id AND
             ps.party_site_id = psu.party_site_id AND
             psu.primary_per_type = 'Y' AND
             psu.site_use_type = site_type AND
             psu.status = 'A' AND
             NVL(psu.end_date,sysdate+1) > sysdate AND
             hr.organization_id = l_org_id AND
             hr.org_information_context = hr_type AND
             hr.org_information1 = loc.country AND
          ( NOT EXISTS (
		       SELECT 1 FROM hz_cust_acct_sites_all cas1
                       WHERE cas1.party_site_id = ps.party_site_id
			    AND cas1.org_id = MO_GLOBAL.get_current_org_id()) OR
	    ( EXISTS ( SELECT 1 FROM hz_cust_acct_sites_all
                       WHERE party_site_id = ps.party_site_id
			    AND org_id = MO_GLOBAL.get_current_org_id()
			    AND status = 'A') AND
		(
                  NOT EXISTS (
                       SELECT 1 FROM hz_cust_acct_sites_all cas2, hz_cust_site_uses_all csu2
                       WHERE csu2.cust_acct_site_id = cas2.cust_acct_site_id
                         AND cas2.party_site_id = ps.party_site_id
                         AND cas2.org_id = MO_GLOBAL.get_current_org_id()
                         AND csu2.site_use_code = site_type) OR
                  EXISTS (
                       SELECT 1
                       FROM hz_cust_acct_sites_all cas, hz_cust_site_uses_all csu
                       WHERE cas.party_site_id = ps.party_site_id AND
                             cas.org_id = MO_GLOBAL.get_current_org_id() AND
                             csu.cust_acct_site_id (+) = cas.cust_acct_site_id AND
                             NVL(csu.status,'A') = 'A' AND
            		     NVL(csu.site_use_code,site_type) = site_type)
            	 )
            )
          );

   cursor c_getPrimAddrId_1(l_party_id NUMBER,l_org_id NUMBER,hr_type VARCHAR2,site_type VARCHAR2) IS
          SELECT ps.party_site_id
          FROM hz_party_sites ps, hz_party_site_uses psu
          WHERE
             ps.party_id = l_party_id AND
             ps.status = 'A' AND
             ps.party_site_id = psu.party_site_id AND
             psu.primary_per_type =  'Y' AND
             psu.site_use_type = site_type AND
             psu.status = 'A' AND
             NVL(psu.end_date,sysdate+1) > sysdate AND
          NOT EXISTS (
              SELECT 1
              FROM hr_organization_information hr
              WHERE
	         hr.organization_id = l_org_id AND
	         hr.org_information_context = hr_type AND
	         rownum = 1) AND
          ( NOT EXISTS (
		       SELECT 1 FROM hz_cust_acct_sites_all cas1
                       WHERE cas1.party_site_id = ps.party_site_id
			    AND cas1.org_id = MO_GLOBAL.get_current_org_id()) OR
	    ( EXISTS ( SELECT 1 FROM hz_cust_acct_sites_all
                       WHERE party_site_id = ps.party_site_id
			    AND org_id = MO_GLOBAL.get_current_org_id()
			    AND status = 'A') AND
		(
                  NOT EXISTS (
                       SELECT 1 FROM hz_cust_acct_sites_all cas2, hz_cust_site_uses_all csu2
                       WHERE csu2.cust_acct_site_id = cas2.cust_acct_site_id
                         AND cas2.party_site_id = ps.party_site_id
                         AND cas2.org_id = MO_GLOBAL.get_current_org_id()
                         AND csu2.site_use_code = site_type) OR
                  EXISTS (
                       SELECT 1
                       FROM hz_cust_acct_sites_all cas, hz_cust_site_uses_all csu
                       WHERE cas.party_site_id = ps.party_site_id AND
                             cas.org_id = MO_GLOBAL.get_current_org_id() AND
                             csu.cust_acct_site_id (+) = cas.cust_acct_site_id AND
                             NVL(csu.status,'A') = 'A' AND
            		     NVL(csu.site_use_code,site_type) = site_type)
            	 )
            )
          );

   cursor c_getOrgPartyId(l_party_id number) IS
     select subject_id from hz_relationships
     where party_id = l_party_id and subject_type = 'ORGANIZATION';

BEGIN

  --IBE_UTIL.enable_debug();

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('enter IBE_ADDRESS_V2PVT.get_primary_addr_id for party_id'||p_party_id);
    END IF;




    -- standard start of API savepoint
    SAVEPOINT get_primary_addr_id_pvt;

    -- standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call(l_api_version,
							    p_api_version,
  							    l_api_name,
							    G_PKG_NAME)
    THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_boolean(p_init_msg_list) THEN
	   FND_MSG_PUB.initialize;
    END IF;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	 IBE_UTIL.debug('p_site_use_type = '||p_site_use_type);
END IF;


	 IF (p_site_use_type = 'S') THEN
	    site_type := 'SHIP_TO';
	    hr_type := 'SHIP_TO_COUNTRY';
      END IF;
	 IF (p_site_use_type = 'B') THEN
	     site_type := 'BILL_TO';
		hr_type := 'BILL_TO_COUNTRY';
      END IF;

      x_party_site_id := null;

      OPEN c_getPrimAddrId_1(p_party_id,p_org_id,hr_type,site_type);
      FETCH c_getPrimAddrId_1 INTO x_party_site_id;
      CLOSE c_getPrimAddrId_1;

      IF (x_party_site_id IS NULL) THEN
	     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Accessing the SECOND cursor');
		END IF;
          OPEN c_getPrimAddrId_2(p_party_id,p_org_id,hr_type,site_type);
          FETCH c_getPrimAddrId_2 INTO x_party_site_id;
          CLOSE c_getPrimAddrId_2;
      ELSE
	     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('NOT Accessing the SECOND cursor');
		END IF;
      END IF;


	 /* madesai - 7/10 fixed bug 2608767 */
	 if x_party_site_id IS NULL then
	   if FND_API.to_boolean(p_get_org_prim_addr) then
             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('ContactPrimAddr not found,get Org Primary Addr');
             END IF;
	     OPEN c_getOrgPartyId(p_party_id);
	     FETCH c_getOrgPartyId INTO l_contact_org_id;
             if c_getOrgPartyId%notfound then
               IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_UTIL.debug('Org Id is not found');
               END IF;
	       x_party_site_id := null;
	     else
	       get_primary_addr_id
	        (p_api_version => p_api_version,
	         p_party_id => l_contact_org_id,
		 p_site_use_type => p_site_use_type,
		 p_org_id => p_org_id,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data     => x_msg_data,
		 x_party_site_id => x_party_site_id
  	        );
               IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_UTIL.debug('Primary address for orgId'||l_contact_org_id||'is '||x_party_site_id);
               END IF;
	    end if;
	   else
	      x_party_site_id := null;
	   end if;--p_get_org_prim_addr of loop
        end if;--getPrimAddrId cursor end
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- standard check of p_commit
	 IF FND_API.to_boolean(p_commit) THEN
	    commit;
	 END IF;

	 -- standard call to get message count and if count is 1, get message info
	 FND_MSG_PUB.count_and_get(
	    	p_encoded => FND_API.G_FALSE,
	     p_count => x_msg_count,
	    p_data => x_msg_data
					);

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('Ending getPrimary Addr with party_site_id '||x_party_site_id);
     IBE_UTIL.debug('exit IBE_ADDRESS_V2PVT.get_primary_address');
  END IF;

    --IBE_UTIL.disable_debug();

EXCEPTION
  WHEN OTHERS THEN
  --IBE_UTIL.enable_debug();

  ROLLBACK TO get_primary_addr_id_pvt;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
     p_data => x_msg_data
	    );
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('OTHER exception');
     IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
     IBE_UTIL.debug('x_msg_data ' || x_msg_data);
     IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
     IBE_UTIL.debug('error text : '|| SQLERRM);
  END IF;

  --IBE_UTIL.disable_debug();
END;


PROCEDURE get_primary_address(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_party_id           IN  NUMBER,
  p_site_use_type      IN  VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_party_site_id      OUT NOCOPY NUMBER,
  x_location_id        OUT NOCOPY NUMBER)
IS

  l_api_name           CONSTANT VARCHAR2(30) := 'get_primary_address';
  l_api_version        CONSTANT NUMBER := 1.0;

BEGIN

  --IBE_UTIL.enable_debug();

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('enter IBE_ADDRESS_V2PVT.get_primary_address');
  END IF;

  -- standard start of API savepoint
  SAVEPOINT get_primary_address_pvt;

  -- standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  BEGIN
    SELECT DISTINCT
      party_site_id, location_id
    INTO
      x_party_site_id, x_location_id
    FROM
      hz_party_sites_v
    WHERE
      party_id = p_party_id AND
      site_use_type = p_site_use_type AND
      status = 'A' AND
      primary_per_type = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_party_site_id := -1;
      x_location_id := -1;
    WHEN TOO_MANY_ROWS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('TOO_MANY_ROWS exception found');
         IBE_UTIL.debug('p_party_id = ' || to_char(p_party_id));
         IBE_UTIL.debug('p_site_use_type = ' || p_site_use_type);
      END IF;
      x_party_site_id := -1;
      x_location_id := -1;
  END;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- standard check of p_commit
  IF FND_API.to_boolean(p_commit) THEN
    commit;
  END IF;

  -- standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data => x_msg_data
  );

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('exit IBE_ADDRESS_V2PVT.get_primary_address');
  END IF;

  --IBE_UTIL.disable_debug();

EXCEPTION
  WHEN OTHERS THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO get_primary_address_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('OTHER exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();
END;


PROCEDURE do_create_address(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_location           IN  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
  p_party_site         IN  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
  p_primary_billto     IN  VARCHAR2 := FND_API.G_FALSE,
  p_primary_shipto     IN  VARCHAR2 := FND_API.G_FALSE,
  p_billto             IN  VARCHAR2 := FND_API.G_FALSE,
  p_shipto             IN  VARCHAR2 := FND_API.G_FALSE,
  p_default_primary    IN  VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_location_id        OUT NOCOPY NUMBER,
  x_party_site_id      OUT NOCOPY NUMBER)
IS

  l_location               HZ_LOCATION_V2PUB.LOCATION_REC_TYPE := p_location;
  l_party_site             HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE := p_party_site;

  l_count                  NUMBER;
  l_gen_party_site_number  VARCHAR2(1);
  l_party_site_use         HZ_PARTY_SITE_V2PUB.party_site_use_rec_type;
  l_party_site_number      VARCHAR2(30) := p_party_site.party_site_number;
  l_party_site_use_id      NUMBER;
  l_loc_id                 NUMBER;
  l_prim_site_id           NUMBER;
  l_prim_loc_id            NUMBER;
  l_primary_billto         VARCHAR2(1) := p_primary_billto;
  l_primary_shipto         VARCHAR2(1) := p_primary_shipto;
  l_createdby              VARCHAR2(150) :='User Management';
  l_org_id                 NUMBER;
  l_addr_val               VARCHAR2(30);
  l_lock_flag              VARCHAR2(1) := FND_API.G_FALSE;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('enter IBE_ADDRESS_V2PVT.do_create_address');
  END IF;

  --
  -- create a location
  --

  l_location.location_id := FND_API.G_MISS_NUM;
  l_location.address_effective_date := sysdate;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('hz_location_v2pub.create_location(+)');
  END IF;

--V2
/*  HZ_location_v2pub.create_location(
    p_api_version,
    p_init_msg_list,
    p_commit,
    l_location,
    x_return_status,
    x_msg_count,
    x_msg_data,
    x_location_id
  );*/

    HZ_LOCATION_V2PUB.create_location (
        p_init_msg_list,
        l_location,
        x_location_id,
        x_return_status,
        x_msg_count,
        x_msg_data
    );

  l_location.location_id := x_location_id;
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('hz_location_v2pub.create_location(-)');
     IBE_UTIL.debug('locaiton_id = ' || x_location_id);
  END IF;


  --
  -- prepare to create a party site
  --

  l_party_site.party_site_id := FND_API.G_MISS_NUM;
  l_party_site.location_id := x_location_id;
  l_party_site.status := 'A';
  --V2
  --l_party_site.start_date_active := sysdate;

  -- if GENERATE_PARTY_SITE_NUMBER is 'N' and party site number
  -- is not passed it, generate from sequence till a unique value
  -- is obtained.

  l_gen_party_site_number :=
    fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER');

  IF l_gen_party_site_number = 'N' THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('HZ_GENERATE_PARTY_SITE_NUMBER is off');
    END IF;

    IF l_party_site_number = FND_API.G_MISS_CHAR OR
       l_party_site_number IS NULL THEN

      l_count := 1;

      WHILE l_count > 0 LOOP

        SELECT to_char(hz_party_site_number_s.nextval)
        INTO l_party_site_number
        FROM dual;

        SELECT COUNT(*) INTO l_count
        FROM hz_party_sites_v
        WHERE party_site_number = l_party_site_number;

      END LOOP;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('party_site_number from sequence : ' || l_party_site_number);
      END IF;

      l_party_site.party_site_number := l_party_site_number;

    END IF;
  END IF;

  --
  -- create a party site
  --

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('hz_party_v2pub.create_party_site(+)');
  END IF;

--V2
/*  HZ_PARTY_PUB.create_party_site(
    p_api_version,
    p_init_msg_list,
    p_commit,
    l_party_site,
    x_return_status,
    x_msg_count,
    x_msg_data,
    x_party_site_id,
    l_party_site_number
  );
*/

    HZ_PARTY_SITE_V2PUB.create_party_site (
        p_init_msg_list,
        l_party_site,
        x_party_site_id,
        l_party_site_number,
        x_return_status,
        x_msg_count,
        x_msg_data
    );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('hz_party_site_v2pub.create_party_site(-)');
     IBE_UTIL.debug('party_site_id = ' || x_party_site_id);
  END IF;

  --
  -- if p_default_primary is true, create a primary address
  -- if user does not already have one.
  --

  IF p_default_primary = FND_API.G_TRUE THEN

    -- check primary billing address

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.get_primary_address(+)');
    END IF;

    IBE_ADDRESS_V2PVT.get_primary_address(
      p_api_version,
      p_init_msg_list,
      p_commit,
      l_party_site.party_id,
      'BILL_TO',
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_prim_site_id,
      l_prim_loc_id
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.get_primary_address(-)');
       IBE_UTIL.debug('l_prim_site_id = ' || l_prim_site_id);
    END IF;

    IF (l_prim_site_id = -1) THEN
      -- no primary billing address
      l_primary_billto := FND_API.G_TRUE;
    END IF;

    -- check primary shipping address

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.get_primary_address(+)');
    END IF;

    IBE_ADDRESS_V2PVT.get_primary_address(
      p_api_version,
      p_init_msg_list,
      p_commit,
      l_party_site.party_id,
      'SHIP_TO',
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_prim_site_id,
      l_prim_loc_id
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.get_primary_address(-)');
       IBE_UTIL.debug('l_prim_site_id = ' || l_prim_site_id);
    END IF;

    IF (l_prim_site_id = -1) THEN
      -- no primary shipping address
      l_primary_shipto := FND_API.G_TRUE;
    END IF;

  END IF;


  --
  -- create a party site use for bill to or ship to
  --

  IF (l_primary_billto = FND_API.G_TRUE  OR p_billto = FND_API.G_TRUE)THEN

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.set_primary_address(+) for BILL_TO');
    END IF;
    l_createdby := l_location.created_by_module;
    IBE_ADDRESS_V2PVT.set_address_usage(
      p_api_version,
      p_init_msg_list,
      P_commit,
      x_party_site_id,
      l_primary_billto,
      'BILL_TO',
      l_createdby,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_party_site_use_id
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.set_primary_address(-)');
       IBE_UTIL.debug('party_site_use_id = ' || l_party_site_use_id);
    END IF;

  END IF;

  IF (l_primary_shipto = FND_API.G_TRUE OR p_shipto = FND_API.G_TRUE) THEN
    l_createdby := l_location.created_by_module;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.set_primary_address(+) for SHIP_TO');
    END IF;
    IBE_ADDRESS_V2PVT.set_address_usage(
      p_api_version,
      p_init_msg_list,
      P_commit,
      x_party_site_id,
      l_primary_shipto,
      'SHIP_TO',
      l_createdby,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_party_site_use_id
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ADDRESS_V2PVT.set_address_usage(-)');
       IBE_UTIL.debug('party_site_use_id = ' || l_party_site_use_id);
    END IF;

  END IF;


  --
  -- For debug purpose
  --
  l_org_id := MO_GLOBAL.get_current_org_id();

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('Current user org id = ' || l_org_id);
     IBE_UTIL.debug('=== Checking system parameters ===');
     --IBE_UTIL.debug('sysparm.org_id = ' || to_char(arp_standard.sysparm.org_id));
     --IBE_UTIL.debug('sysparm.default_country = ' || arp_standard.sysparm.default_country);
     IBE_UTIL.debug('country = ' || p_location.country);
     IBE_UTIL.debug('address1 = ' || p_location.address1);
     IBE_UTIL.debug('city = ' || p_location.city);
     IBE_UTIL.debug('county = ' || p_location.county);
     IBE_UTIL.debug('state = ' || p_location.state);
     IBE_UTIL.debug('postal_code = ' || p_location.postal_code);
  END IF;
  --
  -- End of debug purpose
  --

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('hz_tax_assignment_pub.create_loc_assignment(+)');
    END IF;

    HZ_TAX_ASSIGNMENT_V2PUB.create_loc_assignment(
        p_init_msg_list,
        l_location.location_id,
        l_lock_flag,
        l_location.created_by_module,
        l_location.application_id,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_loc_id
    );
--V2
/*    HZ_TAX_ASSIGNMENT_PUB.create_loc_assignment(
      p_api_version,
      p_init_msg_list,
      p_commit,
      x_location_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_loc_id,
      FND_API.G_TRUE
    );
*/
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('hz_tax_assignment_pub.create_loc_assignment(-)');
       IBE_UTIL.debug('loc_id = ' || to_char(l_loc_id));
    END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('exit IBE_ADDRESS_V2PVT.do_create_address');
  END IF;

END;

PROCEDURE do_delete_address(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_party_id           IN  NUMBER,
  p_party_site_id      IN  NUMBER,
  p_ps_object_version_number   IN  NUMBER,
  p_bill_object_version_number   IN  NUMBER,
  p_ship_object_version_number   IN  NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2)
IS

  cursor c_psu is
    select party_site_use_id,site_use_type,object_version_number
    from hz_party_site_uses
    where party_site_id = p_party_site_id
  for update nowait;

  l_api_name           CONSTANT VARCHAR2(30) := 'delete_address';
  l_api_version        CONSTANT NUMBER       := 1.0;
  l_party_site         HZ_PARTY_SITE_V2PUB.party_site_rec_type;
  l_party_site_use     HZ_PARTY_SITE_V2PUB.party_site_use_rec_type;
  l_party_site_use_id  NUMBER;
  l_site_use_type      VARCHAR(30);
  l_ps_object_version_number NUMBER := p_ps_object_version_number;
  l_psu_object_version_number NUMBER;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('enter IBE_ADDRESS_V2PVT.do_delete_address');
  END IF;

  --
  -- update party site
  --

  l_party_site.party_site_id := p_party_site_id;
  l_party_site.status := 'I';
  l_party_site_use.status := 'I';
  --fix bug 3382268
  l_party_site_use.primary_per_type := 'N';

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('hz_party_v2pub.update_party_site(+)');
  END IF;

  HZ_PARTY_SITE_V2PUB.update_party_site (
     p_init_msg_list,
     l_party_site,
     l_ps_object_version_number,
     x_return_status,
     x_msg_count,
  x_msg_data);

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('hz_party_v2pub.update_party_site(-)');
     IBE_UTIL.debug('hz_party_v2pub.update_party_site_use(+)');
  END IF;
  --delete all psu for a given party site that's to be deleted
  open c_psu;
  Loop
      fetch c_psu into l_party_site_use_id,l_site_use_type,l_psu_object_version_number;
      EXIT When c_psu%NOTFOUND;
      l_party_site_use.party_site_use_id := l_party_site_use_id;
      /*if l_site_use_type = 'BILL_TO' then
        l_psu_object_version_number := p_bill_object_version_number;
      elsif l_site_use_type = 'SHIP_TO' then
        l_psu_object_version_number := p_ship_object_version_number;
      end if;
      */
        HZ_PARTY_SITE_V2PUB.update_party_site_use(
              p_init_msg_list,
              l_party_site_use,
              l_psu_object_version_number,
              x_return_status,
              x_msg_count,
              x_msg_data
          );
   End Loop;
   close c_psu;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('hz_party_v2pub.update_party_site_use(-)');
  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('hz_party_v2pub.update_party_site(-)');
     IBE_UTIL.debug('exit IBE_ADDRESS_V2PVT.do_delete_address');
  END IF;

END;

--
-- Check if the user input has changed from the database
--
FUNCTION is_location_changed(
  p_location           IN HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
) RETURN BOOLEAN
IS
  l_changed            BOOLEAN := false;
  l_dummy              NUMBER;
  l_gmiss              VARCHAR2(1) := NULL;
BEGIN

  l_gmiss := FND_API.G_MISS_CHAR;
  -- for debug purpose
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('location_id = ' || p_location.location_id || '.');
     IBE_UTIL.debug('address1 = ' || p_location.address1 || '.');
     IBE_UTIL.debug('address2 = ' || p_location.address2 || '.');
     IBE_UTIL.debug('address3 = ' || p_location.address3 || '.');
     IBE_UTIL.debug('address4 = ' || p_location.address4 || '.');
     IBE_UTIL.debug('city = ' || p_location.city || '.');
     IBE_UTIL.debug('county = ' || p_location.county || '.');
     IBE_UTIL.debug('province = ' || p_location.province || '.');
     IBE_UTIL.debug('state = ' || p_location.state || '.');
     IBE_UTIL.debug('postal_code = ' || p_location.postal_code || '.');
     IBE_UTIL.debug('country = ' || p_location.country || '.');
     IBE_UTIL.debug('address_lines_phonetic = ' || p_location.address_lines_phonetic || '.');
  END IF;

  BEGIN
    SELECT location_id INTO l_dummy
    FROM hz_locations
    WHERE location_id = p_location.location_id
    AND   nvl(address1, l_gmiss) = nvl(p_location.address1, l_gmiss)
    AND   nvl(address2, l_gmiss) = nvl(p_location.address2, l_gmiss)
    AND   nvl(address3, l_gmiss) = nvl(p_location.address3, l_gmiss)
    AND   nvl(address4, l_gmiss) = nvl(p_location.address4, l_gmiss)
    AND   nvl(city, l_gmiss)     = nvl(p_location.city, l_gmiss)
    AND   nvl(county, l_gmiss)   = nvl(p_location.county, l_gmiss)
    AND   nvl(province, l_gmiss) = nvl(p_location.province, l_gmiss)
    AND   nvl(state, l_gmiss)    = nvl(p_location.state, l_gmiss)
    AND   nvl(postal_code, l_gmiss) = nvl(p_location.postal_code, l_gmiss)
    AND   nvl(country, l_gmiss)  = nvl(p_location.country, l_gmiss)
    AND   nvl(address_lines_phonetic, l_gmiss) = nvl(p_location.address_lines_phonetic, l_gmiss);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_changed := true;
  END;

  IF l_changed THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('location is changed');
    END IF;
  ELSE
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('location is not changed');
    END IF;
  END IF;

  return l_changed;
END;


--
-- Check if the user input has changed from the database
--
FUNCTION is_party_site_changed(
  p_party_site         IN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE
) RETURN BOOLEAN
IS
  l_changed            BOOLEAN := false;
  l_dummy              NUMBER;
  l_gmiss              VARCHAR2(1) := NULL;
BEGIN

   l_gmiss := FND_API.G_MISS_CHAR;
  -- for debug purpose
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('party_site_id = ' || p_party_site.party_site_id || '.');
     IBE_UTIL.debug('party_site_name = ' || p_party_site.party_site_name || '.');
     IBE_UTIL.debug('addressee = ' || p_party_site.addressee || '.');
  END IF;

  BEGIN
    SELECT party_site_id INTO l_dummy
    FROM hz_party_sites
    WHERE party_site_id   = p_party_site.party_site_id
    AND nvl(party_site_name,l_gmiss)=nvl(p_party_site.party_site_name,l_gmiss)
    AND nvl(addressee,l_gmiss)= nvl(p_party_site.addressee,l_gmiss)
    AND (identifying_address_flag = 'Y' or p_party_site.identifying_address_flag='N');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_changed := true;
  END;

  IF l_changed THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('party_site is changed');
    END IF;
  ELSE
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('party_site is not changed');
    END IF;
  END IF;

  return l_changed;
END;


--
-- Check if update is necessary for party_site_use
--

FUNCTION is_party_site_use_changed(
  p_party_site_use     IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE
) RETURN VARCHAR
IS
  l_psu_id              NUMBER := NULL;
  --T is changed, F is not changed, N is not found
  --default value is no change
  l_status            VARCHAR(1) := 'F';
BEGIN

  --
  -- check if a party_site_use exists for the given usage
  --
  BEGIN
    SELECT party_site_use_id
    INTO l_psu_id
    FROM ( SELECT distinct party_site_use_id,status  FROM hz_party_site_uses
           WHERE site_use_type = p_party_site_use.site_use_type
           AND party_site_id = p_party_site_use.party_site_id
           AND (primary_per_type = 'N' OR primary_per_type = 'Y')
           ORDER BY status,party_site_use_id desc)
    WHERE rownum=1;

    p_party_site_use.party_site_use_id := l_psu_id;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('assign party site use ID: '||p_party_site_use.party_site_use_id);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_status := 'N';
  END;


  IF l_status = 'N'  THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('party_site_use is not found');
    END IF;
  ELSE
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('party_site_use is found');
    END IF;
    BEGIN
      SELECT distinct party_site_use_id INTO l_psu_id
      FROM hz_party_site_uses
      WHERE NVL(status, 'A') = p_party_site_use.status
      AND party_site_use_id = p_party_site_use.party_site_use_id
      AND primary_per_type = p_party_site_use.primary_per_type;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_status := 'T';
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('l_status is set to true');
        END IF;
    END;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('l_status is: '||l_status);
  END IF;
  return l_status;
END;



PROCEDURE valid_usages (
  p_api_version        IN NUMBER,
  p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
  p_party_site_id      IN NUMBER,
  p_operating_unit_id  IN NUMBER,
  p_usage_codes        IN JTF_VARCHAR2_TABLE_100,
  x_return_codes       OUT NOCOPY JTF_VARCHAR2_TABLE_100,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2)
IS

  l_api_name           CONSTANT VARCHAR2(30) := 'Valid_Usages';
  l_api_version        CONSTANT NUMBER       := 1.0;

  l_psite_terr_code VARCHAR2(30);
  l_flag            BOOLEAN;

  CURSOR c1(l_c_party_site_id IN NUMBER)
  IS SELECT country FROM hz_locations
    WHERE location_id IN
    (SELECT location_id FROM hz_party_sites
    WHERE party_site_id = l_c_party_site_id);

  CURSOR c2(l_c_operating_unit_id IN NUMBER, l_c_usage_code IN VARCHAR2)
  IS SELECT org_information1 FROM hr_organization_information
    WHERE organization_id = l_c_operating_unit_id
    AND org_information_context = l_c_usage_code;

BEGIN

  --IBE_UTIL.enable_debug();

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get the country associated with the party site
  --
  OPEN c1(p_party_site_id);
  FETCH c1 INTO l_psite_terr_code;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    FND_MESSAGE.Set_Name('IBE', 'IBE_OU_GET_PSITE_COUNTRY_FAIL');
    FND_MESSAGE.Set_Token('PARTY_SITE_ID', p_party_site_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c1;

  x_return_codes := JTF_VARCHAR2_TABLE_100();
  FOR i IN 1..p_usage_codes.COUNT LOOP

    x_return_codes.EXTEND();
    x_return_codes(i) := FND_API.G_RET_STS_ERROR;

    --
    -- Process SHIP_TO_COUNTRY usage code
    --

    -- Set flag to false. l_flag is used to check if there is at least one
    -- entry for ship to countries. If flag is true, then there is at least
    -- one entry in ship to countries.
    l_flag := FALSE;

    IF (p_usage_codes(i) = 'SHIP_TO_COUNTRY') THEN

      FOR r2 IN c2(p_operating_unit_id, p_usage_codes(i)) LOOP

        IF (l_flag = FALSE) THEN
          l_flag := TRUE;
        END IF;

        IF (r2.org_information1 = l_psite_terr_code) THEN
          x_return_codes(i) := FND_API.G_RET_STS_SUCCESS;
          EXIT;
        END IF;

      END LOOP; -- end for r2

      IF (l_flag = FALSE) THEN
        x_return_codes(i) := FND_API.G_RET_STS_SUCCESS;
      END IF;

    END IF; -- end if SHIP_TO_COUNTRY


    --
    -- Process BILL_TO_COUNTRY usage code
    --

    -- Set flag to false. l_flag is used to check if there is at least one
    -- entry for bill to countries. If flag is true, then there is at least
    -- one entry in bill to countries.
    l_flag := FALSE;

    IF (p_usage_codes(i) = 'BILL_TO_COUNTRY') THEN

      FOR r2 IN c2(p_operating_unit_id, p_usage_codes(i)) LOOP

        IF (l_flag = FALSE) THEN
          l_flag := TRUE;
        END IF;

        IF (r2.org_information1 = l_psite_terr_code) THEN
          x_return_codes(i) := FND_API.G_RET_STS_SUCCESS;
          EXIT;
        END IF;

      END LOOP; -- end for r2

      IF (l_flag = FALSE) THEN
        x_return_codes(i) := FND_API.G_RET_STS_SUCCESS;
      END IF;

    END IF; -- end if BILL_TO_COUNTRY

  END LOOP; -- end for i

  --IBE_UTIL.disable_debug();

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END;

PROCEDURE copy_party_site (
  p_api_version   IN NUMBER,
  p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
  p_commit        IN  VARCHAR2 := FND_API.G_FALSE,
  p_party_site    IN  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
  p_location      IN  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
  x_party_site_id OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_party_site_id     NUMBER;
l_party_site_number NUMBER;
lx_msg_data         VARCHAR2(2000);
l_api_name          CONSTANT VARCHAR2(30) := 'copy_party_site';

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('IBE_ADDRESS_V2PVT.copy_pary_site:Begin ');
  END IF;
/*PROCEDURE create_party_site (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_rec                IN          PARTY_SITE_REC_TYPE,
    x_party_site_id                 OUT NOCOPY         NUMBER,
    x_party_site_number             OUT NOCOPY         VARCHAR2,
    x_return_status                 OUT NOCOPY         VARCHAR2,
    x_msg_count                     OUT NOCOPY         NUMBER,
    x_msg_data                      OUT NOCOPY         VARCHAR2
);
*/

  HZ_PARTY_SITE_V2PUB.create_party_site (
        p_init_msg_list     => p_init_msg_list,
        p_party_site_rec    => p_party_site,
        x_party_site_id     => l_party_site_id,
        x_party_site_number => l_party_site_number,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data    );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('IBE_ADDRESS_V2PVT.copy_pary_site:Expected error ');
    END IF;

    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('IBE_ADDRESS_V2PVT.copy_pary_site:Unexpected error ');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('IBE_ADDRESS_V2PVT.copy_pary_site:Done ');
     IBE_UTIL.debug('party_site_id = ' || x_party_site_id);
  END IF;

  x_party_site_id := l_party_site_id;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('IBE_ADDRESS_V2PVT.copy_pary_site:In the expected exception block ');
   END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

     for k in 1 .. x_msg_count loop
       lx_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                  p_encoded => 'F');

       IBE_UTIL.debug('Error msg: '||substr(lx_msg_data,1,240));
     end loop;


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('IBE_ADDRESS_V2PVT.copy_pary_site:In the unexpected exception block ');
   END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

     for k in 1 .. x_msg_count loop
       lx_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                  p_encoded => 'F');

       IBE_UTIL.debug('Error msg: '||substr(lx_msg_data,1,240));
     end loop;


   WHEN OTHERS THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('IBE_ADDRESS_V2PVT.copy_pary_site:In the others exception block ');
   END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');
     for k in 1 .. x_msg_count loop
       lx_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                  p_encoded => 'F');

       IBE_UTIL.debug('Error msg: '||substr(lx_msg_data,1,240));
     end loop;


END;


END IBE_ADDRESS_V2PVT;

/
