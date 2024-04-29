--------------------------------------------------------
--  DDL for Package OKC_IMP_TERMS_TEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_IMP_TERMS_TEMPLATES_PUB" 
/*$Header: OKCPITTS.pls 120.0.12010000.3 2011/05/27 10:32:49 serukull noship $*/
AUTHID CURRENT_USER AS
   PROCEDURE create_template (
      p_template_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.terms_template_tbl_type,
      p_commit         IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_article (
      p_article_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.k_article_tbl_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_section (
      p_section_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.section_tbl_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_deliverable (
      p_deliverable_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.deliverable_tbl_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE update_template( p_template_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.terms_template_tbl_type,
                              p_commit         IN              VARCHAR2 := fnd_api.g_false
                             );

   PROCEDURE create_template_revision (
      p_template_id         IN              NUMBER,
      p_copy_deliverables   IN              VARCHAR2 DEFAULT 'Y',
      p_commit              IN              VARCHAR2 := fnd_api.g_false,
      x_new_template_id     OUT NOCOPY      NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER
   );

   PROCEDURE delete_articles (
      p_template_id        IN              NUMBER,
      p_k_article_id_tbl   IN              okc_imp_terms_templates_pvt.k_article_id_tbl_type,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      x_k_article_id_tbl   OUT NOCOPY      okc_imp_terms_templates_pvt.k_article_id_tbl_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_data           OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_sections (
      p_template_id      IN              NUMBER,
      p_section_id_tbl   IN              okc_imp_terms_templates_pvt.section_id_tbl_type,
      p_commit           IN              VARCHAR2 := fnd_api.g_false,
      x_section_id_tbl   OUT NOCOPY      okc_imp_terms_templates_pvt.section_id_tbl_type,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_data         OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_deliverables (
      p_template_id          IN              NUMBER,
      p_deliverable_id_tbl   IN              okc_imp_terms_templates_pvt.deliverable_id_tbl_type,
      p_commit               IN              VARCHAR2 := fnd_api.g_false,
      x_deliverable_id_tbl   OUT NOCOPY      okc_imp_terms_templates_pvt.deliverable_id_tbl_type,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2
   );

   -- Template Usages --
   PROCEDURE create_tmpl_usage (
      p_template_id       IN NUMBER,
      p_tmpl_usage_tbl    IN OUT NOCOPY   okc_imp_terms_templates_pvt.tmpl_usage_tbl_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE update_tmpl_usage(
      p_template_id      IN NUMBER ,
      p_tmpl_usage_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.tmpl_usage_tbl_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE delete_tmpl_usage (
      p_template_id      IN NUMBER ,
      p_tmpl_usage_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.tmpl_usage_tbl_type,
      p_commit           IN VARCHAR2 := fnd_api.g_false
                                );
END okc_imp_terms_templates_pub;

/
