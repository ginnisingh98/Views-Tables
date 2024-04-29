--------------------------------------------------------
--  DDL for Package PV_SLSTEAM_MIGRTN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_SLSTEAM_MIGRTN_PVT" AUTHID CURRENT_USER AS
/* $Header: pvslmigs.pls 120.1 2005/08/05 11:32:35 appldev noship $ */

  G_LOG_TO_FILE   VARCHAR2(1) := 'Y';
  TYPE migration_REC_TYPE IS RECORD (
  Entity      varchar2(1000),
  entity_id   varchar2(1000),
  party_name  varchar2(32000),
  resource_id number
  );
  TYPE migration_tbl_TYPE IS TABLE OF
  migration_REC_TYPE INDEX BY BINARY_INTEGER;


PROCEDURE EXT_SLSTEAM_MIGRTN
  ( ERRBUF     OUT NOCOPY   VARCHAR2,
    RETCODE    OUT NOCOPY   VARCHAR2,
    P_MODE     IN           VARCHAR2
  );
END PV_SLSTEAM_MIGRTN_PVT;

 

/
