--------------------------------------------------------
--  DDL for Package AMS_PRICE_LIST_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PRICE_LIST_REPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsqprls.pls 115.0 2001/09/05 14:54:14 pkm ship      $*/

  TYPE sec_rec IS RECORD
  (
   parent_section_id NUMBER,
   child_section_id  NUMBER,
   SORT_ORDER        NUMBER,
   LEAF              VARCHAR2(1)
  );

  TYPE section_tbl_type IS TABLE OF sec_rec INDEX BY BINARY_INTEGER;

  PROCEDURE get_section_heirarchy( p_section_id number , px_section_tbl  OUT section_tbl_type) ;

END;

 

/
