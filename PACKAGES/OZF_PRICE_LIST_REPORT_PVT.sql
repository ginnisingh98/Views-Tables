--------------------------------------------------------
--  DDL for Package OZF_PRICE_LIST_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PRICE_LIST_REPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfqprls.pls 120.0 2005/06/01 03:34:22 appldev noship $*/

  TYPE sec_rec IS RECORD
  (
   parent_section_id NUMBER,
   child_section_id  NUMBER,
   SORT_ORDER        NUMBER,
   LEAF              VARCHAR2(1)
  );

  TYPE section_tbl_type IS TABLE OF sec_rec INDEX BY BINARY_INTEGER;

  PROCEDURE get_section_heirarchy( p_section_id number , px_section_tbl  OUT NOCOPY section_tbl_type) ;

END;

 

/
