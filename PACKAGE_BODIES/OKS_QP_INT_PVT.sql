--------------------------------------------------------
--  DDL for Package Body OKS_QP_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_QP_INT_PVT" AS
/* $Header: OKSQPRQB.pls 120.17 2006/09/12 18:38:52 gpriya noship $ */

------------------------------------------------------------------------------
-- GLOBAL CONSTANTS
------------------------------------------------------------------------------
   g_module                       CONSTANT VARCHAR2 (250)
                                         := 'oks.plsql.pricing.' ||
                                            g_pkg_name ||
                                            '.';
   l_api_version                  CONSTANT NUMBER := 1.0;
   l_init_msg_list                CONSTANT VARCHAR2 (1) := 'F';

   FUNCTION get_line_no (
      p_line_id                       IN       NUMBER
   )
      RETURN VARCHAR2
   IS
      l_api_name                     CONSTANT VARCHAR2 (30) := 'get_line_no';

      CURSOR l_line_details_csr (
         p_line_id                                NUMBER
      )
      IS
         SELECT lse_id,
                line_number
           FROM okc_k_lines_b
          WHERE ID = p_line_id;

      CURSOR l_line_no_csr (
         p_subline_id                             NUMBER
      )
      IS
         SELECT b.line_number ||
                '.' ||
                a.line_number line_no
           FROM okc_k_lines_b a,
                okc_k_lines_b b
          WHERE a.ID = p_subline_id
            AND a.cle_id = b.ID;

      l_lse_id                                NUMBER;
      l_line_number                           VARCHAR2 (300);
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      OPEN l_line_details_csr (p_line_id);

      FETCH l_line_details_csr
       INTO l_lse_id,
            l_line_number;

      IF l_line_details_csr%NOTFOUND
      THEN
         CLOSE l_line_details_csr;

         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '1000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         RETURN NULL;
      END IF;

      CLOSE l_line_details_csr;

      IF l_lse_id = 46
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '1000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         RETURN l_line_number;
      ELSIF l_lse_id IN (7, 9, 25)
      THEN
         OPEN l_line_no_csr (p_line_id);

         FETCH l_line_no_csr
          INTO l_line_number;

         IF l_line_no_csr%NOTFOUND
         THEN
            CLOSE l_line_no_csr;

            -- end debug log
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '1000: Leaving ' ||
                               g_pkg_name ||
                               '.' ||
                               l_api_name
                              );
            END IF;

            RETURN NULL;
         END IF;

         CLOSE l_line_no_csr;

         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '1000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         RETURN l_line_number;
      ELSE
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '1000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         RETURN NULL;
      END IF;
   END;

  -- Function to get discount amount for sublines or subscription lines
  FUNCTION get_subline_discount(p_subline_id IN NUMBER) RETURN NUMBER IS
    CURSOR cs_subline_discount (cp_subline_id IN NUMBER) IS
      SELECT kle.lse_id,
             (NVL(cleb.toplvl_adj_price,0) - NVL(kle.line_list_price,0)) * cleb.toplvl_price_qty discount
      FROM okc_k_lines_b kle,
           oks_k_lines_b cleb
      WHERE kle.ID = cp_subline_id
        AND kle.ID = cleb.cle_id
        AND NVL(kle.line_list_price, 0) > NVL(cleb.toplvl_adj_price,0);
    CURSOR cs_subline_qty (cp_subline_id IN NUMBER) IS
      SELECT number_of_items subline_qty
      FROM okc_k_items
      WHERE cle_id = cp_subline_id;
    l_api_name    CONSTANT VARCHAR2 (30) := 'get_subline_discount';
    l_discount    NUMBER := 0;
    l_subline_qty NUMBER := 0;
    l_lse_id      NUMBER;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,
                     g_module||l_api_name,
                     'Entered '||g_pkg_name||'.'||l_api_name);
    END IF;

    OPEN cs_subline_discount (p_subline_id);
    FETCH cs_subline_discount INTO l_lse_id, l_discount;
    CLOSE cs_subline_discount;
    IF l_lse_id <> 46 THEN
      OPEN cs_subline_qty (p_subline_id);
      FETCH cs_subline_qty INTO l_subline_qty;
      CLOSE cs_subline_qty;
      l_discount  := l_discount * l_subline_qty;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,
                     g_module||l_api_name,
                     'Leaving '||g_pkg_name||'.'||l_api_name);
    END IF;

    RETURN ROUND (l_discount, 29);
  END get_subline_discount;

  -- Function to get surcharge amount for sublines or subscription lines
  FUNCTION get_subline_surcharge(p_subline_id IN NUMBER) RETURN NUMBER IS
    CURSOR cs_subline_surcharge(cp_subline_id IN NUMBER) IS
      SELECT kle.lse_id,
             (NVL(cleb.toplvl_adj_price,0) - NVL(kle.line_list_price,0)) * cleb.toplvl_price_qty surcharge
      FROM okc_k_lines_b kle,
           oks_k_lines_b cleb
      WHERE kle.ID = cp_subline_id
        AND kle.ID = cleb.cle_id
        AND NVL (kle.line_list_price, 0) < NVL (cleb.toplvl_adj_price, 0);
    CURSOR cs_subline_qty(cp_subline_id IN NUMBER) IS
      SELECT number_of_items subline_qty
      FROM okc_k_items
      WHERE cle_id = cp_subline_id;
    l_api_name    CONSTANT VARCHAR2(30):= 'get_subline_surcharge';
    l_surcharge   NUMBER := 0;
    l_subline_qty NUMBER := 0;
    l_lse_id      NUMBER;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_module||l_api_name,
                     'Entered '||g_pkg_name||'.'||l_api_name);
    END IF;

    OPEN cs_subline_surcharge (p_subline_id);
    FETCH cs_subline_surcharge INTO l_lse_id, l_surcharge;
    CLOSE cs_subline_surcharge;
    IF l_lse_id <> 46 THEN
      OPEN cs_subline_qty (p_subline_id);
      FETCH cs_subline_qty INTO l_subline_qty;
      CLOSE cs_subline_qty;
      l_surcharge := l_surcharge * l_subline_qty;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_module||l_api_name,
                     'Leaving '||g_pkg_name ||'.' ||l_api_name);
    END IF;

    RETURN ROUND (l_surcharge, 29);
  END;

-- function to get topline discount
   FUNCTION get_topline_discount (
      p_topline_id                    IN       NUMBER
   )
      RETURN NUMBER
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                    := 'GET_TOPLINE_DISCOUNT';

      CURSOR cs_subline (
         cp_cle_id                                NUMBER
      )
      IS
         SELECT ID,
                lse_id
           FROM okc_k_lines_b
          WHERE cle_id = cp_cle_id;

      l_lse_id                                NUMBER;
      l_topline_discount                      NUMBER;
      l_topline_yn                            VARCHAR2 (1) := 'N';
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      --   open cs_topline(p_topline_id);
      --   fetch cs_topline into l_lse_id;
      --   if l_lse_id = '46' -- subcription line then
      --   then
      --     l_topline_discount := get_subscrp_discount(p_topline_id);
      --   else -- calculate for it's subline.
      l_topline_discount         := 0;

      FOR l_subline IN cs_subline (p_topline_id)
      LOOP
         l_topline_yn               := 'Y';
         l_topline_discount         :=
                     l_topline_discount +
                     get_subline_discount (l_subline.ID);
      END LOOP;

      IF l_topline_yn = 'N'
      THEN
         l_topline_discount         := get_subline_discount (p_topline_id);
      END IF;

      --   end if;

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      RETURN ROUND (l_topline_discount, 29);
   END;

-- function to get topline surcharge
   FUNCTION get_topline_surcharge (
      p_topline_id                    IN       NUMBER
   )
      RETURN NUMBER
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                   := 'GET_TOPLINE_SURCHARGE';

      CURSOR cs_subline (
         cp_cle_id                                NUMBER
      )
      IS
         SELECT ID,
                lse_id
           FROM okc_k_lines_b
          WHERE cle_id = cp_cle_id;

      l_lse_id                                NUMBER;
      l_topline_surcharge                     NUMBER;
      l_topline_yn                            VARCHAR2 (1) := 'N';
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      --   open cs_topline(p_topline_id);
      --   fetch cs_topline into l_lse_id;
      --   if l_lse_id = '46' -- subcription line then
      --   then
      --     l_topline_surcharge := get_subscrp_surcharge(p_topline_id);
      --   else -- calculate for it's subline.
      l_topline_surcharge        := 0;

      FOR l_subline IN cs_subline (p_topline_id)
      LOOP
         l_topline_yn               := 'Y';
         l_topline_surcharge        :=
                   l_topline_surcharge +
                   get_subline_surcharge (l_subline.ID);
      END LOOP;

      IF l_topline_yn = 'N'
      THEN
         l_topline_surcharge        := get_subline_surcharge (p_topline_id);
      END IF;

      --   end if;
              -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      RETURN ROUND (l_topline_surcharge, 29);
   END;

/** 3912685 **/
   PROCEDURE check_pricing_eligibility (
      p_line_id                       IN       NUMBER,
      x_status                        OUT NOCOPY VARCHAR2,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER,
      x_msg_data                      OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                               := 'CHECK_PRICING_ELIGIBILITY';

      CURSOR l_line_csr (
         p_line_id                                NUMBER
      )
      IS
         SELECT lse_id,
                start_date,
                end_date,
                date_terminated,
                dnz_chr_id
           FROM okc_k_lines_b
          WHERE ID = p_line_id;

      l_line_rec                              l_line_csr%ROWTYPE;
      l_kln_rec_in                            oks_contract_line_pub.klnv_rec_type;
      l_kln_rec_out                           oks_contract_line_pub.klnv_rec_type;
      l_k_det_rec                             k_details_rec;
--   l_rule_rec           OKC_RUL_PVT.rulv_rec_type;
      l_billed_date                           DATE;
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      x_return_status            := g_ret_sts_success;

      OPEN l_line_csr (p_line_id);

      FETCH l_line_csr
       INTO l_line_rec;

      IF l_line_csr%NOTFOUND
      THEN
         CLOSE l_line_csr;

         x_return_status            := g_ret_sts_error;
         RAISE g_exc_error;
      END IF;

      CLOSE l_line_csr;

      IF l_line_rec.lse_id = g_subscription
      THEN
         l_billed_date              :=
            oks_bill_util_pub.get_billed_upto (p_id                               => p_line_id,
                                               p_level                            => 'T');
      ELSE
         l_billed_date              :=
            oks_bill_util_pub.get_billed_upto (p_id                               => p_line_id,
                                               p_level                            => 'S');
      END IF;

      /** Bug 4194843 **/
      x_status                   := g_oks_success;

      IF l_billed_date IS NOT NULL
      THEN
         /** Bug 4194843 **/
         IF NVL (l_line_rec.date_terminated, l_line_rec.end_date) <
                                   NVL (l_billed_date, l_line_rec.start_date)
         THEN
            x_status                   := g_partial_billed;
            get_k_details (p_id                               => p_line_id,
                           p_type                             => g_oks_line,
                           x_k_det_rec                        => l_k_det_rec
                          );
            l_kln_rec_in.ID            := l_k_det_rec.ID;
            l_kln_rec_in.status_text   := g_billed_line;
            l_kln_rec_in.object_version_number :=
                                             l_k_det_rec.object_version_number;
            oks_contract_line_pub.update_line
                                          (p_api_version                      => l_api_version,
                                           p_init_msg_list                    => l_init_msg_list,
                                           x_return_status                    => x_return_status,
                                           x_msg_count                        => x_msg_count,
                                           x_msg_data                         => x_msg_data,
                                           p_klnv_rec                         => l_kln_rec_in,
                                           x_klnv_rec                         => l_kln_rec_out,
                                           p_validate_yn                      => 'N'
                                          );

            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;
         ELSIF trunc(NVL (l_line_rec.date_terminated, l_line_rec.end_date)) =
                                    trunc(NVL (l_billed_date, l_line_rec.start_date))
         THEN
            x_status                   := g_fully_billed;
            get_k_details (p_id                               => p_line_id,
                           p_type                             => g_oks_line,
                           x_k_det_rec                        => l_k_det_rec
                          );
            l_kln_rec_in.ID            := l_k_det_rec.ID;
            l_kln_rec_in.status_text   := g_billed_line;
            l_kln_rec_in.object_version_number :=
                                             l_k_det_rec.object_version_number;
            oks_contract_line_pub.update_line
                                          (p_api_version                      => l_api_version,
                                           p_init_msg_list                    => l_init_msg_list,
                                           x_return_status                    => x_return_status,
                                           x_msg_count                        => x_msg_count,
                                           x_msg_data                         => x_msg_data,
                                           p_klnv_rec                         => l_kln_rec_in,
                                           x_klnv_rec                         => l_kln_rec_out,
                                           p_validate_yn                      => 'N'
                                          );
         ELSE
            x_status                   := g_oks_success;
         END IF;
      /** Bug 4194843 **/
      END IF;
   /** Bug 4194843 **/
   EXCEPTION
      WHEN g_exc_error
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '2000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         NULL;
      WHEN OTHERS
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status            := g_ret_sts_error;

         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '1000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;
   END check_pricing_eligibility;

/**  **/
   PROCEDURE get_modifier_details (
      p_api_version                   IN       NUMBER,
      p_init_msg_list                 IN       VARCHAR2,
      p_chr_id                        IN       NUMBER,
      p_cle_id                        IN       VARCHAR2,
      x_modifiers_tbl                 OUT NOCOPY price_modifiers_tbl,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER,
      x_msg_data                      OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                    := 'GET_MODIFIER_DETAILS';

      CURSOR cs_hdr_line
      IS
         SELECT ID
           FROM okc_k_lines_b
          WHERE dnz_chr_id = p_chr_id
            AND cle_id IS NULL;

      l_line_discount                         NUMBER;
      l_line_surcharge                        NUMBER;
      l_hdr_discount                          NUMBER;
      l_hdr_surcharge                         NUMBER;
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      x_return_status            := g_ret_sts_success;

      IF p_cle_id IS NOT NULL
      THEN
         x_modifiers_tbl (1).discount := get_topline_discount (p_cle_id);
         x_modifiers_tbl (1).surcharge := get_topline_surcharge (p_cle_id);
      ELSIF p_chr_id IS NOT NULL
      THEN
         l_hdr_discount             := 0;
         l_hdr_surcharge            := 0;

         FOR l_hdr_line_rec IN cs_hdr_line
         LOOP
            l_hdr_discount             :=
                    l_hdr_discount +
                    get_topline_discount (l_hdr_line_rec.ID);
            l_hdr_surcharge            :=
                   l_hdr_surcharge +
                   get_topline_surcharge (l_hdr_line_rec.ID);
         END LOOP;

         x_modifiers_tbl (1).discount := l_hdr_discount;
         x_modifiers_tbl (1).surcharge := l_hdr_surcharge;
      ELSE
         x_modifiers_tbl (1).discount := NULL;
         x_modifiers_tbl (1).surcharge := NULL;
         x_modifiers_tbl (1).total  := NULL;
         x_return_status            := g_ret_sts_error;
         RAISE g_exc_error;
      END IF;

      x_modifiers_tbl (1).total  :=
                  x_modifiers_tbl (1).surcharge +
                  x_modifiers_tbl (1).discount;

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '5000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         x_modifiers_tbl (1).discount := 0;
         x_modifiers_tbl (1).surcharge := 0;
         x_modifiers_tbl (1).total  := 0;
      WHEN g_exc_error
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '2000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         NULL;
      WHEN OTHERS
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status            := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name                         => g_app_name,
                              p_msg_name                         => g_unexpected_error,
                              p_token1                           => g_sqlcode_token,
                              p_token1_value                     => SQLCODE,
                              p_token2                           => g_sqlerrm_token,
                              p_token2_value                     => SQLERRM
                             );
   END get_modifier_details;

   PROCEDURE get_k_details (
      p_id                            IN       NUMBER,
      p_type                          IN       VARCHAR2,
      x_k_det_rec                     OUT NOCOPY k_details_rec
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                           := 'GET_K_DETAILS';

      CURSOR l_okc_chr_csr (
         p_id                                     NUMBER
      )
      IS
         SELECT ID,
                object_version_number
           FROM okc_k_headers_all_b
          WHERE ID = p_id;

      CURSOR l_okc_cle_csr (
         p_id                                     NUMBER
      )
      IS
         SELECT ID,
                object_version_number
           FROM okc_k_lines_b
          WHERE ID = p_id;

      CURSOR l_oks_chr_csr (
         p_id                                     NUMBER
      )
      IS
         SELECT ID,
                object_version_number
           FROM oks_k_headers_b
          WHERE chr_id = p_id;

      CURSOR l_oks_cle_csr (
         p_id                                     NUMBER
      )
      IS
         SELECT ID,
                object_version_number
           FROM oks_k_lines_b
          WHERE cle_id = p_id;
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      IF p_type = g_okc_hdr
      THEN
         OPEN l_okc_chr_csr (p_id);

         FETCH l_okc_chr_csr
          INTO x_k_det_rec;

         IF l_okc_chr_csr%NOTFOUND
         THEN
            x_k_det_rec.ID             := NULL;
            x_k_det_rec.object_version_number := NULL;
         END IF;

         CLOSE l_okc_chr_csr;
      ELSIF p_type = g_okc_line
      THEN
         OPEN l_okc_cle_csr (p_id);

         FETCH l_okc_cle_csr
          INTO x_k_det_rec;

         IF l_okc_cle_csr%NOTFOUND
         THEN
            x_k_det_rec.ID             := NULL;
            x_k_det_rec.object_version_number := NULL;
         END IF;

         CLOSE l_okc_cle_csr;
      ELSIF p_type = g_oks_hdr
      THEN
         OPEN l_oks_chr_csr (p_id);

         FETCH l_oks_chr_csr
          INTO x_k_det_rec;

         IF l_oks_chr_csr%NOTFOUND
         THEN
            x_k_det_rec.ID             := NULL;
            x_k_det_rec.object_version_number := NULL;
         END IF;

         CLOSE l_oks_chr_csr;
      ELSIF p_type = g_oks_line
      THEN
         OPEN l_oks_cle_csr (p_id);

         FETCH l_oks_cle_csr
          INTO x_k_det_rec;

         IF l_oks_cle_csr%NOTFOUND
         THEN
            x_k_det_rec.ID             := NULL;
            x_k_det_rec.object_version_number := NULL;
         END IF;

         CLOSE l_oks_cle_csr;
      END IF;

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   END get_k_details;

   PROCEDURE get_id (
      p_line_id                       IN       NUMBER,
      x_chr_id                        OUT NOCOPY NUMBER,
      x_topline_id                    OUT NOCOPY NUMBER,
      x_return_status                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30) := 'GET_ID';

      CURSOR l_line_csr (
         p_line_id                                NUMBER
      )
      IS
         SELECT dnz_chr_id,
                cle_id
           FROM okc_k_lines_b
          WHERE ID = p_line_id;
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      x_return_status            := g_ret_sts_success;

      OPEN l_line_csr (p_line_id);

      FETCH l_line_csr
       INTO x_chr_id,
            x_topline_id;

      IF l_line_csr%NOTFOUND
      THEN
         CLOSE l_line_csr;

         x_return_status            := g_ret_sts_error;
      END IF;

      CLOSE l_line_csr;

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         CLOSE l_line_csr;

         x_return_status            := okc_api.g_ret_sts_warning;
   END;

   FUNCTION is_subs_item (
      p_subline_id                             NUMBER
   )
      RETURN BOOLEAN
   IS
      l_api_name                     CONSTANT VARCHAR2 (30) := 'IS_SUBS_ITEM';

      CURSOR l_subscr_item_csr (
         p_subline_id                             NUMBER
      )
      IS
         SELECT 'x'
           FROM okc_k_lines_b kl,
                okc_k_items ki,
                oks_subscr_header_b sh
          WHERE kl.ID = p_subline_id
            AND ki.cle_id = kl.ID
            AND sh.instance_id = ki.object1_id1;

      l_dummy                                 VARCHAR2 (1);
      l_return                                BOOLEAN;
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      OPEN l_subscr_item_csr (p_subline_id);

      FETCH l_subscr_item_csr
       INTO l_dummy;

      IF l_subscr_item_csr%FOUND
      THEN
         l_return                   := TRUE;
      ELSE
         l_return                   := FALSE;
      END IF;

      CLOSE l_subscr_item_csr;

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      RETURN (l_return);
   END is_subs_item;

   PROCEDURE get_line_details (
      p_line_id                       IN       NUMBER,
      x_name                          OUT NOCOPY VARCHAR2,
      x_description                   OUT NOCOPY VARCHAR2,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER,
      x_msg_data                      OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                        := 'GET_LINE_DETAILS';

      CURSOR l_line_csr
      IS
         SELECT cle_id,
                lse_id,
                dnz_chr_id
           FROM okc_k_lines_b
          WHERE ID = p_line_id;

      CURSOR l_item_csr (
         c_cle_id                                 NUMBER
      )
      IS
         SELECT object1_id1,
                object1_id2
           FROM okc_k_items
          WHERE cle_id = c_cle_id;

      CURSOR l_cii_csr (
         c_instance_id                            NUMBER
      )
      IS
         SELECT inventory_item_id
           FROM csi_item_instances
          WHERE instance_id = c_instance_id;

      CURSOR l_hdr_csr (
         c_chr_id                                 NUMBER
      )
      IS
         SELECT inv_organization_id
           FROM okc_k_headers_all_b
          WHERE ID = c_chr_id;

      CURSOR l_mtl_csr (
         c_item_id                                NUMBER,
         c_inv_org_id                             NUMBER
      )
      IS
         SELECT concatenated_segments,
                description
           FROM mtl_system_items_kfv
          WHERE inventory_item_id = c_item_id
            AND organization_id = c_inv_org_id;

      l_profile_value                         VARCHAR2 (240)
                          := fnd_profile.VALUE ('OKS_ITEM_DISPLAY_PREFERENCE');
      l_cle_id                                NUMBER;
      l_lse_id                                NUMBER;
      l_dnz_chr_id                            NUMBER;
      l_inv_org_id                            NUMBER;
      l_object1_id1                           okc_k_items.object1_id1%TYPE;
      l_object1_id2                           okc_k_items.object1_id2%TYPE;
      l_inventory_item_id                     NUMBER;
      l_item_cle_id                           NUMBER;
      l_name                                  VARCHAR2 (1000);
      l_description                           VARCHAR2 (1000);
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      x_return_status            := g_ret_sts_success;

      OPEN l_line_csr;

      FETCH l_line_csr
       INTO l_cle_id,
            l_lse_id,
            l_dnz_chr_id;

      CLOSE l_line_csr;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '200:l_cle_id: ' ||
                         l_cle_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '201:l_lse_id: ' ||
                         l_lse_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '202:l_dnz_chr_id: ' ||
                         l_dnz_chr_id
                        );
      END IF;

      -- errorout('l_cle_id: ' || l_cle_id);
      -- errorout('l_lse_id: ' || l_lse_id);
      -- errorout('l_dnz_chr_id: ' || l_dnz_chr_id);
      OPEN l_hdr_csr (l_dnz_chr_id);

      FETCH l_hdr_csr
       INTO l_inv_org_id;

      CLOSE l_hdr_csr;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '203:l_inv_org_id: ' ||
                         l_inv_org_id
                        );
      END IF;

      -- errorout('l_inv_org_id: ' || l_inv_org_id);
      OPEN l_item_csr (p_line_id);

      FETCH l_item_csr
       INTO l_object1_id1,
            l_object1_id2;

      CLOSE l_item_csr;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '204:object1_id1: ' ||
                         l_object1_id1
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '205:object1_id2: ' ||
                         l_object1_id2
                        );
      END IF;

      -- errorout('object1_id1: ' || l_object1_id1);
      -- errorout('object1_id2: ' || l_object1_id2);
      IF    l_cle_id IS NULL
         OR l_lse_id = 7
      THEN
         OPEN l_mtl_csr (l_object1_id1, l_object1_id2);

         FETCH l_mtl_csr
          INTO l_name,
               l_description;

         CLOSE l_mtl_csr;
      ELSE
         OPEN l_cii_csr (l_object1_id1);

         FETCH l_cii_csr
          INTO l_inventory_item_id;

         CLOSE l_cii_csr;

         OPEN l_mtl_csr (l_inventory_item_id, l_inv_org_id);

         FETCH l_mtl_csr
          INTO l_name,
               l_description;

         CLOSE l_mtl_csr;
      END IF;

      IF l_cle_id IS NULL
      THEN
         x_name                     := l_name;
         x_description              := l_description;
      ELSE
         IF l_profile_value = 'DISPLAY_DESC'
         THEN
            x_name                     := l_description;
            x_description              := l_name;
         ELSIF l_profile_value = 'DISPLAY_NAME'
         THEN
            x_name                     := l_name;
            x_description              := l_description;
         END IF;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '206:x_name: ' ||
                         x_name
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '207:x_desc: ' ||
                         x_description
                        );
      END IF;

      -- errorout('x_name: ' || x_name);
      -- errorout('x_desc: ' || x_description);

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status            := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name                         => g_app_name,
                              p_msg_name                         => g_unexpected_error,
                              p_token1                           => g_sqlcode_token,
                              p_token1_value                     => SQLCODE,
                              p_token2                           => g_sqlerrm_token,
                              p_token2_value                     => SQLERRM
                             );
   END get_line_details;

   FUNCTION get_pricing_messages
      RETURN pricing_status_tbl
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                    := 'GET_PRICING_MESSAGES';
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      RETURN (g_pricing_status_tbl);
   END;

   FUNCTION get_amounts (
      p_id                            IN       NUMBER,
      p_level                         IN       VARCHAR2
   )
      RETURN NUMBER
   IS
      l_api_name                     CONSTANT VARCHAR2 (30) := 'GET_AMOUNTS';

      CURSOR l_line_csr (
         p_line_id                                NUMBER
      )
      IS
         SELECT SUM (price_negotiated) amount
           FROM okc_k_lines_b
          WHERE cle_id = p_line_id
            AND chr_id IS NULL
            AND lse_id IN (7, 8, 9, 10, 11, 18, 25, 35)
	    AND date_cancelled IS NULL;  -- bug 4870602

      CURSOR l_hdr_csr (
         p_chr_id                                 NUMBER
      )
      IS
         SELECT SUM (price_negotiated) amount
           FROM okc_k_lines_b
          WHERE chr_id = p_chr_id
            AND cle_id IS NULL
            AND date_cancelled IS NULL;  -- bug 4870602

      l_amount                                NUMBER := 0;
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      IF p_level = g_hdr_level
      THEN
         OPEN l_hdr_csr (p_id);

         FETCH l_hdr_csr
          INTO l_amount;

         IF l_hdr_csr%NOTFOUND
         THEN
            l_amount                   := 0;
         END IF;

         CLOSE l_hdr_csr;
      ELSIF p_level = g_line_level
      THEN
         OPEN l_line_csr (p_id);

         FETCH l_line_csr
          INTO l_amount;

         IF l_line_csr%NOTFOUND
         THEN
            l_amount                   := 0;
         END IF;

         CLOSE l_line_csr;
      ELSE
         l_amount                   := 0;
      END IF;

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      RETURN l_amount;
   END get_amounts;

   PROCEDURE qualifier_party_merge (
      p_from_fk_id                    IN       NUMBER,
      p_to_fk_id                      IN       NUMBER,
      x_return_status                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                   := 'QUALIFIER_PARTY_MERGE';
      l_count                                 NUMBER;
      l_proc_name                             VARCHAR2 (240)
                                                   := 'QUALIFIER_PARTY_MERGE';
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      x_return_status            := okc_api.g_ret_sts_success;

      UPDATE oks_qualifiers
         SET qualifier_attr_value = TO_CHAR (p_to_fk_id),
             last_update_date = hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.user_id,
             last_update_login = hz_utility_pub.last_update_login,
             request_id = hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = SYSDATE
       WHERE qualifier_attr_value = TO_CHAR (p_from_fk_id);

      l_count                    := SQL%ROWCOUNT;
      arp_message.set_name ('AR', 'AR_ROWS_UPDATED');
      arp_message.set_token ('NUM_ROWS', TO_CHAR (l_count));

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status            := fnd_api.g_ret_sts_error;
         arp_message.set_line (g_pkg_name ||
                               '.' ||
                               l_proc_name ||
                               ': ' ||
                               SQLERRM);
   END qualifier_party_merge;

   PROCEDURE qualifier_account_merge (
      req_id                                   NUMBER,
      set_num                                  NUMBER
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                 := 'QUALIFIER_ACCOUNT_MERGE';

      TYPE merge_header_id_list_type IS TABLE OF ra_customer_merge_headers.customer_merge_header_id%TYPE
         INDEX BY BINARY_INTEGER;

      merge_header_id_list                    merge_header_id_list_type;

      TYPE qualifier_id_list_type IS TABLE OF oks_qualifiers.qualifier_id%TYPE
         INDEX BY BINARY_INTEGER;

      primary_key_id1_list                    qualifier_id_list_type;

      TYPE qualifier_attr_value_list_type IS TABLE OF oks_qualifiers.qualifier_attr_value%TYPE
         INDEX BY BINARY_INTEGER;

      vchar_col1_orig_list                    qualifier_attr_value_list_type;
      vchar_col1_new_list                     qualifier_attr_value_list_type;
      l_profile_val                           VARCHAR2 (30);

      CURSOR merged_records
      IS
         SELECT DISTINCT customer_merge_header_id,
                         qualifier_id,
                         qualifier_attr_value
                    FROM oks_qualifiers yt,
                         ra_customer_merges m
                   WHERE (yt.qualifier_attr_value = m.duplicate_site_id)
                     AND m.process_flag = 'N'
                     AND m.request_id = req_id
                     AND m.set_number = set_num;

      l_last_fetch                            BOOLEAN := FALSE;
      l_count                                 NUMBER;
      l_proc_name                             VARCHAR2 (240)
                                                  := 'QUALIFIER_ACCOUNT_MERGE';
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      arp_message.set_name ('AR', 'AR_UPDATING_TABLE');
      arp_message.set_token ('TABLE_NAME',
                             'OKS_QUALIFIERS',
                             FALSE
                            );
      hz_acct_merge_util.load_set (set_num, req_id);
      l_profile_val              := fnd_profile.VALUE ('HZ_AUDIT_ACCT_MERGE');

      OPEN merged_records;

      LOOP
         FETCH merged_records
         BULK COLLECT INTO merge_header_id_list,
                primary_key_id1_list,
                vchar_col1_orig_list;

         IF merged_records%NOTFOUND
         THEN
            l_last_fetch               := TRUE;
         END IF;

         IF     merge_header_id_list.COUNT = 0
            AND l_last_fetch
         THEN
            -- end debug log
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '1000: Leaving ' ||
                               g_pkg_name ||
                               '.' ||
                               l_api_name
                              );
            END IF;

            EXIT;
         END IF;

         FOR i IN 1 .. merge_header_id_list.COUNT
         LOOP
            vchar_col1_new_list (i)    :=
                hz_acct_merge_util.getdup_site_use (vchar_col1_orig_list (i));
         END LOOP;

         IF     l_profile_val IS NOT NULL
            AND l_profile_val = 'Y'
         THEN
            FORALL i IN 1 .. merge_header_id_list.COUNT
               INSERT INTO hz_customer_merge_log
                           (merge_log_id,
                            table_name,
                            merge_header_id,
                            primary_key_id1,
                            vchar_col1_orig,
                            vchar_col1_new,
                            action_flag,
                            request_id,
                            created_by,
                            creation_date,
                            last_update_login,
                            last_update_date,
                            last_updated_by
                           )
                    VALUES (hz_customer_merge_log_s.NEXTVAL,
                            'OKS_QUALIFIERS',
                            merge_header_id_list (i),
                            primary_key_id1_list (i),
                            vchar_col1_orig_list (i),
                            vchar_col1_new_list (i),
                            'U',
                            req_id,
                            hz_utility_pub.created_by,
                            hz_utility_pub.creation_date,
                            hz_utility_pub.last_update_login,
                            hz_utility_pub.last_update_date,
                            hz_utility_pub.last_updated_by
                           );
         END IF;

         FORALL i IN 1 .. merge_header_id_list.COUNT
            UPDATE oks_qualifiers yt
               SET qualifier_attr_value = vchar_col1_new_list (i),
                   last_update_date = SYSDATE,
                   last_updated_by = arp_standard.PROFILE.user_id,
                   last_update_login = arp_standard.PROFILE.last_update_login,
                   request_id = req_id
             WHERE qualifier_id = primary_key_id1_list (i);
         l_count                    := l_count +
                                       SQL%ROWCOUNT;

         IF l_last_fetch
         THEN
            EXIT;
         END IF;
      END LOOP;

      arp_message.set_name ('AR', 'AR_ROWS_UPDATED');
      arp_message.set_token ('NUM_ROWS', TO_CHAR (l_count));

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         arp_message.set_line (g_pkg_name ||
                               '.' ||
                               l_proc_name ||
                               ': ' ||
                               SQLERRM);
         RAISE;
   END qualifier_account_merge;

   PROCEDURE calculate_subscription_price (
      p_detail_rec                    IN       oks_qp_pkg.input_details,
      x_price_details                 OUT NOCOPY oks_qp_pkg.price_details,
      x_modifier_details              OUT NOCOPY qp_preq_grp.line_detail_tbl_type,
      x_price_break_details           OUT NOCOPY oks_qp_pkg.g_price_break_tbl_type,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER,
      x_msg_data                      OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                            := 'CALCULATE_SUBSCRIPTION_PRICE';

      CURSOR l_currcode_csr (
         p_hdr_id                                 NUMBER
      )
      IS
         SELECT currency_code
           FROM okc_k_headers_all_b
          WHERE ID = p_hdr_id;

      CURSOR l_line_details_csr (
         p_cle_id                                 NUMBER
      )
      IS
         SELECT ID,
                start_date,
                end_date,
                lse_id,
                dnz_chr_id,
                price_negotiated,
                price_unit,
                price_unit_percent,
                price_list_line_id,
                price_list_id,
                line_list_price,
                item_to_price_yn,
                pricing_date,
                price_basis_yn,
                object_version_number
           FROM okc_k_lines_b
          WHERE ID = p_cle_id
            AND lse_id = 46;

      CURSOR l_subs_elements_csr (
         p_line_id                                NUMBER
      )
      IS
         SELECT ID,
                osh_id,
                dnz_chr_id,
                dnz_cle_id,
                linked_flag,
                seq_no,
                om_interface_date,
                amount,
                start_date,
                end_date,
                quantity,
                uom_code,
                order_header_id,
                order_line_id,
                object_version_number
           FROM oks_subscr_elements
          WHERE dnz_cle_id = p_line_id;

      l_line_details_rec                      l_line_details_csr%ROWTYPE;
      l_input_detail_rec                      oks_qp_pkg.input_details
                                                               := p_detail_rec;
      l_rail_rec                              oks_tax_util_pvt.ra_rec_type;
      l_k_det_rec                             k_details_rec;
      l_khdr_rec_in                           oks_contract_hdr_pub.khrv_rec_type;
      l_khdr_rec_out                          oks_contract_hdr_pub.khrv_rec_type;
      l_kln_rec_in                            oks_contract_line_pub.klnv_rec_type;
      l_kln_rec_out                           oks_contract_line_pub.klnv_rec_type;
      l_clev_rec_in                           okc_contract_pub.clev_rec_type;
      l_clev_rec_out                          okc_contract_pub.clev_rec_type;
      l_scev_rec_in                           oks_subscr_elems_pub.scev_rec_type;
      l_scev_rec_out                          oks_subscr_elems_pub.scev_rec_type;
      l_qpprod_quantity                       NUMBER;
      l_qpprod_uom_code                       VARCHAR2 (240);
      l_tlvl_name                             VARCHAR2 (800);
      l_tlvl_desc                             VARCHAR2 (1000);
      l_return_status                         VARCHAR2 (1);
      l_line_no                               VARCHAR2 (300);
      l_status                                VARCHAR2 (30);         --3912685
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      x_return_status            := g_ret_sts_success;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '300:********** Entered Subscription Price ********'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '301:CHR_ID            = ' ||
                         p_detail_rec.chr_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '302:LINE_ID           = ' ||
                         p_detail_rec.line_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '303:SUBLINE_ID        = ' ||
                         p_detail_rec.subline_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '304:INTENT            = ' ||
                         p_detail_rec.intent
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '305:CURRENCY          = ' ||
                         p_detail_rec.currency
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '306:Usage Qty         = ' ||
                         p_detail_rec.usage_qty
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '307:Usage UOM Code    = ' ||
                         p_detail_rec.usage_uom_code
                        );
      END IF;

      --errorout ('********** Entered Subscription Price ********');
      --errorout ('CHR_ID            = ' || p_detail_rec.chr_id);
      --errorout ('LINE_ID           = ' || p_detail_rec.line_id);
      --errorout ('SUBLINE_ID        = ' || p_detail_rec.subline_id);
      --errorout ('INTENT            = ' || p_detail_rec.intent);
      --errorout ('CURRENCY          = ' || p_detail_rec.currency);
      --errorout ('Usage Qty         = ' || p_detail_rec.usage_qty);
      --errorout ('Usage UOM Code    = ' || p_detail_rec.usage_uom_code);

      /** 3912685 **/
      check_pricing_eligibility (p_line_id                          => p_detail_rec.line_id,
                                 x_status                           => l_status,
                                 x_return_status                    => x_return_status,
                                 x_msg_count                        => x_msg_count,
                                 x_msg_data                         => x_msg_data
                                );

      IF x_return_status <> g_ret_sts_success
      THEN
         RAISE g_exc_error;
      END IF;

      IF l_status <> g_oks_success
      THEN
         x_price_details.status_code := l_status;
         RAISE g_exc_cant_price;
      END IF;

      /** **/
      IF p_detail_rec.intent = g_subsc_ovr_pricing
      THEN
         -- Get Price negotiated amount
         OPEN l_line_details_csr (p_detail_rec.line_id);

         FETCH l_line_details_csr
          INTO l_line_details_rec;

         IF l_line_details_csr%NOTFOUND
         THEN
            CLOSE l_line_details_csr;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                     (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '308:Negotiated amount ERROR at Calc Subscription call'
                     );
            END IF;

            --errorout('Negotiated amount ERROR at Calc Subscription call');
            RAISE g_exc_error;
         END IF;

         CLOSE l_line_details_csr;

         oks_subscription_pub.get_subs_qty
                                          (p_cle_id                           => p_detail_rec.line_id,
                                           x_return_status                    => x_return_status,
                                           x_quantity                         => l_qpprod_quantity,
                                           x_uom_code                         => l_qpprod_uom_code
                                          );

         IF x_return_status <> g_ret_sts_success
         THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '309:UOM/QTY ERROR at Calc Subscription call'
                              );
            END IF;

            --errorout('UOM/QTY ERROR at Calc Subscription call');
            RAISE g_exc_error;
         END IF;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '310:QTY = ' ||
                            l_qpprod_quantity ||
                            ' UOM = ' ||
                            l_qpprod_uom_code
                           );
         END IF;

         --errorout('QTY = '||l_qpprod_quantity || ' UOM = ' || l_qpprod_uom_code);
         IF NVL (fnd_profile.VALUE ('OKS_USE_QP_FOR_MANUAL_ADJ'), 'NO') =
                                                                         'YES'
         THEN
            IF    l_qpprod_quantity IS NULL
               OR l_qpprod_quantity = 0
            THEN
               l_input_detail_rec.asking_unit_price :=
                                          l_line_details_rec.price_negotiated;
            ELSE
               l_input_detail_rec.asking_unit_price :=
                      l_line_details_rec.price_negotiated /
                      l_qpprod_quantity;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '311:Asking price = ' ||
                               l_input_detail_rec.asking_unit_price
                              );
            END IF;

            --errorout('Asking price = '||l_input_detail_rec.asking_unit_price);
            oks_qp_pkg.calc_price
                              (p_detail_rec                       => l_input_detail_rec,
                               x_price_details                    => x_price_details,
                               x_modifier_details                 => x_modifier_details,
                               x_price_break_details              => x_price_break_details,
                               x_return_status                    => x_return_status,
                               x_msg_count                        => x_msg_count,
                               x_msg_data                         => x_msg_data
                              );

            IF x_return_status <> g_ret_sts_success
            THEN
               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_procedure,
                                  g_module ||
                                  l_api_name,
                                  '101:CALC PRICE ERROR at 2nd SAPI call'
                                 );
               END IF;

               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '312:CALC PRICE ERROR at 2nd SAPI call'
                                 );
               END IF;

               --dbms_output.put_line('CALC PRICE ERROR at 2nd SAPI call');
               RAISE g_exc_error;
            END IF;

            x_price_details.serv_ext_amount := x_price_details.prod_ext_amount;
            l_rail_rec.amount          :=
                                      NVL (x_price_details.serv_ext_amount, 0);
         -- x_price_details.status_text         := NVL(x_price_details.status_text,G_STS_TXT_SUCCESS);
         ELSE
            IF l_input_detail_rec.currency IS NULL
            THEN
               OPEN l_currcode_csr (l_line_details_rec.dnz_chr_id);

               FETCH l_currcode_csr
                INTO l_input_detail_rec.currency;

               CLOSE l_currcode_csr;
            END IF;

            -- bug 5018782, don't round any amount that we get from QP
            l_line_details_rec.price_negotiated :=  ROUND (l_line_details_rec.price_negotiated, 29);
            /*  bug 5018782
               oks_extwar_util_pvt.round_currency_amt
                             (p_amount                           => l_line_details_rec.price_negotiated,
                              p_currency_code                    => l_input_detail_rec.currency);
             */

            x_price_details.serv_ext_amount :=
                                  NVL (l_line_details_rec.price_negotiated, 0);
            l_rail_rec.amount          :=
                                  NVL (l_line_details_rec.price_negotiated, 0);
            x_price_details.status_text := g_manual_adj_price;

            IF     NVL (l_line_details_rec.price_negotiated, 0) > 0
               AND l_qpprod_quantity > 0
            THEN
               x_price_details.prod_adj_unit_price :=
                  NVL (l_line_details_rec.price_negotiated, 0) /
                  l_qpprod_quantity;
            ELSE
               x_price_details.prod_adj_unit_price :=
                                 NVL (l_line_details_rec.price_negotiated, 0);
            END IF;

            x_price_details.prod_qty   := NULL;
            x_price_details.prod_qty_uom := NULL;
            x_price_details.prod_price_list_id := NULL;
            x_price_details.prod_list_unit_price := NULL;
            x_price_details.prod_adj_unit_price := NULL;
            x_price_details.prod_priced_qty := NULL;
            x_price_details.prod_priced_uom := NULL;
         END IF;
      ELSE
         oks_qp_pkg.calc_price
                             (p_detail_rec                       => l_input_detail_rec,
                              x_price_details                    => x_price_details,
                              x_modifier_details                 => x_modifier_details,
                              x_price_break_details              => x_price_break_details,
                              x_return_status                    => x_return_status,
                              x_msg_count                        => x_msg_count,
                              x_msg_data                         => x_msg_data
                             );

         IF x_return_status <> g_ret_sts_success
         THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '313:CALC Price ERROR after SAPI call'
                              );
            END IF;

            --errorout('CALC Price ERROR after SAPI call');
            RAISE g_exc_error;
         END IF;

         x_price_details.serv_ext_amount := x_price_details.prod_ext_amount;
         l_rail_rec.amount          :=
                                      NVL (x_price_details.serv_ext_amount, 0);
      -- x_price_details.status_text          := NVL(x_price_details.status_text,G_STS_TXT_SUCCESS);
      END IF;

      x_price_details.serv_qty   := x_price_details.prod_qty;
      x_price_details.serv_qty_uom := x_price_details.prod_qty_uom;
      x_price_details.serv_price_list_id := x_price_details.prod_price_list_id;
      x_price_details.serv_list_unit_price :=
                                          x_price_details.prod_list_unit_price;
      x_price_details.serv_adj_unit_price :=
                                           x_price_details.prod_adj_unit_price;
      x_price_details.serv_priced_qty := x_price_details.prod_priced_qty;
      x_price_details.serv_priced_uom := x_price_details.prod_priced_uom;
      x_price_details.prod_qty   := NULL;
      x_price_details.prod_qty_uom := NULL;
      x_price_details.prod_price_list_id := NULL;
      x_price_details.prod_list_unit_price := NULL;
      x_price_details.prod_adj_unit_price := NULL;
      x_price_details.prod_priced_qty := NULL;
      x_price_details.prod_priced_uom := NULL;
      x_price_details.prod_ext_amount := NULL;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '314:x_price_details.PROD_QTY = ' ||
                         x_price_details.prod_qty
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '315:x_price_details.PROD_QTY_UOM = ' ||
                         x_price_details.prod_qty_uom
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '316:x_price_details.SERV_QTY = ' ||
                         x_price_details.serv_qty
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '317:x_price_details.SERV_QTY_UOM = ' ||
                         x_price_details.serv_qty_uom
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '318:x_price_details.PROD_PRICE_LIST_ID = ' ||
                         x_price_details.prod_price_list_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '319:x_price_details.SERV_PRICE_LIST_ID = ' ||
                         x_price_details.serv_price_list_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '320:x_price_details.PROD_LIST_UNIT_PRICE = ' ||
                         x_price_details.prod_list_unit_price
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '321:x_price_details.SERV_LIST_UNIT_PRICE = ' ||
                         x_price_details.serv_list_unit_price
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '322:x_price_details.PROD_ADJ_UNIT_PRICE = ' ||
                         x_price_details.prod_adj_unit_price
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '323:x_price_details.SERV_ADJ_UNIT_PRICE = ' ||
                         x_price_details.serv_adj_unit_price
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '324:x_price_details.PROD_PRICED_QTY = ' ||
                         x_price_details.prod_priced_qty
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '325:x_price_details.PROD_PRICED_UOM = ' ||
                         x_price_details.prod_priced_uom
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '326:x_price_details.PROD_EXT_AMOUNT = ' ||
                         x_price_details.prod_ext_amount
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '327:x_price_details.SERV_PRICED_QTY = ' ||
                         x_price_details.serv_priced_qty
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '328:x_price_details.SERV_PRICED_UOM = ' ||
                         x_price_details.serv_priced_uom
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '329:x_price_details.SERV_EXT_AMOUNT = ' ||
                         x_price_details.serv_ext_amount
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '330:x_price_details.SERV_OPERAND = ' ||
                         x_price_details.serv_operand
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '331:x_price_details.SERV_OPERATOR = ' ||
                         x_price_details.serv_operator
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '332:x_price_details.STATUS_TEXT = ' ||
                         x_price_details.status_text
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '333:l_rail_rec.amount = ' ||
                         l_rail_rec.amount
                        );
      END IF;

--errorout('x_price_details.PROD_QTY = '            || x_price_details.PROD_QTY );
--errorout('x_pri'ce_details.PROD_QTY_UOM = '       || x_price_details.PROD_QTY_UOM );
--errorout('x_price_details.SERV_QTY = '            || x_price_details.SERV_QTY );
--errorout('x_price_details.SERV_QTY_UOM = '        || x_price_details.SERV_QTY_UOM );
--errorout('x_price_details.PROD_PRICE_LIST_ID = '  || x_price_details.PROD_PRICE_LIST_ID );
--errorout('x_price_details.SERV_PRICE_LIST_ID = '  || x_price_details.SERV_PRICE_LIST_ID );
--errorout('x_price_details.PROD_LIST_UNIT_PRICE = '|| x_price_details.PROD_LIST_UNIT_PRICE );
--errorout('x_price_details.SERV_LIST_UNIT_PRICE = '|| x_price_details.SERV_LIST_UNIT_PRICE );
--errorout('x_price_details.PROD_ADJ_UNIT_PRICE = ' || x_price_details.PROD_ADJ_UNIT_PRICE );
--errorout('x_price_details.SERV_ADJ_UNIT_PRICE = ' || x_price_details.SERV_ADJ_UNIT_PRICE );
--errorout('x_price_details.PROD_PRICED_QTY = '     || x_price_details.PROD_PRICED_QTY );
--errorout('x_price_details.PROD_PRICED_UOM = '     || x_price_details.PROD_PRICED_UOM );
--errorout('x_price_details.PROD_EXT_AMOUNT = '     || x_price_details.PROD_EXT_AMOUNT );
--errorout('x_price_details.SERV_PRICED_QTY = '     || x_price_details.SERV_PRICED_QTY );
--errorout('x_price_details.SERV_PRICED_UOM = '     || x_price_details.SERV_PRICED_UOM );
--errorout('x_price_details.SERV_EXT_AMOUNT = '     || x_price_details.SERV_EXT_AMOUNT );
--errorout('x_price_details.SERV_OPERAND = '        || x_price_details.SERV_OPERAND );
--errorout('x_price_details.SERV_OPERATOR = '       || x_price_details.SERV_OPERATOR );
--errorout('x_price_details.STATUS_TEXT = '         || x_price_details.STATUS_TEXT );
--errorout('l_rail_rec.amount = '                   || l_rail_rec.amount);
      l_rail_rec.tax_value       := NULL;
      l_rail_rec.amount_includes_tax_flag := NULL;
      -- Calculate Tax
      oks_tax_util_pvt.get_tax (p_api_version                      => l_api_version,
                                p_init_msg_list                    => l_init_msg_list,
                                p_chr_id                           => l_input_detail_rec.chr_id,
                                p_cle_id                           => l_input_detail_rec.line_id,
                                px_rail_rec                        => l_rail_rec,
                                x_msg_count                        => x_msg_count,
                                x_msg_data                         => x_msg_data,
                                x_return_status                    => x_return_status
                               );

      IF x_return_status <> g_ret_sts_success
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '334:Tax ERROR after GET_TAX call x_return_status '||x_return_status
                           );
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '334:x_msg_data '||x_msg_data
                           );
         END IF;

         --errorout('Tax ERROR after GET_TAX call');
         -- bug 5001677, even if tax error continue
         -- RAISE g_exc_error;
         l_rail_rec.tax_value                :=  0;
         l_rail_rec.amount_includes_tax_flag := 'N';
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '336:l_rail_rec.TAX_VALUE = ' ||
                         l_rail_rec.tax_value
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '337:l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG = ' ||
                         l_rail_rec.amount_includes_tax_flag
                        );
      END IF;

--errorout('l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG = '||l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG );
--errorout('l_rail_rec.TAX_VALUE = '||  l_rail_rec.TAX_VALUE );
--errorout('l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG = '||l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG );
      l_kln_rec_in.cle_id        := l_input_detail_rec.line_id;
      l_kln_rec_in.dnz_chr_id    := l_input_detail_rec.chr_id;
      l_kln_rec_in.tax_inclusive_yn := l_rail_rec.amount_includes_tax_flag;

      IF l_rail_rec.amount_includes_tax_flag = 'N'
      THEN
         l_kln_rec_in.tax_amount    := NVL (l_rail_rec.tax_value, 0);
      ELSE
         l_kln_rec_in.tax_amount    := 0;
      END IF;

      IF x_price_details.prod_price_list_id IS NOT NULL
      THEN
         l_kln_rec_in.prod_price    := x_price_details.prod_price_list_id;
      END IF;

      IF x_price_details.serv_price_list_id IS NOT NULL
      THEN
         l_kln_rec_in.service_price := x_price_details.serv_price_list_id;
      END IF;

      l_kln_rec_in.clvl_list_price := x_price_details.prod_list_unit_price;
      l_kln_rec_in.clvl_quantity := x_price_details.prod_priced_qty;
      l_kln_rec_in.clvl_extended_amt := x_price_details.prod_ext_amount;
      l_kln_rec_in.toplvl_operand_code := x_price_details.serv_operator;
      l_kln_rec_in.toplvl_operand_val := x_price_details.serv_operand;
      l_kln_rec_in.clvl_uom_code := x_price_details.prod_priced_uom;
      l_kln_rec_in.toplvl_quantity := x_price_details.serv_qty;
      l_kln_rec_in.toplvl_uom_code := x_price_details.serv_priced_uom;
      l_kln_rec_in.toplvl_adj_price := x_price_details.serv_adj_unit_price;
      -- GCHADHA --
      -- 17-NOV-2004 --
      -- BUG 4015739 --
      l_kln_rec_in.status_text   :=
         SUBSTR (NVL (x_price_details.status_text, g_sts_txt_success),
                 1,
                 450
                );
      -- l_kln_rec_in.status_text         := NVL(x_price_details.status_text,G_STS_TXT_SUCCESS);

      -- END GCHADHA --
      l_kln_rec_in.toplvl_price_qty := x_price_details.serv_priced_qty;
      get_k_details (p_id                               => l_input_detail_rec.line_id,
                     p_type                             => g_oks_line,
                     x_k_det_rec                        => l_k_det_rec
                    );
      l_kln_rec_in.ID            := l_k_det_rec.ID;
      l_kln_rec_in.object_version_number := l_k_det_rec.object_version_number;
      oks_contract_line_pub.update_line (p_api_version                      => l_api_version,
                                         p_init_msg_list                    => l_init_msg_list,
                                         x_return_status                    => x_return_status,
                                         x_msg_count                        => x_msg_count,
                                         x_msg_data                         => x_msg_data,
                                         p_klnv_rec                         => l_kln_rec_in,
                                         x_klnv_rec                         => l_kln_rec_out,
                                         p_validate_yn                      => 'N'
                                        );

      IF x_return_status <> g_ret_sts_success
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '338:Update line details at Calc Subscription'
                           );
         END IF;

         -- errorout('Update line details at Calc Subscription');
         RAISE g_exc_error;
      END IF;

      l_clev_rec_in.ID           := l_input_detail_rec.line_id;
      l_clev_rec_in.line_list_price := x_price_details.serv_list_unit_price;
      l_clev_rec_in.price_negotiated := l_rail_rec.amount;
      get_k_details (p_id                               => l_input_detail_rec.line_id,
                     p_type                             => g_okc_line,
                     x_k_det_rec                        => l_k_det_rec
                    );
      l_clev_rec_in.object_version_number := l_k_det_rec.object_version_number;
      okc_contract_pub.update_contract_line
                                          (p_api_version                      => l_api_version,
                                           p_init_msg_list                    => l_init_msg_list,
                                           x_return_status                    => x_return_status,
                                           x_msg_count                        => x_msg_count,
                                           x_msg_data                         => x_msg_data,
                                           p_clev_rec                         => l_clev_rec_in,
                                           x_clev_rec                         => l_clev_rec_out
                                          );

      IF x_return_status <> g_ret_sts_success
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                       (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '339:Update Contract line ERROR at Calc Subscription'
                       );
         END IF;

         -- errorout('Update Contract line ERROR at Calc Subscription');
         RAISE g_exc_error;
      END IF;

      -- Update Subsciption elements
      FOR l_subs_elements_rec IN l_subs_elements_csr (p_detail_rec.line_id)
      LOOP
         l_scev_rec_in.ID           := l_subs_elements_rec.ID;
         l_scev_rec_in.amount       :=
            l_subs_elements_rec.quantity *
            x_price_details.serv_adj_unit_price;
         l_scev_rec_in.object_version_number :=
                                     l_subs_elements_rec.object_version_number;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '340:Subscription element ID : ' ||
                            l_scev_rec_in.ID
                           );
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '341:Subscription element Amt : ' ||
                            l_scev_rec_in.amount
                           );
         END IF;

         -- errorout('Subscription element ID : ' || l_scev_rec_in.id);
         -- errorout('Subscription element Amt : ' || l_scev_rec_in.amount);
         oks_subscr_elems_pub.update_row (p_api_version                      => l_api_version,
                                          p_init_msg_list                    => l_init_msg_list,
                                          x_return_status                    => x_return_status,
                                          x_msg_count                        => x_msg_count,
                                          x_msg_data                         => x_msg_data,
                                          p_scev_rec                         => l_scev_rec_in,
                                          x_scev_rec                         => l_scev_rec_out
                                         );

         IF x_return_status <> g_ret_sts_success
         THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_statement,
                   g_module ||
                   l_api_name,
                   '342:ERROR while updating Subscription elements at Calc Subscription'
                  );
            END IF;

            -- errorout('ERROR while updating Subscription elements at Calc Subscription');
            RAISE g_exc_error;
         END IF;
      END LOOP;

      -- If request coming from Header pricing, populate the message table
      IF p_detail_rec.intent = g_subsc_reg_pricing
      THEN
         -- Get subscription line details
         get_line_details (p_line_id                          => l_input_detail_rec.line_id,
                           x_name                             => l_tlvl_name,
                           x_description                      => l_tlvl_desc,
                           x_return_status                    => x_return_status,
                           x_msg_count                        => x_msg_count,
                           x_msg_data                         => x_msg_data
                          );

         IF x_return_status <> g_ret_sts_success
         THEN
            RAISE g_exc_error;
         END IF;

         g_pricing_status_tbl (g_index).service_name := l_tlvl_name;
         g_pricing_status_tbl (g_index).coverage_level_name := l_tlvl_desc; -- bug 5014604
         g_pricing_status_tbl (g_index).status_code := g_sts_code_success;
         l_line_no                  :=
                                      get_line_no (l_input_detail_rec.line_id);

         IF l_line_no IS NULL
         THEN
            g_pricing_status_tbl (g_index).status_text :=
                         NVL (x_price_details.status_text, g_sts_txt_success);
         ELSE
            -- bug 4730011
            fnd_message.set_name ('OKS', 'OKS_LINE_REPRICE_SUCCESS');
            fnd_message.set_token ('LINENO', l_line_no);
            g_pricing_status_tbl (g_index).status_text := fnd_message.get;
              -- l_line_no ||' ' ||NVL (x_price_details.status_text, g_sts_txt_success);
         END IF;

         g_index                    := g_index +
                                       1;
      END IF;

      x_price_details.status_text :=
                          NVL (x_price_details.status_text, g_sts_txt_success);

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN g_exc_cant_price
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '7000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         IF p_detail_rec.intent = g_subsc_reg_pricing
         THEN
            -- Get subscription line details
            get_line_details (p_line_id                          => l_input_detail_rec.line_id,
                              x_name                             => l_tlvl_name,
                              x_description                      => l_tlvl_desc,
                              x_return_status                    => l_return_status,
                              x_msg_count                        => x_msg_count,
                              x_msg_data                         => x_msg_data
                             );
            g_pricing_status_tbl (g_index).service_name := l_tlvl_name;
            g_pricing_status_tbl (g_index).coverage_level_name := l_tlvl_desc; -- bug 5014604
            g_pricing_status_tbl (g_index).status_code := g_sts_code_success;

            IF x_price_details.status_code = g_partial_billed
                             or
               x_price_details.status_code = g_fully_billed
            THEN
               g_pricing_status_tbl (g_index).status_text := g_billed_line;
            ELSE
               g_pricing_status_tbl (g_index).status_text :=
                                                            g_sts_txt_success;
            END IF;

            g_index                    := g_index +
                                          1;
         END IF;

         IF    l_status = g_fully_billed
            OR l_status = g_partial_billed
         THEN
            x_price_details.status_code := g_billed;
         END IF;
      WHEN g_exc_error
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '2000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         IF p_detail_rec.intent = g_subsc_reg_pricing
         THEN
            -- Get subscription line details
            get_line_details (p_line_id                          => l_input_detail_rec.line_id,
                              x_name                             => l_tlvl_name,
                              x_description                      => l_tlvl_desc,
                              x_return_status                    => l_return_status,
                              x_msg_count                        => x_msg_count,
                              x_msg_data                         => x_msg_data
                             );
            g_pricing_status_tbl (g_index).service_name := l_tlvl_name;
            g_pricing_status_tbl (g_index).coverage_level_name := l_tlvl_desc; -- bug 5014604
            g_pricing_status_tbl (g_index).status_code := g_sts_code_error;
            l_line_no                  :=
                                      get_line_no (l_input_detail_rec.line_id);

            IF l_line_no IS NULL
            THEN
               g_pricing_status_tbl (g_index).status_text :=
                           NVL (x_price_details.status_text, g_sts_txt_error);
            ELSE
              -- bug 4730011
               fnd_message.set_name ('OKS', 'OKS_LINE_REPRICE_SUCCESS');
               fnd_message.set_token ('LINENO', l_line_no);
               g_pricing_status_tbl (g_index).status_text := fnd_message.get;
                 --   l_line_no ||' ' ||NVL (x_price_details.status_text, g_sts_txt_error);
            END IF;

            g_index                    := g_index +
                                          1;
         END IF;
      WHEN OTHERS
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status            := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name                         => g_app_name,
                              p_msg_name                         => g_unexpected_error,
                              p_token1                           => g_sqlcode_token,
                              p_token1_value                     => SQLCODE,
                              p_token2                           => g_sqlerrm_token,
                              p_token2_value                     => SQLERRM
                             );
   END calculate_subscription_price;

   PROCEDURE calculate_subline_price (
      p_detail_rec                    IN       oks_qp_pkg.input_details,
      x_price_details                 OUT NOCOPY oks_qp_pkg.price_details,
      x_modifier_details              OUT NOCOPY qp_preq_grp.line_detail_tbl_type,
      x_price_break_details           OUT NOCOPY oks_qp_pkg.g_price_break_tbl_type,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER,
      x_msg_data                      OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                 := 'CALCULATE_SUBLINE_PRICE';

      CURSOR l_currcode_csr (
         p_hdr_id                                 NUMBER
      )
      IS
         SELECT currency_code
           FROM okc_k_headers_all_b
          WHERE ID = p_hdr_id;

      CURSOR l_line_details_csr (
         p_cle_id                                 NUMBER
      )
      IS
         SELECT ID,
                start_date,
                end_date,
                cle_id,
                dnz_chr_id,
                lse_id,
                price_negotiated,
                price_unit,
                price_unit_percent,
                price_list_line_id,
                price_list_id,
                line_list_price,
                item_to_price_yn,
                pricing_date,
                price_basis_yn
           FROM okc_k_lines_b
          WHERE ID = p_cle_id
            AND lse_id IN (7, 9, 25);

      CURSOR l_prodpriceuom_csr (
         p_id                                     NUMBER
      )
      IS
         SELECT price_uom
           FROM oks_k_lines_b
          WHERE cle_id = p_id;

      CURSOR l_get_hdrid_csr (
         p_cle_id                                 NUMBER
      )
      IS
         SELECT dnz_chr_id
           FROM okc_k_lines_b
          WHERE ID = p_cle_id;

      CURSOR l_numitems_csr (
         p_subline_id                             NUMBER
      )
      IS
         SELECT number_of_items
           FROM okc_k_items_v
          WHERE cle_id = p_subline_id;

      l_num_items                             NUMBER;
      l_duration_qty                          NUMBER;
      l_cpuom_code                            VARCHAR2 (200);
      l_line_details_rec                      l_line_details_csr%ROWTYPE;
      l_input_detail_rec                      oks_qp_pkg.input_details
                                                               := p_detail_rec;
      l_rail_rec                              oks_tax_util_pvt.ra_rec_type;
      l_k_det_rec                             k_details_rec;
      l_khdr_rec_in                           oks_contract_hdr_pub.khrv_rec_type;
      l_khdr_rec_out                          oks_contract_hdr_pub.khrv_rec_type;
      l_kln_rec_in                            oks_contract_line_pub.klnv_rec_type;
      l_kln_rec_out                           oks_contract_line_pub.klnv_rec_type;
      l_clev_rec_in                           okc_contract_pub.clev_rec_type;
      l_clev_rec_out                          okc_contract_pub.clev_rec_type;
      l_prod_qty                              NUMBER;
      l_serv_qty                              NUMBER;
      l_status                                VARCHAR2 (30);         --3912685
      --new variables for partial periods
      l_period_type                           VARCHAR2 (30);
      l_period_start                          VARCHAR2 (30);
      l_price_uom                             VARCHAR2 (30);
      l_chr_id                                NUMBER;
      invalid_hdr_id_exception                EXCEPTION;
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      x_return_status            := g_ret_sts_success;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '343:********** Entered Sub line Price ********'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '344:CHR_ID            = ' ||
                         p_detail_rec.chr_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '345:LINE_ID           = ' ||
                         p_detail_rec.line_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '346:SUBLINE_ID        = ' ||
                         p_detail_rec.subline_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '347:INTENT            = ' ||
                         p_detail_rec.intent
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '348:CURRENCY          = ' ||
                         p_detail_rec.currency
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '349:Usage Qty         = ' ||
                         p_detail_rec.usage_qty
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '350:Usage UOM Code    = ' ||
                         p_detail_rec.usage_uom_code
                        );
      END IF;

      --errorout ('********** Entered Sub line Price ********');
      --errorout ('CHR_ID            = ' || p_detail_rec.chr_id);
      --errorout ('LINE_ID           = ' || p_detail_rec.line_id);
      --errorout ('SUBLINE_ID        = ' || p_detail_rec.subline_id);
      --errorout ('INTENT            = ' || p_detail_rec.intent);
      --errorout ('CURRENCY          = ' || p_detail_rec.currency);
      --errorout ('Usage Qty         = ' || p_detail_rec.usage_qty);
      --errorout ('Usage UOM Code    = ' || p_detail_rec.usage_uom_code);

      /** 3912685 **/
      check_pricing_eligibility (p_line_id                          => p_detail_rec.subline_id,
                                 x_status                           => l_status,
                                 x_return_status                    => x_return_status,
                                 x_msg_count                        => x_msg_count,
                                 x_msg_data                         => x_msg_data
                                );

      IF x_return_status <> g_ret_sts_success
      THEN
         RAISE g_exc_error;
      END IF;

      IF l_status <> g_oks_success
      THEN
         x_price_details.status_code := l_status;
         RAISE g_exc_cant_price;
      END IF;

      /** 3912685 **/
      IF p_detail_rec.intent = g_override_pricing
      THEN
         OPEN l_line_details_csr (p_detail_rec.subline_id);

         FETCH l_line_details_csr
          INTO l_line_details_rec;

         IF l_line_details_csr%NOTFOUND
         THEN
            CLOSE l_line_details_csr;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_statement,
                   g_module ||
                   l_api_name,
                   '351:Override amount not present in Price Negotiated column'
                  );
            END IF;

            --errorout  ('Override amount not present in Price Negotiated column');
            okc_api.set_message (p_app_name                         => g_app_name,
                                 p_msg_name                         => g_required_value,
                                 p_token1                           => g_col_name_token,
                                 p_token1_value                     => 'PRICE_NEGOTIATED'
                                );
            x_return_status            := g_ret_sts_error;
            RAISE g_exc_error;
         END IF;

         CLOSE l_line_details_csr;

         IF NVL (fnd_profile.VALUE ('OKS_USE_QP_FOR_MANUAL_ADJ'), 'NO') =
                                                                         'YES'
         THEN
            oks_qp_pkg.calc_price
                             (p_detail_rec                       => l_input_detail_rec,
                              x_price_details                    => x_price_details,
                              x_modifier_details                 => x_modifier_details,
                              x_price_break_details              => x_price_break_details,
                              x_return_status                    => x_return_status,
                              x_msg_count                        => x_msg_count,
                              x_msg_data                         => x_msg_data
                             );

            IF x_return_status <> g_ret_sts_success
            THEN
               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '352:CALC PRICE ERROR at 1st SAPI call'
                                 );
               END IF;

               --errorout('CALC PRICE ERROR at 1st SAPI call');
               RAISE g_exc_error;
            END IF;

            -- Now calculate the override unit price
            l_prod_qty                 :=
                                      NVL (x_price_details.prod_priced_qty, 1);
            l_serv_qty                 :=
                                      NVL (x_price_details.serv_priced_qty, 1);
            l_input_detail_rec.asking_unit_price :=
               l_line_details_rec.price_negotiated /
               (l_prod_qty *
                l_serv_qty
               );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '353:Asking price : ' ||
                               l_input_detail_rec.asking_unit_price
                              );
            END IF;

            --errorout('Asking price : ' || l_input_detail_rec.asking_unit_price);
            oks_qp_pkg.calc_price
                              (p_detail_rec                       => l_input_detail_rec,
                               x_price_details                    => x_price_details,
                               x_modifier_details                 => x_modifier_details,
                               x_price_break_details              => x_price_break_details,
                               x_return_status                    => x_return_status,
                               x_msg_count                        => x_msg_count,
                               x_msg_data                         => x_msg_data
                              );

            IF x_return_status <> g_ret_sts_success
            THEN
               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_procedure,
                                  g_module ||
                                  l_api_name,
                                  '201:CALC PRICE ERROR at 2nd SAPI call'
                                 );
               END IF;

               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '354:CALC PRICE ERROR at 2nd SAPI call'
                                 );
               END IF;

               --dbms_output.put_line('CALC PRICE ERROR at 2nd SAPI call');
               RAISE g_exc_error;
            END IF;

            l_rail_rec.amount          :=
                                      NVL (x_price_details.serv_ext_amount, 0);
            x_price_details.status_text :=
                          NVL (x_price_details.status_text, g_sts_txt_success);
         ELSE
            OPEN l_prodpriceuom_csr (p_detail_rec.subline_id);

            FETCH l_prodpriceuom_csr
             INTO l_cpuom_code;

            CLOSE l_prodpriceuom_csr;

            --New logic for Partial Periods
            OPEN l_get_hdrid_csr (p_detail_rec.subline_id);

            FETCH l_get_hdrid_csr
             INTO l_chr_id;

            CLOSE l_get_hdrid_csr;

            IF l_chr_id IS NOT NULL
            THEN
               oks_renew_util_pub.get_period_defaults
                                          (p_hdr_id                           => l_chr_id,
                                           p_org_id                           => NULL,
                                           x_period_type                      => l_period_type,
                                           x_period_start                     => l_period_start,
                                           x_price_uom                        => l_price_uom,
                                           x_return_status                    => x_return_status
                                          );

               IF x_return_status <> g_ret_sts_success
               THEN
                  RAISE g_exc_error;
               END IF;
            ELSE
               RAISE invalid_hdr_id_exception;
            END IF;

            --End  logic for Partial Periods
            IF l_cpuom_code IS NOT NULL
            THEN
               l_duration_qty             :=
                  oks_time_measures_pub.get_quantity
                              (p_start_date                       => l_line_details_rec.start_date,
                               p_end_date                         => l_line_details_rec.end_date,
                               p_source_uom                       => l_cpuom_code,
                               p_period_type                      => l_period_type,
                               --new parameter
                               p_period_start                     => l_period_start
                              --new paramter
                              );
            ELSE
               okc_time_util_pub.get_duration
                              (p_start_date                       => l_line_details_rec.start_date,
                               p_end_date                         => l_line_details_rec.end_date,
                               x_duration                         => l_duration_qty,
                               x_timeunit                         => l_cpuom_code,
                               x_return_status                    => x_return_status
                              );
            END IF;

            OPEN l_numitems_csr (p_detail_rec.subline_id);

            FETCH l_numitems_csr
             INTO l_num_items;

            CLOSE l_numitems_csr;

            IF l_input_detail_rec.currency IS NULL
            THEN
               OPEN l_currcode_csr (l_line_details_rec.dnz_chr_id);

               FETCH l_currcode_csr
                INTO l_input_detail_rec.currency;

               CLOSE l_currcode_csr;
            END IF;

             -- bug 5018782, don't round any amount that we get from QP
            l_line_details_rec.price_negotiated := ROUND (l_line_details_rec.price_negotiated, 29) ;
             /*  bug 5018782
               oks_extwar_util_pvt.round_currency_amt
                             (p_amount                           => l_line_details_rec.price_negotiated,
                              p_currency_code                    => l_input_detail_rec.currency);
             */
            l_rail_rec.amount          :=
                                  NVL (l_line_details_rec.price_negotiated, 0);
            x_price_details.status_text := g_manual_adj_price;
            x_price_details.serv_ext_amount :=
                                  NVL (l_line_details_rec.price_negotiated, 0);

            IF     NVL (l_line_details_rec.price_negotiated, 0) > 0
               AND l_duration_qty > 0
               AND l_num_items > 0
            THEN
               x_price_details.serv_adj_unit_price :=
                  NVL (l_line_details_rec.price_negotiated, 0) /
                  (l_duration_qty *
                   l_num_items
                  );
            ELSE
               x_price_details.serv_adj_unit_price :=
                                 NVL (l_line_details_rec.price_negotiated, 0);
            END IF;

            x_price_details.serv_adj_unit_price :=
                               ROUND (x_price_details.serv_adj_unit_price, 29);
            x_price_details.prod_list_unit_price := NULL;
            x_price_details.prod_priced_qty := NULL;
            x_price_details.prod_ext_amount := NULL;
            x_price_details.serv_list_unit_price := NULL;
            x_price_details.serv_operator := NULL;
            x_price_details.serv_operand := NULL;
            x_price_details.prod_priced_uom := NULL;
            x_price_details.serv_qty   := NULL;
            x_price_details.serv_priced_uom := NULL;
         END IF;
      ELSE
         oks_qp_pkg.calc_price
                             (p_detail_rec                       => l_input_detail_rec,
                              x_price_details                    => x_price_details,
                              x_modifier_details                 => x_modifier_details,
                              x_price_break_details              => x_price_break_details,
                              x_return_status                    => x_return_status,
                              x_msg_count                        => x_msg_count,
                              x_msg_data                         => x_msg_data
                             );

         IF x_return_status <> g_ret_sts_success
         THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '355:CALC PRICE ERROR at 2nd SAPI call'
                              );
            END IF;

            -- errorout('CALC PRICE ERROR at 2nd SAPI call');
            RAISE g_exc_error;
         END IF;

         l_rail_rec.amount          :=
                                      NVL (x_price_details.serv_ext_amount, 0);
         x_price_details.status_text :=
                          NVL (x_price_details.status_text, g_sts_txt_success);
      END IF;

      l_rail_rec.tax_value       := NULL;
      l_rail_rec.amount_includes_tax_flag := NULL;
      -- Calculate Tax
      oks_tax_util_pvt.get_tax (p_api_version                      => l_api_version,
                                p_init_msg_list                    => l_init_msg_list,
                                p_chr_id                           => l_input_detail_rec.chr_id,
                                p_cle_id                           => l_input_detail_rec.subline_id,
                                px_rail_rec                        => l_rail_rec,
                                x_msg_count                        => x_msg_count,
                                x_msg_data                         => x_msg_data,
                                x_return_status                    => x_return_status
                               );

      IF x_return_status <> g_ret_sts_success
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '356:TAX ERROR in Subline Price x_return_status '||x_return_status
                           );
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '356: x_msg_data '||x_msg_data
                           );
         END IF;

         --errorout('TAX ERROR in Subline Price');
         -- bug 5001677, even if tax error continue
         -- RAISE g_exc_error;
         l_rail_rec.tax_value                :=  0;
         l_rail_rec.amount_includes_tax_flag := 'N';
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '358:l_rail_rec.TAX_VALUE = ' ||
                         l_rail_rec.tax_value
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '359:l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG = ' ||
                         l_rail_rec.amount_includes_tax_flag
                        );
      END IF;

      --errorout('l_rail_rec.TAX_VALUE = '||l_rail_rec.TAX_VALUE);
      --errorout('l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG = '||l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG );
      l_kln_rec_in.cle_id        := l_input_detail_rec.subline_id;
      l_kln_rec_in.dnz_chr_id    := l_input_detail_rec.chr_id;
      l_kln_rec_in.tax_inclusive_yn := l_rail_rec.amount_includes_tax_flag;

      IF l_rail_rec.amount_includes_tax_flag = 'N'
      THEN
         l_kln_rec_in.tax_amount    := NVL (l_rail_rec.tax_value, 0);
      ELSE
         l_kln_rec_in.tax_amount    := 0;
      END IF;

      IF x_price_details.prod_price_list_id IS NOT NULL
      THEN
         l_kln_rec_in.prod_price    := x_price_details.prod_price_list_id;
      END IF;

      IF x_price_details.serv_price_list_id IS NOT NULL
      THEN
         l_kln_rec_in.service_price := x_price_details.serv_price_list_id;
      END IF;

      l_kln_rec_in.clvl_list_price := x_price_details.prod_list_unit_price;
      l_kln_rec_in.clvl_quantity := x_price_details.prod_priced_qty;
      l_kln_rec_in.clvl_extended_amt := x_price_details.prod_ext_amount;
      l_kln_rec_in.toplvl_operand_code := x_price_details.serv_operator;
      l_kln_rec_in.toplvl_operand_val := x_price_details.serv_operand;
      l_kln_rec_in.clvl_uom_code := x_price_details.prod_priced_uom;
      l_kln_rec_in.toplvl_quantity := x_price_details.serv_qty;
      l_kln_rec_in.toplvl_uom_code := x_price_details.serv_priced_uom;
      l_kln_rec_in.toplvl_adj_price := x_price_details.serv_adj_unit_price;
      -- GCHADHA --
      -- BUG 4015739 --
      -- 17-NOV-2004 --
      --l_kln_rec_in.status_text         := NVL(x_price_details.status_text,G_STS_TXT_SUCCESS);
      l_kln_rec_in.status_text   :=
         SUBSTR (NVL (x_price_details.status_text, g_sts_txt_success),
                 1,
                 450
                );
      -- END GCHADHA --
      l_kln_rec_in.toplvl_price_qty := x_price_details.serv_priced_qty;
      get_k_details (p_id                               => l_input_detail_rec.subline_id,
                     p_type                             => g_oks_line,
                     x_k_det_rec                        => l_k_det_rec
                    );
      l_kln_rec_in.ID            := l_k_det_rec.ID;
      l_kln_rec_in.object_version_number := l_k_det_rec.object_version_number;
      oks_contract_line_pub.update_line (p_api_version                      => l_api_version,
                                         p_init_msg_list                    => l_init_msg_list,
                                         x_return_status                    => x_return_status,
                                         x_msg_count                        => x_msg_count,
                                         x_msg_data                         => x_msg_data,
                                         p_klnv_rec                         => l_kln_rec_in,
                                         x_klnv_rec                         => l_kln_rec_out,
                                         p_validate_yn                      => 'N'
                                        );

      IF x_return_status <> g_ret_sts_success
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '360:Update line details at Calc Subscription'
                           );
         END IF;

         --errorout('Update line details at Calc Subscription');
         RAISE g_exc_error;
      END IF;

      l_clev_rec_in.ID           := l_input_detail_rec.subline_id;
      l_clev_rec_in.line_list_price := x_price_details.serv_list_unit_price;
      l_clev_rec_in.price_negotiated := l_rail_rec.amount;
      l_clev_rec_in.price_unit   :=
         NVL (x_price_details.serv_adj_unit_price,
              x_price_details.serv_list_unit_price);
      --bug 3360423 list_unit_price will be stored in the database instead of adj_unit_price
      get_k_details (p_id                               => l_input_detail_rec.subline_id,
                     p_type                             => g_okc_line,
                     x_k_det_rec                        => l_k_det_rec
                    );
      l_clev_rec_in.object_version_number := l_k_det_rec.object_version_number;
      okc_contract_pub.update_contract_line
                                          (p_api_version                      => l_api_version,
                                           p_init_msg_list                    => l_init_msg_list,
                                           x_return_status                    => x_return_status,
                                           x_msg_count                        => x_msg_count,
                                           x_msg_data                         => x_msg_data,
                                           p_clev_rec                         => l_clev_rec_in,
                                           x_clev_rec                         => l_clev_rec_out
                                          );

      IF x_return_status <> g_ret_sts_success
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                         (fnd_log.level_statement,
                          g_module ||
                          l_api_name,
                          '361:Contract line updation ERROR in Subline Price'
                         );
         END IF;

         -- errorout('Contract line updation ERROR in Subline Price');
         RAISE g_exc_error;
      END IF;

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN g_exc_cant_price
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '7000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         IF    l_status = g_fully_billed
            OR l_status = g_partial_billed
         THEN
            x_price_details.status_code := g_billed;
         END IF;

         NULL;
      WHEN g_exc_error
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '2000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         NULL;
      WHEN invalid_hdr_id_exception
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '8000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         okc_api.set_message (p_app_name                         => g_app_name,
                              p_msg_name                         => g_invalid_value,
                              p_token1                           => g_col_name_token,
                              p_token1_value                     => 'Header ID'
                             );
      WHEN OTHERS
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status            := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name                         => g_app_name,
                              p_msg_name                         => g_unexpected_error,
                              p_token1                           => g_sqlcode_token,
                              p_token1_value                     => SQLCODE,
                              p_token2                           => g_sqlerrm_token,
                              p_token2_value                     => SQLERRM
                             );
   END calculate_subline_price;

   PROCEDURE calculate_topline_price (
      p_detail_rec                    IN       oks_qp_pkg.input_details,
      x_price_details                 OUT NOCOPY oks_qp_pkg.price_details,
      x_modifier_details              OUT NOCOPY qp_preq_grp.line_detail_tbl_type,
      x_price_break_details           OUT NOCOPY oks_qp_pkg.g_price_break_tbl_type,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER,
      x_msg_data                      OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                 := 'CALCULATE_TOPLINE_PRICE';

      CURSOR l_subline_csr (
         p_cle_id                                 NUMBER
      )
      IS
         SELECT   ID,
                  start_date,
                  end_date,
                  lse_id
             FROM okc_k_lines_b
            WHERE cle_id = p_cle_id
              AND lse_id IN (7, 9, 25)
              AND date_cancelled IS NULL                               --[llc]
              AND date_terminated IS NULL                  -- bug 5504157
         ORDER BY line_number;

      l_input_detail_rec                      oks_qp_pkg.input_details;
      l_rail_rec                              oks_tax_util_pvt.ra_rec_type;
      l_k_det_rec                             k_details_rec;
      l_khdr_rec_in                           oks_contract_hdr_pub.khrv_rec_type;
      l_khdr_rec_out                          oks_contract_hdr_pub.khrv_rec_type;
      l_kln_rec_in                            oks_contract_line_pub.klnv_rec_type;
      l_kln_rec_out                           oks_contract_line_pub.klnv_rec_type;
      l_clev_rec_in                           okc_contract_pub.clev_rec_type;
      l_clev_rec_out                          okc_contract_pub.clev_rec_type;
      l_subs_item                             BOOLEAN := FALSE;
      l_clvl_name                             VARCHAR2 (240);
      l_clvl_desc                             VARCHAR2 (1000);
      l_tlvl_name                             VARCHAR2 (800);
      l_tlvl_desc                             VARCHAR2 (1000);
      l_line_no                               VARCHAR2 (300);
      l_status                                VARCHAR2 (30);         --3912685
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      x_return_status            := g_ret_sts_success;
      l_input_detail_rec         := p_detail_rec;
      -- Get top line details
      get_line_details (p_line_id                          => l_input_detail_rec.line_id,
                        x_name                             => l_tlvl_name,
                        x_description                      => l_tlvl_desc,
                        x_return_status                    => x_return_status,
                        x_msg_count                        => x_msg_count,
                        x_msg_data                         => x_msg_data
                       );

      IF x_return_status <> g_ret_sts_success
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '362:Get Line details ERROR in Topline'
                           );
         END IF;

         -- errorout('Get Line details ERROR in Topline');
         RAISE g_exc_error;
      END IF;

      FOR l_subline_rec IN l_subline_csr (l_input_detail_rec.line_id)
      LOOP
         BEGIN
            IF l_subline_rec.lse_id IN (9, 25)
            THEN
               l_subs_item                := is_subs_item (l_subline_rec.ID);
            ELSE
               l_subs_item                := FALSE;
            END IF;

            -- If its a Subscription item, skip iteration
            IF NOT l_subs_item
            THEN
               l_input_detail_rec.subline_id := l_subline_rec.ID;
               /** 3912685 **/
               check_pricing_eligibility
                                 (p_line_id                          => l_input_detail_rec.subline_id,
                                  x_status                           => l_status,
                                  x_return_status                    => x_return_status,
                                  x_msg_count                        => x_msg_count,
                                  x_msg_data                         => x_msg_data
                                 );

               IF x_return_status <> g_ret_sts_success
               THEN
                  RAISE g_exc_error;
               END IF;

               IF l_status <> g_oks_success
               THEN
                  x_price_details.status_code := l_status;
                  RAISE g_exc_cant_price;
               END IF;

               /** **/
               oks_qp_pkg.calc_price
                              (p_detail_rec                       => l_input_detail_rec,
                               x_price_details                    => x_price_details,
                               x_modifier_details                 => x_modifier_details,
                               x_price_break_details              => x_price_break_details,
                               x_return_status                    => x_return_status,
                               x_msg_count                        => x_msg_count,
                               x_msg_data                         => x_msg_data
                              );

               IF x_return_status <> g_ret_sts_success
               THEN
                  IF (fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                           (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '363:CALC PRICE ERROR after SAPI call in Topline'
                           );
                  END IF;

                  -- errorout('CALC PRICE ERROR after SAPI call in Topline');
                  RAISE g_skip_exception;
               END IF;

               l_rail_rec.amount          :=
                                      NVL (x_price_details.serv_ext_amount, 0);
               l_rail_rec.tax_value       := NULL;
               l_rail_rec.amount_includes_tax_flag := NULL;
               -- Calculate Tax
               oks_tax_util_pvt.get_tax
                                   (p_api_version                      => l_api_version,
                                    p_init_msg_list                    => l_init_msg_list,
                                    p_chr_id                           => l_input_detail_rec.chr_id,
                                    p_cle_id                           => l_input_detail_rec.subline_id,
                                    px_rail_rec                        => l_rail_rec,
                                    x_msg_count                        => x_msg_count,
                                    x_msg_data                         => x_msg_data,
                                    x_return_status                    => x_return_status
                                   );

               IF x_return_status <> g_ret_sts_success
               THEN
                  IF (fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING (fnd_log.level_statement,
                                     g_module ||
                                     l_api_name,
                                     '364:TAX CALC ERROR in Topline x_return_status '||x_return_status
                                    );
                     fnd_log.STRING (fnd_log.level_statement,
                                     g_module ||
                                     l_api_name,
                                     'x_msg_data '||x_msg_data
                                    );
                  END IF;

                  -- errorout('TAX CALC ERROR in Topline');
                  -- bug 5001677, even if tax error continue
                  -- RAISE g_skip_exception;
                    l_rail_rec.tax_value                :=  0;
                    l_rail_rec.amount_includes_tax_flag := 'N';
               END IF;

               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '366:l_rail_rec.TAX_VALUE = ' ||
                                  l_rail_rec.tax_value
                                 );
                  fnd_log.STRING
                              (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '367:l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG = ' ||
                               l_rail_rec.amount_includes_tax_flag
                              );
               END IF;

               --errorout('l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG = '||l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG );
               --errorout('l_rail_rec.TAX_VALUE = '||  l_rail_rec.TAX_VALUE );
               --errorout('l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG = '||l_rail_rec.AMOUNT_INCLUDES_TAX_FLAG );
               l_kln_rec_in.cle_id        := l_input_detail_rec.subline_id;
               l_kln_rec_in.dnz_chr_id    := l_input_detail_rec.chr_id;
               l_kln_rec_in.tax_inclusive_yn :=
                                           l_rail_rec.amount_includes_tax_flag;

               IF l_rail_rec.amount_includes_tax_flag = 'N'
               THEN
                  l_kln_rec_in.tax_amount    := NVL (l_rail_rec.tax_value, 0);
               ELSE
                  l_kln_rec_in.tax_amount    := 0;
               END IF;

               IF x_price_details.prod_price_list_id IS NOT NULL
               THEN
                  l_kln_rec_in.prod_price    :=
                                           x_price_details.prod_price_list_id;
               END IF;

               IF x_price_details.serv_price_list_id IS NOT NULL
               THEN
                  l_kln_rec_in.service_price :=
                                           x_price_details.serv_price_list_id;
               END IF;

               l_kln_rec_in.clvl_list_price :=
                                          x_price_details.prod_list_unit_price;
               l_kln_rec_in.clvl_quantity := x_price_details.prod_priced_qty;
               l_kln_rec_in.clvl_extended_amt :=
                                               x_price_details.prod_ext_amount;
               l_kln_rec_in.toplvl_operand_code :=
                                                 x_price_details.serv_operator;
               l_kln_rec_in.toplvl_operand_val := x_price_details.serv_operand;
               l_kln_rec_in.clvl_uom_code := x_price_details.prod_priced_uom;
               l_kln_rec_in.toplvl_quantity := x_price_details.serv_qty;
               l_kln_rec_in.toplvl_uom_code := x_price_details.serv_priced_uom;
               l_kln_rec_in.toplvl_adj_price :=
                                           x_price_details.serv_adj_unit_price;
               -- GCHADHA --
               -- BUG 4015739 --
               -- 17-NOV-2004 --
               l_kln_rec_in.status_text   :=
                  SUBSTR (NVL (x_price_details.status_text, g_sts_txt_success),
                          1,
                          450
                         );
                    --l_kln_rec_in.status_text         := NVL(x_price_details.status_text,G_STS_TXT_SUCCESS);
               -- END GCHADHA --
               l_kln_rec_in.toplvl_price_qty :=
                                               x_price_details.serv_priced_qty;
               get_k_details (p_id                               => l_input_detail_rec.subline_id,
                              p_type                             => g_oks_line,
                              x_k_det_rec                        => l_k_det_rec
                             );
               l_kln_rec_in.ID            := l_k_det_rec.ID;
               l_kln_rec_in.object_version_number :=
                                             l_k_det_rec.object_version_number;
               oks_contract_line_pub.update_line
                                          (p_api_version                      => l_api_version,
                                           p_init_msg_list                    => l_init_msg_list,
                                           x_return_status                    => x_return_status,
                                           x_msg_count                        => x_msg_count,
                                           x_msg_data                         => x_msg_data,
                                           p_klnv_rec                         => l_kln_rec_in,
                                           x_klnv_rec                         => l_kln_rec_out,
                                           p_validate_yn                      => 'N'
                                          );

               IF x_return_status <> g_ret_sts_success
               THEN
                  IF (fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                              (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '368:Update line details at Calc Subscription'
                              );
                  END IF;

                  --errorout('Update line details at Calc Subscription');
                  RAISE g_skip_exception;
               END IF;

               l_clev_rec_in.ID           := l_input_detail_rec.subline_id;
               l_clev_rec_in.line_list_price :=
                                          x_price_details.serv_list_unit_price;
               l_clev_rec_in.price_negotiated :=
                                               x_price_details.serv_ext_amount;
               l_clev_rec_in.price_unit   :=
                  NVL (x_price_details.serv_adj_unit_price,
                       x_price_details.serv_list_unit_price);
               --bug 3360423 list_unit_price will be stored in the database instead of adj_unit_price
               get_k_details (p_id                               => l_input_detail_rec.subline_id,
                              p_type                             => g_okc_line,
                              x_k_det_rec                        => l_k_det_rec
                             );
               l_clev_rec_in.object_version_number :=
                                             l_k_det_rec.object_version_number;
               okc_contract_pub.update_contract_line
                                          (p_api_version                      => l_api_version,
                                           p_init_msg_list                    => l_init_msg_list,
                                           x_return_status                    => x_return_status,
                                           x_msg_count                        => x_msg_count,
                                           x_msg_data                         => x_msg_data,
                                           p_clev_rec                         => l_clev_rec_in,
                                           x_clev_rec                         => l_clev_rec_out
                                          );

               IF x_return_status <> g_ret_sts_success
               THEN
                  IF (fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '369:Contract line updation ERROR in Subline Price - Topline Price'
                        );
                  END IF;

                  -- errorout ('Contract line updation ERROR in Subline Price - Topline Price');
                  RAISE g_skip_exception;
               END IF;

               -- Clear the record so as to reuse it
               l_clev_rec_in.ID           := okc_api.g_miss_num;
               --l_clev_rec_in.chr_id           := OKC_API.G_MISS_NUM;
               --l_clev_rec_in.cle_id           := OKC_API.G_MISS_NUM;
               l_clev_rec_in.price_negotiated := okc_api.g_miss_num;
               l_clev_rec_in.price_unit   := okc_api.g_miss_num;
               -- Get covered line details
               get_line_details (p_line_id                          => l_input_detail_rec.subline_id,
                                 x_name                             => l_clvl_name,
                                 x_description                      => l_clvl_desc,
                                 x_return_status                    => x_return_status,
                                 x_msg_count                        => x_msg_count,
                                 x_msg_data                         => x_msg_data
                                );
               g_pricing_status_tbl (g_index).service_name := l_tlvl_name;
               g_pricing_status_tbl (g_index).coverage_level_name :=
                                                                   l_clvl_name;
               g_pricing_status_tbl (g_index).status_code :=
                                                            g_sts_code_success;
               l_line_no                  :=
                                   get_line_no (l_input_detail_rec.subline_id);

               IF l_line_no IS NULL
               THEN
                  g_pricing_status_tbl (g_index).status_text :=
                         NVL (x_price_details.status_text, g_sts_txt_success);
               ELSE
                   -- bug 4730011
                  fnd_message.set_name ('OKS', 'OKS_LINE_REPRICE_SUCCESS');
                  fnd_message.set_token ('LINENO', l_line_no);
                  g_pricing_status_tbl (g_index).status_text := fnd_message.get;
                     -- l_line_no ||' ' ||NVL (x_price_details.status_text, g_sts_txt_success);
               END IF;

               g_index                    := g_index +
                                             1;
            END IF;               -- Skip iteration if its a Subscription item

            -- end debug log
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '1000: Leaving ' ||
                               g_pkg_name ||
                               '.' ||
                               l_api_name
                              );
            END IF;
         EXCEPTION
            WHEN g_exc_cant_price
            THEN
               -- end debug log
               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_procedure,
                                  g_module ||
                                  l_api_name,
                                  '7000: Leaving ' ||
                                  g_pkg_name ||
                                  '.' ||
                                  l_api_name
                                 );
               END IF;

               -- Get covered line details
               get_line_details (p_line_id                          => l_input_detail_rec.subline_id,
                                 x_name                             => l_clvl_name,
                                 x_description                      => l_clvl_desc,
                                 x_return_status                    => x_return_status,
                                 x_msg_count                        => x_msg_count,
                                 x_msg_data                         => x_msg_data
                                );
               g_pricing_status_tbl (g_index).service_name := l_tlvl_name;
               g_pricing_status_tbl (g_index).coverage_level_name :=
                                                                   l_clvl_name;
               g_pricing_status_tbl (g_index).status_code :=
                                                            g_sts_code_success;

               IF x_price_details.status_code = g_partial_billed
                                 or
                  x_price_details.status_code = g_fully_billed
               THEN
                  g_pricing_status_tbl (g_index).status_text := g_billed_line;
               ELSE
                  g_pricing_status_tbl (g_index).status_text :=
                                                            g_sts_txt_success;
               END IF;

               g_index                    := g_index +
                                             1;

               IF    l_status = g_fully_billed
                  OR l_status = g_partial_billed
               THEN
                  x_price_details.status_code := g_billed;
               END IF;
            WHEN g_skip_exception
            THEN
               -- end debug log
               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_procedure,
                                  g_module ||
                                  l_api_name,
                                  '9000: Leaving ' ||
                                  g_pkg_name ||
                                  '.' ||
                                  l_api_name
                                 );
               END IF;

               -- Get covered line details
               get_line_details (p_line_id                          => l_input_detail_rec.subline_id,
                                 x_name                             => l_clvl_name,
                                 x_description                      => l_clvl_desc,
                                 x_return_status                    => x_return_status,
                                 x_msg_count                        => x_msg_count,
                                 x_msg_data                         => x_msg_data
                                );
               g_pricing_status_tbl (g_index).service_name := l_tlvl_name;
               g_pricing_status_tbl (g_index).coverage_level_name :=
                                                                   l_clvl_name;
               g_pricing_status_tbl (g_index).status_code := g_sts_code_error;
               l_line_no                  :=
                                   get_line_no (l_input_detail_rec.subline_id);

               IF l_line_no IS NULL
               THEN
                  g_pricing_status_tbl (g_index).status_text :=
                           NVL (x_price_details.status_text, g_sts_txt_error);
               ELSE
                 -- bug 4730011
                 fnd_message.set_name ('OKS', 'OKS_LINE_REPRICE_SUCCESS');
                 fnd_message.set_token ('LINENO', l_line_no);
                 g_pricing_status_tbl (g_index).status_text := fnd_message.get;
                  -- l_line_no ||' ' ||NVL (x_price_details.status_text, g_sts_txt_error);
               END IF;

               g_index                    := g_index +
                                             1;
         END;
      END LOOP;

      l_clev_rec_in.ID           := l_input_detail_rec.line_id;
      l_clev_rec_in.price_negotiated :=
         get_amounts (p_id                               => l_input_detail_rec.line_id,
                      p_level                            => g_line_level);
      get_k_details (p_id                               => l_input_detail_rec.line_id,
                     p_type                             => g_okc_line,
                     x_k_det_rec                        => l_k_det_rec
                    );
      l_clev_rec_in.object_version_number := l_k_det_rec.object_version_number;
      okc_contract_pub.update_contract_line
                                          (p_api_version                      => l_api_version,
                                           p_init_msg_list                    => l_init_msg_list,
                                           x_return_status                    => x_return_status,
                                           x_msg_count                        => x_msg_count,
                                           x_msg_data                         => x_msg_data,
                                           p_clev_rec                         => l_clev_rec_in,
                                           x_clev_rec                         => l_clev_rec_out
                                          );

      IF x_return_status <> g_ret_sts_success
      THEN
         RAISE g_exc_error;
      END IF;

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN g_exc_error
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '2000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         NULL;
      WHEN OTHERS
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status            := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name                         => g_app_name,
                              p_msg_name                         => g_unexpected_error,
                              p_token1                           => g_sqlcode_token,
                              p_token1_value                     => SQLCODE,
                              p_token2                           => g_sqlerrm_token,
                              p_token2_value                     => SQLERRM
                             );
   END calculate_topline_price;

   PROCEDURE calculate_hdr_price (
      p_detail_rec                    IN       oks_qp_pkg.input_details,
      x_price_details                 OUT NOCOPY oks_qp_pkg.price_details,
      x_modifier_details              OUT NOCOPY qp_preq_grp.line_detail_tbl_type,
      x_price_break_details           OUT NOCOPY oks_qp_pkg.g_price_break_tbl_type,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER,
      x_msg_data                      OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                     := 'CALCULATE_HDR_PRICE';

      CURSOR l_topline_csr (
         p_chr_id                                 NUMBER
      )
      IS
         SELECT   ID,
                  start_date,
                  end_date,
                  lse_id
             FROM okc_k_lines_b
            WHERE chr_id = p_chr_id
              AND lse_id IN (1, 14, 19, 46)
              AND date_cancelled IS NULL                   --[llc] bug 4653406
              AND date_terminated IS NULL                  -- bug 5504157
         ORDER BY line_number;

      l_input_details                         oks_qp_pkg.input_details;
      l_chrv_rec_in                           okc_contract_pub.chrv_rec_type;
      l_chrv_rec_out                          okc_contract_pub.chrv_rec_type;
      l_k_det_rec                             k_details_rec;
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      x_return_status            := g_ret_sts_success;

      FOR l_topline_rec IN l_topline_csr (p_detail_rec.chr_id)
      LOOP
         BEGIN
            IF l_topline_rec.lse_id = g_subscription
            THEN
               l_input_details.chr_id     := p_detail_rec.chr_id;
               l_input_details.line_id    := l_topline_rec.ID;
               l_input_details.subline_id := NULL;
               l_input_details.intent     := g_subsc_reg_pricing;
               l_input_details.currency   := p_detail_rec.currency;
               l_input_details.usage_qty  := NULL;
               l_input_details.usage_uom_code := NULL;
               l_input_details.asking_unit_price := NULL;
               calculate_subscription_price
                             (p_detail_rec                       => l_input_details,
                              x_price_details                    => x_price_details,
                              x_modifier_details                 => x_modifier_details,
                              x_price_break_details              => x_price_break_details,
                              x_return_status                    => x_return_status,
                              x_msg_count                        => x_msg_count,
                              x_msg_data                         => x_msg_data
                             );

               IF x_return_status <> g_ret_sts_success
               THEN
                  IF (fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                              (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '370:CALC SUBSCRIPTION ERROR at Calc Hdr call'
                              );
                  END IF;

                  -- errorout('CALC SUBSCRIPTION ERROR at Calc Hdr call');
                  RAISE g_skip_exception;
               END IF;
            ELSE
               l_input_details.chr_id     := p_detail_rec.chr_id;
               l_input_details.line_id    := l_topline_rec.ID;
               l_input_details.subline_id := NULL;
               l_input_details.intent     := g_top_line_pricing;
               l_input_details.currency   := p_detail_rec.currency;
               l_input_details.usage_qty  := NULL;
               l_input_details.usage_uom_code := NULL;
               l_input_details.asking_unit_price := NULL;
               calculate_topline_price
                             (p_detail_rec                       => l_input_details,
                              x_price_details                    => x_price_details,
                              x_modifier_details                 => x_modifier_details,
                              x_price_break_details              => x_price_break_details,
                              x_return_status                    => x_return_status,
                              x_msg_count                        => x_msg_count,
                              x_msg_data                         => x_msg_data
                             );

               IF x_return_status <> g_ret_sts_success
               THEN
                  IF (fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                                   (fnd_log.level_statement,
                                    g_module ||
                                    l_api_name,
                                    '371:CALC TOPLINE ERROR at Calc Hdr call'
                                   );
                  END IF;

                  -- errorout('CALC TOPLINE ERROR at Calc Hdr call');
                  RAISE g_skip_exception;
               END IF;
            END IF;

            -- end debug log
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '1000: Leaving ' ||
                               g_pkg_name ||
                               '.' ||
                               l_api_name
                              );
            END IF;
         EXCEPTION
            WHEN g_skip_exception
            THEN
               -- end debug log
               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_procedure,
                                  g_module ||
                                  l_api_name,
                                  '9000: Leaving ' ||
                                  g_pkg_name ||
                                  '.' ||
                                  l_api_name
                                 );
               END IF;

               NULL;
         END;
      END LOOP;

      l_chrv_rec_in.ID           := p_detail_rec.chr_id;
      l_chrv_rec_in.estimated_amount :=
             get_amounts (p_id                               => p_detail_rec.chr_id,
                          p_level                            => g_hdr_level);
      get_k_details (p_id                               => p_detail_rec.chr_id,
                     p_type                             => g_okc_hdr,
                     x_k_det_rec                        => l_k_det_rec
                    );
      l_chrv_rec_in.object_version_number := l_k_det_rec.object_version_number;
      okc_contract_pub.update_contract_header
                                      (p_api_version                      => l_api_version,
                                       p_init_msg_list                    => l_init_msg_list,
                                       x_return_status                    => x_return_status,
                                       x_msg_count                        => x_msg_count,
                                       x_msg_data                         => x_msg_data,
                                       p_restricted_update                => okc_api.g_false,
                                       p_chrv_rec                         => l_chrv_rec_in,
                                       x_chrv_rec                         => l_chrv_rec_out
                                      );

      IF x_return_status <> g_ret_sts_success
      THEN
         RAISE g_exc_error;
      END IF;

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN g_exc_error
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '2000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         NULL;
      WHEN OTHERS
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status            := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name                         => g_app_name,
                              p_msg_name                         => g_unexpected_error,
                              p_token1                           => g_sqlcode_token,
                              p_token1_value                     => SQLCODE,
                              p_token2                           => g_sqlerrm_token,
                              p_token2_value                     => SQLERRM
                             );
   END calculate_hdr_price;

   PROCEDURE compute_price (
      p_api_version                   IN       NUMBER,
      p_init_msg_list                 IN       VARCHAR2,
      p_detail_rec                    IN       oks_qp_pkg.input_details,
      x_price_details                 OUT NOCOPY oks_qp_pkg.price_details,
      x_modifier_details              OUT NOCOPY qp_preq_grp.line_detail_tbl_type,
      x_price_break_details           OUT NOCOPY oks_qp_pkg.g_price_break_tbl_type,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER,
      x_msg_data                      OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                           := 'compute_price';
      l_input_detail_rec                      oks_qp_pkg.input_details
                                                              := p_detail_rec;
      l_k_det_rec                             k_details_rec;
      l_chrv_rec_in                           okc_contract_pub.chrv_rec_type;
      l_chrv_rec_out                          okc_contract_pub.chrv_rec_type;
      l_clev_rec_in                           okc_contract_pub.clev_rec_type;
      l_clev_rec_out                          okc_contract_pub.clev_rec_type;
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
         fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: ***************** Parameters : ******************'
                     );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100:CHR_ID            = ' ||
                         p_detail_rec.chr_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100:LINE_ID           = ' ||
                         p_detail_rec.line_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100:SUBLINE_ID        = ' ||
                         p_detail_rec.subline_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100:INTENT            = ' ||
                         p_detail_rec.intent
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100:CURRENCY          = ' ||
                         p_detail_rec.currency
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100:Usage Qty         = ' ||
                         p_detail_rec.usage_qty
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100:Usage UOM Code    = ' ||
                         p_detail_rec.usage_uom_code
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100:Asking Unit Price  = ' ||
                         p_detail_rec.asking_unit_price
                        );
      END IF;

      --errorout ('********** Entered Compute Price ********');
      --errorout ('CHR_ID            = ' || p_detail_rec.chr_id);
      --errorout ('LINE_ID           = ' || p_detail_rec.line_id);
      --errorout ('SUBLINE_ID        = ' || p_detail_rec.subline_id);
      --errorout ('INTENT            = ' || p_detail_rec.intent);
      --errorout ('CURRENCY          = ' || p_detail_rec.currency);
      --errorout ('Usage Qty         = ' || p_detail_rec.usage_qty);
      --errorout ('Usage UOM Code    = ' || p_detail_rec.usage_uom_code);
      --errorout ('AskingUnit Price  = ' || p_detail_rec.asking_unit_price);

      -- Make a save point, in case of error rollback
      DBMS_TRANSACTION.SAVEPOINT ('COMPUTE_PRICE');

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      x_return_status            := g_ret_sts_success;
      -- Always initialize the Pricing message table
      g_pricing_status_tbl.DELETE;
      g_index                    := 0;
      fnd_message.set_name ('OKS', 'OKS_SUCCESS');
      g_sts_txt_success          := fnd_message.get;
      fnd_message.set_name ('OKS', 'OKS_ERROR');
      g_sts_txt_error            := fnd_message.get;
      fnd_message.set_name ('OKS', 'OKS_PRICE_STATUS_MAN_ADJ');
      g_manual_adj_price         := fnd_message.get;
      fnd_message.set_name ('OKS', 'OKS_BILLED_LINE');
      g_billed_line              := fnd_message.get;

      IF p_detail_rec.intent = g_header_pricing
      THEN
         IF p_detail_rec.chr_id IS NOT NULL
         THEN
            calculate_hdr_price
                             (p_detail_rec                       => p_detail_rec,
                              x_price_details                    => x_price_details,
                              x_modifier_details                 => x_modifier_details,
                              x_price_break_details              => x_price_break_details,
                              x_return_status                    => x_return_status,
                              x_msg_count                        => x_msg_count,
                              x_msg_data                         => x_msg_data
                             );

            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;
         ELSE
            okc_api.set_message (p_app_name                         => g_app_name,
                                 p_msg_name                         => g_required_value,
                                 p_token1                           => g_invalid_value,
                                 p_token1_value                     => 'CHR_ID'
                                );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '372:Contract header id is NULL'
                              );
            END IF;

            -- errorout ('Contract header id is NULL');
            x_return_status            := g_ret_sts_error;
            RAISE g_exc_error;
         END IF;
      ELSIF p_detail_rec.intent = g_top_line_pricing
      THEN
         IF p_detail_rec.line_id IS NOT NULL
         THEN
            IF p_detail_rec.chr_id IS NULL
            THEN
               get_id (p_line_id                          => p_detail_rec.line_id,
                       x_chr_id                           => l_input_detail_rec.chr_id,
                       x_topline_id                       => l_input_detail_rec.subline_id,
                       x_return_status                    => x_return_status
                      );

               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '373:Get_id chr_id in CompP = ' ||
                                  l_input_detail_rec.chr_id
                                 );
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '374:Get_id topline_id in CompP = ' ||
                                  l_input_detail_rec.line_id
                                 );
               END IF;

               --errorout ('Get_id chr_id in CompP = ' || l_input_detail_rec.chr_id);
               --errorout ('Get_id topline_id in CompP = ' || l_input_detail_rec.line_id);
               IF x_return_status <> g_ret_sts_success
               THEN
                  IF (fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING (fnd_log.level_statement,
                                     g_module ||
                                     l_api_name,
                                     '375:Get_id return status = ' ||
                                     x_return_status
                                    );
                  END IF;

                  --errorout ('Get_id return status = ' || x_return_status);
                  RAISE g_exc_error;
               END IF;
            END IF;

            calculate_topline_price
                              (p_detail_rec                       => l_input_detail_rec,
                               x_price_details                    => x_price_details,
                               x_modifier_details                 => x_modifier_details,
                               x_price_break_details              => x_price_break_details,
                               x_return_status                    => x_return_status,
                               x_msg_count                        => x_msg_count,
                               x_msg_data                         => x_msg_data
                              );

            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;

            l_chrv_rec_in.ID           := l_input_detail_rec.chr_id;
            l_chrv_rec_in.estimated_amount :=
               get_amounts (p_id                               => l_input_detail_rec.chr_id,
                            p_level                            => g_hdr_level);
            get_k_details (p_id                               => l_input_detail_rec.chr_id,
                           p_type                             => g_okc_hdr,
                           x_k_det_rec                        => l_k_det_rec
                          );
            l_chrv_rec_in.object_version_number :=
                                             l_k_det_rec.object_version_number;
            okc_contract_pub.update_contract_header
                                      (p_api_version                      => l_api_version,
                                       p_init_msg_list                    => l_init_msg_list,
                                       x_return_status                    => x_return_status,
                                       x_msg_count                        => x_msg_count,
                                       x_msg_data                         => x_msg_data,
                                       p_restricted_update                => okc_api.g_false,
                                       p_chrv_rec                         => l_chrv_rec_in,
                                       x_chrv_rec                         => l_chrv_rec_out
                                      );

            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;
         ELSE
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '376:Top Line id is NULL'
                              );
            END IF;

            --errorout ('Top Line id is NULL');
            okc_api.set_message (p_app_name                         => g_app_name,
                                 p_msg_name                         => g_required_value,
                                 p_token1                           => g_invalid_value,
                                 p_token1_value                     => 'CLE_ID'
                                );
            x_return_status            := g_ret_sts_error;
            RAISE g_exc_error;
         END IF;
      ELSIF p_detail_rec.intent = g_sub_line_pricing
      THEN
         IF p_detail_rec.subline_id IS NOT NULL
         THEN
            IF (   p_detail_rec.line_id IS NULL
                OR p_detail_rec.chr_id IS NULL
               )
            THEN
               get_id (p_line_id                          => p_detail_rec.subline_id,
                       x_chr_id                           => l_input_detail_rec.chr_id,
                       x_topline_id                       => l_input_detail_rec.line_id,
                       x_return_status                    => x_return_status
                      );

               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '377:Get_id topline_id = ' ||
                                  l_input_detail_rec.line_id
                                 );
               END IF;

               --errorout ('Get_id topline_id = ' || l_input_detail_rec.line_id);
               IF x_return_status <> g_ret_sts_success
               THEN
                  IF (fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING (fnd_log.level_statement,
                                     g_module ||
                                     l_api_name,
                                     '378:Get_id return status = ' ||
                                     x_return_status
                                    );
                  END IF;

                  --errorout ('Get_id return status = ' || x_return_status);
                  RAISE g_exc_error;
               END IF;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '379:here is Sub line'
                              );
            END IF;

            --errorout ('here is Sub line');
            calculate_subline_price
                              (p_detail_rec                       => l_input_detail_rec,
                               x_price_details                    => x_price_details,
                               x_modifier_details                 => x_modifier_details,
                               x_price_break_details              => x_price_break_details,
                               x_return_status                    => x_return_status,
                               x_msg_count                        => x_msg_count,
                               x_msg_data                         => x_msg_data
                              );

            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;

            l_clev_rec_in.ID           := l_input_detail_rec.line_id;
            l_clev_rec_in.price_negotiated :=
               get_amounts (p_id                               => l_input_detail_rec.line_id,
                            p_level                            => g_line_level);
            get_k_details (p_id                               => l_input_detail_rec.line_id,
                           p_type                             => g_okc_line,
                           x_k_det_rec                        => l_k_det_rec
                          );
            l_clev_rec_in.object_version_number :=
                                             l_k_det_rec.object_version_number;
            okc_contract_pub.update_contract_line
                                          (p_api_version                      => l_api_version,
                                           p_init_msg_list                    => l_init_msg_list,
                                           x_return_status                    => x_return_status,
                                           x_msg_count                        => x_msg_count,
                                           x_msg_data                         => x_msg_data,
                                           p_clev_rec                         => l_clev_rec_in,
                                           x_clev_rec                         => l_clev_rec_out
                                          );

            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;

            l_chrv_rec_in.ID           := l_input_detail_rec.chr_id;
            l_chrv_rec_in.estimated_amount :=
               get_amounts (p_id                               => l_input_detail_rec.chr_id,
                            p_level                            => g_hdr_level);
            get_k_details (p_id                               => l_input_detail_rec.chr_id,
                           p_type                             => g_okc_hdr,
                           x_k_det_rec                        => l_k_det_rec
                          );
            l_chrv_rec_in.object_version_number :=
                                             l_k_det_rec.object_version_number;
            okc_contract_pub.update_contract_header
                                      (p_api_version                      => l_api_version,
                                       p_init_msg_list                    => l_init_msg_list,
                                       x_return_status                    => x_return_status,
                                       x_msg_count                        => x_msg_count,
                                       x_msg_data                         => x_msg_data,
                                       p_restricted_update                => okc_api.g_false,
                                       p_chrv_rec                         => l_chrv_rec_in,
                                       x_chrv_rec                         => l_chrv_rec_out
                                      );

            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;
         ELSE
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '380:Sub line id is NULL'
                              );
            END IF;

            --errorout ('Sub line id is NULL');
            okc_api.set_message (p_app_name                         => g_app_name,
                                 p_msg_name                         => g_required_value,
                                 p_token1                           => g_invalid_value,
                                 p_token1_value                     => 'LINE_ID'
                                );
            x_return_status            := g_ret_sts_error;
            RAISE g_exc_error;
         END IF;
      ELSIF p_detail_rec.intent IN (g_subsc_reg_pricing, g_subsc_ovr_pricing)
      THEN
         IF p_detail_rec.line_id IS NOT NULL
         THEN
            IF p_detail_rec.chr_id IS NULL
            THEN
               get_id (p_line_id                          => p_detail_rec.line_id,
                       x_chr_id                           => l_input_detail_rec.chr_id,
                       x_topline_id                       => l_input_detail_rec.subline_id,
                       x_return_status                    => x_return_status
                      );

               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '381:Get_id chr_id in CompP = ' ||
                                  l_input_detail_rec.chr_id
                                 );
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '382:Get_id topline_id in CompP = ' ||
                                  l_input_detail_rec.line_id
                                 );
               END IF;

               --errorout ('Get_id chr_id in CompP = ' || l_input_detail_rec.chr_id);
               --errorout ('Get_id topline_id in CompP = ' || l_input_detail_rec.line_id);
               IF x_return_status <> g_ret_sts_success
               THEN
                  IF (fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING (fnd_log.level_statement,
                                     g_module ||
                                     l_api_name,
                                     '383:Get_id return status = ' ||
                                     x_return_status
                                    );
                  END IF;

                  --errorout ('Get_id return status = ' || x_return_status);
                  RAISE g_exc_error;
               END IF;
            END IF;

            calculate_subscription_price
                              (p_detail_rec                       => l_input_detail_rec,
                               x_price_details                    => x_price_details,
                               x_modifier_details                 => x_modifier_details,
                               x_price_break_details              => x_price_break_details,
                               x_return_status                    => x_return_status,
                               x_msg_count                        => x_msg_count,
                               x_msg_data                         => x_msg_data
                              );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_statement,
                   g_module ||
                   l_api_name,
                   '384:after CSUBS - In compute price - return status = ' ||
                   x_return_status
                  );
            END IF;

            -- errorout ('after CSUBS - In compute price - return status = ' || x_return_status);
            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '385:Chr_id = ' ||
                               l_input_detail_rec.chr_id
                              );
            END IF;

            -- errorout ('Chr_id = ' || l_input_detail_rec.chr_id);
            l_chrv_rec_in.ID           := l_input_detail_rec.chr_id;
            l_chrv_rec_in.estimated_amount :=
               get_amounts (p_id                               => l_input_detail_rec.chr_id,
                            p_level                            => g_hdr_level);
            get_k_details (p_id                               => l_input_detail_rec.chr_id,
                           p_type                             => g_okc_hdr,
                           x_k_det_rec                        => l_k_det_rec
                          );
            l_chrv_rec_in.object_version_number :=
                                             l_k_det_rec.object_version_number;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '386:Amount  = ' ||
                               l_chrv_rec_in.estimated_amount
                              );
            END IF;

            -- errorout ('Amount  = ' || l_chrv_rec_in.estimated_amount);
            okc_contract_pub.update_contract_header
                                      (p_api_version                      => l_api_version,
                                       p_init_msg_list                    => l_init_msg_list,
                                       x_return_status                    => x_return_status,
                                       x_msg_count                        => x_msg_count,
                                       x_msg_data                         => x_msg_data,
                                       p_restricted_update                => okc_api.g_false,
                                       p_chrv_rec                         => l_chrv_rec_in,
                                       x_chrv_rec                         => l_chrv_rec_out
                                      );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_statement,
                   g_module ||
                   l_api_name,
                   '387:after hdr updation - In compute price - return status = ' ||
                   x_return_status
                  );
            END IF;

            -- errorout ('after hdr updation - In compute price - return status = ' || x_return_status);
            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;
         ELSE
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '388:Line id is NULL'
                              );
            END IF;

            -- errorout ('Line id is NULL');
            okc_api.set_message (p_app_name                         => g_app_name,
                                 p_msg_name                         => g_required_value,
                                 p_token1                           => g_invalid_value,
                                 p_token1_value                     => 'CLE_ID'
                                );
            x_return_status            := g_ret_sts_error;
            RAISE g_exc_error;
         END IF;
      ELSIF p_detail_rec.intent = g_override_pricing
      THEN
         IF p_detail_rec.subline_id IS NOT NULL
         THEN
            IF (   p_detail_rec.line_id IS NULL
                OR p_detail_rec.chr_id IS NULL
               )
            THEN
               get_id (p_line_id                          => p_detail_rec.subline_id,
                       x_chr_id                           => l_input_detail_rec.chr_id,
                       x_topline_id                       => l_input_detail_rec.line_id,
                       x_return_status                    => x_return_status
                      );

               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '389:Get_id topline_id = ' ||
                                  l_input_detail_rec.line_id
                                 );
               END IF;

               --errorout ('Get_id topline_id = ' || l_input_detail_rec.line_id);
               IF x_return_status <> g_ret_sts_success
               THEN
                  --errorout ('Get_id return status = ' || x_return_status);
                  RAISE g_exc_error;
               END IF;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '390:here is Sub line'
                              );
            END IF;

            -- errorout ('here is Sub line');
            calculate_subline_price
                              (p_detail_rec                       => l_input_detail_rec,
                               x_price_details                    => x_price_details,
                               x_modifier_details                 => x_modifier_details,
                               x_price_break_details              => x_price_break_details,
                               x_return_status                    => x_return_status,
                               x_msg_count                        => x_msg_count,
                               x_msg_data                         => x_msg_data
                              );

            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;

            l_clev_rec_in.ID           := l_input_detail_rec.line_id;
            l_clev_rec_in.price_negotiated :=
               get_amounts (p_id                               => l_input_detail_rec.line_id,
                            p_level                            => g_line_level);
            get_k_details (p_id                               => l_input_detail_rec.line_id,
                           p_type                             => g_okc_line,
                           x_k_det_rec                        => l_k_det_rec
                          );
            l_clev_rec_in.object_version_number :=
                                             l_k_det_rec.object_version_number;
            okc_contract_pub.update_contract_line
                                          (p_api_version                      => l_api_version,
                                           p_init_msg_list                    => l_init_msg_list,
                                           x_return_status                    => x_return_status,
                                           x_msg_count                        => x_msg_count,
                                           x_msg_data                         => x_msg_data,
                                           p_clev_rec                         => l_clev_rec_in,
                                           x_clev_rec                         => l_clev_rec_out
                                          );

            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;

            l_chrv_rec_in.ID           := l_input_detail_rec.chr_id;
            l_chrv_rec_in.estimated_amount :=
               get_amounts (p_id                               => l_input_detail_rec.chr_id,
                            p_level                            => g_hdr_level);
            get_k_details (p_id                               => l_input_detail_rec.chr_id,
                           p_type                             => g_okc_hdr,
                           x_k_det_rec                        => l_k_det_rec
                          );
            l_chrv_rec_in.object_version_number :=
                                             l_k_det_rec.object_version_number;
            okc_contract_pub.update_contract_header
                                      (p_api_version                      => l_api_version,
                                       p_init_msg_list                    => l_init_msg_list,
                                       x_return_status                    => x_return_status,
                                       x_msg_count                        => x_msg_count,
                                       x_msg_data                         => x_msg_data,
                                       p_restricted_update                => okc_api.g_false,
                                       p_chrv_rec                         => l_chrv_rec_in,
                                       x_chrv_rec                         => l_chrv_rec_out
                                      );

            IF x_return_status <> g_ret_sts_success
            THEN
               RAISE g_exc_error;
            END IF;
         ELSE
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module ||
                               l_api_name,
                               '391:Sub line id is NULL'
                              );
            END IF;

            -- errorout ('Sub line id is NULL');
            okc_api.set_message (p_app_name                         => g_app_name,
                                 p_msg_name                         => g_required_value,
                                 p_token1                           => g_invalid_value,
                                 p_token1_value                     => 'LINE_ID'
                                );
            x_return_status            := g_ret_sts_error;
            RAISE g_exc_error;
         END IF;
      ELSE
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            '392:********** Invalid Intent ********'
                           );
         END IF;

         -- errorout ('********** Invalid Intent ********');
         okc_api.set_message (p_app_name                         => g_app_name,
                              p_msg_name                         => g_required_value,
                              p_token1                           => g_invalid_value,
                              p_token1_value                     => 'INTENT'
                             );
         x_return_status            := g_ret_sts_error;
         RAISE g_exc_error;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '393:********** Exiting Compute Price ********'
                        );
      END IF;

      -- errorout ('********** Exiting Compute Price ********');

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN g_exc_error
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '2000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         DBMS_TRANSACTION.rollback_savepoint ('COMPUTE_PRICE');
      WHEN OTHERS
      THEN
         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         DBMS_TRANSACTION.rollback_savepoint ('COMPUTE_PRICE');
         x_return_status            := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name                         => g_app_name,
                              p_msg_name                         => g_unexpected_error,
                              p_token1                           => g_sqlcode_token,
                              p_token1_value                     => SQLCODE,
                              p_token2                           => g_sqlerrm_token,
                              p_token2_value                     => SQLERRM
                             );
   END compute_price;
END oks_qp_int_pvt;

/
