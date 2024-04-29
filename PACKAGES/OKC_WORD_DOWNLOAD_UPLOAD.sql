--------------------------------------------------------
--  DDL for Package OKC_WORD_DOWNLOAD_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_WORD_DOWNLOAD_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: OKCWDUPS.pls 120.0.12010000.14 2012/12/12 10:29:00 skavutha noship $ */

-- Download Procedures

PROCEDURE DOWNLOAD_PRE_PROCESSOR(p_doc_id NUMBER,p_doc_type VARCHAR2,x_return_status OUT NOCOPY VARCHAR2,x_msg_data OUT NOCOPY VARCHAR2);
PROCEDURE DOWNLOAD_POST_PROCESSOR(p_doc_id NUMBER,p_doc_type VARCHAR2,x_return_status OUT NOCOPY VARCHAR2,x_msg_data OUT NOCOPY VARCHAR2);
FUNCTION get_article_body(p_text_in_word IN BLOB) RETURN CLOB;
FUNCTION RESOLVE_VARIABLES_DOWNLOAD(p_art_XML XMLType,p_var_XML XMLType) RETURN XMLType;

PROCEDURE UPLOAD_PRE_PROCESSOR(p_doc_id NUMBER,p_doc_type VARCHAR2, p_cust_tag_exists IN VARCHAR2 DEFAULT 'Y'
                                                          ,x_return_status OUT NOCOPY VARCHAR2,x_msg_data OUT NOCOPY VARCHAR2);
FUNCTION UPLOAD_POST_PROCESSOR(p_doc_id NUMBER,p_doc_type VARCHAR2,p_cat_id NUMBER) return BLOB;
FUNCTION RESOLVE_VARIABLES_UPLOAD(p_art_CLOB CLOB) RETURN CLOB;

-- Utility Procedures
FUNCTION BLOB_TO_CLOB(p_text_in_word IN BLOB) RETURN CLOB;
FUNCTION CLOB_TO_BLOB(p_clob IN CLOB) return BLOB;
FUNCTION GET_WORD_SYNC_PROFILE RETURN VARCHAR2;
PROCEDURE INSERT_WML_TEXT(p_article_version_id NUMBER, p_article_text_in_word BLOB);
PROCEDURE STRIP_TAGS (p_doc_id NUMBER, p_doc_type VARCHAR2);
FUNCTION GET_ARTICLE_WML(p_art_clob XMLType,p_doc_clob CLOB) return BLOB;
FUNCTION get_articleWML_Text(p_art_blob BLOB) return CLOB;
FUNCTION get_articleWML_Text(p_art_blob CLOB) return CLOB;
PROCEDURE get_latest_wml (p_doc_id IN NUMBER, p_doc_type IN VARCHAR2, p_cat_id IN NUMBER DEFAULT NULL,x_action OUT NOCOPY VARCHAR2, x_wml_blob OUT BLOB,
        x_return_status OUT NOCOPY VARCHAR2,x_msg_data OUT NOCOPY VARCHAR2);
FUNCTION get_latest_wmlblob (p_doc_id IN NUMBER, p_doc_type IN VARCHAR2, p_cat_id IN NUMBER DEFAULT NULL) RETURN BLOB;
PROCEDURE get_article_html_for_comp(p_art_ver_id IN NUMBER,p_review_upld_terms_id IN NUMBER,x_art_html OUT NOCOPY BLOB,x_success OUT NOCOPY VARCHAR2);
FUNCTION convert_wml_to_html_1(p_art_wml CLOB) return CLOB;
FUNCTION convert_rows_to_html(p_table CLOB) return CLOB;
FUNCTION convert_cells_to_html(p_row CLOB) return CLOB;
FUNCTION clean_html_diff(p_html_diff CLOB) RETURN CLOB;
FUNCTION change_encoding(p_clob CLOB) RETURN CLOB;
END OKC_WORD_DOWNLOAD_UPLOAD;

/
