--------------------------------------------------------
--  DDL for Package OKC_TERMS_DEVIATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_DEVIATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVTDRS.pls 120.1.12000000.3 2007/08/01 11:52:31 ndoddi ship $ */


/*
-- PROCEDURE Populate_Template_Articles
-- To be used to delete populate the global temp table with articles on
-- the current version of the template.
*/
PROCEDURE Populate_Template_Articles (
    x_return_status    OUT NOCOPY VARCHAR2,
    p_template_id      IN  NUMBER,
    p_doc_type		   IN  VARCHAR2
);

/*
-- PROCEDURE Populate_Expert_Articles
-- To be used to delete populate the global temp table with articles on
-- the current version of the Expert.
*/
PROCEDURE Populate_Expert_Articles (
    x_return_status    OUT NOCOPY VARCHAR2,
    p_document_type    IN  VARCHAR2,
    p_document_id      IN  NUMBER,
    p_include_exp      OUT NOCOPY VARCHAR2,
    p_seq_id           IN  NUMBER
);

/*
-- PROCEDURE Generate_Terms_Deviations
-- This API will be used to generate deviations
*/
PROCEDURE Generate_Terms_Deviations (
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,

    p_doc_type          IN  VARCHAR2,
    p_doc_id            IN  NUMBER,
    p_template_id       IN  NUMBER ,
    p_run_id		OUT NOCOPY NUMBER
);

type scn_id_tbl is TABLE of okc_terms_deviations_temp.scn_id%type
   	INDEX BY BINARY_INTEGER;
type article_id_tbl is TABLE OF okc_terms_deviations_temp.article_id%type
	INDEX BY BINARY_INTEGER;
type article_version_id_tbl is TABLE OF okc_terms_deviations_temp.article_version_id%type
	INDEX BY BINARY_INTEGER;
type ref_article_id_tbl is TABLE OF okc_terms_deviations_temp.ref_article_id%type
	INDEX BY BINARY_INTEGER;
type ref_article_version_id_tbl is TABLE OF okc_terms_deviations_temp.ref_article_version_id%type
	INDEX BY BINARY_INTEGER;
type display_sequence_tbl is TABLE OF okc_terms_deviations_temp.display_sequence%type
	INDEX BY BINARY_INTEGER;
type label_tbl is TABLE OF okc_terms_deviations_t.label%type
	INDEX BY BINARY_INTEGER;
type mandatory_flag_tbl is TABLE OF okc_terms_deviations_temp.mandatory_flag%type
	INDEX BY BINARY_INTEGER;
type orig_article_id_tbl is TABLE OF okc_terms_deviations_temp.orig_article_id%type
	INDEX BY BINARY_INTEGER;
type section_heading_tbl is TABLE OF okc_terms_deviations_t.section_heading%type
	INDEX BY BINARY_INTEGER;
type article_title_tbl is TABLE OF okc_terms_deviations_t.article_title%type
	INDEX BY BINARY_INTEGER;
type dev_category_tbl is TABLE OF okc_terms_deviations_t.deviation_category%type
	INDEX BY BINARY_INTEGER;
type dev_code_tbl is TABLE OF okc_terms_deviations_t.deviation_code%type
	INDEX BY BINARY_INTEGER;
type dev_category_meaning_tbl is TABLE OF okc_terms_deviations_t.deviation_category_meaning%type
     INDEX BY BINARY_INTEGER;
type dev_code_meaning_tbl is TABLE OF okc_terms_deviations_t.deviation_code_meaning%type
     INDEX BY BINARY_INTEGER;
type art_seq_id_tbl is TABLE OF okc_terms_deviations_t.art_seq_id%type
     INDEX BY BINARY_INTEGER;

-- Procedure to insert data into okc_terms_deviations_t table
-- this will be a BULK insert as all the parameters passed to
-- this routine are table type.
Procedure Insert_deviations(
    x_return_status     	OUT NOCOPY VARCHAR2,
    x_msg_data          	OUT NOCOPY VARCHAR2,
    x_msg_count         	OUT NOCOPY NUMBER,

    p_seq_id                    IN Number,
    p_dev_category              IN Varchar2,
    p_dev_code                  IN Varchar2,
    p_dev_category_meaning      IN Varchar2,
    p_dev_code_meaning          IN Varchar2,
    p_dev_category_priority     IN Number,
    p_scn_id                    IN scn_id_tbl,
    p_section_heading           IN section_heading_tbl,
    p_label                     IN label_tbl,
    p_doc_article_id            IN article_id_tbl,
    p_doc_article_version_id    IN article_version_id_tbl,
    p_ref_article_id            IN ref_article_id_tbl,
    p_ref_article_version_id    IN ref_article_version_id_tbl,
    p_article_title             IN article_title_tbl,
    p_display_sequence          IN display_sequence_tbl,
    p_mandatory_flag            IN mandatory_flag_tbl,
    p_orig_article_id           IN orig_article_id_tbl,
    p_art_seq_id                IN art_seq_id_tbl,
    p_compare_flag              IN Varchar2 default 'N',
    p_doc_type				  IN Varchar2,
    p_doc_id				  IN Number);


-- This procedure will be called from Contracts Purge
-- concurrent program. This is used for purging the
-- deviations data as it will be generated every time
-- user requests for it.

Procedure Purge_Deviations_Data(
	errbuf 			OUT NOCOPY VARCHAR2,
	retcode			OUT NOCOPY VARCHAR2,
	p_num_days		IN  NUMBER DEFAULT 3);

FUNCTION has_deviation_report(
  p_document_type   IN  VARCHAR2,
  p_document_id     IN  NUMBER
 ) RETURN VARCHAR2;

end;

 

/
