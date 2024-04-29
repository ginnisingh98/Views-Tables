--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCFG_MAPPED_KEYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCFG_MAPPED_KEYS_PKG" as
/* $Header: AFOAMDSCMKEYB.pls 120.1 2005/11/23 10:55 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCFG_MAPPED_KEYS_PKG.';

   --stateless, only contains a table handler to insert a new directive with no properties

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   PROCEDURE ADD_MAPPED_KEY(p_mapped_key_type   IN VARCHAR2,
                            p_number_pk1        IN NUMBER       DEFAULT NULL,
                            p_number_pk2        IN NUMBER       DEFAULT NULL,
                            p_number_pk3        IN NUMBER       DEFAULT NULL,
                            p_number_pk4        IN NUMBER       DEFAULT NULL,
                            p_number_pk5        IN NUMBER       DEFAULT NULL,
                            p_raw_pk1           IN RAW          DEFAULT NULL,
                            p_raw_pk2           IN RAW          DEFAULT NULL,
                            p_raw_pk3           IN RAW          DEFAULT NULL,
                            p_varchar2_pk1      IN VARCHAR2     DEFAULT NULL,
                            p_varchar2_pk2      IN VARCHAR2     DEFAULT NULL,
                            p_varchar2_pk3      IN VARCHAR2     DEFAULT NULL,
                            p_varchar2_pk4      IN VARCHAR2     DEFAULT NULL,
                            p_varchar2_pk5      IN VARCHAR2     DEFAULT NULL,
                            x_mapped_key_id     OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_MAPPED_KEY';

      l_config_instance_id      NUMBER;
      l_proc_id                 NUMBER := NULL;

      l_mapped_key_id           NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --get the config_instance_id, throws error if not initialized
      l_config_instance_id := FND_OAM_DSCFG_INSTANCES_PKG.GET_CURRENT_ID;

      --try to get the import proc id
      IF FND_OAM_DSCFG_PROCS_PKG.IS_INITIALIZED THEN
         l_proc_id := FND_OAM_DSCFG_PROCS_PKG.GET_CURRENT_ID;
      END IF;

      --do the insert
      INSERT INTO fnd_oam_dscfg_mapped_keys (MAPPED_KEY_ID,
                                             CONFIG_INSTANCE_ID,
                                             PARENT_PROC_ID,
                                             MAPPED_KEY_TYPE,
                                             NUMBER_PK1,
                                             NUMBER_PK2,
                                             NUMBER_PK3,
                                             NUMBER_PK4,
                                             NUMBER_PK5,
                                             RAW_PK1,
                                             RAW_PK2,
                                             RAW_PK3,
                                             VARCHAR2_PK1,
                                             VARCHAR2_PK2,
                                             VARCHAR2_PK3,
                                             VARCHAR2_PK4,
                                             VARCHAR2_PK5,
                                             CREATED_BY,
                                             CREATION_DATE,
                                             LAST_UPDATED_BY,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATE_LOGIN)
         VALUES (FND_OAM_DSCFG_MAPPED_KEYS_S.NEXTVAL,
                 l_config_instance_id,
                 l_proc_id,
                 p_mapped_key_type,
                 p_number_pk1,
                 p_number_pk2,
                 p_number_pk3,
                 p_number_pk4,
                 p_number_pk5,
                 p_raw_pk1,
                 p_raw_pk2,
                 p_raw_pk3,
                 p_varchar2_pk1,
                 p_varchar2_pk2,
                 p_varchar2_pk3,
                 p_varchar2_pk4,
                 p_varchar2_pk5,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID)
         RETURNING MAPPED_KEY_ID INTO l_mapped_key_id;

      x_mapped_key_id := l_mapped_key_id;

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

END FND_OAM_DSCFG_MAPPED_KEYS_PKG;

/
