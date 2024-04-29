--------------------------------------------------------
--  DDL for Package Body HZ_ADDRESS_USAGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ADDRESS_USAGES_PUB" AS
/* $Header: ARHGNRSB.pls 120.4 2006/04/11 00:27:07 nsinghai noship $ */

PROCEDURE do_create_address_usages(
   p_address_usages_rec      IN              address_usages_rec_type,
   p_address_usage_dtls_tbl  IN              address_usage_dtls_tbl_type,
   x_usage_id                OUT  NOCOPY     NUMBER,
   x_return_status           OUT  NOCOPY     VARCHAR2) IS

  l_map_id            NUMBER;
  l_usage_id          NUMBER;
  l_usage_dtl_id      NUMBER;
  l_usage_row_id      VARCHAR2(50);
  x_usage_dtl_row_id  VARCHAR2(50);
  l_usage_code        VARCHAR2(30);
  l_geotype           VARCHAR2(360);

  i                 BINARY_INTEGER;
  l_error_code      VARCHAR2(30);
  x_status          VARCHAR2(30);
  l_temp            VARCHAR2(100);
  l_map_dtl_extsts  VARCHAR2(1);
  l_usg_country_found  VARCHAR2(1);
  p_index_name      VARCHAR2(30);

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_error_code := NULL;

   -- Standard start of API savepoint
   SAVEPOINT do_create_address_usages;

   -- Map Id is mandatory

   IF p_address_usages_rec.map_id IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_MAP_ID');
      -- The Map Id passed is NULL. Please use a valid Map Id to create a Address Usage.
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      BEGIN
        SELECT map_id
        INTO  l_map_id
        FROM  hz_geo_struct_map
        WHERE map_id = p_address_usages_rec.map_id;

      EXCEPTION WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_MAP_ID');
        -- The mapping record that you are trying to create address usage does not exist.
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

      END;
   END IF;

    -- Usage code is mandatory

   IF p_address_usages_rec.usage_code IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_USAGE_CODE');
      -- Please enter a valid usage.
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      BEGIN
        SELECT lookup_code
        INTO   l_usage_code
        FROM   ar_lookups
        WHERE  lookup_type = 'HZ_GEOGRAPHY_USAGE'
        AND    lookup_code = p_address_usages_rec.usage_code;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_USAGE_CODE');
        --  The Usage Code is invalid. Please pass a valid Usage Code
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END;
   END IF;

    IF p_address_usage_dtls_tbl.COUNT < 2 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_2_USAGE_DTL_MAND');
      -- Please enter two or more geography types for a usage.
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate that one of the geography_type passed is COUNTRY
    i := p_address_usage_dtls_tbl.first;
    LOOP
      IF p_address_usage_dtls_tbl(i).geography_type <> 'COUNTRY' THEN
        l_usg_country_found := 'N';
      ELSE
        l_usg_country_found := 'Y';
        EXIT;
      END IF;
      EXIT WHEN i = p_address_usage_dtls_tbl.LAST;
      i := p_address_usage_dtls_tbl.NEXT(i);
    END LOOP;

    IF l_usg_country_found <> 'Y' then
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GEO_TYPE_NOT_COUNTRY');
      -- Please enter a geography type COUNTRY
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Call table handler to insert row and make a
    -- call to create map packages


    BEGIN --insert row

      SELECT HZ_ADDRESS_USAGES_S.nextval
      INTO l_usage_id
      FROM dual;

      hz_address_usages_pkg.insert_row(
                                  l_usage_row_id,
                                  l_usage_id,
                                  p_address_usages_rec.map_id,
                                  p_address_usages_rec.usage_code,
                                  p_address_usages_rec.status_flag,
                                  1,
                                  p_address_usages_rec.created_by_module,
                                  p_address_usages_rec.application_id);
      END;

--dbms_output.put_line(' message : Usage Created');

      BEGIN
        i := p_address_usage_dtls_tbl.first;
        WHILE i IS NOT NULL LOOP

        IF p_address_usage_dtls_tbl(i).geography_type IS NULL THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GEOGRAPHY_TYPE_MAND');
           -- Please enter a valid geography type
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           BEGIN
             SELECT 'X'
             INTO  l_map_dtl_extsts
             FROM  hz_geo_struct_map_dtl
             WHERE map_id = p_address_usages_rec.map_id
             AND   geography_type = p_address_usage_dtls_tbl(i).geography_type;

           EXCEPTION WHEN NO_DATA_FOUND THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GEOTYPE_INVALID');
             -- Geography Type does not mapped with a location
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;

           END;
        END IF;

        -- The below variable is to display the geography type in case of unique error from pkg API
        l_geotype := p_address_usage_dtls_tbl(i).geography_type;

        SELECT HZ_ADDRESS_USAGES_S.nextval
        INTO l_usage_dtl_id
        FROM dual;

        hz_address_usage_dtls_pkg.insert_row(
                                  x_usage_dtl_row_id,
                                  l_usage_dtl_id,
                                  l_usage_id,
                                  p_address_usage_dtls_tbl(i).geography_type,
                                  1,
                                  p_address_usage_dtls_tbl(i).created_by_module,
                                  p_address_usage_dtls_tbl(i).application_id);
         i := p_address_usage_dtls_tbl.next(i);
        END LOOP;
      END; -- insert row

      x_usage_id := l_usage_id;

   EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO do_create_address_usages;
        x_return_status := FND_API.G_RET_STS_ERROR;
        HZ_UTILITY_V2PUB.find_index_name(p_index_name);
        IF p_index_name = 'HZ_ADDRESS_USAGES_U1' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_USAGE_ID');
          FND_MESSAGE.SET_TOKEN('P_USAGE_ID',l_usage_id);
          -- Usage ID already exists. Please use a unique ID
          FND_MSG_PUB.ADD;

        ELSIF p_index_name = 'HZ_ADDRESS_USAGES_U2' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_USAGE_ROW_EXISTS');
          FND_MESSAGE.SET_TOKEN('P_USAGE',p_address_usages_rec.usage_code);
          -- The mapping already exists for this usage. Please use another mapping.
          FND_MSG_PUB.ADD;

        ELSIF p_index_name = 'HZ_ADDRESS_USAGE_DTLS_U1' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_USAGE_DTL_ID');
          FND_MESSAGE.SET_TOKEN('P_USAGE_DTL_ID',l_usage_dtl_id);
          -- Usage detail ID already exists. Please use a unique ID.
          FND_MSG_PUB.ADD;

        ELSIF p_index_name = 'HZ_ADDRESS_USAGE_DTLS_U2' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_USAGE_GEOTYPE');
          FND_MESSAGE.SET_TOKEN('P_GEOTYPE',l_geotype);
          FND_MESSAGE.SET_TOKEN('P_USAGE',p_address_usages_rec.usage_code);
          -- This geography type is already mapped for this usage.
          FND_MSG_PUB.ADD;
        END IF;

END do_create_address_usages;

PROCEDURE create_address_usages(
   p_address_usages_rec      IN              address_usages_rec_type,
   p_address_usage_dtls_tbl  IN              address_usage_dtls_tbl_type,
   p_init_msg_list           IN              VARCHAR2 := FND_API.G_FALSE,
   x_usage_id                OUT    NOCOPY   NUMBER,
   x_return_status           OUT    NOCOPY   VARCHAR2,
   x_msg_count               OUT    NOCOPY   NUMBER,
   x_msg_data                OUT    NOCOPY   VARCHAR2) IS
   p_index_name  VARCHAR2(30);
   l_temp            VARCHAR2(1000);
   l_pkgname                 VARCHAR2(50);
   l_status                  VARCHAR2(30);

BEGIN

   -- Standard start of API savepoint
   SAVEPOINT create_address_usages;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Call to business logic.
   do_create_address_usages(
                            p_address_usages_rec,
                            p_address_usage_dtls_tbl,
                            x_usage_id,
                            x_return_status
                           );


   --  if validation failed at any point, then raise an exception to stop processing
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF p_address_usages_rec.status_flag = 'A' THEN
      --dbms_output.put_line('Before Gen pkg Create usage : map id :'|| p_address_usages_rec.map_id);
      BEGIN
         hz_gnr_gen_pkg.genpkg(p_address_usages_rec.map_id,l_pkgname,l_status);
         IF l_status = FND_API.G_RET_STS_ERROR THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_PKG_ERR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      EXCEPTION WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_INTERNAL_ERROR');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END;
      --dbms_output.put_line('After Gen pkg Create usage : map id :'|| p_address_usages_rec.map_id);
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
               p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data);

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_address_usages;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_address_usages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   WHEN OTHERS THEN
        ROLLBACK TO create_address_usages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END create_address_usages;

PROCEDURE update_address_usages
  (p_usage_id              IN             NUMBER,
   p_map_id                IN             NUMBER,
   p_usage_code            IN             VARCHAR2,
   p_status_flag           IN             VARCHAR2,
   p_init_msg_list         IN             VARCHAR2 := FND_API.G_FALSE,
   x_object_version_number IN OUT NOCOPY  NUMBER,
   x_return_status         OUT    NOCOPY  VARCHAR2,
   x_msg_count             OUT    NOCOPY  NUMBER,
   x_msg_data              OUT    NOCOPY  VARCHAR2
  ) IS

   l_map_id                NUMBER;
   l_usage_id              NUMBER;
   l_usage_row_id          VARCHAR2(50);
   l_object_version_number NUMBER;
   l_pkgname               VARCHAR2(50);
   l_status                VARCHAR2(30);
   l_count                 NUMBER;
   pkg_name                VARCHAR2(1000);
   l_drp_sql               VARCHAR2(1000);

   db_object_version_number hz_address_usages.object_version_number%TYPE;
   db_map_id                hz_address_usages.map_id%TYPE;
   db_usage_code            hz_address_usages.usage_code%TYPE;
   db_status_flag           hz_address_usages.status_flag%TYPE;
   db_created_by            hz_address_usages.created_by%TYPE;
   db_creation_date         hz_address_usages.creation_date%TYPE;
   db_last_updated_by       hz_address_usages.last_updated_by%TYPE;
   db_last_update_date      hz_address_usages.last_update_date%TYPE;
   db_last_update_login     hz_address_usages.last_update_login%TYPE;
   db_created_by_module     hz_address_usages.created_by_module%TYPE;
   db_application_id        hz_address_usages.application_id%TYPE;

BEGIN

   -- Standard start of API savepoint
   SAVEPOINT update_address_usages;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_usage_id IS NOT NULL THEN

      -- Check the passed usage_id is valid or not
      BEGIN
         SELECT rowid, usage_id, object_version_number, map_id,
                usage_code, status_flag, created_by, creation_date, last_updated_by,
               last_update_date, last_update_login, created_by_module, application_id
         INTO  l_usage_row_id, l_usage_id, db_object_version_number, db_map_id,
               db_usage_code, db_status_flag, db_created_by, db_creation_date, db_last_updated_by,
               db_last_update_date, db_last_update_login, db_created_by_module, db_application_id
         FROM  hz_address_usages
         WHERE usage_id = p_usage_id;
      EXCEPTION WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_USAGE_ID');
         -- Usage record does not exists for updation
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END;
   ELSE

      IF p_map_id IS NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_MAP_ID');
         -- The Map Id passed is NULL. Please use a valid Map Id to create an Address Usage.
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_usage_code IS NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_USAGE_CODE');
         -- The usage code passed is NULL. Please use a valid usage code.
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Check the valid combination for map_id and usage_code
      BEGIN
         SELECT rowid, usage_id, object_version_number, map_id,
                usage_code, status_flag, created_by, creation_date, last_updated_by,
               last_update_date, last_update_login, created_by_module, application_id
         INTO  l_usage_row_id, l_usage_id, db_object_version_number, db_map_id,
               db_usage_code, db_status_flag, db_created_by, db_creation_date, db_last_updated_by,
               db_last_update_date, db_last_update_login, db_created_by_module, db_application_id
         FROM  hz_address_usages
         WHERE map_id = p_map_id
         AND   usage_code = p_usage_code;
      EXCEPTION WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_USAGE_ID');
         -- Usage record does not exists for updation
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END;

   END IF;

   IF db_object_version_number <> x_object_version_number THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
       FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ADDRESS_USAGES');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   hz_address_usages_pkg.Lock_Row (
       x_rowid                     => l_usage_row_id,
       x_usage_id                  => l_usage_id,
       x_map_id                    => db_map_id,
       x_usage_code                => db_usage_code,
       x_status_flag               => db_status_flag,
       x_created_by                => db_created_by,
       x_creation_date             => db_creation_date,
       x_last_updated_by           => db_last_updated_by,
       x_last_update_date          => db_last_update_date,
       x_last_update_login         => db_last_update_login,
       x_object_version_number     => x_object_version_number,
       x_created_by_module         => db_created_by_module,
       x_application_id            => db_application_id);

--dbms_output.put_line(' message update  : l_usage_row_id '|| l_usage_row_id);
   l_object_version_number := x_object_version_number +1;

   hz_address_usages_pkg.Update_Row (
                   x_rowid                    => l_usage_row_id,
                   x_usage_id                 => l_usage_id,
                   x_map_id                   => db_map_id,
                   x_usage_code               => db_usage_code,
                   x_status_flag              => p_status_flag,
                   x_object_version_number    => l_object_version_number,
                   x_created_by_module        => db_created_by_module,
                   x_application_id           => db_application_id);


--dbms_output.put_line(' message after update :');
   x_object_version_number := l_object_version_number;

   SELECT count(*)
   INTO   l_count
   FROM   Hz_address_usages usg, Hz_address_usage_dtls dtl
   WHERE  usg.map_id = db_map_id
   AND    usg.status_flag = 'A'
   AND    dtl.usage_id = usg.usage_id;

   -- If count is 0, that means there is no active usage details for this map_id
   IF l_count > 0 THEN
     --dbms_output.put_line('Before Gen pkg Create usage : map id :'|| p_address_usages_rec.map_id);
     BEGIN
        hz_gnr_gen_pkg.genpkg(db_map_id,l_pkgname,l_status);
        IF l_status = FND_API.G_RET_STS_ERROR THEN
           FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_PKG_ERR');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     EXCEPTION WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_INTERNAL_ERROR');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
     END;
     --dbms_output.put_line('After Gen pkg Create usage : map id :'|| p_address_usages_rec.map_id);
   ELSE
     BEGIN
       pkg_name := 'HZ_GNR_MAP' ||to_char(db_map_id);
       l_drp_sql := 'Drop Package Body '|| pkg_name;
       EXECUTE IMMEDIATE l_drp_sql;

       l_drp_sql := 'Drop Package '|| pkg_name;

       EXECUTE IMMEDIATE l_drp_sql;
     EXCEPTION when OTHERS then
       NULL;
     END;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
               p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data);

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_address_usages;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_address_usages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   WHEN OTHERS THEN
        ROLLBACK TO update_address_usages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END update_address_usages;

PROCEDURE create_address_usage_dtls(
   p_usage_id                IN              NUMBER,
   p_address_usage_dtls_tbl  IN              address_usage_dtls_tbl_type,
   x_usage_dtl_id            OUT  NOCOPY     NUMBER,
   p_init_msg_list           IN              VARCHAR2 := FND_API.G_FALSE,
   x_return_status           OUT    NOCOPY   VARCHAR2,
   x_msg_count               OUT    NOCOPY   NUMBER,
   x_msg_data                OUT    NOCOPY   VARCHAR2) IS

  p_index_name      VARCHAR2(30);
  l_temp            VARCHAR2(1000);

  l_map_id            NUMBER;
  l_usage_dtl_id      NUMBER;
  x_usage_dtl_row_id  VARCHAR2(50);
  l_usage_code        VARCHAR2(50);
  l_geotype           VARCHAR2(360);
  l_status_flag       VARCHAR2(1);

  i                 BINARY_INTEGER;
  l_error_code      VARCHAR2(30);
  x_status          VARCHAR2(30);
  l_map_dtl_extsts  VARCHAR2(1);
  l_usage_extsts    VARCHAR2(1);
  l_pkgname         VARCHAR2(50);
  l_status          VARCHAR2(30);

BEGIN

   -- Standard start of API savepoint
   SAVEPOINT create_address_usage_dtls;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF  p_usage_id IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_USAGE_ID');
      -- Usage Id cannot be null. Please enter a valid Usage Id
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      BEGIN
        SELECT map_id, usage_code, status_flag
        INTO  l_map_id, l_usage_code, l_status_flag
        FROM  hz_address_usages
        WHERE usage_id = p_usage_id;

      EXCEPTION WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_USAGE_ID');
        -- Usage Id passed is not valid. Please enter a valid Usage Id.
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

      END;
   END IF;

   -- Call to business logic.

--dbms_output.put_line(' message : Usage Created');

   BEGIN
        i := p_address_usage_dtls_tbl.first;
        WHILE i IS NOT NULL LOOP

        IF p_address_usage_dtls_tbl(i).geography_type IS NULL THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GEOGRAPHY_TYPE_MAND');
           -- Please enter a valid geography type
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           BEGIN
             SELECT 'X'
             INTO  l_map_dtl_extsts
             FROM  hz_geo_struct_map_dtl
             WHERE map_id = l_map_id
             AND   geography_type = p_address_usage_dtls_tbl(i).geography_type;

           EXCEPTION WHEN NO_DATA_FOUND THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GEOTYPE_INVALID');
             -- Geography Type does not mapped with a location
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;

           END;
        END IF;

        -- The below variable is to display the geography type in case of unique error from pkg API
        l_geotype := p_address_usage_dtls_tbl(i).geography_type;

        SELECT HZ_ADDRESS_USAGES_S.nextval
        INTO l_usage_dtl_id
        FROM dual;

        hz_address_usage_dtls_pkg.insert_row(
                                  x_usage_dtl_row_id,
                                  l_usage_dtl_id,
                                  p_usage_id,
                                  p_address_usage_dtls_tbl(i).geography_type,
                                  1,
                                  p_address_usage_dtls_tbl(i).created_by_module,
                                  p_address_usage_dtls_tbl(i).application_id);
         i := p_address_usage_dtls_tbl.next(i);
        END LOOP;
      END; -- insert row

      x_usage_dtl_id := l_usage_dtl_id;

   --  if validation failed at any point, then raise an exception to stop processing
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF l_status_flag = 'A' THEN
      --dbms_output.put_line('Before Gen pkg Create usage dtls : map id :'|| l_map_id);
      BEGIN
         hz_gnr_gen_pkg.genpkg(l_map_id,l_pkgname,l_status);
         IF l_status = FND_API.G_RET_STS_ERROR THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_PKG_ERR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      EXCEPTION WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_INTERNAL_ERROR');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END;
      --dbms_output.put_line('After Gen pkg Create usage dtls : map id :'|| l_map_id);
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
               p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data);

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_address_usage_dtls;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_address_usage_dtls;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO create_address_usage_dtls;
        x_return_status := FND_API.G_RET_STS_ERROR;
        HZ_UTILITY_V2PUB.find_index_name(p_index_name);
        IF p_index_name = 'HZ_ADDRESS_USAGE_DTLS_U1' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_USAGE_DTL_ID');
          -- Usage detail ID already exists. Please use a unique ID.
          FND_MESSAGE.SET_TOKEN('P_USAGE_DTL_ID',l_usage_dtl_id);
          FND_MSG_PUB.ADD;
        ELSIF p_index_name = 'HZ_ADDRESS_USAGE_DTLS_U2' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_USAGE_GEOTYPE');
          FND_MESSAGE.SET_TOKEN('P_GEOTYPE',l_geotype);
          FND_MESSAGE.SET_TOKEN('P_USAGE',l_usage_code);
          -- This geography type is already mapped for this usage.
          FND_MSG_PUB.ADD;
        END IF;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);
   WHEN OTHERS THEN
        ROLLBACK TO create_address_usage_dtls;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END create_address_usage_dtls;

PROCEDURE delete_address_usages(
                   p_usage_id                IN         NUMBER,
                   p_address_usage_dtls_tbl  IN         address_usage_dtls_tbl_type,
                   p_init_msg_list           IN         VARCHAR2 := FND_API.G_FALSE,
                   x_return_status           OUT NOCOPY VARCHAR2,
                   x_msg_count               OUT NOCOPY NUMBER,
                   x_msg_data                OUT NOCOPY VARCHAR2
                   ) IS

  l_map_id          NUMBER;
  l_usage_dtl_id    NUMBER;
  l_usage_code      VARCHAR2(50);
  l_count           NUMBER;
  l_pkgname         VARCHAR2(50);
  l_status          VARCHAR2(30);
  i                 NUMBER;
  l_status_flag     VARCHAR2(1);
  pkg_name          VARCHAR2(1000);
  l_drp_sql         VARCHAR2(1000);
  l_last_usg_dtl_id NUMBER;

  CURSOR c_address_usage_dtls IS
  SELECT usage_dtl_id
  FROM   hz_address_usage_dtls
  WHERE  usage_id = p_usage_id;

BEGIN

   -- Standard start of API savepoint
   SAVEPOINT delete_address_usages;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_usage_id IS NULL THEN

       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_USAGE_ID');
       -- Usage Id cannot be null. Please enter a valid Usage Id
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;

   ELSE

      BEGIN
        SELECT map_id, usage_code, status_flag
        INTO  l_map_id, l_usage_code, l_status_flag
        FROM  hz_address_usages
        WHERE usage_id = p_usage_id;

      EXCEPTION WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_USAGE_ID');
        -- Usage Id passed is not valid. Please enter a valid Usage Id.
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END;

      IF p_address_usage_dtls_tbl.COUNT > 0 THEN

         i:= p_address_usage_dtls_tbl.FIRST;
         LOOP
            IF p_address_usage_dtls_tbl(i).geography_type IS NOT NULL then
               BEGIN
                 SELECT usage_dtl_id
                 INTO  l_usage_dtl_id
                 FROM  hz_address_usage_dtls
                 WHERE usage_id = p_usage_id
                 AND   geography_type = p_address_usage_dtls_tbl(i).geography_type;

               EXCEPTION WHEN NO_DATA_FOUND THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_USAGE_GEOTYPE_INVALID');
                 FND_MESSAGE.SET_TOKEN('P_GEOTYPE',p_address_usage_dtls_tbl(i).geography_type);
                 FND_MESSAGE.SET_TOKEN('P_USAGE',l_usage_code);
                 -- Geography type does not exists for the given usage
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;
               END;

               BEGIN
                 SELECT count(*)
                 INTO  l_count
                 FROM  hz_address_usage_dtls
                 WHERE usage_id = p_usage_id;

                 IF l_count < 3 then

                   BEGIN
                      SELECT usage_dtl_id
                      INTO  l_last_usg_dtl_id
                      FROM  hz_address_usage_dtls
                      WHERE usage_id = p_usage_id
                      AND   usage_dtl_id <> l_usage_dtl_id;

                      -- delete the other usage detail also because it is only
                      -- one left can can not exist without any other usage detail
                      -- Bug 5096570 (Nishant 10-Apr-2006)
                      hz_address_usage_dtls_pkg.delete_row(l_last_usg_dtl_id);
                      hz_address_usages_pkg.delete_row(p_usage_id);
                      -- Set i to LAST, so that it does not check any other geo type
                      -- as there is no use (all are deleted)
                      i := p_address_usage_dtls_tbl.LAST;
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                      -- it means only 1 usage detail was there. Delete the usage only
                      -- usage detail will be deleted below
                      /*
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_2_USAGE_DTL_MAND');
                      -- At least two geography types are required for a usage
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_ERROR;
                      */
                      hz_address_usages_pkg.delete_row(p_usage_id);
                      i := p_address_usage_dtls_tbl.LAST;
                    END;

                 END IF;
               END;

               hz_address_usage_dtls_pkg.delete_row(l_usage_dtl_id);
            END IF;
            EXIT WHEN i = p_address_usage_dtls_tbl.LAST;
            i := p_address_usage_dtls_tbl.NEXT(i);
         END LOOP;
      ELSE
         FOR i IN c_address_usage_dtls
         LOOP
            hz_address_usage_dtls_pkg.delete_row(i.usage_dtl_id);
         EXIT WHEN c_address_usage_dtls%NOTFOUND;
         END LOOP;
         hz_address_usages_pkg.delete_row(p_usage_id);
      END IF;

      SELECT count(*)
      INTO   l_count
      FROM   Hz_address_usages usg, Hz_address_usage_dtls dtl
      WHERE  usg.map_id = l_map_id
      AND    usg.status_flag = 'A'
      AND    dtl.usage_id = usg.usage_id;

      -- If count is 0, that means there is no active usage details for this map_id
      -- In this case we can drop the package
      IF l_count < 1 THEN
         BEGIN
           pkg_name := 'HZ_GNR_MAP' ||to_char(l_map_id);
           l_drp_sql := 'Drop Package Body '|| pkg_name;
           EXECUTE IMMEDIATE l_drp_sql;

           l_drp_sql := 'Drop Package '|| pkg_name;

           EXECUTE IMMEDIATE l_drp_sql;
         EXCEPTION when OTHERS then
           NULL;
         END;
      ELSE
         -- Checking whether the usage is active or not.
         IF l_status_flag = 'A' THEN
           --dbms_output.put_line('Before Gen pkg Delete usage : map id :'|| l_map_id);
           BEGIN
              hz_gnr_gen_pkg.genpkg(l_map_id,l_pkgname,l_status);
              IF l_status = FND_API.G_RET_STS_ERROR THEN
                 FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_PKG_ERR');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           EXCEPTION WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_INTERNAL_ERROR');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END;
           --dbms_output.put_line('After Gen pkg Delete usage : map id :'|| l_map_id);
         END IF;
      END IF;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
               p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data);

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_address_usages;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_address_usages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   WHEN OTHERS THEN
     ROLLBACK TO delete_address_usages;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count        => x_msg_count,
                              p_data        => x_msg_data);

 END delete_address_usages;

END HZ_ADDRESS_USAGES_PUB;

/
