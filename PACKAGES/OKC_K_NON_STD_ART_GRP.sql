--------------------------------------------------------
--  DDL for Package OKC_K_NON_STD_ART_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_NON_STD_ART_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGNSAS.pls 120.1.12010000.3 2011/12/09 13:36:28 serukull ship $ */

Procedure create_non_std_article(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                       IN VARCHAR2 :='NORMAL', -- Other value 'AMEND'
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_article_title              IN VARCHAR2,
    p_article_type               IN VARCHAR2 := NULL,

-- Article Version Attributes
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	  p_article_text_in_word       IN BLOB DEFAULT NULL,

-- K Article Attributes
    p_ref_type                   IN VARCHAR2 := 'SECTION', -- 'ARTICLE' or 'SECTION'
    p_ref_id                     IN NUMBER, -- Id of okc_sections_b or okc_articles_b depending upon ref type
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_cat_id                     IN NUMBER := NULL, -- Should be passed when exsisitng std is modified to make non-std.If it is passed then ref_type and ref_id doesnt need to be passed.

    p_amendment_description      IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := NULL,
    x_cat_id                     OUT NOCOPY NUMBER,
    x_article_version_id         OUT NOCOPY NUMBER,
    p_lock_terms_yn              IN  VARCHAR2 := 'N'
    );

Procedure update_non_std_article(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                       IN VARCHAR2 :='NORMAL', -- Other value 'AMEND'
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_article_title              IN VARCHAR2,
    p_article_type               IN VARCHAR2 := NULL,

-- Article Version Attributes
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_display_name               IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	  p_article_text_in_word       IN BLOB DEFAULT NULL,

-- K Article Attributes
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_cat_id                     IN NUMBER,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := NULL,
    x_cat_id                     OUT NOCOPY NUMBER,
    x_article_version_id         OUT NOCOPY NUMBER,
    p_lock_terms_yn              IN  VARCHAR2 := 'N'
    ) ;

Procedure revert_to_standard(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2,
    p_mode                       IN VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_k_art_id                   IN NUMBER,
    x_cat_id                     OUT NOCOPY NUMBER,
    x_article_version_id         OUT NOCOPY NUMBER,
    p_lock_terms_yn              IN  VARCHAR2 := 'N'
    );

END OKC_K_NON_STD_ART_GRP;

/
