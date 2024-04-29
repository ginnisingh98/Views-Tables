--------------------------------------------------------
--  DDL for Package HZ_STAGE_MAP_TRANSFORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_STAGE_MAP_TRANSFORM" AUTHID CURRENT_USER AS
/* $Header: ARHDQSMS.pls 120.9.12010000.2 2010/03/29 11:10:06 amstephe ship $ */

  PROCEDURE open_party_cursor(
    p_select_type	IN             VARCHAR2,
    p_party_type	IN             VARCHAR2,
    p_worker_number     IN             NUMBER,
    p_num_workers	IN             NUMBER,
    p_party_id	        IN             NUMBER,
    p_continue          IN	       VARCHAR2,
    x_party_cur	        IN OUT NOCOPY  HZ_PARTY_STAGE.StageCurTyp);

  PROCEDURE open_sync_party_cursor (
    p_operation      IN             VARCHAR2,
    p_party_type     IN             VARCHAR2,
    p_from_rec       IN             VARCHAR2,
    p_to_rec         IN             VARCHAR2,
    x_sync_party_cur IN OUT NOCOPY  HZ_DQM_SYNC.SyncCurTyp );

  PROCEDURE open_sync_party_site_cursor (
    p_operation           IN            VARCHAR2,
    p_from_rec            IN            VARCHAR2,
    p_to_rec              IN            VARCHAR2,
    x_sync_party_site_cur IN OUT NOCOPY  HZ_DQM_SYNC.SyncCurTyp );

  PROCEDURE open_sync_contact_cursor (
    p_operation        IN            VARCHAR2,
    p_from_rec         IN            VARCHAR2,
    p_to_rec           IN            VARCHAR2,
    x_sync_contact_cur IN OUT NOCOPY HZ_DQM_SYNC.SyncCurTyp );

  PROCEDURE open_sync_cpt_cursor (
    p_operation      IN          VARCHAR2,
    p_from_rec       IN          VARCHAR2,
    p_to_rec         IN          VARCHAR2,
    x_sync_cpt_cur IN OUT NOCOPY HZ_DQM_SYNC.SyncCurTyp );

  -- REPURI. Modified the 4 sync_all_xxx to include the
  -- p_bulk_sync_type parameter to distinguish the calling API.
  -- Bug 4884735.
  PROCEDURE sync_all_parties (
    p_operation             IN VARCHAR2,
    p_bulk_sync_type        IN VARCHAR2,
    p_sync_all_party_cur    IN HZ_DQM_SYNC.SyncCurTyp);

  PROCEDURE sync_all_party_sites (
    p_operation                IN VARCHAR2,
    p_bulk_sync_type           IN VARCHAR2,
    p_sync_all_party_site_cur  IN HZ_DQM_SYNC.SyncCurTyp);

  PROCEDURE sync_all_contacts (
    p_operation             IN VARCHAR2,
    p_bulk_sync_type        IN VARCHAR2,
    p_sync_all_contact_cur  IN HZ_DQM_SYNC.SyncCurTyp);

  PROCEDURE sync_all_contact_points (
    p_operation             IN VARCHAR2,
    p_bulk_sync_type        IN VARCHAR2,
    p_sync_all_cpt_cur      IN HZ_DQM_SYNC.SyncCurTyp);

  PROCEDURE insert_stage_parties (
    p_continue     IN VARCHAR2,
    p_party_cur    IN HZ_PARTY_STAGE.StageCurTyp);

  PROCEDURE insert_stage_party_sites;
  PROCEDURE insert_stage_contacts;
  PROCEDURE insert_stage_contact_pts;

  PROCEDURE sync_single_party (
    p_party_id NUMBER,
    p_party_type VARCHAR2,
    p_operation VARCHAR2);

  PROCEDURE sync_single_party_site (
    p_party_site_id NUMBER,
    p_operation VARCHAR2);

  PROCEDURE sync_single_contact (
    p_org_contact_id NUMBER,
    p_operation VARCHAR2);

  PROCEDURE sync_single_contact_point (
    p_contact_point_id NUMBER,
    p_operation VARCHAR2);

  PROCEDURE log (
    message      IN      VARCHAR2,
    newline      IN      BOOLEAN DEFAULT TRUE);

  -- VJN Introduced for R12
  -- REPURI modifications for Sync Enhancements, changed the signatures of
  -- sync_single_xxx_online, to be similar to sync_single_xxx Procedures.

  PROCEDURE sync_single_party_online (
    p_party_id NUMBER,
    p_operation VARCHAR2);

  PROCEDURE sync_single_party_site_online (
    p_party_site_id NUMBER,
    p_operation VARCHAR2);

  PROCEDURE sync_single_contact_online (
    p_org_contact_id NUMBER,
    p_operation VARCHAR2);

  PROCEDURE sync_single_cpt_online (
    p_contact_point_id NUMBER,
    p_operation VARCHAR2);

  FUNCTION miscp (rid IN ROWID) RETURN CLOB;
  FUNCTION miscps (rid IN ROWID) RETURN CLOB;
  FUNCTION miscct (rid IN ROWID) RETURN CLOB;
  FUNCTION misccpt (rid IN ROWID) RETURN CLOB;

  FUNCTION den_ps (party_id NUMBER) RETURN VARCHAR2;
  FUNCTION den_cpt (party_id NUMBER) RETURN VARCHAR2;
  FUNCTION den_ct (party_id NUMBER) RETURN VARCHAR2;
  FUNCTION den_acc_number (party_id NUMBER) RETURN VARCHAR2;

  -- REPURI. Adding 4 new procedures to populate
  -- bulk import ref cursors. Bug 4884735.
  PROCEDURE open_bulk_imp_sync_cpt_cur (
    p_batch_id             IN            NUMBER,
    p_batch_mode_flag      IN            VARCHAR2,
    p_from_osr             IN            VARCHAR2,
    p_to_osr               IN            VARCHAR2,
    p_os                   IN            VARCHAR2,
    p_operation            IN            VARCHAR2,
    x_sync_cpt_cur         IN OUT NOCOPY HZ_DQM_SYNC.SyncCurTyp);
  PROCEDURE open_bulk_imp_sync_ct_cur (
    p_batch_id             IN            NUMBER,
    p_batch_mode_flag      IN            VARCHAR2,
    p_from_osr             IN            VARCHAR2,
    p_to_osr               IN            VARCHAR2,
    p_os                   IN            VARCHAR2,
    p_operation            IN            VARCHAR2,
    x_sync_contact_cur     IN OUT NOCOPY HZ_DQM_SYNC.SyncCurTyp);
  PROCEDURE open_bulk_imp_sync_party_cur(
    p_batch_id             IN            NUMBER,
    p_batch_mode_flag      IN            VARCHAR2,
    p_from_osr             IN            VARCHAR2,
    p_to_osr               IN            VARCHAR2,
    p_os                   IN            VARCHAR2,
    p_party_type           IN            VARCHAR2,
    p_operation            IN            VARCHAR2,
    x_sync_party_cur       IN OUT NOCOPY HZ_DQM_SYNC.SyncCurTyp);
  PROCEDURE open_bulk_imp_sync_psite_cur (
    p_batch_id             IN            NUMBER,
    p_batch_mode_flag      IN            VARCHAR2,
    p_from_osr             IN            VARCHAR2,
    p_to_osr               IN            VARCHAR2,
    p_os                   IN            VARCHAR2,
    p_operation            IN            VARCHAR2,
    x_sync_party_site_cur  IN OUT NOCOPY HZ_DQM_SYNC.SyncCurTyp);

END HZ_STAGE_MAP_TRANSFORM;

/

  GRANT EXECUTE ON "APPS"."HZ_STAGE_MAP_TRANSFORM" TO "CTXSYS";
  GRANT EXECUTE ON "APPS"."HZ_STAGE_MAP_TRANSFORM" TO "AR";
