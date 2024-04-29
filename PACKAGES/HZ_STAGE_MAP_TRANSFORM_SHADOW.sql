--------------------------------------------------------
--  DDL for Package HZ_STAGE_MAP_TRANSFORM_SHADOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_STAGE_MAP_TRANSFORM_SHADOW" AUTHID CURRENT_USER AS
/* $Header: ARHDSSMS.pls 120.0 2005/08/18 00:07:12 nthaker noship $ */

  PROCEDURE open_party_cursor(
    p_select_type	IN	VARCHAR2,
    p_party_type	IN	VARCHAR2,
    p_worker_number IN	NUMBER,
    p_num_workers	IN	NUMBER,
    p_party_id	IN	NUMBER,
    p_continue	IN	VARCHAR2,
    x_party_cur	IN OUT NOCOPY	HZ_PARTY_STAGE.StageCurTyp);

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

 /** These are introduced as part of R12 as part of introducing the
     the user defined datastore for context indexes ***********/
 PROCEDURE PARTY_DS(rid in rowid, tlob in out nocopy clob) ;
 PROCEDURE PARTY_SITE_DS(rid in rowid, tlob in out nocopy clob) ;
 PROCEDURE CONTACT_DS(rid in rowid, tlob in out nocopy clob) ;
 PROCEDURE CONTACT_POINT_DS(rid in rowid, tlob in out nocopy clob) ;

END HZ_STAGE_MAP_TRANSFORM_SHADOW;

 

/

  GRANT EXECUTE ON "APPS"."HZ_STAGE_MAP_TRANSFORM_SHADOW" TO "AR";
