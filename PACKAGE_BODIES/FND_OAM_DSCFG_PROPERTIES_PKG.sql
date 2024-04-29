--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCFG_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCFG_PROPERTIES_PKG" as
/* $Header: AFOAMDSCPROPB.pls 120.2 2005/12/19 09:42 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(30) := 'DSCFG_PROPERTIES_PKG.';

   --stateless, only contains a table handler to insert new properties

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_datatype            IN VARCHAR2,
                          p_canonical_value     IN VARCHAR2,
                          x_property_id         OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_PROPERTY';

      l_property_id             NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --make sure a configuration instance is initialized, we don't need it but
      --we need this as a security harness check.
      IF NOT FND_OAM_DSCFG_INSTANCES_PKG.IS_INITIALIZED THEN
         RAISE NO_DATA_FOUND;
      END IF;

      --do the insert
      INSERT INTO fnd_oam_dscfg_properties (PROPERTY_ID,
                                            PARENT_TYPE,
                                            PARENT_ID,
                                            PROPERTY_NAME,
                                            DATATYPE,
                                            CANONICAL_VALUE,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            LAST_UPDATED_BY,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATE_LOGIN)
         VALUES (FND_OAM_DSCFG_PROPERTIES_S.NEXTVAL,
                 p_parent_type,
                 p_parent_id,
                 p_property_name,
                 p_datatype,
                 p_canonical_value,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID)
         RETURNING PROPERTY_ID INTO l_property_id;

      x_property_id := l_property_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_varchar2_value      IN VARCHAR2,
                          x_property_id         OUT NOCOPY NUMBER)
   IS
   BEGIN
      ADD_PROPERTY(p_parent_type,
                   p_parent_id,
                   p_property_name,
                   FND_OAM_DSCFG_API_PKG.G_DATATYPE_VARCHAR2,
                   p_varchar2_value,
                   x_property_id);
   END;

    -- Public
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_number_value        IN NUMBER,
                          x_property_id         OUT NOCOPY NUMBER)
   IS
   BEGIN
      ADD_PROPERTY(p_parent_type,
                   p_parent_id,
                   p_property_name,
                   FND_OAM_DSCFG_API_PKG.G_DATATYPE_NUMBER,
                   FND_OAM_DSCFG_UTILS_PKG.NUMBER_TO_CANONICAL(p_number_value),
                   x_property_id);
   END;


   -- Public
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_date_value          IN DATE,
                          x_property_id         OUT NOCOPY NUMBER)
   IS
   BEGIN
      ADD_PROPERTY(p_parent_type,
                   p_parent_id,
                   p_property_name,
                   FND_OAM_DSCFG_API_PKG.G_DATATYPE_DATE,
                   FND_OAM_DSCFG_UTILS_PKG.DATE_TO_CANONICAL(p_date_value),
                   x_property_id);
   END;

   -- Public
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_boolean_value       IN BOOLEAN,
                          x_property_id         OUT NOCOPY NUMBER)
   IS
   BEGIN
      ADD_PROPERTY(p_parent_type,
                   p_parent_id,
                   p_property_name,
                   FND_OAM_DSCFG_API_PKG.G_DATATYPE_BOOLEAN,
                   FND_OAM_DSCFG_UTILS_PKG.BOOLEAN_TO_CANONICAL(p_boolean_value),
                   x_property_id);
   END;

   -- Public
   PROCEDURE ADD_PROPERTY_ROWID(p_parent_type           IN VARCHAR2,
                                p_parent_id             IN NUMBER,
                                p_property_name         IN VARCHAR2,
                                p_rowid_value           IN ROWID,
                                x_property_id           OUT NOCOPY NUMBER)
   IS
   BEGIN
      ADD_PROPERTY(p_parent_type,
                   p_parent_id,
                   p_property_name,
                   FND_OAM_DSCFG_API_PKG.G_DATATYPE_ROWID,
                   TO_CHAR(p_rowid_value),
                   x_property_id);
   END;

   -- Public
   PROCEDURE ADD_PROPERTY_RAW(p_parent_type             IN VARCHAR2,
                              p_parent_id               IN NUMBER,
                              p_property_name           IN VARCHAR2,
                              p_raw_value               IN RAW,
                              x_property_id             OUT NOCOPY NUMBER)
   IS
   BEGIN
      ADD_PROPERTY(p_parent_type,
                   p_parent_id,
                   p_property_name,
                   FND_OAM_DSCFG_API_PKG.G_DATATYPE_RAW,
                   TO_CHAR(p_raw_value),
                   x_property_id);
   END;

   -- Public
   PROCEDURE GET_PROPERTY_CANONICAL_VALUE(p_parent_type         IN VARCHAR2,
                                          p_parent_id           IN NUMBER,
                                          p_property_name       IN VARCHAR2,
                                          x_canonical_value     OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_PROPERTY_CANONICAL_VALUE';

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      SELECT    canonical_value
         INTO   x_canonical_value
         FROM   fnd_oam_dscfg_properties
         WHERE  parent_type = p_parent_type
         AND    parent_id = p_parent_id
         AND    property_name = p_property_name;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN TOO_MANY_ROWS THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE GET_PROPERTY_VALUE(p_parent_type           IN VARCHAR2,
                                p_parent_id             IN NUMBER,
                                p_property_name         IN VARCHAR2,
                                x_varchar2_value        OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      GET_PROPERTY_CANONICAL_VALUE(p_parent_type,
                                   p_parent_id,
                                   p_property_name,
                                   x_varchar2_value);
   END;

   -- Convenience wrapper on generic GET_PROPERTY_CANONICAL_VALUE for datatype NUMBER
   PROCEDURE GET_PROPERTY_VALUE(p_parent_type           IN VARCHAR2,
                                p_parent_id             IN NUMBER,
                                p_property_name         IN VARCHAR2,
                                x_number_value          OUT NOCOPY NUMBER)
   IS
      l_canonical_value         VARCHAR2(4000);
   BEGIN
      GET_PROPERTY_CANONICAL_VALUE(p_parent_type,
                                   p_parent_id,
                                   p_property_name,
                                   l_canonical_value);
      x_number_value := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_NUMBER(l_canonical_value);
   END;


   -- Convenience wrapper on generic GET_PROPERTY_CANONICAL_VALUE for datatype DATE
   PROCEDURE GET_PROPERTY_VALUE(p_parent_type           IN VARCHAR2,
                                p_parent_id             IN NUMBER,
                                p_property_name         IN VARCHAR2,
                                x_date_value            OUT NOCOPY DATE)
   IS
      l_canonical_value         VARCHAR2(4000);
   BEGIN
      GET_PROPERTY_CANONICAL_VALUE(p_parent_type,
                                   p_parent_id,
                                   p_property_name,
                                   l_canonical_value);
      x_date_value := FND_OAM_DSCFG_UTILS_PKG.CANONICAL_TO_DATE(l_canonical_value);
   END;

   -- Public
   PROCEDURE SET_OR_ADD_PROPERTY(p_parent_type          IN VARCHAR2,
                                 p_parent_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_datatype             IN VARCHAR2,
                                 p_canonical_value      IN VARCHAR2,
                                 x_property_id          OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'SET_OR_ADD_PROPERTY';

      l_property_id             NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --make sure a configuration instance is initialized, we don't need it but
      --we need this as a security harness check.
      IF NOT FND_OAM_DSCFG_INSTANCES_PKG.IS_INITIALIZED THEN
         RAISE NO_DATA_FOUND;
      END IF;

      --see if the property's present
      BEGIN
         SELECT property_id
            INTO l_property_id
            FROM fnd_oam_dscfg_properties
            WHERE parent_type = p_parent_type
            AND parent_id = p_parent_id
            AND property_name = p_property_name;

         --if we didn't throw an exception, we found a single row we can update
         --don't allow changing the datatype
         UPDATE fnd_oam_dscfg_properties
            SET canonical_value = p_canonical_value,
            last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = SYSDATE,
            last_update_login = FND_GLOBAL.USER_ID
            WHERE property_id = l_property_id;
         x_property_id := l_property_id;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --do an add
            ADD_PROPERTY(p_parent_type,
                         p_parent_id,
                         p_property_name,
                         p_datatype,
                         p_canonical_value,
                         x_property_id);
      END;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN TOO_MANY_ROWS THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE SET_OR_ADD_PROPERTY(p_parent_type          IN VARCHAR2,
                                 p_parent_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_varchar2_value       IN VARCHAR2,
                                 x_property_id          OUT NOCOPY NUMBER)
   IS
   BEGIN
      SET_OR_ADD_PROPERTY(p_parent_type,
                          p_parent_id,
                          p_property_name,
                          FND_OAM_DSCFG_API_PKG.G_DATATYPE_VARCHAR2,
                          p_varchar2_value,
                          x_property_id);
   END;

   -- Public
   PROCEDURE SET_OR_ADD_PROPERTY(p_parent_type          IN VARCHAR2,
                                 p_parent_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_number_value         IN NUMBER,
                                 x_property_id          OUT NOCOPY NUMBER)
   IS
   BEGIN
      SET_OR_ADD_PROPERTY(p_parent_type,
                          p_parent_id,
                          p_property_name,
                          FND_OAM_DSCFG_API_PKG.G_DATATYPE_NUMBER,
                          FND_OAM_DSCFG_UTILS_PKG.NUMBER_TO_CANONICAL(p_number_value),
                          x_property_id);
   END;

   -- Public
   PROCEDURE SET_OR_ADD_PROPERTY(p_parent_type          IN VARCHAR2,
                                 p_parent_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_date_value           IN DATE,
                                 x_property_id          OUT NOCOPY NUMBER)
   IS
   BEGIN
      SET_OR_ADD_PROPERTY(p_parent_type,
                          p_parent_id,
                          p_property_name,
                          FND_OAM_DSCFG_API_PKG.G_DATATYPE_DATE,
                          FND_OAM_DSCFG_UTILS_PKG.DATE_TO_CANONICAL(p_date_value),
                          x_property_id);
   END;

   -- Public
   FUNCTION DELETE_PROPERTIES(p_parent_type     IN VARCHAR2,
                              p_parent_id       IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_PROPERTIES';

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --just delete the property
      DELETE FROM fnd_oam_dscfg_properties
         WHERE parent_type = p_parent_type
         AND parent_id = p_parent_id;
      fnd_oam_debug.log(1, l_ctxt, 'Deleted '||SQL%ROWCOUNT||' properties.');

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;


   -- Public
   FUNCTION DELETE_PROPERTY(p_property_id       IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_PROPERTY';

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --just delete the property
      DELETE FROM fnd_oam_dscfg_properties
         WHERE property_id = p_property_id;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

END FND_OAM_DSCFG_PROPERTIES_PKG;

/
