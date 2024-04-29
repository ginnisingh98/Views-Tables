--------------------------------------------------------
--  DDL for Package Body CZ_APC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_APC_GRP" AS
/*	$Header: czapcgb.pls 120.0 2005/06/28 14:01:33 appldev noship $		*/

  CZ_APPLICATION_ID    CONSTANT NUMBER := 708;
  EGO_APPLICATION_ID   CONSTANT NUMBER := 431;

  DECIMAL_TYPE         CONSTANT NUMBER := 2;
  TEXT_TYPE            CONSTANT NUMBER := 4;
  TL_TEXT_TYPE         CONSTANT NUMBER := 8;

  l_Batch_Size         NUMBER := 10000;

  TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE varchar_tbl_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
  TYPE long_varchar_tbl_type IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

  TYPE varchar_arr_tbl_type IS TABLE OF long_varchar_tbl_type INDEX BY BINARY_INTEGER;
  TYPE number_arr_tbl_type IS TABLE OF number_tbl_type INDEX BY BINARY_INTEGER;

  FUNCTION Is_Supported_By_CZ (
   p_attr IN EGO_EXT_FWK_PUB.EGO_ATTR_USG_METADATA
  ) RETURN BOOLEAN IS

  BEGIN
   IF (p_attr.application_id <> 431) THEN  --only allow item attributes
     RETURN FALSE;
   ELSIF (p_attr.is_multi_row = 'Y') THEN  --disallow multi row attribute groups
     RETURN FALSE;
   ELSIF (p_attr.attr_grp_type <> 'EGO_ITEMMGMT_GROUP') THEN  --only allow USER-defined ATTRIBUTE -- groups
     RETURN FALSE;
   ELSIF (p_attr.data_type = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
          p_attr.data_type = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN  --disallow DATE AND DATE/TIME -- attributes
     RETURN FALSE;
   ELSE
     RETURN TRUE;
   END IF;
  END is_Supported_By_CZ;

END CZ_APC_GRP;

/
