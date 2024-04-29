--------------------------------------------------------
--  DDL for Package OKC_TERMS_MULTIREC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_MULTIREC_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGMULS.pls 120.2.12010000.3 2011/12/09 13:35:39 serukull ship $ */

TYPE art_var_rec_type IS RECORD (
    cat_id                 OKC_K_ART_VARIABLES.cat_id%type,
    variable_code          OKC_K_ART_VARIABLES.variable_code%type,
    variable_type          OKC_K_ART_VARIABLES.variable_type%type,
    external_yn            OKC_K_ART_VARIABLES.external_yn%type,
    variable_value_id      OKC_K_ART_VARIABLES.variable_value_id%type,
    variable_value         OKC_K_ART_VARIABLES.variable_value%type,
    attribute_value_set_id OKC_K_ART_VARIABLES.attribute_value_set_id%type,
    object_version_number  OKC_K_ART_VARIABLES.object_version_number%type
    );

TYPE kart_rec_type IS RECORD (
    id                         OKC_K_ARTICLES_B.id%type,
    sav_sae_id                 OKC_K_ARTICLES_B.sav_sae_id%type,
    article_version_id         OKC_K_ARTICLES_B.article_version_id%type,
    amendment_description      OKC_K_ARTICLES_B.amendment_description%TYPE,
    print_text_yn              OKC_K_ARTICLES_B.print_text_yn%TYPE,
    ref_article_id             OKC_K_ARTICLES_B.ref_article_id%TYPE,
    ref_article_version_id     OKC_K_ARTICLES_B.ref_article_version_id%TYPE
     );

TYPE organize_rec_type IS RECORD (
    object_type                   VARCHAR(30),
    id                     NUMBER
    );

TYPE structure_rec_type IS RECORD (
    type                   VARCHAR(30),
    id                     NUMBER,
    scn_id                 NUMBER,
    display_sequence       NUMBER,
    label                  VARCHAR2(15),
    mandatory_yn           VARCHAR2(1),
    object_version_number  OKC_K_ARTICLES_B.object_version_number%type
    );
TYPE article_rec_type IS RECORD (
    cat_id                     OKC_K_ARTICLES_B.cat_id%type,
    article_version_id         OKC_K_ARTICLES_B.article_version_id%type,
    ovn                        OKC_K_ARTICLES_B.object_version_number%type
    );

TYPE merge_review_rec_type IS RECORD (
    object_type            VARCHAR(30),
    review_upld_terms_id NUMBER,
    object_version_number   NUMBER
    );
TYPE art_var_tbl_type IS TABLE OF art_var_rec_type INDEX BY BINARY_INTEGER;
TYPE kart_tbl_type IS TABLE OF kart_rec_type INDEX BY BINARY_INTEGER;
TYPE structure_tbl_type IS TABLE OF structure_rec_type INDEX BY BINARY_INTEGER;
TYPE article_id_tbl_type IS TABLE OF OKC_ARTICLES_ALL.article_id%type INDEX BY BINARY_INTEGER;
TYPE article_tbl_type IS TABLE OF article_rec_type INDEX BY BINARY_INTEGER;
TYPE organize_tbl_type IS TABLE OF organize_rec_type INDEX BY BINARY_INTEGER;
TYPE merge_review_tbl_type IS TABLE OF merge_review_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE create_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_mode                         IN VARCHAR2 := 'NORMAL',
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_ref_type                     IN VARCHAR2 := 'SECTION', -- 'ARTICLE' or 'SECTION'
    p_ref_id                       IN NUMBER, --Id of okc_sections_b or okc_articles_b depending upon ref type
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_kart_tbl                     IN kart_tbl_type,
    x_kart_tbl                     OUT NOCOPY kart_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    );

PROCEDURE update_article_variable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_art_var_tbl                  IN art_var_tbl_type,
    p_mode                         IN VARCHAR2 := 'NORMAL',
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lock_terms_yn                IN VARCHAR2 := 'N'
    );

PROCEDURE update_structure(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_structure_tbl                IN structure_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    );

PROCEDURE sync_doc_with_expert(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_doc_type	                   IN VARCHAR2,
    p_doc_id	                   IN NUMBER,
    p_article_id_tbl	           IN article_id_tbl_type,
    p_mode                         IN VARCHAR2 := 'NORMAL',
    x_articles_dropped             OUT NOCOPY NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lock_terms_yn                IN VARCHAR2 := 'N'
    );

PROCEDURE refresh_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                         IN VARCHAR2 :='NORMAL',
    p_doc_type	                   IN VARCHAR2,
    p_doc_id	                   IN NUMBER,
    p_article_tbl	           IN article_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lock_terms_yn                IN VARCHAR2 := 'N'
    );

PROCEDURE organize_layout(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_organize_tbl                 IN ORGANIZE_TBL_TYPE,
    p_ref_point                    IN VARCHAR2 := 'A',  -- Possible values
                                       -- 'A'=After,'B'=Before,'S' = Subsection
    p_doc_type                     IN  VARCHAR2,
    p_doc_id                       IN  NUMBER,
    p_to_object_type               IN  VARCHAR2,
    p_to_object_id                 IN  NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    );

PROCEDURE merge_review_clauses(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_merge_review_tbl             IN MERGE_REVIEW_TBL_TYPE,
    p_doc_type                     IN  VARCHAR2,
    p_doc_id                       IN  NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    );

PROCEDURE sort_clauses(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_doc_type                     IN  VARCHAR2,
    p_doc_id                       IN  NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    );

END OKC_TERMS_MULTIREC_GRP;

/
