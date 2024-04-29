--------------------------------------------------------
--  DDL for Package HZ_DQM_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DQM_SYNC" AUTHID CURRENT_USER AS
/* $Header: ARHDQSNS.pls 120.7 2006/01/19 09:50:13 repuri noship $ */

PROCEDURE sync_org (
        p_party_id      IN      NUMBER,
        p_create_upd    IN      VARCHAR2
);

PROCEDURE sync_person (
        p_party_id      IN      NUMBER,
        p_create_upd    IN      VARCHAR2
);

PROCEDURE sync_party_site (
        p_party_site_id IN      NUMBER,
        p_create_upd    IN      VARCHAR2
);

PROCEDURE sync_contact (
        p_org_contact_id IN      NUMBER,
        p_create_upd     IN      VARCHAR2
);

PROCEDURE sync_contact_point (
        p_contact_point_id IN      NUMBER,
        p_create_upd       IN      VARCHAR2
);


PROCEDURE sync_location (
        p_location_id   IN      NUMBER,
        p_create_upd       IN      VARCHAR2
);

PROCEDURE sync_relationship (
        p_relationship_id  IN      NUMBER,
        p_create_upd       IN      VARCHAR2
);

PROCEDURE sync_cust_account (
        p_cust_acct_id  IN      NUMBER,
        p_create_upd    IN      VARCHAR2
);
/*
PROCEDURE sync_parties (
        errbuf                  OUT     NOCOPY VARCHAR2,
        retcode                 OUT     NOCOPY VARCHAR2
); */

PROCEDURE optimize_indexes (
        errbuf                  OUT     NOCOPY VARCHAR2,
        retcode                 OUT     NOCOPY VARCHAR2
);

PROCEDURE stage_party_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT  NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT          NOCOPY VARCHAR2
);

PROCEDURE stage_party_site_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT  NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT          NOCOPY VARCHAR2
);

PROCEDURE stage_contact_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT  NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT          NOCOPY VARCHAR2
);

PROCEDURE stage_contact_point_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT  NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT          NOCOPY VARCHAR2
);

FUNCTION realtime_sync  (p_subscription_guid  IN RAW,
   p_event              IN OUT NOCOPY WF_EVENT_T)
   RETURN VARCHAR2 ;


TYPE SyncCurTyp IS REF CURSOR;

PROCEDURE sync_work_unit(retcode OUT NOCOPY   VARCHAR2,
    err         OUT NOCOPY    VARCHAR2,
    p_from_rec  IN  VARCHAR2,
    p_to_rec    IN  VARCHAR2,
    p_sync_type IN  VARCHAR2 );

PROCEDURE sync_parties(retcode  OUT NOCOPY   VARCHAR2,
    err               OUT NOCOPY    VARCHAR2,
    p_num_of_workers  IN VARCHAR2,
    p_indexes_only    IN VARCHAR2 );

PROCEDURE sync_index_conc(
        retcode                 OUT    NOCOPY VARCHAR2,
        err                     OUT    NOCOPY VARCHAR2,
        p_index_name            IN     VARCHAR2 );

PROCEDURE set_to_batch_sync;

-- VJN modified for R12 for Bulk Import
-- This API would be called by the Bulk Import Post Processing Program, to directly insert
-- data into the STAGING tables
-- Modified for R12 using collections instead of Ref Cursors

-- REPURI. Modified to get batch details instead of collections. Bug 4884735.

PROCEDURE sync_work_unit_imp(
  p_batch_id        IN          NUMBER,
  p_batch_mode_flag IN          VARCHAR2,
  p_from_osr        IN          VARCHAR2,
  p_to_osr          IN          VARCHAR2,
  p_os              IN          VARCHAR2,
  x_return_status   OUT NOCOPY  VARCHAR2,
  x_msg_count       OUT NOCOPY  NUMBER,
  x_msg_data        OUT NOCOPY  VARCHAR2
) ;

-- REPURI. Added to enable inserting data into HZ_DQM_SH_SYNC_INTERFACE table.
-- The table is the Interface table for Shadow Sync. Bug 4884742.

  PROCEDURE insert_sh_interface_rec (
	p_party_id	     IN	 NUMBER,
	p_record_id	     IN	 NUMBER,
	p_party_site_id	 IN	 NUMBER,
	p_org_contact_id IN	 NUMBER,
	p_entity	     IN	 VARCHAR2,
	p_operation	     IN	 VARCHAR2,
	p_staged_flag    IN  VARCHAR2 DEFAULT 'N'
);

-- REPURI. Introduced to check if shadow staging has completed successfully. Bug 4884742.

  FUNCTION is_shadow_staging_complete RETURN BOOLEAN;

-- VJN Introduced for setting transactional property of Index, a new feature
-- for text indexes, available as part of 10g.
PROCEDURE set_index_transactional ( enabled IN VARCHAR2 ) ;

------------------------------
-- VJN Sync changes for R12
-----------------------------

-- conc program executable for Serial Sync Index Concurrent Program
-- This will be used only online (API) flows
PROCEDURE sync_index_serial(
        retcode                 OUT    NOCOPY VARCHAR2,
        err                     OUT    NOCOPY VARCHAR2
        );

-- conc program executable for Parallel Sync Index Parent Concurrent Program
-- This will be used by both Manual ( Batch) Synchronization and Bulk Import

PROCEDURE sync_index_parallel_parent (
        retcode                 OUT    NOCOPY VARCHAR2,
        err                     OUT    NOCOPY VARCHAR2,
        p_request_id            IN     NUMBER
        );

-- conc program executable for Parallel Sync Index Child Concurrent Program
-- This will be used by both Manual ( Batch) Synchronization and Bulk Import
PROCEDURE sync_index_parallel_child (
        retcode                 OUT    NOCOPY VARCHAR2,
        err                     OUT    NOCOPY VARCHAR2,
        p_request_id            IN     NUMBER,
        p_index_name            IN     VARCHAR2
        );

END HZ_DQM_SYNC;


 

/
