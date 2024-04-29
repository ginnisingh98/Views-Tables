--------------------------------------------------------
--  DDL for Package OKE_VERSION_COMPARISON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_VERSION_COMPARISON_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEKVCPS.pls 115.9 2003/08/07 22:15:12 tweichen noship $ */

    PROCEDURE comp_all_items(p_Header_id IN NUMBER, p_Version_1 IN NUMBER, p_Version_2 IN NUMBER);

    PROCEDURE comp_headers(vHeader_id IN NUMBER, vVersion1 IN NUMBER, vVersion2 IN NUMBER);

    PROCEDURE comp_lines(vHeader_id IN NUMBER, vVersion1 IN NUMBER, vVersion2 IN NUMBER);

    PROCEDURE comp_subline(vHeader_id IN NUMBER, vVersion1 IN NUMBER, vVersion2 IN NUMBER, vParentLineId IN NUMBER);

    PROCEDURE comp_header_terms(vHeader_id IN NUMBER, vVersion_1 IN NUMBER, vVersion_2 IN NUMBER);

    PROCEDURE comp_line_terms(vHeader_id IN NUMBER, vVersion_1 IN NUMBER, vVersion_2 IN NUMBER,vLine_id IN NUMBER);

    PROCEDURE comp_header_parties(vHeader_id IN NUMBER, vVersion_1 IN NUMBER, vVersion_2 IN NUMBER);

    PROCEDURE comp_line_parties(vHeader_id IN NUMBER, vVersion_1 IN NUMBER, vVersion_2 IN NUMBER,vLine_id IN NUMBER);

    PROCEDURE comp_line_deliverables(vHeader_id IN NUMBER,vVersion1 IN NUMBER, vVersion2 IN NUMBER,vCurrentLineId IN NUMBER
);

    PROCEDURE comp_header_articles(vHeader_id IN NUMBER, vVersion_1 IN NUMBER, vVersion_2 IN NUMBER);

    PROCEDURE comp_line_articles(vHeader_id IN NUMBER, vVersion_1 IN NUMBER, vVersion_2 IN NUMBER,vLine_id IN NUMBER);





END OKE_VERSION_COMPARISON_PKG;

 

/
