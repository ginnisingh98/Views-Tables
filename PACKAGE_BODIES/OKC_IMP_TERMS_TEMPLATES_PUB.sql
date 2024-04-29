--------------------------------------------------------
--  DDL for Package Body OKC_IMP_TERMS_TEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_IMP_TERMS_TEMPLATES_PUB" 
/*$Header: OKCPITTB.pls 120.0.12010000.3 2011/05/27 10:32:01 serukull noship $*/
AS
   PROCEDURE create_template (
      p_template_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.terms_template_tbl_type,
      p_commit         IN              VARCHAR2 := fnd_api.g_false
   )
   IS
   BEGIN
      okc_imp_terms_templates_pvt.create_template
                                           (p_template_tbl      => p_template_tbl,
                                            p_commit            => p_commit
                                           );
   END create_template;

   PROCEDURE create_article (
      p_article_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.k_article_tbl_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   )
   IS
   BEGIN
      okc_imp_terms_templates_pvt.create_article
                                             (p_article_tbl      => p_article_tbl,
                                              p_commit           => p_commit
                                             );
   END create_article;

   PROCEDURE create_section (
      p_section_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.section_tbl_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   )
   IS
   BEGIN
      okc_imp_terms_templates_pvt.create_section
                                             (p_section_tbl      => p_section_tbl,
                                              p_commit           => p_commit
                                             );
   END create_section;

   PROCEDURE create_deliverable (
      p_deliverable_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.deliverable_tbl_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   )
   IS
   BEGIN
      okc_imp_terms_templates_pvt.create_deliverable
                                     (p_deliverable_tbl      => p_deliverable_tbl,
                                      p_commit               => p_commit
                                     );
   END create_deliverable;

   PROCEDURE update_template( p_template_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.terms_template_tbl_type,
                              p_commit         IN              VARCHAR2 := fnd_api.g_false
                             )
   IS
   BEGIN
      okc_imp_terms_templates_pvt.update_template(p_template_tbl => p_template_tbl,
                                                  p_commit       =>  p_commit
                                                  );
   END  update_template;


   PROCEDURE create_template_revision (
      p_template_id         IN              NUMBER,
      p_copy_deliverables   IN              VARCHAR2 DEFAULT 'Y',
      p_commit              IN              VARCHAR2 := fnd_api.g_false,
      x_new_template_id     OUT NOCOPY      NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER
   )
   IS
   BEGIN
      okc_imp_terms_templates_pvt.create_template_revision
                                 (p_template_id            => p_template_id,
                                  p_copy_deliverables      => p_copy_deliverables,
                                  p_commit                 => p_commit,
                                  x_new_template_id        => x_new_template_id,
                                  x_return_status          => x_return_status,
                                  x_msg_data               => x_msg_data,
                                  x_msg_count              => x_msg_count
                                 );
   END create_template_revision;

   PROCEDURE delete_articles (
      p_template_id        IN              NUMBER,
      p_k_article_id_tbl   IN              okc_imp_terms_templates_pvt.k_article_id_tbl_type,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      x_k_article_id_tbl   OUT NOCOPY      okc_imp_terms_templates_pvt.k_article_id_tbl_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN
      okc_imp_terms_templates_pvt.delete_articles
                                   (p_template_id           => p_template_id,
                                    p_k_article_id_tbl      => p_k_article_id_tbl,
                                    p_commit                => p_commit,
                                    x_k_article_id_tbl      => x_k_article_id_tbl,
                                    x_return_status         => x_return_status,
                                    x_msg_data              => x_msg_data
                                   );
   END delete_articles;

   PROCEDURE delete_sections (
      p_template_id      IN              NUMBER,
      p_section_id_tbl   IN              okc_imp_terms_templates_pvt.section_id_tbl_type,
      p_commit           IN              VARCHAR2 := fnd_api.g_false,
      x_section_id_tbl   OUT NOCOPY      okc_imp_terms_templates_pvt.section_id_tbl_type,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_data         OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN
      okc_imp_terms_templates_pvt.delete_sections
                                       (p_template_id         => p_template_id,
                                        p_section_id_tbl      => p_section_id_tbl,
                                        p_commit              => p_commit,
                                        x_section_id_tbl      => x_section_id_tbl,
                                        x_return_status       => x_return_status,
                                        x_msg_data            => x_msg_data
                                       );
   END delete_sections;

   PROCEDURE delete_deliverables (
      p_template_id          IN              NUMBER,
      p_deliverable_id_tbl   IN              okc_imp_terms_templates_pvt.deliverable_id_tbl_type,
      p_commit               IN              VARCHAR2 := fnd_api.g_false,
      x_deliverable_id_tbl   OUT NOCOPY      okc_imp_terms_templates_pvt.deliverable_id_tbl_type,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN
      okc_imp_terms_templates_pvt.delete_deliverables
                               (p_template_id             => p_template_id,
                                p_deliverable_id_tbl      => p_deliverable_id_tbl,
                                p_commit                  => p_commit,
                                x_deliverable_id_tbl      => x_deliverable_id_tbl,
                                x_return_status           => x_return_status,
                                x_msg_data                => x_msg_data
                               );
   END delete_deliverables;
      -- Template Usages --
   PROCEDURE create_tmpl_usage (
      p_template_id       IN NUMBER,
      p_tmpl_usage_tbl    IN OUT NOCOPY   okc_imp_terms_templates_pvt.tmpl_usage_tbl_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   )
   IS
   BEGIN
       okc_imp_terms_templates_pvt.create_tmpl_usage( p_template_id =>  p_template_id,
                                                      p_tmpl_usage_tbl => p_tmpl_usage_tbl,
                                                      p_commit  => p_commit
                                                     );
   END create_tmpl_usage;

   PROCEDURE update_tmpl_usage(
      p_template_id      IN NUMBER ,
      p_tmpl_usage_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.tmpl_usage_tbl_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   )
   IS
   BEGIN
        okc_imp_terms_templates_pvt.update_tmpl_usage( p_template_id =>  p_template_id,
                                                      p_tmpl_usage_tbl => p_tmpl_usage_tbl,
                                                      p_commit  => p_commit
                                                     );
   END  update_tmpl_usage;

   PROCEDURE delete_tmpl_usage (
      p_template_id      IN NUMBER ,
      p_tmpl_usage_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.tmpl_usage_tbl_type,
      p_commit           IN VARCHAR2 := fnd_api.g_false
                                )
   IS
   BEGIN
      okc_imp_terms_templates_pvt.delete_tmpl_usage( p_template_id =>  p_template_id,
                                                      p_tmpl_usage_tbl => p_tmpl_usage_tbl,
                                                      p_commit  => p_commit
                                                     );

  END  delete_tmpl_usage;


END okc_imp_terms_templates_pub;

/
