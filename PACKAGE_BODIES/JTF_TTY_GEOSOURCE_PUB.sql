--------------------------------------------------------
--  DDL for Package Body JTF_TTY_GEOSOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_GEOSOURCE_PUB" AS
/* $Header: jtftgspb.pls 120.0 2005/06/02 18:21:15 appldev ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_GEOSOURCE_PUB
--    ---------------------------------------------------
--    PURPOSE
--      This package contains APIs for populating geographies source
--      table for Territory Manager
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      08/11/03    SGKUMAR     Created
--      06/01/04    SGKUMAR     changed create API for performance fix
--
--    End of Comments
--
/***********************************************************
* Creates a Geography
* Non Required parameters: state code, province code, county
*                          code, city and postal code
************************************************************/
PROCEDURE create_geo(
                     p_geo_type                   IN   VARCHAR2,
                     p_geo_name                   IN   VARCHAR2,
                     p_geo_code                   IN   VARCHAR2,
                     p_country_code               IN   VARCHAR2,
                     p_state_code                 IN   VARCHAR2 default null,
                     p_province_code              IN   VARCHAR2 default null,
                     p_county_code                IN   VARCHAR2 default null,
                     p_city_code                  IN   VARCHAR2 default null,
                     p_postal_code                IN   VARCHAR2 default null,
	             x_return_status              IN OUT  NOCOPY VARCHAR2,
	             x_error_msg                  IN OUT  NOCOPY VARCHAR2)
AS
   l_api_name CONSTANT VARCHAR2(30) :=  'CREATE_GEO';
   p_parent_exists_flag VARCHAR2(1) DEFAULT 'Y';
   p_exists_flag VARCHAR2(1) DEFAULT 'Y';
   p_geo_type_exists_flag VARCHAR2(1) DEFAULT 'Y';
   p_user_id NUMBER;
   p_date    DATE;
BEGIN
    p_user_id := fnd_global.user_id;
    p_date    := sysdate;
    BEGIN
      SELECT 'Y'
      into    p_geo_type_exists_flag
      FROM    fnd_lookups
      WHERE   lookup_type = 'JTF_TTY_GEO_TYPE'
      AND     lookup_code = p_geo_type
      AND     ROWNUM < 2;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_geo_type_exists_flag := 'N';
    END;

-- do validations
   x_return_status := fnd_api.g_ret_sts_success;
   IF(p_geo_type is null OR p_geo_name is null
     OR p_geo_code is null OR p_country_code is null) THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('JTF', 'JTF_TTY_NOT_NULL');
    x_error_msg := fnd_message.Get();
   -- check if parent geo is there
   elsif (p_geo_type_exists_flag = 'N') THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_TYPE_INVALID');
       fnd_message.set_token('p_geo_type',p_geo_type);
       x_error_msg := fnd_message.Get();
   elsif (p_geo_type = 'STATE') THEN
    BEGIN
      SELECT 'Y'
      into    p_parent_exists_flag
      FROM    jtf_tty_geographies
      WHERE   geo_type = 'COUNTRY'
      AND     geo_code = p_country_code
      AND     ROWNUM < 2;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_parent_exists_flag := 'N';
    END;
    if (p_parent_exists_flag = 'N') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_PARENT_NOTEXIST');
       fnd_message.set_token('p_geo_code',p_geo_code);
       fnd_message.set_token('p_geo_type',p_geo_type);
       fnd_message.set_token('p_country_code',p_country_code);
       fnd_message.set_token('p_geo_name',p_geo_name);
       x_error_msg := fnd_message.Get();
    end if;
    BEGIN
      SELECT 'Y'
      into    p_exists_flag
      FROM    jtf_tty_geographies
      WHERE   geo_type = 'STATE'
      AND     country_code = p_country_code
      AND     state_code = p_state_code
      AND     ROWNUM < 2;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_exists_flag := 'N';
    END;
    if (p_exists_flag = 'Y') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_UNIQUE');
       -- fnd_message.set_token('p_geo_code',p_geo_code);
       -- fnd_message.set_token('p_geo_type',p_geo_type);
       -- fnd_message.set_token('p_country_code',p_country_code);
       -- fnd_message.set_token('p_geo_name',p_geo_name);
       x_error_msg := fnd_message.Get();
    end if;
   elsif (p_geo_type = 'PROVINCE') THEN
    BEGIN
      SELECT 'Y'
      into    p_parent_exists_flag
      FROM    jtf_tty_geographies
      WHERE   geo_type = 'COUNTRY'
      AND     geo_code = p_country_code
      AND     ROWNUM < 2;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_parent_exists_flag := 'N';
    END;
    if (p_parent_exists_flag = 'N') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_PARENT_NOTEXIST');
       fnd_message.set_token('p_geo_code',p_geo_code);
       fnd_message.set_token('p_geo_type',p_geo_type);
       fnd_message.set_token('p_country_code',p_country_code);
       fnd_message.set_token('p_geo_name',p_geo_name);
       x_error_msg := fnd_message.Get();
    end if;
    BEGIN
      SELECT 'Y'
      into    p_exists_flag
      FROM    jtf_tty_geographies
      WHERE   geo_type = 'PROVINCE'
      AND     country_code = p_country_code
      AND     province_code = p_province_code
      AND     ROWNUM < 2;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_exists_flag := 'N';
    END;
    if (p_exists_flag = 'Y') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_UNIQUE');
       -- fnd_message.set_token('p_geo_code',p_geo_code);
       -- fnd_message.set_token('p_geo_type',p_geo_type);
       -- fnd_message.set_token('p_country_code',p_country_code);
       -- fnd_message.set_token('p_geo_name',p_geo_name);
       x_error_msg := fnd_message.Get();
    end if;
   elsif (p_geo_type = 'COUNTY') THEN
    BEGIN
      IF (p_state_code is not NULL) THEN
       SELECT 'Y'
       into    p_parent_exists_flag
       FROM    jtf_tty_geographies
       WHERE   geo_type = 'STATE'
       AND   country_code = p_country_code
       AND     state_code = p_state_code
       AND     ROWNUM < 2;
      ELSE
       SELECT 'Y'
       into    p_parent_exists_flag
       FROM    jtf_tty_geographies
       WHERE   geo_type = 'PROVINCE'
       AND   country_code = p_country_code
       AND    province_code = p_province_code
       AND     ROWNUM < 2;
     END IF;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_parent_exists_flag := 'N';
    END;
    if (p_parent_exists_flag = 'N') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_PARENT_NOTEXIST');
       fnd_message.set_token('p_geo_code',p_geo_code);
       fnd_message.set_token('p_geo_type',p_geo_type);
       fnd_message.set_token('p_country_code',p_country_code);
       fnd_message.set_token('p_geo_name',p_geo_name);
       x_error_msg := fnd_message.Get();
    end if;
   elsif (p_geo_type = 'CITY') THEN
    BEGIN
      SELECT 'Y'
      into    p_parent_exists_flag
      FROM    jtf_tty_geographies
      WHERE   ((geo_type = 'STATE' and (p_state_code is not null and p_county_code is null))
               or
               (geo_type = 'PROVINCE' and (p_province_code is not null and p_county_code is null))
               or
               (geo_type = 'COUNTY' and p_county_code is not null))
      AND   country_code = p_country_code
      AND    ((state_code = p_state_code  and p_state_code is not null)
        OR
            (province_code = p_province_code  and p_province_code is not null))
      AND   (p_county_code is null or county_code = p_county_code)
      AND     ROWNUM < 2;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_parent_exists_flag := 'N';
    END;
    if (p_parent_exists_flag = 'N') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_PARENT_NOTEXIST');
       fnd_message.set_token('p_geo_code',p_geo_code);
       fnd_message.set_token('p_geo_type',p_geo_type);
       fnd_message.set_token('p_country_code',p_country_code);
       fnd_message.set_token('p_geo_name',p_geo_name);
       x_error_msg := fnd_message.Get();
    end if;
   elsif (p_geo_type = 'POSTAL_CODE') THEN
    BEGIN
      SELECT 'Y'
      into    p_parent_exists_flag
      FROM    jtf_tty_geographies
      WHERE   (
            (p_city_code is not null and geo_type = 'CITY')
            OR
            ((p_city_code is null and p_county_code is not null) and geo_type = 'COUNTY')
            OR
            ((p_city_code is null and p_county_code is null and p_state_code is not null) and geo_type = 'STATE')
            OR
            ((p_city_code is null and p_county_code is null and p_province_code is not null) and geo_type = 'PROVINCE')
             )
      AND     country_code = p_country_code
      AND     ((state_code = p_state_code  and p_state_code is not null)
              OR
              (province_code = p_province_code and p_province_code is not null))
      AND     (p_county_code is null or county_code = p_county_code)
      AND     (p_city_code is null or city_code = p_city_code)
      AND     ROWNUM < 2;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_parent_exists_flag := 'N';
    END;
    if (p_parent_exists_flag = 'N') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_PARENT_NOTEXIST');
       fnd_message.set_token('p_geo_code',p_geo_code);
       fnd_message.set_token('p_geo_type',p_geo_type);
       fnd_message.set_token('p_country_code',p_country_code);
       fnd_message.set_token('p_geo_name',p_geo_name);
       x_error_msg := fnd_message.Get();
    end if;
   END IF;
   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   -- Create the geography, validations done
   INSERT INTO jtf_tty_geographies(
            geo_id,
            geo_name,
            geo_type,
            geo_code,
            country_code,
            state_code,
            province_code,
            county_code,
            city_code,
            postal_code,
            object_version_number,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date)
   VALUES(
           jtf_tty_geographies_s.nextval,
           p_geo_name,
           p_geo_type,
           p_geo_code,
           p_country_code,
           decode(p_geo_type, 'STATE', p_geo_code,  p_state_code),
           decode(p_geo_type, 'PROVINCE', p_geo_code, p_province_code),
           decode(p_geo_type, 'COUNTY', p_geo_code, p_county_code),
           decode(p_geo_type, 'CITY', p_geo_code, p_city_code),
           decode(p_geo_type, 'POSTAL_CODE', p_geo_code, p_postal_code),
           1,
           p_user_id,
           p_date,
           p_user_id,
           p_date);
   COMMIT;
EXCEPTION

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN OTHERS THEN
      fnd_message.set_name('JTF', 'JTF_TTY_GEO_API_OTHERS');
      fnd_message.set_token('P_SQLCODE', SQLCODE);
      fnd_message.set_token('P_SQLERRM', SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      x_error_msg := fnd_message.Get();
      -- FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

END create_geo;

/***********************************************************
* Updates a Geography
* Non Required parameters: state code, province code, county
*                          code, city and postal code
************************************************************/
PROCEDURE update_geo(
                     p_geo_id                     IN   VARCHAR2,
                     p_geo_name                   IN   VARCHAR2,
                     x_return_status              IN OUT  NOCOPY VARCHAR2,
                     x_error_msg                  IN OUT  NOCOPY VARCHAR2)
AS
   l_api_name CONSTANT VARCHAR2(30) :=  'UPDATE_GEO';
   p_exists_flag VARCHAR2(1) DEFAULT 'Y';
   p_user_id NUMBER;
   p_date    DATE;
BEGIN
    p_user_id := fnd_global.user_id;
    p_date    := sysdate;

-- do validations
   x_return_status := fnd_api.g_ret_sts_success;
   IF (p_geo_id is null OR p_geo_name is null) THEN
       x_return_status := fnd_api.g_ret_sts_error;
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_UPDATE_NOT_ENOUGHVALUES');
       x_error_msg := fnd_message.Get();
   END IF;
   BEGIN
      SELECT 'Y'
      into    p_exists_flag
      FROM    jtf_tty_geographies
      WHERE   geo_id = p_geo_id;
   EXCEPTION
         WHEN NO_DATA_FOUND THEN
           p_exists_flag := 'N';
   END;
   IF (p_exists_flag = 'N') THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEOID_NOTEXIST');
       fnd_message.set_token('p_geo_id',p_geo_id);
       fnd_message.set_token('p_action_type','updated');
       x_error_msg := fnd_message.Get();
   END IF;
   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   -- passed all validations, now perform update operation
   UPDATE jtf_tty_geographies
   SET    geo_name = p_geo_name,
          last_updated_by = p_user_id,
          last_update_date = p_date
   WHERE  geo_id   = p_geo_id;
   COMMIT;
EXCEPTION

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN OTHERS THEN
      fnd_message.set_name('JTF', 'JTF_TTY_GEO_API_OTHERS');
      fnd_message.set_token('P_SQLCODE', SQLCODE);
      fnd_message.set_token('P_SQLERRM', SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      x_error_msg := fnd_message.Get();
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END update_geo;

/***********************************************************
* Deletes a Geography
* Non Required parameters: state code, province code, county
*                          code, city and postal code
************************************************************/
PROCEDURE delete_geo(
                     p_geo_type                   IN   VARCHAR2,
                     p_geo_code                   IN   VARCHAR2,
                     p_country_code               IN   VARCHAR2,
                     p_state_code                 IN   VARCHAR2 default null,
                     p_province_code              IN   VARCHAR2 default null,
                     p_county_code                IN   VARCHAR2 default null,
                     p_city_code                  IN   VARCHAR2 default null,
                     p_postal_code                IN   VARCHAR2 default null,
                     p_delete_cascade_flag        IN   VARCHAR2 default 'N',
	             x_return_status              IN OUT  NOCOPY VARCHAR2,
	             x_error_msg                  IN OUT  NOCOPY VARCHAR2)
AS
   l_api_name CONSTANT VARCHAR2(30) :=  'DELETE_GEO';
   p_child_exists_flag VARCHAR2(1) DEFAULT 'Y';
   p_parent_exists_flag VARCHAR2(1) DEFAULT 'Y';
   p_geo_type_exists_flag VARCHAR2(1) DEFAULT 'Y';
   p_exists_flag VARCHAR2(1) DEFAULT 'Y';
   p_user_id NUMBER;
   p_date    DATE;
BEGIN
    p_user_id := fnd_global.user_id;
    p_date    := sysdate;
    BEGIN
     SELECT 'Y'
     INTO p_exists_flag
     FROM jtf_tty_geographies
     WHERE country_code = p_country_code
     AND   geo_code = p_geo_code
     AND   geo_type = p_geo_type
     AND   (p_state_code is null or state_code = p_state_code)
     AND   (p_province_code is null or province_code = p_province_code)
     AND   (p_county_code is null or county_code = p_county_code)
     AND   (p_city_code is null or city_code = p_city_code)
     AND   (p_postal_code is null or postal_code = p_postal_code)
     AND ROWNUM < 2;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
         p_exists_flag := 'N';
   END;
   BEGIN
      SELECT 'Y'
      into    p_geo_type_exists_flag
      FROM    fnd_lookups
      WHERE   lookup_type = 'JTF_TTY_GEO_TYPE'
      AND     lookup_code = p_geo_type
      AND     ROWNUM < 2;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_geo_type_exists_flag := 'N';
   END;

-- do validations
   x_return_status := fnd_api.g_ret_sts_success;
   IF(p_geo_type is null
     OR p_geo_code is null OR p_country_code is null) THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('JTF', 'JTF_TTY_NOT_NULL');
    x_error_msg := fnd_message.Get();
   elsif(p_exists_flag = 'N') THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('JTF', 'JTF_TTY_GEO_NOTEXIST');
    x_error_msg := fnd_message.Get();
   -- check if parent geo is there
   elsif (p_geo_type_exists_flag = 'N') THEN
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_TYPE_INVALID');
       fnd_message.set_token('p_geo_type',p_geo_type);
       x_error_msg := fnd_message.Get();
   elsif (p_geo_type = 'COUNTRY') THEN
    if (p_delete_cascade_flag = 'N') THEN
     BEGIN
      SELECT 'Y'
      into    p_child_exists_flag
      FROM    jtf_tty_geographies
      WHERE   geo_type <> 'COUNTRY'
      AND     country_code = p_country_code
      AND     ROWNUM < 2;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_child_exists_flag := 'N';
     END;
     if (p_child_exists_flag = 'Y') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_CHILDEXIST');
       x_error_msg := fnd_message.Get();
     end if;
    end if;
   elsif (p_geo_type = 'STATE') THEN
    if (p_delete_cascade_flag = 'N') THEN
     BEGIN
      SELECT 'Y'
      into    p_child_exists_flag
      FROM    jtf_tty_geographies
      WHERE   (geo_type = 'COUNTY'
               or geo_type = 'CITY'
               or geo_type = 'POSTAL_CODE')
      AND     country_code = p_country_code
      AND     state_code = p_geo_code
      AND     ROWNUM < 2;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_child_exists_flag := 'N';
     END;
     if (p_child_exists_flag = 'Y') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_CHILDEXIST');
       x_error_msg := fnd_message.Get();
     end if;
    end if;
   elsif (p_geo_type = 'PROVINCE') THEN
    if (p_delete_cascade_flag = 'N') THEN
     BEGIN
      SELECT 'Y'
      into    p_child_exists_flag
      FROM    jtf_tty_geographies
      WHERE   (geo_type = 'COUNTY'
               or geo_type = 'CITY'
               or geo_type = 'POSTAL_CODE')
      AND     country_code = p_country_code
      AND     province_code = p_geo_code
      AND     ROWNUM < 2;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_child_exists_flag := 'N';
     END;
     if (p_child_exists_flag = 'Y') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_CHILDEXIST');
       x_error_msg := fnd_message.Get();
     end if;
    end if;
   elsif (p_geo_type = 'COUNTY') THEN
    if (p_delete_cascade_flag = 'N') THEN
     BEGIN
      SELECT 'Y'
      into    p_child_exists_flag
      FROM    jtf_tty_geographies
      WHERE   (geo_type = 'CITY' or geo_type = 'POSTAL_CODE')
      AND     country_code = p_country_code
      AND     ((p_province_code is not null or province_code = p_province_code)
               OR
               (p_state_code is not null or state_code = p_state_code))
      AND     county_code = p_geo_code
      AND     ROWNUM < 2;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_child_exists_flag := 'N';
     END;
     if (p_child_exists_flag = 'Y') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_CHILDEXIST');
       x_error_msg := fnd_message.Get();
     end if;
    end if;
   elsif (p_geo_type = 'CITY') THEN
    if (p_delete_cascade_flag = 'N') THEN
     BEGIN
      SELECT 'Y'
      into    p_child_exists_flag
      FROM    jtf_tty_geographies
      WHERE   geo_type = 'POSTAL_CODE'
      AND     country_code = p_country_code
      AND     ((p_province_code is not null or province_code = p_province_code)
               OR
               (p_state_code is not null or state_code = p_state_code))
      AND     (p_county_code is null or county_code = p_county_code)
      AND     city_code = p_city_code
      AND     ROWNUM < 2;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_child_exists_flag := 'N';
     END;
     if (p_child_exists_flag = 'Y') then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('JTF', 'JTF_TTY_GEO_CHILDEXIST');
       x_error_msg := fnd_message.Get();
     end if;
    end if;
   elsif (p_geo_type = 'POSTAL_CODE') THEN
    null;
   END IF;
   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   -- delete the  geography, validations done
   IF (p_geo_type = 'STATE') THEN
     if (p_delete_cascade_flag = 'Y') THEN
       DELETE from jtf_tty_geographies
       WHERE state_code = p_geo_code
       AND   country_code = p_country_code;
     else
       DELETE from jtf_tty_geographies
       WHERE state_code = p_geo_code
       AND   geo_type = 'STATE'
       AND   country_code = p_country_code;
     end if;
   END IF;

   COMMIT;
EXCEPTION

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN OTHERS THEN
      fnd_message.set_name('JTF', 'JTF_TTY_GEO_API_OTHERS');
      fnd_message.set_token('P_SQLCODE', SQLCODE);
      fnd_message.set_token('P_SQLERRM', SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      x_error_msg := fnd_message.Get();
      -- FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

END delete_geo;

END JTF_TTY_GEOSOURCE_PUB;

/
