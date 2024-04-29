--------------------------------------------------------
--  DDL for Package OKC_CLM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CLM_PKG" AUTHID CURRENT_USER AS
/* $Header: OKCCLMPS.pls 120.0.12010000.6 2011/01/17 15:38:56 kkolukul noship $ */

TYPE var_value_rec_type IS RECORD (
  variable_code            VARCHAR2(30),
  variable_value_id        VARCHAR2(2500)
);

TYPE udf_var_value_tbl_type IS TABLE OF var_value_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE get_user_defined_variables (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           IN  VARCHAR2,
    p_doc_id             IN  NUMBER,
    p_org_id             IN  NUMBER,
    p_intent             IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_udf_var_value_tbl  OUT NOCOPY okc_xprt_xrule_values_pvt.udf_var_value_tbl_type
);

PROCEDURE get_udv_with_procedures (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           IN  VARCHAR2,
    p_doc_id             IN  NUMBER,
    p_org_id             IN  NUMBER,
    p_intent             IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_udf_var_value_tbl  OUT NOCOPY okc_xprt_xrule_values_pvt.udf_var_value_tbl_type
);

PROCEDURE get_clm_udv (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           IN  VARCHAR2,
    p_doc_id             IN  NUMBER,
    p_org_id             IN  NUMBER,
    p_intent             IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_udf_var_value_tbl  OUT NOCOPY okc_xprt_xrule_values_pvt.udf_var_value_tbl_type
);

PROCEDURE set_clm_udv(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_document_type     IN  VARCHAR2,
    p_document_id       IN  NUMBER,
    p_output_error	IN  VARCHAR2 :=  FND_API.G_TRUE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER
  );

PROCEDURE get_default_scn_code (
 p_api_version        IN  NUMBER,
 p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
 p_article_id IN NUMBER,
 p_article_version_id IN NUMBER,
 p_doc_id IN NUMBER,
 p_doc_type IN VARCHAR2,
 x_default_scn_code OUT NOCOPY OKC_SECTIONS_B.SCN_CODE%TYPE,
 x_return_status      OUT NOCOPY VARCHAR2
 );

PROCEDURE get_system_variables (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    p_doc_type           IN  VARCHAR2,
    p_doc_id             IN  NUMBER,
    p_only_doc_variables IN  VARCHAR2 := FND_API.G_TRUE,
    x_sys_var_value_tbl  OUT NOCOPY okc_xprt_xrule_values_pvt.var_value_tbl_type
);

PROCEDURE clm_remove_dup_scn_art( p_document_type   IN   VARCHAR2,
                                  p_document_id     IN   NUMBER,
                                  x_return_status   OUT  NOCOPY VARCHAR2,
                                  x_msg_data        OUT  NOCOPY VARCHAR2,
                                  x_msg_count       OUT  NOCOPY NUMBER);

PROCEDURE clm_remove_dup_articles( p_document_type   IN   VARCHAR2,
                                  p_document_id     IN   NUMBER,
                                  x_return_status   OUT  NOCOPY VARCHAR2,
                                  x_msg_data        OUT  NOCOPY VARCHAR2,
                                  x_msg_count       OUT  NOCOPY NUMBER);

PROCEDURE clm_remove_dup_sections( p_document_type   IN   VARCHAR2,
                                  p_document_id     IN   NUMBER,
                                  x_return_status   OUT  NOCOPY VARCHAR2,
                                  x_msg_data        OUT  NOCOPY VARCHAR2,
                                  x_msg_count       OUT  NOCOPY NUMBER);

PROCEDURE insert_usages_row( p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER,
    p_doc_numbering_scheme   IN NUMBER,
    p_document_number        IN VARCHAR2,
    p_article_effective_date IN DATE,
    p_config_header_id       IN NUMBER,
    p_config_revision_number IN NUMBER,
    p_valid_config_yn        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1 IN NUMBER := NULL,
    p_orig_system_reference_id2 IN NUMBER := NULL,
    p_lock_terms_flag        IN VARCHAR2 := NULL,
    p_locked_by_user_id      IN NUMBER := NULL,
    p_primary_template         IN VARCHAR2 := 'N',
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER);

PROCEDURE Delete_Usages_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_object_version_number  IN NUMBER);

FUNCTION check_dup_templates( p_document_type          IN VARCHAR2,
                               p_document_id            IN NUMBER,
                               p_template_id            IN NUMBER)
RETURN VARCHAR2;

PROCEDURE copy_usages_row(
                      p_target_doc_type         IN      VARCHAR2,
                      p_source_doc_type         IN      VARCHAR2,
                      p_target_doc_id           IN      NUMBER,
                      p_source_doc_id           IN      NUMBER,
                      x_return_status           OUT NOCOPY VARCHAR2,
                      x_msg_data                OUT NOCOPY VARCHAR2,
                      x_msg_count               OUT NOCOPY NUMBER);


END OKC_CLM_PKG;

/
