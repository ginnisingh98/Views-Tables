--------------------------------------------------------
--  DDL for Package OKC_K_ART_VARIABLES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_ART_VARIABLES_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGVARS.pls 120.0.12010000.3 2013/10/07 07:04:29 skavutha ship $ */

Procedure update_article_var_values(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                       IN VARCHAR2 :='NORMAL', -- Other value 'AMEND'
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_cat_id                     IN NUMBER,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := NULL,
    p_variable_code              IN VARCHAR2,
    p_variable_value_id          IN VARCHAR2,
    p_variable_value             IN VARCHAR2,
    p_lock_terms_yn              IN VARCHAR2 := 'N');

Procedure update_global_var_values(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                       IN VARCHAR2 :='NORMAL', -- Other value 'AMEND'
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_variable_code              IN VARCHAR2,
    p_global_variable_value_id   IN VARCHAR2,
    p_global_variable_value      IN VARCHAR2,
    p_lock_terms_yn              IN VARCHAR2 := 'N'
);

Procedure update_local_var_values(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                       IN VARCHAR2 :='NORMAL', -- Other value 'AMEND'
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_cat_id                     IN NUMBER,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := NULL,
    p_variable_code              IN VARCHAR2,
    p_variable_value_id          IN VARCHAR2,
    p_variable_value             IN VARCHAR2,
    p_override_global_yn         IN VARCHAR2,
    p_lock_terms_yn              IN VARCHAR2 := 'N');


Procedure update_response_var_values(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string          IN VARCHAR2,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                       IN VARCHAR2 :='NORMAL', -- Other value 'AMEND'
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_doc_type                   IN VARCHAR2,
    p_doc_id                     IN NUMBER,
    p_old_cat_id                 IN NUMBER,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := NULL,
    p_variable_code              IN VARCHAR2,
    p_variable_value_id          IN VARCHAR2,
    p_variable_value             IN VARCHAR2,
    p_override_global_yn         IN VARCHAR2);

PROCEDURE get_new_cat_id (
      p_old_cat_id               IN VARCHAR2,
      p_new_doc_type             IN VARCHAR2,
      p_new_doc_id               IN VARCHAR2,
      p_new_cat_id               OUT NOCOPY VARCHAR2
);



END OKC_K_ART_VARIABLES_GRP;

/
