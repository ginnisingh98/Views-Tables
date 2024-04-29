--------------------------------------------------------
--  DDL for Package FND_OAM_DSCFG_MAPPED_KEYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCFG_MAPPED_KEYS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSCMKEYS.pls 120.0 2005/11/23 10:17 ilawler noship $ */

   ---------------
   -- Constants --
   ---------------
   -- Mapped Key Types are provided by the import procedure

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- This procedure adds a new mapped key for a given configuration instance. The configuration_instance_id is pulled from the
   -- INSTANCES_PKG to force a call to CREATE/USE_CONFIG_INSTANCE. This is not autonomous so we can package
   -- the corresponding directive and its properties in the same, atomic commit.
   -- Invariants:
   --   Should only be called after a configuration instance has been created or set.
   -- Parameters:
   --   p_mapped_key_type       [OPTIONAL]Corresponds to API_PKG.G_KEYTYPE_* or a custom value for the import procedure,
   --                           gives meaning to which PK* fields are relevant.
   --   p_number_pk*            [OPTIONAL]NUMBER-type PK fields.  1-3 are NUMBER(15) with 4,5 as just NUMBER.
   --   p_raw_pk*               [OPTIONAL]RAW-type PK fields.  Used for GUID-type PKs.
   --   p_varchar2_pk*          [OPTIONAL]VARCHAR2-type PK fields.  1-3 are VARCHAR2(120) with 4,5 as VARCHAR2(4000).
   --
   --   x_mapped_key_id_id:     The corresponding ID of the newly created mapped key.
   -- Return Statuses:
   --   Throws NO_DATA_FOUND if the configuration instance isn't initialized.
   PROCEDURE ADD_MAPPED_KEY(p_mapped_key_type   IN VARCHAR2     DEFAULT NULL,
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
                            x_mapped_key_id     OUT NOCOPY NUMBER);

END FND_OAM_DSCFG_MAPPED_KEYS_PKG;

 

/
