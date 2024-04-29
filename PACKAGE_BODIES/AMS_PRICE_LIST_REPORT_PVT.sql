--------------------------------------------------------
--  DDL for Package Body AMS_PRICE_LIST_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PRICE_LIST_REPORT_PVT" AS
/* $Header: amsqprlb.pls 115.1 2001/09/12 16:15:20 pkm ship      $*/


g_total        NUMBER := 1;
g_sections_tbl section_tbl_type;

PROCEDURE get_section_heir( p_section_id NUMBER,px_section_tbl IN OUT SECTION_TBL_TYPE,p_mini_site_id IN NUMBER)
IS
 CURSOR get_sections IS
 SELECT parent_section_id,child_section_id,sort_order
   FROM ibe_dsp_msite_sct_sects
  WHERE parent_section_id = p_section_id
    AND mini_site_id = p_mini_site_id
   ORDER BY sort_order ;
 l_section_rec get_sections%ROWTYPE;
BEGIN
  OPEN get_sections;
  LOOP
  FETCH get_sections INTO l_section_rec;
  IF get_sections%notfound THEN
    px_section_tbl(g_total-1).leaf := 'Y';
    CLOSE get_sections;
    EXIT;
  ELSE
    px_section_tbl(g_total).child_section_id := l_section_rec.child_section_id;
    px_section_tbl(g_total).parent_section_id:= l_section_rec.parent_section_id;
    px_section_tbl(g_total).sort_order := l_section_rec.sort_order;
    px_section_tbl(g_total).leaf := 'N';
    g_total := g_total + 1;
    get_section_heir(l_section_rec.child_section_id,px_section_tbl,p_mini_site_id);
   END IF;
 END LOOP;
END;


PROCEDURE get_section_heirarchy( p_section_id number , px_section_tbl  OUT section_tbl_type) IS
  CURSOR cur_get_master_mini_site_id IS
  SELECT msite_id
    FROM ibe_msites_b
   WHERE master_msite_flag = 'Y';
  l_mini_site_id  NUMBER;
BEGIN
  OPEN cur_get_master_mini_site_id;
 FETCH cur_get_master_mini_site_id INTO l_mini_site_id;
 CLOSE cur_get_master_mini_site_id;
 get_section_heir(p_section_id,px_section_tbl,l_mini_site_id);
END;
END;

/
