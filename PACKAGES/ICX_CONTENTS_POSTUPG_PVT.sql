--------------------------------------------------------
--  DDL for Package ICX_CONTENTS_POSTUPG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CONTENTS_POSTUPG_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVCPUS.pls 120.1 2008/02/07 09:34:39 krsethur noship $*/

-- defining the types within this package


TYPE ICX_MAP_TBL_NUMBER IS TABLE OF ICX_TBL_NUMBER
  INDEX BY BINARY_INTEGER;

TYPE ICX_IDX_TBL_NUMBER IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

PROCEDURE auto_split;

PROCEDURE  get_new_zones_and_categorylist(p_original_zone_id IN NUMBER,
  p_new_zone_ids OUT NOCOPY ICX_TBL_NUMBER,
  p_zone_categories OUT NOCOPY ICX_MAP_TBL_NUMBER);

PROCEDURE create_content_zones(p_old_zone_id IN NUMBER,
  p_new_zone_ids IN ICX_TBL_NUMBER);

PROCEDURE create_category_restrictions(p_old_zone_id IN NUMBER,
      p_new_zone_ids IN ICX_TBL_NUMBER ,
      p_zone_categories IN ICX_MAP_TBL_NUMBER );

PROCEDURE create_secure_contents(p_old_zone_id IN NUMBER,
      p_new_zone_ids IN ICX_TBL_NUMBER);

PROCEDURE add_new_zones_to_stores(p_old_zone_id IN NUMBER,
      p_new_zone_ids IN ICX_TBL_NUMBER);

PROCEDURE delete_old_zone(p_old_zone_id IN NUMBER);


END ICX_CONTENTS_POSTUPG_PVT;


/
