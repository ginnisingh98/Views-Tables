--------------------------------------------------------
--  DDL for Package HZ_STAGE_MAP_TRANSFORM_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_STAGE_MAP_TRANSFORM_UPD" AUTHID CURRENT_USER AS
/* $Header: ARHDQMUS.pls 120.3 2005/06/16 21:11:06 jhuang noship $ */

  PROCEDURE open_party_cursor(
      p_party_type   IN      VARCHAR2,
      p_worker_number IN     NUMBER,
      p_num_workers  IN      NUMBER,
      x_party_cur    IN OUT  NOCOPY HZ_PARTY_STAGE.StageCurTyp);

  PROCEDURE open_contact_cursor(
      p_worker_number IN     NUMBER,
      p_num_workers  IN      NUMBER,
      x_contact_cur  IN OUT  NOCOPY HZ_PARTY_STAGE.StageCurTyp);

  PROCEDURE open_party_site_cursor(
      p_worker_number IN     NUMBER,
      p_num_workers  IN      NUMBER,
      x_party_site_cur       IN OUT  NOCOPY HZ_PARTY_STAGE.StageCurTyp);

  PROCEDURE open_contact_pt_cursor(
      p_worker_number IN     NUMBER,
      p_num_workers  IN      NUMBER,
      x_contact_pt_cur       IN OUT  NOCOPY HZ_PARTY_STAGE.StageCurTyp);

  PROCEDURE update_stage_parties (
      p_party_cur    IN HZ_PARTY_STAGE.StageCurTyp);

  PROCEDURE update_stage_contacts (
      p_contact_cur    IN HZ_PARTY_STAGE.StageCurTyp);

  PROCEDURE update_stage_party_sites (
      p_party_site_cur    IN HZ_PARTY_STAGE.StageCurTyp);

  PROCEDURE update_stage_contact_pts (
      p_contact_pt_cur    IN HZ_PARTY_STAGE.StageCurTyp);
END HZ_STAGE_MAP_TRANSFORM_UPD;

 

/
