--------------------------------------------------------
--  DDL for Package HRI_MTDT_AK_REGION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_MTDT_AK_REGION" AUTHID CURRENT_USER AS
/* $Header: hrimdakr.pkh 120.0 2005/06/24 07:30:36 appldev noship $ */
TYPE ak_region_metadata_rectype IS RECORD
  (ak_region_code          VARCHAR2(45)
  ,wkth_wktyp_sk_fk        VARCHAR2(30));

TYPE ak_region_metadata_tabtype IS TABLE OF ak_region_metadata_rectype
                   INDEX BY VARCHAR2(80);

FUNCTION get_ak_region_wkth_wktyp(p_ak_region_code   IN  VARCHAR2)
        RETURN VARCHAR2;

END HRI_MTDT_AK_REGION;

 

/
